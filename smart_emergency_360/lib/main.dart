import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'app_dependencies.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Loads intl's date-symbol data for every supported locale up front, so
  // DateFormat(pattern, 'ar') never throws right after switching language.
  await initializeDateFormatting();

  // Last-resort safety net: if a widget's build() throws (a bug we missed),
  // show a small neutral card instead of Flutter's red error screen. Kept
  // independent of the app's Provider/translation system on purpose.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const Material(
      color: Color(0xFFF6FAFF),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFE53935),
                size: 40,
              ),
              SizedBox(height: 12),
              Text(
                'Something went wrong. / حدث خطأ ما.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  };

  // Accounts (Supabase Auth). A failure here must never stop the app from
  // opening: SOS and guest mode work without it.
  try {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabasePublishableKey,
      // Implicit flow so email links (confirm account, reset password) also
      // work when opened on a different device or browser than the one that
      // requested them.
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
      ),
    );
  } catch (e) {
    debugPrint('[startup] Supabase init failed: $e');
  }

  final dependencies = await AppDependencies.load();
  runApp(RescueOneApp(dependencies: dependencies));
}
