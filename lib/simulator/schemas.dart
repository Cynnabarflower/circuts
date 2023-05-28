class Schemas {

  static Schemas get first => Schemas.fromString('''
V1 1 0 sin(0 1 1k)
R1 1 2 100
C1 2 0 1u
L1 2 0 1u
.tran 5u 10m 0 0
.backanno
.end'''.trim()
  );

  static Schemas get firstFrequencyResponse => Schemas.fromString('''
V1 1 0 sin(0 1 1k)
R1 1 2 100
C1 2 0 1u
L1 2 0 1u
.ac dec 10 10m 1meg
.backanno
.end'''.trim()
  );

  static Schemas get second => Schemas.fromString('''
V1 1 0 sin(0 1 1k)
R1 1 2 100
C1 2 0 1u
L1 2 0 1u
.tran 5u 10m 0 0
.backanno
.end'''.trim()
  );


  Map<String, List<String>> data = {};

  Schemas(this.data);

  Schemas.fromString(String s) {
    var lines = s.split('\n');
    for (var line in lines) {
      line = line.trim();
      if (line.contains(' ')) {
        data[line.split(' ').first] = line.split(' ').sublist(1);
      } else {
        data[line] = [];
      }
    }
  }

  @override
  String toString() {
    String s = '';
    for (var line in data.entries) {
      s += '${line.key} ${line.value.join(' ')}\n';
    }
    return s;
  }

}