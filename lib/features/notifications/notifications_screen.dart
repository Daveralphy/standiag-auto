import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  _GroupLabel(label: 'TODAY'),
                  const SizedBox(height: 10),
                  _NotifRow(
                    icon: Icons.oil_barrel_outlined,
                    iconColor: AppColors.critical,
                    iconBg: AppColors.criticalBg,
                    title: 'Oil Change Overdue',
                    body: 'Your Corolla 2016 is overdue by 12 days.',
                    meta: 'Maintenance  •  Just now',
                    isUnread: true,
                    cardBg: AppColors.errorBg,
                    borderColor: AppColors.criticalBorder,
                    dotColor: AppColors.critical,
                  ),
                  const SizedBox(height: 8),
                  _NotifRow(
                    icon: Icons.wifi_tethering_rounded,
                    iconColor: AppColors.moderate,
                    iconBg: AppColors.moderateBg,
                    title: 'Weekly Scan Reminder',
                    body: "You haven't scanned your Civic 2019 in 6 days.",
                    meta: 'Scan reminder  •  2 hours ago',
                    isUnread: true,
                    cardBg: const Color(0xFF100A08),
                    borderColor: AppColors.moderateBorder,
                    dotColor: AppColors.moderate,
                  ),
                  const SizedBox(height: 20),
                  _GroupLabel(label: 'YESTERDAY'),
                  const SizedBox(height: 10),
                  _NotifRow(
                    icon: Icons.chat_outlined,
                    iconColor: AppColors.whatsApp,
                    iconBg: AppColors.whatsApp.withOpacity(0.12),
                    title: 'Ade Mech replied on WhatsApp',
                    body: "Bring the car in tomorrow morning, I'll sort it.",
                    meta: 'Mechanic reply  •  10 Apr, 15:20',
                    isUnread: false,
                    cardBg: AppColors.surface,
                    borderColor: AppColors.border,
                    dotColor: Colors.transparent,
                  ),
                  const SizedBox(height: 8),
                  _NotifRow(
                    icon: Icons.tire_repair_outlined,
                    iconColor: AppColors.moderate,
                    iconBg: AppColors.moderateBg,
                    title: 'Tyre Pressure Due Soon',
                    body: 'Corolla 2016 tyre check due in 5 days.',
                    meta: 'Maintenance  •  10 Apr, 08:00',
                    isUnread: false,
                    cardBg: AppColors.surface,
                    borderColor: AppColors.border,
                    dotColor: Colors.transparent,
                  ),
                  const SizedBox(height: 20),
                  _GroupLabel(label: 'EARLIER'),
                  const SizedBox(height: 10),
                  _NotifRow(
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: AppColors.advisory,
                    iconBg: AppColors.advisoryBg,
                    title: 'Scan Complete — No Faults',
                    body: 'Civic 2019 scan returned all clear.',
                    meta: 'Scan  •  5 Apr, 14:22',
                    isUnread: false,
                    cardBg: AppColors.surface,
                    borderColor: AppColors.border,
                    dotColor: Colors.transparent,
                  ),
                  const SizedBox(height: 8),
                  Opacity(
                    opacity: 0.5,
                    child: _NotifRow(
                      icon: Icons.person_outline_rounded,
                      iconColor: AppColors.primary,
                      iconBg: AppColors.primarySubtle,
                      title: 'Welcome to StanDiag Auto!',
                      body: 'Connect your adapter and run your first scan.',
                      meta: 'Account  •  11 Apr, 09:00',
                      isUnread: false,
                      cardBg: AppColors.surface,
                      borderColor: AppColors.border,
                      dotColor: Colors.transparent,
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary, fontFamily: 'Inter')),
          ),
          const Text('Mark all read',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                  color: AppColors.primary, fontFamily: 'Inter')),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String label;
  const _GroupLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
            color: AppColors.textTertiary, letterSpacing: 1.5,
            fontFamily: 'Inter'));
  }
}

class _NotifRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg, cardBg, borderColor, dotColor;
  final String title, body, meta;
  final bool isUnread;

  const _NotifRow({
    required this.icon, required this.iconColor, required this.iconBg,
    required this.title, required this.body, required this.meta,
    required this.isUnread, required this.cardBg, required this.borderColor,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isUnread)
            Padding(
              padding: const EdgeInsets.only(top: 5, right: 8),
              child: Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                    color: dotColor, shape: BoxShape.circle),
              ),
            )
          else
            const SizedBox(width: 15),
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary, fontFamily: 'Inter')),
                const SizedBox(height: 3),
                Text(body,
                    style: TextStyle(
                        fontSize: 12,
                        color: isUnread
                            ? AppColors.textSecondary
                            : AppColors.textTertiary,
                        fontFamily: 'Inter')),
                const SizedBox(height: 4),
                Text(meta,
                    style: const TextStyle(fontSize: 10,
                        color: AppColors.textTertiary, fontFamily: 'Inter')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
