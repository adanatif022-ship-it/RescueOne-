import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/language/app_language.dart';
import '../../core/services/incident_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/rating_stars.dart';
import '../../core/widgets/responsive_section.dart';
import '../root/root_shell.dart';
import 'emergency_type_screen.dart';

/// Final step of the SOS flow: assistance confirmed, an optional "I need
/// more help" path, and a 1-5 star rating with a comment that is saved on
/// the incident (shown later in its details).
class AssistanceCompletedScreen extends StatefulWidget {
  final String? incidentId;
  const AssistanceCompletedScreen({super.key, this.incidentId});

  @override
  State<AssistanceCompletedScreen> createState() =>
      _AssistanceCompletedScreenState();
}

class _AssistanceCompletedScreenState extends State<AssistanceCompletedScreen> {
  final _feedbackController = TextEditingController();
  int _rating = 0;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final id = widget.incidentId;
    final incident = id == null
        ? null
        : context.read<IncidentRepository>().byId(id);
    if (incident?.rating != null) {
      _rating = incident!.rating!;
      _feedbackController.text = incident.feedback ?? '';
      _saved = true;
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _returnHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RootShell()),
      (route) => false,
    );
  }

  void _needMoreHelp() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RootShell()),
      (route) => false,
    );
    // Opens SOS on top of Home, so "back" from it lands on Home.
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const EmergencyTypeScreen()));
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.trRead('completed_rating_required'))),
      );
      return;
    }
    final id = widget.incidentId;
    if (id != null) {
      await context.read<IncidentRepository>().rateIncident(
        id,
        _rating,
        _feedbackController.text,
      );
    }
    if (!mounted) return;
    setState(() => _saved = true);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.trRead('completed_thanks_feedback'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // System back also returns to Home.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _returnHome();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(leading: AppBackButton(onPressed: _returnHome)),
        body: SafeArea(
          child: SingleChildScrollView(
            child: ResponsiveSection(
              vertical: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 56,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.tr('completed_title'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('completed_message'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.tr('completed_need_more_help'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Stacked full-width buttons: side by side, the
                          // Arabic label wrapped onto two lines.
                          ElevatedButton.icon(
                            onPressed: _needMoreHelp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.dangerRed,
                              minimumSize: const Size.fromHeight(50),
                            ),
                            icon: const Icon(Icons.emergency_rounded),
                            label: Text(context.tr('completed_need_more')),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: _returnHome,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                            ),
                            child: Text(context.tr('completed_no_thanks')),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          Text(
                            context.tr('completed_rate_service'),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RatingStars(
                            value: _rating,
                            onChanged: (v) => setState(() {
                              _rating = v;
                              _saved = false;
                            }),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _feedbackController,
                            maxLines: 2,
                            onChanged: (_) {
                              if (_saved) setState(() => _saved = false);
                            },
                            decoration: InputDecoration(
                              hintText: context.tr('completed_feedback_hint'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _saved ? null : _submitFeedback,
                              icon: Icon(
                                _saved
                                    ? Icons.check_rounded
                                    : Icons.save_rounded,
                              ),
                              label: Text(context.tr('save')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _returnHome,
                    child: Text(context.tr('completed_return_home')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
