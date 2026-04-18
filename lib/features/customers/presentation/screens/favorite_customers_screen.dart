import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/sekka_app_bar.dart';
import '../../../../core/widgets/sekka_card.dart';
import '../../../../core/widgets/sekka_empty_state.dart';
import '../../../../core/widgets/sekka_loading.dart';
import '../../../../shared/network/api_response.dart';
import '../../../../shared/network/api_result.dart';
import '../../../../shared/network/dio_client.dart';
import '../../data/models/customer_model.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/services/favorite_customers_service.dart';

class FavoriteCustomersScreen extends StatefulWidget {
  const FavoriteCustomersScreen({super.key});

  @override
  State<FavoriteCustomersScreen> createState() =>
      _FavoriteCustomersScreenState();
}

class _FavoriteCustomersScreenState extends State<FavoriteCustomersScreen> {
  bool _loading = true;
  List<CustomerModel> _favorites = const [];

  @override
  void initState() {
    super.initState();
    FavoriteCustomersService.instance.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    FavoriteCustomersService.instance.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final favIds = await FavoriteCustomersService.instance.all();
    if (favIds.isEmpty) {
      if (!mounted) return;
      setState(() {
        _favorites = const [];
        _loading = false;
      });
      return;
    }
    if (!mounted) return;
    final repo = CustomerRepository(context.read<DioClient>().dio);
    final result = await repo.getCustomers(pageSize: 200);
    if (!mounted) return;
    if (result case ApiSuccess<PagedData<CustomerModel>>(:final data)) {
      setState(() {
        _favorites =
            data.items.where((c) => favIds.contains(c.id)).toList();
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: const SekkaAppBar(title: 'العملاء المفضلين'),
      body: _loading
          ? const SekkaLoading()
          : _favorites.isEmpty
              ? const SekkaEmptyState(
                  icon: IconsaxPlusLinear.heart,
                  title: 'مفيش عملاء مفضلين',
                  description:
                      'اضغطي على القلب في صفحة العميل عشان تضيفيه هنا',
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.w(20)),
                  itemCount: _favorites.length,
                  itemBuilder: (context, i) {
                    final customer = _favorites[i];
                    final displayName = customer.name ?? customer.phone;
                    final initial = displayName.characters.first;
                    return Padding(
                      padding: EdgeInsets.only(
                        top: Responsive.h(10),
                        bottom: Responsive.h(2),
                      ),
                      child: SekkaCard(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surface,
                        padding: EdgeInsets.all(Responsive.w(16)),
                        onTap: () => context.push('/customers/${customer.id}'),
                        child: Row(
                          children: [
                            Container(
                              width: Responsive.r(46),
                              height: Responsive.r(46),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  initial,
                                  style: AppTypography.titleLarge.copyWith(
                                    color: AppColors.textOnPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: Responsive.w(14)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: AppTypography.titleMedium.copyWith(
                                      color: isDark
                                          ? AppColors.textHeadlineDark
                                          : AppColors.textHeadline,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: Responsive.h(4)),
                                  Text(
                                    customer.phone,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: isDark
                                          ? AppColors.textCaptionDark
                                          : AppColors.textCaption,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              IconsaxPlusBold.heart,
                              size: Responsive.r(20),
                              color: AppColors.error,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
