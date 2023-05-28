import 'dart:io';

import 'package:circuts2/settings/settings_controller.dart';
import 'package:f_logs/f_logs.dart';
import 'package:get/get.dart';
import 'package:process_run/shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Helper {
  static Uri pythonUri = Uri.parse(
      'https://www.python.org/ftp/python/3.8.6/python-3.8.6-embed-amd64.zip');
  static String pythonPath = '';

  static Directory get scriptsDirectory {
    return Directory(assetsDirectory.path + '/scripts');
  }

  static Directory get sitePackagesDirectory {
    return Directory(scriptsDirectory.path + '/Lib/site-packages');
  }

  static Directory get internalPythonDirectory {
    return Directory(assetsDirectory.path + '/scripts');
  }

  static Directory get assetsDirectory {
    String mainPath = Platform.resolvedExecutable;
    mainPath = mainPath.substring(0, mainPath.lastIndexOf("\\"));
    Directory directoryScripts =
        Directory("$mainPath/data/flutter_assets/assets");
    return directoryScripts;
  }

  static Future<String?> findPythonPath() async {
    // FlutterLogs.logInfo('HELPER','', 'find python path');
    FLog.info(text: 'find python path');
    if (File('${Helper.internalPythonDirectory.path}/python.exe').existsSync()) {
      // FlutterLogs.logInfo('HELPER','', 'inner exists');
      FLog.info(text: 'inner exxist');
      Get.find<SettingsController>().embeddedPythonInstalled.trigger(true);
      return '${Helper.internalPythonDirectory.path}/python.exe';
    } else {
      FLog.info(text: 'inner doesnt exist');
      // FlutterLogs.logInfo('HELPER','', 'inner doesnt exist');
      Get.find<SettingsController>().embeddedPythonInstalled.trigger(false);
    }
    FLog.info(text: 'which');
    // FlutterLogs.logInfo('HELPER','', 'which');
    return whichSync('python')?.replaceAll('\\','/');
    // if (result == null) {
    //   var shell = Shell(
    //     runInShell: false,
    //     workingDirectory: r'.',
    //   );
    //   var result = await shell.run('where.exe python');
    //   return result.outText
    //       .split('\n')
    //       .last;
    // }
  }

  static Future<bool> checkPythonPath(String path) async {
    // FlutterLogs.logInfo('HELPER','', 'check path ${path}');
    FLog.info(text: 'check path $path');
    var version = await Shell().run('${path} --version').catchError(
              (v) => <ProcessResult>[]
      );

    // FlutterLogs.logInfo('HELPER','', 'check path  ${version}');
    FLog.info(text: 'check path $version');
    return version.outText.contains('Python 3');
  }

  static Future<bool> setPythonPath(String path) async {
    FLog.info(text: 'setting python path $path');
    if (await checkPythonPath(path)) {
      Helper.pythonPath = path.replaceAll('\\', '/');
      FLog.info(text: 'path set ${Helper.pythonPath}');
      // FlutterLogs.logInfo('HELPER','', 'path set ${Helper.pythonPath}');
      (await SharedPreferences.getInstance()).setString('python', Helper.pythonPath);
      Get.find<SettingsController>().pythonPathController.text = Helper.pythonPath;
      return true;
    }
    FLog.info(text: 'path not set');
    return false;
  }

  static Future<bool> loadPythonPath([fromSP = true]) async {
    FLog.info(text: 'loading python path fromSP=${fromSP}');
    // FlutterLogs.logInfo('HELPER','', 'loading python path fromSP=${fromSP}');
    var path = await Helper.findPythonPath();
    if (fromSP) {
      var sp = await SharedPreferences.getInstance();
      var path = sp.getString('python');
      if (path != null && await setPythonPath(path)) {
        return true;
      }
    }
    if (path != null) {
      return setPythonPath(path);
    }
    return false;
  }
}

extension ListHelper<T extends num> on Iterable<T> {
  T? max() {
    if (isEmpty) {
      return null;
    }
    return fold(first, (T? p, e) => e >= (p ?? e) ? e : p);
  }

  T? min() {
    if (isEmpty) {
      return null;
    }
    return fold(first, (T? p, e) => e <= (p ?? e) ? e : p);
  }
}
