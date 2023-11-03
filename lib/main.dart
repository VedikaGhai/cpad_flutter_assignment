import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

void main() async{
  final keyApplicationId = 'YOUR_APPLICATION_KEY_HERE';
  final keyClientKey = 'YOUR_CLIENT_KEY_HERE';
  final keyParseServerUrl = 'https://parseapi.back4app.com';
  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);
  //final objectId = await saveTask().toString();
  //final task = await getTasks();
  //print('Task: ${task.toString()}');
  //print('Title: ${task['title']}');
  //print('Description: ${task['description']}');
  runApp(const TodoApp());
}

Future<String?> saveTask(String title, String description, bool completed) async {
  final task = ParseObject('Task')
    ..set('title', title)
    ..set('description', description)
    ..set('completed', false);
  await task.save();
  return task.objectId;
}

Future<List<ParseObject>> getTasks() async {
  QueryBuilder<ParseObject> queryTask =
  QueryBuilder<ParseObject>(ParseObject('Task'));
  final ParseResponse apiResponse = await queryTask.query();
  if (apiResponse.success && apiResponse.results != null) {
    // final title = apiResponse.results?.first.get<String>('title');
    // final description = apiResponse.results?.first.get<String>('description');
    // bool completed = apiResponse.results?.first.get<bool>('completed');
    // return apiResponse as Future<List<Todo>>;
    return apiResponse.results as List<ParseObject>;
  } else {
    return [];
  }
}

Future<void> updateTodo(String id, bool done) async {
  var todo = ParseObject('Task')
    ..objectId = id
    ..set('completed', done);
  await todo.save();
}

Future<void> deleteTodo(String id) async {
  var todo = ParseObject('Task')..objectId = id;
  await todo.delete();
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const TodoList(title: 'To-Do Manager', description: ''),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({super.key, required this.title, required this.description});
  final String title;
  final String description;

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final TextEditingController _textFieldController = TextEditingController();
  final TextEditingController _textDescController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _addTodoItem(String title, String description) {
    setState(() {
      saveTask(title, description, false);
    });
    _textFieldController.clear();
    _textDescController.clear();
  }

  Future<void> _displayDialog() async {
    return showDialog<void>(
      context: context,
      //T: false,
      builder: (BuildContext context) {
        var width = MediaQuery.of(context).size.width;
        var height = MediaQuery.of(context).size.height;
        return AlertDialog(
          title: const Text(
            'Add a todo',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.brown),
          ),
          content: SizedBox(
            height: height * 0.35,
            width: width,
            child: Form(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    style: const TextStyle(fontSize: 14),
                    controller: _textFieldController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      hintText: 'Type your todo',
                      hintStyle: const TextStyle(fontSize: 14),
                      //icon: const Icon(CupertinoIcons.square_list, color: Colors.brown),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    style: const TextStyle(fontSize: 14),
                    controller: _textDescController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      hintText: 'Description',
                      hintStyle: const TextStyle(fontSize: 14),
                      //icon: const Icon(CupertinoIcons.bubble_left_bubble_right, color: Colors.brown),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _addTodoItem(_textFieldController.text, _textDescController.text);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _displayDetailsListView(String title, String description) async {
    return showDialog<void>(
      context: context,
      //T: false,
      builder: (BuildContext context) {
        var width = MediaQuery.of(context).size.width;
        var height = MediaQuery.of(context).size.height;
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: <Widget>[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      // body: ListView(
      //   padding: const EdgeInsets.symmetric(vertical: 8.0),
      //   children: _todos.map((Todo todo) {
      //     return TodoItem(
      //       todo: todo,
      //     );
      //   }).toList(),
      // ),
      body: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
              child: Row(
                children: <Widget>[],
              )),
          Expanded(
              child: FutureBuilder<List<ParseObject>>(
                  future: getTasks(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: Container(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator()),
                        );
                      default:
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error..."),
                          );
                        }
                        if (!snapshot.hasData) {
                          return Center(
                            child: Text("No Data..."),
                          );
                        } else {
                          return ListView.builder(
                              padding: EdgeInsets.only(top: 10.0),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                //*************************************
                                //Get Parse Object Values
                                final varTodo = snapshot.data![index];
                                final varTitle = varTodo.get<String>('title')!;
                                final varDesc =  varTodo.get<String>('description')!;
                                final varCompleted = varTodo.get<bool>('completed')!;
                                //*************************************

                                return ListTile(
                                  title: Text(varTitle),
                                  subtitle: Text(varDesc),
                                  leading: CircleAvatar(
                                    child: Icon(
                                        varCompleted ? Icons.check : Icons.error),
                                    backgroundColor:
                                    varCompleted ? Colors.green : Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                          value: varCompleted,
                                          onChanged: (value) async {
                                            await updateTodo(
                                                varTodo.objectId!, value!);
                                            setState(() {
                                              //Refresh UI
                                            });
                                          }),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () async {
                                          await deleteTodo(varTodo.objectId!);
                                          setState(() {
                                            final snackBar = SnackBar(
                                              content: Text("Todo deleted!"),
                                              duration: Duration(seconds: 2),
                                            );
                                            ScaffoldMessenger.of(context)
                                              ..removeCurrentSnackBar()
                                              ..showSnackBar(snackBar);
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                  onTap: (){
                                    _displayDetailsListView(varTitle, varDesc);
                                  }
                                );
                              });
                        }
                    }
                  }))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayDialog(),
        tooltip: 'New To-do',
        child: const Icon(Icons.add),
      ), 
    );
  }
}

class Todo {
  Todo({required this.title, required this.description, required this.completed});
  String title;
  String description;
  bool completed;
}

class TodoItem extends StatelessWidget {
  TodoItem({required this.todo}) : super(key: ObjectKey(todo));

  final Todo todo;

  TextStyle? _getTextStyle(bool checked) {
    if (!checked) return null;

    return const TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      leading: Checkbox(
        checkColor: Colors.greenAccent,
        activeColor: Colors.red,
        value: todo.completed,
        onChanged: (value) {},
      ),
      title: Row(children: <Widget>[
        Expanded(
          child: Text(todo.title, style: _getTextStyle(todo.completed)),
        ),
        IconButton(
          iconSize: 30,
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          alignment: Alignment.centerRight,
          onPressed: () {},
        ),
      ]),
    );
  }
}
