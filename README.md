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
