class ServiceTemplates {
  static const List<String> minorService = [
    'Engine Oil Filled',
    'Oil Filter Replaced',
    'Air Filter Checked/Replaced',
    'Coolant Level Checked',
    'Brake Fluid Level Checked',
    'Power Steering Fluid Checked',
    'Windscreen Washer Fluid Top-up',
    'Battery Terminals Checked',
    'Tyre Pressure Checked (inc. Spare)',
    'Lights & Indicators Checked',
    'Wiper Blades Checked',
  ];

  static const List<String> majorService = [
    ...minorService,
    'Spark Plugs Replaced',
    'Fuel Filter Replaced',
    'Cabin Filter Replaced',
    'Serpentine Belt Checked',
    'Timing Belt/Chain Checked',
    'Brake Pads & Discs Checked',
    'Brake Lines & Hoses Inspected',
    'Suspension - Shocks/Struts Checked',
    'Suspension - Control Arms Checked',
    'Steering - Tie Rods/Rack Checked',
    'Drive Shafts/CV Boots Checked',
    'Exhaust System Checked',
    'Transmission Fluid Checked/Changed',
    'Differential Oil Checked/Changed',
    'Coolant Flush & Replace',
  ];

  static const List<String> diagnosticCheck = [
    'OBD-II Scan Performed',
    'Error Codes Recorded',
    'Live Data Analysis',
    'Component Actuation Tests',
    'Visual Inspection of Wiring',
    'Fuse Box Inspection',
    'Battery Load Test',
    'Alternator Output Test',
  ];

  static List<String> getTemplateForType(String serviceType) {
    // Normalize string to match templates
    final lowerType = serviceType.toLowerCase();
    if (lowerType.contains('major')) return majorService;
    if (lowerType.contains('minor')) return minorService;
    if (lowerType.contains('diagnostic')) return diagnosticCheck;

    // Default fallback
    return ['General Inspection', 'Report Defects'];
  }
}
