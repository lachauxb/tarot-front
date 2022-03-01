import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';


/// à l'aide du package hive & path_provider,
/// cette classe permet de stocker localement sur le téléphone des données
class LocalStorageHandler{

  static var encryptedOriginBox;
  static const _keyBoxID = 'keyBox';
  static const _encryptedOriginBoxID = 'originVault';

  static var isInitialized = false;

  /// initialise le magasin de donnée local si nécessaire
  static Future<bool> _init() async{

    // initialisation du magasin de données local
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);

    // génération d'une clé d'encryptage de donnée unique si il n'en existe pas
    var keyBox = await Hive.openBox(_keyBoxID);
    if (!keyBox.containsKey('key')) {
      keyBox.put('key', Hive.generateSecureKey());
    }

    // récupération du store Origin à l'aide de la clé d'encryptage des données unique
    encryptedOriginBox = await Hive.openBox(_encryptedOriginBoxID, encryptionKey: keyBox.get('key'));

    return true;
  }

  /// tentative de récupération d'un élément sauvegardé en local
  static Future<dynamic> getData(String key) async{
    if(!isInitialized)
      isInitialized = await _init();
    return encryptedOriginBox.containsKey(key) ? encryptedOriginBox.get(key) : null;
  }

  /// insertion d'un élément dans le magasin de données local
  static void putData(String key, dynamic data) async{
    if(!isInitialized)
      isInitialized = await _init();
    encryptedOriginBox.put(key, data);
  }

  /// tentative de suppression d'un élément sauvegardé en local
  static void removeData(String key) async{
    if(!isInitialized)
      isInitialized = await _init();
    if(encryptedOriginBox.containsKey(key))
      encryptedOriginBox.delete(key);
  }

}