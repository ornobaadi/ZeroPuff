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

/// The shape of the shared image.
enum ShareCardFormat {
  post('Post', 4 / 5, 300),
  story('Story', 9 / 16, 230);

  const ShareCardFormat(this.label, this.aspectRatio, this.previewWidth);

  final String label;
  final double aspectRatio;

  /// How wide the card is drawn in the preview, in logical pixels.
  final double previewWidth;
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
  /// The shared image is this many pixels wide whatever the preview size.
  static const _imageWidth = 1080.0;

  final _cardKey = GlobalKey();
  ShareCardFormat _format = ShareCardFormat.post;
  bool _sharing = false;

  Future<void> _share() async {
    setState(() => _sharing = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final boundary =
          _cardKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(
        pixelRatio: _imageWidth / boundary.size.width,
      );
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/zeropuff-${_format.name}.png');
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
              child: SegmentedButton<ShareCardFormat>(
                showSelectedIcon: false,
                segments: [
                  for (final format in ShareCardFormat.values)
                    ButtonSegment(value: format, label: Text(format.label)),
                ],
                selected: {_format},
                onSelectionChanged: (selection) =>
                    setState(() => _format = selection.first),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: SizedBox(
                width: _format.previewWidth,
                child: RepaintBoundary(
                  key: _cardKey,
                  child: ShareCard(data: widget.data, format: _format),
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
  const ShareCard({
    required this.data,
    this.format = ShareCardFormat.post,
    super.key,
  });

  final ShareCardData data;
  final ShareCardFormat format;

  static const _paper = Color(0xFFFAF6EE);
  static const _ink = Color(0xFF1F2A24);
  static const _muted = Color(0xFF5C6B62);

  @override
  Widget build(BuildContext context) {
    const accents = AppAccents.light;
    final story = format == ShareCardFormat.story;

    return AspectRatio(
      aspectRatio: format.aspectRatio,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _paper,
          // A story fills the screen, so it has no corners to round.
          borderRadius: story ? BorderRadius.zero : AppShapes.extraLarge,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            // Stories keep clear of the app chrome drawn over the top and
            // bottom of the screen.
            vertical: story ? AppSpacing.xxl : AppSpacing.lg,
          ),
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
              const Text(
                'One breath at a time.',
                style: TextStyle(
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
