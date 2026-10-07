import '../models/member.dart';

abstract interface class MemberRepository {
  Future<List<Member>> findAllActive();
  Future<Member?> findById(int id);
  Future<void> create(Member member);
  Future<void> update(Member member);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<bool> isEmailUnique(String email, {int? excludeId});
}