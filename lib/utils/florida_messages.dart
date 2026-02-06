import 'dart:math';

import 'package:flutter/material.dart';

/// Florida-themed messaging system for the KNEX app.
///
/// A core brand feature: all error messages, validation feedback, and UI copy
/// use randomized Florida-themed messages. Each message has EN/ES/FR variants.
/// The locale is determined from [Localizations.localeOf] at call time.
class FloridaMessages {
  FloridaMessages._();

  static final _random = Random();

  // ---------------------------------------------------------------------------
  // Internal helper
  // ---------------------------------------------------------------------------

  /// Picks one random message from [messages], selecting the variant that
  /// matches the current locale's language code. Falls back to English.
  static String _randomFromLocalized(
    BuildContext context,
    List<Map<String, String>> messages,
  ) {
    final langCode = Localizations.localeOf(context).languageCode;
    final picked = messages[_random.nextInt(messages.length)];
    return picked[langCode] ?? picked['en'] ?? '';
  }

  // ---------------------------------------------------------------------------
  // Error titles
  // ---------------------------------------------------------------------------

  static String errorTitle(BuildContext context) =>
      _randomFromLocalized(context, _errorTitles);

  static const _errorTitles = [
    {
      'en': 'Hurricane of errors!',
      'es': 'Huracan de errores!',
      'fr': 'Ouragan d\'erreurs!',
    },
    {
      'en': 'Gator ate the connection!',
      'es': 'El caiman se comio la conexion!',
      'fr': 'L\'alligator a mange la connexion!',
    },
    {
      'en': 'Swamp trouble ahead!',
      'es': 'Problemas en el pantano!',
      'fr': 'Probleme dans le marais!',
    },
  ];

  // ---------------------------------------------------------------------------
  // Generic errors
  // ---------------------------------------------------------------------------

  static String genericError(BuildContext context) =>
      _randomFromLocalized(context, _genericErrors);

  static const _genericErrors = [
    {
      'en': 'Something went wrong, like a flamingo in a snowstorm.',
      'es': 'Algo salio mal, como un flamenco en una tormenta de nieve.',
      'fr': 'Quelque chose a mal tourne, comme un flamant dans une tempete de neige.',
    },
    {
      'en': 'Things got tangled like mangrove roots. Try again!',
      'es': 'Las cosas se enredaron como raices de manglar. Intenta de nuevo!',
      'fr': 'Les choses se sont emmelees comme des racines de mangrove. Reessayez!',
    },
    {
      'en': 'Even the pelicans are confused. Give it another shot.',
      'es': 'Hasta los pelicanos estan confundidos. Intentalo otra vez.',
      'fr': 'Meme les pelicans sont confus. Reessayez.',
    },
  ];

  // ---------------------------------------------------------------------------
  // Server error
  // ---------------------------------------------------------------------------

  static String serverError(BuildContext context) =>
      _randomFromLocalized(context, _serverErrors);

  static const _serverErrors = [
    {
      'en': 'Our servers took a detour through the Everglades.',
      'es': 'Nuestros servidores tomaron un desvio por los Everglades.',
      'fr': 'Nos serveurs ont fait un detour par les Everglades.',
    },
    {
      'en': 'Server is sunbathing in Miami. Be right back!',
      'es': 'El servidor esta tomando sol en Miami. Volvemos pronto!',
      'fr': 'Le serveur bronze a Miami. De retour bientot!',
    },
    {
      'en': 'A manatee sat on the server. We\'re fixing it!',
      'es': 'Un manati se sento en el servidor. Lo estamos arreglando!',
      'fr': 'Un lamantin s\'est assis sur le serveur. On repare ca!',
    },
  ];

  // ---------------------------------------------------------------------------
  // Timeout
  // ---------------------------------------------------------------------------

  static String timeout(BuildContext context) =>
      _randomFromLocalized(context, _timeouts);

  static const _timeouts = [
    {
      'en': 'Slower than a sea turtle crossing the highway!',
      'es': 'Mas lento que una tortuga marina cruzando la autopista!',
      'fr': 'Plus lent qu\'une tortue de mer traversant l\'autoroute!',
    },
    {
      'en': 'The request got stuck in Florida traffic.',
      'es': 'La solicitud se quedo atascada en el trafico de Florida.',
      'fr': 'La requete est bloquee dans le trafic de Floride.',
    },
    {
      'en': 'Timed out like waiting for a parking spot at the beach.',
      'es': 'Se agoto el tiempo como esperando estacionamiento en la playa.',
      'fr': 'Delai depasse comme attendre une place a la plage.',
    },
  ];

  // ---------------------------------------------------------------------------
  // No internet
  // ---------------------------------------------------------------------------

  static String noInternet(BuildContext context) =>
      _randomFromLocalized(context, _noInternet);

  static const _noInternet = [
    {
      'en': 'No signal! Are you in the middle of the Everglades?',
      'es': 'Sin senal! Estas en medio de los Everglades?',
      'fr': 'Pas de signal! Etes-vous au milieu des Everglades?',
    },
    {
      'en': 'Even the dolphins have better Wi-Fi. Check your connection!',
      'es': 'Hasta los delfines tienen mejor Wi-Fi. Revisa tu conexion!',
      'fr': 'Meme les dauphins ont un meilleur Wi-Fi. Verifiez votre connexion!',
    },
    {
      'en': 'The internet went fishing. Please reconnect.',
      'es': 'El internet se fue a pescar. Por favor reconecta.',
      'fr': 'Internet est parti pecher. Veuillez vous reconnecter.',
    },
  ];

  // ---------------------------------------------------------------------------
  // Session expired
  // ---------------------------------------------------------------------------

  static String sessionExpired(BuildContext context) =>
      _randomFromLocalized(context, _sessionExpired);

  static const _sessionExpired = [
    {
      'en': 'Your session drifted away like a coconut in the Gulf Stream.',
      'es': 'Tu sesion se fue flotando como un coco en la Corriente del Golfo.',
      'fr': 'Votre session a derive comme une noix de coco dans le Gulf Stream.',
    },
    {
      'en': 'Session expired! The Florida sun dried it out.',
      'es': 'Sesion expirada! El sol de Florida la seco.',
      'fr': 'Session expiree! Le soleil de Floride l\'a dessechee.',
    },
    {
      'en': 'Time to log in again -- your pass got swept by the tide.',
      'es': 'Hora de iniciar sesion de nuevo -- la marea se llevo tu pase.',
      'fr': 'Reconnectez-vous -- la maree a emporte votre pass.',
    },
  ];

  // ---------------------------------------------------------------------------
  // Not found
  // ---------------------------------------------------------------------------

  static String notFound(BuildContext context) =>
      _randomFromLocalized(context, _notFound);

  static const _notFound = [
    {
      'en': 'Lost like a tourist in Little Havana!',
      'es': 'Perdido como un turista en la Pequena Habana!',
      'fr': 'Perdu comme un touriste dans la Petite Havane!',
    },
    {
      'en': 'We searched every beach -- couldn\'t find it.',
      'es': 'Buscamos en todas las playas -- no lo encontramos.',
      'fr': 'Nous avons cherche sur toutes les plages -- introuvable.',
    },
    {
      'en': 'Not even the lifeguards can spot this one.',
      'es': 'Ni los salvavidas pueden encontrar esto.',
      'fr': 'Meme les sauveteurs ne trouvent pas ca.',
    },
  ];

  // ---------------------------------------------------------------------------
  // Forbidden
  // ---------------------------------------------------------------------------

  static String forbidden(BuildContext context) =>
      _randomFromLocalized(context, _forbidden);

  static const _forbidden = [
    {
      'en': 'Access denied! This area is gator-only.',
      'es': 'Acceso denegado! Esta area es solo para caimanes.',
      'fr': 'Acces refuse! Cette zone est reservee aux alligators.',
    },
    {
      'en': 'No trespassing -- private beach!',
      'es': 'Prohibido el paso -- playa privada!',
      'fr': 'Interdit -- plage privee!',
    },
    {
      'en': 'You need a VIP wristband for this one, amigo.',
      'es': 'Necesitas una pulsera VIP para esto, amigo.',
      'fr': 'Il vous faut un bracelet VIP pour ca, ami.',
    },
  ];

  // ---------------------------------------------------------------------------
  // Bad request
  // ---------------------------------------------------------------------------

  static String badRequest(BuildContext context) =>
      _randomFromLocalized(context, _badRequest);

  static const _badRequest = [
    {
      'en': 'That request was wilder than a Key West sunset party!',
      'es': 'Esa solicitud fue mas loca que una fiesta de atardecer en Key West!',
      'fr': 'Cette requete etait plus folle qu\'une fete de coucher de soleil a Key West!',
    },
    {
      'en': 'Something\'s off -- like wearing a parka in Miami.',
      'es': 'Algo no cuadra -- como usar un abrigo en Miami.',
      'fr': 'Quelque chose cloche -- comme porter un manteau a Miami.',
    },
    {
      'en': 'The server didn\'t understand that. Try rephrasing, beach style.',
      'es': 'El servidor no entendio eso. Intenta de nuevo, estilo playa.',
      'fr': 'Le serveur n\'a pas compris. Reessayez, style plage.',
    },
  ];

  // ---------------------------------------------------------------------------
  // Button labels
  // ---------------------------------------------------------------------------

  static String retryButton(BuildContext context) =>
      _randomFromLocalized(context, _retryButton);

  static const _retryButton = [
    {'en': 'Try Again', 'es': 'Intentar de nuevo', 'fr': 'Reessayer'},
    {'en': 'Give it another go!', 'es': 'Dale otra vez!', 'fr': 'On reessaie!'},
    {'en': 'One more time!', 'es': 'Una vez mas!', 'fr': 'Encore une fois!'},
  ];

  static String okButton(BuildContext context) =>
      _randomFromLocalized(context, _okButton);

  static const _okButton = [
    {'en': 'OK', 'es': 'OK', 'fr': 'OK'},
    {'en': 'Got it!', 'es': 'Entendido!', 'fr': 'Compris!'},
    {'en': 'All good', 'es': 'Todo bien', 'fr': 'Tout bon'},
  ];

  static String cancelButton(BuildContext context) =>
      _randomFromLocalized(context, _cancelButton);

  static const _cancelButton = [
    {'en': 'Cancel', 'es': 'Cancelar', 'fr': 'Annuler'},
    {'en': 'Never mind', 'es': 'Olvidalo', 'fr': 'Laissez tomber'},
    {'en': 'Nah, skip it', 'es': 'No, dejalo', 'fr': 'Non, laissez'},
  ];

  // ---------------------------------------------------------------------------
  // Loading & success
  // ---------------------------------------------------------------------------

  static String loadingDefault(BuildContext context) =>
      _randomFromLocalized(context, _loading);

  static const _loading = [
    {
      'en': 'Warming up the engine...',
      'es': 'Calentando el motor...',
      'fr': 'On chauffe le moteur...',
    },
    {
      'en': 'Cruising down Ocean Drive...',
      'es': 'Paseando por Ocean Drive...',
      'fr': 'En balade sur Ocean Drive...',
    },
    {
      'en': 'Palm trees loading...',
      'es': 'Cargando palmeras...',
      'fr': 'Chargement des palmiers...',
    },
  ];

  static String successGeneric(BuildContext context) =>
      _randomFromLocalized(context, _success);

  static const _success = [
    {
      'en': 'Smooth as a South Beach sunset!',
      'es': 'Suave como un atardecer en South Beach!',
      'fr': 'Doux comme un coucher de soleil a South Beach!',
    },
    {
      'en': 'Nailed it, Florida style!',
      'es': 'Lo lograste, al estilo Florida!',
      'fr': 'Reussi, a la mode de Floride!',
    },
    {
      'en': 'Done and dusted like sand at the beach!',
      'es': 'Hecho y listo como arena en la playa!',
      'fr': 'Fait et fini comme le sable a la plage!',
    },
  ];

  // ---------------------------------------------------------------------------
  // Validation messages
  // ---------------------------------------------------------------------------

  static String plateRequired(BuildContext context) =>
      _randomFromLocalized(context, _plateRequired);

  static const _plateRequired = [
    {
      'en': 'We need your plate number -- even Florida Man has one!',
      'es': 'Necesitamos tu numero de placa -- hasta Florida Man tiene una!',
      'fr': 'Il nous faut votre plaque -- meme Florida Man en a une!',
    },
    {
      'en': 'No plate, no valet! Enter your license plate.',
      'es': 'Sin placa, no hay valet! Ingresa tu placa.',
      'fr': 'Pas de plaque, pas de voiturier! Entrez votre plaque.',
    },
    {
      'en': 'Your license plate is missing. Don\'t leave it in the swamp!',
      'es': 'Falta tu placa. No la dejes en el pantano!',
      'fr': 'Votre plaque manque. Ne la laissez pas dans le marais!',
    },
  ];

  static String emailRequired(BuildContext context) =>
      _randomFromLocalized(context, _emailRequired);

  static const _emailRequired = [
    {
      'en': 'We need your email -- carrier pigeons are so last century.',
      'es': 'Necesitamos tu email -- las palomas mensajeras son del siglo pasado.',
      'fr': 'Il nous faut votre email -- les pigeons voyageurs, c\'est depasse.',
    },
    {
      'en': 'Email required! We promise no spam, just sunshine.',
      'es': 'Email requerido! Prometemos no spam, solo sol.',
      'fr': 'Email requis! Promis, pas de spam, juste du soleil.',
    },
    {
      'en': 'Drop your email like a coconut from a palm tree.',
      'es': 'Deja tu email como un coco cayendo de una palmera.',
      'fr': 'Donnez votre email comme une noix de coco tombant d\'un palmier.',
    },
  ];

  static String passwordsDontMatch(BuildContext context) =>
      _randomFromLocalized(context, _passwordsDontMatch);

  static const _passwordsDontMatch = [
    {
      'en': 'Passwords don\'t match -- like flip flops on different feet!',
      'es': 'Las contrasenas no coinciden -- como chancletas en pies distintos!',
      'fr': 'Les mots de passe ne correspondent pas -- comme des tongs depareillees!',
    },
    {
      'en': 'Those passwords are as different as Miami and the Panhandle.',
      'es': 'Esas contrasenas son tan diferentes como Miami y el Panhandle.',
      'fr': 'Ces mots de passe sont aussi differents que Miami et le Panhandle.',
    },
    {
      'en': 'Try again -- make those passwords twins, not cousins!',
      'es': 'Intenta de nuevo -- haz que las contrasenas sean gemelas, no primas!',
      'fr': 'Reessayez -- faites correspondre ces mots de passe!',
    },
  ];

  static String photoRequired(BuildContext context) =>
      _randomFromLocalized(context, _photoRequired);

  static const _photoRequired = [
    {
      'en': 'Say cheese! We need a photo for your profile.',
      'es': 'Di queso! Necesitamos una foto para tu perfil.',
      'fr': 'Dites fromage! Il nous faut une photo pour votre profil.',
    },
    {
      'en': 'No selfie, no service! Add your photo.',
      'es': 'Sin selfie, no hay servicio! Agrega tu foto.',
      'fr': 'Pas de selfie, pas de service! Ajoutez votre photo.',
    },
    {
      'en': 'We need to see that Florida smile -- add a photo!',
      'es': 'Necesitamos ver esa sonrisa de Florida -- agrega una foto!',
      'fr': 'On veut voir ce sourire de Floride -- ajoutez une photo!',
    },
  ];

  static String stateRequired(BuildContext context) =>
      _randomFromLocalized(context, _stateRequired);

  static const _stateRequired = [
    {
      'en': 'Which state? (We hope it\'s Florida!)',
      'es': 'Cual estado? (Esperamos que sea Florida!)',
      'fr': 'Quel etat? (On espere que c\'est la Floride!)',
    },
    {
      'en': 'Don\'t forget the state -- even the Sunshine State counts!',
      'es': 'No olvides el estado -- hasta el Estado del Sol cuenta!',
      'fr': 'N\'oubliez pas l\'etat -- meme l\'Etat du Soleil compte!',
    },
    {
      'en': 'State is required. Florida plates, perhaps?',
      'es': 'El estado es requerido. Placas de Florida, quizas?',
      'fr': 'L\'etat est requis. Des plaques de Floride, peut-etre?',
    },
  ];

  // ---------------------------------------------------------------------------
  // Empty states
  // ---------------------------------------------------------------------------

  static String noFavoritesYet(BuildContext context) =>
      _randomFromLocalized(context, _noFavorites);

  static const _noFavorites = [
    {
      'en': 'No favorites yet! Start exploring like a tourist in the Keys.',
      'es': 'Sin favoritos aun! Empieza a explorar como un turista en los Keys.',
      'fr': 'Pas de favoris! Explorez comme un touriste dans les Keys.',
    },
    {
      'en': 'Your favorites list is emptier than a beach at midnight.',
      'es': 'Tu lista de favoritos esta mas vacia que una playa a medianoche.',
      'fr': 'Votre liste de favoris est plus vide qu\'une plage a minuit.',
    },
    {
      'en': 'No spots saved yet. Time to find your perfect parking palm!',
      'es': 'No hay lugares guardados. Es hora de encontrar tu palmera de estacionamiento!',
      'fr': 'Aucun lieu sauvegarde. Trouvez votre palmier de stationnement!',
    },
  ];

  static String tipEmpty(BuildContext context) =>
      _randomFromLocalized(context, _tipEmpty);

  static const _tipEmpty = [
    {
      'en': 'A little tip goes a long way under the Florida sun!',
      'es': 'Una pequena propina llega lejos bajo el sol de Florida!',
      'fr': 'Un petit pourboire va loin sous le soleil de Floride!',
    },
    {
      'en': 'Don\'t leave your valet high and dry -- add a tip!',
      'es': 'No dejes a tu valet en la estacada -- agrega una propina!',
      'fr': 'Ne laissez pas votre voiturier en plan -- ajoutez un pourboire!',
    },
    {
      'en': 'Tips are like sunscreen -- always a good idea in Florida.',
      'es': 'Las propinas son como el protector solar -- siempre buena idea en Florida.',
      'fr': 'Les pourboires sont comme la creme solaire -- toujours une bonne idee en Floride.',
    },
  ];

  // ---------------------------------------------------------------------------
  // Auth error messages
  // ---------------------------------------------------------------------------

  static String invalidCredentials(BuildContext context) =>
      _randomFromLocalized(context, _invalidCredentials);

  static const _invalidCredentials = [
    {
      'en': 'Wrong password -- even the key to the Fontainebleau is easier!',
      'es': 'Contrasena incorrecta -- hasta la llave del Fontainebleau es mas facil!',
      'fr': 'Mauvais mot de passe -- meme la cle du Fontainebleau est plus facile!',
    },
    {
      'en': 'Those credentials sank like a stone in Biscayne Bay.',
      'es': 'Esas credenciales se hundieron como una piedra en la Bahia de Biscayne.',
      'fr': 'Ces identifiants ont coule comme une pierre dans la baie de Biscayne.',
    },
    {
      'en': 'Nope! That login was fishier than a Key West dock.',
      'es': 'No! Ese login fue mas sospechoso que un muelle de Key West.',
      'fr': 'Non! Cette connexion etait plus louche qu\'un quai de Key West.',
    },
  ];

  static String emailAlreadyInUse(BuildContext context) =>
      _randomFromLocalized(context, _emailAlreadyInUse);

  static const _emailAlreadyInUse = [
    {
      'en': 'That email is already taken -- like the last beach chair at sunrise!',
      'es': 'Ese email ya esta en uso -- como la ultima silla de playa al amanecer!',
      'fr': 'Cet email est deja pris -- comme la derniere chaise de plage au lever du soleil!',
    },
    {
      'en': 'Someone already parked at that email address!',
      'es': 'Alguien ya se estaciono en esa direccion de email!',
      'fr': 'Quelqu\'un est deja gare a cette adresse email!',
    },
    {
      'en': 'This email has a reservation -- try another one, amigo!',
      'es': 'Este email tiene reservacion -- prueba con otro, amigo!',
      'fr': 'Cet email a une reservation -- essayez-en un autre, ami!',
    },
  ];

  static String weakPassword(BuildContext context) =>
      _randomFromLocalized(context, _weakPassword);

  static const _weakPassword = [
    {
      'en': 'That password is weaker than a tropical storm downgrade!',
      'es': 'Esa contrasena es mas debil que una tormenta tropical degradada!',
      'fr': 'Ce mot de passe est plus faible qu\'une tempete tropicale retrogradee!',
    },
    {
      'en': 'Beef up that password -- make it hurricane-strength!',
      'es': 'Refuerza esa contrasena -- hazla fuerza de huracan!',
      'fr': 'Renforcez ce mot de passe -- rendez-le force ouragan!',
    },
    {
      'en': 'Your password needs more muscle than a Florida Man headline!',
      'es': 'Tu contrasena necesita mas fuerza que un titular de Florida Man!',
      'fr': 'Votre mot de passe a besoin de plus de force qu\'un titre de Florida Man!',
    },
  ];

  static String signInRequired(BuildContext context) =>
      _randomFromLocalized(context, _signInRequired);

  static const _signInRequired = [
    {
      'en': 'You need to sign in first -- no sneaking past the velvet rope!',
      'es': 'Necesitas iniciar sesion primero -- no te cueles por la cuerda de terciopelo!',
      'fr': 'Connectez-vous d\'abord -- pas de resquille devant le cordon!',
    },
    {
      'en': 'Hold up! Sign in before cruising Ocean Drive.',
      'es': 'Espera! Inicia sesion antes de pasear por Ocean Drive.',
      'fr': 'Attendez! Connectez-vous avant de longer Ocean Drive.',
    },
    {
      'en': 'No ticket without a login -- even valets have rules!',
      'es': 'Sin login no hay ticket -- hasta los valets tienen reglas!',
      'fr': 'Pas de ticket sans connexion -- meme les voituriers ont des regles!',
    },
  ];

  static String passwordResetSent(BuildContext context) =>
      _randomFromLocalized(context, _passwordResetSent);

  static const _passwordResetSent = [
    {
      'en': 'Reset email sent! Check your inbox faster than a jet ski!',
      'es': 'Email de restablecimiento enviado! Revisa tu bandeja mas rapido que un jet ski!',
      'fr': 'Email de reinitialisation envoye! Verifiez votre boite plus vite qu\'un jet ski!',
    },
    {
      'en': 'Password reset on its way -- like a breeze from the Gulf!',
      'es': 'Restablecimiento en camino -- como una brisa del Golfo!',
      'fr': 'Reinitialisation en route -- comme une brise du Golfe!',
    },
    {
      'en': 'We sent you a lifeline! Check your email, beach buddy.',
      'es': 'Te enviamos un salvavidas! Revisa tu email, amigo de playa.',
      'fr': 'On vous a envoye une bouee! Verifiez votre email, ami de la plage.',
    },
  ];

  /// Returns a Florida-themed message for the given Firebase Auth [errorCode].
  static String getMessageForAuthError(BuildContext context, String errorCode) {
    return switch (errorCode) {
      'wrong-password' || 'user-not-found' || 'invalid-credential' =>
        invalidCredentials(context),
      'email-already-in-use' => emailAlreadyInUse(context),
      'weak-password' => weakPassword(context),
      'requires-recent-login' => signInRequired(context),
      _ => genericError(context),
    };
  }

  // ---------------------------------------------------------------------------
  // Status code & error mapping
  // ---------------------------------------------------------------------------

  /// Returns a Florida-themed message for the given HTTP [code].
  static String getMessageForStatusCode(BuildContext context, int code) {
    return switch (code) {
      400 => badRequest(context),
      401 || 403 => forbidden(context),
      404 => notFound(context),
      408 => timeout(context),
      >= 500 => serverError(context),
      _ => genericError(context),
    };
  }

  /// Returns a Florida-themed message for the given [error].
  ///
  /// Handles common error types including [SocketException] patterns (via
  /// string matching), timeout-like messages, and generic fallbacks.
  static String getMessageForError(BuildContext context, dynamic error) {
    final message = error.toString().toLowerCase();

    if (message.contains('socket') ||
        message.contains('network') ||
        message.contains('connection refused')) {
      return noInternet(context);
    }

    if (message.contains('timeout') || message.contains('timed out')) {
      return timeout(context);
    }

    if (message.contains('401') || message.contains('unauthorized')) {
      return sessionExpired(context);
    }

    if (message.contains('403') || message.contains('forbidden')) {
      return forbidden(context);
    }

    if (message.contains('404') || message.contains('not found')) {
      return notFound(context);
    }

    if (message.contains('500') || message.contains('internal server')) {
      return serverError(context);
    }

    return genericError(context);
  }
}
