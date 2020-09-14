import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        accentColor: Colors.orange),
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String input = "";

  createTodos() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('MyTasks').doc(input);
    Map<String, String> todos = {input: 'todoTitle '};
    documentReference.set(todos).whenComplete(() {
      print('$input created');
    });
  }

  deleteTodos(item) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('MyTasks').doc(item);

    documentReference.delete().whenComplete(() {
      print('$item deleted');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('My Tasks'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    title: Text('Add TodoList'),
                    content: TextField(
                      onChanged: (String value) {
                        input = value;
                      },
                    ),
                    actions: [
                      FlatButton(
                        child: Text('Add'),
                        onPressed: () {
                          createTodos();
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                });
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        body: StreamBuilder(
          builder: (context, snapshot) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  onDismissed: (direction) {
                    deleteTodos(snapshot.data.documents[index].data()['todoTitle']);
                  },
                  key: Key(snapshot.data.documents[index].data()['todoTitle']),
                  child: Card(
                    elevation: 4,
                    margin: EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      trailing: IconButton(
                          onPressed: () {
                            deleteTodos(
                                snapshot.data.documents[index].data()['todoTitle']);
                          },
                          icon: Icon(Icons.delete)),
                      title:
                          Text(snapshot.data.documents[index].data()['todoTitle']),
                    ),
                  ),
                );
              },
            );
          },
          stream: FirebaseFirestore.instance.collection('MyTasks').snapshots(),
        ));
  }
}
