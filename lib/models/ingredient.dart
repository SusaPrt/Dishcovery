import 'package:hive/hive.dart';

part 'ingredient.g.dart';

@HiveType(typeId: 1)
class Ingredient extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  String unit;

  @HiveField(3)
  String ownerEmail;

  Ingredient({required this.name, required this.quantity, required this.unit, required this.ownerEmail});
}
