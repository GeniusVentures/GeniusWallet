import 'dart:convert';
import 'dart:io';

import 'package:squidrouter/squidrouter.dart';

/// A same-chain swap on Base: gas, but no fees at all.
const sameChainRoute = 'route_response.json';

/// Base to Ethereum: a bridge fee on top of gas.
const crossChainRoute = 'route_response_cross_chain.json';

String rawRouteFixture(String name) =>
    File('test/squid_router/fixtures/$name').readAsStringSync();

/// A recorded real `/v2/route` body, through the generated client. No
/// network and no credential, so every plan in the phase can test on it.
RouteResponseData loadRouteFixture(String name) =>
    standardSerializers.deserializeWith(
      RouteResponseData.serializer,
      jsonDecode(rawRouteFixture(name)) as Map<String, dynamic>,
    )!;
