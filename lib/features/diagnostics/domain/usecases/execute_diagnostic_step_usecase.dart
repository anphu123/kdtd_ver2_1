import '../entities/diagnostic_step.dart';
import '../repositories/diagnostics_repository.dart';

/// Execute Diagnostic Step Use Case
///
/// Handles the execution of a single diagnostic step
class ExecuteDiagnosticStepUseCase {
  final IDiagnosticsRepository _repository;

  const ExecuteDiagnosticStepUseCase(this._repository);

  /// Execute a specific diagnostic step
  Future<DiagnosticStep> call(DiagnosticStep step) async {
    try {
      // Update step to running status
      final runningStep = step.copyWith(
        status: DiagnosticStatus.running,
      );

      // Execute the step
      final result = await _repository.executeStep(runningStep);

      // Return result with execution timestamp
      return result.copyWith(
        executedAt: DateTime.now(),
      );
    } catch (e) {
      // Return failed step with error note
      return step.copyWith(
        status: DiagnosticStatus.failed,
        note: e.toString(),
        executedAt: DateTime.now(),
      );
    }
  }
}

