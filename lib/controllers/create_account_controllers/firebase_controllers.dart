import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../presentation/bloc/bloc_states.dart';
import '../../presentation/views/account_creation_success/welcome_screen.dart';

createUserToFirebase({TextEditingController? email,
    TextEditingController? firstName,
    TextEditingController? lastName,
    List<TextEditingController>? phoneNumbersControllers,
    TextEditingController? password,
    File? file,
    required BuildContext context,
    required ImageRegisterScreenStates stateImage}) async {
  String downloadURL = '';
  Map<String, dynamic> phonesNumbers = {};
  if (stateImage is ImagePickedState) {
    await FirebaseStorage.instance
        .ref()
        .child(email!.text)
        .putFile(file!)
        .then((snapshot) async {
      downloadURL = await snapshot.ref.getDownloadURL();
      log(downloadURL);
    });

    for (var s in phoneNumbersControllers!) {
      phonesNumbers.putIfAbsent(
          "phoneNumber_${phoneNumbersControllers.indexOf(s)}", () => s.value);
    }
    var auth = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text, password: password!.text);
    String? uid = auth.user?.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'email': email.text,
      'firstName': firstName?.text,
      'imageURL': downloadURL,
      'phoneNumbersCount': phoneNumbersControllers.length,
      'lastName': lastName?.text,
      'password': password.text,
      ...phonesNumbers,
      'uid': uid
    }).whenComplete(() => persistNameInCache(
        '${firstName!.text} ${lastName!.text}',
        email.text,
        uid!,
        phoneNumbersControllers,
        context,
        downloadURL));
  } else {
    createFile(email!.text).then((file) async {
      await FirebaseStorage.instance
          .ref()
          .child(email.text.toString())
          .putFile(file)
          .then((snapshot) async {
        downloadURL = await snapshot.ref.getDownloadURL();
        log(downloadURL);
      });
      var auth = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text, password: password!.text);
      String uid = auth.user!.uid;
      Map<String, dynamic> phonesNumbers = {};
      for (var s in phoneNumbersControllers!) {
        phonesNumbers.putIfAbsent(
            "phoneNumber_"
            "${phoneNumbersControllers.indexOf(s)}",
            () => s.text);
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.user?.uid)
          .set({
        'email': email.text,
        'firstName': firstName?.text,
        'imageURL': downloadURL,
        'lastName': lastName?.text,
        'password': password.text,
        ...phonesNumbers,
        'uid': auth.user?.uid
      }).whenComplete(() => persistNameInCache(
              '${firstName!.text} ${lastName!.text}',
              email.text,
              uid,
              phoneNumbersControllers,
              context,
              downloadURL));
    });
  }
}

Future<File> createFile(String email) async {
  final Directory systemTempDir = Directory.systemTemp;
  log(systemTempDir.path);
  final byteData = await rootBundle.load("assets/blank-profile.webp");
  final file = File("${systemTempDir.path}/$email.webp");
  return await file.writeAsBytes(byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
}

void persistNameInCache(
    String userName,
    String email,
    String uid,
    List<TextEditingController> phoneNumbersControllers,
    BuildContext context,
    String downloadURL) {
  saveItInCache(userName, uid, email, phoneNumbersControllers, downloadURL)
      .whenComplete(() => navigateToWelcome(context));
}

Future saveItInCache(
    String userName,
    String uid,
    String email,
    List<TextEditingController> phoneNumbersControllers,
    String downloadURL) async {
  // Obtain shared preferences.
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('username', userName);
  await prefs.setString('uid', uid);
  await prefs.setString('photo', downloadURL);
  await prefs.setString('email', email);
  for (var s in phoneNumbersControllers) {
    await prefs.setString(
        "phoneNumber_${phoneNumbersControllers.indexOf(s)}",
        s.text);
  }
  await prefs.setInt('phoneNumbersCount', phoneNumbersControllers.length);
}

navigateToWelcome(BuildContext context) async {
  await Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const WelcomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ));
}