enum PaymentMethod {
  cash,
  card,
}

String paymentMethodToString(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.cash:
      return 'cash';
    case PaymentMethod.card:
      return 'card';
    }
}