enum MainServiceStateHome { home, race, loading, update }

abstract class MainServiceState {}

class MainServiceStateInitial extends MainServiceState {}

class MainServiceStatePage extends MainServiceState {
  final MainServiceStateHome stateHome;

  MainServiceStatePage({required this.stateHome});
}
