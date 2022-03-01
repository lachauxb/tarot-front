import 'package:flushbar/flushbar.dart';
import 'package:origin/config/auto_loader.dart';

/** USAGE
    Toast(
      context: context,
      message: 'Liste rafraîchie !',
      type: ToastType.SUCCESS,
    ).show();
 **/
/// Permet d'afficher facilement une information au bas de l'application
class Toast{

  Flushbar _flushbar;
  bool isShown = false;

  final BuildContext context;
  final String title;
  final String message;
  final ToastType type;
  final Duration duration;
  final bool flag;
  final Function onTap;
  final Widget mainButton;

  Toast({@required this.context, @required this.message, @required this.type, this.title, this.duration, this.flag = true, this.onTap, this.mainButton}) : assert(context != null && message != null && message.isNotEmpty && type != null);

  static const Map<ToastType, IconData> icons = {
    ToastType.INFO: Icons.info_outline,
    ToastType.ALERT: Icons.error_outline,
    ToastType.WARNING: Icons.warning,
    ToastType.SUCCESS: Icons.check_circle_outline
  };
  static const Map<ToastType, Color> colors = {
    ToastType.INFO: Colors.blue,
    ToastType.ALERT: Colors.red,
    ToastType.WARNING: Colors.orange,
    ToastType.SUCCESS: Colors.green
  };

  void show(){
    if(!isShown){
      _flushbar = Flushbar(
          title: this.title != null && this.title.isNotEmpty ? this.title : null,
          message: this.message,
          icon: Icon(
            icons[this.type],
            size: 20,
            color: colors[this.type],
          ),
          leftBarIndicatorColor: this.flag ? colors[this.type] : null,
          duration: this.duration, //!= null ? this.duration : Duration(seconds: 2),
          onTap: this.onTap,
          isDismissible: true,
          onStatusChanged: (FlushbarStatus status){
            if(status == FlushbarStatus.DISMISSED)
              isShown = false;
          },
          mainButton: mainButton,
      );
      _flushbar.show(context);
      isShown = true;
    }
  }

  bool isShowing(){
    return _flushbar != null && _flushbar.isShowing();
  }

  void dismiss(){
    if(isShown)
      _flushbar.dismiss();
  }

  static void alert(BuildContext context) {
    Toast(
        duration: const Duration(seconds: 2),
        context: context,
        message: "Une erreur est survenue.",
        type: ToastType.ALERT
    ).show();
  }

}

enum ToastType {
  ALERT,
  WARNING,
  INFO,
  SUCCESS
}