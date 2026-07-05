import 'package:flutter/material.dart';

/// Zentrale App-Navigation und Dialog-Management
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();

  late GlobalKey<NavigatorState> navigatorKey;

  NavigationService._internal() {
    navigatorKey = GlobalKey<NavigatorState>();
  }

  factory NavigationService() {
    return _instance;
  }

  /// Gehe zu einer neuen Route
  Future<dynamic> pushNamed(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamed(
      routeName,
      arguments: arguments,
    ) ??
        Future.value();
  }

  /// Ersetze aktuelle Route
  Future<dynamic> pushReplacementNamed(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState?.pushReplacementNamed(
      routeName,
      arguments: arguments,
    ) ??
        Future.value();
  }

  /// Gehe zurück
  void pop({Object? result}) {
    navigatorKey.currentState?.pop(result);
  }

  /// Zeige Error-Dialog mit eleganter Animation
  Future<void> showErrorDialog(
    String title,
    String message,
  ) async {
    return _showAnimatedDialog(
      context: navigatorKey.currentContext!,
      title: title,
      message: message,
      icon: Icons.error_outline,
      iconColor: Colors.red,
    );
  }

  /// Zeige Success-Dialog
  Future<void> showSuccessDialog(
    String title,
    String message,
  ) async {
    return _showAnimatedDialog(
      context: navigatorKey.currentContext!,
      title: title,
      message: message,
      icon: Icons.check_circle_outline,
      iconColor: Colors.green,
    );
  }

  /// Zeige Bestätigungs-Dialog
  Future<bool> showConfirmDialog(
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: navigatorKey.currentContext!,
      builder: (_) => _buildAnimatedDialog(
        title: title,
        message: message,
        icon: Icons.help_outline,
        iconColor: Colors.blue,
        isConfirmation: true,
      ),
    );
    return result ?? false;
  }

  Future<void> _showAnimatedDialog({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    return showDialog(
      context: context,
      builder: (_) => _buildAnimatedDialog(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  Widget _buildAnimatedDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    bool isConfirmation = false,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: _AnimatedDialogContent(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
        isConfirmation: isConfirmation,
      ),
    );
  }
}

/// Animierter Dialog mit modernem Design
class _AnimatedDialogContent extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final bool isConfirmation;

  const _AnimatedDialogContent({
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    this.isConfirmation = false,
  });

  @override
  State<_AnimatedDialogContent> createState() =>
      _AnimatedDialogContentState();
}

class _AnimatedDialogContentState extends State<_AnimatedDialogContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => FadeTransition(
        opacity: _opacityAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: widget.iconColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF8FAFC),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFA4ACBA),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (widget.isConfirmation)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF334155),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Abbrechen'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFD97706),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Bestätigen'),
                          ),
                        ),
                      ],
                    )
                  else
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.iconColor,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(double.infinity, 44),
                      ),
                      child: const Text('OK'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
