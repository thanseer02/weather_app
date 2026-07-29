import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/settings_entity.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                children: [
                  _buildSectionHeader('Appearance'),
                  _buildAnimatedSection(
                    index: 0,
                    child: GlassCard(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          _buildDropdownTile<ThemeModeType>(
                            title: 'Theme',
                            icon: Icons.palette,
                            value: settings.themeMode,
                            items: ThemeModeType.values,
                            onChanged: (val) {
                              if (val != null) notifier.updateSettings(settings.copyWith(themeMode: val));
                            },
                            displayString: (val) => val.name.toUpperCase(),
                          ),
                          _buildDropdownTile<AnimationQuality>(
                            title: 'Animation Quality',
                            icon: Icons.animation,
                            value: settings.animationQuality,
                            items: AnimationQuality.values,
                            onChanged: (val) {
                              if (val != null) notifier.updateSettings(settings.copyWith(animationQuality: val));
                            },
                            displayString: (val) => val.name.toUpperCase(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  _buildSectionHeader('Units'),
                  _buildAnimatedSection(
                    index: 1,
                    child: GlassCard(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          _buildDropdownTile<TemperatureUnit>(
                            title: 'Temperature Unit',
                            icon: Icons.thermostat,
                            value: settings.temperatureUnit,
                            items: TemperatureUnit.values,
                            onChanged: (val) {
                              if (val != null) notifier.updateSettings(settings.copyWith(temperatureUnit: val));
                            },
                            displayString: (val) => val.name.toUpperCase(),
                          ),
                          _buildDropdownTile<WindUnit>(
                            title: 'Wind Speed Unit',
                            icon: Icons.air,
                            value: settings.windUnit,
                            items: WindUnit.values,
                            onChanged: (val) {
                              if (val != null) notifier.updateSettings(settings.copyWith(windUnit: val));
                            },
                            displayString: (val) => val.name.toUpperCase(),
                          ),
                          _buildDropdownTile<PressureUnit>(
                            title: 'Pressure Unit',
                            icon: Icons.speed,
                            value: settings.pressureUnit,
                            items: PressureUnit.values,
                            onChanged: (val) {
                              if (val != null) notifier.updateSettings(settings.copyWith(pressureUnit: val));
                            },
                            displayString: (val) => val.name.toUpperCase(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  _buildSectionHeader('App Settings'),
                  _buildAnimatedSection(
                    index: 2,
                    child: GlassCard(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Push Notifications', style: TextStyle(color: Colors.white)),
                            secondary: const Icon(Icons.notifications, color: Colors.white70),
                            activeColor: Colors.blueAccent,
                            value: settings.notificationsEnabled,
                            onChanged: (val) {
                              notifier.updateSettings(settings.copyWith(notificationsEnabled: val));
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.language, color: Colors.white70),
                            title: const Text('Language', style: TextStyle(color: Colors.white)),
                            trailing: const Text('EN', style: TextStyle(color: Colors.white54)),
                            onTap: () {
                              // Future: Language Picker
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.cleaning_services, color: Colors.white70),
                            title: const Text('Clear Cache', style: TextStyle(color: Colors.white)),
                            onTap: () async {
                              await notifier.clearCache();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Cache cleared successfully!')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  _buildSectionHeader('Information'),
                  _buildAnimatedSection(
                    index: 3,
                    child: GlassCard(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.info_outline, color: Colors.white70),
                            title: const Text('About', style: TextStyle(color: Colors.white)),
                            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                            onTap: () {
                              // Future: About Screen
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.privacy_tip_outlined, color: Colors.white70),
                            title: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
                            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                            onTap: () {
                              // Future: Privacy Policy
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDropdownTile<T>({
    required String title,
    required IconData icon,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) displayString,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: DropdownButton<T>(
        value: value,
        dropdownColor: const Color(0xFF1E293B),
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        onChanged: onChanged,
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(displayString(item)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAnimatedSection({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 150)),
      curve: Curves.easeOutBack,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, childWidget) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }
}
