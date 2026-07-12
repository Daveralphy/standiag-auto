// Reference data for OBD-II Diagnostic Trouble Code (DTC) descriptions.
// These are standardized SAE J2012 generic codes (the "P0xxx" codes every
// vehicle manufacturer implements) — public, standardized reference data,
// not fabricated content. A code without a known description still displays
// as-is; this table only adds a human-readable label where one is known.

class DtcReferenceData {
  DtcReferenceData._();

  static const Map<String, String> descriptions = {
    'P0100': 'Mass or Volume Air Flow Circuit Malfunction',
    'P0101': 'Mass or Volume Air Flow Circuit Range/Performance',
    'P0110': 'Intake Air Temperature Circuit Malfunction',
    'P0115': 'Engine Coolant Temperature Circuit Malfunction',
    'P0120': 'Throttle/Pedal Position Sensor Circuit Malfunction',
    'P0128': 'Coolant Thermostat Below Regulating Temperature',
    'P0130': 'O2 Sensor Circuit Malfunction (Bank 1 Sensor 1)',
    'P0133': 'O2 Sensor Circuit Slow Response (Bank 1 Sensor 1)',
    'P0171': 'System Too Lean (Bank 1)',
    'P0172': 'System Too Rich (Bank 1)',
    'P0174': 'System Too Lean (Bank 2)',
    'P0175': 'System Too Rich (Bank 2)',
    'P0200': 'Injector Circuit Malfunction',
    'P0217': 'Engine Overtemperature Condition',
    'P0300': 'Random/Multiple Cylinder Misfire Detected',
    'P0301': 'Cylinder 1 Misfire Detected',
    'P0302': 'Cylinder 2 Misfire Detected',
    'P0303': 'Cylinder 3 Misfire Detected',
    'P0304': 'Cylinder 4 Misfire Detected',
    'P0305': 'Cylinder 5 Misfire Detected',
    'P0306': 'Cylinder 6 Misfire Detected',
    'P0325': 'Knock Sensor Circuit Malfunction',
    'P0335': 'Crankshaft Position Sensor Circuit Malfunction',
    'P0340': 'Camshaft Position Sensor Circuit Malfunction',
    'P0401': 'Exhaust Gas Recirculation Flow Insufficient',
    'P0420': 'Catalyst System Efficiency Below Threshold (Bank 1)',
    'P0430': 'Catalyst System Efficiency Below Threshold (Bank 2)',
    'P0440': 'Evaporative Emission Control System Malfunction',
    'P0442': 'Evaporative Emission System Leak Detected (small leak)',
    'P0455': 'Evaporative Emission System Leak Detected (large leak)',
    'P0500': 'Vehicle Speed Sensor Malfunction',
    'P0505': 'Idle Control System Malfunction',
    'P0601': 'Internal Control Module Memory Check Sum Error',
    'P0700': 'Transmission Control System Malfunction',
    'P0715': 'Input/Turbine Speed Sensor Circuit Malfunction',
    'P0740': 'Torque Converter Clutch Circuit Malfunction',
    'C0035': 'Left Front Wheel Speed Sensor Circuit Malfunction',
    'C0040': 'Right Front Wheel Speed Sensor Circuit Malfunction',
    'B0001': 'Driver Frontal Stage 1 Deployment Control',
    'U0100': 'Lost Communication with ECM/PCM',
    'U0101': 'Lost Communication with TCM',
  };

  /// Returns a human-readable description for a DTC like "P0301", or the
  /// bare code itself if it isn't in the known reference table.
  static String describe(String code) => descriptions[code] ?? code;
}
