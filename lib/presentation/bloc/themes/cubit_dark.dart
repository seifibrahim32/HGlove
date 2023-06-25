import 'package:bloc/bloc.dart';
import 'package:health_diagnosis/presentation/bloc/themes/theme_states.dart';
class ThemeDark extends Cubit<ThemeStates> {
  ThemeDark() : super(LightMode());

  changeDark(bool value) {}
}
