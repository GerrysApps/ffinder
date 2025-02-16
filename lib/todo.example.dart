// dart async library you will refer to when setting up real time updates
import 'dart:async';
 
// flutter and ui libraries
import 'package:flutter/material.dart';
 
// amplify packages you will need to use
//import 'package:amplify_flutter/amplify_flutter.dart';
//import 'package:amplify_datastore/amplify_datastore.dart';
 
// amplify configuration and models that should have been generated for you
//import 'amplifyconfiguration.dart';
//import 'models/ModelProvider.dart';
//import 'models/Todo.dart';
 
void main() {
  runApp(const MyApp());
}
 
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
 
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Amplified Todo',
      home: TodosPage(),
    );
  }
}
 
class TodosPage extends StatefulWidget {
  const TodosPage({Key? key}) : super(key: key);
 
  @override
  State<TodosPage> createState() => _TodosPageState();
}
 
class _TodosPageState extends State<TodosPage> {
  @override
  void initState() {
    // to be filled in a later step
    super.initState();
  }
 
  @override
  void dispose() {
    super.dispose();
    // to be filled in a later step
  }
 
  //Future<void> _initializeApp() async {
    // to be filled in a later step
  //}
 
  //Future<void> _configureAmplify() async {
    // to be filled in a later step
  //}
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todo List'),
      ),
      body: const Center(child: CircularProgressIndicator()),
      // body: _isLoading
      //     ? Center(child: CircularProgressIndicator())
      //     : TodosList(todos: _todos),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTodoForm()),
          );
        },
        tooltip: 'Add Todo',
        label: const Row(
          children: [Icon(Icons.add), Text('Add todo')],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
 
class TodosList extends StatelessWidget {
  const TodosList({
    required this.todos,
    Key? key,
  }) : super(key: key);
 
  final List<Object> todos;
  //final List<Todo> todos;
 
  @override
  Widget build(BuildContext context) {
    return todos.isNotEmpty
        ? ListView(
            padding: const EdgeInsets.all(8),
            children: todos.map((todo) => TodoItem(todo: todo)).toList())
        : const Center(
            child: Text('Tap button below to add a todo!'),
          );
  }
}
 
class TodoItem extends StatelessWidget {
  const TodoItem({
    required this.todo,
    Key? key,
  }) : super(key: key);
 
  final double iconSize = 24.0;

  final Object todo;
  //final Todo todo;
 
  void _deleteTodo(BuildContext context) async {
    // to be filled in a later step
  }
 
  Future<void> _toggleIsComplete() async {
    // to be filled in a later step
  }
 
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          _toggleIsComplete();
        },
        onLongPress: () {
          _deleteTodo(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  // ignore: prefer_const_constructors
                  Text(
                    'todo', // todo.name,
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  // Text(todo.description ?? 'No description'),
                  Text('description No description'),
                ],
              ),
            ),
            Icon(
                // todo.isComplete
                // true ? Icons.check_box : Icons.check_box_outline_blank,
                Icons.check_box, 
                size: iconSize),
          ]),
        ),
      ),
    );
  }
}
 
class AddTodoForm extends StatefulWidget {
  const AddTodoForm({Key? key}) : super(key: key);
 
  @override
  State<AddTodoForm> createState() => _AddTodoFormState();
}
 
class _AddTodoFormState extends State<AddTodoForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
 
  @override
  void initState() {
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    super.initState();
  }
 
  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
  }
 
  Future<void> _saveTodo() async {
    // to be filled in a later step
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Todo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration:
                    const InputDecoration(filled: true, labelText: 'Name'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                    filled: true, labelText: 'Description'),
              ),
              ElevatedButton(
                onPressed: _saveTodo,
                child: const Text('Save'),
              )
            ],
          ),
        ),
      ),
    );
  }
}