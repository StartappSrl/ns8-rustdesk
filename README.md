# ns8-rustdesk

Modulo [NethServer 8](https://github.com/NethServer/ns8-core) che installa un
server [RustDesk](https://rustdesk.com) self-hosted con console web.

Il modulo esegue tre container Podman rootless:

| Servizio | Immagine | Ruolo | Porte |
|---|---|---|---|
| `hbbs.service` | `rustdesk/rustdesk-server` | Server ID / rendezvous | 21115/tcp, 21116/tcp+udp (21118/tcp locale, per il client da browser via Traefik) |
| `hbbr.service` | `rustdesk/rustdesk-server` | Server relay | 21117/tcp (21119/tcp locale, per il client da browser via Traefik) |
| `rustdesk-api.service` | `lejianwen/rustdesk-api` | Server API e console web: utenti, dispositivi, rubriche, log | 127.0.0.1:`TCP_PORT`, pubblicata da Traefik in HTTPS |

hbbs e hbbr usano la rete dell'host, necessaria per le connessioni dirette
(P2P). Poiché le porte sono fisse, è possibile **una sola istanza per nodo**.

Le versioni delle immagini sono fissate in `build-images.sh` e in
`rustdesk-api/Containerfile`.

## Lingua italiana

Il modulo è localizzato in italiano in tutte le sue parti:

- **Interfaccia del modulo in NS8**: segue la lingua scelta in cluster-admin
  (traduzioni in `ui/public/i18n/it`).
- **Console web**: il modulo pubblica una propria immagine `rustdesk-api`,
  costruita da `rustdesk-api/Containerfile`. Parte dall'immagine upstream e
  aggiunge l'italiano alla console (`it.json`), ai messaggi del server
  (`it.toml`) e alla pagina di benvenuto (`hello.html`). L'italiano è la
  lingua predefinita; ogni utente può cambiarla dal menu della console.
- **Client RustDesk**: è già disponibile in italiano, si sceglie dalle
  impostazioni del client.

Quando Renovate propone una nuova versione di `lejianwen/rustdesk-api`,
aggiorna anche `RUSTDESK_API_WEB_COMMIT` nel Containerfile e traduci le
eventuali nuove chiavi: lo script `patch-italian.sh` blocca la build se il
codice upstream cambia in modo incompatibile, invece di produrre una console
non tradotta.

## Installazione

    add-module ghcr.io/startappsrl/rustdesk:1.0.0 1

L'output restituisce il nome dell'istanza, ad esempio `rustdesk1`.

## Configurazione

Dalla pagina Impostazioni del modulo nell'interfaccia di NS8, oppure da riga di
comando:

    api-cli run module/rustdesk1/configure-module --data '{
      "host": "rustdesk.example.org",
      "rustdesk_host": "rustdesk.example.org",
      "lets_encrypt": true,
      "http2https": true,
      "web_client": false
    }'

| Parametro | Descrizione |
|---|---|
| `host` | FQDN della console web e del server API (rotta Traefik) |
| `rustdesk_host` | Nome host o IP pubblico a cui si collegano i client per ID e relay. Se omesso vale `host` |
| `lets_encrypt` | Richiede un certificato Let's Encrypt per `host` |
| `http2https` | Reindirizza HTTP su HTTPS |
| `web_client` | Abilita il client da browser su `https://<host>/webclient/` (vedi sotto) |
| `ban_threshold` | Accessi falliti in 5 minuti prima di bloccare l'IP per 30 minuti. Default `5`, `0` disattiva |
| `log_retention_days` | Giorni di conservazione dei log di accessi, connessioni e file. Default `180`, `0` per sempre |
| `admin_allowlist` | IP o reti (CIDR) da cui si può aprire la console web. Vuoto: da ovunque |

Il DNS di `host` deve puntare al nodo. Se il nodo è dietro NAT, inoltra sul
router le porte 21115-21117/tcp e 21116/udp.

### Configurazione dei client RustDesk

Nel client: **Impostazioni → Rete → Server ID/Relay**. La pagina Impostazioni
del modulo mostra i valori da copiare:

- Server ID: `rustdesk_host`
- Server relay: `rustdesk_host`
- Server API: `https://<host>`
- Chiave: il contenuto di `id_ed25519.pub`, generato al primo avvio di hbbs

La chiave è leggibile anche da riga di comando:

    api-cli run module/rustdesk1/get-configuration | jq -r .public_key

### Primo accesso alla console web

La console è su `https://<host>/_admin/`. Al primo avvio rustdesk-api crea
l'utente `admin` e scrive la password nel log del container:

    runagent -m rustdesk1 podman logs rustdesk-api 2>&1 | grep -i password

Per impostare una nuova password:

    runagent -m rustdesk1 podman exec rustdesk-api ./apimain reset-admin-pwd 'NuovaPassword'

### Client da browser

Con `web_client` attivo, il client RustDesk da browser è disponibile su
`https://<host>/webclient/` e dalla console web (anche tramite i link di
condivisione verso un dispositivo). Serve per collegarsi da un computer dove
non si può installare RustDesk; il computer da controllare deve comunque
avere il client installato.

Il client da browser comunica con hbbs e hbbr tramite websocket. Il client
originale cercherebbe `wss://<server>:21118` e `:21119`, dove però hbbs e
hbbr non hanno TLS. Il modulo modifica il client (`rustdesk-api/patch-webclient.sh`)
perché usi `wss://<host>/ws/id` e `wss://<host>/ws/relay`: Traefik termina
il TLS con il certificato della console e inoltra a hbbs e hbbr. Le porte
21118 e 21119 restano chiuse nel firewall.

Limiti: le sessioni passano sempre dal relay (niente connessione diretta),
quindi sono più lente dell'app installata, e le funzioni disponibili sono
meno di quelle del client desktop.

## Sicurezza

### Cosa fa il modulo

- **Chiave obbligatoria su ID server e relay.** hbbs e hbbr rifiutano i
  client che non hanno la chiave pubblica del server. hbbr è avviato con
  `-k _`: senza questa opzione il relay accetterebbe chiunque.
- **Sessioni cifrate end-to-end** tra i client: il relay inoltra i dati ma
  non può leggerli.
- **Console solo in HTTPS**, tramite Traefik e Let's Encrypt. Il container
  ascolta solo su `127.0.0.1`.
- **Header di sicurezza** su ogni risposta: HSTS (con il redirect HTTPS
  attivo), `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`.
- **Protezione dai tentativi di accesso**: captcha dopo 3 errori, blocco
  dell'IP per 30 minuti dopo `ban_threshold` errori. Vale sia per la console
  sia per il login dai client.
- **Console limitabile per IP** (`admin_allowlist`): si applica a `/_admin` e
  alle API di amministrazione `/api/admin`. Le API usate dai client restano
  raggiungibili, altrimenti i tecnici fuori ufficio non potrebbero fare login.
- **Registrazioni chiuse** e documentazione Swagger nascosta.
- **Conservazione dei log** (`log_retention_days`): ogni notte il timer
  `purge-logs.timer` cancella i log più vecchi del limite.
- **Container rootless** sotto l'utente dedicato del modulo; firewall con le
  sole porte indispensabili.
- **Immagini aggiornate**: l'immagine della console applica gli
  aggiornamenti di sicurezza di Alpine a ogni build; Renovate segnala le
  nuove versioni; il workflow `security-scan.yml` analizza ogni settimana le
  immagini pubblicate con Trivy (risultati in **Security → Code scanning**).

### Cosa devi fare tu

1. **Cambia la password di `admin`** al primo accesso. La password iniziale
   resta scritta nel journal: una volta cambiata non è più valida.
2. **Imposta `admin_allowlist`** con gli IP dell'ufficio o della VPN, se la
   console la usate solo da lì.
3. **Proteggi i computer assistiti** dalle impostazioni di sicurezza del
   client RustDesk:
   - per l'assistenza occasionale, lascia che sia l'utente ad accettare la
     connessione con un clic, senza password permanente;
   - per l'accesso non presidiato, usa una password permanente lunga e
     diversa per ogni macchina e attiva l'autenticazione a due fattori;
   - concedi solo i permessi necessari (ad esempio niente trasferimento file
     o terminale se non servono).
4. **Aggiorna regolarmente** il modulo e controlla gli avvisi di Renovate e
   della scansione settimanale.
5. **Privacy**: i log contengono IP, utenti e orari delle connessioni, cioè
   dati personali. Indica nell'informativa che li raccogli e per quanto tempo
   (`log_retention_days`).

### Limiti noti

- **Uso del relay da parte di terzi.** La chiave è pubblica per natura (è
  anche nel nome dell'installer che distribuisci): chi la conosce può usare
  il server per le proprie connessioni. hbbr limita la banda (32 Mb/s per
  connessione, 1 Gb/s in totale). Il fork `lejianwen/rustdesk-server`
  offre `MUST_LOGIN` per accettare solo utenti autenticati, ma è basato su
  una versione più vecchia del server e non è aggiornato da settembre 2025:
  il modulo resta sul server ufficiale, che riceve le correzioni di
  sicurezza.
- **rustdesk-api non è più sviluppato attivamente** (ultimo commit a
  settembre 2025). Il modulo mitiga il rischio con gli aggiornamenti di
  Alpine, la scansione settimanale e la possibilità di limitare la console
  per IP. Se la scansione segnala una vulnerabilità grave non corretta,
  valuta la migrazione a un'alternativa mantenuta (ad esempio CortenDesk,
  che importa i dati di rustdesk-api).

## Backup e ripristino

Il backup di NS8 include i volumi:

- `rustdesk-data`: la coppia di chiavi di hbbs. **Se la perdi, devi
  riconfigurare la chiave su tutti i client.**
- `rustdesk-api-data`: il database della console web.

Al ripristino il modulo rilegge la configurazione originale e riavvia i servizi.

## Aggiornamento

    api-cli run update-module --data '{
      "module_url": "ghcr.io/startappsrl/rustdesk:1.1.0",
      "instances": ["rustdesk1"]
    }'

## Disinstallazione

    remove-module --no-preserve rustdesk1

La rimozione cancella anche la rotta Traefik e chiude le porte nel firewall.

## Debug

    runagent -m rustdesk1 systemctl --user status hbbs hbbr rustdesk-api
    runagent -m rustdesk1 journalctl --user -u hbbs -f
    runagent -m rustdesk1 podman ps

---

## Sviluppo e release

### Struttura del repository

    build-images.sh                  build dell'immagine del modulo (buildah)
    imageroot/
      actions/create-module/         apertura porte firewall
      actions/configure-module/      validazione host, env, rotta Traefik, avvio
      actions/get-configuration/     lettura configurazione e chiave pubblica
      actions/destroy-module/        rimozione rotta e regole firewall
      actions/restore-module/        ripristino da backup
      bin/wait-key                   attende le chiavi di hbbs prima di avviare hbbr e l'API
      bin/purge-logs                 cancella i log oltre il periodo di conservazione
      etc/state-include.conf         cosa finisce nel backup
      systemd/user/*.service         unit dei tre container
      update-module.d/               hook eseguiti dopo update-module
    rustdesk-api/                    immagine della console web in italiano
    ui/                              interfaccia del modulo (Vue 2 + Carbon)
    tests/                           test Robot Framework
    .github/workflows/               build, pubblicazione e test

### Primo setup su GitHub

1. Crea il repository vuoto `ns8-rustdesk` sul tuo account GitHub.
2. Sostituisci `startappsrl` con il tuo nome utente in `build-images.sh`,
   `README.md` e `ui/public/metadata.json` (in `metadata.json` il campo
   `source` va in minuscolo), e i dati dell'autore in `metadata.json`:

       grep -rl startappsrl . | xargs sed -i 's/startappsrl/mio-utente/g'
       sed -i 's/tuo-utente/mio-utente/' ui/public/metadata.json

3. Pubblica il codice:

       git init -b main
       git add -A
       git commit -m "Initial import"
       git remote add origin git@github.com:startappsrl/ns8-rustdesk.git
       git push -u origin main

4. Il workflow **Publish images** costruisce l'immagine e la pubblica come
   `ghcr.io/startappsrl/rustdesk:main` (e `:latest`).
5. Su GitHub, in **Packages → rustdesk → Package settings**, imposta la
   visibilità su **Public**: NS8 non può scaricare immagini private. Fai lo
   stesso per il package **rustdesk-api**.

### Ciclo di sviluppo

Ogni push su un branch pubblica un'immagine con il nome del branch (gli `/`
diventano `-`). Per provare una modifica:

    git switch -c feat-web-client
    # ...modifiche...
    git push -u origin feat-web-client
    # sul nodo di test:
    add-module ghcr.io/startappsrl/rustdesk:feat-web-client 1

Quando funziona, apri una pull request e fai merge su `main`.

### Release

Le versioni seguono il [semantic versioning](https://semver.org) **senza** il
prefisso `v` (`1.0.0`, non `v1.0.0`): il tag Git diventa il tag dell'immagine,
e NS8 lo usa come versione del modulo.

    git switch main && git pull
    gh release create 1.0.0 --generate-notes

Il tag avvia **Publish images**, che pubblica `ghcr.io/startappsrl/rustdesk:1.0.0`.
Le note di rilascio vengono generate dalle pull request, raggruppate per
etichetta secondo `.github/release.yml`. Per una pre-release usa ad esempio
`1.1.0-rc.1` con `gh release create 1.1.0-rc.1 --prerelease --generate-notes`.

Regola pratica per il numero di versione:

- **patch** (`1.0.1`): correzioni, aggiornamento delle immagini upstream
- **minor** (`1.1.0`): nuove opzioni compatibili (es. client da browser con WSS)
- **major** (`2.0.0`): modifiche che richiedono interventi manuali

### Aggiornamenti delle immagini upstream

`renovate.json` configura [Renovate](https://github.com/apps/renovate) per
aprire automaticamente una pull request quando escono nuove versioni di
`rustdesk/rustdesk-server` o `lejianwen/rustdesk-api`. Installa l'app Renovate
sul repository per attivarlo.

### Workflow opzionali

`test-module.yml` esegue i test di `tests/` su una macchina virtuale e
`build-apidoc.yml` genera la documentazione delle API: sono ereditati da
`ns8-kickstart` e si appoggiano a `NethServer/ns8-github-actions`. Se non ti
servono, disabilitali dalla scheda **Actions** del repository.

### Build locale

    ./build-images.sh
    buildah push ghcr.io/startappsrl/rustdesk docker://ghcr.io/startappsrl/rustdesk:dev

## Licenza

GPL-3.0-or-later, vedi [LICENSE](LICENSE). Basato sul template
[ns8-kickstart](https://github.com/NethServer/ns8-kickstart).
