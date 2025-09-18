# Marvel – Flutter App

Aplicativo mobile em Flutter que consome a API da Marvel para listar personagens e exibir detalhes, seguindo uma experiência visual minimalista e arquitetura limpa.

## 📱 Visão Geral

- **Lista paginada** de personagens com scroll infinito
- **Busca em tempo real** com debounce automático
- **Personagens em destaque** (featured characters)
- **Detalhes do personagem** com Hero animation nas imagens
- **Pull-to-refresh** para atualizar dados
- **Tratamento robusto de erros** com retry automático
- **Analytics integrado** para performance e navegação
- **Splash screen** com animação de fade

## 🏗️ Arquitetura

O projeto segue **Clean Architecture** com separação clara de responsabilidades:

```
lib/
├── core/                   # Camada de infraestrutura
│   ├── constants/          # Configurações (API, cores, estilos)
│   └── error/              # Tratamento de erros
├── features/
│   └── characters/         # Feature principal
│       ├── data/           # Fontes de dados e modelos
│       ├── domain/         # Entidades e casos de uso
│       └── presentation/   # UI (BLoC, páginas, widgets)
├── injection/              # Injeção de dependência
└── services/               # Serviços (Analytics)
```

### Camadas da Arquitetura

- **Data Layer**: Datasources, Models, Repository implementations
- **Domain Layer**: Entities, Use cases, Repository interfaces
- **Presentation Layer**: BLoC, Pages, Widgets

## 📦 Pacotes e Justificativas

### Dependências Principais

| Pacote | Versão | Justificativa |
|--------|--------|---------------|
| `dio` | ^5.4.0 | Cliente HTTP robusto com interceptors, tratamento de erros e suporte a timeout |
| `flutter_bloc` | ^8.1.3 | Gerenciamento de estado reativo, separação clara de eventos/estados, excelente testabilidade |
| `get_it` | ^7.6.7 | Injeção de dependência simples e explícita, reduz acoplamento entre camadas |
| `crypto` | ^3.0.3 | Geração de hash MD5 para autenticação na API Marvel |
| `flutter_dotenv` | ^5.1.0 | Carregamento seguro de variáveis de ambiente (.env) |
| `dartz` | ^0.10.1 | Programação funcional com Either para tratamento de erros |
| `cupertino_icons` | ^1.0.8 | Ícones iOS/Material Design para interface |
| `cached_network_image` | ^3.3.1 | Cache inteligente de imagens, otimização de performance |

### Dependências de Desenvolvimento

| Pacote | Versão | Justificativa |
|--------|--------|---------------|
| `mocktail` | ^1.0.3 | Mocking ergonômico e seguro com null-safety para testes |
| `bloc_test` | ^9.1.5 | Testes específicos para BLoC com verificações de estados |
| `flutter_lints` | ^5.0.0 | Linting padrão do Flutter para qualidade de código |

### Escolha do BLoC

**Por que BLoC ao invés de Cubit/MobX/Riverpod?**

- **Cubit**: BLoC oferece separação explícita entre eventos e estados, melhor para fluxos complexos
- **MobX**: BLoC é mais testável e previsível, sem "magia" de reatividade
- **Riverpod**: BLoC tem melhor integração com Flutter e ecossistema mais maduro
- **Vantagens**: Imutabilidade, testabilidade, debugging, time-travel debugging

## 🚀 Como Instalar e Configurar

### Pré-requisitos

- Flutter SDK 3.9.0 ou superior
- Dart 3.0 ou superior
- Android Studio / VS Code
- Conta na [Marvel Developer Portal](https://developer.marvel.com/)

### 1. Clone o Repositório

```bash
git clone https://github.com/levivcruz/marvel.git
cd marvel
```

### 2. Obtenha suas Chaves da API Marvel

1. Acesse [Marvel Developer Portal](https://developer.marvel.com/)
2. Crie uma conta e obtenha suas chaves:
   - **Public Key** (pode ser exposta)
   - **Private Key** (deve ser mantida em segredo)

### 3. Configure as Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto:

```env
MARVEL_PUBLIC_KEY=sua_chave_publica_aqui
MARVEL_PRIVATE_KEY=sua_chave_privada_aqui
```

### 4. Entenda a API Marvel

A API Marvel retorna dados no seguinte formato:

#### Estrutura da Resposta

```json
{
  "code": 200,
  "status": "Ok",
  "data": {
    "results": [
      {
        "id": 1011334,
        "name": "3-D Man",
        "description": "Descrição do personagem...",
        "thumbnail": {
          "path": "http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784",
          "extension": "jpg"
        },
        "comics": {
          "items": [
            {"name": "Avengers: The Initiative (2007) #19"},
            {"name": "Avengers: The Initiative (2007) #18"}
          ]
        },
        "series": {
          "items": [
            {"name": "Avengers: The Initiative (2007 - 2010)"},
            {"name": "Deadpool (1997 - 2002)"}
          ]
        },
        "stories": {
          "items": [
            {"name": "Cover #19947"},
            {"name": "The 3-D Man!"}
          ]
        }
      }
    ],
    "total": 1562,
    "count": 20,
    "offset": 0,
    "limit": 20
  }
}
```

#### Parâmetros de Autenticação

- **ts**: Timestamp atual (milliseconds)
- **apikey**: Chave pública da Marvel
- **hash**: MD5(timestamp + privateKey + publicKey)

#### Endpoints Utilizados

- **Lista**: `/characters?orderBy=name&offset=0&limit=20`
- **Busca**: `/characters?nameStartsWith=spider&limit=5`
- **Destaques**: `/characters?orderBy=-modified&limit=6`

### 5. Instale as Dependências

```bash
flutter pub get
```

### 6. Execute o Aplicativo

```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

## 📱 Plataformas Suportadas

- ✅ **Android** (minSdk: flutter.minSdkVersion - padrão Flutter)
- ✅ **iOS** (iOS 13.0+)

## 🧪 Testes

O projeto inclui testes abrangentes para as camadas de data e presentation:

### Executar Testes

```bash
# Todos os testes
flutter test

# Testes com coverage
flutter test --coverage

# Testes específicos
flutter test test/features/characters/
```

### Tipos de Testes

- **Unit Tests**: Datasources
- **BLoC Tests**: Estados e eventos com `bloc_test`
- **Widget Tests**: Componentes de UI

## 📊 Analytics

O projeto inclui sistema de analytics **implementado** com MethodChannel nativo:

- **Screen tracking**: Navegação entre páginas (`trackScreen`)
- **Performance metrics**: Tempo de carregamento (`trackEvent`)
- **Error tracking**: Falhas de API e rede (`trackApiError`)
- **User interactions**: Busca (`trackCharacterSearch`) e visualização (`trackCharacterView`)

### Implementação Completa

✅ **Flutter (AnalyticsServiceImpl)**:

- MethodChannel: `com.marvel.analytics`
- Métodos: `initialize`, `trackEvent`, `trackScreen`
- Tratamento de erros com PlatformException

✅ **Android (MainActivity.kt)**:

- Firebase Analytics integrado
- MethodChannel handler completo
- Métodos: `initialize`, `trackEvent`, `trackScreen`, `setUserProperty`, `trackError`
- Logs detalhados para debugging

✅ **iOS (AppDelegate.swift)**:

- Firebase Analytics integrado
- MethodChannel handler completo
- Métodos: `initialize`, `trackEvent`, `trackScreen`, `setUserProperty`, `trackError`
- Conversão automática de parâmetros

⚠️ **Firebase Mock Configurado**:

- google-services.json (MOCK - valores fake para desenvolvimento)
- GoogleService-Info.plist (MOCK - valores fake para desenvolvimento)
- Firebase Analytics **NÃO ativo** (implementação preparada)

## 🎨 Design System

### Cores

- **Primary**: `#E62429` (Vermelho Marvel)
- **Background Dark**: `#202020` (Fundo escuro)
- **Background Light**: `#F5F5F5` (Fundo claro)
- **Text Primary Dark**: `Colors.white` (Texto em modo escuro)
- **Text Primary Light**: `Colors.black` (Texto em modo claro)
- **Text Secondary Light**: `#757575` (Texto secundário)

### Tipografia

- **Header**: 28px, bold, texto escuro
- **Section Title**: 15px, w700, texto escuro
- **Body**: 14px, w400, altura 1.4, texto escuro
- **Hint**: 14px, texto secundário claro
- **Label**: 15px, bold, texto claro

## 🔧 Lint e Qualidade

O projeto utiliza `flutter_lints` com configuração padrão:

```bash
# Verificar linting
flutter analyze

# Corrigir automaticamente
dart fix --apply
```

**Configuração atual:**

- Usa `package:flutter_lints/flutter.yaml` (configuração padrão)
- Sem regras personalizadas adicionais
- Regras comentadas disponíveis para customização

## 📋 Estrutura de Pastas Detalhada

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart      # URLs e chaves da API
│   │   ├── app_colors.dart         # Paleta de cores
│   │   ├── app_text_styles.dart    # Estilos de texto
│   │   └── app_dimensions.dart     # Dimensões padrão
│   ├── error/
│   │   ├── exceptions.dart         # Exceptions customizadas
│   │   ├── failures.dart           # Failures do domain
│   │   └── error_types.dart        # Tipos de erro
│   └── core.dart                   # Exports principais
├── features/
│   └── characters/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── character_remote_datasource.dart
│       │   │   └── character_remote_datasource_impl.dart
│       │   ├── models/
│       │   │   ├── character_model.dart
│       │   │   └── models.dart
│       │   └── repositories/
│       │       └── character_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── character.dart
│       │   ├── repositories/
│       │   │   └── character_repository.dart
│       │   └── usecases/
│       │       ├── get_characters.dart
│       │       ├── get_featured_characters.dart
│       │       └── search_characters.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── character_bloc.dart
│           │   ├── character_event.dart
│           │   └── character_state.dart
│           ├── pages/
│           │   ├── characters_page.dart
│           │   └── character_detail_page.dart
│           └── widgets/
│               ├── search_widget.dart
│               ├── featured_characters_section.dart
│               ├── characters_grid_section.dart
│               └── others...
├── injection/
│   ├── injection_container.dart    # Configuração do GetIt
│   └── injection.dart              # Exports
├── services/
│   ├── analytics_service_interface.dart
│   ├── analytics_service.dart
│   └── services.dart
└── main.dart
```

## 🚀 Funcionalidades Técnicas

### Scroll Infinito

- Detecção automática em 80% do scroll
- Prevenção de requisições múltiplas
- Tratamento de fim da lista

### Busca Inteligente

- Debounce de 300ms
- Scroll automático para visibilidade
- Restauração de posição ao fechar teclado

### Cache de Imagens

- Cache automático via `cached_network_image`
- Placeholders durante carregamento
- Otimização de memória

### Tratamento de Erros

- Diferenciação entre erros de rede e servidor
- Retry automático disponível
- Mensagens user-friendly

## 📱 Screenshots

<img src="assets/demo.gif" width="300" alt="App Demo" />
