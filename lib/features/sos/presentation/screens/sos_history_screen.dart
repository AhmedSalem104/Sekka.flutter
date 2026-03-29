import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../shared/network/api_response.dart';
import '../../../../shared/network/api_result.dart';
import '../../data/models/sos_model.dart';
import '../../data/repositories/sos_repository.dart';
import '../widgets/sos_history_card.dart';

class SosHistoryScreen extends StatefulWidget {
  const SosHistoryScreen({super.key, required this.repository});
  final SosRepository repository;

  @override
  State<SosHistoryScreen> createState() => _SosHistoryScreenState();
}

class _SosHistoryScreenState extends State<SosHistoryScreen> {
  PagedData<SosModel>? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await widget.repository.getHistory();

    if (!mounted) return;

    switch (result) {
      case ApiSuccess(:final data):
        setState(() {
          _data = data;
          _isLoading = false;
        });
      case ApiFailure(:final error):
        setState(() {
          _error = error.arabicMessage;
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            IconsaxPlusLinear.arrow_right_3,
            color: isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
          ),
        ),
        title: Text(
          AppStrings.sosHistory,
          style: AppTypography.headlineSmall.copyWith(
            color:
                isDark ? AppColors.textHeadlineDark : AppColors.textHeadline,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const SekkaShimmerList(itemCount: 6);
    }

    if (_error != null) {
      return SekkaEmptyState(
        icon: IconsaxPlusBold.warning_2,
        title: _error!,
        actionLabel: AppStrings.retry,
        onAction: _loadHistory,
      );
    }

    if (_data == null || _data!.items.isEmpty) {
      return const SekkaEmptyState(
        icon: IconsaxPlusBold.danger,
        title: AppStrings.sosNoHistory,
        description: AppStrings.sosNoHistoryDesc,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: AppColors.primary,
      child: ListView.separated(
        padding: EdgeInsets.all(Responsive.w(20)),
        itemCount: _data!.items.length,
        separatorBuilder: (_, __) => SizedBox(height: Responsive.h(10)),
        itemBuilder: (context, index) {
          final sos = _data!.items[index];
          return SosHistoryCard(sos: sos, isDark: isDark);
        },
      ),
    );
  }
}
