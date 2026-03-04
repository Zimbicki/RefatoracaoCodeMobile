# TODO — Refatoração Arquitetural (Projeto Bagunçado)

Este projeto foi montado **de propósito** com:
- **classes corretas** (responsabilidades adequadas dentro do arquivo),
- porém **em lugares errados** na estrutura de pastas,
- com **imports misturados** e uma estrutura pouco escalável.

## Objetivo da atividade
Refatorar para um padrão **feature-first** (por exemplo):
```
lib/
  core/
  features/
    todos/
      data/
      domain/
      presentation/
```

### Regras
1. Não altere a lógica interna das classes (o comportamento deve continuar).
2. Você pode ajustar **imports**, **paths**, e criar pastas.
3. A UI **não pode** chamar HTTP nem SharedPreferences diretamente.
4. O ViewModel **não pode** conhecer Widgets / BuildContext (exceto mensagens via estado).
5. O Repository deve centralizar a escolha entre remoto/local.

## Checklist de entrega
- Projeto compila e roda
- Estrutura de pastas organizada (feature-first)
- `ARCH.md` explicando:
  - diagrama do fluxo (UI → VM → Repo → DataSources)
  - justificativa da estrutura
  - decisões de responsabilidade

## Como rodar
1. `flutter pub get`
2. `flutter run`

> API usada: JSONPlaceholder (https://jsonplaceholder.typicode.com/todos)

---

## O que foi entregue (refatoração)

### Estrutura final

```
lib/
├── main.dart                          # Entry point + injeção de dependências
├── core/
│   ├── errors/app_errors.dart         # AppError — exceção tipada
│   └── ui/app_root.dart               # MaterialApp raiz
└── features/
    └── todos/
        ├── data/
        │   ├── datasources/
        │   │   ├── todo_local_datasource.dart   # SharedPreferences
        │   │   └── todo_remote_datasource.dart  # HTTP (http pkg)
        │   ├── models/
        │   │   └── todo_model.dart    # DTO com fromJson / toJson
        │   └── repositories/
        │       └── todo_repository_impl.dart    # Orquestra remote + local
        ├── domain/
        │   ├── entities/
        │   │   └── todo.dart          # Entidade de negócio (Dart puro)
        │   └── repositories/
        │       └── todo_repository.dart  # Contrato abstrato
        └── presentation/
            ├── screens/
            │   └── todos_page.dart    # Tela principal
            ├── viewmodels/
            │   └── todo_viewmodel.dart  # Estado e lógica de apresentação
            └── widgets/
                └── add_todo_dialog.dart # Diálogo de adição
```

### Regras atendidas

| Regra | Como foi atendida |
|---|---|
| UI não chama HTTP nem SharedPreferences | Apenas `TodoViewModel` é importado pela UI; datasources ficam em `data/` |
| ViewModel não conhece Widgets/BuildContext | `TodoViewModel` importa apenas `foundation.dart` e a interface do domínio |
| Repository centraliza remoto/local | `TodoRepositoryImpl` é o único ponto de decisão entre `RemoteDataSource` e `LocalDataSource` |
| Lógica interna intocada | Nenhum método teve seu comportamento alterado |
| Injeção de dependência | `main.dart` cria `TodoRepositoryImpl` e injeta em `TodoViewModel` via construtor |

### Evidência de análise estática

```
$ flutter analyze
Analyzing aula02_mobileII...
No issues found! (ran in 1.2s)
```

### Tratamento de erros

- Todos os métodos de rede verificam o status HTTP; lançam `Exception` em caso de erro.
- `TodoViewModel` envolve cada chamada em `try/catch` e expõe `errorMessage` via estado (sem BuildContext).
- `toggleCompleted` implementa **rollback otimista**: reverte o item local se a chamada de rede falhar.
- `AppError` tipado disponível em `core/errors/` para evoluções futuras.

### Testes

`test/widget_test.dart` contém um smoke test que:
1. Monta o app com um `_FakeTodoRepository` (sem rede real).
2. Verifica que a `TodosPage` renderiza corretamente.

```
$ flutter test
00:04 +1: All tests passed!
```
