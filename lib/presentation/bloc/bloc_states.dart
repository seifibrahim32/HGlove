import 'dart:typed_data';

abstract class ScreenStates {}

class LoadingScreenState extends ScreenStates {}

class LoginScreenState extends ScreenStates {}

class CreateNewAccountScreenState extends ScreenStates {}

class SettingsScreenState extends ScreenStates {}

abstract class CheckboxTermsStates {}

class CheckboxTermsStatesUnClicked extends CheckboxTermsStates {}

class CheckboxTermsStatesClicked extends CheckboxTermsStates {}

abstract class ImageRegisterScreenStates {}

class ImageUnpickedState extends ImageRegisterScreenStates {}

class ImagePickedState extends ImageRegisterScreenStates {
  String path = "";

  //For web
  Uint8List? fileBytes;

  ImagePickedState(this.path);

  ImagePickedState.fromWeb(this.fileBytes);
}

// ........

abstract class EditProfileStates {}

class ProfileDataIsNotFetched extends EditProfileStates {}

class ProfileDataIsEdited extends EditProfileStates {}

class ProfilePhotoChanged extends EditProfileStates {}

// ........ During diagnosing

abstract class AssessmentStates {}

class CheckConnectivityState extends AssessmentStates {}

class ConnectivityInvalidState extends AssessmentStates {}

class SessionInitializingState extends AssessmentStates {}

class SessionInitializedState extends AssessmentStates {}

class AcceptingTermsAndConditionsState extends AssessmentStates {}

class PreparingQuestionsState extends AssessmentStates {}

class QuestionsShownState extends AssessmentStates {}

class StoreDiseasesState extends AssessmentStates {}

class AssessmentAnalyzingState extends AssessmentStates {}

class AssessmentAnalyzedState extends AssessmentStates {}

// ........

abstract class SettingsScreenStates {}

class ProfileDetailsNotFetched extends SettingsScreenStates {}

class DarkMode extends SettingsScreenStates {}

class LanguagesState extends SettingsScreenStates {}

class ProfileDetailsFetched extends SettingsScreenStates {}

abstract class OverviewStates {}

class AppBarDetailsNotFetched extends OverviewStates {}

class AppBarDetailsFetched extends OverviewStates {}
