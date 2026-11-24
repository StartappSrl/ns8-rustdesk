# Untitled integer in configure-module input Schema

```txt
http://schema.nethserver.org/rustdesk/configure-module-input.json#/properties/log_retention_days
```

Days to keep login, connection and file transfer logs. 0 keeps them forever

| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                   |
| :------------------ | :--------- | :------------- | :---------------------- | :---------------- | :-------------------- | :------------------ | :------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [configure-module-input.json\*](rustdesk/configure-module-input.json "open original schema") |

## log_retention_days Type

`integer`

## log_retention_days Constraints

**maximum**: the value of this number must smaller than or equal to: `3650`

**minimum**: the value of this number must greater than or equal to: `0`
