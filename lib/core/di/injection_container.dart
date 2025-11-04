import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pixelator/core/interceptors/dio_interceptors.dart';
import 'package:pixelator/domain/usecases/get_case_by_id_usecase.dart';
import 'package:pixelator/presentation/cubit/case_detail_cubit.dart';
import 'package:pixelator/presentation/cubit/case_media_cubit.dart';
import 'package:pixelator/domain/usecases/media_usecases.dart';
import 'package:pixelator/domain/repositories/media_repository.dart';
import 'package:pixelator/data/repositories/media_repository_impl.dart';
import 'package:pixelator/data/data_sources/media_remote_data_source.dart';
import '../../data/data_sources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../presentation/cubit/login_cubit.dart';
import '../../presentation/cubit/logout_cubit.dart';
import '../../presentation/cubit/auth_cubit.dart';
import '../../presentation/cubit/cases_cubit.dart';
import '../../domain/repositories/case_repository.dart';
import '../../data/repositories/case_repository_impl.dart';
import '../../data/data_sources/case_remote_data_source.dart';
import '../../domain/usecases/get_cases_usecase.dart';
import '../constants/app_constants.dart';
import '../storage/token_storage.dart';
import '../interceptors/auth_interceptor.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Cubits
  sl.registerFactory(() => LoginCubit(sl()));
  sl.registerFactory(() => LogoutCubit(sl()));
  sl.registerFactory(() => AuthCubit(sl()));
  sl.registerFactory(() => CasesCubit(sl()));
  sl.registerFactory(() => CaseDetailCubit(sl()));
  sl.registerFactory(() => CaseMediaCubit(sl(), sl(), sl(), sl(), sl()));

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => GetCasesUseCase(sl()));
  sl.registerLazySingleton(() => GetCaseByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetCaseMediaUseCase(sl()));
  sl.registerLazySingleton(() => GetPresignedUrlUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmUploadUseCase(sl()));
  sl.registerLazySingleton(() => UploadToS3UseCase(sl()));
  sl.registerLazySingleton(() => DeleteMediaFileUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<CaseRepository>(() => CaseRepositoryImpl(sl()));
  sl.registerLazySingleton<MediaRepository>(() => MediaRepositoryImpl(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<CaseRemoteDataSource>(
    () => CaseRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<MediaRemoteDataSource>(
    () => MediaRemoteDataSourceImpl(sl()),
  );

  // Storage
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  sl.registerLazySingleton<TokenStorage>(() => TokenStorageImpl(sl()));

  // Dio with interceptor
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add auth interceptor
  dio.interceptors.addAll([
    AuthInterceptor(sl<TokenStorage>(), dio),
    LoggerInterceptor(),
  ]);

  sl.registerLazySingleton<Dio>(() => dio);
}
