import 'package:billey/l10n/l10n_extensions.dart';
import 'package:billey/services/qr_image_decoder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/colors/app_colors.dart';

class CoupleQrScanScreen extends StatefulWidget {
  const CoupleQrScanScreen({super.key});

  @override
  State<CoupleQrScanScreen> createState() => _CoupleQrScanScreenState();
}

class _CoupleQrScanScreenState extends State<CoupleQrScanScreen> {
  final _picker = ImagePicker();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scanQr());
  }

  Future<void> _scanQr() async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 90,
      );
      if (!mounted) return;
      if (file == null) {
        Navigator.pop(context);
        return;
      }

      final decoded = QrImageDecoder.decodeFromPath(file.path);
      if (decoded == null || !decoded.startsWith('billey://couple/')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.coupleQrNotFound)),
          );
        }
        return;
      }
      if (mounted) Navigator.pop(context, decoded);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor,
        elevation: 0,
        title: Text(
          l10n.coupleScanQr,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_busy) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
              ] else ...[
                Icon(
                  TablerIcons.qrcode,
                  size: 72,
                  color: AppColors.primaryColor.withValues(alpha: 0.85),
                ),
                const SizedBox(height: 24),
              ],
              Text(
                l10n.coupleScanHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
              if (!_busy) ...[
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: _scanQr,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  icon: const Icon(TablerIcons.camera),
                  label: Text(
                    l10n.coupleScanQr,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
