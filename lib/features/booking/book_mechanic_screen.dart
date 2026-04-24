import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'booking_confirmed_screen.dart';

class BookMechanicScreen extends StatefulWidget {
  final Map<String, dynamic> mechanic;
  const BookMechanicScreen({super.key, required this.mechanic});

  @override
  State<BookMechanicScreen> createState() => _BookMechanicScreenState();
}

class _BookMechanicScreenState extends State<BookMechanicScreen> {
  int _selectedDay = 14;
  String _selectedTime = '8:00 AM';

  final List<String> _timeSlots = [
    '8:00 AM', '10:00 AM', '12:00 PM', '2:00 PM', '4:00 PM', '6:00 PM'
  ];
  final List<String> _bookedSlots = ['2:00 PM'];

  // April 2026 starts on Wednesday (index 3 in Sun=0 week)
  final int _startDayOfWeek = 3;
  final int _daysInMonth = 30;

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
                    _buildMechanicCard(),
                    const SizedBox(height: 20),
                    _buildCalendar(),
                    const SizedBox(height: 20),
                    _buildTimeSlots(),
                    const SizedBox(height: 20),
                    _buildJobDescription(),
                    const SizedBox(height: 20),
                    _buildVehicleFaultRow(),
                    const SizedBox(height: 24),
                    _buildConfirmButton(context),
                    const SizedBox(height: 24),
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
          const Text('Book a Mechanic',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, fontFamily: 'Inter')),
        ],
      ),
    );
  }

  Widget _buildMechanicCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.vehicleCard, shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryBorder),
            ),
            child: const Center(
              child: Text('AO',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                      color: AppColors.primary, fontFamily: 'Inter')),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ade Okonkwo Auto',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary, fontFamily: 'Inter')),
                const SizedBox(height: 3),
                Wrap(
                  spacing: 5,
                  children: ['Toyota', 'Honda', 'Electrical', '0.8 km']
                      .map((s) => Text(s,
                          style: const TextStyle(fontSize: 11,
                              color: AppColors.textSecondary,
                              fontFamily: 'Inter')))
                      .toList(),
                ),
                const SizedBox(height: 3),
                Row(
                  children: const [
                    Icon(Icons.star_rounded, color: AppColors.gold, size: 12),
                    Icon(Icons.star_rounded, color: AppColors.gold, size: 12),
                    Icon(Icons.star_rounded, color: AppColors.gold, size: 12),
                    Icon(Icons.star_rounded, color: AppColors.gold, size: 12),
                    Icon(Icons.star_rounded, color: AppColors.gold, size: 12),
                    SizedBox(width: 4),
                    Text('4.9',
                        style: TextStyle(fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary, fontFamily: 'Inter')),
                    SizedBox(width: 6),
                    Icon(Icons.location_on_outlined,
                        color: AppColors.textTertiary, size: 11),
                    Text(' Lagos Island',
                        style: TextStyle(fontSize: 11,
                            color: AppColors.textTertiary, fontFamily: 'Inter')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SELECT DATE',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: AppColors.textTertiary, letterSpacing: 1.5,
                fontFamily: 'Inter')),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              // Month nav
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(Icons.chevron_left_rounded,
                        color: AppColors.textSecondary, size: 24),
                  ),
                  const Text('April 2026',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary, fontFamily: 'Inter')),
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textSecondary, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Day headers
              Row(
                children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                    .map((d) => Expanded(
                          child: Center(
                            child: Text(d,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textTertiary,
                                    fontFamily: 'Inter')),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 10),
              // Date grid
              _buildDateGrid(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateGrid() {
    final cells = <Widget>[];
    // Leading empty cells
    for (int i = 0; i < _startDayOfWeek; i++) {
      cells.add(const SizedBox());
    }
    // Day cells
    for (int d = 1; d <= _daysInMonth; d++) {
      final isSelected = d == _selectedDay;
      final isToday = d == 11;
      final isPast = d < 11;
      cells.add(
        GestureDetector(
          onTap: isPast ? null : () => setState(() => _selectedDay = d),
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$d',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected || isToday
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: isSelected
                      ? Colors.white
                      : isPast
                          ? AppColors.textDisabled
                          : isToday
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.0,
      children: cells,
    );
  }

  Widget _buildTimeSlots() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SELECT TIME SLOT',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: AppColors.textTertiary, letterSpacing: 1.5,
                fontFamily: 'Inter')),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _timeSlots.map((slot) {
            final isBooked = _bookedSlots.contains(slot);
            final isSelected = _selectedTime == slot && !isBooked;
            return GestureDetector(
              onTap: isBooked ? null : () => setState(() => _selectedTime = slot),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : isBooked
                          ? AppColors.surfaceDeep
                          : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : isBooked
                            ? AppColors.borderSubtle
                            : AppColors.border,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(slot,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : isBooked
                                    ? AppColors.textDisabled
                                    : AppColors.textSecondary,
                            fontFamily: 'Inter')),
                    if (isBooked) ...[
                      const SizedBox(height: 2),
                      const Text('Booked',
                          style: TextStyle(fontSize: 9,
                              color: AppColors.textDisabled,
                              fontFamily: 'Inter')),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildJobDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DESCRIBE THE JOB',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: AppColors.textTertiary, letterSpacing: 1.5,
                fontFamily: 'Inter')),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'P0301 cylinder 1 misfire. Spark plug or ignition coil replacement needed.',
                style: TextStyle(fontSize: 14, color: AppColors.textPrimary,
                    height: 1.5, fontFamily: 'Inter'),
              ),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Text('Auto-filled from your last scan  •  ',
                      style: TextStyle(fontSize: 11, color: AppColors.textTertiary,
                          fontFamily: 'Inter')),
                  Text('Edit',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                          color: AppColors.primary, fontFamily: 'Inter')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleFaultRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Vehicle:',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary,
                      fontFamily: 'Inter')),
              SizedBox(height: 4),
              Text('Fault codes:',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary,
                      fontFamily: 'Inter')),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Toyota Corolla 2016',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary, fontFamily: 'Inter')),
              SizedBox(height: 4),
              Text('P0301  ·  P0420  ·  P0171',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: AppColors.primary, fontFamily: 'Inter')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BookingConfirmedScreen())),
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
          child: Text('CONFIRM BOOKING',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                  color: Colors.white, letterSpacing: 0.8, fontFamily: 'Inter')),
        ),
      ),
    );
  }
}




