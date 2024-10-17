abstract class Failure{
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure{
  const ServerFailure(String message):super(message);
}
class ConnectionFailure extends Failure{
  const ConnectionFailure(String message):super(message);
}
class DatabaseFailure extends Failure{
  const DatabaseFailure(String message):super(message);
}
class signInFaliure extends Failure{
  const signInFaliure(String message):super(message);
}
class NoLocaleStoredLocally extends Failure{
  const NoLocaleStoredLocally(String message):super(message);
}
class SignOutFailure extends Failure{
  const SignOutFailure(String message):super(message);
}
class deleteAccountFailure extends Failure{
  const deleteAccountFailure(String message):super(message);
}
class incompatibleProblems extends Failure{
  const incompatibleProblems(String message):super(message);

}
class emailSentFailure extends Failure{
  const emailSentFailure(String message):super(message);

}
class notificationFailure extends Failure{
  const notificationFailure(String message):super(message);
}