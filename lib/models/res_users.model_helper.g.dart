// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// OdooModelHelperGenerator
// **************************************************************************

part of 'res_users.dart';

extension ResUsersHelper on ResUsers {
  static ResUsers fromJson(Map<String, dynamic> json) => ResUsers(
    id: json['id'] as int?,
    name: json['name'] as String,
    login: json['login'] as String?,
    email: json['email'] as String?,
    createDate: json['create_date'] as DateTime?,
    writeDate: json['write_date'] as DateTime?,
    createUid: json['create_uid'] as int?,
    writeUid: json['write_uid'] as int?,
  );
}

extension ResUsersJsonEncoding on ResUsers {
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'login': login,
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
