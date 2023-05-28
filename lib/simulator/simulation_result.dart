class SimulationResult {
  String name;
  List<double> voltage = [];
  List<double> current = [];

  SimulationResult(this.name, {List<double>? voltage, List<double>? current}) :
      voltage = voltage ?? [],
      current = current ?? [];
}