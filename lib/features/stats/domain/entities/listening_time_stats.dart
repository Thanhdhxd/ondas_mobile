import 'package:equatable/equatable.dart';

class ListeningTimeStats extends Equatable {
  final int totalListeningSeconds;
  final double totalListeningMinutes;
  final double totalListeningHours;
  final int totalSongsPlayed;

  const ListeningTimeStats({
    required this.totalListeningSeconds,
    required this.totalListeningMinutes,
    required this.totalListeningHours,
    required this.totalSongsPlayed,
  });

  @override
  List<Object?> get props => [
        totalListeningSeconds,
        totalListeningMinutes,
        totalListeningHours,
        totalSongsPlayed,
      ];
}
