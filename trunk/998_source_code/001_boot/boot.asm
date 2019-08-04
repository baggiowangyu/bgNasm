; boot.asm
; Copyright (C) 2019-2020 wangy
; All rights reserved.

;
; 编译命令为：
;    软盘启动：nasm.exe boot.asm -o boot
;    U盘启动：nasm.exe boot.asm -o boot -d UBOOT
; 生成 boot 模块后，写入 demo.img (磁盘映像)的第0扇区（MBR）
;

%include "..\000_inc\support.inc"
%include "..\000_inc\ports.inc"

    ; 定义此程序为 16位-实模式 程序
    bits 16

;----------------------------------------------------------------
; 现在，处理器是处于实模式（real mode）
;----------------------------------------------------------------

    ; Int 19h 加载 sector 0 (MBR) 进入 BOOT_SEG 段，BOOT_SEG 定义为 0x7c00
    org BOOT_SEG

start:
    cli

    ; enable a20 line
    FAST_A20_ENABLE
    sti

    ; set BOOT_SEG environment
    mov ax, cs
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov sp, BOOT_SEG  ; 栈底设置为 BOOT_SEG

    call clear_screen
    mov si, hello
    call print_message

    mov si, 20  ; setup 模块在第20号扇区内
    mov di, SETUP_SEG - 2
    call load_module  ; 使用 load_module() 函数读取多个扇区

    mov si, SETUP_SEG
    call print_message

    mov si, word [load_message_table + eax * 2]
    call print_message

next:
    jmp $

;----------------------------------------------------------------
; clear_screen()
; 描述：
;    清理屏幕 & 将光标位置设置为(0,0)
;----------------------------------------------------------------
clear_screen:
    pusha
    mov ax, 0x6000
    xor cx, cx
    xor bh, 0x0f  ; white
    mov dh, 24
    mov dl, 79
    int 0x10

set_cursor_position:
