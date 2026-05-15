import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';
import '../../core/models/booking_model.dart';
import '../../core/models/subscription_model.dart';
import '../../core/services/home_service.dart';
import '../../core/widgets/app_toast.dart';

class MechanicHomeScreen extends StatefulWidget {
  const MechanicHomeScreen({super.key});

  @override
  State<MechanicHomeScreen> createState() => _MechanicHomeScreenState();
}

class _MechanicHomeScreenState extends State<MechanicHomeScreen> {
  final _service = HomeService();
  final _supabase = Supabase.instance.client;

  String _firstName = '';
  SubscriptionModel? _subscription;
  List<BookingModel> _pendingBookings = [];
  BookingModel? _activeJob;
  Map<String, dynamic> _stats = {};
  int _unreadCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final uid = _supabase.auth.currentUser!.id;
      final profile = await _supabase
          .from('profiles').select('first_name').eq('id', uid).single();
      final sub = await _service.getActiveSubscription();
      final pending = await _service.getMechanicBookings(status: 'pending');
      final accepted = await _service.getMechanicBookings(status: 'accepted');
      final stats = await _service.getMechanicStats();
      final notifs = await _supabase
          .from('notifications').select('id')
          .eq('user_id', uid).eq('is_read', false);

      if (!mounted) return;
      setState(() {
        _firstName = profile['first_name'] as String? ?? '';
        _subscription = sub;
        _pendingBookings = pending;
        _activeJob = accepted.isNotEmpty ? accepted.first : null;
        _stats = stats;
        _unreadCount = notifs.length;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      AppToast.error(context, 'Failed to load home data.');
    }
  }

  Future<void> _acceptBooking(String id) async {
    try {
      await _service.acceptBooking(id);
      if (!mounted) return;
      AppToast.success(context, 'Booking accepted.');
      _loadData();
    } catch (_) {
      if (!mounted) return;
      AppToast.error(context, 'Failed to accept booking.');
    }
  }

  Future<void> _declineBooking(String id) async {
    try {
      await _service.declineBooking(id);
      if (!mounted) return;
      AppToast.success(context, 'Booking declined.');
      _loadData();
    } catch (_) {
      if (!mounted) return;
      AppToast.error(context, 'Failed to decline booking.');
    }
  }

  Future<void> _completeJob(String id) async {
    try {
      await _service.completeBooking(id);
      if (!mounted) return;
      AppToast.success(context, 'Job marked as complete.');
      _loadData();
    } catch (_) {
      if (!mounted) return;
      AppToast.error(context, 'Failed to complete job.');
    }
  }

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inDays > 0) return '${d.inDays}d ago';
    if (d.inHours > 0) return '${d.inHours}h ago';
    if (d.inMinutes > 0) return '${d.inMinutes}m ago';
    return 'Just now';
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  Widget _sectionTitle(String t) => Text(t,
      style: AppTypography.caption.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      _buildOnlineBanner(),
                      _buildPlanCard(),
                      _buildStatsRow(),
                      if (_activeJob != null) _buildActiveJob(),
                      _buildPendingBookings(),
                      _buildRating(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_greeting(), style: AppTypography.caption
              .copyWith(color: AppColors.textTertiary)),
          Text('$_firstName ðŸ”§',
              style: AppTypography.h2.copyWith(letterSpacing: -0.5)),
        ]),
        const Spacer(),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface, borderRadius: AppRadius.mdAll,
              border: Border.all(color: AppColors.border)),
            child: Stack(children: [
              const Center(child: Icon(Icons.notifications_outlined,
                  color: AppColors.textSecondary, size: 22)),
              if (_unreadCount > 0)
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.background, width: 1.5)),
                  ),
                ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildOnlineBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.08),
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.success.withValues(alpha: 0.2))),
        child: Row(children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
              color: AppColors.success, shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.3),
                  blurRadius: 6, spreadRadius: 2)]),
          ),
          const SizedBox(width: 10),
          Text('You are visible to nearby users',
              style: AppTypography.body.copyWith(
                  color: AppColors.success, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text('Active now', style: AppTypography.caption
              .copyWith(color: AppColors.success.withValues(alpha: 0.5))),
        ]),
      ),
    );
  }

  Widget _buildPlanCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Your Plan'),
        const SizedBox(height: 10),
        _subscription == null ? _noSubscription() : _subscriptionContent(),
      ]),
    );
  }

  Widget _noSubscription() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surface, borderRadius: AppRadius.lgAll,
      border: Border.all(color: AppColors.border)),
    child: Column(children: [
      const Icon(Icons.lock_outline_rounded,
          color: AppColors.textTertiary, size: 36),
      const SizedBox(height: 8),
      Text('No active subscription',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
      const SizedBox(height: 4),
      Text('Subscribe to become visible to users',
          style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
          textAlign: TextAlign.center),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: AppRadius.mdAll),
          child: Text('View Plans',
              style: AppTypography.button.copyWith(fontSize: 14)),
        ),
      ),
    ]),
  );

  Widget _subscriptionContent() {
    final sub = _subscription!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF0D0D14), Color(0xFF130810)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.primaryBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary, borderRadius: AppRadius.smAll),
            child: Text('${sub.planName} â€” ${sub.planAmount}',
                style: AppTypography.caption.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w800)),
          ),
          const Spacer(),
          Text('Expires ${sub.expiresAt.day}/${sub.expiresAt.month}',
              style: AppTypography.caption
                  .copyWith(color: AppColors.textTertiary)),
        ]),
        if (!sub.isUnlimited) ...[
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Bookings accepted this month',
                style: AppTypography.bodySm
                    .copyWith(color: AppColors.textSecondary)),
            Text('${sub.slotsUsed} / ${sub.slotsLimit}',
                style: AppTypography.bodySm
                    .copyWith(fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: AppRadius.fullAll,
            child: LinearProgressIndicator(
              value: sub.usagePercent.clamp(0.0, 1.0),
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 6),
          ),
        ],
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: AppColors.primaryBorder)),
            child: Center(child: Text('âš¡ Upgrade Plan',
                style: AppTypography.body.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700))),
          ),
        ),
      ]),
    );
  }

  Widget _buildStatsRow() {
    final views = _stats['profile_views'] as int? ?? 0;
    final jobs = _stats['jobs_this_month'] as int? ?? 0;
    final rating = (_stats['rating'] as num?)?.toDouble() ?? 0.0;
    final reviews = _stats['review_count'] as int? ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(children: [
        _StatCard(label: 'Profile Views', value: views.toString(),
            change: 'total', changeColor: AppColors.success),
        const SizedBox(width: 10),
        _StatCard(label: 'Jobs Done', value: jobs.toString(),
            change: 'this month', changeColor: AppColors.success),
        const SizedBox(width: 10),
        _StatCard(label: 'Rating', value: rating.toStringAsFixed(1),
            change: '$reviews reviews', changeColor: AppColors.warning),
      ]),
    );
  }

  Widget _buildActiveJob() {
    final job = _activeJob!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Active Job'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.06),
            borderRadius: AppRadius.lgAll,
            border: Border.all(
                color: AppColors.success.withValues(alpha: 0.18))),
          child: Column(children: [
            Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface, borderRadius: AppRadius.smAll,
                  border: Border.all(color: AppColors.border)),
                child: const Icon(Icons.person_outline_rounded,
                    color: AppColors.textTertiary, size: 20)),
              const SizedBox(width: 10),
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(job.userName ?? 'Customer',
                    style: AppTypography.body
                        .copyWith(fontWeight: FontWeight.w700)),
                Text(job.vehicleSummary ?? 'Vehicle',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textTertiary)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: AppRadius.smAll),
                child: Text('Active', style: AppTypography.caption.copyWith(
                    color: AppColors.success, fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _completeJob(job.id),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppColors.success,
                    AppColors.success.withValues(alpha: 0.8)]),
                  borderRadius: AppRadius.mdAll),
                child: Center(child: Text('Mark as Complete',
                    style: AppTypography.button.copyWith(fontSize: 14))),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildPendingBookings() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Pending Bookings'),
        const SizedBox(height: 10),
        if (_pendingBookings.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface, borderRadius: AppRadius.lgAll,
              border: Border.all(color: AppColors.border)),
            child: Center(child: Text('No pending bookings',
                style: AppTypography.body
                    .copyWith(color: AppColors.textTertiary))),
          )
        else
          ...(_pendingBookings.map((b) => _BookingCard(
                booking: b, timeAgo: _timeAgo(b.createdAt),
                onAccept: () => _acceptBooking(b.id),
                onDecline: () => _declineBooking(b.id)))),
      ]),
    );
  }

  Widget _buildRating() {
    final rating = (_stats['rating'] as num?)?.toDouble() ?? 0.0;
    final count = _stats['review_count'] as int? ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Your Rating'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard, borderRadius: AppRadius.lgAll,
            border: Border.all(color: AppColors.border)),
          child: Row(children: [
            Text(rating.toStringAsFixed(1),
                style: AppTypography.h1.copyWith(fontSize: 44, letterSpacing: -1)),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: List.generate(5, (i) => Icon(
                  i < rating.round()
                      ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: AppColors.warning, size: 18))),
              const SizedBox(height: 4),
              Text('Based on $count reviews',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textTertiary)),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String change;
  final Color changeColor;
  const _StatCard({
    required this.label, required this.value,
    required this.change, required this.changeColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard, borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTypography.caption
              .copyWith(color: AppColors.textTertiary),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.h2.copyWith(letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(change, style: AppTypography.caption
              .copyWith(color: changeColor, fontWeight: FontWeight.w600),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final String timeAgo;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  const _BookingCard({
    required this.booking, required this.timeAgo,
    required this.onAccept, required this.onDecline});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard, borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface, borderRadius: AppRadius.smAll,
              border: Border.all(color: AppColors.border)),
            child: const Icon(Icons.person_outline_rounded,
                color: AppColors.textTertiary, size: 20)),
          const SizedBox(width: 10),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(booking.userName ?? 'Customer',
                style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
            Text(booking.vehicleSummary ?? 'Vehicle',
                style: AppTypography.caption
                    .copyWith(color: AppColors.textTertiary)),
          ])),
          Text(timeAgo, style: AppTypography.caption
              .copyWith(color: AppColors.textTertiary)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: onAccept,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.success, borderRadius: AppRadius.mdAll),
                child: Center(child: Text('Accept',
                    style: AppTypography.button.copyWith(fontSize: 14))),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: onDecline,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.surface, borderRadius: AppRadius.mdAll,
                  border: Border.all(color: AppColors.border)),
                child: Center(child: Text('Decline',
                    style: AppTypography.button.copyWith(
                        fontSize: 14,
                        color: AppColors.textSecondary))),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}
