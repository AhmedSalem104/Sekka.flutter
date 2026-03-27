import 'package:equatable/equatable.dart';

class VehicleTypeEntity extends Equatable {
  const VehicleTypeEntity({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
