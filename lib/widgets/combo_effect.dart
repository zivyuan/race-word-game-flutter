import 'package:flutter/material.dart';
import 'dart:math' as math;

class ComboEffect extends StatefulWidget {\  final int comboCount;\
  final VoidCallback? onComplete;\
  final Offset position;\
  \
  const ComboEffect({\
    super.key,\
    required this.comboCount,\
    this.onComplete,\
    required this.position,\
  });\
  \
  @override\
  State<ComboEffect> createState() => ComboEffectState();\
}\
  \
class ComboEffectState extends State<ComboEffect> \  with SingleTickerProviderStateMixin {\
  late AnimationController _controller;\
  late Animation<double> _scaleAnimation;\
  late Animation<double> _fadeAnimation;\
  late Animation<double> _slideAnimation;\
  \
  final List<ParticleWidget> _particles = [];\
  \
  @override\
  void initState() {\
    super.initState();\
    _controller = AnimationController(\  duration: const Duration(milliseconds: 1500),\  vsync: this,\
    );\
    \
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(\  CurvedAnimation(\  parent: _controller,\  curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),\  ),\
    );\
    \
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(\  CurvedAnimation(\  parent: _controller,\  curve: const Interval(0.8, 1.0, curve: Curves.easeOut),\  ),\
    );\
    \
    _slideAnimation = Tween<double>(begin: 0.0, end: -50.0).animate(\  CurvedAnimation(\  parent: _controller,\  curve: const Interval(0.4, 1.0, curve: Curves.easeOut),\  ),\
    );\
    \
    _createParticles();\
    _controller.forward().then((_) {\
      widget.onComplete?.call();\
    });\
  }\
  \
  void _createParticles() {\
    final random = math.Random();\
    final colors = [\  Colors.red.withOpacity(0.8),\  Colors.orange.withOpacity(0.8),\  Colors.yellow.withOpacity(0.8),\  Colors.green.withOpacity(0.8),\  Colors.blue.withOpacity(0.8),\  Colors.purple.withOpacity(0.8),\
    ];\
    \
    for (int i = 0; i < 20; i++) {\
      _particles.add(\  ParticleWidget(\  key: ValueKey('particle_$i'),\  position: widget.position,\
  velocity: Offset(\  (random.nextDouble() - 0.5) * 200,\  -random.nextDouble() * 150 - 50,\
  ),\
  color: colors[random.nextInt(colors.length)],\  size: random.nextDouble() * 8 + 4,\
  ),\
  );\
  }\
  \
  @override\
  void dispose() {\
    _controller.dispose();\
    super.dispose();\
  }\
  \
  @override\
  Widget build(BuildContext context) {\
    return Positioned(\  top: widget.position.dy - 50,\  left: widget.position.dx - 50,\
  child: AnimatedBuilder(\  animation: _controller,\  builder: (context, child) {\
    return FadeTransition(\  opacity: _fadeAnimation,\
  child: Transform(\  transform: Matrix4.identity()\  ..translate(0.0, _slideAnimation.value)\
  ..scale(_scaleAnimation.value),\
  alignment: Alignment.center,\
  child: Column(\  mainAxisSize: MainAxisSize.min,\
  children: [\  if (widget.comboCount >= 5)\  Text(\
  '${_getComboEmoji(widget.comboCount)}',\
  style: TextStyle(\  fontSize: 60,\  fontWeight: FontWeight.bold,\  ),\
  ),\
  Text(\
  '${widget.comboCount}连击!',\
  style: TextStyle(\  fontSize: 24,\
  fontWeight: FontWeight.bold,\
  color: _getComboColor(widget.comboCount),\  shadows: [\  Shadow(\  color: Colors.black.withOpacity(0.3),\  blurRadius: 4,\  offset: const Offset(2, 2),\  ),\
  ],\
  ),\
  ),\
  ],\
  ),\
  ),\
  );\
  },\
  ),\
  ),\
  );\
  }\
  \
  String _getComboEmoji(int combo) {\
    if (combo >= 20) return '🔥🔥🔥';\
    if (combo >= 15) return '🔥🔥';\
    if (combo >= 10) return '🔥';\
    if (combo >= 5) return '⭐';\
    return '✨';\
  }\
  \
  Color _getComboColor(int combo) {\
    if (combo >= 20) return Colors.red;\
    if (combo >= 15) return Colors.orange;\
    if (combo >= 10) return Colors.yellow;\
    if (combo >= 5) return Colors.green;\
    return Colors.blue;\
  }\
}\
  \
class ParticleWidget extends StatelessWidget {\
  final Offset position;\
  final Offset velocity;\
  final Color color;\
  final double size;\
  \
  const ParticleWidget({\
    super.key,\
    required this.position,\
    required this.velocity,\
    required this.color,\
    required this.size,\
  });\
  \
  @override\
  Widget build(BuildContext context) {\
    return Positioned(\  top: position.dy,\
  left: position.dx,\
  child: AnimatedParticle(\  velocity: velocity,\  color: color,\  size: size,\
  ),\
  );\
  }\
}\
  \
class AnimatedParticle extends StatefulWidget {\
  final Offset velocity;\
  final Color color;\
  final double size;\
  \
  const AnimatedParticle({\
    super.key,\
    required this.velocity,\
    required this.color,\
    required this.size,\
  });\
  \
  @override\
  State<AnimatedParticle> createState() => AnimatedParticleState();\
}\
  \
class AnimatedParticleState extends State<AnimatedParticle>\  with SingleTickerProviderStateMixin {\
  late AnimationController _controller;\
  late Animation<Offset> _positionAnimation;\
  late Animation<double> _fadeAnimation;\
  \
  @override\
  void initState() {\
    super.initState();\
    _controller = AnimationController(\  duration: const Duration(milliseconds: 1000),\
  vsync: this,\
  );\
  \
    _positionAnimation = Tween<Offset>(\
  begin: Offset.zero,\
  end: widget.velocity / 60, // 转换为1秒内的位移\
  ).animate(_controller);\
  \
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(\  CurvedAnimation(\  parent: _controller,\
  curve: Curves.easeOut,\
  ),\
  );\
    \
    _controller.forward();\
  }\
  \
  @override\
  void dispose() {\
    _controller.dispose();\
    super.dispose();\
  }\
  }\
  \
  @override\
  Widget build(BuildContext context) {\
    return AnimatedBuilder(\  animation: _controller,\
  builder: (context, child) {\
    return FadeTransition(\  opacity: _fadeAnimation,\
  child: Transform.translate(\  offset: _positionAnimation.value,\  child: Container(\  width: widget.size,\
  height: widget.size,\
  decoration: BoxDecoration(\  color: widget.color,\
  shape: BoxShape.circle,\
  ),\
  ),\
  ),\
  );\
  },\
  );\
  }\
}\
  \
class ComboManager {\
  static final ComboManager _instance = ComboManager._internal();\
  \
  factory ComboManager() {\
    return _instance;\
  }\
  \
  ComboManager._internal();\
  \
  final List<ComboEffect> _activeEffects = [];\
  int _currentCombo = 0;\
  int _maxCombo = 0;\
  \
  int get currentCombo => _currentCombo;\
  int get maxCombo => _maxCombo;\
  \
  void incrementCombo(BuildContext context, {Offset? position}) {\  _currentCombo++;\
  if (_currentCombo > _maxCombo) {\  _maxCombo = _currentCombo;\
  }\
  \
  if (currentCombo >= 3) {\  _showComboEffect(context, position ?? const Offset(100, 100));\
  }\
  \
  // 每达到5连击的倍数，触发振动\
  if (currentCombo % 5 == 0) {\  _triggerHapticFeedback();\
  }\
  }\
  \
  void resetCombo() {\
    _currentCombo = 0;\
  }\
  \
  void _showComboEffect(BuildContext context, Offset position) {\
    final overlay = Overlay.of(context);\
    final entry = OverlayEntry(\  builder: (context) => ComboEffect(\  comboCount: _currentCombo,\
  position: position,\
  onComplete: () {\
    // 动画完成后自动移除\
  },\
  ),\
  );\
  \
    overlay.insert(entry);\
    _activeEffects.add(ComboEffect(\  comboCount: _currentCombo,\  position: position,\
  ));\
    \
    // 1.5秒后移除特效\
    Future.delayed(const Duration(milliseconds: 1500), () {\
      entry.remove();\
      _activeEffects.removeWhere((effect) => effect.comboCount == _currentCombo);\
  });\
  }\
  \
  void _triggerHapticFeedback() {\
    // 这里可以添加振动反馈\
    // HapticFeedback.heavyImpact();\
  }\
}