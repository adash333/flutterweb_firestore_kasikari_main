import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart';
import 'package:firebase/firestore.dart' as fs;
import 'dart:async';

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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        settings: const RouteSettings(name: "/edit"),
                                        builder: (BuildContext context) =>
                                          MyInputForm(document)
                                      ),
                                    );
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
          Navigator.push(
            context,
            MaterialPageRoute(
              settings: const RouteSettings(name: "/new"),
              // builder: (BuildContext context) => MyInputForm()
              builder: (BuildContext context) => MyInputForm(null)
            ),
          );
        },
      ),
    );
  }
}

class MyInputForm extends StatefulWidget {
  // MyInputFormに引数を追加
  MyInputForm(this.document);
  final fs.DocumentSnapshot document;

  @override
  _MyInputFormState createState() => new _MyInputFormState();
}

class _FormData {
  String borrowOrLend = "borrow";
  String user;
  String stuff;
  DateTime date = DateTime.now();
}

class _MyInputFormState extends State<MyInputForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _FormData _data = _FormData();

  Future <DateTime> _selectTime(BuildContext context) {
    return showDatePicker(
      context: context,
      initialDate: _data.date,
      firstDate: DateTime(_data.date.year - 2),
      lastDate: DateTime(_data.date.year + 2),
    );
  }

  void _setLendOrRent(String value) {
    setState(() {
      _data.borrowOrLend = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    fs.DocumentReference _mainReference = firestore().collection('kasikarimemo').doc();
    // 編集データの作成
    if (widget.document != null) { // 引数で渡したデータがあるかどうか
      if(_data.user == null && _data.stuff == null) {
        _data.borrowOrLend = widget.document.get('borrowOrLend');
        _data.user = widget.document.get('user');
        _data.stuff = widget.document.get('stuff');
        _data.date = widget.document.get('date');
      } else {
        _mainReference = firestore().collection('kasikarimemo').doc(widget.document.id);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('かしかり入力'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              print("保存ボタンを押しました");
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                _mainReference.set(
                  {
                    'borrowOrLend': _data.borrowOrLend,
                    'user': _data.user,
                    'stuff': _data.stuff,
                    'date': _data.date
                  }
                );
                Navigator.pop(context);
              }
            }
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              print("削除ボタンを押しました");
            },
          ),
        ],
      ),
      body: SafeArea(
        child:
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: <Widget>[
                RadioListTile(
                  value: "borrow",
                  groupValue: _data.borrowOrLend,
                  title: Text("借りた"),
                  onChanged: (String value) {
                    print("借りたをタッチしました");
                    _setLendOrRent(value);
                  },
                ),
                RadioListTile(
                  value: "lend",
                  groupValue: _data.borrowOrLend,
                  title: Text("貸した"),
                  onChanged: (String value) {
                    print("貸したをタッチしました");
                    _setLendOrRent(value);
                  },
                ),

                TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.person),
                    hintText: '相手の名前',
                    labelText: 'Name',
                  ),
                  onSaved: (String value) {
                    _data.user = value;
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return '名前は必須入力項目です';
                    }
                  },
                  initialValue: _data.user,
                ),

                TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.business_center),
                    hintText: '借りたもの、貸したもの',
                    labelText: 'loan',
                  ),
                  onSaved: (String value) {
                    _data.stuff = value;
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return '借りたもの、貸したものは必須入力項目です';
                    }
                  },
                  initialValue: _data.stuff,
                ),

                Padding(
                  padding: const EdgeInsets.only(top:8.0),
                  child: Text("締切日：${_data.date.toString().substring(0,10)}"),
                ),

                RaisedButton(
                  child: const Text("締切日変更"),
                  onPressed: () {
                    print("締切日変更をタップしました");
                    _selectTime(context).then((time){
                      if (time != null && time != _data.date) {
                        setState( () {
                          _data.date = time;
                        });
                      }
                    });
                  },
                ),
              ],
            ),
          )
      )
    );
  }
}
