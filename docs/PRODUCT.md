# Produto — GymTrack

## Propósito

Planejar, executar e acompanhar treinos offline, preservando a evolução do usuário.

## Regras de negócio consolidadas

- Treinos não são excluídos pela interface: são arquivados e permanecem recuperáveis.
- Exercícios seguem a mesma regra de arquivamento.
- O usuário informa uma prescrição por exercício: quantidade de séries, repetições, peso e descanso.
- O sistema gera as séries automaticamente; cada uma mantém identidade própria para edição posterior.
- Descanso de série (`restSeconds`) não é duração de exercício (`durationSeconds`).
- Histórico preserva o treino executado por ID e snapshot, mesmo após edição, renomeação ou arquivamento.

## Limites atuais

- Não há restauração de arquivos na interface ainda.
- Edição individual de série é suportada pelo modelo, mas será exposta em etapa posterior.
- Firebase continua apenas planejado; o app funciona integralmente offline.