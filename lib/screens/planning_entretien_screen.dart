import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sunnypool_app/services/planning_service.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:sunnypool_app/utils/token_storage.dart';

import 'profile_screen.dart';

class PlanningEntretienScreen extends StatefulWidget {
  const PlanningEntretienScreen({super.key});

  @override
  State<PlanningEntretienScreen> createState() =>
      _PlanningEntretienScreenState();
}

enum ButtonOption { calendar, list }

class _PlanningTask {
  _PlanningTask({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.notes = '',
    this.isDone = false,
  });

  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final String notes;
  final bool isDone;

  _PlanningTask copyWith({
    String? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    Color? color,
    String? notes,
    bool? isDone,
  }) {
    return _PlanningTask(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      notes: notes ?? this.notes,
      isDone: isDone ?? this.isDone,
    );
  }
}

class _PlanningDataSource extends CalendarDataSource {
  _PlanningDataSource(List<Appointment> source) {
    appointments = source;
  }

  void updateAppointments(List<Appointment> source) {
    appointments = source;
    notifyListeners(CalendarDataSourceAction.reset, source);
  }
}

class _PlanningDraft {
  _PlanningDraft({
    required this.title,
    required this.notes,
    required this.startTime,
    required this.endTime,
    required this.color,
  });

  final String title;
  final String notes;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
}

class _AddPlanningBottomSheet extends StatefulWidget {
  const _AddPlanningBottomSheet();

  @override
  State<_AddPlanningBottomSheet> createState() =>
      _AddPlanningBottomSheetState();
}

class _AddPlanningBottomSheetState extends State<_AddPlanningBottomSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final DateFormat _fullDateFormat = DateFormat('dd/MM/yyyy', 'fr_FR');

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late int _durationInMinutes;
  late Color _selectedColor;

  bool _isDatePickerOpen = false;
  bool _isTimePickerOpen = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _durationInMinutes = 60;
    _selectedColor = Colors.amber.shade700;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    if (_isDatePickerOpen) {
      return;
    }
    _isDatePickerOpen = true;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      locale: const Locale('fr', 'FR'),
    );
    _isDatePickerOpen = false;
    if (!mounted || picked == null) {
      return;
    }
    setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    if (_isTimePickerOpen) {
      return;
    }
    _isTimePickerOpen = true;
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    _isTimePickerOpen = false;
    if (!mounted || picked == null) {
      return;
    }
    setState(() => _selectedTime = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final startTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final endTime = startTime.add(Duration(minutes: _durationInMinutes));

    Navigator.of(context).pop(
      _PlanningDraft(
        title: _titleController.text.trim(),
        notes: _notesController.text.trim(),
        startTime: startTime,
        endTime: endTime,
        color: _selectedColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Ajouter un planning',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Titre de la tâche',
                    hintText: 'Ex: Nettoyage du filtre',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le titre est obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optionnel)',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.event),
                        label: Text(_fullDateFormat.format(_selectedDate)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.schedule),
                        label: Text(_selectedTime.format(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _durationInMinutes,
                  decoration: const InputDecoration(labelText: 'Durée'),
                  items: const [
                    DropdownMenuItem(value: 30, child: Text('30 minutes')),
                    DropdownMenuItem(value: 45, child: Text('45 minutes')),
                    DropdownMenuItem(value: 60, child: Text('1 heure')),
                    DropdownMenuItem(value: 90, child: Text('1 heure 30')),
                    DropdownMenuItem(value: 120, child: Text('2 heures')),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _durationInMinutes = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Color>(
                  initialValue: _selectedColor,
                  decoration: const InputDecoration(
                    labelText: 'Type / Couleur',
                  ),
                  items: [
                    DropdownMenuItem(
                      value: Colors.amber.shade700,
                      child: const Text('Nettoyage'),
                    ),
                    DropdownMenuItem(
                      value: Colors.lightBlue.shade600,
                      child: const Text('Analyse de l\'eau'),
                    ),
                    DropdownMenuItem(
                      value: Colors.green.shade600,
                      child: const Text('Vérification équipement'),
                    ),
                    DropdownMenuItem(
                      value: Colors.deepOrange.shade400,
                      child: const Text('Traitement'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _selectedColor = value);
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter au planning'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanningEntretienScreenState extends State<PlanningEntretienScreen> {
  final PlanningService _planningService = PlanningService();
  final List<_PlanningTask> _planningItems = [];
  final DateFormat _dayFormat = DateFormat('EEEE d MMMM', 'fr_FR');
  final DateFormat _hourFormat = DateFormat('HH:mm', 'fr_FR');
  late final _PlanningDataSource _planningDataSource;

  ButtonOption _buttonOption = ButtonOption.calendar;
  bool _isAddSheetOpen = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadingError;

  @override
  void initState() {
    super.initState();
    _planningDataSource = _PlanningDataSource([]);
    _loadPlannings();
  }

  Future<String> _requireToken() async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Session expirée, veuillez vous reconnecter.');
    }
    return token;
  }

  bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final v = value.toLowerCase();
      return v == '1' || v == 'true';
    }
    return false;
  }

  DateTime _parseApiDate(dynamic value, {DateTime? fallback}) {
    if (value == null) return fallback ?? DateTime.now();
    final raw = value.toString().trim();
    if (raw.isEmpty) return fallback ?? DateTime.now();
    return DateTime.tryParse(raw.replaceFirst(' ', 'T')) ??
        fallback ??
        DateTime.now();
  }

  Color _colorFromTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('analyse') || t.contains('chlore') || t.contains('ph')) {
      return Colors.lightBlue.shade600;
    }
    if (t.contains('pompe') || t.contains('equipement')) {
      return Colors.green.shade600;
    }
    if (t.contains('traitement') || t.contains('produit')) {
      return Colors.deepOrange.shade400;
    }
    return Colors.amber.shade700;
  }

  _PlanningTask? _taskFromApi(dynamic item) {
    if (item is! Map) return null;
    final id = item['id']?.toString();
    if (id == null || id.isEmpty) return null;

    final start = _parseApiDate(item['startTime']);
    final end = _parseApiDate(
      item['endTime'],
      fallback: start.add(const Duration(hours: 1)),
    );

    final title = (item['title'] ?? '').toString().trim();
    return _PlanningTask(
      id: id,
      title: title.isEmpty ? 'Nouvelle tâche' : title,
      startTime: start,
      endTime: end,
      color: _colorFromTitle(title),
      notes: (item['notes'] ?? '').toString(),
      isDone: _toBool(item['isDone']),
    );
  }

  Future<void> _loadPlannings() async {
    setState(() {
      _isLoading = true;
      _loadingError = null;
    });

    try {
      final token = await _requireToken();
      final response = await _planningService.getAllPlanning(token);
      final data = response['data'];

      final List<_PlanningTask> fetched = [];
      if (data is List) {
        for (final item in data) {
          final parsed = _taskFromApi(item);
          if (parsed != null) fetched.add(parsed);
        }
      }

      if (!mounted) return;
      setState(() {
        _planningItems
          ..clear()
          ..addAll(fetched);
        _sortPlanning();
        _syncCalendarSource();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadingError = e.toString();
      });
    }
  }

  void _sortPlanning() {
    _planningItems.sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<Appointment> _appointmentsFromPlanning() {
    return _planningItems
        .map(
          (item) => Appointment(
            id: item.id,
            startTime: item.startTime,
            endTime: item.endTime,
            subject: item.title,
            notes: item.notes,
            color: item.isDone ? Colors.grey : item.color,
          ),
        )
        .toList();
  }

  void _syncCalendarSource() {
    _planningDataSource.updateAppointments(_appointmentsFromPlanning());
  }

  Future<void> _showAddPlanningSheet() async {
    if (_isAddSheetOpen) {
      return;
    }
    _isAddSheetOpen = true;
    try {
      final draft = await showModalBottomSheet<_PlanningDraft>(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF121212),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => const _AddPlanningBottomSheet(),
      );

      if (!mounted || draft == null) {
        return;
      }

      await _addPlanning(draft);
    } finally {
      _isAddSheetOpen = false;
    }
  }

  Future<void> _addPlanning(_PlanningDraft draft) async {
    setState(() => _isSaving = true);
    try {
      final token = await _requireToken();
      final response = await _planningService.addPlanning(
        token,
        title: draft.title,
        startTime: draft.startTime,
        endTime: draft.endTime,
        notes: draft.notes,
      );

      final created = _taskFromApi(response['data']);
      if (!mounted) return;

      setState(() {
        if (created != null) {
          _planningItems.add(created);
          _sortPlanning();
          _syncCalendarSource();
        }
      });

      if (created == null) {
        await _loadPlannings();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Planning ajouté avec succès')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur ajout planning: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _toggleDone(_PlanningTask item) async {
    final index = _planningItems.indexWhere((it) => it.id == item.id);
    if (index < 0) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final token = await _requireToken();
      final response = await _planningService.updatePlanning(
        token,
        int.parse(item.id),
        isDone: !item.isDone,
      );

      final updated = _taskFromApi(response['data']);
      if (!mounted) return;
      setState(() {
        _planningItems[index] = updated ?? item.copyWith(isDone: !item.isDone);
        _sortPlanning();
        _syncCalendarSource();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur mise à jour: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _removePlanning(_PlanningTask item) async {
    setState(() => _isSaving = true);
    try {
      final token = await _requireToken();
      await _planningService.deletePlanning(token, int.parse(item.id));

      if (!mounted) return;
      setState(() {
        _planningItems.removeWhere((it) => it.id == item.id);
        _syncCalendarSource();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Planning supprimé')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur suppression: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showPlanningActions(_PlanningTask item) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF171717),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              children: [
                ListTile(
                  title: Text(
                    item.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${_dayFormat.format(item.startTime)} • ${_hourFormat.format(item.startTime)} - ${_hourFormat.format(item.endTime)}',
                  ),
                ),
                ListTile(
                  leading: Icon(
                    item.isDone
                        ? Icons.radio_button_unchecked
                        : Icons.check_circle_outline,
                    color: Colors.amber,
                  ),
                  title: Text(
                    item.isDone ? 'Marquer non terminé' : 'Marquer terminé',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _toggleDone(item);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'Supprimer',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _removePlanning(item);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onCalendarTap(CalendarTapDetails details) {
    if (details.targetElement != CalendarElement.appointment ||
        details.appointments == null ||
        details.appointments!.isEmpty) {
      return;
    }
    final appointment = details.appointments!.first as Appointment;
    final id = appointment.id as String?;
    if (id == null) {
      return;
    }
    final selectedItem = _planningItems
        .where((item) => item.id == id)
        .firstOrNull;
    if (selectedItem == null) {
      return;
    }
    _showPlanningActions(selectedItem);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning d\'entretien'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/icon.png'),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050505), Color(0xFF111111)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Organise les entretiens de ta piscine',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<ButtonOption>(
              segments: const [
                ButtonSegment<ButtonOption>(
                  value: ButtonOption.calendar,
                  icon: Icon(Icons.calendar_month_outlined),
                  label: Text('Calendrier'),
                ),
                ButtonSegment<ButtonOption>(
                  value: ButtonOption.list,
                  icon: Icon(Icons.list_alt_outlined),
                  label: Text('Liste'),
                ),
              ],
              selected: {_buttonOption},
              style: SegmentedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black87,
                selectedBackgroundColor: Colors.amber.shade700,
                selectedForegroundColor: Colors.white,
              ),
              onSelectionChanged: (selection) {
                setState(() => _buttonOption = selection.first);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _loadingError != null && _planningItems.isEmpty
                  ? _buildLoadingError()
                  : _buttonOption == ButtonOption.calendar
                  ? _buildCalendarPlanning()
                  : _buildListPlanning(),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _showAddPlanningSheet,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un planning'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarPlanning() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SfCalendar(
        view: CalendarView.month,
        firstDayOfWeek: 1,
        // Workaround: avoid SfCalendar internal date-picker route lifecycle
        // issues that can trigger duplicate key/element assertions.
        showDatePickerButton: false,
        showNavigationArrow: true,
        monthViewSettings: const MonthViewSettings(
          // Better stability with multiple events on the same day.
          appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
          showAgenda: true,
          agendaViewHeight: 180,
        ),
        todayHighlightColor: Colors.amber,
        dataSource: _planningDataSource,
        onTap: _onCalendarTap,
      ),
    );
  }

  Widget _buildListPlanning() {
    if (_planningItems.isEmpty) {
      return Center(
        child: Text(
          'Aucun planning pour le moment',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
        ),
      );
    }

    return ListView.separated(
      itemCount: _planningItems.length,
      separatorBuilder: (_, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _planningItems[index];
        return Card(
          color: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: ListTile(
            onTap: () => _showPlanningActions(item),
            leading: Icon(
              item.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: item.isDone ? Colors.greenAccent : item.color,
            ),
            title: Text(
              item.title,
              style: TextStyle(
                color: Colors.white,
                decoration: item.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              '${_dayFormat.format(item.startTime)} • ${_hourFormat.format(item.startTime)} - ${_hourFormat.format(item.endTime)}'
              '${item.notes.isEmpty ? '' : '\n${item.notes}'}',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white70),
              onPressed: () => _showPlanningActions(item),
            ),
            isThreeLine: item.notes.isNotEmpty,
          ),
        );
      },
    );
  }

  Widget _buildLoadingError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
            const SizedBox(height: 10),
            Text(
              'Impossible de charger le planning',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              _loadingError ?? '',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _loadPlannings,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
