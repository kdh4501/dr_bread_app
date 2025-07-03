// lib/features/recipe/presentation/widgets/filter_bottom_sheet.dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../bloc/recipe_list_state.dart'; // RecipeFilterOptions가 정의된 파일


class FilterBottomSheet extends StatefulWidget {
  final RecipeFilterOptions currentFilter;
  final Function(RecipeFilterOptions) onApplyFilter;

  const FilterBottomSheet({
    Key? key,
    required this.currentFilter,
    required this.onApplyFilter,
  }) : super(key: key);

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _selectedCategory;
  String? _selectedDifficulty;
  int? _selectedMaxPrepTime;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.currentFilter.category;
    _selectedDifficulty = widget.currentFilter.difficulty;
    _selectedMaxPrepTime = widget.currentFilter.maxPrepTimeMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding), // <-- 상수 사용!
      child: ListView(
        // mainAxisSize: MainAxisSize.min,
        shrinkWrap: true,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('필터', style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface)),
          const SizedBox(height: kSpacingMedium), // <-- 상수 사용!

          // 카테고리 필터
          Text('카테고리', style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface)),
          const SizedBox(height: kSpacingSmall), // <-- 상수 사용!
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            hint: Text('카테고리 선택', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6))),
            items: ['빵', '쿠키', '케이크', '기타']
                .map((category) => DropdownMenuItem(value: category, child: Text(category, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface))))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(kSpacingSmall)), // <-- 상수 사용!
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: kSpacingMedium), // <-- 상수 사용!

          // 난이도 필터
          Text('난이도', style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface)),
          const SizedBox(height: kSpacingSmall), // <-- 상수 사용!
          DropdownButtonFormField<String>(
            value: _selectedDifficulty,
            hint: Text('난이도 선택', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6))),
            items: ['쉬움', '보통', '어려움']
                .map((difficulty) => DropdownMenuItem(value: difficulty, child: Text(difficulty, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)))) // item 텍스트 스타일
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedDifficulty = value;
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(kSpacingSmall)), // <-- 상수 사용!
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: kSpacingMedium), // <-- 상수 사용!

          // 최대 준비 시간 필터 (Slider 또는 Dropdown)
          Text('최대 준비 시간 (분)', style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface)),
          const SizedBox(height: kSpacingSmall), // <-- 상수 사용!
          Slider(
            value: (_selectedMaxPrepTime ?? 0).toDouble(),
            min: 0,
            max: 120,
            divisions: 12, // 10분 단위
            label: (_selectedMaxPrepTime ?? 0).toString(),
            onChanged: (value) {
              setState(() {
                _selectedMaxPrepTime = value.toInt();
              });
            },
            activeColor: colorScheme.primary, // primary 색상
            inactiveColor: colorScheme.primary.withOpacity(0.3), // primary 색상
            thumbColor: colorScheme.primary, // primary 색상
          ),
          Text('선택된 시간: ${_selectedMaxPrepTime ?? '무제한'}분', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)), // bodyMedium 스타일, onSurface 색상
          const SizedBox(height: kSpacingLarge), // <-- 상수 사용!

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                    _selectedDifficulty = null;
                    _selectedMaxPrepTime = null;
                  });
                },
                child: const Text('초기화'),
              ),
              const SizedBox(width: kSpacingMedium), // <-- 상수 사용!
              ElevatedButton(
                onPressed: () {
                  widget.onApplyFilter(RecipeFilterOptions(
                    category: _selectedCategory,
                    difficulty: _selectedDifficulty,
                    maxPrepTimeMinutes: _selectedMaxPrepTime,
                  ));
                },
                child: const Text('적용'),
              ),
            ],
          ),
          const SizedBox(height: kSpacingMedium), // <-- 상수 사용!
        ],
      ),
    );
  }
}