---
name: github-actions
description: "Застосовуй, коли потрібно створити або перевірити GitHub Actions workflow для Rust-проєкту з матрицею Linux, Windows і macOS, який запускає ci.sh або ci.bat та завантажує dist/."
---

# GitHub Actions

Створи кросплатформний workflow для проєкту `hello`. Workflow має делегувати збірку та тести локальним CI-скриптам репозиторію.

## Вхід

- У корені проєкту вже є перевірені `ci.sh` і `ci.bat`.
- `ci.sh` має executable bit для запуску на Linux і macOS.

## Вихід

Створи `.github/workflows/ci.yml` з такими властивостями:

- Тригери `push` і `pull_request` лише для гілок `develop` та `master`.
- Одна job із `strategy.fail-fast: false` та matrix `os: [ubuntu-latest, windows-latest, macos-latest]`.
- Крок checkout через `actions/checkout@v4`.
- На Windows запускай `ci.bat` з `shell: cmd`.
- На Linux і macOS запускай `./ci.sh` з `shell: bash`.
- Завантажуй `dist/` через `actions/upload-artifact@v4`; назва артефакту має бути `hello-${{ matrix.os }}`, а `if-no-files-found` — `error`.
- Не додавай облікових даних, залежностей від GitHub repository secrets чи інших чутливих налаштувань.

Зразок структури:

```yaml
name: CI

on:
  push:
    branches: [develop, master]
  pull_request:
    branches: [develop, master]

jobs:
  build:
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4

      - name: Run Windows CI
        if: runner.os == 'Windows'
        shell: cmd
        run: ci.bat

      - name: Run Unix CI
        if: runner.os != 'Windows'
        shell: bash
        run: ./ci.sh

      - uses: actions/upload-artifact@v4
        with:
          name: hello-${{ matrix.os }}
          path: dist/
          if-no-files-found: error
```

## Обмеження кроків

- У `run` кроків workflow дозволені лише виклики `ci.sh` або `ci.bat` відповідно до ОС. Не запускай `cargo`, `rustc` чи інші build-команди безпосередньо з `ci.yml`.
- Зберігай єдину job і задану матрицю; не створюй окремі jobs для платформ.
- Не змінюй локальні CI-скрипти в межах цього workflow, якщо вони не відповідають вимогам: повідом про проблему, щоб її виправили у skill `build-and-test`.
- Не перезаписуй наявний `ci.yml` без перевірки. Якщо він має сторонні налаштування або конфліктний вміст, збережи його та повідом про конфлікт.

## Перевірки

Перевір саме `.github/workflows/ci.yml`:

1. YAML синтаксично валідний: запусти `actionlint`, якщо він доступний; інакше перевір парсером PyYAML, наприклад:

   ```text
   python -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml', encoding='utf-8'))"
   ```

2. У workflow є всі три значення ОС: `ubuntu-latest`, `windows-latest`, `macos-latest`.
3. Є тільки одна job, `fail-fast: false`, а тригери обмежені гілками `develop` і `master` для `push` та `pull_request`.
4. Переглянь кожен `run`: мають бути лише `ci.bat` і `./ci.sh` у відповідних умовних кроках. Команд `cargo` або `rustc` у `run` бути не повинно.
5. Крок завантаження використовує `actions/upload-artifact@v4`, має унікальне ім'я `hello-${{ matrix.os }}`, шлях `dist/` і `if-no-files-found: error`.
6. У `ci.yml` немає слів `token`, `password` або `secret`.

Якщо `actionlint` або Python-модуль `yaml` відсутній, повідом про це й не стверджуй, що відповідна перевірка пройшла.

## Типова помилка

**`ci.sh` не має права на виконання.** Виклик `./ci.sh` на Linux/macOS потребує executable bit. Попроси виправити його у `build-and-test` skill та зафіксувати режим Git командою `git update-index --chmod=+x -- ci.sh`; не маскуй помилку запуском через іншу команду.

## Приклад

Вхід:

```text
Створи GitHub Actions CI для hello на develop і master.
Локальні скрипти ci.sh та ci.bat уже налаштовані.
```

Очікуваний результат: `.github/workflows/ci.yml` запускає `./ci.sh` на Ubuntu і macOS, `ci.bat` на Windows, а після успіху кожної платформи завантажує окремий артефакт `hello-<назва-ОС>` із `dist/`. YAML проходить перевірку, прямі команди збірки у workflow відсутні.