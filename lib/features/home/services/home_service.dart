// lib/features/home/home_repository.dart
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:pingo/features/home/models/home_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeService {
  static final _db = Supabase.instance.client;

  static String get _userId {
    final id = _db.auth.currentUser?.id;
    if (id == null) throw Exception('Not authenticated');
    return id;
  }

  static Future<HomeData> fetchHomeData() async {
    final TimezoneInfo timezoneInfo = await FlutterTimezone.getLocalTimezone();

    final data = await _db.rpc(
      'get_user_home_events',
      params: {'p_user_id': _userId, 'p_timezone': timezoneInfo.identifier},
    );

    return HomeData.fromJson(data);
  }
}
