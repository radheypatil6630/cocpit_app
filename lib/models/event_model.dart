class EventModel {
  final String title;
  final String description;
  final String location;
  final String image;
  final String category;
  final String eventType; // Online / In-person
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;

  final bool isFree;
  final bool createdByMe;

  int totalRegistrations;
  int attendedCount;

  final String status; // Upcoming / Completed

  EventModel({
    required this.title,
    required this.description,
    required this.location,
    required this.image,
    required this.category,
    required this.eventType,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.isFree,
    this.createdByMe = false,
    this.totalRegistrations = 0,
    this.attendedCount = 0,
    this.status = 'Upcoming',
  });

  EventModel copyWith({
    bool? createdByMe,
  }) {
    return EventModel(
      title: title,
      description: description,
      location: location,
      image: image,
      category: category,
      eventType: eventType,
      startDate: startDate,
      startTime: startTime,
      endDate: endDate,
      endTime: endTime,
      isFree: isFree,
      createdByMe: createdByMe ?? this.createdByMe,
      totalRegistrations: totalRegistrations,
      attendedCount: attendedCount,
      status: status,
    );
  }
}
















/*class EventModel {
  final String title;
  final String date;
  final String location;
  final String attendees;
  final String image;
  final String description;
  final bool isFree;

  // 🔥 EVENT OWNERSHIP & ANALYTICS (UNCHANGED)
  final bool createdByMe;
  final int totalRegistrations;
  final int attendedCount;

  // 🔥 EVENT LIFECYCLE (UNCHANGED)
  final String status; // Upcoming | Completed

  // ✅ NEW – USER PARTICIPATION STATE
  final String participationStatus; // None | Registered | Attended

  EventModel({
    required this.title,
    required this.date,
    required this.location,
    required this.attendees,
    required this.image,
    required this.description,
    required this.isFree,

    // existing
    this.createdByMe = false,
    this.totalRegistrations = 0,
    this.attendedCount = 0,
    this.status = 'Upcoming',

    // new (safe default)
    this.participationStatus = 'None',
  });

  // 🔁 COPY (used when event is created / registered / attended)
  EventModel copyWith({
    bool? createdByMe,
    int? totalRegistrations,
    int? attendedCount,
    String? status,
    String? participationStatus,
  }) {
    return EventModel(
      title: title,
      date: date,
      location: location,
      attendees: attendees,
      image: image,
      description: description,
      isFree: isFree,

      createdByMe: createdByMe ?? this.createdByMe,
      totalRegistrations:
      totalRegistrations ?? this.totalRegistrations,
      attendedCount: attendedCount ?? this.attendedCount,
      status: status ?? this.status,
      participationStatus:
      participationStatus ?? this.participationStatus,
    );
  }
}*/
