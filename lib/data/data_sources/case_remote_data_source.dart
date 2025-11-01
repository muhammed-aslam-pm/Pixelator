import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/exceptions/auth_exceptions.dart';
import '../../core/utils/logger.dart';
import '../models/cases_response_model.dart';

abstract class CaseRemoteDataSource {
  Future<CasesResponseModel> getCases({
    String? caseName,
    String? caseNo,
    String? hospitalName,
    String? patientId,
    String? specialization,
    int? priority,
    String? status,
    int? assignedTo,
    bool? isCompleted,
    bool? isFlagged,
    bool? hasOpinion,
    String? createdFrom,
    String? createdTo,
    String? flaggedFrom,
    String? flaggedTo,
    String? completedFrom,
    String? completedTo,
    String? archivedFrom,
    String? archivedTo,
    String? sort,
    int page = 1,
    int size = 20,
  });
}

class CaseRemoteDataSourceImpl implements CaseRemoteDataSource {
  final Dio dio;

  CaseRemoteDataSourceImpl(this.dio);

  @override
  Future<CasesResponseModel> getCases({
    String? caseName,
    String? caseNo,
    String? hospitalName,
    String? patientId,
    String? specialization,
    int? priority,
    String? status,
    int? assignedTo,
    bool? isCompleted,
    bool? isFlagged,
    bool? hasOpinion,
    String? createdFrom,
    String? createdTo,
    String? flaggedFrom,
    String? flaggedTo,
    String? completedFrom,
    String? completedTo,
    String? archivedFrom,
    String? archivedTo,
    String? sort,
    int page = 1,
    int size = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
    };

    if (caseName != null && caseName.isNotEmpty) {
      queryParams['case_name'] = caseName;
    }
    if (caseNo != null && caseNo.isNotEmpty) {
      queryParams['case_no'] = caseNo;
    }
    if (hospitalName != null && hospitalName.isNotEmpty) {
      queryParams['hospital_name'] = hospitalName;
    }
    if (patientId != null && patientId.isNotEmpty) {
      queryParams['patient_id'] = patientId;
    }
    if (specialization != null && specialization.isNotEmpty) {
      queryParams['specialization'] = specialization;
    }
    if (priority != null) {
      queryParams['priority'] = priority;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (assignedTo != null) {
      queryParams['assigned_to'] = assignedTo;
    }
    if (isCompleted != null) {
      queryParams['is_completed'] = isCompleted;
    }
    if (isFlagged != null) {
      queryParams['is_flagged'] = isFlagged;
    }
    if (hasOpinion != null) {
      queryParams['has_opinion'] = hasOpinion;
    }
    if (createdFrom != null && createdFrom.isNotEmpty) {
      queryParams['created_from'] = createdFrom;
    }
    if (createdTo != null && createdTo.isNotEmpty) {
      queryParams['created_to'] = createdTo;
    }
    if (flaggedFrom != null && flaggedFrom.isNotEmpty) {
      queryParams['flagged_from'] = flaggedFrom;
    }
    if (flaggedTo != null && flaggedTo.isNotEmpty) {
      queryParams['flagged_to'] = flaggedTo;
    }
    if (completedFrom != null && completedFrom.isNotEmpty) {
      queryParams['completed_from'] = completedFrom;
    }
    if (completedTo != null && completedTo.isNotEmpty) {
      queryParams['completed_to'] = completedTo;
    }
    if (archivedFrom != null && archivedFrom.isNotEmpty) {
      queryParams['archived_from'] = archivedFrom;
    }
    if (archivedTo != null && archivedTo.isNotEmpty) {
      queryParams['archived_to'] = archivedTo;
    }
    if (sort != null && sort.isNotEmpty) {
      queryParams['sort'] = sort;
    }

    AppLogger.apiCall('GET', AppConstants.casesEndpoint, data: queryParams);

    try {
      final response = await dio.get(
        AppConstants.casesEndpoint,
        queryParameters: queryParams,
      );

      AppLogger.apiResponse(
        'GET',
        AppConstants.casesEndpoint,
        response.statusCode,
        response.data,
      );

      if (response.statusCode == 200) {
        final responseModel = CasesResponseModel.fromJson(response.data);
        AppLogger.i('Cases fetched: ${responseModel.cases.length} cases');
        return responseModel;
      } else {
        AppLogger.e(
          'Get cases failed with status: ${response.statusCode}',
          response.data,
        );
        throw ServerException(
          'Failed to get cases',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.apiError('GET', AppConstants.casesEndpoint, e);
      AppLogger.e('Get cases DioException: ${e.type}', e.response?.data, e.stackTrace);

      if (e.response?.statusCode == 401) {
        AppLogger.w('Get cases unauthorized');
        throw const AuthException('Unauthorized. Please login again.', 401);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        AppLogger.e('Get cases timeout');
        throw const NetworkException('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        AppLogger.e('Get cases connection error');
        throw const NetworkException('No internet connection. Please check your network settings.');
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        if (statusCode != null && statusCode >= 500) {
          AppLogger.e('Get cases server error: $statusCode');
          throw ServerException(
            'Server error. Please try again later.',
            statusCode,
          );
        }
        AppLogger.e('Get cases error: ${e.response?.data}');
        throw ServerException(
          e.response?.data?['detail'] ?? 'Failed to get cases',
          statusCode,
        );
      } else {
        AppLogger.e('Get cases network error: ${e.message}');
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      if (e is AuthException) {
        AppLogger.e('Get cases AuthException: ${e.message}', stackTrace);
        rethrow;
      }
      AppLogger.e('Get cases unexpected error: ${e.toString()}', e, stackTrace);
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }
}

