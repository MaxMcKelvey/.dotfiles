---
name: esp-platformio-serial
description: >-
  Flash and monitor ESP32 with PlatformIO/ESP-IDF over Linux USB-serial. Use
  when using pio, ttyACM, sg dialout, Seeed XIAO ESP32-C3, serial monitors, or
  sdkconfig/NVS on ESP-IDF NimBLE dual-role firmware.
---

# ESP32, PlatformIO, USB serial

Do not hardcode a repo’s ACM port or secrets. Discover the port each time.

## Agent serial

- Agent shells are often **not** in `dialout`. Use `sg dialout -c '…'`. Do **not** `sudo`.
- USB-Serial/JTAG (XIAO ESP32-C3): `/dev/ttyACM*`. **One** process per port.
- Kill the monitor **by PID** before `pio run -t upload`. Wait ~2s — USB can bounce.
- Do not `pkill -f` a string that also appears in the current agent command (it kills itself).
- Do not assert DTR/RTS (they reset C3). Pattern:

```text
Serial(port, 115200, rtscts=False, dsrdtr=False); dtr=False; rts=False
TX: a cmd file the reader thread writes as a line + newline
```

```bash
sg dialout -c 'pio run -t upload --upload-port /dev/ttyACMN'
```

## PlatformIO + ESP-IDF

- `pio run` then upload. Board `sdkconfig.*` + `sdkconfig.defaults` must agree; `.pio/build/.../config` is stale until rebuild.
- Do not patch `~/.platformio/packages/framework-espidf`. Timeouts and Kconfig belong in the **project**.
- Dual-role NimBLE (central + peripheral) needs enough `MAX_CONNECTIONS`, `MAX_BONDS`, `BLE_MAX_ACT`, `NVS_PERSIST`.
- App flash does **not** always wipe NVS bonds. Provide a console clear (`forget_ble` or equivalent).
