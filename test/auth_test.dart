import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_club/models/role.dart';
import 'package:nexus_club/models/app_user.dart';

void main() {
  group('Тестирование разграничения прав и ролей (Критерий 18)', () {
    test('1. Иерархия уровней ролей: gamer < operator < admin', () {
      expect(Role.gamer.level < Role.operator.level, true);
      expect(Role.operator.level < Role.admin.level, true);
    });

    test('2. Роль gamer имеет доступ только к уровню gamer', () {
      const gamerUser =
          AppUser(id: 3, username: 'p1', email: 'p@c.ru', role: Role.gamer);
      expect(gamerUser.role.level >= Role.gamer.level, true);
      expect(gamerUser.role.level >= Role.operator.level, false);
      expect(gamerUser.role.level >= Role.admin.level, false);
    });

    test('3. Роль operator имеет доступ к управлению ПК, но не к панели админа',
        () {
      const opUser =
          AppUser(id: 2, username: 'op', email: 'op@c.ru', role: Role.operator);
      expect(opUser.role.level >= Role.operator.level, true);
      expect(opUser.role.level >= Role.admin.level, false);
    });

    test('4. Роль admin обладает наивысшим уровнем доступа', () {
      const adminUser =
          AppUser(id: 1, username: 'adm', email: 'a@c.ru', role: Role.admin);
      expect(adminUser.role.level >= Role.gamer.level, true);
      expect(adminUser.role.level >= Role.operator.level, true);
      expect(adminUser.role.level >= Role.admin.level, true);
    });

    test('5. Корректный парсинг строковых ролей из ответа API', () {
      expect(Role.fromString('ADMIN'), Role.admin);
      expect(Role.fromString('operator'), Role.operator);
      expect(Role.fromString('unknown_role'), Role.gamer);
    });
  });
}
