enum LeadStatus { newLead, contacted, qualified, proposal, won, lost }

extension LeadStatusLabel on LeadStatus {
  String get label => switch (this) {
        LeadStatus.newLead => 'New',
        LeadStatus.contacted => 'Contacted',
        LeadStatus.qualified => 'Qualified',
        LeadStatus.proposal => 'Proposal',
        LeadStatus.won => 'Won',
        LeadStatus.lost => 'Lost',
      };
}

class Lead {
  final String id;
  final String name;
  final String email;
  final String company;
  final LeadStatus status;
  final String source;
  final DateTime createdAt;

  const Lead({required this.id, required this.name, required this.email, required this.company, required this.status, required this.source, required this.createdAt});
}

class Contact {
  final String id;
  final String name;
  final String title;
  final String company;
  final String email;
  final String phone;
  final bool active;

  const Contact({required this.id, required this.name, required this.title, required this.company, required this.email, required this.phone, this.active = true});
}
