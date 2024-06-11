class Car {
  String title;
  String imageUrl;
  String price;
  String location;
  String travel;

  // Constructor
  Car({
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.location,
    required this.travel
  });

  // Method to convert Car instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': title,
      'price': price,
      'imageUrl': imageUrl,
      'location': location,
      'travel': travel
    };
  }

  // Factory method to create Car instance from JSON
  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      title: json['title'],
      price: json['price'],
      imageUrl: json['imageUrl'],
      location: json['location'],
      travel: json['travel']
    );
  }
}
