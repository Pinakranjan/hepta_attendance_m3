import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config.dart';

class DioHelper {
  final Dio api = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 25),
      baseUrl: "http://${Config.apiURL}",
    ),
  );

  DioHelper() {
    api.interceptors.add(InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
        // if (!options.path.contains('http')) {
        //   options.path = 'http://192.168.0.20:8080' + options.path;
        // }
        if (options.headers['requires-token'] == true) {
          // In case of retry it will not enter in this loop
          try {
            // Clear previous header and update it with updated token
            options.headers.clear();

            // options.headers['Authorization'] = 'Bearer ${loginDetails!.data.accessToken}';
            options.headers['Content-Type'] = 'application/json';
            options.headers['Connection'] = 'Keep-Alive';
          } catch (e) {
            if (kDebugMode) {
              print(e);
            }
          }
        }

        return handler.next(options);
      },
      onResponse: (Response response, ResponseInterceptorHandler handler) async {
        return handler.next(response);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        if (kDebugMode) {
          print(error);
          print('hi');
          print(error.response?.data);
        }

        if (error.type == DioExceptionType.unknown) {
          if (error.toString().contains('SocketException')) {
            return handler.reject(error);
          } else {
            try {
              return handler.resolve(await _retry(error.requestOptions));
            } on DioException catch (e) {
              return handler.next(e);
            }
          }
        } else if (error.type == DioExceptionType.connectionTimeout) {
          return handler.reject(error);
        } else if (error.type == DioExceptionType.badResponse) {
          return handler.reject(error);
        }

        return handler.next(error);
      },
    ));
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    FormData formData = FormData();

    //======================================================================
    // Check if No FormData Provided its working or not=====================
    //======================================================================
    if (requestOptions.data is FormData) {
      formData.fields.addAll(requestOptions.data.fields);

      for (MapEntry mapFile in requestOptions.data.files) {
        formData.files.add(MapEntry(
          mapFile.key,
          await MultipartFile.fromFile((mapFile.value as MultipartFile).filename ?? "", filename: "${(mapFile.value as MultipartFile).filename}"),
        ));
      }

      // requestOptions.data = formData;
    }

    return api.request<dynamic>(requestOptions.path, data: formData, queryParameters: requestOptions.queryParameters, options: options);
  }
}
