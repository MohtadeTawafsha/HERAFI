class ProjectStepEntity {
  final int stepNumber;
  final String title;
  final double price;
  final String duration; // تم تغيير النوع إلى Text
  final bool isPaid;

  ProjectStepEntity({
    required this.stepNumber,
    required this.title,
    required this.price,
    required this.duration, // نوع String الآن
    this.isPaid = false,
  });
}
