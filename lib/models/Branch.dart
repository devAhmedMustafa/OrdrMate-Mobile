class Branch {
  final String id;
  final String address;
  final double latitude;
  final double longitude;
  final String restaurantId;
  final String restaurantName;

  Branch({
    required this.id,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.restaurantId,
    required this.restaurantName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
    };
  }

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['branchId'] as String,
      address: json['branchAddress'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      restaurantId: json['restaurantId'] as String,
      restaurantName: json['restaurantName'] as String,
    );
  }
}

class BranchInfo {
  final String branchId;
  final String branchAddress;
  final String? branchPhoneNumber;
  final String restaurantName;
  final double minWaitingTime;
  final double maxWaitingTime;
  final double averageWaitingTime;
  final int freeTables;
  final int ordersInQueue;

  BranchInfo({
    required this.branchId,
    required this.branchAddress,
    this.branchPhoneNumber,
    required this.restaurantName,
    required this.minWaitingTime,
    required this.maxWaitingTime,
    required this.averageWaitingTime,
    required this.freeTables,
    required this.ordersInQueue,
  });

  factory BranchInfo.fromJson(Map<String, dynamic> json) {
    return BranchInfo(
      branchId: json['branchId'],
      branchAddress: json['branchAddress'],
      branchPhoneNumber: json['branchPhoneNumber'],
      restaurantName: json['restaurantName'],
      minWaitingTime: json['minWaitingTime'].toDouble(),
      maxWaitingTime: json['maxWaitingTime'].toDouble(),
      averageWaitingTime: json['averageWaitingTime'].toDouble(),
      freeTables: json['freeTables'],
      ordersInQueue: json['ordersInQueue'],
    );
  }
}