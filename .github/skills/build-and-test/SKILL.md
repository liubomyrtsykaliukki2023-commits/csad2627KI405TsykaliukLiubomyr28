---
name: build-and-test
description: "Застосовуй, коли потрібно налаштувати Cargo для наявних Rust src/lib.rs і src/main.rs, додати basic_addition, створити кросплатформні CI-скрипти, зібрати release binary або перевірити збірку й тести."
---

# Build and Test

Налаштуй Cargo-збірку, тестування та локальні CI-скрипти для наявного Rust-проєкту `hello`.

## Вхід

Передумови: у корені проєкту вже існують `src/lib.rs` і `src/main.rs`. Перевір їхній вміст і переконайся, що бібліотека надає `hello_lib::add`; не перезаписуй їх у цьому workflow.

## Вихід

Створи або узгодь такі файли:

- `Cargo.toml` з параметрами:

  ```toml
  [package]
  name = "hello"
  version = "0.1.0"
  edition = "2021"

  [lib]
  name = "hello_lib"
  path = "src/lib.rs"

  [[bin]]
  name = "hello"
  path = "src/main.rs"
  ```

- `tests/test_basic.rs` з інтеграційним тестом:

  ```rust
  #[test]
  fn basic_addition() {
      assert_eq!(hello_lib::add(2, 3), 5);
  }
  ```

- `Cargo.lock`, згенерований запуском `cargo build` з кореня проєкту. Не створюй і не редагуй його вручну.
- `ci.sh` — Bash-скрипт із `set -euo pipefail`, який виконує `cargo build --release`, `cargo test --release`, створює `dist/` і копіює `target/release/hello` у `dist/hello`.
- `ci.bat` — Windows batch-скрипт, який виконує `cargo build --release`, `cargo test --release`, створює `dist\` і копіює `target\release\hello.exe` у `dist\hello.exe`.

## Правила роботи з файлами

1. Перевір наявні файли перед будь-якою зміною. Не змінюй `src/lib.rs` і `src/main.rs`.
2. Якщо `Cargo.toml` уже існує, перевір його структуровано й узгодь потрібні значення та target-и на місці. Не додавай дублікати `[package]`, `[lib]` чи `[[bin]]`; збережи не пов'язані з цією задачею налаштування.
3. Якщо існуючий файл конфліктує з потрібним результатом і його не можна узгодити без втрати стороннього вмісту, зупинись і повідом шлях та конфлікт. Не перезаписуй файл навмання.
4. Не додавай повторно тест, команди або TOML-секції під час повторного запуску. Скрипти мають лишатися придатними до повторного запуску.
5. Перед копіюванням створюй `dist/` або `dist\`, якщо каталогу ще немає. Виконуваний файл у `dist/` є артефактом збірки та може оновлюватися наступними успішними запусками скрипта.
6. Зроби `ci.sh` виконуваним у Git: вистав executable bit і зафіксуй його командою `git update-index --chmod=+x -- ci.sh`. Якщо файл ще не відстежується Git і команда не може змінити індекс без додаткового staging, не додавай файли до індексу мовчки; повідом про необхідну дію та не заявляй, що Git executable bit налаштовано.

## Скрипти

`ci.sh` має починатися з shebang і завершуватися з ненульовим кодом при першій помилці:

```bash
#!/usr/bin/env bash
set -euo pipefail

cargo build --release
cargo test --release
mkdir -p dist
cp target/release/hello dist/hello
```

`ci.bat` перевіряє `%errorlevel%` після кожної команди й завершується з ненульовим кодом при помилці. Не об'єднуй команди в дужковий блок, щоб перевірки коду завершення були однозначними.

```bat
@echo off
setlocal
cargo build --release
if errorlevel 1 exit /b %errorlevel%
cargo test --release
if errorlevel 1 exit /b %errorlevel%
if not exist dist mkdir dist
if errorlevel 1 exit /b %errorlevel%
copy /Y target\release\hello.exe dist\hello.exe
if errorlevel 1 exit /b %errorlevel%
exit /b 0
```

## Перевірки

1. Переконайся, що Cargo доступний (`cargo --version`). Якщо `cargo` не знайдено, зупинись і повідом, що потрібне встановлення Rust через `rustup`.
2. Запусти `cargo build` з кореня проєкту, щоб Cargo згенерував або оновив `Cargo.lock`.
3. Запусти `cargo test` і підтвердь, що вивід містить `test basic_addition ... ok`.
4. Запусти відповідний CI-скрипт на поточній платформі та перевір ненульовий код завершення при помилці. Після успіху перевір, що executable створено: `target/release/hello` на Linux/macOS або `target\release\hello.exe` на Windows, а копія лежить у `dist/`.
5. Не заявляй про перевірки для інших платформ, якщо їх не запускали.

## Типові помилки

- **`cargo` не знайдено:** Rust toolchain не встановлений або не доданий до `PATH`. Повідом, що потрібен `rustup`; не продовжуй збірку.
- **Неправильне ім'я binary на Windows:** використовуй `target\release\hello.exe` і копіюй його як `dist\hello.exe`.
- **`dist/` відсутній:** створи його (`mkdir -p dist` у Bash, `if not exist dist mkdir dist` у batch) до команди копіювання.
- **Дубльована TOML-секція:** не дописуй ще одну секцію; узгодь наявну або зупинись і повідом про конфлікт.

## Приклад

Вхід:

```text
src/lib.rs і src/main.rs вже існують
```

Очікуваний результат після успішного налаштування:

```text
$ cargo test
test basic_addition ... ok

$ ./ci.sh
... успішні cargo build --release і cargo test --release ...
dist/hello створено
```

У Windows відповідний результат: успішний запуск `ci.bat` і створений `dist\hello.exe`.