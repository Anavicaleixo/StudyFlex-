import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();
  String? _userEmail;
  String? _userName;
  String? _userBio;
  String? _userCourse;
  String? _userAvatarUrl;
  int _selectedIndex = 3;
  bool _isEditing = false;
  bool _isLoadingStats = true;

  int _favoritesCount = 0;
  int _watchedCount = 0;

 
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _courseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchStats();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email;
        _userName = user.userMetadata?['name'] ??
            user.email?.split('@').first ??
            'Usuário';
        _userBio = user.userMetadata?['bio'] ?? 'Estudante focado no ENEM';
        _userCourse = user.userMetadata?['course'] ?? 'Curso não informado';
        _userAvatarUrl = user.userMetadata?['avatar_url'];
      });

   
      _nameController.text = _userName ?? '';
      _bioController.text = _userBio ?? '';
      _courseController.text = _userCourse ?? '';
    }
  }

  Future<void> _updateAvatar(String url) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'avatar_url': url,
          },
        ),
      );

      setState(() {
        _userAvatarUrl = url;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil atualizada com sucesso!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar foto de perfil: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fazendo upload da foto...'),
          backgroundColor: Color(0xFF0F3E34),
          duration: Duration(seconds: 2),
        ),
      );

      final bytes = await image.readAsBytes();
      final fileExt = image.name.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      final filePath = '${user.id}/$fileName';

      await _supabase.storage.from('avatars').uploadBinary(
        filePath,
        bytes,
        fileOptions: FileOptions(contentType: 'image/$fileExt', upsert: true),
      );

      final imageUrlResponse = _supabase.storage.from('avatars').getPublicUrl(filePath);
      
      await _updateAvatar(imageUrlResponse);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer upload: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _fetchStats() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final favoritesRes = await _supabase.from('favorites').select('id').eq('user_id', user.id);
      final historyRes = await _supabase.from('history').select('id').eq('user_id', user.id);

      if (mounted) {
        setState(() {
          _favoritesCount = (favoritesRes as List).length;
          _watchedCount = (historyRes as List).length;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _isEditing = false);

    try {
     
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'name': _nameController.text,
            'bio': _bioController.text,
            'course': _courseController.text,
          },
        ),
      );

      setState(() {
        _userName = _nameController.text;
        _userBio = _bioController.text;
        _userCourse = _courseController.text;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar perfil: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F3E34),
        title: Text(
          'Sair da Conta',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Tem certeza que deseja encerrar a sua sessão no StudyFlex+?',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: GoogleFonts.poppins(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Sair',
              style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _supabase.auth.signOut();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        _updateProfile();
      } else {
        _isEditing = true;
      }
    });
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
        context.go('/history');
        break;
      case 3:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final studyHours = (_watchedCount * 15) / 60.0;

    return Scaffold(
      backgroundColor: const Color(0xFF082720),
      appBar: AppBar(
        title: Text(
          'Meu Perfil',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0F3E34),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                _isEditing ? Icons.save_rounded : Icons.edit_rounded,
                color: const Color(0xFF10B981),
              ),
              onPressed: _toggleEdit,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
           
            Container(
              height: 220,
              width: double.infinity,
              color: const Color(0xFF0F3E34),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF10B981),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withOpacity(0.15),
                                blurRadius: 16,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(48),
                            child: (_userAvatarUrl != null && _userAvatarUrl!.isNotEmpty)
                                ? Image.network(
                                    _userAvatarUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: const Color(0xFF0F3E34),
                                        child: const Icon(
                                          Icons.person_rounded,
                                          size: 56,
                                          color: Colors.white54,
                                        ),
                                      );
                                    },
                                  )
                                : Image.asset(
                                    'assets/logo.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: const Color(0xFF0F3E34),
                                        child: const Icon(
                                          Icons.person_rounded,
                                          size: 56,
                                          color: Colors.white54,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_isEditing)
                    Text(
                      _userName ?? 'Usuário',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (!_isEditing)
                    const SizedBox(height: 4),
                  if (!_isEditing)
                    Text(
                      _userEmail ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white38,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                 
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F3E34),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF0F3E34),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.badge_rounded, color: Color(0xFF10B981), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Informações de Perfil',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                       
                        _buildEditableField(
                          icon: Icons.person_rounded,
                          label: 'Nome de Estudante',
                          value: _userName ?? '',
                          controller: _nameController,
                          isEditing: _isEditing,
                        ),
                        const SizedBox(height: 16),

                      
                        _buildInfoRow(Icons.email_rounded, 'Endereço de E-mail',
                            _userEmail ?? 'Não informado'),
                        const SizedBox(height: 16),

                      
                        _buildEditableField(
                          icon: Icons.school_rounded,
                          label: 'Curso / Objetivo Acadêmico',
                          value: _userCourse ?? '',
                          controller: _courseController,
                          isEditing: _isEditing,
                        ),
                        const SizedBox(height: 16),

                      
                        _buildEditableField(
                          icon: Icons.description_rounded,
                          label: 'Biografia / Status',
                          value: _userBio ?? '',
                          controller: _bioController,
                          isEditing: _isEditing,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F3E34),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF0F3E34),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.analytics_rounded, color: Color(0xFF10B981), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Seu Progresso',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _isLoadingStats
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  _buildStatRow(
                                    icon: Icons.favorite_rounded,
                                    label: 'Favoritos Salvos',
                                    value: '$_favoritesCount',
                                    iconColor: Colors.redAccent,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildStatRow(
                                    icon: Icons.play_circle_rounded,
                                    label: 'Aulas Concluídas',
                                    value: '$_watchedCount',
                                    iconColor: Colors.blueAccent,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildStatRow(
                                    icon: Icons.timer_rounded,
                                    label: 'Tempo de Estudo Estimado',
                                    value: studyHours >= 1.0
                                        ? '${studyHours.toStringAsFixed(1)} horas'
                                        : '${(studyHours * 60).toInt()} minutos',
                                    iconColor: Colors.amberAccent,
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                      label: Text(
                        'Sair da Conta',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.redAccent.withOpacity(0.5), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 100 + bottomPadding),
                ],
              ),
            ),
          ],
        ),
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
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Início'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite_rounded), label: 'Favoritos'),
            BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded), label: 'Histórico'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Perfil'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.white30),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField({
    required IconData icon,
    required String label,
    required String value,
    required TextEditingController controller,
    required bool isEditing,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.white30),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(height: 4),
              if (isEditing)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: TextField(
                    controller: controller,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                    maxLines: maxLines,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF082720),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF082720)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                )
              else
                Text(
                  value.isEmpty ? 'Não informado' : value,
                  style: GoogleFonts.poppins(
                    color: value.isEmpty ? Colors.white24 : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
