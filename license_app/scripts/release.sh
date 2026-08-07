#!/bin/bash

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Verificar argumentos
if [ -z "$1" ]; then
    echo -e "${RED}❌ Erro: Digite a versão (ex: 1.0.0)${NC}"
    echo "Uso: ./scripts/release.sh <versão>"
    exit 1
fi

VERSION=$1
RELEASE_TAG="v$VERSION"

echo -e "${BLUE}🚀 Iniciando release $RELEASE_TAG...${NC}"

# Verificar se branch é main
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo -e "${YELLOW}⚠️  Aviso: Você está na branch '$CURRENT_BRANCH', não em 'main'${NC}"
    read -p "Deseja continuar? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Verificar se há mudanças não commitadas
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}❌ Erro: Há mudanças não commitadas${NC}"
    exit 1
fi

# Atualizar versão no pubspec.yaml
echo -e "${BLUE}📝 Atualizando versão no pubspec.yaml...${NC}"
sed -i "s/version: .*/version: $VERSION+1/" pubspec.yaml

# Atualizar CHANGELOG
echo -e "${BLUE}📝 Atualizando CHANGELOG...${NC}"
NOW=$(date +%Y-%m-%d)
sed -i "1s/^/## [$VERSION] - $NOW\n\n### Adicionado\n- \n\n/" CHANGELOG.md

# Adicionar e commitar
echo -e "${BLUE}📦 Fazendo commit...${NC}"
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: release $RELEASE_TAG"

# Criar tag
echo -e "${BLUE}🏷️  Criando tag $RELEASE_TAG...${NC}"
git tag -a $RELEASE_TAG -m "Release $VERSION"

# Push
echo -e "${BLUE}📤 Fazendo push...${NC}"
git push origin main
git push origin $RELEASE_TAG

echo -e "${GREEN}✅ Release $RELEASE_TAG criado com sucesso!${NC}"
echo ""
echo "Próximos passos:"
echo "  • Verificar o GitHub Actions para o build automático"
echo "  • Os artifacts estarão disponíveis em: https://github.com/seu-usuario/license_app/releases/tag/$RELEASE_TAG"
