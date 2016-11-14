
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 c6 0f 00 00       	call   801007 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80004e:	e8 26 0b 00 00       	call   800b79 <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 60 14 80 00       	push   $0x801460
  80005d:	e8 87 01 00 00       	call   8001e9 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 0f 0b 00 00       	call   800b79 <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 7a 14 80 00       	push   $0x80147a
  800074:	e8 70 01 00 00       	call   8001e9 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 01 10 00 00       	call   801088 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 87 0f 00 00       	call   801021 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 20 80 00       	mov    0x802004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 c6 0a 00 00       	call   800b79 <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 90 14 80 00       	push   $0x801490
  8000c2:	e8 22 01 00 00       	call   8001e9 <cprintf>
		if (val == 10)
  8000c7:	a1 04 20 80 00       	mov    0x802004,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 9e 0f 00 00       	call   801088 <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  8000f4:	75 94                	jne    80008a <umain+0x57>
			return;
	}

}
  8000f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800109:	e8 6b 0a 00 00       	call   800b79 <sys_getenvid>
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011b:	a3 08 20 80 00       	mov    %eax,0x802008
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x2d>
		binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
  800130:	e8 fe fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800135:	e8 0a 00 00 00       	call   800144 <exit>
}
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80014a:	6a 00                	push   $0x0
  80014c:	e8 e7 09 00 00       	call   800b38 <sys_env_destroy>
}
  800151:	83 c4 10             	add    $0x10,%esp
  800154:	c9                   	leave  
  800155:	c3                   	ret    

00800156 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	53                   	push   %ebx
  80015a:	83 ec 04             	sub    $0x4,%esp
  80015d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800160:	8b 13                	mov    (%ebx),%edx
  800162:	8d 42 01             	lea    0x1(%edx),%eax
  800165:	89 03                	mov    %eax,(%ebx)
  800167:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80016e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800173:	75 1a                	jne    80018f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800175:	83 ec 08             	sub    $0x8,%esp
  800178:	68 ff 00 00 00       	push   $0xff
  80017d:	8d 43 08             	lea    0x8(%ebx),%eax
  800180:	50                   	push   %eax
  800181:	e8 75 09 00 00       	call   800afb <sys_cputs>
		b->idx = 0;
  800186:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80018c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80018f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800193:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a8:	00 00 00 
	b.cnt = 0;
  8001ab:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b5:	ff 75 0c             	pushl  0xc(%ebp)
  8001b8:	ff 75 08             	pushl  0x8(%ebp)
  8001bb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c1:	50                   	push   %eax
  8001c2:	68 56 01 80 00       	push   $0x800156
  8001c7:	e8 54 01 00 00       	call   800320 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001cc:	83 c4 08             	add    $0x8,%esp
  8001cf:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001d5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001db:	50                   	push   %eax
  8001dc:	e8 1a 09 00 00       	call   800afb <sys_cputs>

	return b.cnt;
}
  8001e1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001e7:	c9                   	leave  
  8001e8:	c3                   	ret    

008001e9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ef:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f2:	50                   	push   %eax
  8001f3:	ff 75 08             	pushl  0x8(%ebp)
  8001f6:	e8 9d ff ff ff       	call   800198 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001fb:	c9                   	leave  
  8001fc:	c3                   	ret    

008001fd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001fd:	55                   	push   %ebp
  8001fe:	89 e5                	mov    %esp,%ebp
  800200:	57                   	push   %edi
  800201:	56                   	push   %esi
  800202:	53                   	push   %ebx
  800203:	83 ec 1c             	sub    $0x1c,%esp
  800206:	89 c7                	mov    %eax,%edi
  800208:	89 d6                	mov    %edx,%esi
  80020a:	8b 45 08             	mov    0x8(%ebp),%eax
  80020d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800210:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800213:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800216:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800219:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800221:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800224:	39 d3                	cmp    %edx,%ebx
  800226:	72 05                	jb     80022d <printnum+0x30>
  800228:	39 45 10             	cmp    %eax,0x10(%ebp)
  80022b:	77 45                	ja     800272 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80022d:	83 ec 0c             	sub    $0xc,%esp
  800230:	ff 75 18             	pushl  0x18(%ebp)
  800233:	8b 45 14             	mov    0x14(%ebp),%eax
  800236:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800239:	53                   	push   %ebx
  80023a:	ff 75 10             	pushl  0x10(%ebp)
  80023d:	83 ec 08             	sub    $0x8,%esp
  800240:	ff 75 e4             	pushl  -0x1c(%ebp)
  800243:	ff 75 e0             	pushl  -0x20(%ebp)
  800246:	ff 75 dc             	pushl  -0x24(%ebp)
  800249:	ff 75 d8             	pushl  -0x28(%ebp)
  80024c:	e8 7f 0f 00 00       	call   8011d0 <__udivdi3>
  800251:	83 c4 18             	add    $0x18,%esp
  800254:	52                   	push   %edx
  800255:	50                   	push   %eax
  800256:	89 f2                	mov    %esi,%edx
  800258:	89 f8                	mov    %edi,%eax
  80025a:	e8 9e ff ff ff       	call   8001fd <printnum>
  80025f:	83 c4 20             	add    $0x20,%esp
  800262:	eb 18                	jmp    80027c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800264:	83 ec 08             	sub    $0x8,%esp
  800267:	56                   	push   %esi
  800268:	ff 75 18             	pushl  0x18(%ebp)
  80026b:	ff d7                	call   *%edi
  80026d:	83 c4 10             	add    $0x10,%esp
  800270:	eb 03                	jmp    800275 <printnum+0x78>
  800272:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800275:	83 eb 01             	sub    $0x1,%ebx
  800278:	85 db                	test   %ebx,%ebx
  80027a:	7f e8                	jg     800264 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027c:	83 ec 08             	sub    $0x8,%esp
  80027f:	56                   	push   %esi
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	ff 75 e4             	pushl  -0x1c(%ebp)
  800286:	ff 75 e0             	pushl  -0x20(%ebp)
  800289:	ff 75 dc             	pushl  -0x24(%ebp)
  80028c:	ff 75 d8             	pushl  -0x28(%ebp)
  80028f:	e8 6c 10 00 00       	call   801300 <__umoddi3>
  800294:	83 c4 14             	add    $0x14,%esp
  800297:	0f be 80 c0 14 80 00 	movsbl 0x8014c0(%eax),%eax
  80029e:	50                   	push   %eax
  80029f:	ff d7                	call   *%edi
}
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a7:	5b                   	pop    %ebx
  8002a8:	5e                   	pop    %esi
  8002a9:	5f                   	pop    %edi
  8002aa:	5d                   	pop    %ebp
  8002ab:	c3                   	ret    

008002ac <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002af:	83 fa 01             	cmp    $0x1,%edx
  8002b2:	7e 0e                	jle    8002c2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b4:	8b 10                	mov    (%eax),%edx
  8002b6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b9:	89 08                	mov    %ecx,(%eax)
  8002bb:	8b 02                	mov    (%edx),%eax
  8002bd:	8b 52 04             	mov    0x4(%edx),%edx
  8002c0:	eb 22                	jmp    8002e4 <getuint+0x38>
	else if (lflag)
  8002c2:	85 d2                	test   %edx,%edx
  8002c4:	74 10                	je     8002d6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cb:	89 08                	mov    %ecx,(%eax)
  8002cd:	8b 02                	mov    (%edx),%eax
  8002cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d4:	eb 0e                	jmp    8002e4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d6:	8b 10                	mov    (%eax),%edx
  8002d8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002db:	89 08                	mov    %ecx,(%eax)
  8002dd:	8b 02                	mov    (%edx),%eax
  8002df:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ec:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f5:	73 0a                	jae    800301 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fa:	89 08                	mov    %ecx,(%eax)
  8002fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ff:	88 02                	mov    %al,(%edx)
}
  800301:	5d                   	pop    %ebp
  800302:	c3                   	ret    

00800303 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800309:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030c:	50                   	push   %eax
  80030d:	ff 75 10             	pushl  0x10(%ebp)
  800310:	ff 75 0c             	pushl  0xc(%ebp)
  800313:	ff 75 08             	pushl  0x8(%ebp)
  800316:	e8 05 00 00 00       	call   800320 <vprintfmt>
	va_end(ap);
}
  80031b:	83 c4 10             	add    $0x10,%esp
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 2c             	sub    $0x2c,%esp
  800329:	8b 75 08             	mov    0x8(%ebp),%esi
  80032c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800332:	eb 1d                	jmp    800351 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  800334:	85 c0                	test   %eax,%eax
  800336:	75 0f                	jne    800347 <vprintfmt+0x27>
				csa = 0x0700;
  800338:	c7 05 0c 20 80 00 00 	movl   $0x700,0x80200c
  80033f:	07 00 00 
				return;
  800342:	e9 c4 03 00 00       	jmp    80070b <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  800347:	83 ec 08             	sub    $0x8,%esp
  80034a:	53                   	push   %ebx
  80034b:	50                   	push   %eax
  80034c:	ff d6                	call   *%esi
  80034e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800351:	83 c7 01             	add    $0x1,%edi
  800354:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800358:	83 f8 25             	cmp    $0x25,%eax
  80035b:	75 d7                	jne    800334 <vprintfmt+0x14>
  80035d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800361:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800368:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80036f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800376:	ba 00 00 00 00       	mov    $0x0,%edx
  80037b:	eb 07                	jmp    800384 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800380:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800384:	8d 47 01             	lea    0x1(%edi),%eax
  800387:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038a:	0f b6 07             	movzbl (%edi),%eax
  80038d:	0f b6 c8             	movzbl %al,%ecx
  800390:	83 e8 23             	sub    $0x23,%eax
  800393:	3c 55                	cmp    $0x55,%al
  800395:	0f 87 55 03 00 00    	ja     8006f0 <vprintfmt+0x3d0>
  80039b:	0f b6 c0             	movzbl %al,%eax
  80039e:	ff 24 85 80 15 80 00 	jmp    *0x801580(,%eax,4)
  8003a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003ac:	eb d6                	jmp    800384 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003bc:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003c0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003c3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c6:	83 fa 09             	cmp    $0x9,%edx
  8003c9:	77 39                	ja     800404 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003cb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ce:	eb e9                	jmp    8003b9 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d3:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d9:	8b 00                	mov    (%eax),%eax
  8003db:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e1:	eb 27                	jmp    80040a <vprintfmt+0xea>
  8003e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e6:	85 c0                	test   %eax,%eax
  8003e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ed:	0f 49 c8             	cmovns %eax,%ecx
  8003f0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f6:	eb 8c                	jmp    800384 <vprintfmt+0x64>
  8003f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003fb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800402:	eb 80                	jmp    800384 <vprintfmt+0x64>
  800404:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800407:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80040a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040e:	0f 89 70 ff ff ff    	jns    800384 <vprintfmt+0x64>
				width = precision, precision = -1;
  800414:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800417:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800421:	e9 5e ff ff ff       	jmp    800384 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800426:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800429:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80042c:	e9 53 ff ff ff       	jmp    800384 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800431:	8b 45 14             	mov    0x14(%ebp),%eax
  800434:	8d 50 04             	lea    0x4(%eax),%edx
  800437:	89 55 14             	mov    %edx,0x14(%ebp)
  80043a:	83 ec 08             	sub    $0x8,%esp
  80043d:	53                   	push   %ebx
  80043e:	ff 30                	pushl  (%eax)
  800440:	ff d6                	call   *%esi
			break;
  800442:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800445:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800448:	e9 04 ff ff ff       	jmp    800351 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044d:	8b 45 14             	mov    0x14(%ebp),%eax
  800450:	8d 50 04             	lea    0x4(%eax),%edx
  800453:	89 55 14             	mov    %edx,0x14(%ebp)
  800456:	8b 00                	mov    (%eax),%eax
  800458:	99                   	cltd   
  800459:	31 d0                	xor    %edx,%eax
  80045b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045d:	83 f8 08             	cmp    $0x8,%eax
  800460:	7f 0b                	jg     80046d <vprintfmt+0x14d>
  800462:	8b 14 85 e0 16 80 00 	mov    0x8016e0(,%eax,4),%edx
  800469:	85 d2                	test   %edx,%edx
  80046b:	75 18                	jne    800485 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  80046d:	50                   	push   %eax
  80046e:	68 d8 14 80 00       	push   $0x8014d8
  800473:	53                   	push   %ebx
  800474:	56                   	push   %esi
  800475:	e8 89 fe ff ff       	call   800303 <printfmt>
  80047a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800480:	e9 cc fe ff ff       	jmp    800351 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  800485:	52                   	push   %edx
  800486:	68 e1 14 80 00       	push   $0x8014e1
  80048b:	53                   	push   %ebx
  80048c:	56                   	push   %esi
  80048d:	e8 71 fe ff ff       	call   800303 <printfmt>
  800492:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800495:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800498:	e9 b4 fe ff ff       	jmp    800351 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049d:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a0:	8d 50 04             	lea    0x4(%eax),%edx
  8004a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a8:	85 ff                	test   %edi,%edi
  8004aa:	b8 d1 14 80 00       	mov    $0x8014d1,%eax
  8004af:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b6:	0f 8e 94 00 00 00    	jle    800550 <vprintfmt+0x230>
  8004bc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c0:	0f 84 98 00 00 00    	je     80055e <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	ff 75 d0             	pushl  -0x30(%ebp)
  8004cc:	57                   	push   %edi
  8004cd:	e8 c1 02 00 00       	call   800793 <strnlen>
  8004d2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d5:	29 c1                	sub    %eax,%ecx
  8004d7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004da:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004dd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e9:	eb 0f                	jmp    8004fa <vprintfmt+0x1da>
					putch(padc, putdat);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	53                   	push   %ebx
  8004ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f4:	83 ef 01             	sub    $0x1,%edi
  8004f7:	83 c4 10             	add    $0x10,%esp
  8004fa:	85 ff                	test   %edi,%edi
  8004fc:	7f ed                	jg     8004eb <vprintfmt+0x1cb>
  8004fe:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800501:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800504:	85 c9                	test   %ecx,%ecx
  800506:	b8 00 00 00 00       	mov    $0x0,%eax
  80050b:	0f 49 c1             	cmovns %ecx,%eax
  80050e:	29 c1                	sub    %eax,%ecx
  800510:	89 75 08             	mov    %esi,0x8(%ebp)
  800513:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800516:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800519:	89 cb                	mov    %ecx,%ebx
  80051b:	eb 4d                	jmp    80056a <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800521:	74 1b                	je     80053e <vprintfmt+0x21e>
  800523:	0f be c0             	movsbl %al,%eax
  800526:	83 e8 20             	sub    $0x20,%eax
  800529:	83 f8 5e             	cmp    $0x5e,%eax
  80052c:	76 10                	jbe    80053e <vprintfmt+0x21e>
					putch('?', putdat);
  80052e:	83 ec 08             	sub    $0x8,%esp
  800531:	ff 75 0c             	pushl  0xc(%ebp)
  800534:	6a 3f                	push   $0x3f
  800536:	ff 55 08             	call   *0x8(%ebp)
  800539:	83 c4 10             	add    $0x10,%esp
  80053c:	eb 0d                	jmp    80054b <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	ff 75 0c             	pushl  0xc(%ebp)
  800544:	52                   	push   %edx
  800545:	ff 55 08             	call   *0x8(%ebp)
  800548:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054b:	83 eb 01             	sub    $0x1,%ebx
  80054e:	eb 1a                	jmp    80056a <vprintfmt+0x24a>
  800550:	89 75 08             	mov    %esi,0x8(%ebp)
  800553:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800556:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800559:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055c:	eb 0c                	jmp    80056a <vprintfmt+0x24a>
  80055e:	89 75 08             	mov    %esi,0x8(%ebp)
  800561:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800564:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800567:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056a:	83 c7 01             	add    $0x1,%edi
  80056d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800571:	0f be d0             	movsbl %al,%edx
  800574:	85 d2                	test   %edx,%edx
  800576:	74 23                	je     80059b <vprintfmt+0x27b>
  800578:	85 f6                	test   %esi,%esi
  80057a:	78 a1                	js     80051d <vprintfmt+0x1fd>
  80057c:	83 ee 01             	sub    $0x1,%esi
  80057f:	79 9c                	jns    80051d <vprintfmt+0x1fd>
  800581:	89 df                	mov    %ebx,%edi
  800583:	8b 75 08             	mov    0x8(%ebp),%esi
  800586:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800589:	eb 18                	jmp    8005a3 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058b:	83 ec 08             	sub    $0x8,%esp
  80058e:	53                   	push   %ebx
  80058f:	6a 20                	push   $0x20
  800591:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800593:	83 ef 01             	sub    $0x1,%edi
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	eb 08                	jmp    8005a3 <vprintfmt+0x283>
  80059b:	89 df                	mov    %ebx,%edi
  80059d:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a3:	85 ff                	test   %edi,%edi
  8005a5:	7f e4                	jg     80058b <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005aa:	e9 a2 fd ff ff       	jmp    800351 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005af:	83 fa 01             	cmp    $0x1,%edx
  8005b2:	7e 16                	jle    8005ca <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 50 08             	lea    0x8(%eax),%edx
  8005ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bd:	8b 50 04             	mov    0x4(%eax),%edx
  8005c0:	8b 00                	mov    (%eax),%eax
  8005c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c8:	eb 32                	jmp    8005fc <vprintfmt+0x2dc>
	else if (lflag)
  8005ca:	85 d2                	test   %edx,%edx
  8005cc:	74 18                	je     8005e6 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8d 50 04             	lea    0x4(%eax),%edx
  8005d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d7:	8b 00                	mov    (%eax),%eax
  8005d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005dc:	89 c1                	mov    %eax,%ecx
  8005de:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e4:	eb 16                	jmp    8005fc <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 00                	mov    (%eax),%eax
  8005f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f4:	89 c1                	mov    %eax,%ecx
  8005f6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005fc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ff:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800602:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800607:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80060b:	79 74                	jns    800681 <vprintfmt+0x361>
				putch('-', putdat);
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	53                   	push   %ebx
  800611:	6a 2d                	push   $0x2d
  800613:	ff d6                	call   *%esi
				num = -(long long) num;
  800615:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800618:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80061b:	f7 d8                	neg    %eax
  80061d:	83 d2 00             	adc    $0x0,%edx
  800620:	f7 da                	neg    %edx
  800622:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800625:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80062a:	eb 55                	jmp    800681 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80062c:	8d 45 14             	lea    0x14(%ebp),%eax
  80062f:	e8 78 fc ff ff       	call   8002ac <getuint>
			base = 10;
  800634:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800639:	eb 46                	jmp    800681 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  80063b:	8d 45 14             	lea    0x14(%ebp),%eax
  80063e:	e8 69 fc ff ff       	call   8002ac <getuint>
      base = 8;
  800643:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800648:	eb 37                	jmp    800681 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	53                   	push   %ebx
  80064e:	6a 30                	push   $0x30
  800650:	ff d6                	call   *%esi
			putch('x', putdat);
  800652:	83 c4 08             	add    $0x8,%esp
  800655:	53                   	push   %ebx
  800656:	6a 78                	push   $0x78
  800658:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8d 50 04             	lea    0x4(%eax),%edx
  800660:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800663:	8b 00                	mov    (%eax),%eax
  800665:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80066a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80066d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800672:	eb 0d                	jmp    800681 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800674:	8d 45 14             	lea    0x14(%ebp),%eax
  800677:	e8 30 fc ff ff       	call   8002ac <getuint>
			base = 16;
  80067c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800681:	83 ec 0c             	sub    $0xc,%esp
  800684:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800688:	57                   	push   %edi
  800689:	ff 75 e0             	pushl  -0x20(%ebp)
  80068c:	51                   	push   %ecx
  80068d:	52                   	push   %edx
  80068e:	50                   	push   %eax
  80068f:	89 da                	mov    %ebx,%edx
  800691:	89 f0                	mov    %esi,%eax
  800693:	e8 65 fb ff ff       	call   8001fd <printnum>
			break;
  800698:	83 c4 20             	add    $0x20,%esp
  80069b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069e:	e9 ae fc ff ff       	jmp    800351 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	51                   	push   %ecx
  8006a8:	ff d6                	call   *%esi
			break;
  8006aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b0:	e9 9c fc ff ff       	jmp    800351 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b5:	83 fa 01             	cmp    $0x1,%edx
  8006b8:	7e 0d                	jle    8006c7 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8d 50 08             	lea    0x8(%eax),%edx
  8006c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c3:	8b 00                	mov    (%eax),%eax
  8006c5:	eb 1c                	jmp    8006e3 <vprintfmt+0x3c3>
	else if (lflag)
  8006c7:	85 d2                	test   %edx,%edx
  8006c9:	74 0d                	je     8006d8 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8d 50 04             	lea    0x4(%eax),%edx
  8006d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d4:	8b 00                	mov    (%eax),%eax
  8006d6:	eb 0b                	jmp    8006e3 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8d 50 04             	lea    0x4(%eax),%edx
  8006de:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e1:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  8006e3:	a3 0c 20 80 00       	mov    %eax,0x80200c
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  8006eb:	e9 61 fc ff ff       	jmp    800351 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f0:	83 ec 08             	sub    $0x8,%esp
  8006f3:	53                   	push   %ebx
  8006f4:	6a 25                	push   $0x25
  8006f6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f8:	83 c4 10             	add    $0x10,%esp
  8006fb:	eb 03                	jmp    800700 <vprintfmt+0x3e0>
  8006fd:	83 ef 01             	sub    $0x1,%edi
  800700:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800704:	75 f7                	jne    8006fd <vprintfmt+0x3dd>
  800706:	e9 46 fc ff ff       	jmp    800351 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  80070b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070e:	5b                   	pop    %ebx
  80070f:	5e                   	pop    %esi
  800710:	5f                   	pop    %edi
  800711:	5d                   	pop    %ebp
  800712:	c3                   	ret    

00800713 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800713:	55                   	push   %ebp
  800714:	89 e5                	mov    %esp,%ebp
  800716:	83 ec 18             	sub    $0x18,%esp
  800719:	8b 45 08             	mov    0x8(%ebp),%eax
  80071c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800722:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800726:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800729:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800730:	85 c0                	test   %eax,%eax
  800732:	74 26                	je     80075a <vsnprintf+0x47>
  800734:	85 d2                	test   %edx,%edx
  800736:	7e 22                	jle    80075a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800738:	ff 75 14             	pushl  0x14(%ebp)
  80073b:	ff 75 10             	pushl  0x10(%ebp)
  80073e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800741:	50                   	push   %eax
  800742:	68 e6 02 80 00       	push   $0x8002e6
  800747:	e8 d4 fb ff ff       	call   800320 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80074f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800752:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800755:	83 c4 10             	add    $0x10,%esp
  800758:	eb 05                	jmp    80075f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800767:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076a:	50                   	push   %eax
  80076b:	ff 75 10             	pushl  0x10(%ebp)
  80076e:	ff 75 0c             	pushl  0xc(%ebp)
  800771:	ff 75 08             	pushl  0x8(%ebp)
  800774:	e8 9a ff ff ff       	call   800713 <vsnprintf>
	va_end(ap);

	return rc;
}
  800779:	c9                   	leave  
  80077a:	c3                   	ret    

0080077b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800781:	b8 00 00 00 00       	mov    $0x0,%eax
  800786:	eb 03                	jmp    80078b <strlen+0x10>
		n++;
  800788:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80078f:	75 f7                	jne    800788 <strlen+0xd>
		n++;
	return n;
}
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800799:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079c:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a1:	eb 03                	jmp    8007a6 <strnlen+0x13>
		n++;
  8007a3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a6:	39 c2                	cmp    %eax,%edx
  8007a8:	74 08                	je     8007b2 <strnlen+0x1f>
  8007aa:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ae:	75 f3                	jne    8007a3 <strnlen+0x10>
  8007b0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	53                   	push   %ebx
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007be:	89 c2                	mov    %eax,%edx
  8007c0:	83 c2 01             	add    $0x1,%edx
  8007c3:	83 c1 01             	add    $0x1,%ecx
  8007c6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ca:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007cd:	84 db                	test   %bl,%bl
  8007cf:	75 ef                	jne    8007c0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d1:	5b                   	pop    %ebx
  8007d2:	5d                   	pop    %ebp
  8007d3:	c3                   	ret    

008007d4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	53                   	push   %ebx
  8007d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007db:	53                   	push   %ebx
  8007dc:	e8 9a ff ff ff       	call   80077b <strlen>
  8007e1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e4:	ff 75 0c             	pushl  0xc(%ebp)
  8007e7:	01 d8                	add    %ebx,%eax
  8007e9:	50                   	push   %eax
  8007ea:	e8 c5 ff ff ff       	call   8007b4 <strcpy>
	return dst;
}
  8007ef:	89 d8                	mov    %ebx,%eax
  8007f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f4:	c9                   	leave  
  8007f5:	c3                   	ret    

008007f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	56                   	push   %esi
  8007fa:	53                   	push   %ebx
  8007fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800801:	89 f3                	mov    %esi,%ebx
  800803:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800806:	89 f2                	mov    %esi,%edx
  800808:	eb 0f                	jmp    800819 <strncpy+0x23>
		*dst++ = *src;
  80080a:	83 c2 01             	add    $0x1,%edx
  80080d:	0f b6 01             	movzbl (%ecx),%eax
  800810:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800813:	80 39 01             	cmpb   $0x1,(%ecx)
  800816:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800819:	39 da                	cmp    %ebx,%edx
  80081b:	75 ed                	jne    80080a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80081d:	89 f0                	mov    %esi,%eax
  80081f:	5b                   	pop    %ebx
  800820:	5e                   	pop    %esi
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	56                   	push   %esi
  800827:	53                   	push   %ebx
  800828:	8b 75 08             	mov    0x8(%ebp),%esi
  80082b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082e:	8b 55 10             	mov    0x10(%ebp),%edx
  800831:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800833:	85 d2                	test   %edx,%edx
  800835:	74 21                	je     800858 <strlcpy+0x35>
  800837:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80083b:	89 f2                	mov    %esi,%edx
  80083d:	eb 09                	jmp    800848 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80083f:	83 c2 01             	add    $0x1,%edx
  800842:	83 c1 01             	add    $0x1,%ecx
  800845:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800848:	39 c2                	cmp    %eax,%edx
  80084a:	74 09                	je     800855 <strlcpy+0x32>
  80084c:	0f b6 19             	movzbl (%ecx),%ebx
  80084f:	84 db                	test   %bl,%bl
  800851:	75 ec                	jne    80083f <strlcpy+0x1c>
  800853:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800855:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800858:	29 f0                	sub    %esi,%eax
}
  80085a:	5b                   	pop    %ebx
  80085b:	5e                   	pop    %esi
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800864:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800867:	eb 06                	jmp    80086f <strcmp+0x11>
		p++, q++;
  800869:	83 c1 01             	add    $0x1,%ecx
  80086c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80086f:	0f b6 01             	movzbl (%ecx),%eax
  800872:	84 c0                	test   %al,%al
  800874:	74 04                	je     80087a <strcmp+0x1c>
  800876:	3a 02                	cmp    (%edx),%al
  800878:	74 ef                	je     800869 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087a:	0f b6 c0             	movzbl %al,%eax
  80087d:	0f b6 12             	movzbl (%edx),%edx
  800880:	29 d0                	sub    %edx,%eax
}
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	53                   	push   %ebx
  800888:	8b 45 08             	mov    0x8(%ebp),%eax
  80088b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088e:	89 c3                	mov    %eax,%ebx
  800890:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800893:	eb 06                	jmp    80089b <strncmp+0x17>
		n--, p++, q++;
  800895:	83 c0 01             	add    $0x1,%eax
  800898:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089b:	39 d8                	cmp    %ebx,%eax
  80089d:	74 15                	je     8008b4 <strncmp+0x30>
  80089f:	0f b6 08             	movzbl (%eax),%ecx
  8008a2:	84 c9                	test   %cl,%cl
  8008a4:	74 04                	je     8008aa <strncmp+0x26>
  8008a6:	3a 0a                	cmp    (%edx),%cl
  8008a8:	74 eb                	je     800895 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008aa:	0f b6 00             	movzbl (%eax),%eax
  8008ad:	0f b6 12             	movzbl (%edx),%edx
  8008b0:	29 d0                	sub    %edx,%eax
  8008b2:	eb 05                	jmp    8008b9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b9:	5b                   	pop    %ebx
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c6:	eb 07                	jmp    8008cf <strchr+0x13>
		if (*s == c)
  8008c8:	38 ca                	cmp    %cl,%dl
  8008ca:	74 0f                	je     8008db <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008cc:	83 c0 01             	add    $0x1,%eax
  8008cf:	0f b6 10             	movzbl (%eax),%edx
  8008d2:	84 d2                	test   %dl,%dl
  8008d4:	75 f2                	jne    8008c8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e7:	eb 03                	jmp    8008ec <strfind+0xf>
  8008e9:	83 c0 01             	add    $0x1,%eax
  8008ec:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ef:	38 ca                	cmp    %cl,%dl
  8008f1:	74 04                	je     8008f7 <strfind+0x1a>
  8008f3:	84 d2                	test   %dl,%dl
  8008f5:	75 f2                	jne    8008e9 <strfind+0xc>
			break;
	return (char *) s;
}
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	57                   	push   %edi
  8008fd:	56                   	push   %esi
  8008fe:	53                   	push   %ebx
  8008ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  800902:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800905:	85 c9                	test   %ecx,%ecx
  800907:	74 36                	je     80093f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800909:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80090f:	75 28                	jne    800939 <memset+0x40>
  800911:	f6 c1 03             	test   $0x3,%cl
  800914:	75 23                	jne    800939 <memset+0x40>
		c &= 0xFF;
  800916:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091a:	89 d3                	mov    %edx,%ebx
  80091c:	c1 e3 08             	shl    $0x8,%ebx
  80091f:	89 d6                	mov    %edx,%esi
  800921:	c1 e6 18             	shl    $0x18,%esi
  800924:	89 d0                	mov    %edx,%eax
  800926:	c1 e0 10             	shl    $0x10,%eax
  800929:	09 f0                	or     %esi,%eax
  80092b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80092d:	89 d8                	mov    %ebx,%eax
  80092f:	09 d0                	or     %edx,%eax
  800931:	c1 e9 02             	shr    $0x2,%ecx
  800934:	fc                   	cld    
  800935:	f3 ab                	rep stos %eax,%es:(%edi)
  800937:	eb 06                	jmp    80093f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800939:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093c:	fc                   	cld    
  80093d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80093f:	89 f8                	mov    %edi,%eax
  800941:	5b                   	pop    %ebx
  800942:	5e                   	pop    %esi
  800943:	5f                   	pop    %edi
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	57                   	push   %edi
  80094a:	56                   	push   %esi
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800951:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800954:	39 c6                	cmp    %eax,%esi
  800956:	73 35                	jae    80098d <memmove+0x47>
  800958:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095b:	39 d0                	cmp    %edx,%eax
  80095d:	73 2e                	jae    80098d <memmove+0x47>
		s += n;
		d += n;
  80095f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800962:	89 d6                	mov    %edx,%esi
  800964:	09 fe                	or     %edi,%esi
  800966:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096c:	75 13                	jne    800981 <memmove+0x3b>
  80096e:	f6 c1 03             	test   $0x3,%cl
  800971:	75 0e                	jne    800981 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800973:	83 ef 04             	sub    $0x4,%edi
  800976:	8d 72 fc             	lea    -0x4(%edx),%esi
  800979:	c1 e9 02             	shr    $0x2,%ecx
  80097c:	fd                   	std    
  80097d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097f:	eb 09                	jmp    80098a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800981:	83 ef 01             	sub    $0x1,%edi
  800984:	8d 72 ff             	lea    -0x1(%edx),%esi
  800987:	fd                   	std    
  800988:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098a:	fc                   	cld    
  80098b:	eb 1d                	jmp    8009aa <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098d:	89 f2                	mov    %esi,%edx
  80098f:	09 c2                	or     %eax,%edx
  800991:	f6 c2 03             	test   $0x3,%dl
  800994:	75 0f                	jne    8009a5 <memmove+0x5f>
  800996:	f6 c1 03             	test   $0x3,%cl
  800999:	75 0a                	jne    8009a5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80099b:	c1 e9 02             	shr    $0x2,%ecx
  80099e:	89 c7                	mov    %eax,%edi
  8009a0:	fc                   	cld    
  8009a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a3:	eb 05                	jmp    8009aa <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a5:	89 c7                	mov    %eax,%edi
  8009a7:	fc                   	cld    
  8009a8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009aa:	5e                   	pop    %esi
  8009ab:	5f                   	pop    %edi
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b1:	ff 75 10             	pushl  0x10(%ebp)
  8009b4:	ff 75 0c             	pushl  0xc(%ebp)
  8009b7:	ff 75 08             	pushl  0x8(%ebp)
  8009ba:	e8 87 ff ff ff       	call   800946 <memmove>
}
  8009bf:	c9                   	leave  
  8009c0:	c3                   	ret    

008009c1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	56                   	push   %esi
  8009c5:	53                   	push   %ebx
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cc:	89 c6                	mov    %eax,%esi
  8009ce:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d1:	eb 1a                	jmp    8009ed <memcmp+0x2c>
		if (*s1 != *s2)
  8009d3:	0f b6 08             	movzbl (%eax),%ecx
  8009d6:	0f b6 1a             	movzbl (%edx),%ebx
  8009d9:	38 d9                	cmp    %bl,%cl
  8009db:	74 0a                	je     8009e7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009dd:	0f b6 c1             	movzbl %cl,%eax
  8009e0:	0f b6 db             	movzbl %bl,%ebx
  8009e3:	29 d8                	sub    %ebx,%eax
  8009e5:	eb 0f                	jmp    8009f6 <memcmp+0x35>
		s1++, s2++;
  8009e7:	83 c0 01             	add    $0x1,%eax
  8009ea:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ed:	39 f0                	cmp    %esi,%eax
  8009ef:	75 e2                	jne    8009d3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f6:	5b                   	pop    %ebx
  8009f7:	5e                   	pop    %esi
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	53                   	push   %ebx
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a01:	89 c1                	mov    %eax,%ecx
  800a03:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a06:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0a:	eb 0a                	jmp    800a16 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0c:	0f b6 10             	movzbl (%eax),%edx
  800a0f:	39 da                	cmp    %ebx,%edx
  800a11:	74 07                	je     800a1a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a13:	83 c0 01             	add    $0x1,%eax
  800a16:	39 c8                	cmp    %ecx,%eax
  800a18:	72 f2                	jb     800a0c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1a:	5b                   	pop    %ebx
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    

00800a1d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	57                   	push   %edi
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a29:	eb 03                	jmp    800a2e <strtol+0x11>
		s++;
  800a2b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2e:	0f b6 01             	movzbl (%ecx),%eax
  800a31:	3c 20                	cmp    $0x20,%al
  800a33:	74 f6                	je     800a2b <strtol+0xe>
  800a35:	3c 09                	cmp    $0x9,%al
  800a37:	74 f2                	je     800a2b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a39:	3c 2b                	cmp    $0x2b,%al
  800a3b:	75 0a                	jne    800a47 <strtol+0x2a>
		s++;
  800a3d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a40:	bf 00 00 00 00       	mov    $0x0,%edi
  800a45:	eb 11                	jmp    800a58 <strtol+0x3b>
  800a47:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a4c:	3c 2d                	cmp    $0x2d,%al
  800a4e:	75 08                	jne    800a58 <strtol+0x3b>
		s++, neg = 1;
  800a50:	83 c1 01             	add    $0x1,%ecx
  800a53:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a58:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a5e:	75 15                	jne    800a75 <strtol+0x58>
  800a60:	80 39 30             	cmpb   $0x30,(%ecx)
  800a63:	75 10                	jne    800a75 <strtol+0x58>
  800a65:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a69:	75 7c                	jne    800ae7 <strtol+0xca>
		s += 2, base = 16;
  800a6b:	83 c1 02             	add    $0x2,%ecx
  800a6e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a73:	eb 16                	jmp    800a8b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a75:	85 db                	test   %ebx,%ebx
  800a77:	75 12                	jne    800a8b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a79:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a7e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a81:	75 08                	jne    800a8b <strtol+0x6e>
		s++, base = 8;
  800a83:	83 c1 01             	add    $0x1,%ecx
  800a86:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a90:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a93:	0f b6 11             	movzbl (%ecx),%edx
  800a96:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a99:	89 f3                	mov    %esi,%ebx
  800a9b:	80 fb 09             	cmp    $0x9,%bl
  800a9e:	77 08                	ja     800aa8 <strtol+0x8b>
			dig = *s - '0';
  800aa0:	0f be d2             	movsbl %dl,%edx
  800aa3:	83 ea 30             	sub    $0x30,%edx
  800aa6:	eb 22                	jmp    800aca <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aa8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aab:	89 f3                	mov    %esi,%ebx
  800aad:	80 fb 19             	cmp    $0x19,%bl
  800ab0:	77 08                	ja     800aba <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab2:	0f be d2             	movsbl %dl,%edx
  800ab5:	83 ea 57             	sub    $0x57,%edx
  800ab8:	eb 10                	jmp    800aca <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aba:	8d 72 bf             	lea    -0x41(%edx),%esi
  800abd:	89 f3                	mov    %esi,%ebx
  800abf:	80 fb 19             	cmp    $0x19,%bl
  800ac2:	77 16                	ja     800ada <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac4:	0f be d2             	movsbl %dl,%edx
  800ac7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aca:	3b 55 10             	cmp    0x10(%ebp),%edx
  800acd:	7d 0b                	jge    800ada <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800acf:	83 c1 01             	add    $0x1,%ecx
  800ad2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ad8:	eb b9                	jmp    800a93 <strtol+0x76>

	if (endptr)
  800ada:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ade:	74 0d                	je     800aed <strtol+0xd0>
		*endptr = (char *) s;
  800ae0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae3:	89 0e                	mov    %ecx,(%esi)
  800ae5:	eb 06                	jmp    800aed <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae7:	85 db                	test   %ebx,%ebx
  800ae9:	74 98                	je     800a83 <strtol+0x66>
  800aeb:	eb 9e                	jmp    800a8b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aed:	89 c2                	mov    %eax,%edx
  800aef:	f7 da                	neg    %edx
  800af1:	85 ff                	test   %edi,%edi
  800af3:	0f 45 c2             	cmovne %edx,%eax
}
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b01:	b8 00 00 00 00       	mov    $0x0,%eax
  800b06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b09:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0c:	89 c3                	mov    %eax,%ebx
  800b0e:	89 c7                	mov    %eax,%edi
  800b10:	89 c6                	mov    %eax,%esi
  800b12:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5f                   	pop    %edi
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    

00800b19 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	57                   	push   %edi
  800b1d:	56                   	push   %esi
  800b1e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b24:	b8 01 00 00 00       	mov    $0x1,%eax
  800b29:	89 d1                	mov    %edx,%ecx
  800b2b:	89 d3                	mov    %edx,%ebx
  800b2d:	89 d7                	mov    %edx,%edi
  800b2f:	89 d6                	mov    %edx,%esi
  800b31:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
  800b3e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b41:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b46:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4e:	89 cb                	mov    %ecx,%ebx
  800b50:	89 cf                	mov    %ecx,%edi
  800b52:	89 ce                	mov    %ecx,%esi
  800b54:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b56:	85 c0                	test   %eax,%eax
  800b58:	7e 17                	jle    800b71 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5a:	83 ec 0c             	sub    $0xc,%esp
  800b5d:	50                   	push   %eax
  800b5e:	6a 03                	push   $0x3
  800b60:	68 04 17 80 00       	push   $0x801704
  800b65:	6a 23                	push   $0x23
  800b67:	68 21 17 80 00       	push   $0x801721
  800b6c:	e8 77 05 00 00       	call   8010e8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b84:	b8 02 00 00 00       	mov    $0x2,%eax
  800b89:	89 d1                	mov    %edx,%ecx
  800b8b:	89 d3                	mov    %edx,%ebx
  800b8d:	89 d7                	mov    %edx,%edi
  800b8f:	89 d6                	mov    %edx,%esi
  800b91:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800b93:	5b                   	pop    %ebx
  800b94:	5e                   	pop    %esi
  800b95:	5f                   	pop    %edi
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    

00800b98 <sys_yield>:

void
sys_yield(void)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	57                   	push   %edi
  800b9c:	56                   	push   %esi
  800b9d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ba8:	89 d1                	mov    %edx,%ecx
  800baa:	89 d3                	mov    %edx,%ebx
  800bac:	89 d7                	mov    %edx,%edi
  800bae:	89 d6                	mov    %edx,%esi
  800bb0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
  800bbd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc0:	be 00 00 00 00       	mov    $0x0,%esi
  800bc5:	b8 04 00 00 00       	mov    $0x4,%eax
  800bca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd3:	89 f7                	mov    %esi,%edi
  800bd5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd7:	85 c0                	test   %eax,%eax
  800bd9:	7e 17                	jle    800bf2 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdb:	83 ec 0c             	sub    $0xc,%esp
  800bde:	50                   	push   %eax
  800bdf:	6a 04                	push   $0x4
  800be1:	68 04 17 80 00       	push   $0x801704
  800be6:	6a 23                	push   $0x23
  800be8:	68 21 17 80 00       	push   $0x801721
  800bed:	e8 f6 04 00 00       	call   8010e8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800c03:	b8 05 00 00 00       	mov    $0x5,%eax
  800c08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c11:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c14:	8b 75 18             	mov    0x18(%ebp),%esi
  800c17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c19:	85 c0                	test   %eax,%eax
  800c1b:	7e 17                	jle    800c34 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1d:	83 ec 0c             	sub    $0xc,%esp
  800c20:	50                   	push   %eax
  800c21:	6a 05                	push   $0x5
  800c23:	68 04 17 80 00       	push   $0x801704
  800c28:	6a 23                	push   $0x23
  800c2a:	68 21 17 80 00       	push   $0x801721
  800c2f:	e8 b4 04 00 00       	call   8010e8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	57                   	push   %edi
  800c40:	56                   	push   %esi
  800c41:	53                   	push   %ebx
  800c42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c45:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c52:	8b 55 08             	mov    0x8(%ebp),%edx
  800c55:	89 df                	mov    %ebx,%edi
  800c57:	89 de                	mov    %ebx,%esi
  800c59:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5b:	85 c0                	test   %eax,%eax
  800c5d:	7e 17                	jle    800c76 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5f:	83 ec 0c             	sub    $0xc,%esp
  800c62:	50                   	push   %eax
  800c63:	6a 06                	push   $0x6
  800c65:	68 04 17 80 00       	push   $0x801704
  800c6a:	6a 23                	push   $0x23
  800c6c:	68 21 17 80 00       	push   $0x801721
  800c71:	e8 72 04 00 00       	call   8010e8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
  800c84:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c87:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c94:	8b 55 08             	mov    0x8(%ebp),%edx
  800c97:	89 df                	mov    %ebx,%edi
  800c99:	89 de                	mov    %ebx,%esi
  800c9b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9d:	85 c0                	test   %eax,%eax
  800c9f:	7e 17                	jle    800cb8 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca1:	83 ec 0c             	sub    $0xc,%esp
  800ca4:	50                   	push   %eax
  800ca5:	6a 08                	push   $0x8
  800ca7:	68 04 17 80 00       	push   $0x801704
  800cac:	6a 23                	push   $0x23
  800cae:	68 21 17 80 00       	push   $0x801721
  800cb3:	e8 30 04 00 00       	call   8010e8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	57                   	push   %edi
  800cc4:	56                   	push   %esi
  800cc5:	53                   	push   %ebx
  800cc6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cce:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd9:	89 df                	mov    %ebx,%edi
  800cdb:	89 de                	mov    %ebx,%esi
  800cdd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	7e 17                	jle    800cfa <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce3:	83 ec 0c             	sub    $0xc,%esp
  800ce6:	50                   	push   %eax
  800ce7:	6a 09                	push   $0x9
  800ce9:	68 04 17 80 00       	push   $0x801704
  800cee:	6a 23                	push   $0x23
  800cf0:	68 21 17 80 00       	push   $0x801721
  800cf5:	e8 ee 03 00 00       	call   8010e8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    

00800d02 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	57                   	push   %edi
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d08:	be 00 00 00 00       	mov    $0x0,%esi
  800d0d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d15:	8b 55 08             	mov    0x8(%ebp),%edx
  800d18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d1e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	57                   	push   %edi
  800d29:	56                   	push   %esi
  800d2a:	53                   	push   %ebx
  800d2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d33:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d38:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3b:	89 cb                	mov    %ecx,%ebx
  800d3d:	89 cf                	mov    %ecx,%edi
  800d3f:	89 ce                	mov    %ecx,%esi
  800d41:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d43:	85 c0                	test   %eax,%eax
  800d45:	7e 17                	jle    800d5e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d47:	83 ec 0c             	sub    $0xc,%esp
  800d4a:	50                   	push   %eax
  800d4b:	6a 0c                	push   $0xc
  800d4d:	68 04 17 80 00       	push   $0x801704
  800d52:	6a 23                	push   $0x23
  800d54:	68 21 17 80 00       	push   $0x801721
  800d59:	e8 8a 03 00 00       	call   8010e8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	53                   	push   %ebx
  800d6a:	83 ec 04             	sub    $0x4,%esp
  800d6d:	8b 55 08             	mov    0x8(%ebp),%edx
	
	void *fault_addr = (void *) utf->utf_fault_va;
  800d70:	8b 02                	mov    (%edx),%eax
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800d72:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800d76:	74 2e                	je     800da6 <pgfault+0x40>
			(err & FEC_WR) && (uvpd[PDX(fault_addr)] & PTE_P) && 
  800d78:	89 c2                	mov    %eax,%edx
  800d7a:	c1 ea 16             	shr    $0x16,%edx
  800d7d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d84:	f6 c2 01             	test   $0x1,%dl
  800d87:	74 1d                	je     800da6 <pgfault+0x40>
			(uvpt[PGNUM(fault_addr)] & PTE_P) && (uvpt[PGNUM(fault_addr)] & PTE_COW)))
  800d89:	89 c2                	mov    %eax,%edx
  800d8b:	c1 ea 0c             	shr    $0xc,%edx
  800d8e:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
			(err & FEC_WR) && (uvpd[PDX(fault_addr)] & PTE_P) && 
  800d95:	f6 c1 01             	test   $0x1,%cl
  800d98:	74 0c                	je     800da6 <pgfault+0x40>
			(uvpt[PGNUM(fault_addr)] & PTE_P) && (uvpt[PGNUM(fault_addr)] & PTE_COW)))
  800d9a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800da1:	f6 c6 08             	test   $0x8,%dh
  800da4:	75 14                	jne    800dba <pgfault+0x54>
			(err & FEC_WR) && (uvpd[PDX(fault_addr)] & PTE_P) && 
			(uvpt[PGNUM(fault_addr)] & PTE_P) && (uvpt[PGNUM(fault_addr)] & PTE_COW)))
		panic("copy-on-write not there");
  800da6:	83 ec 04             	sub    $0x4,%esp
  800da9:	68 2f 17 80 00       	push   $0x80172f
  800dae:	6a 20                	push   $0x20
  800db0:	68 47 17 80 00       	push   $0x801747
  800db5:	e8 2e 03 00 00       	call   8010e8 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	fault_addr = ROUNDDOWN(fault_addr, PGSIZE);
  800dba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dbf:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800dc1:	83 ec 04             	sub    $0x4,%esp
  800dc4:	6a 07                	push   $0x7
  800dc6:	68 00 f0 7f 00       	push   $0x7ff000
  800dcb:	6a 00                	push   $0x0
  800dcd:	e8 e5 fd ff ff       	call   800bb7 <sys_page_alloc>
  800dd2:	83 c4 10             	add    $0x10,%esp
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	79 14                	jns    800ded <pgfault+0x87>
		panic("page alloc failed");
  800dd9:	83 ec 04             	sub    $0x4,%esp
  800ddc:	68 52 17 80 00       	push   $0x801752
  800de1:	6a 2c                	push   $0x2c
  800de3:	68 47 17 80 00       	push   $0x801747
  800de8:	e8 fb 02 00 00       	call   8010e8 <_panic>
	memcpy(PFTEMP, fault_addr, PGSIZE);
  800ded:	83 ec 04             	sub    $0x4,%esp
  800df0:	68 00 10 00 00       	push   $0x1000
  800df5:	53                   	push   %ebx
  800df6:	68 00 f0 7f 00       	push   $0x7ff000
  800dfb:	e8 ae fb ff ff       	call   8009ae <memcpy>
	if (sys_page_map(0, PFTEMP, 0, fault_addr, PTE_W|PTE_U|PTE_P) < 0)
  800e00:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e07:	53                   	push   %ebx
  800e08:	6a 00                	push   $0x0
  800e0a:	68 00 f0 7f 00       	push   $0x7ff000
  800e0f:	6a 00                	push   $0x0
  800e11:	e8 e4 fd ff ff       	call   800bfa <sys_page_map>
  800e16:	83 c4 20             	add    $0x20,%esp
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	79 14                	jns    800e31 <pgfault+0xcb>
		panic("pagemap failed");
  800e1d:	83 ec 04             	sub    $0x4,%esp
  800e20:	68 64 17 80 00       	push   $0x801764
  800e25:	6a 2f                	push   $0x2f
  800e27:	68 47 17 80 00       	push   $0x801747
  800e2c:	e8 b7 02 00 00       	call   8010e8 <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  800e31:	83 ec 08             	sub    $0x8,%esp
  800e34:	68 00 f0 7f 00       	push   $0x7ff000
  800e39:	6a 00                	push   $0x0
  800e3b:	e8 fc fd ff ff       	call   800c3c <sys_page_unmap>
  800e40:	83 c4 10             	add    $0x10,%esp
  800e43:	85 c0                	test   %eax,%eax
  800e45:	79 14                	jns    800e5b <pgfault+0xf5>
		panic("page unmap failed");
  800e47:	83 ec 04             	sub    $0x4,%esp
  800e4a:	68 73 17 80 00       	push   $0x801773
  800e4f:	6a 31                	push   $0x31
  800e51:	68 47 17 80 00       	push   $0x801747
  800e56:	e8 8d 02 00 00       	call   8010e8 <_panic>
	//return;
}
  800e5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e5e:	c9                   	leave  
  800e5f:	c3                   	ret    

00800e60 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	57                   	push   %edi
  800e64:	56                   	push   %esi
  800e65:	53                   	push   %ebx
  800e66:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800e69:	68 66 0d 80 00       	push   $0x800d66
  800e6e:	e8 bb 02 00 00       	call   80112e <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e73:	b8 07 00 00 00       	mov    $0x7,%eax
  800e78:	cd 30                	int    $0x30
  800e7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t ad;
	envid = sys_exofork();
	if (envid == 0) {
  800e7d:	83 c4 10             	add    $0x10,%esp
  800e80:	85 c0                	test   %eax,%eax
  800e82:	75 21                	jne    800ea5 <fork+0x45>
		
		thisenv = &envs[ENVX(sys_getenvid())];
  800e84:	e8 f0 fc ff ff       	call   800b79 <sys_getenvid>
  800e89:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e8e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e91:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e96:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  800e9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea0:	e9 5a 01 00 00       	jmp    800fff <fork+0x19f>
  800ea5:	89 c7                	mov    %eax,%edi
	}
	
	if (envid < 0)
  800ea7:	85 c0                	test   %eax,%eax
  800ea9:	79 12                	jns    800ebd <fork+0x5d>
		panic("sys_exofork: %e", envid);
  800eab:	50                   	push   %eax
  800eac:	68 85 17 80 00       	push   $0x801785
  800eb1:	6a 71                	push   $0x71
  800eb3:	68 47 17 80 00       	push   $0x801747
  800eb8:	e8 2b 02 00 00       	call   8010e8 <_panic>
  800ebd:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (ad = 0; ad < USTACKTOP; ad += PGSIZE)
		if ((uvpd[PDX(ad)] & PTE_P) && (uvpt[PGNUM(ad)] & PTE_P)
  800ec2:	89 d8                	mov    %ebx,%eax
  800ec4:	c1 e8 16             	shr    $0x16,%eax
  800ec7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ece:	a8 01                	test   $0x1,%al
  800ed0:	0f 84 b3 00 00 00    	je     800f89 <fork+0x129>
  800ed6:	89 d8                	mov    %ebx,%eax
  800ed8:	c1 e8 0c             	shr    $0xc,%eax
  800edb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ee2:	f6 c2 01             	test   $0x1,%dl
  800ee5:	0f 84 9e 00 00 00    	je     800f89 <fork+0x129>
			&& (uvpt[PGNUM(ad)] & PTE_U)) {
  800eeb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ef2:	f6 c2 04             	test   $0x4,%dl
  800ef5:	0f 84 8e 00 00 00    	je     800f89 <fork+0x129>
duppage(envid_t envid, unsigned pn)
{
	//int r;
	// LAB 4: Your code here.
	
	void *vir_addr = (void*) (pn*PGSIZE);
  800efb:	89 c6                	mov    %eax,%esi
  800efd:	c1 e6 0c             	shl    $0xc,%esi
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800f00:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f07:	f6 c2 02             	test   $0x2,%dl
  800f0a:	75 0c                	jne    800f18 <fork+0xb8>
  800f0c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f13:	f6 c4 08             	test   $0x8,%ah
  800f16:	74 5d                	je     800f75 <fork+0x115>
		if (sys_page_map(0, vir_addr, envid, vir_addr, PTE_COW|PTE_U|PTE_P) < 0)
  800f18:	83 ec 0c             	sub    $0xc,%esp
  800f1b:	68 05 08 00 00       	push   $0x805
  800f20:	56                   	push   %esi
  800f21:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f24:	56                   	push   %esi
  800f25:	6a 00                	push   $0x0
  800f27:	e8 ce fc ff ff       	call   800bfa <sys_page_map>
  800f2c:	83 c4 20             	add    $0x20,%esp
  800f2f:	85 c0                	test   %eax,%eax
  800f31:	79 14                	jns    800f47 <fork+0xe7>
			panic("page map failed");
  800f33:	83 ec 04             	sub    $0x4,%esp
  800f36:	68 95 17 80 00       	push   $0x801795
  800f3b:	6a 49                	push   $0x49
  800f3d:	68 47 17 80 00       	push   $0x801747
  800f42:	e8 a1 01 00 00       	call   8010e8 <_panic>
		if (sys_page_map(0, vir_addr, 0, vir_addr, PTE_COW|PTE_U|PTE_P) < 0)
  800f47:	83 ec 0c             	sub    $0xc,%esp
  800f4a:	68 05 08 00 00       	push   $0x805
  800f4f:	56                   	push   %esi
  800f50:	6a 00                	push   $0x0
  800f52:	56                   	push   %esi
  800f53:	6a 00                	push   $0x0
  800f55:	e8 a0 fc ff ff       	call   800bfa <sys_page_map>
  800f5a:	83 c4 20             	add    $0x20,%esp
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	79 28                	jns    800f89 <fork+0x129>
			panic("page map failed");
  800f61:	83 ec 04             	sub    $0x4,%esp
  800f64:	68 95 17 80 00       	push   $0x801795
  800f69:	6a 4b                	push   $0x4b
  800f6b:	68 47 17 80 00       	push   $0x801747
  800f70:	e8 73 01 00 00       	call   8010e8 <_panic>
	} else sys_page_map(0, vir_addr, envid, vir_addr, PTE_U|PTE_P);
  800f75:	83 ec 0c             	sub    $0xc,%esp
  800f78:	6a 05                	push   $0x5
  800f7a:	56                   	push   %esi
  800f7b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f7e:	56                   	push   %esi
  800f7f:	6a 00                	push   $0x0
  800f81:	e8 74 fc ff ff       	call   800bfa <sys_page_map>
  800f86:	83 c4 20             	add    $0x20,%esp
	}
	
	if (envid < 0)
		panic("sys_exofork: %e", envid);

	for (ad = 0; ad < USTACKTOP; ad += PGSIZE)
  800f89:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f8f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f95:	0f 85 27 ff ff ff    	jne    800ec2 <fork+0x62>
			
		}
	


	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  800f9b:	83 ec 04             	sub    $0x4,%esp
  800f9e:	6a 07                	push   $0x7
  800fa0:	68 00 f0 bf ee       	push   $0xeebff000
  800fa5:	57                   	push   %edi
  800fa6:	e8 0c fc ff ff       	call   800bb7 <sys_page_alloc>
  800fab:	83 c4 10             	add    $0x10,%esp
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	79 14                	jns    800fc6 <fork+0x166>
		panic("alloc failed");
  800fb2:	83 ec 04             	sub    $0x4,%esp
  800fb5:	68 57 17 80 00       	push   $0x801757
  800fba:	6a 7e                	push   $0x7e
  800fbc:	68 47 17 80 00       	push   $0x801747
  800fc1:	e8 22 01 00 00       	call   8010e8 <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800fc6:	83 ec 08             	sub    $0x8,%esp
  800fc9:	68 9d 11 80 00       	push   $0x80119d
  800fce:	57                   	push   %edi
  800fcf:	e8 ec fc ff ff       	call   800cc0 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  800fd4:	83 c4 08             	add    $0x8,%esp
  800fd7:	6a 02                	push   $0x2
  800fd9:	57                   	push   %edi
  800fda:	e8 9f fc ff ff       	call   800c7e <sys_env_set_status>
  800fdf:	83 c4 10             	add    $0x10,%esp
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	79 17                	jns    800ffd <fork+0x19d>
		panic("set status failed");
  800fe6:	83 ec 04             	sub    $0x4,%esp
  800fe9:	68 a5 17 80 00       	push   $0x8017a5
  800fee:	68 83 00 00 00       	push   $0x83
  800ff3:	68 47 17 80 00       	push   $0x801747
  800ff8:	e8 eb 00 00 00       	call   8010e8 <_panic>

	return envid;
  800ffd:	89 f8                	mov    %edi,%eax
	
}
  800fff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801002:	5b                   	pop    %ebx
  801003:	5e                   	pop    %esi
  801004:	5f                   	pop    %edi
  801005:	5d                   	pop    %ebp
  801006:	c3                   	ret    

00801007 <sfork>:

int
sfork(void)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80100d:	68 b7 17 80 00       	push   $0x8017b7
  801012:	68 8c 00 00 00       	push   $0x8c
  801017:	68 47 17 80 00       	push   $0x801747
  80101c:	e8 c7 00 00 00       	call   8010e8 <_panic>

00801021 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	56                   	push   %esi
  801025:	53                   	push   %ebx
  801026:	8b 75 08             	mov    0x8(%ebp),%esi
  801029:	8b 45 0c             	mov    0xc(%ebp),%eax
  80102c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  80102f:	85 f6                	test   %esi,%esi
  801031:	74 06                	je     801039 <ipc_recv+0x18>
  801033:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801039:	85 db                	test   %ebx,%ebx
  80103b:	74 06                	je     801043 <ipc_recv+0x22>
  80103d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801043:	85 c0                	test   %eax,%eax
  801045:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80104a:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  80104d:	83 ec 0c             	sub    $0xc,%esp
  801050:	50                   	push   %eax
  801051:	e8 cf fc ff ff       	call   800d25 <sys_ipc_recv>
	if (ret) return ret;
  801056:	83 c4 10             	add    $0x10,%esp
  801059:	85 c0                	test   %eax,%eax
  80105b:	75 24                	jne    801081 <ipc_recv+0x60>
	if (from_env_store)
  80105d:	85 f6                	test   %esi,%esi
  80105f:	74 0a                	je     80106b <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801061:	a1 08 20 80 00       	mov    0x802008,%eax
  801066:	8b 40 74             	mov    0x74(%eax),%eax
  801069:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  80106b:	85 db                	test   %ebx,%ebx
  80106d:	74 0a                	je     801079 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  80106f:	a1 08 20 80 00       	mov    0x802008,%eax
  801074:	8b 40 78             	mov    0x78(%eax),%eax
  801077:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801079:	a1 08 20 80 00       	mov    0x802008,%eax
  80107e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801084:	5b                   	pop    %ebx
  801085:	5e                   	pop    %esi
  801086:	5d                   	pop    %ebp
  801087:	c3                   	ret    

00801088 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	83 ec 08             	sub    $0x8,%esp
  80108e:	8b 45 10             	mov    0x10(%ebp),%eax
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801091:	85 c0                	test   %eax,%eax
  801093:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801098:	0f 44 c2             	cmove  %edx,%eax
	int success = sys_ipc_try_send(to_env, val, pg, perm) ;
  80109b:	ff 75 14             	pushl  0x14(%ebp)
  80109e:	50                   	push   %eax
  80109f:	ff 75 0c             	pushl  0xc(%ebp)
  8010a2:	ff 75 08             	pushl  0x8(%ebp)
  8010a5:	e8 58 fc ff ff       	call   800d02 <sys_ipc_try_send>
		if (success == 0) break;
		if (success != -E_IPC_NOT_RECV) 
	panic("receive fail");
		sys_yield();
	}
}
  8010aa:	83 c4 10             	add    $0x10,%esp
  8010ad:	c9                   	leave  
  8010ae:	c3                   	ret    

008010af <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010b5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8010ba:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010bd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8010c3:	8b 52 50             	mov    0x50(%edx),%edx
  8010c6:	39 ca                	cmp    %ecx,%edx
  8010c8:	75 0d                	jne    8010d7 <ipc_find_env+0x28>
			return envs[i].env_id;
  8010ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010d2:	8b 40 48             	mov    0x48(%eax),%eax
  8010d5:	eb 0f                	jmp    8010e6 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8010d7:	83 c0 01             	add    $0x1,%eax
  8010da:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010df:	75 d9                	jne    8010ba <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8010e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010e6:	5d                   	pop    %ebp
  8010e7:	c3                   	ret    

008010e8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	56                   	push   %esi
  8010ec:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010ed:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010f0:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8010f6:	e8 7e fa ff ff       	call   800b79 <sys_getenvid>
  8010fb:	83 ec 0c             	sub    $0xc,%esp
  8010fe:	ff 75 0c             	pushl  0xc(%ebp)
  801101:	ff 75 08             	pushl  0x8(%ebp)
  801104:	56                   	push   %esi
  801105:	50                   	push   %eax
  801106:	68 d0 17 80 00       	push   $0x8017d0
  80110b:	e8 d9 f0 ff ff       	call   8001e9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801110:	83 c4 18             	add    $0x18,%esp
  801113:	53                   	push   %ebx
  801114:	ff 75 10             	pushl  0x10(%ebp)
  801117:	e8 7c f0 ff ff       	call   800198 <vcprintf>
	cprintf("\n");
  80111c:	c7 04 24 78 14 80 00 	movl   $0x801478,(%esp)
  801123:	e8 c1 f0 ff ff       	call   8001e9 <cprintf>
  801128:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80112b:	cc                   	int3   
  80112c:	eb fd                	jmp    80112b <_panic+0x43>

0080112e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	83 ec 08             	sub    $0x8,%esp
	// int r;

	if (_pgfault_handler == 0) {
  801134:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  80113b:	75 2c                	jne    801169 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  80113d:	83 ec 04             	sub    $0x4,%esp
  801140:	6a 07                	push   $0x7
  801142:	68 00 f0 bf ee       	push   $0xeebff000
  801147:	6a 00                	push   $0x0
  801149:	e8 69 fa ff ff       	call   800bb7 <sys_page_alloc>
  80114e:	83 c4 10             	add    $0x10,%esp
  801151:	85 c0                	test   %eax,%eax
  801153:	79 14                	jns    801169 <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");;
  801155:	83 ec 04             	sub    $0x4,%esp
  801158:	68 f4 17 80 00       	push   $0x8017f4
  80115d:	6a 21                	push   $0x21
  80115f:	68 58 18 80 00       	push   $0x801858
  801164:	e8 7f ff ff ff       	call   8010e8 <_panic>
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801169:	8b 45 08             	mov    0x8(%ebp),%eax
  80116c:	a3 10 20 80 00       	mov    %eax,0x802010
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801171:	83 ec 08             	sub    $0x8,%esp
  801174:	68 9d 11 80 00       	push   $0x80119d
  801179:	6a 00                	push   $0x0
  80117b:	e8 40 fb ff ff       	call   800cc0 <sys_env_set_pgfault_upcall>
  801180:	83 c4 10             	add    $0x10,%esp
  801183:	85 c0                	test   %eax,%eax
  801185:	79 14                	jns    80119b <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801187:	83 ec 04             	sub    $0x4,%esp
  80118a:	68 20 18 80 00       	push   $0x801820
  80118f:	6a 26                	push   $0x26
  801191:	68 58 18 80 00       	push   $0x801858
  801196:	e8 4d ff ff ff       	call   8010e8 <_panic>
}
  80119b:	c9                   	leave  
  80119c:	c3                   	ret    

0080119d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80119d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80119e:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  8011a3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8011a5:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx #trap-time eip
  8011a8:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)
  8011ac:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax #trap-time esp-4
  8011b1:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)
  8011b5:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp
  8011b7:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8011ba:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp #eip
  8011bb:	83 c4 04             	add    $0x4,%esp
	popfl
  8011be:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8011bf:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8011c0:	c3                   	ret    
  8011c1:	66 90                	xchg   %ax,%ax
  8011c3:	66 90                	xchg   %ax,%ax
  8011c5:	66 90                	xchg   %ax,%ax
  8011c7:	66 90                	xchg   %ax,%ax
  8011c9:	66 90                	xchg   %ax,%ax
  8011cb:	66 90                	xchg   %ax,%ax
  8011cd:	66 90                	xchg   %ax,%ax
  8011cf:	90                   	nop

008011d0 <__udivdi3>:
  8011d0:	55                   	push   %ebp
  8011d1:	57                   	push   %edi
  8011d2:	56                   	push   %esi
  8011d3:	53                   	push   %ebx
  8011d4:	83 ec 1c             	sub    $0x1c,%esp
  8011d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8011db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8011df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8011e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8011e7:	85 f6                	test   %esi,%esi
  8011e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011ed:	89 ca                	mov    %ecx,%edx
  8011ef:	89 f8                	mov    %edi,%eax
  8011f1:	75 3d                	jne    801230 <__udivdi3+0x60>
  8011f3:	39 cf                	cmp    %ecx,%edi
  8011f5:	0f 87 c5 00 00 00    	ja     8012c0 <__udivdi3+0xf0>
  8011fb:	85 ff                	test   %edi,%edi
  8011fd:	89 fd                	mov    %edi,%ebp
  8011ff:	75 0b                	jne    80120c <__udivdi3+0x3c>
  801201:	b8 01 00 00 00       	mov    $0x1,%eax
  801206:	31 d2                	xor    %edx,%edx
  801208:	f7 f7                	div    %edi
  80120a:	89 c5                	mov    %eax,%ebp
  80120c:	89 c8                	mov    %ecx,%eax
  80120e:	31 d2                	xor    %edx,%edx
  801210:	f7 f5                	div    %ebp
  801212:	89 c1                	mov    %eax,%ecx
  801214:	89 d8                	mov    %ebx,%eax
  801216:	89 cf                	mov    %ecx,%edi
  801218:	f7 f5                	div    %ebp
  80121a:	89 c3                	mov    %eax,%ebx
  80121c:	89 d8                	mov    %ebx,%eax
  80121e:	89 fa                	mov    %edi,%edx
  801220:	83 c4 1c             	add    $0x1c,%esp
  801223:	5b                   	pop    %ebx
  801224:	5e                   	pop    %esi
  801225:	5f                   	pop    %edi
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    
  801228:	90                   	nop
  801229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801230:	39 ce                	cmp    %ecx,%esi
  801232:	77 74                	ja     8012a8 <__udivdi3+0xd8>
  801234:	0f bd fe             	bsr    %esi,%edi
  801237:	83 f7 1f             	xor    $0x1f,%edi
  80123a:	0f 84 98 00 00 00    	je     8012d8 <__udivdi3+0x108>
  801240:	bb 20 00 00 00       	mov    $0x20,%ebx
  801245:	89 f9                	mov    %edi,%ecx
  801247:	89 c5                	mov    %eax,%ebp
  801249:	29 fb                	sub    %edi,%ebx
  80124b:	d3 e6                	shl    %cl,%esi
  80124d:	89 d9                	mov    %ebx,%ecx
  80124f:	d3 ed                	shr    %cl,%ebp
  801251:	89 f9                	mov    %edi,%ecx
  801253:	d3 e0                	shl    %cl,%eax
  801255:	09 ee                	or     %ebp,%esi
  801257:	89 d9                	mov    %ebx,%ecx
  801259:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80125d:	89 d5                	mov    %edx,%ebp
  80125f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801263:	d3 ed                	shr    %cl,%ebp
  801265:	89 f9                	mov    %edi,%ecx
  801267:	d3 e2                	shl    %cl,%edx
  801269:	89 d9                	mov    %ebx,%ecx
  80126b:	d3 e8                	shr    %cl,%eax
  80126d:	09 c2                	or     %eax,%edx
  80126f:	89 d0                	mov    %edx,%eax
  801271:	89 ea                	mov    %ebp,%edx
  801273:	f7 f6                	div    %esi
  801275:	89 d5                	mov    %edx,%ebp
  801277:	89 c3                	mov    %eax,%ebx
  801279:	f7 64 24 0c          	mull   0xc(%esp)
  80127d:	39 d5                	cmp    %edx,%ebp
  80127f:	72 10                	jb     801291 <__udivdi3+0xc1>
  801281:	8b 74 24 08          	mov    0x8(%esp),%esi
  801285:	89 f9                	mov    %edi,%ecx
  801287:	d3 e6                	shl    %cl,%esi
  801289:	39 c6                	cmp    %eax,%esi
  80128b:	73 07                	jae    801294 <__udivdi3+0xc4>
  80128d:	39 d5                	cmp    %edx,%ebp
  80128f:	75 03                	jne    801294 <__udivdi3+0xc4>
  801291:	83 eb 01             	sub    $0x1,%ebx
  801294:	31 ff                	xor    %edi,%edi
  801296:	89 d8                	mov    %ebx,%eax
  801298:	89 fa                	mov    %edi,%edx
  80129a:	83 c4 1c             	add    $0x1c,%esp
  80129d:	5b                   	pop    %ebx
  80129e:	5e                   	pop    %esi
  80129f:	5f                   	pop    %edi
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    
  8012a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012a8:	31 ff                	xor    %edi,%edi
  8012aa:	31 db                	xor    %ebx,%ebx
  8012ac:	89 d8                	mov    %ebx,%eax
  8012ae:	89 fa                	mov    %edi,%edx
  8012b0:	83 c4 1c             	add    $0x1c,%esp
  8012b3:	5b                   	pop    %ebx
  8012b4:	5e                   	pop    %esi
  8012b5:	5f                   	pop    %edi
  8012b6:	5d                   	pop    %ebp
  8012b7:	c3                   	ret    
  8012b8:	90                   	nop
  8012b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012c0:	89 d8                	mov    %ebx,%eax
  8012c2:	f7 f7                	div    %edi
  8012c4:	31 ff                	xor    %edi,%edi
  8012c6:	89 c3                	mov    %eax,%ebx
  8012c8:	89 d8                	mov    %ebx,%eax
  8012ca:	89 fa                	mov    %edi,%edx
  8012cc:	83 c4 1c             	add    $0x1c,%esp
  8012cf:	5b                   	pop    %ebx
  8012d0:	5e                   	pop    %esi
  8012d1:	5f                   	pop    %edi
  8012d2:	5d                   	pop    %ebp
  8012d3:	c3                   	ret    
  8012d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012d8:	39 ce                	cmp    %ecx,%esi
  8012da:	72 0c                	jb     8012e8 <__udivdi3+0x118>
  8012dc:	31 db                	xor    %ebx,%ebx
  8012de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8012e2:	0f 87 34 ff ff ff    	ja     80121c <__udivdi3+0x4c>
  8012e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8012ed:	e9 2a ff ff ff       	jmp    80121c <__udivdi3+0x4c>
  8012f2:	66 90                	xchg   %ax,%ax
  8012f4:	66 90                	xchg   %ax,%ax
  8012f6:	66 90                	xchg   %ax,%ax
  8012f8:	66 90                	xchg   %ax,%ax
  8012fa:	66 90                	xchg   %ax,%ax
  8012fc:	66 90                	xchg   %ax,%ax
  8012fe:	66 90                	xchg   %ax,%ax

00801300 <__umoddi3>:
  801300:	55                   	push   %ebp
  801301:	57                   	push   %edi
  801302:	56                   	push   %esi
  801303:	53                   	push   %ebx
  801304:	83 ec 1c             	sub    $0x1c,%esp
  801307:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80130b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80130f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801313:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801317:	85 d2                	test   %edx,%edx
  801319:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80131d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801321:	89 f3                	mov    %esi,%ebx
  801323:	89 3c 24             	mov    %edi,(%esp)
  801326:	89 74 24 04          	mov    %esi,0x4(%esp)
  80132a:	75 1c                	jne    801348 <__umoddi3+0x48>
  80132c:	39 f7                	cmp    %esi,%edi
  80132e:	76 50                	jbe    801380 <__umoddi3+0x80>
  801330:	89 c8                	mov    %ecx,%eax
  801332:	89 f2                	mov    %esi,%edx
  801334:	f7 f7                	div    %edi
  801336:	89 d0                	mov    %edx,%eax
  801338:	31 d2                	xor    %edx,%edx
  80133a:	83 c4 1c             	add    $0x1c,%esp
  80133d:	5b                   	pop    %ebx
  80133e:	5e                   	pop    %esi
  80133f:	5f                   	pop    %edi
  801340:	5d                   	pop    %ebp
  801341:	c3                   	ret    
  801342:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801348:	39 f2                	cmp    %esi,%edx
  80134a:	89 d0                	mov    %edx,%eax
  80134c:	77 52                	ja     8013a0 <__umoddi3+0xa0>
  80134e:	0f bd ea             	bsr    %edx,%ebp
  801351:	83 f5 1f             	xor    $0x1f,%ebp
  801354:	75 5a                	jne    8013b0 <__umoddi3+0xb0>
  801356:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80135a:	0f 82 e0 00 00 00    	jb     801440 <__umoddi3+0x140>
  801360:	39 0c 24             	cmp    %ecx,(%esp)
  801363:	0f 86 d7 00 00 00    	jbe    801440 <__umoddi3+0x140>
  801369:	8b 44 24 08          	mov    0x8(%esp),%eax
  80136d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801371:	83 c4 1c             	add    $0x1c,%esp
  801374:	5b                   	pop    %ebx
  801375:	5e                   	pop    %esi
  801376:	5f                   	pop    %edi
  801377:	5d                   	pop    %ebp
  801378:	c3                   	ret    
  801379:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801380:	85 ff                	test   %edi,%edi
  801382:	89 fd                	mov    %edi,%ebp
  801384:	75 0b                	jne    801391 <__umoddi3+0x91>
  801386:	b8 01 00 00 00       	mov    $0x1,%eax
  80138b:	31 d2                	xor    %edx,%edx
  80138d:	f7 f7                	div    %edi
  80138f:	89 c5                	mov    %eax,%ebp
  801391:	89 f0                	mov    %esi,%eax
  801393:	31 d2                	xor    %edx,%edx
  801395:	f7 f5                	div    %ebp
  801397:	89 c8                	mov    %ecx,%eax
  801399:	f7 f5                	div    %ebp
  80139b:	89 d0                	mov    %edx,%eax
  80139d:	eb 99                	jmp    801338 <__umoddi3+0x38>
  80139f:	90                   	nop
  8013a0:	89 c8                	mov    %ecx,%eax
  8013a2:	89 f2                	mov    %esi,%edx
  8013a4:	83 c4 1c             	add    $0x1c,%esp
  8013a7:	5b                   	pop    %ebx
  8013a8:	5e                   	pop    %esi
  8013a9:	5f                   	pop    %edi
  8013aa:	5d                   	pop    %ebp
  8013ab:	c3                   	ret    
  8013ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013b0:	8b 34 24             	mov    (%esp),%esi
  8013b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8013b8:	89 e9                	mov    %ebp,%ecx
  8013ba:	29 ef                	sub    %ebp,%edi
  8013bc:	d3 e0                	shl    %cl,%eax
  8013be:	89 f9                	mov    %edi,%ecx
  8013c0:	89 f2                	mov    %esi,%edx
  8013c2:	d3 ea                	shr    %cl,%edx
  8013c4:	89 e9                	mov    %ebp,%ecx
  8013c6:	09 c2                	or     %eax,%edx
  8013c8:	89 d8                	mov    %ebx,%eax
  8013ca:	89 14 24             	mov    %edx,(%esp)
  8013cd:	89 f2                	mov    %esi,%edx
  8013cf:	d3 e2                	shl    %cl,%edx
  8013d1:	89 f9                	mov    %edi,%ecx
  8013d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8013db:	d3 e8                	shr    %cl,%eax
  8013dd:	89 e9                	mov    %ebp,%ecx
  8013df:	89 c6                	mov    %eax,%esi
  8013e1:	d3 e3                	shl    %cl,%ebx
  8013e3:	89 f9                	mov    %edi,%ecx
  8013e5:	89 d0                	mov    %edx,%eax
  8013e7:	d3 e8                	shr    %cl,%eax
  8013e9:	89 e9                	mov    %ebp,%ecx
  8013eb:	09 d8                	or     %ebx,%eax
  8013ed:	89 d3                	mov    %edx,%ebx
  8013ef:	89 f2                	mov    %esi,%edx
  8013f1:	f7 34 24             	divl   (%esp)
  8013f4:	89 d6                	mov    %edx,%esi
  8013f6:	d3 e3                	shl    %cl,%ebx
  8013f8:	f7 64 24 04          	mull   0x4(%esp)
  8013fc:	39 d6                	cmp    %edx,%esi
  8013fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801402:	89 d1                	mov    %edx,%ecx
  801404:	89 c3                	mov    %eax,%ebx
  801406:	72 08                	jb     801410 <__umoddi3+0x110>
  801408:	75 11                	jne    80141b <__umoddi3+0x11b>
  80140a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80140e:	73 0b                	jae    80141b <__umoddi3+0x11b>
  801410:	2b 44 24 04          	sub    0x4(%esp),%eax
  801414:	1b 14 24             	sbb    (%esp),%edx
  801417:	89 d1                	mov    %edx,%ecx
  801419:	89 c3                	mov    %eax,%ebx
  80141b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80141f:	29 da                	sub    %ebx,%edx
  801421:	19 ce                	sbb    %ecx,%esi
  801423:	89 f9                	mov    %edi,%ecx
  801425:	89 f0                	mov    %esi,%eax
  801427:	d3 e0                	shl    %cl,%eax
  801429:	89 e9                	mov    %ebp,%ecx
  80142b:	d3 ea                	shr    %cl,%edx
  80142d:	89 e9                	mov    %ebp,%ecx
  80142f:	d3 ee                	shr    %cl,%esi
  801431:	09 d0                	or     %edx,%eax
  801433:	89 f2                	mov    %esi,%edx
  801435:	83 c4 1c             	add    $0x1c,%esp
  801438:	5b                   	pop    %ebx
  801439:	5e                   	pop    %esi
  80143a:	5f                   	pop    %edi
  80143b:	5d                   	pop    %ebp
  80143c:	c3                   	ret    
  80143d:	8d 76 00             	lea    0x0(%esi),%esi
  801440:	29 f9                	sub    %edi,%ecx
  801442:	19 d6                	sbb    %edx,%esi
  801444:	89 74 24 04          	mov    %esi,0x4(%esp)
  801448:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80144c:	e9 18 ff ff ff       	jmp    801369 <__umoddi3+0x69>
