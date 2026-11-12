import 'package:flutter/material.dart';
import '../models/hospital.dart';
import '../models/incident.dart';
import '../models/osm_place.dart';
import '../theme/app_colors.dart';

IconData incidentTypeIcon(IncidentType type) {
  switch (type) {
    case IncidentType.medical:
      return Icons.medical_services_rounded;
    case IncidentType.fire:
      return Icons.local_fire_department_rounded;
    case IncidentType.accident:
      return Icons.car_crash_rounded;
    case IncidentType.danger:
      return Icons.warning_rounded;
    case IncidentType.security:
      return Icons.shield_rounded;
    case IncidentType.other:
      return Icons.help_rounded;
  }
}

/// Each emergency type's own color (filled icon circles, selected card).
Color incidentTypeColor(IncidentType type) => switch (type) {
  IncidentType.medical => AppColors.serviceMedical,
  IncidentType.fire => AppColors.serviceFire,
  IncidentType.accident => AppColors.serviceAccident,
  IncidentType.danger => AppColors.serviceDanger,
  IncidentType.security => AppColors.servicePolice,
  IncidentType.other => AppColors.serviceOther,
};

String incidentTypeKey(IncidentType type) {
  switch (type) {
    case IncidentType.medical:
      return 'type_medical';
    case IncidentType.fire:
      return 'type_fire';
    case IncidentType.accident:
      return 'type_accident';
    case IncidentType.danger:
      return 'type_danger';
    case IncidentType.security:
      return 'type_security';
    case IncidentType.other:
      return 'type_other';
  }
}

String incidentStatusKey(IncidentStatus status) {
  switch (status) {
    case IncidentStatus.created:
      return 'status_created';
    case IncidentStatus.sent:
      return 'status_sent';
    case IncidentStatus.received:
      return 'status_received';
    case IncidentStatus.assigned:
      return 'status_assigned';
    case IncidentStatus.helpOnWay:
      return 'status_help_on_way';
    case IncidentStatus.assisted:
      return 'status_assisted';
    case IncidentStatus.closed:
      return 'status_closed';
    case IncidentStatus.cancelled:
      return 'status_cancelled';
  }
}

String incidentTypeDescKey(IncidentType type) {
  switch (type) {
    case IncidentType.medical:
      return 'type_medical_desc';
    case IncidentType.fire:
      return 'type_fire_desc';
    case IncidentType.accident:
      return 'type_accident_desc';
    case IncidentType.danger:
      return 'type_danger_desc';
    case IncidentType.security:
      return 'type_security_desc';
    case IncidentType.other:
      return 'type_other_desc';
  }
}

/// Groups the granular [IncidentStatus] values into the 3 broad buckets
/// shown as colored chips in History (Active / Completed / Cancelled).
Color incidentStatusColor(IncidentStatus status) {
  switch (status) {
    case IncidentStatus.cancelled:
      return AppColors.dangerRed;
    case IncidentStatus.assisted:
    case IncidentStatus.closed:
      return AppColors.success;
    case IncidentStatus.created:
    case IncidentStatus.sent:
    case IncidentStatus.received:
    case IncidentStatus.assigned:
    case IncidentStatus.helpOnWay:
      return AppColors.primaryBlue;
  }
}

Color congestionColor(CongestionLevel level) {
  switch (level) {
    case CongestionLevel.low:
      return AppColors.congestionLow;
    case CongestionLevel.moderate:
      return AppColors.congestionModerate;
    case CongestionLevel.high:
      return AppColors.congestionHigh;
  }
}

String hospitalCategoryKey(HospitalCategory category) {
  switch (category) {
    case HospitalCategory.hospital:
      return 'hospitals_category_hospital';
    case HospitalCategory.clinic:
      return 'hospitals_category_clinic';
  }
}

String congestionKey(CongestionLevel level) {
  switch (level) {
    case CongestionLevel.low:
      return 'hospitals_congestion_low';
    case CongestionLevel.moderate:
      return 'hospitals_congestion_moderate';
    case CongestionLevel.high:
      return 'hospitals_congestion_high';
  }
}

/// Maps an [OverpassHospitalService] failure code to a user-facing
/// translation key, explaining exactly why no real hospitals are shown.
String overpassErrorKey(String? errorKey) {
  switch (errorKey) {
    case 'no_results':
      return 'hospitals_overpass_error_no_results';
    case 'timeout':
      return 'hospitals_overpass_error_timeout';
    case 'server_error':
      return 'hospitals_overpass_error_server';
    default:
      return 'hospitals_overpass_error_network';
  }
}

/// Maps a [LocationService] failure code to a user-facing translation key.
String locationErrorKey(String? errorKey) {
  switch (errorKey) {
    case 'service_disabled':
      return 'hospitals_location_error_service_disabled';
    case 'permission_denied':
      return 'hospitals_location_error_permission_denied';
    case 'permission_denied_forever':
      return 'hospitals_location_error_permission_denied_forever';
    case 'timeout':
      return 'hospitals_location_error_timeout';
    default:
      return 'hospitals_location_error_unknown';
  }
}

IconData incidentStatusIcon(IncidentStatus status) {
  switch (status) {
    case IncidentStatus.created:
      return Icons.add_alert_rounded;
    case IncidentStatus.sent:
      return Icons.send_rounded;
    case IncidentStatus.received:
      return Icons.mark_email_read_rounded;
    case IncidentStatus.assigned:
      return Icons.assignment_ind_rounded;
    case IncidentStatus.helpOnWay:
      return Icons.local_shipping_rounded;
    case IncidentStatus.assisted:
      return Icons.task_alt_rounded;
    case IncidentStatus.closed:
      return Icons.lock_rounded;
    case IncidentStatus.cancelled:
      return Icons.cancel_rounded;
  }
}

String placeKindKey(OsmPlaceKind kind) {
  switch (kind) {
    case OsmPlaceKind.hospital:
      return 'maps_kind_hospital';
    case OsmPlaceKind.clinic:
      return 'maps_kind_clinic';
    case OsmPlaceKind.police:
      return 'maps_kind_police';
    case OsmPlaceKind.fireStation:
      return 'maps_kind_fire';
    case OsmPlaceKind.pharmacy:
      return 'maps_kind_pharmacy';
  }
}

IconData placeKindIcon(OsmPlaceKind kind) {
  switch (kind) {
    case OsmPlaceKind.hospital:
      return Icons.local_hospital_rounded;
    case OsmPlaceKind.clinic:
      return Icons.medical_services_rounded;
    case OsmPlaceKind.police:
      return Icons.local_police_rounded;
    case OsmPlaceKind.fireStation:
      return Icons.local_fire_department_rounded;
    case OsmPlaceKind.pharmacy:
      return Icons.local_pharmacy_rounded;
  }
}

Color placeKindColor(OsmPlaceKind kind) {
  switch (kind) {
    case OsmPlaceKind.hospital:
    case OsmPlaceKind.clinic:
      return AppColors.dangerRed;
    case OsmPlaceKind.police:
      return AppColors.primaryBlue;
    case OsmPlaceKind.fireStation:
      return AppColors.warning;
    case OsmPlaceKind.pharmacy:
      return AppColors.success;
  }
}
