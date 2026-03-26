// import 'package:flutter/material.dart';
// import 'package:mini_reddit_v2/core/models/enum.dart';

// class FeedSortSelector extends StatelessWidget {
//   final FeedType selectedType;
//   final Function(FeedType) onTypeSelected;
//   final TopFeedTimeframe selectedTimeframe;
//   final Function(TopFeedTimeframe) onTimeframeSelected;

//   const FeedSortSelector({
//     super.key,
//     required this.selectedType,
//     required this.onTypeSelected,
//     required this.selectedTimeframe,
//     required this.onTimeframeSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final color = isDark ? Colors.white70 : Colors.black54;

//     return Container(
//       height: 48,
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).scaffoldBackgroundColor,
//         border: Border(
//           bottom: BorderSide(
//             color: Theme.of(context).dividerColor.withOpacity(0.05),
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           _SortItem(
//             icon: _getIconForType(selectedType),
//             label: _getLabelForType(selectedType),
//             onTap: () => _showSortPicker(context),
//             color: color,
//           ),
//           if (selectedType == FeedType.top) ...[
//             const SizedBox(width: 8),
//             _SortItem(
//               icon: Icons.access_time_rounded,
//               label: _getLabelForTimeframe(selectedTimeframe),
//               onTap: () => _showTimeframePicker(context),
//               color: color,
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   IconData _getIconForType(FeedType type) {
//     switch (type) {
//       case FeedType.hot:
//         return Icons.local_fire_department_rounded;
//       case FeedType.newFeed:
//         return Icons.new_releases_rounded;
//       case FeedType.top:
//         return Icons.trending_up_rounded;
//       case FeedType.best:
//         return Icons.rocket_launch_rounded;
//       case FeedType.popular:
//         return Icons.auto_graph_rounded;
//       default:
//         return Icons.sort_rounded;
//     }
//   }

//   void _showSortPicker(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _PickerOption(
//                 icon: Icons.local_fire_department_rounded,
//                 label: 'Hot',
//                 isSelected: selectedType == FeedType.hot,
//                 onTap: () {
//                   onTypeSelected(FeedType.hot);
//                   Navigator.pop(context);
//                 },
//               ),
//               _PickerOption(
//                 icon: Icons.new_releases_rounded,
//                 label: 'New',
//                 isSelected: selectedType == FeedType.newFeed,
//                 onTap: () {
//                   onTypeSelected(FeedType.newFeed);
//                   Navigator.pop(context);
//                 },
//               ),
//               _PickerOption(
//                 icon: Icons.trending_up_rounded,
//                 label: 'Top',
//                 isSelected: selectedType == FeedType.top,
//                 onTap: () {
//                   onTypeSelected(FeedType.top);
//                   Navigator.pop(context);
//                 },
//               ),
//               _PickerOption(
//                 icon: Icons.rocket_launch_rounded,
//                 label: 'Best',
//                 isSelected: selectedType == FeedType.best,
//                 onTap: () {
//                   onTypeSelected(FeedType.best);
//                   Navigator.pop(context);
//                 },
//               ),
//               _PickerOption(
//                 icon: Icons.auto_graph_rounded,
//                 label: 'Popular',
//                 isSelected: selectedType == FeedType.popular,
//                 onTap: () {
//                   onTypeSelected(FeedType.popular);
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _showTimeframePicker(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: TopFeedTimeframe.values.map((timeframe) {
//               return _PickerOption(
//                 icon: Icons.access_time_rounded,
//                 label: _getLabelForTimeframe(timeframe),
//                 isSelected: selectedTimeframe == timeframe,
//                 onTap: () {
//                   onTimeframeSelected(timeframe);
//                   Navigator.pop(context);
//                 },
//               );
//             }).toList(),
//           ),
//         );
//       },
//     );
//   }
// }

// class _SortItem extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//   final Color color;

//   const _SortItem({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(4),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 16, color: color),
//             const SizedBox(width: 4),
//             Text(
//               label.toUpperCase(),
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w700,
//                 color: color,
//                 letterSpacing: 0.5,
//               ),
//             ),
//             Icon(Icons.arrow_drop_down, size: 20, color: color),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _PickerOption extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const _PickerOption({
//     required this.icon,
//     required this.label,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final color = isSelected ? const Color(0xFFFF4500) : null;

//     return ListTile(
//       leading: Icon(icon, color: color),
//       title: Text(
//         label,
//         style: TextStyle(
//           fontWeight: isSelected ? FontWeight.bold : null,
//           color: color,
//         ),
//       ),
//       trailing: isSelected ? Icon(Icons.check, color: color, size: 20) : null,
//       onTap: onTap,
//     );
//   }
// }
