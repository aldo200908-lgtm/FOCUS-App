import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show LicenseRegistry, LicenseEntryWithLineBreaks;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/app_state.dart';
import 'core/repository.dart';
import 'ui/design.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Inter',
    ], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: ink,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const Bootstrap());
}

class Bootstrap extends StatefulWidget {
  const Bootstrap({super.key});
  @override
  State<Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<Bootstrap> {
  AppState? state;
  Object? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => error = null);
    try {
      final preferences = await SharedPreferences.getInstance();
      final loaded = await AppState.load(LocalRepository(preferences));
      if (!mounted) {
        loaded.dispose();
        return;
      }
      setState(() => state = loaded);
    } catch (e) {
      if (mounted) setState(() => error = e);
    }
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (state != null) return FocusApp(state: state!);
    return MaterialApp(
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      debugShowCheckedModeBanner: false,
      theme: focusTheme(),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: error == null
                ? const CircularProgressIndicator(color: accent)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        color: accent,
                        size: 40,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Tus datos se conservan.',
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'No hemos podido abrir el almacenamiento local. Vuelve a intentarlo; no borres los datos de la aplicación.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: muted, height: 1.6),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: load,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
