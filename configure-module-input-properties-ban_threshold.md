# Untitled integer in configure-module input Schema

```txt
http://schema.nethserver.org/rustdesk/configure-module-input.json#/properties/ban_threshold
```

Failed logins within 5 minutes after which the client IP is blocked for 30 minutes. 0 disables the block

| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                   |
| :------------------ | :--------- | :------------- | :---------------------- | :---------------- | :-------------------- | :------------------ | :------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [configure-module-input.json\*](rustdesk/configure-module-input.json "open original schema") |

## ban_threshold Type

`integer`

## ban_threshold Constraints

**maximum**: the value of this number must smaller than or equal to: `100`

**minimum**: the value of this number must greater than or equal to: `0`
