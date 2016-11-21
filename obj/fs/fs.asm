
obj/fs/fs:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 1f 19 00 00       	call   801950 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
		return -1;
	return 0;
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800085:	eb 0b                	jmp    800092 <ide_probe_disk1+0x33>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800087:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008a:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800090:	74 05                	je     800097 <ide_probe_disk1+0x38>
  800092:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800093:	a8 a1                	test   $0xa1,%al
  800095:	75 f0                	jne    800087 <ide_probe_disk1+0x28>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800097:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009c:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  8000a1:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a2:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a8:	0f 9e c3             	setle  %bl
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	0f b6 c3             	movzbl %bl,%eax
  8000b1:	50                   	push   %eax
  8000b2:	68 60 37 80 00       	push   $0x803760
  8000b7:	e8 cd 19 00 00       	call   801a89 <cprintf>
	return (x < 1000);
}
  8000bc:	89 d8                	mov    %ebx,%eax
  8000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	83 ec 08             	sub    $0x8,%esp
  8000c9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000cc:	83 f8 01             	cmp    $0x1,%eax
  8000cf:	76 14                	jbe    8000e5 <ide_set_disk+0x22>
		panic("bad disk number");
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	68 77 37 80 00       	push   $0x803777
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 87 37 80 00       	push   $0x803787
  8000e0:	e8 cb 18 00 00       	call   8019b0 <_panic>
	diskno = d;
  8000e5:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fe:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800104:	76 16                	jbe    80011c <ide_read+0x30>
  800106:	68 90 37 80 00       	push   $0x803790
  80010b:	68 9d 37 80 00       	push   $0x80379d
  800110:	6a 44                	push   $0x44
  800112:	68 87 37 80 00       	push   $0x803787
  800117:	e8 94 18 00 00       	call   8019b0 <_panic>

	ide_wait_ready(0);
  80011c:	b8 00 00 00 00       	mov    $0x0,%eax
  800121:	e8 0d ff ff ff       	call   800033 <ide_wait_ready>
  800126:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80012b:	89 f0                	mov    %esi,%eax
  80012d:	ee                   	out    %al,(%dx)
  80012e:	ba f3 01 00 00       	mov    $0x1f3,%edx
  800133:	89 f8                	mov    %edi,%eax
  800135:	ee                   	out    %al,(%dx)
  800136:	89 f8                	mov    %edi,%eax
  800138:	c1 e8 08             	shr    $0x8,%eax
  80013b:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800140:	ee                   	out    %al,(%dx)
  800141:	89 f8                	mov    %edi,%eax
  800143:	c1 e8 10             	shr    $0x10,%eax
  800146:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80014b:	ee                   	out    %al,(%dx)
  80014c:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800153:	83 e0 01             	and    $0x1,%eax
  800156:	c1 e0 04             	shl    $0x4,%eax
  800159:	83 c8 e0             	or     $0xffffffe0,%eax
  80015c:	c1 ef 18             	shr    $0x18,%edi
  80015f:	83 e7 0f             	and    $0xf,%edi
  800162:	09 f8                	or     %edi,%eax
  800164:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800169:	ee                   	out    %al,(%dx)
  80016a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80016f:	b8 20 00 00 00       	mov    $0x20,%eax
  800174:	ee                   	out    %al,(%dx)
  800175:	c1 e6 09             	shl    $0x9,%esi
  800178:	01 de                	add    %ebx,%esi
  80017a:	eb 23                	jmp    80019f <ide_read+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80017c:	b8 01 00 00 00       	mov    $0x1,%eax
  800181:	e8 ad fe ff ff       	call   800033 <ide_wait_ready>
  800186:	85 c0                	test   %eax,%eax
  800188:	78 1e                	js     8001a8 <ide_read+0xbc>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  80018a:	89 df                	mov    %ebx,%edi
  80018c:	b9 80 00 00 00       	mov    $0x80,%ecx
  800191:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800196:	fc                   	cld    
  800197:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800199:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80019f:	39 f3                	cmp    %esi,%ebx
  8001a1:	75 d9                	jne    80017c <ide_read+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001bf:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c2:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001c8:	76 16                	jbe    8001e0 <ide_write+0x30>
  8001ca:	68 90 37 80 00       	push   $0x803790
  8001cf:	68 9d 37 80 00       	push   $0x80379d
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 87 37 80 00       	push   $0x803787
  8001db:	e8 d0 17 00 00       	call   8019b0 <_panic>

	ide_wait_ready(0);
  8001e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e5:	e8 49 fe ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ea:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001ef:	89 f8                	mov    %edi,%eax
  8001f1:	ee                   	out    %al,(%dx)
  8001f2:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001f7:	89 f0                	mov    %esi,%eax
  8001f9:	ee                   	out    %al,(%dx)
  8001fa:	89 f0                	mov    %esi,%eax
  8001fc:	c1 e8 08             	shr    $0x8,%eax
  8001ff:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800204:	ee                   	out    %al,(%dx)
  800205:	89 f0                	mov    %esi,%eax
  800207:	c1 e8 10             	shr    $0x10,%eax
  80020a:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80020f:	ee                   	out    %al,(%dx)
  800210:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800217:	83 e0 01             	and    $0x1,%eax
  80021a:	c1 e0 04             	shl    $0x4,%eax
  80021d:	83 c8 e0             	or     $0xffffffe0,%eax
  800220:	c1 ee 18             	shr    $0x18,%esi
  800223:	83 e6 0f             	and    $0xf,%esi
  800226:	09 f0                	or     %esi,%eax
  800228:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80022d:	ee                   	out    %al,(%dx)
  80022e:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800233:	b8 30 00 00 00       	mov    $0x30,%eax
  800238:	ee                   	out    %al,(%dx)
  800239:	c1 e7 09             	shl    $0x9,%edi
  80023c:	01 df                	add    %ebx,%edi
  80023e:	eb 23                	jmp    800263 <ide_write+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800240:	b8 01 00 00 00       	mov    $0x1,%eax
  800245:	e8 e9 fd ff ff       	call   800033 <ide_wait_ready>
  80024a:	85 c0                	test   %eax,%eax
  80024c:	78 1e                	js     80026c <ide_write+0xbc>
}

static __inline void
outsl(int port, const void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\toutsl"		:
  80024e:	89 de                	mov    %ebx,%esi
  800250:	b9 80 00 00 00       	mov    $0x80,%ecx
  800255:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80025a:	fc                   	cld    
  80025b:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80025d:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800263:	39 fb                	cmp    %edi,%ebx
  800265:	75 d9                	jne    800240 <ide_write+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  80027c:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  80027e:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800284:	89 c6                	mov    %eax,%esi
  800286:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800289:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80028e:	76 1b                	jbe    8002ab <bc_pgfault+0x37>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	ff 72 04             	pushl  0x4(%edx)
  800296:	53                   	push   %ebx
  800297:	ff 72 28             	pushl  0x28(%edx)
  80029a:	68 b4 37 80 00       	push   $0x8037b4
  80029f:	6a 27                	push   $0x27
  8002a1:	68 70 38 80 00       	push   $0x803870
  8002a6:	e8 05 17 00 00       	call   8019b0 <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002ab:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8002b0:	85 c0                	test   %eax,%eax
  8002b2:	74 17                	je     8002cb <bc_pgfault+0x57>
  8002b4:	3b 70 04             	cmp    0x4(%eax),%esi
  8002b7:	72 12                	jb     8002cb <bc_pgfault+0x57>
		panic("reading non-existent block %08x\n", blockno);
  8002b9:	56                   	push   %esi
  8002ba:	68 e4 37 80 00       	push   $0x8037e4
  8002bf:	6a 2b                	push   $0x2b
  8002c1:	68 70 38 80 00       	push   $0x803870
  8002c6:	e8 e5 16 00 00       	call   8019b0 <_panic>
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:

			addr = (void*) ROUNDDOWN(addr, PGSIZE);
  8002cb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	
	if((r = sys_page_alloc(0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  8002d1:	83 ec 04             	sub    $0x4,%esp
  8002d4:	6a 07                	push   $0x7
  8002d6:	53                   	push   %ebx
  8002d7:	6a 00                	push   $0x0
  8002d9:	e8 33 21 00 00       	call   802411 <sys_page_alloc>
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	79 14                	jns    8002f9 <bc_pgfault+0x85>
		panic("sys alloc failed");
  8002e5:	83 ec 04             	sub    $0x4,%esp
  8002e8:	68 78 38 80 00       	push   $0x803878
  8002ed:	6a 38                	push   $0x38
  8002ef:	68 70 38 80 00       	push   $0x803870
  8002f4:	e8 b7 16 00 00       	call   8019b0 <_panic>

	
	if ((r = ide_read(blockno*BLKSECTS, addr, BLKSECTS)) < 0)
  8002f9:	83 ec 04             	sub    $0x4,%esp
  8002fc:	6a 08                	push   $0x8
  8002fe:	53                   	push   %ebx
  8002ff:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  800306:	50                   	push   %eax
  800307:	e8 e0 fd ff ff       	call   8000ec <ide_read>
  80030c:	83 c4 10             	add    $0x10,%esp
  80030f:	85 c0                	test   %eax,%eax
  800311:	79 14                	jns    800327 <bc_pgfault+0xb3>
		panic("ide read failed");
  800313:	83 ec 04             	sub    $0x4,%esp
  800316:	68 89 38 80 00       	push   $0x803889
  80031b:	6a 3c                	push   $0x3c
  80031d:	68 70 38 80 00       	push   $0x803870
  800322:	e8 89 16 00 00       	call   8019b0 <_panic>
	

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800327:	89 d8                	mov    %ebx,%eax
  800329:	c1 e8 0c             	shr    $0xc,%eax
  80032c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800333:	83 ec 0c             	sub    $0xc,%esp
  800336:	25 07 0e 00 00       	and    $0xe07,%eax
  80033b:	50                   	push   %eax
  80033c:	53                   	push   %ebx
  80033d:	6a 00                	push   $0x0
  80033f:	53                   	push   %ebx
  800340:	6a 00                	push   $0x0
  800342:	e8 0d 21 00 00       	call   802454 <sys_page_map>
  800347:	83 c4 20             	add    $0x20,%esp
  80034a:	85 c0                	test   %eax,%eax
  80034c:	79 12                	jns    800360 <bc_pgfault+0xec>
		panic("in bc_pgfault, sys_page_map: %e", r);
  80034e:	50                   	push   %eax
  80034f:	68 08 38 80 00       	push   $0x803808
  800354:	6a 42                	push   $0x42
  800356:	68 70 38 80 00       	push   $0x803870
  80035b:	e8 50 16 00 00       	call   8019b0 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  800360:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  800367:	74 22                	je     80038b <bc_pgfault+0x117>
  800369:	83 ec 0c             	sub    $0xc,%esp
  80036c:	56                   	push   %esi
  80036d:	e8 5a 03 00 00       	call   8006cc <block_is_free>
  800372:	83 c4 10             	add    $0x10,%esp
  800375:	84 c0                	test   %al,%al
  800377:	74 12                	je     80038b <bc_pgfault+0x117>
		panic("reading free block %08x\n", blockno);
  800379:	56                   	push   %esi
  80037a:	68 99 38 80 00       	push   $0x803899
  80037f:	6a 48                	push   $0x48
  800381:	68 70 38 80 00       	push   $0x803870
  800386:	e8 25 16 00 00       	call   8019b0 <_panic>
}
  80038b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80038e:	5b                   	pop    %ebx
  80038f:	5e                   	pop    %esi
  800390:	5d                   	pop    %ebp
  800391:	c3                   	ret    

00800392 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  800392:	55                   	push   %ebp
  800393:	89 e5                	mov    %esp,%ebp
  800395:	83 ec 08             	sub    $0x8,%esp
  800398:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  80039b:	85 c0                	test   %eax,%eax
  80039d:	74 0f                	je     8003ae <diskaddr+0x1c>
  80039f:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8003a5:	85 d2                	test   %edx,%edx
  8003a7:	74 17                	je     8003c0 <diskaddr+0x2e>
  8003a9:	3b 42 04             	cmp    0x4(%edx),%eax
  8003ac:	72 12                	jb     8003c0 <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  8003ae:	50                   	push   %eax
  8003af:	68 28 38 80 00       	push   $0x803828
  8003b4:	6a 09                	push   $0x9
  8003b6:	68 70 38 80 00       	push   $0x803870
  8003bb:	e8 f0 15 00 00       	call   8019b0 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003c0:	05 00 00 01 00       	add    $0x10000,%eax
  8003c5:	c1 e0 0c             	shl    $0xc,%eax
}
  8003c8:	c9                   	leave  
  8003c9:	c3                   	ret    

008003ca <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003d0:	89 d0                	mov    %edx,%eax
  8003d2:	c1 e8 16             	shr    $0x16,%eax
  8003d5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e1:	f6 c1 01             	test   $0x1,%cl
  8003e4:	74 0d                	je     8003f3 <va_is_mapped+0x29>
  8003e6:	c1 ea 0c             	shr    $0xc,%edx
  8003e9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8003f0:	83 e0 01             	and    $0x1,%eax
  8003f3:	83 e0 01             	and    $0x1,%eax
}
  8003f6:	5d                   	pop    %ebp
  8003f7:	c3                   	ret    

008003f8 <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fe:	c1 e8 0c             	shr    $0xc,%eax
  800401:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800408:	c1 e8 06             	shr    $0x6,%eax
  80040b:	83 e0 01             	and    $0x1,%eax
}
  80040e:	5d                   	pop    %ebp
  80040f:	c3                   	ret    

00800410 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	56                   	push   %esi
  800414:	53                   	push   %ebx
  800415:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800418:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80041e:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800423:	76 12                	jbe    800437 <flush_block+0x27>
		panic("flush_block of bad va %08x", addr);
  800425:	53                   	push   %ebx
  800426:	68 b2 38 80 00       	push   $0x8038b2
  80042b:	6a 58                	push   $0x58
  80042d:	68 70 38 80 00       	push   $0x803870
  800432:	e8 79 15 00 00       	call   8019b0 <_panic>

	// LAB 5: Your code here.
	
	addr = (void*) ROUNDDOWN(addr, PGSIZE);
  800437:	89 de                	mov    %ebx,%esi
  800439:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi


	int r;
	if (va_is_mapped(addr) && va_is_dirty(addr)) {
  80043f:	83 ec 0c             	sub    $0xc,%esp
  800442:	56                   	push   %esi
  800443:	e8 82 ff ff ff       	call   8003ca <va_is_mapped>
  800448:	83 c4 10             	add    $0x10,%esp
  80044b:	84 c0                	test   %al,%al
  80044d:	74 7e                	je     8004cd <flush_block+0xbd>
  80044f:	83 ec 0c             	sub    $0xc,%esp
  800452:	56                   	push   %esi
  800453:	e8 a0 ff ff ff       	call   8003f8 <va_is_dirty>
  800458:	83 c4 10             	add    $0x10,%esp
  80045b:	84 c0                	test   %al,%al
  80045d:	74 6e                	je     8004cd <flush_block+0xbd>
		
		if ((r = ide_write(blockno*BLKSECTS, addr, BLKSECTS)) < 0)
  80045f:	83 ec 04             	sub    $0x4,%esp
  800462:	6a 08                	push   $0x8
  800464:	56                   	push   %esi
  800465:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
  80046b:	c1 eb 0c             	shr    $0xc,%ebx
  80046e:	c1 e3 03             	shl    $0x3,%ebx
  800471:	53                   	push   %ebx
  800472:	e8 39 fd ff ff       	call   8001b0 <ide_write>
  800477:	83 c4 10             	add    $0x10,%esp
  80047a:	85 c0                	test   %eax,%eax
  80047c:	79 14                	jns    800492 <flush_block+0x82>
			panic("ide wite failed");
  80047e:	83 ec 04             	sub    $0x4,%esp
  800481:	68 cd 38 80 00       	push   $0x8038cd
  800486:	6a 63                	push   $0x63
  800488:	68 70 38 80 00       	push   $0x803870
  80048d:	e8 1e 15 00 00       	call   8019b0 <_panic>
		
		if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800492:	89 f0                	mov    %esi,%eax
  800494:	c1 e8 0c             	shr    $0xc,%eax
  800497:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80049e:	83 ec 0c             	sub    $0xc,%esp
  8004a1:	25 07 0e 00 00       	and    $0xe07,%eax
  8004a6:	50                   	push   %eax
  8004a7:	56                   	push   %esi
  8004a8:	6a 00                	push   $0x0
  8004aa:	56                   	push   %esi
  8004ab:	6a 00                	push   $0x0
  8004ad:	e8 a2 1f 00 00       	call   802454 <sys_page_map>
  8004b2:	83 c4 20             	add    $0x20,%esp
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	79 14                	jns    8004cd <flush_block+0xbd>
			panic("sys page map failed");
  8004b9:	83 ec 04             	sub    $0x4,%esp
  8004bc:	68 dd 38 80 00       	push   $0x8038dd
  8004c1:	6a 66                	push   $0x66
  8004c3:	68 70 38 80 00       	push   $0x803870
  8004c8:	e8 e3 14 00 00       	call   8019b0 <_panic>
	}
}
  8004cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004d0:	5b                   	pop    %ebx
  8004d1:	5e                   	pop    %esi
  8004d2:	5d                   	pop    %ebp
  8004d3:	c3                   	ret    

008004d4 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
  8004d7:	81 ec 24 02 00 00    	sub    $0x224,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004dd:	68 74 02 80 00       	push   $0x800274
  8004e2:	e8 1b 21 00 00       	call   802602 <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8004e7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004ee:	e8 9f fe ff ff       	call   800392 <diskaddr>
  8004f3:	83 c4 0c             	add    $0xc,%esp
  8004f6:	68 08 01 00 00       	push   $0x108
  8004fb:	50                   	push   %eax
  8004fc:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  800502:	50                   	push   %eax
  800503:	e8 98 1c 00 00       	call   8021a0 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800508:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80050f:	e8 7e fe ff ff       	call   800392 <diskaddr>
  800514:	83 c4 08             	add    $0x8,%esp
  800517:	68 f1 38 80 00       	push   $0x8038f1
  80051c:	50                   	push   %eax
  80051d:	e8 ec 1a 00 00       	call   80200e <strcpy>
	flush_block(diskaddr(1));
  800522:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800529:	e8 64 fe ff ff       	call   800392 <diskaddr>
  80052e:	89 04 24             	mov    %eax,(%esp)
  800531:	e8 da fe ff ff       	call   800410 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800536:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80053d:	e8 50 fe ff ff       	call   800392 <diskaddr>
  800542:	89 04 24             	mov    %eax,(%esp)
  800545:	e8 80 fe ff ff       	call   8003ca <va_is_mapped>
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	84 c0                	test   %al,%al
  80054f:	75 16                	jne    800567 <bc_init+0x93>
  800551:	68 13 39 80 00       	push   $0x803913
  800556:	68 9d 37 80 00       	push   $0x80379d
  80055b:	6a 77                	push   $0x77
  80055d:	68 70 38 80 00       	push   $0x803870
  800562:	e8 49 14 00 00       	call   8019b0 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800567:	83 ec 0c             	sub    $0xc,%esp
  80056a:	6a 01                	push   $0x1
  80056c:	e8 21 fe ff ff       	call   800392 <diskaddr>
  800571:	89 04 24             	mov    %eax,(%esp)
  800574:	e8 7f fe ff ff       	call   8003f8 <va_is_dirty>
  800579:	83 c4 10             	add    $0x10,%esp
  80057c:	84 c0                	test   %al,%al
  80057e:	74 16                	je     800596 <bc_init+0xc2>
  800580:	68 f8 38 80 00       	push   $0x8038f8
  800585:	68 9d 37 80 00       	push   $0x80379d
  80058a:	6a 78                	push   $0x78
  80058c:	68 70 38 80 00       	push   $0x803870
  800591:	e8 1a 14 00 00       	call   8019b0 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800596:	83 ec 0c             	sub    $0xc,%esp
  800599:	6a 01                	push   $0x1
  80059b:	e8 f2 fd ff ff       	call   800392 <diskaddr>
  8005a0:	83 c4 08             	add    $0x8,%esp
  8005a3:	50                   	push   %eax
  8005a4:	6a 00                	push   $0x0
  8005a6:	e8 eb 1e 00 00       	call   802496 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8005ab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005b2:	e8 db fd ff ff       	call   800392 <diskaddr>
  8005b7:	89 04 24             	mov    %eax,(%esp)
  8005ba:	e8 0b fe ff ff       	call   8003ca <va_is_mapped>
  8005bf:	83 c4 10             	add    $0x10,%esp
  8005c2:	84 c0                	test   %al,%al
  8005c4:	74 16                	je     8005dc <bc_init+0x108>
  8005c6:	68 12 39 80 00       	push   $0x803912
  8005cb:	68 9d 37 80 00       	push   $0x80379d
  8005d0:	6a 7c                	push   $0x7c
  8005d2:	68 70 38 80 00       	push   $0x803870
  8005d7:	e8 d4 13 00 00       	call   8019b0 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005dc:	83 ec 0c             	sub    $0xc,%esp
  8005df:	6a 01                	push   $0x1
  8005e1:	e8 ac fd ff ff       	call   800392 <diskaddr>
  8005e6:	83 c4 08             	add    $0x8,%esp
  8005e9:	68 f1 38 80 00       	push   $0x8038f1
  8005ee:	50                   	push   %eax
  8005ef:	e8 c4 1a 00 00       	call   8020b8 <strcmp>
  8005f4:	83 c4 10             	add    $0x10,%esp
  8005f7:	85 c0                	test   %eax,%eax
  8005f9:	74 16                	je     800611 <bc_init+0x13d>
  8005fb:	68 4c 38 80 00       	push   $0x80384c
  800600:	68 9d 37 80 00       	push   $0x80379d
  800605:	6a 7f                	push   $0x7f
  800607:	68 70 38 80 00       	push   $0x803870
  80060c:	e8 9f 13 00 00       	call   8019b0 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800611:	83 ec 0c             	sub    $0xc,%esp
  800614:	6a 01                	push   $0x1
  800616:	e8 77 fd ff ff       	call   800392 <diskaddr>
  80061b:	83 c4 0c             	add    $0xc,%esp
  80061e:	68 08 01 00 00       	push   $0x108
  800623:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  800629:	52                   	push   %edx
  80062a:	50                   	push   %eax
  80062b:	e8 70 1b 00 00       	call   8021a0 <memmove>
	flush_block(diskaddr(1));
  800630:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800637:	e8 56 fd ff ff       	call   800392 <diskaddr>
  80063c:	89 04 24             	mov    %eax,(%esp)
  80063f:	e8 cc fd ff ff       	call   800410 <flush_block>

	cprintf("block cache is good\n");
  800644:	c7 04 24 2d 39 80 00 	movl   $0x80392d,(%esp)
  80064b:	e8 39 14 00 00       	call   801a89 <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  800650:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800657:	e8 36 fd ff ff       	call   800392 <diskaddr>
  80065c:	83 c4 0c             	add    $0xc,%esp
  80065f:	68 08 01 00 00       	push   $0x108
  800664:	50                   	push   %eax
  800665:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80066b:	50                   	push   %eax
  80066c:	e8 2f 1b 00 00       	call   8021a0 <memmove>
}
  800671:	83 c4 10             	add    $0x10,%esp
  800674:	c9                   	leave  
  800675:	c3                   	ret    

00800676 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  800676:	55                   	push   %ebp
  800677:	89 e5                	mov    %esp,%ebp
  800679:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  80067c:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800681:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800687:	74 14                	je     80069d <check_super+0x27>
		panic("bad file system magic number");
  800689:	83 ec 04             	sub    $0x4,%esp
  80068c:	68 42 39 80 00       	push   $0x803942
  800691:	6a 0f                	push   $0xf
  800693:	68 5f 39 80 00       	push   $0x80395f
  800698:	e8 13 13 00 00       	call   8019b0 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  80069d:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8006a4:	76 14                	jbe    8006ba <check_super+0x44>
		panic("file system is too large");
  8006a6:	83 ec 04             	sub    $0x4,%esp
  8006a9:	68 67 39 80 00       	push   $0x803967
  8006ae:	6a 12                	push   $0x12
  8006b0:	68 5f 39 80 00       	push   $0x80395f
  8006b5:	e8 f6 12 00 00       	call   8019b0 <_panic>

	cprintf("superblock is good\n");
  8006ba:	83 ec 0c             	sub    $0xc,%esp
  8006bd:	68 80 39 80 00       	push   $0x803980
  8006c2:	e8 c2 13 00 00       	call   801a89 <cprintf>
}
  8006c7:	83 c4 10             	add    $0x10,%esp
  8006ca:	c9                   	leave  
  8006cb:	c3                   	ret    

008006cc <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  8006cc:	55                   	push   %ebp
  8006cd:	89 e5                	mov    %esp,%ebp
  8006cf:	53                   	push   %ebx
  8006d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  8006d3:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8006d9:	85 d2                	test   %edx,%edx
  8006db:	74 24                	je     800701 <block_is_free+0x35>
		return 0;
  8006dd:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  8006e2:	39 4a 04             	cmp    %ecx,0x4(%edx)
  8006e5:	76 1f                	jbe    800706 <block_is_free+0x3a>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  8006e7:	89 cb                	mov    %ecx,%ebx
  8006e9:	c1 eb 05             	shr    $0x5,%ebx
  8006ec:	b8 01 00 00 00       	mov    $0x1,%eax
  8006f1:	d3 e0                	shl    %cl,%eax
  8006f3:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  8006f9:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  8006fc:	0f 95 c0             	setne  %al
  8006ff:	eb 05                	jmp    800706 <block_is_free+0x3a>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  800701:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  800706:	5b                   	pop    %ebx
  800707:	5d                   	pop    %ebp
  800708:	c3                   	ret    

00800709 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
  80070c:	53                   	push   %ebx
  80070d:	83 ec 04             	sub    $0x4,%esp
  800710:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  800713:	85 c9                	test   %ecx,%ecx
  800715:	75 14                	jne    80072b <free_block+0x22>
		panic("attempt to free zero block");
  800717:	83 ec 04             	sub    $0x4,%esp
  80071a:	68 94 39 80 00       	push   $0x803994
  80071f:	6a 2d                	push   $0x2d
  800721:	68 5f 39 80 00       	push   $0x80395f
  800726:	e8 85 12 00 00       	call   8019b0 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  80072b:	89 cb                	mov    %ecx,%ebx
  80072d:	c1 eb 05             	shr    $0x5,%ebx
  800730:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  800736:	b8 01 00 00 00       	mov    $0x1,%eax
  80073b:	d3 e0                	shl    %cl,%eax
  80073d:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  800740:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800743:	c9                   	leave  
  800744:	c3                   	ret    

00800745 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	56                   	push   %esi
  800749:	53                   	push   %ebx
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	if (!super)
  80074a:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80074f:	85 c0                	test   %eax,%eax
  800751:	74 0a                	je     80075d <alloc_block+0x18>
		panic("in alloc_block: super not initialized");

	
	int no;
	for (no = 1; no < super->s_nblocks; no++) {
  800753:	8b 70 04             	mov    0x4(%eax),%esi
  800756:	bb 01 00 00 00       	mov    $0x1,%ebx
  80075b:	eb 6c                	jmp    8007c9 <alloc_block+0x84>
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	if (!super)
		panic("in alloc_block: super not initialized");
  80075d:	83 ec 04             	sub    $0x4,%esp
  800760:	68 34 3a 80 00       	push   $0x803a34
  800765:	6a 42                	push   $0x42
  800767:	68 5f 39 80 00       	push   $0x80395f
  80076c:	e8 3f 12 00 00       	call   8019b0 <_panic>

	
	int no;
	for (no = 1; no < super->s_nblocks; no++) {
		// If find a free block, mark it used and flush the bitmap block
		if(block_is_free(no)) {
  800771:	83 ec 0c             	sub    $0xc,%esp
  800774:	53                   	push   %ebx
  800775:	e8 52 ff ff ff       	call   8006cc <block_is_free>
  80077a:	83 c4 10             	add    $0x10,%esp
  80077d:	84 c0                	test   %al,%al
  80077f:	74 45                	je     8007c6 <alloc_block+0x81>
			bitmap[no / 32] &= ~(1<<(no%32));
  800781:	8d 43 1f             	lea    0x1f(%ebx),%eax
  800784:	85 db                	test   %ebx,%ebx
  800786:	0f 49 c3             	cmovns %ebx,%eax
  800789:	c1 f8 05             	sar    $0x5,%eax
  80078c:	c1 e0 02             	shl    $0x2,%eax
  80078f:	89 c2                	mov    %eax,%edx
  800791:	03 15 04 a0 80 00    	add    0x80a004,%edx
  800797:	89 de                	mov    %ebx,%esi
  800799:	c1 fe 1f             	sar    $0x1f,%esi
  80079c:	c1 ee 1b             	shr    $0x1b,%esi
  80079f:	8d 0c 33             	lea    (%ebx,%esi,1),%ecx
  8007a2:	83 e1 1f             	and    $0x1f,%ecx
  8007a5:	29 f1                	sub    %esi,%ecx
  8007a7:	be fe ff ff ff       	mov    $0xfffffffe,%esi
  8007ac:	d3 c6                	rol    %cl,%esi
  8007ae:	21 32                	and    %esi,(%edx)
			flush_block(&bitmap[no/32]);
  8007b0:	83 ec 0c             	sub    $0xc,%esp
  8007b3:	03 05 04 a0 80 00    	add    0x80a004,%eax
  8007b9:	50                   	push   %eax
  8007ba:	e8 51 fc ff ff       	call   800410 <flush_block>
			return no;
  8007bf:	83 c4 10             	add    $0x10,%esp
  8007c2:	89 d8                	mov    %ebx,%eax
  8007c4:	eb 0c                	jmp    8007d2 <alloc_block+0x8d>
	if (!super)
		panic("in alloc_block: super not initialized");

	
	int no;
	for (no = 1; no < super->s_nblocks; no++) {
  8007c6:	83 c3 01             	add    $0x1,%ebx
  8007c9:	39 de                	cmp    %ebx,%esi
  8007cb:	77 a4                	ja     800771 <alloc_block+0x2c>
			return no;
		}
	}

	// No block is free
	return -E_NO_DISK;
  8007cd:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  8007d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007d5:	5b                   	pop    %ebx
  8007d6:	5e                   	pop    %esi
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	57                   	push   %edi
  8007dd:	56                   	push   %esi
  8007de:	53                   	push   %ebx
  8007df:	83 ec 1c             	sub    $0x1c,%esp
  8007e2:	8b 7d 08             	mov    0x8(%ebp),%edi
       // LAB 5: Your code here.
	
	if (filebno >= NDIRECT + NINDIRECT)
  8007e5:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  8007eb:	77 76                	ja     800863 <file_block_walk+0x8a>
		return -E_INVAL;
	if (filebno < NDIRECT) {
  8007ed:	83 fa 09             	cmp    $0x9,%edx
  8007f0:	77 10                	ja     800802 <file_block_walk+0x29>
		*ppdiskbno = &(f->f_direct[filebno]);
  8007f2:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  8007f9:	89 01                	mov    %eax,(%ecx)
		return 0;
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800800:	eb 74                	jmp    800876 <file_block_walk+0x9d>
  800802:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800805:	89 d3                	mov    %edx,%ebx
  800807:	89 c6                	mov    %eax,%esi
	}
	if (f->f_indirect == 0) {
  800809:	83 b8 b0 00 00 00 00 	cmpl   $0x0,0xb0(%eax)
  800810:	75 33                	jne    800845 <file_block_walk+0x6c>
		if (alloc) {
  800812:	89 f8                	mov    %edi,%eax
  800814:	84 c0                	test   %al,%al
  800816:	74 52                	je     80086a <file_block_walk+0x91>
			
			int new;
			if ((new = alloc_block()) < 0)
  800818:	e8 28 ff ff ff       	call   800745 <alloc_block>
  80081d:	89 c7                	mov    %eax,%edi
  80081f:	85 c0                	test   %eax,%eax
  800821:	78 4e                	js     800871 <file_block_walk+0x98>
				return -E_NO_DISK;

			
			memset(blockno_to_va(new), 0, BLKSIZE);
  800823:	83 ec 04             	sub    $0x4,%esp
  800826:	68 00 10 00 00       	push   $0x1000
  80082b:	6a 00                	push   $0x0
  80082d:	8d 80 00 00 01 00    	lea    0x10000(%eax),%eax
  800833:	c1 e0 0c             	shl    $0xc,%eax
  800836:	50                   	push   %eax
  800837:	e8 17 19 00 00       	call   802153 <memset>

			
			f->f_indirect = new;
  80083c:	89 be b0 00 00 00    	mov    %edi,0xb0(%esi)
  800842:	83 c4 10             	add    $0x10,%esp
			return -E_NOT_FOUND;
		}
	}

	uint32_t *indirblk = (uint32_t *) blockno_to_va(f->f_indirect);
	*ppdiskbno = &indirblk[filebno - NDIRECT];
  800845:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  80084b:	05 00 00 01 00       	add    $0x10000,%eax
  800850:	c1 e0 0c             	shl    $0xc,%eax
  800853:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800857:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80085a:	89 03                	mov    %eax,(%ebx)
	return 0;
  80085c:	b8 00 00 00 00       	mov    $0x0,%eax
  800861:	eb 13                	jmp    800876 <file_block_walk+0x9d>
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
       // LAB 5: Your code here.
	
	if (filebno >= NDIRECT + NINDIRECT)
		return -E_INVAL;
  800863:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800868:	eb 0c                	jmp    800876 <file_block_walk+0x9d>
			memset(blockno_to_va(new), 0, BLKSIZE);

			
			f->f_indirect = new;
		} else {
			return -E_NOT_FOUND;
  80086a:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  80086f:	eb 05                	jmp    800876 <file_block_walk+0x9d>
	if (f->f_indirect == 0) {
		if (alloc) {
			
			int new;
			if ((new = alloc_block()) < 0)
				return -E_NO_DISK;
  800871:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
	}

	uint32_t *indirblk = (uint32_t *) blockno_to_va(f->f_indirect);
	*ppdiskbno = &indirblk[filebno - NDIRECT];
	return 0;
}
  800876:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800879:	5b                   	pop    %ebx
  80087a:	5e                   	pop    %esi
  80087b:	5f                   	pop    %edi
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	56                   	push   %esi
  800882:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800883:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800888:	8b 70 04             	mov    0x4(%eax),%esi
  80088b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800890:	eb 29                	jmp    8008bb <check_bitmap+0x3d>
		assert(!block_is_free(2+i));
  800892:	8d 43 02             	lea    0x2(%ebx),%eax
  800895:	50                   	push   %eax
  800896:	e8 31 fe ff ff       	call   8006cc <block_is_free>
  80089b:	83 c4 04             	add    $0x4,%esp
  80089e:	84 c0                	test   %al,%al
  8008a0:	74 16                	je     8008b8 <check_bitmap+0x3a>
  8008a2:	68 af 39 80 00       	push   $0x8039af
  8008a7:	68 9d 37 80 00       	push   $0x80379d
  8008ac:	6a 5e                	push   $0x5e
  8008ae:	68 5f 39 80 00       	push   $0x80395f
  8008b3:	e8 f8 10 00 00       	call   8019b0 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8008b8:	83 c3 01             	add    $0x1,%ebx
  8008bb:	89 d8                	mov    %ebx,%eax
  8008bd:	c1 e0 0f             	shl    $0xf,%eax
  8008c0:	39 f0                	cmp    %esi,%eax
  8008c2:	72 ce                	jb     800892 <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  8008c4:	83 ec 0c             	sub    $0xc,%esp
  8008c7:	6a 00                	push   $0x0
  8008c9:	e8 fe fd ff ff       	call   8006cc <block_is_free>
  8008ce:	83 c4 10             	add    $0x10,%esp
  8008d1:	84 c0                	test   %al,%al
  8008d3:	74 16                	je     8008eb <check_bitmap+0x6d>
  8008d5:	68 c3 39 80 00       	push   $0x8039c3
  8008da:	68 9d 37 80 00       	push   $0x80379d
  8008df:	6a 61                	push   $0x61
  8008e1:	68 5f 39 80 00       	push   $0x80395f
  8008e6:	e8 c5 10 00 00       	call   8019b0 <_panic>
	assert(!block_is_free(1));
  8008eb:	83 ec 0c             	sub    $0xc,%esp
  8008ee:	6a 01                	push   $0x1
  8008f0:	e8 d7 fd ff ff       	call   8006cc <block_is_free>
  8008f5:	83 c4 10             	add    $0x10,%esp
  8008f8:	84 c0                	test   %al,%al
  8008fa:	74 16                	je     800912 <check_bitmap+0x94>
  8008fc:	68 d5 39 80 00       	push   $0x8039d5
  800901:	68 9d 37 80 00       	push   $0x80379d
  800906:	6a 62                	push   $0x62
  800908:	68 5f 39 80 00       	push   $0x80395f
  80090d:	e8 9e 10 00 00       	call   8019b0 <_panic>

	cprintf("bitmap is good\n");
  800912:	83 ec 0c             	sub    $0xc,%esp
  800915:	68 e7 39 80 00       	push   $0x8039e7
  80091a:	e8 6a 11 00 00       	call   801a89 <cprintf>
}
  80091f:	83 c4 10             	add    $0x10,%esp
  800922:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800925:	5b                   	pop    %ebx
  800926:	5e                   	pop    %esi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

       // Find a JOS disk.  Use the second IDE disk (number 1) if availabl
       if (ide_probe_disk1())
  80092f:	e8 2b f7 ff ff       	call   80005f <ide_probe_disk1>
  800934:	84 c0                	test   %al,%al
  800936:	74 0f                	je     800947 <fs_init+0x1e>
               ide_set_disk(1);
  800938:	83 ec 0c             	sub    $0xc,%esp
  80093b:	6a 01                	push   $0x1
  80093d:	e8 81 f7 ff ff       	call   8000c3 <ide_set_disk>
  800942:	83 c4 10             	add    $0x10,%esp
  800945:	eb 0d                	jmp    800954 <fs_init+0x2b>
       else
               ide_set_disk(0);
  800947:	83 ec 0c             	sub    $0xc,%esp
  80094a:	6a 00                	push   $0x0
  80094c:	e8 72 f7 ff ff       	call   8000c3 <ide_set_disk>
  800951:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800954:	e8 7b fb ff ff       	call   8004d4 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800959:	83 ec 0c             	sub    $0xc,%esp
  80095c:	6a 01                	push   $0x1
  80095e:	e8 2f fa ff ff       	call   800392 <diskaddr>
  800963:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  800968:	e8 09 fd ff ff       	call   800676 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  80096d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800974:	e8 19 fa ff ff       	call   800392 <diskaddr>
  800979:	a3 04 a0 80 00       	mov    %eax,0x80a004
	check_bitmap();
  80097e:	e8 fb fe ff ff       	call   80087e <check_bitmap>
	
}
  800983:	83 c4 10             	add    $0x10,%esp
  800986:	c9                   	leave  
  800987:	c3                   	ret    

00800988 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	53                   	push   %ebx
  80098c:	83 ec 20             	sub    $0x20,%esp
       // LAB 5: Your code here.
	// Retrieve the blockno_entry of the 'filebno'th block of file 'f'
	uint32_t *block_entry;
	int x;
	if ((x = file_block_walk(f, filebno, &block_entry, 1)) < 0) {
  80098f:	6a 01                	push   $0x1
  800991:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800994:	8b 55 0c             	mov    0xc(%ebp),%edx
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	e8 3a fe ff ff       	call   8007d9 <file_block_walk>
  80099f:	83 c4 10             	add    $0x10,%esp
  8009a2:	85 c0                	test   %eax,%eax
  8009a4:	78 52                	js     8009f8 <file_get_block+0x70>
		return x; // -E_INVAL or -E_NO_DISK
	}

	
	if (*block_entry == 0) {
  8009a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009a9:	83 38 00             	cmpl   $0x0,(%eax)
  8009ac:	75 2c                	jne    8009da <file_get_block+0x52>
		
		int newblk;
		if ((newblk = alloc_block()) < 0)
  8009ae:	e8 92 fd ff ff       	call   800745 <alloc_block>
  8009b3:	89 c3                	mov    %eax,%ebx
  8009b5:	85 c0                	test   %eax,%eax
  8009b7:	78 3a                	js     8009f3 <file_get_block+0x6b>
			return -E_NO_DISK;
	
		memset(blockno_to_va(newblk), 0, BLKSIZE);
  8009b9:	83 ec 04             	sub    $0x4,%esp
  8009bc:	68 00 10 00 00       	push   $0x1000
  8009c1:	6a 00                	push   $0x0
  8009c3:	8d 80 00 00 01 00    	lea    0x10000(%eax),%eax
  8009c9:	c1 e0 0c             	shl    $0xc,%eax
  8009cc:	50                   	push   %eax
  8009cd:	e8 81 17 00 00       	call   802153 <memset>
	
		*block_entry = newblk;
  8009d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009d5:	89 18                	mov    %ebx,(%eax)
  8009d7:	83 c4 10             	add    $0x10,%esp
	}

	*blk = blockno_to_va(*block_entry);
  8009da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009dd:	8b 00                	mov    (%eax),%eax
  8009df:	05 00 00 01 00       	add    $0x10000,%eax
  8009e4:	c1 e0 0c             	shl    $0xc,%eax
  8009e7:	8b 55 10             	mov    0x10(%ebp),%edx
  8009ea:	89 02                	mov    %eax,(%edx)
	return 0;
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f1:	eb 05                	jmp    8009f8 <file_get_block+0x70>
	
	if (*block_entry == 0) {
		
		int newblk;
		if ((newblk = alloc_block()) < 0)
			return -E_NO_DISK;
  8009f3:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
		*block_entry = newblk;
	}

	*blk = blockno_to_va(*block_entry);
	return 0;
}
  8009f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009fb:	c9                   	leave  
  8009fc:	c3                   	ret    

008009fd <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	57                   	push   %edi
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
  800a03:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  800a09:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  800a0f:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  800a15:	eb 03                	jmp    800a1a <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800a17:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800a1a:	80 38 2f             	cmpb   $0x2f,(%eax)
  800a1d:	74 f8                	je     800a17 <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800a1f:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  800a25:	83 c1 08             	add    $0x8,%ecx
  800a28:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  800a2e:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800a35:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  800a3b:	85 c9                	test   %ecx,%ecx
  800a3d:	74 06                	je     800a45 <walk_path+0x48>
		*pdir = 0;
  800a3f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  800a45:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800a4b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  800a51:	ba 00 00 00 00       	mov    $0x0,%edx
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800a56:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800a5c:	e9 5f 01 00 00       	jmp    800bc0 <walk_path+0x1c3>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800a61:	83 c7 01             	add    $0x1,%edi
  800a64:	eb 02                	jmp    800a68 <walk_path+0x6b>
  800a66:	89 c7                	mov    %eax,%edi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800a68:	0f b6 17             	movzbl (%edi),%edx
  800a6b:	80 fa 2f             	cmp    $0x2f,%dl
  800a6e:	74 04                	je     800a74 <walk_path+0x77>
  800a70:	84 d2                	test   %dl,%dl
  800a72:	75 ed                	jne    800a61 <walk_path+0x64>
			path++;
		if (path - p >= MAXNAMELEN)
  800a74:	89 fb                	mov    %edi,%ebx
  800a76:	29 c3                	sub    %eax,%ebx
  800a78:	83 fb 7f             	cmp    $0x7f,%ebx
  800a7b:	0f 8f 69 01 00 00    	jg     800bea <walk_path+0x1ed>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800a81:	83 ec 04             	sub    $0x4,%esp
  800a84:	53                   	push   %ebx
  800a85:	50                   	push   %eax
  800a86:	56                   	push   %esi
  800a87:	e8 14 17 00 00       	call   8021a0 <memmove>
		name[path - p] = '\0';
  800a8c:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800a93:	00 
  800a94:	83 c4 10             	add    $0x10,%esp
  800a97:	eb 03                	jmp    800a9c <walk_path+0x9f>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800a99:	83 c7 01             	add    $0x1,%edi

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800a9c:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800a9f:	74 f8                	je     800a99 <walk_path+0x9c>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800aa1:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800aa7:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800aae:	0f 85 3d 01 00 00    	jne    800bf1 <walk_path+0x1f4>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800ab4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800aba:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800abf:	74 19                	je     800ada <walk_path+0xdd>
  800ac1:	68 f7 39 80 00       	push   $0x8039f7
  800ac6:	68 9d 37 80 00       	push   $0x80379d
  800acb:	68 ef 00 00 00       	push   $0xef
  800ad0:	68 5f 39 80 00       	push   $0x80395f
  800ad5:	e8 d6 0e 00 00       	call   8019b0 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800ada:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800ae0:	85 c0                	test   %eax,%eax
  800ae2:	0f 48 c2             	cmovs  %edx,%eax
  800ae5:	c1 f8 0c             	sar    $0xc,%eax
  800ae8:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800aee:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800af5:	00 00 00 
  800af8:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
  800afe:	eb 5e                	jmp    800b5e <walk_path+0x161>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800b00:	83 ec 04             	sub    $0x4,%esp
  800b03:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800b09:	50                   	push   %eax
  800b0a:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800b10:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800b16:	e8 6d fe ff ff       	call   800988 <file_get_block>
  800b1b:	83 c4 10             	add    $0x10,%esp
  800b1e:	85 c0                	test   %eax,%eax
  800b20:	0f 88 ee 00 00 00    	js     800c14 <walk_path+0x217>
			return r;
		f = (struct File*) blk;
  800b26:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800b2c:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800b32:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800b38:	83 ec 08             	sub    $0x8,%esp
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
  800b3d:	e8 76 15 00 00       	call   8020b8 <strcmp>
  800b42:	83 c4 10             	add    $0x10,%esp
  800b45:	85 c0                	test   %eax,%eax
  800b47:	0f 84 ab 00 00 00    	je     800bf8 <walk_path+0x1fb>
  800b4d:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800b53:	39 fb                	cmp    %edi,%ebx
  800b55:	75 db                	jne    800b32 <walk_path+0x135>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800b57:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800b5e:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800b64:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800b6a:	75 94                	jne    800b00 <walk_path+0x103>
  800b6c:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800b72:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800b77:	80 3f 00             	cmpb   $0x0,(%edi)
  800b7a:	0f 85 a3 00 00 00    	jne    800c23 <walk_path+0x226>
				if (pdir)
  800b80:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800b86:	85 c0                	test   %eax,%eax
  800b88:	74 08                	je     800b92 <walk_path+0x195>
					*pdir = dir;
  800b8a:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800b90:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800b92:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b96:	74 15                	je     800bad <walk_path+0x1b0>
					strcpy(lastelem, name);
  800b98:	83 ec 08             	sub    $0x8,%esp
  800b9b:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800ba1:	50                   	push   %eax
  800ba2:	ff 75 08             	pushl  0x8(%ebp)
  800ba5:	e8 64 14 00 00       	call   80200e <strcpy>
  800baa:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800bad:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800bb3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800bb9:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800bbe:	eb 63                	jmp    800c23 <walk_path+0x226>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800bc0:	80 38 00             	cmpb   $0x0,(%eax)
  800bc3:	0f 85 9d fe ff ff    	jne    800a66 <walk_path+0x69>
			}
			return r;
		}
	}

	if (pdir)
  800bc9:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800bcf:	85 c0                	test   %eax,%eax
  800bd1:	74 02                	je     800bd5 <walk_path+0x1d8>
		*pdir = dir;
  800bd3:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800bd5:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800bdb:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800be1:	89 08                	mov    %ecx,(%eax)
	return 0;
  800be3:	b8 00 00 00 00       	mov    $0x0,%eax
  800be8:	eb 39                	jmp    800c23 <walk_path+0x226>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800bea:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800bef:	eb 32                	jmp    800c23 <walk_path+0x226>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800bf1:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800bf6:	eb 2b                	jmp    800c23 <walk_path+0x226>
  800bf8:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800bfe:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800c04:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800c0a:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  800c10:	89 f8                	mov    %edi,%eax
  800c12:	eb ac                	jmp    800bc0 <walk_path+0x1c3>
  800c14:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800c1a:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800c1d:	0f 84 4f ff ff ff    	je     800b72 <walk_path+0x175>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800c23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800c31:	6a 00                	push   $0x0
  800c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c36:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3e:	e8 ba fd ff ff       	call   8009fd <walk_path>
}
  800c43:	c9                   	leave  
  800c44:	c3                   	ret    

00800c45 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	83 ec 2c             	sub    $0x2c,%esp
  800c4e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c51:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800c54:	8b 45 08             	mov    0x8(%ebp),%eax
  800c57:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800c5d:	b8 00 00 00 00       	mov    $0x0,%eax
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800c62:	39 ca                	cmp    %ecx,%edx
  800c64:	7e 7c                	jle    800ce2 <file_read+0x9d>
		return 0;

	count = MIN(count, f->f_size - offset);
  800c66:	29 ca                	sub    %ecx,%edx
  800c68:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c6b:	0f 47 55 10          	cmova  0x10(%ebp),%edx
  800c6f:	89 55 d0             	mov    %edx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800c72:	89 ce                	mov    %ecx,%esi
  800c74:	01 d1                	add    %edx,%ecx
  800c76:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800c79:	eb 5d                	jmp    800cd8 <file_read+0x93>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800c7b:	83 ec 04             	sub    $0x4,%esp
  800c7e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800c81:	50                   	push   %eax
  800c82:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800c88:	85 f6                	test   %esi,%esi
  800c8a:	0f 49 c6             	cmovns %esi,%eax
  800c8d:	c1 f8 0c             	sar    $0xc,%eax
  800c90:	50                   	push   %eax
  800c91:	ff 75 08             	pushl  0x8(%ebp)
  800c94:	e8 ef fc ff ff       	call   800988 <file_get_block>
  800c99:	83 c4 10             	add    $0x10,%esp
  800c9c:	85 c0                	test   %eax,%eax
  800c9e:	78 42                	js     800ce2 <file_read+0x9d>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800ca0:	89 f2                	mov    %esi,%edx
  800ca2:	c1 fa 1f             	sar    $0x1f,%edx
  800ca5:	c1 ea 14             	shr    $0x14,%edx
  800ca8:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800cab:	25 ff 0f 00 00       	and    $0xfff,%eax
  800cb0:	29 d0                	sub    %edx,%eax
  800cb2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800cb5:	29 da                	sub    %ebx,%edx
  800cb7:	bb 00 10 00 00       	mov    $0x1000,%ebx
  800cbc:	29 c3                	sub    %eax,%ebx
  800cbe:	39 da                	cmp    %ebx,%edx
  800cc0:	0f 46 da             	cmovbe %edx,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800cc3:	83 ec 04             	sub    $0x4,%esp
  800cc6:	53                   	push   %ebx
  800cc7:	03 45 e4             	add    -0x1c(%ebp),%eax
  800cca:	50                   	push   %eax
  800ccb:	57                   	push   %edi
  800ccc:	e8 cf 14 00 00       	call   8021a0 <memmove>
		pos += bn;
  800cd1:	01 de                	add    %ebx,%esi
		buf += bn;
  800cd3:	01 df                	add    %ebx,%edi
  800cd5:	83 c4 10             	add    $0x10,%esp
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800cd8:	89 f3                	mov    %esi,%ebx
  800cda:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800cdd:	77 9c                	ja     800c7b <file_read+0x36>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800cdf:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800ce2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
  800cf0:	83 ec 2c             	sub    $0x2c,%esp
  800cf3:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800cf6:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800cfc:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800cff:	0f 8e a7 00 00 00    	jle    800dac <file_set_size+0xc2>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800d05:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800d0b:	05 ff 0f 00 00       	add    $0xfff,%eax
  800d10:	0f 49 f8             	cmovns %eax,%edi
  800d13:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800d16:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d19:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800d1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d21:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800d27:	0f 49 c2             	cmovns %edx,%eax
  800d2a:	c1 f8 0c             	sar    $0xc,%eax
  800d2d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800d30:	89 c3                	mov    %eax,%ebx
  800d32:	eb 39                	jmp    800d6d <file_set_size+0x83>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800d34:	83 ec 0c             	sub    $0xc,%esp
  800d37:	6a 00                	push   $0x0
  800d39:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800d3c:	89 da                	mov    %ebx,%edx
  800d3e:	89 f0                	mov    %esi,%eax
  800d40:	e8 94 fa ff ff       	call   8007d9 <file_block_walk>
  800d45:	83 c4 10             	add    $0x10,%esp
  800d48:	85 c0                	test   %eax,%eax
  800d4a:	78 4d                	js     800d99 <file_set_size+0xaf>
		return r;
	if (*ptr) {
  800d4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d4f:	8b 00                	mov    (%eax),%eax
  800d51:	85 c0                	test   %eax,%eax
  800d53:	74 15                	je     800d6a <file_set_size+0x80>
		free_block(*ptr);
  800d55:	83 ec 0c             	sub    $0xc,%esp
  800d58:	50                   	push   %eax
  800d59:	e8 ab f9 ff ff       	call   800709 <free_block>
		*ptr = 0;
  800d5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d61:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800d67:	83 c4 10             	add    $0x10,%esp
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800d6a:	83 c3 01             	add    $0x1,%ebx
  800d6d:	39 df                	cmp    %ebx,%edi
  800d6f:	77 c3                	ja     800d34 <file_set_size+0x4a>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800d71:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800d75:	77 35                	ja     800dac <file_set_size+0xc2>
  800d77:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	74 2b                	je     800dac <file_set_size+0xc2>
		free_block(f->f_indirect);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	50                   	push   %eax
  800d85:	e8 7f f9 ff ff       	call   800709 <free_block>
		f->f_indirect = 0;
  800d8a:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800d91:	00 00 00 
  800d94:	83 c4 10             	add    $0x10,%esp
  800d97:	eb 13                	jmp    800dac <file_set_size+0xc2>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800d99:	83 ec 08             	sub    $0x8,%esp
  800d9c:	50                   	push   %eax
  800d9d:	68 14 3a 80 00       	push   $0x803a14
  800da2:	e8 e2 0c 00 00       	call   801a89 <cprintf>
  800da7:	83 c4 10             	add    $0x10,%esp
  800daa:	eb be                	jmp    800d6a <file_set_size+0x80>
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800dac:	8b 45 0c             	mov    0xc(%ebp),%eax
  800daf:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800db5:	83 ec 0c             	sub    $0xc,%esp
  800db8:	56                   	push   %esi
  800db9:	e8 52 f6 ff ff       	call   800410 <flush_block>
	return 0;
}
  800dbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc6:	5b                   	pop    %ebx
  800dc7:	5e                   	pop    %esi
  800dc8:	5f                   	pop    %edi
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	57                   	push   %edi
  800dcf:	56                   	push   %esi
  800dd0:	53                   	push   %ebx
  800dd1:	83 ec 2c             	sub    $0x2c,%esp
  800dd4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800dd7:	8b 75 14             	mov    0x14(%ebp),%esi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800dda:	89 f0                	mov    %esi,%eax
  800ddc:	03 45 10             	add    0x10(%ebp),%eax
  800ddf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800de2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de5:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800deb:	76 72                	jbe    800e5f <file_write+0x94>
		if ((r = file_set_size(f, offset + count)) < 0)
  800ded:	83 ec 08             	sub    $0x8,%esp
  800df0:	50                   	push   %eax
  800df1:	51                   	push   %ecx
  800df2:	e8 f3 fe ff ff       	call   800cea <file_set_size>
  800df7:	83 c4 10             	add    $0x10,%esp
  800dfa:	85 c0                	test   %eax,%eax
  800dfc:	79 61                	jns    800e5f <file_write+0x94>
  800dfe:	eb 69                	jmp    800e69 <file_write+0x9e>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800e00:	83 ec 04             	sub    $0x4,%esp
  800e03:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e06:	50                   	push   %eax
  800e07:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800e0d:	85 f6                	test   %esi,%esi
  800e0f:	0f 49 c6             	cmovns %esi,%eax
  800e12:	c1 f8 0c             	sar    $0xc,%eax
  800e15:	50                   	push   %eax
  800e16:	ff 75 08             	pushl  0x8(%ebp)
  800e19:	e8 6a fb ff ff       	call   800988 <file_get_block>
  800e1e:	83 c4 10             	add    $0x10,%esp
  800e21:	85 c0                	test   %eax,%eax
  800e23:	78 44                	js     800e69 <file_write+0x9e>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800e25:	89 f2                	mov    %esi,%edx
  800e27:	c1 fa 1f             	sar    $0x1f,%edx
  800e2a:	c1 ea 14             	shr    $0x14,%edx
  800e2d:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800e30:	25 ff 0f 00 00       	and    $0xfff,%eax
  800e35:	29 d0                	sub    %edx,%eax
  800e37:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800e3a:	29 d9                	sub    %ebx,%ecx
  800e3c:	89 cb                	mov    %ecx,%ebx
  800e3e:	ba 00 10 00 00       	mov    $0x1000,%edx
  800e43:	29 c2                	sub    %eax,%edx
  800e45:	39 d1                	cmp    %edx,%ecx
  800e47:	0f 47 da             	cmova  %edx,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  800e4a:	83 ec 04             	sub    $0x4,%esp
  800e4d:	53                   	push   %ebx
  800e4e:	57                   	push   %edi
  800e4f:	03 45 e4             	add    -0x1c(%ebp),%eax
  800e52:	50                   	push   %eax
  800e53:	e8 48 13 00 00       	call   8021a0 <memmove>
		pos += bn;
  800e58:	01 de                	add    %ebx,%esi
		buf += bn;
  800e5a:	01 df                	add    %ebx,%edi
  800e5c:	83 c4 10             	add    $0x10,%esp
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800e5f:	89 f3                	mov    %esi,%ebx
  800e61:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800e64:	77 9a                	ja     800e00 <file_write+0x35>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800e66:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800e69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6c:	5b                   	pop    %ebx
  800e6d:	5e                   	pop    %esi
  800e6e:	5f                   	pop    %edi
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	56                   	push   %esi
  800e75:	53                   	push   %ebx
  800e76:	83 ec 10             	sub    $0x10,%esp
  800e79:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800e7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e81:	eb 3c                	jmp    800ebf <file_flush+0x4e>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800e83:	83 ec 0c             	sub    $0xc,%esp
  800e86:	6a 00                	push   $0x0
  800e88:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800e8b:	89 da                	mov    %ebx,%edx
  800e8d:	89 f0                	mov    %esi,%eax
  800e8f:	e8 45 f9 ff ff       	call   8007d9 <file_block_walk>
  800e94:	83 c4 10             	add    $0x10,%esp
  800e97:	85 c0                	test   %eax,%eax
  800e99:	78 21                	js     800ebc <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800e9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	74 1a                	je     800ebc <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800ea2:	8b 00                	mov    (%eax),%eax
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	74 14                	je     800ebc <file_flush+0x4b>
			continue;
		flush_block(diskaddr(*pdiskbno));
  800ea8:	83 ec 0c             	sub    $0xc,%esp
  800eab:	50                   	push   %eax
  800eac:	e8 e1 f4 ff ff       	call   800392 <diskaddr>
  800eb1:	89 04 24             	mov    %eax,(%esp)
  800eb4:	e8 57 f5 ff ff       	call   800410 <flush_block>
  800eb9:	83 c4 10             	add    $0x10,%esp
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800ebc:	83 c3 01             	add    $0x1,%ebx
  800ebf:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  800ec5:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  800ecb:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  800ed1:	85 c9                	test   %ecx,%ecx
  800ed3:	0f 49 c1             	cmovns %ecx,%eax
  800ed6:	c1 f8 0c             	sar    $0xc,%eax
  800ed9:	39 c3                	cmp    %eax,%ebx
  800edb:	7c a6                	jl     800e83 <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800edd:	83 ec 0c             	sub    $0xc,%esp
  800ee0:	56                   	push   %esi
  800ee1:	e8 2a f5 ff ff       	call   800410 <flush_block>
	if (f->f_indirect)
  800ee6:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800eec:	83 c4 10             	add    $0x10,%esp
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	74 14                	je     800f07 <file_flush+0x96>
		flush_block(diskaddr(f->f_indirect));
  800ef3:	83 ec 0c             	sub    $0xc,%esp
  800ef6:	50                   	push   %eax
  800ef7:	e8 96 f4 ff ff       	call   800392 <diskaddr>
  800efc:	89 04 24             	mov    %eax,(%esp)
  800eff:	e8 0c f5 ff ff       	call   800410 <flush_block>
  800f04:	83 c4 10             	add    $0x10,%esp
}
  800f07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f0a:	5b                   	pop    %ebx
  800f0b:	5e                   	pop    %esi
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    

00800f0e <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	57                   	push   %edi
  800f12:	56                   	push   %esi
  800f13:	53                   	push   %ebx
  800f14:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  800f1a:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800f20:	50                   	push   %eax
  800f21:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  800f27:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  800f2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f30:	e8 c8 fa ff ff       	call   8009fd <walk_path>
  800f35:	83 c4 10             	add    $0x10,%esp
  800f38:	85 c0                	test   %eax,%eax
  800f3a:	0f 84 d1 00 00 00    	je     801011 <file_create+0x103>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  800f40:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800f43:	0f 85 0c 01 00 00    	jne    801055 <file_create+0x147>
  800f49:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  800f4f:	85 f6                	test   %esi,%esi
  800f51:	0f 84 c1 00 00 00    	je     801018 <file_create+0x10a>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  800f57:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800f5d:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800f62:	74 19                	je     800f7d <file_create+0x6f>
  800f64:	68 f7 39 80 00       	push   $0x8039f7
  800f69:	68 9d 37 80 00       	push   $0x80379d
  800f6e:	68 08 01 00 00       	push   $0x108
  800f73:	68 5f 39 80 00       	push   $0x80395f
  800f78:	e8 33 0a 00 00       	call   8019b0 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800f7d:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800f83:	85 c0                	test   %eax,%eax
  800f85:	0f 48 c2             	cmovs  %edx,%eax
  800f88:	c1 f8 0c             	sar    $0xc,%eax
  800f8b:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  800f91:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800f96:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  800f9c:	eb 3b                	jmp    800fd9 <file_create+0xcb>
  800f9e:	83 ec 04             	sub    $0x4,%esp
  800fa1:	57                   	push   %edi
  800fa2:	53                   	push   %ebx
  800fa3:	56                   	push   %esi
  800fa4:	e8 df f9 ff ff       	call   800988 <file_get_block>
  800fa9:	83 c4 10             	add    $0x10,%esp
  800fac:	85 c0                	test   %eax,%eax
  800fae:	0f 88 a1 00 00 00    	js     801055 <file_create+0x147>
			return r;
		f = (struct File*) blk;
  800fb4:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800fba:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  800fc0:	80 38 00             	cmpb   $0x0,(%eax)
  800fc3:	75 08                	jne    800fcd <file_create+0xbf>
				*file = &f[j];
  800fc5:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  800fcb:	eb 52                	jmp    80101f <file_create+0x111>
  800fcd:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800fd2:	39 d0                	cmp    %edx,%eax
  800fd4:	75 ea                	jne    800fc0 <file_create+0xb2>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800fd6:	83 c3 01             	add    $0x1,%ebx
  800fd9:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  800fdf:	75 bd                	jne    800f9e <file_create+0x90>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  800fe1:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  800fe8:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  800feb:	83 ec 04             	sub    $0x4,%esp
  800fee:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  800ff4:	50                   	push   %eax
  800ff5:	53                   	push   %ebx
  800ff6:	56                   	push   %esi
  800ff7:	e8 8c f9 ff ff       	call   800988 <file_get_block>
  800ffc:	83 c4 10             	add    $0x10,%esp
  800fff:	85 c0                	test   %eax,%eax
  801001:	78 52                	js     801055 <file_create+0x147>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  801003:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801009:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  80100f:	eb 0e                	jmp    80101f <file_create+0x111>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  801011:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  801016:	eb 3d                	jmp    801055 <file_create+0x147>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  801018:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  80101d:	eb 36                	jmp    801055 <file_create+0x147>
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  80101f:	83 ec 08             	sub    $0x8,%esp
  801022:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801028:	50                   	push   %eax
  801029:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  80102f:	e8 da 0f 00 00       	call   80200e <strcpy>
	*pf = f;
  801034:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  80103a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80103d:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  80103f:	83 c4 04             	add    $0x4,%esp
  801042:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  801048:	e8 24 fe ff ff       	call   800e71 <file_flush>
	return 0;
  80104d:	83 c4 10             	add    $0x10,%esp
  801050:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801055:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801058:	5b                   	pop    %ebx
  801059:	5e                   	pop    %esi
  80105a:	5f                   	pop    %edi
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    

0080105d <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	53                   	push   %ebx
  801061:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801064:	bb 01 00 00 00       	mov    $0x1,%ebx
  801069:	eb 17                	jmp    801082 <fs_sync+0x25>
		flush_block(diskaddr(i));
  80106b:	83 ec 0c             	sub    $0xc,%esp
  80106e:	53                   	push   %ebx
  80106f:	e8 1e f3 ff ff       	call   800392 <diskaddr>
  801074:	89 04 24             	mov    %eax,(%esp)
  801077:	e8 94 f3 ff ff       	call   800410 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  80107c:	83 c3 01             	add    $0x1,%ebx
  80107f:	83 c4 10             	add    $0x10,%esp
  801082:	a1 08 a0 80 00       	mov    0x80a008,%eax
  801087:	39 58 04             	cmp    %ebx,0x4(%eax)
  80108a:	77 df                	ja     80106b <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  80108c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108f:	c9                   	leave  
  801090:	c3                   	ret    

00801091 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  801097:	e8 c1 ff ff ff       	call   80105d <fs_sync>
	return 0;
}
  80109c:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a1:	c9                   	leave  
  8010a2:	c3                   	ret    

008010a3 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	ba 60 50 80 00       	mov    $0x805060,%edx
	int i;
	uintptr_t va = FILEVA;
  8010ab:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  8010b0:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  8010b5:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  8010b7:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  8010ba:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  8010c0:	83 c0 01             	add    $0x1,%eax
  8010c3:	83 c2 10             	add    $0x10,%edx
  8010c6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010cb:	75 e8                	jne    8010b5 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  8010cd:	5d                   	pop    %ebp
  8010ce:	c3                   	ret    

008010cf <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	56                   	push   %esi
  8010d3:	53                   	push   %ebx
  8010d4:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8010d7:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  8010dc:	83 ec 0c             	sub    $0xc,%esp
  8010df:	89 d8                	mov    %ebx,%eax
  8010e1:	c1 e0 04             	shl    $0x4,%eax
  8010e4:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  8010ea:	e8 b3 1e 00 00       	call   802fa2 <pageref>
  8010ef:	83 c4 10             	add    $0x10,%esp
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	74 07                	je     8010fd <openfile_alloc+0x2e>
  8010f6:	83 f8 01             	cmp    $0x1,%eax
  8010f9:	74 20                	je     80111b <openfile_alloc+0x4c>
  8010fb:	eb 51                	jmp    80114e <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  8010fd:	83 ec 04             	sub    $0x4,%esp
  801100:	6a 07                	push   $0x7
  801102:	89 d8                	mov    %ebx,%eax
  801104:	c1 e0 04             	shl    $0x4,%eax
  801107:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  80110d:	6a 00                	push   $0x0
  80110f:	e8 fd 12 00 00       	call   802411 <sys_page_alloc>
  801114:	83 c4 10             	add    $0x10,%esp
  801117:	85 c0                	test   %eax,%eax
  801119:	78 43                	js     80115e <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  80111b:	c1 e3 04             	shl    $0x4,%ebx
  80111e:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  801124:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  80112b:	04 00 00 
			*o = &opentab[i];
  80112e:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  801130:	83 ec 04             	sub    $0x4,%esp
  801133:	68 00 10 00 00       	push   $0x1000
  801138:	6a 00                	push   $0x0
  80113a:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  801140:	e8 0e 10 00 00       	call   802153 <memset>
			return (*o)->o_fileid;
  801145:	8b 06                	mov    (%esi),%eax
  801147:	8b 00                	mov    (%eax),%eax
  801149:	83 c4 10             	add    $0x10,%esp
  80114c:	eb 10                	jmp    80115e <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  80114e:	83 c3 01             	add    $0x1,%ebx
  801151:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801157:	75 83                	jne    8010dc <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  801159:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80115e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801161:	5b                   	pop    %ebx
  801162:	5e                   	pop    %esi
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    

00801165 <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	57                   	push   %edi
  801169:	56                   	push   %esi
  80116a:	53                   	push   %ebx
  80116b:	83 ec 18             	sub    $0x18,%esp
  80116e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801171:	89 fb                	mov    %edi,%ebx
  801173:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801179:	89 de                	mov    %ebx,%esi
  80117b:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  80117e:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801184:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  80118a:	e8 13 1e 00 00       	call   802fa2 <pageref>
  80118f:	83 c4 10             	add    $0x10,%esp
  801192:	83 f8 01             	cmp    $0x1,%eax
  801195:	7e 17                	jle    8011ae <openfile_lookup+0x49>
  801197:	c1 e3 04             	shl    $0x4,%ebx
  80119a:	3b bb 60 50 80 00    	cmp    0x805060(%ebx),%edi
  8011a0:	75 13                	jne    8011b5 <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  8011a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8011a5:	89 30                	mov    %esi,(%eax)
	return 0;
  8011a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ac:	eb 0c                	jmp    8011ba <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  8011ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b3:	eb 05                	jmp    8011ba <openfile_lookup+0x55>
  8011b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  8011ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bd:	5b                   	pop    %ebx
  8011be:	5e                   	pop    %esi
  8011bf:	5f                   	pop    %edi
  8011c0:	5d                   	pop    %ebp
  8011c1:	c3                   	ret    

008011c2 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	53                   	push   %ebx
  8011c6:	83 ec 18             	sub    $0x18,%esp
  8011c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8011cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cf:	50                   	push   %eax
  8011d0:	ff 33                	pushl  (%ebx)
  8011d2:	ff 75 08             	pushl  0x8(%ebp)
  8011d5:	e8 8b ff ff ff       	call   801165 <openfile_lookup>
  8011da:	83 c4 10             	add    $0x10,%esp
  8011dd:	85 c0                	test   %eax,%eax
  8011df:	78 14                	js     8011f5 <serve_set_size+0x33>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  8011e1:	83 ec 08             	sub    $0x8,%esp
  8011e4:	ff 73 04             	pushl  0x4(%ebx)
  8011e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ea:	ff 70 04             	pushl  0x4(%eax)
  8011ed:	e8 f8 fa ff ff       	call   800cea <file_set_size>
  8011f2:	83 c4 10             	add    $0x10,%esp
}
  8011f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f8:	c9                   	leave  
  8011f9:	c3                   	ret    

008011fa <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	53                   	push   %ebx
  8011fe:	83 ec 18             	sub    $0x18,%esp
  801201:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// Lab 5: Your code here:
	
	struct OpenFile *open;
	int x;
	if ((x = openfile_lookup(envid, req->req_fileid, &open)) < 0)
  801204:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801207:	50                   	push   %eax
  801208:	ff 33                	pushl  (%ebx)
  80120a:	ff 75 08             	pushl  0x8(%ebp)
  80120d:	e8 53 ff ff ff       	call   801165 <openfile_lookup>
  801212:	83 c4 10             	add    $0x10,%esp
		return x;
  801215:	89 c2                	mov    %eax,%edx

	// Lab 5: Your code here:
	
	struct OpenFile *open;
	int x;
	if ((x = openfile_lookup(envid, req->req_fileid, &open)) < 0)
  801217:	85 c0                	test   %eax,%eax
  801219:	78 2b                	js     801246 <serve_read+0x4c>
		return x;

	
	struct File *file = open->o_file;
  80121b:	8b 45 f4             	mov    -0xc(%ebp),%eax
	size_t count = req->req_n;
	off_t offset = open->o_fd->fd_offset;
  80121e:	8b 50 0c             	mov    0xc(%eax),%edx
	x = file_read(file, ret, count, offset);
  801221:	ff 72 04             	pushl  0x4(%edx)
  801224:	ff 73 04             	pushl  0x4(%ebx)
  801227:	53                   	push   %ebx
  801228:	ff 70 04             	pushl  0x4(%eax)
  80122b:	e8 15 fa ff ff       	call   800c45 <file_read>

		if (x < 0) {
  801230:	83 c4 10             	add    $0x10,%esp
  801233:	85 c0                	test   %eax,%eax
  801235:	78 0d                	js     801244 <serve_read+0x4a>
		return x;
	} else {
		uint32_t bytes_read = x;
		open->o_fd->fd_offset += bytes_read;
  801237:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80123a:	8b 52 0c             	mov    0xc(%edx),%edx
  80123d:	01 42 04             	add    %eax,0x4(%edx)
		return bytes_read;
  801240:	89 c2                	mov    %eax,%edx
  801242:	eb 02                	jmp    801246 <serve_read+0x4c>
	size_t count = req->req_n;
	off_t offset = open->o_fd->fd_offset;
	x = file_read(file, ret, count, offset);

		if (x < 0) {
		return x;
  801244:	89 c2                	mov    %eax,%edx
	} else {
		uint32_t bytes_read = x;
		open->o_fd->fd_offset += bytes_read;
		return bytes_read;
	}
}
  801246:	89 d0                	mov    %edx,%eax
  801248:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80124b:	c9                   	leave  
  80124c:	c3                   	ret    

0080124d <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  80124d:	55                   	push   %ebp
  80124e:	89 e5                	mov    %esp,%ebp
  801250:	53                   	push   %ebx
  801251:	83 ec 18             	sub    $0x18,%esp
  801254:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// LAB 5: Your code here.
	
	struct OpenFile *open;
	int x;
	if ((x = openfile_lookup(envid, req->req_fileid, &open)) < 0)
  801257:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125a:	50                   	push   %eax
  80125b:	ff 33                	pushl  (%ebx)
  80125d:	ff 75 08             	pushl  0x8(%ebp)
  801260:	e8 00 ff ff ff       	call   801165 <openfile_lookup>
  801265:	83 c4 10             	add    $0x10,%esp
		return x;
  801268:	89 c2                	mov    %eax,%edx

	// LAB 5: Your code here.
	
	struct OpenFile *open;
	int x;
	if ((x = openfile_lookup(envid, req->req_fileid, &open)) < 0)
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 2e                	js     80129c <serve_write+0x4f>
		return x;

	struct File *file_to_write = open->o_file;
  80126e:	8b 45 f4             	mov    -0xc(%ebp),%eax
	size_t count = req->req_n;
	off_t offset = open->o_fd->fd_offset;
  801271:	8b 50 0c             	mov    0xc(%eax),%edx
	x = file_write(file_to_write, req->req_buf, count, offset);
  801274:	ff 72 04             	pushl  0x4(%edx)
  801277:	ff 73 04             	pushl  0x4(%ebx)
  80127a:	83 c3 08             	add    $0x8,%ebx
  80127d:	53                   	push   %ebx
  80127e:	ff 70 04             	pushl  0x4(%eax)
  801281:	e8 45 fb ff ff       	call   800dcb <file_write>

	if (x < 0) {
  801286:	83 c4 10             	add    $0x10,%esp
  801289:	85 c0                	test   %eax,%eax
  80128b:	78 0d                	js     80129a <serve_write+0x4d>
		return x;
	
	} else {
		uint32_t bytes_written = x;
		open->o_fd->fd_offset += bytes_written;
  80128d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801290:	8b 52 0c             	mov    0xc(%edx),%edx
  801293:	01 42 04             	add    %eax,0x4(%edx)
		return bytes_written;
  801296:	89 c2                	mov    %eax,%edx
  801298:	eb 02                	jmp    80129c <serve_write+0x4f>
	size_t count = req->req_n;
	off_t offset = open->o_fd->fd_offset;
	x = file_write(file_to_write, req->req_buf, count, offset);

	if (x < 0) {
		return x;
  80129a:	89 c2                	mov    %eax,%edx
	} else {
		uint32_t bytes_written = x;
		open->o_fd->fd_offset += bytes_written;
		return bytes_written;
	}
}
  80129c:	89 d0                	mov    %edx,%eax
  80129e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a1:	c9                   	leave  
  8012a2:	c3                   	ret    

008012a3 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  8012a3:	55                   	push   %ebp
  8012a4:	89 e5                	mov    %esp,%ebp
  8012a6:	53                   	push   %ebx
  8012a7:	83 ec 18             	sub    $0x18,%esp
  8012aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8012ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b0:	50                   	push   %eax
  8012b1:	ff 33                	pushl  (%ebx)
  8012b3:	ff 75 08             	pushl  0x8(%ebp)
  8012b6:	e8 aa fe ff ff       	call   801165 <openfile_lookup>
  8012bb:	83 c4 10             	add    $0x10,%esp
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	78 3f                	js     801301 <serve_stat+0x5e>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  8012c2:	83 ec 08             	sub    $0x8,%esp
  8012c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c8:	ff 70 04             	pushl  0x4(%eax)
  8012cb:	53                   	push   %ebx
  8012cc:	e8 3d 0d 00 00       	call   80200e <strcpy>
	ret->ret_size = o->o_file->f_size;
  8012d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d4:	8b 50 04             	mov    0x4(%eax),%edx
  8012d7:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  8012dd:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8012e3:	8b 40 04             	mov    0x4(%eax),%eax
  8012e6:	83 c4 10             	add    $0x10,%esp
  8012e9:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8012f0:	0f 94 c0             	sete   %al
  8012f3:	0f b6 c0             	movzbl %al,%eax
  8012f6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8012fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801301:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801304:	c9                   	leave  
  801305:	c3                   	ret    

00801306 <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  801306:	55                   	push   %ebp
  801307:	89 e5                	mov    %esp,%ebp
  801309:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80130c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130f:	50                   	push   %eax
  801310:	8b 45 0c             	mov    0xc(%ebp),%eax
  801313:	ff 30                	pushl  (%eax)
  801315:	ff 75 08             	pushl  0x8(%ebp)
  801318:	e8 48 fe ff ff       	call   801165 <openfile_lookup>
  80131d:	83 c4 10             	add    $0x10,%esp
  801320:	85 c0                	test   %eax,%eax
  801322:	78 16                	js     80133a <serve_flush+0x34>
		return r;
	file_flush(o->o_file);
  801324:	83 ec 0c             	sub    $0xc,%esp
  801327:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132a:	ff 70 04             	pushl  0x4(%eax)
  80132d:	e8 3f fb ff ff       	call   800e71 <file_flush>
	return 0;
  801332:	83 c4 10             	add    $0x10,%esp
  801335:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80133a:	c9                   	leave  
  80133b:	c3                   	ret    

0080133c <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	53                   	push   %ebx
  801340:	81 ec 18 04 00 00    	sub    $0x418,%esp
  801346:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801349:	68 00 04 00 00       	push   $0x400
  80134e:	53                   	push   %ebx
  80134f:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801355:	50                   	push   %eax
  801356:	e8 45 0e 00 00       	call   8021a0 <memmove>
	path[MAXPATHLEN-1] = 0;
  80135b:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  80135f:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801365:	89 04 24             	mov    %eax,(%esp)
  801368:	e8 62 fd ff ff       	call   8010cf <openfile_alloc>
  80136d:	83 c4 10             	add    $0x10,%esp
  801370:	85 c0                	test   %eax,%eax
  801372:	0f 88 f0 00 00 00    	js     801468 <serve_open+0x12c>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  801378:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  80137f:	74 33                	je     8013b4 <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  801381:	83 ec 08             	sub    $0x8,%esp
  801384:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  80138a:	50                   	push   %eax
  80138b:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801391:	50                   	push   %eax
  801392:	e8 77 fb ff ff       	call   800f0e <file_create>
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	85 c0                	test   %eax,%eax
  80139c:	79 37                	jns    8013d5 <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  80139e:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  8013a5:	0f 85 bd 00 00 00    	jne    801468 <serve_open+0x12c>
  8013ab:	83 f8 f3             	cmp    $0xfffffff3,%eax
  8013ae:	0f 85 b4 00 00 00    	jne    801468 <serve_open+0x12c>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  8013b4:	83 ec 08             	sub    $0x8,%esp
  8013b7:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8013bd:	50                   	push   %eax
  8013be:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8013c4:	50                   	push   %eax
  8013c5:	e8 61 f8 ff ff       	call   800c2b <file_open>
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	0f 88 93 00 00 00    	js     801468 <serve_open+0x12c>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  8013d5:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8013dc:	74 17                	je     8013f5 <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  8013de:	83 ec 08             	sub    $0x8,%esp
  8013e1:	6a 00                	push   $0x0
  8013e3:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  8013e9:	e8 fc f8 ff ff       	call   800cea <file_set_size>
  8013ee:	83 c4 10             	add    $0x10,%esp
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	78 73                	js     801468 <serve_open+0x12c>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  8013f5:	83 ec 08             	sub    $0x8,%esp
  8013f8:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8013fe:	50                   	push   %eax
  8013ff:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801405:	50                   	push   %eax
  801406:	e8 20 f8 ff ff       	call   800c2b <file_open>
  80140b:	83 c4 10             	add    $0x10,%esp
  80140e:	85 c0                	test   %eax,%eax
  801410:	78 56                	js     801468 <serve_open+0x12c>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  801412:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801418:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  80141e:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  801421:	8b 50 0c             	mov    0xc(%eax),%edx
  801424:	8b 08                	mov    (%eax),%ecx
  801426:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  801429:	8b 48 0c             	mov    0xc(%eax),%ecx
  80142c:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801432:	83 e2 03             	and    $0x3,%edx
  801435:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801438:	8b 40 0c             	mov    0xc(%eax),%eax
  80143b:	8b 15 64 90 80 00    	mov    0x809064,%edx
  801441:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  801443:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801449:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80144f:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  801452:	8b 50 0c             	mov    0xc(%eax),%edx
  801455:	8b 45 10             	mov    0x10(%ebp),%eax
  801458:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  80145a:	8b 45 14             	mov    0x14(%ebp),%eax
  80145d:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  801463:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801468:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146b:	c9                   	leave  
  80146c:	c3                   	ret    

0080146d <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  80146d:	55                   	push   %ebp
  80146e:	89 e5                	mov    %esp,%ebp
  801470:	56                   	push   %esi
  801471:	53                   	push   %ebx
  801472:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801475:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  801478:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  80147b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801482:	83 ec 04             	sub    $0x4,%esp
  801485:	53                   	push   %ebx
  801486:	ff 35 44 50 80 00    	pushl  0x805044
  80148c:	56                   	push   %esi
  80148d:	e8 e6 11 00 00       	call   802678 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  801499:	75 15                	jne    8014b0 <serve+0x43>
			cprintf("Invalid request from %08x: no argument page\n",
  80149b:	83 ec 08             	sub    $0x8,%esp
  80149e:	ff 75 f4             	pushl  -0xc(%ebp)
  8014a1:	68 5c 3a 80 00       	push   $0x803a5c
  8014a6:	e8 de 05 00 00       	call   801a89 <cprintf>
				whom);
			continue; // just leave it hanging...
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	eb cb                	jmp    80147b <serve+0xe>
		}

		pg = NULL;
  8014b0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  8014b7:	83 f8 01             	cmp    $0x1,%eax
  8014ba:	75 18                	jne    8014d4 <serve+0x67>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  8014bc:	53                   	push   %ebx
  8014bd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8014c0:	50                   	push   %eax
  8014c1:	ff 35 44 50 80 00    	pushl  0x805044
  8014c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ca:	e8 6d fe ff ff       	call   80133c <serve_open>
  8014cf:	83 c4 10             	add    $0x10,%esp
  8014d2:	eb 3c                	jmp    801510 <serve+0xa3>
		} else if (req < NHANDLERS && handlers[req]) {
  8014d4:	83 f8 08             	cmp    $0x8,%eax
  8014d7:	77 1e                	ja     8014f7 <serve+0x8a>
  8014d9:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  8014e0:	85 d2                	test   %edx,%edx
  8014e2:	74 13                	je     8014f7 <serve+0x8a>
			r = handlers[req](whom, fsreq);
  8014e4:	83 ec 08             	sub    $0x8,%esp
  8014e7:	ff 35 44 50 80 00    	pushl  0x805044
  8014ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8014f0:	ff d2                	call   *%edx
  8014f2:	83 c4 10             	add    $0x10,%esp
  8014f5:	eb 19                	jmp    801510 <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  8014f7:	83 ec 04             	sub    $0x4,%esp
  8014fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8014fd:	50                   	push   %eax
  8014fe:	68 8c 3a 80 00       	push   $0x803a8c
  801503:	e8 81 05 00 00       	call   801a89 <cprintf>
  801508:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  80150b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  801510:	ff 75 f0             	pushl  -0x10(%ebp)
  801513:	ff 75 ec             	pushl  -0x14(%ebp)
  801516:	50                   	push   %eax
  801517:	ff 75 f4             	pushl  -0xc(%ebp)
  80151a:	e8 c2 11 00 00       	call   8026e1 <ipc_send>
		sys_page_unmap(0, fsreq);
  80151f:	83 c4 08             	add    $0x8,%esp
  801522:	ff 35 44 50 80 00    	pushl  0x805044
  801528:	6a 00                	push   $0x0
  80152a:	e8 67 0f 00 00       	call   802496 <sys_page_unmap>
  80152f:	83 c4 10             	add    $0x10,%esp
  801532:	e9 44 ff ff ff       	jmp    80147b <serve+0xe>

00801537 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  801537:	55                   	push   %ebp
  801538:	89 e5                	mov    %esp,%ebp
  80153a:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  80153d:	c7 05 60 90 80 00 af 	movl   $0x803aaf,0x809060
  801544:	3a 80 00 
	cprintf("FS is running\n");
  801547:	68 b2 3a 80 00       	push   $0x803ab2
  80154c:	e8 38 05 00 00       	call   801a89 <cprintf>
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  801551:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801556:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  80155b:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  80155d:	c7 04 24 c1 3a 80 00 	movl   $0x803ac1,(%esp)
  801564:	e8 20 05 00 00       	call   801a89 <cprintf>

	serve_init();
  801569:	e8 35 fb ff ff       	call   8010a3 <serve_init>
	fs_init();
  80156e:	e8 b6 f3 ff ff       	call   800929 <fs_init>
        fs_test();
  801573:	e8 05 00 00 00       	call   80157d <fs_test>
	serve();
  801578:	e8 f0 fe ff ff       	call   80146d <serve>

0080157d <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  80157d:	55                   	push   %ebp
  80157e:	89 e5                	mov    %esp,%ebp
  801580:	53                   	push   %ebx
  801581:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  801584:	6a 07                	push   $0x7
  801586:	68 00 10 00 00       	push   $0x1000
  80158b:	6a 00                	push   $0x0
  80158d:	e8 7f 0e 00 00       	call   802411 <sys_page_alloc>
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	85 c0                	test   %eax,%eax
  801597:	79 12                	jns    8015ab <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  801599:	50                   	push   %eax
  80159a:	68 d0 3a 80 00       	push   $0x803ad0
  80159f:	6a 12                	push   $0x12
  8015a1:	68 e3 3a 80 00       	push   $0x803ae3
  8015a6:	e8 05 04 00 00       	call   8019b0 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  8015ab:	83 ec 04             	sub    $0x4,%esp
  8015ae:	68 00 10 00 00       	push   $0x1000
  8015b3:	ff 35 04 a0 80 00    	pushl  0x80a004
  8015b9:	68 00 10 00 00       	push   $0x1000
  8015be:	e8 dd 0b 00 00       	call   8021a0 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8015c3:	e8 7d f1 ff ff       	call   800745 <alloc_block>
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	79 12                	jns    8015e1 <fs_test+0x64>
		panic("alloc_block: %e", r);
  8015cf:	50                   	push   %eax
  8015d0:	68 ed 3a 80 00       	push   $0x803aed
  8015d5:	6a 17                	push   $0x17
  8015d7:	68 e3 3a 80 00       	push   $0x803ae3
  8015dc:	e8 cf 03 00 00       	call   8019b0 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8015e1:	8d 50 1f             	lea    0x1f(%eax),%edx
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	0f 49 d0             	cmovns %eax,%edx
  8015e9:	c1 fa 05             	sar    $0x5,%edx
  8015ec:	89 c3                	mov    %eax,%ebx
  8015ee:	c1 fb 1f             	sar    $0x1f,%ebx
  8015f1:	c1 eb 1b             	shr    $0x1b,%ebx
  8015f4:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  8015f7:	83 e1 1f             	and    $0x1f,%ecx
  8015fa:	29 d9                	sub    %ebx,%ecx
  8015fc:	b8 01 00 00 00       	mov    $0x1,%eax
  801601:	d3 e0                	shl    %cl,%eax
  801603:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  80160a:	75 16                	jne    801622 <fs_test+0xa5>
  80160c:	68 fd 3a 80 00       	push   $0x803afd
  801611:	68 9d 37 80 00       	push   $0x80379d
  801616:	6a 19                	push   $0x19
  801618:	68 e3 3a 80 00       	push   $0x803ae3
  80161d:	e8 8e 03 00 00       	call   8019b0 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801622:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  801628:	85 04 91             	test   %eax,(%ecx,%edx,4)
  80162b:	74 16                	je     801643 <fs_test+0xc6>
  80162d:	68 78 3c 80 00       	push   $0x803c78
  801632:	68 9d 37 80 00       	push   $0x80379d
  801637:	6a 1b                	push   $0x1b
  801639:	68 e3 3a 80 00       	push   $0x803ae3
  80163e:	e8 6d 03 00 00       	call   8019b0 <_panic>
	cprintf("alloc_block is good\n");
  801643:	83 ec 0c             	sub    $0xc,%esp
  801646:	68 18 3b 80 00       	push   $0x803b18
  80164b:	e8 39 04 00 00       	call   801a89 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801650:	83 c4 08             	add    $0x8,%esp
  801653:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801656:	50                   	push   %eax
  801657:	68 2d 3b 80 00       	push   $0x803b2d
  80165c:	e8 ca f5 ff ff       	call   800c2b <file_open>
  801661:	83 c4 10             	add    $0x10,%esp
  801664:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801667:	74 1b                	je     801684 <fs_test+0x107>
  801669:	89 c2                	mov    %eax,%edx
  80166b:	c1 ea 1f             	shr    $0x1f,%edx
  80166e:	84 d2                	test   %dl,%dl
  801670:	74 12                	je     801684 <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  801672:	50                   	push   %eax
  801673:	68 38 3b 80 00       	push   $0x803b38
  801678:	6a 1f                	push   $0x1f
  80167a:	68 e3 3a 80 00       	push   $0x803ae3
  80167f:	e8 2c 03 00 00       	call   8019b0 <_panic>
	else if (r == 0)
  801684:	85 c0                	test   %eax,%eax
  801686:	75 14                	jne    80169c <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  801688:	83 ec 04             	sub    $0x4,%esp
  80168b:	68 98 3c 80 00       	push   $0x803c98
  801690:	6a 21                	push   $0x21
  801692:	68 e3 3a 80 00       	push   $0x803ae3
  801697:	e8 14 03 00 00       	call   8019b0 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  80169c:	83 ec 08             	sub    $0x8,%esp
  80169f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a2:	50                   	push   %eax
  8016a3:	68 51 3b 80 00       	push   $0x803b51
  8016a8:	e8 7e f5 ff ff       	call   800c2b <file_open>
  8016ad:	83 c4 10             	add    $0x10,%esp
  8016b0:	85 c0                	test   %eax,%eax
  8016b2:	79 12                	jns    8016c6 <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  8016b4:	50                   	push   %eax
  8016b5:	68 5a 3b 80 00       	push   $0x803b5a
  8016ba:	6a 23                	push   $0x23
  8016bc:	68 e3 3a 80 00       	push   $0x803ae3
  8016c1:	e8 ea 02 00 00       	call   8019b0 <_panic>
	cprintf("file_open is good\n");
  8016c6:	83 ec 0c             	sub    $0xc,%esp
  8016c9:	68 71 3b 80 00       	push   $0x803b71
  8016ce:	e8 b6 03 00 00       	call   801a89 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8016d3:	83 c4 0c             	add    $0xc,%esp
  8016d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d9:	50                   	push   %eax
  8016da:	6a 00                	push   $0x0
  8016dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8016df:	e8 a4 f2 ff ff       	call   800988 <file_get_block>
  8016e4:	83 c4 10             	add    $0x10,%esp
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	79 12                	jns    8016fd <fs_test+0x180>
		panic("file_get_block: %e", r);
  8016eb:	50                   	push   %eax
  8016ec:	68 84 3b 80 00       	push   $0x803b84
  8016f1:	6a 27                	push   $0x27
  8016f3:	68 e3 3a 80 00       	push   $0x803ae3
  8016f8:	e8 b3 02 00 00       	call   8019b0 <_panic>
	if (strcmp(blk, msg) != 0)
  8016fd:	83 ec 08             	sub    $0x8,%esp
  801700:	68 b8 3c 80 00       	push   $0x803cb8
  801705:	ff 75 f0             	pushl  -0x10(%ebp)
  801708:	e8 ab 09 00 00       	call   8020b8 <strcmp>
  80170d:	83 c4 10             	add    $0x10,%esp
  801710:	85 c0                	test   %eax,%eax
  801712:	74 14                	je     801728 <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  801714:	83 ec 04             	sub    $0x4,%esp
  801717:	68 e0 3c 80 00       	push   $0x803ce0
  80171c:	6a 29                	push   $0x29
  80171e:	68 e3 3a 80 00       	push   $0x803ae3
  801723:	e8 88 02 00 00       	call   8019b0 <_panic>
	cprintf("file_get_block is good\n");
  801728:	83 ec 0c             	sub    $0xc,%esp
  80172b:	68 97 3b 80 00       	push   $0x803b97
  801730:	e8 54 03 00 00       	call   801a89 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801735:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801738:	0f b6 10             	movzbl (%eax),%edx
  80173b:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  80173d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801740:	c1 e8 0c             	shr    $0xc,%eax
  801743:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80174a:	83 c4 10             	add    $0x10,%esp
  80174d:	a8 40                	test   $0x40,%al
  80174f:	75 16                	jne    801767 <fs_test+0x1ea>
  801751:	68 b0 3b 80 00       	push   $0x803bb0
  801756:	68 9d 37 80 00       	push   $0x80379d
  80175b:	6a 2d                	push   $0x2d
  80175d:	68 e3 3a 80 00       	push   $0x803ae3
  801762:	e8 49 02 00 00       	call   8019b0 <_panic>
	file_flush(f);
  801767:	83 ec 0c             	sub    $0xc,%esp
  80176a:	ff 75 f4             	pushl  -0xc(%ebp)
  80176d:	e8 ff f6 ff ff       	call   800e71 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801772:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801775:	c1 e8 0c             	shr    $0xc,%eax
  801778:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80177f:	83 c4 10             	add    $0x10,%esp
  801782:	a8 40                	test   $0x40,%al
  801784:	74 16                	je     80179c <fs_test+0x21f>
  801786:	68 af 3b 80 00       	push   $0x803baf
  80178b:	68 9d 37 80 00       	push   $0x80379d
  801790:	6a 2f                	push   $0x2f
  801792:	68 e3 3a 80 00       	push   $0x803ae3
  801797:	e8 14 02 00 00       	call   8019b0 <_panic>
	cprintf("file_flush is good\n");
  80179c:	83 ec 0c             	sub    $0xc,%esp
  80179f:	68 cb 3b 80 00       	push   $0x803bcb
  8017a4:	e8 e0 02 00 00       	call   801a89 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  8017a9:	83 c4 08             	add    $0x8,%esp
  8017ac:	6a 00                	push   $0x0
  8017ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8017b1:	e8 34 f5 ff ff       	call   800cea <file_set_size>
  8017b6:	83 c4 10             	add    $0x10,%esp
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	79 12                	jns    8017cf <fs_test+0x252>
		panic("file_set_size: %e", r);
  8017bd:	50                   	push   %eax
  8017be:	68 df 3b 80 00       	push   $0x803bdf
  8017c3:	6a 33                	push   $0x33
  8017c5:	68 e3 3a 80 00       	push   $0x803ae3
  8017ca:	e8 e1 01 00 00       	call   8019b0 <_panic>
	assert(f->f_direct[0] == 0);
  8017cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d2:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8017d9:	74 16                	je     8017f1 <fs_test+0x274>
  8017db:	68 f1 3b 80 00       	push   $0x803bf1
  8017e0:	68 9d 37 80 00       	push   $0x80379d
  8017e5:	6a 34                	push   $0x34
  8017e7:	68 e3 3a 80 00       	push   $0x803ae3
  8017ec:	e8 bf 01 00 00       	call   8019b0 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8017f1:	c1 e8 0c             	shr    $0xc,%eax
  8017f4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017fb:	a8 40                	test   $0x40,%al
  8017fd:	74 16                	je     801815 <fs_test+0x298>
  8017ff:	68 05 3c 80 00       	push   $0x803c05
  801804:	68 9d 37 80 00       	push   $0x80379d
  801809:	6a 35                	push   $0x35
  80180b:	68 e3 3a 80 00       	push   $0x803ae3
  801810:	e8 9b 01 00 00       	call   8019b0 <_panic>
	cprintf("file_truncate is good\n");
  801815:	83 ec 0c             	sub    $0xc,%esp
  801818:	68 1f 3c 80 00       	push   $0x803c1f
  80181d:	e8 67 02 00 00       	call   801a89 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801822:	c7 04 24 b8 3c 80 00 	movl   $0x803cb8,(%esp)
  801829:	e8 a7 07 00 00       	call   801fd5 <strlen>
  80182e:	83 c4 08             	add    $0x8,%esp
  801831:	50                   	push   %eax
  801832:	ff 75 f4             	pushl  -0xc(%ebp)
  801835:	e8 b0 f4 ff ff       	call   800cea <file_set_size>
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	85 c0                	test   %eax,%eax
  80183f:	79 12                	jns    801853 <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  801841:	50                   	push   %eax
  801842:	68 36 3c 80 00       	push   $0x803c36
  801847:	6a 39                	push   $0x39
  801849:	68 e3 3a 80 00       	push   $0x803ae3
  80184e:	e8 5d 01 00 00       	call   8019b0 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801853:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801856:	89 c2                	mov    %eax,%edx
  801858:	c1 ea 0c             	shr    $0xc,%edx
  80185b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801862:	f6 c2 40             	test   $0x40,%dl
  801865:	74 16                	je     80187d <fs_test+0x300>
  801867:	68 05 3c 80 00       	push   $0x803c05
  80186c:	68 9d 37 80 00       	push   $0x80379d
  801871:	6a 3a                	push   $0x3a
  801873:	68 e3 3a 80 00       	push   $0x803ae3
  801878:	e8 33 01 00 00       	call   8019b0 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  80187d:	83 ec 04             	sub    $0x4,%esp
  801880:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801883:	52                   	push   %edx
  801884:	6a 00                	push   $0x0
  801886:	50                   	push   %eax
  801887:	e8 fc f0 ff ff       	call   800988 <file_get_block>
  80188c:	83 c4 10             	add    $0x10,%esp
  80188f:	85 c0                	test   %eax,%eax
  801891:	79 12                	jns    8018a5 <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  801893:	50                   	push   %eax
  801894:	68 4a 3c 80 00       	push   $0x803c4a
  801899:	6a 3c                	push   $0x3c
  80189b:	68 e3 3a 80 00       	push   $0x803ae3
  8018a0:	e8 0b 01 00 00       	call   8019b0 <_panic>
	strcpy(blk, msg);
  8018a5:	83 ec 08             	sub    $0x8,%esp
  8018a8:	68 b8 3c 80 00       	push   $0x803cb8
  8018ad:	ff 75 f0             	pushl  -0x10(%ebp)
  8018b0:	e8 59 07 00 00       	call   80200e <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8018b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b8:	c1 e8 0c             	shr    $0xc,%eax
  8018bb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018c2:	83 c4 10             	add    $0x10,%esp
  8018c5:	a8 40                	test   $0x40,%al
  8018c7:	75 16                	jne    8018df <fs_test+0x362>
  8018c9:	68 b0 3b 80 00       	push   $0x803bb0
  8018ce:	68 9d 37 80 00       	push   $0x80379d
  8018d3:	6a 3e                	push   $0x3e
  8018d5:	68 e3 3a 80 00       	push   $0x803ae3
  8018da:	e8 d1 00 00 00       	call   8019b0 <_panic>
	file_flush(f);
  8018df:	83 ec 0c             	sub    $0xc,%esp
  8018e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e5:	e8 87 f5 ff ff       	call   800e71 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8018ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ed:	c1 e8 0c             	shr    $0xc,%eax
  8018f0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018f7:	83 c4 10             	add    $0x10,%esp
  8018fa:	a8 40                	test   $0x40,%al
  8018fc:	74 16                	je     801914 <fs_test+0x397>
  8018fe:	68 af 3b 80 00       	push   $0x803baf
  801903:	68 9d 37 80 00       	push   $0x80379d
  801908:	6a 40                	push   $0x40
  80190a:	68 e3 3a 80 00       	push   $0x803ae3
  80190f:	e8 9c 00 00 00       	call   8019b0 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801914:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801917:	c1 e8 0c             	shr    $0xc,%eax
  80191a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801921:	a8 40                	test   $0x40,%al
  801923:	74 16                	je     80193b <fs_test+0x3be>
  801925:	68 05 3c 80 00       	push   $0x803c05
  80192a:	68 9d 37 80 00       	push   $0x80379d
  80192f:	6a 41                	push   $0x41
  801931:	68 e3 3a 80 00       	push   $0x803ae3
  801936:	e8 75 00 00 00       	call   8019b0 <_panic>
	cprintf("file rewrite is good\n");
  80193b:	83 ec 0c             	sub    $0xc,%esp
  80193e:	68 5f 3c 80 00       	push   $0x803c5f
  801943:	e8 41 01 00 00       	call   801a89 <cprintf>
}
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80194e:	c9                   	leave  
  80194f:	c3                   	ret    

00801950 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	56                   	push   %esi
  801954:	53                   	push   %ebx
  801955:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801958:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80195b:	e8 73 0a 00 00       	call   8023d3 <sys_getenvid>
  801960:	25 ff 03 00 00       	and    $0x3ff,%eax
  801965:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801968:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80196d:	a3 0c a0 80 00       	mov    %eax,0x80a00c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801972:	85 db                	test   %ebx,%ebx
  801974:	7e 07                	jle    80197d <libmain+0x2d>
		binaryname = argv[0];
  801976:	8b 06                	mov    (%esi),%eax
  801978:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  80197d:	83 ec 08             	sub    $0x8,%esp
  801980:	56                   	push   %esi
  801981:	53                   	push   %ebx
  801982:	e8 b0 fb ff ff       	call   801537 <umain>

	// exit gracefully
	exit();
  801987:	e8 0a 00 00 00       	call   801996 <exit>
}
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801992:	5b                   	pop    %ebx
  801993:	5e                   	pop    %esi
  801994:	5d                   	pop    %ebp
  801995:	c3                   	ret    

00801996 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
  801999:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80199c:	e8 98 0f 00 00       	call   802939 <close_all>
	sys_env_destroy(0);
  8019a1:	83 ec 0c             	sub    $0xc,%esp
  8019a4:	6a 00                	push   $0x0
  8019a6:	e8 e7 09 00 00       	call   802392 <sys_env_destroy>
}
  8019ab:	83 c4 10             	add    $0x10,%esp
  8019ae:	c9                   	leave  
  8019af:	c3                   	ret    

008019b0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	56                   	push   %esi
  8019b4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019b5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019b8:	8b 35 60 90 80 00    	mov    0x809060,%esi
  8019be:	e8 10 0a 00 00       	call   8023d3 <sys_getenvid>
  8019c3:	83 ec 0c             	sub    $0xc,%esp
  8019c6:	ff 75 0c             	pushl  0xc(%ebp)
  8019c9:	ff 75 08             	pushl  0x8(%ebp)
  8019cc:	56                   	push   %esi
  8019cd:	50                   	push   %eax
  8019ce:	68 10 3d 80 00       	push   $0x803d10
  8019d3:	e8 b1 00 00 00       	call   801a89 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019d8:	83 c4 18             	add    $0x18,%esp
  8019db:	53                   	push   %ebx
  8019dc:	ff 75 10             	pushl  0x10(%ebp)
  8019df:	e8 54 00 00 00       	call   801a38 <vcprintf>
	cprintf("\n");
  8019e4:	c7 04 24 f6 38 80 00 	movl   $0x8038f6,(%esp)
  8019eb:	e8 99 00 00 00       	call   801a89 <cprintf>
  8019f0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019f3:	cc                   	int3   
  8019f4:	eb fd                	jmp    8019f3 <_panic+0x43>

008019f6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	53                   	push   %ebx
  8019fa:	83 ec 04             	sub    $0x4,%esp
  8019fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801a00:	8b 13                	mov    (%ebx),%edx
  801a02:	8d 42 01             	lea    0x1(%edx),%eax
  801a05:	89 03                	mov    %eax,(%ebx)
  801a07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a0a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801a0e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801a13:	75 1a                	jne    801a2f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801a15:	83 ec 08             	sub    $0x8,%esp
  801a18:	68 ff 00 00 00       	push   $0xff
  801a1d:	8d 43 08             	lea    0x8(%ebx),%eax
  801a20:	50                   	push   %eax
  801a21:	e8 2f 09 00 00       	call   802355 <sys_cputs>
		b->idx = 0;
  801a26:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a2c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801a2f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801a33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a36:	c9                   	leave  
  801a37:	c3                   	ret    

00801a38 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801a41:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a48:	00 00 00 
	b.cnt = 0;
  801a4b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801a52:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801a55:	ff 75 0c             	pushl  0xc(%ebp)
  801a58:	ff 75 08             	pushl  0x8(%ebp)
  801a5b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801a61:	50                   	push   %eax
  801a62:	68 f6 19 80 00       	push   $0x8019f6
  801a67:	e8 54 01 00 00       	call   801bc0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801a6c:	83 c4 08             	add    $0x8,%esp
  801a6f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801a75:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801a7b:	50                   	push   %eax
  801a7c:	e8 d4 08 00 00       	call   802355 <sys_cputs>

	return b.cnt;
}
  801a81:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801a87:	c9                   	leave  
  801a88:	c3                   	ret    

00801a89 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a8f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801a92:	50                   	push   %eax
  801a93:	ff 75 08             	pushl  0x8(%ebp)
  801a96:	e8 9d ff ff ff       	call   801a38 <vcprintf>
	va_end(ap);

	return cnt;
}
  801a9b:	c9                   	leave  
  801a9c:	c3                   	ret    

00801a9d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	57                   	push   %edi
  801aa1:	56                   	push   %esi
  801aa2:	53                   	push   %ebx
  801aa3:	83 ec 1c             	sub    $0x1c,%esp
  801aa6:	89 c7                	mov    %eax,%edi
  801aa8:	89 d6                	mov    %edx,%esi
  801aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  801aad:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ab0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801ab3:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801ab6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801ab9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801abe:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801ac1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801ac4:	39 d3                	cmp    %edx,%ebx
  801ac6:	72 05                	jb     801acd <printnum+0x30>
  801ac8:	39 45 10             	cmp    %eax,0x10(%ebp)
  801acb:	77 45                	ja     801b12 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801acd:	83 ec 0c             	sub    $0xc,%esp
  801ad0:	ff 75 18             	pushl  0x18(%ebp)
  801ad3:	8b 45 14             	mov    0x14(%ebp),%eax
  801ad6:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801ad9:	53                   	push   %ebx
  801ada:	ff 75 10             	pushl  0x10(%ebp)
  801add:	83 ec 08             	sub    $0x8,%esp
  801ae0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ae3:	ff 75 e0             	pushl  -0x20(%ebp)
  801ae6:	ff 75 dc             	pushl  -0x24(%ebp)
  801ae9:	ff 75 d8             	pushl  -0x28(%ebp)
  801aec:	e8 cf 19 00 00       	call   8034c0 <__udivdi3>
  801af1:	83 c4 18             	add    $0x18,%esp
  801af4:	52                   	push   %edx
  801af5:	50                   	push   %eax
  801af6:	89 f2                	mov    %esi,%edx
  801af8:	89 f8                	mov    %edi,%eax
  801afa:	e8 9e ff ff ff       	call   801a9d <printnum>
  801aff:	83 c4 20             	add    $0x20,%esp
  801b02:	eb 18                	jmp    801b1c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801b04:	83 ec 08             	sub    $0x8,%esp
  801b07:	56                   	push   %esi
  801b08:	ff 75 18             	pushl  0x18(%ebp)
  801b0b:	ff d7                	call   *%edi
  801b0d:	83 c4 10             	add    $0x10,%esp
  801b10:	eb 03                	jmp    801b15 <printnum+0x78>
  801b12:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801b15:	83 eb 01             	sub    $0x1,%ebx
  801b18:	85 db                	test   %ebx,%ebx
  801b1a:	7f e8                	jg     801b04 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801b1c:	83 ec 08             	sub    $0x8,%esp
  801b1f:	56                   	push   %esi
  801b20:	83 ec 04             	sub    $0x4,%esp
  801b23:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b26:	ff 75 e0             	pushl  -0x20(%ebp)
  801b29:	ff 75 dc             	pushl  -0x24(%ebp)
  801b2c:	ff 75 d8             	pushl  -0x28(%ebp)
  801b2f:	e8 bc 1a 00 00       	call   8035f0 <__umoddi3>
  801b34:	83 c4 14             	add    $0x14,%esp
  801b37:	0f be 80 33 3d 80 00 	movsbl 0x803d33(%eax),%eax
  801b3e:	50                   	push   %eax
  801b3f:	ff d7                	call   *%edi
}
  801b41:	83 c4 10             	add    $0x10,%esp
  801b44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b47:	5b                   	pop    %ebx
  801b48:	5e                   	pop    %esi
  801b49:	5f                   	pop    %edi
  801b4a:	5d                   	pop    %ebp
  801b4b:	c3                   	ret    

00801b4c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801b4f:	83 fa 01             	cmp    $0x1,%edx
  801b52:	7e 0e                	jle    801b62 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801b54:	8b 10                	mov    (%eax),%edx
  801b56:	8d 4a 08             	lea    0x8(%edx),%ecx
  801b59:	89 08                	mov    %ecx,(%eax)
  801b5b:	8b 02                	mov    (%edx),%eax
  801b5d:	8b 52 04             	mov    0x4(%edx),%edx
  801b60:	eb 22                	jmp    801b84 <getuint+0x38>
	else if (lflag)
  801b62:	85 d2                	test   %edx,%edx
  801b64:	74 10                	je     801b76 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801b66:	8b 10                	mov    (%eax),%edx
  801b68:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b6b:	89 08                	mov    %ecx,(%eax)
  801b6d:	8b 02                	mov    (%edx),%eax
  801b6f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b74:	eb 0e                	jmp    801b84 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801b76:	8b 10                	mov    (%eax),%edx
  801b78:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b7b:	89 08                	mov    %ecx,(%eax)
  801b7d:	8b 02                	mov    (%edx),%eax
  801b7f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801b84:	5d                   	pop    %ebp
  801b85:	c3                   	ret    

00801b86 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801b8c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801b90:	8b 10                	mov    (%eax),%edx
  801b92:	3b 50 04             	cmp    0x4(%eax),%edx
  801b95:	73 0a                	jae    801ba1 <sprintputch+0x1b>
		*b->buf++ = ch;
  801b97:	8d 4a 01             	lea    0x1(%edx),%ecx
  801b9a:	89 08                	mov    %ecx,(%eax)
  801b9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9f:	88 02                	mov    %al,(%edx)
}
  801ba1:	5d                   	pop    %ebp
  801ba2:	c3                   	ret    

00801ba3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801ba9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801bac:	50                   	push   %eax
  801bad:	ff 75 10             	pushl  0x10(%ebp)
  801bb0:	ff 75 0c             	pushl  0xc(%ebp)
  801bb3:	ff 75 08             	pushl  0x8(%ebp)
  801bb6:	e8 05 00 00 00       	call   801bc0 <vprintfmt>
	va_end(ap);
}
  801bbb:	83 c4 10             	add    $0x10,%esp
  801bbe:	c9                   	leave  
  801bbf:	c3                   	ret    

00801bc0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	57                   	push   %edi
  801bc4:	56                   	push   %esi
  801bc5:	53                   	push   %ebx
  801bc6:	83 ec 2c             	sub    $0x2c,%esp
  801bc9:	8b 75 08             	mov    0x8(%ebp),%esi
  801bcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801bcf:	8b 7d 10             	mov    0x10(%ebp),%edi
  801bd2:	eb 12                	jmp    801be6 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	0f 84 89 03 00 00    	je     801f65 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801bdc:	83 ec 08             	sub    $0x8,%esp
  801bdf:	53                   	push   %ebx
  801be0:	50                   	push   %eax
  801be1:	ff d6                	call   *%esi
  801be3:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801be6:	83 c7 01             	add    $0x1,%edi
  801be9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801bed:	83 f8 25             	cmp    $0x25,%eax
  801bf0:	75 e2                	jne    801bd4 <vprintfmt+0x14>
  801bf2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801bf6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801bfd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801c04:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801c0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c10:	eb 07                	jmp    801c19 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c12:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801c15:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c19:	8d 47 01             	lea    0x1(%edi),%eax
  801c1c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c1f:	0f b6 07             	movzbl (%edi),%eax
  801c22:	0f b6 c8             	movzbl %al,%ecx
  801c25:	83 e8 23             	sub    $0x23,%eax
  801c28:	3c 55                	cmp    $0x55,%al
  801c2a:	0f 87 1a 03 00 00    	ja     801f4a <vprintfmt+0x38a>
  801c30:	0f b6 c0             	movzbl %al,%eax
  801c33:	ff 24 85 80 3e 80 00 	jmp    *0x803e80(,%eax,4)
  801c3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801c3d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801c41:	eb d6                	jmp    801c19 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c43:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c46:	b8 00 00 00 00       	mov    $0x0,%eax
  801c4b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801c4e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801c51:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801c55:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801c58:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801c5b:	83 fa 09             	cmp    $0x9,%edx
  801c5e:	77 39                	ja     801c99 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801c60:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801c63:	eb e9                	jmp    801c4e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801c65:	8b 45 14             	mov    0x14(%ebp),%eax
  801c68:	8d 48 04             	lea    0x4(%eax),%ecx
  801c6b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801c6e:	8b 00                	mov    (%eax),%eax
  801c70:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c73:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801c76:	eb 27                	jmp    801c9f <vprintfmt+0xdf>
  801c78:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c7b:	85 c0                	test   %eax,%eax
  801c7d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801c82:	0f 49 c8             	cmovns %eax,%ecx
  801c85:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c88:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c8b:	eb 8c                	jmp    801c19 <vprintfmt+0x59>
  801c8d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801c90:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801c97:	eb 80                	jmp    801c19 <vprintfmt+0x59>
  801c99:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801c9c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801c9f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801ca3:	0f 89 70 ff ff ff    	jns    801c19 <vprintfmt+0x59>
				width = precision, precision = -1;
  801ca9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801cac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801caf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801cb6:	e9 5e ff ff ff       	jmp    801c19 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801cbb:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cbe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801cc1:	e9 53 ff ff ff       	jmp    801c19 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801cc6:	8b 45 14             	mov    0x14(%ebp),%eax
  801cc9:	8d 50 04             	lea    0x4(%eax),%edx
  801ccc:	89 55 14             	mov    %edx,0x14(%ebp)
  801ccf:	83 ec 08             	sub    $0x8,%esp
  801cd2:	53                   	push   %ebx
  801cd3:	ff 30                	pushl  (%eax)
  801cd5:	ff d6                	call   *%esi
			break;
  801cd7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cda:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801cdd:	e9 04 ff ff ff       	jmp    801be6 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801ce2:	8b 45 14             	mov    0x14(%ebp),%eax
  801ce5:	8d 50 04             	lea    0x4(%eax),%edx
  801ce8:	89 55 14             	mov    %edx,0x14(%ebp)
  801ceb:	8b 00                	mov    (%eax),%eax
  801ced:	99                   	cltd   
  801cee:	31 d0                	xor    %edx,%eax
  801cf0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801cf2:	83 f8 0f             	cmp    $0xf,%eax
  801cf5:	7f 0b                	jg     801d02 <vprintfmt+0x142>
  801cf7:	8b 14 85 e0 3f 80 00 	mov    0x803fe0(,%eax,4),%edx
  801cfe:	85 d2                	test   %edx,%edx
  801d00:	75 18                	jne    801d1a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801d02:	50                   	push   %eax
  801d03:	68 4b 3d 80 00       	push   $0x803d4b
  801d08:	53                   	push   %ebx
  801d09:	56                   	push   %esi
  801d0a:	e8 94 fe ff ff       	call   801ba3 <printfmt>
  801d0f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d12:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801d15:	e9 cc fe ff ff       	jmp    801be6 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801d1a:	52                   	push   %edx
  801d1b:	68 af 37 80 00       	push   $0x8037af
  801d20:	53                   	push   %ebx
  801d21:	56                   	push   %esi
  801d22:	e8 7c fe ff ff       	call   801ba3 <printfmt>
  801d27:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d2a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d2d:	e9 b4 fe ff ff       	jmp    801be6 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801d32:	8b 45 14             	mov    0x14(%ebp),%eax
  801d35:	8d 50 04             	lea    0x4(%eax),%edx
  801d38:	89 55 14             	mov    %edx,0x14(%ebp)
  801d3b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801d3d:	85 ff                	test   %edi,%edi
  801d3f:	b8 44 3d 80 00       	mov    $0x803d44,%eax
  801d44:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801d47:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801d4b:	0f 8e 94 00 00 00    	jle    801de5 <vprintfmt+0x225>
  801d51:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801d55:	0f 84 98 00 00 00    	je     801df3 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801d5b:	83 ec 08             	sub    $0x8,%esp
  801d5e:	ff 75 d0             	pushl  -0x30(%ebp)
  801d61:	57                   	push   %edi
  801d62:	e8 86 02 00 00       	call   801fed <strnlen>
  801d67:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801d6a:	29 c1                	sub    %eax,%ecx
  801d6c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801d6f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801d72:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801d76:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d79:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801d7c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d7e:	eb 0f                	jmp    801d8f <vprintfmt+0x1cf>
					putch(padc, putdat);
  801d80:	83 ec 08             	sub    $0x8,%esp
  801d83:	53                   	push   %ebx
  801d84:	ff 75 e0             	pushl  -0x20(%ebp)
  801d87:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d89:	83 ef 01             	sub    $0x1,%edi
  801d8c:	83 c4 10             	add    $0x10,%esp
  801d8f:	85 ff                	test   %edi,%edi
  801d91:	7f ed                	jg     801d80 <vprintfmt+0x1c0>
  801d93:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801d96:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801d99:	85 c9                	test   %ecx,%ecx
  801d9b:	b8 00 00 00 00       	mov    $0x0,%eax
  801da0:	0f 49 c1             	cmovns %ecx,%eax
  801da3:	29 c1                	sub    %eax,%ecx
  801da5:	89 75 08             	mov    %esi,0x8(%ebp)
  801da8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801dab:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801dae:	89 cb                	mov    %ecx,%ebx
  801db0:	eb 4d                	jmp    801dff <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801db2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801db6:	74 1b                	je     801dd3 <vprintfmt+0x213>
  801db8:	0f be c0             	movsbl %al,%eax
  801dbb:	83 e8 20             	sub    $0x20,%eax
  801dbe:	83 f8 5e             	cmp    $0x5e,%eax
  801dc1:	76 10                	jbe    801dd3 <vprintfmt+0x213>
					putch('?', putdat);
  801dc3:	83 ec 08             	sub    $0x8,%esp
  801dc6:	ff 75 0c             	pushl  0xc(%ebp)
  801dc9:	6a 3f                	push   $0x3f
  801dcb:	ff 55 08             	call   *0x8(%ebp)
  801dce:	83 c4 10             	add    $0x10,%esp
  801dd1:	eb 0d                	jmp    801de0 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801dd3:	83 ec 08             	sub    $0x8,%esp
  801dd6:	ff 75 0c             	pushl  0xc(%ebp)
  801dd9:	52                   	push   %edx
  801dda:	ff 55 08             	call   *0x8(%ebp)
  801ddd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801de0:	83 eb 01             	sub    $0x1,%ebx
  801de3:	eb 1a                	jmp    801dff <vprintfmt+0x23f>
  801de5:	89 75 08             	mov    %esi,0x8(%ebp)
  801de8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801deb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801dee:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801df1:	eb 0c                	jmp    801dff <vprintfmt+0x23f>
  801df3:	89 75 08             	mov    %esi,0x8(%ebp)
  801df6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801df9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801dfc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801dff:	83 c7 01             	add    $0x1,%edi
  801e02:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801e06:	0f be d0             	movsbl %al,%edx
  801e09:	85 d2                	test   %edx,%edx
  801e0b:	74 23                	je     801e30 <vprintfmt+0x270>
  801e0d:	85 f6                	test   %esi,%esi
  801e0f:	78 a1                	js     801db2 <vprintfmt+0x1f2>
  801e11:	83 ee 01             	sub    $0x1,%esi
  801e14:	79 9c                	jns    801db2 <vprintfmt+0x1f2>
  801e16:	89 df                	mov    %ebx,%edi
  801e18:	8b 75 08             	mov    0x8(%ebp),%esi
  801e1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e1e:	eb 18                	jmp    801e38 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801e20:	83 ec 08             	sub    $0x8,%esp
  801e23:	53                   	push   %ebx
  801e24:	6a 20                	push   $0x20
  801e26:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801e28:	83 ef 01             	sub    $0x1,%edi
  801e2b:	83 c4 10             	add    $0x10,%esp
  801e2e:	eb 08                	jmp    801e38 <vprintfmt+0x278>
  801e30:	89 df                	mov    %ebx,%edi
  801e32:	8b 75 08             	mov    0x8(%ebp),%esi
  801e35:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e38:	85 ff                	test   %edi,%edi
  801e3a:	7f e4                	jg     801e20 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e3c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e3f:	e9 a2 fd ff ff       	jmp    801be6 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801e44:	83 fa 01             	cmp    $0x1,%edx
  801e47:	7e 16                	jle    801e5f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801e49:	8b 45 14             	mov    0x14(%ebp),%eax
  801e4c:	8d 50 08             	lea    0x8(%eax),%edx
  801e4f:	89 55 14             	mov    %edx,0x14(%ebp)
  801e52:	8b 50 04             	mov    0x4(%eax),%edx
  801e55:	8b 00                	mov    (%eax),%eax
  801e57:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e5a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801e5d:	eb 32                	jmp    801e91 <vprintfmt+0x2d1>
	else if (lflag)
  801e5f:	85 d2                	test   %edx,%edx
  801e61:	74 18                	je     801e7b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801e63:	8b 45 14             	mov    0x14(%ebp),%eax
  801e66:	8d 50 04             	lea    0x4(%eax),%edx
  801e69:	89 55 14             	mov    %edx,0x14(%ebp)
  801e6c:	8b 00                	mov    (%eax),%eax
  801e6e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e71:	89 c1                	mov    %eax,%ecx
  801e73:	c1 f9 1f             	sar    $0x1f,%ecx
  801e76:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801e79:	eb 16                	jmp    801e91 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801e7b:	8b 45 14             	mov    0x14(%ebp),%eax
  801e7e:	8d 50 04             	lea    0x4(%eax),%edx
  801e81:	89 55 14             	mov    %edx,0x14(%ebp)
  801e84:	8b 00                	mov    (%eax),%eax
  801e86:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e89:	89 c1                	mov    %eax,%ecx
  801e8b:	c1 f9 1f             	sar    $0x1f,%ecx
  801e8e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801e91:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801e94:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801e97:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801e9c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801ea0:	79 74                	jns    801f16 <vprintfmt+0x356>
				putch('-', putdat);
  801ea2:	83 ec 08             	sub    $0x8,%esp
  801ea5:	53                   	push   %ebx
  801ea6:	6a 2d                	push   $0x2d
  801ea8:	ff d6                	call   *%esi
				num = -(long long) num;
  801eaa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ead:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801eb0:	f7 d8                	neg    %eax
  801eb2:	83 d2 00             	adc    $0x0,%edx
  801eb5:	f7 da                	neg    %edx
  801eb7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801eba:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801ebf:	eb 55                	jmp    801f16 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801ec1:	8d 45 14             	lea    0x14(%ebp),%eax
  801ec4:	e8 83 fc ff ff       	call   801b4c <getuint>
			base = 10;
  801ec9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801ece:	eb 46                	jmp    801f16 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801ed0:	8d 45 14             	lea    0x14(%ebp),%eax
  801ed3:	e8 74 fc ff ff       	call   801b4c <getuint>
                        base = 8;
  801ed8:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801edd:	eb 37                	jmp    801f16 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801edf:	83 ec 08             	sub    $0x8,%esp
  801ee2:	53                   	push   %ebx
  801ee3:	6a 30                	push   $0x30
  801ee5:	ff d6                	call   *%esi
			putch('x', putdat);
  801ee7:	83 c4 08             	add    $0x8,%esp
  801eea:	53                   	push   %ebx
  801eeb:	6a 78                	push   $0x78
  801eed:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801eef:	8b 45 14             	mov    0x14(%ebp),%eax
  801ef2:	8d 50 04             	lea    0x4(%eax),%edx
  801ef5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801ef8:	8b 00                	mov    (%eax),%eax
  801efa:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801eff:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801f02:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801f07:	eb 0d                	jmp    801f16 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801f09:	8d 45 14             	lea    0x14(%ebp),%eax
  801f0c:	e8 3b fc ff ff       	call   801b4c <getuint>
			base = 16;
  801f11:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801f16:	83 ec 0c             	sub    $0xc,%esp
  801f19:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801f1d:	57                   	push   %edi
  801f1e:	ff 75 e0             	pushl  -0x20(%ebp)
  801f21:	51                   	push   %ecx
  801f22:	52                   	push   %edx
  801f23:	50                   	push   %eax
  801f24:	89 da                	mov    %ebx,%edx
  801f26:	89 f0                	mov    %esi,%eax
  801f28:	e8 70 fb ff ff       	call   801a9d <printnum>
			break;
  801f2d:	83 c4 20             	add    $0x20,%esp
  801f30:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f33:	e9 ae fc ff ff       	jmp    801be6 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801f38:	83 ec 08             	sub    $0x8,%esp
  801f3b:	53                   	push   %ebx
  801f3c:	51                   	push   %ecx
  801f3d:	ff d6                	call   *%esi
			break;
  801f3f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f42:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801f45:	e9 9c fc ff ff       	jmp    801be6 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801f4a:	83 ec 08             	sub    $0x8,%esp
  801f4d:	53                   	push   %ebx
  801f4e:	6a 25                	push   $0x25
  801f50:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801f52:	83 c4 10             	add    $0x10,%esp
  801f55:	eb 03                	jmp    801f5a <vprintfmt+0x39a>
  801f57:	83 ef 01             	sub    $0x1,%edi
  801f5a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801f5e:	75 f7                	jne    801f57 <vprintfmt+0x397>
  801f60:	e9 81 fc ff ff       	jmp    801be6 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801f65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f68:	5b                   	pop    %ebx
  801f69:	5e                   	pop    %esi
  801f6a:	5f                   	pop    %edi
  801f6b:	5d                   	pop    %ebp
  801f6c:	c3                   	ret    

00801f6d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801f6d:	55                   	push   %ebp
  801f6e:	89 e5                	mov    %esp,%ebp
  801f70:	83 ec 18             	sub    $0x18,%esp
  801f73:	8b 45 08             	mov    0x8(%ebp),%eax
  801f76:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801f79:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f7c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801f80:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801f83:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801f8a:	85 c0                	test   %eax,%eax
  801f8c:	74 26                	je     801fb4 <vsnprintf+0x47>
  801f8e:	85 d2                	test   %edx,%edx
  801f90:	7e 22                	jle    801fb4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801f92:	ff 75 14             	pushl  0x14(%ebp)
  801f95:	ff 75 10             	pushl  0x10(%ebp)
  801f98:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801f9b:	50                   	push   %eax
  801f9c:	68 86 1b 80 00       	push   $0x801b86
  801fa1:	e8 1a fc ff ff       	call   801bc0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801fa6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801fa9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801faf:	83 c4 10             	add    $0x10,%esp
  801fb2:	eb 05                	jmp    801fb9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801fb4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801fb9:	c9                   	leave  
  801fba:	c3                   	ret    

00801fbb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801fbb:	55                   	push   %ebp
  801fbc:	89 e5                	mov    %esp,%ebp
  801fbe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801fc1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801fc4:	50                   	push   %eax
  801fc5:	ff 75 10             	pushl  0x10(%ebp)
  801fc8:	ff 75 0c             	pushl  0xc(%ebp)
  801fcb:	ff 75 08             	pushl  0x8(%ebp)
  801fce:	e8 9a ff ff ff       	call   801f6d <vsnprintf>
	va_end(ap);

	return rc;
}
  801fd3:	c9                   	leave  
  801fd4:	c3                   	ret    

00801fd5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801fd5:	55                   	push   %ebp
  801fd6:	89 e5                	mov    %esp,%ebp
  801fd8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801fdb:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe0:	eb 03                	jmp    801fe5 <strlen+0x10>
		n++;
  801fe2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801fe5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801fe9:	75 f7                	jne    801fe2 <strlen+0xd>
		n++;
	return n;
}
  801feb:	5d                   	pop    %ebp
  801fec:	c3                   	ret    

00801fed <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801fed:	55                   	push   %ebp
  801fee:	89 e5                	mov    %esp,%ebp
  801ff0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ff3:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ff6:	ba 00 00 00 00       	mov    $0x0,%edx
  801ffb:	eb 03                	jmp    802000 <strnlen+0x13>
		n++;
  801ffd:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802000:	39 c2                	cmp    %eax,%edx
  802002:	74 08                	je     80200c <strnlen+0x1f>
  802004:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  802008:	75 f3                	jne    801ffd <strnlen+0x10>
  80200a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80200c:	5d                   	pop    %ebp
  80200d:	c3                   	ret    

0080200e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80200e:	55                   	push   %ebp
  80200f:	89 e5                	mov    %esp,%ebp
  802011:	53                   	push   %ebx
  802012:	8b 45 08             	mov    0x8(%ebp),%eax
  802015:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  802018:	89 c2                	mov    %eax,%edx
  80201a:	83 c2 01             	add    $0x1,%edx
  80201d:	83 c1 01             	add    $0x1,%ecx
  802020:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  802024:	88 5a ff             	mov    %bl,-0x1(%edx)
  802027:	84 db                	test   %bl,%bl
  802029:	75 ef                	jne    80201a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80202b:	5b                   	pop    %ebx
  80202c:	5d                   	pop    %ebp
  80202d:	c3                   	ret    

0080202e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80202e:	55                   	push   %ebp
  80202f:	89 e5                	mov    %esp,%ebp
  802031:	53                   	push   %ebx
  802032:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  802035:	53                   	push   %ebx
  802036:	e8 9a ff ff ff       	call   801fd5 <strlen>
  80203b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80203e:	ff 75 0c             	pushl  0xc(%ebp)
  802041:	01 d8                	add    %ebx,%eax
  802043:	50                   	push   %eax
  802044:	e8 c5 ff ff ff       	call   80200e <strcpy>
	return dst;
}
  802049:	89 d8                	mov    %ebx,%eax
  80204b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80204e:	c9                   	leave  
  80204f:	c3                   	ret    

00802050 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	56                   	push   %esi
  802054:	53                   	push   %ebx
  802055:	8b 75 08             	mov    0x8(%ebp),%esi
  802058:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80205b:	89 f3                	mov    %esi,%ebx
  80205d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802060:	89 f2                	mov    %esi,%edx
  802062:	eb 0f                	jmp    802073 <strncpy+0x23>
		*dst++ = *src;
  802064:	83 c2 01             	add    $0x1,%edx
  802067:	0f b6 01             	movzbl (%ecx),%eax
  80206a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80206d:	80 39 01             	cmpb   $0x1,(%ecx)
  802070:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802073:	39 da                	cmp    %ebx,%edx
  802075:	75 ed                	jne    802064 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  802077:	89 f0                	mov    %esi,%eax
  802079:	5b                   	pop    %ebx
  80207a:	5e                   	pop    %esi
  80207b:	5d                   	pop    %ebp
  80207c:	c3                   	ret    

0080207d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80207d:	55                   	push   %ebp
  80207e:	89 e5                	mov    %esp,%ebp
  802080:	56                   	push   %esi
  802081:	53                   	push   %ebx
  802082:	8b 75 08             	mov    0x8(%ebp),%esi
  802085:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802088:	8b 55 10             	mov    0x10(%ebp),%edx
  80208b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80208d:	85 d2                	test   %edx,%edx
  80208f:	74 21                	je     8020b2 <strlcpy+0x35>
  802091:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  802095:	89 f2                	mov    %esi,%edx
  802097:	eb 09                	jmp    8020a2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  802099:	83 c2 01             	add    $0x1,%edx
  80209c:	83 c1 01             	add    $0x1,%ecx
  80209f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8020a2:	39 c2                	cmp    %eax,%edx
  8020a4:	74 09                	je     8020af <strlcpy+0x32>
  8020a6:	0f b6 19             	movzbl (%ecx),%ebx
  8020a9:	84 db                	test   %bl,%bl
  8020ab:	75 ec                	jne    802099 <strlcpy+0x1c>
  8020ad:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8020af:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8020b2:	29 f0                	sub    %esi,%eax
}
  8020b4:	5b                   	pop    %ebx
  8020b5:	5e                   	pop    %esi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    

008020b8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8020b8:	55                   	push   %ebp
  8020b9:	89 e5                	mov    %esp,%ebp
  8020bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020be:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8020c1:	eb 06                	jmp    8020c9 <strcmp+0x11>
		p++, q++;
  8020c3:	83 c1 01             	add    $0x1,%ecx
  8020c6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8020c9:	0f b6 01             	movzbl (%ecx),%eax
  8020cc:	84 c0                	test   %al,%al
  8020ce:	74 04                	je     8020d4 <strcmp+0x1c>
  8020d0:	3a 02                	cmp    (%edx),%al
  8020d2:	74 ef                	je     8020c3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8020d4:	0f b6 c0             	movzbl %al,%eax
  8020d7:	0f b6 12             	movzbl (%edx),%edx
  8020da:	29 d0                	sub    %edx,%eax
}
  8020dc:	5d                   	pop    %ebp
  8020dd:	c3                   	ret    

008020de <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8020de:	55                   	push   %ebp
  8020df:	89 e5                	mov    %esp,%ebp
  8020e1:	53                   	push   %ebx
  8020e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020e8:	89 c3                	mov    %eax,%ebx
  8020ea:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8020ed:	eb 06                	jmp    8020f5 <strncmp+0x17>
		n--, p++, q++;
  8020ef:	83 c0 01             	add    $0x1,%eax
  8020f2:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8020f5:	39 d8                	cmp    %ebx,%eax
  8020f7:	74 15                	je     80210e <strncmp+0x30>
  8020f9:	0f b6 08             	movzbl (%eax),%ecx
  8020fc:	84 c9                	test   %cl,%cl
  8020fe:	74 04                	je     802104 <strncmp+0x26>
  802100:	3a 0a                	cmp    (%edx),%cl
  802102:	74 eb                	je     8020ef <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  802104:	0f b6 00             	movzbl (%eax),%eax
  802107:	0f b6 12             	movzbl (%edx),%edx
  80210a:	29 d0                	sub    %edx,%eax
  80210c:	eb 05                	jmp    802113 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80210e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  802113:	5b                   	pop    %ebx
  802114:	5d                   	pop    %ebp
  802115:	c3                   	ret    

00802116 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  802116:	55                   	push   %ebp
  802117:	89 e5                	mov    %esp,%ebp
  802119:	8b 45 08             	mov    0x8(%ebp),%eax
  80211c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802120:	eb 07                	jmp    802129 <strchr+0x13>
		if (*s == c)
  802122:	38 ca                	cmp    %cl,%dl
  802124:	74 0f                	je     802135 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  802126:	83 c0 01             	add    $0x1,%eax
  802129:	0f b6 10             	movzbl (%eax),%edx
  80212c:	84 d2                	test   %dl,%dl
  80212e:	75 f2                	jne    802122 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  802130:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802135:	5d                   	pop    %ebp
  802136:	c3                   	ret    

00802137 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  802137:	55                   	push   %ebp
  802138:	89 e5                	mov    %esp,%ebp
  80213a:	8b 45 08             	mov    0x8(%ebp),%eax
  80213d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802141:	eb 03                	jmp    802146 <strfind+0xf>
  802143:	83 c0 01             	add    $0x1,%eax
  802146:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  802149:	38 ca                	cmp    %cl,%dl
  80214b:	74 04                	je     802151 <strfind+0x1a>
  80214d:	84 d2                	test   %dl,%dl
  80214f:	75 f2                	jne    802143 <strfind+0xc>
			break;
	return (char *) s;
}
  802151:	5d                   	pop    %ebp
  802152:	c3                   	ret    

00802153 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802153:	55                   	push   %ebp
  802154:	89 e5                	mov    %esp,%ebp
  802156:	57                   	push   %edi
  802157:	56                   	push   %esi
  802158:	53                   	push   %ebx
  802159:	8b 7d 08             	mov    0x8(%ebp),%edi
  80215c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80215f:	85 c9                	test   %ecx,%ecx
  802161:	74 36                	je     802199 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802163:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802169:	75 28                	jne    802193 <memset+0x40>
  80216b:	f6 c1 03             	test   $0x3,%cl
  80216e:	75 23                	jne    802193 <memset+0x40>
		c &= 0xFF;
  802170:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802174:	89 d3                	mov    %edx,%ebx
  802176:	c1 e3 08             	shl    $0x8,%ebx
  802179:	89 d6                	mov    %edx,%esi
  80217b:	c1 e6 18             	shl    $0x18,%esi
  80217e:	89 d0                	mov    %edx,%eax
  802180:	c1 e0 10             	shl    $0x10,%eax
  802183:	09 f0                	or     %esi,%eax
  802185:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  802187:	89 d8                	mov    %ebx,%eax
  802189:	09 d0                	or     %edx,%eax
  80218b:	c1 e9 02             	shr    $0x2,%ecx
  80218e:	fc                   	cld    
  80218f:	f3 ab                	rep stos %eax,%es:(%edi)
  802191:	eb 06                	jmp    802199 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802193:	8b 45 0c             	mov    0xc(%ebp),%eax
  802196:	fc                   	cld    
  802197:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802199:	89 f8                	mov    %edi,%eax
  80219b:	5b                   	pop    %ebx
  80219c:	5e                   	pop    %esi
  80219d:	5f                   	pop    %edi
  80219e:	5d                   	pop    %ebp
  80219f:	c3                   	ret    

008021a0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	57                   	push   %edi
  8021a4:	56                   	push   %esi
  8021a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8021ae:	39 c6                	cmp    %eax,%esi
  8021b0:	73 35                	jae    8021e7 <memmove+0x47>
  8021b2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8021b5:	39 d0                	cmp    %edx,%eax
  8021b7:	73 2e                	jae    8021e7 <memmove+0x47>
		s += n;
		d += n;
  8021b9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021bc:	89 d6                	mov    %edx,%esi
  8021be:	09 fe                	or     %edi,%esi
  8021c0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8021c6:	75 13                	jne    8021db <memmove+0x3b>
  8021c8:	f6 c1 03             	test   $0x3,%cl
  8021cb:	75 0e                	jne    8021db <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8021cd:	83 ef 04             	sub    $0x4,%edi
  8021d0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8021d3:	c1 e9 02             	shr    $0x2,%ecx
  8021d6:	fd                   	std    
  8021d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8021d9:	eb 09                	jmp    8021e4 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8021db:	83 ef 01             	sub    $0x1,%edi
  8021de:	8d 72 ff             	lea    -0x1(%edx),%esi
  8021e1:	fd                   	std    
  8021e2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8021e4:	fc                   	cld    
  8021e5:	eb 1d                	jmp    802204 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021e7:	89 f2                	mov    %esi,%edx
  8021e9:	09 c2                	or     %eax,%edx
  8021eb:	f6 c2 03             	test   $0x3,%dl
  8021ee:	75 0f                	jne    8021ff <memmove+0x5f>
  8021f0:	f6 c1 03             	test   $0x3,%cl
  8021f3:	75 0a                	jne    8021ff <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8021f5:	c1 e9 02             	shr    $0x2,%ecx
  8021f8:	89 c7                	mov    %eax,%edi
  8021fa:	fc                   	cld    
  8021fb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8021fd:	eb 05                	jmp    802204 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8021ff:	89 c7                	mov    %eax,%edi
  802201:	fc                   	cld    
  802202:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802204:	5e                   	pop    %esi
  802205:	5f                   	pop    %edi
  802206:	5d                   	pop    %ebp
  802207:	c3                   	ret    

00802208 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  802208:	55                   	push   %ebp
  802209:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80220b:	ff 75 10             	pushl  0x10(%ebp)
  80220e:	ff 75 0c             	pushl  0xc(%ebp)
  802211:	ff 75 08             	pushl  0x8(%ebp)
  802214:	e8 87 ff ff ff       	call   8021a0 <memmove>
}
  802219:	c9                   	leave  
  80221a:	c3                   	ret    

0080221b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80221b:	55                   	push   %ebp
  80221c:	89 e5                	mov    %esp,%ebp
  80221e:	56                   	push   %esi
  80221f:	53                   	push   %ebx
  802220:	8b 45 08             	mov    0x8(%ebp),%eax
  802223:	8b 55 0c             	mov    0xc(%ebp),%edx
  802226:	89 c6                	mov    %eax,%esi
  802228:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80222b:	eb 1a                	jmp    802247 <memcmp+0x2c>
		if (*s1 != *s2)
  80222d:	0f b6 08             	movzbl (%eax),%ecx
  802230:	0f b6 1a             	movzbl (%edx),%ebx
  802233:	38 d9                	cmp    %bl,%cl
  802235:	74 0a                	je     802241 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  802237:	0f b6 c1             	movzbl %cl,%eax
  80223a:	0f b6 db             	movzbl %bl,%ebx
  80223d:	29 d8                	sub    %ebx,%eax
  80223f:	eb 0f                	jmp    802250 <memcmp+0x35>
		s1++, s2++;
  802241:	83 c0 01             	add    $0x1,%eax
  802244:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802247:	39 f0                	cmp    %esi,%eax
  802249:	75 e2                	jne    80222d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80224b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802250:	5b                   	pop    %ebx
  802251:	5e                   	pop    %esi
  802252:	5d                   	pop    %ebp
  802253:	c3                   	ret    

00802254 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802254:	55                   	push   %ebp
  802255:	89 e5                	mov    %esp,%ebp
  802257:	53                   	push   %ebx
  802258:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80225b:	89 c1                	mov    %eax,%ecx
  80225d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  802260:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802264:	eb 0a                	jmp    802270 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  802266:	0f b6 10             	movzbl (%eax),%edx
  802269:	39 da                	cmp    %ebx,%edx
  80226b:	74 07                	je     802274 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80226d:	83 c0 01             	add    $0x1,%eax
  802270:	39 c8                	cmp    %ecx,%eax
  802272:	72 f2                	jb     802266 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  802274:	5b                   	pop    %ebx
  802275:	5d                   	pop    %ebp
  802276:	c3                   	ret    

00802277 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802277:	55                   	push   %ebp
  802278:	89 e5                	mov    %esp,%ebp
  80227a:	57                   	push   %edi
  80227b:	56                   	push   %esi
  80227c:	53                   	push   %ebx
  80227d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802280:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802283:	eb 03                	jmp    802288 <strtol+0x11>
		s++;
  802285:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802288:	0f b6 01             	movzbl (%ecx),%eax
  80228b:	3c 20                	cmp    $0x20,%al
  80228d:	74 f6                	je     802285 <strtol+0xe>
  80228f:	3c 09                	cmp    $0x9,%al
  802291:	74 f2                	je     802285 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802293:	3c 2b                	cmp    $0x2b,%al
  802295:	75 0a                	jne    8022a1 <strtol+0x2a>
		s++;
  802297:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80229a:	bf 00 00 00 00       	mov    $0x0,%edi
  80229f:	eb 11                	jmp    8022b2 <strtol+0x3b>
  8022a1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8022a6:	3c 2d                	cmp    $0x2d,%al
  8022a8:	75 08                	jne    8022b2 <strtol+0x3b>
		s++, neg = 1;
  8022aa:	83 c1 01             	add    $0x1,%ecx
  8022ad:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8022b2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8022b8:	75 15                	jne    8022cf <strtol+0x58>
  8022ba:	80 39 30             	cmpb   $0x30,(%ecx)
  8022bd:	75 10                	jne    8022cf <strtol+0x58>
  8022bf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8022c3:	75 7c                	jne    802341 <strtol+0xca>
		s += 2, base = 16;
  8022c5:	83 c1 02             	add    $0x2,%ecx
  8022c8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8022cd:	eb 16                	jmp    8022e5 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8022cf:	85 db                	test   %ebx,%ebx
  8022d1:	75 12                	jne    8022e5 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8022d3:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8022d8:	80 39 30             	cmpb   $0x30,(%ecx)
  8022db:	75 08                	jne    8022e5 <strtol+0x6e>
		s++, base = 8;
  8022dd:	83 c1 01             	add    $0x1,%ecx
  8022e0:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8022e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8022ea:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8022ed:	0f b6 11             	movzbl (%ecx),%edx
  8022f0:	8d 72 d0             	lea    -0x30(%edx),%esi
  8022f3:	89 f3                	mov    %esi,%ebx
  8022f5:	80 fb 09             	cmp    $0x9,%bl
  8022f8:	77 08                	ja     802302 <strtol+0x8b>
			dig = *s - '0';
  8022fa:	0f be d2             	movsbl %dl,%edx
  8022fd:	83 ea 30             	sub    $0x30,%edx
  802300:	eb 22                	jmp    802324 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  802302:	8d 72 9f             	lea    -0x61(%edx),%esi
  802305:	89 f3                	mov    %esi,%ebx
  802307:	80 fb 19             	cmp    $0x19,%bl
  80230a:	77 08                	ja     802314 <strtol+0x9d>
			dig = *s - 'a' + 10;
  80230c:	0f be d2             	movsbl %dl,%edx
  80230f:	83 ea 57             	sub    $0x57,%edx
  802312:	eb 10                	jmp    802324 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  802314:	8d 72 bf             	lea    -0x41(%edx),%esi
  802317:	89 f3                	mov    %esi,%ebx
  802319:	80 fb 19             	cmp    $0x19,%bl
  80231c:	77 16                	ja     802334 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80231e:	0f be d2             	movsbl %dl,%edx
  802321:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  802324:	3b 55 10             	cmp    0x10(%ebp),%edx
  802327:	7d 0b                	jge    802334 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  802329:	83 c1 01             	add    $0x1,%ecx
  80232c:	0f af 45 10          	imul   0x10(%ebp),%eax
  802330:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  802332:	eb b9                	jmp    8022ed <strtol+0x76>

	if (endptr)
  802334:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802338:	74 0d                	je     802347 <strtol+0xd0>
		*endptr = (char *) s;
  80233a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80233d:	89 0e                	mov    %ecx,(%esi)
  80233f:	eb 06                	jmp    802347 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802341:	85 db                	test   %ebx,%ebx
  802343:	74 98                	je     8022dd <strtol+0x66>
  802345:	eb 9e                	jmp    8022e5 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  802347:	89 c2                	mov    %eax,%edx
  802349:	f7 da                	neg    %edx
  80234b:	85 ff                	test   %edi,%edi
  80234d:	0f 45 c2             	cmovne %edx,%eax
}
  802350:	5b                   	pop    %ebx
  802351:	5e                   	pop    %esi
  802352:	5f                   	pop    %edi
  802353:	5d                   	pop    %ebp
  802354:	c3                   	ret    

00802355 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802355:	55                   	push   %ebp
  802356:	89 e5                	mov    %esp,%ebp
  802358:	57                   	push   %edi
  802359:	56                   	push   %esi
  80235a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80235b:	b8 00 00 00 00       	mov    $0x0,%eax
  802360:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802363:	8b 55 08             	mov    0x8(%ebp),%edx
  802366:	89 c3                	mov    %eax,%ebx
  802368:	89 c7                	mov    %eax,%edi
  80236a:	89 c6                	mov    %eax,%esi
  80236c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80236e:	5b                   	pop    %ebx
  80236f:	5e                   	pop    %esi
  802370:	5f                   	pop    %edi
  802371:	5d                   	pop    %ebp
  802372:	c3                   	ret    

00802373 <sys_cgetc>:

int
sys_cgetc(void)
{
  802373:	55                   	push   %ebp
  802374:	89 e5                	mov    %esp,%ebp
  802376:	57                   	push   %edi
  802377:	56                   	push   %esi
  802378:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802379:	ba 00 00 00 00       	mov    $0x0,%edx
  80237e:	b8 01 00 00 00       	mov    $0x1,%eax
  802383:	89 d1                	mov    %edx,%ecx
  802385:	89 d3                	mov    %edx,%ebx
  802387:	89 d7                	mov    %edx,%edi
  802389:	89 d6                	mov    %edx,%esi
  80238b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80238d:	5b                   	pop    %ebx
  80238e:	5e                   	pop    %esi
  80238f:	5f                   	pop    %edi
  802390:	5d                   	pop    %ebp
  802391:	c3                   	ret    

00802392 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802392:	55                   	push   %ebp
  802393:	89 e5                	mov    %esp,%ebp
  802395:	57                   	push   %edi
  802396:	56                   	push   %esi
  802397:	53                   	push   %ebx
  802398:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80239b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8023a0:	b8 03 00 00 00       	mov    $0x3,%eax
  8023a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8023a8:	89 cb                	mov    %ecx,%ebx
  8023aa:	89 cf                	mov    %ecx,%edi
  8023ac:	89 ce                	mov    %ecx,%esi
  8023ae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8023b0:	85 c0                	test   %eax,%eax
  8023b2:	7e 17                	jle    8023cb <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8023b4:	83 ec 0c             	sub    $0xc,%esp
  8023b7:	50                   	push   %eax
  8023b8:	6a 03                	push   $0x3
  8023ba:	68 3f 40 80 00       	push   $0x80403f
  8023bf:	6a 23                	push   $0x23
  8023c1:	68 5c 40 80 00       	push   $0x80405c
  8023c6:	e8 e5 f5 ff ff       	call   8019b0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8023cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023ce:	5b                   	pop    %ebx
  8023cf:	5e                   	pop    %esi
  8023d0:	5f                   	pop    %edi
  8023d1:	5d                   	pop    %ebp
  8023d2:	c3                   	ret    

008023d3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8023d3:	55                   	push   %ebp
  8023d4:	89 e5                	mov    %esp,%ebp
  8023d6:	57                   	push   %edi
  8023d7:	56                   	push   %esi
  8023d8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8023de:	b8 02 00 00 00       	mov    $0x2,%eax
  8023e3:	89 d1                	mov    %edx,%ecx
  8023e5:	89 d3                	mov    %edx,%ebx
  8023e7:	89 d7                	mov    %edx,%edi
  8023e9:	89 d6                	mov    %edx,%esi
  8023eb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8023ed:	5b                   	pop    %ebx
  8023ee:	5e                   	pop    %esi
  8023ef:	5f                   	pop    %edi
  8023f0:	5d                   	pop    %ebp
  8023f1:	c3                   	ret    

008023f2 <sys_yield>:

void
sys_yield(void)
{
  8023f2:	55                   	push   %ebp
  8023f3:	89 e5                	mov    %esp,%ebp
  8023f5:	57                   	push   %edi
  8023f6:	56                   	push   %esi
  8023f7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8023fd:	b8 0b 00 00 00       	mov    $0xb,%eax
  802402:	89 d1                	mov    %edx,%ecx
  802404:	89 d3                	mov    %edx,%ebx
  802406:	89 d7                	mov    %edx,%edi
  802408:	89 d6                	mov    %edx,%esi
  80240a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80240c:	5b                   	pop    %ebx
  80240d:	5e                   	pop    %esi
  80240e:	5f                   	pop    %edi
  80240f:	5d                   	pop    %ebp
  802410:	c3                   	ret    

00802411 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802411:	55                   	push   %ebp
  802412:	89 e5                	mov    %esp,%ebp
  802414:	57                   	push   %edi
  802415:	56                   	push   %esi
  802416:	53                   	push   %ebx
  802417:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80241a:	be 00 00 00 00       	mov    $0x0,%esi
  80241f:	b8 04 00 00 00       	mov    $0x4,%eax
  802424:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802427:	8b 55 08             	mov    0x8(%ebp),%edx
  80242a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80242d:	89 f7                	mov    %esi,%edi
  80242f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802431:	85 c0                	test   %eax,%eax
  802433:	7e 17                	jle    80244c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802435:	83 ec 0c             	sub    $0xc,%esp
  802438:	50                   	push   %eax
  802439:	6a 04                	push   $0x4
  80243b:	68 3f 40 80 00       	push   $0x80403f
  802440:	6a 23                	push   $0x23
  802442:	68 5c 40 80 00       	push   $0x80405c
  802447:	e8 64 f5 ff ff       	call   8019b0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80244c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80244f:	5b                   	pop    %ebx
  802450:	5e                   	pop    %esi
  802451:	5f                   	pop    %edi
  802452:	5d                   	pop    %ebp
  802453:	c3                   	ret    

00802454 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802454:	55                   	push   %ebp
  802455:	89 e5                	mov    %esp,%ebp
  802457:	57                   	push   %edi
  802458:	56                   	push   %esi
  802459:	53                   	push   %ebx
  80245a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80245d:	b8 05 00 00 00       	mov    $0x5,%eax
  802462:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802465:	8b 55 08             	mov    0x8(%ebp),%edx
  802468:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80246b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80246e:	8b 75 18             	mov    0x18(%ebp),%esi
  802471:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802473:	85 c0                	test   %eax,%eax
  802475:	7e 17                	jle    80248e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802477:	83 ec 0c             	sub    $0xc,%esp
  80247a:	50                   	push   %eax
  80247b:	6a 05                	push   $0x5
  80247d:	68 3f 40 80 00       	push   $0x80403f
  802482:	6a 23                	push   $0x23
  802484:	68 5c 40 80 00       	push   $0x80405c
  802489:	e8 22 f5 ff ff       	call   8019b0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80248e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802491:	5b                   	pop    %ebx
  802492:	5e                   	pop    %esi
  802493:	5f                   	pop    %edi
  802494:	5d                   	pop    %ebp
  802495:	c3                   	ret    

00802496 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802496:	55                   	push   %ebp
  802497:	89 e5                	mov    %esp,%ebp
  802499:	57                   	push   %edi
  80249a:	56                   	push   %esi
  80249b:	53                   	push   %ebx
  80249c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80249f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024a4:	b8 06 00 00 00       	mov    $0x6,%eax
  8024a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8024af:	89 df                	mov    %ebx,%edi
  8024b1:	89 de                	mov    %ebx,%esi
  8024b3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8024b5:	85 c0                	test   %eax,%eax
  8024b7:	7e 17                	jle    8024d0 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024b9:	83 ec 0c             	sub    $0xc,%esp
  8024bc:	50                   	push   %eax
  8024bd:	6a 06                	push   $0x6
  8024bf:	68 3f 40 80 00       	push   $0x80403f
  8024c4:	6a 23                	push   $0x23
  8024c6:	68 5c 40 80 00       	push   $0x80405c
  8024cb:	e8 e0 f4 ff ff       	call   8019b0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8024d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024d3:	5b                   	pop    %ebx
  8024d4:	5e                   	pop    %esi
  8024d5:	5f                   	pop    %edi
  8024d6:	5d                   	pop    %ebp
  8024d7:	c3                   	ret    

008024d8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8024d8:	55                   	push   %ebp
  8024d9:	89 e5                	mov    %esp,%ebp
  8024db:	57                   	push   %edi
  8024dc:	56                   	push   %esi
  8024dd:	53                   	push   %ebx
  8024de:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024e6:	b8 08 00 00 00       	mov    $0x8,%eax
  8024eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8024f1:	89 df                	mov    %ebx,%edi
  8024f3:	89 de                	mov    %ebx,%esi
  8024f5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8024f7:	85 c0                	test   %eax,%eax
  8024f9:	7e 17                	jle    802512 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024fb:	83 ec 0c             	sub    $0xc,%esp
  8024fe:	50                   	push   %eax
  8024ff:	6a 08                	push   $0x8
  802501:	68 3f 40 80 00       	push   $0x80403f
  802506:	6a 23                	push   $0x23
  802508:	68 5c 40 80 00       	push   $0x80405c
  80250d:	e8 9e f4 ff ff       	call   8019b0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802512:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802515:	5b                   	pop    %ebx
  802516:	5e                   	pop    %esi
  802517:	5f                   	pop    %edi
  802518:	5d                   	pop    %ebp
  802519:	c3                   	ret    

0080251a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80251a:	55                   	push   %ebp
  80251b:	89 e5                	mov    %esp,%ebp
  80251d:	57                   	push   %edi
  80251e:	56                   	push   %esi
  80251f:	53                   	push   %ebx
  802520:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802523:	bb 00 00 00 00       	mov    $0x0,%ebx
  802528:	b8 09 00 00 00       	mov    $0x9,%eax
  80252d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802530:	8b 55 08             	mov    0x8(%ebp),%edx
  802533:	89 df                	mov    %ebx,%edi
  802535:	89 de                	mov    %ebx,%esi
  802537:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802539:	85 c0                	test   %eax,%eax
  80253b:	7e 17                	jle    802554 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80253d:	83 ec 0c             	sub    $0xc,%esp
  802540:	50                   	push   %eax
  802541:	6a 09                	push   $0x9
  802543:	68 3f 40 80 00       	push   $0x80403f
  802548:	6a 23                	push   $0x23
  80254a:	68 5c 40 80 00       	push   $0x80405c
  80254f:	e8 5c f4 ff ff       	call   8019b0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802554:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802557:	5b                   	pop    %ebx
  802558:	5e                   	pop    %esi
  802559:	5f                   	pop    %edi
  80255a:	5d                   	pop    %ebp
  80255b:	c3                   	ret    

0080255c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80255c:	55                   	push   %ebp
  80255d:	89 e5                	mov    %esp,%ebp
  80255f:	57                   	push   %edi
  802560:	56                   	push   %esi
  802561:	53                   	push   %ebx
  802562:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802565:	bb 00 00 00 00       	mov    $0x0,%ebx
  80256a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80256f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802572:	8b 55 08             	mov    0x8(%ebp),%edx
  802575:	89 df                	mov    %ebx,%edi
  802577:	89 de                	mov    %ebx,%esi
  802579:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80257b:	85 c0                	test   %eax,%eax
  80257d:	7e 17                	jle    802596 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80257f:	83 ec 0c             	sub    $0xc,%esp
  802582:	50                   	push   %eax
  802583:	6a 0a                	push   $0xa
  802585:	68 3f 40 80 00       	push   $0x80403f
  80258a:	6a 23                	push   $0x23
  80258c:	68 5c 40 80 00       	push   $0x80405c
  802591:	e8 1a f4 ff ff       	call   8019b0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802596:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802599:	5b                   	pop    %ebx
  80259a:	5e                   	pop    %esi
  80259b:	5f                   	pop    %edi
  80259c:	5d                   	pop    %ebp
  80259d:	c3                   	ret    

0080259e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80259e:	55                   	push   %ebp
  80259f:	89 e5                	mov    %esp,%ebp
  8025a1:	57                   	push   %edi
  8025a2:	56                   	push   %esi
  8025a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025a4:	be 00 00 00 00       	mov    $0x0,%esi
  8025a9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8025ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8025b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025b7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8025ba:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8025bc:	5b                   	pop    %ebx
  8025bd:	5e                   	pop    %esi
  8025be:	5f                   	pop    %edi
  8025bf:	5d                   	pop    %ebp
  8025c0:	c3                   	ret    

008025c1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8025c1:	55                   	push   %ebp
  8025c2:	89 e5                	mov    %esp,%ebp
  8025c4:	57                   	push   %edi
  8025c5:	56                   	push   %esi
  8025c6:	53                   	push   %ebx
  8025c7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8025cf:	b8 0d 00 00 00       	mov    $0xd,%eax
  8025d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8025d7:	89 cb                	mov    %ecx,%ebx
  8025d9:	89 cf                	mov    %ecx,%edi
  8025db:	89 ce                	mov    %ecx,%esi
  8025dd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8025df:	85 c0                	test   %eax,%eax
  8025e1:	7e 17                	jle    8025fa <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025e3:	83 ec 0c             	sub    $0xc,%esp
  8025e6:	50                   	push   %eax
  8025e7:	6a 0d                	push   $0xd
  8025e9:	68 3f 40 80 00       	push   $0x80403f
  8025ee:	6a 23                	push   $0x23
  8025f0:	68 5c 40 80 00       	push   $0x80405c
  8025f5:	e8 b6 f3 ff ff       	call   8019b0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8025fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025fd:	5b                   	pop    %ebx
  8025fe:	5e                   	pop    %esi
  8025ff:	5f                   	pop    %edi
  802600:	5d                   	pop    %ebp
  802601:	c3                   	ret    

00802602 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802602:	55                   	push   %ebp
  802603:	89 e5                	mov    %esp,%ebp
  802605:	53                   	push   %ebx
  802606:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  802609:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  802610:	75 28                	jne    80263a <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802612:	e8 bc fd ff ff       	call   8023d3 <sys_getenvid>
  802617:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  802619:	83 ec 04             	sub    $0x4,%esp
  80261c:	6a 06                	push   $0x6
  80261e:	68 00 f0 bf ee       	push   $0xeebff000
  802623:	50                   	push   %eax
  802624:	e8 e8 fd ff ff       	call   802411 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  802629:	83 c4 08             	add    $0x8,%esp
  80262c:	68 47 26 80 00       	push   $0x802647
  802631:	53                   	push   %ebx
  802632:	e8 25 ff ff ff       	call   80255c <sys_env_set_pgfault_upcall>
  802637:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80263a:	8b 45 08             	mov    0x8(%ebp),%eax
  80263d:	a3 10 a0 80 00       	mov    %eax,0x80a010
}
  802642:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802645:	c9                   	leave  
  802646:	c3                   	ret    

00802647 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802647:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802648:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  80264d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80264f:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  802652:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  802654:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  802657:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  80265a:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  80265d:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  802660:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  802663:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  802666:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  802669:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  80266c:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  80266f:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  802672:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  802675:	61                   	popa   
	popfl
  802676:	9d                   	popf   
	ret
  802677:	c3                   	ret    

00802678 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802678:	55                   	push   %ebp
  802679:	89 e5                	mov    %esp,%ebp
  80267b:	56                   	push   %esi
  80267c:	53                   	push   %ebx
  80267d:	8b 75 08             	mov    0x8(%ebp),%esi
  802680:	8b 45 0c             	mov    0xc(%ebp),%eax
  802683:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  802686:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802688:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  80268d:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  802690:	83 ec 0c             	sub    $0xc,%esp
  802693:	50                   	push   %eax
  802694:	e8 28 ff ff ff       	call   8025c1 <sys_ipc_recv>

	if (r < 0) {
  802699:	83 c4 10             	add    $0x10,%esp
  80269c:	85 c0                	test   %eax,%eax
  80269e:	79 16                	jns    8026b6 <ipc_recv+0x3e>
		if (from_env_store)
  8026a0:	85 f6                	test   %esi,%esi
  8026a2:	74 06                	je     8026aa <ipc_recv+0x32>
			*from_env_store = 0;
  8026a4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  8026aa:	85 db                	test   %ebx,%ebx
  8026ac:	74 2c                	je     8026da <ipc_recv+0x62>
			*perm_store = 0;
  8026ae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8026b4:	eb 24                	jmp    8026da <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  8026b6:	85 f6                	test   %esi,%esi
  8026b8:	74 0a                	je     8026c4 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  8026ba:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8026bf:	8b 40 74             	mov    0x74(%eax),%eax
  8026c2:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  8026c4:	85 db                	test   %ebx,%ebx
  8026c6:	74 0a                	je     8026d2 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  8026c8:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8026cd:	8b 40 78             	mov    0x78(%eax),%eax
  8026d0:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  8026d2:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8026d7:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8026da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026dd:	5b                   	pop    %ebx
  8026de:	5e                   	pop    %esi
  8026df:	5d                   	pop    %ebp
  8026e0:	c3                   	ret    

008026e1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8026e1:	55                   	push   %ebp
  8026e2:	89 e5                	mov    %esp,%ebp
  8026e4:	57                   	push   %edi
  8026e5:	56                   	push   %esi
  8026e6:	53                   	push   %ebx
  8026e7:	83 ec 0c             	sub    $0xc,%esp
  8026ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026ed:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8026f3:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8026f5:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8026fa:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8026fd:	ff 75 14             	pushl  0x14(%ebp)
  802700:	53                   	push   %ebx
  802701:	56                   	push   %esi
  802702:	57                   	push   %edi
  802703:	e8 96 fe ff ff       	call   80259e <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  802708:	83 c4 10             	add    $0x10,%esp
  80270b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80270e:	75 07                	jne    802717 <ipc_send+0x36>
			sys_yield();
  802710:	e8 dd fc ff ff       	call   8023f2 <sys_yield>
  802715:	eb e6                	jmp    8026fd <ipc_send+0x1c>
		} else if (r < 0) {
  802717:	85 c0                	test   %eax,%eax
  802719:	79 12                	jns    80272d <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  80271b:	50                   	push   %eax
  80271c:	68 6a 40 80 00       	push   $0x80406a
  802721:	6a 51                	push   $0x51
  802723:	68 77 40 80 00       	push   $0x804077
  802728:	e8 83 f2 ff ff       	call   8019b0 <_panic>
		}
	}
}
  80272d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802730:	5b                   	pop    %ebx
  802731:	5e                   	pop    %esi
  802732:	5f                   	pop    %edi
  802733:	5d                   	pop    %ebp
  802734:	c3                   	ret    

00802735 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802735:	55                   	push   %ebp
  802736:	89 e5                	mov    %esp,%ebp
  802738:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80273b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802740:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802743:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802749:	8b 52 50             	mov    0x50(%edx),%edx
  80274c:	39 ca                	cmp    %ecx,%edx
  80274e:	75 0d                	jne    80275d <ipc_find_env+0x28>
			return envs[i].env_id;
  802750:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802753:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802758:	8b 40 48             	mov    0x48(%eax),%eax
  80275b:	eb 0f                	jmp    80276c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80275d:	83 c0 01             	add    $0x1,%eax
  802760:	3d 00 04 00 00       	cmp    $0x400,%eax
  802765:	75 d9                	jne    802740 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802767:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80276c:	5d                   	pop    %ebp
  80276d:	c3                   	ret    

0080276e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80276e:	55                   	push   %ebp
  80276f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802771:	8b 45 08             	mov    0x8(%ebp),%eax
  802774:	05 00 00 00 30       	add    $0x30000000,%eax
  802779:	c1 e8 0c             	shr    $0xc,%eax
}
  80277c:	5d                   	pop    %ebp
  80277d:	c3                   	ret    

0080277e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80277e:	55                   	push   %ebp
  80277f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  802781:	8b 45 08             	mov    0x8(%ebp),%eax
  802784:	05 00 00 00 30       	add    $0x30000000,%eax
  802789:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80278e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802793:	5d                   	pop    %ebp
  802794:	c3                   	ret    

00802795 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802795:	55                   	push   %ebp
  802796:	89 e5                	mov    %esp,%ebp
  802798:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80279b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8027a0:	89 c2                	mov    %eax,%edx
  8027a2:	c1 ea 16             	shr    $0x16,%edx
  8027a5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8027ac:	f6 c2 01             	test   $0x1,%dl
  8027af:	74 11                	je     8027c2 <fd_alloc+0x2d>
  8027b1:	89 c2                	mov    %eax,%edx
  8027b3:	c1 ea 0c             	shr    $0xc,%edx
  8027b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8027bd:	f6 c2 01             	test   $0x1,%dl
  8027c0:	75 09                	jne    8027cb <fd_alloc+0x36>
			*fd_store = fd;
  8027c2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8027c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8027c9:	eb 17                	jmp    8027e2 <fd_alloc+0x4d>
  8027cb:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8027d0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8027d5:	75 c9                	jne    8027a0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8027d7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8027dd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8027e2:	5d                   	pop    %ebp
  8027e3:	c3                   	ret    

008027e4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8027e4:	55                   	push   %ebp
  8027e5:	89 e5                	mov    %esp,%ebp
  8027e7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8027ea:	83 f8 1f             	cmp    $0x1f,%eax
  8027ed:	77 36                	ja     802825 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8027ef:	c1 e0 0c             	shl    $0xc,%eax
  8027f2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8027f7:	89 c2                	mov    %eax,%edx
  8027f9:	c1 ea 16             	shr    $0x16,%edx
  8027fc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802803:	f6 c2 01             	test   $0x1,%dl
  802806:	74 24                	je     80282c <fd_lookup+0x48>
  802808:	89 c2                	mov    %eax,%edx
  80280a:	c1 ea 0c             	shr    $0xc,%edx
  80280d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802814:	f6 c2 01             	test   $0x1,%dl
  802817:	74 1a                	je     802833 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802819:	8b 55 0c             	mov    0xc(%ebp),%edx
  80281c:	89 02                	mov    %eax,(%edx)
	return 0;
  80281e:	b8 00 00 00 00       	mov    $0x0,%eax
  802823:	eb 13                	jmp    802838 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802825:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80282a:	eb 0c                	jmp    802838 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80282c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802831:	eb 05                	jmp    802838 <fd_lookup+0x54>
  802833:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802838:	5d                   	pop    %ebp
  802839:	c3                   	ret    

0080283a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80283a:	55                   	push   %ebp
  80283b:	89 e5                	mov    %esp,%ebp
  80283d:	83 ec 08             	sub    $0x8,%esp
  802840:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802843:	ba 04 41 80 00       	mov    $0x804104,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802848:	eb 13                	jmp    80285d <dev_lookup+0x23>
  80284a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80284d:	39 08                	cmp    %ecx,(%eax)
  80284f:	75 0c                	jne    80285d <dev_lookup+0x23>
			*dev = devtab[i];
  802851:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802854:	89 01                	mov    %eax,(%ecx)
			return 0;
  802856:	b8 00 00 00 00       	mov    $0x0,%eax
  80285b:	eb 2e                	jmp    80288b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80285d:	8b 02                	mov    (%edx),%eax
  80285f:	85 c0                	test   %eax,%eax
  802861:	75 e7                	jne    80284a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802863:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802868:	8b 40 48             	mov    0x48(%eax),%eax
  80286b:	83 ec 04             	sub    $0x4,%esp
  80286e:	51                   	push   %ecx
  80286f:	50                   	push   %eax
  802870:	68 84 40 80 00       	push   $0x804084
  802875:	e8 0f f2 ff ff       	call   801a89 <cprintf>
	*dev = 0;
  80287a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80287d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802883:	83 c4 10             	add    $0x10,%esp
  802886:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80288b:	c9                   	leave  
  80288c:	c3                   	ret    

0080288d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80288d:	55                   	push   %ebp
  80288e:	89 e5                	mov    %esp,%ebp
  802890:	56                   	push   %esi
  802891:	53                   	push   %ebx
  802892:	83 ec 10             	sub    $0x10,%esp
  802895:	8b 75 08             	mov    0x8(%ebp),%esi
  802898:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80289b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80289e:	50                   	push   %eax
  80289f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8028a5:	c1 e8 0c             	shr    $0xc,%eax
  8028a8:	50                   	push   %eax
  8028a9:	e8 36 ff ff ff       	call   8027e4 <fd_lookup>
  8028ae:	83 c4 08             	add    $0x8,%esp
  8028b1:	85 c0                	test   %eax,%eax
  8028b3:	78 05                	js     8028ba <fd_close+0x2d>
	    || fd != fd2)
  8028b5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8028b8:	74 0c                	je     8028c6 <fd_close+0x39>
		return (must_exist ? r : 0);
  8028ba:	84 db                	test   %bl,%bl
  8028bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8028c1:	0f 44 c2             	cmove  %edx,%eax
  8028c4:	eb 41                	jmp    802907 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8028c6:	83 ec 08             	sub    $0x8,%esp
  8028c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8028cc:	50                   	push   %eax
  8028cd:	ff 36                	pushl  (%esi)
  8028cf:	e8 66 ff ff ff       	call   80283a <dev_lookup>
  8028d4:	89 c3                	mov    %eax,%ebx
  8028d6:	83 c4 10             	add    $0x10,%esp
  8028d9:	85 c0                	test   %eax,%eax
  8028db:	78 1a                	js     8028f7 <fd_close+0x6a>
		if (dev->dev_close)
  8028dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8028e0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8028e3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8028e8:	85 c0                	test   %eax,%eax
  8028ea:	74 0b                	je     8028f7 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8028ec:	83 ec 0c             	sub    $0xc,%esp
  8028ef:	56                   	push   %esi
  8028f0:	ff d0                	call   *%eax
  8028f2:	89 c3                	mov    %eax,%ebx
  8028f4:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8028f7:	83 ec 08             	sub    $0x8,%esp
  8028fa:	56                   	push   %esi
  8028fb:	6a 00                	push   $0x0
  8028fd:	e8 94 fb ff ff       	call   802496 <sys_page_unmap>
	return r;
  802902:	83 c4 10             	add    $0x10,%esp
  802905:	89 d8                	mov    %ebx,%eax
}
  802907:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80290a:	5b                   	pop    %ebx
  80290b:	5e                   	pop    %esi
  80290c:	5d                   	pop    %ebp
  80290d:	c3                   	ret    

0080290e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80290e:	55                   	push   %ebp
  80290f:	89 e5                	mov    %esp,%ebp
  802911:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802914:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802917:	50                   	push   %eax
  802918:	ff 75 08             	pushl  0x8(%ebp)
  80291b:	e8 c4 fe ff ff       	call   8027e4 <fd_lookup>
  802920:	83 c4 08             	add    $0x8,%esp
  802923:	85 c0                	test   %eax,%eax
  802925:	78 10                	js     802937 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802927:	83 ec 08             	sub    $0x8,%esp
  80292a:	6a 01                	push   $0x1
  80292c:	ff 75 f4             	pushl  -0xc(%ebp)
  80292f:	e8 59 ff ff ff       	call   80288d <fd_close>
  802934:	83 c4 10             	add    $0x10,%esp
}
  802937:	c9                   	leave  
  802938:	c3                   	ret    

00802939 <close_all>:

void
close_all(void)
{
  802939:	55                   	push   %ebp
  80293a:	89 e5                	mov    %esp,%ebp
  80293c:	53                   	push   %ebx
  80293d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802940:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802945:	83 ec 0c             	sub    $0xc,%esp
  802948:	53                   	push   %ebx
  802949:	e8 c0 ff ff ff       	call   80290e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80294e:	83 c3 01             	add    $0x1,%ebx
  802951:	83 c4 10             	add    $0x10,%esp
  802954:	83 fb 20             	cmp    $0x20,%ebx
  802957:	75 ec                	jne    802945 <close_all+0xc>
		close(i);
}
  802959:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80295c:	c9                   	leave  
  80295d:	c3                   	ret    

0080295e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80295e:	55                   	push   %ebp
  80295f:	89 e5                	mov    %esp,%ebp
  802961:	57                   	push   %edi
  802962:	56                   	push   %esi
  802963:	53                   	push   %ebx
  802964:	83 ec 2c             	sub    $0x2c,%esp
  802967:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80296a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80296d:	50                   	push   %eax
  80296e:	ff 75 08             	pushl  0x8(%ebp)
  802971:	e8 6e fe ff ff       	call   8027e4 <fd_lookup>
  802976:	83 c4 08             	add    $0x8,%esp
  802979:	85 c0                	test   %eax,%eax
  80297b:	0f 88 c1 00 00 00    	js     802a42 <dup+0xe4>
		return r;
	close(newfdnum);
  802981:	83 ec 0c             	sub    $0xc,%esp
  802984:	56                   	push   %esi
  802985:	e8 84 ff ff ff       	call   80290e <close>

	newfd = INDEX2FD(newfdnum);
  80298a:	89 f3                	mov    %esi,%ebx
  80298c:	c1 e3 0c             	shl    $0xc,%ebx
  80298f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802995:	83 c4 04             	add    $0x4,%esp
  802998:	ff 75 e4             	pushl  -0x1c(%ebp)
  80299b:	e8 de fd ff ff       	call   80277e <fd2data>
  8029a0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8029a2:	89 1c 24             	mov    %ebx,(%esp)
  8029a5:	e8 d4 fd ff ff       	call   80277e <fd2data>
  8029aa:	83 c4 10             	add    $0x10,%esp
  8029ad:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8029b0:	89 f8                	mov    %edi,%eax
  8029b2:	c1 e8 16             	shr    $0x16,%eax
  8029b5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8029bc:	a8 01                	test   $0x1,%al
  8029be:	74 37                	je     8029f7 <dup+0x99>
  8029c0:	89 f8                	mov    %edi,%eax
  8029c2:	c1 e8 0c             	shr    $0xc,%eax
  8029c5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8029cc:	f6 c2 01             	test   $0x1,%dl
  8029cf:	74 26                	je     8029f7 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8029d1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8029d8:	83 ec 0c             	sub    $0xc,%esp
  8029db:	25 07 0e 00 00       	and    $0xe07,%eax
  8029e0:	50                   	push   %eax
  8029e1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8029e4:	6a 00                	push   $0x0
  8029e6:	57                   	push   %edi
  8029e7:	6a 00                	push   $0x0
  8029e9:	e8 66 fa ff ff       	call   802454 <sys_page_map>
  8029ee:	89 c7                	mov    %eax,%edi
  8029f0:	83 c4 20             	add    $0x20,%esp
  8029f3:	85 c0                	test   %eax,%eax
  8029f5:	78 2e                	js     802a25 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8029f7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8029fa:	89 d0                	mov    %edx,%eax
  8029fc:	c1 e8 0c             	shr    $0xc,%eax
  8029ff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802a06:	83 ec 0c             	sub    $0xc,%esp
  802a09:	25 07 0e 00 00       	and    $0xe07,%eax
  802a0e:	50                   	push   %eax
  802a0f:	53                   	push   %ebx
  802a10:	6a 00                	push   $0x0
  802a12:	52                   	push   %edx
  802a13:	6a 00                	push   $0x0
  802a15:	e8 3a fa ff ff       	call   802454 <sys_page_map>
  802a1a:	89 c7                	mov    %eax,%edi
  802a1c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802a1f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802a21:	85 ff                	test   %edi,%edi
  802a23:	79 1d                	jns    802a42 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802a25:	83 ec 08             	sub    $0x8,%esp
  802a28:	53                   	push   %ebx
  802a29:	6a 00                	push   $0x0
  802a2b:	e8 66 fa ff ff       	call   802496 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802a30:	83 c4 08             	add    $0x8,%esp
  802a33:	ff 75 d4             	pushl  -0x2c(%ebp)
  802a36:	6a 00                	push   $0x0
  802a38:	e8 59 fa ff ff       	call   802496 <sys_page_unmap>
	return r;
  802a3d:	83 c4 10             	add    $0x10,%esp
  802a40:	89 f8                	mov    %edi,%eax
}
  802a42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a45:	5b                   	pop    %ebx
  802a46:	5e                   	pop    %esi
  802a47:	5f                   	pop    %edi
  802a48:	5d                   	pop    %ebp
  802a49:	c3                   	ret    

00802a4a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802a4a:	55                   	push   %ebp
  802a4b:	89 e5                	mov    %esp,%ebp
  802a4d:	53                   	push   %ebx
  802a4e:	83 ec 14             	sub    $0x14,%esp
  802a51:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802a54:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802a57:	50                   	push   %eax
  802a58:	53                   	push   %ebx
  802a59:	e8 86 fd ff ff       	call   8027e4 <fd_lookup>
  802a5e:	83 c4 08             	add    $0x8,%esp
  802a61:	89 c2                	mov    %eax,%edx
  802a63:	85 c0                	test   %eax,%eax
  802a65:	78 6d                	js     802ad4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802a67:	83 ec 08             	sub    $0x8,%esp
  802a6a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a6d:	50                   	push   %eax
  802a6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a71:	ff 30                	pushl  (%eax)
  802a73:	e8 c2 fd ff ff       	call   80283a <dev_lookup>
  802a78:	83 c4 10             	add    $0x10,%esp
  802a7b:	85 c0                	test   %eax,%eax
  802a7d:	78 4c                	js     802acb <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802a7f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802a82:	8b 42 08             	mov    0x8(%edx),%eax
  802a85:	83 e0 03             	and    $0x3,%eax
  802a88:	83 f8 01             	cmp    $0x1,%eax
  802a8b:	75 21                	jne    802aae <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802a8d:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802a92:	8b 40 48             	mov    0x48(%eax),%eax
  802a95:	83 ec 04             	sub    $0x4,%esp
  802a98:	53                   	push   %ebx
  802a99:	50                   	push   %eax
  802a9a:	68 c8 40 80 00       	push   $0x8040c8
  802a9f:	e8 e5 ef ff ff       	call   801a89 <cprintf>
		return -E_INVAL;
  802aa4:	83 c4 10             	add    $0x10,%esp
  802aa7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802aac:	eb 26                	jmp    802ad4 <read+0x8a>
	}
	if (!dev->dev_read)
  802aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ab1:	8b 40 08             	mov    0x8(%eax),%eax
  802ab4:	85 c0                	test   %eax,%eax
  802ab6:	74 17                	je     802acf <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802ab8:	83 ec 04             	sub    $0x4,%esp
  802abb:	ff 75 10             	pushl  0x10(%ebp)
  802abe:	ff 75 0c             	pushl  0xc(%ebp)
  802ac1:	52                   	push   %edx
  802ac2:	ff d0                	call   *%eax
  802ac4:	89 c2                	mov    %eax,%edx
  802ac6:	83 c4 10             	add    $0x10,%esp
  802ac9:	eb 09                	jmp    802ad4 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802acb:	89 c2                	mov    %eax,%edx
  802acd:	eb 05                	jmp    802ad4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802acf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802ad4:	89 d0                	mov    %edx,%eax
  802ad6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ad9:	c9                   	leave  
  802ada:	c3                   	ret    

00802adb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802adb:	55                   	push   %ebp
  802adc:	89 e5                	mov    %esp,%ebp
  802ade:	57                   	push   %edi
  802adf:	56                   	push   %esi
  802ae0:	53                   	push   %ebx
  802ae1:	83 ec 0c             	sub    $0xc,%esp
  802ae4:	8b 7d 08             	mov    0x8(%ebp),%edi
  802ae7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802aea:	bb 00 00 00 00       	mov    $0x0,%ebx
  802aef:	eb 21                	jmp    802b12 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802af1:	83 ec 04             	sub    $0x4,%esp
  802af4:	89 f0                	mov    %esi,%eax
  802af6:	29 d8                	sub    %ebx,%eax
  802af8:	50                   	push   %eax
  802af9:	89 d8                	mov    %ebx,%eax
  802afb:	03 45 0c             	add    0xc(%ebp),%eax
  802afe:	50                   	push   %eax
  802aff:	57                   	push   %edi
  802b00:	e8 45 ff ff ff       	call   802a4a <read>
		if (m < 0)
  802b05:	83 c4 10             	add    $0x10,%esp
  802b08:	85 c0                	test   %eax,%eax
  802b0a:	78 10                	js     802b1c <readn+0x41>
			return m;
		if (m == 0)
  802b0c:	85 c0                	test   %eax,%eax
  802b0e:	74 0a                	je     802b1a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802b10:	01 c3                	add    %eax,%ebx
  802b12:	39 f3                	cmp    %esi,%ebx
  802b14:	72 db                	jb     802af1 <readn+0x16>
  802b16:	89 d8                	mov    %ebx,%eax
  802b18:	eb 02                	jmp    802b1c <readn+0x41>
  802b1a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802b1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b1f:	5b                   	pop    %ebx
  802b20:	5e                   	pop    %esi
  802b21:	5f                   	pop    %edi
  802b22:	5d                   	pop    %ebp
  802b23:	c3                   	ret    

00802b24 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802b24:	55                   	push   %ebp
  802b25:	89 e5                	mov    %esp,%ebp
  802b27:	53                   	push   %ebx
  802b28:	83 ec 14             	sub    $0x14,%esp
  802b2b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802b2e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802b31:	50                   	push   %eax
  802b32:	53                   	push   %ebx
  802b33:	e8 ac fc ff ff       	call   8027e4 <fd_lookup>
  802b38:	83 c4 08             	add    $0x8,%esp
  802b3b:	89 c2                	mov    %eax,%edx
  802b3d:	85 c0                	test   %eax,%eax
  802b3f:	78 68                	js     802ba9 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802b41:	83 ec 08             	sub    $0x8,%esp
  802b44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b47:	50                   	push   %eax
  802b48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b4b:	ff 30                	pushl  (%eax)
  802b4d:	e8 e8 fc ff ff       	call   80283a <dev_lookup>
  802b52:	83 c4 10             	add    $0x10,%esp
  802b55:	85 c0                	test   %eax,%eax
  802b57:	78 47                	js     802ba0 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802b59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b5c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802b60:	75 21                	jne    802b83 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802b62:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802b67:	8b 40 48             	mov    0x48(%eax),%eax
  802b6a:	83 ec 04             	sub    $0x4,%esp
  802b6d:	53                   	push   %ebx
  802b6e:	50                   	push   %eax
  802b6f:	68 e4 40 80 00       	push   $0x8040e4
  802b74:	e8 10 ef ff ff       	call   801a89 <cprintf>
		return -E_INVAL;
  802b79:	83 c4 10             	add    $0x10,%esp
  802b7c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802b81:	eb 26                	jmp    802ba9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802b83:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802b86:	8b 52 0c             	mov    0xc(%edx),%edx
  802b89:	85 d2                	test   %edx,%edx
  802b8b:	74 17                	je     802ba4 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802b8d:	83 ec 04             	sub    $0x4,%esp
  802b90:	ff 75 10             	pushl  0x10(%ebp)
  802b93:	ff 75 0c             	pushl  0xc(%ebp)
  802b96:	50                   	push   %eax
  802b97:	ff d2                	call   *%edx
  802b99:	89 c2                	mov    %eax,%edx
  802b9b:	83 c4 10             	add    $0x10,%esp
  802b9e:	eb 09                	jmp    802ba9 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802ba0:	89 c2                	mov    %eax,%edx
  802ba2:	eb 05                	jmp    802ba9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802ba4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802ba9:	89 d0                	mov    %edx,%eax
  802bab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802bae:	c9                   	leave  
  802baf:	c3                   	ret    

00802bb0 <seek>:

int
seek(int fdnum, off_t offset)
{
  802bb0:	55                   	push   %ebp
  802bb1:	89 e5                	mov    %esp,%ebp
  802bb3:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802bb6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802bb9:	50                   	push   %eax
  802bba:	ff 75 08             	pushl  0x8(%ebp)
  802bbd:	e8 22 fc ff ff       	call   8027e4 <fd_lookup>
  802bc2:	83 c4 08             	add    $0x8,%esp
  802bc5:	85 c0                	test   %eax,%eax
  802bc7:	78 0e                	js     802bd7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802bc9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802bcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  802bcf:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802bd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802bd7:	c9                   	leave  
  802bd8:	c3                   	ret    

00802bd9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802bd9:	55                   	push   %ebp
  802bda:	89 e5                	mov    %esp,%ebp
  802bdc:	53                   	push   %ebx
  802bdd:	83 ec 14             	sub    $0x14,%esp
  802be0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802be3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802be6:	50                   	push   %eax
  802be7:	53                   	push   %ebx
  802be8:	e8 f7 fb ff ff       	call   8027e4 <fd_lookup>
  802bed:	83 c4 08             	add    $0x8,%esp
  802bf0:	89 c2                	mov    %eax,%edx
  802bf2:	85 c0                	test   %eax,%eax
  802bf4:	78 65                	js     802c5b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802bf6:	83 ec 08             	sub    $0x8,%esp
  802bf9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802bfc:	50                   	push   %eax
  802bfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c00:	ff 30                	pushl  (%eax)
  802c02:	e8 33 fc ff ff       	call   80283a <dev_lookup>
  802c07:	83 c4 10             	add    $0x10,%esp
  802c0a:	85 c0                	test   %eax,%eax
  802c0c:	78 44                	js     802c52 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802c0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c11:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802c15:	75 21                	jne    802c38 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802c17:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802c1c:	8b 40 48             	mov    0x48(%eax),%eax
  802c1f:	83 ec 04             	sub    $0x4,%esp
  802c22:	53                   	push   %ebx
  802c23:	50                   	push   %eax
  802c24:	68 a4 40 80 00       	push   $0x8040a4
  802c29:	e8 5b ee ff ff       	call   801a89 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802c2e:	83 c4 10             	add    $0x10,%esp
  802c31:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802c36:	eb 23                	jmp    802c5b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802c38:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802c3b:	8b 52 18             	mov    0x18(%edx),%edx
  802c3e:	85 d2                	test   %edx,%edx
  802c40:	74 14                	je     802c56 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802c42:	83 ec 08             	sub    $0x8,%esp
  802c45:	ff 75 0c             	pushl  0xc(%ebp)
  802c48:	50                   	push   %eax
  802c49:	ff d2                	call   *%edx
  802c4b:	89 c2                	mov    %eax,%edx
  802c4d:	83 c4 10             	add    $0x10,%esp
  802c50:	eb 09                	jmp    802c5b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c52:	89 c2                	mov    %eax,%edx
  802c54:	eb 05                	jmp    802c5b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802c56:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802c5b:	89 d0                	mov    %edx,%eax
  802c5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c60:	c9                   	leave  
  802c61:	c3                   	ret    

00802c62 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802c62:	55                   	push   %ebp
  802c63:	89 e5                	mov    %esp,%ebp
  802c65:	53                   	push   %ebx
  802c66:	83 ec 14             	sub    $0x14,%esp
  802c69:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c6c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c6f:	50                   	push   %eax
  802c70:	ff 75 08             	pushl  0x8(%ebp)
  802c73:	e8 6c fb ff ff       	call   8027e4 <fd_lookup>
  802c78:	83 c4 08             	add    $0x8,%esp
  802c7b:	89 c2                	mov    %eax,%edx
  802c7d:	85 c0                	test   %eax,%eax
  802c7f:	78 58                	js     802cd9 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c81:	83 ec 08             	sub    $0x8,%esp
  802c84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c87:	50                   	push   %eax
  802c88:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c8b:	ff 30                	pushl  (%eax)
  802c8d:	e8 a8 fb ff ff       	call   80283a <dev_lookup>
  802c92:	83 c4 10             	add    $0x10,%esp
  802c95:	85 c0                	test   %eax,%eax
  802c97:	78 37                	js     802cd0 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c9c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802ca0:	74 32                	je     802cd4 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802ca2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802ca5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802cac:	00 00 00 
	stat->st_isdir = 0;
  802caf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802cb6:	00 00 00 
	stat->st_dev = dev;
  802cb9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802cbf:	83 ec 08             	sub    $0x8,%esp
  802cc2:	53                   	push   %ebx
  802cc3:	ff 75 f0             	pushl  -0x10(%ebp)
  802cc6:	ff 50 14             	call   *0x14(%eax)
  802cc9:	89 c2                	mov    %eax,%edx
  802ccb:	83 c4 10             	add    $0x10,%esp
  802cce:	eb 09                	jmp    802cd9 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802cd0:	89 c2                	mov    %eax,%edx
  802cd2:	eb 05                	jmp    802cd9 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802cd4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802cd9:	89 d0                	mov    %edx,%eax
  802cdb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802cde:	c9                   	leave  
  802cdf:	c3                   	ret    

00802ce0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802ce0:	55                   	push   %ebp
  802ce1:	89 e5                	mov    %esp,%ebp
  802ce3:	56                   	push   %esi
  802ce4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802ce5:	83 ec 08             	sub    $0x8,%esp
  802ce8:	6a 00                	push   $0x0
  802cea:	ff 75 08             	pushl  0x8(%ebp)
  802ced:	e8 0c 02 00 00       	call   802efe <open>
  802cf2:	89 c3                	mov    %eax,%ebx
  802cf4:	83 c4 10             	add    $0x10,%esp
  802cf7:	85 c0                	test   %eax,%eax
  802cf9:	78 1b                	js     802d16 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802cfb:	83 ec 08             	sub    $0x8,%esp
  802cfe:	ff 75 0c             	pushl  0xc(%ebp)
  802d01:	50                   	push   %eax
  802d02:	e8 5b ff ff ff       	call   802c62 <fstat>
  802d07:	89 c6                	mov    %eax,%esi
	close(fd);
  802d09:	89 1c 24             	mov    %ebx,(%esp)
  802d0c:	e8 fd fb ff ff       	call   80290e <close>
	return r;
  802d11:	83 c4 10             	add    $0x10,%esp
  802d14:	89 f0                	mov    %esi,%eax
}
  802d16:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d19:	5b                   	pop    %ebx
  802d1a:	5e                   	pop    %esi
  802d1b:	5d                   	pop    %ebp
  802d1c:	c3                   	ret    

00802d1d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802d1d:	55                   	push   %ebp
  802d1e:	89 e5                	mov    %esp,%ebp
  802d20:	56                   	push   %esi
  802d21:	53                   	push   %ebx
  802d22:	89 c6                	mov    %eax,%esi
  802d24:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802d26:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802d2d:	75 12                	jne    802d41 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802d2f:	83 ec 0c             	sub    $0xc,%esp
  802d32:	6a 01                	push   $0x1
  802d34:	e8 fc f9 ff ff       	call   802735 <ipc_find_env>
  802d39:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802d3e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802d41:	6a 07                	push   $0x7
  802d43:	68 00 b0 80 00       	push   $0x80b000
  802d48:	56                   	push   %esi
  802d49:	ff 35 00 a0 80 00    	pushl  0x80a000
  802d4f:	e8 8d f9 ff ff       	call   8026e1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802d54:	83 c4 0c             	add    $0xc,%esp
  802d57:	6a 00                	push   $0x0
  802d59:	53                   	push   %ebx
  802d5a:	6a 00                	push   $0x0
  802d5c:	e8 17 f9 ff ff       	call   802678 <ipc_recv>
}
  802d61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d64:	5b                   	pop    %ebx
  802d65:	5e                   	pop    %esi
  802d66:	5d                   	pop    %ebp
  802d67:	c3                   	ret    

00802d68 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802d68:	55                   	push   %ebp
  802d69:	89 e5                	mov    %esp,%ebp
  802d6b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  802d71:	8b 40 0c             	mov    0xc(%eax),%eax
  802d74:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802d79:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d7c:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802d81:	ba 00 00 00 00       	mov    $0x0,%edx
  802d86:	b8 02 00 00 00       	mov    $0x2,%eax
  802d8b:	e8 8d ff ff ff       	call   802d1d <fsipc>
}
  802d90:	c9                   	leave  
  802d91:	c3                   	ret    

00802d92 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802d92:	55                   	push   %ebp
  802d93:	89 e5                	mov    %esp,%ebp
  802d95:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802d98:	8b 45 08             	mov    0x8(%ebp),%eax
  802d9b:	8b 40 0c             	mov    0xc(%eax),%eax
  802d9e:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802da3:	ba 00 00 00 00       	mov    $0x0,%edx
  802da8:	b8 06 00 00 00       	mov    $0x6,%eax
  802dad:	e8 6b ff ff ff       	call   802d1d <fsipc>
}
  802db2:	c9                   	leave  
  802db3:	c3                   	ret    

00802db4 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802db4:	55                   	push   %ebp
  802db5:	89 e5                	mov    %esp,%ebp
  802db7:	53                   	push   %ebx
  802db8:	83 ec 04             	sub    $0x4,%esp
  802dbb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  802dc1:	8b 40 0c             	mov    0xc(%eax),%eax
  802dc4:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802dc9:	ba 00 00 00 00       	mov    $0x0,%edx
  802dce:	b8 05 00 00 00       	mov    $0x5,%eax
  802dd3:	e8 45 ff ff ff       	call   802d1d <fsipc>
  802dd8:	85 c0                	test   %eax,%eax
  802dda:	78 2c                	js     802e08 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802ddc:	83 ec 08             	sub    $0x8,%esp
  802ddf:	68 00 b0 80 00       	push   $0x80b000
  802de4:	53                   	push   %ebx
  802de5:	e8 24 f2 ff ff       	call   80200e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802dea:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802def:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802df5:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802dfa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802e00:	83 c4 10             	add    $0x10,%esp
  802e03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802e08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e0b:	c9                   	leave  
  802e0c:	c3                   	ret    

00802e0d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802e0d:	55                   	push   %ebp
  802e0e:	89 e5                	mov    %esp,%ebp
  802e10:	53                   	push   %ebx
  802e11:	83 ec 08             	sub    $0x8,%esp
  802e14:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802e17:	8b 55 08             	mov    0x8(%ebp),%edx
  802e1a:	8b 52 0c             	mov    0xc(%edx),%edx
  802e1d:	89 15 00 b0 80 00    	mov    %edx,0x80b000
  802e23:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802e28:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  802e2d:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  802e30:	89 1d 04 b0 80 00    	mov    %ebx,0x80b004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  802e36:	53                   	push   %ebx
  802e37:	ff 75 0c             	pushl  0xc(%ebp)
  802e3a:	68 08 b0 80 00       	push   $0x80b008
  802e3f:	e8 5c f3 ff ff       	call   8021a0 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  802e44:	ba 00 00 00 00       	mov    $0x0,%edx
  802e49:	b8 04 00 00 00       	mov    $0x4,%eax
  802e4e:	e8 ca fe ff ff       	call   802d1d <fsipc>
  802e53:	83 c4 10             	add    $0x10,%esp
  802e56:	85 c0                	test   %eax,%eax
  802e58:	78 1d                	js     802e77 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  802e5a:	39 d8                	cmp    %ebx,%eax
  802e5c:	76 19                	jbe    802e77 <devfile_write+0x6a>
  802e5e:	68 14 41 80 00       	push   $0x804114
  802e63:	68 9d 37 80 00       	push   $0x80379d
  802e68:	68 a5 00 00 00       	push   $0xa5
  802e6d:	68 20 41 80 00       	push   $0x804120
  802e72:	e8 39 eb ff ff       	call   8019b0 <_panic>
	return r;
}
  802e77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e7a:	c9                   	leave  
  802e7b:	c3                   	ret    

00802e7c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802e7c:	55                   	push   %ebp
  802e7d:	89 e5                	mov    %esp,%ebp
  802e7f:	56                   	push   %esi
  802e80:	53                   	push   %ebx
  802e81:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802e84:	8b 45 08             	mov    0x8(%ebp),%eax
  802e87:	8b 40 0c             	mov    0xc(%eax),%eax
  802e8a:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  802e8f:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802e95:	ba 00 00 00 00       	mov    $0x0,%edx
  802e9a:	b8 03 00 00 00       	mov    $0x3,%eax
  802e9f:	e8 79 fe ff ff       	call   802d1d <fsipc>
  802ea4:	89 c3                	mov    %eax,%ebx
  802ea6:	85 c0                	test   %eax,%eax
  802ea8:	78 4b                	js     802ef5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  802eaa:	39 c6                	cmp    %eax,%esi
  802eac:	73 16                	jae    802ec4 <devfile_read+0x48>
  802eae:	68 2b 41 80 00       	push   $0x80412b
  802eb3:	68 9d 37 80 00       	push   $0x80379d
  802eb8:	6a 7c                	push   $0x7c
  802eba:	68 20 41 80 00       	push   $0x804120
  802ebf:	e8 ec ea ff ff       	call   8019b0 <_panic>
	assert(r <= PGSIZE);
  802ec4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802ec9:	7e 16                	jle    802ee1 <devfile_read+0x65>
  802ecb:	68 32 41 80 00       	push   $0x804132
  802ed0:	68 9d 37 80 00       	push   $0x80379d
  802ed5:	6a 7d                	push   $0x7d
  802ed7:	68 20 41 80 00       	push   $0x804120
  802edc:	e8 cf ea ff ff       	call   8019b0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802ee1:	83 ec 04             	sub    $0x4,%esp
  802ee4:	50                   	push   %eax
  802ee5:	68 00 b0 80 00       	push   $0x80b000
  802eea:	ff 75 0c             	pushl  0xc(%ebp)
  802eed:	e8 ae f2 ff ff       	call   8021a0 <memmove>
	return r;
  802ef2:	83 c4 10             	add    $0x10,%esp
}
  802ef5:	89 d8                	mov    %ebx,%eax
  802ef7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802efa:	5b                   	pop    %ebx
  802efb:	5e                   	pop    %esi
  802efc:	5d                   	pop    %ebp
  802efd:	c3                   	ret    

00802efe <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802efe:	55                   	push   %ebp
  802eff:	89 e5                	mov    %esp,%ebp
  802f01:	53                   	push   %ebx
  802f02:	83 ec 20             	sub    $0x20,%esp
  802f05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802f08:	53                   	push   %ebx
  802f09:	e8 c7 f0 ff ff       	call   801fd5 <strlen>
  802f0e:	83 c4 10             	add    $0x10,%esp
  802f11:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802f16:	7f 67                	jg     802f7f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802f18:	83 ec 0c             	sub    $0xc,%esp
  802f1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f1e:	50                   	push   %eax
  802f1f:	e8 71 f8 ff ff       	call   802795 <fd_alloc>
  802f24:	83 c4 10             	add    $0x10,%esp
		return r;
  802f27:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802f29:	85 c0                	test   %eax,%eax
  802f2b:	78 57                	js     802f84 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802f2d:	83 ec 08             	sub    $0x8,%esp
  802f30:	53                   	push   %ebx
  802f31:	68 00 b0 80 00       	push   $0x80b000
  802f36:	e8 d3 f0 ff ff       	call   80200e <strcpy>
	fsipcbuf.open.req_omode = mode;
  802f3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f3e:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802f43:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802f46:	b8 01 00 00 00       	mov    $0x1,%eax
  802f4b:	e8 cd fd ff ff       	call   802d1d <fsipc>
  802f50:	89 c3                	mov    %eax,%ebx
  802f52:	83 c4 10             	add    $0x10,%esp
  802f55:	85 c0                	test   %eax,%eax
  802f57:	79 14                	jns    802f6d <open+0x6f>
		fd_close(fd, 0);
  802f59:	83 ec 08             	sub    $0x8,%esp
  802f5c:	6a 00                	push   $0x0
  802f5e:	ff 75 f4             	pushl  -0xc(%ebp)
  802f61:	e8 27 f9 ff ff       	call   80288d <fd_close>
		return r;
  802f66:	83 c4 10             	add    $0x10,%esp
  802f69:	89 da                	mov    %ebx,%edx
  802f6b:	eb 17                	jmp    802f84 <open+0x86>
	}

	return fd2num(fd);
  802f6d:	83 ec 0c             	sub    $0xc,%esp
  802f70:	ff 75 f4             	pushl  -0xc(%ebp)
  802f73:	e8 f6 f7 ff ff       	call   80276e <fd2num>
  802f78:	89 c2                	mov    %eax,%edx
  802f7a:	83 c4 10             	add    $0x10,%esp
  802f7d:	eb 05                	jmp    802f84 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802f7f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802f84:	89 d0                	mov    %edx,%eax
  802f86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f89:	c9                   	leave  
  802f8a:	c3                   	ret    

00802f8b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802f8b:	55                   	push   %ebp
  802f8c:	89 e5                	mov    %esp,%ebp
  802f8e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802f91:	ba 00 00 00 00       	mov    $0x0,%edx
  802f96:	b8 08 00 00 00       	mov    $0x8,%eax
  802f9b:	e8 7d fd ff ff       	call   802d1d <fsipc>
}
  802fa0:	c9                   	leave  
  802fa1:	c3                   	ret    

00802fa2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802fa2:	55                   	push   %ebp
  802fa3:	89 e5                	mov    %esp,%ebp
  802fa5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802fa8:	89 d0                	mov    %edx,%eax
  802faa:	c1 e8 16             	shr    $0x16,%eax
  802fad:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802fb4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802fb9:	f6 c1 01             	test   $0x1,%cl
  802fbc:	74 1d                	je     802fdb <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802fbe:	c1 ea 0c             	shr    $0xc,%edx
  802fc1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802fc8:	f6 c2 01             	test   $0x1,%dl
  802fcb:	74 0e                	je     802fdb <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802fcd:	c1 ea 0c             	shr    $0xc,%edx
  802fd0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802fd7:	ef 
  802fd8:	0f b7 c0             	movzwl %ax,%eax
}
  802fdb:	5d                   	pop    %ebp
  802fdc:	c3                   	ret    

00802fdd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802fdd:	55                   	push   %ebp
  802fde:	89 e5                	mov    %esp,%ebp
  802fe0:	56                   	push   %esi
  802fe1:	53                   	push   %ebx
  802fe2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802fe5:	83 ec 0c             	sub    $0xc,%esp
  802fe8:	ff 75 08             	pushl  0x8(%ebp)
  802feb:	e8 8e f7 ff ff       	call   80277e <fd2data>
  802ff0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802ff2:	83 c4 08             	add    $0x8,%esp
  802ff5:	68 3e 41 80 00       	push   $0x80413e
  802ffa:	53                   	push   %ebx
  802ffb:	e8 0e f0 ff ff       	call   80200e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803000:	8b 46 04             	mov    0x4(%esi),%eax
  803003:	2b 06                	sub    (%esi),%eax
  803005:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80300b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803012:	00 00 00 
	stat->st_dev = &devpipe;
  803015:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  80301c:	90 80 00 
	return 0;
}
  80301f:	b8 00 00 00 00       	mov    $0x0,%eax
  803024:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803027:	5b                   	pop    %ebx
  803028:	5e                   	pop    %esi
  803029:	5d                   	pop    %ebp
  80302a:	c3                   	ret    

0080302b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80302b:	55                   	push   %ebp
  80302c:	89 e5                	mov    %esp,%ebp
  80302e:	53                   	push   %ebx
  80302f:	83 ec 0c             	sub    $0xc,%esp
  803032:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803035:	53                   	push   %ebx
  803036:	6a 00                	push   $0x0
  803038:	e8 59 f4 ff ff       	call   802496 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80303d:	89 1c 24             	mov    %ebx,(%esp)
  803040:	e8 39 f7 ff ff       	call   80277e <fd2data>
  803045:	83 c4 08             	add    $0x8,%esp
  803048:	50                   	push   %eax
  803049:	6a 00                	push   $0x0
  80304b:	e8 46 f4 ff ff       	call   802496 <sys_page_unmap>
}
  803050:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803053:	c9                   	leave  
  803054:	c3                   	ret    

00803055 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  803055:	55                   	push   %ebp
  803056:	89 e5                	mov    %esp,%ebp
  803058:	57                   	push   %edi
  803059:	56                   	push   %esi
  80305a:	53                   	push   %ebx
  80305b:	83 ec 1c             	sub    $0x1c,%esp
  80305e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  803061:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  803063:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  803068:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80306b:	83 ec 0c             	sub    $0xc,%esp
  80306e:	ff 75 e0             	pushl  -0x20(%ebp)
  803071:	e8 2c ff ff ff       	call   802fa2 <pageref>
  803076:	89 c3                	mov    %eax,%ebx
  803078:	89 3c 24             	mov    %edi,(%esp)
  80307b:	e8 22 ff ff ff       	call   802fa2 <pageref>
  803080:	83 c4 10             	add    $0x10,%esp
  803083:	39 c3                	cmp    %eax,%ebx
  803085:	0f 94 c1             	sete   %cl
  803088:	0f b6 c9             	movzbl %cl,%ecx
  80308b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80308e:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  803094:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  803097:	39 ce                	cmp    %ecx,%esi
  803099:	74 1b                	je     8030b6 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80309b:	39 c3                	cmp    %eax,%ebx
  80309d:	75 c4                	jne    803063 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80309f:	8b 42 58             	mov    0x58(%edx),%eax
  8030a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8030a5:	50                   	push   %eax
  8030a6:	56                   	push   %esi
  8030a7:	68 45 41 80 00       	push   $0x804145
  8030ac:	e8 d8 e9 ff ff       	call   801a89 <cprintf>
  8030b1:	83 c4 10             	add    $0x10,%esp
  8030b4:	eb ad                	jmp    803063 <_pipeisclosed+0xe>
	}
}
  8030b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8030b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8030bc:	5b                   	pop    %ebx
  8030bd:	5e                   	pop    %esi
  8030be:	5f                   	pop    %edi
  8030bf:	5d                   	pop    %ebp
  8030c0:	c3                   	ret    

008030c1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8030c1:	55                   	push   %ebp
  8030c2:	89 e5                	mov    %esp,%ebp
  8030c4:	57                   	push   %edi
  8030c5:	56                   	push   %esi
  8030c6:	53                   	push   %ebx
  8030c7:	83 ec 28             	sub    $0x28,%esp
  8030ca:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8030cd:	56                   	push   %esi
  8030ce:	e8 ab f6 ff ff       	call   80277e <fd2data>
  8030d3:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8030d5:	83 c4 10             	add    $0x10,%esp
  8030d8:	bf 00 00 00 00       	mov    $0x0,%edi
  8030dd:	eb 4b                	jmp    80312a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8030df:	89 da                	mov    %ebx,%edx
  8030e1:	89 f0                	mov    %esi,%eax
  8030e3:	e8 6d ff ff ff       	call   803055 <_pipeisclosed>
  8030e8:	85 c0                	test   %eax,%eax
  8030ea:	75 48                	jne    803134 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8030ec:	e8 01 f3 ff ff       	call   8023f2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8030f1:	8b 43 04             	mov    0x4(%ebx),%eax
  8030f4:	8b 0b                	mov    (%ebx),%ecx
  8030f6:	8d 51 20             	lea    0x20(%ecx),%edx
  8030f9:	39 d0                	cmp    %edx,%eax
  8030fb:	73 e2                	jae    8030df <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8030fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803100:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803104:	88 4d e7             	mov    %cl,-0x19(%ebp)
  803107:	89 c2                	mov    %eax,%edx
  803109:	c1 fa 1f             	sar    $0x1f,%edx
  80310c:	89 d1                	mov    %edx,%ecx
  80310e:	c1 e9 1b             	shr    $0x1b,%ecx
  803111:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803114:	83 e2 1f             	and    $0x1f,%edx
  803117:	29 ca                	sub    %ecx,%edx
  803119:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80311d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803121:	83 c0 01             	add    $0x1,%eax
  803124:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803127:	83 c7 01             	add    $0x1,%edi
  80312a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80312d:	75 c2                	jne    8030f1 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80312f:	8b 45 10             	mov    0x10(%ebp),%eax
  803132:	eb 05                	jmp    803139 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803134:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  803139:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80313c:	5b                   	pop    %ebx
  80313d:	5e                   	pop    %esi
  80313e:	5f                   	pop    %edi
  80313f:	5d                   	pop    %ebp
  803140:	c3                   	ret    

00803141 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803141:	55                   	push   %ebp
  803142:	89 e5                	mov    %esp,%ebp
  803144:	57                   	push   %edi
  803145:	56                   	push   %esi
  803146:	53                   	push   %ebx
  803147:	83 ec 18             	sub    $0x18,%esp
  80314a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80314d:	57                   	push   %edi
  80314e:	e8 2b f6 ff ff       	call   80277e <fd2data>
  803153:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803155:	83 c4 10             	add    $0x10,%esp
  803158:	bb 00 00 00 00       	mov    $0x0,%ebx
  80315d:	eb 3d                	jmp    80319c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80315f:	85 db                	test   %ebx,%ebx
  803161:	74 04                	je     803167 <devpipe_read+0x26>
				return i;
  803163:	89 d8                	mov    %ebx,%eax
  803165:	eb 44                	jmp    8031ab <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  803167:	89 f2                	mov    %esi,%edx
  803169:	89 f8                	mov    %edi,%eax
  80316b:	e8 e5 fe ff ff       	call   803055 <_pipeisclosed>
  803170:	85 c0                	test   %eax,%eax
  803172:	75 32                	jne    8031a6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  803174:	e8 79 f2 ff ff       	call   8023f2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  803179:	8b 06                	mov    (%esi),%eax
  80317b:	3b 46 04             	cmp    0x4(%esi),%eax
  80317e:	74 df                	je     80315f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803180:	99                   	cltd   
  803181:	c1 ea 1b             	shr    $0x1b,%edx
  803184:	01 d0                	add    %edx,%eax
  803186:	83 e0 1f             	and    $0x1f,%eax
  803189:	29 d0                	sub    %edx,%eax
  80318b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  803190:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803193:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  803196:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803199:	83 c3 01             	add    $0x1,%ebx
  80319c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80319f:	75 d8                	jne    803179 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8031a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8031a4:	eb 05                	jmp    8031ab <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8031a6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8031ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8031ae:	5b                   	pop    %ebx
  8031af:	5e                   	pop    %esi
  8031b0:	5f                   	pop    %edi
  8031b1:	5d                   	pop    %ebp
  8031b2:	c3                   	ret    

008031b3 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8031b3:	55                   	push   %ebp
  8031b4:	89 e5                	mov    %esp,%ebp
  8031b6:	56                   	push   %esi
  8031b7:	53                   	push   %ebx
  8031b8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8031bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8031be:	50                   	push   %eax
  8031bf:	e8 d1 f5 ff ff       	call   802795 <fd_alloc>
  8031c4:	83 c4 10             	add    $0x10,%esp
  8031c7:	89 c2                	mov    %eax,%edx
  8031c9:	85 c0                	test   %eax,%eax
  8031cb:	0f 88 2c 01 00 00    	js     8032fd <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8031d1:	83 ec 04             	sub    $0x4,%esp
  8031d4:	68 07 04 00 00       	push   $0x407
  8031d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8031dc:	6a 00                	push   $0x0
  8031de:	e8 2e f2 ff ff       	call   802411 <sys_page_alloc>
  8031e3:	83 c4 10             	add    $0x10,%esp
  8031e6:	89 c2                	mov    %eax,%edx
  8031e8:	85 c0                	test   %eax,%eax
  8031ea:	0f 88 0d 01 00 00    	js     8032fd <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8031f0:	83 ec 0c             	sub    $0xc,%esp
  8031f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8031f6:	50                   	push   %eax
  8031f7:	e8 99 f5 ff ff       	call   802795 <fd_alloc>
  8031fc:	89 c3                	mov    %eax,%ebx
  8031fe:	83 c4 10             	add    $0x10,%esp
  803201:	85 c0                	test   %eax,%eax
  803203:	0f 88 e2 00 00 00    	js     8032eb <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803209:	83 ec 04             	sub    $0x4,%esp
  80320c:	68 07 04 00 00       	push   $0x407
  803211:	ff 75 f0             	pushl  -0x10(%ebp)
  803214:	6a 00                	push   $0x0
  803216:	e8 f6 f1 ff ff       	call   802411 <sys_page_alloc>
  80321b:	89 c3                	mov    %eax,%ebx
  80321d:	83 c4 10             	add    $0x10,%esp
  803220:	85 c0                	test   %eax,%eax
  803222:	0f 88 c3 00 00 00    	js     8032eb <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  803228:	83 ec 0c             	sub    $0xc,%esp
  80322b:	ff 75 f4             	pushl  -0xc(%ebp)
  80322e:	e8 4b f5 ff ff       	call   80277e <fd2data>
  803233:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803235:	83 c4 0c             	add    $0xc,%esp
  803238:	68 07 04 00 00       	push   $0x407
  80323d:	50                   	push   %eax
  80323e:	6a 00                	push   $0x0
  803240:	e8 cc f1 ff ff       	call   802411 <sys_page_alloc>
  803245:	89 c3                	mov    %eax,%ebx
  803247:	83 c4 10             	add    $0x10,%esp
  80324a:	85 c0                	test   %eax,%eax
  80324c:	0f 88 89 00 00 00    	js     8032db <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803252:	83 ec 0c             	sub    $0xc,%esp
  803255:	ff 75 f0             	pushl  -0x10(%ebp)
  803258:	e8 21 f5 ff ff       	call   80277e <fd2data>
  80325d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  803264:	50                   	push   %eax
  803265:	6a 00                	push   $0x0
  803267:	56                   	push   %esi
  803268:	6a 00                	push   $0x0
  80326a:	e8 e5 f1 ff ff       	call   802454 <sys_page_map>
  80326f:	89 c3                	mov    %eax,%ebx
  803271:	83 c4 20             	add    $0x20,%esp
  803274:	85 c0                	test   %eax,%eax
  803276:	78 55                	js     8032cd <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  803278:	8b 15 80 90 80 00    	mov    0x809080,%edx
  80327e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803281:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803283:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803286:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80328d:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803293:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803296:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  803298:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80329b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8032a2:	83 ec 0c             	sub    $0xc,%esp
  8032a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8032a8:	e8 c1 f4 ff ff       	call   80276e <fd2num>
  8032ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8032b0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8032b2:	83 c4 04             	add    $0x4,%esp
  8032b5:	ff 75 f0             	pushl  -0x10(%ebp)
  8032b8:	e8 b1 f4 ff ff       	call   80276e <fd2num>
  8032bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8032c0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8032c3:	83 c4 10             	add    $0x10,%esp
  8032c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8032cb:	eb 30                	jmp    8032fd <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8032cd:	83 ec 08             	sub    $0x8,%esp
  8032d0:	56                   	push   %esi
  8032d1:	6a 00                	push   $0x0
  8032d3:	e8 be f1 ff ff       	call   802496 <sys_page_unmap>
  8032d8:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8032db:	83 ec 08             	sub    $0x8,%esp
  8032de:	ff 75 f0             	pushl  -0x10(%ebp)
  8032e1:	6a 00                	push   $0x0
  8032e3:	e8 ae f1 ff ff       	call   802496 <sys_page_unmap>
  8032e8:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8032eb:	83 ec 08             	sub    $0x8,%esp
  8032ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8032f1:	6a 00                	push   $0x0
  8032f3:	e8 9e f1 ff ff       	call   802496 <sys_page_unmap>
  8032f8:	83 c4 10             	add    $0x10,%esp
  8032fb:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8032fd:	89 d0                	mov    %edx,%eax
  8032ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803302:	5b                   	pop    %ebx
  803303:	5e                   	pop    %esi
  803304:	5d                   	pop    %ebp
  803305:	c3                   	ret    

00803306 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  803306:	55                   	push   %ebp
  803307:	89 e5                	mov    %esp,%ebp
  803309:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80330c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80330f:	50                   	push   %eax
  803310:	ff 75 08             	pushl  0x8(%ebp)
  803313:	e8 cc f4 ff ff       	call   8027e4 <fd_lookup>
  803318:	83 c4 10             	add    $0x10,%esp
  80331b:	85 c0                	test   %eax,%eax
  80331d:	78 18                	js     803337 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80331f:	83 ec 0c             	sub    $0xc,%esp
  803322:	ff 75 f4             	pushl  -0xc(%ebp)
  803325:	e8 54 f4 ff ff       	call   80277e <fd2data>
	return _pipeisclosed(fd, p);
  80332a:	89 c2                	mov    %eax,%edx
  80332c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80332f:	e8 21 fd ff ff       	call   803055 <_pipeisclosed>
  803334:	83 c4 10             	add    $0x10,%esp
}
  803337:	c9                   	leave  
  803338:	c3                   	ret    

00803339 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  803339:	55                   	push   %ebp
  80333a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80333c:	b8 00 00 00 00       	mov    $0x0,%eax
  803341:	5d                   	pop    %ebp
  803342:	c3                   	ret    

00803343 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  803343:	55                   	push   %ebp
  803344:	89 e5                	mov    %esp,%ebp
  803346:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  803349:	68 5d 41 80 00       	push   $0x80415d
  80334e:	ff 75 0c             	pushl  0xc(%ebp)
  803351:	e8 b8 ec ff ff       	call   80200e <strcpy>
	return 0;
}
  803356:	b8 00 00 00 00       	mov    $0x0,%eax
  80335b:	c9                   	leave  
  80335c:	c3                   	ret    

0080335d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80335d:	55                   	push   %ebp
  80335e:	89 e5                	mov    %esp,%ebp
  803360:	57                   	push   %edi
  803361:	56                   	push   %esi
  803362:	53                   	push   %ebx
  803363:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803369:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80336e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803374:	eb 2d                	jmp    8033a3 <devcons_write+0x46>
		m = n - tot;
  803376:	8b 5d 10             	mov    0x10(%ebp),%ebx
  803379:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80337b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80337e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  803383:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803386:	83 ec 04             	sub    $0x4,%esp
  803389:	53                   	push   %ebx
  80338a:	03 45 0c             	add    0xc(%ebp),%eax
  80338d:	50                   	push   %eax
  80338e:	57                   	push   %edi
  80338f:	e8 0c ee ff ff       	call   8021a0 <memmove>
		sys_cputs(buf, m);
  803394:	83 c4 08             	add    $0x8,%esp
  803397:	53                   	push   %ebx
  803398:	57                   	push   %edi
  803399:	e8 b7 ef ff ff       	call   802355 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80339e:	01 de                	add    %ebx,%esi
  8033a0:	83 c4 10             	add    $0x10,%esp
  8033a3:	89 f0                	mov    %esi,%eax
  8033a5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8033a8:	72 cc                	jb     803376 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8033aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8033ad:	5b                   	pop    %ebx
  8033ae:	5e                   	pop    %esi
  8033af:	5f                   	pop    %edi
  8033b0:	5d                   	pop    %ebp
  8033b1:	c3                   	ret    

008033b2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8033b2:	55                   	push   %ebp
  8033b3:	89 e5                	mov    %esp,%ebp
  8033b5:	83 ec 08             	sub    $0x8,%esp
  8033b8:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8033bd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8033c1:	74 2a                	je     8033ed <devcons_read+0x3b>
  8033c3:	eb 05                	jmp    8033ca <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8033c5:	e8 28 f0 ff ff       	call   8023f2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8033ca:	e8 a4 ef ff ff       	call   802373 <sys_cgetc>
  8033cf:	85 c0                	test   %eax,%eax
  8033d1:	74 f2                	je     8033c5 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8033d3:	85 c0                	test   %eax,%eax
  8033d5:	78 16                	js     8033ed <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8033d7:	83 f8 04             	cmp    $0x4,%eax
  8033da:	74 0c                	je     8033e8 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8033dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8033df:	88 02                	mov    %al,(%edx)
	return 1;
  8033e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8033e6:	eb 05                	jmp    8033ed <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8033e8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8033ed:	c9                   	leave  
  8033ee:	c3                   	ret    

008033ef <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8033ef:	55                   	push   %ebp
  8033f0:	89 e5                	mov    %esp,%ebp
  8033f2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8033f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8033f8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8033fb:	6a 01                	push   $0x1
  8033fd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803400:	50                   	push   %eax
  803401:	e8 4f ef ff ff       	call   802355 <sys_cputs>
}
  803406:	83 c4 10             	add    $0x10,%esp
  803409:	c9                   	leave  
  80340a:	c3                   	ret    

0080340b <getchar>:

int
getchar(void)
{
  80340b:	55                   	push   %ebp
  80340c:	89 e5                	mov    %esp,%ebp
  80340e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803411:	6a 01                	push   $0x1
  803413:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803416:	50                   	push   %eax
  803417:	6a 00                	push   $0x0
  803419:	e8 2c f6 ff ff       	call   802a4a <read>
	if (r < 0)
  80341e:	83 c4 10             	add    $0x10,%esp
  803421:	85 c0                	test   %eax,%eax
  803423:	78 0f                	js     803434 <getchar+0x29>
		return r;
	if (r < 1)
  803425:	85 c0                	test   %eax,%eax
  803427:	7e 06                	jle    80342f <getchar+0x24>
		return -E_EOF;
	return c;
  803429:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80342d:	eb 05                	jmp    803434 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80342f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  803434:	c9                   	leave  
  803435:	c3                   	ret    

00803436 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  803436:	55                   	push   %ebp
  803437:	89 e5                	mov    %esp,%ebp
  803439:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80343c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80343f:	50                   	push   %eax
  803440:	ff 75 08             	pushl  0x8(%ebp)
  803443:	e8 9c f3 ff ff       	call   8027e4 <fd_lookup>
  803448:	83 c4 10             	add    $0x10,%esp
  80344b:	85 c0                	test   %eax,%eax
  80344d:	78 11                	js     803460 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80344f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803452:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803458:	39 10                	cmp    %edx,(%eax)
  80345a:	0f 94 c0             	sete   %al
  80345d:	0f b6 c0             	movzbl %al,%eax
}
  803460:	c9                   	leave  
  803461:	c3                   	ret    

00803462 <opencons>:

int
opencons(void)
{
  803462:	55                   	push   %ebp
  803463:	89 e5                	mov    %esp,%ebp
  803465:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803468:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80346b:	50                   	push   %eax
  80346c:	e8 24 f3 ff ff       	call   802795 <fd_alloc>
  803471:	83 c4 10             	add    $0x10,%esp
		return r;
  803474:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803476:	85 c0                	test   %eax,%eax
  803478:	78 3e                	js     8034b8 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80347a:	83 ec 04             	sub    $0x4,%esp
  80347d:	68 07 04 00 00       	push   $0x407
  803482:	ff 75 f4             	pushl  -0xc(%ebp)
  803485:	6a 00                	push   $0x0
  803487:	e8 85 ef ff ff       	call   802411 <sys_page_alloc>
  80348c:	83 c4 10             	add    $0x10,%esp
		return r;
  80348f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803491:	85 c0                	test   %eax,%eax
  803493:	78 23                	js     8034b8 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  803495:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  80349b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80349e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8034a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8034a3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8034aa:	83 ec 0c             	sub    $0xc,%esp
  8034ad:	50                   	push   %eax
  8034ae:	e8 bb f2 ff ff       	call   80276e <fd2num>
  8034b3:	89 c2                	mov    %eax,%edx
  8034b5:	83 c4 10             	add    $0x10,%esp
}
  8034b8:	89 d0                	mov    %edx,%eax
  8034ba:	c9                   	leave  
  8034bb:	c3                   	ret    
  8034bc:	66 90                	xchg   %ax,%ax
  8034be:	66 90                	xchg   %ax,%ax

008034c0 <__udivdi3>:
  8034c0:	55                   	push   %ebp
  8034c1:	57                   	push   %edi
  8034c2:	56                   	push   %esi
  8034c3:	53                   	push   %ebx
  8034c4:	83 ec 1c             	sub    $0x1c,%esp
  8034c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8034cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8034cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8034d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8034d7:	85 f6                	test   %esi,%esi
  8034d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8034dd:	89 ca                	mov    %ecx,%edx
  8034df:	89 f8                	mov    %edi,%eax
  8034e1:	75 3d                	jne    803520 <__udivdi3+0x60>
  8034e3:	39 cf                	cmp    %ecx,%edi
  8034e5:	0f 87 c5 00 00 00    	ja     8035b0 <__udivdi3+0xf0>
  8034eb:	85 ff                	test   %edi,%edi
  8034ed:	89 fd                	mov    %edi,%ebp
  8034ef:	75 0b                	jne    8034fc <__udivdi3+0x3c>
  8034f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8034f6:	31 d2                	xor    %edx,%edx
  8034f8:	f7 f7                	div    %edi
  8034fa:	89 c5                	mov    %eax,%ebp
  8034fc:	89 c8                	mov    %ecx,%eax
  8034fe:	31 d2                	xor    %edx,%edx
  803500:	f7 f5                	div    %ebp
  803502:	89 c1                	mov    %eax,%ecx
  803504:	89 d8                	mov    %ebx,%eax
  803506:	89 cf                	mov    %ecx,%edi
  803508:	f7 f5                	div    %ebp
  80350a:	89 c3                	mov    %eax,%ebx
  80350c:	89 d8                	mov    %ebx,%eax
  80350e:	89 fa                	mov    %edi,%edx
  803510:	83 c4 1c             	add    $0x1c,%esp
  803513:	5b                   	pop    %ebx
  803514:	5e                   	pop    %esi
  803515:	5f                   	pop    %edi
  803516:	5d                   	pop    %ebp
  803517:	c3                   	ret    
  803518:	90                   	nop
  803519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803520:	39 ce                	cmp    %ecx,%esi
  803522:	77 74                	ja     803598 <__udivdi3+0xd8>
  803524:	0f bd fe             	bsr    %esi,%edi
  803527:	83 f7 1f             	xor    $0x1f,%edi
  80352a:	0f 84 98 00 00 00    	je     8035c8 <__udivdi3+0x108>
  803530:	bb 20 00 00 00       	mov    $0x20,%ebx
  803535:	89 f9                	mov    %edi,%ecx
  803537:	89 c5                	mov    %eax,%ebp
  803539:	29 fb                	sub    %edi,%ebx
  80353b:	d3 e6                	shl    %cl,%esi
  80353d:	89 d9                	mov    %ebx,%ecx
  80353f:	d3 ed                	shr    %cl,%ebp
  803541:	89 f9                	mov    %edi,%ecx
  803543:	d3 e0                	shl    %cl,%eax
  803545:	09 ee                	or     %ebp,%esi
  803547:	89 d9                	mov    %ebx,%ecx
  803549:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80354d:	89 d5                	mov    %edx,%ebp
  80354f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803553:	d3 ed                	shr    %cl,%ebp
  803555:	89 f9                	mov    %edi,%ecx
  803557:	d3 e2                	shl    %cl,%edx
  803559:	89 d9                	mov    %ebx,%ecx
  80355b:	d3 e8                	shr    %cl,%eax
  80355d:	09 c2                	or     %eax,%edx
  80355f:	89 d0                	mov    %edx,%eax
  803561:	89 ea                	mov    %ebp,%edx
  803563:	f7 f6                	div    %esi
  803565:	89 d5                	mov    %edx,%ebp
  803567:	89 c3                	mov    %eax,%ebx
  803569:	f7 64 24 0c          	mull   0xc(%esp)
  80356d:	39 d5                	cmp    %edx,%ebp
  80356f:	72 10                	jb     803581 <__udivdi3+0xc1>
  803571:	8b 74 24 08          	mov    0x8(%esp),%esi
  803575:	89 f9                	mov    %edi,%ecx
  803577:	d3 e6                	shl    %cl,%esi
  803579:	39 c6                	cmp    %eax,%esi
  80357b:	73 07                	jae    803584 <__udivdi3+0xc4>
  80357d:	39 d5                	cmp    %edx,%ebp
  80357f:	75 03                	jne    803584 <__udivdi3+0xc4>
  803581:	83 eb 01             	sub    $0x1,%ebx
  803584:	31 ff                	xor    %edi,%edi
  803586:	89 d8                	mov    %ebx,%eax
  803588:	89 fa                	mov    %edi,%edx
  80358a:	83 c4 1c             	add    $0x1c,%esp
  80358d:	5b                   	pop    %ebx
  80358e:	5e                   	pop    %esi
  80358f:	5f                   	pop    %edi
  803590:	5d                   	pop    %ebp
  803591:	c3                   	ret    
  803592:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803598:	31 ff                	xor    %edi,%edi
  80359a:	31 db                	xor    %ebx,%ebx
  80359c:	89 d8                	mov    %ebx,%eax
  80359e:	89 fa                	mov    %edi,%edx
  8035a0:	83 c4 1c             	add    $0x1c,%esp
  8035a3:	5b                   	pop    %ebx
  8035a4:	5e                   	pop    %esi
  8035a5:	5f                   	pop    %edi
  8035a6:	5d                   	pop    %ebp
  8035a7:	c3                   	ret    
  8035a8:	90                   	nop
  8035a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8035b0:	89 d8                	mov    %ebx,%eax
  8035b2:	f7 f7                	div    %edi
  8035b4:	31 ff                	xor    %edi,%edi
  8035b6:	89 c3                	mov    %eax,%ebx
  8035b8:	89 d8                	mov    %ebx,%eax
  8035ba:	89 fa                	mov    %edi,%edx
  8035bc:	83 c4 1c             	add    $0x1c,%esp
  8035bf:	5b                   	pop    %ebx
  8035c0:	5e                   	pop    %esi
  8035c1:	5f                   	pop    %edi
  8035c2:	5d                   	pop    %ebp
  8035c3:	c3                   	ret    
  8035c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8035c8:	39 ce                	cmp    %ecx,%esi
  8035ca:	72 0c                	jb     8035d8 <__udivdi3+0x118>
  8035cc:	31 db                	xor    %ebx,%ebx
  8035ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8035d2:	0f 87 34 ff ff ff    	ja     80350c <__udivdi3+0x4c>
  8035d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8035dd:	e9 2a ff ff ff       	jmp    80350c <__udivdi3+0x4c>
  8035e2:	66 90                	xchg   %ax,%ax
  8035e4:	66 90                	xchg   %ax,%ax
  8035e6:	66 90                	xchg   %ax,%ax
  8035e8:	66 90                	xchg   %ax,%ax
  8035ea:	66 90                	xchg   %ax,%ax
  8035ec:	66 90                	xchg   %ax,%ax
  8035ee:	66 90                	xchg   %ax,%ax

008035f0 <__umoddi3>:
  8035f0:	55                   	push   %ebp
  8035f1:	57                   	push   %edi
  8035f2:	56                   	push   %esi
  8035f3:	53                   	push   %ebx
  8035f4:	83 ec 1c             	sub    $0x1c,%esp
  8035f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8035fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8035ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  803603:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803607:	85 d2                	test   %edx,%edx
  803609:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80360d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803611:	89 f3                	mov    %esi,%ebx
  803613:	89 3c 24             	mov    %edi,(%esp)
  803616:	89 74 24 04          	mov    %esi,0x4(%esp)
  80361a:	75 1c                	jne    803638 <__umoddi3+0x48>
  80361c:	39 f7                	cmp    %esi,%edi
  80361e:	76 50                	jbe    803670 <__umoddi3+0x80>
  803620:	89 c8                	mov    %ecx,%eax
  803622:	89 f2                	mov    %esi,%edx
  803624:	f7 f7                	div    %edi
  803626:	89 d0                	mov    %edx,%eax
  803628:	31 d2                	xor    %edx,%edx
  80362a:	83 c4 1c             	add    $0x1c,%esp
  80362d:	5b                   	pop    %ebx
  80362e:	5e                   	pop    %esi
  80362f:	5f                   	pop    %edi
  803630:	5d                   	pop    %ebp
  803631:	c3                   	ret    
  803632:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803638:	39 f2                	cmp    %esi,%edx
  80363a:	89 d0                	mov    %edx,%eax
  80363c:	77 52                	ja     803690 <__umoddi3+0xa0>
  80363e:	0f bd ea             	bsr    %edx,%ebp
  803641:	83 f5 1f             	xor    $0x1f,%ebp
  803644:	75 5a                	jne    8036a0 <__umoddi3+0xb0>
  803646:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80364a:	0f 82 e0 00 00 00    	jb     803730 <__umoddi3+0x140>
  803650:	39 0c 24             	cmp    %ecx,(%esp)
  803653:	0f 86 d7 00 00 00    	jbe    803730 <__umoddi3+0x140>
  803659:	8b 44 24 08          	mov    0x8(%esp),%eax
  80365d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803661:	83 c4 1c             	add    $0x1c,%esp
  803664:	5b                   	pop    %ebx
  803665:	5e                   	pop    %esi
  803666:	5f                   	pop    %edi
  803667:	5d                   	pop    %ebp
  803668:	c3                   	ret    
  803669:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803670:	85 ff                	test   %edi,%edi
  803672:	89 fd                	mov    %edi,%ebp
  803674:	75 0b                	jne    803681 <__umoddi3+0x91>
  803676:	b8 01 00 00 00       	mov    $0x1,%eax
  80367b:	31 d2                	xor    %edx,%edx
  80367d:	f7 f7                	div    %edi
  80367f:	89 c5                	mov    %eax,%ebp
  803681:	89 f0                	mov    %esi,%eax
  803683:	31 d2                	xor    %edx,%edx
  803685:	f7 f5                	div    %ebp
  803687:	89 c8                	mov    %ecx,%eax
  803689:	f7 f5                	div    %ebp
  80368b:	89 d0                	mov    %edx,%eax
  80368d:	eb 99                	jmp    803628 <__umoddi3+0x38>
  80368f:	90                   	nop
  803690:	89 c8                	mov    %ecx,%eax
  803692:	89 f2                	mov    %esi,%edx
  803694:	83 c4 1c             	add    $0x1c,%esp
  803697:	5b                   	pop    %ebx
  803698:	5e                   	pop    %esi
  803699:	5f                   	pop    %edi
  80369a:	5d                   	pop    %ebp
  80369b:	c3                   	ret    
  80369c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8036a0:	8b 34 24             	mov    (%esp),%esi
  8036a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8036a8:	89 e9                	mov    %ebp,%ecx
  8036aa:	29 ef                	sub    %ebp,%edi
  8036ac:	d3 e0                	shl    %cl,%eax
  8036ae:	89 f9                	mov    %edi,%ecx
  8036b0:	89 f2                	mov    %esi,%edx
  8036b2:	d3 ea                	shr    %cl,%edx
  8036b4:	89 e9                	mov    %ebp,%ecx
  8036b6:	09 c2                	or     %eax,%edx
  8036b8:	89 d8                	mov    %ebx,%eax
  8036ba:	89 14 24             	mov    %edx,(%esp)
  8036bd:	89 f2                	mov    %esi,%edx
  8036bf:	d3 e2                	shl    %cl,%edx
  8036c1:	89 f9                	mov    %edi,%ecx
  8036c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8036c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8036cb:	d3 e8                	shr    %cl,%eax
  8036cd:	89 e9                	mov    %ebp,%ecx
  8036cf:	89 c6                	mov    %eax,%esi
  8036d1:	d3 e3                	shl    %cl,%ebx
  8036d3:	89 f9                	mov    %edi,%ecx
  8036d5:	89 d0                	mov    %edx,%eax
  8036d7:	d3 e8                	shr    %cl,%eax
  8036d9:	89 e9                	mov    %ebp,%ecx
  8036db:	09 d8                	or     %ebx,%eax
  8036dd:	89 d3                	mov    %edx,%ebx
  8036df:	89 f2                	mov    %esi,%edx
  8036e1:	f7 34 24             	divl   (%esp)
  8036e4:	89 d6                	mov    %edx,%esi
  8036e6:	d3 e3                	shl    %cl,%ebx
  8036e8:	f7 64 24 04          	mull   0x4(%esp)
  8036ec:	39 d6                	cmp    %edx,%esi
  8036ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8036f2:	89 d1                	mov    %edx,%ecx
  8036f4:	89 c3                	mov    %eax,%ebx
  8036f6:	72 08                	jb     803700 <__umoddi3+0x110>
  8036f8:	75 11                	jne    80370b <__umoddi3+0x11b>
  8036fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8036fe:	73 0b                	jae    80370b <__umoddi3+0x11b>
  803700:	2b 44 24 04          	sub    0x4(%esp),%eax
  803704:	1b 14 24             	sbb    (%esp),%edx
  803707:	89 d1                	mov    %edx,%ecx
  803709:	89 c3                	mov    %eax,%ebx
  80370b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80370f:	29 da                	sub    %ebx,%edx
  803711:	19 ce                	sbb    %ecx,%esi
  803713:	89 f9                	mov    %edi,%ecx
  803715:	89 f0                	mov    %esi,%eax
  803717:	d3 e0                	shl    %cl,%eax
  803719:	89 e9                	mov    %ebp,%ecx
  80371b:	d3 ea                	shr    %cl,%edx
  80371d:	89 e9                	mov    %ebp,%ecx
  80371f:	d3 ee                	shr    %cl,%esi
  803721:	09 d0                	or     %edx,%eax
  803723:	89 f2                	mov    %esi,%edx
  803725:	83 c4 1c             	add    $0x1c,%esp
  803728:	5b                   	pop    %ebx
  803729:	5e                   	pop    %esi
  80372a:	5f                   	pop    %edi
  80372b:	5d                   	pop    %ebp
  80372c:	c3                   	ret    
  80372d:	8d 76 00             	lea    0x0(%esi),%esi
  803730:	29 f9                	sub    %edi,%ecx
  803732:	19 d6                	sbb    %edx,%esi
  803734:	89 74 24 04          	mov    %esi,0x4(%esp)
  803738:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80373c:	e9 18 ff ff ff       	jmp    803659 <__umoddi3+0x69>
