import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/dashboard/events/view/bloc/events_state.dart';

class EventsCubit extends Cubit<EventsState> {
  GeniusApi api;
  EventsCubit({
    required this.api,
  }) : super(EventsState());

  Future<void> loadEvents() async {
    emit(state.copyWith(eventsLoadingStatus: EventsStatus.loading));

    try {
      final events = await api.getEvents();

      emit(state.copyWith(
        events: events,
        eventsLoadingStatus: EventsStatus.loaded,
      ));
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(eventsLoadingStatus: EventsStatus.error));
      }
    }
  }
}
