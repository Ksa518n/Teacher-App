import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/class_list_screen.dart'; // شاشة قائمة الفصول
import 'screens/auth_screen.dart'; // شاشة تسجيل الدخول

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Supabase
  // يجب استبدال هذه القيم بقيم مشروعك الفعلي في Supabase
  await Supabase.initialize(
    url: 'https://fjutnlhglyilrwlzodhq.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZqdXRubGhnbHlpbHJ3bHpvZGhqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE3NTc2NDMsImV4cCI6MjA3NzMzMzY0M30.FdWoTSYGLRxPbu2onKMCsne_mJ9RYvciaXOpgLbyqO8',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق إدارة الفصول',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Arial', // تم استخدام خط "Cairo" الافتراضي لتمثيل خط عربي احترافي
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
      ),
      home: const AuthScreen(),\n      locale: const Locale('ar'),\n      supportedLocales: const [Locale('ar')],\n      localizationsDelegates: const [\n        GlobalMaterialLocalizations.delegate,\n        GlobalWidgetsLocalizations.delegate,\n        GlobalCupertinoLocalizations.delegate,\n      ],
    );
  }
}
