import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import 'modern_components.dart';
import '../utils/haptic_feedback.dart';

/// Premium Scorecard Widget für Spieler-Bewertung
/// Zeigt Technik, Taktik, Fitness, Mental in eleganten Balken
class ScorecardWidget extends StatefulWidget {
  final Map<String, dynamic> scorecard;
  final bool isEditable;
  final VoidCallback? onChanged;
  final String playerName;
  final int playerNumber;

  const ScorecardWidget({
    super.key,
    required this.scorecard,
    this.isEditable = false,
    this.onChanged,
    required this.playerName,
    required this.playerNumber,
  });

  @override
  State<ScorecardWidget> createState() => _ScorecardWidgetState();
}

class _ScorecardWidgetState extends State<ScorecardWidget> {
  late Map<String, int> _editableScores;

  @override
  void initState() {
    super.initState();
    _editableScores = {
      'technik': (widget.scorecard['technik'] as num?)?.toInt() ?? 0,
      'taktik': (widget.scorecard['taktik'] as num?)?.toInt() ?? 0,
      'fitness': (widget.scorecard['fitness'] as num?)?.toInt() ?? 0,
      'mental': (widget.scorecard['mental'] as num?)?.toInt() ?? 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header mit Spielername und Rückennummer
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange,
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Center(
                  child: Text(
                    '${widget.playerNumber}',
                    style: AppTheme.headingMedium.copyWith(
                      color: AppTheme.backgroundDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.playerName,
                      style: AppTheme.titleLarge,
                    ),
                    Text(
                      'Spielerbewertung',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing2XL),
          // Bewertungs-Balken
          _buildScoreBar(
            'Technik',
            'Ballkontrolle und Technik',
            'technik',
          ),
          const SizedBox(height: AppTheme.spacingXL),
          _buildScoreBar(
            'Taktik',
            'Taktisches Verständnis',
            'taktik',
          ),
          const SizedBox(height: AppTheme.spacingXL),
          _buildScoreBar(
            'Fitness',
            'Ausdauer und Athletik',
            'fitness',
          ),
          const SizedBox(height: AppTheme.spacingXL),
          _buildScoreBar(
            'Mentalität',
            'Kampfgeist und Konzentration',
            'mental',
          ),
          // Notizen/Anmerkungen
          if (widget.scorecard['notizen'] != null &&
              (widget.scorecard['notizen'] as String).isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacing2XL),
            Divider(
              color: AppTheme.surfaceLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Trainer-Notizen',
              style: AppTheme.labelMedium,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              widget.scorecard['notizen'] ?? '',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          // Letztes Update
          if (widget.scorecard['letztesUpdate'] != null) ...[
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Letzte Aktualisierung: ${widget.scorecard['letztesUpdate']}',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreBar(
    String title,
    String subtitle,
    String key,
  ) {
    final currentScore = _editableScores[key] ?? 0;
    final maxScore = 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.titleMedium),
                Text(
                  subtitle,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withValues(alpha: 0.15),
                borderRadius:
                    BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                '$currentScore / $maxScore',
                style: AppTheme.labelLarge.copyWith(
                  color: AppTheme.accentOrange,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        if (widget.isEditable)
          GestureDetector(
            onVerticalDragUpdate: (details) async {
              final newScore = (currentScore +
                      (details.delta.dy * -1).toInt())
                  .clamp(0, maxScore);
              if (newScore != currentScore) {
                await HapticFeedback.lightTap();
                setState(() => _editableScores[key] = newScore);
                widget.onChanged?.call();
              }
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingS,
                ),
                child: ModernProgressIndicator(
                  value: currentScore / maxScore,
                  height: 12,
                  foregroundColor: _getScoreColor(currentScore),
                ),
              ),
            ),
          )
        else
          ModernProgressIndicator(
            value: currentScore / maxScore,
            height: 12,
            foregroundColor: _getScoreColor(currentScore),
          ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppTheme.successGreen;
    if (score >= 60) return AppTheme.accentOrange;
    if (score >= 40) return AppTheme.warningYellow;
    return AppTheme.errorRed;
  }
}
