import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSummaryStrip(),
                    const SizedBox(height: 20),
                    _buildSectionLabel('OVERDUE', AppColors.critical),
                    const SizedBox(height: 10),
                    _MaintenanceItem(
                      icon: Icons.oil_barrel_outlined,
                      title: 'Engine Oil Change',
                      status: 'Overdue by 12 days',
                      interval: 'Every 90 days  •  Last done: 3 Jan 2026',
                      urgencyColor: AppColors.critical,
                      urgencyBg: AppColors.criticalBg,
                      urgencyBorder: AppColors.criticalBorder,
                      showMarkDone: true,
                    ),
                    const SizedBox(height: 20),
                    _buildSectionLabel('DUE SOON', AppColors.moderate),
                    const SizedBox(height: 10),
                    _MaintenanceItem(
                      icon: Icons.tire_repair_outlined,
                      title: 'Tyre Pressure Check',
                      status: 'Due in 5 days',
                      interval: 'Every 30 days  •  Last done: 14 Mar 2026',
                      urgencyColor: AppColors.moderate,
                      urgencyBg: AppColors.moderateBg,
                      urgencyBorder: AppColors.moderateBorder,
                      showMarkDone: true,
                    ),
                    const SizedBox(height: 10),
                    _MaintenanceItem(
                      icon: Icons.air_outlined,
                      title: 'Air Filter Inspection',
                      status: 'Due in 18 days',
                      interval: 'Every 6 months  •  Last done: 11 Oct 2025',
                      urgencyColor: AppColors.moderate,
                      urgencyBg: AppColors.moderateBg,
                      urgencyBorder: AppColors.moderateBorder,
                      showMarkDone: true,
                    ),
                    const SizedBox(height: 20),
                    _buildSectionLabel('UP TO DATE', AppColors.advisory),
                    const SizedBox(height: 10),
                    _MaintenanceItem(
                      icon: Icons.water_drop_outlined,
                      title: 'Brake Fluid Top-Up',
                      status: 'Done  •  Next in 48 days',
                      interval: 'Every 6 months  •  Done: 28 Mar 2026',
                      urgencyColor: AppColors.advisory,
                      urgencyBg: AppColors.advisoryBg,
                      urgencyBorder: AppColors.advisoryBorder,
                      showMarkDone: false,
                    ),
                    const SizedBox(height: 10),
                    _MaintenanceItem(
                      icon: Icons.electric_bolt_outlined,
                      title: 'Spark Plug Check',
                      status: 'Done  •  Next in 65 days',
                      interval: 'Every 2 years  •  Done: 11 Mar 2026',
                      urgencyColor: AppColors.advisory,
                      urgencyBg: AppColors.advisoryBg,
                      urgencyBorder: AppColors.advisoryBorder,
                      showMarkDone: false,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Maintenance',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary, fontFamily: 'Inter')),
                Text('Toyota Corolla 2016  •  Keep your car healthy',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary,
                        fontFamily: 'Inter')),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('+ Add',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: Colors.white, fontFamily: 'Inter')),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _SummaryItem(value: '1', label: 'OVERDUE',
              color: AppColors.critical),
          Container(width: 1, height: 36, color: AppColors.borderSubtle),
          _SummaryItem(value: '2', label: 'DUE SOON',
              color: AppColors.moderate),
          Container(width: 1, height: 36, color: AppColors.borderSubtle),
          _SummaryItem(value: '4', label: 'UP TO DATE',
              color: AppColors.advisory),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color color) {
    return Text(label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
            color: color, letterSpacing: 1.5, fontFamily: 'Inter'));
  }
}

class _SummaryItem extends StatelessWidget {
  final String value, label;
  final Color color;
  const _SummaryItem({required this.value, required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                  color: color, fontFamily: 'Inter')),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
                  color: color, letterSpacing: 1, fontFamily: 'Inter')),
        ],
      ),
    );
  }
}

class _MaintenanceItem extends StatelessWidget {
  final IconData icon;
  final String title, status, interval;
  final Color urgencyColor, urgencyBg, urgencyBorder;
  final bool showMarkDone;

  const _MaintenanceItem({
    required this.icon, required this.title, required this.status,
    required this.interval, required this.urgencyColor,
    required this.urgencyBg, required this.urgencyBorder,
    required this.showMarkDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: urgencyBorder),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 3,
              decoration: BoxDecoration(
                  color: urgencyColor,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 12),
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  color: urgencyBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: urgencyColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary, fontFamily: 'Inter')),
                  const SizedBox(height: 3),
                  Text(status,
                      style: TextStyle(fontSize: 12, color: urgencyColor,
                          fontFamily: 'Inter')),
                  const SizedBox(height: 3),
                  Text(interval,
                      style: const TextStyle(fontSize: 11,
                          color: AppColors.textTertiary, fontFamily: 'Inter')),
                ],
              ),
            ),
            if (showMarkDone)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: urgencyBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: urgencyBorder),
                  ),
                  child: Text('Mark done',
                      style: TextStyle(fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: urgencyColor, fontFamily: 'Inter')),
                ),
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: urgencyBg, shape: BoxShape.circle,
                    border: Border.all(color: urgencyBorder),
                  ),
                  child: Icon(Icons.check_rounded,
                      color: urgencyColor, size: 15),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
