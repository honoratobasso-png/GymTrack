# Sprint 16 — Sincronização em nuvem

## Decisão técnica recomendada

**Firebase** é a plataforma recomendada para o GymTrack.

### Motivos

- Integração oficial e madura com Flutter por meio do FlutterFire.
- Suporte direto às autenticações Google, Apple e e-mail planejadas para a Sprint 17.
- Firestore permite sincronização offline e atualização em tempo real.
- A configuração oficial gera `firebase_options.dart` para Android, iOS e Web.

Supabase permanece uma alternativa válida, especialmente para uma equipe que prefira PostgreSQL e políticas SQL explícitas. Para este projeto, Firebase reduz o atrito nas sprints de autenticação e publicação.

## Arquitetura de sincronização

O SQLite continua sendo a fonte local do aplicativo. A nuvem será uma segunda cópia por usuário autenticado.

```text
UI → serviços locais (SQLite) → fila de sincronização → Firebase
                          ↑                         ↓
                      leitura offline       alterações remotas
```

### Princípios

- O aplicativo deve continuar funcionando sem internet.
- Nenhum dado local é apagado ao ativar sincronização.
- Cada registro remoto terá `userId`, `updatedAt` e `deletedAt` quando aplicável.
- A resolução inicial de conflito será “última alteração vence”, registrada em log para evolução futura.
- Regras de segurança devem impedir acesso a dados de outro usuário.

## Dados previstos no Firestore

```text
users/{userId}
  workouts/{workoutId}
    exercises/{exerciseId}
      sets/{setId}
  history/{historyId}
```

Campos mínimos de sincronização: `id`, `updatedAt`, `deletedAt`, `schemaVersion` e `deviceId`.

## Etapa pendente de autorização

Para ativar a implementação, o proprietário deve criar ou indicar um projeto Firebase. Depois disso, a configuração oficial será:

```powershell
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

Somente então serão adicionados `firebase_core`, `firebase_auth` e `cloud_firestore`, junto com as regras de segurança e a migração local-remota.