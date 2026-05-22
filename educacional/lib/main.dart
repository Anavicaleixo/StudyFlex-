import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/app_router.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseConfig.initialize();

  runApp(const StreamingAcademicoApp());
}

class StreamingAcademicoApp extends StatelessWidget {
  const StreamingAcademicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'StudyFlex+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF082720), 
        cardColor: const Color(0xFF0F3E34), 
        primaryColor: const Color(0xFF10B981), 
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981), 
          secondary: Color(0xFF34D399),  
          surface: Color(0xFF0F3E34),
          background: Color(0xFF082720),
          error: Colors.redAccent,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF082720),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF082720),
          selectedItemColor: Color(0xFF10B981),
          unselectedItemColor: Colors.white60,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
