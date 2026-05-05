import 'package:connectivity_plus/connectivity_plus.dart';

/// واجهة برمجية (Interface) للتحقق من حالة الاتصال بالإنترنت
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// التنفيذ الفعلي لواجهة التحقق من الاتصال باستخدام مكتبة connectivity_plus
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    // التحقق من حالة الاتصال (واي فاي، بيانات جوال، أو لا يوجد اتصال)
    final result = await connectivity.checkConnectivity();
    
    // إذا كانت النتيجة لا تحتوي على "none"، فهذا يعني أن الجهاز متصل بشبكة ما
    return !result.contains(ConnectivityResult.none);
  }
}