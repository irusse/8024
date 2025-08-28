part of 'otp_cubit.dart';

enum OTPTimerStateEnum { running, completed }

class OtpState {
  final OTPTimerStateEnum currentTimerState;

  OtpState({required this.currentTimerState});
}
