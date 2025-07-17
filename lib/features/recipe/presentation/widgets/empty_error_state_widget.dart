// lib/features/recipe/presentation/widgets/empty_error_state_widget.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/app_constants.dart'; // 상수 임포트

class EmptyErrorStateWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final String? lottieAsset;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final bool isError;

  const EmptyErrorStateWidget({
    Key? key,
    required this.message,
    this.icon,
    this.lottieAsset,
    this.buttonText,
    this.onButtonPressed,
    this.isError = false, // 에러 상태인지 여부
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: SingleChildScrollView( // 내용이 길어질 경우 스크롤 가능 (오버플로우가 발생 방지)
        padding: const EdgeInsets.all(kDefaultPadding * 2), // 패딩 더 넓게
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (lottieAsset != null)
              Lottie.asset(
                lottieAsset!,
                width: 150, // 크기 조절
                height: 150,
                fit: BoxFit.contain,
              )
            else if (icon != null)
              Icon(
                icon,
                size: kIconSizeLarge * 1.5, // 더 큰 아이콘
                color: isError ? colorScheme.error : colorScheme.onSurfaceVariant, // 에러면 에러 색상, 아니면 보조 색상
              ),
            const SizedBox(height: kSpacingLarge),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                color: isError ? colorScheme.error : colorScheme.onSurface, // 에러면 에러 색상, 아니면 기본 텍스트 색상
              ),
            ),
            if (buttonText != null && onButtonPressed != null)
              Padding(
                padding: const EdgeInsets.only(top: kSpacingLarge),
                child: ElevatedButton(
                  onPressed: onButtonPressed,
                  child: Text(buttonText!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isError ? colorScheme.error : colorScheme.primary, // 에러면 에러 색상, 아니면 메인 색상
                    foregroundColor: isError ? colorScheme.onError : colorScheme.onPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}