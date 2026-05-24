import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:seiyun_reports_app/core/database/news_local_service.dart';
import 'package:seiyun_reports_app/core/database/reports_local_service.dart';
import 'package:seiyun_reports_app/core/network/api_service.dart';
import 'package:seiyun_reports_app/core/network/dio_client.dart';
import 'package:seiyun_reports_app/core/network/network_info.dart';
import 'package:seiyun_reports_app/core/database/assignment_local_service.dart';
import 'package:seiyun_reports_app/screens/supervisor/TasksScreen/data/assignment_service.dart';
import 'package:seiyun_reports_app/screens/supervisor/TasksScreen/data/assignment_repository.dart';
import 'package:seiyun_reports_app/screens/supervisor/TasksScreen/viewmodel/supervisor_tasks_viewmodel.dart';

import 'package:seiyun_reports_app/screens/auth/viewmodel/auth_viewmodel.dart';
import 'package:seiyun_reports_app/screens/citizen_reports/data/citizen_reports_repository.dart';
import 'package:seiyun_reports_app/screens/citizen_reports/data/citizen_reports_service.dart';
import 'package:seiyun_reports_app/screens/citizen_reports/viewmodel/citizen_reports_viewmodel.dart';
import 'package:seiyun_reports_app/screens/home/data/home_repository.dart';
import 'package:seiyun_reports_app/screens/home/data/home_service.dart';
import 'package:seiyun_reports_app/screens/home/viewmodel/home_viewmodel.dart';
import 'package:seiyun_reports_app/screens/map/data/map_repository.dart';
import 'package:seiyun_reports_app/screens/map/data/map_service.dart';
import 'package:seiyun_reports_app/screens/map/viewmodel/map_viewmodel.dart';
import 'package:seiyun_reports_app/screens/news_tips/data/news_repository.dart';
import 'package:seiyun_reports_app/screens/news_tips/data/news_service.dart';
import 'package:seiyun_reports_app/screens/news_tips/viewmodel/news_tips_viewmodel.dart';
import 'package:seiyun_reports_app/screens/notifications/data/notification_repository.dart';
import 'package:seiyun_reports_app/screens/notifications/viewmodel/notification_viewmodel.dart';
import 'package:seiyun_reports_app/screens/pickup_schedules/data/pickup_schedules_repository.dart';
import 'package:seiyun_reports_app/screens/pickup_schedules/data/pickup_schedules_service.dart';
import 'package:seiyun_reports_app/screens/pickup_schedules/viewmodel/pickup_schedules_viewmodel.dart';
import 'package:seiyun_reports_app/core/services/location_service.dart';
import 'package:seiyun_reports_app/screens/profile/data/profile_repository.dart';
import 'package:seiyun_reports_app/screens/profile/data/profile_service.dart';
import 'package:seiyun_reports_app/screens/profile/viewmodel/profile_viewmodel.dart';
import 'package:seiyun_reports_app/screens/report/data/report_repository.dart';
import 'package:seiyun_reports_app/screens/report/data/report_service.dart';
import 'package:seiyun_reports_app/screens/report/viewmodel/report_viewmodel.dart';

class AppProviders {
  static List<SingleChildWidget> providers = [
    Provider(create: (_) => ApiService(DioClient())),
    Provider<NetworkInfo>(create: (_) => NetworkInfoImpl(Connectivity())),
    Provider(create: (_) => LocationService()),
    Provider(create: (_) => ReportsLocalService()),
    Provider(create: (_) => NewsLocalService()),
    Provider(create: (_) => AssignmentsLocalService()),

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
          (context) =>
              CitizenReportsViewModel(context.read<CitizenReportsRepository>()),
    ),

    ChangeNotifierProvider(create: (_) => AuthViewModel()),
    ProxyProvider<ApiService, HomeService>(
      update: (_, api, __) => HomeService(api),
    ),
    ProxyProvider2<HomeService, NetworkInfo, HomeRepository>(
      update:
          (_, service, networkInfo, __) => HomeRepository(service, networkInfo),
    ),
    ChangeNotifierProvider(
      create:
          (context) => HomeViewModel(
            context.read<HomeRepository>(),
            context.read<LocationService>(),
          ),
    ),
    ProxyProvider<ApiService, NotificationRepository>(
      update: (_, api, __) => NotificationRepository(api),
    ),
    ChangeNotifierProxyProvider2<
      NotificationRepository,
      ReportViewModel,
      NotificationViewModel
    >(
      create:
          (context) => NotificationViewModel(
            context.read<NotificationRepository>(),
            context.read<ReportViewModel>(),
          ),
      update:
          (_, repository, reportVM, previous) =>
              previous ?? NotificationViewModel(repository, reportVM),
    ),
    ProxyProvider<ApiService, ProfileService>(
      update: (_, api, __) => ProfileService(api),
    ),
    ProxyProvider2<ProfileService, NetworkInfo, ProfileRepository>(
      update:
          (_, service, networkInfo, __) =>
              ProfileRepository(service, networkInfo),
    ),
    ChangeNotifierProvider(
      create:
          (context) => ProfileViewModel(
            context.read<ProfileRepository>(),
            context.read<LocationService>(),
          ),
    ),
    ProxyProvider<ApiService, PickupSchedulesService>(
      update: (_, api, __) => PickupSchedulesService(api),
    ),
    ProxyProvider2<
      PickupSchedulesService,
      NetworkInfo,
      PickupSchedulesRepository
    >(
      update:
          (_, service, networkInfo, __) =>
              PickupSchedulesRepository(service, networkInfo),
    ),
    ChangeNotifierProvider(
      create:
          (context) => PickupSchedulesViewModel(
            context.read<PickupSchedulesRepository>(),
            context.read<LocationService>(),
          ),
    ),
    ProxyProvider<ApiService, MapService>(
      update: (_, api, __) => MapService(api),
    ),
    ProxyProvider2<MapService, NetworkInfo, MapRepository>(
      update:
          (_, service, networkInfo, __) => MapRepository(service, networkInfo),
    ),
    ChangeNotifierProvider(
      create: (context) => MapViewModel(context.read<MapRepository>()),
    ),
    ChangeNotifierProvider(
      create:
          (context) => SupervisorTasksViewModel(
            AssignmentRepository(
              remoteService: AssignmentService(context.read<ApiService>()),
              localService: context.read<AssignmentsLocalService>(),
              networkInfo: context.read<NetworkInfo>(),
            ),
          ),
    ),
  ];
}
