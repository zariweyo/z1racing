import 'package:z1racing/enviroment/enviroment_repository.dart';

class EnviromentRepositoryMock implements EnviromentRepository {
  static final EnviromentRepositoryMock _instance =
      EnviromentRepositoryMock._internal();

  factory EnviromentRepositoryMock() {
    return _instance;
  }

  EnviromentRepositoryMock._internal();

  @override
  List<int> get acceptedVersions => [1];
}
