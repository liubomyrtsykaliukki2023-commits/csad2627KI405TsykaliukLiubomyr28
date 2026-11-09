# Usage

## Запуск агента в VS Code

1. Відкрийте папку репозиторію в VS Code.
2. Відкрийте панель Copilot Chat.
3. Виберіть агента `build-engineer`.
4. Виконайте команду `/init`.
5. Для перевірки стану виконання виконайте `/check`.

## Локальна збірка та перевірка

### Linux / macOS

```bash
chmod +x ci.sh
./ci.sh
```

### Windows

```bat
ci.bat
```

## Запуск тестів

```bash
cargo test --release
```

## Запуск додатку

### Linux / macOS

```bash
./dist/hello
```

### Windows

```bat
dist\hello.exe
```

## Очікуваний результат

- Проєкт компілюється в релізному режимі.
- Тести проходять через `cargo test --release`.
- Виконавчий файл створюється в `dist/` або `dist\` залежно від ОС.
- Агент `build-engineer` може бути запущений через Copilot Chat командою `/init`.
