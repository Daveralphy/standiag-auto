import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class RateMechanicScreen extends StatefulWidget {
  const RateMechanicScreen({super.key});

  @override
  State<RateMechanicScreen> createState() => _RateMechanicScreenState();
}

class _RateMechanicScreenState extends State<RateMechanicScreen> {
  int _rating = 4;
  final Set<String> _selectedTags = {'Quick fix', 'Honest pricing'};
  final _reviewController = TextEditingController(
      text:
          'He diagnosed the fault correctly from the StanDiag report without any extra checks and fixed in under 2 hours. Highly recommended!');

  final List<String> _tags = [
    'Quick fix', 'Honest pricing', 'Good communicator',
    'Clean workspace', 'Professional'
  ];

  @override
  void dispose() { _reviewController.dispose(); super.dispose(); }

  String get _ratingLabel {
    switch (_rating) {
      case 1: return 'Poor · 1 / 5';
      case 2: return 'Fair · 2 / 5';
      case 3: return 'Good · 3 / 5';
      case 4: return 'Very Good · 4 / 5';
      case 5: return 'Excellent · 5 / 5';
      default: return '';
    }
  }

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
                  children: [
                    const SizedBox(height: 24),
                    _buildMechanicInfo(),
                    const SizedBox(height: 24),
                    _buildRating(),
                    const SizedBox(height: 24),
                    _buildTags(),
                    const SizedBox(height: 24),
                    _buildWrittenReview(),
                    const SizedBox(height: 28),
                    _buildSubmitButton(context),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Text('Skip for now',
                          style: TextStyle(fontSize: 13,
                              color: AppColors.textDisabled, fontFamily: 'Inter')),
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
          const Text('Rate Your Experience',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, fontFamily: 'Inter')),
        ],
      ),
    );
  }

  Widget _buildMechanicInfo() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.vehicleCard, shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryBorder, width: 2),
                boxShadow: [BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.20), blurRadius: 16)],
              ),
              child: const Center(
                child: Text('AO',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                        color: AppColors.primary, fontFamily: 'Inter')),
              ),
            ),
            Positioned(
              bottom: 2, right: 2,
              child: Container(
                width: 16, height: 16,
                decoration: BoxDecoration(
                  color: AppColors.advisory, shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Ade Okonkwo Auto',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary, fontFamily: 'Inter')),
        const SizedBox(height: 4),
        const Text('Cylinder 1 misfire repair  •  14 Apr 2026',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary,
                fontFamily: 'Inter')),
        const Text('Toyota Corolla 2016  •  Lagos Island',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary,
                fontFamily: 'Inter')),
        const SizedBox(height: 16),
        const Text('How was the service?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary, fontFamily: 'Inter')),
        const SizedBox(height: 4),
        const Text('Your review helps other StanDiag users.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary,
                fontFamily: 'Inter')),
      ],
    );
  }

  Widget _buildRating() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final filled = i < _rating;
            return GestureDetector(
              onTap: () => setState(() => _rating = i + 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: filled ? AppColors.gold : AppColors.textDisabled,
                  size: 40,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(_ratingLabel,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: AppColors.gold, fontFamily: 'Inter')),
      ],
    );
  }

  Widget _buildTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('WHAT WENT WELL?',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: AppColors.textTertiary, letterSpacing: 1.5,
                fontFamily: 'Inter')),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _tags.map((tag) {
            final selected = _selectedTags.contains(tag);
            return GestureDetector(
              onTap: () => setState(() => selected
                  ? _selectedTags.remove(tag)
                  : _selectedTags.add(tag)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primarySubtle : AppColors.surface,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(tag,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected ? AppColors.primary : AppColors.textSecondary,
                        fontFamily: 'Inter')),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWrittenReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('WRITTEN REVIEW (OPTIONAL)',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: AppColors.textTertiary, letterSpacing: 1.5,
                fontFamily: 'Inter')),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              TextField(
                controller: _reviewController,
                maxLines: 4,
                maxLength: 300,
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary,
                    height: 1.5, fontFamily: 'Inter'),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                  counterStyle: TextStyle(fontSize: 11,
                      color: AppColors.textTertiary, fontFamily: 'Inter'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
      child: Container(
        width: double.infinity, height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.40),
              blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: const Center(
          child: Text('SUBMIT REVIEW',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                  color: Colors.white, letterSpacing: 0.8, fontFamily: 'Inter')),
        ),
      ),
    );
  }
}

