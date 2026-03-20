import 'dart:convert';
import 'dart:io';
void main() {
  final file = File('assets/players_data.json');
  final data = jsonDecode(file.readAsStringSync()) as List;
  final nats = data.map((e) => e['nationality']).toSet().toList()..sort();
  print(nats.join(', '));
}
