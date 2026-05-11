import 'package:ondas_mobile/features/lyrics/domain/entities/lyrics.dart';

class LyricsModel extends Lyrics {
  const LyricsModel({
    required super.id,
    required super.songId,
    super.plainText,
    required super.hasSynced,
    super.language,
    super.syncedLines,
  });

  factory LyricsModel.fromJson(Map<String, dynamic> json) {
    final syncedLinesJson = (json['syncedLines'] as List<dynamic>?) ?? [];
    final syncedLines = syncedLinesJson
        .map((e) => SyncedLyricsLineModel.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.lineIndex.compareTo(b.lineIndex));

    return LyricsModel(
      id: json['id'] as String,
      songId: json['songId'] as String,
      plainText: json['plainText'] as String?,
      hasSynced: json['hasSynced'] as bool? ?? false,
      language: json['language'] as String?,
      syncedLines: syncedLines,
    );
  }
}

class SyncedLyricsLineModel extends SyncedLyricsLine {
  const SyncedLyricsLineModel({
    super.id,
    required super.startMs,
    super.endMs,
    required super.lineText,
    required super.lineIndex,
  });

  factory SyncedLyricsLineModel.fromJson(Map<String, dynamic> json) {
    return SyncedLyricsLineModel(
      id: json['id'] as int?,
      startMs: json['startMs'] as int,
      endMs: json['endMs'] as int?,
      lineText: json['lineText'] as String? ?? '',
      lineIndex: json['lineIndex'] as int,
    );
  }
}
