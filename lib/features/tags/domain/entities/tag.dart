import 'package:equatable/equatable.dart';

class Tag extends Equatable {
  final int id;
  final String name;
  final String type;
  final String? colorHex;

  const Tag({
    required this.id,
    required this.name,
    required this.type,
    this.colorHex,
  });

  @override
  List<Object?> get props => [id, name, type, colorHex];
}
