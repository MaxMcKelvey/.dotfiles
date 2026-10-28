# `~/.dotfiles/.ai`

Personal Cursor Agent Skills, versioned with the rest of the dotfiles.

## How Cursor skills work

A skill is a directory with a `SKILL.md` (YAML frontmatter + markdown). Cursor lists skills in the agent prompt. The `description` is how the model decides whether to **open** the file.

| Kind | Path | Who sees it |
|---|---|---|
| Personal | `~/.cursor/skills/<name>/SKILL.md` | Every local project |
| Project | `<repo>/.cursor/skills/<name>/SKILL.md` | Anyone who clones that repo |
| Built-in | `~/.cursor/skills-cursor/` | Cursor-managed — do not edit |

Rules (`.cursor/rules/*.mdc`) are different: they inject continuously. Skills are **on-demand** — keep them short, put tables in `reference.md`, and write a description that includes both **what** and **when**.

Omit `disable-model-invocation` so the agent can auto-open from the description. Set it `true` only if the skill should run when the user names it.

## Layout

```
.ai/
  README.md
  skills/                          ← this directory is ~/.cursor/skills
    esp-platformio-serial/
    ble-nimble-pairing/
    garmin-connect-iq-ble/
```

## Wire Cursor to this tree

```sh
# If ~/.cursor/skills is a real directory with only generated/personal skills,
# move them here first, then replace the directory with a symlink:
rm -rf ~/.cursor/skills
ln -sfn ~/.dotfiles/.ai/skills ~/.cursor/skills
```

Do not symlink or copy `~/.cursor/skills-cursor/`.
