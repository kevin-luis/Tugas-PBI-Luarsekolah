// lib/features/home/domain/usecases/get_programs_use_case.dart

import 'package:luarsekolah_app/features/home/domain/entities/program_menu_entity.dart';
import 'package:luarsekolah_app/features/home/domain/repositories/home_repository.dart';

class GetProgramsUseCase {
  final HomeRepository repository;

  GetProgramsUseCase(this.repository);

  Future<List<ProgramMenuEntity>> call() async {
    return await repository.getPrograms();
  }
}