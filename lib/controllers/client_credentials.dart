import 'package:dio/dio.dart';
import 'package:oauth_dio/oauth_dio.dart';

class ClientCredentialsGrant extends OAuthGrantType {
  final List<String> scope;

  ClientCredentialsGrant({this.scope = const []});

  /// Prepare Request
  @override
  RequestOptions handle(RequestOptions request) {
    request.data = {
      "grant_type": "client_credentials",
      "scope": scope.join(' ')
    };

    return request;
  }
}
