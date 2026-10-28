---
name: ble-nimble-pairing
description: >-
  NimBLE dual-role BLE, Android Settings pairing, SMP passkeys, and HID
  pitfalls. Use when debugging bonds, Just Works, PIN, numeric comparison,
  AUTHREQ 1283, security_initiate, or advertising a phone-pairable ESP32
  peripheral.
---

# NimBLE pairing (Android Settings)

Android Settings pairing is **not** a companion-app Just Works flow.

## IO cap + MITM (phone is usually KeyboardDisplay)

| Goal | Peripheral | Phone |
|---|---|---|
| No UI, often fails | NoInput + `mitm=0` | AUTHREQ in ~0.6s |
| 6-digit compare | DisplayYesNo + MITM | Numeric comparison (~30s SMP) |
| Phone **types** a code | DisplayOnly + MITM | PIN box |
| Phone **shows** a code | KeyboardOnly + MITM | Enter it on the ESP (UART) |

Do **not** advertise HID (`0x1812`) or keyboard appearance unless it **is** a keyboard. HID → “type PIN on the keyboard” → **incorrect PIN** with no box.

- SMP timeout is **30s on both sides**. Extending only the ESP does not keep the Android dialog open.
- If the user needs minutes: **arm** a passkey on UART first (`pair NNNNNN`), then tap and type it **on the phone** (DisplayOnly).
- Failed attempts often never show Forget. Toggle Bluetooth. Clear ESP NVS bonds separately.
- Do not `security_initiate` again on a link that already got AUTHREQ; wait for reconnect.
- `STATIC_PASSKEY` in sdkconfig forces passkey even when IO caps say Just Works. Leave it unset unless you want a fixed PIN.

## Dual-role radio

- Stop advert while scanning if the controller needs it; restart after.
- Keep advertising after a peripheral connect if more centrals should join.
- Primary advert **≤ 31 bytes**.

Status codes: [reference.md](reference.md).
