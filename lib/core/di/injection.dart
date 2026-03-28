import 'package:get_it/get_it.dart';
import 'package:futdle/core/firebase/auth_service.dart';
import 'package:futdle/core/firebase/firestore_service.dart';
import 'package:futdle/core/api/api_service.dart';
import 'package:futdle/core/managers/daily_player_manager.dart';
import 'package:futdle/features/auth/controllers/auth_controller.dart';


final getIt = GetIt.instance;

void setupDependencyInjection() {
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<FirestoreService>(() => FirestoreService());
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  getIt.registerLazySingleton<DailyPlayerManager>(() => DailyPlayerManager());
  getIt.registerLazySingleton<AuthController>(() => AuthController());
}
