---
description: "Лише для читання перевірити структуру Rust-проєкту, Cargo build і test, GitHub Actions workflow та правила Git ignore; вивести таблицю PASS/FAIL."
agent: build-engineer
---

# Check

## Передумови

- Працюй із кореня Git-репозиторію.
- Режим роботи — **ТІЛЬКИ ЧИТАННЯ**. Не створюй, не змінюй, не перейменовуй і не видаляй файли проєкту. Не виправляй помилки, знайдені перевірками.
- Дозволені тимчасові build-файли лише в `target/`, який має бути в `.gitignore`.
- Перед перевірками зафіксуй результат `git status --short --untracked-files=all`, щоб знати початковий стан. Не скасовуй і не перезаписуй наявні зміни користувача.
- Для Cargo використовуй `--locked`, щоб не створювати й не змінювати `Cargo.lock`.
- Перед запуском Cargo переглянь `Cargo.toml`, build scripts і тестовий код. Якщо вони можуть змінювати файли поза `target/` або це неможливо встановити, не запускай цей код і познач відповідні перевірки `FAIL`.
- Усі результати та таблицю виводь у відповідь. Не створюй файл звіту.

## Перевірки

Виконай усі дев'ять перевірок і для кожної вистав `PASS` або `FAIL`. Запиши короткий доказ: шлях, команду та суттєвий результат. Якщо перевірку неможливо виконати, вважай її `FAIL` і поясни чому.

1. **Агент і skills:** існують `.github/agents/build-engineer.agent.md` та рівно три потрібні для цієї перевірки файли skill-ів: `.github/skills/project-scaffold/SKILL.md`, `.github/skills/build-and-test/SKILL.md`, `.github/skills/github-actions/SKILL.md`.
2. **Розділи skills:** кожен із трьох файлів має окремі Markdown-заголовки `Вхід`, `Вихід` і `Перевірки` (наприклад, `## Вхід`). Заголовки `Вхідні дані` або `Результат` не вважай точним збігом.
3. **Файли проєкту:** існують `src/lib.rs`, `src/main.rs`, `tests/test_basic.rs`, `Cargo.toml`, `Cargo.lock`, `ci.sh` і `ci.bat`.
4. **Release build:** виконай `cargo build --release --locked`; команда має завершитися з кодом `0`.
5. **Release tests:** виконай `cargo test --release --locked`; команда має завершитися з кодом `0`, а вивід містити `test basic_addition ... ok`.
6. **Виконуваний файл:** після успішного build існує executable `target/release/hello` на Linux/macOS або `target\release\hello.exe` на Windows. На Unix перевір executable bit, наприклад `test -x target/release/hello`; на Windows перевір наявність `.exe`.
7. **GitHub Actions:** `.github/workflows/ci.yml` існує та є валідним YAML. Перевір `actionlint`, якщо він доступний; інакше скористайся PyYAML. Workflow має містити тригери `push` і `pull_request` для `develop` та `master`, рівно одну job із `fail-fast: false` і матрицею `ubuntu-latest`, `windows-latest`, `macos-latest`, checkout через `actions/checkout@v4` та upload через `actions/upload-artifact@v4` із `dist/`, `hello-${{ matrix.os }}` і `if-no-files-found: error`. Переглянь усі `run` кроки структурно: вони мають викликати лише `./ci.sh` або `ci.bat` відповідно до ОС; прямих команд `cargo` чи `rustc` бути не повинно. У workflow не має бути слів `token`, `password` або `secret`.
8. **Відстежувані заборонені шляхи:** переглянь вивід `git ls-files` і переконайся, що Git не відстежує нічого з `target/`, `build/`, `dist/`, файл `.env` або файли, що відповідають `*.key` чи `*.pem`. Виведи перелік збігів або підтвердження, що їх немає.
9. **`.gitignore`:** файл `.gitignore` містить окремі правила `target/`, `build/` і `dist/`.

Для перевірки YAML приклад запасної команди:

```text
python -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml', encoding='utf-8'))"
```

Після всіх перевірок повторно виконай `git status --short --untracked-files=all`. Порівняй із початковим станом: будь-яка зміна файлів проєкту поза `target/` означає `FAIL` для read-only режиму. Не намагайся прибирати такі зміни.

Виведи таблицю:

| # | Перевірка | Результат | Доказ |
|---|---|---|---|
| 1-9 | Назва перевірки | PASS або FAIL | Команда/шлях і результат |

Після таблиці виведи загальний статус: `PASSED`, лише якщо всі перевірки мають `PASS`; інакше `FAILED`.

## Повідомлення про помилку

- Якщо команда завершується помилкою, інструмент перевірки відсутній або даних недостатньо для висновку, відповідну перевірку познач `FAIL` із конкретною причиною.
- Не виправляй помилки й не змінюй файли. Виведи повну таблицю результатів і загальний статус `FAILED`, якщо є хоча б один `FAIL`.
- Не повідомляй `PASSED`, якщо будь-яку перевірку пропущено або не вдалося підтвердити.