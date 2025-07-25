﻿import 'package:flutter/material.dart';
import '../models/event_item.dart';
import '../screens/event_detail_screen.dart';

class EventCard extends StatelessWidget {
  final EventItem event;

  final Set<String> favoriteEventIds;
  final Function(String) onToggleFavorite;
  final Function(String) onNavigateToMap;

  const EventCard({
    super.key,
    required this.event,
    required this.favoriteEventIds,
    required this.onToggleFavorite,
    required this.onNavigateToMap,
  });

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

  @override
  Widget build(BuildContext context) {
    final bool isFavorited = favoriteEventIds.contains(event.id);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: event.disableDetailsLink
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailScreen(event: event, favoriteEventIds: favoriteEventIds, onToggleFavorite: onToggleFavorite, onNavigateToMap: onNavigateToMap,),
                  ),
                );
              },

        child: SizedBox(
          height: 120,
          child: Row(
            children: [
              AspectRatio(
                aspectRatio: 1 / 1,
                child: Image.asset(
                  event.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            padding: const EdgeInsets.all(0),
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              isFavorited
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorited ? Colors.red : Colors.grey,
                            ),
                            onPressed: () {
                              onToggleFavorite(event.id);
                            },
                          ),
                        ],
                      ),
                      Text(
                        event.groupName,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey[700],
                        ),
                      ),
                      const Spacer(),
                      Wrap(
                        spacing: 6.0,
                        runSpacing: 4.0,
                        children: [
                          ...event.categories.map((category) => _buildTag(category.name, Colors.blue)),
                          _buildTag(event.area.name, Colors.orange),
                          _buildTag(event.date.name, Colors.green),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
