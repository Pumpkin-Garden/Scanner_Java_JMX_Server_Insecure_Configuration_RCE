> For educational purposes only

## 1. Scanner Java JMX Server Insecure Configuration RCE
The task that this script solves is to automatically scan a large list of hosts and save a short result to a file. This script is based on the Beanshooter utility.
List of performed checks:
- Access without authentication
- Use of weak passwords
- Deserialization attack capability (RCE)
- Ability to read arbitrary files (Path Traversal)
- Ability to load MBean-class (RCE)

## 1. Сканер Java JMX Server Insecure Configuration RCE
Задача, которую решает этот скрипт: автоматизированное сканирование большого списка хостов и сохранение краткого результата в файл. В основе данного скрипта лежит утилита Beanshooter.
Список выполняемых проверок:
- Доступ без аутентификации
- Использование слабых паролей
- Возможность атаки десериализации (RCE)
- Возможность чтения произвольных файлов (Path Traversal)
- Возможность загрузки MBean-класса (RCE)


## 2. How to use
1. Install [**Beanshooter**](https://github.com/qtc-de/beanshooter) from the official repository. Use the installation instructions
2. Before running the script start the stager server to deliver the MBean. ```./beanshooter.jar stager <IP> <Port> tonka```
3. Change the Stager_* variables to the IP and Port values of your web server
4. Add a list of hosts to scan through to the **hosts.txt** file. IP and Port must be separated by any characters
5. Change the Beanshooter variable to the name and path of your jar file. I have everything in one directory, so I use ./beanshooter
6. Change the user_file and password_file variables to the path to files with logins and passwords for easy brute force. Or download these files from here and place them in the bash directory.
7. The result will be displayed in the terminal, as well as in the result_Java_JMX.txt file in a convenient format for importing into Excel

## 2. Как использовать
1. Установите [**Beanshooter**](https://github.com/qtc-de/beanshooter) из официального репозитория. Используйте инструкцию
2. Перед запуском скрипта поднимите сервер, который будет использоваться для загрузки MBean-класса. ```./beanshooter.jar stager <IP> <Port> tonka```
3. Измените значения переменных Stager_* на IP и Port вашего поднятого сервера
4. Добавьте список хостов для сканирования в файл **hosts.txt**. IP и Port могут быть разделены любым символом
5. Измените переменную Beanshooter на название и путь до вашего jar-файла. У меня все лежит в одной директории, поэтому я использую ./beanshooter
6. Измените переменные user_file и password_file на путь до файлов с логинами и паролями для легкого брутфорса. Или скачайте эти файлы отсюда и поместите в директорию с bash-файлом.
7. Результат будет выведен в терминал, а также в файл result_Java_JMX.txt в удобном формате для импорта в эксель

