// GENERATED CODE - DO NOT MODIFY BY HAND
// Auto-generated registry for all Odoo models

part of 'models.dart';

class BaseOdooModelsRegistry {
  static void registerAll() {
    // Register Odoo models
    // Register model: res.users
    ModelRegistry.registerModel<ResUsers>('res.users', [
      OdooIntegerField('id'),
      OdooCharField('name'),
      OdooCharField('login', nullable: true),
      OdooCharField('email', nullable: true),
      OdooDateTimeField('create_date', nullable: true),
      OdooDateTimeField('write_date', nullable: true),
      OdooIntegerField('create_uid', nullable: true),
      OdooIntegerField('write_uid', nullable: true),
    ], ResUsersHelper.fromJson);

    // Register model: res.company
    ModelRegistry.registerModel<ResCompany>('res.company', [
      OdooIntegerField('id'),
      OdooCharField('name'),
      OdooCharField('vat', nullable: true),
      OdooCharField('email', nullable: true),
      OdooDateTimeField('create_date', nullable: true),
      OdooDateTimeField('write_date', nullable: true),
      OdooIntegerField('create_uid', nullable: true),
      OdooIntegerField('write_uid', nullable: true),
    ], ResCompanyHelper.fromJson);
  }
}
