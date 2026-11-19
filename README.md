# Instalação do Docker e Docker Compose no Ubuntu

Guia passo a passo para instalar o **Docker Engine** e o **Docker Compose (plugin v2)** em um servidor Ubuntu.

## Índice

1. [Pré-requisitos](#pré-requisitos)
2. [Atualizar o sistema](#1-atualizar-o-sistema)
3. [Instalar dependências](#2-instalar-dependências)
4. [Adicionar o repositório oficial do Docker](#3-adicionar-o-repositório-oficial-do-docker)
5. [Instalar o Docker](#4-instalar-o-docker)
6. [Usar o Docker sem sudo](#5-usar-o-docker-sem-sudo)
7. [Instalar o Docker Compose](#6-instalar-o-docker-compose)
8. [Testando a instalação](#7-testando-a-instalação)
9. [Solução de problemas](#solução-de-problemas)

---

## Pré-requisitos

- Ubuntu (20.04, 22.04 ou superior)
- Usuário com permissão `sudo`
- Acesso à internet
- Arquitetura x86_64 (para ARM, veja a observação no passo 6)

---

## 1. Atualizar o sistema

```bash
sudo apt update && sudo apt upgrade -y
```

---

## 2. Instalar dependências

```bash
sudo apt install apt-transport-https ca-certificates curl software-properties-common
```

---

## 3. Adicionar o repositório oficial do Docker

Baixe e registre a chave GPG:

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

Adicione o repositório às fontes do apt:

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Atualize a lista de pacotes:

```bash
sudo apt update
```

---

## 4. Instalar o Docker

```bash
sudo apt install docker-ce
```

Confirme a versão instalada:

```bash
docker --version
```

---

## 5. Usar o Docker sem sudo

Adicione seu usuário ao grupo `docker`:

```bash
sudo usermod -aG docker ${USER}
```

Aplique a mudança de grupo na sessão atual:

```bash
su - ${USER}
```

> Se preferir, saia e entre novamente na sessão (logout/login).

---

## 6. Instalar o Docker Compose

Crie a pasta de plugins do Docker:

```bash
mkdir -p ~/.docker/cli-plugins/
```

Baixe o binário do Compose (v2.27.1):

```bash
curl -SL https://github.com/docker/compose/releases/download/v2.27.1/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
```

Dê permissão de execução:

```bash
chmod +x ~/.docker/cli-plugins/docker-compose
```

Confirme a instalação:

```bash
docker compose version
```

> **Observação (ARM / Raspberry Pi):** troque `docker-compose-linux-x86_64` por `docker-compose-linux-aarch64` no link de download.

---

## 7. Testando a instalação

```bash
docker run hello-world
```

Se aparecer a mensagem "Hello from Docker!", está tudo funcionando.

---

## Solução de problemas

| Problema | Solução |
|---|---|
| `permission denied` ao rodar `docker` | Refaça o passo 5 e faça logout/login |
| `docker: command not found` | Verifique se o passo 4 terminou sem erros |
| `docker compose` não é reconhecido | Confira se o arquivo está em `~/.docker/cli-plugins/docker-compose` e tem permissão de execução |
| Erro de chave GPG no `apt update` | Repita o passo 3 e confira o caminho `/usr/share/keyrings/docker-archive-keyring.gpg` |

---

## Referências

- [Documentação oficial do Docker](https://docs.docker.com/engine/install/ubuntu/)
- [Releases do Docker Compose](https://github.com/docker/compose/releases)
