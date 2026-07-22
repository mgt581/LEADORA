import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/crm_models.dart';

final crmRepositoryProvider = ChangeNotifierProvider<CrmRepository>((ref) => CrmRepository.seeded());

class CrmRepository extends ChangeNotifier {
  static int _nextId = 0;
  CrmRepository(this.leads, this.contacts);

  final List<Lead> leads;
  final List<Contact> contacts;

  factory CrmRepository.seeded() => CrmRepository(
        [
          Lead(id: 'lead-1', name: 'Sarah Johnson', email: 'sarah@designco.com', company: 'Design Co.', status: LeadStatus.newLead, source: 'Website', createdAt: DateTime.now()),
          Lead(id: 'lead-2', name: 'David Williams', email: 'david@techflow.com', company: 'TechFlow', status: LeadStatus.contacted, source: 'LinkedIn', createdAt: DateTime.now()),
          Lead(id: 'lead-3', name: 'James Brown', email: 'james@marketplus.com', company: 'MarketPlus', status: LeadStatus.qualified, source: 'Referral', createdAt: DateTime.now()),
        ],
        [
          const Contact(id: 'contact-1', name: 'Sarah Johnson', title: 'CEO', company: 'Design Co.', email: 'sarah@designco.com', phone: '+44 7700 900123'),
          const Contact(id: 'contact-2', name: 'David Williams', title: 'CTO', company: 'TechFlow', email: 'david@techflow.com', phone: '+44 7700 900456'),
        ],
      );

  void addLead({required String name, required String email, required String company}) {
    leads.insert(0, Lead(id: 'lead-${_nextId++}', name: name, email: email, company: company, status: LeadStatus.newLead, source: 'Manual', createdAt: DateTime.now()));
    notifyListeners();
  }

  void addContact({required String name, required String email, required String company}) {
    contacts.insert(0, Contact(id: 'contact-${_nextId++}', name: name, title: 'New contact', company: company, email: email, phone: '—'));
    notifyListeners();
  }
}
