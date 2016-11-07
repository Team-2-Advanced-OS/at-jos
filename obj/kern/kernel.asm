
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
f0100015:	b8 00 d0 11 00       	mov    $0x11d000,%eax
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
f0100034:	bc 00 d0 11 f0       	mov    $0xf011d000,%esp

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
f0100048:	83 3d 00 af 22 f0 00 	cmpl   $0x0,0xf022af00
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 00 af 22 f0    	mov    %esi,0xf022af00

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 4d 56 00 00       	call   f01056ae <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 40 5d 10 f0       	push   $0xf0105d40
f010006d:	e8 16 36 00 00       	call   f0103688 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 e6 35 00 00       	call   f0103662 <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 63 66 10 f0 	movl   $0xf0106663,(%esp)
f0100083:	e8 00 36 00 00       	call   f0103688 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 c9 08 00 00       	call   f010095e <monitor>
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
f01000a1:	b8 08 c0 26 f0       	mov    $0xf026c008,%eax
f01000a6:	2d d8 95 22 f0       	sub    $0xf02295d8,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 d8 95 22 f0       	push   $0xf02295d8
f01000b3:	e8 d3 4f 00 00       	call   f010508b <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 74 05 00 00       	call   f0100631 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 ac 5d 10 f0       	push   $0xf0105dac
f01000ca:	e8 b9 35 00 00       	call   f0103688 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 bd 11 00 00       	call   f0101291 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 27 2e 00 00       	call   f0102f00 <env_init>
	trap_init();
f01000d9:	e8 1b 36 00 00       	call   f01036f9 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 c1 52 00 00       	call   f01053a4 <mp_init>
	lapic_init();
f01000e3:	e8 e1 55 00 00       	call   f01056c9 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 c2 34 00 00       	call   f01035af <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 c0 f3 11 f0 	movl   $0xf011f3c0,(%esp)
f01000f4:	e8 23 58 00 00       	call   f010591c <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f9:	83 c4 10             	add    $0x10,%esp
f01000fc:	83 3d 08 af 22 f0 07 	cmpl   $0x7,0xf022af08
f0100103:	77 16                	ja     f010011b <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100105:	68 00 70 00 00       	push   $0x7000
f010010a:	68 64 5d 10 f0       	push   $0xf0105d64
f010010f:	6a 57                	push   $0x57
f0100111:	68 c7 5d 10 f0       	push   $0xf0105dc7
f0100116:	e8 25 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011b:	83 ec 04             	sub    $0x4,%esp
f010011e:	b8 0a 53 10 f0       	mov    $0xf010530a,%eax
f0100123:	2d 90 52 10 f0       	sub    $0xf0105290,%eax
f0100128:	50                   	push   %eax
f0100129:	68 90 52 10 f0       	push   $0xf0105290
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 a0 4f 00 00       	call   f01050d8 <memmove>
f0100138:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010013b:	bb 20 b0 22 f0       	mov    $0xf022b020,%ebx
f0100140:	eb 4d                	jmp    f010018f <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100142:	e8 67 55 00 00       	call   f01056ae <cpunum>
f0100147:	6b c0 74             	imul   $0x74,%eax,%eax
f010014a:	05 20 b0 22 f0       	add    $0xf022b020,%eax
f010014f:	39 c3                	cmp    %eax,%ebx
f0100151:	74 39                	je     f010018c <i386_init+0xf2>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100153:	89 d8                	mov    %ebx,%eax
f0100155:	2d 20 b0 22 f0       	sub    $0xf022b020,%eax
f010015a:	c1 f8 02             	sar    $0x2,%eax
f010015d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100163:	c1 e0 0f             	shl    $0xf,%eax
f0100166:	05 00 40 23 f0       	add    $0xf0234000,%eax
f010016b:	a3 04 af 22 f0       	mov    %eax,0xf022af04
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100170:	83 ec 08             	sub    $0x8,%esp
f0100173:	68 00 70 00 00       	push   $0x7000
f0100178:	0f b6 03             	movzbl (%ebx),%eax
f010017b:	50                   	push   %eax
f010017c:	e8 96 56 00 00       	call   f0105817 <lapic_startap>
f0100181:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED);
f0100184:	8b 43 04             	mov    0x4(%ebx),%eax
f0100187:	83 f8 01             	cmp    $0x1,%eax
f010018a:	75 f8                	jne    f0100184 <i386_init+0xea>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010018c:	83 c3 74             	add    $0x74,%ebx
f010018f:	6b 05 c4 b3 22 f0 74 	imul   $0x74,0xf022b3c4,%eax
f0100196:	05 20 b0 22 f0       	add    $0xf022b020,%eax
f010019b:	39 c3                	cmp    %eax,%ebx
f010019d:	72 a3                	jb     f0100142 <i386_init+0xa8>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010019f:	83 ec 08             	sub    $0x8,%esp
f01001a2:	6a 00                	push   $0x0
f01001a4:	68 08 fd 19 f0       	push   $0xf019fd08
f01001a9:	e8 42 2f 00 00       	call   f01030f0 <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
	ENV_CREATE(user_yield, ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01001ae:	e8 3a 3e 00 00       	call   f0103fed <sched_yield>

f01001b3 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001b3:	55                   	push   %ebp
f01001b4:	89 e5                	mov    %esp,%ebp
f01001b6:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001b9:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001be:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001c3:	77 12                	ja     f01001d7 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001c5:	50                   	push   %eax
f01001c6:	68 88 5d 10 f0       	push   $0xf0105d88
f01001cb:	6a 6e                	push   $0x6e
f01001cd:	68 c7 5d 10 f0       	push   $0xf0105dc7
f01001d2:	e8 69 fe ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01001d7:	05 00 00 00 10       	add    $0x10000000,%eax
f01001dc:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001df:	e8 ca 54 00 00       	call   f01056ae <cpunum>
f01001e4:	83 ec 08             	sub    $0x8,%esp
f01001e7:	50                   	push   %eax
f01001e8:	68 d3 5d 10 f0       	push   $0xf0105dd3
f01001ed:	e8 96 34 00 00       	call   f0103688 <cprintf>

	lapic_init();
f01001f2:	e8 d2 54 00 00       	call   f01056c9 <lapic_init>
	env_init_percpu();
f01001f7:	e8 d4 2c 00 00       	call   f0102ed0 <env_init_percpu>
	trap_init_percpu();
f01001fc:	e8 9b 34 00 00       	call   f010369c <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100201:	e8 a8 54 00 00       	call   f01056ae <cpunum>
f0100206:	6b d0 74             	imul   $0x74,%eax,%edx
f0100209:	81 c2 20 b0 22 f0    	add    $0xf022b020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010020f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100214:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100218:	c7 04 24 c0 f3 11 f0 	movl   $0xf011f3c0,(%esp)
f010021f:	e8 f8 56 00 00       	call   f010591c <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
lock_kernel();
sched_yield();
f0100224:	e8 c4 3d 00 00       	call   f0103fed <sched_yield>

f0100229 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100229:	55                   	push   %ebp
f010022a:	89 e5                	mov    %esp,%ebp
f010022c:	53                   	push   %ebx
f010022d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100230:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100233:	ff 75 0c             	pushl  0xc(%ebp)
f0100236:	ff 75 08             	pushl  0x8(%ebp)
f0100239:	68 e9 5d 10 f0       	push   $0xf0105de9
f010023e:	e8 45 34 00 00       	call   f0103688 <cprintf>
	vcprintf(fmt, ap);
f0100243:	83 c4 08             	add    $0x8,%esp
f0100246:	53                   	push   %ebx
f0100247:	ff 75 10             	pushl  0x10(%ebp)
f010024a:	e8 13 34 00 00       	call   f0103662 <vcprintf>
	cprintf("\n");
f010024f:	c7 04 24 63 66 10 f0 	movl   $0xf0106663,(%esp)
f0100256:	e8 2d 34 00 00       	call   f0103688 <cprintf>
	va_end(ap);
}
f010025b:	83 c4 10             	add    $0x10,%esp
f010025e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100261:	c9                   	leave  
f0100262:	c3                   	ret    

f0100263 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100263:	55                   	push   %ebp
f0100264:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100266:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010026b:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010026c:	a8 01                	test   $0x1,%al
f010026e:	74 0b                	je     f010027b <serial_proc_data+0x18>
f0100270:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100275:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100276:	0f b6 c0             	movzbl %al,%eax
f0100279:	eb 05                	jmp    f0100280 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010027b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100280:	5d                   	pop    %ebp
f0100281:	c3                   	ret    

f0100282 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100282:	55                   	push   %ebp
f0100283:	89 e5                	mov    %esp,%ebp
f0100285:	53                   	push   %ebx
f0100286:	83 ec 04             	sub    $0x4,%esp
f0100289:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010028b:	eb 2b                	jmp    f01002b8 <cons_intr+0x36>
		if (c == 0)
f010028d:	85 c0                	test   %eax,%eax
f010028f:	74 27                	je     f01002b8 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100291:	8b 0d 24 a2 22 f0    	mov    0xf022a224,%ecx
f0100297:	8d 51 01             	lea    0x1(%ecx),%edx
f010029a:	89 15 24 a2 22 f0    	mov    %edx,0xf022a224
f01002a0:	88 81 20 a0 22 f0    	mov    %al,-0xfdd5fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002a6:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002ac:	75 0a                	jne    f01002b8 <cons_intr+0x36>
			cons.wpos = 0;
f01002ae:	c7 05 24 a2 22 f0 00 	movl   $0x0,0xf022a224
f01002b5:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002b8:	ff d3                	call   *%ebx
f01002ba:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002bd:	75 ce                	jne    f010028d <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002bf:	83 c4 04             	add    $0x4,%esp
f01002c2:	5b                   	pop    %ebx
f01002c3:	5d                   	pop    %ebp
f01002c4:	c3                   	ret    

f01002c5 <kbd_proc_data>:
f01002c5:	ba 64 00 00 00       	mov    $0x64,%edx
f01002ca:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01002cb:	a8 01                	test   $0x1,%al
f01002cd:	0f 84 f0 00 00 00    	je     f01003c3 <kbd_proc_data+0xfe>
f01002d3:	ba 60 00 00 00       	mov    $0x60,%edx
f01002d8:	ec                   	in     (%dx),%al
f01002d9:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002db:	3c e0                	cmp    $0xe0,%al
f01002dd:	75 0d                	jne    f01002ec <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01002df:	83 0d 00 a0 22 f0 40 	orl    $0x40,0xf022a000
		return 0;
f01002e6:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002eb:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01002ec:	55                   	push   %ebp
f01002ed:	89 e5                	mov    %esp,%ebp
f01002ef:	53                   	push   %ebx
f01002f0:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01002f3:	84 c0                	test   %al,%al
f01002f5:	79 36                	jns    f010032d <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01002f7:	8b 0d 00 a0 22 f0    	mov    0xf022a000,%ecx
f01002fd:	89 cb                	mov    %ecx,%ebx
f01002ff:	83 e3 40             	and    $0x40,%ebx
f0100302:	83 e0 7f             	and    $0x7f,%eax
f0100305:	85 db                	test   %ebx,%ebx
f0100307:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010030a:	0f b6 d2             	movzbl %dl,%edx
f010030d:	0f b6 82 60 5f 10 f0 	movzbl -0xfefa0a0(%edx),%eax
f0100314:	83 c8 40             	or     $0x40,%eax
f0100317:	0f b6 c0             	movzbl %al,%eax
f010031a:	f7 d0                	not    %eax
f010031c:	21 c8                	and    %ecx,%eax
f010031e:	a3 00 a0 22 f0       	mov    %eax,0xf022a000
		return 0;
f0100323:	b8 00 00 00 00       	mov    $0x0,%eax
f0100328:	e9 9e 00 00 00       	jmp    f01003cb <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f010032d:	8b 0d 00 a0 22 f0    	mov    0xf022a000,%ecx
f0100333:	f6 c1 40             	test   $0x40,%cl
f0100336:	74 0e                	je     f0100346 <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100338:	83 c8 80             	or     $0xffffff80,%eax
f010033b:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010033d:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100340:	89 0d 00 a0 22 f0    	mov    %ecx,0xf022a000
	}

	shift |= shiftcode[data];
f0100346:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100349:	0f b6 82 60 5f 10 f0 	movzbl -0xfefa0a0(%edx),%eax
f0100350:	0b 05 00 a0 22 f0    	or     0xf022a000,%eax
f0100356:	0f b6 8a 60 5e 10 f0 	movzbl -0xfefa1a0(%edx),%ecx
f010035d:	31 c8                	xor    %ecx,%eax
f010035f:	a3 00 a0 22 f0       	mov    %eax,0xf022a000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100364:	89 c1                	mov    %eax,%ecx
f0100366:	83 e1 03             	and    $0x3,%ecx
f0100369:	8b 0c 8d 40 5e 10 f0 	mov    -0xfefa1c0(,%ecx,4),%ecx
f0100370:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100374:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100377:	a8 08                	test   $0x8,%al
f0100379:	74 1b                	je     f0100396 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f010037b:	89 da                	mov    %ebx,%edx
f010037d:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100380:	83 f9 19             	cmp    $0x19,%ecx
f0100383:	77 05                	ja     f010038a <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100385:	83 eb 20             	sub    $0x20,%ebx
f0100388:	eb 0c                	jmp    f0100396 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f010038a:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010038d:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100390:	83 fa 19             	cmp    $0x19,%edx
f0100393:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100396:	f7 d0                	not    %eax
f0100398:	a8 06                	test   $0x6,%al
f010039a:	75 2d                	jne    f01003c9 <kbd_proc_data+0x104>
f010039c:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003a2:	75 25                	jne    f01003c9 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01003a4:	83 ec 0c             	sub    $0xc,%esp
f01003a7:	68 03 5e 10 f0       	push   $0xf0105e03
f01003ac:	e8 d7 32 00 00       	call   f0103688 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b1:	ba 92 00 00 00       	mov    $0x92,%edx
f01003b6:	b8 03 00 00 00       	mov    $0x3,%eax
f01003bb:	ee                   	out    %al,(%dx)
f01003bc:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003bf:	89 d8                	mov    %ebx,%eax
f01003c1:	eb 08                	jmp    f01003cb <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01003c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003c8:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003c9:	89 d8                	mov    %ebx,%eax
}
f01003cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003ce:	c9                   	leave  
f01003cf:	c3                   	ret    

f01003d0 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003d0:	55                   	push   %ebp
f01003d1:	89 e5                	mov    %esp,%ebp
f01003d3:	57                   	push   %edi
f01003d4:	56                   	push   %esi
f01003d5:	53                   	push   %ebx
f01003d6:	83 ec 1c             	sub    $0x1c,%esp
f01003d9:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003db:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003e0:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003e5:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003ea:	eb 09                	jmp    f01003f5 <cons_putc+0x25>
f01003ec:	89 ca                	mov    %ecx,%edx
f01003ee:	ec                   	in     (%dx),%al
f01003ef:	ec                   	in     (%dx),%al
f01003f0:	ec                   	in     (%dx),%al
f01003f1:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01003f2:	83 c3 01             	add    $0x1,%ebx
f01003f5:	89 f2                	mov    %esi,%edx
f01003f7:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003f8:	a8 20                	test   $0x20,%al
f01003fa:	75 08                	jne    f0100404 <cons_putc+0x34>
f01003fc:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100402:	7e e8                	jle    f01003ec <cons_putc+0x1c>
f0100404:	89 f8                	mov    %edi,%eax
f0100406:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100409:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010040e:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010040f:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100414:	be 79 03 00 00       	mov    $0x379,%esi
f0100419:	b9 84 00 00 00       	mov    $0x84,%ecx
f010041e:	eb 09                	jmp    f0100429 <cons_putc+0x59>
f0100420:	89 ca                	mov    %ecx,%edx
f0100422:	ec                   	in     (%dx),%al
f0100423:	ec                   	in     (%dx),%al
f0100424:	ec                   	in     (%dx),%al
f0100425:	ec                   	in     (%dx),%al
f0100426:	83 c3 01             	add    $0x1,%ebx
f0100429:	89 f2                	mov    %esi,%edx
f010042b:	ec                   	in     (%dx),%al
f010042c:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100432:	7f 04                	jg     f0100438 <cons_putc+0x68>
f0100434:	84 c0                	test   %al,%al
f0100436:	79 e8                	jns    f0100420 <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100438:	ba 78 03 00 00       	mov    $0x378,%edx
f010043d:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100441:	ee                   	out    %al,(%dx)
f0100442:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100447:	b8 0d 00 00 00       	mov    $0xd,%eax
f010044c:	ee                   	out    %al,(%dx)
f010044d:	b8 08 00 00 00       	mov    $0x8,%eax
f0100452:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100453:	89 fa                	mov    %edi,%edx
f0100455:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010045b:	89 f8                	mov    %edi,%eax
f010045d:	80 cc 07             	or     $0x7,%ah
f0100460:	85 d2                	test   %edx,%edx
f0100462:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100465:	89 f8                	mov    %edi,%eax
f0100467:	0f b6 c0             	movzbl %al,%eax
f010046a:	83 f8 09             	cmp    $0x9,%eax
f010046d:	74 74                	je     f01004e3 <cons_putc+0x113>
f010046f:	83 f8 09             	cmp    $0x9,%eax
f0100472:	7f 0a                	jg     f010047e <cons_putc+0xae>
f0100474:	83 f8 08             	cmp    $0x8,%eax
f0100477:	74 14                	je     f010048d <cons_putc+0xbd>
f0100479:	e9 99 00 00 00       	jmp    f0100517 <cons_putc+0x147>
f010047e:	83 f8 0a             	cmp    $0xa,%eax
f0100481:	74 3a                	je     f01004bd <cons_putc+0xed>
f0100483:	83 f8 0d             	cmp    $0xd,%eax
f0100486:	74 3d                	je     f01004c5 <cons_putc+0xf5>
f0100488:	e9 8a 00 00 00       	jmp    f0100517 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f010048d:	0f b7 05 28 a2 22 f0 	movzwl 0xf022a228,%eax
f0100494:	66 85 c0             	test   %ax,%ax
f0100497:	0f 84 e6 00 00 00    	je     f0100583 <cons_putc+0x1b3>
			crt_pos--;
f010049d:	83 e8 01             	sub    $0x1,%eax
f01004a0:	66 a3 28 a2 22 f0    	mov    %ax,0xf022a228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004a6:	0f b7 c0             	movzwl %ax,%eax
f01004a9:	66 81 e7 00 ff       	and    $0xff00,%di
f01004ae:	83 cf 20             	or     $0x20,%edi
f01004b1:	8b 15 2c a2 22 f0    	mov    0xf022a22c,%edx
f01004b7:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004bb:	eb 78                	jmp    f0100535 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004bd:	66 83 05 28 a2 22 f0 	addw   $0x50,0xf022a228
f01004c4:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004c5:	0f b7 05 28 a2 22 f0 	movzwl 0xf022a228,%eax
f01004cc:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004d2:	c1 e8 16             	shr    $0x16,%eax
f01004d5:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004d8:	c1 e0 04             	shl    $0x4,%eax
f01004db:	66 a3 28 a2 22 f0    	mov    %ax,0xf022a228
f01004e1:	eb 52                	jmp    f0100535 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01004e3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e8:	e8 e3 fe ff ff       	call   f01003d0 <cons_putc>
		cons_putc(' ');
f01004ed:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f2:	e8 d9 fe ff ff       	call   f01003d0 <cons_putc>
		cons_putc(' ');
f01004f7:	b8 20 00 00 00       	mov    $0x20,%eax
f01004fc:	e8 cf fe ff ff       	call   f01003d0 <cons_putc>
		cons_putc(' ');
f0100501:	b8 20 00 00 00       	mov    $0x20,%eax
f0100506:	e8 c5 fe ff ff       	call   f01003d0 <cons_putc>
		cons_putc(' ');
f010050b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100510:	e8 bb fe ff ff       	call   f01003d0 <cons_putc>
f0100515:	eb 1e                	jmp    f0100535 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100517:	0f b7 05 28 a2 22 f0 	movzwl 0xf022a228,%eax
f010051e:	8d 50 01             	lea    0x1(%eax),%edx
f0100521:	66 89 15 28 a2 22 f0 	mov    %dx,0xf022a228
f0100528:	0f b7 c0             	movzwl %ax,%eax
f010052b:	8b 15 2c a2 22 f0    	mov    0xf022a22c,%edx
f0100531:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100535:	66 81 3d 28 a2 22 f0 	cmpw   $0x7cf,0xf022a228
f010053c:	cf 07 
f010053e:	76 43                	jbe    f0100583 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t)); // You can write more than one line once the max is reached. Brings the cursor to init position.
f0100540:	a1 2c a2 22 f0       	mov    0xf022a22c,%eax
f0100545:	83 ec 04             	sub    $0x4,%esp
f0100548:	68 00 0f 00 00       	push   $0xf00
f010054d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100553:	52                   	push   %edx
f0100554:	50                   	push   %eax
f0100555:	e8 7e 4b 00 00       	call   f01050d8 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010055a:	8b 15 2c a2 22 f0    	mov    0xf022a22c,%edx
f0100560:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100566:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010056c:	83 c4 10             	add    $0x10,%esp
f010056f:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100574:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t)); // You can write more than one line once the max is reached. Brings the cursor to init position.
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100577:	39 d0                	cmp    %edx,%eax
f0100579:	75 f4                	jne    f010056f <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010057b:	66 83 2d 28 a2 22 f0 	subw   $0x50,0xf022a228
f0100582:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100583:	8b 0d 30 a2 22 f0    	mov    0xf022a230,%ecx
f0100589:	b8 0e 00 00 00       	mov    $0xe,%eax
f010058e:	89 ca                	mov    %ecx,%edx
f0100590:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100591:	0f b7 1d 28 a2 22 f0 	movzwl 0xf022a228,%ebx
f0100598:	8d 71 01             	lea    0x1(%ecx),%esi
f010059b:	89 d8                	mov    %ebx,%eax
f010059d:	66 c1 e8 08          	shr    $0x8,%ax
f01005a1:	89 f2                	mov    %esi,%edx
f01005a3:	ee                   	out    %al,(%dx)
f01005a4:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005a9:	89 ca                	mov    %ecx,%edx
f01005ab:	ee                   	out    %al,(%dx)
f01005ac:	89 d8                	mov    %ebx,%eax
f01005ae:	89 f2                	mov    %esi,%edx
f01005b0:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005b4:	5b                   	pop    %ebx
f01005b5:	5e                   	pop    %esi
f01005b6:	5f                   	pop    %edi
f01005b7:	5d                   	pop    %ebp
f01005b8:	c3                   	ret    

f01005b9 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005b9:	80 3d 34 a2 22 f0 00 	cmpb   $0x0,0xf022a234
f01005c0:	74 11                	je     f01005d3 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005c2:	55                   	push   %ebp
f01005c3:	89 e5                	mov    %esp,%ebp
f01005c5:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005c8:	b8 63 02 10 f0       	mov    $0xf0100263,%eax
f01005cd:	e8 b0 fc ff ff       	call   f0100282 <cons_intr>
}
f01005d2:	c9                   	leave  
f01005d3:	f3 c3                	repz ret 

f01005d5 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005d5:	55                   	push   %ebp
f01005d6:	89 e5                	mov    %esp,%ebp
f01005d8:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005db:	b8 c5 02 10 f0       	mov    $0xf01002c5,%eax
f01005e0:	e8 9d fc ff ff       	call   f0100282 <cons_intr>
}
f01005e5:	c9                   	leave  
f01005e6:	c3                   	ret    

f01005e7 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005e7:	55                   	push   %ebp
f01005e8:	89 e5                	mov    %esp,%ebp
f01005ea:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005ed:	e8 c7 ff ff ff       	call   f01005b9 <serial_intr>
	kbd_intr();
f01005f2:	e8 de ff ff ff       	call   f01005d5 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01005f7:	a1 20 a2 22 f0       	mov    0xf022a220,%eax
f01005fc:	3b 05 24 a2 22 f0    	cmp    0xf022a224,%eax
f0100602:	74 26                	je     f010062a <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100604:	8d 50 01             	lea    0x1(%eax),%edx
f0100607:	89 15 20 a2 22 f0    	mov    %edx,0xf022a220
f010060d:	0f b6 88 20 a0 22 f0 	movzbl -0xfdd5fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100614:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100616:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010061c:	75 11                	jne    f010062f <cons_getc+0x48>
			cons.rpos = 0;
f010061e:	c7 05 20 a2 22 f0 00 	movl   $0x0,0xf022a220
f0100625:	00 00 00 
f0100628:	eb 05                	jmp    f010062f <cons_getc+0x48>
		return c;
	}
	return 0;
f010062a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010062f:	c9                   	leave  
f0100630:	c3                   	ret    

f0100631 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100631:	55                   	push   %ebp
f0100632:	89 e5                	mov    %esp,%ebp
f0100634:	57                   	push   %edi
f0100635:	56                   	push   %esi
f0100636:	53                   	push   %ebx
f0100637:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010063a:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100641:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100648:	5a a5 
	if (*cp != 0xA55A) {
f010064a:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100651:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100655:	74 11                	je     f0100668 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100657:	c7 05 30 a2 22 f0 b4 	movl   $0x3b4,0xf022a230
f010065e:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100661:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100666:	eb 16                	jmp    f010067e <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100668:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010066f:	c7 05 30 a2 22 f0 d4 	movl   $0x3d4,0xf022a230
f0100676:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100679:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010067e:	8b 3d 30 a2 22 f0    	mov    0xf022a230,%edi
f0100684:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100689:	89 fa                	mov    %edi,%edx
f010068b:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010068c:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010068f:	89 da                	mov    %ebx,%edx
f0100691:	ec                   	in     (%dx),%al
f0100692:	0f b6 c8             	movzbl %al,%ecx
f0100695:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100698:	b8 0f 00 00 00       	mov    $0xf,%eax
f010069d:	89 fa                	mov    %edi,%edx
f010069f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a0:	89 da                	mov    %ebx,%edx
f01006a2:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006a3:	89 35 2c a2 22 f0    	mov    %esi,0xf022a22c
	crt_pos = pos;
f01006a9:	0f b6 c0             	movzbl %al,%eax
f01006ac:	09 c8                	or     %ecx,%eax
f01006ae:	66 a3 28 a2 22 f0    	mov    %ax,0xf022a228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006b4:	e8 1c ff ff ff       	call   f01005d5 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006b9:	83 ec 0c             	sub    $0xc,%esp
f01006bc:	0f b7 05 a8 f3 11 f0 	movzwl 0xf011f3a8,%eax
f01006c3:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006c8:	50                   	push   %eax
f01006c9:	e8 69 2e 00 00       	call   f0103537 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ce:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01006d8:	89 f2                	mov    %esi,%edx
f01006da:	ee                   	out    %al,(%dx)
f01006db:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006e0:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006e5:	ee                   	out    %al,(%dx)
f01006e6:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01006eb:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006f0:	89 da                	mov    %ebx,%edx
f01006f2:	ee                   	out    %al,(%dx)
f01006f3:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01006f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01006fd:	ee                   	out    %al,(%dx)
f01006fe:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100703:	b8 03 00 00 00       	mov    $0x3,%eax
f0100708:	ee                   	out    %al,(%dx)
f0100709:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010070e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100713:	ee                   	out    %al,(%dx)
f0100714:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100719:	b8 01 00 00 00       	mov    $0x1,%eax
f010071e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010071f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100724:	ec                   	in     (%dx),%al
f0100725:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100727:	83 c4 10             	add    $0x10,%esp
f010072a:	3c ff                	cmp    $0xff,%al
f010072c:	0f 95 05 34 a2 22 f0 	setne  0xf022a234
f0100733:	89 f2                	mov    %esi,%edx
f0100735:	ec                   	in     (%dx),%al
f0100736:	89 da                	mov    %ebx,%edx
f0100738:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100739:	80 f9 ff             	cmp    $0xff,%cl
f010073c:	75 10                	jne    f010074e <cons_init+0x11d>
		cprintf("Serial port does not exist!\n");
f010073e:	83 ec 0c             	sub    $0xc,%esp
f0100741:	68 0f 5e 10 f0       	push   $0xf0105e0f
f0100746:	e8 3d 2f 00 00       	call   f0103688 <cprintf>
f010074b:	83 c4 10             	add    $0x10,%esp
}
f010074e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100751:	5b                   	pop    %ebx
f0100752:	5e                   	pop    %esi
f0100753:	5f                   	pop    %edi
f0100754:	5d                   	pop    %ebp
f0100755:	c3                   	ret    

f0100756 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100756:	55                   	push   %ebp
f0100757:	89 e5                	mov    %esp,%ebp
f0100759:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010075c:	8b 45 08             	mov    0x8(%ebp),%eax
f010075f:	e8 6c fc ff ff       	call   f01003d0 <cons_putc>
}
f0100764:	c9                   	leave  
f0100765:	c3                   	ret    

f0100766 <getchar>:

int
getchar(void)
{
f0100766:	55                   	push   %ebp
f0100767:	89 e5                	mov    %esp,%ebp
f0100769:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010076c:	e8 76 fe ff ff       	call   f01005e7 <cons_getc>
f0100771:	85 c0                	test   %eax,%eax
f0100773:	74 f7                	je     f010076c <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100775:	c9                   	leave  
f0100776:	c3                   	ret    

f0100777 <iscons>:

int
iscons(int fdnum)
{
f0100777:	55                   	push   %ebp
f0100778:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010077a:	b8 01 00 00 00       	mov    $0x1,%eax
f010077f:	5d                   	pop    %ebp
f0100780:	c3                   	ret    

f0100781 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100781:	55                   	push   %ebp
f0100782:	89 e5                	mov    %esp,%ebp
f0100784:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100787:	68 60 60 10 f0       	push   $0xf0106060
f010078c:	68 7e 60 10 f0       	push   $0xf010607e
f0100791:	68 83 60 10 f0       	push   $0xf0106083
f0100796:	e8 ed 2e 00 00       	call   f0103688 <cprintf>
f010079b:	83 c4 0c             	add    $0xc,%esp
f010079e:	68 50 61 10 f0       	push   $0xf0106150
f01007a3:	68 8c 60 10 f0       	push   $0xf010608c
f01007a8:	68 83 60 10 f0       	push   $0xf0106083
f01007ad:	e8 d6 2e 00 00       	call   f0103688 <cprintf>
f01007b2:	83 c4 0c             	add    $0xc,%esp
f01007b5:	68 95 60 10 f0       	push   $0xf0106095
f01007ba:	68 b1 60 10 f0       	push   $0xf01060b1
f01007bf:	68 83 60 10 f0       	push   $0xf0106083
f01007c4:	e8 bf 2e 00 00       	call   f0103688 <cprintf>
	return 0;
}
f01007c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ce:	c9                   	leave  
f01007cf:	c3                   	ret    

f01007d0 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007d0:	55                   	push   %ebp
f01007d1:	89 e5                	mov    %esp,%ebp
f01007d3:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007d6:	68 bb 60 10 f0       	push   $0xf01060bb
f01007db:	e8 a8 2e 00 00       	call   f0103688 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007e0:	83 c4 08             	add    $0x8,%esp
f01007e3:	68 0c 00 10 00       	push   $0x10000c
f01007e8:	68 78 61 10 f0       	push   $0xf0106178
f01007ed:	e8 96 2e 00 00       	call   f0103688 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007f2:	83 c4 0c             	add    $0xc,%esp
f01007f5:	68 0c 00 10 00       	push   $0x10000c
f01007fa:	68 0c 00 10 f0       	push   $0xf010000c
f01007ff:	68 a0 61 10 f0       	push   $0xf01061a0
f0100804:	e8 7f 2e 00 00       	call   f0103688 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100809:	83 c4 0c             	add    $0xc,%esp
f010080c:	68 31 5d 10 00       	push   $0x105d31
f0100811:	68 31 5d 10 f0       	push   $0xf0105d31
f0100816:	68 c4 61 10 f0       	push   $0xf01061c4
f010081b:	e8 68 2e 00 00       	call   f0103688 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100820:	83 c4 0c             	add    $0xc,%esp
f0100823:	68 d8 95 22 00       	push   $0x2295d8
f0100828:	68 d8 95 22 f0       	push   $0xf02295d8
f010082d:	68 e8 61 10 f0       	push   $0xf01061e8
f0100832:	e8 51 2e 00 00       	call   f0103688 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100837:	83 c4 0c             	add    $0xc,%esp
f010083a:	68 08 c0 26 00       	push   $0x26c008
f010083f:	68 08 c0 26 f0       	push   $0xf026c008
f0100844:	68 0c 62 10 f0       	push   $0xf010620c
f0100849:	e8 3a 2e 00 00       	call   f0103688 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010084e:	b8 07 c4 26 f0       	mov    $0xf026c407,%eax
f0100853:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100858:	83 c4 08             	add    $0x8,%esp
f010085b:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100860:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100866:	85 c0                	test   %eax,%eax
f0100868:	0f 48 c2             	cmovs  %edx,%eax
f010086b:	c1 f8 0a             	sar    $0xa,%eax
f010086e:	50                   	push   %eax
f010086f:	68 30 62 10 f0       	push   $0xf0106230
f0100874:	e8 0f 2e 00 00       	call   f0103688 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100879:	b8 00 00 00 00       	mov    $0x0,%eax
f010087e:	c9                   	leave  
f010087f:	c3                   	ret    

f0100880 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100880:	55                   	push   %ebp
f0100881:	89 e5                	mov    %esp,%ebp
f0100883:	57                   	push   %edi
f0100884:	56                   	push   %esi
f0100885:	53                   	push   %ebx
f0100886:	83 ec 38             	sub    $0x38,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100889:	89 eb                	mov    %ebp,%ebx
	
 uint32_t* ebp;
struct Eipdebuginfo info;
ebp = (uint32_t*) read_ebp();
cprintf("Stack backtrace:\n");
f010088b:	68 d4 60 10 f0       	push   $0xf01060d4
f0100890:	e8 f3 2d 00 00       	call   f0103688 <cprintf>
while (ebp){
f0100895:	83 c4 10             	add    $0x10,%esp
cprintf("%08x ",*(ebp+2)); 
cprintf("%08x ",*(ebp+3)) ;
cprintf("%08x ",*(ebp+4)) ;
cprintf("%08x ",*(ebp+5)) ;
cprintf("%08x\n",*(ebp+6)) ;
debuginfo_eip(eip, &info);
f0100898:	8d 7d d0             	lea    -0x30(%ebp),%edi
	
 uint32_t* ebp;
struct Eipdebuginfo info;
ebp = (uint32_t*) read_ebp();
cprintf("Stack backtrace:\n");
while (ebp){
f010089b:	e9 a9 00 00 00       	jmp    f0100949 <mon_backtrace+0xc9>
uint32_t offset_eip =0;
uint32_t eip = *(ebp+1);
f01008a0:	8b 73 04             	mov    0x4(%ebx),%esi

cprintf ("ebp %08x ",ebp);
f01008a3:	83 ec 08             	sub    $0x8,%esp
f01008a6:	53                   	push   %ebx
f01008a7:	68 e6 60 10 f0       	push   $0xf01060e6
f01008ac:	e8 d7 2d 00 00       	call   f0103688 <cprintf>
cprintf ("eip %08x ",*(ebp+1));
f01008b1:	83 c4 08             	add    $0x8,%esp
f01008b4:	ff 73 04             	pushl  0x4(%ebx)
f01008b7:	68 f0 60 10 f0       	push   $0xf01060f0
f01008bc:	e8 c7 2d 00 00       	call   f0103688 <cprintf>
cprintf("args:");
f01008c1:	c7 04 24 fa 60 10 f0 	movl   $0xf01060fa,(%esp)
f01008c8:	e8 bb 2d 00 00       	call   f0103688 <cprintf>
cprintf("%08x ",*(ebp+2)); 
f01008cd:	83 c4 08             	add    $0x8,%esp
f01008d0:	ff 73 08             	pushl  0x8(%ebx)
f01008d3:	68 ea 60 10 f0       	push   $0xf01060ea
f01008d8:	e8 ab 2d 00 00       	call   f0103688 <cprintf>
cprintf("%08x ",*(ebp+3)) ;
f01008dd:	83 c4 08             	add    $0x8,%esp
f01008e0:	ff 73 0c             	pushl  0xc(%ebx)
f01008e3:	68 ea 60 10 f0       	push   $0xf01060ea
f01008e8:	e8 9b 2d 00 00       	call   f0103688 <cprintf>
cprintf("%08x ",*(ebp+4)) ;
f01008ed:	83 c4 08             	add    $0x8,%esp
f01008f0:	ff 73 10             	pushl  0x10(%ebx)
f01008f3:	68 ea 60 10 f0       	push   $0xf01060ea
f01008f8:	e8 8b 2d 00 00       	call   f0103688 <cprintf>
cprintf("%08x ",*(ebp+5)) ;
f01008fd:	83 c4 08             	add    $0x8,%esp
f0100900:	ff 73 14             	pushl  0x14(%ebx)
f0100903:	68 ea 60 10 f0       	push   $0xf01060ea
f0100908:	e8 7b 2d 00 00       	call   f0103688 <cprintf>
cprintf("%08x\n",*(ebp+6)) ;
f010090d:	83 c4 08             	add    $0x8,%esp
f0100910:	ff 73 18             	pushl  0x18(%ebx)
f0100913:	68 39 7a 10 f0       	push   $0xf0107a39
f0100918:	e8 6b 2d 00 00       	call   f0103688 <cprintf>
debuginfo_eip(eip, &info);
f010091d:	83 c4 08             	add    $0x8,%esp
f0100920:	57                   	push   %edi
f0100921:	56                   	push   %esi
f0100922:	e8 be 3c 00 00       	call   f01045e5 <debuginfo_eip>
offset_eip = eip-info.eip_fn_addr;
cprintf("\t %s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,offset_eip);
f0100927:	83 c4 08             	add    $0x8,%esp
f010092a:	2b 75 e0             	sub    -0x20(%ebp),%esi
f010092d:	56                   	push   %esi
f010092e:	ff 75 d8             	pushl  -0x28(%ebp)
f0100931:	ff 75 dc             	pushl  -0x24(%ebp)
f0100934:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100937:	ff 75 d0             	pushl  -0x30(%ebp)
f010093a:	68 00 61 10 f0       	push   $0xf0106100
f010093f:	e8 44 2d 00 00       	call   f0103688 <cprintf>

//cprintf(" *ebp is %08x\n",*ebp);
 ebp = (uint32_t*) *ebp;
f0100944:	8b 1b                	mov    (%ebx),%ebx
f0100946:	83 c4 20             	add    $0x20,%esp
	
 uint32_t* ebp;
struct Eipdebuginfo info;
ebp = (uint32_t*) read_ebp();
cprintf("Stack backtrace:\n");
while (ebp){
f0100949:	85 db                	test   %ebx,%ebx
f010094b:	0f 85 4f ff ff ff    	jne    f01008a0 <mon_backtrace+0x20>
 ebp = (uint32_t*) *ebp;
}


	return 0;
}
f0100951:	b8 00 00 00 00       	mov    $0x0,%eax
f0100956:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100959:	5b                   	pop    %ebx
f010095a:	5e                   	pop    %esi
f010095b:	5f                   	pop    %edi
f010095c:	5d                   	pop    %ebp
f010095d:	c3                   	ret    

f010095e <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010095e:	55                   	push   %ebp
f010095f:	89 e5                	mov    %esp,%ebp
f0100961:	57                   	push   %edi
f0100962:	56                   	push   %esi
f0100963:	53                   	push   %ebx
f0100964:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100967:	68 5c 62 10 f0       	push   $0xf010625c
f010096c:	e8 17 2d 00 00       	call   f0103688 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100971:	c7 04 24 80 62 10 f0 	movl   $0xf0106280,(%esp)
f0100978:	e8 0b 2d 00 00       	call   f0103688 <cprintf>

	if (tf != NULL)
f010097d:	83 c4 10             	add    $0x10,%esp
f0100980:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100984:	74 0e                	je     f0100994 <monitor+0x36>
		print_trapframe(tf);
f0100986:	83 ec 0c             	sub    $0xc,%esp
f0100989:	ff 75 08             	pushl  0x8(%ebp)
f010098c:	e8 b0 30 00 00       	call   f0103a41 <print_trapframe>
f0100991:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100994:	83 ec 0c             	sub    $0xc,%esp
f0100997:	68 12 61 10 f0       	push   $0xf0106112
f010099c:	e8 93 44 00 00       	call   f0104e34 <readline>
f01009a1:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009a3:	83 c4 10             	add    $0x10,%esp
f01009a6:	85 c0                	test   %eax,%eax
f01009a8:	74 ea                	je     f0100994 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009aa:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01009b1:	be 00 00 00 00       	mov    $0x0,%esi
f01009b6:	eb 0a                	jmp    f01009c2 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01009b8:	c6 03 00             	movb   $0x0,(%ebx)
f01009bb:	89 f7                	mov    %esi,%edi
f01009bd:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01009c0:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01009c2:	0f b6 03             	movzbl (%ebx),%eax
f01009c5:	84 c0                	test   %al,%al
f01009c7:	74 63                	je     f0100a2c <monitor+0xce>
f01009c9:	83 ec 08             	sub    $0x8,%esp
f01009cc:	0f be c0             	movsbl %al,%eax
f01009cf:	50                   	push   %eax
f01009d0:	68 16 61 10 f0       	push   $0xf0106116
f01009d5:	e8 74 46 00 00       	call   f010504e <strchr>
f01009da:	83 c4 10             	add    $0x10,%esp
f01009dd:	85 c0                	test   %eax,%eax
f01009df:	75 d7                	jne    f01009b8 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01009e1:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009e4:	74 46                	je     f0100a2c <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01009e6:	83 fe 0f             	cmp    $0xf,%esi
f01009e9:	75 14                	jne    f01009ff <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009eb:	83 ec 08             	sub    $0x8,%esp
f01009ee:	6a 10                	push   $0x10
f01009f0:	68 1b 61 10 f0       	push   $0xf010611b
f01009f5:	e8 8e 2c 00 00       	call   f0103688 <cprintf>
f01009fa:	83 c4 10             	add    $0x10,%esp
f01009fd:	eb 95                	jmp    f0100994 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f01009ff:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a02:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a06:	eb 03                	jmp    f0100a0b <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100a08:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a0b:	0f b6 03             	movzbl (%ebx),%eax
f0100a0e:	84 c0                	test   %al,%al
f0100a10:	74 ae                	je     f01009c0 <monitor+0x62>
f0100a12:	83 ec 08             	sub    $0x8,%esp
f0100a15:	0f be c0             	movsbl %al,%eax
f0100a18:	50                   	push   %eax
f0100a19:	68 16 61 10 f0       	push   $0xf0106116
f0100a1e:	e8 2b 46 00 00       	call   f010504e <strchr>
f0100a23:	83 c4 10             	add    $0x10,%esp
f0100a26:	85 c0                	test   %eax,%eax
f0100a28:	74 de                	je     f0100a08 <monitor+0xaa>
f0100a2a:	eb 94                	jmp    f01009c0 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100a2c:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a33:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a34:	85 f6                	test   %esi,%esi
f0100a36:	0f 84 58 ff ff ff    	je     f0100994 <monitor+0x36>
f0100a3c:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a41:	83 ec 08             	sub    $0x8,%esp
f0100a44:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a47:	ff 34 85 c0 62 10 f0 	pushl  -0xfef9d40(,%eax,4)
f0100a4e:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a51:	e8 9a 45 00 00       	call   f0104ff0 <strcmp>
f0100a56:	83 c4 10             	add    $0x10,%esp
f0100a59:	85 c0                	test   %eax,%eax
f0100a5b:	75 21                	jne    f0100a7e <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f0100a5d:	83 ec 04             	sub    $0x4,%esp
f0100a60:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a63:	ff 75 08             	pushl  0x8(%ebp)
f0100a66:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a69:	52                   	push   %edx
f0100a6a:	56                   	push   %esi
f0100a6b:	ff 14 85 c8 62 10 f0 	call   *-0xfef9d38(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a72:	83 c4 10             	add    $0x10,%esp
f0100a75:	85 c0                	test   %eax,%eax
f0100a77:	78 25                	js     f0100a9e <monitor+0x140>
f0100a79:	e9 16 ff ff ff       	jmp    f0100994 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a7e:	83 c3 01             	add    $0x1,%ebx
f0100a81:	83 fb 03             	cmp    $0x3,%ebx
f0100a84:	75 bb                	jne    f0100a41 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a86:	83 ec 08             	sub    $0x8,%esp
f0100a89:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a8c:	68 38 61 10 f0       	push   $0xf0106138
f0100a91:	e8 f2 2b 00 00       	call   f0103688 <cprintf>
f0100a96:	83 c4 10             	add    $0x10,%esp
f0100a99:	e9 f6 fe ff ff       	jmp    f0100994 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100aa1:	5b                   	pop    %ebx
f0100aa2:	5e                   	pop    %esi
f0100aa3:	5f                   	pop    %edi
f0100aa4:	5d                   	pop    %ebp
f0100aa5:	c3                   	ret    

f0100aa6 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100aa6:	55                   	push   %ebp
f0100aa7:	89 e5                	mov    %esp,%ebp
f0100aa9:	53                   	push   %ebx
f0100aaa:	83 ec 04             	sub    $0x4,%esp
f0100aad:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100aaf:	83 3d 38 a2 22 f0 00 	cmpl   $0x0,0xf022a238
f0100ab6:	75 0f                	jne    f0100ac7 <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100ab8:	b8 07 d0 26 f0       	mov    $0xf026d007,%eax
f0100abd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ac2:	a3 38 a2 22 f0       	mov    %eax,0xf022a238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	cprintf("boot_alloc memory at %x\n", nextfree);
f0100ac7:	83 ec 08             	sub    $0x8,%esp
f0100aca:	ff 35 38 a2 22 f0    	pushl  0xf022a238
f0100ad0:	68 e4 62 10 f0       	push   $0xf01062e4
f0100ad5:	e8 ae 2b 00 00       	call   f0103688 <cprintf>
	cprintf("Next memory at %x\n", ROUNDUP((char *) (nextfree+n), PGSIZE));
f0100ada:	89 d8                	mov    %ebx,%eax
f0100adc:	03 05 38 a2 22 f0    	add    0xf022a238,%eax
f0100ae2:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100ae7:	83 c4 08             	add    $0x8,%esp
f0100aea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100aef:	50                   	push   %eax
f0100af0:	68 fd 62 10 f0       	push   $0xf01062fd
f0100af5:	e8 8e 2b 00 00       	call   f0103688 <cprintf>
	if (n != 0) {
f0100afa:	83 c4 10             	add    $0x10,%esp
		char *next = nextfree;
		nextfree = ROUNDUP((char *) (nextfree+n), PGSIZE);
		return next;
	} else return nextfree;
f0100afd:	a1 38 a2 22 f0       	mov    0xf022a238,%eax
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	cprintf("boot_alloc memory at %x\n", nextfree);
	cprintf("Next memory at %x\n", ROUNDUP((char *) (nextfree+n), PGSIZE));
	if (n != 0) {
f0100b02:	85 db                	test   %ebx,%ebx
f0100b04:	74 13                	je     f0100b19 <boot_alloc+0x73>
		char *next = nextfree;
		nextfree = ROUNDUP((char *) (nextfree+n), PGSIZE);
f0100b06:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f0100b0d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b13:	89 15 38 a2 22 f0    	mov    %edx,0xf022a238
		return next;
	} else return nextfree;

	return NULL;
}
f0100b19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b1c:	c9                   	leave  
f0100b1d:	c3                   	ret    

f0100b1e <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100b1e:	89 d1                	mov    %edx,%ecx
f0100b20:	c1 e9 16             	shr    $0x16,%ecx
f0100b23:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b26:	a8 01                	test   $0x1,%al
f0100b28:	74 52                	je     f0100b7c <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b2a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b2f:	89 c1                	mov    %eax,%ecx
f0100b31:	c1 e9 0c             	shr    $0xc,%ecx
f0100b34:	3b 0d 08 af 22 f0    	cmp    0xf022af08,%ecx
f0100b3a:	72 1b                	jb     f0100b57 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b3c:	55                   	push   %ebp
f0100b3d:	89 e5                	mov    %esp,%ebp
f0100b3f:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b42:	50                   	push   %eax
f0100b43:	68 64 5d 10 f0       	push   $0xf0105d64
f0100b48:	68 86 03 00 00       	push   $0x386
f0100b4d:	68 10 63 10 f0       	push   $0xf0106310
f0100b52:	e8 e9 f4 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100b57:	c1 ea 0c             	shr    $0xc,%edx
f0100b5a:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b60:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b67:	89 c2                	mov    %eax,%edx
f0100b69:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b6c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b71:	85 d2                	test   %edx,%edx
f0100b73:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b78:	0f 44 c2             	cmove  %edx,%eax
f0100b7b:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100b81:	c3                   	ret    

f0100b82 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b82:	55                   	push   %ebp
f0100b83:	89 e5                	mov    %esp,%ebp
f0100b85:	57                   	push   %edi
f0100b86:	56                   	push   %esi
f0100b87:	53                   	push   %ebx
f0100b88:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b8b:	84 c0                	test   %al,%al
f0100b8d:	0f 85 a0 02 00 00    	jne    f0100e33 <check_page_free_list+0x2b1>
f0100b93:	e9 ad 02 00 00       	jmp    f0100e45 <check_page_free_list+0x2c3>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b98:	83 ec 04             	sub    $0x4,%esp
f0100b9b:	68 bc 66 10 f0       	push   $0xf01066bc
f0100ba0:	68 b7 02 00 00       	push   $0x2b7
f0100ba5:	68 10 63 10 f0       	push   $0xf0106310
f0100baa:	e8 91 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100baf:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100bb2:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100bb5:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100bb8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100bbb:	89 c2                	mov    %eax,%edx
f0100bbd:	2b 15 10 af 22 f0    	sub    0xf022af10,%edx
f0100bc3:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100bc9:	0f 95 c2             	setne  %dl
f0100bcc:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100bcf:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100bd3:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100bd5:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bd9:	8b 00                	mov    (%eax),%eax
f0100bdb:	85 c0                	test   %eax,%eax
f0100bdd:	75 dc                	jne    f0100bbb <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100bdf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100be2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100be8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100beb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100bee:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100bf0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bf3:	a3 40 a2 22 f0       	mov    %eax,0xf022a240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bf8:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bfd:	8b 1d 40 a2 22 f0    	mov    0xf022a240,%ebx
f0100c03:	eb 53                	jmp    f0100c58 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c05:	89 d8                	mov    %ebx,%eax
f0100c07:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f0100c0d:	c1 f8 03             	sar    $0x3,%eax
f0100c10:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c13:	89 c2                	mov    %eax,%edx
f0100c15:	c1 ea 16             	shr    $0x16,%edx
f0100c18:	39 f2                	cmp    %esi,%edx
f0100c1a:	73 3a                	jae    f0100c56 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c1c:	89 c2                	mov    %eax,%edx
f0100c1e:	c1 ea 0c             	shr    $0xc,%edx
f0100c21:	3b 15 08 af 22 f0    	cmp    0xf022af08,%edx
f0100c27:	72 12                	jb     f0100c3b <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c29:	50                   	push   %eax
f0100c2a:	68 64 5d 10 f0       	push   $0xf0105d64
f0100c2f:	6a 58                	push   $0x58
f0100c31:	68 1c 63 10 f0       	push   $0xf010631c
f0100c36:	e8 05 f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c3b:	83 ec 04             	sub    $0x4,%esp
f0100c3e:	68 80 00 00 00       	push   $0x80
f0100c43:	68 97 00 00 00       	push   $0x97
f0100c48:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c4d:	50                   	push   %eax
f0100c4e:	e8 38 44 00 00       	call   f010508b <memset>
f0100c53:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c56:	8b 1b                	mov    (%ebx),%ebx
f0100c58:	85 db                	test   %ebx,%ebx
f0100c5a:	75 a9                	jne    f0100c05 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c5c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c61:	e8 40 fe ff ff       	call   f0100aa6 <boot_alloc>
f0100c66:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c69:	8b 15 40 a2 22 f0    	mov    0xf022a240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c6f:	8b 0d 10 af 22 f0    	mov    0xf022af10,%ecx
		assert(pp < pages + npages);
f0100c75:	a1 08 af 22 f0       	mov    0xf022af08,%eax
f0100c7a:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c7d:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c80:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c83:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c86:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c8b:	e9 52 01 00 00       	jmp    f0100de2 <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c90:	39 ca                	cmp    %ecx,%edx
f0100c92:	73 19                	jae    f0100cad <check_page_free_list+0x12b>
f0100c94:	68 2a 63 10 f0       	push   $0xf010632a
f0100c99:	68 36 63 10 f0       	push   $0xf0106336
f0100c9e:	68 d1 02 00 00       	push   $0x2d1
f0100ca3:	68 10 63 10 f0       	push   $0xf0106310
f0100ca8:	e8 93 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100cad:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100cb0:	72 19                	jb     f0100ccb <check_page_free_list+0x149>
f0100cb2:	68 4b 63 10 f0       	push   $0xf010634b
f0100cb7:	68 36 63 10 f0       	push   $0xf0106336
f0100cbc:	68 d2 02 00 00       	push   $0x2d2
f0100cc1:	68 10 63 10 f0       	push   $0xf0106310
f0100cc6:	e8 75 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ccb:	89 d0                	mov    %edx,%eax
f0100ccd:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100cd0:	a8 07                	test   $0x7,%al
f0100cd2:	74 19                	je     f0100ced <check_page_free_list+0x16b>
f0100cd4:	68 e0 66 10 f0       	push   $0xf01066e0
f0100cd9:	68 36 63 10 f0       	push   $0xf0106336
f0100cde:	68 d3 02 00 00       	push   $0x2d3
f0100ce3:	68 10 63 10 f0       	push   $0xf0106310
f0100ce8:	e8 53 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ced:	c1 f8 03             	sar    $0x3,%eax
f0100cf0:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100cf3:	85 c0                	test   %eax,%eax
f0100cf5:	75 19                	jne    f0100d10 <check_page_free_list+0x18e>
f0100cf7:	68 5f 63 10 f0       	push   $0xf010635f
f0100cfc:	68 36 63 10 f0       	push   $0xf0106336
f0100d01:	68 d6 02 00 00       	push   $0x2d6
f0100d06:	68 10 63 10 f0       	push   $0xf0106310
f0100d0b:	e8 30 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d10:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d15:	75 19                	jne    f0100d30 <check_page_free_list+0x1ae>
f0100d17:	68 70 63 10 f0       	push   $0xf0106370
f0100d1c:	68 36 63 10 f0       	push   $0xf0106336
f0100d21:	68 d7 02 00 00       	push   $0x2d7
f0100d26:	68 10 63 10 f0       	push   $0xf0106310
f0100d2b:	e8 10 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d30:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d35:	75 19                	jne    f0100d50 <check_page_free_list+0x1ce>
f0100d37:	68 14 67 10 f0       	push   $0xf0106714
f0100d3c:	68 36 63 10 f0       	push   $0xf0106336
f0100d41:	68 d8 02 00 00       	push   $0x2d8
f0100d46:	68 10 63 10 f0       	push   $0xf0106310
f0100d4b:	e8 f0 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d50:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d55:	75 19                	jne    f0100d70 <check_page_free_list+0x1ee>
f0100d57:	68 89 63 10 f0       	push   $0xf0106389
f0100d5c:	68 36 63 10 f0       	push   $0xf0106336
f0100d61:	68 d9 02 00 00       	push   $0x2d9
f0100d66:	68 10 63 10 f0       	push   $0xf0106310
f0100d6b:	e8 d0 f2 ff ff       	call   f0100040 <_panic>
		// cprintf("pp: %x, page2pa(pp): %x, page2kva(pp): %x, first_free_page: %x\n",
		// 	pp, page2pa(pp), page2kva(pp), first_free_page);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d70:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d75:	0f 86 f1 00 00 00    	jbe    f0100e6c <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d7b:	89 c7                	mov    %eax,%edi
f0100d7d:	c1 ef 0c             	shr    $0xc,%edi
f0100d80:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100d83:	77 12                	ja     f0100d97 <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d85:	50                   	push   %eax
f0100d86:	68 64 5d 10 f0       	push   $0xf0105d64
f0100d8b:	6a 58                	push   $0x58
f0100d8d:	68 1c 63 10 f0       	push   $0xf010631c
f0100d92:	e8 a9 f2 ff ff       	call   f0100040 <_panic>
f0100d97:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100d9d:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100da0:	0f 86 b6 00 00 00    	jbe    f0100e5c <check_page_free_list+0x2da>
f0100da6:	68 38 67 10 f0       	push   $0xf0106738
f0100dab:	68 36 63 10 f0       	push   $0xf0106336
f0100db0:	68 dc 02 00 00       	push   $0x2dc
f0100db5:	68 10 63 10 f0       	push   $0xf0106310
f0100dba:	e8 81 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100dbf:	68 a3 63 10 f0       	push   $0xf01063a3
f0100dc4:	68 36 63 10 f0       	push   $0xf0106336
f0100dc9:	68 de 02 00 00       	push   $0x2de
f0100dce:	68 10 63 10 f0       	push   $0xf0106310
f0100dd3:	e8 68 f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100dd8:	83 c6 01             	add    $0x1,%esi
f0100ddb:	eb 03                	jmp    f0100de0 <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100ddd:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100de0:	8b 12                	mov    (%edx),%edx
f0100de2:	85 d2                	test   %edx,%edx
f0100de4:	0f 85 a6 fe ff ff    	jne    f0100c90 <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100dea:	85 f6                	test   %esi,%esi
f0100dec:	7f 19                	jg     f0100e07 <check_page_free_list+0x285>
f0100dee:	68 c0 63 10 f0       	push   $0xf01063c0
f0100df3:	68 36 63 10 f0       	push   $0xf0106336
f0100df8:	68 e6 02 00 00       	push   $0x2e6
f0100dfd:	68 10 63 10 f0       	push   $0xf0106310
f0100e02:	e8 39 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e07:	85 db                	test   %ebx,%ebx
f0100e09:	7f 19                	jg     f0100e24 <check_page_free_list+0x2a2>
f0100e0b:	68 d2 63 10 f0       	push   $0xf01063d2
f0100e10:	68 36 63 10 f0       	push   $0xf0106336
f0100e15:	68 e7 02 00 00       	push   $0x2e7
f0100e1a:	68 10 63 10 f0       	push   $0xf0106310
f0100e1f:	e8 1c f2 ff ff       	call   f0100040 <_panic>
	cprintf("check_page_free_list done\n");
f0100e24:	83 ec 0c             	sub    $0xc,%esp
f0100e27:	68 e3 63 10 f0       	push   $0xf01063e3
f0100e2c:	e8 57 28 00 00       	call   f0103688 <cprintf>
}
f0100e31:	eb 49                	jmp    f0100e7c <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e33:	a1 40 a2 22 f0       	mov    0xf022a240,%eax
f0100e38:	85 c0                	test   %eax,%eax
f0100e3a:	0f 85 6f fd ff ff    	jne    f0100baf <check_page_free_list+0x2d>
f0100e40:	e9 53 fd ff ff       	jmp    f0100b98 <check_page_free_list+0x16>
f0100e45:	83 3d 40 a2 22 f0 00 	cmpl   $0x0,0xf022a240
f0100e4c:	0f 84 46 fd ff ff    	je     f0100b98 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e52:	be 00 04 00 00       	mov    $0x400,%esi
f0100e57:	e9 a1 fd ff ff       	jmp    f0100bfd <check_page_free_list+0x7b>
		assert(page2pa(pp) != EXTPHYSMEM);
		// cprintf("pp: %x, page2pa(pp): %x, page2kva(pp): %x, first_free_page: %x\n",
		// 	pp, page2pa(pp), page2kva(pp), first_free_page);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e5c:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e61:	0f 85 76 ff ff ff    	jne    f0100ddd <check_page_free_list+0x25b>
f0100e67:	e9 53 ff ff ff       	jmp    f0100dbf <check_page_free_list+0x23d>
f0100e6c:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e71:	0f 85 61 ff ff ff    	jne    f0100dd8 <check_page_free_list+0x256>
f0100e77:	e9 43 ff ff ff       	jmp    f0100dbf <check_page_free_list+0x23d>
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
	cprintf("check_page_free_list done\n");
}
f0100e7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e7f:	5b                   	pop    %ebx
f0100e80:	5e                   	pop    %esi
f0100e81:	5f                   	pop    %edi
f0100e82:	5d                   	pop    %ebp
f0100e83:	c3                   	ret    

f0100e84 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e84:	8b 0d 40 a2 22 f0    	mov    0xf022a240,%ecx
f0100e8a:	b8 08 00 00 00       	mov    $0x8,%eax
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
    for (i = 1; i < MPENTRY_PADDR/PGSIZE; i++) {
        pages[i].pp_ref = 0;
f0100e8f:	89 c2                	mov    %eax,%edx
f0100e91:	03 15 10 af 22 f0    	add    0xf022af10,%edx
f0100e97:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
        pages[i].pp_link = page_free_list;
f0100e9d:	89 0a                	mov    %ecx,(%edx)
        page_free_list = &pages[i];
f0100e9f:	89 c1                	mov    %eax,%ecx
f0100ea1:	03 0d 10 af 22 f0    	add    0xf022af10,%ecx
f0100ea7:	83 c0 08             	add    $0x8,%eax
	// 
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
    for (i = 1; i < MPENTRY_PADDR/PGSIZE; i++) {
f0100eaa:	83 f8 38             	cmp    $0x38,%eax
f0100ead:	75 e0                	jne    f0100e8f <page_init+0xb>
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100eaf:	55                   	push   %ebp
f0100eb0:	89 e5                	mov    %esp,%ebp
f0100eb2:	53                   	push   %ebx
f0100eb3:	89 0d 40 a2 22 f0    	mov    %ecx,0xf022a240
    for (i = 1; i < MPENTRY_PADDR/PGSIZE; i++) {
        pages[i].pp_ref = 0;
        pages[i].pp_link = page_free_list;
        page_free_list = &pages[i];
	}
	int point = (int)ROUNDUP(((char*)envs) + (sizeof(struct Env) * NENV) - 0xf0000000, PGSIZE)/PGSIZE;
f0100eb9:	a1 48 a2 22 f0       	mov    0xf022a248,%eax
f0100ebe:	05 ff ff 01 10       	add    $0x1001ffff,%eax
	//cprintf("%x\n", ((char*)envs) + (sizeof(struct Env) * NENV));
	//cprintf("med=%d\n", med);
	for (i = point; i < npages; i++) {
f0100ec3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ec8:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100ece:	85 c0                	test   %eax,%eax
f0100ed0:	0f 48 c2             	cmovs  %edx,%eax
f0100ed3:	c1 f8 0c             	sar    $0xc,%eax
f0100ed6:	89 c2                	mov    %eax,%edx
f0100ed8:	c1 e0 03             	shl    $0x3,%eax
f0100edb:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ee0:	eb 23                	jmp    f0100f05 <page_init+0x81>
		pages[i].pp_ref = 0;
f0100ee2:	89 c3                	mov    %eax,%ebx
f0100ee4:	03 1d 10 af 22 f0    	add    0xf022af10,%ebx
f0100eea:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
		pages[i].pp_link = page_free_list;
f0100ef0:	89 0b                	mov    %ecx,(%ebx)
		page_free_list = &pages[i];
f0100ef2:	89 c1                	mov    %eax,%ecx
f0100ef4:	03 0d 10 af 22 f0    	add    0xf022af10,%ecx
        page_free_list = &pages[i];
	}
	int point = (int)ROUNDUP(((char*)envs) + (sizeof(struct Env) * NENV) - 0xf0000000, PGSIZE)/PGSIZE;
	//cprintf("%x\n", ((char*)envs) + (sizeof(struct Env) * NENV));
	//cprintf("med=%d\n", med);
	for (i = point; i < npages; i++) {
f0100efa:	83 c2 01             	add    $0x1,%edx
f0100efd:	83 c0 08             	add    $0x8,%eax
f0100f00:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100f05:	3b 15 08 af 22 f0    	cmp    0xf022af08,%edx
f0100f0b:	72 d5                	jb     f0100ee2 <page_init+0x5e>
f0100f0d:	84 db                	test   %bl,%bl
f0100f0f:	74 06                	je     f0100f17 <page_init+0x93>
f0100f11:	89 0d 40 a2 22 f0    	mov    %ecx,0xf022a240
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100f17:	5b                   	pop    %ebx
f0100f18:	5d                   	pop    %ebp
f0100f19:	c3                   	ret    

f0100f1a <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100f1a:	55                   	push   %ebp
f0100f1b:	89 e5                	mov    %esp,%ebp
f0100f1d:	53                   	push   %ebx
f0100f1e:	83 ec 04             	sub    $0x4,%esp
	if (page_free_list) {
f0100f21:	8b 1d 40 a2 22 f0    	mov    0xf022a240,%ebx
f0100f27:	85 db                	test   %ebx,%ebx
f0100f29:	74 52                	je     f0100f7d <page_alloc+0x63>
		struct PageInfo *ret = page_free_list;
		page_free_list = page_free_list->pp_link;
f0100f2b:	8b 03                	mov    (%ebx),%eax
f0100f2d:	a3 40 a2 22 f0       	mov    %eax,0xf022a240
		if (alloc_flags & ALLOC_ZERO) 
f0100f32:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f36:	74 45                	je     f0100f7d <page_alloc+0x63>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f38:	89 d8                	mov    %ebx,%eax
f0100f3a:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f0100f40:	c1 f8 03             	sar    $0x3,%eax
f0100f43:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f46:	89 c2                	mov    %eax,%edx
f0100f48:	c1 ea 0c             	shr    $0xc,%edx
f0100f4b:	3b 15 08 af 22 f0    	cmp    0xf022af08,%edx
f0100f51:	72 12                	jb     f0100f65 <page_alloc+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f53:	50                   	push   %eax
f0100f54:	68 64 5d 10 f0       	push   $0xf0105d64
f0100f59:	6a 58                	push   $0x58
f0100f5b:	68 1c 63 10 f0       	push   $0xf010631c
f0100f60:	e8 db f0 ff ff       	call   f0100040 <_panic>
			memset(page2kva(ret), 0, PGSIZE);
f0100f65:	83 ec 04             	sub    $0x4,%esp
f0100f68:	68 00 10 00 00       	push   $0x1000
f0100f6d:	6a 00                	push   $0x0
f0100f6f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f74:	50                   	push   %eax
f0100f75:	e8 11 41 00 00       	call   f010508b <memset>
f0100f7a:	83 c4 10             	add    $0x10,%esp
		return ret;
	}
	return NULL;
}
f0100f7d:	89 d8                	mov    %ebx,%eax
f0100f7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f82:	c9                   	leave  
f0100f83:	c3                   	ret    

f0100f84 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100f84:	55                   	push   %ebp
f0100f85:	89 e5                	mov    %esp,%ebp
f0100f87:	8b 45 08             	mov    0x8(%ebp),%eax
	pp->pp_link = page_free_list;
f0100f8a:	8b 15 40 a2 22 f0    	mov    0xf022a240,%edx
f0100f90:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100f92:	a3 40 a2 22 f0       	mov    %eax,0xf022a240
}
f0100f97:	5d                   	pop    %ebp
f0100f98:	c3                   	ret    

f0100f99 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100f99:	55                   	push   %ebp
f0100f9a:	89 e5                	mov    %esp,%ebp
f0100f9c:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100f9f:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100fa3:	83 e8 01             	sub    $0x1,%eax
f0100fa6:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100faa:	66 85 c0             	test   %ax,%ax
f0100fad:	75 09                	jne    f0100fb8 <page_decref+0x1f>
		page_free(pp);
f0100faf:	52                   	push   %edx
f0100fb0:	e8 cf ff ff ff       	call   f0100f84 <page_free>
f0100fb5:	83 c4 04             	add    $0x4,%esp
}
f0100fb8:	c9                   	leave  
f0100fb9:	c3                   	ret    

f0100fba <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100fba:	55                   	push   %ebp
f0100fbb:	89 e5                	mov    %esp,%ebp
f0100fbd:	56                   	push   %esi
f0100fbe:	53                   	push   %ebx
f0100fbf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int dindex = PDX(va), tindex = PTX(va);
f0100fc2:	89 de                	mov    %ebx,%esi
f0100fc4:	c1 ee 0c             	shr    $0xc,%esi
f0100fc7:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
f0100fcd:	c1 eb 16             	shr    $0x16,%ebx
f0100fd0:	c1 e3 02             	shl    $0x2,%ebx
f0100fd3:	03 5d 08             	add    0x8(%ebp),%ebx
f0100fd6:	f6 03 01             	testb  $0x1,(%ebx)
f0100fd9:	75 2d                	jne    f0101008 <pgdir_walk+0x4e>
		if (create) {
f0100fdb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100fdf:	74 59                	je     f010103a <pgdir_walk+0x80>
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
f0100fe1:	83 ec 0c             	sub    $0xc,%esp
f0100fe4:	6a 01                	push   $0x1
f0100fe6:	e8 2f ff ff ff       	call   f0100f1a <page_alloc>
			if (!pg) return NULL;	//allocation fails
f0100feb:	83 c4 10             	add    $0x10,%esp
f0100fee:	85 c0                	test   %eax,%eax
f0100ff0:	74 4f                	je     f0101041 <pgdir_walk+0x87>
			pg->pp_ref++;
f0100ff2:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
			pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
f0100ff7:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f0100ffd:	c1 f8 03             	sar    $0x3,%eax
f0101000:	c1 e0 0c             	shl    $0xc,%eax
f0101003:	83 c8 07             	or     $0x7,%eax
f0101006:	89 03                	mov    %eax,(%ebx)
		} else return NULL;
	}
	pte_t *p = KADDR(PTE_ADDR(pgdir[dindex]));
f0101008:	8b 03                	mov    (%ebx),%eax
f010100a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010100f:	89 c2                	mov    %eax,%edx
f0101011:	c1 ea 0c             	shr    $0xc,%edx
f0101014:	3b 15 08 af 22 f0    	cmp    0xf022af08,%edx
f010101a:	72 15                	jb     f0101031 <pgdir_walk+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010101c:	50                   	push   %eax
f010101d:	68 64 5d 10 f0       	push   $0xf0105d64
f0101022:	68 b6 01 00 00       	push   $0x1b6
f0101027:	68 10 63 10 f0       	push   $0xf0106310
f010102c:	e8 0f f0 ff ff       	call   f0100040 <_panic>
	// 		struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
	// 		pg->pp_ref++;
	// 		p[tindex] = page2pa(pg) | PTE_P;
	// 	} else return NULL;

	return p+tindex;
f0101031:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f0101038:	eb 0c                	jmp    f0101046 <pgdir_walk+0x8c>
		if (create) {
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
			if (!pg) return NULL;	//allocation fails
			pg->pp_ref++;
			pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
		} else return NULL;
f010103a:	b8 00 00 00 00       	mov    $0x0,%eax
f010103f:	eb 05                	jmp    f0101046 <pgdir_walk+0x8c>
	int dindex = PDX(va), tindex = PTX(va);
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
		if (create) {
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
			if (!pg) return NULL;	//allocation fails
f0101041:	b8 00 00 00 00       	mov    $0x0,%eax
	// 		pg->pp_ref++;
	// 		p[tindex] = page2pa(pg) | PTE_P;
	// 	} else return NULL;

	return p+tindex;
}
f0101046:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101049:	5b                   	pop    %ebx
f010104a:	5e                   	pop    %esi
f010104b:	5d                   	pop    %ebp
f010104c:	c3                   	ret    

f010104d <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010104d:	55                   	push   %ebp
f010104e:	89 e5                	mov    %esp,%ebp
f0101050:	57                   	push   %edi
f0101051:	56                   	push   %esi
f0101052:	53                   	push   %ebx
f0101053:	83 ec 20             	sub    $0x20,%esp
f0101056:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101059:	89 d7                	mov    %edx,%edi
f010105b:	89 cb                	mov    %ecx,%ebx
	int i;
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
f010105d:	ff 75 08             	pushl  0x8(%ebp)
f0101060:	52                   	push   %edx
f0101061:	68 80 67 10 f0       	push   $0xf0106780
f0101066:	e8 1d 26 00 00       	call   f0103688 <cprintf>
f010106b:	c1 eb 0c             	shr    $0xc,%ebx
f010106e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f0101071:	83 c4 10             	add    $0x10,%esp
f0101074:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101077:	be 00 00 00 00       	mov    $0x0,%esi
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
f010107c:	29 df                	sub    %ebx,%edi
		if (!pte) panic("boot_map_region panic, out of memory");
		*pte = pa | perm | PTE_P;
f010107e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101081:	83 c8 01             	or     $0x1,%eax
f0101084:	89 45 dc             	mov    %eax,-0x24(%ebp)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f0101087:	eb 3f                	jmp    f01010c8 <boot_map_region+0x7b>
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
f0101089:	83 ec 04             	sub    $0x4,%esp
f010108c:	6a 01                	push   $0x1
f010108e:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0101091:	50                   	push   %eax
f0101092:	ff 75 e0             	pushl  -0x20(%ebp)
f0101095:	e8 20 ff ff ff       	call   f0100fba <pgdir_walk>
		if (!pte) panic("boot_map_region panic, out of memory");
f010109a:	83 c4 10             	add    $0x10,%esp
f010109d:	85 c0                	test   %eax,%eax
f010109f:	75 17                	jne    f01010b8 <boot_map_region+0x6b>
f01010a1:	83 ec 04             	sub    $0x4,%esp
f01010a4:	68 b4 67 10 f0       	push   $0xf01067b4
f01010a9:	68 d4 01 00 00       	push   $0x1d4
f01010ae:	68 10 63 10 f0       	push   $0xf0106310
f01010b3:	e8 88 ef ff ff       	call   f0100040 <_panic>
		*pte = pa | perm | PTE_P;
f01010b8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01010bb:	09 da                	or     %ebx,%edx
f01010bd:	89 10                	mov    %edx,(%eax)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f01010bf:	83 c6 01             	add    $0x1,%esi
f01010c2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01010c8:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01010cb:	75 bc                	jne    f0101089 <boot_map_region+0x3c>
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
		if (!pte) panic("boot_map_region panic, out of memory");
		*pte = pa | perm | PTE_P;
	}
}
f01010cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010d0:	5b                   	pop    %ebx
f01010d1:	5e                   	pop    %esi
f01010d2:	5f                   	pop    %edi
f01010d3:	5d                   	pop    %ebp
f01010d4:	c3                   	ret    

f01010d5 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01010d5:	55                   	push   %ebp
f01010d6:	89 e5                	mov    %esp,%ebp
f01010d8:	53                   	push   %ebx
f01010d9:	83 ec 08             	sub    $0x8,%esp
f01010dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0);	//not create
f01010df:	6a 00                	push   $0x0
f01010e1:	ff 75 0c             	pushl  0xc(%ebp)
f01010e4:	ff 75 08             	pushl  0x8(%ebp)
f01010e7:	e8 ce fe ff ff       	call   f0100fba <pgdir_walk>
	if (!pte || !(*pte & PTE_P)) return NULL;	//page not found
f01010ec:	83 c4 10             	add    $0x10,%esp
f01010ef:	85 c0                	test   %eax,%eax
f01010f1:	74 37                	je     f010112a <page_lookup+0x55>
f01010f3:	f6 00 01             	testb  $0x1,(%eax)
f01010f6:	74 39                	je     f0101131 <page_lookup+0x5c>
	if (pte_store)
f01010f8:	85 db                	test   %ebx,%ebx
f01010fa:	74 02                	je     f01010fe <page_lookup+0x29>
		*pte_store = pte;	//found and set
f01010fc:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010fe:	8b 00                	mov    (%eax),%eax
f0101100:	c1 e8 0c             	shr    $0xc,%eax
f0101103:	3b 05 08 af 22 f0    	cmp    0xf022af08,%eax
f0101109:	72 14                	jb     f010111f <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f010110b:	83 ec 04             	sub    $0x4,%esp
f010110e:	68 dc 67 10 f0       	push   $0xf01067dc
f0101113:	6a 51                	push   $0x51
f0101115:	68 1c 63 10 f0       	push   $0xf010631c
f010111a:	e8 21 ef ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010111f:	8b 15 10 af 22 f0    	mov    0xf022af10,%edx
f0101125:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	return pa2page(PTE_ADDR(*pte));		
f0101128:	eb 0c                	jmp    f0101136 <page_lookup+0x61>
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t *pte = pgdir_walk(pgdir, va, 0);	//not create
	if (!pte || !(*pte & PTE_P)) return NULL;	//page not found
f010112a:	b8 00 00 00 00       	mov    $0x0,%eax
f010112f:	eb 05                	jmp    f0101136 <page_lookup+0x61>
f0101131:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pte_store)
		*pte_store = pte;	//found and set
	return pa2page(PTE_ADDR(*pte));		
}
f0101136:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101139:	c9                   	leave  
f010113a:	c3                   	ret    

f010113b <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010113b:	55                   	push   %ebp
f010113c:	89 e5                	mov    %esp,%ebp
f010113e:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101141:	e8 68 45 00 00       	call   f01056ae <cpunum>
f0101146:	6b c0 74             	imul   $0x74,%eax,%eax
f0101149:	83 b8 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%eax)
f0101150:	74 16                	je     f0101168 <tlb_invalidate+0x2d>
f0101152:	e8 57 45 00 00       	call   f01056ae <cpunum>
f0101157:	6b c0 74             	imul   $0x74,%eax,%eax
f010115a:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0101160:	8b 55 08             	mov    0x8(%ebp),%edx
f0101163:	39 50 60             	cmp    %edx,0x60(%eax)
f0101166:	75 06                	jne    f010116e <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101168:	8b 45 0c             	mov    0xc(%ebp),%eax
f010116b:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f010116e:	c9                   	leave  
f010116f:	c3                   	ret    

f0101170 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101170:	55                   	push   %ebp
f0101171:	89 e5                	mov    %esp,%ebp
f0101173:	56                   	push   %esi
f0101174:	53                   	push   %ebx
f0101175:	83 ec 14             	sub    $0x14,%esp
f0101178:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010117b:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *pte;
	struct PageInfo *pg = page_lookup(pgdir, va, &pte);
f010117e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101181:	50                   	push   %eax
f0101182:	56                   	push   %esi
f0101183:	53                   	push   %ebx
f0101184:	e8 4c ff ff ff       	call   f01010d5 <page_lookup>
	if (!pg || !(*pte & PTE_P)) return;	//page not exist
f0101189:	83 c4 10             	add    $0x10,%esp
f010118c:	85 c0                	test   %eax,%eax
f010118e:	74 27                	je     f01011b7 <page_remove+0x47>
f0101190:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101193:	f6 02 01             	testb  $0x1,(%edx)
f0101196:	74 1f                	je     f01011b7 <page_remove+0x47>
//   - The ref count on the physical page should decrement.
//   - The physical page should be freed if the refcount reaches 0.
	page_decref(pg);
f0101198:	83 ec 0c             	sub    $0xc,%esp
f010119b:	50                   	push   %eax
f010119c:	e8 f8 fd ff ff       	call   f0100f99 <page_decref>
//   - The pg table entry corresponding to 'va' should be set to 0.
	*pte = 0;
f01011a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011a4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
//   - The TLB must be invalidated if you remove an entry from
//     the page table.
	tlb_invalidate(pgdir, va);
f01011aa:	83 c4 08             	add    $0x8,%esp
f01011ad:	56                   	push   %esi
f01011ae:	53                   	push   %ebx
f01011af:	e8 87 ff ff ff       	call   f010113b <tlb_invalidate>
f01011b4:	83 c4 10             	add    $0x10,%esp
}
f01011b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01011ba:	5b                   	pop    %ebx
f01011bb:	5e                   	pop    %esi
f01011bc:	5d                   	pop    %ebp
f01011bd:	c3                   	ret    

f01011be <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01011be:	55                   	push   %ebp
f01011bf:	89 e5                	mov    %esp,%ebp
f01011c1:	57                   	push   %edi
f01011c2:	56                   	push   %esi
f01011c3:	53                   	push   %ebx
f01011c4:	83 ec 10             	sub    $0x10,%esp
f01011c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01011ca:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1);	//create on demand
f01011cd:	6a 01                	push   $0x1
f01011cf:	57                   	push   %edi
f01011d0:	ff 75 08             	pushl  0x8(%ebp)
f01011d3:	e8 e2 fd ff ff       	call   f0100fba <pgdir_walk>
	if (!pte) 	//page table not allocated
f01011d8:	83 c4 10             	add    $0x10,%esp
f01011db:	85 c0                	test   %eax,%eax
f01011dd:	74 38                	je     f0101217 <page_insert+0x59>
f01011df:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;	
	//increase ref count to avoid the corner case that pp is freed before it is inserted.
	pp->pp_ref++;	
f01011e1:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P) 	//page colides, tle is invalidated in page_remove
f01011e6:	f6 00 01             	testb  $0x1,(%eax)
f01011e9:	74 0f                	je     f01011fa <page_insert+0x3c>
		page_remove(pgdir, va);
f01011eb:	83 ec 08             	sub    $0x8,%esp
f01011ee:	57                   	push   %edi
f01011ef:	ff 75 08             	pushl  0x8(%ebp)
f01011f2:	e8 79 ff ff ff       	call   f0101170 <page_remove>
f01011f7:	83 c4 10             	add    $0x10,%esp
	*pte = page2pa(pp) | perm | PTE_P;
f01011fa:	2b 1d 10 af 22 f0    	sub    0xf022af10,%ebx
f0101200:	c1 fb 03             	sar    $0x3,%ebx
f0101203:	c1 e3 0c             	shl    $0xc,%ebx
f0101206:	8b 45 14             	mov    0x14(%ebp),%eax
f0101209:	83 c8 01             	or     $0x1,%eax
f010120c:	09 c3                	or     %eax,%ebx
f010120e:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101210:	b8 00 00 00 00       	mov    $0x0,%eax
f0101215:	eb 05                	jmp    f010121c <page_insert+0x5e>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t *pte = pgdir_walk(pgdir, va, 1);	//create on demand
	if (!pte) 	//page table not allocated
		return -E_NO_MEM;	
f0101217:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	pp->pp_ref++;	
	if (*pte & PTE_P) 	//page colides, tle is invalidated in page_remove
		page_remove(pgdir, va);
	*pte = page2pa(pp) | perm | PTE_P;
	return 0;
}
f010121c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010121f:	5b                   	pop    %ebx
f0101220:	5e                   	pop    %esi
f0101221:	5f                   	pop    %edi
f0101222:	5d                   	pop    %ebp
f0101223:	c3                   	ret    

f0101224 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101224:	55                   	push   %ebp
f0101225:	89 e5                	mov    %esp,%ebp
f0101227:	53                   	push   %ebx
f0101228:	83 ec 04             	sub    $0x4,%esp
f010122b:	8b 45 08             	mov    0x8(%ebp),%eax
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	//panic("mmio_map_region not implemented");

	size = ROUNDUP(pa+size, PGSIZE);
f010122e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101231:	8d 9c 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%ebx
    pa = ROUNDDOWN(pa, PGSIZE);
f0101238:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    size -= pa;
f010123d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0101243:	29 c3                	sub    %eax,%ebx
    if (base+size >= MMIOLIM) panic("not enough memory");
f0101245:	8b 15 00 f3 11 f0    	mov    0xf011f300,%edx
f010124b:	8d 0c 13             	lea    (%ebx,%edx,1),%ecx
f010124e:	81 f9 ff ff bf ef    	cmp    $0xefbfffff,%ecx
f0101254:	76 17                	jbe    f010126d <mmio_map_region+0x49>
f0101256:	83 ec 04             	sub    $0x4,%esp
f0101259:	68 fe 63 10 f0       	push   $0xf01063fe
f010125e:	68 65 02 00 00       	push   $0x265
f0101263:	68 10 63 10 f0       	push   $0xf0106310
f0101268:	e8 d3 ed ff ff       	call   f0100040 <_panic>
    boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f010126d:	83 ec 08             	sub    $0x8,%esp
f0101270:	6a 1a                	push   $0x1a
f0101272:	50                   	push   %eax
f0101273:	89 d9                	mov    %ebx,%ecx
f0101275:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
f010127a:	e8 ce fd ff ff       	call   f010104d <boot_map_region>
    base += size;
f010127f:	a1 00 f3 11 f0       	mov    0xf011f300,%eax
f0101284:	01 c3                	add    %eax,%ebx
f0101286:	89 1d 00 f3 11 f0    	mov    %ebx,0xf011f300
    return (void*) (base - size);
}
f010128c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010128f:	c9                   	leave  
f0101290:	c3                   	ret    

f0101291 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101291:	55                   	push   %ebp
f0101292:	89 e5                	mov    %esp,%ebp
f0101294:	57                   	push   %edi
f0101295:	56                   	push   %esi
f0101296:	53                   	push   %ebx
f0101297:	83 ec 48             	sub    $0x48,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010129a:	6a 15                	push   $0x15
f010129c:	e8 68 22 00 00       	call   f0103509 <mc146818_read>
f01012a1:	89 c3                	mov    %eax,%ebx
f01012a3:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01012aa:	e8 5a 22 00 00       	call   f0103509 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01012af:	c1 e0 08             	shl    $0x8,%eax
f01012b2:	09 d8                	or     %ebx,%eax
f01012b4:	c1 e0 0a             	shl    $0xa,%eax
f01012b7:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01012bd:	85 c0                	test   %eax,%eax
f01012bf:	0f 48 c2             	cmovs  %edx,%eax
f01012c2:	c1 f8 0c             	sar    $0xc,%eax
f01012c5:	a3 44 a2 22 f0       	mov    %eax,0xf022a244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01012ca:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01012d1:	e8 33 22 00 00       	call   f0103509 <mc146818_read>
f01012d6:	89 c3                	mov    %eax,%ebx
f01012d8:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01012df:	e8 25 22 00 00       	call   f0103509 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01012e4:	c1 e0 08             	shl    $0x8,%eax
f01012e7:	09 d8                	or     %ebx,%eax
f01012e9:	c1 e0 0a             	shl    $0xa,%eax
f01012ec:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01012f2:	83 c4 10             	add    $0x10,%esp
f01012f5:	85 c0                	test   %eax,%eax
f01012f7:	0f 48 c2             	cmovs  %edx,%eax
f01012fa:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01012fd:	85 c0                	test   %eax,%eax
f01012ff:	74 0e                	je     f010130f <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101301:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101307:	89 15 08 af 22 f0    	mov    %edx,0xf022af08
f010130d:	eb 0c                	jmp    f010131b <mem_init+0x8a>
	else
		npages = npages_basemem;
f010130f:	8b 15 44 a2 22 f0    	mov    0xf022a244,%edx
f0101315:	89 15 08 af 22 f0    	mov    %edx,0xf022af08

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010131b:	c1 e0 0c             	shl    $0xc,%eax
f010131e:	c1 e8 0a             	shr    $0xa,%eax
f0101321:	50                   	push   %eax
f0101322:	a1 44 a2 22 f0       	mov    0xf022a244,%eax
f0101327:	c1 e0 0c             	shl    $0xc,%eax
f010132a:	c1 e8 0a             	shr    $0xa,%eax
f010132d:	50                   	push   %eax
f010132e:	a1 08 af 22 f0       	mov    0xf022af08,%eax
f0101333:	c1 e0 0c             	shl    $0xc,%eax
f0101336:	c1 e8 0a             	shr    $0xa,%eax
f0101339:	50                   	push   %eax
f010133a:	68 fc 67 10 f0       	push   $0xf01067fc
f010133f:	e8 44 23 00 00       	call   f0103688 <cprintf>
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.

	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101344:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101349:	e8 58 f7 ff ff       	call   f0100aa6 <boot_alloc>
f010134e:	a3 0c af 22 f0       	mov    %eax,0xf022af0c
	memset(kern_pgdir, 0, PGSIZE);
f0101353:	83 c4 0c             	add    $0xc,%esp
f0101356:	68 00 10 00 00       	push   $0x1000
f010135b:	6a 00                	push   $0x0
f010135d:	50                   	push   %eax
f010135e:	e8 28 3d 00 00       	call   f010508b <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101363:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101368:	83 c4 10             	add    $0x10,%esp
f010136b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101370:	77 15                	ja     f0101387 <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101372:	50                   	push   %eax
f0101373:	68 88 5d 10 f0       	push   $0xf0105d88
f0101378:	68 93 00 00 00       	push   $0x93
f010137d:	68 10 63 10 f0       	push   $0xf0106310
f0101382:	e8 b9 ec ff ff       	call   f0100040 <_panic>
f0101387:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010138d:	83 ca 05             	or     $0x5,%edx
f0101390:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo) * npages);
f0101396:	a1 08 af 22 f0       	mov    0xf022af08,%eax
f010139b:	c1 e0 03             	shl    $0x3,%eax
f010139e:	e8 03 f7 ff ff       	call   f0100aa6 <boot_alloc>
f01013a3:	a3 10 af 22 f0       	mov    %eax,0xf022af10

	cprintf("npages: %d\n", npages);
f01013a8:	83 ec 08             	sub    $0x8,%esp
f01013ab:	ff 35 08 af 22 f0    	pushl  0xf022af08
f01013b1:	68 10 64 10 f0       	push   $0xf0106410
f01013b6:	e8 cd 22 00 00       	call   f0103688 <cprintf>
	cprintf("npages_basemem: %d\n", npages_basemem);
f01013bb:	83 c4 08             	add    $0x8,%esp
f01013be:	ff 35 44 a2 22 f0    	pushl  0xf022a244
f01013c4:	68 1c 64 10 f0       	push   $0xf010641c
f01013c9:	e8 ba 22 00 00       	call   f0103688 <cprintf>
	cprintf("pages: %x\n", pages);
f01013ce:	83 c4 08             	add    $0x8,%esp
f01013d1:	ff 35 10 af 22 f0    	pushl  0xf022af10
f01013d7:	68 30 64 10 f0       	push   $0xf0106430
f01013dc:	e8 a7 22 00 00       	call   f0103688 <cprintf>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *) boot_alloc(sizeof(struct Env) * NENV);
f01013e1:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01013e6:	e8 bb f6 ff ff       	call   f0100aa6 <boot_alloc>
f01013eb:	a3 48 a2 22 f0       	mov    %eax,0xf022a248
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01013f0:	e8 8f fa ff ff       	call   f0100e84 <page_init>

	check_page_free_list(1);
f01013f5:	b8 01 00 00 00       	mov    $0x1,%eax
f01013fa:	e8 83 f7 ff ff       	call   f0100b82 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01013ff:	83 c4 10             	add    $0x10,%esp
f0101402:	83 3d 10 af 22 f0 00 	cmpl   $0x0,0xf022af10
f0101409:	75 17                	jne    f0101422 <mem_init+0x191>
		panic("'pages' is a null pointer!");
f010140b:	83 ec 04             	sub    $0x4,%esp
f010140e:	68 3b 64 10 f0       	push   $0xf010643b
f0101413:	68 f9 02 00 00       	push   $0x2f9
f0101418:	68 10 63 10 f0       	push   $0xf0106310
f010141d:	e8 1e ec ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101422:	a1 40 a2 22 f0       	mov    0xf022a240,%eax
f0101427:	bb 00 00 00 00       	mov    $0x0,%ebx
f010142c:	eb 05                	jmp    f0101433 <mem_init+0x1a2>
		++nfree;
f010142e:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101431:	8b 00                	mov    (%eax),%eax
f0101433:	85 c0                	test   %eax,%eax
f0101435:	75 f7                	jne    f010142e <mem_init+0x19d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101437:	83 ec 0c             	sub    $0xc,%esp
f010143a:	6a 00                	push   $0x0
f010143c:	e8 d9 fa ff ff       	call   f0100f1a <page_alloc>
f0101441:	89 c7                	mov    %eax,%edi
f0101443:	83 c4 10             	add    $0x10,%esp
f0101446:	85 c0                	test   %eax,%eax
f0101448:	75 19                	jne    f0101463 <mem_init+0x1d2>
f010144a:	68 56 64 10 f0       	push   $0xf0106456
f010144f:	68 36 63 10 f0       	push   $0xf0106336
f0101454:	68 01 03 00 00       	push   $0x301
f0101459:	68 10 63 10 f0       	push   $0xf0106310
f010145e:	e8 dd eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101463:	83 ec 0c             	sub    $0xc,%esp
f0101466:	6a 00                	push   $0x0
f0101468:	e8 ad fa ff ff       	call   f0100f1a <page_alloc>
f010146d:	89 c6                	mov    %eax,%esi
f010146f:	83 c4 10             	add    $0x10,%esp
f0101472:	85 c0                	test   %eax,%eax
f0101474:	75 19                	jne    f010148f <mem_init+0x1fe>
f0101476:	68 6c 64 10 f0       	push   $0xf010646c
f010147b:	68 36 63 10 f0       	push   $0xf0106336
f0101480:	68 02 03 00 00       	push   $0x302
f0101485:	68 10 63 10 f0       	push   $0xf0106310
f010148a:	e8 b1 eb ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010148f:	83 ec 0c             	sub    $0xc,%esp
f0101492:	6a 00                	push   $0x0
f0101494:	e8 81 fa ff ff       	call   f0100f1a <page_alloc>
f0101499:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010149c:	83 c4 10             	add    $0x10,%esp
f010149f:	85 c0                	test   %eax,%eax
f01014a1:	75 19                	jne    f01014bc <mem_init+0x22b>
f01014a3:	68 82 64 10 f0       	push   $0xf0106482
f01014a8:	68 36 63 10 f0       	push   $0xf0106336
f01014ad:	68 03 03 00 00       	push   $0x303
f01014b2:	68 10 63 10 f0       	push   $0xf0106310
f01014b7:	e8 84 eb ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01014bc:	39 f7                	cmp    %esi,%edi
f01014be:	75 19                	jne    f01014d9 <mem_init+0x248>
f01014c0:	68 98 64 10 f0       	push   $0xf0106498
f01014c5:	68 36 63 10 f0       	push   $0xf0106336
f01014ca:	68 06 03 00 00       	push   $0x306
f01014cf:	68 10 63 10 f0       	push   $0xf0106310
f01014d4:	e8 67 eb ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014dc:	39 c6                	cmp    %eax,%esi
f01014de:	74 04                	je     f01014e4 <mem_init+0x253>
f01014e0:	39 c7                	cmp    %eax,%edi
f01014e2:	75 19                	jne    f01014fd <mem_init+0x26c>
f01014e4:	68 38 68 10 f0       	push   $0xf0106838
f01014e9:	68 36 63 10 f0       	push   $0xf0106336
f01014ee:	68 07 03 00 00       	push   $0x307
f01014f3:	68 10 63 10 f0       	push   $0xf0106310
f01014f8:	e8 43 eb ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014fd:	8b 0d 10 af 22 f0    	mov    0xf022af10,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101503:	8b 15 08 af 22 f0    	mov    0xf022af08,%edx
f0101509:	c1 e2 0c             	shl    $0xc,%edx
f010150c:	89 f8                	mov    %edi,%eax
f010150e:	29 c8                	sub    %ecx,%eax
f0101510:	c1 f8 03             	sar    $0x3,%eax
f0101513:	c1 e0 0c             	shl    $0xc,%eax
f0101516:	39 d0                	cmp    %edx,%eax
f0101518:	72 19                	jb     f0101533 <mem_init+0x2a2>
f010151a:	68 aa 64 10 f0       	push   $0xf01064aa
f010151f:	68 36 63 10 f0       	push   $0xf0106336
f0101524:	68 08 03 00 00       	push   $0x308
f0101529:	68 10 63 10 f0       	push   $0xf0106310
f010152e:	e8 0d eb ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101533:	89 f0                	mov    %esi,%eax
f0101535:	29 c8                	sub    %ecx,%eax
f0101537:	c1 f8 03             	sar    $0x3,%eax
f010153a:	c1 e0 0c             	shl    $0xc,%eax
f010153d:	39 c2                	cmp    %eax,%edx
f010153f:	77 19                	ja     f010155a <mem_init+0x2c9>
f0101541:	68 c7 64 10 f0       	push   $0xf01064c7
f0101546:	68 36 63 10 f0       	push   $0xf0106336
f010154b:	68 09 03 00 00       	push   $0x309
f0101550:	68 10 63 10 f0       	push   $0xf0106310
f0101555:	e8 e6 ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010155a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010155d:	29 c8                	sub    %ecx,%eax
f010155f:	c1 f8 03             	sar    $0x3,%eax
f0101562:	c1 e0 0c             	shl    $0xc,%eax
f0101565:	39 c2                	cmp    %eax,%edx
f0101567:	77 19                	ja     f0101582 <mem_init+0x2f1>
f0101569:	68 e4 64 10 f0       	push   $0xf01064e4
f010156e:	68 36 63 10 f0       	push   $0xf0106336
f0101573:	68 0a 03 00 00       	push   $0x30a
f0101578:	68 10 63 10 f0       	push   $0xf0106310
f010157d:	e8 be ea ff ff       	call   f0100040 <_panic>


	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101582:	a1 40 a2 22 f0       	mov    0xf022a240,%eax
f0101587:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010158a:	c7 05 40 a2 22 f0 00 	movl   $0x0,0xf022a240
f0101591:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101594:	83 ec 0c             	sub    $0xc,%esp
f0101597:	6a 00                	push   $0x0
f0101599:	e8 7c f9 ff ff       	call   f0100f1a <page_alloc>
f010159e:	83 c4 10             	add    $0x10,%esp
f01015a1:	85 c0                	test   %eax,%eax
f01015a3:	74 19                	je     f01015be <mem_init+0x32d>
f01015a5:	68 01 65 10 f0       	push   $0xf0106501
f01015aa:	68 36 63 10 f0       	push   $0xf0106336
f01015af:	68 12 03 00 00       	push   $0x312
f01015b4:	68 10 63 10 f0       	push   $0xf0106310
f01015b9:	e8 82 ea ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01015be:	83 ec 0c             	sub    $0xc,%esp
f01015c1:	57                   	push   %edi
f01015c2:	e8 bd f9 ff ff       	call   f0100f84 <page_free>
	page_free(pp1);
f01015c7:	89 34 24             	mov    %esi,(%esp)
f01015ca:	e8 b5 f9 ff ff       	call   f0100f84 <page_free>
	page_free(pp2);
f01015cf:	83 c4 04             	add    $0x4,%esp
f01015d2:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015d5:	e8 aa f9 ff ff       	call   f0100f84 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015e1:	e8 34 f9 ff ff       	call   f0100f1a <page_alloc>
f01015e6:	89 c6                	mov    %eax,%esi
f01015e8:	83 c4 10             	add    $0x10,%esp
f01015eb:	85 c0                	test   %eax,%eax
f01015ed:	75 19                	jne    f0101608 <mem_init+0x377>
f01015ef:	68 56 64 10 f0       	push   $0xf0106456
f01015f4:	68 36 63 10 f0       	push   $0xf0106336
f01015f9:	68 19 03 00 00       	push   $0x319
f01015fe:	68 10 63 10 f0       	push   $0xf0106310
f0101603:	e8 38 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101608:	83 ec 0c             	sub    $0xc,%esp
f010160b:	6a 00                	push   $0x0
f010160d:	e8 08 f9 ff ff       	call   f0100f1a <page_alloc>
f0101612:	89 c7                	mov    %eax,%edi
f0101614:	83 c4 10             	add    $0x10,%esp
f0101617:	85 c0                	test   %eax,%eax
f0101619:	75 19                	jne    f0101634 <mem_init+0x3a3>
f010161b:	68 6c 64 10 f0       	push   $0xf010646c
f0101620:	68 36 63 10 f0       	push   $0xf0106336
f0101625:	68 1a 03 00 00       	push   $0x31a
f010162a:	68 10 63 10 f0       	push   $0xf0106310
f010162f:	e8 0c ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101634:	83 ec 0c             	sub    $0xc,%esp
f0101637:	6a 00                	push   $0x0
f0101639:	e8 dc f8 ff ff       	call   f0100f1a <page_alloc>
f010163e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101641:	83 c4 10             	add    $0x10,%esp
f0101644:	85 c0                	test   %eax,%eax
f0101646:	75 19                	jne    f0101661 <mem_init+0x3d0>
f0101648:	68 82 64 10 f0       	push   $0xf0106482
f010164d:	68 36 63 10 f0       	push   $0xf0106336
f0101652:	68 1b 03 00 00       	push   $0x31b
f0101657:	68 10 63 10 f0       	push   $0xf0106310
f010165c:	e8 df e9 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101661:	39 fe                	cmp    %edi,%esi
f0101663:	75 19                	jne    f010167e <mem_init+0x3ed>
f0101665:	68 98 64 10 f0       	push   $0xf0106498
f010166a:	68 36 63 10 f0       	push   $0xf0106336
f010166f:	68 1d 03 00 00       	push   $0x31d
f0101674:	68 10 63 10 f0       	push   $0xf0106310
f0101679:	e8 c2 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010167e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101681:	39 c7                	cmp    %eax,%edi
f0101683:	74 04                	je     f0101689 <mem_init+0x3f8>
f0101685:	39 c6                	cmp    %eax,%esi
f0101687:	75 19                	jne    f01016a2 <mem_init+0x411>
f0101689:	68 38 68 10 f0       	push   $0xf0106838
f010168e:	68 36 63 10 f0       	push   $0xf0106336
f0101693:	68 1e 03 00 00       	push   $0x31e
f0101698:	68 10 63 10 f0       	push   $0xf0106310
f010169d:	e8 9e e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01016a2:	83 ec 0c             	sub    $0xc,%esp
f01016a5:	6a 00                	push   $0x0
f01016a7:	e8 6e f8 ff ff       	call   f0100f1a <page_alloc>
f01016ac:	83 c4 10             	add    $0x10,%esp
f01016af:	85 c0                	test   %eax,%eax
f01016b1:	74 19                	je     f01016cc <mem_init+0x43b>
f01016b3:	68 01 65 10 f0       	push   $0xf0106501
f01016b8:	68 36 63 10 f0       	push   $0xf0106336
f01016bd:	68 1f 03 00 00       	push   $0x31f
f01016c2:	68 10 63 10 f0       	push   $0xf0106310
f01016c7:	e8 74 e9 ff ff       	call   f0100040 <_panic>
f01016cc:	89 f0                	mov    %esi,%eax
f01016ce:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f01016d4:	c1 f8 03             	sar    $0x3,%eax
f01016d7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016da:	89 c2                	mov    %eax,%edx
f01016dc:	c1 ea 0c             	shr    $0xc,%edx
f01016df:	3b 15 08 af 22 f0    	cmp    0xf022af08,%edx
f01016e5:	72 12                	jb     f01016f9 <mem_init+0x468>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016e7:	50                   	push   %eax
f01016e8:	68 64 5d 10 f0       	push   $0xf0105d64
f01016ed:	6a 58                	push   $0x58
f01016ef:	68 1c 63 10 f0       	push   $0xf010631c
f01016f4:	e8 47 e9 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01016f9:	83 ec 04             	sub    $0x4,%esp
f01016fc:	68 00 10 00 00       	push   $0x1000
f0101701:	6a 01                	push   $0x1
f0101703:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101708:	50                   	push   %eax
f0101709:	e8 7d 39 00 00       	call   f010508b <memset>
	page_free(pp0);
f010170e:	89 34 24             	mov    %esi,(%esp)
f0101711:	e8 6e f8 ff ff       	call   f0100f84 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101716:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010171d:	e8 f8 f7 ff ff       	call   f0100f1a <page_alloc>
f0101722:	83 c4 10             	add    $0x10,%esp
f0101725:	85 c0                	test   %eax,%eax
f0101727:	75 19                	jne    f0101742 <mem_init+0x4b1>
f0101729:	68 10 65 10 f0       	push   $0xf0106510
f010172e:	68 36 63 10 f0       	push   $0xf0106336
f0101733:	68 24 03 00 00       	push   $0x324
f0101738:	68 10 63 10 f0       	push   $0xf0106310
f010173d:	e8 fe e8 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101742:	39 c6                	cmp    %eax,%esi
f0101744:	74 19                	je     f010175f <mem_init+0x4ce>
f0101746:	68 2e 65 10 f0       	push   $0xf010652e
f010174b:	68 36 63 10 f0       	push   $0xf0106336
f0101750:	68 25 03 00 00       	push   $0x325
f0101755:	68 10 63 10 f0       	push   $0xf0106310
f010175a:	e8 e1 e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010175f:	89 f0                	mov    %esi,%eax
f0101761:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f0101767:	c1 f8 03             	sar    $0x3,%eax
f010176a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010176d:	89 c2                	mov    %eax,%edx
f010176f:	c1 ea 0c             	shr    $0xc,%edx
f0101772:	3b 15 08 af 22 f0    	cmp    0xf022af08,%edx
f0101778:	72 12                	jb     f010178c <mem_init+0x4fb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010177a:	50                   	push   %eax
f010177b:	68 64 5d 10 f0       	push   $0xf0105d64
f0101780:	6a 58                	push   $0x58
f0101782:	68 1c 63 10 f0       	push   $0xf010631c
f0101787:	e8 b4 e8 ff ff       	call   f0100040 <_panic>
f010178c:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101792:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101798:	80 38 00             	cmpb   $0x0,(%eax)
f010179b:	74 19                	je     f01017b6 <mem_init+0x525>
f010179d:	68 3e 65 10 f0       	push   $0xf010653e
f01017a2:	68 36 63 10 f0       	push   $0xf0106336
f01017a7:	68 28 03 00 00       	push   $0x328
f01017ac:	68 10 63 10 f0       	push   $0xf0106310
f01017b1:	e8 8a e8 ff ff       	call   f0100040 <_panic>
f01017b6:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01017b9:	39 d0                	cmp    %edx,%eax
f01017bb:	75 db                	jne    f0101798 <mem_init+0x507>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01017bd:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01017c0:	a3 40 a2 22 f0       	mov    %eax,0xf022a240

	// free the pages we took
	page_free(pp0);
f01017c5:	83 ec 0c             	sub    $0xc,%esp
f01017c8:	56                   	push   %esi
f01017c9:	e8 b6 f7 ff ff       	call   f0100f84 <page_free>
	page_free(pp1);
f01017ce:	89 3c 24             	mov    %edi,(%esp)
f01017d1:	e8 ae f7 ff ff       	call   f0100f84 <page_free>
	page_free(pp2);
f01017d6:	83 c4 04             	add    $0x4,%esp
f01017d9:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017dc:	e8 a3 f7 ff ff       	call   f0100f84 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017e1:	a1 40 a2 22 f0       	mov    0xf022a240,%eax
f01017e6:	83 c4 10             	add    $0x10,%esp
f01017e9:	eb 05                	jmp    f01017f0 <mem_init+0x55f>
		--nfree;
f01017eb:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017ee:	8b 00                	mov    (%eax),%eax
f01017f0:	85 c0                	test   %eax,%eax
f01017f2:	75 f7                	jne    f01017eb <mem_init+0x55a>
		--nfree;
	assert(nfree == 0);
f01017f4:	85 db                	test   %ebx,%ebx
f01017f6:	74 19                	je     f0101811 <mem_init+0x580>
f01017f8:	68 48 65 10 f0       	push   $0xf0106548
f01017fd:	68 36 63 10 f0       	push   $0xf0106336
f0101802:	68 35 03 00 00       	push   $0x335
f0101807:	68 10 63 10 f0       	push   $0xf0106310
f010180c:	e8 2f e8 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101811:	83 ec 0c             	sub    $0xc,%esp
f0101814:	68 58 68 10 f0       	push   $0xf0106858
f0101819:	e8 6a 1e 00 00       	call   f0103688 <cprintf>
	// or page_insert
	page_init();

	check_page_free_list(1);
	check_page_alloc();
	cprintf("so far so good\n");
f010181e:	c7 04 24 53 65 10 f0 	movl   $0xf0106553,(%esp)
f0101825:	e8 5e 1e 00 00       	call   f0103688 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010182a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101831:	e8 e4 f6 ff ff       	call   f0100f1a <page_alloc>
f0101836:	89 c6                	mov    %eax,%esi
f0101838:	83 c4 10             	add    $0x10,%esp
f010183b:	85 c0                	test   %eax,%eax
f010183d:	75 19                	jne    f0101858 <mem_init+0x5c7>
f010183f:	68 56 64 10 f0       	push   $0xf0106456
f0101844:	68 36 63 10 f0       	push   $0xf0106336
f0101849:	68 9b 03 00 00       	push   $0x39b
f010184e:	68 10 63 10 f0       	push   $0xf0106310
f0101853:	e8 e8 e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101858:	83 ec 0c             	sub    $0xc,%esp
f010185b:	6a 00                	push   $0x0
f010185d:	e8 b8 f6 ff ff       	call   f0100f1a <page_alloc>
f0101862:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101865:	83 c4 10             	add    $0x10,%esp
f0101868:	85 c0                	test   %eax,%eax
f010186a:	75 19                	jne    f0101885 <mem_init+0x5f4>
f010186c:	68 6c 64 10 f0       	push   $0xf010646c
f0101871:	68 36 63 10 f0       	push   $0xf0106336
f0101876:	68 9c 03 00 00       	push   $0x39c
f010187b:	68 10 63 10 f0       	push   $0xf0106310
f0101880:	e8 bb e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101885:	83 ec 0c             	sub    $0xc,%esp
f0101888:	6a 00                	push   $0x0
f010188a:	e8 8b f6 ff ff       	call   f0100f1a <page_alloc>
f010188f:	89 c3                	mov    %eax,%ebx
f0101891:	83 c4 10             	add    $0x10,%esp
f0101894:	85 c0                	test   %eax,%eax
f0101896:	75 19                	jne    f01018b1 <mem_init+0x620>
f0101898:	68 82 64 10 f0       	push   $0xf0106482
f010189d:	68 36 63 10 f0       	push   $0xf0106336
f01018a2:	68 9d 03 00 00       	push   $0x39d
f01018a7:	68 10 63 10 f0       	push   $0xf0106310
f01018ac:	e8 8f e7 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018b1:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01018b4:	75 19                	jne    f01018cf <mem_init+0x63e>
f01018b6:	68 98 64 10 f0       	push   $0xf0106498
f01018bb:	68 36 63 10 f0       	push   $0xf0106336
f01018c0:	68 a0 03 00 00       	push   $0x3a0
f01018c5:	68 10 63 10 f0       	push   $0xf0106310
f01018ca:	e8 71 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018cf:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01018d2:	74 04                	je     f01018d8 <mem_init+0x647>
f01018d4:	39 c6                	cmp    %eax,%esi
f01018d6:	75 19                	jne    f01018f1 <mem_init+0x660>
f01018d8:	68 38 68 10 f0       	push   $0xf0106838
f01018dd:	68 36 63 10 f0       	push   $0xf0106336
f01018e2:	68 a1 03 00 00       	push   $0x3a1
f01018e7:	68 10 63 10 f0       	push   $0xf0106310
f01018ec:	e8 4f e7 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018f1:	a1 40 a2 22 f0       	mov    0xf022a240,%eax
f01018f6:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01018f9:	c7 05 40 a2 22 f0 00 	movl   $0x0,0xf022a240
f0101900:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101903:	83 ec 0c             	sub    $0xc,%esp
f0101906:	6a 00                	push   $0x0
f0101908:	e8 0d f6 ff ff       	call   f0100f1a <page_alloc>
f010190d:	83 c4 10             	add    $0x10,%esp
f0101910:	85 c0                	test   %eax,%eax
f0101912:	74 19                	je     f010192d <mem_init+0x69c>
f0101914:	68 01 65 10 f0       	push   $0xf0106501
f0101919:	68 36 63 10 f0       	push   $0xf0106336
f010191e:	68 a8 03 00 00       	push   $0x3a8
f0101923:	68 10 63 10 f0       	push   $0xf0106310
f0101928:	e8 13 e7 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010192d:	83 ec 04             	sub    $0x4,%esp
f0101930:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101933:	50                   	push   %eax
f0101934:	6a 00                	push   $0x0
f0101936:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f010193c:	e8 94 f7 ff ff       	call   f01010d5 <page_lookup>
f0101941:	83 c4 10             	add    $0x10,%esp
f0101944:	85 c0                	test   %eax,%eax
f0101946:	74 19                	je     f0101961 <mem_init+0x6d0>
f0101948:	68 78 68 10 f0       	push   $0xf0106878
f010194d:	68 36 63 10 f0       	push   $0xf0106336
f0101952:	68 ab 03 00 00       	push   $0x3ab
f0101957:	68 10 63 10 f0       	push   $0xf0106310
f010195c:	e8 df e6 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101961:	6a 02                	push   $0x2
f0101963:	6a 00                	push   $0x0
f0101965:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101968:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f010196e:	e8 4b f8 ff ff       	call   f01011be <page_insert>
f0101973:	83 c4 10             	add    $0x10,%esp
f0101976:	85 c0                	test   %eax,%eax
f0101978:	78 19                	js     f0101993 <mem_init+0x702>
f010197a:	68 b0 68 10 f0       	push   $0xf01068b0
f010197f:	68 36 63 10 f0       	push   $0xf0106336
f0101984:	68 ae 03 00 00       	push   $0x3ae
f0101989:	68 10 63 10 f0       	push   $0xf0106310
f010198e:	e8 ad e6 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101993:	83 ec 0c             	sub    $0xc,%esp
f0101996:	56                   	push   %esi
f0101997:	e8 e8 f5 ff ff       	call   f0100f84 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010199c:	6a 02                	push   $0x2
f010199e:	6a 00                	push   $0x0
f01019a0:	ff 75 d4             	pushl  -0x2c(%ebp)
f01019a3:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f01019a9:	e8 10 f8 ff ff       	call   f01011be <page_insert>
f01019ae:	83 c4 20             	add    $0x20,%esp
f01019b1:	85 c0                	test   %eax,%eax
f01019b3:	74 19                	je     f01019ce <mem_init+0x73d>
f01019b5:	68 e0 68 10 f0       	push   $0xf01068e0
f01019ba:	68 36 63 10 f0       	push   $0xf0106336
f01019bf:	68 b2 03 00 00       	push   $0x3b2
f01019c4:	68 10 63 10 f0       	push   $0xf0106310
f01019c9:	e8 72 e6 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019ce:	8b 3d 0c af 22 f0    	mov    0xf022af0c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019d4:	a1 10 af 22 f0       	mov    0xf022af10,%eax
f01019d9:	89 c1                	mov    %eax,%ecx
f01019db:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01019de:	8b 17                	mov    (%edi),%edx
f01019e0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019e6:	89 f0                	mov    %esi,%eax
f01019e8:	29 c8                	sub    %ecx,%eax
f01019ea:	c1 f8 03             	sar    $0x3,%eax
f01019ed:	c1 e0 0c             	shl    $0xc,%eax
f01019f0:	39 c2                	cmp    %eax,%edx
f01019f2:	74 19                	je     f0101a0d <mem_init+0x77c>
f01019f4:	68 10 69 10 f0       	push   $0xf0106910
f01019f9:	68 36 63 10 f0       	push   $0xf0106336
f01019fe:	68 b3 03 00 00       	push   $0x3b3
f0101a03:	68 10 63 10 f0       	push   $0xf0106310
f0101a08:	e8 33 e6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a0d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a12:	89 f8                	mov    %edi,%eax
f0101a14:	e8 05 f1 ff ff       	call   f0100b1e <check_va2pa>
f0101a19:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101a1c:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101a1f:	c1 fa 03             	sar    $0x3,%edx
f0101a22:	c1 e2 0c             	shl    $0xc,%edx
f0101a25:	39 d0                	cmp    %edx,%eax
f0101a27:	74 19                	je     f0101a42 <mem_init+0x7b1>
f0101a29:	68 38 69 10 f0       	push   $0xf0106938
f0101a2e:	68 36 63 10 f0       	push   $0xf0106336
f0101a33:	68 b4 03 00 00       	push   $0x3b4
f0101a38:	68 10 63 10 f0       	push   $0xf0106310
f0101a3d:	e8 fe e5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101a42:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a45:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a4a:	74 19                	je     f0101a65 <mem_init+0x7d4>
f0101a4c:	68 63 65 10 f0       	push   $0xf0106563
f0101a51:	68 36 63 10 f0       	push   $0xf0106336
f0101a56:	68 b5 03 00 00       	push   $0x3b5
f0101a5b:	68 10 63 10 f0       	push   $0xf0106310
f0101a60:	e8 db e5 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101a65:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a6a:	74 19                	je     f0101a85 <mem_init+0x7f4>
f0101a6c:	68 74 65 10 f0       	push   $0xf0106574
f0101a71:	68 36 63 10 f0       	push   $0xf0106336
f0101a76:	68 b6 03 00 00       	push   $0x3b6
f0101a7b:	68 10 63 10 f0       	push   $0xf0106310
f0101a80:	e8 bb e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a85:	6a 02                	push   $0x2
f0101a87:	68 00 10 00 00       	push   $0x1000
f0101a8c:	53                   	push   %ebx
f0101a8d:	57                   	push   %edi
f0101a8e:	e8 2b f7 ff ff       	call   f01011be <page_insert>
f0101a93:	83 c4 10             	add    $0x10,%esp
f0101a96:	85 c0                	test   %eax,%eax
f0101a98:	74 19                	je     f0101ab3 <mem_init+0x822>
f0101a9a:	68 68 69 10 f0       	push   $0xf0106968
f0101a9f:	68 36 63 10 f0       	push   $0xf0106336
f0101aa4:	68 b9 03 00 00       	push   $0x3b9
f0101aa9:	68 10 63 10 f0       	push   $0xf0106310
f0101aae:	e8 8d e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ab3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ab8:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
f0101abd:	e8 5c f0 ff ff       	call   f0100b1e <check_va2pa>
f0101ac2:	89 da                	mov    %ebx,%edx
f0101ac4:	2b 15 10 af 22 f0    	sub    0xf022af10,%edx
f0101aca:	c1 fa 03             	sar    $0x3,%edx
f0101acd:	c1 e2 0c             	shl    $0xc,%edx
f0101ad0:	39 d0                	cmp    %edx,%eax
f0101ad2:	74 19                	je     f0101aed <mem_init+0x85c>
f0101ad4:	68 a4 69 10 f0       	push   $0xf01069a4
f0101ad9:	68 36 63 10 f0       	push   $0xf0106336
f0101ade:	68 ba 03 00 00       	push   $0x3ba
f0101ae3:	68 10 63 10 f0       	push   $0xf0106310
f0101ae8:	e8 53 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101aed:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101af2:	74 19                	je     f0101b0d <mem_init+0x87c>
f0101af4:	68 85 65 10 f0       	push   $0xf0106585
f0101af9:	68 36 63 10 f0       	push   $0xf0106336
f0101afe:	68 bb 03 00 00       	push   $0x3bb
f0101b03:	68 10 63 10 f0       	push   $0xf0106310
f0101b08:	e8 33 e5 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101b0d:	83 ec 0c             	sub    $0xc,%esp
f0101b10:	6a 00                	push   $0x0
f0101b12:	e8 03 f4 ff ff       	call   f0100f1a <page_alloc>
f0101b17:	83 c4 10             	add    $0x10,%esp
f0101b1a:	85 c0                	test   %eax,%eax
f0101b1c:	74 19                	je     f0101b37 <mem_init+0x8a6>
f0101b1e:	68 01 65 10 f0       	push   $0xf0106501
f0101b23:	68 36 63 10 f0       	push   $0xf0106336
f0101b28:	68 be 03 00 00       	push   $0x3be
f0101b2d:	68 10 63 10 f0       	push   $0xf0106310
f0101b32:	e8 09 e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b37:	6a 02                	push   $0x2
f0101b39:	68 00 10 00 00       	push   $0x1000
f0101b3e:	53                   	push   %ebx
f0101b3f:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0101b45:	e8 74 f6 ff ff       	call   f01011be <page_insert>
f0101b4a:	83 c4 10             	add    $0x10,%esp
f0101b4d:	85 c0                	test   %eax,%eax
f0101b4f:	74 19                	je     f0101b6a <mem_init+0x8d9>
f0101b51:	68 68 69 10 f0       	push   $0xf0106968
f0101b56:	68 36 63 10 f0       	push   $0xf0106336
f0101b5b:	68 c1 03 00 00       	push   $0x3c1
f0101b60:	68 10 63 10 f0       	push   $0xf0106310
f0101b65:	e8 d6 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b6a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b6f:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
f0101b74:	e8 a5 ef ff ff       	call   f0100b1e <check_va2pa>
f0101b79:	89 da                	mov    %ebx,%edx
f0101b7b:	2b 15 10 af 22 f0    	sub    0xf022af10,%edx
f0101b81:	c1 fa 03             	sar    $0x3,%edx
f0101b84:	c1 e2 0c             	shl    $0xc,%edx
f0101b87:	39 d0                	cmp    %edx,%eax
f0101b89:	74 19                	je     f0101ba4 <mem_init+0x913>
f0101b8b:	68 a4 69 10 f0       	push   $0xf01069a4
f0101b90:	68 36 63 10 f0       	push   $0xf0106336
f0101b95:	68 c2 03 00 00       	push   $0x3c2
f0101b9a:	68 10 63 10 f0       	push   $0xf0106310
f0101b9f:	e8 9c e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ba4:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ba9:	74 19                	je     f0101bc4 <mem_init+0x933>
f0101bab:	68 85 65 10 f0       	push   $0xf0106585
f0101bb0:	68 36 63 10 f0       	push   $0xf0106336
f0101bb5:	68 c3 03 00 00       	push   $0x3c3
f0101bba:	68 10 63 10 f0       	push   $0xf0106310
f0101bbf:	e8 7c e4 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101bc4:	83 ec 0c             	sub    $0xc,%esp
f0101bc7:	6a 00                	push   $0x0
f0101bc9:	e8 4c f3 ff ff       	call   f0100f1a <page_alloc>
f0101bce:	83 c4 10             	add    $0x10,%esp
f0101bd1:	85 c0                	test   %eax,%eax
f0101bd3:	74 19                	je     f0101bee <mem_init+0x95d>
f0101bd5:	68 01 65 10 f0       	push   $0xf0106501
f0101bda:	68 36 63 10 f0       	push   $0xf0106336
f0101bdf:	68 c7 03 00 00       	push   $0x3c7
f0101be4:	68 10 63 10 f0       	push   $0xf0106310
f0101be9:	e8 52 e4 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101bee:	8b 15 0c af 22 f0    	mov    0xf022af0c,%edx
f0101bf4:	8b 02                	mov    (%edx),%eax
f0101bf6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101bfb:	89 c1                	mov    %eax,%ecx
f0101bfd:	c1 e9 0c             	shr    $0xc,%ecx
f0101c00:	3b 0d 08 af 22 f0    	cmp    0xf022af08,%ecx
f0101c06:	72 15                	jb     f0101c1d <mem_init+0x98c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c08:	50                   	push   %eax
f0101c09:	68 64 5d 10 f0       	push   $0xf0105d64
f0101c0e:	68 ca 03 00 00       	push   $0x3ca
f0101c13:	68 10 63 10 f0       	push   $0xf0106310
f0101c18:	e8 23 e4 ff ff       	call   f0100040 <_panic>
f0101c1d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c22:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101c25:	83 ec 04             	sub    $0x4,%esp
f0101c28:	6a 00                	push   $0x0
f0101c2a:	68 00 10 00 00       	push   $0x1000
f0101c2f:	52                   	push   %edx
f0101c30:	e8 85 f3 ff ff       	call   f0100fba <pgdir_walk>
f0101c35:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101c38:	8d 51 04             	lea    0x4(%ecx),%edx
f0101c3b:	83 c4 10             	add    $0x10,%esp
f0101c3e:	39 d0                	cmp    %edx,%eax
f0101c40:	74 19                	je     f0101c5b <mem_init+0x9ca>
f0101c42:	68 d4 69 10 f0       	push   $0xf01069d4
f0101c47:	68 36 63 10 f0       	push   $0xf0106336
f0101c4c:	68 cb 03 00 00       	push   $0x3cb
f0101c51:	68 10 63 10 f0       	push   $0xf0106310
f0101c56:	e8 e5 e3 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101c5b:	6a 06                	push   $0x6
f0101c5d:	68 00 10 00 00       	push   $0x1000
f0101c62:	53                   	push   %ebx
f0101c63:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0101c69:	e8 50 f5 ff ff       	call   f01011be <page_insert>
f0101c6e:	83 c4 10             	add    $0x10,%esp
f0101c71:	85 c0                	test   %eax,%eax
f0101c73:	74 19                	je     f0101c8e <mem_init+0x9fd>
f0101c75:	68 14 6a 10 f0       	push   $0xf0106a14
f0101c7a:	68 36 63 10 f0       	push   $0xf0106336
f0101c7f:	68 ce 03 00 00       	push   $0x3ce
f0101c84:	68 10 63 10 f0       	push   $0xf0106310
f0101c89:	e8 b2 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c8e:	8b 3d 0c af 22 f0    	mov    0xf022af0c,%edi
f0101c94:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c99:	89 f8                	mov    %edi,%eax
f0101c9b:	e8 7e ee ff ff       	call   f0100b1e <check_va2pa>
f0101ca0:	89 da                	mov    %ebx,%edx
f0101ca2:	2b 15 10 af 22 f0    	sub    0xf022af10,%edx
f0101ca8:	c1 fa 03             	sar    $0x3,%edx
f0101cab:	c1 e2 0c             	shl    $0xc,%edx
f0101cae:	39 d0                	cmp    %edx,%eax
f0101cb0:	74 19                	je     f0101ccb <mem_init+0xa3a>
f0101cb2:	68 a4 69 10 f0       	push   $0xf01069a4
f0101cb7:	68 36 63 10 f0       	push   $0xf0106336
f0101cbc:	68 cf 03 00 00       	push   $0x3cf
f0101cc1:	68 10 63 10 f0       	push   $0xf0106310
f0101cc6:	e8 75 e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ccb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101cd0:	74 19                	je     f0101ceb <mem_init+0xa5a>
f0101cd2:	68 85 65 10 f0       	push   $0xf0106585
f0101cd7:	68 36 63 10 f0       	push   $0xf0106336
f0101cdc:	68 d0 03 00 00       	push   $0x3d0
f0101ce1:	68 10 63 10 f0       	push   $0xf0106310
f0101ce6:	e8 55 e3 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101ceb:	83 ec 04             	sub    $0x4,%esp
f0101cee:	6a 00                	push   $0x0
f0101cf0:	68 00 10 00 00       	push   $0x1000
f0101cf5:	57                   	push   %edi
f0101cf6:	e8 bf f2 ff ff       	call   f0100fba <pgdir_walk>
f0101cfb:	83 c4 10             	add    $0x10,%esp
f0101cfe:	f6 00 04             	testb  $0x4,(%eax)
f0101d01:	75 19                	jne    f0101d1c <mem_init+0xa8b>
f0101d03:	68 54 6a 10 f0       	push   $0xf0106a54
f0101d08:	68 36 63 10 f0       	push   $0xf0106336
f0101d0d:	68 d1 03 00 00       	push   $0x3d1
f0101d12:	68 10 63 10 f0       	push   $0xf0106310
f0101d17:	e8 24 e3 ff ff       	call   f0100040 <_panic>
	cprintf("pp2 %x\n", pp2);
f0101d1c:	83 ec 08             	sub    $0x8,%esp
f0101d1f:	53                   	push   %ebx
f0101d20:	68 96 65 10 f0       	push   $0xf0106596
f0101d25:	e8 5e 19 00 00       	call   f0103688 <cprintf>
	cprintf("kern_pgdir %x\n", kern_pgdir);
f0101d2a:	83 c4 08             	add    $0x8,%esp
f0101d2d:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0101d33:	68 9e 65 10 f0       	push   $0xf010659e
f0101d38:	e8 4b 19 00 00       	call   f0103688 <cprintf>
	cprintf("kern_pgdir[0] is %x\n", kern_pgdir[0]);
f0101d3d:	83 c4 08             	add    $0x8,%esp
f0101d40:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
f0101d45:	ff 30                	pushl  (%eax)
f0101d47:	68 ad 65 10 f0       	push   $0xf01065ad
f0101d4c:	e8 37 19 00 00       	call   f0103688 <cprintf>
	assert(kern_pgdir[0] & PTE_U);
f0101d51:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
f0101d56:	83 c4 10             	add    $0x10,%esp
f0101d59:	f6 00 04             	testb  $0x4,(%eax)
f0101d5c:	75 19                	jne    f0101d77 <mem_init+0xae6>
f0101d5e:	68 c2 65 10 f0       	push   $0xf01065c2
f0101d63:	68 36 63 10 f0       	push   $0xf0106336
f0101d68:	68 d5 03 00 00       	push   $0x3d5
f0101d6d:	68 10 63 10 f0       	push   $0xf0106310
f0101d72:	e8 c9 e2 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d77:	6a 02                	push   $0x2
f0101d79:	68 00 10 00 00       	push   $0x1000
f0101d7e:	53                   	push   %ebx
f0101d7f:	50                   	push   %eax
f0101d80:	e8 39 f4 ff ff       	call   f01011be <page_insert>
f0101d85:	83 c4 10             	add    $0x10,%esp
f0101d88:	85 c0                	test   %eax,%eax
f0101d8a:	74 19                	je     f0101da5 <mem_init+0xb14>
f0101d8c:	68 68 69 10 f0       	push   $0xf0106968
f0101d91:	68 36 63 10 f0       	push   $0xf0106336
f0101d96:	68 d8 03 00 00       	push   $0x3d8
f0101d9b:	68 10 63 10 f0       	push   $0xf0106310
f0101da0:	e8 9b e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101da5:	83 ec 04             	sub    $0x4,%esp
f0101da8:	6a 00                	push   $0x0
f0101daa:	68 00 10 00 00       	push   $0x1000
f0101daf:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0101db5:	e8 00 f2 ff ff       	call   f0100fba <pgdir_walk>
f0101dba:	83 c4 10             	add    $0x10,%esp
f0101dbd:	f6 00 02             	testb  $0x2,(%eax)
f0101dc0:	75 19                	jne    f0101ddb <mem_init+0xb4a>
f0101dc2:	68 88 6a 10 f0       	push   $0xf0106a88
f0101dc7:	68 36 63 10 f0       	push   $0xf0106336
f0101dcc:	68 d9 03 00 00       	push   $0x3d9
f0101dd1:	68 10 63 10 f0       	push   $0xf0106310
f0101dd6:	e8 65 e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ddb:	83 ec 04             	sub    $0x4,%esp
f0101dde:	6a 00                	push   $0x0
f0101de0:	68 00 10 00 00       	push   $0x1000
f0101de5:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0101deb:	e8 ca f1 ff ff       	call   f0100fba <pgdir_walk>
f0101df0:	83 c4 10             	add    $0x10,%esp
f0101df3:	f6 00 04             	testb  $0x4,(%eax)
f0101df6:	74 19                	je     f0101e11 <mem_init+0xb80>
f0101df8:	68 bc 6a 10 f0       	push   $0xf0106abc
f0101dfd:	68 36 63 10 f0       	push   $0xf0106336
f0101e02:	68 da 03 00 00       	push   $0x3da
f0101e07:	68 10 63 10 f0       	push   $0xf0106310
f0101e0c:	e8 2f e2 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101e11:	6a 02                	push   $0x2
f0101e13:	68 00 00 40 00       	push   $0x400000
f0101e18:	56                   	push   %esi
f0101e19:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0101e1f:	e8 9a f3 ff ff       	call   f01011be <page_insert>
f0101e24:	83 c4 10             	add    $0x10,%esp
f0101e27:	85 c0                	test   %eax,%eax
f0101e29:	78 19                	js     f0101e44 <mem_init+0xbb3>
f0101e2b:	68 f4 6a 10 f0       	push   $0xf0106af4
f0101e30:	68 36 63 10 f0       	push   $0xf0106336
f0101e35:	68 dd 03 00 00       	push   $0x3dd
f0101e3a:	68 10 63 10 f0       	push   $0xf0106310
f0101e3f:	e8 fc e1 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101e44:	6a 02                	push   $0x2
f0101e46:	68 00 10 00 00       	push   $0x1000
f0101e4b:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101e4e:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0101e54:	e8 65 f3 ff ff       	call   f01011be <page_insert>
f0101e59:	83 c4 10             	add    $0x10,%esp
f0101e5c:	85 c0                	test   %eax,%eax
f0101e5e:	74 19                	je     f0101e79 <mem_init+0xbe8>
f0101e60:	68 2c 6b 10 f0       	push   $0xf0106b2c
f0101e65:	68 36 63 10 f0       	push   $0xf0106336
f0101e6a:	68 e0 03 00 00       	push   $0x3e0
f0101e6f:	68 10 63 10 f0       	push   $0xf0106310
f0101e74:	e8 c7 e1 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e79:	83 ec 04             	sub    $0x4,%esp
f0101e7c:	6a 00                	push   $0x0
f0101e7e:	68 00 10 00 00       	push   $0x1000
f0101e83:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0101e89:	e8 2c f1 ff ff       	call   f0100fba <pgdir_walk>
f0101e8e:	83 c4 10             	add    $0x10,%esp
f0101e91:	f6 00 04             	testb  $0x4,(%eax)
f0101e94:	74 19                	je     f0101eaf <mem_init+0xc1e>
f0101e96:	68 bc 6a 10 f0       	push   $0xf0106abc
f0101e9b:	68 36 63 10 f0       	push   $0xf0106336
f0101ea0:	68 e1 03 00 00       	push   $0x3e1
f0101ea5:	68 10 63 10 f0       	push   $0xf0106310
f0101eaa:	e8 91 e1 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101eaf:	8b 3d 0c af 22 f0    	mov    0xf022af0c,%edi
f0101eb5:	ba 00 00 00 00       	mov    $0x0,%edx
f0101eba:	89 f8                	mov    %edi,%eax
f0101ebc:	e8 5d ec ff ff       	call   f0100b1e <check_va2pa>
f0101ec1:	89 c1                	mov    %eax,%ecx
f0101ec3:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101ec6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ec9:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f0101ecf:	c1 f8 03             	sar    $0x3,%eax
f0101ed2:	c1 e0 0c             	shl    $0xc,%eax
f0101ed5:	39 c1                	cmp    %eax,%ecx
f0101ed7:	74 19                	je     f0101ef2 <mem_init+0xc61>
f0101ed9:	68 68 6b 10 f0       	push   $0xf0106b68
f0101ede:	68 36 63 10 f0       	push   $0xf0106336
f0101ee3:	68 e4 03 00 00       	push   $0x3e4
f0101ee8:	68 10 63 10 f0       	push   $0xf0106310
f0101eed:	e8 4e e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ef2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ef7:	89 f8                	mov    %edi,%eax
f0101ef9:	e8 20 ec ff ff       	call   f0100b1e <check_va2pa>
f0101efe:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101f01:	74 19                	je     f0101f1c <mem_init+0xc8b>
f0101f03:	68 94 6b 10 f0       	push   $0xf0106b94
f0101f08:	68 36 63 10 f0       	push   $0xf0106336
f0101f0d:	68 e5 03 00 00       	push   $0x3e5
f0101f12:	68 10 63 10 f0       	push   $0xf0106310
f0101f17:	e8 24 e1 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101f1c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f1f:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f0101f24:	74 19                	je     f0101f3f <mem_init+0xcae>
f0101f26:	68 d8 65 10 f0       	push   $0xf01065d8
f0101f2b:	68 36 63 10 f0       	push   $0xf0106336
f0101f30:	68 e7 03 00 00       	push   $0x3e7
f0101f35:	68 10 63 10 f0       	push   $0xf0106310
f0101f3a:	e8 01 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101f3f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f44:	74 19                	je     f0101f5f <mem_init+0xcce>
f0101f46:	68 e9 65 10 f0       	push   $0xf01065e9
f0101f4b:	68 36 63 10 f0       	push   $0xf0106336
f0101f50:	68 e8 03 00 00       	push   $0x3e8
f0101f55:	68 10 63 10 f0       	push   $0xf0106310
f0101f5a:	e8 e1 e0 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101f5f:	83 ec 0c             	sub    $0xc,%esp
f0101f62:	6a 00                	push   $0x0
f0101f64:	e8 b1 ef ff ff       	call   f0100f1a <page_alloc>
f0101f69:	83 c4 10             	add    $0x10,%esp
f0101f6c:	85 c0                	test   %eax,%eax
f0101f6e:	74 04                	je     f0101f74 <mem_init+0xce3>
f0101f70:	39 c3                	cmp    %eax,%ebx
f0101f72:	74 19                	je     f0101f8d <mem_init+0xcfc>
f0101f74:	68 c4 6b 10 f0       	push   $0xf0106bc4
f0101f79:	68 36 63 10 f0       	push   $0xf0106336
f0101f7e:	68 eb 03 00 00       	push   $0x3eb
f0101f83:	68 10 63 10 f0       	push   $0xf0106310
f0101f88:	e8 b3 e0 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101f8d:	83 ec 08             	sub    $0x8,%esp
f0101f90:	6a 00                	push   $0x0
f0101f92:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0101f98:	e8 d3 f1 ff ff       	call   f0101170 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f9d:	8b 3d 0c af 22 f0    	mov    0xf022af0c,%edi
f0101fa3:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fa8:	89 f8                	mov    %edi,%eax
f0101faa:	e8 6f eb ff ff       	call   f0100b1e <check_va2pa>
f0101faf:	83 c4 10             	add    $0x10,%esp
f0101fb2:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fb5:	74 19                	je     f0101fd0 <mem_init+0xd3f>
f0101fb7:	68 e8 6b 10 f0       	push   $0xf0106be8
f0101fbc:	68 36 63 10 f0       	push   $0xf0106336
f0101fc1:	68 ef 03 00 00       	push   $0x3ef
f0101fc6:	68 10 63 10 f0       	push   $0xf0106310
f0101fcb:	e8 70 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101fd0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fd5:	89 f8                	mov    %edi,%eax
f0101fd7:	e8 42 eb ff ff       	call   f0100b1e <check_va2pa>
f0101fdc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101fdf:	2b 15 10 af 22 f0    	sub    0xf022af10,%edx
f0101fe5:	c1 fa 03             	sar    $0x3,%edx
f0101fe8:	c1 e2 0c             	shl    $0xc,%edx
f0101feb:	39 d0                	cmp    %edx,%eax
f0101fed:	74 19                	je     f0102008 <mem_init+0xd77>
f0101fef:	68 94 6b 10 f0       	push   $0xf0106b94
f0101ff4:	68 36 63 10 f0       	push   $0xf0106336
f0101ff9:	68 f0 03 00 00       	push   $0x3f0
f0101ffe:	68 10 63 10 f0       	push   $0xf0106310
f0102003:	e8 38 e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102008:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010200b:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102010:	74 19                	je     f010202b <mem_init+0xd9a>
f0102012:	68 63 65 10 f0       	push   $0xf0106563
f0102017:	68 36 63 10 f0       	push   $0xf0106336
f010201c:	68 f1 03 00 00       	push   $0x3f1
f0102021:	68 10 63 10 f0       	push   $0xf0106310
f0102026:	e8 15 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010202b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102030:	74 19                	je     f010204b <mem_init+0xdba>
f0102032:	68 e9 65 10 f0       	push   $0xf01065e9
f0102037:	68 36 63 10 f0       	push   $0xf0106336
f010203c:	68 f2 03 00 00       	push   $0x3f2
f0102041:	68 10 63 10 f0       	push   $0xf0106310
f0102046:	e8 f5 df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010204b:	83 ec 08             	sub    $0x8,%esp
f010204e:	68 00 10 00 00       	push   $0x1000
f0102053:	57                   	push   %edi
f0102054:	e8 17 f1 ff ff       	call   f0101170 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102059:	8b 3d 0c af 22 f0    	mov    0xf022af0c,%edi
f010205f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102064:	89 f8                	mov    %edi,%eax
f0102066:	e8 b3 ea ff ff       	call   f0100b1e <check_va2pa>
f010206b:	83 c4 10             	add    $0x10,%esp
f010206e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102071:	74 19                	je     f010208c <mem_init+0xdfb>
f0102073:	68 e8 6b 10 f0       	push   $0xf0106be8
f0102078:	68 36 63 10 f0       	push   $0xf0106336
f010207d:	68 f6 03 00 00       	push   $0x3f6
f0102082:	68 10 63 10 f0       	push   $0xf0106310
f0102087:	e8 b4 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010208c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102091:	89 f8                	mov    %edi,%eax
f0102093:	e8 86 ea ff ff       	call   f0100b1e <check_va2pa>
f0102098:	83 f8 ff             	cmp    $0xffffffff,%eax
f010209b:	74 19                	je     f01020b6 <mem_init+0xe25>
f010209d:	68 0c 6c 10 f0       	push   $0xf0106c0c
f01020a2:	68 36 63 10 f0       	push   $0xf0106336
f01020a7:	68 f7 03 00 00       	push   $0x3f7
f01020ac:	68 10 63 10 f0       	push   $0xf0106310
f01020b1:	e8 8a df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01020b6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020b9:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01020be:	74 19                	je     f01020d9 <mem_init+0xe48>
f01020c0:	68 fa 65 10 f0       	push   $0xf01065fa
f01020c5:	68 36 63 10 f0       	push   $0xf0106336
f01020ca:	68 f8 03 00 00       	push   $0x3f8
f01020cf:	68 10 63 10 f0       	push   $0xf0106310
f01020d4:	e8 67 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01020d9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01020de:	74 19                	je     f01020f9 <mem_init+0xe68>
f01020e0:	68 e9 65 10 f0       	push   $0xf01065e9
f01020e5:	68 36 63 10 f0       	push   $0xf0106336
f01020ea:	68 f9 03 00 00       	push   $0x3f9
f01020ef:	68 10 63 10 f0       	push   $0xf0106310
f01020f4:	e8 47 df ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01020f9:	83 ec 0c             	sub    $0xc,%esp
f01020fc:	6a 00                	push   $0x0
f01020fe:	e8 17 ee ff ff       	call   f0100f1a <page_alloc>
f0102103:	83 c4 10             	add    $0x10,%esp
f0102106:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0102109:	75 04                	jne    f010210f <mem_init+0xe7e>
f010210b:	85 c0                	test   %eax,%eax
f010210d:	75 19                	jne    f0102128 <mem_init+0xe97>
f010210f:	68 34 6c 10 f0       	push   $0xf0106c34
f0102114:	68 36 63 10 f0       	push   $0xf0106336
f0102119:	68 fc 03 00 00       	push   $0x3fc
f010211e:	68 10 63 10 f0       	push   $0xf0106310
f0102123:	e8 18 df ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102128:	83 ec 0c             	sub    $0xc,%esp
f010212b:	6a 00                	push   $0x0
f010212d:	e8 e8 ed ff ff       	call   f0100f1a <page_alloc>
f0102132:	83 c4 10             	add    $0x10,%esp
f0102135:	85 c0                	test   %eax,%eax
f0102137:	74 19                	je     f0102152 <mem_init+0xec1>
f0102139:	68 01 65 10 f0       	push   $0xf0106501
f010213e:	68 36 63 10 f0       	push   $0xf0106336
f0102143:	68 ff 03 00 00       	push   $0x3ff
f0102148:	68 10 63 10 f0       	push   $0xf0106310
f010214d:	e8 ee de ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102152:	8b 0d 0c af 22 f0    	mov    0xf022af0c,%ecx
f0102158:	8b 11                	mov    (%ecx),%edx
f010215a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102160:	89 f0                	mov    %esi,%eax
f0102162:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f0102168:	c1 f8 03             	sar    $0x3,%eax
f010216b:	c1 e0 0c             	shl    $0xc,%eax
f010216e:	39 c2                	cmp    %eax,%edx
f0102170:	74 19                	je     f010218b <mem_init+0xefa>
f0102172:	68 10 69 10 f0       	push   $0xf0106910
f0102177:	68 36 63 10 f0       	push   $0xf0106336
f010217c:	68 02 04 00 00       	push   $0x402
f0102181:	68 10 63 10 f0       	push   $0xf0106310
f0102186:	e8 b5 de ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010218b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102191:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102196:	74 19                	je     f01021b1 <mem_init+0xf20>
f0102198:	68 74 65 10 f0       	push   $0xf0106574
f010219d:	68 36 63 10 f0       	push   $0xf0106336
f01021a2:	68 04 04 00 00       	push   $0x404
f01021a7:	68 10 63 10 f0       	push   $0xf0106310
f01021ac:	e8 8f de ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01021b1:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01021b7:	83 ec 0c             	sub    $0xc,%esp
f01021ba:	56                   	push   %esi
f01021bb:	e8 c4 ed ff ff       	call   f0100f84 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01021c0:	83 c4 0c             	add    $0xc,%esp
f01021c3:	6a 01                	push   $0x1
f01021c5:	68 00 10 40 00       	push   $0x401000
f01021ca:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f01021d0:	e8 e5 ed ff ff       	call   f0100fba <pgdir_walk>
f01021d5:	89 c7                	mov    %eax,%edi
f01021d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01021da:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
f01021df:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01021e2:	8b 40 04             	mov    0x4(%eax),%eax
f01021e5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01021ea:	8b 0d 08 af 22 f0    	mov    0xf022af08,%ecx
f01021f0:	89 c2                	mov    %eax,%edx
f01021f2:	c1 ea 0c             	shr    $0xc,%edx
f01021f5:	83 c4 10             	add    $0x10,%esp
f01021f8:	39 ca                	cmp    %ecx,%edx
f01021fa:	72 15                	jb     f0102211 <mem_init+0xf80>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01021fc:	50                   	push   %eax
f01021fd:	68 64 5d 10 f0       	push   $0xf0105d64
f0102202:	68 0b 04 00 00       	push   $0x40b
f0102207:	68 10 63 10 f0       	push   $0xf0106310
f010220c:	e8 2f de ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102211:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102216:	39 c7                	cmp    %eax,%edi
f0102218:	74 19                	je     f0102233 <mem_init+0xfa2>
f010221a:	68 0b 66 10 f0       	push   $0xf010660b
f010221f:	68 36 63 10 f0       	push   $0xf0106336
f0102224:	68 0c 04 00 00       	push   $0x40c
f0102229:	68 10 63 10 f0       	push   $0xf0106310
f010222e:	e8 0d de ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102233:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102236:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f010223d:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102243:	89 f0                	mov    %esi,%eax
f0102245:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f010224b:	c1 f8 03             	sar    $0x3,%eax
f010224e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102251:	89 c2                	mov    %eax,%edx
f0102253:	c1 ea 0c             	shr    $0xc,%edx
f0102256:	39 d1                	cmp    %edx,%ecx
f0102258:	77 12                	ja     f010226c <mem_init+0xfdb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010225a:	50                   	push   %eax
f010225b:	68 64 5d 10 f0       	push   $0xf0105d64
f0102260:	6a 58                	push   $0x58
f0102262:	68 1c 63 10 f0       	push   $0xf010631c
f0102267:	e8 d4 dd ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010226c:	83 ec 04             	sub    $0x4,%esp
f010226f:	68 00 10 00 00       	push   $0x1000
f0102274:	68 ff 00 00 00       	push   $0xff
f0102279:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010227e:	50                   	push   %eax
f010227f:	e8 07 2e 00 00       	call   f010508b <memset>
	page_free(pp0);
f0102284:	89 34 24             	mov    %esi,(%esp)
f0102287:	e8 f8 ec ff ff       	call   f0100f84 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010228c:	83 c4 0c             	add    $0xc,%esp
f010228f:	6a 01                	push   $0x1
f0102291:	6a 00                	push   $0x0
f0102293:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0102299:	e8 1c ed ff ff       	call   f0100fba <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010229e:	89 f2                	mov    %esi,%edx
f01022a0:	2b 15 10 af 22 f0    	sub    0xf022af10,%edx
f01022a6:	c1 fa 03             	sar    $0x3,%edx
f01022a9:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01022ac:	89 d0                	mov    %edx,%eax
f01022ae:	c1 e8 0c             	shr    $0xc,%eax
f01022b1:	83 c4 10             	add    $0x10,%esp
f01022b4:	3b 05 08 af 22 f0    	cmp    0xf022af08,%eax
f01022ba:	72 12                	jb     f01022ce <mem_init+0x103d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01022bc:	52                   	push   %edx
f01022bd:	68 64 5d 10 f0       	push   $0xf0105d64
f01022c2:	6a 58                	push   $0x58
f01022c4:	68 1c 63 10 f0       	push   $0xf010631c
f01022c9:	e8 72 dd ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01022ce:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01022d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01022d7:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01022dd:	f6 00 01             	testb  $0x1,(%eax)
f01022e0:	74 19                	je     f01022fb <mem_init+0x106a>
f01022e2:	68 23 66 10 f0       	push   $0xf0106623
f01022e7:	68 36 63 10 f0       	push   $0xf0106336
f01022ec:	68 16 04 00 00       	push   $0x416
f01022f1:	68 10 63 10 f0       	push   $0xf0106310
f01022f6:	e8 45 dd ff ff       	call   f0100040 <_panic>
f01022fb:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01022fe:	39 c2                	cmp    %eax,%edx
f0102300:	75 db                	jne    f01022dd <mem_init+0x104c>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102302:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
f0102307:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010230d:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102313:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102316:	a3 40 a2 22 f0       	mov    %eax,0xf022a240

	// free the pages we took
	page_free(pp0);
f010231b:	83 ec 0c             	sub    $0xc,%esp
f010231e:	56                   	push   %esi
f010231f:	e8 60 ec ff ff       	call   f0100f84 <page_free>
	page_free(pp1);
f0102324:	83 c4 04             	add    $0x4,%esp
f0102327:	ff 75 d4             	pushl  -0x2c(%ebp)
f010232a:	e8 55 ec ff ff       	call   f0100f84 <page_free>
	page_free(pp2);
f010232f:	89 1c 24             	mov    %ebx,(%esp)
f0102332:	e8 4d ec ff ff       	call   f0100f84 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102337:	83 c4 08             	add    $0x8,%esp
f010233a:	68 01 10 00 00       	push   $0x1001
f010233f:	6a 00                	push   $0x0
f0102341:	e8 de ee ff ff       	call   f0101224 <mmio_map_region>
f0102346:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102348:	83 c4 08             	add    $0x8,%esp
f010234b:	68 00 10 00 00       	push   $0x1000
f0102350:	6a 00                	push   $0x0
f0102352:	e8 cd ee ff ff       	call   f0101224 <mmio_map_region>
f0102357:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102359:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f010235f:	83 c4 10             	add    $0x10,%esp
f0102362:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102368:	76 07                	jbe    f0102371 <mem_init+0x10e0>
f010236a:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010236f:	76 19                	jbe    f010238a <mem_init+0x10f9>
f0102371:	68 58 6c 10 f0       	push   $0xf0106c58
f0102376:	68 36 63 10 f0       	push   $0xf0106336
f010237b:	68 26 04 00 00       	push   $0x426
f0102380:	68 10 63 10 f0       	push   $0xf0106310
f0102385:	e8 b6 dc ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f010238a:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102390:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102396:	77 08                	ja     f01023a0 <mem_init+0x110f>
f0102398:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010239e:	77 19                	ja     f01023b9 <mem_init+0x1128>
f01023a0:	68 80 6c 10 f0       	push   $0xf0106c80
f01023a5:	68 36 63 10 f0       	push   $0xf0106336
f01023aa:	68 27 04 00 00       	push   $0x427
f01023af:	68 10 63 10 f0       	push   $0xf0106310
f01023b4:	e8 87 dc ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01023b9:	89 da                	mov    %ebx,%edx
f01023bb:	09 f2                	or     %esi,%edx
f01023bd:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01023c3:	74 19                	je     f01023de <mem_init+0x114d>
f01023c5:	68 a8 6c 10 f0       	push   $0xf0106ca8
f01023ca:	68 36 63 10 f0       	push   $0xf0106336
f01023cf:	68 29 04 00 00       	push   $0x429
f01023d4:	68 10 63 10 f0       	push   $0xf0106310
f01023d9:	e8 62 dc ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01023de:	39 c6                	cmp    %eax,%esi
f01023e0:	73 19                	jae    f01023fb <mem_init+0x116a>
f01023e2:	68 3a 66 10 f0       	push   $0xf010663a
f01023e7:	68 36 63 10 f0       	push   $0xf0106336
f01023ec:	68 2b 04 00 00       	push   $0x42b
f01023f1:	68 10 63 10 f0       	push   $0xf0106310
f01023f6:	e8 45 dc ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01023fb:	8b 3d 0c af 22 f0    	mov    0xf022af0c,%edi
f0102401:	89 da                	mov    %ebx,%edx
f0102403:	89 f8                	mov    %edi,%eax
f0102405:	e8 14 e7 ff ff       	call   f0100b1e <check_va2pa>
f010240a:	85 c0                	test   %eax,%eax
f010240c:	74 19                	je     f0102427 <mem_init+0x1196>
f010240e:	68 d0 6c 10 f0       	push   $0xf0106cd0
f0102413:	68 36 63 10 f0       	push   $0xf0106336
f0102418:	68 2d 04 00 00       	push   $0x42d
f010241d:	68 10 63 10 f0       	push   $0xf0106310
f0102422:	e8 19 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102427:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f010242d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102430:	89 c2                	mov    %eax,%edx
f0102432:	89 f8                	mov    %edi,%eax
f0102434:	e8 e5 e6 ff ff       	call   f0100b1e <check_va2pa>
f0102439:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010243e:	74 19                	je     f0102459 <mem_init+0x11c8>
f0102440:	68 f4 6c 10 f0       	push   $0xf0106cf4
f0102445:	68 36 63 10 f0       	push   $0xf0106336
f010244a:	68 2e 04 00 00       	push   $0x42e
f010244f:	68 10 63 10 f0       	push   $0xf0106310
f0102454:	e8 e7 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102459:	89 f2                	mov    %esi,%edx
f010245b:	89 f8                	mov    %edi,%eax
f010245d:	e8 bc e6 ff ff       	call   f0100b1e <check_va2pa>
f0102462:	85 c0                	test   %eax,%eax
f0102464:	74 19                	je     f010247f <mem_init+0x11ee>
f0102466:	68 24 6d 10 f0       	push   $0xf0106d24
f010246b:	68 36 63 10 f0       	push   $0xf0106336
f0102470:	68 2f 04 00 00       	push   $0x42f
f0102475:	68 10 63 10 f0       	push   $0xf0106310
f010247a:	e8 c1 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010247f:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102485:	89 f8                	mov    %edi,%eax
f0102487:	e8 92 e6 ff ff       	call   f0100b1e <check_va2pa>
f010248c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010248f:	74 19                	je     f01024aa <mem_init+0x1219>
f0102491:	68 48 6d 10 f0       	push   $0xf0106d48
f0102496:	68 36 63 10 f0       	push   $0xf0106336
f010249b:	68 30 04 00 00       	push   $0x430
f01024a0:	68 10 63 10 f0       	push   $0xf0106310
f01024a5:	e8 96 db ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01024aa:	83 ec 04             	sub    $0x4,%esp
f01024ad:	6a 00                	push   $0x0
f01024af:	53                   	push   %ebx
f01024b0:	57                   	push   %edi
f01024b1:	e8 04 eb ff ff       	call   f0100fba <pgdir_walk>
f01024b6:	83 c4 10             	add    $0x10,%esp
f01024b9:	f6 00 1a             	testb  $0x1a,(%eax)
f01024bc:	75 19                	jne    f01024d7 <mem_init+0x1246>
f01024be:	68 74 6d 10 f0       	push   $0xf0106d74
f01024c3:	68 36 63 10 f0       	push   $0xf0106336
f01024c8:	68 32 04 00 00       	push   $0x432
f01024cd:	68 10 63 10 f0       	push   $0xf0106310
f01024d2:	e8 69 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01024d7:	83 ec 04             	sub    $0x4,%esp
f01024da:	6a 00                	push   $0x0
f01024dc:	53                   	push   %ebx
f01024dd:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f01024e3:	e8 d2 ea ff ff       	call   f0100fba <pgdir_walk>
f01024e8:	8b 00                	mov    (%eax),%eax
f01024ea:	83 c4 10             	add    $0x10,%esp
f01024ed:	83 e0 04             	and    $0x4,%eax
f01024f0:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01024f3:	74 19                	je     f010250e <mem_init+0x127d>
f01024f5:	68 b8 6d 10 f0       	push   $0xf0106db8
f01024fa:	68 36 63 10 f0       	push   $0xf0106336
f01024ff:	68 33 04 00 00       	push   $0x433
f0102504:	68 10 63 10 f0       	push   $0xf0106310
f0102509:	e8 32 db ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f010250e:	83 ec 04             	sub    $0x4,%esp
f0102511:	6a 00                	push   $0x0
f0102513:	53                   	push   %ebx
f0102514:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f010251a:	e8 9b ea ff ff       	call   f0100fba <pgdir_walk>
f010251f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102525:	83 c4 0c             	add    $0xc,%esp
f0102528:	6a 00                	push   $0x0
f010252a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010252d:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0102533:	e8 82 ea ff ff       	call   f0100fba <pgdir_walk>
f0102538:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010253e:	83 c4 0c             	add    $0xc,%esp
f0102541:	6a 00                	push   $0x0
f0102543:	56                   	push   %esi
f0102544:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f010254a:	e8 6b ea ff ff       	call   f0100fba <pgdir_walk>
f010254f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102555:	c7 04 24 4c 66 10 f0 	movl   $0xf010664c,(%esp)
f010255c:	e8 27 11 00 00       	call   f0103688 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, 
f0102561:	a1 10 af 22 f0       	mov    0xf022af10,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102566:	83 c4 10             	add    $0x10,%esp
f0102569:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010256e:	77 15                	ja     f0102585 <mem_init+0x12f4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102570:	50                   	push   %eax
f0102571:	68 88 5d 10 f0       	push   $0xf0105d88
f0102576:	68 c0 00 00 00       	push   $0xc0
f010257b:	68 10 63 10 f0       	push   $0xf0106310
f0102580:	e8 bb da ff ff       	call   f0100040 <_panic>
f0102585:	83 ec 08             	sub    $0x8,%esp
f0102588:	6a 04                	push   $0x4
f010258a:	05 00 00 00 10       	add    $0x10000000,%eax
f010258f:	50                   	push   %eax
f0102590:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102595:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010259a:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
f010259f:	e8 a9 ea ff ff       	call   f010104d <boot_map_region>
		UPAGES, 
		PTSIZE, 
		PADDR(pages), 
		PTE_U);
	cprintf("PADDR(pages) %x\n", PADDR(pages));
f01025a4:	a1 10 af 22 f0       	mov    0xf022af10,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025a9:	83 c4 10             	add    $0x10,%esp
f01025ac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025b1:	77 15                	ja     f01025c8 <mem_init+0x1337>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025b3:	50                   	push   %eax
f01025b4:	68 88 5d 10 f0       	push   $0xf0105d88
f01025b9:	68 c2 00 00 00       	push   $0xc2
f01025be:	68 10 63 10 f0       	push   $0xf0106310
f01025c3:	e8 78 da ff ff       	call   f0100040 <_panic>
f01025c8:	83 ec 08             	sub    $0x8,%esp
f01025cb:	05 00 00 00 10       	add    $0x10000000,%eax
f01025d0:	50                   	push   %eax
f01025d1:	68 65 66 10 f0       	push   $0xf0106665
f01025d6:	e8 ad 10 00 00       	call   f0103688 <cprintf>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir,
f01025db:	a1 48 a2 22 f0       	mov    0xf022a248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025e0:	83 c4 10             	add    $0x10,%esp
f01025e3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025e8:	77 15                	ja     f01025ff <mem_init+0x136e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025ea:	50                   	push   %eax
f01025eb:	68 88 5d 10 f0       	push   $0xf0105d88
f01025f0:	68 cd 00 00 00       	push   $0xcd
f01025f5:	68 10 63 10 f0       	push   $0xf0106310
f01025fa:	e8 41 da ff ff       	call   f0100040 <_panic>
f01025ff:	83 ec 08             	sub    $0x8,%esp
f0102602:	6a 04                	push   $0x4
f0102604:	05 00 00 00 10       	add    $0x10000000,%eax
f0102609:	50                   	push   %eax
f010260a:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010260f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102614:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
f0102619:	e8 2f ea ff ff       	call   f010104d <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010261e:	83 c4 10             	add    $0x10,%esp
f0102621:	b8 00 50 11 f0       	mov    $0xf0115000,%eax
f0102626:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010262b:	77 15                	ja     f0102642 <mem_init+0x13b1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010262d:	50                   	push   %eax
f010262e:	68 88 5d 10 f0       	push   $0xf0105d88
f0102633:	68 df 00 00 00       	push   $0xdf
f0102638:	68 10 63 10 f0       	push   $0xf0106310
f010263d:	e8 fe d9 ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, 
f0102642:	83 ec 08             	sub    $0x8,%esp
f0102645:	6a 02                	push   $0x2
f0102647:	68 00 50 11 00       	push   $0x115000
f010264c:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102651:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102656:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
f010265b:	e8 ed e9 ff ff       	call   f010104d <boot_map_region>
		KSTACKTOP-KSTKSIZE, 
		KSTKSIZE, 
		PADDR(bootstack), 
		PTE_W);
	cprintf("PADDR(bootstack) %x\n", PADDR(bootstack));
f0102660:	83 c4 08             	add    $0x8,%esp
f0102663:	68 00 50 11 00       	push   $0x115000
f0102668:	68 76 66 10 f0       	push   $0xf0106676
f010266d:	e8 16 10 00 00       	call   f0103688 <cprintf>
f0102672:	c7 45 c4 00 c0 22 f0 	movl   $0xf022c000,-0x3c(%ebp)
f0102679:	83 c4 10             	add    $0x10,%esp
f010267c:	bb 00 c0 22 f0       	mov    $0xf022c000,%ebx
f0102681:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102686:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f010268c:	77 15                	ja     f01026a3 <mem_init+0x1412>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010268e:	53                   	push   %ebx
f010268f:	68 88 5d 10 f0       	push   $0xf0105d88
f0102694:	68 2d 01 00 00       	push   $0x12d
f0102699:	68 10 63 10 f0       	push   $0xf0106310
f010269e:	e8 9d d9 ff ff       	call   f0100040 <_panic>
	//
	// LAB 4: Your code here:
int i;
  
    for (i = 0; i < NCPU; ++i) {
        boot_map_region(kern_pgdir, 
f01026a3:	83 ec 08             	sub    $0x8,%esp
f01026a6:	6a 02                	push   $0x2
f01026a8:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f01026ae:	50                   	push   %eax
f01026af:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01026b4:	89 f2                	mov    %esi,%edx
f01026b6:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
f01026bb:	e8 8d e9 ff ff       	call   f010104d <boot_map_region>
f01026c0:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01026c6:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
int i;
  
    for (i = 0; i < NCPU; ++i) {
f01026cc:	83 c4 10             	add    $0x10,%esp
f01026cf:	b8 00 c0 26 f0       	mov    $0xf026c000,%eax
f01026d4:	39 d8                	cmp    %ebx,%eax
f01026d6:	75 ae                	jne    f0102686 <mem_init+0x13f5>

//<<<<<<< HEAD
	// Initialize the SMP-related parts of the memory map
	mem_init_mp();
//=======
	boot_map_region(kern_pgdir, 
f01026d8:	83 ec 08             	sub    $0x8,%esp
f01026db:	6a 02                	push   $0x2
f01026dd:	6a 00                	push   $0x0
f01026df:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01026e4:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01026e9:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
f01026ee:	e8 5a e9 ff ff       	call   f010104d <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01026f3:	8b 3d 0c af 22 f0    	mov    0xf022af0c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01026f9:	a1 08 af 22 f0       	mov    0xf022af08,%eax
f01026fe:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102701:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102708:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010270d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102710:	8b 35 10 af 22 f0    	mov    0xf022af10,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102716:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0102719:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010271c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102721:	eb 55                	jmp    f0102778 <mem_init+0x14e7>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102723:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102729:	89 f8                	mov    %edi,%eax
f010272b:	e8 ee e3 ff ff       	call   f0100b1e <check_va2pa>
f0102730:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102737:	77 15                	ja     f010274e <mem_init+0x14bd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102739:	56                   	push   %esi
f010273a:	68 88 5d 10 f0       	push   $0xf0105d88
f010273f:	68 4d 03 00 00       	push   $0x34d
f0102744:	68 10 63 10 f0       	push   $0xf0106310
f0102749:	e8 f2 d8 ff ff       	call   f0100040 <_panic>
f010274e:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f0102755:	39 c2                	cmp    %eax,%edx
f0102757:	74 19                	je     f0102772 <mem_init+0x14e1>
f0102759:	68 ec 6d 10 f0       	push   $0xf0106dec
f010275e:	68 36 63 10 f0       	push   $0xf0106336
f0102763:	68 4d 03 00 00       	push   $0x34d
f0102768:	68 10 63 10 f0       	push   $0xf0106310
f010276d:	e8 ce d8 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102772:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102778:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010277b:	77 a6                	ja     f0102723 <mem_init+0x1492>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010277d:	8b 35 48 a2 22 f0    	mov    0xf022a248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102783:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102786:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f010278b:	89 da                	mov    %ebx,%edx
f010278d:	89 f8                	mov    %edi,%eax
f010278f:	e8 8a e3 ff ff       	call   f0100b1e <check_va2pa>
f0102794:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f010279b:	77 15                	ja     f01027b2 <mem_init+0x1521>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010279d:	56                   	push   %esi
f010279e:	68 88 5d 10 f0       	push   $0xf0105d88
f01027a3:	68 52 03 00 00       	push   $0x352
f01027a8:	68 10 63 10 f0       	push   $0xf0106310
f01027ad:	e8 8e d8 ff ff       	call   f0100040 <_panic>
f01027b2:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f01027b9:	39 d0                	cmp    %edx,%eax
f01027bb:	74 19                	je     f01027d6 <mem_init+0x1545>
f01027bd:	68 20 6e 10 f0       	push   $0xf0106e20
f01027c2:	68 36 63 10 f0       	push   $0xf0106336
f01027c7:	68 52 03 00 00       	push   $0x352
f01027cc:	68 10 63 10 f0       	push   $0xf0106310
f01027d1:	e8 6a d8 ff ff       	call   f0100040 <_panic>
f01027d6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027dc:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01027e2:	75 a7                	jne    f010278b <mem_init+0x14fa>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01027e4:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01027e7:	c1 e6 0c             	shl    $0xc,%esi
f01027ea:	bb 00 00 00 00       	mov    $0x0,%ebx
f01027ef:	eb 30                	jmp    f0102821 <mem_init+0x1590>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01027f1:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01027f7:	89 f8                	mov    %edi,%eax
f01027f9:	e8 20 e3 ff ff       	call   f0100b1e <check_va2pa>
f01027fe:	39 c3                	cmp    %eax,%ebx
f0102800:	74 19                	je     f010281b <mem_init+0x158a>
f0102802:	68 54 6e 10 f0       	push   $0xf0106e54
f0102807:	68 36 63 10 f0       	push   $0xf0106336
f010280c:	68 56 03 00 00       	push   $0x356
f0102811:	68 10 63 10 f0       	push   $0xf0106310
f0102816:	e8 25 d8 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010281b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102821:	39 f3                	cmp    %esi,%ebx
f0102823:	72 cc                	jb     f01027f1 <mem_init+0x1560>
f0102825:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f010282a:	89 75 cc             	mov    %esi,-0x34(%ebp)
f010282d:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102830:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102833:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102839:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f010283c:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010283e:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102841:	05 00 80 00 20       	add    $0x20008000,%eax
f0102846:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102849:	89 da                	mov    %ebx,%edx
f010284b:	89 f8                	mov    %edi,%eax
f010284d:	e8 cc e2 ff ff       	call   f0100b1e <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102852:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102858:	77 15                	ja     f010286f <mem_init+0x15de>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010285a:	56                   	push   %esi
f010285b:	68 88 5d 10 f0       	push   $0xf0105d88
f0102860:	68 5e 03 00 00       	push   $0x35e
f0102865:	68 10 63 10 f0       	push   $0xf0106310
f010286a:	e8 d1 d7 ff ff       	call   f0100040 <_panic>
f010286f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102872:	8d 94 0b 00 c0 22 f0 	lea    -0xfdd4000(%ebx,%ecx,1),%edx
f0102879:	39 d0                	cmp    %edx,%eax
f010287b:	74 19                	je     f0102896 <mem_init+0x1605>
f010287d:	68 7c 6e 10 f0       	push   $0xf0106e7c
f0102882:	68 36 63 10 f0       	push   $0xf0106336
f0102887:	68 5e 03 00 00       	push   $0x35e
f010288c:	68 10 63 10 f0       	push   $0xf0106310
f0102891:	e8 aa d7 ff ff       	call   f0100040 <_panic>
f0102896:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010289c:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f010289f:	75 a8                	jne    f0102849 <mem_init+0x15b8>
f01028a1:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01028a4:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f01028aa:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01028ad:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f01028af:	89 da                	mov    %ebx,%edx
f01028b1:	89 f8                	mov    %edi,%eax
f01028b3:	e8 66 e2 ff ff       	call   f0100b1e <check_va2pa>
f01028b8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01028bb:	74 19                	je     f01028d6 <mem_init+0x1645>
f01028bd:	68 c4 6e 10 f0       	push   $0xf0106ec4
f01028c2:	68 36 63 10 f0       	push   $0xf0106336
f01028c7:	68 60 03 00 00       	push   $0x360
f01028cc:	68 10 63 10 f0       	push   $0xf0106310
f01028d1:	e8 6a d7 ff ff       	call   f0100040 <_panic>
f01028d6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01028dc:	39 de                	cmp    %ebx,%esi
f01028de:	75 cf                	jne    f01028af <mem_init+0x161e>
f01028e0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01028e3:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f01028ea:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f01028f1:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f01028f7:	81 fe 00 c0 26 f0    	cmp    $0xf026c000,%esi
f01028fd:	0f 85 2d ff ff ff    	jne    f0102830 <mem_init+0x159f>
f0102903:	b8 00 00 00 00       	mov    $0x0,%eax
f0102908:	eb 2a                	jmp    f0102934 <mem_init+0x16a3>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010290a:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102910:	83 fa 04             	cmp    $0x4,%edx
f0102913:	77 1f                	ja     f0102934 <mem_init+0x16a3>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102915:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102919:	75 7e                	jne    f0102999 <mem_init+0x1708>
f010291b:	68 8b 66 10 f0       	push   $0xf010668b
f0102920:	68 36 63 10 f0       	push   $0xf0106336
f0102925:	68 6b 03 00 00       	push   $0x36b
f010292a:	68 10 63 10 f0       	push   $0xf0106310
f010292f:	e8 0c d7 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102934:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102939:	76 3f                	jbe    f010297a <mem_init+0x16e9>
				assert(pgdir[i] & PTE_P);
f010293b:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010293e:	f6 c2 01             	test   $0x1,%dl
f0102941:	75 19                	jne    f010295c <mem_init+0x16cb>
f0102943:	68 8b 66 10 f0       	push   $0xf010668b
f0102948:	68 36 63 10 f0       	push   $0xf0106336
f010294d:	68 6f 03 00 00       	push   $0x36f
f0102952:	68 10 63 10 f0       	push   $0xf0106310
f0102957:	e8 e4 d6 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f010295c:	f6 c2 02             	test   $0x2,%dl
f010295f:	75 38                	jne    f0102999 <mem_init+0x1708>
f0102961:	68 9c 66 10 f0       	push   $0xf010669c
f0102966:	68 36 63 10 f0       	push   $0xf0106336
f010296b:	68 70 03 00 00       	push   $0x370
f0102970:	68 10 63 10 f0       	push   $0xf0106310
f0102975:	e8 c6 d6 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f010297a:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f010297e:	74 19                	je     f0102999 <mem_init+0x1708>
f0102980:	68 ad 66 10 f0       	push   $0xf01066ad
f0102985:	68 36 63 10 f0       	push   $0xf0106336
f010298a:	68 72 03 00 00       	push   $0x372
f010298f:	68 10 63 10 f0       	push   $0xf0106310
f0102994:	e8 a7 d6 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102999:	83 c0 01             	add    $0x1,%eax
f010299c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01029a1:	0f 86 63 ff ff ff    	jbe    f010290a <mem_init+0x1679>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01029a7:	83 ec 0c             	sub    $0xc,%esp
f01029aa:	68 e8 6e 10 f0       	push   $0xf0106ee8
f01029af:	e8 d4 0c 00 00       	call   f0103688 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01029b4:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029b9:	83 c4 10             	add    $0x10,%esp
f01029bc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029c1:	77 15                	ja     f01029d8 <mem_init+0x1747>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029c3:	50                   	push   %eax
f01029c4:	68 88 5d 10 f0       	push   $0xf0105d88
f01029c9:	68 02 01 00 00       	push   $0x102
f01029ce:	68 10 63 10 f0       	push   $0xf0106310
f01029d3:	e8 68 d6 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01029d8:	05 00 00 00 10       	add    $0x10000000,%eax
f01029dd:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01029e0:	b8 00 00 00 00       	mov    $0x0,%eax
f01029e5:	e8 98 e1 ff ff       	call   f0100b82 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01029ea:	0f 20 c0             	mov    %cr0,%eax
f01029ed:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01029f0:	0d 23 00 05 80       	or     $0x80050023,%eax
f01029f5:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01029f8:	83 ec 0c             	sub    $0xc,%esp
f01029fb:	6a 00                	push   $0x0
f01029fd:	e8 18 e5 ff ff       	call   f0100f1a <page_alloc>
f0102a02:	89 c3                	mov    %eax,%ebx
f0102a04:	83 c4 10             	add    $0x10,%esp
f0102a07:	85 c0                	test   %eax,%eax
f0102a09:	75 19                	jne    f0102a24 <mem_init+0x1793>
f0102a0b:	68 56 64 10 f0       	push   $0xf0106456
f0102a10:	68 36 63 10 f0       	push   $0xf0106336
f0102a15:	68 48 04 00 00       	push   $0x448
f0102a1a:	68 10 63 10 f0       	push   $0xf0106310
f0102a1f:	e8 1c d6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102a24:	83 ec 0c             	sub    $0xc,%esp
f0102a27:	6a 00                	push   $0x0
f0102a29:	e8 ec e4 ff ff       	call   f0100f1a <page_alloc>
f0102a2e:	89 c7                	mov    %eax,%edi
f0102a30:	83 c4 10             	add    $0x10,%esp
f0102a33:	85 c0                	test   %eax,%eax
f0102a35:	75 19                	jne    f0102a50 <mem_init+0x17bf>
f0102a37:	68 6c 64 10 f0       	push   $0xf010646c
f0102a3c:	68 36 63 10 f0       	push   $0xf0106336
f0102a41:	68 49 04 00 00       	push   $0x449
f0102a46:	68 10 63 10 f0       	push   $0xf0106310
f0102a4b:	e8 f0 d5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102a50:	83 ec 0c             	sub    $0xc,%esp
f0102a53:	6a 00                	push   $0x0
f0102a55:	e8 c0 e4 ff ff       	call   f0100f1a <page_alloc>
f0102a5a:	89 c6                	mov    %eax,%esi
f0102a5c:	83 c4 10             	add    $0x10,%esp
f0102a5f:	85 c0                	test   %eax,%eax
f0102a61:	75 19                	jne    f0102a7c <mem_init+0x17eb>
f0102a63:	68 82 64 10 f0       	push   $0xf0106482
f0102a68:	68 36 63 10 f0       	push   $0xf0106336
f0102a6d:	68 4a 04 00 00       	push   $0x44a
f0102a72:	68 10 63 10 f0       	push   $0xf0106310
f0102a77:	e8 c4 d5 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102a7c:	83 ec 0c             	sub    $0xc,%esp
f0102a7f:	53                   	push   %ebx
f0102a80:	e8 ff e4 ff ff       	call   f0100f84 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a85:	89 f8                	mov    %edi,%eax
f0102a87:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f0102a8d:	c1 f8 03             	sar    $0x3,%eax
f0102a90:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a93:	89 c2                	mov    %eax,%edx
f0102a95:	c1 ea 0c             	shr    $0xc,%edx
f0102a98:	83 c4 10             	add    $0x10,%esp
f0102a9b:	3b 15 08 af 22 f0    	cmp    0xf022af08,%edx
f0102aa1:	72 12                	jb     f0102ab5 <mem_init+0x1824>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102aa3:	50                   	push   %eax
f0102aa4:	68 64 5d 10 f0       	push   $0xf0105d64
f0102aa9:	6a 58                	push   $0x58
f0102aab:	68 1c 63 10 f0       	push   $0xf010631c
f0102ab0:	e8 8b d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102ab5:	83 ec 04             	sub    $0x4,%esp
f0102ab8:	68 00 10 00 00       	push   $0x1000
f0102abd:	6a 01                	push   $0x1
f0102abf:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102ac4:	50                   	push   %eax
f0102ac5:	e8 c1 25 00 00       	call   f010508b <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102aca:	89 f0                	mov    %esi,%eax
f0102acc:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f0102ad2:	c1 f8 03             	sar    $0x3,%eax
f0102ad5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ad8:	89 c2                	mov    %eax,%edx
f0102ada:	c1 ea 0c             	shr    $0xc,%edx
f0102add:	83 c4 10             	add    $0x10,%esp
f0102ae0:	3b 15 08 af 22 f0    	cmp    0xf022af08,%edx
f0102ae6:	72 12                	jb     f0102afa <mem_init+0x1869>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ae8:	50                   	push   %eax
f0102ae9:	68 64 5d 10 f0       	push   $0xf0105d64
f0102aee:	6a 58                	push   $0x58
f0102af0:	68 1c 63 10 f0       	push   $0xf010631c
f0102af5:	e8 46 d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102afa:	83 ec 04             	sub    $0x4,%esp
f0102afd:	68 00 10 00 00       	push   $0x1000
f0102b02:	6a 02                	push   $0x2
f0102b04:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b09:	50                   	push   %eax
f0102b0a:	e8 7c 25 00 00       	call   f010508b <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102b0f:	6a 02                	push   $0x2
f0102b11:	68 00 10 00 00       	push   $0x1000
f0102b16:	57                   	push   %edi
f0102b17:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0102b1d:	e8 9c e6 ff ff       	call   f01011be <page_insert>
	assert(pp1->pp_ref == 1);
f0102b22:	83 c4 20             	add    $0x20,%esp
f0102b25:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b2a:	74 19                	je     f0102b45 <mem_init+0x18b4>
f0102b2c:	68 63 65 10 f0       	push   $0xf0106563
f0102b31:	68 36 63 10 f0       	push   $0xf0106336
f0102b36:	68 4f 04 00 00       	push   $0x44f
f0102b3b:	68 10 63 10 f0       	push   $0xf0106310
f0102b40:	e8 fb d4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102b45:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102b4c:	01 01 01 
f0102b4f:	74 19                	je     f0102b6a <mem_init+0x18d9>
f0102b51:	68 08 6f 10 f0       	push   $0xf0106f08
f0102b56:	68 36 63 10 f0       	push   $0xf0106336
f0102b5b:	68 50 04 00 00       	push   $0x450
f0102b60:	68 10 63 10 f0       	push   $0xf0106310
f0102b65:	e8 d6 d4 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102b6a:	6a 02                	push   $0x2
f0102b6c:	68 00 10 00 00       	push   $0x1000
f0102b71:	56                   	push   %esi
f0102b72:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0102b78:	e8 41 e6 ff ff       	call   f01011be <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102b7d:	83 c4 10             	add    $0x10,%esp
f0102b80:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102b87:	02 02 02 
f0102b8a:	74 19                	je     f0102ba5 <mem_init+0x1914>
f0102b8c:	68 2c 6f 10 f0       	push   $0xf0106f2c
f0102b91:	68 36 63 10 f0       	push   $0xf0106336
f0102b96:	68 52 04 00 00       	push   $0x452
f0102b9b:	68 10 63 10 f0       	push   $0xf0106310
f0102ba0:	e8 9b d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102ba5:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102baa:	74 19                	je     f0102bc5 <mem_init+0x1934>
f0102bac:	68 85 65 10 f0       	push   $0xf0106585
f0102bb1:	68 36 63 10 f0       	push   $0xf0106336
f0102bb6:	68 53 04 00 00       	push   $0x453
f0102bbb:	68 10 63 10 f0       	push   $0xf0106310
f0102bc0:	e8 7b d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102bc5:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102bca:	74 19                	je     f0102be5 <mem_init+0x1954>
f0102bcc:	68 fa 65 10 f0       	push   $0xf01065fa
f0102bd1:	68 36 63 10 f0       	push   $0xf0106336
f0102bd6:	68 54 04 00 00       	push   $0x454
f0102bdb:	68 10 63 10 f0       	push   $0xf0106310
f0102be0:	e8 5b d4 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102be5:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102bec:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bef:	89 f0                	mov    %esi,%eax
f0102bf1:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f0102bf7:	c1 f8 03             	sar    $0x3,%eax
f0102bfa:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bfd:	89 c2                	mov    %eax,%edx
f0102bff:	c1 ea 0c             	shr    $0xc,%edx
f0102c02:	3b 15 08 af 22 f0    	cmp    0xf022af08,%edx
f0102c08:	72 12                	jb     f0102c1c <mem_init+0x198b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c0a:	50                   	push   %eax
f0102c0b:	68 64 5d 10 f0       	push   $0xf0105d64
f0102c10:	6a 58                	push   $0x58
f0102c12:	68 1c 63 10 f0       	push   $0xf010631c
f0102c17:	e8 24 d4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c1c:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c23:	03 03 03 
f0102c26:	74 19                	je     f0102c41 <mem_init+0x19b0>
f0102c28:	68 50 6f 10 f0       	push   $0xf0106f50
f0102c2d:	68 36 63 10 f0       	push   $0xf0106336
f0102c32:	68 56 04 00 00       	push   $0x456
f0102c37:	68 10 63 10 f0       	push   $0xf0106310
f0102c3c:	e8 ff d3 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c41:	83 ec 08             	sub    $0x8,%esp
f0102c44:	68 00 10 00 00       	push   $0x1000
f0102c49:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0102c4f:	e8 1c e5 ff ff       	call   f0101170 <page_remove>
	assert(pp2->pp_ref == 0);
f0102c54:	83 c4 10             	add    $0x10,%esp
f0102c57:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102c5c:	74 19                	je     f0102c77 <mem_init+0x19e6>
f0102c5e:	68 e9 65 10 f0       	push   $0xf01065e9
f0102c63:	68 36 63 10 f0       	push   $0xf0106336
f0102c68:	68 58 04 00 00       	push   $0x458
f0102c6d:	68 10 63 10 f0       	push   $0xf0106310
f0102c72:	e8 c9 d3 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c77:	8b 0d 0c af 22 f0    	mov    0xf022af0c,%ecx
f0102c7d:	8b 11                	mov    (%ecx),%edx
f0102c7f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102c85:	89 d8                	mov    %ebx,%eax
f0102c87:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f0102c8d:	c1 f8 03             	sar    $0x3,%eax
f0102c90:	c1 e0 0c             	shl    $0xc,%eax
f0102c93:	39 c2                	cmp    %eax,%edx
f0102c95:	74 19                	je     f0102cb0 <mem_init+0x1a1f>
f0102c97:	68 10 69 10 f0       	push   $0xf0106910
f0102c9c:	68 36 63 10 f0       	push   $0xf0106336
f0102ca1:	68 5b 04 00 00       	push   $0x45b
f0102ca6:	68 10 63 10 f0       	push   $0xf0106310
f0102cab:	e8 90 d3 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102cb0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102cb6:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102cbb:	74 19                	je     f0102cd6 <mem_init+0x1a45>
f0102cbd:	68 74 65 10 f0       	push   $0xf0106574
f0102cc2:	68 36 63 10 f0       	push   $0xf0106336
f0102cc7:	68 5d 04 00 00       	push   $0x45d
f0102ccc:	68 10 63 10 f0       	push   $0xf0106310
f0102cd1:	e8 6a d3 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102cd6:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102cdc:	83 ec 0c             	sub    $0xc,%esp
f0102cdf:	53                   	push   %ebx
f0102ce0:	e8 9f e2 ff ff       	call   f0100f84 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102ce5:	c7 04 24 7c 6f 10 f0 	movl   $0xf0106f7c,(%esp)
f0102cec:	e8 97 09 00 00       	call   f0103688 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102cf1:	83 c4 10             	add    $0x10,%esp
f0102cf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102cf7:	5b                   	pop    %ebx
f0102cf8:	5e                   	pop    %esi
f0102cf9:	5f                   	pop    %edi
f0102cfa:	5d                   	pop    %ebp
f0102cfb:	c3                   	ret    

f0102cfc <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102cfc:	55                   	push   %ebp
f0102cfd:	89 e5                	mov    %esp,%ebp
f0102cff:	57                   	push   %edi
f0102d00:	56                   	push   %esi
f0102d01:	53                   	push   %ebx
f0102d02:	83 ec 1c             	sub    $0x1c,%esp
f0102d05:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102d08:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
	
	uint32_t mem_start = (uint32_t) ROUNDDOWN(va, PGSIZE); 
f0102d0b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102d0e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t mem_end = (uint32_t) ROUNDUP(va+len, PGSIZE);
f0102d14:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d17:	03 45 10             	add    0x10(%ebp),%eax
f0102d1a:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102d1f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102d24:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t i;
	while (mem_start < mem_end) {
f0102d27:	eb 43                	jmp    f0102d6c <user_mem_check+0x70>
		pte_t *page_tbl_entry = pgdir_walk(env->env_pgdir, (void*)mem_start, 0);
f0102d29:	83 ec 04             	sub    $0x4,%esp
f0102d2c:	6a 00                	push   $0x0
f0102d2e:	53                   	push   %ebx
f0102d2f:	ff 77 60             	pushl  0x60(%edi)
f0102d32:	e8 83 e2 ff ff       	call   f0100fba <pgdir_walk>
		
		if ((mem_start>=ULIM) || !page_tbl_entry || !(*page_tbl_entry & PTE_P) || ((*page_tbl_entry & perm) != perm)) {
f0102d37:	83 c4 10             	add    $0x10,%esp
f0102d3a:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102d40:	77 10                	ja     f0102d52 <user_mem_check+0x56>
f0102d42:	85 c0                	test   %eax,%eax
f0102d44:	74 0c                	je     f0102d52 <user_mem_check+0x56>
f0102d46:	8b 00                	mov    (%eax),%eax
f0102d48:	a8 01                	test   $0x1,%al
f0102d4a:	74 06                	je     f0102d52 <user_mem_check+0x56>
f0102d4c:	21 f0                	and    %esi,%eax
f0102d4e:	39 c6                	cmp    %eax,%esi
f0102d50:	74 14                	je     f0102d66 <user_mem_check+0x6a>
			user_mem_check_addr = (mem_start<(uint32_t)va?(uint32_t)va:mem_start);
f0102d52:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102d55:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0102d59:	89 1d 3c a2 22 f0    	mov    %ebx,0xf022a23c
			return -E_FAULT;
f0102d5f:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102d64:	eb 10                	jmp    f0102d76 <user_mem_check+0x7a>
		}
mem_start+=PGSIZE;
f0102d66:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// LAB 3: Your code here.
	
	uint32_t mem_start = (uint32_t) ROUNDDOWN(va, PGSIZE); 
	uint32_t mem_end = (uint32_t) ROUNDUP(va+len, PGSIZE);
	uint32_t i;
	while (mem_start < mem_end) {
f0102d6c:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102d6f:	72 b8                	jb     f0102d29 <user_mem_check+0x2d>
			return -E_FAULT;
		}
mem_start+=PGSIZE;
	}
	
	return 0;
f0102d71:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102d76:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d79:	5b                   	pop    %ebx
f0102d7a:	5e                   	pop    %esi
f0102d7b:	5f                   	pop    %edi
f0102d7c:	5d                   	pop    %ebp
f0102d7d:	c3                   	ret    

f0102d7e <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102d7e:	55                   	push   %ebp
f0102d7f:	89 e5                	mov    %esp,%ebp
f0102d81:	53                   	push   %ebx
f0102d82:	83 ec 04             	sub    $0x4,%esp
f0102d85:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102d88:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d8b:	83 c8 04             	or     $0x4,%eax
f0102d8e:	50                   	push   %eax
f0102d8f:	ff 75 10             	pushl  0x10(%ebp)
f0102d92:	ff 75 0c             	pushl  0xc(%ebp)
f0102d95:	53                   	push   %ebx
f0102d96:	e8 61 ff ff ff       	call   f0102cfc <user_mem_check>
f0102d9b:	83 c4 10             	add    $0x10,%esp
f0102d9e:	85 c0                	test   %eax,%eax
f0102da0:	79 21                	jns    f0102dc3 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102da2:	83 ec 04             	sub    $0x4,%esp
f0102da5:	ff 35 3c a2 22 f0    	pushl  0xf022a23c
f0102dab:	ff 73 48             	pushl  0x48(%ebx)
f0102dae:	68 a8 6f 10 f0       	push   $0xf0106fa8
f0102db3:	e8 d0 08 00 00       	call   f0103688 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102db8:	89 1c 24             	mov    %ebx,(%esp)
f0102dbb:	e8 3c 06 00 00       	call   f01033fc <env_destroy>
f0102dc0:	83 c4 10             	add    $0x10,%esp
	}
}
f0102dc3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102dc6:	c9                   	leave  
f0102dc7:	c3                   	ret    

f0102dc8 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102dc8:	55                   	push   %ebp
f0102dc9:	89 e5                	mov    %esp,%ebp
f0102dcb:	57                   	push   %edi
f0102dcc:	56                   	push   %esi
f0102dcd:	53                   	push   %ebx
f0102dce:	83 ec 0c             	sub    $0xc,%esp
f0102dd1:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
f0102dd3:	89 d3                	mov    %edx,%ebx
f0102dd5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102ddb:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102de2:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for (; begin < end; begin += PGSIZE) {
f0102de8:	eb 3d                	jmp    f0102e27 <region_alloc+0x5f>
		struct PageInfo *pg = page_alloc(0);
f0102dea:	83 ec 0c             	sub    $0xc,%esp
f0102ded:	6a 00                	push   $0x0
f0102def:	e8 26 e1 ff ff       	call   f0100f1a <page_alloc>
		if (!pg) panic("region_alloc failed!");
f0102df4:	83 c4 10             	add    $0x10,%esp
f0102df7:	85 c0                	test   %eax,%eax
f0102df9:	75 17                	jne    f0102e12 <region_alloc+0x4a>
f0102dfb:	83 ec 04             	sub    $0x4,%esp
f0102dfe:	68 dd 6f 10 f0       	push   $0xf0106fdd
f0102e03:	68 12 01 00 00       	push   $0x112
f0102e08:	68 f2 6f 10 f0       	push   $0xf0106ff2
f0102e0d:	e8 2e d2 ff ff       	call   f0100040 <_panic>
		page_insert(e->env_pgdir, pg, begin, PTE_W | PTE_U);
f0102e12:	6a 06                	push   $0x6
f0102e14:	53                   	push   %ebx
f0102e15:	50                   	push   %eax
f0102e16:	ff 77 60             	pushl  0x60(%edi)
f0102e19:	e8 a0 e3 ff ff       	call   f01011be <page_insert>
static void
region_alloc(struct Env *e, void *va, size_t len)
{
	// LAB 3: Your code here.
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
	for (; begin < end; begin += PGSIZE) {
f0102e1e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e24:	83 c4 10             	add    $0x10,%esp
f0102e27:	39 f3                	cmp    %esi,%ebx
f0102e29:	72 bf                	jb     f0102dea <region_alloc+0x22>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0102e2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e2e:	5b                   	pop    %ebx
f0102e2f:	5e                   	pop    %esi
f0102e30:	5f                   	pop    %edi
f0102e31:	5d                   	pop    %ebp
f0102e32:	c3                   	ret    

f0102e33 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102e33:	55                   	push   %ebp
f0102e34:	89 e5                	mov    %esp,%ebp
f0102e36:	56                   	push   %esi
f0102e37:	53                   	push   %ebx
f0102e38:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e3b:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102e3e:	85 c0                	test   %eax,%eax
f0102e40:	75 1a                	jne    f0102e5c <envid2env+0x29>
		*env_store = curenv;
f0102e42:	e8 67 28 00 00       	call   f01056ae <cpunum>
f0102e47:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e4a:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0102e50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102e53:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102e55:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e5a:	eb 70                	jmp    f0102ecc <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102e5c:	89 c3                	mov    %eax,%ebx
f0102e5e:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102e64:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102e67:	03 1d 48 a2 22 f0    	add    0xf022a248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102e6d:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102e71:	74 05                	je     f0102e78 <envid2env+0x45>
f0102e73:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102e76:	74 10                	je     f0102e88 <envid2env+0x55>
		*env_store = 0;
f0102e78:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e7b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102e81:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102e86:	eb 44                	jmp    f0102ecc <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102e88:	84 d2                	test   %dl,%dl
f0102e8a:	74 36                	je     f0102ec2 <envid2env+0x8f>
f0102e8c:	e8 1d 28 00 00       	call   f01056ae <cpunum>
f0102e91:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e94:	3b 98 28 b0 22 f0    	cmp    -0xfdd4fd8(%eax),%ebx
f0102e9a:	74 26                	je     f0102ec2 <envid2env+0x8f>
f0102e9c:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102e9f:	e8 0a 28 00 00       	call   f01056ae <cpunum>
f0102ea4:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ea7:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0102ead:	3b 70 48             	cmp    0x48(%eax),%esi
f0102eb0:	74 10                	je     f0102ec2 <envid2env+0x8f>
		*env_store = 0;
f0102eb2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102eb5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102ebb:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102ec0:	eb 0a                	jmp    f0102ecc <envid2env+0x99>
	}

	*env_store = e;
f0102ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ec5:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102ec7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102ecc:	5b                   	pop    %ebx
f0102ecd:	5e                   	pop    %esi
f0102ece:	5d                   	pop    %ebp
f0102ecf:	c3                   	ret    

f0102ed0 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102ed0:	55                   	push   %ebp
f0102ed1:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102ed3:	b8 20 f3 11 f0       	mov    $0xf011f320,%eax
f0102ed8:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102edb:	b8 23 00 00 00       	mov    $0x23,%eax
f0102ee0:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102ee2:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102ee4:	b8 10 00 00 00       	mov    $0x10,%eax
f0102ee9:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102eeb:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102eed:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102eef:	ea f6 2e 10 f0 08 00 	ljmp   $0x8,$0xf0102ef6
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102ef6:	b8 00 00 00 00       	mov    $0x0,%eax
f0102efb:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102efe:	5d                   	pop    %ebp
f0102eff:	c3                   	ret    

f0102f00 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102f00:	55                   	push   %ebp
f0102f01:	89 e5                	mov    %esp,%ebp
f0102f03:	56                   	push   %esi
f0102f04:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV-1;i >= 0; --i) {
		envs[i].env_id = 0;
f0102f05:	8b 35 48 a2 22 f0    	mov    0xf022a248,%esi
f0102f0b:	8b 15 4c a2 22 f0    	mov    0xf022a24c,%edx
f0102f11:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102f17:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102f1a:	89 c1                	mov    %eax,%ecx
f0102f1c:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0102f23:	89 50 44             	mov    %edx,0x44(%eax)
f0102f26:	83 e8 7c             	sub    $0x7c,%eax
		 env_free_list = envs+i;
f0102f29:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV-1;i >= 0; --i) {
f0102f2b:	39 d8                	cmp    %ebx,%eax
f0102f2d:	75 eb                	jne    f0102f1a <env_init+0x1a>
f0102f2f:	89 35 4c a2 22 f0    	mov    %esi,0xf022a24c
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		 env_free_list = envs+i;
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0102f35:	e8 96 ff ff ff       	call   f0102ed0 <env_init_percpu>
}
f0102f3a:	5b                   	pop    %ebx
f0102f3b:	5e                   	pop    %esi
f0102f3c:	5d                   	pop    %ebp
f0102f3d:	c3                   	ret    

f0102f3e <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102f3e:	55                   	push   %ebp
f0102f3f:	89 e5                	mov    %esp,%ebp
f0102f41:	53                   	push   %ebx
f0102f42:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102f45:	8b 1d 4c a2 22 f0    	mov    0xf022a24c,%ebx
f0102f4b:	85 db                	test   %ebx,%ebx
f0102f4d:	0f 84 93 01 00 00    	je     f01030e6 <env_alloc+0x1a8>
	 
	struct PageInfo *p = NULL;
	//p = page_alloc(ALLOC_ZERO);
	
	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO))){
f0102f53:	83 ec 0c             	sub    $0xc,%esp
f0102f56:	6a 01                	push   $0x1
f0102f58:	e8 bd df ff ff       	call   f0100f1a <page_alloc>
f0102f5d:	83 c4 10             	add    $0x10,%esp
f0102f60:	85 c0                	test   %eax,%eax
f0102f62:	75 16                	jne    f0102f7a <env_alloc+0x3c>
		panic("env_alloc: %e", E_NO_MEM);
f0102f64:	6a 04                	push   $0x4
f0102f66:	68 fd 6f 10 f0       	push   $0xf0106ffd
f0102f6b:	68 ad 00 00 00       	push   $0xad
f0102f70:	68 f2 6f 10 f0       	push   $0xf0106ff2
f0102f75:	e8 c6 d0 ff ff       	call   f0100040 <_panic>
		return -E_NO_MEM;
	}
	
	p->pp_ref++;
f0102f7a:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f7f:	2b 05 10 af 22 f0    	sub    0xf022af10,%eax
f0102f85:	c1 f8 03             	sar    $0x3,%eax
f0102f88:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f8b:	89 c2                	mov    %eax,%edx
f0102f8d:	c1 ea 0c             	shr    $0xc,%edx
f0102f90:	3b 15 08 af 22 f0    	cmp    0xf022af08,%edx
f0102f96:	72 12                	jb     f0102faa <env_alloc+0x6c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f98:	50                   	push   %eax
f0102f99:	68 64 5d 10 f0       	push   $0xf0105d64
f0102f9e:	6a 58                	push   $0x58
f0102fa0:	68 1c 63 10 f0       	push   $0xf010631c
f0102fa5:	e8 96 d0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102faa:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = page2kva(p);
f0102faf:	89 43 60             	mov    %eax,0x60(%ebx)
memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0102fb2:	83 ec 04             	sub    $0x4,%esp
f0102fb5:	68 00 10 00 00       	push   $0x1000
f0102fba:	ff 35 0c af 22 f0    	pushl  0xf022af0c
f0102fc0:	50                   	push   %eax
f0102fc1:	e8 7a 21 00 00       	call   f0105140 <memcpy>

	
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102fc6:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102fc9:	83 c4 10             	add    $0x10,%esp
f0102fcc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102fd1:	77 15                	ja     f0102fe8 <env_alloc+0xaa>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fd3:	50                   	push   %eax
f0102fd4:	68 88 5d 10 f0       	push   $0xf0105d88
f0102fd9:	68 b6 00 00 00       	push   $0xb6
f0102fde:	68 f2 6f 10 f0       	push   $0xf0106ff2
f0102fe3:	e8 58 d0 ff ff       	call   f0100040 <_panic>
f0102fe8:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102fee:	83 ca 05             	or     $0x5,%edx
f0102ff1:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102ff7:	8b 43 48             	mov    0x48(%ebx),%eax
f0102ffa:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102fff:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103004:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103009:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010300c:	8b 0d 48 a2 22 f0    	mov    0xf022a248,%ecx
f0103012:	89 da                	mov    %ebx,%edx
f0103014:	29 ca                	sub    %ecx,%edx
f0103016:	c1 fa 02             	sar    $0x2,%edx
f0103019:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f010301f:	09 d0                	or     %edx,%eax
f0103021:	89 43 48             	mov    %eax,0x48(%ebx)
	cprintf("envs: %x, e: %x, e->env_id: %x\n", envs, e, e->env_id);
f0103024:	50                   	push   %eax
f0103025:	53                   	push   %ebx
f0103026:	51                   	push   %ecx
f0103027:	68 68 70 10 f0       	push   $0xf0107068
f010302c:	e8 57 06 00 00       	call   f0103688 <cprintf>

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103031:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103034:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103037:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010303e:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103045:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010304c:	83 c4 0c             	add    $0xc,%esp
f010304f:	6a 44                	push   $0x44
f0103051:	6a 00                	push   $0x0
f0103053:	53                   	push   %ebx
f0103054:	e8 32 20 00 00       	call   f010508b <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103059:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010305f:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103065:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010306b:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103072:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103078:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f010307f:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103083:	8b 43 44             	mov    0x44(%ebx),%eax
f0103086:	a3 4c a2 22 f0       	mov    %eax,0xf022a24c
	*newenv_store = e;
f010308b:	8b 45 08             	mov    0x8(%ebp),%eax
f010308e:	89 18                	mov    %ebx,(%eax)

	cprintf("env_id, %x\n", e->env_id);
f0103090:	83 c4 08             	add    $0x8,%esp
f0103093:	ff 73 48             	pushl  0x48(%ebx)
f0103096:	68 0b 70 10 f0       	push   $0xf010700b
f010309b:	e8 e8 05 00 00       	call   f0103688 <cprintf>
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01030a0:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01030a3:	e8 06 26 00 00       	call   f01056ae <cpunum>
f01030a8:	6b c0 74             	imul   $0x74,%eax,%eax
f01030ab:	83 c4 10             	add    $0x10,%esp
f01030ae:	ba 00 00 00 00       	mov    $0x0,%edx
f01030b3:	83 b8 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%eax)
f01030ba:	74 11                	je     f01030cd <env_alloc+0x18f>
f01030bc:	e8 ed 25 00 00       	call   f01056ae <cpunum>
f01030c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01030c4:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f01030ca:	8b 50 48             	mov    0x48(%eax),%edx
f01030cd:	83 ec 04             	sub    $0x4,%esp
f01030d0:	53                   	push   %ebx
f01030d1:	52                   	push   %edx
f01030d2:	68 17 70 10 f0       	push   $0xf0107017
f01030d7:	e8 ac 05 00 00       	call   f0103688 <cprintf>
	return 0;
f01030dc:	83 c4 10             	add    $0x10,%esp
f01030df:	b8 00 00 00 00       	mov    $0x0,%eax
f01030e4:	eb 05                	jmp    f01030eb <env_alloc+0x1ad>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01030e6:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
	*newenv_store = e;

	cprintf("env_id, %x\n", e->env_id);
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01030eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01030ee:	c9                   	leave  
f01030ef:	c3                   	ret    

f01030f0 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01030f0:	55                   	push   %ebp
f01030f1:	89 e5                	mov    %esp,%ebp
f01030f3:	57                   	push   %edi
f01030f4:	56                   	push   %esi
f01030f5:	53                   	push   %ebx
f01030f6:	83 ec 34             	sub    $0x34,%esp
f01030f9:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *new;
	env_alloc(&new, 0);
f01030fc:	6a 00                	push   $0x0
f01030fe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103101:	50                   	push   %eax
f0103102:	e8 37 fe ff ff       	call   f0102f3e <env_alloc>
cprintf("env .pointer value %x\n", new);
f0103107:	83 c4 08             	add    $0x8,%esp
f010310a:	ff 75 e4             	pushl  -0x1c(%ebp)
f010310d:	68 2c 70 10 f0       	push   $0xf010702c
f0103112:	e8 71 05 00 00       	call   f0103688 <cprintf>
	load_icode(new, binary);
f0103117:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010311a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
static void
load_icode(struct Env *e, uint8_t *binary)
{   
    struct Elf *ELFHDR = (struct Elf *) binary;
    struct Proghdr *ph, *eph;
    if (ELFHDR->e_magic != ELF_MAGIC){
f010311d:	83 c4 10             	add    $0x10,%esp
f0103120:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103126:	74 17                	je     f010313f <env_create+0x4f>
        panic("load_icode: ELF_MAGIC not matching");
f0103128:	83 ec 04             	sub    $0x4,%esp
f010312b:	68 88 70 10 f0       	push   $0xf0107088
f0103130:	68 39 01 00 00       	push   $0x139
f0103135:	68 f2 6f 10 f0       	push   $0xf0106ff2
f010313a:	e8 01 cf ff ff       	call   f0100040 <_panic>

}
    ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f010313f:	89 fb                	mov    %edi,%ebx
f0103141:	03 5f 1c             	add    0x1c(%edi),%ebx
    eph = ph + ELFHDR->e_phnum;
f0103144:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0103148:	c1 e6 05             	shl    $0x5,%esi
f010314b:	01 de                	add    %ebx,%esi
    lcr3(PADDR(e->env_pgdir));
f010314d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103150:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103153:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103158:	77 15                	ja     f010316f <env_create+0x7f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010315a:	50                   	push   %eax
f010315b:	68 88 5d 10 f0       	push   $0xf0105d88
f0103160:	68 3e 01 00 00       	push   $0x13e
f0103165:	68 f2 6f 10 f0       	push   $0xf0106ff2
f010316a:	e8 d1 ce ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010316f:	05 00 00 00 10       	add    $0x10000000,%eax
f0103174:	0f 22 d8             	mov    %eax,%cr3
f0103177:	eb 59                	jmp    f01031d2 <env_create+0xe2>
    for(;ph<eph;ph++)
    {
        if(ph->p_type==ELF_PROG_LOAD){
f0103179:	83 3b 01             	cmpl   $0x1,(%ebx)
f010317c:	75 2a                	jne    f01031a8 <env_create+0xb8>
            if(ph->p_filesz > ph->p_memsz)
f010317e:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103181:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103184:	76 17                	jbe    f010319d <env_create+0xad>
                panic("load_icode: ph->p_filesz > ph->p_memsz");
f0103186:	83 ec 04             	sub    $0x4,%esp
f0103189:	68 ac 70 10 f0       	push   $0xf01070ac
f010318e:	68 43 01 00 00       	push   $0x143
f0103193:	68 f2 6f 10 f0       	push   $0xf0106ff2
f0103198:	e8 a3 ce ff ff       	call   f0100040 <_panic>
            //cprintf("ph=%x",ph);
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f010319d:	8b 53 08             	mov    0x8(%ebx),%edx
f01031a0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01031a3:	e8 20 fc ff ff       	call   f0102dc8 <region_alloc>
            }
            memset((void *)ph->p_va, 0, ph->p_memsz);
f01031a8:	83 ec 04             	sub    $0x4,%esp
f01031ab:	ff 73 14             	pushl  0x14(%ebx)
f01031ae:	6a 00                	push   $0x0
f01031b0:	ff 73 08             	pushl  0x8(%ebx)
f01031b3:	e8 d3 1e 00 00       	call   f010508b <memset>
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);    }
f01031b8:	83 c4 0c             	add    $0xc,%esp
f01031bb:	ff 73 10             	pushl  0x10(%ebx)
f01031be:	89 f8                	mov    %edi,%eax
f01031c0:	03 43 04             	add    0x4(%ebx),%eax
f01031c3:	50                   	push   %eax
f01031c4:	ff 73 08             	pushl  0x8(%ebx)
f01031c7:	e8 74 1f 00 00       	call   f0105140 <memcpy>

}
    ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    eph = ph + ELFHDR->e_phnum;
    lcr3(PADDR(e->env_pgdir));
    for(;ph<eph;ph++)
f01031cc:	83 c3 20             	add    $0x20,%ebx
f01031cf:	83 c4 10             	add    $0x10,%esp
f01031d2:	39 de                	cmp    %ebx,%esi
f01031d4:	77 a3                	ja     f0103179 <env_create+0x89>
            //cprintf("ph=%x",ph);
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
            }
            memset((void *)ph->p_va, 0, ph->p_memsz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);    }
    lcr3(PADDR(kern_pgdir));
f01031d6:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031db:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031e0:	77 15                	ja     f01031f7 <env_create+0x107>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031e2:	50                   	push   %eax
f01031e3:	68 88 5d 10 f0       	push   $0xf0105d88
f01031e8:	68 49 01 00 00       	push   $0x149
f01031ed:	68 f2 6f 10 f0       	push   $0xf0106ff2
f01031f2:	e8 49 ce ff ff       	call   f0100040 <_panic>
f01031f7:	05 00 00 00 10       	add    $0x10000000,%eax
f01031fc:	0f 22 d8             	mov    %eax,%cr3
    e->env_tf.tf_eip = ELFHDR->e_entry;
f01031ff:	8b 47 18             	mov    0x18(%edi),%eax
f0103202:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0103205:	89 46 30             	mov    %eax,0x30(%esi)
    // Now map one page for the program's initial stack
    // at virtual address USTACKTOP - PGSIZE.
    // LAB 3: Your code here.
    region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103208:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010320d:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103212:	89 f0                	mov    %esi,%eax
f0103214:	e8 af fb ff ff       	call   f0102dc8 <region_alloc>
	// LAB 3: Your code here.
	struct Env *new;
	env_alloc(&new, 0);
cprintf("env .pointer value %x\n", new);
	load_icode(new, binary);
}
f0103219:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010321c:	5b                   	pop    %ebx
f010321d:	5e                   	pop    %esi
f010321e:	5f                   	pop    %edi
f010321f:	5d                   	pop    %ebp
f0103220:	c3                   	ret    

f0103221 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103221:	55                   	push   %ebp
f0103222:	89 e5                	mov    %esp,%ebp
f0103224:	57                   	push   %edi
f0103225:	56                   	push   %esi
f0103226:	53                   	push   %ebx
f0103227:	83 ec 1c             	sub    $0x1c,%esp
f010322a:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010322d:	e8 7c 24 00 00       	call   f01056ae <cpunum>
f0103232:	6b c0 74             	imul   $0x74,%eax,%eax
f0103235:	39 b8 28 b0 22 f0    	cmp    %edi,-0xfdd4fd8(%eax)
f010323b:	75 29                	jne    f0103266 <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f010323d:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103242:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103247:	77 15                	ja     f010325e <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103249:	50                   	push   %eax
f010324a:	68 88 5d 10 f0       	push   $0xf0105d88
f010324f:	68 71 01 00 00       	push   $0x171
f0103254:	68 f2 6f 10 f0       	push   $0xf0106ff2
f0103259:	e8 e2 cd ff ff       	call   f0100040 <_panic>
f010325e:	05 00 00 00 10       	add    $0x10000000,%eax
f0103263:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103266:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103269:	e8 40 24 00 00       	call   f01056ae <cpunum>
f010326e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103271:	ba 00 00 00 00       	mov    $0x0,%edx
f0103276:	83 b8 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%eax)
f010327d:	74 11                	je     f0103290 <env_free+0x6f>
f010327f:	e8 2a 24 00 00       	call   f01056ae <cpunum>
f0103284:	6b c0 74             	imul   $0x74,%eax,%eax
f0103287:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f010328d:	8b 50 48             	mov    0x48(%eax),%edx
f0103290:	83 ec 04             	sub    $0x4,%esp
f0103293:	53                   	push   %ebx
f0103294:	52                   	push   %edx
f0103295:	68 43 70 10 f0       	push   $0xf0107043
f010329a:	e8 e9 03 00 00       	call   f0103688 <cprintf>
f010329f:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01032a2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01032a9:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01032ac:	89 d0                	mov    %edx,%eax
f01032ae:	c1 e0 02             	shl    $0x2,%eax
f01032b1:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01032b4:	8b 47 60             	mov    0x60(%edi),%eax
f01032b7:	8b 34 90             	mov    (%eax,%edx,4),%esi
f01032ba:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01032c0:	0f 84 a8 00 00 00    	je     f010336e <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01032c6:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032cc:	89 f0                	mov    %esi,%eax
f01032ce:	c1 e8 0c             	shr    $0xc,%eax
f01032d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01032d4:	39 05 08 af 22 f0    	cmp    %eax,0xf022af08
f01032da:	77 15                	ja     f01032f1 <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032dc:	56                   	push   %esi
f01032dd:	68 64 5d 10 f0       	push   $0xf0105d64
f01032e2:	68 80 01 00 00       	push   $0x180
f01032e7:	68 f2 6f 10 f0       	push   $0xf0106ff2
f01032ec:	e8 4f cd ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01032f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01032f4:	c1 e0 16             	shl    $0x16,%eax
f01032f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01032fa:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01032ff:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103306:	01 
f0103307:	74 17                	je     f0103320 <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103309:	83 ec 08             	sub    $0x8,%esp
f010330c:	89 d8                	mov    %ebx,%eax
f010330e:	c1 e0 0c             	shl    $0xc,%eax
f0103311:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103314:	50                   	push   %eax
f0103315:	ff 77 60             	pushl  0x60(%edi)
f0103318:	e8 53 de ff ff       	call   f0101170 <page_remove>
f010331d:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103320:	83 c3 01             	add    $0x1,%ebx
f0103323:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103329:	75 d4                	jne    f01032ff <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010332b:	8b 47 60             	mov    0x60(%edi),%eax
f010332e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103331:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103338:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010333b:	3b 05 08 af 22 f0    	cmp    0xf022af08,%eax
f0103341:	72 14                	jb     f0103357 <env_free+0x136>
		panic("pa2page called with invalid pa");
f0103343:	83 ec 04             	sub    $0x4,%esp
f0103346:	68 dc 67 10 f0       	push   $0xf01067dc
f010334b:	6a 51                	push   $0x51
f010334d:	68 1c 63 10 f0       	push   $0xf010631c
f0103352:	e8 e9 cc ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f0103357:	83 ec 0c             	sub    $0xc,%esp
f010335a:	a1 10 af 22 f0       	mov    0xf022af10,%eax
f010335f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103362:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103365:	50                   	push   %eax
f0103366:	e8 2e dc ff ff       	call   f0100f99 <page_decref>
f010336b:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010336e:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103372:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103375:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010337a:	0f 85 29 ff ff ff    	jne    f01032a9 <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103380:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103383:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103388:	77 15                	ja     f010339f <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010338a:	50                   	push   %eax
f010338b:	68 88 5d 10 f0       	push   $0xf0105d88
f0103390:	68 8e 01 00 00       	push   $0x18e
f0103395:	68 f2 6f 10 f0       	push   $0xf0106ff2
f010339a:	e8 a1 cc ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f010339f:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01033a6:	05 00 00 00 10       	add    $0x10000000,%eax
f01033ab:	c1 e8 0c             	shr    $0xc,%eax
f01033ae:	3b 05 08 af 22 f0    	cmp    0xf022af08,%eax
f01033b4:	72 14                	jb     f01033ca <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f01033b6:	83 ec 04             	sub    $0x4,%esp
f01033b9:	68 dc 67 10 f0       	push   $0xf01067dc
f01033be:	6a 51                	push   $0x51
f01033c0:	68 1c 63 10 f0       	push   $0xf010631c
f01033c5:	e8 76 cc ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f01033ca:	83 ec 0c             	sub    $0xc,%esp
f01033cd:	8b 15 10 af 22 f0    	mov    0xf022af10,%edx
f01033d3:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01033d6:	50                   	push   %eax
f01033d7:	e8 bd db ff ff       	call   f0100f99 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01033dc:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01033e3:	a1 4c a2 22 f0       	mov    0xf022a24c,%eax
f01033e8:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01033eb:	89 3d 4c a2 22 f0    	mov    %edi,0xf022a24c
}
f01033f1:	83 c4 10             	add    $0x10,%esp
f01033f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033f7:	5b                   	pop    %ebx
f01033f8:	5e                   	pop    %esi
f01033f9:	5f                   	pop    %edi
f01033fa:	5d                   	pop    %ebp
f01033fb:	c3                   	ret    

f01033fc <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01033fc:	55                   	push   %ebp
f01033fd:	89 e5                	mov    %esp,%ebp
f01033ff:	53                   	push   %ebx
f0103400:	83 ec 04             	sub    $0x4,%esp
f0103403:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103406:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f010340a:	75 19                	jne    f0103425 <env_destroy+0x29>
f010340c:	e8 9d 22 00 00       	call   f01056ae <cpunum>
f0103411:	6b c0 74             	imul   $0x74,%eax,%eax
f0103414:	3b 98 28 b0 22 f0    	cmp    -0xfdd4fd8(%eax),%ebx
f010341a:	74 09                	je     f0103425 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f010341c:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103423:	eb 33                	jmp    f0103458 <env_destroy+0x5c>
	}

	env_free(e);
f0103425:	83 ec 0c             	sub    $0xc,%esp
f0103428:	53                   	push   %ebx
f0103429:	e8 f3 fd ff ff       	call   f0103221 <env_free>

	if (curenv == e) {
f010342e:	e8 7b 22 00 00       	call   f01056ae <cpunum>
f0103433:	6b c0 74             	imul   $0x74,%eax,%eax
f0103436:	83 c4 10             	add    $0x10,%esp
f0103439:	3b 98 28 b0 22 f0    	cmp    -0xfdd4fd8(%eax),%ebx
f010343f:	75 17                	jne    f0103458 <env_destroy+0x5c>
		curenv = NULL;
f0103441:	e8 68 22 00 00       	call   f01056ae <cpunum>
f0103446:	6b c0 74             	imul   $0x74,%eax,%eax
f0103449:	c7 80 28 b0 22 f0 00 	movl   $0x0,-0xfdd4fd8(%eax)
f0103450:	00 00 00 
		sched_yield();
f0103453:	e8 95 0b 00 00       	call   f0103fed <sched_yield>
	}
}
f0103458:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010345b:	c9                   	leave  
f010345c:	c3                   	ret    

f010345d <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010345d:	55                   	push   %ebp
f010345e:	89 e5                	mov    %esp,%ebp
f0103460:	53                   	push   %ebx
f0103461:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103464:	e8 45 22 00 00       	call   f01056ae <cpunum>
f0103469:	6b c0 74             	imul   $0x74,%eax,%eax
f010346c:	8b 98 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%ebx
f0103472:	e8 37 22 00 00       	call   f01056ae <cpunum>
f0103477:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f010347a:	8b 65 08             	mov    0x8(%ebp),%esp
f010347d:	61                   	popa   
f010347e:	07                   	pop    %es
f010347f:	1f                   	pop    %ds
f0103480:	83 c4 08             	add    $0x8,%esp
f0103483:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103484:	83 ec 04             	sub    $0x4,%esp
f0103487:	68 59 70 10 f0       	push   $0xf0107059
f010348c:	68 c4 01 00 00       	push   $0x1c4
f0103491:	68 f2 6f 10 f0       	push   $0xf0106ff2
f0103496:	e8 a5 cb ff ff       	call   f0100040 <_panic>

f010349b <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010349b:	55                   	push   %ebp
f010349c:	89 e5                	mov    %esp,%ebp
f010349e:	53                   	push   %ebx
f010349f:	83 ec 04             	sub    $0x4,%esp
f01034a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
    if (e->env_status == ENV_RUNNING)
f01034a5:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01034a9:	75 07                	jne    f01034b2 <env_run+0x17>
        e->env_status = ENV_RUNNABLE;
f01034ab:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
    curenv = e;
f01034b2:	e8 f7 21 00 00       	call   f01056ae <cpunum>
f01034b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01034ba:	89 98 28 b0 22 f0    	mov    %ebx,-0xfdd4fd8(%eax)
    e->env_status = ENV_RUNNING;
f01034c0:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
    e->env_runs++;
f01034c7:	83 43 58 01          	addl   $0x1,0x58(%ebx)

	    lcr3(PADDR(e->env_pgdir));
f01034cb:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01034ce:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034d3:	77 15                	ja     f01034ea <env_run+0x4f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034d5:	50                   	push   %eax
f01034d6:	68 88 5d 10 f0       	push   $0xf0105d88
f01034db:	68 d6 01 00 00       	push   $0x1d6
f01034e0:	68 f2 6f 10 f0       	push   $0xf0106ff2
f01034e5:	e8 56 cb ff ff       	call   f0100040 <_panic>
f01034ea:	05 00 00 00 10       	add    $0x10000000,%eax
f01034ef:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01034f2:	83 ec 0c             	sub    $0xc,%esp
f01034f5:	68 c0 f3 11 f0       	push   $0xf011f3c0
f01034fa:	e8 ba 24 00 00       	call   f01059b9 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01034ff:	f3 90                	pause  
unlock_kernel();
    env_pop_tf(&e->env_tf);
f0103501:	89 1c 24             	mov    %ebx,(%esp)
f0103504:	e8 54 ff ff ff       	call   f010345d <env_pop_tf>

f0103509 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103509:	55                   	push   %ebp
f010350a:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010350c:	ba 70 00 00 00       	mov    $0x70,%edx
f0103511:	8b 45 08             	mov    0x8(%ebp),%eax
f0103514:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103515:	ba 71 00 00 00       	mov    $0x71,%edx
f010351a:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010351b:	0f b6 c0             	movzbl %al,%eax
}
f010351e:	5d                   	pop    %ebp
f010351f:	c3                   	ret    

f0103520 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103520:	55                   	push   %ebp
f0103521:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103523:	ba 70 00 00 00       	mov    $0x70,%edx
f0103528:	8b 45 08             	mov    0x8(%ebp),%eax
f010352b:	ee                   	out    %al,(%dx)
f010352c:	ba 71 00 00 00       	mov    $0x71,%edx
f0103531:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103534:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103535:	5d                   	pop    %ebp
f0103536:	c3                   	ret    

f0103537 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103537:	55                   	push   %ebp
f0103538:	89 e5                	mov    %esp,%ebp
f010353a:	56                   	push   %esi
f010353b:	53                   	push   %ebx
f010353c:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f010353f:	66 a3 a8 f3 11 f0    	mov    %ax,0xf011f3a8
	if (!didinit)
f0103545:	80 3d 50 a2 22 f0 00 	cmpb   $0x0,0xf022a250
f010354c:	74 5a                	je     f01035a8 <irq_setmask_8259A+0x71>
f010354e:	89 c6                	mov    %eax,%esi
f0103550:	ba 21 00 00 00       	mov    $0x21,%edx
f0103555:	ee                   	out    %al,(%dx)
f0103556:	66 c1 e8 08          	shr    $0x8,%ax
f010355a:	ba a1 00 00 00       	mov    $0xa1,%edx
f010355f:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103560:	83 ec 0c             	sub    $0xc,%esp
f0103563:	68 d3 70 10 f0       	push   $0xf01070d3
f0103568:	e8 1b 01 00 00       	call   f0103688 <cprintf>
f010356d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103570:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103575:	0f b7 f6             	movzwl %si,%esi
f0103578:	f7 d6                	not    %esi
f010357a:	0f a3 de             	bt     %ebx,%esi
f010357d:	73 11                	jae    f0103590 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f010357f:	83 ec 08             	sub    $0x8,%esp
f0103582:	53                   	push   %ebx
f0103583:	68 97 75 10 f0       	push   $0xf0107597
f0103588:	e8 fb 00 00 00       	call   f0103688 <cprintf>
f010358d:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103590:	83 c3 01             	add    $0x1,%ebx
f0103593:	83 fb 10             	cmp    $0x10,%ebx
f0103596:	75 e2                	jne    f010357a <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103598:	83 ec 0c             	sub    $0xc,%esp
f010359b:	68 63 66 10 f0       	push   $0xf0106663
f01035a0:	e8 e3 00 00 00       	call   f0103688 <cprintf>
f01035a5:	83 c4 10             	add    $0x10,%esp
}
f01035a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01035ab:	5b                   	pop    %ebx
f01035ac:	5e                   	pop    %esi
f01035ad:	5d                   	pop    %ebp
f01035ae:	c3                   	ret    

f01035af <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f01035af:	c6 05 50 a2 22 f0 01 	movb   $0x1,0xf022a250
f01035b6:	ba 21 00 00 00       	mov    $0x21,%edx
f01035bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01035c0:	ee                   	out    %al,(%dx)
f01035c1:	ba a1 00 00 00       	mov    $0xa1,%edx
f01035c6:	ee                   	out    %al,(%dx)
f01035c7:	ba 20 00 00 00       	mov    $0x20,%edx
f01035cc:	b8 11 00 00 00       	mov    $0x11,%eax
f01035d1:	ee                   	out    %al,(%dx)
f01035d2:	ba 21 00 00 00       	mov    $0x21,%edx
f01035d7:	b8 20 00 00 00       	mov    $0x20,%eax
f01035dc:	ee                   	out    %al,(%dx)
f01035dd:	b8 04 00 00 00       	mov    $0x4,%eax
f01035e2:	ee                   	out    %al,(%dx)
f01035e3:	b8 03 00 00 00       	mov    $0x3,%eax
f01035e8:	ee                   	out    %al,(%dx)
f01035e9:	ba a0 00 00 00       	mov    $0xa0,%edx
f01035ee:	b8 11 00 00 00       	mov    $0x11,%eax
f01035f3:	ee                   	out    %al,(%dx)
f01035f4:	ba a1 00 00 00       	mov    $0xa1,%edx
f01035f9:	b8 28 00 00 00       	mov    $0x28,%eax
f01035fe:	ee                   	out    %al,(%dx)
f01035ff:	b8 02 00 00 00       	mov    $0x2,%eax
f0103604:	ee                   	out    %al,(%dx)
f0103605:	b8 01 00 00 00       	mov    $0x1,%eax
f010360a:	ee                   	out    %al,(%dx)
f010360b:	ba 20 00 00 00       	mov    $0x20,%edx
f0103610:	b8 68 00 00 00       	mov    $0x68,%eax
f0103615:	ee                   	out    %al,(%dx)
f0103616:	b8 0a 00 00 00       	mov    $0xa,%eax
f010361b:	ee                   	out    %al,(%dx)
f010361c:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103621:	b8 68 00 00 00       	mov    $0x68,%eax
f0103626:	ee                   	out    %al,(%dx)
f0103627:	b8 0a 00 00 00       	mov    $0xa,%eax
f010362c:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f010362d:	0f b7 05 a8 f3 11 f0 	movzwl 0xf011f3a8,%eax
f0103634:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103638:	74 13                	je     f010364d <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f010363a:	55                   	push   %ebp
f010363b:	89 e5                	mov    %esp,%ebp
f010363d:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103640:	0f b7 c0             	movzwl %ax,%eax
f0103643:	50                   	push   %eax
f0103644:	e8 ee fe ff ff       	call   f0103537 <irq_setmask_8259A>
f0103649:	83 c4 10             	add    $0x10,%esp
}
f010364c:	c9                   	leave  
f010364d:	f3 c3                	repz ret 

f010364f <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010364f:	55                   	push   %ebp
f0103650:	89 e5                	mov    %esp,%ebp
f0103652:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103655:	ff 75 08             	pushl  0x8(%ebp)
f0103658:	e8 f9 d0 ff ff       	call   f0100756 <cputchar>
	*cnt++;
}
f010365d:	83 c4 10             	add    $0x10,%esp
f0103660:	c9                   	leave  
f0103661:	c3                   	ret    

f0103662 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103662:	55                   	push   %ebp
f0103663:	89 e5                	mov    %esp,%ebp
f0103665:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103668:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap); 
f010366f:	ff 75 0c             	pushl  0xc(%ebp)
f0103672:	ff 75 08             	pushl  0x8(%ebp)
f0103675:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103678:	50                   	push   %eax
f0103679:	68 4f 36 10 f0       	push   $0xf010364f
f010367e:	e8 5a 13 00 00       	call   f01049dd <vprintfmt>
	return cnt;
}
f0103683:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103686:	c9                   	leave  
f0103687:	c3                   	ret    

f0103688 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103688:	55                   	push   %ebp
f0103689:	89 e5                	mov    %esp,%ebp
f010368b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010368e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);//vcprintf( const char *format, va_list arg );
f0103691:	50                   	push   %eax
f0103692:	ff 75 08             	pushl  0x8(%ebp)
f0103695:	e8 c8 ff ff ff       	call   f0103662 <vcprintf>
	va_end(ap);

	return cnt;
}
f010369a:	c9                   	leave  
f010369b:	c3                   	ret    

f010369c <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f010369c:	55                   	push   %ebp
f010369d:	89 e5                	mov    %esp,%ebp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	ts.ts_esp0 = KSTACKTOP;
f010369f:	b8 80 aa 22 f0       	mov    $0xf022aa80,%eax
f01036a4:	c7 05 84 aa 22 f0 00 	movl   $0xf0000000,0xf022aa84
f01036ab:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f01036ae:	66 c7 05 88 aa 22 f0 	movw   $0x10,0xf022aa88
f01036b5:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f01036b7:	66 c7 05 68 f3 11 f0 	movw   $0x67,0xf011f368
f01036be:	67 00 
f01036c0:	66 a3 6a f3 11 f0    	mov    %ax,0xf011f36a
f01036c6:	89 c2                	mov    %eax,%edx
f01036c8:	c1 ea 10             	shr    $0x10,%edx
f01036cb:	88 15 6c f3 11 f0    	mov    %dl,0xf011f36c
f01036d1:	c6 05 6e f3 11 f0 40 	movb   $0x40,0xf011f36e
f01036d8:	c1 e8 18             	shr    $0x18,%eax
f01036db:	a2 6f f3 11 f0       	mov    %al,0xf011f36f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f01036e0:	c6 05 6d f3 11 f0 89 	movb   $0x89,0xf011f36d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01036e7:	b8 28 00 00 00       	mov    $0x28,%eax
f01036ec:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01036ef:	b8 ac f3 11 f0       	mov    $0xf011f3ac,%eax
f01036f4:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
lidt(&idt_pd);
}
f01036f7:	5d                   	pop    %ebp
f01036f8:	c3                   	ret    

f01036f9 <trap_init>:



void
trap_init(void)
{
f01036f9:	55                   	push   %ebp
f01036fa:	89 e5                	mov    %esp,%ebp
	void i48();

	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	SETGATE(idt[0], 1, GD_KT, i0, 0);
f01036fc:	b8 b4 3e 10 f0       	mov    $0xf0103eb4,%eax
f0103701:	66 a3 60 a2 22 f0    	mov    %ax,0xf022a260
f0103707:	66 c7 05 62 a2 22 f0 	movw   $0x8,0xf022a262
f010370e:	08 00 
f0103710:	c6 05 64 a2 22 f0 00 	movb   $0x0,0xf022a264
f0103717:	c6 05 65 a2 22 f0 8f 	movb   $0x8f,0xf022a265
f010371e:	c1 e8 10             	shr    $0x10,%eax
f0103721:	66 a3 66 a2 22 f0    	mov    %ax,0xf022a266
	    SETGATE(idt[1], 1, GD_KT, i1, 0);
f0103727:	b8 ba 3e 10 f0       	mov    $0xf0103eba,%eax
f010372c:	66 a3 68 a2 22 f0    	mov    %ax,0xf022a268
f0103732:	66 c7 05 6a a2 22 f0 	movw   $0x8,0xf022a26a
f0103739:	08 00 
f010373b:	c6 05 6c a2 22 f0 00 	movb   $0x0,0xf022a26c
f0103742:	c6 05 6d a2 22 f0 8f 	movb   $0x8f,0xf022a26d
f0103749:	c1 e8 10             	shr    $0x10,%eax
f010374c:	66 a3 6e a2 22 f0    	mov    %ax,0xf022a26e
	    SETGATE(idt[3], 1, GD_KT, i3, 3);
f0103752:	b8 c0 3e 10 f0       	mov    $0xf0103ec0,%eax
f0103757:	66 a3 78 a2 22 f0    	mov    %ax,0xf022a278
f010375d:	66 c7 05 7a a2 22 f0 	movw   $0x8,0xf022a27a
f0103764:	08 00 
f0103766:	c6 05 7c a2 22 f0 00 	movb   $0x0,0xf022a27c
f010376d:	c6 05 7d a2 22 f0 ef 	movb   $0xef,0xf022a27d
f0103774:	c1 e8 10             	shr    $0x10,%eax
f0103777:	66 a3 7e a2 22 f0    	mov    %ax,0xf022a27e
	    SETGATE(idt[4], 1, GD_KT, i4, 0);
f010377d:	b8 c6 3e 10 f0       	mov    $0xf0103ec6,%eax
f0103782:	66 a3 80 a2 22 f0    	mov    %ax,0xf022a280
f0103788:	66 c7 05 82 a2 22 f0 	movw   $0x8,0xf022a282
f010378f:	08 00 
f0103791:	c6 05 84 a2 22 f0 00 	movb   $0x0,0xf022a284
f0103798:	c6 05 85 a2 22 f0 8f 	movb   $0x8f,0xf022a285
f010379f:	c1 e8 10             	shr    $0x10,%eax
f01037a2:	66 a3 86 a2 22 f0    	mov    %ax,0xf022a286
	    SETGATE(idt[5], 1, GD_KT, i5, 0);
f01037a8:	b8 cc 3e 10 f0       	mov    $0xf0103ecc,%eax
f01037ad:	66 a3 88 a2 22 f0    	mov    %ax,0xf022a288
f01037b3:	66 c7 05 8a a2 22 f0 	movw   $0x8,0xf022a28a
f01037ba:	08 00 
f01037bc:	c6 05 8c a2 22 f0 00 	movb   $0x0,0xf022a28c
f01037c3:	c6 05 8d a2 22 f0 8f 	movb   $0x8f,0xf022a28d
f01037ca:	c1 e8 10             	shr    $0x10,%eax
f01037cd:	66 a3 8e a2 22 f0    	mov    %ax,0xf022a28e
	    SETGATE(idt[6], 1, GD_KT, i6, 0);
f01037d3:	b8 d2 3e 10 f0       	mov    $0xf0103ed2,%eax
f01037d8:	66 a3 90 a2 22 f0    	mov    %ax,0xf022a290
f01037de:	66 c7 05 92 a2 22 f0 	movw   $0x8,0xf022a292
f01037e5:	08 00 
f01037e7:	c6 05 94 a2 22 f0 00 	movb   $0x0,0xf022a294
f01037ee:	c6 05 95 a2 22 f0 8f 	movb   $0x8f,0xf022a295
f01037f5:	c1 e8 10             	shr    $0x10,%eax
f01037f8:	66 a3 96 a2 22 f0    	mov    %ax,0xf022a296
	    SETGATE(idt[7], 1, GD_KT, i7, 0);
f01037fe:	b8 d8 3e 10 f0       	mov    $0xf0103ed8,%eax
f0103803:	66 a3 98 a2 22 f0    	mov    %ax,0xf022a298
f0103809:	66 c7 05 9a a2 22 f0 	movw   $0x8,0xf022a29a
f0103810:	08 00 
f0103812:	c6 05 9c a2 22 f0 00 	movb   $0x0,0xf022a29c
f0103819:	c6 05 9d a2 22 f0 8f 	movb   $0x8f,0xf022a29d
f0103820:	c1 e8 10             	shr    $0x10,%eax
f0103823:	66 a3 9e a2 22 f0    	mov    %ax,0xf022a29e
	    SETGATE(idt[8], 1, GD_KT, i8, 0);
f0103829:	b8 de 3e 10 f0       	mov    $0xf0103ede,%eax
f010382e:	66 a3 a0 a2 22 f0    	mov    %ax,0xf022a2a0
f0103834:	66 c7 05 a2 a2 22 f0 	movw   $0x8,0xf022a2a2
f010383b:	08 00 
f010383d:	c6 05 a4 a2 22 f0 00 	movb   $0x0,0xf022a2a4
f0103844:	c6 05 a5 a2 22 f0 8f 	movb   $0x8f,0xf022a2a5
f010384b:	c1 e8 10             	shr    $0x10,%eax
f010384e:	66 a3 a6 a2 22 f0    	mov    %ax,0xf022a2a6
	    SETGATE(idt[9], 1, GD_KT, i9, 0);
f0103854:	b8 e2 3e 10 f0       	mov    $0xf0103ee2,%eax
f0103859:	66 a3 a8 a2 22 f0    	mov    %ax,0xf022a2a8
f010385f:	66 c7 05 aa a2 22 f0 	movw   $0x8,0xf022a2aa
f0103866:	08 00 
f0103868:	c6 05 ac a2 22 f0 00 	movb   $0x0,0xf022a2ac
f010386f:	c6 05 ad a2 22 f0 8f 	movb   $0x8f,0xf022a2ad
f0103876:	c1 e8 10             	shr    $0x10,%eax
f0103879:	66 a3 ae a2 22 f0    	mov    %ax,0xf022a2ae
	    SETGATE(idt[10], 1, GD_KT,i10, 0);
f010387f:	b8 e8 3e 10 f0       	mov    $0xf0103ee8,%eax
f0103884:	66 a3 b0 a2 22 f0    	mov    %ax,0xf022a2b0
f010388a:	66 c7 05 b2 a2 22 f0 	movw   $0x8,0xf022a2b2
f0103891:	08 00 
f0103893:	c6 05 b4 a2 22 f0 00 	movb   $0x0,0xf022a2b4
f010389a:	c6 05 b5 a2 22 f0 8f 	movb   $0x8f,0xf022a2b5
f01038a1:	c1 e8 10             	shr    $0x10,%eax
f01038a4:	66 a3 b6 a2 22 f0    	mov    %ax,0xf022a2b6
	    SETGATE(idt[11], 1, GD_KT, i11, 0);
f01038aa:	b8 ec 3e 10 f0       	mov    $0xf0103eec,%eax
f01038af:	66 a3 b8 a2 22 f0    	mov    %ax,0xf022a2b8
f01038b5:	66 c7 05 ba a2 22 f0 	movw   $0x8,0xf022a2ba
f01038bc:	08 00 
f01038be:	c6 05 bc a2 22 f0 00 	movb   $0x0,0xf022a2bc
f01038c5:	c6 05 bd a2 22 f0 8f 	movb   $0x8f,0xf022a2bd
f01038cc:	c1 e8 10             	shr    $0x10,%eax
f01038cf:	66 a3 be a2 22 f0    	mov    %ax,0xf022a2be
	    SETGATE(idt[12], 1, GD_KT, i12, 0);
f01038d5:	b8 f0 3e 10 f0       	mov    $0xf0103ef0,%eax
f01038da:	66 a3 c0 a2 22 f0    	mov    %ax,0xf022a2c0
f01038e0:	66 c7 05 c2 a2 22 f0 	movw   $0x8,0xf022a2c2
f01038e7:	08 00 
f01038e9:	c6 05 c4 a2 22 f0 00 	movb   $0x0,0xf022a2c4
f01038f0:	c6 05 c5 a2 22 f0 8f 	movb   $0x8f,0xf022a2c5
f01038f7:	c1 e8 10             	shr    $0x10,%eax
f01038fa:	66 a3 c6 a2 22 f0    	mov    %ax,0xf022a2c6
	    SETGATE(idt[13], 1, GD_KT, i13, 0);
f0103900:	b8 f4 3e 10 f0       	mov    $0xf0103ef4,%eax
f0103905:	66 a3 c8 a2 22 f0    	mov    %ax,0xf022a2c8
f010390b:	66 c7 05 ca a2 22 f0 	movw   $0x8,0xf022a2ca
f0103912:	08 00 
f0103914:	c6 05 cc a2 22 f0 00 	movb   $0x0,0xf022a2cc
f010391b:	c6 05 cd a2 22 f0 8f 	movb   $0x8f,0xf022a2cd
f0103922:	c1 e8 10             	shr    $0x10,%eax
f0103925:	66 a3 ce a2 22 f0    	mov    %ax,0xf022a2ce
	    SETGATE(idt[14], 1, GD_KT, i14, 0);
f010392b:	b8 f8 3e 10 f0       	mov    $0xf0103ef8,%eax
f0103930:	66 a3 d0 a2 22 f0    	mov    %ax,0xf022a2d0
f0103936:	66 c7 05 d2 a2 22 f0 	movw   $0x8,0xf022a2d2
f010393d:	08 00 
f010393f:	c6 05 d4 a2 22 f0 00 	movb   $0x0,0xf022a2d4
f0103946:	c6 05 d5 a2 22 f0 8f 	movb   $0x8f,0xf022a2d5
f010394d:	c1 e8 10             	shr    $0x10,%eax
f0103950:	66 a3 d6 a2 22 f0    	mov    %ax,0xf022a2d6
	    SETGATE(idt[16], 1, GD_KT, i16, 0);
f0103956:	b8 fc 3e 10 f0       	mov    $0xf0103efc,%eax
f010395b:	66 a3 e0 a2 22 f0    	mov    %ax,0xf022a2e0
f0103961:	66 c7 05 e2 a2 22 f0 	movw   $0x8,0xf022a2e2
f0103968:	08 00 
f010396a:	c6 05 e4 a2 22 f0 00 	movb   $0x0,0xf022a2e4
f0103971:	c6 05 e5 a2 22 f0 8f 	movb   $0x8f,0xf022a2e5
f0103978:	c1 e8 10             	shr    $0x10,%eax
f010397b:	66 a3 e6 a2 22 f0    	mov    %ax,0xf022a2e6
	    SETGATE(idt[48], 1, GD_KT, i48, 3);	
f0103981:	b8 02 3f 10 f0       	mov    $0xf0103f02,%eax
f0103986:	66 a3 e0 a3 22 f0    	mov    %ax,0xf022a3e0
f010398c:	66 c7 05 e2 a3 22 f0 	movw   $0x8,0xf022a3e2
f0103993:	08 00 
f0103995:	c6 05 e4 a3 22 f0 00 	movb   $0x0,0xf022a3e4
f010399c:	c6 05 e5 a3 22 f0 ef 	movb   $0xef,0xf022a3e5
f01039a3:	c1 e8 10             	shr    $0x10,%eax
f01039a6:	66 a3 e6 a3 22 f0    	mov    %ax,0xf022a3e6

	// Per-CPU setup 
	trap_init_percpu();
f01039ac:	e8 eb fc ff ff       	call   f010369c <trap_init_percpu>
}
f01039b1:	5d                   	pop    %ebp
f01039b2:	c3                   	ret    

f01039b3 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01039b3:	55                   	push   %ebp
f01039b4:	89 e5                	mov    %esp,%ebp
f01039b6:	53                   	push   %ebx
f01039b7:	83 ec 0c             	sub    $0xc,%esp
f01039ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01039bd:	ff 33                	pushl  (%ebx)
f01039bf:	68 e7 70 10 f0       	push   $0xf01070e7
f01039c4:	e8 bf fc ff ff       	call   f0103688 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01039c9:	83 c4 08             	add    $0x8,%esp
f01039cc:	ff 73 04             	pushl  0x4(%ebx)
f01039cf:	68 f6 70 10 f0       	push   $0xf01070f6
f01039d4:	e8 af fc ff ff       	call   f0103688 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01039d9:	83 c4 08             	add    $0x8,%esp
f01039dc:	ff 73 08             	pushl  0x8(%ebx)
f01039df:	68 05 71 10 f0       	push   $0xf0107105
f01039e4:	e8 9f fc ff ff       	call   f0103688 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01039e9:	83 c4 08             	add    $0x8,%esp
f01039ec:	ff 73 0c             	pushl  0xc(%ebx)
f01039ef:	68 14 71 10 f0       	push   $0xf0107114
f01039f4:	e8 8f fc ff ff       	call   f0103688 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01039f9:	83 c4 08             	add    $0x8,%esp
f01039fc:	ff 73 10             	pushl  0x10(%ebx)
f01039ff:	68 23 71 10 f0       	push   $0xf0107123
f0103a04:	e8 7f fc ff ff       	call   f0103688 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103a09:	83 c4 08             	add    $0x8,%esp
f0103a0c:	ff 73 14             	pushl  0x14(%ebx)
f0103a0f:	68 32 71 10 f0       	push   $0xf0107132
f0103a14:	e8 6f fc ff ff       	call   f0103688 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103a19:	83 c4 08             	add    $0x8,%esp
f0103a1c:	ff 73 18             	pushl  0x18(%ebx)
f0103a1f:	68 41 71 10 f0       	push   $0xf0107141
f0103a24:	e8 5f fc ff ff       	call   f0103688 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103a29:	83 c4 08             	add    $0x8,%esp
f0103a2c:	ff 73 1c             	pushl  0x1c(%ebx)
f0103a2f:	68 50 71 10 f0       	push   $0xf0107150
f0103a34:	e8 4f fc ff ff       	call   f0103688 <cprintf>
}
f0103a39:	83 c4 10             	add    $0x10,%esp
f0103a3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103a3f:	c9                   	leave  
f0103a40:	c3                   	ret    

f0103a41 <print_trapframe>:
lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103a41:	55                   	push   %ebp
f0103a42:	89 e5                	mov    %esp,%ebp
f0103a44:	56                   	push   %esi
f0103a45:	53                   	push   %ebx
f0103a46:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103a49:	e8 60 1c 00 00       	call   f01056ae <cpunum>
f0103a4e:	83 ec 04             	sub    $0x4,%esp
f0103a51:	50                   	push   %eax
f0103a52:	53                   	push   %ebx
f0103a53:	68 b4 71 10 f0       	push   $0xf01071b4
f0103a58:	e8 2b fc ff ff       	call   f0103688 <cprintf>
	print_regs(&tf->tf_regs);
f0103a5d:	89 1c 24             	mov    %ebx,(%esp)
f0103a60:	e8 4e ff ff ff       	call   f01039b3 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103a65:	83 c4 08             	add    $0x8,%esp
f0103a68:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103a6c:	50                   	push   %eax
f0103a6d:	68 d2 71 10 f0       	push   $0xf01071d2
f0103a72:	e8 11 fc ff ff       	call   f0103688 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103a77:	83 c4 08             	add    $0x8,%esp
f0103a7a:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103a7e:	50                   	push   %eax
f0103a7f:	68 e5 71 10 f0       	push   $0xf01071e5
f0103a84:	e8 ff fb ff ff       	call   f0103688 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103a89:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103a8c:	83 c4 10             	add    $0x10,%esp
f0103a8f:	83 f8 13             	cmp    $0x13,%eax
f0103a92:	77 09                	ja     f0103a9d <print_trapframe+0x5c>
		return excnames[trapno];
f0103a94:	8b 14 85 60 74 10 f0 	mov    -0xfef8ba0(,%eax,4),%edx
f0103a9b:	eb 1f                	jmp    f0103abc <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103a9d:	83 f8 30             	cmp    $0x30,%eax
f0103aa0:	74 15                	je     f0103ab7 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103aa2:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103aa5:	83 fa 10             	cmp    $0x10,%edx
f0103aa8:	b9 7e 71 10 f0       	mov    $0xf010717e,%ecx
f0103aad:	ba 6b 71 10 f0       	mov    $0xf010716b,%edx
f0103ab2:	0f 43 d1             	cmovae %ecx,%edx
f0103ab5:	eb 05                	jmp    f0103abc <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103ab7:	ba 5f 71 10 f0       	mov    $0xf010715f,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103abc:	83 ec 04             	sub    $0x4,%esp
f0103abf:	52                   	push   %edx
f0103ac0:	50                   	push   %eax
f0103ac1:	68 f8 71 10 f0       	push   $0xf01071f8
f0103ac6:	e8 bd fb ff ff       	call   f0103688 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103acb:	83 c4 10             	add    $0x10,%esp
f0103ace:	3b 1d 60 aa 22 f0    	cmp    0xf022aa60,%ebx
f0103ad4:	75 1a                	jne    f0103af0 <print_trapframe+0xaf>
f0103ad6:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103ada:	75 14                	jne    f0103af0 <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103adc:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103adf:	83 ec 08             	sub    $0x8,%esp
f0103ae2:	50                   	push   %eax
f0103ae3:	68 0a 72 10 f0       	push   $0xf010720a
f0103ae8:	e8 9b fb ff ff       	call   f0103688 <cprintf>
f0103aed:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103af0:	83 ec 08             	sub    $0x8,%esp
f0103af3:	ff 73 2c             	pushl  0x2c(%ebx)
f0103af6:	68 19 72 10 f0       	push   $0xf0107219
f0103afb:	e8 88 fb ff ff       	call   f0103688 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103b00:	83 c4 10             	add    $0x10,%esp
f0103b03:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103b07:	75 49                	jne    f0103b52 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103b09:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103b0c:	89 c2                	mov    %eax,%edx
f0103b0e:	83 e2 01             	and    $0x1,%edx
f0103b11:	ba 98 71 10 f0       	mov    $0xf0107198,%edx
f0103b16:	b9 8d 71 10 f0       	mov    $0xf010718d,%ecx
f0103b1b:	0f 44 ca             	cmove  %edx,%ecx
f0103b1e:	89 c2                	mov    %eax,%edx
f0103b20:	83 e2 02             	and    $0x2,%edx
f0103b23:	ba aa 71 10 f0       	mov    $0xf01071aa,%edx
f0103b28:	be a4 71 10 f0       	mov    $0xf01071a4,%esi
f0103b2d:	0f 45 d6             	cmovne %esi,%edx
f0103b30:	83 e0 04             	and    $0x4,%eax
f0103b33:	be e2 72 10 f0       	mov    $0xf01072e2,%esi
f0103b38:	b8 af 71 10 f0       	mov    $0xf01071af,%eax
f0103b3d:	0f 44 c6             	cmove  %esi,%eax
f0103b40:	51                   	push   %ecx
f0103b41:	52                   	push   %edx
f0103b42:	50                   	push   %eax
f0103b43:	68 27 72 10 f0       	push   $0xf0107227
f0103b48:	e8 3b fb ff ff       	call   f0103688 <cprintf>
f0103b4d:	83 c4 10             	add    $0x10,%esp
f0103b50:	eb 10                	jmp    f0103b62 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103b52:	83 ec 0c             	sub    $0xc,%esp
f0103b55:	68 63 66 10 f0       	push   $0xf0106663
f0103b5a:	e8 29 fb ff ff       	call   f0103688 <cprintf>
f0103b5f:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103b62:	83 ec 08             	sub    $0x8,%esp
f0103b65:	ff 73 30             	pushl  0x30(%ebx)
f0103b68:	68 36 72 10 f0       	push   $0xf0107236
f0103b6d:	e8 16 fb ff ff       	call   f0103688 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103b72:	83 c4 08             	add    $0x8,%esp
f0103b75:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103b79:	50                   	push   %eax
f0103b7a:	68 45 72 10 f0       	push   $0xf0107245
f0103b7f:	e8 04 fb ff ff       	call   f0103688 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103b84:	83 c4 08             	add    $0x8,%esp
f0103b87:	ff 73 38             	pushl  0x38(%ebx)
f0103b8a:	68 58 72 10 f0       	push   $0xf0107258
f0103b8f:	e8 f4 fa ff ff       	call   f0103688 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103b94:	83 c4 10             	add    $0x10,%esp
f0103b97:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103b9b:	74 25                	je     f0103bc2 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103b9d:	83 ec 08             	sub    $0x8,%esp
f0103ba0:	ff 73 3c             	pushl  0x3c(%ebx)
f0103ba3:	68 67 72 10 f0       	push   $0xf0107267
f0103ba8:	e8 db fa ff ff       	call   f0103688 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103bad:	83 c4 08             	add    $0x8,%esp
f0103bb0:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103bb4:	50                   	push   %eax
f0103bb5:	68 76 72 10 f0       	push   $0xf0107276
f0103bba:	e8 c9 fa ff ff       	call   f0103688 <cprintf>
f0103bbf:	83 c4 10             	add    $0x10,%esp
	}
}
f0103bc2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103bc5:	5b                   	pop    %ebx
f0103bc6:	5e                   	pop    %esi
f0103bc7:	5d                   	pop    %ebp
f0103bc8:	c3                   	ret    

f0103bc9 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103bc9:	55                   	push   %ebp
f0103bca:	89 e5                	mov    %esp,%ebp
f0103bcc:	57                   	push   %edi
f0103bcd:	56                   	push   %esi
f0103bce:	53                   	push   %ebx
f0103bcf:	83 ec 0c             	sub    $0xc,%esp
f0103bd2:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103bd5:	0f 20 d7             	mov    %cr2,%edi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs&3) == 0)
f0103bd8:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103bdc:	75 17                	jne    f0103bf5 <page_fault_handler+0x2c>
	panic("Page Fault occured(Kernel)");
f0103bde:	83 ec 04             	sub    $0x4,%esp
f0103be1:	68 89 72 10 f0       	push   $0xf0107289
f0103be6:	68 32 01 00 00       	push   $0x132
f0103beb:	68 a4 72 10 f0       	push   $0xf01072a4
f0103bf0:	e8 4b c4 ff ff       	call   f0100040 <_panic>

	// LAB 4: Your code here.

	
	
	if (curenv->env_pgfault_upcall == NULL ||
f0103bf5:	e8 b4 1a 00 00       	call   f01056ae <cpunum>
f0103bfa:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bfd:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103c03:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103c07:	74 16                	je     f0103c1f <page_fault_handler+0x56>
		tf->tf_esp > UXSTACKTOP ||
f0103c09:	8b 43 3c             	mov    0x3c(%ebx),%eax

	// LAB 4: Your code here.

	
	
	if (curenv->env_pgfault_upcall == NULL ||
f0103c0c:	3d 00 00 c0 ee       	cmp    $0xeec00000,%eax
f0103c11:	77 0c                	ja     f0103c1f <page_fault_handler+0x56>
		tf->tf_esp > UXSTACKTOP ||
f0103c13:	05 ff 1f 40 11       	add    $0x11401fff,%eax
f0103c18:	3d fe 0f 00 00       	cmp    $0xffe,%eax
f0103c1d:	77 26                	ja     f0103c45 <page_fault_handler+0x7c>
		(tf->tf_esp > USTACKTOP && tf->tf_esp < (UXSTACKTOP - PGSIZE)))// stack pointer is out of bounds.
	{
		cprintf("user page fault handler exeption!\n");
f0103c1f:	83 ec 0c             	sub    $0xc,%esp
f0103c22:	68 2c 74 10 f0       	push   $0xf010742c
f0103c27:	e8 5c fa ff ff       	call   f0103688 <cprintf>
		env_destroy(curenv);
f0103c2c:	e8 7d 1a 00 00       	call   f01056ae <cpunum>
f0103c31:	83 c4 04             	add    $0x4,%esp
f0103c34:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c37:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f0103c3d:	e8 ba f7 ff ff       	call   f01033fc <env_destroy>
f0103c42:	83 c4 10             	add    $0x10,%esp
	}


	
	uint32_t exception_stack_top;
	if (tf->tf_esp < USTACKTOP) {
f0103c45:	8b 43 3c             	mov    0x3c(%ebx),%eax
		
		exception_stack_top = UXSTACKTOP - sizeof(struct UTrapframe);
	} else {
		exception_stack_top = tf->tf_esp - sizeof(struct UTrapframe) - 4; //gap between two exception frames (recursive fault)
f0103c48:	8d 50 c8             	lea    -0x38(%eax),%edx
f0103c4b:	3d ff df bf ee       	cmp    $0xeebfdfff,%eax
f0103c50:	b8 cc ff bf ee       	mov    $0xeebfffcc,%eax
f0103c55:	0f 47 c2             	cmova  %edx,%eax
f0103c58:	89 c6                	mov    %eax,%esi
	}

	user_mem_assert(curenv, (void *) exception_stack_top, 1, PTE_W | PTE_U);// 
f0103c5a:	e8 4f 1a 00 00       	call   f01056ae <cpunum>
f0103c5f:	6a 06                	push   $0x6
f0103c61:	6a 01                	push   $0x1
f0103c63:	56                   	push   %esi
f0103c64:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c67:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f0103c6d:	e8 0c f1 ff ff       	call   f0102d7e <user_mem_assert>

	// Write the UTrapframe to the exception stack
	struct UTrapframe *utframe = (struct UTrapframe *) exception_stack_top;
	utframe->utf_fault_va = fault_va;
f0103c72:	89 3e                	mov    %edi,(%esi)
	utframe->utf_err = tf->tf_err;
f0103c74:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103c77:	89 f2                	mov    %esi,%edx
f0103c79:	89 46 04             	mov    %eax,0x4(%esi)
	utframe->utf_regs = tf->tf_regs;
f0103c7c:	8d 7e 08             	lea    0x8(%esi),%edi
f0103c7f:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103c84:	89 de                	mov    %ebx,%esi
f0103c86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	utframe->utf_eip = tf->tf_eip;
f0103c88:	8b 43 30             	mov    0x30(%ebx),%eax
f0103c8b:	89 42 28             	mov    %eax,0x28(%edx)
	utframe->utf_eflags = tf->tf_eflags;
f0103c8e:	8b 43 38             	mov    0x38(%ebx),%eax
f0103c91:	89 42 2c             	mov    %eax,0x2c(%edx)
	utframe->utf_esp = tf->tf_esp;
f0103c94:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103c97:	89 42 30             	mov    %eax,0x30(%edx)

	
	tf->tf_esp = (uintptr_t) exception_stack_top;
f0103c9a:	89 53 3c             	mov    %edx,0x3c(%ebx)
	tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;
f0103c9d:	e8 0c 1a 00 00       	call   f01056ae <cpunum>
f0103ca2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ca5:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103cab:	8b 40 64             	mov    0x64(%eax),%eax
f0103cae:	89 43 30             	mov    %eax,0x30(%ebx)

	env_run(curenv);
f0103cb1:	e8 f8 19 00 00       	call   f01056ae <cpunum>
f0103cb6:	83 c4 04             	add    $0x4,%esp
f0103cb9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cbc:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f0103cc2:	e8 d4 f7 ff ff       	call   f010349b <env_run>

f0103cc7 <trap>:

}

void
trap(struct Trapframe *tf)
{
f0103cc7:	55                   	push   %ebp
f0103cc8:	89 e5                	mov    %esp,%ebp
f0103cca:	57                   	push   %edi
f0103ccb:	56                   	push   %esi
f0103ccc:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103ccf:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103cd0:	83 3d 00 af 22 f0 00 	cmpl   $0x0,0xf022af00
f0103cd7:	74 01                	je     f0103cda <trap+0x13>
		asm volatile("hlt");
f0103cd9:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103cda:	e8 cf 19 00 00       	call   f01056ae <cpunum>
f0103cdf:	6b d0 74             	imul   $0x74,%eax,%edx
f0103ce2:	81 c2 20 b0 22 f0    	add    $0xf022b020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0103ce8:	b8 01 00 00 00       	mov    $0x1,%eax
f0103ced:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0103cf1:	83 f8 02             	cmp    $0x2,%eax
f0103cf4:	75 10                	jne    f0103d06 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0103cf6:	83 ec 0c             	sub    $0xc,%esp
f0103cf9:	68 c0 f3 11 f0       	push   $0xf011f3c0
f0103cfe:	e8 19 1c 00 00       	call   f010591c <spin_lock>
f0103d03:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103d06:	9c                   	pushf  
f0103d07:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103d08:	f6 c4 02             	test   $0x2,%ah
f0103d0b:	74 19                	je     f0103d26 <trap+0x5f>
f0103d0d:	68 b0 72 10 f0       	push   $0xf01072b0
f0103d12:	68 36 63 10 f0       	push   $0xf0106336
f0103d17:	68 fb 00 00 00       	push   $0xfb
f0103d1c:	68 a4 72 10 f0       	push   $0xf01072a4
f0103d21:	e8 1a c3 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0103d26:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103d2a:	83 e0 03             	and    $0x3,%eax
f0103d2d:	66 83 f8 03          	cmp    $0x3,%ax
f0103d31:	0f 85 a0 00 00 00    	jne    f0103dd7 <trap+0x110>
f0103d37:	83 ec 0c             	sub    $0xc,%esp
f0103d3a:	68 c0 f3 11 f0       	push   $0xf011f3c0
f0103d3f:	e8 d8 1b 00 00       	call   f010591c <spin_lock>
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();

		assert(curenv);
f0103d44:	e8 65 19 00 00       	call   f01056ae <cpunum>
f0103d49:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d4c:	83 c4 10             	add    $0x10,%esp
f0103d4f:	83 b8 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%eax)
f0103d56:	75 19                	jne    f0103d71 <trap+0xaa>
f0103d58:	68 c9 72 10 f0       	push   $0xf01072c9
f0103d5d:	68 36 63 10 f0       	push   $0xf0106336
f0103d62:	68 04 01 00 00       	push   $0x104
f0103d67:	68 a4 72 10 f0       	push   $0xf01072a4
f0103d6c:	e8 cf c2 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0103d71:	e8 38 19 00 00       	call   f01056ae <cpunum>
f0103d76:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d79:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103d7f:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103d83:	75 2d                	jne    f0103db2 <trap+0xeb>
			env_free(curenv);
f0103d85:	e8 24 19 00 00       	call   f01056ae <cpunum>
f0103d8a:	83 ec 0c             	sub    $0xc,%esp
f0103d8d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d90:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f0103d96:	e8 86 f4 ff ff       	call   f0103221 <env_free>
			curenv = NULL;
f0103d9b:	e8 0e 19 00 00       	call   f01056ae <cpunum>
f0103da0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103da3:	c7 80 28 b0 22 f0 00 	movl   $0x0,-0xfdd4fd8(%eax)
f0103daa:	00 00 00 
			sched_yield();
f0103dad:	e8 3b 02 00 00       	call   f0103fed <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103db2:	e8 f7 18 00 00       	call   f01056ae <cpunum>
f0103db7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dba:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103dc0:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103dc5:	89 c7                	mov    %eax,%edi
f0103dc7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103dc9:	e8 e0 18 00 00       	call   f01056ae <cpunum>
f0103dce:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dd1:	8b b0 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103dd7:	89 35 60 aa 22 f0    	mov    %esi,0xf022aa60
}

static void
trap_dispatch(struct Trapframe *tf)
{
	switch(tf->tf_trapno)
f0103ddd:	8b 46 28             	mov    0x28(%esi),%eax
f0103de0:	83 f8 0e             	cmp    $0xe,%eax
f0103de3:	74 0c                	je     f0103df1 <trap+0x12a>
f0103de5:	83 f8 30             	cmp    $0x30,%eax
f0103de8:	74 26                	je     f0103e10 <trap+0x149>
f0103dea:	83 f8 03             	cmp    $0x3,%eax
f0103ded:	75 42                	jne    f0103e31 <trap+0x16a>
f0103def:	eb 09                	jmp    f0103dfa <trap+0x133>
	{
		case T_PGFLT:
			page_fault_handler(tf);
f0103df1:	83 ec 0c             	sub    $0xc,%esp
f0103df4:	56                   	push   %esi
f0103df5:	e8 cf fd ff ff       	call   f0103bc9 <page_fault_handler>
			break;
		case T_BRKPT:
			print_trapframe(tf);
f0103dfa:	83 ec 0c             	sub    $0xc,%esp
f0103dfd:	56                   	push   %esi
f0103dfe:	e8 3e fc ff ff       	call   f0103a41 <print_trapframe>
			monitor(tf);
f0103e03:	89 34 24             	mov    %esi,(%esp)
f0103e06:	e8 53 cb ff ff       	call   f010095e <monitor>
f0103e0b:	83 c4 10             	add    $0x10,%esp
f0103e0e:	eb 64                	jmp    f0103e74 <trap+0x1ad>
			break;
		case T_SYSCALL:
			tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
f0103e10:	83 ec 08             	sub    $0x8,%esp
f0103e13:	ff 76 04             	pushl  0x4(%esi)
f0103e16:	ff 36                	pushl  (%esi)
f0103e18:	ff 76 10             	pushl  0x10(%esi)
f0103e1b:	ff 76 18             	pushl  0x18(%esi)
f0103e1e:	ff 76 14             	pushl  0x14(%esi)
f0103e21:	ff 76 1c             	pushl  0x1c(%esi)
f0103e24:	e8 c0 02 00 00       	call   f01040e9 <syscall>
f0103e29:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103e2c:	83 c4 20             	add    $0x20,%esp
f0103e2f:	eb 43                	jmp    f0103e74 <trap+0x1ad>
			break;
		default:
			print_trapframe(tf);
f0103e31:	83 ec 0c             	sub    $0xc,%esp
f0103e34:	56                   	push   %esi
f0103e35:	e8 07 fc ff ff       	call   f0103a41 <print_trapframe>
			if (tf->tf_cs == GD_KT)
f0103e3a:	83 c4 10             	add    $0x10,%esp
f0103e3d:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103e42:	75 17                	jne    f0103e5b <trap+0x194>
				panic("unhandled trap in kernel");
f0103e44:	83 ec 04             	sub    $0x4,%esp
f0103e47:	68 d0 72 10 f0       	push   $0xf01072d0
f0103e4c:	68 de 00 00 00       	push   $0xde
f0103e51:	68 a4 72 10 f0       	push   $0xf01072a4
f0103e56:	e8 e5 c1 ff ff       	call   f0100040 <_panic>
			else 
			{
				env_destroy(curenv);
f0103e5b:	e8 4e 18 00 00       	call   f01056ae <cpunum>
f0103e60:	83 ec 0c             	sub    $0xc,%esp
f0103e63:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e66:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f0103e6c:	e8 8b f5 ff ff       	call   f01033fc <env_destroy>
f0103e71:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0103e74:	e8 35 18 00 00       	call   f01056ae <cpunum>
f0103e79:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e7c:	83 b8 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%eax)
f0103e83:	74 2a                	je     f0103eaf <trap+0x1e8>
f0103e85:	e8 24 18 00 00       	call   f01056ae <cpunum>
f0103e8a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e8d:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103e93:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103e97:	75 16                	jne    f0103eaf <trap+0x1e8>
		env_run(curenv);
f0103e99:	e8 10 18 00 00       	call   f01056ae <cpunum>
f0103e9e:	83 ec 0c             	sub    $0xc,%esp
f0103ea1:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ea4:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f0103eaa:	e8 ec f5 ff ff       	call   f010349b <env_run>
	else
		sched_yield();
f0103eaf:	e8 39 01 00 00       	call   f0103fed <sched_yield>

f0103eb4 <i0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(i0, 0)
f0103eb4:	6a 00                	push   $0x0
f0103eb6:	6a 00                	push   $0x0
f0103eb8:	eb 4e                	jmp    f0103f08 <_alltraps>

f0103eba <i1>:
    TRAPHANDLER_NOEC(i1, 1)
f0103eba:	6a 00                	push   $0x0
f0103ebc:	6a 01                	push   $0x1
f0103ebe:	eb 48                	jmp    f0103f08 <_alltraps>

f0103ec0 <i3>:
    TRAPHANDLER_NOEC(i3, 3)
f0103ec0:	6a 00                	push   $0x0
f0103ec2:	6a 03                	push   $0x3
f0103ec4:	eb 42                	jmp    f0103f08 <_alltraps>

f0103ec6 <i4>:
    TRAPHANDLER_NOEC(i4, 4)
f0103ec6:	6a 00                	push   $0x0
f0103ec8:	6a 04                	push   $0x4
f0103eca:	eb 3c                	jmp    f0103f08 <_alltraps>

f0103ecc <i5>:
    TRAPHANDLER_NOEC(i5, 5)
f0103ecc:	6a 00                	push   $0x0
f0103ece:	6a 05                	push   $0x5
f0103ed0:	eb 36                	jmp    f0103f08 <_alltraps>

f0103ed2 <i6>:
    TRAPHANDLER_NOEC(i6, 6)
f0103ed2:	6a 00                	push   $0x0
f0103ed4:	6a 06                	push   $0x6
f0103ed6:	eb 30                	jmp    f0103f08 <_alltraps>

f0103ed8 <i7>:
    TRAPHANDLER_NOEC(i7, 7)
f0103ed8:	6a 00                	push   $0x0
f0103eda:	6a 07                	push   $0x7
f0103edc:	eb 2a                	jmp    f0103f08 <_alltraps>

f0103ede <i8>:
    TRAPHANDLER(i8, 8)          // Error code pushed
f0103ede:	6a 08                	push   $0x8
f0103ee0:	eb 26                	jmp    f0103f08 <_alltraps>

f0103ee2 <i9>:
    TRAPHANDLER_NOEC(i9, 9)
f0103ee2:	6a 00                	push   $0x0
f0103ee4:	6a 09                	push   $0x9
f0103ee6:	eb 20                	jmp    f0103f08 <_alltraps>

f0103ee8 <i10>:
    TRAPHANDLER(i10, 10)	// Error code pushed
f0103ee8:	6a 0a                	push   $0xa
f0103eea:	eb 1c                	jmp    f0103f08 <_alltraps>

f0103eec <i11>:
    TRAPHANDLER(i11, 11)	// Error code pushed
f0103eec:	6a 0b                	push   $0xb
f0103eee:	eb 18                	jmp    f0103f08 <_alltraps>

f0103ef0 <i12>:
    TRAPHANDLER(i12, 12)	// Error code pushed
f0103ef0:	6a 0c                	push   $0xc
f0103ef2:	eb 14                	jmp    f0103f08 <_alltraps>

f0103ef4 <i13>:
    TRAPHANDLER(i13, 13)	// Error code pushed
f0103ef4:	6a 0d                	push   $0xd
f0103ef6:	eb 10                	jmp    f0103f08 <_alltraps>

f0103ef8 <i14>:
    TRAPHANDLER(i14, 14)	// Error code pushed
f0103ef8:	6a 0e                	push   $0xe
f0103efa:	eb 0c                	jmp    f0103f08 <_alltraps>

f0103efc <i16>:
    TRAPHANDLER_NOEC(i16, 16)
f0103efc:	6a 00                	push   $0x0
f0103efe:	6a 10                	push   $0x10
f0103f00:	eb 06                	jmp    f0103f08 <_alltraps>

f0103f02 <i48>:
    TRAPHANDLER_NOEC(i48, 48) //syscall
f0103f02:	6a 00                	push   $0x0
f0103f04:	6a 30                	push   $0x30
f0103f06:	eb 00                	jmp    f0103f08 <_alltraps>

f0103f08 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
    pushl %ds //cpu registers 
f0103f08:	1e                   	push   %ds
    pushl %es
f0103f09:	06                   	push   %es
    pushal // General purpose registers
f0103f0a:	60                   	pusha  
   movw $ GD_KD, %ax
f0103f0b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
f0103f0f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
f0103f11:	8e c0                	mov    %eax,%es
    pushl %esp // Argument for trap()
f0103f13:	54                   	push   %esp
    call trap
f0103f14:	e8 ae fd ff ff       	call   f0103cc7 <trap>

f0103f19 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0103f19:	55                   	push   %ebp
f0103f1a:	89 e5                	mov    %esp,%ebp
f0103f1c:	83 ec 08             	sub    $0x8,%esp
f0103f1f:	a1 48 a2 22 f0       	mov    0xf022a248,%eax
f0103f24:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0103f27:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0103f2c:	8b 02                	mov    (%edx),%eax
f0103f2e:	83 e8 01             	sub    $0x1,%eax
f0103f31:	83 f8 02             	cmp    $0x2,%eax
f0103f34:	76 10                	jbe    f0103f46 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0103f36:	83 c1 01             	add    $0x1,%ecx
f0103f39:	83 c2 7c             	add    $0x7c,%edx
f0103f3c:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103f42:	75 e8                	jne    f0103f2c <sched_halt+0x13>
f0103f44:	eb 08                	jmp    f0103f4e <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0103f46:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103f4c:	75 1f                	jne    f0103f6d <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f0103f4e:	83 ec 0c             	sub    $0xc,%esp
f0103f51:	68 b0 74 10 f0       	push   $0xf01074b0
f0103f56:	e8 2d f7 ff ff       	call   f0103688 <cprintf>
f0103f5b:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0103f5e:	83 ec 0c             	sub    $0xc,%esp
f0103f61:	6a 00                	push   $0x0
f0103f63:	e8 f6 c9 ff ff       	call   f010095e <monitor>
f0103f68:	83 c4 10             	add    $0x10,%esp
f0103f6b:	eb f1                	jmp    f0103f5e <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0103f6d:	e8 3c 17 00 00       	call   f01056ae <cpunum>
f0103f72:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f75:	c7 80 28 b0 22 f0 00 	movl   $0x0,-0xfdd4fd8(%eax)
f0103f7c:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0103f7f:	a1 0c af 22 f0       	mov    0xf022af0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103f84:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103f89:	77 12                	ja     f0103f9d <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103f8b:	50                   	push   %eax
f0103f8c:	68 88 5d 10 f0       	push   $0xf0105d88
f0103f91:	6a 52                	push   $0x52
f0103f93:	68 d9 74 10 f0       	push   $0xf01074d9
f0103f98:	e8 a3 c0 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103f9d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103fa2:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0103fa5:	e8 04 17 00 00       	call   f01056ae <cpunum>
f0103faa:	6b d0 74             	imul   $0x74,%eax,%edx
f0103fad:	81 c2 20 b0 22 f0    	add    $0xf022b020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0103fb3:	b8 02 00 00 00       	mov    $0x2,%eax
f0103fb8:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103fbc:	83 ec 0c             	sub    $0xc,%esp
f0103fbf:	68 c0 f3 11 f0       	push   $0xf011f3c0
f0103fc4:	e8 f0 19 00 00       	call   f01059b9 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103fc9:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0103fcb:	e8 de 16 00 00       	call   f01056ae <cpunum>
f0103fd0:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0103fd3:	8b 80 30 b0 22 f0    	mov    -0xfdd4fd0(%eax),%eax
f0103fd9:	bd 00 00 00 00       	mov    $0x0,%ebp
f0103fde:	89 c4                	mov    %eax,%esp
f0103fe0:	6a 00                	push   $0x0
f0103fe2:	6a 00                	push   $0x0
f0103fe4:	fb                   	sti    
f0103fe5:	f4                   	hlt    
f0103fe6:	eb fd                	jmp    f0103fe5 <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0103fe8:	83 c4 10             	add    $0x10,%esp
f0103feb:	c9                   	leave  
f0103fec:	c3                   	ret    

f0103fed <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0103fed:	55                   	push   %ebp
f0103fee:	89 e5                	mov    %esp,%ebp
f0103ff0:	57                   	push   %edi
f0103ff1:	56                   	push   %esi
f0103ff2:	53                   	push   %ebx
f0103ff3:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	
	//struct Env *e;

    	int i, current=0;
    	if (curenv) current=ENVX(curenv->env_id);
f0103ff6:	e8 b3 16 00 00       	call   f01056ae <cpunum>
f0103ffb:	6b c0 74             	imul   $0x74,%eax,%eax
        else current = 0;
f0103ffe:	bf 00 00 00 00       	mov    $0x0,%edi
	// LAB 4: Your code here.
	
	//struct Env *e;

    	int i, current=0;
    	if (curenv) current=ENVX(curenv->env_id);
f0104003:	83 b8 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%eax)
f010400a:	74 17                	je     f0104023 <sched_yield+0x36>
f010400c:	e8 9d 16 00 00       	call   f01056ae <cpunum>
f0104011:	6b c0 74             	imul   $0x74,%eax,%eax
f0104014:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f010401a:	8b 78 48             	mov    0x48(%eax),%edi
f010401d:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
f0104023:	89 fe                	mov    %edi,%esi
f0104025:	81 c7 00 04 00 00    	add    $0x400,%edi
        else current = 0;
    	for (i = 0; i < NENV; ++i) {
        int j = (current+i) % NENV;
f010402b:	89 f0                	mov    %esi,%eax
f010402d:	c1 f8 1f             	sar    $0x1f,%eax
f0104030:	c1 e8 16             	shr    $0x16,%eax
f0104033:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
f0104036:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f010403c:	29 c3                	sub    %eax,%ebx
f010403e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
        if (j < 2) cprintf("envs[%x].env_status: %x\n", j, envs[j].env_status);
f0104041:	83 fb 01             	cmp    $0x1,%ebx
f0104044:	7f 1d                	jg     f0104063 <sched_yield+0x76>
f0104046:	83 ec 04             	sub    $0x4,%esp
f0104049:	6b c3 7c             	imul   $0x7c,%ebx,%eax
f010404c:	03 05 48 a2 22 f0    	add    0xf022a248,%eax
f0104052:	ff 70 54             	pushl  0x54(%eax)
f0104055:	53                   	push   %ebx
f0104056:	68 e6 74 10 f0       	push   $0xf01074e6
f010405b:	e8 28 f6 ff ff       	call   f0103688 <cprintf>
f0104060:	83 c4 10             	add    $0x10,%esp
        if (envs[j].env_status == ENV_RUNNABLE) {
f0104063:	6b c3 7c             	imul   $0x7c,%ebx,%eax
f0104066:	89 c3                	mov    %eax,%ebx
f0104068:	8b 15 48 a2 22 f0    	mov    0xf022a248,%edx
f010406e:	83 7c 02 54 02       	cmpl   $0x2,0x54(%edx,%eax,1)
f0104073:	75 25                	jne    f010409a <sched_yield+0xad>
         if (j == 1) 
f0104075:	83 7d e4 01          	cmpl   $0x1,-0x1c(%ebp)
f0104079:	75 10                	jne    f010408b <sched_yield+0x9e>
                cprintf("\n");
f010407b:	83 ec 0c             	sub    $0xc,%esp
f010407e:	68 63 66 10 f0       	push   $0xf0106663
f0104083:	e8 00 f6 ff ff       	call   f0103688 <cprintf>
f0104088:	83 c4 10             	add    $0x10,%esp
            env_run(envs + j);
f010408b:	83 ec 0c             	sub    $0xc,%esp
f010408e:	03 1d 48 a2 22 f0    	add    0xf022a248,%ebx
f0104094:	53                   	push   %ebx
f0104095:	e8 01 f4 ff ff       	call   f010349b <env_run>
f010409a:	83 c6 01             	add    $0x1,%esi
	//struct Env *e;

    	int i, current=0;
    	if (curenv) current=ENVX(curenv->env_id);
        else current = 0;
    	for (i = 0; i < NENV; ++i) {
f010409d:	39 fe                	cmp    %edi,%esi
f010409f:	75 8a                	jne    f010402b <sched_yield+0x3e>
         if (j == 1) 
                cprintf("\n");
            env_run(envs + j);
        }
    }
    if (curenv && curenv->env_status == ENV_RUNNING)
f01040a1:	e8 08 16 00 00       	call   f01056ae <cpunum>
f01040a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01040a9:	83 b8 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%eax)
f01040b0:	74 2a                	je     f01040dc <sched_yield+0xef>
f01040b2:	e8 f7 15 00 00       	call   f01056ae <cpunum>
f01040b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01040ba:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f01040c0:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01040c4:	75 16                	jne    f01040dc <sched_yield+0xef>
        env_run(curenv);
f01040c6:	e8 e3 15 00 00       	call   f01056ae <cpunum>
f01040cb:	83 ec 0c             	sub    $0xc,%esp
f01040ce:	6b c0 74             	imul   $0x74,%eax,%eax
f01040d1:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f01040d7:	e8 bf f3 ff ff       	call   f010349b <env_run>




	// sched_halt never returns
	sched_halt();
f01040dc:	e8 38 fe ff ff       	call   f0103f19 <sched_halt>
}
f01040e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01040e4:	5b                   	pop    %ebx
f01040e5:	5e                   	pop    %esi
f01040e6:	5f                   	pop    %edi
f01040e7:	5d                   	pop    %ebp
f01040e8:	c3                   	ret    

f01040e9 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01040e9:	55                   	push   %ebp
f01040ea:	89 e5                	mov    %esp,%ebp
f01040ec:	57                   	push   %edi
f01040ed:	56                   	push   %esi
f01040ee:	53                   	push   %ebx
f01040ef:	83 ec 1c             	sub    $0x1c,%esp
f01040f2:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int32_t ret = 0;
	switch (syscallno) {
f01040f5:	83 f8 0a             	cmp    $0xa,%eax
f01040f8:	0f 87 e2 03 00 00    	ja     f01044e0 <syscall+0x3f7>
f01040fe:	ff 24 85 44 75 10 f0 	jmp    *-0xfef8abc(,%eax,4)
// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	// cprintf("sys curenv_id: %x\n", curenv->env_id);
	return curenv->env_id;
f0104105:	e8 a4 15 00 00       	call   f01056ae <cpunum>
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f010410a:	83 ec 04             	sub    $0x4,%esp
f010410d:	6a 01                	push   $0x1
f010410f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104112:	52                   	push   %edx
// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	// cprintf("sys curenv_id: %x\n", curenv->env_id);
	return curenv->env_id;
f0104113:	6b c0 74             	imul   $0x74,%eax,%eax
f0104116:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f010411c:	ff 70 48             	pushl  0x48(%eax)
f010411f:	e8 0f ed ff ff       	call   f0102e33 <envid2env>
	user_mem_assert(e, s, len, PTE_U);
f0104124:	6a 04                	push   $0x4
f0104126:	ff 75 10             	pushl  0x10(%ebp)
f0104129:	ff 75 0c             	pushl  0xc(%ebp)
f010412c:	ff 75 e4             	pushl  -0x1c(%ebp)
f010412f:	e8 4a ec ff ff       	call   f0102d7e <user_mem_assert>
	

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104134:	83 c4 1c             	add    $0x1c,%esp
f0104137:	ff 75 0c             	pushl  0xc(%ebp)
f010413a:	ff 75 10             	pushl  0x10(%ebp)
f010413d:	68 ff 74 10 f0       	push   $0xf01074ff
f0104142:	e8 41 f5 ff ff       	call   f0103688 <cprintf>
f0104147:	83 c4 10             	add    $0x10,%esp
	// LAB 3: Your code here.
	int32_t ret = 0;
	switch (syscallno) {
		case SYS_cputs: 
			sys_cputs((char*)a1, a2);
			ret = 0;
f010414a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010414f:	e9 91 03 00 00       	jmp    f01044e5 <syscall+0x3fc>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104154:	e8 8e c4 ff ff       	call   f01005e7 <cons_getc>
f0104159:	89 c3                	mov    %eax,%ebx
			sys_cputs((char*)a1, a2);
			ret = 0;
			break;
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
f010415b:	e9 85 03 00 00       	jmp    f01044e5 <syscall+0x3fc>
// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	// cprintf("sys curenv_id: %x\n", curenv->env_id);
	return curenv->env_id;
f0104160:	e8 49 15 00 00       	call   f01056ae <cpunum>
f0104165:	6b c0 74             	imul   $0x74,%eax,%eax
f0104168:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f010416e:	8b 58 48             	mov    0x48(%eax),%ebx
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
		case SYS_getenvid:
			ret = sys_getenvid();
			cprintf ("ret is %d\n",ret);
f0104171:	83 ec 08             	sub    $0x8,%esp
f0104174:	53                   	push   %ebx
f0104175:	68 04 75 10 f0       	push   $0xf0107504
f010417a:	e8 09 f5 ff ff       	call   f0103688 <cprintf>
			break;
f010417f:	83 c4 10             	add    $0x10,%esp
f0104182:	e9 5e 03 00 00       	jmp    f01044e5 <syscall+0x3fc>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104187:	83 ec 04             	sub    $0x4,%esp
f010418a:	6a 01                	push   $0x1
f010418c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010418f:	50                   	push   %eax
f0104190:	ff 75 0c             	pushl  0xc(%ebp)
f0104193:	e8 9b ec ff ff       	call   f0102e33 <envid2env>
f0104198:	83 c4 10             	add    $0x10,%esp
f010419b:	85 c0                	test   %eax,%eax
f010419d:	78 69                	js     f0104208 <syscall+0x11f>
		return r;
	if (e == curenv)
f010419f:	e8 0a 15 00 00       	call   f01056ae <cpunum>
f01041a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01041a7:	6b c0 74             	imul   $0x74,%eax,%eax
f01041aa:	39 90 28 b0 22 f0    	cmp    %edx,-0xfdd4fd8(%eax)
f01041b0:	75 23                	jne    f01041d5 <syscall+0xec>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01041b2:	e8 f7 14 00 00       	call   f01056ae <cpunum>
f01041b7:	83 ec 08             	sub    $0x8,%esp
f01041ba:	6b c0 74             	imul   $0x74,%eax,%eax
f01041bd:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f01041c3:	ff 70 48             	pushl  0x48(%eax)
f01041c6:	68 0f 75 10 f0       	push   $0xf010750f
f01041cb:	e8 b8 f4 ff ff       	call   f0103688 <cprintf>
f01041d0:	83 c4 10             	add    $0x10,%esp
f01041d3:	eb 25                	jmp    f01041fa <syscall+0x111>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01041d5:	8b 5a 48             	mov    0x48(%edx),%ebx
f01041d8:	e8 d1 14 00 00       	call   f01056ae <cpunum>
f01041dd:	83 ec 04             	sub    $0x4,%esp
f01041e0:	53                   	push   %ebx
f01041e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01041e4:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f01041ea:	ff 70 48             	pushl  0x48(%eax)
f01041ed:	68 2a 75 10 f0       	push   $0xf010752a
f01041f2:	e8 91 f4 ff ff       	call   f0103688 <cprintf>
f01041f7:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01041fa:	83 ec 0c             	sub    $0xc,%esp
f01041fd:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104200:	e8 f7 f1 ff ff       	call   f01033fc <env_destroy>
f0104205:	83 c4 10             	add    $0x10,%esp
			ret = sys_getenvid();
			cprintf ("ret is %d\n",ret);
			break;
		case SYS_env_destroy:
			sys_env_destroy(a1);
			ret = 0;
f0104208:	bb 00 00 00 00       	mov    $0x0,%ebx
f010420d:	e9 d3 02 00 00       	jmp    f01044e5 <syscall+0x3fc>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104212:	e8 d6 fd ff ff       	call   f0103fed <sched_yield>
	// will appear to return 0.

	// LAB 4: Your code here.

	struct Env *e;
	int new = env_alloc(&e, curenv->env_id);
f0104217:	e8 92 14 00 00       	call   f01056ae <cpunum>
f010421c:	83 ec 08             	sub    $0x8,%esp
f010421f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104222:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0104228:	ff 70 48             	pushl  0x48(%eax)
f010422b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010422e:	50                   	push   %eax
f010422f:	e8 0a ed ff ff       	call   f0102f3e <env_alloc>
	if (new) return new;
f0104234:	83 c4 10             	add    $0x10,%esp
f0104237:	89 c3                	mov    %eax,%ebx
f0104239:	85 c0                	test   %eax,%eax
f010423b:	0f 85 a4 02 00 00    	jne    f01044e5 <syscall+0x3fc>

	e->env_tf = curenv->env_tf;
f0104241:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104244:	e8 65 14 00 00       	call   f01056ae <cpunum>
f0104249:	6b c0 74             	imul   $0x74,%eax,%eax
f010424c:	8b b0 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%esi
f0104252:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104257:	89 df                	mov    %ebx,%edi
f0104259:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_status = ENV_NOT_RUNNABLE;
f010425b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010425e:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	e->env_tf.tf_regs.reg_eax = 0;
f0104265:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	

	return e->env_id;
f010426c:	8b 58 48             	mov    0x48(%eax),%ebx
f010426f:	e9 71 02 00 00       	jmp    f01044e5 <syscall+0x3fc>
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!
	struct Env *e; 
	int env_id = envid2env(envid, &e, 1);
f0104274:	83 ec 04             	sub    $0x4,%esp
f0104277:	6a 01                	push   $0x1
f0104279:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010427c:	50                   	push   %eax
f010427d:	ff 75 0c             	pushl  0xc(%ebp)
f0104280:	e8 ae eb ff ff       	call   f0102e33 <envid2env>
	if (env_id) return -E_BAD_ENV;	//nvid doesn't currently exist
f0104285:	83 c4 10             	add    $0x10,%esp
f0104288:	85 c0                	test   %eax,%eax
f010428a:	75 5c                	jne    f01042e8 <syscall+0x1ff>

	if (va >= (void*)UTOP) return -E_INVAL;//va >= UTOP
f010428c:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104293:	77 5d                	ja     f01042f2 <syscall+0x209>
	
	if ((perm & (PTE_U|PTE_P)) != (PTE_U|PTE_P)) return -E_INVAL;//perm is inappropriate
f0104295:	8b 45 14             	mov    0x14(%ebp),%eax
f0104298:	83 e0 05             	and    $0x5,%eax
f010429b:	83 f8 05             	cmp    $0x5,%eax
f010429e:	75 5c                	jne    f01042fc <syscall+0x213>

	struct PageInfo *new_page = page_alloc(1);//init to zero
f01042a0:	83 ec 0c             	sub    $0xc,%esp
f01042a3:	6a 01                	push   $0x1
f01042a5:	e8 70 cc ff ff       	call   f0100f1a <page_alloc>
f01042aa:	89 c6                	mov    %eax,%esi
	if (!new_page) return -E_NO_MEM; //no memory
f01042ac:	83 c4 10             	add    $0x10,%esp
f01042af:	85 c0                	test   %eax,%eax
f01042b1:	74 53                	je     f0104306 <syscall+0x21d>
	new_page->pp_ref++;
f01042b3:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	env_id = page_insert(e->env_pgdir, new_page, va, perm);
f01042b8:	ff 75 14             	pushl  0x14(%ebp)
f01042bb:	ff 75 10             	pushl  0x10(%ebp)
f01042be:	50                   	push   %eax
f01042bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01042c2:	ff 70 60             	pushl  0x60(%eax)
f01042c5:	e8 f4 ce ff ff       	call   f01011be <page_insert>
	if (env_id) {
f01042ca:	83 c4 10             	add    $0x10,%esp
		page_free(new_page);
		return env_id;
	}

	return 0;
f01042cd:	89 c3                	mov    %eax,%ebx

	struct PageInfo *new_page = page_alloc(1);//init to zero
	if (!new_page) return -E_NO_MEM; //no memory
	new_page->pp_ref++;
	env_id = page_insert(e->env_pgdir, new_page, va, perm);
	if (env_id) {
f01042cf:	85 c0                	test   %eax,%eax
f01042d1:	0f 84 0e 02 00 00    	je     f01044e5 <syscall+0x3fc>
		page_free(new_page);
f01042d7:	83 ec 0c             	sub    $0xc,%esp
f01042da:	56                   	push   %esi
f01042db:	e8 a4 cc ff ff       	call   f0100f84 <page_free>
f01042e0:	83 c4 10             	add    $0x10,%esp
f01042e3:	e9 fd 01 00 00       	jmp    f01044e5 <syscall+0x3fc>
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!
	struct Env *e; 
	int env_id = envid2env(envid, &e, 1);
	if (env_id) return -E_BAD_ENV;	//nvid doesn't currently exist
f01042e8:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01042ed:	e9 f3 01 00 00       	jmp    f01044e5 <syscall+0x3fc>

	if (va >= (void*)UTOP) return -E_INVAL;//va >= UTOP
f01042f2:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01042f7:	e9 e9 01 00 00       	jmp    f01044e5 <syscall+0x3fc>
	
	if ((perm & (PTE_U|PTE_P)) != (PTE_U|PTE_P)) return -E_INVAL;//perm is inappropriate
f01042fc:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104301:	e9 df 01 00 00       	jmp    f01044e5 <syscall+0x3fc>

	struct PageInfo *new_page = page_alloc(1);//init to zero
	if (!new_page) return -E_NO_MEM; //no memory
f0104306:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f010430b:	e9 d5 01 00 00       	jmp    f01044e5 <syscall+0x3fc>

	// LAB 4: Your code here.
	//	-E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
	//		or the caller doesn't have permission to change one of them.
	struct Env *src, *dest;
	int env_id = envid2env(srcenvid, &src, 1);
f0104310:	83 ec 04             	sub    $0x4,%esp
f0104313:	6a 01                	push   $0x1
f0104315:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104318:	50                   	push   %eax
f0104319:	ff 75 0c             	pushl  0xc(%ebp)
f010431c:	e8 12 eb ff ff       	call   f0102e33 <envid2env>
	if (env_id) return -E_BAD_ENV;	//envid doesn't currently exist
f0104321:	83 c4 10             	add    $0x10,%esp
f0104324:	85 c0                	test   %eax,%eax
f0104326:	0f 85 a6 00 00 00    	jne    f01043d2 <syscall+0x2e9>
	env_id = envid2env(dstenvid, &dest, 1);
f010432c:	83 ec 04             	sub    $0x4,%esp
f010432f:	6a 01                	push   $0x1
f0104331:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104334:	50                   	push   %eax
f0104335:	ff 75 14             	pushl  0x14(%ebp)
f0104338:	e8 f6 ea ff ff       	call   f0102e33 <envid2env>
	if (env_id) return -E_BAD_ENV;	//envid doesn't currently exist
f010433d:	83 c4 10             	add    $0x10,%esp
f0104340:	85 c0                	test   %eax,%eax
f0104342:	0f 85 94 00 00 00    	jne    f01043dc <syscall+0x2f3>
	
	if (srcva>=(void*)UTOP || dstva>=(void*)UTOP || 
f0104348:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010434f:	0f 87 91 00 00 00    	ja     f01043e6 <syscall+0x2fd>
f0104355:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010435c:	0f 87 84 00 00 00    	ja     f01043e6 <syscall+0x2fd>
f0104362:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104369:	0f 85 81 00 00 00    	jne    f01043f0 <syscall+0x307>
		ROUNDDOWN(srcva,PGSIZE)!=srcva || ROUNDDOWN(dstva,PGSIZE)!=dstva) 
		return -E_INVAL; // page not aligned or out of bounds
f010436f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	if (env_id) return -E_BAD_ENV;	//envid doesn't currently exist
	env_id = envid2env(dstenvid, &dest, 1);
	if (env_id) return -E_BAD_ENV;	//envid doesn't currently exist
	
	if (srcva>=(void*)UTOP || dstva>=(void*)UTOP || 
		ROUNDDOWN(srcva,PGSIZE)!=srcva || ROUNDDOWN(dstva,PGSIZE)!=dstva) 
f0104374:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f010437b:	0f 85 64 01 00 00    	jne    f01044e5 <syscall+0x3fc>
		return -E_INVAL; // page not aligned or out of bounds

	pte_t *page_table_entry;
	struct PageInfo *new_page = page_lookup(src->env_pgdir, srcva, &page_table_entry);
f0104381:	83 ec 04             	sub    $0x4,%esp
f0104384:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104387:	50                   	push   %eax
f0104388:	ff 75 10             	pushl  0x10(%ebp)
f010438b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010438e:	ff 70 60             	pushl  0x60(%eax)
f0104391:	e8 3f cd ff ff       	call   f01010d5 <page_lookup>
	if (!new_page) return -E_INVAL;
f0104396:	83 c4 10             	add    $0x10,%esp
f0104399:	85 c0                	test   %eax,%eax
f010439b:	74 5d                	je     f01043fa <syscall+0x311>
	
	if ((perm & (PTE_U|PTE_P)) != (PTE_U|PTE_P)) return -E_INVAL;//permission not correct
f010439d:	8b 55 1c             	mov    0x1c(%ebp),%edx
f01043a0:	83 e2 05             	and    $0x5,%edx
f01043a3:	83 fa 05             	cmp    $0x5,%edx
f01043a6:	75 5c                	jne    f0104404 <syscall+0x31b>

	if (((*page_table_entry&PTE_W) == 0) && (perm&PTE_W)) return -E_INVAL; // no permission to write
f01043a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01043ab:	f6 02 02             	testb  $0x2,(%edx)
f01043ae:	75 06                	jne    f01043b6 <syscall+0x2cd>
f01043b0:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01043b4:	75 58                	jne    f010440e <syscall+0x325>
	
	env_id = page_insert(dest->env_pgdir, new_page, dstva, perm);
f01043b6:	ff 75 1c             	pushl  0x1c(%ebp)
f01043b9:	ff 75 18             	pushl  0x18(%ebp)
f01043bc:	50                   	push   %eax
f01043bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01043c0:	ff 70 60             	pushl  0x60(%eax)
f01043c3:	e8 f6 cd ff ff       	call   f01011be <page_insert>
f01043c8:	83 c4 10             	add    $0x10,%esp
	return env_id;
f01043cb:	89 c3                	mov    %eax,%ebx
f01043cd:	e9 13 01 00 00       	jmp    f01044e5 <syscall+0x3fc>
	// LAB 4: Your code here.
	//	-E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
	//		or the caller doesn't have permission to change one of them.
	struct Env *src, *dest;
	int env_id = envid2env(srcenvid, &src, 1);
	if (env_id) return -E_BAD_ENV;	//envid doesn't currently exist
f01043d2:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01043d7:	e9 09 01 00 00       	jmp    f01044e5 <syscall+0x3fc>
	env_id = envid2env(dstenvid, &dest, 1);
	if (env_id) return -E_BAD_ENV;	//envid doesn't currently exist
f01043dc:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01043e1:	e9 ff 00 00 00       	jmp    f01044e5 <syscall+0x3fc>
	
	if (srcva>=(void*)UTOP || dstva>=(void*)UTOP || 
		ROUNDDOWN(srcva,PGSIZE)!=srcva || ROUNDDOWN(dstva,PGSIZE)!=dstva) 
		return -E_INVAL; // page not aligned or out of bounds
f01043e6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01043eb:	e9 f5 00 00 00       	jmp    f01044e5 <syscall+0x3fc>
f01043f0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01043f5:	e9 eb 00 00 00       	jmp    f01044e5 <syscall+0x3fc>

	pte_t *page_table_entry;
	struct PageInfo *new_page = page_lookup(src->env_pgdir, srcva, &page_table_entry);
	if (!new_page) return -E_INVAL;
f01043fa:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01043ff:	e9 e1 00 00 00       	jmp    f01044e5 <syscall+0x3fc>
	
	if ((perm & (PTE_U|PTE_P)) != (PTE_U|PTE_P)) return -E_INVAL;//permission not correct
f0104404:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104409:	e9 d7 00 00 00       	jmp    f01044e5 <syscall+0x3fc>

	if (((*page_table_entry&PTE_W) == 0) && (perm&PTE_W)) return -E_INVAL; // no permission to write
f010440e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			break;
		case SYS_page_alloc:
			return sys_page_alloc(a1, (void*)a2, a3);
			break;
		case SYS_page_map:
			return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
f0104413:	e9 cd 00 00 00       	jmp    f01044e5 <syscall+0x3fc>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if (va>=(void*)UTOP || ROUNDDOWN(va,PGSIZE)!=va)
f0104418:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010441f:	77 46                	ja     f0104467 <syscall+0x37e>
		return -E_INVAL;// not aligned or out of bounds
f0104421:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if (va>=(void*)UTOP || ROUNDDOWN(va,PGSIZE)!=va)
f0104426:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010442d:	0f 85 b2 00 00 00    	jne    f01044e5 <syscall+0x3fc>
		return -E_INVAL;// not aligned or out of bounds
	struct Env *e;
	int env_id = envid2env(envid, &e, 1);
f0104433:	83 ec 04             	sub    $0x4,%esp
f0104436:	6a 01                	push   $0x1
f0104438:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010443b:	50                   	push   %eax
f010443c:	ff 75 0c             	pushl  0xc(%ebp)
f010443f:	e8 ef e9 ff ff       	call   f0102e33 <envid2env>
	if (env_id) return env_id;	//env id not valid
f0104444:	83 c4 10             	add    $0x10,%esp
f0104447:	89 c3                	mov    %eax,%ebx
f0104449:	85 c0                	test   %eax,%eax
f010444b:	0f 85 94 00 00 00    	jne    f01044e5 <syscall+0x3fc>
	page_remove(e->env_pgdir, va);
f0104451:	83 ec 08             	sub    $0x8,%esp
f0104454:	ff 75 10             	pushl  0x10(%ebp)
f0104457:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010445a:	ff 70 60             	pushl  0x60(%eax)
f010445d:	e8 0e cd ff ff       	call   f0101170 <page_remove>
f0104462:	83 c4 10             	add    $0x10,%esp
f0104465:	eb 7e                	jmp    f01044e5 <syscall+0x3fc>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if (va>=(void*)UTOP || ROUNDDOWN(va,PGSIZE)!=va)
		return -E_INVAL;// not aligned or out of bounds
f0104467:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010446c:	eb 77                	jmp    f01044e5 <syscall+0x3fc>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) return -E_INVAL;//status is not a valid status for an environment
f010446e:	8b 45 10             	mov    0x10(%ebp),%eax
f0104471:	83 e8 02             	sub    $0x2,%eax
f0104474:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104479:	75 28                	jne    f01044a3 <syscall+0x3ba>
	struct Env *e; 
	int env_id = envid2env(envid, &e, 1);
f010447b:	83 ec 04             	sub    $0x4,%esp
f010447e:	6a 01                	push   $0x1
f0104480:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104483:	50                   	push   %eax
f0104484:	ff 75 0c             	pushl  0xc(%ebp)
f0104487:	e8 a7 e9 ff ff       	call   f0102e33 <envid2env>
	if (env_id) return -E_BAD_ENV;	//envid doesn't currently exist
f010448c:	83 c4 10             	add    $0x10,%esp
f010448f:	85 c0                	test   %eax,%eax
f0104491:	75 17                	jne    f01044aa <syscall+0x3c1>
	e->env_status = status;
f0104493:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104496:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104499:	89 48 54             	mov    %ecx,0x54(%eax)
	return 0;
f010449c:	bb 00 00 00 00       	mov    $0x0,%ebx
f01044a1:	eb 42                	jmp    f01044e5 <syscall+0x3fc>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) return -E_INVAL;//status is not a valid status for an environment
f01044a3:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01044a8:	eb 3b                	jmp    f01044e5 <syscall+0x3fc>
	struct Env *e; 
	int env_id = envid2env(envid, &e, 1);
	if (env_id) return -E_BAD_ENV;	//envid doesn't currently exist
f01044aa:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
			break;
		case SYS_page_unmap:
			return sys_page_unmap(a1, (void*)a2);
			break;
		case SYS_env_set_status:
			return sys_env_set_status(a1, a2);
f01044af:	eb 34                	jmp    f01044e5 <syscall+0x3fc>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e; 
	int env_id = envid2env(envid, &e, 1);
f01044b1:	83 ec 04             	sub    $0x4,%esp
f01044b4:	6a 01                	push   $0x1
f01044b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01044b9:	50                   	push   %eax
f01044ba:	ff 75 0c             	pushl  0xc(%ebp)
f01044bd:	e8 71 e9 ff ff       	call   f0102e33 <envid2env>
	if (env_id) return -E_BAD_ENV;	//invalid env id
f01044c2:	83 c4 10             	add    $0x10,%esp
f01044c5:	85 c0                	test   %eax,%eax
f01044c7:	75 10                	jne    f01044d9 <syscall+0x3f0>
	e->env_pgfault_upcall = func;
f01044c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01044cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01044cf:	89 48 64             	mov    %ecx,0x64(%eax)
	return 0;
f01044d2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01044d7:	eb 0c                	jmp    f01044e5 <syscall+0x3fc>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e; 
	int env_id = envid2env(envid, &e, 1);
	if (env_id) return -E_BAD_ENV;	//invalid env id
f01044d9:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
			break;
		case SYS_env_set_status:
			return sys_env_set_status(a1, a2);
			break;
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void*)a2);
f01044de:	eb 05                	jmp    f01044e5 <syscall+0x3fc>
			break;
		default:
			ret = -E_INVAL;
f01044e0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	}
	// cprintf("ret: %x\n", ret);
	return ret;
	panic("syscall not implemented");
}
f01044e5:	89 d8                	mov    %ebx,%eax
f01044e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01044ea:	5b                   	pop    %ebx
f01044eb:	5e                   	pop    %esi
f01044ec:	5f                   	pop    %edi
f01044ed:	5d                   	pop    %ebp
f01044ee:	c3                   	ret    

f01044ef <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01044ef:	55                   	push   %ebp
f01044f0:	89 e5                	mov    %esp,%ebp
f01044f2:	57                   	push   %edi
f01044f3:	56                   	push   %esi
f01044f4:	53                   	push   %ebx
f01044f5:	83 ec 14             	sub    $0x14,%esp
f01044f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01044fb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01044fe:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104501:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104504:	8b 1a                	mov    (%edx),%ebx
f0104506:	8b 01                	mov    (%ecx),%eax
f0104508:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010450b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104512:	eb 7f                	jmp    f0104593 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104514:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104517:	01 d8                	add    %ebx,%eax
f0104519:	89 c6                	mov    %eax,%esi
f010451b:	c1 ee 1f             	shr    $0x1f,%esi
f010451e:	01 c6                	add    %eax,%esi
f0104520:	d1 fe                	sar    %esi
f0104522:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104525:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104528:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f010452b:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010452d:	eb 03                	jmp    f0104532 <stab_binsearch+0x43>
			m--;
f010452f:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104532:	39 c3                	cmp    %eax,%ebx
f0104534:	7f 0d                	jg     f0104543 <stab_binsearch+0x54>
f0104536:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010453a:	83 ea 0c             	sub    $0xc,%edx
f010453d:	39 f9                	cmp    %edi,%ecx
f010453f:	75 ee                	jne    f010452f <stab_binsearch+0x40>
f0104541:	eb 05                	jmp    f0104548 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104543:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104546:	eb 4b                	jmp    f0104593 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104548:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010454b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010454e:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104552:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104555:	76 11                	jbe    f0104568 <stab_binsearch+0x79>
			*region_left = m;
f0104557:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010455a:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010455c:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010455f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104566:	eb 2b                	jmp    f0104593 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104568:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010456b:	73 14                	jae    f0104581 <stab_binsearch+0x92>
			*region_right = m - 1;
f010456d:	83 e8 01             	sub    $0x1,%eax
f0104570:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104573:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104576:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104578:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010457f:	eb 12                	jmp    f0104593 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104581:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104584:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104586:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010458a:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010458c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104593:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104596:	0f 8e 78 ff ff ff    	jle    f0104514 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010459c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01045a0:	75 0f                	jne    f01045b1 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f01045a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01045a5:	8b 00                	mov    (%eax),%eax
f01045a7:	83 e8 01             	sub    $0x1,%eax
f01045aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01045ad:	89 06                	mov    %eax,(%esi)
f01045af:	eb 2c                	jmp    f01045dd <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01045b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01045b4:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01045b6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01045b9:	8b 0e                	mov    (%esi),%ecx
f01045bb:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01045be:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01045c1:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01045c4:	eb 03                	jmp    f01045c9 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01045c6:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01045c9:	39 c8                	cmp    %ecx,%eax
f01045cb:	7e 0b                	jle    f01045d8 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01045cd:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01045d1:	83 ea 0c             	sub    $0xc,%edx
f01045d4:	39 df                	cmp    %ebx,%edi
f01045d6:	75 ee                	jne    f01045c6 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01045d8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01045db:	89 06                	mov    %eax,(%esi)
	}
}
f01045dd:	83 c4 14             	add    $0x14,%esp
f01045e0:	5b                   	pop    %ebx
f01045e1:	5e                   	pop    %esi
f01045e2:	5f                   	pop    %edi
f01045e3:	5d                   	pop    %ebp
f01045e4:	c3                   	ret    

f01045e5 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01045e5:	55                   	push   %ebp
f01045e6:	89 e5                	mov    %esp,%ebp
f01045e8:	57                   	push   %edi
f01045e9:	56                   	push   %esi
f01045ea:	53                   	push   %ebx
f01045eb:	83 ec 3c             	sub    $0x3c,%esp
f01045ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01045f1:	c7 03 70 75 10 f0    	movl   $0xf0107570,(%ebx)
	info->eip_line = 0;
f01045f7:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01045fe:	c7 43 08 70 75 10 f0 	movl   $0xf0107570,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104605:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010460c:	8b 45 08             	mov    0x8(%ebp),%eax
f010460f:	89 43 10             	mov    %eax,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104612:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104619:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f010461e:	0f 87 96 00 00 00    	ja     f01046ba <debuginfo_eip+0xd5>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0104624:	e8 85 10 00 00       	call   f01056ae <cpunum>
f0104629:	6a 04                	push   $0x4
f010462b:	6a 10                	push   $0x10
f010462d:	68 00 00 20 00       	push   $0x200000
f0104632:	6b c0 74             	imul   $0x74,%eax,%eax
f0104635:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f010463b:	e8 bc e6 ff ff       	call   f0102cfc <user_mem_check>
f0104640:	83 c4 10             	add    $0x10,%esp
f0104643:	85 c0                	test   %eax,%eax
f0104645:	0f 85 38 02 00 00    	jne    f0104883 <debuginfo_eip+0x29e>
		return -1;

		stabs = usd->stabs;
f010464b:	a1 00 00 20 00       	mov    0x200000,%eax
f0104650:	89 c7                	mov    %eax,%edi
f0104652:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stab_end = usd->stab_end;
f0104655:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f010465b:	a1 08 00 20 00       	mov    0x200008,%eax
f0104660:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104663:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0104669:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f010466c:	e8 3d 10 00 00       	call   f01056ae <cpunum>
f0104671:	6a 04                	push   $0x4
f0104673:	6a 0c                	push   $0xc
f0104675:	57                   	push   %edi
f0104676:	6b c0 74             	imul   $0x74,%eax,%eax
f0104679:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f010467f:	e8 78 e6 ff ff       	call   f0102cfc <user_mem_check>
f0104684:	83 c4 10             	add    $0x10,%esp
f0104687:	85 c0                	test   %eax,%eax
f0104689:	0f 85 fb 01 00 00    	jne    f010488a <debuginfo_eip+0x2a5>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f010468f:	e8 1a 10 00 00       	call   f01056ae <cpunum>
f0104694:	6a 04                	push   $0x4
f0104696:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0104699:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f010469c:	29 ca                	sub    %ecx,%edx
f010469e:	52                   	push   %edx
f010469f:	51                   	push   %ecx
f01046a0:	6b c0 74             	imul   $0x74,%eax,%eax
f01046a3:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f01046a9:	e8 4e e6 ff ff       	call   f0102cfc <user_mem_check>
f01046ae:	83 c4 10             	add    $0x10,%esp
f01046b1:	85 c0                	test   %eax,%eax
f01046b3:	74 1f                	je     f01046d4 <debuginfo_eip+0xef>
f01046b5:	e9 d7 01 00 00       	jmp    f0104891 <debuginfo_eip+0x2ac>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01046ba:	c7 45 c0 54 4e 11 f0 	movl   $0xf0114e54,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01046c1:	c7 45 b8 e5 17 11 f0 	movl   $0xf01117e5,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01046c8:	be e4 17 11 f0       	mov    $0xf01117e4,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01046cd:	c7 45 bc 58 7a 10 f0 	movl   $0xf0107a58,-0x44(%ebp)


	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01046d4:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01046d7:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f01046da:	0f 83 b8 01 00 00    	jae    f0104898 <debuginfo_eip+0x2b3>
f01046e0:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01046e4:	0f 85 b5 01 00 00    	jne    f010489f <debuginfo_eip+0x2ba>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01046ea:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01046f1:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01046f4:	29 fe                	sub    %edi,%esi
f01046f6:	c1 fe 02             	sar    $0x2,%esi
f01046f9:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f01046ff:	83 e8 01             	sub    $0x1,%eax
f0104702:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104705:	83 ec 08             	sub    $0x8,%esp
f0104708:	ff 75 08             	pushl  0x8(%ebp)
f010470b:	6a 64                	push   $0x64
f010470d:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104710:	89 d1                	mov    %edx,%ecx
f0104712:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104715:	89 f8                	mov    %edi,%eax
f0104717:	e8 d3 fd ff ff       	call   f01044ef <stab_binsearch>
	if (lfile == 0)
f010471c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010471f:	83 c4 10             	add    $0x10,%esp
f0104722:	85 c0                	test   %eax,%eax
f0104724:	0f 84 7c 01 00 00    	je     f01048a6 <debuginfo_eip+0x2c1>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010472a:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010472d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104730:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104733:	83 ec 08             	sub    $0x8,%esp
f0104736:	ff 75 08             	pushl  0x8(%ebp)
f0104739:	6a 24                	push   $0x24
f010473b:	8d 55 d8             	lea    -0x28(%ebp),%edx
f010473e:	89 d1                	mov    %edx,%ecx
f0104740:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104743:	89 f8                	mov    %edi,%eax
f0104745:	e8 a5 fd ff ff       	call   f01044ef <stab_binsearch>

	if (lfun <= rfun) {
f010474a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010474d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104750:	83 c4 10             	add    $0x10,%esp
f0104753:	39 d0                	cmp    %edx,%eax
f0104755:	7f 52                	jg     f01047a9 <debuginfo_eip+0x1c4>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104757:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f010475a:	8d 34 8f             	lea    (%edi,%ecx,4),%esi
f010475d:	8b 3e                	mov    (%esi),%edi
f010475f:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104762:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f0104765:	39 cf                	cmp    %ecx,%edi
f0104767:	73 06                	jae    f010476f <debuginfo_eip+0x18a>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104769:	03 7d b8             	add    -0x48(%ebp),%edi
f010476c:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010476f:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104772:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
		// Search within the function definition for the line number.
		lline = lfun;
f0104775:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104778:	89 55 d0             	mov    %edx,-0x30(%ebp)
stab_binsearch(stabs, &lline, &rline, N_SLINE, addr); //----------------------------------------> New Insertion
f010477b:	83 ec 08             	sub    $0x8,%esp
f010477e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104781:	29 c8                	sub    %ecx,%eax
f0104783:	50                   	push   %eax
f0104784:	6a 44                	push   $0x44
f0104786:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104789:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010478c:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010478f:	89 f8                	mov    %edi,%eax
f0104791:	e8 59 fd ff ff       	call   f01044ef <stab_binsearch>
info->eip_line = stabs[lline].n_desc;
f0104796:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104799:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010479c:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f01047a1:	89 43 04             	mov    %eax,0x4(%ebx)
f01047a4:	83 c4 10             	add    $0x10,%esp
f01047a7:	eb 12                	jmp    f01047bb <debuginfo_eip+0x1d6>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01047a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01047ac:	89 43 10             	mov    %eax,0x10(%ebx)
		lline = lfile;
f01047af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047b2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01047b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01047b8:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01047bb:	83 ec 08             	sub    $0x8,%esp
f01047be:	6a 3a                	push   $0x3a
f01047c0:	ff 73 08             	pushl  0x8(%ebx)
f01047c3:	e8 a7 08 00 00       	call   f010506f <strfind>
f01047c8:	2b 43 08             	sub    0x8(%ebx),%eax
f01047cb:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01047ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01047d1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01047d4:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01047d7:	8b 75 bc             	mov    -0x44(%ebp),%esi
f01047da:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01047dd:	83 c4 10             	add    $0x10,%esp
f01047e0:	c6 45 c7 00          	movb   $0x0,-0x39(%ebp)
f01047e4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01047e7:	eb 0a                	jmp    f01047f3 <debuginfo_eip+0x20e>
f01047e9:	83 e8 01             	sub    $0x1,%eax
f01047ec:	83 ea 0c             	sub    $0xc,%edx
f01047ef:	c6 45 c7 01          	movb   $0x1,-0x39(%ebp)
f01047f3:	39 c7                	cmp    %eax,%edi
f01047f5:	7e 05                	jle    f01047fc <debuginfo_eip+0x217>
f01047f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01047fa:	eb 47                	jmp    f0104843 <debuginfo_eip+0x25e>
	       && stabs[lline].n_type != N_SOL
f01047fc:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104800:	80 f9 84             	cmp    $0x84,%cl
f0104803:	75 0e                	jne    f0104813 <debuginfo_eip+0x22e>
f0104805:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104808:	80 7d c7 00          	cmpb   $0x0,-0x39(%ebp)
f010480c:	74 1c                	je     f010482a <debuginfo_eip+0x245>
f010480e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104811:	eb 17                	jmp    f010482a <debuginfo_eip+0x245>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104813:	80 f9 64             	cmp    $0x64,%cl
f0104816:	75 d1                	jne    f01047e9 <debuginfo_eip+0x204>
f0104818:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f010481c:	74 cb                	je     f01047e9 <debuginfo_eip+0x204>
f010481e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104821:	80 7d c7 00          	cmpb   $0x0,-0x39(%ebp)
f0104825:	74 03                	je     f010482a <debuginfo_eip+0x245>
f0104827:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010482a:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010482d:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104830:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104833:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0104836:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104839:	29 f8                	sub    %edi,%eax
f010483b:	39 c2                	cmp    %eax,%edx
f010483d:	73 04                	jae    f0104843 <debuginfo_eip+0x25e>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010483f:	01 fa                	add    %edi,%edx
f0104841:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104843:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104846:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104849:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010484e:	39 f2                	cmp    %esi,%edx
f0104850:	7d 60                	jge    f01048b2 <debuginfo_eip+0x2cd>
		for (lline = lfun + 1;
f0104852:	83 c2 01             	add    $0x1,%edx
f0104855:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104858:	89 d0                	mov    %edx,%eax
f010485a:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010485d:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104860:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104863:	eb 04                	jmp    f0104869 <debuginfo_eip+0x284>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104865:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104869:	39 c6                	cmp    %eax,%esi
f010486b:	7e 40                	jle    f01048ad <debuginfo_eip+0x2c8>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010486d:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104871:	83 c0 01             	add    $0x1,%eax
f0104874:	83 c2 0c             	add    $0xc,%edx
f0104877:	80 f9 a0             	cmp    $0xa0,%cl
f010487a:	74 e9                	je     f0104865 <debuginfo_eip+0x280>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010487c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104881:	eb 2f                	jmp    f01048b2 <debuginfo_eip+0x2cd>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
		return -1;
f0104883:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104888:	eb 28                	jmp    f01048b2 <debuginfo_eip+0x2cd>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;
f010488a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010488f:	eb 21                	jmp    f01048b2 <debuginfo_eip+0x2cd>

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
		return -1;
f0104891:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104896:	eb 1a                	jmp    f01048b2 <debuginfo_eip+0x2cd>

	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104898:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010489d:	eb 13                	jmp    f01048b2 <debuginfo_eip+0x2cd>
f010489f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01048a4:	eb 0c                	jmp    f01048b2 <debuginfo_eip+0x2cd>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01048a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01048ab:	eb 05                	jmp    f01048b2 <debuginfo_eip+0x2cd>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01048ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01048b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01048b5:	5b                   	pop    %ebx
f01048b6:	5e                   	pop    %esi
f01048b7:	5f                   	pop    %edi
f01048b8:	5d                   	pop    %ebp
f01048b9:	c3                   	ret    

f01048ba <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01048ba:	55                   	push   %ebp
f01048bb:	89 e5                	mov    %esp,%ebp
f01048bd:	57                   	push   %edi
f01048be:	56                   	push   %esi
f01048bf:	53                   	push   %ebx
f01048c0:	83 ec 1c             	sub    $0x1c,%esp
f01048c3:	89 c7                	mov    %eax,%edi
f01048c5:	89 d6                	mov    %edx,%esi
f01048c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01048ca:	8b 55 0c             	mov    0xc(%ebp),%edx
f01048cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01048d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01048d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01048d6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01048db:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01048de:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01048e1:	39 d3                	cmp    %edx,%ebx
f01048e3:	72 05                	jb     f01048ea <printnum+0x30>
f01048e5:	39 45 10             	cmp    %eax,0x10(%ebp)
f01048e8:	77 45                	ja     f010492f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01048ea:	83 ec 0c             	sub    $0xc,%esp
f01048ed:	ff 75 18             	pushl  0x18(%ebp)
f01048f0:	8b 45 14             	mov    0x14(%ebp),%eax
f01048f3:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01048f6:	53                   	push   %ebx
f01048f7:	ff 75 10             	pushl  0x10(%ebp)
f01048fa:	83 ec 08             	sub    $0x8,%esp
f01048fd:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104900:	ff 75 e0             	pushl  -0x20(%ebp)
f0104903:	ff 75 dc             	pushl  -0x24(%ebp)
f0104906:	ff 75 d8             	pushl  -0x28(%ebp)
f0104909:	e8 a2 11 00 00       	call   f0105ab0 <__udivdi3>
f010490e:	83 c4 18             	add    $0x18,%esp
f0104911:	52                   	push   %edx
f0104912:	50                   	push   %eax
f0104913:	89 f2                	mov    %esi,%edx
f0104915:	89 f8                	mov    %edi,%eax
f0104917:	e8 9e ff ff ff       	call   f01048ba <printnum>
f010491c:	83 c4 20             	add    $0x20,%esp
f010491f:	eb 18                	jmp    f0104939 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104921:	83 ec 08             	sub    $0x8,%esp
f0104924:	56                   	push   %esi
f0104925:	ff 75 18             	pushl  0x18(%ebp)
f0104928:	ff d7                	call   *%edi
f010492a:	83 c4 10             	add    $0x10,%esp
f010492d:	eb 03                	jmp    f0104932 <printnum+0x78>
f010492f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104932:	83 eb 01             	sub    $0x1,%ebx
f0104935:	85 db                	test   %ebx,%ebx
f0104937:	7f e8                	jg     f0104921 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104939:	83 ec 08             	sub    $0x8,%esp
f010493c:	56                   	push   %esi
f010493d:	83 ec 04             	sub    $0x4,%esp
f0104940:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104943:	ff 75 e0             	pushl  -0x20(%ebp)
f0104946:	ff 75 dc             	pushl  -0x24(%ebp)
f0104949:	ff 75 d8             	pushl  -0x28(%ebp)
f010494c:	e8 8f 12 00 00       	call   f0105be0 <__umoddi3>
f0104951:	83 c4 14             	add    $0x14,%esp
f0104954:	0f be 80 7a 75 10 f0 	movsbl -0xfef8a86(%eax),%eax
f010495b:	50                   	push   %eax
f010495c:	ff d7                	call   *%edi
}
f010495e:	83 c4 10             	add    $0x10,%esp
f0104961:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104964:	5b                   	pop    %ebx
f0104965:	5e                   	pop    %esi
f0104966:	5f                   	pop    %edi
f0104967:	5d                   	pop    %ebp
f0104968:	c3                   	ret    

f0104969 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104969:	55                   	push   %ebp
f010496a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010496c:	83 fa 01             	cmp    $0x1,%edx
f010496f:	7e 0e                	jle    f010497f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104971:	8b 10                	mov    (%eax),%edx
f0104973:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104976:	89 08                	mov    %ecx,(%eax)
f0104978:	8b 02                	mov    (%edx),%eax
f010497a:	8b 52 04             	mov    0x4(%edx),%edx
f010497d:	eb 22                	jmp    f01049a1 <getuint+0x38>
	else if (lflag)
f010497f:	85 d2                	test   %edx,%edx
f0104981:	74 10                	je     f0104993 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104983:	8b 10                	mov    (%eax),%edx
f0104985:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104988:	89 08                	mov    %ecx,(%eax)
f010498a:	8b 02                	mov    (%edx),%eax
f010498c:	ba 00 00 00 00       	mov    $0x0,%edx
f0104991:	eb 0e                	jmp    f01049a1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104993:	8b 10                	mov    (%eax),%edx
f0104995:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104998:	89 08                	mov    %ecx,(%eax)
f010499a:	8b 02                	mov    (%edx),%eax
f010499c:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01049a1:	5d                   	pop    %ebp
f01049a2:	c3                   	ret    

f01049a3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01049a3:	55                   	push   %ebp
f01049a4:	89 e5                	mov    %esp,%ebp
f01049a6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01049a9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01049ad:	8b 10                	mov    (%eax),%edx
f01049af:	3b 50 04             	cmp    0x4(%eax),%edx
f01049b2:	73 0a                	jae    f01049be <sprintputch+0x1b>
		*b->buf++ = ch;
f01049b4:	8d 4a 01             	lea    0x1(%edx),%ecx
f01049b7:	89 08                	mov    %ecx,(%eax)
f01049b9:	8b 45 08             	mov    0x8(%ebp),%eax
f01049bc:	88 02                	mov    %al,(%edx)
}
f01049be:	5d                   	pop    %ebp
f01049bf:	c3                   	ret    

f01049c0 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01049c0:	55                   	push   %ebp
f01049c1:	89 e5                	mov    %esp,%ebp
f01049c3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01049c6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01049c9:	50                   	push   %eax
f01049ca:	ff 75 10             	pushl  0x10(%ebp)
f01049cd:	ff 75 0c             	pushl  0xc(%ebp)
f01049d0:	ff 75 08             	pushl  0x8(%ebp)
f01049d3:	e8 05 00 00 00       	call   f01049dd <vprintfmt>
	va_end(ap);
}
f01049d8:	83 c4 10             	add    $0x10,%esp
f01049db:	c9                   	leave  
f01049dc:	c3                   	ret    

f01049dd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01049dd:	55                   	push   %ebp
f01049de:	89 e5                	mov    %esp,%ebp
f01049e0:	57                   	push   %edi
f01049e1:	56                   	push   %esi
f01049e2:	53                   	push   %ebx
f01049e3:	83 ec 2c             	sub    $0x2c,%esp
f01049e6:	8b 75 08             	mov    0x8(%ebp),%esi
f01049e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01049ec:	8b 7d 10             	mov    0x10(%ebp),%edi
f01049ef:	eb 12                	jmp    f0104a03 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01049f1:	85 c0                	test   %eax,%eax
f01049f3:	0f 84 cb 03 00 00    	je     f0104dc4 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
f01049f9:	83 ec 08             	sub    $0x8,%esp
f01049fc:	53                   	push   %ebx
f01049fd:	50                   	push   %eax
f01049fe:	ff d6                	call   *%esi
f0104a00:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104a03:	83 c7 01             	add    $0x1,%edi
f0104a06:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104a0a:	83 f8 25             	cmp    $0x25,%eax
f0104a0d:	75 e2                	jne    f01049f1 <vprintfmt+0x14>
f0104a0f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104a13:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104a1a:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0104a21:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104a28:	ba 00 00 00 00       	mov    $0x0,%edx
f0104a2d:	eb 07                	jmp    f0104a36 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104a2f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104a32:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104a36:	8d 47 01             	lea    0x1(%edi),%eax
f0104a39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104a3c:	0f b6 07             	movzbl (%edi),%eax
f0104a3f:	0f b6 c8             	movzbl %al,%ecx
f0104a42:	83 e8 23             	sub    $0x23,%eax
f0104a45:	3c 55                	cmp    $0x55,%al
f0104a47:	0f 87 5c 03 00 00    	ja     f0104da9 <vprintfmt+0x3cc>
f0104a4d:	0f b6 c0             	movzbl %al,%eax
f0104a50:	ff 24 85 40 76 10 f0 	jmp    *-0xfef89c0(,%eax,4)
f0104a57:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104a5a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104a5e:	eb d6                	jmp    f0104a36 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104a60:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104a63:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a68:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104a6b:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104a6e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0104a72:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0104a75:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0104a78:	83 fa 09             	cmp    $0x9,%edx
f0104a7b:	77 39                	ja     f0104ab6 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104a7d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104a80:	eb e9                	jmp    f0104a6b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104a82:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a85:	8d 48 04             	lea    0x4(%eax),%ecx
f0104a88:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104a8b:	8b 00                	mov    (%eax),%eax
f0104a8d:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104a90:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104a93:	eb 27                	jmp    f0104abc <vprintfmt+0xdf>
f0104a95:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a98:	85 c0                	test   %eax,%eax
f0104a9a:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104a9f:	0f 49 c8             	cmovns %eax,%ecx
f0104aa2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104aa5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104aa8:	eb 8c                	jmp    f0104a36 <vprintfmt+0x59>
f0104aaa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104aad:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104ab4:	eb 80                	jmp    f0104a36 <vprintfmt+0x59>
f0104ab6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104ab9:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
f0104abc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104ac0:	0f 89 70 ff ff ff    	jns    f0104a36 <vprintfmt+0x59>
				width = precision, precision = -1;
f0104ac6:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104ac9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104acc:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0104ad3:	e9 5e ff ff ff       	jmp    f0104a36 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104ad8:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104adb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104ade:	e9 53 ff ff ff       	jmp    f0104a36 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104ae3:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ae6:	8d 50 04             	lea    0x4(%eax),%edx
f0104ae9:	89 55 14             	mov    %edx,0x14(%ebp)
f0104aec:	83 ec 08             	sub    $0x8,%esp
f0104aef:	53                   	push   %ebx
f0104af0:	ff 30                	pushl  (%eax)
f0104af2:	ff d6                	call   *%esi
			break;
f0104af4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104af7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104afa:	e9 04 ff ff ff       	jmp    f0104a03 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104aff:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b02:	8d 50 04             	lea    0x4(%eax),%edx
f0104b05:	89 55 14             	mov    %edx,0x14(%ebp)
f0104b08:	8b 00                	mov    (%eax),%eax
f0104b0a:	99                   	cltd   
f0104b0b:	31 d0                	xor    %edx,%eax
f0104b0d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104b0f:	83 f8 09             	cmp    $0x9,%eax
f0104b12:	7f 0b                	jg     f0104b1f <vprintfmt+0x142>
f0104b14:	8b 14 85 a0 77 10 f0 	mov    -0xfef8860(,%eax,4),%edx
f0104b1b:	85 d2                	test   %edx,%edx
f0104b1d:	75 18                	jne    f0104b37 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0104b1f:	50                   	push   %eax
f0104b20:	68 92 75 10 f0       	push   $0xf0107592
f0104b25:	53                   	push   %ebx
f0104b26:	56                   	push   %esi
f0104b27:	e8 94 fe ff ff       	call   f01049c0 <printfmt>
f0104b2c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b2f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104b32:	e9 cc fe ff ff       	jmp    f0104a03 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0104b37:	52                   	push   %edx
f0104b38:	68 48 63 10 f0       	push   $0xf0106348
f0104b3d:	53                   	push   %ebx
f0104b3e:	56                   	push   %esi
f0104b3f:	e8 7c fe ff ff       	call   f01049c0 <printfmt>
f0104b44:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b47:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104b4a:	e9 b4 fe ff ff       	jmp    f0104a03 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104b4f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b52:	8d 50 04             	lea    0x4(%eax),%edx
f0104b55:	89 55 14             	mov    %edx,0x14(%ebp)
f0104b58:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0104b5a:	85 ff                	test   %edi,%edi
f0104b5c:	b8 8b 75 10 f0       	mov    $0xf010758b,%eax
f0104b61:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0104b64:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104b68:	0f 8e 94 00 00 00    	jle    f0104c02 <vprintfmt+0x225>
f0104b6e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104b72:	0f 84 98 00 00 00    	je     f0104c10 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104b78:	83 ec 08             	sub    $0x8,%esp
f0104b7b:	ff 75 c8             	pushl  -0x38(%ebp)
f0104b7e:	57                   	push   %edi
f0104b7f:	e8 a1 03 00 00       	call   f0104f25 <strnlen>
f0104b84:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104b87:	29 c1                	sub    %eax,%ecx
f0104b89:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0104b8c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104b8f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104b93:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104b96:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104b99:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104b9b:	eb 0f                	jmp    f0104bac <vprintfmt+0x1cf>
					putch(padc, putdat);
f0104b9d:	83 ec 08             	sub    $0x8,%esp
f0104ba0:	53                   	push   %ebx
f0104ba1:	ff 75 e0             	pushl  -0x20(%ebp)
f0104ba4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104ba6:	83 ef 01             	sub    $0x1,%edi
f0104ba9:	83 c4 10             	add    $0x10,%esp
f0104bac:	85 ff                	test   %edi,%edi
f0104bae:	7f ed                	jg     f0104b9d <vprintfmt+0x1c0>
f0104bb0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104bb3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104bb6:	85 c9                	test   %ecx,%ecx
f0104bb8:	b8 00 00 00 00       	mov    $0x0,%eax
f0104bbd:	0f 49 c1             	cmovns %ecx,%eax
f0104bc0:	29 c1                	sub    %eax,%ecx
f0104bc2:	89 75 08             	mov    %esi,0x8(%ebp)
f0104bc5:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0104bc8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104bcb:	89 cb                	mov    %ecx,%ebx
f0104bcd:	eb 4d                	jmp    f0104c1c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104bcf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104bd3:	74 1b                	je     f0104bf0 <vprintfmt+0x213>
f0104bd5:	0f be c0             	movsbl %al,%eax
f0104bd8:	83 e8 20             	sub    $0x20,%eax
f0104bdb:	83 f8 5e             	cmp    $0x5e,%eax
f0104bde:	76 10                	jbe    f0104bf0 <vprintfmt+0x213>
					putch('?', putdat);
f0104be0:	83 ec 08             	sub    $0x8,%esp
f0104be3:	ff 75 0c             	pushl  0xc(%ebp)
f0104be6:	6a 3f                	push   $0x3f
f0104be8:	ff 55 08             	call   *0x8(%ebp)
f0104beb:	83 c4 10             	add    $0x10,%esp
f0104bee:	eb 0d                	jmp    f0104bfd <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0104bf0:	83 ec 08             	sub    $0x8,%esp
f0104bf3:	ff 75 0c             	pushl  0xc(%ebp)
f0104bf6:	52                   	push   %edx
f0104bf7:	ff 55 08             	call   *0x8(%ebp)
f0104bfa:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104bfd:	83 eb 01             	sub    $0x1,%ebx
f0104c00:	eb 1a                	jmp    f0104c1c <vprintfmt+0x23f>
f0104c02:	89 75 08             	mov    %esi,0x8(%ebp)
f0104c05:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0104c08:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104c0b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104c0e:	eb 0c                	jmp    f0104c1c <vprintfmt+0x23f>
f0104c10:	89 75 08             	mov    %esi,0x8(%ebp)
f0104c13:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0104c16:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104c19:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104c1c:	83 c7 01             	add    $0x1,%edi
f0104c1f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104c23:	0f be d0             	movsbl %al,%edx
f0104c26:	85 d2                	test   %edx,%edx
f0104c28:	74 23                	je     f0104c4d <vprintfmt+0x270>
f0104c2a:	85 f6                	test   %esi,%esi
f0104c2c:	78 a1                	js     f0104bcf <vprintfmt+0x1f2>
f0104c2e:	83 ee 01             	sub    $0x1,%esi
f0104c31:	79 9c                	jns    f0104bcf <vprintfmt+0x1f2>
f0104c33:	89 df                	mov    %ebx,%edi
f0104c35:	8b 75 08             	mov    0x8(%ebp),%esi
f0104c38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104c3b:	eb 18                	jmp    f0104c55 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104c3d:	83 ec 08             	sub    $0x8,%esp
f0104c40:	53                   	push   %ebx
f0104c41:	6a 20                	push   $0x20
f0104c43:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104c45:	83 ef 01             	sub    $0x1,%edi
f0104c48:	83 c4 10             	add    $0x10,%esp
f0104c4b:	eb 08                	jmp    f0104c55 <vprintfmt+0x278>
f0104c4d:	89 df                	mov    %ebx,%edi
f0104c4f:	8b 75 08             	mov    0x8(%ebp),%esi
f0104c52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104c55:	85 ff                	test   %edi,%edi
f0104c57:	7f e4                	jg     f0104c3d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c59:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104c5c:	e9 a2 fd ff ff       	jmp    f0104a03 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104c61:	83 fa 01             	cmp    $0x1,%edx
f0104c64:	7e 16                	jle    f0104c7c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0104c66:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c69:	8d 50 08             	lea    0x8(%eax),%edx
f0104c6c:	89 55 14             	mov    %edx,0x14(%ebp)
f0104c6f:	8b 50 04             	mov    0x4(%eax),%edx
f0104c72:	8b 00                	mov    (%eax),%eax
f0104c74:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104c77:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0104c7a:	eb 32                	jmp    f0104cae <vprintfmt+0x2d1>
	else if (lflag)
f0104c7c:	85 d2                	test   %edx,%edx
f0104c7e:	74 18                	je     f0104c98 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0104c80:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c83:	8d 50 04             	lea    0x4(%eax),%edx
f0104c86:	89 55 14             	mov    %edx,0x14(%ebp)
f0104c89:	8b 00                	mov    (%eax),%eax
f0104c8b:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104c8e:	89 c1                	mov    %eax,%ecx
f0104c90:	c1 f9 1f             	sar    $0x1f,%ecx
f0104c93:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0104c96:	eb 16                	jmp    f0104cae <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0104c98:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c9b:	8d 50 04             	lea    0x4(%eax),%edx
f0104c9e:	89 55 14             	mov    %edx,0x14(%ebp)
f0104ca1:	8b 00                	mov    (%eax),%eax
f0104ca3:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104ca6:	89 c1                	mov    %eax,%ecx
f0104ca8:	c1 f9 1f             	sar    $0x1f,%ecx
f0104cab:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104cae:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104cb1:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104cb4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104cb7:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104cba:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0104cbf:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0104cc3:	0f 89 a8 00 00 00    	jns    f0104d71 <vprintfmt+0x394>
				putch('-', putdat);
f0104cc9:	83 ec 08             	sub    $0x8,%esp
f0104ccc:	53                   	push   %ebx
f0104ccd:	6a 2d                	push   $0x2d
f0104ccf:	ff d6                	call   *%esi
				num = -(long long) num;
f0104cd1:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104cd4:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104cd7:	f7 d8                	neg    %eax
f0104cd9:	83 d2 00             	adc    $0x0,%edx
f0104cdc:	f7 da                	neg    %edx
f0104cde:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104ce1:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104ce4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0104ce7:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104cec:	e9 80 00 00 00       	jmp    f0104d71 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104cf1:	8d 45 14             	lea    0x14(%ebp),%eax
f0104cf4:	e8 70 fc ff ff       	call   f0104969 <getuint>
f0104cf9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104cfc:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
f0104cff:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0104d04:	eb 6b                	jmp    f0104d71 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0104d06:	8d 45 14             	lea    0x14(%ebp),%eax
f0104d09:	e8 5b fc ff ff       	call   f0104969 <getuint>
f0104d0e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104d11:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
f0104d14:	6a 04                	push   $0x4
f0104d16:	6a 03                	push   $0x3
f0104d18:	6a 01                	push   $0x1
f0104d1a:	68 9b 75 10 f0       	push   $0xf010759b
f0104d1f:	e8 64 e9 ff ff       	call   f0103688 <cprintf>
			goto number;
f0104d24:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
f0104d27:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
f0104d2c:	eb 43                	jmp    f0104d71 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
f0104d2e:	83 ec 08             	sub    $0x8,%esp
f0104d31:	53                   	push   %ebx
f0104d32:	6a 30                	push   $0x30
f0104d34:	ff d6                	call   *%esi
			putch('x', putdat);
f0104d36:	83 c4 08             	add    $0x8,%esp
f0104d39:	53                   	push   %ebx
f0104d3a:	6a 78                	push   $0x78
f0104d3c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104d3e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d41:	8d 50 04             	lea    0x4(%eax),%edx
f0104d44:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104d47:	8b 00                	mov    (%eax),%eax
f0104d49:	ba 00 00 00 00       	mov    $0x0,%edx
f0104d4e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104d51:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104d54:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104d57:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0104d5c:	eb 13                	jmp    f0104d71 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104d5e:	8d 45 14             	lea    0x14(%ebp),%eax
f0104d61:	e8 03 fc ff ff       	call   f0104969 <getuint>
f0104d66:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104d69:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
f0104d6c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104d71:	83 ec 0c             	sub    $0xc,%esp
f0104d74:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
f0104d78:	52                   	push   %edx
f0104d79:	ff 75 e0             	pushl  -0x20(%ebp)
f0104d7c:	50                   	push   %eax
f0104d7d:	ff 75 dc             	pushl  -0x24(%ebp)
f0104d80:	ff 75 d8             	pushl  -0x28(%ebp)
f0104d83:	89 da                	mov    %ebx,%edx
f0104d85:	89 f0                	mov    %esi,%eax
f0104d87:	e8 2e fb ff ff       	call   f01048ba <printnum>

			break;
f0104d8c:	83 c4 20             	add    $0x20,%esp
f0104d8f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d92:	e9 6c fc ff ff       	jmp    f0104a03 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104d97:	83 ec 08             	sub    $0x8,%esp
f0104d9a:	53                   	push   %ebx
f0104d9b:	51                   	push   %ecx
f0104d9c:	ff d6                	call   *%esi
			break;
f0104d9e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104da1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0104da4:	e9 5a fc ff ff       	jmp    f0104a03 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104da9:	83 ec 08             	sub    $0x8,%esp
f0104dac:	53                   	push   %ebx
f0104dad:	6a 25                	push   $0x25
f0104daf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104db1:	83 c4 10             	add    $0x10,%esp
f0104db4:	eb 03                	jmp    f0104db9 <vprintfmt+0x3dc>
f0104db6:	83 ef 01             	sub    $0x1,%edi
f0104db9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0104dbd:	75 f7                	jne    f0104db6 <vprintfmt+0x3d9>
f0104dbf:	e9 3f fc ff ff       	jmp    f0104a03 <vprintfmt+0x26>
			break;
		}

	}

}
f0104dc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104dc7:	5b                   	pop    %ebx
f0104dc8:	5e                   	pop    %esi
f0104dc9:	5f                   	pop    %edi
f0104dca:	5d                   	pop    %ebp
f0104dcb:	c3                   	ret    

f0104dcc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104dcc:	55                   	push   %ebp
f0104dcd:	89 e5                	mov    %esp,%ebp
f0104dcf:	83 ec 18             	sub    $0x18,%esp
f0104dd2:	8b 45 08             	mov    0x8(%ebp),%eax
f0104dd5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104dd8:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104ddb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104ddf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104de2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104de9:	85 c0                	test   %eax,%eax
f0104deb:	74 26                	je     f0104e13 <vsnprintf+0x47>
f0104ded:	85 d2                	test   %edx,%edx
f0104def:	7e 22                	jle    f0104e13 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104df1:	ff 75 14             	pushl  0x14(%ebp)
f0104df4:	ff 75 10             	pushl  0x10(%ebp)
f0104df7:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104dfa:	50                   	push   %eax
f0104dfb:	68 a3 49 10 f0       	push   $0xf01049a3
f0104e00:	e8 d8 fb ff ff       	call   f01049dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104e05:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104e08:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104e0e:	83 c4 10             	add    $0x10,%esp
f0104e11:	eb 05                	jmp    f0104e18 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104e13:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104e18:	c9                   	leave  
f0104e19:	c3                   	ret    

f0104e1a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104e1a:	55                   	push   %ebp
f0104e1b:	89 e5                	mov    %esp,%ebp
f0104e1d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104e20:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104e23:	50                   	push   %eax
f0104e24:	ff 75 10             	pushl  0x10(%ebp)
f0104e27:	ff 75 0c             	pushl  0xc(%ebp)
f0104e2a:	ff 75 08             	pushl  0x8(%ebp)
f0104e2d:	e8 9a ff ff ff       	call   f0104dcc <vsnprintf>
	va_end(ap);

	return rc;
}
f0104e32:	c9                   	leave  
f0104e33:	c3                   	ret    

f0104e34 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104e34:	55                   	push   %ebp
f0104e35:	89 e5                	mov    %esp,%ebp
f0104e37:	57                   	push   %edi
f0104e38:	56                   	push   %esi
f0104e39:	53                   	push   %ebx
f0104e3a:	83 ec 0c             	sub    $0xc,%esp
f0104e3d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104e40:	85 c0                	test   %eax,%eax
f0104e42:	74 11                	je     f0104e55 <readline+0x21>
		cprintf("%s", prompt);
f0104e44:	83 ec 08             	sub    $0x8,%esp
f0104e47:	50                   	push   %eax
f0104e48:	68 48 63 10 f0       	push   $0xf0106348
f0104e4d:	e8 36 e8 ff ff       	call   f0103688 <cprintf>
f0104e52:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104e55:	83 ec 0c             	sub    $0xc,%esp
f0104e58:	6a 00                	push   $0x0
f0104e5a:	e8 18 b9 ff ff       	call   f0100777 <iscons>
f0104e5f:	89 c7                	mov    %eax,%edi
f0104e61:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0104e64:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104e69:	e8 f8 b8 ff ff       	call   f0100766 <getchar>
f0104e6e:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104e70:	85 c0                	test   %eax,%eax
f0104e72:	79 18                	jns    f0104e8c <readline+0x58>
			cprintf("read error: %e\n", c);
f0104e74:	83 ec 08             	sub    $0x8,%esp
f0104e77:	50                   	push   %eax
f0104e78:	68 c8 77 10 f0       	push   $0xf01077c8
f0104e7d:	e8 06 e8 ff ff       	call   f0103688 <cprintf>
			return NULL;
f0104e82:	83 c4 10             	add    $0x10,%esp
f0104e85:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e8a:	eb 79                	jmp    f0104f05 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104e8c:	83 f8 08             	cmp    $0x8,%eax
f0104e8f:	0f 94 c2             	sete   %dl
f0104e92:	83 f8 7f             	cmp    $0x7f,%eax
f0104e95:	0f 94 c0             	sete   %al
f0104e98:	08 c2                	or     %al,%dl
f0104e9a:	74 1a                	je     f0104eb6 <readline+0x82>
f0104e9c:	85 f6                	test   %esi,%esi
f0104e9e:	7e 16                	jle    f0104eb6 <readline+0x82>
			if (echoing)
f0104ea0:	85 ff                	test   %edi,%edi
f0104ea2:	74 0d                	je     f0104eb1 <readline+0x7d>
				cputchar('\b');
f0104ea4:	83 ec 0c             	sub    $0xc,%esp
f0104ea7:	6a 08                	push   $0x8
f0104ea9:	e8 a8 b8 ff ff       	call   f0100756 <cputchar>
f0104eae:	83 c4 10             	add    $0x10,%esp
			i--;
f0104eb1:	83 ee 01             	sub    $0x1,%esi
f0104eb4:	eb b3                	jmp    f0104e69 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104eb6:	83 fb 1f             	cmp    $0x1f,%ebx
f0104eb9:	7e 23                	jle    f0104ede <readline+0xaa>
f0104ebb:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104ec1:	7f 1b                	jg     f0104ede <readline+0xaa>
			if (echoing)
f0104ec3:	85 ff                	test   %edi,%edi
f0104ec5:	74 0c                	je     f0104ed3 <readline+0x9f>
				cputchar(c);
f0104ec7:	83 ec 0c             	sub    $0xc,%esp
f0104eca:	53                   	push   %ebx
f0104ecb:	e8 86 b8 ff ff       	call   f0100756 <cputchar>
f0104ed0:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0104ed3:	88 9e 00 ab 22 f0    	mov    %bl,-0xfdd5500(%esi)
f0104ed9:	8d 76 01             	lea    0x1(%esi),%esi
f0104edc:	eb 8b                	jmp    f0104e69 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0104ede:	83 fb 0a             	cmp    $0xa,%ebx
f0104ee1:	74 05                	je     f0104ee8 <readline+0xb4>
f0104ee3:	83 fb 0d             	cmp    $0xd,%ebx
f0104ee6:	75 81                	jne    f0104e69 <readline+0x35>
			if (echoing)
f0104ee8:	85 ff                	test   %edi,%edi
f0104eea:	74 0d                	je     f0104ef9 <readline+0xc5>
				cputchar('\n');
f0104eec:	83 ec 0c             	sub    $0xc,%esp
f0104eef:	6a 0a                	push   $0xa
f0104ef1:	e8 60 b8 ff ff       	call   f0100756 <cputchar>
f0104ef6:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0104ef9:	c6 86 00 ab 22 f0 00 	movb   $0x0,-0xfdd5500(%esi)
			return buf;
f0104f00:	b8 00 ab 22 f0       	mov    $0xf022ab00,%eax
		}
	}
}
f0104f05:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f08:	5b                   	pop    %ebx
f0104f09:	5e                   	pop    %esi
f0104f0a:	5f                   	pop    %edi
f0104f0b:	5d                   	pop    %ebp
f0104f0c:	c3                   	ret    

f0104f0d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104f0d:	55                   	push   %ebp
f0104f0e:	89 e5                	mov    %esp,%ebp
f0104f10:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104f13:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f18:	eb 03                	jmp    f0104f1d <strlen+0x10>
		n++;
f0104f1a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104f1d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104f21:	75 f7                	jne    f0104f1a <strlen+0xd>
		n++;
	return n;
}
f0104f23:	5d                   	pop    %ebp
f0104f24:	c3                   	ret    

f0104f25 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104f25:	55                   	push   %ebp
f0104f26:	89 e5                	mov    %esp,%ebp
f0104f28:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104f2b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104f2e:	ba 00 00 00 00       	mov    $0x0,%edx
f0104f33:	eb 03                	jmp    f0104f38 <strnlen+0x13>
		n++;
f0104f35:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104f38:	39 c2                	cmp    %eax,%edx
f0104f3a:	74 08                	je     f0104f44 <strnlen+0x1f>
f0104f3c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0104f40:	75 f3                	jne    f0104f35 <strnlen+0x10>
f0104f42:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0104f44:	5d                   	pop    %ebp
f0104f45:	c3                   	ret    

f0104f46 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104f46:	55                   	push   %ebp
f0104f47:	89 e5                	mov    %esp,%ebp
f0104f49:	53                   	push   %ebx
f0104f4a:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104f50:	89 c2                	mov    %eax,%edx
f0104f52:	83 c2 01             	add    $0x1,%edx
f0104f55:	83 c1 01             	add    $0x1,%ecx
f0104f58:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0104f5c:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104f5f:	84 db                	test   %bl,%bl
f0104f61:	75 ef                	jne    f0104f52 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104f63:	5b                   	pop    %ebx
f0104f64:	5d                   	pop    %ebp
f0104f65:	c3                   	ret    

f0104f66 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104f66:	55                   	push   %ebp
f0104f67:	89 e5                	mov    %esp,%ebp
f0104f69:	53                   	push   %ebx
f0104f6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104f6d:	53                   	push   %ebx
f0104f6e:	e8 9a ff ff ff       	call   f0104f0d <strlen>
f0104f73:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0104f76:	ff 75 0c             	pushl  0xc(%ebp)
f0104f79:	01 d8                	add    %ebx,%eax
f0104f7b:	50                   	push   %eax
f0104f7c:	e8 c5 ff ff ff       	call   f0104f46 <strcpy>
	return dst;
}
f0104f81:	89 d8                	mov    %ebx,%eax
f0104f83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104f86:	c9                   	leave  
f0104f87:	c3                   	ret    

f0104f88 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104f88:	55                   	push   %ebp
f0104f89:	89 e5                	mov    %esp,%ebp
f0104f8b:	56                   	push   %esi
f0104f8c:	53                   	push   %ebx
f0104f8d:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104f93:	89 f3                	mov    %esi,%ebx
f0104f95:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104f98:	89 f2                	mov    %esi,%edx
f0104f9a:	eb 0f                	jmp    f0104fab <strncpy+0x23>
		*dst++ = *src;
f0104f9c:	83 c2 01             	add    $0x1,%edx
f0104f9f:	0f b6 01             	movzbl (%ecx),%eax
f0104fa2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104fa5:	80 39 01             	cmpb   $0x1,(%ecx)
f0104fa8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104fab:	39 da                	cmp    %ebx,%edx
f0104fad:	75 ed                	jne    f0104f9c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104faf:	89 f0                	mov    %esi,%eax
f0104fb1:	5b                   	pop    %ebx
f0104fb2:	5e                   	pop    %esi
f0104fb3:	5d                   	pop    %ebp
f0104fb4:	c3                   	ret    

f0104fb5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104fb5:	55                   	push   %ebp
f0104fb6:	89 e5                	mov    %esp,%ebp
f0104fb8:	56                   	push   %esi
f0104fb9:	53                   	push   %ebx
f0104fba:	8b 75 08             	mov    0x8(%ebp),%esi
f0104fbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104fc0:	8b 55 10             	mov    0x10(%ebp),%edx
f0104fc3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104fc5:	85 d2                	test   %edx,%edx
f0104fc7:	74 21                	je     f0104fea <strlcpy+0x35>
f0104fc9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0104fcd:	89 f2                	mov    %esi,%edx
f0104fcf:	eb 09                	jmp    f0104fda <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104fd1:	83 c2 01             	add    $0x1,%edx
f0104fd4:	83 c1 01             	add    $0x1,%ecx
f0104fd7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104fda:	39 c2                	cmp    %eax,%edx
f0104fdc:	74 09                	je     f0104fe7 <strlcpy+0x32>
f0104fde:	0f b6 19             	movzbl (%ecx),%ebx
f0104fe1:	84 db                	test   %bl,%bl
f0104fe3:	75 ec                	jne    f0104fd1 <strlcpy+0x1c>
f0104fe5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0104fe7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104fea:	29 f0                	sub    %esi,%eax
}
f0104fec:	5b                   	pop    %ebx
f0104fed:	5e                   	pop    %esi
f0104fee:	5d                   	pop    %ebp
f0104fef:	c3                   	ret    

f0104ff0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104ff0:	55                   	push   %ebp
f0104ff1:	89 e5                	mov    %esp,%ebp
f0104ff3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104ff6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104ff9:	eb 06                	jmp    f0105001 <strcmp+0x11>
		p++, q++;
f0104ffb:	83 c1 01             	add    $0x1,%ecx
f0104ffe:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105001:	0f b6 01             	movzbl (%ecx),%eax
f0105004:	84 c0                	test   %al,%al
f0105006:	74 04                	je     f010500c <strcmp+0x1c>
f0105008:	3a 02                	cmp    (%edx),%al
f010500a:	74 ef                	je     f0104ffb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010500c:	0f b6 c0             	movzbl %al,%eax
f010500f:	0f b6 12             	movzbl (%edx),%edx
f0105012:	29 d0                	sub    %edx,%eax
}
f0105014:	5d                   	pop    %ebp
f0105015:	c3                   	ret    

f0105016 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105016:	55                   	push   %ebp
f0105017:	89 e5                	mov    %esp,%ebp
f0105019:	53                   	push   %ebx
f010501a:	8b 45 08             	mov    0x8(%ebp),%eax
f010501d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105020:	89 c3                	mov    %eax,%ebx
f0105022:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105025:	eb 06                	jmp    f010502d <strncmp+0x17>
		n--, p++, q++;
f0105027:	83 c0 01             	add    $0x1,%eax
f010502a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010502d:	39 d8                	cmp    %ebx,%eax
f010502f:	74 15                	je     f0105046 <strncmp+0x30>
f0105031:	0f b6 08             	movzbl (%eax),%ecx
f0105034:	84 c9                	test   %cl,%cl
f0105036:	74 04                	je     f010503c <strncmp+0x26>
f0105038:	3a 0a                	cmp    (%edx),%cl
f010503a:	74 eb                	je     f0105027 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010503c:	0f b6 00             	movzbl (%eax),%eax
f010503f:	0f b6 12             	movzbl (%edx),%edx
f0105042:	29 d0                	sub    %edx,%eax
f0105044:	eb 05                	jmp    f010504b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105046:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010504b:	5b                   	pop    %ebx
f010504c:	5d                   	pop    %ebp
f010504d:	c3                   	ret    

f010504e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010504e:	55                   	push   %ebp
f010504f:	89 e5                	mov    %esp,%ebp
f0105051:	8b 45 08             	mov    0x8(%ebp),%eax
f0105054:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105058:	eb 07                	jmp    f0105061 <strchr+0x13>
		if (*s == c)
f010505a:	38 ca                	cmp    %cl,%dl
f010505c:	74 0f                	je     f010506d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010505e:	83 c0 01             	add    $0x1,%eax
f0105061:	0f b6 10             	movzbl (%eax),%edx
f0105064:	84 d2                	test   %dl,%dl
f0105066:	75 f2                	jne    f010505a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105068:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010506d:	5d                   	pop    %ebp
f010506e:	c3                   	ret    

f010506f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010506f:	55                   	push   %ebp
f0105070:	89 e5                	mov    %esp,%ebp
f0105072:	8b 45 08             	mov    0x8(%ebp),%eax
f0105075:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105079:	eb 03                	jmp    f010507e <strfind+0xf>
f010507b:	83 c0 01             	add    $0x1,%eax
f010507e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105081:	38 ca                	cmp    %cl,%dl
f0105083:	74 04                	je     f0105089 <strfind+0x1a>
f0105085:	84 d2                	test   %dl,%dl
f0105087:	75 f2                	jne    f010507b <strfind+0xc>
			break;
	return (char *) s;
}
f0105089:	5d                   	pop    %ebp
f010508a:	c3                   	ret    

f010508b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010508b:	55                   	push   %ebp
f010508c:	89 e5                	mov    %esp,%ebp
f010508e:	57                   	push   %edi
f010508f:	56                   	push   %esi
f0105090:	53                   	push   %ebx
f0105091:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105094:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105097:	85 c9                	test   %ecx,%ecx
f0105099:	74 36                	je     f01050d1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010509b:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01050a1:	75 28                	jne    f01050cb <memset+0x40>
f01050a3:	f6 c1 03             	test   $0x3,%cl
f01050a6:	75 23                	jne    f01050cb <memset+0x40>
		c &= 0xFF;
f01050a8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01050ac:	89 d3                	mov    %edx,%ebx
f01050ae:	c1 e3 08             	shl    $0x8,%ebx
f01050b1:	89 d6                	mov    %edx,%esi
f01050b3:	c1 e6 18             	shl    $0x18,%esi
f01050b6:	89 d0                	mov    %edx,%eax
f01050b8:	c1 e0 10             	shl    $0x10,%eax
f01050bb:	09 f0                	or     %esi,%eax
f01050bd:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01050bf:	89 d8                	mov    %ebx,%eax
f01050c1:	09 d0                	or     %edx,%eax
f01050c3:	c1 e9 02             	shr    $0x2,%ecx
f01050c6:	fc                   	cld    
f01050c7:	f3 ab                	rep stos %eax,%es:(%edi)
f01050c9:	eb 06                	jmp    f01050d1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01050cb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01050ce:	fc                   	cld    
f01050cf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01050d1:	89 f8                	mov    %edi,%eax
f01050d3:	5b                   	pop    %ebx
f01050d4:	5e                   	pop    %esi
f01050d5:	5f                   	pop    %edi
f01050d6:	5d                   	pop    %ebp
f01050d7:	c3                   	ret    

f01050d8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01050d8:	55                   	push   %ebp
f01050d9:	89 e5                	mov    %esp,%ebp
f01050db:	57                   	push   %edi
f01050dc:	56                   	push   %esi
f01050dd:	8b 45 08             	mov    0x8(%ebp),%eax
f01050e0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01050e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01050e6:	39 c6                	cmp    %eax,%esi
f01050e8:	73 35                	jae    f010511f <memmove+0x47>
f01050ea:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01050ed:	39 d0                	cmp    %edx,%eax
f01050ef:	73 2e                	jae    f010511f <memmove+0x47>
		s += n;
		d += n;
f01050f1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01050f4:	89 d6                	mov    %edx,%esi
f01050f6:	09 fe                	or     %edi,%esi
f01050f8:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01050fe:	75 13                	jne    f0105113 <memmove+0x3b>
f0105100:	f6 c1 03             	test   $0x3,%cl
f0105103:	75 0e                	jne    f0105113 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105105:	83 ef 04             	sub    $0x4,%edi
f0105108:	8d 72 fc             	lea    -0x4(%edx),%esi
f010510b:	c1 e9 02             	shr    $0x2,%ecx
f010510e:	fd                   	std    
f010510f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105111:	eb 09                	jmp    f010511c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105113:	83 ef 01             	sub    $0x1,%edi
f0105116:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105119:	fd                   	std    
f010511a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010511c:	fc                   	cld    
f010511d:	eb 1d                	jmp    f010513c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010511f:	89 f2                	mov    %esi,%edx
f0105121:	09 c2                	or     %eax,%edx
f0105123:	f6 c2 03             	test   $0x3,%dl
f0105126:	75 0f                	jne    f0105137 <memmove+0x5f>
f0105128:	f6 c1 03             	test   $0x3,%cl
f010512b:	75 0a                	jne    f0105137 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010512d:	c1 e9 02             	shr    $0x2,%ecx
f0105130:	89 c7                	mov    %eax,%edi
f0105132:	fc                   	cld    
f0105133:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105135:	eb 05                	jmp    f010513c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105137:	89 c7                	mov    %eax,%edi
f0105139:	fc                   	cld    
f010513a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010513c:	5e                   	pop    %esi
f010513d:	5f                   	pop    %edi
f010513e:	5d                   	pop    %ebp
f010513f:	c3                   	ret    

f0105140 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105140:	55                   	push   %ebp
f0105141:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105143:	ff 75 10             	pushl  0x10(%ebp)
f0105146:	ff 75 0c             	pushl  0xc(%ebp)
f0105149:	ff 75 08             	pushl  0x8(%ebp)
f010514c:	e8 87 ff ff ff       	call   f01050d8 <memmove>
}
f0105151:	c9                   	leave  
f0105152:	c3                   	ret    

f0105153 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105153:	55                   	push   %ebp
f0105154:	89 e5                	mov    %esp,%ebp
f0105156:	56                   	push   %esi
f0105157:	53                   	push   %ebx
f0105158:	8b 45 08             	mov    0x8(%ebp),%eax
f010515b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010515e:	89 c6                	mov    %eax,%esi
f0105160:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105163:	eb 1a                	jmp    f010517f <memcmp+0x2c>
		if (*s1 != *s2)
f0105165:	0f b6 08             	movzbl (%eax),%ecx
f0105168:	0f b6 1a             	movzbl (%edx),%ebx
f010516b:	38 d9                	cmp    %bl,%cl
f010516d:	74 0a                	je     f0105179 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010516f:	0f b6 c1             	movzbl %cl,%eax
f0105172:	0f b6 db             	movzbl %bl,%ebx
f0105175:	29 d8                	sub    %ebx,%eax
f0105177:	eb 0f                	jmp    f0105188 <memcmp+0x35>
		s1++, s2++;
f0105179:	83 c0 01             	add    $0x1,%eax
f010517c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010517f:	39 f0                	cmp    %esi,%eax
f0105181:	75 e2                	jne    f0105165 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105183:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105188:	5b                   	pop    %ebx
f0105189:	5e                   	pop    %esi
f010518a:	5d                   	pop    %ebp
f010518b:	c3                   	ret    

f010518c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010518c:	55                   	push   %ebp
f010518d:	89 e5                	mov    %esp,%ebp
f010518f:	53                   	push   %ebx
f0105190:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0105193:	89 c1                	mov    %eax,%ecx
f0105195:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0105198:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010519c:	eb 0a                	jmp    f01051a8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010519e:	0f b6 10             	movzbl (%eax),%edx
f01051a1:	39 da                	cmp    %ebx,%edx
f01051a3:	74 07                	je     f01051ac <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01051a5:	83 c0 01             	add    $0x1,%eax
f01051a8:	39 c8                	cmp    %ecx,%eax
f01051aa:	72 f2                	jb     f010519e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01051ac:	5b                   	pop    %ebx
f01051ad:	5d                   	pop    %ebp
f01051ae:	c3                   	ret    

f01051af <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01051af:	55                   	push   %ebp
f01051b0:	89 e5                	mov    %esp,%ebp
f01051b2:	57                   	push   %edi
f01051b3:	56                   	push   %esi
f01051b4:	53                   	push   %ebx
f01051b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01051b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01051bb:	eb 03                	jmp    f01051c0 <strtol+0x11>
		s++;
f01051bd:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01051c0:	0f b6 01             	movzbl (%ecx),%eax
f01051c3:	3c 20                	cmp    $0x20,%al
f01051c5:	74 f6                	je     f01051bd <strtol+0xe>
f01051c7:	3c 09                	cmp    $0x9,%al
f01051c9:	74 f2                	je     f01051bd <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01051cb:	3c 2b                	cmp    $0x2b,%al
f01051cd:	75 0a                	jne    f01051d9 <strtol+0x2a>
		s++;
f01051cf:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01051d2:	bf 00 00 00 00       	mov    $0x0,%edi
f01051d7:	eb 11                	jmp    f01051ea <strtol+0x3b>
f01051d9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01051de:	3c 2d                	cmp    $0x2d,%al
f01051e0:	75 08                	jne    f01051ea <strtol+0x3b>
		s++, neg = 1;
f01051e2:	83 c1 01             	add    $0x1,%ecx
f01051e5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01051ea:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01051f0:	75 15                	jne    f0105207 <strtol+0x58>
f01051f2:	80 39 30             	cmpb   $0x30,(%ecx)
f01051f5:	75 10                	jne    f0105207 <strtol+0x58>
f01051f7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01051fb:	75 7c                	jne    f0105279 <strtol+0xca>
		s += 2, base = 16;
f01051fd:	83 c1 02             	add    $0x2,%ecx
f0105200:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105205:	eb 16                	jmp    f010521d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105207:	85 db                	test   %ebx,%ebx
f0105209:	75 12                	jne    f010521d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010520b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105210:	80 39 30             	cmpb   $0x30,(%ecx)
f0105213:	75 08                	jne    f010521d <strtol+0x6e>
		s++, base = 8;
f0105215:	83 c1 01             	add    $0x1,%ecx
f0105218:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010521d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105222:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105225:	0f b6 11             	movzbl (%ecx),%edx
f0105228:	8d 72 d0             	lea    -0x30(%edx),%esi
f010522b:	89 f3                	mov    %esi,%ebx
f010522d:	80 fb 09             	cmp    $0x9,%bl
f0105230:	77 08                	ja     f010523a <strtol+0x8b>
			dig = *s - '0';
f0105232:	0f be d2             	movsbl %dl,%edx
f0105235:	83 ea 30             	sub    $0x30,%edx
f0105238:	eb 22                	jmp    f010525c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f010523a:	8d 72 9f             	lea    -0x61(%edx),%esi
f010523d:	89 f3                	mov    %esi,%ebx
f010523f:	80 fb 19             	cmp    $0x19,%bl
f0105242:	77 08                	ja     f010524c <strtol+0x9d>
			dig = *s - 'a' + 10;
f0105244:	0f be d2             	movsbl %dl,%edx
f0105247:	83 ea 57             	sub    $0x57,%edx
f010524a:	eb 10                	jmp    f010525c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010524c:	8d 72 bf             	lea    -0x41(%edx),%esi
f010524f:	89 f3                	mov    %esi,%ebx
f0105251:	80 fb 19             	cmp    $0x19,%bl
f0105254:	77 16                	ja     f010526c <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105256:	0f be d2             	movsbl %dl,%edx
f0105259:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010525c:	3b 55 10             	cmp    0x10(%ebp),%edx
f010525f:	7d 0b                	jge    f010526c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0105261:	83 c1 01             	add    $0x1,%ecx
f0105264:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105268:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f010526a:	eb b9                	jmp    f0105225 <strtol+0x76>

	if (endptr)
f010526c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105270:	74 0d                	je     f010527f <strtol+0xd0>
		*endptr = (char *) s;
f0105272:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105275:	89 0e                	mov    %ecx,(%esi)
f0105277:	eb 06                	jmp    f010527f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105279:	85 db                	test   %ebx,%ebx
f010527b:	74 98                	je     f0105215 <strtol+0x66>
f010527d:	eb 9e                	jmp    f010521d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010527f:	89 c2                	mov    %eax,%edx
f0105281:	f7 da                	neg    %edx
f0105283:	85 ff                	test   %edi,%edi
f0105285:	0f 45 c2             	cmovne %edx,%eax
}
f0105288:	5b                   	pop    %ebx
f0105289:	5e                   	pop    %esi
f010528a:	5f                   	pop    %edi
f010528b:	5d                   	pop    %ebp
f010528c:	c3                   	ret    
f010528d:	66 90                	xchg   %ax,%ax
f010528f:	90                   	nop

f0105290 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105290:	fa                   	cli    

	xorw    %ax, %ax
f0105291:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105293:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105295:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105297:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105299:	0f 01 16             	lgdtl  (%esi)
f010529c:	74 70                	je     f010530e <mpsearch1+0x3>
	movl    %cr0, %eax
f010529e:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01052a1:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01052a5:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01052a8:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01052ae:	08 00                	or     %al,(%eax)

f01052b0 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01052b0:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01052b4:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01052b6:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01052b8:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01052ba:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01052be:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01052c0:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01052c2:	b8 00 d0 11 00       	mov    $0x11d000,%eax
	movl    %eax, %cr3
f01052c7:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01052ca:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01052cd:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01052d2:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01052d5:	8b 25 04 af 22 f0    	mov    0xf022af04,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01052db:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01052e0:	b8 b3 01 10 f0       	mov    $0xf01001b3,%eax
	call    *%eax
f01052e5:	ff d0                	call   *%eax

f01052e7 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01052e7:	eb fe                	jmp    f01052e7 <spin>
f01052e9:	8d 76 00             	lea    0x0(%esi),%esi

f01052ec <gdt>:
	...
f01052f4:	ff                   	(bad)  
f01052f5:	ff 00                	incl   (%eax)
f01052f7:	00 00                	add    %al,(%eax)
f01052f9:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105300:	00                   	.byte 0x0
f0105301:	92                   	xchg   %eax,%edx
f0105302:	cf                   	iret   
	...

f0105304 <gdtdesc>:
f0105304:	17                   	pop    %ss
f0105305:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010530a <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010530a:	90                   	nop

f010530b <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f010530b:	55                   	push   %ebp
f010530c:	89 e5                	mov    %esp,%ebp
f010530e:	57                   	push   %edi
f010530f:	56                   	push   %esi
f0105310:	53                   	push   %ebx
f0105311:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105314:	8b 0d 08 af 22 f0    	mov    0xf022af08,%ecx
f010531a:	89 c3                	mov    %eax,%ebx
f010531c:	c1 eb 0c             	shr    $0xc,%ebx
f010531f:	39 cb                	cmp    %ecx,%ebx
f0105321:	72 12                	jb     f0105335 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105323:	50                   	push   %eax
f0105324:	68 64 5d 10 f0       	push   $0xf0105d64
f0105329:	6a 57                	push   $0x57
f010532b:	68 65 79 10 f0       	push   $0xf0107965
f0105330:	e8 0b ad ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105335:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010533b:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010533d:	89 c2                	mov    %eax,%edx
f010533f:	c1 ea 0c             	shr    $0xc,%edx
f0105342:	39 ca                	cmp    %ecx,%edx
f0105344:	72 12                	jb     f0105358 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105346:	50                   	push   %eax
f0105347:	68 64 5d 10 f0       	push   $0xf0105d64
f010534c:	6a 57                	push   $0x57
f010534e:	68 65 79 10 f0       	push   $0xf0107965
f0105353:	e8 e8 ac ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105358:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f010535e:	eb 2f                	jmp    f010538f <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105360:	83 ec 04             	sub    $0x4,%esp
f0105363:	6a 04                	push   $0x4
f0105365:	68 75 79 10 f0       	push   $0xf0107975
f010536a:	53                   	push   %ebx
f010536b:	e8 e3 fd ff ff       	call   f0105153 <memcmp>
f0105370:	83 c4 10             	add    $0x10,%esp
f0105373:	85 c0                	test   %eax,%eax
f0105375:	75 15                	jne    f010538c <mpsearch1+0x81>
f0105377:	89 da                	mov    %ebx,%edx
f0105379:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f010537c:	0f b6 0a             	movzbl (%edx),%ecx
f010537f:	01 c8                	add    %ecx,%eax
f0105381:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105384:	39 d7                	cmp    %edx,%edi
f0105386:	75 f4                	jne    f010537c <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105388:	84 c0                	test   %al,%al
f010538a:	74 0e                	je     f010539a <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f010538c:	83 c3 10             	add    $0x10,%ebx
f010538f:	39 f3                	cmp    %esi,%ebx
f0105391:	72 cd                	jb     f0105360 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105393:	b8 00 00 00 00       	mov    $0x0,%eax
f0105398:	eb 02                	jmp    f010539c <mpsearch1+0x91>
f010539a:	89 d8                	mov    %ebx,%eax
}
f010539c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010539f:	5b                   	pop    %ebx
f01053a0:	5e                   	pop    %esi
f01053a1:	5f                   	pop    %edi
f01053a2:	5d                   	pop    %ebp
f01053a3:	c3                   	ret    

f01053a4 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01053a4:	55                   	push   %ebp
f01053a5:	89 e5                	mov    %esp,%ebp
f01053a7:	57                   	push   %edi
f01053a8:	56                   	push   %esi
f01053a9:	53                   	push   %ebx
f01053aa:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01053ad:	c7 05 c0 b3 22 f0 20 	movl   $0xf022b020,0xf022b3c0
f01053b4:	b0 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01053b7:	83 3d 08 af 22 f0 00 	cmpl   $0x0,0xf022af08
f01053be:	75 16                	jne    f01053d6 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01053c0:	68 00 04 00 00       	push   $0x400
f01053c5:	68 64 5d 10 f0       	push   $0xf0105d64
f01053ca:	6a 6f                	push   $0x6f
f01053cc:	68 65 79 10 f0       	push   $0xf0107965
f01053d1:	e8 6a ac ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01053d6:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01053dd:	85 c0                	test   %eax,%eax
f01053df:	74 16                	je     f01053f7 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f01053e1:	c1 e0 04             	shl    $0x4,%eax
f01053e4:	ba 00 04 00 00       	mov    $0x400,%edx
f01053e9:	e8 1d ff ff ff       	call   f010530b <mpsearch1>
f01053ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01053f1:	85 c0                	test   %eax,%eax
f01053f3:	75 3c                	jne    f0105431 <mp_init+0x8d>
f01053f5:	eb 20                	jmp    f0105417 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f01053f7:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01053fe:	c1 e0 0a             	shl    $0xa,%eax
f0105401:	2d 00 04 00 00       	sub    $0x400,%eax
f0105406:	ba 00 04 00 00       	mov    $0x400,%edx
f010540b:	e8 fb fe ff ff       	call   f010530b <mpsearch1>
f0105410:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105413:	85 c0                	test   %eax,%eax
f0105415:	75 1a                	jne    f0105431 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105417:	ba 00 00 01 00       	mov    $0x10000,%edx
f010541c:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105421:	e8 e5 fe ff ff       	call   f010530b <mpsearch1>
f0105426:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105429:	85 c0                	test   %eax,%eax
f010542b:	0f 84 5d 02 00 00    	je     f010568e <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105431:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105434:	8b 70 04             	mov    0x4(%eax),%esi
f0105437:	85 f6                	test   %esi,%esi
f0105439:	74 06                	je     f0105441 <mp_init+0x9d>
f010543b:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010543f:	74 15                	je     f0105456 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105441:	83 ec 0c             	sub    $0xc,%esp
f0105444:	68 d8 77 10 f0       	push   $0xf01077d8
f0105449:	e8 3a e2 ff ff       	call   f0103688 <cprintf>
f010544e:	83 c4 10             	add    $0x10,%esp
f0105451:	e9 38 02 00 00       	jmp    f010568e <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105456:	89 f0                	mov    %esi,%eax
f0105458:	c1 e8 0c             	shr    $0xc,%eax
f010545b:	3b 05 08 af 22 f0    	cmp    0xf022af08,%eax
f0105461:	72 15                	jb     f0105478 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105463:	56                   	push   %esi
f0105464:	68 64 5d 10 f0       	push   $0xf0105d64
f0105469:	68 90 00 00 00       	push   $0x90
f010546e:	68 65 79 10 f0       	push   $0xf0107965
f0105473:	e8 c8 ab ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105478:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f010547e:	83 ec 04             	sub    $0x4,%esp
f0105481:	6a 04                	push   $0x4
f0105483:	68 7a 79 10 f0       	push   $0xf010797a
f0105488:	53                   	push   %ebx
f0105489:	e8 c5 fc ff ff       	call   f0105153 <memcmp>
f010548e:	83 c4 10             	add    $0x10,%esp
f0105491:	85 c0                	test   %eax,%eax
f0105493:	74 15                	je     f01054aa <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105495:	83 ec 0c             	sub    $0xc,%esp
f0105498:	68 08 78 10 f0       	push   $0xf0107808
f010549d:	e8 e6 e1 ff ff       	call   f0103688 <cprintf>
f01054a2:	83 c4 10             	add    $0x10,%esp
f01054a5:	e9 e4 01 00 00       	jmp    f010568e <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01054aa:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f01054ae:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f01054b2:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01054b5:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01054ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01054bf:	eb 0d                	jmp    f01054ce <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f01054c1:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f01054c8:	f0 
f01054c9:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01054cb:	83 c0 01             	add    $0x1,%eax
f01054ce:	39 c7                	cmp    %eax,%edi
f01054d0:	75 ef                	jne    f01054c1 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01054d2:	84 d2                	test   %dl,%dl
f01054d4:	74 15                	je     f01054eb <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f01054d6:	83 ec 0c             	sub    $0xc,%esp
f01054d9:	68 3c 78 10 f0       	push   $0xf010783c
f01054de:	e8 a5 e1 ff ff       	call   f0103688 <cprintf>
f01054e3:	83 c4 10             	add    $0x10,%esp
f01054e6:	e9 a3 01 00 00       	jmp    f010568e <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01054eb:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f01054ef:	3c 01                	cmp    $0x1,%al
f01054f1:	74 1d                	je     f0105510 <mp_init+0x16c>
f01054f3:	3c 04                	cmp    $0x4,%al
f01054f5:	74 19                	je     f0105510 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01054f7:	83 ec 08             	sub    $0x8,%esp
f01054fa:	0f b6 c0             	movzbl %al,%eax
f01054fd:	50                   	push   %eax
f01054fe:	68 60 78 10 f0       	push   $0xf0107860
f0105503:	e8 80 e1 ff ff       	call   f0103688 <cprintf>
f0105508:	83 c4 10             	add    $0x10,%esp
f010550b:	e9 7e 01 00 00       	jmp    f010568e <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105510:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105514:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105518:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f010551d:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105522:	01 ce                	add    %ecx,%esi
f0105524:	eb 0d                	jmp    f0105533 <mp_init+0x18f>
f0105526:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f010552d:	f0 
f010552e:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105530:	83 c0 01             	add    $0x1,%eax
f0105533:	39 c7                	cmp    %eax,%edi
f0105535:	75 ef                	jne    f0105526 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105537:	89 d0                	mov    %edx,%eax
f0105539:	02 43 2a             	add    0x2a(%ebx),%al
f010553c:	74 15                	je     f0105553 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f010553e:	83 ec 0c             	sub    $0xc,%esp
f0105541:	68 80 78 10 f0       	push   $0xf0107880
f0105546:	e8 3d e1 ff ff       	call   f0103688 <cprintf>
f010554b:	83 c4 10             	add    $0x10,%esp
f010554e:	e9 3b 01 00 00       	jmp    f010568e <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105553:	85 db                	test   %ebx,%ebx
f0105555:	0f 84 33 01 00 00    	je     f010568e <mp_init+0x2ea>
		return;
	ismp = 1;
f010555b:	c7 05 00 b0 22 f0 01 	movl   $0x1,0xf022b000
f0105562:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105565:	8b 43 24             	mov    0x24(%ebx),%eax
f0105568:	a3 00 c0 26 f0       	mov    %eax,0xf026c000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010556d:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105570:	be 00 00 00 00       	mov    $0x0,%esi
f0105575:	e9 85 00 00 00       	jmp    f01055ff <mp_init+0x25b>
		switch (*p) {
f010557a:	0f b6 07             	movzbl (%edi),%eax
f010557d:	84 c0                	test   %al,%al
f010557f:	74 06                	je     f0105587 <mp_init+0x1e3>
f0105581:	3c 04                	cmp    $0x4,%al
f0105583:	77 55                	ja     f01055da <mp_init+0x236>
f0105585:	eb 4e                	jmp    f01055d5 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105587:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f010558b:	74 11                	je     f010559e <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f010558d:	6b 05 c4 b3 22 f0 74 	imul   $0x74,0xf022b3c4,%eax
f0105594:	05 20 b0 22 f0       	add    $0xf022b020,%eax
f0105599:	a3 c0 b3 22 f0       	mov    %eax,0xf022b3c0
			if (ncpu < NCPU) {
f010559e:	a1 c4 b3 22 f0       	mov    0xf022b3c4,%eax
f01055a3:	83 f8 07             	cmp    $0x7,%eax
f01055a6:	7f 13                	jg     f01055bb <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f01055a8:	6b d0 74             	imul   $0x74,%eax,%edx
f01055ab:	88 82 20 b0 22 f0    	mov    %al,-0xfdd4fe0(%edx)
				ncpu++;
f01055b1:	83 c0 01             	add    $0x1,%eax
f01055b4:	a3 c4 b3 22 f0       	mov    %eax,0xf022b3c4
f01055b9:	eb 15                	jmp    f01055d0 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01055bb:	83 ec 08             	sub    $0x8,%esp
f01055be:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f01055c2:	50                   	push   %eax
f01055c3:	68 b0 78 10 f0       	push   $0xf01078b0
f01055c8:	e8 bb e0 ff ff       	call   f0103688 <cprintf>
f01055cd:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01055d0:	83 c7 14             	add    $0x14,%edi
			continue;
f01055d3:	eb 27                	jmp    f01055fc <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01055d5:	83 c7 08             	add    $0x8,%edi
			continue;
f01055d8:	eb 22                	jmp    f01055fc <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01055da:	83 ec 08             	sub    $0x8,%esp
f01055dd:	0f b6 c0             	movzbl %al,%eax
f01055e0:	50                   	push   %eax
f01055e1:	68 d8 78 10 f0       	push   $0xf01078d8
f01055e6:	e8 9d e0 ff ff       	call   f0103688 <cprintf>
			ismp = 0;
f01055eb:	c7 05 00 b0 22 f0 00 	movl   $0x0,0xf022b000
f01055f2:	00 00 00 
			i = conf->entry;
f01055f5:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f01055f9:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01055fc:	83 c6 01             	add    $0x1,%esi
f01055ff:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105603:	39 c6                	cmp    %eax,%esi
f0105605:	0f 82 6f ff ff ff    	jb     f010557a <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010560b:	a1 c0 b3 22 f0       	mov    0xf022b3c0,%eax
f0105610:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105617:	83 3d 00 b0 22 f0 00 	cmpl   $0x0,0xf022b000
f010561e:	75 26                	jne    f0105646 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105620:	c7 05 c4 b3 22 f0 01 	movl   $0x1,0xf022b3c4
f0105627:	00 00 00 
		lapicaddr = 0;
f010562a:	c7 05 00 c0 26 f0 00 	movl   $0x0,0xf026c000
f0105631:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105634:	83 ec 0c             	sub    $0xc,%esp
f0105637:	68 f8 78 10 f0       	push   $0xf01078f8
f010563c:	e8 47 e0 ff ff       	call   f0103688 <cprintf>
		return;
f0105641:	83 c4 10             	add    $0x10,%esp
f0105644:	eb 48                	jmp    f010568e <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105646:	83 ec 04             	sub    $0x4,%esp
f0105649:	ff 35 c4 b3 22 f0    	pushl  0xf022b3c4
f010564f:	0f b6 00             	movzbl (%eax),%eax
f0105652:	50                   	push   %eax
f0105653:	68 7f 79 10 f0       	push   $0xf010797f
f0105658:	e8 2b e0 ff ff       	call   f0103688 <cprintf>

	if (mp->imcrp) {
f010565d:	83 c4 10             	add    $0x10,%esp
f0105660:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105663:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105667:	74 25                	je     f010568e <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105669:	83 ec 0c             	sub    $0xc,%esp
f010566c:	68 24 79 10 f0       	push   $0xf0107924
f0105671:	e8 12 e0 ff ff       	call   f0103688 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105676:	ba 22 00 00 00       	mov    $0x22,%edx
f010567b:	b8 70 00 00 00       	mov    $0x70,%eax
f0105680:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105681:	ba 23 00 00 00       	mov    $0x23,%edx
f0105686:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105687:	83 c8 01             	or     $0x1,%eax
f010568a:	ee                   	out    %al,(%dx)
f010568b:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f010568e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105691:	5b                   	pop    %ebx
f0105692:	5e                   	pop    %esi
f0105693:	5f                   	pop    %edi
f0105694:	5d                   	pop    %ebp
f0105695:	c3                   	ret    

f0105696 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105696:	55                   	push   %ebp
f0105697:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105699:	8b 0d 04 c0 26 f0    	mov    0xf026c004,%ecx
f010569f:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01056a2:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01056a4:	a1 04 c0 26 f0       	mov    0xf026c004,%eax
f01056a9:	8b 40 20             	mov    0x20(%eax),%eax
}
f01056ac:	5d                   	pop    %ebp
f01056ad:	c3                   	ret    

f01056ae <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01056ae:	55                   	push   %ebp
f01056af:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01056b1:	a1 04 c0 26 f0       	mov    0xf026c004,%eax
f01056b6:	85 c0                	test   %eax,%eax
f01056b8:	74 08                	je     f01056c2 <cpunum+0x14>
		return lapic[ID] >> 24;
f01056ba:	8b 40 20             	mov    0x20(%eax),%eax
f01056bd:	c1 e8 18             	shr    $0x18,%eax
f01056c0:	eb 05                	jmp    f01056c7 <cpunum+0x19>
	return 0;
f01056c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01056c7:	5d                   	pop    %ebp
f01056c8:	c3                   	ret    

f01056c9 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f01056c9:	a1 00 c0 26 f0       	mov    0xf026c000,%eax
f01056ce:	85 c0                	test   %eax,%eax
f01056d0:	0f 84 21 01 00 00    	je     f01057f7 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01056d6:	55                   	push   %ebp
f01056d7:	89 e5                	mov    %esp,%ebp
f01056d9:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f01056dc:	68 00 10 00 00       	push   $0x1000
f01056e1:	50                   	push   %eax
f01056e2:	e8 3d bb ff ff       	call   f0101224 <mmio_map_region>
f01056e7:	a3 04 c0 26 f0       	mov    %eax,0xf026c004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01056ec:	ba 27 01 00 00       	mov    $0x127,%edx
f01056f1:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01056f6:	e8 9b ff ff ff       	call   f0105696 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01056fb:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105700:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105705:	e8 8c ff ff ff       	call   f0105696 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010570a:	ba 20 00 02 00       	mov    $0x20020,%edx
f010570f:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105714:	e8 7d ff ff ff       	call   f0105696 <lapicw>
	lapicw(TICR, 10000000); 
f0105719:	ba 80 96 98 00       	mov    $0x989680,%edx
f010571e:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105723:	e8 6e ff ff ff       	call   f0105696 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105728:	e8 81 ff ff ff       	call   f01056ae <cpunum>
f010572d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105730:	05 20 b0 22 f0       	add    $0xf022b020,%eax
f0105735:	83 c4 10             	add    $0x10,%esp
f0105738:	39 05 c0 b3 22 f0    	cmp    %eax,0xf022b3c0
f010573e:	74 0f                	je     f010574f <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105740:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105745:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010574a:	e8 47 ff ff ff       	call   f0105696 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f010574f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105754:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105759:	e8 38 ff ff ff       	call   f0105696 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010575e:	a1 04 c0 26 f0       	mov    0xf026c004,%eax
f0105763:	8b 40 30             	mov    0x30(%eax),%eax
f0105766:	c1 e8 10             	shr    $0x10,%eax
f0105769:	3c 03                	cmp    $0x3,%al
f010576b:	76 0f                	jbe    f010577c <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f010576d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105772:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105777:	e8 1a ff ff ff       	call   f0105696 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f010577c:	ba 33 00 00 00       	mov    $0x33,%edx
f0105781:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105786:	e8 0b ff ff ff       	call   f0105696 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f010578b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105790:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105795:	e8 fc fe ff ff       	call   f0105696 <lapicw>
	lapicw(ESR, 0);
f010579a:	ba 00 00 00 00       	mov    $0x0,%edx
f010579f:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01057a4:	e8 ed fe ff ff       	call   f0105696 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01057a9:	ba 00 00 00 00       	mov    $0x0,%edx
f01057ae:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01057b3:	e8 de fe ff ff       	call   f0105696 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01057b8:	ba 00 00 00 00       	mov    $0x0,%edx
f01057bd:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01057c2:	e8 cf fe ff ff       	call   f0105696 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01057c7:	ba 00 85 08 00       	mov    $0x88500,%edx
f01057cc:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01057d1:	e8 c0 fe ff ff       	call   f0105696 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01057d6:	8b 15 04 c0 26 f0    	mov    0xf026c004,%edx
f01057dc:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01057e2:	f6 c4 10             	test   $0x10,%ah
f01057e5:	75 f5                	jne    f01057dc <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01057e7:	ba 00 00 00 00       	mov    $0x0,%edx
f01057ec:	b8 20 00 00 00       	mov    $0x20,%eax
f01057f1:	e8 a0 fe ff ff       	call   f0105696 <lapicw>
}
f01057f6:	c9                   	leave  
f01057f7:	f3 c3                	repz ret 

f01057f9 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f01057f9:	83 3d 04 c0 26 f0 00 	cmpl   $0x0,0xf026c004
f0105800:	74 13                	je     f0105815 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105802:	55                   	push   %ebp
f0105803:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105805:	ba 00 00 00 00       	mov    $0x0,%edx
f010580a:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010580f:	e8 82 fe ff ff       	call   f0105696 <lapicw>
}
f0105814:	5d                   	pop    %ebp
f0105815:	f3 c3                	repz ret 

f0105817 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105817:	55                   	push   %ebp
f0105818:	89 e5                	mov    %esp,%ebp
f010581a:	56                   	push   %esi
f010581b:	53                   	push   %ebx
f010581c:	8b 75 08             	mov    0x8(%ebp),%esi
f010581f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105822:	ba 70 00 00 00       	mov    $0x70,%edx
f0105827:	b8 0f 00 00 00       	mov    $0xf,%eax
f010582c:	ee                   	out    %al,(%dx)
f010582d:	ba 71 00 00 00       	mov    $0x71,%edx
f0105832:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105837:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105838:	83 3d 08 af 22 f0 00 	cmpl   $0x0,0xf022af08
f010583f:	75 19                	jne    f010585a <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105841:	68 67 04 00 00       	push   $0x467
f0105846:	68 64 5d 10 f0       	push   $0xf0105d64
f010584b:	68 98 00 00 00       	push   $0x98
f0105850:	68 9c 79 10 f0       	push   $0xf010799c
f0105855:	e8 e6 a7 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f010585a:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105861:	00 00 
	wrv[1] = addr >> 4;
f0105863:	89 d8                	mov    %ebx,%eax
f0105865:	c1 e8 04             	shr    $0x4,%eax
f0105868:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f010586e:	c1 e6 18             	shl    $0x18,%esi
f0105871:	89 f2                	mov    %esi,%edx
f0105873:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105878:	e8 19 fe ff ff       	call   f0105696 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f010587d:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105882:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105887:	e8 0a fe ff ff       	call   f0105696 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f010588c:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105891:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105896:	e8 fb fd ff ff       	call   f0105696 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010589b:	c1 eb 0c             	shr    $0xc,%ebx
f010589e:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01058a1:	89 f2                	mov    %esi,%edx
f01058a3:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01058a8:	e8 e9 fd ff ff       	call   f0105696 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01058ad:	89 da                	mov    %ebx,%edx
f01058af:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01058b4:	e8 dd fd ff ff       	call   f0105696 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01058b9:	89 f2                	mov    %esi,%edx
f01058bb:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01058c0:	e8 d1 fd ff ff       	call   f0105696 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01058c5:	89 da                	mov    %ebx,%edx
f01058c7:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01058cc:	e8 c5 fd ff ff       	call   f0105696 <lapicw>
		microdelay(200);
	}
}
f01058d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01058d4:	5b                   	pop    %ebx
f01058d5:	5e                   	pop    %esi
f01058d6:	5d                   	pop    %ebp
f01058d7:	c3                   	ret    

f01058d8 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01058d8:	55                   	push   %ebp
f01058d9:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01058db:	8b 55 08             	mov    0x8(%ebp),%edx
f01058de:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01058e4:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01058e9:	e8 a8 fd ff ff       	call   f0105696 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01058ee:	8b 15 04 c0 26 f0    	mov    0xf026c004,%edx
f01058f4:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01058fa:	f6 c4 10             	test   $0x10,%ah
f01058fd:	75 f5                	jne    f01058f4 <lapic_ipi+0x1c>
		;
}
f01058ff:	5d                   	pop    %ebp
f0105900:	c3                   	ret    

f0105901 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105901:	55                   	push   %ebp
f0105902:	89 e5                	mov    %esp,%ebp
f0105904:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105907:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010590d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105910:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105913:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f010591a:	5d                   	pop    %ebp
f010591b:	c3                   	ret    

f010591c <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010591c:	55                   	push   %ebp
f010591d:	89 e5                	mov    %esp,%ebp
f010591f:	56                   	push   %esi
f0105920:	53                   	push   %ebx
f0105921:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105924:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105927:	74 14                	je     f010593d <spin_lock+0x21>
f0105929:	8b 73 08             	mov    0x8(%ebx),%esi
f010592c:	e8 7d fd ff ff       	call   f01056ae <cpunum>
f0105931:	6b c0 74             	imul   $0x74,%eax,%eax
f0105934:	05 20 b0 22 f0       	add    $0xf022b020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105939:	39 c6                	cmp    %eax,%esi
f010593b:	74 07                	je     f0105944 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010593d:	ba 01 00 00 00       	mov    $0x1,%edx
f0105942:	eb 20                	jmp    f0105964 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105944:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105947:	e8 62 fd ff ff       	call   f01056ae <cpunum>
f010594c:	83 ec 0c             	sub    $0xc,%esp
f010594f:	53                   	push   %ebx
f0105950:	50                   	push   %eax
f0105951:	68 ac 79 10 f0       	push   $0xf01079ac
f0105956:	6a 41                	push   $0x41
f0105958:	68 10 7a 10 f0       	push   $0xf0107a10
f010595d:	e8 de a6 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105962:	f3 90                	pause  
f0105964:	89 d0                	mov    %edx,%eax
f0105966:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105969:	85 c0                	test   %eax,%eax
f010596b:	75 f5                	jne    f0105962 <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010596d:	e8 3c fd ff ff       	call   f01056ae <cpunum>
f0105972:	6b c0 74             	imul   $0x74,%eax,%eax
f0105975:	05 20 b0 22 f0       	add    $0xf022b020,%eax
f010597a:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f010597d:	83 c3 0c             	add    $0xc,%ebx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0105980:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105982:	b8 00 00 00 00       	mov    $0x0,%eax
f0105987:	eb 0b                	jmp    f0105994 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105989:	8b 4a 04             	mov    0x4(%edx),%ecx
f010598c:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010598f:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105991:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105994:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f010599a:	76 11                	jbe    f01059ad <spin_lock+0x91>
f010599c:	83 f8 09             	cmp    $0x9,%eax
f010599f:	7e e8                	jle    f0105989 <spin_lock+0x6d>
f01059a1:	eb 0a                	jmp    f01059ad <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01059a3:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01059aa:	83 c0 01             	add    $0x1,%eax
f01059ad:	83 f8 09             	cmp    $0x9,%eax
f01059b0:	7e f1                	jle    f01059a3 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01059b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01059b5:	5b                   	pop    %ebx
f01059b6:	5e                   	pop    %esi
f01059b7:	5d                   	pop    %ebp
f01059b8:	c3                   	ret    

f01059b9 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01059b9:	55                   	push   %ebp
f01059ba:	89 e5                	mov    %esp,%ebp
f01059bc:	57                   	push   %edi
f01059bd:	56                   	push   %esi
f01059be:	53                   	push   %ebx
f01059bf:	83 ec 4c             	sub    $0x4c,%esp
f01059c2:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01059c5:	83 3e 00             	cmpl   $0x0,(%esi)
f01059c8:	74 18                	je     f01059e2 <spin_unlock+0x29>
f01059ca:	8b 5e 08             	mov    0x8(%esi),%ebx
f01059cd:	e8 dc fc ff ff       	call   f01056ae <cpunum>
f01059d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01059d5:	05 20 b0 22 f0       	add    $0xf022b020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01059da:	39 c3                	cmp    %eax,%ebx
f01059dc:	0f 84 a5 00 00 00    	je     f0105a87 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01059e2:	83 ec 04             	sub    $0x4,%esp
f01059e5:	6a 28                	push   $0x28
f01059e7:	8d 46 0c             	lea    0xc(%esi),%eax
f01059ea:	50                   	push   %eax
f01059eb:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01059ee:	53                   	push   %ebx
f01059ef:	e8 e4 f6 ff ff       	call   f01050d8 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01059f4:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01059f7:	0f b6 38             	movzbl (%eax),%edi
f01059fa:	8b 76 04             	mov    0x4(%esi),%esi
f01059fd:	e8 ac fc ff ff       	call   f01056ae <cpunum>
f0105a02:	57                   	push   %edi
f0105a03:	56                   	push   %esi
f0105a04:	50                   	push   %eax
f0105a05:	68 d8 79 10 f0       	push   $0xf01079d8
f0105a0a:	e8 79 dc ff ff       	call   f0103688 <cprintf>
f0105a0f:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105a12:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105a15:	eb 54                	jmp    f0105a6b <spin_unlock+0xb2>
f0105a17:	83 ec 08             	sub    $0x8,%esp
f0105a1a:	57                   	push   %edi
f0105a1b:	50                   	push   %eax
f0105a1c:	e8 c4 eb ff ff       	call   f01045e5 <debuginfo_eip>
f0105a21:	83 c4 10             	add    $0x10,%esp
f0105a24:	85 c0                	test   %eax,%eax
f0105a26:	78 27                	js     f0105a4f <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105a28:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105a2a:	83 ec 04             	sub    $0x4,%esp
f0105a2d:	89 c2                	mov    %eax,%edx
f0105a2f:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105a32:	52                   	push   %edx
f0105a33:	ff 75 b0             	pushl  -0x50(%ebp)
f0105a36:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105a39:	ff 75 ac             	pushl  -0x54(%ebp)
f0105a3c:	ff 75 a8             	pushl  -0x58(%ebp)
f0105a3f:	50                   	push   %eax
f0105a40:	68 20 7a 10 f0       	push   $0xf0107a20
f0105a45:	e8 3e dc ff ff       	call   f0103688 <cprintf>
f0105a4a:	83 c4 20             	add    $0x20,%esp
f0105a4d:	eb 12                	jmp    f0105a61 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105a4f:	83 ec 08             	sub    $0x8,%esp
f0105a52:	ff 36                	pushl  (%esi)
f0105a54:	68 37 7a 10 f0       	push   $0xf0107a37
f0105a59:	e8 2a dc ff ff       	call   f0103688 <cprintf>
f0105a5e:	83 c4 10             	add    $0x10,%esp
f0105a61:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105a64:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105a67:	39 c3                	cmp    %eax,%ebx
f0105a69:	74 08                	je     f0105a73 <spin_unlock+0xba>
f0105a6b:	89 de                	mov    %ebx,%esi
f0105a6d:	8b 03                	mov    (%ebx),%eax
f0105a6f:	85 c0                	test   %eax,%eax
f0105a71:	75 a4                	jne    f0105a17 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105a73:	83 ec 04             	sub    $0x4,%esp
f0105a76:	68 3f 7a 10 f0       	push   $0xf0107a3f
f0105a7b:	6a 67                	push   $0x67
f0105a7d:	68 10 7a 10 f0       	push   $0xf0107a10
f0105a82:	e8 b9 a5 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0105a87:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105a8e:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105a95:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a9a:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0105a9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105aa0:	5b                   	pop    %ebx
f0105aa1:	5e                   	pop    %esi
f0105aa2:	5f                   	pop    %edi
f0105aa3:	5d                   	pop    %ebp
f0105aa4:	c3                   	ret    
f0105aa5:	66 90                	xchg   %ax,%ax
f0105aa7:	66 90                	xchg   %ax,%ax
f0105aa9:	66 90                	xchg   %ax,%ax
f0105aab:	66 90                	xchg   %ax,%ax
f0105aad:	66 90                	xchg   %ax,%ax
f0105aaf:	90                   	nop

f0105ab0 <__udivdi3>:
f0105ab0:	55                   	push   %ebp
f0105ab1:	57                   	push   %edi
f0105ab2:	56                   	push   %esi
f0105ab3:	53                   	push   %ebx
f0105ab4:	83 ec 1c             	sub    $0x1c,%esp
f0105ab7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0105abb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0105abf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0105ac3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105ac7:	85 f6                	test   %esi,%esi
f0105ac9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105acd:	89 ca                	mov    %ecx,%edx
f0105acf:	89 f8                	mov    %edi,%eax
f0105ad1:	75 3d                	jne    f0105b10 <__udivdi3+0x60>
f0105ad3:	39 cf                	cmp    %ecx,%edi
f0105ad5:	0f 87 c5 00 00 00    	ja     f0105ba0 <__udivdi3+0xf0>
f0105adb:	85 ff                	test   %edi,%edi
f0105add:	89 fd                	mov    %edi,%ebp
f0105adf:	75 0b                	jne    f0105aec <__udivdi3+0x3c>
f0105ae1:	b8 01 00 00 00       	mov    $0x1,%eax
f0105ae6:	31 d2                	xor    %edx,%edx
f0105ae8:	f7 f7                	div    %edi
f0105aea:	89 c5                	mov    %eax,%ebp
f0105aec:	89 c8                	mov    %ecx,%eax
f0105aee:	31 d2                	xor    %edx,%edx
f0105af0:	f7 f5                	div    %ebp
f0105af2:	89 c1                	mov    %eax,%ecx
f0105af4:	89 d8                	mov    %ebx,%eax
f0105af6:	89 cf                	mov    %ecx,%edi
f0105af8:	f7 f5                	div    %ebp
f0105afa:	89 c3                	mov    %eax,%ebx
f0105afc:	89 d8                	mov    %ebx,%eax
f0105afe:	89 fa                	mov    %edi,%edx
f0105b00:	83 c4 1c             	add    $0x1c,%esp
f0105b03:	5b                   	pop    %ebx
f0105b04:	5e                   	pop    %esi
f0105b05:	5f                   	pop    %edi
f0105b06:	5d                   	pop    %ebp
f0105b07:	c3                   	ret    
f0105b08:	90                   	nop
f0105b09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105b10:	39 ce                	cmp    %ecx,%esi
f0105b12:	77 74                	ja     f0105b88 <__udivdi3+0xd8>
f0105b14:	0f bd fe             	bsr    %esi,%edi
f0105b17:	83 f7 1f             	xor    $0x1f,%edi
f0105b1a:	0f 84 98 00 00 00    	je     f0105bb8 <__udivdi3+0x108>
f0105b20:	bb 20 00 00 00       	mov    $0x20,%ebx
f0105b25:	89 f9                	mov    %edi,%ecx
f0105b27:	89 c5                	mov    %eax,%ebp
f0105b29:	29 fb                	sub    %edi,%ebx
f0105b2b:	d3 e6                	shl    %cl,%esi
f0105b2d:	89 d9                	mov    %ebx,%ecx
f0105b2f:	d3 ed                	shr    %cl,%ebp
f0105b31:	89 f9                	mov    %edi,%ecx
f0105b33:	d3 e0                	shl    %cl,%eax
f0105b35:	09 ee                	or     %ebp,%esi
f0105b37:	89 d9                	mov    %ebx,%ecx
f0105b39:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105b3d:	89 d5                	mov    %edx,%ebp
f0105b3f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105b43:	d3 ed                	shr    %cl,%ebp
f0105b45:	89 f9                	mov    %edi,%ecx
f0105b47:	d3 e2                	shl    %cl,%edx
f0105b49:	89 d9                	mov    %ebx,%ecx
f0105b4b:	d3 e8                	shr    %cl,%eax
f0105b4d:	09 c2                	or     %eax,%edx
f0105b4f:	89 d0                	mov    %edx,%eax
f0105b51:	89 ea                	mov    %ebp,%edx
f0105b53:	f7 f6                	div    %esi
f0105b55:	89 d5                	mov    %edx,%ebp
f0105b57:	89 c3                	mov    %eax,%ebx
f0105b59:	f7 64 24 0c          	mull   0xc(%esp)
f0105b5d:	39 d5                	cmp    %edx,%ebp
f0105b5f:	72 10                	jb     f0105b71 <__udivdi3+0xc1>
f0105b61:	8b 74 24 08          	mov    0x8(%esp),%esi
f0105b65:	89 f9                	mov    %edi,%ecx
f0105b67:	d3 e6                	shl    %cl,%esi
f0105b69:	39 c6                	cmp    %eax,%esi
f0105b6b:	73 07                	jae    f0105b74 <__udivdi3+0xc4>
f0105b6d:	39 d5                	cmp    %edx,%ebp
f0105b6f:	75 03                	jne    f0105b74 <__udivdi3+0xc4>
f0105b71:	83 eb 01             	sub    $0x1,%ebx
f0105b74:	31 ff                	xor    %edi,%edi
f0105b76:	89 d8                	mov    %ebx,%eax
f0105b78:	89 fa                	mov    %edi,%edx
f0105b7a:	83 c4 1c             	add    $0x1c,%esp
f0105b7d:	5b                   	pop    %ebx
f0105b7e:	5e                   	pop    %esi
f0105b7f:	5f                   	pop    %edi
f0105b80:	5d                   	pop    %ebp
f0105b81:	c3                   	ret    
f0105b82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105b88:	31 ff                	xor    %edi,%edi
f0105b8a:	31 db                	xor    %ebx,%ebx
f0105b8c:	89 d8                	mov    %ebx,%eax
f0105b8e:	89 fa                	mov    %edi,%edx
f0105b90:	83 c4 1c             	add    $0x1c,%esp
f0105b93:	5b                   	pop    %ebx
f0105b94:	5e                   	pop    %esi
f0105b95:	5f                   	pop    %edi
f0105b96:	5d                   	pop    %ebp
f0105b97:	c3                   	ret    
f0105b98:	90                   	nop
f0105b99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105ba0:	89 d8                	mov    %ebx,%eax
f0105ba2:	f7 f7                	div    %edi
f0105ba4:	31 ff                	xor    %edi,%edi
f0105ba6:	89 c3                	mov    %eax,%ebx
f0105ba8:	89 d8                	mov    %ebx,%eax
f0105baa:	89 fa                	mov    %edi,%edx
f0105bac:	83 c4 1c             	add    $0x1c,%esp
f0105baf:	5b                   	pop    %ebx
f0105bb0:	5e                   	pop    %esi
f0105bb1:	5f                   	pop    %edi
f0105bb2:	5d                   	pop    %ebp
f0105bb3:	c3                   	ret    
f0105bb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105bb8:	39 ce                	cmp    %ecx,%esi
f0105bba:	72 0c                	jb     f0105bc8 <__udivdi3+0x118>
f0105bbc:	31 db                	xor    %ebx,%ebx
f0105bbe:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0105bc2:	0f 87 34 ff ff ff    	ja     f0105afc <__udivdi3+0x4c>
f0105bc8:	bb 01 00 00 00       	mov    $0x1,%ebx
f0105bcd:	e9 2a ff ff ff       	jmp    f0105afc <__udivdi3+0x4c>
f0105bd2:	66 90                	xchg   %ax,%ax
f0105bd4:	66 90                	xchg   %ax,%ax
f0105bd6:	66 90                	xchg   %ax,%ax
f0105bd8:	66 90                	xchg   %ax,%ax
f0105bda:	66 90                	xchg   %ax,%ax
f0105bdc:	66 90                	xchg   %ax,%ax
f0105bde:	66 90                	xchg   %ax,%ax

f0105be0 <__umoddi3>:
f0105be0:	55                   	push   %ebp
f0105be1:	57                   	push   %edi
f0105be2:	56                   	push   %esi
f0105be3:	53                   	push   %ebx
f0105be4:	83 ec 1c             	sub    $0x1c,%esp
f0105be7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0105beb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0105bef:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105bf3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105bf7:	85 d2                	test   %edx,%edx
f0105bf9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105bfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105c01:	89 f3                	mov    %esi,%ebx
f0105c03:	89 3c 24             	mov    %edi,(%esp)
f0105c06:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105c0a:	75 1c                	jne    f0105c28 <__umoddi3+0x48>
f0105c0c:	39 f7                	cmp    %esi,%edi
f0105c0e:	76 50                	jbe    f0105c60 <__umoddi3+0x80>
f0105c10:	89 c8                	mov    %ecx,%eax
f0105c12:	89 f2                	mov    %esi,%edx
f0105c14:	f7 f7                	div    %edi
f0105c16:	89 d0                	mov    %edx,%eax
f0105c18:	31 d2                	xor    %edx,%edx
f0105c1a:	83 c4 1c             	add    $0x1c,%esp
f0105c1d:	5b                   	pop    %ebx
f0105c1e:	5e                   	pop    %esi
f0105c1f:	5f                   	pop    %edi
f0105c20:	5d                   	pop    %ebp
f0105c21:	c3                   	ret    
f0105c22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105c28:	39 f2                	cmp    %esi,%edx
f0105c2a:	89 d0                	mov    %edx,%eax
f0105c2c:	77 52                	ja     f0105c80 <__umoddi3+0xa0>
f0105c2e:	0f bd ea             	bsr    %edx,%ebp
f0105c31:	83 f5 1f             	xor    $0x1f,%ebp
f0105c34:	75 5a                	jne    f0105c90 <__umoddi3+0xb0>
f0105c36:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0105c3a:	0f 82 e0 00 00 00    	jb     f0105d20 <__umoddi3+0x140>
f0105c40:	39 0c 24             	cmp    %ecx,(%esp)
f0105c43:	0f 86 d7 00 00 00    	jbe    f0105d20 <__umoddi3+0x140>
f0105c49:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105c4d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0105c51:	83 c4 1c             	add    $0x1c,%esp
f0105c54:	5b                   	pop    %ebx
f0105c55:	5e                   	pop    %esi
f0105c56:	5f                   	pop    %edi
f0105c57:	5d                   	pop    %ebp
f0105c58:	c3                   	ret    
f0105c59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105c60:	85 ff                	test   %edi,%edi
f0105c62:	89 fd                	mov    %edi,%ebp
f0105c64:	75 0b                	jne    f0105c71 <__umoddi3+0x91>
f0105c66:	b8 01 00 00 00       	mov    $0x1,%eax
f0105c6b:	31 d2                	xor    %edx,%edx
f0105c6d:	f7 f7                	div    %edi
f0105c6f:	89 c5                	mov    %eax,%ebp
f0105c71:	89 f0                	mov    %esi,%eax
f0105c73:	31 d2                	xor    %edx,%edx
f0105c75:	f7 f5                	div    %ebp
f0105c77:	89 c8                	mov    %ecx,%eax
f0105c79:	f7 f5                	div    %ebp
f0105c7b:	89 d0                	mov    %edx,%eax
f0105c7d:	eb 99                	jmp    f0105c18 <__umoddi3+0x38>
f0105c7f:	90                   	nop
f0105c80:	89 c8                	mov    %ecx,%eax
f0105c82:	89 f2                	mov    %esi,%edx
f0105c84:	83 c4 1c             	add    $0x1c,%esp
f0105c87:	5b                   	pop    %ebx
f0105c88:	5e                   	pop    %esi
f0105c89:	5f                   	pop    %edi
f0105c8a:	5d                   	pop    %ebp
f0105c8b:	c3                   	ret    
f0105c8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105c90:	8b 34 24             	mov    (%esp),%esi
f0105c93:	bf 20 00 00 00       	mov    $0x20,%edi
f0105c98:	89 e9                	mov    %ebp,%ecx
f0105c9a:	29 ef                	sub    %ebp,%edi
f0105c9c:	d3 e0                	shl    %cl,%eax
f0105c9e:	89 f9                	mov    %edi,%ecx
f0105ca0:	89 f2                	mov    %esi,%edx
f0105ca2:	d3 ea                	shr    %cl,%edx
f0105ca4:	89 e9                	mov    %ebp,%ecx
f0105ca6:	09 c2                	or     %eax,%edx
f0105ca8:	89 d8                	mov    %ebx,%eax
f0105caa:	89 14 24             	mov    %edx,(%esp)
f0105cad:	89 f2                	mov    %esi,%edx
f0105caf:	d3 e2                	shl    %cl,%edx
f0105cb1:	89 f9                	mov    %edi,%ecx
f0105cb3:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105cb7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105cbb:	d3 e8                	shr    %cl,%eax
f0105cbd:	89 e9                	mov    %ebp,%ecx
f0105cbf:	89 c6                	mov    %eax,%esi
f0105cc1:	d3 e3                	shl    %cl,%ebx
f0105cc3:	89 f9                	mov    %edi,%ecx
f0105cc5:	89 d0                	mov    %edx,%eax
f0105cc7:	d3 e8                	shr    %cl,%eax
f0105cc9:	89 e9                	mov    %ebp,%ecx
f0105ccb:	09 d8                	or     %ebx,%eax
f0105ccd:	89 d3                	mov    %edx,%ebx
f0105ccf:	89 f2                	mov    %esi,%edx
f0105cd1:	f7 34 24             	divl   (%esp)
f0105cd4:	89 d6                	mov    %edx,%esi
f0105cd6:	d3 e3                	shl    %cl,%ebx
f0105cd8:	f7 64 24 04          	mull   0x4(%esp)
f0105cdc:	39 d6                	cmp    %edx,%esi
f0105cde:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105ce2:	89 d1                	mov    %edx,%ecx
f0105ce4:	89 c3                	mov    %eax,%ebx
f0105ce6:	72 08                	jb     f0105cf0 <__umoddi3+0x110>
f0105ce8:	75 11                	jne    f0105cfb <__umoddi3+0x11b>
f0105cea:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0105cee:	73 0b                	jae    f0105cfb <__umoddi3+0x11b>
f0105cf0:	2b 44 24 04          	sub    0x4(%esp),%eax
f0105cf4:	1b 14 24             	sbb    (%esp),%edx
f0105cf7:	89 d1                	mov    %edx,%ecx
f0105cf9:	89 c3                	mov    %eax,%ebx
f0105cfb:	8b 54 24 08          	mov    0x8(%esp),%edx
f0105cff:	29 da                	sub    %ebx,%edx
f0105d01:	19 ce                	sbb    %ecx,%esi
f0105d03:	89 f9                	mov    %edi,%ecx
f0105d05:	89 f0                	mov    %esi,%eax
f0105d07:	d3 e0                	shl    %cl,%eax
f0105d09:	89 e9                	mov    %ebp,%ecx
f0105d0b:	d3 ea                	shr    %cl,%edx
f0105d0d:	89 e9                	mov    %ebp,%ecx
f0105d0f:	d3 ee                	shr    %cl,%esi
f0105d11:	09 d0                	or     %edx,%eax
f0105d13:	89 f2                	mov    %esi,%edx
f0105d15:	83 c4 1c             	add    $0x1c,%esp
f0105d18:	5b                   	pop    %ebx
f0105d19:	5e                   	pop    %esi
f0105d1a:	5f                   	pop    %edi
f0105d1b:	5d                   	pop    %ebp
f0105d1c:	c3                   	ret    
f0105d1d:	8d 76 00             	lea    0x0(%esi),%esi
f0105d20:	29 f9                	sub    %edi,%ecx
f0105d22:	19 d6                	sbb    %edx,%esi
f0105d24:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105d28:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105d2c:	e9 18 ff ff ff       	jmp    f0105c49 <__umoddi3+0x69>
