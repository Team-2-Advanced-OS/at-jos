
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
f0100015:	b8 00 10 12 00       	mov    $0x121000,%eax
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
f0100034:	bc 00 10 12 f0       	mov    $0xf0121000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5c 00 00 00       	call   f010009a <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 90 1e 2a f0 00 	cmpl   $0x0,0xf02a1e90
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 90 1e 2a f0    	mov    %esi,0xf02a1e90

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 a1 57 00 00       	call   f0105802 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 80 69 10 f0       	push   $0xf0106980
f010006d:	e8 ee 35 00 00       	call   f0103660 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 be 35 00 00       	call   f010363a <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 97 7b 10 f0 	movl   $0xf0107b97,(%esp)
f0100083:	e8 d8 35 00 00       	call   f0103660 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 61 08 00 00       	call   f01008f6 <monitor>
f0100095:	83 c4 10             	add    $0x10,%esp
f0100098:	eb f1                	jmp    f010008b <_panic+0x4b>

f010009a <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010009a:	55                   	push   %ebp
f010009b:	89 e5                	mov    %esp,%ebp
f010009d:	53                   	push   %ebx
f010009e:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a1:	b8 80 32 2e f0       	mov    $0xf02e3280,%eax
f01000a6:	2d d0 0a 2a f0       	sub    $0xf02a0ad0,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 d0 0a 2a f0       	push   $0xf02a0ad0
f01000b3:	e8 2a 51 00 00       	call   f01051e2 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 a1 05 00 00       	call   f010065e <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 ec 69 10 f0       	push   $0xf01069ec
f01000ca:	e8 91 35 00 00       	call   f0103660 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 5b 12 00 00       	call   f010132f <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 b7 2e 00 00       	call   f0102f90 <env_init>
	trap_init();
f01000d9:	e8 66 36 00 00       	call   f0103744 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 15 54 00 00       	call   f01054f8 <mp_init>
	lapic_init();
f01000e3:	e8 35 57 00 00       	call   f010581d <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 84 34 00 00       	call   f0103571 <pic_init>

	// Lab 6 hardware initialization functions
	time_init();
f01000ed:	e8 ac 65 00 00       	call   f010669e <time_init>
	pci_init();
f01000f2:	e8 87 65 00 00       	call   f010667e <pci_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000f7:	c7 04 24 60 34 12 f0 	movl   $0xf0123460,(%esp)
f01000fe:	e8 6d 59 00 00       	call   f0105a70 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100103:	83 c4 10             	add    $0x10,%esp
f0100106:	83 3d 98 1e 2a f0 07 	cmpl   $0x7,0xf02a1e98
f010010d:	77 16                	ja     f0100125 <i386_init+0x8b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010010f:	68 00 70 00 00       	push   $0x7000
f0100114:	68 a4 69 10 f0       	push   $0xf01069a4
f0100119:	6a 65                	push   $0x65
f010011b:	68 07 6a 10 f0       	push   $0xf0106a07
f0100120:	e8 1b ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100125:	83 ec 04             	sub    $0x4,%esp
f0100128:	b8 5e 54 10 f0       	mov    $0xf010545e,%eax
f010012d:	2d e4 53 10 f0       	sub    $0xf01053e4,%eax
f0100132:	50                   	push   %eax
f0100133:	68 e4 53 10 f0       	push   $0xf01053e4
f0100138:	68 00 70 00 f0       	push   $0xf0007000
f010013d:	e8 ed 50 00 00       	call   f010522f <memmove>
f0100142:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100145:	bb 20 20 2a f0       	mov    $0xf02a2020,%ebx
f010014a:	eb 4d                	jmp    f0100199 <i386_init+0xff>
		if (c == cpus + cpunum())  // We've started already.
f010014c:	e8 b1 56 00 00       	call   f0105802 <cpunum>
f0100151:	6b c0 74             	imul   $0x74,%eax,%eax
f0100154:	05 20 20 2a f0       	add    $0xf02a2020,%eax
f0100159:	39 c3                	cmp    %eax,%ebx
f010015b:	74 39                	je     f0100196 <i386_init+0xfc>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010015d:	89 d8                	mov    %ebx,%eax
f010015f:	2d 20 20 2a f0       	sub    $0xf02a2020,%eax
f0100164:	c1 f8 02             	sar    $0x2,%eax
f0100167:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010016d:	c1 e0 0f             	shl    $0xf,%eax
f0100170:	05 00 b0 2a f0       	add    $0xf02ab000,%eax
f0100175:	a3 94 1e 2a f0       	mov    %eax,0xf02a1e94
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010017a:	83 ec 08             	sub    $0x8,%esp
f010017d:	68 00 70 00 00       	push   $0x7000
f0100182:	0f b6 03             	movzbl (%ebx),%eax
f0100185:	50                   	push   %eax
f0100186:	e8 e0 57 00 00       	call   f010596b <lapic_startap>
f010018b:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f010018e:	8b 43 04             	mov    0x4(%ebx),%eax
f0100191:	83 f8 01             	cmp    $0x1,%eax
f0100194:	75 f8                	jne    f010018e <i386_init+0xf4>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100196:	83 c3 74             	add    $0x74,%ebx
f0100199:	6b 05 c4 23 2a f0 74 	imul   $0x74,0xf02a23c4,%eax
f01001a0:	05 20 20 2a f0       	add    $0xf02a2020,%eax
f01001a5:	39 c3                	cmp    %eax,%ebx
f01001a7:	72 a3                	jb     f010014c <i386_init+0xb2>

	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f01001a9:	83 ec 08             	sub    $0x8,%esp
f01001ac:	6a 01                	push   $0x1
f01001ae:	68 ac 1d 1d f0       	push   $0xf01d1dac
f01001b3:	e8 77 2f 00 00       	call   f010312f <env_create>

#if !defined(TEST_NO_NS)
	// Start ns.
	ENV_CREATE(net_ns, ENV_TYPE_NS);
f01001b8:	83 c4 08             	add    $0x8,%esp
f01001bb:	6a 02                	push   $0x2
f01001bd:	68 9c 96 22 f0       	push   $0xf022969c
f01001c2:	e8 68 2f 00 00       	call   f010312f <env_create>
#endif

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001c7:	83 c4 08             	add    $0x8,%esp
f01001ca:	6a 00                	push   $0x0
f01001cc:	68 ec 26 1f f0       	push   $0xf01f26ec
f01001d1:	e8 59 2f 00 00       	call   f010312f <env_create>
	// Touch all you want.
	ENV_CREATE(user_icode, ENV_TYPE_USER);
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001d6:	e8 27 04 00 00       	call   f0100602 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01001db:	e8 bb 3d 00 00       	call   f0103f9b <sched_yield>

f01001e0 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001e0:	55                   	push   %ebp
f01001e1:	89 e5                	mov    %esp,%ebp
f01001e3:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001e6:	a1 9c 1e 2a f0       	mov    0xf02a1e9c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001eb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001f0:	77 12                	ja     f0100204 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001f2:	50                   	push   %eax
f01001f3:	68 c8 69 10 f0       	push   $0xf01069c8
f01001f8:	6a 7c                	push   $0x7c
f01001fa:	68 07 6a 10 f0       	push   $0xf0106a07
f01001ff:	e8 3c fe ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100204:	05 00 00 00 10       	add    $0x10000000,%eax
f0100209:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010020c:	e8 f1 55 00 00       	call   f0105802 <cpunum>
f0100211:	83 ec 08             	sub    $0x8,%esp
f0100214:	50                   	push   %eax
f0100215:	68 13 6a 10 f0       	push   $0xf0106a13
f010021a:	e8 41 34 00 00       	call   f0103660 <cprintf>

	lapic_init();
f010021f:	e8 f9 55 00 00       	call   f010581d <lapic_init>
	env_init_percpu();
f0100224:	e8 37 2d 00 00       	call   f0102f60 <env_init_percpu>
	trap_init_percpu();
f0100229:	e8 46 34 00 00       	call   f0103674 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010022e:	e8 cf 55 00 00       	call   f0105802 <cpunum>
f0100233:	6b d0 74             	imul   $0x74,%eax,%edx
f0100236:	81 c2 20 20 2a f0    	add    $0xf02a2020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010023c:	b8 01 00 00 00       	mov    $0x1,%eax
f0100241:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100245:	c7 04 24 60 34 12 f0 	movl   $0xf0123460,(%esp)
f010024c:	e8 1f 58 00 00       	call   f0105a70 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100251:	e8 45 3d 00 00       	call   f0103f9b <sched_yield>

f0100256 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100256:	55                   	push   %ebp
f0100257:	89 e5                	mov    %esp,%ebp
f0100259:	53                   	push   %ebx
f010025a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010025d:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100260:	ff 75 0c             	pushl  0xc(%ebp)
f0100263:	ff 75 08             	pushl  0x8(%ebp)
f0100266:	68 29 6a 10 f0       	push   $0xf0106a29
f010026b:	e8 f0 33 00 00       	call   f0103660 <cprintf>
	vcprintf(fmt, ap);
f0100270:	83 c4 08             	add    $0x8,%esp
f0100273:	53                   	push   %ebx
f0100274:	ff 75 10             	pushl  0x10(%ebp)
f0100277:	e8 be 33 00 00       	call   f010363a <vcprintf>
	cprintf("\n");
f010027c:	c7 04 24 97 7b 10 f0 	movl   $0xf0107b97,(%esp)
f0100283:	e8 d8 33 00 00       	call   f0103660 <cprintf>
	va_end(ap);
}
f0100288:	83 c4 10             	add    $0x10,%esp
f010028b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010028e:	c9                   	leave  
f010028f:	c3                   	ret    

f0100290 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100290:	55                   	push   %ebp
f0100291:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100293:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100298:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100299:	a8 01                	test   $0x1,%al
f010029b:	74 0b                	je     f01002a8 <serial_proc_data+0x18>
f010029d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002a2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002a3:	0f b6 c0             	movzbl %al,%eax
f01002a6:	eb 05                	jmp    f01002ad <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002ad:	5d                   	pop    %ebp
f01002ae:	c3                   	ret    

f01002af <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002af:	55                   	push   %ebp
f01002b0:	89 e5                	mov    %esp,%ebp
f01002b2:	53                   	push   %ebx
f01002b3:	83 ec 04             	sub    $0x4,%esp
f01002b6:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002b8:	eb 2b                	jmp    f01002e5 <cons_intr+0x36>
		if (c == 0)
f01002ba:	85 c0                	test   %eax,%eax
f01002bc:	74 27                	je     f01002e5 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01002be:	8b 0d 24 12 2a f0    	mov    0xf02a1224,%ecx
f01002c4:	8d 51 01             	lea    0x1(%ecx),%edx
f01002c7:	89 15 24 12 2a f0    	mov    %edx,0xf02a1224
f01002cd:	88 81 20 10 2a f0    	mov    %al,-0xfd5efe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002d3:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002d9:	75 0a                	jne    f01002e5 <cons_intr+0x36>
			cons.wpos = 0;
f01002db:	c7 05 24 12 2a f0 00 	movl   $0x0,0xf02a1224
f01002e2:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002e5:	ff d3                	call   *%ebx
f01002e7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002ea:	75 ce                	jne    f01002ba <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002ec:	83 c4 04             	add    $0x4,%esp
f01002ef:	5b                   	pop    %ebx
f01002f0:	5d                   	pop    %ebp
f01002f1:	c3                   	ret    

f01002f2 <kbd_proc_data>:
f01002f2:	ba 64 00 00 00       	mov    $0x64,%edx
f01002f7:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01002f8:	a8 01                	test   $0x1,%al
f01002fa:	0f 84 f0 00 00 00    	je     f01003f0 <kbd_proc_data+0xfe>
f0100300:	ba 60 00 00 00       	mov    $0x60,%edx
f0100305:	ec                   	in     (%dx),%al
f0100306:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100308:	3c e0                	cmp    $0xe0,%al
f010030a:	75 0d                	jne    f0100319 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f010030c:	83 0d 00 10 2a f0 40 	orl    $0x40,0xf02a1000
		return 0;
f0100313:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100318:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100319:	55                   	push   %ebp
f010031a:	89 e5                	mov    %esp,%ebp
f010031c:	53                   	push   %ebx
f010031d:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100320:	84 c0                	test   %al,%al
f0100322:	79 36                	jns    f010035a <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100324:	8b 0d 00 10 2a f0    	mov    0xf02a1000,%ecx
f010032a:	89 cb                	mov    %ecx,%ebx
f010032c:	83 e3 40             	and    $0x40,%ebx
f010032f:	83 e0 7f             	and    $0x7f,%eax
f0100332:	85 db                	test   %ebx,%ebx
f0100334:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100337:	0f b6 d2             	movzbl %dl,%edx
f010033a:	0f b6 82 a0 6b 10 f0 	movzbl -0xfef9460(%edx),%eax
f0100341:	83 c8 40             	or     $0x40,%eax
f0100344:	0f b6 c0             	movzbl %al,%eax
f0100347:	f7 d0                	not    %eax
f0100349:	21 c8                	and    %ecx,%eax
f010034b:	a3 00 10 2a f0       	mov    %eax,0xf02a1000
		return 0;
f0100350:	b8 00 00 00 00       	mov    $0x0,%eax
f0100355:	e9 9e 00 00 00       	jmp    f01003f8 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f010035a:	8b 0d 00 10 2a f0    	mov    0xf02a1000,%ecx
f0100360:	f6 c1 40             	test   $0x40,%cl
f0100363:	74 0e                	je     f0100373 <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100365:	83 c8 80             	or     $0xffffff80,%eax
f0100368:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010036a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010036d:	89 0d 00 10 2a f0    	mov    %ecx,0xf02a1000
	}

	shift |= shiftcode[data];
f0100373:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100376:	0f b6 82 a0 6b 10 f0 	movzbl -0xfef9460(%edx),%eax
f010037d:	0b 05 00 10 2a f0    	or     0xf02a1000,%eax
f0100383:	0f b6 8a a0 6a 10 f0 	movzbl -0xfef9560(%edx),%ecx
f010038a:	31 c8                	xor    %ecx,%eax
f010038c:	a3 00 10 2a f0       	mov    %eax,0xf02a1000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100391:	89 c1                	mov    %eax,%ecx
f0100393:	83 e1 03             	and    $0x3,%ecx
f0100396:	8b 0c 8d 80 6a 10 f0 	mov    -0xfef9580(,%ecx,4),%ecx
f010039d:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003a1:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01003a4:	a8 08                	test   $0x8,%al
f01003a6:	74 1b                	je     f01003c3 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f01003a8:	89 da                	mov    %ebx,%edx
f01003aa:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003ad:	83 f9 19             	cmp    $0x19,%ecx
f01003b0:	77 05                	ja     f01003b7 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f01003b2:	83 eb 20             	sub    $0x20,%ebx
f01003b5:	eb 0c                	jmp    f01003c3 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f01003b7:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003ba:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003bd:	83 fa 19             	cmp    $0x19,%edx
f01003c0:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003c3:	f7 d0                	not    %eax
f01003c5:	a8 06                	test   $0x6,%al
f01003c7:	75 2d                	jne    f01003f6 <kbd_proc_data+0x104>
f01003c9:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003cf:	75 25                	jne    f01003f6 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01003d1:	83 ec 0c             	sub    $0xc,%esp
f01003d4:	68 43 6a 10 f0       	push   $0xf0106a43
f01003d9:	e8 82 32 00 00       	call   f0103660 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003de:	ba 92 00 00 00       	mov    $0x92,%edx
f01003e3:	b8 03 00 00 00       	mov    $0x3,%eax
f01003e8:	ee                   	out    %al,(%dx)
f01003e9:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003ec:	89 d8                	mov    %ebx,%eax
f01003ee:	eb 08                	jmp    f01003f8 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01003f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003f5:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003f6:	89 d8                	mov    %ebx,%eax
}
f01003f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003fb:	c9                   	leave  
f01003fc:	c3                   	ret    

f01003fd <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003fd:	55                   	push   %ebp
f01003fe:	89 e5                	mov    %esp,%ebp
f0100400:	57                   	push   %edi
f0100401:	56                   	push   %esi
f0100402:	53                   	push   %ebx
f0100403:	83 ec 1c             	sub    $0x1c,%esp
f0100406:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100408:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010040d:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100412:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100417:	eb 09                	jmp    f0100422 <cons_putc+0x25>
f0100419:	89 ca                	mov    %ecx,%edx
f010041b:	ec                   	in     (%dx),%al
f010041c:	ec                   	in     (%dx),%al
f010041d:	ec                   	in     (%dx),%al
f010041e:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f010041f:	83 c3 01             	add    $0x1,%ebx
f0100422:	89 f2                	mov    %esi,%edx
f0100424:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100425:	a8 20                	test   $0x20,%al
f0100427:	75 08                	jne    f0100431 <cons_putc+0x34>
f0100429:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010042f:	7e e8                	jle    f0100419 <cons_putc+0x1c>
f0100431:	89 f8                	mov    %edi,%eax
f0100433:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100436:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010043b:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010043c:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100441:	be 79 03 00 00       	mov    $0x379,%esi
f0100446:	b9 84 00 00 00       	mov    $0x84,%ecx
f010044b:	eb 09                	jmp    f0100456 <cons_putc+0x59>
f010044d:	89 ca                	mov    %ecx,%edx
f010044f:	ec                   	in     (%dx),%al
f0100450:	ec                   	in     (%dx),%al
f0100451:	ec                   	in     (%dx),%al
f0100452:	ec                   	in     (%dx),%al
f0100453:	83 c3 01             	add    $0x1,%ebx
f0100456:	89 f2                	mov    %esi,%edx
f0100458:	ec                   	in     (%dx),%al
f0100459:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010045f:	7f 04                	jg     f0100465 <cons_putc+0x68>
f0100461:	84 c0                	test   %al,%al
f0100463:	79 e8                	jns    f010044d <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100465:	ba 78 03 00 00       	mov    $0x378,%edx
f010046a:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010046e:	ee                   	out    %al,(%dx)
f010046f:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100474:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100479:	ee                   	out    %al,(%dx)
f010047a:	b8 08 00 00 00       	mov    $0x8,%eax
f010047f:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100480:	89 fa                	mov    %edi,%edx
f0100482:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100488:	89 f8                	mov    %edi,%eax
f010048a:	80 cc 07             	or     $0x7,%ah
f010048d:	85 d2                	test   %edx,%edx
f010048f:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100492:	89 f8                	mov    %edi,%eax
f0100494:	0f b6 c0             	movzbl %al,%eax
f0100497:	83 f8 09             	cmp    $0x9,%eax
f010049a:	74 74                	je     f0100510 <cons_putc+0x113>
f010049c:	83 f8 09             	cmp    $0x9,%eax
f010049f:	7f 0a                	jg     f01004ab <cons_putc+0xae>
f01004a1:	83 f8 08             	cmp    $0x8,%eax
f01004a4:	74 14                	je     f01004ba <cons_putc+0xbd>
f01004a6:	e9 99 00 00 00       	jmp    f0100544 <cons_putc+0x147>
f01004ab:	83 f8 0a             	cmp    $0xa,%eax
f01004ae:	74 3a                	je     f01004ea <cons_putc+0xed>
f01004b0:	83 f8 0d             	cmp    $0xd,%eax
f01004b3:	74 3d                	je     f01004f2 <cons_putc+0xf5>
f01004b5:	e9 8a 00 00 00       	jmp    f0100544 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01004ba:	0f b7 05 28 12 2a f0 	movzwl 0xf02a1228,%eax
f01004c1:	66 85 c0             	test   %ax,%ax
f01004c4:	0f 84 e6 00 00 00    	je     f01005b0 <cons_putc+0x1b3>
			crt_pos--;
f01004ca:	83 e8 01             	sub    $0x1,%eax
f01004cd:	66 a3 28 12 2a f0    	mov    %ax,0xf02a1228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004d3:	0f b7 c0             	movzwl %ax,%eax
f01004d6:	66 81 e7 00 ff       	and    $0xff00,%di
f01004db:	83 cf 20             	or     $0x20,%edi
f01004de:	8b 15 2c 12 2a f0    	mov    0xf02a122c,%edx
f01004e4:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004e8:	eb 78                	jmp    f0100562 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004ea:	66 83 05 28 12 2a f0 	addw   $0x50,0xf02a1228
f01004f1:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004f2:	0f b7 05 28 12 2a f0 	movzwl 0xf02a1228,%eax
f01004f9:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004ff:	c1 e8 16             	shr    $0x16,%eax
f0100502:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100505:	c1 e0 04             	shl    $0x4,%eax
f0100508:	66 a3 28 12 2a f0    	mov    %ax,0xf02a1228
f010050e:	eb 52                	jmp    f0100562 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f0100510:	b8 20 00 00 00       	mov    $0x20,%eax
f0100515:	e8 e3 fe ff ff       	call   f01003fd <cons_putc>
		cons_putc(' ');
f010051a:	b8 20 00 00 00       	mov    $0x20,%eax
f010051f:	e8 d9 fe ff ff       	call   f01003fd <cons_putc>
		cons_putc(' ');
f0100524:	b8 20 00 00 00       	mov    $0x20,%eax
f0100529:	e8 cf fe ff ff       	call   f01003fd <cons_putc>
		cons_putc(' ');
f010052e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100533:	e8 c5 fe ff ff       	call   f01003fd <cons_putc>
		cons_putc(' ');
f0100538:	b8 20 00 00 00       	mov    $0x20,%eax
f010053d:	e8 bb fe ff ff       	call   f01003fd <cons_putc>
f0100542:	eb 1e                	jmp    f0100562 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100544:	0f b7 05 28 12 2a f0 	movzwl 0xf02a1228,%eax
f010054b:	8d 50 01             	lea    0x1(%eax),%edx
f010054e:	66 89 15 28 12 2a f0 	mov    %dx,0xf02a1228
f0100555:	0f b7 c0             	movzwl %ax,%eax
f0100558:	8b 15 2c 12 2a f0    	mov    0xf02a122c,%edx
f010055e:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100562:	66 81 3d 28 12 2a f0 	cmpw   $0x7cf,0xf02a1228
f0100569:	cf 07 
f010056b:	76 43                	jbe    f01005b0 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010056d:	a1 2c 12 2a f0       	mov    0xf02a122c,%eax
f0100572:	83 ec 04             	sub    $0x4,%esp
f0100575:	68 00 0f 00 00       	push   $0xf00
f010057a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100580:	52                   	push   %edx
f0100581:	50                   	push   %eax
f0100582:	e8 a8 4c 00 00       	call   f010522f <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100587:	8b 15 2c 12 2a f0    	mov    0xf02a122c,%edx
f010058d:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100593:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100599:	83 c4 10             	add    $0x10,%esp
f010059c:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005a1:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005a4:	39 d0                	cmp    %edx,%eax
f01005a6:	75 f4                	jne    f010059c <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005a8:	66 83 2d 28 12 2a f0 	subw   $0x50,0xf02a1228
f01005af:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005b0:	8b 0d 30 12 2a f0    	mov    0xf02a1230,%ecx
f01005b6:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005bb:	89 ca                	mov    %ecx,%edx
f01005bd:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005be:	0f b7 1d 28 12 2a f0 	movzwl 0xf02a1228,%ebx
f01005c5:	8d 71 01             	lea    0x1(%ecx),%esi
f01005c8:	89 d8                	mov    %ebx,%eax
f01005ca:	66 c1 e8 08          	shr    $0x8,%ax
f01005ce:	89 f2                	mov    %esi,%edx
f01005d0:	ee                   	out    %al,(%dx)
f01005d1:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005d6:	89 ca                	mov    %ecx,%edx
f01005d8:	ee                   	out    %al,(%dx)
f01005d9:	89 d8                	mov    %ebx,%eax
f01005db:	89 f2                	mov    %esi,%edx
f01005dd:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005de:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005e1:	5b                   	pop    %ebx
f01005e2:	5e                   	pop    %esi
f01005e3:	5f                   	pop    %edi
f01005e4:	5d                   	pop    %ebp
f01005e5:	c3                   	ret    

f01005e6 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005e6:	80 3d 34 12 2a f0 00 	cmpb   $0x0,0xf02a1234
f01005ed:	74 11                	je     f0100600 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005ef:	55                   	push   %ebp
f01005f0:	89 e5                	mov    %esp,%ebp
f01005f2:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005f5:	b8 90 02 10 f0       	mov    $0xf0100290,%eax
f01005fa:	e8 b0 fc ff ff       	call   f01002af <cons_intr>
}
f01005ff:	c9                   	leave  
f0100600:	f3 c3                	repz ret 

f0100602 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100602:	55                   	push   %ebp
f0100603:	89 e5                	mov    %esp,%ebp
f0100605:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100608:	b8 f2 02 10 f0       	mov    $0xf01002f2,%eax
f010060d:	e8 9d fc ff ff       	call   f01002af <cons_intr>
}
f0100612:	c9                   	leave  
f0100613:	c3                   	ret    

f0100614 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100614:	55                   	push   %ebp
f0100615:	89 e5                	mov    %esp,%ebp
f0100617:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010061a:	e8 c7 ff ff ff       	call   f01005e6 <serial_intr>
	kbd_intr();
f010061f:	e8 de ff ff ff       	call   f0100602 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100624:	a1 20 12 2a f0       	mov    0xf02a1220,%eax
f0100629:	3b 05 24 12 2a f0    	cmp    0xf02a1224,%eax
f010062f:	74 26                	je     f0100657 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100631:	8d 50 01             	lea    0x1(%eax),%edx
f0100634:	89 15 20 12 2a f0    	mov    %edx,0xf02a1220
f010063a:	0f b6 88 20 10 2a f0 	movzbl -0xfd5efe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100641:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100643:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100649:	75 11                	jne    f010065c <cons_getc+0x48>
			cons.rpos = 0;
f010064b:	c7 05 20 12 2a f0 00 	movl   $0x0,0xf02a1220
f0100652:	00 00 00 
f0100655:	eb 05                	jmp    f010065c <cons_getc+0x48>
		return c;
	}
	return 0;
f0100657:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010065c:	c9                   	leave  
f010065d:	c3                   	ret    

f010065e <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010065e:	55                   	push   %ebp
f010065f:	89 e5                	mov    %esp,%ebp
f0100661:	57                   	push   %edi
f0100662:	56                   	push   %esi
f0100663:	53                   	push   %ebx
f0100664:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100667:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010066e:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100675:	5a a5 
	if (*cp != 0xA55A) {
f0100677:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010067e:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100682:	74 11                	je     f0100695 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100684:	c7 05 30 12 2a f0 b4 	movl   $0x3b4,0xf02a1230
f010068b:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010068e:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100693:	eb 16                	jmp    f01006ab <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100695:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010069c:	c7 05 30 12 2a f0 d4 	movl   $0x3d4,0xf02a1230
f01006a3:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006a6:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006ab:	8b 3d 30 12 2a f0    	mov    0xf02a1230,%edi
f01006b1:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006b6:	89 fa                	mov    %edi,%edx
f01006b8:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006b9:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006bc:	89 da                	mov    %ebx,%edx
f01006be:	ec                   	in     (%dx),%al
f01006bf:	0f b6 c8             	movzbl %al,%ecx
f01006c2:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006c5:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006ca:	89 fa                	mov    %edi,%edx
f01006cc:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006cd:	89 da                	mov    %ebx,%edx
f01006cf:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006d0:	89 35 2c 12 2a f0    	mov    %esi,0xf02a122c
	crt_pos = pos;
f01006d6:	0f b6 c0             	movzbl %al,%eax
f01006d9:	09 c8                	or     %ecx,%eax
f01006db:	66 a3 28 12 2a f0    	mov    %ax,0xf02a1228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006e1:	e8 1c ff ff ff       	call   f0100602 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006e6:	83 ec 0c             	sub    $0xc,%esp
f01006e9:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f01006f0:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006f5:	50                   	push   %eax
f01006f6:	e8 fe 2d 00 00       	call   f01034f9 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006fb:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100700:	b8 00 00 00 00       	mov    $0x0,%eax
f0100705:	89 f2                	mov    %esi,%edx
f0100707:	ee                   	out    %al,(%dx)
f0100708:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010070d:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100712:	ee                   	out    %al,(%dx)
f0100713:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100718:	b8 0c 00 00 00       	mov    $0xc,%eax
f010071d:	89 da                	mov    %ebx,%edx
f010071f:	ee                   	out    %al,(%dx)
f0100720:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100725:	b8 00 00 00 00       	mov    $0x0,%eax
f010072a:	ee                   	out    %al,(%dx)
f010072b:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100730:	b8 03 00 00 00       	mov    $0x3,%eax
f0100735:	ee                   	out    %al,(%dx)
f0100736:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010073b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100740:	ee                   	out    %al,(%dx)
f0100741:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100746:	b8 01 00 00 00       	mov    $0x1,%eax
f010074b:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010074c:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100751:	ec                   	in     (%dx),%al
f0100752:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100754:	83 c4 10             	add    $0x10,%esp
f0100757:	3c ff                	cmp    $0xff,%al
f0100759:	0f 95 05 34 12 2a f0 	setne  0xf02a1234
f0100760:	89 f2                	mov    %esi,%edx
f0100762:	ec                   	in     (%dx),%al
f0100763:	89 da                	mov    %ebx,%edx
f0100765:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f0100766:	80 f9 ff             	cmp    $0xff,%cl
f0100769:	74 21                	je     f010078c <cons_init+0x12e>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<4));
f010076b:	83 ec 0c             	sub    $0xc,%esp
f010076e:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f0100775:	25 ef ff 00 00       	and    $0xffef,%eax
f010077a:	50                   	push   %eax
f010077b:	e8 79 2d 00 00       	call   f01034f9 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100780:	83 c4 10             	add    $0x10,%esp
f0100783:	80 3d 34 12 2a f0 00 	cmpb   $0x0,0xf02a1234
f010078a:	75 10                	jne    f010079c <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f010078c:	83 ec 0c             	sub    $0xc,%esp
f010078f:	68 4f 6a 10 f0       	push   $0xf0106a4f
f0100794:	e8 c7 2e 00 00       	call   f0103660 <cprintf>
f0100799:	83 c4 10             	add    $0x10,%esp
}
f010079c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010079f:	5b                   	pop    %ebx
f01007a0:	5e                   	pop    %esi
f01007a1:	5f                   	pop    %edi
f01007a2:	5d                   	pop    %ebp
f01007a3:	c3                   	ret    

f01007a4 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007a4:	55                   	push   %ebp
f01007a5:	89 e5                	mov    %esp,%ebp
f01007a7:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01007ad:	e8 4b fc ff ff       	call   f01003fd <cons_putc>
}
f01007b2:	c9                   	leave  
f01007b3:	c3                   	ret    

f01007b4 <getchar>:

int
getchar(void)
{
f01007b4:	55                   	push   %ebp
f01007b5:	89 e5                	mov    %esp,%ebp
f01007b7:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007ba:	e8 55 fe ff ff       	call   f0100614 <cons_getc>
f01007bf:	85 c0                	test   %eax,%eax
f01007c1:	74 f7                	je     f01007ba <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007c3:	c9                   	leave  
f01007c4:	c3                   	ret    

f01007c5 <iscons>:

int
iscons(int fdnum)
{
f01007c5:	55                   	push   %ebp
f01007c6:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007c8:	b8 01 00 00 00       	mov    $0x1,%eax
f01007cd:	5d                   	pop    %ebp
f01007ce:	c3                   	ret    

f01007cf <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007cf:	55                   	push   %ebp
f01007d0:	89 e5                	mov    %esp,%ebp
f01007d2:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007d5:	68 a0 6c 10 f0       	push   $0xf0106ca0
f01007da:	68 be 6c 10 f0       	push   $0xf0106cbe
f01007df:	68 c3 6c 10 f0       	push   $0xf0106cc3
f01007e4:	e8 77 2e 00 00       	call   f0103660 <cprintf>
f01007e9:	83 c4 0c             	add    $0xc,%esp
f01007ec:	68 2c 6d 10 f0       	push   $0xf0106d2c
f01007f1:	68 cc 6c 10 f0       	push   $0xf0106ccc
f01007f6:	68 c3 6c 10 f0       	push   $0xf0106cc3
f01007fb:	e8 60 2e 00 00       	call   f0103660 <cprintf>
	return 0;
}
f0100800:	b8 00 00 00 00       	mov    $0x0,%eax
f0100805:	c9                   	leave  
f0100806:	c3                   	ret    

f0100807 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100807:	55                   	push   %ebp
f0100808:	89 e5                	mov    %esp,%ebp
f010080a:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010080d:	68 d5 6c 10 f0       	push   $0xf0106cd5
f0100812:	e8 49 2e 00 00       	call   f0103660 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100817:	83 c4 08             	add    $0x8,%esp
f010081a:	68 0c 00 10 00       	push   $0x10000c
f010081f:	68 54 6d 10 f0       	push   $0xf0106d54
f0100824:	e8 37 2e 00 00       	call   f0103660 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100829:	83 c4 0c             	add    $0xc,%esp
f010082c:	68 0c 00 10 00       	push   $0x10000c
f0100831:	68 0c 00 10 f0       	push   $0xf010000c
f0100836:	68 7c 6d 10 f0       	push   $0xf0106d7c
f010083b:	e8 20 2e 00 00       	call   f0103660 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100840:	83 c4 0c             	add    $0xc,%esp
f0100843:	68 71 69 10 00       	push   $0x106971
f0100848:	68 71 69 10 f0       	push   $0xf0106971
f010084d:	68 a0 6d 10 f0       	push   $0xf0106da0
f0100852:	e8 09 2e 00 00       	call   f0103660 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100857:	83 c4 0c             	add    $0xc,%esp
f010085a:	68 d0 0a 2a 00       	push   $0x2a0ad0
f010085f:	68 d0 0a 2a f0       	push   $0xf02a0ad0
f0100864:	68 c4 6d 10 f0       	push   $0xf0106dc4
f0100869:	e8 f2 2d 00 00       	call   f0103660 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010086e:	83 c4 0c             	add    $0xc,%esp
f0100871:	68 80 32 2e 00       	push   $0x2e3280
f0100876:	68 80 32 2e f0       	push   $0xf02e3280
f010087b:	68 e8 6d 10 f0       	push   $0xf0106de8
f0100880:	e8 db 2d 00 00       	call   f0103660 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100885:	b8 7f 36 2e f0       	mov    $0xf02e367f,%eax
f010088a:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010088f:	83 c4 08             	add    $0x8,%esp
f0100892:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100897:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010089d:	85 c0                	test   %eax,%eax
f010089f:	0f 48 c2             	cmovs  %edx,%eax
f01008a2:	c1 f8 0a             	sar    $0xa,%eax
f01008a5:	50                   	push   %eax
f01008a6:	68 0c 6e 10 f0       	push   $0xf0106e0c
f01008ab:	e8 b0 2d 00 00       	call   f0103660 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008b0:	b8 00 00 00 00       	mov    $0x0,%eax
f01008b5:	c9                   	leave  
f01008b6:	c3                   	ret    

f01008b7 <mon_backtrace>:

// TODO: Implement lab1's backtrace monitor command
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008b7:	55                   	push   %ebp
f01008b8:	89 e5                	mov    %esp,%ebp
f01008ba:	56                   	push   %esi
f01008bb:	53                   	push   %ebx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01008bc:	89 eb                	mov    %ebp,%ebx
	// Your code here.
	uint32_t a = read_ebp();

        int i = 8;
        int *ebp = (int*) a;
f01008be:	be 08 00 00 00       	mov    $0x8,%esi
        while(i > 0) {
                cprintf("ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
f01008c3:	ff 73 18             	pushl  0x18(%ebx)
f01008c6:	ff 73 14             	pushl  0x14(%ebx)
f01008c9:	ff 73 10             	pushl  0x10(%ebx)
f01008cc:	ff 73 0c             	pushl  0xc(%ebx)
f01008cf:	ff 73 08             	pushl  0x8(%ebx)
f01008d2:	ff 73 04             	pushl  0x4(%ebx)
f01008d5:	53                   	push   %ebx
f01008d6:	68 38 6e 10 f0       	push   $0xf0106e38
f01008db:	e8 80 2d 00 00       	call   f0103660 <cprintf>
                         ebp, ebp[1], ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
                ebp = (int*) ebp[0];
f01008e0:	8b 1b                	mov    (%ebx),%ebx
	// Your code here.
	uint32_t a = read_ebp();

        int i = 8;
        int *ebp = (int*) a;
        while(i > 0) {
f01008e2:	83 c4 20             	add    $0x20,%esp
f01008e5:	83 ee 01             	sub    $0x1,%esi
f01008e8:	75 d9                	jne    f01008c3 <mon_backtrace+0xc>
                ebp = (int*) ebp[0];
                i--;
        }

        return 0;
}
f01008ea:	b8 00 00 00 00       	mov    $0x0,%eax
f01008ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01008f2:	5b                   	pop    %ebx
f01008f3:	5e                   	pop    %esi
f01008f4:	5d                   	pop    %ebp
f01008f5:	c3                   	ret    

f01008f6 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008f6:	55                   	push   %ebp
f01008f7:	89 e5                	mov    %esp,%ebp
f01008f9:	57                   	push   %edi
f01008fa:	56                   	push   %esi
f01008fb:	53                   	push   %ebx
f01008fc:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008ff:	68 6c 6e 10 f0       	push   $0xf0106e6c
f0100904:	e8 57 2d 00 00       	call   f0103660 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100909:	c7 04 24 90 6e 10 f0 	movl   $0xf0106e90,(%esp)
f0100910:	e8 4b 2d 00 00       	call   f0103660 <cprintf>

	if (tf != NULL)
f0100915:	83 c4 10             	add    $0x10,%esp
f0100918:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010091c:	74 0e                	je     f010092c <monitor+0x36>
		print_trapframe(tf);
f010091e:	83 ec 0c             	sub    $0xc,%esp
f0100921:	ff 75 08             	pushl  0x8(%ebp)
f0100924:	e8 8e 2f 00 00       	call   f01038b7 <print_trapframe>
f0100929:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f010092c:	83 ec 0c             	sub    $0xc,%esp
f010092f:	68 ee 6c 10 f0       	push   $0xf0106cee
f0100934:	e8 3a 46 00 00       	call   f0104f73 <readline>
f0100939:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010093b:	83 c4 10             	add    $0x10,%esp
f010093e:	85 c0                	test   %eax,%eax
f0100940:	74 ea                	je     f010092c <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100942:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100949:	be 00 00 00 00       	mov    $0x0,%esi
f010094e:	eb 0a                	jmp    f010095a <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100950:	c6 03 00             	movb   $0x0,(%ebx)
f0100953:	89 f7                	mov    %esi,%edi
f0100955:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100958:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010095a:	0f b6 03             	movzbl (%ebx),%eax
f010095d:	84 c0                	test   %al,%al
f010095f:	74 63                	je     f01009c4 <monitor+0xce>
f0100961:	83 ec 08             	sub    $0x8,%esp
f0100964:	0f be c0             	movsbl %al,%eax
f0100967:	50                   	push   %eax
f0100968:	68 f2 6c 10 f0       	push   $0xf0106cf2
f010096d:	e8 33 48 00 00       	call   f01051a5 <strchr>
f0100972:	83 c4 10             	add    $0x10,%esp
f0100975:	85 c0                	test   %eax,%eax
f0100977:	75 d7                	jne    f0100950 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100979:	80 3b 00             	cmpb   $0x0,(%ebx)
f010097c:	74 46                	je     f01009c4 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010097e:	83 fe 0f             	cmp    $0xf,%esi
f0100981:	75 14                	jne    f0100997 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100983:	83 ec 08             	sub    $0x8,%esp
f0100986:	6a 10                	push   $0x10
f0100988:	68 f7 6c 10 f0       	push   $0xf0106cf7
f010098d:	e8 ce 2c 00 00       	call   f0103660 <cprintf>
f0100992:	83 c4 10             	add    $0x10,%esp
f0100995:	eb 95                	jmp    f010092c <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100997:	8d 7e 01             	lea    0x1(%esi),%edi
f010099a:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010099e:	eb 03                	jmp    f01009a3 <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01009a0:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01009a3:	0f b6 03             	movzbl (%ebx),%eax
f01009a6:	84 c0                	test   %al,%al
f01009a8:	74 ae                	je     f0100958 <monitor+0x62>
f01009aa:	83 ec 08             	sub    $0x8,%esp
f01009ad:	0f be c0             	movsbl %al,%eax
f01009b0:	50                   	push   %eax
f01009b1:	68 f2 6c 10 f0       	push   $0xf0106cf2
f01009b6:	e8 ea 47 00 00       	call   f01051a5 <strchr>
f01009bb:	83 c4 10             	add    $0x10,%esp
f01009be:	85 c0                	test   %eax,%eax
f01009c0:	74 de                	je     f01009a0 <monitor+0xaa>
f01009c2:	eb 94                	jmp    f0100958 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f01009c4:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009cb:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01009cc:	85 f6                	test   %esi,%esi
f01009ce:	0f 84 58 ff ff ff    	je     f010092c <monitor+0x36>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01009d4:	83 ec 08             	sub    $0x8,%esp
f01009d7:	68 be 6c 10 f0       	push   $0xf0106cbe
f01009dc:	ff 75 a8             	pushl  -0x58(%ebp)
f01009df:	e8 63 47 00 00       	call   f0105147 <strcmp>
f01009e4:	83 c4 10             	add    $0x10,%esp
f01009e7:	85 c0                	test   %eax,%eax
f01009e9:	74 1e                	je     f0100a09 <monitor+0x113>
f01009eb:	83 ec 08             	sub    $0x8,%esp
f01009ee:	68 cc 6c 10 f0       	push   $0xf0106ccc
f01009f3:	ff 75 a8             	pushl  -0x58(%ebp)
f01009f6:	e8 4c 47 00 00       	call   f0105147 <strcmp>
f01009fb:	83 c4 10             	add    $0x10,%esp
f01009fe:	85 c0                	test   %eax,%eax
f0100a00:	75 2f                	jne    f0100a31 <monitor+0x13b>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a02:	b8 01 00 00 00       	mov    $0x1,%eax
f0100a07:	eb 05                	jmp    f0100a0e <monitor+0x118>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a09:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100a0e:	83 ec 04             	sub    $0x4,%esp
f0100a11:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100a14:	01 d0                	add    %edx,%eax
f0100a16:	ff 75 08             	pushl  0x8(%ebp)
f0100a19:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100a1c:	51                   	push   %ecx
f0100a1d:	56                   	push   %esi
f0100a1e:	ff 14 85 c0 6e 10 f0 	call   *-0xfef9140(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a25:	83 c4 10             	add    $0x10,%esp
f0100a28:	85 c0                	test   %eax,%eax
f0100a2a:	78 1d                	js     f0100a49 <monitor+0x153>
f0100a2c:	e9 fb fe ff ff       	jmp    f010092c <monitor+0x36>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a31:	83 ec 08             	sub    $0x8,%esp
f0100a34:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a37:	68 14 6d 10 f0       	push   $0xf0106d14
f0100a3c:	e8 1f 2c 00 00       	call   f0103660 <cprintf>
f0100a41:	83 c4 10             	add    $0x10,%esp
f0100a44:	e9 e3 fe ff ff       	jmp    f010092c <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a49:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a4c:	5b                   	pop    %ebx
f0100a4d:	5e                   	pop    %esi
f0100a4e:	5f                   	pop    %edi
f0100a4f:	5d                   	pop    %ebp
f0100a50:	c3                   	ret    

f0100a51 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100a51:	89 d1                	mov    %edx,%ecx
f0100a53:	c1 e9 16             	shr    $0x16,%ecx
f0100a56:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100a59:	a8 01                	test   $0x1,%al
f0100a5b:	74 52                	je     f0100aaf <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a5d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a62:	89 c1                	mov    %eax,%ecx
f0100a64:	c1 e9 0c             	shr    $0xc,%ecx
f0100a67:	3b 0d 98 1e 2a f0    	cmp    0xf02a1e98,%ecx
f0100a6d:	72 1b                	jb     f0100a8a <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a6f:	55                   	push   %ebp
f0100a70:	89 e5                	mov    %esp,%ebp
f0100a72:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a75:	50                   	push   %eax
f0100a76:	68 a4 69 10 f0       	push   $0xf01069a4
f0100a7b:	68 b4 03 00 00       	push   $0x3b4
f0100a80:	68 9d 78 10 f0       	push   $0xf010789d
f0100a85:	e8 b6 f5 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100a8a:	c1 ea 0c             	shr    $0xc,%edx
f0100a8d:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a93:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a9a:	89 c2                	mov    %eax,%edx
f0100a9c:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a9f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100aa4:	85 d2                	test   %edx,%edx
f0100aa6:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100aab:	0f 44 c2             	cmove  %edx,%eax
f0100aae:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100aaf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100ab4:	c3                   	ret    

f0100ab5 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100ab5:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100ab7:	83 3d 38 12 2a f0 00 	cmpl   $0x0,0xf02a1238
f0100abe:	75 0f                	jne    f0100acf <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100ac0:	b8 7f 42 2e f0       	mov    $0xf02e427f,%eax
f0100ac5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100aca:	a3 38 12 2a f0       	mov    %eax,0xf02a1238
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	// TODO: Test if 'panic: out of memory' is working
	result = nextfree;
f0100acf:	a1 38 12 2a f0       	mov    0xf02a1238,%eax
	if (n > 0) {
f0100ad4:	85 d2                	test   %edx,%edx
f0100ad6:	74 5f                	je     f0100b37 <boot_alloc+0x82>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100ad8:	55                   	push   %ebp
f0100ad9:	89 e5                	mov    %esp,%ebp
f0100adb:	53                   	push   %ebx
f0100adc:	83 ec 04             	sub    $0x4,%esp
	//
	// LAB 2: Your code here.
	// TODO: Test if 'panic: out of memory' is working
	result = nextfree;
	if (n > 0) {
		if ((uint32_t) PADDR(ROUNDUP(nextfree+n, PGSIZE)) > npages*PGSIZE)
f0100adf:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100ae6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100aec:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100af2:	77 12                	ja     f0100b06 <boot_alloc+0x51>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100af4:	52                   	push   %edx
f0100af5:	68 c8 69 10 f0       	push   $0xf01069c8
f0100afa:	6a 6b                	push   $0x6b
f0100afc:	68 9d 78 10 f0       	push   $0xf010789d
f0100b01:	e8 3a f5 ff ff       	call   f0100040 <_panic>
f0100b06:	8b 0d 98 1e 2a f0    	mov    0xf02a1e98,%ecx
f0100b0c:	c1 e1 0c             	shl    $0xc,%ecx
f0100b0f:	8d 9a 00 00 00 10    	lea    0x10000000(%edx),%ebx
f0100b15:	39 d9                	cmp    %ebx,%ecx
f0100b17:	73 14                	jae    f0100b2d <boot_alloc+0x78>
			panic("boot_alloc: out of memory");
f0100b19:	83 ec 04             	sub    $0x4,%esp
f0100b1c:	68 a9 78 10 f0       	push   $0xf01078a9
f0100b21:	6a 6c                	push   $0x6c
f0100b23:	68 9d 78 10 f0       	push   $0xf010789d
f0100b28:	e8 13 f5 ff ff       	call   f0100040 <_panic>
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100b2d:	89 15 38 12 2a f0    	mov    %edx,0xf02a1238
	}
	return result;
}
f0100b33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b36:	c9                   	leave  
f0100b37:	f3 c3                	repz ret 

f0100b39 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b39:	55                   	push   %ebp
f0100b3a:	89 e5                	mov    %esp,%ebp
f0100b3c:	57                   	push   %edi
f0100b3d:	56                   	push   %esi
f0100b3e:	53                   	push   %ebx
f0100b3f:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b42:	84 c0                	test   %al,%al
f0100b44:	0f 85 91 02 00 00    	jne    f0100ddb <check_page_free_list+0x2a2>
f0100b4a:	e9 9e 02 00 00       	jmp    f0100ded <check_page_free_list+0x2b4>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b4f:	83 ec 04             	sub    $0x4,%esp
f0100b52:	68 d0 6e 10 f0       	push   $0xf0106ed0
f0100b57:	68 e9 02 00 00       	push   $0x2e9
f0100b5c:	68 9d 78 10 f0       	push   $0xf010789d
f0100b61:	e8 da f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b66:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b69:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b6c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b6f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b72:	89 c2                	mov    %eax,%edx
f0100b74:	2b 15 a0 1e 2a f0    	sub    0xf02a1ea0,%edx
f0100b7a:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b80:	0f 95 c2             	setne  %dl
f0100b83:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b86:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b8a:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b8c:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b90:	8b 00                	mov    (%eax),%eax
f0100b92:	85 c0                	test   %eax,%eax
f0100b94:	75 dc                	jne    f0100b72 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100b96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b99:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100b9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ba2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ba5:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100ba7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100baa:	a3 40 12 2a f0       	mov    %eax,0xf02a1240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100baf:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bb4:	8b 1d 40 12 2a f0    	mov    0xf02a1240,%ebx
f0100bba:	eb 53                	jmp    f0100c0f <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bbc:	89 d8                	mov    %ebx,%eax
f0100bbe:	2b 05 a0 1e 2a f0    	sub    0xf02a1ea0,%eax
f0100bc4:	c1 f8 03             	sar    $0x3,%eax
f0100bc7:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bca:	89 c2                	mov    %eax,%edx
f0100bcc:	c1 ea 16             	shr    $0x16,%edx
f0100bcf:	39 f2                	cmp    %esi,%edx
f0100bd1:	73 3a                	jae    f0100c0d <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bd3:	89 c2                	mov    %eax,%edx
f0100bd5:	c1 ea 0c             	shr    $0xc,%edx
f0100bd8:	3b 15 98 1e 2a f0    	cmp    0xf02a1e98,%edx
f0100bde:	72 12                	jb     f0100bf2 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100be0:	50                   	push   %eax
f0100be1:	68 a4 69 10 f0       	push   $0xf01069a4
f0100be6:	6a 58                	push   $0x58
f0100be8:	68 c3 78 10 f0       	push   $0xf01078c3
f0100bed:	e8 4e f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100bf2:	83 ec 04             	sub    $0x4,%esp
f0100bf5:	68 80 00 00 00       	push   $0x80
f0100bfa:	68 97 00 00 00       	push   $0x97
f0100bff:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c04:	50                   	push   %eax
f0100c05:	e8 d8 45 00 00       	call   f01051e2 <memset>
f0100c0a:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c0d:	8b 1b                	mov    (%ebx),%ebx
f0100c0f:	85 db                	test   %ebx,%ebx
f0100c11:	75 a9                	jne    f0100bbc <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c13:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c18:	e8 98 fe ff ff       	call   f0100ab5 <boot_alloc>
f0100c1d:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c20:	8b 15 40 12 2a f0    	mov    0xf02a1240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c26:	8b 0d a0 1e 2a f0    	mov    0xf02a1ea0,%ecx
		assert(pp < pages + npages);
f0100c2c:	a1 98 1e 2a f0       	mov    0xf02a1e98,%eax
f0100c31:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c34:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c37:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c3a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c3d:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c42:	e9 52 01 00 00       	jmp    f0100d99 <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c47:	39 ca                	cmp    %ecx,%edx
f0100c49:	73 19                	jae    f0100c64 <check_page_free_list+0x12b>
f0100c4b:	68 d1 78 10 f0       	push   $0xf01078d1
f0100c50:	68 dd 78 10 f0       	push   $0xf01078dd
f0100c55:	68 03 03 00 00       	push   $0x303
f0100c5a:	68 9d 78 10 f0       	push   $0xf010789d
f0100c5f:	e8 dc f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c64:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c67:	72 19                	jb     f0100c82 <check_page_free_list+0x149>
f0100c69:	68 f2 78 10 f0       	push   $0xf01078f2
f0100c6e:	68 dd 78 10 f0       	push   $0xf01078dd
f0100c73:	68 04 03 00 00       	push   $0x304
f0100c78:	68 9d 78 10 f0       	push   $0xf010789d
f0100c7d:	e8 be f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c82:	89 d0                	mov    %edx,%eax
f0100c84:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100c87:	a8 07                	test   $0x7,%al
f0100c89:	74 19                	je     f0100ca4 <check_page_free_list+0x16b>
f0100c8b:	68 f4 6e 10 f0       	push   $0xf0106ef4
f0100c90:	68 dd 78 10 f0       	push   $0xf01078dd
f0100c95:	68 05 03 00 00       	push   $0x305
f0100c9a:	68 9d 78 10 f0       	push   $0xf010789d
f0100c9f:	e8 9c f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ca4:	c1 f8 03             	sar    $0x3,%eax
f0100ca7:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100caa:	85 c0                	test   %eax,%eax
f0100cac:	75 19                	jne    f0100cc7 <check_page_free_list+0x18e>
f0100cae:	68 06 79 10 f0       	push   $0xf0107906
f0100cb3:	68 dd 78 10 f0       	push   $0xf01078dd
f0100cb8:	68 08 03 00 00       	push   $0x308
f0100cbd:	68 9d 78 10 f0       	push   $0xf010789d
f0100cc2:	e8 79 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cc7:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100ccc:	75 19                	jne    f0100ce7 <check_page_free_list+0x1ae>
f0100cce:	68 17 79 10 f0       	push   $0xf0107917
f0100cd3:	68 dd 78 10 f0       	push   $0xf01078dd
f0100cd8:	68 09 03 00 00       	push   $0x309
f0100cdd:	68 9d 78 10 f0       	push   $0xf010789d
f0100ce2:	e8 59 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ce7:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100cec:	75 19                	jne    f0100d07 <check_page_free_list+0x1ce>
f0100cee:	68 28 6f 10 f0       	push   $0xf0106f28
f0100cf3:	68 dd 78 10 f0       	push   $0xf01078dd
f0100cf8:	68 0a 03 00 00       	push   $0x30a
f0100cfd:	68 9d 78 10 f0       	push   $0xf010789d
f0100d02:	e8 39 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d07:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d0c:	75 19                	jne    f0100d27 <check_page_free_list+0x1ee>
f0100d0e:	68 30 79 10 f0       	push   $0xf0107930
f0100d13:	68 dd 78 10 f0       	push   $0xf01078dd
f0100d18:	68 0b 03 00 00       	push   $0x30b
f0100d1d:	68 9d 78 10 f0       	push   $0xf010789d
f0100d22:	e8 19 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d27:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d2c:	0f 86 de 00 00 00    	jbe    f0100e10 <check_page_free_list+0x2d7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d32:	89 c7                	mov    %eax,%edi
f0100d34:	c1 ef 0c             	shr    $0xc,%edi
f0100d37:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100d3a:	77 12                	ja     f0100d4e <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d3c:	50                   	push   %eax
f0100d3d:	68 a4 69 10 f0       	push   $0xf01069a4
f0100d42:	6a 58                	push   $0x58
f0100d44:	68 c3 78 10 f0       	push   $0xf01078c3
f0100d49:	e8 f2 f2 ff ff       	call   f0100040 <_panic>
f0100d4e:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100d54:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100d57:	0f 86 a7 00 00 00    	jbe    f0100e04 <check_page_free_list+0x2cb>
f0100d5d:	68 4c 6f 10 f0       	push   $0xf0106f4c
f0100d62:	68 dd 78 10 f0       	push   $0xf01078dd
f0100d67:	68 0c 03 00 00       	push   $0x30c
f0100d6c:	68 9d 78 10 f0       	push   $0xf010789d
f0100d71:	e8 ca f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d76:	68 4a 79 10 f0       	push   $0xf010794a
f0100d7b:	68 dd 78 10 f0       	push   $0xf01078dd
f0100d80:	68 0e 03 00 00       	push   $0x30e
f0100d85:	68 9d 78 10 f0       	push   $0xf010789d
f0100d8a:	e8 b1 f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100d8f:	83 c6 01             	add    $0x1,%esi
f0100d92:	eb 03                	jmp    f0100d97 <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100d94:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d97:	8b 12                	mov    (%edx),%edx
f0100d99:	85 d2                	test   %edx,%edx
f0100d9b:	0f 85 a6 fe ff ff    	jne    f0100c47 <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100da1:	85 f6                	test   %esi,%esi
f0100da3:	7f 19                	jg     f0100dbe <check_page_free_list+0x285>
f0100da5:	68 67 79 10 f0       	push   $0xf0107967
f0100daa:	68 dd 78 10 f0       	push   $0xf01078dd
f0100daf:	68 16 03 00 00       	push   $0x316
f0100db4:	68 9d 78 10 f0       	push   $0xf010789d
f0100db9:	e8 82 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100dbe:	85 db                	test   %ebx,%ebx
f0100dc0:	7f 5e                	jg     f0100e20 <check_page_free_list+0x2e7>
f0100dc2:	68 79 79 10 f0       	push   $0xf0107979
f0100dc7:	68 dd 78 10 f0       	push   $0xf01078dd
f0100dcc:	68 17 03 00 00       	push   $0x317
f0100dd1:	68 9d 78 10 f0       	push   $0xf010789d
f0100dd6:	e8 65 f2 ff ff       	call   f0100040 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100ddb:	a1 40 12 2a f0       	mov    0xf02a1240,%eax
f0100de0:	85 c0                	test   %eax,%eax
f0100de2:	0f 85 7e fd ff ff    	jne    f0100b66 <check_page_free_list+0x2d>
f0100de8:	e9 62 fd ff ff       	jmp    f0100b4f <check_page_free_list+0x16>
f0100ded:	83 3d 40 12 2a f0 00 	cmpl   $0x0,0xf02a1240
f0100df4:	0f 84 55 fd ff ff    	je     f0100b4f <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100dfa:	be 00 04 00 00       	mov    $0x400,%esi
f0100dff:	e9 b0 fd ff ff       	jmp    f0100bb4 <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e04:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e09:	75 89                	jne    f0100d94 <check_page_free_list+0x25b>
f0100e0b:	e9 66 ff ff ff       	jmp    f0100d76 <check_page_free_list+0x23d>
f0100e10:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e15:	0f 85 74 ff ff ff    	jne    f0100d8f <check_page_free_list+0x256>
f0100e1b:	e9 56 ff ff ff       	jmp    f0100d76 <check_page_free_list+0x23d>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100e20:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e23:	5b                   	pop    %ebx
f0100e24:	5e                   	pop    %esi
f0100e25:	5f                   	pop    %edi
f0100e26:	5d                   	pop    %ebp
f0100e27:	c3                   	ret    

f0100e28 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e28:	55                   	push   %ebp
f0100e29:	89 e5                	mov    %esp,%ebp
f0100e2b:	57                   	push   %edi
f0100e2c:	56                   	push   %esi
f0100e2d:	53                   	push   %ebx
f0100e2e:	83 ec 0c             	sub    $0xc,%esp
	//	pages[i].pp_ref = 0;
	//	pages[i].pp_link = page_free_list;
	//	page_free_list = &pages[i];
	//}
	//TODO: Check if it's needed to make pp_ref = 0, in the other pages
	pages[0].pp_ref = 0;
f0100e31:	a1 a0 1e 2a f0       	mov    0xf02a1ea0,%eax
f0100e36:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	pages[0].pp_link = NULL;
f0100e3c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	size_t n_mpentry = ROUNDDOWN(MPENTRY_PADDR, PGSIZE)/PGSIZE;
	size_t n_io_hole_start = npages_basemem;
f0100e42:	8b 1d 44 12 2a f0    	mov    0xf02a1244,%ebx
	char *first_free_page = (char *) boot_alloc(0);
f0100e48:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e4d:	e8 63 fc ff ff       	call   f0100ab5 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e52:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e57:	77 15                	ja     f0100e6e <page_init+0x46>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e59:	50                   	push   %eax
f0100e5a:	68 c8 69 10 f0       	push   $0xf01069c8
f0100e5f:	68 51 01 00 00       	push   $0x151
f0100e64:	68 9d 78 10 f0       	push   $0xf010789d
f0100e69:	e8 d2 f1 ff ff       	call   f0100040 <_panic>
	size_t first_free_page_number = PGNUM(PADDR(first_free_page));
f0100e6e:	05 00 00 00 10       	add    $0x10000000,%eax
f0100e73:	c1 e8 0c             	shr    $0xc,%eax
f0100e76:	8b 35 40 12 2a f0    	mov    0xf02a1240,%esi

	size_t i;
	for (i = 0; i < npages; i++) {
f0100e7c:	bf 00 00 00 00       	mov    $0x0,%edi
f0100e81:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e86:	eb 4f                	jmp    f0100ed7 <page_init+0xaf>
		if (i == 0 || i == n_mpentry || (n_io_hole_start <= i && i < first_free_page_number)) {
f0100e88:	85 d2                	test   %edx,%edx
f0100e8a:	74 0d                	je     f0100e99 <page_init+0x71>
f0100e8c:	83 fa 07             	cmp    $0x7,%edx
f0100e8f:	74 08                	je     f0100e99 <page_init+0x71>
f0100e91:	39 da                	cmp    %ebx,%edx
f0100e93:	72 1b                	jb     f0100eb0 <page_init+0x88>
f0100e95:	39 c2                	cmp    %eax,%edx
f0100e97:	73 17                	jae    f0100eb0 <page_init+0x88>
			pages[i].pp_ref = 0;
f0100e99:	8b 0d a0 1e 2a f0    	mov    0xf02a1ea0,%ecx
f0100e9f:	8d 0c d1             	lea    (%ecx,%edx,8),%ecx
f0100ea2:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
			pages[i].pp_link = NULL;
f0100ea8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f0100eae:	eb 24                	jmp    f0100ed4 <page_init+0xac>
f0100eb0:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
		} else {
			pages[i].pp_ref = 0;
f0100eb7:	89 cf                	mov    %ecx,%edi
f0100eb9:	03 3d a0 1e 2a f0    	add    0xf02a1ea0,%edi
f0100ebf:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
			pages[i].pp_link = page_free_list;
f0100ec5:	89 37                	mov    %esi,(%edi)
			page_free_list = &pages[i];
f0100ec7:	89 ce                	mov    %ecx,%esi
f0100ec9:	03 35 a0 1e 2a f0    	add    0xf02a1ea0,%esi
f0100ecf:	bf 01 00 00 00       	mov    $0x1,%edi
	size_t n_io_hole_start = npages_basemem;
	char *first_free_page = (char *) boot_alloc(0);
	size_t first_free_page_number = PGNUM(PADDR(first_free_page));

	size_t i;
	for (i = 0; i < npages; i++) {
f0100ed4:	83 c2 01             	add    $0x1,%edx
f0100ed7:	3b 15 98 1e 2a f0    	cmp    0xf02a1e98,%edx
f0100edd:	72 a9                	jb     f0100e88 <page_init+0x60>
f0100edf:	89 f8                	mov    %edi,%eax
f0100ee1:	84 c0                	test   %al,%al
f0100ee3:	74 06                	je     f0100eeb <page_init+0xc3>
f0100ee5:	89 35 40 12 2a f0    	mov    %esi,0xf02a1240
			pages[i].pp_ref = 0;
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}
	}
}
f0100eeb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100eee:	5b                   	pop    %ebx
f0100eef:	5e                   	pop    %esi
f0100ef0:	5f                   	pop    %edi
f0100ef1:	5d                   	pop    %ebp
f0100ef2:	c3                   	ret    

f0100ef3 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100ef3:	55                   	push   %ebp
f0100ef4:	89 e5                	mov    %esp,%ebp
f0100ef6:	53                   	push   %ebx
f0100ef7:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in

	// Test if it is out of memory
	if (!page_free_list)
f0100efa:	8b 1d 40 12 2a f0    	mov    0xf02a1240,%ebx
f0100f00:	85 db                	test   %ebx,%ebx
f0100f02:	74 58                	je     f0100f5c <page_alloc+0x69>
		return NULL;

	// If it is not, release one page
	struct PageInfo *allocated_page;
	allocated_page = page_free_list;
	page_free_list = page_free_list->pp_link;
f0100f04:	8b 03                	mov    (%ebx),%eax
f0100f06:	a3 40 12 2a f0       	mov    %eax,0xf02a1240
	allocated_page->pp_link = NULL;
f0100f0b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f0100f11:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f15:	74 45                	je     f0100f5c <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f17:	89 d8                	mov    %ebx,%eax
f0100f19:	2b 05 a0 1e 2a f0    	sub    0xf02a1ea0,%eax
f0100f1f:	c1 f8 03             	sar    $0x3,%eax
f0100f22:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f25:	89 c2                	mov    %eax,%edx
f0100f27:	c1 ea 0c             	shr    $0xc,%edx
f0100f2a:	3b 15 98 1e 2a f0    	cmp    0xf02a1e98,%edx
f0100f30:	72 12                	jb     f0100f44 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f32:	50                   	push   %eax
f0100f33:	68 a4 69 10 f0       	push   $0xf01069a4
f0100f38:	6a 58                	push   $0x58
f0100f3a:	68 c3 78 10 f0       	push   $0xf01078c3
f0100f3f:	e8 fc f0 ff ff       	call   f0100040 <_panic>
		memset(page2kva(allocated_page), '\0', PGSIZE);
f0100f44:	83 ec 04             	sub    $0x4,%esp
f0100f47:	68 00 10 00 00       	push   $0x1000
f0100f4c:	6a 00                	push   $0x0
f0100f4e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f53:	50                   	push   %eax
f0100f54:	e8 89 42 00 00       	call   f01051e2 <memset>
f0100f59:	83 c4 10             	add    $0x10,%esp
	}
	return allocated_page;
}
f0100f5c:	89 d8                	mov    %ebx,%eax
f0100f5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f61:	c9                   	leave  
f0100f62:	c3                   	ret    

f0100f63 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100f63:	55                   	push   %ebp
f0100f64:	89 e5                	mov    %esp,%ebp
f0100f66:	83 ec 08             	sub    $0x8,%esp
f0100f69:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0 || pp->pp_link != NULL) {
f0100f6c:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f71:	75 05                	jne    f0100f78 <page_free+0x15>
f0100f73:	83 38 00             	cmpl   $0x0,(%eax)
f0100f76:	74 17                	je     f0100f8f <page_free+0x2c>
		panic("page_free: pp->pp_ref is nonzero or pp->pp_link is not NULL.");
f0100f78:	83 ec 04             	sub    $0x4,%esp
f0100f7b:	68 94 6f 10 f0       	push   $0xf0106f94
f0100f80:	68 8b 01 00 00       	push   $0x18b
f0100f85:	68 9d 78 10 f0       	push   $0xf010789d
f0100f8a:	e8 b1 f0 ff ff       	call   f0100040 <_panic>
	}
	pp->pp_link = page_free_list;
f0100f8f:	8b 15 40 12 2a f0    	mov    0xf02a1240,%edx
f0100f95:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100f97:	a3 40 12 2a f0       	mov    %eax,0xf02a1240
}
f0100f9c:	c9                   	leave  
f0100f9d:	c3                   	ret    

f0100f9e <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100f9e:	55                   	push   %ebp
f0100f9f:	89 e5                	mov    %esp,%ebp
f0100fa1:	83 ec 08             	sub    $0x8,%esp
f0100fa4:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100fa7:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100fab:	83 e8 01             	sub    $0x1,%eax
f0100fae:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100fb2:	66 85 c0             	test   %ax,%ax
f0100fb5:	75 0c                	jne    f0100fc3 <page_decref+0x25>
		page_free(pp);
f0100fb7:	83 ec 0c             	sub    $0xc,%esp
f0100fba:	52                   	push   %edx
f0100fbb:	e8 a3 ff ff ff       	call   f0100f63 <page_free>
f0100fc0:	83 c4 10             	add    $0x10,%esp
}
f0100fc3:	c9                   	leave  
f0100fc4:	c3                   	ret    

f0100fc5 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100fc5:	55                   	push   %ebp
f0100fc6:	89 e5                	mov    %esp,%ebp
f0100fc8:	57                   	push   %edi
f0100fc9:	56                   	push   %esi
f0100fca:	53                   	push   %ebx
f0100fcb:	83 ec 1c             	sub    $0x1c,%esp
f0100fce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	uint32_t pgdir_index = PDX(va);
	uint32_t pgtable_index = PTX(va);
f0100fd1:	89 df                	mov    %ebx,%edi
f0100fd3:	c1 ef 0c             	shr    $0xc,%edi
f0100fd6:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
	pte_t *pgdir_entry = pgdir + pgdir_index;
f0100fdc:	c1 eb 16             	shr    $0x16,%ebx
f0100fdf:	c1 e3 02             	shl    $0x2,%ebx
f0100fe2:	03 5d 08             	add    0x8(%ebp),%ebx

	// If pgdir_entry is present
	if (*pgdir_entry & PTE_P) {
f0100fe5:	8b 03                	mov    (%ebx),%eax
f0100fe7:	a8 01                	test   $0x1,%al
f0100fe9:	74 33                	je     f010101e <pgdir_walk+0x59>
		physaddr_t pgtable_pa = (physaddr_t) (*pgdir_entry & 0xFFFFF000);
f0100feb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ff0:	89 c2                	mov    %eax,%edx
f0100ff2:	c1 ea 0c             	shr    $0xc,%edx
f0100ff5:	39 15 98 1e 2a f0    	cmp    %edx,0xf02a1e98
f0100ffb:	77 15                	ja     f0101012 <pgdir_walk+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ffd:	50                   	push   %eax
f0100ffe:	68 a4 69 10 f0       	push   $0xf01069a4
f0101003:	68 bd 01 00 00       	push   $0x1bd
f0101008:	68 9d 78 10 f0       	push   $0xf010789d
f010100d:	e8 2e f0 ff ff       	call   f0100040 <_panic>
		pte_t *pgtable = (pte_t *) KADDR(pgtable_pa);
		return pgtable + pgtable_index;
f0101012:	8d 84 b8 00 00 00 f0 	lea    -0x10000000(%eax,%edi,4),%eax
f0101019:	e9 89 00 00 00       	jmp    f01010a7 <pgdir_walk+0xe2>
	// If it is not present
	} else if (create) {
f010101e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101022:	74 77                	je     f010109b <pgdir_walk+0xd6>
		struct PageInfo *new_page = page_alloc(0);
f0101024:	83 ec 0c             	sub    $0xc,%esp
f0101027:	6a 00                	push   $0x0
f0101029:	e8 c5 fe ff ff       	call   f0100ef3 <page_alloc>
f010102e:	89 c6                	mov    %eax,%esi
		// If allocation works
		if (new_page) {
f0101030:	83 c4 10             	add    $0x10,%esp
f0101033:	85 c0                	test   %eax,%eax
f0101035:	74 6b                	je     f01010a2 <pgdir_walk+0xdd>
			// Set the page
			new_page->pp_ref += 1;
f0101037:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010103c:	2b 05 a0 1e 2a f0    	sub    0xf02a1ea0,%eax
f0101042:	c1 f8 03             	sar    $0x3,%eax
f0101045:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101048:	89 c2                	mov    %eax,%edx
f010104a:	c1 ea 0c             	shr    $0xc,%edx
f010104d:	3b 15 98 1e 2a f0    	cmp    0xf02a1e98,%edx
f0101053:	72 12                	jb     f0101067 <pgdir_walk+0xa2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101055:	50                   	push   %eax
f0101056:	68 a4 69 10 f0       	push   $0xf01069a4
f010105b:	6a 58                	push   $0x58
f010105d:	68 c3 78 10 f0       	push   $0xf01078c3
f0101062:	e8 d9 ef ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101067:	2d 00 00 00 10       	sub    $0x10000000,%eax
			pte_t *pgtable = page2kva(new_page);
			memset(pgtable, 0, PGSIZE);
f010106c:	83 ec 04             	sub    $0x4,%esp
f010106f:	68 00 10 00 00       	push   $0x1000
f0101074:	6a 00                	push   $0x0
f0101076:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101079:	50                   	push   %eax
f010107a:	e8 63 41 00 00       	call   f01051e2 <memset>
			// Set pgdir_entry
			physaddr_t pgtable_pa = page2pa(new_page);
			*pgdir_entry = (pgtable_pa | PTE_P | PTE_W | PTE_U);
f010107f:	2b 35 a0 1e 2a f0    	sub    0xf02a1ea0,%esi
f0101085:	c1 fe 03             	sar    $0x3,%esi
f0101088:	c1 e6 0c             	shl    $0xc,%esi
f010108b:	83 ce 07             	or     $0x7,%esi
f010108e:	89 33                	mov    %esi,(%ebx)
			// Return the virtual addres of the PTE
			return pgtable + pgtable_index;
f0101090:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101093:	8d 04 b8             	lea    (%eax,%edi,4),%eax
f0101096:	83 c4 10             	add    $0x10,%esp
f0101099:	eb 0c                	jmp    f01010a7 <pgdir_walk+0xe2>
		}
	}
	return NULL;
f010109b:	b8 00 00 00 00       	mov    $0x0,%eax
f01010a0:	eb 05                	jmp    f01010a7 <pgdir_walk+0xe2>
f01010a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01010a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010aa:	5b                   	pop    %ebx
f01010ab:	5e                   	pop    %esi
f01010ac:	5f                   	pop    %edi
f01010ad:	5d                   	pop    %ebp
f01010ae:	c3                   	ret    

f01010af <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01010af:	55                   	push   %ebp
f01010b0:	89 e5                	mov    %esp,%ebp
f01010b2:	57                   	push   %edi
f01010b3:	56                   	push   %esi
f01010b4:	53                   	push   %ebx
f01010b5:	83 ec 1c             	sub    $0x1c,%esp
f01010b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01010bb:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// TODO: Add panic for va an pa aligned
	if (size % PGSIZE != 0)
f01010be:	f7 c1 ff 0f 00 00    	test   $0xfff,%ecx
f01010c4:	74 17                	je     f01010dd <boot_map_region+0x2e>
		panic("boot_map_region: size is not multiple of PGSIZE");
f01010c6:	83 ec 04             	sub    $0x4,%esp
f01010c9:	68 d4 6f 10 f0       	push   $0xf0106fd4
f01010ce:	68 e3 01 00 00       	push   $0x1e3
f01010d3:	68 9d 78 10 f0       	push   $0xf010789d
f01010d8:	e8 63 ef ff ff       	call   f0100040 <_panic>
	uint32_t n = size/PGSIZE;
f01010dd:	c1 e9 0c             	shr    $0xc,%ecx
f01010e0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	uint32_t i;
	for (i = 0; i < n; i++) {
f01010e3:	89 c3                	mov    %eax,%ebx
f01010e5:	be 00 00 00 00       	mov    $0x0,%esi
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);
f01010ea:	89 d7                	mov    %edx,%edi
f01010ec:	29 c7                	sub    %eax,%edi
		if (!pte)
			panic("boot_map_region: could not allocate page table");
		uint32_t pa_without_offset = (pa & 0xFFFFF000);
		*pte = (pa_without_offset | perm | PTE_P);
f01010ee:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010f1:	83 c8 01             	or     $0x1,%eax
f01010f4:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// TODO: Add panic for va an pa aligned
	if (size % PGSIZE != 0)
		panic("boot_map_region: size is not multiple of PGSIZE");
	uint32_t n = size/PGSIZE;
	uint32_t i;
	for (i = 0; i < n; i++) {
f01010f7:	eb 45                	jmp    f010113e <boot_map_region+0x8f>
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);
f01010f9:	83 ec 04             	sub    $0x4,%esp
f01010fc:	6a 01                	push   $0x1
f01010fe:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0101101:	50                   	push   %eax
f0101102:	ff 75 e0             	pushl  -0x20(%ebp)
f0101105:	e8 bb fe ff ff       	call   f0100fc5 <pgdir_walk>
		if (!pte)
f010110a:	83 c4 10             	add    $0x10,%esp
f010110d:	85 c0                	test   %eax,%eax
f010110f:	75 17                	jne    f0101128 <boot_map_region+0x79>
			panic("boot_map_region: could not allocate page table");
f0101111:	83 ec 04             	sub    $0x4,%esp
f0101114:	68 04 70 10 f0       	push   $0xf0107004
f0101119:	68 e9 01 00 00       	push   $0x1e9
f010111e:	68 9d 78 10 f0       	push   $0xf010789d
f0101123:	e8 18 ef ff ff       	call   f0100040 <_panic>
		uint32_t pa_without_offset = (pa & 0xFFFFF000);
		*pte = (pa_without_offset | perm | PTE_P);
f0101128:	89 da                	mov    %ebx,%edx
f010112a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101130:	0b 55 dc             	or     -0x24(%ebp),%edx
f0101133:	89 10                	mov    %edx,(%eax)
		va += PGSIZE;
		pa += PGSIZE;
f0101135:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// TODO: Add panic for va an pa aligned
	if (size % PGSIZE != 0)
		panic("boot_map_region: size is not multiple of PGSIZE");
	uint32_t n = size/PGSIZE;
	uint32_t i;
	for (i = 0; i < n; i++) {
f010113b:	83 c6 01             	add    $0x1,%esi
f010113e:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0101141:	75 b6                	jne    f01010f9 <boot_map_region+0x4a>
		uint32_t pa_without_offset = (pa & 0xFFFFF000);
		*pte = (pa_without_offset | perm | PTE_P);
		va += PGSIZE;
		pa += PGSIZE;
	}
}
f0101143:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101146:	5b                   	pop    %ebx
f0101147:	5e                   	pop    %esi
f0101148:	5f                   	pop    %edi
f0101149:	5d                   	pop    %ebp
f010114a:	c3                   	ret    

f010114b <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010114b:	55                   	push   %ebp
f010114c:	89 e5                	mov    %esp,%ebp
f010114e:	53                   	push   %ebx
f010114f:	83 ec 08             	sub    $0x8,%esp
f0101152:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f0101155:	6a 00                	push   $0x0
f0101157:	ff 75 0c             	pushl  0xc(%ebp)
f010115a:	ff 75 08             	pushl  0x8(%ebp)
f010115d:	e8 63 fe ff ff       	call   f0100fc5 <pgdir_walk>
	if (!pte || !(*pte & PTE_P))
f0101162:	83 c4 10             	add    $0x10,%esp
f0101165:	85 c0                	test   %eax,%eax
f0101167:	74 3c                	je     f01011a5 <page_lookup+0x5a>
f0101169:	8b 10                	mov    (%eax),%edx
f010116b:	f6 c2 01             	test   $0x1,%dl
f010116e:	74 3c                	je     f01011ac <page_lookup+0x61>
		return NULL;
	physaddr_t page_pa = (*pte & 0xFFFFF000);
f0101170:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (pte_store)
f0101176:	85 db                	test   %ebx,%ebx
f0101178:	74 02                	je     f010117c <page_lookup+0x31>
		*pte_store = pte;
f010117a:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010117c:	c1 ea 0c             	shr    $0xc,%edx
f010117f:	3b 15 98 1e 2a f0    	cmp    0xf02a1e98,%edx
f0101185:	72 14                	jb     f010119b <page_lookup+0x50>
		panic("pa2page called with invalid pa");
f0101187:	83 ec 04             	sub    $0x4,%esp
f010118a:	68 34 70 10 f0       	push   $0xf0107034
f010118f:	6a 51                	push   $0x51
f0101191:	68 c3 78 10 f0       	push   $0xf01078c3
f0101196:	e8 a5 ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010119b:	a1 a0 1e 2a f0       	mov    0xf02a1ea0,%eax
f01011a0:	8d 04 d0             	lea    (%eax,%edx,8),%eax
	return pa2page(page_pa);
f01011a3:	eb 0c                	jmp    f01011b1 <page_lookup+0x66>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);
	if (!pte || !(*pte & PTE_P))
		return NULL;
f01011a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01011aa:	eb 05                	jmp    f01011b1 <page_lookup+0x66>
f01011ac:	b8 00 00 00 00       	mov    $0x0,%eax
	physaddr_t page_pa = (*pte & 0xFFFFF000);
	if (pte_store)
		*pte_store = pte;
	return pa2page(page_pa);
}
f01011b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01011b4:	c9                   	leave  
f01011b5:	c3                   	ret    

f01011b6 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01011b6:	55                   	push   %ebp
f01011b7:	89 e5                	mov    %esp,%ebp
f01011b9:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01011bc:	e8 41 46 00 00       	call   f0105802 <cpunum>
f01011c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01011c4:	83 b8 28 20 2a f0 00 	cmpl   $0x0,-0xfd5dfd8(%eax)
f01011cb:	74 16                	je     f01011e3 <tlb_invalidate+0x2d>
f01011cd:	e8 30 46 00 00       	call   f0105802 <cpunum>
f01011d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01011d5:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f01011db:	8b 55 08             	mov    0x8(%ebp),%edx
f01011de:	39 50 60             	cmp    %edx,0x60(%eax)
f01011e1:	75 06                	jne    f01011e9 <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01011e3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011e6:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01011e9:	c9                   	leave  
f01011ea:	c3                   	ret    

f01011eb <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01011eb:	55                   	push   %ebp
f01011ec:	89 e5                	mov    %esp,%ebp
f01011ee:	56                   	push   %esi
f01011ef:	53                   	push   %ebx
f01011f0:	83 ec 14             	sub    $0x14,%esp
f01011f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01011f6:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *pte;
	struct PageInfo *page = page_lookup(pgdir, va, &pte);
f01011f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01011fc:	50                   	push   %eax
f01011fd:	56                   	push   %esi
f01011fe:	53                   	push   %ebx
f01011ff:	e8 47 ff ff ff       	call   f010114b <page_lookup>
	if (page) {
f0101204:	83 c4 10             	add    $0x10,%esp
f0101207:	85 c0                	test   %eax,%eax
f0101209:	74 1f                	je     f010122a <page_remove+0x3f>
		page_decref(page);
f010120b:	83 ec 0c             	sub    $0xc,%esp
f010120e:	50                   	push   %eax
f010120f:	e8 8a fd ff ff       	call   f0100f9e <page_decref>
		*pte = 0;
f0101214:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101217:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, va); // How this works? Is va here ok?
f010121d:	83 c4 08             	add    $0x8,%esp
f0101220:	56                   	push   %esi
f0101221:	53                   	push   %ebx
f0101222:	e8 8f ff ff ff       	call   f01011b6 <tlb_invalidate>
f0101227:	83 c4 10             	add    $0x10,%esp
	}
}
f010122a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010122d:	5b                   	pop    %ebx
f010122e:	5e                   	pop    %esi
f010122f:	5d                   	pop    %ebp
f0101230:	c3                   	ret    

f0101231 <page_insert>:
//
// TODO: It should only be used on pages that are not free? (Allocated pages)
// So it can only be used on pages that were allocated.
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101231:	55                   	push   %ebp
f0101232:	89 e5                	mov    %esp,%ebp
f0101234:	57                   	push   %edi
f0101235:	56                   	push   %esi
f0101236:	53                   	push   %ebx
f0101237:	83 ec 20             	sub    $0x20,%esp
f010123a:	8b 75 08             	mov    0x8(%ebp),%esi
f010123d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101240:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	// TODO: Find a better solution...

	// Corner case
	pte_t *pte;
	if (page_lookup(pgdir, va, &pte) == pp) {
f0101243:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101246:	50                   	push   %eax
f0101247:	57                   	push   %edi
f0101248:	56                   	push   %esi
f0101249:	e8 fd fe ff ff       	call   f010114b <page_lookup>
f010124e:	83 c4 10             	add    $0x10,%esp
f0101251:	39 d8                	cmp    %ebx,%eax
f0101253:	75 20                	jne    f0101275 <page_insert+0x44>
		*pte = (page2pa(pp) | perm | PTE_P);
f0101255:	2b 05 a0 1e 2a f0    	sub    0xf02a1ea0,%eax
f010125b:	c1 f8 03             	sar    $0x3,%eax
f010125e:	c1 e0 0c             	shl    $0xc,%eax
f0101261:	8b 55 14             	mov    0x14(%ebp),%edx
f0101264:	83 ca 01             	or     $0x1,%edx
f0101267:	09 d0                	or     %edx,%eax
f0101269:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010126c:	89 02                	mov    %eax,(%edx)
		return 0;
f010126e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101273:	eb 44                	jmp    f01012b9 <page_insert+0x88>
	}

	// Normal case
	page_remove(pgdir, va);
f0101275:	83 ec 08             	sub    $0x8,%esp
f0101278:	57                   	push   %edi
f0101279:	56                   	push   %esi
f010127a:	e8 6c ff ff ff       	call   f01011eb <page_remove>
	pte = pgdir_walk(pgdir, va, 1);
f010127f:	83 c4 0c             	add    $0xc,%esp
f0101282:	6a 01                	push   $0x1
f0101284:	57                   	push   %edi
f0101285:	56                   	push   %esi
f0101286:	e8 3a fd ff ff       	call   f0100fc5 <pgdir_walk>
	if (!pte)
f010128b:	83 c4 10             	add    $0x10,%esp
f010128e:	85 c0                	test   %eax,%eax
f0101290:	74 22                	je     f01012b4 <page_insert+0x83>
		return -E_NO_MEM;
	pp->pp_ref += 1;
f0101292:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	*pte = (page2pa(pp) | perm | PTE_P);
f0101297:	2b 1d a0 1e 2a f0    	sub    0xf02a1ea0,%ebx
f010129d:	c1 fb 03             	sar    $0x3,%ebx
f01012a0:	c1 e3 0c             	shl    $0xc,%ebx
f01012a3:	8b 55 14             	mov    0x14(%ebp),%edx
f01012a6:	83 ca 01             	or     $0x1,%edx
f01012a9:	09 d3                	or     %edx,%ebx
f01012ab:	89 18                	mov    %ebx,(%eax)
	return 0;
f01012ad:	b8 00 00 00 00       	mov    $0x0,%eax
f01012b2:	eb 05                	jmp    f01012b9 <page_insert+0x88>

	// Normal case
	page_remove(pgdir, va);
	pte = pgdir_walk(pgdir, va, 1);
	if (!pte)
		return -E_NO_MEM;
f01012b4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	pp->pp_ref += 1;
	*pte = (page2pa(pp) | perm | PTE_P);
	return 0;
}
f01012b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012bc:	5b                   	pop    %ebx
f01012bd:	5e                   	pop    %esi
f01012be:	5f                   	pop    %edi
f01012bf:	5d                   	pop    %ebp
f01012c0:	c3                   	ret    

f01012c1 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01012c1:	55                   	push   %ebp
f01012c2:	89 e5                	mov    %esp,%ebp
f01012c4:	53                   	push   %ebx
f01012c5:	83 ec 04             	sub    $0x4,%esp
f01012c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size_t map_size = ROUNDUP(size, PGSIZE);
f01012cb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012ce:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01012d4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (base + map_size > MMIOLIM) {
f01012da:	a1 00 33 12 f0       	mov    0xf0123300,%eax
f01012df:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f01012e2:	81 fa 00 00 c0 ef    	cmp    $0xefc00000,%edx
f01012e8:	76 17                	jbe    f0101301 <mmio_map_region+0x40>
		panic("mmio_map_region: overflow on MMIO map region");
f01012ea:	83 ec 04             	sub    $0x4,%esp
f01012ed:	68 54 70 10 f0       	push   $0xf0107054
f01012f2:	68 84 02 00 00       	push   $0x284
f01012f7:	68 9d 78 10 f0       	push   $0xf010789d
f01012fc:	e8 3f ed ff ff       	call   f0100040 <_panic>
	}
	uintptr_t va = base + PGOFF(pa);

	// Map region. va and pa page aligned. map_size multiple of size.
	boot_map_region(kern_pgdir, va, map_size, pa, PTE_W | PTE_PCD | PTE_PWT);
f0101301:	89 ca                	mov    %ecx,%edx
f0101303:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f0101309:	01 c2                	add    %eax,%edx
f010130b:	83 ec 08             	sub    $0x8,%esp
f010130e:	6a 1a                	push   $0x1a
f0101310:	51                   	push   %ecx
f0101311:	89 d9                	mov    %ebx,%ecx
f0101313:	a1 9c 1e 2a f0       	mov    0xf02a1e9c,%eax
f0101318:	e8 92 fd ff ff       	call   f01010af <boot_map_region>

	// Update base
	base += map_size;
f010131d:	a1 00 33 12 f0       	mov    0xf0123300,%eax
f0101322:	01 c3                	add    %eax,%ebx
f0101324:	89 1d 00 33 12 f0    	mov    %ebx,0xf0123300

	// Return base of mapped region
	return (void *) (base - map_size);
}
f010132a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010132d:	c9                   	leave  
f010132e:	c3                   	ret    

f010132f <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010132f:	55                   	push   %ebp
f0101330:	89 e5                	mov    %esp,%ebp
f0101332:	57                   	push   %edi
f0101333:	56                   	push   %esi
f0101334:	53                   	push   %ebx
f0101335:	83 ec 48             	sub    $0x48,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101338:	6a 15                	push   $0x15
f010133a:	e8 8c 21 00 00       	call   f01034cb <mc146818_read>
f010133f:	89 c3                	mov    %eax,%ebx
f0101341:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101348:	e8 7e 21 00 00       	call   f01034cb <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010134d:	c1 e0 08             	shl    $0x8,%eax
f0101350:	09 d8                	or     %ebx,%eax
f0101352:	c1 e0 0a             	shl    $0xa,%eax
f0101355:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010135b:	85 c0                	test   %eax,%eax
f010135d:	0f 48 c2             	cmovs  %edx,%eax
f0101360:	c1 f8 0c             	sar    $0xc,%eax
f0101363:	a3 44 12 2a f0       	mov    %eax,0xf02a1244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101368:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f010136f:	e8 57 21 00 00       	call   f01034cb <mc146818_read>
f0101374:	89 c3                	mov    %eax,%ebx
f0101376:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f010137d:	e8 49 21 00 00       	call   f01034cb <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101382:	c1 e0 08             	shl    $0x8,%eax
f0101385:	09 d8                	or     %ebx,%eax
f0101387:	c1 e0 0a             	shl    $0xa,%eax
f010138a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101390:	83 c4 10             	add    $0x10,%esp
f0101393:	85 c0                	test   %eax,%eax
f0101395:	0f 48 c2             	cmovs  %edx,%eax
f0101398:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010139b:	85 c0                	test   %eax,%eax
f010139d:	74 0e                	je     f01013ad <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010139f:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01013a5:	89 15 98 1e 2a f0    	mov    %edx,0xf02a1e98
f01013ab:	eb 0c                	jmp    f01013b9 <mem_init+0x8a>
	else
		npages = npages_basemem;
f01013ad:	8b 15 44 12 2a f0    	mov    0xf02a1244,%edx
f01013b3:	89 15 98 1e 2a f0    	mov    %edx,0xf02a1e98

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013b9:	c1 e0 0c             	shl    $0xc,%eax
f01013bc:	c1 e8 0a             	shr    $0xa,%eax
f01013bf:	50                   	push   %eax
f01013c0:	a1 44 12 2a f0       	mov    0xf02a1244,%eax
f01013c5:	c1 e0 0c             	shl    $0xc,%eax
f01013c8:	c1 e8 0a             	shr    $0xa,%eax
f01013cb:	50                   	push   %eax
f01013cc:	a1 98 1e 2a f0       	mov    0xf02a1e98,%eax
f01013d1:	c1 e0 0c             	shl    $0xc,%eax
f01013d4:	c1 e8 0a             	shr    $0xa,%eax
f01013d7:	50                   	push   %eax
f01013d8:	68 84 70 10 f0       	push   $0xf0107084
f01013dd:	e8 7e 22 00 00       	call   f0103660 <cprintf>
	// Remove this line when you're ready to test this function.
//	panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01013e2:	b8 00 10 00 00       	mov    $0x1000,%eax
f01013e7:	e8 c9 f6 ff ff       	call   f0100ab5 <boot_alloc>
f01013ec:	a3 9c 1e 2a f0       	mov    %eax,0xf02a1e9c
	memset(kern_pgdir, 0, PGSIZE);
f01013f1:	83 c4 0c             	add    $0xc,%esp
f01013f4:	68 00 10 00 00       	push   $0x1000
f01013f9:	6a 00                	push   $0x0
f01013fb:	50                   	push   %eax
f01013fc:	e8 e1 3d 00 00       	call   f01051e2 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101401:	a1 9c 1e 2a f0       	mov    0xf02a1e9c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101406:	83 c4 10             	add    $0x10,%esp
f0101409:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010140e:	77 15                	ja     f0101425 <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101410:	50                   	push   %eax
f0101411:	68 c8 69 10 f0       	push   $0xf01069c8
f0101416:	68 93 00 00 00       	push   $0x93
f010141b:	68 9d 78 10 f0       	push   $0xf010789d
f0101420:	e8 1b ec ff ff       	call   f0100040 <_panic>
f0101425:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010142b:	83 ca 05             	or     $0x5,%edx
f010142e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101434:	a1 98 1e 2a f0       	mov    0xf02a1e98,%eax
f0101439:	c1 e0 03             	shl    $0x3,%eax
f010143c:	e8 74 f6 ff ff       	call   f0100ab5 <boot_alloc>
f0101441:	a3 a0 1e 2a f0       	mov    %eax,0xf02a1ea0
	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101446:	83 ec 04             	sub    $0x4,%esp
f0101449:	8b 0d 98 1e 2a f0    	mov    0xf02a1e98,%ecx
f010144f:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101456:	52                   	push   %edx
f0101457:	6a 00                	push   $0x0
f0101459:	50                   	push   %eax
f010145a:	e8 83 3d 00 00       	call   f01051e2 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f010145f:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101464:	e8 4c f6 ff ff       	call   f0100ab5 <boot_alloc>
f0101469:	a3 48 12 2a f0       	mov    %eax,0xf02a1248
	memset(envs, 0, NENV * sizeof(struct Env));
f010146e:	83 c4 0c             	add    $0xc,%esp
f0101471:	68 00 f0 01 00       	push   $0x1f000
f0101476:	6a 00                	push   $0x0
f0101478:	50                   	push   %eax
f0101479:	e8 64 3d 00 00       	call   f01051e2 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010147e:	e8 a5 f9 ff ff       	call   f0100e28 <page_init>

	check_page_free_list(1);
f0101483:	b8 01 00 00 00       	mov    $0x1,%eax
f0101488:	e8 ac f6 ff ff       	call   f0100b39 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010148d:	83 c4 10             	add    $0x10,%esp
f0101490:	83 3d a0 1e 2a f0 00 	cmpl   $0x0,0xf02a1ea0
f0101497:	75 17                	jne    f01014b0 <mem_init+0x181>
		panic("'pages' is a null pointer!");
f0101499:	83 ec 04             	sub    $0x4,%esp
f010149c:	68 8a 79 10 f0       	push   $0xf010798a
f01014a1:	68 28 03 00 00       	push   $0x328
f01014a6:	68 9d 78 10 f0       	push   $0xf010789d
f01014ab:	e8 90 eb ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014b0:	a1 40 12 2a f0       	mov    0xf02a1240,%eax
f01014b5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01014ba:	eb 05                	jmp    f01014c1 <mem_init+0x192>
		++nfree;
f01014bc:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014bf:	8b 00                	mov    (%eax),%eax
f01014c1:	85 c0                	test   %eax,%eax
f01014c3:	75 f7                	jne    f01014bc <mem_init+0x18d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014c5:	83 ec 0c             	sub    $0xc,%esp
f01014c8:	6a 00                	push   $0x0
f01014ca:	e8 24 fa ff ff       	call   f0100ef3 <page_alloc>
f01014cf:	89 c7                	mov    %eax,%edi
f01014d1:	83 c4 10             	add    $0x10,%esp
f01014d4:	85 c0                	test   %eax,%eax
f01014d6:	75 19                	jne    f01014f1 <mem_init+0x1c2>
f01014d8:	68 a5 79 10 f0       	push   $0xf01079a5
f01014dd:	68 dd 78 10 f0       	push   $0xf01078dd
f01014e2:	68 30 03 00 00       	push   $0x330
f01014e7:	68 9d 78 10 f0       	push   $0xf010789d
f01014ec:	e8 4f eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01014f1:	83 ec 0c             	sub    $0xc,%esp
f01014f4:	6a 00                	push   $0x0
f01014f6:	e8 f8 f9 ff ff       	call   f0100ef3 <page_alloc>
f01014fb:	89 c6                	mov    %eax,%esi
f01014fd:	83 c4 10             	add    $0x10,%esp
f0101500:	85 c0                	test   %eax,%eax
f0101502:	75 19                	jne    f010151d <mem_init+0x1ee>
f0101504:	68 bb 79 10 f0       	push   $0xf01079bb
f0101509:	68 dd 78 10 f0       	push   $0xf01078dd
f010150e:	68 31 03 00 00       	push   $0x331
f0101513:	68 9d 78 10 f0       	push   $0xf010789d
f0101518:	e8 23 eb ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010151d:	83 ec 0c             	sub    $0xc,%esp
f0101520:	6a 00                	push   $0x0
f0101522:	e8 cc f9 ff ff       	call   f0100ef3 <page_alloc>
f0101527:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010152a:	83 c4 10             	add    $0x10,%esp
f010152d:	85 c0                	test   %eax,%eax
f010152f:	75 19                	jne    f010154a <mem_init+0x21b>
f0101531:	68 d1 79 10 f0       	push   $0xf01079d1
f0101536:	68 dd 78 10 f0       	push   $0xf01078dd
f010153b:	68 32 03 00 00       	push   $0x332
f0101540:	68 9d 78 10 f0       	push   $0xf010789d
f0101545:	e8 f6 ea ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010154a:	39 f7                	cmp    %esi,%edi
f010154c:	75 19                	jne    f0101567 <mem_init+0x238>
f010154e:	68 e7 79 10 f0       	push   $0xf01079e7
f0101553:	68 dd 78 10 f0       	push   $0xf01078dd
f0101558:	68 35 03 00 00       	push   $0x335
f010155d:	68 9d 78 10 f0       	push   $0xf010789d
f0101562:	e8 d9 ea ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101567:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010156a:	39 c6                	cmp    %eax,%esi
f010156c:	74 04                	je     f0101572 <mem_init+0x243>
f010156e:	39 c7                	cmp    %eax,%edi
f0101570:	75 19                	jne    f010158b <mem_init+0x25c>
f0101572:	68 c0 70 10 f0       	push   $0xf01070c0
f0101577:	68 dd 78 10 f0       	push   $0xf01078dd
f010157c:	68 36 03 00 00       	push   $0x336
f0101581:	68 9d 78 10 f0       	push   $0xf010789d
f0101586:	e8 b5 ea ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010158b:	8b 0d a0 1e 2a f0    	mov    0xf02a1ea0,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101591:	8b 15 98 1e 2a f0    	mov    0xf02a1e98,%edx
f0101597:	c1 e2 0c             	shl    $0xc,%edx
f010159a:	89 f8                	mov    %edi,%eax
f010159c:	29 c8                	sub    %ecx,%eax
f010159e:	c1 f8 03             	sar    $0x3,%eax
f01015a1:	c1 e0 0c             	shl    $0xc,%eax
f01015a4:	39 d0                	cmp    %edx,%eax
f01015a6:	72 19                	jb     f01015c1 <mem_init+0x292>
f01015a8:	68 f9 79 10 f0       	push   $0xf01079f9
f01015ad:	68 dd 78 10 f0       	push   $0xf01078dd
f01015b2:	68 37 03 00 00       	push   $0x337
f01015b7:	68 9d 78 10 f0       	push   $0xf010789d
f01015bc:	e8 7f ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01015c1:	89 f0                	mov    %esi,%eax
f01015c3:	29 c8                	sub    %ecx,%eax
f01015c5:	c1 f8 03             	sar    $0x3,%eax
f01015c8:	c1 e0 0c             	shl    $0xc,%eax
f01015cb:	39 c2                	cmp    %eax,%edx
f01015cd:	77 19                	ja     f01015e8 <mem_init+0x2b9>
f01015cf:	68 16 7a 10 f0       	push   $0xf0107a16
f01015d4:	68 dd 78 10 f0       	push   $0xf01078dd
f01015d9:	68 38 03 00 00       	push   $0x338
f01015de:	68 9d 78 10 f0       	push   $0xf010789d
f01015e3:	e8 58 ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01015e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015eb:	29 c8                	sub    %ecx,%eax
f01015ed:	c1 f8 03             	sar    $0x3,%eax
f01015f0:	c1 e0 0c             	shl    $0xc,%eax
f01015f3:	39 c2                	cmp    %eax,%edx
f01015f5:	77 19                	ja     f0101610 <mem_init+0x2e1>
f01015f7:	68 33 7a 10 f0       	push   $0xf0107a33
f01015fc:	68 dd 78 10 f0       	push   $0xf01078dd
f0101601:	68 39 03 00 00       	push   $0x339
f0101606:	68 9d 78 10 f0       	push   $0xf010789d
f010160b:	e8 30 ea ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101610:	a1 40 12 2a f0       	mov    0xf02a1240,%eax
f0101615:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101618:	c7 05 40 12 2a f0 00 	movl   $0x0,0xf02a1240
f010161f:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101622:	83 ec 0c             	sub    $0xc,%esp
f0101625:	6a 00                	push   $0x0
f0101627:	e8 c7 f8 ff ff       	call   f0100ef3 <page_alloc>
f010162c:	83 c4 10             	add    $0x10,%esp
f010162f:	85 c0                	test   %eax,%eax
f0101631:	74 19                	je     f010164c <mem_init+0x31d>
f0101633:	68 50 7a 10 f0       	push   $0xf0107a50
f0101638:	68 dd 78 10 f0       	push   $0xf01078dd
f010163d:	68 40 03 00 00       	push   $0x340
f0101642:	68 9d 78 10 f0       	push   $0xf010789d
f0101647:	e8 f4 e9 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010164c:	83 ec 0c             	sub    $0xc,%esp
f010164f:	57                   	push   %edi
f0101650:	e8 0e f9 ff ff       	call   f0100f63 <page_free>
	page_free(pp1);
f0101655:	89 34 24             	mov    %esi,(%esp)
f0101658:	e8 06 f9 ff ff       	call   f0100f63 <page_free>
	page_free(pp2);
f010165d:	83 c4 04             	add    $0x4,%esp
f0101660:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101663:	e8 fb f8 ff ff       	call   f0100f63 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101668:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010166f:	e8 7f f8 ff ff       	call   f0100ef3 <page_alloc>
f0101674:	89 c6                	mov    %eax,%esi
f0101676:	83 c4 10             	add    $0x10,%esp
f0101679:	85 c0                	test   %eax,%eax
f010167b:	75 19                	jne    f0101696 <mem_init+0x367>
f010167d:	68 a5 79 10 f0       	push   $0xf01079a5
f0101682:	68 dd 78 10 f0       	push   $0xf01078dd
f0101687:	68 47 03 00 00       	push   $0x347
f010168c:	68 9d 78 10 f0       	push   $0xf010789d
f0101691:	e8 aa e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101696:	83 ec 0c             	sub    $0xc,%esp
f0101699:	6a 00                	push   $0x0
f010169b:	e8 53 f8 ff ff       	call   f0100ef3 <page_alloc>
f01016a0:	89 c7                	mov    %eax,%edi
f01016a2:	83 c4 10             	add    $0x10,%esp
f01016a5:	85 c0                	test   %eax,%eax
f01016a7:	75 19                	jne    f01016c2 <mem_init+0x393>
f01016a9:	68 bb 79 10 f0       	push   $0xf01079bb
f01016ae:	68 dd 78 10 f0       	push   $0xf01078dd
f01016b3:	68 48 03 00 00       	push   $0x348
f01016b8:	68 9d 78 10 f0       	push   $0xf010789d
f01016bd:	e8 7e e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01016c2:	83 ec 0c             	sub    $0xc,%esp
f01016c5:	6a 00                	push   $0x0
f01016c7:	e8 27 f8 ff ff       	call   f0100ef3 <page_alloc>
f01016cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01016cf:	83 c4 10             	add    $0x10,%esp
f01016d2:	85 c0                	test   %eax,%eax
f01016d4:	75 19                	jne    f01016ef <mem_init+0x3c0>
f01016d6:	68 d1 79 10 f0       	push   $0xf01079d1
f01016db:	68 dd 78 10 f0       	push   $0xf01078dd
f01016e0:	68 49 03 00 00       	push   $0x349
f01016e5:	68 9d 78 10 f0       	push   $0xf010789d
f01016ea:	e8 51 e9 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01016ef:	39 fe                	cmp    %edi,%esi
f01016f1:	75 19                	jne    f010170c <mem_init+0x3dd>
f01016f3:	68 e7 79 10 f0       	push   $0xf01079e7
f01016f8:	68 dd 78 10 f0       	push   $0xf01078dd
f01016fd:	68 4b 03 00 00       	push   $0x34b
f0101702:	68 9d 78 10 f0       	push   $0xf010789d
f0101707:	e8 34 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010170c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010170f:	39 c7                	cmp    %eax,%edi
f0101711:	74 04                	je     f0101717 <mem_init+0x3e8>
f0101713:	39 c6                	cmp    %eax,%esi
f0101715:	75 19                	jne    f0101730 <mem_init+0x401>
f0101717:	68 c0 70 10 f0       	push   $0xf01070c0
f010171c:	68 dd 78 10 f0       	push   $0xf01078dd
f0101721:	68 4c 03 00 00       	push   $0x34c
f0101726:	68 9d 78 10 f0       	push   $0xf010789d
f010172b:	e8 10 e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101730:	83 ec 0c             	sub    $0xc,%esp
f0101733:	6a 00                	push   $0x0
f0101735:	e8 b9 f7 ff ff       	call   f0100ef3 <page_alloc>
f010173a:	83 c4 10             	add    $0x10,%esp
f010173d:	85 c0                	test   %eax,%eax
f010173f:	74 19                	je     f010175a <mem_init+0x42b>
f0101741:	68 50 7a 10 f0       	push   $0xf0107a50
f0101746:	68 dd 78 10 f0       	push   $0xf01078dd
f010174b:	68 4d 03 00 00       	push   $0x34d
f0101750:	68 9d 78 10 f0       	push   $0xf010789d
f0101755:	e8 e6 e8 ff ff       	call   f0100040 <_panic>
f010175a:	89 f0                	mov    %esi,%eax
f010175c:	2b 05 a0 1e 2a f0    	sub    0xf02a1ea0,%eax
f0101762:	c1 f8 03             	sar    $0x3,%eax
f0101765:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101768:	89 c2                	mov    %eax,%edx
f010176a:	c1 ea 0c             	shr    $0xc,%edx
f010176d:	3b 15 98 1e 2a f0    	cmp    0xf02a1e98,%edx
f0101773:	72 12                	jb     f0101787 <mem_init+0x458>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101775:	50                   	push   %eax
f0101776:	68 a4 69 10 f0       	push   $0xf01069a4
f010177b:	6a 58                	push   $0x58
f010177d:	68 c3 78 10 f0       	push   $0xf01078c3
f0101782:	e8 b9 e8 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101787:	83 ec 04             	sub    $0x4,%esp
f010178a:	68 00 10 00 00       	push   $0x1000
f010178f:	6a 01                	push   $0x1
f0101791:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101796:	50                   	push   %eax
f0101797:	e8 46 3a 00 00       	call   f01051e2 <memset>
	page_free(pp0);
f010179c:	89 34 24             	mov    %esi,(%esp)
f010179f:	e8 bf f7 ff ff       	call   f0100f63 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01017a4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01017ab:	e8 43 f7 ff ff       	call   f0100ef3 <page_alloc>
f01017b0:	83 c4 10             	add    $0x10,%esp
f01017b3:	85 c0                	test   %eax,%eax
f01017b5:	75 19                	jne    f01017d0 <mem_init+0x4a1>
f01017b7:	68 5f 7a 10 f0       	push   $0xf0107a5f
f01017bc:	68 dd 78 10 f0       	push   $0xf01078dd
f01017c1:	68 52 03 00 00       	push   $0x352
f01017c6:	68 9d 78 10 f0       	push   $0xf010789d
f01017cb:	e8 70 e8 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01017d0:	39 c6                	cmp    %eax,%esi
f01017d2:	74 19                	je     f01017ed <mem_init+0x4be>
f01017d4:	68 7d 7a 10 f0       	push   $0xf0107a7d
f01017d9:	68 dd 78 10 f0       	push   $0xf01078dd
f01017de:	68 53 03 00 00       	push   $0x353
f01017e3:	68 9d 78 10 f0       	push   $0xf010789d
f01017e8:	e8 53 e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017ed:	89 f0                	mov    %esi,%eax
f01017ef:	2b 05 a0 1e 2a f0    	sub    0xf02a1ea0,%eax
f01017f5:	c1 f8 03             	sar    $0x3,%eax
f01017f8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017fb:	89 c2                	mov    %eax,%edx
f01017fd:	c1 ea 0c             	shr    $0xc,%edx
f0101800:	3b 15 98 1e 2a f0    	cmp    0xf02a1e98,%edx
f0101806:	72 12                	jb     f010181a <mem_init+0x4eb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101808:	50                   	push   %eax
f0101809:	68 a4 69 10 f0       	push   $0xf01069a4
f010180e:	6a 58                	push   $0x58
f0101810:	68 c3 78 10 f0       	push   $0xf01078c3
f0101815:	e8 26 e8 ff ff       	call   f0100040 <_panic>
f010181a:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101820:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101826:	80 38 00             	cmpb   $0x0,(%eax)
f0101829:	74 19                	je     f0101844 <mem_init+0x515>
f010182b:	68 8d 7a 10 f0       	push   $0xf0107a8d
f0101830:	68 dd 78 10 f0       	push   $0xf01078dd
f0101835:	68 56 03 00 00       	push   $0x356
f010183a:	68 9d 78 10 f0       	push   $0xf010789d
f010183f:	e8 fc e7 ff ff       	call   f0100040 <_panic>
f0101844:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101847:	39 d0                	cmp    %edx,%eax
f0101849:	75 db                	jne    f0101826 <mem_init+0x4f7>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f010184b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010184e:	a3 40 12 2a f0       	mov    %eax,0xf02a1240

	// free the pages we took
	page_free(pp0);
f0101853:	83 ec 0c             	sub    $0xc,%esp
f0101856:	56                   	push   %esi
f0101857:	e8 07 f7 ff ff       	call   f0100f63 <page_free>
	page_free(pp1);
f010185c:	89 3c 24             	mov    %edi,(%esp)
f010185f:	e8 ff f6 ff ff       	call   f0100f63 <page_free>
	page_free(pp2);
f0101864:	83 c4 04             	add    $0x4,%esp
f0101867:	ff 75 d4             	pushl  -0x2c(%ebp)
f010186a:	e8 f4 f6 ff ff       	call   f0100f63 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010186f:	a1 40 12 2a f0       	mov    0xf02a1240,%eax
f0101874:	83 c4 10             	add    $0x10,%esp
f0101877:	eb 05                	jmp    f010187e <mem_init+0x54f>
		--nfree;
f0101879:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010187c:	8b 00                	mov    (%eax),%eax
f010187e:	85 c0                	test   %eax,%eax
f0101880:	75 f7                	jne    f0101879 <mem_init+0x54a>
		--nfree;
	assert(nfree == 0);
f0101882:	85 db                	test   %ebx,%ebx
f0101884:	74 19                	je     f010189f <mem_init+0x570>
f0101886:	68 97 7a 10 f0       	push   $0xf0107a97
f010188b:	68 dd 78 10 f0       	push   $0xf01078dd
f0101890:	68 63 03 00 00       	push   $0x363
f0101895:	68 9d 78 10 f0       	push   $0xf010789d
f010189a:	e8 a1 e7 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010189f:	83 ec 0c             	sub    $0xc,%esp
f01018a2:	68 e0 70 10 f0       	push   $0xf01070e0
f01018a7:	e8 b4 1d 00 00       	call   f0103660 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01018ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018b3:	e8 3b f6 ff ff       	call   f0100ef3 <page_alloc>
f01018b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018bb:	83 c4 10             	add    $0x10,%esp
f01018be:	85 c0                	test   %eax,%eax
f01018c0:	75 19                	jne    f01018db <mem_init+0x5ac>
f01018c2:	68 a5 79 10 f0       	push   $0xf01079a5
f01018c7:	68 dd 78 10 f0       	push   $0xf01078dd
f01018cc:	68 c9 03 00 00       	push   $0x3c9
f01018d1:	68 9d 78 10 f0       	push   $0xf010789d
f01018d6:	e8 65 e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01018db:	83 ec 0c             	sub    $0xc,%esp
f01018de:	6a 00                	push   $0x0
f01018e0:	e8 0e f6 ff ff       	call   f0100ef3 <page_alloc>
f01018e5:	89 c3                	mov    %eax,%ebx
f01018e7:	83 c4 10             	add    $0x10,%esp
f01018ea:	85 c0                	test   %eax,%eax
f01018ec:	75 19                	jne    f0101907 <mem_init+0x5d8>
f01018ee:	68 bb 79 10 f0       	push   $0xf01079bb
f01018f3:	68 dd 78 10 f0       	push   $0xf01078dd
f01018f8:	68 ca 03 00 00       	push   $0x3ca
f01018fd:	68 9d 78 10 f0       	push   $0xf010789d
f0101902:	e8 39 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101907:	83 ec 0c             	sub    $0xc,%esp
f010190a:	6a 00                	push   $0x0
f010190c:	e8 e2 f5 ff ff       	call   f0100ef3 <page_alloc>
f0101911:	89 c6                	mov    %eax,%esi
f0101913:	83 c4 10             	add    $0x10,%esp
f0101916:	85 c0                	test   %eax,%eax
f0101918:	75 19                	jne    f0101933 <mem_init+0x604>
f010191a:	68 d1 79 10 f0       	push   $0xf01079d1
f010191f:	68 dd 78 10 f0       	push   $0xf01078dd
f0101924:	68 cb 03 00 00       	push   $0x3cb
f0101929:	68 9d 78 10 f0       	push   $0xf010789d
f010192e:	e8 0d e7 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101933:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101936:	75 19                	jne    f0101951 <mem_init+0x622>
f0101938:	68 e7 79 10 f0       	push   $0xf01079e7
f010193d:	68 dd 78 10 f0       	push   $0xf01078dd
f0101942:	68 ce 03 00 00       	push   $0x3ce
f0101947:	68 9d 78 10 f0       	push   $0xf010789d
f010194c:	e8 ef e6 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101951:	39 c3                	cmp    %eax,%ebx
f0101953:	74 05                	je     f010195a <mem_init+0x62b>
f0101955:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101958:	75 19                	jne    f0101973 <mem_init+0x644>
f010195a:	68 c0 70 10 f0       	push   $0xf01070c0
f010195f:	68 dd 78 10 f0       	push   $0xf01078dd
f0101964:	68 cf 03 00 00       	push   $0x3cf
f0101969:	68 9d 78 10 f0       	push   $0xf010789d
f010196e:	e8 cd e6 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101973:	a1 40 12 2a f0       	mov    0xf02a1240,%eax
f0101978:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010197b:	c7 05 40 12 2a f0 00 	movl   $0x0,0xf02a1240
f0101982:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101985:	83 ec 0c             	sub    $0xc,%esp
f0101988:	6a 00                	push   $0x0
f010198a:	e8 64 f5 ff ff       	call   f0100ef3 <page_alloc>
f010198f:	83 c4 10             	add    $0x10,%esp
f0101992:	85 c0                	test   %eax,%eax
f0101994:	74 19                	je     f01019af <mem_init+0x680>
f0101996:	68 50 7a 10 f0       	push   $0xf0107a50
f010199b:	68 dd 78 10 f0       	push   $0xf01078dd
f01019a0:	68 d6 03 00 00       	push   $0x3d6
f01019a5:	68 9d 78 10 f0       	push   $0xf010789d
f01019aa:	e8 91 e6 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01019af:	83 ec 04             	sub    $0x4,%esp
f01019b2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01019b5:	50                   	push   %eax
f01019b6:	6a 00                	push   $0x0
f01019b8:	ff 35 9c 1e 2a f0    	pushl  0xf02a1e9c
f01019be:	e8 88 f7 ff ff       	call   f010114b <page_lookup>
f01019c3:	83 c4 10             	add    $0x10,%esp
f01019c6:	85 c0                	test   %eax,%eax
f01019c8:	74 19                	je     f01019e3 <mem_init+0x6b4>
f01019ca:	68 00 71 10 f0       	push   $0xf0107100
f01019cf:	68 dd 78 10 f0       	push   $0xf01078dd
f01019d4:	68 d9 03 00 00       	push   $0x3d9
f01019d9:	68 9d 78 10 f0       	push   $0xf010789d
f01019de:	e8 5d e6 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01019e3:	6a 02                	push   $0x2
f01019e5:	6a 00                	push   $0x0
f01019e7:	53                   	push   %ebx
f01019e8:	ff 35 9c 1e 2a f0    	pushl  0xf02a1e9c
f01019ee:	e8 3e f8 ff ff       	call   f0101231 <page_insert>
f01019f3:	83 c4 10             	add    $0x10,%esp
f01019f6:	85 c0                	test   %eax,%eax
f01019f8:	78 19                	js     f0101a13 <mem_init+0x6e4>
f01019fa:	68 38 71 10 f0       	push   $0xf0107138
f01019ff:	68 dd 78 10 f0       	push   $0xf01078dd
f0101a04:	68 dc 03 00 00       	push   $0x3dc
f0101a09:	68 9d 78 10 f0       	push   $0xf010789d
f0101a0e:	e8 2d e6 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101a13:	83 ec 0c             	sub    $0xc,%esp
f0101a16:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a19:	e8 45 f5 ff ff       	call   f0100f63 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101a1e:	6a 02                	push   $0x2
f0101a20:	6a 00                	push   $0x0
f0101a22:	53                   	push   %ebx
f0101a23:	ff 35 9c 1e 2a f0    	pushl  0xf02a1e9c
f0101a29:	e8 03 f8 ff ff       	call   f0101231 <page_insert>
f0101a2e:	83 c4 20             	add    $0x20,%esp
f0101a31:	85 c0                	test   %eax,%eax
f0101a33:	74 19                	je     f0101a4e <mem_init+0x71f>
f0101a35:	68 68 71 10 f0       	push   $0xf0107168
f0101a3a:	68 dd 78 10 f0       	push   $0xf01078dd
f0101a3f:	68 e0 03 00 00       	push   $0x3e0
f0101a44:	68 9d 78 10 f0       	push   $0xf010789d
f0101a49:	e8 f2 e5 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101a4e:	8b 3d 9c 1e 2a f0    	mov    0xf02a1e9c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a54:	a1 a0 1e 2a f0       	mov    0xf02a1ea0,%eax
f0101a59:	89 c1                	mov    %eax,%ecx
f0101a5b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101a5e:	8b 17                	mov    (%edi),%edx
f0101a60:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101a66:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a69:	29 c8                	sub    %ecx,%eax
f0101a6b:	c1 f8 03             	sar    $0x3,%eax
f0101a6e:	c1 e0 0c             	shl    $0xc,%eax
f0101a71:	39 c2                	cmp    %eax,%edx
f0101a73:	74 19                	je     f0101a8e <mem_init+0x75f>
f0101a75:	68 98 71 10 f0       	push   $0xf0107198
f0101a7a:	68 dd 78 10 f0       	push   $0xf01078dd
f0101a7f:	68 e1 03 00 00       	push   $0x3e1
f0101a84:	68 9d 78 10 f0       	push   $0xf010789d
f0101a89:	e8 b2 e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a8e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a93:	89 f8                	mov    %edi,%eax
f0101a95:	e8 b7 ef ff ff       	call   f0100a51 <check_va2pa>
f0101a9a:	89 da                	mov    %ebx,%edx
f0101a9c:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101a9f:	c1 fa 03             	sar    $0x3,%edx
f0101aa2:	c1 e2 0c             	shl    $0xc,%edx
f0101aa5:	39 d0                	cmp    %edx,%eax
f0101aa7:	74 19                	je     f0101ac2 <mem_init+0x793>
f0101aa9:	68 c0 71 10 f0       	push   $0xf01071c0
f0101aae:	68 dd 78 10 f0       	push   $0xf01078dd
f0101ab3:	68 e2 03 00 00       	push   $0x3e2
f0101ab8:	68 9d 78 10 f0       	push   $0xf010789d
f0101abd:	e8 7e e5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101ac2:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ac7:	74 19                	je     f0101ae2 <mem_init+0x7b3>
f0101ac9:	68 a2 7a 10 f0       	push   $0xf0107aa2
f0101ace:	68 dd 78 10 f0       	push   $0xf01078dd
f0101ad3:	68 e3 03 00 00       	push   $0x3e3
f0101ad8:	68 9d 78 10 f0       	push   $0xf010789d
f0101add:	e8 5e e5 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101ae2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ae5:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101aea:	74 19                	je     f0101b05 <mem_init+0x7d6>
f0101aec:	68 b3 7a 10 f0       	push   $0xf0107ab3
f0101af1:	68 dd 78 10 f0       	push   $0xf01078dd
f0101af6:	68 e4 03 00 00       	push   $0x3e4
f0101afb:	68 9d 78 10 f0       	push   $0xf010789d
f0101b00:	e8 3b e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b05:	6a 02                	push   $0x2
f0101b07:	68 00 10 00 00       	push   $0x1000
f0101b0c:	56                   	push   %esi
f0101b0d:	57                   	push   %edi
f0101b0e:	e8 1e f7 ff ff       	call   f0101231 <page_insert>
f0101b13:	83 c4 10             	add    $0x10,%esp
f0101b16:	85 c0                	test   %eax,%eax
f0101b18:	74 19                	je     f0101b33 <mem_init+0x804>
f0101b1a:	68 f0 71 10 f0       	push   $0xf01071f0
f0101b1f:	68 dd 78 10 f0       	push   $0xf01078dd
f0101b24:	68 e7 03 00 00       	push   $0x3e7
f0101b29:	68 9d 78 10 f0       	push   $0xf010789d
f0101b2e:	e8 0d e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b33:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b38:	a1 9c 1e 2a f0       	mov    0xf02a1e9c,%eax
f0101b3d:	e8 0f ef ff ff       	call   f0100a51 <check_va2pa>
f0101b42:	89 f2                	mov    %esi,%edx
f0101b44:	2b 15 a0 1e 2a f0    	sub    0xf02a1ea0,%edx
f0101b4a:	c1 fa 03             	sar    $0x3,%edx
f0101b4d:	c1 e2 0c             	shl    $0xc,%edx
f0101b50:	39 d0                	cmp    %edx,%eax
f0101b52:	74 19                	je     f0101b6d <mem_init+0x83e>
f0101b54:	68 2c 72 10 f0       	push   $0xf010722c
f0101b59:	68 dd 78 10 f0       	push   $0xf01078dd
f0101b5e:	68 e8 03 00 00       	push   $0x3e8
f0101b63:	68 9d 78 10 f0       	push   $0xf010789d
f0101b68:	e8 d3 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101b6d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b72:	74 19                	je     f0101b8d <mem_init+0x85e>
f0101b74:	68 c4 7a 10 f0       	push   $0xf0107ac4
f0101b79:	68 dd 78 10 f0       	push   $0xf01078dd
f0101b7e:	68 e9 03 00 00       	push   $0x3e9
f0101b83:	68 9d 78 10 f0       	push   $0xf010789d
f0101b88:	e8 b3 e4 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101b8d:	83 ec 0c             	sub    $0xc,%esp
f0101b90:	6a 00                	push   $0x0
f0101b92:	e8 5c f3 ff ff       	call   f0100ef3 <page_alloc>
f0101b97:	83 c4 10             	add    $0x10,%esp
f0101b9a:	85 c0                	test   %eax,%eax
f0101b9c:	74 19                	je     f0101bb7 <mem_init+0x888>
f0101b9e:	68 50 7a 10 f0       	push   $0xf0107a50
f0101ba3:	68 dd 78 10 f0       	push   $0xf01078dd
f0101ba8:	68 ec 03 00 00       	push   $0x3ec
f0101bad:	68 9d 78 10 f0       	push   $0xf010789d
f0101bb2:	e8 89 e4 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bb7:	6a 02                	push   $0x2
f0101bb9:	68 00 10 00 00       	push   $0x1000
f0101bbe:	56                   	push   %esi
f0101bbf:	ff 35 9c 1e 2a f0    	pushl  0xf02a1e9c
f0101bc5:	e8 67 f6 ff ff       	call   f0101231 <page_insert>
f0101bca:	83 c4 10             	add    $0x10,%esp
f0101bcd:	85 c0                	test   %eax,%eax
f0101bcf:	74 19                	je     f0101bea <mem_init+0x8bb>
f0101bd1:	68 f0 71 10 f0       	push   $0xf01071f0
f0101bd6:	68 dd 78 10 f0       	push   $0xf01078dd
f0101bdb:	68 ef 03 00 00       	push   $0x3ef
f0101be0:	68 9d 78 10 f0       	push   $0xf010789d
f0101be5:	e8 56 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bea:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bef:	a1 9c 1e 2a f0       	mov    0xf02a1e9c,%eax
f0101bf4:	e8 58 ee ff ff       	call   f0100a51 <check_va2pa>
f0101bf9:	89 f2                	mov    %esi,%edx
f0101bfb:	2b 15 a0 1e 2a f0    	sub    0xf02a1ea0,%edx
f0101c01:	c1 fa 03             	sar    $0x3,%edx
f0101c04:	c1 e2 0c             	shl    $0xc,%edx
f0101c07:	39 d0                	cmp    %edx,%eax
f0101c09:	74 19                	je     f0101c24 <mem_init+0x8f5>
f0101c0b:	68 2c 72 10 f0       	push   $0xf010722c
f0101c10:	68 dd 78 10 f0       	push   $0xf01078dd
f0101c15:	68 f0 03 00 00       	push   $0x3f0
f0101c1a:	68 9d 78 10 f0       	push   $0xf010789d
f0101c1f:	e8 1c e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101c24:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c29:	74 19                	je     f0101c44 <mem_init+0x915>
f0101c2b:	68 c4 7a 10 f0       	push   $0xf0107ac4
f0101c30:	68 dd 78 10 f0       	push   $0xf01078dd
f0101c35:	68 f1 03 00 00       	push   $0x3f1
f0101c3a:	68 9d 78 10 f0       	push   $0xf010789d
f0101c3f:	e8 fc e3 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c44:	83 ec 0c             	sub    $0xc,%esp
f0101c47:	6a 00                	push   $0x0
f0101c49:	e8 a5 f2 ff ff       	call   f0100ef3 <page_alloc>
f0101c4e:	83 c4 10             	add    $0x10,%esp
f0101c51:	85 c0                	test   %eax,%eax
f0101c53:	74 19                	je     f0101c6e <mem_init+0x93f>
f0101c55:	68 50 7a 10 f0       	push   $0xf0107a50
f0101c5a:	68 dd 78 10 f0       	push   $0xf01078dd
f0101c5f:	68 f5 03 00 00       	push   $0x3f5
f0101c64:	68 9d 78 10 f0       	push   $0xf010789d
f0101c69:	e8 d2 e3 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c6e:	8b 15 9c 1e 2a f0    	mov    0xf02a1e9c,%edx
f0101c74:	8b 02                	mov    (%edx),%eax
f0101c76:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c7b:	89 c1                	mov    %eax,%ecx
f0101c7d:	c1 e9 0c             	shr    $0xc,%ecx
f0101c80:	3b 0d 98 1e 2a f0    	cmp    0xf02a1e98,%ecx
f0101c86:	72 15                	jb     f0101c9d <mem_init+0x96e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c88:	50                   	push   %eax
f0101c89:	68 a4 69 10 f0       	push   $0xf01069a4
f0101c8e:	68 f8 03 00 00       	push   $0x3f8
f0101c93:	68 9d 78 10 f0       	push   $0xf010789d
f0101c98:	e8 a3 e3 ff ff       	call   f0100040 <_panic>
f0101c9d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ca2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ca5:	83 ec 04             	sub    $0x4,%esp
f0101ca8:	6a 00                	push   $0x0
f0101caa:	68 00 10 00 00       	push   $0x1000
f0101caf:	52                   	push   %edx
f0101cb0:	e8 10 f3 ff ff       	call   f0100fc5 <pgdir_walk>
f0101cb5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101cb8:	8d 51 04             	lea    0x4(%ecx),%edx
f0101cbb:	83 c4 10             	add    $0x10,%esp
f0101cbe:	39 d0                	cmp    %edx,%eax
f0101cc0:	74 19                	je     f0101cdb <mem_init+0x9ac>
f0101cc2:	68 5c 72 10 f0       	push   $0xf010725c
f0101cc7:	68 dd 78 10 f0       	push   $0xf01078dd
f0101ccc:	68 f9 03 00 00       	push   $0x3f9
f0101cd1:	68 9d 78 10 f0       	push   $0xf010789d
f0101cd6:	e8 65 e3 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101cdb:	6a 06                	push   $0x6
f0101cdd:	68 00 10 00 00       	push   $0x1000
f0101ce2:	56                   	push   %esi
f0101ce3:	ff 35 9c 1e 2a f0    	pushl  0xf02a1e9c
f0101ce9:	e8 43 f5 ff ff       	call   f0101231 <page_insert>
f0101cee:	83 c4 10             	add    $0x10,%esp
f0101cf1:	85 c0                	test   %eax,%eax
f0101cf3:	74 19                	je     f0101d0e <mem_init+0x9df>
f0101cf5:	68 9c 72 10 f0       	push   $0xf010729c
f0101cfa:	68 dd 78 10 f0       	push   $0xf01078dd
f0101cff:	68 fc 03 00 00       	push   $0x3fc
f0101d04:	68 9d 78 10 f0       	push   $0xf010789d
f0101d09:	e8 32 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d0e:	8b 3d 9c 1e 2a f0    	mov    0xf02a1e9c,%edi
f0101d14:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d19:	89 f8                	mov    %edi,%eax
f0101d1b:	e8 31 ed ff ff       	call   f0100a51 <check_va2pa>
f0101d20:	89 f2                	mov    %esi,%edx
f0101d22:	2b 15 a0 1e 2a f0    	sub    0xf02a1ea0,%edx
f0101d28:	c1 fa 03             	sar    $0x3,%edx
f0101d2b:	c1 e2 0c             	shl    $0xc,%edx
f0101d2e:	39 d0                	cmp    %edx,%eax
f0101d30:	74 19                	je     f0101d4b <mem_init+0xa1c>
f0101d32:	68 2c 72 10 f0       	push   $0xf010722c
f0101d37:	68 dd 78 10 f0       	push   $0xf01078dd
f0101d3c:	68 fd 03 00 00       	push   $0x3fd
f0101d41:	68 9d 78 10 f0       	push   $0xf010789d
f0101d46:	e8 f5 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101d4b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d50:	74 19                	je     f0101d6b <mem_init+0xa3c>
f0101d52:	68 c4 7a 10 f0       	push   $0xf0107ac4
f0101d57:	68 dd 78 10 f0       	push   $0xf01078dd
f0101d5c:	68 fe 03 00 00       	push   $0x3fe
f0101d61:	68 9d 78 10 f0       	push   $0xf010789d
f0101d66:	e8 d5 e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d6b:	83 ec 04             	sub    $0x4,%esp
f0101d6e:	6a 00                	push   $0x0
f0101d70:	68 00 10 00 00       	push   $0x1000
f0101d75:	57                   	push   %edi
f0101d76:	e8 4a f2 ff ff       	call   f0100fc5 <pgdir_walk>
f0101d7b:	83 c4 10             	add    $0x10,%esp
f0101d7e:	f6 00 04             	testb  $0x4,(%eax)
f0101d81:	75 19                	jne    f0101d9c <mem_init+0xa6d>
f0101d83:	68 dc 72 10 f0       	push   $0xf01072dc
f0101d88:	68 dd 78 10 f0       	push   $0xf01078dd
f0101d8d:	68 ff 03 00 00       	push   $0x3ff
f0101d92:	68 9d 78 10 f0       	push   $0xf010789d
f0101d97:	e8 a4 e2 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101d9c:	a1 9c 1e 2a f0       	mov    0xf02a1e9c,%eax
f0101da1:	f6 00 04             	testb  $0x4,(%eax)
f0101da4:	75 19                	jne    f0101dbf <mem_init+0xa90>
f0101da6:	68 d5 7a 10 f0       	push   $0xf0107ad5
f0101dab:	68 dd 78 10 f0       	push   $0xf01078dd
f0101db0:	68 00 04 00 00       	push   $0x400
f0101db5:	68 9d 78 10 f0       	push   $0xf010789d
f0101dba:	e8 81 e2 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101dbf:	6a 02                	push   $0x2
f0101dc1:	68 00 10 00 00       	push   $0x1000
f0101dc6:	56                   	push   %esi
f0101dc7:	50                   	push   %eax
f0101dc8:	e8 64 f4 ff ff       	call   f0101231 <page_insert>
f0101dcd:	83 c4 10             	add    $0x10,%esp
f0101dd0:	85 c0                	test   %eax,%eax
f0101dd2:	74 19                	je     f0101ded <mem_init+0xabe>
f0101dd4:	68 f0 71 10 f0       	push   $0xf01071f0
f0101dd9:	68 dd 78 10 f0       	push   $0xf01078dd
f0101dde:	68 03 04 00 00       	push   $0x403
f0101de3:	68 9d 78 10 f0       	push   $0xf010789d
f0101de8:	e8 53 e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101ded:	83 ec 04             	sub    $0x4,%esp
f0101df0:	6a 00                	push   $0x0
f0101df2:	68 00 10 00 00       	push   $0x1000
f0101df7:	ff 35 9c 1e 2a f0    	pushl  0xf02a1e9c
f0101dfd:	e8 c3 f1 ff ff       	call   f0100fc5 <pgdir_walk>
f0101e02:	83 c4 10             	add    $0x10,%esp
f0101e05:	f6 00 02             	testb  $0x2,(%eax)
f0101e08:	75 19                	jne    f0101e23 <mem_init+0xaf4>
f0101e0a:	68 10 73 10 f0       	push   $0xf0107310
f0101e0f:	68 dd 78 10 f0       	push   $0xf01078dd
f0101e14:	68 04 04 00 00       	push   $0x404
f0101e19:	68 9d 78 10 f0       	push   $0xf010789d
f0101e1e:	e8 1d e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e23:	83 ec 04             	sub    $0x4,%esp
f0101e26:	6a 00                	push   $0x0
f0101e28:	68 00 10 00 00       	push   $0x1000
f0101e2d:	ff 35 9c 1e 2a f0    	pushl  0xf02a1e9c
f0101e33:	e8 8d f1 ff ff       	call   f0100fc5 <pgdir_walk>
f0101e38:	83 c4 10             	add    $0x10,%esp
f0101e3b:	f6 00 04             	testb  $0x4,(%eax)
f0101e3e:	74 19                	je     f0101e59 <mem_init+0xb2a>
f0101e40:	68 44 73 10 f0       	push   $0xf0107344
f0101e45:	68 dd 78 10 f0       	push   $0xf01078dd
f0101e4a:	68 05 04 00 00       	push   $0x405
f0101e4f:	68 9d 78 10 f0       	push   $0xf010789d
f0101e54:	e8 e7 e1 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101e59:	6a 02                	push   $0x2
f0101e5b:	68 00 00 40 00       	push   $0x400000
f0101e60:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101e63:	ff 35 9c 1e 2a f0    	pushl  0xf02a1e9c
f0101e69:	e8 c3 f3 ff ff       	call   f0101231 <page_insert>
f0101e6e:	83 c4 10             	add    $0x10,%esp
f0101e71:	85 c0                	test   %eax,%eax
f0101e73:	78 19                	js     f0101e8e <mem_init+0xb5f>
f0101e75:	68 7c 73 10 f0       	push   $0xf010737c
f0101e7a:	68 dd 78 10 f0       	push   $0xf01078dd
f0101e7f:	68 08 04 00 00       	push   $0x408
f0101e84:	68 9d 78 10 f0       	push   $0xf010789d
f0101e89:	e8 b2 e1 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101e8e:	6a 02                	push   $0x2
f0101e90:	68 00 10 00 00       	push   $0x1000
f0101e95:	53                   	push   %ebx
f0101e96:	ff 35 9c 1e 2a f0    	pushl  0xf02a1e9c
f0101e9c:	e8 90 f3 ff ff       	call   f0101231 <page_insert>
f0101ea1:	83 c4 10             	add    $0x10,%esp
f0101ea4:	85 c0                	test   %eax,%eax
f0101ea6:	74 19                	je     f0101ec1 <mem_init+0xb92>
f0101ea8:	68 b4 73 10 f0       	push   $0xf01073b4
f0101ead:	68 dd 78 10 f0       	push   $0xf01078dd
f0101eb2:	68 0b 04 00 00       	push   $0x40b
f0101eb7:	68 9d 78 10 f0       	push   $0xf010789d
f0101ebc:	e8 7f e1 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ec1:	83 ec 04             	sub    $0x4,%esp
f0101ec4:	6a 00                	push   $0x0
f0101ec6:	68 00 10 00 00       	push   $0x1000
f0101ecb:	ff 35 9c 1e 2a f0    	pushl  0xf02a1e9c
f0101ed1:	e8 ef f0 ff ff       	call   f0100fc5 <pgdir_walk>
f0101ed6:	83 c4 10             	add    $0x10,%esp
f0101ed9:	f6 00 04             	testb  $0x4,(%eax)
f0101edc:	74 19                	je     f0101ef7 <mem_init+0xbc8>
f0101ede:	68 44 73 10 f0       	push   $0xf0107344
f0101ee3:	68 dd 78 10 f0       	push   $0xf01078dd
f0101ee8:	68 0c 04 00 00       	push   $0x40c
f0101eed:	68 9d 78 10 f0       	push   $0xf010789d
f0101ef2:	e8 49 e1 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101ef7:	8b 3d 9c 1e 2a f0    	mov    0xf02a1e9c,%edi
f0101efd:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f02:	89 f8                	mov    %edi,%eax
f0101f04:	e8 48 eb ff ff       	call   f0100a51 <check_va2pa>
f0101f09:	89 c1                	mov    %eax,%ecx
f0101f0b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f0e:	89 d8                	mov    %ebx,%eax
f0101f10:	2b 05 a0 1e 2a f0    	sub    0xf02a1ea0,%eax
f0101f16:	c1 f8 03             	sar    $0x3,%eax
f0101f19:	c1 e0 0c             	shl    $0xc,%eax
f0101f1c:	39 c1                	cmp    %eax,%ecx
f0101f1e:	74 19                	je     f0101f39 <mem_init+0xc0a>
f0101f20:	68 f0 73 10 f0       	push   $0xf01073f0
f0101f25:	68 dd 78 10 f0       	push   $0xf01078dd
f0101f2a:	68 0f 04 00 00       	push   $0x40f
f0101f2f:	68 9d 78 10 f0       	push   $0xf010789d
f0101f34:	e8 07 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f39:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f3e:	89 f8                	mov    %edi,%eax
f0101f40:	e8 0c eb ff ff       	call   f0100a51 <check_va2pa>
f0101f45:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101f48:	74 19                	je     f0101f63 <mem_init+0xc34>
f0101f4a:	68 1c 74 10 f0       	push   $0xf010741c
f0101f4f:	68 dd 78 10 f0       	push   $0xf01078dd
f0101f54:	68 10 04 00 00       	push   $0x410
f0101f59:	68 9d 78 10 f0       	push   $0xf010789d
f0101f5e:	e8 dd e0 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101f63:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101f68:	74 19                	je     f0101f83 <mem_init+0xc54>
f0101f6a:	68 eb 7a 10 f0       	push   $0xf0107aeb
f0101f6f:	68 dd 78 10 f0       	push   $0xf01078dd
f0101f74:	68 12 04 00 00       	push   $0x412
f0101f79:	68 9d 78 10 f0       	push   $0xf010789d
f0101f7e:	e8 bd e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101f83:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f88:	74 19                	je     f0101fa3 <mem_init+0xc74>
f0101f8a:	68 fc 7a 10 f0       	push   $0xf0107afc
f0101f8f:	68 dd 78 10 f0       	push   $0xf01078dd
f0101f94:	68 13 04 00 00       	push   $0x413
f0101f99:	68 9d 78 10 f0       	push   $0xf010789d
f0101f9e:	e8 9d e0 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101fa3:	83 ec 0c             	sub    $0xc,%esp
f0101fa6:	6a 00                	push   $0x0
f0101fa8:	e8 46 ef ff ff       	call   f0100ef3 <page_alloc>
f0101fad:	83 c4 10             	add    $0x10,%esp
f0101fb0:	85 c0                	test   %eax,%eax
f0101fb2:	74 04                	je     f0101fb8 <mem_init+0xc89>
f0101fb4:	39 c6                	cmp    %eax,%esi
f0101fb6:	74 19                	je     f0101fd1 <mem_init+0xca2>
f0101fb8:	68 4c 74 10 f0       	push   $0xf010744c
f0101fbd:	68 dd 78 10 f0       	push   $0xf01078dd
f0101fc2:	68 16 04 00 00       	push   $0x416
f0101fc7:	68 9d 78 10 f0       	push   $0xf010789d
f0101fcc:	e8 6f e0 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101fd1:	83 ec 08             	sub    $0x8,%esp
f0101fd4:	6a 00                	push   $0x0
f0101fd6:	ff 35 9c 1e 2a f0    	pushl  0xf02a1e9c
f0101fdc:	e8 0a f2 ff ff       	call   f01011eb <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101fe1:	8b 3d 9c 1e 2a f0    	mov    0xf02a1e9c,%edi
f0101fe7:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fec:	89 f8                	mov    %edi,%eax
f0101fee:	e8 5e ea ff ff       	call   f0100a51 <check_va2pa>
f0101ff3:	83 c4 10             	add    $0x10,%esp
f0101ff6:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ff9:	74 19                	je     f0102014 <mem_init+0xce5>
f0101ffb:	68 70 74 10 f0       	push   $0xf0107470
f0102000:	68 dd 78 10 f0       	push   $0xf01078dd
f0102005:	68 1a 04 00 00       	push   $0x41a
f010200a:	68 9d 78 10 f0       	push   $0xf010789d
f010200f:	e8 2c e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102014:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102019:	89 f8                	mov    %edi,%eax
f010201b:	e8 31 ea ff ff       	call   f0100a51 <check_va2pa>
f0102020:	89 da                	mov    %ebx,%edx
f0102022:	2b 15 a0 1e 2a f0    	sub    0xf02a1ea0,%edx
f0102028:	c1 fa 03             	sar    $0x3,%edx
f010202b:	c1 e2 0c             	shl    $0xc,%edx
f010202e:	39 d0                	cmp    %edx,%eax
f0102030:	74 19                	je     f010204b <mem_init+0xd1c>
f0102032:	68 1c 74 10 f0       	push   $0xf010741c
f0102037:	68 dd 78 10 f0       	push   $0xf01078dd
f010203c:	68 1b 04 00 00       	push   $0x41b
f0102041:	68 9d 78 10 f0       	push   $0xf010789d
f0102046:	e8 f5 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010204b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102050:	74 19                	je     f010206b <mem_init+0xd3c>
f0102052:	68 a2 7a 10 f0       	push   $0xf0107aa2
f0102057:	68 dd 78 10 f0       	push   $0xf01078dd
f010205c:	68 1c 04 00 00       	push   $0x41c
f0102061:	68 9d 78 10 f0       	push   $0xf010789d
f0102066:	e8 d5 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010206b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102070:	74 19                	je     f010208b <mem_init+0xd5c>
f0102072:	68 fc 7a 10 f0       	push   $0xf0107afc
f0102077:	68 dd 78 10 f0       	push   $0xf01078dd
f010207c:	68 1d 04 00 00       	push   $0x41d
f0102081:	68 9d 78 10 f0       	push   $0xf010789d
f0102086:	e8 b5 df ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010208b:	6a 00                	push   $0x0
f010208d:	68 00 10 00 00       	push   $0x1000
f0102092:	53                   	push   %ebx
f0102093:	57                   	push   %edi
f0102094:	e8 98 f1 ff ff       	call   f0101231 <page_insert>
f0102099:	83 c4 10             	add    $0x10,%esp
f010209c:	85 c0                	test   %eax,%eax
f010209e:	74 19                	je     f01020b9 <mem_init+0xd8a>
f01020a0:	68 94 74 10 f0       	push   $0xf0107494
f01020a5:	68 dd 78 10 f0       	push   $0xf01078dd
f01020aa:	68 20 04 00 00       	push   $0x420
f01020af:	68 9d 78 10 f0       	push   $0xf010789d
f01020b4:	e8 87 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01020b9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01020be:	75 19                	jne    f01020d9 <mem_init+0xdaa>
f01020c0:	68 0d 7b 10 f0       	push   $0xf0107b0d
f01020c5:	68 dd 78 10 f0       	push   $0xf01078dd
f01020ca:	68 21 04 00 00       	push   $0x421
f01020cf:	68 9d 78 10 f0       	push   $0xf010789d
f01020d4:	e8 67 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01020d9:	83 3b 00             	cmpl   $0x0,(%ebx)
f01020dc:	74 19                	je     f01020f7 <mem_init+0xdc8>
f01020de:	68 19 7b 10 f0       	push   $0xf0107b19
f01020e3:	68 dd 78 10 f0       	push   $0xf01078dd
f01020e8:	68 22 04 00 00       	push   $0x422
f01020ed:	68 9d 78 10 f0       	push   $0xf010789d
f01020f2:	e8 49 df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01020f7:	83 ec 08             	sub    $0x8,%esp
f01020fa:	68 00 10 00 00       	push   $0x1000
f01020ff:	ff 35 9c 1e 2a f0    	pushl  0xf02a1e9c
f0102105:	e8 e1 f0 ff ff       	call   f01011eb <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010210a:	8b 3d 9c 1e 2a f0    	mov    0xf02a1e9c,%edi
f0102110:	ba 00 00 00 00       	mov    $0x0,%edx
f0102115:	89 f8                	mov    %edi,%eax
f0102117:	e8 35 e9 ff ff       	call   f0100a51 <check_va2pa>
f010211c:	83 c4 10             	add    $0x10,%esp
f010211f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102122:	74 19                	je     f010213d <mem_init+0xe0e>
f0102124:	68 70 74 10 f0       	push   $0xf0107470
f0102129:	68 dd 78 10 f0       	push   $0xf01078dd
f010212e:	68 26 04 00 00       	push   $0x426
f0102133:	68 9d 78 10 f0       	push   $0xf010789d
f0102138:	e8 03 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010213d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102142:	89 f8                	mov    %edi,%eax
f0102144:	e8 08 e9 ff ff       	call   f0100a51 <check_va2pa>
f0102149:	83 f8 ff             	cmp    $0xffffffff,%eax
f010214c:	74 19                	je     f0102167 <mem_init+0xe38>
f010214e:	68 cc 74 10 f0       	push   $0xf01074cc
f0102153:	68 dd 78 10 f0       	push   $0xf01078dd
f0102158:	68 27 04 00 00       	push   $0x427
f010215d:	68 9d 78 10 f0       	push   $0xf010789d
f0102162:	e8 d9 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102167:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010216c:	74 19                	je     f0102187 <mem_init+0xe58>
f010216e:	68 2e 7b 10 f0       	push   $0xf0107b2e
f0102173:	68 dd 78 10 f0       	push   $0xf01078dd
f0102178:	68 28 04 00 00       	push   $0x428
f010217d:	68 9d 78 10 f0       	push   $0xf010789d
f0102182:	e8 b9 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102187:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010218c:	74 19                	je     f01021a7 <mem_init+0xe78>
f010218e:	68 fc 7a 10 f0       	push   $0xf0107afc
f0102193:	68 dd 78 10 f0       	push   $0xf01078dd
f0102198:	68 29 04 00 00       	push   $0x429
f010219d:	68 9d 78 10 f0       	push   $0xf010789d
f01021a2:	e8 99 de ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01021a7:	83 ec 0c             	sub    $0xc,%esp
f01021aa:	6a 00                	push   $0x0
f01021ac:	e8 42 ed ff ff       	call   f0100ef3 <page_alloc>
f01021b1:	83 c4 10             	add    $0x10,%esp
f01021b4:	39 c3                	cmp    %eax,%ebx
f01021b6:	75 04                	jne    f01021bc <mem_init+0xe8d>
f01021b8:	85 c0                	test   %eax,%eax
f01021ba:	75 19                	jne    f01021d5 <mem_init+0xea6>
f01021bc:	68 f4 74 10 f0       	push   $0xf01074f4
f01021c1:	68 dd 78 10 f0       	push   $0xf01078dd
f01021c6:	68 2c 04 00 00       	push   $0x42c
f01021cb:	68 9d 78 10 f0       	push   $0xf010789d
f01021d0:	e8 6b de ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01021d5:	83 ec 0c             	sub    $0xc,%esp
f01021d8:	6a 00                	push   $0x0
f01021da:	e8 14 ed ff ff       	call   f0100ef3 <page_alloc>
f01021df:	83 c4 10             	add    $0x10,%esp
f01021e2:	85 c0                	test   %eax,%eax
f01021e4:	74 19                	je     f01021ff <mem_init+0xed0>
f01021e6:	68 50 7a 10 f0       	push   $0xf0107a50
f01021eb:	68 dd 78 10 f0       	push   $0xf01078dd
f01021f0:	68 2f 04 00 00       	push   $0x42f
f01021f5:	68 9d 78 10 f0       	push   $0xf010789d
f01021fa:	e8 41 de ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01021ff:	8b 0d 9c 1e 2a f0    	mov    0xf02a1e9c,%ecx
f0102205:	8b 11                	mov    (%ecx),%edx
f0102207:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010220d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102210:	2b 05 a0 1e 2a f0    	sub    0xf02a1ea0,%eax
f0102216:	c1 f8 03             	sar    $0x3,%eax
f0102219:	c1 e0 0c             	shl    $0xc,%eax
f010221c:	39 c2                	cmp    %eax,%edx
f010221e:	74 19                	je     f0102239 <mem_init+0xf0a>
f0102220:	68 98 71 10 f0       	push   $0xf0107198
f0102225:	68 dd 78 10 f0       	push   $0xf01078dd
f010222a:	68 32 04 00 00       	push   $0x432
f010222f:	68 9d 78 10 f0       	push   $0xf010789d
f0102234:	e8 07 de ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102239:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010223f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102242:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102247:	74 19                	je     f0102262 <mem_init+0xf33>
f0102249:	68 b3 7a 10 f0       	push   $0xf0107ab3
f010224e:	68 dd 78 10 f0       	push   $0xf01078dd
f0102253:	68 34 04 00 00       	push   $0x434
f0102258:	68 9d 78 10 f0       	push   $0xf010789d
f010225d:	e8 de dd ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102262:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102265:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010226b:	83 ec 0c             	sub    $0xc,%esp
f010226e:	50                   	push   %eax
f010226f:	e8 ef ec ff ff       	call   f0100f63 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102274:	83 c4 0c             	add    $0xc,%esp
f0102277:	6a 01                	push   $0x1
f0102279:	68 00 10 40 00       	push   $0x401000
f010227e:	ff 35 9c 1e 2a f0    	pushl  0xf02a1e9c
f0102284:	e8 3c ed ff ff       	call   f0100fc5 <pgdir_walk>
f0102289:	89 c7                	mov    %eax,%edi
f010228b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010228e:	a1 9c 1e 2a f0       	mov    0xf02a1e9c,%eax
f0102293:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102296:	8b 40 04             	mov    0x4(%eax),%eax
f0102299:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010229e:	8b 0d 98 1e 2a f0    	mov    0xf02a1e98,%ecx
f01022a4:	89 c2                	mov    %eax,%edx
f01022a6:	c1 ea 0c             	shr    $0xc,%edx
f01022a9:	83 c4 10             	add    $0x10,%esp
f01022ac:	39 ca                	cmp    %ecx,%edx
f01022ae:	72 15                	jb     f01022c5 <mem_init+0xf96>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01022b0:	50                   	push   %eax
f01022b1:	68 a4 69 10 f0       	push   $0xf01069a4
f01022b6:	68 3b 04 00 00       	push   $0x43b
f01022bb:	68 9d 78 10 f0       	push   $0xf010789d
f01022c0:	e8 7b dd ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01022c5:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01022ca:	39 c7                	cmp    %eax,%edi
f01022cc:	74 19                	je     f01022e7 <mem_init+0xfb8>
f01022ce:	68 3f 7b 10 f0       	push   $0xf0107b3f
f01022d3:	68 dd 78 10 f0       	push   $0xf01078dd
f01022d8:	68 3c 04 00 00       	push   $0x43c
f01022dd:	68 9d 78 10 f0       	push   $0xf010789d
f01022e2:	e8 59 dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01022e7:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01022ea:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f01022f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022f4:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01022fa:	2b 05 a0 1e 2a f0    	sub    0xf02a1ea0,%eax
f0102300:	c1 f8 03             	sar    $0x3,%eax
f0102303:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102306:	89 c2                	mov    %eax,%edx
f0102308:	c1 ea 0c             	shr    $0xc,%edx
f010230b:	39 d1                	cmp    %edx,%ecx
f010230d:	77 12                	ja     f0102321 <mem_init+0xff2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010230f:	50                   	push   %eax
f0102310:	68 a4 69 10 f0       	push   $0xf01069a4
f0102315:	6a 58                	push   $0x58
f0102317:	68 c3 78 10 f0       	push   $0xf01078c3
f010231c:	e8 1f dd ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102321:	83 ec 04             	sub    $0x4,%esp
f0102324:	68 00 10 00 00       	push   $0x1000
f0102329:	68 ff 00 00 00       	push   $0xff
f010232e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102333:	50                   	push   %eax
f0102334:	e8 a9 2e 00 00       	call   f01051e2 <memset>
	page_free(pp0);
f0102339:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010233c:	89 3c 24             	mov    %edi,(%esp)
f010233f:	e8 1f ec ff ff       	call   f0100f63 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102344:	83 c4 0c             	add    $0xc,%esp
f0102347:	6a 01                	push   $0x1
f0102349:	6a 00                	push   $0x0
f010234b:	ff 35 9c 1e 2a f0    	pushl  0xf02a1e9c
f0102351:	e8 6f ec ff ff       	call   f0100fc5 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102356:	89 fa                	mov    %edi,%edx
f0102358:	2b 15 a0 1e 2a f0    	sub    0xf02a1ea0,%edx
f010235e:	c1 fa 03             	sar    $0x3,%edx
f0102361:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102364:	89 d0                	mov    %edx,%eax
f0102366:	c1 e8 0c             	shr    $0xc,%eax
f0102369:	83 c4 10             	add    $0x10,%esp
f010236c:	3b 05 98 1e 2a f0    	cmp    0xf02a1e98,%eax
f0102372:	72 12                	jb     f0102386 <mem_init+0x1057>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102374:	52                   	push   %edx
f0102375:	68 a4 69 10 f0       	push   $0xf01069a4
f010237a:	6a 58                	push   $0x58
f010237c:	68 c3 78 10 f0       	push   $0xf01078c3
f0102381:	e8 ba dc ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102386:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010238c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010238f:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102395:	f6 00 01             	testb  $0x1,(%eax)
f0102398:	74 19                	je     f01023b3 <mem_init+0x1084>
f010239a:	68 57 7b 10 f0       	push   $0xf0107b57
f010239f:	68 dd 78 10 f0       	push   $0xf01078dd
f01023a4:	68 46 04 00 00       	push   $0x446
f01023a9:	68 9d 78 10 f0       	push   $0xf010789d
f01023ae:	e8 8d dc ff ff       	call   f0100040 <_panic>
f01023b3:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01023b6:	39 d0                	cmp    %edx,%eax
f01023b8:	75 db                	jne    f0102395 <mem_init+0x1066>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01023ba:	a1 9c 1e 2a f0       	mov    0xf02a1e9c,%eax
f01023bf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01023c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023c8:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01023ce:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01023d1:	89 0d 40 12 2a f0    	mov    %ecx,0xf02a1240

	// free the pages we took
	page_free(pp0);
f01023d7:	83 ec 0c             	sub    $0xc,%esp
f01023da:	50                   	push   %eax
f01023db:	e8 83 eb ff ff       	call   f0100f63 <page_free>
	page_free(pp1);
f01023e0:	89 1c 24             	mov    %ebx,(%esp)
f01023e3:	e8 7b eb ff ff       	call   f0100f63 <page_free>
	page_free(pp2);
f01023e8:	89 34 24             	mov    %esi,(%esp)
f01023eb:	e8 73 eb ff ff       	call   f0100f63 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01023f0:	83 c4 08             	add    $0x8,%esp
f01023f3:	68 01 10 00 00       	push   $0x1001
f01023f8:	6a 00                	push   $0x0
f01023fa:	e8 c2 ee ff ff       	call   f01012c1 <mmio_map_region>
f01023ff:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102401:	83 c4 08             	add    $0x8,%esp
f0102404:	68 00 10 00 00       	push   $0x1000
f0102409:	6a 00                	push   $0x0
f010240b:	e8 b1 ee ff ff       	call   f01012c1 <mmio_map_region>
f0102410:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102412:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102418:	83 c4 10             	add    $0x10,%esp
f010241b:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102421:	76 07                	jbe    f010242a <mem_init+0x10fb>
f0102423:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102428:	76 19                	jbe    f0102443 <mem_init+0x1114>
f010242a:	68 18 75 10 f0       	push   $0xf0107518
f010242f:	68 dd 78 10 f0       	push   $0xf01078dd
f0102434:	68 56 04 00 00       	push   $0x456
f0102439:	68 9d 78 10 f0       	push   $0xf010789d
f010243e:	e8 fd db ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102443:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102449:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010244f:	77 08                	ja     f0102459 <mem_init+0x112a>
f0102451:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102457:	77 19                	ja     f0102472 <mem_init+0x1143>
f0102459:	68 40 75 10 f0       	push   $0xf0107540
f010245e:	68 dd 78 10 f0       	push   $0xf01078dd
f0102463:	68 57 04 00 00       	push   $0x457
f0102468:	68 9d 78 10 f0       	push   $0xf010789d
f010246d:	e8 ce db ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102472:	89 da                	mov    %ebx,%edx
f0102474:	09 f2                	or     %esi,%edx
f0102476:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f010247c:	74 19                	je     f0102497 <mem_init+0x1168>
f010247e:	68 68 75 10 f0       	push   $0xf0107568
f0102483:	68 dd 78 10 f0       	push   $0xf01078dd
f0102488:	68 59 04 00 00       	push   $0x459
f010248d:	68 9d 78 10 f0       	push   $0xf010789d
f0102492:	e8 a9 db ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102497:	39 c6                	cmp    %eax,%esi
f0102499:	73 19                	jae    f01024b4 <mem_init+0x1185>
f010249b:	68 6e 7b 10 f0       	push   $0xf0107b6e
f01024a0:	68 dd 78 10 f0       	push   $0xf01078dd
f01024a5:	68 5b 04 00 00       	push   $0x45b
f01024aa:	68 9d 78 10 f0       	push   $0xf010789d
f01024af:	e8 8c db ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01024b4:	8b 3d 9c 1e 2a f0    	mov    0xf02a1e9c,%edi
f01024ba:	89 da                	mov    %ebx,%edx
f01024bc:	89 f8                	mov    %edi,%eax
f01024be:	e8 8e e5 ff ff       	call   f0100a51 <check_va2pa>
f01024c3:	85 c0                	test   %eax,%eax
f01024c5:	74 19                	je     f01024e0 <mem_init+0x11b1>
f01024c7:	68 90 75 10 f0       	push   $0xf0107590
f01024cc:	68 dd 78 10 f0       	push   $0xf01078dd
f01024d1:	68 5d 04 00 00       	push   $0x45d
f01024d6:	68 9d 78 10 f0       	push   $0xf010789d
f01024db:	e8 60 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01024e0:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01024e6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01024e9:	89 c2                	mov    %eax,%edx
f01024eb:	89 f8                	mov    %edi,%eax
f01024ed:	e8 5f e5 ff ff       	call   f0100a51 <check_va2pa>
f01024f2:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01024f7:	74 19                	je     f0102512 <mem_init+0x11e3>
f01024f9:	68 b4 75 10 f0       	push   $0xf01075b4
f01024fe:	68 dd 78 10 f0       	push   $0xf01078dd
f0102503:	68 5e 04 00 00       	push   $0x45e
f0102508:	68 9d 78 10 f0       	push   $0xf010789d
f010250d:	e8 2e db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102512:	89 f2                	mov    %esi,%edx
f0102514:	89 f8                	mov    %edi,%eax
f0102516:	e8 36 e5 ff ff       	call   f0100a51 <check_va2pa>
f010251b:	85 c0                	test   %eax,%eax
f010251d:	74 19                	je     f0102538 <mem_init+0x1209>
f010251f:	68 e4 75 10 f0       	push   $0xf01075e4
f0102524:	68 dd 78 10 f0       	push   $0xf01078dd
f0102529:	68 5f 04 00 00       	push   $0x45f
f010252e:	68 9d 78 10 f0       	push   $0xf010789d
f0102533:	e8 08 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102538:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f010253e:	89 f8                	mov    %edi,%eax
f0102540:	e8 0c e5 ff ff       	call   f0100a51 <check_va2pa>
f0102545:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102548:	74 19                	je     f0102563 <mem_init+0x1234>
f010254a:	68 08 76 10 f0       	push   $0xf0107608
f010254f:	68 dd 78 10 f0       	push   $0xf01078dd
f0102554:	68 60 04 00 00       	push   $0x460
f0102559:	68 9d 78 10 f0       	push   $0xf010789d
f010255e:	e8 dd da ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102563:	83 ec 04             	sub    $0x4,%esp
f0102566:	6a 00                	push   $0x0
f0102568:	53                   	push   %ebx
f0102569:	57                   	push   %edi
f010256a:	e8 56 ea ff ff       	call   f0100fc5 <pgdir_walk>
f010256f:	83 c4 10             	add    $0x10,%esp
f0102572:	f6 00 1a             	testb  $0x1a,(%eax)
f0102575:	75 19                	jne    f0102590 <mem_init+0x1261>
f0102577:	68 34 76 10 f0       	push   $0xf0107634
f010257c:	68 dd 78 10 f0       	push   $0xf01078dd
f0102581:	68 62 04 00 00       	push   $0x462
f0102586:	68 9d 78 10 f0       	push   $0xf010789d
f010258b:	e8 b0 da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102590:	83 ec 04             	sub    $0x4,%esp
f0102593:	6a 00                	push   $0x0
f0102595:	53                   	push   %ebx
f0102596:	ff 35 9c 1e 2a f0    	pushl  0xf02a1e9c
f010259c:	e8 24 ea ff ff       	call   f0100fc5 <pgdir_walk>
f01025a1:	8b 00                	mov    (%eax),%eax
f01025a3:	83 c4 10             	add    $0x10,%esp
f01025a6:	83 e0 04             	and    $0x4,%eax
f01025a9:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01025ac:	74 19                	je     f01025c7 <mem_init+0x1298>
f01025ae:	68 78 76 10 f0       	push   $0xf0107678
f01025b3:	68 dd 78 10 f0       	push   $0xf01078dd
f01025b8:	68 63 04 00 00       	push   $0x463
f01025bd:	68 9d 78 10 f0       	push   $0xf010789d
f01025c2:	e8 79 da ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01025c7:	83 ec 04             	sub    $0x4,%esp
f01025ca:	6a 00                	push   $0x0
f01025cc:	53                   	push   %ebx
f01025cd:	ff 35 9c 1e 2a f0    	pushl  0xf02a1e9c
f01025d3:	e8 ed e9 ff ff       	call   f0100fc5 <pgdir_walk>
f01025d8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01025de:	83 c4 0c             	add    $0xc,%esp
f01025e1:	6a 00                	push   $0x0
f01025e3:	ff 75 d4             	pushl  -0x2c(%ebp)
f01025e6:	ff 35 9c 1e 2a f0    	pushl  0xf02a1e9c
f01025ec:	e8 d4 e9 ff ff       	call   f0100fc5 <pgdir_walk>
f01025f1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01025f7:	83 c4 0c             	add    $0xc,%esp
f01025fa:	6a 00                	push   $0x0
f01025fc:	56                   	push   %esi
f01025fd:	ff 35 9c 1e 2a f0    	pushl  0xf02a1e9c
f0102603:	e8 bd e9 ff ff       	call   f0100fc5 <pgdir_walk>
f0102608:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010260e:	c7 04 24 80 7b 10 f0 	movl   $0xf0107b80,(%esp)
f0102615:	e8 46 10 00 00       	call   f0103660 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	uint32_t size = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
f010261a:	a1 98 1e 2a f0       	mov    0xf02a1e98,%eax
f010261f:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f0102626:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UPAGES, size, PADDR(pages), PTE_U);
f010262c:	a1 a0 1e 2a f0       	mov    0xf02a1ea0,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102631:	83 c4 10             	add    $0x10,%esp
f0102634:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102639:	77 15                	ja     f0102650 <mem_init+0x1321>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010263b:	50                   	push   %eax
f010263c:	68 c8 69 10 f0       	push   $0xf01069c8
f0102641:	68 bf 00 00 00       	push   $0xbf
f0102646:	68 9d 78 10 f0       	push   $0xf010789d
f010264b:	e8 f0 d9 ff ff       	call   f0100040 <_panic>
f0102650:	83 ec 08             	sub    $0x8,%esp
f0102653:	6a 04                	push   $0x4
f0102655:	05 00 00 00 10       	add    $0x10000000,%eax
f010265a:	50                   	push   %eax
f010265b:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102660:	a1 9c 1e 2a f0       	mov    0xf02a1e9c,%eax
f0102665:	e8 45 ea ff ff       	call   f01010af <boot_map_region>
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.

	size = ROUNDUP(NENV * sizeof(struct Env), PGSIZE);
	boot_map_region(kern_pgdir, UENVS, size, PADDR(envs), PTE_U);
f010266a:	a1 48 12 2a f0       	mov    0xf02a1248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010266f:	83 c4 10             	add    $0x10,%esp
f0102672:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102677:	77 15                	ja     f010268e <mem_init+0x135f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102679:	50                   	push   %eax
f010267a:	68 c8 69 10 f0       	push   $0xf01069c8
f010267f:	68 ca 00 00 00       	push   $0xca
f0102684:	68 9d 78 10 f0       	push   $0xf010789d
f0102689:	e8 b2 d9 ff ff       	call   f0100040 <_panic>
f010268e:	83 ec 08             	sub    $0x8,%esp
f0102691:	6a 04                	push   $0x4
f0102693:	05 00 00 00 10       	add    $0x10000000,%eax
f0102698:	50                   	push   %eax
f0102699:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f010269e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01026a3:	a1 9c 1e 2a f0       	mov    0xf02a1e9c,%eax
f01026a8:	e8 02 ea ff ff       	call   f01010af <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026ad:	83 c4 10             	add    $0x10,%esp
f01026b0:	b8 00 90 11 f0       	mov    $0xf0119000,%eax
f01026b5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026ba:	77 15                	ja     f01026d1 <mem_init+0x13a2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026bc:	50                   	push   %eax
f01026bd:	68 c8 69 10 f0       	push   $0xf01069c8
f01026c2:	68 d8 00 00 00       	push   $0xd8
f01026c7:	68 9d 78 10 f0       	push   $0xf010789d
f01026cc:	e8 6f d9 ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	extern char bootstack[];
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01026d1:	83 ec 08             	sub    $0x8,%esp
f01026d4:	6a 02                	push   $0x2
f01026d6:	68 00 90 11 00       	push   $0x119000
f01026db:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01026e0:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01026e5:	a1 9c 1e 2a f0       	mov    0xf02a1e9c,%eax
f01026ea:	e8 c0 e9 ff ff       	call   f01010af <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	size = ((0xFFFFFFFF) - KERNBASE) + 1;
	boot_map_region(kern_pgdir, KERNBASE, size, 0, PTE_W);
f01026ef:	83 c4 08             	add    $0x8,%esp
f01026f2:	6a 02                	push   $0x2
f01026f4:	6a 00                	push   $0x0
f01026f6:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01026fb:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102700:	a1 9c 1e 2a f0       	mov    0xf02a1e9c,%eax
f0102705:	e8 a5 e9 ff ff       	call   f01010af <boot_map_region>
f010270a:	c7 45 c4 00 30 2a f0 	movl   $0xf02a3000,-0x3c(%ebp)
f0102711:	83 c4 10             	add    $0x10,%esp
f0102714:	bb 00 30 2a f0       	mov    $0xf02a3000,%ebx
f0102719:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010271e:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102724:	77 15                	ja     f010273b <mem_init+0x140c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102726:	53                   	push   %ebx
f0102727:	68 c8 69 10 f0       	push   $0xf01069c8
f010272c:	68 1b 01 00 00       	push   $0x11b
f0102731:	68 9d 78 10 f0       	push   $0xf010789d
f0102736:	e8 05 d9 ff ff       	call   f0100040 <_panic>
	uint32_t i;
	for (i = 0; i < NCPU; i++) {
		uintptr_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		uintptr_t kstackbot_i = kstacktop_i - KSTKSIZE;
		physaddr_t kstackpa_i = PADDR(&percpu_kstacks[i]);
		boot_map_region(kern_pgdir, kstackbot_i, KSTKSIZE, kstackpa_i, PTE_W);
f010273b:	83 ec 08             	sub    $0x8,%esp
f010273e:	6a 02                	push   $0x2
f0102740:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102746:	50                   	push   %eax
f0102747:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010274c:	89 f2                	mov    %esi,%edx
f010274e:	a1 9c 1e 2a f0       	mov    0xf02a1e9c,%eax
f0102753:	e8 57 e9 ff ff       	call   f01010af <boot_map_region>
f0102758:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010275e:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	uint32_t i;
	for (i = 0; i < NCPU; i++) {
f0102764:	83 c4 10             	add    $0x10,%esp
f0102767:	b8 00 30 2e f0       	mov    $0xf02e3000,%eax
f010276c:	39 d8                	cmp    %ebx,%eax
f010276e:	75 ae                	jne    f010271e <mem_init+0x13ef>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102770:	8b 3d 9c 1e 2a f0    	mov    0xf02a1e9c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102776:	a1 98 1e 2a f0       	mov    0xf02a1e98,%eax
f010277b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010277e:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102785:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010278a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010278d:	8b 35 a0 1e 2a f0    	mov    0xf02a1ea0,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102793:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102796:	bb 00 00 00 00       	mov    $0x0,%ebx
f010279b:	eb 55                	jmp    f01027f2 <mem_init+0x14c3>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010279d:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01027a3:	89 f8                	mov    %edi,%eax
f01027a5:	e8 a7 e2 ff ff       	call   f0100a51 <check_va2pa>
f01027aa:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01027b1:	77 15                	ja     f01027c8 <mem_init+0x1499>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027b3:	56                   	push   %esi
f01027b4:	68 c8 69 10 f0       	push   $0xf01069c8
f01027b9:	68 7b 03 00 00       	push   $0x37b
f01027be:	68 9d 78 10 f0       	push   $0xf010789d
f01027c3:	e8 78 d8 ff ff       	call   f0100040 <_panic>
f01027c8:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f01027cf:	39 c2                	cmp    %eax,%edx
f01027d1:	74 19                	je     f01027ec <mem_init+0x14bd>
f01027d3:	68 ac 76 10 f0       	push   $0xf01076ac
f01027d8:	68 dd 78 10 f0       	push   $0xf01078dd
f01027dd:	68 7b 03 00 00       	push   $0x37b
f01027e2:	68 9d 78 10 f0       	push   $0xf010789d
f01027e7:	e8 54 d8 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027ec:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01027f2:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01027f5:	77 a6                	ja     f010279d <mem_init+0x146e>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01027f7:	8b 35 48 12 2a f0    	mov    0xf02a1248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027fd:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102800:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102805:	89 da                	mov    %ebx,%edx
f0102807:	89 f8                	mov    %edi,%eax
f0102809:	e8 43 e2 ff ff       	call   f0100a51 <check_va2pa>
f010280e:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102815:	77 15                	ja     f010282c <mem_init+0x14fd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102817:	56                   	push   %esi
f0102818:	68 c8 69 10 f0       	push   $0xf01069c8
f010281d:	68 80 03 00 00       	push   $0x380
f0102822:	68 9d 78 10 f0       	push   $0xf010789d
f0102827:	e8 14 d8 ff ff       	call   f0100040 <_panic>
f010282c:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102833:	39 d0                	cmp    %edx,%eax
f0102835:	74 19                	je     f0102850 <mem_init+0x1521>
f0102837:	68 e0 76 10 f0       	push   $0xf01076e0
f010283c:	68 dd 78 10 f0       	push   $0xf01078dd
f0102841:	68 80 03 00 00       	push   $0x380
f0102846:	68 9d 78 10 f0       	push   $0xf010789d
f010284b:	e8 f0 d7 ff ff       	call   f0100040 <_panic>
f0102850:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102856:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f010285c:	75 a7                	jne    f0102805 <mem_init+0x14d6>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010285e:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102861:	c1 e6 0c             	shl    $0xc,%esi
f0102864:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102869:	eb 30                	jmp    f010289b <mem_init+0x156c>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010286b:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102871:	89 f8                	mov    %edi,%eax
f0102873:	e8 d9 e1 ff ff       	call   f0100a51 <check_va2pa>
f0102878:	39 c3                	cmp    %eax,%ebx
f010287a:	74 19                	je     f0102895 <mem_init+0x1566>
f010287c:	68 14 77 10 f0       	push   $0xf0107714
f0102881:	68 dd 78 10 f0       	push   $0xf01078dd
f0102886:	68 84 03 00 00       	push   $0x384
f010288b:	68 9d 78 10 f0       	push   $0xf010789d
f0102890:	e8 ab d7 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102895:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010289b:	39 f3                	cmp    %esi,%ebx
f010289d:	72 cc                	jb     f010286b <mem_init+0x153c>
f010289f:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01028a4:	89 75 cc             	mov    %esi,-0x34(%ebp)
f01028a7:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01028aa:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01028ad:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f01028b3:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01028b6:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01028b8:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01028bb:	05 00 80 00 20       	add    $0x20008000,%eax
f01028c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01028c3:	89 da                	mov    %ebx,%edx
f01028c5:	89 f8                	mov    %edi,%eax
f01028c7:	e8 85 e1 ff ff       	call   f0100a51 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028cc:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01028d2:	77 15                	ja     f01028e9 <mem_init+0x15ba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028d4:	56                   	push   %esi
f01028d5:	68 c8 69 10 f0       	push   $0xf01069c8
f01028da:	68 8c 03 00 00       	push   $0x38c
f01028df:	68 9d 78 10 f0       	push   $0xf010789d
f01028e4:	e8 57 d7 ff ff       	call   f0100040 <_panic>
f01028e9:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01028ec:	8d 94 0b 00 30 2a f0 	lea    -0xfd5d000(%ebx,%ecx,1),%edx
f01028f3:	39 d0                	cmp    %edx,%eax
f01028f5:	74 19                	je     f0102910 <mem_init+0x15e1>
f01028f7:	68 3c 77 10 f0       	push   $0xf010773c
f01028fc:	68 dd 78 10 f0       	push   $0xf01078dd
f0102901:	68 8c 03 00 00       	push   $0x38c
f0102906:	68 9d 78 10 f0       	push   $0xf010789d
f010290b:	e8 30 d7 ff ff       	call   f0100040 <_panic>
f0102910:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102916:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102919:	75 a8                	jne    f01028c3 <mem_init+0x1594>
f010291b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010291e:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102924:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102927:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102929:	89 da                	mov    %ebx,%edx
f010292b:	89 f8                	mov    %edi,%eax
f010292d:	e8 1f e1 ff ff       	call   f0100a51 <check_va2pa>
f0102932:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102935:	74 19                	je     f0102950 <mem_init+0x1621>
f0102937:	68 84 77 10 f0       	push   $0xf0107784
f010293c:	68 dd 78 10 f0       	push   $0xf01078dd
f0102941:	68 8e 03 00 00       	push   $0x38e
f0102946:	68 9d 78 10 f0       	push   $0xf010789d
f010294b:	e8 f0 d6 ff ff       	call   f0100040 <_panic>
f0102950:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102956:	39 de                	cmp    %ebx,%esi
f0102958:	75 cf                	jne    f0102929 <mem_init+0x15fa>
f010295a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010295d:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102964:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f010296b:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102971:	81 fe 00 30 2e f0    	cmp    $0xf02e3000,%esi
f0102977:	0f 85 2d ff ff ff    	jne    f01028aa <mem_init+0x157b>
f010297d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102982:	eb 2a                	jmp    f01029ae <mem_init+0x167f>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102984:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f010298a:	83 fa 04             	cmp    $0x4,%edx
f010298d:	77 1f                	ja     f01029ae <mem_init+0x167f>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f010298f:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102993:	75 7e                	jne    f0102a13 <mem_init+0x16e4>
f0102995:	68 99 7b 10 f0       	push   $0xf0107b99
f010299a:	68 dd 78 10 f0       	push   $0xf01078dd
f010299f:	68 99 03 00 00       	push   $0x399
f01029a4:	68 9d 78 10 f0       	push   $0xf010789d
f01029a9:	e8 92 d6 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01029ae:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01029b3:	76 3f                	jbe    f01029f4 <mem_init+0x16c5>
				assert(pgdir[i] & PTE_P);
f01029b5:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01029b8:	f6 c2 01             	test   $0x1,%dl
f01029bb:	75 19                	jne    f01029d6 <mem_init+0x16a7>
f01029bd:	68 99 7b 10 f0       	push   $0xf0107b99
f01029c2:	68 dd 78 10 f0       	push   $0xf01078dd
f01029c7:	68 9d 03 00 00       	push   $0x39d
f01029cc:	68 9d 78 10 f0       	push   $0xf010789d
f01029d1:	e8 6a d6 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01029d6:	f6 c2 02             	test   $0x2,%dl
f01029d9:	75 38                	jne    f0102a13 <mem_init+0x16e4>
f01029db:	68 aa 7b 10 f0       	push   $0xf0107baa
f01029e0:	68 dd 78 10 f0       	push   $0xf01078dd
f01029e5:	68 9e 03 00 00       	push   $0x39e
f01029ea:	68 9d 78 10 f0       	push   $0xf010789d
f01029ef:	e8 4c d6 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f01029f4:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01029f8:	74 19                	je     f0102a13 <mem_init+0x16e4>
f01029fa:	68 bb 7b 10 f0       	push   $0xf0107bbb
f01029ff:	68 dd 78 10 f0       	push   $0xf01078dd
f0102a04:	68 a0 03 00 00       	push   $0x3a0
f0102a09:	68 9d 78 10 f0       	push   $0xf010789d
f0102a0e:	e8 2d d6 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102a13:	83 c0 01             	add    $0x1,%eax
f0102a16:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102a1b:	0f 86 63 ff ff ff    	jbe    f0102984 <mem_init+0x1655>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102a21:	83 ec 0c             	sub    $0xc,%esp
f0102a24:	68 a8 77 10 f0       	push   $0xf01077a8
f0102a29:	e8 32 0c 00 00       	call   f0103660 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102a2e:	a1 9c 1e 2a f0       	mov    0xf02a1e9c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a33:	83 c4 10             	add    $0x10,%esp
f0102a36:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a3b:	77 15                	ja     f0102a52 <mem_init+0x1723>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a3d:	50                   	push   %eax
f0102a3e:	68 c8 69 10 f0       	push   $0xf01069c8
f0102a43:	68 f2 00 00 00       	push   $0xf2
f0102a48:	68 9d 78 10 f0       	push   $0xf010789d
f0102a4d:	e8 ee d5 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102a52:	05 00 00 00 10       	add    $0x10000000,%eax
f0102a57:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102a5a:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a5f:	e8 d5 e0 ff ff       	call   f0100b39 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102a64:	0f 20 c0             	mov    %cr0,%eax
f0102a67:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102a6a:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102a6f:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102a72:	83 ec 0c             	sub    $0xc,%esp
f0102a75:	6a 00                	push   $0x0
f0102a77:	e8 77 e4 ff ff       	call   f0100ef3 <page_alloc>
f0102a7c:	89 c3                	mov    %eax,%ebx
f0102a7e:	83 c4 10             	add    $0x10,%esp
f0102a81:	85 c0                	test   %eax,%eax
f0102a83:	75 19                	jne    f0102a9e <mem_init+0x176f>
f0102a85:	68 a5 79 10 f0       	push   $0xf01079a5
f0102a8a:	68 dd 78 10 f0       	push   $0xf01078dd
f0102a8f:	68 78 04 00 00       	push   $0x478
f0102a94:	68 9d 78 10 f0       	push   $0xf010789d
f0102a99:	e8 a2 d5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102a9e:	83 ec 0c             	sub    $0xc,%esp
f0102aa1:	6a 00                	push   $0x0
f0102aa3:	e8 4b e4 ff ff       	call   f0100ef3 <page_alloc>
f0102aa8:	89 c7                	mov    %eax,%edi
f0102aaa:	83 c4 10             	add    $0x10,%esp
f0102aad:	85 c0                	test   %eax,%eax
f0102aaf:	75 19                	jne    f0102aca <mem_init+0x179b>
f0102ab1:	68 bb 79 10 f0       	push   $0xf01079bb
f0102ab6:	68 dd 78 10 f0       	push   $0xf01078dd
f0102abb:	68 79 04 00 00       	push   $0x479
f0102ac0:	68 9d 78 10 f0       	push   $0xf010789d
f0102ac5:	e8 76 d5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102aca:	83 ec 0c             	sub    $0xc,%esp
f0102acd:	6a 00                	push   $0x0
f0102acf:	e8 1f e4 ff ff       	call   f0100ef3 <page_alloc>
f0102ad4:	89 c6                	mov    %eax,%esi
f0102ad6:	83 c4 10             	add    $0x10,%esp
f0102ad9:	85 c0                	test   %eax,%eax
f0102adb:	75 19                	jne    f0102af6 <mem_init+0x17c7>
f0102add:	68 d1 79 10 f0       	push   $0xf01079d1
f0102ae2:	68 dd 78 10 f0       	push   $0xf01078dd
f0102ae7:	68 7a 04 00 00       	push   $0x47a
f0102aec:	68 9d 78 10 f0       	push   $0xf010789d
f0102af1:	e8 4a d5 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102af6:	83 ec 0c             	sub    $0xc,%esp
f0102af9:	53                   	push   %ebx
f0102afa:	e8 64 e4 ff ff       	call   f0100f63 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102aff:	89 f8                	mov    %edi,%eax
f0102b01:	2b 05 a0 1e 2a f0    	sub    0xf02a1ea0,%eax
f0102b07:	c1 f8 03             	sar    $0x3,%eax
f0102b0a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b0d:	89 c2                	mov    %eax,%edx
f0102b0f:	c1 ea 0c             	shr    $0xc,%edx
f0102b12:	83 c4 10             	add    $0x10,%esp
f0102b15:	3b 15 98 1e 2a f0    	cmp    0xf02a1e98,%edx
f0102b1b:	72 12                	jb     f0102b2f <mem_init+0x1800>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b1d:	50                   	push   %eax
f0102b1e:	68 a4 69 10 f0       	push   $0xf01069a4
f0102b23:	6a 58                	push   $0x58
f0102b25:	68 c3 78 10 f0       	push   $0xf01078c3
f0102b2a:	e8 11 d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102b2f:	83 ec 04             	sub    $0x4,%esp
f0102b32:	68 00 10 00 00       	push   $0x1000
f0102b37:	6a 01                	push   $0x1
f0102b39:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b3e:	50                   	push   %eax
f0102b3f:	e8 9e 26 00 00       	call   f01051e2 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b44:	89 f0                	mov    %esi,%eax
f0102b46:	2b 05 a0 1e 2a f0    	sub    0xf02a1ea0,%eax
f0102b4c:	c1 f8 03             	sar    $0x3,%eax
f0102b4f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b52:	89 c2                	mov    %eax,%edx
f0102b54:	c1 ea 0c             	shr    $0xc,%edx
f0102b57:	83 c4 10             	add    $0x10,%esp
f0102b5a:	3b 15 98 1e 2a f0    	cmp    0xf02a1e98,%edx
f0102b60:	72 12                	jb     f0102b74 <mem_init+0x1845>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b62:	50                   	push   %eax
f0102b63:	68 a4 69 10 f0       	push   $0xf01069a4
f0102b68:	6a 58                	push   $0x58
f0102b6a:	68 c3 78 10 f0       	push   $0xf01078c3
f0102b6f:	e8 cc d4 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102b74:	83 ec 04             	sub    $0x4,%esp
f0102b77:	68 00 10 00 00       	push   $0x1000
f0102b7c:	6a 02                	push   $0x2
f0102b7e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b83:	50                   	push   %eax
f0102b84:	e8 59 26 00 00       	call   f01051e2 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102b89:	6a 02                	push   $0x2
f0102b8b:	68 00 10 00 00       	push   $0x1000
f0102b90:	57                   	push   %edi
f0102b91:	ff 35 9c 1e 2a f0    	pushl  0xf02a1e9c
f0102b97:	e8 95 e6 ff ff       	call   f0101231 <page_insert>
	assert(pp1->pp_ref == 1);
f0102b9c:	83 c4 20             	add    $0x20,%esp
f0102b9f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102ba4:	74 19                	je     f0102bbf <mem_init+0x1890>
f0102ba6:	68 a2 7a 10 f0       	push   $0xf0107aa2
f0102bab:	68 dd 78 10 f0       	push   $0xf01078dd
f0102bb0:	68 7f 04 00 00       	push   $0x47f
f0102bb5:	68 9d 78 10 f0       	push   $0xf010789d
f0102bba:	e8 81 d4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102bbf:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102bc6:	01 01 01 
f0102bc9:	74 19                	je     f0102be4 <mem_init+0x18b5>
f0102bcb:	68 c8 77 10 f0       	push   $0xf01077c8
f0102bd0:	68 dd 78 10 f0       	push   $0xf01078dd
f0102bd5:	68 80 04 00 00       	push   $0x480
f0102bda:	68 9d 78 10 f0       	push   $0xf010789d
f0102bdf:	e8 5c d4 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102be4:	6a 02                	push   $0x2
f0102be6:	68 00 10 00 00       	push   $0x1000
f0102beb:	56                   	push   %esi
f0102bec:	ff 35 9c 1e 2a f0    	pushl  0xf02a1e9c
f0102bf2:	e8 3a e6 ff ff       	call   f0101231 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102bf7:	83 c4 10             	add    $0x10,%esp
f0102bfa:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c01:	02 02 02 
f0102c04:	74 19                	je     f0102c1f <mem_init+0x18f0>
f0102c06:	68 ec 77 10 f0       	push   $0xf01077ec
f0102c0b:	68 dd 78 10 f0       	push   $0xf01078dd
f0102c10:	68 82 04 00 00       	push   $0x482
f0102c15:	68 9d 78 10 f0       	push   $0xf010789d
f0102c1a:	e8 21 d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102c1f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c24:	74 19                	je     f0102c3f <mem_init+0x1910>
f0102c26:	68 c4 7a 10 f0       	push   $0xf0107ac4
f0102c2b:	68 dd 78 10 f0       	push   $0xf01078dd
f0102c30:	68 83 04 00 00       	push   $0x483
f0102c35:	68 9d 78 10 f0       	push   $0xf010789d
f0102c3a:	e8 01 d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102c3f:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c44:	74 19                	je     f0102c5f <mem_init+0x1930>
f0102c46:	68 2e 7b 10 f0       	push   $0xf0107b2e
f0102c4b:	68 dd 78 10 f0       	push   $0xf01078dd
f0102c50:	68 84 04 00 00       	push   $0x484
f0102c55:	68 9d 78 10 f0       	push   $0xf010789d
f0102c5a:	e8 e1 d3 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c5f:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c66:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c69:	89 f0                	mov    %esi,%eax
f0102c6b:	2b 05 a0 1e 2a f0    	sub    0xf02a1ea0,%eax
f0102c71:	c1 f8 03             	sar    $0x3,%eax
f0102c74:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c77:	89 c2                	mov    %eax,%edx
f0102c79:	c1 ea 0c             	shr    $0xc,%edx
f0102c7c:	3b 15 98 1e 2a f0    	cmp    0xf02a1e98,%edx
f0102c82:	72 12                	jb     f0102c96 <mem_init+0x1967>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c84:	50                   	push   %eax
f0102c85:	68 a4 69 10 f0       	push   $0xf01069a4
f0102c8a:	6a 58                	push   $0x58
f0102c8c:	68 c3 78 10 f0       	push   $0xf01078c3
f0102c91:	e8 aa d3 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c96:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c9d:	03 03 03 
f0102ca0:	74 19                	je     f0102cbb <mem_init+0x198c>
f0102ca2:	68 10 78 10 f0       	push   $0xf0107810
f0102ca7:	68 dd 78 10 f0       	push   $0xf01078dd
f0102cac:	68 86 04 00 00       	push   $0x486
f0102cb1:	68 9d 78 10 f0       	push   $0xf010789d
f0102cb6:	e8 85 d3 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102cbb:	83 ec 08             	sub    $0x8,%esp
f0102cbe:	68 00 10 00 00       	push   $0x1000
f0102cc3:	ff 35 9c 1e 2a f0    	pushl  0xf02a1e9c
f0102cc9:	e8 1d e5 ff ff       	call   f01011eb <page_remove>
	assert(pp2->pp_ref == 0);
f0102cce:	83 c4 10             	add    $0x10,%esp
f0102cd1:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102cd6:	74 19                	je     f0102cf1 <mem_init+0x19c2>
f0102cd8:	68 fc 7a 10 f0       	push   $0xf0107afc
f0102cdd:	68 dd 78 10 f0       	push   $0xf01078dd
f0102ce2:	68 88 04 00 00       	push   $0x488
f0102ce7:	68 9d 78 10 f0       	push   $0xf010789d
f0102cec:	e8 4f d3 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102cf1:	8b 0d 9c 1e 2a f0    	mov    0xf02a1e9c,%ecx
f0102cf7:	8b 11                	mov    (%ecx),%edx
f0102cf9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102cff:	89 d8                	mov    %ebx,%eax
f0102d01:	2b 05 a0 1e 2a f0    	sub    0xf02a1ea0,%eax
f0102d07:	c1 f8 03             	sar    $0x3,%eax
f0102d0a:	c1 e0 0c             	shl    $0xc,%eax
f0102d0d:	39 c2                	cmp    %eax,%edx
f0102d0f:	74 19                	je     f0102d2a <mem_init+0x19fb>
f0102d11:	68 98 71 10 f0       	push   $0xf0107198
f0102d16:	68 dd 78 10 f0       	push   $0xf01078dd
f0102d1b:	68 8b 04 00 00       	push   $0x48b
f0102d20:	68 9d 78 10 f0       	push   $0xf010789d
f0102d25:	e8 16 d3 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102d2a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d30:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102d35:	74 19                	je     f0102d50 <mem_init+0x1a21>
f0102d37:	68 b3 7a 10 f0       	push   $0xf0107ab3
f0102d3c:	68 dd 78 10 f0       	push   $0xf01078dd
f0102d41:	68 8d 04 00 00       	push   $0x48d
f0102d46:	68 9d 78 10 f0       	push   $0xf010789d
f0102d4b:	e8 f0 d2 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102d50:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102d56:	83 ec 0c             	sub    $0xc,%esp
f0102d59:	53                   	push   %ebx
f0102d5a:	e8 04 e2 ff ff       	call   f0100f63 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d5f:	c7 04 24 3c 78 10 f0 	movl   $0xf010783c,(%esp)
f0102d66:	e8 f5 08 00 00       	call   f0103660 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102d6b:	83 c4 10             	add    $0x10,%esp
f0102d6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d71:	5b                   	pop    %ebx
f0102d72:	5e                   	pop    %esi
f0102d73:	5f                   	pop    %edi
f0102d74:	5d                   	pop    %ebp
f0102d75:	c3                   	ret    

f0102d76 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102d76:	55                   	push   %ebp
f0102d77:	89 e5                	mov    %esp,%ebp
f0102d79:	57                   	push   %edi
f0102d7a:	56                   	push   %esi
f0102d7b:	53                   	push   %ebx
f0102d7c:	83 ec 1c             	sub    $0x1c,%esp
f0102d7f:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	uint32_t addr = ROUNDDOWN((uint32_t) va, PGSIZE);
f0102d82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102d85:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t last = ROUNDDOWN((uint32_t) (va+len), PGSIZE);
f0102d8b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d8e:	03 45 10             	add    0x10(%ebp),%eax
f0102d91:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102d96:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			}
			return -E_FAULT;
		}
		// Second check
		pte_t *pte = pgdir_walk(env->env_pgdir, (void *) addr, 0);
		if (!pte || !(*pte & (perm | PTE_P))) {
f0102d99:	8b 75 14             	mov    0x14(%ebp),%esi
f0102d9c:	83 ce 01             	or     $0x1,%esi
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	uint32_t addr = ROUNDDOWN((uint32_t) va, PGSIZE);
	uint32_t last = ROUNDDOWN((uint32_t) (va+len), PGSIZE);
	while (addr <= last) {
f0102d9f:	eb 69                	jmp    f0102e0a <user_mem_check+0x94>
		// TODO: Avoid repeating block of code
		// First check
		if (addr >= ULIM) {
f0102da1:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102da7:	76 21                	jbe    f0102dca <user_mem_check+0x54>
			if (addr < (uint32_t) va) {
f0102da9:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102dac:	73 0f                	jae    f0102dbd <user_mem_check+0x47>
				user_mem_check_addr = (uint32_t) va;
f0102dae:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102db1:	a3 3c 12 2a f0       	mov    %eax,0xf02a123c
			} else {
				user_mem_check_addr = addr;
			}
			return -E_FAULT;
f0102db6:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102dbb:	eb 57                	jmp    f0102e14 <user_mem_check+0x9e>
		// First check
		if (addr >= ULIM) {
			if (addr < (uint32_t) va) {
				user_mem_check_addr = (uint32_t) va;
			} else {
				user_mem_check_addr = addr;
f0102dbd:	89 1d 3c 12 2a f0    	mov    %ebx,0xf02a123c
			}
			return -E_FAULT;
f0102dc3:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102dc8:	eb 4a                	jmp    f0102e14 <user_mem_check+0x9e>
		}
		// Second check
		pte_t *pte = pgdir_walk(env->env_pgdir, (void *) addr, 0);
f0102dca:	83 ec 04             	sub    $0x4,%esp
f0102dcd:	6a 00                	push   $0x0
f0102dcf:	53                   	push   %ebx
f0102dd0:	ff 77 60             	pushl  0x60(%edi)
f0102dd3:	e8 ed e1 ff ff       	call   f0100fc5 <pgdir_walk>
		if (!pte || !(*pte & (perm | PTE_P))) {
f0102dd8:	83 c4 10             	add    $0x10,%esp
f0102ddb:	85 c0                	test   %eax,%eax
f0102ddd:	74 04                	je     f0102de3 <user_mem_check+0x6d>
f0102ddf:	85 30                	test   %esi,(%eax)
f0102de1:	75 21                	jne    f0102e04 <user_mem_check+0x8e>
			if (addr < (uint32_t) va) {
f0102de3:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102de6:	73 0f                	jae    f0102df7 <user_mem_check+0x81>
				user_mem_check_addr = (uint32_t) va;
f0102de8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102deb:	a3 3c 12 2a f0       	mov    %eax,0xf02a123c
			} else {
				user_mem_check_addr = addr;
			}
			return -E_FAULT;
f0102df0:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102df5:	eb 1d                	jmp    f0102e14 <user_mem_check+0x9e>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void *) addr, 0);
		if (!pte || !(*pte & (perm | PTE_P))) {
			if (addr < (uint32_t) va) {
				user_mem_check_addr = (uint32_t) va;
			} else {
				user_mem_check_addr = addr;
f0102df7:	89 1d 3c 12 2a f0    	mov    %ebx,0xf02a123c
			}
			return -E_FAULT;
f0102dfd:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102e02:	eb 10                	jmp    f0102e14 <user_mem_check+0x9e>
		}
		addr += PGSIZE;
f0102e04:	81 c3 00 10 00 00    	add    $0x1000,%ebx
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	uint32_t addr = ROUNDDOWN((uint32_t) va, PGSIZE);
	uint32_t last = ROUNDDOWN((uint32_t) (va+len), PGSIZE);
	while (addr <= last) {
f0102e0a:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102e0d:	76 92                	jbe    f0102da1 <user_mem_check+0x2b>
			return -E_FAULT;
		}
		addr += PGSIZE;

	}
	return 0;
f0102e0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102e14:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e17:	5b                   	pop    %ebx
f0102e18:	5e                   	pop    %esi
f0102e19:	5f                   	pop    %edi
f0102e1a:	5d                   	pop    %ebp
f0102e1b:	c3                   	ret    

f0102e1c <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102e1c:	55                   	push   %ebp
f0102e1d:	89 e5                	mov    %esp,%ebp
f0102e1f:	53                   	push   %ebx
f0102e20:	83 ec 04             	sub    $0x4,%esp
f0102e23:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102e26:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e29:	83 c8 04             	or     $0x4,%eax
f0102e2c:	50                   	push   %eax
f0102e2d:	ff 75 10             	pushl  0x10(%ebp)
f0102e30:	ff 75 0c             	pushl  0xc(%ebp)
f0102e33:	53                   	push   %ebx
f0102e34:	e8 3d ff ff ff       	call   f0102d76 <user_mem_check>
f0102e39:	83 c4 10             	add    $0x10,%esp
f0102e3c:	85 c0                	test   %eax,%eax
f0102e3e:	79 21                	jns    f0102e61 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102e40:	83 ec 04             	sub    $0x4,%esp
f0102e43:	ff 35 3c 12 2a f0    	pushl  0xf02a123c
f0102e49:	ff 73 48             	pushl  0x48(%ebx)
f0102e4c:	68 68 78 10 f0       	push   $0xf0107868
f0102e51:	e8 0a 08 00 00       	call   f0103660 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102e56:	89 1c 24             	mov    %ebx,(%esp)
f0102e59:	e8 33 05 00 00       	call   f0103391 <env_destroy>
f0102e5e:	83 c4 10             	add    $0x10,%esp
	}
}
f0102e61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102e64:	c9                   	leave  
f0102e65:	c3                   	ret    

f0102e66 <region_alloc>:
// Panic if any allocation attempt fails.
//
/** ATTENTION: This function does not cover the case where there are overlaps! **/
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102e66:	55                   	push   %ebp
f0102e67:	89 e5                	mov    %esp,%ebp
f0102e69:	57                   	push   %edi
f0102e6a:	56                   	push   %esi
f0102e6b:	53                   	push   %ebx
f0102e6c:	83 ec 1c             	sub    $0x1c,%esp
f0102e6f:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	uintptr_t va_start = ROUNDDOWN((uintptr_t) va, PGSIZE);
f0102e71:	89 d6                	mov    %edx,%esi
f0102e73:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	uintptr_t va_end = ROUNDUP(((uintptr_t) va) + len, PGSIZE);
f0102e79:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax

	uint32_t n = (va_end - va_start)/PGSIZE;
f0102e80:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102e85:	29 f0                	sub    %esi,%eax
f0102e87:	c1 e8 0c             	shr    $0xc,%eax
f0102e8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t i;
	uint32_t va_current = va_start;
	for (i = 0; i < n; i++) {
f0102e8d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102e92:	eb 22                	jmp    f0102eb6 <region_alloc+0x50>
		struct PageInfo *pp = page_alloc(ALLOC_ZERO); // Clear page
f0102e94:	83 ec 0c             	sub    $0xc,%esp
f0102e97:	6a 01                	push   $0x1
f0102e99:	e8 55 e0 ff ff       	call   f0100ef3 <page_alloc>
		page_insert(e->env_pgdir, pp, (void *) va_current, PTE_U | PTE_W);
f0102e9e:	6a 06                	push   $0x6
f0102ea0:	56                   	push   %esi
f0102ea1:	50                   	push   %eax
f0102ea2:	ff 77 60             	pushl  0x60(%edi)
f0102ea5:	e8 87 e3 ff ff       	call   f0101231 <page_insert>
		va_current += PGSIZE;
f0102eaa:	81 c6 00 10 00 00    	add    $0x1000,%esi
	uintptr_t va_end = ROUNDUP(((uintptr_t) va) + len, PGSIZE);

	uint32_t n = (va_end - va_start)/PGSIZE;
	uint32_t i;
	uint32_t va_current = va_start;
	for (i = 0; i < n; i++) {
f0102eb0:	83 c3 01             	add    $0x1,%ebx
f0102eb3:	83 c4 20             	add    $0x20,%esp
f0102eb6:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102eb9:	75 d9                	jne    f0102e94 <region_alloc+0x2e>
		struct PageInfo *pp = page_alloc(ALLOC_ZERO); // Clear page
		page_insert(e->env_pgdir, pp, (void *) va_current, PTE_U | PTE_W);
		va_current += PGSIZE;
	}
}
f0102ebb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ebe:	5b                   	pop    %ebx
f0102ebf:	5e                   	pop    %esi
f0102ec0:	5f                   	pop    %edi
f0102ec1:	5d                   	pop    %ebp
f0102ec2:	c3                   	ret    

f0102ec3 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102ec3:	55                   	push   %ebp
f0102ec4:	89 e5                	mov    %esp,%ebp
f0102ec6:	56                   	push   %esi
f0102ec7:	53                   	push   %ebx
f0102ec8:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ecb:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102ece:	85 c0                	test   %eax,%eax
f0102ed0:	75 1a                	jne    f0102eec <envid2env+0x29>
		*env_store = curenv;
f0102ed2:	e8 2b 29 00 00       	call   f0105802 <cpunum>
f0102ed7:	6b c0 74             	imul   $0x74,%eax,%eax
f0102eda:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f0102ee0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102ee3:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102ee5:	b8 00 00 00 00       	mov    $0x0,%eax
f0102eea:	eb 70                	jmp    f0102f5c <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102eec:	89 c3                	mov    %eax,%ebx
f0102eee:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102ef4:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102ef7:	03 1d 48 12 2a f0    	add    0xf02a1248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102efd:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102f01:	74 05                	je     f0102f08 <envid2env+0x45>
f0102f03:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102f06:	74 10                	je     f0102f18 <envid2env+0x55>
		*env_store = 0;
f0102f08:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f0b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102f11:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102f16:	eb 44                	jmp    f0102f5c <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102f18:	84 d2                	test   %dl,%dl
f0102f1a:	74 36                	je     f0102f52 <envid2env+0x8f>
f0102f1c:	e8 e1 28 00 00       	call   f0105802 <cpunum>
f0102f21:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f24:	3b 98 28 20 2a f0    	cmp    -0xfd5dfd8(%eax),%ebx
f0102f2a:	74 26                	je     f0102f52 <envid2env+0x8f>
f0102f2c:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102f2f:	e8 ce 28 00 00       	call   f0105802 <cpunum>
f0102f34:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f37:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f0102f3d:	3b 70 48             	cmp    0x48(%eax),%esi
f0102f40:	74 10                	je     f0102f52 <envid2env+0x8f>
		*env_store = 0;
f0102f42:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f45:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102f4b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102f50:	eb 0a                	jmp    f0102f5c <envid2env+0x99>
	}

	*env_store = e;
f0102f52:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f55:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102f57:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102f5c:	5b                   	pop    %ebx
f0102f5d:	5e                   	pop    %esi
f0102f5e:	5d                   	pop    %ebp
f0102f5f:	c3                   	ret    

f0102f60 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102f60:	55                   	push   %ebp
f0102f61:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102f63:	b8 20 33 12 f0       	mov    $0xf0123320,%eax
f0102f68:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102f6b:	b8 23 00 00 00       	mov    $0x23,%eax
f0102f70:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102f72:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102f74:	b8 10 00 00 00       	mov    $0x10,%eax
f0102f79:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102f7b:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102f7d:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102f7f:	ea 86 2f 10 f0 08 00 	ljmp   $0x8,$0xf0102f86
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102f86:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f8b:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102f8e:	5d                   	pop    %ebp
f0102f8f:	c3                   	ret    

f0102f90 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102f90:	55                   	push   %ebp
f0102f91:	89 e5                	mov    %esp,%ebp
f0102f93:	56                   	push   %esi
f0102f94:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV-1; i >= 0; i--) {
		envs[i].env_id = 0;
f0102f95:	8b 35 48 12 2a f0    	mov    0xf02a1248,%esi
f0102f9b:	8b 15 4c 12 2a f0    	mov    0xf02a124c,%edx
f0102fa1:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102fa7:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102faa:	89 c1                	mov    %eax,%ecx
f0102fac:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)

		envs[i].env_link = env_free_list;
f0102fb3:	89 50 44             	mov    %edx,0x44(%eax)
		env_free_list = &envs[i];

		envs[i].env_pgdir = NULL;
f0102fb6:	c7 40 60 00 00 00 00 	movl   $0x0,0x60(%eax)
f0102fbd:	83 e8 7c             	sub    $0x7c,%eax
	int i;
	for (i = NENV-1; i >= 0; i--) {
		envs[i].env_id = 0;

		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f0102fc0:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV-1; i >= 0; i--) {
f0102fc2:	39 d8                	cmp    %ebx,%eax
f0102fc4:	75 e4                	jne    f0102faa <env_init+0x1a>
f0102fc6:	89 35 4c 12 2a f0    	mov    %esi,0xf02a124c
		env_free_list = &envs[i];

		envs[i].env_pgdir = NULL;
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0102fcc:	e8 8f ff ff ff       	call   f0102f60 <env_init_percpu>
}
f0102fd1:	5b                   	pop    %ebx
f0102fd2:	5e                   	pop    %esi
f0102fd3:	5d                   	pop    %ebp
f0102fd4:	c3                   	ret    

f0102fd5 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102fd5:	55                   	push   %ebp
f0102fd6:	89 e5                	mov    %esp,%ebp
f0102fd8:	53                   	push   %ebx
f0102fd9:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102fdc:	8b 1d 4c 12 2a f0    	mov    0xf02a124c,%ebx
f0102fe2:	85 db                	test   %ebx,%ebx
f0102fe4:	0f 84 34 01 00 00    	je     f010311e <env_alloc+0x149>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102fea:	83 ec 0c             	sub    $0xc,%esp
f0102fed:	6a 01                	push   $0x1
f0102fef:	e8 ff de ff ff       	call   f0100ef3 <page_alloc>
f0102ff4:	83 c4 10             	add    $0x10,%esp
f0102ff7:	85 c0                	test   %eax,%eax
f0102ff9:	0f 84 26 01 00 00    	je     f0103125 <env_alloc+0x150>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref += 1; // TODO: Why?
f0102fff:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103004:	2b 05 a0 1e 2a f0    	sub    0xf02a1ea0,%eax
f010300a:	c1 f8 03             	sar    $0x3,%eax
f010300d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103010:	89 c2                	mov    %eax,%edx
f0103012:	c1 ea 0c             	shr    $0xc,%edx
f0103015:	3b 15 98 1e 2a f0    	cmp    0xf02a1e98,%edx
f010301b:	72 12                	jb     f010302f <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010301d:	50                   	push   %eax
f010301e:	68 a4 69 10 f0       	push   $0xf01069a4
f0103023:	6a 58                	push   $0x58
f0103025:	68 c3 78 10 f0       	push   $0xf01078c3
f010302a:	e8 11 d0 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = page2kva(p);
f010302f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103034:	89 43 60             	mov    %eax,0x60(%ebx)
f0103037:	b8 ec 0e 00 00       	mov    $0xeec,%eax

	// Needs to map everything above UTOP: pages, envs, kernel stack
	// and all physical memory
	// More elegant way: just copy. Less elegant: map with boot_map_region...
	for (i = PDX(UTOP); i < NPDENTRIES; i++) {
		e->env_pgdir[i] = kern_pgdir[i];
f010303c:	8b 15 9c 1e 2a f0    	mov    0xf02a1e9c,%edx
f0103042:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0103045:	8b 53 60             	mov    0x60(%ebx),%edx
f0103048:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f010304b:	83 c0 04             	add    $0x4,%eax
	e->env_pgdir = page2kva(p);

	// Needs to map everything above UTOP: pages, envs, kernel stack
	// and all physical memory
	// More elegant way: just copy. Less elegant: map with boot_map_region...
	for (i = PDX(UTOP); i < NPDENTRIES; i++) {
f010304e:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103053:	75 e7                	jne    f010303c <env_alloc+0x67>
		e->env_pgdir[i] = kern_pgdir[i];
	}

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103055:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103058:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010305d:	77 15                	ja     f0103074 <env_alloc+0x9f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010305f:	50                   	push   %eax
f0103060:	68 c8 69 10 f0       	push   $0xf01069c8
f0103065:	68 cd 00 00 00       	push   $0xcd
f010306a:	68 c9 7b 10 f0       	push   $0xf0107bc9
f010306f:	e8 cc cf ff ff       	call   f0100040 <_panic>
f0103074:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010307a:	83 ca 05             	or     $0x5,%edx
f010307d:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103083:	8b 43 48             	mov    0x48(%ebx),%eax
f0103086:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010308b:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103090:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103095:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103098:	89 da                	mov    %ebx,%edx
f010309a:	2b 15 48 12 2a f0    	sub    0xf02a1248,%edx
f01030a0:	c1 fa 02             	sar    $0x2,%edx
f01030a3:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01030a9:	09 d0                	or     %edx,%eax
f01030ab:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01030ae:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030b1:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01030b4:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01030bb:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01030c2:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01030c9:	83 ec 04             	sub    $0x4,%esp
f01030cc:	6a 44                	push   $0x44
f01030ce:	6a 00                	push   $0x0
f01030d0:	53                   	push   %ebx
f01030d1:	e8 0c 21 00 00       	call   f01051e2 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01030d6:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01030dc:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01030e2:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01030e8:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01030ef:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f01030f5:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01030fc:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103103:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103107:	8b 43 44             	mov    0x44(%ebx),%eax
f010310a:	a3 4c 12 2a f0       	mov    %eax,0xf02a124c
	*newenv_store = e;
f010310f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103112:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f0103114:	83 c4 10             	add    $0x10,%esp
f0103117:	b8 00 00 00 00       	mov    $0x0,%eax
f010311c:	eb 0c                	jmp    f010312a <env_alloc+0x155>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010311e:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103123:	eb 05                	jmp    f010312a <env_alloc+0x155>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103125:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f010312a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010312d:	c9                   	leave  
f010312e:	c3                   	ret    

f010312f <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010312f:	55                   	push   %ebp
f0103130:	89 e5                	mov    %esp,%ebp
f0103132:	57                   	push   %edi
f0103133:	56                   	push   %esi
f0103134:	53                   	push   %ebx
f0103135:	83 ec 24             	sub    $0x24,%esp
	// LAB 3: Your code here.
	struct Env *e;
	env_alloc(&e, 0);
f0103138:	6a 00                	push   $0x0
f010313a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010313d:	50                   	push   %eax
f010313e:	e8 92 fe ff ff       	call   f0102fd5 <env_alloc>
	load_icode(e, binary);
f0103143:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	struct Elf *elf = (struct Elf *) binary;
	struct Proghdr *ph = (struct Proghdr *) (binary + elf->e_phoff);
f0103146:	8b 45 08             	mov    0x8(%ebp),%eax
f0103149:	89 c3                	mov    %eax,%ebx
f010314b:	03 58 1c             	add    0x1c(%eax),%ebx
	struct Proghdr *last_ph = ph + elf->e_phnum;
f010314e:	0f b7 70 2c          	movzwl 0x2c(%eax),%esi
f0103152:	c1 e6 05             	shl    $0x5,%esi
f0103155:	01 de                	add    %ebx,%esi
f0103157:	83 c4 10             	add    $0x10,%esp
f010315a:	eb 54                	jmp    f01031b0 <env_create+0x81>
	for (; ph < last_ph; ph++) {
		if (ph->p_type == ELF_PROG_LOAD) {
f010315c:	83 3b 01             	cmpl   $0x1,(%ebx)
f010315f:	75 4c                	jne    f01031ad <env_create+0x7e>
			region_alloc(e, (uint8_t *) ph->p_va, ph->p_memsz);
f0103161:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103164:	8b 53 08             	mov    0x8(%ebx),%edx
f0103167:	89 f8                	mov    %edi,%eax
f0103169:	e8 f8 fc ff ff       	call   f0102e66 <region_alloc>

			lcr3(PADDR(e->env_pgdir));
f010316e:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103171:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103176:	77 15                	ja     f010318d <env_create+0x5e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103178:	50                   	push   %eax
f0103179:	68 c8 69 10 f0       	push   $0xf01069c8
f010317e:	68 77 01 00 00       	push   $0x177
f0103183:	68 c9 7b 10 f0       	push   $0xf0107bc9
f0103188:	e8 b3 ce ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010318d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103192:	0f 22 d8             	mov    %eax,%cr3

			uint8_t *dst = (uint8_t *) ph->p_va;
			uint8_t *src = binary + ph->p_offset;
			size_t n = (size_t) ph->p_filesz;

			memmove(dst, src, n);
f0103195:	83 ec 04             	sub    $0x4,%esp
f0103198:	ff 73 10             	pushl  0x10(%ebx)
f010319b:	8b 45 08             	mov    0x8(%ebp),%eax
f010319e:	03 43 04             	add    0x4(%ebx),%eax
f01031a1:	50                   	push   %eax
f01031a2:	ff 73 08             	pushl  0x8(%ebx)
f01031a5:	e8 85 20 00 00       	call   f010522f <memmove>
f01031aa:	83 c4 10             	add    $0x10,%esp

	// LAB 3: Your code here.
	struct Elf *elf = (struct Elf *) binary;
	struct Proghdr *ph = (struct Proghdr *) (binary + elf->e_phoff);
	struct Proghdr *last_ph = ph + elf->e_phnum;
	for (; ph < last_ph; ph++) {
f01031ad:	83 c3 20             	add    $0x20,%ebx
f01031b0:	39 de                	cmp    %ebx,%esi
f01031b2:	77 a8                	ja     f010315c <env_create+0x2d>
			memmove(dst, src, n);
		}
	}

	// Put the program entry point in the trapframe
	e->env_tf.tf_eip = elf->e_entry;
f01031b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01031b7:	8b 40 18             	mov    0x18(%eax),%eax
f01031ba:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f01031bd:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01031c2:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01031c7:	89 f8                	mov    %edi,%eax
f01031c9:	e8 98 fc ff ff       	call   f0102e66 <region_alloc>
{
	// LAB 3: Your code here.
	struct Env *e;
	env_alloc(&e, 0);
	load_icode(e, binary);
	e->env_type = type;
f01031ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01031d1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01031d4:	89 50 50             	mov    %edx,0x50(%eax)

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
	if (type == ENV_TYPE_FS) {
f01031d7:	83 fa 01             	cmp    $0x1,%edx
f01031da:	75 07                	jne    f01031e3 <env_create+0xb4>
		e->env_tf.tf_eflags |= FL_IOPL_MASK;
f01031dc:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
	}
}
f01031e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01031e6:	5b                   	pop    %ebx
f01031e7:	5e                   	pop    %esi
f01031e8:	5f                   	pop    %edi
f01031e9:	5d                   	pop    %ebp
f01031ea:	c3                   	ret    

f01031eb <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01031eb:	55                   	push   %ebp
f01031ec:	89 e5                	mov    %esp,%ebp
f01031ee:	57                   	push   %edi
f01031ef:	56                   	push   %esi
f01031f0:	53                   	push   %ebx
f01031f1:	83 ec 1c             	sub    $0x1c,%esp
f01031f4:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01031f7:	e8 06 26 00 00       	call   f0105802 <cpunum>
f01031fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01031ff:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103206:	39 b8 28 20 2a f0    	cmp    %edi,-0xfd5dfd8(%eax)
f010320c:	75 30                	jne    f010323e <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f010320e:	a1 9c 1e 2a f0       	mov    0xf02a1e9c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103213:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103218:	77 15                	ja     f010322f <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010321a:	50                   	push   %eax
f010321b:	68 c8 69 10 f0       	push   $0xf01069c8
f0103220:	68 b0 01 00 00       	push   $0x1b0
f0103225:	68 c9 7b 10 f0       	push   $0xf0107bc9
f010322a:	e8 11 ce ff ff       	call   f0100040 <_panic>
f010322f:	05 00 00 00 10       	add    $0x10000000,%eax
f0103234:	0f 22 d8             	mov    %eax,%cr3
f0103237:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010323e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103241:	89 d0                	mov    %edx,%eax
f0103243:	c1 e0 02             	shl    $0x2,%eax
f0103246:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103249:	8b 47 60             	mov    0x60(%edi),%eax
f010324c:	8b 34 90             	mov    (%eax,%edx,4),%esi
f010324f:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103255:	0f 84 a8 00 00 00    	je     f0103303 <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010325b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103261:	89 f0                	mov    %esi,%eax
f0103263:	c1 e8 0c             	shr    $0xc,%eax
f0103266:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103269:	39 05 98 1e 2a f0    	cmp    %eax,0xf02a1e98
f010326f:	77 15                	ja     f0103286 <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103271:	56                   	push   %esi
f0103272:	68 a4 69 10 f0       	push   $0xf01069a4
f0103277:	68 bf 01 00 00       	push   $0x1bf
f010327c:	68 c9 7b 10 f0       	push   $0xf0107bc9
f0103281:	e8 ba cd ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103286:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103289:	c1 e0 16             	shl    $0x16,%eax
f010328c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010328f:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103294:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f010329b:	01 
f010329c:	74 17                	je     f01032b5 <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010329e:	83 ec 08             	sub    $0x8,%esp
f01032a1:	89 d8                	mov    %ebx,%eax
f01032a3:	c1 e0 0c             	shl    $0xc,%eax
f01032a6:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01032a9:	50                   	push   %eax
f01032aa:	ff 77 60             	pushl  0x60(%edi)
f01032ad:	e8 39 df ff ff       	call   f01011eb <page_remove>
f01032b2:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01032b5:	83 c3 01             	add    $0x1,%ebx
f01032b8:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01032be:	75 d4                	jne    f0103294 <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01032c0:	8b 47 60             	mov    0x60(%edi),%eax
f01032c3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01032c6:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01032d0:	3b 05 98 1e 2a f0    	cmp    0xf02a1e98,%eax
f01032d6:	72 14                	jb     f01032ec <env_free+0x101>
		panic("pa2page called with invalid pa");
f01032d8:	83 ec 04             	sub    $0x4,%esp
f01032db:	68 34 70 10 f0       	push   $0xf0107034
f01032e0:	6a 51                	push   $0x51
f01032e2:	68 c3 78 10 f0       	push   $0xf01078c3
f01032e7:	e8 54 cd ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f01032ec:	83 ec 0c             	sub    $0xc,%esp
f01032ef:	a1 a0 1e 2a f0       	mov    0xf02a1ea0,%eax
f01032f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01032f7:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01032fa:	50                   	push   %eax
f01032fb:	e8 9e dc ff ff       	call   f0100f9e <page_decref>
f0103300:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103303:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103307:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010330a:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010330f:	0f 85 29 ff ff ff    	jne    f010323e <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103315:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103318:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010331d:	77 15                	ja     f0103334 <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010331f:	50                   	push   %eax
f0103320:	68 c8 69 10 f0       	push   $0xf01069c8
f0103325:	68 cd 01 00 00       	push   $0x1cd
f010332a:	68 c9 7b 10 f0       	push   $0xf0107bc9
f010332f:	e8 0c cd ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103334:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010333b:	05 00 00 00 10       	add    $0x10000000,%eax
f0103340:	c1 e8 0c             	shr    $0xc,%eax
f0103343:	3b 05 98 1e 2a f0    	cmp    0xf02a1e98,%eax
f0103349:	72 14                	jb     f010335f <env_free+0x174>
		panic("pa2page called with invalid pa");
f010334b:	83 ec 04             	sub    $0x4,%esp
f010334e:	68 34 70 10 f0       	push   $0xf0107034
f0103353:	6a 51                	push   $0x51
f0103355:	68 c3 78 10 f0       	push   $0xf01078c3
f010335a:	e8 e1 cc ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f010335f:	83 ec 0c             	sub    $0xc,%esp
f0103362:	8b 15 a0 1e 2a f0    	mov    0xf02a1ea0,%edx
f0103368:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010336b:	50                   	push   %eax
f010336c:	e8 2d dc ff ff       	call   f0100f9e <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103371:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103378:	a1 4c 12 2a f0       	mov    0xf02a124c,%eax
f010337d:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103380:	89 3d 4c 12 2a f0    	mov    %edi,0xf02a124c
}
f0103386:	83 c4 10             	add    $0x10,%esp
f0103389:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010338c:	5b                   	pop    %ebx
f010338d:	5e                   	pop    %esi
f010338e:	5f                   	pop    %edi
f010338f:	5d                   	pop    %ebp
f0103390:	c3                   	ret    

f0103391 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103391:	55                   	push   %ebp
f0103392:	89 e5                	mov    %esp,%ebp
f0103394:	53                   	push   %ebx
f0103395:	83 ec 04             	sub    $0x4,%esp
f0103398:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010339b:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f010339f:	75 19                	jne    f01033ba <env_destroy+0x29>
f01033a1:	e8 5c 24 00 00       	call   f0105802 <cpunum>
f01033a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01033a9:	3b 98 28 20 2a f0    	cmp    -0xfd5dfd8(%eax),%ebx
f01033af:	74 09                	je     f01033ba <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01033b1:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01033b8:	eb 33                	jmp    f01033ed <env_destroy+0x5c>
	}

	env_free(e);
f01033ba:	83 ec 0c             	sub    $0xc,%esp
f01033bd:	53                   	push   %ebx
f01033be:	e8 28 fe ff ff       	call   f01031eb <env_free>

	if (curenv == e) {
f01033c3:	e8 3a 24 00 00       	call   f0105802 <cpunum>
f01033c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01033cb:	83 c4 10             	add    $0x10,%esp
f01033ce:	3b 98 28 20 2a f0    	cmp    -0xfd5dfd8(%eax),%ebx
f01033d4:	75 17                	jne    f01033ed <env_destroy+0x5c>
		curenv = NULL;
f01033d6:	e8 27 24 00 00       	call   f0105802 <cpunum>
f01033db:	6b c0 74             	imul   $0x74,%eax,%eax
f01033de:	c7 80 28 20 2a f0 00 	movl   $0x0,-0xfd5dfd8(%eax)
f01033e5:	00 00 00 
		sched_yield();
f01033e8:	e8 ae 0b 00 00       	call   f0103f9b <sched_yield>
	}
}
f01033ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01033f0:	c9                   	leave  
f01033f1:	c3                   	ret    

f01033f2 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01033f2:	55                   	push   %ebp
f01033f3:	89 e5                	mov    %esp,%ebp
f01033f5:	53                   	push   %ebx
f01033f6:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01033f9:	e8 04 24 00 00       	call   f0105802 <cpunum>
f01033fe:	6b c0 74             	imul   $0x74,%eax,%eax
f0103401:	8b 98 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%ebx
f0103407:	e8 f6 23 00 00       	call   f0105802 <cpunum>
f010340c:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f010340f:	8b 65 08             	mov    0x8(%ebp),%esp
f0103412:	61                   	popa   
f0103413:	07                   	pop    %es
f0103414:	1f                   	pop    %ds
f0103415:	83 c4 08             	add    $0x8,%esp
f0103418:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103419:	83 ec 04             	sub    $0x4,%esp
f010341c:	68 d4 7b 10 f0       	push   $0xf0107bd4
f0103421:	68 03 02 00 00       	push   $0x203
f0103426:	68 c9 7b 10 f0       	push   $0xf0107bc9
f010342b:	e8 10 cc ff ff       	call   f0100040 <_panic>

f0103430 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103430:	55                   	push   %ebp
f0103431:	89 e5                	mov    %esp,%ebp
f0103433:	53                   	push   %ebx
f0103434:	83 ec 04             	sub    $0x4,%esp
f0103437:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// Step 1
	if (curenv && curenv->env_status == ENV_RUNNING)
f010343a:	e8 c3 23 00 00       	call   f0105802 <cpunum>
f010343f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103442:	83 b8 28 20 2a f0 00 	cmpl   $0x0,-0xfd5dfd8(%eax)
f0103449:	74 29                	je     f0103474 <env_run+0x44>
f010344b:	e8 b2 23 00 00       	call   f0105802 <cpunum>
f0103450:	6b c0 74             	imul   $0x74,%eax,%eax
f0103453:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f0103459:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010345d:	75 15                	jne    f0103474 <env_run+0x44>
		curenv->env_status = ENV_RUNNABLE;
f010345f:	e8 9e 23 00 00       	call   f0105802 <cpunum>
f0103464:	6b c0 74             	imul   $0x74,%eax,%eax
f0103467:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f010346d:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	curenv = e;
f0103474:	e8 89 23 00 00       	call   f0105802 <cpunum>
f0103479:	6b c0 74             	imul   $0x74,%eax,%eax
f010347c:	89 98 28 20 2a f0    	mov    %ebx,-0xfd5dfd8(%eax)
	e->env_status = ENV_RUNNING;
f0103482:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	e->env_runs += 1;
f0103489:	83 43 58 01          	addl   $0x1,0x58(%ebx)
	lcr3(PADDR(e->env_pgdir));
f010348d:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103490:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103495:	77 15                	ja     f01034ac <env_run+0x7c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103497:	50                   	push   %eax
f0103498:	68 c8 69 10 f0       	push   $0xf01069c8
f010349d:	68 27 02 00 00       	push   $0x227
f01034a2:	68 c9 7b 10 f0       	push   $0xf0107bc9
f01034a7:	e8 94 cb ff ff       	call   f0100040 <_panic>
f01034ac:	05 00 00 00 10       	add    $0x10000000,%eax
f01034b1:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01034b4:	83 ec 0c             	sub    $0xc,%esp
f01034b7:	68 60 34 12 f0       	push   $0xf0123460
f01034bc:	e8 4c 26 00 00       	call   f0105b0d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01034c1:	f3 90                	pause  

	// Step 2
	unlock_kernel();
	env_pop_tf(&(e->env_tf));
f01034c3:	89 1c 24             	mov    %ebx,(%esp)
f01034c6:	e8 27 ff ff ff       	call   f01033f2 <env_pop_tf>

f01034cb <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01034cb:	55                   	push   %ebp
f01034cc:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01034ce:	ba 70 00 00 00       	mov    $0x70,%edx
f01034d3:	8b 45 08             	mov    0x8(%ebp),%eax
f01034d6:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01034d7:	ba 71 00 00 00       	mov    $0x71,%edx
f01034dc:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01034dd:	0f b6 c0             	movzbl %al,%eax
}
f01034e0:	5d                   	pop    %ebp
f01034e1:	c3                   	ret    

f01034e2 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01034e2:	55                   	push   %ebp
f01034e3:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01034e5:	ba 70 00 00 00       	mov    $0x70,%edx
f01034ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01034ed:	ee                   	out    %al,(%dx)
f01034ee:	ba 71 00 00 00       	mov    $0x71,%edx
f01034f3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034f6:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01034f7:	5d                   	pop    %ebp
f01034f8:	c3                   	ret    

f01034f9 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01034f9:	55                   	push   %ebp
f01034fa:	89 e5                	mov    %esp,%ebp
f01034fc:	56                   	push   %esi
f01034fd:	53                   	push   %ebx
f01034fe:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103501:	66 a3 a8 33 12 f0    	mov    %ax,0xf01233a8
	if (!didinit)
f0103507:	80 3d 50 12 2a f0 00 	cmpb   $0x0,0xf02a1250
f010350e:	74 5a                	je     f010356a <irq_setmask_8259A+0x71>
f0103510:	89 c6                	mov    %eax,%esi
f0103512:	ba 21 00 00 00       	mov    $0x21,%edx
f0103517:	ee                   	out    %al,(%dx)
f0103518:	66 c1 e8 08          	shr    $0x8,%ax
f010351c:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103521:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103522:	83 ec 0c             	sub    $0xc,%esp
f0103525:	68 e0 7b 10 f0       	push   $0xf0107be0
f010352a:	e8 31 01 00 00       	call   f0103660 <cprintf>
f010352f:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103532:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103537:	0f b7 f6             	movzwl %si,%esi
f010353a:	f7 d6                	not    %esi
f010353c:	0f a3 de             	bt     %ebx,%esi
f010353f:	73 11                	jae    f0103552 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103541:	83 ec 08             	sub    $0x8,%esp
f0103544:	53                   	push   %ebx
f0103545:	68 bf 80 10 f0       	push   $0xf01080bf
f010354a:	e8 11 01 00 00       	call   f0103660 <cprintf>
f010354f:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103552:	83 c3 01             	add    $0x1,%ebx
f0103555:	83 fb 10             	cmp    $0x10,%ebx
f0103558:	75 e2                	jne    f010353c <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f010355a:	83 ec 0c             	sub    $0xc,%esp
f010355d:	68 97 7b 10 f0       	push   $0xf0107b97
f0103562:	e8 f9 00 00 00       	call   f0103660 <cprintf>
f0103567:	83 c4 10             	add    $0x10,%esp
}
f010356a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010356d:	5b                   	pop    %ebx
f010356e:	5e                   	pop    %esi
f010356f:	5d                   	pop    %ebp
f0103570:	c3                   	ret    

f0103571 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103571:	c6 05 50 12 2a f0 01 	movb   $0x1,0xf02a1250
f0103578:	ba 21 00 00 00       	mov    $0x21,%edx
f010357d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103582:	ee                   	out    %al,(%dx)
f0103583:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103588:	ee                   	out    %al,(%dx)
f0103589:	ba 20 00 00 00       	mov    $0x20,%edx
f010358e:	b8 11 00 00 00       	mov    $0x11,%eax
f0103593:	ee                   	out    %al,(%dx)
f0103594:	ba 21 00 00 00       	mov    $0x21,%edx
f0103599:	b8 20 00 00 00       	mov    $0x20,%eax
f010359e:	ee                   	out    %al,(%dx)
f010359f:	b8 04 00 00 00       	mov    $0x4,%eax
f01035a4:	ee                   	out    %al,(%dx)
f01035a5:	b8 03 00 00 00       	mov    $0x3,%eax
f01035aa:	ee                   	out    %al,(%dx)
f01035ab:	ba a0 00 00 00       	mov    $0xa0,%edx
f01035b0:	b8 11 00 00 00       	mov    $0x11,%eax
f01035b5:	ee                   	out    %al,(%dx)
f01035b6:	ba a1 00 00 00       	mov    $0xa1,%edx
f01035bb:	b8 28 00 00 00       	mov    $0x28,%eax
f01035c0:	ee                   	out    %al,(%dx)
f01035c1:	b8 02 00 00 00       	mov    $0x2,%eax
f01035c6:	ee                   	out    %al,(%dx)
f01035c7:	b8 01 00 00 00       	mov    $0x1,%eax
f01035cc:	ee                   	out    %al,(%dx)
f01035cd:	ba 20 00 00 00       	mov    $0x20,%edx
f01035d2:	b8 68 00 00 00       	mov    $0x68,%eax
f01035d7:	ee                   	out    %al,(%dx)
f01035d8:	b8 0a 00 00 00       	mov    $0xa,%eax
f01035dd:	ee                   	out    %al,(%dx)
f01035de:	ba a0 00 00 00       	mov    $0xa0,%edx
f01035e3:	b8 68 00 00 00       	mov    $0x68,%eax
f01035e8:	ee                   	out    %al,(%dx)
f01035e9:	b8 0a 00 00 00       	mov    $0xa,%eax
f01035ee:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01035ef:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f01035f6:	66 83 f8 ff          	cmp    $0xffff,%ax
f01035fa:	74 13                	je     f010360f <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01035fc:	55                   	push   %ebp
f01035fd:	89 e5                	mov    %esp,%ebp
f01035ff:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103602:	0f b7 c0             	movzwl %ax,%eax
f0103605:	50                   	push   %eax
f0103606:	e8 ee fe ff ff       	call   f01034f9 <irq_setmask_8259A>
f010360b:	83 c4 10             	add    $0x10,%esp
}
f010360e:	c9                   	leave  
f010360f:	f3 c3                	repz ret 

f0103611 <irq_eoi>:
	cprintf("\n");
}

void
irq_eoi(void)
{
f0103611:	55                   	push   %ebp
f0103612:	89 e5                	mov    %esp,%ebp
f0103614:	ba 20 00 00 00       	mov    $0x20,%edx
f0103619:	b8 20 00 00 00       	mov    $0x20,%eax
f010361e:	ee                   	out    %al,(%dx)
f010361f:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103624:	ee                   	out    %al,(%dx)
	//   s: specific
	//   e: end-of-interrupt
	// xxx: specific interrupt line
	outb(IO_PIC1, 0x20);
	outb(IO_PIC2, 0x20);
}
f0103625:	5d                   	pop    %ebp
f0103626:	c3                   	ret    

f0103627 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103627:	55                   	push   %ebp
f0103628:	89 e5                	mov    %esp,%ebp
f010362a:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010362d:	ff 75 08             	pushl  0x8(%ebp)
f0103630:	e8 6f d1 ff ff       	call   f01007a4 <cputchar>
	*cnt++;
}
f0103635:	83 c4 10             	add    $0x10,%esp
f0103638:	c9                   	leave  
f0103639:	c3                   	ret    

f010363a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010363a:	55                   	push   %ebp
f010363b:	89 e5                	mov    %esp,%ebp
f010363d:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103640:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103647:	ff 75 0c             	pushl  0xc(%ebp)
f010364a:	ff 75 08             	pushl  0x8(%ebp)
f010364d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103650:	50                   	push   %eax
f0103651:	68 27 36 10 f0       	push   $0xf0103627
f0103656:	e8 03 15 00 00       	call   f0104b5e <vprintfmt>
	return cnt;
}
f010365b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010365e:	c9                   	leave  
f010365f:	c3                   	ret    

f0103660 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103660:	55                   	push   %ebp
f0103661:	89 e5                	mov    %esp,%ebp
f0103663:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103666:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103669:	50                   	push   %eax
f010366a:	ff 75 08             	pushl  0x8(%ebp)
f010366d:	e8 c8 ff ff ff       	call   f010363a <vcprintf>
	va_end(ap);

	return cnt;
}
f0103672:	c9                   	leave  
f0103673:	c3                   	ret    

f0103674 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103674:	55                   	push   %ebp
f0103675:	89 e5                	mov    %esp,%ebp
f0103677:	57                   	push   %edi
f0103678:	56                   	push   %esi
f0103679:	53                   	push   %ebx
f010367a:	83 ec 1c             	sub    $0x1c,%esp
	lidt(&idt_pd);
	*/

	/* MY CODE */
	// Get cpu index
	uint32_t i = thiscpu->cpu_id;
f010367d:	e8 80 21 00 00       	call   f0105802 <cpunum>
f0103682:	6b c0 74             	imul   $0x74,%eax,%eax
f0103685:	0f b6 b0 20 20 2a f0 	movzbl -0xfd5dfe0(%eax),%esi
f010368c:	89 f0                	mov    %esi,%eax
f010368e:	0f b6 d8             	movzbl %al,%ebx

	// Setup the cpu TSS
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
f0103691:	e8 6c 21 00 00       	call   f0105802 <cpunum>
f0103696:	6b c0 74             	imul   $0x74,%eax,%eax
f0103699:	89 da                	mov    %ebx,%edx
f010369b:	f7 da                	neg    %edx
f010369d:	c1 e2 10             	shl    $0x10,%edx
f01036a0:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01036a6:	89 90 30 20 2a f0    	mov    %edx,-0xfd5dfd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01036ac:	e8 51 21 00 00       	call   f0105802 <cpunum>
f01036b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01036b4:	66 c7 80 34 20 2a f0 	movw   $0x10,-0xfd5dfcc(%eax)
f01036bb:	10 00 

	// Initialize the TSS slot of the gdt, so the hardware can access it
	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f01036bd:	83 c3 05             	add    $0x5,%ebx
f01036c0:	e8 3d 21 00 00       	call   f0105802 <cpunum>
f01036c5:	89 c7                	mov    %eax,%edi
f01036c7:	e8 36 21 00 00       	call   f0105802 <cpunum>
f01036cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01036cf:	e8 2e 21 00 00       	call   f0105802 <cpunum>
f01036d4:	66 c7 04 dd 40 33 12 	movw   $0x67,-0xfedccc0(,%ebx,8)
f01036db:	f0 67 00 
f01036de:	6b ff 74             	imul   $0x74,%edi,%edi
f01036e1:	81 c7 2c 20 2a f0    	add    $0xf02a202c,%edi
f01036e7:	66 89 3c dd 42 33 12 	mov    %di,-0xfedccbe(,%ebx,8)
f01036ee:	f0 
f01036ef:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f01036f3:	81 c2 2c 20 2a f0    	add    $0xf02a202c,%edx
f01036f9:	c1 ea 10             	shr    $0x10,%edx
f01036fc:	88 14 dd 44 33 12 f0 	mov    %dl,-0xfedccbc(,%ebx,8)
f0103703:	c6 04 dd 46 33 12 f0 	movb   $0x40,-0xfedccba(,%ebx,8)
f010370a:	40 
f010370b:	6b c0 74             	imul   $0x74,%eax,%eax
f010370e:	05 2c 20 2a f0       	add    $0xf02a202c,%eax
f0103713:	c1 e8 18             	shr    $0x18,%eax
f0103716:	88 04 dd 47 33 12 f0 	mov    %al,-0xfedccb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f010371d:	c6 04 dd 45 33 12 f0 	movb   $0x89,-0xfedccbb(,%ebx,8)
f0103724:	89 
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103725:	89 f0                	mov    %esi,%eax
f0103727:	0f b6 f0             	movzbl %al,%esi
f010372a:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
f0103731:	0f 00 de             	ltr    %si
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103734:	b8 ac 33 12 f0       	mov    $0xf01233ac,%eax
f0103739:	0f 01 18             	lidtl  (%eax)
	// Load the TSS selector, so the hardware knows where to find it on the gdt
	ltr(GD_TSS0 + (i << 3));

	// Load the IDT
	lidt(&idt_pd);
}
f010373c:	83 c4 1c             	add    $0x1c,%esp
f010373f:	5b                   	pop    %ebx
f0103740:	5e                   	pop    %esi
f0103741:	5f                   	pop    %edi
f0103742:	5d                   	pop    %ebp
f0103743:	c3                   	ret    

f0103744 <trap_init>:
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	// Processor internal interrupts
	int i;
	for (i = 0; i <= 19; i++) {
f0103744:	b8 00 00 00 00       	mov    $0x0,%eax
		SETGATE(idt[i], 0, GD_KT, handlers[i], 0);
f0103749:	8b 14 85 b2 33 12 f0 	mov    -0xfedcc4e(,%eax,4),%edx
f0103750:	66 89 14 c5 60 12 2a 	mov    %dx,-0xfd5eda0(,%eax,8)
f0103757:	f0 
f0103758:	66 c7 04 c5 62 12 2a 	movw   $0x8,-0xfd5ed9e(,%eax,8)
f010375f:	f0 08 00 
f0103762:	c6 04 c5 64 12 2a f0 	movb   $0x0,-0xfd5ed9c(,%eax,8)
f0103769:	00 
f010376a:	c6 04 c5 65 12 2a f0 	movb   $0x8e,-0xfd5ed9b(,%eax,8)
f0103771:	8e 
f0103772:	c1 ea 10             	shr    $0x10,%edx
f0103775:	66 89 14 c5 66 12 2a 	mov    %dx,-0xfd5ed9a(,%eax,8)
f010377c:	f0 
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	// Processor internal interrupts
	int i;
	for (i = 0; i <= 19; i++) {
f010377d:	83 c0 01             	add    $0x1,%eax
f0103780:	83 f8 14             	cmp    $0x14,%eax
f0103783:	75 c4                	jne    f0103749 <trap_init+0x5>
		SETGATE(idt[i], 0, GD_KT, handlers[i], 0);
	}
	SETGATE(idt[T_BRKPT], 0, GD_KT, handlers[T_BRKPT], 3);
f0103785:	a1 be 33 12 f0       	mov    0xf01233be,%eax
f010378a:	66 a3 78 12 2a f0    	mov    %ax,0xf02a1278
f0103790:	66 c7 05 7a 12 2a f0 	movw   $0x8,0xf02a127a
f0103797:	08 00 
f0103799:	c6 05 7c 12 2a f0 00 	movb   $0x0,0xf02a127c
f01037a0:	c6 05 7d 12 2a f0 ee 	movb   $0xee,0xf02a127d
f01037a7:	c1 e8 10             	shr    $0x10,%eax
f01037aa:	66 a3 7e 12 2a f0    	mov    %ax,0xf02a127e

	// For system call
	SETGATE(idt[T_SYSCALL], 0, GD_KT, &handler_syscall, 3);
f01037b0:	b8 ac 3e 10 f0       	mov    $0xf0103eac,%eax
f01037b5:	66 a3 e0 13 2a f0    	mov    %ax,0xf02a13e0
f01037bb:	66 c7 05 e2 13 2a f0 	movw   $0x8,0xf02a13e2
f01037c2:	08 00 
f01037c4:	c6 05 e4 13 2a f0 00 	movb   $0x0,0xf02a13e4
f01037cb:	c6 05 e5 13 2a f0 ee 	movb   $0xee,0xf02a13e5
f01037d2:	c1 e8 10             	shr    $0x10,%eax
f01037d5:	66 a3 e6 13 2a f0    	mov    %ax,0xf02a13e6
f01037db:	b8 20 00 00 00       	mov    $0x20,%eax

	// External interrupts
	for (i = 0; i <= 15; i++) {
		SETGATE(idt[IRQ_OFFSET + i], 0, GD_KT, handlers_irq[i],0);
f01037e0:	8b 14 85 82 33 12 f0 	mov    -0xfedcc7e(,%eax,4),%edx
f01037e7:	66 89 14 c5 60 12 2a 	mov    %dx,-0xfd5eda0(,%eax,8)
f01037ee:	f0 
f01037ef:	66 c7 04 c5 62 12 2a 	movw   $0x8,-0xfd5ed9e(,%eax,8)
f01037f6:	f0 08 00 
f01037f9:	c6 04 c5 64 12 2a f0 	movb   $0x0,-0xfd5ed9c(,%eax,8)
f0103800:	00 
f0103801:	c6 04 c5 65 12 2a f0 	movb   $0x8e,-0xfd5ed9b(,%eax,8)
f0103808:	8e 
f0103809:	c1 ea 10             	shr    $0x10,%edx
f010380c:	66 89 14 c5 66 12 2a 	mov    %dx,-0xfd5ed9a(,%eax,8)
f0103813:	f0 
f0103814:	83 c0 01             	add    $0x1,%eax

	// For system call
	SETGATE(idt[T_SYSCALL], 0, GD_KT, &handler_syscall, 3);

	// External interrupts
	for (i = 0; i <= 15; i++) {
f0103817:	83 f8 30             	cmp    $0x30,%eax
f010381a:	75 c4                	jne    f01037e0 <trap_init+0x9c>
extern void* handler_syscall;
extern uint32_t handlers[];
extern uint32_t handlers_irq[];
void
trap_init(void)
{
f010381c:	55                   	push   %ebp
f010381d:	89 e5                	mov    %esp,%ebp
f010381f:	83 ec 08             	sub    $0x8,%esp
	for (i = 0; i <= 15; i++) {
		SETGATE(idt[IRQ_OFFSET + i], 0, GD_KT, handlers_irq[i],0);
	}

	// Per-CPU setup 
	trap_init_percpu();
f0103822:	e8 4d fe ff ff       	call   f0103674 <trap_init_percpu>
}
f0103827:	c9                   	leave  
f0103828:	c3                   	ret    

f0103829 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103829:	55                   	push   %ebp
f010382a:	89 e5                	mov    %esp,%ebp
f010382c:	53                   	push   %ebx
f010382d:	83 ec 0c             	sub    $0xc,%esp
f0103830:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103833:	ff 33                	pushl  (%ebx)
f0103835:	68 f4 7b 10 f0       	push   $0xf0107bf4
f010383a:	e8 21 fe ff ff       	call   f0103660 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010383f:	83 c4 08             	add    $0x8,%esp
f0103842:	ff 73 04             	pushl  0x4(%ebx)
f0103845:	68 03 7c 10 f0       	push   $0xf0107c03
f010384a:	e8 11 fe ff ff       	call   f0103660 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010384f:	83 c4 08             	add    $0x8,%esp
f0103852:	ff 73 08             	pushl  0x8(%ebx)
f0103855:	68 12 7c 10 f0       	push   $0xf0107c12
f010385a:	e8 01 fe ff ff       	call   f0103660 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010385f:	83 c4 08             	add    $0x8,%esp
f0103862:	ff 73 0c             	pushl  0xc(%ebx)
f0103865:	68 21 7c 10 f0       	push   $0xf0107c21
f010386a:	e8 f1 fd ff ff       	call   f0103660 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010386f:	83 c4 08             	add    $0x8,%esp
f0103872:	ff 73 10             	pushl  0x10(%ebx)
f0103875:	68 30 7c 10 f0       	push   $0xf0107c30
f010387a:	e8 e1 fd ff ff       	call   f0103660 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010387f:	83 c4 08             	add    $0x8,%esp
f0103882:	ff 73 14             	pushl  0x14(%ebx)
f0103885:	68 3f 7c 10 f0       	push   $0xf0107c3f
f010388a:	e8 d1 fd ff ff       	call   f0103660 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010388f:	83 c4 08             	add    $0x8,%esp
f0103892:	ff 73 18             	pushl  0x18(%ebx)
f0103895:	68 4e 7c 10 f0       	push   $0xf0107c4e
f010389a:	e8 c1 fd ff ff       	call   f0103660 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010389f:	83 c4 08             	add    $0x8,%esp
f01038a2:	ff 73 1c             	pushl  0x1c(%ebx)
f01038a5:	68 5d 7c 10 f0       	push   $0xf0107c5d
f01038aa:	e8 b1 fd ff ff       	call   f0103660 <cprintf>
}
f01038af:	83 c4 10             	add    $0x10,%esp
f01038b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01038b5:	c9                   	leave  
f01038b6:	c3                   	ret    

f01038b7 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f01038b7:	55                   	push   %ebp
f01038b8:	89 e5                	mov    %esp,%ebp
f01038ba:	56                   	push   %esi
f01038bb:	53                   	push   %ebx
f01038bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01038bf:	e8 3e 1f 00 00       	call   f0105802 <cpunum>
f01038c4:	83 ec 04             	sub    $0x4,%esp
f01038c7:	50                   	push   %eax
f01038c8:	53                   	push   %ebx
f01038c9:	68 c1 7c 10 f0       	push   $0xf0107cc1
f01038ce:	e8 8d fd ff ff       	call   f0103660 <cprintf>
	print_regs(&tf->tf_regs);
f01038d3:	89 1c 24             	mov    %ebx,(%esp)
f01038d6:	e8 4e ff ff ff       	call   f0103829 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01038db:	83 c4 08             	add    $0x8,%esp
f01038de:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01038e2:	50                   	push   %eax
f01038e3:	68 df 7c 10 f0       	push   $0xf0107cdf
f01038e8:	e8 73 fd ff ff       	call   f0103660 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01038ed:	83 c4 08             	add    $0x8,%esp
f01038f0:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01038f4:	50                   	push   %eax
f01038f5:	68 f2 7c 10 f0       	push   $0xf0107cf2
f01038fa:	e8 61 fd ff ff       	call   f0103660 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01038ff:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103902:	83 c4 10             	add    $0x10,%esp
f0103905:	83 f8 13             	cmp    $0x13,%eax
f0103908:	77 09                	ja     f0103913 <print_trapframe+0x5c>
		return excnames[trapno];
f010390a:	8b 14 85 80 7f 10 f0 	mov    -0xfef8080(,%eax,4),%edx
f0103911:	eb 1f                	jmp    f0103932 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103913:	83 f8 30             	cmp    $0x30,%eax
f0103916:	74 15                	je     f010392d <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103918:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f010391b:	83 fa 10             	cmp    $0x10,%edx
f010391e:	b9 8b 7c 10 f0       	mov    $0xf0107c8b,%ecx
f0103923:	ba 78 7c 10 f0       	mov    $0xf0107c78,%edx
f0103928:	0f 43 d1             	cmovae %ecx,%edx
f010392b:	eb 05                	jmp    f0103932 <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f010392d:	ba 6c 7c 10 f0       	mov    $0xf0107c6c,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103932:	83 ec 04             	sub    $0x4,%esp
f0103935:	52                   	push   %edx
f0103936:	50                   	push   %eax
f0103937:	68 05 7d 10 f0       	push   $0xf0107d05
f010393c:	e8 1f fd ff ff       	call   f0103660 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103941:	83 c4 10             	add    $0x10,%esp
f0103944:	3b 1d 60 1a 2a f0    	cmp    0xf02a1a60,%ebx
f010394a:	75 1a                	jne    f0103966 <print_trapframe+0xaf>
f010394c:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103950:	75 14                	jne    f0103966 <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103952:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103955:	83 ec 08             	sub    $0x8,%esp
f0103958:	50                   	push   %eax
f0103959:	68 17 7d 10 f0       	push   $0xf0107d17
f010395e:	e8 fd fc ff ff       	call   f0103660 <cprintf>
f0103963:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103966:	83 ec 08             	sub    $0x8,%esp
f0103969:	ff 73 2c             	pushl  0x2c(%ebx)
f010396c:	68 26 7d 10 f0       	push   $0xf0107d26
f0103971:	e8 ea fc ff ff       	call   f0103660 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103976:	83 c4 10             	add    $0x10,%esp
f0103979:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010397d:	75 49                	jne    f01039c8 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010397f:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103982:	89 c2                	mov    %eax,%edx
f0103984:	83 e2 01             	and    $0x1,%edx
f0103987:	ba a5 7c 10 f0       	mov    $0xf0107ca5,%edx
f010398c:	b9 9a 7c 10 f0       	mov    $0xf0107c9a,%ecx
f0103991:	0f 44 ca             	cmove  %edx,%ecx
f0103994:	89 c2                	mov    %eax,%edx
f0103996:	83 e2 02             	and    $0x2,%edx
f0103999:	ba b7 7c 10 f0       	mov    $0xf0107cb7,%edx
f010399e:	be b1 7c 10 f0       	mov    $0xf0107cb1,%esi
f01039a3:	0f 45 d6             	cmovne %esi,%edx
f01039a6:	83 e0 04             	and    $0x4,%eax
f01039a9:	be 0c 7e 10 f0       	mov    $0xf0107e0c,%esi
f01039ae:	b8 bc 7c 10 f0       	mov    $0xf0107cbc,%eax
f01039b3:	0f 44 c6             	cmove  %esi,%eax
f01039b6:	51                   	push   %ecx
f01039b7:	52                   	push   %edx
f01039b8:	50                   	push   %eax
f01039b9:	68 34 7d 10 f0       	push   $0xf0107d34
f01039be:	e8 9d fc ff ff       	call   f0103660 <cprintf>
f01039c3:	83 c4 10             	add    $0x10,%esp
f01039c6:	eb 10                	jmp    f01039d8 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01039c8:	83 ec 0c             	sub    $0xc,%esp
f01039cb:	68 97 7b 10 f0       	push   $0xf0107b97
f01039d0:	e8 8b fc ff ff       	call   f0103660 <cprintf>
f01039d5:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01039d8:	83 ec 08             	sub    $0x8,%esp
f01039db:	ff 73 30             	pushl  0x30(%ebx)
f01039de:	68 43 7d 10 f0       	push   $0xf0107d43
f01039e3:	e8 78 fc ff ff       	call   f0103660 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01039e8:	83 c4 08             	add    $0x8,%esp
f01039eb:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01039ef:	50                   	push   %eax
f01039f0:	68 52 7d 10 f0       	push   $0xf0107d52
f01039f5:	e8 66 fc ff ff       	call   f0103660 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01039fa:	83 c4 08             	add    $0x8,%esp
f01039fd:	ff 73 38             	pushl  0x38(%ebx)
f0103a00:	68 65 7d 10 f0       	push   $0xf0107d65
f0103a05:	e8 56 fc ff ff       	call   f0103660 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103a0a:	83 c4 10             	add    $0x10,%esp
f0103a0d:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103a11:	74 25                	je     f0103a38 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103a13:	83 ec 08             	sub    $0x8,%esp
f0103a16:	ff 73 3c             	pushl  0x3c(%ebx)
f0103a19:	68 74 7d 10 f0       	push   $0xf0107d74
f0103a1e:	e8 3d fc ff ff       	call   f0103660 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103a23:	83 c4 08             	add    $0x8,%esp
f0103a26:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103a2a:	50                   	push   %eax
f0103a2b:	68 83 7d 10 f0       	push   $0xf0107d83
f0103a30:	e8 2b fc ff ff       	call   f0103660 <cprintf>
f0103a35:	83 c4 10             	add    $0x10,%esp
	}
}
f0103a38:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103a3b:	5b                   	pop    %ebx
f0103a3c:	5e                   	pop    %esi
f0103a3d:	5d                   	pop    %ebp
f0103a3e:	c3                   	ret    

f0103a3f <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103a3f:	55                   	push   %ebp
f0103a40:	89 e5                	mov    %esp,%ebp
f0103a42:	57                   	push   %edi
f0103a43:	56                   	push   %esi
f0103a44:	53                   	push   %ebx
f0103a45:	83 ec 1c             	sub    $0x1c,%esp
f0103a48:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103a4b:	0f 20 d6             	mov    %cr2,%esi
	//cprintf("DEBUG-TRAP: Page fault on address %x, err = %x\n", fault_va, tf->tf_err);

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0) // Checks last 2 bits are 0
f0103a4e:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103a52:	75 17                	jne    f0103a6b <page_fault_handler+0x2c>
		panic("Page fault on kernel mode!");
f0103a54:	83 ec 04             	sub    $0x4,%esp
f0103a57:	68 96 7d 10 f0       	push   $0xf0107d96
f0103a5c:	68 63 01 00 00       	push   $0x163
f0103a61:	68 b1 7d 10 f0       	push   $0xf0107db1
f0103a66:	e8 d5 c5 ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {
f0103a6b:	e8 92 1d 00 00       	call   f0105802 <cpunum>
f0103a70:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a73:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f0103a79:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103a7d:	0f 84 95 00 00 00    	je     f0103b18 <page_fault_handler+0xd9>
		struct UTrapframe *utf;

		// Recursive case. Pgfault handler pgfaulted.
		if (UXSTACKTOP-PGSIZE <= tf->tf_esp && tf->tf_esp < UXSTACKTOP) {
f0103a83:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103a86:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			utf = (struct UTrapframe *) (tf->tf_esp - 4); // Gap
f0103a8c:	83 e8 04             	sub    $0x4,%eax
f0103a8f:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0103a95:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0103a9a:	0f 46 d0             	cmovbe %eax,%edx
f0103a9d:	89 d7                	mov    %edx,%edi
		} else {
			utf = (struct UTrapframe *) UXSTACKTOP;
		}

		// Make utf point to the new top of the exception stack
		utf--;
f0103a9f:	8d 42 cc             	lea    -0x34(%edx),%eax
f0103aa2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		user_mem_assert(curenv, utf, sizeof(struct UTrapframe), PTE_W);
f0103aa5:	e8 58 1d 00 00       	call   f0105802 <cpunum>
f0103aaa:	6a 02                	push   $0x2
f0103aac:	6a 34                	push   $0x34
f0103aae:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103ab1:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ab4:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f0103aba:	e8 5d f3 ff ff       	call   f0102e1c <user_mem_assert>

		// "Push" the info
		utf->utf_fault_va = fault_va;
f0103abf:	89 fa                	mov    %edi,%edx
f0103ac1:	89 77 cc             	mov    %esi,-0x34(%edi)
		utf->utf_err = tf->tf_err;
f0103ac4:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103ac7:	89 47 d0             	mov    %eax,-0x30(%edi)
		utf->utf_regs = tf->tf_regs;
f0103aca:	8d 7f d4             	lea    -0x2c(%edi),%edi
f0103acd:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103ad2:	89 de                	mov    %ebx,%esi
f0103ad4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f0103ad6:	8b 43 30             	mov    0x30(%ebx),%eax
f0103ad9:	89 42 f4             	mov    %eax,-0xc(%edx)
		utf->utf_eflags = tf->tf_eflags;
f0103adc:	8b 43 38             	mov    0x38(%ebx),%eax
f0103adf:	89 42 f8             	mov    %eax,-0x8(%edx)
		utf->utf_esp = tf->tf_esp;
f0103ae2:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103ae5:	89 42 fc             	mov    %eax,-0x4(%edx)

		// Branch to curenv->env_pgfault_upcall: back to user mode!
		tf->tf_esp = (uintptr_t) utf;
f0103ae8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103aeb:	89 43 3c             	mov    %eax,0x3c(%ebx)
		tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;
f0103aee:	e8 0f 1d 00 00       	call   f0105802 <cpunum>
f0103af3:	6b c0 74             	imul   $0x74,%eax,%eax
f0103af6:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f0103afc:	8b 40 64             	mov    0x64(%eax),%eax
f0103aff:	89 43 30             	mov    %eax,0x30(%ebx)
		env_run(curenv);
f0103b02:	e8 fb 1c 00 00       	call   f0105802 <cpunum>
f0103b07:	83 c4 04             	add    $0x4,%esp
f0103b0a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b0d:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f0103b13:	e8 18 f9 ff ff       	call   f0103430 <env_run>

		return;
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103b18:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0103b1b:	e8 e2 1c 00 00       	call   f0105802 <cpunum>

		return;
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103b20:	57                   	push   %edi
f0103b21:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0103b22:	6b c0 74             	imul   $0x74,%eax,%eax

		return;
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103b25:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f0103b2b:	ff 70 48             	pushl  0x48(%eax)
f0103b2e:	68 58 7f 10 f0       	push   $0xf0107f58
f0103b33:	e8 28 fb ff ff       	call   f0103660 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103b38:	89 1c 24             	mov    %ebx,(%esp)
f0103b3b:	e8 77 fd ff ff       	call   f01038b7 <print_trapframe>
	env_destroy(curenv);
f0103b40:	e8 bd 1c 00 00       	call   f0105802 <cpunum>
f0103b45:	83 c4 04             	add    $0x4,%esp
f0103b48:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b4b:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f0103b51:	e8 3b f8 ff ff       	call   f0103391 <env_destroy>
}
f0103b56:	83 c4 10             	add    $0x10,%esp
f0103b59:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103b5c:	5b                   	pop    %ebx
f0103b5d:	5e                   	pop    %esi
f0103b5e:	5f                   	pop    %edi
f0103b5f:	5d                   	pop    %ebp
f0103b60:	c3                   	ret    

f0103b61 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103b61:	55                   	push   %ebp
f0103b62:	89 e5                	mov    %esp,%ebp
f0103b64:	57                   	push   %edi
f0103b65:	56                   	push   %esi
f0103b66:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103b69:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103b6a:	83 3d 90 1e 2a f0 00 	cmpl   $0x0,0xf02a1e90
f0103b71:	74 01                	je     f0103b74 <trap+0x13>
		asm volatile("hlt");
f0103b73:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103b74:	e8 89 1c 00 00       	call   f0105802 <cpunum>
f0103b79:	6b d0 74             	imul   $0x74,%eax,%edx
f0103b7c:	81 c2 20 20 2a f0    	add    $0xf02a2020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0103b82:	b8 01 00 00 00       	mov    $0x1,%eax
f0103b87:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0103b8b:	83 f8 02             	cmp    $0x2,%eax
f0103b8e:	75 10                	jne    f0103ba0 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0103b90:	83 ec 0c             	sub    $0xc,%esp
f0103b93:	68 60 34 12 f0       	push   $0xf0123460
f0103b98:	e8 d3 1e 00 00       	call   f0105a70 <spin_lock>
f0103b9d:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103ba0:	9c                   	pushf  
f0103ba1:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103ba2:	f6 c4 02             	test   $0x2,%ah
f0103ba5:	74 19                	je     f0103bc0 <trap+0x5f>
f0103ba7:	68 bd 7d 10 f0       	push   $0xf0107dbd
f0103bac:	68 dd 78 10 f0       	push   $0xf01078dd
f0103bb1:	68 2c 01 00 00       	push   $0x12c
f0103bb6:	68 b1 7d 10 f0       	push   $0xf0107db1
f0103bbb:	e8 80 c4 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0103bc0:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103bc4:	83 e0 03             	and    $0x3,%eax
f0103bc7:	66 83 f8 03          	cmp    $0x3,%ax
f0103bcb:	0f 85 a0 00 00 00    	jne    f0103c71 <trap+0x110>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f0103bd1:	e8 2c 1c 00 00       	call   f0105802 <cpunum>
f0103bd6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bd9:	83 b8 28 20 2a f0 00 	cmpl   $0x0,-0xfd5dfd8(%eax)
f0103be0:	75 19                	jne    f0103bfb <trap+0x9a>
f0103be2:	68 d6 7d 10 f0       	push   $0xf0107dd6
f0103be7:	68 dd 78 10 f0       	push   $0xf01078dd
f0103bec:	68 33 01 00 00       	push   $0x133
f0103bf1:	68 b1 7d 10 f0       	push   $0xf0107db1
f0103bf6:	e8 45 c4 ff ff       	call   f0100040 <_panic>
f0103bfb:	83 ec 0c             	sub    $0xc,%esp
f0103bfe:	68 60 34 12 f0       	push   $0xf0123460
f0103c03:	e8 68 1e 00 00       	call   f0105a70 <spin_lock>
		lock_kernel();

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0103c08:	e8 f5 1b 00 00       	call   f0105802 <cpunum>
f0103c0d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c10:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f0103c16:	83 c4 10             	add    $0x10,%esp
f0103c19:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103c1d:	75 2d                	jne    f0103c4c <trap+0xeb>
			env_free(curenv);
f0103c1f:	e8 de 1b 00 00       	call   f0105802 <cpunum>
f0103c24:	83 ec 0c             	sub    $0xc,%esp
f0103c27:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c2a:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f0103c30:	e8 b6 f5 ff ff       	call   f01031eb <env_free>
			curenv = NULL;
f0103c35:	e8 c8 1b 00 00       	call   f0105802 <cpunum>
f0103c3a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c3d:	c7 80 28 20 2a f0 00 	movl   $0x0,-0xfd5dfd8(%eax)
f0103c44:	00 00 00 
			sched_yield();
f0103c47:	e8 4f 03 00 00       	call   f0103f9b <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103c4c:	e8 b1 1b 00 00       	call   f0105802 <cpunum>
f0103c51:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c54:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f0103c5a:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103c5f:	89 c7                	mov    %eax,%edi
f0103c61:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103c63:	e8 9a 1b 00 00       	call   f0105802 <cpunum>
f0103c68:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c6b:	8b b0 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103c71:	89 35 60 1a 2a f0    	mov    %esi,0xf02a1a60
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	
	if (tf->tf_trapno == 3) {
f0103c77:	8b 46 28             	mov    0x28(%esi),%eax
f0103c7a:	83 f8 03             	cmp    $0x3,%eax
f0103c7d:	75 11                	jne    f0103c90 <trap+0x12f>
		monitor(tf);
f0103c7f:	83 ec 0c             	sub    $0xc,%esp
f0103c82:	56                   	push   %esi
f0103c83:	e8 6e cc ff ff       	call   f01008f6 <monitor>
f0103c88:	83 c4 10             	add    $0x10,%esp
f0103c8b:	e9 d6 00 00 00       	jmp    f0103d66 <trap+0x205>
		return;
	}
	if (tf->tf_trapno == 14) {
f0103c90:	83 f8 0e             	cmp    $0xe,%eax
f0103c93:	75 11                	jne    f0103ca6 <trap+0x145>
		page_fault_handler(tf);
f0103c95:	83 ec 0c             	sub    $0xc,%esp
f0103c98:	56                   	push   %esi
f0103c99:	e8 a1 fd ff ff       	call   f0103a3f <page_fault_handler>
f0103c9e:	83 c4 10             	add    $0x10,%esp
f0103ca1:	e9 c0 00 00 00       	jmp    f0103d66 <trap+0x205>
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
f0103ca6:	83 f8 30             	cmp    $0x30,%eax
f0103ca9:	75 24                	jne    f0103ccf <trap+0x16e>
		struct PushRegs regs = tf->tf_regs;
		int32_t retValue;
		retValue = syscall(regs.reg_eax,
f0103cab:	83 ec 08             	sub    $0x8,%esp
f0103cae:	ff 76 04             	pushl  0x4(%esi)
f0103cb1:	ff 36                	pushl  (%esi)
f0103cb3:	ff 76 10             	pushl  0x10(%esi)
f0103cb6:	ff 76 18             	pushl  0x18(%esi)
f0103cb9:	ff 76 14             	pushl  0x14(%esi)
f0103cbc:	ff 76 1c             	pushl  0x1c(%esi)
f0103cbf:	e8 a3 03 00 00       	call   f0104067 <syscall>
				regs.reg_edx,	
				regs.reg_ecx,	
				regs.reg_ebx,	
				regs.reg_edi,	
				regs.reg_esi);	
		tf->tf_regs.reg_eax = retValue;
f0103cc4:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103cc7:	83 c4 20             	add    $0x20,%esp
f0103cca:	e9 97 00 00 00       	jmp    f0103d66 <trap+0x205>
		return;
	}

	
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0103ccf:	83 f8 27             	cmp    $0x27,%eax
f0103cd2:	75 1a                	jne    f0103cee <trap+0x18d>
		cprintf("Spurious interrupt on irq 7\n");
f0103cd4:	83 ec 0c             	sub    $0xc,%esp
f0103cd7:	68 dd 7d 10 f0       	push   $0xf0107ddd
f0103cdc:	e8 7f f9 ff ff       	call   f0103660 <cprintf>
		print_trapframe(tf);
f0103ce1:	89 34 24             	mov    %esi,(%esp)
f0103ce4:	e8 ce fb ff ff       	call   f01038b7 <print_trapframe>
f0103ce9:	83 c4 10             	add    $0x10,%esp
f0103cec:	eb 78                	jmp    f0103d66 <trap+0x205>
	// LAB 4: Your code here.
	// Add time tick increment to clock interrupts.
	// Be careful! In multiprocessors, clock interrupts are
	// triggered on every CPU.
	// LAB 6: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0103cee:	83 f8 20             	cmp    $0x20,%eax
f0103cf1:	75 18                	jne    f0103d0b <trap+0x1aa>
		
		if (cpunum() == 0)
f0103cf3:	e8 0a 1b 00 00       	call   f0105802 <cpunum>
f0103cf8:	85 c0                	test   %eax,%eax
f0103cfa:	75 05                	jne    f0103d01 <trap+0x1a0>
			time_tick();
f0103cfc:	e8 ac 29 00 00       	call   f01066ad <time_tick>

		lapic_eoi();
f0103d01:	e8 47 1c 00 00       	call   f010594d <lapic_eoi>
		sched_yield();
f0103d06:	e8 90 02 00 00       	call   f0103f9b <sched_yield>
	}

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_KBD) {
f0103d0b:	83 f8 21             	cmp    $0x21,%eax
f0103d0e:	75 07                	jne    f0103d17 <trap+0x1b6>
		kbd_intr();
f0103d10:	e8 ed c8 ff ff       	call   f0100602 <kbd_intr>
f0103d15:	eb 4f                	jmp    f0103d66 <trap+0x205>
		return;
	}

	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL) {
f0103d17:	83 f8 24             	cmp    $0x24,%eax
f0103d1a:	75 07                	jne    f0103d23 <trap+0x1c2>
		serial_intr();
f0103d1c:	e8 c5 c8 ff ff       	call   f01005e6 <serial_intr>
f0103d21:	eb 43                	jmp    f0103d66 <trap+0x205>
		return;
	}

	
	print_trapframe(tf);
f0103d23:	83 ec 0c             	sub    $0xc,%esp
f0103d26:	56                   	push   %esi
f0103d27:	e8 8b fb ff ff       	call   f01038b7 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103d2c:	83 c4 10             	add    $0x10,%esp
f0103d2f:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103d34:	75 17                	jne    f0103d4d <trap+0x1ec>
		panic("unhandled trap in kernel");
f0103d36:	83 ec 04             	sub    $0x4,%esp
f0103d39:	68 fa 7d 10 f0       	push   $0xf0107dfa
f0103d3e:	68 12 01 00 00       	push   $0x112
f0103d43:	68 b1 7d 10 f0       	push   $0xf0107db1
f0103d48:	e8 f3 c2 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0103d4d:	e8 b0 1a 00 00       	call   f0105802 <cpunum>
f0103d52:	83 ec 0c             	sub    $0xc,%esp
f0103d55:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d58:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f0103d5e:	e8 2e f6 ff ff       	call   f0103391 <env_destroy>
f0103d63:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0103d66:	e8 97 1a 00 00       	call   f0105802 <cpunum>
f0103d6b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d6e:	83 b8 28 20 2a f0 00 	cmpl   $0x0,-0xfd5dfd8(%eax)
f0103d75:	74 2a                	je     f0103da1 <trap+0x240>
f0103d77:	e8 86 1a 00 00       	call   f0105802 <cpunum>
f0103d7c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d7f:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f0103d85:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d89:	75 16                	jne    f0103da1 <trap+0x240>
		env_run(curenv);
f0103d8b:	e8 72 1a 00 00       	call   f0105802 <cpunum>
f0103d90:	83 ec 0c             	sub    $0xc,%esp
f0103d93:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d96:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f0103d9c:	e8 8f f6 ff ff       	call   f0103430 <env_run>
	else
		sched_yield();
f0103da1:	e8 f5 01 00 00       	call   f0103f9b <sched_yield>

f0103da6 <handler0>:
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

# Handlers for process exceptions
TRAPHANDLER_NOEC(handler0, 0)
f0103da6:	6a 00                	push   $0x0
f0103da8:	6a 00                	push   $0x0
f0103daa:	e9 03 01 00 00       	jmp    f0103eb2 <_alltraps>
f0103daf:	90                   	nop

f0103db0 <handler1>:
TRAPHANDLER_NOEC(handler1, 1)
f0103db0:	6a 00                	push   $0x0
f0103db2:	6a 01                	push   $0x1
f0103db4:	e9 f9 00 00 00       	jmp    f0103eb2 <_alltraps>
f0103db9:	90                   	nop

f0103dba <handler2>:
TRAPHANDLER_NOEC(handler2, 2)
f0103dba:	6a 00                	push   $0x0
f0103dbc:	6a 02                	push   $0x2
f0103dbe:	e9 ef 00 00 00       	jmp    f0103eb2 <_alltraps>
f0103dc3:	90                   	nop

f0103dc4 <handler3>:
TRAPHANDLER_NOEC(handler3, 3)
f0103dc4:	6a 00                	push   $0x0
f0103dc6:	6a 03                	push   $0x3
f0103dc8:	e9 e5 00 00 00       	jmp    f0103eb2 <_alltraps>
f0103dcd:	90                   	nop

f0103dce <handler4>:
TRAPHANDLER_NOEC(handler4, 4)
f0103dce:	6a 00                	push   $0x0
f0103dd0:	6a 04                	push   $0x4
f0103dd2:	e9 db 00 00 00       	jmp    f0103eb2 <_alltraps>
f0103dd7:	90                   	nop

f0103dd8 <handler5>:
TRAPHANDLER_NOEC(handler5, 5)
f0103dd8:	6a 00                	push   $0x0
f0103dda:	6a 05                	push   $0x5
f0103ddc:	e9 d1 00 00 00       	jmp    f0103eb2 <_alltraps>
f0103de1:	90                   	nop

f0103de2 <handler6>:
TRAPHANDLER_NOEC(handler6, 6)
f0103de2:	6a 00                	push   $0x0
f0103de4:	6a 06                	push   $0x6
f0103de6:	e9 c7 00 00 00       	jmp    f0103eb2 <_alltraps>
f0103deb:	90                   	nop

f0103dec <handler7>:
TRAPHANDLER_NOEC(handler7, 7)
f0103dec:	6a 00                	push   $0x0
f0103dee:	6a 07                	push   $0x7
f0103df0:	e9 bd 00 00 00       	jmp    f0103eb2 <_alltraps>
f0103df5:	90                   	nop

f0103df6 <handler8>:
TRAPHANDLER(handler8, 8)
f0103df6:	6a 08                	push   $0x8
f0103df8:	e9 b5 00 00 00       	jmp    f0103eb2 <_alltraps>
f0103dfd:	90                   	nop

f0103dfe <handler9>:
TRAPHANDLER_NOEC(handler9, 9)
f0103dfe:	6a 00                	push   $0x0
f0103e00:	6a 09                	push   $0x9
f0103e02:	e9 ab 00 00 00       	jmp    f0103eb2 <_alltraps>
f0103e07:	90                   	nop

f0103e08 <handler10>:
TRAPHANDLER(handler10, 10)
f0103e08:	6a 0a                	push   $0xa
f0103e0a:	e9 a3 00 00 00       	jmp    f0103eb2 <_alltraps>
f0103e0f:	90                   	nop

f0103e10 <handler11>:
TRAPHANDLER(handler11, 11)
f0103e10:	6a 0b                	push   $0xb
f0103e12:	e9 9b 00 00 00       	jmp    f0103eb2 <_alltraps>
f0103e17:	90                   	nop

f0103e18 <handler12>:
TRAPHANDLER(handler12, 12)
f0103e18:	6a 0c                	push   $0xc
f0103e1a:	e9 93 00 00 00       	jmp    f0103eb2 <_alltraps>
f0103e1f:	90                   	nop

f0103e20 <handler13>:
TRAPHANDLER(handler13, 13)
f0103e20:	6a 0d                	push   $0xd
f0103e22:	e9 8b 00 00 00       	jmp    f0103eb2 <_alltraps>
f0103e27:	90                   	nop

f0103e28 <handler14>:
TRAPHANDLER(handler14, 14)
f0103e28:	6a 0e                	push   $0xe
f0103e2a:	e9 83 00 00 00       	jmp    f0103eb2 <_alltraps>
f0103e2f:	90                   	nop

f0103e30 <handler15>:
TRAPHANDLER_NOEC(handler15, 15)
f0103e30:	6a 00                	push   $0x0
f0103e32:	6a 0f                	push   $0xf
f0103e34:	eb 7c                	jmp    f0103eb2 <_alltraps>

f0103e36 <handler16>:
TRAPHANDLER_NOEC(handler16, 16)
f0103e36:	6a 00                	push   $0x0
f0103e38:	6a 10                	push   $0x10
f0103e3a:	eb 76                	jmp    f0103eb2 <_alltraps>

f0103e3c <handler17>:
TRAPHANDLER(handler17, 17)
f0103e3c:	6a 11                	push   $0x11
f0103e3e:	eb 72                	jmp    f0103eb2 <_alltraps>

f0103e40 <handler18>:
TRAPHANDLER_NOEC(handler18, 18)
f0103e40:	6a 00                	push   $0x0
f0103e42:	6a 12                	push   $0x12
f0103e44:	eb 6c                	jmp    f0103eb2 <_alltraps>

f0103e46 <handler19>:
TRAPHANDLER_NOEC(handler19, 19)
f0103e46:	6a 00                	push   $0x0
f0103e48:	6a 13                	push   $0x13
f0103e4a:	eb 66                	jmp    f0103eb2 <_alltraps>

f0103e4c <handler_irq0>:

# Handlers for external interrupts
TRAPHANDLER_NOEC(handler_irq0, IRQ_OFFSET + 0)
f0103e4c:	6a 00                	push   $0x0
f0103e4e:	6a 20                	push   $0x20
f0103e50:	eb 60                	jmp    f0103eb2 <_alltraps>

f0103e52 <handler_irq1>:
TRAPHANDLER_NOEC(handler_irq1, IRQ_OFFSET + 1)
f0103e52:	6a 00                	push   $0x0
f0103e54:	6a 21                	push   $0x21
f0103e56:	eb 5a                	jmp    f0103eb2 <_alltraps>

f0103e58 <handler_irq2>:
TRAPHANDLER_NOEC(handler_irq2, IRQ_OFFSET + 2)
f0103e58:	6a 00                	push   $0x0
f0103e5a:	6a 22                	push   $0x22
f0103e5c:	eb 54                	jmp    f0103eb2 <_alltraps>

f0103e5e <handler_irq3>:
TRAPHANDLER_NOEC(handler_irq3, IRQ_OFFSET + 3)
f0103e5e:	6a 00                	push   $0x0
f0103e60:	6a 23                	push   $0x23
f0103e62:	eb 4e                	jmp    f0103eb2 <_alltraps>

f0103e64 <handler_irq4>:
TRAPHANDLER_NOEC(handler_irq4, IRQ_OFFSET + 4)
f0103e64:	6a 00                	push   $0x0
f0103e66:	6a 24                	push   $0x24
f0103e68:	eb 48                	jmp    f0103eb2 <_alltraps>

f0103e6a <handler_irq5>:
TRAPHANDLER_NOEC(handler_irq5, IRQ_OFFSET + 5)
f0103e6a:	6a 00                	push   $0x0
f0103e6c:	6a 25                	push   $0x25
f0103e6e:	eb 42                	jmp    f0103eb2 <_alltraps>

f0103e70 <handler_irq6>:
TRAPHANDLER_NOEC(handler_irq6, IRQ_OFFSET + 6)
f0103e70:	6a 00                	push   $0x0
f0103e72:	6a 26                	push   $0x26
f0103e74:	eb 3c                	jmp    f0103eb2 <_alltraps>

f0103e76 <handler_irq7>:
TRAPHANDLER_NOEC(handler_irq7, IRQ_OFFSET + 7)
f0103e76:	6a 00                	push   $0x0
f0103e78:	6a 27                	push   $0x27
f0103e7a:	eb 36                	jmp    f0103eb2 <_alltraps>

f0103e7c <handler_irq8>:
TRAPHANDLER_NOEC(handler_irq8, IRQ_OFFSET + 8)
f0103e7c:	6a 00                	push   $0x0
f0103e7e:	6a 28                	push   $0x28
f0103e80:	eb 30                	jmp    f0103eb2 <_alltraps>

f0103e82 <handler_irq9>:
TRAPHANDLER_NOEC(handler_irq9, IRQ_OFFSET + 9)
f0103e82:	6a 00                	push   $0x0
f0103e84:	6a 29                	push   $0x29
f0103e86:	eb 2a                	jmp    f0103eb2 <_alltraps>

f0103e88 <handler_irq10>:
TRAPHANDLER_NOEC(handler_irq10,IRQ_OFFSET + 10)
f0103e88:	6a 00                	push   $0x0
f0103e8a:	6a 2a                	push   $0x2a
f0103e8c:	eb 24                	jmp    f0103eb2 <_alltraps>

f0103e8e <handler_irq11>:
TRAPHANDLER_NOEC(handler_irq11,IRQ_OFFSET + 11)
f0103e8e:	6a 00                	push   $0x0
f0103e90:	6a 2b                	push   $0x2b
f0103e92:	eb 1e                	jmp    f0103eb2 <_alltraps>

f0103e94 <handler_irq12>:
TRAPHANDLER_NOEC(handler_irq12,IRQ_OFFSET + 12)
f0103e94:	6a 00                	push   $0x0
f0103e96:	6a 2c                	push   $0x2c
f0103e98:	eb 18                	jmp    f0103eb2 <_alltraps>

f0103e9a <handler_irq13>:
TRAPHANDLER_NOEC(handler_irq13,IRQ_OFFSET + 13)
f0103e9a:	6a 00                	push   $0x0
f0103e9c:	6a 2d                	push   $0x2d
f0103e9e:	eb 12                	jmp    f0103eb2 <_alltraps>

f0103ea0 <handler_irq14>:
TRAPHANDLER_NOEC(handler_irq14,IRQ_OFFSET + 14)
f0103ea0:	6a 00                	push   $0x0
f0103ea2:	6a 2e                	push   $0x2e
f0103ea4:	eb 0c                	jmp    f0103eb2 <_alltraps>

f0103ea6 <handler_irq15>:
TRAPHANDLER_NOEC(handler_irq15,IRQ_OFFSET + 15)
f0103ea6:	6a 00                	push   $0x0
f0103ea8:	6a 2f                	push   $0x2f
f0103eaa:	eb 06                	jmp    f0103eb2 <_alltraps>

f0103eac <handler_syscall>:

# For system call
TRAPHANDLER_NOEC(handler_syscall, T_SYSCALL)
f0103eac:	6a 00                	push   $0x0
f0103eae:	6a 30                	push   $0x30
f0103eb0:	eb 00                	jmp    f0103eb2 <_alltraps>

f0103eb2 <_alltraps>:
 */
// TODO: Replace mov with movw
.globl _alltraps
_alltraps:
	# Push values to make the stack look like a struct Trapframe
	pushl %ds
f0103eb2:	1e                   	push   %ds
	pushl %es
f0103eb3:	06                   	push   %es
	pushal
f0103eb4:	60                   	pusha  

	# Load GD_KD into %ds and %es
	mov $GD_KD, %eax
f0103eb5:	b8 10 00 00 00       	mov    $0x10,%eax
	mov %ax, %ds
f0103eba:	8e d8                	mov    %eax,%ds
	mov %ax, %es
f0103ebc:	8e c0                	mov    %eax,%es

	# Call trap(tf), where tf=%esp
	pushl %esp
f0103ebe:	54                   	push   %esp
	call trap
f0103ebf:	e8 9d fc ff ff       	call   f0103b61 <trap>
	addl $4, %esp
f0103ec4:	83 c4 04             	add    $0x4,%esp

f0103ec7 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0103ec7:	55                   	push   %ebp
f0103ec8:	89 e5                	mov    %esp,%ebp
f0103eca:	83 ec 08             	sub    $0x8,%esp
f0103ecd:	a1 48 12 2a f0       	mov    0xf02a1248,%eax
f0103ed2:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0103ed5:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0103eda:	8b 02                	mov    (%edx),%eax
f0103edc:	83 e8 01             	sub    $0x1,%eax
f0103edf:	83 f8 02             	cmp    $0x2,%eax
f0103ee2:	76 10                	jbe    f0103ef4 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0103ee4:	83 c1 01             	add    $0x1,%ecx
f0103ee7:	83 c2 7c             	add    $0x7c,%edx
f0103eea:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103ef0:	75 e8                	jne    f0103eda <sched_halt+0x13>
f0103ef2:	eb 08                	jmp    f0103efc <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0103ef4:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103efa:	75 1f                	jne    f0103f1b <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f0103efc:	83 ec 0c             	sub    $0xc,%esp
f0103eff:	68 d0 7f 10 f0       	push   $0xf0107fd0
f0103f04:	e8 57 f7 ff ff       	call   f0103660 <cprintf>
f0103f09:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0103f0c:	83 ec 0c             	sub    $0xc,%esp
f0103f0f:	6a 00                	push   $0x0
f0103f11:	e8 e0 c9 ff ff       	call   f01008f6 <monitor>
f0103f16:	83 c4 10             	add    $0x10,%esp
f0103f19:	eb f1                	jmp    f0103f0c <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0103f1b:	e8 e2 18 00 00       	call   f0105802 <cpunum>
f0103f20:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f23:	c7 80 28 20 2a f0 00 	movl   $0x0,-0xfd5dfd8(%eax)
f0103f2a:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0103f2d:	a1 9c 1e 2a f0       	mov    0xf02a1e9c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103f32:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103f37:	77 12                	ja     f0103f4b <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103f39:	50                   	push   %eax
f0103f3a:	68 c8 69 10 f0       	push   $0xf01069c8
f0103f3f:	6a 5a                	push   $0x5a
f0103f41:	68 f9 7f 10 f0       	push   $0xf0107ff9
f0103f46:	e8 f5 c0 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103f4b:	05 00 00 00 10       	add    $0x10000000,%eax
f0103f50:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0103f53:	e8 aa 18 00 00       	call   f0105802 <cpunum>
f0103f58:	6b d0 74             	imul   $0x74,%eax,%edx
f0103f5b:	81 c2 20 20 2a f0    	add    $0xf02a2020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0103f61:	b8 02 00 00 00       	mov    $0x2,%eax
f0103f66:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103f6a:	83 ec 0c             	sub    $0xc,%esp
f0103f6d:	68 60 34 12 f0       	push   $0xf0123460
f0103f72:	e8 96 1b 00 00       	call   f0105b0d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103f77:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0103f79:	e8 84 18 00 00       	call   f0105802 <cpunum>
f0103f7e:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0103f81:	8b 80 30 20 2a f0    	mov    -0xfd5dfd0(%eax),%eax
f0103f87:	bd 00 00 00 00       	mov    $0x0,%ebp
f0103f8c:	89 c4                	mov    %eax,%esp
f0103f8e:	6a 00                	push   $0x0
f0103f90:	6a 00                	push   $0x0
f0103f92:	fb                   	sti    
f0103f93:	f4                   	hlt    
f0103f94:	eb fd                	jmp    f0103f93 <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0103f96:	83 c4 10             	add    $0x10,%esp
f0103f99:	c9                   	leave  
f0103f9a:	c3                   	ret    

f0103f9b <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0103f9b:	55                   	push   %ebp
f0103f9c:	89 e5                	mov    %esp,%ebp
f0103f9e:	53                   	push   %ebx
f0103f9f:	83 ec 04             	sub    $0x4,%esp
	// below to halt the cpu.

	// LAB 4: Your code here.
	//cprintf("DEBUG-SCHED: CPU %d - In scheduler, curenv = %p\n", cpunum(), curenv);
	struct Env *e;
	if (curenv) {
f0103fa2:	e8 5b 18 00 00       	call   f0105802 <cpunum>
f0103fa7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103faa:	83 b8 28 20 2a f0 00 	cmpl   $0x0,-0xfd5dfd8(%eax)
f0103fb1:	0f 84 83 00 00 00    	je     f010403a <sched_yield+0x9f>
		for (e = curenv + 1; e < envs + NENV; e++) {
f0103fb7:	e8 46 18 00 00       	call   f0105802 <cpunum>
f0103fbc:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fbf:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f0103fc5:	83 c0 7c             	add    $0x7c,%eax
f0103fc8:	8b 1d 48 12 2a f0    	mov    0xf02a1248,%ebx
f0103fce:	8d 93 00 f0 01 00    	lea    0x1f000(%ebx),%edx
f0103fd4:	eb 12                	jmp    f0103fe8 <sched_yield+0x4d>
			if (e->env_status == ENV_RUNNABLE) {
f0103fd6:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0103fda:	75 09                	jne    f0103fe5 <sched_yield+0x4a>
				//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), e);
				env_run(e);
f0103fdc:	83 ec 0c             	sub    $0xc,%esp
f0103fdf:	50                   	push   %eax
f0103fe0:	e8 4b f4 ff ff       	call   f0103430 <env_run>

	// LAB 4: Your code here.
	//cprintf("DEBUG-SCHED: CPU %d - In scheduler, curenv = %p\n", cpunum(), curenv);
	struct Env *e;
	if (curenv) {
		for (e = curenv + 1; e < envs + NENV; e++) {
f0103fe5:	83 c0 7c             	add    $0x7c,%eax
f0103fe8:	39 d0                	cmp    %edx,%eax
f0103fea:	72 ea                	jb     f0103fd6 <sched_yield+0x3b>
f0103fec:	eb 12                	jmp    f0104000 <sched_yield+0x65>
				//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), e);
				env_run(e);
			}
		}
		for (e = envs; e < curenv; e++) {
			if (e->env_status == ENV_RUNNABLE) {
f0103fee:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f0103ff2:	75 09                	jne    f0103ffd <sched_yield+0x62>
				//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), e);
				env_run(e);
f0103ff4:	83 ec 0c             	sub    $0xc,%esp
f0103ff7:	53                   	push   %ebx
f0103ff8:	e8 33 f4 ff ff       	call   f0103430 <env_run>
			if (e->env_status == ENV_RUNNABLE) {
				//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), e);
				env_run(e);
			}
		}
		for (e = envs; e < curenv; e++) {
f0103ffd:	83 c3 7c             	add    $0x7c,%ebx
f0104000:	e8 fd 17 00 00       	call   f0105802 <cpunum>
f0104005:	6b c0 74             	imul   $0x74,%eax,%eax
f0104008:	3b 98 28 20 2a f0    	cmp    -0xfd5dfd8(%eax),%ebx
f010400e:	72 de                	jb     f0103fee <sched_yield+0x53>
				//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), e);
				env_run(e);
			}
		}
		// If didn't find any runnable, try to keep running curenv
		if (curenv->env_status == ENV_RUNNING) {
f0104010:	e8 ed 17 00 00       	call   f0105802 <cpunum>
f0104015:	6b c0 74             	imul   $0x74,%eax,%eax
f0104018:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f010401e:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104022:	75 39                	jne    f010405d <sched_yield+0xc2>
			//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), curenv);
			env_run(curenv);
f0104024:	e8 d9 17 00 00       	call   f0105802 <cpunum>
f0104029:	83 ec 0c             	sub    $0xc,%esp
f010402c:	6b c0 74             	imul   $0x74,%eax,%eax
f010402f:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f0104035:	e8 f6 f3 ff ff       	call   f0103430 <env_run>
		}
	} else {
		for (e = envs; e < envs + NENV; e++) {
f010403a:	a1 48 12 2a f0       	mov    0xf02a1248,%eax
f010403f:	8d 90 00 f0 01 00    	lea    0x1f000(%eax),%edx
f0104045:	eb 12                	jmp    f0104059 <sched_yield+0xbe>
			if (e->env_status == ENV_RUNNABLE) {
f0104047:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f010404b:	75 09                	jne    f0104056 <sched_yield+0xbb>
				//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), e);
				env_run(e);
f010404d:	83 ec 0c             	sub    $0xc,%esp
f0104050:	50                   	push   %eax
f0104051:	e8 da f3 ff ff       	call   f0103430 <env_run>
		if (curenv->env_status == ENV_RUNNING) {
			//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), curenv);
			env_run(curenv);
		}
	} else {
		for (e = envs; e < envs + NENV; e++) {
f0104056:	83 c0 7c             	add    $0x7c,%eax
f0104059:	39 d0                	cmp    %edx,%eax
f010405b:	75 ea                	jne    f0104047 <sched_yield+0xac>
		}
	}

	// sched_halt never returns
	//cprintf("DEBUG-SCHED: CPU %d: no env to run found\n", cpunum());
	sched_halt();
f010405d:	e8 65 fe ff ff       	call   f0103ec7 <sched_halt>
}
f0104062:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104065:	c9                   	leave  
f0104066:	c3                   	ret    

f0104067 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104067:	55                   	push   %ebp
f0104068:	89 e5                	mov    %esp,%ebp
f010406a:	57                   	push   %edi
f010406b:	56                   	push   %esi
f010406c:	53                   	push   %ebx
f010406d:	83 ec 1c             	sub    $0x1c,%esp
f0104070:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int32_t ret = 0;

	switch (syscallno) {
f0104073:	83 f8 11             	cmp    $0x11,%eax
f0104076:	0f 87 5d 06 00 00    	ja     f01046d9 <syscall+0x672>
f010407c:	ff 24 85 50 80 10 f0 	jmp    *-0xfef7fb0(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);
f0104083:	e8 7a 17 00 00       	call   f0105802 <cpunum>
f0104088:	6a 00                	push   $0x0
f010408a:	ff 75 10             	pushl  0x10(%ebp)
f010408d:	ff 75 0c             	pushl  0xc(%ebp)
f0104090:	6b c0 74             	imul   $0x74,%eax,%eax
f0104093:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f0104099:	e8 7e ed ff ff       	call   f0102e1c <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f010409e:	83 c4 0c             	add    $0xc,%esp
f01040a1:	ff 75 0c             	pushl  0xc(%ebp)
f01040a4:	ff 75 10             	pushl  0x10(%ebp)
f01040a7:	68 06 80 10 f0       	push   $0xf0108006
f01040ac:	e8 af f5 ff ff       	call   f0103660 <cprintf>
f01040b1:	83 c4 10             	add    $0x10,%esp
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int32_t ret = 0;
f01040b4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01040b9:	e9 43 06 00 00       	jmp    f0104701 <syscall+0x69a>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01040be:	e8 51 c5 ff ff       	call   f0100614 <cons_getc>
f01040c3:	89 c3                	mov    %eax,%ebx
		sys_cputs((char *) a1, (size_t) a2);
		break;
	case SYS_cgetc:
		
		ret = sys_cgetc();
		break;
f01040c5:	e9 37 06 00 00       	jmp    f0104701 <syscall+0x69a>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01040ca:	e8 33 17 00 00       	call   f0105802 <cpunum>
f01040cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01040d2:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f01040d8:	8b 58 48             	mov    0x48(%eax),%ebx
		ret = sys_cgetc();
		break;
	case SYS_getenvid:
		
		ret = (int32_t) sys_getenvid();
		break;
f01040db:	e9 21 06 00 00       	jmp    f0104701 <syscall+0x69a>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01040e0:	83 ec 04             	sub    $0x4,%esp
f01040e3:	6a 01                	push   $0x1
f01040e5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01040e8:	50                   	push   %eax
f01040e9:	ff 75 0c             	pushl  0xc(%ebp)
f01040ec:	e8 d2 ed ff ff       	call   f0102ec3 <envid2env>
f01040f1:	83 c4 10             	add    $0x10,%esp
		return r;
f01040f4:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01040f6:	85 c0                	test   %eax,%eax
f01040f8:	0f 88 03 06 00 00    	js     f0104701 <syscall+0x69a>
		return r;
	env_destroy(e);
f01040fe:	83 ec 0c             	sub    $0xc,%esp
f0104101:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104104:	e8 88 f2 ff ff       	call   f0103391 <env_destroy>
f0104109:	83 c4 10             	add    $0x10,%esp
	return 0;
f010410c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104111:	e9 eb 05 00 00       	jmp    f0104701 <syscall+0x69a>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104116:	e8 80 fe ff ff       	call   f0103f9b <sched_yield>
	// will appear to return 0.

	// LAB 4: Your code here.
	// Tries to allocate new env in e
	struct Env *e;
	int error = env_alloc(&e, curenv->env_id);
f010411b:	e8 e2 16 00 00       	call   f0105802 <cpunum>
f0104120:	83 ec 08             	sub    $0x8,%esp
f0104123:	6b c0 74             	imul   $0x74,%eax,%eax
f0104126:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f010412c:	ff 70 48             	pushl  0x48(%eax)
f010412f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104132:	50                   	push   %eax
f0104133:	e8 9d ee ff ff       	call   f0102fd5 <env_alloc>
	// Check if it failed, and pass the error. Can be -E_NO_FREE_ENV or -E_NO_MEM
	if (error < 0) {
f0104138:	83 c4 10             	add    $0x10,%esp
		return error;
f010413b:	89 c3                	mov    %eax,%ebx
	// LAB 4: Your code here.
	// Tries to allocate new env in e
	struct Env *e;
	int error = env_alloc(&e, curenv->env_id);
	// Check if it failed, and pass the error. Can be -E_NO_FREE_ENV or -E_NO_MEM
	if (error < 0) {
f010413d:	85 c0                	test   %eax,%eax
f010413f:	0f 88 bc 05 00 00    	js     f0104701 <syscall+0x69a>
		return error;
	}

	e->env_status = ENV_NOT_RUNNABLE;
f0104145:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104148:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	e->env_tf = curenv->env_tf; // trap() has copied the tf that is on kstack to curenv
f010414f:	e8 ae 16 00 00       	call   f0105802 <cpunum>
f0104154:	6b c0 74             	imul   $0x74,%eax,%eax
f0104157:	8b b0 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%esi
f010415d:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104162:	89 df                	mov    %ebx,%edi
f0104164:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

	// Tweak the tf so sys_exofork will appear to return 0.
	// eax holds the return value of the system call, so just make it zero.
	e->env_tf.tf_regs.reg_eax = 0;
f0104166:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104169:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return e->env_id;
f0104170:	8b 58 48             	mov    0x48(%eax),%ebx
f0104173:	e9 89 05 00 00       	jmp    f0104701 <syscall+0x69a>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	// Check if the status is valid
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) {
f0104178:	8b 45 10             	mov    0x10(%ebp),%eax
f010417b:	83 e8 02             	sub    $0x2,%eax
f010417e:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104183:	75 2b                	jne    f01041b0 <syscall+0x149>
		return -E_INVAL;
	}

	// Tries to retrieve the env
	struct Env *e;
	int error = envid2env(envid, &e, 1);
f0104185:	83 ec 04             	sub    $0x4,%esp
f0104188:	6a 01                	push   $0x1
f010418a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010418d:	50                   	push   %eax
f010418e:	ff 75 0c             	pushl  0xc(%ebp)
f0104191:	e8 2d ed ff ff       	call   f0102ec3 <envid2env>
	if (error < 0) { // If error <0, it is -E_BAD_ENV
f0104196:	83 c4 10             	add    $0x10,%esp
f0104199:	85 c0                	test   %eax,%eax
f010419b:	78 1d                	js     f01041ba <syscall+0x153>
		return error;
	}

	// Set the environment status
	e->env_status = status;
f010419d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01041a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01041a3:	89 48 54             	mov    %ecx,0x54(%eax)
	return 0;
f01041a6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01041ab:	e9 51 05 00 00       	jmp    f0104701 <syscall+0x69a>
	// envid's status.

	// LAB 4: Your code here.
	// Check if the status is valid
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) {
		return -E_INVAL;
f01041b0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01041b5:	e9 47 05 00 00       	jmp    f0104701 <syscall+0x69a>

	// Tries to retrieve the env
	struct Env *e;
	int error = envid2env(envid, &e, 1);
	if (error < 0) { // If error <0, it is -E_BAD_ENV
		return error;
f01041ba:	89 c3                	mov    %eax,%ebx
		ret = (int32_t) sys_exofork();
		break;
	case SYS_env_set_status:
		
		ret = (int32_t) sys_env_set_status((envid_t) a1, (int) a2);
		break;
f01041bc:	e9 40 05 00 00       	jmp    f0104701 <syscall+0x69a>
	//   allocated!

	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 1);
f01041c1:	83 ec 04             	sub    $0x4,%esp
f01041c4:	6a 01                	push   $0x1
f01041c6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01041c9:	50                   	push   %eax
f01041ca:	ff 75 0c             	pushl  0xc(%ebp)
f01041cd:	e8 f1 ec ff ff       	call   f0102ec3 <envid2env>
	if (!e) {
f01041d2:	83 c4 10             	add    $0x10,%esp
f01041d5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01041d9:	74 69                	je     f0104244 <syscall+0x1dd>
		return -E_BAD_ENV;
	}

	// Checks if va is as expected
	if (((uint32_t)va >= UTOP) || ((uint32_t) va)%PGSIZE != 0) {
f01041db:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01041e2:	77 6a                	ja     f010424e <syscall+0x1e7>
f01041e4:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01041eb:	75 6b                	jne    f0104258 <syscall+0x1f1>
		return -E_INVAL;
	}

	// Checks if permission is appropiate
	if ((perm & (~PTE_SYSCALL)) != 0 ||   // No bit out of PTE_SYSCALL allowed
f01041ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01041f0:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f01041f6:	75 6a                	jne    f0104262 <syscall+0x1fb>
f01041f8:	f6 45 14 05          	testb  $0x5,0x14(%ebp)
f01041fc:	74 6e                	je     f010426c <syscall+0x205>
	    (perm & (PTE_U | PTE_P)) == 0) {  // These bits must be set
		return -E_INVAL;
	}

	// Tries to allocate a physical page
	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f01041fe:	83 ec 0c             	sub    $0xc,%esp
f0104201:	6a 01                	push   $0x1
f0104203:	e8 eb cc ff ff       	call   f0100ef3 <page_alloc>
f0104208:	89 c6                	mov    %eax,%esi
	if (!pp) {
f010420a:	83 c4 10             	add    $0x10,%esp
f010420d:	85 c0                	test   %eax,%eax
f010420f:	74 65                	je     f0104276 <syscall+0x20f>
		return -E_NO_MEM;
	}

	// Tries to map the physical page at va
	int error = page_insert(e->env_pgdir, pp, va, perm);
f0104211:	ff 75 14             	pushl  0x14(%ebp)
f0104214:	ff 75 10             	pushl  0x10(%ebp)
f0104217:	50                   	push   %eax
f0104218:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010421b:	ff 70 60             	pushl  0x60(%eax)
f010421e:	e8 0e d0 ff ff       	call   f0101231 <page_insert>
	if (error < 0) {
f0104223:	83 c4 10             	add    $0x10,%esp
f0104226:	85 c0                	test   %eax,%eax
f0104228:	0f 89 d3 04 00 00    	jns    f0104701 <syscall+0x69a>
		page_free(pp);
f010422e:	83 ec 0c             	sub    $0xc,%esp
f0104231:	56                   	push   %esi
f0104232:	e8 2c cd ff ff       	call   f0100f63 <page_free>
f0104237:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f010423a:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f010423f:	e9 bd 04 00 00       	jmp    f0104701 <syscall+0x69a>
	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 1);
	if (!e) {
		return -E_BAD_ENV;
f0104244:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104249:	e9 b3 04 00 00       	jmp    f0104701 <syscall+0x69a>
	}

	// Checks if va is as expected
	if (((uint32_t)va >= UTOP) || ((uint32_t) va)%PGSIZE != 0) {
		return -E_INVAL;
f010424e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104253:	e9 a9 04 00 00       	jmp    f0104701 <syscall+0x69a>
f0104258:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010425d:	e9 9f 04 00 00       	jmp    f0104701 <syscall+0x69a>
	}

	// Checks if permission is appropiate
	if ((perm & (~PTE_SYSCALL)) != 0 ||   // No bit out of PTE_SYSCALL allowed
	    (perm & (PTE_U | PTE_P)) == 0) {  // These bits must be set
		return -E_INVAL;
f0104262:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104267:	e9 95 04 00 00       	jmp    f0104701 <syscall+0x69a>
f010426c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104271:	e9 8b 04 00 00       	jmp    f0104701 <syscall+0x69a>
	}

	// Tries to allocate a physical page
	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
	if (!pp) {
		return -E_NO_MEM;
f0104276:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
		ret = (int32_t) sys_env_set_status((envid_t) a1, (int) a2);
		break;
	case SYS_page_alloc:
		
		ret = (int32_t) sys_page_alloc((envid_t) a1, (void *) a2, (int) a3);
		break;
f010427b:	e9 81 04 00 00       	jmp    f0104701 <syscall+0x69a>
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	// Tries to retrieve the environments
	struct Env *srcenv, *dstenv;
	envid2env(srcenvid, &srcenv, 1);
f0104280:	83 ec 04             	sub    $0x4,%esp
f0104283:	6a 01                	push   $0x1
f0104285:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104288:	50                   	push   %eax
f0104289:	ff 75 0c             	pushl  0xc(%ebp)
f010428c:	e8 32 ec ff ff       	call   f0102ec3 <envid2env>
	envid2env(dstenvid, &dstenv, 1);
f0104291:	83 c4 0c             	add    $0xc,%esp
f0104294:	6a 01                	push   $0x1
f0104296:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104299:	50                   	push   %eax
f010429a:	ff 75 14             	pushl  0x14(%ebp)
f010429d:	e8 21 ec ff ff       	call   f0102ec3 <envid2env>
	if (!srcenv || !dstenv) {
f01042a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01042a5:	83 c4 10             	add    $0x10,%esp
f01042a8:	85 c0                	test   %eax,%eax
f01042aa:	0f 84 9a 00 00 00    	je     f010434a <syscall+0x2e3>
f01042b0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01042b4:	0f 84 9a 00 00 00    	je     f0104354 <syscall+0x2ed>
		return -E_BAD_ENV;
	}

	// Checks if va's are as expected
	if (((uint32_t)srcva) >= UTOP || ((uint32_t) srcva)%PGSIZE != 0 ||
f01042ba:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01042c1:	0f 87 97 00 00 00    	ja     f010435e <syscall+0x2f7>
f01042c7:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01042ce:	0f 85 94 00 00 00    	jne    f0104368 <syscall+0x301>
f01042d4:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01042db:	0f 87 87 00 00 00    	ja     f0104368 <syscall+0x301>
	    ((uint32_t)dstva) >= UTOP || ((uint32_t) dstva)%PGSIZE != 0) {
f01042e1:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f01042e8:	0f 85 84 00 00 00    	jne    f0104372 <syscall+0x30b>
	}

	// Lookup for the physical page that is mapped at srcva
	// If srcva is not mapped in srcenv address space, pp is null
	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
f01042ee:	83 ec 04             	sub    $0x4,%esp
f01042f1:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01042f4:	52                   	push   %edx
f01042f5:	ff 75 10             	pushl  0x10(%ebp)
f01042f8:	ff 70 60             	pushl  0x60(%eax)
f01042fb:	e8 4b ce ff ff       	call   f010114b <page_lookup>
	if (!pp) {
f0104300:	83 c4 10             	add    $0x10,%esp
f0104303:	85 c0                	test   %eax,%eax
f0104305:	74 75                	je     f010437c <syscall+0x315>
		return -E_INVAL;
	}

	// Checks if permission is appropiate
	if ((perm & (~PTE_SYSCALL)) != 0 ||
f0104307:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f010430a:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f0104310:	75 74                	jne    f0104386 <syscall+0x31f>
f0104312:	f6 45 1c 05          	testb  $0x5,0x1c(%ebp)
f0104316:	74 78                	je     f0104390 <syscall+0x329>
		return -E_INVAL;
	}

	// Checks if srcva is read-only in srcenv, and it is trying to
	// permit writing in dstenv
	if (!(*pte & PTE_W) && (perm & PTE_W)) {
f0104318:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010431b:	f6 02 02             	testb  $0x2,(%edx)
f010431e:	75 06                	jne    f0104326 <syscall+0x2bf>
f0104320:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104324:	75 74                	jne    f010439a <syscall+0x333>
		return -E_INVAL;
	}

	// Tries to map the physical page at dstva on dstenv address space
	// Fails if there is no memory to allocate a page table, if needed
	int error = page_insert(dstenv->env_pgdir, pp, dstva, perm);
f0104326:	ff 75 1c             	pushl  0x1c(%ebp)
f0104329:	ff 75 18             	pushl  0x18(%ebp)
f010432c:	50                   	push   %eax
f010432d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104330:	ff 70 60             	pushl  0x60(%eax)
f0104333:	e8 f9 ce ff ff       	call   f0101231 <page_insert>
	if (error < 0) {
f0104338:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f010433b:	85 c0                	test   %eax,%eax
f010433d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104342:	0f 48 d8             	cmovs  %eax,%ebx
f0104345:	e9 b7 03 00 00       	jmp    f0104701 <syscall+0x69a>
	// Tries to retrieve the environments
	struct Env *srcenv, *dstenv;
	envid2env(srcenvid, &srcenv, 1);
	envid2env(dstenvid, &dstenv, 1);
	if (!srcenv || !dstenv) {
		return -E_BAD_ENV;
f010434a:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f010434f:	e9 ad 03 00 00       	jmp    f0104701 <syscall+0x69a>
f0104354:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104359:	e9 a3 03 00 00       	jmp    f0104701 <syscall+0x69a>
	}

	// Checks if va's are as expected
	if (((uint32_t)srcva) >= UTOP || ((uint32_t) srcva)%PGSIZE != 0 ||
	    ((uint32_t)dstva) >= UTOP || ((uint32_t) dstva)%PGSIZE != 0) {
		return -E_INVAL;
f010435e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104363:	e9 99 03 00 00       	jmp    f0104701 <syscall+0x69a>
f0104368:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010436d:	e9 8f 03 00 00       	jmp    f0104701 <syscall+0x69a>
f0104372:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104377:	e9 85 03 00 00       	jmp    f0104701 <syscall+0x69a>
	// Lookup for the physical page that is mapped at srcva
	// If srcva is not mapped in srcenv address space, pp is null
	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
	if (!pp) {
		return -E_INVAL;
f010437c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104381:	e9 7b 03 00 00       	jmp    f0104701 <syscall+0x69a>
	}

	// Checks if permission is appropiate
	if ((perm & (~PTE_SYSCALL)) != 0 ||
	    (perm & (PTE_U | PTE_P)) == 0) {
		return -E_INVAL;
f0104386:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010438b:	e9 71 03 00 00       	jmp    f0104701 <syscall+0x69a>
f0104390:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104395:	e9 67 03 00 00       	jmp    f0104701 <syscall+0x69a>
	}

	// Checks if srcva is read-only in srcenv, and it is trying to
	// permit writing in dstenv
	if (!(*pte & PTE_W) && (perm & PTE_W)) {
		return -E_INVAL;
f010439a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010439f:	e9 5d 03 00 00       	jmp    f0104701 <syscall+0x69a>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 1);
f01043a4:	83 ec 04             	sub    $0x4,%esp
f01043a7:	6a 01                	push   $0x1
f01043a9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01043ac:	50                   	push   %eax
f01043ad:	ff 75 0c             	pushl  0xc(%ebp)
f01043b0:	e8 0e eb ff ff       	call   f0102ec3 <envid2env>
	if (!e) {
f01043b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01043b8:	83 c4 10             	add    $0x10,%esp
f01043bb:	85 c0                	test   %eax,%eax
f01043bd:	74 2d                	je     f01043ec <syscall+0x385>
		return -E_BAD_ENV;
	}

	// Checks if va is as expected
	if (((uint32_t)va) >= UTOP || ((uint32_t) va)%PGSIZE != 0) {
f01043bf:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01043c6:	77 2e                	ja     f01043f6 <syscall+0x38f>
f01043c8:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01043cf:	75 2f                	jne    f0104400 <syscall+0x399>
		return -E_INVAL;
	}

	// Removes page
	page_remove(e->env_pgdir, va);
f01043d1:	83 ec 08             	sub    $0x8,%esp
f01043d4:	ff 75 10             	pushl  0x10(%ebp)
f01043d7:	ff 70 60             	pushl  0x60(%eax)
f01043da:	e8 0c ce ff ff       	call   f01011eb <page_remove>
f01043df:	83 c4 10             	add    $0x10,%esp
	return 0;
f01043e2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01043e7:	e9 15 03 00 00       	jmp    f0104701 <syscall+0x69a>
	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 1);
	if (!e) {
		return -E_BAD_ENV;
f01043ec:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01043f1:	e9 0b 03 00 00       	jmp    f0104701 <syscall+0x69a>
	}

	// Checks if va is as expected
	if (((uint32_t)va) >= UTOP || ((uint32_t) va)%PGSIZE != 0) {
		return -E_INVAL;
f01043f6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01043fb:	e9 01 03 00 00       	jmp    f0104701 <syscall+0x69a>
f0104400:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
					     (envid_t) a3, (void *) a4, (int) a5);
		break;
	case SYS_page_unmap:
		
		ret = (int32_t) sys_page_unmap((envid_t) a1, (void *) a2);
		break;
f0104405:	e9 f7 02 00 00       	jmp    f0104701 <syscall+0x69a>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 1);
f010440a:	83 ec 04             	sub    $0x4,%esp
f010440d:	6a 01                	push   $0x1
f010440f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104412:	50                   	push   %eax
f0104413:	ff 75 0c             	pushl  0xc(%ebp)
f0104416:	e8 a8 ea ff ff       	call   f0102ec3 <envid2env>
	if (!e) {
f010441b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010441e:	83 c4 10             	add    $0x10,%esp
f0104421:	85 c0                	test   %eax,%eax
f0104423:	74 10                	je     f0104435 <syscall+0x3ce>
		return -E_BAD_ENV;
	}

	// Set the page fault upcall
	e->env_pgfault_upcall = func;
f0104425:	8b 55 10             	mov    0x10(%ebp),%edx
f0104428:	89 50 64             	mov    %edx,0x64(%eax)
	return 0;
f010442b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104430:	e9 cc 02 00 00       	jmp    f0104701 <syscall+0x69a>
	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 1);
	if (!e) {
		return -E_BAD_ENV;
f0104435:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
		ret = (int32_t) sys_page_unmap((envid_t) a1, (void *) a2);
		break;
	case SYS_env_set_pgfault_upcall:
		
		ret = (int32_t) sys_env_set_pgfault_upcall((envid_t) a1, (void *) a2);
		break;
f010443a:	e9 c2 02 00 00       	jmp    f0104701 <syscall+0x69a>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 0); // Set to 0: can send to anyone
f010443f:	83 ec 04             	sub    $0x4,%esp
f0104442:	6a 00                	push   $0x0
f0104444:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104447:	50                   	push   %eax
f0104448:	ff 75 0c             	pushl  0xc(%ebp)
f010444b:	e8 73 ea ff ff       	call   f0102ec3 <envid2env>
	if (!e) {
f0104450:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104453:	83 c4 10             	add    $0x10,%esp
f0104456:	85 c0                	test   %eax,%eax
f0104458:	0f 84 fa 00 00 00    	je     f0104558 <syscall+0x4f1>
		return -E_BAD_ENV;
	}

	// Checks if the receiver is receiving
	if (!e->env_ipc_recving) {
f010445e:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104462:	0f 84 fa 00 00 00    	je     f0104562 <syscall+0x4fb>
		return -E_IPC_NOT_RECV;
	}

	// If the receiver is accepting a page
	// and the sender is trying to send a page
	if (((uint32_t) e->env_ipc_dstva) < UTOP && ((uint32_t) srcva) < UTOP) {
f0104468:	81 78 6c ff ff bf ee 	cmpl   $0xeebfffff,0x6c(%eax)
f010446f:	0f 87 a7 00 00 00    	ja     f010451c <syscall+0x4b5>
f0104475:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f010447c:	0f 87 9a 00 00 00    	ja     f010451c <syscall+0x4b5>
		// Checks if va is page aligned
		if (((uint32_t) srcva) % PGSIZE != 0)
			return -E_INVAL;
f0104482:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx

	// If the receiver is accepting a page
	// and the sender is trying to send a page
	if (((uint32_t) e->env_ipc_dstva) < UTOP && ((uint32_t) srcva) < UTOP) {
		// Checks if va is page aligned
		if (((uint32_t) srcva) % PGSIZE != 0)
f0104487:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f010448e:	0f 85 6d 02 00 00    	jne    f0104701 <syscall+0x69a>
			return -E_INVAL;

		// Checks if permission is appropiate
		if ((perm & (~PTE_SYSCALL)) != 0 ||   // No bit out of PTE_SYSCALL allowed
f0104494:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f010449b:	0f 85 60 02 00 00    	jne    f0104701 <syscall+0x69a>
f01044a1:	f6 45 18 05          	testb  $0x5,0x18(%ebp)
f01044a5:	0f 84 56 02 00 00    	je     f0104701 <syscall+0x69a>
		}

		// Lookup for the physical page that is mapped at srcva
		// If srcva is not mapped in srcenv address space, pp is null
		pte_t *pte;
		struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &pte);
f01044ab:	e8 52 13 00 00       	call   f0105802 <cpunum>
f01044b0:	83 ec 04             	sub    $0x4,%esp
f01044b3:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01044b6:	52                   	push   %edx
f01044b7:	ff 75 14             	pushl  0x14(%ebp)
f01044ba:	6b c0 74             	imul   $0x74,%eax,%eax
f01044bd:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f01044c3:	ff 70 60             	pushl  0x60(%eax)
f01044c6:	e8 80 cc ff ff       	call   f010114b <page_lookup>
		if (!pp) {
f01044cb:	83 c4 10             	add    $0x10,%esp
f01044ce:	85 c0                	test   %eax,%eax
f01044d0:	74 36                	je     f0104508 <syscall+0x4a1>
			return -E_INVAL;
		}

		// Checks if srcva is read-only in srcenv, and it is trying to
		// permit writing in dstva
		if (!(*pte & PTE_W) && (perm & PTE_W)) {
f01044d2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01044d5:	f6 02 02             	testb  $0x2,(%edx)
f01044d8:	75 0a                	jne    f01044e4 <syscall+0x47d>
f01044da:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f01044de:	0f 85 1d 02 00 00    	jne    f0104701 <syscall+0x69a>
			return -E_INVAL;
		}

		// Tries to map the physical page at dstva on dstenv address space
		// Fails if there is no memory to allocate a page table, if needed
		int error = page_insert(e->env_pgdir, pp, e->env_ipc_dstva, perm);
f01044e4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01044e7:	ff 75 18             	pushl  0x18(%ebp)
f01044ea:	ff 72 6c             	pushl  0x6c(%edx)
f01044ed:	50                   	push   %eax
f01044ee:	ff 72 60             	pushl  0x60(%edx)
f01044f1:	e8 3b cd ff ff       	call   f0101231 <page_insert>
		if (error < 0) {
f01044f6:	83 c4 10             	add    $0x10,%esp
f01044f9:	85 c0                	test   %eax,%eax
f01044fb:	78 15                	js     f0104512 <syscall+0x4ab>
			return -E_NO_MEM;
		}

		// Page successfully transfered
		e->env_ipc_perm = perm;
f01044fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104500:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0104503:	89 48 78             	mov    %ecx,0x78(%eax)
f0104506:	eb 1b                	jmp    f0104523 <syscall+0x4bc>
		// Lookup for the physical page that is mapped at srcva
		// If srcva is not mapped in srcenv address space, pp is null
		pte_t *pte;
		struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &pte);
		if (!pp) {
			return -E_INVAL;
f0104508:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010450d:	e9 ef 01 00 00       	jmp    f0104701 <syscall+0x69a>

		// Tries to map the physical page at dstva on dstenv address space
		// Fails if there is no memory to allocate a page table, if needed
		int error = page_insert(e->env_pgdir, pp, e->env_ipc_dstva, perm);
		if (error < 0) {
			return -E_NO_MEM;
f0104512:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104517:	e9 e5 01 00 00       	jmp    f0104701 <syscall+0x69a>

		// Page successfully transfered
		e->env_ipc_perm = perm;
	} else {
	// The receiver isn't accepting a page
		e->env_ipc_perm = 0;
f010451c:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	}

	// Deliver 'value' to the receiver
	e->env_ipc_recving = 0;
f0104523:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104526:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	e->env_ipc_from = curenv->env_id;
f010452a:	e8 d3 12 00 00       	call   f0105802 <cpunum>
f010452f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104532:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f0104538:	8b 40 48             	mov    0x48(%eax),%eax
f010453b:	89 43 74             	mov    %eax,0x74(%ebx)
	e->env_ipc_value = value;
f010453e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104541:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104544:	89 78 70             	mov    %edi,0x70(%eax)

	// The receiver has successfully received. Make it runnable
	e->env_status = ENV_RUNNABLE;
f0104547:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	return 0;
f010454e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104553:	e9 a9 01 00 00       	jmp    f0104701 <syscall+0x69a>
	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 0); // Set to 0: can send to anyone
	if (!e) {
		return -E_BAD_ENV;
f0104558:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f010455d:	e9 9f 01 00 00       	jmp    f0104701 <syscall+0x69a>
	}

	// Checks if the receiver is receiving
	if (!e->env_ipc_recving) {
		return -E_IPC_NOT_RECV;
f0104562:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
		break;
	case SYS_ipc_try_send:
		
		ret = (int32_t) sys_ipc_try_send((envid_t) a1, (uint32_t) a2,
						   (void*) a3, (unsigned) a4);
		break;
f0104567:	e9 95 01 00 00       	jmp    f0104701 <syscall+0x69a>
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	// Checks if va is page aligned, given that it is valid
	if (((uint32_t) dstva < UTOP) &&  (((uint32_t) dstva) % PGSIZE != 0)) {
f010456c:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104573:	77 0d                	ja     f0104582 <syscall+0x51b>
f0104575:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f010457c:	0f 85 5e 01 00 00    	jne    f01046e0 <syscall+0x679>
		return -E_INVAL;
	}

	// Record that you want to receive
	curenv->env_ipc_recving = 1;
f0104582:	e8 7b 12 00 00       	call   f0105802 <cpunum>
f0104587:	6b c0 74             	imul   $0x74,%eax,%eax
f010458a:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f0104590:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0104594:	e8 69 12 00 00       	call   f0105802 <cpunum>
f0104599:	6b c0 74             	imul   $0x74,%eax,%eax
f010459c:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f01045a2:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01045a5:	89 78 6c             	mov    %edi,0x6c(%eax)

	// Put the return value manually, since this never returns
	curenv->env_tf.tf_regs.reg_eax = 0;
f01045a8:	e8 55 12 00 00       	call   f0105802 <cpunum>
f01045ad:	6b c0 74             	imul   $0x74,%eax,%eax
f01045b0:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f01045b6:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	// Give up the cpu and wait until receiving
	curenv->env_status = ENV_NOT_RUNNABLE;
f01045bd:	e8 40 12 00 00       	call   f0105802 <cpunum>
f01045c2:	6b c0 74             	imul   $0x74,%eax,%eax
f01045c5:	8b 80 28 20 2a f0    	mov    -0xfd5dfd8(%eax),%eax
f01045cb:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f01045d2:	e8 c4 f9 ff ff       	call   f0103f9b <sched_yield>
		
		ret = (int32_t) sys_ipc_recv((void*) a1);
		break;
	case SYS_env_set_trapframe:
		
		ret = (int32_t) sys_env_set_trapframe((envid_t) a1,
f01045d7:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!

	// Check if user provided good addresses
	if (tf->tf_eip >= UTOP || tf->tf_esp >= UTOP)
f01045da:	81 7e 30 ff ff bf ee 	cmpl   $0xeebfffff,0x30(%esi)
f01045e1:	77 09                	ja     f01045ec <syscall+0x585>
f01045e3:	81 7e 3c ff ff bf ee 	cmpl   $0xeebfffff,0x3c(%esi)
f01045ea:	76 17                	jbe    f0104603 <syscall+0x59c>
		panic("sys_env_set_trapframe: user supplied bad address");
f01045ec:	83 ec 04             	sub    $0x4,%esp
f01045ef:	68 1c 80 10 f0       	push   $0xf010801c
f01045f4:	68 9a 00 00 00       	push   $0x9a
f01045f9:	68 0b 80 10 f0       	push   $0xf010800b
f01045fe:	e8 3d ba ff ff       	call   f0100040 <_panic>

	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 1);
f0104603:	83 ec 04             	sub    $0x4,%esp
f0104606:	6a 01                	push   $0x1
f0104608:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010460b:	50                   	push   %eax
f010460c:	ff 75 0c             	pushl  0xc(%ebp)
f010460f:	e8 af e8 ff ff       	call   f0102ec3 <envid2env>
	if (!e) {
f0104614:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104617:	83 c4 10             	add    $0x10,%esp
f010461a:	85 c0                	test   %eax,%eax
f010461c:	74 1f                	je     f010463d <syscall+0x5d6>
		return -E_BAD_ENV;
	}

	// Modify tf to make sure that CPL = 3 and interrupts are enabled
	tf->tf_cs |= 3;
f010461e:	66 83 4e 34 03       	orw    $0x3,0x34(%esi)
	tf->tf_eflags |= FL_IF;
f0104623:	81 4e 38 00 02 00 00 	orl    $0x200,0x38(%esi)

	// Set envid's trapframe to tf
	e->env_tf = *tf;
f010462a:	b9 11 00 00 00       	mov    $0x11,%ecx
f010462f:	89 c7                	mov    %eax,%edi
f0104631:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return 0;
f0104633:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104638:	e9 c4 00 00 00       	jmp    f0104701 <syscall+0x69a>

	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 1);
	if (!e) {
		return -E_BAD_ENV;
f010463d:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
		break;
	case SYS_env_set_trapframe:
		
		ret = (int32_t) sys_env_set_trapframe((envid_t) a1,
						      (struct Trapframe *) a2);
		break;
f0104642:	e9 ba 00 00 00       	jmp    f0104701 <syscall+0x69a>
// Return the current time.
static int
sys_time_msec(void)
{
	// LAB 6: Your code here.
	return time_msec();
f0104647:	e8 90 20 00 00       	call   f01066dc <time_msec>
f010464c:	89 c3                	mov    %eax,%ebx
						      (struct Trapframe *) a2);
		break;
	case SYS_time_msec:
		
		ret = (int32_t) sys_time_msec();
		break;
f010464e:	e9 ae 00 00 00       	jmp    f0104701 <syscall+0x69a>
	// Check arguments
	// buf should be in user space
	if (!buf || ((uint32_t) buf) > UTOP)
		return -E_INVAL;
	// size should not exceed the maximum
	if (size > MAX_PACKET_SIZE)
f0104653:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104656:	83 e8 01             	sub    $0x1,%eax
f0104659:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f010465e:	0f 87 83 00 00 00    	ja     f01046e7 <syscall+0x680>
f0104664:	81 7d 10 ee 05 00 00 	cmpl   $0x5ee,0x10(%ebp)
f010466b:	77 7a                	ja     f01046e7 <syscall+0x680>
		return -E_INVAL;

	transmit_packet(buf, size);
f010466d:	83 ec 08             	sub    $0x8,%esp
f0104670:	ff 75 10             	pushl  0x10(%ebp)
f0104673:	ff 75 0c             	pushl  0xc(%ebp)
f0104676:	e8 8a 17 00 00       	call   f0105e05 <transmit_packet>
f010467b:	83 c4 10             	add    $0x10,%esp
	return 0;
f010467e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104683:	eb 7c                	jmp    f0104701 <syscall+0x69a>
}

static int
sys_receive_packet(void *buf, size_t *size_store) {
	// Check pointers provided by user
	if (!buf || ((uint32_t) buf) > UTOP)
f0104685:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104688:	83 e8 01             	sub    $0x1,%eax
f010468b:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0104690:	77 5c                	ja     f01046ee <syscall+0x687>
		return -E_INVAL;
	if (!size_store || ((uint32_t) size_store) > UTOP)
f0104692:	8b 45 10             	mov    0x10(%ebp),%eax
f0104695:	83 e8 01             	sub    $0x1,%eax
f0104698:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f010469d:	77 56                	ja     f01046f5 <syscall+0x68e>
		return -E_INVAL;

	receive_packet(buf, size_store);
f010469f:	83 ec 08             	sub    $0x8,%esp
f01046a2:	ff 75 10             	pushl  0x10(%ebp)
f01046a5:	ff 75 0c             	pushl  0xc(%ebp)
f01046a8:	e8 cb 19 00 00       	call   f0106078 <receive_packet>
f01046ad:	83 c4 10             	add    $0x10,%esp
	return 0;
f01046b0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01046b5:	eb 4a                	jmp    f0104701 <syscall+0x69a>
// order byte, to the highest order
// Returns 0 on success, < 0 if pointer provided is invalid
static int
sys_get_mac_address(void *buf) {
	// Check pointers provided by user
	if (!buf || ((uint32_t) buf) > UTOP)
f01046b7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01046ba:	83 e8 01             	sub    $0x1,%eax
f01046bd:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f01046c2:	77 38                	ja     f01046fc <syscall+0x695>
		return -E_INVAL;

	get_mac_address(buf);
f01046c4:	83 ec 0c             	sub    $0xc,%esp
f01046c7:	ff 75 0c             	pushl  0xc(%ebp)
f01046ca:	e8 42 1a 00 00       	call   f0106111 <get_mac_address>
f01046cf:	83 c4 10             	add    $0x10,%esp
	return 0;
f01046d2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01046d7:	eb 28                	jmp    f0104701 <syscall+0x69a>
	case SYS_get_mac_address:
		
		ret = (int32_t) sys_get_mac_address((void *) a1);
		break;
	default:
		return -E_INVAL;
f01046d9:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01046de:	eb 21                	jmp    f0104701 <syscall+0x69a>
		ret = (int32_t) sys_ipc_try_send((envid_t) a1, (uint32_t) a2,
						   (void*) a3, (unsigned) a4);
		break;
	case SYS_ipc_recv:
		
		ret = (int32_t) sys_ipc_recv((void*) a1);
f01046e0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01046e5:	eb 1a                	jmp    f0104701 <syscall+0x69a>
	// buf should be in user space
	if (!buf || ((uint32_t) buf) > UTOP)
		return -E_INVAL;
	// size should not exceed the maximum
	if (size > MAX_PACKET_SIZE)
		return -E_INVAL;
f01046e7:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01046ec:	eb 13                	jmp    f0104701 <syscall+0x69a>

static int
sys_receive_packet(void *buf, size_t *size_store) {
	// Check pointers provided by user
	if (!buf || ((uint32_t) buf) > UTOP)
		return -E_INVAL;
f01046ee:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01046f3:	eb 0c                	jmp    f0104701 <syscall+0x69a>
	if (!size_store || ((uint32_t) size_store) > UTOP)
		return -E_INVAL;
f01046f5:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01046fa:	eb 05                	jmp    f0104701 <syscall+0x69a>
// Returns 0 on success, < 0 if pointer provided is invalid
static int
sys_get_mac_address(void *buf) {
	// Check pointers provided by user
	if (!buf || ((uint32_t) buf) > UTOP)
		return -E_INVAL;
f01046fc:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		break;
	default:
		return -E_INVAL;
	}
	return ret;
}
f0104701:	89 d8                	mov    %ebx,%eax
f0104703:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104706:	5b                   	pop    %ebx
f0104707:	5e                   	pop    %esi
f0104708:	5f                   	pop    %edi
f0104709:	5d                   	pop    %ebp
f010470a:	c3                   	ret    

f010470b <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010470b:	55                   	push   %ebp
f010470c:	89 e5                	mov    %esp,%ebp
f010470e:	57                   	push   %edi
f010470f:	56                   	push   %esi
f0104710:	53                   	push   %ebx
f0104711:	83 ec 14             	sub    $0x14,%esp
f0104714:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104717:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010471a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010471d:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104720:	8b 1a                	mov    (%edx),%ebx
f0104722:	8b 01                	mov    (%ecx),%eax
f0104724:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104727:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010472e:	eb 7f                	jmp    f01047af <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104730:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104733:	01 d8                	add    %ebx,%eax
f0104735:	89 c6                	mov    %eax,%esi
f0104737:	c1 ee 1f             	shr    $0x1f,%esi
f010473a:	01 c6                	add    %eax,%esi
f010473c:	d1 fe                	sar    %esi
f010473e:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104741:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104744:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104747:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104749:	eb 03                	jmp    f010474e <stab_binsearch+0x43>
			m--;
f010474b:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010474e:	39 c3                	cmp    %eax,%ebx
f0104750:	7f 0d                	jg     f010475f <stab_binsearch+0x54>
f0104752:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104756:	83 ea 0c             	sub    $0xc,%edx
f0104759:	39 f9                	cmp    %edi,%ecx
f010475b:	75 ee                	jne    f010474b <stab_binsearch+0x40>
f010475d:	eb 05                	jmp    f0104764 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010475f:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104762:	eb 4b                	jmp    f01047af <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104764:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104767:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010476a:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010476e:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104771:	76 11                	jbe    f0104784 <stab_binsearch+0x79>
			*region_left = m;
f0104773:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104776:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104778:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010477b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104782:	eb 2b                	jmp    f01047af <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104784:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104787:	73 14                	jae    f010479d <stab_binsearch+0x92>
			*region_right = m - 1;
f0104789:	83 e8 01             	sub    $0x1,%eax
f010478c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010478f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104792:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104794:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010479b:	eb 12                	jmp    f01047af <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010479d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01047a0:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01047a2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01047a6:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01047a8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01047af:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01047b2:	0f 8e 78 ff ff ff    	jle    f0104730 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01047b8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01047bc:	75 0f                	jne    f01047cd <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f01047be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047c1:	8b 00                	mov    (%eax),%eax
f01047c3:	83 e8 01             	sub    $0x1,%eax
f01047c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01047c9:	89 06                	mov    %eax,(%esi)
f01047cb:	eb 2c                	jmp    f01047f9 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01047cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01047d0:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01047d2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01047d5:	8b 0e                	mov    (%esi),%ecx
f01047d7:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01047da:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01047dd:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01047e0:	eb 03                	jmp    f01047e5 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01047e2:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01047e5:	39 c8                	cmp    %ecx,%eax
f01047e7:	7e 0b                	jle    f01047f4 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01047e9:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01047ed:	83 ea 0c             	sub    $0xc,%edx
f01047f0:	39 df                	cmp    %ebx,%edi
f01047f2:	75 ee                	jne    f01047e2 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01047f4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01047f7:	89 06                	mov    %eax,(%esi)
	}
}
f01047f9:	83 c4 14             	add    $0x14,%esp
f01047fc:	5b                   	pop    %ebx
f01047fd:	5e                   	pop    %esi
f01047fe:	5f                   	pop    %edi
f01047ff:	5d                   	pop    %ebp
f0104800:	c3                   	ret    

f0104801 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104801:	55                   	push   %ebp
f0104802:	89 e5                	mov    %esp,%ebp
f0104804:	57                   	push   %edi
f0104805:	56                   	push   %esi
f0104806:	53                   	push   %ebx
f0104807:	83 ec 2c             	sub    $0x2c,%esp
f010480a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010480d:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104810:	c7 06 98 80 10 f0    	movl   $0xf0108098,(%esi)
	info->eip_line = 0;
f0104816:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f010481d:	c7 46 08 98 80 10 f0 	movl   $0xf0108098,0x8(%esi)
	info->eip_fn_namelen = 9;
f0104824:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f010482b:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f010482e:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104835:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f010483b:	0f 87 80 00 00 00    	ja     f01048c1 <debuginfo_eip+0xc0>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// TODO: Not sure if it is correct. Should use PTE_U?
		/* Not sure */
		user_mem_check(curenv, usd, 1, PTE_U);
f0104841:	e8 bc 0f 00 00       	call   f0105802 <cpunum>
f0104846:	6a 04                	push   $0x4
f0104848:	6a 01                	push   $0x1
f010484a:	68 00 00 20 00       	push   $0x200000
f010484f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104852:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f0104858:	e8 19 e5 ff ff       	call   f0102d76 <user_mem_check>
		/* Not sure */

		stabs = usd->stabs;
f010485d:	a1 00 00 20 00       	mov    0x200000,%eax
f0104862:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f0104865:	8b 1d 04 00 20 00    	mov    0x200004,%ebx
		stabstr = usd->stabstr;
f010486b:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104871:	89 55 cc             	mov    %edx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f0104874:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104879:	89 45 d0             	mov    %eax,-0x30(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		// TODO: Not sure if it is correct. Should use PTE_U?
		/* Not sure */
		int len = (stab_end - stabs) * sizeof(struct Stab);
		user_mem_check(curenv, stabs, len, PTE_U);
f010487c:	e8 81 0f 00 00       	call   f0105802 <cpunum>
f0104881:	6a 04                	push   $0x4
f0104883:	89 da                	mov    %ebx,%edx
f0104885:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104888:	29 ca                	sub    %ecx,%edx
f010488a:	52                   	push   %edx
f010488b:	51                   	push   %ecx
f010488c:	6b c0 74             	imul   $0x74,%eax,%eax
f010488f:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f0104895:	e8 dc e4 ff ff       	call   f0102d76 <user_mem_check>

		len = stabstr_end - stabstr;
		user_mem_check(curenv, stabstr, len, PTE_U);
f010489a:	83 c4 20             	add    $0x20,%esp
f010489d:	e8 60 0f 00 00       	call   f0105802 <cpunum>
f01048a2:	6a 04                	push   $0x4
f01048a4:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01048a7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01048aa:	29 ca                	sub    %ecx,%edx
f01048ac:	52                   	push   %edx
f01048ad:	51                   	push   %ecx
f01048ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01048b1:	ff b0 28 20 2a f0    	pushl  -0xfd5dfd8(%eax)
f01048b7:	e8 ba e4 ff ff       	call   f0102d76 <user_mem_check>
f01048bc:	83 c4 10             	add    $0x10,%esp
f01048bf:	eb 1a                	jmp    f01048db <debuginfo_eip+0xda>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01048c1:	c7 45 d0 60 86 11 f0 	movl   $0xf0118660,-0x30(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01048c8:	c7 45 cc 99 42 11 f0 	movl   $0xf0114299,-0x34(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01048cf:	bb 98 42 11 f0       	mov    $0xf0114298,%ebx
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01048d4:	c7 45 d4 ac 89 10 f0 	movl   $0xf01089ac,-0x2c(%ebp)
		user_mem_check(curenv, stabstr, len, PTE_U);
		/* Not sure */
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01048db:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01048de:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01048e1:	0f 83 32 01 00 00    	jae    f0104a19 <debuginfo_eip+0x218>
f01048e7:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01048eb:	0f 85 2f 01 00 00    	jne    f0104a20 <debuginfo_eip+0x21f>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01048f1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01048f8:	2b 5d d4             	sub    -0x2c(%ebp),%ebx
f01048fb:	c1 fb 02             	sar    $0x2,%ebx
f01048fe:	69 c3 ab aa aa aa    	imul   $0xaaaaaaab,%ebx,%eax
f0104904:	83 e8 01             	sub    $0x1,%eax
f0104907:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010490a:	83 ec 08             	sub    $0x8,%esp
f010490d:	57                   	push   %edi
f010490e:	6a 64                	push   $0x64
f0104910:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104913:	89 d1                	mov    %edx,%ecx
f0104915:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104918:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010491b:	89 d8                	mov    %ebx,%eax
f010491d:	e8 e9 fd ff ff       	call   f010470b <stab_binsearch>
	if (lfile == 0)
f0104922:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104925:	83 c4 10             	add    $0x10,%esp
f0104928:	85 c0                	test   %eax,%eax
f010492a:	0f 84 f7 00 00 00    	je     f0104a27 <debuginfo_eip+0x226>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104930:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104933:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104936:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104939:	83 ec 08             	sub    $0x8,%esp
f010493c:	57                   	push   %edi
f010493d:	6a 24                	push   $0x24
f010493f:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104942:	89 d1                	mov    %edx,%ecx
f0104944:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104947:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f010494a:	89 d8                	mov    %ebx,%eax
f010494c:	e8 ba fd ff ff       	call   f010470b <stab_binsearch>

	if (lfun <= rfun) {
f0104951:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104954:	83 c4 10             	add    $0x10,%esp
f0104957:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f010495a:	7f 24                	jg     f0104980 <debuginfo_eip+0x17f>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010495c:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010495f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104962:	8d 14 87             	lea    (%edi,%eax,4),%edx
f0104965:	8b 02                	mov    (%edx),%eax
f0104967:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010496a:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010496d:	29 f9                	sub    %edi,%ecx
f010496f:	39 c8                	cmp    %ecx,%eax
f0104971:	73 05                	jae    f0104978 <debuginfo_eip+0x177>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104973:	01 f8                	add    %edi,%eax
f0104975:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104978:	8b 42 08             	mov    0x8(%edx),%eax
f010497b:	89 46 10             	mov    %eax,0x10(%esi)
f010497e:	eb 06                	jmp    f0104986 <debuginfo_eip+0x185>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104980:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0104983:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104986:	83 ec 08             	sub    $0x8,%esp
f0104989:	6a 3a                	push   $0x3a
f010498b:	ff 76 08             	pushl  0x8(%esi)
f010498e:	e8 33 08 00 00       	call   f01051c6 <strfind>
f0104993:	2b 46 08             	sub    0x8(%esi),%eax
f0104996:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104999:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010499c:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010499f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01049a2:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01049a5:	83 c4 10             	add    $0x10,%esp
f01049a8:	eb 06                	jmp    f01049b0 <debuginfo_eip+0x1af>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01049aa:	83 eb 01             	sub    $0x1,%ebx
f01049ad:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01049b0:	39 fb                	cmp    %edi,%ebx
f01049b2:	7c 2d                	jl     f01049e1 <debuginfo_eip+0x1e0>
	       && stabs[lline].n_type != N_SOL
f01049b4:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f01049b8:	80 fa 84             	cmp    $0x84,%dl
f01049bb:	74 0b                	je     f01049c8 <debuginfo_eip+0x1c7>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01049bd:	80 fa 64             	cmp    $0x64,%dl
f01049c0:	75 e8                	jne    f01049aa <debuginfo_eip+0x1a9>
f01049c2:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f01049c6:	74 e2                	je     f01049aa <debuginfo_eip+0x1a9>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01049c8:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01049cb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01049ce:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01049d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01049d4:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01049d7:	29 f8                	sub    %edi,%eax
f01049d9:	39 c2                	cmp    %eax,%edx
f01049db:	73 04                	jae    f01049e1 <debuginfo_eip+0x1e0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01049dd:	01 fa                	add    %edi,%edx
f01049df:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01049e1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01049e4:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01049e7:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01049ec:	39 cb                	cmp    %ecx,%ebx
f01049ee:	7d 43                	jge    f0104a33 <debuginfo_eip+0x232>
		for (lline = lfun + 1;
f01049f0:	8d 53 01             	lea    0x1(%ebx),%edx
f01049f3:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01049f6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01049f9:	8d 04 87             	lea    (%edi,%eax,4),%eax
f01049fc:	eb 07                	jmp    f0104a05 <debuginfo_eip+0x204>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01049fe:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0104a02:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104a05:	39 ca                	cmp    %ecx,%edx
f0104a07:	74 25                	je     f0104a2e <debuginfo_eip+0x22d>
f0104a09:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104a0c:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0104a10:	74 ec                	je     f01049fe <debuginfo_eip+0x1fd>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104a12:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a17:	eb 1a                	jmp    f0104a33 <debuginfo_eip+0x232>
		/* Not sure */
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104a19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104a1e:	eb 13                	jmp    f0104a33 <debuginfo_eip+0x232>
f0104a20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104a25:	eb 0c                	jmp    f0104a33 <debuginfo_eip+0x232>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104a27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104a2c:	eb 05                	jmp    f0104a33 <debuginfo_eip+0x232>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104a2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104a33:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104a36:	5b                   	pop    %ebx
f0104a37:	5e                   	pop    %esi
f0104a38:	5f                   	pop    %edi
f0104a39:	5d                   	pop    %ebp
f0104a3a:	c3                   	ret    

f0104a3b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104a3b:	55                   	push   %ebp
f0104a3c:	89 e5                	mov    %esp,%ebp
f0104a3e:	57                   	push   %edi
f0104a3f:	56                   	push   %esi
f0104a40:	53                   	push   %ebx
f0104a41:	83 ec 1c             	sub    $0x1c,%esp
f0104a44:	89 c7                	mov    %eax,%edi
f0104a46:	89 d6                	mov    %edx,%esi
f0104a48:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a4b:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104a4e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104a51:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104a54:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104a57:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104a5c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104a5f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104a62:	39 d3                	cmp    %edx,%ebx
f0104a64:	72 05                	jb     f0104a6b <printnum+0x30>
f0104a66:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104a69:	77 45                	ja     f0104ab0 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104a6b:	83 ec 0c             	sub    $0xc,%esp
f0104a6e:	ff 75 18             	pushl  0x18(%ebp)
f0104a71:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a74:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104a77:	53                   	push   %ebx
f0104a78:	ff 75 10             	pushl  0x10(%ebp)
f0104a7b:	83 ec 08             	sub    $0x8,%esp
f0104a7e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104a81:	ff 75 e0             	pushl  -0x20(%ebp)
f0104a84:	ff 75 dc             	pushl  -0x24(%ebp)
f0104a87:	ff 75 d8             	pushl  -0x28(%ebp)
f0104a8a:	e8 61 1c 00 00       	call   f01066f0 <__udivdi3>
f0104a8f:	83 c4 18             	add    $0x18,%esp
f0104a92:	52                   	push   %edx
f0104a93:	50                   	push   %eax
f0104a94:	89 f2                	mov    %esi,%edx
f0104a96:	89 f8                	mov    %edi,%eax
f0104a98:	e8 9e ff ff ff       	call   f0104a3b <printnum>
f0104a9d:	83 c4 20             	add    $0x20,%esp
f0104aa0:	eb 18                	jmp    f0104aba <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104aa2:	83 ec 08             	sub    $0x8,%esp
f0104aa5:	56                   	push   %esi
f0104aa6:	ff 75 18             	pushl  0x18(%ebp)
f0104aa9:	ff d7                	call   *%edi
f0104aab:	83 c4 10             	add    $0x10,%esp
f0104aae:	eb 03                	jmp    f0104ab3 <printnum+0x78>
f0104ab0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104ab3:	83 eb 01             	sub    $0x1,%ebx
f0104ab6:	85 db                	test   %ebx,%ebx
f0104ab8:	7f e8                	jg     f0104aa2 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104aba:	83 ec 08             	sub    $0x8,%esp
f0104abd:	56                   	push   %esi
f0104abe:	83 ec 04             	sub    $0x4,%esp
f0104ac1:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104ac4:	ff 75 e0             	pushl  -0x20(%ebp)
f0104ac7:	ff 75 dc             	pushl  -0x24(%ebp)
f0104aca:	ff 75 d8             	pushl  -0x28(%ebp)
f0104acd:	e8 4e 1d 00 00       	call   f0106820 <__umoddi3>
f0104ad2:	83 c4 14             	add    $0x14,%esp
f0104ad5:	0f be 80 a2 80 10 f0 	movsbl -0xfef7f5e(%eax),%eax
f0104adc:	50                   	push   %eax
f0104add:	ff d7                	call   *%edi
}
f0104adf:	83 c4 10             	add    $0x10,%esp
f0104ae2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104ae5:	5b                   	pop    %ebx
f0104ae6:	5e                   	pop    %esi
f0104ae7:	5f                   	pop    %edi
f0104ae8:	5d                   	pop    %ebp
f0104ae9:	c3                   	ret    

f0104aea <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104aea:	55                   	push   %ebp
f0104aeb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104aed:	83 fa 01             	cmp    $0x1,%edx
f0104af0:	7e 0e                	jle    f0104b00 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104af2:	8b 10                	mov    (%eax),%edx
f0104af4:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104af7:	89 08                	mov    %ecx,(%eax)
f0104af9:	8b 02                	mov    (%edx),%eax
f0104afb:	8b 52 04             	mov    0x4(%edx),%edx
f0104afe:	eb 22                	jmp    f0104b22 <getuint+0x38>
	else if (lflag)
f0104b00:	85 d2                	test   %edx,%edx
f0104b02:	74 10                	je     f0104b14 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104b04:	8b 10                	mov    (%eax),%edx
f0104b06:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104b09:	89 08                	mov    %ecx,(%eax)
f0104b0b:	8b 02                	mov    (%edx),%eax
f0104b0d:	ba 00 00 00 00       	mov    $0x0,%edx
f0104b12:	eb 0e                	jmp    f0104b22 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104b14:	8b 10                	mov    (%eax),%edx
f0104b16:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104b19:	89 08                	mov    %ecx,(%eax)
f0104b1b:	8b 02                	mov    (%edx),%eax
f0104b1d:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104b22:	5d                   	pop    %ebp
f0104b23:	c3                   	ret    

f0104b24 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104b24:	55                   	push   %ebp
f0104b25:	89 e5                	mov    %esp,%ebp
f0104b27:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104b2a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104b2e:	8b 10                	mov    (%eax),%edx
f0104b30:	3b 50 04             	cmp    0x4(%eax),%edx
f0104b33:	73 0a                	jae    f0104b3f <sprintputch+0x1b>
		*b->buf++ = ch;
f0104b35:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104b38:	89 08                	mov    %ecx,(%eax)
f0104b3a:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b3d:	88 02                	mov    %al,(%edx)
}
f0104b3f:	5d                   	pop    %ebp
f0104b40:	c3                   	ret    

f0104b41 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104b41:	55                   	push   %ebp
f0104b42:	89 e5                	mov    %esp,%ebp
f0104b44:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104b47:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104b4a:	50                   	push   %eax
f0104b4b:	ff 75 10             	pushl  0x10(%ebp)
f0104b4e:	ff 75 0c             	pushl  0xc(%ebp)
f0104b51:	ff 75 08             	pushl  0x8(%ebp)
f0104b54:	e8 05 00 00 00       	call   f0104b5e <vprintfmt>
	va_end(ap);
}
f0104b59:	83 c4 10             	add    $0x10,%esp
f0104b5c:	c9                   	leave  
f0104b5d:	c3                   	ret    

f0104b5e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104b5e:	55                   	push   %ebp
f0104b5f:	89 e5                	mov    %esp,%ebp
f0104b61:	57                   	push   %edi
f0104b62:	56                   	push   %esi
f0104b63:	53                   	push   %ebx
f0104b64:	83 ec 2c             	sub    $0x2c,%esp
f0104b67:	8b 75 08             	mov    0x8(%ebp),%esi
f0104b6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104b6d:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104b70:	eb 12                	jmp    f0104b84 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104b72:	85 c0                	test   %eax,%eax
f0104b74:	0f 84 89 03 00 00    	je     f0104f03 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0104b7a:	83 ec 08             	sub    $0x8,%esp
f0104b7d:	53                   	push   %ebx
f0104b7e:	50                   	push   %eax
f0104b7f:	ff d6                	call   *%esi
f0104b81:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104b84:	83 c7 01             	add    $0x1,%edi
f0104b87:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104b8b:	83 f8 25             	cmp    $0x25,%eax
f0104b8e:	75 e2                	jne    f0104b72 <vprintfmt+0x14>
f0104b90:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104b94:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104b9b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104ba2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104ba9:	ba 00 00 00 00       	mov    $0x0,%edx
f0104bae:	eb 07                	jmp    f0104bb7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104bb0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104bb3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104bb7:	8d 47 01             	lea    0x1(%edi),%eax
f0104bba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104bbd:	0f b6 07             	movzbl (%edi),%eax
f0104bc0:	0f b6 c8             	movzbl %al,%ecx
f0104bc3:	83 e8 23             	sub    $0x23,%eax
f0104bc6:	3c 55                	cmp    $0x55,%al
f0104bc8:	0f 87 1a 03 00 00    	ja     f0104ee8 <vprintfmt+0x38a>
f0104bce:	0f b6 c0             	movzbl %al,%eax
f0104bd1:	ff 24 85 e0 81 10 f0 	jmp    *-0xfef7e20(,%eax,4)
f0104bd8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104bdb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104bdf:	eb d6                	jmp    f0104bb7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104be1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104be4:	b8 00 00 00 00       	mov    $0x0,%eax
f0104be9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104bec:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104bef:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0104bf3:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0104bf6:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0104bf9:	83 fa 09             	cmp    $0x9,%edx
f0104bfc:	77 39                	ja     f0104c37 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104bfe:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104c01:	eb e9                	jmp    f0104bec <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104c03:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c06:	8d 48 04             	lea    0x4(%eax),%ecx
f0104c09:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104c0c:	8b 00                	mov    (%eax),%eax
f0104c0e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c11:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104c14:	eb 27                	jmp    f0104c3d <vprintfmt+0xdf>
f0104c16:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c19:	85 c0                	test   %eax,%eax
f0104c1b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104c20:	0f 49 c8             	cmovns %eax,%ecx
f0104c23:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c26:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104c29:	eb 8c                	jmp    f0104bb7 <vprintfmt+0x59>
f0104c2b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104c2e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104c35:	eb 80                	jmp    f0104bb7 <vprintfmt+0x59>
f0104c37:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104c3a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0104c3d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104c41:	0f 89 70 ff ff ff    	jns    f0104bb7 <vprintfmt+0x59>
				width = precision, precision = -1;
f0104c47:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104c4a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104c4d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104c54:	e9 5e ff ff ff       	jmp    f0104bb7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104c59:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c5c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104c5f:	e9 53 ff ff ff       	jmp    f0104bb7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104c64:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c67:	8d 50 04             	lea    0x4(%eax),%edx
f0104c6a:	89 55 14             	mov    %edx,0x14(%ebp)
f0104c6d:	83 ec 08             	sub    $0x8,%esp
f0104c70:	53                   	push   %ebx
f0104c71:	ff 30                	pushl  (%eax)
f0104c73:	ff d6                	call   *%esi
			break;
f0104c75:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c78:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104c7b:	e9 04 ff ff ff       	jmp    f0104b84 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104c80:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c83:	8d 50 04             	lea    0x4(%eax),%edx
f0104c86:	89 55 14             	mov    %edx,0x14(%ebp)
f0104c89:	8b 00                	mov    (%eax),%eax
f0104c8b:	99                   	cltd   
f0104c8c:	31 d0                	xor    %edx,%eax
f0104c8e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104c90:	83 f8 0f             	cmp    $0xf,%eax
f0104c93:	7f 0b                	jg     f0104ca0 <vprintfmt+0x142>
f0104c95:	8b 14 85 40 83 10 f0 	mov    -0xfef7cc0(,%eax,4),%edx
f0104c9c:	85 d2                	test   %edx,%edx
f0104c9e:	75 18                	jne    f0104cb8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0104ca0:	50                   	push   %eax
f0104ca1:	68 ba 80 10 f0       	push   $0xf01080ba
f0104ca6:	53                   	push   %ebx
f0104ca7:	56                   	push   %esi
f0104ca8:	e8 94 fe ff ff       	call   f0104b41 <printfmt>
f0104cad:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104cb0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104cb3:	e9 cc fe ff ff       	jmp    f0104b84 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0104cb8:	52                   	push   %edx
f0104cb9:	68 ef 78 10 f0       	push   $0xf01078ef
f0104cbe:	53                   	push   %ebx
f0104cbf:	56                   	push   %esi
f0104cc0:	e8 7c fe ff ff       	call   f0104b41 <printfmt>
f0104cc5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104cc8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ccb:	e9 b4 fe ff ff       	jmp    f0104b84 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104cd0:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cd3:	8d 50 04             	lea    0x4(%eax),%edx
f0104cd6:	89 55 14             	mov    %edx,0x14(%ebp)
f0104cd9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0104cdb:	85 ff                	test   %edi,%edi
f0104cdd:	b8 b3 80 10 f0       	mov    $0xf01080b3,%eax
f0104ce2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0104ce5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104ce9:	0f 8e 94 00 00 00    	jle    f0104d83 <vprintfmt+0x225>
f0104cef:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104cf3:	0f 84 98 00 00 00    	je     f0104d91 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104cf9:	83 ec 08             	sub    $0x8,%esp
f0104cfc:	ff 75 d0             	pushl  -0x30(%ebp)
f0104cff:	57                   	push   %edi
f0104d00:	e8 77 03 00 00       	call   f010507c <strnlen>
f0104d05:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104d08:	29 c1                	sub    %eax,%ecx
f0104d0a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0104d0d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104d10:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104d14:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104d17:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104d1a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104d1c:	eb 0f                	jmp    f0104d2d <vprintfmt+0x1cf>
					putch(padc, putdat);
f0104d1e:	83 ec 08             	sub    $0x8,%esp
f0104d21:	53                   	push   %ebx
f0104d22:	ff 75 e0             	pushl  -0x20(%ebp)
f0104d25:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104d27:	83 ef 01             	sub    $0x1,%edi
f0104d2a:	83 c4 10             	add    $0x10,%esp
f0104d2d:	85 ff                	test   %edi,%edi
f0104d2f:	7f ed                	jg     f0104d1e <vprintfmt+0x1c0>
f0104d31:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104d34:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104d37:	85 c9                	test   %ecx,%ecx
f0104d39:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d3e:	0f 49 c1             	cmovns %ecx,%eax
f0104d41:	29 c1                	sub    %eax,%ecx
f0104d43:	89 75 08             	mov    %esi,0x8(%ebp)
f0104d46:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104d49:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104d4c:	89 cb                	mov    %ecx,%ebx
f0104d4e:	eb 4d                	jmp    f0104d9d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104d50:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104d54:	74 1b                	je     f0104d71 <vprintfmt+0x213>
f0104d56:	0f be c0             	movsbl %al,%eax
f0104d59:	83 e8 20             	sub    $0x20,%eax
f0104d5c:	83 f8 5e             	cmp    $0x5e,%eax
f0104d5f:	76 10                	jbe    f0104d71 <vprintfmt+0x213>
					putch('?', putdat);
f0104d61:	83 ec 08             	sub    $0x8,%esp
f0104d64:	ff 75 0c             	pushl  0xc(%ebp)
f0104d67:	6a 3f                	push   $0x3f
f0104d69:	ff 55 08             	call   *0x8(%ebp)
f0104d6c:	83 c4 10             	add    $0x10,%esp
f0104d6f:	eb 0d                	jmp    f0104d7e <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0104d71:	83 ec 08             	sub    $0x8,%esp
f0104d74:	ff 75 0c             	pushl  0xc(%ebp)
f0104d77:	52                   	push   %edx
f0104d78:	ff 55 08             	call   *0x8(%ebp)
f0104d7b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104d7e:	83 eb 01             	sub    $0x1,%ebx
f0104d81:	eb 1a                	jmp    f0104d9d <vprintfmt+0x23f>
f0104d83:	89 75 08             	mov    %esi,0x8(%ebp)
f0104d86:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104d89:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104d8c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104d8f:	eb 0c                	jmp    f0104d9d <vprintfmt+0x23f>
f0104d91:	89 75 08             	mov    %esi,0x8(%ebp)
f0104d94:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104d97:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104d9a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104d9d:	83 c7 01             	add    $0x1,%edi
f0104da0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104da4:	0f be d0             	movsbl %al,%edx
f0104da7:	85 d2                	test   %edx,%edx
f0104da9:	74 23                	je     f0104dce <vprintfmt+0x270>
f0104dab:	85 f6                	test   %esi,%esi
f0104dad:	78 a1                	js     f0104d50 <vprintfmt+0x1f2>
f0104daf:	83 ee 01             	sub    $0x1,%esi
f0104db2:	79 9c                	jns    f0104d50 <vprintfmt+0x1f2>
f0104db4:	89 df                	mov    %ebx,%edi
f0104db6:	8b 75 08             	mov    0x8(%ebp),%esi
f0104db9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104dbc:	eb 18                	jmp    f0104dd6 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104dbe:	83 ec 08             	sub    $0x8,%esp
f0104dc1:	53                   	push   %ebx
f0104dc2:	6a 20                	push   $0x20
f0104dc4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104dc6:	83 ef 01             	sub    $0x1,%edi
f0104dc9:	83 c4 10             	add    $0x10,%esp
f0104dcc:	eb 08                	jmp    f0104dd6 <vprintfmt+0x278>
f0104dce:	89 df                	mov    %ebx,%edi
f0104dd0:	8b 75 08             	mov    0x8(%ebp),%esi
f0104dd3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104dd6:	85 ff                	test   %edi,%edi
f0104dd8:	7f e4                	jg     f0104dbe <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104dda:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ddd:	e9 a2 fd ff ff       	jmp    f0104b84 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104de2:	83 fa 01             	cmp    $0x1,%edx
f0104de5:	7e 16                	jle    f0104dfd <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0104de7:	8b 45 14             	mov    0x14(%ebp),%eax
f0104dea:	8d 50 08             	lea    0x8(%eax),%edx
f0104ded:	89 55 14             	mov    %edx,0x14(%ebp)
f0104df0:	8b 50 04             	mov    0x4(%eax),%edx
f0104df3:	8b 00                	mov    (%eax),%eax
f0104df5:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104df8:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104dfb:	eb 32                	jmp    f0104e2f <vprintfmt+0x2d1>
	else if (lflag)
f0104dfd:	85 d2                	test   %edx,%edx
f0104dff:	74 18                	je     f0104e19 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0104e01:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e04:	8d 50 04             	lea    0x4(%eax),%edx
f0104e07:	89 55 14             	mov    %edx,0x14(%ebp)
f0104e0a:	8b 00                	mov    (%eax),%eax
f0104e0c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104e0f:	89 c1                	mov    %eax,%ecx
f0104e11:	c1 f9 1f             	sar    $0x1f,%ecx
f0104e14:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104e17:	eb 16                	jmp    f0104e2f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0104e19:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e1c:	8d 50 04             	lea    0x4(%eax),%edx
f0104e1f:	89 55 14             	mov    %edx,0x14(%ebp)
f0104e22:	8b 00                	mov    (%eax),%eax
f0104e24:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104e27:	89 c1                	mov    %eax,%ecx
f0104e29:	c1 f9 1f             	sar    $0x1f,%ecx
f0104e2c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104e2f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104e32:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104e35:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0104e3a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104e3e:	79 74                	jns    f0104eb4 <vprintfmt+0x356>
				putch('-', putdat);
f0104e40:	83 ec 08             	sub    $0x8,%esp
f0104e43:	53                   	push   %ebx
f0104e44:	6a 2d                	push   $0x2d
f0104e46:	ff d6                	call   *%esi
				num = -(long long) num;
f0104e48:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104e4b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104e4e:	f7 d8                	neg    %eax
f0104e50:	83 d2 00             	adc    $0x0,%edx
f0104e53:	f7 da                	neg    %edx
f0104e55:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0104e58:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0104e5d:	eb 55                	jmp    f0104eb4 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104e5f:	8d 45 14             	lea    0x14(%ebp),%eax
f0104e62:	e8 83 fc ff ff       	call   f0104aea <getuint>
			base = 10;
f0104e67:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0104e6c:	eb 46                	jmp    f0104eb4 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0104e6e:	8d 45 14             	lea    0x14(%ebp),%eax
f0104e71:	e8 74 fc ff ff       	call   f0104aea <getuint>
                        base = 8;
f0104e76:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
f0104e7b:	eb 37                	jmp    f0104eb4 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0104e7d:	83 ec 08             	sub    $0x8,%esp
f0104e80:	53                   	push   %ebx
f0104e81:	6a 30                	push   $0x30
f0104e83:	ff d6                	call   *%esi
			putch('x', putdat);
f0104e85:	83 c4 08             	add    $0x8,%esp
f0104e88:	53                   	push   %ebx
f0104e89:	6a 78                	push   $0x78
f0104e8b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104e8d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e90:	8d 50 04             	lea    0x4(%eax),%edx
f0104e93:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104e96:	8b 00                	mov    (%eax),%eax
f0104e98:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104e9d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104ea0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0104ea5:	eb 0d                	jmp    f0104eb4 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104ea7:	8d 45 14             	lea    0x14(%ebp),%eax
f0104eaa:	e8 3b fc ff ff       	call   f0104aea <getuint>
			base = 16;
f0104eaf:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104eb4:	83 ec 0c             	sub    $0xc,%esp
f0104eb7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0104ebb:	57                   	push   %edi
f0104ebc:	ff 75 e0             	pushl  -0x20(%ebp)
f0104ebf:	51                   	push   %ecx
f0104ec0:	52                   	push   %edx
f0104ec1:	50                   	push   %eax
f0104ec2:	89 da                	mov    %ebx,%edx
f0104ec4:	89 f0                	mov    %esi,%eax
f0104ec6:	e8 70 fb ff ff       	call   f0104a3b <printnum>
			break;
f0104ecb:	83 c4 20             	add    $0x20,%esp
f0104ece:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ed1:	e9 ae fc ff ff       	jmp    f0104b84 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104ed6:	83 ec 08             	sub    $0x8,%esp
f0104ed9:	53                   	push   %ebx
f0104eda:	51                   	push   %ecx
f0104edb:	ff d6                	call   *%esi
			break;
f0104edd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ee0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0104ee3:	e9 9c fc ff ff       	jmp    f0104b84 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104ee8:	83 ec 08             	sub    $0x8,%esp
f0104eeb:	53                   	push   %ebx
f0104eec:	6a 25                	push   $0x25
f0104eee:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104ef0:	83 c4 10             	add    $0x10,%esp
f0104ef3:	eb 03                	jmp    f0104ef8 <vprintfmt+0x39a>
f0104ef5:	83 ef 01             	sub    $0x1,%edi
f0104ef8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0104efc:	75 f7                	jne    f0104ef5 <vprintfmt+0x397>
f0104efe:	e9 81 fc ff ff       	jmp    f0104b84 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0104f03:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f06:	5b                   	pop    %ebx
f0104f07:	5e                   	pop    %esi
f0104f08:	5f                   	pop    %edi
f0104f09:	5d                   	pop    %ebp
f0104f0a:	c3                   	ret    

f0104f0b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104f0b:	55                   	push   %ebp
f0104f0c:	89 e5                	mov    %esp,%ebp
f0104f0e:	83 ec 18             	sub    $0x18,%esp
f0104f11:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f14:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104f17:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104f1a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104f1e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104f21:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104f28:	85 c0                	test   %eax,%eax
f0104f2a:	74 26                	je     f0104f52 <vsnprintf+0x47>
f0104f2c:	85 d2                	test   %edx,%edx
f0104f2e:	7e 22                	jle    f0104f52 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104f30:	ff 75 14             	pushl  0x14(%ebp)
f0104f33:	ff 75 10             	pushl  0x10(%ebp)
f0104f36:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104f39:	50                   	push   %eax
f0104f3a:	68 24 4b 10 f0       	push   $0xf0104b24
f0104f3f:	e8 1a fc ff ff       	call   f0104b5e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104f44:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104f47:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104f4d:	83 c4 10             	add    $0x10,%esp
f0104f50:	eb 05                	jmp    f0104f57 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104f52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104f57:	c9                   	leave  
f0104f58:	c3                   	ret    

f0104f59 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104f59:	55                   	push   %ebp
f0104f5a:	89 e5                	mov    %esp,%ebp
f0104f5c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104f5f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104f62:	50                   	push   %eax
f0104f63:	ff 75 10             	pushl  0x10(%ebp)
f0104f66:	ff 75 0c             	pushl  0xc(%ebp)
f0104f69:	ff 75 08             	pushl  0x8(%ebp)
f0104f6c:	e8 9a ff ff ff       	call   f0104f0b <vsnprintf>
	va_end(ap);

	return rc;
}
f0104f71:	c9                   	leave  
f0104f72:	c3                   	ret    

f0104f73 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104f73:	55                   	push   %ebp
f0104f74:	89 e5                	mov    %esp,%ebp
f0104f76:	57                   	push   %edi
f0104f77:	56                   	push   %esi
f0104f78:	53                   	push   %ebx
f0104f79:	83 ec 0c             	sub    $0xc,%esp
f0104f7c:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0104f7f:	85 c0                	test   %eax,%eax
f0104f81:	74 11                	je     f0104f94 <readline+0x21>
		cprintf("%s", prompt);
f0104f83:	83 ec 08             	sub    $0x8,%esp
f0104f86:	50                   	push   %eax
f0104f87:	68 ef 78 10 f0       	push   $0xf01078ef
f0104f8c:	e8 cf e6 ff ff       	call   f0103660 <cprintf>
f0104f91:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0104f94:	83 ec 0c             	sub    $0xc,%esp
f0104f97:	6a 00                	push   $0x0
f0104f99:	e8 27 b8 ff ff       	call   f01007c5 <iscons>
f0104f9e:	89 c7                	mov    %eax,%edi
f0104fa0:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0104fa3:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104fa8:	e8 07 b8 ff ff       	call   f01007b4 <getchar>
f0104fad:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104faf:	85 c0                	test   %eax,%eax
f0104fb1:	79 29                	jns    f0104fdc <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0104fb3:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f0104fb8:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0104fbb:	0f 84 9b 00 00 00    	je     f010505c <readline+0xe9>
				cprintf("read error: %e\n", c);
f0104fc1:	83 ec 08             	sub    $0x8,%esp
f0104fc4:	53                   	push   %ebx
f0104fc5:	68 9f 83 10 f0       	push   $0xf010839f
f0104fca:	e8 91 e6 ff ff       	call   f0103660 <cprintf>
f0104fcf:	83 c4 10             	add    $0x10,%esp
			return NULL;
f0104fd2:	b8 00 00 00 00       	mov    $0x0,%eax
f0104fd7:	e9 80 00 00 00       	jmp    f010505c <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104fdc:	83 f8 08             	cmp    $0x8,%eax
f0104fdf:	0f 94 c2             	sete   %dl
f0104fe2:	83 f8 7f             	cmp    $0x7f,%eax
f0104fe5:	0f 94 c0             	sete   %al
f0104fe8:	08 c2                	or     %al,%dl
f0104fea:	74 1a                	je     f0105006 <readline+0x93>
f0104fec:	85 f6                	test   %esi,%esi
f0104fee:	7e 16                	jle    f0105006 <readline+0x93>
			if (echoing)
f0104ff0:	85 ff                	test   %edi,%edi
f0104ff2:	74 0d                	je     f0105001 <readline+0x8e>
				cputchar('\b');
f0104ff4:	83 ec 0c             	sub    $0xc,%esp
f0104ff7:	6a 08                	push   $0x8
f0104ff9:	e8 a6 b7 ff ff       	call   f01007a4 <cputchar>
f0104ffe:	83 c4 10             	add    $0x10,%esp
			i--;
f0105001:	83 ee 01             	sub    $0x1,%esi
f0105004:	eb a2                	jmp    f0104fa8 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105006:	83 fb 1f             	cmp    $0x1f,%ebx
f0105009:	7e 26                	jle    f0105031 <readline+0xbe>
f010500b:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105011:	7f 1e                	jg     f0105031 <readline+0xbe>
			if (echoing)
f0105013:	85 ff                	test   %edi,%edi
f0105015:	74 0c                	je     f0105023 <readline+0xb0>
				cputchar(c);
f0105017:	83 ec 0c             	sub    $0xc,%esp
f010501a:	53                   	push   %ebx
f010501b:	e8 84 b7 ff ff       	call   f01007a4 <cputchar>
f0105020:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105023:	88 9e 80 1a 2a f0    	mov    %bl,-0xfd5e580(%esi)
f0105029:	8d 76 01             	lea    0x1(%esi),%esi
f010502c:	e9 77 ff ff ff       	jmp    f0104fa8 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105031:	83 fb 0a             	cmp    $0xa,%ebx
f0105034:	74 09                	je     f010503f <readline+0xcc>
f0105036:	83 fb 0d             	cmp    $0xd,%ebx
f0105039:	0f 85 69 ff ff ff    	jne    f0104fa8 <readline+0x35>
			if (echoing)
f010503f:	85 ff                	test   %edi,%edi
f0105041:	74 0d                	je     f0105050 <readline+0xdd>
				cputchar('\n');
f0105043:	83 ec 0c             	sub    $0xc,%esp
f0105046:	6a 0a                	push   $0xa
f0105048:	e8 57 b7 ff ff       	call   f01007a4 <cputchar>
f010504d:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105050:	c6 86 80 1a 2a f0 00 	movb   $0x0,-0xfd5e580(%esi)
			return buf;
f0105057:	b8 80 1a 2a f0       	mov    $0xf02a1a80,%eax
		}
	}
}
f010505c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010505f:	5b                   	pop    %ebx
f0105060:	5e                   	pop    %esi
f0105061:	5f                   	pop    %edi
f0105062:	5d                   	pop    %ebp
f0105063:	c3                   	ret    

f0105064 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105064:	55                   	push   %ebp
f0105065:	89 e5                	mov    %esp,%ebp
f0105067:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010506a:	b8 00 00 00 00       	mov    $0x0,%eax
f010506f:	eb 03                	jmp    f0105074 <strlen+0x10>
		n++;
f0105071:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105074:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105078:	75 f7                	jne    f0105071 <strlen+0xd>
		n++;
	return n;
}
f010507a:	5d                   	pop    %ebp
f010507b:	c3                   	ret    

f010507c <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010507c:	55                   	push   %ebp
f010507d:	89 e5                	mov    %esp,%ebp
f010507f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105082:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105085:	ba 00 00 00 00       	mov    $0x0,%edx
f010508a:	eb 03                	jmp    f010508f <strnlen+0x13>
		n++;
f010508c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010508f:	39 c2                	cmp    %eax,%edx
f0105091:	74 08                	je     f010509b <strnlen+0x1f>
f0105093:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105097:	75 f3                	jne    f010508c <strnlen+0x10>
f0105099:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010509b:	5d                   	pop    %ebp
f010509c:	c3                   	ret    

f010509d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010509d:	55                   	push   %ebp
f010509e:	89 e5                	mov    %esp,%ebp
f01050a0:	53                   	push   %ebx
f01050a1:	8b 45 08             	mov    0x8(%ebp),%eax
f01050a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01050a7:	89 c2                	mov    %eax,%edx
f01050a9:	83 c2 01             	add    $0x1,%edx
f01050ac:	83 c1 01             	add    $0x1,%ecx
f01050af:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01050b3:	88 5a ff             	mov    %bl,-0x1(%edx)
f01050b6:	84 db                	test   %bl,%bl
f01050b8:	75 ef                	jne    f01050a9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01050ba:	5b                   	pop    %ebx
f01050bb:	5d                   	pop    %ebp
f01050bc:	c3                   	ret    

f01050bd <strcat>:

char *
strcat(char *dst, const char *src)
{
f01050bd:	55                   	push   %ebp
f01050be:	89 e5                	mov    %esp,%ebp
f01050c0:	53                   	push   %ebx
f01050c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01050c4:	53                   	push   %ebx
f01050c5:	e8 9a ff ff ff       	call   f0105064 <strlen>
f01050ca:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01050cd:	ff 75 0c             	pushl  0xc(%ebp)
f01050d0:	01 d8                	add    %ebx,%eax
f01050d2:	50                   	push   %eax
f01050d3:	e8 c5 ff ff ff       	call   f010509d <strcpy>
	return dst;
}
f01050d8:	89 d8                	mov    %ebx,%eax
f01050da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01050dd:	c9                   	leave  
f01050de:	c3                   	ret    

f01050df <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01050df:	55                   	push   %ebp
f01050e0:	89 e5                	mov    %esp,%ebp
f01050e2:	56                   	push   %esi
f01050e3:	53                   	push   %ebx
f01050e4:	8b 75 08             	mov    0x8(%ebp),%esi
f01050e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01050ea:	89 f3                	mov    %esi,%ebx
f01050ec:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01050ef:	89 f2                	mov    %esi,%edx
f01050f1:	eb 0f                	jmp    f0105102 <strncpy+0x23>
		*dst++ = *src;
f01050f3:	83 c2 01             	add    $0x1,%edx
f01050f6:	0f b6 01             	movzbl (%ecx),%eax
f01050f9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01050fc:	80 39 01             	cmpb   $0x1,(%ecx)
f01050ff:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105102:	39 da                	cmp    %ebx,%edx
f0105104:	75 ed                	jne    f01050f3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105106:	89 f0                	mov    %esi,%eax
f0105108:	5b                   	pop    %ebx
f0105109:	5e                   	pop    %esi
f010510a:	5d                   	pop    %ebp
f010510b:	c3                   	ret    

f010510c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010510c:	55                   	push   %ebp
f010510d:	89 e5                	mov    %esp,%ebp
f010510f:	56                   	push   %esi
f0105110:	53                   	push   %ebx
f0105111:	8b 75 08             	mov    0x8(%ebp),%esi
f0105114:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105117:	8b 55 10             	mov    0x10(%ebp),%edx
f010511a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010511c:	85 d2                	test   %edx,%edx
f010511e:	74 21                	je     f0105141 <strlcpy+0x35>
f0105120:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105124:	89 f2                	mov    %esi,%edx
f0105126:	eb 09                	jmp    f0105131 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105128:	83 c2 01             	add    $0x1,%edx
f010512b:	83 c1 01             	add    $0x1,%ecx
f010512e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105131:	39 c2                	cmp    %eax,%edx
f0105133:	74 09                	je     f010513e <strlcpy+0x32>
f0105135:	0f b6 19             	movzbl (%ecx),%ebx
f0105138:	84 db                	test   %bl,%bl
f010513a:	75 ec                	jne    f0105128 <strlcpy+0x1c>
f010513c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f010513e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105141:	29 f0                	sub    %esi,%eax
}
f0105143:	5b                   	pop    %ebx
f0105144:	5e                   	pop    %esi
f0105145:	5d                   	pop    %ebp
f0105146:	c3                   	ret    

f0105147 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105147:	55                   	push   %ebp
f0105148:	89 e5                	mov    %esp,%ebp
f010514a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010514d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105150:	eb 06                	jmp    f0105158 <strcmp+0x11>
		p++, q++;
f0105152:	83 c1 01             	add    $0x1,%ecx
f0105155:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105158:	0f b6 01             	movzbl (%ecx),%eax
f010515b:	84 c0                	test   %al,%al
f010515d:	74 04                	je     f0105163 <strcmp+0x1c>
f010515f:	3a 02                	cmp    (%edx),%al
f0105161:	74 ef                	je     f0105152 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105163:	0f b6 c0             	movzbl %al,%eax
f0105166:	0f b6 12             	movzbl (%edx),%edx
f0105169:	29 d0                	sub    %edx,%eax
}
f010516b:	5d                   	pop    %ebp
f010516c:	c3                   	ret    

f010516d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010516d:	55                   	push   %ebp
f010516e:	89 e5                	mov    %esp,%ebp
f0105170:	53                   	push   %ebx
f0105171:	8b 45 08             	mov    0x8(%ebp),%eax
f0105174:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105177:	89 c3                	mov    %eax,%ebx
f0105179:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010517c:	eb 06                	jmp    f0105184 <strncmp+0x17>
		n--, p++, q++;
f010517e:	83 c0 01             	add    $0x1,%eax
f0105181:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105184:	39 d8                	cmp    %ebx,%eax
f0105186:	74 15                	je     f010519d <strncmp+0x30>
f0105188:	0f b6 08             	movzbl (%eax),%ecx
f010518b:	84 c9                	test   %cl,%cl
f010518d:	74 04                	je     f0105193 <strncmp+0x26>
f010518f:	3a 0a                	cmp    (%edx),%cl
f0105191:	74 eb                	je     f010517e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105193:	0f b6 00             	movzbl (%eax),%eax
f0105196:	0f b6 12             	movzbl (%edx),%edx
f0105199:	29 d0                	sub    %edx,%eax
f010519b:	eb 05                	jmp    f01051a2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010519d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01051a2:	5b                   	pop    %ebx
f01051a3:	5d                   	pop    %ebp
f01051a4:	c3                   	ret    

f01051a5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01051a5:	55                   	push   %ebp
f01051a6:	89 e5                	mov    %esp,%ebp
f01051a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01051ab:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01051af:	eb 07                	jmp    f01051b8 <strchr+0x13>
		if (*s == c)
f01051b1:	38 ca                	cmp    %cl,%dl
f01051b3:	74 0f                	je     f01051c4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01051b5:	83 c0 01             	add    $0x1,%eax
f01051b8:	0f b6 10             	movzbl (%eax),%edx
f01051bb:	84 d2                	test   %dl,%dl
f01051bd:	75 f2                	jne    f01051b1 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01051bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01051c4:	5d                   	pop    %ebp
f01051c5:	c3                   	ret    

f01051c6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01051c6:	55                   	push   %ebp
f01051c7:	89 e5                	mov    %esp,%ebp
f01051c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01051cc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01051d0:	eb 03                	jmp    f01051d5 <strfind+0xf>
f01051d2:	83 c0 01             	add    $0x1,%eax
f01051d5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01051d8:	38 ca                	cmp    %cl,%dl
f01051da:	74 04                	je     f01051e0 <strfind+0x1a>
f01051dc:	84 d2                	test   %dl,%dl
f01051de:	75 f2                	jne    f01051d2 <strfind+0xc>
			break;
	return (char *) s;
}
f01051e0:	5d                   	pop    %ebp
f01051e1:	c3                   	ret    

f01051e2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01051e2:	55                   	push   %ebp
f01051e3:	89 e5                	mov    %esp,%ebp
f01051e5:	57                   	push   %edi
f01051e6:	56                   	push   %esi
f01051e7:	53                   	push   %ebx
f01051e8:	8b 7d 08             	mov    0x8(%ebp),%edi
f01051eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01051ee:	85 c9                	test   %ecx,%ecx
f01051f0:	74 36                	je     f0105228 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01051f2:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01051f8:	75 28                	jne    f0105222 <memset+0x40>
f01051fa:	f6 c1 03             	test   $0x3,%cl
f01051fd:	75 23                	jne    f0105222 <memset+0x40>
		c &= 0xFF;
f01051ff:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105203:	89 d3                	mov    %edx,%ebx
f0105205:	c1 e3 08             	shl    $0x8,%ebx
f0105208:	89 d6                	mov    %edx,%esi
f010520a:	c1 e6 18             	shl    $0x18,%esi
f010520d:	89 d0                	mov    %edx,%eax
f010520f:	c1 e0 10             	shl    $0x10,%eax
f0105212:	09 f0                	or     %esi,%eax
f0105214:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105216:	89 d8                	mov    %ebx,%eax
f0105218:	09 d0                	or     %edx,%eax
f010521a:	c1 e9 02             	shr    $0x2,%ecx
f010521d:	fc                   	cld    
f010521e:	f3 ab                	rep stos %eax,%es:(%edi)
f0105220:	eb 06                	jmp    f0105228 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105222:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105225:	fc                   	cld    
f0105226:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105228:	89 f8                	mov    %edi,%eax
f010522a:	5b                   	pop    %ebx
f010522b:	5e                   	pop    %esi
f010522c:	5f                   	pop    %edi
f010522d:	5d                   	pop    %ebp
f010522e:	c3                   	ret    

f010522f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010522f:	55                   	push   %ebp
f0105230:	89 e5                	mov    %esp,%ebp
f0105232:	57                   	push   %edi
f0105233:	56                   	push   %esi
f0105234:	8b 45 08             	mov    0x8(%ebp),%eax
f0105237:	8b 75 0c             	mov    0xc(%ebp),%esi
f010523a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010523d:	39 c6                	cmp    %eax,%esi
f010523f:	73 35                	jae    f0105276 <memmove+0x47>
f0105241:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105244:	39 d0                	cmp    %edx,%eax
f0105246:	73 2e                	jae    f0105276 <memmove+0x47>
		s += n;
		d += n;
f0105248:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010524b:	89 d6                	mov    %edx,%esi
f010524d:	09 fe                	or     %edi,%esi
f010524f:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105255:	75 13                	jne    f010526a <memmove+0x3b>
f0105257:	f6 c1 03             	test   $0x3,%cl
f010525a:	75 0e                	jne    f010526a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f010525c:	83 ef 04             	sub    $0x4,%edi
f010525f:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105262:	c1 e9 02             	shr    $0x2,%ecx
f0105265:	fd                   	std    
f0105266:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105268:	eb 09                	jmp    f0105273 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010526a:	83 ef 01             	sub    $0x1,%edi
f010526d:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105270:	fd                   	std    
f0105271:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105273:	fc                   	cld    
f0105274:	eb 1d                	jmp    f0105293 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105276:	89 f2                	mov    %esi,%edx
f0105278:	09 c2                	or     %eax,%edx
f010527a:	f6 c2 03             	test   $0x3,%dl
f010527d:	75 0f                	jne    f010528e <memmove+0x5f>
f010527f:	f6 c1 03             	test   $0x3,%cl
f0105282:	75 0a                	jne    f010528e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105284:	c1 e9 02             	shr    $0x2,%ecx
f0105287:	89 c7                	mov    %eax,%edi
f0105289:	fc                   	cld    
f010528a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010528c:	eb 05                	jmp    f0105293 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010528e:	89 c7                	mov    %eax,%edi
f0105290:	fc                   	cld    
f0105291:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105293:	5e                   	pop    %esi
f0105294:	5f                   	pop    %edi
f0105295:	5d                   	pop    %ebp
f0105296:	c3                   	ret    

f0105297 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105297:	55                   	push   %ebp
f0105298:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010529a:	ff 75 10             	pushl  0x10(%ebp)
f010529d:	ff 75 0c             	pushl  0xc(%ebp)
f01052a0:	ff 75 08             	pushl  0x8(%ebp)
f01052a3:	e8 87 ff ff ff       	call   f010522f <memmove>
}
f01052a8:	c9                   	leave  
f01052a9:	c3                   	ret    

f01052aa <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01052aa:	55                   	push   %ebp
f01052ab:	89 e5                	mov    %esp,%ebp
f01052ad:	56                   	push   %esi
f01052ae:	53                   	push   %ebx
f01052af:	8b 45 08             	mov    0x8(%ebp),%eax
f01052b2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01052b5:	89 c6                	mov    %eax,%esi
f01052b7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01052ba:	eb 1a                	jmp    f01052d6 <memcmp+0x2c>
		if (*s1 != *s2)
f01052bc:	0f b6 08             	movzbl (%eax),%ecx
f01052bf:	0f b6 1a             	movzbl (%edx),%ebx
f01052c2:	38 d9                	cmp    %bl,%cl
f01052c4:	74 0a                	je     f01052d0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01052c6:	0f b6 c1             	movzbl %cl,%eax
f01052c9:	0f b6 db             	movzbl %bl,%ebx
f01052cc:	29 d8                	sub    %ebx,%eax
f01052ce:	eb 0f                	jmp    f01052df <memcmp+0x35>
		s1++, s2++;
f01052d0:	83 c0 01             	add    $0x1,%eax
f01052d3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01052d6:	39 f0                	cmp    %esi,%eax
f01052d8:	75 e2                	jne    f01052bc <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01052da:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01052df:	5b                   	pop    %ebx
f01052e0:	5e                   	pop    %esi
f01052e1:	5d                   	pop    %ebp
f01052e2:	c3                   	ret    

f01052e3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01052e3:	55                   	push   %ebp
f01052e4:	89 e5                	mov    %esp,%ebp
f01052e6:	53                   	push   %ebx
f01052e7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01052ea:	89 c1                	mov    %eax,%ecx
f01052ec:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01052ef:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01052f3:	eb 0a                	jmp    f01052ff <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01052f5:	0f b6 10             	movzbl (%eax),%edx
f01052f8:	39 da                	cmp    %ebx,%edx
f01052fa:	74 07                	je     f0105303 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01052fc:	83 c0 01             	add    $0x1,%eax
f01052ff:	39 c8                	cmp    %ecx,%eax
f0105301:	72 f2                	jb     f01052f5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105303:	5b                   	pop    %ebx
f0105304:	5d                   	pop    %ebp
f0105305:	c3                   	ret    

f0105306 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105306:	55                   	push   %ebp
f0105307:	89 e5                	mov    %esp,%ebp
f0105309:	57                   	push   %edi
f010530a:	56                   	push   %esi
f010530b:	53                   	push   %ebx
f010530c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010530f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105312:	eb 03                	jmp    f0105317 <strtol+0x11>
		s++;
f0105314:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105317:	0f b6 01             	movzbl (%ecx),%eax
f010531a:	3c 20                	cmp    $0x20,%al
f010531c:	74 f6                	je     f0105314 <strtol+0xe>
f010531e:	3c 09                	cmp    $0x9,%al
f0105320:	74 f2                	je     f0105314 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105322:	3c 2b                	cmp    $0x2b,%al
f0105324:	75 0a                	jne    f0105330 <strtol+0x2a>
		s++;
f0105326:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105329:	bf 00 00 00 00       	mov    $0x0,%edi
f010532e:	eb 11                	jmp    f0105341 <strtol+0x3b>
f0105330:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105335:	3c 2d                	cmp    $0x2d,%al
f0105337:	75 08                	jne    f0105341 <strtol+0x3b>
		s++, neg = 1;
f0105339:	83 c1 01             	add    $0x1,%ecx
f010533c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105341:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105347:	75 15                	jne    f010535e <strtol+0x58>
f0105349:	80 39 30             	cmpb   $0x30,(%ecx)
f010534c:	75 10                	jne    f010535e <strtol+0x58>
f010534e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105352:	75 7c                	jne    f01053d0 <strtol+0xca>
		s += 2, base = 16;
f0105354:	83 c1 02             	add    $0x2,%ecx
f0105357:	bb 10 00 00 00       	mov    $0x10,%ebx
f010535c:	eb 16                	jmp    f0105374 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f010535e:	85 db                	test   %ebx,%ebx
f0105360:	75 12                	jne    f0105374 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105362:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105367:	80 39 30             	cmpb   $0x30,(%ecx)
f010536a:	75 08                	jne    f0105374 <strtol+0x6e>
		s++, base = 8;
f010536c:	83 c1 01             	add    $0x1,%ecx
f010536f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105374:	b8 00 00 00 00       	mov    $0x0,%eax
f0105379:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010537c:	0f b6 11             	movzbl (%ecx),%edx
f010537f:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105382:	89 f3                	mov    %esi,%ebx
f0105384:	80 fb 09             	cmp    $0x9,%bl
f0105387:	77 08                	ja     f0105391 <strtol+0x8b>
			dig = *s - '0';
f0105389:	0f be d2             	movsbl %dl,%edx
f010538c:	83 ea 30             	sub    $0x30,%edx
f010538f:	eb 22                	jmp    f01053b3 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105391:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105394:	89 f3                	mov    %esi,%ebx
f0105396:	80 fb 19             	cmp    $0x19,%bl
f0105399:	77 08                	ja     f01053a3 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010539b:	0f be d2             	movsbl %dl,%edx
f010539e:	83 ea 57             	sub    $0x57,%edx
f01053a1:	eb 10                	jmp    f01053b3 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01053a3:	8d 72 bf             	lea    -0x41(%edx),%esi
f01053a6:	89 f3                	mov    %esi,%ebx
f01053a8:	80 fb 19             	cmp    $0x19,%bl
f01053ab:	77 16                	ja     f01053c3 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01053ad:	0f be d2             	movsbl %dl,%edx
f01053b0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01053b3:	3b 55 10             	cmp    0x10(%ebp),%edx
f01053b6:	7d 0b                	jge    f01053c3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01053b8:	83 c1 01             	add    $0x1,%ecx
f01053bb:	0f af 45 10          	imul   0x10(%ebp),%eax
f01053bf:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01053c1:	eb b9                	jmp    f010537c <strtol+0x76>

	if (endptr)
f01053c3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01053c7:	74 0d                	je     f01053d6 <strtol+0xd0>
		*endptr = (char *) s;
f01053c9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01053cc:	89 0e                	mov    %ecx,(%esi)
f01053ce:	eb 06                	jmp    f01053d6 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01053d0:	85 db                	test   %ebx,%ebx
f01053d2:	74 98                	je     f010536c <strtol+0x66>
f01053d4:	eb 9e                	jmp    f0105374 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01053d6:	89 c2                	mov    %eax,%edx
f01053d8:	f7 da                	neg    %edx
f01053da:	85 ff                	test   %edi,%edi
f01053dc:	0f 45 c2             	cmovne %edx,%eax
}
f01053df:	5b                   	pop    %ebx
f01053e0:	5e                   	pop    %esi
f01053e1:	5f                   	pop    %edi
f01053e2:	5d                   	pop    %ebp
f01053e3:	c3                   	ret    

f01053e4 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01053e4:	fa                   	cli    

	xorw    %ax, %ax
f01053e5:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01053e7:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01053e9:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01053eb:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01053ed:	0f 01 16             	lgdtl  (%esi)
f01053f0:	74 70                	je     f0105462 <mpsearch1+0x3>
	movl    %cr0, %eax
f01053f2:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01053f5:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01053f9:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01053fc:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105402:	08 00                	or     %al,(%eax)

f0105404 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105404:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105408:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010540a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010540c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010540e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105412:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105414:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105416:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl    %eax, %cr3
f010541b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010541e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105421:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105426:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105429:	8b 25 94 1e 2a f0    	mov    0xf02a1e94,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010542f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105434:	b8 e0 01 10 f0       	mov    $0xf01001e0,%eax
	call    *%eax
f0105439:	ff d0                	call   *%eax

f010543b <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010543b:	eb fe                	jmp    f010543b <spin>
f010543d:	8d 76 00             	lea    0x0(%esi),%esi

f0105440 <gdt>:
	...
f0105448:	ff                   	(bad)  
f0105449:	ff 00                	incl   (%eax)
f010544b:	00 00                	add    %al,(%eax)
f010544d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105454:	00                   	.byte 0x0
f0105455:	92                   	xchg   %eax,%edx
f0105456:	cf                   	iret   
	...

f0105458 <gdtdesc>:
f0105458:	17                   	pop    %ss
f0105459:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010545e <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010545e:	90                   	nop

f010545f <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f010545f:	55                   	push   %ebp
f0105460:	89 e5                	mov    %esp,%ebp
f0105462:	57                   	push   %edi
f0105463:	56                   	push   %esi
f0105464:	53                   	push   %ebx
f0105465:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105468:	8b 0d 98 1e 2a f0    	mov    0xf02a1e98,%ecx
f010546e:	89 c3                	mov    %eax,%ebx
f0105470:	c1 eb 0c             	shr    $0xc,%ebx
f0105473:	39 cb                	cmp    %ecx,%ebx
f0105475:	72 12                	jb     f0105489 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105477:	50                   	push   %eax
f0105478:	68 a4 69 10 f0       	push   $0xf01069a4
f010547d:	6a 57                	push   $0x57
f010547f:	68 3d 85 10 f0       	push   $0xf010853d
f0105484:	e8 b7 ab ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105489:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010548f:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105491:	89 c2                	mov    %eax,%edx
f0105493:	c1 ea 0c             	shr    $0xc,%edx
f0105496:	39 ca                	cmp    %ecx,%edx
f0105498:	72 12                	jb     f01054ac <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010549a:	50                   	push   %eax
f010549b:	68 a4 69 10 f0       	push   $0xf01069a4
f01054a0:	6a 57                	push   $0x57
f01054a2:	68 3d 85 10 f0       	push   $0xf010853d
f01054a7:	e8 94 ab ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01054ac:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f01054b2:	eb 2f                	jmp    f01054e3 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01054b4:	83 ec 04             	sub    $0x4,%esp
f01054b7:	6a 04                	push   $0x4
f01054b9:	68 4d 85 10 f0       	push   $0xf010854d
f01054be:	53                   	push   %ebx
f01054bf:	e8 e6 fd ff ff       	call   f01052aa <memcmp>
f01054c4:	83 c4 10             	add    $0x10,%esp
f01054c7:	85 c0                	test   %eax,%eax
f01054c9:	75 15                	jne    f01054e0 <mpsearch1+0x81>
f01054cb:	89 da                	mov    %ebx,%edx
f01054cd:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f01054d0:	0f b6 0a             	movzbl (%edx),%ecx
f01054d3:	01 c8                	add    %ecx,%eax
f01054d5:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01054d8:	39 d7                	cmp    %edx,%edi
f01054da:	75 f4                	jne    f01054d0 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01054dc:	84 c0                	test   %al,%al
f01054de:	74 0e                	je     f01054ee <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01054e0:	83 c3 10             	add    $0x10,%ebx
f01054e3:	39 f3                	cmp    %esi,%ebx
f01054e5:	72 cd                	jb     f01054b4 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01054e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01054ec:	eb 02                	jmp    f01054f0 <mpsearch1+0x91>
f01054ee:	89 d8                	mov    %ebx,%eax
}
f01054f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01054f3:	5b                   	pop    %ebx
f01054f4:	5e                   	pop    %esi
f01054f5:	5f                   	pop    %edi
f01054f6:	5d                   	pop    %ebp
f01054f7:	c3                   	ret    

f01054f8 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01054f8:	55                   	push   %ebp
f01054f9:	89 e5                	mov    %esp,%ebp
f01054fb:	57                   	push   %edi
f01054fc:	56                   	push   %esi
f01054fd:	53                   	push   %ebx
f01054fe:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105501:	c7 05 c0 23 2a f0 20 	movl   $0xf02a2020,0xf02a23c0
f0105508:	20 2a f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010550b:	83 3d 98 1e 2a f0 00 	cmpl   $0x0,0xf02a1e98
f0105512:	75 16                	jne    f010552a <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105514:	68 00 04 00 00       	push   $0x400
f0105519:	68 a4 69 10 f0       	push   $0xf01069a4
f010551e:	6a 6f                	push   $0x6f
f0105520:	68 3d 85 10 f0       	push   $0xf010853d
f0105525:	e8 16 ab ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010552a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105531:	85 c0                	test   %eax,%eax
f0105533:	74 16                	je     f010554b <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105535:	c1 e0 04             	shl    $0x4,%eax
f0105538:	ba 00 04 00 00       	mov    $0x400,%edx
f010553d:	e8 1d ff ff ff       	call   f010545f <mpsearch1>
f0105542:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105545:	85 c0                	test   %eax,%eax
f0105547:	75 3c                	jne    f0105585 <mp_init+0x8d>
f0105549:	eb 20                	jmp    f010556b <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f010554b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105552:	c1 e0 0a             	shl    $0xa,%eax
f0105555:	2d 00 04 00 00       	sub    $0x400,%eax
f010555a:	ba 00 04 00 00       	mov    $0x400,%edx
f010555f:	e8 fb fe ff ff       	call   f010545f <mpsearch1>
f0105564:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105567:	85 c0                	test   %eax,%eax
f0105569:	75 1a                	jne    f0105585 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010556b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105570:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105575:	e8 e5 fe ff ff       	call   f010545f <mpsearch1>
f010557a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f010557d:	85 c0                	test   %eax,%eax
f010557f:	0f 84 5d 02 00 00    	je     f01057e2 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105585:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105588:	8b 70 04             	mov    0x4(%eax),%esi
f010558b:	85 f6                	test   %esi,%esi
f010558d:	74 06                	je     f0105595 <mp_init+0x9d>
f010558f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105593:	74 15                	je     f01055aa <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105595:	83 ec 0c             	sub    $0xc,%esp
f0105598:	68 b0 83 10 f0       	push   $0xf01083b0
f010559d:	e8 be e0 ff ff       	call   f0103660 <cprintf>
f01055a2:	83 c4 10             	add    $0x10,%esp
f01055a5:	e9 38 02 00 00       	jmp    f01057e2 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01055aa:	89 f0                	mov    %esi,%eax
f01055ac:	c1 e8 0c             	shr    $0xc,%eax
f01055af:	3b 05 98 1e 2a f0    	cmp    0xf02a1e98,%eax
f01055b5:	72 15                	jb     f01055cc <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01055b7:	56                   	push   %esi
f01055b8:	68 a4 69 10 f0       	push   $0xf01069a4
f01055bd:	68 90 00 00 00       	push   $0x90
f01055c2:	68 3d 85 10 f0       	push   $0xf010853d
f01055c7:	e8 74 aa ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01055cc:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01055d2:	83 ec 04             	sub    $0x4,%esp
f01055d5:	6a 04                	push   $0x4
f01055d7:	68 52 85 10 f0       	push   $0xf0108552
f01055dc:	53                   	push   %ebx
f01055dd:	e8 c8 fc ff ff       	call   f01052aa <memcmp>
f01055e2:	83 c4 10             	add    $0x10,%esp
f01055e5:	85 c0                	test   %eax,%eax
f01055e7:	74 15                	je     f01055fe <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01055e9:	83 ec 0c             	sub    $0xc,%esp
f01055ec:	68 e0 83 10 f0       	push   $0xf01083e0
f01055f1:	e8 6a e0 ff ff       	call   f0103660 <cprintf>
f01055f6:	83 c4 10             	add    $0x10,%esp
f01055f9:	e9 e4 01 00 00       	jmp    f01057e2 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01055fe:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105602:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105606:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105609:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f010560e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105613:	eb 0d                	jmp    f0105622 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105615:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f010561c:	f0 
f010561d:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010561f:	83 c0 01             	add    $0x1,%eax
f0105622:	39 c7                	cmp    %eax,%edi
f0105624:	75 ef                	jne    f0105615 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105626:	84 d2                	test   %dl,%dl
f0105628:	74 15                	je     f010563f <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f010562a:	83 ec 0c             	sub    $0xc,%esp
f010562d:	68 14 84 10 f0       	push   $0xf0108414
f0105632:	e8 29 e0 ff ff       	call   f0103660 <cprintf>
f0105637:	83 c4 10             	add    $0x10,%esp
f010563a:	e9 a3 01 00 00       	jmp    f01057e2 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f010563f:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105643:	3c 01                	cmp    $0x1,%al
f0105645:	74 1d                	je     f0105664 <mp_init+0x16c>
f0105647:	3c 04                	cmp    $0x4,%al
f0105649:	74 19                	je     f0105664 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f010564b:	83 ec 08             	sub    $0x8,%esp
f010564e:	0f b6 c0             	movzbl %al,%eax
f0105651:	50                   	push   %eax
f0105652:	68 38 84 10 f0       	push   $0xf0108438
f0105657:	e8 04 e0 ff ff       	call   f0103660 <cprintf>
f010565c:	83 c4 10             	add    $0x10,%esp
f010565f:	e9 7e 01 00 00       	jmp    f01057e2 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105664:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105668:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f010566c:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105671:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105676:	01 ce                	add    %ecx,%esi
f0105678:	eb 0d                	jmp    f0105687 <mp_init+0x18f>
f010567a:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105681:	f0 
f0105682:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105684:	83 c0 01             	add    $0x1,%eax
f0105687:	39 c7                	cmp    %eax,%edi
f0105689:	75 ef                	jne    f010567a <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010568b:	89 d0                	mov    %edx,%eax
f010568d:	02 43 2a             	add    0x2a(%ebx),%al
f0105690:	74 15                	je     f01056a7 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105692:	83 ec 0c             	sub    $0xc,%esp
f0105695:	68 58 84 10 f0       	push   $0xf0108458
f010569a:	e8 c1 df ff ff       	call   f0103660 <cprintf>
f010569f:	83 c4 10             	add    $0x10,%esp
f01056a2:	e9 3b 01 00 00       	jmp    f01057e2 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01056a7:	85 db                	test   %ebx,%ebx
f01056a9:	0f 84 33 01 00 00    	je     f01057e2 <mp_init+0x2ea>
		return;
	ismp = 1;
f01056af:	c7 05 00 20 2a f0 01 	movl   $0x1,0xf02a2000
f01056b6:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01056b9:	8b 43 24             	mov    0x24(%ebx),%eax
f01056bc:	a3 00 30 2e f0       	mov    %eax,0xf02e3000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01056c1:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f01056c4:	be 00 00 00 00       	mov    $0x0,%esi
f01056c9:	e9 85 00 00 00       	jmp    f0105753 <mp_init+0x25b>
		switch (*p) {
f01056ce:	0f b6 07             	movzbl (%edi),%eax
f01056d1:	84 c0                	test   %al,%al
f01056d3:	74 06                	je     f01056db <mp_init+0x1e3>
f01056d5:	3c 04                	cmp    $0x4,%al
f01056d7:	77 55                	ja     f010572e <mp_init+0x236>
f01056d9:	eb 4e                	jmp    f0105729 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01056db:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f01056df:	74 11                	je     f01056f2 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f01056e1:	6b 05 c4 23 2a f0 74 	imul   $0x74,0xf02a23c4,%eax
f01056e8:	05 20 20 2a f0       	add    $0xf02a2020,%eax
f01056ed:	a3 c0 23 2a f0       	mov    %eax,0xf02a23c0
			if (ncpu < NCPU) {
f01056f2:	a1 c4 23 2a f0       	mov    0xf02a23c4,%eax
f01056f7:	83 f8 07             	cmp    $0x7,%eax
f01056fa:	7f 13                	jg     f010570f <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f01056fc:	6b d0 74             	imul   $0x74,%eax,%edx
f01056ff:	88 82 20 20 2a f0    	mov    %al,-0xfd5dfe0(%edx)
				ncpu++;
f0105705:	83 c0 01             	add    $0x1,%eax
f0105708:	a3 c4 23 2a f0       	mov    %eax,0xf02a23c4
f010570d:	eb 15                	jmp    f0105724 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010570f:	83 ec 08             	sub    $0x8,%esp
f0105712:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105716:	50                   	push   %eax
f0105717:	68 88 84 10 f0       	push   $0xf0108488
f010571c:	e8 3f df ff ff       	call   f0103660 <cprintf>
f0105721:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105724:	83 c7 14             	add    $0x14,%edi
			continue;
f0105727:	eb 27                	jmp    f0105750 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105729:	83 c7 08             	add    $0x8,%edi
			continue;
f010572c:	eb 22                	jmp    f0105750 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010572e:	83 ec 08             	sub    $0x8,%esp
f0105731:	0f b6 c0             	movzbl %al,%eax
f0105734:	50                   	push   %eax
f0105735:	68 b0 84 10 f0       	push   $0xf01084b0
f010573a:	e8 21 df ff ff       	call   f0103660 <cprintf>
			ismp = 0;
f010573f:	c7 05 00 20 2a f0 00 	movl   $0x0,0xf02a2000
f0105746:	00 00 00 
			i = conf->entry;
f0105749:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f010574d:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105750:	83 c6 01             	add    $0x1,%esi
f0105753:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105757:	39 c6                	cmp    %eax,%esi
f0105759:	0f 82 6f ff ff ff    	jb     f01056ce <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010575f:	a1 c0 23 2a f0       	mov    0xf02a23c0,%eax
f0105764:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010576b:	83 3d 00 20 2a f0 00 	cmpl   $0x0,0xf02a2000
f0105772:	75 26                	jne    f010579a <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105774:	c7 05 c4 23 2a f0 01 	movl   $0x1,0xf02a23c4
f010577b:	00 00 00 
		lapicaddr = 0;
f010577e:	c7 05 00 30 2e f0 00 	movl   $0x0,0xf02e3000
f0105785:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105788:	83 ec 0c             	sub    $0xc,%esp
f010578b:	68 d0 84 10 f0       	push   $0xf01084d0
f0105790:	e8 cb de ff ff       	call   f0103660 <cprintf>
		return;
f0105795:	83 c4 10             	add    $0x10,%esp
f0105798:	eb 48                	jmp    f01057e2 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010579a:	83 ec 04             	sub    $0x4,%esp
f010579d:	ff 35 c4 23 2a f0    	pushl  0xf02a23c4
f01057a3:	0f b6 00             	movzbl (%eax),%eax
f01057a6:	50                   	push   %eax
f01057a7:	68 57 85 10 f0       	push   $0xf0108557
f01057ac:	e8 af de ff ff       	call   f0103660 <cprintf>

	if (mp->imcrp) {
f01057b1:	83 c4 10             	add    $0x10,%esp
f01057b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01057b7:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01057bb:	74 25                	je     f01057e2 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01057bd:	83 ec 0c             	sub    $0xc,%esp
f01057c0:	68 fc 84 10 f0       	push   $0xf01084fc
f01057c5:	e8 96 de ff ff       	call   f0103660 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01057ca:	ba 22 00 00 00       	mov    $0x22,%edx
f01057cf:	b8 70 00 00 00       	mov    $0x70,%eax
f01057d4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01057d5:	ba 23 00 00 00       	mov    $0x23,%edx
f01057da:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01057db:	83 c8 01             	or     $0x1,%eax
f01057de:	ee                   	out    %al,(%dx)
f01057df:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01057e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01057e5:	5b                   	pop    %ebx
f01057e6:	5e                   	pop    %esi
f01057e7:	5f                   	pop    %edi
f01057e8:	5d                   	pop    %ebp
f01057e9:	c3                   	ret    

f01057ea <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01057ea:	55                   	push   %ebp
f01057eb:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01057ed:	8b 0d 04 30 2e f0    	mov    0xf02e3004,%ecx
f01057f3:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01057f6:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01057f8:	a1 04 30 2e f0       	mov    0xf02e3004,%eax
f01057fd:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105800:	5d                   	pop    %ebp
f0105801:	c3                   	ret    

f0105802 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105802:	55                   	push   %ebp
f0105803:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105805:	a1 04 30 2e f0       	mov    0xf02e3004,%eax
f010580a:	85 c0                	test   %eax,%eax
f010580c:	74 08                	je     f0105816 <cpunum+0x14>
		return lapic[ID] >> 24;
f010580e:	8b 40 20             	mov    0x20(%eax),%eax
f0105811:	c1 e8 18             	shr    $0x18,%eax
f0105814:	eb 05                	jmp    f010581b <cpunum+0x19>
	return 0;
f0105816:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010581b:	5d                   	pop    %ebp
f010581c:	c3                   	ret    

f010581d <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f010581d:	a1 00 30 2e f0       	mov    0xf02e3000,%eax
f0105822:	85 c0                	test   %eax,%eax
f0105824:	0f 84 21 01 00 00    	je     f010594b <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f010582a:	55                   	push   %ebp
f010582b:	89 e5                	mov    %esp,%ebp
f010582d:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105830:	68 00 10 00 00       	push   $0x1000
f0105835:	50                   	push   %eax
f0105836:	e8 86 ba ff ff       	call   f01012c1 <mmio_map_region>
f010583b:	a3 04 30 2e f0       	mov    %eax,0xf02e3004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105840:	ba 27 01 00 00       	mov    $0x127,%edx
f0105845:	b8 3c 00 00 00       	mov    $0x3c,%eax
f010584a:	e8 9b ff ff ff       	call   f01057ea <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010584f:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105854:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105859:	e8 8c ff ff ff       	call   f01057ea <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010585e:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105863:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105868:	e8 7d ff ff ff       	call   f01057ea <lapicw>
	lapicw(TICR, 10000000); 
f010586d:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105872:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105877:	e8 6e ff ff ff       	call   f01057ea <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f010587c:	e8 81 ff ff ff       	call   f0105802 <cpunum>
f0105881:	6b c0 74             	imul   $0x74,%eax,%eax
f0105884:	05 20 20 2a f0       	add    $0xf02a2020,%eax
f0105889:	83 c4 10             	add    $0x10,%esp
f010588c:	39 05 c0 23 2a f0    	cmp    %eax,0xf02a23c0
f0105892:	74 0f                	je     f01058a3 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105894:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105899:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010589e:	e8 47 ff ff ff       	call   f01057ea <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01058a3:	ba 00 00 01 00       	mov    $0x10000,%edx
f01058a8:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01058ad:	e8 38 ff ff ff       	call   f01057ea <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01058b2:	a1 04 30 2e f0       	mov    0xf02e3004,%eax
f01058b7:	8b 40 30             	mov    0x30(%eax),%eax
f01058ba:	c1 e8 10             	shr    $0x10,%eax
f01058bd:	3c 03                	cmp    $0x3,%al
f01058bf:	76 0f                	jbe    f01058d0 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f01058c1:	ba 00 00 01 00       	mov    $0x10000,%edx
f01058c6:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01058cb:	e8 1a ff ff ff       	call   f01057ea <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01058d0:	ba 33 00 00 00       	mov    $0x33,%edx
f01058d5:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01058da:	e8 0b ff ff ff       	call   f01057ea <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01058df:	ba 00 00 00 00       	mov    $0x0,%edx
f01058e4:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01058e9:	e8 fc fe ff ff       	call   f01057ea <lapicw>
	lapicw(ESR, 0);
f01058ee:	ba 00 00 00 00       	mov    $0x0,%edx
f01058f3:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01058f8:	e8 ed fe ff ff       	call   f01057ea <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01058fd:	ba 00 00 00 00       	mov    $0x0,%edx
f0105902:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105907:	e8 de fe ff ff       	call   f01057ea <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f010590c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105911:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105916:	e8 cf fe ff ff       	call   f01057ea <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010591b:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105920:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105925:	e8 c0 fe ff ff       	call   f01057ea <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010592a:	8b 15 04 30 2e f0    	mov    0xf02e3004,%edx
f0105930:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105936:	f6 c4 10             	test   $0x10,%ah
f0105939:	75 f5                	jne    f0105930 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f010593b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105940:	b8 20 00 00 00       	mov    $0x20,%eax
f0105945:	e8 a0 fe ff ff       	call   f01057ea <lapicw>
}
f010594a:	c9                   	leave  
f010594b:	f3 c3                	repz ret 

f010594d <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f010594d:	83 3d 04 30 2e f0 00 	cmpl   $0x0,0xf02e3004
f0105954:	74 13                	je     f0105969 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105956:	55                   	push   %ebp
f0105957:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105959:	ba 00 00 00 00       	mov    $0x0,%edx
f010595e:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105963:	e8 82 fe ff ff       	call   f01057ea <lapicw>
}
f0105968:	5d                   	pop    %ebp
f0105969:	f3 c3                	repz ret 

f010596b <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010596b:	55                   	push   %ebp
f010596c:	89 e5                	mov    %esp,%ebp
f010596e:	56                   	push   %esi
f010596f:	53                   	push   %ebx
f0105970:	8b 75 08             	mov    0x8(%ebp),%esi
f0105973:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105976:	ba 70 00 00 00       	mov    $0x70,%edx
f010597b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105980:	ee                   	out    %al,(%dx)
f0105981:	ba 71 00 00 00       	mov    $0x71,%edx
f0105986:	b8 0a 00 00 00       	mov    $0xa,%eax
f010598b:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010598c:	83 3d 98 1e 2a f0 00 	cmpl   $0x0,0xf02a1e98
f0105993:	75 19                	jne    f01059ae <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105995:	68 67 04 00 00       	push   $0x467
f010599a:	68 a4 69 10 f0       	push   $0xf01069a4
f010599f:	68 98 00 00 00       	push   $0x98
f01059a4:	68 74 85 10 f0       	push   $0xf0108574
f01059a9:	e8 92 a6 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01059ae:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01059b5:	00 00 
	wrv[1] = addr >> 4;
f01059b7:	89 d8                	mov    %ebx,%eax
f01059b9:	c1 e8 04             	shr    $0x4,%eax
f01059bc:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01059c2:	c1 e6 18             	shl    $0x18,%esi
f01059c5:	89 f2                	mov    %esi,%edx
f01059c7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01059cc:	e8 19 fe ff ff       	call   f01057ea <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01059d1:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01059d6:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01059db:	e8 0a fe ff ff       	call   f01057ea <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01059e0:	ba 00 85 00 00       	mov    $0x8500,%edx
f01059e5:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01059ea:	e8 fb fd ff ff       	call   f01057ea <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01059ef:	c1 eb 0c             	shr    $0xc,%ebx
f01059f2:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01059f5:	89 f2                	mov    %esi,%edx
f01059f7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01059fc:	e8 e9 fd ff ff       	call   f01057ea <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105a01:	89 da                	mov    %ebx,%edx
f0105a03:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105a08:	e8 dd fd ff ff       	call   f01057ea <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105a0d:	89 f2                	mov    %esi,%edx
f0105a0f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105a14:	e8 d1 fd ff ff       	call   f01057ea <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105a19:	89 da                	mov    %ebx,%edx
f0105a1b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105a20:	e8 c5 fd ff ff       	call   f01057ea <lapicw>
		microdelay(200);
	}
}
f0105a25:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105a28:	5b                   	pop    %ebx
f0105a29:	5e                   	pop    %esi
f0105a2a:	5d                   	pop    %ebp
f0105a2b:	c3                   	ret    

f0105a2c <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105a2c:	55                   	push   %ebp
f0105a2d:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105a2f:	8b 55 08             	mov    0x8(%ebp),%edx
f0105a32:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105a38:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105a3d:	e8 a8 fd ff ff       	call   f01057ea <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105a42:	8b 15 04 30 2e f0    	mov    0xf02e3004,%edx
f0105a48:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105a4e:	f6 c4 10             	test   $0x10,%ah
f0105a51:	75 f5                	jne    f0105a48 <lapic_ipi+0x1c>
		;
}
f0105a53:	5d                   	pop    %ebp
f0105a54:	c3                   	ret    

f0105a55 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105a55:	55                   	push   %ebp
f0105a56:	89 e5                	mov    %esp,%ebp
f0105a58:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105a5b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105a61:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105a64:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105a67:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105a6e:	5d                   	pop    %ebp
f0105a6f:	c3                   	ret    

f0105a70 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105a70:	55                   	push   %ebp
f0105a71:	89 e5                	mov    %esp,%ebp
f0105a73:	56                   	push   %esi
f0105a74:	53                   	push   %ebx
f0105a75:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105a78:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105a7b:	74 14                	je     f0105a91 <spin_lock+0x21>
f0105a7d:	8b 73 08             	mov    0x8(%ebx),%esi
f0105a80:	e8 7d fd ff ff       	call   f0105802 <cpunum>
f0105a85:	6b c0 74             	imul   $0x74,%eax,%eax
f0105a88:	05 20 20 2a f0       	add    $0xf02a2020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105a8d:	39 c6                	cmp    %eax,%esi
f0105a8f:	74 07                	je     f0105a98 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105a91:	ba 01 00 00 00       	mov    $0x1,%edx
f0105a96:	eb 20                	jmp    f0105ab8 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105a98:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105a9b:	e8 62 fd ff ff       	call   f0105802 <cpunum>
f0105aa0:	83 ec 0c             	sub    $0xc,%esp
f0105aa3:	53                   	push   %ebx
f0105aa4:	50                   	push   %eax
f0105aa5:	68 84 85 10 f0       	push   $0xf0108584
f0105aaa:	6a 41                	push   $0x41
f0105aac:	68 e6 85 10 f0       	push   $0xf01085e6
f0105ab1:	e8 8a a5 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105ab6:	f3 90                	pause  
f0105ab8:	89 d0                	mov    %edx,%eax
f0105aba:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105abd:	85 c0                	test   %eax,%eax
f0105abf:	75 f5                	jne    f0105ab6 <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105ac1:	e8 3c fd ff ff       	call   f0105802 <cpunum>
f0105ac6:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ac9:	05 20 20 2a f0       	add    $0xf02a2020,%eax
f0105ace:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105ad1:	83 c3 0c             	add    $0xc,%ebx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0105ad4:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105ad6:	b8 00 00 00 00       	mov    $0x0,%eax
f0105adb:	eb 0b                	jmp    f0105ae8 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105add:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105ae0:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105ae3:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105ae5:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105ae8:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105aee:	76 11                	jbe    f0105b01 <spin_lock+0x91>
f0105af0:	83 f8 09             	cmp    $0x9,%eax
f0105af3:	7e e8                	jle    f0105add <spin_lock+0x6d>
f0105af5:	eb 0a                	jmp    f0105b01 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105af7:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105afe:	83 c0 01             	add    $0x1,%eax
f0105b01:	83 f8 09             	cmp    $0x9,%eax
f0105b04:	7e f1                	jle    f0105af7 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105b06:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105b09:	5b                   	pop    %ebx
f0105b0a:	5e                   	pop    %esi
f0105b0b:	5d                   	pop    %ebp
f0105b0c:	c3                   	ret    

f0105b0d <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105b0d:	55                   	push   %ebp
f0105b0e:	89 e5                	mov    %esp,%ebp
f0105b10:	57                   	push   %edi
f0105b11:	56                   	push   %esi
f0105b12:	53                   	push   %ebx
f0105b13:	83 ec 4c             	sub    $0x4c,%esp
f0105b16:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105b19:	83 3e 00             	cmpl   $0x0,(%esi)
f0105b1c:	74 18                	je     f0105b36 <spin_unlock+0x29>
f0105b1e:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105b21:	e8 dc fc ff ff       	call   f0105802 <cpunum>
f0105b26:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b29:	05 20 20 2a f0       	add    $0xf02a2020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105b2e:	39 c3                	cmp    %eax,%ebx
f0105b30:	0f 84 a5 00 00 00    	je     f0105bdb <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105b36:	83 ec 04             	sub    $0x4,%esp
f0105b39:	6a 28                	push   $0x28
f0105b3b:	8d 46 0c             	lea    0xc(%esi),%eax
f0105b3e:	50                   	push   %eax
f0105b3f:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105b42:	53                   	push   %ebx
f0105b43:	e8 e7 f6 ff ff       	call   f010522f <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105b48:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105b4b:	0f b6 38             	movzbl (%eax),%edi
f0105b4e:	8b 76 04             	mov    0x4(%esi),%esi
f0105b51:	e8 ac fc ff ff       	call   f0105802 <cpunum>
f0105b56:	57                   	push   %edi
f0105b57:	56                   	push   %esi
f0105b58:	50                   	push   %eax
f0105b59:	68 b0 85 10 f0       	push   $0xf01085b0
f0105b5e:	e8 fd da ff ff       	call   f0103660 <cprintf>
f0105b63:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105b66:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105b69:	eb 54                	jmp    f0105bbf <spin_unlock+0xb2>
f0105b6b:	83 ec 08             	sub    $0x8,%esp
f0105b6e:	57                   	push   %edi
f0105b6f:	50                   	push   %eax
f0105b70:	e8 8c ec ff ff       	call   f0104801 <debuginfo_eip>
f0105b75:	83 c4 10             	add    $0x10,%esp
f0105b78:	85 c0                	test   %eax,%eax
f0105b7a:	78 27                	js     f0105ba3 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105b7c:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105b7e:	83 ec 04             	sub    $0x4,%esp
f0105b81:	89 c2                	mov    %eax,%edx
f0105b83:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105b86:	52                   	push   %edx
f0105b87:	ff 75 b0             	pushl  -0x50(%ebp)
f0105b8a:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105b8d:	ff 75 ac             	pushl  -0x54(%ebp)
f0105b90:	ff 75 a8             	pushl  -0x58(%ebp)
f0105b93:	50                   	push   %eax
f0105b94:	68 f6 85 10 f0       	push   $0xf01085f6
f0105b99:	e8 c2 da ff ff       	call   f0103660 <cprintf>
f0105b9e:	83 c4 20             	add    $0x20,%esp
f0105ba1:	eb 12                	jmp    f0105bb5 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105ba3:	83 ec 08             	sub    $0x8,%esp
f0105ba6:	ff 36                	pushl  (%esi)
f0105ba8:	68 0d 86 10 f0       	push   $0xf010860d
f0105bad:	e8 ae da ff ff       	call   f0103660 <cprintf>
f0105bb2:	83 c4 10             	add    $0x10,%esp
f0105bb5:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105bb8:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105bbb:	39 c3                	cmp    %eax,%ebx
f0105bbd:	74 08                	je     f0105bc7 <spin_unlock+0xba>
f0105bbf:	89 de                	mov    %ebx,%esi
f0105bc1:	8b 03                	mov    (%ebx),%eax
f0105bc3:	85 c0                	test   %eax,%eax
f0105bc5:	75 a4                	jne    f0105b6b <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105bc7:	83 ec 04             	sub    $0x4,%esp
f0105bca:	68 15 86 10 f0       	push   $0xf0108615
f0105bcf:	6a 67                	push   $0x67
f0105bd1:	68 e6 85 10 f0       	push   $0xf01085e6
f0105bd6:	e8 65 a4 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0105bdb:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105be2:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105be9:	b8 00 00 00 00       	mov    $0x0,%eax
f0105bee:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0105bf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105bf4:	5b                   	pop    %ebx
f0105bf5:	5e                   	pop    %esi
f0105bf6:	5f                   	pop    %edi
f0105bf7:	5d                   	pop    %ebp
f0105bf8:	c3                   	ret    

f0105bf9 <e1000_page_alloc>:
// Returns:
//   0 on success
//   -E_NO_MEM if there is no more page to allocate a page or page table for mapping
static int
e1000_page_alloc(char **va_store, int perm)
{
f0105bf9:	55                   	push   %ebp
f0105bfa:	89 e5                	mov    %esp,%ebp
f0105bfc:	57                   	push   %edi
f0105bfd:	56                   	push   %esi
f0105bfe:	53                   	push   %ebx
f0105bff:	83 ec 0c             	sub    $0xc,%esp
f0105c02:	89 c6                	mov    %eax,%esi
f0105c04:	89 d7                	mov    %edx,%edi
	// Hold the virtual address of the next free page in virtual address space
	static char *nextfree;

	// Initial address should be in the beggining of a free area, above UTOP
	// The chosen address for that was MMIOLIM, there could be a better one
	if (!nextfree) {
f0105c06:	83 3d 80 1e 2a f0 00 	cmpl   $0x0,0xf02a1e80
f0105c0d:	75 0a                	jne    f0105c19 <e1000_page_alloc+0x20>
		nextfree = (char *) MMIOLIM;
f0105c0f:	c7 05 80 1e 2a f0 00 	movl   $0xefc00000,0xf02a1e80
f0105c16:	00 c0 ef 
	}

	// Tries to allocate a physical page
	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f0105c19:	83 ec 0c             	sub    $0xc,%esp
f0105c1c:	6a 01                	push   $0x1
f0105c1e:	e8 d0 b2 ff ff       	call   f0100ef3 <page_alloc>
f0105c23:	89 c3                	mov    %eax,%ebx
	if (!pp) {
f0105c25:	83 c4 10             	add    $0x10,%esp
f0105c28:	85 c0                	test   %eax,%eax
f0105c2a:	74 49                	je     f0105c75 <e1000_page_alloc+0x7c>
	        return -E_NO_MEM;
	}

	// Tries to map the physical page at nextfree on kern_pgdir
	int r;
	if ((r = page_insert(kern_pgdir, pp, nextfree, perm)) < 0) {
f0105c2c:	57                   	push   %edi
f0105c2d:	ff 35 80 1e 2a f0    	pushl  0xf02a1e80
f0105c33:	50                   	push   %eax
f0105c34:	ff 35 9c 1e 2a f0    	pushl  0xf02a1e9c
f0105c3a:	e8 f2 b5 ff ff       	call   f0101231 <page_insert>
f0105c3f:	83 c4 10             	add    $0x10,%esp
f0105c42:	85 c0                	test   %eax,%eax
f0105c44:	79 13                	jns    f0105c59 <e1000_page_alloc+0x60>
	        page_free(pp);
f0105c46:	83 ec 0c             	sub    $0xc,%esp
f0105c49:	53                   	push   %ebx
f0105c4a:	e8 14 b3 ff ff       	call   f0100f63 <page_free>
	        return -E_NO_MEM;
f0105c4f:	83 c4 10             	add    $0x10,%esp
f0105c52:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0105c57:	eb 21                	jmp    f0105c7a <e1000_page_alloc+0x81>
	}

	// Store the va of the page
	if(va_store)
f0105c59:	85 f6                	test   %esi,%esi
f0105c5b:	74 07                	je     f0105c64 <e1000_page_alloc+0x6b>
		*va_store = nextfree;
f0105c5d:	a1 80 1e 2a f0       	mov    0xf02a1e80,%eax
f0105c62:	89 06                	mov    %eax,(%esi)

	// Increment to next free page, and returns success
	nextfree += PGSIZE;
f0105c64:	81 05 80 1e 2a f0 00 	addl   $0x1000,0xf02a1e80
f0105c6b:	10 00 00 
	return 0;
f0105c6e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c73:	eb 05                	jmp    f0105c7a <e1000_page_alloc+0x81>
	}

	// Tries to allocate a physical page
	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
	if (!pp) {
	        return -E_NO_MEM;
f0105c75:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		*va_store = nextfree;

	// Increment to next free page, and returns success
	nextfree += PGSIZE;
	return 0;
}
f0105c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105c7d:	5b                   	pop    %ebx
f0105c7e:	5e                   	pop    %esi
f0105c7f:	5f                   	pop    %edi
f0105c80:	5d                   	pop    %ebp
f0105c81:	c3                   	ret    

f0105c82 <va2pa>:

// Translates virtual address to physical address
// Could also use UVPT, but I think this way is simpler/easier
static physaddr_t
va2pa(void *va)
{
f0105c82:	55                   	push   %ebp
f0105c83:	89 e5                	mov    %esp,%ebp
f0105c85:	83 ec 0c             	sub    $0xc,%esp
	struct PageInfo *pp = page_lookup(kern_pgdir, va, NULL);
f0105c88:	6a 00                	push   $0x0
f0105c8a:	50                   	push   %eax
f0105c8b:	ff 35 9c 1e 2a f0    	pushl  0xf02a1e9c
f0105c91:	e8 b5 b4 ff ff       	call   f010114b <page_lookup>
	if (!pp)
f0105c96:	83 c4 10             	add    $0x10,%esp
f0105c99:	85 c0                	test   %eax,%eax
f0105c9b:	75 17                	jne    f0105cb4 <va2pa+0x32>
		panic("va2pa: va is not mapped");
f0105c9d:	83 ec 04             	sub    $0x4,%esp
f0105ca0:	68 2d 86 10 f0       	push   $0xf010862d
f0105ca5:	68 4e 01 00 00       	push   $0x14e
f0105caa:	68 45 86 10 f0       	push   $0xf0108645
f0105caf:	e8 8c a3 ff ff       	call   f0100040 <_panic>
	return page2pa(pp);
f0105cb4:	2b 05 a0 1e 2a f0    	sub    0xf02a1ea0,%eax
f0105cba:	c1 f8 03             	sar    $0x3,%eax
f0105cbd:	c1 e0 0c             	shl    $0xc,%eax
}
f0105cc0:	c9                   	leave  
f0105cc1:	c3                   	ret    

f0105cc2 <init_transmission>:


// Initializes transmision
void
init_transmission(void)
{
f0105cc2:	55                   	push   %ebp
f0105cc3:	89 e5                	mov    %esp,%ebp
f0105cc5:	56                   	push   %esi
f0105cc6:	53                   	push   %ebx
f0105cc7:	83 ec 1c             	sub    $0x1c,%esp
	cprintf("E1000 initializing transmission\n");
f0105cca:	68 b8 86 10 f0       	push   $0xf01086b8
f0105ccf:	e8 8c d9 ff ff       	call   f0103660 <cprintf>

	/* Data structures setup */
	// Allocate memory for descriptor ring
	char *va;
	int r;
	if((r = e1000_page_alloc(&va, PTE_P | PTE_W)) < 0)
f0105cd4:	ba 03 00 00 00       	mov    $0x3,%edx
f0105cd9:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105cdc:	e8 18 ff ff ff       	call   f0105bf9 <e1000_page_alloc>
f0105ce1:	83 c4 10             	add    $0x10,%esp
f0105ce4:	85 c0                	test   %eax,%eax
f0105ce6:	79 12                	jns    f0105cfa <init_transmission+0x38>
		panic("e1000_page_alloc: %e", r);
f0105ce8:	50                   	push   %eax
f0105ce9:	68 52 86 10 f0       	push   $0xf0108652
f0105cee:	6a 20                	push   $0x20
f0105cf0:	68 45 86 10 f0       	push   $0xf0108645
f0105cf5:	e8 46 a3 ff ff       	call   f0100040 <_panic>
	tx_ring = (struct tx_desc *) va;
f0105cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105cfd:	a3 20 32 2e f0       	mov    %eax,0xf02e3220
f0105d02:	bb 40 32 2e f0       	mov    $0xf02e3240,%ebx
f0105d07:	be 80 32 2e f0       	mov    $0xf02e3280,%esi

	// Allocate memory for the buffers
	int i;
	for (i = 0; i < NUM_TX_DESC; i++) {
		if((r = e1000_page_alloc(&va, PTE_P | PTE_W)) < 0)
f0105d0c:	ba 03 00 00 00       	mov    $0x3,%edx
f0105d11:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105d14:	e8 e0 fe ff ff       	call   f0105bf9 <e1000_page_alloc>
f0105d19:	85 c0                	test   %eax,%eax
f0105d1b:	79 12                	jns    f0105d2f <init_transmission+0x6d>
			panic("e1000_page_alloc: %e", r);
f0105d1d:	50                   	push   %eax
f0105d1e:	68 52 86 10 f0       	push   $0xf0108652
f0105d23:	6a 27                	push   $0x27
f0105d25:	68 45 86 10 f0       	push   $0xf0108645
f0105d2a:	e8 11 a3 ff ff       	call   f0100040 <_panic>
		tx_buffers[i] = va;
f0105d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105d32:	89 03                	mov    %eax,(%ebx)
f0105d34:	83 c3 04             	add    $0x4,%ebx
		panic("e1000_page_alloc: %e", r);
	tx_ring = (struct tx_desc *) va;

	// Allocate memory for the buffers
	int i;
	for (i = 0; i < NUM_TX_DESC; i++) {
f0105d37:	39 f3                	cmp    %esi,%ebx
f0105d39:	75 d1                	jne    f0105d0c <init_transmission+0x4a>
	

	// Initial settings of the tx_descriptors
	for (i = 0; i < NUM_TX_DESC; i++) {
		// Set CMD.RS, so it updates DD
		tx_ring[i].cmd |= E1000_TXD_CMD_RS;
f0105d3b:	8b 15 20 32 2e f0    	mov    0xf02e3220,%edx
f0105d41:	8d 42 0b             	lea    0xb(%edx),%eax
f0105d44:	81 c2 0b 01 00 00    	add    $0x10b,%edx
f0105d4a:	80 08 08             	orb    $0x8,(%eax)
		// Set STATUS.DD, so it starts available
		tx_ring[i].status |= E1000_TXD_STAT_DD;
f0105d4d:	80 48 01 01          	orb    $0x1,0x1(%eax)
f0105d51:	83 c0 10             	add    $0x10,%eax
	}

	

	// Initial settings of the tx_descriptors
	for (i = 0; i < NUM_TX_DESC; i++) {
f0105d54:	39 d0                	cmp    %edx,%eax
f0105d56:	75 f2                	jne    f0105d4a <init_transmission+0x88>
	/* Registers setup (as shown in chapter 14.5 of intel manual) */

	// TDBAH & TDBAL (Transmit Descriptor Ring address)
	// Always store physical address, not the virtual address!
	// E1000_REG(E1000_TDBAH) = 0;
	E1000_REG(E1000_TDBAL) = va2pa(tx_ring);
f0105d58:	8b 1d 28 32 2e f0    	mov    0xf02e3228,%ebx
f0105d5e:	a1 20 32 2e f0       	mov    0xf02e3220,%eax
f0105d63:	e8 1a ff ff ff       	call   f0105c82 <va2pa>
f0105d68:	89 83 00 38 00 00    	mov    %eax,0x3800(%ebx)

	// TDLEN (Transmit Descriptor Ring length in bytes)
	// Length is NUM_TX_DESC * sizeof(struct tx_desc), which is NUM_TX_DESC * 16
	E1000_REG(E1000_TDLEN) = NUM_TX_DESC * sizeof(struct tx_desc);
f0105d6e:	a1 28 32 2e f0       	mov    0xf02e3228,%eax
f0105d73:	c7 80 08 38 00 00 00 	movl   $0x100,0x3808(%eax)
f0105d7a:	01 00 00 

	// TDH & TDT (Transmit Decriptor Ring Head and Tail)
	E1000_REG(E1000_TDH) = 0;
f0105d7d:	c7 80 10 38 00 00 00 	movl   $0x0,0x3810(%eax)
f0105d84:	00 00 00 
	E1000_REG(E1000_TDT) = 0;
f0105d87:	c7 80 18 38 00 00 00 	movl   $0x0,0x3818(%eax)
f0105d8e:	00 00 00 

	// TCTL (Transmit Control Register)
	// Enable TCTL.EN
	E1000_REG(E1000_TCTL) |= E1000_TCTL_EN;
f0105d91:	8b 90 00 04 00 00    	mov    0x400(%eax),%edx
f0105d97:	83 ca 02             	or     $0x2,%edx
f0105d9a:	89 90 00 04 00 00    	mov    %edx,0x400(%eax)
	// Enable TCTL.PSP
	E1000_REG(E1000_TCTL) |= E1000_TCTL_PSP;
f0105da0:	8b 90 00 04 00 00    	mov    0x400(%eax),%edx
f0105da6:	83 ca 08             	or     $0x8,%edx
f0105da9:	89 90 00 04 00 00    	mov    %edx,0x400(%eax)
	// Configure TCTL.CT
	/* No need */
	// Configure TCTL.COLD for full duplex operation (40h)
	E1000_REG(E1000_TCTL) &= (~E1000_TCTL_COLD | 0x00040000); // Hard coded...
f0105daf:	8b 90 00 04 00 00    	mov    0x400(%eax),%edx
f0105db5:	81 e2 ff 0f c4 ff    	and    $0xffc40fff,%edx
f0105dbb:	89 90 00 04 00 00    	mov    %edx,0x400(%eax)

	// TIPG
	E1000_REG(E1000_TIPG) = 0;
f0105dc1:	c7 80 10 04 00 00 00 	movl   $0x0,0x410(%eax)
f0105dc8:	00 00 00 
	E1000_REG(E1000_TIPG) += (10 <<  0); // TIPG.IPGT = 10, bits 0-9
f0105dcb:	8b 90 10 04 00 00    	mov    0x410(%eax),%edx
f0105dd1:	83 c2 0a             	add    $0xa,%edx
f0105dd4:	89 90 10 04 00 00    	mov    %edx,0x410(%eax)
	E1000_REG(E1000_TIPG) += ( 4 << 10); // TIPG.IPGR1 = 4 (2/3*IPGR2), 10-19
f0105dda:	8b 90 10 04 00 00    	mov    0x410(%eax),%edx
f0105de0:	81 c2 00 10 00 00    	add    $0x1000,%edx
f0105de6:	89 90 10 04 00 00    	mov    %edx,0x410(%eax)
	E1000_REG(E1000_TIPG) += ( 6 << 20); // TIPG.IPGR2 = 6, bits 20-29
f0105dec:	8b 90 10 04 00 00    	mov    0x410(%eax),%edx
f0105df2:	81 c2 00 00 60 00    	add    $0x600000,%edx
f0105df8:	89 90 10 04 00 00    	mov    %edx,0x410(%eax)
}
f0105dfe:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105e01:	5b                   	pop    %ebx
f0105e02:	5e                   	pop    %esi
f0105e03:	5d                   	pop    %ebp
f0105e04:	c3                   	ret    

f0105e05 <transmit_packet>:

// Transmit packet
void
transmit_packet(void *buf, size_t size)
{
f0105e05:	55                   	push   %ebp
f0105e06:	89 e5                	mov    %esp,%ebp
f0105e08:	57                   	push   %edi
f0105e09:	56                   	push   %esi
f0105e0a:	53                   	push   %ebx
f0105e0b:	83 ec 0c             	sub    $0xc,%esp
f0105e0e:	8b 7d 08             	mov    0x8(%ebp),%edi
	// Initial checkings
	if (size > MAX_PACKET_SIZE)
f0105e11:	81 7d 0c ee 05 00 00 	cmpl   $0x5ee,0xc(%ebp)
f0105e18:	76 14                	jbe    f0105e2e <transmit_packet+0x29>
		panic("Packet size is bigger than the maximum allowed");
f0105e1a:	83 ec 04             	sub    $0x4,%esp
f0105e1d:	68 dc 86 10 f0       	push   $0xf01086dc
f0105e22:	6a 5b                	push   $0x5b
f0105e24:	68 45 86 10 f0       	push   $0xf0108645
f0105e29:	e8 12 a2 ff ff       	call   f0100040 <_panic>
	if (!buf)
f0105e2e:	85 ff                	test   %edi,%edi
f0105e30:	75 14                	jne    f0105e46 <transmit_packet+0x41>
		panic("Null pointer passed");
f0105e32:	83 ec 04             	sub    $0x4,%esp
f0105e35:	68 67 86 10 f0       	push   $0xf0108667
f0105e3a:	6a 5d                	push   $0x5d
f0105e3c:	68 45 86 10 f0       	push   $0xf0108645
f0105e41:	e8 fa a1 ff ff       	call   f0100040 <_panic>

	// Retrieve tail and check if it is available (if ring is not full)
	// by checking if TXD.STATUS.DD is set
	uint32_t tail = E1000_REG(E1000_TDT);
f0105e46:	a1 28 32 2e f0       	mov    0xf02e3228,%eax
f0105e4b:	8b 98 18 38 00 00    	mov    0x3818(%eax),%ebx
	if (!(tx_ring[tail].status & 0x01)) {
f0105e51:	89 de                	mov    %ebx,%esi
f0105e53:	c1 e6 04             	shl    $0x4,%esi
f0105e56:	89 f0                	mov    %esi,%eax
f0105e58:	03 05 20 32 2e f0    	add    0xf02e3220,%eax
f0105e5e:	0f b6 50 0c          	movzbl 0xc(%eax),%edx
f0105e62:	f6 c2 01             	test   $0x1,%dl
f0105e65:	75 12                	jne    f0105e79 <transmit_packet+0x74>
		// Drop packet if tx_ring is full
		cprintf("tx_ring[tail] DD is not set: tx_ring is full. "
f0105e67:	83 ec 0c             	sub    $0xc,%esp
f0105e6a:	68 0c 87 10 f0       	push   $0xf010870c
f0105e6f:	e8 ec d7 ff ff       	call   f0103660 <cprintf>
			"Transmission aborted.\n");
		return;
f0105e74:	83 c4 10             	add    $0x10,%esp
f0105e77:	eb 72                	jmp    f0105eeb <transmit_packet+0xe6>
	}

	// Set CMD.EOP, meaning this is the end of packet
	tx_ring[tail].cmd |= E1000_TXD_CMD_EOP;
f0105e79:	80 48 0b 01          	orb    $0x1,0xb(%eax)
	// Set STAT.DD to 0, 
	tx_ring[tail].status &= ~E1000_TXD_STAT_DD;
f0105e7d:	83 e2 fe             	and    $0xfffffffe,%edx
f0105e80:	88 50 0c             	mov    %dl,0xc(%eax)

	// Put packet data in buffer
	memset(tx_buffers[tail], 0, PGSIZE);
f0105e83:	83 ec 04             	sub    $0x4,%esp
f0105e86:	68 00 10 00 00       	push   $0x1000
f0105e8b:	6a 00                	push   $0x0
f0105e8d:	ff 34 9d 40 32 2e f0 	pushl  -0xfd1cdc0(,%ebx,4)
f0105e94:	e8 49 f3 ff ff       	call   f01051e2 <memset>
	memmove(tx_buffers[tail], buf, size);
f0105e99:	83 c4 0c             	add    $0xc,%esp
f0105e9c:	ff 75 0c             	pushl  0xc(%ebp)
f0105e9f:	57                   	push   %edi
f0105ea0:	ff 34 9d 40 32 2e f0 	pushl  -0xfd1cdc0(,%ebx,4)
f0105ea7:	e8 83 f3 ff ff       	call   f010522f <memmove>

	// Update tx descriptor
	tx_ring[tail].addr = (uint64_t) va2pa(tx_buffers[tail]); 
f0105eac:	89 f7                	mov    %esi,%edi
f0105eae:	03 3d 20 32 2e f0    	add    0xf02e3220,%edi
f0105eb4:	8b 04 9d 40 32 2e f0 	mov    -0xfd1cdc0(,%ebx,4),%eax
f0105ebb:	e8 c2 fd ff ff       	call   f0105c82 <va2pa>
f0105ec0:	89 07                	mov    %eax,(%edi)
f0105ec2:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	tx_ring[tail].length = (uint16_t) size;
f0105ec9:	a1 20 32 2e f0       	mov    0xf02e3220,%eax
f0105ece:	0f b7 4d 0c          	movzwl 0xc(%ebp),%ecx
f0105ed2:	66 89 4c 30 08       	mov    %cx,0x8(%eax,%esi,1)

	

	// Update tail
	tail = (tail + 1) % NUM_TX_DESC;
f0105ed7:	83 c3 01             	add    $0x1,%ebx
f0105eda:	83 e3 0f             	and    $0xf,%ebx
	E1000_REG(E1000_TDT) = tail;
f0105edd:	a1 28 32 2e f0       	mov    0xf02e3228,%eax
f0105ee2:	89 98 18 38 00 00    	mov    %ebx,0x3818(%eax)
f0105ee8:	83 c4 10             	add    $0x10,%esp
}
f0105eeb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105eee:	5b                   	pop    %ebx
f0105eef:	5e                   	pop    %esi
f0105ef0:	5f                   	pop    %edi
f0105ef1:	5d                   	pop    %ebp
f0105ef2:	c3                   	ret    

f0105ef3 <init_receive>:

// Initializes receive
void
init_receive(void)
{
f0105ef3:	55                   	push   %ebp
f0105ef4:	89 e5                	mov    %esp,%ebp
f0105ef6:	56                   	push   %esi
f0105ef7:	53                   	push   %ebx
f0105ef8:	83 ec 1c             	sub    $0x1c,%esp
	cprintf("E1000 initializing receive\n");
f0105efb:	68 7b 86 10 f0       	push   $0xf010867b
f0105f00:	e8 5b d7 ff ff       	call   f0103660 <cprintf>

	
	// Allocate memory for descriptor ring
	char *va;
	int r;
	if((r = e1000_page_alloc(&va, PTE_P | PTE_W)) < 0)
f0105f05:	ba 03 00 00 00       	mov    $0x3,%edx
f0105f0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105f0d:	e8 e7 fc ff ff       	call   f0105bf9 <e1000_page_alloc>
f0105f12:	83 c4 10             	add    $0x10,%esp
f0105f15:	85 c0                	test   %eax,%eax
f0105f17:	79 15                	jns    f0105f2e <init_receive+0x3b>
		panic("e1000_page_alloc: %e", r);
f0105f19:	50                   	push   %eax
f0105f1a:	68 52 86 10 f0       	push   $0xf0108652
f0105f1f:	68 88 00 00 00       	push   $0x88
f0105f24:	68 45 86 10 f0       	push   $0xf0108645
f0105f29:	e8 12 a1 ff ff       	call   f0100040 <_panic>
	rx_ring = (struct rx_desc *) va;
f0105f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105f31:	a3 24 32 2e f0       	mov    %eax,0xf02e3224
f0105f36:	bb 20 30 2e f0       	mov    $0xf02e3020,%ebx
f0105f3b:	be 20 32 2e f0       	mov    $0xf02e3220,%esi

	// Allocate memory for the buffers
	int i;
	for (i = 0; i < NUM_RX_DESC; i++) {
		if((r = e1000_page_alloc(&va, PTE_P | PTE_W)) < 0)
f0105f40:	ba 03 00 00 00       	mov    $0x3,%edx
f0105f45:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0105f48:	e8 ac fc ff ff       	call   f0105bf9 <e1000_page_alloc>
f0105f4d:	85 c0                	test   %eax,%eax
f0105f4f:	79 15                	jns    f0105f66 <init_receive+0x73>
			panic("e1000_page_alloc: %e", r);
f0105f51:	50                   	push   %eax
f0105f52:	68 52 86 10 f0       	push   $0xf0108652
f0105f57:	68 8f 00 00 00       	push   $0x8f
f0105f5c:	68 45 86 10 f0       	push   $0xf0108645
f0105f61:	e8 da a0 ff ff       	call   f0100040 <_panic>
		rx_buffers[i] = va;
f0105f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105f69:	89 03                	mov    %eax,(%ebx)
f0105f6b:	83 c3 04             	add    $0x4,%ebx
		panic("e1000_page_alloc: %e", r);
	rx_ring = (struct rx_desc *) va;

	// Allocate memory for the buffers
	int i;
	for (i = 0; i < NUM_RX_DESC; i++) {
f0105f6e:	39 de                	cmp    %ebx,%esi
f0105f70:	75 ce                	jne    f0105f40 <init_receive+0x4d>
f0105f72:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Initial settings of the rx_descriptors
	for (i = 0; i < NUM_RX_DESC; i++) {
		

		// Buffer address
		rx_ring[i].addr = (uint64_t) va2pa(rx_buffers[i]);
f0105f77:	a1 24 32 2e f0       	mov    0xf02e3224,%eax
f0105f7c:	8d 34 98             	lea    (%eax,%ebx,4),%esi
f0105f7f:	8b 83 20 30 2e f0    	mov    -0xfd1cfe0(%ebx),%eax
f0105f85:	e8 f8 fc ff ff       	call   f0105c82 <va2pa>
f0105f8a:	89 06                	mov    %eax,(%esi)
f0105f8c:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
f0105f93:	83 c3 04             	add    $0x4,%ebx
	}

	

	// Initial settings of the rx_descriptors
	for (i = 0; i < NUM_RX_DESC; i++) {
f0105f96:	81 fb 00 02 00 00    	cmp    $0x200,%ebx
f0105f9c:	75 d9                	jne    f0105f77 <init_receive+0x84>
	}

	// The last descriptor starts pointed by the tail
	// The rx descriptor pointed by the tail is always software owned and
	// holds no packet (DD=1, EOP=1)
	rx_ring[NUM_RX_DESC-1].status |= E1000_RXD_STAT_DD;
f0105f9e:	a1 24 32 2e f0       	mov    0xf02e3224,%eax
	rx_ring[NUM_RX_DESC-1].status |= E1000_RXD_STAT_EOP;
f0105fa3:	80 88 fc 07 00 00 03 	orb    $0x3,0x7fc(%eax)
	/* Registers setup */

	// RAL0 and RAH0 (stores the 48-bit mac address, for filtering packets)
	// E1000_RAL0 with the low 32 bits
	// E1000_RAH0 with high 16 bits, in bits 0-15. 16-31 are zeroes.
	uint32_t mac_addr_low_32 =
f0105faa:	0f b6 15 95 34 12 f0 	movzbl 0xf0123495,%edx
f0105fb1:	89 d1                	mov    %edx,%ecx
f0105fb3:	c1 e1 08             	shl    $0x8,%ecx
f0105fb6:	0f b6 15 96 34 12 f0 	movzbl 0xf0123496,%edx
f0105fbd:	c1 e2 10             	shl    $0x10,%edx
f0105fc0:	01 ca                	add    %ecx,%edx
f0105fc2:	0f b6 1d 94 34 12 f0 	movzbl 0xf0123494,%ebx
f0105fc9:	01 d3                	add    %edx,%ebx
f0105fcb:	0f b6 15 97 34 12 f0 	movzbl 0xf0123497,%edx
f0105fd2:	89 d1                	mov    %edx,%ecx
f0105fd4:	c1 e1 18             	shl    $0x18,%ecx
f0105fd7:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
		(((uint32_t) mac_address[0]) <<  0) +
		(((uint32_t) mac_address[1]) <<  8) +
		(((uint32_t) mac_address[2]) << 16) +
		(((uint32_t) mac_address[3]) << 24);
	uint32_t mac_addr_high_16 =
f0105fda:	0f b6 0d 99 34 12 f0 	movzbl 0xf0123499,%ecx
f0105fe1:	c1 e1 08             	shl    $0x8,%ecx
f0105fe4:	89 cb                	mov    %ecx,%ebx
f0105fe6:	0f b6 0d 98 34 12 f0 	movzbl 0xf0123498,%ecx
f0105fed:	01 d9                	add    %ebx,%ecx
		(((uint32_t) mac_address[4]) << 0) +
		(((uint32_t) mac_address[5]) << 8);
	E1000_REG(E1000_RAL0) = mac_addr_low_32;
f0105fef:	8b 1d 28 32 2e f0    	mov    0xf02e3228,%ebx
f0105ff5:	89 93 00 54 00 00    	mov    %edx,0x5400(%ebx)
	E1000_REG(E1000_RAH0) = mac_addr_high_16;
f0105ffb:	89 8b 04 54 00 00    	mov    %ecx,0x5404(%ebx)
	E1000_REG(E1000_RAH0) |= E1000_RAH0_AV; // Set E1000_RAH0 Address Valid bit
f0106001:	8b 93 04 54 00 00    	mov    0x5404(%ebx),%edx
f0106007:	81 ca 00 00 00 80    	or     $0x80000000,%edx
f010600d:	89 93 04 54 00 00    	mov    %edx,0x5404(%ebx)
	

	// RDBAL and RDBAH (Receive Descriptor Ring address)
	// Always store physical address, not the virtual address!
	// Don't use RDBAH as we are using 32 bit addresses
	E1000_REG(E1000_RDBAL) = va2pa(rx_ring);
f0106013:	e8 6a fc ff ff       	call   f0105c82 <va2pa>
f0106018:	89 83 00 28 00 00    	mov    %eax,0x2800(%ebx)

	// RDLEN (Receive Descriptor Ring length in bytes)
	// This size must be multiple of 128 bytes
	E1000_REG(E1000_RDLEN) = NUM_RX_DESC * sizeof(struct rx_desc);
f010601e:	a1 28 32 2e f0       	mov    0xf02e3228,%eax
f0106023:	c7 80 08 28 00 00 00 	movl   $0x800,0x2808(%eax)
f010602a:	08 00 00 

	// RDH and RDT (rx_ring head and tail indexes)
	E1000_REG(E1000_RDH) = 0;
f010602d:	c7 80 10 28 00 00 00 	movl   $0x0,0x2810(%eax)
f0106034:	00 00 00 
	E1000_REG(E1000_RDT) = NUM_RX_DESC - 1;
f0106037:	c7 80 18 28 00 00 7f 	movl   $0x7f,0x2818(%eax)
f010603e:	00 00 00 

	// RCTL (Receive Control Register) (Initial values are all 0)
	// RCTL.EN = 1b
	E1000_REG(E1000_RCTL) |= E1000_RCTL_EN;
f0106041:	8b 90 00 01 00 00    	mov    0x100(%eax),%edx
f0106047:	83 ca 02             	or     $0x2,%edx
f010604a:	89 90 00 01 00 00    	mov    %edx,0x100(%eax)
	
	// RCTL.BAM = 1b
	E1000_REG(E1000_RCTL) |= E1000_RCTL_BAM;
f0106050:	8b 90 00 01 00 00    	mov    0x100(%eax),%edx
f0106056:	80 ce 80             	or     $0x80,%dh
f0106059:	89 90 00 01 00 00    	mov    %edx,0x100(%eax)
	
	// RCTL.SECRC = 1b (Strips the CRC from packet)
	E1000_REG(E1000_RCTL) |= E1000_RCTL_SECRC;
f010605f:	8b 90 00 01 00 00    	mov    0x100(%eax),%edx
f0106065:	81 ca 00 00 00 04    	or     $0x4000000,%edx
f010606b:	89 90 00 01 00 00    	mov    %edx,0x100(%eax)
}
f0106071:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106074:	5b                   	pop    %ebx
f0106075:	5e                   	pop    %esi
f0106076:	5d                   	pop    %ebp
f0106077:	c3                   	ret    

f0106078 <receive_packet>:
//   Descriptors owned by software: DD and EOP is set
//   Descriptors owned by hardware: DD and EOP are not set
//   The desc. pointed by the tail is SW-owned, but holds no packet.
void
receive_packet(void *buf, size_t *size_store)
{
f0106078:	55                   	push   %ebp
f0106079:	89 e5                	mov    %esp,%ebp
f010607b:	57                   	push   %edi
f010607c:	56                   	push   %esi
f010607d:	53                   	push   %ebx
f010607e:	83 ec 0c             	sub    $0xc,%esp
f0106081:	8b 45 08             	mov    0x8(%ebp),%eax
	// Initial checkings
	if (!buf || !size_store)
f0106084:	85 c0                	test   %eax,%eax
f0106086:	74 06                	je     f010608e <receive_packet+0x16>
f0106088:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010608c:	75 17                	jne    f01060a5 <receive_packet+0x2d>
		panic("Null pointer passed");
f010608e:	83 ec 04             	sub    $0x4,%esp
f0106091:	68 67 86 10 f0       	push   $0xf0108667
f0106096:	68 d8 00 00 00       	push   $0xd8
f010609b:	68 45 86 10 f0       	push   $0xf0108645
f01060a0:	e8 9b 9f ff ff       	call   f0100040 <_panic>

	uint32_t tail = E1000_REG(E1000_RDT);
f01060a5:	8b 15 28 32 2e f0    	mov    0xf02e3228,%edx
f01060ab:	8b b2 18 28 00 00    	mov    0x2818(%edx),%esi
	uint32_t next = (tail+1)%NUM_RX_DESC;
f01060b1:	8d 5e 01             	lea    0x1(%esi),%ebx
f01060b4:	83 e3 7f             	and    $0x7f,%ebx

	// Analyzes if the next is sw owned(DD = 1) or hw owned (DD = 0)
	if (rx_ring[next].status & E1000_RXD_STAT_DD) {
f01060b7:	89 df                	mov    %ebx,%edi
f01060b9:	c1 e7 04             	shl    $0x4,%edi
f01060bc:	89 fa                	mov    %edi,%edx
f01060be:	03 15 24 32 2e f0    	add    0xf02e3224,%edx
f01060c4:	f6 42 0c 01          	testb  $0x1,0xc(%edx)
f01060c8:	74 3f                	je     f0106109 <receive_packet+0x91>
		// cprintf("receive_packet - copying packet to provided buf\n");

		// The next descriptor is sofware owned, so we can read it's data
		// Attention: don't use the buffer address from the descriptor,
		// since it's a physical address
		memmove(buf, rx_buffers[next], (size_t)rx_ring[next].length);
f01060ca:	83 ec 04             	sub    $0x4,%esp
f01060cd:	0f b7 52 08          	movzwl 0x8(%edx),%edx
f01060d1:	52                   	push   %edx
f01060d2:	ff 34 9d 20 30 2e f0 	pushl  -0xfd1cfe0(,%ebx,4)
f01060d9:	50                   	push   %eax
f01060da:	e8 50 f1 ff ff       	call   f010522f <memmove>
		*size_store = (size_t) rx_ring[next].length;
f01060df:	a1 24 32 2e f0       	mov    0xf02e3224,%eax
f01060e4:	0f b7 44 38 08       	movzwl 0x8(%eax,%edi,1),%eax
f01060e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01060ec:	89 01                	mov    %eax,(%ecx)

		// Current tail becomes hw-owned (DD=0, EOP=0)
		rx_ring[tail].status &= ~E1000_RXD_STAT_DD;
f01060ee:	c1 e6 04             	shl    $0x4,%esi
f01060f1:	03 35 24 32 2e f0    	add    0xf02e3224,%esi
		rx_ring[tail].status &= ~E1000_RXD_STAT_EOP;
f01060f7:	80 66 0c fc          	andb   $0xfc,0xc(%esi)

		// Now make tail point to next
		E1000_REG(E1000_RDT) = next;
f01060fb:	a1 28 32 2e f0       	mov    0xf02e3228,%eax
f0106100:	89 98 18 28 00 00    	mov    %ebx,0x2818(%eax)
f0106106:	83 c4 10             	add    $0x10,%esp
	} else {
		// The next descriptor is hardware owned. There's nothing to receive
		/* Do nothing */
		return;
	}
}
f0106109:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010610c:	5b                   	pop    %ebx
f010610d:	5e                   	pop    %esi
f010610e:	5f                   	pop    %edi
f010610f:	5d                   	pop    %ebp
f0106110:	c3                   	ret    

f0106111 <get_mac_address>:



void
get_mac_address(void *buf)
{
f0106111:	55                   	push   %ebp
f0106112:	89 e5                	mov    %esp,%ebp
f0106114:	83 ec 08             	sub    $0x8,%esp
f0106117:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (!buf)
f010611a:	85 c9                	test   %ecx,%ecx
f010611c:	75 17                	jne    f0106135 <get_mac_address+0x24>
		panic("get_mac_address: null pointer");
f010611e:	83 ec 04             	sub    $0x4,%esp
f0106121:	68 97 86 10 f0       	push   $0xf0108697
f0106126:	68 fc 00 00 00       	push   $0xfc
f010612b:	68 45 86 10 f0       	push   $0xf0108645
f0106130:	e8 0b 9f ff ff       	call   f0100040 <_panic>
f0106135:	b8 00 00 00 00       	mov    $0x0,%eax

	uint8_t *mac_addr_copy = (uint8_t *) buf;
	int i;
	for (i = 0; i < 6; i++) {
		*(mac_addr_copy + i) = mac_address[i];
f010613a:	0f b6 90 94 34 12 f0 	movzbl -0xfedcb6c(%eax),%edx
f0106141:	88 14 01             	mov    %dl,(%ecx,%eax,1)
	if (!buf)
		panic("get_mac_address: null pointer");

	uint8_t *mac_addr_copy = (uint8_t *) buf;
	int i;
	for (i = 0; i < 6; i++) {
f0106144:	83 c0 01             	add    $0x1,%eax
f0106147:	83 f8 06             	cmp    $0x6,%eax
f010614a:	75 ee                	jne    f010613a <get_mac_address+0x29>
		*(mac_addr_copy + i) = mac_address[i];
	}
}
f010614c:	c9                   	leave  
f010614d:	c3                   	ret    

f010614e <attach_e1000>:

// Initialize the E1000, which is a PCI device
// Returns 0 on success (always)
int
attach_e1000(struct pci_func *pcif)
{
f010614e:	55                   	push   %ebp
f010614f:	89 e5                	mov    %esp,%ebp
f0106151:	53                   	push   %ebx
f0106152:	83 ec 10             	sub    $0x10,%esp
f0106155:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	pci_func_enable(pcif);
f0106158:	53                   	push   %ebx
f0106159:	e8 ed 03 00 00       	call   f010654b <pci_func_enable>

	// Map MMIO to an appropiate virtual memory
	physaddr_t pa = pcif->reg_base[0];
	size_t size = pcif->reg_size[0];
	e1000 = mmio_map_region(pa, size);
f010615e:	83 c4 08             	add    $0x8,%esp
f0106161:	ff 73 2c             	pushl  0x2c(%ebx)
f0106164:	ff 73 14             	pushl  0x14(%ebx)
f0106167:	e8 55 b1 ff ff       	call   f01012c1 <mmio_map_region>
f010616c:	a3 28 32 2e f0       	mov    %eax,0xf02e3228

	


	// Initializations
	init_transmission();
f0106171:	e8 4c fb ff ff       	call   f0105cc2 <init_transmission>
	init_receive();
f0106176:	e8 78 fd ff ff       	call   f0105ef3 <init_receive>

	

	return 0;
}
f010617b:	b8 00 00 00 00       	mov    $0x0,%eax
f0106180:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0106183:	c9                   	leave  
f0106184:	c3                   	ret    

f0106185 <pci_attach_match>:
}

static int __attribute__((warn_unused_result))
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
f0106185:	55                   	push   %ebp
f0106186:	89 e5                	mov    %esp,%ebp
f0106188:	57                   	push   %edi
f0106189:	56                   	push   %esi
f010618a:	53                   	push   %ebx
f010618b:	83 ec 0c             	sub    $0xc,%esp
f010618e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106191:	8b 45 10             	mov    0x10(%ebp),%eax
f0106194:	8d 58 08             	lea    0x8(%eax),%ebx
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f0106197:	eb 3a                	jmp    f01061d3 <pci_attach_match+0x4e>
		if (list[i].key1 == key1 && list[i].key2 == key2) {
f0106199:	39 7b f8             	cmp    %edi,-0x8(%ebx)
f010619c:	75 32                	jne    f01061d0 <pci_attach_match+0x4b>
f010619e:	8b 55 0c             	mov    0xc(%ebp),%edx
f01061a1:	39 56 fc             	cmp    %edx,-0x4(%esi)
f01061a4:	75 2a                	jne    f01061d0 <pci_attach_match+0x4b>
			int r = list[i].attachfn(pcif);
f01061a6:	83 ec 0c             	sub    $0xc,%esp
f01061a9:	ff 75 14             	pushl  0x14(%ebp)
f01061ac:	ff d0                	call   *%eax
			if (r > 0)
f01061ae:	83 c4 10             	add    $0x10,%esp
f01061b1:	85 c0                	test   %eax,%eax
f01061b3:	7f 26                	jg     f01061db <pci_attach_match+0x56>
				return r;
			if (r < 0)
f01061b5:	85 c0                	test   %eax,%eax
f01061b7:	79 17                	jns    f01061d0 <pci_attach_match+0x4b>
				cprintf("pci_attach_match: attaching "
f01061b9:	83 ec 0c             	sub    $0xc,%esp
f01061bc:	50                   	push   %eax
f01061bd:	ff 36                	pushl  (%esi)
f01061bf:	ff 75 0c             	pushl  0xc(%ebp)
f01061c2:	57                   	push   %edi
f01061c3:	68 54 87 10 f0       	push   $0xf0108754
f01061c8:	e8 93 d4 ff ff       	call   f0103660 <cprintf>
f01061cd:	83 c4 20             	add    $0x20,%esp
f01061d0:	83 c3 0c             	add    $0xc,%ebx
f01061d3:	89 de                	mov    %ebx,%esi
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f01061d5:	8b 03                	mov    (%ebx),%eax
f01061d7:	85 c0                	test   %eax,%eax
f01061d9:	75 be                	jne    f0106199 <pci_attach_match+0x14>
					"%x.%x (%p): e\n",
					key1, key2, list[i].attachfn, r);
		}
	}
	return 0;
}
f01061db:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01061de:	5b                   	pop    %ebx
f01061df:	5e                   	pop    %esi
f01061e0:	5f                   	pop    %edi
f01061e1:	5d                   	pop    %ebp
f01061e2:	c3                   	ret    

f01061e3 <pci_conf1_set_addr>:
static void
pci_conf1_set_addr(uint32_t bus,
		   uint32_t dev,
		   uint32_t func,
		   uint32_t offset)
{
f01061e3:	55                   	push   %ebp
f01061e4:	89 e5                	mov    %esp,%ebp
f01061e6:	53                   	push   %ebx
f01061e7:	83 ec 04             	sub    $0x4,%esp
f01061ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	assert(bus < 256);
f01061ed:	3d ff 00 00 00       	cmp    $0xff,%eax
f01061f2:	76 16                	jbe    f010620a <pci_conf1_set_addr+0x27>
f01061f4:	68 ac 88 10 f0       	push   $0xf01088ac
f01061f9:	68 dd 78 10 f0       	push   $0xf01078dd
f01061fe:	6a 2c                	push   $0x2c
f0106200:	68 b6 88 10 f0       	push   $0xf01088b6
f0106205:	e8 36 9e ff ff       	call   f0100040 <_panic>
	assert(dev < 32);
f010620a:	83 fa 1f             	cmp    $0x1f,%edx
f010620d:	76 16                	jbe    f0106225 <pci_conf1_set_addr+0x42>
f010620f:	68 c1 88 10 f0       	push   $0xf01088c1
f0106214:	68 dd 78 10 f0       	push   $0xf01078dd
f0106219:	6a 2d                	push   $0x2d
f010621b:	68 b6 88 10 f0       	push   $0xf01088b6
f0106220:	e8 1b 9e ff ff       	call   f0100040 <_panic>
	assert(func < 8);
f0106225:	83 f9 07             	cmp    $0x7,%ecx
f0106228:	76 16                	jbe    f0106240 <pci_conf1_set_addr+0x5d>
f010622a:	68 ca 88 10 f0       	push   $0xf01088ca
f010622f:	68 dd 78 10 f0       	push   $0xf01078dd
f0106234:	6a 2e                	push   $0x2e
f0106236:	68 b6 88 10 f0       	push   $0xf01088b6
f010623b:	e8 00 9e ff ff       	call   f0100040 <_panic>
	assert(offset < 256);
f0106240:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0106246:	76 16                	jbe    f010625e <pci_conf1_set_addr+0x7b>
f0106248:	68 d3 88 10 f0       	push   $0xf01088d3
f010624d:	68 dd 78 10 f0       	push   $0xf01078dd
f0106252:	6a 2f                	push   $0x2f
f0106254:	68 b6 88 10 f0       	push   $0xf01088b6
f0106259:	e8 e2 9d ff ff       	call   f0100040 <_panic>
	assert((offset & 0x3) == 0);
f010625e:	f6 c3 03             	test   $0x3,%bl
f0106261:	74 16                	je     f0106279 <pci_conf1_set_addr+0x96>
f0106263:	68 e0 88 10 f0       	push   $0xf01088e0
f0106268:	68 dd 78 10 f0       	push   $0xf01078dd
f010626d:	6a 30                	push   $0x30
f010626f:	68 b6 88 10 f0       	push   $0xf01088b6
f0106274:	e8 c7 9d ff ff       	call   f0100040 <_panic>
}

static __inline void
outl(int port, uint32_t data)
{
	__asm __volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0106279:	c1 e1 08             	shl    $0x8,%ecx
f010627c:	81 cb 00 00 00 80    	or     $0x80000000,%ebx
f0106282:	09 cb                	or     %ecx,%ebx
f0106284:	c1 e2 0b             	shl    $0xb,%edx
f0106287:	09 d3                	or     %edx,%ebx
f0106289:	c1 e0 10             	shl    $0x10,%eax
f010628c:	09 d8                	or     %ebx,%eax
f010628e:	ba f8 0c 00 00       	mov    $0xcf8,%edx
f0106293:	ef                   	out    %eax,(%dx)

	uint32_t v = (1 << 31) |		// config-space
		(bus << 16) | (dev << 11) | (func << 8) | (offset);
	outl(pci_conf1_addr_ioport, v);
}
f0106294:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0106297:	c9                   	leave  
f0106298:	c3                   	ret    

f0106299 <pci_conf_read>:

static uint32_t
pci_conf_read(struct pci_func *f, uint32_t off)
{
f0106299:	55                   	push   %ebp
f010629a:	89 e5                	mov    %esp,%ebp
f010629c:	53                   	push   %ebx
f010629d:	83 ec 10             	sub    $0x10,%esp
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f01062a0:	8b 48 08             	mov    0x8(%eax),%ecx
f01062a3:	8b 58 04             	mov    0x4(%eax),%ebx
f01062a6:	8b 00                	mov    (%eax),%eax
f01062a8:	8b 40 04             	mov    0x4(%eax),%eax
f01062ab:	52                   	push   %edx
f01062ac:	89 da                	mov    %ebx,%edx
f01062ae:	e8 30 ff ff ff       	call   f01061e3 <pci_conf1_set_addr>

static __inline uint32_t
inl(int port)
{
	uint32_t data;
	__asm __volatile("inl %w1,%0" : "=a" (data) : "d" (port));
f01062b3:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f01062b8:	ed                   	in     (%dx),%eax
	return inl(pci_conf1_data_ioport);
}
f01062b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01062bc:	c9                   	leave  
f01062bd:	c3                   	ret    

f01062be <pci_scan_bus>:
		f->irq_line);
}

static int
pci_scan_bus(struct pci_bus *bus)
{
f01062be:	55                   	push   %ebp
f01062bf:	89 e5                	mov    %esp,%ebp
f01062c1:	57                   	push   %edi
f01062c2:	56                   	push   %esi
f01062c3:	53                   	push   %ebx
f01062c4:	81 ec 00 01 00 00    	sub    $0x100,%esp
f01062ca:	89 c3                	mov    %eax,%ebx
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
f01062cc:	6a 48                	push   $0x48
f01062ce:	6a 00                	push   $0x0
f01062d0:	8d 45 a0             	lea    -0x60(%ebp),%eax
f01062d3:	50                   	push   %eax
f01062d4:	e8 09 ef ff ff       	call   f01051e2 <memset>
	df.bus = bus;
f01062d9:	89 5d a0             	mov    %ebx,-0x60(%ebp)

	for (df.dev = 0; df.dev < 32; df.dev++) {
f01062dc:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01062e3:	83 c4 10             	add    $0x10,%esp
}

static int
pci_scan_bus(struct pci_bus *bus)
{
	int totaldev = 0;
f01062e6:	c7 85 00 ff ff ff 00 	movl   $0x0,-0x100(%ebp)
f01062ed:	00 00 00 
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
f01062f0:	ba 0c 00 00 00       	mov    $0xc,%edx
f01062f5:	8d 45 a0             	lea    -0x60(%ebp),%eax
f01062f8:	e8 9c ff ff ff       	call   f0106299 <pci_conf_read>
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
f01062fd:	89 c2                	mov    %eax,%edx
f01062ff:	c1 ea 10             	shr    $0x10,%edx
f0106302:	83 e2 7f             	and    $0x7f,%edx
f0106305:	83 fa 01             	cmp    $0x1,%edx
f0106308:	0f 87 4b 01 00 00    	ja     f0106459 <pci_scan_bus+0x19b>
			continue;

		totaldev++;
f010630e:	83 85 00 ff ff ff 01 	addl   $0x1,-0x100(%ebp)

		struct pci_func f = df;
f0106315:	8d bd 10 ff ff ff    	lea    -0xf0(%ebp),%edi
f010631b:	8d 75 a0             	lea    -0x60(%ebp),%esi
f010631e:	b9 12 00 00 00       	mov    $0x12,%ecx
f0106323:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0106325:	c7 85 18 ff ff ff 00 	movl   $0x0,-0xe8(%ebp)
f010632c:	00 00 00 
f010632f:	25 00 00 80 00       	and    $0x800000,%eax
f0106334:	83 f8 01             	cmp    $0x1,%eax
f0106337:	19 c0                	sbb    %eax,%eax
f0106339:	83 e0 f9             	and    $0xfffffff9,%eax
f010633c:	83 c0 08             	add    $0x8,%eax
f010633f:	89 85 04 ff ff ff    	mov    %eax,-0xfc(%ebp)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
			if (PCI_VENDOR(af.dev_id) == 0xffff)
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f0106345:	8d 9d 58 ff ff ff    	lea    -0xa8(%ebp),%ebx
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f010634b:	e9 f7 00 00 00       	jmp    f0106447 <pci_scan_bus+0x189>
		     f.func++) {
			struct pci_func af = f;
f0106350:	8d bd 58 ff ff ff    	lea    -0xa8(%ebp),%edi
f0106356:	8d b5 10 ff ff ff    	lea    -0xf0(%ebp),%esi
f010635c:	b9 12 00 00 00       	mov    $0x12,%ecx
f0106361:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
f0106363:	ba 00 00 00 00       	mov    $0x0,%edx
f0106368:	8d 85 10 ff ff ff    	lea    -0xf0(%ebp),%eax
f010636e:	e8 26 ff ff ff       	call   f0106299 <pci_conf_read>
f0106373:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
			if (PCI_VENDOR(af.dev_id) == 0xffff)
f0106379:	66 83 f8 ff          	cmp    $0xffff,%ax
f010637d:	0f 84 bd 00 00 00    	je     f0106440 <pci_scan_bus+0x182>
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f0106383:	ba 3c 00 00 00       	mov    $0x3c,%edx
f0106388:	89 d8                	mov    %ebx,%eax
f010638a:	e8 0a ff ff ff       	call   f0106299 <pci_conf_read>
			af.irq_line = PCI_INTERRUPT_LINE(intr);
f010638f:	88 45 9c             	mov    %al,-0x64(%ebp)

			af.dev_class = pci_conf_read(&af, PCI_CLASS_REG);
f0106392:	ba 08 00 00 00       	mov    $0x8,%edx
f0106397:	89 d8                	mov    %ebx,%eax
f0106399:	e8 fb fe ff ff       	call   f0106299 <pci_conf_read>
f010639e:	89 85 68 ff ff ff    	mov    %eax,-0x98(%ebp)

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
f01063a4:	89 c1                	mov    %eax,%ecx
f01063a6:	c1 e9 18             	shr    $0x18,%ecx
};

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
f01063a9:	be f4 88 10 f0       	mov    $0xf01088f4,%esi
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
f01063ae:	83 f9 06             	cmp    $0x6,%ecx
f01063b1:	77 07                	ja     f01063ba <pci_scan_bus+0xfc>
		class = pci_class[PCI_CLASS(f->dev_class)];
f01063b3:	8b 34 8d 68 89 10 f0 	mov    -0xfef7698(,%ecx,4),%esi

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f01063ba:	8b 95 64 ff ff ff    	mov    -0x9c(%ebp),%edx
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
		class = pci_class[PCI_CLASS(f->dev_class)];

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f01063c0:	83 ec 08             	sub    $0x8,%esp
f01063c3:	0f b6 7d 9c          	movzbl -0x64(%ebp),%edi
f01063c7:	57                   	push   %edi
f01063c8:	56                   	push   %esi
f01063c9:	c1 e8 10             	shr    $0x10,%eax
f01063cc:	0f b6 c0             	movzbl %al,%eax
f01063cf:	50                   	push   %eax
f01063d0:	51                   	push   %ecx
f01063d1:	89 d0                	mov    %edx,%eax
f01063d3:	c1 e8 10             	shr    $0x10,%eax
f01063d6:	50                   	push   %eax
f01063d7:	0f b7 d2             	movzwl %dx,%edx
f01063da:	52                   	push   %edx
f01063db:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
f01063e1:	ff b5 5c ff ff ff    	pushl  -0xa4(%ebp)
f01063e7:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
f01063ed:	ff 70 04             	pushl  0x4(%eax)
f01063f0:	68 80 87 10 f0       	push   $0xf0108780
f01063f5:	e8 66 d2 ff ff       	call   f0103660 <cprintf>
static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
f01063fa:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax

static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
f0106400:	83 c4 30             	add    $0x30,%esp
f0106403:	53                   	push   %ebx
f0106404:	68 b4 34 12 f0       	push   $0xf01234b4
f0106409:	89 c2                	mov    %eax,%edx
f010640b:	c1 ea 10             	shr    $0x10,%edx
f010640e:	0f b6 d2             	movzbl %dl,%edx
f0106411:	52                   	push   %edx
f0106412:	c1 e8 18             	shr    $0x18,%eax
f0106415:	50                   	push   %eax
f0106416:	e8 6a fd ff ff       	call   f0106185 <pci_attach_match>
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
f010641b:	83 c4 10             	add    $0x10,%esp
f010641e:	85 c0                	test   %eax,%eax
f0106420:	75 1e                	jne    f0106440 <pci_scan_bus+0x182>
		pci_attach_match(PCI_VENDOR(f->dev_id),
				 PCI_PRODUCT(f->dev_id),
f0106422:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
		pci_attach_match(PCI_VENDOR(f->dev_id),
f0106428:	53                   	push   %ebx
f0106429:	68 9c 34 12 f0       	push   $0xf012349c
f010642e:	89 c2                	mov    %eax,%edx
f0106430:	c1 ea 10             	shr    $0x10,%edx
f0106433:	52                   	push   %edx
f0106434:	0f b7 c0             	movzwl %ax,%eax
f0106437:	50                   	push   %eax
f0106438:	e8 48 fd ff ff       	call   f0106185 <pci_attach_match>
f010643d:	83 c4 10             	add    $0x10,%esp

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
		     f.func++) {
f0106440:	83 85 18 ff ff ff 01 	addl   $0x1,-0xe8(%ebp)
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0106447:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
f010644d:	3b 85 18 ff ff ff    	cmp    -0xe8(%ebp),%eax
f0106453:	0f 87 f7 fe ff ff    	ja     f0106350 <pci_scan_bus+0x92>
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
f0106459:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f010645c:	83 c0 01             	add    $0x1,%eax
f010645f:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0106462:	83 f8 1f             	cmp    $0x1f,%eax
f0106465:	0f 86 85 fe ff ff    	jbe    f01062f0 <pci_scan_bus+0x32>
			pci_attach(&af);
		}
	}

	return totaldev;
}
f010646b:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
f0106471:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106474:	5b                   	pop    %ebx
f0106475:	5e                   	pop    %esi
f0106476:	5f                   	pop    %edi
f0106477:	5d                   	pop    %ebp
f0106478:	c3                   	ret    

f0106479 <pci_bridge_attach>:

static int
pci_bridge_attach(struct pci_func *pcif)
{
f0106479:	55                   	push   %ebp
f010647a:	89 e5                	mov    %esp,%ebp
f010647c:	57                   	push   %edi
f010647d:	56                   	push   %esi
f010647e:	53                   	push   %ebx
f010647f:	83 ec 1c             	sub    $0x1c,%esp
f0106482:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t ioreg  = pci_conf_read(pcif, PCI_BRIDGE_STATIO_REG);
f0106485:	ba 1c 00 00 00       	mov    $0x1c,%edx
f010648a:	89 d8                	mov    %ebx,%eax
f010648c:	e8 08 fe ff ff       	call   f0106299 <pci_conf_read>
f0106491:	89 c7                	mov    %eax,%edi
	uint32_t busreg = pci_conf_read(pcif, PCI_BRIDGE_BUS_REG);
f0106493:	ba 18 00 00 00       	mov    $0x18,%edx
f0106498:	89 d8                	mov    %ebx,%eax
f010649a:	e8 fa fd ff ff       	call   f0106299 <pci_conf_read>

	if (PCI_BRIDGE_IO_32BITS(ioreg)) {
f010649f:	83 e7 0f             	and    $0xf,%edi
f01064a2:	83 ff 01             	cmp    $0x1,%edi
f01064a5:	75 1f                	jne    f01064c6 <pci_bridge_attach+0x4d>
		cprintf("PCI: %02x:%02x.%d: 32-bit bridge IO not supported.\n",
f01064a7:	ff 73 08             	pushl  0x8(%ebx)
f01064aa:	ff 73 04             	pushl  0x4(%ebx)
f01064ad:	8b 03                	mov    (%ebx),%eax
f01064af:	ff 70 04             	pushl  0x4(%eax)
f01064b2:	68 bc 87 10 f0       	push   $0xf01087bc
f01064b7:	e8 a4 d1 ff ff       	call   f0103660 <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func);
		return 0;
f01064bc:	83 c4 10             	add    $0x10,%esp
f01064bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01064c4:	eb 4e                	jmp    f0106514 <pci_bridge_attach+0x9b>
f01064c6:	89 c6                	mov    %eax,%esi
	}

	struct pci_bus nbus;
	memset(&nbus, 0, sizeof(nbus));
f01064c8:	83 ec 04             	sub    $0x4,%esp
f01064cb:	6a 08                	push   $0x8
f01064cd:	6a 00                	push   $0x0
f01064cf:	8d 7d e0             	lea    -0x20(%ebp),%edi
f01064d2:	57                   	push   %edi
f01064d3:	e8 0a ed ff ff       	call   f01051e2 <memset>
	nbus.parent_bridge = pcif;
f01064d8:	89 5d e0             	mov    %ebx,-0x20(%ebp)
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;
f01064db:	89 f0                	mov    %esi,%eax
f01064dd:	0f b6 c4             	movzbl %ah,%eax
f01064e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f01064e3:	83 c4 08             	add    $0x8,%esp
f01064e6:	89 f2                	mov    %esi,%edx
f01064e8:	c1 ea 10             	shr    $0x10,%edx
f01064eb:	0f b6 f2             	movzbl %dl,%esi
f01064ee:	56                   	push   %esi
f01064ef:	50                   	push   %eax
f01064f0:	ff 73 08             	pushl  0x8(%ebx)
f01064f3:	ff 73 04             	pushl  0x4(%ebx)
f01064f6:	8b 03                	mov    (%ebx),%eax
f01064f8:	ff 70 04             	pushl  0x4(%eax)
f01064fb:	68 f0 87 10 f0       	push   $0xf01087f0
f0106500:	e8 5b d1 ff ff       	call   f0103660 <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func,
			nbus.busno,
			(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff);

	pci_scan_bus(&nbus);
f0106505:	83 c4 20             	add    $0x20,%esp
f0106508:	89 f8                	mov    %edi,%eax
f010650a:	e8 af fd ff ff       	call   f01062be <pci_scan_bus>
	return 1;
f010650f:	b8 01 00 00 00       	mov    $0x1,%eax
}
f0106514:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106517:	5b                   	pop    %ebx
f0106518:	5e                   	pop    %esi
f0106519:	5f                   	pop    %edi
f010651a:	5d                   	pop    %ebp
f010651b:	c3                   	ret    

f010651c <pci_conf_write>:
	return inl(pci_conf1_data_ioport);
}

static void
pci_conf_write(struct pci_func *f, uint32_t off, uint32_t v)
{
f010651c:	55                   	push   %ebp
f010651d:	89 e5                	mov    %esp,%ebp
f010651f:	56                   	push   %esi
f0106520:	53                   	push   %ebx
f0106521:	89 cb                	mov    %ecx,%ebx
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f0106523:	8b 48 08             	mov    0x8(%eax),%ecx
f0106526:	8b 70 04             	mov    0x4(%eax),%esi
f0106529:	8b 00                	mov    (%eax),%eax
f010652b:	8b 40 04             	mov    0x4(%eax),%eax
f010652e:	83 ec 0c             	sub    $0xc,%esp
f0106531:	52                   	push   %edx
f0106532:	89 f2                	mov    %esi,%edx
f0106534:	e8 aa fc ff ff       	call   f01061e3 <pci_conf1_set_addr>
}

static __inline void
outl(int port, uint32_t data)
{
	__asm __volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0106539:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f010653e:	89 d8                	mov    %ebx,%eax
f0106540:	ef                   	out    %eax,(%dx)
	outl(pci_conf1_data_ioport, v);
}
f0106541:	83 c4 10             	add    $0x10,%esp
f0106544:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106547:	5b                   	pop    %ebx
f0106548:	5e                   	pop    %esi
f0106549:	5d                   	pop    %ebp
f010654a:	c3                   	ret    

f010654b <pci_func_enable>:

// External PCI subsystem interface

void
pci_func_enable(struct pci_func *f)
{
f010654b:	55                   	push   %ebp
f010654c:	89 e5                	mov    %esp,%ebp
f010654e:	57                   	push   %edi
f010654f:	56                   	push   %esi
f0106550:	53                   	push   %ebx
f0106551:	83 ec 1c             	sub    $0x1c,%esp
f0106554:	8b 7d 08             	mov    0x8(%ebp),%edi
	pci_conf_write(f, PCI_COMMAND_STATUS_REG,
f0106557:	b9 07 00 00 00       	mov    $0x7,%ecx
f010655c:	ba 04 00 00 00       	mov    $0x4,%edx
f0106561:	89 f8                	mov    %edi,%eax
f0106563:	e8 b4 ff ff ff       	call   f010651c <pci_conf_write>
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f0106568:	be 10 00 00 00       	mov    $0x10,%esi
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);
f010656d:	89 f2                	mov    %esi,%edx
f010656f:	89 f8                	mov    %edi,%eax
f0106571:	e8 23 fd ff ff       	call   f0106299 <pci_conf_read>
f0106576:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		bar_width = 4;
		pci_conf_write(f, bar, 0xffffffff);
f0106579:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f010657e:	89 f2                	mov    %esi,%edx
f0106580:	89 f8                	mov    %edi,%eax
f0106582:	e8 95 ff ff ff       	call   f010651c <pci_conf_write>
		uint32_t rv = pci_conf_read(f, bar);
f0106587:	89 f2                	mov    %esi,%edx
f0106589:	89 f8                	mov    %edi,%eax
f010658b:	e8 09 fd ff ff       	call   f0106299 <pci_conf_read>
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f0106590:	bb 04 00 00 00       	mov    $0x4,%ebx
		pci_conf_write(f, bar, 0xffffffff);
		uint32_t rv = pci_conf_read(f, bar);

		if (rv == 0)
f0106595:	85 c0                	test   %eax,%eax
f0106597:	0f 84 a6 00 00 00    	je     f0106643 <pci_func_enable+0xf8>
			continue;

		int regnum = PCI_MAPREG_NUM(bar);
f010659d:	8d 56 f0             	lea    -0x10(%esi),%edx
f01065a0:	c1 ea 02             	shr    $0x2,%edx
f01065a3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		uint32_t base, size;
		if (PCI_MAPREG_TYPE(rv) == PCI_MAPREG_TYPE_MEM) {
f01065a6:	a8 01                	test   $0x1,%al
f01065a8:	75 2c                	jne    f01065d6 <pci_func_enable+0x8b>
			if (PCI_MAPREG_MEM_TYPE(rv) == PCI_MAPREG_MEM_TYPE_64BIT)
f01065aa:	89 c2                	mov    %eax,%edx
f01065ac:	83 e2 06             	and    $0x6,%edx
				bar_width = 8;
f01065af:	83 fa 04             	cmp    $0x4,%edx
f01065b2:	0f 94 c3             	sete   %bl
f01065b5:	0f b6 db             	movzbl %bl,%ebx
f01065b8:	8d 1c 9d 04 00 00 00 	lea    0x4(,%ebx,4),%ebx

			size = PCI_MAPREG_MEM_SIZE(rv);
f01065bf:	83 e0 f0             	and    $0xfffffff0,%eax
f01065c2:	89 c2                	mov    %eax,%edx
f01065c4:	f7 da                	neg    %edx
f01065c6:	21 c2                	and    %eax,%edx
f01065c8:	89 55 d8             	mov    %edx,-0x28(%ebp)
			base = PCI_MAPREG_MEM_ADDR(oldv);
f01065cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01065ce:	83 e0 f0             	and    $0xfffffff0,%eax
f01065d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01065d4:	eb 1a                	jmp    f01065f0 <pci_func_enable+0xa5>
			if (pci_show_addrs)
				cprintf("  mem region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		} else {
			size = PCI_MAPREG_IO_SIZE(rv);
f01065d6:	83 e0 fc             	and    $0xfffffffc,%eax
f01065d9:	89 c2                	mov    %eax,%edx
f01065db:	f7 da                	neg    %edx
f01065dd:	21 c2                	and    %eax,%edx
f01065df:	89 55 d8             	mov    %edx,-0x28(%ebp)
			base = PCI_MAPREG_IO_ADDR(oldv);
f01065e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01065e5:	83 e0 fc             	and    $0xfffffffc,%eax
f01065e8:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f01065eb:	bb 04 00 00 00       	mov    $0x4,%ebx
			if (pci_show_addrs)
				cprintf("  io region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		}

		pci_conf_write(f, bar, oldv);
f01065f0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01065f3:	89 f2                	mov    %esi,%edx
f01065f5:	89 f8                	mov    %edi,%eax
f01065f7:	e8 20 ff ff ff       	call   f010651c <pci_conf_write>
f01065fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01065ff:	8d 04 87             	lea    (%edi,%eax,4),%eax
		f->reg_base[regnum] = base;
f0106602:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106605:	89 50 14             	mov    %edx,0x14(%eax)
		f->reg_size[regnum] = size;
f0106608:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f010660b:	89 48 2c             	mov    %ecx,0x2c(%eax)

		if (size && !base)
f010660e:	85 c9                	test   %ecx,%ecx
f0106610:	74 31                	je     f0106643 <pci_func_enable+0xf8>
f0106612:	85 d2                	test   %edx,%edx
f0106614:	75 2d                	jne    f0106643 <pci_func_enable+0xf8>
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
				"may be misconfigured: "
				"region %d: base 0x%x, size %d\n",
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f0106616:	8b 47 0c             	mov    0xc(%edi),%eax
		pci_conf_write(f, bar, oldv);
		f->reg_base[regnum] = base;
		f->reg_size[regnum] = size;

		if (size && !base)
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
f0106619:	83 ec 0c             	sub    $0xc,%esp
f010661c:	51                   	push   %ecx
f010661d:	52                   	push   %edx
f010661e:	ff 75 e0             	pushl  -0x20(%ebp)
f0106621:	89 c2                	mov    %eax,%edx
f0106623:	c1 ea 10             	shr    $0x10,%edx
f0106626:	52                   	push   %edx
f0106627:	0f b7 c0             	movzwl %ax,%eax
f010662a:	50                   	push   %eax
f010662b:	ff 77 08             	pushl  0x8(%edi)
f010662e:	ff 77 04             	pushl  0x4(%edi)
f0106631:	8b 07                	mov    (%edi),%eax
f0106633:	ff 70 04             	pushl  0x4(%eax)
f0106636:	68 20 88 10 f0       	push   $0xf0108820
f010663b:	e8 20 d0 ff ff       	call   f0103660 <cprintf>
f0106640:	83 c4 30             	add    $0x30,%esp
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
f0106643:	01 de                	add    %ebx,%esi
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f0106645:	83 fe 27             	cmp    $0x27,%esi
f0106648:	0f 86 1f ff ff ff    	jbe    f010656d <pci_func_enable+0x22>
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
f010664e:	8b 47 0c             	mov    0xc(%edi),%eax
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
f0106651:	83 ec 08             	sub    $0x8,%esp
f0106654:	89 c2                	mov    %eax,%edx
f0106656:	c1 ea 10             	shr    $0x10,%edx
f0106659:	52                   	push   %edx
f010665a:	0f b7 c0             	movzwl %ax,%eax
f010665d:	50                   	push   %eax
f010665e:	ff 77 08             	pushl  0x8(%edi)
f0106661:	ff 77 04             	pushl  0x4(%edi)
f0106664:	8b 07                	mov    (%edi),%eax
f0106666:	ff 70 04             	pushl  0x4(%eax)
f0106669:	68 7c 88 10 f0       	push   $0xf010887c
f010666e:	e8 ed cf ff ff       	call   f0103660 <cprintf>
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
}
f0106673:	83 c4 20             	add    $0x20,%esp
f0106676:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106679:	5b                   	pop    %ebx
f010667a:	5e                   	pop    %esi
f010667b:	5f                   	pop    %edi
f010667c:	5d                   	pop    %ebp
f010667d:	c3                   	ret    

f010667e <pci_init>:

int
pci_init(void)
{
f010667e:	55                   	push   %ebp
f010667f:	89 e5                	mov    %esp,%ebp
f0106681:	83 ec 0c             	sub    $0xc,%esp
	static struct pci_bus root_bus;
	memset(&root_bus, 0, sizeof(root_bus));
f0106684:	6a 08                	push   $0x8
f0106686:	6a 00                	push   $0x0
f0106688:	68 84 1e 2a f0       	push   $0xf02a1e84
f010668d:	e8 50 eb ff ff       	call   f01051e2 <memset>

	return pci_scan_bus(&root_bus);
f0106692:	b8 84 1e 2a f0       	mov    $0xf02a1e84,%eax
f0106697:	e8 22 fc ff ff       	call   f01062be <pci_scan_bus>
}
f010669c:	c9                   	leave  
f010669d:	c3                   	ret    

f010669e <time_init>:

static unsigned int ticks;

void
time_init(void)
{
f010669e:	55                   	push   %ebp
f010669f:	89 e5                	mov    %esp,%ebp
	ticks = 0;
f01066a1:	c7 05 8c 1e 2a f0 00 	movl   $0x0,0xf02a1e8c
f01066a8:	00 00 00 
}
f01066ab:	5d                   	pop    %ebp
f01066ac:	c3                   	ret    

f01066ad <time_tick>:
// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
	ticks++;
f01066ad:	a1 8c 1e 2a f0       	mov    0xf02a1e8c,%eax
f01066b2:	83 c0 01             	add    $0x1,%eax
f01066b5:	a3 8c 1e 2a f0       	mov    %eax,0xf02a1e8c
	if (ticks * 10 < ticks)
f01066ba:	8d 14 80             	lea    (%eax,%eax,4),%edx
f01066bd:	01 d2                	add    %edx,%edx
f01066bf:	39 d0                	cmp    %edx,%eax
f01066c1:	76 17                	jbe    f01066da <time_tick+0x2d>

// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
f01066c3:	55                   	push   %ebp
f01066c4:	89 e5                	mov    %esp,%ebp
f01066c6:	83 ec 0c             	sub    $0xc,%esp
	ticks++;
	if (ticks * 10 < ticks)
		panic("time_tick: time overflowed");
f01066c9:	68 84 89 10 f0       	push   $0xf0108984
f01066ce:	6a 13                	push   $0x13
f01066d0:	68 9f 89 10 f0       	push   $0xf010899f
f01066d5:	e8 66 99 ff ff       	call   f0100040 <_panic>
f01066da:	f3 c3                	repz ret 

f01066dc <time_msec>:
}

unsigned int
time_msec(void)
{
f01066dc:	55                   	push   %ebp
f01066dd:	89 e5                	mov    %esp,%ebp
	return ticks * 10;
f01066df:	a1 8c 1e 2a f0       	mov    0xf02a1e8c,%eax
f01066e4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01066e7:	01 c0                	add    %eax,%eax
}
f01066e9:	5d                   	pop    %ebp
f01066ea:	c3                   	ret    
f01066eb:	66 90                	xchg   %ax,%ax
f01066ed:	66 90                	xchg   %ax,%ax
f01066ef:	90                   	nop

f01066f0 <__udivdi3>:
f01066f0:	55                   	push   %ebp
f01066f1:	57                   	push   %edi
f01066f2:	56                   	push   %esi
f01066f3:	53                   	push   %ebx
f01066f4:	83 ec 1c             	sub    $0x1c,%esp
f01066f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01066fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01066ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0106703:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106707:	85 f6                	test   %esi,%esi
f0106709:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010670d:	89 ca                	mov    %ecx,%edx
f010670f:	89 f8                	mov    %edi,%eax
f0106711:	75 3d                	jne    f0106750 <__udivdi3+0x60>
f0106713:	39 cf                	cmp    %ecx,%edi
f0106715:	0f 87 c5 00 00 00    	ja     f01067e0 <__udivdi3+0xf0>
f010671b:	85 ff                	test   %edi,%edi
f010671d:	89 fd                	mov    %edi,%ebp
f010671f:	75 0b                	jne    f010672c <__udivdi3+0x3c>
f0106721:	b8 01 00 00 00       	mov    $0x1,%eax
f0106726:	31 d2                	xor    %edx,%edx
f0106728:	f7 f7                	div    %edi
f010672a:	89 c5                	mov    %eax,%ebp
f010672c:	89 c8                	mov    %ecx,%eax
f010672e:	31 d2                	xor    %edx,%edx
f0106730:	f7 f5                	div    %ebp
f0106732:	89 c1                	mov    %eax,%ecx
f0106734:	89 d8                	mov    %ebx,%eax
f0106736:	89 cf                	mov    %ecx,%edi
f0106738:	f7 f5                	div    %ebp
f010673a:	89 c3                	mov    %eax,%ebx
f010673c:	89 d8                	mov    %ebx,%eax
f010673e:	89 fa                	mov    %edi,%edx
f0106740:	83 c4 1c             	add    $0x1c,%esp
f0106743:	5b                   	pop    %ebx
f0106744:	5e                   	pop    %esi
f0106745:	5f                   	pop    %edi
f0106746:	5d                   	pop    %ebp
f0106747:	c3                   	ret    
f0106748:	90                   	nop
f0106749:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106750:	39 ce                	cmp    %ecx,%esi
f0106752:	77 74                	ja     f01067c8 <__udivdi3+0xd8>
f0106754:	0f bd fe             	bsr    %esi,%edi
f0106757:	83 f7 1f             	xor    $0x1f,%edi
f010675a:	0f 84 98 00 00 00    	je     f01067f8 <__udivdi3+0x108>
f0106760:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106765:	89 f9                	mov    %edi,%ecx
f0106767:	89 c5                	mov    %eax,%ebp
f0106769:	29 fb                	sub    %edi,%ebx
f010676b:	d3 e6                	shl    %cl,%esi
f010676d:	89 d9                	mov    %ebx,%ecx
f010676f:	d3 ed                	shr    %cl,%ebp
f0106771:	89 f9                	mov    %edi,%ecx
f0106773:	d3 e0                	shl    %cl,%eax
f0106775:	09 ee                	or     %ebp,%esi
f0106777:	89 d9                	mov    %ebx,%ecx
f0106779:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010677d:	89 d5                	mov    %edx,%ebp
f010677f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106783:	d3 ed                	shr    %cl,%ebp
f0106785:	89 f9                	mov    %edi,%ecx
f0106787:	d3 e2                	shl    %cl,%edx
f0106789:	89 d9                	mov    %ebx,%ecx
f010678b:	d3 e8                	shr    %cl,%eax
f010678d:	09 c2                	or     %eax,%edx
f010678f:	89 d0                	mov    %edx,%eax
f0106791:	89 ea                	mov    %ebp,%edx
f0106793:	f7 f6                	div    %esi
f0106795:	89 d5                	mov    %edx,%ebp
f0106797:	89 c3                	mov    %eax,%ebx
f0106799:	f7 64 24 0c          	mull   0xc(%esp)
f010679d:	39 d5                	cmp    %edx,%ebp
f010679f:	72 10                	jb     f01067b1 <__udivdi3+0xc1>
f01067a1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01067a5:	89 f9                	mov    %edi,%ecx
f01067a7:	d3 e6                	shl    %cl,%esi
f01067a9:	39 c6                	cmp    %eax,%esi
f01067ab:	73 07                	jae    f01067b4 <__udivdi3+0xc4>
f01067ad:	39 d5                	cmp    %edx,%ebp
f01067af:	75 03                	jne    f01067b4 <__udivdi3+0xc4>
f01067b1:	83 eb 01             	sub    $0x1,%ebx
f01067b4:	31 ff                	xor    %edi,%edi
f01067b6:	89 d8                	mov    %ebx,%eax
f01067b8:	89 fa                	mov    %edi,%edx
f01067ba:	83 c4 1c             	add    $0x1c,%esp
f01067bd:	5b                   	pop    %ebx
f01067be:	5e                   	pop    %esi
f01067bf:	5f                   	pop    %edi
f01067c0:	5d                   	pop    %ebp
f01067c1:	c3                   	ret    
f01067c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01067c8:	31 ff                	xor    %edi,%edi
f01067ca:	31 db                	xor    %ebx,%ebx
f01067cc:	89 d8                	mov    %ebx,%eax
f01067ce:	89 fa                	mov    %edi,%edx
f01067d0:	83 c4 1c             	add    $0x1c,%esp
f01067d3:	5b                   	pop    %ebx
f01067d4:	5e                   	pop    %esi
f01067d5:	5f                   	pop    %edi
f01067d6:	5d                   	pop    %ebp
f01067d7:	c3                   	ret    
f01067d8:	90                   	nop
f01067d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01067e0:	89 d8                	mov    %ebx,%eax
f01067e2:	f7 f7                	div    %edi
f01067e4:	31 ff                	xor    %edi,%edi
f01067e6:	89 c3                	mov    %eax,%ebx
f01067e8:	89 d8                	mov    %ebx,%eax
f01067ea:	89 fa                	mov    %edi,%edx
f01067ec:	83 c4 1c             	add    $0x1c,%esp
f01067ef:	5b                   	pop    %ebx
f01067f0:	5e                   	pop    %esi
f01067f1:	5f                   	pop    %edi
f01067f2:	5d                   	pop    %ebp
f01067f3:	c3                   	ret    
f01067f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01067f8:	39 ce                	cmp    %ecx,%esi
f01067fa:	72 0c                	jb     f0106808 <__udivdi3+0x118>
f01067fc:	31 db                	xor    %ebx,%ebx
f01067fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106802:	0f 87 34 ff ff ff    	ja     f010673c <__udivdi3+0x4c>
f0106808:	bb 01 00 00 00       	mov    $0x1,%ebx
f010680d:	e9 2a ff ff ff       	jmp    f010673c <__udivdi3+0x4c>
f0106812:	66 90                	xchg   %ax,%ax
f0106814:	66 90                	xchg   %ax,%ax
f0106816:	66 90                	xchg   %ax,%ax
f0106818:	66 90                	xchg   %ax,%ax
f010681a:	66 90                	xchg   %ax,%ax
f010681c:	66 90                	xchg   %ax,%ax
f010681e:	66 90                	xchg   %ax,%ax

f0106820 <__umoddi3>:
f0106820:	55                   	push   %ebp
f0106821:	57                   	push   %edi
f0106822:	56                   	push   %esi
f0106823:	53                   	push   %ebx
f0106824:	83 ec 1c             	sub    $0x1c,%esp
f0106827:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010682b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010682f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106833:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106837:	85 d2                	test   %edx,%edx
f0106839:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010683d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106841:	89 f3                	mov    %esi,%ebx
f0106843:	89 3c 24             	mov    %edi,(%esp)
f0106846:	89 74 24 04          	mov    %esi,0x4(%esp)
f010684a:	75 1c                	jne    f0106868 <__umoddi3+0x48>
f010684c:	39 f7                	cmp    %esi,%edi
f010684e:	76 50                	jbe    f01068a0 <__umoddi3+0x80>
f0106850:	89 c8                	mov    %ecx,%eax
f0106852:	89 f2                	mov    %esi,%edx
f0106854:	f7 f7                	div    %edi
f0106856:	89 d0                	mov    %edx,%eax
f0106858:	31 d2                	xor    %edx,%edx
f010685a:	83 c4 1c             	add    $0x1c,%esp
f010685d:	5b                   	pop    %ebx
f010685e:	5e                   	pop    %esi
f010685f:	5f                   	pop    %edi
f0106860:	5d                   	pop    %ebp
f0106861:	c3                   	ret    
f0106862:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106868:	39 f2                	cmp    %esi,%edx
f010686a:	89 d0                	mov    %edx,%eax
f010686c:	77 52                	ja     f01068c0 <__umoddi3+0xa0>
f010686e:	0f bd ea             	bsr    %edx,%ebp
f0106871:	83 f5 1f             	xor    $0x1f,%ebp
f0106874:	75 5a                	jne    f01068d0 <__umoddi3+0xb0>
f0106876:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010687a:	0f 82 e0 00 00 00    	jb     f0106960 <__umoddi3+0x140>
f0106880:	39 0c 24             	cmp    %ecx,(%esp)
f0106883:	0f 86 d7 00 00 00    	jbe    f0106960 <__umoddi3+0x140>
f0106889:	8b 44 24 08          	mov    0x8(%esp),%eax
f010688d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106891:	83 c4 1c             	add    $0x1c,%esp
f0106894:	5b                   	pop    %ebx
f0106895:	5e                   	pop    %esi
f0106896:	5f                   	pop    %edi
f0106897:	5d                   	pop    %ebp
f0106898:	c3                   	ret    
f0106899:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01068a0:	85 ff                	test   %edi,%edi
f01068a2:	89 fd                	mov    %edi,%ebp
f01068a4:	75 0b                	jne    f01068b1 <__umoddi3+0x91>
f01068a6:	b8 01 00 00 00       	mov    $0x1,%eax
f01068ab:	31 d2                	xor    %edx,%edx
f01068ad:	f7 f7                	div    %edi
f01068af:	89 c5                	mov    %eax,%ebp
f01068b1:	89 f0                	mov    %esi,%eax
f01068b3:	31 d2                	xor    %edx,%edx
f01068b5:	f7 f5                	div    %ebp
f01068b7:	89 c8                	mov    %ecx,%eax
f01068b9:	f7 f5                	div    %ebp
f01068bb:	89 d0                	mov    %edx,%eax
f01068bd:	eb 99                	jmp    f0106858 <__umoddi3+0x38>
f01068bf:	90                   	nop
f01068c0:	89 c8                	mov    %ecx,%eax
f01068c2:	89 f2                	mov    %esi,%edx
f01068c4:	83 c4 1c             	add    $0x1c,%esp
f01068c7:	5b                   	pop    %ebx
f01068c8:	5e                   	pop    %esi
f01068c9:	5f                   	pop    %edi
f01068ca:	5d                   	pop    %ebp
f01068cb:	c3                   	ret    
f01068cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01068d0:	8b 34 24             	mov    (%esp),%esi
f01068d3:	bf 20 00 00 00       	mov    $0x20,%edi
f01068d8:	89 e9                	mov    %ebp,%ecx
f01068da:	29 ef                	sub    %ebp,%edi
f01068dc:	d3 e0                	shl    %cl,%eax
f01068de:	89 f9                	mov    %edi,%ecx
f01068e0:	89 f2                	mov    %esi,%edx
f01068e2:	d3 ea                	shr    %cl,%edx
f01068e4:	89 e9                	mov    %ebp,%ecx
f01068e6:	09 c2                	or     %eax,%edx
f01068e8:	89 d8                	mov    %ebx,%eax
f01068ea:	89 14 24             	mov    %edx,(%esp)
f01068ed:	89 f2                	mov    %esi,%edx
f01068ef:	d3 e2                	shl    %cl,%edx
f01068f1:	89 f9                	mov    %edi,%ecx
f01068f3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01068f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01068fb:	d3 e8                	shr    %cl,%eax
f01068fd:	89 e9                	mov    %ebp,%ecx
f01068ff:	89 c6                	mov    %eax,%esi
f0106901:	d3 e3                	shl    %cl,%ebx
f0106903:	89 f9                	mov    %edi,%ecx
f0106905:	89 d0                	mov    %edx,%eax
f0106907:	d3 e8                	shr    %cl,%eax
f0106909:	89 e9                	mov    %ebp,%ecx
f010690b:	09 d8                	or     %ebx,%eax
f010690d:	89 d3                	mov    %edx,%ebx
f010690f:	89 f2                	mov    %esi,%edx
f0106911:	f7 34 24             	divl   (%esp)
f0106914:	89 d6                	mov    %edx,%esi
f0106916:	d3 e3                	shl    %cl,%ebx
f0106918:	f7 64 24 04          	mull   0x4(%esp)
f010691c:	39 d6                	cmp    %edx,%esi
f010691e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106922:	89 d1                	mov    %edx,%ecx
f0106924:	89 c3                	mov    %eax,%ebx
f0106926:	72 08                	jb     f0106930 <__umoddi3+0x110>
f0106928:	75 11                	jne    f010693b <__umoddi3+0x11b>
f010692a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010692e:	73 0b                	jae    f010693b <__umoddi3+0x11b>
f0106930:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106934:	1b 14 24             	sbb    (%esp),%edx
f0106937:	89 d1                	mov    %edx,%ecx
f0106939:	89 c3                	mov    %eax,%ebx
f010693b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010693f:	29 da                	sub    %ebx,%edx
f0106941:	19 ce                	sbb    %ecx,%esi
f0106943:	89 f9                	mov    %edi,%ecx
f0106945:	89 f0                	mov    %esi,%eax
f0106947:	d3 e0                	shl    %cl,%eax
f0106949:	89 e9                	mov    %ebp,%ecx
f010694b:	d3 ea                	shr    %cl,%edx
f010694d:	89 e9                	mov    %ebp,%ecx
f010694f:	d3 ee                	shr    %cl,%esi
f0106951:	09 d0                	or     %edx,%eax
f0106953:	89 f2                	mov    %esi,%edx
f0106955:	83 c4 1c             	add    $0x1c,%esp
f0106958:	5b                   	pop    %ebx
f0106959:	5e                   	pop    %esi
f010695a:	5f                   	pop    %edi
f010695b:	5d                   	pop    %ebp
f010695c:	c3                   	ret    
f010695d:	8d 76 00             	lea    0x0(%esi),%esi
f0106960:	29 f9                	sub    %edi,%ecx
f0106962:	19 d6                	sbb    %edx,%esi
f0106964:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106968:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010696c:	e9 18 ff ff ff       	jmp    f0106889 <__umoddi3+0x69>
