// lib/features/home/domain/usecases/get_programs_use_case.dart

import '../entities/program_menu_entity.dart';
import '../repositories/home_repository.dart';

class GetProgramsUseCase {
  final HomeRepository repository;

  GetProgramsUseCase(this.repository);

  Future<List<ProgramMenuEntity>> call() async {
    return await repository.getPrograms();
  }
}