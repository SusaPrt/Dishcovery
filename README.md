# Dishcovery

<p align="center">
  <img src="img/logo.PNG" alt="Dishcovery Logo" width="200"/>
</p>

## Susanna Peretti mat. 329456

## Descrizione del progetto
Dishcovery è un'applicazione Flutter che permette agli utenti di scoprire nuove ricette in base agli ingredienti disponibili nella loro dispensa, inseriti manualmente. L'app consente di creare un account, gestire la dispensa personale, esplorare ricette suggerite, e aggiungere ingredienti al carrello per creare una lista della spesa.

## User Experience
L'utente accederà all'applicativo tramite l'inserimento di email e password. Se non è registrato, potrà creare un nuovo account. E' richiesto un indirizzo mail valido e una password di almeno 6 caratteri.

<p align="center">
  <img src="img/readme/login.png" alt="Schermata Login" width="300"/>
  <img src="img/readme/signup.png" alt="Schermata Sign Up" width="300"/>
</p>

Una volta autenticato, l'utente verrà indirizzato alla schermata principale dell'app, che include una barra di navigazione inferiore per accedere alle diverse sezioni: Dispensa, Ricette, Carrello e Impostazioni. La dispensa consente di aggiungere ingredienti manualmente, visualizzare quelli esistenti e rimuoverli. Nella sezione Ricette, l'utente può esplorare le ricette suggerite in base agli ingredienti disponibili nella dispensa. Ogni ricetta mostra il titolo, gli ingredienti necessari e quelli mancanti. Gli ingredienti delle ricette possono essere aggiunti al carrello per creare una lista della spesa. La sezione Impostazioni permette di modificare le informazioni dell'account o cancellarlo.

<p align="center">
  <img src="img/readme/pantry.png" alt="Schermata Dispensa" width="300"/>
  <img src="img/readme/recipes.png" alt="Schermata Ricette" width="300"/>
  <img src="img/readme/cart.png" alt="Schermata Carrello" width="300"/>
  <img src="img/readme/settings.png" alt="Schermata Impostazioni" width="300"/>
</p>

## Gestione dello stato
La gestione dello stato nell'app avviene tramite:
- **Hive**: database locale per la persistenza di utenti, ingredienti e carrello.
- **ValueListenableBuilder**: per aggiornare automaticamente la UI quando i dati Hive cambiano.
- **setState**: per aggiornare lo stato locale dei widget dopo operazioni come aggiunta, modifica o cancellazione.

## Dipendenze
- **flutter** SDK 3.8.1
- **hive** database locale chiave-valore
- **http**: per richieste API

## Struttura del progetto
```
lib/
  ├── main.dart
  ├── models/
    ├── ingredients.dart
    ├── ingredient.g.dart
    ├── user.dart
    ├── muser.g.dart
  ├── pages/
    ├── cart_page.dart
    ├── login_page.dart
    ├── main_app_page.dart
    ├── pantry_page.dart
    ├── recipes_page.dart
    ├── settings_page.dart
    ├── sign_up_page.dart
  ├── services/
    ├── spoonacular_api.dart
  '''

  Ge