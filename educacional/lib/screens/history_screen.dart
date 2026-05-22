import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('history')
          .select()
          .eq('user_id', user.id)
          .order('watched_at', ascending: false);

      if (mounted) {
        setState(() {
          _history = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar histórico: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _clearAllHistory() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F3E34),
        title: Text(
          'Limpar Histórico',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Tem certeza que deseja limpar todo o histórico de visualização?',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.white38),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Limpar Tudo',
              style: GoogleFonts.poppins(
                  color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabase.from('history').delete().eq('user_id', user.id);
        if (mounted) {
          setState(() => _history = []);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Histórico limpo com sucesso'),
              backgroundColor: Color(0xFF0F3E34),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao limpar histórico: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  Future<void> _removeFromHistory(String historyId) async {
    try {
      final parsedId = int.tryParse(historyId);
      if (parsedId == null) return;

      await _supabase.from('history').delete().eq('id', parsedId);

      if (mounted) {
        setState(() {
          _history.removeWhere((item) => item['id'].toString() == historyId);
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Vídeo removido do histórico!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
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

  String _formatDate(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return 'Hoje, ${DateFormat('HH:mm').format(dateTime)}';
      } else if (difference.inDays == 1) {
        return 'Ontem, ${DateFormat('HH:mm').format(dateTime)}';
      } else if (difference.inDays < 7) {
        return '${DateFormat('EEEE', 'pt_BR').format(dateTime)}, ${DateFormat('HH:mm').format(dateTime)}';
      } else {
        return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
      }
    } catch (e) {
      final dateTime = DateTime.tryParse(dateTimeString) ?? DateTime.now();
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
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
        context.go('/favorites');
        break;
      case 2:
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
              'Meu Histórico',
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
        actions: [
          if (_history.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.delete_sweep_rounded,
                    color: Colors.redAccent, size: 24),
                onPressed: _clearAllHistory,
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
            )
          : _history.isEmpty
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
                            Icons.history_rounded,
                            size: 40,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Nenhum vídeo assistido ainda',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Os vídeos que você assistir serão salvos aqui cronologicamente.',
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
                            'Explorar Conteúdo',
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
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    final String hId = item['id'].toString();
                    final String vId = item['video_id'].toString();
                    final String title = item['title'] ?? 'Sem Título';
                    final String imageUrl = item['image_url'] ?? '';
                    final String watchedAt = item['watched_at'] ?? '';

                    return Dismissible(
                      key: Key(hId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.redAccent.withOpacity(0.9),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: Colors.white, size: 28),
                      ),
                      onDismissed: (direction) => _removeFromHistory(hId),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F3E34),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF0F3E34),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    width: 72,
                                    height: 54,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 72,
                                        height: 54,
                                        color: const Color(0xFF082720),
                                        child: const Icon(
                                          Icons.broken_image_rounded,
                                          color: Colors.white24,
                                          size: 20,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    width: 72,
                                    height: 54,
                                    color: const Color(0xFF082720),
                                  ),
                          ),
                          title: Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 13,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_rounded,
                                    color: Colors.white38, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(watchedAt),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white38,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.white30, size: 20),
                            onPressed: () => _removeFromHistory(hId),
                          ),
                          onTap: () => context.push(
                            '/detail/$vId',
                            extra: {
                              'title': title,
                              'description': '',
                              'imageUrl': imageUrl,
                              'category': '',
                            },
                          ),
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
