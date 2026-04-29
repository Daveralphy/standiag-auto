import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/screen_header.dart';

class MechanicEarningsScreen extends StatefulWidget {
  const MechanicEarningsScreen({super.key});
  @override
  State<MechanicEarningsScreen> createState() => _MechanicEarningsScreenState();
}

class _MechanicEarningsScreenState extends State<MechanicEarningsScreen> {
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _withdrawals = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final p = await Supabase.instance.client.from('mechanic_profiles').select().eq('id', userId).maybeSingle();
      final t = await Supabase.instance.client.from('wallet_transactions').select().eq('mechanic_id', userId).order('created_at', ascending: false).limit(20);
      final w = await Supabase.instance.client.from('withdrawal_requests').select().eq('mechanic_id', userId).order('created_at', ascending: false).limit(10);
      if (mounted) setState(() { _profile = p; _transactions = List<Map<String, dynamic>>.from(t); _withdrawals = List<Map<String, dynamic>>.from(w); _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  void _showWithdrawSheet() {
    final balance = (_profile?['available_balance'] as num?)?.toDouble() ?? 0.0;
    final bankCtrl = TextEditingController();
    final numCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    bool loading = false;

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Withdraw Funds', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Inter')),
            const SizedBox(height: 4),
            Text('Available: ₦${balance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: AppColors.advisory, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
            const SizedBox(height: 10),
            Container(padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.moderateBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.moderateBorder)),
              child: const Text('A 5% transaction fee applies to all withdrawals.', style: TextStyle(fontSize: 12, color: AppColors.moderate, fontFamily: 'Inter'))),
            const SizedBox(height: 16),
            _field('AMOUNT (₦)', 'Enter amount', amtCtrl, TextInputType.number),
            const SizedBox(height: 12),
            _field('BANK NAME', 'e.g. GTBank, First Bank', bankCtrl),
            const SizedBox(height: 12),
            _field('ACCOUNT NUMBER', '10-digit number', numCtrl, TextInputType.number),
            const SizedBox(height: 12),
            _field('ACCOUNT NAME', 'As on your bank account', nameCtrl),
            const SizedBox(height: 16),
            ValueListenableBuilder(valueListenable: amtCtrl, builder: (_, __, ___) {
              final gross = double.tryParse(amtCtrl.text) ?? 0.0;
              if (gross <= 0) return const SizedBox.shrink();
              final fee = gross * 0.05; final payout = gross - fee;
              return Container(padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                child: Column(children: [
                  _feeRow('Withdrawal', '₦${gross.toStringAsFixed(2)}'),
                  _feeRow('Fee (5%)', '-₦${fee.toStringAsFixed(2)}', isRed: true),
                  const Divider(color: AppColors.border, height: 12),
                  _feeRow('You receive', '₦${payout.toStringAsFixed(2)}', isBold: true),
                ]));
            }),
            const SizedBox(height: 20),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: loading ? null : () async {
                final gross = double.tryParse(amtCtrl.text.trim());
                if (gross == null || gross <= 0) {
                  AppToast.error(context, 'Enter a valid amount.'); return;
                }
                if (gross > balance) {
                  AppToast.error(context, 'Exceeds available balance.'); return;
                }
                if (bankCtrl.text.isEmpty || numCtrl.text.isEmpty || nameCtrl.text.isEmpty) {
                  AppToast.error(context, 'Fill in all bank details.'); return;
                }
                set(() => loading = true);
                try {
                  final userId = Supabase.instance.client.auth.currentUser?.id;
                  final fee = gross * 0.05;
                  await Supabase.instance.client.from('withdrawal_requests').insert({
                    'mechanic_id': userId, 'gross_amount': gross, 'withdrawal_fee': fee,
                    'payout_amount': gross - fee, 'bank_name': bankCtrl.text.trim(),
                    'account_number': numCtrl.text.trim(), 'account_name': nameCtrl.text.trim(), 'status': 'pending',
                  });
                  if (ctx.mounted) { Navigator.of(ctx).pop(); _loadData(); }
                } catch (_) {
                  set(() => loading = false);
                  if (mounted) AppToast.error(context,'Something went wrong.');
                }
              },
              child: Container(width: double.infinity, height: 54,
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
                child: Center(child: loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('REQUEST WITHDRAWAL', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Inter')))),
            ),
          ]),
        ),
      )),
    );
  }

  Widget _field(String label, String hint, TextEditingController ctrl, [TextInputType keyboard = TextInputType.text]) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 1.5, fontFamily: 'Inter')),
      const SizedBox(height: 6),
      TextField(controller: ctrl, keyboardType: keyboard,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontFamily: 'Inter'),
        decoration: InputDecoration(hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textDisabled, fontFamily: 'Inter'),
          filled: true, fillColor: AppColors.background, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)))),
    ]);
  }

  Widget _feeRow(String label, String value, {bool isRed = false, bool isBold = false}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [
      Expanded(child: Text(label, style: TextStyle(fontSize: 12, color: isBold ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: isBold ? FontWeight.w700 : FontWeight.w400, fontFamily: 'Inter'))),
      Text(value, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.w800 : FontWeight.w600, color: isRed ? AppColors.primary : isBold ? AppColors.advisory : AppColors.textPrimary, fontFamily: 'Inter')),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    final balance = (_profile?['available_balance'] as num?)?.toDouble() ?? 0.0;
    final total = (_profile?['total_earnings'] as num?)?.toDouble() ?? 0.0;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : RefreshIndicator(color: AppColors.primary, backgroundColor: AppColors.surface, onRefresh: _loadData,
          child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
            const SizedBox(height: 16),
            const ScreenHeader(
              title: 'Earnings',
              subtitle: 'Your wallet \u0026 payouts',
            ),
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1A0608), Color(0xFF0F0304)]),
                borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primaryBorder),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 4))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('AVAILABLE BALANCE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 1.5, fontFamily: 'Inter')),
                const SizedBox(height: 8),
                Text('₦${balance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontFamily: 'Inter', letterSpacing: -0.5)),
                Text('Total earned: ₦${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Inter')),
                const SizedBox(height: 16),
                GestureDetector(behavior: HitTestBehavior.opaque, onTap: balance > 0 ? _showWithdrawSheet : null,
                  child: Container(padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(color: balance > 0 ? AppColors.primary : AppColors.surface, borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text('WITHDRAW FUNDS',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: balance > 0 ? Colors.white : AppColors.textTertiary, letterSpacing: 0.5, fontFamily: 'Inter'))))),
              ])),
            const SizedBox(height: 24),
            const Text('TRANSACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 1.5, fontFamily: 'Inter')),
            const SizedBox(height: 10),
            if (_transactions.isEmpty)
              Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                child: const Center(child: Text('No transactions yet.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Inter'))))
            else
              ..._transactions.map((t) {
                final isCredit = t['type'] == 'credit';
                final amount = (t['amount'] as num?)?.toDouble() ?? 0.0;
                return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  child: Row(children: [
                    Container(width: 40, height: 40,
                      decoration: BoxDecoration(color: isCredit ? AppColors.advisoryBg : AppColors.criticalBg, borderRadius: BorderRadius.circular(10)),
                      child: Icon(isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: isCredit ? AppColors.advisory : AppColors.primary, size: 18)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(t['description'] ?? (isCredit ? 'Credit' : 'Withdrawal'),
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontFamily: 'Inter'))),
                    Text('${isCredit ? '+' : '-'}₦${amount.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isCredit ? AppColors.advisory : AppColors.primary, fontFamily: 'Inter')),
                  ]));
              }),
            if (_withdrawals.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('WITHDRAWALS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 1.5, fontFamily: 'Inter')),
              const SizedBox(height: 10),
              ..._withdrawals.map((w) {
                final payout = (w['payout_amount'] as num?)?.toDouble() ?? 0.0;
                final status = w['status'] ?? 'pending';
                final sColor = status == 'completed' ? AppColors.advisory : status == 'failed' ? AppColors.primary : AppColors.moderate;
                return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  child: Row(children: [
                    const Icon(Icons.account_balance_outlined, color: AppColors.textTertiary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(w['bank_name'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'Inter')),
                      Text(w['account_number'] ?? '', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Inter')),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('₦${payout.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamily: 'Inter')),
                      Text(status, style: TextStyle(fontSize: 10, color: sColor, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                    ]),
                  ]));
              }),
            ],
            const SizedBox(height: 32),
          ]))),
    );
  }
}

