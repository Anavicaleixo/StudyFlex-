import 'package:supabase/supabase.dart';

void main() async {
  print('Initializing Supabase client...');
  final client = SupabaseClient(
    'https://vrldehdiphjokrweseci.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZybGRlaGRpcGhqb2tyd2VzZWNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkwOTg4NjYsImV4cCI6MjA5NDY3NDg2Nn0.xp_k0Vv6ULMC9OdUNP5XnNFbH6_vskbe6crkVApUkCA'
  );

  try {
    print('Deleting existing videos...');
    // We try to delete all videos. neq('id', 'dummy') matches everything
    final deleteRes = await client.from('videos').delete().neq('title', 'dummy_to_match_all').select();
    print('Deleted videos: $deleteRes');

    print('Inserting new videos...');
    final insertRes = await client.from('videos').insert([
      {
        'title': 'Aula de Matemática',
        'description': 'Vídeo educacional de Matemática',
        'image_url': 'https://img.youtube.com/vi/DR2WZkAQmG4/maxresdefault.jpg',
        'video_url': 'https://www.youtube.com/watch?v=DR2WZkAQmG4',
        'category': 'Matemática',
        'views': 0
      },
      {
        'title': 'Aula de Biologia',
        'description': 'Vídeo educacional de Biologia',
        'image_url': 'https://img.youtube.com/vi/DR2WZkAQmG4/maxresdefault.jpg',
        'video_url': 'https://www.youtube.com/watch?v=DR2WZkAQmG4',
        'category': 'Biologia',
        'views': 0
      },
      {
        'title': 'Aula de Filosofia',
        'description': 'Vídeo educacional de Filosofia',
        'image_url': 'https://img.youtube.com/vi/9Dd4b36lHng/maxresdefault.jpg',
        'video_url': 'https://www.youtube.com/watch?v=9Dd4b36lHng&list=PLMra4G0-Z7pO2imaaQCEeGDq7dFFoqcuB',
        'category': 'Filosofia',
        'views': 0
      }
    ]).select();
    print('Inserted videos: $insertRes');
    print('Database updated successfully!');
  } catch (e) {
    print('Error: $e');
  }
}
