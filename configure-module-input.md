# configure-module input Schema

```txt
http://schema.nethserver.org/rustdesk/configure-module-input.json
```

Configure the RustDesk server and its web console

| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                 |
| :------------------ | :--------- | :------------- | :----------- | :---------------- | :-------------------- | :------------------ | :----------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Allowed               | none                | [configure-module-input.json](rustdesk/configure-module-input.json "open original schema") |

## configure-module input Type

`object` ([configure-module input](configure-module-input.md))

## configure-module input Examples

```json
{
  "host": "rustdesk.example.org",
  "rustdesk_host": "rustdesk.example.org",
  "lets_encrypt": true,
  "http2https": true,
  "web_client": false,
  "ban_threshold": 5,
  "log_retention_days": 180,
  "admin_allowlist": [
    "203.0.113.10",
    "192.168.1.0/24"
  ]
}
```

# configure-module input Properties

| Property                                  | Type      | Required | Nullable       | Defined by                                                                                                                                                                           |
| :---------------------------------------- | :-------- | :------- | :------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [host](#host)                             | `string`  | Required | cannot be null | [configure-module input](configure-module-input-properties-host.md "http://schema.nethserver.org/rustdesk/configure-module-input.json#/properties/host")                             |
| [rustdesk_host](#rustdesk_host)           | `string`  | Optional | cannot be null | [configure-module input](configure-module-input-properties-rustdesk_host.md "http://schema.nethserver.org/rustdesk/configure-module-input.json#/properties/rustdesk_host")           |
| [lets_encrypt](#lets_encrypt)             | `boolean` | Required | cannot be null | [configure-module input](configure-module-input-properties-lets_encrypt.md "http://schema.nethserver.org/rustdesk/configure-module-input.json#/properties/lets_encrypt")             |
| [http2https](#http2https)                 | `boolean` | Required | cannot be null | [configure-module input](configure-module-input-properties-http2https.md "http://schema.nethserver.org/rustdesk/configure-module-input.json#/properties/http2https")                 |
| [web_client](#web_client)                 | `boolean` | Optional | cannot be null | [configure-module input](configure-module-input-properties-web_client.md "http://schema.nethserver.org/rustdesk/configure-module-input.json#/properties/web_client")                 |
| [ban_threshold](#ban_threshold)           | `integer` | Optional | cannot be null | [configure-module input](configure-module-input-properties-ban_threshold.md "http://schema.nethserver.org/rustdesk/configure-module-input.json#/properties/ban_threshold")           |
| [log_retention_days](#log_retention_days) | `integer` | Optional | cannot be null | [configure-module input](configure-module-input-properties-log_retention_days.md "http://schema.nethserver.org/rustdesk/configure-module-input.json#/properties/log_retention_days") |
| [admin_allowlist](#admin_allowlist)       | `array`   | Optional | cannot be null | [configure-module input](configure-module-input-properties-admin_allowlist.md "http://schema.nethserver.org/rustdesk/configure-module-input.json#/properties/admin_allowlist")       |

## host

Fully qualified domain name of the web console

`host`

* is required

* Type: `string`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-host.md "http://schema.nethserver.org/rustdesk/configure-module-input.json#/properties/host")

### host Type

`string`

### host Constraints

**pattern**: the string must match the following regular expression:&#x20;

```regexp
\.
```

[try pattern](https://regexr.com/?expression=%5C. "try regular expression with regexr.com")

**hostname**: the string must be a hostname, according to [RFC 1123, section 2.1](https://tools.ietf.org/html/rfc1123 "check the specification")

## rustdesk_host

Host name or IP address that RustDesk clients use for the ID and relay servers. Defaults to host

`rustdesk_host`

* is optional

* Type: `string`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-rustdesk_host.md "http://schema.nethserver.org/rustdesk/configure-module-input.json#/properties/rustdesk_host")

### rustdesk_host Type

`string`

### rustdesk_host Constraints

**maximum length**: the maximum number of characters for this string is: `253`

## lets_encrypt

Request a Let's Encrypt certificate for the web console

`lets_encrypt`

* is required

* Type: `boolean`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-lets_encrypt.md "http://schema.nethserver.org/rustdesk/configure-module-input.json#/properties/lets_encrypt")

### lets_encrypt Type

`boolean`

## http2https

Redirect HTTP requests to HTTPS

`http2https`

* is required

* Type: `boolean`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-http2https.md "http://schema.nethserver.org/rustdesk/configure-module-input.json#/properties/http2https")

### http2https Type

`boolean`

## web_client

Enable the browser client at https\://<host>/webclient/. It connects to hbbs and hbbr through Traefik (wss\://<host>/ws/id and /ws/relay)

`web_client`

* is optional

* Type: `boolean`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-web_client.md "http://schema.nethserver.org/rustdesk/configure-module-input.json#/properties/web_client")

### web_client Type

`boolean`

## ban_threshold

Failed logins within 5 minutes after which the client IP is blocked for 30 minutes. 0 disables the block

`ban_threshold`

* is optional

* Type: `integer`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-ban_threshold.md "http://schema.nethserver.org/rustdesk/configure-module-input.json#/properties/ban_threshold")

### ban_threshold Type

`integer`

### ban_threshold Constraints

**maximum**: the value of this number must smaller than or equal to: `100`

**minimum**: the value of this number must greater than or equal to: `0`

## log_retention_days

Days to keep login, connection and file transfer logs. 0 keeps them forever

`log_retention_days`

* is optional

* Type: `integer`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-log_retention_days.md "http://schema.nethserver.org/rustdesk/configure-module-input.json#/properties/log_retention_days")

### log_retention_days Type

`integer`

### log_retention_days Constraints

**maximum**: the value of this number must smaller than or equal to: `3650`

**minimum**: the value of this number must greater than or equal to: `0`

## admin_allowlist

IP addresses or CIDR networks allowed to open the web console. Empty allows everyone

`admin_allowlist`

* is optional

* Type: `string[]`

* cannot be null

* defined in: [configure-module input](configure-module-input-properties-admin_allowlist.md "http://schema.nethserver.org/rustdesk/configure-module-input.json#/properties/admin_allowlist")

### admin_allowlist Type

`string[]`

### admin_allowlist Constraints

**maximum number of items**: the maximum number of items for this array is: `50`
