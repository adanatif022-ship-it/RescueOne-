import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/language/app_language.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/models/chat_message.dart';
import '../../core/models/incident.dart';
import '../../core/services/hospital_repository.dart';
import '../../core/services/incident_repository.dart';
import '../../core/services/launcher_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/settings_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/assistant_nlp.dart';
import '../../core/utils/incident_ui.dart';
import '../../core/widgets/disclaimer_banner.dart';
import '../sos/incident_progress_screen.dart';

enum _Stage { type, injured, conscious, location, note, summary }

/// Rule-based incident intake (no external AI service, no API keys).
/// It classifies the emergency - from the quick buttons *or free text in
/// Arabic/English* (see assistant_nlp.dart) - and structures the answers
/// into a report. It never gives a diagnosis.
class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _messages = <ChatMessage>[];
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  _Stage _stage = _Stage.type;

  IncidentType? _type;
  String _typeFreeText = '';
  int _injured = 0;
  bool? _conscious;
  bool _locationAttached = false;
  double? _lat;
  double? _lng;
  String _note = '';
  bool _criticalSigns = false;
  bool _busy = false;
  bool _initialized = false;
  bool _creating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Seeding reads AppLanguage, which can't happen in initState; the flag
    // keeps a language switch from wiping the conversation.
    if (!_initialized) {
      _initialized = true;
      _pushAssistantKey('assistant_intro');
      _askCurrentStageQuestion();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _pushAssistant(String text) {
    setState(() {
      _messages.add(ChatMessage(sender: ChatSender.assistant, text: text));
    });
    _scrollToBottom();
  }

  void _pushAssistantKey(String key) => _pushAssistant(context.trRead(key));

  void _pushUser(String text) {
    setState(() {
      _messages.add(ChatMessage(sender: ChatSender.user, text: text));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    // The list is reversed (bottom-anchored), so offset 0 is the newest.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _askCurrentStageQuestion() {
    switch (_stage) {
      case _Stage.type:
        _pushAssistantKey('assistant_ask_type');
      case _Stage.injured:
        _pushAssistantKey('assistant_ask_injured');
      case _Stage.conscious:
        _pushAssistantKey('assistant_ask_conscious');
      case _Stage.location:
        _pushAssistantKey('assistant_ask_location');
      case _Stage.note:
        _pushAssistantKey('assistant_ask_note');
      case _Stage.summary:
        _pushAssistantKey('assistant_summary_title');
    }
  }

  static const _quickTypeKeys = {
    IncidentType.medical: 'assistant_quick_medical',
    IncidentType.fire: 'assistant_quick_fire',
    IncidentType.accident: 'assistant_quick_accident',
    IncidentType.danger: 'assistant_quick_danger',
    IncidentType.security: 'assistant_quick_security',
    IncidentType.other: 'assistant_quick_other',
  };

  List<String> get _currentQuickOptions {
    switch (_stage) {
      case _Stage.type:
        return _quickTypeKeys.values.map(context.tr).toList();
      case _Stage.injured:
        return ['0', '1', '2', '3+'];
      case _Stage.conscious:
      case _Stage.location:
        return [context.tr('yes'), context.tr('no')];
      case _Stage.note:
        return [context.tr('no')];
      case _Stage.summary:
        return [];
    }
  }

  /// Exact match with a quick-reply button (in either language).
  IncidentType? _typeFromButton(String label) {
    final lang = context.read<AppLanguage>();
    for (final entry in _quickTypeKeys.entries) {
      if (label == lang.tr(entry.value) ||
          label == lang.tr(incidentTypeKey(entry.key))) {
        return entry.key;
      }
    }
    return null;
  }

  void _checkCritical(String text) {
    if (!_criticalSigns && mentionsCriticalSigns(text)) {
      _criticalSigns = true;
      _pushAssistantKey('assistant_critical_detected');
    }
  }

  Future<void> _handleInput(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _busy) return;
    _pushUser(text);
    _textController.clear();

    switch (_stage) {
      case _Stage.type:
        final fromButton = _typeFromButton(text);
        if (fromButton != null) {
          _type = fromButton;
        } else {
          // Free text, e.g. "حريق كبير في المطبخ" or "car crash".
          _typeFreeText = text;
          _type = classifyIncidentText(text);
          if (_type == null) {
            _type = IncidentType.other;
            _pushAssistantKey('assistant_type_unknown');
          } else {
            _pushAssistant(
              context.trArgsRead('assistant_type_detected', {
                'type': context.trRead(incidentTypeKey(_type!)),
              }),
            );
          }
          _checkCritical(text);
        }
        _stage = _Stage.injured;
      case _Stage.injured:
        final count = parseInjuredCount(text);
        if (count == null) {
          _pushAssistantKey('assistant_not_understood_injured');
          return;
        }
        _injured = count;
        _stage = _Stage.conscious;
      case _Stage.conscious:
        final answer = parseYesNo(text);
        if (answer == null) {
          _pushAssistantKey('assistant_not_understood_yes_no');
          return;
        }
        _conscious = answer;
        _stage = _Stage.location;
      case _Stage.location:
        final wantsLocation = parseYesNo(text);
        if (wantsLocation == null) {
          _pushAssistantKey('assistant_not_understood_yes_no');
          return;
        }
        if (wantsLocation) {
          setState(() => _busy = true);
          final result = await context
              .read<LocationService>()
              .getCurrentLocation();
          if (!mounted) return;
          if (result.hasLocation) {
            _lat = result.latitude;
            _lng = result.longitude;
            _locationAttached = true;
            _pushAssistantKey('assistant_location_ok');
            // Start finding hospitals around this spot in the background.
            context.read<HospitalRepository>().useLocation(_lat!, _lng!);
          } else {
            _pushAssistantKey('assistant_location_failed');
          }
          setState(() => _busy = false);
        }
        _stage = _Stage.note;
      case _Stage.note:
        _note = parseYesNo(text) == false && text.length <= 4 ? '' : text;
        if (_note.isNotEmpty) _checkCritical(_note);
        _stage = _Stage.summary;
      case _Stage.summary:
        return;
    }

    if (!mounted) return;
    _askCurrentStageQuestion();
  }

  String get _urgencyKey => urgencyKeyFor(
    type: _type,
    conscious: _conscious,
    injured: _injured,
    criticalSigns: _criticalSigns,
  );

  /// Description saved with the incident - everything a responder needs.
  String _buildDescription() {
    final lang = context.read<AppLanguage>();
    final parts = <String>[
      if (_typeFreeText.isNotEmpty) _typeFreeText,
      if (_note.isNotEmpty && _note != _typeFreeText) _note,
      '${lang.tr('assistant_summary_injured')}: ${injuredLabel(_injured)}',
      '${lang.tr('assistant_summary_status')}: ${lang.tr(_conscious == false ? 'assistant_conscious_no' : 'assistant_conscious_yes')}',
      '${lang.tr('assistant_summary_urgency')}: ${lang.tr(_urgencyKey)}',
    ];
    return parts.join(' · ');
  }

  Future<void> _createIncidentFromSummary() async {
    if (_type == null || _creating) return;
    setState(() => _creating = true);
    final hospitalRepo = context.read<HospitalRepository>();
    final incidents = context.read<IncidentRepository>();
    final incident = await incidents.createIncident(
      type: _type!,
      description: _buildDescription(),
      mode: AlertMode.normal,
      location: _locationAttached && _lat != null && _lng != null
          ? IncidentLocation(latitude: _lat!, longitude: _lng!)
          : null,
      recommendedHospital: hospitalRepo.recommendationFor(_type!),
    );
    if (!mounted) return;
    setState(() => _creating = false);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => IncidentProgressScreen(incidentId: incident.id),
      ),
    );
  }

  Future<void> _callEmergency() async {
    final number = context.read<SettingsRepository>().emergencyNumber;
    final ok = await LauncherService().callNumber(number);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.trRead('sos_call_failed'))),
      );
    }
  }

  void _restart() {
    setState(() {
      _messages.clear();
      _stage = _Stage.type;
      _type = null;
      _typeFreeText = '';
      _injured = 0;
      _conscious = null;
      _locationAttached = false;
      _lat = null;
      _lng = null;
      _note = '';
      _criticalSigns = false;
    });
    _pushAssistantKey('assistant_intro');
    _askCurrentStageQuestion();
  }

  @override
  Widget build(BuildContext context) {
    final emergencyNumber = context.watch<SettingsRepository>().emergencyNumber;
    final showSummary = _stage == _Stage.summary && _type != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
              child: Icon(
                Icons.smart_toy_rounded,
                size: 16,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                context.tr('assistant_title'),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: context.tr('assistant_restart'),
            onPressed: _restart,
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_criticalSigns)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: ElevatedButton.icon(
                  onPressed: _callEmergency,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dangerRed,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  icon: const Icon(Icons.call_rounded),
                  label: Text(
                    context.trArgs('assistant_call_now', {
                      'number': emergencyNumber,
                    }),
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.all(16),
                // Item 0 (the oldest, at the top) holds the two notices, so
                // they scroll away with the chat instead of permanently
                // taking space from it on small screens.
                itemCount: 1 + _messages.length + (showSummary ? 1 : 0),
                itemBuilder: (context, index) {
                  final total = 1 + _messages.length + (showSummary ? 1 : 0);
                  final logicalIndex = total - 1 - index;
                  if (logicalIndex == 0) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          DisclaimerBanner(
                            textKey: 'assistant_disclaimer',
                            icon: Icons.smart_toy_outlined,
                          ),
                          SizedBox(height: 8),
                          DisclaimerBanner(
                            textKey: 'assistant_urgent_notice',
                            icon: Icons.warning_amber_rounded,
                          ),
                        ],
                      ),
                    );
                  }
                  if (logicalIndex - 1 < _messages.length) {
                    return _ChatBubble(message: _messages[logicalIndex - 1]);
                  }
                  return _SummaryCard(
                    type: _type!,
                    injured: injuredLabel(_injured),
                    conscious: _conscious,
                    locationAttached: _locationAttached,
                    urgencyKey: _urgencyKey,
                    note: [
                      _typeFreeText,
                      if (_note != _typeFreeText) _note,
                    ].where((t) => t.isNotEmpty).join(' · '),
                    creating: _creating,
                    onCreate: _createIncidentFromSummary,
                    onRestart: _restart,
                  );
                },
              ),
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            if (_stage != _Stage.summary) ...[
              if (_currentQuickOptions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 132),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _currentQuickOptions.map((option) {
                          final type = _stage == _Stage.type
                              ? _typeFromButton(option)
                              : null;
                          return ActionChip(
                            avatar: type != null
                                ? Icon(
                                    incidentTypeIcon(type),
                                    size: 16,
                                    color: AppColors.primaryBlue,
                                  )
                                : null,
                            label: Text(option),
                            backgroundColor: AppColors.primaryBlue.withValues(
                              alpha: 0.1,
                            ),
                            side: BorderSide(
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.2,
                              ),
                            ),
                            labelStyle: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                            onPressed: _busy
                                ? null
                                : () => _handleInput(option),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 36),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        enabled: !_busy,
                        textInputAction: TextInputAction.send,
                        decoration: InputDecoration(
                          hintText: context.tr('assistant_type_hint'),
                        ),
                        onSubmitted: _handleInput,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      tooltip: context.tr('assistant_send'),
                      onPressed: _busy
                          ? null
                          : () => _handleInput(_textController.text),
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ] else
              const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isAssistant = message.sender == ChatSender.assistant;
    final bubble = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      decoration: BoxDecoration(
        color: isAssistant ? AppColors.surface : AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(16),
        border: isAssistant ? Border.all(color: AppColors.border) : null,
      ),
      child: Text(
        message.text,
        style: TextStyle(
          height: 1.35,
          color: isAssistant ? AppColors.textPrimary : Colors.white,
        ),
      ),
    );

    if (!isAssistant) {
      return Align(alignment: AlignmentDirectional.centerEnd, child: bubble);
    }

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2, bottom: 10),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(child: bubble),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IncidentType type;
  final String injured;
  final bool? conscious;
  final bool locationAttached;
  final String urgencyKey;
  final String note;
  final bool creating;
  final VoidCallback onCreate;
  final VoidCallback onRestart;

  const _SummaryCard({
    required this.type,
    required this.injured,
    required this.conscious,
    required this.locationAttached,
    required this.urgencyKey,
    required this.note,
    required this.creating,
    required this.onCreate,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final high = urgencyKey == 'assistant_urgency_high';

    Widget row(String label, String value, {Color? valueColor}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );

    return Card(
      margin: const EdgeInsets.only(top: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('assistant_summary_title'),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const Divider(height: 20),
            row(
              context.tr('assistant_summary_type'),
              context.tr(incidentTypeKey(type)),
            ),
            row(context.tr('assistant_summary_injured'), injured),
            row(
              context.tr('assistant_summary_status'),
              conscious == false
                  ? context.tr('assistant_conscious_no')
                  : context.tr('assistant_conscious_yes'),
            ),
            row(
              context.tr('assistant_summary_location'),
              locationAttached
                  ? context.tr('assistant_location_attached')
                  : context.tr('assistant_location_missing'),
            ),
            row(
              context.tr('assistant_summary_urgency'),
              context.tr(urgencyKey),
              valueColor: high ? AppColors.dangerRed : AppColors.warning,
            ),
            row(
              context.tr('assistant_summary_note'),
              note.isEmpty ? context.tr('none') : note,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: creating ? null : onCreate,
              child: creating
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(context.tr('assistant_create_incident')),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: onRestart,
              child: Text(context.tr('assistant_restart')),
            ),
          ],
        ),
      ),
    );
  }
}
