import 'package:bloc/bloc.dart';

part 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  OtpCubit() : super(OtpState(currentTimerState: OTPTimerStateEnum.running));

  void timerCompleted() {
    emit(OtpState(currentTimerState: OTPTimerStateEnum.completed));
  }

  void restartTimer() {
    emit(OtpState(currentTimerState: OTPTimerStateEnum.running));
  }
}
