# Guia de Contribuição

Obrigado por seu interesse em contribuir para o License Manager! Este documento fornece orientações e instruções para ajudar a tornar o processo de contribuição o mais suave possível.

## Código de Conduta

Este projeto adota um Código de Conduta que esperamos que todos os contribuidores respeitem. Por favor, leia-o.

## Como Posso Contribuir?

### Reportando Bugs

Antes de criar um relatório de bug, verifique a lista de issues, pois você pode descobrir que o erro já foi reportado. Ao criar um relatório de bug, inclua o máximo de detalhes possível:

- **Use um título claro e descritivo** para o issue
- **Descreva os passos exatos** para reproduzir o problema
- **Forneça exemplos específicos** para demonstrar os passos
- **Descreva o comportamento que você observou** e apontar exatamente qual é o problema
- **Explique qual comportamento você esperava** ver em vez disso

### Sugerindo Enhancements

Sugestões de melhorias geralmente incluem ideias completamente novas e melhorias de funcionalidades ou recursos existentes.

Ao criar uma sugestão de enhancement, inclua:

- **Use um título claro e descritivo** para o issue
- **Forneça uma descrição passo-a-passo** da melhoria sugerida
- **Forneça exemplos específicos** para demonstrar os passos
- **Descreva o comportamento atual** e mencione o comportamento esperado

### Pull Requests

- Siga o guia de estilo Dart
- Inclua comentários apropriados, especialmente para lógica não óbvia
- Inclua testes para novas funcionalidades
- Termine todos os arquivos com uma nova linha
- Evite código dependente da plataforma

## Guia de Estilo

### Dart/Flutter Code Style

```dart
// Use nomes descritivos
const String apiEndpoint = 'https://fluffernutter-joy-factory.lovable.app/endpoint';

// Use final para variáveis que não são reatribuídas
final licenseFile = File('${configDir.path}/license.json');

// Use arrow functions quando apropriado
final numbers = [1, 2, 3].map((n) => n * 2).toList();

// Use String interpolation
print('License key: $licenseKey');
```

### Commit Messages

- Use o imperativo ("move cursor to..." não "moved cursor to...")
- Limite a primeira linha a 72 caracteres ou menos
- Referencie issues relevantes no corpo da mensagem

Exemplo:
```
Add D-Pad navigation support

Implement full D-Pad navigation for Android TV devices
Fixes #123
```

### Branch Naming

- `feature/description` - para novas funcionalidades
- `fix/description` - para correções de bugs
- `docs/description` - para documentação
- `refactor/description` - para refatorações

## Processo de Desenvolvimento

1. Fork o repositório
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## Setup do Ambiente

### Requisitos
- Flutter 3.16.0 ou superior
- Java 17 ou superior
- Android SDK 21+

### Instalação

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/license_app.git
cd license_app

# Instale as dependências
flutter pub get

# Execute a análise de código
flutter analyze

# Execute os testes
flutter test

# Build para teste
flutter build apk --debug
```

## Teste

Antes de submeter um Pull Request, certifique-se de que:

1. Todos os testes passam: `flutter test`
2. O código está formatado: `dart format lib/`
3. Sem warnings de análise: `flutter analyze`
4. A aplicação compila sem erros: `flutter build apk --release`

## Documentação

- Use comentários para explicar o "porquê", não o "o quê"
- Mantenha o README.md atualizado
- Documentes mudanças significativas em CHANGELOG.md

## Repositório

- **Problemas**: https://github.com/seu-usuario/license_app/issues
- **Discussões**: https://github.com/seu-usuario/license_app/discussions
- **Wiki**: https://github.com/seu-usuario/license_app/wiki

## Licença

Ao contribuir para este projeto, você concorda que suas contribuições serão licenciadas sob sua Licença MIT.
