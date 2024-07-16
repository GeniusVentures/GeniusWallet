# Creating a new model for use in a service to your flutter application.

Create a scaffold of your class following this [article](https://pub.dev/packages/freezed) or the example below. <br/>

```

    import 'package:freezed_annotation/freezed_annotation.dart';

    // These 2 parts need to be added after generation
    part 'events.freezed.dart';
    part 'events.g.dart';

    @freezed
    class Events with _$Events {
    const factory Events(
        {String? location,
        String? body,
        String? weekDay,
        String? date}) = _Events;

    factory Events.fromJson(Map<String, Object?> json) => _$EventsFromJson(json);
    }

```

<br/>

Now run the following command within `GeniusWallet/packages/genius_api` - `flutter packages pub run build_runner build`

This will generate:

- `events.freezed.dart`
- `events.g.dart`

Complete your model by adding these imports to include the generate files

```
    part 'events.freezed.dart';
    part 'events.g.dart';
```
