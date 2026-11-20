# get-configuration output Schema

```txt
http://schema.nethserver.org/rustdesk/get-configuration-output.json
```

Get the RustDesk configuration

| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                     |
| :------------------ | :--------- | :------------- | :----------- | :---------------- | :-------------------- | :------------------ | :--------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Allowed               | none                | [get-configuration-output.json](rustdesk/get-configuration-output.json "open original schema") |

## get-configuration output Type

`object` ([get-configuration output](get-configuration-output.md))

## get-configuration output Examples

```json
{
  "host": "rustdesk.example.org",
  "rustdesk_host": "rustdesk.example.org",
  "lets_encrypt": true,
  "http2https": true,
  "web_client": false,
  "public_key": "kXq2V8...=",
  "ban_threshold": 5,
  "log_retention_days": 180,
  "admin_allowlist": [
    "192.168.1.0/24"
  ]
}
```

# get-configuration output Properties

| Property                                  | Type      | Required | Nullable       | Defined by                                                                                                                                                                                 |
| :---------------------------------------- | :-------- | :------- | :------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [host](#host)                             | `string`  | Required | cannot be null | [get-configuration output](get-configuration-output-properties-host.md "http://schema.nethserver.org/rustdesk/get-configuration-output.json#/properties/host")                             |
| [rustdesk_host](#rustdesk_host)           | `string`  | Required | cannot be null | [get-configuration output](get-configuration-output-properties-rustdesk_host.md "http://schema.nethserver.org/rustdesk/get-configuration-output.json#/properties/rustdesk_host")           |
| [lets_encrypt](#lets_encrypt)             | `boolean` | Required | cannot be null | [get-configuration output](get-configuration-output-properties-lets_encrypt.md "http://schema.nethserver.org/rustdesk/get-configuration-output.json#/properties/lets_encrypt")             |
| [http2https](#http2https)                 | `boolean` | Required | cannot be null | [get-configuration output](get-configuration-output-properties-http2https.md "http://schema.nethserver.org/rustdesk/get-configuration-output.json#/properties/http2https")                 |
| [web_client](#web_client)                 | `boolean` | Required | cannot be null | [get-configuration output](get-configuration-output-properties-web_client.md "http://schema.nethserver.org/rustdesk/get-configuration-output.json#/properties/web_client")                 |
| [public_key](#public_key)                 | `string`  | Required | cannot be null | [get-configuration output](get-configuration-output-properties-public_key.md "http://schema.nethserver.org/rustdesk/get-configuration-output.json#/properties/public_key")                 |
| [ban_threshold](#ban_threshold)           | `integer` | Required | cannot be null | [get-configuration output](get-configuration-output-properties-ban_threshold.md "http://schema.nethserver.org/rustdesk/get-configuration-output.json#/properties/ban_threshold")           |
| [log_retention_days](#log_retention_days) | `integer` | Required | cannot be null | [get-configuration output](get-configuration-output-properties-log_retention_days.md "http://schema.nethserver.org/rustdesk/get-configuration-output.json#/properties/log_retention_days") |
| [admin_allowlist](#admin_allowlist)       | `array`   | Required | cannot be null | [get-configuration output](get-configuration-output-properties-admin_allowlist.md "http://schema.nethserver.org/rustdesk/get-configuration-output.json#/properties/admin_allowlist")       |

## host



`host`

* is required

* Type: `string`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-host.md "http://schema.nethserver.org/rustdesk/get-configuration-output.json#/properties/host")

### host Type

`string`

## rustdesk_host



`rustdesk_host`

* is required

* Type: `string`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-rustdesk_host.md "http://schema.nethserver.org/rustdesk/get-configuration-output.json#/properties/rustdesk_host")

### rustdesk_host Type

`string`

## lets_encrypt



`lets_encrypt`

* is required

* Type: `boolean`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-lets_encrypt.md "http://schema.nethserver.org/rustdesk/get-configuration-output.json#/properties/lets_encrypt")

### lets_encrypt Type

`boolean`

## http2https



`http2https`

* is required

* Type: `boolean`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-http2https.md "http://schema.nethserver.org/rustdesk/get-configuration-output.json#/properties/http2https")

### http2https Type

`boolean`

## web_client



`web_client`

* is required

* Type: `boolean`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-web_client.md "http://schema.nethserver.org/rustdesk/get-configuration-output.json#/properties/web_client")

### web_client Type

`boolean`

## public_key

hbbs public key, empty until hbbs starts for the first time

`public_key`

* is required

* Type: `string`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-public_key.md "http://schema.nethserver.org/rustdesk/get-configuration-output.json#/properties/public_key")

### public_key Type

`string`

## ban_threshold



`ban_threshold`

* is required

* Type: `integer`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-ban_threshold.md "http://schema.nethserver.org/rustdesk/get-configuration-output.json#/properties/ban_threshold")

### ban_threshold Type

`integer`

## log_retention_days



`log_retention_days`

* is required

* Type: `integer`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-log_retention_days.md "http://schema.nethserver.org/rustdesk/get-configuration-output.json#/properties/log_retention_days")

### log_retention_days Type

`integer`

## admin_allowlist



`admin_allowlist`

* is required

* Type: `string[]`

* cannot be null

* defined in: [get-configuration output](get-configuration-output-properties-admin_allowlist.md "http://schema.nethserver.org/rustdesk/get-configuration-output.json#/properties/admin_allowlist")

### admin_allowlist Type

`string[]`
