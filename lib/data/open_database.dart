import 'package:powersync/powersync.dart' show PowerSyncDatabase;

import 'open_database_stub.dart'
    if (dart.library.io) 'open_database_native.dart'
    if (dart.library.js_interop) 'open_database_web.dart' as impl;

/// Opens the PowerSync database using the platform-appropriate storage.
Future<PowerSyncDatabase> openPowerSyncDatabase() =>
    impl.openPowerSyncDatabase();
