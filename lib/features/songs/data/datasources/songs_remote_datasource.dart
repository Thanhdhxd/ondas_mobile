import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/features/home/data/models/song_summary_model.dart';

abstract class SongsRemoteDatasource {
  Future<PageResult<SongSummaryModel>> getSongs({
    String? artistId,
    String? albumId,
    int? genreId,
    List<int>? tagIds,
    int page = 0,
    int size = 20,
  });
}
