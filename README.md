# dotenv

Configuração do meu ambiente, versionada. Um script instala tudo — Ghostty, zsh, Neovim e git — igual em Linux e macOS.

## Como usar

Com git instalado:

```sh
git clone git@github.com:fabiomaciel/dotenv.git ~/git/dotenv
cd ~/git/dotenv
./install --dry-run   # mostra o que seria feito
./install             # aplica
```

Sem git (máquina zerada) — baixa os arquivos direto do GitHub, sem clonar:

```sh
curl -fsSL https://raw.githubusercontent.com/fabiomaciel/dotenv/main/install-raw | bash
cd dotenv
./install
```

O `install-raw` só baixa o projeto para `./dotenv`; ele não instala nada.

Depois: reinicie o Ghostty e abra o `nvim` uma vez (ele termina de instalar os LSPs).

O `git/` é interativo: pergunta nome, e-mail e se o GitHub usa ssh ou https.

## O que tem

| Pasta | O que instala |
|---|---|
| `ghostty/` | Ghostty, zsh (oh-my-zsh, powerlevel10k, plugins), fonte MesloLGS, `.zshrc`, `.bashrc`, `.p10k.zsh` |
| `nvim/` | Neovim com lazy.nvim, os plugins do `lazy-lock.json`, LSPs e tree-sitter |
| `git/` | Identidade do git (nome/e-mail), protocolo ssh ou https, chave SSH registrada no GitHub via `gh`, e credential helper para o https não pedir senha |

Cada pasta tem um `install` próprio, que detecta o OS e chama `linux/install` ou `macos/install`. O `install` da raiz roda os três.

## Como funciona

- **Idempotente**: pode rodar quantas vezes quiser; o que já está certo é pulado.
- **Backup**: arquivos existentes viram `.bak.<timestamp>` antes de serem trocados.
- **`--dry-run`**: mostra as ações sem alterar nada.
- **Falha em passo opcional**: pergunta se quer continuar sem (sem terminal interativo, assume sim).

Os arquivos que ficam fora do repo (plugins do lazy, LSPs do mason, parsers do tree-sitter) são gerados pelo próprio instalador, não versionados.
