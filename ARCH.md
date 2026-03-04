# ARCH — Arquitetura do projeto

## Estrutura final de pastas

```
lib/
├── main.dart                          # Entry point — injeção de dependências
├── core/
│   ├── errors/
│   │   └── app_errors.dart            # AppError: exceção tipada da aplicação
│   └── ui/
│       └── app_root.dart              # MaterialApp raiz
└── features/
    └── todos/
        ├── data/                      # Camada de dados (implementações concretas)
        │   ├── datasources/
        │   │   ├── todo_local_datasource.dart   # SharedPreferences
        │   │   └── todo_remote_datasource.dart  # HTTP / JSONPlaceholder
        │   ├── models/
        │   │   └── todo_model.dart    # DTO com fromJson / toJson
        │   └── repositories/
        │       └── todo_repository_impl.dart    # Orquestra remote + local
        ├── domain/                    # Camada de domínio (puras, sem framework)
        │   ├── entities/
        │   │   └── todo.dart          # Entidade de negócio
        │   └── repositories/
        │       └── todo_repository.dart  # Contrato (interface abstrata)
        └── presentation/              # Camada de apresentação (Flutter/UI)
            ├── screens/
            │   └── todos_page.dart    # Tela principal
            ├── viewmodels/
            │   └── todo_viewmodel.dart  # Estado e lógica de apresentação
            └── widgets/
                └── add_todo_dialog.dart # Diálogo de criação de todo
```

---

## Fluxo de dependências

```
main.dart
  └── cria TodoRepositoryImpl (data)
  └── injeta em TodoViewModel (presentation)
  └── monta AppRoot (core/ui)

Fluxo de uma ação do usuário:

  TodosPage (UI)
      │  observa / chama métodos do VM
      ▼
  TodoViewModel (ChangeNotifier)
      │  chama métodos da interface TodoRepository
      ▼
  TodoRepositoryImpl
      ├── TodoRemoteDataSource  →  GET/POST/PATCH https://jsonplaceholder.typicode.com
      └── TodoLocalDataSource   →  SharedPreferences (persistência de lastSync)
```

Diagrama resumido:

```
UI  ──►  ViewModel  ──►  Repository (interface)
                              │
                    ┌─────────┴──────────┐
                    ▼                    ▼
             RemoteDataSource     LocalDataSource
             (HTTP / http pkg)    (SharedPreferences)
```

---

## Justificativa da estrutura

**Feature-first** foi escolhido porque agrupa por contexto de negócio (`todos/`)
em vez de por tipo técnico (`screens/`, `models/`…). Isso torna cada feature
auto-contida: para adicionar uma nova feature basta criar uma nova pasta em
`features/` sem tocar no restante do projeto.

Dentro de cada feature, as três camadas clássicas são respeitadas:

| Camada | Pasta | Regra |
|--------|-------|-------|
| **domain** | `domain/` | Zero dependências de Flutter ou bibliotecas externas. Apenas Dart puro. Define o contrato (`TodoRepository`) e a entidade (`Todo`). |
| **data** | `data/` | Implementa o contrato do domínio. Conhece HTTP, SharedPreferences e DTOs. Nunca importado pela UI diretamente. |
| **presentation** | `presentation/` | Conhece Flutter (widgets, ChangeNotifier). Depende apenas da interface `TodoRepository`, nunca de implementações concretas. |

O `core/` abriga código genuinamente compartilhado entre features:
`AppError` (classe de erro tipada) e `AppRoot` (raiz Material da aplicação).

---

## Decisões de responsabilidade

### Onde ficou a validação?
No `TodoViewModel`. A validação de entrada (título vazio) é lógica de
**apresentação**, não de negócio nem de acesso a dados. O VM centraliza isso
antes de delegar ao repositório.

### Onde ficou o parsing JSON?
No `TodoModel` (`data/models/`), via `fromJson` / `toJson`.
O DTO pertence à camada de dados porque o formato JSON é um detalhe de
implementação da API remota. A entidade `Todo` (domínio) nunca conhece JSON.

### Como foram tratados os erros?
- `RemoteDataSource` lança `Exception` se o status HTTP for fora de 2xx.
- `RepositoryImpl` propaga a exceção sem engoli-la.
- `TodoViewModel` captura em blocos `try/catch`, converte para `String`
  armazenada em `errorMessage`, e expõe ao widget via `ChangeNotifier`.
  Não há `BuildContext` nem Widgets dentro do VM.
- `AppError` está disponível em `core/errors/` para evoluções futuras que
  precisem de erros tipados e tratamento diferenciado por tipo.

### Por que o ViewModel recebe a interface e não a implementação?
O `TodoRepository` (interface abstrata) é declarado na camada **domain**, que
não depende de nada externo. O `TodoViewModel` importa apenas essa interface,
ficando desacoplado da fonte real dos dados (HTTP? mock? cache?). A escolha
concreta acontece em `main.dart` (raiz de composição), tornando trivial a
substituição por um mock em testes.

### O Repository centraliza a escolha entre remoto e local?
Sim. `TodoRepositoryImpl` é o único lugar que decide:
- Buscar dados no `RemoteDataSource` (HTTP).
- Persistir a data de sincronização no `LocalDataSource` (SharedPreferences).
Nem a UI nem o ViewModel sabem que existe HTTP ou SharedPreferences.

