import 'dart:js_interop';
import 'dart:js_interop_unsafe';

void clearUrlQuery() {
  final location = globalContext['location'] as JSObject;
  final base = (location['origin'] as JSString).toDart +
      (location['pathname'] as JSString).toDart;
  final history = globalContext['history'] as JSObject;
  history.callMethod('replaceState'.toJS, null, ''.toJS, base.toJS);
}
