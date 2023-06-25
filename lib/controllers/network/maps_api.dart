import 'dart:developer';

import 'package:dio/dio.dart';

import '../../domain/models/geocoder_model.dart';
import '../../domain/models/nearest_doctors_places_model.dart';

class MapsAPI {
  static String apiKey = 'AIzaSyD_u0bRQjlEfAC18puxXqUlh8z5gEqyy6o';
  static Dio dio =
      Dio(BaseOptions(baseUrl: 'https://maps.googleapis.com/maps/api/'));

  static Future<MapsModel?> fetchNearPlaces(
      double latitude, double longitude
      ) async {
    Response result =
        await dio.get('place/nearbysearch/json', queryParameters: {
      "keyword": "doctor",
      "location": "$latitude,$longitude",
      "radius": "1500",
      "type": "doctor",
      "key": apiKey
    });
    if (result.statusCode == 200) {
      // log(MapsModel.fromJson(result.data).toJson().toString());
      return MapsModel.fromJson(result.data);
    }
    return null;
  }

  static Future<GeocoderModel?> getCurrentAddressFromLocation(
      double latitude, double longitude) async {
    Response result = await dio.get('geocode/json',
        queryParameters: {"latlng": "$latitude,$longitude", "key": apiKey}
    );
    if (result.statusCode == 200) {
      log(GeocoderModel.fromJson(result.data).toJson().toString());
      return GeocoderModel.fromJson(result.data);
    }
    return null;
  }
}
