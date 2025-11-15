// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// OdooModelHelperGenerator
// **************************************************************************

part of 'res_partner.dart';

extension ResPartnerHelper on ResPartner {
  static ResPartner fromJson(Map<String, dynamic> json) => ResPartner(
    id: json['id'] as int?,
    name: json['name'] as String,
    email: json['email'] as String?,
    createDate: json['create_date'] as DateTime?,
  );
}

extension ResPartnerJsonEncoding on ResPartner {
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'create_date': (createDate == null)
          ? null
          : createDate!.toIso8601String(),
    };
  }
}
