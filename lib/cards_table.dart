import 'package:flutter/material.dart';

class CardsTableScreen extends StatefulWidget {
  final String userRole;
  final String currentUserName;

  const CardsTableScreen({super.key, required this.userRole, required this.currentUserName});

  @override
  State<CardsTableScreen> createState() => _CardsTableScreenState();
}

class _CardsTableScreenState extends State<CardsTableScreen> {
  final List<Map<String, dynamic>> _playerCards = [
    {'name': 'Lian', 'gelb': 3, 'rot': 0, 'sperre': 0},
    {'name': 'Mika', 'gelb': 5, 'rot': 1, 'sperre': 1},
    {'name': 'Kian', 'gelb': 2, 'rot': 0, 'sperre': 0},
    {'name': 'Jonas', 'gelb': 1, 'rot': 0, 'sperre': 0},
    {'name': 'Felix', 'gelb': 4, 'rot': 0, 'sperre': 0},
  ];

  bool get _canEdit => widget.userRole == 'Vereinsadministrator' || widget.userRole == 'Trainer' || widget.userRole == 'Co-Trainer';

  @override
  Widget build(BuildContext context) {
    final totalYellow = _playerCards.fold(0, (sum, p) => sum + (p['gelb'] as int));
    final totalRed = _playerCards.fold(0, (sum, p) => sum + (p['rot'] as int));
    final totalSuspensions = _playerCards.fold(0, (sum, p) => sum + (p['sperre'] as int));
    final fairplayScore = 100 - (totalYellow * 2 + totalRed * 5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Karten & Fairplay'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Übersicht der Spieler-Disziplin',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildCardSummary(title: 'Gelbe Karten', value: '$totalYellow', color: Colors.amber, icon: Icons.warning),
                _buildCardSummary(title: 'Rote Karten', value: '$totalRed', color: Colors.redAccent, icon: Icons.block),
                _buildCardSummary(title: 'Sperren', value: '$totalSuspensions', color: Colors.deepOrangeAccent, icon: Icons.shield),
                _buildCardSummary(title: 'Fairplay', value: '${fairplayScore.clamp(0, 100)}%', color: Colors.greenAccent, icon: Icons.emoji_events),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _playerCards.length,
                itemBuilder: (context, index) {
                  final player = _playerCards[index];
                  return Card(
                    color: Colors.white10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueGrey,
                        child: Text(player['name'][0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(player['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _buildStatusChip('Gelb', player['gelb'] as int, Colors.amber),
                              const SizedBox(width: 8),
                              _buildStatusChip('Rot', player['rot'] as int, Colors.redAccent),
                              const SizedBox(width: 8),
                              _buildStatusChip('Sperre', player['sperre'] as int, Colors.deepOrangeAccent),
                            ],
                          ),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: (player['gelb'] as int) * 0.1 + (player['rot'] as int) * 0.2,
                            color: Colors.redAccent,
                            backgroundColor: Colors.white10,
                            minHeight: 6,
                          ),
                        ],
                      ),
                      trailing: _canEdit
                          ? PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: Colors.white70),
                              onSelected: (action) {
                                setState(() {
                                  if (action == 'yellow') {
                                    player['gelb'] = (player['gelb'] as int) + 1;
                                  } else if (action == 'red') {
                                    player['rot'] = (player['rot'] as int) + 1;
                                  } else if (action == 'suspend') {
                                    player['sperre'] = (player['sperre'] as int) + 1;
                                  }
                                });
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'yellow', child: Text('Gelbe Karte vergeben')),
                                const PopupMenuItem(value: 'red', child: Text('Rote Karte vergeben')),
                                const PopupMenuItem(value: 'suspend', child: Text('Sperre hinzufügen')),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSummary({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return SizedBox(
      width: 160,
      child: Card(
        color: Colors.white10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withValues(alpha: 0.18),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 14),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(12)),
      child: Text(
        '$label: $value',
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
