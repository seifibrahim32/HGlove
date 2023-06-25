import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:health_diagnosis/domain/models/diseases_model.dart';
import 'package:health_diagnosis/domain/models/questions_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/files/file_controllers.dart';
import '../../controllers/network/diagnoser_api/assessment_api.dart';
import '../../domain/models/result_model.dart';
import 'bloc_states.dart';

class RegistrationCubit extends Cubit<ScreenStates> {
  Connectivity connectivity = Connectivity();

  RegistrationCubit() : super(LoadingScreenState());

  connectInternet() async {
    if (kIsWeb) {
      var connectivityResult = await (connectivity.checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile &&
          state is LoadingScreenState) {
        gotoLoginScreen();
        log("network available using mobile");
      } else if (connectivityResult == ConnectivityResult.wifi &&
          state is LoadingScreenState) {
        gotoLoginScreen();
        log("network available using wifi");
      } else if (state is LoadingScreenState ||
          connectivityResult == ConnectivityResult.none) {
        emit(LoadingScreenState());
        log("network not available");
      }
    } else {
      await connectivity.checkConnectivity().then((connectivityResult) {
        if (connectivityResult == ConnectivityResult.mobile) {
          log(connectivityResult.name);
          gotoLoginScreen();
        } else if (connectivityResult == ConnectivityResult.wifi) {
          log(connectivityResult.name);
          gotoLoginScreen();
        } else {
          log('Not connected to any network...');
          log(connectivityResult.name);
          emit(LoadingScreenState());
        }
      });
    }
  }

  gotoRegisterScreen() {
    emit(CreateNewAccountScreenState());
  }

  gotoLoginScreen() {
    emit(LoginScreenState());
  }
}

class TermsCubit extends Cubit<CheckboxTermsStates> {
  TermsCubit() : super(CheckboxTermsStatesUnClicked());

  uncheck() {
    emit(CheckboxTermsStatesUnClicked());
  }

  check() {
    emit(CheckboxTermsStatesClicked());
  }
}

class PhotoRegistrationCubit extends Cubit<ImageRegisterScreenStates> {
  PhotoRegistrationCubit() : super(ImageUnpickedState());

  pickWeb({Uint8List? fileBytes}) {
    emit(ImagePickedState.fromWeb(fileBytes));
  }

  pick(String? filePath) {
    emit(ImagePickedState(filePath!));
  }
}

class EditProfileCubit extends Cubit<EditProfileStates> {
  EditProfileCubit() : super(ProfileDataIsNotFetched());
  static String photoLink = ' ';
  static String firstName = ' ';
  static String lastName = ' ';
  static String emergencyNumber = ' ';

  void fetchData() async {
    var data = await SharedPreferences.getInstance();
    firstName = data.get('username').toString().split(RegExp(' '))[0];
    lastName = data.get('username').toString().split(RegExp(' '))[1];
    emergencyNumber = data.get('phoneNumber_0').toString();
    log("firstName $firstName");
    log("lastName $lastName");
    log("emergencyNumber_0 $emergencyNumber");
    photoLink = data.getString('photo')!;
    emit(ProfileDataIsEdited());
  }

  void change(BuildContext context) async {
    photoLink = (await filePicker(context))!;
    var checkPhoto = await SharedPreferences.getInstance();
    checkPhoto.setString('photo', photoLink);
    log(photoLink);
    emit(ProfilePhotoChanged());
  }
}

class AssessmentCubit extends Cubit<AssessmentStates> {
  late Stream<ConnectivityResult> streamConnectivity;

  late StreamSubscription streamSubscriber;

  late String sessionIDArg;

  Connectivity connectivity = Connectivity();

  List<Questions> questions = [];

  List<Diseases> diseases = [];

  List<DiseasesInfo> diseasesInfo = [];

  AssessmentCubit() : super(CheckConnectivityState());

  void checkConnectivity() async {
    streamConnectivity = connectivity.onConnectivityChanged;
    streamSubscriber = streamConnectivity.listen((result) {
      log(result.name);
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        emit(SessionInitializingState());
      } else {
        emit(ConnectivityInvalidState());
      }
    });
  }

  Future closeInternetSubscription() async {
    await streamSubscriber.cancel();
  }

  void navigate() {
    if (state is SessionInitializingState) {
      AssessmentAPI.initializeSession().then((sessionID) {
        sessionIDArg = sessionID;
        log(sessionIDArg);
        emit(SessionInitializedState());
      });
    } else if (state is SessionInitializedState) {
      emit(AcceptingTermsAndConditionsState());
    } else if (state is QuestionsShownState) {
      emit(AssessmentAnalyzingState());
      AssessmentAPI.analyze().then((list) {
        diseases = list.diseases!;
      }).whenComplete(() => emit(StoreDiseasesState()));
    }
  }

  void storeInDiseasesList() async {
    await AssessmentAPI.getDiseasesInfo().then((value) {
      for (var disease in diseases) {
        for (var info in value!.diseasesInfo) {
          if (info.text == disease.type) {
            diseasesInfo.add(info);
            break;
          }
        }
      }
    }).whenComplete(() async {
      final data = await SharedPreferences.getInstance();
      print("Analyzed");
      await FirebaseFirestore.instance.collection('assessments').add({
        'name' : data.get('username'),
        'time' : DateTime.now(),
        'most_disease' :  diseases.first.type
      });
      emit(AssessmentAnalyzedState());
    });
  }

  void acceptTermsAndConditions() {
    AssessmentAPI.selfAcceptTermsOfUse(sessionIDArg).then((status) {
      log("status: $status");
      emit(PreparingQuestionsState());
    });
  }

  void retrieveQuestions() {
    AssessmentAPI.retrieveQuestions().then((list) {
      questions = list.questions;
      emit(QuestionsShownState());
    });
  }

  @override
  Future<void> close() async {
    await closeInternetSubscription();
    super.close();
  }
}

class SettingsCubit extends Cubit<SettingsScreenStates> {
  SettingsCubit() : super(ProfileDetailsNotFetched());
  static late Future<bool> isDark;
  static String? imageURL, email, username;
  late SharedPreferences storedData;

  fetchData() async {
    storedData = await SharedPreferences.getInstance();
    email = storedData.getString('email');
    log(email.toString());
    await FirebaseStorage.instance
        .ref(email)
        .getDownloadURL()
        .then((url) => imageURL = url);
    username = storedData.getString('username');
    if (username != null && email != null && imageURL != null) {
      emit(ProfileDetailsFetched());
    }
  }

  setDarkMode(bool mode) async {
    storedData = await SharedPreferences.getInstance();
    isDark = storedData.setBool('isDark', mode);
    emit(ProfileDetailsNotFetched());
  }
}

class OverviewCubit extends Cubit<OverviewStates> {
  OverviewCubit() : super(AppBarDetailsNotFetched());
  static String? username;

  fetchData() async {
    var storedData = await SharedPreferences.getInstance();
    username = storedData.getString('username');
    emit(AppBarDetailsFetched());
  }
}
