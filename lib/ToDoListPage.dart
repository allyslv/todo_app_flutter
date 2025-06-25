import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:convert';

class ToDoListPage extends StatefulWidget {
  final DateTime selectedDate;

  ToDoListPage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  DatabaseReference database = FirebaseDatabase.instance.ref();
  StreamSubscription<DatabaseEvent>? _taskSubscription;

  List<Task> tasks = [];

  String get stringDate {
    final d = widget.selectedDate;
    return '${d.day}${d.month <= 9 ? '0${d.month}' : d.month}${d.year}';
  }

  @override
  void initState() {
    super.initState();
    getTasks(stringDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCBF49),
      appBar: AppBar(
        backgroundColor: Color(0xFFF77F00),
        title: Text(
          'Lista de Tarefas - ${widget.selectedDate.day.toString().padLeft(2, '0')}/${widget.selectedDate.month.toString().padLeft(2, '0')}/${widget.selectedDate.year}',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFEAE2B7),
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
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final isEven = index % 2 == 0;
                    return Container(
                      decoration: BoxDecoration(
                        color: isEven ? Color(0xFFFAFAFA) : Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        title: Text(
                          task.name,
                          style: TextStyle(
                            fontSize: 16,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        leading: Icon(
                          task.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: task.isCompleted ? Colors.green : Colors.red,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: Color(0xFF003049)),
                              onPressed: () {
                                _toggleTaskCompletion(index, stringDate);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                _removeTask(index, stringDate);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF003049),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _showAddTaskDialog(context);
                    },
                    child: Text('Adicionar Tarefa'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD62828),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _showRemoveAllTasksDialog(context);
                    },
                    child: Text('Remover Todas'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showAddTaskDialog(BuildContext context) {
    final _controller = TextEditingController();
    String _errorText = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              title: Text('Adicionar Tarefa'),
              content: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Nome da Tarefa',
                  errorText: _errorText.isNotEmpty ? _errorText : null,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      Navigator.pop(context);
                      setState(() {
                        tasks.add(Task(name: _controller.text));
                        final ref = database
                            .child('calendar/$stringDate')
                            .push();
                        final newId = ref.key!;
                        final lastTask = tasks[tasks.length - 1];
                        lastTask.setIdFirebase(newId);

                        ref.set(lastTask.toJson());
                      });
                    } else {
                      setModalState(() {
                        _errorText = 'O campo nome não pode estar vazio!';
                      });
                    }

                    // Navigator.pop(context);
                  },
                  child: Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRemoveAllTasksDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remover Todas as Tarefas'),
          content: Text('Tem certeza que deseja remover todas as tarefas?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  tasks.clear();
                  database.child('calendar/$stringDate').remove();
                });
                Navigator.pop(context);
              },
              child: Text('Remover Todas'),
            ),
          ],
        );
      },
    );
  }

  void _toggleTaskCompletion(int index, String date) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
      updateTask(date, tasks[index]);
    });
  }

  void _removeTask(int index, String date) {
    setState(() {
      database.child('calendar/$date/${tasks[index].idFirebase}').remove();
      tasks.removeAt(index);
    });
  }

  void getTasks(String date) {
    _taskSubscription?.cancel();

    _taskSubscription = database
        .child('calendar/$date')
        .orderByChild('isCompleted')
        .onValue
        .listen((DatabaseEvent event) {
      final data = event.snapshot.value;

      if (data != null && data is Map) {
        List<Task> loadedTasks = [];

        data.forEach((key, value) {
          final taskMap = Map<String, dynamic>.from(value);
          final task = Task(
            name: taskMap['name'],
            isCompleted: taskMap['isCompleted'] ?? false,
          );
          task.setIdFirebase(taskMap['id'] ?? key);
          loadedTasks.add(task);
        });

        loadedTasks.sort((a, b) {
          if (a.isCompleted == b.isCompleted) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          }
          return a.isCompleted ? 1 : -1;
        });

        setState(() {
          tasks = loadedTasks;
        });
      } else {
        setState(() {
          tasks = [];
        });
      }
    });
  }

  void updateTask(String date, Task task) {
    database.child('calendar/$date/${task.idFirebase}').update({
      'name': task.name,
      'isCompleted': task.isCompleted,
    });
  }
}

class Task {
  String name;
  bool isCompleted;
  String? idFirebase;

  Task({required this.name, this.isCompleted = false, this.idFirebase});

  void setIdFirebase(String id) {
    idFirebase = id;
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'isCompleted': isCompleted, 'id': idFirebase};
  }
}
