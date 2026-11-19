#!/usr/bin/env bash
#
# Instalador do Docker Engine + Docker Compose (plugin v2) para Ubuntu Server
# Repositório: https://github.com/NeoDeskOfocial/docker-ubuntu-ptbr
# Licença: MIT
#
# Uso:
#   curl -fsSL https://raw.githubusercontent.com/NeoDeskOfocial/docker-ubuntu-ptbr/main/install.sh | sudo bash
#   sudo bash install.sh --ajuda

set -Eeuo pipefail

COMPOSE_VERSION="v2.27.1"
SEM_UPGRADE=0
SEM_USUARIO=0
SIM=0
REINICIAR_SESSAO=0

export DEBIAN_FRONTEND=noninteractive

# ---------------------------------------------------------------- aparência --
if [[ -t 1 ]]; then
  VERDE=$'\033[0;32m'; AMARELO=$'\033[1;33m'; VERMELHO=$'\033[0;31m'
  AZUL=$'\033[0;34m'; NC=$'\033[0m'
else
  VERDE=""; AMARELO=""; VERMELHO=""; AZUL=""; NC=""
fi

info()  { echo "${AZUL}[INFO]${NC}  $*"; }
ok()    { echo "${VERDE}[ OK ]${NC}  $*"; }
aviso() { echo "${AMARELO}[AVISO]${NC} $*"; }
erro()  { echo "${VERMELHO}[ERRO]${NC}  $*" >&2; }
etapa() { echo; echo "${AZUL}==>${NC} $*"; }
die()   { erro "$*"; exit 1; }

trap 'erro "Falha na linha ${LINENO}. Instalação interrompida."' ERR

# ------------------------------------------------------------------- ajuda --
ajuda() {
  cat <<'EOF'
Instalador do Docker Engine e Docker Compose para Ubuntu Server

Uso:
  sudo bash install.sh [opções]

Opções:
  --sem-upgrade            Não atualiza os pacotes do sistema (apenas apt update)
  --sem-usuario            Não adiciona seu usuário ao grupo docker
  --versao-compose=vX.Y.Z  Define a versão do Docker Compose (padrão: v2.27.1)
  --sim                    Responde "sim" às perguntas do script
  --ajuda                  Mostra esta ajuda
EOF
}

# ---------------------------------------------------------------- perguntas --
tem_terminal() { (: < /dev/tty) 2>/dev/null; }

confirmar() {
  local pergunta="$1" resposta=""
  if [[ "$SIM" -eq 1 ]]; then
    return 0
  fi
  if ! tem_terminal; then
    aviso "Sem terminal interativo para perguntar: \"$pergunta\" (assumindo não). Use --sim para aceitar."
    return 1
  fi
  read -r -p "$pergunta [s/N] " resposta < /dev/tty
  [[ "$resposta" =~ ^[sSyY]$ ]]
}

# ---------------------------------------------------------------- argumentos --
for arg in "$@"; do
  case "$arg" in
    --sem-upgrade)        SEM_UPGRADE=1 ;;
    --sem-usuario)        SEM_USUARIO=1 ;;
    --sim)                SIM=1 ;;
    --versao-compose=*)   COMPOSE_VERSION="${arg#*=}" ;;
    --ajuda|-h|--help)    ajuda; exit 0 ;;
    *)                    die "Opção desconhecida: $arg (use --ajuda)" ;;
  esac
done

[[ "$COMPOSE_VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] \
  || die "Versão do Compose inválida: '$COMPOSE_VERSION' (use o formato v2.27.1)."

# ------------------------------------------------------------ verificações --
etapa "Verificando o sistema"

[[ $EUID -eq 0 ]] || die "Execute como administrador: curl -fsSL <url> | sudo bash"

[[ -r /etc/os-release ]] || die "Não foi possível identificar o sistema operacional."
# shellcheck disable=SC1091
. /etc/os-release
[[ "${ID:-}" == "ubuntu" ]] \
  || die "Sistema detectado: ${PRETTY_NAME:-desconhecido}. Este instalador é exclusivo para Ubuntu."

CODENAME="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
[[ -n "$CODENAME" ]] || die "Não foi possível descobrir o codinome da versão do Ubuntu."
ok "Sistema: ${PRETTY_NAME} (${CODENAME})"

case "$(uname -m)" in
  x86_64)        ARQ_COMPOSE="x86_64" ;;
  aarch64|arm64) ARQ_COMPOSE="aarch64" ;;
  *)             die "Arquitetura não suportada por este instalador: $(uname -m)" ;;
esac
ok "Arquitetura: $(uname -m)"

USUARIO_ALVO="${SUDO_USER:-}"

if command -v docker >/dev/null 2>&1; then
  aviso "O Docker já está instalado: $(docker --version 2>/dev/null || echo 'versão desconhecida')"
  confirmar "Deseja continuar mesmo assim (atualiza/reinstala)?" || { info "Nada a fazer. Saindo."; exit 0; }
fi

# --------------------------------------------------------------- atualização --
etapa "Atualizando o servidor"
apt-get update -y
if [[ "$SEM_UPGRADE" -eq 0 ]]; then
  apt-get upgrade -y
else
  info "Pulando apt upgrade (--sem-upgrade)."
fi
ok "Sistema atualizado."

# -------------------------------------------------------------- dependências --
etapa "Instalando dependências"
apt-get install -y apt-transport-https ca-certificates curl gnupg software-properties-common lsb-release
ok "Dependências instaladas."

# ------------------------------------------------------- pacotes conflitantes --
CONFLITANTES="$(dpkg --get-selections docker.io docker-compose docker-doc podman-docker containerd runc 2>/dev/null | cut -f1 | tr '\n' ' ' || true)"
if [[ -n "${CONFLITANTES// /}" ]]; then
  aviso "Pacotes que podem conflitar com o Docker oficial: ${CONFLITANTES}"
  if confirmar "Remover esses pacotes antes de instalar?"; then
    # shellcheck disable=SC2086
    apt-get remove -y $CONFLITANTES
    ok "Pacotes removidos."
  else
    aviso "Mantendo os pacotes. A instalação pode falhar por conflito."
  fi
fi

# ---------------------------------------------------------------- repositório --
etapa "Configurando o repositório oficial do Docker"

curl -fsSL --max-time 15 -o /dev/null https://download.docker.com/linux/ubuntu/gpg \
  || die "Sem acesso a download.docker.com. Verifique sua conexão com a internet."

curl -fsI "https://download.docker.com/linux/ubuntu/dists/${CODENAME}/Release" >/dev/null 2>&1 \
  || die "O repositório da Docker ainda não oferece suporte ao Ubuntu '${CODENAME}'. Tente uma versão LTS anterior."

install -m 0755 -d /usr/share/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg
chmod a+r /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu ${CODENAME} stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update -y
ok "Repositório configurado."

# --------------------------------------------------------------------- docker --
etapa "Instalando o Docker Engine"
apt-get install -y docker-ce docker-ce-cli containerd.io
systemctl enable --now docker
ok "$(docker --version)"

# -------------------------------------------------------------------- compose --
etapa "Instalando o Docker Compose ${COMPOSE_VERSION}"
DESTINO="/usr/local/lib/docker/cli-plugins"
mkdir -p "$DESTINO"
curl -fSL --retry 3 \
  "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-${ARQ_COMPOSE}" \
  -o "${DESTINO}/docker-compose.tmp"
chmod +x "${DESTINO}/docker-compose.tmp"
mv -f "${DESTINO}/docker-compose.tmp" "${DESTINO}/docker-compose"
ok "$(docker compose version)"

# -------------------------------------------------------------------- usuário --
if [[ "$SEM_USUARIO" -eq 0 ]]; then
  etapa "Permissão para usar o Docker sem sudo"
  if [[ -z "$USUARIO_ALVO" || "$USUARIO_ALVO" == "root" ]]; then
    info "Nenhum usuário comum detectado (executado direto como root). Pulando."
  else
    aviso "Quem está no grupo 'docker' tem, na prática, acesso de administrador (root) ao servidor."
    if confirmar "Adicionar o usuário '${USUARIO_ALVO}' ao grupo docker?"; then
      usermod -aG docker "$USUARIO_ALVO"
      REINICIAR_SESSAO=1
      ok "Usuário '${USUARIO_ALVO}' adicionado ao grupo docker."
    else
      info "Ok. Você precisará usar sudo antes dos comandos docker."
    fi
  fi
fi

# ---------------------------------------------------------------------- teste --
etapa "Testando a instalação"
if docker run --rm hello-world >/dev/null 2>&1; then
  ok "Container de teste (hello-world) executado com sucesso."
else
  aviso "Não foi possível executar o hello-world agora. Rode manualmente: sudo docker run hello-world"
fi

# --------------------------------------------------------------------- resumo --
echo
echo "${VERDE}======================================================${NC}"
echo "${VERDE}  Instalação concluída!${NC}"
echo "${VERDE}======================================================${NC}"
echo "  Docker:  $(docker --version)"
echo "  Compose: $(docker compose version)"
echo
if [[ "$REINICIAR_SESSAO" -eq 1 ]]; then
  echo "  Próximo passo: aplique a permissão do grupo com uma das opções:"
  echo "    - saia e entre novamente na sessão SSH; ou"
  echo "    - rode: newgrp docker"
  echo
fi
echo "  Teste:  docker run hello-world"
echo
