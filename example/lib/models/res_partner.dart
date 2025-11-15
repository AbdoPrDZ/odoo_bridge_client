import 'package:odoo_bridge_client/odoo_model.dart';

part 'res_partner.model_helper.g.dart';

@OdooModel('res.partner')
class ResPartner {
  @OdooIntegerField('id')
  int? id;

  @OdooCharField('name')
  String name;

  @OdooCharField('email', nullable: true)
  String? email;

  @OdooDateTimeField('create_date', nullable: true)
  DateTime? createDate;

  ResPartner({
    this.id,
    required this.name,
    required this.email,
    this.createDate,
  });
}
