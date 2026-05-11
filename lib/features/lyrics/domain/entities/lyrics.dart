import 'package:equatable/equatable.dart';

class Lyrics extends Equatable {
  final String id;
  final String songId;
  final String? plainText;
  final bool hasSynced;
  final String? language;
  final List<SyncedLyricsLine> syncedLines;

  const Lyrics({
    required this.id,
    required this.songId,
    this.plainText,
    required this.hasSynced,
    this.language,
    this.syncedLines = const [],
  });

  bool get hasPlainText => plainText != null && plainText!.trim().isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        songId,
        plainText,
        hasSynced,
        language,
        syncedLines,
      ];
}

class SyncedLyricsLine extends Equatable {
  final int? id;
  final int startMs;
  final int? endMs;
  final String lineText;
  final int lineIndex;

  const SyncedLyricsLine({
    this.id,
    required this.startMs,
    this.endMs,
    required this.lineText,
    required this.lineIndex,
  });

  @override
  List<Object?> get props => [id, startMs, endMs, lineText, lineIndex];
}
