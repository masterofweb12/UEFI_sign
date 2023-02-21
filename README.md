# Ubuntu 22.04 исполнение только подписанного кода


## Зададимся задачей исполнять на целевой системе только подписаный ( доверенный ) код.

Во исполнение этой задачи нам необходим обеспечить следующее:
1) безопасную загрузку доверенного подписанного кода ядра Linux
2) загрузку исключительно подписанных драйверов ( модулей ядра Linux )
3) доверенную инициализацию пользовательского пространства ( процесс init )
4) исполнение только подписанных бинарных файлов

### Безопасная загрузка доверенного подписанного кода ядра Linux

 Если *ядро Linux* скомпилировано с параметром *CONFIG_EFI_STUB* ( а в ubuntu это именно так ), то оно поддерживает загрузку напрямую из *UEFI*.
Таким образом мы можем перенести *ядро* в *ESP* ( *EFI System Partition* ) располженный обычно в */boot/efi*, настроить UEFI таким образом, чтоб *ядро* грузилось напрямую, и всё должно работать.
 Однако это не будет полноценным решением, потому как *ядру* надо передать в качестве параметра образ *initramfs*, целостность которого мы никоим образом не можем проверить, что влечёт за собой возможность подмены образа *initramfs* с последующей компроментацией всей системы.
 Во избежание изложенного выше мы должны объединить *ядро* и образ *initramfs* в единый испонимый файл и запускать напрямую его. К счастью такая возможность существует. 
 
 Прежде чем подписывать код ядра, мы должны сгенерировать ключи, которыми мы будем подписывать ядро и всё остальное. Для этого нам понадобится скрипт
 [UEFI/MOK_KEYS/make_keys.sh](/UEFI/MOK_KEYS/make_keys.sh).

 Этот скрипт запросит имя ключа ( оно же будет выступать в качестве Common Name сертификата ).
Запустим скрипт и для примера назовём наш ключ **masterkey**. Скрипт сгенерирует следующие файлы и каталоги:  
keys  
masterkey.GUID.txt  
masterkey.cer  
masterkey.cer.siglist  
masterkey.crt  
masterkey.key

 В файлах *masterkey.crt* и *masterkey.key* содержатся сертификат и его приватный ключ. В файле *masterkey.cer* тот же сертификат в формате *DER*.
Также скрипт генерирует произвольный *UUID* и сохраняет его в файл *masterkey.GUID.txt*.
 На основе файлов *masterkey.GUID.txt* и *masterkey.cer* генерируется *siglist*.  
**siglist** является специальным видом файла экспорт которого возможен в энергонезависимую памят *UEFI*.  
В каталоге *keys* будут созданы следующие подкаталоги:  
PK  
KEK  
db  
dbx  
Назначение этих подкаталогов следующее:  
**Platform Key (PK)** — публичный ключ владельца платформы. Подписи соответствующим приватным ключом необходимы для смены PK или изменения KEK, db и dbx (описаны далее). Хранилище PK должно быть защищено от вмешательства и удаления.  
**Key Exchange Key (KEK)** — публичные ключи операционных систем. Подписи соответствующими приватными ключами необходимы для изменения баз данных подписей (db, dbx, описаны далее). Хранилище KEK должно быть защищено от вмешательства.  
**Базы данных подписей (db, dbx)** — Базы данных подписей и хешей доверенных приложений (db) и недоверенных приложений (dbx).  

В нашем случае мы имеем самоподписанный сертификат, потому мы можем записать наш открытый ключ и в *PK*, и в *KEK* и в *db*.
Для этого нам нужно зайти в UEFI полностю очистить его от ключей, которые там содержатся и перевести **Secure Boot** в режим **Setup Mode**.  
После этого нужно вызвать скрипт  [UEFI/MOK_KEYS/save_keys.sh](/UEFI/MOK_KEYS/save_keys.sh), который запишет данные ключи ( по сути наш один самоподписанный ключ ) в энергонезависимую память UEFI.  

Теперь мы можем подписать ядро и пергрузившись включить **Secure Boot**.  
Для начала объединим *ядро* и  *initramfs*.  
Сначала подпишем *ядро*. Для этого запустим скрипт [UEFI/MOK_KEYS/sign.sh](/UEFI/MOK_KEYS/sign.sh) передав ему в качестве параметра путь к подписываему ядру. Скрипт запросит имя ключа, в нашем случае мы введём *masterkey* и *ядро* будет успешно подписано. результатом подписи будет файл с именем ИМЯ_ЯДРА-signed. Скопируем этот файл на место оригинального *ядра* и удалим его ( например так *ИМЯ_ЯДРА-signed* > *ИМЯ_ЯДРА* ).  
Теперь можем приступать к объединению *ядра* и *initramfs*. Для этого зайдём в каталог [/UEFI/MAKE_UEFI](/UEFI/MAKE_UEFI)  запустим скрипт [/UEFI/MAKE_UEFI/make_uefi_exe.sh](/UEFI/MAKE_UEFI/make_uefi_exe.sh). Предварительно в этом скрипте нужно поправить переменную *EFIFOLDER* введя в качестве её значения имя каталога, куда будут помещаться готовые объединённые с *initramfs* *ядра*. После отработки скрипта в означенном выше каталоге заданном переменной *EFIFOLDER* появится файл *vmlinuz*, который и будет нужным нам ядром. Вернёмся в [UEFI/MOK_KEYS](/UEFI/MOK_KEYS) и подпишем его при помощи [UEFI/MOK_KEYS/sign.sh](/UEFI/MOK_KEYS/sign.sh).  

Теперь можем перегружаться и переводит **Secure Boot** в режим максимальной защиты.







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
