import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/src/components/auth/model.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import './bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  @override
  AuthState get initialState => InitialAuthState();

  AuthConfigModel authConfigModel;

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    // TODO: Add Logic
    if (event is UpdateAuthStatusEvent) {
      if (event.authorized != null) {
        yield UpdateAuthStatusState(authorized: event.authorized);
      }
    } else if (event is UpdateAuthConfigEvent) {
      if (event.authConfigModel != null) {
        authConfigModel = event.authConfigModel;

        await AppCache.saveValue<String>('${PrefsKey.AUTH_CONFIG}',
            json.encode(event.authConfigModel.toJSON()));

        yield UpdateAuthConfigState(authConfigModel: event.authConfigModel);
      }
    } else if (event is SetBioAuthEvent) {
      if (authConfigModel != null) {
        if (authConfigModel.availableBiometricTypes
            .contains(BiometricType.face)) {
          authConfigModel.useFace = event.value;
        }
        if (authConfigModel.availableBiometricTypes
            .contains(BiometricType.fingerprint)) {
          authConfigModel.useFingerprint = event.value;
        }

        if (authConfigModel.availableBiometricTypes
            .contains(BiometricType.iris)) {
          authConfigModel.useFingerprint = event.value;
        }

        authConfigModel.lastBioAuthTime = DateTime.now().millisecondsSinceEpoch;

        print('SetBioAuthEvent: ${authConfigModel.toJSON()}');
        await AppCache.saveValue<String>(
            '${PrefsKey.AUTH_CONFIG}',
            json.encode(
              authConfigModel.toJSON(),
            ));

        yield UpdateAuthConfigState(authConfigModel: authConfigModel);
      }
    }
  }
}
