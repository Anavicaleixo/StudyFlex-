import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('favorites')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _favorites = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar favoritos: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _removeFavorite(String videoId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase
          .from('favorites')
          .delete()
          .eq('user_id', user.id)
          .eq('video_id', videoId);

      if (mounted) {
        setState(() {
          _favorites
              .removeWhere((item) => item['video_id'].toString() == videoId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removido dos favoritos'),
            backgroundColor: Color(0xFF0F3E34),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
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
    return Scaffold(
      backgroundColor: const Color(0xFF082720),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo.png', height: 80),
            const SizedBox(width: 8),
            Text(
              'Meus Favoritos',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF082720),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
            )
          : _favorites.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F3E34),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF10B981).withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.favorite_outline_rounded,
                            size: 40,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Nenhum favorito ainda',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Marque os vídeos que você mais gosta para acessá-los rapidamente aqui.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white38,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.go('/home'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Explorar Vídeos',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final favorite = _favorites[index];
                    final String vId = favorite['video_id'].toString();
                    final String title = favorite['title'] ?? 'Sem Título';
                    final String imageUrl = favorite['image_url'] ?? '';
                    final String category = favorite['category'] ?? 'Educação';

                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F3E34),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF0F3E34),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () => context.push(
                                '/detail/$vId',
                                extra: {
                                  'title': title,
                                  'description': '',
                                  'imageUrl': imageUrl,
                                  'category': category,
                                },
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                color: const Color(0xFF0F3E34),
                                                child: const Icon(
                                                  Icons.broken_image_rounded,
                                                  color: Colors.white24,
                                                  size: 36,
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            color: const Color(0xFF0F3E34)),
                                  ),
                                  Expanded(
                                    flex: 6,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            category.toUpperCase(),
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFF34D399),
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Expanded(
                                            child: Text(
                                              title,
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                height: 1.3,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.55),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(6),
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                  onPressed: () => _removeFavorite(vId),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
