import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/shift_assignment.dart';
import '../services/shift_service.dart';
import 'package:intl/intl.dart';

class HomeNursePage extends StatefulWidget {
  const HomeNursePage({super.key});

  @override
  State<HomeNursePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomeNursePage> {
  String name = '';
  late Future<List<ShiftAssignment>> futureShifts;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    futureShifts = ShiftService.fetchMySchedule();
    _selectedDay = _focusedDay;
    loadUserName();
  }

  Future<void> loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
    });
  }

  Future<void> _showLeaveRequestDialog(
    BuildContext context,
    ShiftAssignment shift,
  ) async {
    final TextEditingController reasonController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('คำขอลาหยุด'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ต้องการส่งคำขอลาหยุดสำหรับเวรนี้หรือไม่?'),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'วันที่: ${DateFormat('yyyy-MM-dd').format(shift.date)}\nเวลา: ${shift.startTime} - ${shift.endTime}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'เหตุผล',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('ยกเลิก'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('ยืนยัน'),
              ),
            ],
          ),
    );

    if (result == true) {
      await _submitLeaveRequest(context, shift, reasonController.text);
    }
  }

  Future<void> _submitLeaveRequest(
    BuildContext context,
    ShiftAssignment shift,
    String reason,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('userId');

    if (token == null || userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ไม่พบ token หรือ userId')));
      return;
    }

    final errorMessage = await ShiftService.submitLeaveRequest(
      userId: userId,
      token: token,
      shiftAssignmentId: shift.shift_assignment_id,
      reason: reason,
    );

    if (errorMessage == null) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('สำเร็จ'),
              content: const Text('ส่งคำขอลาหยุดสำเร็จ'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('ตกลง'),
                ),
              ],
            ),
      );
    } else if (errorMessage.contains('already exists')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'คุณได้ส่งคำขอลาหยุดสำหรับเวรนี้ไปแล้ว กำลังรอการอนุมัติ',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, $name"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          SizedBox(
            // height: 200,
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<ShiftAssignment>>(
              future: futureShifts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No schedule found."));
                }

                final shifts = snapshot.data!;
                final now = DateTime.now();
                final weekShifts =
                    shifts
                        .where(
                          (shift) =>
                              shift.date.isAfter(
                                now.subtract(const Duration(days: 1)),
                              ) &&
                              shift.date.isBefore(
                                now.add(const Duration(days: 7)),
                              ),
                        )
                        .toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: weekShifts.length,
                  itemBuilder: (context, index) {
                    final shift = weekShifts[index];
                    final formattedDate = DateFormat(
                      'EEE, MMM d',
                    ).format(shift.date);

                    Color dayColor;
                    switch (shift.date.weekday) {
                      case DateTime.monday:
                        dayColor = Colors.blue;
                        break;
                      case DateTime.tuesday:
                        dayColor = Colors.green;
                        break;
                      case DateTime.wednesday:
                        dayColor = Colors.orange;
                        break;
                      case DateTime.thursday:
                        dayColor = Colors.purple;
                        break;
                      case DateTime.friday:
                        dayColor = Colors.red;
                        break;
                      case DateTime.saturday:
                        dayColor = Colors.teal;
                        break;
                      case DateTime.sunday:
                        dayColor = Colors.pink;
                        break;
                      default:
                        dayColor = Colors.grey;
                    }

                    return Card(
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _showLeaveRequestDialog(context, shift),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 60,
                              decoration: BoxDecoration(
                                color: dayColor,
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(8),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  "$formattedDate: ${shift.startTime} - ${shift.endTime}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}
