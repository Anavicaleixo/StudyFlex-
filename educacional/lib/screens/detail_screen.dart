import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class DetailScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final String description;
  final String imageUrl;
  final String category;

  const DetailScreen({
    super.key,
    required this.videoId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _supabase = Supabase.instance.client;
  bool _isFavorite = false;
  bool _isLoading = true;
  String? _userId;

  String? _title;
  String? _description;
  String? _imageUrl;
  String? _category;
  String? _videoUrl;

  @override
  void initState() {
    super.initState();
    _title = widget.title.isEmpty ? null : widget.title;
    _description = widget.description.isEmpty ? null : widget.description;
    _imageUrl = widget.imageUrl.isEmpty ? null : widget.imageUrl;
    _category = widget.category.isEmpty ? null : widget.category;

    _isLoading = (_title == null);
    _loadVideoDetailsAndCheckFavorite();
  }

  Future<void> _loadVideoDetailsAndCheckFavorite() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      _userId = user.id;
    }

    try {
      if (_title == null || _imageUrl == null || _description == null || _category == null || _videoUrl == null) {
        final videoIntId = int.tryParse(widget.videoId);
        if (videoIntId != null) {
          final data = await _supabase
              .from('videos')
              .select()
              .eq('id', videoIntId)
              .single();

          if (mounted) {
            setState(() {
              _title = data['title'] ?? '';
              _description = data['description'] ?? '';
              _imageUrl = data['image_url'] ?? '';
              _category = data['category'] ?? '';
              _videoUrl = data['video_url'] ?? '';
            });
          }
        }
      }

      if (_userId != null && mounted) {
        await _checkIfFavorite();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar detalhes do vídeo: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkIfFavorite() async {
    try {
      final response = await _supabase
          .from('favorites')
          .select()
          .eq('user_id', _userId!)
          .eq('video_id', widget.videoId);

      if (mounted) {
        setState(() => _isFavorite = response.isNotEmpty);
      }
    } catch (e) {
     
    }
  }

  Future<void> _toggleFavorite() async {
    if (_userId == null || _title == null) return;

    try {
      if (_isFavorite) {
        await _supabase
            .from('favorites')
            .delete()
            .eq('user_id', _userId!)
            .eq('video_id', widget.videoId);

        if (mounted) {
          setState(() => _isFavorite = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removido dos favoritos'),
              backgroundColor: Color(0xFF0F3E34),
            ),
          );
        }
      } else {
        await _supabase.from('favorites').insert({
          'user_id': _userId!,
          'video_id': widget.videoId,
          'title': _title!,
          'image_url': _imageUrl!,
          'category': _category!,
          'created_at': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          setState(() => _isFavorite = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Adicionado aos favoritos!'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao favoritar: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _addToHistory() async {
    if (_userId == null || _title == null) return;

    try {
      await _supabase.from('history').insert({
        'user_id': _userId!,
        'video_id': widget.videoId,
        'title': _title!,
        'image_url': _imageUrl!,
        'watched_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
     
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF082720),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
          ),
        ),
      );
    }

    final safeTitle = _title ?? 'Detalhes do Vídeo';
    final safeImageUrl = _imageUrl ?? '';
    final safeCategory = _category ?? 'Vídeo';
    final safeDescription = _description ?? 'Sem sinopse disponível.';

    return Scaffold(
      backgroundColor: const Color(0xFF082720),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: const Color(0xFF082720),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  onPressed: () => context.go('/home'),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  safeImageUrl.isNotEmpty
                      ? Image.network(
                          safeImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFF0F3E34),
                              child: const Icon(
                                Icons.video_library_rounded,
                                size: 80,
                                color: Color(0xFF10B981),
                              ),
                            );
                          },
                        )
                      : Container(color: const Color(0xFF0F3E34)),
                 
                  Container(
                    color: Colors.black.withOpacity(0.15),
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.redAccent : Colors.white,
                      size: 20,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      safeCategory.toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF34D399),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                 
                  Text(
                    safeTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Container(
                    height: 1,
                    color: const Color(0xFF0F3E34),
                  ),
                  const SizedBox(height: 24),
                 
                  Text(
                    'Sinopse do Conteúdo',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                 
                  Text(
                    safeDescription,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 32),
                 
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        _addToHistory();
                        if (_videoUrl != null && _videoUrl!.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) => YouTubePlayerDialog(videoUrl: _videoUrl!),
                          );
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('URL do vídeo indisponível.'), backgroundColor: Colors.orange),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 28),
                      label: Text(
                        'ASSISTIR AGORA',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: const Color(0xFF10B981).withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class YouTubePlayerDialog extends StatefulWidget {
  final String videoUrl;
  const YouTubePlayerDialog({super.key, required this.videoUrl});

  @override
  State<YouTubePlayerDialog> createState() => _YouTubePlayerDialogState();
}

class _YouTubePlayerDialogState extends State<YouTubePlayerDialog> {
  late YoutubePlayerController _controller;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    final uri = Uri.tryParse(widget.videoUrl);
    String? videoId = uri?.queryParameters['v'];
    
    if (videoId == null && uri != null && uri.host.contains('youtu.be')) {
      videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }

    if (videoId == null) {
      _isError = true;
    } else {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    if (!_isError) {
      _controller.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return AlertDialog(
        backgroundColor: const Color(0xFF0F3E34),
        title: const Text('Erro', style: TextStyle(color: Colors.white)),
        content: const Text('Não foi possível carregar o vídeo. URL inválida.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar', style: TextStyle(color: Color(0xFF10B981))),
          )
        ],
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22), 
              child: YoutubePlayer(
                controller: _controller,
                aspectRatio: 16 / 9,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
