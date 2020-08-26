# sbash (Snoopy Bash)

[Snoopy Logger](https://github.com/a2o/snoopy)
を使って、
特定のユーザがログイン(su, sudo含む)した場合に
コマンドラインを記録するシェル。
シェルスクリプトで記述されている。

ログインシェルをbashからこれに変更して使う。

いちおうRHEL,Cent OS用
(Debian, Ubuntu用にするには1行変えるだけ)。


# もくじ

- [sbash (Snoopy Bash)](#sbash-snoopy-bash)
- [もくじ](#もくじ)
- [インストール](#インストール)
- [テスト](#テスト)
- [既存ユーザへの適用](#既存ユーザへの適用)
- [よくある質問](#よくある質問)
  - [`pwd`などが記録されない](#pwdなどが記録されない)
- [メモ](#メモ)
  - [/usr/local/bin/sbashの中身](#usrlocalbinsbashの中身)
  - [snoopy logのサンプル](#snoopy-logのサンプル)
  - [snoopy-loggerのインストール](#snoopy-loggerのインストール)
- [TODO](#todo)


# インストール

以下を実行してインストール
```sh
sudo sh ./install.sh
```

事前に
`sudo snoopy-disable ; sudo reboot`
で
グローバルワイドなロギングを停止しておくとよい。


# テスト

まずテストユーザを作成する(仮に`user001`とする)。

```sh
sudo useradd -s /usr/local/bin/sbash user001
sudo passwd user001
```
(Debian, Ubuntuの場合さらにuser001のhome dirを作ってパーミッションを設定すること)


そして
```sh
su - user001
# または
sudo -iu user001
```

で、テストユーザになり、コマンドを叩いて、
`/var/log/secure`(RHEL,Cent OSの場合)に
snoopy logが記録されることを確認する。

```sh
sudo -iu user001 ls -la
sudo -iu user001 ps axf
```
なども試す。


おわったら
```sh
sudo userdel user001
```
でテストユーザを削除しておく。


# 既存ユーザへの適用

例えばrootに適用する場合
```
sudo usermod -s /usr/local/bin/sbash root
```
(再起動不要)


# よくある質問

## `pwd`などが記録されない

[Snoopy Logger](https://github.com/a2o/snoopy)は
[execve(2) - Linux manual page](https://man7.org/linux/man-pages/man2/execve.2.html)を
フックするものなので、
`bash -c help`で表示される、bashの内部コマンドは記録されません。


# メモ

## /usr/local/bin/sbashの中身

```sh
#!/usr/bin/bash
/bin/tty -s
if [ $? -eq 0 ]; then
  export LD_PRELOAD=/usr/lib64/libsnoopy.so
  # Debian, Ubuntuの場合
  # export LD_PRELOAD=/lib/x86_64-linux-gnu/libsnoopy.so
fi
exec /usr/bin/bash "$@"
```

見ての通り大したことはしてない。

## snoopy logのサンプル

/var/log/secureの一部
```
Aug 26 04:55:38 r7 snoopy[22921]: [uid:1001 sid:10741 tty:/dev/pts/4 cwd:/home/user1 filename:/bin/ls]: ls --color=auto -la
Aug 26 04:55:40 r7 snoopy[22922]: [uid:1001 sid:10741 tty:/dev/pts/4 cwd:/home/user1 filename:/bin/date]: date
```

## snoopy-loggerのインストール

Debian, Ubuntuの場合
```
apt install snoopy
```

RHEL, Cent OSの場合は、
どこかから
`snoopy-2.4.6-1.el7.x86_64.rpm`
を見つけてインストールする。昔はEPELにあった。
[a2o/snoopy: Log every executed command to syslog (a.k.a. Snoopy Logger).](https://github.com/a2o/snoopy)の手順を実行してもインストールできない(a2o.siが死んでるらしい)。contributeされた.specもなんだか怪しくて、rpmbuildできない(頑張る)。


# TODO

Cで書き直すかもしれない。
