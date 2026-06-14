import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  late Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://medicalhouse-ye.net/api/',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(
          seconds: 60,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final prefs = await SharedPreferences.getInstance();
            String? laravelToken = prefs.getString('access_token');

            if (laravelToken != null && laravelToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $laravelToken';
            } else {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                String? firebaseToken = await user.getIdToken();
                if (firebaseToken != null) {
                  options.headers['Authorization'] = 'Bearer $firebaseToken';

                  if (options.method == 'POST') {
                    if (options.data is FormData) {
                      (options.data as FormData).fields.add(
                        MapEntry("idToken", firebaseToken),
                      );
                    } else if (options.data is Map) {
                      options.data['idToken'] = firebaseToken;
                    } else {
                      options.data = {"idToken": firebaseToken};
                    }
                  }
                }
              }
            }
          } catch (e) {
          }
          return handler.next(options);
        },
      ),
    );
  }
}
