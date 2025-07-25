﻿import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_item.dart';

class EventDetailScreen extends StatefulWidget {
  final EventItem event;
  final Set<String> favoriteEventIds;
  final Function(String) onToggleFavorite;
  final Function(String) onNavigateToMap;


  const EventDetailScreen({
    super.key,
    required this.event,
    required this.favoriteEventIds,
    required this.onToggleFavorite,
    required this.onNavigateToMap,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withAlpha(51),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    Widget? child,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              if (child != null) child,
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final timeFormatter = DateFormat('HH:mm');
    final dayFormatter = DateFormat('M/d (E)', 'ja_JP');

    final bool isFavorited = widget.favoriteEventIds.contains(widget.event.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title),
        actions: [
          IconButton(
            icon: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              color: isFavorited ? Colors.red : null,
            ),
            tooltip: 'お気に入り',
            onPressed: () {
              widget.onToggleFavorite(widget.event.id);
              setState(() {});
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              widget.event.imagePath,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.image_not_supported)),
                );
              },

            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.event.title, style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),),
                  Text(widget.event.groupName, style: TextStyle(fontSize: 16, color: Colors.grey[700]),),
                  const SizedBox(height: 16.0),
                  Wrap(
                    // ...
                    children: [
                      ...widget.event.categories.map((category) => _buildTag(category.name, Colors.blue)),
                      _buildTag(widget.event.area.name, Colors.orange),
                      _buildTag(widget.event.date.name, Colors.green),
                    ],
                  ),
                  const Divider(height: 32.0),
                  _buildInfoRow(
                    icon: Icons.schedule,
                    title: '開催日時',
                    child: widget.event.timeSlots.isEmpty
                        ? const Text('常時開催', style: TextStyle(fontSize: 16))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widget.event.timeSlots.map((slot) {
                              return Text(
                                '${dayFormatter.format(slot.startTime)} ${timeFormatter.format(slot.startTime)} - ${timeFormatter.format(slot.endTime)}',
                                style: const TextStyle(fontSize: 16),
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: 16.0),
                  _buildInfoRow(
                    icon: Icons.location_on,
                    title: '開催場所',
                    child: Text(
                      '${widget.event.area.name} / ${widget.event.location}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: OutlinedButton(
                      child: const Text('マップで見る'),
                      onPressed: () {
                        widget.onNavigateToMap(widget.event.id);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const Divider(height: 32.0),
                  // ...
                  Text(widget.event.description, /* ... */),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}