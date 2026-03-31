import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../bloc/badge_bloc.dart';
import '../bloc/badge_event.dart';
import '../bloc/badge_state.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;
    setState(() => _scanned = true);
    _controller.stop();
    context.read<BadgeBloc>().add(BadgeVerifyRequested(qrToken: code));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        title: Text(
          AppStrings.badgeScanQr,
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<BadgeBloc, BadgeState>(
        listener: (context, state) {
          if (state is BadgeVerifying) {
            // Already popped — handled in badge_screen listener
          }
        },
        child: Stack(
          children: [
            // Camera
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),

            // Overlay
            _ScanOverlay(isDark: isDark),
          ],
        ),
      ),
    );
  }
}

// ── Scan overlay ──────────────────────────────────────────────────────────────

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cutoutSize = Responsive.r(240);

    return Column(
      children: [
        // Top dimmed area + side dims + bottom
        Expanded(
          child: ColoredBox(
            color: Colors.black.withValues(alpha: 0.55),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Clear cutout area with corner brackets
                  SizedBox(
                    width: cutoutSize,
                    height: cutoutSize,
                    child: Stack(
                      children: [
                        // Transparent center
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMd),
                          ),
                        ),
                        // Corner brackets
                        ..._buildCorners(cutoutSize),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSizes.xl),
                  Text(
                    AppStrings.badgeScanHint,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSizes.sm),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        IconsaxPlusLinear.scan,
                        color: AppColors.primary,
                        size: AppSizes.iconMd,
                      ),
                      SizedBox(width: AppSizes.xs),
                      Text(
                        AppStrings.badgeScanSubhint,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCorners(double size) {
    const strokeWidth = 3.0;
    const cornerLength = 24.0;

    return [
      // Top-right
      Positioned(
        top: 0,
        right: 0,
        child: _Corner(
          width: cornerLength,
          height: cornerLength,
          strokeWidth: strokeWidth,
          topRight: true,
        ),
      ),
      // Top-left
      Positioned(
        top: 0,
        left: 0,
        child: _Corner(
          width: cornerLength,
          height: cornerLength,
          strokeWidth: strokeWidth,
          topLeft: true,
        ),
      ),
      // Bottom-right
      Positioned(
        bottom: 0,
        right: 0,
        child: _Corner(
          width: cornerLength,
          height: cornerLength,
          strokeWidth: strokeWidth,
          bottomRight: true,
        ),
      ),
      // Bottom-left
      Positioned(
        bottom: 0,
        left: 0,
        child: _Corner(
          width: cornerLength,
          height: cornerLength,
          strokeWidth: strokeWidth,
          bottomLeft: true,
        ),
      ),
    ];
  }
}

class _Corner extends StatelessWidget {
  const _Corner({
    required this.width,
    required this.height,
    required this.strokeWidth,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  final double width;
  final double height;
  final double strokeWidth;
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _CornerPainter(
        strokeWidth: strokeWidth,
        topLeft: topLeft,
        topRight: topRight,
        bottomLeft: bottomLeft,
        bottomRight: bottomRight,
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({
    required this.strokeWidth,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  final double strokeWidth;
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    if (topLeft) {
      canvas.drawLine(Offset(0, h), const Offset(0, 0), paint);
      canvas.drawLine(const Offset(0, 0), Offset(w, 0), paint);
    }
    if (topRight) {
      canvas.drawLine(Offset(0, 0), Offset(w, 0), paint);
      canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
    }
    if (bottomLeft) {
      canvas.drawLine(Offset(0, 0), Offset(0, h), paint);
      canvas.drawLine(Offset(0, h), Offset(w, h), paint);
    }
    if (bottomRight) {
      canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
      canvas.drawLine(Offset(0, h), Offset(w, h), paint);
    }
  }

  @override
  bool shouldRepaint(_CornerPainter oldDelegate) => false;
}
