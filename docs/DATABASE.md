# Dados e persistência — GymTrack

## Tecnologias

- SQLite (`sqflite`): treinos, exercícios, séries e histórico.
- SharedPreferences: tema e descanso padrão.

## Migrações

`DatabaseService` está na versão 3 e possui `onUpgrade`.

- **v1:** estrutura original.
- **v2:** arquivamento lógico e metadados de auditoria/sincronização.
- **v3:** prescrição de exercícios, `restSeconds` por série e vínculo/snapshot de histórico.

A migração preenche datas ausentes em registros legados e não remove dados existentes.

## Tabelas

| Tabela | Dados principais |
| --- | --- |
| `workouts` | identificação, nome, auditoria e arquivamento lógico |
| `exercises` | vínculo com treino, prescrição, auditoria e arquivamento lógico |
| `exercise_sets` | série gerada, repetições, peso, descanso e duração opcional |
| `workout_history` | sessão, `workoutId`, snapshot, duração e progresso |

## Persistência incremental

`WorkoutStorage` possui operações de inserir, atualizar, arquivar, restaurar e limpeza física futura. A UI não expõe limpeza física.

## Sincronização futura

Os registros carregam UUID, `createdAt`, `updatedAt`, `schemaVersion`, `deviceId` e `userId` quando aplicável. Arquivamento usa `isArchived` e `archivedAt`, permitindo tombstones para Firebase.