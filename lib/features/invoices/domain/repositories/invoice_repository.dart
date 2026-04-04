import '../entities/invoice_entity.dart';
import '../entities/invoice_summary_entity.dart';

abstract class InvoiceRepository {
  Future<List<InvoiceEntity>> getInvoices({
    int pageNumber = 1,
    int pageSize = 20,
    int? status,
  });

  Future<InvoiceEntity> getInvoiceDetail(String id);

  Future<List<int>> downloadInvoicePdf(String id);

  Future<InvoiceSummaryEntity> getInvoiceSummary();
}
