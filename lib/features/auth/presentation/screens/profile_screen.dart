// lib/features/auth/presentation/screens/profile_screen.dart
import 'package:dr_bread_app/core/widgets/background_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/entities/user.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // AuthBloc의 현재 상태에서 사용자 정보 가져오기
    // BlocBuilder를 사용하여 AuthBloc의 상태 변화에 따라 UI 업데이트
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        UserEntity? user;
        if (state is AuthAuthenticated) {
          user = state.user;
        }

        return Scaffold(
          appBar: CustomAppBar(
            title: Text('내 프로필', style: theme.appBarTheme.titleTextStyle),
          ),
          body: BackgroundGradient(
            child: Center(
            child: SingleChildScrollView( // 내용이 길어질 경우 스크롤 가능
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 프로필 이미지
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: colorScheme.surfaceVariant,
                    backgroundImage: user?.photoUrl != null
                        ? CachedNetworkImageProvider(user!.photoUrl!) as ImageProvider
                        : null,
                    child: user?.photoUrl == null
                        ? Icon(Icons.person, size: kIconSizeLarge * 1.5, color: colorScheme.onSurfaceVariant)
                        : null,
                  ),
                  const SizedBox(height: kSpacingLarge),

                  // 사용자 닉네임/이름
                  Text(
                    user?.displayName ?? '사용자',
                    style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: kSpacingSmall),

                  // 이메일
                  Text(
                    user?.email ?? '이메일 없음',
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: kSpacingExtraLarge),

                  // 로그아웃 버튼
                  ElevatedButton(
                    onPressed: () async {
                      // 로그아웃 확인 다이얼로그 (MainRecipeListScreen에서 가져옴)
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('로그아웃'),
                          content: const Text('정말로 로그아웃 하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('로그아웃'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        context.read<AuthBloc>().add(AuthSignOut()); // AuthBloc에 로그아웃 이벤트 추가
                      }
                    },
                    child: Text('로그아웃', style: textTheme.labelLarge),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.error, // 에러 색상으로 강조
                      foregroundColor: colorScheme.onError,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: kSpacingMedium),

                  // TODO: 마이 레시피 버튼 (나중에 MainRecipeListScreen의 필터로 대체 가능)
                  // ElevatedButton(
                  //   onPressed: () {
                  //     // 마이 레시피 화면으로 이동 또는 MainRecipeListScreen에서 필터 적용
                  //   },
                  //   child: Text('내가 작성한 레시피', style: textTheme.labelLarge),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: colorScheme.secondary,
                  //     foregroundColor: colorScheme.onSecondary,
                  //     minimumSize: const Size(double.infinity, 50),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          ),
        );
      },
    );
  }
}