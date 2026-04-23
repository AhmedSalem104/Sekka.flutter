import '../../data/models/favorite_driver_model.dart';

sealed class FavoriteDriversState {
  const FavoriteDriversState();
}

final class FavoriteDriversInitial extends FavoriteDriversState {
  const FavoriteDriversInitial();
}

final class FavoriteDriversLoading extends FavoriteDriversState {
  const FavoriteDriversLoading();
}

final class FavoriteDriversLoaded extends FavoriteDriversState {
  const FavoriteDriversLoaded(this.drivers);
  final List<FavoriteDriverModel> drivers;
}

final class FavoriteDriversError extends FavoriteDriversState {
  const FavoriteDriversError(this.message);
  final String message;
}

/// Transient state emitted after an action succeeds (add/remove/refresh).
/// The bloc immediately re-fetches the list after this.
final class FavoriteDriverActionSuccess extends FavoriteDriversState {
  const FavoriteDriverActionSuccess(this.message);
  final String message;
}

/// Share link generated successfully.
final class ShareLinkGenerated extends FavoriteDriversState {
  const ShareLinkGenerated(this.link);
  final ShareLinkModel link;
}
