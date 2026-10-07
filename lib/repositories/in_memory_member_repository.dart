import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/member.dart';
import 'member_repository.dart';

class InMemoryMemberRepository implements MemberRepository {
  static const _storageKey = 'nexus_members_v2';
  final SharedPreferences? _prefs;
  List<Member> _members = [];

  static final List<Member> _initialSeed = [
    const Member(
      id: 1,
      nickname: 'ShadowSlayer',
      email: 'shadow@nexus.club',
      phone: '+7 (999) 111-22-33',
      card: LoyaltyCard(cardNumber: 'NEXUS-7701', discountPercent: 15, bonusBalance: 1250),
    ),
    const Member(
      id: 2,
      nickname: 'CyberViper',
      email: 'viper@nexus.club',
      phone: '+7 (999) 222-33-44',
      card: LoyaltyCard(cardNumber: 'NEXUS-7702', discountPercent: 10, bonusBalance: 800),
    ),
    const Member(
      id: 3,
      nickname: 'FrostBite',
      email: 'frost@nexus.club',
      phone: '+7 (999) 333-44-55',
      card: LoyaltyCard(cardNumber: 'NEXUS-7703', discountPercent: 5, bonusBalance: 300),
    ),
    const Member(
      id: 4,
      nickname: 'NeoMatrix',
      email: 'neo@nexus.club',
      phone: '+7 (999) 444-55-66',
      card: LoyaltyCard(cardNumber: 'NEXUS-7704', discountPercent: 20, bonusBalance: 3500),
    ),
  ];

  InMemoryMemberRepository([this._prefs]) {
    _restore();
  }

  void _restore() {
    final prefs = _prefs;
    if (prefs == null) {
      _members = List.from(_initialSeed);
      return;
    }
    final raw = prefs.getString(_storageKey);
    if (raw == null) {
      _members = List.from(_initialSeed);
      _persist();
      return;
    }
    try {
      final list = jsonDecode(raw) as List;
      _members = list.map((e) => Member.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      _members = List.from(_initialSeed);
      _persist();
    }
  }

  Future<void> _persist() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_storageKey, jsonEncode(_members.map((m) => m.toJson()).toList()));
  }

  @override
  Future<List<Member>> findAllActive() async {
    return _members.where((m) => !m.isDeleted).toList();
  }

  @override
  Future<Member?> findById(int id) async {
    try {
      return _members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> create(Member member) async {
    final newId = _members.isEmpty ? 1 : (_members.map((m) => m.id).reduce((a, b) => a > b ? a : b) + 1);
    _members.add(member.copyWith(nickname: member.nickname));
    _members[_members.length - 1] = Member(
      id: newId,
      nickname: member.nickname,
      email: member.email,
      phone: member.phone,
      card: member.card,
    );
    await _persist();
  }

  @override
  Future<void> update(Member member) async {
    final i = _members.indexWhere((m) => m.id == member.id);
    if (i != -1) {
      _members[i] = member;
      await _persist();
    }
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _members.indexWhere((m) => m.id == id);
    if (i != -1) {
      _members[i] = _members[i].copyWith(deletedAt: DateTime.now());
      await _persist();
    }
  }

  @override
  Future<void> hardDelete(int id) async {
    _members.removeWhere((m) => m.id == id);
    await _persist();
  }

  @override
  Future<void> restore(int id) async {
    final i = _members.indexWhere((m) => m.id == id);
    if (i != -1) {
      _members[i] = _members[i].copyWith(clearDeletedAt: true);
      await _persist();
    }
  }

  @override
  Future<bool> isEmailUnique(String email, {int? excludeId}) async {
    return !_members.any((m) => m.email.trim().toLowerCase() == email.trim().toLowerCase() && m.id != excludeId);
  }
}