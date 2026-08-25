class CompanyResponse {
  final String companyId;
  final String legalName;
  final String? displayName;
  final String? businessIdentifier;
  final String status;
  final String createdAt;

  const CompanyResponse({
    required this.companyId,
    required this.legalName,
    this.displayName,
    this.businessIdentifier,
    required this.status,
    required this.createdAt,
  });

  factory CompanyResponse.fromJson(Map<String, dynamic> json) {
    return CompanyResponse(
      companyId: json['companyId'] as String,
      legalName: json['legalName'] as String,
      displayName: json['displayName'] as String?,
      businessIdentifier: json['businessIdentifier'] as String?,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  String get name => displayName ?? legalName;

  String get statusLabel => switch (status) {
        'ACTIVE' => 'Faol',
        'ARCHIVED' => 'Arxivlangan',
        _ => status,
      };
}

class CreateCompanyPayload {
  final String legalName;
  final String? displayName;
  final String? businessIdentifier;

  const CreateCompanyPayload({
    required this.legalName,
    this.displayName,
    this.businessIdentifier,
  });

  Map<String, dynamic> toJson() => {
        'legalName': legalName,
        if (displayName != null) 'displayName': displayName,
        if (businessIdentifier != null) 'businessIdentifier': businessIdentifier,
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
