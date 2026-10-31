abstract final class AppRoutes {
  static const students = '/students';
  static const newStudent = '/students/new';
  static const subjects = '/subjects';
  static const settings = '/settings';

  static String student(int id) => '/students/$id';
  static String editStudent(int id) => '/students/$id/edit';
  static String subject(int id) => '/subjects/$id';
}
