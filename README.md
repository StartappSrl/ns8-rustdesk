# ns8-rustdesk

Modulo [NethServer 8](https://github.com/NethServer/ns8-core) che installa un
server [RustDesk](https://rustdesk.com) self-hosted con console web.

Il modulo esegue tre container Podman rootless:

| Servizio | Immagine | Ruolo | Porte |
|---|---|---|---|
| `hbbs.service` | `rustdesk/rustdesk-server` | Server ID / rendezvous | 21115/tcp, 21116/tcp+udp (21118/tcp per il client da browser) |
| `hbbr.service` | `rustdesk/rustdesk-server` | Server relay | 21117/tcp (21119/tcp per il client da browser) |
| `rustdesk-api.service` | `lejianwen/rustdesk-api` | Server API e console web: utenti, dispositivi, rubriche, log | 127.0.0.1:`TCP_PORT`, pubblicata da Traefik in HTTPS |

hbbs e hbbr usano la rete dell'host, necessaria per le connessioni dirette
(P2P). Poiché le porte sono fisse, è possibile **una sola istanza per nodo**.

Le versioni delle immagini sono fissate in `build-images.sh`.

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
| `web_client` | Abilita il client da browser e apre le porte 21118 e 21119 (vedi sotto) |

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

Il client web di rustdesk-api si collega a hbbs/hbbr tramite websocket sulle
porte 21118 e 21119. I browser rifiutano i websocket non cifrati (`ws://`) da
una pagina HTTPS, quindi con la sola opzione `web_client` il client da browser
si apre ma non si connette. Serve un proxy TLS (`wss://`) davanti a queste
porte, da impostare poi in `RUSTDESK_API_RUSTDESK_WS_HOST`. Questa parte non è
ancora automatizzata nel modulo: è il candidato naturale per una prossima
release.

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
      bin/wait-key                   attende la chiave di hbbs prima di avviare l'API
      etc/state-include.conf         cosa finisce nel backup
      systemd/user/*.service         unit dei tre container
      update-module.d/               hook eseguiti dopo update-module
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
   visibilità su **Public**: NS8 non può scaricare immagini private.

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
