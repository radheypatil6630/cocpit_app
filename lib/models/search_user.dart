class SearchUser {
  final String id;
  final String fullName;
  final String? headline;
  final String? avatarUrl;
  final String? accountType;

  SearchUser({
    required this.id,
    required this.fullName,
    this.headline,
    this.avatarUrl,
    this.accountType,
  });

  factory SearchUser.fromJson(Map<String, dynamic> json) {
    return SearchUser(
      id: json['id'],
      fullName: json['full_name'],
      headline: json['headline'],
      avatarUrl: json['avatar_url'],
      accountType: json['account_type'],
    );
  }
}
