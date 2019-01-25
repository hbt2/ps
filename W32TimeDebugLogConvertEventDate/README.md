## Контекст
Журнал отладки службы времени Windows (W32Time) → Записи событий → Преобразование даты записей в читаемый вид.

## Проблема

Дата в журнале отлидки службы **W32Time** хранится в виде числа, обозначающего количество дней, 
прошедших с "начала эпохи" — 01.01.1601 (*"windows epoch time"*). 
Такое представление даты неудобно для чтения журнала.

Пример:

```
152384 06:28:50.9218750s - ---------- Log File Opened -----------------  
152384 06:28:50.9218750s - Entered W32TmServiceMain W2K3SP1  
152384 06:28:50.9218750s - CurSpc:15625000ns  BaseSpc:15625000ns  SyncToCmos:Yes  
```

## Решение

Для преобразования даты в читаемый вид:

1. Скопируйте файл журнала отладки службы W32Time в папку `Log`. Файл должен называться `W32Time.log`.

2. Запустите convert.bat. Результаты выполнения будут сохранены в следующие файлы:
   - `.\Log\W32Time.out.log`
   - `.\Log\W32Time.out.localclockoffset.log`

Во второй выходной файл сохраняются только строки (события), содержащие подстроку `LocalClockOffset`.

Предположительно, *LocalClockOffset* указывает обнаруженный службой *W32Time* 
сдвиг времени между локальной системой и сервером времени. Такое обнаружение 
происходит во время выполнения синхронизации, выполняемой с определённым 
интервалом (15-20 минут).