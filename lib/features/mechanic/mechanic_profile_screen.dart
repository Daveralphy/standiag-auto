import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_field.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/screen_header.dart';

import '../auth/login_screen.dart';

class MechanicProfileScreen extends StatefulWidget {
  const MechanicProfileScreen({super.key});
  @override
  State<MechanicProfileScreen> createState() => _MechanicProfileScreenState();
}

class _MechanicProfileScreenState extends State<MechanicProfileScreen> {
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _mechProfile;
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final p = await Supabase.instance.client.from('profiles').select().eq('id', userId).maybeSingle();
      final m = await Supabase.instance.client.from('mechanic_profiles').select().eq('id', userId).maybeSingle();
      if (mounted) setState(() { _profile = p; _mechProfile = m; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  void _editProfile() {
    final fCtrl = TextEditingController(text: _profile?['first_name'] ?? '');
    final lCtrl = TextEditingController(text: _profile?['last_name'] ?? '');
    final phCtrl = TextEditingController(text: _profile?['phone'] ?? '');
    final locCtrl = TextEditingController(text: _mechProfile?['location'] ?? '');
    final bioCtrl = TextEditingController(text: _mechProfile?['bio'] ?? '');
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
        bool saving = false;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24, 20, 24, 32), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Inter')),
            const SizedBox(height: 20),
            AppField(label: 'First Name', hint: 'First name', controller: fCtrl),
            const SizedBox(height: 12),
            AppField(label: 'Last Name', hint: 'Last name', controller: lCtrl),
            const SizedBox(height: 12),
            AppField(label: 'Phone', hint: 'Phone number', controller: phCtrl, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            AppField(label: 'Location', hint: 'e.g. Ikeja, Lagos', controller: locCtrl),
            const SizedBox(height: 12),
            AppField(label: 'Bio', hint: 'About you', controller: bioCtrl),
            const SizedBox(height: 24),
            StatefulBuilder(builder: (_, setSave) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: saving ? null : () async {
                setSave(() => saving = true);
                final nav = Navigator.of(ctx);
                try {
                  final uid = Supabase.instance.client.auth.currentUser?.id;
                  await Supabase.instance.client.from('profiles').update({'first_name': fCtrl.text.trim(), 'last_name': lCtrl.text.trim(), 'phone': phCtrl.text.trim()}).eq('id', uid!);
                  await Supabase.instance.client.from('mechanic_profiles').update({'location': locCtrl.text.trim(), 'bio': bioCtrl.text.trim()}).eq('id', uid);
                  nav.pop();
                  _loadData();
                } catch (_) {
                  setSave(() => saving = false);
                  if (mounted) AppToast.error(context, 'Failed to save profile.');
                }
              },
              child: Container(width: double.infinity, height: 54,
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
                child: Center(child: saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Inter')))))),
          ])));
      }),
    );
  }

  void _signOut() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Sign Out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Inter')),
      content: const Text('Are you sure you want to sign out?', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontFamily: 'Inter')),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter'))),
        TextButton(onPressed: () async {
          Navigator.of(ctx).pop();
          final nav = Navigator.of(context);
          if (context.mounted) { nav.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false); }
        }, child: const Text('Sign Out', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontFamily: 'Inter'))),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final fn = _profile?['first_name'] ?? '';
    final ln = _profile?['last_name'] ?? '';
    final un = _profile?['username'] ?? '';
    final rating = (_mechProfile?['rating'] as num?)?.toDouble() ?? 0.0;
    final jobs = (_mechProfile?['jobs_done'] as num?)?.toInt() ?? 0;
    final loc = _mechProfile?['location'] ?? '';
    final bio = _mechProfile?['bio'] ?? '';
    final specs = List<String>.from(_mechProfile?['specialisations'] ?? []);
    final exp = (_mechProfile?['experience_years'] as num?)?.toInt() ?? 0;
    final verified = _mechProfile?['is_verified'] ?? false;
    final avatarHex = _mechProfile?['avatar_color'] ?? 'C0272D';
    final ac = Color(int.parse('FF$avatarHex', radix: 16));
    final initials = ((fn.isNotEmpty ? fn[0] : '') + (ln.isNotEmpty ? ln[0] : '')).toUpperCase();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _loading
        ? Center(child: CircularProgressIndicator(color: AppColors.primary))
        : RefreshIndicator(color: AppColors.primary, backgroundColor: AppColors.surface, onRefresh: _loadData,
          child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
            const SizedBox(height: 16),
            ScreenHeader(
              title: un.isNotEmpty ? '@$un' : 'Profile',
              subtitle: 'Mechanic account',
              actionIcon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary, size: 20),
              onActionTap: () {},
            ),
            const SizedBox(height: 20),
            Container(padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primaryBorder)),
              child: Column(children: [
                Stack(children: [
                  Container(width: 80, height: 80,
                    decoration: BoxDecoration(color: ac, shape: BoxShape.circle, border: Border.all(color: AppColors.primaryBorder, width: 2)),
                    child: Center(child: Text(initials, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Inter')))),
                  if (verified) Positioned(bottom: 0, right: 0,
                    child: Container(width: 24, height: 24, decoration: const BoxDecoration(color: AppColors.advisory, shape: BoxShape.circle),
                      child: const Icon(Icons.verified_rounded, color: Colors.white, size: 14))),
                ]),
                const SizedBox(height: 12),
                Text(' ', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Inter')),
                Text('@$un', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Inter')),
                if (loc.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.location_on_outlined, color: AppColors.textTertiary, size: 13),
                    const SizedBox(width: 4),
                    Text(loc, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary, fontFamily: 'Inter')),
                  ]),
                ],
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _stat('Rating', rating.toStringAsFixed(1), Icons.star_rounded, AppColors.gold),
                  _stat('Jobs', jobs.toString(), Icons.build_rounded, AppColors.primary),
                  _stat('Exp', '${exp}yr', Icons.workspace_premium_rounded, AppColors.moderate),
                ]),
              ])),
            if (bio.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('ABOUT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 1.5, fontFamily: 'Inter')),
                  const SizedBox(height: 8),
                  Text(bio, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5, fontFamily: 'Inter')),
                ])),
            ],
            if (specs.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('SPECIALISATIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 1.5, fontFamily: 'Inter')),
                  const SizedBox(height: 10),
                  Wrap(spacing: 6, runSpacing: 6, children: specs.map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.primarySubtle, borderRadius: BorderRadius.circular(100), border: Border.all(color: AppColors.primaryBorder)),
                    child: Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary, fontFamily: 'Inter')))).toList()),
                ])),
            ],
            const SizedBox(height: 24),
            const Text('ACCOUNT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 1.5, fontFamily: 'Inter')),
            const SizedBox(height: 10),
            _row(Icons.person_outline_rounded, 'Edit Profile', false, _editProfile),
            const SizedBox(height: 8),
            _row(Icons.lock_outline_rounded, 'Change Password', false, () {}),
            const SizedBox(height: 24),
            const Text('DANGER ZONE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary, letterSpacing: 1.5, fontFamily: 'Inter')),
            const SizedBox(height: 10),
            _row(Icons.logout_rounded, 'Sign Out', true, _signOut),
            const SizedBox(height: 32),
          ]))),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) => Column(children: [
    Icon(icon, color: color, size: 20), const SizedBox(height: 4),
    Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Inter')),
    Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Inter')),
  ]);

  Widget _row(IconData icon, String label, bool red, VoidCallback onTap) {
    final c = red ? AppColors.primary : AppColors.textPrimary;
    return GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap,
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: red ? AppColors.primaryBorder : AppColors.border)),
        child: Row(children: [
          Icon(icon, color: c, size: 20), const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c, fontFamily: 'Inter'))),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 18),
        ])));
  }
}



