// ignore_for_file: prefer_constructors_over_static_methods

import 'package:z1racing/enviroment/enviroment_repository_impl.dart';
import 'package:z1racing/enviroment/enviroment_repository_mock.dart';

abstract class EnviromentRepository {
  static final EnviromentRepository _instanceImpl = EnviromentRepositoryImpl();
  static final EnviromentRepository _instanceMock = EnviromentRepositoryMock();

  static EnviromentRepository? _instance;

  factory EnviromentRepository._({bool useMock = false}) {
    if (useMock) {
      _instance = _instanceMock;
    } else {
      _instance = _instanceImpl;
    }

    return _instance!;
  }

  static EnviromentRepository get instance =>
      _instance ?? EnviromentRepository._();

  static EnviromentRepository get initInMockMode =>
      _instance ?? EnviromentRepository._(useMock: true);

  List<int> get acceptedVersions => [0];
}
