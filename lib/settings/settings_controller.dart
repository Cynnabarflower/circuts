import 'dart:io';

import 'package:archive/archive_io.dart' as archive;
import 'package:circuts2/helper.dart';
import 'package:circuts2/settings/local_terminal.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';
import 'package:xterm/xterm.dart';
import 'package:http/http.dart' as http;

class SettingsController extends GetxController {

  TextEditingController pythonPathController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();
  Map<String, bool> validatorMap = {};
  LocalTerminalBackend? localTerminalBackend;
  Rx<Terminal?> terminal = Rx(null);

  RxDouble installationProgress = 0.0.obs;
  RxString installationMessage = ''.obs;
  RxBool embeddedPythonInstalled = false.obs;

  //not used
  Future<void> downloadPython() async {
    installationMessage.trigger('Downloading...');
    installationProgress.trigger(0.01);
    var tmpDir = await getTemporaryDirectory();
    var zipFile = File("${tmpDir.path}/downloaded.zip");
    var response = await http.Client()
        .send(http.Request('GET', Helper.pythonUri));
    var length = response.contentLength ?? 0;
    var received = 0;

    await zipFile.openWrite().addStream(
        response.stream.map((value) {
          received += value.length;
          installationProgress.trigger((received / length * 100));
           return value;
        })
    );
    installationMessage.trigger('Extracting...');
    installationProgress.trigger(0.01);
    print('extracting...');
    await archive.extractFileToDisk(zipFile.path, Helper.internalPythonDirectory.path);
  }

  Future<void> installPython() async {
    embeddedPythonInstalled.trigger(false);
    installationMessage.trigger('Installing...');
    // installationProgress.trigger(0.01);
    // await downloadPython();
    await archive.extractFileToDisk('${Helper.sitePackagesDirectory.path}/python-3.8.6-embed-amd64.zip', Helper.internalPythonDirectory.path);
    // installationProgress.trigger(0.33);
    await archive.extractFileToDisk('${Helper.sitePackagesDirectory.path}/scipy.zip', Helper.sitePackagesDirectory.path);installationProgress.trigger(0.33);
    // installationProgress.trigger(0.66);
    await archive.extractFileToDisk('${Helper.sitePackagesDirectory.path}/numpy.zip', Helper.sitePackagesDirectory.path);
    // installationProgress.trigger(0.99);
    var pthPath = Directory(Helper.internalPythonDirectory.path).listSync().firstWhere((element) => element.path.endsWith('_pth')).path;
    var s = File(pthPath).readAsStringSync();
    s = s.replaceAll('#import site', 'import site');
    s += '\nLib';
    s += '\nLib/site-packages';
    File(pthPath).writeAsStringSync(s);
    installationProgress.trigger(0.0);
    installationMessage.trigger('');
    Helper.setPythonPath(Helper.internalPythonDirectory.path + '/python.exe');
    Helper.findPythonPath();

    // Shell shell = Shell(workingDirectory: Helper.internalPythonDirectory.path);
    // print('get pip');
    // print(await shell.run('${Helper.pythonPath} -m ensurepip --upgrade'));
    // print(await shell.run('${Helper.pythonPath} get-pip.py'));
    // print('installing scipy, numpy');
    // print(await shell.run('${Helper.pythonPath} -m pip install scipy'));
    // print(await shell.run('${Helper.pythonPath} -m pip install numpy'));
    // terminal.value?.backend!.write('${Helper.pythonPath} --version\r');
  }

  void initTerm() {
    localTerminalBackend = LocalTerminalBackend();
    terminal.trigger(Terminal(maxLines: 10000, backend: localTerminalBackend));
  }

  @override
  void onInit() {
    super.onInit();
  }
}