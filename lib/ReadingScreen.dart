import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sample_project/SerialPortSingleton.dart';
import 'package:serial_port_win32/serial_port_win32.dart';
import 'package:sample_project/main.dart';
import 'package:english_words/english_words.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
class ReadingScreen extends StatefulWidget {
  const ReadingScreen({Key? key}) : super(key: key);

  @override
  ReadingPage createState() => ReadingPage();
}

class ReadingPage extends State<ReadingScreen> {
  var ports = <String>[];
  late String data = '0.0';
  bool light = true;
  bool startReadingFlag = false;
  String startTime = '';
  String endTime = '';
  String userName = '';
  late int startDate;
  final sendData = Uint8List.fromList(List.filled(4, 1, growable: false));

  @override
  void initState() {
    super.initState();
  }

  void _getPortsAndClose() {
  SerialPortSingleton().closePort();
    showToast(
      'Readings stopped successfully',
      duration: Duration(seconds: 3),
      position: const ToastPosition(align: Alignment.topRight),
      backgroundColor: Colors.green
    );
  }
  
  void _getPortsAndOpen() {
    final List<PortInfo> portInfoLists = SerialPort.getPortsWithFullMessages();
    ports = SerialPort.getAvailablePorts();
    String datacopy = '';
    print(portInfoLists);
    print(ports);
    if (ports.isNotEmpty) {
      // Initialising the port name here
      SerialPortSingleton().initialize('COM5');
      SerialPortSingleton().openPort();
      print(SerialPortSingleton().port?.isOpened);
      
      String incomingData = '';
      String completeData = '';

      // while (port.isOpened) {
      // incomingData = '';
      SerialPortSingleton().port?.readBytesOnListen(8, (value) {
        print('check vlaue ${utf8.decode(value)}');
      // if (utf8.decode(value) != '+' && utf8.decode(value) != ',') {
      incomingData += utf8.decode(value);
      print('check incoming data ${incomingData.length}');
      if(incomingData.length > 50) {
          String trimmedData = incomingData.substring(35);
          incomingData = trimmedData;
      }
      List<String> parts = incomingData.split(',');
      print('check parts $parts');
      final regex = RegExp(r'[+-]\d+(?:\.\d+)?'); // Matches numbers optionally followed by a decimal point
      List<double> extractedValues = [];
      for (var part in parts) {
        final match = regex.matchAsPrefix(part);
        if (match != null) {
          // Extract the captured group (the number) and convert to double
          extractedValues.add(double.parse(match.group(0)!.substring(1))); // Remove leading "+"
        }
      }

      if (extractedValues.length >= 2) {
        completeData = extractedValues[extractedValues.length - 2].toString();
      }
      print('check data and complete data $data, $completeData');
      setState(() {data = completeData;});
      }
      );
    }
  }

  void _getStartDateWithTime(DateTime data) {
    startDate = data.millisecondsSinceEpoch;
  }

  String getSystemTime() {
    var now = DateTime.now();
    return DateFormat("hh:mm:ss a").format(now);
  }

  String getSystemDateAndTime(String inputFormat) {
    var now = DateTime.now();
    DateFormat.yMd().add_jm();
    var formattedMonthYear = DateFormat(inputFormat);
    String formatMonthYear = formattedMonthYear.format(now);
    return formatMonthYear;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(40, 20, 20, 40),
      color: Colors.white,
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: <Widget>[
              const SizedBox(
                  width: 500,
                  child: Text(
                    'Setup',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ))
                  ],
                ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    (!startReadingFlag)?(ElevatedButton.icon(
                    onPressed: () {
                      _getPortsAndOpen();
                      setState(() {
                        startReadingFlag = true;
                        startTime = getSystemTime();
                      });
                      // appState.toggleFavorite();
                    },
                    icon: const Icon(Icons.play_arrow),
                    style: const ButtonStyle(foregroundColor: WidgetStatePropertyAll<Color>(Colors.white), backgroundColor:  WidgetStatePropertyAll<Color>(Color.fromRGBO(0,145,255, 1))),
                    label: const Text('START READING', style: TextStyle(color: Colors.white)),
                  )):(ElevatedButton.icon(
                    onPressed: () {
                    _getPortsAndClose();
                    setState(() {
                      startReadingFlag = false;
                      endTime = getSystemTime();
                    });
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('STOP READING', style: TextStyle(color: Colors.white)),
                    style: const ButtonStyle(foregroundColor: WidgetStatePropertyAll<Color>(Colors.white), backgroundColor: WidgetStatePropertyAll<Color>(Color.fromRGBO(255, 111, 0, 1))),
                  )),
                ],
              ),
            
          const SizedBox(width: 100),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                  child: Text(
                'Readings',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              )),
              Padding(padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: TimeCard(
                  startTime: startTime,
                  startDateWithTime:_getStartDateWithTime,
                  endTime: endTime,
                  startReadingFlag: startReadingFlag),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: 
                  SizedBox(
                    height: 220,
                    width: 230,
                   child: BigCard(pair: pair, data: data),
                  )
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

}

class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.pair, required this.data});

  final WordPair pair;
  final String data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onSecondary,
      fontSize: 50
    );

    return Card(
      color: theme.colorScheme.secondary,
      child: Center(
        child: Text(
          data,
          style:const TextStyle(fontSize: 30, color: Colors.white),
          semanticsLabel: data,
        ),
      ),
    );
  }
}

class TimeCard extends StatelessWidget {
  const TimeCard(
      {super.key,
      required this.startTime,
      required this.endTime,
      required this.startDateWithTime,
      required this.startReadingFlag});

  final String startTime;
  final String endTime;
  final void Function(DateTime) startDateWithTime;
  final bool startReadingFlag;

  String getSystemTime() {
    var now = DateTime.now();
    // DateFormat.yMd().add_jm().format(now)
    startDateWithTime(now);
    return DateFormat("hh:mm:ss a").format(now);
  }

  String getSystemDate(String inputFormat) {
    var now = DateTime.now();
    var formattedMonthYear = DateFormat(inputFormat);
    String formatMonthYear = formattedMonthYear.format(now);
    return formatMonthYear;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
        color: theme.colorScheme.secondary,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(getSystemDate('d'), style:const TextStyle(fontSize: 30, color: Colors.white)),
                  Text(getSystemDate('MMMM y'), style:const TextStyle(fontSize: 20, color: Colors.white))
                ],
              ),
              const SizedBox(width: 80),
              Column(
                children: [
                  const Text('Start time', style:TextStyle(fontSize: 15, color: Colors.white)),
                  SizedBox(
                    width: 130,
                    height: 50,
                    child: Card(
                      child: Center(
                      child: Text(
                        startTime,
                        style: const TextStyle(
                          color: Color(0xff2d386b),
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                      )
                      ))
                  )
                ],
              ),
              const SizedBox(width: 20),
              Column(
                children: [
                  const Text('End time', style:TextStyle(fontSize: 15, color: Colors.white)),
                  SizedBox(
                    width: 130,
                    height: 50,
                    child: Card(
                      child: Center(
                         child: (startReadingFlag == true && startTime != '')
                          ? TimerBuilder.periodic(const Duration(seconds: 1),
                              builder: (context) {
                              return Text(
                                getSystemTime(),
                                style: const TextStyle(
                                    color: Color(0xff2d386b),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              );
                            })
                          : (startTime == '' && startReadingFlag == false)
                              ? (null)
                              : Text(
                                  endTime,
                                  style: const TextStyle(
                                      color: Color(0xff2d386b),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ))
                      )
                     )
                ],
              ),
            ],
          ),
        ));
  }
}








