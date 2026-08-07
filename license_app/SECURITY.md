# Política de Segurança

## Vulnerabilidades

Se você descobrir uma vulnerabilidade de segurança, por favor, **não** crie um issue público. Em vez disso, envie um email para `security@example.com` com os detalhes.

Por favor, inclua:
- Descrição da vulnerabilidade
- Passos para reproduzir
- Possível impacto
- Sugestão de correção (se houver)

## Práticas de Segurança

Este projeto implementa as seguintes práticas de segurança:

### 1. Autenticação e Autorização
- Validação de chaves de licença no backend
- Verificação de device ID
- Timestamps para prevenção de replay attacks

### 2. Armazenamento de Dados
- Arquivo de configuração em diretório protegido
- Arquivo JSON simples sem encriptação (adicione se necessário)
- Sem armazenamento de senhas ou credenciais

### 3. Comunicação
- Apenas HTTPS permitido
- Timeout de 30 segundos para requisições
- Validação de resposta do servidor

### 4. Permissões
- Permissões específicas solicitadas
- Verificação de runtime permissions (Android 6+)
- Sem permissões desnecessárias

### 5. Análise de Código
- Flutter analyze em todos os PRs
- Linter ativado
- Code review obrigatório

## Dependências

Mantenha as dependências atualizadas:

```bash
flutter pub upgrade
flutter pub outdated
```

## Segurança da Compilação

- Chaves de assinatura não são commited
- Gradle wrapper verificado
- GitHub Actions usa credenciais seguras

## Reporte de Vulnerabilidades Descobertas

Se você descobrir uma vulnerabilidade:
1. Não publique detalhes públicos
2. Envie um email com as informações
3. Aguarde uma resposta dentro de 48 horas
4. Permita tempo para a correção antes da divulgação

## Aviso de Segurança

Este é um aplicativo de demonstração. Para uso em produção:
- Implemente encriptação de dados sensíveis
- Use OAuth/autenticação segura
- Implemente rate limiting
- Use certificado SSL/TLS válido
- Implemente logging e monitoramento
- Realize testes de segurança
