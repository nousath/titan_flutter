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
        var activeWalletFileName = await AppCache.getValue<String>(
          PrefsKey.ACTIVATED_WALLET_FILE_NAME,
        );

        if (activeWalletFileName != null) {
          await AppCache.saveValue<String>(
              '${activeWalletFileName}_${PrefsKey.AUTH_CONFIG}',
              json.encode(event.authConfigModel.toJSON()));
        }

        yield UpdateAuthConfigState(authConfigModel: event.authConfigModel);
      }
    } else if (event is SetBioAuthEvent) {
      if (authConfigModel != null) {
        if (authConfigModel.availableBiometricTypes
            .contains(BiometricType.face)) {
          authConfigModel.useFace = event.value;
        } else if (authConfigModel.availableBiometricTypes
            .contains(BiometricType.fingerprint)) {
          authConfigModel.useFingerprint = event.value;
        }
        var activeWalletFileName = await AppCache.getValue<String>(
          PrefsKey.ACTIVATED_WALLET_FILE_NAME,
        );

        if (activeWalletFileName != null) {
          await AppCache.saveValue<String>(
              '${activeWalletFileName}_${PrefsKey.AUTH_CONFIG}',
              json.encode(authConfigModel.toJSON()));
        }

        yield UpdateAuthConfigState(authConfigModel: authConfigModel);
      }
    }
  }
}
