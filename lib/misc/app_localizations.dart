import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shuttertop/l10n/messages_all.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
  @override
  bool isSupported(Locale locale) {
    return <String>['en', 'it', 'es', 'pt'].contains(locale.languageCode);
  }
}

class SpecifiedLocalizationDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const SpecifiedLocalizationDelegate(this.overriddenLocale);

  final Locale overriddenLocale;

  @override
  bool isSupported(Locale locale) => overriddenLocale != null;

  @override
  Future<AppLocalizations> load(Locale locale) =>
      AppLocalizations.load(overriddenLocale);

  @override
  bool shouldReload(SpecifiedLocalizationDelegate old) => true;
}

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return new AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get createAccountShuttertop =>
      Intl.message('Crea un nuovo account', name: 'createAccountShuttertop');

  String get accediConLaMail =>
      Intl.message('Accedi con la mail', name: 'accediConLaMail');
  String get oppure => Intl.message('oppure', name: 'oppure');
  String get continuaCon =>
      Intl.message('o usa un account social', name: 'continuaCon');
  String get contestFotograficiImprovvisati =>
      Intl.message('Contest fotografici improvvisati e via\ndiscorrendo',
          name: 'contestFotograficiImprovvisati');
  String nonRiescoAConnettermiAllaReteCiRiprovoPerLaVolta(int retry) =>
      Intl.message(
          "Non riesco a connettermi alla rete. Ci riprovo per la $retry° volta tra 5 secondi.",
          name: "nonRiescoAConnettermiAllaReteCiRiprovoPerLaVolta",
          args: <int>[retry]);
  String get perProseguireENecessarioAggiornaleLapp =>
      Intl.message("Per proseguire è necessario aggiornare l' app",
          name: "perProseguireENecessarioAggiornaleLapp");
  String errore(String error) =>
      Intl.message("Errore :( $error", name: "errore", args: <String>[error]);
  String get sputaIlRospo =>
      Intl.message("Sputa il rospo...", name: "sputaIlRospo");
  String get sistemaGliErroriPerContinuare =>
      Intl.message("Sistema gli errori per continuare",
          name: "sistemaGliErroriPerContinuare");

  String get problemiDiConnessioneAlServer =>
      Intl.message("Problemi di connessione al server :(",
          name: "problemiDiConnessioneAlServer");

  String get esisteGiaUnContestInCorsoConQuestoNome =>
      Intl.message("Esiste già un contest in corso con questo nome..",
          name: "esisteGiaUnContestInCorsoConQuestoNome");

  String get cambiaNome => Intl.message("Cambia nome", name: "cambiaNome");

  String get portamici => Intl.message("Portamici", name: "portamici");

  String get nuovaEdizione =>
      Intl.message("Nuova edizione", name: "nuovaEdizione");

  String get nuovoContest =>
      Intl.message("Nuovo contest", name: "nuovoContest");

  String get modificaContest =>
      Intl.message("Modifica contest", name: "modificaContest");

  String get nome => Intl.message("Nome", name: "nome");

  String get nonTiDilungareTagliaCorto =>
      Intl.message("Non ti dilungare, taglia corto",
          name: "nonTiDilungareTagliaCorto");

  String get terminaIl => Intl.message("Termina il", name: "terminaIl");

  String get categoria => Intl.message("Categoria", name: "categoria");

  String get scegliUnaCategoria =>
      Intl.message("Scegli una categoria", name: "scegliUnaCategoria");

  String get fornisciUnaSpiegatione =>
      Intl.message("Fornisci una spiegazione", name: "fornisciUnaSpiegatione");

  String get descrizione => Intl.message("Descrizione", name: "descrizione");

  String get crea => Intl.message("Crea", name: "crea");

  String get scendiInCampo =>
      Intl.message("Scendi in campo", name: "scendiInCampo");

  String get inserisciLaCover =>
      Intl.message("Inserisci la cover", name: "inserisciLaCover");

  String get modificaIlContest =>
      Intl.message("Modifica il contest", name: "modificaIlContest");

  String get eliminaIlContest =>
      Intl.message("Elimina il contest", name: "eliminaIlContest");

  String get inserisciUnImmagineDiCopertiva =>
      Intl.message("Inserisci un immagine di copertina",
          name: "inserisciUnImmagineDiCopertiva");

  String get home => Intl.message("Home", name: "home");

  String get info => Intl.message("Info", name: "info");

  String get foto => Intl.message("Foto", name: "foto");

  String get gentaccia => Intl.message("Gentaccia", name: "gentaccia");

  String get classifica => Intl.message("Classifica", name: "classifica");

  String get followers => Intl.message("Followers", name: "followers");

  String get cercaUnContest =>
      Intl.message("Cerca un contest...", name: "cercaUnContest");

  String get contest => Intl.message("Contest", name: "contest");

  String get cerca => Intl.message("Cerca", name: "cerca");

  String get esplora => Intl.message("Esplora", name: "esplora");

  String get following => Intl.message("Following", name: "following");

  String get recenti => Intl.message("Recenti", name: "recenti");

  String get popolari => Intl.message("Popolari", name: "popolari");

  String get terminati => Intl.message("Terminati", name: "terminati");

  String get gareInCorso => Intl.message("Gare in corso", name: "gareInCorso");

  String get vittorie => Intl.message("vittorie", name: "vittorie");

  String get nonCiSonoStateVittorie =>
      Intl.message("Non ci sono state vittorie",
          name: "nonCiSonoStateVittorie");
  String get nonCiSonoGareInCorso =>
      Intl.message("Non ci sono gare in corso", name: "nonCiSonoGareInCorso");

  String get nonCiSonoFoto =>
      Intl.message("Non ci sono foto", name: "nonCiSonoFoto");

  String get controllaLaTuaCasellaDiPosta =>
      Intl.message("Controlla la tua casella di posta!",
          name: "controllaLaTuaCasellaDiPosta");

  String get newsDalMondo =>
      Intl.message('News dal mondo', name: "newsDalMondo");

  String get benvenutoSuShuttertop =>
      Intl.message("Benvenuto su Shuttertop", name: "benvenutoSuShuttertop");

  String get questoEIlMigliorPostoPerSficcanasare => Intl.message(
      "Questo è il miglior posto per sficcanasare le novità dei paraggi. Trova adesso contest e utenti da seguire.",
      name: "questoEIlMigliorPostoPerSficcanasare");

  String get andiamo => Intl.message("Andiamo", name: "andiamo");

  String get cronologiaPunti =>
      Intl.message("Cronologia punti", name: "cronologiaPunti");

  String get posta => Intl.message("Posta", name: "posta");

  String get messaggi => Intl.message("Messaggi", name: "messaggi");

  String get notifiche => Intl.message("Notifiche", name: "notifiche");

  String get nonCiSonoPuntiTotalizzati =>
      Intl.message("Non risultano punti totalizzati",
          name: "nonCiSonoPuntiTotalizzati");

  String get nonCiSonoNotifiche =>
      Intl.message("Non ci sono notifiche", name: "nonCiSonoNotifiche");

  String get seiSulTaciturno =>
      Intl.message("Sei sul taciturno", name: "seiSulTaciturno");

  String get controllaCheSiaCorretta =>
      Intl.message("Controlla che sia corretta!",
          name: "controllaCheSiaCorretta");

  String get controllaCheLaTuaVecchiaPasswordSiaCorretta =>
      Intl.message("Controlla che la tua vecchia password sia corretta!",
          name: "controllaCheLaTuaVecchiaPasswordSiaCorretta");

  String get laPasswordEObbligatoria =>
      Intl.message("La password è obbligatoria",
          name: "laPasswordEObbligatoria");

  String get nuovaPassword =>
      Intl.message("Nuova password", name: "nuovaPassword");

  String get cambiaPassword =>
      Intl.message("Cambia password", name: "cambiaPassword");

  String get password => Intl.message("Password", name: "password");

  String get vecchiaPassword =>
      Intl.message("Vecchia password", name: "vecchiaPassword");

  String get digitaLaTuaNuovaPassword =>
      Intl.message("Digita la tua nuova password",
          name: "digitaLaTuaNuovaPassword");

  String get conferma => Intl.message("Conferma", name: "conferma");

  String get nonTiAbbiamoRintracciato =>
      Intl.message('Non ti abbiamo rintracciato! :(',
          name: "nonTiAbbiamoRintracciato");

  String get emailEObbligatoria =>
      Intl.message("L' email è obbligatoria", name: "emailEObbligatoria");

  String get recuperoPassword =>
      Intl.message('Aiutooooo!', name: "recuperoPassword");

  String get digitaLaTuaEmail =>
      Intl.message('Digita la tua email', name: "digitaLaTuaEmail");

  String get email => Intl.message("Email", name: "email");

  String get recuperati => Intl.message("Recuperati", name: "recuperati");

  String get contestTerminato =>
      Intl.message("Contest terminato", name: "contestTerminato");

  String get fotoInOrdineDiVoti =>
      Intl.message("Foto in ordine di voti", name: "fotoInOrdineDiVoti");

  String get fotoInOrdineDiInserimento =>
      Intl.message("Foto in ordine di inserimento",
          name: "fotoInOrdineDiInserimento");

  String get impostazioni => Intl.message("Impostazioni", name: "impostazioni");
  String get lingua => Intl.message("Lingua", name: "lingua");

  String get nomeDiBattaglia =>
      Intl.message("Nome di battaglia", name: "nomeDiBattaglia");

  String get modificaFotoDelProfilo =>
      Intl.message('Modifica foto del profilo', name: "modificaFotoDelProfilo");

  String get immagineDiProfilo =>
      Intl.message("Immagine di profilo", name: "immagineDiProfilo");

  String get cambiaLaTuaPassword =>
      Intl.message('Cambia la tua password', name: "cambiaLaTuaPassword");

  String get informazioni => Intl.message("Informazioni", name: "informazioni");

  String get esciDalTunnel =>
      Intl.message("Esci dal tunnel", name: "esciDalTunnel");

  String get ancheDettoLogout =>
      Intl.message("Anche detto logout", name: "ancheDettoLogout");

  String get selezionaUnContest =>
      Intl.message("Seleziona un contest", name: "selezionaUnContest");

  String get emailEOPasswordErrati =>
      Intl.message("Email e/o password errati", name: "emailEOPasswordErrati");

  String get login => Intl.message("Login", name: "login");

  String get digitaLaTuaPassword =>
      Intl.message('Digita la tua password', name: "digitaLaTuaPassword");

  String get accedi => Intl.message("Accedi", name: "accedi");

  String get nonHaiUnAccount =>
      Intl.message('Non hai un account?', name: "nonHaiUnAccount");

  String get iscriviti => Intl.message(" Iscriviti!", name: "iscriviti");

  String get recuperaLa => Intl.message("Recupera la ", name: "recuperaLa");

  String get passwordWithExclamation =>
      Intl.message("password!", name: "passwordWithExclamation");

  String get usernameEObbligatorio =>
      Intl.message("L' username è obbligatorio", name: "usernameEObbligatorio");

  String get lunghezzaMinima8Caratteri =>
      Intl.message("La lunghezza minima è 8 caratteri");

  String get registrati => Intl.message("Registrati", name: "registrati");

  String get ciccioBello => Intl.message("CiccioBello", name: "ciccioBello");

  String get siiCoincisoERuspante =>
      Intl.message('Sii coinciso e ruspante', name: "siiCoincisoERuspante");

  String get creati => Intl.message("Creati", name: "creati");

  String get scrostaLaTuaImmaginazione =>
      Intl.message("Scrosta la tua immaginazione",
          name: "scrostaLaTuaImmaginazione");

  String get leSueFoto => Intl.message("Le sue foto", name: "leSueFoto");

  String get eSeguitoDaQuestiTizi =>
      Intl.message("E' seguito da questi tizi", name: "eSeguitoDaQuestiTizi");

  String get luiSegueQuesti =>
      Intl.message("Lui segue questi", name: "luiSegueQuesti");

  String userFollows(String user) =>
      Intl.message("$user segue", args: <String>[user], name: "userFollows");

  String get scrivigli => Intl.message("Scrivigli", name: "scrivigli");

  String get visualizzaTutti =>
      Intl.message("Visualizza tutti", name: "visualizzaTutti");

  String get contestCreati =>
      Intl.message("Contest creati", name: "contestCreati");

  String get mondiale => Intl.message("Mondiale", name: "mondiale");

  String get cercaUtenti =>
      Intl.message('Cerca utenti...', name: "cercaUtenti");

  String get punteggio => Intl.message("Punteggio", name: "punteggio");

  String get aggiorna => Intl.message("Aggiorna", name: "aggiorna");

  String get caricamento => Intl.message("Caricamento...", name: "caricamento");

  String get segui => Intl.message("Segui", name: "segui");
  String get seguendo => Intl.message("Seguendo", name: "seguendo");

  String get condividi => Intl.message("Condividi", name: "condividi");

  String commentiVis(int commentsCount) =>
      Intl.message("Visualizza tutti i $commentsCount commenti",
          args: <int>[commentsCount], name: "commentiTop");

  String topVis(int votesCount) =>
      Intl.message("Ha scatenato il top a $votesCount persone",
          args: <int>[votesCount], name: "commentiTop");

  String commentiTop(int commentsCount, int votesCount) => Intl.message(
      "Ha scatenato il top a $votesCount persone · $commentsCount commenti",
      args: <int>[commentsCount, votesCount],
      name: "commentiTop");

  String get top => Intl.message("Top", name: "top");

  String get commenta => Intl.message("Commenta", name: "commenta");

  String get commenti => Intl.message("Commenti", name: "commenti");

  String vediTuttiINCommenti(int commentsCount) =>
      Intl.message("Vedi tutti i $commentsCount commenti",
          args: <int>[commentsCount], name: "vediTuttiINCommenti");

  String get punti => Intl.message("punti", name: "punti");
  String get pts => Intl.message("pts", name: "pts");

  String photosWithCount(int photosCount) => Intl.message("$photosCount foto",
      name: "photosWithCount", args: <int>[photosCount]);

  String get dettagli => Intl.message("Dettagli", name: "dettagli");

  String nEdizione(int n) =>
      Intl.message("${n}th edizione", args: <int>[n], name: "nEdizione");

  String get creatoDa => Intl.message("Creato da", name: "creatoDa");

  String get filtriContest =>
      Intl.message("Filtri contest", name: "filtriContest");

  String get salva => Intl.message("Salva", name: "salva");

  String get categorie => Intl.message("Categorie", name: "categorie");

  String get tutte => Intl.message("Tutte", name: "tutte");

  String get partecipa => Intl.message("Partecipa", name: "partecipa");

  String get ripartecipa => Intl.message("Ripartecipa", name: "ripartecipa");

  String get rilancia => Intl.message("Rilancia", name: "rilancia");

  String get fotoRecenti => Intl.message("Foto recenti", name: "fotoRecenti");

  String get iSeguaci => Intl.message("I seguaci", name: "iSeguaci");

  String get unVincitore => Intl.message("Un vincitore", name: "unVincitore");

  String get zeroVincitori =>
      Intl.message("0 Vincitori", name: "zeroVincitori");

  String get alTermine => Intl.message("Al termine", name: "alTermine");

  String get nessunContestTrovato =>
      Intl.message("Nessun contest trovato", name: "nessunContestTrovato");

  String get aggiungiUnContest =>
      Intl.message("Aggiungi un contest", name: "aggiungiUnContest");

  String get winner => Intl.message("Winner", name: "winner");

  String nTop(int votesCount) =>
      Intl.message("$votesCount top", args: <int>[votesCount], name: "nTop");

  String get inClassifica =>
      Intl.message("In classifica", name: "inClassifica");

  String get classificato => Intl.message("Classificato", name: "classificato");

  String get iSostenitori =>
      Intl.message("I sostenitori", name: "iSostenitori");

  String get infoFoto => Intl.message("Info foto", name: "infoFoto");

  String get rapportoFocale =>
      Intl.message("rap. focale", name: "rapportoFocale");

  String get tempoEsposizione =>
      Intl.message("tempo esp.", name: "tempoEsposizione");

  String get lunghezzaFocale =>
      Intl.message("lung. focale", name: "lunghezzaFocale");

  String get nessunaFotoInserita =>
      Intl.message("Nessuna foto inserita", name: "nessunaFotoInserita");

  String get percheNonTiAggrada =>
      Intl.message("Perchè non ti aggrada?", name: "percheNonTiAggrada");

  String get motivo => Intl.message("Motivo", name: "motivo");

  String get esScombinaIlMioCervello =>
      Intl.message('es. scombina il mio cervello',
          name: "esScombinaIlMioCervello");

  String get annulla => Intl.message("Annulla", name: "annulla");

  String get invia => Intl.message("Invia", name: "invia");

  String get seiSicuro => Intl.message("Sei sicuro?", name: "seiSicuro");

  String get rimuovi => Intl.message("Rimuovi", name: "rimuovi");

  String get segnala => Intl.message("Segnala", name: "segnala");

  String modificaUsername(String username) => Intl.message("Modifica $username",
      args: <String>[username], name: "modificaUsername");

  String get camuffati => Intl.message("Camuffati", name: "camuffati");

  String get nonSeguire => Intl.message("Non seguire", name: "nonSeguire");

  String get seguilo => Intl.message("Seguilo", name: "seguilo");

  String get inGara => Intl.message("In gara", name: "inGara");

  String puntiWithScore(int score) =>
      Intl.message("$score punti", name: "puntiWithScore", args: <int>[score]);

  String vittorieWithCount(int count) => Intl.message("$count vittorie",
      name: "vittorieWithCount", args: <int>[count]);

  String get ilTuoProfilo =>
      Intl.message('Il tuo profilo', name: "ilTuoProfilo");

  String get creaUnContest =>
      Intl.message('Crea un contest', name: "creaUnContest");

  String get scattaUnaFoto =>
      Intl.message("Scatta una foto", name: "scattaUnaFoto");

  String get apriLaGalleria =>
      Intl.message("Apri la galleria", name: "apriLaGalleria");

  String get terminiDelServizio =>
      Intl.message("Termini del servizio", name: "terminiDelServizio");
  String get informativaSullaPrivacy =>
      Intl.message("Informativa sulla privacy",
          name: "informativaSullaPrivacy");
  String get versione => Intl.message("Versione", name: "versione");
}
