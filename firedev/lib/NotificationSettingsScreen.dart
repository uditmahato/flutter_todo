import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  @override
  _NotificationSettingsScreenState createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _generalNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _smsNotificationsEnabled = false;
  bool _doNotDisturbEnabled = false;

  // This can be called when you want to update these preferences in your backend or local storage.
  void _updatePreferences() {
    print("General Notifications: $_generalNotificationsEnabled");
    print("Email Notifications: $_emailNotificationsEnabled");
    print("SMS Notifications: $_smsNotificationsEnabled");
    print("Do Not Disturb: $_doNotDisturbEnabled");
    // Implement the logic to update these settings, e.g., save to shared preferences, local database, or update in your backend.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notification Settings"),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SwitchListTile(
              title: Text("General Notifications"),
              subtitle: Text("Turn on/off general app notifications."),
              value: _generalNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _generalNotificationsEnabled = value;
                });
                _updatePreferences();
              },
            ),
            SwitchListTile(
              title: Text("Email Notifications"),
              subtitle: Text("Receive notifications via email."),
              value: _emailNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _emailNotificationsEnabled = value;
                });
                _updatePreferences();
              },
            ),
            SwitchListTile(
              title: Text("SMS Notifications"),
              subtitle: Text("Receive notifications via SMS."),
              value: _smsNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _smsNotificationsEnabled = value;
                });
                _updatePreferences();
              },
            ),
            SwitchListTile(
              title: Text("Do Not Disturb"),
              subtitle: Text("Mute all notifications."),
              value: _doNotDisturbEnabled,
              onChanged: (value) {
                setState(() {
                  _doNotDisturbEnabled = value;
                  // If Do Not Disturb is turned on, we'll turn off other notifications.
                  if (value) {
                    _generalNotificationsEnabled = false;
                    _emailNotificationsEnabled = false;
                    _smsNotificationsEnabled = false;
                  }
                });
                _updatePreferences();
              },
            ),
          ],
        ),
      ),
    );
  }
}
