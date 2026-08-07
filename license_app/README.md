# License Manager - Android TV

Aplicação Flutter nativa para Android TV com suporte a controle remoto D-Pad, ativação de licença e armazenamento persistente.

## Requisitos do Sistema

- Flutter 3.16.0 ou superior
- Java 17 ou superior
- Android SDK 21+
- Gradle 8.1+

## Características

✅ Suporte completo a D-Pad (controle remoto de TV Box)
✅ Interface otimizada para Android TV
✅ Campo de entrada de texto para chave de licença
✅ Requisição POST para validação de licença
✅ Armazenamento local persistente em `/storage/emulated/0/Android/.config`
✅ Verificação automática de licença ao iniciar
✅ Botão para remover licença e voltar à tela de ativação
✅ Compilação automatizada via GitHub Actions

## Estrutura do Projeto

```
license_app/
├── lib/
│   └── main.dart                 # Código principal da aplicação
├── android/
│   ├── app/
│   │   ├── build.gradle          # Build configuration do app
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       ├── kotlin/
│   │       │   └── MainActivity.kt
│   │       └── res/values/
│   │           └── strings.xml
│   ├── build.gradle              # Build configuration do projeto
│   ├── settings.gradle           # Configuração de plugins
│   └── gradle/wrapper/           # Gradle wrapper
├── .github/
│   └── workflows/
│       └── build.yml             # CI/CD do GitHub Actions
├── pubspec.yaml                  # Dependências do Flutter
└── README.md                     # Este arquivo
```

## Instalação Local

### 1. Clone o repositório
```bash
git clone <seu-repo>
cd license_app
```

### 2. Instale as dependências do Flutter
```bash
flutter pub get
```

### 3. Configure o Android SDK
```bash
flutter config --android-sdk <caminho-para-android-sdk>
```

### 4. Execute a aplicação (dispositivo/emulador Android TV)
```bash
flutter run -d <device-id> --release
```

## Build da APK

### Build local
```bash
flutter build apk --release
```

A APK será gerada em: `build/app/outputs/flutter-apk/app-release.apk`

### Build via GitHub Actions

1. Faça push para a branch `main` ou `develop`
2. O workflow será executado automaticamente
3. Baixe o APK nos artifacts da ação

## Permissões Necessárias

A aplicação requer as seguintes permissões:
- `INTERNET` - Para realizar requisições POST
- `READ_EXTERNAL_STORAGE` - Para leitura do arquivo de licença
- `WRITE_EXTERNAL_STORAGE` - Para escrita do arquivo de licença
- `MANAGE_EXTERNAL_STORAGE` - Para acesso ao diretório `.config`

## Uso da Aplicação

### Tela de Ativação
1. Digite sua chave de licença no campo de texto
2. Use D-Pad para navegar entre os campos
3. Pressione Enter para ativar a licença
4. A chave será enviada para: `https://fluffernutter-joy-factory.lovable.app/endpoint`

### Armazenamento de Licença
- Arquivo: `/storage/emulated/0/Android/.config/license.json`
- Formato: JSON com chave de licença e timestamp

### Painel de Controle
- Exibido quando uma licença válida é detectada ao iniciar
- Botão "Remover Licença" para resetar e voltar à tela de ativação

## Requisição HTTP

A aplicação envia uma requisição POST no seguinte formato:

```json
{
  "license_key": "sua-chave-aqui",
  "device_id": "android_tv_device",
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

## Navegação via D-Pad

- **Seta para Cima/Esquerda**: Navega para o elemento anterior
- **Seta para Baixo/Direita**: Navega para o elemento seguinte
- **Enter/OK**: Ativa a ação do elemento focado

## Troubleshooting

### APK não compila
```bash
flutter clean
flutter pub get
flutter build apk --release -v
```

### Erro de permissões
- Certifique-se de que as permissões do arquivo foram solicitadas
- Verifique as configurações de permissões do dispositivo

### Licença não é salva
- Verifique se o dispositivo tem espaço disponível
- Confirme que a aplicação tem permissão de escrita

## Contribuindo

1. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
2. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
3. Push para a branch (`git push origin feature/AmazingFeature`)
4. Abra um Pull Request

## Licença

Este projeto está sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.

## Suporte

Para suporte, abra uma issue no repositório do GitHub.
