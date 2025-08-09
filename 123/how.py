import random
import string

# Приветствие
def greet():
    print("Добро пожаловать в программу 'Менеджер фильмов и паролей'!")
    print("Здесь вы можете управлять рейтингами фильмов и своими паролями.")
    print("Выберите режим работы:")
    print("1. Управление рейтингами фильмов")
    print("2. Управление паролями")

# Словарь для хранения фильмов и их рейтингов
movies = {
    "Inception": 8.8,
    "The Shawshank Redemption": 9.3,
    "The Dark Knight": 9.0,
    "Pulp Fiction": 8.9,
    "Fight Club": 8.8
}

# Словарь для хранения паролей
passwords = {}

# Функция для генерации случайного пароля
def generate_random_password(length=12):
    characters = string.ascii_letters + string.digits + string.punctuation
    password = ''.join(random.choice(characters) for _ in range(length))
    return password

# Функции для управления рейтингами фильмов
def show_movies():
    print("Список фильмов и их рейтинги:")
    for movie, rating in movies.items():
        print("{}: {}".format(movie, rating))

def add_movie():
    movie = input("Введите название фильма: ")
    rating = float(input("Введите рейтинг фильма: "))
    movies[movie] = rating
    print("Фильм '{}' добавлен с рейтингом {}".format(movie, rating))

def remove_movie():
    movie = input("Введите название фильма для удаления: ")
    if movie in movies:
        del movies[movie]
        print("Фильм '{}' удален".format(movie))
    else:
        print("Фильм '{}' не найден".format(movie))

def random_movie():
    movie, rating = random.choice(list(movies.items()))
    print("Случайный фильм: {} с рейтингом {}".format(movie, rating))

def change_rating():
    movie = input("Введите название фильма для изменения рейтинга: ")
    if movie in movies:
        new_rating = float(input("Введите новый рейтинг: "))
        movies[movie] = new_rating
        print("Рейтинг фильма '{}' изменен на {}".format(movie, new_rating))
    else:
        print("Фильм '{}' не найден".format(movie))

# Функции для управления паролями
def show_passwords():
    print("Список паролей:")
    for name, password in passwords.items():
        print("{}: {}".format(name, password))

def add_password():
    name = input("Введите название для пароля: ")
    password = generate_random_password()
    passwords[name] = password
    print("Пароль для '{}' добавлен: {}".format(name, password))

def remove_password():
    name = input("Введите название пароля для удаления: ")
    if name in passwords:
        del passwords[name]
        print("Пароль для '{}' удален.".format(name))
    else:
        print("Пароль для '{}' не найден.".format(name))

def random_password():
    if passwords:
        name, password = random.choice(list(passwords.items()))
        print("Случайный пароль: {} - {}".format(name, password))
    else:
        print("Нет доступных паролей.")

# Основной цикл программы
def main():
    greet()
    mode = input("Выберите режим (1 или 2): ")
    if mode == "1":
        print("Вы выбрали режим управления рейтингами фильмов.")
        while True:
            print("Доступные команды:")
            print("1. Показать список фильмов и их рейтинг")
            print("2. Удалить фильм")
            print("3. Добавить фильм")
            print("4. Случайный фильм для пользователя")
            print("5. Изменить рейтинг фильму")
            print("6. Выход")
            command = input("Введите номер команды: ")
            if command == "1":
                show_movies()
            elif command == "2":
                remove_movie()
            elif command == "3":
                add_movie()
            elif command == "4":
                random_movie()
            elif command == "5":
                change_rating()
            elif command == "6":
                break
            else:
                print("Такой команды не существует.")
    elif mode == "2":
        print("Вы выбрали режим управления паролями.")
        while True:
            print("Доступные команды:")
            print("1. Показать список паролей")
            print("2. Удалить пароль")
            print("3. Добавить пароль")
            print("4. Получить случайный пароль")
            print("5. Выход")
            command = input("Введите номер команды: ")
            if command == "1":
                show_passwords()
            elif command == "2":
                remove_password()
            elif command == "3":
                add_password()
            elif command == "4":
                random_password()
            elif command == "5":
                break
            else:
                print("Такой команды не существует.")
    else:
        print("Неверный выбор режима.")

if __name__ == "__main__":
    main()
