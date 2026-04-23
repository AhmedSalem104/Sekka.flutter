import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/network/api_result.dart';
import '../../data/repositories/favorite_drivers_repository.dart';
import 'favorite_drivers_event.dart';
import 'favorite_drivers_state.dart';

class FavoriteDriversBloc
    extends Bloc<FavoriteDriversEvent, FavoriteDriversState> {
  FavoriteDriversBloc({required this.repository})
      : super(const FavoriteDriversInitial()) {
    on<FavoriteDriversLoadRequested>(_onLoad);
    on<FavoriteDriverAdded>(_onAdd);
    on<FavoriteDriverRemoved>(_onRemove);
    on<FavoriteDriverRefreshed>(_onRefresh);
    on<ShareLinkRequested>(_onShareLink);
  }

  final FavoriteDriversRepository repository;

  Future<void> _onLoad(
    FavoriteDriversLoadRequested event,
    Emitter<FavoriteDriversState> emit,
  ) async {
    emit(const FavoriteDriversLoading());
    final result = await repository.getFavorites();
    switch (result) {
      case ApiSuccess(:final data):
        emit(FavoriteDriversLoaded(data));
      case ApiFailure(:final error):
        emit(FavoriteDriversError(error.arabicMessage));
    }
  }

  Future<void> _onAdd(
    FavoriteDriverAdded event,
    Emitter<FavoriteDriversState> emit,
  ) async {
    final result = await repository.addFavorite(
      name: event.name,
      phone: event.phone,
    );
    switch (result) {
      case ApiSuccess():
        emit(const FavoriteDriverActionSuccess('تم إضافة الزميل بنجاح'));
        add(const FavoriteDriversLoadRequested());
      case ApiFailure(:final error):
        emit(FavoriteDriversError(error.message));
        // Reload the existing list so UI doesn't get stuck
        add(const FavoriteDriversLoadRequested());
    }
  }

  Future<void> _onRemove(
    FavoriteDriverRemoved event,
    Emitter<FavoriteDriversState> emit,
  ) async {
    final result = await repository.removeFavorite(event.id);
    switch (result) {
      case ApiSuccess():
        emit(const FavoriteDriverActionSuccess('تم حذف الزميل'));
        add(const FavoriteDriversLoadRequested());
      case ApiFailure(:final error):
        emit(FavoriteDriversError(error.arabicMessage));
        add(const FavoriteDriversLoadRequested());
    }
  }

  Future<void> _onRefresh(
    FavoriteDriverRefreshed event,
    Emitter<FavoriteDriversState> emit,
  ) async {
    final result = await repository.refreshFavorite(event.id);
    switch (result) {
      case ApiSuccess():
        add(const FavoriteDriversLoadRequested());
      case ApiFailure(:final error):
        emit(FavoriteDriversError(error.arabicMessage));
        add(const FavoriteDriversLoadRequested());
    }
  }

  Future<void> _onShareLink(
    ShareLinkRequested event,
    Emitter<FavoriteDriversState> emit,
  ) async {
    final result = await repository.createShareLink(
      event.orderId,
      ttlMinutes: event.ttlMinutes,
    );
    switch (result) {
      case ApiSuccess(:final data):
        emit(ShareLinkGenerated(data));
      case ApiFailure(:final error):
        emit(FavoriteDriversError(error.arabicMessage));
    }
  }
}
