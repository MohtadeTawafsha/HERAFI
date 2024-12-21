class ProjectEntity {
  final int id; // الرقم التعريفي للمشروع
  final String title; // عنوان المشروع
  final double? price; // سعر المشروع
  final DateTime? startDate; // تاريخ البدء
  final DateTime? endDate; // تاريخ الانتهاء
  final String? customerId; // معرف العميل
  final String? craftsmanId; // معرف الحرفي
  final String state; // حالة المشروع

  ProjectEntity({
    required this.id,
    required this.title,
    this.price,
    this.startDate,
    this.endDate,
    this.customerId,
    this.craftsmanId,
    this.state = 'تم الإرسال للعميل',
  });
}
