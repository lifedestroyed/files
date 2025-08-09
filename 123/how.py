import random
import string
import json

# Приветствие
def greet():
    print("Добро пожаловать в программу 'Менеджер произведений и паролей'!")
    print("Здесь вы можете управлять рейтингами произведений и своими паролями.")
    print("Выберите режим работы:")
    print("1. Управление рейтингами произведений")
    print("2. Управление паролями")

# Словарь для хранения произведений и их рейтингов
works = {
    "Фильмы": {
        "Inception": 8.8,
        "The Shawshank Redemption": 9.3,
        "The Dark Knight": 9.0,
    },
    "Книги": {
        "1984": 9.0,
        "To Kill a Mockingbird": 8.7,
    },
    "Альбомы": {
        "The Dark Side of the Moon": 9.5,
        "Thriller": 8.9,
    }
}

# Словарь для хранения паролей
passwords = {}

# Пароль для доступа к словарю
dictionary_password = None

# Функция для генерации случайного пароля
def generate_random_password(length):
    characters = string.ascii_letters + string.digits + string.punctuation
    return ''.join(random.choice(characters) for _ in range(length))

# Функция для управления паролями
def manage_passwords():
    while True:
        print("\nДоступные команды:")
        print("1. Показать список паролей")
        print("2. Удалить пароль")
        print("3. Добавить пароль")
        print("4. Получить случайный пароль")
        print("5. Выход")
        command = input("Введите номер команды: ")
        if command == "1":
            print("Список паролей:")
            for name, password in passwords.items():
                print(f"{name}: {password}")
        elif command == "2":
            name = input("Введите название пароля для удаления: ")
            if name in passwords:
                del passwords[name]
                print(f"Пароль для '{name}' удален.")
            else:
                print(f"Пароль для '{name}' не найден.")
        elif command == "3":
            name = input("Введите название для пароля: ")
            length = int(input("Введите длину пароля: "))
            password = generate_random_password(length)
            passwords[name] = password
            print(f"Пароль для '{name}' добавлен: {password}")
        elif command == "4":
            if passwords:
                name, password = random.choice(list(passwords.items()))
                print(f"Случайный пароль: {name} - {password}")
            else:
                print("Нет доступных паролей.")
        elif command == "5":
            break
        else:
            print("Такой команды не существует.")

# Функция для установки пароля на словарь
def set_dictionary_password():
    global dictionary_password
    dictionary_password = input("Введите пароль для доступа к словарю: ")
    print("Пароль для доступа к словарю установлен.")

# Функция для проверки пароля
def check_dictionary_password():
    if dictionary_password:
        password_attempt = input("Введите пароль для доступа к словарю: ")
        return password_attempt == dictionary_password
    return True

# Функция для записи данных в файл
def save_to_file(filename, data):
    with open(filename, 'w') as file:
        json.dump(data, file)
    print(f"Данные сохранены в файл '{filename}'.")

# Функции для управления рейтингами произведений
def show_works():
    if check_dictionary_password():
        print("Список произведений и их рейтинги:")
        for category, items in works.items():
            print(f"{category}:")
            for item, rating in items.items():
                print(f"  {item}: {rating}")
    else:
        print("Неверный пароль. Доступ запрещен.")

def add_work():
    if check_dictionary_password():
        category = input("Введите категорию произведения (Фильмы, Книги, Альбомы): ")
        if category not in works:
            works[category] = {}

        work = input("Введите название произведения: ")
        rating = float(input("Введите рейтинг произведения: "))
        works[category][work] = rating
        print(f"Произведение '{work}' добавлено с рейтингом {rating} в категорию '{category}'.")
    else:
        print("Неверный пароль. Доступ запрещен.")

def remove_work():
    if check_dictionary_password():
        category = input("Введите категорию произведения (Фильмы, Книги, Альбомы): ")
        if category in works:
            work = input("Введите название произведения для удаления: ")
            if work in works[category]:
                del works[category][work]
                print(f"Произведение '{work}' удалено из категории '{category}'.")
            else:
                print(f"Произведение '{work}' не найдено в категории '{category}'.")
        else:
            print(f"Категория '{category}' не найдена.")
    else:
        print("Неверный пароль. Доступ запрещен.")

def random_work():
    if check_dictionary_password():
        category = random.choice(list(works.keys()))
        work, rating = random.choice(list(works[category].items()))
        print(f"Случайное произведение: {category} - {work} с рейтингом {rating}")
    else:
        print("Неверный пароль. Доступ запрещен.")

def change_rating():
    if check_dictionary_password():
        category = input("Введите категорию произведения (Фильмы, Книги, Альбомы): ")
        if category in works:
            work = input("Введите название произведения для изменения рейтинга: ")
            if work in works[category]:
                new_rating = float(input("Введите новый рейтинг: "))
                works[category][work] = new_rating
                print(f"Рейтинг произведения '{work}' изменен на {new_rating} в категории '{category}'.")
            else:
                print(f"Произведение '{work}' не найдено в категории '{category}'.")
        else:
            print(f"Категория '{category}' не найдена.")
    else:
        print("Неверный пароль. Доступ запрещен.")

# Основной цикл программы
def main():
    greet()
    mode = input("Выберите режим (1 или 2): ")
    if mode == "1":
        print("Вы выбрали режим управления рейтингами произведений.")
        while True:
            print("\nДоступные команды:")
            print("1. Показать список произведений и их рейтинг")
            print("2. Удалить произведение")
            print("3. Добавить произведение")
            print("4. Случайное произведение")
            print("5. Изменить рейтинг произведения")
            print("6. Установить пароль для доступа к словарю")
            print("7. Сохранить данные в файл")
            print("8. Выход")
            command = input("Введите номер команды: ")
            if command == "1":
                show_works()
            elif command == "2":
                remove_work()
            elif command == "3":
                add_work()
            elif command == "4":
                random_work()
            elif command == "5":
                change_rating()
            elif command == "6":
                set_dictionary_password()
            elif command == "7":
                filename = input("Введите имя файла для сохранения: ")
                save_to_file(filename, works)
            elif command == "8":
                break
            else:
                print("Такой команды не существует.")
    elif mode == "2":
        manage_passwords()
    else:
        print("Неверный выбор режима.")

if __name__ == "__main__":
    main()
