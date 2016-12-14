
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 87 01 00 00       	call   8001b8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 20 28 80 00       	push   $0x802820
  800043:	e8 4b 19 00 00       	call   801993 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 25 28 80 00       	push   $0x802825
  800057:	6a 0c                	push   $0xc
  800059:	68 33 28 80 00       	push   $0x802833
  80005e:	e8 b5 01 00 00       	call   800218 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 d7 15 00 00       	call   801645 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 ef 14 00 00       	call   801570 <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 48 28 80 00       	push   $0x802848
  800090:	6a 0f                	push   $0xf
  800092:	68 33 28 80 00       	push   $0x802833
  800097:	e8 7c 01 00 00       	call   800218 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 83 0f 00 00       	call   801024 <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 26 2d 80 00       	push   $0x802d26
  8000ad:	6a 12                	push   $0x12
  8000af:	68 33 28 80 00       	push   $0x802833
  8000b4:	e8 5f 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 79 15 00 00       	call   801645 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 88 28 80 00 	movl   $0x802888,(%esp)
  8000d3:	e8 19 02 00 00       	call   8002f1 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 85 14 00 00       	call   801570 <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 cc 28 80 00       	push   $0x8028cc
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 33 28 80 00       	push   $0x802833
  800103:	e8 10 01 00 00       	call   800218 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	56                   	push   %esi
  80010c:	68 20 40 80 00       	push   $0x804020
  800111:	68 20 42 80 00       	push   $0x804220
  800116:	e8 68 09 00 00       	call   800a83 <memcmp>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 14                	je     800136 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	68 f8 28 80 00       	push   $0x8028f8
  80012a:	6a 19                	push   $0x19
  80012c:	68 33 28 80 00       	push   $0x802833
  800131:	e8 e2 00 00 00       	call   800218 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 52 28 80 00       	push   $0x802852
  80013e:	e8 ae 01 00 00       	call   8002f1 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 f7 14 00 00       	call   801645 <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 4d 12 00 00       	call   8013a3 <close>
		exit();
  800156:	e8 a3 00 00 00       	call   8001fe <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 93 20 00 00       	call   8021fa <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 f6 13 00 00       	call   801570 <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 30 29 80 00       	push   $0x802930
  80018b:	6a 21                	push   $0x21
  80018d:	68 33 28 80 00       	push   $0x802833
  800192:	e8 81 00 00 00       	call   800218 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 6b 28 80 00       	push   $0x80286b
  80019f:	e8 4d 01 00 00       	call   8002f1 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 f7 11 00 00       	call   8013a3 <close>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8001ac:	cc                   	int3   

	breakpoint();
}
  8001ad:	83 c4 10             	add    $0x10,%esp
  8001b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001c3:	e8 73 0a 00 00       	call   800c3b <sys_getenvid>
  8001c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d5:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001da:	85 db                	test   %ebx,%ebx
  8001dc:	7e 07                	jle    8001e5 <libmain+0x2d>
		binaryname = argv[0];
  8001de:	8b 06                	mov    (%esi),%eax
  8001e0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	e8 44 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001ef:	e8 0a 00 00 00       	call   8001fe <exit>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800204:	e8 c5 11 00 00       	call   8013ce <close_all>
	sys_env_destroy(0);
  800209:	83 ec 0c             	sub    $0xc,%esp
  80020c:	6a 00                	push   $0x0
  80020e:	e8 e7 09 00 00       	call   800bfa <sys_env_destroy>
}
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80021d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800220:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800226:	e8 10 0a 00 00       	call   800c3b <sys_getenvid>
  80022b:	83 ec 0c             	sub    $0xc,%esp
  80022e:	ff 75 0c             	pushl  0xc(%ebp)
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	56                   	push   %esi
  800235:	50                   	push   %eax
  800236:	68 60 29 80 00       	push   $0x802960
  80023b:	e8 b1 00 00 00       	call   8002f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	53                   	push   %ebx
  800244:	ff 75 10             	pushl  0x10(%ebp)
  800247:	e8 54 00 00 00       	call   8002a0 <vcprintf>
	cprintf("\n");
  80024c:	c7 04 24 69 28 80 00 	movl   $0x802869,(%esp)
  800253:	e8 99 00 00 00       	call   8002f1 <cprintf>
  800258:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80025b:	cc                   	int3   
  80025c:	eb fd                	jmp    80025b <_panic+0x43>

0080025e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	53                   	push   %ebx
  800262:	83 ec 04             	sub    $0x4,%esp
  800265:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800268:	8b 13                	mov    (%ebx),%edx
  80026a:	8d 42 01             	lea    0x1(%edx),%eax
  80026d:	89 03                	mov    %eax,(%ebx)
  80026f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800272:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800276:	3d ff 00 00 00       	cmp    $0xff,%eax
  80027b:	75 1a                	jne    800297 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	68 ff 00 00 00       	push   $0xff
  800285:	8d 43 08             	lea    0x8(%ebx),%eax
  800288:	50                   	push   %eax
  800289:	e8 2f 09 00 00       	call   800bbd <sys_cputs>
		b->idx = 0;
  80028e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800294:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800297:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80029b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002b0:	00 00 00 
	b.cnt = 0;
  8002b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002bd:	ff 75 0c             	pushl  0xc(%ebp)
  8002c0:	ff 75 08             	pushl  0x8(%ebp)
  8002c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c9:	50                   	push   %eax
  8002ca:	68 5e 02 80 00       	push   $0x80025e
  8002cf:	e8 54 01 00 00       	call   800428 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d4:	83 c4 08             	add    $0x8,%esp
  8002d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 d4 08 00 00       	call   800bbd <sys_cputs>

	return b.cnt;
}
  8002e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ef:	c9                   	leave  
  8002f0:	c3                   	ret    

008002f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002fa:	50                   	push   %eax
  8002fb:	ff 75 08             	pushl  0x8(%ebp)
  8002fe:	e8 9d ff ff ff       	call   8002a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800303:	c9                   	leave  
  800304:	c3                   	ret    

00800305 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 1c             	sub    $0x1c,%esp
  80030e:	89 c7                	mov    %eax,%edi
  800310:	89 d6                	mov    %edx,%esi
  800312:	8b 45 08             	mov    0x8(%ebp),%eax
  800315:	8b 55 0c             	mov    0xc(%ebp),%edx
  800318:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80031b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80031e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800321:	bb 00 00 00 00       	mov    $0x0,%ebx
  800326:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800329:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80032c:	39 d3                	cmp    %edx,%ebx
  80032e:	72 05                	jb     800335 <printnum+0x30>
  800330:	39 45 10             	cmp    %eax,0x10(%ebp)
  800333:	77 45                	ja     80037a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	ff 75 18             	pushl  0x18(%ebp)
  80033b:	8b 45 14             	mov    0x14(%ebp),%eax
  80033e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800341:	53                   	push   %ebx
  800342:	ff 75 10             	pushl  0x10(%ebp)
  800345:	83 ec 08             	sub    $0x8,%esp
  800348:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034b:	ff 75 e0             	pushl  -0x20(%ebp)
  80034e:	ff 75 dc             	pushl  -0x24(%ebp)
  800351:	ff 75 d8             	pushl  -0x28(%ebp)
  800354:	e8 27 22 00 00       	call   802580 <__udivdi3>
  800359:	83 c4 18             	add    $0x18,%esp
  80035c:	52                   	push   %edx
  80035d:	50                   	push   %eax
  80035e:	89 f2                	mov    %esi,%edx
  800360:	89 f8                	mov    %edi,%eax
  800362:	e8 9e ff ff ff       	call   800305 <printnum>
  800367:	83 c4 20             	add    $0x20,%esp
  80036a:	eb 18                	jmp    800384 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80036c:	83 ec 08             	sub    $0x8,%esp
  80036f:	56                   	push   %esi
  800370:	ff 75 18             	pushl  0x18(%ebp)
  800373:	ff d7                	call   *%edi
  800375:	83 c4 10             	add    $0x10,%esp
  800378:	eb 03                	jmp    80037d <printnum+0x78>
  80037a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80037d:	83 eb 01             	sub    $0x1,%ebx
  800380:	85 db                	test   %ebx,%ebx
  800382:	7f e8                	jg     80036c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	56                   	push   %esi
  800388:	83 ec 04             	sub    $0x4,%esp
  80038b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80038e:	ff 75 e0             	pushl  -0x20(%ebp)
  800391:	ff 75 dc             	pushl  -0x24(%ebp)
  800394:	ff 75 d8             	pushl  -0x28(%ebp)
  800397:	e8 14 23 00 00       	call   8026b0 <__umoddi3>
  80039c:	83 c4 14             	add    $0x14,%esp
  80039f:	0f be 80 83 29 80 00 	movsbl 0x802983(%eax),%eax
  8003a6:	50                   	push   %eax
  8003a7:	ff d7                	call   *%edi
}
  8003a9:	83 c4 10             	add    $0x10,%esp
  8003ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003af:	5b                   	pop    %ebx
  8003b0:	5e                   	pop    %esi
  8003b1:	5f                   	pop    %edi
  8003b2:	5d                   	pop    %ebp
  8003b3:	c3                   	ret    

008003b4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b7:	83 fa 01             	cmp    $0x1,%edx
  8003ba:	7e 0e                	jle    8003ca <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003bc:	8b 10                	mov    (%eax),%edx
  8003be:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003c1:	89 08                	mov    %ecx,(%eax)
  8003c3:	8b 02                	mov    (%edx),%eax
  8003c5:	8b 52 04             	mov    0x4(%edx),%edx
  8003c8:	eb 22                	jmp    8003ec <getuint+0x38>
	else if (lflag)
  8003ca:	85 d2                	test   %edx,%edx
  8003cc:	74 10                	je     8003de <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ce:	8b 10                	mov    (%eax),%edx
  8003d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d3:	89 08                	mov    %ecx,(%eax)
  8003d5:	8b 02                	mov    (%edx),%eax
  8003d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003dc:	eb 0e                	jmp    8003ec <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003de:	8b 10                	mov    (%eax),%edx
  8003e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e3:	89 08                	mov    %ecx,(%eax)
  8003e5:	8b 02                	mov    (%edx),%eax
  8003e7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ec:	5d                   	pop    %ebp
  8003ed:	c3                   	ret    

008003ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f8:	8b 10                	mov    (%eax),%edx
  8003fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fd:	73 0a                	jae    800409 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800402:	89 08                	mov    %ecx,(%eax)
  800404:	8b 45 08             	mov    0x8(%ebp),%eax
  800407:	88 02                	mov    %al,(%edx)
}
  800409:	5d                   	pop    %ebp
  80040a:	c3                   	ret    

0080040b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80040b:	55                   	push   %ebp
  80040c:	89 e5                	mov    %esp,%ebp
  80040e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800411:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800414:	50                   	push   %eax
  800415:	ff 75 10             	pushl  0x10(%ebp)
  800418:	ff 75 0c             	pushl  0xc(%ebp)
  80041b:	ff 75 08             	pushl  0x8(%ebp)
  80041e:	e8 05 00 00 00       	call   800428 <vprintfmt>
	va_end(ap);
}
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	57                   	push   %edi
  80042c:	56                   	push   %esi
  80042d:	53                   	push   %ebx
  80042e:	83 ec 2c             	sub    $0x2c,%esp
  800431:	8b 75 08             	mov    0x8(%ebp),%esi
  800434:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800437:	8b 7d 10             	mov    0x10(%ebp),%edi
  80043a:	eb 12                	jmp    80044e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80043c:	85 c0                	test   %eax,%eax
  80043e:	0f 84 89 03 00 00    	je     8007cd <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800444:	83 ec 08             	sub    $0x8,%esp
  800447:	53                   	push   %ebx
  800448:	50                   	push   %eax
  800449:	ff d6                	call   *%esi
  80044b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80044e:	83 c7 01             	add    $0x1,%edi
  800451:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800455:	83 f8 25             	cmp    $0x25,%eax
  800458:	75 e2                	jne    80043c <vprintfmt+0x14>
  80045a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80045e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800465:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80046c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800473:	ba 00 00 00 00       	mov    $0x0,%edx
  800478:	eb 07                	jmp    800481 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80047d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8d 47 01             	lea    0x1(%edi),%eax
  800484:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800487:	0f b6 07             	movzbl (%edi),%eax
  80048a:	0f b6 c8             	movzbl %al,%ecx
  80048d:	83 e8 23             	sub    $0x23,%eax
  800490:	3c 55                	cmp    $0x55,%al
  800492:	0f 87 1a 03 00 00    	ja     8007b2 <vprintfmt+0x38a>
  800498:	0f b6 c0             	movzbl %al,%eax
  80049b:	ff 24 85 c0 2a 80 00 	jmp    *0x802ac0(,%eax,4)
  8004a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004a9:	eb d6                	jmp    800481 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004b6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004b9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004bd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004c0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004c3:	83 fa 09             	cmp    $0x9,%edx
  8004c6:	77 39                	ja     800501 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004cb:	eb e9                	jmp    8004b6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	8d 48 04             	lea    0x4(%eax),%ecx
  8004d3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004d6:	8b 00                	mov    (%eax),%eax
  8004d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004de:	eb 27                	jmp    800507 <vprintfmt+0xdf>
  8004e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ea:	0f 49 c8             	cmovns %eax,%ecx
  8004ed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f3:	eb 8c                	jmp    800481 <vprintfmt+0x59>
  8004f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004f8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004ff:	eb 80                	jmp    800481 <vprintfmt+0x59>
  800501:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800504:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800507:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80050b:	0f 89 70 ff ff ff    	jns    800481 <vprintfmt+0x59>
				width = precision, precision = -1;
  800511:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800514:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800517:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80051e:	e9 5e ff ff ff       	jmp    800481 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800523:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800529:	e9 53 ff ff ff       	jmp    800481 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 50 04             	lea    0x4(%eax),%edx
  800534:	89 55 14             	mov    %edx,0x14(%ebp)
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	53                   	push   %ebx
  80053b:	ff 30                	pushl  (%eax)
  80053d:	ff d6                	call   *%esi
			break;
  80053f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800545:	e9 04 ff ff ff       	jmp    80044e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8d 50 04             	lea    0x4(%eax),%edx
  800550:	89 55 14             	mov    %edx,0x14(%ebp)
  800553:	8b 00                	mov    (%eax),%eax
  800555:	99                   	cltd   
  800556:	31 d0                	xor    %edx,%eax
  800558:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055a:	83 f8 0f             	cmp    $0xf,%eax
  80055d:	7f 0b                	jg     80056a <vprintfmt+0x142>
  80055f:	8b 14 85 20 2c 80 00 	mov    0x802c20(,%eax,4),%edx
  800566:	85 d2                	test   %edx,%edx
  800568:	75 18                	jne    800582 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80056a:	50                   	push   %eax
  80056b:	68 9b 29 80 00       	push   $0x80299b
  800570:	53                   	push   %ebx
  800571:	56                   	push   %esi
  800572:	e8 94 fe ff ff       	call   80040b <printfmt>
  800577:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80057d:	e9 cc fe ff ff       	jmp    80044e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800582:	52                   	push   %edx
  800583:	68 0e 2e 80 00       	push   $0x802e0e
  800588:	53                   	push   %ebx
  800589:	56                   	push   %esi
  80058a:	e8 7c fe ff ff       	call   80040b <printfmt>
  80058f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800592:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800595:	e9 b4 fe ff ff       	jmp    80044e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 50 04             	lea    0x4(%eax),%edx
  8005a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005a5:	85 ff                	test   %edi,%edi
  8005a7:	b8 94 29 80 00       	mov    $0x802994,%eax
  8005ac:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b3:	0f 8e 94 00 00 00    	jle    80064d <vprintfmt+0x225>
  8005b9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005bd:	0f 84 98 00 00 00    	je     80065b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	ff 75 d0             	pushl  -0x30(%ebp)
  8005c9:	57                   	push   %edi
  8005ca:	e8 86 02 00 00       	call   800855 <strnlen>
  8005cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005d2:	29 c1                	sub    %eax,%ecx
  8005d4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005d7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005da:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005e4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e6:	eb 0f                	jmp    8005f7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	53                   	push   %ebx
  8005ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f1:	83 ef 01             	sub    $0x1,%edi
  8005f4:	83 c4 10             	add    $0x10,%esp
  8005f7:	85 ff                	test   %edi,%edi
  8005f9:	7f ed                	jg     8005e8 <vprintfmt+0x1c0>
  8005fb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005fe:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800601:	85 c9                	test   %ecx,%ecx
  800603:	b8 00 00 00 00       	mov    $0x0,%eax
  800608:	0f 49 c1             	cmovns %ecx,%eax
  80060b:	29 c1                	sub    %eax,%ecx
  80060d:	89 75 08             	mov    %esi,0x8(%ebp)
  800610:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800613:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800616:	89 cb                	mov    %ecx,%ebx
  800618:	eb 4d                	jmp    800667 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80061a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80061e:	74 1b                	je     80063b <vprintfmt+0x213>
  800620:	0f be c0             	movsbl %al,%eax
  800623:	83 e8 20             	sub    $0x20,%eax
  800626:	83 f8 5e             	cmp    $0x5e,%eax
  800629:	76 10                	jbe    80063b <vprintfmt+0x213>
					putch('?', putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	ff 75 0c             	pushl  0xc(%ebp)
  800631:	6a 3f                	push   $0x3f
  800633:	ff 55 08             	call   *0x8(%ebp)
  800636:	83 c4 10             	add    $0x10,%esp
  800639:	eb 0d                	jmp    800648 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	ff 75 0c             	pushl  0xc(%ebp)
  800641:	52                   	push   %edx
  800642:	ff 55 08             	call   *0x8(%ebp)
  800645:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800648:	83 eb 01             	sub    $0x1,%ebx
  80064b:	eb 1a                	jmp    800667 <vprintfmt+0x23f>
  80064d:	89 75 08             	mov    %esi,0x8(%ebp)
  800650:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800653:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800656:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800659:	eb 0c                	jmp    800667 <vprintfmt+0x23f>
  80065b:	89 75 08             	mov    %esi,0x8(%ebp)
  80065e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800661:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800664:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800667:	83 c7 01             	add    $0x1,%edi
  80066a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80066e:	0f be d0             	movsbl %al,%edx
  800671:	85 d2                	test   %edx,%edx
  800673:	74 23                	je     800698 <vprintfmt+0x270>
  800675:	85 f6                	test   %esi,%esi
  800677:	78 a1                	js     80061a <vprintfmt+0x1f2>
  800679:	83 ee 01             	sub    $0x1,%esi
  80067c:	79 9c                	jns    80061a <vprintfmt+0x1f2>
  80067e:	89 df                	mov    %ebx,%edi
  800680:	8b 75 08             	mov    0x8(%ebp),%esi
  800683:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800686:	eb 18                	jmp    8006a0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800688:	83 ec 08             	sub    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 20                	push   $0x20
  80068e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800690:	83 ef 01             	sub    $0x1,%edi
  800693:	83 c4 10             	add    $0x10,%esp
  800696:	eb 08                	jmp    8006a0 <vprintfmt+0x278>
  800698:	89 df                	mov    %ebx,%edi
  80069a:	8b 75 08             	mov    0x8(%ebp),%esi
  80069d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a0:	85 ff                	test   %edi,%edi
  8006a2:	7f e4                	jg     800688 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a7:	e9 a2 fd ff ff       	jmp    80044e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ac:	83 fa 01             	cmp    $0x1,%edx
  8006af:	7e 16                	jle    8006c7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8d 50 08             	lea    0x8(%eax),%edx
  8006b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ba:	8b 50 04             	mov    0x4(%eax),%edx
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006c5:	eb 32                	jmp    8006f9 <vprintfmt+0x2d1>
	else if (lflag)
  8006c7:	85 d2                	test   %edx,%edx
  8006c9:	74 18                	je     8006e3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8d 50 04             	lea    0x4(%eax),%edx
  8006d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d4:	8b 00                	mov    (%eax),%eax
  8006d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d9:	89 c1                	mov    %eax,%ecx
  8006db:	c1 f9 1f             	sar    $0x1f,%ecx
  8006de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e1:	eb 16                	jmp    8006f9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8d 50 04             	lea    0x4(%eax),%edx
  8006e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ec:	8b 00                	mov    (%eax),%eax
  8006ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f1:	89 c1                	mov    %eax,%ecx
  8006f3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800704:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800708:	79 74                	jns    80077e <vprintfmt+0x356>
				putch('-', putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	6a 2d                	push   $0x2d
  800710:	ff d6                	call   *%esi
				num = -(long long) num;
  800712:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800715:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800718:	f7 d8                	neg    %eax
  80071a:	83 d2 00             	adc    $0x0,%edx
  80071d:	f7 da                	neg    %edx
  80071f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800722:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800727:	eb 55                	jmp    80077e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800729:	8d 45 14             	lea    0x14(%ebp),%eax
  80072c:	e8 83 fc ff ff       	call   8003b4 <getuint>
			base = 10;
  800731:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800736:	eb 46                	jmp    80077e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800738:	8d 45 14             	lea    0x14(%ebp),%eax
  80073b:	e8 74 fc ff ff       	call   8003b4 <getuint>
                        base = 8;
  800740:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800745:	eb 37                	jmp    80077e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	53                   	push   %ebx
  80074b:	6a 30                	push   $0x30
  80074d:	ff d6                	call   *%esi
			putch('x', putdat);
  80074f:	83 c4 08             	add    $0x8,%esp
  800752:	53                   	push   %ebx
  800753:	6a 78                	push   $0x78
  800755:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	8d 50 04             	lea    0x4(%eax),%edx
  80075d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800760:	8b 00                	mov    (%eax),%eax
  800762:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800767:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80076a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80076f:	eb 0d                	jmp    80077e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800771:	8d 45 14             	lea    0x14(%ebp),%eax
  800774:	e8 3b fc ff ff       	call   8003b4 <getuint>
			base = 16;
  800779:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80077e:	83 ec 0c             	sub    $0xc,%esp
  800781:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800785:	57                   	push   %edi
  800786:	ff 75 e0             	pushl  -0x20(%ebp)
  800789:	51                   	push   %ecx
  80078a:	52                   	push   %edx
  80078b:	50                   	push   %eax
  80078c:	89 da                	mov    %ebx,%edx
  80078e:	89 f0                	mov    %esi,%eax
  800790:	e8 70 fb ff ff       	call   800305 <printnum>
			break;
  800795:	83 c4 20             	add    $0x20,%esp
  800798:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80079b:	e9 ae fc ff ff       	jmp    80044e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007a0:	83 ec 08             	sub    $0x8,%esp
  8007a3:	53                   	push   %ebx
  8007a4:	51                   	push   %ecx
  8007a5:	ff d6                	call   *%esi
			break;
  8007a7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ad:	e9 9c fc ff ff       	jmp    80044e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007b2:	83 ec 08             	sub    $0x8,%esp
  8007b5:	53                   	push   %ebx
  8007b6:	6a 25                	push   $0x25
  8007b8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ba:	83 c4 10             	add    $0x10,%esp
  8007bd:	eb 03                	jmp    8007c2 <vprintfmt+0x39a>
  8007bf:	83 ef 01             	sub    $0x1,%edi
  8007c2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007c6:	75 f7                	jne    8007bf <vprintfmt+0x397>
  8007c8:	e9 81 fc ff ff       	jmp    80044e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d0:	5b                   	pop    %ebx
  8007d1:	5e                   	pop    %esi
  8007d2:	5f                   	pop    %edi
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	83 ec 18             	sub    $0x18,%esp
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007e4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007f2:	85 c0                	test   %eax,%eax
  8007f4:	74 26                	je     80081c <vsnprintf+0x47>
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	7e 22                	jle    80081c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007fa:	ff 75 14             	pushl  0x14(%ebp)
  8007fd:	ff 75 10             	pushl  0x10(%ebp)
  800800:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800803:	50                   	push   %eax
  800804:	68 ee 03 80 00       	push   $0x8003ee
  800809:	e8 1a fc ff ff       	call   800428 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80080e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800811:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800814:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800817:	83 c4 10             	add    $0x10,%esp
  80081a:	eb 05                	jmp    800821 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80081c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800821:	c9                   	leave  
  800822:	c3                   	ret    

00800823 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800829:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80082c:	50                   	push   %eax
  80082d:	ff 75 10             	pushl  0x10(%ebp)
  800830:	ff 75 0c             	pushl  0xc(%ebp)
  800833:	ff 75 08             	pushl  0x8(%ebp)
  800836:	e8 9a ff ff ff       	call   8007d5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80083b:	c9                   	leave  
  80083c:	c3                   	ret    

0080083d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800843:	b8 00 00 00 00       	mov    $0x0,%eax
  800848:	eb 03                	jmp    80084d <strlen+0x10>
		n++;
  80084a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80084d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800851:	75 f7                	jne    80084a <strlen+0xd>
		n++;
	return n;
}
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085e:	ba 00 00 00 00       	mov    $0x0,%edx
  800863:	eb 03                	jmp    800868 <strnlen+0x13>
		n++;
  800865:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800868:	39 c2                	cmp    %eax,%edx
  80086a:	74 08                	je     800874 <strnlen+0x1f>
  80086c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800870:	75 f3                	jne    800865 <strnlen+0x10>
  800872:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	53                   	push   %ebx
  80087a:	8b 45 08             	mov    0x8(%ebp),%eax
  80087d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800880:	89 c2                	mov    %eax,%edx
  800882:	83 c2 01             	add    $0x1,%edx
  800885:	83 c1 01             	add    $0x1,%ecx
  800888:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80088c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80088f:	84 db                	test   %bl,%bl
  800891:	75 ef                	jne    800882 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800893:	5b                   	pop    %ebx
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	53                   	push   %ebx
  80089a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80089d:	53                   	push   %ebx
  80089e:	e8 9a ff ff ff       	call   80083d <strlen>
  8008a3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008a6:	ff 75 0c             	pushl  0xc(%ebp)
  8008a9:	01 d8                	add    %ebx,%eax
  8008ab:	50                   	push   %eax
  8008ac:	e8 c5 ff ff ff       	call   800876 <strcpy>
	return dst;
}
  8008b1:	89 d8                	mov    %ebx,%eax
  8008b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    

008008b8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
  8008bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c3:	89 f3                	mov    %esi,%ebx
  8008c5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c8:	89 f2                	mov    %esi,%edx
  8008ca:	eb 0f                	jmp    8008db <strncpy+0x23>
		*dst++ = *src;
  8008cc:	83 c2 01             	add    $0x1,%edx
  8008cf:	0f b6 01             	movzbl (%ecx),%eax
  8008d2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d5:	80 39 01             	cmpb   $0x1,(%ecx)
  8008d8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008db:	39 da                	cmp    %ebx,%edx
  8008dd:	75 ed                	jne    8008cc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008df:	89 f0                	mov    %esi,%eax
  8008e1:	5b                   	pop    %ebx
  8008e2:	5e                   	pop    %esi
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	56                   	push   %esi
  8008e9:	53                   	push   %ebx
  8008ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f0:	8b 55 10             	mov    0x10(%ebp),%edx
  8008f3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f5:	85 d2                	test   %edx,%edx
  8008f7:	74 21                	je     80091a <strlcpy+0x35>
  8008f9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008fd:	89 f2                	mov    %esi,%edx
  8008ff:	eb 09                	jmp    80090a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800901:	83 c2 01             	add    $0x1,%edx
  800904:	83 c1 01             	add    $0x1,%ecx
  800907:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80090a:	39 c2                	cmp    %eax,%edx
  80090c:	74 09                	je     800917 <strlcpy+0x32>
  80090e:	0f b6 19             	movzbl (%ecx),%ebx
  800911:	84 db                	test   %bl,%bl
  800913:	75 ec                	jne    800901 <strlcpy+0x1c>
  800915:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800917:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80091a:	29 f0                	sub    %esi,%eax
}
  80091c:	5b                   	pop    %ebx
  80091d:	5e                   	pop    %esi
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800929:	eb 06                	jmp    800931 <strcmp+0x11>
		p++, q++;
  80092b:	83 c1 01             	add    $0x1,%ecx
  80092e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800931:	0f b6 01             	movzbl (%ecx),%eax
  800934:	84 c0                	test   %al,%al
  800936:	74 04                	je     80093c <strcmp+0x1c>
  800938:	3a 02                	cmp    (%edx),%al
  80093a:	74 ef                	je     80092b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80093c:	0f b6 c0             	movzbl %al,%eax
  80093f:	0f b6 12             	movzbl (%edx),%edx
  800942:	29 d0                	sub    %edx,%eax
}
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	53                   	push   %ebx
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800950:	89 c3                	mov    %eax,%ebx
  800952:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800955:	eb 06                	jmp    80095d <strncmp+0x17>
		n--, p++, q++;
  800957:	83 c0 01             	add    $0x1,%eax
  80095a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80095d:	39 d8                	cmp    %ebx,%eax
  80095f:	74 15                	je     800976 <strncmp+0x30>
  800961:	0f b6 08             	movzbl (%eax),%ecx
  800964:	84 c9                	test   %cl,%cl
  800966:	74 04                	je     80096c <strncmp+0x26>
  800968:	3a 0a                	cmp    (%edx),%cl
  80096a:	74 eb                	je     800957 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80096c:	0f b6 00             	movzbl (%eax),%eax
  80096f:	0f b6 12             	movzbl (%edx),%edx
  800972:	29 d0                	sub    %edx,%eax
  800974:	eb 05                	jmp    80097b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80097b:	5b                   	pop    %ebx
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800988:	eb 07                	jmp    800991 <strchr+0x13>
		if (*s == c)
  80098a:	38 ca                	cmp    %cl,%dl
  80098c:	74 0f                	je     80099d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80098e:	83 c0 01             	add    $0x1,%eax
  800991:	0f b6 10             	movzbl (%eax),%edx
  800994:	84 d2                	test   %dl,%dl
  800996:	75 f2                	jne    80098a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800998:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a9:	eb 03                	jmp    8009ae <strfind+0xf>
  8009ab:	83 c0 01             	add    $0x1,%eax
  8009ae:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009b1:	38 ca                	cmp    %cl,%dl
  8009b3:	74 04                	je     8009b9 <strfind+0x1a>
  8009b5:	84 d2                	test   %dl,%dl
  8009b7:	75 f2                	jne    8009ab <strfind+0xc>
			break;
	return (char *) s;
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	57                   	push   %edi
  8009bf:	56                   	push   %esi
  8009c0:	53                   	push   %ebx
  8009c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c7:	85 c9                	test   %ecx,%ecx
  8009c9:	74 36                	je     800a01 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009cb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d1:	75 28                	jne    8009fb <memset+0x40>
  8009d3:	f6 c1 03             	test   $0x3,%cl
  8009d6:	75 23                	jne    8009fb <memset+0x40>
		c &= 0xFF;
  8009d8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009dc:	89 d3                	mov    %edx,%ebx
  8009de:	c1 e3 08             	shl    $0x8,%ebx
  8009e1:	89 d6                	mov    %edx,%esi
  8009e3:	c1 e6 18             	shl    $0x18,%esi
  8009e6:	89 d0                	mov    %edx,%eax
  8009e8:	c1 e0 10             	shl    $0x10,%eax
  8009eb:	09 f0                	or     %esi,%eax
  8009ed:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009ef:	89 d8                	mov    %ebx,%eax
  8009f1:	09 d0                	or     %edx,%eax
  8009f3:	c1 e9 02             	shr    $0x2,%ecx
  8009f6:	fc                   	cld    
  8009f7:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f9:	eb 06                	jmp    800a01 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fe:	fc                   	cld    
  8009ff:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a01:	89 f8                	mov    %edi,%eax
  800a03:	5b                   	pop    %ebx
  800a04:	5e                   	pop    %esi
  800a05:	5f                   	pop    %edi
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	57                   	push   %edi
  800a0c:	56                   	push   %esi
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a13:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a16:	39 c6                	cmp    %eax,%esi
  800a18:	73 35                	jae    800a4f <memmove+0x47>
  800a1a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a1d:	39 d0                	cmp    %edx,%eax
  800a1f:	73 2e                	jae    800a4f <memmove+0x47>
		s += n;
		d += n;
  800a21:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a24:	89 d6                	mov    %edx,%esi
  800a26:	09 fe                	or     %edi,%esi
  800a28:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a2e:	75 13                	jne    800a43 <memmove+0x3b>
  800a30:	f6 c1 03             	test   $0x3,%cl
  800a33:	75 0e                	jne    800a43 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a35:	83 ef 04             	sub    $0x4,%edi
  800a38:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a3b:	c1 e9 02             	shr    $0x2,%ecx
  800a3e:	fd                   	std    
  800a3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a41:	eb 09                	jmp    800a4c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a43:	83 ef 01             	sub    $0x1,%edi
  800a46:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a49:	fd                   	std    
  800a4a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a4c:	fc                   	cld    
  800a4d:	eb 1d                	jmp    800a6c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4f:	89 f2                	mov    %esi,%edx
  800a51:	09 c2                	or     %eax,%edx
  800a53:	f6 c2 03             	test   $0x3,%dl
  800a56:	75 0f                	jne    800a67 <memmove+0x5f>
  800a58:	f6 c1 03             	test   $0x3,%cl
  800a5b:	75 0a                	jne    800a67 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a5d:	c1 e9 02             	shr    $0x2,%ecx
  800a60:	89 c7                	mov    %eax,%edi
  800a62:	fc                   	cld    
  800a63:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a65:	eb 05                	jmp    800a6c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a67:	89 c7                	mov    %eax,%edi
  800a69:	fc                   	cld    
  800a6a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a6c:	5e                   	pop    %esi
  800a6d:	5f                   	pop    %edi
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a73:	ff 75 10             	pushl  0x10(%ebp)
  800a76:	ff 75 0c             	pushl  0xc(%ebp)
  800a79:	ff 75 08             	pushl  0x8(%ebp)
  800a7c:	e8 87 ff ff ff       	call   800a08 <memmove>
}
  800a81:	c9                   	leave  
  800a82:	c3                   	ret    

00800a83 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8e:	89 c6                	mov    %eax,%esi
  800a90:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a93:	eb 1a                	jmp    800aaf <memcmp+0x2c>
		if (*s1 != *s2)
  800a95:	0f b6 08             	movzbl (%eax),%ecx
  800a98:	0f b6 1a             	movzbl (%edx),%ebx
  800a9b:	38 d9                	cmp    %bl,%cl
  800a9d:	74 0a                	je     800aa9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a9f:	0f b6 c1             	movzbl %cl,%eax
  800aa2:	0f b6 db             	movzbl %bl,%ebx
  800aa5:	29 d8                	sub    %ebx,%eax
  800aa7:	eb 0f                	jmp    800ab8 <memcmp+0x35>
		s1++, s2++;
  800aa9:	83 c0 01             	add    $0x1,%eax
  800aac:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aaf:	39 f0                	cmp    %esi,%eax
  800ab1:	75 e2                	jne    800a95 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ab3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	53                   	push   %ebx
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ac3:	89 c1                	mov    %eax,%ecx
  800ac5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800acc:	eb 0a                	jmp    800ad8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ace:	0f b6 10             	movzbl (%eax),%edx
  800ad1:	39 da                	cmp    %ebx,%edx
  800ad3:	74 07                	je     800adc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad5:	83 c0 01             	add    $0x1,%eax
  800ad8:	39 c8                	cmp    %ecx,%eax
  800ada:	72 f2                	jb     800ace <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800adc:	5b                   	pop    %ebx
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	57                   	push   %edi
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
  800ae5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aeb:	eb 03                	jmp    800af0 <strtol+0x11>
		s++;
  800aed:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af0:	0f b6 01             	movzbl (%ecx),%eax
  800af3:	3c 20                	cmp    $0x20,%al
  800af5:	74 f6                	je     800aed <strtol+0xe>
  800af7:	3c 09                	cmp    $0x9,%al
  800af9:	74 f2                	je     800aed <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800afb:	3c 2b                	cmp    $0x2b,%al
  800afd:	75 0a                	jne    800b09 <strtol+0x2a>
		s++;
  800aff:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b02:	bf 00 00 00 00       	mov    $0x0,%edi
  800b07:	eb 11                	jmp    800b1a <strtol+0x3b>
  800b09:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b0e:	3c 2d                	cmp    $0x2d,%al
  800b10:	75 08                	jne    800b1a <strtol+0x3b>
		s++, neg = 1;
  800b12:	83 c1 01             	add    $0x1,%ecx
  800b15:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b20:	75 15                	jne    800b37 <strtol+0x58>
  800b22:	80 39 30             	cmpb   $0x30,(%ecx)
  800b25:	75 10                	jne    800b37 <strtol+0x58>
  800b27:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b2b:	75 7c                	jne    800ba9 <strtol+0xca>
		s += 2, base = 16;
  800b2d:	83 c1 02             	add    $0x2,%ecx
  800b30:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b35:	eb 16                	jmp    800b4d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b37:	85 db                	test   %ebx,%ebx
  800b39:	75 12                	jne    800b4d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b3b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b40:	80 39 30             	cmpb   $0x30,(%ecx)
  800b43:	75 08                	jne    800b4d <strtol+0x6e>
		s++, base = 8;
  800b45:	83 c1 01             	add    $0x1,%ecx
  800b48:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b52:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b55:	0f b6 11             	movzbl (%ecx),%edx
  800b58:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b5b:	89 f3                	mov    %esi,%ebx
  800b5d:	80 fb 09             	cmp    $0x9,%bl
  800b60:	77 08                	ja     800b6a <strtol+0x8b>
			dig = *s - '0';
  800b62:	0f be d2             	movsbl %dl,%edx
  800b65:	83 ea 30             	sub    $0x30,%edx
  800b68:	eb 22                	jmp    800b8c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b6a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b6d:	89 f3                	mov    %esi,%ebx
  800b6f:	80 fb 19             	cmp    $0x19,%bl
  800b72:	77 08                	ja     800b7c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b74:	0f be d2             	movsbl %dl,%edx
  800b77:	83 ea 57             	sub    $0x57,%edx
  800b7a:	eb 10                	jmp    800b8c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b7c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b7f:	89 f3                	mov    %esi,%ebx
  800b81:	80 fb 19             	cmp    $0x19,%bl
  800b84:	77 16                	ja     800b9c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b86:	0f be d2             	movsbl %dl,%edx
  800b89:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b8c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b8f:	7d 0b                	jge    800b9c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b91:	83 c1 01             	add    $0x1,%ecx
  800b94:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b98:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b9a:	eb b9                	jmp    800b55 <strtol+0x76>

	if (endptr)
  800b9c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba0:	74 0d                	je     800baf <strtol+0xd0>
		*endptr = (char *) s;
  800ba2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba5:	89 0e                	mov    %ecx,(%esi)
  800ba7:	eb 06                	jmp    800baf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ba9:	85 db                	test   %ebx,%ebx
  800bab:	74 98                	je     800b45 <strtol+0x66>
  800bad:	eb 9e                	jmp    800b4d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800baf:	89 c2                	mov    %eax,%edx
  800bb1:	f7 da                	neg    %edx
  800bb3:	85 ff                	test   %edi,%edi
  800bb5:	0f 45 c2             	cmovne %edx,%eax
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bce:	89 c3                	mov    %eax,%ebx
  800bd0:	89 c7                	mov    %eax,%edi
  800bd2:	89 c6                	mov    %eax,%esi
  800bd4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_cgetc>:

int
sys_cgetc(void)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be1:	ba 00 00 00 00       	mov    $0x0,%edx
  800be6:	b8 01 00 00 00       	mov    $0x1,%eax
  800beb:	89 d1                	mov    %edx,%ecx
  800bed:	89 d3                	mov    %edx,%ebx
  800bef:	89 d7                	mov    %edx,%edi
  800bf1:	89 d6                	mov    %edx,%esi
  800bf3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
  800c00:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c03:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c08:	b8 03 00 00 00       	mov    $0x3,%eax
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	89 cb                	mov    %ecx,%ebx
  800c12:	89 cf                	mov    %ecx,%edi
  800c14:	89 ce                	mov    %ecx,%esi
  800c16:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	7e 17                	jle    800c33 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 03                	push   $0x3
  800c22:	68 7f 2c 80 00       	push   $0x802c7f
  800c27:	6a 23                	push   $0x23
  800c29:	68 9c 2c 80 00       	push   $0x802c9c
  800c2e:	e8 e5 f5 ff ff       	call   800218 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	ba 00 00 00 00       	mov    $0x0,%edx
  800c46:	b8 02 00 00 00       	mov    $0x2,%eax
  800c4b:	89 d1                	mov    %edx,%ecx
  800c4d:	89 d3                	mov    %edx,%ebx
  800c4f:	89 d7                	mov    %edx,%edi
  800c51:	89 d6                	mov    %edx,%esi
  800c53:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_yield>:

void
sys_yield(void)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	ba 00 00 00 00       	mov    $0x0,%edx
  800c65:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c6a:	89 d1                	mov    %edx,%ecx
  800c6c:	89 d3                	mov    %edx,%ebx
  800c6e:	89 d7                	mov    %edx,%edi
  800c70:	89 d6                	mov    %edx,%esi
  800c72:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
  800c7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c82:	be 00 00 00 00       	mov    $0x0,%esi
  800c87:	b8 04 00 00 00       	mov    $0x4,%eax
  800c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c95:	89 f7                	mov    %esi,%edi
  800c97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	7e 17                	jle    800cb4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	83 ec 0c             	sub    $0xc,%esp
  800ca0:	50                   	push   %eax
  800ca1:	6a 04                	push   $0x4
  800ca3:	68 7f 2c 80 00       	push   $0x802c7f
  800ca8:	6a 23                	push   $0x23
  800caa:	68 9c 2c 80 00       	push   $0x802c9c
  800caf:	e8 64 f5 ff ff       	call   800218 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc5:	b8 05 00 00 00       	mov    $0x5,%eax
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd6:	8b 75 18             	mov    0x18(%ebp),%esi
  800cd9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	7e 17                	jle    800cf6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdf:	83 ec 0c             	sub    $0xc,%esp
  800ce2:	50                   	push   %eax
  800ce3:	6a 05                	push   $0x5
  800ce5:	68 7f 2c 80 00       	push   $0x802c7f
  800cea:	6a 23                	push   $0x23
  800cec:	68 9c 2c 80 00       	push   $0x802c9c
  800cf1:	e8 22 f5 ff ff       	call   800218 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0c:	b8 06 00 00 00       	mov    $0x6,%eax
  800d11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	89 df                	mov    %ebx,%edi
  800d19:	89 de                	mov    %ebx,%esi
  800d1b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	7e 17                	jle    800d38 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d21:	83 ec 0c             	sub    $0xc,%esp
  800d24:	50                   	push   %eax
  800d25:	6a 06                	push   $0x6
  800d27:	68 7f 2c 80 00       	push   $0x802c7f
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 9c 2c 80 00       	push   $0x802c9c
  800d33:	e8 e0 f4 ff ff       	call   800218 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	57                   	push   %edi
  800d44:	56                   	push   %esi
  800d45:	53                   	push   %ebx
  800d46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4e:	b8 08 00 00 00       	mov    $0x8,%eax
  800d53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	89 df                	mov    %ebx,%edi
  800d5b:	89 de                	mov    %ebx,%esi
  800d5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	7e 17                	jle    800d7a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	50                   	push   %eax
  800d67:	6a 08                	push   $0x8
  800d69:	68 7f 2c 80 00       	push   $0x802c7f
  800d6e:	6a 23                	push   $0x23
  800d70:	68 9c 2c 80 00       	push   $0x802c9c
  800d75:	e8 9e f4 ff ff       	call   800218 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
  800d88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d90:	b8 09 00 00 00       	mov    $0x9,%eax
  800d95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d98:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9b:	89 df                	mov    %ebx,%edi
  800d9d:	89 de                	mov    %ebx,%esi
  800d9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da1:	85 c0                	test   %eax,%eax
  800da3:	7e 17                	jle    800dbc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da5:	83 ec 0c             	sub    $0xc,%esp
  800da8:	50                   	push   %eax
  800da9:	6a 09                	push   $0x9
  800dab:	68 7f 2c 80 00       	push   $0x802c7f
  800db0:	6a 23                	push   $0x23
  800db2:	68 9c 2c 80 00       	push   $0x802c9c
  800db7:	e8 5c f4 ff ff       	call   800218 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dda:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddd:	89 df                	mov    %ebx,%edi
  800ddf:	89 de                	mov    %ebx,%esi
  800de1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de3:	85 c0                	test   %eax,%eax
  800de5:	7e 17                	jle    800dfe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de7:	83 ec 0c             	sub    $0xc,%esp
  800dea:	50                   	push   %eax
  800deb:	6a 0a                	push   $0xa
  800ded:	68 7f 2c 80 00       	push   $0x802c7f
  800df2:	6a 23                	push   $0x23
  800df4:	68 9c 2c 80 00       	push   $0x802c9c
  800df9:	e8 1a f4 ff ff       	call   800218 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	57                   	push   %edi
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0c:	be 00 00 00 00       	mov    $0x0,%esi
  800e11:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e19:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e22:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e37:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3f:	89 cb                	mov    %ecx,%ebx
  800e41:	89 cf                	mov    %ecx,%edi
  800e43:	89 ce                	mov    %ecx,%esi
  800e45:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e47:	85 c0                	test   %eax,%eax
  800e49:	7e 17                	jle    800e62 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4b:	83 ec 0c             	sub    $0xc,%esp
  800e4e:	50                   	push   %eax
  800e4f:	6a 0d                	push   $0xd
  800e51:	68 7f 2c 80 00       	push   $0x802c7f
  800e56:	6a 23                	push   $0x23
  800e58:	68 9c 2c 80 00       	push   $0x802c9c
  800e5d:	e8 b6 f3 ff ff       	call   800218 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	57                   	push   %edi
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e70:	ba 00 00 00 00       	mov    $0x0,%edx
  800e75:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e7a:	89 d1                	mov    %edx,%ecx
  800e7c:	89 d3                	mov    %edx,%ebx
  800e7e:	89 d7                	mov    %edx,%edi
  800e80:	89 d6                	mov    %edx,%esi
  800e82:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_transmit_packet>:

int
sys_transmit_packet(void *buf, size_t size)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
  800e8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e97:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea2:	89 df                	mov    %ebx,%edi
  800ea4:	89 de                	mov    %ebx,%esi
  800ea6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ea8:	85 c0                	test   %eax,%eax
  800eaa:	7e 17                	jle    800ec3 <sys_transmit_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eac:	83 ec 0c             	sub    $0xc,%esp
  800eaf:	50                   	push   %eax
  800eb0:	6a 0f                	push   $0xf
  800eb2:	68 7f 2c 80 00       	push   $0x802c7f
  800eb7:	6a 23                	push   $0x23
  800eb9:	68 9c 2c 80 00       	push   $0x802c9c
  800ebe:	e8 55 f3 ff ff       	call   800218 <_panic>
int
sys_transmit_packet(void *buf, size_t size)
{
	return syscall(SYS_transmit_packet, 1,
		(uint32_t) buf, (uint32_t) size, 0, 0, 0);
}
  800ec3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec6:	5b                   	pop    %ebx
  800ec7:	5e                   	pop    %esi
  800ec8:	5f                   	pop    %edi
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <sys_receive_packet>:

int
sys_receive_packet(void *buf, size_t *size_store)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	57                   	push   %edi
  800ecf:	56                   	push   %esi
  800ed0:	53                   	push   %ebx
  800ed1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed9:	b8 10 00 00 00       	mov    $0x10,%eax
  800ede:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee4:	89 df                	mov    %ebx,%edi
  800ee6:	89 de                	mov    %ebx,%esi
  800ee8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eea:	85 c0                	test   %eax,%eax
  800eec:	7e 17                	jle    800f05 <sys_receive_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eee:	83 ec 0c             	sub    $0xc,%esp
  800ef1:	50                   	push   %eax
  800ef2:	6a 10                	push   $0x10
  800ef4:	68 7f 2c 80 00       	push   $0x802c7f
  800ef9:	6a 23                	push   $0x23
  800efb:	68 9c 2c 80 00       	push   $0x802c9c
  800f00:	e8 13 f3 ff ff       	call   800218 <_panic>
int
sys_receive_packet(void *buf, size_t *size_store)
{
	return syscall(SYS_receive_packet, 1,
		(uint32_t) buf, (uint32_t) size_store, 0, 0, 0);
}
  800f05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f08:	5b                   	pop    %ebx
  800f09:	5e                   	pop    %esi
  800f0a:	5f                   	pop    %edi
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    

00800f0d <sys_get_mac_address>:

int
sys_get_mac_address(void *buf)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	57                   	push   %edi
  800f11:	56                   	push   %esi
  800f12:	53                   	push   %ebx
  800f13:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f16:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f1b:	b8 11 00 00 00       	mov    $0x11,%eax
  800f20:	8b 55 08             	mov    0x8(%ebp),%edx
  800f23:	89 cb                	mov    %ecx,%ebx
  800f25:	89 cf                	mov    %ecx,%edi
  800f27:	89 ce                	mov    %ecx,%esi
  800f29:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f2b:	85 c0                	test   %eax,%eax
  800f2d:	7e 17                	jle    800f46 <sys_get_mac_address+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2f:	83 ec 0c             	sub    $0xc,%esp
  800f32:	50                   	push   %eax
  800f33:	6a 11                	push   $0x11
  800f35:	68 7f 2c 80 00       	push   $0x802c7f
  800f3a:	6a 23                	push   $0x23
  800f3c:	68 9c 2c 80 00       	push   $0x802c9c
  800f41:	e8 d2 f2 ff ff       	call   800218 <_panic>
int
sys_get_mac_address(void *buf)
{
	return syscall(SYS_get_mac_address, 1,
		(uint32_t) buf, 0, 0, 0, 0);
}
  800f46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f49:	5b                   	pop    %ebx
  800f4a:	5e                   	pop    %esi
  800f4b:	5f                   	pop    %edi
  800f4c:	5d                   	pop    %ebp
  800f4d:	c3                   	ret    

00800f4e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	53                   	push   %ebx
  800f52:	83 ec 04             	sub    $0x4,%esp
  800f55:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f58:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800f5a:	89 da                	mov    %ebx,%edx
  800f5c:	c1 ea 0c             	shr    $0xc,%edx
	pte_t pte = uvpt[pn];
  800f5f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  800f66:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f6a:	74 05                	je     800f71 <pgfault+0x23>
  800f6c:	f6 c6 08             	test   $0x8,%dh
  800f6f:	75 14                	jne    800f85 <pgfault+0x37>
		panic("fork pgfault handler: does not handle this fault");
  800f71:	83 ec 04             	sub    $0x4,%esp
  800f74:	68 ac 2c 80 00       	push   $0x802cac
  800f79:	6a 1f                	push   $0x1f
  800f7b:	68 dd 2c 80 00       	push   $0x802cdd
  800f80:	e8 93 f2 ff ff       	call   800218 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800f85:	83 ec 04             	sub    $0x4,%esp
  800f88:	6a 07                	push   $0x7
  800f8a:	68 00 f0 7f 00       	push   $0x7ff000
  800f8f:	6a 00                	push   $0x0
  800f91:	e8 e3 fc ff ff       	call   800c79 <sys_page_alloc>
  800f96:	83 c4 10             	add    $0x10,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	79 12                	jns    800faf <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  800f9d:	50                   	push   %eax
  800f9e:	68 e8 2c 80 00       	push   $0x802ce8
  800fa3:	6a 2b                	push   $0x2b
  800fa5:	68 dd 2c 80 00       	push   $0x802cdd
  800faa:	e8 69 f2 ff ff       	call   800218 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800faf:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800fb5:	83 ec 04             	sub    $0x4,%esp
  800fb8:	68 00 10 00 00       	push   $0x1000
  800fbd:	53                   	push   %ebx
  800fbe:	68 00 f0 7f 00       	push   $0x7ff000
  800fc3:	e8 40 fa ff ff       	call   800a08 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800fc8:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fcf:	53                   	push   %ebx
  800fd0:	6a 00                	push   $0x0
  800fd2:	68 00 f0 7f 00       	push   $0x7ff000
  800fd7:	6a 00                	push   $0x0
  800fd9:	e8 de fc ff ff       	call   800cbc <sys_page_map>
  800fde:	83 c4 20             	add    $0x20,%esp
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	79 12                	jns    800ff7 <pgfault+0xa9>
		panic("sys_page_map: %e", r);
  800fe5:	50                   	push   %eax
  800fe6:	68 fb 2c 80 00       	push   $0x802cfb
  800feb:	6a 33                	push   $0x33
  800fed:	68 dd 2c 80 00       	push   $0x802cdd
  800ff2:	e8 21 f2 ff ff       	call   800218 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800ff7:	83 ec 08             	sub    $0x8,%esp
  800ffa:	68 00 f0 7f 00       	push   $0x7ff000
  800fff:	6a 00                	push   $0x0
  801001:	e8 f8 fc ff ff       	call   800cfe <sys_page_unmap>
  801006:	83 c4 10             	add    $0x10,%esp
  801009:	85 c0                	test   %eax,%eax
  80100b:	79 12                	jns    80101f <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  80100d:	50                   	push   %eax
  80100e:	68 0c 2d 80 00       	push   $0x802d0c
  801013:	6a 37                	push   $0x37
  801015:	68 dd 2c 80 00       	push   $0x802cdd
  80101a:	e8 f9 f1 ff ff       	call   800218 <_panic>
}
  80101f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801022:	c9                   	leave  
  801023:	c3                   	ret    

00801024 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	57                   	push   %edi
  801028:	56                   	push   %esi
  801029:	53                   	push   %ebx
  80102a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  80102d:	68 4e 0f 80 00       	push   $0x800f4e
  801032:	e8 95 13 00 00       	call   8023cc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801037:	b8 07 00 00 00       	mov    $0x7,%eax
  80103c:	cd 30                	int    $0x30
  80103e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801041:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Create child
	envid_t envid = sys_exofork();
	if (envid < 0) {
  801044:	83 c4 10             	add    $0x10,%esp
  801047:	85 c0                	test   %eax,%eax
  801049:	79 15                	jns    801060 <fork+0x3c>
		panic("sys_exofork: %e", envid);
  80104b:	50                   	push   %eax
  80104c:	68 1f 2d 80 00       	push   $0x802d1f
  801051:	68 93 00 00 00       	push   $0x93
  801056:	68 dd 2c 80 00       	push   $0x802cdd
  80105b:	e8 b8 f1 ff ff       	call   800218 <_panic>
		return envid;
	}

	// If we are the child, fix thisenv.
	if (envid == 0) {
  801060:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801064:	75 21                	jne    801087 <fork+0x63>
		thisenv = &envs[ENVX(sys_getenvid())];
  801066:	e8 d0 fb ff ff       	call   800c3b <sys_getenvid>
  80106b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801070:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801078:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  80107d:	b8 00 00 00 00       	mov    $0x0,%eax
  801082:	e9 5a 01 00 00       	jmp    8011e1 <fork+0x1bd>
	// We are the parent!
	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle the
	// fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), PTE_P | PTE_U | PTE_W);
  801087:	83 ec 04             	sub    $0x4,%esp
  80108a:	6a 07                	push   $0x7
  80108c:	68 00 f0 bf ee       	push   $0xeebff000
  801091:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801094:	57                   	push   %edi
  801095:	e8 df fb ff ff       	call   800c79 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  80109a:	83 c4 08             	add    $0x8,%esp
  80109d:	68 11 24 80 00       	push   $0x802411
  8010a2:	57                   	push   %edi
  8010a3:	e8 1c fd ff ff       	call   800dc4 <sys_env_set_pgfault_upcall>
  8010a8:	83 c4 10             	add    $0x10,%esp

	// Copy our address space to child. Be careful not to copy the exception
	// stack too, so go until USTACKTOP instead of UTOP.
	unsigned pn;
	for (pn = UTEXT/PGSIZE; pn < USTACKTOP/PGSIZE; pn++) {
  8010ab:	bb 00 08 00 00       	mov    $0x800,%ebx
static int
duppage(envid_t envid, unsigned pn)
{
	// Check if the page table that contains the PTE we want is allocated
	// using UVPD. If it is not, just don't map anything, and silently succeed.
	if (!(uvpd[pn/NPTENTRIES] & PTE_P))
  8010b0:	89 d8                	mov    %ebx,%eax
  8010b2:	c1 e8 0a             	shr    $0xa,%eax
  8010b5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010bc:	a8 01                	test   $0x1,%al
  8010be:	0f 84 e2 00 00 00    	je     8011a6 <fork+0x182>
		return 0;

	// Retrieve the PTE using UVPT
	pte_t pte = uvpt[pn];
  8010c4:	8b 34 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%esi

	// If the page is present, duplicate according to it's permissions
	if (pte & PTE_P) {
  8010cb:	f7 c6 01 00 00 00    	test   $0x1,%esi
  8010d1:	0f 84 cf 00 00 00    	je     8011a6 <fork+0x182>
		int r;
		uint32_t perm = pte & PTE_SYSCALL;
  8010d7:	89 f0                	mov    %esi,%eax
  8010d9:	25 07 0e 00 00       	and    $0xe07,%eax
  8010de:	89 df                	mov    %ebx,%edi
  8010e0:	c1 e7 0c             	shl    $0xc,%edi
		void *va = (void *) (pn * PGSIZE);

		// If PTE_SHARE is enabled, share it by just copying the
		// pte, which can be done by mapping on the same address
		// with the same permissions, even if it is writable
		if (pte & PTE_SHARE) {
  8010e3:	f7 c6 00 04 00 00    	test   $0x400,%esi
  8010e9:	74 2d                	je     801118 <fork+0xf4>
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  8010eb:	83 ec 0c             	sub    $0xc,%esp
  8010ee:	50                   	push   %eax
  8010ef:	57                   	push   %edi
  8010f0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f3:	57                   	push   %edi
  8010f4:	6a 00                	push   $0x0
  8010f6:	e8 c1 fb ff ff       	call   800cbc <sys_page_map>
  8010fb:	83 c4 20             	add    $0x20,%esp
  8010fe:	85 c0                	test   %eax,%eax
  801100:	0f 89 a0 00 00 00    	jns    8011a6 <fork+0x182>
				panic("sys_page_map: %e", r);
  801106:	50                   	push   %eax
  801107:	68 fb 2c 80 00       	push   $0x802cfb
  80110c:	6a 5c                	push   $0x5c
  80110e:	68 dd 2c 80 00       	push   $0x802cdd
  801113:	e8 00 f1 ff ff       	call   800218 <_panic>
				return r;
			}
		// If writable or COW, make it COW on parent and child
		} else if (pte & (PTE_W | PTE_COW)) {
  801118:	f7 c6 02 08 00 00    	test   $0x802,%esi
  80111e:	74 5d                	je     80117d <fork+0x159>
			perm &= ~PTE_W;  // Remove PTE_W, so it faults
  801120:	81 e6 05 0e 00 00    	and    $0xe05,%esi
			perm |= PTE_COW; // Make it PTE_COW
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  801126:	81 ce 00 08 00 00    	or     $0x800,%esi
  80112c:	83 ec 0c             	sub    $0xc,%esp
  80112f:	56                   	push   %esi
  801130:	57                   	push   %edi
  801131:	ff 75 e4             	pushl  -0x1c(%ebp)
  801134:	57                   	push   %edi
  801135:	6a 00                	push   $0x0
  801137:	e8 80 fb ff ff       	call   800cbc <sys_page_map>
  80113c:	83 c4 20             	add    $0x20,%esp
  80113f:	85 c0                	test   %eax,%eax
  801141:	79 12                	jns    801155 <fork+0x131>
				panic("sys_page_map: %e", r);
  801143:	50                   	push   %eax
  801144:	68 fb 2c 80 00       	push   $0x802cfb
  801149:	6a 65                	push   $0x65
  80114b:	68 dd 2c 80 00       	push   $0x802cdd
  801150:	e8 c3 f0 ff ff       	call   800218 <_panic>
				return r;
			}
			// Change the permission on parent, mapping on itself
			if ((r = sys_page_map(0, va, 0, va, perm)) < 0) {
  801155:	83 ec 0c             	sub    $0xc,%esp
  801158:	56                   	push   %esi
  801159:	57                   	push   %edi
  80115a:	6a 00                	push   $0x0
  80115c:	57                   	push   %edi
  80115d:	6a 00                	push   $0x0
  80115f:	e8 58 fb ff ff       	call   800cbc <sys_page_map>
  801164:	83 c4 20             	add    $0x20,%esp
  801167:	85 c0                	test   %eax,%eax
  801169:	79 3b                	jns    8011a6 <fork+0x182>
				panic("sys_page_map: %e", r);
  80116b:	50                   	push   %eax
  80116c:	68 fb 2c 80 00       	push   $0x802cfb
  801171:	6a 6a                	push   $0x6a
  801173:	68 dd 2c 80 00       	push   $0x802cdd
  801178:	e8 9b f0 ff ff       	call   800218 <_panic>
				return r;
			}
		// If it is read-only, just share it.
		} else {
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  80117d:	83 ec 0c             	sub    $0xc,%esp
  801180:	50                   	push   %eax
  801181:	57                   	push   %edi
  801182:	ff 75 e4             	pushl  -0x1c(%ebp)
  801185:	57                   	push   %edi
  801186:	6a 00                	push   $0x0
  801188:	e8 2f fb ff ff       	call   800cbc <sys_page_map>
  80118d:	83 c4 20             	add    $0x20,%esp
  801190:	85 c0                	test   %eax,%eax
  801192:	79 12                	jns    8011a6 <fork+0x182>
				panic("sys_page_map: %e", r);
  801194:	50                   	push   %eax
  801195:	68 fb 2c 80 00       	push   $0x802cfb
  80119a:	6a 71                	push   $0x71
  80119c:	68 dd 2c 80 00       	push   $0x802cdd
  8011a1:	e8 72 f0 ff ff       	call   800218 <_panic>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);

	// Copy our address space to child. Be careful not to copy the exception
	// stack too, so go until USTACKTOP instead of UTOP.
	unsigned pn;
	for (pn = UTEXT/PGSIZE; pn < USTACKTOP/PGSIZE; pn++) {
  8011a6:	83 c3 01             	add    $0x1,%ebx
  8011a9:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  8011af:	0f 85 fb fe ff ff    	jne    8010b0 <fork+0x8c>
		duppage(envid, pn);
	}

	// Make the child runnable
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8011b5:	83 ec 08             	sub    $0x8,%esp
  8011b8:	6a 02                	push   $0x2
  8011ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8011bd:	e8 7e fb ff ff       	call   800d40 <sys_env_set_status>
  8011c2:	83 c4 10             	add    $0x10,%esp
  8011c5:	85 c0                	test   %eax,%eax
  8011c7:	79 15                	jns    8011de <fork+0x1ba>
		panic("sys_env_set_status: %e", r);
  8011c9:	50                   	push   %eax
  8011ca:	68 2f 2d 80 00       	push   $0x802d2f
  8011cf:	68 af 00 00 00       	push   $0xaf
  8011d4:	68 dd 2c 80 00       	push   $0x802cdd
  8011d9:	e8 3a f0 ff ff       	call   800218 <_panic>
		return r;
	}

	return envid;
  8011de:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  8011e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e4:	5b                   	pop    %ebx
  8011e5:	5e                   	pop    %esi
  8011e6:	5f                   	pop    %edi
  8011e7:	5d                   	pop    %ebp
  8011e8:	c3                   	ret    

008011e9 <sfork>:

// Challenge!
int
sfork(void)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011ef:	68 46 2d 80 00       	push   $0x802d46
  8011f4:	68 ba 00 00 00       	push   $0xba
  8011f9:	68 dd 2c 80 00       	push   $0x802cdd
  8011fe:	e8 15 f0 ff ff       	call   800218 <_panic>

00801203 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801206:	8b 45 08             	mov    0x8(%ebp),%eax
  801209:	05 00 00 00 30       	add    $0x30000000,%eax
  80120e:	c1 e8 0c             	shr    $0xc,%eax
}
  801211:	5d                   	pop    %ebp
  801212:	c3                   	ret    

00801213 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801216:	8b 45 08             	mov    0x8(%ebp),%eax
  801219:	05 00 00 00 30       	add    $0x30000000,%eax
  80121e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801223:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801228:	5d                   	pop    %ebp
  801229:	c3                   	ret    

0080122a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
  80122d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801230:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801235:	89 c2                	mov    %eax,%edx
  801237:	c1 ea 16             	shr    $0x16,%edx
  80123a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801241:	f6 c2 01             	test   $0x1,%dl
  801244:	74 11                	je     801257 <fd_alloc+0x2d>
  801246:	89 c2                	mov    %eax,%edx
  801248:	c1 ea 0c             	shr    $0xc,%edx
  80124b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801252:	f6 c2 01             	test   $0x1,%dl
  801255:	75 09                	jne    801260 <fd_alloc+0x36>
			*fd_store = fd;
  801257:	89 01                	mov    %eax,(%ecx)
			return 0;
  801259:	b8 00 00 00 00       	mov    $0x0,%eax
  80125e:	eb 17                	jmp    801277 <fd_alloc+0x4d>
  801260:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801265:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80126a:	75 c9                	jne    801235 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80126c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801272:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801277:	5d                   	pop    %ebp
  801278:	c3                   	ret    

00801279 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80127f:	83 f8 1f             	cmp    $0x1f,%eax
  801282:	77 36                	ja     8012ba <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801284:	c1 e0 0c             	shl    $0xc,%eax
  801287:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80128c:	89 c2                	mov    %eax,%edx
  80128e:	c1 ea 16             	shr    $0x16,%edx
  801291:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801298:	f6 c2 01             	test   $0x1,%dl
  80129b:	74 24                	je     8012c1 <fd_lookup+0x48>
  80129d:	89 c2                	mov    %eax,%edx
  80129f:	c1 ea 0c             	shr    $0xc,%edx
  8012a2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012a9:	f6 c2 01             	test   $0x1,%dl
  8012ac:	74 1a                	je     8012c8 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b1:	89 02                	mov    %eax,(%edx)
	return 0;
  8012b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b8:	eb 13                	jmp    8012cd <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012bf:	eb 0c                	jmp    8012cd <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c6:	eb 05                	jmp    8012cd <fd_lookup+0x54>
  8012c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012cd:	5d                   	pop    %ebp
  8012ce:	c3                   	ret    

008012cf <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	83 ec 08             	sub    $0x8,%esp
  8012d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d8:	ba dc 2d 80 00       	mov    $0x802ddc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012dd:	eb 13                	jmp    8012f2 <dev_lookup+0x23>
  8012df:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012e2:	39 08                	cmp    %ecx,(%eax)
  8012e4:	75 0c                	jne    8012f2 <dev_lookup+0x23>
			*dev = devtab[i];
  8012e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f0:	eb 2e                	jmp    801320 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012f2:	8b 02                	mov    (%edx),%eax
  8012f4:	85 c0                	test   %eax,%eax
  8012f6:	75 e7                	jne    8012df <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012f8:	a1 20 44 80 00       	mov    0x804420,%eax
  8012fd:	8b 40 48             	mov    0x48(%eax),%eax
  801300:	83 ec 04             	sub    $0x4,%esp
  801303:	51                   	push   %ecx
  801304:	50                   	push   %eax
  801305:	68 5c 2d 80 00       	push   $0x802d5c
  80130a:	e8 e2 ef ff ff       	call   8002f1 <cprintf>
	*dev = 0;
  80130f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801312:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801318:	83 c4 10             	add    $0x10,%esp
  80131b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801320:	c9                   	leave  
  801321:	c3                   	ret    

00801322 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	56                   	push   %esi
  801326:	53                   	push   %ebx
  801327:	83 ec 10             	sub    $0x10,%esp
  80132a:	8b 75 08             	mov    0x8(%ebp),%esi
  80132d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801330:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801333:	50                   	push   %eax
  801334:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80133a:	c1 e8 0c             	shr    $0xc,%eax
  80133d:	50                   	push   %eax
  80133e:	e8 36 ff ff ff       	call   801279 <fd_lookup>
  801343:	83 c4 08             	add    $0x8,%esp
  801346:	85 c0                	test   %eax,%eax
  801348:	78 05                	js     80134f <fd_close+0x2d>
	    || fd != fd2)
  80134a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80134d:	74 0c                	je     80135b <fd_close+0x39>
		return (must_exist ? r : 0);
  80134f:	84 db                	test   %bl,%bl
  801351:	ba 00 00 00 00       	mov    $0x0,%edx
  801356:	0f 44 c2             	cmove  %edx,%eax
  801359:	eb 41                	jmp    80139c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80135b:	83 ec 08             	sub    $0x8,%esp
  80135e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801361:	50                   	push   %eax
  801362:	ff 36                	pushl  (%esi)
  801364:	e8 66 ff ff ff       	call   8012cf <dev_lookup>
  801369:	89 c3                	mov    %eax,%ebx
  80136b:	83 c4 10             	add    $0x10,%esp
  80136e:	85 c0                	test   %eax,%eax
  801370:	78 1a                	js     80138c <fd_close+0x6a>
		if (dev->dev_close)
  801372:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801375:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801378:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80137d:	85 c0                	test   %eax,%eax
  80137f:	74 0b                	je     80138c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801381:	83 ec 0c             	sub    $0xc,%esp
  801384:	56                   	push   %esi
  801385:	ff d0                	call   *%eax
  801387:	89 c3                	mov    %eax,%ebx
  801389:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80138c:	83 ec 08             	sub    $0x8,%esp
  80138f:	56                   	push   %esi
  801390:	6a 00                	push   $0x0
  801392:	e8 67 f9 ff ff       	call   800cfe <sys_page_unmap>
	return r;
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	89 d8                	mov    %ebx,%eax
}
  80139c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80139f:	5b                   	pop    %ebx
  8013a0:	5e                   	pop    %esi
  8013a1:	5d                   	pop    %ebp
  8013a2:	c3                   	ret    

008013a3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ac:	50                   	push   %eax
  8013ad:	ff 75 08             	pushl  0x8(%ebp)
  8013b0:	e8 c4 fe ff ff       	call   801279 <fd_lookup>
  8013b5:	83 c4 08             	add    $0x8,%esp
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	78 10                	js     8013cc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013bc:	83 ec 08             	sub    $0x8,%esp
  8013bf:	6a 01                	push   $0x1
  8013c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8013c4:	e8 59 ff ff ff       	call   801322 <fd_close>
  8013c9:	83 c4 10             	add    $0x10,%esp
}
  8013cc:	c9                   	leave  
  8013cd:	c3                   	ret    

008013ce <close_all>:

void
close_all(void)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	53                   	push   %ebx
  8013d2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013d5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013da:	83 ec 0c             	sub    $0xc,%esp
  8013dd:	53                   	push   %ebx
  8013de:	e8 c0 ff ff ff       	call   8013a3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013e3:	83 c3 01             	add    $0x1,%ebx
  8013e6:	83 c4 10             	add    $0x10,%esp
  8013e9:	83 fb 20             	cmp    $0x20,%ebx
  8013ec:	75 ec                	jne    8013da <close_all+0xc>
		close(i);
}
  8013ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f1:	c9                   	leave  
  8013f2:	c3                   	ret    

008013f3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013f3:	55                   	push   %ebp
  8013f4:	89 e5                	mov    %esp,%ebp
  8013f6:	57                   	push   %edi
  8013f7:	56                   	push   %esi
  8013f8:	53                   	push   %ebx
  8013f9:	83 ec 2c             	sub    $0x2c,%esp
  8013fc:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013ff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801402:	50                   	push   %eax
  801403:	ff 75 08             	pushl  0x8(%ebp)
  801406:	e8 6e fe ff ff       	call   801279 <fd_lookup>
  80140b:	83 c4 08             	add    $0x8,%esp
  80140e:	85 c0                	test   %eax,%eax
  801410:	0f 88 c1 00 00 00    	js     8014d7 <dup+0xe4>
		return r;
	close(newfdnum);
  801416:	83 ec 0c             	sub    $0xc,%esp
  801419:	56                   	push   %esi
  80141a:	e8 84 ff ff ff       	call   8013a3 <close>

	newfd = INDEX2FD(newfdnum);
  80141f:	89 f3                	mov    %esi,%ebx
  801421:	c1 e3 0c             	shl    $0xc,%ebx
  801424:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80142a:	83 c4 04             	add    $0x4,%esp
  80142d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801430:	e8 de fd ff ff       	call   801213 <fd2data>
  801435:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801437:	89 1c 24             	mov    %ebx,(%esp)
  80143a:	e8 d4 fd ff ff       	call   801213 <fd2data>
  80143f:	83 c4 10             	add    $0x10,%esp
  801442:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801445:	89 f8                	mov    %edi,%eax
  801447:	c1 e8 16             	shr    $0x16,%eax
  80144a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801451:	a8 01                	test   $0x1,%al
  801453:	74 37                	je     80148c <dup+0x99>
  801455:	89 f8                	mov    %edi,%eax
  801457:	c1 e8 0c             	shr    $0xc,%eax
  80145a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801461:	f6 c2 01             	test   $0x1,%dl
  801464:	74 26                	je     80148c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801466:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80146d:	83 ec 0c             	sub    $0xc,%esp
  801470:	25 07 0e 00 00       	and    $0xe07,%eax
  801475:	50                   	push   %eax
  801476:	ff 75 d4             	pushl  -0x2c(%ebp)
  801479:	6a 00                	push   $0x0
  80147b:	57                   	push   %edi
  80147c:	6a 00                	push   $0x0
  80147e:	e8 39 f8 ff ff       	call   800cbc <sys_page_map>
  801483:	89 c7                	mov    %eax,%edi
  801485:	83 c4 20             	add    $0x20,%esp
  801488:	85 c0                	test   %eax,%eax
  80148a:	78 2e                	js     8014ba <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80148c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80148f:	89 d0                	mov    %edx,%eax
  801491:	c1 e8 0c             	shr    $0xc,%eax
  801494:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80149b:	83 ec 0c             	sub    $0xc,%esp
  80149e:	25 07 0e 00 00       	and    $0xe07,%eax
  8014a3:	50                   	push   %eax
  8014a4:	53                   	push   %ebx
  8014a5:	6a 00                	push   $0x0
  8014a7:	52                   	push   %edx
  8014a8:	6a 00                	push   $0x0
  8014aa:	e8 0d f8 ff ff       	call   800cbc <sys_page_map>
  8014af:	89 c7                	mov    %eax,%edi
  8014b1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014b4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014b6:	85 ff                	test   %edi,%edi
  8014b8:	79 1d                	jns    8014d7 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014ba:	83 ec 08             	sub    $0x8,%esp
  8014bd:	53                   	push   %ebx
  8014be:	6a 00                	push   $0x0
  8014c0:	e8 39 f8 ff ff       	call   800cfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014c5:	83 c4 08             	add    $0x8,%esp
  8014c8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014cb:	6a 00                	push   $0x0
  8014cd:	e8 2c f8 ff ff       	call   800cfe <sys_page_unmap>
	return r;
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	89 f8                	mov    %edi,%eax
}
  8014d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014da:	5b                   	pop    %ebx
  8014db:	5e                   	pop    %esi
  8014dc:	5f                   	pop    %edi
  8014dd:	5d                   	pop    %ebp
  8014de:	c3                   	ret    

008014df <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
  8014e2:	53                   	push   %ebx
  8014e3:	83 ec 14             	sub    $0x14,%esp
  8014e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ec:	50                   	push   %eax
  8014ed:	53                   	push   %ebx
  8014ee:	e8 86 fd ff ff       	call   801279 <fd_lookup>
  8014f3:	83 c4 08             	add    $0x8,%esp
  8014f6:	89 c2                	mov    %eax,%edx
  8014f8:	85 c0                	test   %eax,%eax
  8014fa:	78 6d                	js     801569 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014fc:	83 ec 08             	sub    $0x8,%esp
  8014ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801502:	50                   	push   %eax
  801503:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801506:	ff 30                	pushl  (%eax)
  801508:	e8 c2 fd ff ff       	call   8012cf <dev_lookup>
  80150d:	83 c4 10             	add    $0x10,%esp
  801510:	85 c0                	test   %eax,%eax
  801512:	78 4c                	js     801560 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801514:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801517:	8b 42 08             	mov    0x8(%edx),%eax
  80151a:	83 e0 03             	and    $0x3,%eax
  80151d:	83 f8 01             	cmp    $0x1,%eax
  801520:	75 21                	jne    801543 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801522:	a1 20 44 80 00       	mov    0x804420,%eax
  801527:	8b 40 48             	mov    0x48(%eax),%eax
  80152a:	83 ec 04             	sub    $0x4,%esp
  80152d:	53                   	push   %ebx
  80152e:	50                   	push   %eax
  80152f:	68 a0 2d 80 00       	push   $0x802da0
  801534:	e8 b8 ed ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  801539:	83 c4 10             	add    $0x10,%esp
  80153c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801541:	eb 26                	jmp    801569 <read+0x8a>
	}
	if (!dev->dev_read)
  801543:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801546:	8b 40 08             	mov    0x8(%eax),%eax
  801549:	85 c0                	test   %eax,%eax
  80154b:	74 17                	je     801564 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80154d:	83 ec 04             	sub    $0x4,%esp
  801550:	ff 75 10             	pushl  0x10(%ebp)
  801553:	ff 75 0c             	pushl  0xc(%ebp)
  801556:	52                   	push   %edx
  801557:	ff d0                	call   *%eax
  801559:	89 c2                	mov    %eax,%edx
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	eb 09                	jmp    801569 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801560:	89 c2                	mov    %eax,%edx
  801562:	eb 05                	jmp    801569 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801564:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801569:	89 d0                	mov    %edx,%eax
  80156b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156e:	c9                   	leave  
  80156f:	c3                   	ret    

00801570 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	57                   	push   %edi
  801574:	56                   	push   %esi
  801575:	53                   	push   %ebx
  801576:	83 ec 0c             	sub    $0xc,%esp
  801579:	8b 7d 08             	mov    0x8(%ebp),%edi
  80157c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80157f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801584:	eb 21                	jmp    8015a7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801586:	83 ec 04             	sub    $0x4,%esp
  801589:	89 f0                	mov    %esi,%eax
  80158b:	29 d8                	sub    %ebx,%eax
  80158d:	50                   	push   %eax
  80158e:	89 d8                	mov    %ebx,%eax
  801590:	03 45 0c             	add    0xc(%ebp),%eax
  801593:	50                   	push   %eax
  801594:	57                   	push   %edi
  801595:	e8 45 ff ff ff       	call   8014df <read>
		if (m < 0)
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 10                	js     8015b1 <readn+0x41>
			return m;
		if (m == 0)
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	74 0a                	je     8015af <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015a5:	01 c3                	add    %eax,%ebx
  8015a7:	39 f3                	cmp    %esi,%ebx
  8015a9:	72 db                	jb     801586 <readn+0x16>
  8015ab:	89 d8                	mov    %ebx,%eax
  8015ad:	eb 02                	jmp    8015b1 <readn+0x41>
  8015af:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b4:	5b                   	pop    %ebx
  8015b5:	5e                   	pop    %esi
  8015b6:	5f                   	pop    %edi
  8015b7:	5d                   	pop    %ebp
  8015b8:	c3                   	ret    

008015b9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	53                   	push   %ebx
  8015bd:	83 ec 14             	sub    $0x14,%esp
  8015c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c6:	50                   	push   %eax
  8015c7:	53                   	push   %ebx
  8015c8:	e8 ac fc ff ff       	call   801279 <fd_lookup>
  8015cd:	83 c4 08             	add    $0x8,%esp
  8015d0:	89 c2                	mov    %eax,%edx
  8015d2:	85 c0                	test   %eax,%eax
  8015d4:	78 68                	js     80163e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d6:	83 ec 08             	sub    $0x8,%esp
  8015d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015dc:	50                   	push   %eax
  8015dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e0:	ff 30                	pushl  (%eax)
  8015e2:	e8 e8 fc ff ff       	call   8012cf <dev_lookup>
  8015e7:	83 c4 10             	add    $0x10,%esp
  8015ea:	85 c0                	test   %eax,%eax
  8015ec:	78 47                	js     801635 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f5:	75 21                	jne    801618 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f7:	a1 20 44 80 00       	mov    0x804420,%eax
  8015fc:	8b 40 48             	mov    0x48(%eax),%eax
  8015ff:	83 ec 04             	sub    $0x4,%esp
  801602:	53                   	push   %ebx
  801603:	50                   	push   %eax
  801604:	68 bc 2d 80 00       	push   $0x802dbc
  801609:	e8 e3 ec ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801616:	eb 26                	jmp    80163e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801618:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161b:	8b 52 0c             	mov    0xc(%edx),%edx
  80161e:	85 d2                	test   %edx,%edx
  801620:	74 17                	je     801639 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801622:	83 ec 04             	sub    $0x4,%esp
  801625:	ff 75 10             	pushl  0x10(%ebp)
  801628:	ff 75 0c             	pushl  0xc(%ebp)
  80162b:	50                   	push   %eax
  80162c:	ff d2                	call   *%edx
  80162e:	89 c2                	mov    %eax,%edx
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	eb 09                	jmp    80163e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801635:	89 c2                	mov    %eax,%edx
  801637:	eb 05                	jmp    80163e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801639:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80163e:	89 d0                	mov    %edx,%eax
  801640:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801643:	c9                   	leave  
  801644:	c3                   	ret    

00801645 <seek>:

int
seek(int fdnum, off_t offset)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80164b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80164e:	50                   	push   %eax
  80164f:	ff 75 08             	pushl  0x8(%ebp)
  801652:	e8 22 fc ff ff       	call   801279 <fd_lookup>
  801657:	83 c4 08             	add    $0x8,%esp
  80165a:	85 c0                	test   %eax,%eax
  80165c:	78 0e                	js     80166c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80165e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801661:	8b 55 0c             	mov    0xc(%ebp),%edx
  801664:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801667:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80166c:	c9                   	leave  
  80166d:	c3                   	ret    

0080166e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	53                   	push   %ebx
  801672:	83 ec 14             	sub    $0x14,%esp
  801675:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801678:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167b:	50                   	push   %eax
  80167c:	53                   	push   %ebx
  80167d:	e8 f7 fb ff ff       	call   801279 <fd_lookup>
  801682:	83 c4 08             	add    $0x8,%esp
  801685:	89 c2                	mov    %eax,%edx
  801687:	85 c0                	test   %eax,%eax
  801689:	78 65                	js     8016f0 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168b:	83 ec 08             	sub    $0x8,%esp
  80168e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801691:	50                   	push   %eax
  801692:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801695:	ff 30                	pushl  (%eax)
  801697:	e8 33 fc ff ff       	call   8012cf <dev_lookup>
  80169c:	83 c4 10             	add    $0x10,%esp
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	78 44                	js     8016e7 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016aa:	75 21                	jne    8016cd <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016ac:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016b1:	8b 40 48             	mov    0x48(%eax),%eax
  8016b4:	83 ec 04             	sub    $0x4,%esp
  8016b7:	53                   	push   %ebx
  8016b8:	50                   	push   %eax
  8016b9:	68 7c 2d 80 00       	push   $0x802d7c
  8016be:	e8 2e ec ff ff       	call   8002f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016c3:	83 c4 10             	add    $0x10,%esp
  8016c6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016cb:	eb 23                	jmp    8016f0 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016d0:	8b 52 18             	mov    0x18(%edx),%edx
  8016d3:	85 d2                	test   %edx,%edx
  8016d5:	74 14                	je     8016eb <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016d7:	83 ec 08             	sub    $0x8,%esp
  8016da:	ff 75 0c             	pushl  0xc(%ebp)
  8016dd:	50                   	push   %eax
  8016de:	ff d2                	call   *%edx
  8016e0:	89 c2                	mov    %eax,%edx
  8016e2:	83 c4 10             	add    $0x10,%esp
  8016e5:	eb 09                	jmp    8016f0 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e7:	89 c2                	mov    %eax,%edx
  8016e9:	eb 05                	jmp    8016f0 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016eb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016f0:	89 d0                	mov    %edx,%eax
  8016f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f5:	c9                   	leave  
  8016f6:	c3                   	ret    

008016f7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	53                   	push   %ebx
  8016fb:	83 ec 14             	sub    $0x14,%esp
  8016fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801701:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801704:	50                   	push   %eax
  801705:	ff 75 08             	pushl  0x8(%ebp)
  801708:	e8 6c fb ff ff       	call   801279 <fd_lookup>
  80170d:	83 c4 08             	add    $0x8,%esp
  801710:	89 c2                	mov    %eax,%edx
  801712:	85 c0                	test   %eax,%eax
  801714:	78 58                	js     80176e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801716:	83 ec 08             	sub    $0x8,%esp
  801719:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171c:	50                   	push   %eax
  80171d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801720:	ff 30                	pushl  (%eax)
  801722:	e8 a8 fb ff ff       	call   8012cf <dev_lookup>
  801727:	83 c4 10             	add    $0x10,%esp
  80172a:	85 c0                	test   %eax,%eax
  80172c:	78 37                	js     801765 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80172e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801731:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801735:	74 32                	je     801769 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801737:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80173a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801741:	00 00 00 
	stat->st_isdir = 0;
  801744:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80174b:	00 00 00 
	stat->st_dev = dev;
  80174e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801754:	83 ec 08             	sub    $0x8,%esp
  801757:	53                   	push   %ebx
  801758:	ff 75 f0             	pushl  -0x10(%ebp)
  80175b:	ff 50 14             	call   *0x14(%eax)
  80175e:	89 c2                	mov    %eax,%edx
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	eb 09                	jmp    80176e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801765:	89 c2                	mov    %eax,%edx
  801767:	eb 05                	jmp    80176e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801769:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80176e:	89 d0                	mov    %edx,%eax
  801770:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801773:	c9                   	leave  
  801774:	c3                   	ret    

00801775 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	56                   	push   %esi
  801779:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80177a:	83 ec 08             	sub    $0x8,%esp
  80177d:	6a 00                	push   $0x0
  80177f:	ff 75 08             	pushl  0x8(%ebp)
  801782:	e8 0c 02 00 00       	call   801993 <open>
  801787:	89 c3                	mov    %eax,%ebx
  801789:	83 c4 10             	add    $0x10,%esp
  80178c:	85 c0                	test   %eax,%eax
  80178e:	78 1b                	js     8017ab <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801790:	83 ec 08             	sub    $0x8,%esp
  801793:	ff 75 0c             	pushl  0xc(%ebp)
  801796:	50                   	push   %eax
  801797:	e8 5b ff ff ff       	call   8016f7 <fstat>
  80179c:	89 c6                	mov    %eax,%esi
	close(fd);
  80179e:	89 1c 24             	mov    %ebx,(%esp)
  8017a1:	e8 fd fb ff ff       	call   8013a3 <close>
	return r;
  8017a6:	83 c4 10             	add    $0x10,%esp
  8017a9:	89 f0                	mov    %esi,%eax
}
  8017ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ae:	5b                   	pop    %ebx
  8017af:	5e                   	pop    %esi
  8017b0:	5d                   	pop    %ebp
  8017b1:	c3                   	ret    

008017b2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	56                   	push   %esi
  8017b6:	53                   	push   %ebx
  8017b7:	89 c6                	mov    %eax,%esi
  8017b9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017bb:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017c2:	75 12                	jne    8017d6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017c4:	83 ec 0c             	sub    $0xc,%esp
  8017c7:	6a 01                	push   $0x1
  8017c9:	e8 31 0d 00 00       	call   8024ff <ipc_find_env>
  8017ce:	a3 00 40 80 00       	mov    %eax,0x804000
  8017d3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017d6:	6a 07                	push   $0x7
  8017d8:	68 00 50 80 00       	push   $0x805000
  8017dd:	56                   	push   %esi
  8017de:	ff 35 00 40 80 00    	pushl  0x804000
  8017e4:	e8 c2 0c 00 00       	call   8024ab <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017e9:	83 c4 0c             	add    $0xc,%esp
  8017ec:	6a 00                	push   $0x0
  8017ee:	53                   	push   %ebx
  8017ef:	6a 00                	push   $0x0
  8017f1:	e8 4c 0c 00 00       	call   802442 <ipc_recv>
}
  8017f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f9:	5b                   	pop    %ebx
  8017fa:	5e                   	pop    %esi
  8017fb:	5d                   	pop    %ebp
  8017fc:	c3                   	ret    

008017fd <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801803:	8b 45 08             	mov    0x8(%ebp),%eax
  801806:	8b 40 0c             	mov    0xc(%eax),%eax
  801809:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80180e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801811:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801816:	ba 00 00 00 00       	mov    $0x0,%edx
  80181b:	b8 02 00 00 00       	mov    $0x2,%eax
  801820:	e8 8d ff ff ff       	call   8017b2 <fsipc>
}
  801825:	c9                   	leave  
  801826:	c3                   	ret    

00801827 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80182d:	8b 45 08             	mov    0x8(%ebp),%eax
  801830:	8b 40 0c             	mov    0xc(%eax),%eax
  801833:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801838:	ba 00 00 00 00       	mov    $0x0,%edx
  80183d:	b8 06 00 00 00       	mov    $0x6,%eax
  801842:	e8 6b ff ff ff       	call   8017b2 <fsipc>
}
  801847:	c9                   	leave  
  801848:	c3                   	ret    

00801849 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801849:	55                   	push   %ebp
  80184a:	89 e5                	mov    %esp,%ebp
  80184c:	53                   	push   %ebx
  80184d:	83 ec 04             	sub    $0x4,%esp
  801850:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801853:	8b 45 08             	mov    0x8(%ebp),%eax
  801856:	8b 40 0c             	mov    0xc(%eax),%eax
  801859:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80185e:	ba 00 00 00 00       	mov    $0x0,%edx
  801863:	b8 05 00 00 00       	mov    $0x5,%eax
  801868:	e8 45 ff ff ff       	call   8017b2 <fsipc>
  80186d:	85 c0                	test   %eax,%eax
  80186f:	78 2c                	js     80189d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801871:	83 ec 08             	sub    $0x8,%esp
  801874:	68 00 50 80 00       	push   $0x805000
  801879:	53                   	push   %ebx
  80187a:	e8 f7 ef ff ff       	call   800876 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80187f:	a1 80 50 80 00       	mov    0x805080,%eax
  801884:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80188a:	a1 84 50 80 00       	mov    0x805084,%eax
  80188f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801895:	83 c4 10             	add    $0x10,%esp
  801898:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80189d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a0:	c9                   	leave  
  8018a1:	c3                   	ret    

008018a2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	53                   	push   %ebx
  8018a6:	83 ec 08             	sub    $0x8,%esp
  8018a9:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8018af:	8b 52 0c             	mov    0xc(%edx),%edx
  8018b2:	89 15 00 50 80 00    	mov    %edx,0x805000
  8018b8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018bd:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8018c2:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8018c5:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8018cb:	53                   	push   %ebx
  8018cc:	ff 75 0c             	pushl  0xc(%ebp)
  8018cf:	68 08 50 80 00       	push   $0x805008
  8018d4:	e8 2f f1 ff ff       	call   800a08 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  8018d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018de:	b8 04 00 00 00       	mov    $0x4,%eax
  8018e3:	e8 ca fe ff ff       	call   8017b2 <fsipc>
  8018e8:	83 c4 10             	add    $0x10,%esp
  8018eb:	85 c0                	test   %eax,%eax
  8018ed:	78 1d                	js     80190c <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  8018ef:	39 d8                	cmp    %ebx,%eax
  8018f1:	76 19                	jbe    80190c <devfile_write+0x6a>
  8018f3:	68 f0 2d 80 00       	push   $0x802df0
  8018f8:	68 fc 2d 80 00       	push   $0x802dfc
  8018fd:	68 a5 00 00 00       	push   $0xa5
  801902:	68 11 2e 80 00       	push   $0x802e11
  801907:	e8 0c e9 ff ff       	call   800218 <_panic>
	return r;
}
  80190c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190f:	c9                   	leave  
  801910:	c3                   	ret    

00801911 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	56                   	push   %esi
  801915:	53                   	push   %ebx
  801916:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801919:	8b 45 08             	mov    0x8(%ebp),%eax
  80191c:	8b 40 0c             	mov    0xc(%eax),%eax
  80191f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801924:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80192a:	ba 00 00 00 00       	mov    $0x0,%edx
  80192f:	b8 03 00 00 00       	mov    $0x3,%eax
  801934:	e8 79 fe ff ff       	call   8017b2 <fsipc>
  801939:	89 c3                	mov    %eax,%ebx
  80193b:	85 c0                	test   %eax,%eax
  80193d:	78 4b                	js     80198a <devfile_read+0x79>
		return r;
	assert(r <= n);
  80193f:	39 c6                	cmp    %eax,%esi
  801941:	73 16                	jae    801959 <devfile_read+0x48>
  801943:	68 1c 2e 80 00       	push   $0x802e1c
  801948:	68 fc 2d 80 00       	push   $0x802dfc
  80194d:	6a 7c                	push   $0x7c
  80194f:	68 11 2e 80 00       	push   $0x802e11
  801954:	e8 bf e8 ff ff       	call   800218 <_panic>
	assert(r <= PGSIZE);
  801959:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80195e:	7e 16                	jle    801976 <devfile_read+0x65>
  801960:	68 23 2e 80 00       	push   $0x802e23
  801965:	68 fc 2d 80 00       	push   $0x802dfc
  80196a:	6a 7d                	push   $0x7d
  80196c:	68 11 2e 80 00       	push   $0x802e11
  801971:	e8 a2 e8 ff ff       	call   800218 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801976:	83 ec 04             	sub    $0x4,%esp
  801979:	50                   	push   %eax
  80197a:	68 00 50 80 00       	push   $0x805000
  80197f:	ff 75 0c             	pushl  0xc(%ebp)
  801982:	e8 81 f0 ff ff       	call   800a08 <memmove>
	return r;
  801987:	83 c4 10             	add    $0x10,%esp
}
  80198a:	89 d8                	mov    %ebx,%eax
  80198c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198f:	5b                   	pop    %ebx
  801990:	5e                   	pop    %esi
  801991:	5d                   	pop    %ebp
  801992:	c3                   	ret    

00801993 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801993:	55                   	push   %ebp
  801994:	89 e5                	mov    %esp,%ebp
  801996:	53                   	push   %ebx
  801997:	83 ec 20             	sub    $0x20,%esp
  80199a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80199d:	53                   	push   %ebx
  80199e:	e8 9a ee ff ff       	call   80083d <strlen>
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019ab:	7f 67                	jg     801a14 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ad:	83 ec 0c             	sub    $0xc,%esp
  8019b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b3:	50                   	push   %eax
  8019b4:	e8 71 f8 ff ff       	call   80122a <fd_alloc>
  8019b9:	83 c4 10             	add    $0x10,%esp
		return r;
  8019bc:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019be:	85 c0                	test   %eax,%eax
  8019c0:	78 57                	js     801a19 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019c2:	83 ec 08             	sub    $0x8,%esp
  8019c5:	53                   	push   %ebx
  8019c6:	68 00 50 80 00       	push   $0x805000
  8019cb:	e8 a6 ee ff ff       	call   800876 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019db:	b8 01 00 00 00       	mov    $0x1,%eax
  8019e0:	e8 cd fd ff ff       	call   8017b2 <fsipc>
  8019e5:	89 c3                	mov    %eax,%ebx
  8019e7:	83 c4 10             	add    $0x10,%esp
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	79 14                	jns    801a02 <open+0x6f>
		fd_close(fd, 0);
  8019ee:	83 ec 08             	sub    $0x8,%esp
  8019f1:	6a 00                	push   $0x0
  8019f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f6:	e8 27 f9 ff ff       	call   801322 <fd_close>
		return r;
  8019fb:	83 c4 10             	add    $0x10,%esp
  8019fe:	89 da                	mov    %ebx,%edx
  801a00:	eb 17                	jmp    801a19 <open+0x86>
	}

	return fd2num(fd);
  801a02:	83 ec 0c             	sub    $0xc,%esp
  801a05:	ff 75 f4             	pushl  -0xc(%ebp)
  801a08:	e8 f6 f7 ff ff       	call   801203 <fd2num>
  801a0d:	89 c2                	mov    %eax,%edx
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	eb 05                	jmp    801a19 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a14:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a19:	89 d0                	mov    %edx,%eax
  801a1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1e:	c9                   	leave  
  801a1f:	c3                   	ret    

00801a20 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a26:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2b:	b8 08 00 00 00       	mov    $0x8,%eax
  801a30:	e8 7d fd ff ff       	call   8017b2 <fsipc>
}
  801a35:	c9                   	leave  
  801a36:	c3                   	ret    

00801a37 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a37:	55                   	push   %ebp
  801a38:	89 e5                	mov    %esp,%ebp
  801a3a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a3d:	68 2f 2e 80 00       	push   $0x802e2f
  801a42:	ff 75 0c             	pushl  0xc(%ebp)
  801a45:	e8 2c ee ff ff       	call   800876 <strcpy>
	return 0;
}
  801a4a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a4f:	c9                   	leave  
  801a50:	c3                   	ret    

00801a51 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a51:	55                   	push   %ebp
  801a52:	89 e5                	mov    %esp,%ebp
  801a54:	53                   	push   %ebx
  801a55:	83 ec 10             	sub    $0x10,%esp
  801a58:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a5b:	53                   	push   %ebx
  801a5c:	e8 d7 0a 00 00       	call   802538 <pageref>
  801a61:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a64:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a69:	83 f8 01             	cmp    $0x1,%eax
  801a6c:	75 10                	jne    801a7e <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a6e:	83 ec 0c             	sub    $0xc,%esp
  801a71:	ff 73 0c             	pushl  0xc(%ebx)
  801a74:	e8 c0 02 00 00       	call   801d39 <nsipc_close>
  801a79:	89 c2                	mov    %eax,%edx
  801a7b:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a7e:	89 d0                	mov    %edx,%eax
  801a80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a83:	c9                   	leave  
  801a84:	c3                   	ret    

00801a85 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a85:	55                   	push   %ebp
  801a86:	89 e5                	mov    %esp,%ebp
  801a88:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a8b:	6a 00                	push   $0x0
  801a8d:	ff 75 10             	pushl  0x10(%ebp)
  801a90:	ff 75 0c             	pushl  0xc(%ebp)
  801a93:	8b 45 08             	mov    0x8(%ebp),%eax
  801a96:	ff 70 0c             	pushl  0xc(%eax)
  801a99:	e8 78 03 00 00       	call   801e16 <nsipc_send>
}
  801a9e:	c9                   	leave  
  801a9f:	c3                   	ret    

00801aa0 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801aa6:	6a 00                	push   $0x0
  801aa8:	ff 75 10             	pushl  0x10(%ebp)
  801aab:	ff 75 0c             	pushl  0xc(%ebp)
  801aae:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab1:	ff 70 0c             	pushl  0xc(%eax)
  801ab4:	e8 f1 02 00 00       	call   801daa <nsipc_recv>
}
  801ab9:	c9                   	leave  
  801aba:	c3                   	ret    

00801abb <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801ac1:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ac4:	52                   	push   %edx
  801ac5:	50                   	push   %eax
  801ac6:	e8 ae f7 ff ff       	call   801279 <fd_lookup>
  801acb:	83 c4 10             	add    $0x10,%esp
  801ace:	85 c0                	test   %eax,%eax
  801ad0:	78 17                	js     801ae9 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad5:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801adb:	39 08                	cmp    %ecx,(%eax)
  801add:	75 05                	jne    801ae4 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801adf:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae2:	eb 05                	jmp    801ae9 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801ae4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801ae9:	c9                   	leave  
  801aea:	c3                   	ret    

00801aeb <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801aeb:	55                   	push   %ebp
  801aec:	89 e5                	mov    %esp,%ebp
  801aee:	56                   	push   %esi
  801aef:	53                   	push   %ebx
  801af0:	83 ec 1c             	sub    $0x1c,%esp
  801af3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801af5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801af8:	50                   	push   %eax
  801af9:	e8 2c f7 ff ff       	call   80122a <fd_alloc>
  801afe:	89 c3                	mov    %eax,%ebx
  801b00:	83 c4 10             	add    $0x10,%esp
  801b03:	85 c0                	test   %eax,%eax
  801b05:	78 1b                	js     801b22 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b07:	83 ec 04             	sub    $0x4,%esp
  801b0a:	68 07 04 00 00       	push   $0x407
  801b0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b12:	6a 00                	push   $0x0
  801b14:	e8 60 f1 ff ff       	call   800c79 <sys_page_alloc>
  801b19:	89 c3                	mov    %eax,%ebx
  801b1b:	83 c4 10             	add    $0x10,%esp
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	79 10                	jns    801b32 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b22:	83 ec 0c             	sub    $0xc,%esp
  801b25:	56                   	push   %esi
  801b26:	e8 0e 02 00 00       	call   801d39 <nsipc_close>
		return r;
  801b2b:	83 c4 10             	add    $0x10,%esp
  801b2e:	89 d8                	mov    %ebx,%eax
  801b30:	eb 24                	jmp    801b56 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b32:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b3b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b40:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b47:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b4a:	83 ec 0c             	sub    $0xc,%esp
  801b4d:	50                   	push   %eax
  801b4e:	e8 b0 f6 ff ff       	call   801203 <fd2num>
  801b53:	83 c4 10             	add    $0x10,%esp
}
  801b56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b59:	5b                   	pop    %ebx
  801b5a:	5e                   	pop    %esi
  801b5b:	5d                   	pop    %ebp
  801b5c:	c3                   	ret    

00801b5d <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b5d:	55                   	push   %ebp
  801b5e:	89 e5                	mov    %esp,%ebp
  801b60:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b63:	8b 45 08             	mov    0x8(%ebp),%eax
  801b66:	e8 50 ff ff ff       	call   801abb <fd2sockid>
		return r;
  801b6b:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b6d:	85 c0                	test   %eax,%eax
  801b6f:	78 1f                	js     801b90 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b71:	83 ec 04             	sub    $0x4,%esp
  801b74:	ff 75 10             	pushl  0x10(%ebp)
  801b77:	ff 75 0c             	pushl  0xc(%ebp)
  801b7a:	50                   	push   %eax
  801b7b:	e8 12 01 00 00       	call   801c92 <nsipc_accept>
  801b80:	83 c4 10             	add    $0x10,%esp
		return r;
  801b83:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b85:	85 c0                	test   %eax,%eax
  801b87:	78 07                	js     801b90 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b89:	e8 5d ff ff ff       	call   801aeb <alloc_sockfd>
  801b8e:	89 c1                	mov    %eax,%ecx
}
  801b90:	89 c8                	mov    %ecx,%eax
  801b92:	c9                   	leave  
  801b93:	c3                   	ret    

00801b94 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9d:	e8 19 ff ff ff       	call   801abb <fd2sockid>
  801ba2:	85 c0                	test   %eax,%eax
  801ba4:	78 12                	js     801bb8 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801ba6:	83 ec 04             	sub    $0x4,%esp
  801ba9:	ff 75 10             	pushl  0x10(%ebp)
  801bac:	ff 75 0c             	pushl  0xc(%ebp)
  801baf:	50                   	push   %eax
  801bb0:	e8 2d 01 00 00       	call   801ce2 <nsipc_bind>
  801bb5:	83 c4 10             	add    $0x10,%esp
}
  801bb8:	c9                   	leave  
  801bb9:	c3                   	ret    

00801bba <shutdown>:

int
shutdown(int s, int how)
{
  801bba:	55                   	push   %ebp
  801bbb:	89 e5                	mov    %esp,%ebp
  801bbd:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bc0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc3:	e8 f3 fe ff ff       	call   801abb <fd2sockid>
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	78 0f                	js     801bdb <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801bcc:	83 ec 08             	sub    $0x8,%esp
  801bcf:	ff 75 0c             	pushl  0xc(%ebp)
  801bd2:	50                   	push   %eax
  801bd3:	e8 3f 01 00 00       	call   801d17 <nsipc_shutdown>
  801bd8:	83 c4 10             	add    $0x10,%esp
}
  801bdb:	c9                   	leave  
  801bdc:	c3                   	ret    

00801bdd <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801be3:	8b 45 08             	mov    0x8(%ebp),%eax
  801be6:	e8 d0 fe ff ff       	call   801abb <fd2sockid>
  801beb:	85 c0                	test   %eax,%eax
  801bed:	78 12                	js     801c01 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801bef:	83 ec 04             	sub    $0x4,%esp
  801bf2:	ff 75 10             	pushl  0x10(%ebp)
  801bf5:	ff 75 0c             	pushl  0xc(%ebp)
  801bf8:	50                   	push   %eax
  801bf9:	e8 55 01 00 00       	call   801d53 <nsipc_connect>
  801bfe:	83 c4 10             	add    $0x10,%esp
}
  801c01:	c9                   	leave  
  801c02:	c3                   	ret    

00801c03 <listen>:

int
listen(int s, int backlog)
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c09:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0c:	e8 aa fe ff ff       	call   801abb <fd2sockid>
  801c11:	85 c0                	test   %eax,%eax
  801c13:	78 0f                	js     801c24 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c15:	83 ec 08             	sub    $0x8,%esp
  801c18:	ff 75 0c             	pushl  0xc(%ebp)
  801c1b:	50                   	push   %eax
  801c1c:	e8 67 01 00 00       	call   801d88 <nsipc_listen>
  801c21:	83 c4 10             	add    $0x10,%esp
}
  801c24:	c9                   	leave  
  801c25:	c3                   	ret    

00801c26 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c26:	55                   	push   %ebp
  801c27:	89 e5                	mov    %esp,%ebp
  801c29:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c2c:	ff 75 10             	pushl  0x10(%ebp)
  801c2f:	ff 75 0c             	pushl  0xc(%ebp)
  801c32:	ff 75 08             	pushl  0x8(%ebp)
  801c35:	e8 3a 02 00 00       	call   801e74 <nsipc_socket>
  801c3a:	83 c4 10             	add    $0x10,%esp
  801c3d:	85 c0                	test   %eax,%eax
  801c3f:	78 05                	js     801c46 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c41:	e8 a5 fe ff ff       	call   801aeb <alloc_sockfd>
}
  801c46:	c9                   	leave  
  801c47:	c3                   	ret    

00801c48 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	53                   	push   %ebx
  801c4c:	83 ec 04             	sub    $0x4,%esp
  801c4f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c51:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c58:	75 12                	jne    801c6c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c5a:	83 ec 0c             	sub    $0xc,%esp
  801c5d:	6a 02                	push   $0x2
  801c5f:	e8 9b 08 00 00       	call   8024ff <ipc_find_env>
  801c64:	a3 04 40 80 00       	mov    %eax,0x804004
  801c69:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c6c:	6a 07                	push   $0x7
  801c6e:	68 00 60 80 00       	push   $0x806000
  801c73:	53                   	push   %ebx
  801c74:	ff 35 04 40 80 00    	pushl  0x804004
  801c7a:	e8 2c 08 00 00       	call   8024ab <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c7f:	83 c4 0c             	add    $0xc,%esp
  801c82:	6a 00                	push   $0x0
  801c84:	6a 00                	push   $0x0
  801c86:	6a 00                	push   $0x0
  801c88:	e8 b5 07 00 00       	call   802442 <ipc_recv>
}
  801c8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c90:	c9                   	leave  
  801c91:	c3                   	ret    

00801c92 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c92:	55                   	push   %ebp
  801c93:	89 e5                	mov    %esp,%ebp
  801c95:	56                   	push   %esi
  801c96:	53                   	push   %ebx
  801c97:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ca2:	8b 06                	mov    (%esi),%eax
  801ca4:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ca9:	b8 01 00 00 00       	mov    $0x1,%eax
  801cae:	e8 95 ff ff ff       	call   801c48 <nsipc>
  801cb3:	89 c3                	mov    %eax,%ebx
  801cb5:	85 c0                	test   %eax,%eax
  801cb7:	78 20                	js     801cd9 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cb9:	83 ec 04             	sub    $0x4,%esp
  801cbc:	ff 35 10 60 80 00    	pushl  0x806010
  801cc2:	68 00 60 80 00       	push   $0x806000
  801cc7:	ff 75 0c             	pushl  0xc(%ebp)
  801cca:	e8 39 ed ff ff       	call   800a08 <memmove>
		*addrlen = ret->ret_addrlen;
  801ccf:	a1 10 60 80 00       	mov    0x806010,%eax
  801cd4:	89 06                	mov    %eax,(%esi)
  801cd6:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801cd9:	89 d8                	mov    %ebx,%eax
  801cdb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cde:	5b                   	pop    %ebx
  801cdf:	5e                   	pop    %esi
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    

00801ce2 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	53                   	push   %ebx
  801ce6:	83 ec 08             	sub    $0x8,%esp
  801ce9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801cec:	8b 45 08             	mov    0x8(%ebp),%eax
  801cef:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801cf4:	53                   	push   %ebx
  801cf5:	ff 75 0c             	pushl  0xc(%ebp)
  801cf8:	68 04 60 80 00       	push   $0x806004
  801cfd:	e8 06 ed ff ff       	call   800a08 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d02:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d08:	b8 02 00 00 00       	mov    $0x2,%eax
  801d0d:	e8 36 ff ff ff       	call   801c48 <nsipc>
}
  801d12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d15:	c9                   	leave  
  801d16:	c3                   	ret    

00801d17 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d17:	55                   	push   %ebp
  801d18:	89 e5                	mov    %esp,%ebp
  801d1a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d20:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d28:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d2d:	b8 03 00 00 00       	mov    $0x3,%eax
  801d32:	e8 11 ff ff ff       	call   801c48 <nsipc>
}
  801d37:	c9                   	leave  
  801d38:	c3                   	ret    

00801d39 <nsipc_close>:

int
nsipc_close(int s)
{
  801d39:	55                   	push   %ebp
  801d3a:	89 e5                	mov    %esp,%ebp
  801d3c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d42:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d47:	b8 04 00 00 00       	mov    $0x4,%eax
  801d4c:	e8 f7 fe ff ff       	call   801c48 <nsipc>
}
  801d51:	c9                   	leave  
  801d52:	c3                   	ret    

00801d53 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d53:	55                   	push   %ebp
  801d54:	89 e5                	mov    %esp,%ebp
  801d56:	53                   	push   %ebx
  801d57:	83 ec 08             	sub    $0x8,%esp
  801d5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d60:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d65:	53                   	push   %ebx
  801d66:	ff 75 0c             	pushl  0xc(%ebp)
  801d69:	68 04 60 80 00       	push   $0x806004
  801d6e:	e8 95 ec ff ff       	call   800a08 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d73:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d79:	b8 05 00 00 00       	mov    $0x5,%eax
  801d7e:	e8 c5 fe ff ff       	call   801c48 <nsipc>
}
  801d83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d86:	c9                   	leave  
  801d87:	c3                   	ret    

00801d88 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d91:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d96:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d99:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d9e:	b8 06 00 00 00       	mov    $0x6,%eax
  801da3:	e8 a0 fe ff ff       	call   801c48 <nsipc>
}
  801da8:	c9                   	leave  
  801da9:	c3                   	ret    

00801daa <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801daa:	55                   	push   %ebp
  801dab:	89 e5                	mov    %esp,%ebp
  801dad:	56                   	push   %esi
  801dae:	53                   	push   %ebx
  801daf:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801db2:	8b 45 08             	mov    0x8(%ebp),%eax
  801db5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801dba:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801dc0:	8b 45 14             	mov    0x14(%ebp),%eax
  801dc3:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801dc8:	b8 07 00 00 00       	mov    $0x7,%eax
  801dcd:	e8 76 fe ff ff       	call   801c48 <nsipc>
  801dd2:	89 c3                	mov    %eax,%ebx
  801dd4:	85 c0                	test   %eax,%eax
  801dd6:	78 35                	js     801e0d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801dd8:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801ddd:	7f 04                	jg     801de3 <nsipc_recv+0x39>
  801ddf:	39 c6                	cmp    %eax,%esi
  801de1:	7d 16                	jge    801df9 <nsipc_recv+0x4f>
  801de3:	68 3b 2e 80 00       	push   $0x802e3b
  801de8:	68 fc 2d 80 00       	push   $0x802dfc
  801ded:	6a 62                	push   $0x62
  801def:	68 50 2e 80 00       	push   $0x802e50
  801df4:	e8 1f e4 ff ff       	call   800218 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801df9:	83 ec 04             	sub    $0x4,%esp
  801dfc:	50                   	push   %eax
  801dfd:	68 00 60 80 00       	push   $0x806000
  801e02:	ff 75 0c             	pushl  0xc(%ebp)
  801e05:	e8 fe eb ff ff       	call   800a08 <memmove>
  801e0a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e0d:	89 d8                	mov    %ebx,%eax
  801e0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e12:	5b                   	pop    %ebx
  801e13:	5e                   	pop    %esi
  801e14:	5d                   	pop    %ebp
  801e15:	c3                   	ret    

00801e16 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e16:	55                   	push   %ebp
  801e17:	89 e5                	mov    %esp,%ebp
  801e19:	53                   	push   %ebx
  801e1a:	83 ec 04             	sub    $0x4,%esp
  801e1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e20:	8b 45 08             	mov    0x8(%ebp),%eax
  801e23:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e28:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e2e:	7e 16                	jle    801e46 <nsipc_send+0x30>
  801e30:	68 5c 2e 80 00       	push   $0x802e5c
  801e35:	68 fc 2d 80 00       	push   $0x802dfc
  801e3a:	6a 6d                	push   $0x6d
  801e3c:	68 50 2e 80 00       	push   $0x802e50
  801e41:	e8 d2 e3 ff ff       	call   800218 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e46:	83 ec 04             	sub    $0x4,%esp
  801e49:	53                   	push   %ebx
  801e4a:	ff 75 0c             	pushl  0xc(%ebp)
  801e4d:	68 0c 60 80 00       	push   $0x80600c
  801e52:	e8 b1 eb ff ff       	call   800a08 <memmove>
	nsipcbuf.send.req_size = size;
  801e57:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e5d:	8b 45 14             	mov    0x14(%ebp),%eax
  801e60:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e65:	b8 08 00 00 00       	mov    $0x8,%eax
  801e6a:	e8 d9 fd ff ff       	call   801c48 <nsipc>
}
  801e6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e72:	c9                   	leave  
  801e73:	c3                   	ret    

00801e74 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e74:	55                   	push   %ebp
  801e75:	89 e5                	mov    %esp,%ebp
  801e77:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e82:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e85:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e8a:	8b 45 10             	mov    0x10(%ebp),%eax
  801e8d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e92:	b8 09 00 00 00       	mov    $0x9,%eax
  801e97:	e8 ac fd ff ff       	call   801c48 <nsipc>
}
  801e9c:	c9                   	leave  
  801e9d:	c3                   	ret    

00801e9e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e9e:	55                   	push   %ebp
  801e9f:	89 e5                	mov    %esp,%ebp
  801ea1:	56                   	push   %esi
  801ea2:	53                   	push   %ebx
  801ea3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ea6:	83 ec 0c             	sub    $0xc,%esp
  801ea9:	ff 75 08             	pushl  0x8(%ebp)
  801eac:	e8 62 f3 ff ff       	call   801213 <fd2data>
  801eb1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801eb3:	83 c4 08             	add    $0x8,%esp
  801eb6:	68 68 2e 80 00       	push   $0x802e68
  801ebb:	53                   	push   %ebx
  801ebc:	e8 b5 e9 ff ff       	call   800876 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ec1:	8b 46 04             	mov    0x4(%esi),%eax
  801ec4:	2b 06                	sub    (%esi),%eax
  801ec6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ecc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ed3:	00 00 00 
	stat->st_dev = &devpipe;
  801ed6:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801edd:	30 80 00 
	return 0;
}
  801ee0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ee8:	5b                   	pop    %ebx
  801ee9:	5e                   	pop    %esi
  801eea:	5d                   	pop    %ebp
  801eeb:	c3                   	ret    

00801eec <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801eec:	55                   	push   %ebp
  801eed:	89 e5                	mov    %esp,%ebp
  801eef:	53                   	push   %ebx
  801ef0:	83 ec 0c             	sub    $0xc,%esp
  801ef3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ef6:	53                   	push   %ebx
  801ef7:	6a 00                	push   $0x0
  801ef9:	e8 00 ee ff ff       	call   800cfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801efe:	89 1c 24             	mov    %ebx,(%esp)
  801f01:	e8 0d f3 ff ff       	call   801213 <fd2data>
  801f06:	83 c4 08             	add    $0x8,%esp
  801f09:	50                   	push   %eax
  801f0a:	6a 00                	push   $0x0
  801f0c:	e8 ed ed ff ff       	call   800cfe <sys_page_unmap>
}
  801f11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f14:	c9                   	leave  
  801f15:	c3                   	ret    

00801f16 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f16:	55                   	push   %ebp
  801f17:	89 e5                	mov    %esp,%ebp
  801f19:	57                   	push   %edi
  801f1a:	56                   	push   %esi
  801f1b:	53                   	push   %ebx
  801f1c:	83 ec 1c             	sub    $0x1c,%esp
  801f1f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f22:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f24:	a1 20 44 80 00       	mov    0x804420,%eax
  801f29:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f2c:	83 ec 0c             	sub    $0xc,%esp
  801f2f:	ff 75 e0             	pushl  -0x20(%ebp)
  801f32:	e8 01 06 00 00       	call   802538 <pageref>
  801f37:	89 c3                	mov    %eax,%ebx
  801f39:	89 3c 24             	mov    %edi,(%esp)
  801f3c:	e8 f7 05 00 00       	call   802538 <pageref>
  801f41:	83 c4 10             	add    $0x10,%esp
  801f44:	39 c3                	cmp    %eax,%ebx
  801f46:	0f 94 c1             	sete   %cl
  801f49:	0f b6 c9             	movzbl %cl,%ecx
  801f4c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f4f:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801f55:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f58:	39 ce                	cmp    %ecx,%esi
  801f5a:	74 1b                	je     801f77 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f5c:	39 c3                	cmp    %eax,%ebx
  801f5e:	75 c4                	jne    801f24 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f60:	8b 42 58             	mov    0x58(%edx),%eax
  801f63:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f66:	50                   	push   %eax
  801f67:	56                   	push   %esi
  801f68:	68 6f 2e 80 00       	push   $0x802e6f
  801f6d:	e8 7f e3 ff ff       	call   8002f1 <cprintf>
  801f72:	83 c4 10             	add    $0x10,%esp
  801f75:	eb ad                	jmp    801f24 <_pipeisclosed+0xe>
	}
}
  801f77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f7d:	5b                   	pop    %ebx
  801f7e:	5e                   	pop    %esi
  801f7f:	5f                   	pop    %edi
  801f80:	5d                   	pop    %ebp
  801f81:	c3                   	ret    

00801f82 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f82:	55                   	push   %ebp
  801f83:	89 e5                	mov    %esp,%ebp
  801f85:	57                   	push   %edi
  801f86:	56                   	push   %esi
  801f87:	53                   	push   %ebx
  801f88:	83 ec 28             	sub    $0x28,%esp
  801f8b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f8e:	56                   	push   %esi
  801f8f:	e8 7f f2 ff ff       	call   801213 <fd2data>
  801f94:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f96:	83 c4 10             	add    $0x10,%esp
  801f99:	bf 00 00 00 00       	mov    $0x0,%edi
  801f9e:	eb 4b                	jmp    801feb <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801fa0:	89 da                	mov    %ebx,%edx
  801fa2:	89 f0                	mov    %esi,%eax
  801fa4:	e8 6d ff ff ff       	call   801f16 <_pipeisclosed>
  801fa9:	85 c0                	test   %eax,%eax
  801fab:	75 48                	jne    801ff5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fad:	e8 a8 ec ff ff       	call   800c5a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fb2:	8b 43 04             	mov    0x4(%ebx),%eax
  801fb5:	8b 0b                	mov    (%ebx),%ecx
  801fb7:	8d 51 20             	lea    0x20(%ecx),%edx
  801fba:	39 d0                	cmp    %edx,%eax
  801fbc:	73 e2                	jae    801fa0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fc1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fc5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fc8:	89 c2                	mov    %eax,%edx
  801fca:	c1 fa 1f             	sar    $0x1f,%edx
  801fcd:	89 d1                	mov    %edx,%ecx
  801fcf:	c1 e9 1b             	shr    $0x1b,%ecx
  801fd2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fd5:	83 e2 1f             	and    $0x1f,%edx
  801fd8:	29 ca                	sub    %ecx,%edx
  801fda:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fde:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fe2:	83 c0 01             	add    $0x1,%eax
  801fe5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fe8:	83 c7 01             	add    $0x1,%edi
  801feb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fee:	75 c2                	jne    801fb2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ff0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ff3:	eb 05                	jmp    801ffa <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ff5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ffa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ffd:	5b                   	pop    %ebx
  801ffe:	5e                   	pop    %esi
  801fff:	5f                   	pop    %edi
  802000:	5d                   	pop    %ebp
  802001:	c3                   	ret    

00802002 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802002:	55                   	push   %ebp
  802003:	89 e5                	mov    %esp,%ebp
  802005:	57                   	push   %edi
  802006:	56                   	push   %esi
  802007:	53                   	push   %ebx
  802008:	83 ec 18             	sub    $0x18,%esp
  80200b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80200e:	57                   	push   %edi
  80200f:	e8 ff f1 ff ff       	call   801213 <fd2data>
  802014:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802016:	83 c4 10             	add    $0x10,%esp
  802019:	bb 00 00 00 00       	mov    $0x0,%ebx
  80201e:	eb 3d                	jmp    80205d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802020:	85 db                	test   %ebx,%ebx
  802022:	74 04                	je     802028 <devpipe_read+0x26>
				return i;
  802024:	89 d8                	mov    %ebx,%eax
  802026:	eb 44                	jmp    80206c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802028:	89 f2                	mov    %esi,%edx
  80202a:	89 f8                	mov    %edi,%eax
  80202c:	e8 e5 fe ff ff       	call   801f16 <_pipeisclosed>
  802031:	85 c0                	test   %eax,%eax
  802033:	75 32                	jne    802067 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802035:	e8 20 ec ff ff       	call   800c5a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80203a:	8b 06                	mov    (%esi),%eax
  80203c:	3b 46 04             	cmp    0x4(%esi),%eax
  80203f:	74 df                	je     802020 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802041:	99                   	cltd   
  802042:	c1 ea 1b             	shr    $0x1b,%edx
  802045:	01 d0                	add    %edx,%eax
  802047:	83 e0 1f             	and    $0x1f,%eax
  80204a:	29 d0                	sub    %edx,%eax
  80204c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802051:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802054:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802057:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80205a:	83 c3 01             	add    $0x1,%ebx
  80205d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802060:	75 d8                	jne    80203a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802062:	8b 45 10             	mov    0x10(%ebp),%eax
  802065:	eb 05                	jmp    80206c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802067:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80206c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80206f:	5b                   	pop    %ebx
  802070:	5e                   	pop    %esi
  802071:	5f                   	pop    %edi
  802072:	5d                   	pop    %ebp
  802073:	c3                   	ret    

00802074 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	56                   	push   %esi
  802078:	53                   	push   %ebx
  802079:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80207c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80207f:	50                   	push   %eax
  802080:	e8 a5 f1 ff ff       	call   80122a <fd_alloc>
  802085:	83 c4 10             	add    $0x10,%esp
  802088:	89 c2                	mov    %eax,%edx
  80208a:	85 c0                	test   %eax,%eax
  80208c:	0f 88 2c 01 00 00    	js     8021be <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802092:	83 ec 04             	sub    $0x4,%esp
  802095:	68 07 04 00 00       	push   $0x407
  80209a:	ff 75 f4             	pushl  -0xc(%ebp)
  80209d:	6a 00                	push   $0x0
  80209f:	e8 d5 eb ff ff       	call   800c79 <sys_page_alloc>
  8020a4:	83 c4 10             	add    $0x10,%esp
  8020a7:	89 c2                	mov    %eax,%edx
  8020a9:	85 c0                	test   %eax,%eax
  8020ab:	0f 88 0d 01 00 00    	js     8021be <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020b1:	83 ec 0c             	sub    $0xc,%esp
  8020b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020b7:	50                   	push   %eax
  8020b8:	e8 6d f1 ff ff       	call   80122a <fd_alloc>
  8020bd:	89 c3                	mov    %eax,%ebx
  8020bf:	83 c4 10             	add    $0x10,%esp
  8020c2:	85 c0                	test   %eax,%eax
  8020c4:	0f 88 e2 00 00 00    	js     8021ac <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ca:	83 ec 04             	sub    $0x4,%esp
  8020cd:	68 07 04 00 00       	push   $0x407
  8020d2:	ff 75 f0             	pushl  -0x10(%ebp)
  8020d5:	6a 00                	push   $0x0
  8020d7:	e8 9d eb ff ff       	call   800c79 <sys_page_alloc>
  8020dc:	89 c3                	mov    %eax,%ebx
  8020de:	83 c4 10             	add    $0x10,%esp
  8020e1:	85 c0                	test   %eax,%eax
  8020e3:	0f 88 c3 00 00 00    	js     8021ac <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020e9:	83 ec 0c             	sub    $0xc,%esp
  8020ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ef:	e8 1f f1 ff ff       	call   801213 <fd2data>
  8020f4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020f6:	83 c4 0c             	add    $0xc,%esp
  8020f9:	68 07 04 00 00       	push   $0x407
  8020fe:	50                   	push   %eax
  8020ff:	6a 00                	push   $0x0
  802101:	e8 73 eb ff ff       	call   800c79 <sys_page_alloc>
  802106:	89 c3                	mov    %eax,%ebx
  802108:	83 c4 10             	add    $0x10,%esp
  80210b:	85 c0                	test   %eax,%eax
  80210d:	0f 88 89 00 00 00    	js     80219c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802113:	83 ec 0c             	sub    $0xc,%esp
  802116:	ff 75 f0             	pushl  -0x10(%ebp)
  802119:	e8 f5 f0 ff ff       	call   801213 <fd2data>
  80211e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802125:	50                   	push   %eax
  802126:	6a 00                	push   $0x0
  802128:	56                   	push   %esi
  802129:	6a 00                	push   $0x0
  80212b:	e8 8c eb ff ff       	call   800cbc <sys_page_map>
  802130:	89 c3                	mov    %eax,%ebx
  802132:	83 c4 20             	add    $0x20,%esp
  802135:	85 c0                	test   %eax,%eax
  802137:	78 55                	js     80218e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802139:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80213f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802142:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802144:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802147:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80214e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802154:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802157:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802159:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80215c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802163:	83 ec 0c             	sub    $0xc,%esp
  802166:	ff 75 f4             	pushl  -0xc(%ebp)
  802169:	e8 95 f0 ff ff       	call   801203 <fd2num>
  80216e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802171:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802173:	83 c4 04             	add    $0x4,%esp
  802176:	ff 75 f0             	pushl  -0x10(%ebp)
  802179:	e8 85 f0 ff ff       	call   801203 <fd2num>
  80217e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802181:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802184:	83 c4 10             	add    $0x10,%esp
  802187:	ba 00 00 00 00       	mov    $0x0,%edx
  80218c:	eb 30                	jmp    8021be <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80218e:	83 ec 08             	sub    $0x8,%esp
  802191:	56                   	push   %esi
  802192:	6a 00                	push   $0x0
  802194:	e8 65 eb ff ff       	call   800cfe <sys_page_unmap>
  802199:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80219c:	83 ec 08             	sub    $0x8,%esp
  80219f:	ff 75 f0             	pushl  -0x10(%ebp)
  8021a2:	6a 00                	push   $0x0
  8021a4:	e8 55 eb ff ff       	call   800cfe <sys_page_unmap>
  8021a9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021ac:	83 ec 08             	sub    $0x8,%esp
  8021af:	ff 75 f4             	pushl  -0xc(%ebp)
  8021b2:	6a 00                	push   $0x0
  8021b4:	e8 45 eb ff ff       	call   800cfe <sys_page_unmap>
  8021b9:	83 c4 10             	add    $0x10,%esp
  8021bc:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8021be:	89 d0                	mov    %edx,%eax
  8021c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021c3:	5b                   	pop    %ebx
  8021c4:	5e                   	pop    %esi
  8021c5:	5d                   	pop    %ebp
  8021c6:	c3                   	ret    

008021c7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021c7:	55                   	push   %ebp
  8021c8:	89 e5                	mov    %esp,%ebp
  8021ca:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021d0:	50                   	push   %eax
  8021d1:	ff 75 08             	pushl  0x8(%ebp)
  8021d4:	e8 a0 f0 ff ff       	call   801279 <fd_lookup>
  8021d9:	83 c4 10             	add    $0x10,%esp
  8021dc:	85 c0                	test   %eax,%eax
  8021de:	78 18                	js     8021f8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021e0:	83 ec 0c             	sub    $0xc,%esp
  8021e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8021e6:	e8 28 f0 ff ff       	call   801213 <fd2data>
	return _pipeisclosed(fd, p);
  8021eb:	89 c2                	mov    %eax,%edx
  8021ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021f0:	e8 21 fd ff ff       	call   801f16 <_pipeisclosed>
  8021f5:	83 c4 10             	add    $0x10,%esp
}
  8021f8:	c9                   	leave  
  8021f9:	c3                   	ret    

008021fa <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8021fa:	55                   	push   %ebp
  8021fb:	89 e5                	mov    %esp,%ebp
  8021fd:	56                   	push   %esi
  8021fe:	53                   	push   %ebx
  8021ff:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802202:	85 f6                	test   %esi,%esi
  802204:	75 16                	jne    80221c <wait+0x22>
  802206:	68 87 2e 80 00       	push   $0x802e87
  80220b:	68 fc 2d 80 00       	push   $0x802dfc
  802210:	6a 09                	push   $0x9
  802212:	68 92 2e 80 00       	push   $0x802e92
  802217:	e8 fc df ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  80221c:	89 f3                	mov    %esi,%ebx
  80221e:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802224:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802227:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80222d:	eb 05                	jmp    802234 <wait+0x3a>
		sys_yield();
  80222f:	e8 26 ea ff ff       	call   800c5a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802234:	8b 43 48             	mov    0x48(%ebx),%eax
  802237:	39 c6                	cmp    %eax,%esi
  802239:	75 07                	jne    802242 <wait+0x48>
  80223b:	8b 43 54             	mov    0x54(%ebx),%eax
  80223e:	85 c0                	test   %eax,%eax
  802240:	75 ed                	jne    80222f <wait+0x35>
		sys_yield();
}
  802242:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802245:	5b                   	pop    %ebx
  802246:	5e                   	pop    %esi
  802247:	5d                   	pop    %ebp
  802248:	c3                   	ret    

00802249 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802249:	55                   	push   %ebp
  80224a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80224c:	b8 00 00 00 00       	mov    $0x0,%eax
  802251:	5d                   	pop    %ebp
  802252:	c3                   	ret    

00802253 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802253:	55                   	push   %ebp
  802254:	89 e5                	mov    %esp,%ebp
  802256:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802259:	68 9d 2e 80 00       	push   $0x802e9d
  80225e:	ff 75 0c             	pushl  0xc(%ebp)
  802261:	e8 10 e6 ff ff       	call   800876 <strcpy>
	return 0;
}
  802266:	b8 00 00 00 00       	mov    $0x0,%eax
  80226b:	c9                   	leave  
  80226c:	c3                   	ret    

0080226d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80226d:	55                   	push   %ebp
  80226e:	89 e5                	mov    %esp,%ebp
  802270:	57                   	push   %edi
  802271:	56                   	push   %esi
  802272:	53                   	push   %ebx
  802273:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802279:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80227e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802284:	eb 2d                	jmp    8022b3 <devcons_write+0x46>
		m = n - tot;
  802286:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802289:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80228b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80228e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802293:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802296:	83 ec 04             	sub    $0x4,%esp
  802299:	53                   	push   %ebx
  80229a:	03 45 0c             	add    0xc(%ebp),%eax
  80229d:	50                   	push   %eax
  80229e:	57                   	push   %edi
  80229f:	e8 64 e7 ff ff       	call   800a08 <memmove>
		sys_cputs(buf, m);
  8022a4:	83 c4 08             	add    $0x8,%esp
  8022a7:	53                   	push   %ebx
  8022a8:	57                   	push   %edi
  8022a9:	e8 0f e9 ff ff       	call   800bbd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022ae:	01 de                	add    %ebx,%esi
  8022b0:	83 c4 10             	add    $0x10,%esp
  8022b3:	89 f0                	mov    %esi,%eax
  8022b5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022b8:	72 cc                	jb     802286 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022bd:	5b                   	pop    %ebx
  8022be:	5e                   	pop    %esi
  8022bf:	5f                   	pop    %edi
  8022c0:	5d                   	pop    %ebp
  8022c1:	c3                   	ret    

008022c2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022c2:	55                   	push   %ebp
  8022c3:	89 e5                	mov    %esp,%ebp
  8022c5:	83 ec 08             	sub    $0x8,%esp
  8022c8:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8022cd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022d1:	74 2a                	je     8022fd <devcons_read+0x3b>
  8022d3:	eb 05                	jmp    8022da <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022d5:	e8 80 e9 ff ff       	call   800c5a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8022da:	e8 fc e8 ff ff       	call   800bdb <sys_cgetc>
  8022df:	85 c0                	test   %eax,%eax
  8022e1:	74 f2                	je     8022d5 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8022e3:	85 c0                	test   %eax,%eax
  8022e5:	78 16                	js     8022fd <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8022e7:	83 f8 04             	cmp    $0x4,%eax
  8022ea:	74 0c                	je     8022f8 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8022ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022ef:	88 02                	mov    %al,(%edx)
	return 1;
  8022f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8022f6:	eb 05                	jmp    8022fd <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022f8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022fd:	c9                   	leave  
  8022fe:	c3                   	ret    

008022ff <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022ff:	55                   	push   %ebp
  802300:	89 e5                	mov    %esp,%ebp
  802302:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802305:	8b 45 08             	mov    0x8(%ebp),%eax
  802308:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80230b:	6a 01                	push   $0x1
  80230d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802310:	50                   	push   %eax
  802311:	e8 a7 e8 ff ff       	call   800bbd <sys_cputs>
}
  802316:	83 c4 10             	add    $0x10,%esp
  802319:	c9                   	leave  
  80231a:	c3                   	ret    

0080231b <getchar>:

int
getchar(void)
{
  80231b:	55                   	push   %ebp
  80231c:	89 e5                	mov    %esp,%ebp
  80231e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802321:	6a 01                	push   $0x1
  802323:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802326:	50                   	push   %eax
  802327:	6a 00                	push   $0x0
  802329:	e8 b1 f1 ff ff       	call   8014df <read>
	if (r < 0)
  80232e:	83 c4 10             	add    $0x10,%esp
  802331:	85 c0                	test   %eax,%eax
  802333:	78 0f                	js     802344 <getchar+0x29>
		return r;
	if (r < 1)
  802335:	85 c0                	test   %eax,%eax
  802337:	7e 06                	jle    80233f <getchar+0x24>
		return -E_EOF;
	return c;
  802339:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80233d:	eb 05                	jmp    802344 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80233f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802344:	c9                   	leave  
  802345:	c3                   	ret    

00802346 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802346:	55                   	push   %ebp
  802347:	89 e5                	mov    %esp,%ebp
  802349:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80234c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80234f:	50                   	push   %eax
  802350:	ff 75 08             	pushl  0x8(%ebp)
  802353:	e8 21 ef ff ff       	call   801279 <fd_lookup>
  802358:	83 c4 10             	add    $0x10,%esp
  80235b:	85 c0                	test   %eax,%eax
  80235d:	78 11                	js     802370 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80235f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802362:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802368:	39 10                	cmp    %edx,(%eax)
  80236a:	0f 94 c0             	sete   %al
  80236d:	0f b6 c0             	movzbl %al,%eax
}
  802370:	c9                   	leave  
  802371:	c3                   	ret    

00802372 <opencons>:

int
opencons(void)
{
  802372:	55                   	push   %ebp
  802373:	89 e5                	mov    %esp,%ebp
  802375:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802378:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80237b:	50                   	push   %eax
  80237c:	e8 a9 ee ff ff       	call   80122a <fd_alloc>
  802381:	83 c4 10             	add    $0x10,%esp
		return r;
  802384:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802386:	85 c0                	test   %eax,%eax
  802388:	78 3e                	js     8023c8 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80238a:	83 ec 04             	sub    $0x4,%esp
  80238d:	68 07 04 00 00       	push   $0x407
  802392:	ff 75 f4             	pushl  -0xc(%ebp)
  802395:	6a 00                	push   $0x0
  802397:	e8 dd e8 ff ff       	call   800c79 <sys_page_alloc>
  80239c:	83 c4 10             	add    $0x10,%esp
		return r;
  80239f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023a1:	85 c0                	test   %eax,%eax
  8023a3:	78 23                	js     8023c8 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023a5:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ae:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023b3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023ba:	83 ec 0c             	sub    $0xc,%esp
  8023bd:	50                   	push   %eax
  8023be:	e8 40 ee ff ff       	call   801203 <fd2num>
  8023c3:	89 c2                	mov    %eax,%edx
  8023c5:	83 c4 10             	add    $0x10,%esp
}
  8023c8:	89 d0                	mov    %edx,%eax
  8023ca:	c9                   	leave  
  8023cb:	c3                   	ret    

008023cc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023cc:	55                   	push   %ebp
  8023cd:	89 e5                	mov    %esp,%ebp
  8023cf:	53                   	push   %ebx
  8023d0:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023d3:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8023da:	75 28                	jne    802404 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  8023dc:	e8 5a e8 ff ff       	call   800c3b <sys_getenvid>
  8023e1:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  8023e3:	83 ec 04             	sub    $0x4,%esp
  8023e6:	6a 06                	push   $0x6
  8023e8:	68 00 f0 bf ee       	push   $0xeebff000
  8023ed:	50                   	push   %eax
  8023ee:	e8 86 e8 ff ff       	call   800c79 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  8023f3:	83 c4 08             	add    $0x8,%esp
  8023f6:	68 11 24 80 00       	push   $0x802411
  8023fb:	53                   	push   %ebx
  8023fc:	e8 c3 e9 ff ff       	call   800dc4 <sys_env_set_pgfault_upcall>
  802401:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802404:	8b 45 08             	mov    0x8(%ebp),%eax
  802407:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80240c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80240f:	c9                   	leave  
  802410:	c3                   	ret    

00802411 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802411:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802412:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802417:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802419:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  80241c:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  80241e:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  802421:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  802424:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  802427:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  80242a:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  80242d:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  802430:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  802433:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  802436:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  802439:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  80243c:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  80243f:	61                   	popa   
	popfl
  802440:	9d                   	popf   
	ret
  802441:	c3                   	ret    

00802442 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802442:	55                   	push   %ebp
  802443:	89 e5                	mov    %esp,%ebp
  802445:	56                   	push   %esi
  802446:	53                   	push   %ebx
  802447:	8b 75 08             	mov    0x8(%ebp),%esi
  80244a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80244d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  802450:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802452:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802457:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  80245a:	83 ec 0c             	sub    $0xc,%esp
  80245d:	50                   	push   %eax
  80245e:	e8 c6 e9 ff ff       	call   800e29 <sys_ipc_recv>

	if (r < 0) {
  802463:	83 c4 10             	add    $0x10,%esp
  802466:	85 c0                	test   %eax,%eax
  802468:	79 16                	jns    802480 <ipc_recv+0x3e>
		if (from_env_store)
  80246a:	85 f6                	test   %esi,%esi
  80246c:	74 06                	je     802474 <ipc_recv+0x32>
			*from_env_store = 0;
  80246e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  802474:	85 db                	test   %ebx,%ebx
  802476:	74 2c                	je     8024a4 <ipc_recv+0x62>
			*perm_store = 0;
  802478:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80247e:	eb 24                	jmp    8024a4 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  802480:	85 f6                	test   %esi,%esi
  802482:	74 0a                	je     80248e <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  802484:	a1 20 44 80 00       	mov    0x804420,%eax
  802489:	8b 40 74             	mov    0x74(%eax),%eax
  80248c:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  80248e:	85 db                	test   %ebx,%ebx
  802490:	74 0a                	je     80249c <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  802492:	a1 20 44 80 00       	mov    0x804420,%eax
  802497:	8b 40 78             	mov    0x78(%eax),%eax
  80249a:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  80249c:	a1 20 44 80 00       	mov    0x804420,%eax
  8024a1:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8024a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024a7:	5b                   	pop    %ebx
  8024a8:	5e                   	pop    %esi
  8024a9:	5d                   	pop    %ebp
  8024aa:	c3                   	ret    

008024ab <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024ab:	55                   	push   %ebp
  8024ac:	89 e5                	mov    %esp,%ebp
  8024ae:	57                   	push   %edi
  8024af:	56                   	push   %esi
  8024b0:	53                   	push   %ebx
  8024b1:	83 ec 0c             	sub    $0xc,%esp
  8024b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024b7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8024bd:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8024bf:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8024c4:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8024c7:	ff 75 14             	pushl  0x14(%ebp)
  8024ca:	53                   	push   %ebx
  8024cb:	56                   	push   %esi
  8024cc:	57                   	push   %edi
  8024cd:	e8 34 e9 ff ff       	call   800e06 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  8024d2:	83 c4 10             	add    $0x10,%esp
  8024d5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024d8:	75 07                	jne    8024e1 <ipc_send+0x36>
			sys_yield();
  8024da:	e8 7b e7 ff ff       	call   800c5a <sys_yield>
  8024df:	eb e6                	jmp    8024c7 <ipc_send+0x1c>
		} else if (r < 0) {
  8024e1:	85 c0                	test   %eax,%eax
  8024e3:	79 12                	jns    8024f7 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  8024e5:	50                   	push   %eax
  8024e6:	68 a9 2e 80 00       	push   $0x802ea9
  8024eb:	6a 51                	push   $0x51
  8024ed:	68 b6 2e 80 00       	push   $0x802eb6
  8024f2:	e8 21 dd ff ff       	call   800218 <_panic>
		}
	}
}
  8024f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024fa:	5b                   	pop    %ebx
  8024fb:	5e                   	pop    %esi
  8024fc:	5f                   	pop    %edi
  8024fd:	5d                   	pop    %ebp
  8024fe:	c3                   	ret    

008024ff <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8024ff:	55                   	push   %ebp
  802500:	89 e5                	mov    %esp,%ebp
  802502:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802505:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80250a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80250d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802513:	8b 52 50             	mov    0x50(%edx),%edx
  802516:	39 ca                	cmp    %ecx,%edx
  802518:	75 0d                	jne    802527 <ipc_find_env+0x28>
			return envs[i].env_id;
  80251a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80251d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802522:	8b 40 48             	mov    0x48(%eax),%eax
  802525:	eb 0f                	jmp    802536 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802527:	83 c0 01             	add    $0x1,%eax
  80252a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80252f:	75 d9                	jne    80250a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802531:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802536:	5d                   	pop    %ebp
  802537:	c3                   	ret    

00802538 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802538:	55                   	push   %ebp
  802539:	89 e5                	mov    %esp,%ebp
  80253b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80253e:	89 d0                	mov    %edx,%eax
  802540:	c1 e8 16             	shr    $0x16,%eax
  802543:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80254a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80254f:	f6 c1 01             	test   $0x1,%cl
  802552:	74 1d                	je     802571 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802554:	c1 ea 0c             	shr    $0xc,%edx
  802557:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80255e:	f6 c2 01             	test   $0x1,%dl
  802561:	74 0e                	je     802571 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802563:	c1 ea 0c             	shr    $0xc,%edx
  802566:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80256d:	ef 
  80256e:	0f b7 c0             	movzwl %ax,%eax
}
  802571:	5d                   	pop    %ebp
  802572:	c3                   	ret    
  802573:	66 90                	xchg   %ax,%ax
  802575:	66 90                	xchg   %ax,%ax
  802577:	66 90                	xchg   %ax,%ax
  802579:	66 90                	xchg   %ax,%ax
  80257b:	66 90                	xchg   %ax,%ax
  80257d:	66 90                	xchg   %ax,%ax
  80257f:	90                   	nop

00802580 <__udivdi3>:
  802580:	55                   	push   %ebp
  802581:	57                   	push   %edi
  802582:	56                   	push   %esi
  802583:	53                   	push   %ebx
  802584:	83 ec 1c             	sub    $0x1c,%esp
  802587:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80258b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80258f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802593:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802597:	85 f6                	test   %esi,%esi
  802599:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80259d:	89 ca                	mov    %ecx,%edx
  80259f:	89 f8                	mov    %edi,%eax
  8025a1:	75 3d                	jne    8025e0 <__udivdi3+0x60>
  8025a3:	39 cf                	cmp    %ecx,%edi
  8025a5:	0f 87 c5 00 00 00    	ja     802670 <__udivdi3+0xf0>
  8025ab:	85 ff                	test   %edi,%edi
  8025ad:	89 fd                	mov    %edi,%ebp
  8025af:	75 0b                	jne    8025bc <__udivdi3+0x3c>
  8025b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025b6:	31 d2                	xor    %edx,%edx
  8025b8:	f7 f7                	div    %edi
  8025ba:	89 c5                	mov    %eax,%ebp
  8025bc:	89 c8                	mov    %ecx,%eax
  8025be:	31 d2                	xor    %edx,%edx
  8025c0:	f7 f5                	div    %ebp
  8025c2:	89 c1                	mov    %eax,%ecx
  8025c4:	89 d8                	mov    %ebx,%eax
  8025c6:	89 cf                	mov    %ecx,%edi
  8025c8:	f7 f5                	div    %ebp
  8025ca:	89 c3                	mov    %eax,%ebx
  8025cc:	89 d8                	mov    %ebx,%eax
  8025ce:	89 fa                	mov    %edi,%edx
  8025d0:	83 c4 1c             	add    $0x1c,%esp
  8025d3:	5b                   	pop    %ebx
  8025d4:	5e                   	pop    %esi
  8025d5:	5f                   	pop    %edi
  8025d6:	5d                   	pop    %ebp
  8025d7:	c3                   	ret    
  8025d8:	90                   	nop
  8025d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025e0:	39 ce                	cmp    %ecx,%esi
  8025e2:	77 74                	ja     802658 <__udivdi3+0xd8>
  8025e4:	0f bd fe             	bsr    %esi,%edi
  8025e7:	83 f7 1f             	xor    $0x1f,%edi
  8025ea:	0f 84 98 00 00 00    	je     802688 <__udivdi3+0x108>
  8025f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8025f5:	89 f9                	mov    %edi,%ecx
  8025f7:	89 c5                	mov    %eax,%ebp
  8025f9:	29 fb                	sub    %edi,%ebx
  8025fb:	d3 e6                	shl    %cl,%esi
  8025fd:	89 d9                	mov    %ebx,%ecx
  8025ff:	d3 ed                	shr    %cl,%ebp
  802601:	89 f9                	mov    %edi,%ecx
  802603:	d3 e0                	shl    %cl,%eax
  802605:	09 ee                	or     %ebp,%esi
  802607:	89 d9                	mov    %ebx,%ecx
  802609:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80260d:	89 d5                	mov    %edx,%ebp
  80260f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802613:	d3 ed                	shr    %cl,%ebp
  802615:	89 f9                	mov    %edi,%ecx
  802617:	d3 e2                	shl    %cl,%edx
  802619:	89 d9                	mov    %ebx,%ecx
  80261b:	d3 e8                	shr    %cl,%eax
  80261d:	09 c2                	or     %eax,%edx
  80261f:	89 d0                	mov    %edx,%eax
  802621:	89 ea                	mov    %ebp,%edx
  802623:	f7 f6                	div    %esi
  802625:	89 d5                	mov    %edx,%ebp
  802627:	89 c3                	mov    %eax,%ebx
  802629:	f7 64 24 0c          	mull   0xc(%esp)
  80262d:	39 d5                	cmp    %edx,%ebp
  80262f:	72 10                	jb     802641 <__udivdi3+0xc1>
  802631:	8b 74 24 08          	mov    0x8(%esp),%esi
  802635:	89 f9                	mov    %edi,%ecx
  802637:	d3 e6                	shl    %cl,%esi
  802639:	39 c6                	cmp    %eax,%esi
  80263b:	73 07                	jae    802644 <__udivdi3+0xc4>
  80263d:	39 d5                	cmp    %edx,%ebp
  80263f:	75 03                	jne    802644 <__udivdi3+0xc4>
  802641:	83 eb 01             	sub    $0x1,%ebx
  802644:	31 ff                	xor    %edi,%edi
  802646:	89 d8                	mov    %ebx,%eax
  802648:	89 fa                	mov    %edi,%edx
  80264a:	83 c4 1c             	add    $0x1c,%esp
  80264d:	5b                   	pop    %ebx
  80264e:	5e                   	pop    %esi
  80264f:	5f                   	pop    %edi
  802650:	5d                   	pop    %ebp
  802651:	c3                   	ret    
  802652:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802658:	31 ff                	xor    %edi,%edi
  80265a:	31 db                	xor    %ebx,%ebx
  80265c:	89 d8                	mov    %ebx,%eax
  80265e:	89 fa                	mov    %edi,%edx
  802660:	83 c4 1c             	add    $0x1c,%esp
  802663:	5b                   	pop    %ebx
  802664:	5e                   	pop    %esi
  802665:	5f                   	pop    %edi
  802666:	5d                   	pop    %ebp
  802667:	c3                   	ret    
  802668:	90                   	nop
  802669:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802670:	89 d8                	mov    %ebx,%eax
  802672:	f7 f7                	div    %edi
  802674:	31 ff                	xor    %edi,%edi
  802676:	89 c3                	mov    %eax,%ebx
  802678:	89 d8                	mov    %ebx,%eax
  80267a:	89 fa                	mov    %edi,%edx
  80267c:	83 c4 1c             	add    $0x1c,%esp
  80267f:	5b                   	pop    %ebx
  802680:	5e                   	pop    %esi
  802681:	5f                   	pop    %edi
  802682:	5d                   	pop    %ebp
  802683:	c3                   	ret    
  802684:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802688:	39 ce                	cmp    %ecx,%esi
  80268a:	72 0c                	jb     802698 <__udivdi3+0x118>
  80268c:	31 db                	xor    %ebx,%ebx
  80268e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802692:	0f 87 34 ff ff ff    	ja     8025cc <__udivdi3+0x4c>
  802698:	bb 01 00 00 00       	mov    $0x1,%ebx
  80269d:	e9 2a ff ff ff       	jmp    8025cc <__udivdi3+0x4c>
  8026a2:	66 90                	xchg   %ax,%ax
  8026a4:	66 90                	xchg   %ax,%ax
  8026a6:	66 90                	xchg   %ax,%ax
  8026a8:	66 90                	xchg   %ax,%ax
  8026aa:	66 90                	xchg   %ax,%ax
  8026ac:	66 90                	xchg   %ax,%ax
  8026ae:	66 90                	xchg   %ax,%ax

008026b0 <__umoddi3>:
  8026b0:	55                   	push   %ebp
  8026b1:	57                   	push   %edi
  8026b2:	56                   	push   %esi
  8026b3:	53                   	push   %ebx
  8026b4:	83 ec 1c             	sub    $0x1c,%esp
  8026b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8026c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026c7:	85 d2                	test   %edx,%edx
  8026c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026d1:	89 f3                	mov    %esi,%ebx
  8026d3:	89 3c 24             	mov    %edi,(%esp)
  8026d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026da:	75 1c                	jne    8026f8 <__umoddi3+0x48>
  8026dc:	39 f7                	cmp    %esi,%edi
  8026de:	76 50                	jbe    802730 <__umoddi3+0x80>
  8026e0:	89 c8                	mov    %ecx,%eax
  8026e2:	89 f2                	mov    %esi,%edx
  8026e4:	f7 f7                	div    %edi
  8026e6:	89 d0                	mov    %edx,%eax
  8026e8:	31 d2                	xor    %edx,%edx
  8026ea:	83 c4 1c             	add    $0x1c,%esp
  8026ed:	5b                   	pop    %ebx
  8026ee:	5e                   	pop    %esi
  8026ef:	5f                   	pop    %edi
  8026f0:	5d                   	pop    %ebp
  8026f1:	c3                   	ret    
  8026f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026f8:	39 f2                	cmp    %esi,%edx
  8026fa:	89 d0                	mov    %edx,%eax
  8026fc:	77 52                	ja     802750 <__umoddi3+0xa0>
  8026fe:	0f bd ea             	bsr    %edx,%ebp
  802701:	83 f5 1f             	xor    $0x1f,%ebp
  802704:	75 5a                	jne    802760 <__umoddi3+0xb0>
  802706:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80270a:	0f 82 e0 00 00 00    	jb     8027f0 <__umoddi3+0x140>
  802710:	39 0c 24             	cmp    %ecx,(%esp)
  802713:	0f 86 d7 00 00 00    	jbe    8027f0 <__umoddi3+0x140>
  802719:	8b 44 24 08          	mov    0x8(%esp),%eax
  80271d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802721:	83 c4 1c             	add    $0x1c,%esp
  802724:	5b                   	pop    %ebx
  802725:	5e                   	pop    %esi
  802726:	5f                   	pop    %edi
  802727:	5d                   	pop    %ebp
  802728:	c3                   	ret    
  802729:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802730:	85 ff                	test   %edi,%edi
  802732:	89 fd                	mov    %edi,%ebp
  802734:	75 0b                	jne    802741 <__umoddi3+0x91>
  802736:	b8 01 00 00 00       	mov    $0x1,%eax
  80273b:	31 d2                	xor    %edx,%edx
  80273d:	f7 f7                	div    %edi
  80273f:	89 c5                	mov    %eax,%ebp
  802741:	89 f0                	mov    %esi,%eax
  802743:	31 d2                	xor    %edx,%edx
  802745:	f7 f5                	div    %ebp
  802747:	89 c8                	mov    %ecx,%eax
  802749:	f7 f5                	div    %ebp
  80274b:	89 d0                	mov    %edx,%eax
  80274d:	eb 99                	jmp    8026e8 <__umoddi3+0x38>
  80274f:	90                   	nop
  802750:	89 c8                	mov    %ecx,%eax
  802752:	89 f2                	mov    %esi,%edx
  802754:	83 c4 1c             	add    $0x1c,%esp
  802757:	5b                   	pop    %ebx
  802758:	5e                   	pop    %esi
  802759:	5f                   	pop    %edi
  80275a:	5d                   	pop    %ebp
  80275b:	c3                   	ret    
  80275c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802760:	8b 34 24             	mov    (%esp),%esi
  802763:	bf 20 00 00 00       	mov    $0x20,%edi
  802768:	89 e9                	mov    %ebp,%ecx
  80276a:	29 ef                	sub    %ebp,%edi
  80276c:	d3 e0                	shl    %cl,%eax
  80276e:	89 f9                	mov    %edi,%ecx
  802770:	89 f2                	mov    %esi,%edx
  802772:	d3 ea                	shr    %cl,%edx
  802774:	89 e9                	mov    %ebp,%ecx
  802776:	09 c2                	or     %eax,%edx
  802778:	89 d8                	mov    %ebx,%eax
  80277a:	89 14 24             	mov    %edx,(%esp)
  80277d:	89 f2                	mov    %esi,%edx
  80277f:	d3 e2                	shl    %cl,%edx
  802781:	89 f9                	mov    %edi,%ecx
  802783:	89 54 24 04          	mov    %edx,0x4(%esp)
  802787:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80278b:	d3 e8                	shr    %cl,%eax
  80278d:	89 e9                	mov    %ebp,%ecx
  80278f:	89 c6                	mov    %eax,%esi
  802791:	d3 e3                	shl    %cl,%ebx
  802793:	89 f9                	mov    %edi,%ecx
  802795:	89 d0                	mov    %edx,%eax
  802797:	d3 e8                	shr    %cl,%eax
  802799:	89 e9                	mov    %ebp,%ecx
  80279b:	09 d8                	or     %ebx,%eax
  80279d:	89 d3                	mov    %edx,%ebx
  80279f:	89 f2                	mov    %esi,%edx
  8027a1:	f7 34 24             	divl   (%esp)
  8027a4:	89 d6                	mov    %edx,%esi
  8027a6:	d3 e3                	shl    %cl,%ebx
  8027a8:	f7 64 24 04          	mull   0x4(%esp)
  8027ac:	39 d6                	cmp    %edx,%esi
  8027ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027b2:	89 d1                	mov    %edx,%ecx
  8027b4:	89 c3                	mov    %eax,%ebx
  8027b6:	72 08                	jb     8027c0 <__umoddi3+0x110>
  8027b8:	75 11                	jne    8027cb <__umoddi3+0x11b>
  8027ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8027be:	73 0b                	jae    8027cb <__umoddi3+0x11b>
  8027c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8027c4:	1b 14 24             	sbb    (%esp),%edx
  8027c7:	89 d1                	mov    %edx,%ecx
  8027c9:	89 c3                	mov    %eax,%ebx
  8027cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8027cf:	29 da                	sub    %ebx,%edx
  8027d1:	19 ce                	sbb    %ecx,%esi
  8027d3:	89 f9                	mov    %edi,%ecx
  8027d5:	89 f0                	mov    %esi,%eax
  8027d7:	d3 e0                	shl    %cl,%eax
  8027d9:	89 e9                	mov    %ebp,%ecx
  8027db:	d3 ea                	shr    %cl,%edx
  8027dd:	89 e9                	mov    %ebp,%ecx
  8027df:	d3 ee                	shr    %cl,%esi
  8027e1:	09 d0                	or     %edx,%eax
  8027e3:	89 f2                	mov    %esi,%edx
  8027e5:	83 c4 1c             	add    $0x1c,%esp
  8027e8:	5b                   	pop    %ebx
  8027e9:	5e                   	pop    %esi
  8027ea:	5f                   	pop    %edi
  8027eb:	5d                   	pop    %ebp
  8027ec:	c3                   	ret    
  8027ed:	8d 76 00             	lea    0x0(%esi),%esi
  8027f0:	29 f9                	sub    %edi,%ecx
  8027f2:	19 d6                	sbb    %edx,%esi
  8027f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027fc:	e9 18 ff ff ff       	jmp    802719 <__umoddi3+0x69>
