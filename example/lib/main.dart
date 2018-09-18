import 'package:flutter/material.dart';

import 'package:flutter_page_indicator/flutter_page_indicator.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class RadioGroup extends StatefulWidget {
  final List<String> titles;

  final ValueChanged<int> onIndexChanged;

  const RadioGroup({Key key, this.titles, this.onIndexChanged})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _RadioGroupState();
  }
}

class _RadioGroupState extends State<RadioGroup> {
  int _index = 1;

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    for (int i = 0; i < widget.titles.length; ++i) {
      list.add(((String title, int index) {
        return new Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Radio<int>(
                value: index,
                groupValue: _index,
                onChanged: (int index) {
                  setState(() {
                    _index = index;
                    widget.onIndexChanged(_index);
                  });
                }),
            new Text(title)
          ],
        );
      })(widget.titles[i], i));
    }

    return new Wrap(
      children: list,
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _index = 1;

  PageController controller;

  PageIndicatorLayout layout = PageIndicatorLayout.slide;

  List<PageIndicatorLayout> layouts = PageIndicatorLayout.values;

  @override
  void initState() {
    controller = new PageController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: new Column(
          children: <Widget>[
            new RadioGroup(
              titles: layouts.map((s) {
                var str = s.toString();
                return str.substring(str.indexOf(".") + 1);
              }).toList(),
              onIndexChanged: (int index) {
                setState(() {
                  _index = index;
                  layout = layouts[index];
                });
              },
            ),
            new Expanded(
                child: new Stack(
              children: <Widget>[
                new PageView(
                  controller: controller,
                  children: <Widget>[
                    new Container(
                      color: Colors.red,
                    ),
                    new Container(
                      color: Colors.green,
                    ),
                    new Container(
                      color: Colors.blueAccent,
                    ),
                    new Container(
                      color: Colors.grey,
                    )
                  ],
                ),
                new Align(
                  alignment: Alignment.bottomCenter,
                  child: new Padding(
                    padding: new EdgeInsets.only(bottom: 20.0),
                    child: new PageIndicator(
                      layout: layout,
                      size: 20.0,
                      controller: controller,
                      space: 5.0,
                      count: 4,
                    ),
                  ),
                )
              ],
            ))
          ],
        ));
  }
}
