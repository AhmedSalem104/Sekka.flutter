sealed class FavoriteDriversEvent {
  const FavoriteDriversEvent();
}

final class FavoriteDriversLoadRequested extends FavoriteDriversEvent {
  const FavoriteDriversLoadRequested();
}

final class FavoriteDriverAdded extends FavoriteDriversEvent {
  const FavoriteDriverAdded({required this.name, required this.phone});
  final String name;
  final String phone;
}

final class FavoriteDriverRemoved extends FavoriteDriversEvent {
  const FavoriteDriverRemoved(this.id);
  final String id;
}

final class FavoriteDriverRefreshed extends FavoriteDriversEvent {
  const FavoriteDriverRefreshed(this.id);
  final String id;
}

final class FavoriteDriverSearchByPhone extends FavoriteDriversEvent {
  const FavoriteDriverSearchByPhone(this.phone);
  final String phone;
}

final class ShareLinkRequested extends FavoriteDriversEvent {
  const ShareLinkRequested({required this.orderId, this.ttlMinutes});
  final String orderId;
  final int? ttlMinutes;
}
