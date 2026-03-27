import '../../../../shared/network/paginated_response.dart';
import '../../domain/entities/cash_status_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/wallet_balance_entity.dart';
import '../../domain/entities/wallet_summary_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl({required WalletRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final WalletRemoteDataSource _remote;

  @override
  Future<WalletBalanceEntity> getBalance() => _remote.getBalance();

  @override
  Future<PaginatedResponse<TransactionEntity>> getTransactions({
    int pageNumber = 1,
    int pageSize = 20,
    int? type,
    String? dateFrom,
    String? dateTo,
  }) =>
      _remote.getTransactions(
        pageNumber: pageNumber,
        pageSize: pageSize,
        type: type,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

  @override
  Future<WalletSummaryEntity> getSummary({
    String? dateFrom,
    String? dateTo,
  }) =>
      _remote.getSummary(dateFrom: dateFrom, dateTo: dateTo);

  @override
  Future<CashStatusEntity> getCashStatus() => _remote.getCashStatus();
}
