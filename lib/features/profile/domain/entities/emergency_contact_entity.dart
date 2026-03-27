import 'package:equatable/equatable.dart';

class EmergencyContactEntity extends Equatable {
  const EmergencyContactEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
  });

  final String id;
  final String name;
  final String phone;
  final String? relation;

  @override
  List<Object?> get props => [id, name, phone, relation];
}
