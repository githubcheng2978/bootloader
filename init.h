/*
 *   Copyright 2012 by dragon 
 *   bolg:	http://blog.csdn.net/xidomlove
 *   mail:	fufulove2012@gmail.com
 *   File:      init.h
 *   Date:      2012年10月03日 星期三 11时49分44秒
 */

#ifndef INIT_H
#define INIT_H

typedef unsigned int   u32int;
typedef          int   s32int;
typedef unsigned short u16int;
typedef          short s16int;
typedef unsigned char  u8int;
typedef          char  s8int;

#define GDT_BEGIN 0x100000

#define GDT_LEN	0X10000

#define IDT_BEGIN 0X110000

#define IDT_LEN 0x800
//gdt描述符项定义，packed属性指定1字节对齐
struct gdt_entry
{
	u16int limit_low;           // The lower 16 bits of the limit.
	u16int base_low;            // The lower 16 bits of the base.
	u8int  base_middle;         // The next 8 bits of the base.
	u8int  access;              // Access flags, determine what ring this segment can be used in.
	u8int  granularity;
	u8int  base_high;           // The last 8 bits of the base.
} __attribute__((packed));

struct gdt_ptr
{
	u16int limit;               //gdt表长度
	u32int base;                //gdt表偏移地址
} __attribute__((packed));

#endif
