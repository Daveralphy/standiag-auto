import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../booking/book_mechanic_screen.dart';

class MechanicProfileScreen extends StatelessWidget {
  const MechanicProfileScreen({super.key});

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
                child: Column(
                  children: [
                    _buildHero(),
                    _buildStatsRow(),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSpecialisations(),
                          const SizedBox(height: 20),
                          _buildReviews(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
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
          const Text('Mechanic Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, fontFamily: 'Inter')),
          const Spacer(),
          Icon(Icons.bookmark_border_rounded,
              color: AppColors.textSecondary, size: 22),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppColors.vehicleCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryBorder, width: 2),
                  boxShadow: [BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 20)],
                ),
                child: const Center(
                  child: Text('AO',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                          color: AppColors.primary, fontFamily: 'Inter')),
                ),
              ),
              Positioned(
                bottom: 2, right: 2,
                child: Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.advisory,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.primaryBorder),
            ),
            child: const Text('★ FEATURED MECHANIC',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                    color: AppColors.primary, letterSpacing: 0.5,
                    fontFamily: 'Inter')),
          ),
          const SizedBox(height: 12),
          const Text('Ade Okonkwo Auto',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary, fontFamily: 'Inter')),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.location_on_outlined,
                  color: AppColors.textTertiary, size: 14),
              SizedBox(width: 3),
              Text('Lagos Island, Lagos  •  0.8 km away',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary,
                      fontFamily: 'Inter')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.star_rounded, color: AppColors.gold, size: 16),
              Icon(Icons.star_rounded, color: AppColors.gold, size: 16),
              Icon(Icons.star_rounded, color: AppColors.gold, size: 16),
              Icon(Icons.star_rounded, color: AppColors.gold, size: 16),
              Icon(Icons.star_rounded, color: AppColors.gold, size: 16),
              SizedBox(width: 6),
              Text('4.9',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary, fontFamily: 'Inter')),
              Text('  (128 reviews)',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary,
                      fontFamily: 'Inter')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _StatItem(label: 'EXPERIENCE', value: '14 yrs'),
          _VertDivider(),
          _StatItem(label: 'JOBS DONE', value: '340+'),
          _VertDivider(),
          _StatItem(label: 'RESPONSE', value: 'Fast',
              valueColor: AppColors.advisory),
        ],
      ),
    );
  }

  Widget _buildSpecialisations() {
    final specs = ['Toyota', 'Honda', 'Electrical', 'AC Repair', '+3'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SPECIALISATIONS',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: AppColors.textTertiary, letterSpacing: 1.5,
                fontFamily: 'Inter')),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: specs.map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.primaryBorder),
            ),
            child: Text(s,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: AppColors.primary, fontFamily: 'Inter')),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('RECENT REVIEWS',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: AppColors.textTertiary, letterSpacing: 1.5,
                fontFamily: 'Inter')),
        const SizedBox(height: 10),
        _ReviewCard(
          initials: 'JA',
          name: 'James Adeyemi',
          stars: 5,
          date: '3 days ago',
          review:
              'Fixed my Toyota Corolla misfire in under 2 hours. Diagnosed it correctly straight away. Very professional.',
        ),
        const SizedBox(height: 10),
        _ReviewCard(
          initials: 'FO',
          name: 'Fatima Okafor',
          stars: 5,
          date: '1 week ago',
          review:
              'Honest pricing. He told me what was actually wrong without adding unnecessary jobs.',
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.navBg,
        border: Border(top: BorderSide(color: AppColors.borderSubtle, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.whatsApp.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.whatsApp.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.chat_outlined, color: AppColors.whatsApp, size: 18),
                    SizedBox(width: 8),
                    Text('WhatsApp',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                            color: AppColors.whatsApp, fontFamily: 'Inter')),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BookMechanicScreen())),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(
                      color: AppColors.primary.withOpacity(0.38),
                      blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.phone_outlined, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Call Mechanic',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                            color: Colors.white, fontFamily: 'Inter')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final Color valueColor;
  const _StatItem({required this.label, required this.value,
      this.valueColor = AppColors.textPrimary});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary, letterSpacing: 0.8,
                  fontFamily: 'Inter')),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                  color: valueColor, fontFamily: 'Inter')),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: AppColors.borderSubtle);
}

class _ReviewCard extends StatelessWidget {
  final String initials, name, review, date;
  final int stars;
  const _ReviewCard({required this.initials, required this.name,
      required this.review, required this.date, required this.stars});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.bluetooth.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(initials,
                      style: const TextStyle(fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.bluetooth, fontFamily: 'Inter')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary, fontFamily: 'Inter')),
                    Row(
                      children: [
                        ...List.generate(stars, (_) => const Icon(
                            Icons.star_rounded, color: AppColors.gold, size: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Text(date,
                  style: const TextStyle(fontSize: 11,
                      color: AppColors.textTertiary, fontFamily: 'Inter')),
            ],
          ),
          const SizedBox(height: 10),
          Text(review,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary,
                  height: 1.5, fontFamily: 'Inter')),
        ],
      ),
    );
  }
}
