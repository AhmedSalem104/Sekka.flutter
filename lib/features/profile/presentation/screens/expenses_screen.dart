import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/sekka_back_button.dart';
import '../../../../core/widgets/sekka_button.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../../../core/widgets/sekka_input_field.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../../shared/network/api_exception.dart';


class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _scrollController = ScrollController();
  List<ExpenseEntity> _expenses = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadExpenses() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final repo = context.read<ProfileRepository>();
      final result = await repo.getExpenses(pageNumber: 1);
      if (mounted) {
        setState(() {
          _expenses = result.items.cast<ExpenseEntity>();
          _hasMore = result.hasNextPage;
          _currentPage = 1;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = AppStrings.unknownError; _isLoading = false; });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    try {
      final repo = context.read<ProfileRepository>();
      final result = await repo.getExpenses(pageNumber: _currentPage + 1);
      if (mounted) {
        setState(() {
          _expenses.addAll(result.items.cast<ExpenseEntity>());
          _hasMore = result.hasNextPage;
          _currentPage++;
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.expenses, style: AppTypography.headlineSmall),
        leading: const SekkaBackButton(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(IconsaxPlusLinear.add, color: AppColors.textOnPrimary),
      ),
      body: _isLoading
          ? const SekkaLoading()
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: AppTypography.bodyMedium),
                      SizedBox(height: AppSizes.lg),
                      TextButton(
                        onPressed: _loadExpenses,
                        child: Text(AppStrings.retry,
                            style: AppTypography.titleMedium
                                .copyWith(color: AppColors.primary)),
                      ),
                    ],
                  ),
                )
              : _expenses.isEmpty
                  ? SekkaEmptyState(
                      icon: IconsaxPlusLinear.money_send,
                      title: AppStrings.noExpenses,
                      actionLabel: AppStrings.addExpense,
                      onAction: () => _showAddDialog(context),
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _loadExpenses,
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: EdgeInsets.all(AppSizes.pagePadding),
                        itemCount: _expenses.length + (_isLoadingMore ? 1 : 0),
                        separatorBuilder: (_, __) =>
                            SizedBox(height: AppSizes.sm),
                        itemBuilder: (context, index) {
                          if (index == _expenses.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(
                                    color: AppColors.primary),
                              ),
                            );
                          }
                          final e = _expenses[index];
                          return _ExpenseCard(
                            expense: e,
                            dateFormat: dateFormat,
                            isDark: isDark,
                          );
                        },
                      ),
                    ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final categoryCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.cardRadius),
        ),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSizes.pagePadding,
          AppSizes.xxl,
          AppSizes.pagePadding,
          MediaQuery.of(ctx).viewInsets.bottom + AppSizes.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppStrings.addExpense, style: AppTypography.headlineSmall),
            SizedBox(height: AppSizes.xl),
            SekkaInputField(
              controller: categoryCtrl,
              label: AppStrings.expenseCategory,
              prefixIcon: IconsaxPlusLinear.category,
            ),
            SizedBox(height: AppSizes.md),
            SekkaInputField(
              controller: amountCtrl,
              label: AppStrings.expenseAmount,
              prefixIcon: IconsaxPlusLinear.money_recive,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: AppSizes.md),
            SekkaInputField(
              controller: notesCtrl,
              label: AppStrings.expenseNotes,
              prefixIcon: IconsaxPlusLinear.note_2,
            ),
            SizedBox(height: AppSizes.xxl),
            SekkaButton(
              label: AppStrings.save,
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text.trim());
                if (categoryCtrl.text.trim().isEmpty || amount == null) return;
                Navigator.pop(ctx);
                try {
                  final repo = context.read<ProfileRepository>();
                  await repo.addExpense({
                    'category': categoryCtrl.text.trim(),
                    'amount': amount,
                    if (notesCtrl.text.trim().isNotEmpty)
                      'notes': notesCtrl.text.trim(),
                  });
                  _loadExpenses();
                } on ApiException catch (e) {
                  if (mounted) context.showSnackBar(e.message, isError: true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({
    required this.expense,
    required this.dateFormat,
    required this.isDark,
  });

  final ExpenseEntity expense;
  final DateFormat dateFormat;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: AppSizes.avatarMd,
            height: AppSizes.avatarMd,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconsaxPlusLinear.money_send,
              size: AppSizes.iconMd,
              color: AppColors.error,
            ),
          ),
          SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.category,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textHeadlineDark
                        : AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  dateFormat.format(expense.createdAt),
                  style: AppTypography.caption.copyWith(
                    color:
                        isDark ? AppColors.textCaptionDark : AppColors.textCaption,
                  ),
                ),
                if (expense.notes != null && expense.notes!.isNotEmpty) ...[
                  SizedBox(height: AppSizes.xs),
                  Text(
                    expense.notes!,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textCaptionDark
                          : AppColors.textCaption,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Text(
            '-${expense.amount.toStringAsFixed(0)} ${AppStrings.currency}',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
