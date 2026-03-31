import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/network/api_result.dart';
import '../../data/models/search_result_model.dart';
import '../../data/repositories/search_repository.dart';

// ── Events ──

sealed class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

final class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

final class SearchCleared extends SearchEvent {
  const SearchCleared();
}

// ── States ──

sealed class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

final class SearchInitial extends SearchState {
  const SearchInitial();
}

final class SearchLoading extends SearchState {
  const SearchLoading();
}

final class SearchLoaded extends SearchState {
  const SearchLoaded(this.result, this.query);
  final SearchResultModel result;
  final String query;

  @override
  List<Object?> get props => [result, query];
}

final class SearchError extends SearchState {
  const SearchError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

// ── BLoC ──

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({required SearchRepository repository})
      : _repository = repository,
        super(const SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchCleared>(_onCleared);
  }

  final SearchRepository _repository;
  Timer? _debounce;

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    _debounce?.cancel();

    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    // Debounce 400ms
    final completer = Completer<void>();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      completer.complete();
    });

    try {
      await completer.future;
    } catch (_) {
      return;
    }

    emit(const SearchLoading());

    final result = await _repository.search(query: query);

    switch (result) {
      case ApiSuccess(:final data):
        emit(SearchLoaded(data, query));
      case ApiFailure(:final error):
        emit(SearchError(error.arabicMessage));
    }
  }

  void _onCleared(
    SearchCleared event,
    Emitter<SearchState> emit,
  ) {
    _debounce?.cancel();
    emit(const SearchInitial());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
