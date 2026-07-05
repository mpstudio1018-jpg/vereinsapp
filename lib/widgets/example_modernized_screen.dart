import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../widgets/modern_components.dart';
import '../utils/haptic_feedback.dart';

/// BEISPIEL: Wie man einen Screen modernisiert
/// 
/// Dieses Fragment zeigt die Umsetzung der neuen Design-Prinzipien
/// an einem realen Beispiel eines Spieler-Listen-Screens

class ModernPlayerListExample extends StatefulWidget {
  final List<Map<String, dynamic>> players;
  final VoidCallback onAddPlayer;

  const ModernPlayerListExample({
    super.key,
    required this.players,
    required this.onAddPlayer,
  });

  @override
  State<ModernPlayerListExample> createState() =>
      _ModernPlayerListExampleState();
}

class _ModernPlayerListExampleState
    extends State<ModernPlayerListExample> {
  late List<Map<String, dynamic>> _filteredPlayers;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filteredPlayers = widget.players;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: _buildModernAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      title: Text('Spieler-Verwaltung', style: AppTheme.headingMedium),
      backgroundColor: AppTheme.cardBackground,
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingL,
          ),
          child: ModernButton(
            label: 'Neu',
            onPressed: () async {
              await HapticFeedback.mediumTap();
              widget.onAddPlayer();
            },
            iconData: Icons.add,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Column(
        children: [
          // Suchfeld
          _buildSearchBar(),
          // Spieler-Liste oder Empty State
          Expanded(
            child: _filteredPlayers.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.people_outline,
                    title: 'Keine Spieler gefunden',
                    subtitle: _searchQuery.isNotEmpty
                        ? 'Versuche einen anderen Suchbegriff'
                        : 'Füge einen neuen Spieler ein um zu beginnen',
                    actionLabel: 'Spieler hinzufügen',
                    onAction: () async {
                      await HapticFeedback.lightTap();
                      widget.onAddPlayer();
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(
                      AppTheme.spacingL,
                    ),
                    itemCount: _filteredPlayers.length,
                    itemBuilder: (context, index) =>
                        _buildPlayerCard(
                          _filteredPlayers[index],
                          index,
                        ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _filteredPlayers = widget.players
                .where((player) =>
                    (player['name'] as String)
                        .toLowerCase()
                        .contains(value.toLowerCase()) ||
                    (player['rueckennummer'] as int)
                        .toString()
                        .contains(value))
                .toList();
          });
        },
        decoration: InputDecoration(
          hintText: 'Spieler oder Nummer suchen...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _filteredPlayers = widget.players;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildPlayerCard(
    Map<String, dynamic> player,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppTheme.spacingL,
      ),
      child: ModernCard(
        isClickable: true,
        onTap: () async {
          await HapticFeedback.selection();
          // Navigiere zu Spieler-Detail-Screen
        },
        child: Row(
          children: [
            // Jersey-Nummer
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentOrange.withValues(alpha: 0.8),
                    AppTheme.accentGold.withValues(alpha: 0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  AppTheme.radiusSmall,
                ),
              ),
              child: Center(
                child: Text(
                  '${player['rueckennummer']}',
                  style: AppTheme.headingMedium.copyWith(
                    color: AppTheme.backgroundDark,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingL),
            // Spieler-Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player['name'] ?? 'Unbekannt',
                    style: AppTheme.titleMedium,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Row(
                    children: [
                      _buildPositionBadge(
                        player['hauptposition'] ?? 'Unbekannt',
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      if (player['starkerFuss'] != null)
                        _buildBadge(
                          player['starkerFuss'],
                          Colors.blue,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Action Button
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(
                  AppTheme.radiusSmall,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () async {
                  await HapticFeedback.lightTap();
                  // Handle tap
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionBadge(String position) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.accentOrange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(
          AppTheme.radiusSmall,
        ),
      ),
      child: Text(
        position,
        style: AppTheme.labelMedium.copyWith(
          color: AppTheme.accentOrange,
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(
          AppTheme.radiusSmall,
        ),
      ),
      child: Text(
        label,
        style: AppTheme.labelMedium.copyWith(
          color: color,
        ),
      ),
    );
  }
}

/// BEISPIEL-NUTZUNG in main.dart:
///
/// ```dart
/// import 'lib/widgets/example_modernized_screen.dart';
///
/// // In deinem DashboardScreen oder wo immer du die Spieler-Liste zeigst:
/// ModernPlayerListExample(
///   players: _teamMembers,
///   onAddPlayer: () {
///     // Öffne Dialog um neuen Spieler hinzuzufügen
///   },
/// )
/// ```
