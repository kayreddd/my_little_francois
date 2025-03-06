import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  await Hive.initFlutter();
  
  print('Suppression des données Hive...');
  await Hive.deleteFromDisk();
  print('Données Hive supprimées avec succès!');
}
