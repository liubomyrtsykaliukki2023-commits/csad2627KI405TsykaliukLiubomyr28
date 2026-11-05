csad2627KI405TsykaliukLiubomyr28

## Інформація про лабораторну

- ПІП: [ПІП]
- Група: [група]
- Варіант: 28 (Rust, Cargo, cargo test)

Проєкт демонструє роботу AI-агента для VS Code Copilot, який створює базовий Rust-проєкт Hello World, налаштовує Cargo-збірку та тести, а також готує кросплатформний CI на GitHub Actions.

## Запуск агента

1. Відкрити папку репозиторію у VS Code.
2. Відкрити Copilot Chat.
3. Вибрати агента `build-engineer`.
4. Виконати команду `/init`.

## Commands

- `/git-init` — перевірити Git-репозиторій і створити або доповнити `.gitignore`.
- `/create-project` — створити базову структуру Rust-проєкту.
- `/create-build` — налаштувати Cargo, тест і локальні CI-скрипти.
- `/create-actions` — створити GitHub Actions workflow.
- `/check` — перевірити структуру проєкту, збірку, тести та CI.
- `/init` — послідовно виконати повне налаштування проєкту.