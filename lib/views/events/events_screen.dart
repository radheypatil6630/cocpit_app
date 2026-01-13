import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import 'event_card.dart';
import 'event_details_screen.dart';
import 'create_event_screen.dart';
import '../bottom_navigation.dart';
import '../../widgets/app_top_bar.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();

  // State
  List<EventModel> allEvents = [
    EventModel(
      title: 'Product Management Summit 2025',
      description: 'The ultimate gathering for product leaders and managers.',
      location: 'New York, NY',
      image: 'lib/images/event1.jpg',
      category: 'Summit',
      eventType: 'In-person',
      startDate: '25 OCT',
      startTime: '10:00',
      endDate: '25 OCT',
      endTime: '18:00',
      isFree: false,
      totalRegistrations: 1250,
    ),
    EventModel(
      title: 'Tech Mixer & Networking',
      description: 'A networking mixer for designers and developers.',
      location: 'San Francisco, CA',
      image: 'lib/images/event2.jpg',
      category: 'Network',
      eventType: 'In-person',
      startDate: '12 NOV',
      startTime: '18:00',
      endDate: '12 NOV',
      endTime: '21:00',
      isFree: false,
      totalRegistrations: 450,
    ),
    EventModel(
      title: 'Web Design Workshop',
      description: 'Hands-on session on building modern user interfaces.',
      location: 'Online',
      image: 'lib/images/post1.jpg',
      category: 'Workshop',
      eventType: 'Online',
      startDate: '05 DEC',
      startTime: '14:00',
      endDate: '05 DEC',
      endTime: '17:00',
      isFree: true,
      totalRegistrations: 800,
    ),
  ];

  List<String> registeredEventTitles = [];
  List<String> savedEventTitles = [];

  // Filters
  bool fOnline = false;
  bool fInPerson = false;
  bool fFree = false;
  bool fPaid = false;
  Map<String, bool> fCategories = {
    'Tech': false,
    'Business': false,
    'Networking': false,
    'Workshop': false,
    'Summit': false,
    'Conference': false,
    'Masterclass': false,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Refresh content when tab changes
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<EventModel> get _filteredEvents {
    return allEvents.where((e) {
      final query = _searchCtrl.text.toLowerCase();
      final matchesSearch = e.title.toLowerCase().contains(query) || e.description.toLowerCase().contains(query);
      final matchesType = (!fOnline && !fInPerson) || (fOnline && e.eventType == 'Online') || (fInPerson && e.eventType == 'In-person');
      final matchesPrice = (!fFree && !fPaid) || (fFree && e.isFree) || (fPaid && !e.isFree);
      final activeCats = fCategories.entries.where((c) => c.value).map((c) => c.key).toList();
      final matchesCategory = activeCats.isEmpty || activeCats.contains(e.category);
      return matchesSearch && matchesType && matchesPrice && matchesCategory;
    }).toList();
  }

  void _onEventTap(EventModel event) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailsScreen(
          event: event,
          isRegistered: registeredEventTitles.contains(event.title),
          isSaved: savedEventTitles.contains(event.title),
          onSaveToggle: (saved) {
            _toggleSave(event.title);
          },
          onRegister: () {
            setState(() {
              if (!registeredEventTitles.contains(event.title)) {
                registeredEventTitles.add(event.title);
                event.totalRegistrations++;
              }
            });
          },
          onCancelRegistration: () {
            setState(() {
              registeredEventTitles.remove(event.title);
              event.totalRegistrations--;
            });
          },
        ),
      ),
    );
  }

  void _toggleSave(String title) {
    setState(() {
      if (savedEventTitles.contains(title)) {
        savedEventTitles.remove(title);
      } else {
        savedEventTitles.add(title);
      }
    });
  }

  void _openFilterSheet() {
    bool tOnline = fOnline;
    bool tInPerson = fInPerson;
    bool tFree = fFree;
    bool tPaid = fPaid;
    Map<String, bool> tCats = Map.from(fCategories);

    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSS) => DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (_, controller) => Container(
            decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    controller: controller,
                    children: [
                      Text('Filters', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 30),
                      _fSection(theme, 'Event Type'),
                      _fItem(theme, 'Online', tOnline, (v) => setSS(() => tOnline = v)),
                      _fItem(theme, 'In-person', tInPerson, (v) => setSS(() => tInPerson = v)),
                      const SizedBox(height: 20),
                      _fSection(theme, 'Price'),
                      _fItem(theme, 'Free', tFree, (v) => setSS(() => tFree = v)),
                      _fItem(theme, 'Paid', tPaid, (v) => setSS(() => tPaid = v)),
                      const SizedBox(height: 20),
                      _fSection(theme, 'Category'),
                      ...tCats.keys.map((cat) => _fItem(theme, cat, tCats[cat]!, (v) => setSS(() => tCats[cat] = v))),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setSS(() {
                              tOnline = false; tInPerson = false; tFree = false; tPaid = false;
                              tCats.updateAll((k, v) => false);
                            });
                          },
                          style: OutlinedButton.styleFrom(side: BorderSide(color: theme.dividerColor), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: Text('Reset', style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() { fOnline = tOnline; fInPerson = tInPerson; fFree = tFree; fPaid = tPaid; fCategories = tCats; });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: Text('Apply Filters', style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fSection(ThemeData theme, String t) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(t, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)));
  Widget _fItem(ThemeData theme, String l, bool s, Function(bool) onTap) => GestureDetector(
    onTap: () => onTap(!s),
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(width: 22, height: 22, decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: s ? theme.primaryColor : theme.dividerColor, width: 2), color: s ? theme.primaryColor : Colors.transparent), child: s ? Icon(Icons.check, size: 16, color: theme.colorScheme.onPrimary) : null),
          const SizedBox(width: 14),
          Text(l, style: theme.textTheme.bodyLarge),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppTopBar(
        searchType: SearchType.events,
        controller: _searchCtrl,
        onChanged: (v) => setState(() {}),
        onFilterTap: _openFilterSheet,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            _buildTabs(theme),
            _buildActiveTabContent(theme),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 3),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _createEventButton(theme),
        ],
      ),
    );
  }

  Widget _createEventButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withValues(alpha: 0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () async {
          final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEventScreen()));
          if (res != null) {
            setState(() {
              allEvents.add((res as EventModel).copyWith(createdByMe: true));
              _tabController.index = 3;
            });
          }
        },
        icon: Icon(Icons.add, color: theme.colorScheme.onPrimary, size: 14),
        label: Text('Create Event', style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildTabs(ThemeData theme) {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      indicatorColor: theme.primaryColor,
      indicatorWeight: 3,
      labelColor: theme.primaryColor,
      unselectedLabelColor: theme.textTheme.bodySmall?.color,
      dividerColor: theme.dividerColor,
      labelPadding: const EdgeInsets.symmetric(horizontal: 20),
      labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      tabs: const [
        Tab(text: 'Discover'),
        Tab(text: 'Registered'),
        Tab(text: 'Saved'),
        Tab(text: 'My Events'),
      ],
    );
  }

  Widget _buildActiveTabContent(ThemeData theme) {
    List<EventModel> eventsToShow = [];
    bool showSuggested = _tabController.index == 0;

    switch (_tabController.index) {
      case 0:
        eventsToShow = _filteredEvents;
        break;
      case 1:
        eventsToShow = allEvents.where((e) => registeredEventTitles.contains(e.title)).toList();
        break;
      case 2:
        eventsToShow = allEvents.where((e) => savedEventTitles.contains(e.title)).toList();
        break;
      case 3:
        eventsToShow = allEvents.where((e) => e.createdByMe).toList();
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSuggested) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
            child: Text(
              'Suggested for you',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          _buildSuggestedSection(theme),
        ],
        const SizedBox(height: 24),
        _evList(theme, eventsToShow, isMy: _tabController.index == 3),
      ],
    );
  }

  Widget _buildSuggestedSection(ThemeData theme) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: allEvents.length,
        itemBuilder: (context, index) => _suggestedCard(theme, allEvents[index]),
      ),
    );
  }

  Widget _suggestedCard(ThemeData theme, EventModel event) {
    final colorScheme = theme.colorScheme;
    return GestureDetector(
      onTap: () => _onEventTap(event),
      child: Container(
        width: 260,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: AssetImage(event.image),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Text(
                    event.category,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              if (!event.isFree)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '\$50',
                      style: TextStyle(color: colorScheme.onPrimary, fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, height: 1.1),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.white60),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white60, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _evList(ThemeData theme, List<EventModel> events, {bool isMy = false}) {
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Text('No events found', style: theme.textTheme.bodyLarge?.copyWith(color: theme.textTheme.bodySmall?.color)),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: events.length,
      itemBuilder: (context, i) => EventCard(
        event: events[i],
        isMyEvent: i % 2 == 0 && isMy, // Mock logic for my event
        isRegistered: registeredEventTitles.contains(events[i].title),
        isSaved: savedEventTitles.contains(events[i].title),
        onSaveToggle: () => _toggleSave(events[i].title),
        onTap: () => _onEventTap(events[i]),
      ),
    );
  }
}
