import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workout_plan.dart';
import '../services/progress_store.dart';

class WorkoutScreen extends StatefulWidget {
  final WorkoutPlan plan;
  const WorkoutScreen({super.key, required this.plan});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  Timer? _timer;
  int _index = 0;
  int _secondsLeft = 0;
  bool _isRest = false;
  bool _paused = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.plan.exercises.first.durationSec;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (_paused || _finished || !mounted) return;
    if (_secondsLeft > 1) {
      setState(() => _secondsLeft--);
      return;
    }
    HapticFeedback.mediumImpact();
    if (_isRest) {
      _goNextExercise();
    } else {
      _startRestOrFinish();
    }
  }

  void _startRestOrFinish() {
    final isLast = _index == widget.plan.exercises.length - 1;
    if (isLast) {
      _finishWorkout();
      return;
    }
    setState(() {
      _isRest = true;
      _secondsLeft = widget.plan.exercises[_index].restSec;
    });
  }

  void _goNextExercise() {
    setState(() {
      _index++;
      _isRest = false;
      _secondsLeft = widget.plan.exercises[_index].durationSec;
    });
  }

  Future<void> _finishWorkout() async {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();
    await ProgressStore.addCompletedWorkout();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.emoji_events_rounded, size: 46),
        title: const Text('Hoàn thành!'),
        content: Text('Bạn đã hoàn thành “${widget.plan.name}”. Nghỉ ngơi, uống đủ nước và duy trì đều đặn nhé.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tuyệt!'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  void _skip() {
    if (_isRest) {
      _goNextExercise();
    } else {
      _startRestOrFinish();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.plan.exercises[_index];
    final phaseTotal = _isRest ? ex.restSec : ex.durationSec;
    final progress = phaseTotal == 0 ? 0.0 : 1 - (_secondsLeft / phaseTotal);
    final totalProgress = (_index + (_isRest ? .7 : .2)) / widget.plan.exercises.length;

    return WillPopScope(
      onWillPop: () async {
        final leave = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Dừng buổi tập?'),
            content: const Text('Tiến độ buổi tập hiện tại sẽ không được tính là hoàn thành.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tiếp tục tập')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Dừng')),
            ],
          ),
        );
        return leave ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${_index + 1}/${widget.plan.exercises.length}'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.close)),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                LinearProgressIndicator(value: totalProgress.clamp(0, 1)),
                const SizedBox(height: 26),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _isRest ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    children: [
                      Text(_isRest ? 'NGHỈ' : 'ĐANG TẬP', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 18),
                      Text(_isRest ? '😮‍💨' : ex.emoji, style: const TextStyle(fontSize: 70)),
                      const SizedBox(height: 10),
                      Text(_isRest ? 'Chuẩn bị: ${widget.plan.exercises[_index + 1].name}' : ex.name, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox.expand(child: CircularProgressIndicator(value: progress.clamp(0, 1), strokeWidth: 10)),
                            Text('$_secondsLeft', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (!_isRest)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.tips_and_updates_outlined),
                          const SizedBox(width: 12),
                          Expanded(child: Text('${ex.cue}\n\nDụng cụ: ${ex.band} • Nhóm cơ: ${ex.muscle}')),
                        ],
                      ),
                    ),
                  ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _paused = !_paused),
                        icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
                        label: Text(_paused ? 'Tiếp tục' : 'Tạm dừng'),
                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: _skip,
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Bỏ qua'),
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
