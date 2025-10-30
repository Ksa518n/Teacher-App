class Student {
  final String id;
  final String classId;
  final String name;

  Student({
    required this.id,
    required this.classId,
    required this.name,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      classId: json['class_id'] as String,
      name: json['student_name'] as String,
    );
  }
}
