import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class OAuthHandler {
  static const String baseUrl = 'http://10.0.2.2:5000';
  static final _authService = AuthService();

  static Future<Map<String, dynamic>> handleOAuthLogin(
    BuildContext context,
    String provider,
  ) async {
    try {
      final oauthUrlString = '$baseUrl/auth/$provider';
      final oauthUrl = Uri.parse(oauthUrlString);

      bool urlOpened = false;

      // Coba buka dengan browser eksternal
      try {
        if (await canLaunchUrl(oauthUrl)) {
          await launchUrl(
            oauthUrl,
            mode: LaunchMode.externalApplication,
          );
          urlOpened = true;
        }
      } catch (e) {
        debugPrint('Error launching with external app: $e');
      }

      // Jika browser eksternal gagal, show manual dialog dengan URL
      if (!urlOpened) {
        if (context.mounted) {
          final manualResult = await _showManualBrowserDialog(
            context,
            provider,
            oauthUrlString,
          );
          if (manualResult != null) {
            return manualResult;
          }
        }
      }

      // Show dialog untuk user copy-paste token
      if (context.mounted) {
        return await _showTokenPasteDialog(context, provider);
      }

      return {'success': false, 'error': 'Dialog ditutup'};
    } catch (e) {
      return {
        'success': false,
        'error': 'OAuth login gagal: $e',
      };
    }
  }

  static Future<Map<String, dynamic>?> _showManualBrowserDialog(
    BuildContext context,
    String provider,
    String url,
  ) async {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: AppColors.darkBluePurple,
        title: Text(
          'Buka Link ${provider.toUpperCase()}',
          style: const TextStyle(
            color: AppColors.brightBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Salin URL di bawah, buka di browser, dan login dengan akun Anda:',
              style: TextStyle(color: AppColors.silver),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.brightBlue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                url,
                style: const TextStyle(
                  color: AppColors.brightBlue,
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Setelah login berhasil di browser, Anda akan mendapat token. Klik "Lanjutkan" ketika siap paste token.',
              style: TextStyle(
                color: AppColors.silver,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Batal', style: TextStyle(color: AppColors.silver)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop({'continue': true}),
            child: const Text('Lanjutkan', style: TextStyle(color: AppColors.brightBlue)),
          ),
        ],
      ),
    );
  }

  static Future<Map<String, dynamic>> _showTokenPasteDialog(
    BuildContext context,
    String provider,
  ) async {
    final tokenController = TextEditingController();
    String? errorText;

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => StatefulBuilder(
        builder: (BuildContext ctx, StateSetter setState) => AlertDialog(
          backgroundColor: AppColors.darkBluePurple,
          title: Text(
            'Paste Token ${provider.toUpperCase()}',
            style: const TextStyle(
              color: AppColors.brightBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Paste token yang Anda dapat dari halaman login:',
                style: TextStyle(color: AppColors.silver),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tokenController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Paste token di sini',
                  hintStyle: const TextStyle(color: AppColors.silver),
                  errorText: errorText,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.brightBlue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.brightBlue),
                  ),
                ),
                style: const TextStyle(color: AppColors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop({
                'success': false,
                'error': 'Login dibatalkan',
              }),
              child: const Text('Batal', style: TextStyle(color: AppColors.silver)),
            ),
            TextButton(
              onPressed: () async {
                final token = tokenController.text.trim();
                if (token.isEmpty) {
                  setState(() {
                    errorText = 'Token tidak boleh kosong';
                  });
                  return;
                }

                // Verify token dengan backend
                final result = await _authService.handleOAuthCallback(
                  token: token,
                  provider: provider,
                );

                if (ctx.mounted) {
                  Navigator.of(ctx).pop(result);
                }
              },
              child: const Text('Verifikasi', style: TextStyle(color: AppColors.brightBlue)),
            ),
          ],
        ),
      ),
    ).then((result) => result ?? {'success': false, 'error': 'Dialog ditutup'});
  }
}
