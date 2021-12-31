import 'dart:async';
import 'package:bookstore/shared/validation.dart';
import 'package:rxdart/subjects.dart';
import 'package:bookstore/base/base_bloc.dart';
import 'package:bookstore/base/base_event.dart';
import 'package:bookstore/event/singin_event.dart';
import 'package:bookstore/data/repo/user_repo.dart';
import 'package:bookstore/shared/model/user_data.dart';
import 'package:rxdart/rxdart.dart';

class SignInBloc extends BaseBloc {
  late UserRepo _userRepo;
  BehaviorSubject<String> _txtPhoneSubject = BehaviorSubject<String>();
  BehaviorSubject<String> _txtPasswordSubject = BehaviorSubject<String>();
  BehaviorSubject<bool> _btnSignInSubject = BehaviorSubject<bool>();

  SignInBloc({required UserRepo userRepo}) {
    this._userRepo = userRepo;
    validateLoginButton();
  }

  Sink<String> get txtPhoneSubjectSink => _txtPhoneSubject.sink;
  Stream<String?> get txtPhoneSubjectStream =>
      _txtPhoneSubject.stream.transform<String?>(_txtPhoneTransform);

  Sink<String> get txtPasswordSubjectSink => _txtPasswordSubject.sink;
  Stream<String?> get txtPasswordSubjectStream =>
      _txtPasswordSubject.stream.transform<String?>(_txtPasswordTransform);

  Sink<bool> get btnSignInSubjectSink => _btnSignInSubject.sink;
  Stream<bool> get btnSignInSubjectStream => _btnSignInSubject.stream;

  final StreamTransformer<String, String?> _txtPhoneTransform =
      StreamTransformer<String, String?>.fromHandlers(
    handleData: (data, sink) {
      if (Validation.isPhone(data)) {
        sink.add(null);

        return;
      }

      sink.add('Phone is invalid.');
    },
  );

  final StreamTransformer<String, String?> _txtPasswordTransform =
      StreamTransformer.fromHandlers(
    handleData: (data, sink) {
      if (Validation.isPassValid(data)) {
        sink.add(null);

        return;
      }

      sink.add('Password too short.');
    },
  );

  validateLoginButton() {
    CombineLatestStream.combine2<String, String, bool>(
      _txtPhoneSubject,
      _txtPasswordSubject,
      (txtPhone, txtPassword) =>
          Validation.isPhone(txtPhone) && Validation.isPassValid(txtPassword),
    ).listen((isEnable) {
      btnSignInSubjectSink.add(isEnable);
    });
  }

  @override
  void dispatchEvent(BaseEvent event) {
    switch (event.runtimeType) {
      case SignInEvent:
        _signIn(event as SignInEvent);
        break;
      default:
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  _signIn(SignInEvent event) {
    _userRepo.signIn(event.phone, event.password).then(
      (UserData user) {
        print(user.displayName);
        print(user.token);
      },
      onError: (e) {
        print(e);
      },
    );
  }
}