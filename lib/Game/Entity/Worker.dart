import 'package:json_object/json_object.dart';

class Worker {
  final int id;
  final String name;
  final int level;
  final int grade;
  final int salary;
  final int periodToGetSalary;
  final int remainingPeriodToGetSalary;

  Worker({
    this.id,
    this.name,
    this.level,
    this.grade,
    this.salary,
    this.periodToGetSalary,
    this.remainingPeriodToGetSalary,
  }) {}

  JsonObject toJson() =>
    new JsonObject
      .fromMap({
        'id': id,
        'name': name,
        'level': level,
        'grade': grade,
        'salary': salary,
        'periodToGetSalary': periodToGetSalary,
        'remainingPeriodToGetSalary': remainingPeriodToGetSalary,
      });

  String toString() =>
    toJson().toString();
}
