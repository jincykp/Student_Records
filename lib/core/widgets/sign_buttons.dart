import 'package:flutter/material.dart';
import 'package:studentrecords/core/constants/color_constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final double textSize;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.padding,
    this.textSize = 18,
    this.borderRadius = 20,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBackgroundColor = backgroundColor ?? AllColors.primaryColor;
    final defaultTextColor = textColor ?? AllColors.textColor;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isOutlined
                ? Colors.transparent
                : (isLoading
                    ? defaultBackgroundColor.withOpacity(0.7)
                    : defaultBackgroundColor),
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side:
              isOutlined
                  ? BorderSide(color: defaultBackgroundColor, width: 2)
                  : BorderSide.none,
        ),
        elevation: isOutlined ? 0 : null,
      ),
      child:
          isLoading
              ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: textSize,
                    height: textSize,
                    child: CircularProgressIndicator(
                      color: defaultTextColor,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: textSize,
                      fontWeight: FontWeight.bold,
                      color: defaultTextColor,
                    ),
                  ),
                ],
              )
              : Text(
                text,
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.bold,
                  color: isOutlined ? defaultBackgroundColor : defaultTextColor,
                ),
              ),
    );
  }
}
