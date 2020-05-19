import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat_laravel/models/lt_models.dart';

const String ROOT_ENDPOINT = 'http://sexybaby.sinka.vn/api';

bool trustSelfSigned = false;

class ApiException implements Exception {
  final String cause;
  ApiException({@required this.cause}) : assert(cause != null);
}

class RestNetworkManager {
  static RestNetworkManager _singleton;
  factory RestNetworkManager() {
    if (_singleton == null) {
      var restNetworkManager = RestNetworkManager._();
      _singleton = restNetworkManager;
    }
    return _singleton;
  }

  final Dio dio = Dio();
  RestNetworkManager._() {
    // certificate content
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  ResponseModel responseModel;

  final Map<String, String> headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  Future<dynamic> post(
      {@required String endpoint, Map<String, dynamic> body}) async {
    final String url = "$ROOT_ENDPOINT$endpoint";
    // final jsonBody = json.encode(body);

    // add more cookie of session due to server required
    headers['Authorization'] =
        "Bearer ${AuthRepository().authModel?.authToken}";

    final Options opt = Options(
      headers: headers,
    );

    try {
      final response = await dio.post(url, data: body, options: opt);

      if (response.statusCode == 200) {
        this.responseModel = ResponseModel.fromJson(response.data);
        debugPrint('auth_token: ${responseModel?.auth?.authToken}');

        if (this.responseModel.auth?.authToken != '' &&
            this.responseModel.auth?.authToken !=
                AuthRepository().authModel?.authToken) {
          AuthRepository().authModel = responseModel?.auth;
          AuthRepository().cacheAuthData();
        }
      }

      if (response.statusCode == 403 ||
          this.responseModel.auth?.authToken == null) {
        AuthRepository().clearAuth();
        this.responseModel =
            ResponseModel(code: "403", message: "Unauthorized");
      }
    } on DioError catch (e) {
      _handleError(e);
    }

    return this.responseModel;
  }

  Future<dynamic> postFormData(
      {@required String endpoint, Map<String, dynamic> body}) async {
    final String url = "$ROOT_ENDPOINT$endpoint";
    // final jsonBody = json.encode(body);

    // add more cookie of session due to server required
    headers['Authorization'] =
        "Bearer ${AuthRepository().authModel?.authToken}";

    final Options opt = Options(
      headers: headers,
    );

    try {
      // form data
      FormData formData = new FormData.fromMap(body);

      final response = await dio.post(url, data: formData, options: opt);

      if (response.statusCode == 200) {
        this.responseModel = ResponseModel.fromJson(response.data);
        debugPrint('auth_token: ${responseModel?.auth?.authToken}');

        if (this.responseModel.auth?.authToken != '' &&
            this.responseModel.auth?.authToken !=
                AuthRepository().authModel?.authToken) {
          AuthRepository().authModel = responseModel?.auth;
          AuthRepository().cacheAuthData();
        }
      }

      if (response.statusCode == 403 ||
          this.responseModel.auth?.authToken == null) {
        AuthRepository().clearAuth();
        this.responseModel =
            ResponseModel(code: "403", message: "Unauthorized");
      }
    } on DioError catch (e) {
      _handleError(e);
    }

    return this.responseModel;
  }

  Future<dynamic> get(
      {@required String endpoint, Map<String, dynamic> queryParameters}) async {
    final String url = "$ROOT_ENDPOINT$endpoint";

    // add more cookie of session due to server required
    headers['Authorization'] =
        "Bearer ${AuthRepository().authModel?.authToken}";

    final Options opt = Options(
      headers: headers,
    );

    try {
      final response =
          await dio.get(url, options: opt, queryParameters: queryParameters);

      if (response.statusCode == 200) {
        this.responseModel = ResponseModel.fromJson(response.data);
        debugPrint('auth_token: ${responseModel?.auth?.authToken}');

        if (this.responseModel.auth?.authToken != '' &&
            this.responseModel.auth?.authToken !=
                AuthRepository().authModel?.authToken) {
          AuthRepository().authModel = responseModel?.auth;
          AuthRepository().cacheAuthData();
        }
      }

      if (response.statusCode == 403 ||
          this.responseModel.auth?.authToken == null) {
        AuthRepository().clearAuth();
        this.responseModel =
            ResponseModel(code: "403", message: "Unauthorized");
      }
    } on DioError catch (e) {
      _handleError(e);
    }

    return this.responseModel;
  }

  _handleError(DioError error) {
    String errorDescription = "";
    String code = "";
    if (error is DioError) {
      switch (error.type) {
        case DioErrorType.CANCEL:
          errorDescription = "Request to API server was cancelled";
          code = "CANCEL";
          break;
        case DioErrorType.CONNECT_TIMEOUT:
          errorDescription = "Connection timeout with API server";
          code = "CONNECT_TIMEOUT";
          break;
        case DioErrorType.RECEIVE_TIMEOUT:
          errorDescription = "Receive timeout in connection with API server";
          code = "RECEIVE_TIMEOUT";
          break;
        case DioErrorType.RESPONSE:
          errorDescription =
              "Received invalid status code: ${error.response.statusCode}";
          code = "INVALID_RESPONSE";
          break;
        case DioErrorType.DEFAULT:
        default:
          errorDescription =
              "Connection to API server failed due to internet connection";
          code = "DEFAULT";
          break;
      }
    } else {
      code = "UNKNOWN";
      errorDescription = "Unexpected error occured";
    }
    this.responseModel = ResponseModel(code: code, message: errorDescription);
  }
}
