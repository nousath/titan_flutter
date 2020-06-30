import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/auth/bloc/auth_bloc.dart';
import 'package:titan/src/components/auth/bloc/auth_state.dart';

import 'model.dart';

class AuthComponent extends StatelessWidget {
  final Widget child;

  AuthComponent({@required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (ctx) => AuthBloc(),
      child: _AuthManager(child: child),
    );
  }
}

class _AuthManager extends StatefulWidget {
  final Widget child;

  _AuthManager({@required this.child});

  @override
  State<StatefulWidget> createState() {
    return _AuthManagerState();
  }
}

class _AuthManagerState extends BaseState<_AuthManager> {
  AuthConfigModel authConfigModel;
  bool authorized;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is UpdateAuthStatusState) {
          authorized = state.authorized;
        } else if (state is UpdateAuthConfigState) {
          authConfigModel = state.authConfigModel;
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return AuthInheritedModel(
            authorized: authorized,
            authConfigModel: authConfigModel,
            child: widget.child,
          );
        },
      ),
    );
  }
}

enum AuthAspect { authorized, config }

class AuthInheritedModel extends InheritedModel<AuthAspect> {
  ///Store quick-auth config
  final AuthConfigModel authConfigModel;

  ///Only while in app
  final bool authorized;

  AuthInheritedModel({
    Key key,
    @required this.authorized,
    @required this.authConfigModel,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(AuthInheritedModel oldWidget) {
    return authConfigModel != oldWidget.authConfigModel ||
        authorized != oldWidget.authorized;
  }

  static AuthInheritedModel of(BuildContext context, {AuthAspect aspect}) {
    return InheritedModel.inheritFrom<AuthInheritedModel>(
      context,
      aspect: aspect,
    );
  }

  @override
  bool updateShouldNotifyDependent(
      AuthInheritedModel oldWidget, Set<AuthAspect> dependencies) {
    return authConfigModel != oldWidget.authConfigModel &&
            dependencies.contains(AuthAspect.config) ||
        authorized != oldWidget.authorized &&
            dependencies.contains(AuthAspect.authorized);
  }
}