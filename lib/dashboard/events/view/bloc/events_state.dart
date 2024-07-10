import 'package:genius_api/models/events.dart';

class EventsState {
  EventsStatus eventsLoadingStatus;

  List<Events> events;

  EventsState({
    this.eventsLoadingStatus = EventsStatus.initial,
    this.events = const [],
  });

  EventsState copyWith({
    EventsStatus? eventsLoadingStatus,
    List<Events>? events,
  }) {
    return EventsState(
      eventsLoadingStatus: eventsLoadingStatus ?? this.eventsLoadingStatus,
      events: events ?? this.events,
    );
  }
}

enum EventsStatus { initial, loading, loaded, error }
