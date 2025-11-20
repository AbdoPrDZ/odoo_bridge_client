import 'package:odoo_bridge_client/odoo_bridge_client.dart';

part 'res_users.model_helper.g.dart';

@OdooModel('res.users')
class ResUsers {
  @OdooIntegerField('id')
  int? id;

  @OdooCharField('name')
  String name;

  @OdooCharField('login', nullable: true)
  String? login;

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

  ResUsers({
    this.id,
    required this.name,
    this.login,
    this.email,
    this.createDate,
    this.writeDate,
    this.createUid,
    this.writeUid,
  });
}
