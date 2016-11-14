
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 f0 11 f0       	mov    $0xf011f000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 b0 00 00 00       	call   f01000ee <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:


// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 20 67 10 f0       	push   $0xf0106720
f0100050:	e8 5b 3a 00 00       	call   f0103ab0 <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
	else
		mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 0a 09 00 00       	call   f0100985 <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 3c 67 10 f0       	push   $0xf010673c
f0100087:	e8 24 3a 00 00       	call   f0103ab0 <cprintf>
}
f010008c:	83 c4 10             	add    $0x10,%esp
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	56                   	push   %esi
f0100098:	53                   	push   %ebx
f0100099:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010009c:	83 3d 80 7e 22 f0 00 	cmpl   $0x0,0xf0227e80
f01000a3:	75 3a                	jne    f01000df <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f01000a5:	89 35 80 7e 22 f0    	mov    %esi,0xf0227e80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000ab:	fa                   	cli    
f01000ac:	fc                   	cld    

	va_start(ap, fmt);
f01000ad:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01000b0:	e8 c7 5f 00 00       	call   f010607c <cpunum>
f01000b5:	ff 75 0c             	pushl  0xc(%ebp)
f01000b8:	ff 75 08             	pushl  0x8(%ebp)
f01000bb:	50                   	push   %eax
f01000bc:	68 38 68 10 f0       	push   $0xf0106838
f01000c1:	e8 ea 39 00 00       	call   f0103ab0 <cprintf>
	vcprintf(fmt, ap);
f01000c6:	83 c4 08             	add    $0x8,%esp
f01000c9:	53                   	push   %ebx
f01000ca:	56                   	push   %esi
f01000cb:	e8 ba 39 00 00       	call   f0103a8a <vcprintf>
	cprintf("\n");
f01000d0:	c7 04 24 c2 67 10 f0 	movl   $0xf01067c2,(%esp)
f01000d7:	e8 d4 39 00 00       	call   f0103ab0 <cprintf>
	va_end(ap);
f01000dc:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000df:	83 ec 0c             	sub    $0xc,%esp
f01000e2:	6a 00                	push   $0x0
f01000e4:	e8 af 09 00 00       	call   f0100a98 <monitor>
f01000e9:	83 c4 10             	add    $0x10,%esp
f01000ec:	eb f1                	jmp    f01000df <_panic+0x4b>

f01000ee <i386_init>:
	cprintf("leaving test_backtrace %d\n", x);
}

void
i386_init(void)
{
f01000ee:	55                   	push   %ebp
f01000ef:	89 e5                	mov    %esp,%ebp
f01000f1:	56                   	push   %esi
f01000f2:	53                   	push   %ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000f3:	83 ec 04             	sub    $0x4,%esp
f01000f6:	b8 08 90 26 f0       	mov    $0xf0269008,%eax
f01000fb:	2d 08 61 22 f0       	sub    $0xf0226108,%eax
f0100100:	50                   	push   %eax
f0100101:	6a 00                	push   $0x0
f0100103:	68 08 61 22 f0       	push   $0xf0226108
f0100108:	e8 4f 59 00 00       	call   f0105a5c <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010010d:	e8 3c 06 00 00       	call   f010074e <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100112:	83 c4 08             	add    $0x8,%esp
f0100115:	68 ac 1a 00 00       	push   $0x1aac
f010011a:	68 57 67 10 f0       	push   $0xf0106757
f010011f:	e8 8c 39 00 00       	call   f0103ab0 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100124:	e8 88 15 00 00       	call   f01016b1 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100129:	e8 0b 32 00 00       	call   f0103339 <env_init>
	trap_init();
f010012e:	e8 50 3a 00 00       	call   f0103b83 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f0100133:	e8 3c 5c 00 00       	call   f0105d74 <mp_init>
	lapic_init();
f0100138:	e8 5a 5f 00 00       	call   f0106097 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010013d:	e8 95 38 00 00       	call   f01039d7 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100142:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100149:	e8 9c 61 00 00       	call   f01062ea <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010014e:	83 c4 10             	add    $0x10,%esp
f0100151:	83 3d 90 7e 22 f0 07 	cmpl   $0x7,0xf0227e90
f0100158:	77 16                	ja     f0100170 <i386_init+0x82>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010015a:	68 00 70 00 00       	push   $0x7000
f010015f:	68 5c 68 10 f0       	push   $0xf010685c
f0100164:	6a 62                	push   $0x62
f0100166:	68 72 67 10 f0       	push   $0xf0106772
f010016b:	e8 24 ff ff ff       	call   f0100094 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100170:	bb da 5c 10 f0       	mov    $0xf0105cda,%ebx
f0100175:	81 eb 60 5c 10 f0    	sub    $0xf0105c60,%ebx
f010017b:	83 ec 04             	sub    $0x4,%esp
f010017e:	53                   	push   %ebx
f010017f:	68 60 5c 10 f0       	push   $0xf0105c60
f0100184:	68 00 70 00 f0       	push   $0xf0007000
f0100189:	e8 1b 59 00 00       	call   f0105aa9 <memmove>
	cprintf("code size: %x\n", mpentry_end - mpentry_start);
f010018e:	83 c4 08             	add    $0x8,%esp
f0100191:	53                   	push   %ebx
f0100192:	68 7e 67 10 f0       	push   $0xf010677e
f0100197:	e8 14 39 00 00       	call   f0103ab0 <cprintf>
	cprintf("code addr: %x, mpentry_start addr: %x\n",
f010019c:	83 c4 0c             	add    $0xc,%esp
f010019f:	68 60 5c 10 f0       	push   $0xf0105c60
f01001a4:	68 00 70 00 f0       	push   $0xf0007000
f01001a9:	68 80 68 10 f0       	push   $0xf0106880
f01001ae:	e8 fd 38 00 00       	call   f0103ab0 <cprintf>
		code, mpentry_start);
	// Boot each AP one at a time
	cprintf("boot_aps:cpus: %x\n", cpus);
f01001b3:	83 c4 08             	add    $0x8,%esp
f01001b6:	68 20 80 22 f0       	push   $0xf0228020
f01001bb:	68 8d 67 10 f0       	push   $0xf010678d
f01001c0:	e8 eb 38 00 00       	call   f0103ab0 <cprintf>
	cprintf("ncpu: %x, CpuInfo size: %x\n", ncpu, sizeof(struct CpuInfo));
f01001c5:	83 c4 0c             	add    $0xc,%esp
f01001c8:	6a 74                	push   $0x74
f01001ca:	ff 35 c4 83 22 f0    	pushl  0xf02283c4
f01001d0:	68 a0 67 10 f0       	push   $0xf01067a0
f01001d5:	e8 d6 38 00 00       	call   f0103ab0 <cprintf>
f01001da:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f01001dd:	bb 20 80 22 f0       	mov    $0xf0228020,%ebx
f01001e2:	e9 a3 00 00 00       	jmp    f010028a <i386_init+0x19c>
		cprintf("c: %x\n\n", c-cpus);
f01001e7:	89 de                	mov    %ebx,%esi
f01001e9:	81 ee 20 80 22 f0    	sub    $0xf0228020,%esi
f01001ef:	c1 fe 02             	sar    $0x2,%esi
f01001f2:	69 f6 35 c2 72 4f    	imul   $0x4f72c235,%esi,%esi
f01001f8:	83 ec 08             	sub    $0x8,%esp
f01001fb:	56                   	push   %esi
f01001fc:	68 bc 67 10 f0       	push   $0xf01067bc
f0100201:	e8 aa 38 00 00       	call   f0103ab0 <cprintf>
		if (c == cpus + cpunum())  // We've started already.
f0100206:	e8 71 5e 00 00       	call   f010607c <cpunum>
f010020b:	6b c0 74             	imul   $0x74,%eax,%eax
f010020e:	05 20 80 22 f0       	add    $0xf0228020,%eax
f0100213:	83 c4 10             	add    $0x10,%esp
f0100216:	39 c3                	cmp    %eax,%ebx
f0100218:	74 6d                	je     f0100287 <i386_init+0x199>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010021a:	89 f0                	mov    %esi,%eax
f010021c:	c1 e0 0f             	shl    $0xf,%eax
f010021f:	05 00 10 23 f0       	add    $0xf0231000,%eax
f0100224:	a3 84 7e 22 f0       	mov    %eax,0xf0227e84
		cprintf("mpentry_kstack: %x\n", mpentry_kstack);
f0100229:	83 ec 08             	sub    $0x8,%esp
f010022c:	50                   	push   %eax
f010022d:	68 c4 67 10 f0       	push   $0xf01067c4
f0100232:	e8 79 38 00 00       	call   f0103ab0 <cprintf>
		// Start the CPU at mpentry_start
		cprintf("code: %x\n", code);
f0100237:	83 c4 08             	add    $0x8,%esp
f010023a:	68 00 70 00 f0       	push   $0xf0007000
f010023f:	68 d8 67 10 f0       	push   $0xf01067d8
f0100244:	e8 67 38 00 00       	call   f0103ab0 <cprintf>
		lapic_startap(c->cpu_id, PADDR(code));
f0100249:	83 c4 08             	add    $0x8,%esp
f010024c:	68 00 70 00 00       	push   $0x7000
f0100251:	0f b6 03             	movzbl (%ebx),%eax
f0100254:	50                   	push   %eax
f0100255:	e8 8b 5f 00 00       	call   f01061e5 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		cprintf("c->cpu_status: %x\n", c->cpu_status);
f010025a:	8b 43 04             	mov    0x4(%ebx),%eax
f010025d:	83 c4 08             	add    $0x8,%esp
f0100260:	50                   	push   %eax
f0100261:	68 e2 67 10 f0       	push   $0xf01067e2
f0100266:	e8 45 38 00 00       	call   f0103ab0 <cprintf>
f010026b:	83 c4 10             	add    $0x10,%esp
		while(c->cpu_status != CPU_STARTED)
f010026e:	8b 43 04             	mov    0x4(%ebx),%eax
f0100271:	83 f8 01             	cmp    $0x1,%eax
f0100274:	75 f8                	jne    f010026e <i386_init+0x180>
			;
		cprintf("cpu %x started\n", c-cpus);
f0100276:	83 ec 08             	sub    $0x8,%esp
f0100279:	56                   	push   %esi
f010027a:	68 f5 67 10 f0       	push   $0xf01067f5
f010027f:	e8 2c 38 00 00       	call   f0103ab0 <cprintf>
f0100284:	83 c4 10             	add    $0x10,%esp
	cprintf("code addr: %x, mpentry_start addr: %x\n",
		code, mpentry_start);
	// Boot each AP one at a time
	cprintf("boot_aps:cpus: %x\n", cpus);
	cprintf("ncpu: %x, CpuInfo size: %x\n", ncpu, sizeof(struct CpuInfo));
	for (c = cpus; c < cpus + ncpu; c++) {
f0100287:	83 c3 74             	add    $0x74,%ebx
f010028a:	6b 05 c4 83 22 f0 74 	imul   $0x74,0xf02283c4,%eax
f0100291:	05 20 80 22 f0       	add    $0xf0228020,%eax
f0100296:	39 c3                	cmp    %eax,%ebx
f0100298:	0f 82 49 ff ff ff    	jb     f01001e7 <i386_init+0xf9>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010029e:	83 ec 04             	sub    $0x4,%esp
f01002a1:	6a 00                	push   $0x0
f01002a3:	68 00 8a 00 00       	push   $0x8a00
f01002a8:	68 a8 a7 1a f0       	push   $0xf01aa7a8
f01002ad:	e8 54 32 00 00       	call   f0103506 <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
	ENV_CREATE(user_yield, ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01002b2:	e8 34 46 00 00       	call   f01048eb <sched_yield>

f01002b7 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01002b7:	55                   	push   %ebp
f01002b8:	89 e5                	mov    %esp,%ebp
f01002ba:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01002bd:	a1 94 7e 22 f0       	mov    0xf0227e94,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01002c2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01002c7:	77 15                	ja     f01002de <mp_main+0x27>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01002c9:	50                   	push   %eax
f01002ca:	68 a8 68 10 f0       	push   $0xf01068a8
f01002cf:	68 82 00 00 00       	push   $0x82
f01002d4:	68 72 67 10 f0       	push   $0xf0106772
f01002d9:	e8 b6 fd ff ff       	call   f0100094 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01002de:	05 00 00 00 10       	add    $0x10000000,%eax
f01002e3:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01002e6:	e8 91 5d 00 00       	call   f010607c <cpunum>
f01002eb:	83 ec 08             	sub    $0x8,%esp
f01002ee:	50                   	push   %eax
f01002ef:	68 05 68 10 f0       	push   $0xf0106805
f01002f4:	e8 b7 37 00 00       	call   f0103ab0 <cprintf>

	lapic_init();
f01002f9:	e8 99 5d 00 00       	call   f0106097 <lapic_init>
	// cprintf("lapic_init done\n");
	env_init_percpu();
f01002fe:	e8 06 30 00 00       	call   f0103309 <env_init_percpu>
	// cprintf("env_init_percpu done\n");
	trap_init_percpu();
f0100303:	e8 bc 37 00 00       	call   f0103ac4 <trap_init_percpu>
	// cprintf("trap_init_percpu done\n");
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100308:	e8 6f 5d 00 00       	call   f010607c <cpunum>
f010030d:	6b d0 74             	imul   $0x74,%eax,%edx
f0100310:	81 c2 20 80 22 f0    	add    $0xf0228020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100316:	b8 01 00 00 00       	mov    $0x1,%eax
f010031b:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010031f:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100326:	e8 bf 5f 00 00       	call   f01062ea <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f010032b:	e8 bb 45 00 00       	call   f01048eb <sched_yield>

f0100330 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100330:	55                   	push   %ebp
f0100331:	89 e5                	mov    %esp,%ebp
f0100333:	53                   	push   %ebx
f0100334:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100337:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010033a:	ff 75 0c             	pushl  0xc(%ebp)
f010033d:	ff 75 08             	pushl  0x8(%ebp)
f0100340:	68 1b 68 10 f0       	push   $0xf010681b
f0100345:	e8 66 37 00 00       	call   f0103ab0 <cprintf>
	vcprintf(fmt, ap);
f010034a:	83 c4 08             	add    $0x8,%esp
f010034d:	53                   	push   %ebx
f010034e:	ff 75 10             	pushl  0x10(%ebp)
f0100351:	e8 34 37 00 00       	call   f0103a8a <vcprintf>
	cprintf("\n");
f0100356:	c7 04 24 c2 67 10 f0 	movl   $0xf01067c2,(%esp)
f010035d:	e8 4e 37 00 00       	call   f0103ab0 <cprintf>
	va_end(ap);
}
f0100362:	83 c4 10             	add    $0x10,%esp
f0100365:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100368:	c9                   	leave  
f0100369:	c3                   	ret    

f010036a <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010036a:	55                   	push   %ebp
f010036b:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010036d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100372:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100373:	a8 01                	test   $0x1,%al
f0100375:	74 0b                	je     f0100382 <serial_proc_data+0x18>
f0100377:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010037c:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010037d:	0f b6 c0             	movzbl %al,%eax
f0100380:	eb 05                	jmp    f0100387 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100382:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100387:	5d                   	pop    %ebp
f0100388:	c3                   	ret    

f0100389 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100389:	55                   	push   %ebp
f010038a:	89 e5                	mov    %esp,%ebp
f010038c:	53                   	push   %ebx
f010038d:	83 ec 04             	sub    $0x4,%esp
f0100390:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100392:	eb 2b                	jmp    f01003bf <cons_intr+0x36>
		if (c == 0)
f0100394:	85 c0                	test   %eax,%eax
f0100396:	74 27                	je     f01003bf <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100398:	8b 0d 24 72 22 f0    	mov    0xf0227224,%ecx
f010039e:	8d 51 01             	lea    0x1(%ecx),%edx
f01003a1:	89 15 24 72 22 f0    	mov    %edx,0xf0227224
f01003a7:	88 81 20 70 22 f0    	mov    %al,-0xfdd8fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01003ad:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01003b3:	75 0a                	jne    f01003bf <cons_intr+0x36>
			cons.wpos = 0;
f01003b5:	c7 05 24 72 22 f0 00 	movl   $0x0,0xf0227224
f01003bc:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01003bf:	ff d3                	call   *%ebx
f01003c1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01003c4:	75 ce                	jne    f0100394 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01003c6:	83 c4 04             	add    $0x4,%esp
f01003c9:	5b                   	pop    %ebx
f01003ca:	5d                   	pop    %ebp
f01003cb:	c3                   	ret    

f01003cc <kbd_proc_data>:
f01003cc:	ba 64 00 00 00       	mov    $0x64,%edx
f01003d1:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01003d2:	a8 01                	test   $0x1,%al
f01003d4:	0f 84 f0 00 00 00    	je     f01004ca <kbd_proc_data+0xfe>
f01003da:	ba 60 00 00 00       	mov    $0x60,%edx
f01003df:	ec                   	in     (%dx),%al
f01003e0:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01003e2:	3c e0                	cmp    $0xe0,%al
f01003e4:	75 0d                	jne    f01003f3 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01003e6:	83 0d 00 70 22 f0 40 	orl    $0x40,0xf0227000
		return 0;
f01003ed:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01003f2:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01003f3:	55                   	push   %ebp
f01003f4:	89 e5                	mov    %esp,%ebp
f01003f6:	53                   	push   %ebx
f01003f7:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01003fa:	84 c0                	test   %al,%al
f01003fc:	79 36                	jns    f0100434 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003fe:	8b 0d 00 70 22 f0    	mov    0xf0227000,%ecx
f0100404:	89 cb                	mov    %ecx,%ebx
f0100406:	83 e3 40             	and    $0x40,%ebx
f0100409:	83 e0 7f             	and    $0x7f,%eax
f010040c:	85 db                	test   %ebx,%ebx
f010040e:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100411:	0f b6 d2             	movzbl %dl,%edx
f0100414:	0f b6 82 20 6a 10 f0 	movzbl -0xfef95e0(%edx),%eax
f010041b:	83 c8 40             	or     $0x40,%eax
f010041e:	0f b6 c0             	movzbl %al,%eax
f0100421:	f7 d0                	not    %eax
f0100423:	21 c8                	and    %ecx,%eax
f0100425:	a3 00 70 22 f0       	mov    %eax,0xf0227000
		return 0;
f010042a:	b8 00 00 00 00       	mov    $0x0,%eax
f010042f:	e9 9e 00 00 00       	jmp    f01004d2 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f0100434:	8b 0d 00 70 22 f0    	mov    0xf0227000,%ecx
f010043a:	f6 c1 40             	test   $0x40,%cl
f010043d:	74 0e                	je     f010044d <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010043f:	83 c8 80             	or     $0xffffff80,%eax
f0100442:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100444:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100447:	89 0d 00 70 22 f0    	mov    %ecx,0xf0227000
	}

	shift |= shiftcode[data];
f010044d:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100450:	0f b6 82 20 6a 10 f0 	movzbl -0xfef95e0(%edx),%eax
f0100457:	0b 05 00 70 22 f0    	or     0xf0227000,%eax
f010045d:	0f b6 8a 20 69 10 f0 	movzbl -0xfef96e0(%edx),%ecx
f0100464:	31 c8                	xor    %ecx,%eax
f0100466:	a3 00 70 22 f0       	mov    %eax,0xf0227000

	c = charcode[shift & (CTL | SHIFT)][data];
f010046b:	89 c1                	mov    %eax,%ecx
f010046d:	83 e1 03             	and    $0x3,%ecx
f0100470:	8b 0c 8d 00 69 10 f0 	mov    -0xfef9700(,%ecx,4),%ecx
f0100477:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010047b:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010047e:	a8 08                	test   $0x8,%al
f0100480:	74 1b                	je     f010049d <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100482:	89 da                	mov    %ebx,%edx
f0100484:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100487:	83 f9 19             	cmp    $0x19,%ecx
f010048a:	77 05                	ja     f0100491 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f010048c:	83 eb 20             	sub    $0x20,%ebx
f010048f:	eb 0c                	jmp    f010049d <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f0100491:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100494:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100497:	83 fa 19             	cmp    $0x19,%edx
f010049a:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010049d:	f7 d0                	not    %eax
f010049f:	a8 06                	test   $0x6,%al
f01004a1:	75 2d                	jne    f01004d0 <kbd_proc_data+0x104>
f01004a3:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01004a9:	75 25                	jne    f01004d0 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01004ab:	83 ec 0c             	sub    $0xc,%esp
f01004ae:	68 cc 68 10 f0       	push   $0xf01068cc
f01004b3:	e8 f8 35 00 00       	call   f0103ab0 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004b8:	ba 92 00 00 00       	mov    $0x92,%edx
f01004bd:	b8 03 00 00 00       	mov    $0x3,%eax
f01004c2:	ee                   	out    %al,(%dx)
f01004c3:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01004c6:	89 d8                	mov    %ebx,%eax
f01004c8:	eb 08                	jmp    f01004d2 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01004ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01004cf:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01004d0:	89 d8                	mov    %ebx,%eax
}
f01004d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01004d5:	c9                   	leave  
f01004d6:	c3                   	ret    

f01004d7 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01004d7:	55                   	push   %ebp
f01004d8:	89 e5                	mov    %esp,%ebp
f01004da:	57                   	push   %edi
f01004db:	56                   	push   %esi
f01004dc:	53                   	push   %ebx
f01004dd:	83 ec 1c             	sub    $0x1c,%esp
f01004e0:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01004e2:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004e7:	be fd 03 00 00       	mov    $0x3fd,%esi
f01004ec:	b9 84 00 00 00       	mov    $0x84,%ecx
f01004f1:	eb 09                	jmp    f01004fc <cons_putc+0x25>
f01004f3:	89 ca                	mov    %ecx,%edx
f01004f5:	ec                   	in     (%dx),%al
f01004f6:	ec                   	in     (%dx),%al
f01004f7:	ec                   	in     (%dx),%al
f01004f8:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01004f9:	83 c3 01             	add    $0x1,%ebx
f01004fc:	89 f2                	mov    %esi,%edx
f01004fe:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01004ff:	a8 20                	test   $0x20,%al
f0100501:	75 08                	jne    f010050b <cons_putc+0x34>
f0100503:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100509:	7e e8                	jle    f01004f3 <cons_putc+0x1c>
f010050b:	89 f8                	mov    %edi,%eax
f010050d:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100510:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100515:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100516:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010051b:	be 79 03 00 00       	mov    $0x379,%esi
f0100520:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100525:	eb 09                	jmp    f0100530 <cons_putc+0x59>
f0100527:	89 ca                	mov    %ecx,%edx
f0100529:	ec                   	in     (%dx),%al
f010052a:	ec                   	in     (%dx),%al
f010052b:	ec                   	in     (%dx),%al
f010052c:	ec                   	in     (%dx),%al
f010052d:	83 c3 01             	add    $0x1,%ebx
f0100530:	89 f2                	mov    %esi,%edx
f0100532:	ec                   	in     (%dx),%al
f0100533:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100539:	7f 04                	jg     f010053f <cons_putc+0x68>
f010053b:	84 c0                	test   %al,%al
f010053d:	79 e8                	jns    f0100527 <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010053f:	ba 78 03 00 00       	mov    $0x378,%edx
f0100544:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100548:	ee                   	out    %al,(%dx)
f0100549:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010054e:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100553:	ee                   	out    %al,(%dx)
f0100554:	b8 08 00 00 00       	mov    $0x8,%eax
f0100559:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!csa) csa = 0x0700;
f010055a:	83 3d 88 7e 22 f0 00 	cmpl   $0x0,0xf0227e88
f0100561:	75 0a                	jne    f010056d <cons_putc+0x96>
f0100563:	c7 05 88 7e 22 f0 00 	movl   $0x700,0xf0227e88
f010056a:	07 00 00 
	if (!(c & ~0xFF))
f010056d:	89 fa                	mov    %edi,%edx
f010056f:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= csa;
f0100575:	89 f8                	mov    %edi,%eax
f0100577:	0b 05 88 7e 22 f0    	or     0xf0227e88,%eax
f010057d:	85 d2                	test   %edx,%edx
f010057f:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100582:	89 f8                	mov    %edi,%eax
f0100584:	0f b6 c0             	movzbl %al,%eax
f0100587:	83 f8 09             	cmp    $0x9,%eax
f010058a:	74 74                	je     f0100600 <cons_putc+0x129>
f010058c:	83 f8 09             	cmp    $0x9,%eax
f010058f:	7f 0a                	jg     f010059b <cons_putc+0xc4>
f0100591:	83 f8 08             	cmp    $0x8,%eax
f0100594:	74 14                	je     f01005aa <cons_putc+0xd3>
f0100596:	e9 99 00 00 00       	jmp    f0100634 <cons_putc+0x15d>
f010059b:	83 f8 0a             	cmp    $0xa,%eax
f010059e:	74 3a                	je     f01005da <cons_putc+0x103>
f01005a0:	83 f8 0d             	cmp    $0xd,%eax
f01005a3:	74 3d                	je     f01005e2 <cons_putc+0x10b>
f01005a5:	e9 8a 00 00 00       	jmp    f0100634 <cons_putc+0x15d>
	case '\b':
		if (crt_pos > 0) {
f01005aa:	0f b7 05 28 72 22 f0 	movzwl 0xf0227228,%eax
f01005b1:	66 85 c0             	test   %ax,%ax
f01005b4:	0f 84 e6 00 00 00    	je     f01006a0 <cons_putc+0x1c9>
			crt_pos--;
f01005ba:	83 e8 01             	sub    $0x1,%eax
f01005bd:	66 a3 28 72 22 f0    	mov    %ax,0xf0227228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01005c3:	0f b7 c0             	movzwl %ax,%eax
f01005c6:	66 81 e7 00 ff       	and    $0xff00,%di
f01005cb:	83 cf 20             	or     $0x20,%edi
f01005ce:	8b 15 2c 72 22 f0    	mov    0xf022722c,%edx
f01005d4:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01005d8:	eb 78                	jmp    f0100652 <cons_putc+0x17b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01005da:	66 83 05 28 72 22 f0 	addw   $0x50,0xf0227228
f01005e1:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01005e2:	0f b7 05 28 72 22 f0 	movzwl 0xf0227228,%eax
f01005e9:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01005ef:	c1 e8 16             	shr    $0x16,%eax
f01005f2:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01005f5:	c1 e0 04             	shl    $0x4,%eax
f01005f8:	66 a3 28 72 22 f0    	mov    %ax,0xf0227228
f01005fe:	eb 52                	jmp    f0100652 <cons_putc+0x17b>
		break;
	case '\t':
		cons_putc(' ');
f0100600:	b8 20 00 00 00       	mov    $0x20,%eax
f0100605:	e8 cd fe ff ff       	call   f01004d7 <cons_putc>
		cons_putc(' ');
f010060a:	b8 20 00 00 00       	mov    $0x20,%eax
f010060f:	e8 c3 fe ff ff       	call   f01004d7 <cons_putc>
		cons_putc(' ');
f0100614:	b8 20 00 00 00       	mov    $0x20,%eax
f0100619:	e8 b9 fe ff ff       	call   f01004d7 <cons_putc>
		cons_putc(' ');
f010061e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100623:	e8 af fe ff ff       	call   f01004d7 <cons_putc>
		cons_putc(' ');
f0100628:	b8 20 00 00 00       	mov    $0x20,%eax
f010062d:	e8 a5 fe ff ff       	call   f01004d7 <cons_putc>
f0100632:	eb 1e                	jmp    f0100652 <cons_putc+0x17b>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100634:	0f b7 05 28 72 22 f0 	movzwl 0xf0227228,%eax
f010063b:	8d 50 01             	lea    0x1(%eax),%edx
f010063e:	66 89 15 28 72 22 f0 	mov    %dx,0xf0227228
f0100645:	0f b7 c0             	movzwl %ax,%eax
f0100648:	8b 15 2c 72 22 f0    	mov    0xf022722c,%edx
f010064e:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100652:	66 81 3d 28 72 22 f0 	cmpw   $0x7cf,0xf0227228
f0100659:	cf 07 
f010065b:	76 43                	jbe    f01006a0 <cons_putc+0x1c9>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010065d:	a1 2c 72 22 f0       	mov    0xf022722c,%eax
f0100662:	83 ec 04             	sub    $0x4,%esp
f0100665:	68 00 0f 00 00       	push   $0xf00
f010066a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100670:	52                   	push   %edx
f0100671:	50                   	push   %eax
f0100672:	e8 32 54 00 00       	call   f0105aa9 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100677:	8b 15 2c 72 22 f0    	mov    0xf022722c,%edx
f010067d:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100683:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100689:	83 c4 10             	add    $0x10,%esp
f010068c:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100691:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100694:	39 d0                	cmp    %edx,%eax
f0100696:	75 f4                	jne    f010068c <cons_putc+0x1b5>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100698:	66 83 2d 28 72 22 f0 	subw   $0x50,0xf0227228
f010069f:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01006a0:	8b 0d 30 72 22 f0    	mov    0xf0227230,%ecx
f01006a6:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006ab:	89 ca                	mov    %ecx,%edx
f01006ad:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01006ae:	0f b7 1d 28 72 22 f0 	movzwl 0xf0227228,%ebx
f01006b5:	8d 71 01             	lea    0x1(%ecx),%esi
f01006b8:	89 d8                	mov    %ebx,%eax
f01006ba:	66 c1 e8 08          	shr    $0x8,%ax
f01006be:	89 f2                	mov    %esi,%edx
f01006c0:	ee                   	out    %al,(%dx)
f01006c1:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006c6:	89 ca                	mov    %ecx,%edx
f01006c8:	ee                   	out    %al,(%dx)
f01006c9:	89 d8                	mov    %ebx,%eax
f01006cb:	89 f2                	mov    %esi,%edx
f01006cd:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01006ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006d1:	5b                   	pop    %ebx
f01006d2:	5e                   	pop    %esi
f01006d3:	5f                   	pop    %edi
f01006d4:	5d                   	pop    %ebp
f01006d5:	c3                   	ret    

f01006d6 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01006d6:	80 3d 34 72 22 f0 00 	cmpb   $0x0,0xf0227234
f01006dd:	74 11                	je     f01006f0 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01006df:	55                   	push   %ebp
f01006e0:	89 e5                	mov    %esp,%ebp
f01006e2:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01006e5:	b8 6a 03 10 f0       	mov    $0xf010036a,%eax
f01006ea:	e8 9a fc ff ff       	call   f0100389 <cons_intr>
}
f01006ef:	c9                   	leave  
f01006f0:	f3 c3                	repz ret 

f01006f2 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01006f2:	55                   	push   %ebp
f01006f3:	89 e5                	mov    %esp,%ebp
f01006f5:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01006f8:	b8 cc 03 10 f0       	mov    $0xf01003cc,%eax
f01006fd:	e8 87 fc ff ff       	call   f0100389 <cons_intr>
}
f0100702:	c9                   	leave  
f0100703:	c3                   	ret    

f0100704 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100704:	55                   	push   %ebp
f0100705:	89 e5                	mov    %esp,%ebp
f0100707:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010070a:	e8 c7 ff ff ff       	call   f01006d6 <serial_intr>
	kbd_intr();
f010070f:	e8 de ff ff ff       	call   f01006f2 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100714:	a1 20 72 22 f0       	mov    0xf0227220,%eax
f0100719:	3b 05 24 72 22 f0    	cmp    0xf0227224,%eax
f010071f:	74 26                	je     f0100747 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100721:	8d 50 01             	lea    0x1(%eax),%edx
f0100724:	89 15 20 72 22 f0    	mov    %edx,0xf0227220
f010072a:	0f b6 88 20 70 22 f0 	movzbl -0xfdd8fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100731:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100733:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100739:	75 11                	jne    f010074c <cons_getc+0x48>
			cons.rpos = 0;
f010073b:	c7 05 20 72 22 f0 00 	movl   $0x0,0xf0227220
f0100742:	00 00 00 
f0100745:	eb 05                	jmp    f010074c <cons_getc+0x48>
		return c;
	}
	return 0;
f0100747:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010074c:	c9                   	leave  
f010074d:	c3                   	ret    

f010074e <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010074e:	55                   	push   %ebp
f010074f:	89 e5                	mov    %esp,%ebp
f0100751:	57                   	push   %edi
f0100752:	56                   	push   %esi
f0100753:	53                   	push   %ebx
f0100754:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100757:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010075e:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100765:	5a a5 
	if (*cp != 0xA55A) {
f0100767:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010076e:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100772:	74 11                	je     f0100785 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100774:	c7 05 30 72 22 f0 b4 	movl   $0x3b4,0xf0227230
f010077b:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010077e:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100783:	eb 16                	jmp    f010079b <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100785:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010078c:	c7 05 30 72 22 f0 d4 	movl   $0x3d4,0xf0227230
f0100793:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100796:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010079b:	8b 3d 30 72 22 f0    	mov    0xf0227230,%edi
f01007a1:	b8 0e 00 00 00       	mov    $0xe,%eax
f01007a6:	89 fa                	mov    %edi,%edx
f01007a8:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01007a9:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01007ac:	89 da                	mov    %ebx,%edx
f01007ae:	ec                   	in     (%dx),%al
f01007af:	0f b6 c8             	movzbl %al,%ecx
f01007b2:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01007b5:	b8 0f 00 00 00       	mov    $0xf,%eax
f01007ba:	89 fa                	mov    %edi,%edx
f01007bc:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01007bd:	89 da                	mov    %ebx,%edx
f01007bf:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01007c0:	89 35 2c 72 22 f0    	mov    %esi,0xf022722c
	crt_pos = pos;
f01007c6:	0f b6 c0             	movzbl %al,%eax
f01007c9:	09 c8                	or     %ecx,%eax
f01007cb:	66 a3 28 72 22 f0    	mov    %ax,0xf0227228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f01007d1:	e8 1c ff ff ff       	call   f01006f2 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01007d6:	83 ec 0c             	sub    $0xc,%esp
f01007d9:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f01007e0:	25 fd ff 00 00       	and    $0xfffd,%eax
f01007e5:	50                   	push   %eax
f01007e6:	e8 74 31 00 00       	call   f010395f <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01007eb:	be fa 03 00 00       	mov    $0x3fa,%esi
f01007f0:	b8 00 00 00 00       	mov    $0x0,%eax
f01007f5:	89 f2                	mov    %esi,%edx
f01007f7:	ee                   	out    %al,(%dx)
f01007f8:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01007fd:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100802:	ee                   	out    %al,(%dx)
f0100803:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100808:	b8 0c 00 00 00       	mov    $0xc,%eax
f010080d:	89 da                	mov    %ebx,%edx
f010080f:	ee                   	out    %al,(%dx)
f0100810:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100815:	b8 00 00 00 00       	mov    $0x0,%eax
f010081a:	ee                   	out    %al,(%dx)
f010081b:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100820:	b8 03 00 00 00       	mov    $0x3,%eax
f0100825:	ee                   	out    %al,(%dx)
f0100826:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010082b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100830:	ee                   	out    %al,(%dx)
f0100831:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100836:	b8 01 00 00 00       	mov    $0x1,%eax
f010083b:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010083c:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100841:	ec                   	in     (%dx),%al
f0100842:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100844:	83 c4 10             	add    $0x10,%esp
f0100847:	3c ff                	cmp    $0xff,%al
f0100849:	0f 95 05 34 72 22 f0 	setne  0xf0227234
f0100850:	89 f2                	mov    %esi,%edx
f0100852:	ec                   	in     (%dx),%al
f0100853:	89 da                	mov    %ebx,%edx
f0100855:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100856:	80 f9 ff             	cmp    $0xff,%cl
f0100859:	75 10                	jne    f010086b <cons_init+0x11d>
		cprintf("Serial port does not exist!\n");
f010085b:	83 ec 0c             	sub    $0xc,%esp
f010085e:	68 d8 68 10 f0       	push   $0xf01068d8
f0100863:	e8 48 32 00 00       	call   f0103ab0 <cprintf>
f0100868:	83 c4 10             	add    $0x10,%esp
}
f010086b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010086e:	5b                   	pop    %ebx
f010086f:	5e                   	pop    %esi
f0100870:	5f                   	pop    %edi
f0100871:	5d                   	pop    %ebp
f0100872:	c3                   	ret    

f0100873 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100873:	55                   	push   %ebp
f0100874:	89 e5                	mov    %esp,%ebp
f0100876:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100879:	8b 45 08             	mov    0x8(%ebp),%eax
f010087c:	e8 56 fc ff ff       	call   f01004d7 <cons_putc>
}
f0100881:	c9                   	leave  
f0100882:	c3                   	ret    

f0100883 <getchar>:

int
getchar(void)
{
f0100883:	55                   	push   %ebp
f0100884:	89 e5                	mov    %esp,%ebp
f0100886:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100889:	e8 76 fe ff ff       	call   f0100704 <cons_getc>
f010088e:	85 c0                	test   %eax,%eax
f0100890:	74 f7                	je     f0100889 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100892:	c9                   	leave  
f0100893:	c3                   	ret    

f0100894 <iscons>:

int
iscons(int fdnum)
{
f0100894:	55                   	push   %ebp
f0100895:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100897:	b8 01 00 00 00       	mov    $0x1,%eax
f010089c:	5d                   	pop    %ebp
f010089d:	c3                   	ret    

f010089e <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010089e:	55                   	push   %ebp
f010089f:	89 e5                	mov    %esp,%ebp
f01008a1:	56                   	push   %esi
f01008a2:	53                   	push   %ebx
f01008a3:	bb e4 6e 10 f0       	mov    $0xf0106ee4,%ebx
f01008a8:	be 50 6f 10 f0       	mov    $0xf0106f50,%esi
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01008ad:	83 ec 04             	sub    $0x4,%esp
f01008b0:	ff 33                	pushl  (%ebx)
f01008b2:	ff 73 fc             	pushl  -0x4(%ebx)
f01008b5:	68 20 6b 10 f0       	push   $0xf0106b20
f01008ba:	e8 f1 31 00 00       	call   f0103ab0 <cprintf>
f01008bf:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01008c2:	83 c4 10             	add    $0x10,%esp
f01008c5:	39 f3                	cmp    %esi,%ebx
f01008c7:	75 e4                	jne    f01008ad <mon_help+0xf>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01008c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01008ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01008d1:	5b                   	pop    %ebx
f01008d2:	5e                   	pop    %esi
f01008d3:	5d                   	pop    %ebp
f01008d4:	c3                   	ret    

f01008d5 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01008d5:	55                   	push   %ebp
f01008d6:	89 e5                	mov    %esp,%ebp
f01008d8:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01008db:	68 29 6b 10 f0       	push   $0xf0106b29
f01008e0:	e8 cb 31 00 00       	call   f0103ab0 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01008e5:	83 c4 08             	add    $0x8,%esp
f01008e8:	68 0c 00 10 00       	push   $0x10000c
f01008ed:	68 d4 6c 10 f0       	push   $0xf0106cd4
f01008f2:	e8 b9 31 00 00       	call   f0103ab0 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01008f7:	83 c4 0c             	add    $0xc,%esp
f01008fa:	68 0c 00 10 00       	push   $0x10000c
f01008ff:	68 0c 00 10 f0       	push   $0xf010000c
f0100904:	68 fc 6c 10 f0       	push   $0xf0106cfc
f0100909:	e8 a2 31 00 00       	call   f0103ab0 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010090e:	83 c4 0c             	add    $0xc,%esp
f0100911:	68 01 67 10 00       	push   $0x106701
f0100916:	68 01 67 10 f0       	push   $0xf0106701
f010091b:	68 20 6d 10 f0       	push   $0xf0106d20
f0100920:	e8 8b 31 00 00       	call   f0103ab0 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100925:	83 c4 0c             	add    $0xc,%esp
f0100928:	68 08 61 22 00       	push   $0x226108
f010092d:	68 08 61 22 f0       	push   $0xf0226108
f0100932:	68 44 6d 10 f0       	push   $0xf0106d44
f0100937:	e8 74 31 00 00       	call   f0103ab0 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010093c:	83 c4 0c             	add    $0xc,%esp
f010093f:	68 08 90 26 00       	push   $0x269008
f0100944:	68 08 90 26 f0       	push   $0xf0269008
f0100949:	68 68 6d 10 f0       	push   $0xf0106d68
f010094e:	e8 5d 31 00 00       	call   f0103ab0 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100953:	b8 07 94 26 f0       	mov    $0xf0269407,%eax
f0100958:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010095d:	83 c4 08             	add    $0x8,%esp
f0100960:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100965:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010096b:	85 c0                	test   %eax,%eax
f010096d:	0f 48 c2             	cmovs  %edx,%eax
f0100970:	c1 f8 0a             	sar    $0xa,%eax
f0100973:	50                   	push   %eax
f0100974:	68 8c 6d 10 f0       	push   $0xf0106d8c
f0100979:	e8 32 31 00 00       	call   f0103ab0 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010097e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100983:	c9                   	leave  
f0100984:	c3                   	ret    

f0100985 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100985:	55                   	push   %ebp
f0100986:	89 e5                	mov    %esp,%ebp
f0100988:	57                   	push   %edi
f0100989:	56                   	push   %esi
f010098a:	53                   	push   %ebx
f010098b:	83 ec 18             	sub    $0x18,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f010098e:	89 ee                	mov    %ebp,%esi
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
f0100990:	68 42 6b 10 f0       	push   $0xf0106b42
f0100995:	e8 16 31 00 00       	call   f0103ab0 <cprintf>
	while (ebp) {
f010099a:	83 c4 10             	add    $0x10,%esp
f010099d:	eb 45                	jmp    f01009e4 <mon_backtrace+0x5f>
		cprintf("ebp %x  eip %x  args", ebp, ebp[1]);
f010099f:	83 ec 04             	sub    $0x4,%esp
f01009a2:	ff 76 04             	pushl  0x4(%esi)
f01009a5:	56                   	push   %esi
f01009a6:	68 54 6b 10 f0       	push   $0xf0106b54
f01009ab:	e8 00 31 00 00       	call   f0103ab0 <cprintf>
f01009b0:	8d 5e 08             	lea    0x8(%esi),%ebx
f01009b3:	8d 7e 1c             	lea    0x1c(%esi),%edi
f01009b6:	83 c4 10             	add    $0x10,%esp
		int i;
		for (i = 2; i <= 6; ++i)
			cprintf(" %08.x", ebp[i]);
f01009b9:	83 ec 08             	sub    $0x8,%esp
f01009bc:	ff 33                	pushl  (%ebx)
f01009be:	68 69 6b 10 f0       	push   $0xf0106b69
f01009c3:	e8 e8 30 00 00       	call   f0103ab0 <cprintf>
f01009c8:	83 c3 04             	add    $0x4,%ebx
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp) {
		cprintf("ebp %x  eip %x  args", ebp, ebp[1]);
		int i;
		for (i = 2; i <= 6; ++i)
f01009cb:	83 c4 10             	add    $0x10,%esp
f01009ce:	39 fb                	cmp    %edi,%ebx
f01009d0:	75 e7                	jne    f01009b9 <mon_backtrace+0x34>
			cprintf(" %08.x", ebp[i]);
		cprintf("\n");
f01009d2:	83 ec 0c             	sub    $0xc,%esp
f01009d5:	68 c2 67 10 f0       	push   $0xf01067c2
f01009da:	e8 d1 30 00 00       	call   f0103ab0 <cprintf>
		ebp = (uint32_t*) *ebp;
f01009df:	8b 36                	mov    (%esi),%esi
f01009e1:	83 c4 10             	add    $0x10,%esp
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp) {
f01009e4:	85 f6                	test   %esi,%esi
f01009e6:	75 b7                	jne    f010099f <mon_backtrace+0x1a>
			cprintf(" %08.x", ebp[i]);
		cprintf("\n");
		ebp = (uint32_t*) *ebp;
	}
	return 0;
}
f01009e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01009ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009f0:	5b                   	pop    %ebx
f01009f1:	5e                   	pop    %esi
f01009f2:	5f                   	pop    %edi
f01009f3:	5d                   	pop    %ebp
f01009f4:	c3                   	ret    

f01009f5 <csa_backtrace>:

int
csa_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01009f5:	55                   	push   %ebp
f01009f6:	89 e5                	mov    %esp,%ebp
f01009f8:	57                   	push   %edi
f01009f9:	56                   	push   %esi
f01009fa:	53                   	push   %ebx
f01009fb:	83 ec 48             	sub    $0x48,%esp
f01009fe:	89 ee                	mov    %ebp,%esi
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
f0100a00:	68 42 6b 10 f0       	push   $0xf0106b42
f0100a05:	e8 a6 30 00 00       	call   f0103ab0 <cprintf>
	while (ebp) {
f0100a0a:	83 c4 10             	add    $0x10,%esp
f0100a0d:	eb 78                	jmp    f0100a87 <csa_backtrace+0x92>
		uint32_t eip = ebp[1];
f0100a0f:	8b 46 04             	mov    0x4(%esi),%eax
f0100a12:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		cprintf("ebp %x  eip %x  args", ebp, eip);
f0100a15:	83 ec 04             	sub    $0x4,%esp
f0100a18:	50                   	push   %eax
f0100a19:	56                   	push   %esi
f0100a1a:	68 54 6b 10 f0       	push   $0xf0106b54
f0100a1f:	e8 8c 30 00 00       	call   f0103ab0 <cprintf>
f0100a24:	8d 5e 08             	lea    0x8(%esi),%ebx
f0100a27:	8d 7e 1c             	lea    0x1c(%esi),%edi
f0100a2a:	83 c4 10             	add    $0x10,%esp
		int i;
		for (i = 2; i <= 6; ++i)
			cprintf(" %08.x", ebp[i]);
f0100a2d:	83 ec 08             	sub    $0x8,%esp
f0100a30:	ff 33                	pushl  (%ebx)
f0100a32:	68 69 6b 10 f0       	push   $0xf0106b69
f0100a37:	e8 74 30 00 00       	call   f0103ab0 <cprintf>
f0100a3c:	83 c3 04             	add    $0x4,%ebx
	cprintf("Stack backtrace:\n");
	while (ebp) {
		uint32_t eip = ebp[1];
		cprintf("ebp %x  eip %x  args", ebp, eip);
		int i;
		for (i = 2; i <= 6; ++i)
f0100a3f:	83 c4 10             	add    $0x10,%esp
f0100a42:	39 fb                	cmp    %edi,%ebx
f0100a44:	75 e7                	jne    f0100a2d <csa_backtrace+0x38>
			cprintf(" %08.x", ebp[i]);
		cprintf("\n");
f0100a46:	83 ec 0c             	sub    $0xc,%esp
f0100a49:	68 c2 67 10 f0       	push   $0xf01067c2
f0100a4e:	e8 5d 30 00 00       	call   f0103ab0 <cprintf>
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
f0100a53:	83 c4 08             	add    $0x8,%esp
f0100a56:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100a59:	50                   	push   %eax
f0100a5a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100a5d:	57                   	push   %edi
f0100a5e:	e8 5e 45 00 00       	call   f0104fc1 <debuginfo_eip>
		cprintf("\t%s:%d: %.*s+%d\n", 
f0100a63:	83 c4 08             	add    $0x8,%esp
f0100a66:	89 f8                	mov    %edi,%eax
f0100a68:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100a6b:	50                   	push   %eax
f0100a6c:	ff 75 d8             	pushl  -0x28(%ebp)
f0100a6f:	ff 75 dc             	pushl  -0x24(%ebp)
f0100a72:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100a75:	ff 75 d0             	pushl  -0x30(%ebp)
f0100a78:	68 70 6b 10 f0       	push   $0xf0106b70
f0100a7d:	e8 2e 30 00 00       	call   f0103ab0 <cprintf>
			info.eip_file, info.eip_line,
			info.eip_fn_namelen, info.eip_fn_name,
			eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
		ebp = (uint32_t*) *ebp;
f0100a82:	8b 36                	mov    (%esi),%esi
f0100a84:	83 c4 20             	add    $0x20,%esp
int
csa_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp) {
f0100a87:	85 f6                	test   %esi,%esi
f0100a89:	75 84                	jne    f0100a0f <csa_backtrace+0x1a>
			eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
		ebp = (uint32_t*) *ebp;
	}
	return 0;
}
f0100a8b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a90:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a93:	5b                   	pop    %ebx
f0100a94:	5e                   	pop    %esi
f0100a95:	5f                   	pop    %edi
f0100a96:	5d                   	pop    %ebp
f0100a97:	c3                   	ret    

f0100a98 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100a98:	55                   	push   %ebp
f0100a99:	89 e5                	mov    %esp,%ebp
f0100a9b:	57                   	push   %edi
f0100a9c:	56                   	push   %esi
f0100a9d:	53                   	push   %ebx
f0100a9e:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100aa1:	68 b8 6d 10 f0       	push   $0xf0106db8
f0100aa6:	e8 05 30 00 00       	call   f0103ab0 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100aab:	c7 04 24 dc 6d 10 f0 	movl   $0xf0106ddc,(%esp)
f0100ab2:	e8 f9 2f 00 00       	call   f0103ab0 <cprintf>
	cprintf("%m%s\n%m%s\n%m%s\n", 
f0100ab7:	83 c4 0c             	add    $0xc,%esp
f0100aba:	68 81 6b 10 f0       	push   $0xf0106b81
f0100abf:	68 00 04 00 00       	push   $0x400
f0100ac4:	68 85 6b 10 f0       	push   $0xf0106b85
f0100ac9:	68 00 02 00 00       	push   $0x200
f0100ace:	68 8b 6b 10 f0       	push   $0xf0106b8b
f0100ad3:	68 00 01 00 00       	push   $0x100
f0100ad8:	68 90 6b 10 f0       	push   $0xf0106b90
f0100add:	e8 ce 2f 00 00       	call   f0103ab0 <cprintf>
		0x0100, "blue", 0x0200, "green", 0x0400, "red");
	// cprintf("UTrapframe: %x\n", sizeof(struct UTrapframe));
	if (tf != NULL)
f0100ae2:	83 c4 20             	add    $0x20,%esp
f0100ae5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100ae9:	74 0e                	je     f0100af9 <monitor+0x61>
		print_trapframe(tf);
f0100aeb:	83 ec 0c             	sub    $0xc,%esp
f0100aee:	ff 75 08             	pushl  0x8(%ebp)
f0100af1:	e8 88 36 00 00       	call   f010417e <print_trapframe>
f0100af6:	83 c4 10             	add    $0x10,%esp
	// asm volatile("or $0x0100, %%eax\n":::);
	// asm volatile("\tpushl %%eax\n":::);
	// asm volatile("\tpopf\n":::);
	// asm volatile("\tjmp *%0\n":: "g" (&tf->tf_eip): "memory");
	while (1) {
		buf = readline("K> ");
f0100af9:	83 ec 0c             	sub    $0xc,%esp
f0100afc:	68 a0 6b 10 f0       	push   $0xf0106ba0
f0100b01:	e8 ff 4c 00 00       	call   f0105805 <readline>
f0100b06:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100b08:	83 c4 10             	add    $0x10,%esp
f0100b0b:	85 c0                	test   %eax,%eax
f0100b0d:	74 ea                	je     f0100af9 <monitor+0x61>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100b0f:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100b16:	be 00 00 00 00       	mov    $0x0,%esi
f0100b1b:	eb 0a                	jmp    f0100b27 <monitor+0x8f>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100b1d:	c6 03 00             	movb   $0x0,(%ebx)
f0100b20:	89 f7                	mov    %esi,%edi
f0100b22:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100b25:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100b27:	0f b6 03             	movzbl (%ebx),%eax
f0100b2a:	84 c0                	test   %al,%al
f0100b2c:	74 63                	je     f0100b91 <monitor+0xf9>
f0100b2e:	83 ec 08             	sub    $0x8,%esp
f0100b31:	0f be c0             	movsbl %al,%eax
f0100b34:	50                   	push   %eax
f0100b35:	68 a4 6b 10 f0       	push   $0xf0106ba4
f0100b3a:	e8 e0 4e 00 00       	call   f0105a1f <strchr>
f0100b3f:	83 c4 10             	add    $0x10,%esp
f0100b42:	85 c0                	test   %eax,%eax
f0100b44:	75 d7                	jne    f0100b1d <monitor+0x85>
			*buf++ = 0;
		if (*buf == 0)
f0100b46:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100b49:	74 46                	je     f0100b91 <monitor+0xf9>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100b4b:	83 fe 0f             	cmp    $0xf,%esi
f0100b4e:	75 14                	jne    f0100b64 <monitor+0xcc>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100b50:	83 ec 08             	sub    $0x8,%esp
f0100b53:	6a 10                	push   $0x10
f0100b55:	68 a9 6b 10 f0       	push   $0xf0106ba9
f0100b5a:	e8 51 2f 00 00       	call   f0103ab0 <cprintf>
f0100b5f:	83 c4 10             	add    $0x10,%esp
f0100b62:	eb 95                	jmp    f0100af9 <monitor+0x61>
			return 0;
		}
		argv[argc++] = buf;
f0100b64:	8d 7e 01             	lea    0x1(%esi),%edi
f0100b67:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100b6b:	eb 03                	jmp    f0100b70 <monitor+0xd8>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100b6d:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100b70:	0f b6 03             	movzbl (%ebx),%eax
f0100b73:	84 c0                	test   %al,%al
f0100b75:	74 ae                	je     f0100b25 <monitor+0x8d>
f0100b77:	83 ec 08             	sub    $0x8,%esp
f0100b7a:	0f be c0             	movsbl %al,%eax
f0100b7d:	50                   	push   %eax
f0100b7e:	68 a4 6b 10 f0       	push   $0xf0106ba4
f0100b83:	e8 97 4e 00 00       	call   f0105a1f <strchr>
f0100b88:	83 c4 10             	add    $0x10,%esp
f0100b8b:	85 c0                	test   %eax,%eax
f0100b8d:	74 de                	je     f0100b6d <monitor+0xd5>
f0100b8f:	eb 94                	jmp    f0100b25 <monitor+0x8d>
			buf++;
	}
	argv[argc] = 0;
f0100b91:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100b98:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100b99:	85 f6                	test   %esi,%esi
f0100b9b:	0f 84 58 ff ff ff    	je     f0100af9 <monitor+0x61>
f0100ba1:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100ba6:	83 ec 08             	sub    $0x8,%esp
f0100ba9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100bac:	ff 34 85 e0 6e 10 f0 	pushl  -0xfef9120(,%eax,4)
f0100bb3:	ff 75 a8             	pushl  -0x58(%ebp)
f0100bb6:	e8 06 4e 00 00       	call   f01059c1 <strcmp>
f0100bbb:	83 c4 10             	add    $0x10,%esp
f0100bbe:	85 c0                	test   %eax,%eax
f0100bc0:	75 21                	jne    f0100be3 <monitor+0x14b>
			return commands[i].func(argc, argv, tf);
f0100bc2:	83 ec 04             	sub    $0x4,%esp
f0100bc5:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100bc8:	ff 75 08             	pushl  0x8(%ebp)
f0100bcb:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100bce:	52                   	push   %edx
f0100bcf:	56                   	push   %esi
f0100bd0:	ff 14 85 e8 6e 10 f0 	call   *-0xfef9118(,%eax,4)
	// asm volatile("\tpopf\n":::);
	// asm volatile("\tjmp *%0\n":: "g" (&tf->tf_eip): "memory");
	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100bd7:	83 c4 10             	add    $0x10,%esp
f0100bda:	85 c0                	test   %eax,%eax
f0100bdc:	78 25                	js     f0100c03 <monitor+0x16b>
f0100bde:	e9 16 ff ff ff       	jmp    f0100af9 <monitor+0x61>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100be3:	83 c3 01             	add    $0x1,%ebx
f0100be6:	83 fb 09             	cmp    $0x9,%ebx
f0100be9:	75 bb                	jne    f0100ba6 <monitor+0x10e>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100beb:	83 ec 08             	sub    $0x8,%esp
f0100bee:	ff 75 a8             	pushl  -0x58(%ebp)
f0100bf1:	68 c6 6b 10 f0       	push   $0xf0106bc6
f0100bf6:	e8 b5 2e 00 00       	call   f0103ab0 <cprintf>
f0100bfb:	83 c4 10             	add    $0x10,%esp
f0100bfe:	e9 f6 fe ff ff       	jmp    f0100af9 <monitor+0x61>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100c03:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c06:	5b                   	pop    %ebx
f0100c07:	5e                   	pop    %esi
f0100c08:	5f                   	pop    %edi
f0100c09:	5d                   	pop    %ebp
f0100c0a:	c3                   	ret    

f0100c0b <xtoi>:

uint32_t xtoi(char* buf) {
f0100c0b:	55                   	push   %ebp
f0100c0c:	89 e5                	mov    %esp,%ebp
	uint32_t res = 0;
	buf += 2; //0x...
f0100c0e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c11:	8d 50 02             	lea    0x2(%eax),%edx
				break;
	}
}

uint32_t xtoi(char* buf) {
	uint32_t res = 0;
f0100c14:	b8 00 00 00 00       	mov    $0x0,%eax
	buf += 2; //0x...
	while (*buf) { 
f0100c19:	eb 17                	jmp    f0100c32 <xtoi+0x27>
		if (*buf >= 'a') *buf = *buf-'a'+'0'+10;//aha
f0100c1b:	80 f9 60             	cmp    $0x60,%cl
f0100c1e:	7e 05                	jle    f0100c25 <xtoi+0x1a>
f0100c20:	83 e9 27             	sub    $0x27,%ecx
f0100c23:	88 0a                	mov    %cl,(%edx)
f0100c25:	c1 e0 04             	shl    $0x4,%eax
		res = res*16 + *buf - '0';
f0100c28:	0f be 0a             	movsbl (%edx),%ecx
f0100c2b:	8d 44 08 d0          	lea    -0x30(%eax,%ecx,1),%eax
		++buf;
f0100c2f:	83 c2 01             	add    $0x1,%edx
}

uint32_t xtoi(char* buf) {
	uint32_t res = 0;
	buf += 2; //0x...
	while (*buf) { 
f0100c32:	0f b6 0a             	movzbl (%edx),%ecx
f0100c35:	84 c9                	test   %cl,%cl
f0100c37:	75 e2                	jne    f0100c1b <xtoi+0x10>
		if (*buf >= 'a') *buf = *buf-'a'+'0'+10;//aha
		res = res*16 + *buf - '0';
		++buf;
	}
	return res;
}
f0100c39:	5d                   	pop    %ebp
f0100c3a:	c3                   	ret    

f0100c3b <showvm>:
	cprintf("%x after  setm: ", addr);
	pprint(pte);
	return 0;
}

int showvm(int argc, char **argv, struct Trapframe *tf) {
f0100c3b:	55                   	push   %ebp
f0100c3c:	89 e5                	mov    %esp,%ebp
f0100c3e:	57                   	push   %edi
f0100c3f:	56                   	push   %esi
f0100c40:	53                   	push   %ebx
f0100c41:	83 ec 0c             	sub    $0xc,%esp
f0100c44:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc == 1) {
f0100c47:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100c4b:	75 12                	jne    f0100c5f <showvm+0x24>
		cprintf("Usage: showvm 0xaddr 0xn\n");
f0100c4d:	83 ec 0c             	sub    $0xc,%esp
f0100c50:	68 dc 6b 10 f0       	push   $0xf0106bdc
f0100c55:	e8 56 2e 00 00       	call   f0103ab0 <cprintf>
		return 0;
f0100c5a:	83 c4 10             	add    $0x10,%esp
f0100c5d:	eb 41                	jmp    f0100ca0 <showvm+0x65>
	}
	void** addr = (void**) xtoi(argv[1]);
f0100c5f:	83 ec 0c             	sub    $0xc,%esp
f0100c62:	ff 76 04             	pushl  0x4(%esi)
f0100c65:	e8 a1 ff ff ff       	call   f0100c0b <xtoi>
f0100c6a:	89 c3                	mov    %eax,%ebx
	uint32_t n = xtoi(argv[2]);
f0100c6c:	83 c4 04             	add    $0x4,%esp
f0100c6f:	ff 76 08             	pushl  0x8(%esi)
f0100c72:	e8 94 ff ff ff       	call   f0100c0b <xtoi>
f0100c77:	89 c6                	mov    %eax,%esi
	int i;
	for (i = 0; i < n; ++i)
f0100c79:	83 c4 10             	add    $0x10,%esp
f0100c7c:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c81:	eb 19                	jmp    f0100c9c <showvm+0x61>
		cprintf("VM at %x is %x\n", addr+i, addr[i]);
f0100c83:	83 ec 04             	sub    $0x4,%esp
f0100c86:	ff 33                	pushl  (%ebx)
f0100c88:	53                   	push   %ebx
f0100c89:	68 f6 6b 10 f0       	push   $0xf0106bf6
f0100c8e:	e8 1d 2e 00 00       	call   f0103ab0 <cprintf>
		return 0;
	}
	void** addr = (void**) xtoi(argv[1]);
	uint32_t n = xtoi(argv[2]);
	int i;
	for (i = 0; i < n; ++i)
f0100c93:	83 c7 01             	add    $0x1,%edi
f0100c96:	83 c3 04             	add    $0x4,%ebx
f0100c99:	83 c4 10             	add    $0x10,%esp
f0100c9c:	39 f7                	cmp    %esi,%edi
f0100c9e:	75 e3                	jne    f0100c83 <showvm+0x48>
		cprintf("VM at %x is %x\n", addr+i, addr[i]);
	return 0;
}
f0100ca0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ca5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ca8:	5b                   	pop    %ebx
f0100ca9:	5e                   	pop    %esi
f0100caa:	5f                   	pop    %edi
f0100cab:	5d                   	pop    %ebp
f0100cac:	c3                   	ret    

f0100cad <pprint>:
		res = res*16 + *buf - '0';
		++buf;
	}
	return res;
}
void pprint(pte_t *pte) {
f0100cad:	55                   	push   %ebp
f0100cae:	89 e5                	mov    %esp,%ebp
f0100cb0:	83 ec 08             	sub    $0x8,%esp
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x\n", 
		*pte&PTE_P, *pte&PTE_W, *pte&PTE_U);
f0100cb3:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cb6:	8b 00                	mov    (%eax),%eax
		++buf;
	}
	return res;
}
void pprint(pte_t *pte) {
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x\n", 
f0100cb8:	89 c2                	mov    %eax,%edx
f0100cba:	83 e2 04             	and    $0x4,%edx
f0100cbd:	52                   	push   %edx
f0100cbe:	89 c2                	mov    %eax,%edx
f0100cc0:	83 e2 02             	and    $0x2,%edx
f0100cc3:	52                   	push   %edx
f0100cc4:	83 e0 01             	and    $0x1,%eax
f0100cc7:	50                   	push   %eax
f0100cc8:	68 04 6e 10 f0       	push   $0xf0106e04
f0100ccd:	e8 de 2d 00 00       	call   f0103ab0 <cprintf>
		*pte&PTE_P, *pte&PTE_W, *pte&PTE_U);
}
f0100cd2:	83 c4 10             	add    $0x10,%esp
f0100cd5:	c9                   	leave  
f0100cd6:	c3                   	ret    

f0100cd7 <showmappings>:
int
showmappings(int argc, char **argv, struct Trapframe *tf)
{
f0100cd7:	55                   	push   %ebp
f0100cd8:	89 e5                	mov    %esp,%ebp
f0100cda:	57                   	push   %edi
f0100cdb:	56                   	push   %esi
f0100cdc:	53                   	push   %ebx
f0100cdd:	83 ec 0c             	sub    $0xc,%esp
f0100ce0:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc == 1) {
f0100ce3:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100ce7:	75 15                	jne    f0100cfe <showmappings+0x27>
		cprintf("Usage: showmappings 0xbegin_addr 0xend_addr\n");
f0100ce9:	83 ec 0c             	sub    $0xc,%esp
f0100cec:	68 28 6e 10 f0       	push   $0xf0106e28
f0100cf1:	e8 ba 2d 00 00       	call   f0103ab0 <cprintf>
		return 0;
f0100cf6:	83 c4 10             	add    $0x10,%esp
f0100cf9:	e9 9a 00 00 00       	jmp    f0100d98 <showmappings+0xc1>
	}
	uint32_t begin = xtoi(argv[1]), end = xtoi(argv[2]);
f0100cfe:	83 ec 0c             	sub    $0xc,%esp
f0100d01:	ff 76 04             	pushl  0x4(%esi)
f0100d04:	e8 02 ff ff ff       	call   f0100c0b <xtoi>
f0100d09:	89 c3                	mov    %eax,%ebx
f0100d0b:	83 c4 04             	add    $0x4,%esp
f0100d0e:	ff 76 08             	pushl  0x8(%esi)
f0100d11:	e8 f5 fe ff ff       	call   f0100c0b <xtoi>
f0100d16:	89 c7                	mov    %eax,%edi
	cprintf("begin: %x, end: %x\n", begin, end);
f0100d18:	83 c4 0c             	add    $0xc,%esp
f0100d1b:	50                   	push   %eax
f0100d1c:	53                   	push   %ebx
f0100d1d:	68 06 6c 10 f0       	push   $0xf0106c06
f0100d22:	e8 89 2d 00 00       	call   f0103ab0 <cprintf>
	for (; begin <= end; begin += PGSIZE) {
f0100d27:	83 c4 10             	add    $0x10,%esp
f0100d2a:	eb 68                	jmp    f0100d94 <showmappings+0xbd>
		pte_t *pte = pgdir_walk(kern_pgdir, (void *) begin, 1);	//create
f0100d2c:	83 ec 04             	sub    $0x4,%esp
f0100d2f:	6a 01                	push   $0x1
f0100d31:	53                   	push   %ebx
f0100d32:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f0100d38:	e8 7f 06 00 00       	call   f01013bc <pgdir_walk>
f0100d3d:	89 c6                	mov    %eax,%esi
		if (!pte) panic("boot_map_region panic, out of memory");
f0100d3f:	83 c4 10             	add    $0x10,%esp
f0100d42:	85 c0                	test   %eax,%eax
f0100d44:	75 17                	jne    f0100d5d <showmappings+0x86>
f0100d46:	83 ec 04             	sub    $0x4,%esp
f0100d49:	68 58 6e 10 f0       	push   $0xf0106e58
f0100d4e:	68 d1 00 00 00       	push   $0xd1
f0100d53:	68 1a 6c 10 f0       	push   $0xf0106c1a
f0100d58:	e8 37 f3 ff ff       	call   f0100094 <_panic>
		if (*pte & PTE_P) {
f0100d5d:	f6 00 01             	testb  $0x1,(%eax)
f0100d60:	74 1b                	je     f0100d7d <showmappings+0xa6>
			cprintf("page %x with ", begin);
f0100d62:	83 ec 08             	sub    $0x8,%esp
f0100d65:	53                   	push   %ebx
f0100d66:	68 29 6c 10 f0       	push   $0xf0106c29
f0100d6b:	e8 40 2d 00 00       	call   f0103ab0 <cprintf>
			pprint(pte);
f0100d70:	89 34 24             	mov    %esi,(%esp)
f0100d73:	e8 35 ff ff ff       	call   f0100cad <pprint>
f0100d78:	83 c4 10             	add    $0x10,%esp
f0100d7b:	eb 11                	jmp    f0100d8e <showmappings+0xb7>
		} else cprintf("page not exist: %x\n", begin);
f0100d7d:	83 ec 08             	sub    $0x8,%esp
f0100d80:	53                   	push   %ebx
f0100d81:	68 37 6c 10 f0       	push   $0xf0106c37
f0100d86:	e8 25 2d 00 00       	call   f0103ab0 <cprintf>
f0100d8b:	83 c4 10             	add    $0x10,%esp
		cprintf("Usage: showmappings 0xbegin_addr 0xend_addr\n");
		return 0;
	}
	uint32_t begin = xtoi(argv[1]), end = xtoi(argv[2]);
	cprintf("begin: %x, end: %x\n", begin, end);
	for (; begin <= end; begin += PGSIZE) {
f0100d8e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100d94:	39 fb                	cmp    %edi,%ebx
f0100d96:	76 94                	jbe    f0100d2c <showmappings+0x55>
			cprintf("page %x with ", begin);
			pprint(pte);
		} else cprintf("page not exist: %x\n", begin);
	}
	return 0;
}
f0100d98:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100da0:	5b                   	pop    %ebx
f0100da1:	5e                   	pop    %esi
f0100da2:	5f                   	pop    %edi
f0100da3:	5d                   	pop    %ebp
f0100da4:	c3                   	ret    

f0100da5 <setm>:

int setm(int argc, char **argv, struct Trapframe *tf) {
f0100da5:	55                   	push   %ebp
f0100da6:	89 e5                	mov    %esp,%ebp
f0100da8:	57                   	push   %edi
f0100da9:	56                   	push   %esi
f0100daa:	53                   	push   %ebx
f0100dab:	83 ec 0c             	sub    $0xc,%esp
f0100dae:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc == 1) {
f0100db1:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100db5:	75 15                	jne    f0100dcc <setm+0x27>
		cprintf("Usage: setm 0xaddr [0|1 :clear or set] [P|W|U]\n");
f0100db7:	83 ec 0c             	sub    $0xc,%esp
f0100dba:	68 80 6e 10 f0       	push   $0xf0106e80
f0100dbf:	e8 ec 2c 00 00       	call   f0103ab0 <cprintf>
		return 0;
f0100dc4:	83 c4 10             	add    $0x10,%esp
f0100dc7:	e9 85 00 00 00       	jmp    f0100e51 <setm+0xac>
	}
	uint32_t addr = xtoi(argv[1]);
f0100dcc:	83 ec 0c             	sub    $0xc,%esp
f0100dcf:	ff 76 04             	pushl  0x4(%esi)
f0100dd2:	e8 34 fe ff ff       	call   f0100c0b <xtoi>
f0100dd7:	89 c7                	mov    %eax,%edi
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 1);
f0100dd9:	83 c4 0c             	add    $0xc,%esp
f0100ddc:	6a 01                	push   $0x1
f0100dde:	50                   	push   %eax
f0100ddf:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f0100de5:	e8 d2 05 00 00       	call   f01013bc <pgdir_walk>
f0100dea:	89 c3                	mov    %eax,%ebx
	cprintf("%x before setm: ", addr);
f0100dec:	83 c4 08             	add    $0x8,%esp
f0100def:	57                   	push   %edi
f0100df0:	68 4b 6c 10 f0       	push   $0xf0106c4b
f0100df5:	e8 b6 2c 00 00       	call   f0103ab0 <cprintf>
	pprint(pte);
f0100dfa:	89 1c 24             	mov    %ebx,(%esp)
f0100dfd:	e8 ab fe ff ff       	call   f0100cad <pprint>
	uint32_t perm = 0;
	if (argv[3][0] == 'P') perm = PTE_P;
f0100e02:	8b 46 0c             	mov    0xc(%esi),%eax
f0100e05:	0f b6 10             	movzbl (%eax),%edx
	if (argv[3][0] == 'W') perm = PTE_W;
f0100e08:	83 c4 10             	add    $0x10,%esp
f0100e0b:	b8 02 00 00 00       	mov    $0x2,%eax
f0100e10:	80 fa 57             	cmp    $0x57,%dl
f0100e13:	74 13                	je     f0100e28 <setm+0x83>
	if (argv[3][0] == 'U') perm = PTE_U;
f0100e15:	b8 04 00 00 00       	mov    $0x4,%eax
f0100e1a:	80 fa 55             	cmp    $0x55,%dl
f0100e1d:	74 09                	je     f0100e28 <setm+0x83>
	}
	uint32_t addr = xtoi(argv[1]);
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 1);
	cprintf("%x before setm: ", addr);
	pprint(pte);
	uint32_t perm = 0;
f0100e1f:	80 fa 50             	cmp    $0x50,%dl
f0100e22:	0f 94 c0             	sete   %al
f0100e25:	0f b6 c0             	movzbl %al,%eax
	if (argv[3][0] == 'P') perm = PTE_P;
	if (argv[3][0] == 'W') perm = PTE_W;
	if (argv[3][0] == 'U') perm = PTE_U;
	if (argv[2][0] == '0') 	//clear
f0100e28:	8b 56 08             	mov    0x8(%esi),%edx
f0100e2b:	80 3a 30             	cmpb   $0x30,(%edx)
f0100e2e:	75 06                	jne    f0100e36 <setm+0x91>
		*pte = *pte & ~perm;
f0100e30:	f7 d0                	not    %eax
f0100e32:	21 03                	and    %eax,(%ebx)
f0100e34:	eb 02                	jmp    f0100e38 <setm+0x93>
	else 	//set
		*pte = *pte | perm;
f0100e36:	09 03                	or     %eax,(%ebx)
	cprintf("%x after  setm: ", addr);
f0100e38:	83 ec 08             	sub    $0x8,%esp
f0100e3b:	57                   	push   %edi
f0100e3c:	68 5c 6c 10 f0       	push   $0xf0106c5c
f0100e41:	e8 6a 2c 00 00       	call   f0103ab0 <cprintf>
	pprint(pte);
f0100e46:	89 1c 24             	mov    %ebx,(%esp)
f0100e49:	e8 5f fe ff ff       	call   f0100cad <pprint>
	return 0;
f0100e4e:	83 c4 10             	add    $0x10,%esp
}
f0100e51:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e56:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e59:	5b                   	pop    %ebx
f0100e5a:	5e                   	pop    %esi
f0100e5b:	5f                   	pop    %edi
f0100e5c:	5d                   	pop    %ebp
f0100e5d:	c3                   	ret    

f0100e5e <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100e5e:	55                   	push   %ebp
f0100e5f:	89 e5                	mov    %esp,%ebp
f0100e61:	53                   	push   %ebx
f0100e62:	83 ec 04             	sub    $0x4,%esp
f0100e65:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100e67:	83 3d 38 72 22 f0 00 	cmpl   $0x0,0xf0227238
f0100e6e:	75 0f                	jne    f0100e7f <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100e70:	b8 07 a0 26 f0       	mov    $0xf026a007,%eax
f0100e75:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100e7a:	a3 38 72 22 f0       	mov    %eax,0xf0227238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	cprintf("boot_alloc memory at %x\n", nextfree);
f0100e7f:	83 ec 08             	sub    $0x8,%esp
f0100e82:	ff 35 38 72 22 f0    	pushl  0xf0227238
f0100e88:	68 4c 6f 10 f0       	push   $0xf0106f4c
f0100e8d:	e8 1e 2c 00 00       	call   f0103ab0 <cprintf>
	cprintf("Next memory at %x\n", ROUNDUP((char *) (nextfree+n), PGSIZE));
f0100e92:	89 d8                	mov    %ebx,%eax
f0100e94:	03 05 38 72 22 f0    	add    0xf0227238,%eax
f0100e9a:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100e9f:	83 c4 08             	add    $0x8,%esp
f0100ea2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ea7:	50                   	push   %eax
f0100ea8:	68 65 6f 10 f0       	push   $0xf0106f65
f0100ead:	e8 fe 2b 00 00       	call   f0103ab0 <cprintf>
	if (n != 0) {
f0100eb2:	83 c4 10             	add    $0x10,%esp
		char *next = nextfree;
		nextfree = ROUNDUP((char *) (nextfree+n), PGSIZE);
		return next;
	} else return nextfree;
f0100eb5:	a1 38 72 22 f0       	mov    0xf0227238,%eax
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	cprintf("boot_alloc memory at %x\n", nextfree);
	cprintf("Next memory at %x\n", ROUNDUP((char *) (nextfree+n), PGSIZE));
	if (n != 0) {
f0100eba:	85 db                	test   %ebx,%ebx
f0100ebc:	74 13                	je     f0100ed1 <boot_alloc+0x73>
		char *next = nextfree;
		nextfree = ROUNDUP((char *) (nextfree+n), PGSIZE);
f0100ebe:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f0100ec5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ecb:	89 15 38 72 22 f0    	mov    %edx,0xf0227238
		return next;
	} else return nextfree;

	return NULL;
}
f0100ed1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ed4:	c9                   	leave  
f0100ed5:	c3                   	ret    

f0100ed6 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100ed6:	89 d1                	mov    %edx,%ecx
f0100ed8:	c1 e9 16             	shr    $0x16,%ecx
f0100edb:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ede:	a8 01                	test   $0x1,%al
f0100ee0:	74 52                	je     f0100f34 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100ee2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ee7:	89 c1                	mov    %eax,%ecx
f0100ee9:	c1 e9 0c             	shr    $0xc,%ecx
f0100eec:	3b 0d 90 7e 22 f0    	cmp    0xf0227e90,%ecx
f0100ef2:	72 1b                	jb     f0100f0f <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100ef4:	55                   	push   %ebp
f0100ef5:	89 e5                	mov    %esp,%ebp
f0100ef7:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100efa:	50                   	push   %eax
f0100efb:	68 5c 68 10 f0       	push   $0xf010685c
f0100f00:	68 92 03 00 00       	push   $0x392
f0100f05:	68 78 6f 10 f0       	push   $0xf0106f78
f0100f0a:	e8 85 f1 ff ff       	call   f0100094 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100f0f:	c1 ea 0c             	shr    $0xc,%edx
f0100f12:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100f18:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100f1f:	89 c2                	mov    %eax,%edx
f0100f21:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100f24:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f29:	85 d2                	test   %edx,%edx
f0100f2b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100f30:	0f 44 c2             	cmove  %edx,%eax
f0100f33:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100f34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100f39:	c3                   	ret    

f0100f3a <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100f3a:	55                   	push   %ebp
f0100f3b:	89 e5                	mov    %esp,%ebp
f0100f3d:	57                   	push   %edi
f0100f3e:	56                   	push   %esi
f0100f3f:	53                   	push   %ebx
f0100f40:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f43:	84 c0                	test   %al,%al
f0100f45:	0f 85 a0 02 00 00    	jne    f01011eb <check_page_free_list+0x2b1>
f0100f4b:	e9 ad 02 00 00       	jmp    f01011fd <check_page_free_list+0x2c3>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100f50:	83 ec 04             	sub    $0x4,%esp
f0100f53:	68 78 73 10 f0       	push   $0xf0107378
f0100f58:	68 be 02 00 00       	push   $0x2be
f0100f5d:	68 78 6f 10 f0       	push   $0xf0106f78
f0100f62:	e8 2d f1 ff ff       	call   f0100094 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100f67:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100f6a:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100f6d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100f70:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100f73:	89 c2                	mov    %eax,%edx
f0100f75:	2b 15 98 7e 22 f0    	sub    0xf0227e98,%edx
f0100f7b:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100f81:	0f 95 c2             	setne  %dl
f0100f84:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100f87:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100f8b:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100f8d:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f91:	8b 00                	mov    (%eax),%eax
f0100f93:	85 c0                	test   %eax,%eax
f0100f95:	75 dc                	jne    f0100f73 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100f97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f9a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100fa0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100fa3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100fa6:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100fa8:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100fab:	a3 40 72 22 f0       	mov    %eax,0xf0227240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100fb0:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100fb5:	8b 1d 40 72 22 f0    	mov    0xf0227240,%ebx
f0100fbb:	eb 53                	jmp    f0101010 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fbd:	89 d8                	mov    %ebx,%eax
f0100fbf:	2b 05 98 7e 22 f0    	sub    0xf0227e98,%eax
f0100fc5:	c1 f8 03             	sar    $0x3,%eax
f0100fc8:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100fcb:	89 c2                	mov    %eax,%edx
f0100fcd:	c1 ea 16             	shr    $0x16,%edx
f0100fd0:	39 f2                	cmp    %esi,%edx
f0100fd2:	73 3a                	jae    f010100e <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fd4:	89 c2                	mov    %eax,%edx
f0100fd6:	c1 ea 0c             	shr    $0xc,%edx
f0100fd9:	3b 15 90 7e 22 f0    	cmp    0xf0227e90,%edx
f0100fdf:	72 12                	jb     f0100ff3 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fe1:	50                   	push   %eax
f0100fe2:	68 5c 68 10 f0       	push   $0xf010685c
f0100fe7:	6a 58                	push   $0x58
f0100fe9:	68 84 6f 10 f0       	push   $0xf0106f84
f0100fee:	e8 a1 f0 ff ff       	call   f0100094 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100ff3:	83 ec 04             	sub    $0x4,%esp
f0100ff6:	68 80 00 00 00       	push   $0x80
f0100ffb:	68 97 00 00 00       	push   $0x97
f0101000:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101005:	50                   	push   %eax
f0101006:	e8 51 4a 00 00       	call   f0105a5c <memset>
f010100b:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010100e:	8b 1b                	mov    (%ebx),%ebx
f0101010:	85 db                	test   %ebx,%ebx
f0101012:	75 a9                	jne    f0100fbd <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0101014:	b8 00 00 00 00       	mov    $0x0,%eax
f0101019:	e8 40 fe ff ff       	call   f0100e5e <boot_alloc>
f010101e:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101021:	8b 15 40 72 22 f0    	mov    0xf0227240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101027:	8b 0d 98 7e 22 f0    	mov    0xf0227e98,%ecx
		assert(pp < pages + npages);
f010102d:	a1 90 7e 22 f0       	mov    0xf0227e90,%eax
f0101032:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101035:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0101038:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010103b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f010103e:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101043:	e9 52 01 00 00       	jmp    f010119a <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101048:	39 ca                	cmp    %ecx,%edx
f010104a:	73 19                	jae    f0101065 <check_page_free_list+0x12b>
f010104c:	68 92 6f 10 f0       	push   $0xf0106f92
f0101051:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101056:	68 d8 02 00 00       	push   $0x2d8
f010105b:	68 78 6f 10 f0       	push   $0xf0106f78
f0101060:	e8 2f f0 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0101065:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0101068:	72 19                	jb     f0101083 <check_page_free_list+0x149>
f010106a:	68 b3 6f 10 f0       	push   $0xf0106fb3
f010106f:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101074:	68 d9 02 00 00       	push   $0x2d9
f0101079:	68 78 6f 10 f0       	push   $0xf0106f78
f010107e:	e8 11 f0 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101083:	89 d0                	mov    %edx,%eax
f0101085:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101088:	a8 07                	test   $0x7,%al
f010108a:	74 19                	je     f01010a5 <check_page_free_list+0x16b>
f010108c:	68 9c 73 10 f0       	push   $0xf010739c
f0101091:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101096:	68 da 02 00 00       	push   $0x2da
f010109b:	68 78 6f 10 f0       	push   $0xf0106f78
f01010a0:	e8 ef ef ff ff       	call   f0100094 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010a5:	c1 f8 03             	sar    $0x3,%eax
f01010a8:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01010ab:	85 c0                	test   %eax,%eax
f01010ad:	75 19                	jne    f01010c8 <check_page_free_list+0x18e>
f01010af:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01010b4:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01010b9:	68 dd 02 00 00       	push   $0x2dd
f01010be:	68 78 6f 10 f0       	push   $0xf0106f78
f01010c3:	e8 cc ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01010c8:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01010cd:	75 19                	jne    f01010e8 <check_page_free_list+0x1ae>
f01010cf:	68 d8 6f 10 f0       	push   $0xf0106fd8
f01010d4:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01010d9:	68 de 02 00 00       	push   $0x2de
f01010de:	68 78 6f 10 f0       	push   $0xf0106f78
f01010e3:	e8 ac ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01010e8:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01010ed:	75 19                	jne    f0101108 <check_page_free_list+0x1ce>
f01010ef:	68 d0 73 10 f0       	push   $0xf01073d0
f01010f4:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01010f9:	68 df 02 00 00       	push   $0x2df
f01010fe:	68 78 6f 10 f0       	push   $0xf0106f78
f0101103:	e8 8c ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101108:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010110d:	75 19                	jne    f0101128 <check_page_free_list+0x1ee>
f010110f:	68 f1 6f 10 f0       	push   $0xf0106ff1
f0101114:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101119:	68 e0 02 00 00       	push   $0x2e0
f010111e:	68 78 6f 10 f0       	push   $0xf0106f78
f0101123:	e8 6c ef ff ff       	call   f0100094 <_panic>
		// cprintf("pp: %x, page2pa(pp): %x, page2kva(pp): %x, first_free_page: %x\n",
		// 	pp, page2pa(pp), page2kva(pp), first_free_page);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101128:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f010112d:	0f 86 f1 00 00 00    	jbe    f0101224 <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101133:	89 c7                	mov    %eax,%edi
f0101135:	c1 ef 0c             	shr    $0xc,%edi
f0101138:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f010113b:	77 12                	ja     f010114f <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010113d:	50                   	push   %eax
f010113e:	68 5c 68 10 f0       	push   $0xf010685c
f0101143:	6a 58                	push   $0x58
f0101145:	68 84 6f 10 f0       	push   $0xf0106f84
f010114a:	e8 45 ef ff ff       	call   f0100094 <_panic>
f010114f:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0101155:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0101158:	0f 86 b6 00 00 00    	jbe    f0101214 <check_page_free_list+0x2da>
f010115e:	68 f4 73 10 f0       	push   $0xf01073f4
f0101163:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101168:	68 e3 02 00 00       	push   $0x2e3
f010116d:	68 78 6f 10 f0       	push   $0xf0106f78
f0101172:	e8 1d ef ff ff       	call   f0100094 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101177:	68 0b 70 10 f0       	push   $0xf010700b
f010117c:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101181:	68 e5 02 00 00       	push   $0x2e5
f0101186:	68 78 6f 10 f0       	push   $0xf0106f78
f010118b:	e8 04 ef ff ff       	call   f0100094 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0101190:	83 c6 01             	add    $0x1,%esi
f0101193:	eb 03                	jmp    f0101198 <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0101195:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101198:	8b 12                	mov    (%edx),%edx
f010119a:	85 d2                	test   %edx,%edx
f010119c:	0f 85 a6 fe ff ff    	jne    f0101048 <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f01011a2:	85 f6                	test   %esi,%esi
f01011a4:	7f 19                	jg     f01011bf <check_page_free_list+0x285>
f01011a6:	68 28 70 10 f0       	push   $0xf0107028
f01011ab:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01011b0:	68 ed 02 00 00       	push   $0x2ed
f01011b5:	68 78 6f 10 f0       	push   $0xf0106f78
f01011ba:	e8 d5 ee ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f01011bf:	85 db                	test   %ebx,%ebx
f01011c1:	7f 19                	jg     f01011dc <check_page_free_list+0x2a2>
f01011c3:	68 3a 70 10 f0       	push   $0xf010703a
f01011c8:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01011cd:	68 ee 02 00 00       	push   $0x2ee
f01011d2:	68 78 6f 10 f0       	push   $0xf0106f78
f01011d7:	e8 b8 ee ff ff       	call   f0100094 <_panic>
	cprintf("check_page_free_list done\n");
f01011dc:	83 ec 0c             	sub    $0xc,%esp
f01011df:	68 4b 70 10 f0       	push   $0xf010704b
f01011e4:	e8 c7 28 00 00       	call   f0103ab0 <cprintf>
}
f01011e9:	eb 49                	jmp    f0101234 <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f01011eb:	a1 40 72 22 f0       	mov    0xf0227240,%eax
f01011f0:	85 c0                	test   %eax,%eax
f01011f2:	0f 85 6f fd ff ff    	jne    f0100f67 <check_page_free_list+0x2d>
f01011f8:	e9 53 fd ff ff       	jmp    f0100f50 <check_page_free_list+0x16>
f01011fd:	83 3d 40 72 22 f0 00 	cmpl   $0x0,0xf0227240
f0101204:	0f 84 46 fd ff ff    	je     f0100f50 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010120a:	be 00 04 00 00       	mov    $0x400,%esi
f010120f:	e9 a1 fd ff ff       	jmp    f0100fb5 <check_page_free_list+0x7b>
		assert(page2pa(pp) != EXTPHYSMEM);
		// cprintf("pp: %x, page2pa(pp): %x, page2kva(pp): %x, first_free_page: %x\n",
		// 	pp, page2pa(pp), page2kva(pp), first_free_page);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101214:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101219:	0f 85 76 ff ff ff    	jne    f0101195 <check_page_free_list+0x25b>
f010121f:	e9 53 ff ff ff       	jmp    f0101177 <check_page_free_list+0x23d>
f0101224:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101229:	0f 85 61 ff ff ff    	jne    f0101190 <check_page_free_list+0x256>
f010122f:	e9 43 ff ff ff       	jmp    f0101177 <check_page_free_list+0x23d>
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
	cprintf("check_page_free_list done\n");
}
f0101234:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101237:	5b                   	pop    %ebx
f0101238:	5e                   	pop    %esi
f0101239:	5f                   	pop    %edi
f010123a:	5d                   	pop    %ebp
f010123b:	c3                   	ret    

f010123c <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f010123c:	55                   	push   %ebp
f010123d:	89 e5                	mov    %esp,%ebp
f010123f:	56                   	push   %esi
f0101240:	53                   	push   %ebx
	//     page tables and other data structures?
	// 
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	cprintf("MPENTRY_PADDR: %x\n", MPENTRY_PADDR);
f0101241:	83 ec 08             	sub    $0x8,%esp
f0101244:	68 00 70 00 00       	push   $0x7000
f0101249:	68 66 70 10 f0       	push   $0xf0107066
f010124e:	e8 5d 28 00 00       	call   f0103ab0 <cprintf>
	cprintf("npages_basemem: %x\n", npages_basemem);
f0101253:	83 c4 08             	add    $0x8,%esp
f0101256:	ff 35 44 72 22 f0    	pushl  0xf0227244
f010125c:	68 79 70 10 f0       	push   $0xf0107079
f0101261:	e8 4a 28 00 00       	call   f0103ab0 <cprintf>
f0101266:	8b 0d 40 72 22 f0    	mov    0xf0227240,%ecx
f010126c:	83 c4 10             	add    $0x10,%esp
f010126f:	b8 08 00 00 00       	mov    $0x8,%eax
	size_t i;
	for (i = 1; i < MPENTRY_PADDR/PGSIZE; i++) {
		pages[i].pp_ref = 0;
f0101274:	89 c2                	mov    %eax,%edx
f0101276:	03 15 98 7e 22 f0    	add    0xf0227e98,%edx
f010127c:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0101282:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0101284:	89 c1                	mov    %eax,%ecx
f0101286:	03 0d 98 7e 22 f0    	add    0xf0227e98,%ecx
f010128c:	83 c0 08             	add    $0x8,%eax
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	cprintf("MPENTRY_PADDR: %x\n", MPENTRY_PADDR);
	cprintf("npages_basemem: %x\n", npages_basemem);
	size_t i;
	for (i = 1; i < MPENTRY_PADDR/PGSIZE; i++) {
f010128f:	83 f8 38             	cmp    $0x38,%eax
f0101292:	75 e0                	jne    f0101274 <page_init+0x38>
f0101294:	89 0d 40 72 22 f0    	mov    %ecx,0xf0227240
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	// int med = (int)ROUNDUP(kern_top - 0xf0000000, PGSIZE)/PGSIZE;
	int med = (int)ROUNDUP(((char*)envs) + (sizeof(struct Env) * NENV) - 0xf0000000, PGSIZE)/PGSIZE;
f010129a:	a1 48 72 22 f0       	mov    0xf0227248,%eax
f010129f:	05 ff ff 01 10       	add    $0x1001ffff,%eax
f01012a4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01012a9:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01012af:	85 c0                	test   %eax,%eax
f01012b1:	0f 48 c2             	cmovs  %edx,%eax
f01012b4:	c1 f8 0c             	sar    $0xc,%eax
f01012b7:	89 c3                	mov    %eax,%ebx
	// med = (int) percpu_kstacks[NCPU-1];
	cprintf("med: %x\n", med);
f01012b9:	83 ec 08             	sub    $0x8,%esp
f01012bc:	50                   	push   %eax
f01012bd:	68 8d 70 10 f0       	push   $0xf010708d
f01012c2:	e8 e9 27 00 00       	call   f0103ab0 <cprintf>
	for (i = med; i < npages; i++) {
f01012c7:	89 da                	mov    %ebx,%edx
f01012c9:	8b 35 40 72 22 f0    	mov    0xf0227240,%esi
f01012cf:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f01012d6:	83 c4 10             	add    $0x10,%esp
f01012d9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012de:	eb 23                	jmp    f0101303 <page_init+0xc7>
		pages[i].pp_ref = 0;
f01012e0:	89 c1                	mov    %eax,%ecx
f01012e2:	03 0d 98 7e 22 f0    	add    0xf0227e98,%ecx
f01012e8:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f01012ee:	89 31                	mov    %esi,(%ecx)
		page_free_list = &pages[i];
f01012f0:	89 c6                	mov    %eax,%esi
f01012f2:	03 35 98 7e 22 f0    	add    0xf0227e98,%esi
	}
	// int med = (int)ROUNDUP(kern_top - 0xf0000000, PGSIZE)/PGSIZE;
	int med = (int)ROUNDUP(((char*)envs) + (sizeof(struct Env) * NENV) - 0xf0000000, PGSIZE)/PGSIZE;
	// med = (int) percpu_kstacks[NCPU-1];
	cprintf("med: %x\n", med);
	for (i = med; i < npages; i++) {
f01012f8:	83 c2 01             	add    $0x1,%edx
f01012fb:	83 c0 08             	add    $0x8,%eax
f01012fe:	b9 01 00 00 00       	mov    $0x1,%ecx
f0101303:	3b 15 90 7e 22 f0    	cmp    0xf0227e90,%edx
f0101309:	72 d5                	jb     f01012e0 <page_init+0xa4>
f010130b:	84 c9                	test   %cl,%cl
f010130d:	74 06                	je     f0101315 <page_init+0xd9>
f010130f:	89 35 40 72 22 f0    	mov    %esi,0xf0227240
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0101315:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101318:	5b                   	pop    %ebx
f0101319:	5e                   	pop    %esi
f010131a:	5d                   	pop    %ebp
f010131b:	c3                   	ret    

f010131c <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f010131c:	55                   	push   %ebp
f010131d:	89 e5                	mov    %esp,%ebp
f010131f:	53                   	push   %ebx
f0101320:	83 ec 04             	sub    $0x4,%esp
	if (page_free_list) {
f0101323:	8b 1d 40 72 22 f0    	mov    0xf0227240,%ebx
f0101329:	85 db                	test   %ebx,%ebx
f010132b:	74 52                	je     f010137f <page_alloc+0x63>
		struct PageInfo *ret = page_free_list;
		page_free_list = page_free_list->pp_link;
f010132d:	8b 03                	mov    (%ebx),%eax
f010132f:	a3 40 72 22 f0       	mov    %eax,0xf0227240
		// cprintf("alocccccccccccccc pa: %x\n", page2pa(ret));
		if (alloc_flags & ALLOC_ZERO) 
f0101334:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101338:	74 45                	je     f010137f <page_alloc+0x63>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010133a:	89 d8                	mov    %ebx,%eax
f010133c:	2b 05 98 7e 22 f0    	sub    0xf0227e98,%eax
f0101342:	c1 f8 03             	sar    $0x3,%eax
f0101345:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101348:	89 c2                	mov    %eax,%edx
f010134a:	c1 ea 0c             	shr    $0xc,%edx
f010134d:	3b 15 90 7e 22 f0    	cmp    0xf0227e90,%edx
f0101353:	72 12                	jb     f0101367 <page_alloc+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101355:	50                   	push   %eax
f0101356:	68 5c 68 10 f0       	push   $0xf010685c
f010135b:	6a 58                	push   $0x58
f010135d:	68 84 6f 10 f0       	push   $0xf0106f84
f0101362:	e8 2d ed ff ff       	call   f0100094 <_panic>
			memset(page2kva(ret), 0, PGSIZE);
f0101367:	83 ec 04             	sub    $0x4,%esp
f010136a:	68 00 10 00 00       	push   $0x1000
f010136f:	6a 00                	push   $0x0
f0101371:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101376:	50                   	push   %eax
f0101377:	e8 e0 46 00 00       	call   f0105a5c <memset>
f010137c:	83 c4 10             	add    $0x10,%esp
		return ret;
	}
	return NULL;
}
f010137f:	89 d8                	mov    %ebx,%eax
f0101381:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101384:	c9                   	leave  
f0101385:	c3                   	ret    

f0101386 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101386:	55                   	push   %ebp
f0101387:	89 e5                	mov    %esp,%ebp
f0101389:	8b 45 08             	mov    0x8(%ebp),%eax
	// cprintf("freeeeeeeeeee pa: %x\n", page2pa(pp));
	pp->pp_link = page_free_list;
f010138c:	8b 15 40 72 22 f0    	mov    0xf0227240,%edx
f0101392:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101394:	a3 40 72 22 f0       	mov    %eax,0xf0227240
}
f0101399:	5d                   	pop    %ebp
f010139a:	c3                   	ret    

f010139b <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010139b:	55                   	push   %ebp
f010139c:	89 e5                	mov    %esp,%ebp
f010139e:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01013a1:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f01013a5:	83 e8 01             	sub    $0x1,%eax
f01013a8:	66 89 42 04          	mov    %ax,0x4(%edx)
f01013ac:	66 85 c0             	test   %ax,%ax
f01013af:	75 09                	jne    f01013ba <page_decref+0x1f>
		page_free(pp);
f01013b1:	52                   	push   %edx
f01013b2:	e8 cf ff ff ff       	call   f0101386 <page_free>
f01013b7:	83 c4 04             	add    $0x4,%esp
}
f01013ba:	c9                   	leave  
f01013bb:	c3                   	ret    

f01013bc <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01013bc:	55                   	push   %ebp
f01013bd:	89 e5                	mov    %esp,%ebp
f01013bf:	56                   	push   %esi
f01013c0:	53                   	push   %ebx
f01013c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int dindex = PDX(va), tindex = PTX(va);
f01013c4:	89 de                	mov    %ebx,%esi
f01013c6:	c1 ee 0c             	shr    $0xc,%esi
f01013c9:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
f01013cf:	c1 eb 16             	shr    $0x16,%ebx
f01013d2:	c1 e3 02             	shl    $0x2,%ebx
f01013d5:	03 5d 08             	add    0x8(%ebp),%ebx
f01013d8:	f6 03 01             	testb  $0x1,(%ebx)
f01013db:	75 2d                	jne    f010140a <pgdir_walk+0x4e>
		if (create) {
f01013dd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01013e1:	74 59                	je     f010143c <pgdir_walk+0x80>
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
f01013e3:	83 ec 0c             	sub    $0xc,%esp
f01013e6:	6a 01                	push   $0x1
f01013e8:	e8 2f ff ff ff       	call   f010131c <page_alloc>
			if (!pg) return NULL;	//allocation fails
f01013ed:	83 c4 10             	add    $0x10,%esp
f01013f0:	85 c0                	test   %eax,%eax
f01013f2:	74 4f                	je     f0101443 <pgdir_walk+0x87>
			pg->pp_ref++;
f01013f4:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
			pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
f01013f9:	2b 05 98 7e 22 f0    	sub    0xf0227e98,%eax
f01013ff:	c1 f8 03             	sar    $0x3,%eax
f0101402:	c1 e0 0c             	shl    $0xc,%eax
f0101405:	83 c8 07             	or     $0x7,%eax
f0101408:	89 03                	mov    %eax,(%ebx)
		} else return NULL;
	}
	pte_t *p = KADDR(PTE_ADDR(pgdir[dindex]));
f010140a:	8b 03                	mov    (%ebx),%eax
f010140c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101411:	89 c2                	mov    %eax,%edx
f0101413:	c1 ea 0c             	shr    $0xc,%edx
f0101416:	3b 15 90 7e 22 f0    	cmp    0xf0227e90,%edx
f010141c:	72 15                	jb     f0101433 <pgdir_walk+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010141e:	50                   	push   %eax
f010141f:	68 5c 68 10 f0       	push   $0xf010685c
f0101424:	68 be 01 00 00       	push   $0x1be
f0101429:	68 78 6f 10 f0       	push   $0xf0106f78
f010142e:	e8 61 ec ff ff       	call   f0100094 <_panic>
	// 		struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
	// 		pg->pp_ref++;
	// 		p[tindex] = page2pa(pg) | PTE_P;
	// 	} else return NULL;

	return p+tindex;
f0101433:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f010143a:	eb 0c                	jmp    f0101448 <pgdir_walk+0x8c>
		if (create) {
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
			if (!pg) return NULL;	//allocation fails
			pg->pp_ref++;
			pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
		} else return NULL;
f010143c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101441:	eb 05                	jmp    f0101448 <pgdir_walk+0x8c>
	int dindex = PDX(va), tindex = PTX(va);
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
		if (create) {
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
			if (!pg) return NULL;	//allocation fails
f0101443:	b8 00 00 00 00       	mov    $0x0,%eax
	// 		pg->pp_ref++;
	// 		p[tindex] = page2pa(pg) | PTE_P;
	// 	} else return NULL;

	return p+tindex;
}
f0101448:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010144b:	5b                   	pop    %ebx
f010144c:	5e                   	pop    %esi
f010144d:	5d                   	pop    %ebp
f010144e:	c3                   	ret    

f010144f <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010144f:	55                   	push   %ebp
f0101450:	89 e5                	mov    %esp,%ebp
f0101452:	57                   	push   %edi
f0101453:	56                   	push   %esi
f0101454:	53                   	push   %ebx
f0101455:	83 ec 1c             	sub    $0x1c,%esp
f0101458:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010145b:	89 d7                	mov    %edx,%edi
f010145d:	89 cb                	mov    %ecx,%ebx
	int i;
	cprintf("thiscpu: %x\n", thiscpu);
f010145f:	e8 18 4c 00 00       	call   f010607c <cpunum>
f0101464:	83 ec 08             	sub    $0x8,%esp
f0101467:	6b c0 74             	imul   $0x74,%eax,%eax
f010146a:	05 20 80 22 f0       	add    $0xf0228020,%eax
f010146f:	50                   	push   %eax
f0101470:	68 96 70 10 f0       	push   $0xf0107096
f0101475:	e8 36 26 00 00       	call   f0103ab0 <cprintf>
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
f010147a:	83 c4 0c             	add    $0xc,%esp
f010147d:	ff 75 08             	pushl  0x8(%ebp)
f0101480:	57                   	push   %edi
f0101481:	68 3c 74 10 f0       	push   $0xf010743c
f0101486:	e8 25 26 00 00       	call   f0103ab0 <cprintf>
f010148b:	c1 eb 0c             	shr    $0xc,%ebx
f010148e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f0101491:	83 c4 10             	add    $0x10,%esp
f0101494:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101497:	be 00 00 00 00       	mov    $0x0,%esi
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
f010149c:	29 df                	sub    %ebx,%edi
		if (!pte) panic("boot_map_region panic, out of memory");
		*pte = pa | perm | PTE_P;
f010149e:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014a1:	83 c8 01             	or     $0x1,%eax
f01014a4:	89 45 dc             	mov    %eax,-0x24(%ebp)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
	cprintf("thiscpu: %x\n", thiscpu);
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f01014a7:	eb 3f                	jmp    f01014e8 <boot_map_region+0x99>
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
f01014a9:	83 ec 04             	sub    $0x4,%esp
f01014ac:	6a 01                	push   $0x1
f01014ae:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01014b1:	50                   	push   %eax
f01014b2:	ff 75 e0             	pushl  -0x20(%ebp)
f01014b5:	e8 02 ff ff ff       	call   f01013bc <pgdir_walk>
		if (!pte) panic("boot_map_region panic, out of memory");
f01014ba:	83 c4 10             	add    $0x10,%esp
f01014bd:	85 c0                	test   %eax,%eax
f01014bf:	75 17                	jne    f01014d8 <boot_map_region+0x89>
f01014c1:	83 ec 04             	sub    $0x4,%esp
f01014c4:	68 58 6e 10 f0       	push   $0xf0106e58
f01014c9:	68 dd 01 00 00       	push   $0x1dd
f01014ce:	68 78 6f 10 f0       	push   $0xf0106f78
f01014d3:	e8 bc eb ff ff       	call   f0100094 <_panic>
		*pte = pa | perm | PTE_P;
f01014d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01014db:	09 da                	or     %ebx,%edx
f01014dd:	89 10                	mov    %edx,(%eax)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
	cprintf("thiscpu: %x\n", thiscpu);
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f01014df:	83 c6 01             	add    $0x1,%esi
f01014e2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01014e8:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01014eb:	75 bc                	jne    f01014a9 <boot_map_region+0x5a>
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
		if (!pte) panic("boot_map_region panic, out of memory");
		*pte = pa | perm | PTE_P;
	}
}
f01014ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014f0:	5b                   	pop    %ebx
f01014f1:	5e                   	pop    %esi
f01014f2:	5f                   	pop    %edi
f01014f3:	5d                   	pop    %ebp
f01014f4:	c3                   	ret    

f01014f5 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01014f5:	55                   	push   %ebp
f01014f6:	89 e5                	mov    %esp,%ebp
f01014f8:	53                   	push   %ebx
f01014f9:	83 ec 08             	sub    $0x8,%esp
f01014fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0);	//not create
f01014ff:	6a 00                	push   $0x0
f0101501:	ff 75 0c             	pushl  0xc(%ebp)
f0101504:	ff 75 08             	pushl  0x8(%ebp)
f0101507:	e8 b0 fe ff ff       	call   f01013bc <pgdir_walk>
	if (!pte || !(*pte & PTE_P)) return NULL;	//page not found
f010150c:	83 c4 10             	add    $0x10,%esp
f010150f:	85 c0                	test   %eax,%eax
f0101511:	74 37                	je     f010154a <page_lookup+0x55>
f0101513:	f6 00 01             	testb  $0x1,(%eax)
f0101516:	74 39                	je     f0101551 <page_lookup+0x5c>
	if (pte_store)
f0101518:	85 db                	test   %ebx,%ebx
f010151a:	74 02                	je     f010151e <page_lookup+0x29>
		*pte_store = pte;	//found and set
f010151c:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010151e:	8b 00                	mov    (%eax),%eax
f0101520:	c1 e8 0c             	shr    $0xc,%eax
f0101523:	3b 05 90 7e 22 f0    	cmp    0xf0227e90,%eax
f0101529:	72 14                	jb     f010153f <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f010152b:	83 ec 04             	sub    $0x4,%esp
f010152e:	68 70 74 10 f0       	push   $0xf0107470
f0101533:	6a 51                	push   $0x51
f0101535:	68 84 6f 10 f0       	push   $0xf0106f84
f010153a:	e8 55 eb ff ff       	call   f0100094 <_panic>
	return &pages[PGNUM(pa)];
f010153f:	8b 15 98 7e 22 f0    	mov    0xf0227e98,%edx
f0101545:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	return pa2page(PTE_ADDR(*pte));		
f0101548:	eb 0c                	jmp    f0101556 <page_lookup+0x61>
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t *pte = pgdir_walk(pgdir, va, 0);	//not create
	if (!pte || !(*pte & PTE_P)) return NULL;	//page not found
f010154a:	b8 00 00 00 00       	mov    $0x0,%eax
f010154f:	eb 05                	jmp    f0101556 <page_lookup+0x61>
f0101551:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pte_store)
		*pte_store = pte;	//found and set
	return pa2page(PTE_ADDR(*pte));		
}
f0101556:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101559:	c9                   	leave  
f010155a:	c3                   	ret    

f010155b <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010155b:	55                   	push   %ebp
f010155c:	89 e5                	mov    %esp,%ebp
f010155e:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101561:	e8 16 4b 00 00       	call   f010607c <cpunum>
f0101566:	6b c0 74             	imul   $0x74,%eax,%eax
f0101569:	83 b8 28 80 22 f0 00 	cmpl   $0x0,-0xfdd7fd8(%eax)
f0101570:	74 16                	je     f0101588 <tlb_invalidate+0x2d>
f0101572:	e8 05 4b 00 00       	call   f010607c <cpunum>
f0101577:	6b c0 74             	imul   $0x74,%eax,%eax
f010157a:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f0101580:	8b 55 08             	mov    0x8(%ebp),%edx
f0101583:	39 50 60             	cmp    %edx,0x60(%eax)
f0101586:	75 06                	jne    f010158e <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101588:	8b 45 0c             	mov    0xc(%ebp),%eax
f010158b:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f010158e:	c9                   	leave  
f010158f:	c3                   	ret    

f0101590 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101590:	55                   	push   %ebp
f0101591:	89 e5                	mov    %esp,%ebp
f0101593:	56                   	push   %esi
f0101594:	53                   	push   %ebx
f0101595:	83 ec 14             	sub    $0x14,%esp
f0101598:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010159b:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *pte;
	struct PageInfo *pg = page_lookup(pgdir, va, &pte);
f010159e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01015a1:	50                   	push   %eax
f01015a2:	56                   	push   %esi
f01015a3:	53                   	push   %ebx
f01015a4:	e8 4c ff ff ff       	call   f01014f5 <page_lookup>
	if (!pg || !(*pte & PTE_P)) return;	//page not exist
f01015a9:	83 c4 10             	add    $0x10,%esp
f01015ac:	85 c0                	test   %eax,%eax
f01015ae:	74 27                	je     f01015d7 <page_remove+0x47>
f01015b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01015b3:	f6 02 01             	testb  $0x1,(%edx)
f01015b6:	74 1f                	je     f01015d7 <page_remove+0x47>
//   - The ref count on the physical page should decrement.
//   - The physical page should be freed if the refcount reaches 0.
	page_decref(pg);
f01015b8:	83 ec 0c             	sub    $0xc,%esp
f01015bb:	50                   	push   %eax
f01015bc:	e8 da fd ff ff       	call   f010139b <page_decref>
//   - The pg table entry corresponding to 'va' should be set to 0.
	*pte = 0;
f01015c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01015c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
//   - The TLB must be invalidated if you remove an entry from
//     the page table.
	tlb_invalidate(pgdir, va);
f01015ca:	83 c4 08             	add    $0x8,%esp
f01015cd:	56                   	push   %esi
f01015ce:	53                   	push   %ebx
f01015cf:	e8 87 ff ff ff       	call   f010155b <tlb_invalidate>
f01015d4:	83 c4 10             	add    $0x10,%esp
}
f01015d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01015da:	5b                   	pop    %ebx
f01015db:	5e                   	pop    %esi
f01015dc:	5d                   	pop    %ebp
f01015dd:	c3                   	ret    

f01015de <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01015de:	55                   	push   %ebp
f01015df:	89 e5                	mov    %esp,%ebp
f01015e1:	57                   	push   %edi
f01015e2:	56                   	push   %esi
f01015e3:	53                   	push   %ebx
f01015e4:	83 ec 10             	sub    $0x10,%esp
f01015e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01015ea:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1);	//create on demand
f01015ed:	6a 01                	push   $0x1
f01015ef:	57                   	push   %edi
f01015f0:	ff 75 08             	pushl  0x8(%ebp)
f01015f3:	e8 c4 fd ff ff       	call   f01013bc <pgdir_walk>
	if (!pte) 	//page table not allocated
f01015f8:	83 c4 10             	add    $0x10,%esp
f01015fb:	85 c0                	test   %eax,%eax
f01015fd:	74 38                	je     f0101637 <page_insert+0x59>
f01015ff:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;	
	//increase ref count to avoid the corner case that pp is freed before it is inserted.
	pp->pp_ref++;	
f0101601:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P) 	//page colides, tle is invalidated in page_remove
f0101606:	f6 00 01             	testb  $0x1,(%eax)
f0101609:	74 0f                	je     f010161a <page_insert+0x3c>
		page_remove(pgdir, va);
f010160b:	83 ec 08             	sub    $0x8,%esp
f010160e:	57                   	push   %edi
f010160f:	ff 75 08             	pushl  0x8(%ebp)
f0101612:	e8 79 ff ff ff       	call   f0101590 <page_remove>
f0101617:	83 c4 10             	add    $0x10,%esp
	*pte = page2pa(pp) | perm | PTE_P;
f010161a:	2b 1d 98 7e 22 f0    	sub    0xf0227e98,%ebx
f0101620:	c1 fb 03             	sar    $0x3,%ebx
f0101623:	c1 e3 0c             	shl    $0xc,%ebx
f0101626:	8b 45 14             	mov    0x14(%ebp),%eax
f0101629:	83 c8 01             	or     $0x1,%eax
f010162c:	09 c3                	or     %eax,%ebx
f010162e:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101630:	b8 00 00 00 00       	mov    $0x0,%eax
f0101635:	eb 05                	jmp    f010163c <page_insert+0x5e>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t *pte = pgdir_walk(pgdir, va, 1);	//create on demand
	if (!pte) 	//page table not allocated
		return -E_NO_MEM;	
f0101637:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	pp->pp_ref++;	
	if (*pte & PTE_P) 	//page colides, tle is invalidated in page_remove
		page_remove(pgdir, va);
	*pte = page2pa(pp) | perm | PTE_P;
	return 0;
}
f010163c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010163f:	5b                   	pop    %ebx
f0101640:	5e                   	pop    %esi
f0101641:	5f                   	pop    %edi
f0101642:	5d                   	pop    %ebp
f0101643:	c3                   	ret    

f0101644 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101644:	55                   	push   %ebp
f0101645:	89 e5                	mov    %esp,%ebp
f0101647:	53                   	push   %ebx
f0101648:	83 ec 04             	sub    $0x4,%esp
f010164b:	8b 45 08             	mov    0x8(%ebp),%eax
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size = ROUNDUP(pa+size, PGSIZE);
f010164e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101651:	8d 9c 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%ebx
	pa = ROUNDDOWN(pa, PGSIZE);
f0101658:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	size -= pa;
f010165d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0101663:	29 c3                	sub    %eax,%ebx
	if (base+size >= MMIOLIM) panic("not enough memory");
f0101665:	8b 15 00 13 12 f0    	mov    0xf0121300,%edx
f010166b:	8d 0c 13             	lea    (%ebx,%edx,1),%ecx
f010166e:	81 f9 ff ff bf ef    	cmp    $0xefbfffff,%ecx
f0101674:	76 17                	jbe    f010168d <mmio_map_region+0x49>
f0101676:	83 ec 04             	sub    $0x4,%esp
f0101679:	68 a3 70 10 f0       	push   $0xf01070a3
f010167e:	68 6c 02 00 00       	push   $0x26c
f0101683:	68 78 6f 10 f0       	push   $0xf0106f78
f0101688:	e8 07 ea ff ff       	call   f0100094 <_panic>
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f010168d:	83 ec 08             	sub    $0x8,%esp
f0101690:	6a 1a                	push   $0x1a
f0101692:	50                   	push   %eax
f0101693:	89 d9                	mov    %ebx,%ecx
f0101695:	a1 94 7e 22 f0       	mov    0xf0227e94,%eax
f010169a:	e8 b0 fd ff ff       	call   f010144f <boot_map_region>
	base += size;
f010169f:	a1 00 13 12 f0       	mov    0xf0121300,%eax
f01016a4:	01 c3                	add    %eax,%ebx
f01016a6:	89 1d 00 13 12 f0    	mov    %ebx,0xf0121300
	return (void*) (base - size);
	// panic("mmio_map_region not implemented");
}
f01016ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01016af:	c9                   	leave  
f01016b0:	c3                   	ret    

f01016b1 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01016b1:	55                   	push   %ebp
f01016b2:	89 e5                	mov    %esp,%ebp
f01016b4:	57                   	push   %edi
f01016b5:	56                   	push   %esi
f01016b6:	53                   	push   %ebx
f01016b7:	83 ec 48             	sub    $0x48,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01016ba:	6a 15                	push   $0x15
f01016bc:	e8 70 22 00 00       	call   f0103931 <mc146818_read>
f01016c1:	89 c3                	mov    %eax,%ebx
f01016c3:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01016ca:	e8 62 22 00 00       	call   f0103931 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01016cf:	c1 e0 08             	shl    $0x8,%eax
f01016d2:	09 d8                	or     %ebx,%eax
f01016d4:	c1 e0 0a             	shl    $0xa,%eax
f01016d7:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01016dd:	85 c0                	test   %eax,%eax
f01016df:	0f 48 c2             	cmovs  %edx,%eax
f01016e2:	c1 f8 0c             	sar    $0xc,%eax
f01016e5:	a3 44 72 22 f0       	mov    %eax,0xf0227244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01016ea:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01016f1:	e8 3b 22 00 00       	call   f0103931 <mc146818_read>
f01016f6:	89 c3                	mov    %eax,%ebx
f01016f8:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01016ff:	e8 2d 22 00 00       	call   f0103931 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101704:	c1 e0 08             	shl    $0x8,%eax
f0101707:	09 d8                	or     %ebx,%eax
f0101709:	c1 e0 0a             	shl    $0xa,%eax
f010170c:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101712:	83 c4 10             	add    $0x10,%esp
f0101715:	85 c0                	test   %eax,%eax
f0101717:	0f 48 c2             	cmovs  %edx,%eax
f010171a:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010171d:	85 c0                	test   %eax,%eax
f010171f:	74 0e                	je     f010172f <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101721:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101727:	89 15 90 7e 22 f0    	mov    %edx,0xf0227e90
f010172d:	eb 0c                	jmp    f010173b <mem_init+0x8a>
	else
		npages = npages_basemem;
f010172f:	8b 15 44 72 22 f0    	mov    0xf0227244,%edx
f0101735:	89 15 90 7e 22 f0    	mov    %edx,0xf0227e90

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010173b:	c1 e0 0c             	shl    $0xc,%eax
f010173e:	c1 e8 0a             	shr    $0xa,%eax
f0101741:	50                   	push   %eax
f0101742:	a1 44 72 22 f0       	mov    0xf0227244,%eax
f0101747:	c1 e0 0c             	shl    $0xc,%eax
f010174a:	c1 e8 0a             	shr    $0xa,%eax
f010174d:	50                   	push   %eax
f010174e:	a1 90 7e 22 f0       	mov    0xf0227e90,%eax
f0101753:	c1 e0 0c             	shl    $0xc,%eax
f0101756:	c1 e8 0a             	shr    $0xa,%eax
f0101759:	50                   	push   %eax
f010175a:	68 90 74 10 f0       	push   $0xf0107490
f010175f:	e8 4c 23 00 00       	call   f0103ab0 <cprintf>
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.

	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101764:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101769:	e8 f0 f6 ff ff       	call   f0100e5e <boot_alloc>
f010176e:	a3 94 7e 22 f0       	mov    %eax,0xf0227e94
	memset(kern_pgdir, 0, PGSIZE);
f0101773:	83 c4 0c             	add    $0xc,%esp
f0101776:	68 00 10 00 00       	push   $0x1000
f010177b:	6a 00                	push   $0x0
f010177d:	50                   	push   %eax
f010177e:	e8 d9 42 00 00       	call   f0105a5c <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101783:	a1 94 7e 22 f0       	mov    0xf0227e94,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101788:	83 c4 10             	add    $0x10,%esp
f010178b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101790:	77 15                	ja     f01017a7 <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101792:	50                   	push   %eax
f0101793:	68 a8 68 10 f0       	push   $0xf01068a8
f0101798:	68 96 00 00 00       	push   $0x96
f010179d:	68 78 6f 10 f0       	push   $0xf0106f78
f01017a2:	e8 ed e8 ff ff       	call   f0100094 <_panic>
f01017a7:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01017ad:	83 ca 05             	or     $0x5,%edx
f01017b0:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo) * npages);
f01017b6:	a1 90 7e 22 f0       	mov    0xf0227e90,%eax
f01017bb:	c1 e0 03             	shl    $0x3,%eax
f01017be:	e8 9b f6 ff ff       	call   f0100e5e <boot_alloc>
f01017c3:	a3 98 7e 22 f0       	mov    %eax,0xf0227e98

	cprintf("npages: %d\n", npages);
f01017c8:	83 ec 08             	sub    $0x8,%esp
f01017cb:	ff 35 90 7e 22 f0    	pushl  0xf0227e90
f01017d1:	68 b5 70 10 f0       	push   $0xf01070b5
f01017d6:	e8 d5 22 00 00       	call   f0103ab0 <cprintf>
	cprintf("npages_basemem: %d\n", npages_basemem);
f01017db:	83 c4 08             	add    $0x8,%esp
f01017de:	ff 35 44 72 22 f0    	pushl  0xf0227244
f01017e4:	68 c1 70 10 f0       	push   $0xf01070c1
f01017e9:	e8 c2 22 00 00       	call   f0103ab0 <cprintf>
	cprintf("pages: %x\n", pages);
f01017ee:	83 c4 08             	add    $0x8,%esp
f01017f1:	ff 35 98 7e 22 f0    	pushl  0xf0227e98
f01017f7:	68 d5 70 10 f0       	push   $0xf01070d5
f01017fc:	e8 af 22 00 00       	call   f0103ab0 <cprintf>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *) boot_alloc(sizeof(struct Env) * NENV);
f0101801:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101806:	e8 53 f6 ff ff       	call   f0100e5e <boot_alloc>
f010180b:	a3 48 72 22 f0       	mov    %eax,0xf0227248
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101810:	e8 27 fa ff ff       	call   f010123c <page_init>

	check_page_free_list(1);
f0101815:	b8 01 00 00 00       	mov    $0x1,%eax
f010181a:	e8 1b f7 ff ff       	call   f0100f3a <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010181f:	83 c4 10             	add    $0x10,%esp
f0101822:	83 3d 98 7e 22 f0 00 	cmpl   $0x0,0xf0227e98
f0101829:	75 17                	jne    f0101842 <mem_init+0x191>
		panic("'pages' is a null pointer!");
f010182b:	83 ec 04             	sub    $0x4,%esp
f010182e:	68 e0 70 10 f0       	push   $0xf01070e0
f0101833:	68 00 03 00 00       	push   $0x300
f0101838:	68 78 6f 10 f0       	push   $0xf0106f78
f010183d:	e8 52 e8 ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101842:	a1 40 72 22 f0       	mov    0xf0227240,%eax
f0101847:	bb 00 00 00 00       	mov    $0x0,%ebx
f010184c:	eb 05                	jmp    f0101853 <mem_init+0x1a2>
		++nfree;
f010184e:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101851:	8b 00                	mov    (%eax),%eax
f0101853:	85 c0                	test   %eax,%eax
f0101855:	75 f7                	jne    f010184e <mem_init+0x19d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101857:	83 ec 0c             	sub    $0xc,%esp
f010185a:	6a 00                	push   $0x0
f010185c:	e8 bb fa ff ff       	call   f010131c <page_alloc>
f0101861:	89 c7                	mov    %eax,%edi
f0101863:	83 c4 10             	add    $0x10,%esp
f0101866:	85 c0                	test   %eax,%eax
f0101868:	75 19                	jne    f0101883 <mem_init+0x1d2>
f010186a:	68 fb 70 10 f0       	push   $0xf01070fb
f010186f:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101874:	68 08 03 00 00       	push   $0x308
f0101879:	68 78 6f 10 f0       	push   $0xf0106f78
f010187e:	e8 11 e8 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101883:	83 ec 0c             	sub    $0xc,%esp
f0101886:	6a 00                	push   $0x0
f0101888:	e8 8f fa ff ff       	call   f010131c <page_alloc>
f010188d:	89 c6                	mov    %eax,%esi
f010188f:	83 c4 10             	add    $0x10,%esp
f0101892:	85 c0                	test   %eax,%eax
f0101894:	75 19                	jne    f01018af <mem_init+0x1fe>
f0101896:	68 11 71 10 f0       	push   $0xf0107111
f010189b:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01018a0:	68 09 03 00 00       	push   $0x309
f01018a5:	68 78 6f 10 f0       	push   $0xf0106f78
f01018aa:	e8 e5 e7 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01018af:	83 ec 0c             	sub    $0xc,%esp
f01018b2:	6a 00                	push   $0x0
f01018b4:	e8 63 fa ff ff       	call   f010131c <page_alloc>
f01018b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018bc:	83 c4 10             	add    $0x10,%esp
f01018bf:	85 c0                	test   %eax,%eax
f01018c1:	75 19                	jne    f01018dc <mem_init+0x22b>
f01018c3:	68 27 71 10 f0       	push   $0xf0107127
f01018c8:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01018cd:	68 0a 03 00 00       	push   $0x30a
f01018d2:	68 78 6f 10 f0       	push   $0xf0106f78
f01018d7:	e8 b8 e7 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018dc:	39 f7                	cmp    %esi,%edi
f01018de:	75 19                	jne    f01018f9 <mem_init+0x248>
f01018e0:	68 3d 71 10 f0       	push   $0xf010713d
f01018e5:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01018ea:	68 0d 03 00 00       	push   $0x30d
f01018ef:	68 78 6f 10 f0       	push   $0xf0106f78
f01018f4:	e8 9b e7 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018f9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01018fc:	39 c6                	cmp    %eax,%esi
f01018fe:	74 04                	je     f0101904 <mem_init+0x253>
f0101900:	39 c7                	cmp    %eax,%edi
f0101902:	75 19                	jne    f010191d <mem_init+0x26c>
f0101904:	68 cc 74 10 f0       	push   $0xf01074cc
f0101909:	68 9e 6f 10 f0       	push   $0xf0106f9e
f010190e:	68 0e 03 00 00       	push   $0x30e
f0101913:	68 78 6f 10 f0       	push   $0xf0106f78
f0101918:	e8 77 e7 ff ff       	call   f0100094 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010191d:	8b 0d 98 7e 22 f0    	mov    0xf0227e98,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101923:	8b 15 90 7e 22 f0    	mov    0xf0227e90,%edx
f0101929:	c1 e2 0c             	shl    $0xc,%edx
f010192c:	89 f8                	mov    %edi,%eax
f010192e:	29 c8                	sub    %ecx,%eax
f0101930:	c1 f8 03             	sar    $0x3,%eax
f0101933:	c1 e0 0c             	shl    $0xc,%eax
f0101936:	39 d0                	cmp    %edx,%eax
f0101938:	72 19                	jb     f0101953 <mem_init+0x2a2>
f010193a:	68 4f 71 10 f0       	push   $0xf010714f
f010193f:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101944:	68 0f 03 00 00       	push   $0x30f
f0101949:	68 78 6f 10 f0       	push   $0xf0106f78
f010194e:	e8 41 e7 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101953:	89 f0                	mov    %esi,%eax
f0101955:	29 c8                	sub    %ecx,%eax
f0101957:	c1 f8 03             	sar    $0x3,%eax
f010195a:	c1 e0 0c             	shl    $0xc,%eax
f010195d:	39 c2                	cmp    %eax,%edx
f010195f:	77 19                	ja     f010197a <mem_init+0x2c9>
f0101961:	68 6c 71 10 f0       	push   $0xf010716c
f0101966:	68 9e 6f 10 f0       	push   $0xf0106f9e
f010196b:	68 10 03 00 00       	push   $0x310
f0101970:	68 78 6f 10 f0       	push   $0xf0106f78
f0101975:	e8 1a e7 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010197a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010197d:	29 c8                	sub    %ecx,%eax
f010197f:	c1 f8 03             	sar    $0x3,%eax
f0101982:	c1 e0 0c             	shl    $0xc,%eax
f0101985:	39 c2                	cmp    %eax,%edx
f0101987:	77 19                	ja     f01019a2 <mem_init+0x2f1>
f0101989:	68 89 71 10 f0       	push   $0xf0107189
f010198e:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101993:	68 11 03 00 00       	push   $0x311
f0101998:	68 78 6f 10 f0       	push   $0xf0106f78
f010199d:	e8 f2 e6 ff ff       	call   f0100094 <_panic>


	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01019a2:	a1 40 72 22 f0       	mov    0xf0227240,%eax
f01019a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01019aa:	c7 05 40 72 22 f0 00 	movl   $0x0,0xf0227240
f01019b1:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01019b4:	83 ec 0c             	sub    $0xc,%esp
f01019b7:	6a 00                	push   $0x0
f01019b9:	e8 5e f9 ff ff       	call   f010131c <page_alloc>
f01019be:	83 c4 10             	add    $0x10,%esp
f01019c1:	85 c0                	test   %eax,%eax
f01019c3:	74 19                	je     f01019de <mem_init+0x32d>
f01019c5:	68 a6 71 10 f0       	push   $0xf01071a6
f01019ca:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01019cf:	68 19 03 00 00       	push   $0x319
f01019d4:	68 78 6f 10 f0       	push   $0xf0106f78
f01019d9:	e8 b6 e6 ff ff       	call   f0100094 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01019de:	83 ec 0c             	sub    $0xc,%esp
f01019e1:	57                   	push   %edi
f01019e2:	e8 9f f9 ff ff       	call   f0101386 <page_free>
	page_free(pp1);
f01019e7:	89 34 24             	mov    %esi,(%esp)
f01019ea:	e8 97 f9 ff ff       	call   f0101386 <page_free>
	page_free(pp2);
f01019ef:	83 c4 04             	add    $0x4,%esp
f01019f2:	ff 75 d4             	pushl  -0x2c(%ebp)
f01019f5:	e8 8c f9 ff ff       	call   f0101386 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01019fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a01:	e8 16 f9 ff ff       	call   f010131c <page_alloc>
f0101a06:	89 c6                	mov    %eax,%esi
f0101a08:	83 c4 10             	add    $0x10,%esp
f0101a0b:	85 c0                	test   %eax,%eax
f0101a0d:	75 19                	jne    f0101a28 <mem_init+0x377>
f0101a0f:	68 fb 70 10 f0       	push   $0xf01070fb
f0101a14:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101a19:	68 20 03 00 00       	push   $0x320
f0101a1e:	68 78 6f 10 f0       	push   $0xf0106f78
f0101a23:	e8 6c e6 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a28:	83 ec 0c             	sub    $0xc,%esp
f0101a2b:	6a 00                	push   $0x0
f0101a2d:	e8 ea f8 ff ff       	call   f010131c <page_alloc>
f0101a32:	89 c7                	mov    %eax,%edi
f0101a34:	83 c4 10             	add    $0x10,%esp
f0101a37:	85 c0                	test   %eax,%eax
f0101a39:	75 19                	jne    f0101a54 <mem_init+0x3a3>
f0101a3b:	68 11 71 10 f0       	push   $0xf0107111
f0101a40:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101a45:	68 21 03 00 00       	push   $0x321
f0101a4a:	68 78 6f 10 f0       	push   $0xf0106f78
f0101a4f:	e8 40 e6 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a54:	83 ec 0c             	sub    $0xc,%esp
f0101a57:	6a 00                	push   $0x0
f0101a59:	e8 be f8 ff ff       	call   f010131c <page_alloc>
f0101a5e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a61:	83 c4 10             	add    $0x10,%esp
f0101a64:	85 c0                	test   %eax,%eax
f0101a66:	75 19                	jne    f0101a81 <mem_init+0x3d0>
f0101a68:	68 27 71 10 f0       	push   $0xf0107127
f0101a6d:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101a72:	68 22 03 00 00       	push   $0x322
f0101a77:	68 78 6f 10 f0       	push   $0xf0106f78
f0101a7c:	e8 13 e6 ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a81:	39 fe                	cmp    %edi,%esi
f0101a83:	75 19                	jne    f0101a9e <mem_init+0x3ed>
f0101a85:	68 3d 71 10 f0       	push   $0xf010713d
f0101a8a:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101a8f:	68 24 03 00 00       	push   $0x324
f0101a94:	68 78 6f 10 f0       	push   $0xf0106f78
f0101a99:	e8 f6 e5 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a9e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101aa1:	39 c7                	cmp    %eax,%edi
f0101aa3:	74 04                	je     f0101aa9 <mem_init+0x3f8>
f0101aa5:	39 c6                	cmp    %eax,%esi
f0101aa7:	75 19                	jne    f0101ac2 <mem_init+0x411>
f0101aa9:	68 cc 74 10 f0       	push   $0xf01074cc
f0101aae:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101ab3:	68 25 03 00 00       	push   $0x325
f0101ab8:	68 78 6f 10 f0       	push   $0xf0106f78
f0101abd:	e8 d2 e5 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101ac2:	83 ec 0c             	sub    $0xc,%esp
f0101ac5:	6a 00                	push   $0x0
f0101ac7:	e8 50 f8 ff ff       	call   f010131c <page_alloc>
f0101acc:	83 c4 10             	add    $0x10,%esp
f0101acf:	85 c0                	test   %eax,%eax
f0101ad1:	74 19                	je     f0101aec <mem_init+0x43b>
f0101ad3:	68 a6 71 10 f0       	push   $0xf01071a6
f0101ad8:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101add:	68 26 03 00 00       	push   $0x326
f0101ae2:	68 78 6f 10 f0       	push   $0xf0106f78
f0101ae7:	e8 a8 e5 ff ff       	call   f0100094 <_panic>
f0101aec:	89 f0                	mov    %esi,%eax
f0101aee:	2b 05 98 7e 22 f0    	sub    0xf0227e98,%eax
f0101af4:	c1 f8 03             	sar    $0x3,%eax
f0101af7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101afa:	89 c2                	mov    %eax,%edx
f0101afc:	c1 ea 0c             	shr    $0xc,%edx
f0101aff:	3b 15 90 7e 22 f0    	cmp    0xf0227e90,%edx
f0101b05:	72 12                	jb     f0101b19 <mem_init+0x468>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b07:	50                   	push   %eax
f0101b08:	68 5c 68 10 f0       	push   $0xf010685c
f0101b0d:	6a 58                	push   $0x58
f0101b0f:	68 84 6f 10 f0       	push   $0xf0106f84
f0101b14:	e8 7b e5 ff ff       	call   f0100094 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101b19:	83 ec 04             	sub    $0x4,%esp
f0101b1c:	68 00 10 00 00       	push   $0x1000
f0101b21:	6a 01                	push   $0x1
f0101b23:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b28:	50                   	push   %eax
f0101b29:	e8 2e 3f 00 00       	call   f0105a5c <memset>
	page_free(pp0);
f0101b2e:	89 34 24             	mov    %esi,(%esp)
f0101b31:	e8 50 f8 ff ff       	call   f0101386 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101b36:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101b3d:	e8 da f7 ff ff       	call   f010131c <page_alloc>
f0101b42:	83 c4 10             	add    $0x10,%esp
f0101b45:	85 c0                	test   %eax,%eax
f0101b47:	75 19                	jne    f0101b62 <mem_init+0x4b1>
f0101b49:	68 b5 71 10 f0       	push   $0xf01071b5
f0101b4e:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101b53:	68 2b 03 00 00       	push   $0x32b
f0101b58:	68 78 6f 10 f0       	push   $0xf0106f78
f0101b5d:	e8 32 e5 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f0101b62:	39 c6                	cmp    %eax,%esi
f0101b64:	74 19                	je     f0101b7f <mem_init+0x4ce>
f0101b66:	68 d3 71 10 f0       	push   $0xf01071d3
f0101b6b:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101b70:	68 2c 03 00 00       	push   $0x32c
f0101b75:	68 78 6f 10 f0       	push   $0xf0106f78
f0101b7a:	e8 15 e5 ff ff       	call   f0100094 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b7f:	89 f0                	mov    %esi,%eax
f0101b81:	2b 05 98 7e 22 f0    	sub    0xf0227e98,%eax
f0101b87:	c1 f8 03             	sar    $0x3,%eax
f0101b8a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b8d:	89 c2                	mov    %eax,%edx
f0101b8f:	c1 ea 0c             	shr    $0xc,%edx
f0101b92:	3b 15 90 7e 22 f0    	cmp    0xf0227e90,%edx
f0101b98:	72 12                	jb     f0101bac <mem_init+0x4fb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b9a:	50                   	push   %eax
f0101b9b:	68 5c 68 10 f0       	push   $0xf010685c
f0101ba0:	6a 58                	push   $0x58
f0101ba2:	68 84 6f 10 f0       	push   $0xf0106f84
f0101ba7:	e8 e8 e4 ff ff       	call   f0100094 <_panic>
f0101bac:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101bb2:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101bb8:	80 38 00             	cmpb   $0x0,(%eax)
f0101bbb:	74 19                	je     f0101bd6 <mem_init+0x525>
f0101bbd:	68 e3 71 10 f0       	push   $0xf01071e3
f0101bc2:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101bc7:	68 2f 03 00 00       	push   $0x32f
f0101bcc:	68 78 6f 10 f0       	push   $0xf0106f78
f0101bd1:	e8 be e4 ff ff       	call   f0100094 <_panic>
f0101bd6:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101bd9:	39 d0                	cmp    %edx,%eax
f0101bdb:	75 db                	jne    f0101bb8 <mem_init+0x507>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101bdd:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101be0:	a3 40 72 22 f0       	mov    %eax,0xf0227240

	// free the pages we took
	page_free(pp0);
f0101be5:	83 ec 0c             	sub    $0xc,%esp
f0101be8:	56                   	push   %esi
f0101be9:	e8 98 f7 ff ff       	call   f0101386 <page_free>
	page_free(pp1);
f0101bee:	89 3c 24             	mov    %edi,(%esp)
f0101bf1:	e8 90 f7 ff ff       	call   f0101386 <page_free>
	page_free(pp2);
f0101bf6:	83 c4 04             	add    $0x4,%esp
f0101bf9:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101bfc:	e8 85 f7 ff ff       	call   f0101386 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101c01:	a1 40 72 22 f0       	mov    0xf0227240,%eax
f0101c06:	83 c4 10             	add    $0x10,%esp
f0101c09:	eb 05                	jmp    f0101c10 <mem_init+0x55f>
		--nfree;
f0101c0b:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101c0e:	8b 00                	mov    (%eax),%eax
f0101c10:	85 c0                	test   %eax,%eax
f0101c12:	75 f7                	jne    f0101c0b <mem_init+0x55a>
		--nfree;
	assert(nfree == 0);
f0101c14:	85 db                	test   %ebx,%ebx
f0101c16:	74 19                	je     f0101c31 <mem_init+0x580>
f0101c18:	68 ed 71 10 f0       	push   $0xf01071ed
f0101c1d:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101c22:	68 3c 03 00 00       	push   $0x33c
f0101c27:	68 78 6f 10 f0       	push   $0xf0106f78
f0101c2c:	e8 63 e4 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101c31:	83 ec 0c             	sub    $0xc,%esp
f0101c34:	68 ec 74 10 f0       	push   $0xf01074ec
f0101c39:	e8 72 1e 00 00       	call   f0103ab0 <cprintf>
	// or page_insert
	page_init();

	check_page_free_list(1);
	check_page_alloc();
	cprintf("so far so good\n");
f0101c3e:	c7 04 24 f8 71 10 f0 	movl   $0xf01071f8,(%esp)
f0101c45:	e8 66 1e 00 00       	call   f0103ab0 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101c4a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c51:	e8 c6 f6 ff ff       	call   f010131c <page_alloc>
f0101c56:	89 c6                	mov    %eax,%esi
f0101c58:	83 c4 10             	add    $0x10,%esp
f0101c5b:	85 c0                	test   %eax,%eax
f0101c5d:	75 19                	jne    f0101c78 <mem_init+0x5c7>
f0101c5f:	68 fb 70 10 f0       	push   $0xf01070fb
f0101c64:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101c69:	68 a7 03 00 00       	push   $0x3a7
f0101c6e:	68 78 6f 10 f0       	push   $0xf0106f78
f0101c73:	e8 1c e4 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c78:	83 ec 0c             	sub    $0xc,%esp
f0101c7b:	6a 00                	push   $0x0
f0101c7d:	e8 9a f6 ff ff       	call   f010131c <page_alloc>
f0101c82:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101c85:	83 c4 10             	add    $0x10,%esp
f0101c88:	85 c0                	test   %eax,%eax
f0101c8a:	75 19                	jne    f0101ca5 <mem_init+0x5f4>
f0101c8c:	68 11 71 10 f0       	push   $0xf0107111
f0101c91:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101c96:	68 a8 03 00 00       	push   $0x3a8
f0101c9b:	68 78 6f 10 f0       	push   $0xf0106f78
f0101ca0:	e8 ef e3 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101ca5:	83 ec 0c             	sub    $0xc,%esp
f0101ca8:	6a 00                	push   $0x0
f0101caa:	e8 6d f6 ff ff       	call   f010131c <page_alloc>
f0101caf:	89 c3                	mov    %eax,%ebx
f0101cb1:	83 c4 10             	add    $0x10,%esp
f0101cb4:	85 c0                	test   %eax,%eax
f0101cb6:	75 19                	jne    f0101cd1 <mem_init+0x620>
f0101cb8:	68 27 71 10 f0       	push   $0xf0107127
f0101cbd:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101cc2:	68 a9 03 00 00       	push   $0x3a9
f0101cc7:	68 78 6f 10 f0       	push   $0xf0106f78
f0101ccc:	e8 c3 e3 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101cd1:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101cd4:	75 19                	jne    f0101cef <mem_init+0x63e>
f0101cd6:	68 3d 71 10 f0       	push   $0xf010713d
f0101cdb:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101ce0:	68 ac 03 00 00       	push   $0x3ac
f0101ce5:	68 78 6f 10 f0       	push   $0xf0106f78
f0101cea:	e8 a5 e3 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101cef:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101cf2:	74 04                	je     f0101cf8 <mem_init+0x647>
f0101cf4:	39 c6                	cmp    %eax,%esi
f0101cf6:	75 19                	jne    f0101d11 <mem_init+0x660>
f0101cf8:	68 cc 74 10 f0       	push   $0xf01074cc
f0101cfd:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101d02:	68 ad 03 00 00       	push   $0x3ad
f0101d07:	68 78 6f 10 f0       	push   $0xf0106f78
f0101d0c:	e8 83 e3 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101d11:	a1 40 72 22 f0       	mov    0xf0227240,%eax
f0101d16:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101d19:	c7 05 40 72 22 f0 00 	movl   $0x0,0xf0227240
f0101d20:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101d23:	83 ec 0c             	sub    $0xc,%esp
f0101d26:	6a 00                	push   $0x0
f0101d28:	e8 ef f5 ff ff       	call   f010131c <page_alloc>
f0101d2d:	83 c4 10             	add    $0x10,%esp
f0101d30:	85 c0                	test   %eax,%eax
f0101d32:	74 19                	je     f0101d4d <mem_init+0x69c>
f0101d34:	68 a6 71 10 f0       	push   $0xf01071a6
f0101d39:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101d3e:	68 b4 03 00 00       	push   $0x3b4
f0101d43:	68 78 6f 10 f0       	push   $0xf0106f78
f0101d48:	e8 47 e3 ff ff       	call   f0100094 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101d4d:	83 ec 04             	sub    $0x4,%esp
f0101d50:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101d53:	50                   	push   %eax
f0101d54:	6a 00                	push   $0x0
f0101d56:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f0101d5c:	e8 94 f7 ff ff       	call   f01014f5 <page_lookup>
f0101d61:	83 c4 10             	add    $0x10,%esp
f0101d64:	85 c0                	test   %eax,%eax
f0101d66:	74 19                	je     f0101d81 <mem_init+0x6d0>
f0101d68:	68 0c 75 10 f0       	push   $0xf010750c
f0101d6d:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101d72:	68 b7 03 00 00       	push   $0x3b7
f0101d77:	68 78 6f 10 f0       	push   $0xf0106f78
f0101d7c:	e8 13 e3 ff ff       	call   f0100094 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101d81:	6a 02                	push   $0x2
f0101d83:	6a 00                	push   $0x0
f0101d85:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d88:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f0101d8e:	e8 4b f8 ff ff       	call   f01015de <page_insert>
f0101d93:	83 c4 10             	add    $0x10,%esp
f0101d96:	85 c0                	test   %eax,%eax
f0101d98:	78 19                	js     f0101db3 <mem_init+0x702>
f0101d9a:	68 44 75 10 f0       	push   $0xf0107544
f0101d9f:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101da4:	68 ba 03 00 00       	push   $0x3ba
f0101da9:	68 78 6f 10 f0       	push   $0xf0106f78
f0101dae:	e8 e1 e2 ff ff       	call   f0100094 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101db3:	83 ec 0c             	sub    $0xc,%esp
f0101db6:	56                   	push   %esi
f0101db7:	e8 ca f5 ff ff       	call   f0101386 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101dbc:	6a 02                	push   $0x2
f0101dbe:	6a 00                	push   $0x0
f0101dc0:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101dc3:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f0101dc9:	e8 10 f8 ff ff       	call   f01015de <page_insert>
f0101dce:	83 c4 20             	add    $0x20,%esp
f0101dd1:	85 c0                	test   %eax,%eax
f0101dd3:	74 19                	je     f0101dee <mem_init+0x73d>
f0101dd5:	68 74 75 10 f0       	push   $0xf0107574
f0101dda:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101ddf:	68 be 03 00 00       	push   $0x3be
f0101de4:	68 78 6f 10 f0       	push   $0xf0106f78
f0101de9:	e8 a6 e2 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101dee:	8b 3d 94 7e 22 f0    	mov    0xf0227e94,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101df4:	a1 98 7e 22 f0       	mov    0xf0227e98,%eax
f0101df9:	89 c1                	mov    %eax,%ecx
f0101dfb:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101dfe:	8b 17                	mov    (%edi),%edx
f0101e00:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101e06:	89 f0                	mov    %esi,%eax
f0101e08:	29 c8                	sub    %ecx,%eax
f0101e0a:	c1 f8 03             	sar    $0x3,%eax
f0101e0d:	c1 e0 0c             	shl    $0xc,%eax
f0101e10:	39 c2                	cmp    %eax,%edx
f0101e12:	74 19                	je     f0101e2d <mem_init+0x77c>
f0101e14:	68 a4 75 10 f0       	push   $0xf01075a4
f0101e19:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101e1e:	68 bf 03 00 00       	push   $0x3bf
f0101e23:	68 78 6f 10 f0       	push   $0xf0106f78
f0101e28:	e8 67 e2 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101e2d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e32:	89 f8                	mov    %edi,%eax
f0101e34:	e8 9d f0 ff ff       	call   f0100ed6 <check_va2pa>
f0101e39:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101e3c:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101e3f:	c1 fa 03             	sar    $0x3,%edx
f0101e42:	c1 e2 0c             	shl    $0xc,%edx
f0101e45:	39 d0                	cmp    %edx,%eax
f0101e47:	74 19                	je     f0101e62 <mem_init+0x7b1>
f0101e49:	68 cc 75 10 f0       	push   $0xf01075cc
f0101e4e:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101e53:	68 c0 03 00 00       	push   $0x3c0
f0101e58:	68 78 6f 10 f0       	push   $0xf0106f78
f0101e5d:	e8 32 e2 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0101e62:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e65:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e6a:	74 19                	je     f0101e85 <mem_init+0x7d4>
f0101e6c:	68 08 72 10 f0       	push   $0xf0107208
f0101e71:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101e76:	68 c1 03 00 00       	push   $0x3c1
f0101e7b:	68 78 6f 10 f0       	push   $0xf0106f78
f0101e80:	e8 0f e2 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0101e85:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e8a:	74 19                	je     f0101ea5 <mem_init+0x7f4>
f0101e8c:	68 19 72 10 f0       	push   $0xf0107219
f0101e91:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101e96:	68 c2 03 00 00       	push   $0x3c2
f0101e9b:	68 78 6f 10 f0       	push   $0xf0106f78
f0101ea0:	e8 ef e1 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ea5:	6a 02                	push   $0x2
f0101ea7:	68 00 10 00 00       	push   $0x1000
f0101eac:	53                   	push   %ebx
f0101ead:	57                   	push   %edi
f0101eae:	e8 2b f7 ff ff       	call   f01015de <page_insert>
f0101eb3:	83 c4 10             	add    $0x10,%esp
f0101eb6:	85 c0                	test   %eax,%eax
f0101eb8:	74 19                	je     f0101ed3 <mem_init+0x822>
f0101eba:	68 fc 75 10 f0       	push   $0xf01075fc
f0101ebf:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101ec4:	68 c5 03 00 00       	push   $0x3c5
f0101ec9:	68 78 6f 10 f0       	push   $0xf0106f78
f0101ece:	e8 c1 e1 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ed3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ed8:	a1 94 7e 22 f0       	mov    0xf0227e94,%eax
f0101edd:	e8 f4 ef ff ff       	call   f0100ed6 <check_va2pa>
f0101ee2:	89 da                	mov    %ebx,%edx
f0101ee4:	2b 15 98 7e 22 f0    	sub    0xf0227e98,%edx
f0101eea:	c1 fa 03             	sar    $0x3,%edx
f0101eed:	c1 e2 0c             	shl    $0xc,%edx
f0101ef0:	39 d0                	cmp    %edx,%eax
f0101ef2:	74 19                	je     f0101f0d <mem_init+0x85c>
f0101ef4:	68 38 76 10 f0       	push   $0xf0107638
f0101ef9:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101efe:	68 c6 03 00 00       	push   $0x3c6
f0101f03:	68 78 6f 10 f0       	push   $0xf0106f78
f0101f08:	e8 87 e1 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101f0d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f12:	74 19                	je     f0101f2d <mem_init+0x87c>
f0101f14:	68 2a 72 10 f0       	push   $0xf010722a
f0101f19:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101f1e:	68 c7 03 00 00       	push   $0x3c7
f0101f23:	68 78 6f 10 f0       	push   $0xf0106f78
f0101f28:	e8 67 e1 ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101f2d:	83 ec 0c             	sub    $0xc,%esp
f0101f30:	6a 00                	push   $0x0
f0101f32:	e8 e5 f3 ff ff       	call   f010131c <page_alloc>
f0101f37:	83 c4 10             	add    $0x10,%esp
f0101f3a:	85 c0                	test   %eax,%eax
f0101f3c:	74 19                	je     f0101f57 <mem_init+0x8a6>
f0101f3e:	68 a6 71 10 f0       	push   $0xf01071a6
f0101f43:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101f48:	68 ca 03 00 00       	push   $0x3ca
f0101f4d:	68 78 6f 10 f0       	push   $0xf0106f78
f0101f52:	e8 3d e1 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f57:	6a 02                	push   $0x2
f0101f59:	68 00 10 00 00       	push   $0x1000
f0101f5e:	53                   	push   %ebx
f0101f5f:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f0101f65:	e8 74 f6 ff ff       	call   f01015de <page_insert>
f0101f6a:	83 c4 10             	add    $0x10,%esp
f0101f6d:	85 c0                	test   %eax,%eax
f0101f6f:	74 19                	je     f0101f8a <mem_init+0x8d9>
f0101f71:	68 fc 75 10 f0       	push   $0xf01075fc
f0101f76:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101f7b:	68 cd 03 00 00       	push   $0x3cd
f0101f80:	68 78 6f 10 f0       	push   $0xf0106f78
f0101f85:	e8 0a e1 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f8a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f8f:	a1 94 7e 22 f0       	mov    0xf0227e94,%eax
f0101f94:	e8 3d ef ff ff       	call   f0100ed6 <check_va2pa>
f0101f99:	89 da                	mov    %ebx,%edx
f0101f9b:	2b 15 98 7e 22 f0    	sub    0xf0227e98,%edx
f0101fa1:	c1 fa 03             	sar    $0x3,%edx
f0101fa4:	c1 e2 0c             	shl    $0xc,%edx
f0101fa7:	39 d0                	cmp    %edx,%eax
f0101fa9:	74 19                	je     f0101fc4 <mem_init+0x913>
f0101fab:	68 38 76 10 f0       	push   $0xf0107638
f0101fb0:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101fb5:	68 ce 03 00 00       	push   $0x3ce
f0101fba:	68 78 6f 10 f0       	push   $0xf0106f78
f0101fbf:	e8 d0 e0 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101fc4:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101fc9:	74 19                	je     f0101fe4 <mem_init+0x933>
f0101fcb:	68 2a 72 10 f0       	push   $0xf010722a
f0101fd0:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101fd5:	68 cf 03 00 00       	push   $0x3cf
f0101fda:	68 78 6f 10 f0       	push   $0xf0106f78
f0101fdf:	e8 b0 e0 ff ff       	call   f0100094 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101fe4:	83 ec 0c             	sub    $0xc,%esp
f0101fe7:	6a 00                	push   $0x0
f0101fe9:	e8 2e f3 ff ff       	call   f010131c <page_alloc>
f0101fee:	83 c4 10             	add    $0x10,%esp
f0101ff1:	85 c0                	test   %eax,%eax
f0101ff3:	74 19                	je     f010200e <mem_init+0x95d>
f0101ff5:	68 a6 71 10 f0       	push   $0xf01071a6
f0101ffa:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0101fff:	68 d3 03 00 00       	push   $0x3d3
f0102004:	68 78 6f 10 f0       	push   $0xf0106f78
f0102009:	e8 86 e0 ff ff       	call   f0100094 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010200e:	8b 15 94 7e 22 f0    	mov    0xf0227e94,%edx
f0102014:	8b 02                	mov    (%edx),%eax
f0102016:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010201b:	89 c1                	mov    %eax,%ecx
f010201d:	c1 e9 0c             	shr    $0xc,%ecx
f0102020:	3b 0d 90 7e 22 f0    	cmp    0xf0227e90,%ecx
f0102026:	72 15                	jb     f010203d <mem_init+0x98c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102028:	50                   	push   %eax
f0102029:	68 5c 68 10 f0       	push   $0xf010685c
f010202e:	68 d6 03 00 00       	push   $0x3d6
f0102033:	68 78 6f 10 f0       	push   $0xf0106f78
f0102038:	e8 57 e0 ff ff       	call   f0100094 <_panic>
f010203d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102045:	83 ec 04             	sub    $0x4,%esp
f0102048:	6a 00                	push   $0x0
f010204a:	68 00 10 00 00       	push   $0x1000
f010204f:	52                   	push   %edx
f0102050:	e8 67 f3 ff ff       	call   f01013bc <pgdir_walk>
f0102055:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102058:	8d 51 04             	lea    0x4(%ecx),%edx
f010205b:	83 c4 10             	add    $0x10,%esp
f010205e:	39 d0                	cmp    %edx,%eax
f0102060:	74 19                	je     f010207b <mem_init+0x9ca>
f0102062:	68 68 76 10 f0       	push   $0xf0107668
f0102067:	68 9e 6f 10 f0       	push   $0xf0106f9e
f010206c:	68 d7 03 00 00       	push   $0x3d7
f0102071:	68 78 6f 10 f0       	push   $0xf0106f78
f0102076:	e8 19 e0 ff ff       	call   f0100094 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010207b:	6a 06                	push   $0x6
f010207d:	68 00 10 00 00       	push   $0x1000
f0102082:	53                   	push   %ebx
f0102083:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f0102089:	e8 50 f5 ff ff       	call   f01015de <page_insert>
f010208e:	83 c4 10             	add    $0x10,%esp
f0102091:	85 c0                	test   %eax,%eax
f0102093:	74 19                	je     f01020ae <mem_init+0x9fd>
f0102095:	68 a8 76 10 f0       	push   $0xf01076a8
f010209a:	68 9e 6f 10 f0       	push   $0xf0106f9e
f010209f:	68 da 03 00 00       	push   $0x3da
f01020a4:	68 78 6f 10 f0       	push   $0xf0106f78
f01020a9:	e8 e6 df ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01020ae:	8b 3d 94 7e 22 f0    	mov    0xf0227e94,%edi
f01020b4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020b9:	89 f8                	mov    %edi,%eax
f01020bb:	e8 16 ee ff ff       	call   f0100ed6 <check_va2pa>
f01020c0:	89 da                	mov    %ebx,%edx
f01020c2:	2b 15 98 7e 22 f0    	sub    0xf0227e98,%edx
f01020c8:	c1 fa 03             	sar    $0x3,%edx
f01020cb:	c1 e2 0c             	shl    $0xc,%edx
f01020ce:	39 d0                	cmp    %edx,%eax
f01020d0:	74 19                	je     f01020eb <mem_init+0xa3a>
f01020d2:	68 38 76 10 f0       	push   $0xf0107638
f01020d7:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01020dc:	68 db 03 00 00       	push   $0x3db
f01020e1:	68 78 6f 10 f0       	push   $0xf0106f78
f01020e6:	e8 a9 df ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01020eb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01020f0:	74 19                	je     f010210b <mem_init+0xa5a>
f01020f2:	68 2a 72 10 f0       	push   $0xf010722a
f01020f7:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01020fc:	68 dc 03 00 00       	push   $0x3dc
f0102101:	68 78 6f 10 f0       	push   $0xf0106f78
f0102106:	e8 89 df ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010210b:	83 ec 04             	sub    $0x4,%esp
f010210e:	6a 00                	push   $0x0
f0102110:	68 00 10 00 00       	push   $0x1000
f0102115:	57                   	push   %edi
f0102116:	e8 a1 f2 ff ff       	call   f01013bc <pgdir_walk>
f010211b:	83 c4 10             	add    $0x10,%esp
f010211e:	f6 00 04             	testb  $0x4,(%eax)
f0102121:	75 19                	jne    f010213c <mem_init+0xa8b>
f0102123:	68 e8 76 10 f0       	push   $0xf01076e8
f0102128:	68 9e 6f 10 f0       	push   $0xf0106f9e
f010212d:	68 dd 03 00 00       	push   $0x3dd
f0102132:	68 78 6f 10 f0       	push   $0xf0106f78
f0102137:	e8 58 df ff ff       	call   f0100094 <_panic>
	cprintf("pp2 %x\n", pp2);
f010213c:	83 ec 08             	sub    $0x8,%esp
f010213f:	53                   	push   %ebx
f0102140:	68 3b 72 10 f0       	push   $0xf010723b
f0102145:	e8 66 19 00 00       	call   f0103ab0 <cprintf>
	cprintf("kern_pgdir %x\n", kern_pgdir);
f010214a:	83 c4 08             	add    $0x8,%esp
f010214d:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f0102153:	68 43 72 10 f0       	push   $0xf0107243
f0102158:	e8 53 19 00 00       	call   f0103ab0 <cprintf>
	cprintf("kern_pgdir[0] is %x\n", kern_pgdir[0]);
f010215d:	83 c4 08             	add    $0x8,%esp
f0102160:	a1 94 7e 22 f0       	mov    0xf0227e94,%eax
f0102165:	ff 30                	pushl  (%eax)
f0102167:	68 52 72 10 f0       	push   $0xf0107252
f010216c:	e8 3f 19 00 00       	call   f0103ab0 <cprintf>
	assert(kern_pgdir[0] & PTE_U);
f0102171:	a1 94 7e 22 f0       	mov    0xf0227e94,%eax
f0102176:	83 c4 10             	add    $0x10,%esp
f0102179:	f6 00 04             	testb  $0x4,(%eax)
f010217c:	75 19                	jne    f0102197 <mem_init+0xae6>
f010217e:	68 67 72 10 f0       	push   $0xf0107267
f0102183:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102188:	68 e1 03 00 00       	push   $0x3e1
f010218d:	68 78 6f 10 f0       	push   $0xf0106f78
f0102192:	e8 fd de ff ff       	call   f0100094 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102197:	6a 02                	push   $0x2
f0102199:	68 00 10 00 00       	push   $0x1000
f010219e:	53                   	push   %ebx
f010219f:	50                   	push   %eax
f01021a0:	e8 39 f4 ff ff       	call   f01015de <page_insert>
f01021a5:	83 c4 10             	add    $0x10,%esp
f01021a8:	85 c0                	test   %eax,%eax
f01021aa:	74 19                	je     f01021c5 <mem_init+0xb14>
f01021ac:	68 fc 75 10 f0       	push   $0xf01075fc
f01021b1:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01021b6:	68 e4 03 00 00       	push   $0x3e4
f01021bb:	68 78 6f 10 f0       	push   $0xf0106f78
f01021c0:	e8 cf de ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01021c5:	83 ec 04             	sub    $0x4,%esp
f01021c8:	6a 00                	push   $0x0
f01021ca:	68 00 10 00 00       	push   $0x1000
f01021cf:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f01021d5:	e8 e2 f1 ff ff       	call   f01013bc <pgdir_walk>
f01021da:	83 c4 10             	add    $0x10,%esp
f01021dd:	f6 00 02             	testb  $0x2,(%eax)
f01021e0:	75 19                	jne    f01021fb <mem_init+0xb4a>
f01021e2:	68 1c 77 10 f0       	push   $0xf010771c
f01021e7:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01021ec:	68 e5 03 00 00       	push   $0x3e5
f01021f1:	68 78 6f 10 f0       	push   $0xf0106f78
f01021f6:	e8 99 de ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01021fb:	83 ec 04             	sub    $0x4,%esp
f01021fe:	6a 00                	push   $0x0
f0102200:	68 00 10 00 00       	push   $0x1000
f0102205:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f010220b:	e8 ac f1 ff ff       	call   f01013bc <pgdir_walk>
f0102210:	83 c4 10             	add    $0x10,%esp
f0102213:	f6 00 04             	testb  $0x4,(%eax)
f0102216:	74 19                	je     f0102231 <mem_init+0xb80>
f0102218:	68 50 77 10 f0       	push   $0xf0107750
f010221d:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102222:	68 e6 03 00 00       	push   $0x3e6
f0102227:	68 78 6f 10 f0       	push   $0xf0106f78
f010222c:	e8 63 de ff ff       	call   f0100094 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102231:	6a 02                	push   $0x2
f0102233:	68 00 00 40 00       	push   $0x400000
f0102238:	56                   	push   %esi
f0102239:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f010223f:	e8 9a f3 ff ff       	call   f01015de <page_insert>
f0102244:	83 c4 10             	add    $0x10,%esp
f0102247:	85 c0                	test   %eax,%eax
f0102249:	78 19                	js     f0102264 <mem_init+0xbb3>
f010224b:	68 88 77 10 f0       	push   $0xf0107788
f0102250:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102255:	68 e9 03 00 00       	push   $0x3e9
f010225a:	68 78 6f 10 f0       	push   $0xf0106f78
f010225f:	e8 30 de ff ff       	call   f0100094 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102264:	6a 02                	push   $0x2
f0102266:	68 00 10 00 00       	push   $0x1000
f010226b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010226e:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f0102274:	e8 65 f3 ff ff       	call   f01015de <page_insert>
f0102279:	83 c4 10             	add    $0x10,%esp
f010227c:	85 c0                	test   %eax,%eax
f010227e:	74 19                	je     f0102299 <mem_init+0xbe8>
f0102280:	68 c0 77 10 f0       	push   $0xf01077c0
f0102285:	68 9e 6f 10 f0       	push   $0xf0106f9e
f010228a:	68 ec 03 00 00       	push   $0x3ec
f010228f:	68 78 6f 10 f0       	push   $0xf0106f78
f0102294:	e8 fb dd ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102299:	83 ec 04             	sub    $0x4,%esp
f010229c:	6a 00                	push   $0x0
f010229e:	68 00 10 00 00       	push   $0x1000
f01022a3:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f01022a9:	e8 0e f1 ff ff       	call   f01013bc <pgdir_walk>
f01022ae:	83 c4 10             	add    $0x10,%esp
f01022b1:	f6 00 04             	testb  $0x4,(%eax)
f01022b4:	74 19                	je     f01022cf <mem_init+0xc1e>
f01022b6:	68 50 77 10 f0       	push   $0xf0107750
f01022bb:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01022c0:	68 ed 03 00 00       	push   $0x3ed
f01022c5:	68 78 6f 10 f0       	push   $0xf0106f78
f01022ca:	e8 c5 dd ff ff       	call   f0100094 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01022cf:	8b 3d 94 7e 22 f0    	mov    0xf0227e94,%edi
f01022d5:	ba 00 00 00 00       	mov    $0x0,%edx
f01022da:	89 f8                	mov    %edi,%eax
f01022dc:	e8 f5 eb ff ff       	call   f0100ed6 <check_va2pa>
f01022e1:	89 c1                	mov    %eax,%ecx
f01022e3:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01022e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022e9:	2b 05 98 7e 22 f0    	sub    0xf0227e98,%eax
f01022ef:	c1 f8 03             	sar    $0x3,%eax
f01022f2:	c1 e0 0c             	shl    $0xc,%eax
f01022f5:	39 c1                	cmp    %eax,%ecx
f01022f7:	74 19                	je     f0102312 <mem_init+0xc61>
f01022f9:	68 fc 77 10 f0       	push   $0xf01077fc
f01022fe:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102303:	68 f0 03 00 00       	push   $0x3f0
f0102308:	68 78 6f 10 f0       	push   $0xf0106f78
f010230d:	e8 82 dd ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102312:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102317:	89 f8                	mov    %edi,%eax
f0102319:	e8 b8 eb ff ff       	call   f0100ed6 <check_va2pa>
f010231e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102321:	74 19                	je     f010233c <mem_init+0xc8b>
f0102323:	68 28 78 10 f0       	push   $0xf0107828
f0102328:	68 9e 6f 10 f0       	push   $0xf0106f9e
f010232d:	68 f1 03 00 00       	push   $0x3f1
f0102332:	68 78 6f 10 f0       	push   $0xf0106f78
f0102337:	e8 58 dd ff ff       	call   f0100094 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010233c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010233f:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f0102344:	74 19                	je     f010235f <mem_init+0xcae>
f0102346:	68 7d 72 10 f0       	push   $0xf010727d
f010234b:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102350:	68 f3 03 00 00       	push   $0x3f3
f0102355:	68 78 6f 10 f0       	push   $0xf0106f78
f010235a:	e8 35 dd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f010235f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102364:	74 19                	je     f010237f <mem_init+0xcce>
f0102366:	68 8e 72 10 f0       	push   $0xf010728e
f010236b:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102370:	68 f4 03 00 00       	push   $0x3f4
f0102375:	68 78 6f 10 f0       	push   $0xf0106f78
f010237a:	e8 15 dd ff ff       	call   f0100094 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010237f:	83 ec 0c             	sub    $0xc,%esp
f0102382:	6a 00                	push   $0x0
f0102384:	e8 93 ef ff ff       	call   f010131c <page_alloc>
f0102389:	83 c4 10             	add    $0x10,%esp
f010238c:	85 c0                	test   %eax,%eax
f010238e:	74 04                	je     f0102394 <mem_init+0xce3>
f0102390:	39 c3                	cmp    %eax,%ebx
f0102392:	74 19                	je     f01023ad <mem_init+0xcfc>
f0102394:	68 58 78 10 f0       	push   $0xf0107858
f0102399:	68 9e 6f 10 f0       	push   $0xf0106f9e
f010239e:	68 f7 03 00 00       	push   $0x3f7
f01023a3:	68 78 6f 10 f0       	push   $0xf0106f78
f01023a8:	e8 e7 dc ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01023ad:	83 ec 08             	sub    $0x8,%esp
f01023b0:	6a 00                	push   $0x0
f01023b2:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f01023b8:	e8 d3 f1 ff ff       	call   f0101590 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01023bd:	8b 3d 94 7e 22 f0    	mov    0xf0227e94,%edi
f01023c3:	ba 00 00 00 00       	mov    $0x0,%edx
f01023c8:	89 f8                	mov    %edi,%eax
f01023ca:	e8 07 eb ff ff       	call   f0100ed6 <check_va2pa>
f01023cf:	83 c4 10             	add    $0x10,%esp
f01023d2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01023d5:	74 19                	je     f01023f0 <mem_init+0xd3f>
f01023d7:	68 7c 78 10 f0       	push   $0xf010787c
f01023dc:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01023e1:	68 fb 03 00 00       	push   $0x3fb
f01023e6:	68 78 6f 10 f0       	push   $0xf0106f78
f01023eb:	e8 a4 dc ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01023f0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023f5:	89 f8                	mov    %edi,%eax
f01023f7:	e8 da ea ff ff       	call   f0100ed6 <check_va2pa>
f01023fc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01023ff:	2b 15 98 7e 22 f0    	sub    0xf0227e98,%edx
f0102405:	c1 fa 03             	sar    $0x3,%edx
f0102408:	c1 e2 0c             	shl    $0xc,%edx
f010240b:	39 d0                	cmp    %edx,%eax
f010240d:	74 19                	je     f0102428 <mem_init+0xd77>
f010240f:	68 28 78 10 f0       	push   $0xf0107828
f0102414:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102419:	68 fc 03 00 00       	push   $0x3fc
f010241e:	68 78 6f 10 f0       	push   $0xf0106f78
f0102423:	e8 6c dc ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102428:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010242b:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102430:	74 19                	je     f010244b <mem_init+0xd9a>
f0102432:	68 08 72 10 f0       	push   $0xf0107208
f0102437:	68 9e 6f 10 f0       	push   $0xf0106f9e
f010243c:	68 fd 03 00 00       	push   $0x3fd
f0102441:	68 78 6f 10 f0       	push   $0xf0106f78
f0102446:	e8 49 dc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f010244b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102450:	74 19                	je     f010246b <mem_init+0xdba>
f0102452:	68 8e 72 10 f0       	push   $0xf010728e
f0102457:	68 9e 6f 10 f0       	push   $0xf0106f9e
f010245c:	68 fe 03 00 00       	push   $0x3fe
f0102461:	68 78 6f 10 f0       	push   $0xf0106f78
f0102466:	e8 29 dc ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010246b:	83 ec 08             	sub    $0x8,%esp
f010246e:	68 00 10 00 00       	push   $0x1000
f0102473:	57                   	push   %edi
f0102474:	e8 17 f1 ff ff       	call   f0101590 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102479:	8b 3d 94 7e 22 f0    	mov    0xf0227e94,%edi
f010247f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102484:	89 f8                	mov    %edi,%eax
f0102486:	e8 4b ea ff ff       	call   f0100ed6 <check_va2pa>
f010248b:	83 c4 10             	add    $0x10,%esp
f010248e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102491:	74 19                	je     f01024ac <mem_init+0xdfb>
f0102493:	68 7c 78 10 f0       	push   $0xf010787c
f0102498:	68 9e 6f 10 f0       	push   $0xf0106f9e
f010249d:	68 02 04 00 00       	push   $0x402
f01024a2:	68 78 6f 10 f0       	push   $0xf0106f78
f01024a7:	e8 e8 db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01024ac:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024b1:	89 f8                	mov    %edi,%eax
f01024b3:	e8 1e ea ff ff       	call   f0100ed6 <check_va2pa>
f01024b8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024bb:	74 19                	je     f01024d6 <mem_init+0xe25>
f01024bd:	68 a0 78 10 f0       	push   $0xf01078a0
f01024c2:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01024c7:	68 03 04 00 00       	push   $0x403
f01024cc:	68 78 6f 10 f0       	push   $0xf0106f78
f01024d1:	e8 be db ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f01024d6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024d9:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01024de:	74 19                	je     f01024f9 <mem_init+0xe48>
f01024e0:	68 9f 72 10 f0       	push   $0xf010729f
f01024e5:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01024ea:	68 04 04 00 00       	push   $0x404
f01024ef:	68 78 6f 10 f0       	push   $0xf0106f78
f01024f4:	e8 9b db ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01024f9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01024fe:	74 19                	je     f0102519 <mem_init+0xe68>
f0102500:	68 8e 72 10 f0       	push   $0xf010728e
f0102505:	68 9e 6f 10 f0       	push   $0xf0106f9e
f010250a:	68 05 04 00 00       	push   $0x405
f010250f:	68 78 6f 10 f0       	push   $0xf0106f78
f0102514:	e8 7b db ff ff       	call   f0100094 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102519:	83 ec 0c             	sub    $0xc,%esp
f010251c:	6a 00                	push   $0x0
f010251e:	e8 f9 ed ff ff       	call   f010131c <page_alloc>
f0102523:	83 c4 10             	add    $0x10,%esp
f0102526:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0102529:	75 04                	jne    f010252f <mem_init+0xe7e>
f010252b:	85 c0                	test   %eax,%eax
f010252d:	75 19                	jne    f0102548 <mem_init+0xe97>
f010252f:	68 c8 78 10 f0       	push   $0xf01078c8
f0102534:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102539:	68 08 04 00 00       	push   $0x408
f010253e:	68 78 6f 10 f0       	push   $0xf0106f78
f0102543:	e8 4c db ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102548:	83 ec 0c             	sub    $0xc,%esp
f010254b:	6a 00                	push   $0x0
f010254d:	e8 ca ed ff ff       	call   f010131c <page_alloc>
f0102552:	83 c4 10             	add    $0x10,%esp
f0102555:	85 c0                	test   %eax,%eax
f0102557:	74 19                	je     f0102572 <mem_init+0xec1>
f0102559:	68 a6 71 10 f0       	push   $0xf01071a6
f010255e:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102563:	68 0b 04 00 00       	push   $0x40b
f0102568:	68 78 6f 10 f0       	push   $0xf0106f78
f010256d:	e8 22 db ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102572:	8b 0d 94 7e 22 f0    	mov    0xf0227e94,%ecx
f0102578:	8b 11                	mov    (%ecx),%edx
f010257a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102580:	89 f0                	mov    %esi,%eax
f0102582:	2b 05 98 7e 22 f0    	sub    0xf0227e98,%eax
f0102588:	c1 f8 03             	sar    $0x3,%eax
f010258b:	c1 e0 0c             	shl    $0xc,%eax
f010258e:	39 c2                	cmp    %eax,%edx
f0102590:	74 19                	je     f01025ab <mem_init+0xefa>
f0102592:	68 a4 75 10 f0       	push   $0xf01075a4
f0102597:	68 9e 6f 10 f0       	push   $0xf0106f9e
f010259c:	68 0e 04 00 00       	push   $0x40e
f01025a1:	68 78 6f 10 f0       	push   $0xf0106f78
f01025a6:	e8 e9 da ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f01025ab:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01025b1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01025b6:	74 19                	je     f01025d1 <mem_init+0xf20>
f01025b8:	68 19 72 10 f0       	push   $0xf0107219
f01025bd:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01025c2:	68 10 04 00 00       	push   $0x410
f01025c7:	68 78 6f 10 f0       	push   $0xf0106f78
f01025cc:	e8 c3 da ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f01025d1:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01025d7:	83 ec 0c             	sub    $0xc,%esp
f01025da:	56                   	push   %esi
f01025db:	e8 a6 ed ff ff       	call   f0101386 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01025e0:	83 c4 0c             	add    $0xc,%esp
f01025e3:	6a 01                	push   $0x1
f01025e5:	68 00 10 40 00       	push   $0x401000
f01025ea:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f01025f0:	e8 c7 ed ff ff       	call   f01013bc <pgdir_walk>
f01025f5:	89 c7                	mov    %eax,%edi
f01025f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01025fa:	a1 94 7e 22 f0       	mov    0xf0227e94,%eax
f01025ff:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102602:	8b 40 04             	mov    0x4(%eax),%eax
f0102605:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010260a:	8b 0d 90 7e 22 f0    	mov    0xf0227e90,%ecx
f0102610:	89 c2                	mov    %eax,%edx
f0102612:	c1 ea 0c             	shr    $0xc,%edx
f0102615:	83 c4 10             	add    $0x10,%esp
f0102618:	39 ca                	cmp    %ecx,%edx
f010261a:	72 15                	jb     f0102631 <mem_init+0xf80>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010261c:	50                   	push   %eax
f010261d:	68 5c 68 10 f0       	push   $0xf010685c
f0102622:	68 17 04 00 00       	push   $0x417
f0102627:	68 78 6f 10 f0       	push   $0xf0106f78
f010262c:	e8 63 da ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102631:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102636:	39 c7                	cmp    %eax,%edi
f0102638:	74 19                	je     f0102653 <mem_init+0xfa2>
f010263a:	68 b0 72 10 f0       	push   $0xf01072b0
f010263f:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102644:	68 18 04 00 00       	push   $0x418
f0102649:	68 78 6f 10 f0       	push   $0xf0106f78
f010264e:	e8 41 da ff ff       	call   f0100094 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102653:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102656:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f010265d:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102663:	89 f0                	mov    %esi,%eax
f0102665:	2b 05 98 7e 22 f0    	sub    0xf0227e98,%eax
f010266b:	c1 f8 03             	sar    $0x3,%eax
f010266e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102671:	89 c2                	mov    %eax,%edx
f0102673:	c1 ea 0c             	shr    $0xc,%edx
f0102676:	39 d1                	cmp    %edx,%ecx
f0102678:	77 12                	ja     f010268c <mem_init+0xfdb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010267a:	50                   	push   %eax
f010267b:	68 5c 68 10 f0       	push   $0xf010685c
f0102680:	6a 58                	push   $0x58
f0102682:	68 84 6f 10 f0       	push   $0xf0106f84
f0102687:	e8 08 da ff ff       	call   f0100094 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010268c:	83 ec 04             	sub    $0x4,%esp
f010268f:	68 00 10 00 00       	push   $0x1000
f0102694:	68 ff 00 00 00       	push   $0xff
f0102699:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010269e:	50                   	push   %eax
f010269f:	e8 b8 33 00 00       	call   f0105a5c <memset>
	page_free(pp0);
f01026a4:	89 34 24             	mov    %esi,(%esp)
f01026a7:	e8 da ec ff ff       	call   f0101386 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01026ac:	83 c4 0c             	add    $0xc,%esp
f01026af:	6a 01                	push   $0x1
f01026b1:	6a 00                	push   $0x0
f01026b3:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f01026b9:	e8 fe ec ff ff       	call   f01013bc <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01026be:	89 f2                	mov    %esi,%edx
f01026c0:	2b 15 98 7e 22 f0    	sub    0xf0227e98,%edx
f01026c6:	c1 fa 03             	sar    $0x3,%edx
f01026c9:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026cc:	89 d0                	mov    %edx,%eax
f01026ce:	c1 e8 0c             	shr    $0xc,%eax
f01026d1:	83 c4 10             	add    $0x10,%esp
f01026d4:	3b 05 90 7e 22 f0    	cmp    0xf0227e90,%eax
f01026da:	72 12                	jb     f01026ee <mem_init+0x103d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026dc:	52                   	push   %edx
f01026dd:	68 5c 68 10 f0       	push   $0xf010685c
f01026e2:	6a 58                	push   $0x58
f01026e4:	68 84 6f 10 f0       	push   $0xf0106f84
f01026e9:	e8 a6 d9 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f01026ee:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01026f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01026f7:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01026fd:	f6 00 01             	testb  $0x1,(%eax)
f0102700:	74 19                	je     f010271b <mem_init+0x106a>
f0102702:	68 c8 72 10 f0       	push   $0xf01072c8
f0102707:	68 9e 6f 10 f0       	push   $0xf0106f9e
f010270c:	68 22 04 00 00       	push   $0x422
f0102711:	68 78 6f 10 f0       	push   $0xf0106f78
f0102716:	e8 79 d9 ff ff       	call   f0100094 <_panic>
f010271b:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010271e:	39 c2                	cmp    %eax,%edx
f0102720:	75 db                	jne    f01026fd <mem_init+0x104c>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102722:	a1 94 7e 22 f0       	mov    0xf0227e94,%eax
f0102727:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010272d:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102733:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102736:	a3 40 72 22 f0       	mov    %eax,0xf0227240

	// free the pages we took
	page_free(pp0);
f010273b:	83 ec 0c             	sub    $0xc,%esp
f010273e:	56                   	push   %esi
f010273f:	e8 42 ec ff ff       	call   f0101386 <page_free>
	page_free(pp1);
f0102744:	83 c4 04             	add    $0x4,%esp
f0102747:	ff 75 d4             	pushl  -0x2c(%ebp)
f010274a:	e8 37 ec ff ff       	call   f0101386 <page_free>
	page_free(pp2);
f010274f:	89 1c 24             	mov    %ebx,(%esp)
f0102752:	e8 2f ec ff ff       	call   f0101386 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102757:	83 c4 08             	add    $0x8,%esp
f010275a:	68 01 10 00 00       	push   $0x1001
f010275f:	6a 00                	push   $0x0
f0102761:	e8 de ee ff ff       	call   f0101644 <mmio_map_region>
f0102766:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102768:	83 c4 08             	add    $0x8,%esp
f010276b:	68 00 10 00 00       	push   $0x1000
f0102770:	6a 00                	push   $0x0
f0102772:	e8 cd ee ff ff       	call   f0101644 <mmio_map_region>
f0102777:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102779:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f010277f:	83 c4 10             	add    $0x10,%esp
f0102782:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102788:	76 07                	jbe    f0102791 <mem_init+0x10e0>
f010278a:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010278f:	76 19                	jbe    f01027aa <mem_init+0x10f9>
f0102791:	68 ec 78 10 f0       	push   $0xf01078ec
f0102796:	68 9e 6f 10 f0       	push   $0xf0106f9e
f010279b:	68 32 04 00 00       	push   $0x432
f01027a0:	68 78 6f 10 f0       	push   $0xf0106f78
f01027a5:	e8 ea d8 ff ff       	call   f0100094 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01027aa:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01027b0:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01027b6:	77 08                	ja     f01027c0 <mem_init+0x110f>
f01027b8:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01027be:	77 19                	ja     f01027d9 <mem_init+0x1128>
f01027c0:	68 14 79 10 f0       	push   $0xf0107914
f01027c5:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01027ca:	68 33 04 00 00       	push   $0x433
f01027cf:	68 78 6f 10 f0       	push   $0xf0106f78
f01027d4:	e8 bb d8 ff ff       	call   f0100094 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01027d9:	89 da                	mov    %ebx,%edx
f01027db:	09 f2                	or     %esi,%edx
f01027dd:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01027e3:	74 19                	je     f01027fe <mem_init+0x114d>
f01027e5:	68 3c 79 10 f0       	push   $0xf010793c
f01027ea:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01027ef:	68 35 04 00 00       	push   $0x435
f01027f4:	68 78 6f 10 f0       	push   $0xf0106f78
f01027f9:	e8 96 d8 ff ff       	call   f0100094 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01027fe:	39 c6                	cmp    %eax,%esi
f0102800:	73 19                	jae    f010281b <mem_init+0x116a>
f0102802:	68 df 72 10 f0       	push   $0xf01072df
f0102807:	68 9e 6f 10 f0       	push   $0xf0106f9e
f010280c:	68 37 04 00 00       	push   $0x437
f0102811:	68 78 6f 10 f0       	push   $0xf0106f78
f0102816:	e8 79 d8 ff ff       	call   f0100094 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010281b:	8b 3d 94 7e 22 f0    	mov    0xf0227e94,%edi
f0102821:	89 da                	mov    %ebx,%edx
f0102823:	89 f8                	mov    %edi,%eax
f0102825:	e8 ac e6 ff ff       	call   f0100ed6 <check_va2pa>
f010282a:	85 c0                	test   %eax,%eax
f010282c:	74 19                	je     f0102847 <mem_init+0x1196>
f010282e:	68 64 79 10 f0       	push   $0xf0107964
f0102833:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102838:	68 39 04 00 00       	push   $0x439
f010283d:	68 78 6f 10 f0       	push   $0xf0106f78
f0102842:	e8 4d d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102847:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f010284d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102850:	89 c2                	mov    %eax,%edx
f0102852:	89 f8                	mov    %edi,%eax
f0102854:	e8 7d e6 ff ff       	call   f0100ed6 <check_va2pa>
f0102859:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010285e:	74 19                	je     f0102879 <mem_init+0x11c8>
f0102860:	68 88 79 10 f0       	push   $0xf0107988
f0102865:	68 9e 6f 10 f0       	push   $0xf0106f9e
f010286a:	68 3a 04 00 00       	push   $0x43a
f010286f:	68 78 6f 10 f0       	push   $0xf0106f78
f0102874:	e8 1b d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102879:	89 f2                	mov    %esi,%edx
f010287b:	89 f8                	mov    %edi,%eax
f010287d:	e8 54 e6 ff ff       	call   f0100ed6 <check_va2pa>
f0102882:	85 c0                	test   %eax,%eax
f0102884:	74 19                	je     f010289f <mem_init+0x11ee>
f0102886:	68 b8 79 10 f0       	push   $0xf01079b8
f010288b:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102890:	68 3b 04 00 00       	push   $0x43b
f0102895:	68 78 6f 10 f0       	push   $0xf0106f78
f010289a:	e8 f5 d7 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010289f:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01028a5:	89 f8                	mov    %edi,%eax
f01028a7:	e8 2a e6 ff ff       	call   f0100ed6 <check_va2pa>
f01028ac:	83 f8 ff             	cmp    $0xffffffff,%eax
f01028af:	74 19                	je     f01028ca <mem_init+0x1219>
f01028b1:	68 dc 79 10 f0       	push   $0xf01079dc
f01028b6:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01028bb:	68 3c 04 00 00       	push   $0x43c
f01028c0:	68 78 6f 10 f0       	push   $0xf0106f78
f01028c5:	e8 ca d7 ff ff       	call   f0100094 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01028ca:	83 ec 04             	sub    $0x4,%esp
f01028cd:	6a 00                	push   $0x0
f01028cf:	53                   	push   %ebx
f01028d0:	57                   	push   %edi
f01028d1:	e8 e6 ea ff ff       	call   f01013bc <pgdir_walk>
f01028d6:	83 c4 10             	add    $0x10,%esp
f01028d9:	f6 00 1a             	testb  $0x1a,(%eax)
f01028dc:	75 19                	jne    f01028f7 <mem_init+0x1246>
f01028de:	68 08 7a 10 f0       	push   $0xf0107a08
f01028e3:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01028e8:	68 3e 04 00 00       	push   $0x43e
f01028ed:	68 78 6f 10 f0       	push   $0xf0106f78
f01028f2:	e8 9d d7 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01028f7:	83 ec 04             	sub    $0x4,%esp
f01028fa:	6a 00                	push   $0x0
f01028fc:	53                   	push   %ebx
f01028fd:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f0102903:	e8 b4 ea ff ff       	call   f01013bc <pgdir_walk>
f0102908:	8b 00                	mov    (%eax),%eax
f010290a:	83 c4 10             	add    $0x10,%esp
f010290d:	83 e0 04             	and    $0x4,%eax
f0102910:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102913:	74 19                	je     f010292e <mem_init+0x127d>
f0102915:	68 4c 7a 10 f0       	push   $0xf0107a4c
f010291a:	68 9e 6f 10 f0       	push   $0xf0106f9e
f010291f:	68 3f 04 00 00       	push   $0x43f
f0102924:	68 78 6f 10 f0       	push   $0xf0106f78
f0102929:	e8 66 d7 ff ff       	call   f0100094 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f010292e:	83 ec 04             	sub    $0x4,%esp
f0102931:	6a 00                	push   $0x0
f0102933:	53                   	push   %ebx
f0102934:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f010293a:	e8 7d ea ff ff       	call   f01013bc <pgdir_walk>
f010293f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102945:	83 c4 0c             	add    $0xc,%esp
f0102948:	6a 00                	push   $0x0
f010294a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010294d:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f0102953:	e8 64 ea ff ff       	call   f01013bc <pgdir_walk>
f0102958:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010295e:	83 c4 0c             	add    $0xc,%esp
f0102961:	6a 00                	push   $0x0
f0102963:	56                   	push   %esi
f0102964:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f010296a:	e8 4d ea ff ff       	call   f01013bc <pgdir_walk>
f010296f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102975:	c7 04 24 f1 72 10 f0 	movl   $0xf01072f1,(%esp)
f010297c:	e8 2f 11 00 00       	call   f0103ab0 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, 
f0102981:	a1 98 7e 22 f0       	mov    0xf0227e98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102986:	83 c4 10             	add    $0x10,%esp
f0102989:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010298e:	77 15                	ja     f01029a5 <mem_init+0x12f4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102990:	50                   	push   %eax
f0102991:	68 a8 68 10 f0       	push   $0xf01068a8
f0102996:	68 c3 00 00 00       	push   $0xc3
f010299b:	68 78 6f 10 f0       	push   $0xf0106f78
f01029a0:	e8 ef d6 ff ff       	call   f0100094 <_panic>
f01029a5:	83 ec 08             	sub    $0x8,%esp
f01029a8:	6a 04                	push   $0x4
f01029aa:	05 00 00 00 10       	add    $0x10000000,%eax
f01029af:	50                   	push   %eax
f01029b0:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01029b5:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01029ba:	a1 94 7e 22 f0       	mov    0xf0227e94,%eax
f01029bf:	e8 8b ea ff ff       	call   f010144f <boot_map_region>
		UPAGES, 
		PTSIZE, 
		PADDR(pages), 
		PTE_U);
	cprintf("PADDR(pages) %x\n", PADDR(pages));
f01029c4:	a1 98 7e 22 f0       	mov    0xf0227e98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029c9:	83 c4 10             	add    $0x10,%esp
f01029cc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029d1:	77 15                	ja     f01029e8 <mem_init+0x1337>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029d3:	50                   	push   %eax
f01029d4:	68 a8 68 10 f0       	push   $0xf01068a8
f01029d9:	68 c5 00 00 00       	push   $0xc5
f01029de:	68 78 6f 10 f0       	push   $0xf0106f78
f01029e3:	e8 ac d6 ff ff       	call   f0100094 <_panic>
f01029e8:	83 ec 08             	sub    $0x8,%esp
f01029eb:	05 00 00 00 10       	add    $0x10000000,%eax
f01029f0:	50                   	push   %eax
f01029f1:	68 0a 73 10 f0       	push   $0xf010730a
f01029f6:	e8 b5 10 00 00       	call   f0103ab0 <cprintf>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir,
f01029fb:	a1 48 72 22 f0       	mov    0xf0227248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a00:	83 c4 10             	add    $0x10,%esp
f0102a03:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a08:	77 15                	ja     f0102a1f <mem_init+0x136e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a0a:	50                   	push   %eax
f0102a0b:	68 a8 68 10 f0       	push   $0xf01068a8
f0102a10:	68 d0 00 00 00       	push   $0xd0
f0102a15:	68 78 6f 10 f0       	push   $0xf0106f78
f0102a1a:	e8 75 d6 ff ff       	call   f0100094 <_panic>
f0102a1f:	83 ec 08             	sub    $0x8,%esp
f0102a22:	6a 04                	push   $0x4
f0102a24:	05 00 00 00 10       	add    $0x10000000,%eax
f0102a29:	50                   	push   %eax
f0102a2a:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102a2f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102a34:	a1 94 7e 22 f0       	mov    0xf0227e94,%eax
f0102a39:	e8 11 ea ff ff       	call   f010144f <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a3e:	83 c4 10             	add    $0x10,%esp
f0102a41:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0102a46:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a4b:	77 15                	ja     f0102a62 <mem_init+0x13b1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a4d:	50                   	push   %eax
f0102a4e:	68 a8 68 10 f0       	push   $0xf01068a8
f0102a53:	68 e2 00 00 00       	push   $0xe2
f0102a58:	68 78 6f 10 f0       	push   $0xf0106f78
f0102a5d:	e8 32 d6 ff ff       	call   f0100094 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, 
f0102a62:	83 ec 08             	sub    $0x8,%esp
f0102a65:	6a 02                	push   $0x2
f0102a67:	68 00 70 11 00       	push   $0x117000
f0102a6c:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102a71:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102a76:	a1 94 7e 22 f0       	mov    0xf0227e94,%eax
f0102a7b:	e8 cf e9 ff ff       	call   f010144f <boot_map_region>
		KSTACKTOP-KSTKSIZE, 
		KSTKSIZE, 
		PADDR(bootstack), 
		PTE_W);
	cprintf("PADDR(bootstack) %x\n", PADDR(bootstack));
f0102a80:	83 c4 08             	add    $0x8,%esp
f0102a83:	68 00 70 11 00       	push   $0x117000
f0102a88:	68 1b 73 10 f0       	push   $0xf010731b
f0102a8d:	e8 1e 10 00 00       	call   f0103ab0 <cprintf>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, 
f0102a92:	83 c4 08             	add    $0x8,%esp
f0102a95:	6a 02                	push   $0x2
f0102a97:	6a 00                	push   $0x0
f0102a99:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102a9e:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102aa3:	a1 94 7e 22 f0       	mov    0xf0227e94,%eax
f0102aa8:	e8 a2 e9 ff ff       	call   f010144f <boot_map_region>
f0102aad:	c7 45 c4 00 90 22 f0 	movl   $0xf0229000,-0x3c(%ebp)
f0102ab4:	83 c4 10             	add    $0x10,%esp
f0102ab7:	bb 00 90 22 f0       	mov    $0xf0229000,%ebx
f0102abc:	bf 00 80 ff ef       	mov    $0xefff8000,%edi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; ++i) {
f0102ac1:	be 00 00 00 00       	mov    $0x0,%esi
		cprintf("percpu_kstacks[%d]: %x\n", i, percpu_kstacks[i]);
f0102ac6:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0102ac9:	83 ec 04             	sub    $0x4,%esp
f0102acc:	53                   	push   %ebx
f0102acd:	56                   	push   %esi
f0102ace:	68 30 73 10 f0       	push   $0xf0107330
f0102ad3:	e8 d8 0f 00 00       	call   f0103ab0 <cprintf>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ad8:	83 c4 10             	add    $0x10,%esp
f0102adb:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102ae1:	77 17                	ja     f0102afa <mem_init+0x1449>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ae3:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102ae6:	68 a8 68 10 f0       	push   $0xf01068a8
f0102aeb:	68 30 01 00 00       	push   $0x130
f0102af0:	68 78 6f 10 f0       	push   $0xf0106f78
f0102af5:	e8 9a d5 ff ff       	call   f0100094 <_panic>
		boot_map_region(kern_pgdir, 
f0102afa:	83 ec 08             	sub    $0x8,%esp
f0102afd:	6a 02                	push   $0x2
f0102aff:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102b05:	50                   	push   %eax
f0102b06:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102b0b:	89 fa                	mov    %edi,%edx
f0102b0d:	a1 94 7e 22 f0       	mov    0xf0227e94,%eax
f0102b12:	e8 38 e9 ff ff       	call   f010144f <boot_map_region>
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; ++i) {
f0102b17:	83 c6 01             	add    $0x1,%esi
f0102b1a:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102b20:	81 ef 00 00 01 00    	sub    $0x10000,%edi
f0102b26:	83 c4 10             	add    $0x10,%esp
f0102b29:	83 fe 08             	cmp    $0x8,%esi
f0102b2c:	75 98                	jne    f0102ac6 <mem_init+0x1415>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102b2e:	8b 3d 94 7e 22 f0    	mov    0xf0227e94,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102b34:	a1 90 7e 22 f0       	mov    0xf0227e90,%eax
f0102b39:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102b3c:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102b43:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102b48:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102b4b:	8b 35 98 7e 22 f0    	mov    0xf0227e98,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b51:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102b54:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102b59:	eb 55                	jmp    f0102bb0 <mem_init+0x14ff>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102b5b:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102b61:	89 f8                	mov    %edi,%eax
f0102b63:	e8 6e e3 ff ff       	call   f0100ed6 <check_va2pa>
f0102b68:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102b6f:	77 15                	ja     f0102b86 <mem_init+0x14d5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b71:	56                   	push   %esi
f0102b72:	68 a8 68 10 f0       	push   $0xf01068a8
f0102b77:	68 54 03 00 00       	push   $0x354
f0102b7c:	68 78 6f 10 f0       	push   $0xf0106f78
f0102b81:	e8 0e d5 ff ff       	call   f0100094 <_panic>
f0102b86:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f0102b8d:	39 c2                	cmp    %eax,%edx
f0102b8f:	74 19                	je     f0102baa <mem_init+0x14f9>
f0102b91:	68 80 7a 10 f0       	push   $0xf0107a80
f0102b96:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102b9b:	68 54 03 00 00       	push   $0x354
f0102ba0:	68 78 6f 10 f0       	push   $0xf0106f78
f0102ba5:	e8 ea d4 ff ff       	call   f0100094 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102baa:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102bb0:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102bb3:	77 a6                	ja     f0102b5b <mem_init+0x14aa>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102bb5:	8b 35 48 72 22 f0    	mov    0xf0227248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102bbb:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102bbe:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102bc3:	89 da                	mov    %ebx,%edx
f0102bc5:	89 f8                	mov    %edi,%eax
f0102bc7:	e8 0a e3 ff ff       	call   f0100ed6 <check_va2pa>
f0102bcc:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102bd3:	77 15                	ja     f0102bea <mem_init+0x1539>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bd5:	56                   	push   %esi
f0102bd6:	68 a8 68 10 f0       	push   $0xf01068a8
f0102bdb:	68 59 03 00 00       	push   $0x359
f0102be0:	68 78 6f 10 f0       	push   $0xf0106f78
f0102be5:	e8 aa d4 ff ff       	call   f0100094 <_panic>
f0102bea:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102bf1:	39 d0                	cmp    %edx,%eax
f0102bf3:	74 19                	je     f0102c0e <mem_init+0x155d>
f0102bf5:	68 b4 7a 10 f0       	push   $0xf0107ab4
f0102bfa:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102bff:	68 59 03 00 00       	push   $0x359
f0102c04:	68 78 6f 10 f0       	push   $0xf0106f78
f0102c09:	e8 86 d4 ff ff       	call   f0100094 <_panic>
f0102c0e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102c14:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102c1a:	75 a7                	jne    f0102bc3 <mem_init+0x1512>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102c1c:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102c1f:	c1 e6 0c             	shl    $0xc,%esi
f0102c22:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102c27:	eb 30                	jmp    f0102c59 <mem_init+0x15a8>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102c29:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102c2f:	89 f8                	mov    %edi,%eax
f0102c31:	e8 a0 e2 ff ff       	call   f0100ed6 <check_va2pa>
f0102c36:	39 c3                	cmp    %eax,%ebx
f0102c38:	74 19                	je     f0102c53 <mem_init+0x15a2>
f0102c3a:	68 e8 7a 10 f0       	push   $0xf0107ae8
f0102c3f:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102c44:	68 5d 03 00 00       	push   $0x35d
f0102c49:	68 78 6f 10 f0       	push   $0xf0106f78
f0102c4e:	e8 41 d4 ff ff       	call   f0100094 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102c53:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102c59:	39 f3                	cmp    %esi,%ebx
f0102c5b:	72 cc                	jb     f0102c29 <mem_init+0x1578>
f0102c5d:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102c62:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102c65:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102c68:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102c6b:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102c71:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102c74:	89 c3                	mov    %eax,%ebx
			// check_va2pa(pgdir, base + KSTKGAP + i));

		// cprintf("PADDR(percpu_kstacks[n]) + i: %x\n", 
		//	PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102c76:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102c79:	05 00 80 00 20       	add    $0x20008000,%eax
f0102c7e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102c81:	89 da                	mov    %ebx,%edx
f0102c83:	89 f8                	mov    %edi,%eax
f0102c85:	e8 4c e2 ff ff       	call   f0100ed6 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c8a:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102c90:	77 15                	ja     f0102ca7 <mem_init+0x15f6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c92:	56                   	push   %esi
f0102c93:	68 a8 68 10 f0       	push   $0xf01068a8
f0102c98:	68 6a 03 00 00       	push   $0x36a
f0102c9d:	68 78 6f 10 f0       	push   $0xf0106f78
f0102ca2:	e8 ed d3 ff ff       	call   f0100094 <_panic>
f0102ca7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102caa:	8d 94 0b 00 90 22 f0 	lea    -0xfdd7000(%ebx,%ecx,1),%edx
f0102cb1:	39 d0                	cmp    %edx,%eax
f0102cb3:	74 19                	je     f0102cce <mem_init+0x161d>
f0102cb5:	68 10 7b 10 f0       	push   $0xf0107b10
f0102cba:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102cbf:	68 6a 03 00 00       	push   $0x36a
f0102cc4:	68 78 6f 10 f0       	push   $0xf0106f78
f0102cc9:	e8 c6 d3 ff ff       	call   f0100094 <_panic>
f0102cce:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		// cprintf("check_va2pa(pgdir, base + KSTKGAP + i): %x\n", 
			// check_va2pa(pgdir, base + KSTKGAP + i));

		// cprintf("PADDR(percpu_kstacks[n]) + i: %x\n", 
		//	PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102cd4:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0102cd7:	75 a8                	jne    f0102c81 <mem_init+0x15d0>
f0102cd9:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102cdc:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102ce2:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102ce5:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102ce7:	89 da                	mov    %ebx,%edx
f0102ce9:	89 f8                	mov    %edi,%eax
f0102ceb:	e8 e6 e1 ff ff       	call   f0100ed6 <check_va2pa>
f0102cf0:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102cf3:	74 19                	je     f0102d0e <mem_init+0x165d>
f0102cf5:	68 58 7b 10 f0       	push   $0xf0107b58
f0102cfa:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102cff:	68 6c 03 00 00       	push   $0x36c
f0102d04:	68 78 6f 10 f0       	push   $0xf0106f78
f0102d09:	e8 86 d3 ff ff       	call   f0100094 <_panic>
f0102d0e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		// cprintf("PADDR(percpu_kstacks[n]) + i: %x\n", 
		//	PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102d14:	39 de                	cmp    %ebx,%esi
f0102d16:	75 cf                	jne    f0102ce7 <mem_init+0x1636>
f0102d18:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102d1b:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102d22:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102d29:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102d2f:	b8 00 90 26 f0       	mov    $0xf0269000,%eax
f0102d34:	39 f0                	cmp    %esi,%eax
f0102d36:	0f 85 2c ff ff ff    	jne    f0102c68 <mem_init+0x15b7>
f0102d3c:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d41:	eb 2a                	jmp    f0102d6d <mem_init+0x16bc>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102d43:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102d49:	83 fa 04             	cmp    $0x4,%edx
f0102d4c:	77 1f                	ja     f0102d6d <mem_init+0x16bc>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102d4e:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102d52:	75 7e                	jne    f0102dd2 <mem_init+0x1721>
f0102d54:	68 48 73 10 f0       	push   $0xf0107348
f0102d59:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102d5e:	68 77 03 00 00       	push   $0x377
f0102d63:	68 78 6f 10 f0       	push   $0xf0106f78
f0102d68:	e8 27 d3 ff ff       	call   f0100094 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102d6d:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102d72:	76 3f                	jbe    f0102db3 <mem_init+0x1702>
				assert(pgdir[i] & PTE_P);
f0102d74:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102d77:	f6 c2 01             	test   $0x1,%dl
f0102d7a:	75 19                	jne    f0102d95 <mem_init+0x16e4>
f0102d7c:	68 48 73 10 f0       	push   $0xf0107348
f0102d81:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102d86:	68 7b 03 00 00       	push   $0x37b
f0102d8b:	68 78 6f 10 f0       	push   $0xf0106f78
f0102d90:	e8 ff d2 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_W);
f0102d95:	f6 c2 02             	test   $0x2,%dl
f0102d98:	75 38                	jne    f0102dd2 <mem_init+0x1721>
f0102d9a:	68 59 73 10 f0       	push   $0xf0107359
f0102d9f:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102da4:	68 7c 03 00 00       	push   $0x37c
f0102da9:	68 78 6f 10 f0       	push   $0xf0106f78
f0102dae:	e8 e1 d2 ff ff       	call   f0100094 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102db3:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102db7:	74 19                	je     f0102dd2 <mem_init+0x1721>
f0102db9:	68 6a 73 10 f0       	push   $0xf010736a
f0102dbe:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102dc3:	68 7e 03 00 00       	push   $0x37e
f0102dc8:	68 78 6f 10 f0       	push   $0xf0106f78
f0102dcd:	e8 c2 d2 ff ff       	call   f0100094 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102dd2:	83 c0 01             	add    $0x1,%eax
f0102dd5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102dda:	0f 86 63 ff ff ff    	jbe    f0102d43 <mem_init+0x1692>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102de0:	83 ec 0c             	sub    $0xc,%esp
f0102de3:	68 7c 7b 10 f0       	push   $0xf0107b7c
f0102de8:	e8 c3 0c 00 00       	call   f0103ab0 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102ded:	a1 94 7e 22 f0       	mov    0xf0227e94,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102df2:	83 c4 10             	add    $0x10,%esp
f0102df5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102dfa:	77 15                	ja     f0102e11 <mem_init+0x1760>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dfc:	50                   	push   %eax
f0102dfd:	68 a8 68 10 f0       	push   $0xf01068a8
f0102e02:	68 05 01 00 00       	push   $0x105
f0102e07:	68 78 6f 10 f0       	push   $0xf0106f78
f0102e0c:	e8 83 d2 ff ff       	call   f0100094 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102e11:	05 00 00 00 10       	add    $0x10000000,%eax
f0102e16:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102e19:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e1e:	e8 17 e1 ff ff       	call   f0100f3a <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102e23:	0f 20 c0             	mov    %cr0,%eax
f0102e26:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102e29:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102e2e:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102e31:	83 ec 0c             	sub    $0xc,%esp
f0102e34:	6a 00                	push   $0x0
f0102e36:	e8 e1 e4 ff ff       	call   f010131c <page_alloc>
f0102e3b:	89 c3                	mov    %eax,%ebx
f0102e3d:	83 c4 10             	add    $0x10,%esp
f0102e40:	85 c0                	test   %eax,%eax
f0102e42:	75 19                	jne    f0102e5d <mem_init+0x17ac>
f0102e44:	68 fb 70 10 f0       	push   $0xf01070fb
f0102e49:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102e4e:	68 54 04 00 00       	push   $0x454
f0102e53:	68 78 6f 10 f0       	push   $0xf0106f78
f0102e58:	e8 37 d2 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102e5d:	83 ec 0c             	sub    $0xc,%esp
f0102e60:	6a 00                	push   $0x0
f0102e62:	e8 b5 e4 ff ff       	call   f010131c <page_alloc>
f0102e67:	89 c7                	mov    %eax,%edi
f0102e69:	83 c4 10             	add    $0x10,%esp
f0102e6c:	85 c0                	test   %eax,%eax
f0102e6e:	75 19                	jne    f0102e89 <mem_init+0x17d8>
f0102e70:	68 11 71 10 f0       	push   $0xf0107111
f0102e75:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102e7a:	68 55 04 00 00       	push   $0x455
f0102e7f:	68 78 6f 10 f0       	push   $0xf0106f78
f0102e84:	e8 0b d2 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102e89:	83 ec 0c             	sub    $0xc,%esp
f0102e8c:	6a 00                	push   $0x0
f0102e8e:	e8 89 e4 ff ff       	call   f010131c <page_alloc>
f0102e93:	89 c6                	mov    %eax,%esi
f0102e95:	83 c4 10             	add    $0x10,%esp
f0102e98:	85 c0                	test   %eax,%eax
f0102e9a:	75 19                	jne    f0102eb5 <mem_init+0x1804>
f0102e9c:	68 27 71 10 f0       	push   $0xf0107127
f0102ea1:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102ea6:	68 56 04 00 00       	push   $0x456
f0102eab:	68 78 6f 10 f0       	push   $0xf0106f78
f0102eb0:	e8 df d1 ff ff       	call   f0100094 <_panic>
	page_free(pp0);
f0102eb5:	83 ec 0c             	sub    $0xc,%esp
f0102eb8:	53                   	push   %ebx
f0102eb9:	e8 c8 e4 ff ff       	call   f0101386 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ebe:	89 f8                	mov    %edi,%eax
f0102ec0:	2b 05 98 7e 22 f0    	sub    0xf0227e98,%eax
f0102ec6:	c1 f8 03             	sar    $0x3,%eax
f0102ec9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ecc:	89 c2                	mov    %eax,%edx
f0102ece:	c1 ea 0c             	shr    $0xc,%edx
f0102ed1:	83 c4 10             	add    $0x10,%esp
f0102ed4:	3b 15 90 7e 22 f0    	cmp    0xf0227e90,%edx
f0102eda:	72 12                	jb     f0102eee <mem_init+0x183d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102edc:	50                   	push   %eax
f0102edd:	68 5c 68 10 f0       	push   $0xf010685c
f0102ee2:	6a 58                	push   $0x58
f0102ee4:	68 84 6f 10 f0       	push   $0xf0106f84
f0102ee9:	e8 a6 d1 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102eee:	83 ec 04             	sub    $0x4,%esp
f0102ef1:	68 00 10 00 00       	push   $0x1000
f0102ef6:	6a 01                	push   $0x1
f0102ef8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102efd:	50                   	push   %eax
f0102efe:	e8 59 2b 00 00       	call   f0105a5c <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f03:	89 f0                	mov    %esi,%eax
f0102f05:	2b 05 98 7e 22 f0    	sub    0xf0227e98,%eax
f0102f0b:	c1 f8 03             	sar    $0x3,%eax
f0102f0e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f11:	89 c2                	mov    %eax,%edx
f0102f13:	c1 ea 0c             	shr    $0xc,%edx
f0102f16:	83 c4 10             	add    $0x10,%esp
f0102f19:	3b 15 90 7e 22 f0    	cmp    0xf0227e90,%edx
f0102f1f:	72 12                	jb     f0102f33 <mem_init+0x1882>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f21:	50                   	push   %eax
f0102f22:	68 5c 68 10 f0       	push   $0xf010685c
f0102f27:	6a 58                	push   $0x58
f0102f29:	68 84 6f 10 f0       	push   $0xf0106f84
f0102f2e:	e8 61 d1 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102f33:	83 ec 04             	sub    $0x4,%esp
f0102f36:	68 00 10 00 00       	push   $0x1000
f0102f3b:	6a 02                	push   $0x2
f0102f3d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102f42:	50                   	push   %eax
f0102f43:	e8 14 2b 00 00       	call   f0105a5c <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102f48:	6a 02                	push   $0x2
f0102f4a:	68 00 10 00 00       	push   $0x1000
f0102f4f:	57                   	push   %edi
f0102f50:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f0102f56:	e8 83 e6 ff ff       	call   f01015de <page_insert>
	assert(pp1->pp_ref == 1);
f0102f5b:	83 c4 20             	add    $0x20,%esp
f0102f5e:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102f63:	74 19                	je     f0102f7e <mem_init+0x18cd>
f0102f65:	68 08 72 10 f0       	push   $0xf0107208
f0102f6a:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102f6f:	68 5b 04 00 00       	push   $0x45b
f0102f74:	68 78 6f 10 f0       	push   $0xf0106f78
f0102f79:	e8 16 d1 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102f7e:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102f85:	01 01 01 
f0102f88:	74 19                	je     f0102fa3 <mem_init+0x18f2>
f0102f8a:	68 9c 7b 10 f0       	push   $0xf0107b9c
f0102f8f:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102f94:	68 5c 04 00 00       	push   $0x45c
f0102f99:	68 78 6f 10 f0       	push   $0xf0106f78
f0102f9e:	e8 f1 d0 ff ff       	call   f0100094 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102fa3:	6a 02                	push   $0x2
f0102fa5:	68 00 10 00 00       	push   $0x1000
f0102faa:	56                   	push   %esi
f0102fab:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f0102fb1:	e8 28 e6 ff ff       	call   f01015de <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102fb6:	83 c4 10             	add    $0x10,%esp
f0102fb9:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102fc0:	02 02 02 
f0102fc3:	74 19                	je     f0102fde <mem_init+0x192d>
f0102fc5:	68 c0 7b 10 f0       	push   $0xf0107bc0
f0102fca:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102fcf:	68 5e 04 00 00       	push   $0x45e
f0102fd4:	68 78 6f 10 f0       	push   $0xf0106f78
f0102fd9:	e8 b6 d0 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102fde:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102fe3:	74 19                	je     f0102ffe <mem_init+0x194d>
f0102fe5:	68 2a 72 10 f0       	push   $0xf010722a
f0102fea:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0102fef:	68 5f 04 00 00       	push   $0x45f
f0102ff4:	68 78 6f 10 f0       	push   $0xf0106f78
f0102ff9:	e8 96 d0 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102ffe:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103003:	74 19                	je     f010301e <mem_init+0x196d>
f0103005:	68 9f 72 10 f0       	push   $0xf010729f
f010300a:	68 9e 6f 10 f0       	push   $0xf0106f9e
f010300f:	68 60 04 00 00       	push   $0x460
f0103014:	68 78 6f 10 f0       	push   $0xf0106f78
f0103019:	e8 76 d0 ff ff       	call   f0100094 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010301e:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103025:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103028:	89 f0                	mov    %esi,%eax
f010302a:	2b 05 98 7e 22 f0    	sub    0xf0227e98,%eax
f0103030:	c1 f8 03             	sar    $0x3,%eax
f0103033:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103036:	89 c2                	mov    %eax,%edx
f0103038:	c1 ea 0c             	shr    $0xc,%edx
f010303b:	3b 15 90 7e 22 f0    	cmp    0xf0227e90,%edx
f0103041:	72 12                	jb     f0103055 <mem_init+0x19a4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103043:	50                   	push   %eax
f0103044:	68 5c 68 10 f0       	push   $0xf010685c
f0103049:	6a 58                	push   $0x58
f010304b:	68 84 6f 10 f0       	push   $0xf0106f84
f0103050:	e8 3f d0 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103055:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010305c:	03 03 03 
f010305f:	74 19                	je     f010307a <mem_init+0x19c9>
f0103061:	68 e4 7b 10 f0       	push   $0xf0107be4
f0103066:	68 9e 6f 10 f0       	push   $0xf0106f9e
f010306b:	68 62 04 00 00       	push   $0x462
f0103070:	68 78 6f 10 f0       	push   $0xf0106f78
f0103075:	e8 1a d0 ff ff       	call   f0100094 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010307a:	83 ec 08             	sub    $0x8,%esp
f010307d:	68 00 10 00 00       	push   $0x1000
f0103082:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f0103088:	e8 03 e5 ff ff       	call   f0101590 <page_remove>
	assert(pp2->pp_ref == 0);
f010308d:	83 c4 10             	add    $0x10,%esp
f0103090:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103095:	74 19                	je     f01030b0 <mem_init+0x19ff>
f0103097:	68 8e 72 10 f0       	push   $0xf010728e
f010309c:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01030a1:	68 64 04 00 00       	push   $0x464
f01030a6:	68 78 6f 10 f0       	push   $0xf0106f78
f01030ab:	e8 e4 cf ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01030b0:	8b 0d 94 7e 22 f0    	mov    0xf0227e94,%ecx
f01030b6:	8b 11                	mov    (%ecx),%edx
f01030b8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01030be:	89 d8                	mov    %ebx,%eax
f01030c0:	2b 05 98 7e 22 f0    	sub    0xf0227e98,%eax
f01030c6:	c1 f8 03             	sar    $0x3,%eax
f01030c9:	c1 e0 0c             	shl    $0xc,%eax
f01030cc:	39 c2                	cmp    %eax,%edx
f01030ce:	74 19                	je     f01030e9 <mem_init+0x1a38>
f01030d0:	68 a4 75 10 f0       	push   $0xf01075a4
f01030d5:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01030da:	68 67 04 00 00       	push   $0x467
f01030df:	68 78 6f 10 f0       	push   $0xf0106f78
f01030e4:	e8 ab cf ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f01030e9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01030ef:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01030f4:	74 19                	je     f010310f <mem_init+0x1a5e>
f01030f6:	68 19 72 10 f0       	push   $0xf0107219
f01030fb:	68 9e 6f 10 f0       	push   $0xf0106f9e
f0103100:	68 69 04 00 00       	push   $0x469
f0103105:	68 78 6f 10 f0       	push   $0xf0106f78
f010310a:	e8 85 cf ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f010310f:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0103115:	83 ec 0c             	sub    $0xc,%esp
f0103118:	53                   	push   %ebx
f0103119:	e8 68 e2 ff ff       	call   f0101386 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010311e:	c7 04 24 10 7c 10 f0 	movl   $0xf0107c10,(%esp)
f0103125:	e8 86 09 00 00       	call   f0103ab0 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010312a:	83 c4 10             	add    $0x10,%esp
f010312d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103130:	5b                   	pop    %ebx
f0103131:	5e                   	pop    %esi
f0103132:	5f                   	pop    %edi
f0103133:	5d                   	pop    %ebp
f0103134:	c3                   	ret    

f0103135 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103135:	55                   	push   %ebp
f0103136:	89 e5                	mov    %esp,%ebp
f0103138:	57                   	push   %edi
f0103139:	56                   	push   %esi
f010313a:	53                   	push   %ebx
f010313b:	83 ec 1c             	sub    $0x1c,%esp
f010313e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103141:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
	// cprintf("user_mem_check va: %x, len: %x\n", va, len);
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
f0103144:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103147:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
f010314d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103150:	03 45 10             	add    0x10(%ebp),%eax
f0103153:	05 ff 0f 00 00       	add    $0xfff,%eax
f0103158:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010315d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t i;
	for (i = (uint32_t)begin; i < end; i+=PGSIZE) {
f0103160:	eb 43                	jmp    f01031a5 <user_mem_check+0x70>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
f0103162:	83 ec 04             	sub    $0x4,%esp
f0103165:	6a 00                	push   $0x0
f0103167:	53                   	push   %ebx
f0103168:	ff 77 60             	pushl  0x60(%edi)
f010316b:	e8 4c e2 ff ff       	call   f01013bc <pgdir_walk>
		// pprint(pte);
		if ((i>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
f0103170:	83 c4 10             	add    $0x10,%esp
f0103173:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103179:	77 10                	ja     f010318b <user_mem_check+0x56>
f010317b:	85 c0                	test   %eax,%eax
f010317d:	74 0c                	je     f010318b <user_mem_check+0x56>
f010317f:	8b 00                	mov    (%eax),%eax
f0103181:	a8 01                	test   $0x1,%al
f0103183:	74 06                	je     f010318b <user_mem_check+0x56>
f0103185:	21 f0                	and    %esi,%eax
f0103187:	39 c6                	cmp    %eax,%esi
f0103189:	74 14                	je     f010319f <user_mem_check+0x6a>
			user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
f010318b:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f010318e:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0103192:	89 1d 3c 72 22 f0    	mov    %ebx,0xf022723c
			return -E_FAULT;
f0103198:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010319d:	eb 10                	jmp    f01031af <user_mem_check+0x7a>
	// LAB 3: Your code here.
	// cprintf("user_mem_check va: %x, len: %x\n", va, len);
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
	uint32_t i;
	for (i = (uint32_t)begin; i < end; i+=PGSIZE) {
f010319f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01031a5:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01031a8:	72 b8                	jb     f0103162 <user_mem_check+0x2d>
			user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
			return -E_FAULT;
		}
	}
	// cprintf("user_mem_check success va: %x, len: %x\n", va, len);
	return 0;
f01031aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01031af:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01031b2:	5b                   	pop    %ebx
f01031b3:	5e                   	pop    %esi
f01031b4:	5f                   	pop    %edi
f01031b5:	5d                   	pop    %ebp
f01031b6:	c3                   	ret    

f01031b7 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01031b7:	55                   	push   %ebp
f01031b8:	89 e5                	mov    %esp,%ebp
f01031ba:	53                   	push   %ebx
f01031bb:	83 ec 04             	sub    $0x4,%esp
f01031be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01031c1:	8b 45 14             	mov    0x14(%ebp),%eax
f01031c4:	83 c8 04             	or     $0x4,%eax
f01031c7:	50                   	push   %eax
f01031c8:	ff 75 10             	pushl  0x10(%ebp)
f01031cb:	ff 75 0c             	pushl  0xc(%ebp)
f01031ce:	53                   	push   %ebx
f01031cf:	e8 61 ff ff ff       	call   f0103135 <user_mem_check>
f01031d4:	83 c4 10             	add    $0x10,%esp
f01031d7:	85 c0                	test   %eax,%eax
f01031d9:	79 21                	jns    f01031fc <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f01031db:	83 ec 04             	sub    $0x4,%esp
f01031de:	ff 35 3c 72 22 f0    	pushl  0xf022723c
f01031e4:	ff 73 48             	pushl  0x48(%ebx)
f01031e7:	68 3c 7c 10 f0       	push   $0xf0107c3c
f01031ec:	e8 bf 08 00 00       	call   f0103ab0 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01031f1:	89 1c 24             	mov    %ebx,(%esp)
f01031f4:	e8 ed 05 00 00       	call   f01037e6 <env_destroy>
f01031f9:	83 c4 10             	add    $0x10,%esp
	}
}
f01031fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01031ff:	c9                   	leave  
f0103200:	c3                   	ret    

f0103201 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103201:	55                   	push   %ebp
f0103202:	89 e5                	mov    %esp,%ebp
f0103204:	57                   	push   %edi
f0103205:	56                   	push   %esi
f0103206:	53                   	push   %ebx
f0103207:	83 ec 0c             	sub    $0xc,%esp
f010320a:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
f010320c:	89 d3                	mov    %edx,%ebx
f010320e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0103214:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f010321b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	// cprintf("begin: %x, end: %x\n", begin, end);
	for (; begin < end; begin += PGSIZE) {
f0103221:	eb 3d                	jmp    f0103260 <region_alloc+0x5f>
		struct PageInfo *pg = page_alloc(0);
f0103223:	83 ec 0c             	sub    $0xc,%esp
f0103226:	6a 00                	push   $0x0
f0103228:	e8 ef e0 ff ff       	call   f010131c <page_alloc>
		if (!pg) panic("region_alloc failed!");
f010322d:	83 c4 10             	add    $0x10,%esp
f0103230:	85 c0                	test   %eax,%eax
f0103232:	75 17                	jne    f010324b <region_alloc+0x4a>
f0103234:	83 ec 04             	sub    $0x4,%esp
f0103237:	68 71 7c 10 f0       	push   $0xf0107c71
f010323c:	68 23 01 00 00       	push   $0x123
f0103241:	68 86 7c 10 f0       	push   $0xf0107c86
f0103246:	e8 49 ce ff ff       	call   f0100094 <_panic>
		page_insert(e->env_pgdir, pg, begin, PTE_W | PTE_U);
f010324b:	6a 06                	push   $0x6
f010324d:	53                   	push   %ebx
f010324e:	50                   	push   %eax
f010324f:	ff 77 60             	pushl  0x60(%edi)
f0103252:	e8 87 e3 ff ff       	call   f01015de <page_insert>
region_alloc(struct Env *e, void *va, size_t len)
{
	// LAB 3: Your code here.
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
	// cprintf("begin: %x, end: %x\n", begin, end);
	for (; begin < end; begin += PGSIZE) {
f0103257:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010325d:	83 c4 10             	add    $0x10,%esp
f0103260:	39 f3                	cmp    %esi,%ebx
f0103262:	72 bf                	jb     f0103223 <region_alloc+0x22>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0103264:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103267:	5b                   	pop    %ebx
f0103268:	5e                   	pop    %esi
f0103269:	5f                   	pop    %edi
f010326a:	5d                   	pop    %ebp
f010326b:	c3                   	ret    

f010326c <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010326c:	55                   	push   %ebp
f010326d:	89 e5                	mov    %esp,%ebp
f010326f:	56                   	push   %esi
f0103270:	53                   	push   %ebx
f0103271:	8b 45 08             	mov    0x8(%ebp),%eax
f0103274:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103277:	85 c0                	test   %eax,%eax
f0103279:	75 1a                	jne    f0103295 <envid2env+0x29>
		*env_store = curenv;
f010327b:	e8 fc 2d 00 00       	call   f010607c <cpunum>
f0103280:	6b c0 74             	imul   $0x74,%eax,%eax
f0103283:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f0103289:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010328c:	89 01                	mov    %eax,(%ecx)
		return 0;
f010328e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103293:	eb 70                	jmp    f0103305 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103295:	89 c3                	mov    %eax,%ebx
f0103297:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f010329d:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f01032a0:	03 1d 48 72 22 f0    	add    0xf0227248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01032a6:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01032aa:	74 05                	je     f01032b1 <envid2env+0x45>
f01032ac:	3b 43 48             	cmp    0x48(%ebx),%eax
f01032af:	74 10                	je     f01032c1 <envid2env+0x55>
		*env_store = 0;
f01032b1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01032ba:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01032bf:	eb 44                	jmp    f0103305 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01032c1:	84 d2                	test   %dl,%dl
f01032c3:	74 36                	je     f01032fb <envid2env+0x8f>
f01032c5:	e8 b2 2d 00 00       	call   f010607c <cpunum>
f01032ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01032cd:	3b 98 28 80 22 f0    	cmp    -0xfdd7fd8(%eax),%ebx
f01032d3:	74 26                	je     f01032fb <envid2env+0x8f>
f01032d5:	8b 73 4c             	mov    0x4c(%ebx),%esi
f01032d8:	e8 9f 2d 00 00       	call   f010607c <cpunum>
f01032dd:	6b c0 74             	imul   $0x74,%eax,%eax
f01032e0:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f01032e6:	3b 70 48             	cmp    0x48(%eax),%esi
f01032e9:	74 10                	je     f01032fb <envid2env+0x8f>
		*env_store = 0;
f01032eb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032ee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01032f4:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01032f9:	eb 0a                	jmp    f0103305 <envid2env+0x99>
	}

	*env_store = e;
f01032fb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032fe:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103300:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103305:	5b                   	pop    %ebx
f0103306:	5e                   	pop    %esi
f0103307:	5d                   	pop    %ebp
f0103308:	c3                   	ret    

f0103309 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103309:	55                   	push   %ebp
f010330a:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f010330c:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f0103311:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103314:	b8 23 00 00 00       	mov    $0x23,%eax
f0103319:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f010331b:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f010331d:	b8 10 00 00 00       	mov    $0x10,%eax
f0103322:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103324:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103326:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103328:	ea 2f 33 10 f0 08 00 	ljmp   $0x8,$0xf010332f
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f010332f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103334:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103337:	5d                   	pop    %ebp
f0103338:	c3                   	ret    

f0103339 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103339:	55                   	push   %ebp
f010333a:	89 e5                	mov    %esp,%ebp
f010333c:	56                   	push   %esi
f010333d:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV-1;i >= 0; --i) {
		envs[i].env_id = 0;
f010333e:	8b 35 48 72 22 f0    	mov    0xf0227248,%esi
f0103344:	8b 15 4c 72 22 f0    	mov    0xf022724c,%edx
f010334a:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103350:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0103353:	89 c1                	mov    %eax,%ecx
f0103355:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f010335c:	89 50 44             	mov    %edx,0x44(%eax)
f010335f:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = envs+i;
f0103362:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV-1;i >= 0; --i) {
f0103364:	39 d8                	cmp    %ebx,%eax
f0103366:	75 eb                	jne    f0103353 <env_init+0x1a>
f0103368:	89 35 4c 72 22 f0    	mov    %esi,0xf022724c
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = envs+i;
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f010336e:	e8 96 ff ff ff       	call   f0103309 <env_init_percpu>
}
f0103373:	5b                   	pop    %ebx
f0103374:	5e                   	pop    %esi
f0103375:	5d                   	pop    %ebp
f0103376:	c3                   	ret    

f0103377 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103377:	55                   	push   %ebp
f0103378:	89 e5                	mov    %esp,%ebp
f010337a:	53                   	push   %ebx
f010337b:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010337e:	8b 1d 4c 72 22 f0    	mov    0xf022724c,%ebx
f0103384:	85 db                	test   %ebx,%ebx
f0103386:	0f 84 69 01 00 00    	je     f01034f5 <env_alloc+0x17e>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010338c:	83 ec 0c             	sub    $0xc,%esp
f010338f:	6a 01                	push   $0x1
f0103391:	e8 86 df ff ff       	call   f010131c <page_alloc>
f0103396:	83 c4 10             	add    $0x10,%esp
f0103399:	85 c0                	test   %eax,%eax
f010339b:	0f 84 5b 01 00 00    	je     f01034fc <env_alloc+0x185>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f01033a1:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01033a6:	2b 05 98 7e 22 f0    	sub    0xf0227e98,%eax
f01033ac:	c1 f8 03             	sar    $0x3,%eax
f01033af:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01033b2:	89 c2                	mov    %eax,%edx
f01033b4:	c1 ea 0c             	shr    $0xc,%edx
f01033b7:	3b 15 90 7e 22 f0    	cmp    0xf0227e90,%edx
f01033bd:	72 12                	jb     f01033d1 <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01033bf:	50                   	push   %eax
f01033c0:	68 5c 68 10 f0       	push   $0xf010685c
f01033c5:	6a 58                	push   $0x58
f01033c7:	68 84 6f 10 f0       	push   $0xf0106f84
f01033cc:	e8 c3 cc ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f01033d1:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = (pde_t *) page2kva(p);
f01033d6:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f01033d9:	83 ec 04             	sub    $0x4,%esp
f01033dc:	68 00 10 00 00       	push   $0x1000
f01033e1:	ff 35 94 7e 22 f0    	pushl  0xf0227e94
f01033e7:	50                   	push   %eax
f01033e8:	e8 24 27 00 00       	call   f0105b11 <memcpy>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01033ed:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033f0:	83 c4 10             	add    $0x10,%esp
f01033f3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033f8:	77 15                	ja     f010340f <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033fa:	50                   	push   %eax
f01033fb:	68 a8 68 10 f0       	push   $0xf01068a8
f0103400:	68 c4 00 00 00       	push   $0xc4
f0103405:	68 86 7c 10 f0       	push   $0xf0107c86
f010340a:	e8 85 cc ff ff       	call   f0100094 <_panic>
f010340f:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103415:	83 ca 05             	or     $0x5,%edx
f0103418:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010341e:	8b 43 48             	mov    0x48(%ebx),%eax
f0103421:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103426:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f010342b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103430:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103433:	89 da                	mov    %ebx,%edx
f0103435:	2b 15 48 72 22 f0    	sub    0xf0227248,%edx
f010343b:	c1 fa 02             	sar    $0x2,%edx
f010343e:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103444:	09 d0                	or     %edx,%eax
f0103446:	89 43 48             	mov    %eax,0x48(%ebx)
	// cprintf("envs: %x, e: %x, e->env_id: %x\n", envs, e, e->env_id);

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103449:	8b 45 0c             	mov    0xc(%ebp),%eax
f010344c:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010344f:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103456:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010345d:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103464:	83 ec 04             	sub    $0x4,%esp
f0103467:	6a 44                	push   $0x44
f0103469:	6a 00                	push   $0x0
f010346b:	53                   	push   %ebx
f010346c:	e8 eb 25 00 00       	call   f0105a5c <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103471:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103477:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010347d:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103483:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010348a:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0103490:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103497:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f010349e:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01034a2:	8b 43 44             	mov    0x44(%ebx),%eax
f01034a5:	a3 4c 72 22 f0       	mov    %eax,0xf022724c
	*newenv_store = e;
f01034aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01034ad:	89 18                	mov    %ebx,(%eax)

	// cprintf("env_id, %x\n", e->env_id);
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01034af:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01034b2:	e8 c5 2b 00 00       	call   f010607c <cpunum>
f01034b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01034ba:	83 c4 10             	add    $0x10,%esp
f01034bd:	ba 00 00 00 00       	mov    $0x0,%edx
f01034c2:	83 b8 28 80 22 f0 00 	cmpl   $0x0,-0xfdd7fd8(%eax)
f01034c9:	74 11                	je     f01034dc <env_alloc+0x165>
f01034cb:	e8 ac 2b 00 00       	call   f010607c <cpunum>
f01034d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01034d3:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f01034d9:	8b 50 48             	mov    0x48(%eax),%edx
f01034dc:	83 ec 04             	sub    $0x4,%esp
f01034df:	53                   	push   %ebx
f01034e0:	52                   	push   %edx
f01034e1:	68 91 7c 10 f0       	push   $0xf0107c91
f01034e6:	e8 c5 05 00 00       	call   f0103ab0 <cprintf>
	return 0;
f01034eb:	83 c4 10             	add    $0x10,%esp
f01034ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01034f3:	eb 0c                	jmp    f0103501 <env_alloc+0x18a>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01034f5:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01034fa:	eb 05                	jmp    f0103501 <env_alloc+0x18a>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01034fc:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	*newenv_store = e;

	// cprintf("env_id, %x\n", e->env_id);
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103501:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103504:	c9                   	leave  
f0103505:	c3                   	ret    

f0103506 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0103506:	55                   	push   %ebp
f0103507:	89 e5                	mov    %esp,%ebp
f0103509:	57                   	push   %edi
f010350a:	56                   	push   %esi
f010350b:	53                   	push   %ebx
f010350c:	83 ec 34             	sub    $0x34,%esp
f010350f:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *penv;
	env_alloc(&penv, 0);
f0103512:	6a 00                	push   $0x0
f0103514:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103517:	50                   	push   %eax
f0103518:	e8 5a fe ff ff       	call   f0103377 <env_alloc>
	load_icode(penv, binary, size);
f010351d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103520:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	struct Elf *ELFHDR = (struct Elf *) binary;
	struct Proghdr *ph, *eph;

	if (ELFHDR->e_magic != ELF_MAGIC)
f0103523:	83 c4 10             	add    $0x10,%esp
f0103526:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f010352c:	74 17                	je     f0103545 <env_create+0x3f>
		panic("Not executable!");
f010352e:	83 ec 04             	sub    $0x4,%esp
f0103531:	68 a6 7c 10 f0       	push   $0xf0107ca6
f0103536:	68 60 01 00 00       	push   $0x160
f010353b:	68 86 7c 10 f0       	push   $0xf0107c86
f0103540:	e8 4f cb ff ff       	call   f0100094 <_panic>
	
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f0103545:	89 fb                	mov    %edi,%ebx
f0103547:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + ELFHDR->e_phnum;
f010354a:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f010354e:	c1 e6 05             	shl    $0x5,%esi
f0103551:	01 de                	add    %ebx,%esi
	//  The ph->p_filesz bytes from the ELF binary, starting at
	//  'binary + ph->p_offset', should be copied to virtual address
	//  ph->p_va.  Any remaining memory bytes should be cleared to zero.
	//  (The ELF header should have ph->p_filesz <= ph->p_memsz.)
	//  Use functions from the previous lab to allocate and map pages.
	lcr3(PADDR(e->env_pgdir));
f0103553:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103556:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103559:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010355e:	77 15                	ja     f0103575 <env_create+0x6f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103560:	50                   	push   %eax
f0103561:	68 a8 68 10 f0       	push   $0xf01068a8
f0103566:	68 6c 01 00 00       	push   $0x16c
f010356b:	68 86 7c 10 f0       	push   $0xf0107c86
f0103570:	e8 1f cb ff ff       	call   f0100094 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103575:	05 00 00 00 10       	add    $0x10000000,%eax
f010357a:	0f 22 d8             	mov    %eax,%cr3
f010357d:	eb 3d                	jmp    f01035bc <env_create+0xb6>
	//it's silly to use kern_pgdir here.
	for (; ph < eph; ph++)
		if (ph->p_type == ELF_PROG_LOAD) {
f010357f:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103582:	75 35                	jne    f01035b9 <env_create+0xb3>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103584:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103587:	8b 53 08             	mov    0x8(%ebx),%edx
f010358a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010358d:	e8 6f fc ff ff       	call   f0103201 <region_alloc>
			memset((void *)ph->p_va, 0, ph->p_memsz);
f0103592:	83 ec 04             	sub    $0x4,%esp
f0103595:	ff 73 14             	pushl  0x14(%ebx)
f0103598:	6a 00                	push   $0x0
f010359a:	ff 73 08             	pushl  0x8(%ebx)
f010359d:	e8 ba 24 00 00       	call   f0105a5c <memset>
			memcpy((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
f01035a2:	83 c4 0c             	add    $0xc,%esp
f01035a5:	ff 73 10             	pushl  0x10(%ebx)
f01035a8:	89 f8                	mov    %edi,%eax
f01035aa:	03 43 04             	add    0x4(%ebx),%eax
f01035ad:	50                   	push   %eax
f01035ae:	ff 73 08             	pushl  0x8(%ebx)
f01035b1:	e8 5b 25 00 00       	call   f0105b11 <memcpy>
f01035b6:	83 c4 10             	add    $0x10,%esp
	//  ph->p_va.  Any remaining memory bytes should be cleared to zero.
	//  (The ELF header should have ph->p_filesz <= ph->p_memsz.)
	//  Use functions from the previous lab to allocate and map pages.
	lcr3(PADDR(e->env_pgdir));
	//it's silly to use kern_pgdir here.
	for (; ph < eph; ph++)
f01035b9:	83 c3 20             	add    $0x20,%ebx
f01035bc:	39 de                	cmp    %ebx,%esi
f01035be:	77 bf                	ja     f010357f <env_create+0x79>
			// 	cprintf("region_alloc %x %x %x\n", ph->p_va, ph->p_memsz, *(int*)0x802008);
			//but I'm curious about how exactly p_memsz and p_filesz differs
			// cprintf("p_memsz: %x, p_filesz: %x\n", ph->p_memsz, ph->p_filesz);
		}
	//we can use this because kern_pgdir is a subset of e->env_pgdir
	lcr3(PADDR(kern_pgdir));
f01035c0:	a1 94 7e 22 f0       	mov    0xf0227e94,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01035c5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035ca:	77 15                	ja     f01035e1 <env_create+0xdb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035cc:	50                   	push   %eax
f01035cd:	68 a8 68 10 f0       	push   $0xf01068a8
f01035d2:	68 79 01 00 00       	push   $0x179
f01035d7:	68 86 7c 10 f0       	push   $0xf0107c86
f01035dc:	e8 b3 ca ff ff       	call   f0100094 <_panic>
f01035e1:	05 00 00 00 10       	add    $0x10000000,%eax
f01035e6:	0f 22 d8             	mov    %eax,%cr3
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
	e->env_tf.tf_eip = ELFHDR->e_entry;
f01035e9:	8b 47 18             	mov    0x18(%edi),%eax
f01035ec:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01035ef:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f01035f2:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01035f7:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01035fc:	89 f8                	mov    %edi,%eax
f01035fe:	e8 fe fb ff ff       	call   f0103201 <region_alloc>
{
	// LAB 3: Your code here.
	struct Env *penv;
	env_alloc(&penv, 0);
	load_icode(penv, binary, size);
}
f0103603:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103606:	5b                   	pop    %ebx
f0103607:	5e                   	pop    %esi
f0103608:	5f                   	pop    %edi
f0103609:	5d                   	pop    %ebp
f010360a:	c3                   	ret    

f010360b <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010360b:	55                   	push   %ebp
f010360c:	89 e5                	mov    %esp,%ebp
f010360e:	57                   	push   %edi
f010360f:	56                   	push   %esi
f0103610:	53                   	push   %ebx
f0103611:	83 ec 1c             	sub    $0x1c,%esp
f0103614:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103617:	e8 60 2a 00 00       	call   f010607c <cpunum>
f010361c:	6b c0 74             	imul   $0x74,%eax,%eax
f010361f:	39 b8 28 80 22 f0    	cmp    %edi,-0xfdd7fd8(%eax)
f0103625:	75 29                	jne    f0103650 <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f0103627:	a1 94 7e 22 f0       	mov    0xf0227e94,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010362c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103631:	77 15                	ja     f0103648 <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103633:	50                   	push   %eax
f0103634:	68 a8 68 10 f0       	push   $0xf01068a8
f0103639:	68 9f 01 00 00       	push   $0x19f
f010363e:	68 86 7c 10 f0       	push   $0xf0107c86
f0103643:	e8 4c ca ff ff       	call   f0100094 <_panic>
f0103648:	05 00 00 00 10       	add    $0x10000000,%eax
f010364d:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103650:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103653:	e8 24 2a 00 00       	call   f010607c <cpunum>
f0103658:	6b c0 74             	imul   $0x74,%eax,%eax
f010365b:	ba 00 00 00 00       	mov    $0x0,%edx
f0103660:	83 b8 28 80 22 f0 00 	cmpl   $0x0,-0xfdd7fd8(%eax)
f0103667:	74 11                	je     f010367a <env_free+0x6f>
f0103669:	e8 0e 2a 00 00       	call   f010607c <cpunum>
f010366e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103671:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f0103677:	8b 50 48             	mov    0x48(%eax),%edx
f010367a:	83 ec 04             	sub    $0x4,%esp
f010367d:	53                   	push   %ebx
f010367e:	52                   	push   %edx
f010367f:	68 b6 7c 10 f0       	push   $0xf0107cb6
f0103684:	e8 27 04 00 00       	call   f0103ab0 <cprintf>
f0103689:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010368c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103693:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103696:	89 d0                	mov    %edx,%eax
f0103698:	c1 e0 02             	shl    $0x2,%eax
f010369b:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010369e:	8b 47 60             	mov    0x60(%edi),%eax
f01036a1:	8b 34 90             	mov    (%eax,%edx,4),%esi
f01036a4:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01036aa:	0f 84 a8 00 00 00    	je     f0103758 <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01036b0:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01036b6:	89 f0                	mov    %esi,%eax
f01036b8:	c1 e8 0c             	shr    $0xc,%eax
f01036bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01036be:	39 05 90 7e 22 f0    	cmp    %eax,0xf0227e90
f01036c4:	77 15                	ja     f01036db <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01036c6:	56                   	push   %esi
f01036c7:	68 5c 68 10 f0       	push   $0xf010685c
f01036cc:	68 ae 01 00 00       	push   $0x1ae
f01036d1:	68 86 7c 10 f0       	push   $0xf0107c86
f01036d6:	e8 b9 c9 ff ff       	call   f0100094 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01036db:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01036de:	c1 e0 16             	shl    $0x16,%eax
f01036e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01036e4:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01036e9:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01036f0:	01 
f01036f1:	74 17                	je     f010370a <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01036f3:	83 ec 08             	sub    $0x8,%esp
f01036f6:	89 d8                	mov    %ebx,%eax
f01036f8:	c1 e0 0c             	shl    $0xc,%eax
f01036fb:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01036fe:	50                   	push   %eax
f01036ff:	ff 77 60             	pushl  0x60(%edi)
f0103702:	e8 89 de ff ff       	call   f0101590 <page_remove>
f0103707:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010370a:	83 c3 01             	add    $0x1,%ebx
f010370d:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103713:	75 d4                	jne    f01036e9 <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103715:	8b 47 60             	mov    0x60(%edi),%eax
f0103718:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010371b:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103722:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103725:	3b 05 90 7e 22 f0    	cmp    0xf0227e90,%eax
f010372b:	72 14                	jb     f0103741 <env_free+0x136>
		panic("pa2page called with invalid pa");
f010372d:	83 ec 04             	sub    $0x4,%esp
f0103730:	68 70 74 10 f0       	push   $0xf0107470
f0103735:	6a 51                	push   $0x51
f0103737:	68 84 6f 10 f0       	push   $0xf0106f84
f010373c:	e8 53 c9 ff ff       	call   f0100094 <_panic>
		page_decref(pa2page(pa));
f0103741:	83 ec 0c             	sub    $0xc,%esp
f0103744:	a1 98 7e 22 f0       	mov    0xf0227e98,%eax
f0103749:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010374c:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f010374f:	50                   	push   %eax
f0103750:	e8 46 dc ff ff       	call   f010139b <page_decref>
f0103755:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103758:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f010375c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010375f:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0103764:	0f 85 29 ff ff ff    	jne    f0103693 <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010376a:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010376d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103772:	77 15                	ja     f0103789 <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103774:	50                   	push   %eax
f0103775:	68 a8 68 10 f0       	push   $0xf01068a8
f010377a:	68 bc 01 00 00       	push   $0x1bc
f010377f:	68 86 7c 10 f0       	push   $0xf0107c86
f0103784:	e8 0b c9 ff ff       	call   f0100094 <_panic>
	e->env_pgdir = 0;
f0103789:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103790:	05 00 00 00 10       	add    $0x10000000,%eax
f0103795:	c1 e8 0c             	shr    $0xc,%eax
f0103798:	3b 05 90 7e 22 f0    	cmp    0xf0227e90,%eax
f010379e:	72 14                	jb     f01037b4 <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f01037a0:	83 ec 04             	sub    $0x4,%esp
f01037a3:	68 70 74 10 f0       	push   $0xf0107470
f01037a8:	6a 51                	push   $0x51
f01037aa:	68 84 6f 10 f0       	push   $0xf0106f84
f01037af:	e8 e0 c8 ff ff       	call   f0100094 <_panic>
	page_decref(pa2page(pa));
f01037b4:	83 ec 0c             	sub    $0xc,%esp
f01037b7:	8b 15 98 7e 22 f0    	mov    0xf0227e98,%edx
f01037bd:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01037c0:	50                   	push   %eax
f01037c1:	e8 d5 db ff ff       	call   f010139b <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01037c6:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01037cd:	a1 4c 72 22 f0       	mov    0xf022724c,%eax
f01037d2:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01037d5:	89 3d 4c 72 22 f0    	mov    %edi,0xf022724c
}
f01037db:	83 c4 10             	add    $0x10,%esp
f01037de:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01037e1:	5b                   	pop    %ebx
f01037e2:	5e                   	pop    %esi
f01037e3:	5f                   	pop    %edi
f01037e4:	5d                   	pop    %ebp
f01037e5:	c3                   	ret    

f01037e6 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01037e6:	55                   	push   %ebp
f01037e7:	89 e5                	mov    %esp,%ebp
f01037e9:	53                   	push   %ebx
f01037ea:	83 ec 04             	sub    $0x4,%esp
f01037ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01037f0:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01037f4:	75 19                	jne    f010380f <env_destroy+0x29>
f01037f6:	e8 81 28 00 00       	call   f010607c <cpunum>
f01037fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01037fe:	3b 98 28 80 22 f0    	cmp    -0xfdd7fd8(%eax),%ebx
f0103804:	74 09                	je     f010380f <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103806:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f010380d:	eb 33                	jmp    f0103842 <env_destroy+0x5c>
	}

	env_free(e);
f010380f:	83 ec 0c             	sub    $0xc,%esp
f0103812:	53                   	push   %ebx
f0103813:	e8 f3 fd ff ff       	call   f010360b <env_free>

	if (curenv == e) {
f0103818:	e8 5f 28 00 00       	call   f010607c <cpunum>
f010381d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103820:	83 c4 10             	add    $0x10,%esp
f0103823:	3b 98 28 80 22 f0    	cmp    -0xfdd7fd8(%eax),%ebx
f0103829:	75 17                	jne    f0103842 <env_destroy+0x5c>
		curenv = NULL;
f010382b:	e8 4c 28 00 00       	call   f010607c <cpunum>
f0103830:	6b c0 74             	imul   $0x74,%eax,%eax
f0103833:	c7 80 28 80 22 f0 00 	movl   $0x0,-0xfdd7fd8(%eax)
f010383a:	00 00 00 
		sched_yield();
f010383d:	e8 a9 10 00 00       	call   f01048eb <sched_yield>
	}
}
f0103842:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103845:	c9                   	leave  
f0103846:	c3                   	ret    

f0103847 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103847:	55                   	push   %ebp
f0103848:	89 e5                	mov    %esp,%ebp
f010384a:	53                   	push   %ebx
f010384b:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f010384e:	e8 29 28 00 00       	call   f010607c <cpunum>
f0103853:	6b c0 74             	imul   $0x74,%eax,%eax
f0103856:	8b 98 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%ebx
f010385c:	e8 1b 28 00 00       	call   f010607c <cpunum>
f0103861:	89 43 5c             	mov    %eax,0x5c(%ebx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103864:	83 ec 0c             	sub    $0xc,%esp
f0103867:	68 c0 13 12 f0       	push   $0xf01213c0
f010386c:	e8 16 2b 00 00       	call   f0106387 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103871:	f3 90                	pause  
	unlock_kernel();
	__asm __volatile("movl %0,%%esp\n"
f0103873:	8b 65 08             	mov    0x8(%ebp),%esp
f0103876:	61                   	popa   
f0103877:	07                   	pop    %es
f0103878:	1f                   	pop    %ds
f0103879:	83 c4 08             	add    $0x8,%esp
f010387c:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010387d:	83 c4 0c             	add    $0xc,%esp
f0103880:	68 cc 7c 10 f0       	push   $0xf0107ccc
f0103885:	68 f2 01 00 00       	push   $0x1f2
f010388a:	68 86 7c 10 f0       	push   $0xf0107c86
f010388f:	e8 00 c8 ff ff       	call   f0100094 <_panic>

f0103894 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103894:	55                   	push   %ebp
f0103895:	89 e5                	mov    %esp,%ebp
f0103897:	53                   	push   %ebx
f0103898:	83 ec 04             	sub    $0x4,%esp
f010389b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// cprintf("curenv: %x, e: %x\n", curenv, e);
	// cprintf("\n");
	if (curenv != e) {
f010389e:	e8 d9 27 00 00       	call   f010607c <cpunum>
f01038a3:	6b c0 74             	imul   $0x74,%eax,%eax
f01038a6:	39 98 28 80 22 f0    	cmp    %ebx,-0xfdd7fd8(%eax)
f01038ac:	74 7a                	je     f0103928 <env_run+0x94>
		if (curenv && curenv->env_status == ENV_RUNNING)
f01038ae:	e8 c9 27 00 00       	call   f010607c <cpunum>
f01038b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01038b6:	83 b8 28 80 22 f0 00 	cmpl   $0x0,-0xfdd7fd8(%eax)
f01038bd:	74 29                	je     f01038e8 <env_run+0x54>
f01038bf:	e8 b8 27 00 00       	call   f010607c <cpunum>
f01038c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01038c7:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f01038cd:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01038d1:	75 15                	jne    f01038e8 <env_run+0x54>
			curenv->env_status = ENV_RUNNABLE;
f01038d3:	e8 a4 27 00 00       	call   f010607c <cpunum>
f01038d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01038db:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f01038e1:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		curenv = e;
f01038e8:	e8 8f 27 00 00       	call   f010607c <cpunum>
f01038ed:	6b c0 74             	imul   $0x74,%eax,%eax
f01038f0:	89 98 28 80 22 f0    	mov    %ebx,-0xfdd7fd8(%eax)
		e->env_status = ENV_RUNNING;
f01038f6:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
		e->env_runs++;
f01038fd:	83 43 58 01          	addl   $0x1,0x58(%ebx)
		lcr3(PADDR(e->env_pgdir));
f0103901:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103904:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103909:	77 15                	ja     f0103920 <env_run+0x8c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010390b:	50                   	push   %eax
f010390c:	68 a8 68 10 f0       	push   $0xf01068a8
f0103911:	68 18 02 00 00       	push   $0x218
f0103916:	68 86 7c 10 f0       	push   $0xf0107c86
f010391b:	e8 74 c7 ff ff       	call   f0100094 <_panic>
f0103920:	05 00 00 00 10       	add    $0x10000000,%eax
f0103925:	0f 22 d8             	mov    %eax,%cr3
	}
	
	env_pop_tf(&e->env_tf);
f0103928:	83 ec 0c             	sub    $0xc,%esp
f010392b:	53                   	push   %ebx
f010392c:	e8 16 ff ff ff       	call   f0103847 <env_pop_tf>

f0103931 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103931:	55                   	push   %ebp
f0103932:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103934:	ba 70 00 00 00       	mov    $0x70,%edx
f0103939:	8b 45 08             	mov    0x8(%ebp),%eax
f010393c:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010393d:	ba 71 00 00 00       	mov    $0x71,%edx
f0103942:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103943:	0f b6 c0             	movzbl %al,%eax
}
f0103946:	5d                   	pop    %ebp
f0103947:	c3                   	ret    

f0103948 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103948:	55                   	push   %ebp
f0103949:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010394b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103950:	8b 45 08             	mov    0x8(%ebp),%eax
f0103953:	ee                   	out    %al,(%dx)
f0103954:	ba 71 00 00 00       	mov    $0x71,%edx
f0103959:	8b 45 0c             	mov    0xc(%ebp),%eax
f010395c:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010395d:	5d                   	pop    %ebp
f010395e:	c3                   	ret    

f010395f <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010395f:	55                   	push   %ebp
f0103960:	89 e5                	mov    %esp,%ebp
f0103962:	56                   	push   %esi
f0103963:	53                   	push   %ebx
f0103964:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103967:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f010396d:	80 3d 50 72 22 f0 00 	cmpb   $0x0,0xf0227250
f0103974:	74 5a                	je     f01039d0 <irq_setmask_8259A+0x71>
f0103976:	89 c6                	mov    %eax,%esi
f0103978:	ba 21 00 00 00       	mov    $0x21,%edx
f010397d:	ee                   	out    %al,(%dx)
f010397e:	66 c1 e8 08          	shr    $0x8,%ax
f0103982:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103987:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103988:	83 ec 0c             	sub    $0xc,%esp
f010398b:	68 d8 7c 10 f0       	push   $0xf0107cd8
f0103990:	e8 1b 01 00 00       	call   f0103ab0 <cprintf>
f0103995:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103998:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f010399d:	0f b7 f6             	movzwl %si,%esi
f01039a0:	f7 d6                	not    %esi
f01039a2:	0f a3 de             	bt     %ebx,%esi
f01039a5:	73 11                	jae    f01039b8 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f01039a7:	83 ec 08             	sub    $0x8,%esp
f01039aa:	53                   	push   %ebx
f01039ab:	68 b7 81 10 f0       	push   $0xf01081b7
f01039b0:	e8 fb 00 00 00       	call   f0103ab0 <cprintf>
f01039b5:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f01039b8:	83 c3 01             	add    $0x1,%ebx
f01039bb:	83 fb 10             	cmp    $0x10,%ebx
f01039be:	75 e2                	jne    f01039a2 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f01039c0:	83 ec 0c             	sub    $0xc,%esp
f01039c3:	68 c2 67 10 f0       	push   $0xf01067c2
f01039c8:	e8 e3 00 00 00       	call   f0103ab0 <cprintf>
f01039cd:	83 c4 10             	add    $0x10,%esp
}
f01039d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01039d3:	5b                   	pop    %ebx
f01039d4:	5e                   	pop    %esi
f01039d5:	5d                   	pop    %ebp
f01039d6:	c3                   	ret    

f01039d7 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f01039d7:	c6 05 50 72 22 f0 01 	movb   $0x1,0xf0227250
f01039de:	ba 21 00 00 00       	mov    $0x21,%edx
f01039e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01039e8:	ee                   	out    %al,(%dx)
f01039e9:	ba a1 00 00 00       	mov    $0xa1,%edx
f01039ee:	ee                   	out    %al,(%dx)
f01039ef:	ba 20 00 00 00       	mov    $0x20,%edx
f01039f4:	b8 11 00 00 00       	mov    $0x11,%eax
f01039f9:	ee                   	out    %al,(%dx)
f01039fa:	ba 21 00 00 00       	mov    $0x21,%edx
f01039ff:	b8 20 00 00 00       	mov    $0x20,%eax
f0103a04:	ee                   	out    %al,(%dx)
f0103a05:	b8 04 00 00 00       	mov    $0x4,%eax
f0103a0a:	ee                   	out    %al,(%dx)
f0103a0b:	b8 03 00 00 00       	mov    $0x3,%eax
f0103a10:	ee                   	out    %al,(%dx)
f0103a11:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103a16:	b8 11 00 00 00       	mov    $0x11,%eax
f0103a1b:	ee                   	out    %al,(%dx)
f0103a1c:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103a21:	b8 28 00 00 00       	mov    $0x28,%eax
f0103a26:	ee                   	out    %al,(%dx)
f0103a27:	b8 02 00 00 00       	mov    $0x2,%eax
f0103a2c:	ee                   	out    %al,(%dx)
f0103a2d:	b8 01 00 00 00       	mov    $0x1,%eax
f0103a32:	ee                   	out    %al,(%dx)
f0103a33:	ba 20 00 00 00       	mov    $0x20,%edx
f0103a38:	b8 68 00 00 00       	mov    $0x68,%eax
f0103a3d:	ee                   	out    %al,(%dx)
f0103a3e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103a43:	ee                   	out    %al,(%dx)
f0103a44:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103a49:	b8 68 00 00 00       	mov    $0x68,%eax
f0103a4e:	ee                   	out    %al,(%dx)
f0103a4f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103a54:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103a55:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f0103a5c:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103a60:	74 13                	je     f0103a75 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103a62:	55                   	push   %ebp
f0103a63:	89 e5                	mov    %esp,%ebp
f0103a65:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103a68:	0f b7 c0             	movzwl %ax,%eax
f0103a6b:	50                   	push   %eax
f0103a6c:	e8 ee fe ff ff       	call   f010395f <irq_setmask_8259A>
f0103a71:	83 c4 10             	add    $0x10,%esp
}
f0103a74:	c9                   	leave  
f0103a75:	f3 c3                	repz ret 

f0103a77 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103a77:	55                   	push   %ebp
f0103a78:	89 e5                	mov    %esp,%ebp
f0103a7a:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103a7d:	ff 75 08             	pushl  0x8(%ebp)
f0103a80:	e8 ee cd ff ff       	call   f0100873 <cputchar>
	*cnt++;
}
f0103a85:	83 c4 10             	add    $0x10,%esp
f0103a88:	c9                   	leave  
f0103a89:	c3                   	ret    

f0103a8a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103a8a:	55                   	push   %ebp
f0103a8b:	89 e5                	mov    %esp,%ebp
f0103a8d:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103a90:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103a97:	ff 75 0c             	pushl  0xc(%ebp)
f0103a9a:	ff 75 08             	pushl  0x8(%ebp)
f0103a9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103aa0:	50                   	push   %eax
f0103aa1:	68 77 3a 10 f0       	push   $0xf0103a77
f0103aa6:	e8 ff 18 00 00       	call   f01053aa <vprintfmt>
	return cnt;
}
f0103aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103aae:	c9                   	leave  
f0103aaf:	c3                   	ret    

f0103ab0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103ab0:	55                   	push   %ebp
f0103ab1:	89 e5                	mov    %esp,%ebp
f0103ab3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103ab6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103ab9:	50                   	push   %eax
f0103aba:	ff 75 08             	pushl  0x8(%ebp)
f0103abd:	e8 c8 ff ff ff       	call   f0103a8a <vcprintf>
	va_end(ap);

	return cnt;
}
f0103ac2:	c9                   	leave  
f0103ac3:	c3                   	ret    

f0103ac4 <trap_init_percpu>:
	trap_init_percpu();
}
// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103ac4:	55                   	push   %ebp
f0103ac5:	89 e5                	mov    %esp,%ebp
f0103ac7:	57                   	push   %edi
f0103ac8:	56                   	push   %esi
f0103ac9:	53                   	push   %ebx
f0103aca:	83 ec 0c             	sub    $0xc,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	int cid = thiscpu->cpu_id;
f0103acd:	e8 aa 25 00 00       	call   f010607c <cpunum>
f0103ad2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ad5:	0f b6 98 20 80 22 f0 	movzbl -0xfdd7fe0(%eax),%ebx

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cid * (KSTKSIZE + KSTKGAP);
f0103adc:	e8 9b 25 00 00       	call   f010607c <cpunum>
f0103ae1:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ae4:	89 d9                	mov    %ebx,%ecx
f0103ae6:	c1 e1 10             	shl    $0x10,%ecx
f0103ae9:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0103aee:	29 ca                	sub    %ecx,%edx
f0103af0:	89 90 30 80 22 f0    	mov    %edx,-0xfdd7fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103af6:	e8 81 25 00 00       	call   f010607c <cpunum>
f0103afb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103afe:	66 c7 80 34 80 22 f0 	movw   $0x10,-0xfdd7fcc(%eax)
f0103b05:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3)+cid] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0103b07:	83 c3 05             	add    $0x5,%ebx
f0103b0a:	e8 6d 25 00 00       	call   f010607c <cpunum>
f0103b0f:	89 c7                	mov    %eax,%edi
f0103b11:	e8 66 25 00 00       	call   f010607c <cpunum>
f0103b16:	89 c6                	mov    %eax,%esi
f0103b18:	e8 5f 25 00 00       	call   f010607c <cpunum>
f0103b1d:	66 c7 04 dd 40 13 12 	movw   $0x68,-0xfedecc0(,%ebx,8)
f0103b24:	f0 68 00 
f0103b27:	6b ff 74             	imul   $0x74,%edi,%edi
f0103b2a:	81 c7 2c 80 22 f0    	add    $0xf022802c,%edi
f0103b30:	66 89 3c dd 42 13 12 	mov    %di,-0xfedecbe(,%ebx,8)
f0103b37:	f0 
f0103b38:	6b d6 74             	imul   $0x74,%esi,%edx
f0103b3b:	81 c2 2c 80 22 f0    	add    $0xf022802c,%edx
f0103b41:	c1 ea 10             	shr    $0x10,%edx
f0103b44:	88 14 dd 44 13 12 f0 	mov    %dl,-0xfedecbc(,%ebx,8)
f0103b4b:	c6 04 dd 46 13 12 f0 	movb   $0x40,-0xfedecba(,%ebx,8)
f0103b52:	40 
f0103b53:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b56:	05 2c 80 22 f0       	add    $0xf022802c,%eax
f0103b5b:	c1 e8 18             	shr    $0x18,%eax
f0103b5e:	88 04 dd 47 13 12 f0 	mov    %al,-0xfedecb9(,%ebx,8)
					sizeof(struct Taskstate), 0);
	gdt[(GD_TSS0 >> 3)+cid].sd_s = 0;
f0103b65:	c6 04 dd 45 13 12 f0 	movb   $0x89,-0xfedecbb(,%ebx,8)
f0103b6c:	89 
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103b6d:	c1 e3 03             	shl    $0x3,%ebx
f0103b70:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103b73:	b8 ac 13 12 f0       	mov    $0xf01213ac,%eax
f0103b78:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0+8*cid);

	// Load the IDT
	lidt(&idt_pd);
}
f0103b7b:	83 c4 0c             	add    $0xc,%esp
f0103b7e:	5b                   	pop    %ebx
f0103b7f:	5e                   	pop    %esi
f0103b80:	5f                   	pop    %edi
f0103b81:	5d                   	pop    %ebp
f0103b82:	c3                   	ret    

f0103b83 <trap_init>:
	void i47();
void i48();

void
trap_init(void)
{
f0103b83:	55                   	push   %ebp
f0103b84:	89 e5                	mov    %esp,%ebp
f0103b86:	83 ec 08             	sub    $0x8,%esp
	// LAB 3: Your code here.
	
	SETGATE(idt[0], 0, GD_KT, i0, 0);
f0103b89:	b8 56 46 10 f0       	mov    $0xf0104656,%eax
f0103b8e:	66 a3 60 72 22 f0    	mov    %ax,0xf0227260
f0103b94:	66 c7 05 62 72 22 f0 	movw   $0x8,0xf0227262
f0103b9b:	08 00 
f0103b9d:	c6 05 64 72 22 f0 00 	movb   $0x0,0xf0227264
f0103ba4:	c6 05 65 72 22 f0 8e 	movb   $0x8e,0xf0227265
f0103bab:	c1 e8 10             	shr    $0x10,%eax
f0103bae:	66 a3 66 72 22 f0    	mov    %ax,0xf0227266
	    SETGATE(idt[1], 0, GD_KT, i1, 0);
f0103bb4:	b8 60 46 10 f0       	mov    $0xf0104660,%eax
f0103bb9:	66 a3 68 72 22 f0    	mov    %ax,0xf0227268
f0103bbf:	66 c7 05 6a 72 22 f0 	movw   $0x8,0xf022726a
f0103bc6:	08 00 
f0103bc8:	c6 05 6c 72 22 f0 00 	movb   $0x0,0xf022726c
f0103bcf:	c6 05 6d 72 22 f0 8e 	movb   $0x8e,0xf022726d
f0103bd6:	c1 e8 10             	shr    $0x10,%eax
f0103bd9:	66 a3 6e 72 22 f0    	mov    %ax,0xf022726e
	    SETGATE(idt[3], 0, GD_KT, i3, 3);
f0103bdf:	b8 74 46 10 f0       	mov    $0xf0104674,%eax
f0103be4:	66 a3 78 72 22 f0    	mov    %ax,0xf0227278
f0103bea:	66 c7 05 7a 72 22 f0 	movw   $0x8,0xf022727a
f0103bf1:	08 00 
f0103bf3:	c6 05 7c 72 22 f0 00 	movb   $0x0,0xf022727c
f0103bfa:	c6 05 7d 72 22 f0 ee 	movb   $0xee,0xf022727d
f0103c01:	c1 e8 10             	shr    $0x10,%eax
f0103c04:	66 a3 7e 72 22 f0    	mov    %ax,0xf022727e
	    SETGATE(idt[4], 0, GD_KT, i4, 0);
f0103c0a:	b8 7e 46 10 f0       	mov    $0xf010467e,%eax
f0103c0f:	66 a3 80 72 22 f0    	mov    %ax,0xf0227280
f0103c15:	66 c7 05 82 72 22 f0 	movw   $0x8,0xf0227282
f0103c1c:	08 00 
f0103c1e:	c6 05 84 72 22 f0 00 	movb   $0x0,0xf0227284
f0103c25:	c6 05 85 72 22 f0 8e 	movb   $0x8e,0xf0227285
f0103c2c:	c1 e8 10             	shr    $0x10,%eax
f0103c2f:	66 a3 86 72 22 f0    	mov    %ax,0xf0227286
	    SETGATE(idt[5], 0, GD_KT, i5, 0);
f0103c35:	b8 88 46 10 f0       	mov    $0xf0104688,%eax
f0103c3a:	66 a3 88 72 22 f0    	mov    %ax,0xf0227288
f0103c40:	66 c7 05 8a 72 22 f0 	movw   $0x8,0xf022728a
f0103c47:	08 00 
f0103c49:	c6 05 8c 72 22 f0 00 	movb   $0x0,0xf022728c
f0103c50:	c6 05 8d 72 22 f0 8e 	movb   $0x8e,0xf022728d
f0103c57:	c1 e8 10             	shr    $0x10,%eax
f0103c5a:	66 a3 8e 72 22 f0    	mov    %ax,0xf022728e
	    SETGATE(idt[6], 0, GD_KT, i6, 0);
f0103c60:	b8 92 46 10 f0       	mov    $0xf0104692,%eax
f0103c65:	66 a3 90 72 22 f0    	mov    %ax,0xf0227290
f0103c6b:	66 c7 05 92 72 22 f0 	movw   $0x8,0xf0227292
f0103c72:	08 00 
f0103c74:	c6 05 94 72 22 f0 00 	movb   $0x0,0xf0227294
f0103c7b:	c6 05 95 72 22 f0 8e 	movb   $0x8e,0xf0227295
f0103c82:	c1 e8 10             	shr    $0x10,%eax
f0103c85:	66 a3 96 72 22 f0    	mov    %ax,0xf0227296
	    SETGATE(idt[7], 0, GD_KT, i7, 0);
f0103c8b:	b8 9c 46 10 f0       	mov    $0xf010469c,%eax
f0103c90:	66 a3 98 72 22 f0    	mov    %ax,0xf0227298
f0103c96:	66 c7 05 9a 72 22 f0 	movw   $0x8,0xf022729a
f0103c9d:	08 00 
f0103c9f:	c6 05 9c 72 22 f0 00 	movb   $0x0,0xf022729c
f0103ca6:	c6 05 9d 72 22 f0 8e 	movb   $0x8e,0xf022729d
f0103cad:	c1 e8 10             	shr    $0x10,%eax
f0103cb0:	66 a3 9e 72 22 f0    	mov    %ax,0xf022729e
	    SETGATE(idt[8], 0, GD_KT, i8, 0);
f0103cb6:	b8 a6 46 10 f0       	mov    $0xf01046a6,%eax
f0103cbb:	66 a3 a0 72 22 f0    	mov    %ax,0xf02272a0
f0103cc1:	66 c7 05 a2 72 22 f0 	movw   $0x8,0xf02272a2
f0103cc8:	08 00 
f0103cca:	c6 05 a4 72 22 f0 00 	movb   $0x0,0xf02272a4
f0103cd1:	c6 05 a5 72 22 f0 8e 	movb   $0x8e,0xf02272a5
f0103cd8:	c1 e8 10             	shr    $0x10,%eax
f0103cdb:	66 a3 a6 72 22 f0    	mov    %ax,0xf02272a6
	    SETGATE(idt[9], 0, GD_KT, i9, 0);
f0103ce1:	b8 ae 46 10 f0       	mov    $0xf01046ae,%eax
f0103ce6:	66 a3 a8 72 22 f0    	mov    %ax,0xf02272a8
f0103cec:	66 c7 05 aa 72 22 f0 	movw   $0x8,0xf02272aa
f0103cf3:	08 00 
f0103cf5:	c6 05 ac 72 22 f0 00 	movb   $0x0,0xf02272ac
f0103cfc:	c6 05 ad 72 22 f0 8e 	movb   $0x8e,0xf02272ad
f0103d03:	c1 e8 10             	shr    $0x10,%eax
f0103d06:	66 a3 ae 72 22 f0    	mov    %ax,0xf02272ae
	    SETGATE(idt[10],0, GD_KT,i10, 0);
f0103d0c:	b8 b8 46 10 f0       	mov    $0xf01046b8,%eax
f0103d11:	66 a3 b0 72 22 f0    	mov    %ax,0xf02272b0
f0103d17:	66 c7 05 b2 72 22 f0 	movw   $0x8,0xf02272b2
f0103d1e:	08 00 
f0103d20:	c6 05 b4 72 22 f0 00 	movb   $0x0,0xf02272b4
f0103d27:	c6 05 b5 72 22 f0 8e 	movb   $0x8e,0xf02272b5
f0103d2e:	c1 e8 10             	shr    $0x10,%eax
f0103d31:	66 a3 b6 72 22 f0    	mov    %ax,0xf02272b6
	    SETGATE(idt[11], 0, GD_KT, i11, 0);
f0103d37:	b8 c0 46 10 f0       	mov    $0xf01046c0,%eax
f0103d3c:	66 a3 b8 72 22 f0    	mov    %ax,0xf02272b8
f0103d42:	66 c7 05 ba 72 22 f0 	movw   $0x8,0xf02272ba
f0103d49:	08 00 
f0103d4b:	c6 05 bc 72 22 f0 00 	movb   $0x0,0xf02272bc
f0103d52:	c6 05 bd 72 22 f0 8e 	movb   $0x8e,0xf02272bd
f0103d59:	c1 e8 10             	shr    $0x10,%eax
f0103d5c:	66 a3 be 72 22 f0    	mov    %ax,0xf02272be
	    SETGATE(idt[12], 0, GD_KT, i12, 0);
f0103d62:	b8 c8 46 10 f0       	mov    $0xf01046c8,%eax
f0103d67:	66 a3 c0 72 22 f0    	mov    %ax,0xf02272c0
f0103d6d:	66 c7 05 c2 72 22 f0 	movw   $0x8,0xf02272c2
f0103d74:	08 00 
f0103d76:	c6 05 c4 72 22 f0 00 	movb   $0x0,0xf02272c4
f0103d7d:	c6 05 c5 72 22 f0 8e 	movb   $0x8e,0xf02272c5
f0103d84:	c1 e8 10             	shr    $0x10,%eax
f0103d87:	66 a3 c6 72 22 f0    	mov    %ax,0xf02272c6
	    SETGATE(idt[13], 0, GD_KT, i13, 0);
f0103d8d:	b8 d0 46 10 f0       	mov    $0xf01046d0,%eax
f0103d92:	66 a3 c8 72 22 f0    	mov    %ax,0xf02272c8
f0103d98:	66 c7 05 ca 72 22 f0 	movw   $0x8,0xf02272ca
f0103d9f:	08 00 
f0103da1:	c6 05 cc 72 22 f0 00 	movb   $0x0,0xf02272cc
f0103da8:	c6 05 cd 72 22 f0 8e 	movb   $0x8e,0xf02272cd
f0103daf:	c1 e8 10             	shr    $0x10,%eax
f0103db2:	66 a3 ce 72 22 f0    	mov    %ax,0xf02272ce
	    SETGATE(idt[14], 0, GD_KT, i14, 0);
f0103db8:	b8 d8 46 10 f0       	mov    $0xf01046d8,%eax
f0103dbd:	66 a3 d0 72 22 f0    	mov    %ax,0xf02272d0
f0103dc3:	66 c7 05 d2 72 22 f0 	movw   $0x8,0xf02272d2
f0103dca:	08 00 
f0103dcc:	c6 05 d4 72 22 f0 00 	movb   $0x0,0xf02272d4
f0103dd3:	c6 05 d5 72 22 f0 8e 	movb   $0x8e,0xf02272d5
f0103dda:	c1 e8 10             	shr    $0x10,%eax
f0103ddd:	66 a3 d6 72 22 f0    	mov    %ax,0xf02272d6
	    SETGATE(idt[16], 0, GD_KT, i16, 0);
f0103de3:	b8 ea 46 10 f0       	mov    $0xf01046ea,%eax
f0103de8:	66 a3 e0 72 22 f0    	mov    %ax,0xf02272e0
f0103dee:	66 c7 05 e2 72 22 f0 	movw   $0x8,0xf02272e2
f0103df5:	08 00 
f0103df7:	c6 05 e4 72 22 f0 00 	movb   $0x0,0xf02272e4
f0103dfe:	c6 05 e5 72 22 f0 8e 	movb   $0x8e,0xf02272e5
f0103e05:	c1 e8 10             	shr    $0x10,%eax
f0103e08:	66 a3 e6 72 22 f0    	mov    %ax,0xf02272e6
	    	


            SETGATE(idt[IRQ_OFFSET+0], 0, GD_KT, i32, 0);
f0103e0e:	b8 74 47 10 f0       	mov    $0xf0104774,%eax
f0103e13:	66 a3 60 73 22 f0    	mov    %ax,0xf0227360
f0103e19:	66 c7 05 62 73 22 f0 	movw   $0x8,0xf0227362
f0103e20:	08 00 
f0103e22:	c6 05 64 73 22 f0 00 	movb   $0x0,0xf0227364
f0103e29:	c6 05 65 73 22 f0 8e 	movb   $0x8e,0xf0227365
f0103e30:	c1 e8 10             	shr    $0x10,%eax
f0103e33:	66 a3 66 73 22 f0    	mov    %ax,0xf0227366
	    SETGATE(idt[IRQ_OFFSET+1], 0, GD_KT, i33, 0);
f0103e39:	b8 7a 47 10 f0       	mov    $0xf010477a,%eax
f0103e3e:	66 a3 68 73 22 f0    	mov    %ax,0xf0227368
f0103e44:	66 c7 05 6a 73 22 f0 	movw   $0x8,0xf022736a
f0103e4b:	08 00 
f0103e4d:	c6 05 6c 73 22 f0 00 	movb   $0x0,0xf022736c
f0103e54:	c6 05 6d 73 22 f0 8e 	movb   $0x8e,0xf022736d
f0103e5b:	c1 e8 10             	shr    $0x10,%eax
f0103e5e:	66 a3 6e 73 22 f0    	mov    %ax,0xf022736e
	    SETGATE(idt[IRQ_OFFSET+2], 0, GD_KT, i34, 0);
f0103e64:	b8 80 47 10 f0       	mov    $0xf0104780,%eax
f0103e69:	66 a3 70 73 22 f0    	mov    %ax,0xf0227370
f0103e6f:	66 c7 05 72 73 22 f0 	movw   $0x8,0xf0227372
f0103e76:	08 00 
f0103e78:	c6 05 74 73 22 f0 00 	movb   $0x0,0xf0227374
f0103e7f:	c6 05 75 73 22 f0 8e 	movb   $0x8e,0xf0227375
f0103e86:	c1 e8 10             	shr    $0x10,%eax
f0103e89:	66 a3 76 73 22 f0    	mov    %ax,0xf0227376
	    SETGATE(idt[IRQ_OFFSET+3], 0, GD_KT, i35, 0);
f0103e8f:	b8 86 47 10 f0       	mov    $0xf0104786,%eax
f0103e94:	66 a3 78 73 22 f0    	mov    %ax,0xf0227378
f0103e9a:	66 c7 05 7a 73 22 f0 	movw   $0x8,0xf022737a
f0103ea1:	08 00 
f0103ea3:	c6 05 7c 73 22 f0 00 	movb   $0x0,0xf022737c
f0103eaa:	c6 05 7d 73 22 f0 8e 	movb   $0x8e,0xf022737d
f0103eb1:	c1 e8 10             	shr    $0x10,%eax
f0103eb4:	66 a3 7e 73 22 f0    	mov    %ax,0xf022737e
	    
	    SETGATE(idt[IRQ_OFFSET+4], 0, GD_KT, i36, 0);
f0103eba:	b8 8c 47 10 f0       	mov    $0xf010478c,%eax
f0103ebf:	66 a3 80 73 22 f0    	mov    %ax,0xf0227380
f0103ec5:	66 c7 05 82 73 22 f0 	movw   $0x8,0xf0227382
f0103ecc:	08 00 
f0103ece:	c6 05 84 73 22 f0 00 	movb   $0x0,0xf0227384
f0103ed5:	c6 05 85 73 22 f0 8e 	movb   $0x8e,0xf0227385
f0103edc:	c1 e8 10             	shr    $0x10,%eax
f0103edf:	66 a3 86 73 22 f0    	mov    %ax,0xf0227386
	    SETGATE(idt[IRQ_OFFSET+5], 0, GD_KT, i37, 0);
f0103ee5:	b8 92 47 10 f0       	mov    $0xf0104792,%eax
f0103eea:	66 a3 88 73 22 f0    	mov    %ax,0xf0227388
f0103ef0:	66 c7 05 8a 73 22 f0 	movw   $0x8,0xf022738a
f0103ef7:	08 00 
f0103ef9:	c6 05 8c 73 22 f0 00 	movb   $0x0,0xf022738c
f0103f00:	c6 05 8d 73 22 f0 8e 	movb   $0x8e,0xf022738d
f0103f07:	c1 e8 10             	shr    $0x10,%eax
f0103f0a:	66 a3 8e 73 22 f0    	mov    %ax,0xf022738e
	    SETGATE(idt[IRQ_OFFSET+6], 0, GD_KT, i38, 0);
f0103f10:	b8 98 47 10 f0       	mov    $0xf0104798,%eax
f0103f15:	66 a3 90 73 22 f0    	mov    %ax,0xf0227390
f0103f1b:	66 c7 05 92 73 22 f0 	movw   $0x8,0xf0227392
f0103f22:	08 00 
f0103f24:	c6 05 94 73 22 f0 00 	movb   $0x0,0xf0227394
f0103f2b:	c6 05 95 73 22 f0 8e 	movb   $0x8e,0xf0227395
f0103f32:	c1 e8 10             	shr    $0x10,%eax
f0103f35:	66 a3 96 73 22 f0    	mov    %ax,0xf0227396
	    SETGATE(idt[IRQ_OFFSET+7], 0, GD_KT, i39, 0);
f0103f3b:	b8 9e 47 10 f0       	mov    $0xf010479e,%eax
f0103f40:	66 a3 98 73 22 f0    	mov    %ax,0xf0227398
f0103f46:	66 c7 05 9a 73 22 f0 	movw   $0x8,0xf022739a
f0103f4d:	08 00 
f0103f4f:	c6 05 9c 73 22 f0 00 	movb   $0x0,0xf022739c
f0103f56:	c6 05 9d 73 22 f0 8e 	movb   $0x8e,0xf022739d
f0103f5d:	c1 e8 10             	shr    $0x10,%eax
f0103f60:	66 a3 9e 73 22 f0    	mov    %ax,0xf022739e
	    SETGATE(idt[IRQ_OFFSET+8], 0, GD_KT,i40, 0);
f0103f66:	b8 a4 47 10 f0       	mov    $0xf01047a4,%eax
f0103f6b:	66 a3 a0 73 22 f0    	mov    %ax,0xf02273a0
f0103f71:	66 c7 05 a2 73 22 f0 	movw   $0x8,0xf02273a2
f0103f78:	08 00 
f0103f7a:	c6 05 a4 73 22 f0 00 	movb   $0x0,0xf02273a4
f0103f81:	c6 05 a5 73 22 f0 8e 	movb   $0x8e,0xf02273a5
f0103f88:	c1 e8 10             	shr    $0x10,%eax
f0103f8b:	66 a3 a6 73 22 f0    	mov    %ax,0xf02273a6
	    SETGATE(idt[IRQ_OFFSET+9], 0, GD_KT, i41, 0);
f0103f91:	b8 aa 47 10 f0       	mov    $0xf01047aa,%eax
f0103f96:	66 a3 a8 73 22 f0    	mov    %ax,0xf02273a8
f0103f9c:	66 c7 05 aa 73 22 f0 	movw   $0x8,0xf02273aa
f0103fa3:	08 00 
f0103fa5:	c6 05 ac 73 22 f0 00 	movb   $0x0,0xf02273ac
f0103fac:	c6 05 ad 73 22 f0 8e 	movb   $0x8e,0xf02273ad
f0103fb3:	c1 e8 10             	shr    $0x10,%eax
f0103fb6:	66 a3 ae 73 22 f0    	mov    %ax,0xf02273ae
	    SETGATE(idt[IRQ_OFFSET+10], 0, GD_KT, i42, 0);
f0103fbc:	b8 b0 47 10 f0       	mov    $0xf01047b0,%eax
f0103fc1:	66 a3 b0 73 22 f0    	mov    %ax,0xf02273b0
f0103fc7:	66 c7 05 b2 73 22 f0 	movw   $0x8,0xf02273b2
f0103fce:	08 00 
f0103fd0:	c6 05 b4 73 22 f0 00 	movb   $0x0,0xf02273b4
f0103fd7:	c6 05 b5 73 22 f0 8e 	movb   $0x8e,0xf02273b5
f0103fde:	c1 e8 10             	shr    $0x10,%eax
f0103fe1:	66 a3 b6 73 22 f0    	mov    %ax,0xf02273b6
	    SETGATE(idt[IRQ_OFFSET+11], 0, GD_KT, i43, 0);
f0103fe7:	b8 b6 47 10 f0       	mov    $0xf01047b6,%eax
f0103fec:	66 a3 b8 73 22 f0    	mov    %ax,0xf02273b8
f0103ff2:	66 c7 05 ba 73 22 f0 	movw   $0x8,0xf02273ba
f0103ff9:	08 00 
f0103ffb:	c6 05 bc 73 22 f0 00 	movb   $0x0,0xf02273bc
f0104002:	c6 05 bd 73 22 f0 8e 	movb   $0x8e,0xf02273bd
f0104009:	c1 e8 10             	shr    $0x10,%eax
f010400c:	66 a3 be 73 22 f0    	mov    %ax,0xf02273be
	    SETGATE(idt[IRQ_OFFSET+12], 0, GD_KT, i44, 0);
f0104012:	b8 bc 47 10 f0       	mov    $0xf01047bc,%eax
f0104017:	66 a3 c0 73 22 f0    	mov    %ax,0xf02273c0
f010401d:	66 c7 05 c2 73 22 f0 	movw   $0x8,0xf02273c2
f0104024:	08 00 
f0104026:	c6 05 c4 73 22 f0 00 	movb   $0x0,0xf02273c4
f010402d:	c6 05 c5 73 22 f0 8e 	movb   $0x8e,0xf02273c5
f0104034:	c1 e8 10             	shr    $0x10,%eax
f0104037:	66 a3 c6 73 22 f0    	mov    %ax,0xf02273c6
	    SETGATE(idt[IRQ_OFFSET+13], 0, GD_KT, i45, 0);
f010403d:	b8 c2 47 10 f0       	mov    $0xf01047c2,%eax
f0104042:	66 a3 c8 73 22 f0    	mov    %ax,0xf02273c8
f0104048:	66 c7 05 ca 73 22 f0 	movw   $0x8,0xf02273ca
f010404f:	08 00 
f0104051:	c6 05 cc 73 22 f0 00 	movb   $0x0,0xf02273cc
f0104058:	c6 05 cd 73 22 f0 8e 	movb   $0x8e,0xf02273cd
f010405f:	c1 e8 10             	shr    $0x10,%eax
f0104062:	66 a3 ce 73 22 f0    	mov    %ax,0xf02273ce
	    SETGATE(idt[IRQ_OFFSET+14], 0, GD_KT, i46, 0);
f0104068:	b8 c8 47 10 f0       	mov    $0xf01047c8,%eax
f010406d:	66 a3 d0 73 22 f0    	mov    %ax,0xf02273d0
f0104073:	66 c7 05 d2 73 22 f0 	movw   $0x8,0xf02273d2
f010407a:	08 00 
f010407c:	c6 05 d4 73 22 f0 00 	movb   $0x0,0xf02273d4
f0104083:	c6 05 d5 73 22 f0 8e 	movb   $0x8e,0xf02273d5
f010408a:	c1 e8 10             	shr    $0x10,%eax
f010408d:	66 a3 d6 73 22 f0    	mov    %ax,0xf02273d6
	    SETGATE(idt[IRQ_OFFSET+15], 0, GD_KT, i47, 0);	
f0104093:	b8 ce 47 10 f0       	mov    $0xf01047ce,%eax
f0104098:	66 a3 d8 73 22 f0    	mov    %ax,0xf02273d8
f010409e:	66 c7 05 da 73 22 f0 	movw   $0x8,0xf02273da
f01040a5:	08 00 
f01040a7:	c6 05 dc 73 22 f0 00 	movb   $0x0,0xf02273dc
f01040ae:	c6 05 dd 73 22 f0 8e 	movb   $0x8e,0xf02273dd
f01040b5:	c1 e8 10             	shr    $0x10,%eax
f01040b8:	66 a3 de 73 22 f0    	mov    %ax,0xf02273de
	    SETGATE(idt[48], 0, GD_KT, i48, 3);
f01040be:	b8 d4 47 10 f0       	mov    $0xf01047d4,%eax
f01040c3:	66 a3 e0 73 22 f0    	mov    %ax,0xf02273e0
f01040c9:	66 c7 05 e2 73 22 f0 	movw   $0x8,0xf02273e2
f01040d0:	08 00 
f01040d2:	c6 05 e4 73 22 f0 00 	movb   $0x0,0xf02273e4
f01040d9:	c6 05 e5 73 22 f0 ee 	movb   $0xee,0xf02273e5
f01040e0:	c1 e8 10             	shr    $0x10,%eax
f01040e3:	66 a3 e6 73 22 f0    	mov    %ax,0xf02273e6

	// Per-CPU setup 
	trap_init_percpu();
f01040e9:	e8 d6 f9 ff ff       	call   f0103ac4 <trap_init_percpu>
}
f01040ee:	c9                   	leave  
f01040ef:	c3                   	ret    

f01040f0 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01040f0:	55                   	push   %ebp
f01040f1:	89 e5                	mov    %esp,%ebp
f01040f3:	53                   	push   %ebx
f01040f4:	83 ec 0c             	sub    $0xc,%esp
f01040f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01040fa:	ff 33                	pushl  (%ebx)
f01040fc:	68 ec 7c 10 f0       	push   $0xf0107cec
f0104101:	e8 aa f9 ff ff       	call   f0103ab0 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104106:	83 c4 08             	add    $0x8,%esp
f0104109:	ff 73 04             	pushl  0x4(%ebx)
f010410c:	68 fb 7c 10 f0       	push   $0xf0107cfb
f0104111:	e8 9a f9 ff ff       	call   f0103ab0 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104116:	83 c4 08             	add    $0x8,%esp
f0104119:	ff 73 08             	pushl  0x8(%ebx)
f010411c:	68 0a 7d 10 f0       	push   $0xf0107d0a
f0104121:	e8 8a f9 ff ff       	call   f0103ab0 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104126:	83 c4 08             	add    $0x8,%esp
f0104129:	ff 73 0c             	pushl  0xc(%ebx)
f010412c:	68 19 7d 10 f0       	push   $0xf0107d19
f0104131:	e8 7a f9 ff ff       	call   f0103ab0 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104136:	83 c4 08             	add    $0x8,%esp
f0104139:	ff 73 10             	pushl  0x10(%ebx)
f010413c:	68 28 7d 10 f0       	push   $0xf0107d28
f0104141:	e8 6a f9 ff ff       	call   f0103ab0 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104146:	83 c4 08             	add    $0x8,%esp
f0104149:	ff 73 14             	pushl  0x14(%ebx)
f010414c:	68 37 7d 10 f0       	push   $0xf0107d37
f0104151:	e8 5a f9 ff ff       	call   f0103ab0 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104156:	83 c4 08             	add    $0x8,%esp
f0104159:	ff 73 18             	pushl  0x18(%ebx)
f010415c:	68 46 7d 10 f0       	push   $0xf0107d46
f0104161:	e8 4a f9 ff ff       	call   f0103ab0 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104166:	83 c4 08             	add    $0x8,%esp
f0104169:	ff 73 1c             	pushl  0x1c(%ebx)
f010416c:	68 55 7d 10 f0       	push   $0xf0107d55
f0104171:	e8 3a f9 ff ff       	call   f0103ab0 <cprintf>
}
f0104176:	83 c4 10             	add    $0x10,%esp
f0104179:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010417c:	c9                   	leave  
f010417d:	c3                   	ret    

f010417e <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f010417e:	55                   	push   %ebp
f010417f:	89 e5                	mov    %esp,%ebp
f0104181:	56                   	push   %esi
f0104182:	53                   	push   %ebx
f0104183:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104186:	e8 f1 1e 00 00       	call   f010607c <cpunum>
f010418b:	83 ec 04             	sub    $0x4,%esp
f010418e:	50                   	push   %eax
f010418f:	53                   	push   %ebx
f0104190:	68 b9 7d 10 f0       	push   $0xf0107db9
f0104195:	e8 16 f9 ff ff       	call   f0103ab0 <cprintf>
	print_regs(&tf->tf_regs);
f010419a:	89 1c 24             	mov    %ebx,(%esp)
f010419d:	e8 4e ff ff ff       	call   f01040f0 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01041a2:	83 c4 08             	add    $0x8,%esp
f01041a5:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01041a9:	50                   	push   %eax
f01041aa:	68 d7 7d 10 f0       	push   $0xf0107dd7
f01041af:	e8 fc f8 ff ff       	call   f0103ab0 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01041b4:	83 c4 08             	add    $0x8,%esp
f01041b7:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01041bb:	50                   	push   %eax
f01041bc:	68 ea 7d 10 f0       	push   $0xf0107dea
f01041c1:	e8 ea f8 ff ff       	call   f0103ab0 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01041c6:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01041c9:	83 c4 10             	add    $0x10,%esp
f01041cc:	83 f8 13             	cmp    $0x13,%eax
f01041cf:	77 09                	ja     f01041da <print_trapframe+0x5c>
		return excnames[trapno];
f01041d1:	8b 14 85 80 80 10 f0 	mov    -0xfef7f80(,%eax,4),%edx
f01041d8:	eb 1f                	jmp    f01041f9 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f01041da:	83 f8 30             	cmp    $0x30,%eax
f01041dd:	74 15                	je     f01041f4 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01041df:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f01041e2:	83 fa 10             	cmp    $0x10,%edx
f01041e5:	b9 83 7d 10 f0       	mov    $0xf0107d83,%ecx
f01041ea:	ba 70 7d 10 f0       	mov    $0xf0107d70,%edx
f01041ef:	0f 43 d1             	cmovae %ecx,%edx
f01041f2:	eb 05                	jmp    f01041f9 <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01041f4:	ba 64 7d 10 f0       	mov    $0xf0107d64,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01041f9:	83 ec 04             	sub    $0x4,%esp
f01041fc:	52                   	push   %edx
f01041fd:	50                   	push   %eax
f01041fe:	68 fd 7d 10 f0       	push   $0xf0107dfd
f0104203:	e8 a8 f8 ff ff       	call   f0103ab0 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104208:	83 c4 10             	add    $0x10,%esp
f010420b:	3b 1d 60 7a 22 f0    	cmp    0xf0227a60,%ebx
f0104211:	75 1a                	jne    f010422d <print_trapframe+0xaf>
f0104213:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104217:	75 14                	jne    f010422d <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104219:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010421c:	83 ec 08             	sub    $0x8,%esp
f010421f:	50                   	push   %eax
f0104220:	68 0f 7e 10 f0       	push   $0xf0107e0f
f0104225:	e8 86 f8 ff ff       	call   f0103ab0 <cprintf>
f010422a:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f010422d:	83 ec 08             	sub    $0x8,%esp
f0104230:	ff 73 2c             	pushl  0x2c(%ebx)
f0104233:	68 1e 7e 10 f0       	push   $0xf0107e1e
f0104238:	e8 73 f8 ff ff       	call   f0103ab0 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f010423d:	83 c4 10             	add    $0x10,%esp
f0104240:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104244:	75 49                	jne    f010428f <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104246:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104249:	89 c2                	mov    %eax,%edx
f010424b:	83 e2 01             	and    $0x1,%edx
f010424e:	ba 9d 7d 10 f0       	mov    $0xf0107d9d,%edx
f0104253:	b9 92 7d 10 f0       	mov    $0xf0107d92,%ecx
f0104258:	0f 44 ca             	cmove  %edx,%ecx
f010425b:	89 c2                	mov    %eax,%edx
f010425d:	83 e2 02             	and    $0x2,%edx
f0104260:	ba af 7d 10 f0       	mov    $0xf0107daf,%edx
f0104265:	be a9 7d 10 f0       	mov    $0xf0107da9,%esi
f010426a:	0f 45 d6             	cmovne %esi,%edx
f010426d:	83 e0 04             	and    $0x4,%eax
f0104270:	be fc 7e 10 f0       	mov    $0xf0107efc,%esi
f0104275:	b8 b4 7d 10 f0       	mov    $0xf0107db4,%eax
f010427a:	0f 44 c6             	cmove  %esi,%eax
f010427d:	51                   	push   %ecx
f010427e:	52                   	push   %edx
f010427f:	50                   	push   %eax
f0104280:	68 2c 7e 10 f0       	push   $0xf0107e2c
f0104285:	e8 26 f8 ff ff       	call   f0103ab0 <cprintf>
f010428a:	83 c4 10             	add    $0x10,%esp
f010428d:	eb 10                	jmp    f010429f <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f010428f:	83 ec 0c             	sub    $0xc,%esp
f0104292:	68 c2 67 10 f0       	push   $0xf01067c2
f0104297:	e8 14 f8 ff ff       	call   f0103ab0 <cprintf>
f010429c:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010429f:	83 ec 08             	sub    $0x8,%esp
f01042a2:	ff 73 30             	pushl  0x30(%ebx)
f01042a5:	68 3b 7e 10 f0       	push   $0xf0107e3b
f01042aa:	e8 01 f8 ff ff       	call   f0103ab0 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01042af:	83 c4 08             	add    $0x8,%esp
f01042b2:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01042b6:	50                   	push   %eax
f01042b7:	68 4a 7e 10 f0       	push   $0xf0107e4a
f01042bc:	e8 ef f7 ff ff       	call   f0103ab0 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01042c1:	83 c4 08             	add    $0x8,%esp
f01042c4:	ff 73 38             	pushl  0x38(%ebx)
f01042c7:	68 5d 7e 10 f0       	push   $0xf0107e5d
f01042cc:	e8 df f7 ff ff       	call   f0103ab0 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01042d1:	83 c4 10             	add    $0x10,%esp
f01042d4:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01042d8:	74 25                	je     f01042ff <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01042da:	83 ec 08             	sub    $0x8,%esp
f01042dd:	ff 73 3c             	pushl  0x3c(%ebx)
f01042e0:	68 6c 7e 10 f0       	push   $0xf0107e6c
f01042e5:	e8 c6 f7 ff ff       	call   f0103ab0 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01042ea:	83 c4 08             	add    $0x8,%esp
f01042ed:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01042f1:	50                   	push   %eax
f01042f2:	68 7b 7e 10 f0       	push   $0xf0107e7b
f01042f7:	e8 b4 f7 ff ff       	call   f0103ab0 <cprintf>
f01042fc:	83 c4 10             	add    $0x10,%esp
	}
}
f01042ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104302:	5b                   	pop    %ebx
f0104303:	5e                   	pop    %esi
f0104304:	5d                   	pop    %ebp
f0104305:	c3                   	ret    

f0104306 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104306:	55                   	push   %ebp
f0104307:	89 e5                	mov    %esp,%ebp
f0104309:	57                   	push   %edi
f010430a:	56                   	push   %esi
f010430b:	53                   	push   %ebx
f010430c:	83 ec 0c             	sub    $0xc,%esp
f010430f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104312:	0f 20 d6             	mov    %cr2,%esi
	// cprintf("fault_va: %x\n", fault_va);

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs&3) == 0) {
f0104315:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104319:	75 17                	jne    f0104332 <page_fault_handler+0x2c>
		panic("Kernel page fault!");
f010431b:	83 ec 04             	sub    $0x4,%esp
f010431e:	68 8e 7e 10 f0       	push   $0xf0107e8e
f0104323:	68 77 01 00 00       	push   $0x177
f0104328:	68 a1 7e 10 f0       	push   $0xf0107ea1
f010432d:	e8 62 bd ff ff       	call   f0100094 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {
f0104332:	e8 45 1d 00 00       	call   f010607c <cpunum>
f0104337:	6b c0 74             	imul   $0x74,%eax,%eax
f010433a:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f0104340:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104344:	0f 84 a7 00 00 00    	je     f01043f1 <page_fault_handler+0xeb>
		struct UTrapframe *utf;
		uintptr_t utf_addr;
		if (UXSTACKTOP-PGSIZE<=tf->tf_esp && tf->tf_esp<=UXSTACKTOP-1)
f010434a:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010434d:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			utf_addr = tf->tf_esp - sizeof(struct UTrapframe) - 4;
f0104353:	83 e8 38             	sub    $0x38,%eax
f0104356:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f010435c:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f0104361:	0f 46 d0             	cmovbe %eax,%edx
f0104364:	89 d7                	mov    %edx,%edi
		else 
			utf_addr = UXSTACKTOP - sizeof(struct UTrapframe);
		user_mem_assert(curenv, (void*)utf_addr, sizeof(struct UTrapframe), PTE_W);//1 is enough
f0104366:	e8 11 1d 00 00       	call   f010607c <cpunum>
f010436b:	6a 02                	push   $0x2
f010436d:	6a 34                	push   $0x34
f010436f:	57                   	push   %edi
f0104370:	6b c0 74             	imul   $0x74,%eax,%eax
f0104373:	ff b0 28 80 22 f0    	pushl  -0xfdd7fd8(%eax)
f0104379:	e8 39 ee ff ff       	call   f01031b7 <user_mem_assert>
		utf = (struct UTrapframe *) utf_addr;

		utf->utf_fault_va = fault_va;
f010437e:	89 fa                	mov    %edi,%edx
f0104380:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_err;
f0104382:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104385:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f0104388:	8d 7f 08             	lea    0x8(%edi),%edi
f010438b:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104390:	89 de                	mov    %ebx,%esi
f0104392:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f0104394:	8b 43 30             	mov    0x30(%ebx),%eax
f0104397:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f010439a:	8b 43 38             	mov    0x38(%ebx),%eax
f010439d:	89 d7                	mov    %edx,%edi
f010439f:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f01043a2:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01043a5:	89 42 30             	mov    %eax,0x30(%edx)

//		curenv->env_tf.env_tf
		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f01043a8:	e8 cf 1c 00 00       	call   f010607c <cpunum>
f01043ad:	6b c0 74             	imul   $0x74,%eax,%eax
f01043b0:	8b 98 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%ebx
f01043b6:	e8 c1 1c 00 00       	call   f010607c <cpunum>
f01043bb:	6b c0 74             	imul   $0x74,%eax,%eax
f01043be:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f01043c4:	8b 40 64             	mov    0x64(%eax),%eax
f01043c7:	89 43 30             	mov    %eax,0x30(%ebx)
		curenv->env_tf.tf_esp = utf_addr;
f01043ca:	e8 ad 1c 00 00       	call   f010607c <cpunum>
f01043cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01043d2:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f01043d8:	89 78 3c             	mov    %edi,0x3c(%eax)
		env_run(curenv);
f01043db:	e8 9c 1c 00 00       	call   f010607c <cpunum>
f01043e0:	83 c4 04             	add    $0x4,%esp
f01043e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01043e6:	ff b0 28 80 22 f0    	pushl  -0xfdd7fd8(%eax)
f01043ec:	e8 a3 f4 ff ff       	call   f0103894 <env_run>
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01043f1:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01043f4:	e8 83 1c 00 00       	call   f010607c <cpunum>
		curenv->env_tf.tf_esp = utf_addr;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01043f9:	57                   	push   %edi
f01043fa:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f01043fb:	6b c0 74             	imul   $0x74,%eax,%eax
		curenv->env_tf.tf_esp = utf_addr;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01043fe:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f0104404:	ff 70 48             	pushl  0x48(%eax)
f0104407:	68 48 80 10 f0       	push   $0xf0108048
f010440c:	e8 9f f6 ff ff       	call   f0103ab0 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104411:	89 1c 24             	mov    %ebx,(%esp)
f0104414:	e8 65 fd ff ff       	call   f010417e <print_trapframe>
	env_destroy(curenv);
f0104419:	e8 5e 1c 00 00       	call   f010607c <cpunum>
f010441e:	83 c4 04             	add    $0x4,%esp
f0104421:	6b c0 74             	imul   $0x74,%eax,%eax
f0104424:	ff b0 28 80 22 f0    	pushl  -0xfdd7fd8(%eax)
f010442a:	e8 b7 f3 ff ff       	call   f01037e6 <env_destroy>
}
f010442f:	83 c4 10             	add    $0x10,%esp
f0104432:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104435:	5b                   	pop    %ebx
f0104436:	5e                   	pop    %esi
f0104437:	5f                   	pop    %edi
f0104438:	5d                   	pop    %ebp
f0104439:	c3                   	ret    

f010443a <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f010443a:	55                   	push   %ebp
f010443b:	89 e5                	mov    %esp,%ebp
f010443d:	57                   	push   %edi
f010443e:	56                   	push   %esi
f010443f:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104442:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104443:	83 3d 80 7e 22 f0 00 	cmpl   $0x0,0xf0227e80
f010444a:	74 01                	je     f010444d <trap+0x13>
		asm volatile("hlt");
f010444c:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010444d:	e8 2a 1c 00 00       	call   f010607c <cpunum>
f0104452:	6b d0 74             	imul   $0x74,%eax,%edx
f0104455:	81 c2 20 80 22 f0    	add    $0xf0228020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010445b:	b8 01 00 00 00       	mov    $0x1,%eax
f0104460:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104464:	83 f8 02             	cmp    $0x2,%eax
f0104467:	75 10                	jne    f0104479 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104469:	83 ec 0c             	sub    $0xc,%esp
f010446c:	68 c0 13 12 f0       	push   $0xf01213c0
f0104471:	e8 74 1e 00 00       	call   f01062ea <spin_lock>
f0104476:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104479:	9c                   	pushf  
f010447a:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010447b:	f6 c4 02             	test   $0x2,%ah
f010447e:	74 19                	je     f0104499 <trap+0x5f>
f0104480:	68 ad 7e 10 f0       	push   $0xf0107ead
f0104485:	68 9e 6f 10 f0       	push   $0xf0106f9e
f010448a:	68 3f 01 00 00       	push   $0x13f
f010448f:	68 a1 7e 10 f0       	push   $0xf0107ea1
f0104494:	e8 fb bb ff ff       	call   f0100094 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104499:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010449d:	83 e0 03             	and    $0x3,%eax
f01044a0:	66 83 f8 03          	cmp    $0x3,%ax
f01044a4:	0f 85 a0 00 00 00    	jne    f010454a <trap+0x110>
f01044aa:	83 ec 0c             	sub    $0xc,%esp
f01044ad:	68 c0 13 12 f0       	push   $0xf01213c0
f01044b2:	e8 33 1e 00 00       	call   f01062ea <spin_lock>
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();

		assert(curenv);
f01044b7:	e8 c0 1b 00 00       	call   f010607c <cpunum>
f01044bc:	6b c0 74             	imul   $0x74,%eax,%eax
f01044bf:	83 c4 10             	add    $0x10,%esp
f01044c2:	83 b8 28 80 22 f0 00 	cmpl   $0x0,-0xfdd7fd8(%eax)
f01044c9:	75 19                	jne    f01044e4 <trap+0xaa>
f01044cb:	68 c6 7e 10 f0       	push   $0xf0107ec6
f01044d0:	68 9e 6f 10 f0       	push   $0xf0106f9e
f01044d5:	68 48 01 00 00       	push   $0x148
f01044da:	68 a1 7e 10 f0       	push   $0xf0107ea1
f01044df:	e8 b0 bb ff ff       	call   f0100094 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01044e4:	e8 93 1b 00 00       	call   f010607c <cpunum>
f01044e9:	6b c0 74             	imul   $0x74,%eax,%eax
f01044ec:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f01044f2:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01044f6:	75 2d                	jne    f0104525 <trap+0xeb>
			env_free(curenv);
f01044f8:	e8 7f 1b 00 00       	call   f010607c <cpunum>
f01044fd:	83 ec 0c             	sub    $0xc,%esp
f0104500:	6b c0 74             	imul   $0x74,%eax,%eax
f0104503:	ff b0 28 80 22 f0    	pushl  -0xfdd7fd8(%eax)
f0104509:	e8 fd f0 ff ff       	call   f010360b <env_free>
			curenv = NULL;
f010450e:	e8 69 1b 00 00       	call   f010607c <cpunum>
f0104513:	6b c0 74             	imul   $0x74,%eax,%eax
f0104516:	c7 80 28 80 22 f0 00 	movl   $0x0,-0xfdd7fd8(%eax)
f010451d:	00 00 00 
			sched_yield();
f0104520:	e8 c6 03 00 00       	call   f01048eb <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104525:	e8 52 1b 00 00       	call   f010607c <cpunum>
f010452a:	6b c0 74             	imul   $0x74,%eax,%eax
f010452d:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f0104533:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104538:	89 c7                	mov    %eax,%edi
f010453a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f010453c:	e8 3b 1b 00 00       	call   f010607c <cpunum>
f0104541:	6b c0 74             	imul   $0x74,%eax,%eax
f0104544:	8b b0 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010454a:	89 35 60 7a 22 f0    	mov    %esi,0xf0227a60
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	if (tf->tf_trapno == T_PGFLT) {
f0104550:	8b 46 28             	mov    0x28(%esi),%eax
f0104553:	83 f8 0e             	cmp    $0xe,%eax
f0104556:	75 11                	jne    f0104569 <trap+0x12f>
		// cprintf("PAGE FAULT\n");
		page_fault_handler(tf);
f0104558:	83 ec 0c             	sub    $0xc,%esp
f010455b:	56                   	push   %esi
f010455c:	e8 a5 fd ff ff       	call   f0104306 <page_fault_handler>
f0104561:	83 c4 10             	add    $0x10,%esp
f0104564:	e9 ad 00 00 00       	jmp    f0104616 <trap+0x1dc>
		return;
	}
	if (tf->tf_trapno == T_BRKPT) {
f0104569:	83 f8 03             	cmp    $0x3,%eax
f010456c:	75 11                	jne    f010457f <trap+0x145>
		// cprintf("BREAK POINT\n");
		monitor(tf);
f010456e:	83 ec 0c             	sub    $0xc,%esp
f0104571:	56                   	push   %esi
f0104572:	e8 21 c5 ff ff       	call   f0100a98 <monitor>
f0104577:	83 c4 10             	add    $0x10,%esp
f010457a:	e9 97 00 00 00       	jmp    f0104616 <trap+0x1dc>
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
f010457f:	83 f8 30             	cmp    $0x30,%eax
f0104582:	75 21                	jne    f01045a5 <trap+0x16b>
		// cprintf("SYSTEM CALL\n");
		tf->tf_regs.reg_eax = 
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0104584:	83 ec 08             	sub    $0x8,%esp
f0104587:	ff 76 04             	pushl  0x4(%esi)
f010458a:	ff 36                	pushl  (%esi)
f010458c:	ff 76 10             	pushl  0x10(%esi)
f010458f:	ff 76 18             	pushl  0x18(%esi)
f0104592:	ff 76 14             	pushl  0x14(%esi)
f0104595:	ff 76 1c             	pushl  0x1c(%esi)
f0104598:	e8 02 04 00 00       	call   f010499f <syscall>
		monitor(tf);
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
		// cprintf("SYSTEM CALL\n");
		tf->tf_regs.reg_eax = 
f010459d:	89 46 1c             	mov    %eax,0x1c(%esi)
f01045a0:	83 c4 20             	add    $0x20,%esp
f01045a3:	eb 71                	jmp    f0104616 <trap+0x1dc>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01045a5:	83 f8 27             	cmp    $0x27,%eax
f01045a8:	75 1a                	jne    f01045c4 <trap+0x18a>
		cprintf("Spurious interrupt on irq 7\n");
f01045aa:	83 ec 0c             	sub    $0xc,%esp
f01045ad:	68 cd 7e 10 f0       	push   $0xf0107ecd
f01045b2:	e8 f9 f4 ff ff       	call   f0103ab0 <cprintf>
		print_trapframe(tf);
f01045b7:	89 34 24             	mov    %esi,(%esp)
f01045ba:	e8 bf fb ff ff       	call   f010417e <print_trapframe>
f01045bf:	83 c4 10             	add    $0x10,%esp
f01045c2:	eb 52                	jmp    f0104616 <trap+0x1dc>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f01045c4:	83 f8 20             	cmp    $0x20,%eax
f01045c7:	75 0a                	jne    f01045d3 <trap+0x199>
		// cprintf("Timer\n");
		lapic_eoi();
f01045c9:	e8 f9 1b 00 00       	call   f01061c7 <lapic_eoi>
		sched_yield();
f01045ce:	e8 18 03 00 00       	call   f01048eb <sched_yield>
		return;
	}


	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01045d3:	83 ec 0c             	sub    $0xc,%esp
f01045d6:	56                   	push   %esi
f01045d7:	e8 a2 fb ff ff       	call   f010417e <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01045dc:	83 c4 10             	add    $0x10,%esp
f01045df:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01045e4:	75 17                	jne    f01045fd <trap+0x1c3>
		panic("unhandled trap in kernel");
f01045e6:	83 ec 04             	sub    $0x4,%esp
f01045e9:	68 ea 7e 10 f0       	push   $0xf0107eea
f01045ee:	68 25 01 00 00       	push   $0x125
f01045f3:	68 a1 7e 10 f0       	push   $0xf0107ea1
f01045f8:	e8 97 ba ff ff       	call   f0100094 <_panic>
	else {
		env_destroy(curenv);
f01045fd:	e8 7a 1a 00 00       	call   f010607c <cpunum>
f0104602:	83 ec 0c             	sub    $0xc,%esp
f0104605:	6b c0 74             	imul   $0x74,%eax,%eax
f0104608:	ff b0 28 80 22 f0    	pushl  -0xfdd7fd8(%eax)
f010460e:	e8 d3 f1 ff ff       	call   f01037e6 <env_destroy>
f0104613:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104616:	e8 61 1a 00 00       	call   f010607c <cpunum>
f010461b:	6b c0 74             	imul   $0x74,%eax,%eax
f010461e:	83 b8 28 80 22 f0 00 	cmpl   $0x0,-0xfdd7fd8(%eax)
f0104625:	74 2a                	je     f0104651 <trap+0x217>
f0104627:	e8 50 1a 00 00       	call   f010607c <cpunum>
f010462c:	6b c0 74             	imul   $0x74,%eax,%eax
f010462f:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f0104635:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104639:	75 16                	jne    f0104651 <trap+0x217>
		env_run(curenv);
f010463b:	e8 3c 1a 00 00       	call   f010607c <cpunum>
f0104640:	83 ec 0c             	sub    $0xc,%esp
f0104643:	6b c0 74             	imul   $0x74,%eax,%eax
f0104646:	ff b0 28 80 22 f0    	pushl  -0xfdd7fd8(%eax)
f010464c:	e8 43 f2 ff ff       	call   f0103894 <env_run>
	else
		sched_yield();
f0104651:	e8 95 02 00 00       	call   f01048eb <sched_yield>

f0104656 <i0>:
	pushl $(num);							\
	jmp _alltraps


.text
TRAPHANDLER_NOEC(i0, 0)
f0104656:	6a 00                	push   $0x0
f0104658:	6a 00                	push   $0x0
f010465a:	e9 7b 01 00 00       	jmp    f01047da <_alltraps>
f010465f:	90                   	nop

f0104660 <i1>:
TRAPHANDLER_NOEC(i1, 1)
f0104660:	6a 00                	push   $0x0
f0104662:	6a 01                	push   $0x1
f0104664:	e9 71 01 00 00       	jmp    f01047da <_alltraps>
f0104669:	90                   	nop

f010466a <i2>:
TRAPHANDLER_NOEC(i2, 2)
f010466a:	6a 00                	push   $0x0
f010466c:	6a 02                	push   $0x2
f010466e:	e9 67 01 00 00       	jmp    f01047da <_alltraps>
f0104673:	90                   	nop

f0104674 <i3>:
TRAPHANDLER_NOEC(i3, 3)
f0104674:	6a 00                	push   $0x0
f0104676:	6a 03                	push   $0x3
f0104678:	e9 5d 01 00 00       	jmp    f01047da <_alltraps>
f010467d:	90                   	nop

f010467e <i4>:
TRAPHANDLER_NOEC(i4, 4)
f010467e:	6a 00                	push   $0x0
f0104680:	6a 04                	push   $0x4
f0104682:	e9 53 01 00 00       	jmp    f01047da <_alltraps>
f0104687:	90                   	nop

f0104688 <i5>:
TRAPHANDLER_NOEC(i5, 5)
f0104688:	6a 00                	push   $0x0
f010468a:	6a 05                	push   $0x5
f010468c:	e9 49 01 00 00       	jmp    f01047da <_alltraps>
f0104691:	90                   	nop

f0104692 <i6>:
TRAPHANDLER_NOEC(i6, 6)
f0104692:	6a 00                	push   $0x0
f0104694:	6a 06                	push   $0x6
f0104696:	e9 3f 01 00 00       	jmp    f01047da <_alltraps>
f010469b:	90                   	nop

f010469c <i7>:
TRAPHANDLER_NOEC(i7, 7)
f010469c:	6a 00                	push   $0x0
f010469e:	6a 07                	push   $0x7
f01046a0:	e9 35 01 00 00       	jmp    f01047da <_alltraps>
f01046a5:	90                   	nop

f01046a6 <i8>:
TRAPHANDLER(i8, 8)
f01046a6:	6a 08                	push   $0x8
f01046a8:	e9 2d 01 00 00       	jmp    f01047da <_alltraps>
f01046ad:	90                   	nop

f01046ae <i9>:
TRAPHANDLER_NOEC(i9, 9)
f01046ae:	6a 00                	push   $0x0
f01046b0:	6a 09                	push   $0x9
f01046b2:	e9 23 01 00 00       	jmp    f01047da <_alltraps>
f01046b7:	90                   	nop

f01046b8 <i10>:
TRAPHANDLER(i10, 10)
f01046b8:	6a 0a                	push   $0xa
f01046ba:	e9 1b 01 00 00       	jmp    f01047da <_alltraps>
f01046bf:	90                   	nop

f01046c0 <i11>:
TRAPHANDLER(i11, 11)
f01046c0:	6a 0b                	push   $0xb
f01046c2:	e9 13 01 00 00       	jmp    f01047da <_alltraps>
f01046c7:	90                   	nop

f01046c8 <i12>:
TRAPHANDLER(i12, 12)
f01046c8:	6a 0c                	push   $0xc
f01046ca:	e9 0b 01 00 00       	jmp    f01047da <_alltraps>
f01046cf:	90                   	nop

f01046d0 <i13>:
TRAPHANDLER(i13, 13)
f01046d0:	6a 0d                	push   $0xd
f01046d2:	e9 03 01 00 00       	jmp    f01047da <_alltraps>
f01046d7:	90                   	nop

f01046d8 <i14>:
TRAPHANDLER(i14, 14)
f01046d8:	6a 0e                	push   $0xe
f01046da:	e9 fb 00 00 00       	jmp    f01047da <_alltraps>
f01046df:	90                   	nop

f01046e0 <i15>:
TRAPHANDLER_NOEC(i15, 15)
f01046e0:	6a 00                	push   $0x0
f01046e2:	6a 0f                	push   $0xf
f01046e4:	e9 f1 00 00 00       	jmp    f01047da <_alltraps>
f01046e9:	90                   	nop

f01046ea <i16>:
TRAPHANDLER_NOEC(i16, 16)
f01046ea:	6a 00                	push   $0x0
f01046ec:	6a 10                	push   $0x10
f01046ee:	e9 e7 00 00 00       	jmp    f01047da <_alltraps>
f01046f3:	90                   	nop

f01046f4 <i17>:
TRAPHANDLER(i17, 17)
f01046f4:	6a 11                	push   $0x11
f01046f6:	e9 df 00 00 00       	jmp    f01047da <_alltraps>
f01046fb:	90                   	nop

f01046fc <i18>:
TRAPHANDLER_NOEC(i18, 18)
f01046fc:	6a 00                	push   $0x0
f01046fe:	6a 12                	push   $0x12
f0104700:	e9 d5 00 00 00       	jmp    f01047da <_alltraps>
f0104705:	90                   	nop

f0104706 <i19>:
TRAPHANDLER_NOEC(i19, 19)
f0104706:	6a 00                	push   $0x0
f0104708:	6a 13                	push   $0x13
f010470a:	e9 cb 00 00 00       	jmp    f01047da <_alltraps>
f010470f:	90                   	nop

f0104710 <i20>:
TRAPHANDLER_NOEC(i20, 20)
f0104710:	6a 00                	push   $0x0
f0104712:	6a 14                	push   $0x14
f0104714:	e9 c1 00 00 00       	jmp    f01047da <_alltraps>
f0104719:	90                   	nop

f010471a <i21>:
TRAPHANDLER_NOEC(i21, 21)
f010471a:	6a 00                	push   $0x0
f010471c:	6a 15                	push   $0x15
f010471e:	e9 b7 00 00 00       	jmp    f01047da <_alltraps>
f0104723:	90                   	nop

f0104724 <i22>:
TRAPHANDLER_NOEC(i22, 22)
f0104724:	6a 00                	push   $0x0
f0104726:	6a 16                	push   $0x16
f0104728:	e9 ad 00 00 00       	jmp    f01047da <_alltraps>
f010472d:	90                   	nop

f010472e <i23>:
TRAPHANDLER_NOEC(i23, 23)
f010472e:	6a 00                	push   $0x0
f0104730:	6a 17                	push   $0x17
f0104732:	e9 a3 00 00 00       	jmp    f01047da <_alltraps>
f0104737:	90                   	nop

f0104738 <i24>:
TRAPHANDLER_NOEC(i24, 24)
f0104738:	6a 00                	push   $0x0
f010473a:	6a 18                	push   $0x18
f010473c:	e9 99 00 00 00       	jmp    f01047da <_alltraps>
f0104741:	90                   	nop

f0104742 <i25>:
TRAPHANDLER_NOEC(i25, 25)
f0104742:	6a 00                	push   $0x0
f0104744:	6a 19                	push   $0x19
f0104746:	e9 8f 00 00 00       	jmp    f01047da <_alltraps>
f010474b:	90                   	nop

f010474c <i26>:
TRAPHANDLER_NOEC(i26, 26)
f010474c:	6a 00                	push   $0x0
f010474e:	6a 1a                	push   $0x1a
f0104750:	e9 85 00 00 00       	jmp    f01047da <_alltraps>
f0104755:	90                   	nop

f0104756 <i27>:
TRAPHANDLER_NOEC(i27, 27)
f0104756:	6a 00                	push   $0x0
f0104758:	6a 1b                	push   $0x1b
f010475a:	eb 7e                	jmp    f01047da <_alltraps>

f010475c <i28>:
TRAPHANDLER_NOEC(i28, 28)
f010475c:	6a 00                	push   $0x0
f010475e:	6a 1c                	push   $0x1c
f0104760:	eb 78                	jmp    f01047da <_alltraps>

f0104762 <i29>:
TRAPHANDLER_NOEC(i29, 29)
f0104762:	6a 00                	push   $0x0
f0104764:	6a 1d                	push   $0x1d
f0104766:	eb 72                	jmp    f01047da <_alltraps>

f0104768 <i30>:
TRAPHANDLER_NOEC(i30, 30)
f0104768:	6a 00                	push   $0x0
f010476a:	6a 1e                	push   $0x1e
f010476c:	eb 6c                	jmp    f01047da <_alltraps>

f010476e <i31>:
TRAPHANDLER_NOEC(i31, 31)
f010476e:	6a 00                	push   $0x0
f0104770:	6a 1f                	push   $0x1f
f0104772:	eb 66                	jmp    f01047da <_alltraps>

f0104774 <i32>:
TRAPHANDLER_NOEC(i32, 32)
f0104774:	6a 00                	push   $0x0
f0104776:	6a 20                	push   $0x20
f0104778:	eb 60                	jmp    f01047da <_alltraps>

f010477a <i33>:
TRAPHANDLER_NOEC(i33, 33)
f010477a:	6a 00                	push   $0x0
f010477c:	6a 21                	push   $0x21
f010477e:	eb 5a                	jmp    f01047da <_alltraps>

f0104780 <i34>:
TRAPHANDLER_NOEC(i34, 34)
f0104780:	6a 00                	push   $0x0
f0104782:	6a 22                	push   $0x22
f0104784:	eb 54                	jmp    f01047da <_alltraps>

f0104786 <i35>:
TRAPHANDLER_NOEC(i35, 35)
f0104786:	6a 00                	push   $0x0
f0104788:	6a 23                	push   $0x23
f010478a:	eb 4e                	jmp    f01047da <_alltraps>

f010478c <i36>:
TRAPHANDLER_NOEC(i36, 36)
f010478c:	6a 00                	push   $0x0
f010478e:	6a 24                	push   $0x24
f0104790:	eb 48                	jmp    f01047da <_alltraps>

f0104792 <i37>:
TRAPHANDLER_NOEC(i37, 37)
f0104792:	6a 00                	push   $0x0
f0104794:	6a 25                	push   $0x25
f0104796:	eb 42                	jmp    f01047da <_alltraps>

f0104798 <i38>:
TRAPHANDLER_NOEC(i38, 38)
f0104798:	6a 00                	push   $0x0
f010479a:	6a 26                	push   $0x26
f010479c:	eb 3c                	jmp    f01047da <_alltraps>

f010479e <i39>:
TRAPHANDLER_NOEC(i39, 39)
f010479e:	6a 00                	push   $0x0
f01047a0:	6a 27                	push   $0x27
f01047a2:	eb 36                	jmp    f01047da <_alltraps>

f01047a4 <i40>:
TRAPHANDLER_NOEC(i40, 40)
f01047a4:	6a 00                	push   $0x0
f01047a6:	6a 28                	push   $0x28
f01047a8:	eb 30                	jmp    f01047da <_alltraps>

f01047aa <i41>:
TRAPHANDLER_NOEC(i41, 41)
f01047aa:	6a 00                	push   $0x0
f01047ac:	6a 29                	push   $0x29
f01047ae:	eb 2a                	jmp    f01047da <_alltraps>

f01047b0 <i42>:
TRAPHANDLER_NOEC(i42, 42)
f01047b0:	6a 00                	push   $0x0
f01047b2:	6a 2a                	push   $0x2a
f01047b4:	eb 24                	jmp    f01047da <_alltraps>

f01047b6 <i43>:
TRAPHANDLER_NOEC(i43, 43)
f01047b6:	6a 00                	push   $0x0
f01047b8:	6a 2b                	push   $0x2b
f01047ba:	eb 1e                	jmp    f01047da <_alltraps>

f01047bc <i44>:
TRAPHANDLER_NOEC(i44, 44)
f01047bc:	6a 00                	push   $0x0
f01047be:	6a 2c                	push   $0x2c
f01047c0:	eb 18                	jmp    f01047da <_alltraps>

f01047c2 <i45>:
TRAPHANDLER_NOEC(i45, 45)
f01047c2:	6a 00                	push   $0x0
f01047c4:	6a 2d                	push   $0x2d
f01047c6:	eb 12                	jmp    f01047da <_alltraps>

f01047c8 <i46>:
TRAPHANDLER_NOEC(i46, 46)
f01047c8:	6a 00                	push   $0x0
f01047ca:	6a 2e                	push   $0x2e
f01047cc:	eb 0c                	jmp    f01047da <_alltraps>

f01047ce <i47>:
TRAPHANDLER_NOEC(i47, 47)
f01047ce:	6a 00                	push   $0x0
f01047d0:	6a 2f                	push   $0x2f
f01047d2:	eb 06                	jmp    f01047da <_alltraps>

f01047d4 <i48>:
TRAPHANDLER_NOEC(i48, 48)
f01047d4:	6a 00                	push   $0x0
f01047d6:	6a 30                	push   $0x30
f01047d8:	eb 00                	jmp    f01047da <_alltraps>

f01047da <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f01047da:	1e                   	push   %ds
	pushl %es
f01047db:	06                   	push   %es
	pushal
f01047dc:	60                   	pusha  
	pushl $GD_KD
f01047dd:	6a 10                	push   $0x10
	popl %ds
f01047df:	1f                   	pop    %ds
	pushl $GD_KD
f01047e0:	6a 10                	push   $0x10
	popl %es
f01047e2:	07                   	pop    %es
	pushl %esp
f01047e3:	54                   	push   %esp
	call trap
f01047e4:	e8 51 fc ff ff       	call   f010443a <trap>

f01047e9 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01047e9:	55                   	push   %ebp
f01047ea:	89 e5                	mov    %esp,%ebp
f01047ec:	53                   	push   %ebx
f01047ed:	83 ec 04             	sub    $0x4,%esp
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01047f0:	8b 1d 48 72 22 f0    	mov    0xf0227248,%ebx
f01047f6:	8d 4b 54             	lea    0x54(%ebx),%ecx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01047f9:	ba 00 00 00 00       	mov    $0x0,%edx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01047fe:	8b 01                	mov    (%ecx),%eax
f0104800:	83 e8 02             	sub    $0x2,%eax
f0104803:	83 f8 01             	cmp    $0x1,%eax
f0104806:	76 10                	jbe    f0104818 <sched_halt+0x2f>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104808:	83 c2 01             	add    $0x1,%edx
f010480b:	83 c1 7c             	add    $0x7c,%ecx
f010480e:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0104814:	75 e8                	jne    f01047fe <sched_halt+0x15>
f0104816:	eb 08                	jmp    f0104820 <sched_halt+0x37>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f0104818:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f010481e:	75 4a                	jne    f010486a <sched_halt+0x81>
		for (i = 0; i < 2; ++i)
			cprintf("envs[%x].env_status: %x\n", i, envs[i].env_status);
f0104820:	83 ec 04             	sub    $0x4,%esp
f0104823:	ff 73 54             	pushl  0x54(%ebx)
f0104826:	6a 00                	push   $0x0
f0104828:	68 d0 80 10 f0       	push   $0xf01080d0
f010482d:	e8 7e f2 ff ff       	call   f0103ab0 <cprintf>
f0104832:	83 c4 0c             	add    $0xc,%esp
f0104835:	a1 48 72 22 f0       	mov    0xf0227248,%eax
f010483a:	ff b0 d0 00 00 00    	pushl  0xd0(%eax)
f0104840:	6a 01                	push   $0x1
f0104842:	68 d0 80 10 f0       	push   $0xf01080d0
f0104847:	e8 64 f2 ff ff       	call   f0103ab0 <cprintf>
		cprintf("No runnable environments in the system!\n");
f010484c:	c7 04 24 f8 80 10 f0 	movl   $0xf01080f8,(%esp)
f0104853:	e8 58 f2 ff ff       	call   f0103ab0 <cprintf>
f0104858:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f010485b:	83 ec 0c             	sub    $0xc,%esp
f010485e:	6a 00                	push   $0x0
f0104860:	e8 33 c2 ff ff       	call   f0100a98 <monitor>
f0104865:	83 c4 10             	add    $0x10,%esp
f0104868:	eb f1                	jmp    f010485b <sched_halt+0x72>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010486a:	e8 0d 18 00 00       	call   f010607c <cpunum>
f010486f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104872:	c7 80 28 80 22 f0 00 	movl   $0x0,-0xfdd7fd8(%eax)
f0104879:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f010487c:	a1 94 7e 22 f0       	mov    0xf0227e94,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104881:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104886:	77 12                	ja     f010489a <sched_halt+0xb1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104888:	50                   	push   %eax
f0104889:	68 a8 68 10 f0       	push   $0xf01068a8
f010488e:	6a 50                	push   $0x50
f0104890:	68 e9 80 10 f0       	push   $0xf01080e9
f0104895:	e8 fa b7 ff ff       	call   f0100094 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010489a:	05 00 00 00 10       	add    $0x10000000,%eax
f010489f:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01048a2:	e8 d5 17 00 00       	call   f010607c <cpunum>
f01048a7:	6b d0 74             	imul   $0x74,%eax,%edx
f01048aa:	81 c2 20 80 22 f0    	add    $0xf0228020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01048b0:	b8 02 00 00 00       	mov    $0x2,%eax
f01048b5:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01048b9:	83 ec 0c             	sub    $0xc,%esp
f01048bc:	68 c0 13 12 f0       	push   $0xf01213c0
f01048c1:	e8 c1 1a 00 00       	call   f0106387 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01048c6:	f3 90                	pause  
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01048c8:	e8 af 17 00 00       	call   f010607c <cpunum>
f01048cd:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01048d0:	8b 80 30 80 22 f0    	mov    -0xfdd7fd0(%eax),%eax
f01048d6:	bd 00 00 00 00       	mov    $0x0,%ebp
f01048db:	89 c4                	mov    %eax,%esp
f01048dd:	6a 00                	push   $0x0
f01048df:	6a 00                	push   $0x0
f01048e1:	fb                   	sti    
f01048e2:	f4                   	hlt    
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f01048e3:	83 c4 10             	add    $0x10,%esp
f01048e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01048e9:	c9                   	leave  
f01048ea:	c3                   	ret    

f01048eb <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01048eb:	55                   	push   %ebp
f01048ec:	89 e5                	mov    %esp,%ebp
f01048ee:	56                   	push   %esi
f01048ef:	53                   	push   %ebx

	// LAB 4: Your code here.
	struct Env *e;
	// cprintf("curenv: %x\n", curenv);
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_id);
f01048f0:	e8 87 17 00 00       	call   f010607c <cpunum>
f01048f5:	6b c0 74             	imul   $0x74,%eax,%eax
		else cur = 0;
f01048f8:	b9 00 00 00 00       	mov    $0x0,%ecx

	// LAB 4: Your code here.
	struct Env *e;
	// cprintf("curenv: %x\n", curenv);
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_id);
f01048fd:	83 b8 28 80 22 f0 00 	cmpl   $0x0,-0xfdd7fd8(%eax)
f0104904:	74 17                	je     f010491d <sched_yield+0x32>
f0104906:	e8 71 17 00 00       	call   f010607c <cpunum>
f010490b:	6b c0 74             	imul   $0x74,%eax,%eax
f010490e:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f0104914:	8b 48 48             	mov    0x48(%eax),%ecx
f0104917:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
		else cur = 0;
	// cprintf("cur: %x, thiscpu: %x\n", cur, thiscpu->cpu_id);
	for (i = 0; i < NENV; ++i) {
		int j = (cur+i) % NENV;
		// if (j < 2) cprintf("envs[%x].env_status: %x\n", j, envs[j].env_status);
		if (envs[j].env_status == ENV_RUNNABLE) {
f010491d:	8b 1d 48 72 22 f0    	mov    0xf0227248,%ebx
f0104923:	89 ca                	mov    %ecx,%edx
f0104925:	81 c1 00 04 00 00    	add    $0x400,%ecx
f010492b:	89 d6                	mov    %edx,%esi
f010492d:	c1 fe 1f             	sar    $0x1f,%esi
f0104930:	c1 ee 16             	shr    $0x16,%esi
f0104933:	8d 04 32             	lea    (%edx,%esi,1),%eax
f0104936:	25 ff 03 00 00       	and    $0x3ff,%eax
f010493b:	29 f0                	sub    %esi,%eax
f010493d:	6b c0 7c             	imul   $0x7c,%eax,%eax
f0104940:	01 d8                	add    %ebx,%eax
f0104942:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104946:	75 09                	jne    f0104951 <sched_yield+0x66>
			// if (j == 1) 
			// 	cprintf("\n");
			env_run(envs + j);
f0104948:	83 ec 0c             	sub    $0xc,%esp
f010494b:	50                   	push   %eax
f010494c:	e8 43 ef ff ff       	call   f0103894 <env_run>
f0104951:	83 c2 01             	add    $0x1,%edx
	// cprintf("curenv: %x\n", curenv);
	int i, cur=0;
	if (curenv) cur=ENVX(curenv->env_id);
		else cur = 0;
	// cprintf("cur: %x, thiscpu: %x\n", cur, thiscpu->cpu_id);
	for (i = 0; i < NENV; ++i) {
f0104954:	39 ca                	cmp    %ecx,%edx
f0104956:	75 d3                	jne    f010492b <sched_yield+0x40>
			// if (j == 1) 
			// 	cprintf("\n");
			env_run(envs + j);
		}
	}
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104958:	e8 1f 17 00 00       	call   f010607c <cpunum>
f010495d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104960:	83 b8 28 80 22 f0 00 	cmpl   $0x0,-0xfdd7fd8(%eax)
f0104967:	74 2a                	je     f0104993 <sched_yield+0xa8>
f0104969:	e8 0e 17 00 00       	call   f010607c <cpunum>
f010496e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104971:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f0104977:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010497b:	75 16                	jne    f0104993 <sched_yield+0xa8>
		env_run(curenv);
f010497d:	e8 fa 16 00 00       	call   f010607c <cpunum>
f0104982:	83 ec 0c             	sub    $0xc,%esp
f0104985:	6b c0 74             	imul   $0x74,%eax,%eax
f0104988:	ff b0 28 80 22 f0    	pushl  -0xfdd7fd8(%eax)
f010498e:	e8 01 ef ff ff       	call   f0103894 <env_run>

	// sched_halt never returns
	// cprintf("Nothing runnable\n");
	sched_halt();
f0104993:	e8 51 fe ff ff       	call   f01047e9 <sched_halt>
}
f0104998:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010499b:	5b                   	pop    %ebx
f010499c:	5e                   	pop    %esi
f010499d:	5d                   	pop    %ebp
f010499e:	c3                   	ret    

f010499f <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010499f:	55                   	push   %ebp
f01049a0:	89 e5                	mov    %esp,%ebp
f01049a2:	57                   	push   %edi
f01049a3:	56                   	push   %esi
f01049a4:	53                   	push   %ebx
f01049a5:	83 ec 1c             	sub    $0x1c,%esp
f01049a8:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int ret = 0;
	switch (syscallno) {
f01049ab:	83 f8 0c             	cmp    $0xc,%eax
f01049ae:	0f 87 03 05 00 00    	ja     f0104eb7 <syscall+0x518>
f01049b4:	ff 24 85 5c 81 10 f0 	jmp    *-0xfef7ea4(,%eax,4)
// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	// cprintf("sys curenv_id: %x\n", curenv->env_id);
	return curenv->env_id;
f01049bb:	e8 bc 16 00 00       	call   f010607c <cpunum>
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f01049c0:	83 ec 04             	sub    $0x4,%esp
f01049c3:	6a 01                	push   $0x1
f01049c5:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01049c8:	52                   	push   %edx
// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	// cprintf("sys curenv_id: %x\n", curenv->env_id);
	return curenv->env_id;
f01049c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01049cc:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f01049d2:	ff 70 48             	pushl  0x48(%eax)
f01049d5:	e8 92 e8 ff ff       	call   f010326c <envid2env>
	user_mem_assert(e, s, len, PTE_U);
f01049da:	6a 04                	push   $0x4
f01049dc:	ff 75 10             	pushl  0x10(%ebp)
f01049df:	ff 75 0c             	pushl  0xc(%ebp)
f01049e2:	ff 75 e4             	pushl  -0x1c(%ebp)
f01049e5:	e8 cd e7 ff ff       	call   f01031b7 <user_mem_assert>
	//user_mem_check(struct Env *env, const void *va, size_t len, int perm)

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01049ea:	83 c4 1c             	add    $0x1c,%esp
f01049ed:	ff 75 0c             	pushl  0xc(%ebp)
f01049f0:	ff 75 10             	pushl  0x10(%ebp)
f01049f3:	68 21 81 10 f0       	push   $0xf0108121
f01049f8:	e8 b3 f0 ff ff       	call   f0103ab0 <cprintf>
f01049fd:	83 c4 10             	add    $0x10,%esp
	// LAB 3: Your code here.
	int ret = 0;
	switch (syscallno) {
		case SYS_cputs: 
			sys_cputs((char*)a1, a2);
			ret = 0;
f0104a00:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a05:	e9 b9 04 00 00       	jmp    f0104ec3 <syscall+0x524>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104a0a:	e8 f5 bc ff ff       	call   f0100704 <cons_getc>
			sys_cputs((char*)a1, a2);
			ret = 0;
			break;
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
f0104a0f:	e9 af 04 00 00       	jmp    f0104ec3 <syscall+0x524>
// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	// cprintf("sys curenv_id: %x\n", curenv->env_id);
	return curenv->env_id;
f0104a14:	e8 63 16 00 00       	call   f010607c <cpunum>
f0104a19:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a1c:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f0104a22:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
		case SYS_getenvid:
			ret = sys_getenvid();
			break;
f0104a25:	e9 99 04 00 00       	jmp    f0104ec3 <syscall+0x524>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104a2a:	83 ec 04             	sub    $0x4,%esp
f0104a2d:	6a 01                	push   $0x1
f0104a2f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a32:	50                   	push   %eax
f0104a33:	ff 75 0c             	pushl  0xc(%ebp)
f0104a36:	e8 31 e8 ff ff       	call   f010326c <envid2env>
f0104a3b:	83 c4 10             	add    $0x10,%esp
f0104a3e:	85 c0                	test   %eax,%eax
f0104a40:	78 69                	js     f0104aab <syscall+0x10c>
		return r;
	if (e == curenv)
f0104a42:	e8 35 16 00 00       	call   f010607c <cpunum>
f0104a47:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104a4a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a4d:	39 90 28 80 22 f0    	cmp    %edx,-0xfdd7fd8(%eax)
f0104a53:	75 23                	jne    f0104a78 <syscall+0xd9>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104a55:	e8 22 16 00 00       	call   f010607c <cpunum>
f0104a5a:	83 ec 08             	sub    $0x8,%esp
f0104a5d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a60:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f0104a66:	ff 70 48             	pushl  0x48(%eax)
f0104a69:	68 26 81 10 f0       	push   $0xf0108126
f0104a6e:	e8 3d f0 ff ff       	call   f0103ab0 <cprintf>
f0104a73:	83 c4 10             	add    $0x10,%esp
f0104a76:	eb 25                	jmp    f0104a9d <syscall+0xfe>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104a78:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104a7b:	e8 fc 15 00 00       	call   f010607c <cpunum>
f0104a80:	83 ec 04             	sub    $0x4,%esp
f0104a83:	53                   	push   %ebx
f0104a84:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a87:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f0104a8d:	ff 70 48             	pushl  0x48(%eax)
f0104a90:	68 41 81 10 f0       	push   $0xf0108141
f0104a95:	e8 16 f0 ff ff       	call   f0103ab0 <cprintf>
f0104a9a:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104a9d:	83 ec 0c             	sub    $0xc,%esp
f0104aa0:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104aa3:	e8 3e ed ff ff       	call   f01037e6 <env_destroy>
f0104aa8:	83 c4 10             	add    $0x10,%esp
		case SYS_getenvid:
			ret = sys_getenvid();
			break;
		case SYS_env_destroy:
			sys_env_destroy(a1);
			ret = 0;
f0104aab:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ab0:	e9 0e 04 00 00       	jmp    f0104ec3 <syscall+0x524>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104ab5:	e8 31 fe ff ff       	call   f01048eb <sched_yield>
	// will appear to return 0.

	// LAB 4: Your code here.

	struct Env *e;
	int ret = env_alloc(&e, curenv->env_id);
f0104aba:	e8 bd 15 00 00       	call   f010607c <cpunum>
f0104abf:	83 ec 08             	sub    $0x8,%esp
f0104ac2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ac5:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f0104acb:	ff 70 48             	pushl  0x48(%eax)
f0104ace:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104ad1:	50                   	push   %eax
f0104ad2:	e8 a0 e8 ff ff       	call   f0103377 <env_alloc>
	if (ret) return ret;
f0104ad7:	83 c4 10             	add    $0x10,%esp
f0104ada:	85 c0                	test   %eax,%eax
f0104adc:	0f 85 e1 03 00 00    	jne    f0104ec3 <syscall+0x524>
	e->env_tf = curenv->env_tf;
f0104ae2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104ae5:	e8 92 15 00 00       	call   f010607c <cpunum>
f0104aea:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aed:	8b b0 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%esi
f0104af3:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104af8:	89 df                	mov    %ebx,%edi
f0104afa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_status = ENV_NOT_RUNNABLE;
f0104afc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104aff:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	e->env_tf.tf_regs.reg_eax = 0;
f0104b06:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	
	return e->env_id;
f0104b0d:	8b 40 48             	mov    0x48(%eax),%eax
f0104b10:	e9 ae 03 00 00       	jmp    f0104ec3 <syscall+0x524>
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!
	struct Env *e; 
	int ret = envid2env(envid, &e, 1);
f0104b15:	83 ec 04             	sub    $0x4,%esp
f0104b18:	6a 01                	push   $0x1
f0104b1a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104b1d:	50                   	push   %eax
f0104b1e:	ff 75 0c             	pushl  0xc(%ebp)
f0104b21:	e8 46 e7 ff ff       	call   f010326c <envid2env>
	if (ret) return ret;	//bad_env
f0104b26:	83 c4 10             	add    $0x10,%esp
f0104b29:	85 c0                	test   %eax,%eax
f0104b2b:	0f 85 92 03 00 00    	jne    f0104ec3 <syscall+0x524>
	// cprintf("good\n");
	if (va >= (void*)UTOP) return -E_INVAL;
f0104b31:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104b38:	77 55                	ja     f0104b8f <syscall+0x1f0>
	int flag = PTE_U|PTE_P;
	if ((perm & flag) != flag) return -E_INVAL;
f0104b3a:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b3d:	83 e0 05             	and    $0x5,%eax
f0104b40:	83 f8 05             	cmp    $0x5,%eax
f0104b43:	75 54                	jne    f0104b99 <syscall+0x1fa>
	// cprintf("good\n");
	struct PageInfo *pg = page_alloc(1);//init to zero
f0104b45:	83 ec 0c             	sub    $0xc,%esp
f0104b48:	6a 01                	push   $0x1
f0104b4a:	e8 cd c7 ff ff       	call   f010131c <page_alloc>
f0104b4f:	89 c3                	mov    %eax,%ebx
	if (!pg) return -E_NO_MEM;
f0104b51:	83 c4 10             	add    $0x10,%esp
f0104b54:	85 c0                	test   %eax,%eax
f0104b56:	74 4b                	je     f0104ba3 <syscall+0x204>
	// cprintf("good\n");
	pg->pp_ref++;
f0104b58:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	ret = page_insert(e->env_pgdir, pg, va, perm);
f0104b5d:	ff 75 14             	pushl  0x14(%ebp)
f0104b60:	ff 75 10             	pushl  0x10(%ebp)
f0104b63:	50                   	push   %eax
f0104b64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b67:	ff 70 60             	pushl  0x60(%eax)
f0104b6a:	e8 6f ca ff ff       	call   f01015de <page_insert>
f0104b6f:	89 c6                	mov    %eax,%esi
	if (ret) {
f0104b71:	83 c4 10             	add    $0x10,%esp
f0104b74:	85 c0                	test   %eax,%eax
f0104b76:	0f 84 47 03 00 00    	je     f0104ec3 <syscall+0x524>
		page_free(pg);
f0104b7c:	83 ec 0c             	sub    $0xc,%esp
f0104b7f:	53                   	push   %ebx
f0104b80:	e8 01 c8 ff ff       	call   f0101386 <page_free>
f0104b85:	83 c4 10             	add    $0x10,%esp
		return ret;
f0104b88:	89 f0                	mov    %esi,%eax
f0104b8a:	e9 34 03 00 00       	jmp    f0104ec3 <syscall+0x524>
	//   allocated!
	struct Env *e; 
	int ret = envid2env(envid, &e, 1);
	if (ret) return ret;	//bad_env
	// cprintf("good\n");
	if (va >= (void*)UTOP) return -E_INVAL;
f0104b8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104b94:	e9 2a 03 00 00       	jmp    f0104ec3 <syscall+0x524>
	int flag = PTE_U|PTE_P;
	if ((perm & flag) != flag) return -E_INVAL;
f0104b99:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104b9e:	e9 20 03 00 00       	jmp    f0104ec3 <syscall+0x524>
	// cprintf("good\n");
	struct PageInfo *pg = page_alloc(1);//init to zero
	if (!pg) return -E_NO_MEM;
f0104ba3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104ba8:	e9 16 03 00 00       	jmp    f0104ec3 <syscall+0x524>

	// LAB 4: Your code here.
	//	-E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
	//		or the caller doesn't have permission to change one of them.
	struct Env *se, *de;
	int ret = envid2env(srcenvid, &se, 1);
f0104bad:	83 ec 04             	sub    $0x4,%esp
f0104bb0:	6a 01                	push   $0x1
f0104bb2:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104bb5:	50                   	push   %eax
f0104bb6:	ff 75 0c             	pushl  0xc(%ebp)
f0104bb9:	e8 ae e6 ff ff       	call   f010326c <envid2env>
	if (ret) return ret;	//bad_env
f0104bbe:	83 c4 10             	add    $0x10,%esp
f0104bc1:	85 c0                	test   %eax,%eax
f0104bc3:	0f 85 fa 02 00 00    	jne    f0104ec3 <syscall+0x524>
	ret = envid2env(dstenvid, &de, 1);
f0104bc9:	83 ec 04             	sub    $0x4,%esp
f0104bcc:	6a 01                	push   $0x1
f0104bce:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104bd1:	50                   	push   %eax
f0104bd2:	ff 75 14             	pushl  0x14(%ebp)
f0104bd5:	e8 92 e6 ff ff       	call   f010326c <envid2env>
	if (ret) return ret;	//bad_env
f0104bda:	83 c4 10             	add    $0x10,%esp
f0104bdd:	85 c0                	test   %eax,%eax
f0104bdf:	0f 85 de 02 00 00    	jne    f0104ec3 <syscall+0x524>
	// cprintf("src env: %x, dst env: %x, src va: %x, dst va: %x\n", 
		// se->env_id, de->env_id, srcva, dstva);

	//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
	//		or dstva >= UTOP or dstva is not page-aligned.
	if (srcva>=(void*)UTOP || dstva>=(void*)UTOP || 
f0104be5:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104bec:	77 73                	ja     f0104c61 <syscall+0x2c2>
f0104bee:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104bf5:	77 6a                	ja     f0104c61 <syscall+0x2c2>
f0104bf7:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104bfe:	75 6b                	jne    f0104c6b <syscall+0x2cc>
		ROUNDDOWN(srcva,PGSIZE)!=srcva || ROUNDDOWN(dstva,PGSIZE)!=dstva) 
		return -E_INVAL;
f0104c00:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		// se->env_id, de->env_id, srcva, dstva);

	//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
	//		or dstva >= UTOP or dstva is not page-aligned.
	if (srcva>=(void*)UTOP || dstva>=(void*)UTOP || 
		ROUNDDOWN(srcva,PGSIZE)!=srcva || ROUNDDOWN(dstva,PGSIZE)!=dstva) 
f0104c05:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104c0c:	0f 85 b1 02 00 00    	jne    f0104ec3 <syscall+0x524>
		return -E_INVAL;

	//	-E_INVAL is srcva is not mapped in srcenvid's address space.
	pte_t *pte;
	struct PageInfo *pg = page_lookup(se->env_pgdir, srcva, &pte);
f0104c12:	83 ec 04             	sub    $0x4,%esp
f0104c15:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104c18:	50                   	push   %eax
f0104c19:	ff 75 10             	pushl  0x10(%ebp)
f0104c1c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104c1f:	ff 70 60             	pushl  0x60(%eax)
f0104c22:	e8 ce c8 ff ff       	call   f01014f5 <page_lookup>
	if (!pg) return -E_INVAL;
f0104c27:	83 c4 10             	add    $0x10,%esp
f0104c2a:	85 c0                	test   %eax,%eax
f0104c2c:	74 47                	je     f0104c75 <syscall+0x2d6>

	//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
	int flag = PTE_U|PTE_P;
	if ((perm & flag) != flag) return -E_INVAL;
f0104c2e:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0104c31:	83 e2 05             	and    $0x5,%edx
f0104c34:	83 fa 05             	cmp    $0x5,%edx
f0104c37:	75 46                	jne    f0104c7f <syscall+0x2e0>

	//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
	//		address space.
	if (((*pte&PTE_W) == 0) && (perm&PTE_W)) return -E_INVAL;
f0104c39:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104c3c:	f6 02 02             	testb  $0x2,(%edx)
f0104c3f:	75 06                	jne    f0104c47 <syscall+0x2a8>
f0104c41:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104c45:	75 42                	jne    f0104c89 <syscall+0x2ea>

	//	-E_NO_MEM if there's no memory to allocate any necessary page tables.

	ret = page_insert(de->env_pgdir, pg, dstva, perm);
f0104c47:	ff 75 1c             	pushl  0x1c(%ebp)
f0104c4a:	ff 75 18             	pushl  0x18(%ebp)
f0104c4d:	50                   	push   %eax
f0104c4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c51:	ff 70 60             	pushl  0x60(%eax)
f0104c54:	e8 85 c9 ff ff       	call   f01015de <page_insert>
f0104c59:	83 c4 10             	add    $0x10,%esp
f0104c5c:	e9 62 02 00 00       	jmp    f0104ec3 <syscall+0x524>

	//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
	//		or dstva >= UTOP or dstva is not page-aligned.
	if (srcva>=(void*)UTOP || dstva>=(void*)UTOP || 
		ROUNDDOWN(srcva,PGSIZE)!=srcva || ROUNDDOWN(dstva,PGSIZE)!=dstva) 
		return -E_INVAL;
f0104c61:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c66:	e9 58 02 00 00       	jmp    f0104ec3 <syscall+0x524>
f0104c6b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c70:	e9 4e 02 00 00       	jmp    f0104ec3 <syscall+0x524>

	//	-E_INVAL is srcva is not mapped in srcenvid's address space.
	pte_t *pte;
	struct PageInfo *pg = page_lookup(se->env_pgdir, srcva, &pte);
	if (!pg) return -E_INVAL;
f0104c75:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c7a:	e9 44 02 00 00       	jmp    f0104ec3 <syscall+0x524>

	//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
	int flag = PTE_U|PTE_P;
	if ((perm & flag) != flag) return -E_INVAL;
f0104c7f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c84:	e9 3a 02 00 00       	jmp    f0104ec3 <syscall+0x524>

	//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
	//		address space.
	if (((*pte&PTE_W) == 0) && (perm&PTE_W)) return -E_INVAL;
f0104c89:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_exofork:
			return sys_exofork();
		case SYS_page_alloc:
			return sys_page_alloc(a1, (void*)a2, a3);
		case SYS_page_map:
			return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
f0104c8e:	e9 30 02 00 00       	jmp    f0104ec3 <syscall+0x524>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if (va>=(void*)UTOP || ROUNDDOWN(va,PGSIZE)!=va)
f0104c93:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104c9a:	77 4b                	ja     f0104ce7 <syscall+0x348>
		return -E_INVAL;
f0104c9c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if (va>=(void*)UTOP || ROUNDDOWN(va,PGSIZE)!=va)
f0104ca1:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104ca8:	0f 85 15 02 00 00    	jne    f0104ec3 <syscall+0x524>
		return -E_INVAL;
	struct Env *e;
	int ret = envid2env(envid, &e, 1);
f0104cae:	83 ec 04             	sub    $0x4,%esp
f0104cb1:	6a 01                	push   $0x1
f0104cb3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104cb6:	50                   	push   %eax
f0104cb7:	ff 75 0c             	pushl  0xc(%ebp)
f0104cba:	e8 ad e5 ff ff       	call   f010326c <envid2env>
f0104cbf:	89 c3                	mov    %eax,%ebx
	if (ret) return ret;	//bad_env
f0104cc1:	83 c4 10             	add    $0x10,%esp
f0104cc4:	85 c0                	test   %eax,%eax
f0104cc6:	0f 85 f7 01 00 00    	jne    f0104ec3 <syscall+0x524>
	page_remove(e->env_pgdir, va);
f0104ccc:	83 ec 08             	sub    $0x8,%esp
f0104ccf:	ff 75 10             	pushl  0x10(%ebp)
f0104cd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104cd5:	ff 70 60             	pushl  0x60(%eax)
f0104cd8:	e8 b3 c8 ff ff       	call   f0101590 <page_remove>
f0104cdd:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104ce0:	89 d8                	mov    %ebx,%eax
f0104ce2:	e9 dc 01 00 00       	jmp    f0104ec3 <syscall+0x524>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if (va>=(void*)UTOP || ROUNDDOWN(va,PGSIZE)!=va)
		return -E_INVAL;
f0104ce7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104cec:	e9 d2 01 00 00       	jmp    f0104ec3 <syscall+0x524>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) return -E_INVAL;
f0104cf1:	8b 45 10             	mov    0x10(%ebp),%eax
f0104cf4:	83 e8 02             	sub    $0x2,%eax
f0104cf7:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104cfc:	75 2e                	jne    f0104d2c <syscall+0x38d>
	struct Env *e; 
	int ret = envid2env(envid, &e, 1);
f0104cfe:	83 ec 04             	sub    $0x4,%esp
f0104d01:	6a 01                	push   $0x1
f0104d03:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104d06:	50                   	push   %eax
f0104d07:	ff 75 0c             	pushl  0xc(%ebp)
f0104d0a:	e8 5d e5 ff ff       	call   f010326c <envid2env>
f0104d0f:	89 c2                	mov    %eax,%edx
	if (ret) return ret;	//bad_env
f0104d11:	83 c4 10             	add    $0x10,%esp
f0104d14:	85 c0                	test   %eax,%eax
f0104d16:	0f 85 a7 01 00 00    	jne    f0104ec3 <syscall+0x524>
	e->env_status = status;
f0104d1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104d22:	89 48 54             	mov    %ecx,0x54(%eax)
	return 0;
f0104d25:	89 d0                	mov    %edx,%eax
f0104d27:	e9 97 01 00 00       	jmp    f0104ec3 <syscall+0x524>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) return -E_INVAL;
f0104d2c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104d31:	e9 8d 01 00 00       	jmp    f0104ec3 <syscall+0x524>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e; 
	int ret = envid2env(envid, &e, 1);
f0104d36:	83 ec 04             	sub    $0x4,%esp
f0104d39:	6a 01                	push   $0x1
f0104d3b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104d3e:	50                   	push   %eax
f0104d3f:	ff 75 0c             	pushl  0xc(%ebp)
f0104d42:	e8 25 e5 ff ff       	call   f010326c <envid2env>
	if (ret) return ret;	//bad_env
f0104d47:	83 c4 10             	add    $0x10,%esp
f0104d4a:	85 c0                	test   %eax,%eax
f0104d4c:	0f 85 71 01 00 00    	jne    f0104ec3 <syscall+0x524>
	e->env_pgfault_upcall = func;
f0104d52:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104d55:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104d58:	89 7a 64             	mov    %edi,0x64(%edx)
		case SYS_page_unmap:
			return sys_page_unmap(a1, (void*)a2);
		case SYS_env_set_status:
			return sys_env_set_status(a1, a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void*)a2);
f0104d5b:	e9 63 01 00 00       	jmp    f0104ec3 <syscall+0x524>
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	// cprintf("sys_ipc_recv dstva: %x\n", dstva);
	if (dstva < (void*)UTOP) 
f0104d60:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104d67:	77 0d                	ja     f0104d76 <syscall+0x3d7>
		if (dstva != ROUNDDOWN(dstva, PGSIZE)) 
f0104d69:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104d70:	0f 85 48 01 00 00    	jne    f0104ebe <syscall+0x51f>
			return -E_INVAL;
	curenv->env_ipc_recving = 1;
f0104d76:	e8 01 13 00 00       	call   f010607c <cpunum>
f0104d7b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d7e:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f0104d84:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104d88:	e8 ef 12 00 00       	call   f010607c <cpunum>
f0104d8d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d90:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f0104d96:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_dstva = dstva;
f0104d9d:	e8 da 12 00 00       	call   f010607c <cpunum>
f0104da2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104da5:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f0104dab:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104dae:	89 78 6c             	mov    %edi,0x6c(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104db1:	e8 35 fb ff ff       	call   f01048eb <sched_yield>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	
	struct Env *e;
	int env = envid2env(envid, &e, 0);
f0104db6:	83 ec 04             	sub    $0x4,%esp
f0104db9:	6a 00                	push   $0x0
f0104dbb:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104dbe:	50                   	push   %eax
f0104dbf:	ff 75 0c             	pushl  0xc(%ebp)
f0104dc2:	e8 a5 e4 ff ff       	call   f010326c <envid2env>
	if (env) return env;
f0104dc7:	83 c4 10             	add    $0x10,%esp
f0104dca:	85 c0                	test   %eax,%eax
f0104dcc:	0f 85 f1 00 00 00    	jne    f0104ec3 <syscall+0x524>
	if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
f0104dd2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104dd5:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104dd9:	0f 84 d1 00 00 00    	je     f0104eb0 <syscall+0x511>
	if (srcva < (void*)UTOP) {
f0104ddf:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104de6:	0f 87 8b 00 00 00    	ja     f0104e77 <syscall+0x4d8>
		pte_t *pte;
		struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104dec:	e8 8b 12 00 00       	call   f010607c <cpunum>
f0104df1:	83 ec 04             	sub    $0x4,%esp
f0104df4:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104df7:	52                   	push   %edx
f0104df8:	ff 75 14             	pushl  0x14(%ebp)
f0104dfb:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dfe:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f0104e04:	ff 70 60             	pushl  0x60(%eax)
f0104e07:	e8 e9 c6 ff ff       	call   f01014f5 <page_lookup>
f0104e0c:	89 c2                	mov    %eax,%edx
		if (!pg) return -E_INVAL;
f0104e0e:	83 c4 10             	add    $0x10,%esp
f0104e11:	85 c0                	test   %eax,%eax
f0104e13:	74 5b                	je     f0104e70 <syscall+0x4d1>
	if (((uint32_t) srcva % PGSIZE) != 0)
			return -E_INVAL;
f0104e15:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
	if (srcva < (void*)UTOP) {
		pte_t *pte;
		struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
		if (!pg) return -E_INVAL;
	if (((uint32_t) srcva % PGSIZE) != 0)
f0104e1a:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104e21:	0f 85 9c 00 00 00    	jne    f0104ec3 <syscall+0x524>
			return -E_INVAL;

		// Check permissions
		if ((perm & PTE_U) != PTE_U)
			return -E_INVAL;
		if ((perm & PTE_P) != PTE_P)
f0104e27:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0104e2a:	83 e1 05             	and    $0x5,%ecx
f0104e2d:	83 f9 05             	cmp    $0x5,%ecx
f0104e30:	0f 85 8d 00 00 00    	jne    f0104ec3 <syscall+0x524>
			return -E_INVAL;
		if ((perm & ~PTE_SYSCALL) != 0)
f0104e36:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f0104e3d:	0f 85 80 00 00 00    	jne    f0104ec3 <syscall+0x524>
return -E_INVAL;
		if (e->env_ipc_dstva < (void*)UTOP) {
f0104e43:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e46:	8b 48 6c             	mov    0x6c(%eax),%ecx
f0104e49:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f0104e4f:	77 26                	ja     f0104e77 <syscall+0x4d8>
			env = page_insert(e->env_pgdir, pg, e->env_ipc_dstva, perm);
f0104e51:	ff 75 18             	pushl  0x18(%ebp)
f0104e54:	51                   	push   %ecx
f0104e55:	52                   	push   %edx
f0104e56:	ff 70 60             	pushl  0x60(%eax)
f0104e59:	e8 80 c7 ff ff       	call   f01015de <page_insert>
			if (env) return env;
f0104e5e:	83 c4 10             	add    $0x10,%esp
f0104e61:	85 c0                	test   %eax,%eax
f0104e63:	75 5e                	jne    f0104ec3 <syscall+0x524>
			e->env_ipc_perm = perm;
f0104e65:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e68:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104e6b:	89 78 78             	mov    %edi,0x78(%eax)
f0104e6e:	eb 07                	jmp    f0104e77 <syscall+0x4d8>
	if (env) return env;
	if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
	if (srcva < (void*)UTOP) {
		pte_t *pte;
		struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
		if (!pg) return -E_INVAL;
f0104e70:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104e75:	eb 4c                	jmp    f0104ec3 <syscall+0x524>
			env = page_insert(e->env_pgdir, pg, e->env_ipc_dstva, perm);
			if (env) return env;
			e->env_ipc_perm = perm;
		}
	}
	e->env_ipc_recving = 0;
f0104e77:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104e7a:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	e->env_ipc_from = curenv->env_id;
f0104e7e:	e8 f9 11 00 00       	call   f010607c <cpunum>
f0104e83:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e86:	8b 80 28 80 22 f0    	mov    -0xfdd7fd8(%eax),%eax
f0104e8c:	8b 40 48             	mov    0x48(%eax),%eax
f0104e8f:	89 43 74             	mov    %eax,0x74(%ebx)
	e->env_ipc_value = value; 
f0104e92:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e95:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104e98:	89 78 70             	mov    %edi,0x70(%eax)
	e->env_status = ENV_RUNNABLE;
f0104e9b:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	e->env_tf.tf_regs.reg_eax = 0;
f0104ea2:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f0104ea9:	b8 00 00 00 00       	mov    $0x0,%eax
f0104eae:	eb 13                	jmp    f0104ec3 <syscall+0x524>
	// LAB 4: Your code here.
	
	struct Env *e;
	int env = envid2env(envid, &e, 0);
	if (env) return env;
	if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
f0104eb0:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void*)a2);
		case SYS_ipc_recv:
			return sys_ipc_recv((void*)a1);
		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void*)a3, a4);
f0104eb5:	eb 0c                	jmp    f0104ec3 <syscall+0x524>
		default:
			ret = -E_INVAL;
f0104eb7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104ebc:	eb 05                	jmp    f0104ec3 <syscall+0x524>
		case SYS_env_set_status:
			return sys_env_set_status(a1, a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void*)a2);
		case SYS_ipc_recv:
			return sys_ipc_recv((void*)a1);
f0104ebe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			ret = -E_INVAL;
	}
	// cprintf("ret: %x\n", ret);
	return ret;
	//panic("syscall not implemented");
}
f0104ec3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104ec6:	5b                   	pop    %ebx
f0104ec7:	5e                   	pop    %esi
f0104ec8:	5f                   	pop    %edi
f0104ec9:	5d                   	pop    %ebp
f0104eca:	c3                   	ret    

f0104ecb <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104ecb:	55                   	push   %ebp
f0104ecc:	89 e5                	mov    %esp,%ebp
f0104ece:	57                   	push   %edi
f0104ecf:	56                   	push   %esi
f0104ed0:	53                   	push   %ebx
f0104ed1:	83 ec 14             	sub    $0x14,%esp
f0104ed4:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104ed7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104eda:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104edd:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104ee0:	8b 1a                	mov    (%edx),%ebx
f0104ee2:	8b 01                	mov    (%ecx),%eax
f0104ee4:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104ee7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104eee:	eb 7f                	jmp    f0104f6f <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104ef0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104ef3:	01 d8                	add    %ebx,%eax
f0104ef5:	89 c6                	mov    %eax,%esi
f0104ef7:	c1 ee 1f             	shr    $0x1f,%esi
f0104efa:	01 c6                	add    %eax,%esi
f0104efc:	d1 fe                	sar    %esi
f0104efe:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104f01:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104f04:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104f07:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104f09:	eb 03                	jmp    f0104f0e <stab_binsearch+0x43>
			m--;
f0104f0b:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104f0e:	39 c3                	cmp    %eax,%ebx
f0104f10:	7f 0d                	jg     f0104f1f <stab_binsearch+0x54>
f0104f12:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104f16:	83 ea 0c             	sub    $0xc,%edx
f0104f19:	39 f9                	cmp    %edi,%ecx
f0104f1b:	75 ee                	jne    f0104f0b <stab_binsearch+0x40>
f0104f1d:	eb 05                	jmp    f0104f24 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104f1f:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104f22:	eb 4b                	jmp    f0104f6f <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104f24:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104f27:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104f2a:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104f2e:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104f31:	76 11                	jbe    f0104f44 <stab_binsearch+0x79>
			*region_left = m;
f0104f33:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104f36:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104f38:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104f3b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104f42:	eb 2b                	jmp    f0104f6f <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104f44:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104f47:	73 14                	jae    f0104f5d <stab_binsearch+0x92>
			*region_right = m - 1;
f0104f49:	83 e8 01             	sub    $0x1,%eax
f0104f4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104f4f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104f52:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104f54:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104f5b:	eb 12                	jmp    f0104f6f <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104f5d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104f60:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104f62:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104f66:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104f68:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104f6f:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104f72:	0f 8e 78 ff ff ff    	jle    f0104ef0 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104f78:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104f7c:	75 0f                	jne    f0104f8d <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104f7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f81:	8b 00                	mov    (%eax),%eax
f0104f83:	83 e8 01             	sub    $0x1,%eax
f0104f86:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104f89:	89 06                	mov    %eax,(%esi)
f0104f8b:	eb 2c                	jmp    f0104fb9 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104f8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f90:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104f92:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104f95:	8b 0e                	mov    (%esi),%ecx
f0104f97:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104f9a:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104f9d:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104fa0:	eb 03                	jmp    f0104fa5 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104fa2:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104fa5:	39 c8                	cmp    %ecx,%eax
f0104fa7:	7e 0b                	jle    f0104fb4 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104fa9:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104fad:	83 ea 0c             	sub    $0xc,%edx
f0104fb0:	39 df                	cmp    %ebx,%edi
f0104fb2:	75 ee                	jne    f0104fa2 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104fb4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104fb7:	89 06                	mov    %eax,(%esi)
	}
}
f0104fb9:	83 c4 14             	add    $0x14,%esp
f0104fbc:	5b                   	pop    %ebx
f0104fbd:	5e                   	pop    %esi
f0104fbe:	5f                   	pop    %edi
f0104fbf:	5d                   	pop    %ebp
f0104fc0:	c3                   	ret    

f0104fc1 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104fc1:	55                   	push   %ebp
f0104fc2:	89 e5                	mov    %esp,%ebp
f0104fc4:	57                   	push   %edi
f0104fc5:	56                   	push   %esi
f0104fc6:	53                   	push   %ebx
f0104fc7:	83 ec 3c             	sub    $0x3c,%esp
f0104fca:	8b 75 08             	mov    0x8(%ebp),%esi
f0104fcd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104fd0:	c7 03 90 81 10 f0    	movl   $0xf0108190,(%ebx)
	info->eip_line = 0;
f0104fd6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104fdd:	c7 43 08 90 81 10 f0 	movl   $0xf0108190,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104fe4:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104feb:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104fee:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104ff5:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104ffb:	0f 87 96 00 00 00    	ja     f0105097 <debuginfo_eip+0xd6>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// user_mem_check
		//
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0105001:	e8 76 10 00 00       	call   f010607c <cpunum>
f0105006:	6a 04                	push   $0x4
f0105008:	6a 10                	push   $0x10
f010500a:	68 00 00 20 00       	push   $0x200000
f010500f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105012:	ff b0 28 80 22 f0    	pushl  -0xfdd7fd8(%eax)
f0105018:	e8 18 e1 ff ff       	call   f0103135 <user_mem_check>
f010501d:	83 c4 10             	add    $0x10,%esp
f0105020:	85 c0                	test   %eax,%eax
f0105022:	0f 85 28 02 00 00    	jne    f0105250 <debuginfo_eip+0x28f>
			return -1;

		stabs = usd->stabs;
f0105028:	a1 00 00 20 00       	mov    0x200000,%eax
f010502d:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0105030:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0105036:	a1 08 00 20 00       	mov    0x200008,%eax
f010503b:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f010503e:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0105044:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f0105047:	e8 30 10 00 00       	call   f010607c <cpunum>
f010504c:	6a 04                	push   $0x4
f010504e:	6a 0c                	push   $0xc
f0105050:	ff 75 c0             	pushl  -0x40(%ebp)
f0105053:	6b c0 74             	imul   $0x74,%eax,%eax
f0105056:	ff b0 28 80 22 f0    	pushl  -0xfdd7fd8(%eax)
f010505c:	e8 d4 e0 ff ff       	call   f0103135 <user_mem_check>
f0105061:	83 c4 10             	add    $0x10,%esp
f0105064:	85 c0                	test   %eax,%eax
f0105066:	0f 85 eb 01 00 00    	jne    f0105257 <debuginfo_eip+0x296>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f010506c:	e8 0b 10 00 00       	call   f010607c <cpunum>
f0105071:	6a 04                	push   $0x4
f0105073:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105076:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0105079:	29 ca                	sub    %ecx,%edx
f010507b:	52                   	push   %edx
f010507c:	51                   	push   %ecx
f010507d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105080:	ff b0 28 80 22 f0    	pushl  -0xfdd7fd8(%eax)
f0105086:	e8 aa e0 ff ff       	call   f0103135 <user_mem_check>
f010508b:	83 c4 10             	add    $0x10,%esp
f010508e:	85 c0                	test   %eax,%eax
f0105090:	74 1f                	je     f01050b1 <debuginfo_eip+0xf0>
f0105092:	e9 c7 01 00 00       	jmp    f010525e <debuginfo_eip+0x29d>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105097:	c7 45 bc e0 66 11 f0 	movl   $0xf01166e0,-0x44(%ebp)
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010509e:	c7 45 b8 89 2f 11 f0 	movl   $0xf0112f89,-0x48(%ebp)
	info->eip_fn_narg = 0;
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01050a5:	bf 88 2f 11 f0       	mov    $0xf0112f88,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01050aa:	c7 45 c0 74 86 10 f0 	movl   $0xf0108674,-0x40(%ebp)
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01050b1:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01050b4:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f01050b7:	0f 83 a8 01 00 00    	jae    f0105265 <debuginfo_eip+0x2a4>
f01050bd:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01050c1:	0f 85 a5 01 00 00    	jne    f010526c <debuginfo_eip+0x2ab>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01050c7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01050ce:	2b 7d c0             	sub    -0x40(%ebp),%edi
f01050d1:	c1 ff 02             	sar    $0x2,%edi
f01050d4:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f01050da:	83 e8 01             	sub    $0x1,%eax
f01050dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01050e0:	83 ec 08             	sub    $0x8,%esp
f01050e3:	56                   	push   %esi
f01050e4:	6a 64                	push   $0x64
f01050e6:	8d 55 e0             	lea    -0x20(%ebp),%edx
f01050e9:	89 d1                	mov    %edx,%ecx
f01050eb:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01050ee:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01050f1:	89 f8                	mov    %edi,%eax
f01050f3:	e8 d3 fd ff ff       	call   f0104ecb <stab_binsearch>
	if (lfile == 0)
f01050f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01050fb:	83 c4 10             	add    $0x10,%esp
f01050fe:	85 c0                	test   %eax,%eax
f0105100:	0f 84 6d 01 00 00    	je     f0105273 <debuginfo_eip+0x2b2>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105106:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105109:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010510c:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010510f:	83 ec 08             	sub    $0x8,%esp
f0105112:	56                   	push   %esi
f0105113:	6a 24                	push   $0x24
f0105115:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0105118:	89 d1                	mov    %edx,%ecx
f010511a:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010511d:	89 f8                	mov    %edi,%eax
f010511f:	e8 a7 fd ff ff       	call   f0104ecb <stab_binsearch>

	if (lfun <= rfun) {
f0105124:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105127:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010512a:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f010512d:	83 c4 10             	add    $0x10,%esp
f0105130:	39 d0                	cmp    %edx,%eax
f0105132:	7f 2b                	jg     f010515f <debuginfo_eip+0x19e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105134:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105137:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f010513a:	8b 11                	mov    (%ecx),%edx
f010513c:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010513f:	2b 7d b8             	sub    -0x48(%ebp),%edi
f0105142:	39 fa                	cmp    %edi,%edx
f0105144:	73 06                	jae    f010514c <debuginfo_eip+0x18b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105146:	03 55 b8             	add    -0x48(%ebp),%edx
f0105149:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010514c:	8b 51 08             	mov    0x8(%ecx),%edx
f010514f:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105152:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105154:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105157:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010515a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010515d:	eb 0f                	jmp    f010516e <debuginfo_eip+0x1ad>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010515f:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0105162:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105165:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105168:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010516b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010516e:	83 ec 08             	sub    $0x8,%esp
f0105171:	6a 3a                	push   $0x3a
f0105173:	ff 73 08             	pushl  0x8(%ebx)
f0105176:	e8 c5 08 00 00       	call   f0105a40 <strfind>
f010517b:	2b 43 08             	sub    0x8(%ebx),%eax
f010517e:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105181:	83 c4 08             	add    $0x8,%esp
f0105184:	56                   	push   %esi
f0105185:	6a 44                	push   $0x44
f0105187:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010518a:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010518d:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105190:	89 f8                	mov    %edi,%eax
f0105192:	e8 34 fd ff ff       	call   f0104ecb <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0105197:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010519a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010519d:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01051a0:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f01051a4:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01051a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051aa:	83 c4 10             	add    $0x10,%esp
f01051ad:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f01051b1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01051b4:	eb 0a                	jmp    f01051c0 <debuginfo_eip+0x1ff>
f01051b6:	83 e8 01             	sub    $0x1,%eax
f01051b9:	83 ea 0c             	sub    $0xc,%edx
f01051bc:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f01051c0:	39 c7                	cmp    %eax,%edi
f01051c2:	7e 05                	jle    f01051c9 <debuginfo_eip+0x208>
f01051c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01051c7:	eb 47                	jmp    f0105210 <debuginfo_eip+0x24f>
	       && stabs[lline].n_type != N_SOL
f01051c9:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01051cd:	80 f9 84             	cmp    $0x84,%cl
f01051d0:	75 0e                	jne    f01051e0 <debuginfo_eip+0x21f>
f01051d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01051d5:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01051d9:	74 1c                	je     f01051f7 <debuginfo_eip+0x236>
f01051db:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01051de:	eb 17                	jmp    f01051f7 <debuginfo_eip+0x236>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01051e0:	80 f9 64             	cmp    $0x64,%cl
f01051e3:	75 d1                	jne    f01051b6 <debuginfo_eip+0x1f5>
f01051e5:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f01051e9:	74 cb                	je     f01051b6 <debuginfo_eip+0x1f5>
f01051eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01051ee:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01051f2:	74 03                	je     f01051f7 <debuginfo_eip+0x236>
f01051f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01051f7:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01051fa:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01051fd:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0105200:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105203:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0105206:	29 f0                	sub    %esi,%eax
f0105208:	39 c2                	cmp    %eax,%edx
f010520a:	73 04                	jae    f0105210 <debuginfo_eip+0x24f>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010520c:	01 f2                	add    %esi,%edx
f010520e:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105210:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105213:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105216:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010521b:	39 f2                	cmp    %esi,%edx
f010521d:	7d 60                	jge    f010527f <debuginfo_eip+0x2be>
		for (lline = lfun + 1;
f010521f:	83 c2 01             	add    $0x1,%edx
f0105222:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105225:	89 d0                	mov    %edx,%eax
f0105227:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010522a:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010522d:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0105230:	eb 04                	jmp    f0105236 <debuginfo_eip+0x275>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105232:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105236:	39 c6                	cmp    %eax,%esi
f0105238:	7e 40                	jle    f010527a <debuginfo_eip+0x2b9>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010523a:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010523e:	83 c0 01             	add    $0x1,%eax
f0105241:	83 c2 0c             	add    $0xc,%edx
f0105244:	80 f9 a0             	cmp    $0xa0,%cl
f0105247:	74 e9                	je     f0105232 <debuginfo_eip+0x271>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105249:	b8 00 00 00 00       	mov    $0x0,%eax
f010524e:	eb 2f                	jmp    f010527f <debuginfo_eip+0x2be>
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// user_mem_check
		//
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
			return -1;
f0105250:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105255:	eb 28                	jmp    f010527f <debuginfo_eip+0x2be>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;
f0105257:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010525c:	eb 21                	jmp    f010527f <debuginfo_eip+0x2be>

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
f010525e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105263:	eb 1a                	jmp    f010527f <debuginfo_eip+0x2be>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105265:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010526a:	eb 13                	jmp    f010527f <debuginfo_eip+0x2be>
f010526c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105271:	eb 0c                	jmp    f010527f <debuginfo_eip+0x2be>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0105273:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105278:	eb 05                	jmp    f010527f <debuginfo_eip+0x2be>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010527a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010527f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105282:	5b                   	pop    %ebx
f0105283:	5e                   	pop    %esi
f0105284:	5f                   	pop    %edi
f0105285:	5d                   	pop    %ebp
f0105286:	c3                   	ret    

f0105287 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105287:	55                   	push   %ebp
f0105288:	89 e5                	mov    %esp,%ebp
f010528a:	57                   	push   %edi
f010528b:	56                   	push   %esi
f010528c:	53                   	push   %ebx
f010528d:	83 ec 1c             	sub    $0x1c,%esp
f0105290:	89 c7                	mov    %eax,%edi
f0105292:	89 d6                	mov    %edx,%esi
f0105294:	8b 45 08             	mov    0x8(%ebp),%eax
f0105297:	8b 55 0c             	mov    0xc(%ebp),%edx
f010529a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010529d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01052a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01052a3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01052a8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01052ab:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01052ae:	39 d3                	cmp    %edx,%ebx
f01052b0:	72 05                	jb     f01052b7 <printnum+0x30>
f01052b2:	39 45 10             	cmp    %eax,0x10(%ebp)
f01052b5:	77 45                	ja     f01052fc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01052b7:	83 ec 0c             	sub    $0xc,%esp
f01052ba:	ff 75 18             	pushl  0x18(%ebp)
f01052bd:	8b 45 14             	mov    0x14(%ebp),%eax
f01052c0:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01052c3:	53                   	push   %ebx
f01052c4:	ff 75 10             	pushl  0x10(%ebp)
f01052c7:	83 ec 08             	sub    $0x8,%esp
f01052ca:	ff 75 e4             	pushl  -0x1c(%ebp)
f01052cd:	ff 75 e0             	pushl  -0x20(%ebp)
f01052d0:	ff 75 dc             	pushl  -0x24(%ebp)
f01052d3:	ff 75 d8             	pushl  -0x28(%ebp)
f01052d6:	e8 a5 11 00 00       	call   f0106480 <__udivdi3>
f01052db:	83 c4 18             	add    $0x18,%esp
f01052de:	52                   	push   %edx
f01052df:	50                   	push   %eax
f01052e0:	89 f2                	mov    %esi,%edx
f01052e2:	89 f8                	mov    %edi,%eax
f01052e4:	e8 9e ff ff ff       	call   f0105287 <printnum>
f01052e9:	83 c4 20             	add    $0x20,%esp
f01052ec:	eb 18                	jmp    f0105306 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01052ee:	83 ec 08             	sub    $0x8,%esp
f01052f1:	56                   	push   %esi
f01052f2:	ff 75 18             	pushl  0x18(%ebp)
f01052f5:	ff d7                	call   *%edi
f01052f7:	83 c4 10             	add    $0x10,%esp
f01052fa:	eb 03                	jmp    f01052ff <printnum+0x78>
f01052fc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01052ff:	83 eb 01             	sub    $0x1,%ebx
f0105302:	85 db                	test   %ebx,%ebx
f0105304:	7f e8                	jg     f01052ee <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105306:	83 ec 08             	sub    $0x8,%esp
f0105309:	56                   	push   %esi
f010530a:	83 ec 04             	sub    $0x4,%esp
f010530d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105310:	ff 75 e0             	pushl  -0x20(%ebp)
f0105313:	ff 75 dc             	pushl  -0x24(%ebp)
f0105316:	ff 75 d8             	pushl  -0x28(%ebp)
f0105319:	e8 92 12 00 00       	call   f01065b0 <__umoddi3>
f010531e:	83 c4 14             	add    $0x14,%esp
f0105321:	0f be 80 9a 81 10 f0 	movsbl -0xfef7e66(%eax),%eax
f0105328:	50                   	push   %eax
f0105329:	ff d7                	call   *%edi
}
f010532b:	83 c4 10             	add    $0x10,%esp
f010532e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105331:	5b                   	pop    %ebx
f0105332:	5e                   	pop    %esi
f0105333:	5f                   	pop    %edi
f0105334:	5d                   	pop    %ebp
f0105335:	c3                   	ret    

f0105336 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105336:	55                   	push   %ebp
f0105337:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105339:	83 fa 01             	cmp    $0x1,%edx
f010533c:	7e 0e                	jle    f010534c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010533e:	8b 10                	mov    (%eax),%edx
f0105340:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105343:	89 08                	mov    %ecx,(%eax)
f0105345:	8b 02                	mov    (%edx),%eax
f0105347:	8b 52 04             	mov    0x4(%edx),%edx
f010534a:	eb 22                	jmp    f010536e <getuint+0x38>
	else if (lflag)
f010534c:	85 d2                	test   %edx,%edx
f010534e:	74 10                	je     f0105360 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105350:	8b 10                	mov    (%eax),%edx
f0105352:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105355:	89 08                	mov    %ecx,(%eax)
f0105357:	8b 02                	mov    (%edx),%eax
f0105359:	ba 00 00 00 00       	mov    $0x0,%edx
f010535e:	eb 0e                	jmp    f010536e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105360:	8b 10                	mov    (%eax),%edx
f0105362:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105365:	89 08                	mov    %ecx,(%eax)
f0105367:	8b 02                	mov    (%edx),%eax
f0105369:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010536e:	5d                   	pop    %ebp
f010536f:	c3                   	ret    

f0105370 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105370:	55                   	push   %ebp
f0105371:	89 e5                	mov    %esp,%ebp
f0105373:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105376:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010537a:	8b 10                	mov    (%eax),%edx
f010537c:	3b 50 04             	cmp    0x4(%eax),%edx
f010537f:	73 0a                	jae    f010538b <sprintputch+0x1b>
		*b->buf++ = ch;
f0105381:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105384:	89 08                	mov    %ecx,(%eax)
f0105386:	8b 45 08             	mov    0x8(%ebp),%eax
f0105389:	88 02                	mov    %al,(%edx)
}
f010538b:	5d                   	pop    %ebp
f010538c:	c3                   	ret    

f010538d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010538d:	55                   	push   %ebp
f010538e:	89 e5                	mov    %esp,%ebp
f0105390:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0105393:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105396:	50                   	push   %eax
f0105397:	ff 75 10             	pushl  0x10(%ebp)
f010539a:	ff 75 0c             	pushl  0xc(%ebp)
f010539d:	ff 75 08             	pushl  0x8(%ebp)
f01053a0:	e8 05 00 00 00       	call   f01053aa <vprintfmt>
	va_end(ap);
}
f01053a5:	83 c4 10             	add    $0x10,%esp
f01053a8:	c9                   	leave  
f01053a9:	c3                   	ret    

f01053aa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01053aa:	55                   	push   %ebp
f01053ab:	89 e5                	mov    %esp,%ebp
f01053ad:	57                   	push   %edi
f01053ae:	56                   	push   %esi
f01053af:	53                   	push   %ebx
f01053b0:	83 ec 2c             	sub    $0x2c,%esp
f01053b3:	8b 75 08             	mov    0x8(%ebp),%esi
f01053b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01053b9:	8b 7d 10             	mov    0x10(%ebp),%edi
f01053bc:	eb 1d                	jmp    f01053db <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
f01053be:	85 c0                	test   %eax,%eax
f01053c0:	75 0f                	jne    f01053d1 <vprintfmt+0x27>
				csa = 0x0700;
f01053c2:	c7 05 88 7e 22 f0 00 	movl   $0x700,0xf0227e88
f01053c9:	07 00 00 
				return;
f01053cc:	e9 c4 03 00 00       	jmp    f0105795 <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
f01053d1:	83 ec 08             	sub    $0x8,%esp
f01053d4:	53                   	push   %ebx
f01053d5:	50                   	push   %eax
f01053d6:	ff d6                	call   *%esi
f01053d8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01053db:	83 c7 01             	add    $0x1,%edi
f01053de:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01053e2:	83 f8 25             	cmp    $0x25,%eax
f01053e5:	75 d7                	jne    f01053be <vprintfmt+0x14>
f01053e7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f01053eb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01053f2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01053f9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0105400:	ba 00 00 00 00       	mov    $0x0,%edx
f0105405:	eb 07                	jmp    f010540e <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105407:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f010540a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010540e:	8d 47 01             	lea    0x1(%edi),%eax
f0105411:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105414:	0f b6 07             	movzbl (%edi),%eax
f0105417:	0f b6 c8             	movzbl %al,%ecx
f010541a:	83 e8 23             	sub    $0x23,%eax
f010541d:	3c 55                	cmp    $0x55,%al
f010541f:	0f 87 55 03 00 00    	ja     f010577a <vprintfmt+0x3d0>
f0105425:	0f b6 c0             	movzbl %al,%eax
f0105428:	ff 24 85 60 82 10 f0 	jmp    *-0xfef7da0(,%eax,4)
f010542f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105432:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0105436:	eb d6                	jmp    f010540e <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010543b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105440:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105443:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105446:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f010544a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f010544d:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0105450:	83 fa 09             	cmp    $0x9,%edx
f0105453:	77 39                	ja     f010548e <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105455:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105458:	eb e9                	jmp    f0105443 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010545a:	8b 45 14             	mov    0x14(%ebp),%eax
f010545d:	8d 48 04             	lea    0x4(%eax),%ecx
f0105460:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105463:	8b 00                	mov    (%eax),%eax
f0105465:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105468:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010546b:	eb 27                	jmp    f0105494 <vprintfmt+0xea>
f010546d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105470:	85 c0                	test   %eax,%eax
f0105472:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105477:	0f 49 c8             	cmovns %eax,%ecx
f010547a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010547d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105480:	eb 8c                	jmp    f010540e <vprintfmt+0x64>
f0105482:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105485:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010548c:	eb 80                	jmp    f010540e <vprintfmt+0x64>
f010548e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105491:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0105494:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105498:	0f 89 70 ff ff ff    	jns    f010540e <vprintfmt+0x64>
				width = precision, precision = -1;
f010549e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01054a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01054a4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01054ab:	e9 5e ff ff ff       	jmp    f010540e <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01054b0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01054b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01054b6:	e9 53 ff ff ff       	jmp    f010540e <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01054bb:	8b 45 14             	mov    0x14(%ebp),%eax
f01054be:	8d 50 04             	lea    0x4(%eax),%edx
f01054c1:	89 55 14             	mov    %edx,0x14(%ebp)
f01054c4:	83 ec 08             	sub    $0x8,%esp
f01054c7:	53                   	push   %ebx
f01054c8:	ff 30                	pushl  (%eax)
f01054ca:	ff d6                	call   *%esi
			break;
f01054cc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01054cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01054d2:	e9 04 ff ff ff       	jmp    f01053db <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01054d7:	8b 45 14             	mov    0x14(%ebp),%eax
f01054da:	8d 50 04             	lea    0x4(%eax),%edx
f01054dd:	89 55 14             	mov    %edx,0x14(%ebp)
f01054e0:	8b 00                	mov    (%eax),%eax
f01054e2:	99                   	cltd   
f01054e3:	31 d0                	xor    %edx,%eax
f01054e5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01054e7:	83 f8 08             	cmp    $0x8,%eax
f01054ea:	7f 0b                	jg     f01054f7 <vprintfmt+0x14d>
f01054ec:	8b 14 85 c0 83 10 f0 	mov    -0xfef7c40(,%eax,4),%edx
f01054f3:	85 d2                	test   %edx,%edx
f01054f5:	75 18                	jne    f010550f <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
f01054f7:	50                   	push   %eax
f01054f8:	68 b2 81 10 f0       	push   $0xf01081b2
f01054fd:	53                   	push   %ebx
f01054fe:	56                   	push   %esi
f01054ff:	e8 89 fe ff ff       	call   f010538d <printfmt>
f0105504:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105507:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f010550a:	e9 cc fe ff ff       	jmp    f01053db <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
f010550f:	52                   	push   %edx
f0105510:	68 b0 6f 10 f0       	push   $0xf0106fb0
f0105515:	53                   	push   %ebx
f0105516:	56                   	push   %esi
f0105517:	e8 71 fe ff ff       	call   f010538d <printfmt>
f010551c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010551f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105522:	e9 b4 fe ff ff       	jmp    f01053db <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105527:	8b 45 14             	mov    0x14(%ebp),%eax
f010552a:	8d 50 04             	lea    0x4(%eax),%edx
f010552d:	89 55 14             	mov    %edx,0x14(%ebp)
f0105530:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105532:	85 ff                	test   %edi,%edi
f0105534:	b8 ab 81 10 f0       	mov    $0xf01081ab,%eax
f0105539:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f010553c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105540:	0f 8e 94 00 00 00    	jle    f01055da <vprintfmt+0x230>
f0105546:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010554a:	0f 84 98 00 00 00    	je     f01055e8 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105550:	83 ec 08             	sub    $0x8,%esp
f0105553:	ff 75 d0             	pushl  -0x30(%ebp)
f0105556:	57                   	push   %edi
f0105557:	e8 9a 03 00 00       	call   f01058f6 <strnlen>
f010555c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010555f:	29 c1                	sub    %eax,%ecx
f0105561:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0105564:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105567:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010556b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010556e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105571:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105573:	eb 0f                	jmp    f0105584 <vprintfmt+0x1da>
					putch(padc, putdat);
f0105575:	83 ec 08             	sub    $0x8,%esp
f0105578:	53                   	push   %ebx
f0105579:	ff 75 e0             	pushl  -0x20(%ebp)
f010557c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010557e:	83 ef 01             	sub    $0x1,%edi
f0105581:	83 c4 10             	add    $0x10,%esp
f0105584:	85 ff                	test   %edi,%edi
f0105586:	7f ed                	jg     f0105575 <vprintfmt+0x1cb>
f0105588:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010558b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010558e:	85 c9                	test   %ecx,%ecx
f0105590:	b8 00 00 00 00       	mov    $0x0,%eax
f0105595:	0f 49 c1             	cmovns %ecx,%eax
f0105598:	29 c1                	sub    %eax,%ecx
f010559a:	89 75 08             	mov    %esi,0x8(%ebp)
f010559d:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01055a0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01055a3:	89 cb                	mov    %ecx,%ebx
f01055a5:	eb 4d                	jmp    f01055f4 <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01055a7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01055ab:	74 1b                	je     f01055c8 <vprintfmt+0x21e>
f01055ad:	0f be c0             	movsbl %al,%eax
f01055b0:	83 e8 20             	sub    $0x20,%eax
f01055b3:	83 f8 5e             	cmp    $0x5e,%eax
f01055b6:	76 10                	jbe    f01055c8 <vprintfmt+0x21e>
					putch('?', putdat);
f01055b8:	83 ec 08             	sub    $0x8,%esp
f01055bb:	ff 75 0c             	pushl  0xc(%ebp)
f01055be:	6a 3f                	push   $0x3f
f01055c0:	ff 55 08             	call   *0x8(%ebp)
f01055c3:	83 c4 10             	add    $0x10,%esp
f01055c6:	eb 0d                	jmp    f01055d5 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
f01055c8:	83 ec 08             	sub    $0x8,%esp
f01055cb:	ff 75 0c             	pushl  0xc(%ebp)
f01055ce:	52                   	push   %edx
f01055cf:	ff 55 08             	call   *0x8(%ebp)
f01055d2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01055d5:	83 eb 01             	sub    $0x1,%ebx
f01055d8:	eb 1a                	jmp    f01055f4 <vprintfmt+0x24a>
f01055da:	89 75 08             	mov    %esi,0x8(%ebp)
f01055dd:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01055e0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01055e3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01055e6:	eb 0c                	jmp    f01055f4 <vprintfmt+0x24a>
f01055e8:	89 75 08             	mov    %esi,0x8(%ebp)
f01055eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01055ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01055f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01055f4:	83 c7 01             	add    $0x1,%edi
f01055f7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01055fb:	0f be d0             	movsbl %al,%edx
f01055fe:	85 d2                	test   %edx,%edx
f0105600:	74 23                	je     f0105625 <vprintfmt+0x27b>
f0105602:	85 f6                	test   %esi,%esi
f0105604:	78 a1                	js     f01055a7 <vprintfmt+0x1fd>
f0105606:	83 ee 01             	sub    $0x1,%esi
f0105609:	79 9c                	jns    f01055a7 <vprintfmt+0x1fd>
f010560b:	89 df                	mov    %ebx,%edi
f010560d:	8b 75 08             	mov    0x8(%ebp),%esi
f0105610:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105613:	eb 18                	jmp    f010562d <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105615:	83 ec 08             	sub    $0x8,%esp
f0105618:	53                   	push   %ebx
f0105619:	6a 20                	push   $0x20
f010561b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010561d:	83 ef 01             	sub    $0x1,%edi
f0105620:	83 c4 10             	add    $0x10,%esp
f0105623:	eb 08                	jmp    f010562d <vprintfmt+0x283>
f0105625:	89 df                	mov    %ebx,%edi
f0105627:	8b 75 08             	mov    0x8(%ebp),%esi
f010562a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010562d:	85 ff                	test   %edi,%edi
f010562f:	7f e4                	jg     f0105615 <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105631:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105634:	e9 a2 fd ff ff       	jmp    f01053db <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105639:	83 fa 01             	cmp    $0x1,%edx
f010563c:	7e 16                	jle    f0105654 <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
f010563e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105641:	8d 50 08             	lea    0x8(%eax),%edx
f0105644:	89 55 14             	mov    %edx,0x14(%ebp)
f0105647:	8b 50 04             	mov    0x4(%eax),%edx
f010564a:	8b 00                	mov    (%eax),%eax
f010564c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010564f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105652:	eb 32                	jmp    f0105686 <vprintfmt+0x2dc>
	else if (lflag)
f0105654:	85 d2                	test   %edx,%edx
f0105656:	74 18                	je     f0105670 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
f0105658:	8b 45 14             	mov    0x14(%ebp),%eax
f010565b:	8d 50 04             	lea    0x4(%eax),%edx
f010565e:	89 55 14             	mov    %edx,0x14(%ebp)
f0105661:	8b 00                	mov    (%eax),%eax
f0105663:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105666:	89 c1                	mov    %eax,%ecx
f0105668:	c1 f9 1f             	sar    $0x1f,%ecx
f010566b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010566e:	eb 16                	jmp    f0105686 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
f0105670:	8b 45 14             	mov    0x14(%ebp),%eax
f0105673:	8d 50 04             	lea    0x4(%eax),%edx
f0105676:	89 55 14             	mov    %edx,0x14(%ebp)
f0105679:	8b 00                	mov    (%eax),%eax
f010567b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010567e:	89 c1                	mov    %eax,%ecx
f0105680:	c1 f9 1f             	sar    $0x1f,%ecx
f0105683:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105686:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105689:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010568c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105691:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105695:	79 74                	jns    f010570b <vprintfmt+0x361>
				putch('-', putdat);
f0105697:	83 ec 08             	sub    $0x8,%esp
f010569a:	53                   	push   %ebx
f010569b:	6a 2d                	push   $0x2d
f010569d:	ff d6                	call   *%esi
				num = -(long long) num;
f010569f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01056a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01056a5:	f7 d8                	neg    %eax
f01056a7:	83 d2 00             	adc    $0x0,%edx
f01056aa:	f7 da                	neg    %edx
f01056ac:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01056af:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01056b4:	eb 55                	jmp    f010570b <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01056b6:	8d 45 14             	lea    0x14(%ebp),%eax
f01056b9:	e8 78 fc ff ff       	call   f0105336 <getuint>
			base = 10;
f01056be:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01056c3:	eb 46                	jmp    f010570b <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
f01056c5:	8d 45 14             	lea    0x14(%ebp),%eax
f01056c8:	e8 69 fc ff ff       	call   f0105336 <getuint>
      base = 8;
f01056cd:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
f01056d2:	eb 37                	jmp    f010570b <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
f01056d4:	83 ec 08             	sub    $0x8,%esp
f01056d7:	53                   	push   %ebx
f01056d8:	6a 30                	push   $0x30
f01056da:	ff d6                	call   *%esi
			putch('x', putdat);
f01056dc:	83 c4 08             	add    $0x8,%esp
f01056df:	53                   	push   %ebx
f01056e0:	6a 78                	push   $0x78
f01056e2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01056e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01056e7:	8d 50 04             	lea    0x4(%eax),%edx
f01056ea:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01056ed:	8b 00                	mov    (%eax),%eax
f01056ef:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01056f4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01056f7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01056fc:	eb 0d                	jmp    f010570b <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01056fe:	8d 45 14             	lea    0x14(%ebp),%eax
f0105701:	e8 30 fc ff ff       	call   f0105336 <getuint>
			base = 16;
f0105706:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f010570b:	83 ec 0c             	sub    $0xc,%esp
f010570e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105712:	57                   	push   %edi
f0105713:	ff 75 e0             	pushl  -0x20(%ebp)
f0105716:	51                   	push   %ecx
f0105717:	52                   	push   %edx
f0105718:	50                   	push   %eax
f0105719:	89 da                	mov    %ebx,%edx
f010571b:	89 f0                	mov    %esi,%eax
f010571d:	e8 65 fb ff ff       	call   f0105287 <printnum>
			break;
f0105722:	83 c4 20             	add    $0x20,%esp
f0105725:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105728:	e9 ae fc ff ff       	jmp    f01053db <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010572d:	83 ec 08             	sub    $0x8,%esp
f0105730:	53                   	push   %ebx
f0105731:	51                   	push   %ecx
f0105732:	ff d6                	call   *%esi
			break;
f0105734:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105737:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010573a:	e9 9c fc ff ff       	jmp    f01053db <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010573f:	83 fa 01             	cmp    $0x1,%edx
f0105742:	7e 0d                	jle    f0105751 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
f0105744:	8b 45 14             	mov    0x14(%ebp),%eax
f0105747:	8d 50 08             	lea    0x8(%eax),%edx
f010574a:	89 55 14             	mov    %edx,0x14(%ebp)
f010574d:	8b 00                	mov    (%eax),%eax
f010574f:	eb 1c                	jmp    f010576d <vprintfmt+0x3c3>
	else if (lflag)
f0105751:	85 d2                	test   %edx,%edx
f0105753:	74 0d                	je     f0105762 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
f0105755:	8b 45 14             	mov    0x14(%ebp),%eax
f0105758:	8d 50 04             	lea    0x4(%eax),%edx
f010575b:	89 55 14             	mov    %edx,0x14(%ebp)
f010575e:	8b 00                	mov    (%eax),%eax
f0105760:	eb 0b                	jmp    f010576d <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
f0105762:	8b 45 14             	mov    0x14(%ebp),%eax
f0105765:	8d 50 04             	lea    0x4(%eax),%edx
f0105768:	89 55 14             	mov    %edx,0x14(%ebp)
f010576b:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
f010576d:	a3 88 7e 22 f0       	mov    %eax,0xf0227e88
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105772:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
f0105775:	e9 61 fc ff ff       	jmp    f01053db <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010577a:	83 ec 08             	sub    $0x8,%esp
f010577d:	53                   	push   %ebx
f010577e:	6a 25                	push   $0x25
f0105780:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105782:	83 c4 10             	add    $0x10,%esp
f0105785:	eb 03                	jmp    f010578a <vprintfmt+0x3e0>
f0105787:	83 ef 01             	sub    $0x1,%edi
f010578a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010578e:	75 f7                	jne    f0105787 <vprintfmt+0x3dd>
f0105790:	e9 46 fc ff ff       	jmp    f01053db <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
f0105795:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105798:	5b                   	pop    %ebx
f0105799:	5e                   	pop    %esi
f010579a:	5f                   	pop    %edi
f010579b:	5d                   	pop    %ebp
f010579c:	c3                   	ret    

f010579d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010579d:	55                   	push   %ebp
f010579e:	89 e5                	mov    %esp,%ebp
f01057a0:	83 ec 18             	sub    $0x18,%esp
f01057a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01057a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01057a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01057ac:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01057b0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01057b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01057ba:	85 c0                	test   %eax,%eax
f01057bc:	74 26                	je     f01057e4 <vsnprintf+0x47>
f01057be:	85 d2                	test   %edx,%edx
f01057c0:	7e 22                	jle    f01057e4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01057c2:	ff 75 14             	pushl  0x14(%ebp)
f01057c5:	ff 75 10             	pushl  0x10(%ebp)
f01057c8:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01057cb:	50                   	push   %eax
f01057cc:	68 70 53 10 f0       	push   $0xf0105370
f01057d1:	e8 d4 fb ff ff       	call   f01053aa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01057d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01057d9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01057dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01057df:	83 c4 10             	add    $0x10,%esp
f01057e2:	eb 05                	jmp    f01057e9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01057e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01057e9:	c9                   	leave  
f01057ea:	c3                   	ret    

f01057eb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01057eb:	55                   	push   %ebp
f01057ec:	89 e5                	mov    %esp,%ebp
f01057ee:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01057f1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01057f4:	50                   	push   %eax
f01057f5:	ff 75 10             	pushl  0x10(%ebp)
f01057f8:	ff 75 0c             	pushl  0xc(%ebp)
f01057fb:	ff 75 08             	pushl  0x8(%ebp)
f01057fe:	e8 9a ff ff ff       	call   f010579d <vsnprintf>
	va_end(ap);

	return rc;
}
f0105803:	c9                   	leave  
f0105804:	c3                   	ret    

f0105805 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105805:	55                   	push   %ebp
f0105806:	89 e5                	mov    %esp,%ebp
f0105808:	57                   	push   %edi
f0105809:	56                   	push   %esi
f010580a:	53                   	push   %ebx
f010580b:	83 ec 0c             	sub    $0xc,%esp
f010580e:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105811:	85 c0                	test   %eax,%eax
f0105813:	74 11                	je     f0105826 <readline+0x21>
		cprintf("%s", prompt);
f0105815:	83 ec 08             	sub    $0x8,%esp
f0105818:	50                   	push   %eax
f0105819:	68 b0 6f 10 f0       	push   $0xf0106fb0
f010581e:	e8 8d e2 ff ff       	call   f0103ab0 <cprintf>
f0105823:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0105826:	83 ec 0c             	sub    $0xc,%esp
f0105829:	6a 00                	push   $0x0
f010582b:	e8 64 b0 ff ff       	call   f0100894 <iscons>
f0105830:	89 c7                	mov    %eax,%edi
f0105832:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105835:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010583a:	e8 44 b0 ff ff       	call   f0100883 <getchar>
f010583f:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105841:	85 c0                	test   %eax,%eax
f0105843:	79 18                	jns    f010585d <readline+0x58>
			cprintf("read error: %e\n", c);
f0105845:	83 ec 08             	sub    $0x8,%esp
f0105848:	50                   	push   %eax
f0105849:	68 e4 83 10 f0       	push   $0xf01083e4
f010584e:	e8 5d e2 ff ff       	call   f0103ab0 <cprintf>
			return NULL;
f0105853:	83 c4 10             	add    $0x10,%esp
f0105856:	b8 00 00 00 00       	mov    $0x0,%eax
f010585b:	eb 79                	jmp    f01058d6 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010585d:	83 f8 08             	cmp    $0x8,%eax
f0105860:	0f 94 c2             	sete   %dl
f0105863:	83 f8 7f             	cmp    $0x7f,%eax
f0105866:	0f 94 c0             	sete   %al
f0105869:	08 c2                	or     %al,%dl
f010586b:	74 1a                	je     f0105887 <readline+0x82>
f010586d:	85 f6                	test   %esi,%esi
f010586f:	7e 16                	jle    f0105887 <readline+0x82>
			if (echoing)
f0105871:	85 ff                	test   %edi,%edi
f0105873:	74 0d                	je     f0105882 <readline+0x7d>
				cputchar('\b');
f0105875:	83 ec 0c             	sub    $0xc,%esp
f0105878:	6a 08                	push   $0x8
f010587a:	e8 f4 af ff ff       	call   f0100873 <cputchar>
f010587f:	83 c4 10             	add    $0x10,%esp
			i--;
f0105882:	83 ee 01             	sub    $0x1,%esi
f0105885:	eb b3                	jmp    f010583a <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105887:	83 fb 1f             	cmp    $0x1f,%ebx
f010588a:	7e 23                	jle    f01058af <readline+0xaa>
f010588c:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105892:	7f 1b                	jg     f01058af <readline+0xaa>
			if (echoing)
f0105894:	85 ff                	test   %edi,%edi
f0105896:	74 0c                	je     f01058a4 <readline+0x9f>
				cputchar(c);
f0105898:	83 ec 0c             	sub    $0xc,%esp
f010589b:	53                   	push   %ebx
f010589c:	e8 d2 af ff ff       	call   f0100873 <cputchar>
f01058a1:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01058a4:	88 9e 80 7a 22 f0    	mov    %bl,-0xfdd8580(%esi)
f01058aa:	8d 76 01             	lea    0x1(%esi),%esi
f01058ad:	eb 8b                	jmp    f010583a <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01058af:	83 fb 0a             	cmp    $0xa,%ebx
f01058b2:	74 05                	je     f01058b9 <readline+0xb4>
f01058b4:	83 fb 0d             	cmp    $0xd,%ebx
f01058b7:	75 81                	jne    f010583a <readline+0x35>
			if (echoing)
f01058b9:	85 ff                	test   %edi,%edi
f01058bb:	74 0d                	je     f01058ca <readline+0xc5>
				cputchar('\n');
f01058bd:	83 ec 0c             	sub    $0xc,%esp
f01058c0:	6a 0a                	push   $0xa
f01058c2:	e8 ac af ff ff       	call   f0100873 <cputchar>
f01058c7:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01058ca:	c6 86 80 7a 22 f0 00 	movb   $0x0,-0xfdd8580(%esi)
			return buf;
f01058d1:	b8 80 7a 22 f0       	mov    $0xf0227a80,%eax
		}
	}
}
f01058d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01058d9:	5b                   	pop    %ebx
f01058da:	5e                   	pop    %esi
f01058db:	5f                   	pop    %edi
f01058dc:	5d                   	pop    %ebp
f01058dd:	c3                   	ret    

f01058de <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01058de:	55                   	push   %ebp
f01058df:	89 e5                	mov    %esp,%ebp
f01058e1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01058e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01058e9:	eb 03                	jmp    f01058ee <strlen+0x10>
		n++;
f01058eb:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01058ee:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01058f2:	75 f7                	jne    f01058eb <strlen+0xd>
		n++;
	return n;
}
f01058f4:	5d                   	pop    %ebp
f01058f5:	c3                   	ret    

f01058f6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01058f6:	55                   	push   %ebp
f01058f7:	89 e5                	mov    %esp,%ebp
f01058f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01058fc:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01058ff:	ba 00 00 00 00       	mov    $0x0,%edx
f0105904:	eb 03                	jmp    f0105909 <strnlen+0x13>
		n++;
f0105906:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105909:	39 c2                	cmp    %eax,%edx
f010590b:	74 08                	je     f0105915 <strnlen+0x1f>
f010590d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105911:	75 f3                	jne    f0105906 <strnlen+0x10>
f0105913:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0105915:	5d                   	pop    %ebp
f0105916:	c3                   	ret    

f0105917 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105917:	55                   	push   %ebp
f0105918:	89 e5                	mov    %esp,%ebp
f010591a:	53                   	push   %ebx
f010591b:	8b 45 08             	mov    0x8(%ebp),%eax
f010591e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105921:	89 c2                	mov    %eax,%edx
f0105923:	83 c2 01             	add    $0x1,%edx
f0105926:	83 c1 01             	add    $0x1,%ecx
f0105929:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010592d:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105930:	84 db                	test   %bl,%bl
f0105932:	75 ef                	jne    f0105923 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105934:	5b                   	pop    %ebx
f0105935:	5d                   	pop    %ebp
f0105936:	c3                   	ret    

f0105937 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105937:	55                   	push   %ebp
f0105938:	89 e5                	mov    %esp,%ebp
f010593a:	53                   	push   %ebx
f010593b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010593e:	53                   	push   %ebx
f010593f:	e8 9a ff ff ff       	call   f01058de <strlen>
f0105944:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105947:	ff 75 0c             	pushl  0xc(%ebp)
f010594a:	01 d8                	add    %ebx,%eax
f010594c:	50                   	push   %eax
f010594d:	e8 c5 ff ff ff       	call   f0105917 <strcpy>
	return dst;
}
f0105952:	89 d8                	mov    %ebx,%eax
f0105954:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105957:	c9                   	leave  
f0105958:	c3                   	ret    

f0105959 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105959:	55                   	push   %ebp
f010595a:	89 e5                	mov    %esp,%ebp
f010595c:	56                   	push   %esi
f010595d:	53                   	push   %ebx
f010595e:	8b 75 08             	mov    0x8(%ebp),%esi
f0105961:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105964:	89 f3                	mov    %esi,%ebx
f0105966:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105969:	89 f2                	mov    %esi,%edx
f010596b:	eb 0f                	jmp    f010597c <strncpy+0x23>
		*dst++ = *src;
f010596d:	83 c2 01             	add    $0x1,%edx
f0105970:	0f b6 01             	movzbl (%ecx),%eax
f0105973:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105976:	80 39 01             	cmpb   $0x1,(%ecx)
f0105979:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010597c:	39 da                	cmp    %ebx,%edx
f010597e:	75 ed                	jne    f010596d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105980:	89 f0                	mov    %esi,%eax
f0105982:	5b                   	pop    %ebx
f0105983:	5e                   	pop    %esi
f0105984:	5d                   	pop    %ebp
f0105985:	c3                   	ret    

f0105986 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105986:	55                   	push   %ebp
f0105987:	89 e5                	mov    %esp,%ebp
f0105989:	56                   	push   %esi
f010598a:	53                   	push   %ebx
f010598b:	8b 75 08             	mov    0x8(%ebp),%esi
f010598e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105991:	8b 55 10             	mov    0x10(%ebp),%edx
f0105994:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105996:	85 d2                	test   %edx,%edx
f0105998:	74 21                	je     f01059bb <strlcpy+0x35>
f010599a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010599e:	89 f2                	mov    %esi,%edx
f01059a0:	eb 09                	jmp    f01059ab <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01059a2:	83 c2 01             	add    $0x1,%edx
f01059a5:	83 c1 01             	add    $0x1,%ecx
f01059a8:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01059ab:	39 c2                	cmp    %eax,%edx
f01059ad:	74 09                	je     f01059b8 <strlcpy+0x32>
f01059af:	0f b6 19             	movzbl (%ecx),%ebx
f01059b2:	84 db                	test   %bl,%bl
f01059b4:	75 ec                	jne    f01059a2 <strlcpy+0x1c>
f01059b6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01059b8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01059bb:	29 f0                	sub    %esi,%eax
}
f01059bd:	5b                   	pop    %ebx
f01059be:	5e                   	pop    %esi
f01059bf:	5d                   	pop    %ebp
f01059c0:	c3                   	ret    

f01059c1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01059c1:	55                   	push   %ebp
f01059c2:	89 e5                	mov    %esp,%ebp
f01059c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01059c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01059ca:	eb 06                	jmp    f01059d2 <strcmp+0x11>
		p++, q++;
f01059cc:	83 c1 01             	add    $0x1,%ecx
f01059cf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01059d2:	0f b6 01             	movzbl (%ecx),%eax
f01059d5:	84 c0                	test   %al,%al
f01059d7:	74 04                	je     f01059dd <strcmp+0x1c>
f01059d9:	3a 02                	cmp    (%edx),%al
f01059db:	74 ef                	je     f01059cc <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01059dd:	0f b6 c0             	movzbl %al,%eax
f01059e0:	0f b6 12             	movzbl (%edx),%edx
f01059e3:	29 d0                	sub    %edx,%eax
}
f01059e5:	5d                   	pop    %ebp
f01059e6:	c3                   	ret    

f01059e7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01059e7:	55                   	push   %ebp
f01059e8:	89 e5                	mov    %esp,%ebp
f01059ea:	53                   	push   %ebx
f01059eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01059ee:	8b 55 0c             	mov    0xc(%ebp),%edx
f01059f1:	89 c3                	mov    %eax,%ebx
f01059f3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01059f6:	eb 06                	jmp    f01059fe <strncmp+0x17>
		n--, p++, q++;
f01059f8:	83 c0 01             	add    $0x1,%eax
f01059fb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01059fe:	39 d8                	cmp    %ebx,%eax
f0105a00:	74 15                	je     f0105a17 <strncmp+0x30>
f0105a02:	0f b6 08             	movzbl (%eax),%ecx
f0105a05:	84 c9                	test   %cl,%cl
f0105a07:	74 04                	je     f0105a0d <strncmp+0x26>
f0105a09:	3a 0a                	cmp    (%edx),%cl
f0105a0b:	74 eb                	je     f01059f8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105a0d:	0f b6 00             	movzbl (%eax),%eax
f0105a10:	0f b6 12             	movzbl (%edx),%edx
f0105a13:	29 d0                	sub    %edx,%eax
f0105a15:	eb 05                	jmp    f0105a1c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105a17:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105a1c:	5b                   	pop    %ebx
f0105a1d:	5d                   	pop    %ebp
f0105a1e:	c3                   	ret    

f0105a1f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105a1f:	55                   	push   %ebp
f0105a20:	89 e5                	mov    %esp,%ebp
f0105a22:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a25:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105a29:	eb 07                	jmp    f0105a32 <strchr+0x13>
		if (*s == c)
f0105a2b:	38 ca                	cmp    %cl,%dl
f0105a2d:	74 0f                	je     f0105a3e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105a2f:	83 c0 01             	add    $0x1,%eax
f0105a32:	0f b6 10             	movzbl (%eax),%edx
f0105a35:	84 d2                	test   %dl,%dl
f0105a37:	75 f2                	jne    f0105a2b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105a39:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105a3e:	5d                   	pop    %ebp
f0105a3f:	c3                   	ret    

f0105a40 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105a40:	55                   	push   %ebp
f0105a41:	89 e5                	mov    %esp,%ebp
f0105a43:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a46:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105a4a:	eb 03                	jmp    f0105a4f <strfind+0xf>
f0105a4c:	83 c0 01             	add    $0x1,%eax
f0105a4f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105a52:	38 ca                	cmp    %cl,%dl
f0105a54:	74 04                	je     f0105a5a <strfind+0x1a>
f0105a56:	84 d2                	test   %dl,%dl
f0105a58:	75 f2                	jne    f0105a4c <strfind+0xc>
			break;
	return (char *) s;
}
f0105a5a:	5d                   	pop    %ebp
f0105a5b:	c3                   	ret    

f0105a5c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105a5c:	55                   	push   %ebp
f0105a5d:	89 e5                	mov    %esp,%ebp
f0105a5f:	57                   	push   %edi
f0105a60:	56                   	push   %esi
f0105a61:	53                   	push   %ebx
f0105a62:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105a65:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105a68:	85 c9                	test   %ecx,%ecx
f0105a6a:	74 36                	je     f0105aa2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105a6c:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105a72:	75 28                	jne    f0105a9c <memset+0x40>
f0105a74:	f6 c1 03             	test   $0x3,%cl
f0105a77:	75 23                	jne    f0105a9c <memset+0x40>
		c &= 0xFF;
f0105a79:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105a7d:	89 d3                	mov    %edx,%ebx
f0105a7f:	c1 e3 08             	shl    $0x8,%ebx
f0105a82:	89 d6                	mov    %edx,%esi
f0105a84:	c1 e6 18             	shl    $0x18,%esi
f0105a87:	89 d0                	mov    %edx,%eax
f0105a89:	c1 e0 10             	shl    $0x10,%eax
f0105a8c:	09 f0                	or     %esi,%eax
f0105a8e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105a90:	89 d8                	mov    %ebx,%eax
f0105a92:	09 d0                	or     %edx,%eax
f0105a94:	c1 e9 02             	shr    $0x2,%ecx
f0105a97:	fc                   	cld    
f0105a98:	f3 ab                	rep stos %eax,%es:(%edi)
f0105a9a:	eb 06                	jmp    f0105aa2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105a9f:	fc                   	cld    
f0105aa0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105aa2:	89 f8                	mov    %edi,%eax
f0105aa4:	5b                   	pop    %ebx
f0105aa5:	5e                   	pop    %esi
f0105aa6:	5f                   	pop    %edi
f0105aa7:	5d                   	pop    %ebp
f0105aa8:	c3                   	ret    

f0105aa9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105aa9:	55                   	push   %ebp
f0105aaa:	89 e5                	mov    %esp,%ebp
f0105aac:	57                   	push   %edi
f0105aad:	56                   	push   %esi
f0105aae:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ab1:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105ab4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105ab7:	39 c6                	cmp    %eax,%esi
f0105ab9:	73 35                	jae    f0105af0 <memmove+0x47>
f0105abb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105abe:	39 d0                	cmp    %edx,%eax
f0105ac0:	73 2e                	jae    f0105af0 <memmove+0x47>
		s += n;
		d += n;
f0105ac2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105ac5:	89 d6                	mov    %edx,%esi
f0105ac7:	09 fe                	or     %edi,%esi
f0105ac9:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105acf:	75 13                	jne    f0105ae4 <memmove+0x3b>
f0105ad1:	f6 c1 03             	test   $0x3,%cl
f0105ad4:	75 0e                	jne    f0105ae4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105ad6:	83 ef 04             	sub    $0x4,%edi
f0105ad9:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105adc:	c1 e9 02             	shr    $0x2,%ecx
f0105adf:	fd                   	std    
f0105ae0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105ae2:	eb 09                	jmp    f0105aed <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105ae4:	83 ef 01             	sub    $0x1,%edi
f0105ae7:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105aea:	fd                   	std    
f0105aeb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105aed:	fc                   	cld    
f0105aee:	eb 1d                	jmp    f0105b0d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105af0:	89 f2                	mov    %esi,%edx
f0105af2:	09 c2                	or     %eax,%edx
f0105af4:	f6 c2 03             	test   $0x3,%dl
f0105af7:	75 0f                	jne    f0105b08 <memmove+0x5f>
f0105af9:	f6 c1 03             	test   $0x3,%cl
f0105afc:	75 0a                	jne    f0105b08 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105afe:	c1 e9 02             	shr    $0x2,%ecx
f0105b01:	89 c7                	mov    %eax,%edi
f0105b03:	fc                   	cld    
f0105b04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105b06:	eb 05                	jmp    f0105b0d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105b08:	89 c7                	mov    %eax,%edi
f0105b0a:	fc                   	cld    
f0105b0b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105b0d:	5e                   	pop    %esi
f0105b0e:	5f                   	pop    %edi
f0105b0f:	5d                   	pop    %ebp
f0105b10:	c3                   	ret    

f0105b11 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105b11:	55                   	push   %ebp
f0105b12:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105b14:	ff 75 10             	pushl  0x10(%ebp)
f0105b17:	ff 75 0c             	pushl  0xc(%ebp)
f0105b1a:	ff 75 08             	pushl  0x8(%ebp)
f0105b1d:	e8 87 ff ff ff       	call   f0105aa9 <memmove>
}
f0105b22:	c9                   	leave  
f0105b23:	c3                   	ret    

f0105b24 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105b24:	55                   	push   %ebp
f0105b25:	89 e5                	mov    %esp,%ebp
f0105b27:	56                   	push   %esi
f0105b28:	53                   	push   %ebx
f0105b29:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b2c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105b2f:	89 c6                	mov    %eax,%esi
f0105b31:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105b34:	eb 1a                	jmp    f0105b50 <memcmp+0x2c>
		if (*s1 != *s2)
f0105b36:	0f b6 08             	movzbl (%eax),%ecx
f0105b39:	0f b6 1a             	movzbl (%edx),%ebx
f0105b3c:	38 d9                	cmp    %bl,%cl
f0105b3e:	74 0a                	je     f0105b4a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105b40:	0f b6 c1             	movzbl %cl,%eax
f0105b43:	0f b6 db             	movzbl %bl,%ebx
f0105b46:	29 d8                	sub    %ebx,%eax
f0105b48:	eb 0f                	jmp    f0105b59 <memcmp+0x35>
		s1++, s2++;
f0105b4a:	83 c0 01             	add    $0x1,%eax
f0105b4d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105b50:	39 f0                	cmp    %esi,%eax
f0105b52:	75 e2                	jne    f0105b36 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105b54:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105b59:	5b                   	pop    %ebx
f0105b5a:	5e                   	pop    %esi
f0105b5b:	5d                   	pop    %ebp
f0105b5c:	c3                   	ret    

f0105b5d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105b5d:	55                   	push   %ebp
f0105b5e:	89 e5                	mov    %esp,%ebp
f0105b60:	53                   	push   %ebx
f0105b61:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0105b64:	89 c1                	mov    %eax,%ecx
f0105b66:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0105b69:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105b6d:	eb 0a                	jmp    f0105b79 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105b6f:	0f b6 10             	movzbl (%eax),%edx
f0105b72:	39 da                	cmp    %ebx,%edx
f0105b74:	74 07                	je     f0105b7d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105b76:	83 c0 01             	add    $0x1,%eax
f0105b79:	39 c8                	cmp    %ecx,%eax
f0105b7b:	72 f2                	jb     f0105b6f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105b7d:	5b                   	pop    %ebx
f0105b7e:	5d                   	pop    %ebp
f0105b7f:	c3                   	ret    

f0105b80 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105b80:	55                   	push   %ebp
f0105b81:	89 e5                	mov    %esp,%ebp
f0105b83:	57                   	push   %edi
f0105b84:	56                   	push   %esi
f0105b85:	53                   	push   %ebx
f0105b86:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105b89:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105b8c:	eb 03                	jmp    f0105b91 <strtol+0x11>
		s++;
f0105b8e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105b91:	0f b6 01             	movzbl (%ecx),%eax
f0105b94:	3c 20                	cmp    $0x20,%al
f0105b96:	74 f6                	je     f0105b8e <strtol+0xe>
f0105b98:	3c 09                	cmp    $0x9,%al
f0105b9a:	74 f2                	je     f0105b8e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105b9c:	3c 2b                	cmp    $0x2b,%al
f0105b9e:	75 0a                	jne    f0105baa <strtol+0x2a>
		s++;
f0105ba0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105ba3:	bf 00 00 00 00       	mov    $0x0,%edi
f0105ba8:	eb 11                	jmp    f0105bbb <strtol+0x3b>
f0105baa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105baf:	3c 2d                	cmp    $0x2d,%al
f0105bb1:	75 08                	jne    f0105bbb <strtol+0x3b>
		s++, neg = 1;
f0105bb3:	83 c1 01             	add    $0x1,%ecx
f0105bb6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105bbb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105bc1:	75 15                	jne    f0105bd8 <strtol+0x58>
f0105bc3:	80 39 30             	cmpb   $0x30,(%ecx)
f0105bc6:	75 10                	jne    f0105bd8 <strtol+0x58>
f0105bc8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105bcc:	75 7c                	jne    f0105c4a <strtol+0xca>
		s += 2, base = 16;
f0105bce:	83 c1 02             	add    $0x2,%ecx
f0105bd1:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105bd6:	eb 16                	jmp    f0105bee <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105bd8:	85 db                	test   %ebx,%ebx
f0105bda:	75 12                	jne    f0105bee <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105bdc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105be1:	80 39 30             	cmpb   $0x30,(%ecx)
f0105be4:	75 08                	jne    f0105bee <strtol+0x6e>
		s++, base = 8;
f0105be6:	83 c1 01             	add    $0x1,%ecx
f0105be9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105bee:	b8 00 00 00 00       	mov    $0x0,%eax
f0105bf3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105bf6:	0f b6 11             	movzbl (%ecx),%edx
f0105bf9:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105bfc:	89 f3                	mov    %esi,%ebx
f0105bfe:	80 fb 09             	cmp    $0x9,%bl
f0105c01:	77 08                	ja     f0105c0b <strtol+0x8b>
			dig = *s - '0';
f0105c03:	0f be d2             	movsbl %dl,%edx
f0105c06:	83 ea 30             	sub    $0x30,%edx
f0105c09:	eb 22                	jmp    f0105c2d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105c0b:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105c0e:	89 f3                	mov    %esi,%ebx
f0105c10:	80 fb 19             	cmp    $0x19,%bl
f0105c13:	77 08                	ja     f0105c1d <strtol+0x9d>
			dig = *s - 'a' + 10;
f0105c15:	0f be d2             	movsbl %dl,%edx
f0105c18:	83 ea 57             	sub    $0x57,%edx
f0105c1b:	eb 10                	jmp    f0105c2d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0105c1d:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105c20:	89 f3                	mov    %esi,%ebx
f0105c22:	80 fb 19             	cmp    $0x19,%bl
f0105c25:	77 16                	ja     f0105c3d <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105c27:	0f be d2             	movsbl %dl,%edx
f0105c2a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105c2d:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105c30:	7d 0b                	jge    f0105c3d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0105c32:	83 c1 01             	add    $0x1,%ecx
f0105c35:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105c39:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105c3b:	eb b9                	jmp    f0105bf6 <strtol+0x76>

	if (endptr)
f0105c3d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105c41:	74 0d                	je     f0105c50 <strtol+0xd0>
		*endptr = (char *) s;
f0105c43:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105c46:	89 0e                	mov    %ecx,(%esi)
f0105c48:	eb 06                	jmp    f0105c50 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105c4a:	85 db                	test   %ebx,%ebx
f0105c4c:	74 98                	je     f0105be6 <strtol+0x66>
f0105c4e:	eb 9e                	jmp    f0105bee <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105c50:	89 c2                	mov    %eax,%edx
f0105c52:	f7 da                	neg    %edx
f0105c54:	85 ff                	test   %edi,%edi
f0105c56:	0f 45 c2             	cmovne %edx,%eax
}
f0105c59:	5b                   	pop    %ebx
f0105c5a:	5e                   	pop    %esi
f0105c5b:	5f                   	pop    %edi
f0105c5c:	5d                   	pop    %ebp
f0105c5d:	c3                   	ret    
f0105c5e:	66 90                	xchg   %ax,%ax

f0105c60 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105c60:	fa                   	cli    

	xorw    %ax, %ax
f0105c61:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105c63:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105c65:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105c67:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105c69:	0f 01 16             	lgdtl  (%esi)
f0105c6c:	74 70                	je     f0105cde <mpsearch1+0x3>
	movl    %cr0, %eax
f0105c6e:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105c71:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105c75:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105c78:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105c7e:	08 00                	or     %al,(%eax)

f0105c80 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105c80:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105c84:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105c86:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105c88:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105c8a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105c8e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105c90:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105c92:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f0105c97:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105c9a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105c9d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105ca2:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105ca5:	8b 25 84 7e 22 f0    	mov    0xf0227e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105cab:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105cb0:	b8 b7 02 10 f0       	mov    $0xf01002b7,%eax
	call    *%eax
f0105cb5:	ff d0                	call   *%eax

f0105cb7 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105cb7:	eb fe                	jmp    f0105cb7 <spin>
f0105cb9:	8d 76 00             	lea    0x0(%esi),%esi

f0105cbc <gdt>:
	...
f0105cc4:	ff                   	(bad)  
f0105cc5:	ff 00                	incl   (%eax)
f0105cc7:	00 00                	add    %al,(%eax)
f0105cc9:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105cd0:	00                   	.byte 0x0
f0105cd1:	92                   	xchg   %eax,%edx
f0105cd2:	cf                   	iret   
	...

f0105cd4 <gdtdesc>:
f0105cd4:	17                   	pop    %ss
f0105cd5:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105cda <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105cda:	90                   	nop

f0105cdb <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105cdb:	55                   	push   %ebp
f0105cdc:	89 e5                	mov    %esp,%ebp
f0105cde:	57                   	push   %edi
f0105cdf:	56                   	push   %esi
f0105ce0:	53                   	push   %ebx
f0105ce1:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105ce4:	8b 0d 90 7e 22 f0    	mov    0xf0227e90,%ecx
f0105cea:	89 c3                	mov    %eax,%ebx
f0105cec:	c1 eb 0c             	shr    $0xc,%ebx
f0105cef:	39 cb                	cmp    %ecx,%ebx
f0105cf1:	72 12                	jb     f0105d05 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105cf3:	50                   	push   %eax
f0105cf4:	68 5c 68 10 f0       	push   $0xf010685c
f0105cf9:	6a 57                	push   $0x57
f0105cfb:	68 81 85 10 f0       	push   $0xf0108581
f0105d00:	e8 8f a3 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0105d05:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105d0b:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105d0d:	89 c2                	mov    %eax,%edx
f0105d0f:	c1 ea 0c             	shr    $0xc,%edx
f0105d12:	39 ca                	cmp    %ecx,%edx
f0105d14:	72 12                	jb     f0105d28 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105d16:	50                   	push   %eax
f0105d17:	68 5c 68 10 f0       	push   $0xf010685c
f0105d1c:	6a 57                	push   $0x57
f0105d1e:	68 81 85 10 f0       	push   $0xf0108581
f0105d23:	e8 6c a3 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0105d28:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105d2e:	eb 2f                	jmp    f0105d5f <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105d30:	83 ec 04             	sub    $0x4,%esp
f0105d33:	6a 04                	push   $0x4
f0105d35:	68 91 85 10 f0       	push   $0xf0108591
f0105d3a:	53                   	push   %ebx
f0105d3b:	e8 e4 fd ff ff       	call   f0105b24 <memcmp>
f0105d40:	83 c4 10             	add    $0x10,%esp
f0105d43:	85 c0                	test   %eax,%eax
f0105d45:	75 15                	jne    f0105d5c <mpsearch1+0x81>
f0105d47:	89 da                	mov    %ebx,%edx
f0105d49:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105d4c:	0f b6 0a             	movzbl (%edx),%ecx
f0105d4f:	01 c8                	add    %ecx,%eax
f0105d51:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105d54:	39 d7                	cmp    %edx,%edi
f0105d56:	75 f4                	jne    f0105d4c <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105d58:	84 c0                	test   %al,%al
f0105d5a:	74 0e                	je     f0105d6a <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105d5c:	83 c3 10             	add    $0x10,%ebx
f0105d5f:	39 f3                	cmp    %esi,%ebx
f0105d61:	72 cd                	jb     f0105d30 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105d63:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d68:	eb 02                	jmp    f0105d6c <mpsearch1+0x91>
f0105d6a:	89 d8                	mov    %ebx,%eax
}
f0105d6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105d6f:	5b                   	pop    %ebx
f0105d70:	5e                   	pop    %esi
f0105d71:	5f                   	pop    %edi
f0105d72:	5d                   	pop    %ebp
f0105d73:	c3                   	ret    

f0105d74 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105d74:	55                   	push   %ebp
f0105d75:	89 e5                	mov    %esp,%ebp
f0105d77:	57                   	push   %edi
f0105d78:	56                   	push   %esi
f0105d79:	53                   	push   %ebx
f0105d7a:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105d7d:	c7 05 c0 83 22 f0 20 	movl   $0xf0228020,0xf02283c0
f0105d84:	80 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105d87:	83 3d 90 7e 22 f0 00 	cmpl   $0x0,0xf0227e90
f0105d8e:	75 16                	jne    f0105da6 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105d90:	68 00 04 00 00       	push   $0x400
f0105d95:	68 5c 68 10 f0       	push   $0xf010685c
f0105d9a:	6a 6f                	push   $0x6f
f0105d9c:	68 81 85 10 f0       	push   $0xf0108581
f0105da1:	e8 ee a2 ff ff       	call   f0100094 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105da6:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105dad:	85 c0                	test   %eax,%eax
f0105daf:	74 16                	je     f0105dc7 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105db1:	c1 e0 04             	shl    $0x4,%eax
f0105db4:	ba 00 04 00 00       	mov    $0x400,%edx
f0105db9:	e8 1d ff ff ff       	call   f0105cdb <mpsearch1>
f0105dbe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105dc1:	85 c0                	test   %eax,%eax
f0105dc3:	75 3c                	jne    f0105e01 <mp_init+0x8d>
f0105dc5:	eb 20                	jmp    f0105de7 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105dc7:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105dce:	c1 e0 0a             	shl    $0xa,%eax
f0105dd1:	2d 00 04 00 00       	sub    $0x400,%eax
f0105dd6:	ba 00 04 00 00       	mov    $0x400,%edx
f0105ddb:	e8 fb fe ff ff       	call   f0105cdb <mpsearch1>
f0105de0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105de3:	85 c0                	test   %eax,%eax
f0105de5:	75 1a                	jne    f0105e01 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105de7:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105dec:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105df1:	e8 e5 fe ff ff       	call   f0105cdb <mpsearch1>
f0105df6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105df9:	85 c0                	test   %eax,%eax
f0105dfb:	0f 84 5b 02 00 00    	je     f010605c <mp_init+0x2e8>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105e01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105e04:	8b 70 04             	mov    0x4(%eax),%esi
f0105e07:	85 f6                	test   %esi,%esi
f0105e09:	74 06                	je     f0105e11 <mp_init+0x9d>
f0105e0b:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105e0f:	74 15                	je     f0105e26 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105e11:	83 ec 0c             	sub    $0xc,%esp
f0105e14:	68 f4 83 10 f0       	push   $0xf01083f4
f0105e19:	e8 92 dc ff ff       	call   f0103ab0 <cprintf>
f0105e1e:	83 c4 10             	add    $0x10,%esp
f0105e21:	e9 36 02 00 00       	jmp    f010605c <mp_init+0x2e8>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105e26:	89 f0                	mov    %esi,%eax
f0105e28:	c1 e8 0c             	shr    $0xc,%eax
f0105e2b:	3b 05 90 7e 22 f0    	cmp    0xf0227e90,%eax
f0105e31:	72 15                	jb     f0105e48 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105e33:	56                   	push   %esi
f0105e34:	68 5c 68 10 f0       	push   $0xf010685c
f0105e39:	68 90 00 00 00       	push   $0x90
f0105e3e:	68 81 85 10 f0       	push   $0xf0108581
f0105e43:	e8 4c a2 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0105e48:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105e4e:	83 ec 04             	sub    $0x4,%esp
f0105e51:	6a 04                	push   $0x4
f0105e53:	68 96 85 10 f0       	push   $0xf0108596
f0105e58:	53                   	push   %ebx
f0105e59:	e8 c6 fc ff ff       	call   f0105b24 <memcmp>
f0105e5e:	83 c4 10             	add    $0x10,%esp
f0105e61:	85 c0                	test   %eax,%eax
f0105e63:	74 15                	je     f0105e7a <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105e65:	83 ec 0c             	sub    $0xc,%esp
f0105e68:	68 24 84 10 f0       	push   $0xf0108424
f0105e6d:	e8 3e dc ff ff       	call   f0103ab0 <cprintf>
f0105e72:	83 c4 10             	add    $0x10,%esp
f0105e75:	e9 e2 01 00 00       	jmp    f010605c <mp_init+0x2e8>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105e7a:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105e7e:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105e82:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105e85:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105e8a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e8f:	eb 0d                	jmp    f0105e9e <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105e91:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105e98:	f0 
f0105e99:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105e9b:	83 c0 01             	add    $0x1,%eax
f0105e9e:	39 c7                	cmp    %eax,%edi
f0105ea0:	75 ef                	jne    f0105e91 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105ea2:	84 d2                	test   %dl,%dl
f0105ea4:	74 15                	je     f0105ebb <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105ea6:	83 ec 0c             	sub    $0xc,%esp
f0105ea9:	68 58 84 10 f0       	push   $0xf0108458
f0105eae:	e8 fd db ff ff       	call   f0103ab0 <cprintf>
f0105eb3:	83 c4 10             	add    $0x10,%esp
f0105eb6:	e9 a1 01 00 00       	jmp    f010605c <mp_init+0x2e8>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105ebb:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105ebf:	3c 01                	cmp    $0x1,%al
f0105ec1:	74 1d                	je     f0105ee0 <mp_init+0x16c>
f0105ec3:	3c 04                	cmp    $0x4,%al
f0105ec5:	74 19                	je     f0105ee0 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105ec7:	83 ec 08             	sub    $0x8,%esp
f0105eca:	0f b6 c0             	movzbl %al,%eax
f0105ecd:	50                   	push   %eax
f0105ece:	68 7c 84 10 f0       	push   $0xf010847c
f0105ed3:	e8 d8 db ff ff       	call   f0103ab0 <cprintf>
f0105ed8:	83 c4 10             	add    $0x10,%esp
f0105edb:	e9 7c 01 00 00       	jmp    f010605c <mp_init+0x2e8>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0105ee0:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105ee4:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105ee8:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105eed:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105ef2:	01 ce                	add    %ecx,%esi
f0105ef4:	eb 0d                	jmp    f0105f03 <mp_init+0x18f>
f0105ef6:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105efd:	f0 
f0105efe:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105f00:	83 c0 01             	add    $0x1,%eax
f0105f03:	39 c7                	cmp    %eax,%edi
f0105f05:	75 ef                	jne    f0105ef6 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0105f07:	38 53 2a             	cmp    %dl,0x2a(%ebx)
f0105f0a:	74 15                	je     f0105f21 <mp_init+0x1ad>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105f0c:	83 ec 0c             	sub    $0xc,%esp
f0105f0f:	68 9c 84 10 f0       	push   $0xf010849c
f0105f14:	e8 97 db ff ff       	call   f0103ab0 <cprintf>
f0105f19:	83 c4 10             	add    $0x10,%esp
f0105f1c:	e9 3b 01 00 00       	jmp    f010605c <mp_init+0x2e8>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105f21:	85 db                	test   %ebx,%ebx
f0105f23:	0f 84 33 01 00 00    	je     f010605c <mp_init+0x2e8>
		return;
	ismp = 1;
f0105f29:	c7 05 00 80 22 f0 01 	movl   $0x1,0xf0228000
f0105f30:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105f33:	8b 43 24             	mov    0x24(%ebx),%eax
f0105f36:	a3 00 90 26 f0       	mov    %eax,0xf0269000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105f3b:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105f3e:	be 00 00 00 00       	mov    $0x0,%esi
f0105f43:	e9 85 00 00 00       	jmp    f0105fcd <mp_init+0x259>
		switch (*p) {
f0105f48:	0f b6 07             	movzbl (%edi),%eax
f0105f4b:	84 c0                	test   %al,%al
f0105f4d:	74 06                	je     f0105f55 <mp_init+0x1e1>
f0105f4f:	3c 04                	cmp    $0x4,%al
f0105f51:	77 55                	ja     f0105fa8 <mp_init+0x234>
f0105f53:	eb 4e                	jmp    f0105fa3 <mp_init+0x22f>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105f55:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105f59:	74 11                	je     f0105f6c <mp_init+0x1f8>
				bootcpu = &cpus[ncpu];
f0105f5b:	6b 05 c4 83 22 f0 74 	imul   $0x74,0xf02283c4,%eax
f0105f62:	05 20 80 22 f0       	add    $0xf0228020,%eax
f0105f67:	a3 c0 83 22 f0       	mov    %eax,0xf02283c0
			if (ncpu < NCPU) {
f0105f6c:	a1 c4 83 22 f0       	mov    0xf02283c4,%eax
f0105f71:	83 f8 07             	cmp    $0x7,%eax
f0105f74:	7f 13                	jg     f0105f89 <mp_init+0x215>
				cpus[ncpu].cpu_id = ncpu;
f0105f76:	6b d0 74             	imul   $0x74,%eax,%edx
f0105f79:	88 82 20 80 22 f0    	mov    %al,-0xfdd7fe0(%edx)
				ncpu++;
f0105f7f:	83 c0 01             	add    $0x1,%eax
f0105f82:	a3 c4 83 22 f0       	mov    %eax,0xf02283c4
f0105f87:	eb 15                	jmp    f0105f9e <mp_init+0x22a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105f89:	83 ec 08             	sub    $0x8,%esp
f0105f8c:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105f90:	50                   	push   %eax
f0105f91:	68 cc 84 10 f0       	push   $0xf01084cc
f0105f96:	e8 15 db ff ff       	call   f0103ab0 <cprintf>
f0105f9b:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105f9e:	83 c7 14             	add    $0x14,%edi
			continue;
f0105fa1:	eb 27                	jmp    f0105fca <mp_init+0x256>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105fa3:	83 c7 08             	add    $0x8,%edi
			continue;
f0105fa6:	eb 22                	jmp    f0105fca <mp_init+0x256>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105fa8:	83 ec 08             	sub    $0x8,%esp
f0105fab:	0f b6 c0             	movzbl %al,%eax
f0105fae:	50                   	push   %eax
f0105faf:	68 f4 84 10 f0       	push   $0xf01084f4
f0105fb4:	e8 f7 da ff ff       	call   f0103ab0 <cprintf>
			ismp = 0;
f0105fb9:	c7 05 00 80 22 f0 00 	movl   $0x0,0xf0228000
f0105fc0:	00 00 00 
			i = conf->entry;
f0105fc3:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105fc7:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105fca:	83 c6 01             	add    $0x1,%esi
f0105fcd:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105fd1:	39 c6                	cmp    %eax,%esi
f0105fd3:	0f 82 6f ff ff ff    	jb     f0105f48 <mp_init+0x1d4>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105fd9:	a1 c0 83 22 f0       	mov    0xf02283c0,%eax
f0105fde:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105fe5:	83 3d 00 80 22 f0 00 	cmpl   $0x0,0xf0228000
f0105fec:	75 26                	jne    f0106014 <mp_init+0x2a0>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105fee:	c7 05 c4 83 22 f0 01 	movl   $0x1,0xf02283c4
f0105ff5:	00 00 00 
		lapicaddr = 0;
f0105ff8:	c7 05 00 90 26 f0 00 	movl   $0x0,0xf0269000
f0105fff:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106002:	83 ec 0c             	sub    $0xc,%esp
f0106005:	68 14 85 10 f0       	push   $0xf0108514
f010600a:	e8 a1 da ff ff       	call   f0103ab0 <cprintf>
		return;
f010600f:	83 c4 10             	add    $0x10,%esp
f0106012:	eb 48                	jmp    f010605c <mp_init+0x2e8>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106014:	83 ec 04             	sub    $0x4,%esp
f0106017:	ff 35 c4 83 22 f0    	pushl  0xf02283c4
f010601d:	0f b6 00             	movzbl (%eax),%eax
f0106020:	50                   	push   %eax
f0106021:	68 9b 85 10 f0       	push   $0xf010859b
f0106026:	e8 85 da ff ff       	call   f0103ab0 <cprintf>

	if (mp->imcrp) {
f010602b:	83 c4 10             	add    $0x10,%esp
f010602e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106031:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106035:	74 25                	je     f010605c <mp_init+0x2e8>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106037:	83 ec 0c             	sub    $0xc,%esp
f010603a:	68 40 85 10 f0       	push   $0xf0108540
f010603f:	e8 6c da ff ff       	call   f0103ab0 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106044:	ba 22 00 00 00       	mov    $0x22,%edx
f0106049:	b8 70 00 00 00       	mov    $0x70,%eax
f010604e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010604f:	ba 23 00 00 00       	mov    $0x23,%edx
f0106054:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106055:	83 c8 01             	or     $0x1,%eax
f0106058:	ee                   	out    %al,(%dx)
f0106059:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f010605c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010605f:	5b                   	pop    %ebx
f0106060:	5e                   	pop    %esi
f0106061:	5f                   	pop    %edi
f0106062:	5d                   	pop    %ebp
f0106063:	c3                   	ret    

f0106064 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106064:	55                   	push   %ebp
f0106065:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106067:	8b 0d 04 90 26 f0    	mov    0xf0269004,%ecx
f010606d:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0106070:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106072:	a1 04 90 26 f0       	mov    0xf0269004,%eax
f0106077:	8b 40 20             	mov    0x20(%eax),%eax
}
f010607a:	5d                   	pop    %ebp
f010607b:	c3                   	ret    

f010607c <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f010607c:	55                   	push   %ebp
f010607d:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010607f:	a1 04 90 26 f0       	mov    0xf0269004,%eax
f0106084:	85 c0                	test   %eax,%eax
f0106086:	74 08                	je     f0106090 <cpunum+0x14>
		return lapic[ID] >> 24;
f0106088:	8b 40 20             	mov    0x20(%eax),%eax
f010608b:	c1 e8 18             	shr    $0x18,%eax
f010608e:	eb 05                	jmp    f0106095 <cpunum+0x19>
	return 0;
f0106090:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106095:	5d                   	pop    %ebp
f0106096:	c3                   	ret    

f0106097 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0106097:	a1 00 90 26 f0       	mov    0xf0269000,%eax
f010609c:	85 c0                	test   %eax,%eax
f010609e:	0f 84 21 01 00 00    	je     f01061c5 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01060a4:	55                   	push   %ebp
f01060a5:	89 e5                	mov    %esp,%ebp
f01060a7:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f01060aa:	68 00 10 00 00       	push   $0x1000
f01060af:	50                   	push   %eax
f01060b0:	e8 8f b5 ff ff       	call   f0101644 <mmio_map_region>
f01060b5:	a3 04 90 26 f0       	mov    %eax,0xf0269004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01060ba:	ba 27 01 00 00       	mov    $0x127,%edx
f01060bf:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01060c4:	e8 9b ff ff ff       	call   f0106064 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01060c9:	ba 0b 00 00 00       	mov    $0xb,%edx
f01060ce:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01060d3:	e8 8c ff ff ff       	call   f0106064 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01060d8:	ba 20 00 02 00       	mov    $0x20020,%edx
f01060dd:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01060e2:	e8 7d ff ff ff       	call   f0106064 <lapicw>
	lapicw(TICR, 10000000); 
f01060e7:	ba 80 96 98 00       	mov    $0x989680,%edx
f01060ec:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01060f1:	e8 6e ff ff ff       	call   f0106064 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)//mask every cpu other than bootcpu
f01060f6:	e8 81 ff ff ff       	call   f010607c <cpunum>
f01060fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01060fe:	05 20 80 22 f0       	add    $0xf0228020,%eax
f0106103:	83 c4 10             	add    $0x10,%esp
f0106106:	39 05 c0 83 22 f0    	cmp    %eax,0xf02283c0
f010610c:	74 0f                	je     f010611d <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f010610e:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106113:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106118:	e8 47 ff ff ff       	call   f0106064 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);//why?
f010611d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106122:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106127:	e8 38 ff ff ff       	call   f0106064 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010612c:	a1 04 90 26 f0       	mov    0xf0269004,%eax
f0106131:	8b 40 30             	mov    0x30(%eax),%eax
f0106134:	c1 e8 10             	shr    $0x10,%eax
f0106137:	3c 03                	cmp    $0x3,%al
f0106139:	76 0f                	jbe    f010614a <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f010613b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106140:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106145:	e8 1a ff ff ff       	call   f0106064 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f010614a:	ba 33 00 00 00       	mov    $0x33,%edx
f010614f:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106154:	e8 0b ff ff ff       	call   f0106064 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0106159:	ba 00 00 00 00       	mov    $0x0,%edx
f010615e:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106163:	e8 fc fe ff ff       	call   f0106064 <lapicw>
	lapicw(ESR, 0);
f0106168:	ba 00 00 00 00       	mov    $0x0,%edx
f010616d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106172:	e8 ed fe ff ff       	call   f0106064 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106177:	ba 00 00 00 00       	mov    $0x0,%edx
f010617c:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106181:	e8 de fe ff ff       	call   f0106064 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0106186:	ba 00 00 00 00       	mov    $0x0,%edx
f010618b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106190:	e8 cf fe ff ff       	call   f0106064 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106195:	ba 00 85 08 00       	mov    $0x88500,%edx
f010619a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010619f:	e8 c0 fe ff ff       	call   f0106064 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01061a4:	8b 15 04 90 26 f0    	mov    0xf0269004,%edx
f01061aa:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01061b0:	f6 c4 10             	test   $0x10,%ah
f01061b3:	75 f5                	jne    f01061aa <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01061b5:	ba 00 00 00 00       	mov    $0x0,%edx
f01061ba:	b8 20 00 00 00       	mov    $0x20,%eax
f01061bf:	e8 a0 fe ff ff       	call   f0106064 <lapicw>
}
f01061c4:	c9                   	leave  
f01061c5:	f3 c3                	repz ret 

f01061c7 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f01061c7:	83 3d 04 90 26 f0 00 	cmpl   $0x0,0xf0269004
f01061ce:	74 13                	je     f01061e3 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01061d0:	55                   	push   %ebp
f01061d1:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f01061d3:	ba 00 00 00 00       	mov    $0x0,%edx
f01061d8:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01061dd:	e8 82 fe ff ff       	call   f0106064 <lapicw>
}
f01061e2:	5d                   	pop    %ebp
f01061e3:	f3 c3                	repz ret 

f01061e5 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01061e5:	55                   	push   %ebp
f01061e6:	89 e5                	mov    %esp,%ebp
f01061e8:	56                   	push   %esi
f01061e9:	53                   	push   %ebx
f01061ea:	8b 75 08             	mov    0x8(%ebp),%esi
f01061ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01061f0:	ba 70 00 00 00       	mov    $0x70,%edx
f01061f5:	b8 0f 00 00 00       	mov    $0xf,%eax
f01061fa:	ee                   	out    %al,(%dx)
f01061fb:	ba 71 00 00 00       	mov    $0x71,%edx
f0106200:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106205:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106206:	83 3d 90 7e 22 f0 00 	cmpl   $0x0,0xf0227e90
f010620d:	75 19                	jne    f0106228 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010620f:	68 67 04 00 00       	push   $0x467
f0106214:	68 5c 68 10 f0       	push   $0xf010685c
f0106219:	68 98 00 00 00       	push   $0x98
f010621e:	68 b8 85 10 f0       	push   $0xf01085b8
f0106223:	e8 6c 9e ff ff       	call   f0100094 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106228:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f010622f:	00 00 
	wrv[1] = addr >> 4;
f0106231:	89 d8                	mov    %ebx,%eax
f0106233:	c1 e8 04             	shr    $0x4,%eax
f0106236:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f010623c:	c1 e6 18             	shl    $0x18,%esi
f010623f:	89 f2                	mov    %esi,%edx
f0106241:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106246:	e8 19 fe ff ff       	call   f0106064 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f010624b:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106250:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106255:	e8 0a fe ff ff       	call   f0106064 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f010625a:	ba 00 85 00 00       	mov    $0x8500,%edx
f010625f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106264:	e8 fb fd ff ff       	call   f0106064 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106269:	c1 eb 0c             	shr    $0xc,%ebx
f010626c:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010626f:	89 f2                	mov    %esi,%edx
f0106271:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106276:	e8 e9 fd ff ff       	call   f0106064 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010627b:	89 da                	mov    %ebx,%edx
f010627d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106282:	e8 dd fd ff ff       	call   f0106064 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106287:	89 f2                	mov    %esi,%edx
f0106289:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010628e:	e8 d1 fd ff ff       	call   f0106064 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106293:	89 da                	mov    %ebx,%edx
f0106295:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010629a:	e8 c5 fd ff ff       	call   f0106064 <lapicw>
		microdelay(200);
	}
}
f010629f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01062a2:	5b                   	pop    %ebx
f01062a3:	5e                   	pop    %esi
f01062a4:	5d                   	pop    %ebp
f01062a5:	c3                   	ret    

f01062a6 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01062a6:	55                   	push   %ebp
f01062a7:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01062a9:	8b 55 08             	mov    0x8(%ebp),%edx
f01062ac:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01062b2:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01062b7:	e8 a8 fd ff ff       	call   f0106064 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01062bc:	8b 15 04 90 26 f0    	mov    0xf0269004,%edx
f01062c2:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01062c8:	f6 c4 10             	test   $0x10,%ah
f01062cb:	75 f5                	jne    f01062c2 <lapic_ipi+0x1c>
		;
}
f01062cd:	5d                   	pop    %ebp
f01062ce:	c3                   	ret    

f01062cf <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01062cf:	55                   	push   %ebp
f01062d0:	89 e5                	mov    %esp,%ebp
f01062d2:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01062d5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01062db:	8b 55 0c             	mov    0xc(%ebp),%edx
f01062de:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01062e1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01062e8:	5d                   	pop    %ebp
f01062e9:	c3                   	ret    

f01062ea <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01062ea:	55                   	push   %ebp
f01062eb:	89 e5                	mov    %esp,%ebp
f01062ed:	56                   	push   %esi
f01062ee:	53                   	push   %ebx
f01062ef:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01062f2:	83 3b 00             	cmpl   $0x0,(%ebx)
f01062f5:	74 14                	je     f010630b <spin_lock+0x21>
f01062f7:	8b 73 08             	mov    0x8(%ebx),%esi
f01062fa:	e8 7d fd ff ff       	call   f010607c <cpunum>
f01062ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0106302:	05 20 80 22 f0       	add    $0xf0228020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106307:	39 c6                	cmp    %eax,%esi
f0106309:	74 07                	je     f0106312 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010630b:	ba 01 00 00 00       	mov    $0x1,%edx
f0106310:	eb 20                	jmp    f0106332 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106312:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106315:	e8 62 fd ff ff       	call   f010607c <cpunum>
f010631a:	83 ec 0c             	sub    $0xc,%esp
f010631d:	53                   	push   %ebx
f010631e:	50                   	push   %eax
f010631f:	68 c8 85 10 f0       	push   $0xf01085c8
f0106324:	6a 41                	push   $0x41
f0106326:	68 2c 86 10 f0       	push   $0xf010862c
f010632b:	e8 64 9d ff ff       	call   f0100094 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106330:	f3 90                	pause  
f0106332:	89 d0                	mov    %edx,%eax
f0106334:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106337:	85 c0                	test   %eax,%eax
f0106339:	75 f5                	jne    f0106330 <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010633b:	e8 3c fd ff ff       	call   f010607c <cpunum>
f0106340:	6b c0 74             	imul   $0x74,%eax,%eax
f0106343:	05 20 80 22 f0       	add    $0xf0228020,%eax
f0106348:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f010634b:	83 c3 0c             	add    $0xc,%ebx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f010634e:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106350:	b8 00 00 00 00       	mov    $0x0,%eax
f0106355:	eb 0b                	jmp    f0106362 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106357:	8b 4a 04             	mov    0x4(%edx),%ecx
f010635a:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010635d:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010635f:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106362:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106368:	76 11                	jbe    f010637b <spin_lock+0x91>
f010636a:	83 f8 09             	cmp    $0x9,%eax
f010636d:	7e e8                	jle    f0106357 <spin_lock+0x6d>
f010636f:	eb 0a                	jmp    f010637b <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106371:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106378:	83 c0 01             	add    $0x1,%eax
f010637b:	83 f8 09             	cmp    $0x9,%eax
f010637e:	7e f1                	jle    f0106371 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106380:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106383:	5b                   	pop    %ebx
f0106384:	5e                   	pop    %esi
f0106385:	5d                   	pop    %ebp
f0106386:	c3                   	ret    

f0106387 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106387:	55                   	push   %ebp
f0106388:	89 e5                	mov    %esp,%ebp
f010638a:	57                   	push   %edi
f010638b:	56                   	push   %esi
f010638c:	53                   	push   %ebx
f010638d:	83 ec 4c             	sub    $0x4c,%esp
f0106390:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106393:	83 3e 00             	cmpl   $0x0,(%esi)
f0106396:	74 18                	je     f01063b0 <spin_unlock+0x29>
f0106398:	8b 5e 08             	mov    0x8(%esi),%ebx
f010639b:	e8 dc fc ff ff       	call   f010607c <cpunum>
f01063a0:	6b c0 74             	imul   $0x74,%eax,%eax
f01063a3:	05 20 80 22 f0       	add    $0xf0228020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01063a8:	39 c3                	cmp    %eax,%ebx
f01063aa:	0f 84 a5 00 00 00    	je     f0106455 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01063b0:	83 ec 04             	sub    $0x4,%esp
f01063b3:	6a 28                	push   $0x28
f01063b5:	8d 46 0c             	lea    0xc(%esi),%eax
f01063b8:	50                   	push   %eax
f01063b9:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01063bc:	53                   	push   %ebx
f01063bd:	e8 e7 f6 ff ff       	call   f0105aa9 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01063c2:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01063c5:	0f b6 38             	movzbl (%eax),%edi
f01063c8:	8b 76 04             	mov    0x4(%esi),%esi
f01063cb:	e8 ac fc ff ff       	call   f010607c <cpunum>
f01063d0:	57                   	push   %edi
f01063d1:	56                   	push   %esi
f01063d2:	50                   	push   %eax
f01063d3:	68 f4 85 10 f0       	push   $0xf01085f4
f01063d8:	e8 d3 d6 ff ff       	call   f0103ab0 <cprintf>
f01063dd:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01063e0:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01063e3:	eb 54                	jmp    f0106439 <spin_unlock+0xb2>
f01063e5:	83 ec 08             	sub    $0x8,%esp
f01063e8:	57                   	push   %edi
f01063e9:	50                   	push   %eax
f01063ea:	e8 d2 eb ff ff       	call   f0104fc1 <debuginfo_eip>
f01063ef:	83 c4 10             	add    $0x10,%esp
f01063f2:	85 c0                	test   %eax,%eax
f01063f4:	78 27                	js     f010641d <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01063f6:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01063f8:	83 ec 04             	sub    $0x4,%esp
f01063fb:	89 c2                	mov    %eax,%edx
f01063fd:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106400:	52                   	push   %edx
f0106401:	ff 75 b0             	pushl  -0x50(%ebp)
f0106404:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106407:	ff 75 ac             	pushl  -0x54(%ebp)
f010640a:	ff 75 a8             	pushl  -0x58(%ebp)
f010640d:	50                   	push   %eax
f010640e:	68 3c 86 10 f0       	push   $0xf010863c
f0106413:	e8 98 d6 ff ff       	call   f0103ab0 <cprintf>
f0106418:	83 c4 20             	add    $0x20,%esp
f010641b:	eb 12                	jmp    f010642f <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f010641d:	83 ec 08             	sub    $0x8,%esp
f0106420:	ff 36                	pushl  (%esi)
f0106422:	68 53 86 10 f0       	push   $0xf0108653
f0106427:	e8 84 d6 ff ff       	call   f0103ab0 <cprintf>
f010642c:	83 c4 10             	add    $0x10,%esp
f010642f:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106432:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106435:	39 c3                	cmp    %eax,%ebx
f0106437:	74 08                	je     f0106441 <spin_unlock+0xba>
f0106439:	89 de                	mov    %ebx,%esi
f010643b:	8b 03                	mov    (%ebx),%eax
f010643d:	85 c0                	test   %eax,%eax
f010643f:	75 a4                	jne    f01063e5 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106441:	83 ec 04             	sub    $0x4,%esp
f0106444:	68 5b 86 10 f0       	push   $0xf010865b
f0106449:	6a 67                	push   $0x67
f010644b:	68 2c 86 10 f0       	push   $0xf010862c
f0106450:	e8 3f 9c ff ff       	call   f0100094 <_panic>
	}

	lk->pcs[0] = 0;
f0106455:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f010645c:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106463:	b8 00 00 00 00       	mov    $0x0,%eax
f0106468:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f010646b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010646e:	5b                   	pop    %ebx
f010646f:	5e                   	pop    %esi
f0106470:	5f                   	pop    %edi
f0106471:	5d                   	pop    %ebp
f0106472:	c3                   	ret    
f0106473:	66 90                	xchg   %ax,%ax
f0106475:	66 90                	xchg   %ax,%ax
f0106477:	66 90                	xchg   %ax,%ax
f0106479:	66 90                	xchg   %ax,%ax
f010647b:	66 90                	xchg   %ax,%ax
f010647d:	66 90                	xchg   %ax,%ax
f010647f:	90                   	nop

f0106480 <__udivdi3>:
f0106480:	55                   	push   %ebp
f0106481:	57                   	push   %edi
f0106482:	56                   	push   %esi
f0106483:	53                   	push   %ebx
f0106484:	83 ec 1c             	sub    $0x1c,%esp
f0106487:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010648b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010648f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0106493:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106497:	85 f6                	test   %esi,%esi
f0106499:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010649d:	89 ca                	mov    %ecx,%edx
f010649f:	89 f8                	mov    %edi,%eax
f01064a1:	75 3d                	jne    f01064e0 <__udivdi3+0x60>
f01064a3:	39 cf                	cmp    %ecx,%edi
f01064a5:	0f 87 c5 00 00 00    	ja     f0106570 <__udivdi3+0xf0>
f01064ab:	85 ff                	test   %edi,%edi
f01064ad:	89 fd                	mov    %edi,%ebp
f01064af:	75 0b                	jne    f01064bc <__udivdi3+0x3c>
f01064b1:	b8 01 00 00 00       	mov    $0x1,%eax
f01064b6:	31 d2                	xor    %edx,%edx
f01064b8:	f7 f7                	div    %edi
f01064ba:	89 c5                	mov    %eax,%ebp
f01064bc:	89 c8                	mov    %ecx,%eax
f01064be:	31 d2                	xor    %edx,%edx
f01064c0:	f7 f5                	div    %ebp
f01064c2:	89 c1                	mov    %eax,%ecx
f01064c4:	89 d8                	mov    %ebx,%eax
f01064c6:	89 cf                	mov    %ecx,%edi
f01064c8:	f7 f5                	div    %ebp
f01064ca:	89 c3                	mov    %eax,%ebx
f01064cc:	89 d8                	mov    %ebx,%eax
f01064ce:	89 fa                	mov    %edi,%edx
f01064d0:	83 c4 1c             	add    $0x1c,%esp
f01064d3:	5b                   	pop    %ebx
f01064d4:	5e                   	pop    %esi
f01064d5:	5f                   	pop    %edi
f01064d6:	5d                   	pop    %ebp
f01064d7:	c3                   	ret    
f01064d8:	90                   	nop
f01064d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01064e0:	39 ce                	cmp    %ecx,%esi
f01064e2:	77 74                	ja     f0106558 <__udivdi3+0xd8>
f01064e4:	0f bd fe             	bsr    %esi,%edi
f01064e7:	83 f7 1f             	xor    $0x1f,%edi
f01064ea:	0f 84 98 00 00 00    	je     f0106588 <__udivdi3+0x108>
f01064f0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01064f5:	89 f9                	mov    %edi,%ecx
f01064f7:	89 c5                	mov    %eax,%ebp
f01064f9:	29 fb                	sub    %edi,%ebx
f01064fb:	d3 e6                	shl    %cl,%esi
f01064fd:	89 d9                	mov    %ebx,%ecx
f01064ff:	d3 ed                	shr    %cl,%ebp
f0106501:	89 f9                	mov    %edi,%ecx
f0106503:	d3 e0                	shl    %cl,%eax
f0106505:	09 ee                	or     %ebp,%esi
f0106507:	89 d9                	mov    %ebx,%ecx
f0106509:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010650d:	89 d5                	mov    %edx,%ebp
f010650f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106513:	d3 ed                	shr    %cl,%ebp
f0106515:	89 f9                	mov    %edi,%ecx
f0106517:	d3 e2                	shl    %cl,%edx
f0106519:	89 d9                	mov    %ebx,%ecx
f010651b:	d3 e8                	shr    %cl,%eax
f010651d:	09 c2                	or     %eax,%edx
f010651f:	89 d0                	mov    %edx,%eax
f0106521:	89 ea                	mov    %ebp,%edx
f0106523:	f7 f6                	div    %esi
f0106525:	89 d5                	mov    %edx,%ebp
f0106527:	89 c3                	mov    %eax,%ebx
f0106529:	f7 64 24 0c          	mull   0xc(%esp)
f010652d:	39 d5                	cmp    %edx,%ebp
f010652f:	72 10                	jb     f0106541 <__udivdi3+0xc1>
f0106531:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106535:	89 f9                	mov    %edi,%ecx
f0106537:	d3 e6                	shl    %cl,%esi
f0106539:	39 c6                	cmp    %eax,%esi
f010653b:	73 07                	jae    f0106544 <__udivdi3+0xc4>
f010653d:	39 d5                	cmp    %edx,%ebp
f010653f:	75 03                	jne    f0106544 <__udivdi3+0xc4>
f0106541:	83 eb 01             	sub    $0x1,%ebx
f0106544:	31 ff                	xor    %edi,%edi
f0106546:	89 d8                	mov    %ebx,%eax
f0106548:	89 fa                	mov    %edi,%edx
f010654a:	83 c4 1c             	add    $0x1c,%esp
f010654d:	5b                   	pop    %ebx
f010654e:	5e                   	pop    %esi
f010654f:	5f                   	pop    %edi
f0106550:	5d                   	pop    %ebp
f0106551:	c3                   	ret    
f0106552:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106558:	31 ff                	xor    %edi,%edi
f010655a:	31 db                	xor    %ebx,%ebx
f010655c:	89 d8                	mov    %ebx,%eax
f010655e:	89 fa                	mov    %edi,%edx
f0106560:	83 c4 1c             	add    $0x1c,%esp
f0106563:	5b                   	pop    %ebx
f0106564:	5e                   	pop    %esi
f0106565:	5f                   	pop    %edi
f0106566:	5d                   	pop    %ebp
f0106567:	c3                   	ret    
f0106568:	90                   	nop
f0106569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106570:	89 d8                	mov    %ebx,%eax
f0106572:	f7 f7                	div    %edi
f0106574:	31 ff                	xor    %edi,%edi
f0106576:	89 c3                	mov    %eax,%ebx
f0106578:	89 d8                	mov    %ebx,%eax
f010657a:	89 fa                	mov    %edi,%edx
f010657c:	83 c4 1c             	add    $0x1c,%esp
f010657f:	5b                   	pop    %ebx
f0106580:	5e                   	pop    %esi
f0106581:	5f                   	pop    %edi
f0106582:	5d                   	pop    %ebp
f0106583:	c3                   	ret    
f0106584:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106588:	39 ce                	cmp    %ecx,%esi
f010658a:	72 0c                	jb     f0106598 <__udivdi3+0x118>
f010658c:	31 db                	xor    %ebx,%ebx
f010658e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106592:	0f 87 34 ff ff ff    	ja     f01064cc <__udivdi3+0x4c>
f0106598:	bb 01 00 00 00       	mov    $0x1,%ebx
f010659d:	e9 2a ff ff ff       	jmp    f01064cc <__udivdi3+0x4c>
f01065a2:	66 90                	xchg   %ax,%ax
f01065a4:	66 90                	xchg   %ax,%ax
f01065a6:	66 90                	xchg   %ax,%ax
f01065a8:	66 90                	xchg   %ax,%ax
f01065aa:	66 90                	xchg   %ax,%ax
f01065ac:	66 90                	xchg   %ax,%ax
f01065ae:	66 90                	xchg   %ax,%ax

f01065b0 <__umoddi3>:
f01065b0:	55                   	push   %ebp
f01065b1:	57                   	push   %edi
f01065b2:	56                   	push   %esi
f01065b3:	53                   	push   %ebx
f01065b4:	83 ec 1c             	sub    $0x1c,%esp
f01065b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01065bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01065bf:	8b 74 24 34          	mov    0x34(%esp),%esi
f01065c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01065c7:	85 d2                	test   %edx,%edx
f01065c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01065cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01065d1:	89 f3                	mov    %esi,%ebx
f01065d3:	89 3c 24             	mov    %edi,(%esp)
f01065d6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01065da:	75 1c                	jne    f01065f8 <__umoddi3+0x48>
f01065dc:	39 f7                	cmp    %esi,%edi
f01065de:	76 50                	jbe    f0106630 <__umoddi3+0x80>
f01065e0:	89 c8                	mov    %ecx,%eax
f01065e2:	89 f2                	mov    %esi,%edx
f01065e4:	f7 f7                	div    %edi
f01065e6:	89 d0                	mov    %edx,%eax
f01065e8:	31 d2                	xor    %edx,%edx
f01065ea:	83 c4 1c             	add    $0x1c,%esp
f01065ed:	5b                   	pop    %ebx
f01065ee:	5e                   	pop    %esi
f01065ef:	5f                   	pop    %edi
f01065f0:	5d                   	pop    %ebp
f01065f1:	c3                   	ret    
f01065f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01065f8:	39 f2                	cmp    %esi,%edx
f01065fa:	89 d0                	mov    %edx,%eax
f01065fc:	77 52                	ja     f0106650 <__umoddi3+0xa0>
f01065fe:	0f bd ea             	bsr    %edx,%ebp
f0106601:	83 f5 1f             	xor    $0x1f,%ebp
f0106604:	75 5a                	jne    f0106660 <__umoddi3+0xb0>
f0106606:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010660a:	0f 82 e0 00 00 00    	jb     f01066f0 <__umoddi3+0x140>
f0106610:	39 0c 24             	cmp    %ecx,(%esp)
f0106613:	0f 86 d7 00 00 00    	jbe    f01066f0 <__umoddi3+0x140>
f0106619:	8b 44 24 08          	mov    0x8(%esp),%eax
f010661d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106621:	83 c4 1c             	add    $0x1c,%esp
f0106624:	5b                   	pop    %ebx
f0106625:	5e                   	pop    %esi
f0106626:	5f                   	pop    %edi
f0106627:	5d                   	pop    %ebp
f0106628:	c3                   	ret    
f0106629:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106630:	85 ff                	test   %edi,%edi
f0106632:	89 fd                	mov    %edi,%ebp
f0106634:	75 0b                	jne    f0106641 <__umoddi3+0x91>
f0106636:	b8 01 00 00 00       	mov    $0x1,%eax
f010663b:	31 d2                	xor    %edx,%edx
f010663d:	f7 f7                	div    %edi
f010663f:	89 c5                	mov    %eax,%ebp
f0106641:	89 f0                	mov    %esi,%eax
f0106643:	31 d2                	xor    %edx,%edx
f0106645:	f7 f5                	div    %ebp
f0106647:	89 c8                	mov    %ecx,%eax
f0106649:	f7 f5                	div    %ebp
f010664b:	89 d0                	mov    %edx,%eax
f010664d:	eb 99                	jmp    f01065e8 <__umoddi3+0x38>
f010664f:	90                   	nop
f0106650:	89 c8                	mov    %ecx,%eax
f0106652:	89 f2                	mov    %esi,%edx
f0106654:	83 c4 1c             	add    $0x1c,%esp
f0106657:	5b                   	pop    %ebx
f0106658:	5e                   	pop    %esi
f0106659:	5f                   	pop    %edi
f010665a:	5d                   	pop    %ebp
f010665b:	c3                   	ret    
f010665c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106660:	8b 34 24             	mov    (%esp),%esi
f0106663:	bf 20 00 00 00       	mov    $0x20,%edi
f0106668:	89 e9                	mov    %ebp,%ecx
f010666a:	29 ef                	sub    %ebp,%edi
f010666c:	d3 e0                	shl    %cl,%eax
f010666e:	89 f9                	mov    %edi,%ecx
f0106670:	89 f2                	mov    %esi,%edx
f0106672:	d3 ea                	shr    %cl,%edx
f0106674:	89 e9                	mov    %ebp,%ecx
f0106676:	09 c2                	or     %eax,%edx
f0106678:	89 d8                	mov    %ebx,%eax
f010667a:	89 14 24             	mov    %edx,(%esp)
f010667d:	89 f2                	mov    %esi,%edx
f010667f:	d3 e2                	shl    %cl,%edx
f0106681:	89 f9                	mov    %edi,%ecx
f0106683:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106687:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010668b:	d3 e8                	shr    %cl,%eax
f010668d:	89 e9                	mov    %ebp,%ecx
f010668f:	89 c6                	mov    %eax,%esi
f0106691:	d3 e3                	shl    %cl,%ebx
f0106693:	89 f9                	mov    %edi,%ecx
f0106695:	89 d0                	mov    %edx,%eax
f0106697:	d3 e8                	shr    %cl,%eax
f0106699:	89 e9                	mov    %ebp,%ecx
f010669b:	09 d8                	or     %ebx,%eax
f010669d:	89 d3                	mov    %edx,%ebx
f010669f:	89 f2                	mov    %esi,%edx
f01066a1:	f7 34 24             	divl   (%esp)
f01066a4:	89 d6                	mov    %edx,%esi
f01066a6:	d3 e3                	shl    %cl,%ebx
f01066a8:	f7 64 24 04          	mull   0x4(%esp)
f01066ac:	39 d6                	cmp    %edx,%esi
f01066ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01066b2:	89 d1                	mov    %edx,%ecx
f01066b4:	89 c3                	mov    %eax,%ebx
f01066b6:	72 08                	jb     f01066c0 <__umoddi3+0x110>
f01066b8:	75 11                	jne    f01066cb <__umoddi3+0x11b>
f01066ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01066be:	73 0b                	jae    f01066cb <__umoddi3+0x11b>
f01066c0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01066c4:	1b 14 24             	sbb    (%esp),%edx
f01066c7:	89 d1                	mov    %edx,%ecx
f01066c9:	89 c3                	mov    %eax,%ebx
f01066cb:	8b 54 24 08          	mov    0x8(%esp),%edx
f01066cf:	29 da                	sub    %ebx,%edx
f01066d1:	19 ce                	sbb    %ecx,%esi
f01066d3:	89 f9                	mov    %edi,%ecx
f01066d5:	89 f0                	mov    %esi,%eax
f01066d7:	d3 e0                	shl    %cl,%eax
f01066d9:	89 e9                	mov    %ebp,%ecx
f01066db:	d3 ea                	shr    %cl,%edx
f01066dd:	89 e9                	mov    %ebp,%ecx
f01066df:	d3 ee                	shr    %cl,%esi
f01066e1:	09 d0                	or     %edx,%eax
f01066e3:	89 f2                	mov    %esi,%edx
f01066e5:	83 c4 1c             	add    $0x1c,%esp
f01066e8:	5b                   	pop    %ebx
f01066e9:	5e                   	pop    %esi
f01066ea:	5f                   	pop    %edi
f01066eb:	5d                   	pop    %ebp
f01066ec:	c3                   	ret    
f01066ed:	8d 76 00             	lea    0x0(%esi),%esi
f01066f0:	29 f9                	sub    %edi,%ecx
f01066f2:	19 d6                	sbb    %edx,%esi
f01066f4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01066f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01066fc:	e9 18 ff ff ff       	jmp    f0106619 <__umoddi3+0x69>
