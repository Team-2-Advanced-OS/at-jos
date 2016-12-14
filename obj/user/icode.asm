
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003e:	c7 05 00 30 80 00 c0 	movl   $0x8029c0,0x803000
  800045:	29 80 00 

	cprintf("icode startup\n");
  800048:	68 c6 29 80 00       	push   $0x8029c6
  80004d:	e8 1b 02 00 00       	call   80026d <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 d5 29 80 00 	movl   $0x8029d5,(%esp)
  800059:	e8 0f 02 00 00       	call   80026d <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 e8 29 80 00       	push   $0x8029e8
  800068:	e8 ed 15 00 00       	call   80165a <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 ee 29 80 00       	push   $0x8029ee
  80007c:	6a 0f                	push   $0xf
  80007e:	68 04 2a 80 00       	push   $0x802a04
  800083:	e8 0c 01 00 00       	call   800194 <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 11 2a 80 00       	push   $0x802a11
  800090:	e8 d8 01 00 00       	call   80026d <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80009e:	eb 0d                	jmp    8000ad <umain+0x7a>
		sys_cputs(buf, n);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	50                   	push   %eax
  8000a4:	53                   	push   %ebx
  8000a5:	e8 8f 0a 00 00       	call   800b39 <sys_cputs>
  8000aa:	83 c4 10             	add    $0x10,%esp
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000ad:	83 ec 04             	sub    $0x4,%esp
  8000b0:	68 00 02 00 00       	push   $0x200
  8000b5:	53                   	push   %ebx
  8000b6:	56                   	push   %esi
  8000b7:	e8 ea 10 00 00       	call   8011a6 <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 24 2a 80 00       	push   $0x802a24
  8000cb:	e8 9d 01 00 00       	call   80026d <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 92 0f 00 00       	call   80106a <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 38 2a 80 00 	movl   $0x802a38,(%esp)
  8000df:	e8 89 01 00 00       	call   80026d <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 4c 2a 80 00       	push   $0x802a4c
  8000f0:	68 55 2a 80 00       	push   $0x802a55
  8000f5:	68 5f 2a 80 00       	push   $0x802a5f
  8000fa:	68 5e 2a 80 00       	push   $0x802a5e
  8000ff:	e8 33 1b 00 00       	call   801c37 <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 64 2a 80 00       	push   $0x802a64
  800111:	6a 1a                	push   $0x1a
  800113:	68 04 2a 80 00       	push   $0x802a04
  800118:	e8 77 00 00 00       	call   800194 <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 7b 2a 80 00       	push   $0x802a7b
  800125:	e8 43 01 00 00       	call   80026d <cprintf>
}
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5d                   	pop    %ebp
  800133:	c3                   	ret    

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80013f:	e8 73 0a 00 00       	call   800bb7 <sys_getenvid>
  800144:	25 ff 03 00 00       	and    $0x3ff,%eax
  800149:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800151:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800156:	85 db                	test   %ebx,%ebx
  800158:	7e 07                	jle    800161 <libmain+0x2d>
		binaryname = argv[0];
  80015a:	8b 06                	mov    (%esi),%eax
  80015c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	e8 c8 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80016b:	e8 0a 00 00 00       	call   80017a <exit>
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800180:	e8 10 0f 00 00       	call   801095 <close_all>
	sys_env_destroy(0);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	6a 00                	push   $0x0
  80018a:	e8 e7 09 00 00       	call   800b76 <sys_env_destroy>
}
  80018f:	83 c4 10             	add    $0x10,%esp
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800199:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a2:	e8 10 0a 00 00       	call   800bb7 <sys_getenvid>
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	ff 75 0c             	pushl  0xc(%ebp)
  8001ad:	ff 75 08             	pushl  0x8(%ebp)
  8001b0:	56                   	push   %esi
  8001b1:	50                   	push   %eax
  8001b2:	68 98 2a 80 00       	push   $0x802a98
  8001b7:	e8 b1 00 00 00       	call   80026d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	53                   	push   %ebx
  8001c0:	ff 75 10             	pushl  0x10(%ebp)
  8001c3:	e8 54 00 00 00       	call   80021c <vcprintf>
	cprintf("\n");
  8001c8:	c7 04 24 b9 2f 80 00 	movl   $0x802fb9,(%esp)
  8001cf:	e8 99 00 00 00       	call   80026d <cprintf>
  8001d4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d7:	cc                   	int3   
  8001d8:	eb fd                	jmp    8001d7 <_panic+0x43>

008001da <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	53                   	push   %ebx
  8001de:	83 ec 04             	sub    $0x4,%esp
  8001e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e4:	8b 13                	mov    (%ebx),%edx
  8001e6:	8d 42 01             	lea    0x1(%edx),%eax
  8001e9:	89 03                	mov    %eax,(%ebx)
  8001eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f7:	75 1a                	jne    800213 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	68 ff 00 00 00       	push   $0xff
  800201:	8d 43 08             	lea    0x8(%ebx),%eax
  800204:	50                   	push   %eax
  800205:	e8 2f 09 00 00       	call   800b39 <sys_cputs>
		b->idx = 0;
  80020a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800210:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800213:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800217:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800225:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022c:	00 00 00 
	b.cnt = 0;
  80022f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800236:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800239:	ff 75 0c             	pushl  0xc(%ebp)
  80023c:	ff 75 08             	pushl  0x8(%ebp)
  80023f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800245:	50                   	push   %eax
  800246:	68 da 01 80 00       	push   $0x8001da
  80024b:	e8 54 01 00 00       	call   8003a4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800250:	83 c4 08             	add    $0x8,%esp
  800253:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800259:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025f:	50                   	push   %eax
  800260:	e8 d4 08 00 00       	call   800b39 <sys_cputs>

	return b.cnt;
}
  800265:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800273:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800276:	50                   	push   %eax
  800277:	ff 75 08             	pushl  0x8(%ebp)
  80027a:	e8 9d ff ff ff       	call   80021c <vcprintf>
	va_end(ap);

	return cnt;
}
  80027f:	c9                   	leave  
  800280:	c3                   	ret    

00800281 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	57                   	push   %edi
  800285:	56                   	push   %esi
  800286:	53                   	push   %ebx
  800287:	83 ec 1c             	sub    $0x1c,%esp
  80028a:	89 c7                	mov    %eax,%edi
  80028c:	89 d6                	mov    %edx,%esi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	8b 55 0c             	mov    0xc(%ebp),%edx
  800294:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800297:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002a5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002a8:	39 d3                	cmp    %edx,%ebx
  8002aa:	72 05                	jb     8002b1 <printnum+0x30>
  8002ac:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002af:	77 45                	ja     8002f6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b1:	83 ec 0c             	sub    $0xc,%esp
  8002b4:	ff 75 18             	pushl  0x18(%ebp)
  8002b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ba:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002bd:	53                   	push   %ebx
  8002be:	ff 75 10             	pushl  0x10(%ebp)
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ca:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d0:	e8 5b 24 00 00       	call   802730 <__udivdi3>
  8002d5:	83 c4 18             	add    $0x18,%esp
  8002d8:	52                   	push   %edx
  8002d9:	50                   	push   %eax
  8002da:	89 f2                	mov    %esi,%edx
  8002dc:	89 f8                	mov    %edi,%eax
  8002de:	e8 9e ff ff ff       	call   800281 <printnum>
  8002e3:	83 c4 20             	add    $0x20,%esp
  8002e6:	eb 18                	jmp    800300 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	56                   	push   %esi
  8002ec:	ff 75 18             	pushl  0x18(%ebp)
  8002ef:	ff d7                	call   *%edi
  8002f1:	83 c4 10             	add    $0x10,%esp
  8002f4:	eb 03                	jmp    8002f9 <printnum+0x78>
  8002f6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f9:	83 eb 01             	sub    $0x1,%ebx
  8002fc:	85 db                	test   %ebx,%ebx
  8002fe:	7f e8                	jg     8002e8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800300:	83 ec 08             	sub    $0x8,%esp
  800303:	56                   	push   %esi
  800304:	83 ec 04             	sub    $0x4,%esp
  800307:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030a:	ff 75 e0             	pushl  -0x20(%ebp)
  80030d:	ff 75 dc             	pushl  -0x24(%ebp)
  800310:	ff 75 d8             	pushl  -0x28(%ebp)
  800313:	e8 48 25 00 00       	call   802860 <__umoddi3>
  800318:	83 c4 14             	add    $0x14,%esp
  80031b:	0f be 80 bb 2a 80 00 	movsbl 0x802abb(%eax),%eax
  800322:	50                   	push   %eax
  800323:	ff d7                	call   *%edi
}
  800325:	83 c4 10             	add    $0x10,%esp
  800328:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032b:	5b                   	pop    %ebx
  80032c:	5e                   	pop    %esi
  80032d:	5f                   	pop    %edi
  80032e:	5d                   	pop    %ebp
  80032f:	c3                   	ret    

00800330 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800333:	83 fa 01             	cmp    $0x1,%edx
  800336:	7e 0e                	jle    800346 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033d:	89 08                	mov    %ecx,(%eax)
  80033f:	8b 02                	mov    (%edx),%eax
  800341:	8b 52 04             	mov    0x4(%edx),%edx
  800344:	eb 22                	jmp    800368 <getuint+0x38>
	else if (lflag)
  800346:	85 d2                	test   %edx,%edx
  800348:	74 10                	je     80035a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80034a:	8b 10                	mov    (%eax),%edx
  80034c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034f:	89 08                	mov    %ecx,(%eax)
  800351:	8b 02                	mov    (%edx),%eax
  800353:	ba 00 00 00 00       	mov    $0x0,%edx
  800358:	eb 0e                	jmp    800368 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80035a:	8b 10                	mov    (%eax),%edx
  80035c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035f:	89 08                	mov    %ecx,(%eax)
  800361:	8b 02                	mov    (%edx),%eax
  800363:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800370:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800374:	8b 10                	mov    (%eax),%edx
  800376:	3b 50 04             	cmp    0x4(%eax),%edx
  800379:	73 0a                	jae    800385 <sprintputch+0x1b>
		*b->buf++ = ch;
  80037b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 45 08             	mov    0x8(%ebp),%eax
  800383:	88 02                	mov    %al,(%edx)
}
  800385:	5d                   	pop    %ebp
  800386:	c3                   	ret    

00800387 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80038d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800390:	50                   	push   %eax
  800391:	ff 75 10             	pushl  0x10(%ebp)
  800394:	ff 75 0c             	pushl  0xc(%ebp)
  800397:	ff 75 08             	pushl  0x8(%ebp)
  80039a:	e8 05 00 00 00       	call   8003a4 <vprintfmt>
	va_end(ap);
}
  80039f:	83 c4 10             	add    $0x10,%esp
  8003a2:	c9                   	leave  
  8003a3:	c3                   	ret    

008003a4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	57                   	push   %edi
  8003a8:	56                   	push   %esi
  8003a9:	53                   	push   %ebx
  8003aa:	83 ec 2c             	sub    $0x2c,%esp
  8003ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8003b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b6:	eb 12                	jmp    8003ca <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b8:	85 c0                	test   %eax,%eax
  8003ba:	0f 84 89 03 00 00    	je     800749 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003c0:	83 ec 08             	sub    $0x8,%esp
  8003c3:	53                   	push   %ebx
  8003c4:	50                   	push   %eax
  8003c5:	ff d6                	call   *%esi
  8003c7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ca:	83 c7 01             	add    $0x1,%edi
  8003cd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003d1:	83 f8 25             	cmp    $0x25,%eax
  8003d4:	75 e2                	jne    8003b8 <vprintfmt+0x14>
  8003d6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003da:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003e1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f4:	eb 07                	jmp    8003fd <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8d 47 01             	lea    0x1(%edi),%eax
  800400:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800403:	0f b6 07             	movzbl (%edi),%eax
  800406:	0f b6 c8             	movzbl %al,%ecx
  800409:	83 e8 23             	sub    $0x23,%eax
  80040c:	3c 55                	cmp    $0x55,%al
  80040e:	0f 87 1a 03 00 00    	ja     80072e <vprintfmt+0x38a>
  800414:	0f b6 c0             	movzbl %al,%eax
  800417:	ff 24 85 00 2c 80 00 	jmp    *0x802c00(,%eax,4)
  80041e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800421:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800425:	eb d6                	jmp    8003fd <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80042a:	b8 00 00 00 00       	mov    $0x0,%eax
  80042f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800432:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800435:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800439:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80043c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80043f:	83 fa 09             	cmp    $0x9,%edx
  800442:	77 39                	ja     80047d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800444:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800447:	eb e9                	jmp    800432 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8d 48 04             	lea    0x4(%eax),%ecx
  80044f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800452:	8b 00                	mov    (%eax),%eax
  800454:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800457:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80045a:	eb 27                	jmp    800483 <vprintfmt+0xdf>
  80045c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045f:	85 c0                	test   %eax,%eax
  800461:	b9 00 00 00 00       	mov    $0x0,%ecx
  800466:	0f 49 c8             	cmovns %eax,%ecx
  800469:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046f:	eb 8c                	jmp    8003fd <vprintfmt+0x59>
  800471:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800474:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80047b:	eb 80                	jmp    8003fd <vprintfmt+0x59>
  80047d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800480:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800483:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800487:	0f 89 70 ff ff ff    	jns    8003fd <vprintfmt+0x59>
				width = precision, precision = -1;
  80048d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800490:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800493:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80049a:	e9 5e ff ff ff       	jmp    8003fd <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80049f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a5:	e9 53 ff ff ff       	jmp    8003fd <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ad:	8d 50 04             	lea    0x4(%eax),%edx
  8004b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	53                   	push   %ebx
  8004b7:	ff 30                	pushl  (%eax)
  8004b9:	ff d6                	call   *%esi
			break;
  8004bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c1:	e9 04 ff ff ff       	jmp    8003ca <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8d 50 04             	lea    0x4(%eax),%edx
  8004cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cf:	8b 00                	mov    (%eax),%eax
  8004d1:	99                   	cltd   
  8004d2:	31 d0                	xor    %edx,%eax
  8004d4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d6:	83 f8 0f             	cmp    $0xf,%eax
  8004d9:	7f 0b                	jg     8004e6 <vprintfmt+0x142>
  8004db:	8b 14 85 60 2d 80 00 	mov    0x802d60(,%eax,4),%edx
  8004e2:	85 d2                	test   %edx,%edx
  8004e4:	75 18                	jne    8004fe <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004e6:	50                   	push   %eax
  8004e7:	68 d3 2a 80 00       	push   $0x802ad3
  8004ec:	53                   	push   %ebx
  8004ed:	56                   	push   %esi
  8004ee:	e8 94 fe ff ff       	call   800387 <printfmt>
  8004f3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f9:	e9 cc fe ff ff       	jmp    8003ca <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004fe:	52                   	push   %edx
  8004ff:	68 9a 2e 80 00       	push   $0x802e9a
  800504:	53                   	push   %ebx
  800505:	56                   	push   %esi
  800506:	e8 7c fe ff ff       	call   800387 <printfmt>
  80050b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800511:	e9 b4 fe ff ff       	jmp    8003ca <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 50 04             	lea    0x4(%eax),%edx
  80051c:	89 55 14             	mov    %edx,0x14(%ebp)
  80051f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800521:	85 ff                	test   %edi,%edi
  800523:	b8 cc 2a 80 00       	mov    $0x802acc,%eax
  800528:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80052b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052f:	0f 8e 94 00 00 00    	jle    8005c9 <vprintfmt+0x225>
  800535:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800539:	0f 84 98 00 00 00    	je     8005d7 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	ff 75 d0             	pushl  -0x30(%ebp)
  800545:	57                   	push   %edi
  800546:	e8 86 02 00 00       	call   8007d1 <strnlen>
  80054b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80054e:	29 c1                	sub    %eax,%ecx
  800550:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800553:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800556:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80055a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800560:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800562:	eb 0f                	jmp    800573 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	53                   	push   %ebx
  800568:	ff 75 e0             	pushl  -0x20(%ebp)
  80056b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056d:	83 ef 01             	sub    $0x1,%edi
  800570:	83 c4 10             	add    $0x10,%esp
  800573:	85 ff                	test   %edi,%edi
  800575:	7f ed                	jg     800564 <vprintfmt+0x1c0>
  800577:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80057a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80057d:	85 c9                	test   %ecx,%ecx
  80057f:	b8 00 00 00 00       	mov    $0x0,%eax
  800584:	0f 49 c1             	cmovns %ecx,%eax
  800587:	29 c1                	sub    %eax,%ecx
  800589:	89 75 08             	mov    %esi,0x8(%ebp)
  80058c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800592:	89 cb                	mov    %ecx,%ebx
  800594:	eb 4d                	jmp    8005e3 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800596:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80059a:	74 1b                	je     8005b7 <vprintfmt+0x213>
  80059c:	0f be c0             	movsbl %al,%eax
  80059f:	83 e8 20             	sub    $0x20,%eax
  8005a2:	83 f8 5e             	cmp    $0x5e,%eax
  8005a5:	76 10                	jbe    8005b7 <vprintfmt+0x213>
					putch('?', putdat);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	ff 75 0c             	pushl  0xc(%ebp)
  8005ad:	6a 3f                	push   $0x3f
  8005af:	ff 55 08             	call   *0x8(%ebp)
  8005b2:	83 c4 10             	add    $0x10,%esp
  8005b5:	eb 0d                	jmp    8005c4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	ff 75 0c             	pushl  0xc(%ebp)
  8005bd:	52                   	push   %edx
  8005be:	ff 55 08             	call   *0x8(%ebp)
  8005c1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c4:	83 eb 01             	sub    $0x1,%ebx
  8005c7:	eb 1a                	jmp    8005e3 <vprintfmt+0x23f>
  8005c9:	89 75 08             	mov    %esi,0x8(%ebp)
  8005cc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005cf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d5:	eb 0c                	jmp    8005e3 <vprintfmt+0x23f>
  8005d7:	89 75 08             	mov    %esi,0x8(%ebp)
  8005da:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005dd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005e3:	83 c7 01             	add    $0x1,%edi
  8005e6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ea:	0f be d0             	movsbl %al,%edx
  8005ed:	85 d2                	test   %edx,%edx
  8005ef:	74 23                	je     800614 <vprintfmt+0x270>
  8005f1:	85 f6                	test   %esi,%esi
  8005f3:	78 a1                	js     800596 <vprintfmt+0x1f2>
  8005f5:	83 ee 01             	sub    $0x1,%esi
  8005f8:	79 9c                	jns    800596 <vprintfmt+0x1f2>
  8005fa:	89 df                	mov    %ebx,%edi
  8005fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800602:	eb 18                	jmp    80061c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800604:	83 ec 08             	sub    $0x8,%esp
  800607:	53                   	push   %ebx
  800608:	6a 20                	push   $0x20
  80060a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060c:	83 ef 01             	sub    $0x1,%edi
  80060f:	83 c4 10             	add    $0x10,%esp
  800612:	eb 08                	jmp    80061c <vprintfmt+0x278>
  800614:	89 df                	mov    %ebx,%edi
  800616:	8b 75 08             	mov    0x8(%ebp),%esi
  800619:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061c:	85 ff                	test   %edi,%edi
  80061e:	7f e4                	jg     800604 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800623:	e9 a2 fd ff ff       	jmp    8003ca <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800628:	83 fa 01             	cmp    $0x1,%edx
  80062b:	7e 16                	jle    800643 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8d 50 08             	lea    0x8(%eax),%edx
  800633:	89 55 14             	mov    %edx,0x14(%ebp)
  800636:	8b 50 04             	mov    0x4(%eax),%edx
  800639:	8b 00                	mov    (%eax),%eax
  80063b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800641:	eb 32                	jmp    800675 <vprintfmt+0x2d1>
	else if (lflag)
  800643:	85 d2                	test   %edx,%edx
  800645:	74 18                	je     80065f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8d 50 04             	lea    0x4(%eax),%edx
  80064d:	89 55 14             	mov    %edx,0x14(%ebp)
  800650:	8b 00                	mov    (%eax),%eax
  800652:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800655:	89 c1                	mov    %eax,%ecx
  800657:	c1 f9 1f             	sar    $0x1f,%ecx
  80065a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80065d:	eb 16                	jmp    800675 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8d 50 04             	lea    0x4(%eax),%edx
  800665:	89 55 14             	mov    %edx,0x14(%ebp)
  800668:	8b 00                	mov    (%eax),%eax
  80066a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066d:	89 c1                	mov    %eax,%ecx
  80066f:	c1 f9 1f             	sar    $0x1f,%ecx
  800672:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800675:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800678:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80067b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800680:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800684:	79 74                	jns    8006fa <vprintfmt+0x356>
				putch('-', putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	6a 2d                	push   $0x2d
  80068c:	ff d6                	call   *%esi
				num = -(long long) num;
  80068e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800691:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800694:	f7 d8                	neg    %eax
  800696:	83 d2 00             	adc    $0x0,%edx
  800699:	f7 da                	neg    %edx
  80069b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80069e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006a3:	eb 55                	jmp    8006fa <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a8:	e8 83 fc ff ff       	call   800330 <getuint>
			base = 10;
  8006ad:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006b2:	eb 46                	jmp    8006fa <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006b4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b7:	e8 74 fc ff ff       	call   800330 <getuint>
                        base = 8;
  8006bc:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8006c1:	eb 37                	jmp    8006fa <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	53                   	push   %ebx
  8006c7:	6a 30                	push   $0x30
  8006c9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006cb:	83 c4 08             	add    $0x8,%esp
  8006ce:	53                   	push   %ebx
  8006cf:	6a 78                	push   $0x78
  8006d1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8d 50 04             	lea    0x4(%eax),%edx
  8006d9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006dc:	8b 00                	mov    (%eax),%eax
  8006de:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006e3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e6:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006eb:	eb 0d                	jmp    8006fa <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ed:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f0:	e8 3b fc ff ff       	call   800330 <getuint>
			base = 16;
  8006f5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006fa:	83 ec 0c             	sub    $0xc,%esp
  8006fd:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800701:	57                   	push   %edi
  800702:	ff 75 e0             	pushl  -0x20(%ebp)
  800705:	51                   	push   %ecx
  800706:	52                   	push   %edx
  800707:	50                   	push   %eax
  800708:	89 da                	mov    %ebx,%edx
  80070a:	89 f0                	mov    %esi,%eax
  80070c:	e8 70 fb ff ff       	call   800281 <printnum>
			break;
  800711:	83 c4 20             	add    $0x20,%esp
  800714:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800717:	e9 ae fc ff ff       	jmp    8003ca <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	53                   	push   %ebx
  800720:	51                   	push   %ecx
  800721:	ff d6                	call   *%esi
			break;
  800723:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800729:	e9 9c fc ff ff       	jmp    8003ca <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	53                   	push   %ebx
  800732:	6a 25                	push   $0x25
  800734:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800736:	83 c4 10             	add    $0x10,%esp
  800739:	eb 03                	jmp    80073e <vprintfmt+0x39a>
  80073b:	83 ef 01             	sub    $0x1,%edi
  80073e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800742:	75 f7                	jne    80073b <vprintfmt+0x397>
  800744:	e9 81 fc ff ff       	jmp    8003ca <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800749:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074c:	5b                   	pop    %ebx
  80074d:	5e                   	pop    %esi
  80074e:	5f                   	pop    %edi
  80074f:	5d                   	pop    %ebp
  800750:	c3                   	ret    

00800751 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	83 ec 18             	sub    $0x18,%esp
  800757:	8b 45 08             	mov    0x8(%ebp),%eax
  80075a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800760:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800764:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800767:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076e:	85 c0                	test   %eax,%eax
  800770:	74 26                	je     800798 <vsnprintf+0x47>
  800772:	85 d2                	test   %edx,%edx
  800774:	7e 22                	jle    800798 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800776:	ff 75 14             	pushl  0x14(%ebp)
  800779:	ff 75 10             	pushl  0x10(%ebp)
  80077c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077f:	50                   	push   %eax
  800780:	68 6a 03 80 00       	push   $0x80036a
  800785:	e8 1a fc ff ff       	call   8003a4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800790:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800793:	83 c4 10             	add    $0x10,%esp
  800796:	eb 05                	jmp    80079d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800798:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079d:	c9                   	leave  
  80079e:	c3                   	ret    

0080079f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a8:	50                   	push   %eax
  8007a9:	ff 75 10             	pushl  0x10(%ebp)
  8007ac:	ff 75 0c             	pushl  0xc(%ebp)
  8007af:	ff 75 08             	pushl  0x8(%ebp)
  8007b2:	e8 9a ff ff ff       	call   800751 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    

008007b9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c4:	eb 03                	jmp    8007c9 <strlen+0x10>
		n++;
  8007c6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007cd:	75 f7                	jne    8007c6 <strlen+0xd>
		n++;
	return n;
}
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007da:	ba 00 00 00 00       	mov    $0x0,%edx
  8007df:	eb 03                	jmp    8007e4 <strnlen+0x13>
		n++;
  8007e1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e4:	39 c2                	cmp    %eax,%edx
  8007e6:	74 08                	je     8007f0 <strnlen+0x1f>
  8007e8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ec:	75 f3                	jne    8007e1 <strnlen+0x10>
  8007ee:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fc:	89 c2                	mov    %eax,%edx
  8007fe:	83 c2 01             	add    $0x1,%edx
  800801:	83 c1 01             	add    $0x1,%ecx
  800804:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800808:	88 5a ff             	mov    %bl,-0x1(%edx)
  80080b:	84 db                	test   %bl,%bl
  80080d:	75 ef                	jne    8007fe <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80080f:	5b                   	pop    %ebx
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	53                   	push   %ebx
  800816:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800819:	53                   	push   %ebx
  80081a:	e8 9a ff ff ff       	call   8007b9 <strlen>
  80081f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800822:	ff 75 0c             	pushl  0xc(%ebp)
  800825:	01 d8                	add    %ebx,%eax
  800827:	50                   	push   %eax
  800828:	e8 c5 ff ff ff       	call   8007f2 <strcpy>
	return dst;
}
  80082d:	89 d8                	mov    %ebx,%eax
  80082f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800832:	c9                   	leave  
  800833:	c3                   	ret    

00800834 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	56                   	push   %esi
  800838:	53                   	push   %ebx
  800839:	8b 75 08             	mov    0x8(%ebp),%esi
  80083c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083f:	89 f3                	mov    %esi,%ebx
  800841:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800844:	89 f2                	mov    %esi,%edx
  800846:	eb 0f                	jmp    800857 <strncpy+0x23>
		*dst++ = *src;
  800848:	83 c2 01             	add    $0x1,%edx
  80084b:	0f b6 01             	movzbl (%ecx),%eax
  80084e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800851:	80 39 01             	cmpb   $0x1,(%ecx)
  800854:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800857:	39 da                	cmp    %ebx,%edx
  800859:	75 ed                	jne    800848 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085b:	89 f0                	mov    %esi,%eax
  80085d:	5b                   	pop    %ebx
  80085e:	5e                   	pop    %esi
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	56                   	push   %esi
  800865:	53                   	push   %ebx
  800866:	8b 75 08             	mov    0x8(%ebp),%esi
  800869:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086c:	8b 55 10             	mov    0x10(%ebp),%edx
  80086f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800871:	85 d2                	test   %edx,%edx
  800873:	74 21                	je     800896 <strlcpy+0x35>
  800875:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800879:	89 f2                	mov    %esi,%edx
  80087b:	eb 09                	jmp    800886 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087d:	83 c2 01             	add    $0x1,%edx
  800880:	83 c1 01             	add    $0x1,%ecx
  800883:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800886:	39 c2                	cmp    %eax,%edx
  800888:	74 09                	je     800893 <strlcpy+0x32>
  80088a:	0f b6 19             	movzbl (%ecx),%ebx
  80088d:	84 db                	test   %bl,%bl
  80088f:	75 ec                	jne    80087d <strlcpy+0x1c>
  800891:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800893:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800896:	29 f0                	sub    %esi,%eax
}
  800898:	5b                   	pop    %ebx
  800899:	5e                   	pop    %esi
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a5:	eb 06                	jmp    8008ad <strcmp+0x11>
		p++, q++;
  8008a7:	83 c1 01             	add    $0x1,%ecx
  8008aa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ad:	0f b6 01             	movzbl (%ecx),%eax
  8008b0:	84 c0                	test   %al,%al
  8008b2:	74 04                	je     8008b8 <strcmp+0x1c>
  8008b4:	3a 02                	cmp    (%edx),%al
  8008b6:	74 ef                	je     8008a7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b8:	0f b6 c0             	movzbl %al,%eax
  8008bb:	0f b6 12             	movzbl (%edx),%edx
  8008be:	29 d0                	sub    %edx,%eax
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	53                   	push   %ebx
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cc:	89 c3                	mov    %eax,%ebx
  8008ce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d1:	eb 06                	jmp    8008d9 <strncmp+0x17>
		n--, p++, q++;
  8008d3:	83 c0 01             	add    $0x1,%eax
  8008d6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d9:	39 d8                	cmp    %ebx,%eax
  8008db:	74 15                	je     8008f2 <strncmp+0x30>
  8008dd:	0f b6 08             	movzbl (%eax),%ecx
  8008e0:	84 c9                	test   %cl,%cl
  8008e2:	74 04                	je     8008e8 <strncmp+0x26>
  8008e4:	3a 0a                	cmp    (%edx),%cl
  8008e6:	74 eb                	je     8008d3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e8:	0f b6 00             	movzbl (%eax),%eax
  8008eb:	0f b6 12             	movzbl (%edx),%edx
  8008ee:	29 d0                	sub    %edx,%eax
  8008f0:	eb 05                	jmp    8008f7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f7:	5b                   	pop    %ebx
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800904:	eb 07                	jmp    80090d <strchr+0x13>
		if (*s == c)
  800906:	38 ca                	cmp    %cl,%dl
  800908:	74 0f                	je     800919 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090a:	83 c0 01             	add    $0x1,%eax
  80090d:	0f b6 10             	movzbl (%eax),%edx
  800910:	84 d2                	test   %dl,%dl
  800912:	75 f2                	jne    800906 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800925:	eb 03                	jmp    80092a <strfind+0xf>
  800927:	83 c0 01             	add    $0x1,%eax
  80092a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092d:	38 ca                	cmp    %cl,%dl
  80092f:	74 04                	je     800935 <strfind+0x1a>
  800931:	84 d2                	test   %dl,%dl
  800933:	75 f2                	jne    800927 <strfind+0xc>
			break;
	return (char *) s;
}
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	57                   	push   %edi
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800940:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800943:	85 c9                	test   %ecx,%ecx
  800945:	74 36                	je     80097d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800947:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094d:	75 28                	jne    800977 <memset+0x40>
  80094f:	f6 c1 03             	test   $0x3,%cl
  800952:	75 23                	jne    800977 <memset+0x40>
		c &= 0xFF;
  800954:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800958:	89 d3                	mov    %edx,%ebx
  80095a:	c1 e3 08             	shl    $0x8,%ebx
  80095d:	89 d6                	mov    %edx,%esi
  80095f:	c1 e6 18             	shl    $0x18,%esi
  800962:	89 d0                	mov    %edx,%eax
  800964:	c1 e0 10             	shl    $0x10,%eax
  800967:	09 f0                	or     %esi,%eax
  800969:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80096b:	89 d8                	mov    %ebx,%eax
  80096d:	09 d0                	or     %edx,%eax
  80096f:	c1 e9 02             	shr    $0x2,%ecx
  800972:	fc                   	cld    
  800973:	f3 ab                	rep stos %eax,%es:(%edi)
  800975:	eb 06                	jmp    80097d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800977:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097a:	fc                   	cld    
  80097b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097d:	89 f8                	mov    %edi,%eax
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	5f                   	pop    %edi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	57                   	push   %edi
  800988:	56                   	push   %esi
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800992:	39 c6                	cmp    %eax,%esi
  800994:	73 35                	jae    8009cb <memmove+0x47>
  800996:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800999:	39 d0                	cmp    %edx,%eax
  80099b:	73 2e                	jae    8009cb <memmove+0x47>
		s += n;
		d += n;
  80099d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a0:	89 d6                	mov    %edx,%esi
  8009a2:	09 fe                	or     %edi,%esi
  8009a4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009aa:	75 13                	jne    8009bf <memmove+0x3b>
  8009ac:	f6 c1 03             	test   $0x3,%cl
  8009af:	75 0e                	jne    8009bf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009b1:	83 ef 04             	sub    $0x4,%edi
  8009b4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b7:	c1 e9 02             	shr    $0x2,%ecx
  8009ba:	fd                   	std    
  8009bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bd:	eb 09                	jmp    8009c8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009bf:	83 ef 01             	sub    $0x1,%edi
  8009c2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009c5:	fd                   	std    
  8009c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c8:	fc                   	cld    
  8009c9:	eb 1d                	jmp    8009e8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cb:	89 f2                	mov    %esi,%edx
  8009cd:	09 c2                	or     %eax,%edx
  8009cf:	f6 c2 03             	test   $0x3,%dl
  8009d2:	75 0f                	jne    8009e3 <memmove+0x5f>
  8009d4:	f6 c1 03             	test   $0x3,%cl
  8009d7:	75 0a                	jne    8009e3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009d9:	c1 e9 02             	shr    $0x2,%ecx
  8009dc:	89 c7                	mov    %eax,%edi
  8009de:	fc                   	cld    
  8009df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e1:	eb 05                	jmp    8009e8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e3:	89 c7                	mov    %eax,%edi
  8009e5:	fc                   	cld    
  8009e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e8:	5e                   	pop    %esi
  8009e9:	5f                   	pop    %edi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ef:	ff 75 10             	pushl  0x10(%ebp)
  8009f2:	ff 75 0c             	pushl  0xc(%ebp)
  8009f5:	ff 75 08             	pushl  0x8(%ebp)
  8009f8:	e8 87 ff ff ff       	call   800984 <memmove>
}
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    

008009ff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
  800a07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0a:	89 c6                	mov    %eax,%esi
  800a0c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0f:	eb 1a                	jmp    800a2b <memcmp+0x2c>
		if (*s1 != *s2)
  800a11:	0f b6 08             	movzbl (%eax),%ecx
  800a14:	0f b6 1a             	movzbl (%edx),%ebx
  800a17:	38 d9                	cmp    %bl,%cl
  800a19:	74 0a                	je     800a25 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a1b:	0f b6 c1             	movzbl %cl,%eax
  800a1e:	0f b6 db             	movzbl %bl,%ebx
  800a21:	29 d8                	sub    %ebx,%eax
  800a23:	eb 0f                	jmp    800a34 <memcmp+0x35>
		s1++, s2++;
  800a25:	83 c0 01             	add    $0x1,%eax
  800a28:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2b:	39 f0                	cmp    %esi,%eax
  800a2d:	75 e2                	jne    800a11 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a34:	5b                   	pop    %ebx
  800a35:	5e                   	pop    %esi
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    

00800a38 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	53                   	push   %ebx
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a3f:	89 c1                	mov    %eax,%ecx
  800a41:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a44:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a48:	eb 0a                	jmp    800a54 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4a:	0f b6 10             	movzbl (%eax),%edx
  800a4d:	39 da                	cmp    %ebx,%edx
  800a4f:	74 07                	je     800a58 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a51:	83 c0 01             	add    $0x1,%eax
  800a54:	39 c8                	cmp    %ecx,%eax
  800a56:	72 f2                	jb     800a4a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a58:	5b                   	pop    %ebx
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	57                   	push   %edi
  800a5f:	56                   	push   %esi
  800a60:	53                   	push   %ebx
  800a61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a64:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a67:	eb 03                	jmp    800a6c <strtol+0x11>
		s++;
  800a69:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6c:	0f b6 01             	movzbl (%ecx),%eax
  800a6f:	3c 20                	cmp    $0x20,%al
  800a71:	74 f6                	je     800a69 <strtol+0xe>
  800a73:	3c 09                	cmp    $0x9,%al
  800a75:	74 f2                	je     800a69 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a77:	3c 2b                	cmp    $0x2b,%al
  800a79:	75 0a                	jne    800a85 <strtol+0x2a>
		s++;
  800a7b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a83:	eb 11                	jmp    800a96 <strtol+0x3b>
  800a85:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8a:	3c 2d                	cmp    $0x2d,%al
  800a8c:	75 08                	jne    800a96 <strtol+0x3b>
		s++, neg = 1;
  800a8e:	83 c1 01             	add    $0x1,%ecx
  800a91:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a96:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9c:	75 15                	jne    800ab3 <strtol+0x58>
  800a9e:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa1:	75 10                	jne    800ab3 <strtol+0x58>
  800aa3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa7:	75 7c                	jne    800b25 <strtol+0xca>
		s += 2, base = 16;
  800aa9:	83 c1 02             	add    $0x2,%ecx
  800aac:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab1:	eb 16                	jmp    800ac9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ab3:	85 db                	test   %ebx,%ebx
  800ab5:	75 12                	jne    800ac9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abc:	80 39 30             	cmpb   $0x30,(%ecx)
  800abf:	75 08                	jne    800ac9 <strtol+0x6e>
		s++, base = 8;
  800ac1:	83 c1 01             	add    $0x1,%ecx
  800ac4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ac9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ace:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad1:	0f b6 11             	movzbl (%ecx),%edx
  800ad4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad7:	89 f3                	mov    %esi,%ebx
  800ad9:	80 fb 09             	cmp    $0x9,%bl
  800adc:	77 08                	ja     800ae6 <strtol+0x8b>
			dig = *s - '0';
  800ade:	0f be d2             	movsbl %dl,%edx
  800ae1:	83 ea 30             	sub    $0x30,%edx
  800ae4:	eb 22                	jmp    800b08 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ae6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae9:	89 f3                	mov    %esi,%ebx
  800aeb:	80 fb 19             	cmp    $0x19,%bl
  800aee:	77 08                	ja     800af8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800af0:	0f be d2             	movsbl %dl,%edx
  800af3:	83 ea 57             	sub    $0x57,%edx
  800af6:	eb 10                	jmp    800b08 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800af8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800afb:	89 f3                	mov    %esi,%ebx
  800afd:	80 fb 19             	cmp    $0x19,%bl
  800b00:	77 16                	ja     800b18 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b02:	0f be d2             	movsbl %dl,%edx
  800b05:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b08:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b0b:	7d 0b                	jge    800b18 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b0d:	83 c1 01             	add    $0x1,%ecx
  800b10:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b14:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b16:	eb b9                	jmp    800ad1 <strtol+0x76>

	if (endptr)
  800b18:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1c:	74 0d                	je     800b2b <strtol+0xd0>
		*endptr = (char *) s;
  800b1e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b21:	89 0e                	mov    %ecx,(%esi)
  800b23:	eb 06                	jmp    800b2b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b25:	85 db                	test   %ebx,%ebx
  800b27:	74 98                	je     800ac1 <strtol+0x66>
  800b29:	eb 9e                	jmp    800ac9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b2b:	89 c2                	mov    %eax,%edx
  800b2d:	f7 da                	neg    %edx
  800b2f:	85 ff                	test   %edi,%edi
  800b31:	0f 45 c2             	cmovne %edx,%eax
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b47:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4a:	89 c3                	mov    %eax,%ebx
  800b4c:	89 c7                	mov    %eax,%edi
  800b4e:	89 c6                	mov    %eax,%esi
  800b50:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b62:	b8 01 00 00 00       	mov    $0x1,%eax
  800b67:	89 d1                	mov    %edx,%ecx
  800b69:	89 d3                	mov    %edx,%ebx
  800b6b:	89 d7                	mov    %edx,%edi
  800b6d:	89 d6                	mov    %edx,%esi
  800b6f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
  800b7c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b84:	b8 03 00 00 00       	mov    $0x3,%eax
  800b89:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8c:	89 cb                	mov    %ecx,%ebx
  800b8e:	89 cf                	mov    %ecx,%edi
  800b90:	89 ce                	mov    %ecx,%esi
  800b92:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b94:	85 c0                	test   %eax,%eax
  800b96:	7e 17                	jle    800baf <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b98:	83 ec 0c             	sub    $0xc,%esp
  800b9b:	50                   	push   %eax
  800b9c:	6a 03                	push   $0x3
  800b9e:	68 bf 2d 80 00       	push   $0x802dbf
  800ba3:	6a 23                	push   $0x23
  800ba5:	68 dc 2d 80 00       	push   $0x802ddc
  800baa:	e8 e5 f5 ff ff       	call   800194 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800baf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc2:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc7:	89 d1                	mov    %edx,%ecx
  800bc9:	89 d3                	mov    %edx,%ebx
  800bcb:	89 d7                	mov    %edx,%edi
  800bcd:	89 d6                	mov    %edx,%esi
  800bcf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_yield>:

void
sys_yield(void)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be6:	89 d1                	mov    %edx,%ecx
  800be8:	89 d3                	mov    %edx,%ebx
  800bea:	89 d7                	mov    %edx,%edi
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfe:	be 00 00 00 00       	mov    $0x0,%esi
  800c03:	b8 04 00 00 00       	mov    $0x4,%eax
  800c08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c11:	89 f7                	mov    %esi,%edi
  800c13:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c15:	85 c0                	test   %eax,%eax
  800c17:	7e 17                	jle    800c30 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c19:	83 ec 0c             	sub    $0xc,%esp
  800c1c:	50                   	push   %eax
  800c1d:	6a 04                	push   $0x4
  800c1f:	68 bf 2d 80 00       	push   $0x802dbf
  800c24:	6a 23                	push   $0x23
  800c26:	68 dc 2d 80 00       	push   $0x802ddc
  800c2b:	e8 64 f5 ff ff       	call   800194 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	57                   	push   %edi
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
  800c3e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	b8 05 00 00 00       	mov    $0x5,%eax
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c52:	8b 75 18             	mov    0x18(%ebp),%esi
  800c55:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c57:	85 c0                	test   %eax,%eax
  800c59:	7e 17                	jle    800c72 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5b:	83 ec 0c             	sub    $0xc,%esp
  800c5e:	50                   	push   %eax
  800c5f:	6a 05                	push   $0x5
  800c61:	68 bf 2d 80 00       	push   $0x802dbf
  800c66:	6a 23                	push   $0x23
  800c68:	68 dc 2d 80 00       	push   $0x802ddc
  800c6d:	e8 22 f5 ff ff       	call   800194 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
  800c80:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c88:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	89 df                	mov    %ebx,%edi
  800c95:	89 de                	mov    %ebx,%esi
  800c97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	7e 17                	jle    800cb4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	83 ec 0c             	sub    $0xc,%esp
  800ca0:	50                   	push   %eax
  800ca1:	6a 06                	push   $0x6
  800ca3:	68 bf 2d 80 00       	push   $0x802dbf
  800ca8:	6a 23                	push   $0x23
  800caa:	68 dc 2d 80 00       	push   $0x802ddc
  800caf:	e8 e0 f4 ff ff       	call   800194 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800cc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cca:	b8 08 00 00 00       	mov    $0x8,%eax
  800ccf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	89 df                	mov    %ebx,%edi
  800cd7:	89 de                	mov    %ebx,%esi
  800cd9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	7e 17                	jle    800cf6 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdf:	83 ec 0c             	sub    $0xc,%esp
  800ce2:	50                   	push   %eax
  800ce3:	6a 08                	push   $0x8
  800ce5:	68 bf 2d 80 00       	push   $0x802dbf
  800cea:	6a 23                	push   $0x23
  800cec:	68 dc 2d 80 00       	push   $0x802ddc
  800cf1:	e8 9e f4 ff ff       	call   800194 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800d0c:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800d1f:	7e 17                	jle    800d38 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d21:	83 ec 0c             	sub    $0xc,%esp
  800d24:	50                   	push   %eax
  800d25:	6a 09                	push   $0x9
  800d27:	68 bf 2d 80 00       	push   $0x802dbf
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 dc 2d 80 00       	push   $0x802ddc
  800d33:	e8 5c f4 ff ff       	call   800194 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800d4e:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800d61:	7e 17                	jle    800d7a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	50                   	push   %eax
  800d67:	6a 0a                	push   $0xa
  800d69:	68 bf 2d 80 00       	push   $0x802dbf
  800d6e:	6a 23                	push   $0x23
  800d70:	68 dc 2d 80 00       	push   $0x802ddc
  800d75:	e8 1a f4 ff ff       	call   800194 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d88:	be 00 00 00 00       	mov    $0x0,%esi
  800d8d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	8b 55 08             	mov    0x8(%ebp),%edx
  800d98:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800dae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	89 cb                	mov    %ecx,%ebx
  800dbd:	89 cf                	mov    %ecx,%edi
  800dbf:	89 ce                	mov    %ecx,%esi
  800dc1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	7e 17                	jle    800dde <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc7:	83 ec 0c             	sub    $0xc,%esp
  800dca:	50                   	push   %eax
  800dcb:	6a 0d                	push   $0xd
  800dcd:	68 bf 2d 80 00       	push   $0x802dbf
  800dd2:	6a 23                	push   $0x23
  800dd4:	68 dc 2d 80 00       	push   $0x802ddc
  800dd9:	e8 b6 f3 ff ff       	call   800194 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	57                   	push   %edi
  800dea:	56                   	push   %esi
  800deb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dec:	ba 00 00 00 00       	mov    $0x0,%edx
  800df1:	b8 0e 00 00 00       	mov    $0xe,%eax
  800df6:	89 d1                	mov    %edx,%ecx
  800df8:	89 d3                	mov    %edx,%ebx
  800dfa:	89 d7                	mov    %edx,%edi
  800dfc:	89 d6                	mov    %edx,%esi
  800dfe:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <sys_transmit_packet>:

int
sys_transmit_packet(void *buf, size_t size)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	57                   	push   %edi
  800e09:	56                   	push   %esi
  800e0a:	53                   	push   %ebx
  800e0b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e13:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1e:	89 df                	mov    %ebx,%edi
  800e20:	89 de                	mov    %ebx,%esi
  800e22:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e24:	85 c0                	test   %eax,%eax
  800e26:	7e 17                	jle    800e3f <sys_transmit_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e28:	83 ec 0c             	sub    $0xc,%esp
  800e2b:	50                   	push   %eax
  800e2c:	6a 0f                	push   $0xf
  800e2e:	68 bf 2d 80 00       	push   $0x802dbf
  800e33:	6a 23                	push   $0x23
  800e35:	68 dc 2d 80 00       	push   $0x802ddc
  800e3a:	e8 55 f3 ff ff       	call   800194 <_panic>
int
sys_transmit_packet(void *buf, size_t size)
{
	return syscall(SYS_transmit_packet, 1,
		(uint32_t) buf, (uint32_t) size, 0, 0, 0);
}
  800e3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_receive_packet>:

int
sys_receive_packet(void *buf, size_t *size_store)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	57                   	push   %edi
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e55:	b8 10 00 00 00       	mov    $0x10,%eax
  800e5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e60:	89 df                	mov    %ebx,%edi
  800e62:	89 de                	mov    %ebx,%esi
  800e64:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e66:	85 c0                	test   %eax,%eax
  800e68:	7e 17                	jle    800e81 <sys_receive_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6a:	83 ec 0c             	sub    $0xc,%esp
  800e6d:	50                   	push   %eax
  800e6e:	6a 10                	push   $0x10
  800e70:	68 bf 2d 80 00       	push   $0x802dbf
  800e75:	6a 23                	push   $0x23
  800e77:	68 dc 2d 80 00       	push   $0x802ddc
  800e7c:	e8 13 f3 ff ff       	call   800194 <_panic>
int
sys_receive_packet(void *buf, size_t *size_store)
{
	return syscall(SYS_receive_packet, 1,
		(uint32_t) buf, (uint32_t) size_store, 0, 0, 0);
}
  800e81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_get_mac_address>:

int
sys_get_mac_address(void *buf)
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
  800e92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e97:	b8 11 00 00 00       	mov    $0x11,%eax
  800e9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9f:	89 cb                	mov    %ecx,%ebx
  800ea1:	89 cf                	mov    %ecx,%edi
  800ea3:	89 ce                	mov    %ecx,%esi
  800ea5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ea7:	85 c0                	test   %eax,%eax
  800ea9:	7e 17                	jle    800ec2 <sys_get_mac_address+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eab:	83 ec 0c             	sub    $0xc,%esp
  800eae:	50                   	push   %eax
  800eaf:	6a 11                	push   $0x11
  800eb1:	68 bf 2d 80 00       	push   $0x802dbf
  800eb6:	6a 23                	push   $0x23
  800eb8:	68 dc 2d 80 00       	push   $0x802ddc
  800ebd:	e8 d2 f2 ff ff       	call   800194 <_panic>
int
sys_get_mac_address(void *buf)
{
	return syscall(SYS_get_mac_address, 1,
		(uint32_t) buf, 0, 0, 0, 0);
}
  800ec2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec5:	5b                   	pop    %ebx
  800ec6:	5e                   	pop    %esi
  800ec7:	5f                   	pop    %edi
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ecd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed0:	05 00 00 00 30       	add    $0x30000000,%eax
  800ed5:	c1 e8 0c             	shr    $0xc,%eax
}
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    

00800eda <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800edd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee0:	05 00 00 00 30       	add    $0x30000000,%eax
  800ee5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eea:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800efc:	89 c2                	mov    %eax,%edx
  800efe:	c1 ea 16             	shr    $0x16,%edx
  800f01:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f08:	f6 c2 01             	test   $0x1,%dl
  800f0b:	74 11                	je     800f1e <fd_alloc+0x2d>
  800f0d:	89 c2                	mov    %eax,%edx
  800f0f:	c1 ea 0c             	shr    $0xc,%edx
  800f12:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f19:	f6 c2 01             	test   $0x1,%dl
  800f1c:	75 09                	jne    800f27 <fd_alloc+0x36>
			*fd_store = fd;
  800f1e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f20:	b8 00 00 00 00       	mov    $0x0,%eax
  800f25:	eb 17                	jmp    800f3e <fd_alloc+0x4d>
  800f27:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f2c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f31:	75 c9                	jne    800efc <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f33:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f39:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    

00800f40 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f46:	83 f8 1f             	cmp    $0x1f,%eax
  800f49:	77 36                	ja     800f81 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f4b:	c1 e0 0c             	shl    $0xc,%eax
  800f4e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f53:	89 c2                	mov    %eax,%edx
  800f55:	c1 ea 16             	shr    $0x16,%edx
  800f58:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f5f:	f6 c2 01             	test   $0x1,%dl
  800f62:	74 24                	je     800f88 <fd_lookup+0x48>
  800f64:	89 c2                	mov    %eax,%edx
  800f66:	c1 ea 0c             	shr    $0xc,%edx
  800f69:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f70:	f6 c2 01             	test   $0x1,%dl
  800f73:	74 1a                	je     800f8f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f75:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f78:	89 02                	mov    %eax,(%edx)
	return 0;
  800f7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7f:	eb 13                	jmp    800f94 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f81:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f86:	eb 0c                	jmp    800f94 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f88:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f8d:	eb 05                	jmp    800f94 <fd_lookup+0x54>
  800f8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    

00800f96 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	83 ec 08             	sub    $0x8,%esp
  800f9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f9f:	ba 68 2e 80 00       	mov    $0x802e68,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800fa4:	eb 13                	jmp    800fb9 <dev_lookup+0x23>
  800fa6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800fa9:	39 08                	cmp    %ecx,(%eax)
  800fab:	75 0c                	jne    800fb9 <dev_lookup+0x23>
			*dev = devtab[i];
  800fad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb7:	eb 2e                	jmp    800fe7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fb9:	8b 02                	mov    (%edx),%eax
  800fbb:	85 c0                	test   %eax,%eax
  800fbd:	75 e7                	jne    800fa6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fbf:	a1 08 40 80 00       	mov    0x804008,%eax
  800fc4:	8b 40 48             	mov    0x48(%eax),%eax
  800fc7:	83 ec 04             	sub    $0x4,%esp
  800fca:	51                   	push   %ecx
  800fcb:	50                   	push   %eax
  800fcc:	68 ec 2d 80 00       	push   $0x802dec
  800fd1:	e8 97 f2 ff ff       	call   80026d <cprintf>
	*dev = 0;
  800fd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fdf:	83 c4 10             	add    $0x10,%esp
  800fe2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fe7:	c9                   	leave  
  800fe8:	c3                   	ret    

00800fe9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	56                   	push   %esi
  800fed:	53                   	push   %ebx
  800fee:	83 ec 10             	sub    $0x10,%esp
  800ff1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ff4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ff7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffa:	50                   	push   %eax
  800ffb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801001:	c1 e8 0c             	shr    $0xc,%eax
  801004:	50                   	push   %eax
  801005:	e8 36 ff ff ff       	call   800f40 <fd_lookup>
  80100a:	83 c4 08             	add    $0x8,%esp
  80100d:	85 c0                	test   %eax,%eax
  80100f:	78 05                	js     801016 <fd_close+0x2d>
	    || fd != fd2)
  801011:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801014:	74 0c                	je     801022 <fd_close+0x39>
		return (must_exist ? r : 0);
  801016:	84 db                	test   %bl,%bl
  801018:	ba 00 00 00 00       	mov    $0x0,%edx
  80101d:	0f 44 c2             	cmove  %edx,%eax
  801020:	eb 41                	jmp    801063 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801022:	83 ec 08             	sub    $0x8,%esp
  801025:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801028:	50                   	push   %eax
  801029:	ff 36                	pushl  (%esi)
  80102b:	e8 66 ff ff ff       	call   800f96 <dev_lookup>
  801030:	89 c3                	mov    %eax,%ebx
  801032:	83 c4 10             	add    $0x10,%esp
  801035:	85 c0                	test   %eax,%eax
  801037:	78 1a                	js     801053 <fd_close+0x6a>
		if (dev->dev_close)
  801039:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80103c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80103f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801044:	85 c0                	test   %eax,%eax
  801046:	74 0b                	je     801053 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801048:	83 ec 0c             	sub    $0xc,%esp
  80104b:	56                   	push   %esi
  80104c:	ff d0                	call   *%eax
  80104e:	89 c3                	mov    %eax,%ebx
  801050:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801053:	83 ec 08             	sub    $0x8,%esp
  801056:	56                   	push   %esi
  801057:	6a 00                	push   $0x0
  801059:	e8 1c fc ff ff       	call   800c7a <sys_page_unmap>
	return r;
  80105e:	83 c4 10             	add    $0x10,%esp
  801061:	89 d8                	mov    %ebx,%eax
}
  801063:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801066:	5b                   	pop    %ebx
  801067:	5e                   	pop    %esi
  801068:	5d                   	pop    %ebp
  801069:	c3                   	ret    

0080106a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801070:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801073:	50                   	push   %eax
  801074:	ff 75 08             	pushl  0x8(%ebp)
  801077:	e8 c4 fe ff ff       	call   800f40 <fd_lookup>
  80107c:	83 c4 08             	add    $0x8,%esp
  80107f:	85 c0                	test   %eax,%eax
  801081:	78 10                	js     801093 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801083:	83 ec 08             	sub    $0x8,%esp
  801086:	6a 01                	push   $0x1
  801088:	ff 75 f4             	pushl  -0xc(%ebp)
  80108b:	e8 59 ff ff ff       	call   800fe9 <fd_close>
  801090:	83 c4 10             	add    $0x10,%esp
}
  801093:	c9                   	leave  
  801094:	c3                   	ret    

00801095 <close_all>:

void
close_all(void)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	53                   	push   %ebx
  801099:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80109c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010a1:	83 ec 0c             	sub    $0xc,%esp
  8010a4:	53                   	push   %ebx
  8010a5:	e8 c0 ff ff ff       	call   80106a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010aa:	83 c3 01             	add    $0x1,%ebx
  8010ad:	83 c4 10             	add    $0x10,%esp
  8010b0:	83 fb 20             	cmp    $0x20,%ebx
  8010b3:	75 ec                	jne    8010a1 <close_all+0xc>
		close(i);
}
  8010b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b8:	c9                   	leave  
  8010b9:	c3                   	ret    

008010ba <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
  8010bd:	57                   	push   %edi
  8010be:	56                   	push   %esi
  8010bf:	53                   	push   %ebx
  8010c0:	83 ec 2c             	sub    $0x2c,%esp
  8010c3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010c6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010c9:	50                   	push   %eax
  8010ca:	ff 75 08             	pushl  0x8(%ebp)
  8010cd:	e8 6e fe ff ff       	call   800f40 <fd_lookup>
  8010d2:	83 c4 08             	add    $0x8,%esp
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	0f 88 c1 00 00 00    	js     80119e <dup+0xe4>
		return r;
	close(newfdnum);
  8010dd:	83 ec 0c             	sub    $0xc,%esp
  8010e0:	56                   	push   %esi
  8010e1:	e8 84 ff ff ff       	call   80106a <close>

	newfd = INDEX2FD(newfdnum);
  8010e6:	89 f3                	mov    %esi,%ebx
  8010e8:	c1 e3 0c             	shl    $0xc,%ebx
  8010eb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010f1:	83 c4 04             	add    $0x4,%esp
  8010f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f7:	e8 de fd ff ff       	call   800eda <fd2data>
  8010fc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010fe:	89 1c 24             	mov    %ebx,(%esp)
  801101:	e8 d4 fd ff ff       	call   800eda <fd2data>
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80110c:	89 f8                	mov    %edi,%eax
  80110e:	c1 e8 16             	shr    $0x16,%eax
  801111:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801118:	a8 01                	test   $0x1,%al
  80111a:	74 37                	je     801153 <dup+0x99>
  80111c:	89 f8                	mov    %edi,%eax
  80111e:	c1 e8 0c             	shr    $0xc,%eax
  801121:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801128:	f6 c2 01             	test   $0x1,%dl
  80112b:	74 26                	je     801153 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80112d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801134:	83 ec 0c             	sub    $0xc,%esp
  801137:	25 07 0e 00 00       	and    $0xe07,%eax
  80113c:	50                   	push   %eax
  80113d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801140:	6a 00                	push   $0x0
  801142:	57                   	push   %edi
  801143:	6a 00                	push   $0x0
  801145:	e8 ee fa ff ff       	call   800c38 <sys_page_map>
  80114a:	89 c7                	mov    %eax,%edi
  80114c:	83 c4 20             	add    $0x20,%esp
  80114f:	85 c0                	test   %eax,%eax
  801151:	78 2e                	js     801181 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801153:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801156:	89 d0                	mov    %edx,%eax
  801158:	c1 e8 0c             	shr    $0xc,%eax
  80115b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801162:	83 ec 0c             	sub    $0xc,%esp
  801165:	25 07 0e 00 00       	and    $0xe07,%eax
  80116a:	50                   	push   %eax
  80116b:	53                   	push   %ebx
  80116c:	6a 00                	push   $0x0
  80116e:	52                   	push   %edx
  80116f:	6a 00                	push   $0x0
  801171:	e8 c2 fa ff ff       	call   800c38 <sys_page_map>
  801176:	89 c7                	mov    %eax,%edi
  801178:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80117b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80117d:	85 ff                	test   %edi,%edi
  80117f:	79 1d                	jns    80119e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801181:	83 ec 08             	sub    $0x8,%esp
  801184:	53                   	push   %ebx
  801185:	6a 00                	push   $0x0
  801187:	e8 ee fa ff ff       	call   800c7a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80118c:	83 c4 08             	add    $0x8,%esp
  80118f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801192:	6a 00                	push   $0x0
  801194:	e8 e1 fa ff ff       	call   800c7a <sys_page_unmap>
	return r;
  801199:	83 c4 10             	add    $0x10,%esp
  80119c:	89 f8                	mov    %edi,%eax
}
  80119e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a1:	5b                   	pop    %ebx
  8011a2:	5e                   	pop    %esi
  8011a3:	5f                   	pop    %edi
  8011a4:	5d                   	pop    %ebp
  8011a5:	c3                   	ret    

008011a6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	53                   	push   %ebx
  8011aa:	83 ec 14             	sub    $0x14,%esp
  8011ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b3:	50                   	push   %eax
  8011b4:	53                   	push   %ebx
  8011b5:	e8 86 fd ff ff       	call   800f40 <fd_lookup>
  8011ba:	83 c4 08             	add    $0x8,%esp
  8011bd:	89 c2                	mov    %eax,%edx
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	78 6d                	js     801230 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c3:	83 ec 08             	sub    $0x8,%esp
  8011c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c9:	50                   	push   %eax
  8011ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cd:	ff 30                	pushl  (%eax)
  8011cf:	e8 c2 fd ff ff       	call   800f96 <dev_lookup>
  8011d4:	83 c4 10             	add    $0x10,%esp
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	78 4c                	js     801227 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011db:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011de:	8b 42 08             	mov    0x8(%edx),%eax
  8011e1:	83 e0 03             	and    $0x3,%eax
  8011e4:	83 f8 01             	cmp    $0x1,%eax
  8011e7:	75 21                	jne    80120a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e9:	a1 08 40 80 00       	mov    0x804008,%eax
  8011ee:	8b 40 48             	mov    0x48(%eax),%eax
  8011f1:	83 ec 04             	sub    $0x4,%esp
  8011f4:	53                   	push   %ebx
  8011f5:	50                   	push   %eax
  8011f6:	68 2d 2e 80 00       	push   $0x802e2d
  8011fb:	e8 6d f0 ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  801200:	83 c4 10             	add    $0x10,%esp
  801203:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801208:	eb 26                	jmp    801230 <read+0x8a>
	}
	if (!dev->dev_read)
  80120a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80120d:	8b 40 08             	mov    0x8(%eax),%eax
  801210:	85 c0                	test   %eax,%eax
  801212:	74 17                	je     80122b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801214:	83 ec 04             	sub    $0x4,%esp
  801217:	ff 75 10             	pushl  0x10(%ebp)
  80121a:	ff 75 0c             	pushl  0xc(%ebp)
  80121d:	52                   	push   %edx
  80121e:	ff d0                	call   *%eax
  801220:	89 c2                	mov    %eax,%edx
  801222:	83 c4 10             	add    $0x10,%esp
  801225:	eb 09                	jmp    801230 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801227:	89 c2                	mov    %eax,%edx
  801229:	eb 05                	jmp    801230 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80122b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801230:	89 d0                	mov    %edx,%eax
  801232:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801235:	c9                   	leave  
  801236:	c3                   	ret    

00801237 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	57                   	push   %edi
  80123b:	56                   	push   %esi
  80123c:	53                   	push   %ebx
  80123d:	83 ec 0c             	sub    $0xc,%esp
  801240:	8b 7d 08             	mov    0x8(%ebp),%edi
  801243:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801246:	bb 00 00 00 00       	mov    $0x0,%ebx
  80124b:	eb 21                	jmp    80126e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80124d:	83 ec 04             	sub    $0x4,%esp
  801250:	89 f0                	mov    %esi,%eax
  801252:	29 d8                	sub    %ebx,%eax
  801254:	50                   	push   %eax
  801255:	89 d8                	mov    %ebx,%eax
  801257:	03 45 0c             	add    0xc(%ebp),%eax
  80125a:	50                   	push   %eax
  80125b:	57                   	push   %edi
  80125c:	e8 45 ff ff ff       	call   8011a6 <read>
		if (m < 0)
  801261:	83 c4 10             	add    $0x10,%esp
  801264:	85 c0                	test   %eax,%eax
  801266:	78 10                	js     801278 <readn+0x41>
			return m;
		if (m == 0)
  801268:	85 c0                	test   %eax,%eax
  80126a:	74 0a                	je     801276 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80126c:	01 c3                	add    %eax,%ebx
  80126e:	39 f3                	cmp    %esi,%ebx
  801270:	72 db                	jb     80124d <readn+0x16>
  801272:	89 d8                	mov    %ebx,%eax
  801274:	eb 02                	jmp    801278 <readn+0x41>
  801276:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801278:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80127b:	5b                   	pop    %ebx
  80127c:	5e                   	pop    %esi
  80127d:	5f                   	pop    %edi
  80127e:	5d                   	pop    %ebp
  80127f:	c3                   	ret    

00801280 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	53                   	push   %ebx
  801284:	83 ec 14             	sub    $0x14,%esp
  801287:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80128a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80128d:	50                   	push   %eax
  80128e:	53                   	push   %ebx
  80128f:	e8 ac fc ff ff       	call   800f40 <fd_lookup>
  801294:	83 c4 08             	add    $0x8,%esp
  801297:	89 c2                	mov    %eax,%edx
  801299:	85 c0                	test   %eax,%eax
  80129b:	78 68                	js     801305 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80129d:	83 ec 08             	sub    $0x8,%esp
  8012a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a3:	50                   	push   %eax
  8012a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a7:	ff 30                	pushl  (%eax)
  8012a9:	e8 e8 fc ff ff       	call   800f96 <dev_lookup>
  8012ae:	83 c4 10             	add    $0x10,%esp
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	78 47                	js     8012fc <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012bc:	75 21                	jne    8012df <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012be:	a1 08 40 80 00       	mov    0x804008,%eax
  8012c3:	8b 40 48             	mov    0x48(%eax),%eax
  8012c6:	83 ec 04             	sub    $0x4,%esp
  8012c9:	53                   	push   %ebx
  8012ca:	50                   	push   %eax
  8012cb:	68 49 2e 80 00       	push   $0x802e49
  8012d0:	e8 98 ef ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  8012d5:	83 c4 10             	add    $0x10,%esp
  8012d8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012dd:	eb 26                	jmp    801305 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012e2:	8b 52 0c             	mov    0xc(%edx),%edx
  8012e5:	85 d2                	test   %edx,%edx
  8012e7:	74 17                	je     801300 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012e9:	83 ec 04             	sub    $0x4,%esp
  8012ec:	ff 75 10             	pushl  0x10(%ebp)
  8012ef:	ff 75 0c             	pushl  0xc(%ebp)
  8012f2:	50                   	push   %eax
  8012f3:	ff d2                	call   *%edx
  8012f5:	89 c2                	mov    %eax,%edx
  8012f7:	83 c4 10             	add    $0x10,%esp
  8012fa:	eb 09                	jmp    801305 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012fc:	89 c2                	mov    %eax,%edx
  8012fe:	eb 05                	jmp    801305 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801300:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801305:	89 d0                	mov    %edx,%eax
  801307:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80130a:	c9                   	leave  
  80130b:	c3                   	ret    

0080130c <seek>:

int
seek(int fdnum, off_t offset)
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801312:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801315:	50                   	push   %eax
  801316:	ff 75 08             	pushl  0x8(%ebp)
  801319:	e8 22 fc ff ff       	call   800f40 <fd_lookup>
  80131e:	83 c4 08             	add    $0x8,%esp
  801321:	85 c0                	test   %eax,%eax
  801323:	78 0e                	js     801333 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801325:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801328:	8b 55 0c             	mov    0xc(%ebp),%edx
  80132b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80132e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801333:	c9                   	leave  
  801334:	c3                   	ret    

00801335 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	53                   	push   %ebx
  801339:	83 ec 14             	sub    $0x14,%esp
  80133c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80133f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801342:	50                   	push   %eax
  801343:	53                   	push   %ebx
  801344:	e8 f7 fb ff ff       	call   800f40 <fd_lookup>
  801349:	83 c4 08             	add    $0x8,%esp
  80134c:	89 c2                	mov    %eax,%edx
  80134e:	85 c0                	test   %eax,%eax
  801350:	78 65                	js     8013b7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801352:	83 ec 08             	sub    $0x8,%esp
  801355:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801358:	50                   	push   %eax
  801359:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135c:	ff 30                	pushl  (%eax)
  80135e:	e8 33 fc ff ff       	call   800f96 <dev_lookup>
  801363:	83 c4 10             	add    $0x10,%esp
  801366:	85 c0                	test   %eax,%eax
  801368:	78 44                	js     8013ae <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80136a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801371:	75 21                	jne    801394 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801373:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801378:	8b 40 48             	mov    0x48(%eax),%eax
  80137b:	83 ec 04             	sub    $0x4,%esp
  80137e:	53                   	push   %ebx
  80137f:	50                   	push   %eax
  801380:	68 0c 2e 80 00       	push   $0x802e0c
  801385:	e8 e3 ee ff ff       	call   80026d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801392:	eb 23                	jmp    8013b7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801394:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801397:	8b 52 18             	mov    0x18(%edx),%edx
  80139a:	85 d2                	test   %edx,%edx
  80139c:	74 14                	je     8013b2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80139e:	83 ec 08             	sub    $0x8,%esp
  8013a1:	ff 75 0c             	pushl  0xc(%ebp)
  8013a4:	50                   	push   %eax
  8013a5:	ff d2                	call   *%edx
  8013a7:	89 c2                	mov    %eax,%edx
  8013a9:	83 c4 10             	add    $0x10,%esp
  8013ac:	eb 09                	jmp    8013b7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ae:	89 c2                	mov    %eax,%edx
  8013b0:	eb 05                	jmp    8013b7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013b2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013b7:	89 d0                	mov    %edx,%eax
  8013b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013bc:	c9                   	leave  
  8013bd:	c3                   	ret    

008013be <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
  8013c1:	53                   	push   %ebx
  8013c2:	83 ec 14             	sub    $0x14,%esp
  8013c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013cb:	50                   	push   %eax
  8013cc:	ff 75 08             	pushl  0x8(%ebp)
  8013cf:	e8 6c fb ff ff       	call   800f40 <fd_lookup>
  8013d4:	83 c4 08             	add    $0x8,%esp
  8013d7:	89 c2                	mov    %eax,%edx
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	78 58                	js     801435 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013dd:	83 ec 08             	sub    $0x8,%esp
  8013e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e3:	50                   	push   %eax
  8013e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e7:	ff 30                	pushl  (%eax)
  8013e9:	e8 a8 fb ff ff       	call   800f96 <dev_lookup>
  8013ee:	83 c4 10             	add    $0x10,%esp
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	78 37                	js     80142c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013fc:	74 32                	je     801430 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013fe:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801401:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801408:	00 00 00 
	stat->st_isdir = 0;
  80140b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801412:	00 00 00 
	stat->st_dev = dev;
  801415:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80141b:	83 ec 08             	sub    $0x8,%esp
  80141e:	53                   	push   %ebx
  80141f:	ff 75 f0             	pushl  -0x10(%ebp)
  801422:	ff 50 14             	call   *0x14(%eax)
  801425:	89 c2                	mov    %eax,%edx
  801427:	83 c4 10             	add    $0x10,%esp
  80142a:	eb 09                	jmp    801435 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142c:	89 c2                	mov    %eax,%edx
  80142e:	eb 05                	jmp    801435 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801430:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801435:	89 d0                	mov    %edx,%eax
  801437:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80143a:	c9                   	leave  
  80143b:	c3                   	ret    

0080143c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	56                   	push   %esi
  801440:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801441:	83 ec 08             	sub    $0x8,%esp
  801444:	6a 00                	push   $0x0
  801446:	ff 75 08             	pushl  0x8(%ebp)
  801449:	e8 0c 02 00 00       	call   80165a <open>
  80144e:	89 c3                	mov    %eax,%ebx
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	85 c0                	test   %eax,%eax
  801455:	78 1b                	js     801472 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801457:	83 ec 08             	sub    $0x8,%esp
  80145a:	ff 75 0c             	pushl  0xc(%ebp)
  80145d:	50                   	push   %eax
  80145e:	e8 5b ff ff ff       	call   8013be <fstat>
  801463:	89 c6                	mov    %eax,%esi
	close(fd);
  801465:	89 1c 24             	mov    %ebx,(%esp)
  801468:	e8 fd fb ff ff       	call   80106a <close>
	return r;
  80146d:	83 c4 10             	add    $0x10,%esp
  801470:	89 f0                	mov    %esi,%eax
}
  801472:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801475:	5b                   	pop    %ebx
  801476:	5e                   	pop    %esi
  801477:	5d                   	pop    %ebp
  801478:	c3                   	ret    

00801479 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801479:	55                   	push   %ebp
  80147a:	89 e5                	mov    %esp,%ebp
  80147c:	56                   	push   %esi
  80147d:	53                   	push   %ebx
  80147e:	89 c6                	mov    %eax,%esi
  801480:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801482:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801489:	75 12                	jne    80149d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80148b:	83 ec 0c             	sub    $0xc,%esp
  80148e:	6a 01                	push   $0x1
  801490:	e8 18 12 00 00       	call   8026ad <ipc_find_env>
  801495:	a3 00 40 80 00       	mov    %eax,0x804000
  80149a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80149d:	6a 07                	push   $0x7
  80149f:	68 00 50 80 00       	push   $0x805000
  8014a4:	56                   	push   %esi
  8014a5:	ff 35 00 40 80 00    	pushl  0x804000
  8014ab:	e8 a9 11 00 00       	call   802659 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014b0:	83 c4 0c             	add    $0xc,%esp
  8014b3:	6a 00                	push   $0x0
  8014b5:	53                   	push   %ebx
  8014b6:	6a 00                	push   $0x0
  8014b8:	e8 33 11 00 00       	call   8025f0 <ipc_recv>
}
  8014bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014c0:	5b                   	pop    %ebx
  8014c1:	5e                   	pop    %esi
  8014c2:	5d                   	pop    %ebp
  8014c3:	c3                   	ret    

008014c4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014c4:	55                   	push   %ebp
  8014c5:	89 e5                	mov    %esp,%ebp
  8014c7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8014cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e2:	b8 02 00 00 00       	mov    $0x2,%eax
  8014e7:	e8 8d ff ff ff       	call   801479 <fsipc>
}
  8014ec:	c9                   	leave  
  8014ed:	c3                   	ret    

008014ee <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014fa:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801504:	b8 06 00 00 00       	mov    $0x6,%eax
  801509:	e8 6b ff ff ff       	call   801479 <fsipc>
}
  80150e:	c9                   	leave  
  80150f:	c3                   	ret    

00801510 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	53                   	push   %ebx
  801514:	83 ec 04             	sub    $0x4,%esp
  801517:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80151a:	8b 45 08             	mov    0x8(%ebp),%eax
  80151d:	8b 40 0c             	mov    0xc(%eax),%eax
  801520:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801525:	ba 00 00 00 00       	mov    $0x0,%edx
  80152a:	b8 05 00 00 00       	mov    $0x5,%eax
  80152f:	e8 45 ff ff ff       	call   801479 <fsipc>
  801534:	85 c0                	test   %eax,%eax
  801536:	78 2c                	js     801564 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801538:	83 ec 08             	sub    $0x8,%esp
  80153b:	68 00 50 80 00       	push   $0x805000
  801540:	53                   	push   %ebx
  801541:	e8 ac f2 ff ff       	call   8007f2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801546:	a1 80 50 80 00       	mov    0x805080,%eax
  80154b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801551:	a1 84 50 80 00       	mov    0x805084,%eax
  801556:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80155c:	83 c4 10             	add    $0x10,%esp
  80155f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801564:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801567:	c9                   	leave  
  801568:	c3                   	ret    

00801569 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801569:	55                   	push   %ebp
  80156a:	89 e5                	mov    %esp,%ebp
  80156c:	53                   	push   %ebx
  80156d:	83 ec 08             	sub    $0x8,%esp
  801570:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801573:	8b 55 08             	mov    0x8(%ebp),%edx
  801576:	8b 52 0c             	mov    0xc(%edx),%edx
  801579:	89 15 00 50 80 00    	mov    %edx,0x805000
  80157f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801584:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801589:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  80158c:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801592:	53                   	push   %ebx
  801593:	ff 75 0c             	pushl  0xc(%ebp)
  801596:	68 08 50 80 00       	push   $0x805008
  80159b:	e8 e4 f3 ff ff       	call   800984 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  8015a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a5:	b8 04 00 00 00       	mov    $0x4,%eax
  8015aa:	e8 ca fe ff ff       	call   801479 <fsipc>
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	78 1d                	js     8015d3 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  8015b6:	39 d8                	cmp    %ebx,%eax
  8015b8:	76 19                	jbe    8015d3 <devfile_write+0x6a>
  8015ba:	68 7c 2e 80 00       	push   $0x802e7c
  8015bf:	68 88 2e 80 00       	push   $0x802e88
  8015c4:	68 a5 00 00 00       	push   $0xa5
  8015c9:	68 9d 2e 80 00       	push   $0x802e9d
  8015ce:	e8 c1 eb ff ff       	call   800194 <_panic>
	return r;
}
  8015d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d6:	c9                   	leave  
  8015d7:	c3                   	ret    

008015d8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	56                   	push   %esi
  8015dc:	53                   	push   %ebx
  8015dd:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8015e6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015eb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f6:	b8 03 00 00 00       	mov    $0x3,%eax
  8015fb:	e8 79 fe ff ff       	call   801479 <fsipc>
  801600:	89 c3                	mov    %eax,%ebx
  801602:	85 c0                	test   %eax,%eax
  801604:	78 4b                	js     801651 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801606:	39 c6                	cmp    %eax,%esi
  801608:	73 16                	jae    801620 <devfile_read+0x48>
  80160a:	68 a8 2e 80 00       	push   $0x802ea8
  80160f:	68 88 2e 80 00       	push   $0x802e88
  801614:	6a 7c                	push   $0x7c
  801616:	68 9d 2e 80 00       	push   $0x802e9d
  80161b:	e8 74 eb ff ff       	call   800194 <_panic>
	assert(r <= PGSIZE);
  801620:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801625:	7e 16                	jle    80163d <devfile_read+0x65>
  801627:	68 af 2e 80 00       	push   $0x802eaf
  80162c:	68 88 2e 80 00       	push   $0x802e88
  801631:	6a 7d                	push   $0x7d
  801633:	68 9d 2e 80 00       	push   $0x802e9d
  801638:	e8 57 eb ff ff       	call   800194 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80163d:	83 ec 04             	sub    $0x4,%esp
  801640:	50                   	push   %eax
  801641:	68 00 50 80 00       	push   $0x805000
  801646:	ff 75 0c             	pushl  0xc(%ebp)
  801649:	e8 36 f3 ff ff       	call   800984 <memmove>
	return r;
  80164e:	83 c4 10             	add    $0x10,%esp
}
  801651:	89 d8                	mov    %ebx,%eax
  801653:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801656:	5b                   	pop    %ebx
  801657:	5e                   	pop    %esi
  801658:	5d                   	pop    %ebp
  801659:	c3                   	ret    

0080165a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	53                   	push   %ebx
  80165e:	83 ec 20             	sub    $0x20,%esp
  801661:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801664:	53                   	push   %ebx
  801665:	e8 4f f1 ff ff       	call   8007b9 <strlen>
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801672:	7f 67                	jg     8016db <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801674:	83 ec 0c             	sub    $0xc,%esp
  801677:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167a:	50                   	push   %eax
  80167b:	e8 71 f8 ff ff       	call   800ef1 <fd_alloc>
  801680:	83 c4 10             	add    $0x10,%esp
		return r;
  801683:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801685:	85 c0                	test   %eax,%eax
  801687:	78 57                	js     8016e0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801689:	83 ec 08             	sub    $0x8,%esp
  80168c:	53                   	push   %ebx
  80168d:	68 00 50 80 00       	push   $0x805000
  801692:	e8 5b f1 ff ff       	call   8007f2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801697:	8b 45 0c             	mov    0xc(%ebp),%eax
  80169a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80169f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8016a7:	e8 cd fd ff ff       	call   801479 <fsipc>
  8016ac:	89 c3                	mov    %eax,%ebx
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	79 14                	jns    8016c9 <open+0x6f>
		fd_close(fd, 0);
  8016b5:	83 ec 08             	sub    $0x8,%esp
  8016b8:	6a 00                	push   $0x0
  8016ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8016bd:	e8 27 f9 ff ff       	call   800fe9 <fd_close>
		return r;
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	89 da                	mov    %ebx,%edx
  8016c7:	eb 17                	jmp    8016e0 <open+0x86>
	}

	return fd2num(fd);
  8016c9:	83 ec 0c             	sub    $0xc,%esp
  8016cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8016cf:	e8 f6 f7 ff ff       	call   800eca <fd2num>
  8016d4:	89 c2                	mov    %eax,%edx
  8016d6:	83 c4 10             	add    $0x10,%esp
  8016d9:	eb 05                	jmp    8016e0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016db:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016e0:	89 d0                	mov    %edx,%eax
  8016e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e5:	c9                   	leave  
  8016e6:	c3                   	ret    

008016e7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f2:	b8 08 00 00 00       	mov    $0x8,%eax
  8016f7:	e8 7d fd ff ff       	call   801479 <fsipc>
}
  8016fc:	c9                   	leave  
  8016fd:	c3                   	ret    

008016fe <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	57                   	push   %edi
  801702:	56                   	push   %esi
  801703:	53                   	push   %ebx
  801704:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80170a:	6a 00                	push   $0x0
  80170c:	ff 75 08             	pushl  0x8(%ebp)
  80170f:	e8 46 ff ff ff       	call   80165a <open>
  801714:	89 c7                	mov    %eax,%edi
  801716:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80171c:	83 c4 10             	add    $0x10,%esp
  80171f:	85 c0                	test   %eax,%eax
  801721:	0f 88 a6 04 00 00    	js     801bcd <spawn+0x4cf>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801727:	83 ec 04             	sub    $0x4,%esp
  80172a:	68 00 02 00 00       	push   $0x200
  80172f:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801735:	50                   	push   %eax
  801736:	57                   	push   %edi
  801737:	e8 fb fa ff ff       	call   801237 <readn>
  80173c:	83 c4 10             	add    $0x10,%esp
  80173f:	3d 00 02 00 00       	cmp    $0x200,%eax
  801744:	75 0c                	jne    801752 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801746:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80174d:	45 4c 46 
  801750:	74 33                	je     801785 <spawn+0x87>
		close(fd);
  801752:	83 ec 0c             	sub    $0xc,%esp
  801755:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80175b:	e8 0a f9 ff ff       	call   80106a <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801760:	83 c4 0c             	add    $0xc,%esp
  801763:	68 7f 45 4c 46       	push   $0x464c457f
  801768:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80176e:	68 bb 2e 80 00       	push   $0x802ebb
  801773:	e8 f5 ea ff ff       	call   80026d <cprintf>
		return -E_NOT_EXEC;
  801778:	83 c4 10             	add    $0x10,%esp
  80177b:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801780:	e9 a8 04 00 00       	jmp    801c2d <spawn+0x52f>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801785:	b8 07 00 00 00       	mov    $0x7,%eax
  80178a:	cd 30                	int    $0x30
  80178c:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801792:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801798:	85 c0                	test   %eax,%eax
  80179a:	0f 88 35 04 00 00    	js     801bd5 <spawn+0x4d7>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8017a0:	89 c6                	mov    %eax,%esi
  8017a2:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8017a8:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8017ab:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8017b1:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8017b7:	b9 11 00 00 00       	mov    $0x11,%ecx
  8017bc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8017be:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8017c4:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8017ca:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8017cf:	be 00 00 00 00       	mov    $0x0,%esi
  8017d4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8017d7:	eb 13                	jmp    8017ec <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8017d9:	83 ec 0c             	sub    $0xc,%esp
  8017dc:	50                   	push   %eax
  8017dd:	e8 d7 ef ff ff       	call   8007b9 <strlen>
  8017e2:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8017e6:	83 c3 01             	add    $0x1,%ebx
  8017e9:	83 c4 10             	add    $0x10,%esp
  8017ec:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8017f3:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	75 df                	jne    8017d9 <spawn+0xdb>
  8017fa:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801800:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801806:	bf 00 10 40 00       	mov    $0x401000,%edi
  80180b:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80180d:	89 fa                	mov    %edi,%edx
  80180f:	83 e2 fc             	and    $0xfffffffc,%edx
  801812:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801819:	29 c2                	sub    %eax,%edx
  80181b:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801821:	8d 42 f8             	lea    -0x8(%edx),%eax
  801824:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801829:	0f 86 b6 03 00 00    	jbe    801be5 <spawn+0x4e7>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80182f:	83 ec 04             	sub    $0x4,%esp
  801832:	6a 07                	push   $0x7
  801834:	68 00 00 40 00       	push   $0x400000
  801839:	6a 00                	push   $0x0
  80183b:	e8 b5 f3 ff ff       	call   800bf5 <sys_page_alloc>
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	85 c0                	test   %eax,%eax
  801845:	0f 88 a1 03 00 00    	js     801bec <spawn+0x4ee>
  80184b:	be 00 00 00 00       	mov    $0x0,%esi
  801850:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801856:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801859:	eb 30                	jmp    80188b <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80185b:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801861:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801867:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  80186a:	83 ec 08             	sub    $0x8,%esp
  80186d:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801870:	57                   	push   %edi
  801871:	e8 7c ef ff ff       	call   8007f2 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801876:	83 c4 04             	add    $0x4,%esp
  801879:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80187c:	e8 38 ef ff ff       	call   8007b9 <strlen>
  801881:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801885:	83 c6 01             	add    $0x1,%esi
  801888:	83 c4 10             	add    $0x10,%esp
  80188b:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801891:	7f c8                	jg     80185b <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801893:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801899:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  80189f:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8018a6:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8018ac:	74 19                	je     8018c7 <spawn+0x1c9>
  8018ae:	68 40 2f 80 00       	push   $0x802f40
  8018b3:	68 88 2e 80 00       	push   $0x802e88
  8018b8:	68 f1 00 00 00       	push   $0xf1
  8018bd:	68 d5 2e 80 00       	push   $0x802ed5
  8018c2:	e8 cd e8 ff ff       	call   800194 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8018c7:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  8018cd:	89 f8                	mov    %edi,%eax
  8018cf:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8018d4:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  8018d7:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8018dd:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8018e0:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  8018e6:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8018ec:	83 ec 0c             	sub    $0xc,%esp
  8018ef:	6a 07                	push   $0x7
  8018f1:	68 00 d0 bf ee       	push   $0xeebfd000
  8018f6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8018fc:	68 00 00 40 00       	push   $0x400000
  801901:	6a 00                	push   $0x0
  801903:	e8 30 f3 ff ff       	call   800c38 <sys_page_map>
  801908:	89 c3                	mov    %eax,%ebx
  80190a:	83 c4 20             	add    $0x20,%esp
  80190d:	85 c0                	test   %eax,%eax
  80190f:	0f 88 06 03 00 00    	js     801c1b <spawn+0x51d>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801915:	83 ec 08             	sub    $0x8,%esp
  801918:	68 00 00 40 00       	push   $0x400000
  80191d:	6a 00                	push   $0x0
  80191f:	e8 56 f3 ff ff       	call   800c7a <sys_page_unmap>
  801924:	89 c3                	mov    %eax,%ebx
  801926:	83 c4 10             	add    $0x10,%esp
  801929:	85 c0                	test   %eax,%eax
  80192b:	0f 88 ea 02 00 00    	js     801c1b <spawn+0x51d>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801931:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801937:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  80193e:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801944:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  80194b:	00 00 00 
  80194e:	e9 88 01 00 00       	jmp    801adb <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801953:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801959:	83 38 01             	cmpl   $0x1,(%eax)
  80195c:	0f 85 6b 01 00 00    	jne    801acd <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801962:	89 c7                	mov    %eax,%edi
  801964:	8b 40 18             	mov    0x18(%eax),%eax
  801967:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80196d:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801970:	83 f8 01             	cmp    $0x1,%eax
  801973:	19 c0                	sbb    %eax,%eax
  801975:	83 e0 fe             	and    $0xfffffffe,%eax
  801978:	83 c0 07             	add    $0x7,%eax
  80197b:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801981:	89 f8                	mov    %edi,%eax
  801983:	8b 7f 04             	mov    0x4(%edi),%edi
  801986:	89 f9                	mov    %edi,%ecx
  801988:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  80198e:	8b 78 10             	mov    0x10(%eax),%edi
  801991:	8b 50 14             	mov    0x14(%eax),%edx
  801994:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  80199a:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80199d:	89 f0                	mov    %esi,%eax
  80199f:	25 ff 0f 00 00       	and    $0xfff,%eax
  8019a4:	74 14                	je     8019ba <spawn+0x2bc>
		va -= i;
  8019a6:	29 c6                	sub    %eax,%esi
		memsz += i;
  8019a8:	01 c2                	add    %eax,%edx
  8019aa:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  8019b0:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8019b2:	29 c1                	sub    %eax,%ecx
  8019b4:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8019ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019bf:	e9 f7 00 00 00       	jmp    801abb <spawn+0x3bd>
		if (i >= filesz) {
  8019c4:	39 df                	cmp    %ebx,%edi
  8019c6:	77 27                	ja     8019ef <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8019c8:	83 ec 04             	sub    $0x4,%esp
  8019cb:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8019d1:	56                   	push   %esi
  8019d2:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8019d8:	e8 18 f2 ff ff       	call   800bf5 <sys_page_alloc>
  8019dd:	83 c4 10             	add    $0x10,%esp
  8019e0:	85 c0                	test   %eax,%eax
  8019e2:	0f 89 c7 00 00 00    	jns    801aaf <spawn+0x3b1>
  8019e8:	89 c3                	mov    %eax,%ebx
  8019ea:	e9 0b 02 00 00       	jmp    801bfa <spawn+0x4fc>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019ef:	83 ec 04             	sub    $0x4,%esp
  8019f2:	6a 07                	push   $0x7
  8019f4:	68 00 00 40 00       	push   $0x400000
  8019f9:	6a 00                	push   $0x0
  8019fb:	e8 f5 f1 ff ff       	call   800bf5 <sys_page_alloc>
  801a00:	83 c4 10             	add    $0x10,%esp
  801a03:	85 c0                	test   %eax,%eax
  801a05:	0f 88 e5 01 00 00    	js     801bf0 <spawn+0x4f2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801a0b:	83 ec 08             	sub    $0x8,%esp
  801a0e:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801a14:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801a1a:	50                   	push   %eax
  801a1b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a21:	e8 e6 f8 ff ff       	call   80130c <seek>
  801a26:	83 c4 10             	add    $0x10,%esp
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	0f 88 c3 01 00 00    	js     801bf4 <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801a31:	83 ec 04             	sub    $0x4,%esp
  801a34:	89 f8                	mov    %edi,%eax
  801a36:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801a3c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a41:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801a46:	0f 47 c1             	cmova  %ecx,%eax
  801a49:	50                   	push   %eax
  801a4a:	68 00 00 40 00       	push   $0x400000
  801a4f:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a55:	e8 dd f7 ff ff       	call   801237 <readn>
  801a5a:	83 c4 10             	add    $0x10,%esp
  801a5d:	85 c0                	test   %eax,%eax
  801a5f:	0f 88 93 01 00 00    	js     801bf8 <spawn+0x4fa>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801a65:	83 ec 0c             	sub    $0xc,%esp
  801a68:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801a6e:	56                   	push   %esi
  801a6f:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801a75:	68 00 00 40 00       	push   $0x400000
  801a7a:	6a 00                	push   $0x0
  801a7c:	e8 b7 f1 ff ff       	call   800c38 <sys_page_map>
  801a81:	83 c4 20             	add    $0x20,%esp
  801a84:	85 c0                	test   %eax,%eax
  801a86:	79 15                	jns    801a9d <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801a88:	50                   	push   %eax
  801a89:	68 e1 2e 80 00       	push   $0x802ee1
  801a8e:	68 24 01 00 00       	push   $0x124
  801a93:	68 d5 2e 80 00       	push   $0x802ed5
  801a98:	e8 f7 e6 ff ff       	call   800194 <_panic>
			sys_page_unmap(0, UTEMP);
  801a9d:	83 ec 08             	sub    $0x8,%esp
  801aa0:	68 00 00 40 00       	push   $0x400000
  801aa5:	6a 00                	push   $0x0
  801aa7:	e8 ce f1 ff ff       	call   800c7a <sys_page_unmap>
  801aac:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801aaf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ab5:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801abb:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801ac1:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801ac7:	0f 87 f7 fe ff ff    	ja     8019c4 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801acd:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801ad4:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801adb:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801ae2:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801ae8:	0f 8c 65 fe ff ff    	jl     801953 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801aee:	83 ec 0c             	sub    $0xc,%esp
  801af1:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801af7:	e8 6e f5 ff ff       	call   80106a <close>
  801afc:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	// Loop through all the pte's of parent's pgdir in user space
        uint32_t pn;
        for (pn = UTEXT/PGSIZE; pn < UTOP/PGSIZE; pn++) {
  801aff:	bb 00 08 00 00       	mov    $0x800,%ebx
  801b04:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		
		if (uvpd[pn/NPTENTRIES] & PTE_P) {
  801b0a:	89 d8                	mov    %ebx,%eax
  801b0c:	c1 e8 0a             	shr    $0xa,%eax
  801b0f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801b16:	a8 01                	test   $0x1,%al
  801b18:	74 4b                	je     801b65 <spawn+0x467>
		
			pte_t pte = uvpt[pn];
  801b1a:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax

			
			if ((pte & PTE_P) && (pte & PTE_SHARE)) {
  801b21:	89 c2                	mov    %eax,%edx
  801b23:	81 e2 01 04 00 00    	and    $0x401,%edx
  801b29:	81 fa 01 04 00 00    	cmp    $0x401,%edx
  801b2f:	75 34                	jne    801b65 <spawn+0x467>
  801b31:	89 da                	mov    %ebx,%edx
  801b33:	c1 e2 0c             	shl    $0xc,%edx
				void *va = (void *) (pn * PGSIZE);
				uint32_t perm = pte & PTE_SYSCALL;
				int r;
				if ((r = sys_page_map(0, va, child, va, perm)) < 0)
  801b36:	83 ec 0c             	sub    $0xc,%esp
  801b39:	25 07 0e 00 00       	and    $0xe07,%eax
  801b3e:	50                   	push   %eax
  801b3f:	52                   	push   %edx
  801b40:	56                   	push   %esi
  801b41:	52                   	push   %edx
  801b42:	6a 00                	push   $0x0
  801b44:	e8 ef f0 ff ff       	call   800c38 <sys_page_map>
  801b49:	83 c4 20             	add    $0x20,%esp
  801b4c:	85 c0                	test   %eax,%eax
  801b4e:	79 15                	jns    801b65 <spawn+0x467>
					panic("sys_page_map: %e", r);
  801b50:	50                   	push   %eax
  801b51:	68 fe 2e 80 00       	push   $0x802efe
  801b56:	68 3e 01 00 00       	push   $0x13e
  801b5b:	68 d5 2e 80 00       	push   $0x802ed5
  801b60:	e8 2f e6 ff ff       	call   800194 <_panic>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	// Loop through all the pte's of parent's pgdir in user space
        uint32_t pn;
        for (pn = UTEXT/PGSIZE; pn < UTOP/PGSIZE; pn++) {
  801b65:	83 c3 01             	add    $0x1,%ebx
  801b68:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  801b6e:	75 9a                	jne    801b0a <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801b70:	83 ec 08             	sub    $0x8,%esp
  801b73:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801b79:	50                   	push   %eax
  801b7a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b80:	e8 79 f1 ff ff       	call   800cfe <sys_env_set_trapframe>
  801b85:	83 c4 10             	add    $0x10,%esp
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	79 15                	jns    801ba1 <spawn+0x4a3>
		panic("sys_env_set_trapframe: %e", r);
  801b8c:	50                   	push   %eax
  801b8d:	68 0f 2f 80 00       	push   $0x802f0f
  801b92:	68 85 00 00 00       	push   $0x85
  801b97:	68 d5 2e 80 00       	push   $0x802ed5
  801b9c:	e8 f3 e5 ff ff       	call   800194 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801ba1:	83 ec 08             	sub    $0x8,%esp
  801ba4:	6a 02                	push   $0x2
  801ba6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801bac:	e8 0b f1 ff ff       	call   800cbc <sys_env_set_status>
  801bb1:	83 c4 10             	add    $0x10,%esp
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	79 25                	jns    801bdd <spawn+0x4df>
		panic("sys_env_set_status: %e", r);
  801bb8:	50                   	push   %eax
  801bb9:	68 29 2f 80 00       	push   $0x802f29
  801bbe:	68 88 00 00 00       	push   $0x88
  801bc3:	68 d5 2e 80 00       	push   $0x802ed5
  801bc8:	e8 c7 e5 ff ff       	call   800194 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801bcd:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801bd3:	eb 58                	jmp    801c2d <spawn+0x52f>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801bd5:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801bdb:	eb 50                	jmp    801c2d <spawn+0x52f>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801bdd:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801be3:	eb 48                	jmp    801c2d <spawn+0x52f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801be5:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801bea:	eb 41                	jmp    801c2d <spawn+0x52f>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801bec:	89 c3                	mov    %eax,%ebx
  801bee:	eb 3d                	jmp    801c2d <spawn+0x52f>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801bf0:	89 c3                	mov    %eax,%ebx
  801bf2:	eb 06                	jmp    801bfa <spawn+0x4fc>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801bf4:	89 c3                	mov    %eax,%ebx
  801bf6:	eb 02                	jmp    801bfa <spawn+0x4fc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801bf8:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801bfa:	83 ec 0c             	sub    $0xc,%esp
  801bfd:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801c03:	e8 6e ef ff ff       	call   800b76 <sys_env_destroy>
	close(fd);
  801c08:	83 c4 04             	add    $0x4,%esp
  801c0b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c11:	e8 54 f4 ff ff       	call   80106a <close>
	return r;
  801c16:	83 c4 10             	add    $0x10,%esp
  801c19:	eb 12                	jmp    801c2d <spawn+0x52f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801c1b:	83 ec 08             	sub    $0x8,%esp
  801c1e:	68 00 00 40 00       	push   $0x400000
  801c23:	6a 00                	push   $0x0
  801c25:	e8 50 f0 ff ff       	call   800c7a <sys_page_unmap>
  801c2a:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801c2d:	89 d8                	mov    %ebx,%eax
  801c2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c32:	5b                   	pop    %ebx
  801c33:	5e                   	pop    %esi
  801c34:	5f                   	pop    %edi
  801c35:	5d                   	pop    %ebp
  801c36:	c3                   	ret    

00801c37 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801c37:	55                   	push   %ebp
  801c38:	89 e5                	mov    %esp,%ebp
  801c3a:	56                   	push   %esi
  801c3b:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801c3c:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801c3f:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801c44:	eb 03                	jmp    801c49 <spawnl+0x12>
		argc++;
  801c46:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801c49:	83 c2 04             	add    $0x4,%edx
  801c4c:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801c50:	75 f4                	jne    801c46 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801c52:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801c59:	83 e2 f0             	and    $0xfffffff0,%edx
  801c5c:	29 d4                	sub    %edx,%esp
  801c5e:	8d 54 24 03          	lea    0x3(%esp),%edx
  801c62:	c1 ea 02             	shr    $0x2,%edx
  801c65:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801c6c:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801c6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c71:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801c78:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801c7f:	00 
  801c80:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801c82:	b8 00 00 00 00       	mov    $0x0,%eax
  801c87:	eb 0a                	jmp    801c93 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801c89:	83 c0 01             	add    $0x1,%eax
  801c8c:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801c90:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801c93:	39 d0                	cmp    %edx,%eax
  801c95:	75 f2                	jne    801c89 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801c97:	83 ec 08             	sub    $0x8,%esp
  801c9a:	56                   	push   %esi
  801c9b:	ff 75 08             	pushl  0x8(%ebp)
  801c9e:	e8 5b fa ff ff       	call   8016fe <spawn>
}
  801ca3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ca6:	5b                   	pop    %ebx
  801ca7:	5e                   	pop    %esi
  801ca8:	5d                   	pop    %ebp
  801ca9:	c3                   	ret    

00801caa <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801cb0:	68 68 2f 80 00       	push   $0x802f68
  801cb5:	ff 75 0c             	pushl  0xc(%ebp)
  801cb8:	e8 35 eb ff ff       	call   8007f2 <strcpy>
	return 0;
}
  801cbd:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc2:	c9                   	leave  
  801cc3:	c3                   	ret    

00801cc4 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801cc4:	55                   	push   %ebp
  801cc5:	89 e5                	mov    %esp,%ebp
  801cc7:	53                   	push   %ebx
  801cc8:	83 ec 10             	sub    $0x10,%esp
  801ccb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801cce:	53                   	push   %ebx
  801ccf:	e8 12 0a 00 00       	call   8026e6 <pageref>
  801cd4:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801cd7:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801cdc:	83 f8 01             	cmp    $0x1,%eax
  801cdf:	75 10                	jne    801cf1 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801ce1:	83 ec 0c             	sub    $0xc,%esp
  801ce4:	ff 73 0c             	pushl  0xc(%ebx)
  801ce7:	e8 c0 02 00 00       	call   801fac <nsipc_close>
  801cec:	89 c2                	mov    %eax,%edx
  801cee:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801cf1:	89 d0                	mov    %edx,%eax
  801cf3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf6:	c9                   	leave  
  801cf7:	c3                   	ret    

00801cf8 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801cf8:	55                   	push   %ebp
  801cf9:	89 e5                	mov    %esp,%ebp
  801cfb:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801cfe:	6a 00                	push   $0x0
  801d00:	ff 75 10             	pushl  0x10(%ebp)
  801d03:	ff 75 0c             	pushl  0xc(%ebp)
  801d06:	8b 45 08             	mov    0x8(%ebp),%eax
  801d09:	ff 70 0c             	pushl  0xc(%eax)
  801d0c:	e8 78 03 00 00       	call   802089 <nsipc_send>
}
  801d11:	c9                   	leave  
  801d12:	c3                   	ret    

00801d13 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d19:	6a 00                	push   $0x0
  801d1b:	ff 75 10             	pushl  0x10(%ebp)
  801d1e:	ff 75 0c             	pushl  0xc(%ebp)
  801d21:	8b 45 08             	mov    0x8(%ebp),%eax
  801d24:	ff 70 0c             	pushl  0xc(%eax)
  801d27:	e8 f1 02 00 00       	call   80201d <nsipc_recv>
}
  801d2c:	c9                   	leave  
  801d2d:	c3                   	ret    

00801d2e <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d2e:	55                   	push   %ebp
  801d2f:	89 e5                	mov    %esp,%ebp
  801d31:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d34:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d37:	52                   	push   %edx
  801d38:	50                   	push   %eax
  801d39:	e8 02 f2 ff ff       	call   800f40 <fd_lookup>
  801d3e:	83 c4 10             	add    $0x10,%esp
  801d41:	85 c0                	test   %eax,%eax
  801d43:	78 17                	js     801d5c <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d48:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801d4e:	39 08                	cmp    %ecx,(%eax)
  801d50:	75 05                	jne    801d57 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d52:	8b 40 0c             	mov    0xc(%eax),%eax
  801d55:	eb 05                	jmp    801d5c <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d57:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d5c:	c9                   	leave  
  801d5d:	c3                   	ret    

00801d5e <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	56                   	push   %esi
  801d62:	53                   	push   %ebx
  801d63:	83 ec 1c             	sub    $0x1c,%esp
  801d66:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d6b:	50                   	push   %eax
  801d6c:	e8 80 f1 ff ff       	call   800ef1 <fd_alloc>
  801d71:	89 c3                	mov    %eax,%ebx
  801d73:	83 c4 10             	add    $0x10,%esp
  801d76:	85 c0                	test   %eax,%eax
  801d78:	78 1b                	js     801d95 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d7a:	83 ec 04             	sub    $0x4,%esp
  801d7d:	68 07 04 00 00       	push   $0x407
  801d82:	ff 75 f4             	pushl  -0xc(%ebp)
  801d85:	6a 00                	push   $0x0
  801d87:	e8 69 ee ff ff       	call   800bf5 <sys_page_alloc>
  801d8c:	89 c3                	mov    %eax,%ebx
  801d8e:	83 c4 10             	add    $0x10,%esp
  801d91:	85 c0                	test   %eax,%eax
  801d93:	79 10                	jns    801da5 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801d95:	83 ec 0c             	sub    $0xc,%esp
  801d98:	56                   	push   %esi
  801d99:	e8 0e 02 00 00       	call   801fac <nsipc_close>
		return r;
  801d9e:	83 c4 10             	add    $0x10,%esp
  801da1:	89 d8                	mov    %ebx,%eax
  801da3:	eb 24                	jmp    801dc9 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801da5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dae:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801dba:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801dbd:	83 ec 0c             	sub    $0xc,%esp
  801dc0:	50                   	push   %eax
  801dc1:	e8 04 f1 ff ff       	call   800eca <fd2num>
  801dc6:	83 c4 10             	add    $0x10,%esp
}
  801dc9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dcc:	5b                   	pop    %ebx
  801dcd:	5e                   	pop    %esi
  801dce:	5d                   	pop    %ebp
  801dcf:	c3                   	ret    

00801dd0 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dd0:	55                   	push   %ebp
  801dd1:	89 e5                	mov    %esp,%ebp
  801dd3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd9:	e8 50 ff ff ff       	call   801d2e <fd2sockid>
		return r;
  801dde:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801de0:	85 c0                	test   %eax,%eax
  801de2:	78 1f                	js     801e03 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801de4:	83 ec 04             	sub    $0x4,%esp
  801de7:	ff 75 10             	pushl  0x10(%ebp)
  801dea:	ff 75 0c             	pushl  0xc(%ebp)
  801ded:	50                   	push   %eax
  801dee:	e8 12 01 00 00       	call   801f05 <nsipc_accept>
  801df3:	83 c4 10             	add    $0x10,%esp
		return r;
  801df6:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801df8:	85 c0                	test   %eax,%eax
  801dfa:	78 07                	js     801e03 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801dfc:	e8 5d ff ff ff       	call   801d5e <alloc_sockfd>
  801e01:	89 c1                	mov    %eax,%ecx
}
  801e03:	89 c8                	mov    %ecx,%eax
  801e05:	c9                   	leave  
  801e06:	c3                   	ret    

00801e07 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e07:	55                   	push   %ebp
  801e08:	89 e5                	mov    %esp,%ebp
  801e0a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e10:	e8 19 ff ff ff       	call   801d2e <fd2sockid>
  801e15:	85 c0                	test   %eax,%eax
  801e17:	78 12                	js     801e2b <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801e19:	83 ec 04             	sub    $0x4,%esp
  801e1c:	ff 75 10             	pushl  0x10(%ebp)
  801e1f:	ff 75 0c             	pushl  0xc(%ebp)
  801e22:	50                   	push   %eax
  801e23:	e8 2d 01 00 00       	call   801f55 <nsipc_bind>
  801e28:	83 c4 10             	add    $0x10,%esp
}
  801e2b:	c9                   	leave  
  801e2c:	c3                   	ret    

00801e2d <shutdown>:

int
shutdown(int s, int how)
{
  801e2d:	55                   	push   %ebp
  801e2e:	89 e5                	mov    %esp,%ebp
  801e30:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e33:	8b 45 08             	mov    0x8(%ebp),%eax
  801e36:	e8 f3 fe ff ff       	call   801d2e <fd2sockid>
  801e3b:	85 c0                	test   %eax,%eax
  801e3d:	78 0f                	js     801e4e <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801e3f:	83 ec 08             	sub    $0x8,%esp
  801e42:	ff 75 0c             	pushl  0xc(%ebp)
  801e45:	50                   	push   %eax
  801e46:	e8 3f 01 00 00       	call   801f8a <nsipc_shutdown>
  801e4b:	83 c4 10             	add    $0x10,%esp
}
  801e4e:	c9                   	leave  
  801e4f:	c3                   	ret    

00801e50 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e56:	8b 45 08             	mov    0x8(%ebp),%eax
  801e59:	e8 d0 fe ff ff       	call   801d2e <fd2sockid>
  801e5e:	85 c0                	test   %eax,%eax
  801e60:	78 12                	js     801e74 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801e62:	83 ec 04             	sub    $0x4,%esp
  801e65:	ff 75 10             	pushl  0x10(%ebp)
  801e68:	ff 75 0c             	pushl  0xc(%ebp)
  801e6b:	50                   	push   %eax
  801e6c:	e8 55 01 00 00       	call   801fc6 <nsipc_connect>
  801e71:	83 c4 10             	add    $0x10,%esp
}
  801e74:	c9                   	leave  
  801e75:	c3                   	ret    

00801e76 <listen>:

int
listen(int s, int backlog)
{
  801e76:	55                   	push   %ebp
  801e77:	89 e5                	mov    %esp,%ebp
  801e79:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7f:	e8 aa fe ff ff       	call   801d2e <fd2sockid>
  801e84:	85 c0                	test   %eax,%eax
  801e86:	78 0f                	js     801e97 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801e88:	83 ec 08             	sub    $0x8,%esp
  801e8b:	ff 75 0c             	pushl  0xc(%ebp)
  801e8e:	50                   	push   %eax
  801e8f:	e8 67 01 00 00       	call   801ffb <nsipc_listen>
  801e94:	83 c4 10             	add    $0x10,%esp
}
  801e97:	c9                   	leave  
  801e98:	c3                   	ret    

00801e99 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e99:	55                   	push   %ebp
  801e9a:	89 e5                	mov    %esp,%ebp
  801e9c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e9f:	ff 75 10             	pushl  0x10(%ebp)
  801ea2:	ff 75 0c             	pushl  0xc(%ebp)
  801ea5:	ff 75 08             	pushl  0x8(%ebp)
  801ea8:	e8 3a 02 00 00       	call   8020e7 <nsipc_socket>
  801ead:	83 c4 10             	add    $0x10,%esp
  801eb0:	85 c0                	test   %eax,%eax
  801eb2:	78 05                	js     801eb9 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801eb4:	e8 a5 fe ff ff       	call   801d5e <alloc_sockfd>
}
  801eb9:	c9                   	leave  
  801eba:	c3                   	ret    

00801ebb <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ebb:	55                   	push   %ebp
  801ebc:	89 e5                	mov    %esp,%ebp
  801ebe:	53                   	push   %ebx
  801ebf:	83 ec 04             	sub    $0x4,%esp
  801ec2:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ec4:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801ecb:	75 12                	jne    801edf <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ecd:	83 ec 0c             	sub    $0xc,%esp
  801ed0:	6a 02                	push   $0x2
  801ed2:	e8 d6 07 00 00       	call   8026ad <ipc_find_env>
  801ed7:	a3 04 40 80 00       	mov    %eax,0x804004
  801edc:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801edf:	6a 07                	push   $0x7
  801ee1:	68 00 60 80 00       	push   $0x806000
  801ee6:	53                   	push   %ebx
  801ee7:	ff 35 04 40 80 00    	pushl  0x804004
  801eed:	e8 67 07 00 00       	call   802659 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ef2:	83 c4 0c             	add    $0xc,%esp
  801ef5:	6a 00                	push   $0x0
  801ef7:	6a 00                	push   $0x0
  801ef9:	6a 00                	push   $0x0
  801efb:	e8 f0 06 00 00       	call   8025f0 <ipc_recv>
}
  801f00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f03:	c9                   	leave  
  801f04:	c3                   	ret    

00801f05 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f05:	55                   	push   %ebp
  801f06:	89 e5                	mov    %esp,%ebp
  801f08:	56                   	push   %esi
  801f09:	53                   	push   %ebx
  801f0a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f10:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f15:	8b 06                	mov    (%esi),%eax
  801f17:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f1c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f21:	e8 95 ff ff ff       	call   801ebb <nsipc>
  801f26:	89 c3                	mov    %eax,%ebx
  801f28:	85 c0                	test   %eax,%eax
  801f2a:	78 20                	js     801f4c <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f2c:	83 ec 04             	sub    $0x4,%esp
  801f2f:	ff 35 10 60 80 00    	pushl  0x806010
  801f35:	68 00 60 80 00       	push   $0x806000
  801f3a:	ff 75 0c             	pushl  0xc(%ebp)
  801f3d:	e8 42 ea ff ff       	call   800984 <memmove>
		*addrlen = ret->ret_addrlen;
  801f42:	a1 10 60 80 00       	mov    0x806010,%eax
  801f47:	89 06                	mov    %eax,(%esi)
  801f49:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801f4c:	89 d8                	mov    %ebx,%eax
  801f4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f51:	5b                   	pop    %ebx
  801f52:	5e                   	pop    %esi
  801f53:	5d                   	pop    %ebp
  801f54:	c3                   	ret    

00801f55 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	53                   	push   %ebx
  801f59:	83 ec 08             	sub    $0x8,%esp
  801f5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f62:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f67:	53                   	push   %ebx
  801f68:	ff 75 0c             	pushl  0xc(%ebp)
  801f6b:	68 04 60 80 00       	push   $0x806004
  801f70:	e8 0f ea ff ff       	call   800984 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f75:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f7b:	b8 02 00 00 00       	mov    $0x2,%eax
  801f80:	e8 36 ff ff ff       	call   801ebb <nsipc>
}
  801f85:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f88:	c9                   	leave  
  801f89:	c3                   	ret    

00801f8a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f8a:	55                   	push   %ebp
  801f8b:	89 e5                	mov    %esp,%ebp
  801f8d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f90:	8b 45 08             	mov    0x8(%ebp),%eax
  801f93:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801f98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f9b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801fa0:	b8 03 00 00 00       	mov    $0x3,%eax
  801fa5:	e8 11 ff ff ff       	call   801ebb <nsipc>
}
  801faa:	c9                   	leave  
  801fab:	c3                   	ret    

00801fac <nsipc_close>:

int
nsipc_close(int s)
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801fb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb5:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801fba:	b8 04 00 00 00       	mov    $0x4,%eax
  801fbf:	e8 f7 fe ff ff       	call   801ebb <nsipc>
}
  801fc4:	c9                   	leave  
  801fc5:	c3                   	ret    

00801fc6 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801fc6:	55                   	push   %ebp
  801fc7:	89 e5                	mov    %esp,%ebp
  801fc9:	53                   	push   %ebx
  801fca:	83 ec 08             	sub    $0x8,%esp
  801fcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801fd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd3:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801fd8:	53                   	push   %ebx
  801fd9:	ff 75 0c             	pushl  0xc(%ebp)
  801fdc:	68 04 60 80 00       	push   $0x806004
  801fe1:	e8 9e e9 ff ff       	call   800984 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fe6:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801fec:	b8 05 00 00 00       	mov    $0x5,%eax
  801ff1:	e8 c5 fe ff ff       	call   801ebb <nsipc>
}
  801ff6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ff9:	c9                   	leave  
  801ffa:	c3                   	ret    

00801ffb <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ffb:	55                   	push   %ebp
  801ffc:	89 e5                	mov    %esp,%ebp
  801ffe:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802001:	8b 45 08             	mov    0x8(%ebp),%eax
  802004:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  802009:	8b 45 0c             	mov    0xc(%ebp),%eax
  80200c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  802011:	b8 06 00 00 00       	mov    $0x6,%eax
  802016:	e8 a0 fe ff ff       	call   801ebb <nsipc>
}
  80201b:	c9                   	leave  
  80201c:	c3                   	ret    

0080201d <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80201d:	55                   	push   %ebp
  80201e:	89 e5                	mov    %esp,%ebp
  802020:	56                   	push   %esi
  802021:	53                   	push   %ebx
  802022:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802025:	8b 45 08             	mov    0x8(%ebp),%eax
  802028:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80202d:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  802033:	8b 45 14             	mov    0x14(%ebp),%eax
  802036:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80203b:	b8 07 00 00 00       	mov    $0x7,%eax
  802040:	e8 76 fe ff ff       	call   801ebb <nsipc>
  802045:	89 c3                	mov    %eax,%ebx
  802047:	85 c0                	test   %eax,%eax
  802049:	78 35                	js     802080 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80204b:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802050:	7f 04                	jg     802056 <nsipc_recv+0x39>
  802052:	39 c6                	cmp    %eax,%esi
  802054:	7d 16                	jge    80206c <nsipc_recv+0x4f>
  802056:	68 74 2f 80 00       	push   $0x802f74
  80205b:	68 88 2e 80 00       	push   $0x802e88
  802060:	6a 62                	push   $0x62
  802062:	68 89 2f 80 00       	push   $0x802f89
  802067:	e8 28 e1 ff ff       	call   800194 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80206c:	83 ec 04             	sub    $0x4,%esp
  80206f:	50                   	push   %eax
  802070:	68 00 60 80 00       	push   $0x806000
  802075:	ff 75 0c             	pushl  0xc(%ebp)
  802078:	e8 07 e9 ff ff       	call   800984 <memmove>
  80207d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802080:	89 d8                	mov    %ebx,%eax
  802082:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802085:	5b                   	pop    %ebx
  802086:	5e                   	pop    %esi
  802087:	5d                   	pop    %ebp
  802088:	c3                   	ret    

00802089 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802089:	55                   	push   %ebp
  80208a:	89 e5                	mov    %esp,%ebp
  80208c:	53                   	push   %ebx
  80208d:	83 ec 04             	sub    $0x4,%esp
  802090:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802093:	8b 45 08             	mov    0x8(%ebp),%eax
  802096:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80209b:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8020a1:	7e 16                	jle    8020b9 <nsipc_send+0x30>
  8020a3:	68 95 2f 80 00       	push   $0x802f95
  8020a8:	68 88 2e 80 00       	push   $0x802e88
  8020ad:	6a 6d                	push   $0x6d
  8020af:	68 89 2f 80 00       	push   $0x802f89
  8020b4:	e8 db e0 ff ff       	call   800194 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8020b9:	83 ec 04             	sub    $0x4,%esp
  8020bc:	53                   	push   %ebx
  8020bd:	ff 75 0c             	pushl  0xc(%ebp)
  8020c0:	68 0c 60 80 00       	push   $0x80600c
  8020c5:	e8 ba e8 ff ff       	call   800984 <memmove>
	nsipcbuf.send.req_size = size;
  8020ca:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8020d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8020d3:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8020d8:	b8 08 00 00 00       	mov    $0x8,%eax
  8020dd:	e8 d9 fd ff ff       	call   801ebb <nsipc>
}
  8020e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020e5:	c9                   	leave  
  8020e6:	c3                   	ret    

008020e7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8020e7:	55                   	push   %ebp
  8020e8:	89 e5                	mov    %esp,%ebp
  8020ea:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8020f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020f8:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8020fd:	8b 45 10             	mov    0x10(%ebp),%eax
  802100:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802105:	b8 09 00 00 00       	mov    $0x9,%eax
  80210a:	e8 ac fd ff ff       	call   801ebb <nsipc>
}
  80210f:	c9                   	leave  
  802110:	c3                   	ret    

00802111 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802111:	55                   	push   %ebp
  802112:	89 e5                	mov    %esp,%ebp
  802114:	56                   	push   %esi
  802115:	53                   	push   %ebx
  802116:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802119:	83 ec 0c             	sub    $0xc,%esp
  80211c:	ff 75 08             	pushl  0x8(%ebp)
  80211f:	e8 b6 ed ff ff       	call   800eda <fd2data>
  802124:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802126:	83 c4 08             	add    $0x8,%esp
  802129:	68 a1 2f 80 00       	push   $0x802fa1
  80212e:	53                   	push   %ebx
  80212f:	e8 be e6 ff ff       	call   8007f2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802134:	8b 46 04             	mov    0x4(%esi),%eax
  802137:	2b 06                	sub    (%esi),%eax
  802139:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80213f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802146:	00 00 00 
	stat->st_dev = &devpipe;
  802149:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  802150:	30 80 00 
	return 0;
}
  802153:	b8 00 00 00 00       	mov    $0x0,%eax
  802158:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80215b:	5b                   	pop    %ebx
  80215c:	5e                   	pop    %esi
  80215d:	5d                   	pop    %ebp
  80215e:	c3                   	ret    

0080215f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80215f:	55                   	push   %ebp
  802160:	89 e5                	mov    %esp,%ebp
  802162:	53                   	push   %ebx
  802163:	83 ec 0c             	sub    $0xc,%esp
  802166:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802169:	53                   	push   %ebx
  80216a:	6a 00                	push   $0x0
  80216c:	e8 09 eb ff ff       	call   800c7a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802171:	89 1c 24             	mov    %ebx,(%esp)
  802174:	e8 61 ed ff ff       	call   800eda <fd2data>
  802179:	83 c4 08             	add    $0x8,%esp
  80217c:	50                   	push   %eax
  80217d:	6a 00                	push   $0x0
  80217f:	e8 f6 ea ff ff       	call   800c7a <sys_page_unmap>
}
  802184:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802187:	c9                   	leave  
  802188:	c3                   	ret    

00802189 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802189:	55                   	push   %ebp
  80218a:	89 e5                	mov    %esp,%ebp
  80218c:	57                   	push   %edi
  80218d:	56                   	push   %esi
  80218e:	53                   	push   %ebx
  80218f:	83 ec 1c             	sub    $0x1c,%esp
  802192:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802195:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802197:	a1 08 40 80 00       	mov    0x804008,%eax
  80219c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80219f:	83 ec 0c             	sub    $0xc,%esp
  8021a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8021a5:	e8 3c 05 00 00       	call   8026e6 <pageref>
  8021aa:	89 c3                	mov    %eax,%ebx
  8021ac:	89 3c 24             	mov    %edi,(%esp)
  8021af:	e8 32 05 00 00       	call   8026e6 <pageref>
  8021b4:	83 c4 10             	add    $0x10,%esp
  8021b7:	39 c3                	cmp    %eax,%ebx
  8021b9:	0f 94 c1             	sete   %cl
  8021bc:	0f b6 c9             	movzbl %cl,%ecx
  8021bf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8021c2:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8021c8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8021cb:	39 ce                	cmp    %ecx,%esi
  8021cd:	74 1b                	je     8021ea <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8021cf:	39 c3                	cmp    %eax,%ebx
  8021d1:	75 c4                	jne    802197 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8021d3:	8b 42 58             	mov    0x58(%edx),%eax
  8021d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8021d9:	50                   	push   %eax
  8021da:	56                   	push   %esi
  8021db:	68 a8 2f 80 00       	push   $0x802fa8
  8021e0:	e8 88 e0 ff ff       	call   80026d <cprintf>
  8021e5:	83 c4 10             	add    $0x10,%esp
  8021e8:	eb ad                	jmp    802197 <_pipeisclosed+0xe>
	}
}
  8021ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021f0:	5b                   	pop    %ebx
  8021f1:	5e                   	pop    %esi
  8021f2:	5f                   	pop    %edi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    

008021f5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021f5:	55                   	push   %ebp
  8021f6:	89 e5                	mov    %esp,%ebp
  8021f8:	57                   	push   %edi
  8021f9:	56                   	push   %esi
  8021fa:	53                   	push   %ebx
  8021fb:	83 ec 28             	sub    $0x28,%esp
  8021fe:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802201:	56                   	push   %esi
  802202:	e8 d3 ec ff ff       	call   800eda <fd2data>
  802207:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802209:	83 c4 10             	add    $0x10,%esp
  80220c:	bf 00 00 00 00       	mov    $0x0,%edi
  802211:	eb 4b                	jmp    80225e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802213:	89 da                	mov    %ebx,%edx
  802215:	89 f0                	mov    %esi,%eax
  802217:	e8 6d ff ff ff       	call   802189 <_pipeisclosed>
  80221c:	85 c0                	test   %eax,%eax
  80221e:	75 48                	jne    802268 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802220:	e8 b1 e9 ff ff       	call   800bd6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802225:	8b 43 04             	mov    0x4(%ebx),%eax
  802228:	8b 0b                	mov    (%ebx),%ecx
  80222a:	8d 51 20             	lea    0x20(%ecx),%edx
  80222d:	39 d0                	cmp    %edx,%eax
  80222f:	73 e2                	jae    802213 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802231:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802234:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802238:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80223b:	89 c2                	mov    %eax,%edx
  80223d:	c1 fa 1f             	sar    $0x1f,%edx
  802240:	89 d1                	mov    %edx,%ecx
  802242:	c1 e9 1b             	shr    $0x1b,%ecx
  802245:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802248:	83 e2 1f             	and    $0x1f,%edx
  80224b:	29 ca                	sub    %ecx,%edx
  80224d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802251:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802255:	83 c0 01             	add    $0x1,%eax
  802258:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80225b:	83 c7 01             	add    $0x1,%edi
  80225e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802261:	75 c2                	jne    802225 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802263:	8b 45 10             	mov    0x10(%ebp),%eax
  802266:	eb 05                	jmp    80226d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802268:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80226d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802270:	5b                   	pop    %ebx
  802271:	5e                   	pop    %esi
  802272:	5f                   	pop    %edi
  802273:	5d                   	pop    %ebp
  802274:	c3                   	ret    

00802275 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802275:	55                   	push   %ebp
  802276:	89 e5                	mov    %esp,%ebp
  802278:	57                   	push   %edi
  802279:	56                   	push   %esi
  80227a:	53                   	push   %ebx
  80227b:	83 ec 18             	sub    $0x18,%esp
  80227e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802281:	57                   	push   %edi
  802282:	e8 53 ec ff ff       	call   800eda <fd2data>
  802287:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802289:	83 c4 10             	add    $0x10,%esp
  80228c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802291:	eb 3d                	jmp    8022d0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802293:	85 db                	test   %ebx,%ebx
  802295:	74 04                	je     80229b <devpipe_read+0x26>
				return i;
  802297:	89 d8                	mov    %ebx,%eax
  802299:	eb 44                	jmp    8022df <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80229b:	89 f2                	mov    %esi,%edx
  80229d:	89 f8                	mov    %edi,%eax
  80229f:	e8 e5 fe ff ff       	call   802189 <_pipeisclosed>
  8022a4:	85 c0                	test   %eax,%eax
  8022a6:	75 32                	jne    8022da <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8022a8:	e8 29 e9 ff ff       	call   800bd6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8022ad:	8b 06                	mov    (%esi),%eax
  8022af:	3b 46 04             	cmp    0x4(%esi),%eax
  8022b2:	74 df                	je     802293 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8022b4:	99                   	cltd   
  8022b5:	c1 ea 1b             	shr    $0x1b,%edx
  8022b8:	01 d0                	add    %edx,%eax
  8022ba:	83 e0 1f             	and    $0x1f,%eax
  8022bd:	29 d0                	sub    %edx,%eax
  8022bf:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8022c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022c7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8022ca:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022cd:	83 c3 01             	add    $0x1,%ebx
  8022d0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8022d3:	75 d8                	jne    8022ad <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8022d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8022d8:	eb 05                	jmp    8022df <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022da:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8022df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022e2:	5b                   	pop    %ebx
  8022e3:	5e                   	pop    %esi
  8022e4:	5f                   	pop    %edi
  8022e5:	5d                   	pop    %ebp
  8022e6:	c3                   	ret    

008022e7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8022e7:	55                   	push   %ebp
  8022e8:	89 e5                	mov    %esp,%ebp
  8022ea:	56                   	push   %esi
  8022eb:	53                   	push   %ebx
  8022ec:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8022ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022f2:	50                   	push   %eax
  8022f3:	e8 f9 eb ff ff       	call   800ef1 <fd_alloc>
  8022f8:	83 c4 10             	add    $0x10,%esp
  8022fb:	89 c2                	mov    %eax,%edx
  8022fd:	85 c0                	test   %eax,%eax
  8022ff:	0f 88 2c 01 00 00    	js     802431 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802305:	83 ec 04             	sub    $0x4,%esp
  802308:	68 07 04 00 00       	push   $0x407
  80230d:	ff 75 f4             	pushl  -0xc(%ebp)
  802310:	6a 00                	push   $0x0
  802312:	e8 de e8 ff ff       	call   800bf5 <sys_page_alloc>
  802317:	83 c4 10             	add    $0x10,%esp
  80231a:	89 c2                	mov    %eax,%edx
  80231c:	85 c0                	test   %eax,%eax
  80231e:	0f 88 0d 01 00 00    	js     802431 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802324:	83 ec 0c             	sub    $0xc,%esp
  802327:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80232a:	50                   	push   %eax
  80232b:	e8 c1 eb ff ff       	call   800ef1 <fd_alloc>
  802330:	89 c3                	mov    %eax,%ebx
  802332:	83 c4 10             	add    $0x10,%esp
  802335:	85 c0                	test   %eax,%eax
  802337:	0f 88 e2 00 00 00    	js     80241f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80233d:	83 ec 04             	sub    $0x4,%esp
  802340:	68 07 04 00 00       	push   $0x407
  802345:	ff 75 f0             	pushl  -0x10(%ebp)
  802348:	6a 00                	push   $0x0
  80234a:	e8 a6 e8 ff ff       	call   800bf5 <sys_page_alloc>
  80234f:	89 c3                	mov    %eax,%ebx
  802351:	83 c4 10             	add    $0x10,%esp
  802354:	85 c0                	test   %eax,%eax
  802356:	0f 88 c3 00 00 00    	js     80241f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80235c:	83 ec 0c             	sub    $0xc,%esp
  80235f:	ff 75 f4             	pushl  -0xc(%ebp)
  802362:	e8 73 eb ff ff       	call   800eda <fd2data>
  802367:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802369:	83 c4 0c             	add    $0xc,%esp
  80236c:	68 07 04 00 00       	push   $0x407
  802371:	50                   	push   %eax
  802372:	6a 00                	push   $0x0
  802374:	e8 7c e8 ff ff       	call   800bf5 <sys_page_alloc>
  802379:	89 c3                	mov    %eax,%ebx
  80237b:	83 c4 10             	add    $0x10,%esp
  80237e:	85 c0                	test   %eax,%eax
  802380:	0f 88 89 00 00 00    	js     80240f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802386:	83 ec 0c             	sub    $0xc,%esp
  802389:	ff 75 f0             	pushl  -0x10(%ebp)
  80238c:	e8 49 eb ff ff       	call   800eda <fd2data>
  802391:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802398:	50                   	push   %eax
  802399:	6a 00                	push   $0x0
  80239b:	56                   	push   %esi
  80239c:	6a 00                	push   $0x0
  80239e:	e8 95 e8 ff ff       	call   800c38 <sys_page_map>
  8023a3:	89 c3                	mov    %eax,%ebx
  8023a5:	83 c4 20             	add    $0x20,%esp
  8023a8:	85 c0                	test   %eax,%eax
  8023aa:	78 55                	js     802401 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8023ac:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8023b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023b5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8023b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ba:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8023c1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8023c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023ca:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8023cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023cf:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8023d6:	83 ec 0c             	sub    $0xc,%esp
  8023d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8023dc:	e8 e9 ea ff ff       	call   800eca <fd2num>
  8023e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023e4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8023e6:	83 c4 04             	add    $0x4,%esp
  8023e9:	ff 75 f0             	pushl  -0x10(%ebp)
  8023ec:	e8 d9 ea ff ff       	call   800eca <fd2num>
  8023f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023f4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8023f7:	83 c4 10             	add    $0x10,%esp
  8023fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8023ff:	eb 30                	jmp    802431 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802401:	83 ec 08             	sub    $0x8,%esp
  802404:	56                   	push   %esi
  802405:	6a 00                	push   $0x0
  802407:	e8 6e e8 ff ff       	call   800c7a <sys_page_unmap>
  80240c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80240f:	83 ec 08             	sub    $0x8,%esp
  802412:	ff 75 f0             	pushl  -0x10(%ebp)
  802415:	6a 00                	push   $0x0
  802417:	e8 5e e8 ff ff       	call   800c7a <sys_page_unmap>
  80241c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80241f:	83 ec 08             	sub    $0x8,%esp
  802422:	ff 75 f4             	pushl  -0xc(%ebp)
  802425:	6a 00                	push   $0x0
  802427:	e8 4e e8 ff ff       	call   800c7a <sys_page_unmap>
  80242c:	83 c4 10             	add    $0x10,%esp
  80242f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802431:	89 d0                	mov    %edx,%eax
  802433:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802436:	5b                   	pop    %ebx
  802437:	5e                   	pop    %esi
  802438:	5d                   	pop    %ebp
  802439:	c3                   	ret    

0080243a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80243a:	55                   	push   %ebp
  80243b:	89 e5                	mov    %esp,%ebp
  80243d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802440:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802443:	50                   	push   %eax
  802444:	ff 75 08             	pushl  0x8(%ebp)
  802447:	e8 f4 ea ff ff       	call   800f40 <fd_lookup>
  80244c:	83 c4 10             	add    $0x10,%esp
  80244f:	85 c0                	test   %eax,%eax
  802451:	78 18                	js     80246b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802453:	83 ec 0c             	sub    $0xc,%esp
  802456:	ff 75 f4             	pushl  -0xc(%ebp)
  802459:	e8 7c ea ff ff       	call   800eda <fd2data>
	return _pipeisclosed(fd, p);
  80245e:	89 c2                	mov    %eax,%edx
  802460:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802463:	e8 21 fd ff ff       	call   802189 <_pipeisclosed>
  802468:	83 c4 10             	add    $0x10,%esp
}
  80246b:	c9                   	leave  
  80246c:	c3                   	ret    

0080246d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80246d:	55                   	push   %ebp
  80246e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802470:	b8 00 00 00 00       	mov    $0x0,%eax
  802475:	5d                   	pop    %ebp
  802476:	c3                   	ret    

00802477 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802477:	55                   	push   %ebp
  802478:	89 e5                	mov    %esp,%ebp
  80247a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80247d:	68 c0 2f 80 00       	push   $0x802fc0
  802482:	ff 75 0c             	pushl  0xc(%ebp)
  802485:	e8 68 e3 ff ff       	call   8007f2 <strcpy>
	return 0;
}
  80248a:	b8 00 00 00 00       	mov    $0x0,%eax
  80248f:	c9                   	leave  
  802490:	c3                   	ret    

00802491 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802491:	55                   	push   %ebp
  802492:	89 e5                	mov    %esp,%ebp
  802494:	57                   	push   %edi
  802495:	56                   	push   %esi
  802496:	53                   	push   %ebx
  802497:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80249d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8024a2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024a8:	eb 2d                	jmp    8024d7 <devcons_write+0x46>
		m = n - tot;
  8024aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8024ad:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8024af:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8024b2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8024b7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8024ba:	83 ec 04             	sub    $0x4,%esp
  8024bd:	53                   	push   %ebx
  8024be:	03 45 0c             	add    0xc(%ebp),%eax
  8024c1:	50                   	push   %eax
  8024c2:	57                   	push   %edi
  8024c3:	e8 bc e4 ff ff       	call   800984 <memmove>
		sys_cputs(buf, m);
  8024c8:	83 c4 08             	add    $0x8,%esp
  8024cb:	53                   	push   %ebx
  8024cc:	57                   	push   %edi
  8024cd:	e8 67 e6 ff ff       	call   800b39 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024d2:	01 de                	add    %ebx,%esi
  8024d4:	83 c4 10             	add    $0x10,%esp
  8024d7:	89 f0                	mov    %esi,%eax
  8024d9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8024dc:	72 cc                	jb     8024aa <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8024de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024e1:	5b                   	pop    %ebx
  8024e2:	5e                   	pop    %esi
  8024e3:	5f                   	pop    %edi
  8024e4:	5d                   	pop    %ebp
  8024e5:	c3                   	ret    

008024e6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8024e6:	55                   	push   %ebp
  8024e7:	89 e5                	mov    %esp,%ebp
  8024e9:	83 ec 08             	sub    $0x8,%esp
  8024ec:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8024f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8024f5:	74 2a                	je     802521 <devcons_read+0x3b>
  8024f7:	eb 05                	jmp    8024fe <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8024f9:	e8 d8 e6 ff ff       	call   800bd6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8024fe:	e8 54 e6 ff ff       	call   800b57 <sys_cgetc>
  802503:	85 c0                	test   %eax,%eax
  802505:	74 f2                	je     8024f9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802507:	85 c0                	test   %eax,%eax
  802509:	78 16                	js     802521 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80250b:	83 f8 04             	cmp    $0x4,%eax
  80250e:	74 0c                	je     80251c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802510:	8b 55 0c             	mov    0xc(%ebp),%edx
  802513:	88 02                	mov    %al,(%edx)
	return 1;
  802515:	b8 01 00 00 00       	mov    $0x1,%eax
  80251a:	eb 05                	jmp    802521 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80251c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802521:	c9                   	leave  
  802522:	c3                   	ret    

00802523 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802523:	55                   	push   %ebp
  802524:	89 e5                	mov    %esp,%ebp
  802526:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802529:	8b 45 08             	mov    0x8(%ebp),%eax
  80252c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80252f:	6a 01                	push   $0x1
  802531:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802534:	50                   	push   %eax
  802535:	e8 ff e5 ff ff       	call   800b39 <sys_cputs>
}
  80253a:	83 c4 10             	add    $0x10,%esp
  80253d:	c9                   	leave  
  80253e:	c3                   	ret    

0080253f <getchar>:

int
getchar(void)
{
  80253f:	55                   	push   %ebp
  802540:	89 e5                	mov    %esp,%ebp
  802542:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802545:	6a 01                	push   $0x1
  802547:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80254a:	50                   	push   %eax
  80254b:	6a 00                	push   $0x0
  80254d:	e8 54 ec ff ff       	call   8011a6 <read>
	if (r < 0)
  802552:	83 c4 10             	add    $0x10,%esp
  802555:	85 c0                	test   %eax,%eax
  802557:	78 0f                	js     802568 <getchar+0x29>
		return r;
	if (r < 1)
  802559:	85 c0                	test   %eax,%eax
  80255b:	7e 06                	jle    802563 <getchar+0x24>
		return -E_EOF;
	return c;
  80255d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802561:	eb 05                	jmp    802568 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802563:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802568:	c9                   	leave  
  802569:	c3                   	ret    

0080256a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80256a:	55                   	push   %ebp
  80256b:	89 e5                	mov    %esp,%ebp
  80256d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802570:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802573:	50                   	push   %eax
  802574:	ff 75 08             	pushl  0x8(%ebp)
  802577:	e8 c4 e9 ff ff       	call   800f40 <fd_lookup>
  80257c:	83 c4 10             	add    $0x10,%esp
  80257f:	85 c0                	test   %eax,%eax
  802581:	78 11                	js     802594 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802583:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802586:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80258c:	39 10                	cmp    %edx,(%eax)
  80258e:	0f 94 c0             	sete   %al
  802591:	0f b6 c0             	movzbl %al,%eax
}
  802594:	c9                   	leave  
  802595:	c3                   	ret    

00802596 <opencons>:

int
opencons(void)
{
  802596:	55                   	push   %ebp
  802597:	89 e5                	mov    %esp,%ebp
  802599:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80259c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80259f:	50                   	push   %eax
  8025a0:	e8 4c e9 ff ff       	call   800ef1 <fd_alloc>
  8025a5:	83 c4 10             	add    $0x10,%esp
		return r;
  8025a8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8025aa:	85 c0                	test   %eax,%eax
  8025ac:	78 3e                	js     8025ec <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8025ae:	83 ec 04             	sub    $0x4,%esp
  8025b1:	68 07 04 00 00       	push   $0x407
  8025b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8025b9:	6a 00                	push   $0x0
  8025bb:	e8 35 e6 ff ff       	call   800bf5 <sys_page_alloc>
  8025c0:	83 c4 10             	add    $0x10,%esp
		return r;
  8025c3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8025c5:	85 c0                	test   %eax,%eax
  8025c7:	78 23                	js     8025ec <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8025c9:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8025cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025d2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8025d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025d7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8025de:	83 ec 0c             	sub    $0xc,%esp
  8025e1:	50                   	push   %eax
  8025e2:	e8 e3 e8 ff ff       	call   800eca <fd2num>
  8025e7:	89 c2                	mov    %eax,%edx
  8025e9:	83 c4 10             	add    $0x10,%esp
}
  8025ec:	89 d0                	mov    %edx,%eax
  8025ee:	c9                   	leave  
  8025ef:	c3                   	ret    

008025f0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8025f0:	55                   	push   %ebp
  8025f1:	89 e5                	mov    %esp,%ebp
  8025f3:	56                   	push   %esi
  8025f4:	53                   	push   %ebx
  8025f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8025f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  8025fe:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802600:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802605:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  802608:	83 ec 0c             	sub    $0xc,%esp
  80260b:	50                   	push   %eax
  80260c:	e8 94 e7 ff ff       	call   800da5 <sys_ipc_recv>

	if (r < 0) {
  802611:	83 c4 10             	add    $0x10,%esp
  802614:	85 c0                	test   %eax,%eax
  802616:	79 16                	jns    80262e <ipc_recv+0x3e>
		if (from_env_store)
  802618:	85 f6                	test   %esi,%esi
  80261a:	74 06                	je     802622 <ipc_recv+0x32>
			*from_env_store = 0;
  80261c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  802622:	85 db                	test   %ebx,%ebx
  802624:	74 2c                	je     802652 <ipc_recv+0x62>
			*perm_store = 0;
  802626:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80262c:	eb 24                	jmp    802652 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  80262e:	85 f6                	test   %esi,%esi
  802630:	74 0a                	je     80263c <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  802632:	a1 08 40 80 00       	mov    0x804008,%eax
  802637:	8b 40 74             	mov    0x74(%eax),%eax
  80263a:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  80263c:	85 db                	test   %ebx,%ebx
  80263e:	74 0a                	je     80264a <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  802640:	a1 08 40 80 00       	mov    0x804008,%eax
  802645:	8b 40 78             	mov    0x78(%eax),%eax
  802648:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  80264a:	a1 08 40 80 00       	mov    0x804008,%eax
  80264f:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  802652:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802655:	5b                   	pop    %ebx
  802656:	5e                   	pop    %esi
  802657:	5d                   	pop    %ebp
  802658:	c3                   	ret    

00802659 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802659:	55                   	push   %ebp
  80265a:	89 e5                	mov    %esp,%ebp
  80265c:	57                   	push   %edi
  80265d:	56                   	push   %esi
  80265e:	53                   	push   %ebx
  80265f:	83 ec 0c             	sub    $0xc,%esp
  802662:	8b 7d 08             	mov    0x8(%ebp),%edi
  802665:	8b 75 0c             	mov    0xc(%ebp),%esi
  802668:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  80266b:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80266d:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802672:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  802675:	ff 75 14             	pushl  0x14(%ebp)
  802678:	53                   	push   %ebx
  802679:	56                   	push   %esi
  80267a:	57                   	push   %edi
  80267b:	e8 02 e7 ff ff       	call   800d82 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  802680:	83 c4 10             	add    $0x10,%esp
  802683:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802686:	75 07                	jne    80268f <ipc_send+0x36>
			sys_yield();
  802688:	e8 49 e5 ff ff       	call   800bd6 <sys_yield>
  80268d:	eb e6                	jmp    802675 <ipc_send+0x1c>
		} else if (r < 0) {
  80268f:	85 c0                	test   %eax,%eax
  802691:	79 12                	jns    8026a5 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  802693:	50                   	push   %eax
  802694:	68 cc 2f 80 00       	push   $0x802fcc
  802699:	6a 51                	push   $0x51
  80269b:	68 d9 2f 80 00       	push   $0x802fd9
  8026a0:	e8 ef da ff ff       	call   800194 <_panic>
		}
	}
}
  8026a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026a8:	5b                   	pop    %ebx
  8026a9:	5e                   	pop    %esi
  8026aa:	5f                   	pop    %edi
  8026ab:	5d                   	pop    %ebp
  8026ac:	c3                   	ret    

008026ad <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8026ad:	55                   	push   %ebp
  8026ae:	89 e5                	mov    %esp,%ebp
  8026b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8026b3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8026b8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8026bb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8026c1:	8b 52 50             	mov    0x50(%edx),%edx
  8026c4:	39 ca                	cmp    %ecx,%edx
  8026c6:	75 0d                	jne    8026d5 <ipc_find_env+0x28>
			return envs[i].env_id;
  8026c8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8026cb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8026d0:	8b 40 48             	mov    0x48(%eax),%eax
  8026d3:	eb 0f                	jmp    8026e4 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8026d5:	83 c0 01             	add    $0x1,%eax
  8026d8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8026dd:	75 d9                	jne    8026b8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8026df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8026e4:	5d                   	pop    %ebp
  8026e5:	c3                   	ret    

008026e6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026e6:	55                   	push   %ebp
  8026e7:	89 e5                	mov    %esp,%ebp
  8026e9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026ec:	89 d0                	mov    %edx,%eax
  8026ee:	c1 e8 16             	shr    $0x16,%eax
  8026f1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8026f8:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026fd:	f6 c1 01             	test   $0x1,%cl
  802700:	74 1d                	je     80271f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802702:	c1 ea 0c             	shr    $0xc,%edx
  802705:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80270c:	f6 c2 01             	test   $0x1,%dl
  80270f:	74 0e                	je     80271f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802711:	c1 ea 0c             	shr    $0xc,%edx
  802714:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80271b:	ef 
  80271c:	0f b7 c0             	movzwl %ax,%eax
}
  80271f:	5d                   	pop    %ebp
  802720:	c3                   	ret    
  802721:	66 90                	xchg   %ax,%ax
  802723:	66 90                	xchg   %ax,%ax
  802725:	66 90                	xchg   %ax,%ax
  802727:	66 90                	xchg   %ax,%ax
  802729:	66 90                	xchg   %ax,%ax
  80272b:	66 90                	xchg   %ax,%ax
  80272d:	66 90                	xchg   %ax,%ax
  80272f:	90                   	nop

00802730 <__udivdi3>:
  802730:	55                   	push   %ebp
  802731:	57                   	push   %edi
  802732:	56                   	push   %esi
  802733:	53                   	push   %ebx
  802734:	83 ec 1c             	sub    $0x1c,%esp
  802737:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80273b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80273f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802743:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802747:	85 f6                	test   %esi,%esi
  802749:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80274d:	89 ca                	mov    %ecx,%edx
  80274f:	89 f8                	mov    %edi,%eax
  802751:	75 3d                	jne    802790 <__udivdi3+0x60>
  802753:	39 cf                	cmp    %ecx,%edi
  802755:	0f 87 c5 00 00 00    	ja     802820 <__udivdi3+0xf0>
  80275b:	85 ff                	test   %edi,%edi
  80275d:	89 fd                	mov    %edi,%ebp
  80275f:	75 0b                	jne    80276c <__udivdi3+0x3c>
  802761:	b8 01 00 00 00       	mov    $0x1,%eax
  802766:	31 d2                	xor    %edx,%edx
  802768:	f7 f7                	div    %edi
  80276a:	89 c5                	mov    %eax,%ebp
  80276c:	89 c8                	mov    %ecx,%eax
  80276e:	31 d2                	xor    %edx,%edx
  802770:	f7 f5                	div    %ebp
  802772:	89 c1                	mov    %eax,%ecx
  802774:	89 d8                	mov    %ebx,%eax
  802776:	89 cf                	mov    %ecx,%edi
  802778:	f7 f5                	div    %ebp
  80277a:	89 c3                	mov    %eax,%ebx
  80277c:	89 d8                	mov    %ebx,%eax
  80277e:	89 fa                	mov    %edi,%edx
  802780:	83 c4 1c             	add    $0x1c,%esp
  802783:	5b                   	pop    %ebx
  802784:	5e                   	pop    %esi
  802785:	5f                   	pop    %edi
  802786:	5d                   	pop    %ebp
  802787:	c3                   	ret    
  802788:	90                   	nop
  802789:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802790:	39 ce                	cmp    %ecx,%esi
  802792:	77 74                	ja     802808 <__udivdi3+0xd8>
  802794:	0f bd fe             	bsr    %esi,%edi
  802797:	83 f7 1f             	xor    $0x1f,%edi
  80279a:	0f 84 98 00 00 00    	je     802838 <__udivdi3+0x108>
  8027a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8027a5:	89 f9                	mov    %edi,%ecx
  8027a7:	89 c5                	mov    %eax,%ebp
  8027a9:	29 fb                	sub    %edi,%ebx
  8027ab:	d3 e6                	shl    %cl,%esi
  8027ad:	89 d9                	mov    %ebx,%ecx
  8027af:	d3 ed                	shr    %cl,%ebp
  8027b1:	89 f9                	mov    %edi,%ecx
  8027b3:	d3 e0                	shl    %cl,%eax
  8027b5:	09 ee                	or     %ebp,%esi
  8027b7:	89 d9                	mov    %ebx,%ecx
  8027b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027bd:	89 d5                	mov    %edx,%ebp
  8027bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027c3:	d3 ed                	shr    %cl,%ebp
  8027c5:	89 f9                	mov    %edi,%ecx
  8027c7:	d3 e2                	shl    %cl,%edx
  8027c9:	89 d9                	mov    %ebx,%ecx
  8027cb:	d3 e8                	shr    %cl,%eax
  8027cd:	09 c2                	or     %eax,%edx
  8027cf:	89 d0                	mov    %edx,%eax
  8027d1:	89 ea                	mov    %ebp,%edx
  8027d3:	f7 f6                	div    %esi
  8027d5:	89 d5                	mov    %edx,%ebp
  8027d7:	89 c3                	mov    %eax,%ebx
  8027d9:	f7 64 24 0c          	mull   0xc(%esp)
  8027dd:	39 d5                	cmp    %edx,%ebp
  8027df:	72 10                	jb     8027f1 <__udivdi3+0xc1>
  8027e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8027e5:	89 f9                	mov    %edi,%ecx
  8027e7:	d3 e6                	shl    %cl,%esi
  8027e9:	39 c6                	cmp    %eax,%esi
  8027eb:	73 07                	jae    8027f4 <__udivdi3+0xc4>
  8027ed:	39 d5                	cmp    %edx,%ebp
  8027ef:	75 03                	jne    8027f4 <__udivdi3+0xc4>
  8027f1:	83 eb 01             	sub    $0x1,%ebx
  8027f4:	31 ff                	xor    %edi,%edi
  8027f6:	89 d8                	mov    %ebx,%eax
  8027f8:	89 fa                	mov    %edi,%edx
  8027fa:	83 c4 1c             	add    $0x1c,%esp
  8027fd:	5b                   	pop    %ebx
  8027fe:	5e                   	pop    %esi
  8027ff:	5f                   	pop    %edi
  802800:	5d                   	pop    %ebp
  802801:	c3                   	ret    
  802802:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802808:	31 ff                	xor    %edi,%edi
  80280a:	31 db                	xor    %ebx,%ebx
  80280c:	89 d8                	mov    %ebx,%eax
  80280e:	89 fa                	mov    %edi,%edx
  802810:	83 c4 1c             	add    $0x1c,%esp
  802813:	5b                   	pop    %ebx
  802814:	5e                   	pop    %esi
  802815:	5f                   	pop    %edi
  802816:	5d                   	pop    %ebp
  802817:	c3                   	ret    
  802818:	90                   	nop
  802819:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802820:	89 d8                	mov    %ebx,%eax
  802822:	f7 f7                	div    %edi
  802824:	31 ff                	xor    %edi,%edi
  802826:	89 c3                	mov    %eax,%ebx
  802828:	89 d8                	mov    %ebx,%eax
  80282a:	89 fa                	mov    %edi,%edx
  80282c:	83 c4 1c             	add    $0x1c,%esp
  80282f:	5b                   	pop    %ebx
  802830:	5e                   	pop    %esi
  802831:	5f                   	pop    %edi
  802832:	5d                   	pop    %ebp
  802833:	c3                   	ret    
  802834:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802838:	39 ce                	cmp    %ecx,%esi
  80283a:	72 0c                	jb     802848 <__udivdi3+0x118>
  80283c:	31 db                	xor    %ebx,%ebx
  80283e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802842:	0f 87 34 ff ff ff    	ja     80277c <__udivdi3+0x4c>
  802848:	bb 01 00 00 00       	mov    $0x1,%ebx
  80284d:	e9 2a ff ff ff       	jmp    80277c <__udivdi3+0x4c>
  802852:	66 90                	xchg   %ax,%ax
  802854:	66 90                	xchg   %ax,%ax
  802856:	66 90                	xchg   %ax,%ax
  802858:	66 90                	xchg   %ax,%ax
  80285a:	66 90                	xchg   %ax,%ax
  80285c:	66 90                	xchg   %ax,%ax
  80285e:	66 90                	xchg   %ax,%ax

00802860 <__umoddi3>:
  802860:	55                   	push   %ebp
  802861:	57                   	push   %edi
  802862:	56                   	push   %esi
  802863:	53                   	push   %ebx
  802864:	83 ec 1c             	sub    $0x1c,%esp
  802867:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80286b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80286f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802873:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802877:	85 d2                	test   %edx,%edx
  802879:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80287d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802881:	89 f3                	mov    %esi,%ebx
  802883:	89 3c 24             	mov    %edi,(%esp)
  802886:	89 74 24 04          	mov    %esi,0x4(%esp)
  80288a:	75 1c                	jne    8028a8 <__umoddi3+0x48>
  80288c:	39 f7                	cmp    %esi,%edi
  80288e:	76 50                	jbe    8028e0 <__umoddi3+0x80>
  802890:	89 c8                	mov    %ecx,%eax
  802892:	89 f2                	mov    %esi,%edx
  802894:	f7 f7                	div    %edi
  802896:	89 d0                	mov    %edx,%eax
  802898:	31 d2                	xor    %edx,%edx
  80289a:	83 c4 1c             	add    $0x1c,%esp
  80289d:	5b                   	pop    %ebx
  80289e:	5e                   	pop    %esi
  80289f:	5f                   	pop    %edi
  8028a0:	5d                   	pop    %ebp
  8028a1:	c3                   	ret    
  8028a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028a8:	39 f2                	cmp    %esi,%edx
  8028aa:	89 d0                	mov    %edx,%eax
  8028ac:	77 52                	ja     802900 <__umoddi3+0xa0>
  8028ae:	0f bd ea             	bsr    %edx,%ebp
  8028b1:	83 f5 1f             	xor    $0x1f,%ebp
  8028b4:	75 5a                	jne    802910 <__umoddi3+0xb0>
  8028b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8028ba:	0f 82 e0 00 00 00    	jb     8029a0 <__umoddi3+0x140>
  8028c0:	39 0c 24             	cmp    %ecx,(%esp)
  8028c3:	0f 86 d7 00 00 00    	jbe    8029a0 <__umoddi3+0x140>
  8028c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8028cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8028d1:	83 c4 1c             	add    $0x1c,%esp
  8028d4:	5b                   	pop    %ebx
  8028d5:	5e                   	pop    %esi
  8028d6:	5f                   	pop    %edi
  8028d7:	5d                   	pop    %ebp
  8028d8:	c3                   	ret    
  8028d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028e0:	85 ff                	test   %edi,%edi
  8028e2:	89 fd                	mov    %edi,%ebp
  8028e4:	75 0b                	jne    8028f1 <__umoddi3+0x91>
  8028e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8028eb:	31 d2                	xor    %edx,%edx
  8028ed:	f7 f7                	div    %edi
  8028ef:	89 c5                	mov    %eax,%ebp
  8028f1:	89 f0                	mov    %esi,%eax
  8028f3:	31 d2                	xor    %edx,%edx
  8028f5:	f7 f5                	div    %ebp
  8028f7:	89 c8                	mov    %ecx,%eax
  8028f9:	f7 f5                	div    %ebp
  8028fb:	89 d0                	mov    %edx,%eax
  8028fd:	eb 99                	jmp    802898 <__umoddi3+0x38>
  8028ff:	90                   	nop
  802900:	89 c8                	mov    %ecx,%eax
  802902:	89 f2                	mov    %esi,%edx
  802904:	83 c4 1c             	add    $0x1c,%esp
  802907:	5b                   	pop    %ebx
  802908:	5e                   	pop    %esi
  802909:	5f                   	pop    %edi
  80290a:	5d                   	pop    %ebp
  80290b:	c3                   	ret    
  80290c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802910:	8b 34 24             	mov    (%esp),%esi
  802913:	bf 20 00 00 00       	mov    $0x20,%edi
  802918:	89 e9                	mov    %ebp,%ecx
  80291a:	29 ef                	sub    %ebp,%edi
  80291c:	d3 e0                	shl    %cl,%eax
  80291e:	89 f9                	mov    %edi,%ecx
  802920:	89 f2                	mov    %esi,%edx
  802922:	d3 ea                	shr    %cl,%edx
  802924:	89 e9                	mov    %ebp,%ecx
  802926:	09 c2                	or     %eax,%edx
  802928:	89 d8                	mov    %ebx,%eax
  80292a:	89 14 24             	mov    %edx,(%esp)
  80292d:	89 f2                	mov    %esi,%edx
  80292f:	d3 e2                	shl    %cl,%edx
  802931:	89 f9                	mov    %edi,%ecx
  802933:	89 54 24 04          	mov    %edx,0x4(%esp)
  802937:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80293b:	d3 e8                	shr    %cl,%eax
  80293d:	89 e9                	mov    %ebp,%ecx
  80293f:	89 c6                	mov    %eax,%esi
  802941:	d3 e3                	shl    %cl,%ebx
  802943:	89 f9                	mov    %edi,%ecx
  802945:	89 d0                	mov    %edx,%eax
  802947:	d3 e8                	shr    %cl,%eax
  802949:	89 e9                	mov    %ebp,%ecx
  80294b:	09 d8                	or     %ebx,%eax
  80294d:	89 d3                	mov    %edx,%ebx
  80294f:	89 f2                	mov    %esi,%edx
  802951:	f7 34 24             	divl   (%esp)
  802954:	89 d6                	mov    %edx,%esi
  802956:	d3 e3                	shl    %cl,%ebx
  802958:	f7 64 24 04          	mull   0x4(%esp)
  80295c:	39 d6                	cmp    %edx,%esi
  80295e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802962:	89 d1                	mov    %edx,%ecx
  802964:	89 c3                	mov    %eax,%ebx
  802966:	72 08                	jb     802970 <__umoddi3+0x110>
  802968:	75 11                	jne    80297b <__umoddi3+0x11b>
  80296a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80296e:	73 0b                	jae    80297b <__umoddi3+0x11b>
  802970:	2b 44 24 04          	sub    0x4(%esp),%eax
  802974:	1b 14 24             	sbb    (%esp),%edx
  802977:	89 d1                	mov    %edx,%ecx
  802979:	89 c3                	mov    %eax,%ebx
  80297b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80297f:	29 da                	sub    %ebx,%edx
  802981:	19 ce                	sbb    %ecx,%esi
  802983:	89 f9                	mov    %edi,%ecx
  802985:	89 f0                	mov    %esi,%eax
  802987:	d3 e0                	shl    %cl,%eax
  802989:	89 e9                	mov    %ebp,%ecx
  80298b:	d3 ea                	shr    %cl,%edx
  80298d:	89 e9                	mov    %ebp,%ecx
  80298f:	d3 ee                	shr    %cl,%esi
  802991:	09 d0                	or     %edx,%eax
  802993:	89 f2                	mov    %esi,%edx
  802995:	83 c4 1c             	add    $0x1c,%esp
  802998:	5b                   	pop    %ebx
  802999:	5e                   	pop    %esi
  80299a:	5f                   	pop    %edi
  80299b:	5d                   	pop    %ebp
  80299c:	c3                   	ret    
  80299d:	8d 76 00             	lea    0x0(%esi),%esi
  8029a0:	29 f9                	sub    %edi,%ecx
  8029a2:	19 d6                	sbb    %edx,%esi
  8029a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8029ac:	e9 18 ff ff ff       	jmp    8028c9 <__umoddi3+0x69>
