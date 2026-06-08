import 'package:ondas_mobile/features/stats/domain/entities/listening_time_stats.dart';

class ListeningTimeStatsModel extends ListeningTimeStats {
  const ListeningTimeStatsModel({
    required super.totalListeningSeconds,
    required super.totalListeningMinutes,
    required super.totalListeningHours,
    required super.totalSongsPlayed,
  });

  factory ListeningTimeStatsModel.fromJson(Map<String, dynamic> json) {
    return ListeningTimeStatsModel(
      totalListeningSeconds: (json['totalListeningSeconds'] as num?)?.toInt() ?? 0,
      totalListeningMinutes: (json['totalListeningMinutes'] as num?)?.toDouble() ?? 0.0,
      totalListeningHours: (json['totalListeningHours'] as num?)?.toDouble() ?? 0.0,
      totalSongsPlayed: (json['totalSongsPlayed'] as num?)?.toInt() ?? 0,
    );
  }
}
