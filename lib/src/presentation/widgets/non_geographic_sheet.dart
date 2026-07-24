import 'package:e3dad_khodam_2026/src/app/app_strings.dart';
import 'package:e3dad_khodam_2026/src/domain/non_geographic_group.dart';
import 'package:flutter/material.dart';

/// The modal bottom sheet listing epistle recipients with no map
/// location (spec §9): drag handle, title, then each group as a flat,
/// inert list — tapping a row does nothing, since these entries have no
/// children and no map presence by design.
final class NonGeographicSheet extends StatelessWidget {
  static const double _dragHandleWidth = 32.0;
  static const double _dragHandleHeight = 4.0;
  static const double _dragHandleTopMargin = 12.0;
  static const Color _dragHandleColor = Color(0xFF9E9E9E);
  static const double _titlePadding = 16.0;
  static const double _titleFontSize = 16.0;
  static const double _rowFontSize = 15.0;
  static const double _groupHeaderFontSize = 13.0;
  static const double _groupHeaderHorizontalPadding = 16.0;
  static const double _groupHeaderTopPadding = 12.0;
  static const double _bottomSafeAreaPadding = 8.0;
  static const IconData _defaultGroupIcon = Icons.circle;

  /// The non-geographic groups to list, in dataset order.
  final List<NonGeographicGroup> groups;

  /// Creates the sheet for [groups].
  const NonGeographicSheet({required this.groups, super.key});

  static IconData _iconFor(String groupLabel) => switch (groupLabel) {
    'أشخاص' => Icons.person,
    'العبرانيين' => Icons.groups,
    _ => _defaultGroupIcon,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: _bottomSafeAreaPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _dragHandleWidth,
              height: _dragHandleHeight,
              margin: const EdgeInsets.only(top: _dragHandleTopMargin),
              decoration: BoxDecoration(
                color: _dragHandleColor,
                borderRadius: BorderRadius.circular(_dragHandleHeight / 2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(_titlePadding),
              child: Text(
                AppStrings.nonGeographicSheetTitle,
                style: TextStyle(
                  fontSize: _titleFontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final (index, group) in groups.indexed) ...[
              if (index > 0) const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _groupHeaderHorizontalPadding,
                  vertical: _groupHeaderTopPadding,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    group.label,
                    style: TextStyle(
                      fontSize: _groupHeaderFontSize,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              for (final member in group.members)
                ListTile(
                  leading: Icon(_iconFor(group.label)),
                  title: Text(
                    member,
                    style: const TextStyle(fontSize: _rowFontSize),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
