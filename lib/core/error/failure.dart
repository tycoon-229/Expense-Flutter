abstract class Failure {
  final String message;
  Failure(this.message);
}

class CacheFailure extends Failure {
  CacheFailure(super.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}
