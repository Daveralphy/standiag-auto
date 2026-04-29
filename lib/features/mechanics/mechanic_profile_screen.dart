import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_header.dart';
import '../booking/book_mechanic_screen.dart';

class MechanicProfileScreen extends StatelessWidget {
  final Map<String, dynamic> mechanic;
  const MechanicProfileScreen(
      {super.key, required this.mechanic});

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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _buildBio(),
                          const SizedBox(height: 20),
                          _buildSpecialisations(),
                          const SizedBox(height: 20),
                          _buildContactRow(context),
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
    return AppSecondaryHeader(
      title: 'Mechanic Profile',
      onBack: () => Navigator.of(context).pop(),
      action: const Icon(Icons.bookmark_border_rounded,
          color: AppColors.textSecondary, size: 22),
    );
  }

  Widget _buildHero() {
    final name = mechanic['name'] ?? '';
    final initials = mechanic['initials'] ?? '';
    final location = mechanic['location'] ?? '';
    final address = mechanic['address'] ?? '';
    final rating =
        (mechanic['rating'] as num?)?.toDouble() ?? 0.0;
    final reviewCount = mechanic['review_count'] ?? 0;
    final isFeatured = mechanic['is_featured'] == true;
    final isOnline = mechanic['is_online'] == true;
    final avatarColor = Color(
        int.parse('FF${mechanic['avatar_color'] ?? 'C0272D'}',
            radix: 16));

    // Build star icons
    final fullStars = rating.floor();
    final hasHalf = (rating - fullStars) >= 0.5;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: avatarColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.primaryBorder, width: 2),
                  boxShadow: [BoxShadow(
                      color: AppColors.primary
                          .withValues(alpha: 0.25),
                      blurRadius: 20)],
                ),
                child: Center(
                  child: Text(initials,
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'Inter')),
                ),
              ),
              if (isOnline)
                Positioned(
                  bottom: 2, right: 2,
                  child: Container(
                    width: 18, height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.advisory,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.background,
                          width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (isFeatured)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                    color: AppColors.primaryBorder),
              ),
              child: const Text('★ FEATURED MECHANIC',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                      fontFamily: 'Inter')),
            ),
          const SizedBox(height: 12),
          Text(name,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter')),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined,
                  color: AppColors.textTertiary, size: 14),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  address.isNotEmpty ? address : location,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(fullStars, (_) => const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFF5A623), size: 16)),
              if (hasHalf)
                const Icon(Icons.star_half_rounded,
                    color: Color(0xFFF5A623), size: 16),
              ...List.generate(
                  5 - fullStars - (hasHalf ? 1 : 0),
                  (_) => const Icon(
                      Icons.star_outline_rounded,
                      color: Color(0xFFF5A623), size: 16)),
              const SizedBox(width: 6),
              Text('$rating',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'Inter')),
              Text('  ($reviewCount reviews)',
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final experience =
        mechanic['experience_years'] ?? 0;
    final jobsDone = mechanic['jobs_done'] ?? 0;
    final responseSpeed =
        mechanic['response_speed'] ?? 'Normal';

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
          _StatItem(
              label: 'EXPERIENCE',
              value: '$experience yrs'),
          _VertDivider(),
          _StatItem(
              label: 'JOBS DONE',
              value: '$jobsDone+'),
          _VertDivider(),
          _StatItem(
              label: 'RESPONSE',
              value: responseSpeed,
              valueColor: AppColors.advisory),
        ],
      ),
    );
  }

  Widget _buildBio() {
    final bio = mechanic['bio'] as String?;
    if (bio == null || bio.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ABOUT',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                letterSpacing: 1.5,
                fontFamily: 'Inter')),
        const SizedBox(height: 10),
        Text(bio,
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.6,
                fontFamily: 'Inter')),
      ],
    );
  }

  Widget _buildSpecialisations() {
    final specs =
        List<String>.from(mechanic['specialisations'] ?? []);
    if (specs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SPECIALISATIONS',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                letterSpacing: 1.5,
                fontFamily: 'Inter')),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: specs.map((s) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                      color: AppColors.primaryBorder),
                ),
                child: Text(s,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontFamily: 'Inter')),
              )).toList(),
        ),
      ],
    );
  }

  Widget _buildContactRow(BuildContext context) {
    final phone =
        mechanic['phone_number'] as String? ?? '';
    final whatsapp =
        mechanic['whatsapp_number'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CONTACT',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                letterSpacing: 1.5,
                fontFamily: 'Inter')),
        const SizedBox(height: 10),
        Row(children: [
          if (phone.isNotEmpty)
            Expanded(
              child: _ContactBtn(
                icon: Icons.phone_outlined,
                label: 'Call',
                color: AppColors.advisory,
                bg: AppColors.advisoryBg,
                border: AppColors.advisoryBorder,
                onTap: () {},
              ),
            ),
          if (phone.isNotEmpty && whatsapp.isNotEmpty)
            const SizedBox(width: 10),
          if (whatsapp.isNotEmpty)
            Expanded(
              child: _ContactBtn(
                icon: Icons.chat_outlined,
                label: 'WhatsApp',
                color: AppColors.whatsApp,
                bg: AppColors.whatsApp
                    .withValues(alpha: 0.1),
                border: AppColors.whatsApp
                    .withValues(alpha: 0.3),
                onTap: () {},
              ),
            ),
        ]),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                BookMechanicScreen(mechanic: mechanic),
          ),
        ),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(
                color: AppColors.primary
                    .withValues(alpha: 0.40),
                blurRadius: 20,
                offset: const Offset(0, 8))],
          ),
          child: const Center(
            child: Text('Book this Mechanic',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Inter')),
          ),
        ),
      ),
    );
  }
}

// ── SUPPORTING WIDGETS ────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _StatItem(
      {required this.label,
      required this.value,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                  letterSpacing: 1,
                  fontFamily: 'Inter')),
          const SizedBox(height: 4),
          Text(value,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: valueColor ?? AppColors.textPrimary,
                  fontFamily: 'Inter')),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 36, color: AppColors.borderSubtle);
  }
}

class _ContactBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, bg, border;
  final VoidCallback onTap;

  const _ContactBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontFamily: 'Inter')),
          ],
        ),
      ),
    );
  }
}

