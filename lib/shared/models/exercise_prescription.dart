/// Configuração usada para gerar as séries planejadas de um exercício.
class ExercisePrescription {
  final int setCount;
  final int repetitions;
  final double? weight;
  final int restSeconds;

  const ExercisePrescription({
    required this.setCount,
    required this.repetitions,
    this.weight,
    required this.restSeconds,
  }) : assert(setCount > 0),
       assert(repetitions > 0),
       assert(restSeconds >= 0);

  Map<String, dynamic> toJson() => {
    'setCount': setCount,
    'repetitions': repetitions,
    'weight': weight,
    'restSeconds': restSeconds,
  };

  factory ExercisePrescription.fromJson(Map<String, dynamic> json) =>
      ExercisePrescription(
        setCount: json['setCount'] as int,
        repetitions: json['repetitions'] as int,
        weight: (json['weight'] as num?)?.toDouble(),
        restSeconds: json['restSeconds'] as int,
      );
}
