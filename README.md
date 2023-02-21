# Ubuntu 22.04 исполнение только подписанного кода


## Зададимся задачей исполнять на целевой системе только подписаный ( доверенный ) код.

Во исполнение этой задачи нам необходим обеспечить следующее:
1) безопасную загрузку доверенного подписанного кода ядра Linux
2) загрузку исключительно подписанных драйверов ( модулей ядра Linux )
3) доверенную инициализацию пользовательского пространства ( процесс init )
4) исполнение только подписанных бинарных файлов

### безопасная загрузка доверенного подписанного кода ядра Linux




Для того, чтоб отработали строки ниже с вызовами keyctl,
необходимо сделать следующую штуку - объеденить сессионную 
и пользовательскую цепочку ключей.
`
keyctl link @us @s
`


Далее можем создавать ключи
`
EVM encrypted key is used for EVM HMAC calculation:

    # create and save the key kernel master key (user type)
    # LMK is used to encrypt encrypted keys
    keyctl add user kmk "`dd if=/dev/urandom bs=1 count=32 2>/dev/null`" @u
    keyctl pipe `keyctl search @u user kmk` > /etc/keys/kmk

    # create the EVM encrypted key
    keyctl add encrypted evm-key "new user:kmk 64" @u
    keyctl pipe `keyctl search @u encrypted evm-key` >/etc/keys/evm-key
`
