import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:geolocator/geolocator.dart';
import 'package:health_diagnosis/presentation/bloc/bloc_observer.dart';
import 'package:health_diagnosis/presentation/views/app_start/splash_screen'
    '.dart';
import 'package:health_diagnosis/presentation/views/dashboard_screen.dart';
import 'package:health_diagnosis/presentation/views/maps/maps_screen.dart';
import 'package:health_diagnosis/presentation/views/registration/login_screen'
    '.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  if (Platform.isAndroid) {
    await Geolocator.checkPermission().then((permission) async {
      switch (permission) {
        case LocationPermission.denied:
        case LocationPermission.unableToDetermine:
        case LocationPermission.deniedForever:
          checkPermission();
          break;
        case LocationPermission.whileInUse:
        case LocationPermission.always:
          navigate();
          break;
      }
    });
  } else {
    // later ....
  }
}

void checkPermission() async =>
    await Geolocator.requestPermission().whenComplete(() => navigate());

void navigate() async {
  Bloc.observer = EventObserver();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  //Already Logged In
  if (prefs.getString('username') != null) {
    runApp(MaterialApp(
        scrollBehavior: MyCustomScrollBehavior(),
        theme: ThemeData(
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => const DashboardScreen(),
          '/login': (context) => const LoginScreen(),
          '/maps-screen': (c) {
            final arguments = (ModalRoute.of(c)?.settings.arguments ??
                <String, dynamic>{}) as Map;
            log("arguments main.dart [Logged]: ${arguments.toString()}");
            return MapsScreen(kind: arguments['type']);
          },
        }));
  }
  //Not logged in
  else {
    runApp(MaterialApp(debugShowCheckedModeBanner: false, routes: {
      '/': (context) => const SplashScreen(),
      '/login': (context) => const LoginScreen(),
      '/maps-screen': (c) {
        final arguments = (ModalRoute.of(c)?.settings.arguments ??
            <String, dynamic>{}) as Map;
        log("arguments main.dart [Not Logged in]: ${arguments.toString()}");
        return MapsScreen(kind: arguments['type']);
      },
    }));
  }
}
