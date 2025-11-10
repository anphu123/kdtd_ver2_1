/// Diagnostic Step Model
///
/// Represents a single diagnostic test step
class DiagnosticStep {
  final String id;
  final String code;
  final String title;
  final String? description;
  final DiagnosticType type;
  final DiagnosticStatus status;
  final String? note;
  final DateTime? executedAt;

  const DiagnosticStep({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    required this.type,
    this.status = DiagnosticStatus.pending,
    this.note,
    this.executedAt,
  });

  /// Create a copy with modified fields
  DiagnosticStep copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    DiagnosticType? type,
    DiagnosticStatus? status,
    String? note,
    DateTime? executedAt,
  }) {
    return DiagnosticStep(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      note: note ?? this.note,
      executedAt: executedAt ?? this.executedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'type': type.name,
      'status': status.name,
      'note': note,
      'executedAt': executedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory DiagnosticStep.fromJson(Map<String, dynamic> json) {
    return DiagnosticStep(
      id: json['id'] as String,
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: DiagnosticType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DiagnosticType.auto,
      ),
      status: DiagnosticStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DiagnosticStatus.pending,
      ),
      note: json['note'] as String?,
      executedAt: json['executedAt'] != null
          ? DateTime.parse(json['executedAt'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'DiagnosticStep(id: $id, code: $code, title: $title, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiagnosticStep && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Diagnostic Test Type
enum DiagnosticType {
  auto,   // Automated test
  manual, // Manual interaction required
}

/// Diagnostic Status
enum DiagnosticStatus {
  pending,  // Not yet executed
  running,  // Currently executing
  passed,   // Test passed
  failed,   // Test failed
  skipped,  // Test was skipped
}

