<div align="center">

# Docker + Docker Compose no Ubuntu Server

**Instale o Docker e o Docker Compose em servidor Ubuntu com um único comando, ou siga o passo a passo manual completo em português.**

![Licença MIT](https://img.shields.io/badge/licença-MIT-green)
![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%20|%2022.04%20|%2024.04-E95420?logo=ubuntu&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Engine-2496ED?logo=docker&logoColor=white)
![Compose](https://img.shields.io/badge/Docker%20Compose-v2.27.1-2496ED?logo=docker&logoColor=white)
![Idioma](https://img.shields.io/badge/idioma-PT--BR-blue)

📺 **Assista ao tutorial completo:** [LINK DO VÍDEO](https://youtube.com/)  
🔔 **Canal:** [NOME DO CANAL](https://youtube.com/)

</div>

---

## Sumário

- [Sobre o projeto](#sobre-o-projeto)
- [Método 1: Instalação rápida (uma linha)](#método-1-instalação-rápida-uma-linha)
- [O que o instalador faz](#o-que-o-instalador-faz)
- [Opções do instalador](#opções-do-instalador)
- [Requisitos](#requisitos)
- [Método 2: Instalação manual passo a passo](#método-2-instalação-manual-passo-a-passo)
- [Verificação](#verificação)
- [Comandos úteis](#comandos-úteis)
- [Atualização](#atualização)
- [Solução de problemas](#solução-de-problemas)
- [Desinstalação](#desinstalação)
- [Perguntas frequentes](#perguntas-frequentes)
- [Referências](#referências)
- [Contribuindo](#contribuindo)
- [Licença](#licença)

---

## Sobre o projeto

O [Docker](https://www.docker.com/) permite executar aplicações em **containers**: ambientes isolados, leves e fáceis de reproduzir. O **Docker Compose** complementa o Docker, permitindo subir vários containers de uma vez a partir de um único arquivo `compose.yaml`.

**Principais benefícios**

- Instala serviços (Pi-hole, Nextcloud, Home Assistant, etc.) sem sujar o sistema.
- Atualizações e remoções simples e previsíveis.
- Ambiente igual em qualquer servidor, físico ou virtual.
- Base para os demais projetos do canal.

Este repositório reúne:

| Arquivo | Descrição |
|---------|-----------|
| [`install.sh`](install.sh) | Instalador automatizado: atualiza o servidor, instala o Docker e o Docker Compose e libera o uso sem `sudo` |
| `README.md` | Esta documentação, com instalação rápida e manual |
| [`LICENSE`](LICENSE) | Licença MIT |

---

## Método 1: Instalação rápida (uma linha)

Basta colar o comando abaixo, que já atualiza o servidor e instala tudo. Em um servidor Ubuntu, execute:

```bash
curl -fsSL https://raw.githubusercontent.com/NeoDeskOficial/instalar-docker-ubuntu/main/install.sh | sudo bash
```

O script faz algumas perguntas durante a instalação (por exemplo, se deve adicionar seu usuário ao grupo `docker`). Por isso, execute o comando em um terminal interativo, como uma sessão SSH.

### Prefere revisar o script antes de executar?

Executar scripts baixados da internet exige confiança na origem. Se quiser ler o código antes:

```bash
curl -fsSL https://raw.githubusercontent.com/NeoDeskOficial/instalar-docker-ubuntu/main/install.sh -o install.sh
less install.sh
sudo bash install.sh
```

---

## O que o instalador faz

1. **Verifica o sistema:** confirma que é Ubuntu, identifica a versão e a arquitetura (x86_64 ou ARM64).
2. **Detecta instalação anterior:** se o Docker já existir, pergunta antes de continuar.
3. **Atualiza o servidor:** `apt update` e `apt upgrade` sem perguntas.
4. **Instala as dependências:** `ca-certificates`, `curl`, `gnupg`, `lsb-release` e demais pacotes necessários.
5. **Remove pacotes conflitantes** (`docker.io`, `podman-docker`, etc.), com confirmação.
6. **Configura o repositório oficial do Docker**, validando antes se ele já oferece suporte à sua versão do Ubuntu.
7. **Instala o Docker Engine** e ativa o serviço na inicialização.
8. **Instala o Docker Compose v2.27.1** como plugin, para todos os usuários, em `/usr/local/lib/docker/cli-plugins`.
9. **Adiciona seu usuário ao grupo `docker`** (opcional, com confirmação), para usar o Docker sem `sudo`.
10. **Testa a instalação** com o container `hello-world` e mostra um resumo final.

O script encerra com mensagem clara se algo estiver errado.

---

## Opções do instalador

Passe opções com `bash -s --`:

```bash
curl -fsSL https://raw.githubusercontent.com/NeoDeskOficial/instalar-docker-ubuntu/main/install.sh | sudo bash -s -- --sem-upgrade
```

| Opção | Efeito |
|-------|--------|
| `--sem-upgrade` | Não atualiza os pacotes do sistema (apenas `apt update`) |
| `--sem-usuario` | Não adiciona seu usuário ao grupo `docker` |
| `--versao-compose=vX.Y.Z` | Instala outra versão do Compose (padrão: `v2.27.1`) |
| `--sim` | Responde "sim" a todas as perguntas do script |
| `--ajuda` | Mostra a ajuda (ao executar o arquivo baixado) |

> **Atenção ao grupo `docker`:** quem faz parte desse grupo tem, na prática, acesso de administrador ao servidor. Em servidores compartilhados, use `--sem-usuario` e rode os comandos com `sudo`.

---

## Requisitos

| Item | Requisito |
|------|-----------|
| Sistema operacional | Ubuntu Server 20.04, 22.04, 24.04 ou superior |
| Arquitetura | x86_64 ou ARM64 (Raspberry Pi 4/5 com sistema 64 bits) |
| CPU | 1 núcleo |
| Memória RAM | 1 GB (2 GB recomendado) |
| Disco | 10 GB livres (as imagens dos containers ocupam espaço) |
| Rede | Conexão com a internet |
| Acesso | Usuário com permissão `sudo` |

---

## Método 2: Instalação manual passo a passo

Prefere fazer cada etapa por conta própria? Siga abaixo. Aqui o Compose é instalado apenas para o seu usuário (em `~/.docker/cli-plugins`).

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

> Se preferir, encerre a sessão e entre novamente.

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

> **ARM / Raspberry Pi:** substitua `docker-compose-linux-x86_64` por `docker-compose-linux-aarch64` no link de download.

---

## Verificação

Confira as versões:

```bash
docker --version
docker compose version
```

Teste com o container de exemplo:

```bash
docker run hello-world
```

Se aparecer a mensagem **"Hello from Docker!"**, a instalação foi concluída com sucesso.

---

## Comandos úteis

| Comando | Descrição |
|---------|-----------|
| `docker ps` | Lista os containers em execução |
| `docker ps -a` | Lista todos os containers, inclusive parados |
| `docker images` | Lista as imagens baixadas |
| `docker logs -f nome` | Acompanha os logs de um container |
| `docker exec -it nome bash` | Abre um terminal dentro do container |
| `docker stop nome` | Para um container |
| `docker system prune` | Remove containers parados, redes e imagens sem uso |
| `docker compose up -d` | Sobe os serviços do `compose.yaml` em segundo plano |
| `docker compose down` | Para e remove os serviços do `compose.yaml` |
| `docker compose pull` | Baixa as imagens mais recentes dos serviços |

Gerenciamento do serviço:

```bash
sudo systemctl status docker
sudo systemctl restart docker
```

---

## Atualização

**Docker Engine:**

```bash
sudo apt update && sudo apt upgrade -y
```

**Docker Compose:** rode o instalador novamente informando a versão desejada, ou, no método manual, repita o [passo 6](#6-instalar-o-docker-compose) trocando o número da versão. As versões estão em [github.com/docker/compose/releases](https://github.com/docker/compose/releases).

```bash
curl -fsSL https://raw.githubusercontent.com/NeoDeskOficial/instalar-docker-ubuntu/main/install.sh | sudo bash -s -- --versao-compose=v2.27.1 --sem-upgrade --sim
```

---

## Solução de problemas

<details>
<summary><strong><code>permission denied</code> ao rodar <code>docker</code></strong></summary>

Seu usuário não está no grupo `docker` ou a sessão ainda não foi atualizada.

```bash
groups
sudo usermod -aG docker ${USER}
newgrp docker
```

Se o problema continuar, saia e entre novamente na sessão SSH.
</details>

<details>
<summary><strong><code>docker: command not found</code></strong></summary>

A instalação não foi concluída. Repita o [passo 4](#4-instalar-o-docker-engine) e verifique se houve erros. Para conferir se o repositório está configurado:

```bash
cat /etc/apt/sources.list.d/docker.list
apt-cache policy docker-ce
```
</details>

<details>
<summary><strong><code>docker compose</code> não é reconhecido</strong></summary>

Confira se o plugin existe e está executável:

```bash
ls -l ~/.docker/cli-plugins/docker-compose
ls -l /usr/local/lib/docker/cli-plugins/docker-compose
```

No método manual, o plugin vale só para o seu usuário. Se rodar com `sudo`, ele não será encontrado. Use o instalador rápido, que instala para todos os usuários.
</details>

<details>
<summary><strong>Erro de chave GPG no <code>apt update</code></strong></summary>

Refaça o [passo 3](#3-adicionar-o-repositório-oficial-do-docker) e confirme que o arquivo da chave existe:

```bash
ls -l /usr/share/keyrings/docker-archive-keyring.gpg
```
</details>

<details>
<summary><strong>O repositório não oferece suporte à minha versão do Ubuntu</strong></summary>

Versões muito novas do Ubuntu às vezes demoram a receber pacotes oficiais. Use uma versão LTS (22.04 ou 24.04) ou consulte a [documentação oficial](https://docs.docker.com/engine/install/ubuntu/).
</details>

<details>
<summary><strong>O serviço <code>docker</code> não inicia</strong></summary>

```bash
sudo systemctl status docker
sudo journalctl -u docker -n 50 --no-pager
```
</details>

Para qualquer outro problema, abra uma *issue* neste repositório com a saída dos comandos acima.

---

## Desinstalação

Remover o Docker (mantém imagens e containers em `/var/lib/docker`):

```bash
sudo apt purge -y docker-ce docker-ce-cli containerd.io
sudo apt autoremove -y
```

Para apagar também **todas as imagens, containers e volumes** (não tem volta):

```bash
sudo rm -rf /var/lib/docker /var/lib/containerd
```

Remover o repositório e o Compose:

```bash
sudo rm -f /etc/apt/sources.list.d/docker.list /usr/share/keyrings/docker-archive-keyring.gpg
sudo rm -f /usr/local/lib/docker/cli-plugins/docker-compose ~/.docker/cli-plugins/docker-compose
```

---

## Perguntas frequentes

**Qual a diferença entre `docker-compose` e `docker compose`?**
`docker-compose` (com hífen) é a versão antiga, em Python. `docker compose` (com espaço) é a versão atual, instalada como plugin do Docker, que este guia utiliza.

**Preciso de um arquivo `version:` no `compose.yaml`?**
Não. Nas versões atuais do Compose o campo `version` é opcional e apenas ignorado.

**Posso instalar em Raspberry Pi?**
Sim, em sistema de 64 bits. O instalador detecta a arquitetura ARM64 automaticamente. No método manual, troque o link do Compose conforme a observação do [passo 6](#6-instalar-o-docker-compose).

**Dá para usar em Debian?**
O Docker oferece suporte oficial ao Debian, mas este guia e o instalador foram feitos e testados para Ubuntu.

**Rodar `docker` sem `sudo` é seguro?**
Quem está no grupo `docker` pode, na prática, obter acesso de administrador no servidor. Em um servidor pessoal ou de laboratório isso costuma ser aceitável; em ambientes compartilhados, prefira usar `sudo`.

---

## Referências

- Docker Engine no Ubuntu (documentação oficial): <https://docs.docker.com/engine/install/ubuntu/>
- Documentação do Docker Compose: <https://docs.docker.com/compose/>
- Releases do Docker Compose: <https://github.com/docker/compose/releases>
- Docker Hub: <https://hub.docker.com/>

---

## Contribuindo

Encontrou um erro ou quer melhorar o guia ou o instalador? Abra uma *issue* ou envie um *pull request*. Ao testar o instalador em outra versão do Ubuntu, conte nos comentários o resultado.

## Licença

Distribuído sob a licença [MIT](LICENSE).

> Este projeto não é afiliado à Docker, Inc. Docker é marca de seus respectivos titulares.

---

<div align="center">

Gostou do conteúdo? Deixe seu 👍 no vídeo e **inscreva-se no canal**!

</div>
