﻿import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteNotificationSettings extends StatefulWidget {
  const FavoriteNotificationSettings({super.key});

  @override
  State<FavoriteNotificationSettings> createState() =>
      _FavoriteNotificationSettingsState();
}

class _FavoriteNotificationSettingsState
    extends State<FavoriteNotificationSettings> {
  bool _remindersEnabled = true;
  bool _isLoading = true;

  final Map<int, bool> _reminderMinutesSettings = {
    15: true,
    30: false,
    60: false,
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _remindersEnabled = prefs.getBool('reminders_enabled') ?? true;
      _reminderMinutesSettings[15] =
          prefs.getBool('reminder_15_min_enabled') ?? true;
      _reminderMinutesSettings[30] =
          prefs.getBool('reminder_30_min_enabled') ?? false;
      _reminderMinutesSettings[60] =
          prefs.getBool('reminder_60_min_enabled') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _updateRemindersEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminders_enabled', value);
    setState(() {
      _remindersEnabled = value;
    });
  }

  Future<void> _updateReminderMinutes(int minutes, bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_${minutes}_min_enabled', isEnabled);
    setState(() {
      _reminderMinutesSettings[minutes] = isEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(height: 50);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('お気に入り企画のリマインダー'),
          subtitle: const Text('企画の開始時刻が近づくと通知します'),
          value: _remindersEnabled,
          onChanged: _updateRemindersEnabled,
        ),

        if (_remindersEnabled)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 8, bottom: 4),
                  child: Text(
                    'リマインダー通知のタイミング（複数選択可）',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                CheckboxListTile(
                  title: const Text('15分前'),
                  value: _reminderMinutesSettings[15],
                  onChanged: (bool? value) {
                    if (value != null) _updateReminderMinutes(15, value);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  title: const Text('30分前'),
                  value: _reminderMinutesSettings[30],
                  onChanged: (bool? value) {
                    if (value != null) _updateReminderMinutes(30, value);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  title: const Text('1時間前'),
                  value: _reminderMinutesSettings[60],
                  onChanged: (bool? value) {
                    if (value != null) _updateReminderMinutes(60, value);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
