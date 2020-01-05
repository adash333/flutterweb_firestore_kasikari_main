import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart';
import 'package:firebase/firestore.dart' as fs;

// initializeApp()の中身は、ご自身の設定に書き換えてください。
void main() {
  initializeApp(
    apiKey: "YourApiKey",
    authDomain: "YourAuthDomain",
    databaseURL: "YourDatabaseUrl",
    projectId: "YourProjectId",
    storageBucket: "YourStorageBucket");
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firestore memo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyList(),
    );
  }
}

class MyList extends StatefulWidget {
  @override
  _MyListState createState() => new _MyListState();
}

class _MyListState extends State<MyList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("リスト画面"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<fs.QuerySnapshot> (
          stream: firestore().collection('kasikarimemo').onSnapshot,
          builder: (BuildContext context, AsyncSnapshot<fs.QuerySnapshot> snapshot) {
            if (!snapshot.hasError) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Text('Loading...');
                default:
                  return ListView(
                    children: snapshot.data.docs.map((fs.DocumentSnapshot document) {
                      return Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[ 
                            ListTile(
                              leading: FlutterLogo(size: 72.0),
                              title: Text("【 " + (document.get('borrowOrLend') == "lend"?"貸": "借") +" 】"+ document.get('stuff')),
                              subtitle: Text('期限 ： ' + document.get('date').toString().substring(0,10) + "\n相手 ： " + document.get('user')),
                            ),
                            ButtonBar(
                              children: <Widget>[
                                FlatButton(
                                  child: const Text('編集'),
                                  onPressed: () {
                                    print("編集ボタンを押しました");
                                  },
                                ),
                              ]
                            )
                          ]
                        )
                      );
                    }
                    ).toList(),
                  );
              }
            } else {
              return Text('Error: ${snapshot.error}');
            }
          }
        ), 
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          print("新規作成ボタンを押しました");
        },
      ),
    );
  }
}
