
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 aa 01 00 00       	call   8001db <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 52 0c 00 00       	call   800c9c <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 80 1f 80 00       	push   $0x801f80
  800057:	6a 20                	push   $0x20
  800059:	68 93 1f 80 00       	push   $0x801f93
  80005e:	e8 d8 01 00 00       	call   80023b <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 69 0c 00 00       	call   800cdf <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 a3 1f 80 00       	push   $0x801fa3
  800083:	6a 22                	push   $0x22
  800085:	68 93 1f 80 00       	push   $0x801f93
  80008a:	e8 ac 01 00 00       	call   80023b <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 89 09 00 00       	call   800a2b <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 70 0c 00 00       	call   800d21 <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 b4 1f 80 00       	push   $0x801fb4
  8000be:	6a 25                	push   $0x25
  8000c0:	68 93 1f 80 00       	push   $0x801f93
  8000c5:	e8 71 01 00 00       	call   80023b <_panic>
}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8000d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	79 12                	jns    8000f8 <dumbfork+0x27>
		panic("sys_exofork: %e", envid);
  8000e6:	50                   	push   %eax
  8000e7:	68 c7 1f 80 00       	push   $0x801fc7
  8000ec:	6a 37                	push   $0x37
  8000ee:	68 93 1f 80 00       	push   $0x801f93
  8000f3:	e8 43 01 00 00       	call   80023b <_panic>
  8000f8:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1e                	jne    80011c <dumbfork+0x4b>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 5b 0b 00 00       	call   800c5e <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800110:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800115:	b8 00 00 00 00       	mov    $0x0,%eax
  80011a:	eb 60                	jmp    80017c <dumbfork+0xab>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80011c:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800123:	eb 14                	jmp    800139 <dumbfork+0x68>
		duppage(envid, addr);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	52                   	push   %edx
  800129:	56                   	push   %esi
  80012a:	e8 04 ff ff ff       	call   800033 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80012f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80013c:	81 fa 00 60 80 00    	cmp    $0x806000,%edx
  800142:	72 e1                	jb     800125 <dumbfork+0x54>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80014f:	50                   	push   %eax
  800150:	53                   	push   %ebx
  800151:	e8 dd fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	6a 02                	push   $0x2
  80015b:	53                   	push   %ebx
  80015c:	e8 02 0c 00 00       	call   800d63 <sys_env_set_status>
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	85 c0                	test   %eax,%eax
  800166:	79 12                	jns    80017a <dumbfork+0xa9>
		panic("sys_env_set_status: %e", r);
  800168:	50                   	push   %eax
  800169:	68 d7 1f 80 00       	push   $0x801fd7
  80016e:	6a 4c                	push   $0x4c
  800170:	68 93 1f 80 00       	push   $0x801f93
  800175:	e8 c1 00 00 00       	call   80023b <_panic>

	return envid;
  80017a:	89 d8                	mov    %ebx,%eax
}
  80017c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	57                   	push   %edi
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	83 ec 0c             	sub    $0xc,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  80018c:	e8 40 ff ff ff       	call   8000d1 <dumbfork>
  800191:	89 c7                	mov    %eax,%edi
  800193:	85 c0                	test   %eax,%eax
  800195:	be f5 1f 80 00       	mov    $0x801ff5,%esi
  80019a:	b8 ee 1f 80 00       	mov    $0x801fee,%eax
  80019f:	0f 45 f0             	cmovne %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a7:	eb 1a                	jmp    8001c3 <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001a9:	83 ec 04             	sub    $0x4,%esp
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	68 fb 1f 80 00       	push   $0x801ffb
  8001b3:	e8 5c 01 00 00       	call   800314 <cprintf>
		sys_yield();
  8001b8:	e8 c0 0a 00 00       	call   800c7d <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001bd:	83 c3 01             	add    $0x1,%ebx
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 ff                	test   %edi,%edi
  8001c5:	74 07                	je     8001ce <umain+0x4b>
  8001c7:	83 fb 09             	cmp    $0x9,%ebx
  8001ca:	7e dd                	jle    8001a9 <umain+0x26>
  8001cc:	eb 05                	jmp    8001d3 <umain+0x50>
  8001ce:	83 fb 13             	cmp    $0x13,%ebx
  8001d1:	7e d6                	jle    8001a9 <umain+0x26>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001e3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001e6:	e8 73 0a 00 00       	call   800c5e <sys_getenvid>
  8001eb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001f3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f8:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001fd:	85 db                	test   %ebx,%ebx
  8001ff:	7e 07                	jle    800208 <libmain+0x2d>
		binaryname = argv[0];
  800201:	8b 06                	mov    (%esi),%eax
  800203:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	53                   	push   %ebx
  80020d:	e8 71 ff ff ff       	call   800183 <umain>

	// exit gracefully
	exit();
  800212:	e8 0a 00 00 00       	call   800221 <exit>
}
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800227:	e8 2c 0e 00 00       	call   801058 <close_all>
	sys_env_destroy(0);
  80022c:	83 ec 0c             	sub    $0xc,%esp
  80022f:	6a 00                	push   $0x0
  800231:	e8 e7 09 00 00       	call   800c1d <sys_env_destroy>
}
  800236:	83 c4 10             	add    $0x10,%esp
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800240:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800243:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800249:	e8 10 0a 00 00       	call   800c5e <sys_getenvid>
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	ff 75 0c             	pushl  0xc(%ebp)
  800254:	ff 75 08             	pushl  0x8(%ebp)
  800257:	56                   	push   %esi
  800258:	50                   	push   %eax
  800259:	68 18 20 80 00       	push   $0x802018
  80025e:	e8 b1 00 00 00       	call   800314 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800263:	83 c4 18             	add    $0x18,%esp
  800266:	53                   	push   %ebx
  800267:	ff 75 10             	pushl  0x10(%ebp)
  80026a:	e8 54 00 00 00       	call   8002c3 <vcprintf>
	cprintf("\n");
  80026f:	c7 04 24 0b 20 80 00 	movl   $0x80200b,(%esp)
  800276:	e8 99 00 00 00       	call   800314 <cprintf>
  80027b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80027e:	cc                   	int3   
  80027f:	eb fd                	jmp    80027e <_panic+0x43>

00800281 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	53                   	push   %ebx
  800285:	83 ec 04             	sub    $0x4,%esp
  800288:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80028b:	8b 13                	mov    (%ebx),%edx
  80028d:	8d 42 01             	lea    0x1(%edx),%eax
  800290:	89 03                	mov    %eax,(%ebx)
  800292:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800295:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800299:	3d ff 00 00 00       	cmp    $0xff,%eax
  80029e:	75 1a                	jne    8002ba <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a0:	83 ec 08             	sub    $0x8,%esp
  8002a3:	68 ff 00 00 00       	push   $0xff
  8002a8:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ab:	50                   	push   %eax
  8002ac:	e8 2f 09 00 00       	call   800be0 <sys_cputs>
		b->idx = 0;
  8002b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002ba:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002c1:	c9                   	leave  
  8002c2:	c3                   	ret    

008002c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d3:	00 00 00 
	b.cnt = 0;
  8002d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e0:	ff 75 0c             	pushl  0xc(%ebp)
  8002e3:	ff 75 08             	pushl  0x8(%ebp)
  8002e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ec:	50                   	push   %eax
  8002ed:	68 81 02 80 00       	push   $0x800281
  8002f2:	e8 54 01 00 00       	call   80044b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f7:	83 c4 08             	add    $0x8,%esp
  8002fa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800300:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800306:	50                   	push   %eax
  800307:	e8 d4 08 00 00       	call   800be0 <sys_cputs>

	return b.cnt;
}
  80030c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80031a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80031d:	50                   	push   %eax
  80031e:	ff 75 08             	pushl  0x8(%ebp)
  800321:	e8 9d ff ff ff       	call   8002c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
  80032e:	83 ec 1c             	sub    $0x1c,%esp
  800331:	89 c7                	mov    %eax,%edi
  800333:	89 d6                	mov    %edx,%esi
  800335:	8b 45 08             	mov    0x8(%ebp),%eax
  800338:	8b 55 0c             	mov    0xc(%ebp),%edx
  80033b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800341:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800344:	bb 00 00 00 00       	mov    $0x0,%ebx
  800349:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80034c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034f:	39 d3                	cmp    %edx,%ebx
  800351:	72 05                	jb     800358 <printnum+0x30>
  800353:	39 45 10             	cmp    %eax,0x10(%ebp)
  800356:	77 45                	ja     80039d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800358:	83 ec 0c             	sub    $0xc,%esp
  80035b:	ff 75 18             	pushl  0x18(%ebp)
  80035e:	8b 45 14             	mov    0x14(%ebp),%eax
  800361:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800364:	53                   	push   %ebx
  800365:	ff 75 10             	pushl  0x10(%ebp)
  800368:	83 ec 08             	sub    $0x8,%esp
  80036b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80036e:	ff 75 e0             	pushl  -0x20(%ebp)
  800371:	ff 75 dc             	pushl  -0x24(%ebp)
  800374:	ff 75 d8             	pushl  -0x28(%ebp)
  800377:	e8 64 19 00 00       	call   801ce0 <__udivdi3>
  80037c:	83 c4 18             	add    $0x18,%esp
  80037f:	52                   	push   %edx
  800380:	50                   	push   %eax
  800381:	89 f2                	mov    %esi,%edx
  800383:	89 f8                	mov    %edi,%eax
  800385:	e8 9e ff ff ff       	call   800328 <printnum>
  80038a:	83 c4 20             	add    $0x20,%esp
  80038d:	eb 18                	jmp    8003a7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038f:	83 ec 08             	sub    $0x8,%esp
  800392:	56                   	push   %esi
  800393:	ff 75 18             	pushl  0x18(%ebp)
  800396:	ff d7                	call   *%edi
  800398:	83 c4 10             	add    $0x10,%esp
  80039b:	eb 03                	jmp    8003a0 <printnum+0x78>
  80039d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a0:	83 eb 01             	sub    $0x1,%ebx
  8003a3:	85 db                	test   %ebx,%ebx
  8003a5:	7f e8                	jg     80038f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a7:	83 ec 08             	sub    $0x8,%esp
  8003aa:	56                   	push   %esi
  8003ab:	83 ec 04             	sub    $0x4,%esp
  8003ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ba:	e8 51 1a 00 00       	call   801e10 <__umoddi3>
  8003bf:	83 c4 14             	add    $0x14,%esp
  8003c2:	0f be 80 3b 20 80 00 	movsbl 0x80203b(%eax),%eax
  8003c9:	50                   	push   %eax
  8003ca:	ff d7                	call   *%edi
}
  8003cc:	83 c4 10             	add    $0x10,%esp
  8003cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d2:	5b                   	pop    %ebx
  8003d3:	5e                   	pop    %esi
  8003d4:	5f                   	pop    %edi
  8003d5:	5d                   	pop    %ebp
  8003d6:	c3                   	ret    

008003d7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003da:	83 fa 01             	cmp    $0x1,%edx
  8003dd:	7e 0e                	jle    8003ed <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003df:	8b 10                	mov    (%eax),%edx
  8003e1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e4:	89 08                	mov    %ecx,(%eax)
  8003e6:	8b 02                	mov    (%edx),%eax
  8003e8:	8b 52 04             	mov    0x4(%edx),%edx
  8003eb:	eb 22                	jmp    80040f <getuint+0x38>
	else if (lflag)
  8003ed:	85 d2                	test   %edx,%edx
  8003ef:	74 10                	je     800401 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003f1:	8b 10                	mov    (%eax),%edx
  8003f3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f6:	89 08                	mov    %ecx,(%eax)
  8003f8:	8b 02                	mov    (%edx),%eax
  8003fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ff:	eb 0e                	jmp    80040f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800401:	8b 10                	mov    (%eax),%edx
  800403:	8d 4a 04             	lea    0x4(%edx),%ecx
  800406:	89 08                	mov    %ecx,(%eax)
  800408:	8b 02                	mov    (%edx),%eax
  80040a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040f:	5d                   	pop    %ebp
  800410:	c3                   	ret    

00800411 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800417:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80041b:	8b 10                	mov    (%eax),%edx
  80041d:	3b 50 04             	cmp    0x4(%eax),%edx
  800420:	73 0a                	jae    80042c <sprintputch+0x1b>
		*b->buf++ = ch;
  800422:	8d 4a 01             	lea    0x1(%edx),%ecx
  800425:	89 08                	mov    %ecx,(%eax)
  800427:	8b 45 08             	mov    0x8(%ebp),%eax
  80042a:	88 02                	mov    %al,(%edx)
}
  80042c:	5d                   	pop    %ebp
  80042d:	c3                   	ret    

0080042e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800434:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800437:	50                   	push   %eax
  800438:	ff 75 10             	pushl  0x10(%ebp)
  80043b:	ff 75 0c             	pushl  0xc(%ebp)
  80043e:	ff 75 08             	pushl  0x8(%ebp)
  800441:	e8 05 00 00 00       	call   80044b <vprintfmt>
	va_end(ap);
}
  800446:	83 c4 10             	add    $0x10,%esp
  800449:	c9                   	leave  
  80044a:	c3                   	ret    

0080044b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80044b:	55                   	push   %ebp
  80044c:	89 e5                	mov    %esp,%ebp
  80044e:	57                   	push   %edi
  80044f:	56                   	push   %esi
  800450:	53                   	push   %ebx
  800451:	83 ec 2c             	sub    $0x2c,%esp
  800454:	8b 75 08             	mov    0x8(%ebp),%esi
  800457:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80045a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80045d:	eb 12                	jmp    800471 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80045f:	85 c0                	test   %eax,%eax
  800461:	0f 84 89 03 00 00    	je     8007f0 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	53                   	push   %ebx
  80046b:	50                   	push   %eax
  80046c:	ff d6                	call   *%esi
  80046e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800471:	83 c7 01             	add    $0x1,%edi
  800474:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800478:	83 f8 25             	cmp    $0x25,%eax
  80047b:	75 e2                	jne    80045f <vprintfmt+0x14>
  80047d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800481:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800488:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80048f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800496:	ba 00 00 00 00       	mov    $0x0,%edx
  80049b:	eb 07                	jmp    8004a4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8d 47 01             	lea    0x1(%edi),%eax
  8004a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004aa:	0f b6 07             	movzbl (%edi),%eax
  8004ad:	0f b6 c8             	movzbl %al,%ecx
  8004b0:	83 e8 23             	sub    $0x23,%eax
  8004b3:	3c 55                	cmp    $0x55,%al
  8004b5:	0f 87 1a 03 00 00    	ja     8007d5 <vprintfmt+0x38a>
  8004bb:	0f b6 c0             	movzbl %al,%eax
  8004be:	ff 24 85 80 21 80 00 	jmp    *0x802180(,%eax,4)
  8004c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004cc:	eb d6                	jmp    8004a4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004d9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004dc:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004e0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004e3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004e6:	83 fa 09             	cmp    $0x9,%edx
  8004e9:	77 39                	ja     800524 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004eb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004ee:	eb e9                	jmp    8004d9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f3:	8d 48 04             	lea    0x4(%eax),%ecx
  8004f6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004f9:	8b 00                	mov    (%eax),%eax
  8004fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800501:	eb 27                	jmp    80052a <vprintfmt+0xdf>
  800503:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800506:	85 c0                	test   %eax,%eax
  800508:	b9 00 00 00 00       	mov    $0x0,%ecx
  80050d:	0f 49 c8             	cmovns %eax,%ecx
  800510:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800516:	eb 8c                	jmp    8004a4 <vprintfmt+0x59>
  800518:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80051b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800522:	eb 80                	jmp    8004a4 <vprintfmt+0x59>
  800524:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800527:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80052a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052e:	0f 89 70 ff ff ff    	jns    8004a4 <vprintfmt+0x59>
				width = precision, precision = -1;
  800534:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800537:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80053a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800541:	e9 5e ff ff ff       	jmp    8004a4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800546:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800549:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80054c:	e9 53 ff ff ff       	jmp    8004a4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800551:	8b 45 14             	mov    0x14(%ebp),%eax
  800554:	8d 50 04             	lea    0x4(%eax),%edx
  800557:	89 55 14             	mov    %edx,0x14(%ebp)
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	53                   	push   %ebx
  80055e:	ff 30                	pushl  (%eax)
  800560:	ff d6                	call   *%esi
			break;
  800562:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800565:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800568:	e9 04 ff ff ff       	jmp    800471 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 50 04             	lea    0x4(%eax),%edx
  800573:	89 55 14             	mov    %edx,0x14(%ebp)
  800576:	8b 00                	mov    (%eax),%eax
  800578:	99                   	cltd   
  800579:	31 d0                	xor    %edx,%eax
  80057b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80057d:	83 f8 0f             	cmp    $0xf,%eax
  800580:	7f 0b                	jg     80058d <vprintfmt+0x142>
  800582:	8b 14 85 e0 22 80 00 	mov    0x8022e0(,%eax,4),%edx
  800589:	85 d2                	test   %edx,%edx
  80058b:	75 18                	jne    8005a5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80058d:	50                   	push   %eax
  80058e:	68 53 20 80 00       	push   $0x802053
  800593:	53                   	push   %ebx
  800594:	56                   	push   %esi
  800595:	e8 94 fe ff ff       	call   80042e <printfmt>
  80059a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005a0:	e9 cc fe ff ff       	jmp    800471 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005a5:	52                   	push   %edx
  8005a6:	68 1a 24 80 00       	push   $0x80241a
  8005ab:	53                   	push   %ebx
  8005ac:	56                   	push   %esi
  8005ad:	e8 7c fe ff ff       	call   80042e <printfmt>
  8005b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b8:	e9 b4 fe ff ff       	jmp    800471 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8d 50 04             	lea    0x4(%eax),%edx
  8005c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005c8:	85 ff                	test   %edi,%edi
  8005ca:	b8 4c 20 80 00       	mov    $0x80204c,%eax
  8005cf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005d2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d6:	0f 8e 94 00 00 00    	jle    800670 <vprintfmt+0x225>
  8005dc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005e0:	0f 84 98 00 00 00    	je     80067e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e6:	83 ec 08             	sub    $0x8,%esp
  8005e9:	ff 75 d0             	pushl  -0x30(%ebp)
  8005ec:	57                   	push   %edi
  8005ed:	e8 86 02 00 00       	call   800878 <strnlen>
  8005f2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005f5:	29 c1                	sub    %eax,%ecx
  8005f7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005fa:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005fd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800601:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800604:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800607:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800609:	eb 0f                	jmp    80061a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	ff 75 e0             	pushl  -0x20(%ebp)
  800612:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800614:	83 ef 01             	sub    $0x1,%edi
  800617:	83 c4 10             	add    $0x10,%esp
  80061a:	85 ff                	test   %edi,%edi
  80061c:	7f ed                	jg     80060b <vprintfmt+0x1c0>
  80061e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800621:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800624:	85 c9                	test   %ecx,%ecx
  800626:	b8 00 00 00 00       	mov    $0x0,%eax
  80062b:	0f 49 c1             	cmovns %ecx,%eax
  80062e:	29 c1                	sub    %eax,%ecx
  800630:	89 75 08             	mov    %esi,0x8(%ebp)
  800633:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800636:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800639:	89 cb                	mov    %ecx,%ebx
  80063b:	eb 4d                	jmp    80068a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80063d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800641:	74 1b                	je     80065e <vprintfmt+0x213>
  800643:	0f be c0             	movsbl %al,%eax
  800646:	83 e8 20             	sub    $0x20,%eax
  800649:	83 f8 5e             	cmp    $0x5e,%eax
  80064c:	76 10                	jbe    80065e <vprintfmt+0x213>
					putch('?', putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	ff 75 0c             	pushl  0xc(%ebp)
  800654:	6a 3f                	push   $0x3f
  800656:	ff 55 08             	call   *0x8(%ebp)
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	eb 0d                	jmp    80066b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	ff 75 0c             	pushl  0xc(%ebp)
  800664:	52                   	push   %edx
  800665:	ff 55 08             	call   *0x8(%ebp)
  800668:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066b:	83 eb 01             	sub    $0x1,%ebx
  80066e:	eb 1a                	jmp    80068a <vprintfmt+0x23f>
  800670:	89 75 08             	mov    %esi,0x8(%ebp)
  800673:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800676:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800679:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80067c:	eb 0c                	jmp    80068a <vprintfmt+0x23f>
  80067e:	89 75 08             	mov    %esi,0x8(%ebp)
  800681:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800684:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800687:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80068a:	83 c7 01             	add    $0x1,%edi
  80068d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800691:	0f be d0             	movsbl %al,%edx
  800694:	85 d2                	test   %edx,%edx
  800696:	74 23                	je     8006bb <vprintfmt+0x270>
  800698:	85 f6                	test   %esi,%esi
  80069a:	78 a1                	js     80063d <vprintfmt+0x1f2>
  80069c:	83 ee 01             	sub    $0x1,%esi
  80069f:	79 9c                	jns    80063d <vprintfmt+0x1f2>
  8006a1:	89 df                	mov    %ebx,%edi
  8006a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a9:	eb 18                	jmp    8006c3 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	6a 20                	push   $0x20
  8006b1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b3:	83 ef 01             	sub    $0x1,%edi
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	eb 08                	jmp    8006c3 <vprintfmt+0x278>
  8006bb:	89 df                	mov    %ebx,%edi
  8006bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c3:	85 ff                	test   %edi,%edi
  8006c5:	7f e4                	jg     8006ab <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ca:	e9 a2 fd ff ff       	jmp    800471 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006cf:	83 fa 01             	cmp    $0x1,%edx
  8006d2:	7e 16                	jle    8006ea <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8d 50 08             	lea    0x8(%eax),%edx
  8006da:	89 55 14             	mov    %edx,0x14(%ebp)
  8006dd:	8b 50 04             	mov    0x4(%eax),%edx
  8006e0:	8b 00                	mov    (%eax),%eax
  8006e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e8:	eb 32                	jmp    80071c <vprintfmt+0x2d1>
	else if (lflag)
  8006ea:	85 d2                	test   %edx,%edx
  8006ec:	74 18                	je     800706 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f1:	8d 50 04             	lea    0x4(%eax),%edx
  8006f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f7:	8b 00                	mov    (%eax),%eax
  8006f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fc:	89 c1                	mov    %eax,%ecx
  8006fe:	c1 f9 1f             	sar    $0x1f,%ecx
  800701:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800704:	eb 16                	jmp    80071c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8d 50 04             	lea    0x4(%eax),%edx
  80070c:	89 55 14             	mov    %edx,0x14(%ebp)
  80070f:	8b 00                	mov    (%eax),%eax
  800711:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800714:	89 c1                	mov    %eax,%ecx
  800716:	c1 f9 1f             	sar    $0x1f,%ecx
  800719:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80071c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80071f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800722:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800727:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80072b:	79 74                	jns    8007a1 <vprintfmt+0x356>
				putch('-', putdat);
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	53                   	push   %ebx
  800731:	6a 2d                	push   $0x2d
  800733:	ff d6                	call   *%esi
				num = -(long long) num;
  800735:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800738:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80073b:	f7 d8                	neg    %eax
  80073d:	83 d2 00             	adc    $0x0,%edx
  800740:	f7 da                	neg    %edx
  800742:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800745:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80074a:	eb 55                	jmp    8007a1 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80074c:	8d 45 14             	lea    0x14(%ebp),%eax
  80074f:	e8 83 fc ff ff       	call   8003d7 <getuint>
			base = 10;
  800754:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800759:	eb 46                	jmp    8007a1 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80075b:	8d 45 14             	lea    0x14(%ebp),%eax
  80075e:	e8 74 fc ff ff       	call   8003d7 <getuint>
                        base = 8;
  800763:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800768:	eb 37                	jmp    8007a1 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80076a:	83 ec 08             	sub    $0x8,%esp
  80076d:	53                   	push   %ebx
  80076e:	6a 30                	push   $0x30
  800770:	ff d6                	call   *%esi
			putch('x', putdat);
  800772:	83 c4 08             	add    $0x8,%esp
  800775:	53                   	push   %ebx
  800776:	6a 78                	push   $0x78
  800778:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8d 50 04             	lea    0x4(%eax),%edx
  800780:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800783:	8b 00                	mov    (%eax),%eax
  800785:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80078a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80078d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800792:	eb 0d                	jmp    8007a1 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800794:	8d 45 14             	lea    0x14(%ebp),%eax
  800797:	e8 3b fc ff ff       	call   8003d7 <getuint>
			base = 16;
  80079c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a1:	83 ec 0c             	sub    $0xc,%esp
  8007a4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007a8:	57                   	push   %edi
  8007a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ac:	51                   	push   %ecx
  8007ad:	52                   	push   %edx
  8007ae:	50                   	push   %eax
  8007af:	89 da                	mov    %ebx,%edx
  8007b1:	89 f0                	mov    %esi,%eax
  8007b3:	e8 70 fb ff ff       	call   800328 <printnum>
			break;
  8007b8:	83 c4 20             	add    $0x20,%esp
  8007bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007be:	e9 ae fc ff ff       	jmp    800471 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007c3:	83 ec 08             	sub    $0x8,%esp
  8007c6:	53                   	push   %ebx
  8007c7:	51                   	push   %ecx
  8007c8:	ff d6                	call   *%esi
			break;
  8007ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007d0:	e9 9c fc ff ff       	jmp    800471 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d5:	83 ec 08             	sub    $0x8,%esp
  8007d8:	53                   	push   %ebx
  8007d9:	6a 25                	push   $0x25
  8007db:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007dd:	83 c4 10             	add    $0x10,%esp
  8007e0:	eb 03                	jmp    8007e5 <vprintfmt+0x39a>
  8007e2:	83 ef 01             	sub    $0x1,%edi
  8007e5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e9:	75 f7                	jne    8007e2 <vprintfmt+0x397>
  8007eb:	e9 81 fc ff ff       	jmp    800471 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f3:	5b                   	pop    %ebx
  8007f4:	5e                   	pop    %esi
  8007f5:	5f                   	pop    %edi
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	83 ec 18             	sub    $0x18,%esp
  8007fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800801:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800804:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800807:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80080b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80080e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800815:	85 c0                	test   %eax,%eax
  800817:	74 26                	je     80083f <vsnprintf+0x47>
  800819:	85 d2                	test   %edx,%edx
  80081b:	7e 22                	jle    80083f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80081d:	ff 75 14             	pushl  0x14(%ebp)
  800820:	ff 75 10             	pushl  0x10(%ebp)
  800823:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800826:	50                   	push   %eax
  800827:	68 11 04 80 00       	push   $0x800411
  80082c:	e8 1a fc ff ff       	call   80044b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800831:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800834:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800837:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	eb 05                	jmp    800844 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80083f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800844:	c9                   	leave  
  800845:	c3                   	ret    

00800846 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80084c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80084f:	50                   	push   %eax
  800850:	ff 75 10             	pushl  0x10(%ebp)
  800853:	ff 75 0c             	pushl  0xc(%ebp)
  800856:	ff 75 08             	pushl  0x8(%ebp)
  800859:	e8 9a ff ff ff       	call   8007f8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80085e:	c9                   	leave  
  80085f:	c3                   	ret    

00800860 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
  80086b:	eb 03                	jmp    800870 <strlen+0x10>
		n++;
  80086d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800870:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800874:	75 f7                	jne    80086d <strlen+0xd>
		n++;
	return n;
}
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800881:	ba 00 00 00 00       	mov    $0x0,%edx
  800886:	eb 03                	jmp    80088b <strnlen+0x13>
		n++;
  800888:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088b:	39 c2                	cmp    %eax,%edx
  80088d:	74 08                	je     800897 <strnlen+0x1f>
  80088f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800893:	75 f3                	jne    800888 <strnlen+0x10>
  800895:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	53                   	push   %ebx
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a3:	89 c2                	mov    %eax,%edx
  8008a5:	83 c2 01             	add    $0x1,%edx
  8008a8:	83 c1 01             	add    $0x1,%ecx
  8008ab:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008af:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008b2:	84 db                	test   %bl,%bl
  8008b4:	75 ef                	jne    8008a5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b6:	5b                   	pop    %ebx
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	53                   	push   %ebx
  8008bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c0:	53                   	push   %ebx
  8008c1:	e8 9a ff ff ff       	call   800860 <strlen>
  8008c6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008c9:	ff 75 0c             	pushl  0xc(%ebp)
  8008cc:	01 d8                	add    %ebx,%eax
  8008ce:	50                   	push   %eax
  8008cf:	e8 c5 ff ff ff       	call   800899 <strcpy>
	return dst;
}
  8008d4:	89 d8                	mov    %ebx,%eax
  8008d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d9:	c9                   	leave  
  8008da:	c3                   	ret    

008008db <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	56                   	push   %esi
  8008df:	53                   	push   %ebx
  8008e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e6:	89 f3                	mov    %esi,%ebx
  8008e8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008eb:	89 f2                	mov    %esi,%edx
  8008ed:	eb 0f                	jmp    8008fe <strncpy+0x23>
		*dst++ = *src;
  8008ef:	83 c2 01             	add    $0x1,%edx
  8008f2:	0f b6 01             	movzbl (%ecx),%eax
  8008f5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f8:	80 39 01             	cmpb   $0x1,(%ecx)
  8008fb:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008fe:	39 da                	cmp    %ebx,%edx
  800900:	75 ed                	jne    8008ef <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800902:	89 f0                	mov    %esi,%eax
  800904:	5b                   	pop    %ebx
  800905:	5e                   	pop    %esi
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	56                   	push   %esi
  80090c:	53                   	push   %ebx
  80090d:	8b 75 08             	mov    0x8(%ebp),%esi
  800910:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800913:	8b 55 10             	mov    0x10(%ebp),%edx
  800916:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800918:	85 d2                	test   %edx,%edx
  80091a:	74 21                	je     80093d <strlcpy+0x35>
  80091c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800920:	89 f2                	mov    %esi,%edx
  800922:	eb 09                	jmp    80092d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800924:	83 c2 01             	add    $0x1,%edx
  800927:	83 c1 01             	add    $0x1,%ecx
  80092a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80092d:	39 c2                	cmp    %eax,%edx
  80092f:	74 09                	je     80093a <strlcpy+0x32>
  800931:	0f b6 19             	movzbl (%ecx),%ebx
  800934:	84 db                	test   %bl,%bl
  800936:	75 ec                	jne    800924 <strlcpy+0x1c>
  800938:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80093a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80093d:	29 f0                	sub    %esi,%eax
}
  80093f:	5b                   	pop    %ebx
  800940:	5e                   	pop    %esi
  800941:	5d                   	pop    %ebp
  800942:	c3                   	ret    

00800943 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800949:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80094c:	eb 06                	jmp    800954 <strcmp+0x11>
		p++, q++;
  80094e:	83 c1 01             	add    $0x1,%ecx
  800951:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800954:	0f b6 01             	movzbl (%ecx),%eax
  800957:	84 c0                	test   %al,%al
  800959:	74 04                	je     80095f <strcmp+0x1c>
  80095b:	3a 02                	cmp    (%edx),%al
  80095d:	74 ef                	je     80094e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80095f:	0f b6 c0             	movzbl %al,%eax
  800962:	0f b6 12             	movzbl (%edx),%edx
  800965:	29 d0                	sub    %edx,%eax
}
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	53                   	push   %ebx
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 55 0c             	mov    0xc(%ebp),%edx
  800973:	89 c3                	mov    %eax,%ebx
  800975:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800978:	eb 06                	jmp    800980 <strncmp+0x17>
		n--, p++, q++;
  80097a:	83 c0 01             	add    $0x1,%eax
  80097d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800980:	39 d8                	cmp    %ebx,%eax
  800982:	74 15                	je     800999 <strncmp+0x30>
  800984:	0f b6 08             	movzbl (%eax),%ecx
  800987:	84 c9                	test   %cl,%cl
  800989:	74 04                	je     80098f <strncmp+0x26>
  80098b:	3a 0a                	cmp    (%edx),%cl
  80098d:	74 eb                	je     80097a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80098f:	0f b6 00             	movzbl (%eax),%eax
  800992:	0f b6 12             	movzbl (%edx),%edx
  800995:	29 d0                	sub    %edx,%eax
  800997:	eb 05                	jmp    80099e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800999:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80099e:	5b                   	pop    %ebx
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ab:	eb 07                	jmp    8009b4 <strchr+0x13>
		if (*s == c)
  8009ad:	38 ca                	cmp    %cl,%dl
  8009af:	74 0f                	je     8009c0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009b1:	83 c0 01             	add    $0x1,%eax
  8009b4:	0f b6 10             	movzbl (%eax),%edx
  8009b7:	84 d2                	test   %dl,%dl
  8009b9:	75 f2                	jne    8009ad <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009cc:	eb 03                	jmp    8009d1 <strfind+0xf>
  8009ce:	83 c0 01             	add    $0x1,%eax
  8009d1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009d4:	38 ca                	cmp    %cl,%dl
  8009d6:	74 04                	je     8009dc <strfind+0x1a>
  8009d8:	84 d2                	test   %dl,%dl
  8009da:	75 f2                	jne    8009ce <strfind+0xc>
			break;
	return (char *) s;
}
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	57                   	push   %edi
  8009e2:	56                   	push   %esi
  8009e3:	53                   	push   %ebx
  8009e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ea:	85 c9                	test   %ecx,%ecx
  8009ec:	74 36                	je     800a24 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ee:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f4:	75 28                	jne    800a1e <memset+0x40>
  8009f6:	f6 c1 03             	test   $0x3,%cl
  8009f9:	75 23                	jne    800a1e <memset+0x40>
		c &= 0xFF;
  8009fb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ff:	89 d3                	mov    %edx,%ebx
  800a01:	c1 e3 08             	shl    $0x8,%ebx
  800a04:	89 d6                	mov    %edx,%esi
  800a06:	c1 e6 18             	shl    $0x18,%esi
  800a09:	89 d0                	mov    %edx,%eax
  800a0b:	c1 e0 10             	shl    $0x10,%eax
  800a0e:	09 f0                	or     %esi,%eax
  800a10:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a12:	89 d8                	mov    %ebx,%eax
  800a14:	09 d0                	or     %edx,%eax
  800a16:	c1 e9 02             	shr    $0x2,%ecx
  800a19:	fc                   	cld    
  800a1a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a1c:	eb 06                	jmp    800a24 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a21:	fc                   	cld    
  800a22:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a24:	89 f8                	mov    %edi,%eax
  800a26:	5b                   	pop    %ebx
  800a27:	5e                   	pop    %esi
  800a28:	5f                   	pop    %edi
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	57                   	push   %edi
  800a2f:	56                   	push   %esi
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a36:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a39:	39 c6                	cmp    %eax,%esi
  800a3b:	73 35                	jae    800a72 <memmove+0x47>
  800a3d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a40:	39 d0                	cmp    %edx,%eax
  800a42:	73 2e                	jae    800a72 <memmove+0x47>
		s += n;
		d += n;
  800a44:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a47:	89 d6                	mov    %edx,%esi
  800a49:	09 fe                	or     %edi,%esi
  800a4b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a51:	75 13                	jne    800a66 <memmove+0x3b>
  800a53:	f6 c1 03             	test   $0x3,%cl
  800a56:	75 0e                	jne    800a66 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a58:	83 ef 04             	sub    $0x4,%edi
  800a5b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a5e:	c1 e9 02             	shr    $0x2,%ecx
  800a61:	fd                   	std    
  800a62:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a64:	eb 09                	jmp    800a6f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a66:	83 ef 01             	sub    $0x1,%edi
  800a69:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a6c:	fd                   	std    
  800a6d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6f:	fc                   	cld    
  800a70:	eb 1d                	jmp    800a8f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a72:	89 f2                	mov    %esi,%edx
  800a74:	09 c2                	or     %eax,%edx
  800a76:	f6 c2 03             	test   $0x3,%dl
  800a79:	75 0f                	jne    800a8a <memmove+0x5f>
  800a7b:	f6 c1 03             	test   $0x3,%cl
  800a7e:	75 0a                	jne    800a8a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a80:	c1 e9 02             	shr    $0x2,%ecx
  800a83:	89 c7                	mov    %eax,%edi
  800a85:	fc                   	cld    
  800a86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a88:	eb 05                	jmp    800a8f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a8a:	89 c7                	mov    %eax,%edi
  800a8c:	fc                   	cld    
  800a8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8f:	5e                   	pop    %esi
  800a90:	5f                   	pop    %edi
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a96:	ff 75 10             	pushl  0x10(%ebp)
  800a99:	ff 75 0c             	pushl  0xc(%ebp)
  800a9c:	ff 75 08             	pushl  0x8(%ebp)
  800a9f:	e8 87 ff ff ff       	call   800a2b <memmove>
}
  800aa4:	c9                   	leave  
  800aa5:	c3                   	ret    

00800aa6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab1:	89 c6                	mov    %eax,%esi
  800ab3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab6:	eb 1a                	jmp    800ad2 <memcmp+0x2c>
		if (*s1 != *s2)
  800ab8:	0f b6 08             	movzbl (%eax),%ecx
  800abb:	0f b6 1a             	movzbl (%edx),%ebx
  800abe:	38 d9                	cmp    %bl,%cl
  800ac0:	74 0a                	je     800acc <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ac2:	0f b6 c1             	movzbl %cl,%eax
  800ac5:	0f b6 db             	movzbl %bl,%ebx
  800ac8:	29 d8                	sub    %ebx,%eax
  800aca:	eb 0f                	jmp    800adb <memcmp+0x35>
		s1++, s2++;
  800acc:	83 c0 01             	add    $0x1,%eax
  800acf:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad2:	39 f0                	cmp    %esi,%eax
  800ad4:	75 e2                	jne    800ab8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800adb:	5b                   	pop    %ebx
  800adc:	5e                   	pop    %esi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	53                   	push   %ebx
  800ae3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ae6:	89 c1                	mov    %eax,%ecx
  800ae8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800aeb:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aef:	eb 0a                	jmp    800afb <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af1:	0f b6 10             	movzbl (%eax),%edx
  800af4:	39 da                	cmp    %ebx,%edx
  800af6:	74 07                	je     800aff <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af8:	83 c0 01             	add    $0x1,%eax
  800afb:	39 c8                	cmp    %ecx,%eax
  800afd:	72 f2                	jb     800af1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aff:	5b                   	pop    %ebx
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0e:	eb 03                	jmp    800b13 <strtol+0x11>
		s++;
  800b10:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b13:	0f b6 01             	movzbl (%ecx),%eax
  800b16:	3c 20                	cmp    $0x20,%al
  800b18:	74 f6                	je     800b10 <strtol+0xe>
  800b1a:	3c 09                	cmp    $0x9,%al
  800b1c:	74 f2                	je     800b10 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b1e:	3c 2b                	cmp    $0x2b,%al
  800b20:	75 0a                	jne    800b2c <strtol+0x2a>
		s++;
  800b22:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b25:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2a:	eb 11                	jmp    800b3d <strtol+0x3b>
  800b2c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b31:	3c 2d                	cmp    $0x2d,%al
  800b33:	75 08                	jne    800b3d <strtol+0x3b>
		s++, neg = 1;
  800b35:	83 c1 01             	add    $0x1,%ecx
  800b38:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b3d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b43:	75 15                	jne    800b5a <strtol+0x58>
  800b45:	80 39 30             	cmpb   $0x30,(%ecx)
  800b48:	75 10                	jne    800b5a <strtol+0x58>
  800b4a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b4e:	75 7c                	jne    800bcc <strtol+0xca>
		s += 2, base = 16;
  800b50:	83 c1 02             	add    $0x2,%ecx
  800b53:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b58:	eb 16                	jmp    800b70 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b5a:	85 db                	test   %ebx,%ebx
  800b5c:	75 12                	jne    800b70 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b5e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b63:	80 39 30             	cmpb   $0x30,(%ecx)
  800b66:	75 08                	jne    800b70 <strtol+0x6e>
		s++, base = 8;
  800b68:	83 c1 01             	add    $0x1,%ecx
  800b6b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b70:	b8 00 00 00 00       	mov    $0x0,%eax
  800b75:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b78:	0f b6 11             	movzbl (%ecx),%edx
  800b7b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b7e:	89 f3                	mov    %esi,%ebx
  800b80:	80 fb 09             	cmp    $0x9,%bl
  800b83:	77 08                	ja     800b8d <strtol+0x8b>
			dig = *s - '0';
  800b85:	0f be d2             	movsbl %dl,%edx
  800b88:	83 ea 30             	sub    $0x30,%edx
  800b8b:	eb 22                	jmp    800baf <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b8d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b90:	89 f3                	mov    %esi,%ebx
  800b92:	80 fb 19             	cmp    $0x19,%bl
  800b95:	77 08                	ja     800b9f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b97:	0f be d2             	movsbl %dl,%edx
  800b9a:	83 ea 57             	sub    $0x57,%edx
  800b9d:	eb 10                	jmp    800baf <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b9f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ba2:	89 f3                	mov    %esi,%ebx
  800ba4:	80 fb 19             	cmp    $0x19,%bl
  800ba7:	77 16                	ja     800bbf <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ba9:	0f be d2             	movsbl %dl,%edx
  800bac:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800baf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bb2:	7d 0b                	jge    800bbf <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bb4:	83 c1 01             	add    $0x1,%ecx
  800bb7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bbb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bbd:	eb b9                	jmp    800b78 <strtol+0x76>

	if (endptr)
  800bbf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc3:	74 0d                	je     800bd2 <strtol+0xd0>
		*endptr = (char *) s;
  800bc5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc8:	89 0e                	mov    %ecx,(%esi)
  800bca:	eb 06                	jmp    800bd2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bcc:	85 db                	test   %ebx,%ebx
  800bce:	74 98                	je     800b68 <strtol+0x66>
  800bd0:	eb 9e                	jmp    800b70 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bd2:	89 c2                	mov    %eax,%edx
  800bd4:	f7 da                	neg    %edx
  800bd6:	85 ff                	test   %edi,%edi
  800bd8:	0f 45 c2             	cmovne %edx,%eax
}
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	b8 00 00 00 00       	mov    $0x0,%eax
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf1:	89 c3                	mov    %eax,%ebx
  800bf3:	89 c7                	mov    %eax,%edi
  800bf5:	89 c6                	mov    %eax,%esi
  800bf7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_cgetc>:

int
sys_cgetc(void)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	ba 00 00 00 00       	mov    $0x0,%edx
  800c09:	b8 01 00 00 00       	mov    $0x1,%eax
  800c0e:	89 d1                	mov    %edx,%ecx
  800c10:	89 d3                	mov    %edx,%ebx
  800c12:	89 d7                	mov    %edx,%edi
  800c14:	89 d6                	mov    %edx,%esi
  800c16:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
  800c23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c26:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	89 cb                	mov    %ecx,%ebx
  800c35:	89 cf                	mov    %ecx,%edi
  800c37:	89 ce                	mov    %ecx,%esi
  800c39:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	7e 17                	jle    800c56 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3f:	83 ec 0c             	sub    $0xc,%esp
  800c42:	50                   	push   %eax
  800c43:	6a 03                	push   $0x3
  800c45:	68 3f 23 80 00       	push   $0x80233f
  800c4a:	6a 23                	push   $0x23
  800c4c:	68 5c 23 80 00       	push   $0x80235c
  800c51:	e8 e5 f5 ff ff       	call   80023b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c64:	ba 00 00 00 00       	mov    $0x0,%edx
  800c69:	b8 02 00 00 00       	mov    $0x2,%eax
  800c6e:	89 d1                	mov    %edx,%ecx
  800c70:	89 d3                	mov    %edx,%ebx
  800c72:	89 d7                	mov    %edx,%edi
  800c74:	89 d6                	mov    %edx,%esi
  800c76:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <sys_yield>:

void
sys_yield(void)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	ba 00 00 00 00       	mov    $0x0,%edx
  800c88:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c8d:	89 d1                	mov    %edx,%ecx
  800c8f:	89 d3                	mov    %edx,%ebx
  800c91:	89 d7                	mov    %edx,%edi
  800c93:	89 d6                	mov    %edx,%esi
  800c95:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca5:	be 00 00 00 00       	mov    $0x0,%esi
  800caa:	b8 04 00 00 00       	mov    $0x4,%eax
  800caf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb8:	89 f7                	mov    %esi,%edi
  800cba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	7e 17                	jle    800cd7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 04                	push   $0x4
  800cc6:	68 3f 23 80 00       	push   $0x80233f
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 5c 23 80 00       	push   $0x80235c
  800cd2:	e8 64 f5 ff ff       	call   80023b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce8:	b8 05 00 00 00       	mov    $0x5,%eax
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf9:	8b 75 18             	mov    0x18(%ebp),%esi
  800cfc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	7e 17                	jle    800d19 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 05                	push   $0x5
  800d08:	68 3f 23 80 00       	push   $0x80233f
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 5c 23 80 00       	push   $0x80235c
  800d14:	e8 22 f5 ff ff       	call   80023b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
  800d27:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2f:	b8 06 00 00 00       	mov    $0x6,%eax
  800d34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d37:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3a:	89 df                	mov    %ebx,%edi
  800d3c:	89 de                	mov    %ebx,%esi
  800d3e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d40:	85 c0                	test   %eax,%eax
  800d42:	7e 17                	jle    800d5b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	50                   	push   %eax
  800d48:	6a 06                	push   $0x6
  800d4a:	68 3f 23 80 00       	push   $0x80233f
  800d4f:	6a 23                	push   $0x23
  800d51:	68 5c 23 80 00       	push   $0x80235c
  800d56:	e8 e0 f4 ff ff       	call   80023b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d71:	b8 08 00 00 00       	mov    $0x8,%eax
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	89 df                	mov    %ebx,%edi
  800d7e:	89 de                	mov    %ebx,%esi
  800d80:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d82:	85 c0                	test   %eax,%eax
  800d84:	7e 17                	jle    800d9d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d86:	83 ec 0c             	sub    $0xc,%esp
  800d89:	50                   	push   %eax
  800d8a:	6a 08                	push   $0x8
  800d8c:	68 3f 23 80 00       	push   $0x80233f
  800d91:	6a 23                	push   $0x23
  800d93:	68 5c 23 80 00       	push   $0x80235c
  800d98:	e8 9e f4 ff ff       	call   80023b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
  800dab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db3:	b8 09 00 00 00       	mov    $0x9,%eax
  800db8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbe:	89 df                	mov    %ebx,%edi
  800dc0:	89 de                	mov    %ebx,%esi
  800dc2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	7e 17                	jle    800ddf <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc8:	83 ec 0c             	sub    $0xc,%esp
  800dcb:	50                   	push   %eax
  800dcc:	6a 09                	push   $0x9
  800dce:	68 3f 23 80 00       	push   $0x80233f
  800dd3:	6a 23                	push   $0x23
  800dd5:	68 5c 23 80 00       	push   $0x80235c
  800dda:	e8 5c f4 ff ff       	call   80023b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ddf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	57                   	push   %edi
  800deb:	56                   	push   %esi
  800dec:	53                   	push   %ebx
  800ded:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800e00:	89 df                	mov    %ebx,%edi
  800e02:	89 de                	mov    %ebx,%esi
  800e04:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e06:	85 c0                	test   %eax,%eax
  800e08:	7e 17                	jle    800e21 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0a:	83 ec 0c             	sub    $0xc,%esp
  800e0d:	50                   	push   %eax
  800e0e:	6a 0a                	push   $0xa
  800e10:	68 3f 23 80 00       	push   $0x80233f
  800e15:	6a 23                	push   $0x23
  800e17:	68 5c 23 80 00       	push   $0x80235c
  800e1c:	e8 1a f4 ff ff       	call   80023b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2f:	be 00 00 00 00       	mov    $0x0,%esi
  800e34:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e42:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e45:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5f                   	pop    %edi
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	57                   	push   %edi
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
  800e52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e55:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e62:	89 cb                	mov    %ecx,%ebx
  800e64:	89 cf                	mov    %ecx,%edi
  800e66:	89 ce                	mov    %ecx,%esi
  800e68:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	7e 17                	jle    800e85 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6e:	83 ec 0c             	sub    $0xc,%esp
  800e71:	50                   	push   %eax
  800e72:	6a 0d                	push   $0xd
  800e74:	68 3f 23 80 00       	push   $0x80233f
  800e79:	6a 23                	push   $0x23
  800e7b:	68 5c 23 80 00       	push   $0x80235c
  800e80:	e8 b6 f3 ff ff       	call   80023b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e88:	5b                   	pop    %ebx
  800e89:	5e                   	pop    %esi
  800e8a:	5f                   	pop    %edi
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e90:	8b 45 08             	mov    0x8(%ebp),%eax
  800e93:	05 00 00 00 30       	add    $0x30000000,%eax
  800e98:	c1 e8 0c             	shr    $0xc,%eax
}
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ea0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea3:	05 00 00 00 30       	add    $0x30000000,%eax
  800ea8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ead:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eba:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ebf:	89 c2                	mov    %eax,%edx
  800ec1:	c1 ea 16             	shr    $0x16,%edx
  800ec4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ecb:	f6 c2 01             	test   $0x1,%dl
  800ece:	74 11                	je     800ee1 <fd_alloc+0x2d>
  800ed0:	89 c2                	mov    %eax,%edx
  800ed2:	c1 ea 0c             	shr    $0xc,%edx
  800ed5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800edc:	f6 c2 01             	test   $0x1,%dl
  800edf:	75 09                	jne    800eea <fd_alloc+0x36>
			*fd_store = fd;
  800ee1:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee8:	eb 17                	jmp    800f01 <fd_alloc+0x4d>
  800eea:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eef:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ef4:	75 c9                	jne    800ebf <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ef6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800efc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    

00800f03 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f09:	83 f8 1f             	cmp    $0x1f,%eax
  800f0c:	77 36                	ja     800f44 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f0e:	c1 e0 0c             	shl    $0xc,%eax
  800f11:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f16:	89 c2                	mov    %eax,%edx
  800f18:	c1 ea 16             	shr    $0x16,%edx
  800f1b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f22:	f6 c2 01             	test   $0x1,%dl
  800f25:	74 24                	je     800f4b <fd_lookup+0x48>
  800f27:	89 c2                	mov    %eax,%edx
  800f29:	c1 ea 0c             	shr    $0xc,%edx
  800f2c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f33:	f6 c2 01             	test   $0x1,%dl
  800f36:	74 1a                	je     800f52 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f38:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f3b:	89 02                	mov    %eax,(%edx)
	return 0;
  800f3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f42:	eb 13                	jmp    800f57 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f44:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f49:	eb 0c                	jmp    800f57 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f4b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f50:	eb 05                	jmp    800f57 <fd_lookup+0x54>
  800f52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    

00800f59 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	83 ec 08             	sub    $0x8,%esp
  800f5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f62:	ba ec 23 80 00       	mov    $0x8023ec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f67:	eb 13                	jmp    800f7c <dev_lookup+0x23>
  800f69:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f6c:	39 08                	cmp    %ecx,(%eax)
  800f6e:	75 0c                	jne    800f7c <dev_lookup+0x23>
			*dev = devtab[i];
  800f70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f73:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f75:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7a:	eb 2e                	jmp    800faa <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f7c:	8b 02                	mov    (%edx),%eax
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	75 e7                	jne    800f69 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f82:	a1 04 40 80 00       	mov    0x804004,%eax
  800f87:	8b 40 48             	mov    0x48(%eax),%eax
  800f8a:	83 ec 04             	sub    $0x4,%esp
  800f8d:	51                   	push   %ecx
  800f8e:	50                   	push   %eax
  800f8f:	68 6c 23 80 00       	push   $0x80236c
  800f94:	e8 7b f3 ff ff       	call   800314 <cprintf>
	*dev = 0;
  800f99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fa2:	83 c4 10             	add    $0x10,%esp
  800fa5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800faa:	c9                   	leave  
  800fab:	c3                   	ret    

00800fac <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	56                   	push   %esi
  800fb0:	53                   	push   %ebx
  800fb1:	83 ec 10             	sub    $0x10,%esp
  800fb4:	8b 75 08             	mov    0x8(%ebp),%esi
  800fb7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbd:	50                   	push   %eax
  800fbe:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fc4:	c1 e8 0c             	shr    $0xc,%eax
  800fc7:	50                   	push   %eax
  800fc8:	e8 36 ff ff ff       	call   800f03 <fd_lookup>
  800fcd:	83 c4 08             	add    $0x8,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	78 05                	js     800fd9 <fd_close+0x2d>
	    || fd != fd2)
  800fd4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fd7:	74 0c                	je     800fe5 <fd_close+0x39>
		return (must_exist ? r : 0);
  800fd9:	84 db                	test   %bl,%bl
  800fdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe0:	0f 44 c2             	cmove  %edx,%eax
  800fe3:	eb 41                	jmp    801026 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fe5:	83 ec 08             	sub    $0x8,%esp
  800fe8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800feb:	50                   	push   %eax
  800fec:	ff 36                	pushl  (%esi)
  800fee:	e8 66 ff ff ff       	call   800f59 <dev_lookup>
  800ff3:	89 c3                	mov    %eax,%ebx
  800ff5:	83 c4 10             	add    $0x10,%esp
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	78 1a                	js     801016 <fd_close+0x6a>
		if (dev->dev_close)
  800ffc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fff:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801002:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801007:	85 c0                	test   %eax,%eax
  801009:	74 0b                	je     801016 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80100b:	83 ec 0c             	sub    $0xc,%esp
  80100e:	56                   	push   %esi
  80100f:	ff d0                	call   *%eax
  801011:	89 c3                	mov    %eax,%ebx
  801013:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801016:	83 ec 08             	sub    $0x8,%esp
  801019:	56                   	push   %esi
  80101a:	6a 00                	push   $0x0
  80101c:	e8 00 fd ff ff       	call   800d21 <sys_page_unmap>
	return r;
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	89 d8                	mov    %ebx,%eax
}
  801026:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801029:	5b                   	pop    %ebx
  80102a:	5e                   	pop    %esi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    

0080102d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801033:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801036:	50                   	push   %eax
  801037:	ff 75 08             	pushl  0x8(%ebp)
  80103a:	e8 c4 fe ff ff       	call   800f03 <fd_lookup>
  80103f:	83 c4 08             	add    $0x8,%esp
  801042:	85 c0                	test   %eax,%eax
  801044:	78 10                	js     801056 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801046:	83 ec 08             	sub    $0x8,%esp
  801049:	6a 01                	push   $0x1
  80104b:	ff 75 f4             	pushl  -0xc(%ebp)
  80104e:	e8 59 ff ff ff       	call   800fac <fd_close>
  801053:	83 c4 10             	add    $0x10,%esp
}
  801056:	c9                   	leave  
  801057:	c3                   	ret    

00801058 <close_all>:

void
close_all(void)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	53                   	push   %ebx
  80105c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80105f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801064:	83 ec 0c             	sub    $0xc,%esp
  801067:	53                   	push   %ebx
  801068:	e8 c0 ff ff ff       	call   80102d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80106d:	83 c3 01             	add    $0x1,%ebx
  801070:	83 c4 10             	add    $0x10,%esp
  801073:	83 fb 20             	cmp    $0x20,%ebx
  801076:	75 ec                	jne    801064 <close_all+0xc>
		close(i);
}
  801078:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107b:	c9                   	leave  
  80107c:	c3                   	ret    

0080107d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	57                   	push   %edi
  801081:	56                   	push   %esi
  801082:	53                   	push   %ebx
  801083:	83 ec 2c             	sub    $0x2c,%esp
  801086:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801089:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80108c:	50                   	push   %eax
  80108d:	ff 75 08             	pushl  0x8(%ebp)
  801090:	e8 6e fe ff ff       	call   800f03 <fd_lookup>
  801095:	83 c4 08             	add    $0x8,%esp
  801098:	85 c0                	test   %eax,%eax
  80109a:	0f 88 c1 00 00 00    	js     801161 <dup+0xe4>
		return r;
	close(newfdnum);
  8010a0:	83 ec 0c             	sub    $0xc,%esp
  8010a3:	56                   	push   %esi
  8010a4:	e8 84 ff ff ff       	call   80102d <close>

	newfd = INDEX2FD(newfdnum);
  8010a9:	89 f3                	mov    %esi,%ebx
  8010ab:	c1 e3 0c             	shl    $0xc,%ebx
  8010ae:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010b4:	83 c4 04             	add    $0x4,%esp
  8010b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ba:	e8 de fd ff ff       	call   800e9d <fd2data>
  8010bf:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010c1:	89 1c 24             	mov    %ebx,(%esp)
  8010c4:	e8 d4 fd ff ff       	call   800e9d <fd2data>
  8010c9:	83 c4 10             	add    $0x10,%esp
  8010cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010cf:	89 f8                	mov    %edi,%eax
  8010d1:	c1 e8 16             	shr    $0x16,%eax
  8010d4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010db:	a8 01                	test   $0x1,%al
  8010dd:	74 37                	je     801116 <dup+0x99>
  8010df:	89 f8                	mov    %edi,%eax
  8010e1:	c1 e8 0c             	shr    $0xc,%eax
  8010e4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010eb:	f6 c2 01             	test   $0x1,%dl
  8010ee:	74 26                	je     801116 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010f0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f7:	83 ec 0c             	sub    $0xc,%esp
  8010fa:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ff:	50                   	push   %eax
  801100:	ff 75 d4             	pushl  -0x2c(%ebp)
  801103:	6a 00                	push   $0x0
  801105:	57                   	push   %edi
  801106:	6a 00                	push   $0x0
  801108:	e8 d2 fb ff ff       	call   800cdf <sys_page_map>
  80110d:	89 c7                	mov    %eax,%edi
  80110f:	83 c4 20             	add    $0x20,%esp
  801112:	85 c0                	test   %eax,%eax
  801114:	78 2e                	js     801144 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801116:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801119:	89 d0                	mov    %edx,%eax
  80111b:	c1 e8 0c             	shr    $0xc,%eax
  80111e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801125:	83 ec 0c             	sub    $0xc,%esp
  801128:	25 07 0e 00 00       	and    $0xe07,%eax
  80112d:	50                   	push   %eax
  80112e:	53                   	push   %ebx
  80112f:	6a 00                	push   $0x0
  801131:	52                   	push   %edx
  801132:	6a 00                	push   $0x0
  801134:	e8 a6 fb ff ff       	call   800cdf <sys_page_map>
  801139:	89 c7                	mov    %eax,%edi
  80113b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80113e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801140:	85 ff                	test   %edi,%edi
  801142:	79 1d                	jns    801161 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801144:	83 ec 08             	sub    $0x8,%esp
  801147:	53                   	push   %ebx
  801148:	6a 00                	push   $0x0
  80114a:	e8 d2 fb ff ff       	call   800d21 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80114f:	83 c4 08             	add    $0x8,%esp
  801152:	ff 75 d4             	pushl  -0x2c(%ebp)
  801155:	6a 00                	push   $0x0
  801157:	e8 c5 fb ff ff       	call   800d21 <sys_page_unmap>
	return r;
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	89 f8                	mov    %edi,%eax
}
  801161:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801164:	5b                   	pop    %ebx
  801165:	5e                   	pop    %esi
  801166:	5f                   	pop    %edi
  801167:	5d                   	pop    %ebp
  801168:	c3                   	ret    

00801169 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801169:	55                   	push   %ebp
  80116a:	89 e5                	mov    %esp,%ebp
  80116c:	53                   	push   %ebx
  80116d:	83 ec 14             	sub    $0x14,%esp
  801170:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801173:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801176:	50                   	push   %eax
  801177:	53                   	push   %ebx
  801178:	e8 86 fd ff ff       	call   800f03 <fd_lookup>
  80117d:	83 c4 08             	add    $0x8,%esp
  801180:	89 c2                	mov    %eax,%edx
  801182:	85 c0                	test   %eax,%eax
  801184:	78 6d                	js     8011f3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801186:	83 ec 08             	sub    $0x8,%esp
  801189:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118c:	50                   	push   %eax
  80118d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801190:	ff 30                	pushl  (%eax)
  801192:	e8 c2 fd ff ff       	call   800f59 <dev_lookup>
  801197:	83 c4 10             	add    $0x10,%esp
  80119a:	85 c0                	test   %eax,%eax
  80119c:	78 4c                	js     8011ea <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80119e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011a1:	8b 42 08             	mov    0x8(%edx),%eax
  8011a4:	83 e0 03             	and    $0x3,%eax
  8011a7:	83 f8 01             	cmp    $0x1,%eax
  8011aa:	75 21                	jne    8011cd <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011ac:	a1 04 40 80 00       	mov    0x804004,%eax
  8011b1:	8b 40 48             	mov    0x48(%eax),%eax
  8011b4:	83 ec 04             	sub    $0x4,%esp
  8011b7:	53                   	push   %ebx
  8011b8:	50                   	push   %eax
  8011b9:	68 b0 23 80 00       	push   $0x8023b0
  8011be:	e8 51 f1 ff ff       	call   800314 <cprintf>
		return -E_INVAL;
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011cb:	eb 26                	jmp    8011f3 <read+0x8a>
	}
	if (!dev->dev_read)
  8011cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011d0:	8b 40 08             	mov    0x8(%eax),%eax
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	74 17                	je     8011ee <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011d7:	83 ec 04             	sub    $0x4,%esp
  8011da:	ff 75 10             	pushl  0x10(%ebp)
  8011dd:	ff 75 0c             	pushl  0xc(%ebp)
  8011e0:	52                   	push   %edx
  8011e1:	ff d0                	call   *%eax
  8011e3:	89 c2                	mov    %eax,%edx
  8011e5:	83 c4 10             	add    $0x10,%esp
  8011e8:	eb 09                	jmp    8011f3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ea:	89 c2                	mov    %eax,%edx
  8011ec:	eb 05                	jmp    8011f3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011ee:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011f3:	89 d0                	mov    %edx,%eax
  8011f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f8:	c9                   	leave  
  8011f9:	c3                   	ret    

008011fa <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	57                   	push   %edi
  8011fe:	56                   	push   %esi
  8011ff:	53                   	push   %ebx
  801200:	83 ec 0c             	sub    $0xc,%esp
  801203:	8b 7d 08             	mov    0x8(%ebp),%edi
  801206:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801209:	bb 00 00 00 00       	mov    $0x0,%ebx
  80120e:	eb 21                	jmp    801231 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801210:	83 ec 04             	sub    $0x4,%esp
  801213:	89 f0                	mov    %esi,%eax
  801215:	29 d8                	sub    %ebx,%eax
  801217:	50                   	push   %eax
  801218:	89 d8                	mov    %ebx,%eax
  80121a:	03 45 0c             	add    0xc(%ebp),%eax
  80121d:	50                   	push   %eax
  80121e:	57                   	push   %edi
  80121f:	e8 45 ff ff ff       	call   801169 <read>
		if (m < 0)
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	85 c0                	test   %eax,%eax
  801229:	78 10                	js     80123b <readn+0x41>
			return m;
		if (m == 0)
  80122b:	85 c0                	test   %eax,%eax
  80122d:	74 0a                	je     801239 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80122f:	01 c3                	add    %eax,%ebx
  801231:	39 f3                	cmp    %esi,%ebx
  801233:	72 db                	jb     801210 <readn+0x16>
  801235:	89 d8                	mov    %ebx,%eax
  801237:	eb 02                	jmp    80123b <readn+0x41>
  801239:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80123b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123e:	5b                   	pop    %ebx
  80123f:	5e                   	pop    %esi
  801240:	5f                   	pop    %edi
  801241:	5d                   	pop    %ebp
  801242:	c3                   	ret    

00801243 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	53                   	push   %ebx
  801247:	83 ec 14             	sub    $0x14,%esp
  80124a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801250:	50                   	push   %eax
  801251:	53                   	push   %ebx
  801252:	e8 ac fc ff ff       	call   800f03 <fd_lookup>
  801257:	83 c4 08             	add    $0x8,%esp
  80125a:	89 c2                	mov    %eax,%edx
  80125c:	85 c0                	test   %eax,%eax
  80125e:	78 68                	js     8012c8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801260:	83 ec 08             	sub    $0x8,%esp
  801263:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801266:	50                   	push   %eax
  801267:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126a:	ff 30                	pushl  (%eax)
  80126c:	e8 e8 fc ff ff       	call   800f59 <dev_lookup>
  801271:	83 c4 10             	add    $0x10,%esp
  801274:	85 c0                	test   %eax,%eax
  801276:	78 47                	js     8012bf <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801278:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80127f:	75 21                	jne    8012a2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801281:	a1 04 40 80 00       	mov    0x804004,%eax
  801286:	8b 40 48             	mov    0x48(%eax),%eax
  801289:	83 ec 04             	sub    $0x4,%esp
  80128c:	53                   	push   %ebx
  80128d:	50                   	push   %eax
  80128e:	68 cc 23 80 00       	push   $0x8023cc
  801293:	e8 7c f0 ff ff       	call   800314 <cprintf>
		return -E_INVAL;
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012a0:	eb 26                	jmp    8012c8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a5:	8b 52 0c             	mov    0xc(%edx),%edx
  8012a8:	85 d2                	test   %edx,%edx
  8012aa:	74 17                	je     8012c3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012ac:	83 ec 04             	sub    $0x4,%esp
  8012af:	ff 75 10             	pushl  0x10(%ebp)
  8012b2:	ff 75 0c             	pushl  0xc(%ebp)
  8012b5:	50                   	push   %eax
  8012b6:	ff d2                	call   *%edx
  8012b8:	89 c2                	mov    %eax,%edx
  8012ba:	83 c4 10             	add    $0x10,%esp
  8012bd:	eb 09                	jmp    8012c8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bf:	89 c2                	mov    %eax,%edx
  8012c1:	eb 05                	jmp    8012c8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012c3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012c8:	89 d0                	mov    %edx,%eax
  8012ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012cd:	c9                   	leave  
  8012ce:	c3                   	ret    

008012cf <seek>:

int
seek(int fdnum, off_t offset)
{
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012d5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012d8:	50                   	push   %eax
  8012d9:	ff 75 08             	pushl  0x8(%ebp)
  8012dc:	e8 22 fc ff ff       	call   800f03 <fd_lookup>
  8012e1:	83 c4 08             	add    $0x8,%esp
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	78 0e                	js     8012f6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ee:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012f6:	c9                   	leave  
  8012f7:	c3                   	ret    

008012f8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	53                   	push   %ebx
  8012fc:	83 ec 14             	sub    $0x14,%esp
  8012ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801302:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801305:	50                   	push   %eax
  801306:	53                   	push   %ebx
  801307:	e8 f7 fb ff ff       	call   800f03 <fd_lookup>
  80130c:	83 c4 08             	add    $0x8,%esp
  80130f:	89 c2                	mov    %eax,%edx
  801311:	85 c0                	test   %eax,%eax
  801313:	78 65                	js     80137a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801315:	83 ec 08             	sub    $0x8,%esp
  801318:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131b:	50                   	push   %eax
  80131c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131f:	ff 30                	pushl  (%eax)
  801321:	e8 33 fc ff ff       	call   800f59 <dev_lookup>
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	85 c0                	test   %eax,%eax
  80132b:	78 44                	js     801371 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80132d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801330:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801334:	75 21                	jne    801357 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801336:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80133b:	8b 40 48             	mov    0x48(%eax),%eax
  80133e:	83 ec 04             	sub    $0x4,%esp
  801341:	53                   	push   %ebx
  801342:	50                   	push   %eax
  801343:	68 8c 23 80 00       	push   $0x80238c
  801348:	e8 c7 ef ff ff       	call   800314 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80134d:	83 c4 10             	add    $0x10,%esp
  801350:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801355:	eb 23                	jmp    80137a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801357:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80135a:	8b 52 18             	mov    0x18(%edx),%edx
  80135d:	85 d2                	test   %edx,%edx
  80135f:	74 14                	je     801375 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801361:	83 ec 08             	sub    $0x8,%esp
  801364:	ff 75 0c             	pushl  0xc(%ebp)
  801367:	50                   	push   %eax
  801368:	ff d2                	call   *%edx
  80136a:	89 c2                	mov    %eax,%edx
  80136c:	83 c4 10             	add    $0x10,%esp
  80136f:	eb 09                	jmp    80137a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801371:	89 c2                	mov    %eax,%edx
  801373:	eb 05                	jmp    80137a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801375:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80137a:	89 d0                	mov    %edx,%eax
  80137c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137f:	c9                   	leave  
  801380:	c3                   	ret    

00801381 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	53                   	push   %ebx
  801385:	83 ec 14             	sub    $0x14,%esp
  801388:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80138b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138e:	50                   	push   %eax
  80138f:	ff 75 08             	pushl  0x8(%ebp)
  801392:	e8 6c fb ff ff       	call   800f03 <fd_lookup>
  801397:	83 c4 08             	add    $0x8,%esp
  80139a:	89 c2                	mov    %eax,%edx
  80139c:	85 c0                	test   %eax,%eax
  80139e:	78 58                	js     8013f8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a0:	83 ec 08             	sub    $0x8,%esp
  8013a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a6:	50                   	push   %eax
  8013a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013aa:	ff 30                	pushl  (%eax)
  8013ac:	e8 a8 fb ff ff       	call   800f59 <dev_lookup>
  8013b1:	83 c4 10             	add    $0x10,%esp
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	78 37                	js     8013ef <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013bb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013bf:	74 32                	je     8013f3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013c1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013c4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013cb:	00 00 00 
	stat->st_isdir = 0;
  8013ce:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013d5:	00 00 00 
	stat->st_dev = dev;
  8013d8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013de:	83 ec 08             	sub    $0x8,%esp
  8013e1:	53                   	push   %ebx
  8013e2:	ff 75 f0             	pushl  -0x10(%ebp)
  8013e5:	ff 50 14             	call   *0x14(%eax)
  8013e8:	89 c2                	mov    %eax,%edx
  8013ea:	83 c4 10             	add    $0x10,%esp
  8013ed:	eb 09                	jmp    8013f8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ef:	89 c2                	mov    %eax,%edx
  8013f1:	eb 05                	jmp    8013f8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013f3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013f8:	89 d0                	mov    %edx,%eax
  8013fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fd:	c9                   	leave  
  8013fe:	c3                   	ret    

008013ff <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013ff:	55                   	push   %ebp
  801400:	89 e5                	mov    %esp,%ebp
  801402:	56                   	push   %esi
  801403:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	6a 00                	push   $0x0
  801409:	ff 75 08             	pushl  0x8(%ebp)
  80140c:	e8 0c 02 00 00       	call   80161d <open>
  801411:	89 c3                	mov    %eax,%ebx
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	85 c0                	test   %eax,%eax
  801418:	78 1b                	js     801435 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80141a:	83 ec 08             	sub    $0x8,%esp
  80141d:	ff 75 0c             	pushl  0xc(%ebp)
  801420:	50                   	push   %eax
  801421:	e8 5b ff ff ff       	call   801381 <fstat>
  801426:	89 c6                	mov    %eax,%esi
	close(fd);
  801428:	89 1c 24             	mov    %ebx,(%esp)
  80142b:	e8 fd fb ff ff       	call   80102d <close>
	return r;
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	89 f0                	mov    %esi,%eax
}
  801435:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801438:	5b                   	pop    %ebx
  801439:	5e                   	pop    %esi
  80143a:	5d                   	pop    %ebp
  80143b:	c3                   	ret    

0080143c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	56                   	push   %esi
  801440:	53                   	push   %ebx
  801441:	89 c6                	mov    %eax,%esi
  801443:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801445:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80144c:	75 12                	jne    801460 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80144e:	83 ec 0c             	sub    $0xc,%esp
  801451:	6a 01                	push   $0x1
  801453:	e8 05 08 00 00       	call   801c5d <ipc_find_env>
  801458:	a3 00 40 80 00       	mov    %eax,0x804000
  80145d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801460:	6a 07                	push   $0x7
  801462:	68 00 50 80 00       	push   $0x805000
  801467:	56                   	push   %esi
  801468:	ff 35 00 40 80 00    	pushl  0x804000
  80146e:	e8 96 07 00 00       	call   801c09 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801473:	83 c4 0c             	add    $0xc,%esp
  801476:	6a 00                	push   $0x0
  801478:	53                   	push   %ebx
  801479:	6a 00                	push   $0x0
  80147b:	e8 20 07 00 00       	call   801ba0 <ipc_recv>
}
  801480:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801483:	5b                   	pop    %ebx
  801484:	5e                   	pop    %esi
  801485:	5d                   	pop    %ebp
  801486:	c3                   	ret    

00801487 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801487:	55                   	push   %ebp
  801488:	89 e5                	mov    %esp,%ebp
  80148a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80148d:	8b 45 08             	mov    0x8(%ebp),%eax
  801490:	8b 40 0c             	mov    0xc(%eax),%eax
  801493:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801498:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a5:	b8 02 00 00 00       	mov    $0x2,%eax
  8014aa:	e8 8d ff ff ff       	call   80143c <fsipc>
}
  8014af:	c9                   	leave  
  8014b0:	c3                   	ret    

008014b1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014b1:	55                   	push   %ebp
  8014b2:	89 e5                	mov    %esp,%ebp
  8014b4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8014bd:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c7:	b8 06 00 00 00       	mov    $0x6,%eax
  8014cc:	e8 6b ff ff ff       	call   80143c <fsipc>
}
  8014d1:	c9                   	leave  
  8014d2:	c3                   	ret    

008014d3 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014d3:	55                   	push   %ebp
  8014d4:	89 e5                	mov    %esp,%ebp
  8014d6:	53                   	push   %ebx
  8014d7:	83 ec 04             	sub    $0x4,%esp
  8014da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e0:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ed:	b8 05 00 00 00       	mov    $0x5,%eax
  8014f2:	e8 45 ff ff ff       	call   80143c <fsipc>
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	78 2c                	js     801527 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014fb:	83 ec 08             	sub    $0x8,%esp
  8014fe:	68 00 50 80 00       	push   $0x805000
  801503:	53                   	push   %ebx
  801504:	e8 90 f3 ff ff       	call   800899 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801509:	a1 80 50 80 00       	mov    0x805080,%eax
  80150e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801514:	a1 84 50 80 00       	mov    0x805084,%eax
  801519:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80151f:	83 c4 10             	add    $0x10,%esp
  801522:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801527:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152a:	c9                   	leave  
  80152b:	c3                   	ret    

0080152c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
  80152f:	53                   	push   %ebx
  801530:	83 ec 08             	sub    $0x8,%esp
  801533:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801536:	8b 55 08             	mov    0x8(%ebp),%edx
  801539:	8b 52 0c             	mov    0xc(%edx),%edx
  80153c:	89 15 00 50 80 00    	mov    %edx,0x805000
  801542:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801547:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80154c:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  80154f:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801555:	53                   	push   %ebx
  801556:	ff 75 0c             	pushl  0xc(%ebp)
  801559:	68 08 50 80 00       	push   $0x805008
  80155e:	e8 c8 f4 ff ff       	call   800a2b <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  801563:	ba 00 00 00 00       	mov    $0x0,%edx
  801568:	b8 04 00 00 00       	mov    $0x4,%eax
  80156d:	e8 ca fe ff ff       	call   80143c <fsipc>
  801572:	83 c4 10             	add    $0x10,%esp
  801575:	85 c0                	test   %eax,%eax
  801577:	78 1d                	js     801596 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  801579:	39 d8                	cmp    %ebx,%eax
  80157b:	76 19                	jbe    801596 <devfile_write+0x6a>
  80157d:	68 fc 23 80 00       	push   $0x8023fc
  801582:	68 08 24 80 00       	push   $0x802408
  801587:	68 a5 00 00 00       	push   $0xa5
  80158c:	68 1d 24 80 00       	push   $0x80241d
  801591:	e8 a5 ec ff ff       	call   80023b <_panic>
	return r;
}
  801596:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801599:	c9                   	leave  
  80159a:	c3                   	ret    

0080159b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80159b:	55                   	push   %ebp
  80159c:	89 e5                	mov    %esp,%ebp
  80159e:	56                   	push   %esi
  80159f:	53                   	push   %ebx
  8015a0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a6:	8b 40 0c             	mov    0xc(%eax),%eax
  8015a9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015ae:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b9:	b8 03 00 00 00       	mov    $0x3,%eax
  8015be:	e8 79 fe ff ff       	call   80143c <fsipc>
  8015c3:	89 c3                	mov    %eax,%ebx
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	78 4b                	js     801614 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015c9:	39 c6                	cmp    %eax,%esi
  8015cb:	73 16                	jae    8015e3 <devfile_read+0x48>
  8015cd:	68 28 24 80 00       	push   $0x802428
  8015d2:	68 08 24 80 00       	push   $0x802408
  8015d7:	6a 7c                	push   $0x7c
  8015d9:	68 1d 24 80 00       	push   $0x80241d
  8015de:	e8 58 ec ff ff       	call   80023b <_panic>
	assert(r <= PGSIZE);
  8015e3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015e8:	7e 16                	jle    801600 <devfile_read+0x65>
  8015ea:	68 2f 24 80 00       	push   $0x80242f
  8015ef:	68 08 24 80 00       	push   $0x802408
  8015f4:	6a 7d                	push   $0x7d
  8015f6:	68 1d 24 80 00       	push   $0x80241d
  8015fb:	e8 3b ec ff ff       	call   80023b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801600:	83 ec 04             	sub    $0x4,%esp
  801603:	50                   	push   %eax
  801604:	68 00 50 80 00       	push   $0x805000
  801609:	ff 75 0c             	pushl  0xc(%ebp)
  80160c:	e8 1a f4 ff ff       	call   800a2b <memmove>
	return r;
  801611:	83 c4 10             	add    $0x10,%esp
}
  801614:	89 d8                	mov    %ebx,%eax
  801616:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801619:	5b                   	pop    %ebx
  80161a:	5e                   	pop    %esi
  80161b:	5d                   	pop    %ebp
  80161c:	c3                   	ret    

0080161d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	53                   	push   %ebx
  801621:	83 ec 20             	sub    $0x20,%esp
  801624:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801627:	53                   	push   %ebx
  801628:	e8 33 f2 ff ff       	call   800860 <strlen>
  80162d:	83 c4 10             	add    $0x10,%esp
  801630:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801635:	7f 67                	jg     80169e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801637:	83 ec 0c             	sub    $0xc,%esp
  80163a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80163d:	50                   	push   %eax
  80163e:	e8 71 f8 ff ff       	call   800eb4 <fd_alloc>
  801643:	83 c4 10             	add    $0x10,%esp
		return r;
  801646:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801648:	85 c0                	test   %eax,%eax
  80164a:	78 57                	js     8016a3 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80164c:	83 ec 08             	sub    $0x8,%esp
  80164f:	53                   	push   %ebx
  801650:	68 00 50 80 00       	push   $0x805000
  801655:	e8 3f f2 ff ff       	call   800899 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80165a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80165d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801662:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801665:	b8 01 00 00 00       	mov    $0x1,%eax
  80166a:	e8 cd fd ff ff       	call   80143c <fsipc>
  80166f:	89 c3                	mov    %eax,%ebx
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	85 c0                	test   %eax,%eax
  801676:	79 14                	jns    80168c <open+0x6f>
		fd_close(fd, 0);
  801678:	83 ec 08             	sub    $0x8,%esp
  80167b:	6a 00                	push   $0x0
  80167d:	ff 75 f4             	pushl  -0xc(%ebp)
  801680:	e8 27 f9 ff ff       	call   800fac <fd_close>
		return r;
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	89 da                	mov    %ebx,%edx
  80168a:	eb 17                	jmp    8016a3 <open+0x86>
	}

	return fd2num(fd);
  80168c:	83 ec 0c             	sub    $0xc,%esp
  80168f:	ff 75 f4             	pushl  -0xc(%ebp)
  801692:	e8 f6 f7 ff ff       	call   800e8d <fd2num>
  801697:	89 c2                	mov    %eax,%edx
  801699:	83 c4 10             	add    $0x10,%esp
  80169c:	eb 05                	jmp    8016a3 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80169e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016a3:	89 d0                	mov    %edx,%eax
  8016a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a8:	c9                   	leave  
  8016a9:	c3                   	ret    

008016aa <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b5:	b8 08 00 00 00       	mov    $0x8,%eax
  8016ba:	e8 7d fd ff ff       	call   80143c <fsipc>
}
  8016bf:	c9                   	leave  
  8016c0:	c3                   	ret    

008016c1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	56                   	push   %esi
  8016c5:	53                   	push   %ebx
  8016c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016c9:	83 ec 0c             	sub    $0xc,%esp
  8016cc:	ff 75 08             	pushl  0x8(%ebp)
  8016cf:	e8 c9 f7 ff ff       	call   800e9d <fd2data>
  8016d4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016d6:	83 c4 08             	add    $0x8,%esp
  8016d9:	68 3b 24 80 00       	push   $0x80243b
  8016de:	53                   	push   %ebx
  8016df:	e8 b5 f1 ff ff       	call   800899 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016e4:	8b 46 04             	mov    0x4(%esi),%eax
  8016e7:	2b 06                	sub    (%esi),%eax
  8016e9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016ef:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016f6:	00 00 00 
	stat->st_dev = &devpipe;
  8016f9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801700:	30 80 00 
	return 0;
}
  801703:	b8 00 00 00 00       	mov    $0x0,%eax
  801708:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80170b:	5b                   	pop    %ebx
  80170c:	5e                   	pop    %esi
  80170d:	5d                   	pop    %ebp
  80170e:	c3                   	ret    

0080170f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	53                   	push   %ebx
  801713:	83 ec 0c             	sub    $0xc,%esp
  801716:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801719:	53                   	push   %ebx
  80171a:	6a 00                	push   $0x0
  80171c:	e8 00 f6 ff ff       	call   800d21 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801721:	89 1c 24             	mov    %ebx,(%esp)
  801724:	e8 74 f7 ff ff       	call   800e9d <fd2data>
  801729:	83 c4 08             	add    $0x8,%esp
  80172c:	50                   	push   %eax
  80172d:	6a 00                	push   $0x0
  80172f:	e8 ed f5 ff ff       	call   800d21 <sys_page_unmap>
}
  801734:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801737:	c9                   	leave  
  801738:	c3                   	ret    

00801739 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	57                   	push   %edi
  80173d:	56                   	push   %esi
  80173e:	53                   	push   %ebx
  80173f:	83 ec 1c             	sub    $0x1c,%esp
  801742:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801745:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801747:	a1 04 40 80 00       	mov    0x804004,%eax
  80174c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80174f:	83 ec 0c             	sub    $0xc,%esp
  801752:	ff 75 e0             	pushl  -0x20(%ebp)
  801755:	e8 3c 05 00 00       	call   801c96 <pageref>
  80175a:	89 c3                	mov    %eax,%ebx
  80175c:	89 3c 24             	mov    %edi,(%esp)
  80175f:	e8 32 05 00 00       	call   801c96 <pageref>
  801764:	83 c4 10             	add    $0x10,%esp
  801767:	39 c3                	cmp    %eax,%ebx
  801769:	0f 94 c1             	sete   %cl
  80176c:	0f b6 c9             	movzbl %cl,%ecx
  80176f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801772:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801778:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80177b:	39 ce                	cmp    %ecx,%esi
  80177d:	74 1b                	je     80179a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80177f:	39 c3                	cmp    %eax,%ebx
  801781:	75 c4                	jne    801747 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801783:	8b 42 58             	mov    0x58(%edx),%eax
  801786:	ff 75 e4             	pushl  -0x1c(%ebp)
  801789:	50                   	push   %eax
  80178a:	56                   	push   %esi
  80178b:	68 42 24 80 00       	push   $0x802442
  801790:	e8 7f eb ff ff       	call   800314 <cprintf>
  801795:	83 c4 10             	add    $0x10,%esp
  801798:	eb ad                	jmp    801747 <_pipeisclosed+0xe>
	}
}
  80179a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80179d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017a0:	5b                   	pop    %ebx
  8017a1:	5e                   	pop    %esi
  8017a2:	5f                   	pop    %edi
  8017a3:	5d                   	pop    %ebp
  8017a4:	c3                   	ret    

008017a5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	57                   	push   %edi
  8017a9:	56                   	push   %esi
  8017aa:	53                   	push   %ebx
  8017ab:	83 ec 28             	sub    $0x28,%esp
  8017ae:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8017b1:	56                   	push   %esi
  8017b2:	e8 e6 f6 ff ff       	call   800e9d <fd2data>
  8017b7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017b9:	83 c4 10             	add    $0x10,%esp
  8017bc:	bf 00 00 00 00       	mov    $0x0,%edi
  8017c1:	eb 4b                	jmp    80180e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8017c3:	89 da                	mov    %ebx,%edx
  8017c5:	89 f0                	mov    %esi,%eax
  8017c7:	e8 6d ff ff ff       	call   801739 <_pipeisclosed>
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	75 48                	jne    801818 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8017d0:	e8 a8 f4 ff ff       	call   800c7d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017d5:	8b 43 04             	mov    0x4(%ebx),%eax
  8017d8:	8b 0b                	mov    (%ebx),%ecx
  8017da:	8d 51 20             	lea    0x20(%ecx),%edx
  8017dd:	39 d0                	cmp    %edx,%eax
  8017df:	73 e2                	jae    8017c3 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017e4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017e8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017eb:	89 c2                	mov    %eax,%edx
  8017ed:	c1 fa 1f             	sar    $0x1f,%edx
  8017f0:	89 d1                	mov    %edx,%ecx
  8017f2:	c1 e9 1b             	shr    $0x1b,%ecx
  8017f5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017f8:	83 e2 1f             	and    $0x1f,%edx
  8017fb:	29 ca                	sub    %ecx,%edx
  8017fd:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801801:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801805:	83 c0 01             	add    $0x1,%eax
  801808:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80180b:	83 c7 01             	add    $0x1,%edi
  80180e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801811:	75 c2                	jne    8017d5 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801813:	8b 45 10             	mov    0x10(%ebp),%eax
  801816:	eb 05                	jmp    80181d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801818:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80181d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801820:	5b                   	pop    %ebx
  801821:	5e                   	pop    %esi
  801822:	5f                   	pop    %edi
  801823:	5d                   	pop    %ebp
  801824:	c3                   	ret    

00801825 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801825:	55                   	push   %ebp
  801826:	89 e5                	mov    %esp,%ebp
  801828:	57                   	push   %edi
  801829:	56                   	push   %esi
  80182a:	53                   	push   %ebx
  80182b:	83 ec 18             	sub    $0x18,%esp
  80182e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801831:	57                   	push   %edi
  801832:	e8 66 f6 ff ff       	call   800e9d <fd2data>
  801837:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801839:	83 c4 10             	add    $0x10,%esp
  80183c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801841:	eb 3d                	jmp    801880 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801843:	85 db                	test   %ebx,%ebx
  801845:	74 04                	je     80184b <devpipe_read+0x26>
				return i;
  801847:	89 d8                	mov    %ebx,%eax
  801849:	eb 44                	jmp    80188f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80184b:	89 f2                	mov    %esi,%edx
  80184d:	89 f8                	mov    %edi,%eax
  80184f:	e8 e5 fe ff ff       	call   801739 <_pipeisclosed>
  801854:	85 c0                	test   %eax,%eax
  801856:	75 32                	jne    80188a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801858:	e8 20 f4 ff ff       	call   800c7d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80185d:	8b 06                	mov    (%esi),%eax
  80185f:	3b 46 04             	cmp    0x4(%esi),%eax
  801862:	74 df                	je     801843 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801864:	99                   	cltd   
  801865:	c1 ea 1b             	shr    $0x1b,%edx
  801868:	01 d0                	add    %edx,%eax
  80186a:	83 e0 1f             	and    $0x1f,%eax
  80186d:	29 d0                	sub    %edx,%eax
  80186f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801874:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801877:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80187a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80187d:	83 c3 01             	add    $0x1,%ebx
  801880:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801883:	75 d8                	jne    80185d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801885:	8b 45 10             	mov    0x10(%ebp),%eax
  801888:	eb 05                	jmp    80188f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80188a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80188f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801892:	5b                   	pop    %ebx
  801893:	5e                   	pop    %esi
  801894:	5f                   	pop    %edi
  801895:	5d                   	pop    %ebp
  801896:	c3                   	ret    

00801897 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801897:	55                   	push   %ebp
  801898:	89 e5                	mov    %esp,%ebp
  80189a:	56                   	push   %esi
  80189b:	53                   	push   %ebx
  80189c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80189f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a2:	50                   	push   %eax
  8018a3:	e8 0c f6 ff ff       	call   800eb4 <fd_alloc>
  8018a8:	83 c4 10             	add    $0x10,%esp
  8018ab:	89 c2                	mov    %eax,%edx
  8018ad:	85 c0                	test   %eax,%eax
  8018af:	0f 88 2c 01 00 00    	js     8019e1 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018b5:	83 ec 04             	sub    $0x4,%esp
  8018b8:	68 07 04 00 00       	push   $0x407
  8018bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c0:	6a 00                	push   $0x0
  8018c2:	e8 d5 f3 ff ff       	call   800c9c <sys_page_alloc>
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	89 c2                	mov    %eax,%edx
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	0f 88 0d 01 00 00    	js     8019e1 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8018d4:	83 ec 0c             	sub    $0xc,%esp
  8018d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018da:	50                   	push   %eax
  8018db:	e8 d4 f5 ff ff       	call   800eb4 <fd_alloc>
  8018e0:	89 c3                	mov    %eax,%ebx
  8018e2:	83 c4 10             	add    $0x10,%esp
  8018e5:	85 c0                	test   %eax,%eax
  8018e7:	0f 88 e2 00 00 00    	js     8019cf <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ed:	83 ec 04             	sub    $0x4,%esp
  8018f0:	68 07 04 00 00       	push   $0x407
  8018f5:	ff 75 f0             	pushl  -0x10(%ebp)
  8018f8:	6a 00                	push   $0x0
  8018fa:	e8 9d f3 ff ff       	call   800c9c <sys_page_alloc>
  8018ff:	89 c3                	mov    %eax,%ebx
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	85 c0                	test   %eax,%eax
  801906:	0f 88 c3 00 00 00    	js     8019cf <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80190c:	83 ec 0c             	sub    $0xc,%esp
  80190f:	ff 75 f4             	pushl  -0xc(%ebp)
  801912:	e8 86 f5 ff ff       	call   800e9d <fd2data>
  801917:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801919:	83 c4 0c             	add    $0xc,%esp
  80191c:	68 07 04 00 00       	push   $0x407
  801921:	50                   	push   %eax
  801922:	6a 00                	push   $0x0
  801924:	e8 73 f3 ff ff       	call   800c9c <sys_page_alloc>
  801929:	89 c3                	mov    %eax,%ebx
  80192b:	83 c4 10             	add    $0x10,%esp
  80192e:	85 c0                	test   %eax,%eax
  801930:	0f 88 89 00 00 00    	js     8019bf <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801936:	83 ec 0c             	sub    $0xc,%esp
  801939:	ff 75 f0             	pushl  -0x10(%ebp)
  80193c:	e8 5c f5 ff ff       	call   800e9d <fd2data>
  801941:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801948:	50                   	push   %eax
  801949:	6a 00                	push   $0x0
  80194b:	56                   	push   %esi
  80194c:	6a 00                	push   $0x0
  80194e:	e8 8c f3 ff ff       	call   800cdf <sys_page_map>
  801953:	89 c3                	mov    %eax,%ebx
  801955:	83 c4 20             	add    $0x20,%esp
  801958:	85 c0                	test   %eax,%eax
  80195a:	78 55                	js     8019b1 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80195c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801962:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801965:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801967:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80196a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801971:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801977:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80197a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80197c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80197f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801986:	83 ec 0c             	sub    $0xc,%esp
  801989:	ff 75 f4             	pushl  -0xc(%ebp)
  80198c:	e8 fc f4 ff ff       	call   800e8d <fd2num>
  801991:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801994:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801996:	83 c4 04             	add    $0x4,%esp
  801999:	ff 75 f0             	pushl  -0x10(%ebp)
  80199c:	e8 ec f4 ff ff       	call   800e8d <fd2num>
  8019a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019a4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8019a7:	83 c4 10             	add    $0x10,%esp
  8019aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8019af:	eb 30                	jmp    8019e1 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8019b1:	83 ec 08             	sub    $0x8,%esp
  8019b4:	56                   	push   %esi
  8019b5:	6a 00                	push   $0x0
  8019b7:	e8 65 f3 ff ff       	call   800d21 <sys_page_unmap>
  8019bc:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8019bf:	83 ec 08             	sub    $0x8,%esp
  8019c2:	ff 75 f0             	pushl  -0x10(%ebp)
  8019c5:	6a 00                	push   $0x0
  8019c7:	e8 55 f3 ff ff       	call   800d21 <sys_page_unmap>
  8019cc:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8019cf:	83 ec 08             	sub    $0x8,%esp
  8019d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d5:	6a 00                	push   $0x0
  8019d7:	e8 45 f3 ff ff       	call   800d21 <sys_page_unmap>
  8019dc:	83 c4 10             	add    $0x10,%esp
  8019df:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8019e1:	89 d0                	mov    %edx,%eax
  8019e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e6:	5b                   	pop    %ebx
  8019e7:	5e                   	pop    %esi
  8019e8:	5d                   	pop    %ebp
  8019e9:	c3                   	ret    

008019ea <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f3:	50                   	push   %eax
  8019f4:	ff 75 08             	pushl  0x8(%ebp)
  8019f7:	e8 07 f5 ff ff       	call   800f03 <fd_lookup>
  8019fc:	83 c4 10             	add    $0x10,%esp
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	78 18                	js     801a1b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a03:	83 ec 0c             	sub    $0xc,%esp
  801a06:	ff 75 f4             	pushl  -0xc(%ebp)
  801a09:	e8 8f f4 ff ff       	call   800e9d <fd2data>
	return _pipeisclosed(fd, p);
  801a0e:	89 c2                	mov    %eax,%edx
  801a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a13:	e8 21 fd ff ff       	call   801739 <_pipeisclosed>
  801a18:	83 c4 10             	add    $0x10,%esp
}
  801a1b:	c9                   	leave  
  801a1c:	c3                   	ret    

00801a1d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a20:	b8 00 00 00 00       	mov    $0x0,%eax
  801a25:	5d                   	pop    %ebp
  801a26:	c3                   	ret    

00801a27 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a2d:	68 5a 24 80 00       	push   $0x80245a
  801a32:	ff 75 0c             	pushl  0xc(%ebp)
  801a35:	e8 5f ee ff ff       	call   800899 <strcpy>
	return 0;
}
  801a3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a3f:	c9                   	leave  
  801a40:	c3                   	ret    

00801a41 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	57                   	push   %edi
  801a45:	56                   	push   %esi
  801a46:	53                   	push   %ebx
  801a47:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a4d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a52:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a58:	eb 2d                	jmp    801a87 <devcons_write+0x46>
		m = n - tot;
  801a5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a5d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801a5f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a62:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a67:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a6a:	83 ec 04             	sub    $0x4,%esp
  801a6d:	53                   	push   %ebx
  801a6e:	03 45 0c             	add    0xc(%ebp),%eax
  801a71:	50                   	push   %eax
  801a72:	57                   	push   %edi
  801a73:	e8 b3 ef ff ff       	call   800a2b <memmove>
		sys_cputs(buf, m);
  801a78:	83 c4 08             	add    $0x8,%esp
  801a7b:	53                   	push   %ebx
  801a7c:	57                   	push   %edi
  801a7d:	e8 5e f1 ff ff       	call   800be0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a82:	01 de                	add    %ebx,%esi
  801a84:	83 c4 10             	add    $0x10,%esp
  801a87:	89 f0                	mov    %esi,%eax
  801a89:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a8c:	72 cc                	jb     801a5a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a91:	5b                   	pop    %ebx
  801a92:	5e                   	pop    %esi
  801a93:	5f                   	pop    %edi
  801a94:	5d                   	pop    %ebp
  801a95:	c3                   	ret    

00801a96 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a96:	55                   	push   %ebp
  801a97:	89 e5                	mov    %esp,%ebp
  801a99:	83 ec 08             	sub    $0x8,%esp
  801a9c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801aa1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801aa5:	74 2a                	je     801ad1 <devcons_read+0x3b>
  801aa7:	eb 05                	jmp    801aae <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801aa9:	e8 cf f1 ff ff       	call   800c7d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801aae:	e8 4b f1 ff ff       	call   800bfe <sys_cgetc>
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	74 f2                	je     801aa9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ab7:	85 c0                	test   %eax,%eax
  801ab9:	78 16                	js     801ad1 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801abb:	83 f8 04             	cmp    $0x4,%eax
  801abe:	74 0c                	je     801acc <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ac0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ac3:	88 02                	mov    %al,(%edx)
	return 1;
  801ac5:	b8 01 00 00 00       	mov    $0x1,%eax
  801aca:	eb 05                	jmp    801ad1 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801acc:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ad1:	c9                   	leave  
  801ad2:	c3                   	ret    

00801ad3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  801adc:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801adf:	6a 01                	push   $0x1
  801ae1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ae4:	50                   	push   %eax
  801ae5:	e8 f6 f0 ff ff       	call   800be0 <sys_cputs>
}
  801aea:	83 c4 10             	add    $0x10,%esp
  801aed:	c9                   	leave  
  801aee:	c3                   	ret    

00801aef <getchar>:

int
getchar(void)
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801af5:	6a 01                	push   $0x1
  801af7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801afa:	50                   	push   %eax
  801afb:	6a 00                	push   $0x0
  801afd:	e8 67 f6 ff ff       	call   801169 <read>
	if (r < 0)
  801b02:	83 c4 10             	add    $0x10,%esp
  801b05:	85 c0                	test   %eax,%eax
  801b07:	78 0f                	js     801b18 <getchar+0x29>
		return r;
	if (r < 1)
  801b09:	85 c0                	test   %eax,%eax
  801b0b:	7e 06                	jle    801b13 <getchar+0x24>
		return -E_EOF;
	return c;
  801b0d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b11:	eb 05                	jmp    801b18 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b13:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b18:	c9                   	leave  
  801b19:	c3                   	ret    

00801b1a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b23:	50                   	push   %eax
  801b24:	ff 75 08             	pushl  0x8(%ebp)
  801b27:	e8 d7 f3 ff ff       	call   800f03 <fd_lookup>
  801b2c:	83 c4 10             	add    $0x10,%esp
  801b2f:	85 c0                	test   %eax,%eax
  801b31:	78 11                	js     801b44 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b36:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b3c:	39 10                	cmp    %edx,(%eax)
  801b3e:	0f 94 c0             	sete   %al
  801b41:	0f b6 c0             	movzbl %al,%eax
}
  801b44:	c9                   	leave  
  801b45:	c3                   	ret    

00801b46 <opencons>:

int
opencons(void)
{
  801b46:	55                   	push   %ebp
  801b47:	89 e5                	mov    %esp,%ebp
  801b49:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b4f:	50                   	push   %eax
  801b50:	e8 5f f3 ff ff       	call   800eb4 <fd_alloc>
  801b55:	83 c4 10             	add    $0x10,%esp
		return r;
  801b58:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b5a:	85 c0                	test   %eax,%eax
  801b5c:	78 3e                	js     801b9c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b5e:	83 ec 04             	sub    $0x4,%esp
  801b61:	68 07 04 00 00       	push   $0x407
  801b66:	ff 75 f4             	pushl  -0xc(%ebp)
  801b69:	6a 00                	push   $0x0
  801b6b:	e8 2c f1 ff ff       	call   800c9c <sys_page_alloc>
  801b70:	83 c4 10             	add    $0x10,%esp
		return r;
  801b73:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b75:	85 c0                	test   %eax,%eax
  801b77:	78 23                	js     801b9c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b79:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b82:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b87:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b8e:	83 ec 0c             	sub    $0xc,%esp
  801b91:	50                   	push   %eax
  801b92:	e8 f6 f2 ff ff       	call   800e8d <fd2num>
  801b97:	89 c2                	mov    %eax,%edx
  801b99:	83 c4 10             	add    $0x10,%esp
}
  801b9c:	89 d0                	mov    %edx,%eax
  801b9e:	c9                   	leave  
  801b9f:	c3                   	ret    

00801ba0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	56                   	push   %esi
  801ba4:	53                   	push   %ebx
  801ba5:	8b 75 08             	mov    0x8(%ebp),%esi
  801ba8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801bae:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801bb0:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801bb5:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801bb8:	83 ec 0c             	sub    $0xc,%esp
  801bbb:	50                   	push   %eax
  801bbc:	e8 8b f2 ff ff       	call   800e4c <sys_ipc_recv>

	if (r < 0) {
  801bc1:	83 c4 10             	add    $0x10,%esp
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	79 16                	jns    801bde <ipc_recv+0x3e>
		if (from_env_store)
  801bc8:	85 f6                	test   %esi,%esi
  801bca:	74 06                	je     801bd2 <ipc_recv+0x32>
			*from_env_store = 0;
  801bcc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801bd2:	85 db                	test   %ebx,%ebx
  801bd4:	74 2c                	je     801c02 <ipc_recv+0x62>
			*perm_store = 0;
  801bd6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801bdc:	eb 24                	jmp    801c02 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801bde:	85 f6                	test   %esi,%esi
  801be0:	74 0a                	je     801bec <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801be2:	a1 04 40 80 00       	mov    0x804004,%eax
  801be7:	8b 40 74             	mov    0x74(%eax),%eax
  801bea:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801bec:	85 db                	test   %ebx,%ebx
  801bee:	74 0a                	je     801bfa <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801bf0:	a1 04 40 80 00       	mov    0x804004,%eax
  801bf5:	8b 40 78             	mov    0x78(%eax),%eax
  801bf8:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801bfa:	a1 04 40 80 00       	mov    0x804004,%eax
  801bff:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801c02:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c05:	5b                   	pop    %ebx
  801c06:	5e                   	pop    %esi
  801c07:	5d                   	pop    %ebp
  801c08:	c3                   	ret    

00801c09 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	57                   	push   %edi
  801c0d:	56                   	push   %esi
  801c0e:	53                   	push   %ebx
  801c0f:	83 ec 0c             	sub    $0xc,%esp
  801c12:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c15:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801c1b:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801c1d:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801c22:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801c25:	ff 75 14             	pushl  0x14(%ebp)
  801c28:	53                   	push   %ebx
  801c29:	56                   	push   %esi
  801c2a:	57                   	push   %edi
  801c2b:	e8 f9 f1 ff ff       	call   800e29 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801c30:	83 c4 10             	add    $0x10,%esp
  801c33:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c36:	75 07                	jne    801c3f <ipc_send+0x36>
			sys_yield();
  801c38:	e8 40 f0 ff ff       	call   800c7d <sys_yield>
  801c3d:	eb e6                	jmp    801c25 <ipc_send+0x1c>
		} else if (r < 0) {
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	79 12                	jns    801c55 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801c43:	50                   	push   %eax
  801c44:	68 66 24 80 00       	push   $0x802466
  801c49:	6a 51                	push   $0x51
  801c4b:	68 73 24 80 00       	push   $0x802473
  801c50:	e8 e6 e5 ff ff       	call   80023b <_panic>
		}
	}
}
  801c55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c58:	5b                   	pop    %ebx
  801c59:	5e                   	pop    %esi
  801c5a:	5f                   	pop    %edi
  801c5b:	5d                   	pop    %ebp
  801c5c:	c3                   	ret    

00801c5d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c63:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c68:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c6b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c71:	8b 52 50             	mov    0x50(%edx),%edx
  801c74:	39 ca                	cmp    %ecx,%edx
  801c76:	75 0d                	jne    801c85 <ipc_find_env+0x28>
			return envs[i].env_id;
  801c78:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c7b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c80:	8b 40 48             	mov    0x48(%eax),%eax
  801c83:	eb 0f                	jmp    801c94 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c85:	83 c0 01             	add    $0x1,%eax
  801c88:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c8d:	75 d9                	jne    801c68 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c94:	5d                   	pop    %ebp
  801c95:	c3                   	ret    

00801c96 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
  801c99:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c9c:	89 d0                	mov    %edx,%eax
  801c9e:	c1 e8 16             	shr    $0x16,%eax
  801ca1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ca8:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cad:	f6 c1 01             	test   $0x1,%cl
  801cb0:	74 1d                	je     801ccf <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801cb2:	c1 ea 0c             	shr    $0xc,%edx
  801cb5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801cbc:	f6 c2 01             	test   $0x1,%dl
  801cbf:	74 0e                	je     801ccf <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801cc1:	c1 ea 0c             	shr    $0xc,%edx
  801cc4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ccb:	ef 
  801ccc:	0f b7 c0             	movzwl %ax,%eax
}
  801ccf:	5d                   	pop    %ebp
  801cd0:	c3                   	ret    
  801cd1:	66 90                	xchg   %ax,%ax
  801cd3:	66 90                	xchg   %ax,%ax
  801cd5:	66 90                	xchg   %ax,%ax
  801cd7:	66 90                	xchg   %ax,%ax
  801cd9:	66 90                	xchg   %ax,%ax
  801cdb:	66 90                	xchg   %ax,%ax
  801cdd:	66 90                	xchg   %ax,%ax
  801cdf:	90                   	nop

00801ce0 <__udivdi3>:
  801ce0:	55                   	push   %ebp
  801ce1:	57                   	push   %edi
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 1c             	sub    $0x1c,%esp
  801ce7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ceb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801cef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801cf3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cf7:	85 f6                	test   %esi,%esi
  801cf9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cfd:	89 ca                	mov    %ecx,%edx
  801cff:	89 f8                	mov    %edi,%eax
  801d01:	75 3d                	jne    801d40 <__udivdi3+0x60>
  801d03:	39 cf                	cmp    %ecx,%edi
  801d05:	0f 87 c5 00 00 00    	ja     801dd0 <__udivdi3+0xf0>
  801d0b:	85 ff                	test   %edi,%edi
  801d0d:	89 fd                	mov    %edi,%ebp
  801d0f:	75 0b                	jne    801d1c <__udivdi3+0x3c>
  801d11:	b8 01 00 00 00       	mov    $0x1,%eax
  801d16:	31 d2                	xor    %edx,%edx
  801d18:	f7 f7                	div    %edi
  801d1a:	89 c5                	mov    %eax,%ebp
  801d1c:	89 c8                	mov    %ecx,%eax
  801d1e:	31 d2                	xor    %edx,%edx
  801d20:	f7 f5                	div    %ebp
  801d22:	89 c1                	mov    %eax,%ecx
  801d24:	89 d8                	mov    %ebx,%eax
  801d26:	89 cf                	mov    %ecx,%edi
  801d28:	f7 f5                	div    %ebp
  801d2a:	89 c3                	mov    %eax,%ebx
  801d2c:	89 d8                	mov    %ebx,%eax
  801d2e:	89 fa                	mov    %edi,%edx
  801d30:	83 c4 1c             	add    $0x1c,%esp
  801d33:	5b                   	pop    %ebx
  801d34:	5e                   	pop    %esi
  801d35:	5f                   	pop    %edi
  801d36:	5d                   	pop    %ebp
  801d37:	c3                   	ret    
  801d38:	90                   	nop
  801d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d40:	39 ce                	cmp    %ecx,%esi
  801d42:	77 74                	ja     801db8 <__udivdi3+0xd8>
  801d44:	0f bd fe             	bsr    %esi,%edi
  801d47:	83 f7 1f             	xor    $0x1f,%edi
  801d4a:	0f 84 98 00 00 00    	je     801de8 <__udivdi3+0x108>
  801d50:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d55:	89 f9                	mov    %edi,%ecx
  801d57:	89 c5                	mov    %eax,%ebp
  801d59:	29 fb                	sub    %edi,%ebx
  801d5b:	d3 e6                	shl    %cl,%esi
  801d5d:	89 d9                	mov    %ebx,%ecx
  801d5f:	d3 ed                	shr    %cl,%ebp
  801d61:	89 f9                	mov    %edi,%ecx
  801d63:	d3 e0                	shl    %cl,%eax
  801d65:	09 ee                	or     %ebp,%esi
  801d67:	89 d9                	mov    %ebx,%ecx
  801d69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d6d:	89 d5                	mov    %edx,%ebp
  801d6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d73:	d3 ed                	shr    %cl,%ebp
  801d75:	89 f9                	mov    %edi,%ecx
  801d77:	d3 e2                	shl    %cl,%edx
  801d79:	89 d9                	mov    %ebx,%ecx
  801d7b:	d3 e8                	shr    %cl,%eax
  801d7d:	09 c2                	or     %eax,%edx
  801d7f:	89 d0                	mov    %edx,%eax
  801d81:	89 ea                	mov    %ebp,%edx
  801d83:	f7 f6                	div    %esi
  801d85:	89 d5                	mov    %edx,%ebp
  801d87:	89 c3                	mov    %eax,%ebx
  801d89:	f7 64 24 0c          	mull   0xc(%esp)
  801d8d:	39 d5                	cmp    %edx,%ebp
  801d8f:	72 10                	jb     801da1 <__udivdi3+0xc1>
  801d91:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d95:	89 f9                	mov    %edi,%ecx
  801d97:	d3 e6                	shl    %cl,%esi
  801d99:	39 c6                	cmp    %eax,%esi
  801d9b:	73 07                	jae    801da4 <__udivdi3+0xc4>
  801d9d:	39 d5                	cmp    %edx,%ebp
  801d9f:	75 03                	jne    801da4 <__udivdi3+0xc4>
  801da1:	83 eb 01             	sub    $0x1,%ebx
  801da4:	31 ff                	xor    %edi,%edi
  801da6:	89 d8                	mov    %ebx,%eax
  801da8:	89 fa                	mov    %edi,%edx
  801daa:	83 c4 1c             	add    $0x1c,%esp
  801dad:	5b                   	pop    %ebx
  801dae:	5e                   	pop    %esi
  801daf:	5f                   	pop    %edi
  801db0:	5d                   	pop    %ebp
  801db1:	c3                   	ret    
  801db2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801db8:	31 ff                	xor    %edi,%edi
  801dba:	31 db                	xor    %ebx,%ebx
  801dbc:	89 d8                	mov    %ebx,%eax
  801dbe:	89 fa                	mov    %edi,%edx
  801dc0:	83 c4 1c             	add    $0x1c,%esp
  801dc3:	5b                   	pop    %ebx
  801dc4:	5e                   	pop    %esi
  801dc5:	5f                   	pop    %edi
  801dc6:	5d                   	pop    %ebp
  801dc7:	c3                   	ret    
  801dc8:	90                   	nop
  801dc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dd0:	89 d8                	mov    %ebx,%eax
  801dd2:	f7 f7                	div    %edi
  801dd4:	31 ff                	xor    %edi,%edi
  801dd6:	89 c3                	mov    %eax,%ebx
  801dd8:	89 d8                	mov    %ebx,%eax
  801dda:	89 fa                	mov    %edi,%edx
  801ddc:	83 c4 1c             	add    $0x1c,%esp
  801ddf:	5b                   	pop    %ebx
  801de0:	5e                   	pop    %esi
  801de1:	5f                   	pop    %edi
  801de2:	5d                   	pop    %ebp
  801de3:	c3                   	ret    
  801de4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801de8:	39 ce                	cmp    %ecx,%esi
  801dea:	72 0c                	jb     801df8 <__udivdi3+0x118>
  801dec:	31 db                	xor    %ebx,%ebx
  801dee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801df2:	0f 87 34 ff ff ff    	ja     801d2c <__udivdi3+0x4c>
  801df8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801dfd:	e9 2a ff ff ff       	jmp    801d2c <__udivdi3+0x4c>
  801e02:	66 90                	xchg   %ax,%ax
  801e04:	66 90                	xchg   %ax,%ax
  801e06:	66 90                	xchg   %ax,%ax
  801e08:	66 90                	xchg   %ax,%ax
  801e0a:	66 90                	xchg   %ax,%ax
  801e0c:	66 90                	xchg   %ax,%ax
  801e0e:	66 90                	xchg   %ax,%ax

00801e10 <__umoddi3>:
  801e10:	55                   	push   %ebp
  801e11:	57                   	push   %edi
  801e12:	56                   	push   %esi
  801e13:	53                   	push   %ebx
  801e14:	83 ec 1c             	sub    $0x1c,%esp
  801e17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801e1b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801e1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e27:	85 d2                	test   %edx,%edx
  801e29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e31:	89 f3                	mov    %esi,%ebx
  801e33:	89 3c 24             	mov    %edi,(%esp)
  801e36:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e3a:	75 1c                	jne    801e58 <__umoddi3+0x48>
  801e3c:	39 f7                	cmp    %esi,%edi
  801e3e:	76 50                	jbe    801e90 <__umoddi3+0x80>
  801e40:	89 c8                	mov    %ecx,%eax
  801e42:	89 f2                	mov    %esi,%edx
  801e44:	f7 f7                	div    %edi
  801e46:	89 d0                	mov    %edx,%eax
  801e48:	31 d2                	xor    %edx,%edx
  801e4a:	83 c4 1c             	add    $0x1c,%esp
  801e4d:	5b                   	pop    %ebx
  801e4e:	5e                   	pop    %esi
  801e4f:	5f                   	pop    %edi
  801e50:	5d                   	pop    %ebp
  801e51:	c3                   	ret    
  801e52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e58:	39 f2                	cmp    %esi,%edx
  801e5a:	89 d0                	mov    %edx,%eax
  801e5c:	77 52                	ja     801eb0 <__umoddi3+0xa0>
  801e5e:	0f bd ea             	bsr    %edx,%ebp
  801e61:	83 f5 1f             	xor    $0x1f,%ebp
  801e64:	75 5a                	jne    801ec0 <__umoddi3+0xb0>
  801e66:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e6a:	0f 82 e0 00 00 00    	jb     801f50 <__umoddi3+0x140>
  801e70:	39 0c 24             	cmp    %ecx,(%esp)
  801e73:	0f 86 d7 00 00 00    	jbe    801f50 <__umoddi3+0x140>
  801e79:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e7d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e81:	83 c4 1c             	add    $0x1c,%esp
  801e84:	5b                   	pop    %ebx
  801e85:	5e                   	pop    %esi
  801e86:	5f                   	pop    %edi
  801e87:	5d                   	pop    %ebp
  801e88:	c3                   	ret    
  801e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e90:	85 ff                	test   %edi,%edi
  801e92:	89 fd                	mov    %edi,%ebp
  801e94:	75 0b                	jne    801ea1 <__umoddi3+0x91>
  801e96:	b8 01 00 00 00       	mov    $0x1,%eax
  801e9b:	31 d2                	xor    %edx,%edx
  801e9d:	f7 f7                	div    %edi
  801e9f:	89 c5                	mov    %eax,%ebp
  801ea1:	89 f0                	mov    %esi,%eax
  801ea3:	31 d2                	xor    %edx,%edx
  801ea5:	f7 f5                	div    %ebp
  801ea7:	89 c8                	mov    %ecx,%eax
  801ea9:	f7 f5                	div    %ebp
  801eab:	89 d0                	mov    %edx,%eax
  801ead:	eb 99                	jmp    801e48 <__umoddi3+0x38>
  801eaf:	90                   	nop
  801eb0:	89 c8                	mov    %ecx,%eax
  801eb2:	89 f2                	mov    %esi,%edx
  801eb4:	83 c4 1c             	add    $0x1c,%esp
  801eb7:	5b                   	pop    %ebx
  801eb8:	5e                   	pop    %esi
  801eb9:	5f                   	pop    %edi
  801eba:	5d                   	pop    %ebp
  801ebb:	c3                   	ret    
  801ebc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ec0:	8b 34 24             	mov    (%esp),%esi
  801ec3:	bf 20 00 00 00       	mov    $0x20,%edi
  801ec8:	89 e9                	mov    %ebp,%ecx
  801eca:	29 ef                	sub    %ebp,%edi
  801ecc:	d3 e0                	shl    %cl,%eax
  801ece:	89 f9                	mov    %edi,%ecx
  801ed0:	89 f2                	mov    %esi,%edx
  801ed2:	d3 ea                	shr    %cl,%edx
  801ed4:	89 e9                	mov    %ebp,%ecx
  801ed6:	09 c2                	or     %eax,%edx
  801ed8:	89 d8                	mov    %ebx,%eax
  801eda:	89 14 24             	mov    %edx,(%esp)
  801edd:	89 f2                	mov    %esi,%edx
  801edf:	d3 e2                	shl    %cl,%edx
  801ee1:	89 f9                	mov    %edi,%ecx
  801ee3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ee7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801eeb:	d3 e8                	shr    %cl,%eax
  801eed:	89 e9                	mov    %ebp,%ecx
  801eef:	89 c6                	mov    %eax,%esi
  801ef1:	d3 e3                	shl    %cl,%ebx
  801ef3:	89 f9                	mov    %edi,%ecx
  801ef5:	89 d0                	mov    %edx,%eax
  801ef7:	d3 e8                	shr    %cl,%eax
  801ef9:	89 e9                	mov    %ebp,%ecx
  801efb:	09 d8                	or     %ebx,%eax
  801efd:	89 d3                	mov    %edx,%ebx
  801eff:	89 f2                	mov    %esi,%edx
  801f01:	f7 34 24             	divl   (%esp)
  801f04:	89 d6                	mov    %edx,%esi
  801f06:	d3 e3                	shl    %cl,%ebx
  801f08:	f7 64 24 04          	mull   0x4(%esp)
  801f0c:	39 d6                	cmp    %edx,%esi
  801f0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f12:	89 d1                	mov    %edx,%ecx
  801f14:	89 c3                	mov    %eax,%ebx
  801f16:	72 08                	jb     801f20 <__umoddi3+0x110>
  801f18:	75 11                	jne    801f2b <__umoddi3+0x11b>
  801f1a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801f1e:	73 0b                	jae    801f2b <__umoddi3+0x11b>
  801f20:	2b 44 24 04          	sub    0x4(%esp),%eax
  801f24:	1b 14 24             	sbb    (%esp),%edx
  801f27:	89 d1                	mov    %edx,%ecx
  801f29:	89 c3                	mov    %eax,%ebx
  801f2b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801f2f:	29 da                	sub    %ebx,%edx
  801f31:	19 ce                	sbb    %ecx,%esi
  801f33:	89 f9                	mov    %edi,%ecx
  801f35:	89 f0                	mov    %esi,%eax
  801f37:	d3 e0                	shl    %cl,%eax
  801f39:	89 e9                	mov    %ebp,%ecx
  801f3b:	d3 ea                	shr    %cl,%edx
  801f3d:	89 e9                	mov    %ebp,%ecx
  801f3f:	d3 ee                	shr    %cl,%esi
  801f41:	09 d0                	or     %edx,%eax
  801f43:	89 f2                	mov    %esi,%edx
  801f45:	83 c4 1c             	add    $0x1c,%esp
  801f48:	5b                   	pop    %ebx
  801f49:	5e                   	pop    %esi
  801f4a:	5f                   	pop    %edi
  801f4b:	5d                   	pop    %ebp
  801f4c:	c3                   	ret    
  801f4d:	8d 76 00             	lea    0x0(%esi),%esi
  801f50:	29 f9                	sub    %edi,%ecx
  801f52:	19 d6                	sbb    %edx,%esi
  801f54:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f5c:	e9 18 ff ff ff       	jmp    801e79 <__umoddi3+0x69>
