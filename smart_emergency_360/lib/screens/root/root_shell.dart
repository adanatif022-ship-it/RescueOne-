import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/language/app_language.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_back_button.dart';
import '../assistant/ai_assistant_screen.dart';
import '../history/incident_history_screen.dart';
import '../home/home_screen.dart';
import '../hospitals/hospital_list_screen.dart';
import '../sos/emergency_type_screen.dart';

/// Bottom-navigation shell holding the 4 persistent tabs plus a central,
/// visually-prominent SOS action. An IndexedStack keeps each tab's scroll
/// position and state alive when switching between them; SOS is not a
/// tab (there's nothing to "stay" on) - it's a normal pushed route, kept
/// out of the notched bar's tab index so it can never be "selected".
class RootShell extends StatefulWidget {
  const RootShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  late int _index = widget.initialIndex;

  /// Tabs are built the first time they're opened (then kept alive), so
  /// e.g. the Hospitals tab doesn't ask for location before it's needed.
  late final Set<int> _visited = {widget.initialIndex};

  void _select(int index) => setState(() {
    _index = index;
    _visited.add(index);
  });

  static const _screens = [
    HomeScreen(),
    HospitalListScreen(),
    AiAssistantScreen(),
    IncidentHistoryScreen(),
  ];

  void _openSos() {
    HapticFeedback.heavyImpact();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const EmergencyTypeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    // Android back button: from another tab go back to Home first,
    // instead of closing the app.
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _index != 0) _select(0);
      },
      child: Scaffold(
        // Tabs get a back arrow that returns to Home (see AppBackButton).
        body: RootTabsScope(
          index: _index,
          goHome: () => _select(0),
          child: IndexedStack(
            index: _index,
            children: [
              for (var i = 0; i < _screens.length; i++)
                _visited.contains(i) ? _screens[i] : const SizedBox.shrink(),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _CentralSosButton(onTap: _openSos),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          color: AppColors.surface,
          elevation: 8,
          padding: EdgeInsets.zero,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 72,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: context.tr('nav_home'),
                    selected: _index == 0,
                    onTap: () => _select(0),
                  ),
                  _NavItem(
                    icon: Icons.local_hospital_rounded,
                    label: context.tr('nav_hospitals'),
                    selected: _index == 1,
                    onTap: () => _select(1),
                  ),
                  const SizedBox(width: 64), // room for the notch/FAB
                  _NavItem(
                    icon: Icons.smart_toy_rounded,
                    label: context.tr('nav_assistant'),
                    selected: _index == 2,
                    onTap: () => _select(2),
                  ),
                  _NavItem(
                    icon: Icons.history_rounded,
                    label: context.tr('nav_history'),
                    selected: _index == 3,
                    onTap: () => _select(3),
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

class _CentralSosButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CentralSosButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: FloatingActionButton(
        onPressed: onTap,
        backgroundColor: AppColors.dangerRed,
        elevation: 4,
        shape: const CircleBorder(),
        tooltip: context.tr('home_sos_button'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emergency_rounded, color: Colors.white, size: 22),
            Text(
              context.tr('nav_sos'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                height: 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryBlue : AppColors.textSecondary;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pill behind the selected icon - selection isn't shown by
              // color alone.
              AnimatedContainer(
                duration: AppTheme.medium,
                curve: Curves.easeOut,
                width: 56,
                height: 30,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryBlue.withValues(
                          alpha: AppColors.isDark ? 0.24 : 0.14,
                        )
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 23),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.25,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
