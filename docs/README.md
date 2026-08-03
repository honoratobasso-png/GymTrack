# Documentação do GymTrack

O GymTrack é um aplicativo Flutter offline para criação, execução e acompanhamento de treinos.

## Estado atual

O projeto está na **Sprint 14**. Treinos, exercícios, séries e histórico funcionam localmente; preferências de tema e descanso também são persistidas.

## Guias

- [Produto](PRODUCT.md): objetivo, público e escopo do MVP.
- [Arquitetura](ARCHITECTURE.md): organização do código, fluxo de dados e navegação.
- [Banco de dados](DATABASE.md): SQLite, tabelas e responsabilidades de persistência.
- [Roadmap](ROADMAP.md): sprints concluídas e próximos passos.
- [Histórico de alterações](CHANGELOG.md): mudanças relevantes por data.
- [Regras do projeto](PROJECT_RULES.md): convenções para manutenção segura.

## Como executar

```powershell
flutter pub get
flutter run
```

Para validar o código sem iniciar o aplicativo:

```powershell
dart analyze
```