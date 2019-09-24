---
title: "clangのデバッグ情報に行番号をのせる"
date: 2019-08-22
tags:
- cpplang
- tech
---

`clang`でAddressSanitizerとか使うと`-g`オプションなどをつけても行番号や関数名などの情報が出てこなくて困っていた。

```console
=================================================================
==32466==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 25000000 byte(s) in 1 object(s) allocated from:
    #0 0x557d7cdee698  (/home/kotet/Documents/c-parallel-mandel/serial+0x105698)
    #1 0x557d7ce237b8  (/home/kotet/Documents/c-parallel-mandel/serial+0x13a7b8)
    #2 0x7f81bcdddee2  (/usr/lib/libc.so.6+0x26ee2)

SUMMARY: AddressSanitizer: 25000000 byte(s) leaked in 1 allocation(s).
```

### llvm-symbolizer

`llvm-symbolizer`というのが必要だったらしい。
Arch Linuxの場合は
[llvm](https://www.archlinux.org/packages/extra/x86_64/llvm/)
パッケージを入れると一緒にインストールされる。

```console
=================================================================
==797==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 25000000 byte(s) in 1 object(s) allocated from:
    #0 0x5590056c5698 in calloc (/home/kotet/Documents/c-parallel-mandel/serial+0x105698)
    #1 0x5590056fa7b8 in main /home/kotet/Documents/c-parallel-mandel/main.c:18:20
    #2 0x7f92d8211ee2 in __libc_start_main (/usr/lib/libc.so.6+0x26ee2)

SUMMARY: AddressSanitizer: 25000000 byte(s) leaked in 1 allocation(s).
```
