# dotenv

Configuração do meu terminal, versionada. Um script instala tudo — Ghostty, zsh e Neovim — igual em Linux e macOS.

## Como usar

```sh
git clone <repo> ~/git/dotenv
cd ~/git/dotenv
./install.sh --dry-run   # mostra o que seria feito
./install.sh             # aplica
```

Depois: reinicie o Ghostty e abra o `nvim` uma vez (ele termina de instalar os LSPs).

## O que tem

| Pasta | O que instala |
|---|---|
| `ghostty/` | Ghostty, zsh (oh-my-zsh, powerlevel10k, plugins), fonte MesloLGS, `.zshrc`, `.bashrc`, `.p10k.zsh` |
| `nvim/` | Neovim com lazy.nvim, os plugins do `lazy-lock.json`, LSPs e tree-sitter |

Cada pasta tem um `install.sh` próprio, que detecta o OS e chama `linux/install.sh` ou `macos/install.sh`. O `install.sh` da raiz roda os dois.

## Como funciona

- **Idempotente**: pode rodar quantas vezes quiser; o que já está certo é pulado.
- **Backup**: arquivos existentes viram `.bak.<timestamp>` antes de serem trocados.
- **`--dry-run`**: mostra as ações sem alterar nada.
- **Falha em passo opcional**: pergunta se quer continuar sem (sem terminal interativo, assume sim).

Os arquivos que ficam fora do repo (plugins do lazy, LSPs do mason, parsers do tree-sitter) são gerados pelo próprio instalador, não versionados.
