import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../features/sync/presentation/bloc/sync_bloc.dart';
import '../../features/sync/presentation/bloc/sync_state.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../theme/app_typography.dart';

/// Wraps the app shell and shows a transient banner at the top when the
/// connectivity status flips (online → offline or offline → online).
/// Auto-dismisses after a few seconds. Otherwise invisible — the user is
/// never nagged with a persistent offline indicator.
class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key, required this.child});

  final Widget child;

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  Timer? _dismissTimer;
  late final AnimationController _controller;

  String _message = '';
  bool _isError = false;
  IconData _icon = IconsaxPlusLinear.wifi;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _show({
    required String message,
    required bool isError,
    required IconData icon,
  }) {
    _dismissTimer?.cancel();
    setState(() {
      _message = message;
      _isError = isError;
      _icon = icon;
    });
    _controller.forward();
    _dismissTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SyncBloc, SyncState>(
      listenWhen: (prev, curr) {
        if (curr is! SyncLoaded) return false;
        final currOnline = curr.status?.isOnline ?? true;
        final prevOnline = (prev is SyncLoaded)
            ? (prev.status?.isOnline ?? true)
            : null;
        return prevOnline != null && prevOnline != currOnline;
      },
      listener: (context, state) {
        if (state is! SyncLoaded) return;
        final isOnline = state.status?.isOnline ?? true;
        if (isOnline) {
          _show(
            message: AppStrings.connectionRestored,
            isError: false,
            icon: IconsaxPlusLinear.wifi,
          );
        } else {
          _show(
            message: AppStrings.connectionOffline,
            isError: true,
            icon: IconsaxPlusLinear.wifi_square,
          );
        }
      },
      child: Stack(
        children: [
          widget.child,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _controller,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              )),
              child: FadeTransition(
                opacity: _controller,
                child: _BannerBar(
                  message: _message,
                  isError: _isError,
                  icon: _icon,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerBar extends StatelessWidget {
  const _BannerBar({
    required this.message,
    required this.isError,
    required this.icon,
  });

  final String message;
  final bool isError;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final bg = isError ? AppColors.error : AppColors.success;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final barHeight = statusBarHeight > 0 ? statusBarHeight : 24.0;

    return Material(
      color: bg,
      child: Container(
        width: double.infinity,
        height: barHeight,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
        color: bg,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 12,
                color: AppColors.textOnPrimary,
              ),
              SizedBox(width: AppSizes.xs),
              Text(
                message,
                style: AppTypography.captionSmall.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
