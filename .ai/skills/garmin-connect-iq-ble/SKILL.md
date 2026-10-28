---
name: garmin-connect-iq-ble
description: >-
  Garmin Connect IQ BLE peripherals on ESP32 NimBLE. Use when writing watch
  widgets/glances, monkeyc builds, 16-bit GATT UUIDs, unbonded watch writes, or
  sharing one ESP peripheral between a phone and a Forerunner.
---

# Garmin Connect IQ BLE

## Advert and GATT

- Prefer **16-bit UUIDs** (`0000xxxx-0000-1000-8000-00805f9b34fb`). 128-bit UUIDs mismatch endianness with Garmin/NimBLE.
- Advertise the **same** UUID the watch scans for. Garmin often **ignores scan response**; keep the primary packet ≤ 31 bytes.
- Unlock/write characteristic: `WRITE` and/or `WRITE_NO_RSP`. Token ≤ **20 bytes**.
- Keep the watch link up after the first write if the next press should be GATT-only.

## Bonding

- Leave the watch **unbonded**. Pairing popups on the watch drop Connect IQ.
- Do **not** `security_initiate` on a watch connection. Detect the watch by a write to the unlock characteristic; skip phone pairing for that handle.

## App

- Glance + `widget` manifest = At a Glance on Forerunner; not Activities.
- Sideload settings persist empty properties — bake the token in resources/source and **gitignore** it.
- Build and install:

```bash
monkeyc -f monkey.jungle -o bin/app.prg -d <device> -y ~/.garmin/developer_key.der -w
cp bin/app.prg /media/$USER/GARMIN/APPS/
```
