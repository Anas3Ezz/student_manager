import 'package:hugeicons/hugeicons.dart';

/// Icon data from the Hugeicons stroke-rounded set.
typedef AppIconData = List<List<dynamic>>;

/// Every icon the app uses, in one place so the set stays consistent.
abstract final class AppIcons {
  // Navigation
  static const AppIconData students = HugeIcons.strokeRoundedUserGroup;
  static const AppIconData subjects = HugeIcons.strokeRoundedBookOpen01;
  static const AppIconData settings = HugeIcons.strokeRoundedSettings02;

  // Directional (mirror in RTL via AppIcon.mirrorInRtl)
  static const AppIconData back = HugeIcons.strokeRoundedArrowLeft01;
  static const AppIconData previous = HugeIcons.strokeRoundedArrowLeft01;
  static const AppIconData next = HugeIcons.strokeRoundedArrowRight01;

  // Actions
  static const AppIconData add = HugeIcons.strokeRoundedAdd01;
  static const AppIconData addStudent = HugeIcons.strokeRoundedUserAdd01;
  static const AppIconData edit = HugeIcons.strokeRoundedPencilEdit02;
  static const AppIconData delete = HugeIcons.strokeRoundedDelete02;
  static const AppIconData search = HugeIcons.strokeRoundedSearch01;
  static const AppIconData clear = HugeIcons.strokeRoundedCancel01;
  static const AppIconData more = HugeIcons.strokeRoundedMoreVertical;
  static const AppIconData manage = HugeIcons.strokeRoundedPreferenceHorizontal;
  static const AppIconData logSession = HugeIcons.strokeRoundedNoteEdit;
  static const AppIconData check = HugeIcons.strokeRoundedTick02;
  static const AppIconData checkCircle =
      HugeIcons.strokeRoundedCheckmarkCircle02;

  // Content
  static const AppIconData phone = HugeIcons.strokeRoundedCall;
  static const AppIconData calendar = HugeIcons.strokeRoundedCalendar03;
  static const AppIconData error = HugeIcons.strokeRoundedAlert02;

  // Theme modes
  static const AppIconData systemMode = HugeIcons.strokeRoundedSmartPhone01;
  static const AppIconData lightMode = HugeIcons.strokeRoundedSun03;
  static const AppIconData darkMode = HugeIcons.strokeRoundedMoon02;
}
