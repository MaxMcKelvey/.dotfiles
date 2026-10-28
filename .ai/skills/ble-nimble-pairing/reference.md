# NimBLE status values (ESP-IDF 5/6)

| Value | Meaning |
|---|---|
| `enc change status=0` | Pairing/encryption succeeded |
| `1283` (`0x503`) | `BLE_HS_SM_PEER_ERR(0x03)` — **peer** sent Authentication Requirements |
| `1027` (`0x403`) | `BLE_HS_SM_US_ERR(0x03)` — **we** sent AUTHREQ |
| `7` | `BLE_HS_ENOTCONN` — encryption finished after the link was gone |
| disconnect `531` | HCI remote user terminated (`0x200+0x13`) |

IO caps: `0` DisplayOnly, `1` DisplayYesNo, `2` KeyboardOnly, `3` NoInputNoOutput, `4` KeyboardDisplay.

With MITM requested:

- NoInput × KeyboardDisplay → Just Works (Settings often AUTHREQ)
- DisplayYesNo × KeyboardDisplay → numeric comparison
- DisplayOnly × KeyboardDisplay → phone **enters** passkey we display
- KeyboardOnly × KeyboardDisplay → we **enter** passkey the phone displays
