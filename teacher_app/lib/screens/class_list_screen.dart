import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/class.dart';
import 'students_list_screen.dart';

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({super.key});

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  late Future<List<Class>> _classesFuture;

  @override
  void initState() {
    super.initState();
    _classesFuture = _fetchClasses();
  }

  // جلب الفصول الخاصة بالمعلم الحالي
  Future<List<Class>> _fetchClasses() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    final response = await supabase
        .from('classes')
        .select('*')
        .eq('teacher_id', userId)
        .order('class_name', ascending: true);

    if (response.error != null) {
      throw Exception(response.error!.message);
    }

    final data = response.data as List;
    return data.map((item) => Class.fromJson(item)).toList();
  }

  // دالة لعرض مربع حوار إضافة فصل جديد
  void _showAddClassDialog() {
    String className = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('إضافة فصل جديد'),
          content: TextField(
            onChanged: (value) => className = value,
            decoration: const InputDecoration(hintText: "اسم الفصل (مثال: ثاني ثانوي - أ)"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('إضافة'),
              onPressed: () {
                if (className.isNotEmpty) {
                  _addClass(className);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // دالة لإضافة الفصل إلى قاعدة البيانات
  Future<void> _addClass(String className) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final response = await supabase.from('classes').insert({
      'teacher_id': userId,
      'class_name': className,
    });

    if (response.error != null) {
      // إظهار رسالة خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إضافة الفصل: ${response.error!.message}')),
      );
    } else {
      // تحديث القائمة
      setState(() {
        _classesFuture = _fetchClasses();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فصولي الدراسية'),
        actions: [
          // زر الإشعارات العامة (للمالك)
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // توجيه إلى شاشة الإشعارات
            },
            tooltip: 'الإشعارات',
          ),
          // زر الإعدادات (الملف الشخصي)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // توجيه إلى شاشة الإعدادات
            },
            tooltip: 'الإعدادات',
          ),
        ],
      ),
      body: FutureBuilder<List<Class>>(
        future: _classesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('لم تقم بإضافة أي فصول بعد.'),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _showAddClassDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة فصل جديد'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final classModel = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(Icons.class_, color: Colors.indigo, size: 36),
                  title: Text(
                    classModel.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('اضغط للدخول إلى الفصل'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => StudentsListScreen(classModel: classModel),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      // زر إضافة فصل جديد في الصفحة الرئيسية (كما طلب المستخدم)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddClassDialog,
        icon: const Icon(Icons.add),
        label: const Text('فصل جديد'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }
}
