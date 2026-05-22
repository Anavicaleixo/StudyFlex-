import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {

  static const String supabaseUrl = 'https://vrldehdiphjokrweseci.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZybGRlaGRpcGhqb2tyd2VzZWNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkwOTg4NjYsImV4cCI6MjA5NDY3NDg2Nn0.xp_k0Vv6ULMC9OdUNP5XnNFbH6_vskbe6crkVApUkCA';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
