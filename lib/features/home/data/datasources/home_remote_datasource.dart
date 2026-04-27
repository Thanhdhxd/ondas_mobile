import 'package:ondas_mobile/features/home/data/models/home_data_model.dart';

abstract class HomeRemoteDatasource {
  Future<HomeDataModel> getHomeData();
}
