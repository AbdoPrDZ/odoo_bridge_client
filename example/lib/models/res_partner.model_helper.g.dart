// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// OdooModelHelperGenerator
// **************************************************************************

part of 'res_partner.dart';

extension ResPartnerHelper on ResPartner {
  OdooModelItem toOdooModelItem() =>
      OdooModelItem(id: id!, displayName: name, odooModel: 'res.partner');

  static ResPartner fromJson(Map<String, dynamic> json) => ResPartner(
    id: json['id'] as int?,
    name: json['name'] as String,
    email: json['email'] as String?,
    createDate: json['create_date'] as DateTime?,
  );

  Map<String, dynamic> toJson() => {
    'id': ModelRegistry.toJsonValue<ResPartner>('id', id),
    'name': ModelRegistry.toJsonValue<ResPartner>('name', name),
    'email': ModelRegistry.toJsonValue<ResPartner>('email', email),
    'create_date': ModelRegistry.toJsonValue<ResPartner>(
      'create_date',
      createDate,
    ),
  };

  static Future<APIResponse<List<ResPartner>>> searchRead(
    Odoo odoo, {
    List<dynamic> domain = const [],
    List<String>? fields,
    int? limit,
    int offset = 0,
    String? order,
  }) => odoo.searchRead<ResPartner>(
    domain: domain,
    fields: fields,
    limit: limit,
    offset: offset,
    order: order,
  );

  static Future<APIResponse<List<ResPartner>>> read(
    Odoo odoo,
    List<int> ids, {
    List<String>? fields,
    int offset = 0,
    int? limit,
    String? order,
  }) => odoo.read<ResPartner>(
    ids,
    fields: fields,
    offset: offset,
    limit: limit,
    order: order,
  );

  static Future<APIResponse<List<ResPartner>>> create(
    Odoo odoo,
    ResPartner item,
  ) => odoo.create<ResPartner>(item.toJson());

  Future<bool> exists(Odoo odoo) async {
    if (id == null) {
      return false;
    }
    final response = await odoo.exists<ResPartner>([id!]);
    return response.success && response.value == true;
  }

  Future<APIResponse<bool>> save(Odoo odoo) async {
    if (id == null) {
      final response = await create(odoo, this);
      return response.copyWith<bool>(value: response.success);
    } else {
      return await odoo.write<ResPartner>([id!], toJson());
    }
  }

  Future<APIResponse<bool>> unlink(Odoo odoo) => odoo.unlink<ResPartner>([id!]);
}
