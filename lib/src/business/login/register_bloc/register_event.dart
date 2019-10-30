import 'package:titan/src/basic/bloc/submit_bloc/bloc.dart';

abstract class RegisterEvent {
  const RegisterEvent();
}

class Register extends RegisterEvent {
  String email;
  String password;
  String fundPassword;
  String invitationCode;
  int verificationCode;

  Register(this.email, this.password, this.fundPassword, this.invitationCode, this.verificationCode);
}

class ResetToInit extends RegisterEvent {}
