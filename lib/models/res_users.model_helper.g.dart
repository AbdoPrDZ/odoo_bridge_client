// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// OdooModelHelperGenerator
// **************************************************************************

part of 'res_users.dart';

extension ResUsersHelper on ResUsers {
  OdooModelItem toOdooModelItem() =>
      OdooModelItem(id: id!, displayName: name, odooModel: 'res.users');

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

  Map<String, dynamic> toJson() => {
    'id': ModelRegistry.toJsonValue<ResUsers>('id', id),
    'name': ModelRegistry.toJsonValue<ResUsers>('name', name),
    'login': ModelRegistry.toJsonValue<ResUsers>('login', login),
    'email': ModelRegistry.toJsonValue<ResUsers>('email', email),
    'create_date': ModelRegistry.toJsonValue<ResUsers>(
      'create_date',
      createDate,
    ),
    'write_date': ModelRegistry.toJsonValue<ResUsers>('write_date', writeDate),
    'create_uid': ModelRegistry.toJsonValue<ResUsers>('create_uid', createUid),
    'write_uid': ModelRegistry.toJsonValue<ResUsers>('write_uid', writeUid),
  };

  static Future<APIResponse<List<ResUsers>>> searchRead(
    Odoo odoo, {
    List<dynamic> domain = const [],
    List<String>? fields,
    int? limit,
    int offset = 0,
    String? order,
  }) => odoo.searchRead<ResUsers>(
    domain: domain,
    fields: fields,
    limit: limit,
    offset: offset,
    order: order,
  );

  static Future<APIResponse<List<ResUsers>>> read(
    Odoo odoo,
    List<int> ids, {
    List<String>? fields,
    int offset = 0,
    int? limit,
    String? order,
  }) => odoo.read<ResUsers>(
    ids,
    fields: fields,
    offset: offset,
    limit: limit,
    order: order,
  );

  static Future<APIResponse<List<ResUsers>>> create(Odoo odoo, ResUsers item) =>
      odoo.create<ResUsers>(item.toJson());

  Future<bool> exists(Odoo odoo) async {
    if (id == null) {
      return false;
    }
    final response = await odoo.exists<ResUsers>([id!]);
    return response.success && response.value == true;
  }

  Future<APIResponse<bool>> save(Odoo odoo) async {
    if (id == null) {
      final response = await create(odoo, this);
      return response.copyWith<bool>(value: response.success);
    } else {
      return await odoo.write<ResUsers>([id!], toJson());
    }
  }

  Future<APIResponse<bool>> unlink(Odoo odoo) => odoo.unlink<ResUsers>([id!]);
}
