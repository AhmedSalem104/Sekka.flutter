import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/invoice_summary_entity.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../datasources/invoice_remote_datasource.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  InvoiceRepositoryImpl({
    required InvoiceRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final InvoiceRemoteDataSource _remote;

  @override
  Future<List<InvoiceEntity>> getInvoices({
    int pageNumber = 1,
    int pageSize = 20,
    int? status,
  }) =>
      _remote.getInvoices(
        pageNumber: pageNumber,
        pageSize: pageSize,
        status: status,
      );

  @override
  Future<InvoiceEntity> getInvoiceDetail(String id) =>
      _remote.getInvoiceDetail(id);

  @override
  Future<List<int>> downloadInvoicePdf(String id) =>
      _remote.downloadInvoicePdf(id);

  @override
  Future<InvoiceSummaryEntity> getInvoiceSummary() =>
      _remote.getInvoiceSummary();
}
