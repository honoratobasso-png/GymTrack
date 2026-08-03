# Dívida técnica — GymTrack

## Prioridade alta

- Criar testes de integração para `DatabaseService.onUpgrade` em bancos v1/v2 reais.
- Definir estratégia de identidade de dispositivo antes da sincronização Firebase.
- Implementar restauração de treinos e exercícios arquivados com uma tela apropriada.

## Prioridade média

- Expor edição individual de `ExerciseSet` na interface.
- Substituir gravação do grafo inteiro por diff granular de filhos quando houver sincronização concorrente.
- Tornar histórico de sessão mais detalhado, incluindo resultado por série.

## Prioridade baixa

- Substituir dependências declaradas como `any` por versões explícitas.
- Consolidar identificadores de aplicativo Android/iOS/Linux antes de configurar Firebase.
- Ajustar exportação/importação de backup para incluir entidades arquivadas e metadados.