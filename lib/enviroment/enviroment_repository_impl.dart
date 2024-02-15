import 'package:z1racing/enviroment/enviroment_repository.dart';

class EnviromentRepositoryImpl implements EnviromentRepository {
  static final EnviromentRepositoryImpl _instance =
      EnviromentRepositoryImpl._internal();

  factory EnviromentRepositoryImpl() {
    return _instance;
  }

  EnviromentRepositoryImpl._internal();

  @override
  List<int> get acceptedVersions => [1];
}
