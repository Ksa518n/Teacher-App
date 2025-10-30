import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'class_list_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // الاستماع لحالة المصادقة
    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _navigateToClassList();
      }
    });
  }

  void _navigateToClassList() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ClassListScreen()),
      );
    }
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (response.user == null) {
        // إدارة الأخطاء
      }
    } on AuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ غير متوقع')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // تسجيل الدخول عبر Google (يتطلب إعدادات إضافية في Flutter)
  Future<void> _signInWithGoogle() async {
    // يجب تنفيذ منطق تسجيل الدخول عبر Google هنا
    // يتطلب إعدادات خاصة بالمنصة (Android/iOS)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تسجيل الدخول عبر Google قيد التنفيذ...')),
    );
  }

  // تسجيل الدخول عبر Apple (يتطلب إعدادات إضافية في Flutter)
  Future<void> _signInWithApple() async {
    // يجب تنفيذ منطق تسجيل الدخول عبر Apple هنا
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تسجيل الدخول عبر Apple قيد التنفيذ...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // إذا كان المستخدم مسجلاً بالفعل، انتقل مباشرة
    if (supabase.auth.currentUser != null) {
      _navigateToClassList();
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'مرحباً بك مجدداً',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const SizedBox(height: 8),
              const Text(
                'يرجى تسجيل الدخول للمتابعة',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'تسجيل الدخول',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
              
              const SizedBox(height: 24),
              
              const Divider(thickness: 1),
              const SizedBox(height: 16),

              // أزرار تسجيل الدخول الاجتماعي
              ElevatedButton.icon(
                onPressed: _signInWithGoogle,
                icon: const Icon(Icons.public, color: Colors.red), // أيقونة مؤقتة
                label: const Text('تسجيل الدخول عبر Google'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _signInWithApple,
                icon: const Icon(Icons.apple, color: Colors.black),
                label: const Text('تسجيل الدخول عبر Apple'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
