// ** AUTO LOADER ** //
import 'dart:math';

import 'package:origin/config/auto_loader.dart';
// ** PACKAGES ** //
// ** SERVICES ** //
import "package:origin/services/AuthenticationService.dart";
import "package:origin/services/UserService.dart";
// ** MODEL ** //
// ** OTHERS ** //

class LoginActivity extends StatefulWidget {
  LoginActivity({Key key}) : super(key: key);

  @override
  _LoginActivityState createState() => _LoginActivityState();
}

class _LoginActivityState extends State<LoginActivity> {

  final _formKey = GlobalKey<FormState>();

  final loginController = TextEditingController();
  final pwdController = TextEditingController();

  bool isButtonEnabled = false;
  bool requestInProgress = false;
  bool invalidLogin = false;
  String invalidLoginCause;

  bool saveLogin = false;

  //fonction de validation du champ password
  String loginValidation(String password){
    if(invalidLogin){
      invalidLogin = false;
      return invalidLoginCause;
    }
    return null;
  }

  //Fonction appelée par le bouton "Se connecter"
  void submit() async{
    //appel des fonctions de validation des champs
    if(_formKey.currentState.validate()) {
      _formKey.currentState.save();

      // si on demande à enregistrer l'identifiant, on l'enregistre
      if(saveLogin){
        LocalStorageHandler.putData("_registered_login_", loginController.text);
      }else{
        LocalStorageHandler.removeData("_registered_login_");
      }

      setState(() {
        //modification de l'apparence du bouton
        requestInProgress = true;
        FocusScope.of(context).requestFocus(new FocusNode()); // retire le focus des champs de saisies
      });

      //Envoi des identifiants au backend
      HttpStatus status = await AuthenticationService.connect(loginController.text, pwdController.text);
      switch(status){
        case HttpStatus.OK:
          AuthenticationService.getUser().then((user){
            if(user == null){ // je n'ai pas réussi à récupérer l'objet utilisateur depuis l'api
              invalidLoginCause = 'Une erreur est survenue, veuillez réessayer';
            }else{ // l'utilisateur est récupéré, je rentre dans l'application
              //mise à jour du token de notifications de l'utilisateur
              PushNotificationHandler.getToken().then((String token) {
                UserService.updatePushNotificationToken(token).then((user){
                  AuthenticationService.getUser(force: true);
                });
              });
              AuthenticationService.logIn().then((String routeToRedirect){
                if(routeToRedirect != null)
                  Navigator.of(context).pushNamedAndRemoveUntil(routeToRedirect, (Route<dynamic> route) => false);
                else invalidLoginCause = "Une erreur est survenue, veuillez réessayer";
              });
            }
          });
          break;
        case HttpStatus.NOT_FOUND:
        case HttpStatus.UNAUTHORIZED:
          invalidLoginCause = "Identifiant ou mot de passe incorrect";
          break;
        case HttpStatus.FORBIDDEN:
          invalidLoginCause = "Accès refusé";
          break;
        case HttpStatus.FRONT_ERROR:
          invalidLoginCause = "Vérifiez votre connexion au réseau";
          break;
        default:
          invalidLoginCause = 'Une erreur est survenue, veuillez réessayer';
          break;
      }
      if(status != HttpStatus.OK){
        setState(() {
          invalidLogin = true;
          requestInProgress = false;
        });
      }
    }
  }

  @override
  void initState() {
    LocalStorageHandler.getData("_registered_login_").then((login){
      if(login != null){
        loginController.text = login;
        saveLogin = true;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    //désactivation du bouton lorsque l'un des deux champs est vide
    VoidCallback updateIsButtonEnabled = () => {
      setState((){ isButtonEnabled = loginController.text.isNotEmpty && pwdController.text.isNotEmpty; })
    };
    loginController.addListener(updateIsButtonEnabled);
    pwdController.addListener(updateIsButtonEnabled);

    final loginButtonTextChild = Text("Se connecter",
        textAlign: TextAlign.center,
        style: inputStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold)
    );

    final loginButtonLoadingSpinner = new CircularProgressIndicator(
      valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
    );

    final loginButton = SizedBox(
      width: 205.0,
      child: RaisedButton(
        child: requestInProgress ? loginButtonLoadingSpinner : loginButtonTextChild,
        elevation: 5.0,
        color: Colors.green,
        disabledColor: Color(0xFFC8E6C9),
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        //désactivation du bouton lorsque l'un des deux champs est vide ou qu'une requête est en cours
        onPressed: (isButtonEnabled && !requestInProgress) ? submit : null,
      ),
    );


    final loginField = TextFormField(
      controller: loginController,
      validator: (value){
        //aucun contrôle n'est fait sur le champ
        return null;
      },
      style: inputStyle,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Identifiant",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final passwordField = TextFormField(
      controller: pwdController,
      validator: loginValidation,
      obscureText: true,
      style: inputStyle,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Mot de passe",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    //Appel de la fonction de validation avant création du formulaire.
    //Est exécuté à la réception de la réponse du back
    _formKey.currentState?.validate();

    return Form(
      key: _formKey,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(36.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 155.0,
                      child: Image.asset(
                        "assets/logo_origin.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 45.0),
                    loginField,
                    GestureDetector(
                      child: Row(
                          children: <Widget>[
                            Checkbox(
                                value: saveLogin,
                                onChanged: (bool newValue) => setState(() => saveLogin = newValue)
                            ),
                            Text("Sauvegarder mon identifiant", style: textStyle)
                          ]
                      ),
                      onTap: () => saveLogin = !saveLogin,
                    ),
                    SizedBox(height: 10.0),
                    passwordField,
                    SizedBox(height: 35.0),
                    loginButton,
                    SizedBox(height: 15.0)
                  ],
                ),
              ),
            ),
          ),
        )
      )
    );
  }
}
