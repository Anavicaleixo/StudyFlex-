import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/video_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _supabase = Supabase.instance.client;
  List<VideoModel> _trendingVideos = [];
  List<VideoModel> _recentVideos = [];
  List<VideoModel> _recommendedVideos = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      final trending = await _supabase
          .from('videos')
          .select()
          .order('views', ascending: false)
          .limit(10);

      final recent = await _supabase
          .from('videos')
          .select()
          .order('created_at', ascending: false)
          .limit(10);

      final recommended = await _supabase
          .from('videos')
          .select()
          .order('views', ascending: false)
          .limit(10);

      if (mounted) {
        setState(() {
          _trendingVideos =
              (trending as List).map((v) => VideoModel.fromJson(v)).toList();
          _recentVideos =
              (recent as List).map((v) => VideoModel.fromJson(v)).toList();
          _recommendedVideos =
              (recommended as List).map((v) => VideoModel.fromJson(v)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar vídeos: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _buildCategorySection(
      String title, IconData icon, List<VideoModel> videos) {
    if (videos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF10B981),
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return GestureDetector(
                onTap: () => context.push(
                  '/detail/${video.id}',
                  extra: {
                    'title': video.title,
                    'description': video.description,
                    'imageUrl': video.imageUrl,
                    'category': video.category,
                  },
                ),
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              video.imageUrl,
                              height: 160,
                              width: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 160,
                                  width: 150,
                                  color: const Color(0xFF0F3E34),
                                  child: const Icon(
                                    Icons.video_library,
                                    color: Color(0xFF10B981),
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                video.category,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF34D399),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        context.go('/favorites');
        break;
      case 2:
        context.go('/history');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF082720),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 280,
                  floating: false,
                  pinned: true,
                  backgroundColor: const Color(0xFF082720),
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                       
                        Container(
                          color: const Color(0xFF082720),
                        ),
                      
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 16,
                          left: 16,
                          child: Container(
                            width: 80,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F3E34),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF10B981).withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/logo.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.school_rounded,
                                    size: 28,
                                    color: Color(0xFF10B981),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      
                        Positioned(
                          bottom: 25,
                          left: 16,
                          right: 16,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Sua aprovação começa',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black54,
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'aqui',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.pacifico(
                                  fontSize: 54,
                                  fontWeight: FontWeight.normal,
                                  color: const Color(0xFF10B981),
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black54,
                                      offset: Offset(0, 3),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildCategorySection('Mais Assistidos',
                          Icons.whatshot_rounded, _trendingVideos),
                      const SizedBox(height: 16),
                      _buildCategorySection('Adicionados Recentemente',
                          Icons.new_releases_rounded, _recentVideos),
                      const SizedBox(height: 16),
                      _buildCategorySection('Recomendados para Você',
                          Icons.star_rounded, _recommendedVideos),
                      SizedBox(height: 100 + bottomPadding),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: const Color(0xFF0F3E34).withOpacity(0.8),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: const Color(0xFF082720),
          selectedItemColor: const Color(0xFF10B981),
          unselectedItemColor: Colors.white60,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: 'Início'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite_rounded), label: 'Favoritos'),
            BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded), label: 'Histórico'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}
