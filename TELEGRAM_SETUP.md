# Configurazione Bot Telegram per GitHub Actions

Segui questi passaggi per ricevere automaticamente l'IPA della tua app su Telegram.

## 1. Creazione del Bot
1. Apri Telegram e cerca l'utente `@BotFather`.
2. Scrivigli il comando `/newbot`.
3. Scegli un nome per il tuo bot (es. `Scheduling Build Bot`).
4. Scegli uno username univoco che finisca per `bot` (es. `scheduling_luca_bot`).
5. **Copia il token API** che ti verrà fornito (è una stringa lunga di numeri e lettere). Questo sarà il tuo `TELEGRAM_TOKEN`.

## 2. Ottenimento del tuo Chat ID
1. Cerca l'utente `@userinfobot` su Telegram.
2. Inviagli un messaggio qualsiasi.
3. Il bot ti risponderà con il tuo `Id` (un numero di circa 9-10 cifre). Questo sarà il tuo `TELEGRAM_TO`.

## 3. Configurazione su GitHub
1. Vai sul tuo repository su GitHub.
2. Vai in **Settings** (la scheda in alto).
3. Nel menu a sinistra, clicca su **Secrets and variables** -> **Actions**.
4. Clicca su **New repository secret** e aggiungi:
   - Name: `TELEGRAM_TOKEN` | Value: (il token di BotFather)
   - Name: `TELEGRAM_TO` | Value: (il tuo ID numerico)

## 4. Test finale
1. Avvia il tuo bot (cerca lo username che hai scelto e premi **START**). Questo è fondamentale, altrimenti il bot non ha il permesso di scriverti.
2. Fai un push sul ramo `main`.
3. Al termine della build, riceverai un messaggio dal bot con il file `.ipa` allegato!

---
*Nota: Puoi condividere il file direttamente da Telegram ad AltStore sul tuo iPhone per installarlo senza usare il computer.*