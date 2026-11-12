import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/language/app_language.dart';
import '../../core/services/launcher_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/disclaimer_banner.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/responsive_section.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(context.tr('help_title'))),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ResponsiveSection(
              vertical: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const DisclaimerBanner(textKey: 'help_prototype_notice'),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryBlue, AppColors.brightBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.support_agent_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('help_hero_title'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('help_hero_subtitle'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _SupportAction(
                          icon: Icons.call_rounded,
                          label: context.tr('help_call_support'),
                          onTap: () => LauncherService().callNumber(
                            AppConfig.supportPhone,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SupportAction(
                          icon: Icons.forum_rounded,
                          label: context.tr('help_chat_support'),
                          onTap: () async {
                            final ok = await LauncherService().openWhatsApp(
                              AppConfig.supportPhone,
                              message: context.trRead('help_whatsapp_greeting'),
                            );
                            if (!ok && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context.trRead(
                                      'help_chat_prototype_message',
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SupportAction(
                          icon: Icons.mail_outline_rounded,
                          label: context.tr('help_email_support'),
                          onTap: () => LauncherService().openEmail(
                            AppConfig.supportEmail,
                            subject: context.trRead('app_name'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.tr('help_faq_title'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FaqTile(
                    question: context.tr('help_faq_q1'),
                    answer: context.tr('help_faq_a1'),
                  ),
                  const SizedBox(height: 8),
                  for (final n in [2, 3, 4, 5]) ...[
                    _FaqTile(
                      question: context.tr('help_faq_q$n'),
                      answer: context.tr('help_faq_a$n'),
                    ),
                    if (n != 5) const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 20),
                  GradientButton(
                    label: context.tr('help_center_button'),
                    icon: Icons.mail_rounded,
                    onPressed: () => LauncherService().openEmail(
                      AppConfig.supportEmail,
                      subject: context.trRead('app_name'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SupportAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryBlue.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              answer,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
