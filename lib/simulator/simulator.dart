import 'dart:io';

import 'package:circuts2/helper.dart';
import 'package:circuts2/simulator/simulation_result.dart';
import 'package:process_run/shell.dart';

class Simulator {

  Future<List<SimulationResult>> simulate(String data, {String variableString = ''}) async {

    var shell = Shell(
      runInShell: false
    );
    data = data.replaceAll('\n', '%20').trim();
    var processResult = await shell.run('${Helper.pythonPath} ${Helper.scriptsDirectory.path}\\op_network.py %20 "$data" $variableString');

    var result = <String, Map<String, dynamic>>{};
    var outText = processResult.outText;
    var lines = outText.split('\n');
    var keys = ['v', 'i'];
    for (var line in lines) {
      if (line.isEmpty) continue;
      var k = line[0];
      if (keys.contains(k)) {
      if (line.startsWith(k)) {
        var name = line.substring(2, line.indexOf(')'));
        if (line.contains('[')) {
          var sub = line.substring(line.indexOf('[')+1, line.indexOf(']')).split(',').map((e) => double.parse(e)).toList();
          (result[name] ??= {})[k] = sub;
        } else {
          (result[name] ??= {})[k] = double.parse(line.split('=').last);
        }
      }}
    }
    List<SimulationResult> simulationResults = [];
    for (var key in result.entries) {
      simulationResults.add(
        SimulationResult(
          key.key,
          current: key.value['i'],
          voltage: key.value['v']
        )
      );
    }
    return simulationResults;
  }

}