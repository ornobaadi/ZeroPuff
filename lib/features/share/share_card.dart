import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/friendly_error.dart';
import '../../core/theme/app_accents.dart';
import '../../core/theme/app_shapes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// What a shared win says. Only the numbers shown here leave the device.
class ShareCardData {
  const ShareCardData({
    required this.headline,
    required this.caption,
    this.lines = const [],
  });

  /// The big line: "7 days", "Craving #12".
  final String headline;

  /// What the headline means: "smoke-free", "beaten".
  final String caption;

  /// Up to three supporting facts.
  final List<String> lines;
}

/// Shows the card and lets the user send it as an image.
Future<void> showShareCard(BuildContext context, ShareCardData data) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _ShareSheet(data: data),
  );
}

class _ShareSheet extends StatefulWidget {
  const _ShareSheet({required this.data});

  final ShareCardData data;

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  final _cardKey = GlobalKey();
  bool _sharing = false;

  Future<void> _share() async {
    setState(() => _sharing = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final boundary =
          _cardKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/zeropuff-win.png');
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: '${widget.data.headline} ${widget.data.caption}.',
        ),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on Object catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(friendlyError(error))));
    } finally {
      if (mounted) {
        setState(() => _sharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding,
          0,
          AppSpacing.pagePadding,
          AppSpacing.pagePadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: RepaintBoundary(
                  key: _cardKey,
                  child: ShareCard(data: widget.data),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: _sharing ? null : _share,
              icon: const Icon(Symbols.ios_share_rounded),
              label: Text(_sharing ? 'Preparing' : 'Share'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The image itself. It always uses the light brand colors so it looks the
/// same wherever it is posted.
class ShareCard extends StatelessWidget {
  const ShareCard({required this.data, super.key});

  final ShareCardData data;

  static const _paper = Color(0xFFFAF6EE);
  static const _ink = Color(0xFF1F2A24);
  static const _muted = Color(0xFF5C6B62);

  @override
  Widget build(BuildContext context) {
    const accents = AppAccents.light;

    return AspectRatio(
      aspectRatio: 4 / 5,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: _paper,
          borderRadius: AppShapes.extraLarge,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.appName.toUpperCase(),
                style: AppTypography.eyebrow.copyWith(color: accents.streak),
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  data.headline,
                  style: AppTypography.displayNumber.copyWith(color: _ink),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                data.caption,
                style: AppTypography.emphasis(
                  AppTypography.statNumber,
                  accents.streak,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final line in data.lines.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 7, right: 8),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: accents.money,
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox(width: 6, height: 6),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          line,
                          style: const TextStyle(
                            fontFamily: AppTypography.bodyFamily,
                            fontSize: 15,
                            height: 1.35,
                            color: _muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              Text(
                'One breath at a time.',
                style: const TextStyle(
                  fontFamily: AppTypography.bodyFamily,
                  fontSize: 12,
                  color: _muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
