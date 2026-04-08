import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import '../models/models.dart';

/// AR Service for displaying word cards in augmented reality.
/// Uses camera preview as background with 3D-style card overlays.
class ArService {
  static final ArService _instance = ArService._();
  factory ArService() => _instance;
  ArService._();

  CameraController? _cameraController;
  bool _isRunning = false;
  List<CameraDescription>? _cameras;

  bool get isRunning => _isRunning;
  CameraController? get cameraController => _cameraController;

  /// Initialize camera for AR view
  Future<bool> initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) return false;

      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Start AR view
  Future<void> start() async {
    if (_cameraController != null && !_isRunning) {
      try {
        await _cameraController!.startImageStream((_) {});
        _isRunning = true;
      } catch (_) {}
    }
  }

  /// Stop AR view
  Future<void> stop() async {
    if (_cameraController != null && _isRunning) {
      try {
        await _cameraController!.stopImageStream();
      } catch (_) {}
      _isRunning = false;
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await stop();
    _cameraController?.dispose();
    _cameraController = null;
  }
}

/// Widget that shows a word card floating over the camera feed (AR-style)
class ArCardView extends StatefulWidget {
  final CardItem card;
  final VoidCallback? onClose;

  const ArCardView({
    super.key,
    required this.card,
    this.onClose,
  });

  @override
  State<ArCardView> createState() => _ArCardViewState();
}

class _ArCardViewState extends State<ArCardView>
    with TickerProviderStateMixin {
  CameraController? _controller;
  bool _cameraReady = false;
  String _currentView = 'card'; // 'card', 'word', 'sentence'

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      _controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
      if (mounted) setState(() => _cameraReady = true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller?.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera background
          if (_cameraReady && _controller != null)
            SizedBox.expand(
              child: CameraPreview(_controller!),
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                ),
              ),
            ),

          // AR overlay elements
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onClose,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔮',
                                style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            const Text(
                              'AR 单词卡',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Floating AR card
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: child,
                    );
                  },
                  child: _buildArCard(),
                ),

                const SizedBox(height: 40),

                // Bottom controls
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ArButton(
                        icon: Icons.image_rounded,
                        label: '图片',
                        isActive: _currentView == 'card',
                        onTap: () => setState(() => _currentView = 'card'),
                      ),
                      _ArButton(
                        icon: Icons.text_fields_rounded,
                        label: '单词',
                        isActive: _currentView == 'word',
                        onTap: () => setState(() => _currentView = 'word'),
                      ),
                      _ArButton(
                        icon: Icons.auto_awesome_rounded,
                        label: '效果',
                        isActive: _currentView == 'sentence',
                        onTap: () => setState(() => _currentView = 'sentence'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArCard() {
    final isEffect = _currentView == 'sentence';
    final isWord = _currentView == 'word';

    return AnimatedScale(
      scale: isEffect ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isWord
              ? Colors.transparent
              : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF6C5CE7).withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C5CE7).withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: isWord
            ? Center(
                child: Text(
                  widget.card.word,
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isWord)
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF6C5CE7).withOpacity(0.2),
                        ),
                      ),
                      child: const Center(
                        child: Text('🖼️',
                            style: TextStyle(fontSize: 72)),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    widget.card.word,
                    style: TextStyle(
                      fontSize: isEffect ? 36 : 32,
                      fontWeight: FontWeight.w800,
                      color: isEffect ? const Color(0xFF6C5CE7) : Colors.black87,
                    ),
                  ),
                  if (isEffect) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${widget.card.word} - AR Word Card',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _ArButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ArButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF6C5CE7)
              : Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? null
              : Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
