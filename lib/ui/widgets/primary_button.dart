import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

enum PrimaryButtonVariant { primary, whatsapp, outlined, ghost }

class PrimaryButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final PrimaryButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;

  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.variant = PrimaryButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _bgColor {
    switch (widget.variant) {
      case PrimaryButtonVariant.whatsapp:
        return AppColors.whatsapp;
      case PrimaryButtonVariant.outlined:
        return Colors.transparent;
      case PrimaryButtonVariant.ghost:
        return AppColors.primaryLight;
      case PrimaryButtonVariant.primary:
        return AppColors.primary;
    }
  }

  Color get _textColor {
    switch (widget.variant) {
      case PrimaryButtonVariant.outlined:
        return AppColors.primary;
      case PrimaryButtonVariant.ghost:
        return AppColors.primary;
      case PrimaryButtonVariant.whatsapp:
      case PrimaryButtonVariant.primary:
        return AppColors.textOnPrimary;
    }
  }

  Border? get _border {
    if (widget.variant == PrimaryButtonVariant.outlined) {
      return Border.all(color: AppColors.primary, width: 1.5);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.isFullWidth ? double.infinity : null,
          height: widget.height ?? AppConstants.buttonHeight,
          padding: widget.isFullWidth
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: widget.onTap == null
                ? AppColors.textMuted
                : _bgColor,
            borderRadius:
            BorderRadius.circular(AppConstants.buttonRadius),
            border: _border,
            boxShadow: widget.variant == PrimaryButtonVariant.primary ||
                widget.variant == PrimaryButtonVariant.whatsapp
                ? [
              BoxShadow(
                color: _bgColor.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ]
                : null,
          ),
          child: widget.isLoading
              ? Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: _textColor,
              ),
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: widget.isFullWidth
                ? MainAxisSize.max
                : MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: _textColor, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: AppTextStyles.labelLarge
                    .copyWith(color: _textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}