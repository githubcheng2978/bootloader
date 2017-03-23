#   Copyright 2012 by dragon 
#   bolg:	http://blog.csdn.net/xidomlove
#   mail:	fufulove2012@gmail.com
#   File:      boot.S
#   Date:      2012年10月01日 星期一 16时11分37秒
#实模式下0-1M可用内存为500-9fc00，其中7c00-7dff为bios自动帮加载的引导程序！！！
#ISO9660规范说明了0-32K字节是保留不用的，既然不用那就给我来放操作系统初始化代码了哦。

.code16

#符号常量
#define READBEGIN $0x7e00


.text
.globl _start
_start:
#movw	%cs,%ax
#movw	%ax,%ds
#movw    %ax,%es
jmp	init_cursor
#调用bios中断清楚屏幕
clear_screeen:
movw	$0x0600,%ax
movw	$0x0700,%bx
movw	$0,%cx
mov	$0x0ffff,%dx
int	$0x10
#初始化光标位置
init_cursor:
movw	$0x0200,%ax
movw	$0x0000,%bx
movw	$0x0000,%dx
int	$0x10

movw	$BootMessage,%bx
#subw	$0x7c00,%bx
movw	%bx,StrAddr
movw    $51,%cx
#movw	$0x0000,%dx
call    PRINT_STR

#mov	$0x0000,%ax  #wating for user input
#int	$0x16

movw	$BootMessage2,%bx
#subw	$0x7c00,%bx
movw	%bx,StrAddr
movw    $14,%cx
#movw	$0x0100,%dx
call    PRINT_STR
#mov	$0x0000,%bx
#mov	$0x0000,%dx
#mov 	$0x02,%ah
#int	$0x10
#mov	$0x0000,%ax #wating for user input
#int	$0x16

/*
# read disk infomation
mov	$0x0100,%ax
mov	$0x0080,%dx
int	$0x13

#show %al
#movb	$0,%bh
#movb	$0x0a,%ah
#movb	$0x0001,%cx
#addb	$0x30,%al
#int	$0x10
#cmp	$0x30,%al

cmp	$0x00,%al
jz	READSUCCESS
#movb	%al,%cl
#and	$0xf0,%cl
#cmp	
#sal	$0x04,%al
lea	ReadDiskMsgF,%bx
movw	%bx,StrAddr
movw    $17,%cx
#movw	$0x0300,%dx
call    PRINT_STR
jmp	HDSTATUS

READSUCCESS:
lea	ReadDiskMsgS,%bx
movw	%bx,StrAddr
movw    $19,%cx
#movw	$0x0300,%dx
call    PRINT_STR

#读取硬盘状态,0号硬盘状态寄存器为1F7
HDSTATUS:
mov	$0x01f7,%dx
inb	%dx,%al
test	$0x40,%al	#测试第七位是否为1
jnz	HDREADY

lea	HDNotReadyMsg,%bx
movw	%bx,StrAddr
movw	$26,%cx
#movw	$0x0400,%dx

jmp	SHOW_HD_STATUS

HDREADY:
lea	HDReadyMsg,%bx
movw	%bx,StrAddr
movw	$23,%cx
#movw	$0x0400,%dx

SHOW_HD_STATUS:
call	PRINT_STR

#READ_MEMORY:#获取内存大小
#int	$0x12
 */
#获取第一控制器主通道主盘参数
#movb	$0x08,%ah
#movb	$0x80,%dl
#int	$0x13

#读取扇区代码到0x7e00处
read_loader:
#movw	$0x2000,%ax
#movw	%ax,%es
movb	$0x02,%ah
movb	$2,%al		#扇区数
movw	$0x0002,%cx	#扇区号是从1开始！！，低六位表示扇区开始，高10位是盘面
movb	$0x00,%dl	#设备号，0是软盘，80是磁盘，光盘需要扫描
movb	$0,%dh
movw	$0x7e00,%bx
int	$0x13
jc	END

#初始化进入保护模式需要的数据
#段基地址应该对齐16字节边界以获得最佳性能
cli	#关中断
lgdt	gdtr
lidt	idtr
movw	$0x0001,%ax
lmsw	%ax

ljmp	$0x8,$0x0	#跳转到加载代码的地方，保护模式下执行该指令后CS就是段选择子，第二位操作数为IP指针，即段内偏移，通过查找gdt或者ldt加上IP得到线性地址，如果没有开启分页机制则直接是物理地址。

END:
#关机，
mov	$0x0000,%ax #wating for user input
int	$0x16
movw	$0x5307,%ax
movw	$0x0001,%bx #设备号居然是1
movw	$0x0003,%cx
int	$0x15
jmp     .
PRINT_STR:	#display a string,and StrAddr is the address,%cx is the length of the string
pushw	 %cx

#将字符串显示位置加一行
movb	 $0x00,%bh
mov	 $0x0300,%ax
int	 $0x10
incb	 %dh

movb	 $0x00,%dl
movw     StrAddr,%bp
movw     $0x1301,%ax
movw	 $0x000c,%bx
popw	 %cx
int      $0x10
#int 	 $3	#中断，调试
ret


BootMessage:.ascii "copyright(c) fufuos 2012.press any key to continue..."
BootMessage2:.ascii "I'm gan you fu"
ReadDiskMsgS:.ascii "read disk successe!"
ReadDiskMsgF:.ascii "read disk failed!"
HDReadyMsg:.ascii "the hard disk is ready!"
HDNotReadyMsg:.ascii "the hard disk is not found"

#diskinfo:.ascii""
#StrTable:.ascii "0123456789ABCDEF"
StrAddr:.short 0x0000
#.org 1474560
#全局段描述符号表
gdt:
.int 0,0	#第一项不用

#num2.内核代码段，线性基地址0x7e00,段长150*4K,(7e00-9de00)，可读执行,选择子0x08
.int 0x7e000096
.int 0x00c09a00
#num3.内核数据段,线性基地址0x100000(1M),段长256*4K（1M）,可读写,(0-64K,gdt)(64-66k,idt,系统最多有256个中断描述符，所以长度最大为256*8=2048)，选择子0x10
.int 0x00000100
.int 0x00c09210
#num4.内核堆栈段（SS），线性基地址0x100800,段长256*4K，可读写，选择子0x18
.int 0x08000100
.int 0x00c09220

#gdt寄存器，低16位是段界限长，高32位是gdt表的偏移地址
gdtr:
.word 0x0100
.word gdt
.word 0

idtr: .word 0,0,0
.org 510
.word 0xaa55
