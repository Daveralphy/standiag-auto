import 'package:supabase_flutter/supabase_flutter.dart';

class VehicleService {
  final _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  Future<bool> hasVehicles() async {
    if (_userId == null) return false;
    final res = await _supabase
        .from('vehicles')
        .select('id')
        .eq('user_id', _userId!)
        .limit(1);
    return (res as List).isNotEmpty;
  }

  Future<Map<String, dynamic>?> getActiveVehicle() async {
    if (_userId == null) return null;
    return await _supabase
        .from('vehicles')
        .select()
        .eq('user_id', _userId!)
        .eq('is_active', true)
        .maybeSingle();
  }

  Future<List<Map<String, dynamic>>> getUserVehicles() async {
    if (_userId == null) return [];
    final res = await _supabase
        .from('vehicles')
        .select()
        .eq('user_id', _userId!)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }
}

