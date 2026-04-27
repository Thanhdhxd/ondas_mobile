import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ondas_mobile/core/constants/api_constants.dart';
import 'package:ondas_mobile/core/network/api_response.dart';
import 'package:ondas_mobile/core/network/dio_client.dart';
import 'package:ondas_mobile/features/playlist/data/datasources/playlist_remote_datasource.dart';
import 'package:ondas_mobile/features/playlist/data/models/playlist_model.dart';
import 'package:ondas_mobile/features/playlist/domain/repositories/playlist_repository.dart';

class PlaylistRemoteDatasourceImpl implements PlaylistRemoteDatasource {
  final DioClient _dioClient;

  const PlaylistRemoteDatasourceImpl(this._dioClient);

  @override
  Future<PageResult<PlaylistModel>> getMyPlaylists({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.playlists,
      queryParameters: {'owner': true, 'page': page, 'size': size},
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => PageResult.fromJson(
        json as Map<String, dynamic>,
        PlaylistModel.fromJson,
      ),
    );
    return apiResponse.data!;
  }

  @override
  Future<PlaylistModel> createPlaylist(CreatePlaylistParams params) async {
    final data = <String, dynamic>{
      'name': params.name,
      if (params.description != null) 'description': params.description,
      'isPublic': params.isPublic,
    };

    final formData = FormData.fromMap({
      'data': MultipartFile.fromString(
        jsonEncode(data),
        contentType: DioMediaType('application', 'json'),
      ),
    });

    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.playlists,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => PlaylistModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  @override
  Future<PlaylistModel> getPlaylistDetail(String id) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.playlistById(id),
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => PlaylistModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  @override
  Future<PlaylistModel> updatePlaylist(UpdatePlaylistParams params) async {
    final data = <String, dynamic>{
      if (params.name != null) 'name': params.name,
      if (params.description != null) 'description': params.description,
      if (params.isPublic != null) 'isPublic': params.isPublic,
    };

    final formData = FormData.fromMap({
      'data': MultipartFile.fromString(
        jsonEncode(data),
        contentType: DioMediaType('application', 'json'),
      ),
    });

    final response = await _dioClient.put<Map<String, dynamic>>(
      ApiConstants.playlistById(params.id),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => PlaylistModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  @override
  Future<void> deletePlaylist(String id) async {
    await _dioClient.delete<Map<String, dynamic>>(
      ApiConstants.playlistById(id),
    );
  }

  @override
  Future<PlaylistModel> addSongToPlaylist(
      AddSongToPlaylistParams params) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.playlistSongs(params.playlistId),
      data: {'songId': params.songId},
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => PlaylistModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  @override
  Future<PlaylistModel> removeSongFromPlaylist(
      RemoveSongFromPlaylistParams params) async {
    final response = await _dioClient.delete<Map<String, dynamic>>(
      ApiConstants.playlistSongById(params.playlistId, params.songId),
    );
    final apiResponse = ApiResponse.fromJson(
      response.data!,
      (json) => PlaylistModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }
}
