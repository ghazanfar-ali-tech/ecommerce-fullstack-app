import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/models/hive_models/cart_model/cart_model.dart';
import 'package:ecommerceapp/view_model/auth_view_model.dart';
import 'package:ecommerceapp/view_model/store_view_model.dart';
import 'package:ecommerceapp/views/detail_screen/check_out_screeen.dart';
import 'package:ecommerceapp/views/home_screen/cart_screen/cart_screen.dart';
import 'package:ecommerceapp/views/whileList/favourite_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecommerceapp/services/chat_service.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerceapp/resources/components/appColor.dart' as MyAppColor;

class AppColors {
  static const Color lightBg = Color(0xFFF6F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBotBubble = Color(0xFFFFFFFF);
  static const Color lightUserBubble = Color(0xFF1A1A2E);
  static const Color lightText = Color(0xFF1A1A2E);
  static const Color lightSubText = Color(0xFF8A8FAB);
  static const Color lightBorder = Color(0xFFEAECF4);
  static const Color lightInputBg = Color(0xFFF0F2FA);

  static const Color darkBg = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkBotBubble = Color(0xFF1E1E32);
  static const Color darkUserBubble = Color(0xFF4F46E5);
  static const Color darkText = Color(0xFFF0F1FF);
  static const Color darkSubText = Color(0xFF6B7280);
  static const Color darkBorder = Color(0xFF2A2A45);
  static const Color darkInputBg = Color(0xFF1E1E32);

  static const Color accent = Color(0xFF4F46E5);
  static const Color accentLight = Color(0xFF818CF8);
  static const Color accentGlow = Color(0x334F46E5);
  static const Color success = Color(0xFF10B981);
  static const Color gold = Color(0xFFF59E0B);
  static const Color price = Color(0xFF059669);
  static const Color tag = Color(0xFF7C3AED);
}

const String kGrokLogoUrl =
    'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/Grok-feb-2025-logo.svg/1280px-Grok-feb-2025-logo.svg.png';

enum BlockType {
  heading,
  subHeading,
  paragraph,
  bullet,
  numbered,
  price,
  productCard,
  imageRow,
  divider,
  badge,
}

class MessageBlock {
  final BlockType type;
  final String text;
  final String? imageUrl;
  final List<String>? imageUrls;
  final int? number;
  final String? badgeLabel;

  const MessageBlock({
    required this.type,
    this.text = '',
    this.imageUrl,
    this.imageUrls,
    this.number,
    this.badgeLabel,
  });
}

class MessageParser {
  static final RegExp _imageUrlRegex = RegExp(
    r'https?://[^\s<>"{}|\\^`\[\]]+\.(?:jpg|jpeg|png|gif|webp)(\?[^\s]*)?',
    caseSensitive: false,
  );

  static final RegExp _anyUrlRegex = RegExp(
    r'https?://[^\s<>"{}|\\^`\[\]]+',
    caseSensitive: false,
  );

  static List<String> extractImageUrls(String text) =>
      _imageUrlRegex.allMatches(text).map((m) => m.group(0)!).toList();

  static String cleanText(String text) {
    String result = text;
    result = result.replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), '');
    result = result.replaceAll(_anyUrlRegex, '');
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return result.trim();
  }

  static List<MessageBlock> parse(String rawText, List<String> extraImages) {
    final inlineImages = extractImageUrls(rawText);
    final allImages = [...inlineImages, ...extraImages].toSet().toList();

    final cleaned = cleanText(rawText);
    final lines = cleaned.split('\n');

    final List<MessageBlock> blocks = [];
    int imageIndex = 0;

    int lineIdx = 0;
    while (lineIdx < lines.length) {
      final raw = lines[lineIdx];
      final line = raw.trim();
      lineIdx++;

      if (line.isEmpty) continue;

      if (line.startsWith('### ') ||
          line.startsWith('## ') ||
          line.startsWith('# ')) {
        final text = line.replaceAll(RegExp(r'^#{1,3}\s+'), '').trim();
        blocks.add(MessageBlock(type: BlockType.heading, text: text));
        continue;
      }

      final boldMatch = RegExp(r'^\*{2}(.+?)\*{2}$').firstMatch(line);
      if (boldMatch != null) {
        blocks.add(
          MessageBlock(
            type: BlockType.subHeading,
            text: boldMatch.group(1)!.trim(),
          ),
        );
        continue;
      }

      if (RegExp(r'^[-*─]{3,}$').hasMatch(line)) {
        blocks.add(const MessageBlock(type: BlockType.divider));
        continue;
      }

      final numberedMatch = RegExp(r'^(\d+)[.)]\s+(.+)$').firstMatch(line);
      if (numberedMatch != null) {
        final num = int.tryParse(numberedMatch.group(1)!) ?? 0;
        String itemText = numberedMatch.group(2)!;

        bool hasPrice =
            itemText.contains(RegExp(r'[\$₹€£]')) ||
            itemText.toLowerCase().contains('price') ||
            itemText.toLowerCase().contains('rs.');

        if (imageIndex < allImages.length && _looksLikeProduct(itemText)) {
          blocks.add(
            MessageBlock(
              type: BlockType.productCard,
              text: _stripInlineMarkdown(itemText),
              imageUrl: allImages[imageIndex],
              number: num,
            ),
          );
          imageIndex++;
        } else {
          blocks.add(
            MessageBlock(
              type: hasPrice ? BlockType.price : BlockType.numbered,
              text: _stripInlineMarkdown(itemText),
              number: num,
            ),
          );
        }
        continue;
      }

      if (line.startsWith('•') ||
          line.startsWith('-') ||
          line.startsWith('*')) {
        String bulletText = line
            .replaceFirst(RegExp(r'^[•\-\*]\s*'), '')
            .trim();

        if (imageIndex < allImages.length && _looksLikeProduct(bulletText)) {
          blocks.add(
            MessageBlock(
              type: BlockType.productCard,
              text: _stripInlineMarkdown(bulletText),
              imageUrl: allImages[imageIndex],
            ),
          );
          imageIndex++;
        } else {
          blocks.add(
            MessageBlock(
              type: BlockType.bullet,
              text: _stripInlineMarkdown(bulletText),
            ),
          );
        }
        continue;
      }

      if (_isPriceLine(line)) {
        blocks.add(
          MessageBlock(type: BlockType.price, text: _stripInlineMarkdown(line)),
        );
        continue;
      }

      final productLineMatch = RegExp(
        r'^\*{2}(.+?)\*{2}[:\s](.+)$',
      ).firstMatch(line);
      if (productLineMatch != null) {
        final name = productLineMatch.group(1)!.trim();
        final desc = productLineMatch.group(2)!.trim();

        if (imageIndex < allImages.length) {
          blocks.add(
            MessageBlock(
              type: BlockType.productCard,
              text: '$name: $desc',
              imageUrl: allImages[imageIndex],
            ),
          );
          imageIndex++;
        } else {
          blocks.add(
            MessageBlock(type: BlockType.subHeading, text: '$name: $desc'),
          );
        }
        continue;
      }

      blocks.add(
        MessageBlock(
          type: BlockType.paragraph,
          text: _stripInlineMarkdown(line),
        ),
      );
    }

    if (imageIndex < allImages.length) {
      final remaining = allImages.sublist(imageIndex);
      blocks.add(MessageBlock(type: BlockType.imageRow, imageUrls: remaining));
    }

    return blocks;
  }

  static bool _looksLikeProduct(String text) {
    final lower = text.toLowerCase();
    return lower.contains('price') ||
        lower.contains('rs.') ||
        lower.contains('\$') ||
        lower.contains('₹') ||
        lower.contains('buy') ||
        lower.contains('product') ||
        lower.contains('item') ||
        lower.contains('model') ||
        lower.contains('brand') ||
        RegExp(r'\*{2}.+\*{2}').hasMatch(text);
  }

  static bool _isPriceLine(String text) {
    return RegExp(r'[\$₹€£]\s*[\d,]+').hasMatch(text) ||
        RegExp(
          r'(price|cost|rate|mrp|discount)\s*[:\-]',
          caseSensitive: false,
        ).hasMatch(text);
  }

  static String _stripInlineMarkdown(String text) {
    String r = text;
    r = r.replaceAllMapped(RegExp(r'\*{3}(.+?)\*{3}'), (m) => m.group(1)!);
    r = r.replaceAllMapped(RegExp(r'\*{2}(.+?)\*{2}'), (m) => m.group(1)!);
    r = r.replaceAllMapped(RegExp(r'\*(.+?)\*'), (m) => m.group(1)!);
    r = r.replaceAllMapped(RegExp(r'_{2}(.+?)_{2}'), (m) => m.group(1)!);
    r = r.replaceAllMapped(RegExp(r'_(.+?)_'), (m) => m.group(1)!);
    r = r.replaceAllMapped(RegExp(r'`(.+?)`'), (m) => m.group(1)!);
    return r.trim();
  }
}

class RichMessageContent extends StatelessWidget {
  final List<MessageBlock> blocks;
  final Color textColor;
  final bool isBot;
  final bool isDark;
  final Size size;

  const RichMessageContent({
    super.key,
    required this.blocks,
    required this.textColor,
    required this.isBot,
    required this.isDark,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.asMap().entries.map((entry) {
        final i = entry.key;
        final block = entry.value;
        return Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : 6),
          child: _buildBlock(context, block),
        );
      }).toList(),
    );
  }

  Widget _buildBlock(BuildContext context, MessageBlock block) {
    switch (block.type) {
      case BlockType.heading:
        return _HeadingBlock(text: block.text, isDark: isDark, isBot: isBot);

      case BlockType.subHeading:
        return _SubHeadingBlock(
          text: block.text,
          isDark: isDark,
          isBot: isBot,
          textColor: textColor,
        );

      case BlockType.bullet:
        return _BulletBlock(
          text: block.text,
          textColor: textColor,
          isBot: isBot,
        );

      case BlockType.numbered:
        return _NumberedBlock(
          text: block.text,
          number: block.number ?? 1,
          textColor: textColor,
          isBot: isBot,
        );

      case BlockType.price:
        return _PriceBlock(text: block.text, isDark: isDark);

      case BlockType.productCard:
        return _ProductCardBlock(
          text: block.text,
          imageUrl: block.imageUrl,
          number: block.number,
          isDark: isDark,
          textColor: textColor,
          isBot: isBot,
          size: size,
        );

      case BlockType.imageRow:
        return _ImageRowBlock(
          imageUrls: block.imageUrls ?? [],
          isDark: isDark,
          size: size,
        );

      case BlockType.divider:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Container(
            height: 1,
            color: isDark
                ? AppColors.darkBorder.withOpacity(0.6)
                : AppColors.lightBorder,
          ),
        );

      case BlockType.badge:
        return _BadgeBlock(label: block.badgeLabel ?? '', text: block.text);

      case BlockType.paragraph:
      default:
        return Text(
          block.text,
          style: TextStyle(color: textColor, fontSize: 14, height: 1.6),
        );
    }
  }
}

class _HeadingBlock extends StatelessWidget {
  final String text;
  final bool isDark, isBot;
  const _HeadingBlock({
    required this.text,
    required this.isDark,
    required this.isBot,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.accentLight],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isBot ? AppColors.accent : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubHeadingBlock extends StatelessWidget {
  final String text;
  final bool isDark, isBot;
  final Color textColor;
  const _SubHeadingBlock({
    required this.text,
    required this.isDark,
    required this.isBot,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Text(
        text,
        style: TextStyle(
          color: isBot
              ? (isDark ? AppColors.accentLight : AppColors.accent)
              : Colors.white,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _BulletBlock extends StatelessWidget {
  final String text;
  final Color textColor;
  final bool isBot;
  const _BulletBlock({
    required this.text,
    required this.textColor,
    required this.isBot,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: isBot ? AppColors.accent : Colors.white70,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: textColor, fontSize: 14, height: 1.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberedBlock extends StatelessWidget {
  final String text;
  final int number;
  final Color textColor;
  final bool isBot;
  const _NumberedBlock({
    required this.text,
    required this.number,
    required this.textColor,
    required this.isBot,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isBot
                  ? AppColors.accent.withOpacity(0.15)
                  : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: isBot ? AppColors.accent : Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: textColor, fontSize: 14, height: 1.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceBlock extends StatelessWidget {
  final String text;
  final bool isDark;
  const _PriceBlock({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.price.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.price.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_offer_rounded,
            color: AppColors.price,
            size: 14,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.price,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeBlock extends StatelessWidget {
  final String label;
  final String text;
  const _BadgeBlock({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (label.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.tag.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.tag.withOpacity(0.3)),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.tag,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        if (text.isNotEmpty)
          Text(text, style: const TextStyle(fontSize: 14, height: 1.5)),
      ],
    );
  }
}

class _ProductCardBlock extends StatelessWidget {
  final String text;
  final String? imageUrl;
  final int? number;
  final bool isDark;
  final Color textColor;
  final bool isBot;
  final Size size;

  const _ProductCardBlock({
    required this.text,
    this.imageUrl,
    this.number,
    required this.isDark,
    required this.textColor,
    required this.isBot,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark
        ? AppColors.darkBorder.withOpacity(0.5)
        : AppColors.lightBorder.withOpacity(0.6);

    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 2),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppColors.accent.withOpacity(0.2)
              : AppColors.accent.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              GestureDetector(
                onTap: () => _showFullImage(context, imageUrl!),
                child: Container(
                  width: 100,
                  height: 110,
                  color: isDark ? AppColors.darkBg : AppColors.lightBg,
                  child: Stack(
                    children: [
                      Image.network(
                        imageUrl!,
                        width: 100,
                        height: 110,
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.accent,
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                          progress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            color: isDark
                                ? AppColors.darkSubText
                                : AppColors.lightSubText,
                            size: 28,
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.zoom_in_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (number != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '#$number',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],

                    ..._buildProductText(text, textColor, isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildProductText(String text, Color textColor, bool isDark) {
    final colonIdx = text.indexOf(':');
    if (colonIdx > 0 && colonIdx < 40) {
      final name = text.substring(0, colonIdx).trim();
      final desc = text.substring(colonIdx + 1).trim();
      return [
        Text(
          name,
          style: TextStyle(
            color: isDark ? AppColors.accentLight : AppColors.accent,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          desc,
          style: TextStyle(
            color: textColor.withOpacity(0.85),
            fontSize: 12.5,
            height: 1.5,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ];
    }

    final priceMatch = RegExp(
      r'([\$₹€£][\s]?[\d,]+(?:\.\d{1,2})?)',
    ).firstMatch(text);
    if (priceMatch != null) {
      final priceStr = priceMatch.group(0)!;
      final rest = text.replaceAll(priceStr, '').trim();
      return [
        Text(
          rest,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.price.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            priceStr,
            style: const TextStyle(
              color: AppColors.price,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ];
    }

    return [
      Text(
        text,
        style: TextStyle(color: textColor, fontSize: 13, height: 1.5),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    ];
  }

  void _showFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(url, fit: BoxFit.contain),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageRowBlock extends StatelessWidget {
  final List<String> imageUrls;
  final bool isDark;
  final Size size;
  const _ImageRowBlock({
    required this.imageUrls,
    required this.isDark,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: SizedBox(
        height: 150,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: imageUrls.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (ctx, idx) => GestureDetector(
            onTap: () {
              showDialog(
                context: ctx,
                barrierColor: Colors.black87,
                builder: (_) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(imageUrls[idx]),
                  ),
                ),
              );
            },
            child: Container(
              width: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrls[idx],
                  fit: BoxFit.cover,
                  loadingBuilder: (ctx2, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: isDark
                          ? AppColors.darkSubText
                          : AppColors.lightSubText,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StreamingMessageWidget extends StatefulWidget {
  final List<MessageBlock> blocks;
  final Color textColor;
  final bool isDark;
  final Size size;
  final VoidCallback? onComplete;

  const StreamingMessageWidget({
    super.key,
    required this.blocks,
    required this.textColor,
    required this.isDark,
    required this.size,
    this.onComplete,
  });

  @override
  State<StreamingMessageWidget> createState() => _StreamingMessageWidgetState();
}

class _StreamingMessageWidgetState extends State<StreamingMessageWidget> {
  int _completedBlocks = 0;
  int _currentWordIndex = 0;
  List<String> _currentWords = [];
  Timer? _timer;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _startStreaming();
  }

  void _startStreaming() {
    _prepareCurrentBlock();
  }

  void _prepareCurrentBlock() {
    if (_completedBlocks >= widget.blocks.length) {
      setState(() => _done = true);
      widget.onComplete?.call();
      return;
    }

    final block = widget.blocks[_completedBlocks];

    if (block.type == BlockType.imageRow ||
        block.type == BlockType.divider ||
        block.type == BlockType.productCard) {
      setState(() => _completedBlocks++);

      Future.delayed(const Duration(milliseconds: 80), _prepareCurrentBlock);
      return;
    }

    _currentWords = block.text.split(' ').where((w) => w.isNotEmpty).toList();
    _currentWordIndex = 0;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 28), (t) {
      if (_currentWordIndex < _currentWords.length) {
        setState(() => _currentWordIndex++);
      } else {
        t.cancel();
        setState(() {
          _completedBlocks++;
          _currentWords = [];
          _currentWordIndex = 0;
        });

        Future.delayed(const Duration(milliseconds: 40), _prepareCurrentBlock);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<MessageBlock> visibleBlocks = [];

    for (int i = 0; i < widget.blocks.length; i++) {
      if (i < _completedBlocks) {
        visibleBlocks.add(widget.blocks[i]);
      } else if (i == _completedBlocks && !_done && _currentWords.isNotEmpty) {
        final partial = _currentWords.sublist(0, _currentWordIndex).join(' ');
        if (partial.isNotEmpty) {
          visibleBlocks.add(
            MessageBlock(
              type: widget.blocks[i].type,
              text: partial,
              number: widget.blocks[i].number,
            ),
          );
        }
        break;
      } else {
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichMessageContent(
          blocks: visibleBlocks,
          textColor: widget.textColor,
          isBot: true,
          isDark: widget.isDark,
          size: widget.size,
        ),

        if (!_done)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: _BlinkingCursor(),
          ),
      ],
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Opacity(
        opacity: _controller.value,
        child: Container(
          width: 2,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}

class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<Map<String, dynamic>> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'messages': messages,
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    DateTime parseDate;
    try {
      parseDate = json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now();
    } catch (_) {
      parseDate = DateTime.now();
    }
    return ChatSession(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'New Chat',
      createdAt: parseDate,
      messages: json['messages'] != null
          ? List<Map<String, dynamic>>.from(json['messages'])
          : [],
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _typingAnimController;
  final FocusNode _focusNode = FocusNode();

  List<ChatSession> _chatHistory = [];
  String? _currentSessionId;
  String? _sessionId;

  Future<Map<String, dynamic>> _resolveProduct(
    Map<String, dynamic> intentProduct,
    StoreViewModel storeVM,
  ) async {
    final productName = (intentProduct['name'] as String? ?? '').toLowerCase();

    print('🔍 Resolving product: $productName');
    print('🔍 intentProduct data: $intentProduct');

    for (final p in storeVM.categoryWiseProducts) {
      if ((p['productName'] as String? ?? '').toLowerCase() == productName) {
        print('✅ Found in categoryWiseProducts: ${p['productPrice']}');
        return p;
      }
    }

    for (final p in storeVM.favList) {
      if ((p['productName'] as String? ?? '').toLowerCase() == productName) {
        print('✅ Found in favList: ${p['productPrice']}');
        return p;
      }
    }

    try {
      print('🔥 Fetching from Firestore: ${intentProduct['name']}');
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('productName', isEqualTo: intentProduct['name'])
          .limit(1)
          .get();

      print('🔥 Firestore docs found: ${snapshot.docs.length}');

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        print('🔥 Raw Firestore data: $data');
        print(
          '🔥 productPrice raw: ${data['productPrice']} (${data['productPrice'].runtimeType})',
        );
        print(
          '🔥 productDiscount raw: ${data['productDiscount']} (${data['productDiscount'].runtimeType})',
        );

        final rawPrice = data['productPrice'];
        final price = rawPrice is int
            ? rawPrice
            : int.tryParse(rawPrice?.toString() ?? '0') ?? 0;

        final rawDiscount = data['productDiscount'];
        final discount = rawDiscount is int
            ? rawDiscount
            : int.tryParse(rawDiscount?.toString() ?? '0') ?? 0;

        final discountedPrice = discount > 0
            ? (price - (price * discount / 100)).toInt()
            : price;

        print(
          '✅ Final price: $discountedPrice (original: $price, discount: $discount%)',
        );

        final imageUrls = data['productImageUrls'];
        final List<String> images = imageUrls is List
            ? List<String>.from(imageUrls)
            : [];

        final resolved = {
          'productName': data['productName'] ?? '',
          'categoryName': data['categoryName'] ?? '',
          'productPrice': discountedPrice,
          'productImageUrls': images,
          'productDescription': data['productDescription'] ?? '',
          'productDiscount': discount,
        };

        print('✅ Resolved product map: $resolved');
        return resolved;
      }
    } catch (e) {
      print('❌ Firestore fetch error: $e');
    }

    print('⚠️ Using fallback for: ${intentProduct['name']}');
    return {
      'productName': intentProduct['name'] ?? '',
      'categoryName': '',
      'productPrice':
          int.tryParse(
            intentProduct['price']?.toString().replaceAll(
                  RegExp(r'[^0-9]'),
                  '',
                ) ??
                '0',
          ) ??
          0,
      'productImageUrls': intentProduct['image_url'] != null
          ? [intentProduct['image_url']]
          : [],
      'productDescription': '',
      'productDiscount': 0,
    };
  }

  Future<void> _handleIntent(
    BuildContext context,
    Map<String, dynamic> response,
    StoreViewModel storeVM,
  ) async {
    final intent = response['intent'] as String?;
    final intentProducts =
        (response['intent_products'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        [];

    if (intent == null) return;

    final authVM = Provider.of<AuthViewModel>(context, listen: false);

    switch (intent) {
      case 'add_to_cart':
        if (intentProducts.isEmpty) break;

        Box<CartModel> cartBox;
        try {
          cartBox = authVM.getCartBox();
        } catch (_) {
          if (mounted)
            _showIntentSnackbar('Please log in to add items to cart');
          break;
        }

        int addedCount = 0;
        for (final intentProduct in intentProducts) {
          final product = await _resolveProduct(intentProduct, storeVM);
          await storeVM.addSingleToCart(
            Map<String, dynamic>.from(product),
            cartBox,
          );
          addedCount++;
        }

        if (mounted && addedCount > 0) {
          final label = addedCount == 1
              ? '"${intentProducts.first['name']}" added to cart!'
              : '$addedCount items added to cart!';
          _showIntentSnackbar(
            '🛒 $label',
            actionLabel: 'View Cart',
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CartScreen()),
            ),
          );
        }
        break;
      case 'checkout':
        if (mounted) {
          int totalAmount = 0;
          int itemCount = 0;
          String itemSummary = '';
          List<CartModel> cartItems = [];

          try {
            final cartBox = authVM.getCartBox();
            cartItems = cartBox.values.toList();
            itemCount = cartItems.length;

            for (final item in cartItems) {
              totalAmount += item.productPrice * item.quantity;
            }

            if (itemCount == 0) {
              itemSummary = 'Your cart is empty';
            } else if (itemCount == 1) {
              itemSummary =
                  '"${cartItems.first.productName}" · Rs $totalAmount';
            } else {
              itemSummary = '$itemCount items · Rs $totalAmount total';
            }
          } catch (e) {
            debugPrint('Cart read error: $e');
            itemSummary = 'Could not load cart';
          }

          _showIntentConfirmDialog(
            title: 'Proceed to Checkout?',
            message: itemCount > 0
                ? '🛒 $itemSummary ready to order.'
                : 'Your cart is empty. Add some products first!',
            confirmLabel: itemCount > 0 ? 'Checkout' : 'OK',
            onConfirm: () {
              if (itemCount > 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckOutScreen(cartItems: cartItems),
                  ),
                );
              }
            },
          );
        }
        break;

      case 'navigate_cart':
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CartScreen()),
          );
        }
        break;

      case 'add_to_wishlist':
        if (intentProducts.isEmpty) break;

        int wishCount = 0;
        for (final intentProduct in intentProducts) {
          final product = await _resolveProduct(intentProduct, storeVM);
          storeVM.toggleFavValue(product);
          wishCount++;
        }

        if (mounted && wishCount > 0) {
          debugPrint('🧾 INTENT: $intent');
          debugPrint('🧾 INTENT PRODUCTS: $intentProducts');
          final label = wishCount == 1
              ? '"${intentProducts.first['name']}" added to wishlist!'
              : '$wishCount items added to wishlist!';
          _showIntentSnackbar(
            '❤️ $label',
            actionLabel: 'View Wishlist',
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FavouriteScreen()),
            ),
          );
        }
        break;

      case 'navigate_wishlist':
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FavouriteScreen()),
          );
        }
        break;
    }
  }

  void _showIntentSnackbar(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }

  void _showIntentConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              confirmLabel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  List<MessageBlock> _pendingBlocks = [];
  bool _hasText = false;

  static String _currentTime() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  static String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  void initState() {
    super.initState();
    _typingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _messageController.addListener(() {
      final hasText = _messageController.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });

    _focusNode.addListener(() => setState(() {}));
    _checkAndFixCorruptedData();
  }

  Future<void> _checkAndFixCorruptedData() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getStringList('chat_sessions') ?? [];
    bool needsFix = false;
    for (String jsonStr in sessionsJson) {
      try {
        final d = jsonDecode(jsonStr);
        if (d['createdAt'] == null || d['id'] == null) {
          needsFix = true;
          break;
        }
      } catch (_) {
        needsFix = true;
        break;
      }
    }
    if (needsFix) await prefs.remove('chat_sessions');
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getStringList('chat_sessions') ?? [];
    final loaded = <ChatSession>[];
    for (String s in sessionsJson) {
      try {
        loaded.add(ChatSession.fromJson(jsonDecode(s)));
      } catch (_) {}
    }
    setState(() {
      _chatHistory = loaded..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
    if (_chatHistory.isNotEmpty) {
      _loadSession(_chatHistory.first);
    } else {
      _startNewChat();
    }
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'chat_sessions',
      _chatHistory.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }

  Future<void> _saveCurrentToHistory() async {
    if (_messages.isEmpty || _messages.length <= 1) return;
    final userMsgs = _messages.where((m) => m['sender'] == 'user').toList();
    if (userMsgs.isEmpty) return;

    final title = (userMsgs.last['text'] as String? ?? '');
    final shortTitle = title.length > 40
        ? '${title.substring(0, 40)}...'
        : title;

    final cleanMessages = _messages.map((msg) {
      List<String> imgs = [];
      if (msg['images'] is List) imgs = List<String>.from(msg['images']);
      return {
        'sender': msg['sender'],
        'text': msg['text'] ?? '',
        'time': msg['time'] ?? _currentTime(),
        'images': imgs,
      };
    }).toList();

    final existingIdx = _chatHistory.indexWhere(
      (s) => s.id == (_currentSessionId ?? ''),
    );
    if (existingIdx != -1) {
      _chatHistory[existingIdx] = ChatSession(
        id: _chatHistory[existingIdx].id,
        title: shortTitle,
        createdAt: _chatHistory[existingIdx].createdAt,
        messages: cleanMessages,
      );
    } else if (_currentSessionId != null) {
      _chatHistory.insert(
        0,
        ChatSession(
          id: _currentSessionId!,
          title: shortTitle,
          createdAt: DateTime.now(),
          messages: cleanMessages,
        ),
      );
    }
    await _saveChatHistory();
  }

  void _startNewChat() async {
    await _saveCurrentToHistory();
    setState(() {
      _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
      _sessionId = null;
      _messages = [
        {
          "sender": "bot",
          "text":
              "✨ Hello! I'm your AI shopping assistant\n\nI can help you with:\n• 📦 Product questions & prices\n• 🚚 Order tracking\n• 💳 Payment support\n• 🔄 Returns & refunds\n\nHow can I help you today?",
          "time": _currentTime(),
          "images": <String>[],
        },
      ];
    });
    if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  void _loadSession(ChatSession session) async {
    await _saveCurrentToHistory();
    setState(() {
      _currentSessionId = session.id;
      _sessionId = null;
      _messages = List.from(session.messages);
    });
    if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
    _scrollToBottom();
  }

  Future<void> _deleteSession(String id) async {
    setState(() => _chatHistory.removeWhere((s) => s.id == id));
    await _saveChatHistory();
    if (_chatHistory.isEmpty) {
      _startNewChat();
    } else if (_currentSessionId == id) {
      _loadSession(_chatHistory.first);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading || _isTyping) return;

    setState(() {
      _messages.insert(0, {
        "sender": "user",
        "text": text,
        "time": _currentTime(),
        "images": <String>[],
      });
      _isLoading = true;
    });
    _messageController.clear();
    await _saveCurrentToHistory();

    try {
      final response = await ChatService.sendMessage(text, _sessionId);
      if (!mounted) return;

      final rawText = response['bot_message']['text'] as String? ?? '';
      List<String> imageUrls = MessageParser.extractImageUrls(rawText).toList();
      if (response['matched_image_urls'] is List) {
        for (var u in response['matched_image_urls']) {
          if (u is String && !imageUrls.contains(u)) imageUrls.add(u);
        }
      }

      final blocks = MessageParser.parse(rawText, imageUrls);

      setState(() {
        _sessionId = response['session_id'];
        _pendingBlocks = blocks;
        _isLoading = false;
        _isTyping = true;
      });

      final storeVM = Provider.of<StoreViewModel>(context, listen: false);
      await _handleIntent(context, response, storeVM);

      _scrollToBottom();
    } catch (e) {
      debugPrint('Error: $e');
      if (!mounted) return;
      setState(() {
        _messages.insert(0, {
          "sender": "bot",
          "text":
              "❌ Sorry, I couldn't reach the server. Make sure your Django backend is running.",
          "time": _currentTime(),
          "images": <String>[],
        });
        _isLoading = false;
      });
    }
  }

  void _onStreamingComplete() {
    final text = _pendingBlocks
        .where(
          (b) =>
              b.type != BlockType.imageRow && b.type != BlockType.productCard,
        )
        .map((b) => b.text)
        .join('\n');

    final images = _pendingBlocks
        .where(
          (b) =>
              b.type == BlockType.productCard && b.imageUrl != null ||
              b.type == BlockType.imageRow,
        )
        .expand(
          (b) =>
              b.imageUrls ?? (b.imageUrl != null ? [b.imageUrl!] : <String>[]),
        )
        .toList();

    setState(() {
      _messages.insert(0, {
        "sender": "bot",
        "text": text,
        "time": _currentTime(),
        "images": images,

        "blocks": _pendingBlocks
            .map(
              (b) => {
                'type': b.type.index,
                'text': b.text,
                'imageUrl': b.imageUrl,
                'imageUrls': b.imageUrls,
                'number': b.number,
              },
            )
            .toList(),
      });
      _isTyping = false;
      _pendingBlocks = [];
    });
    _saveCurrentToHistory();
  }

  List<MessageBlock> _blocksFromMessage(Map<String, dynamic> msg) {
    if (msg['blocks'] != null) {
      try {
        return (msg['blocks'] as List).map((b) {
          return MessageBlock(
            type: BlockType.values[b['type'] as int],
            text: b['text'] as String? ?? '',
            imageUrl: b['imageUrl'] as String?,
            imageUrls: b['imageUrls'] != null
                ? List<String>.from(b['imageUrls'])
                : null,
            number: b['number'] as int?,
          );
        }).toList();
      } catch (_) {}
    }

    final text = msg['text'] as String? ?? '';
    final images = msg['images'] is List
        ? List<String>.from(msg['images'])
        : <String>[];
    return MessageParser.parse(text, images);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimController.dispose();
    _focusNode.dispose();
    _saveCurrentToHistory();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subText = isDark ? AppColors.darkSubText : AppColors.lightSubText;
    final inputBg = isDark ? AppColors.darkInputBg : AppColors.lightInputBg;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bg,
      resizeToAvoidBottomInset: true,
      drawer: _buildHistoryDrawer(
        isDark,
        surface,
        textColor,
        subText,
        borderColor,
      ),
      body: Column(
        children: [
          _buildHeader(
            isDark,
            surface,
            textColor,
            subText,
            borderColor,
            padding,
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: 12,
              ),
              itemCount:
                  _messages.length + (_isTyping ? 1 : 0) + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == 0) {
                  return _buildStreamingBotMessage(
                    isDark,
                    size,
                    textColor,
                    subText,
                  );
                }
                if (_isLoading && index == (_isTyping ? 1 : 0)) {
                  return _buildTypingIndicator(isDark);
                }
                final int offset = (_isTyping ? 1 : 0) + (_isLoading ? 1 : 0);
                final int msgIndex = index - offset;
                if (msgIndex < 0 || msgIndex >= _messages.length) {
                  return const SizedBox.shrink();
                }
                final message = _messages[msgIndex];
                final isBot = message["sender"] == "bot";
                return _buildMessageBubble(
                  message,
                  isBot,
                  isDark,
                  textColor,
                  subText,
                  size,
                );
              },
            ),
          ),
          _buildInputBar(
            isDark,
            surface,
            inputBg,
            textColor,
            subText,
            borderColor,
            padding,
            keyboardVisible,
          ),
        ],
      ),
    );
  }

  Widget _buildStreamingBotMessage(
    bool isDark,
    Size size,
    Color textColor,
    Color subText,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _botAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: size.width * 0.78),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: _botBubbleDecoration(isDark),
                  child: StreamingMessageWidget(
                    blocks: _pendingBlocks,
                    textColor: textColor,
                    isDark: isDark,
                    size: size,
                    onComplete: _onStreamingComplete,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentTime(),
                  style: TextStyle(
                    color: subText,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    Map<String, dynamic> message,
    bool isBot,
    bool isDark,
    Color textColor,
    Color subText,
    Size size,
  ) {
    final msgTextColor = isBot ? textColor : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isBot
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBot) ...[_botAvatar(), const SizedBox(width: 8)],
          Flexible(
            child: Column(
              crossAxisAlignment: isBot
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: size.width * (isBot ? 0.78 : 0.72),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: isBot
                      ? _botBubbleDecoration(isDark)
                      : _userBubbleDecoration(isDark),
                  child: isBot
                      ? RichMessageContent(
                          blocks: _blocksFromMessage(message),
                          textColor: msgTextColor,
                          isBot: true,
                          isDark: isDark,
                          size: size,
                        )
                      : Text(
                          message['text'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  message["time"] ?? "",
                  style: TextStyle(
                    color: subText,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (!isBot) ...[const SizedBox(width: 8), _userAvatar()],
        ],
      ),
    );
  }

  Widget _botAvatar() => Container(
    width: 32,
    height: 32,
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color.fromARGB(255, 21, 21, 22),
          Color.fromARGB(255, 116, 117, 117),
        ],
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Image.network(
      kGrokLogoUrl,
      fit: BoxFit.contain,
      color: Colors.white,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16),
    ),
  );

  Widget _userAvatar() => Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      gradient: MyAppColor.AppColors.primaryGradient,
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
  );

  BoxDecoration _botBubbleDecoration(bool isDark) => BoxDecoration(
    color: isDark ? AppColors.darkBotBubble : AppColors.lightBotBubble,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(4),
      topRight: Radius.circular(18),
      bottomLeft: Radius.circular(18),
      bottomRight: Radius.circular(18),
    ),
    border: Border.all(
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );

  BoxDecoration _userBubbleDecoration(bool isDark) => BoxDecoration(
    gradient: LinearGradient(
      colors: isDark
          ? [
              AppColors.lightUserBubble,
              const Color.fromARGB(255, 127, 127, 134),
            ]
          : [
              AppColors.lightUserBubble,
              const Color.fromARGB(255, 127, 127, 134),
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(18),
      topRight: Radius.circular(4),
      bottomLeft: Radius.circular(18),
      bottomRight: Radius.circular(18),
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.accent.withOpacity(0.3),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _botAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: _botBubbleDecoration(isDark),
            child: AnimatedBuilder(
              animation: _typingAnimController,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final delay = i * 0.3;
                    final v =
                        (((_typingAnimController.value - delay) % 1.0 + 1.0) %
                        1.0);
                    final opacity = v < 0.5 ? v * 2 : (1.0 - v) * 2;
                    return Container(
                      margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(
                          0.4 + opacity * 0.6,
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryDrawer(
    bool isDark,
    Color surface,
    Color textColor,
    Color subText,
    Color borderColor,
  ) {
    final padding = MediaQuery.of(context).padding;
    return Drawer(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: padding.top + 16,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBg : AppColors.lightBg,
              border: Border(bottom: BorderSide(color: borderColor, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  AppColors.lightUserBubble,
                                  const Color.fromARGB(255, 78, 77, 77),
                                ]
                              : [
                                  AppColors.lightUserBubble,
                                  const Color.fromARGB(255, 78, 77, 77),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.network(
                        kGrokLogoUrl,
                        fit: BoxFit.contain,
                        color: AppColors.darkText,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.smart_toy_rounded,
                          color: AppColors.accent,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Chat History',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: _startNewChat,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 11,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: MyAppColor.AppColors.cardGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentGlow,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'New Chat',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _chatHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 48,
                          color: subText.withOpacity(0.35),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No chat history yet',
                          style: TextStyle(color: subText, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    itemCount: _chatHistory.length,
                    itemBuilder: (ctx, idx) {
                      final s = _chatHistory[idx];
                      final isActive = s.id == _currentSessionId;
                      return _buildHistoryTile(
                        s,
                        isActive,
                        isDark,
                        textColor,
                        subText,
                        borderColor,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(
    ChatSession session,
    bool isActive,
    bool isDark,
    Color textColor,
    Color subText,
    Color borderColor,
  ) {
    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.red, size: 20),
      ),
      onDismissed: (_) => _deleteSession(session.id),
      child: GestureDetector(
        onTap: () => _loadSession(session),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.transparent : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(
                    color: MyAppColor.AppColors.primaryDark.withBlue(200),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isActive
                            ? MyAppColor.AppColors.textPrimary(context)
                            : textColor,
                        fontSize: 13,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(session.createdAt),
                      style: TextStyle(color: subText, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    bool isDark,
    Color surface,
    Color textColor,
    Color subText,
    Color borderColor,
    EdgeInsets padding,
  ) {
    return Container(
      padding: EdgeInsets.only(
        top: padding.top + 8,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: surface,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBg : AppColors.lightBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.menu_rounded, size: 20, color: textColor),
            ),
          ),

          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ecommerce AI Assistant',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 1),
              ],
            ),
          ),
          GestureDetector(
            onTap: _startNewChat,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBg : AppColors.lightBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.add,
                size: 20,
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(
    bool isDark,
    Color surface,
    Color inputBg,
    Color textColor,
    Color subText,
    Color borderColor,
    EdgeInsets padding,
    bool keyboardVisible,
  ) {
    final canSend = _hasText && !_isLoading && !_isTyping;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: keyboardVisible ? 10 : padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: inputBg,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: _focusNode.hasFocus
                ? AppColors.accent.withOpacity(0.5)
                : borderColor,
            width: _focusNode.hasFocus ? 1.5 : 1,
          ),
          boxShadow: _focusNode.hasFocus
              ? [
                  BoxShadow(
                    color: AppColors.accentGlow,
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                enabled: !_isLoading && !_isTyping,
                onSubmitted: (_) => canSend ? _sendMessage() : null,
                style: TextStyle(color: textColor, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Ask about products, orders...',
                  hintStyle: TextStyle(color: subText, fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                maxLines: 4,
                minLines: 1,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(6),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: canSend
                      ? const LinearGradient(
                          colors: [AppColors.accent, AppColors.accentLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: canSend
                      ? null
                      : (isDark
                            ? AppColors.darkBorder
                            : const Color(0xFFDDE0EE)),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: canSend
                      ? [
                          BoxShadow(
                            color: AppColors.accentGlow,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: canSend ? _sendMessage : null,
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _isLoading || _isTyping
                            ? SizedBox(
                                key: const ValueKey('loading'),
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: isDark
                                      ? AppColors.darkSubText
                                      : AppColors.lightSubText,
                                ),
                              )
                            : Icon(
                                Icons.arrow_upward_rounded,
                                key: const ValueKey('send'),
                                color: canSend
                                    ? Colors.white
                                    : (isDark
                                          ? AppColors.darkSubText
                                          : AppColors.lightSubText),
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
