import 'dart:developer';

import 'package:dio/dio.dart';

class FirebaseDatabaseAPI {
  static Dio dio = Dio(BaseOptions(
    baseUrl: 'https://health-diagnosis-94ee9-default-rtdb.firebaseio.com/',
    responseType: ResponseType.json,
  ));
  static Response? result;

  static Stream<dynamic> getHeartRate() async* {
    yield* Stream.periodic(const Duration(seconds: 1), (_) async {
      result = await dio.get('heartRate.json');
      log(result!.data);
      return await result?.data;
    }).asyncMap((event) async => await event);
  }
}
