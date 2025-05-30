#!/bin/bash

# Проверяем, что входим в корень проекта
if [ ! -f "mkdocs.yml" ]; then
  echo "Ошибка: mkdocs.yml не найден. Убедитесь, что вы в корне проекта MkDocs."
  exit 1
fi


if [ -z "$(git status --porcelain)" ]; then
  echo "Рабочая директория чиста. Нечего коммитить."
else
  git add .

  echo "Введите сообщение коммита:"
  read commit_message

  git commit -m "$commit_message"

  # Отправляем в ветку main
  git push origin main
fi

echo "Изменения отправлены. Сайт будет развернут через GitHub Actions."
