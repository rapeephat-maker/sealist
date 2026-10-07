import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../app/colors.dart';
import '../../models/task_item.dart';
import '../../providers/settings_provider.dart';
import '../../providers/task_provider.dart';

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({super.key, required this.taskId});

  final String taskId;

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  // The task exactly as stored. We NEVER mutate it here — every edit lives in
  // the local fields below and is only written back when "บันทึก" is pressed,
  // so leaving with the back button really does discard changes.
  late final TaskItem? _original;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;

  DateTime? _dueDate;
  DateTime? _reminderAt;
  ReminderType _reminderType = ReminderType.none;
  Priority _priority = Priority.medium;
  String? _tag;

  static const _tagOptions = ['บ้าน', 'งาน', 'เงิน', 'โทรศัพท์', 'สุขภาพ'];

  @override
  void initState() {
    super.initState();
    final t = context.read<TaskProvider>().byId(widget.taskId);
    _original = t;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _dueDate = t?.dueDate;
    _reminderAt = t?.reminderAt;
    _reminderType = t?.reminderType ?? ReminderType.none;
    _priority = t?.priority ?? Priority.medium;
    _tag = t?.tag;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  /// The reminder that will actually be saved: "at a set time" follows the
  /// task's date, "custom" keeps its own date.
  DateTime? get _effectiveReminder {
    final r = _reminderAt;
    if (_reminderType == ReminderType.none || r == null) return null;
    if (_reminderType == ReminderType.atTime) {
      final base = _dueDate ?? DateTime.now();
      return DateTime(base.year, base.month, base.day, r.hour, r.minute);
    }
    return r;
  }

  Future<DateTime?> _pickDate(DateTime? initial) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final init = initial ?? today;
    var first = today.subtract(const Duration(days: 365));
    if (init.isBefore(first)) first = DateTime(init.year, init.month, init.day);
    var last = today.add(const Duration(days: 365 * 2));
    if (init.isAfter(last)) last = DateTime(init.year, init.month, init.day);
    return showDatePicker(
      context: context,
      initialDate: init,
      firstDate: first,
      lastDate: last,
    );
  }

  TimeOfDay _initialReminderTime() {
    final r = _reminderAt;
    if (r != null) return TimeOfDay.fromDateTime(r);
    return context.read<SettingsProvider>().defaultReminderTime;
  }

  Future<void> _chooseDueDate() async {
    final picked = await _pickDate(_dueDate);
    if (picked != null && mounted) setState(() => _dueDate = picked);
  }

  Future<void> _chooseAtTime() async {
    final picked = await showTimePicker(context: context, initialTime: _initialReminderTime());
    if (picked == null || !mounted) return;
    final base = _dueDate ?? DateTime.now();
    setState(() {
      _reminderType = ReminderType.atTime;
      _reminderAt = DateTime(base.year, base.month, base.day, picked.hour, picked.minute);
    });
  }

  Future<void> _chooseCustom() async {
    final date = await _pickDate(_reminderAt ?? _dueDate);
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: _initialReminderTime());
    if (time == null || !mounted) return;
    setState(() {
      _reminderType = ReminderType.custom;
      _reminderAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _clearReminder() {
    setState(() {
      _reminderType = ReminderType.none;
      _reminderAt = null;
    });
  }

  void _save() {
    final original = _original;
    if (original == null) {
      Navigator.of(context).pop();
      return;
    }
    final reminder = _effectiveReminder;
    final title = _titleCtrl.text.trim();

    final updated = original.copyWith(
      title: title.isEmpty ? original.title : title,
      description: _descCtrl.text.trim(),
      dueDate: _dueDate,
      clearDueDate: _dueDate == null,
      reminderAt: reminder,
      clearReminderAt: reminder == null,
      reminderType: reminder == null ? ReminderType.none : _reminderType,
      priority: _priority,
      tag: _tag,
      clearTag: _tag == null,
    );
    context.read<TaskProvider>().updateTask(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_original == null) {
      // The task disappeared before we opened (shouldn't happen) — bail out.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final reminder = _effectiveReminder;
    final reminderInPast = reminder != null && !reminder.isAfter(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขงาน'),
        leading: const BackButton(),
        actions: [
          TextButton(onPressed: _save, child: const Text('บันทึก')),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          TextField(
            controller: _titleCtrl,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.darkText),
            decoration: const InputDecoration(border: InputBorder.none, hintText: 'ชื่องาน'),
          ),
          const _FieldLabel('📝 รายละเอียด'),
          TextField(
            controller: _descCtrl,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'รายละเอียดเพิ่มเติม (ไม่บังคับ)'),
          ),
          const _FieldLabel('📅 วันที่'),
          _TapField(
            text: _dueDate == null ? 'เลือกวันที่' : DateFormat('d MMM y', 'th').format(_dueDate!),
            placeholder: _dueDate == null,
            onTap: _chooseDueDate,
            onClear: _dueDate == null ? null : () => setState(() => _dueDate = null),
          ),
          const _FieldLabel('⏰ เตือนความจำ'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _OptionPill(
                label: 'ไม่ต้องเตือน',
                selected: _reminderType == ReminderType.none,
                onTap: _clearReminder,
              ),
              _OptionPill(
                label: 'เวลาที่กำหนด',
                selected: _reminderType == ReminderType.atTime,
                onTap: _chooseAtTime,
              ),
              _OptionPill(
                label: 'กำหนดวันเวลาเอง',
                selected: _reminderType == ReminderType.custom,
                onTap: _chooseCustom,
              ),
            ],
          ),
          if (reminder != null) ...[
            const SizedBox(height: 10),
            Text(
              'เตือนเวลา ${DateFormat("d MMM · HH:mm", 'th').format(reminder)} น.',
              style: const TextStyle(fontSize: 13, color: AppColors.mutedText),
            ),
            if (reminderInPast)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'เวลานี้ผ่านไปแล้ว จะไม่มีการแจ้งเตือนนะ',
                  style: TextStyle(fontSize: 12.5, color: AppColors.overdue),
                ),
              ),
          ],
          const _FieldLabel('🌊 ความสำคัญ'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: Priority.values.map((p) {
              return _OptionPill(
                label: p.label,
                selected: _priority == p,
                selectedBg: p.bgColor,
                selectedFg: p.fgColor,
                onTap: () => setState(() => _priority = p),
              );
            }).toList(),
          ),
          const _FieldLabel('🏷️ แท็ก'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._tagOptions.map((tag) => _OptionPill(
                    label: '${tagEmoji(tag)} $tag',
                    selected: _tag == tag,
                    // tap the selected tag again to remove it
                    onTap: () => setState(() => _tag = _tag == tag ? null : tag),
                  )),
              // A custom tag typed earlier shows up here, selected.
              if (_tag != null && !_tagOptions.contains(_tag))
                _OptionPill(
                  label: '${tagEmoji(_tag!)} $_tag',
                  selected: true,
                  onTap: () => setState(() => _tag = null),
                ),
              _OptionPill(label: '+ เพิ่มแท็ก', selected: false, onTap: _promptCustomTag),
            ],
          ),
        ],
      ),
    );
  }

  void _promptCustomTag() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('เพิ่มแท็กใหม่'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'ชื่อแท็ก'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              final text = ctrl.text.trim();
              if (text.isNotEmpty) setState(() => _tag = text);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('เพิ่ม'),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.deepOcean),
      ),
    );
  }
}

class _TapField extends StatelessWidget {
  const _TapField({
    required this.text,
    required this.onTap,
    this.placeholder = false,
    this.onClear,
  });

  final String text;
  final VoidCallback onTap;
  final bool placeholder;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 13, 8, 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    color: placeholder ? AppColors.faintText : AppColors.darkText,
                  ),
                ),
              ),
              if (onClear != null)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onClear,
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.close_rounded, size: 18, color: AppColors.mutedText),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.faintText),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionPill extends StatelessWidget {
  const _OptionPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedBg,
    this.selectedFg,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? selectedBg;
  final Color? selectedFg;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? (selectedBg ?? AppColors.seafoam) : Colors.white;
    final fg = selected ? (selectedFg ?? AppColors.deepOcean) : AppColors.mutedText;
    final borderColor = selected ? (selectedFg ?? AppColors.turquoise) : AppColors.cardBorder;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: fg),
        ),
      ),
    );
  }
}
