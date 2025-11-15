// GENERATED CODE - DO NOT MODIFY BY HAND
// Auto-generated registry for all Odoo models

part of 'models.dart';

class OdooModelsRegistry {
  static void registerAll() {
    ModelRegistry.registerModel<ResPartner>('res.partner', [
      OdooIntegerField('id'),
      OdooCharField('name'),
      OdooCharField('email', nullable: true),
      OdooDateTimeField('create_date', nullable: true),
    ], ResPartnerHelper.fromJson);
  }
}
