import 'package:supabase_flutter/supabase_flutter.dart';

class StudentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> addStudent(String classId, String studentName) async {
    final response = await _supabase.from('students').insert({
      'class_id': classId,
      'student_name': studentName,
    });

    if (response.error != null) {
      throw Exception(response.error!.message);
    }
  }
}
