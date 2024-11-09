import 'package:serial_port_win32/serial_port_win32.dart';

class SerialPortSingleton {
  static final SerialPortSingleton _instance = SerialPortSingleton._internal();
  SerialPort? port;

  factory SerialPortSingleton() {
    return _instance;
  }

  SerialPortSingleton._internal();

  void initialize(String portName) {
    if (port == null) {
      port = SerialPort(
        portName, 
        openNow: false, 
        BaudRate: 9600, 
        ByteSize: 8, 
        Parity: 0, 
        StopBits: 1, 
        ReadIntervalTimeout: 1, 
        ReadTotalTimeoutConstant: 2
      );
    }
  }

  void openPort() {
    if (port != null && !port!.isOpened) {
      port!.open();
    }
  }

  void closePort() {
    if (port != null && port!.isOpened) {
      port!.close();
    }
  }
}