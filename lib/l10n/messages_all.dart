// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that looks up messages for specific locales by
// delegating to the appropriate library.

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
import 'package:intl/src/intl_helpers.dart';

import 'messages_en.dart' as messages_en;
import 'messages_it.dart' as messages_it;

typedef Future<dynamic> LibraryLoader();
Map<String, LibraryLoader> _deferredLibraries = <String, LibraryLoader>{
  'en': () => new Future<Null>.value(null),
  'it': () => new Future<Null>.value(null),
};

MessageLookupByLibrary _findExact(String localeName) {
  switch (localeName) {
    case 'en':
      return messages_en.messages;
    case 'it':
      return messages_it.messages;
    default:
      return null;
  }
}

/// User programs should call this before using [localeName] for messages.
Future<Null> initializeMessages(String localeName) {
  final LibraryLoader lib =
      _deferredLibraries[Intl.canonicalizedLocale(localeName)];
  final Future<bool> load = lib == null ? new Future<bool>.value(false) : lib();
  return load.then((dynamic _) {
    initializeInternalMessageLookup(() => new CompositeMessageLookup());
    messageLookup.addLocale(localeName, _findGeneratedMessagesFor);
  });
}

bool _messagesExistFor(String locale) {
  try {
    return _findExact(locale) != null;
  } catch (e) {
    print(e);
  }
  return false;
}

MessageLookupByLibrary _findGeneratedMessagesFor(String locale) {
  final String actualLocale = Intl.verifiedLocale(locale, _messagesExistFor,
      onFailure: (dynamic _) => null);
  if (actualLocale == null) return null;
  return _findExact(actualLocale);
}
