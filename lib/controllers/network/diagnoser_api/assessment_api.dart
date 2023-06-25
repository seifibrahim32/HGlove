import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:health_diagnosis/domain/models/diseases_model.dart';
import 'package:health_diagnosis/domain/models/result_model.dart';

import '../../../domain/models/questions_model.dart';

class AssessmentAPI {
  static Dio dio = Dio(BaseOptions(
    baseUrl: 'https://api.endlessmedical.com/v1/dx/',
  ));

  static late Response res;

  static late String status;

  static String passphrase =
      'I have read, understood and I accept and agree to '
      'comply with the Terms of Use of EndlessMedicalAPI and '
      'Endless Medical services. '
      'The Terms of Use are available on endlessmedical.com';

  static late String sessionID;

  static Future initializeSession() async {
    res = await dio.get('InitSession');
    try {
      if (res.statusCode == 200) {
        sessionID = res.data['SessionID'];
        return sessionID;
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<String> selfAcceptTermsOfUse(String sessionID) async {
    res = await dio.post('AcceptTermsOfUse', queryParameters: {
      'sessionID': sessionID,
      'passphrase': passphrase,
    });
    try {
      if (res.statusCode == 200) {
        status = res.data["status"];
      }
      return status;
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<QuestionsModel> retrieveQuestions() async {
    try {
      final json = await rootBundle.loadString('assets/Questions'
          'Assessment.json');
      final questions = await compute((message) {
        final decodedQuestions = jsonDecode(message);
        return decodedQuestions;
      }, json);

      return QuestionsModel.fromJson(questions);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<Response>? updateFeature(String name, String value) async {
    print("Updating...");
    try {
      res = await dio.post('UpdateFeature', queryParameters: {
        'SessionID': sessionID,
        'name': name,
        'value': value
      });
      if (res.statusCode == 200) {
        print(res.data);
      } else
        print(res.data);
      return res;
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<ResultModel> analyze() async {
    try {
      res = await dio.get('Analyze', queryParameters: {
        'SessionID': sessionID,
        'NumberOfResults': 10,
        'ResponseFormat': ' '
      });
      if (res.statusCode == 200) {
        print(res.data);
      }
      return ResultModel.fromJson(res.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<DiseasesInfoModel?> getDiseasesInfo() async {
    try {
      final json = await rootBundle.loadString('assets/DiseasesInfo.json');
      final questions = await compute((message) {
        final decodedQuestions = jsonDecode(message);
        return decodedQuestions;
      }, json);
      if (questions != null) {
        print(questions);
        return DiseasesInfoModel.fromJson(questions);
      }
    } catch (e) {
      throw Exception(e);
    }
    return null;
  }
}
