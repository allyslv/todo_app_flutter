import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'ToDoListPage.dart';
import 'package:firebase_database/firebase_database.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DatabaseReference database = FirebaseDatabase.instance.ref();
  Set<DateTime> diasComTarefas = {};
  late CalendarFormat _calendarController;
  DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    buscarDiasComTarefas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCBF49),
      appBar: AppBar(
        backgroundColor: Color(0xFF003049),
        title: Text(
          'Calendário',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
        elevation: 0,
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFE5E5E5),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              TableCalendar(
                calendarFormat: CalendarFormat.month,
                focusedDay: _focusedDay,
                firstDay: DateTime(2000),
                lastDay: DateTime(2050),
                selectedDayPredicate: (day) => isSameDay(_focusedDay, day),
                onFormatChanged: (format) {
                  setState(() {
                  });
                },
                onDaySelected: (selectedDay, focusedDay) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ToDoListPage(selectedDate: selectedDay),
                    ),
                  );
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Color(0xFF003049),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF003049),
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (diasComTarefas.any((d) => isSameDay(d, date))) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Color(0xFFD62828),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Text(
                  'Selecione um dia para adicionar tarefas',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void buscarDiasComTarefas() {
    database.child('calendar').once().then((DatabaseEvent event) {
      final data = event.snapshot.value;

      if (data != null && data is Map) {
        Set<DateTime> dias = {};

        data.forEach((dateString, value) {
          if (dateString.length == 8) {
            try {
              final dia = int.parse(dateString.substring(0, 2));
              final mes = int.parse(dateString.substring(2, 4));
              final ano = int.parse(dateString.substring(4, 8));
              dias.add(DateTime(ano, mes, dia));
            } catch (e) {
              print('Data inválida: $dateString');
            }
          }
        });

        setState(() {
          diasComTarefas = dias;
        });
      }
    });
  }
}
