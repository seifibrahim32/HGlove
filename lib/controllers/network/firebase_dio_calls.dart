import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../presentation/views/dashboard_screen.dart';
import '../../presentation/views/snackbar.dart';
import '../services/services.dart';

class Resource {
  final Status status;

  Resource({required this.status});
}

enum Status { success, error, cancelled }

class FirebaseAPI {
  static Dio dio = Dio();
  static String apiKey = 'AIzaSyDLRQbUtaWBP1iRMXJQ8cwr9wfbhwdLHpA';
  static Response? res;
  static final firebaseAuth = FirebaseAuth.instance;
  static final instanceFirebaseFirestore = FirebaseFirestore.instance;

  static signInWithEmailAndPassword(
      {required String email,
      required String password,
      required BuildContext context}) async {
    var token = await signIn(email, password);
    if (token != null) {
      await instanceFirebaseFirestore
          .collection('users')
          .get()
          .then((snapshot) async {
        for (var doc in snapshot.docs) {
          var userData = doc.data();
          if (userData['uid'] == token) {
            var storedData = await SharedPreferences.getInstance();
            await storedData.setInt(
                'phoneNumbersCount', userData['phoneNumbersCount']);
            await storedData.setString(
                'username', "${userData["firstName"]} ${userData["lastName"]}");
            for (int i = 0; i < userData['phoneNumbersCount']; i++) {
              await storedData.setString(
                  "phoneNumber_$i", userData["phoneNumber_$i"]);
            }
            await storedData.setString("email", userData["email"]);
            await storedData.setString("uid", token).whenComplete(() async {
              navigateToDashboard(context);
              try {
                BackgroundServices.enableNotificationService();
              } on PlatformException catch (e) {
                print("error "+e.toString());
              }
            });
            break;
          }
        }
      });
    } else if (token == null) {
      throw Exception();
    }
  }

  static Future<String?>? signIn(String email, String password) async {
    dio.options.baseUrl = 'https://identitytoolkit.googleapis.com/v1/accounts:';
    dio.options.responseType = ResponseType.json;
    dio.options.queryParameters = {'key': apiKey};
    try {
      res = await dio.post('signInWithPassword', data: {
        'email': email.toString(),
        'password': password.toString(),
        'returnSecureToken': 'true'
      });
      if (res?.statusCode == 200) {
        return await res?.data['localId'];
      }
    } on DioError catch (e) {
      log(res?.data);
      log("error ${e.message}");
      return null;
    }
    return null;
  }

  static navigateToDashboard(BuildContext context) async {
    await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const DashboardScreen(),
          transitionDuration: const Duration(seconds: 2),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;
            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );
            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: child,
            );
          },
        ));
  }

  static googleSignIn(BuildContext context) async {
    final GoogleSignIn googleSignIn =
        GoogleSignIn(scopes: ['email'], signInOption: SignInOption.standard);
    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      GoogleSignInAuthentication? googleSignInAuthentication =
          await googleSignInAccount.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      try {
        final authResult = await firebaseAuth.signInWithCredential(credential);
        final instance = await SharedPreferences.getInstance();

        String googleEmail = authResult.user!.providerData.single.email!;
        await instance.setString('email', googleEmail);

        String googlePhotoURL = authResult.user!.photoURL!;
        await instance.setString('photo', googlePhotoURL);

        String userName = authResult.additionalUserInfo?.profile!['name'];
        instance.setString('username', userName).whenComplete(() {
          showSnackBar(context, 'Successfully signed', Colors.green);
          Navigator.of(context).pushReplacementNamed('/dashboard');
        });
      } on FirebaseAuthException catch (error) {
        throw Exception(error);
      } catch (error) {
        throw Exception(error);
      }
    }
  }

  static Future signInWithFacebook(BuildContext context) async {
    if (kIsWeb) {
      // initialize the facebook javascript SDK
      await FacebookAuth.i.webAndDesktopInitialize(
          appId: "821582055832295",
          cookie: true,
          xfbml: true,
          version: "v15.0");
      log((await FacebookAuth.i.accessToken) as String);
      final facebookCredential = FacebookAuthProvider.credential('');
      // Once signed in, return the UserCredential
      final cred = await firebaseAuth.signInWithCredential(facebookCredential);
      log(cred.user!.displayName as String);
      log(cred.user?.email as String);
      log(cred.user?.photoURL as String);
      FacebookAuth.i.accessToken;
      // initialize the facebook javascript SDK
      log(FacebookAuth.i.isWebSdkInitialized.toString());
    }
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      switch (result.status) {
        case LoginStatus.success:
          final AuthCredential facebookCredential =
              FacebookAuthProvider.credential(result.accessToken!.token);
          final userCredential =
              await firebaseAuth.signInWithCredential(facebookCredential);

          final setEmail = await SharedPreferences.getInstance();
          await setEmail.setString(
              'email', userCredential.user!.providerData.single.email!);

          final setPhoto = await SharedPreferences.getInstance();
          await setPhoto.setString('photo', userCredential.user!.photoURL!);

          final setUsername = await SharedPreferences.getInstance();
          setUsername
              .setString('username',
                  userCredential.additionalUserInfo?.profile!['name'])
              .whenComplete(
                  () => Navigator.pushReplacementNamed(context, '/dashboard'));

          return Resource(status: Status.success);
        case LoginStatus.cancelled:
          throw Resource(status: Status.cancelled);
        case LoginStatus.failed:
          throw Resource(status: Status.error);
        default:
          return null;
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e);
    }
  }
}
