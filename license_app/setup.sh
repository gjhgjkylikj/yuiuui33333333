#!/bin/bash

set -e

echo "🚀 Iniciando setup do projeto License Manager..."

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar Flutter
echo -e "${BLUE}📱 Verificando Flutter...${NC}"
if ! command -v flutter &> /dev/null; then
    echo -e "${YELLOW}⚠️  Flutter não encontrado. Por favor, instale o Flutter.${NC}"
    exit 1
fi
FLUTTER_VERSION=$(flutter --version | grep Flutter | awk '{print $2}')
echo -e "${GREEN}✓ Flutter $FLUTTER_VERSION instalado${NC}"

# Verificar Java
echo -e "${BLUE}☕ Verificando Java...${NC}"
if ! command -v java &> /dev/null; then
    echo -e "${YELLOW}⚠️  Java não encontrado. Por favor, instale Java 17+.${NC}"
    exit 1
fi
JAVA_VERSION=$(java -version 2>&1 | grep version | awk '{print $3}' | tr -d '"')
echo -e "${GREEN}✓ Java $JAVA_VERSION instalado${NC}"

# Obter dependências
echo -e "${BLUE}📦 Obtendo dependências do Flutter...${NC}"
flutter pub get
echo -e "${GREEN}✓ Dependências obtidas${NC}"

# Executar análise
echo -e "${BLUE}🔍 Executando análise de código...${NC}"
flutter analyze
echo -e "${GREEN}✓ Análise completa${NC}"

# Criar arquivo de configuração
echo -e "${BLUE}⚙️  Criando arquivo de configuração...${NC}"
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo -e "${GREEN}✓ Arquivo .env criado${NC}"
else
    echo -e "${YELLOW}ℹ️  Arquivo .env já existe${NC}"
fi

echo ""
echo -e "${GREEN}✅ Setup concluído com sucesso!${NC}"
echo ""
echo "Próximos passos:"
echo "  • Configurar o arquivo .env se necessário"
echo "  • Executar: flutter run"
echo "  • Para build de release: make build"
echo ""
