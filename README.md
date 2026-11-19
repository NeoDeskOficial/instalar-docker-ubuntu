<div align="center">

# 🐳 Docker + Docker Compose no Ubuntu

**Guia completo de instalação, do zero ao primeiro container.**

![Docker](https://img.shields.io/badge/Docker-Engine-2496ED?logo=docker&logoColor=white)
![Compose](https://img.shields.io/badge/Docker%20Compose-v2.27.1-2496ED?logo=docker&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%20%7C%2022.04%20%7C%2024.04-E95420?logo=ubuntu&logoColor=white)
![Licença](https://img.shields.io/badge/licença-MIT-green)

📺 **Assista ao tutorial completo:** [LINK DO VÍDEO](https://youtube.com/)  
🔔 **Canal:** [NOME DO CANAL](https://youtube.com/)

</div>

---

## 📋 Sobre

Este repositório reúne o passo a passo mostrado no canal para instalar o **Docker Engine** e o **Docker Compose (plugin v2)** em servidores Ubuntu, usando o repositório oficial do Docker.

É a base para os próximos projetos do canal, como Pi-hole e outros serviços em containers.

## 📑 Índice

- [Requisitos](#-requisitos)
- [Instalação](#-instalação)
  - [1. Atualizar o sistema](#1-atualizar-o-sistema)
  - [2. Instalar dependências](#2-instalar-dependências)
  - [3. Adicionar o repositório oficial](#3-adicionar-o-repositório-oficial-do-docker)
  - [4. Instalar o Docker Engine](#4-instalar-o-docker-engine)
  - [5. Usar o Docker sem sudo](#5-usar-o-docker-sem-sudo)
  - [6. Instalar o Docker Compose](#6-instalar-o-docker-compose)
- [Verificação](#-verificação)
- [Solução de problemas](#-solução-de-problemas)
- [Referências](#-referências)
- [Contribuindo](#-contribuindo)
- [Licença](#-licença)

## ✅ Requisitos

| Item | Requisito |
|---|---|
| Sistema operacional | Ubuntu 20.04, 22.04 ou superior |
| Arquitetura | x86_64 (ARM: veja a [observação](#6-instalar-o-docker-compose)) |
| Permissões | Usuário com acesso `sudo` |
| Rede | Conexão com a internet |

## 🚀 Instalação

### 1. Atualizar o sistema

```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Instalar dependências

```bash
sudo apt install apt-transport-https ca-certificates curl software-properties-common
```

### 3. Adicionar o repositório oficial do Docker

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

### 4. Instalar o Docker Engine

```bash
sudo apt install docker-ce
```

Confirme a versão instalada:

```bash
docker --version
```

### 5. Usar o Docker sem sudo

Adicione seu usuário ao grupo `docker`:

```bash
sudo usermod -aG docker ${USER}
```

Aplique a mudança na sessão atual:

```bash
su - ${USER}
```

> 💡 Se preferir, encerre a sessão e entre novamente.

### 6. Instalar o Docker Compose

Crie a pasta de plugins:

```bash
mkdir -p ~/.docker/cli-plugins/
```

Baixe o binário (v2.27.1):

```bash
curl -SL https://github.com/docker/compose/releases/download/v2.27.1/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
```

Conceda permissão de execução:

```bash
chmod +x ~/.docker/cli-plugins/docker-compose
```

> ⚠️ **ARM / Raspberry Pi:** substitua `docker-compose-linux-x86_64` por `docker-compose-linux-aarch64` no link de download.

## 🔍 Verificação

Confira as versões:

```bash
docker --version
docker compose version
```

Teste com o container de exemplo:

```bash
docker run hello-world
```

Se aparecer a mensagem **"Hello from Docker!"**, a instalação foi concluída com sucesso. ✅

## 🛠️ Solução de problemas

| Sintoma | Causa provável | Solução |
|---|---|---|
| `permission denied` ao rodar `docker` | Usuário fora do grupo `docker` | Refaça o [passo 5](#5-usar-o-docker-sem-sudo) e reinicie a sessão |
| `docker: command not found` | Instalação não concluída | Repita o [passo 4](#4-instalar-o-docker-engine) e verifique erros |
| `docker compose` não reconhecido | Plugin ausente ou sem permissão | Confira se existe `~/.docker/cli-plugins/docker-compose` e se está executável |
| Erro de chave GPG no `apt update` | Chave não registrada | Repita o [passo 3](#3-adicionar-o-repositório-oficial-do-docker) |

## 📚 Referências

- [Instalação do Docker Engine no Ubuntu (documentação oficial)](https://docs.docker.com/engine/install/ubuntu/)
- [Releases do Docker Compose](https://github.com/docker/compose/releases)

## 🤝 Contribuindo

Encontrou um erro ou tem uma sugestão? Abra uma [issue](../../issues) ou envie um pull request.

## 📄 Licença

Distribuído sob a licença MIT.

---

<div align="center">

Gostou do conteúdo? Deixe seu 👍 no vídeo e **inscreva-se no canal**!

</div>
