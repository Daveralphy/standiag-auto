import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';

class MechanicOrdersScreen extends StatefulWidget {
  const MechanicOrdersScreen({super.key});
  @override
  State<MechanicOrdersScreen> createState() => _MechanicOrdersScreenState();
}

class _MechanicOrdersScreenState extends State<MechanicOrdersScreen> with SingleTickerProviderStateMixin {
  bool _isOnline = false;
  bool _loadingToggle = false;
  Map<String, dynamic>? _mechProfile;
  List<Map<String, dynamic>> _activeJobs = [];
  List<Map<String, dynamic>> _pastJobs = [];
  bool _loading = true;
  late AnimationController _pulseController;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.97, end: 1.03).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _loadData();
  }

  Future<void> _loadData() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final profile = await supabase.from('mechanic_profiles').select().eq('id', userId).maybeSingle();
      final jobs = await supabase.from('job_sessions').select().eq('mechanic_id', userId).order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _mechProfile = profile;
          _isOnline = profile?['is_online'] ?? false;
          final allJobs = List<Map<String, dynamic>>.from(jobs);
          _activeJobs = allJobs.where((j) => !['completed', 'rated', 'payment_confirmed'].contains(j['status'])).toList();
          _pastJobs = allJobs.where((j) => ['completed', 'rated', 'payment_confirmed'].contains(j['status'])).toList();
          _loading = false;
        });
      }
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _toggleOnline() async {
    setState(() => _loadingToggle = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final newState = !_isOnline;
      await Supabase.instance.client.from('mechanic_profiles').update({'is_online': newState}).eq('id', userId);
      setState(() => _isOnline = newState);
    } catch (_) {} finally { if (mounted) setState(() => _loadingToggle = false); }
  }

  @override
  void dispose() { _pulseController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 16),
                  Row(children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Orders', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Inter')),
                      Text(_isOnline ? 'Visible to customers' : 'You are offline',
                          style: TextStyle(fontSize: 13, color: _isOnline ? AppColors.advisory : AppColors.textTertiary, fontFamily: 'Inter')),
                    ]),
                    const Spacer(),
                    Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: _isOnline ? AppColors.advisory : AppColors.textTertiary,
                        boxShadow: _isOnline ? [BoxShadow(color: AppColors.advisory.withValues(alpha: 0.5), blurRadius: 8)] : null)),
                  ]),
                  const SizedBox(height: 16),
                  _buildBalanceCard(),
                  const SizedBox(height: 14),
                  _buildOnlineToggle(),
                  const SizedBox(height: 24),
                  if (_activeJobs.isNotEmpty) ...[
                    _label('ACTIVE JOBS'), const SizedBox(height: 10),
                    ..._activeJobs.map((j) => _JobCard(job: j, isActive: true)),
                    const SizedBox(height: 20),
                  ],
                  _label('RECENT JOBS'), const SizedBox(height: 10),
                  if (_pastJobs.isEmpty)
                    _empty()
                  else
                    ..._pastJobs.take(10).map((j) => _JobCard(job: j, isActive: false)),
                  const SizedBox(height: 32),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    final balance = (_mechProfile?['available_balance'] as num?)?.toDouble() ?? 0.0;
    final total = (_mechProfile?['total_earnings'] as num?)?.toDouble() ?? 0.0;
    final jobs = (_mechProfile?['jobs_done'] as num?)?.toInt() ?? 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1A0608), Color(0xFF0F0304)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBorder),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('AVAILABLE BALANCE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 1.5, fontFamily: 'Inter')),
        const SizedBox(height: 8),
        Text('₦${balance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontFamily: 'Inter', letterSpacing: -0.5)),
        const SizedBox(height: 12),
        Row(children: [
          _pill('Total Earned', '₦${total.toStringAsFixed(0)}', AppColors.advisory),
          const SizedBox(width: 8),
          _pill('Jobs Done', '$jobs', AppColors.moderate),
        ]),
      ]),
    );
  }

  Widget _buildOnlineToggle() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _loadingToggle ? null : _toggleOnline,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, child) => Transform.scale(scale: _isOnline ? _pulse.value : 1.0, child: child),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isOnline ? AppColors.advisoryBg : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _isOnline ? AppColors.advisoryBorder : AppColors.border),
          ),
          child: Row(children: [
            Container(width: 44, height: 44,
              decoration: BoxDecoration(color: _isOnline ? AppColors.advisory.withValues(alpha: 0.15) : AppColors.surfaceDeep, borderRadius: BorderRadius.circular(12)),
              child: Icon(_isOnline ? Icons.wifi_tethering_rounded : Icons.wifi_tethering_off_rounded,
                  color: _isOnline ? AppColors.advisory : AppColors.textTertiary, size: 22)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_isOnline ? 'You are Online' : 'You are Offline',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _isOnline ? AppColors.advisory : AppColors.textPrimary, fontFamily: 'Inter')),
              Text(_isOnline ? 'Customers can see and request you' : 'Tap to go online and receive requests',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Inter')),
            ])),
            _loadingToggle
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
              : Switch(value: _isOnline, onChanged: (_) => _toggleOnline(),
                  activeColor: AppColors.advisory, activeTrackColor: AppColors.advisory.withValues(alpha: 0.3),
                  inactiveThumbColor: AppColors.textTertiary, inactiveTrackColor: AppColors.border),
          ]),
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 1.5, fontFamily: 'Inter'));

  Widget _empty() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
    child: const Center(child: Text('No jobs yet. Go online to receive requests.',
        textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5, fontFamily: 'Inter'))),
  );

  Widget _pill(String label, String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600, letterSpacing: 0.5, fontFamily: 'Inter')),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Inter')),
    ]),
  );
}

class _JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final bool isActive;
  const _JobCard({required this.job, required this.isActive});

  Color _statusColor(String s) {
    if (['active', 'mechanic_arrived', 'job_in_progress'].contains(s)) return AppColors.moderate;
    if (['completed', 'rated', 'payment_confirmed'].contains(s)) return AppColors.advisory;
    return AppColors.textSecondary;
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'active': return 'En route to customer';
      case 'mechanic_arrived': return 'Arrived at location';
      case 'job_in_progress': return 'Job in progress';
      case 'job_done': return 'Done — awaiting confirmation';
      case 'user_confirmed': return 'Confirmed — awaiting payment';
      case 'payment_sent': return 'Payment sent';
      case 'payment_confirmed': return 'Payment received';
      case 'completed': return 'Completed';
      case 'rated': return 'Completed & rated';
      default: return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = job['status'] ?? 'active';
    final amount = (job['agreed_amount'] as num?)?.toDouble() ?? 0.0;
    final color = _statusColor(status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isActive ? AppColors.primaryBorder : AppColors.border)),
      child: Row(children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(isActive ? Icons.build_circle_outlined : Icons.check_circle_outline_rounded, color: color, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Job #${job['id'].toString().substring(0, 8)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Inter')),
          Text(_statusLabel(status), style: TextStyle(fontSize: 12, color: color, fontFamily: 'Inter')),
        ])),
        Text('₦${amount.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.advisory, fontFamily: 'Inter')),
      ]),
    );
  }
}
