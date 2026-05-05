import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seiyun_reports_app/core/database/news_local_service.dart';
import 'package:seiyun_reports_app/core/database/reports_local_service.dart';
import 'package:seiyun_reports_app/core/network/api_service.dart';
import 'package:seiyun_reports_app/core/network/dio_client.dart' show DioClient;
import 'package:seiyun_reports_app/core/network/network_info.dart';
import 'package:seiyun_reports_app/screens/auth/view/auth_screen.dart';
import 'package:seiyun_reports_app/screens/citizen_reports/data/citizen_reports_repository.dart';
import 'package:seiyun_reports_app/screens/citizen_reports/data/citizen_reports_service.dart';
import 'package:seiyun_reports_app/screens/home/view/home_screen.dart';
import 'package:seiyun_reports_app/screens/auth/viewmodel/auth_viewmodel.dart';
import 'package:seiyun_reports_app/screens/home/viewmodel/home_viewmodel.dart';
import 'package:seiyun_reports_app/screens/news_tips/data/NewsRepository.dart';
import 'package:seiyun_reports_app/screens/news_tips/data/NewsService.dart';
import 'package:seiyun_reports_app/screens/report/data/report_repository.dart';
import 'package:seiyun_reports_app/screens/report/data/report_service.dart';
import 'package:seiyun_reports_app/screens/report/viewmodel/report_viewmodel.dart';
import 'package:seiyun_reports_app/viewmodels/notification_viewmodel.dart';
import 'package:seiyun_reports_app/screens/news_tips/viewmodel/news_tips_viewmodel.dart';
import 'package:seiyun_reports_app/screens/profile/viewmodel/profile_viewmodel.dart';
import 'package:seiyun_reports_app/screens/citizen_reports/viewmodel/citizen_reports_viewmodel.dart';
import 'package:seiyun_reports_app/screens/pickup_schedules/viewmodel/pickup_schedules_viewmodel.dart';
import 'package:seiyun_reports_app/screens/map/viewmodel/map_viewmodel.dart';
import 'package:seiyun_reports_app/core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => ApiService(DioClient())),
        Provider<NetworkInfo>(create: (_) => NetworkInfoImpl(Connectivity())),
        Provider(create: (_) => ReportsLocalService()),
        Provider(create: (_) => NewsLocalService()),

        ChangeNotifierProvider(
          create:
              (context) => ReportViewModel(
                ReportRepository(
                  ReportService(context.read<ApiService>()),
                  ReportsLocalService(),
                  context.read<NetworkInfo>(),
                ),
              ),
        ),
        ChangeNotifierProvider(
          create:
              (context) => NewsTipsViewModel(
                NewsRepository(
                  Newsservice(context.read<ApiService>()),
                  NewsLocalService(),
                  context.read<NetworkInfo>(),
                ),
              ),
        ),

        ProxyProvider<ApiService, CitizenReportsService>(
          update: (_, api, __) => CitizenReportsService(api),
        ),
        ProxyProvider2<
          CitizenReportsService,
          NetworkInfo,
          CitizenReportsRepository
        >(
          update:
              (_, service, networkInfo, __) =>
                  CitizenReportsRepository(service, networkInfo),
        ),
        ChangeNotifierProvider(
          create:
              (context) => CitizenReportsViewModel(
                context.read<CitizenReportsRepository>(),
              ),
        ),

        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => PickupSchedulesViewModel()),
        ChangeNotifierProvider(create: (_) => MapViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, profileViewModel, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: const Locale('ar', 'YE'),
          title: 'Seiyun Reports App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode:
              profileViewModel.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasData) {
                return HomeScreen();
              }
              return const AuthScreen();
            },
          ),
        );
      },
    );
  }
}
