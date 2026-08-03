import 'package:flutter/material.dart';

import '../features/dashboard/dashboard_page.dart';
import '../shared/services/settings_service.dart';
import 'theme.dart';

class GymTrackApp extends StatefulWidget {
  const GymTrackApp({super.key});

  @override
  State<GymTrackApp> createState() => _GymTrackAppState();
}

class _GymTrackAppState extends State<GymTrackApp> {
  final _settings = SettingsService();
  late final VoidCallback _onSettingsChanged;

  @override
  void initState() {
    super.initState();
    _onSettingsChanged = () => setState(() {});
    _settings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'GymTrack',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: _settings.themeMode,
    builder: (context, child) => Stack(
      fit: StackFit.expand,
      children: [
        // Plano de fundo global definido para a identidade visual do app.
        const Image(
          image: AssetImage('assets/images/planodefundo1.png'),
          fit: BoxFit.cover,
        ),
        const ColoredBox(color: Color(0x990B0F19)),
        child ?? const SizedBox.shrink(),
      ],
    ),
    home: const DashboardPage(),
  );
}
