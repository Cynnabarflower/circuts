import 'dart:io';

import 'package:circuts2/helper.dart';
import 'package:pty/pty.dart';
import 'package:xterm/terminal/terminal_backend.dart';

class LocalTerminalBackend extends TerminalBackend {
  LocalTerminalBackend();

  final pty = PseudoTerminal.start(
    'cmd',
    // '/system/bin/sh',
    [],
    workingDirectory: Helper.scriptsDirectory.path,
    environment: Platform.environment,
  );

  @override
  Future<int> get exitCode => pty.exitCode;

  @override
  Stream<String> get out => pty.out;

  @override
  void resize(int width, int height, int pixelWidth, int pixelHeight) {
    pty.resize(width, height);
  }

  @override
  void write(String input) {
    if (input.startsWith('python.exe ')) {
      input = input.replaceFirst('python.exe', Helper.pythonPath);
    }
    pty.write(input);
  }

  @override
  void terminate() {
    // client.disconnect('terminate');
  }

  @override
  void ackProcessed() {
    // NOOP
  }

  @override
  void init() {
    //

  }
}
