enum Gender {
  female('Nữ', 'female'),
  male('Nam', 'male')
  ;

  const Gender(this.label, this.value);

  final String label;
  final String value;
}
