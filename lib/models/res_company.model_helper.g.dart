// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// OdooModelHelperGenerator
// **************************************************************************

part of 'res_company.dart';

extension ResCompanyHelper on ResCompany {
  OdooModelItem toOdooModelItem() =>
      OdooModelItem(id: id!, displayName: name, odooModel: 'res.company');

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

  Map<String, dynamic> toJson() => {
    'id': ModelRegistry.toJsonValue<ResCompany>('id', id),
    'name': ModelRegistry.toJsonValue<ResCompany>('name', name),
    'vat': ModelRegistry.toJsonValue<ResCompany>('vat', vat),
    'email': ModelRegistry.toJsonValue<ResCompany>('email', email),
    'create_date': ModelRegistry.toJsonValue<ResCompany>(
      'create_date',
      createDate,
    ),
    'write_date': ModelRegistry.toJsonValue<ResCompany>(
      'write_date',
      writeDate,
    ),
    'create_uid': ModelRegistry.toJsonValue<ResCompany>(
      'create_uid',
      createUid,
    ),
    'write_uid': ModelRegistry.toJsonValue<ResCompany>('write_uid', writeUid),
  };

  static Future<APIResponse<List<ResCompany>>> searchRead(
    Odoo odoo, {
    List<dynamic> domain = const [],
    List<String>? fields,
    int? limit,
    int offset = 0,
    String? order,
  }) => odoo.searchRead<ResCompany>(
    domain: domain,
    fields: fields,
    limit: limit,
    offset: offset,
    order: order,
  );

  static Future<APIResponse<List<ResCompany>>> read(
    Odoo odoo,
    List<int> ids, {
    List<String>? fields,
    int offset = 0,
    int? limit,
    String? order,
  }) => odoo.read<ResCompany>(
    ids,
    fields: fields,
    offset: offset,
    limit: limit,
    order: order,
  );

  static Future<APIResponse<List<ResCompany>>> create(
    Odoo odoo,
    ResCompany item,
  ) => odoo.create<ResCompany>(item.toJson());

  Future<bool> exists(Odoo odoo) async {
    if (id == null) {
      return false;
    }
    final response = await odoo.exists<ResCompany>([id!]);
    return response.success && response.value == true;
  }

  Future<APIResponse<bool>> save(Odoo odoo) async {
    if (id == null) {
      final response = await create(odoo, this);
      return response.copyWith<bool>(value: response.success);
    } else {
      return await odoo.write<ResCompany>([id!], toJson());
    }
  }

  Future<APIResponse<bool>> unlink(Odoo odoo) => odoo.unlink<ResCompany>([id!]);
}
