abstract class Failure{
  final String message;
  Failure(this.message){
    print("Error Happen: "+message);
  }
}

class ServerFailure extends Failure{
   ServerFailure(String message):super(message);
}
class ConnectionFailure extends Failure{
   ConnectionFailure(String message):super(message);
}
class DatabaseFailure extends Failure{
   DatabaseFailure(String message):super(message);
}
class signInFaliure extends Failure{
   signInFaliure(String message):super(message);
}
class NoLocaleStoredLocally extends Failure{
   NoLocaleStoredLocally(String message):super(message);
}
class SignOutFailure extends Failure{
   SignOutFailure(String message):super(message);
}
class deleteAccountFailure extends Failure{
   deleteAccountFailure(String message):super(message);
}
class incompatibleProblems extends Failure{
   incompatibleProblems(String message):super(message);

}
class emailSentFailure extends Failure{
   emailSentFailure(String message):super(message);

}
class notificationFailure extends Failure{
   notificationFailure(String message):super(message);
}