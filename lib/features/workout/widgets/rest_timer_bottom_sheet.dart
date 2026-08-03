import 'package:flutter/material.dart';

import '../../../shared/services/settings_service.dart';
import '../controllers/rest_timer_controller.dart';

class RestTimerBottomSheet extends StatefulWidget {
  final int? initialSeconds;

  const RestTimerBottomSheet({super.key, this.initialSeconds});

  static void show(BuildContext context, {int? initialSeconds}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RestTimerBottomSheet(initialSeconds: initialSeconds),
    );
  }

  @override
  State<RestTimerBottomSheet> createState() => _RestTimerBottomSheetState();
}

class _RestTimerBottomSheetState extends State<RestTimerBottomSheet> {
  final _controller = RestTimerController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTimerChanged);
    _controller.startTimer(
      widget.initialSeconds ?? SettingsService().defaultRestSeconds,
    );
  }

  void _onTimerChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onTimerChanged);
    _controller.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

  Widget _buildTimeButton(int seconds, String label) => ActionChip(
    label: Text(label),
    onPressed: () => _controller.startTimer(seconds),
  );

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: 24,
      right: 24,
      top: 24,
      bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Descanso', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 32),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                value: _controller.progress,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade300,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              _formatTime(_controller.remainingSeconds),
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 32),
        if (!_controller.isRunning && _controller.remainingSeconds == 0)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildTimeButton(30, '30s'),
              _buildTimeButton(45, '45s'),
              _buildTimeButton(60, '1m'),
              _buildTimeButton(90, '1m30s'),
              ActionChip(
                label: const Text('Personalizado'),
                onPressed: () => _controller.startTimer(120),
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 48,
                icon: Icon(
                  _controller.isRunning
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                ),
                onPressed: _controller.isRunning
                    ? _controller.pauseTimer
                    : _controller.resumeTimer,
              ),
              const SizedBox(width: 24),
              IconButton(
                iconSize: 48,
                icon: const Icon(Icons.stop_circle),
                onPressed: _controller.stopTimer,
              ),
            ],
          ),
        const SizedBox(height: 16),
      ],
    ),
  );
}
