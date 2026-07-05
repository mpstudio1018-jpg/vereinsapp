import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

/// Moderner, eleganter Button mit Hover-Effekten
class ModernButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? iconData;
  final double? width;
  final EdgeInsets padding;

  const ModernButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.iconData,
    this.width,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppTheme.spacingL,
      vertical: AppTheme.spacingM,
    ),
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _setHovering(bool hovering) {
    if (_isHovering != hovering) {
      setState(() => _isHovering = hovering);
      if (hovering) {
        _hoverController.forward();
      } else {
        _hoverController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isSecondary
        ? AppTheme.surfaceLight
        : AppTheme.primaryDark;

    final fgColor = widget.isSecondary
        ? AppTheme.accentOrange
        : AppTheme.textPrimary;

    return MouseRegion(
      onEnter: (_) => _setHovering(true),
      onExit: (_) => _setHovering(false),
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          final scale = 1.0 + (_hoverController.value * 0.05);
          final shadowBlur =
              AppTheme.shadowSmall.blurRadius +
              (_hoverController.value * 8);

          return Transform.scale(
            scale: scale,
            child: Container(
              width: widget.width,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppTheme.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: bgColor.withValues(alpha: 0.3),
                    blurRadius: shadowBlur,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed:
                    widget.isLoading ? null : widget.onPressed,
                icon: widget.isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            fgColor,
                          ),
                        ),
                      )
                    : (widget.iconData != null
                        ? Icon(widget.iconData)
                        : const SizedBox.shrink()),
                label: Text(widget.label),
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgColor,
                  foregroundColor: fgColor,
                  padding: widget.padding,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppTheme.radiusLarge,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Premium Card mit eleganten Schatten und Übergängen
class ModernCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool isClickable;

  const ModernCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.spacingL),
    this.borderRadius,
    this.backgroundColor,
    this.onTap,
    this.isClickable = false,
  });

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => widget.isClickable
          ? setState(() => _isHovering = true)
          : null,
      onExit: (_) =>
          widget.isClickable ? setState(() => _isHovering = false) : null,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppTheme.cardBackground,
            borderRadius:
                widget.borderRadius ??
                BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: [
              if (_isHovering) AppTheme.shadowMedium else AppTheme.shadowSmall,
            ],
          ),
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Modernes Fortschritts-Widget
class ModernProgressIndicator extends StatelessWidget {
  final double value;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final Widget? label;

  const ModernProgressIndicator({
    super.key,
    required this.value,
    this.height = 8,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          label!,
          const SizedBox(height: AppTheme.spacingS),
        ],
        ClipRRect(
          borderRadius:
              borderRadius ??
              BorderRadius.circular(AppTheme.radiusMedium),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1),
            minHeight: height,
            backgroundColor: backgroundColor ?? AppTheme.surfaceLight,
            valueColor: AlwaysStoppedAnimation(
              foregroundColor ?? AppTheme.accentOrange,
            ),
          ),
        ),
      ],
    );
  }
}

/// Empty State Widget für bessere UX
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            title,
            style: AppTheme.headingSmall,
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppTheme.spacingS),
            Text(
              subtitle!,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: AppTheme.spacingXL),
            ModernButton(
              label: actionLabel!,
              onPressed: onAction!,
            ),
          ],
        ],
      ),
    );
  }
}

/// Shimmer Loading Effect für elegante Lade-Animation
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(-1, -1),
                    end: const Alignment(1, 1),
                    transform:
                        GradientRotation(_controller.value * 6.3),
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
