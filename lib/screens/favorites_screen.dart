﻿import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/dummy_events.dart';
import '../models/event_item.dart';
import '../widgets/event_card.dart';
import '../widgets/favorite_notification_settings.dart';

class FavoritesScreen extends StatefulWidget {
  final Set<String> favoriteEventIds;
  final Function(String) onToggleFavorite;

  const FavoritesScreen({
    super.key,
    required this.favoriteEventIds,
    required this.onToggleFavorite,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // 選択中の日付を記憶するための変数を追加（初期値は1日目）
  FestivalDay _selectedDay = FestivalDay.dayOne;

  // --- ここから下は、ヘルパーメソッド ---
  static final timeFormatter = DateFormat('HH:mm');

  List<Widget> _buildScheduleWidgets(List<EventItem> timedEvents) {
    if (timedEvents.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('この日にお気に入りの企画はありません'),
        ),
      ];
    }
    final List<Widget> scheduleWidgets = [];
    for (int i = 0; i < timedEvents.length; i++) {
      final currentEvent = timedEvents[i];
      if (i > 0) {
        final previousEvent = timedEvents[i - 1];
        if (currentEvent.startTime!.isAfter(previousEvent.endTime!)) {
          scheduleWidgets.add(
            _buildFreeTimeCard(previousEvent.endTime!, currentEvent.startTime!),
          );
        }
      }
      scheduleWidgets.add(
        _buildTimeSlotHeader(currentEvent.startTime!, currentEvent.endTime!),
      );
      scheduleWidgets.add(
        EventCard(
          event: currentEvent,
          favoriteEventIds: widget.favoriteEventIds,
          onToggleFavorite: widget.onToggleFavorite,
        ),
      );
    }
    return scheduleWidgets;
  }

  // 時間帯ヘッダーを生成するヘルパーメソッド
  Widget _buildTimeSlotHeader(DateTime startTime, DateTime endTime) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        '${timeFormatter.format(startTime)} - ${timeFormatter.format(endTime)}',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // 空き時間カードを生成するヘルパーメソッド
  Widget _buildFreeTimeCard(DateTime startTime, DateTime endTime) {
    // 空き時間を計算
    final duration = endTime.difference(startTime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        color: Colors.grey[200],
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              '空き時間（${duration.inMinutes}分）\n${timeFormatter.format(startTime)} - ${timeFormatter.format(endTime)}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      ),
    );
  }
  // --- ここまでヘルパーメソッド ---

  @override
  Widget build(BuildContext context) {
    final favoritedEvents = dummyEvents
        .where((event) => widget.favoriteEventIds.contains(event.id))
        .toList();

    final allDayEvents = favoritedEvents
        .where((event) => event.startTime == null)
        .toList();

    // 選択された日付に応じて、表示する時間指定企画を絞り込む
    final timedEvents =
        favoritedEvents.where((event) => event.startTime != null).where((
          event,
        ) {
          if (_selectedDay == FestivalDay.dayOne) {
            return event.date == FestivalDay.dayOne ||
                event.date == FestivalDay.both;
          } else {
            // _selectedDay == FestivalDay.dayTwo
            return event.date == FestivalDay.dayTwo ||
                event.date == FestivalDay.both;
          }
        }).toList()..sort((a, b) => a.startTime!.compareTo(b.startTime!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('お気に入り企画'),
        actions: [
          Builder(
            builder: (context) {
              // アイコンだけでなくテキストも表示できるTextButton.iconに変更
              return TextButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    builder: (context) {
                      return const FavoriteNotificationSettings();
                    },
                  );
                },
                // 表示するアイコン
                icon: const Icon(Icons.notifications_active_outlined),
                // 表示するテキスト
                label: const Text('通知設定'),
                // ボタンの文字とアイコンの色をAppBarのテーマに合わせる
                style: TextButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).appBarTheme.iconTheme?.color ??
                      Colors.black,
                ),
              );
            },
          ),
          const SizedBox(width: 8), // 右端に少し余白を追加
        ],
      ),
      body: favoritedEvents.isEmpty
          ? const Center(child: Text('お気に入りに登録した企画はありません'))
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (allDayEvents.isNotEmpty) ...[
                  const Text(
                    '常時開催企画',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...allDayEvents.map(
                    (event) => EventCard(
                      event: event,
                      favoriteEventIds: widget.favoriteEventIds,
                      onToggleFavorite: widget.onToggleFavorite,
                    ),
                  ),
                  const Divider(height: 32, thickness: 1),
                ],

                const Text(
                  'マイタイムテーブル',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                //日付を切り替えるためのトグルボタン
                Center(
                  child: ToggleButtons(
                    // 現在選択されているボタンを示す
                    isSelected: [
                      _selectedDay == FestivalDay.dayOne,
                      _selectedDay == FestivalDay.dayTwo,
                    ],
                    // ボタンが押されたときの処理
                    onPressed: (int index) {
                      setState(() {
                        // 押されたボタンに応じて、_selectedDayの値を更新
                        _selectedDay = (index == 0)
                            ? FestivalDay.dayOne
                            : FestivalDay.dayTwo;
                      });
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    // 2つのボタンの見た目を定義
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('1日目'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('2日目'),
                      ),
                    ],
                  ),
                ),

                ..._buildScheduleWidgets(timedEvents),
              ],
            ),
    );
  }
}
