import '../../../../shared/network/paginated_response.dart';
import '../entities/cash_status_entity.dart';
import '../entities/transaction_entity.dart';
import '../entities/wallet_balance_entity.dart';
import '../entities/wallet_summary_entity.dart';

abstract class WalletRepository {
  Future<WalletBalanceEntity> getBalance();

  Future<PaginatedResponse<TransactionEntity>> getTransactions({
    int pageNumber = 1,
    int pageSize = 20,
    int? type,
    String? dateFrom,
    String? dateTo,
  });

  Future<WalletSummaryEntity> getSummary({
    String? dateFrom,
    String? dateTo,
  });

  Future<CashStatusEntity> getCashStatus();
}
