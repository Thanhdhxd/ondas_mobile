import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/core/network/dio_client.dart';
import 'package:ondas_mobile/features/home/data/datasources/home_remote_datasource.dart';
import 'package:ondas_mobile/features/home/data/models/home_data_model.dart';

class HomeRemoteDatasourceImpl implements HomeRemoteDatasource {
  final DioClient _dioClient;

  const HomeRemoteDatasourceImpl(this._dioClient);

  @override
  Future<HomeDataModel> getHomeData() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.home,
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => HomeDataModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }
}
