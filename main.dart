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
      home: MyHomePage(title: 'リスト表示'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final fs.Firestore store = firestore();
  final List<Map<String, dynamic>> messages = List();
  final List<Map<String, dynamic>> kasikarimemo = List();

  fetchMessages() async {
    var messagesRef = await store.collection('messages').get();
    var memosRef = await store.collection('kasikarimemo').get();

    messagesRef.forEach(
      (doc) {
        messages.add(doc.data());
      },
    );

    memosRef.forEach(
      (doc) {
        kasikarimemo.add(doc.data());
      },
    );

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print("新規ボタンを押しました");
          var m = Map<String, String>();
          m['content'] = 'hogehoge';
          await store.collection('messages').add(m);
          setState(() {
            messages.add(m);
          });
        },
        child: Icon(Icons.add),
      ),
      
      body: ListView(
        children: kasikarimemo.map(
          (message) {
            return Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[ 
                  ListTile(
                    leading: FlutterLogo(size: 72.0),
                    // title: Text(message['borrowOrLend']),
                    title: Text("【 " + (message['borrowOrLend'] == "lend"?"貸": "借") +" 】"+ message['stuff']),
                    // subtitle: Text(message['stuff']),
                    subtitle: Text('期限 ： ' + message['date'].toString().substring(0,10) + "\n相手 ： " + message['user']),
                    // isThreeLine: true,
                  ),
                  ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child: const Text('編集'),
                    onPressed: () {
                      print("編集ボタンを押しました");
                    },
                  ),
                ],
              )
                ]
              )
            );
          },
        ).toList(),
      )
      
    );
  }
}
