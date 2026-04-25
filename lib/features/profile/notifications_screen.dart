import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _appointmentReminders = true;
  bool _medicationReminders = true;
  bool _sosAlerts = true;
  bool _promotionalNotifications = false;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Notification Preferences
          const Text(
            'Notification Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              children: [
                _NotificationToggle(
                  icon: Icons.calendar_today_rounded,
                  title: 'Appointment Reminders',
                  subtitle: 'Get notified about upcoming appointments',
                  value: _appointmentReminders,
                  onChanged: (value) {
                    setState(() => _appointmentReminders = value);
                  },
                ),
                const Divider(height: 1, indent: 68),
                _NotificationToggle(
                  icon: Icons.medication_rounded,
                  title: 'Medication Reminders',
                  subtitle: 'Reminders to take your medications',
                  value: _medicationReminders,
                  onChanged: (value) {
                    setState(() => _medicationReminders = value);
                  },
                ),
                const Divider(height: 1, indent: 68),
                _NotificationToggle(
                  icon: Icons.emergency_rounded,
                  title: 'SOS Alerts',
                  subtitle: 'Critical emergency notifications',
                  value: _sosAlerts,
                  onChanged: (value) {
                    setState(() => _sosAlerts = value);
                  },
                  isImportant: true,
                ),
                const Divider(height: 1, indent: 68),
                _NotificationToggle(
                  icon: Icons.local_offer_rounded,
                  title: 'Promotional Notifications',
                  subtitle: 'Offers and health tips',
                  value: _promotionalNotifications,
                  onChanged: (value) {
                    setState(() => _promotionalNotifications = value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notification Channels
          const Text(
            'Notification Channels',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              children: [
                _NotificationToggle(
                  icon: Icons.notifications_active_rounded,
                  title: 'Push Notifications',
                  subtitle: 'Receive notifications on this device',
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() => _pushNotifications = value);
                  },
                ),
                const Divider(height: 1, indent: 68),
                _NotificationToggle(
                  icon: Icons.email_rounded,
                  title: 'Email Notifications',
                  subtitle: 'Receive notifications via email',
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() => _emailNotifications = value);
                  },
                ),
                const Divider(height: 1, indent: 68),
                _NotificationToggle(
                  icon: Icons.sms_rounded,
                  title: 'SMS Notifications',
                  subtitle: 'Receive notifications via SMS',
                  value: _smsNotifications,
                  onChanged: (value) {
                    setState(() => _smsNotifications = value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent Notifications
          const Text(
            'Recent Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          _NotificationCard(
            icon: Icons.calendar_today_rounded,
            iconColor: AppTheme.primaryColor,
            title: 'Appointment Reminder',
            message: 'You have an appointment with Dr. Rajesh Kumar tomorrow at 10:00 AM',
            time: DateTime.now().subtract(const Duration(hours: 2)),
            isUnread: true,
          ),
          const SizedBox(height: 10),

          _NotificationCard(
            icon: Icons.medication_rounded,
            iconColor: AppTheme.successColor,
            title: 'Medication Reminder',
            message: 'Time to take your evening medication',
            time: DateTime.now().subtract(const Duration(hours: 5)),
            isUnread: true,
          ),
          const SizedBox(height: 10),

          _NotificationCard(
            icon: Icons.check_circle_rounded,
            iconColor: AppTheme.successColor,
            title: 'Appointment Confirmed',
            message: 'Your appointment with Dr. Priya Sharma has been confirmed',
            time: DateTime.now().subtract(const Duration(days: 1)),
            isUnread: false,
          ),
          const SizedBox(height: 10),

          _NotificationCard(
            icon: Icons.local_offer_rounded,
            iconColor: AppTheme.warningColor,
            title: 'Health Tip',
            message: 'Stay hydrated! Drink at least 8 glasses of water daily',
            time: DateTime.now().subtract(const Duration(days: 2)),
            isUnread: false,
          ),
          const SizedBox(height: 10),

          _NotificationCard(
            icon: Icons.update_rounded,
            iconColor: AppTheme.primaryColor,
            title: 'App Update Available',
            message: 'A new version of JeevanPath is available. Update now for new features!',
            time: DateTime.now().subtract(const Duration(days: 3)),
            isUnread: false,
          ),
        ],
      ),
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isImportant;

  const _NotificationToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isImportant = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: (isImportant ? AppTheme.errorColor : AppTheme.primaryColor)
              .withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isImportant ? AppTheme.errorColor : AppTheme.primaryColor,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 13,
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: isImportant ? AppTheme.errorColor : AppTheme.primaryColor,
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final DateTime time;
  final bool isUnread;

  const _NotificationCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.time,
    required this.isUnread,
  });

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread 
            ? AppTheme.primaryColor.withOpacity(0.05) 
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isUnread 
            ? Border.all(color: AppTheme.primaryColor.withOpacity(0.2))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatTime(time),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
