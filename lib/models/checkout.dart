class CheckoutData {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String zip;
  final String paymentMethod;
  final String? cardNumber;
  final String? cardName;
  final String? cardExpiry;
  final String? cardCvv;

  CheckoutData({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.zip,
    required this.paymentMethod,
    this.cardNumber,
    this.cardName,
    this.cardExpiry,
    this.cardCvv,
  });

  // Converte um Map (JSON) para uma instância de CheckoutData
  factory CheckoutData.fromJson(Map<String, dynamic> json) {
    return CheckoutData(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zip: json['zip'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      cardNumber: json['cardNumber'],
      cardName: json['cardName'],
      cardExpiry: json['cardExpiry'],
      cardCvv: json['cardCvv'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'zip': zip,
      'paymentMethod': paymentMethod,
      'cardNumber': cardNumber,
      'cardName': cardName,
      'cardExpiry': cardExpiry,
      'cardCvv': cardCvv,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
