# .dotfiles

## Instructions for zsh

1. Source .dotfiles/.zshrc
2. Follow the powerlevel10k setup instructions
3. Put `source ~/.dotfiles/.zshrc` at the top of your .zshrc file
4. Install zoxide (`brew install zoxide` or with your linux package manager)
5. Install fzf
6. Install tmux
7. Install nvim

## Instructions for nvim

1. `ln -s ~/.dotfiles/.config/nvim ~/.config/nvim` to softlink your nvim config into your .config dir
2. `n .` to open neovim
3. `git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim`
4. `:q` and `n .` to reopen neovim
5. `:PackerSync` to install packages with packer

## Instructions for tmux

1. `ln -s ~/.dotfiles/.tmux.conf ~/.tmux.conf`
2. run `tmux` to start your tmux session

<br/>
---

## Condensed instructions for Ubuntu

```sh
sudo apt update
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt install zsh build-essential neovim tmux fzf zoxide -y

# if you also need node
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

## Caps Lock to Escape Instructions (Windows)

Go to [https://www.autohotkey.com/](https://www.autohotkey.com/), download V2, and do the installation.

Right click in finder, and click new -> autohotkey script.

Open with terminal and paste in:

```ahk
#Requires AutoHotkey v2.0
; Make Caps Lock act as Escape unless Shift is held (AHK v2)

CapsLock:: {
    if GetKeyState("Shift", "P")
        Send("{CapsLock}")  ; If Shift is held, send normal CapsLock
    else
        Send("{Escape}")    ; Otherwise, send Escape
}



; Remap Copilot key (F23 / sc06E) to Left Ctrl
sc06E::Ctrl


; Alt + `  → next window of the same app
!`::CycleAppWindow(1)
; Alt + Shift + `  → previous window of the same app
+!`::CycleAppWindow(-1)

CycleAppWindow(dir := 1) {
    active := WinExist("A")
    if !active
        return

    exe := WinGetProcessName("ahk_id " active)
    if !exe
        return

    DetectHiddenWindows false

    ; Collect all visible, non-tool windows for the same executable
    wins := WinGetList("ahk_exe " exe)
    filtered := []
    for hwnd in wins {
        style := WinGetStyle("ahk_id " hwnd)        ; WS_VISIBLE = 0x10000000
        ex    := WinGetExStyle("ahk_id " hwnd)      ; WS_EX_TOOLWINDOW = 0x00000080
        if !(style & 0x10000000)            ; not visible
            continue
        if (ex & 0x00000080)                ; skip tool/utility windows
            continue
        filtered.Push(hwnd)
    }

    if filtered.Length <= 1
        return

    ; Find current window index in the filtered list
    idx := 0
    for i, hwnd in filtered {
        if (hwnd = active) {
            idx := i
            break
        }
    }
    if (idx = 0)
        idx := 1

    ; Compute next/previous index (wrap around)
    nextIdx := (dir > 0) ? (idx + 1) : (idx - 1)
    if (nextIdx > filtered.Length)
        nextIdx := 1
    if (nextIdx < 1)
        nextIdx := filtered.Length

    target := filtered[nextIdx]
    if (WinGetMinMax("ahk_id " target) = -1)  ; if minimized, restore first
        WinRestore "ahk_id " target
    WinActivate "ahk_id " target
}
```

Double click to run!

Press `Win + R` → type `shell:startup` → Enter.

Copy the script into this folder for it to run on startup!
