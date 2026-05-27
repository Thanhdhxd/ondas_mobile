import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/core/storage/secure_storage.dart';

/// Cubit (flutter_bloc tương tự StateNotifier/Riverpod) quản lý state ngôn ngữ hiện tại, mặc định là 'vi'
class LanguageCubit extends Cubit<String> {
  final SecureStorage _secureStorage;

  LanguageCubit(this._secureStorage) : super('vi');

  void loadSavedLanguage() {
    unawaited(_loadSavedLanguage());
  }

  Future<void> _loadSavedLanguage() async {
    final saved = await _secureStorage.getLanguageCode();
    if (saved != null && _isSupported(saved) && saved != state) {
      emit(saved);
    }
  }

  void setLanguage(String langCode) {
    if (!_isSupported(langCode)) return;
    if (langCode != state) {
      emit(langCode);
    }
    unawaited(_secureStorage.saveLanguageCode(langCode));
  }

  void toggleLanguage() {
    final next = state == 'vi' ? 'en' : 'vi';
    emit(next);
    unawaited(_secureStorage.saveLanguageCode(next));
  }

  bool _isSupported(String langCode) => langCode == 'vi' || langCode == 'en';
}
