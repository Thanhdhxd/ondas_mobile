import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/core/network/dio_client.dart';
import 'package:ondas_mobile/features/playlist/data/datasources/playlist_remote_datasource.dart';
import 'package:ondas_mobile/features/playlist/data/models/playlist_detail_model.dart';
import 'package:ondas_mobile/features/playlist/data/models/playlist_summary_model.dart';

class PlaylistRemoteDatasourceImpl implements PlaylistRemoteDatasource {
  final DioClient _dioClient;

  const PlaylistRemoteDatasourceImpl(this._dioClient);

  @override
  Future<List<PlaylistSummaryModel>> getMyPlaylists({
    required String songId,
  }) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.playlists,
      queryParameters: {
        'owner': true,
        'songId': songId,
        'page': 0,
        'size': 100,
      },
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        PlaylistSummaryModel.fromJson,
      ),
    );
    return apiResponse.data!.items;
  }

  @override
  Future<void> addSongToPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    await _dioClient.post<dynamic>(
      ApiConstants.playlistSongs(playlistId),
      data: {'songId': songId},
    );
  }

  @override
  Future<void> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    await _dioClient.delete<dynamic>(
      ApiConstants.playlistSongById(playlistId, songId),
    );
  }

  @override
  Future<PlaylistSummaryModel> createPlaylist({
    required String name,
    String? coverImageUrl,
  }) async {
    MultipartFile? coverFile;
    if (coverImageUrl != null) {
      try {
        final imageResponse = await _dioClient.dio.get<List<int>>(
          coverImageUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        if (imageResponse.data != null) {
          final ext = coverImageUrl.contains('.png') ? 'png' : 'jpg';
          coverFile = MultipartFile.fromBytes(
            imageResponse.data!,
            filename: 'cover.$ext',
            contentType: DioMediaType('image', ext),
          );
        }
      } catch (_) {
        // Cover download failed — create playlist without cover
      }
    }

    final requestData = <String, dynamic>{'name': name};
    final formData = FormData.fromMap({
      'data': MultipartFile.fromString(
        jsonEncode(requestData),
        contentType: DioMediaType.parse('application/json'),
      ),
      'cover': ?coverFile,
    });

    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.playlists,
      data: formData,
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => PlaylistSummaryModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  @override
  Future<List<PlaylistSummaryModel>> getLibraryPlaylists() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.playlists,
      queryParameters: {'owner': true, 'page': 0, 'size': 100},
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        PlaylistSummaryModel.fromJson,
      ),
    );
    return apiResponse.data!.items;
  }

  @override
  Future<PlaylistDetailModel> getPlaylistDetail(String id) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.playlistById(id),
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => PlaylistDetailModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  @override
  Future<void> updatePlaylist({
    required String id,
    required String name,
  }) async {
    final formData = FormData.fromMap({
      'data': MultipartFile.fromString(
        jsonEncode({'name': name}),
        contentType: DioMediaType.parse('application/json'),
      ),
    });
    await _dioClient.put<dynamic>(ApiConstants.playlistById(id), data: formData);
  }

  @override
  Future<void> deletePlaylist(String id) async {
    await _dioClient.delete<dynamic>(ApiConstants.playlistById(id));
  }

  @override
  Future<void> reorderPlaylistSongs({
    required String playlistId,
    required List<String> songIds,
  }) async {
    await _dioClient.put<dynamic>(
      ApiConstants.playlistSongsReorder(playlistId),
      data: {'songIds': songIds},
    );
  }
}
