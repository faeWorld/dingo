import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class HistoryStatus extends StatefulWidget {
  const HistoryStatus({super.key});

  @override
  _HistoryStatusState createState() => _HistoryStatusState();
}

class _HistoryStatusState extends State<HistoryStatus> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  DateTime _reminderDate = DateTime.now(); // Store selected reminder date
  final Map<DateTime, List<String>> _events =
      {}; // Map to store events for each date
  final Map<DateTime, List<String>> _diagnosisRecords =
      {}; // Store diagnosis records
  final Map<DateTime, String?> _activityNotes =
      {}; // Store activity notes for each date

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  Future<void> _selectReminderDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _reminderDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null && pickedDate != _reminderDate) {
      setState(() {
        _reminderDate = pickedDate; // Update the selected reminder date
      });
    }
  }

  void _showReminderPopup(DateTime selectedDay) {
    // Show a popup to add a reminder
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String diseaseName = '';
        String bodyPart = '';
        String dermatologistName = '';
        String recommendedTreatment = '';
        String clinicAddress = '';
        int? duration;

        return AlertDialog(
          title: Text('Add Reminder'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    diseaseName = value;
                  },
                  decoration: InputDecoration(labelText: 'Disease Name'),
                ),
                DropdownButton<String>(
                  hint: Text('Disease Type'),
                  items: <String>['Benign', 'Malignant']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {},
                ),
                TextField(
                  onChanged: (value) {
                    bodyPart = value;
                  },
                  decoration: InputDecoration(labelText: 'Body Part'),
                ),
                DropdownButton<int>(
                  hint: Text('Duration (days)'),
                  items: List.generate(30, (index) => index + 1)
                      .map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    duration = newValue;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    _selectReminderDate(context); // Call the date picker
                  },
                  child: Text('Select Reminder Date'),
                ),
                Text('Selected Date: ${_reminderDate.toLocal()}'
                    .split(' ')[0]), // Display the selected date
                TextField(
                  onChanged: (value) {
                    dermatologistName = value;
                  },
                  decoration: InputDecoration(labelText: 'Dermatologist Name'),
                ),
                TextField(
                  onChanged: (value) {
                    recommendedTreatment = value;
                  },
                  decoration:
                      InputDecoration(labelText: 'Recommended Treatment'),
                ),
                TextField(
                  onChanged: (value) {
                    clinicAddress = value;
                  },
                  decoration:
                      InputDecoration(labelText: 'Clinic Address or URL'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Logic to save the reminder
                if (_events[selectedDay] == null) {
                  _events[selectedDay] = [];
                }
                _events[selectedDay]!
                    .add(diseaseName); // Save disease name as event
                setState(() {}); // Refresh the calendar to show the new event
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showActivityNoteDialog(DateTime selectedDay) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Activity Note'),
          content: Text(_activityNotes[selectedDay] ??
              'No activity recorded for this date.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 221, 226, 255),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 173, 173, 173),
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: TableCalendar(
          focusedDay: _focusedDay,
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          eventLoader: (day) => _events[day] ?? [],
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, date, events) {
              bool hasEvent = _events[date]?.isNotEmpty ?? false;
              bool hasDiagnosis = _diagnosisRecords[date]?.isNotEmpty ?? false;

              return GestureDetector(
                onTap: () {
                  _showActivityNoteDialog(
                      date); // Show activity note on single tap
                },
                onDoubleTap: () {
                  _showReminderPopup(date); // Show reminder popup on double tap
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: hasEvent
                        ? const Color.fromARGB(255, 137, 59, 255)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: hasDiagnosis
                        ? Border.all(color: Colors.blue, width: 2)
                        : null, // Underline marked days
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(
                        fontFamily: 'Frista',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          headerStyle: const HeaderStyle(
            titleTextStyle: TextStyle(
              fontFamily: 'Frista',
              fontSize: 20,
              color: Colors.black,
            ),
            formatButtonVisible: false,
            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              fontFamily: 'Frista',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            weekendStyle: TextStyle(
              fontFamily: 'Frista',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
