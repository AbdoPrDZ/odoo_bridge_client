// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// OdooModelHelperGenerator
// **************************************************************************

part of 'res_company.dart';

extension ResCompanyHelper on ResCompany {
  static ResCompany fromJson(Map<String, dynamic> json) => ResCompany(
    id: json['id'] as int?,
    name: json['name'] as String,
    vat: json['vat'] as String?,
    email: json['email'] as String?,
    createDate: json['create_date'] as DateTime?,
    writeDate: json['write_date'] as DateTime?,
    createUid: json['create_uid'] as int?,
    writeUid: json['write_uid'] as int?,
  );
}

extension ResCompanyJsonEncoding on ResCompany {
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'vat': vat,
      'email': email,
      'create_date': (createDate == null)
          ? null
          : createDate!.toIso8601String(),
      'write_date': (writeDate == null) ? null : writeDate!.toIso8601String(),
      'create_uid': createUid,
      'write_uid': writeUid,
    };
  }
}
