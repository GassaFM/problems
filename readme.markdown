Примеры задач формата coder-channel-decoder: forgetful-robot и galactic-comm.

Данные преобразуются так:

~~~~
input (solution) encoded (channel) refined (solution) output
~~~~

Запуск в таком формате (решение пускается с файлами или без, неважно, но для примера без файлов):

~~~~
solution <input >encoded
channel <encoded input refined answer log
solution <refined >output
checker input output answer log
~~~~

То есть `channel` читает участника из `stdin`, а выводит во второй аргумент, совсем как интерактор.
На `testlib.h`, пока нет поддержки, видимо, надо будет делать `registerInteraction` в `channel`.

В задаче forgetful-robot есть `tech-test`: примеры решений, которые должны получать различные вердикты на разных фазах запуска.
