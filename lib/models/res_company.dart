import 'package:odoo_bridge_client/odoo_bridge_client.dart';

part 'res_company.model_helper.g.dart';

@OdooModel('res.company')
class ResCompany {
  @OdooIntegerField('id')
  int? id;

  @OdooCharField('name')
  String name;

  @OdooCharField('vat', nullable: true)
  String? vat;

  @OdooCharField('email', nullable: true)
  String? email;

  @OdooDateTimeField('create_date', nullable: true)
  DateTime? createDate;

  @OdooDateTimeField('write_date', nullable: true)
  DateTime? writeDate;

  @OdooIntegerField('create_uid', nullable: true)
  int? createUid;

  @OdooIntegerField('write_uid', nullable: true)
  int? writeUid;

  ResCompany({
    this.id,
    required this.name,
    this.vat,
    this.email,
    this.createDate,
    this.writeDate,
    this.createUid,
    this.writeUid,
  });
}
