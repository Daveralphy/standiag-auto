import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response;
  }

  Future<int> getScanCount() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 0;

    final response = await _supabase
        .from('scans')
        .select('id')
        .eq('user_id', userId);

    return (response as List).length;
  }

  Future<Map<String, dynamic>?> getLastScan() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('scans')
        .select()
        .eq('user_id', userId)
        .order('scanned_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return response;
  }
}