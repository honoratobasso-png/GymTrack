# Histórico de alterações — GymTrack

## 2026-07-31 — Refactor Sprint 17

- Adicionado arquivamento lógico (`isArchived`, `archivedAt`) a treinos e exercícios.
- Substituída exclusão de treino na interface por arquivamento.
- Criado `ExercisePrescription`; o cadastro de exercício agora gera séries automaticamente.
- `ExerciseSet` recebeu `restSeconds`, UUID, auditoria e metadados de sincronização.
- IDs novos migrados de timestamp para UUID v4 local.
- Histórico recebeu `workoutId`, snapshot mínimo e metadados.
- `WorkoutStorage` passou de remoção total para persistência incremental com inserir, atualizar, arquivar, restaurar e limpeza física interna futura.
- SQLite recebeu migrações v1→v3 sem remoção de dados legados.
- Criados `WorkoutRepository` e `SettingsRepository`; a UI não acessa mais o armazenamento diretamente.
- Criados testes de domínio para UUID, arquivamento e geração de séries.

## Documentação

- Atualizados ROADMAP, ARCHITECTURE, PRODUCT e DATABASE.
- Criado TECH_DEBT.md.