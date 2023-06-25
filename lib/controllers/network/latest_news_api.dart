import 'package:dio/dio.dart';

import '../../domain/models/health_articles_model.dart';

class LatestNewsAPI {
  static String apiKey = 'fed9a9dac524473997a33eca63fc120a';
  static Dio dio = Dio(BaseOptions(
      baseUrl: 'https://newsapi.org/v2/',
      responseType: ResponseType.json,
      queryParameters: {
        'q': '"MEDICAL" OR "صحة" NOT VIRGINIA ',
        'apiKey': apiKey,
        'domains': 'news-medical.net',
        'excludeDomains': 'reuters.com'
      }));
  static Response? result;

  static Future<List<Articles>?> getData() async {
    result = await dio.get('everything');
    print(result!.data['status']);
    return NewsModel.fromJson(result!.data).articles;
  }
}
