class SubscriptionInfo {
  final bool isActive;
  final String planName;
  final DateTime expiryDate;

  SubscriptionInfo({
    required this.isActive,
    required this.planName,
    required this.expiryDate,
  });
}
