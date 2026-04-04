import 'package:equatable/equatable.dart';

class SourceBreakdownEntity extends Equatable {
  const SourceBreakdownEntity({
    required this.source,
    required this.count,
    required this.percentage,
  });

  final String source;
  final int count;
  final double percentage;

  @override
  List<Object?> get props => [source, count, percentage];
}
