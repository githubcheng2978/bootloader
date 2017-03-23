#   Copyright 2012 by dragon 
#   bolg:	http://blog.csdn.net/xidomlove
#   mail:	fufulove2012@gmail.com
#   File:      begin64.S
#   Date:      2012年10月01日 星期一 17时36分39秒

#loader程序，进入保护模式,保护模式下已经不能使用bios中断！

#.code16

.text
#初始化数据段。堆栈段

movw $0x10,%ax
movw %ax,%ds

movw $0x18,%ax
movw %ax,%ss

jmp .

