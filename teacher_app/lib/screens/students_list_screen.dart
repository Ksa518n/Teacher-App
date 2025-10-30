import 'package:flutter/material.dart';\nimport 'package:supabase_flutter/supabase_flutter.dart';\nimport '../services/student_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/class.dart';
import '../models/student.dart';

class StudentsListScreen extends StatefulWidget {
  final Class classModel;

  const StudentsListScreen({Key? key, required this.classModel}) : super(key: key);

  @override
  _StudentsListScreenState createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {\n  final StudentService _studentService = StudentService();\n  final SupabaseClient supabase = Supabase.instance.client;
  final SupabaseClient supabase = Supabase.instance.client;
  late Future<List<Student>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = _fetchStudents();
  }

  Future<List<Student>> _fetchStudents() async {
    final response = await supabase
        .from('students')
        .select('*')
        .eq('class_id', widget.classModel.id)
        .order('student_name', ascending: true);

    if (response.error != null) {
      throw Exception(response.error!.message);
    }

    final data = response.data as List;
    return data.map((item) => Student.fromJson(item)).toList();
  }

  // دالة لتسجيل الإجراءات اليومية (حضور، مشاركة، واجب)
  Future<void> _logPerformance(Student student, String logType, {String? note, int? points}) async {
    // منطق لمنع التكرار (للحضور والمشاركة والواجب)
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    // Check if attendance/participation/homework is already logged today
    if (logType != 'behavior') {
      final existingLog = await supabase
          .from('performance_log')
          .select('*')
          .eq('student_id', student.id)
          .eq('log_type', logType)
          .eq('log_date', today)
          .limit(1);

      if (existingLog.data != null && existingLog.data!.isNotEmpty) {
        // Already logged, return (prevents double logging)
        return;
      }
    }

    // Fetch points setting from point_settings table (simplified for now)
    // In a real app, this would fetch the teacher's customized points
    final defaultPoints = {
      'attendance': 5,
      'participation': 3,
      'homework': 10,
      'positive_behavior': 5,
      'negative_behavior': -5,
    };
    
    final finalPoints = points ?? defaultPoints[logType] ?? 0;

    final response = await supabase.from('performance_log').insert({
      'student_id': student.id,
      'log_type': logType,
      'points_awarded': finalPoints,
      'behavior_note': note,
      'log_date': today,
    });

    if (response.error != null) {
      // Show error to user
    } else {
      // Show success message
    }
  }

  // بناء واجهة الطالب مع الأزرار
  Widget _buildStudentTile(Student student) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              student.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // زر الحضور
                _buildActionButton(
                  'حضور',
                  Icons.check_circle,
                  Colors.green,
                  () => _logPerformance(student, 'attendance'),
                ),
                // زر المشاركة
                _buildActionButton(
                  'مشاركة',
                  Icons.star,
                  Colors.amber,
                  () => _logPerformance(student, 'participation'),
                ),
                // زر الواجب
                _buildActionButton(
                  'واجب',
                  Icons.assignment,
                  Colors.blue,
                  () => _logPerformance(student, 'homework'),
                ),
                // زر السلوك
                _buildActionButton(
                  'سلوك',
                  Icons.warning,
                  Colors.red,
                  () => _showBehaviorDialog(student),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // مكون زر الإجراء
  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  // دالة لعرض مربع حوار إضافة طالب جديد
  void _showAddStudentDialog() {
    String studentName = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('إضافة طالب جديد'),
          content: TextField(
            onChanged: (value) => studentName = value,
            decoration: const InputDecoration(hintText: "اسم الطالب"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('إضافة'),
              onPressed: () async {
                if (studentName.isNotEmpty) {
                  try {
                    await _studentService.addStudent(widget.classModel.id, studentName);
                    setState(() {
                      // إعادة تحميل قائمة الطلاب
                      _studentsFuture = _fetchStudents();
                    });
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('فشل الإضافة: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // دالة لعرض إعدادات الفصل
  void _showClassSettings() {
    // هنا يمكن إضافة شاشة لإدارة الطلاب (حذف، تعديل) وتصفير النقاط
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('شاشة إدارة الفصل وتصفير النقاط قيد التطوير...')),
    );
  }

  // دالة لعرض مربع حوار السلوك (إيجابي/سلبي)
  void _showBehaviorDialog(Student student) {
    String note = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تسجيل سلوك لـ ${student.name}'),
          content: TextField(
            onChanged: (value) => note = value,
            decoration: const InputDecoration(hintText: "اكتب الملاحظة (إيجابية أو سلبية)"),
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('سلوك سلبي (-)', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _logPerformance(student, 'behavior', note: note, points: -5); // -5 نقطة افتراضية
              },
            ),
            TextButton(
              child: const Text('سلوك إيجابي (+)', style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.of(context).pop();
                _logPerformance(student, 'behavior', note: note, points: 5); // +5 نقطة افتراضية
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classModel.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddStudentDialog,
            tooltip: 'إضافة طالب',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showClassSettings,
            tooltip: 'إدارة الفصل',
          ),
        ],
      ),
      body: FutureBuilder<List<Student>>(
        future: _studentsFuture,
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
                    const Text('لا يوجد طلاب في هذا الفصل.'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _showAddStudentDialog,
                      icon: const Icon(Icons.person_add),
                      label: const Text('أضف أول طالب'),
                    ),
                  ],
                ));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final student = snapshot.data![index];
              return _buildStudentTile(student);
            },
          );
        },
      ),
      // شريط التنقل السفلي الخاص بالفصل
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'قائمة الطلاب',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'لوحة الصدارة',
          ),
        ],
        currentIndex: 0, // قائمة الطلاب هي الافتراضية
        onTap: (index) {
          if (index == 1) {
            // توجيه إلى لوحة الصدارة
          }
        },
      ),
    );
  }
}
