import 'package:flutter/material.dart';
import '../../services/daily_log_service.dart';
import '../../services/routine_service.dart';
import '../../services/feedback_service.dart';

class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({super.key});

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  late Future<List<DailyLog>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _logsFuture = DailyLogService.getDailyLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Logs'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _logsFuture = DailyLogService.getDailyLogs();
          });
        },
        child: FutureBuilder<List<DailyLog>>(
          future: _logsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF34C759).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.book,
                          size: 40,
                          color: Color(0xFF34C759),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No logs yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Create your first daily log',
                        style: TextStyle(
                          color: const Color(0xFF8E8E93),
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final logs = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return DailyLogCard(
                  log: log,
                  onRefresh: () {
                    setState(() {
                      _logsFuture = DailyLogService.getDailyLogs();
                    });
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateLogDialog,
        backgroundColor: const Color(0xFF34C759),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCreateLogDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateDailyLogDialog(),
    ).then((_) {
      setState(() {
        _logsFuture = DailyLogService.getDailyLogs();
      });
    });
  }
}

class DailyLogCard extends StatelessWidget {
  final DailyLog log;
  final Function() onRefresh;

  const DailyLogCard({super.key, 
    required this.log,
    required this.onRefresh,
  });

  String _getMoodEmoji(int mood) {
    if (mood >= 8) return '😄';
    if (mood >= 6) return '🙂';
    if (mood >= 4) return '😐';
    if (mood >= 2) return '😞';
    return '😢';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF34C759).withOpacity(0.15),
            const Color(0xFF34C759).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DailyLogDetailScreen(
                log: log,
                onRefresh: onRefresh,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mood: ${log.mood}/10 ${_getMoodEmoji(log.mood)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        log.logDate.toString().split(' ')[0],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF8E8E93)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _IndicatorColumn(
                    icon: Icons.battery_full,
                    label: 'Energy',
                    value: log.energyLevel,
                  ),
                  _IndicatorColumn(
                    icon: Icons.warning,
                    label: 'Stress',
                    value: log.stressLevel,
                  ),
                  _IndicatorColumn(
                    icon: Icons.task_alt,
                    label: 'Routines',
                    value: log.routineEntriesCount,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IndicatorColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;

  const _IndicatorColumn({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class CreateDailyLogDialog extends StatefulWidget {
  const CreateDailyLogDialog({super.key});

  @override
  State<CreateDailyLogDialog> createState() => _CreateDailyLogDialogState();
}

class _CreateDailyLogDialogState extends State<CreateDailyLogDialog> {
  int _mood = 5;
  int _energy = 5;
  int _stress = 5;
  final _notesController = TextEditingController();
  final _highlightsController = TextEditingController();
  final _challengesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    _highlightsController.dispose();
    _challengesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Daily Log'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Mood: $_mood/10'),
            Slider(
              value: _mood.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: _mood.toString(),
              onChanged: (value) {
                setState(() {
                  _mood = value.toInt();
                });
              },
            ),
            const SizedBox(height: 12),
            Text('Energy Level: $_energy/10'),
            Slider(
              value: _energy.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: _energy.toString(),
              onChanged: (value) {
                setState(() {
                  _energy = value.toInt();
                });
              },
            ),
            const SizedBox(height: 12),
            Text('Stress Level: $_stress/10'),
            Slider(
              value: _stress.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: _stress.toString(),
              onChanged: (value) {
                setState(() {
                  _stress = value.toInt();
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
                hintText: 'What happened today?',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _highlightsController,
              decoration: const InputDecoration(
                labelText: 'Highlights',
                border: OutlineInputBorder(),
                hintText: 'What went well?',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _challengesController,
              decoration: const InputDecoration(
                labelText: 'Challenges',
                border: OutlineInputBorder(),
                hintText: 'What was difficult?',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createLog,
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _createLog() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await DailyLogService.createDailyLog(
        mood: _mood,
        energyLevel: _energy,
        stressLevel: _stress,
        notes: _notesController.text,
        highlights: _highlightsController.text,
        challenges: _challengesController.text,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Daily log created successfully')),
        );
      }
    } catch (e) {
      if (e.toString().contains('already exists')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You already have a log for today')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class DailyLogDetailScreen extends StatefulWidget {
  final DailyLog log;
  final Function() onRefresh;

  const DailyLogDetailScreen({super.key, 
    required this.log,
    required this.onRefresh,
  });

  @override
  State<DailyLogDetailScreen> createState() => _DailyLogDetailScreenState();
}

class _DailyLogDetailScreenState extends State<DailyLogDetailScreen> {
  late Future<DailyLogDetail> _detailFuture;
  late Future<List<Routine>> _routinesFuture;
  MentorFeedback? _feedback;
  bool _feedbackLoading = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = DailyLogService.getDailyLogByDate(widget.log.logDate);
    _routinesFuture = RoutineService.getRoutines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.log.logDate.toString().split(' ')[0]),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        elevation: 4,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _detailFuture = DailyLogService.getDailyLogByDate(widget.log.logDate);
          });
        },
        child: FutureBuilder<DailyLogDetail>(
          future: _detailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: Text('No data'));
            }

            final detail = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Metrics',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _MetricCard(
                                label: 'Mood',
                                value: detail.mood,
                                icon: Icons.sentiment_satisfied,
                              ),
                              _MetricCard(
                                label: 'Energy',
                                value: detail.energyLevel,
                                icon: Icons.battery_full,
                              ),
                              _MetricCard(
                                label: 'Stress',
                                value: detail.stressLevel,
                                icon: Icons.warning,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextSection(
                    context,
                    'Notes',
                    detail.notes,
                    Icons.note,
                  ),
                  const SizedBox(height: 12),
                  _buildTextSection(
                    context,
                    'Highlights',
                    detail.highlights,
                    Icons.star,
                  ),
                  const SizedBox(height: 12),
                  _buildTextSection(
                    context,
                    'Challenges',
                    detail.challenges,
                    Icons.warning_amber,
                  ),
                  const SizedBox(height: 16),
                  _buildRoutineSection(context, detail),
                  const SizedBox(height: 16),
                  _buildFeedbackSection(context, detail),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content.isEmpty ? 'No entry' : content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineSection(BuildContext context, DailyLogDetail detail) {
    return FutureBuilder<List<Routine>>(
      future: _routinesFuture,
      builder: (context, snapshot) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Routines (${detail.routineEntries.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (snapshot.hasData)
                      ElevatedButton.icon(
                        onPressed: () => _showAddRoutineDialog(context, detail, snapshot.data!),
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (detail.routineEntries.isEmpty)
                  Text(
                    'No routines logged yet',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: detail.routineEntries.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final entry = detail.routineEntries[index];
                      return RoutineEntryTile(entry: entry);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeedbackSection(BuildContext context, DailyLogDetail detail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF007AFF).withOpacity(0.15),
            const Color(0xFF007AFF).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🤖 Mentor Feedback',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
              ),
              if (!_feedbackLoading)
                ElevatedButton.icon(
                  onPressed: _generateFeedback,
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: const Text('Generate'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_feedbackLoading)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Mentor is thinking...', style: TextStyle(fontSize: 13)),
                ],
              ),
            )
          else if (_feedback != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Compliance Rate
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getComplianceColor(_feedback!.routineComplianceRate.toInt())
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Compliance',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_feedback!.routineComplianceRate.toInt()}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: _getComplianceColor(
                                _feedback!.routineComplianceRate.toInt(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      _buildComplianceGauge(
                        _feedback!.routineComplianceRate.toInt(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Top Performer & Biggest Miss
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF34C759).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '⭐ Top Performer',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF34C759),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _feedback!.topPerformer,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3B30).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '💡 Needs Work',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFF3B30),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _feedback!.biggestMiss,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Mentor Suggestion
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF007AFF).withOpacity(0.12),
                        const Color(0xFF007AFF).withOpacity(0.04),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF007AFF).withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D007AFF),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lightbulb_outline,
                              size: 18, color: Color(0xFF007AFF)),
                          SizedBox(width: 8),
                          Text(
                            'Mentor\'s Advice',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF007AFF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _feedback!.suggestions,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Text(
                    '💬',
                    style: TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No feedback yet',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Generate feedback to get personalized insights',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF8E8E93),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getComplianceColor(int compliance) {
    if (compliance >= 80) return const Color(0xFF34C759);
    if (compliance >= 60) return const Color(0xFFFF9500);
    return const Color(0xFFFF3B30);
  }

  Widget _buildComplianceGauge(int compliance) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CustomPaint(
              painter: _ComplianceGaugePainter(
                compliance: compliance,
                color: _getComplianceColor(compliance),
              ),
            ),
          ),
          Text(
            '${compliance}%',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateFeedback() async {
    setState(() {
      _feedbackLoading = true;
    });

    try {
      final feedback = await FeedbackService.generateFeedback(widget.log.id);
      setState(() {
        _feedback = feedback;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback generated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _feedbackLoading = false;
      });
    }
  }

  void _showAddRoutineDialog(
    BuildContext context,
    DailyLogDetail detail,
    List<Routine> allRoutines,
  ) {
    final availableRoutines = allRoutines
        .where((r) => !detail.routineEntries.any((e) => e.routineId == r.id))
        .toList();

    if (availableRoutines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All routines already logged')),
      );
      return;
    }

    // Store values before the dialog builder to avoid scope issues
    final logId = widget.log.id;
    final logDate = widget.log.logDate;

    showDialog(
      context: context,
      builder: (dialogContext) => AddRoutineEntryDialog(
        logId: logId,
        routines: availableRoutines,
        onAdded: () {
          setState(() {
            _detailFuture = DailyLogService.getDailyLogByDate(logDate);
          });
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 8),
        Text(
          '$value/10',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class RoutineEntryTile extends StatefulWidget {
  final RoutineEntry entry;
  final VoidCallback? onStatusChanged;

  const RoutineEntryTile({
    super.key, 
    required this.entry,
    this.onStatusChanged,
  });

  @override
  State<RoutineEntryTile> createState() => _RoutineEntryTileState();
}

class _RoutineEntryTileState extends State<RoutineEntryTile> {
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.entry.status;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF34C759);
      case 'partial':
        return const Color(0xFFFF9500);
      case 'skipped':
        return const Color(0xFFFF3B30);
      default:
        return const Color(0xFF8E8E93);
    }
  }

  String _getStatusEmoji(String status) {
    switch (status) {
      case 'completed':
        return '✅';
      case 'partial':
        return '⚠️';
      case 'skipped':
        return '⏭️';
      default:
        return '❓';
    }
  }

  void _updateStatus(String newStatus) {
    setState(() {
      _currentStatus = newStatus;
    });
    widget.onStatusChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? const Color(0xFFF2F2F7)
            : const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.entry.routineName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (widget.entry.actualDuration != null)
                      Text(
                        '${widget.entry.actualDuration} min (${widget.entry.completionPercentage}%)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(_currentStatus).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _currentStatus.capitalize(),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(_currentStatus),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Quick-log buttons
          Row(
            children: [
              Expanded(
                child: _QuickLogButton(
                  emoji: '✅',
                  label: 'Completed',
                  isActive: _currentStatus == 'completed',
                  onPressed: () => _updateStatus('completed'),
                  color: const Color(0xFF34C759),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickLogButton(
                  emoji: '⚠️',
                  label: 'Partial',
                  isActive: _currentStatus == 'partial',
                  onPressed: () => _updateStatus('partial'),
                  color: const Color(0xFFFF9500),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickLogButton(
                  emoji: '⏭️',
                  label: 'Skipped',
                  isActive: _currentStatus == 'skipped',
                  onPressed: () => _updateStatus('skipped'),
                  color: const Color(0xFFFF3B30),
                ),
              ),
            ],
          ),
          if (widget.entry.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              widget.entry.notes,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8E8E93),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickLogButton extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;
  final Color color;

  const _QuickLogButton({
    required this.emoji,
    required this.label,
    required this.isActive,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.15) : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? color : color.withOpacity(0.3),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? color : const Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddRoutineEntryDialog extends StatefulWidget {
  final int logId;
  final List<Routine> routines;
  final Function() onAdded;

  const AddRoutineEntryDialog({super.key, 
    required this.logId,
    required this.routines,
    required this.onAdded,
  });

  @override
  State<AddRoutineEntryDialog> createState() => _AddRoutineEntryDialogState();
}

class _AddRoutineEntryDialogState extends State<AddRoutineEntryDialog> {
  late Routine _selectedRoutine;
  String _status = 'completed';
  int _completionPercentage = 100;
  int? _actualDuration;
  int? _difficultyFelt;
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRoutine = widget.routines.first;
    _actualDuration = _selectedRoutine.targetDuration;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Routine Entry'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Routine>(
              initialValue: _selectedRoutine,
              decoration: const InputDecoration(
                labelText: 'Routine',
                border: OutlineInputBorder(),
              ),
              items: widget.routines
                  .map((r) => DropdownMenuItem(value: r, child: Text(r.name)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRoutine = value!;
                  _actualDuration = _selectedRoutine.targetDuration;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: ['completed', 'partial', 'skipped', 'not_done']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
            ),
            const SizedBox(height: 12),
            Text('Completion: $_completionPercentage%'),
            Slider(
              value: _completionPercentage.toDouble(),
              min: 0,
              max: 100,
              divisions: 10,
              label: _completionPercentage.toString(),
              onChanged: (value) {
                setState(() {
                  _completionPercentage = value.toInt();
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Actual Duration (minutes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _actualDuration = int.tryParse(value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Difficulty Felt (1-10)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _difficultyFelt = int.tryParse(value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addEntry,
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Add'),
        ),
      ],
    );
  }

  Future<void> _addEntry() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await DailyLogService.addRoutineEntry(
        logId: widget.logId,
        routineId: _selectedRoutine.id,
        status: _status,
        completionPercentage: _completionPercentage,
        actualDuration: _actualDuration,
        difficultyFelt: _difficultyFelt,
        notes: _notesController.text,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Routine entry added successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

extension StringExt on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class _ComplianceGaugePainter extends CustomPainter {
  final int compliance;
  final Color color;

  _ComplianceGaugePainter({
    required this.compliance,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    // Progress arc
    final angle = (compliance / 100) * 2 * 3.14159;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      angle,
      false,
      Paint()
        ..color = color
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_ComplianceGaugePainter oldDelegate) {
    return oldDelegate.compliance != compliance || oldDelegate.color != color;
  }
}
