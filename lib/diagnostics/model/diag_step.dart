// Đảm bảo KHÔNG có từ khóa `abstract` ở đây.
enum DiagStatus { pending, running, passed, failed, skipped }
enum DiagKind { auto, manual }

class DiagStep {
  final String code;
  final String title;
  final DiagKind kind;
  final Future<bool> Function()? run;       // bước auto
  final Future<bool> Function()? interact;  // bước manual
  DiagStatus status;
  String? note;

  DiagStep({
    required this.code,
    required this.title,
    required this.kind,
    this.run,
    this.interact,
    this.status = DiagStatus.pending,
    this.note,
  });
}
