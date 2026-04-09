import 'package:flutter/material.dart';
import 'package:race_word_game/services/api_service.dart';

class VoiceScoreScreen extends StatefulWidget {
  final String word;
  final String userId;
  final VoidCallback? onComplete;

  const VoiceScoreScreen({
    super.key,
    required this.word,
    required this.userId,
    this.onComplete,
  });

  @override
  State<VoiceScoreScreen> createState() => _VoiceScoreScreenState();
}

class _VoiceScoreScreenState extends State<VoiceScoreScreen>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _isProcessing = false;
  double _score = 0;
  String _feedback = '';
  late AnimationController _waveController;
  List<double> _waveformData = List.filled(30, 0.0);

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });
      _waveformData = List.filled(30, 0.0);

      // Call API for voice score
      try {
        final result = await ApiService.voiceScore(
          widget.word,
          widget.userId,
        );
        if (mounted) {
          setState(() {
            _score = (result['score'] ?? 70).toDouble();
            _feedback = result['feedback'] ?? '继续加油！💪';
            _isProcessing = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _score = 70;
            _feedback = '继续加油！💪';
            _isProcessing = false;
          });
        }
      }
    } else {
      setState(() {
        _isRecording = true;
        _score = 0;
        _feedback = '';
      });
      _simulateWaveform();
    }
  }

  void _simulateWaveform() {
    if (!_isRecording) return;
    setState(() {
      _waveformData = List.generate(
        30,
        (_) => 0.2 + (_isRecording ? (DateTime.now().millisecond % 80) / 100 : 0),
      );
    });
    Future.delayed(const Duration(milliseconds: 100), _simulateWaveform);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('语音评分'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Word display
            Text(
              widget.word,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '请朗读上面的单词',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            // Recording area
            _buildRecordingArea(),
            const SizedBox(height: 30),
            // Score display
            if (_score > 0) _buildScoreDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingArea() {
    return Column(
      children: [
        // Waveform
        SizedBox(
          height: 100,
          child: ListenableBuilder(
            listenable: _waveController,
            builder: (context, child) {
              return CustomPaint(
                painter: _WaveformPainter(
                  waveformData: _waveformData,
                  animationValue: _waveController.value,
                  isRecording: _isRecording,
                ),
                size: Size.infinite,
              );
            },
          ),
        ),
        const SizedBox(height: 40),
        // Record button
        GestureDetector(
          onTap: _isProcessing ? null : _toggleRecording,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: _isRecording
                    ? [Colors.red, Colors.orange]
                    : [Theme.of(context).primaryColor, Colors.blue],
              ),
              boxShadow: [
                BoxShadow(
                  color: (_isRecording ? Colors.red : Theme.of(context).primaryColor)
                      .withOpacity(0.3),
                  blurRadius: _isRecording ? 20 : 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              color: Colors.white,
              size: 50,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _isRecording ? '点击停止录音' : '点击开始录音',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        if (_isProcessing)
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildScoreDisplay() {
    final color = _score >= 90
        ? Colors.green
        : _score >= 70
            ? Colors.orange
            : Colors.red;

    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 6),
          ),
          child: Center(
            child: Text(
              '${_score.round()}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _feedback,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('完成'),
        ),
      ],
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final double animationValue;
  final bool isRecording;

  _WaveformPainter({
    required this.waveformData,
    required this.animationValue,
    required this.isRecording,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isRecording ? Colors.red.withOpacity(0.6) : Colors.blue.withOpacity(0.3)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    if (waveformData.isEmpty) return;

    final barWidth = size.width / waveformData.length;
    final centerY = size.height / 2;

    for (int i = 0; i < waveformData.length; i++) {
      final barHeight = waveformData[i] * size.height * 0.4;
      final x = i * barWidth + barWidth / 2;
      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.isRecording != isRecording ||
        oldDelegate.animationValue != animationValue;
  }
}
