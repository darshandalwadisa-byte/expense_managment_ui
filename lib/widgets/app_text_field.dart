import 'package:expense/core/constants/app_images.dart';
import 'package:expense/core/theme/app_colors.dart';
import 'package:expense/core/theme/app_text_styles.dart';
import 'package:expense/widgets/app_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextField extends StatefulWidget {
  /// The label text displayed above the text field
  final String? label;

  /// The hint text displayed inside the text field when empty
  final String? hint;

  /// Controller for the text field
  final TextEditingController? controller;

  /// Callback triggered when text changes
  final ValueChanged<String>? onChanged;

  /// Callback triggered when the field is submitted
  final ValueChanged<String>? onSubmitted;

  /// Widget to display at the end of the text field
  final Widget? suffixIcon;

  /// Widget to display at the start of the text field
  final Widget? prefixIcon;

  /// Whether this is a password field (obscures text)
  final bool isPassword;

  /// Whether the field is enabled for input
  final bool enabled;

  /// Whether the field is read-only
  final bool readOnly;

  /// The keyboard type for the text field
  final TextInputType keyboardType;

  /// Text capitalization behavior
  final TextCapitalization textCapitalization;

  /// Input formatters for the text field
  final List<TextInputFormatter>? inputFormatters;

  /// Maximum number of lines
  final int maxLines;

  /// Minimum number of lines
  final int? minLines;

  /// Maximum length of input
  final int? maxLength;

  /// Focus node for the text field
  final FocusNode? focusNode;

  /// Text input action
  final TextInputAction? textInputAction;

  /// Auto-validation mode
  final AutovalidateMode? autovalidateMode;

  /// Validator function
  final String? Function(String?)? validator;

  /// Whether to show the validation icon (checkmark when valid)
  final bool showValidationIcon;

  /// Whether the current input is valid (shows green checkmark when true)
  final bool? isValid;

  /// Error text to display below the field
  final String? errorText;

  /// Custom border radius
  final double borderRadius;

  /// Custom content padding
  final EdgeInsetsGeometry? contentPadding;

  /// Custom fill color
  final Color? fillColor;

  /// Custom border color
  final Color? borderColor;

  /// Custom focused border color
  final Color? focusedBorderColor;

  /// Whether the text field should auto-focus
  final bool autofocus;
  // final Color? borderColor;
  final double borderWidth;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.suffixIcon,
    this.prefixIcon,
    this.isPassword = false,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.focusNode,
    this.textInputAction,
    this.autovalidateMode,
    this.validator,
    this.showValidationIcon = false,
    this.isValid,
    this.errorText,
    this.borderRadius = 12.0,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.autofocus = false,
    // this.borderColor,
    this.borderWidth = 1.0,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Widget? _buildSuffixIcon() {
    // For password fields, show visibility toggle
    if (widget.isPassword) {
      return GestureDetector(
        onTap: _togglePasswordVisibility,

        child: _obscureText
            ? AppImageViewer(
                imagePath: AppImages.hideImage,
                height: 18.sp,
                width: 18.sp,
              )
            : AppImageViewer(
                imagePath: AppImages.showImage,
                height: 18.sp,
                width: 18.sp,
              ),
      );
    }

    // For validation icon
    if (widget.showValidationIcon && widget.isValid == true) {
      return Icon(Icons.check_circle, color: AppColors.success, size: 22.sp);
    }

    // Custom suffix icon
    return widget.suffixIcon;
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
        ],

        // Text Field
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.textCapitalization,
          inputFormatters: widget.inputFormatters,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          textInputAction: widget.textInputAction,
          autovalidateMode: widget.autovalidateMode,
          validator: widget.validator,
          autofocus: widget.autofocus,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          style: AppTextStyles.bodyLarge.copyWith(
            color: widget.enabled
                ? Theme.of(context).textTheme.bodyLarge?.color
                : Theme.of(context).disabledColor,
          ),

          decoration: InputDecoration(
            counterText: "",
            hintText: widget.hint,
            hintStyle: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.hintText,
            ),
            errorText: widget.errorText,
            errorStyle: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
            filled: true,
            fillColor:
                widget.fillColor ?? Theme.of(context).colorScheme.surface,
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixIcon() != null
                ? Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: _buildSuffixIcon(),
                  )
                : null,
            suffixIconConstraints: BoxConstraints(
              minHeight: 22.sp,
              minWidth: 22.sp,
            ),
            contentPadding:
                widget.contentPadding ??
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius.r),
              borderSide: BorderSide(
                color: widget.borderColor ?? Theme.of(context).primaryColor,
                width: widget.borderWidth.w,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius.r),
              borderSide: hasError
                  ? BorderSide(
                      color: Theme.of(context).colorScheme.error,
                      width: 1.w,
                    )
                  : BorderSide(
                      color:
                          widget.borderColor ?? Theme.of(context).dividerColor,
                      width: widget.borderWidth.w,
                    ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius.r),
              borderSide: BorderSide(
                color:
                    widget.focusedBorderColor ?? Theme.of(context).primaryColor,
                width: 1.5.w,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius.r),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1.w,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius.r),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1.5.w,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
