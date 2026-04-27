import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/features/profile/domain/entities/play_history_item.dart';

class PlayHistorySongModel extends PlayHistorySong {
  const PlayHistorySongModel({
    required super.id,
    required super.title,
    super.coverUrl,
    required super.durationSeconds,
    required super.audioUrl,
  });

  factory PlayHistorySongModel.fromJson(Map<String, dynamic> json) {
    return PlayHistorySongModel(
      id: json['id'] as String,
      title: json['title'] as String,
      coverUrl: _normalizeUrl(json['coverUrl'] as String?),
      durationSeconds: json['durationSeconds'] as int,
      audioUrl: _normalizeUrl(json['audioUrl'] as String?) ?? '',
    );
  }

  static String? _normalizeUrl(String? url) {
    if (url == null) return null;
    final host = Uri.parse(ApiConstants.baseUrl).host;
    return url
        .replaceAll('localhost', host)
        .replaceAll('127.0.0.1', host);
  }
}

class PlayHistoryItemModel extends PlayHistoryItem {
  const PlayHistoryItemModel({
    required super.id,
    required super.song,
    required super.playedAt,
    super.source,
  });

  factory PlayHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return PlayHistoryItemModel(
      id: json['id'] as int,
      song: PlayHistorySongModel.fromJson(
        json['song'] as Map<String, dynamic>,
      ),
      playedAt: DateTime.parse(json['playedAt'] as String),
      source: json['source'] as String?,
    );
  }
}
