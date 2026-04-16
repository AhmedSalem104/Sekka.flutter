import 'package:equatable/equatable.dart';

class HeatmapCellEntity extends Equatable {
  const HeatmapCellEntity({
    required this.dayOfWeek,
    required this.hour,
    required this.orders,
    required this.earnings,
  });

  final int dayOfWeek;
  final int hour;
  final int orders;
  final double earnings;

  @override
  List<Object?> get props => [dayOfWeek, hour, orders, earnings];
}
