class CompanyResponse {
  final String companyId;
  final String name;
  final String? inn;
  final String? legalAddress;
  final String? contactPhone;
  final String status;
  final String createdAt;

  const CompanyResponse({
    required this.companyId,
    required this.name,
    this.inn,
    this.legalAddress,
    this.contactPhone,
    required this.status,
    required this.createdAt,
  });

  factory CompanyResponse.fromJson(Map<String, dynamic> json) {
    return CompanyResponse(
      companyId: json['companyId'] as String,
      name: json['name'] as String,
      inn: json['inn'] as String?,
      legalAddress: json['legalAddress'] as String?,
      contactPhone: json['contactPhone'] as String?,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  String get statusLabel => switch (status) {
        'ACTIVE' => 'Faol',
        'SUSPENDED' => 'To\'xtatilgan',
        'PENDING' => 'Kutilmoqda',
        _ => status,
      };
}

class CreateCompanyPayload {
  final String name;
  final String? inn;
  final String? legalAddress;
  final String? contactPhone;

  const CreateCompanyPayload({
    required this.name,
    this.inn,
    this.legalAddress,
    this.contactPhone,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (inn != null) 'inn': inn,
        if (legalAddress != null) 'legalAddress': legalAddress,
        if (contactPhone != null) 'contactPhone': contactPhone,
      };
}

class CompanyMember {
  final String userId;
  final String displayName;
  final String role;
  final String joinedAt;

  const CompanyMember({
    required this.userId,
    required this.displayName,
    required this.role,
    required this.joinedAt,
  });

  factory CompanyMember.fromJson(Map<String, dynamic> json) {
    return CompanyMember(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      role: json['role'] as String,
      joinedAt: json['joinedAt'] as String,
    );
  }
}
