; demo.asm
;
;

; 建立一个 1.44MB 的 floopy 映像文件，名为demo.img
;
; 生成命令：nasm demo.asm -o demo.img

;
; 用0填满 1.44MB floppy 的空间
times 0x168000-($-$$) db 0
