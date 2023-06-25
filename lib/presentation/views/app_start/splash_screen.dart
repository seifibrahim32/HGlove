import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:oauth_dio/oauth_dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../controllers/client_credentials.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  late Response res;
  late Dio dio;

  dynamic accessToken = '';
  late SharedPreferences sharedPreferences;

  persistData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    accessToken = sharedPreferences.getString('accessToken');
  }

  @override
  void initState() {
    super.initState();
    navigateToLogin();
    // persistData();
  }

  navigateToLogin() {
    var counter = 10;
    Timer.periodic(
      const Duration(milliseconds: 10),
      (timer) async {
        counter--;
        if (counter == 0) {
          timer.cancel();
          await Navigator.of(context).pushReplacementNamed('/login');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    //fetchData();
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/caduceus.png',scale: 4),
                const SizedBox(height: 50),
                const Text('HGlove',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontFamily: 'SF',
                        fontWeight: FontWeight.w700
                    )
                ),
                const SizedBox(height: 50),
                const Text('Please wait ...',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'SF',
                      fontSize: 30,
                    )
                ),
                const SizedBox(height: 50),
                const CircularProgressIndicator(
                  color: Colors.black,
                )
              ]),
        ));
  }

  Future fetchData() async {
    dio = Dio(
      BaseOptions(
          baseUrl: 'https://id.who.int/icd/',
          contentType: 'application/json',
          headers: {
            'Accept': 'application/json',
            'Accept-Language': 'en',
            'API-Version': 'v2',
            'Authorization': 'Bearer $accessToken'
          }),
    );
    try {
      res = await dio.get('entity/145723401');
      if (res.statusCode == 200) {
        log(res.data);
        fetchDatabase(res.data["child"], res.data["child"].length - 1);
      }
    } on DioError catch (e) {
      log(e.toString());
      final oauth = OAuth(
          clientId: 'f7e19660-5f87-4fc5-9f38-e30edc0ea657_470e57c7-bc5f-4d58-9'
              'a52-0e6f9e090122',
          clientSecret: 'SmTnKf0ryU0NVUXS8Ue324n0DKD3ynoP10abQBA0W2E=',
          tokenUrl: 'https://icdaccessmanagement.who.int/connect/token');
      oauth.dio.interceptors.add(BearerInterceptor(oauth));
      final token = await oauth.requestToken(ClientCredentialsGrant(
        scope: ['icdapi_access'],
      ));
      accessToken = token.accessToken;
      sharedPreferences.setString('accessToken', token.accessToken!);
      log(token.accessToken.toString());
    }
  }

  fetchDatabase(List<dynamic> data, int index) async {
    if (data.isEmpty || index < 0) {
      return;
    } else {
      try {
        log(Uri.parse(data[index]).pathSegments.toString());
        log(res.data['child']);
        res =
            await dio.get('entity/${Uri.parse(data[index]).pathSegments.last}');

        data = res.data['child'] ?? [];
        if (data.isEmpty) {
          log('data has no children');
          if (res.data['definition'] != null &&
              res.data['title']['@value'] != null) {
            await FirebaseFirestore.instance.collection('diseases').add({
              'disease': res.data['title']['@value'],
              'definition': res.data['definition']['@value']
            });
          }
        } else {
          index = data.length;
          for (int i = index - 1; i >= 0; i--) {
            log(data[i]);
            log(i as String);
            fetchDatabase(data, --i);
          }
          log(res.data["definition"]);
          if (res.data['definition'] != null &&
              res.data['title']['@value'] != null) {
            await FirebaseFirestore.instance.collection('diseases').add({
              'disease': res.data['title']['@value'],
              'definition': res.data['definition']['@value']
            });
          }
        }
      } on DioError {
        // print(e);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
