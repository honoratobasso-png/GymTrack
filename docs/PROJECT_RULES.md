# Regras de manutenção — GymTrack

## Antes de alterar

1. Leia os modelos e serviços afetados.
2. Preserve a compatibilidade dos dados já armazenados quando possível.
3. Não altere o esquema SQLite sem definir uma migração e elevar a versão do banco.

## Código

- Use nomes em inglês para classes, arquivos e propriedades; textos visíveis ao usuário ficam em português (BR).
- Prefira comentários para decisões e regras não óbvias, não para repetir o código.
- Sempre descarte `TextEditingController`, `Timer`, `AudioPlayer` e listeners em `dispose`.
- Após `await` em widgets, use `mounted` antes de navegar, exibir diálogo ou chamar `setState`.
- Serviços de dados não devem depender de widgets ou `BuildContext`.

## Persistência

- Dados de treino e histórico pertencem ao SQLite.
- Preferências pequenas pertencem ao `SharedPreferences`.
- Mantenha o uso de transações ao gravar treino, exercícios e séries juntos.

## Qualidade e documentação

- Execute `dart format` nos arquivos modificados.
- Execute `dart analyze` antes de entregar uma alteração.
- Atualize `docs/CHANGELOG.md` e `docs/ROADMAP.md` em cada sprint concluída.
- Atualize estes documentos quando arquitetura, dados ou fluxos mudarem.