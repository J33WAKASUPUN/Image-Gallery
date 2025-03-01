import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final VoidCallback? onTap;
  final Color? color;
  final BorderRadius? borderRadius;
  final Color? shadowColor;
  final Gradient? gradient;
  final Border? border;
  final double? width;
  final double? height;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation,
    this.onTap,
    this.color,
    this.borderRadius,
    this.shadowColor,
    this.gradient,
    this.border,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        gradient: gradient,
        border: border,
        boxShadow: elevation == 0
            ? null
            : [
                BoxShadow(
                  color: (shadowColor ?? Colors.black).withOpacity(0.1),
                  blurRadius: elevation ?? 4,
                  offset: Offset(0, (elevation ?? 4) / 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          child: card,
        ),
      );
    }

    return card;
  }

  // Factory constructor for creating a gradient card
  factory CustomCard.gradient({
    required Widget child,
    required List<Color> colors,
    EdgeInsetsGeometry? padding,
    double? elevation,
    VoidCallback? onTap,
    BorderRadius? borderRadius,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return CustomCard(
      padding: padding,
      elevation: elevation,
      onTap: onTap,
      borderRadius: borderRadius,
      gradient: LinearGradient(
        begin: begin,
        end: end,
        colors: colors,
      ),
      child: child,
    );
  }

  // Factory constructor for creating an outlined card
  factory CustomCard.outlined({
    required Widget child,
    required BuildContext context,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
    BorderRadius? borderRadius,
    Color? borderColor,
    double borderWidth = 1.0,
  }) {
    return CustomCard(
      padding: padding,
      elevation: 0,
      onTap: onTap,
      borderRadius: borderRadius,
      border: Border.all(
        color: borderColor ?? Theme.of(context).dividerColor,
        width: borderWidth,
      ),
      child: child,
    );
  }
}