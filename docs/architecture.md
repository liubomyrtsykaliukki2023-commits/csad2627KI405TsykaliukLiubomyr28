# Архітектура агента

## 1. Проблеми, які вирішує агент

Агент автоматизує початкове налаштування кросплатформного Rust-проєкту Hello World. Він створює основу Cargo-проєкту, налаштовує збірку та тест `basic_addition`, готує локальні CI-скрипти для Linux/macOS і Windows та описує GitHub Actions workflow, що запускає ці скрипти. Перевірки й правила ідемпотентності допомагають виявляти помилки та не дублювати наявний вміст.

## 2. Skills та їхня відповідальність

| Skill | Відповідальність |
|---|---|
| `project-scaffold` | Створити базовий Rust scaffold: `src/lib.rs`, `src/main.rs`, порожні каталоги `tests/` і `docs/`, а також `README.md`, якщо його ще немає. |
| `build-and-test` | Налаштувати `Cargo.toml`, інтеграційний тест `basic_addition`, згенерувати `Cargo.lock` та створити `ci.sh` і `ci.bat` для збірки, тестів і копіювання binary у `dist/`. |
| `github-actions` | Налаштувати `.github/workflows/ci.yml` для Linux, Windows і macOS, делегуючи збірку та тести локальним CI-скриптам і публікуючи артефакт `dist/`. |

## 3. Commands для користувача

| Command | Призначення |
|---|---|
| `/git-init` | Перевірити Git-репозиторій, створити або доповнити `.gitignore` та показати `git status`. |
| `/create-project` | Виконати `project-scaffold` для Rust-проєкту `hello`. |
| `/create-build` | Виконати `build-and-test` для Cargo, тесту й локальних CI-скриптів. |
| `/create-actions` | Виконати `github-actions` для GitHub Actions workflow. |
| `/check` | У режимі лише для читання перевірити структуру, збірку, тести, workflow та Git ignore; вивести `PASS`/`FAIL`. |
| `/init` | Послідовно оркеструвати попередні команди та фінальну перевірку. Команда має виконувати кожен етап окремо й зупинятися при першій помилці. |

## 4. Потік даних між етапами

```text
project_name=hello
        -> project-scaffold
        -> src/lib.rs + src/main.rs
        -> build-and-test: Cargo.toml + tests/test_basic.rs + Cargo.lock
        -> ci.sh / ci.bat: release build + tests + binary у dist/
        -> github-actions: ci.yml запускає відповідний скрипт для кожної ОС
```

- `project_name=hello` задає назву Cargo-пакета й executable `hello`.
- Scaffold створює бібліотеку з `hello_lib::add` та `main.rs`, який використовує бібліотеку й друкує привітання.
- `Cargo.toml` пов'язує package `hello` з library target `hello_lib` і binary target `hello`; тест перевіряє `hello_lib::add(2, 3) == 5`.
- `ci.sh` і `ci.bat` виконують release-збірку та тести, після чого копіюють executable до `dist/` з урахуванням розширення `.exe` у Windows.
- `.github/workflows/ci.yml` вибирає локальний скрипт відповідно до ОС у матриці. Сам workflow не виконує Cargo-команди напряму.

## 5. Обробка помилок оркестратором `init`

`init` має прочитати й виконати команди строго послідовно: `git-init`, `create-project`, `create-build`, `create-actions`, `check`. Після кожного етапу він перевіряє результат і переходить далі лише після успіху.

Якщо команда або її перевірка завершується помилкою, оркестратор зупиняється, називає крок і причину, вказує що потрібно виправити та позначає наступні кроки як `NOT RUN`. Підсумковий статус може бути `PASSED` лише після явного `PASSED` від `check`. Перевірка `check` працює лише для читання.

## 6. Відповідність файлів ролям

| Роль | Розташування | Призначення |
|---|---|---|
| Agent | `.github/agents/` | Описує роль build engineer, доступні інструменти, правила та критерії завершення. |
| Skills | `.github/skills/` | Містить спеціалізовані workflow для scaffold, збірки/тестів і GitHub Actions. |
| Commands | `.github/prompts/` | Містить команди користувача, зокрема окремі етапи та оркестратор `init`. |

## 7. Формат VS Code Copilot

У проєкті використано формат кастомізацій VS Code Copilot: custom agent (`.agent.md`), prompt files (`.prompt.md`) та agent skills (`SKILL.md`). Ці файли зберігаються в `.github/`, щоб налаштування були частиною репозиторію.