all: bootcd.iso

bootcd.iso: boot/boot.img ../begin64.bin
#删除旧的镜像
	@rm -f bootcd.iso
	@dd if=../begin64.bin of=boot/boot.img seek=1 bs=512 conv=notrunc
#创建启动镜像，输入文件为当前目录下所有文件
	@mkisofs -r -b boot/boot.img -c boot/boot.catalog -o bootcd.iso .

#ISO9660规范明确开始32KB是不用的，可以把系统初始化代码放到这里来，省去了读一大堆#ISO9660 英文规范的麻烦,(MLGB的，四级还没过)
#if为输入文件,notrunc的意思是不截断输出文件
#@dd if=../begin64.bin of=bootcd.iso conv=notrunc
