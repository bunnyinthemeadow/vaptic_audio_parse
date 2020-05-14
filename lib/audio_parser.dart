class Parser{
  Map motorMap; //comes from pseudo-hilbert.dart
  int motorN;
  Parser(List<int> motorHilbert){
    Map<int, int> backwardsMap = motorHilbert.asMap();
    motorMap = backwardsMap.map((key, value) => MapEntry(value, key));
    motorN = motorMap.length;
  }

  List<double> _map(List<double> separatedAudio){
    return List.generate(motorN, (int index) => separatedAudio[motorMap[index]]);
  }
}