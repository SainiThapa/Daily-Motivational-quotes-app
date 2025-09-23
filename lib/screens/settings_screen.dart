import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<SettingsController>(
        builder: (context, settingsController, child) {
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildSettingsSection(
                context,
                title: 'Preferences',
                children: [
                  _buildSwitchTile(
                    context,
                    title: 'Dark Mode',
                    subtitle: 'Enable dark theme',
                    icon: Icons.dark_mode,
                    value: settingsController.isDarkMode,
                    onChanged: (value) => settingsController.toggleDarkMode(),
                  ),
                  _buildSwitchTile(
                    context,
                    title: 'Notifications',
                    subtitle: 'Get daily quote notifications',
                    icon: Icons.notifications,
                    value: settingsController.notificationsEnabled,
                    onChanged: (value) => settingsController.toggleNotifications(),
                  ),
                ],
              ),
              SizedBox(height: 24),
              _buildSettingsSection(
                context,
                title: 'About',
                children: [
                  _buildActionTile(
                    context,
                    title: 'Rate Us',
                    subtitle: 'Rate our app on the store',
                    icon: Icons.star_rate,
                    onTap: () => _rateApp(context),
                  ),
                  _buildActionTile(
                    context,
                    title: 'Privacy Policy',
                    subtitle: 'Read our privacy policy',
                    icon: Icons.privacy_tip,
                    onTap: () => _openPrivacyPolicy(context),
                  ),
                  _buildActionTile(
                    context,
                    title: 'App Version',
                    subtitle: '1.0.0',
                    icon: Icons.info,
                    onTap: null,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          elevation: 2,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      secondary: Icon(icon),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      leading: Icon(icon),
      trailing: onTap != null ? Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  void _rateApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thank you for your interest! Rating feature coming soon.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openPrivacyPolicy(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Privacy policy will be displayed here.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

