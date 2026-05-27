import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_mobile/core/localization/language_cubit.dart';
import 'package:ondas_mobile/core/localization/str_enum.dart';
import 'package:ondas_mobile/core/localization/translations.dart';

class LanguageExampleWidget extends StatelessWidget {
  const LanguageExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Dùng BlocBuilder để lắng nghe sự thay đổi ngôn ngữ
    return BlocBuilder<LanguageCubit, String>(
      builder: (context, lang) {
        return Scaffold(
          appBar: AppBar(
            title: Text(t(Str.successOk, lang)), // Lấy chuỗi "Thành công" / "Success"
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 2. Lấy một chuỗi thông báo lỗi
                Text(
                  t(Str.errorNotFoundSong, lang),
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                ),
                const SizedBox(height: 20),
                
                // 3. Nút đổi ngôn ngữ
                ElevatedButton(
                  onPressed: () {
                    context.read<LanguageCubit>().toggleLanguage();
                  },
                  child: Text('Toggle Language (Current: $lang)'),
                ),

                const SizedBox(height: 40),

                // 4. Ví dụ convert mã lỗi từ Backend trả về dạng String "error.not_found"
                Text(
                  'Backend test: ${t(StrExtension.fromCode("error.unauthorized.invalid_credentials"), lang)}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
