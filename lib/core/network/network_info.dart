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
    final result = await connectivity.checkConnectivity();
    
    return !result.contains(ConnectivityResult.none);
  }
}
