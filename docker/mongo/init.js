// MongoDB initialisation script
// Creates indexes for the device_readings collection in both prod and test DBs.

['home_ideator', 'home_ideator_test'].forEach(function (dbName) {
  var targetDb = db.getSiblingDB(dbName);

  targetDb.createCollection('device_readings');

  // Compound index: per-user/device time-range queries
  targetDb.device_readings.createIndex(
    { user_uid: 1, device_id: 1, timestamp: -1 },
    { name: 'idx_user_device_ts' }
  );

  // Time-range only (CSV export spanning all devices)
  targetDb.device_readings.createIndex(
    { timestamp: -1 },
    { name: 'idx_timestamp' }
  );

  // Latest-reading lookup
  targetDb.device_readings.createIndex(
    { device_id: 1, timestamp: -1 },
    { name: 'idx_device_ts' }
  );

  print('✅ Indexes created for database: ' + dbName);
});