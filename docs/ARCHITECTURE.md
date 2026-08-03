# Arquitetura — GymTrack

## Estado atual

A Refactor Sprint 17 consolida o MVP para crescimento sustentável, sem substituir a arquitetura por outro padrão.

```text
lib/
├── app/                 MaterialApp, tema e preferências globais
├── features/            telas, controladores e fluxos por domínio
├── shared/models/       entidades e contratos de domínio
├── shared/services/     SQLite, IDs e preferências de baixo nível
├── shared/repositories/ fronteira de dados usada pela UI
└── shared/widgets/      componentes reutilizáveis
```

## Regras de dependência

- Páginas e controladores não acessam `DatabaseService`.
- `WorkoutRepository`, `HistoryRepository` e `SettingsRepository` são a porta de entrada de dados para a UI.
- `WorkoutStorage` é uma implementação local de persistência incremental, usada apenas pelo repositório.
- SQLite é a fonte local de verdade; Firebase será uma réplica futura, não um substituto do modo offline.

## Modelo de domínio

- `Workout` e `Exercise` possuem arquivamento lógico, auditoria e metadados de sincronização.
- `ExercisePrescription` contém a intenção do usuário: quantidade de séries, repetições, peso e descanso.
- `ExerciseSet` é a série gerada e editável individualmente, com `restSeconds` separado de `durationSeconds`.
- `WorkoutHistoryEntry` guarda `workoutId` e snapshot mínimo da sessão.

## Fluxo de dados

```text
Tela → Repository → Storage/HistoryRepository → DatabaseService → SQLite
```

Novas entidades recebem UUID v4 local. `userId`, `deviceId`, `updatedAt` e `schemaVersion` tornam os registros preparados para sincronização futura.