import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterLocalNotificationsPlugin _notifyPlugin =
      FlutterLocalNotificationsPlugin();
  static const _chanelName = "me.liucx.demoNotification"; //channel name

  void _notifyInit() {
    final InitializationSettings initSetting = InitializationSettings(
        android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
            onDidReceiveLocalNotification: _notifyReceiveIos));
    _notifyPlugin.initialize(initSetting,
        onDidReceiveNotificationResponse: _notifyReceiveAndroid);
  }

  Future<void> _notifyShow(
      int id, String title, String content, String payload) async {
    // const chanel = "me.liucx.demoNotification"; //channel name
    await _notifyPlugin.show(
        id,
        title,
        content,
        const NotificationDetails(
            android: AndroidNotificationDetails(_chanelName, _chanelName),
            iOS: DarwinNotificationDetails(
              threadIdentifier: _chanelName,
            )),
        payload: payload);
  }

  Future<void> _notifyShowSchedule(int id, String title, String content,
      String payload, Duration setTime) async {
    tz.initializeTimeZones();
    await _notifyPlugin.zonedSchedule(
        id,
        title,
        content,
        tz.TZDateTime.now(tz.local).add(setTime),
        const NotificationDetails(
            android: AndroidNotificationDetails(_chanelName, _chanelName),
            iOS: DarwinNotificationDetails(threadIdentifier: _chanelName)),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload);
  }

  void _notifyReceiveAndroid(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      _notifyReceiveAction(payload);
    }
  }

  void _notifyReceiveIos(
      int id, String? title, String? body, String? payload) async {
    if (payload != null) {
      _notifyReceiveAction(payload);
    }
  }

  void _notifyReceiveAction(String payload) async {
    print("payload: $payload");
    showDialog(
        context: context,
        builder: (buildContext) {
          return SimpleDialog(
            title: const Text("Playload"),
            contentPadding: EdgeInsets.all(15),
            children: [
              Text(
                payload,
                style: const TextStyle(fontSize: 20),
              ),
              FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Close"))
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _notifyInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _uiHeader(),
      body: _uiBody(),
    );
  }

  AppBar _uiHeader() {
    return AppBar(
      backgroundColor: Colors.blue,
      title: const Text("Notification - Demo"),
    );
  }

  Widget _uiBody() {
    final ctrlId = TextEditingController();
    final ctrlTitle = TextEditingController();
    final ctrlContent = TextEditingController();
    final ctrlPayload = TextEditingController();
    ctrlId.text = "1000";
    ctrlTitle.text = "title.";
    ctrlContent.text = "Content.";
    ctrlPayload.text = "{\"username\":\"abcd\",\"passwd\":\"123456\"}";
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          TextField(
            controller: ctrlId,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, //数字，只能是整数
              LengthLimitingTextInputFormatter(15), //限制长度
            ],
            decoration: const InputDecoration(
                hintText: "Input Number~", labelText: "ID"),
          ),
          TextField(
            controller: ctrlTitle,
            decoration: const InputDecoration(
                hintText: "Input something~", labelText: "Title"),
          ),
          TextField(
            controller: ctrlContent,
            decoration: const InputDecoration(
                hintText: "Input something~", labelText: "Content"),
          ),
          TextField(
            controller: ctrlPayload,
            decoration: const InputDecoration(
                hintText: "{\"username\":\"abcd\",\"passwd\":\"123456\"}",
                labelText: "Payload"),
          ),
          FilledButton(
              onPressed: () {
                _notifyShow(int.parse(ctrlId.text), ctrlTitle.text,
                    ctrlContent.text, ctrlPayload.text);
              },
              child: Container(
                alignment: Alignment.center,
                width: double.maxFinite,
                child: const Text("Action!"),
              )),
          FilledButton(
              onPressed: () {
                _notifyShowSchedule(
                    int.parse(ctrlId.text),
                    ctrlTitle.text,
                    ctrlContent.text,
                    ctrlPayload.text,
                    const Duration(seconds: 3));
              },
              child: Container(
                alignment: Alignment.center,
                width: double.maxFinite,
                child: const Text("Delay 3 Second!"),
              ))
        ],
      ),
    );
  }
}
