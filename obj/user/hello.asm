
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 40 00 00 00       	call   800071 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 c0 0f 80 00       	push   $0x800fc0
  80003e:	e8 19 01 00 00       	call   80015c <cprintf>
	cprintf("thisenv: %x\n", thisenv);
  800043:	83 c4 08             	add    $0x8,%esp
  800046:	ff 35 04 20 80 00    	pushl  0x802004
  80004c:	68 ce 0f 80 00       	push   $0x800fce
  800051:	e8 06 01 00 00       	call   80015c <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800056:	a1 04 20 80 00       	mov    0x802004,%eax
  80005b:	8b 40 48             	mov    0x48(%eax),%eax
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	50                   	push   %eax
  800062:	68 db 0f 80 00       	push   $0x800fdb
  800067:	e8 f0 00 00 00       	call   80015c <cprintf>
}
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	c9                   	leave  
  800070:	c3                   	ret    

00800071 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800071:	55                   	push   %ebp
  800072:	89 e5                	mov    %esp,%ebp
  800074:	56                   	push   %esi
  800075:	53                   	push   %ebx
  800076:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800079:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  80007c:	e8 6b 0a 00 00       	call   800aec <sys_getenvid>
  800081:	25 ff 03 00 00       	and    $0x3ff,%eax
  800086:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800089:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008e:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800093:	85 db                	test   %ebx,%ebx
  800095:	7e 07                	jle    80009e <libmain+0x2d>
		binaryname = argv[0];
  800097:	8b 06                	mov    (%esi),%eax
  800099:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009e:	83 ec 08             	sub    $0x8,%esp
  8000a1:	56                   	push   %esi
  8000a2:	53                   	push   %ebx
  8000a3:	e8 8b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a8:	e8 0a 00 00 00       	call   8000b7 <exit>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000bd:	6a 00                	push   $0x0
  8000bf:	e8 e7 09 00 00       	call   800aab <sys_env_destroy>
}
  8000c4:	83 c4 10             	add    $0x10,%esp
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    

008000c9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	53                   	push   %ebx
  8000cd:	83 ec 04             	sub    $0x4,%esp
  8000d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d3:	8b 13                	mov    (%ebx),%edx
  8000d5:	8d 42 01             	lea    0x1(%edx),%eax
  8000d8:	89 03                	mov    %eax,(%ebx)
  8000da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000dd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e6:	75 1a                	jne    800102 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000e8:	83 ec 08             	sub    $0x8,%esp
  8000eb:	68 ff 00 00 00       	push   $0xff
  8000f0:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f3:	50                   	push   %eax
  8000f4:	e8 75 09 00 00       	call   800a6e <sys_cputs>
		b->idx = 0;
  8000f9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ff:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800102:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800106:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800109:	c9                   	leave  
  80010a:	c3                   	ret    

0080010b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800114:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011b:	00 00 00 
	b.cnt = 0;
  80011e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800125:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800128:	ff 75 0c             	pushl  0xc(%ebp)
  80012b:	ff 75 08             	pushl  0x8(%ebp)
  80012e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800134:	50                   	push   %eax
  800135:	68 c9 00 80 00       	push   $0x8000c9
  80013a:	e8 54 01 00 00       	call   800293 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800148:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014e:	50                   	push   %eax
  80014f:	e8 1a 09 00 00       	call   800a6e <sys_cputs>

	return b.cnt;
}
  800154:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800162:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800165:	50                   	push   %eax
  800166:	ff 75 08             	pushl  0x8(%ebp)
  800169:	e8 9d ff ff ff       	call   80010b <vcprintf>
	va_end(ap);

	return cnt;
}
  80016e:	c9                   	leave  
  80016f:	c3                   	ret    

00800170 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 1c             	sub    $0x1c,%esp
  800179:	89 c7                	mov    %eax,%edi
  80017b:	89 d6                	mov    %edx,%esi
  80017d:	8b 45 08             	mov    0x8(%ebp),%eax
  800180:	8b 55 0c             	mov    0xc(%ebp),%edx
  800183:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800186:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800189:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80018c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800191:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800194:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800197:	39 d3                	cmp    %edx,%ebx
  800199:	72 05                	jb     8001a0 <printnum+0x30>
  80019b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80019e:	77 45                	ja     8001e5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a0:	83 ec 0c             	sub    $0xc,%esp
  8001a3:	ff 75 18             	pushl  0x18(%ebp)
  8001a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001ac:	53                   	push   %ebx
  8001ad:	ff 75 10             	pushl  0x10(%ebp)
  8001b0:	83 ec 08             	sub    $0x8,%esp
  8001b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001bc:	ff 75 d8             	pushl  -0x28(%ebp)
  8001bf:	e8 5c 0b 00 00       	call   800d20 <__udivdi3>
  8001c4:	83 c4 18             	add    $0x18,%esp
  8001c7:	52                   	push   %edx
  8001c8:	50                   	push   %eax
  8001c9:	89 f2                	mov    %esi,%edx
  8001cb:	89 f8                	mov    %edi,%eax
  8001cd:	e8 9e ff ff ff       	call   800170 <printnum>
  8001d2:	83 c4 20             	add    $0x20,%esp
  8001d5:	eb 18                	jmp    8001ef <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d7:	83 ec 08             	sub    $0x8,%esp
  8001da:	56                   	push   %esi
  8001db:	ff 75 18             	pushl  0x18(%ebp)
  8001de:	ff d7                	call   *%edi
  8001e0:	83 c4 10             	add    $0x10,%esp
  8001e3:	eb 03                	jmp    8001e8 <printnum+0x78>
  8001e5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001e8:	83 eb 01             	sub    $0x1,%ebx
  8001eb:	85 db                	test   %ebx,%ebx
  8001ed:	7f e8                	jg     8001d7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001ef:	83 ec 08             	sub    $0x8,%esp
  8001f2:	56                   	push   %esi
  8001f3:	83 ec 04             	sub    $0x4,%esp
  8001f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f9:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fc:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ff:	ff 75 d8             	pushl  -0x28(%ebp)
  800202:	e8 49 0c 00 00       	call   800e50 <__umoddi3>
  800207:	83 c4 14             	add    $0x14,%esp
  80020a:	0f be 80 fc 0f 80 00 	movsbl 0x800ffc(%eax),%eax
  800211:	50                   	push   %eax
  800212:	ff d7                	call   *%edi
}
  800214:	83 c4 10             	add    $0x10,%esp
  800217:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021a:	5b                   	pop    %ebx
  80021b:	5e                   	pop    %esi
  80021c:	5f                   	pop    %edi
  80021d:	5d                   	pop    %ebp
  80021e:	c3                   	ret    

0080021f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800222:	83 fa 01             	cmp    $0x1,%edx
  800225:	7e 0e                	jle    800235 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800227:	8b 10                	mov    (%eax),%edx
  800229:	8d 4a 08             	lea    0x8(%edx),%ecx
  80022c:	89 08                	mov    %ecx,(%eax)
  80022e:	8b 02                	mov    (%edx),%eax
  800230:	8b 52 04             	mov    0x4(%edx),%edx
  800233:	eb 22                	jmp    800257 <getuint+0x38>
	else if (lflag)
  800235:	85 d2                	test   %edx,%edx
  800237:	74 10                	je     800249 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800239:	8b 10                	mov    (%eax),%edx
  80023b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023e:	89 08                	mov    %ecx,(%eax)
  800240:	8b 02                	mov    (%edx),%eax
  800242:	ba 00 00 00 00       	mov    $0x0,%edx
  800247:	eb 0e                	jmp    800257 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800249:	8b 10                	mov    (%eax),%edx
  80024b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80024e:	89 08                	mov    %ecx,(%eax)
  800250:	8b 02                	mov    (%edx),%eax
  800252:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800257:	5d                   	pop    %ebp
  800258:	c3                   	ret    

00800259 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800259:	55                   	push   %ebp
  80025a:	89 e5                	mov    %esp,%ebp
  80025c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80025f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800263:	8b 10                	mov    (%eax),%edx
  800265:	3b 50 04             	cmp    0x4(%eax),%edx
  800268:	73 0a                	jae    800274 <sprintputch+0x1b>
		*b->buf++ = ch;
  80026a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80026d:	89 08                	mov    %ecx,(%eax)
  80026f:	8b 45 08             	mov    0x8(%ebp),%eax
  800272:	88 02                	mov    %al,(%edx)
}
  800274:	5d                   	pop    %ebp
  800275:	c3                   	ret    

00800276 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
  800279:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80027c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80027f:	50                   	push   %eax
  800280:	ff 75 10             	pushl  0x10(%ebp)
  800283:	ff 75 0c             	pushl  0xc(%ebp)
  800286:	ff 75 08             	pushl  0x8(%ebp)
  800289:	e8 05 00 00 00       	call   800293 <vprintfmt>
	va_end(ap);
}
  80028e:	83 c4 10             	add    $0x10,%esp
  800291:	c9                   	leave  
  800292:	c3                   	ret    

00800293 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	57                   	push   %edi
  800297:	56                   	push   %esi
  800298:	53                   	push   %ebx
  800299:	83 ec 2c             	sub    $0x2c,%esp
  80029c:	8b 75 08             	mov    0x8(%ebp),%esi
  80029f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a5:	eb 1d                	jmp    8002c4 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  8002a7:	85 c0                	test   %eax,%eax
  8002a9:	75 0f                	jne    8002ba <vprintfmt+0x27>
				csa = 0x0700;
  8002ab:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  8002b2:	07 00 00 
				return;
  8002b5:	e9 c4 03 00 00       	jmp    80067e <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  8002ba:	83 ec 08             	sub    $0x8,%esp
  8002bd:	53                   	push   %ebx
  8002be:	50                   	push   %eax
  8002bf:	ff d6                	call   *%esi
  8002c1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002c4:	83 c7 01             	add    $0x1,%edi
  8002c7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002cb:	83 f8 25             	cmp    $0x25,%eax
  8002ce:	75 d7                	jne    8002a7 <vprintfmt+0x14>
  8002d0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002d4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002db:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002e2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ee:	eb 07                	jmp    8002f7 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002f3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f7:	8d 47 01             	lea    0x1(%edi),%eax
  8002fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fd:	0f b6 07             	movzbl (%edi),%eax
  800300:	0f b6 c8             	movzbl %al,%ecx
  800303:	83 e8 23             	sub    $0x23,%eax
  800306:	3c 55                	cmp    $0x55,%al
  800308:	0f 87 55 03 00 00    	ja     800663 <vprintfmt+0x3d0>
  80030e:	0f b6 c0             	movzbl %al,%eax
  800311:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  800318:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80031b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80031f:	eb d6                	jmp    8002f7 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800321:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800324:	b8 00 00 00 00       	mov    $0x0,%eax
  800329:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80032c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80032f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800333:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800336:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800339:	83 fa 09             	cmp    $0x9,%edx
  80033c:	77 39                	ja     800377 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80033e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800341:	eb e9                	jmp    80032c <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800343:	8b 45 14             	mov    0x14(%ebp),%eax
  800346:	8d 48 04             	lea    0x4(%eax),%ecx
  800349:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80034c:	8b 00                	mov    (%eax),%eax
  80034e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800354:	eb 27                	jmp    80037d <vprintfmt+0xea>
  800356:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800359:	85 c0                	test   %eax,%eax
  80035b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800360:	0f 49 c8             	cmovns %eax,%ecx
  800363:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800369:	eb 8c                	jmp    8002f7 <vprintfmt+0x64>
  80036b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80036e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800375:	eb 80                	jmp    8002f7 <vprintfmt+0x64>
  800377:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80037a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80037d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800381:	0f 89 70 ff ff ff    	jns    8002f7 <vprintfmt+0x64>
				width = precision, precision = -1;
  800387:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80038a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80038d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800394:	e9 5e ff ff ff       	jmp    8002f7 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800399:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80039f:	e9 53 ff ff ff       	jmp    8002f7 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a7:	8d 50 04             	lea    0x4(%eax),%edx
  8003aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ad:	83 ec 08             	sub    $0x8,%esp
  8003b0:	53                   	push   %ebx
  8003b1:	ff 30                	pushl  (%eax)
  8003b3:	ff d6                	call   *%esi
			break;
  8003b5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003bb:	e9 04 ff ff ff       	jmp    8002c4 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c3:	8d 50 04             	lea    0x4(%eax),%edx
  8003c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c9:	8b 00                	mov    (%eax),%eax
  8003cb:	99                   	cltd   
  8003cc:	31 d0                	xor    %edx,%eax
  8003ce:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d0:	83 f8 08             	cmp    $0x8,%eax
  8003d3:	7f 0b                	jg     8003e0 <vprintfmt+0x14d>
  8003d5:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  8003dc:	85 d2                	test   %edx,%edx
  8003de:	75 18                	jne    8003f8 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  8003e0:	50                   	push   %eax
  8003e1:	68 14 10 80 00       	push   $0x801014
  8003e6:	53                   	push   %ebx
  8003e7:	56                   	push   %esi
  8003e8:	e8 89 fe ff ff       	call   800276 <printfmt>
  8003ed:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003f3:	e9 cc fe ff ff       	jmp    8002c4 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8003f8:	52                   	push   %edx
  8003f9:	68 1d 10 80 00       	push   $0x80101d
  8003fe:	53                   	push   %ebx
  8003ff:	56                   	push   %esi
  800400:	e8 71 fe ff ff       	call   800276 <printfmt>
  800405:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040b:	e9 b4 fe ff ff       	jmp    8002c4 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800410:	8b 45 14             	mov    0x14(%ebp),%eax
  800413:	8d 50 04             	lea    0x4(%eax),%edx
  800416:	89 55 14             	mov    %edx,0x14(%ebp)
  800419:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80041b:	85 ff                	test   %edi,%edi
  80041d:	b8 0d 10 80 00       	mov    $0x80100d,%eax
  800422:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800425:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800429:	0f 8e 94 00 00 00    	jle    8004c3 <vprintfmt+0x230>
  80042f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800433:	0f 84 98 00 00 00    	je     8004d1 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800439:	83 ec 08             	sub    $0x8,%esp
  80043c:	ff 75 d0             	pushl  -0x30(%ebp)
  80043f:	57                   	push   %edi
  800440:	e8 c1 02 00 00       	call   800706 <strnlen>
  800445:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800448:	29 c1                	sub    %eax,%ecx
  80044a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80044d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800450:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800454:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800457:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80045a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80045c:	eb 0f                	jmp    80046d <vprintfmt+0x1da>
					putch(padc, putdat);
  80045e:	83 ec 08             	sub    $0x8,%esp
  800461:	53                   	push   %ebx
  800462:	ff 75 e0             	pushl  -0x20(%ebp)
  800465:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800467:	83 ef 01             	sub    $0x1,%edi
  80046a:	83 c4 10             	add    $0x10,%esp
  80046d:	85 ff                	test   %edi,%edi
  80046f:	7f ed                	jg     80045e <vprintfmt+0x1cb>
  800471:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800474:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800477:	85 c9                	test   %ecx,%ecx
  800479:	b8 00 00 00 00       	mov    $0x0,%eax
  80047e:	0f 49 c1             	cmovns %ecx,%eax
  800481:	29 c1                	sub    %eax,%ecx
  800483:	89 75 08             	mov    %esi,0x8(%ebp)
  800486:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800489:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80048c:	89 cb                	mov    %ecx,%ebx
  80048e:	eb 4d                	jmp    8004dd <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800490:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800494:	74 1b                	je     8004b1 <vprintfmt+0x21e>
  800496:	0f be c0             	movsbl %al,%eax
  800499:	83 e8 20             	sub    $0x20,%eax
  80049c:	83 f8 5e             	cmp    $0x5e,%eax
  80049f:	76 10                	jbe    8004b1 <vprintfmt+0x21e>
					putch('?', putdat);
  8004a1:	83 ec 08             	sub    $0x8,%esp
  8004a4:	ff 75 0c             	pushl  0xc(%ebp)
  8004a7:	6a 3f                	push   $0x3f
  8004a9:	ff 55 08             	call   *0x8(%ebp)
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	eb 0d                	jmp    8004be <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	ff 75 0c             	pushl  0xc(%ebp)
  8004b7:	52                   	push   %edx
  8004b8:	ff 55 08             	call   *0x8(%ebp)
  8004bb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004be:	83 eb 01             	sub    $0x1,%ebx
  8004c1:	eb 1a                	jmp    8004dd <vprintfmt+0x24a>
  8004c3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004cc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004cf:	eb 0c                	jmp    8004dd <vprintfmt+0x24a>
  8004d1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004da:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004dd:	83 c7 01             	add    $0x1,%edi
  8004e0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004e4:	0f be d0             	movsbl %al,%edx
  8004e7:	85 d2                	test   %edx,%edx
  8004e9:	74 23                	je     80050e <vprintfmt+0x27b>
  8004eb:	85 f6                	test   %esi,%esi
  8004ed:	78 a1                	js     800490 <vprintfmt+0x1fd>
  8004ef:	83 ee 01             	sub    $0x1,%esi
  8004f2:	79 9c                	jns    800490 <vprintfmt+0x1fd>
  8004f4:	89 df                	mov    %ebx,%edi
  8004f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fc:	eb 18                	jmp    800516 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	53                   	push   %ebx
  800502:	6a 20                	push   $0x20
  800504:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800506:	83 ef 01             	sub    $0x1,%edi
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	eb 08                	jmp    800516 <vprintfmt+0x283>
  80050e:	89 df                	mov    %ebx,%edi
  800510:	8b 75 08             	mov    0x8(%ebp),%esi
  800513:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800516:	85 ff                	test   %edi,%edi
  800518:	7f e4                	jg     8004fe <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051d:	e9 a2 fd ff ff       	jmp    8002c4 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800522:	83 fa 01             	cmp    $0x1,%edx
  800525:	7e 16                	jle    80053d <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  800527:	8b 45 14             	mov    0x14(%ebp),%eax
  80052a:	8d 50 08             	lea    0x8(%eax),%edx
  80052d:	89 55 14             	mov    %edx,0x14(%ebp)
  800530:	8b 50 04             	mov    0x4(%eax),%edx
  800533:	8b 00                	mov    (%eax),%eax
  800535:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800538:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80053b:	eb 32                	jmp    80056f <vprintfmt+0x2dc>
	else if (lflag)
  80053d:	85 d2                	test   %edx,%edx
  80053f:	74 18                	je     800559 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  800541:	8b 45 14             	mov    0x14(%ebp),%eax
  800544:	8d 50 04             	lea    0x4(%eax),%edx
  800547:	89 55 14             	mov    %edx,0x14(%ebp)
  80054a:	8b 00                	mov    (%eax),%eax
  80054c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054f:	89 c1                	mov    %eax,%ecx
  800551:	c1 f9 1f             	sar    $0x1f,%ecx
  800554:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800557:	eb 16                	jmp    80056f <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8d 50 04             	lea    0x4(%eax),%edx
  80055f:	89 55 14             	mov    %edx,0x14(%ebp)
  800562:	8b 00                	mov    (%eax),%eax
  800564:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800567:	89 c1                	mov    %eax,%ecx
  800569:	c1 f9 1f             	sar    $0x1f,%ecx
  80056c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80056f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800572:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800575:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80057a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80057e:	79 74                	jns    8005f4 <vprintfmt+0x361>
				putch('-', putdat);
  800580:	83 ec 08             	sub    $0x8,%esp
  800583:	53                   	push   %ebx
  800584:	6a 2d                	push   $0x2d
  800586:	ff d6                	call   *%esi
				num = -(long long) num;
  800588:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80058b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80058e:	f7 d8                	neg    %eax
  800590:	83 d2 00             	adc    $0x0,%edx
  800593:	f7 da                	neg    %edx
  800595:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800598:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80059d:	eb 55                	jmp    8005f4 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80059f:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a2:	e8 78 fc ff ff       	call   80021f <getuint>
			base = 10;
  8005a7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005ac:	eb 46                	jmp    8005f4 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  8005ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b1:	e8 69 fc ff ff       	call   80021f <getuint>
      base = 8;
  8005b6:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  8005bb:	eb 37                	jmp    8005f4 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  8005bd:	83 ec 08             	sub    $0x8,%esp
  8005c0:	53                   	push   %ebx
  8005c1:	6a 30                	push   $0x30
  8005c3:	ff d6                	call   *%esi
			putch('x', putdat);
  8005c5:	83 c4 08             	add    $0x8,%esp
  8005c8:	53                   	push   %ebx
  8005c9:	6a 78                	push   $0x78
  8005cb:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8d 50 04             	lea    0x4(%eax),%edx
  8005d3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005d6:	8b 00                	mov    (%eax),%eax
  8005d8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005dd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005e0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005e5:	eb 0d                	jmp    8005f4 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ea:	e8 30 fc ff ff       	call   80021f <getuint>
			base = 16;
  8005ef:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005f4:	83 ec 0c             	sub    $0xc,%esp
  8005f7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005fb:	57                   	push   %edi
  8005fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ff:	51                   	push   %ecx
  800600:	52                   	push   %edx
  800601:	50                   	push   %eax
  800602:	89 da                	mov    %ebx,%edx
  800604:	89 f0                	mov    %esi,%eax
  800606:	e8 65 fb ff ff       	call   800170 <printnum>
			break;
  80060b:	83 c4 20             	add    $0x20,%esp
  80060e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800611:	e9 ae fc ff ff       	jmp    8002c4 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800616:	83 ec 08             	sub    $0x8,%esp
  800619:	53                   	push   %ebx
  80061a:	51                   	push   %ecx
  80061b:	ff d6                	call   *%esi
			break;
  80061d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800623:	e9 9c fc ff ff       	jmp    8002c4 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800628:	83 fa 01             	cmp    $0x1,%edx
  80062b:	7e 0d                	jle    80063a <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8d 50 08             	lea    0x8(%eax),%edx
  800633:	89 55 14             	mov    %edx,0x14(%ebp)
  800636:	8b 00                	mov    (%eax),%eax
  800638:	eb 1c                	jmp    800656 <vprintfmt+0x3c3>
	else if (lflag)
  80063a:	85 d2                	test   %edx,%edx
  80063c:	74 0d                	je     80064b <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8d 50 04             	lea    0x4(%eax),%edx
  800644:	89 55 14             	mov    %edx,0x14(%ebp)
  800647:	8b 00                	mov    (%eax),%eax
  800649:	eb 0b                	jmp    800656 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8d 50 04             	lea    0x4(%eax),%edx
  800651:	89 55 14             	mov    %edx,0x14(%ebp)
  800654:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  800656:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  80065e:	e9 61 fc ff ff       	jmp    8002c4 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	53                   	push   %ebx
  800667:	6a 25                	push   $0x25
  800669:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80066b:	83 c4 10             	add    $0x10,%esp
  80066e:	eb 03                	jmp    800673 <vprintfmt+0x3e0>
  800670:	83 ef 01             	sub    $0x1,%edi
  800673:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800677:	75 f7                	jne    800670 <vprintfmt+0x3dd>
  800679:	e9 46 fc ff ff       	jmp    8002c4 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  80067e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800681:	5b                   	pop    %ebx
  800682:	5e                   	pop    %esi
  800683:	5f                   	pop    %edi
  800684:	5d                   	pop    %ebp
  800685:	c3                   	ret    

00800686 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800686:	55                   	push   %ebp
  800687:	89 e5                	mov    %esp,%ebp
  800689:	83 ec 18             	sub    $0x18,%esp
  80068c:	8b 45 08             	mov    0x8(%ebp),%eax
  80068f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800692:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800695:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800699:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80069c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a3:	85 c0                	test   %eax,%eax
  8006a5:	74 26                	je     8006cd <vsnprintf+0x47>
  8006a7:	85 d2                	test   %edx,%edx
  8006a9:	7e 22                	jle    8006cd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ab:	ff 75 14             	pushl  0x14(%ebp)
  8006ae:	ff 75 10             	pushl  0x10(%ebp)
  8006b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b4:	50                   	push   %eax
  8006b5:	68 59 02 80 00       	push   $0x800259
  8006ba:	e8 d4 fb ff ff       	call   800293 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c8:	83 c4 10             	add    $0x10,%esp
  8006cb:	eb 05                	jmp    8006d2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006d2:	c9                   	leave  
  8006d3:	c3                   	ret    

008006d4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006da:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006dd:	50                   	push   %eax
  8006de:	ff 75 10             	pushl  0x10(%ebp)
  8006e1:	ff 75 0c             	pushl  0xc(%ebp)
  8006e4:	ff 75 08             	pushl  0x8(%ebp)
  8006e7:	e8 9a ff ff ff       	call   800686 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006ec:	c9                   	leave  
  8006ed:	c3                   	ret    

008006ee <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ee:	55                   	push   %ebp
  8006ef:	89 e5                	mov    %esp,%ebp
  8006f1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f9:	eb 03                	jmp    8006fe <strlen+0x10>
		n++;
  8006fb:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fe:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800702:	75 f7                	jne    8006fb <strlen+0xd>
		n++;
	return n;
}
  800704:	5d                   	pop    %ebp
  800705:	c3                   	ret    

00800706 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80070c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070f:	ba 00 00 00 00       	mov    $0x0,%edx
  800714:	eb 03                	jmp    800719 <strnlen+0x13>
		n++;
  800716:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800719:	39 c2                	cmp    %eax,%edx
  80071b:	74 08                	je     800725 <strnlen+0x1f>
  80071d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800721:	75 f3                	jne    800716 <strnlen+0x10>
  800723:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800725:	5d                   	pop    %ebp
  800726:	c3                   	ret    

00800727 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	53                   	push   %ebx
  80072b:	8b 45 08             	mov    0x8(%ebp),%eax
  80072e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800731:	89 c2                	mov    %eax,%edx
  800733:	83 c2 01             	add    $0x1,%edx
  800736:	83 c1 01             	add    $0x1,%ecx
  800739:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80073d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800740:	84 db                	test   %bl,%bl
  800742:	75 ef                	jne    800733 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800744:	5b                   	pop    %ebx
  800745:	5d                   	pop    %ebp
  800746:	c3                   	ret    

00800747 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	53                   	push   %ebx
  80074b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80074e:	53                   	push   %ebx
  80074f:	e8 9a ff ff ff       	call   8006ee <strlen>
  800754:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800757:	ff 75 0c             	pushl  0xc(%ebp)
  80075a:	01 d8                	add    %ebx,%eax
  80075c:	50                   	push   %eax
  80075d:	e8 c5 ff ff ff       	call   800727 <strcpy>
	return dst;
}
  800762:	89 d8                	mov    %ebx,%eax
  800764:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800767:	c9                   	leave  
  800768:	c3                   	ret    

00800769 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800769:	55                   	push   %ebp
  80076a:	89 e5                	mov    %esp,%ebp
  80076c:	56                   	push   %esi
  80076d:	53                   	push   %ebx
  80076e:	8b 75 08             	mov    0x8(%ebp),%esi
  800771:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800774:	89 f3                	mov    %esi,%ebx
  800776:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800779:	89 f2                	mov    %esi,%edx
  80077b:	eb 0f                	jmp    80078c <strncpy+0x23>
		*dst++ = *src;
  80077d:	83 c2 01             	add    $0x1,%edx
  800780:	0f b6 01             	movzbl (%ecx),%eax
  800783:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800786:	80 39 01             	cmpb   $0x1,(%ecx)
  800789:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078c:	39 da                	cmp    %ebx,%edx
  80078e:	75 ed                	jne    80077d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800790:	89 f0                	mov    %esi,%eax
  800792:	5b                   	pop    %ebx
  800793:	5e                   	pop    %esi
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	56                   	push   %esi
  80079a:	53                   	push   %ebx
  80079b:	8b 75 08             	mov    0x8(%ebp),%esi
  80079e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a1:	8b 55 10             	mov    0x10(%ebp),%edx
  8007a4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a6:	85 d2                	test   %edx,%edx
  8007a8:	74 21                	je     8007cb <strlcpy+0x35>
  8007aa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007ae:	89 f2                	mov    %esi,%edx
  8007b0:	eb 09                	jmp    8007bb <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007b2:	83 c2 01             	add    $0x1,%edx
  8007b5:	83 c1 01             	add    $0x1,%ecx
  8007b8:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007bb:	39 c2                	cmp    %eax,%edx
  8007bd:	74 09                	je     8007c8 <strlcpy+0x32>
  8007bf:	0f b6 19             	movzbl (%ecx),%ebx
  8007c2:	84 db                	test   %bl,%bl
  8007c4:	75 ec                	jne    8007b2 <strlcpy+0x1c>
  8007c6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007c8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007cb:	29 f0                	sub    %esi,%eax
}
  8007cd:	5b                   	pop    %ebx
  8007ce:	5e                   	pop    %esi
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007da:	eb 06                	jmp    8007e2 <strcmp+0x11>
		p++, q++;
  8007dc:	83 c1 01             	add    $0x1,%ecx
  8007df:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007e2:	0f b6 01             	movzbl (%ecx),%eax
  8007e5:	84 c0                	test   %al,%al
  8007e7:	74 04                	je     8007ed <strcmp+0x1c>
  8007e9:	3a 02                	cmp    (%edx),%al
  8007eb:	74 ef                	je     8007dc <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ed:	0f b6 c0             	movzbl %al,%eax
  8007f0:	0f b6 12             	movzbl (%edx),%edx
  8007f3:	29 d0                	sub    %edx,%eax
}
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	53                   	push   %ebx
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800801:	89 c3                	mov    %eax,%ebx
  800803:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800806:	eb 06                	jmp    80080e <strncmp+0x17>
		n--, p++, q++;
  800808:	83 c0 01             	add    $0x1,%eax
  80080b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80080e:	39 d8                	cmp    %ebx,%eax
  800810:	74 15                	je     800827 <strncmp+0x30>
  800812:	0f b6 08             	movzbl (%eax),%ecx
  800815:	84 c9                	test   %cl,%cl
  800817:	74 04                	je     80081d <strncmp+0x26>
  800819:	3a 0a                	cmp    (%edx),%cl
  80081b:	74 eb                	je     800808 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80081d:	0f b6 00             	movzbl (%eax),%eax
  800820:	0f b6 12             	movzbl (%edx),%edx
  800823:	29 d0                	sub    %edx,%eax
  800825:	eb 05                	jmp    80082c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800827:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80082c:	5b                   	pop    %ebx
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	8b 45 08             	mov    0x8(%ebp),%eax
  800835:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800839:	eb 07                	jmp    800842 <strchr+0x13>
		if (*s == c)
  80083b:	38 ca                	cmp    %cl,%dl
  80083d:	74 0f                	je     80084e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80083f:	83 c0 01             	add    $0x1,%eax
  800842:	0f b6 10             	movzbl (%eax),%edx
  800845:	84 d2                	test   %dl,%dl
  800847:	75 f2                	jne    80083b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800849:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 45 08             	mov    0x8(%ebp),%eax
  800856:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80085a:	eb 03                	jmp    80085f <strfind+0xf>
  80085c:	83 c0 01             	add    $0x1,%eax
  80085f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800862:	38 ca                	cmp    %cl,%dl
  800864:	74 04                	je     80086a <strfind+0x1a>
  800866:	84 d2                	test   %dl,%dl
  800868:	75 f2                	jne    80085c <strfind+0xc>
			break;
	return (char *) s;
}
  80086a:	5d                   	pop    %ebp
  80086b:	c3                   	ret    

0080086c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	57                   	push   %edi
  800870:	56                   	push   %esi
  800871:	53                   	push   %ebx
  800872:	8b 7d 08             	mov    0x8(%ebp),%edi
  800875:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800878:	85 c9                	test   %ecx,%ecx
  80087a:	74 36                	je     8008b2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80087c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800882:	75 28                	jne    8008ac <memset+0x40>
  800884:	f6 c1 03             	test   $0x3,%cl
  800887:	75 23                	jne    8008ac <memset+0x40>
		c &= 0xFF;
  800889:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80088d:	89 d3                	mov    %edx,%ebx
  80088f:	c1 e3 08             	shl    $0x8,%ebx
  800892:	89 d6                	mov    %edx,%esi
  800894:	c1 e6 18             	shl    $0x18,%esi
  800897:	89 d0                	mov    %edx,%eax
  800899:	c1 e0 10             	shl    $0x10,%eax
  80089c:	09 f0                	or     %esi,%eax
  80089e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008a0:	89 d8                	mov    %ebx,%eax
  8008a2:	09 d0                	or     %edx,%eax
  8008a4:	c1 e9 02             	shr    $0x2,%ecx
  8008a7:	fc                   	cld    
  8008a8:	f3 ab                	rep stos %eax,%es:(%edi)
  8008aa:	eb 06                	jmp    8008b2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008af:	fc                   	cld    
  8008b0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b2:	89 f8                	mov    %edi,%eax
  8008b4:	5b                   	pop    %ebx
  8008b5:	5e                   	pop    %esi
  8008b6:	5f                   	pop    %edi
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	57                   	push   %edi
  8008bd:	56                   	push   %esi
  8008be:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c7:	39 c6                	cmp    %eax,%esi
  8008c9:	73 35                	jae    800900 <memmove+0x47>
  8008cb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008ce:	39 d0                	cmp    %edx,%eax
  8008d0:	73 2e                	jae    800900 <memmove+0x47>
		s += n;
		d += n;
  8008d2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d5:	89 d6                	mov    %edx,%esi
  8008d7:	09 fe                	or     %edi,%esi
  8008d9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008df:	75 13                	jne    8008f4 <memmove+0x3b>
  8008e1:	f6 c1 03             	test   $0x3,%cl
  8008e4:	75 0e                	jne    8008f4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008e6:	83 ef 04             	sub    $0x4,%edi
  8008e9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008ec:	c1 e9 02             	shr    $0x2,%ecx
  8008ef:	fd                   	std    
  8008f0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f2:	eb 09                	jmp    8008fd <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008f4:	83 ef 01             	sub    $0x1,%edi
  8008f7:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008fa:	fd                   	std    
  8008fb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008fd:	fc                   	cld    
  8008fe:	eb 1d                	jmp    80091d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800900:	89 f2                	mov    %esi,%edx
  800902:	09 c2                	or     %eax,%edx
  800904:	f6 c2 03             	test   $0x3,%dl
  800907:	75 0f                	jne    800918 <memmove+0x5f>
  800909:	f6 c1 03             	test   $0x3,%cl
  80090c:	75 0a                	jne    800918 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80090e:	c1 e9 02             	shr    $0x2,%ecx
  800911:	89 c7                	mov    %eax,%edi
  800913:	fc                   	cld    
  800914:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800916:	eb 05                	jmp    80091d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800918:	89 c7                	mov    %eax,%edi
  80091a:	fc                   	cld    
  80091b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80091d:	5e                   	pop    %esi
  80091e:	5f                   	pop    %edi
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800924:	ff 75 10             	pushl  0x10(%ebp)
  800927:	ff 75 0c             	pushl  0xc(%ebp)
  80092a:	ff 75 08             	pushl  0x8(%ebp)
  80092d:	e8 87 ff ff ff       	call   8008b9 <memmove>
}
  800932:	c9                   	leave  
  800933:	c3                   	ret    

00800934 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093f:	89 c6                	mov    %eax,%esi
  800941:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800944:	eb 1a                	jmp    800960 <memcmp+0x2c>
		if (*s1 != *s2)
  800946:	0f b6 08             	movzbl (%eax),%ecx
  800949:	0f b6 1a             	movzbl (%edx),%ebx
  80094c:	38 d9                	cmp    %bl,%cl
  80094e:	74 0a                	je     80095a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800950:	0f b6 c1             	movzbl %cl,%eax
  800953:	0f b6 db             	movzbl %bl,%ebx
  800956:	29 d8                	sub    %ebx,%eax
  800958:	eb 0f                	jmp    800969 <memcmp+0x35>
		s1++, s2++;
  80095a:	83 c0 01             	add    $0x1,%eax
  80095d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800960:	39 f0                	cmp    %esi,%eax
  800962:	75 e2                	jne    800946 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800964:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800969:	5b                   	pop    %ebx
  80096a:	5e                   	pop    %esi
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	53                   	push   %ebx
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800974:	89 c1                	mov    %eax,%ecx
  800976:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800979:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80097d:	eb 0a                	jmp    800989 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80097f:	0f b6 10             	movzbl (%eax),%edx
  800982:	39 da                	cmp    %ebx,%edx
  800984:	74 07                	je     80098d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800986:	83 c0 01             	add    $0x1,%eax
  800989:	39 c8                	cmp    %ecx,%eax
  80098b:	72 f2                	jb     80097f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80098d:	5b                   	pop    %ebx
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	57                   	push   %edi
  800994:	56                   	push   %esi
  800995:	53                   	push   %ebx
  800996:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800999:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099c:	eb 03                	jmp    8009a1 <strtol+0x11>
		s++;
  80099e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a1:	0f b6 01             	movzbl (%ecx),%eax
  8009a4:	3c 20                	cmp    $0x20,%al
  8009a6:	74 f6                	je     80099e <strtol+0xe>
  8009a8:	3c 09                	cmp    $0x9,%al
  8009aa:	74 f2                	je     80099e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ac:	3c 2b                	cmp    $0x2b,%al
  8009ae:	75 0a                	jne    8009ba <strtol+0x2a>
		s++;
  8009b0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b3:	bf 00 00 00 00       	mov    $0x0,%edi
  8009b8:	eb 11                	jmp    8009cb <strtol+0x3b>
  8009ba:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009bf:	3c 2d                	cmp    $0x2d,%al
  8009c1:	75 08                	jne    8009cb <strtol+0x3b>
		s++, neg = 1;
  8009c3:	83 c1 01             	add    $0x1,%ecx
  8009c6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009cb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009d1:	75 15                	jne    8009e8 <strtol+0x58>
  8009d3:	80 39 30             	cmpb   $0x30,(%ecx)
  8009d6:	75 10                	jne    8009e8 <strtol+0x58>
  8009d8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009dc:	75 7c                	jne    800a5a <strtol+0xca>
		s += 2, base = 16;
  8009de:	83 c1 02             	add    $0x2,%ecx
  8009e1:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009e6:	eb 16                	jmp    8009fe <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009e8:	85 db                	test   %ebx,%ebx
  8009ea:	75 12                	jne    8009fe <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009ec:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009f1:	80 39 30             	cmpb   $0x30,(%ecx)
  8009f4:	75 08                	jne    8009fe <strtol+0x6e>
		s++, base = 8;
  8009f6:	83 c1 01             	add    $0x1,%ecx
  8009f9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800a03:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a06:	0f b6 11             	movzbl (%ecx),%edx
  800a09:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a0c:	89 f3                	mov    %esi,%ebx
  800a0e:	80 fb 09             	cmp    $0x9,%bl
  800a11:	77 08                	ja     800a1b <strtol+0x8b>
			dig = *s - '0';
  800a13:	0f be d2             	movsbl %dl,%edx
  800a16:	83 ea 30             	sub    $0x30,%edx
  800a19:	eb 22                	jmp    800a3d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a1b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a1e:	89 f3                	mov    %esi,%ebx
  800a20:	80 fb 19             	cmp    $0x19,%bl
  800a23:	77 08                	ja     800a2d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a25:	0f be d2             	movsbl %dl,%edx
  800a28:	83 ea 57             	sub    $0x57,%edx
  800a2b:	eb 10                	jmp    800a3d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a2d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a30:	89 f3                	mov    %esi,%ebx
  800a32:	80 fb 19             	cmp    $0x19,%bl
  800a35:	77 16                	ja     800a4d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a37:	0f be d2             	movsbl %dl,%edx
  800a3a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a3d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a40:	7d 0b                	jge    800a4d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a42:	83 c1 01             	add    $0x1,%ecx
  800a45:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a49:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a4b:	eb b9                	jmp    800a06 <strtol+0x76>

	if (endptr)
  800a4d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a51:	74 0d                	je     800a60 <strtol+0xd0>
		*endptr = (char *) s;
  800a53:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a56:	89 0e                	mov    %ecx,(%esi)
  800a58:	eb 06                	jmp    800a60 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a5a:	85 db                	test   %ebx,%ebx
  800a5c:	74 98                	je     8009f6 <strtol+0x66>
  800a5e:	eb 9e                	jmp    8009fe <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a60:	89 c2                	mov    %eax,%edx
  800a62:	f7 da                	neg    %edx
  800a64:	85 ff                	test   %edi,%edi
  800a66:	0f 45 c2             	cmovne %edx,%eax
}
  800a69:	5b                   	pop    %ebx
  800a6a:	5e                   	pop    %esi
  800a6b:	5f                   	pop    %edi
  800a6c:	5d                   	pop    %ebp
  800a6d:	c3                   	ret    

00800a6e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	57                   	push   %edi
  800a72:	56                   	push   %esi
  800a73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a74:	b8 00 00 00 00       	mov    $0x0,%eax
  800a79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7f:	89 c3                	mov    %eax,%ebx
  800a81:	89 c7                	mov    %eax,%edi
  800a83:	89 c6                	mov    %eax,%esi
  800a85:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a87:	5b                   	pop    %ebx
  800a88:	5e                   	pop    %esi
  800a89:	5f                   	pop    %edi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <sys_cgetc>:

int
sys_cgetc(void)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	57                   	push   %edi
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a92:	ba 00 00 00 00       	mov    $0x0,%edx
  800a97:	b8 01 00 00 00       	mov    $0x1,%eax
  800a9c:	89 d1                	mov    %edx,%ecx
  800a9e:	89 d3                	mov    %edx,%ebx
  800aa0:	89 d7                	mov    %edx,%edi
  800aa2:	89 d6                	mov    %edx,%esi
  800aa4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aa6:	5b                   	pop    %ebx
  800aa7:	5e                   	pop    %esi
  800aa8:	5f                   	pop    %edi
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	57                   	push   %edi
  800aaf:	56                   	push   %esi
  800ab0:	53                   	push   %ebx
  800ab1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab9:	b8 03 00 00 00       	mov    $0x3,%eax
  800abe:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac1:	89 cb                	mov    %ecx,%ebx
  800ac3:	89 cf                	mov    %ecx,%edi
  800ac5:	89 ce                	mov    %ecx,%esi
  800ac7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ac9:	85 c0                	test   %eax,%eax
  800acb:	7e 17                	jle    800ae4 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800acd:	83 ec 0c             	sub    $0xc,%esp
  800ad0:	50                   	push   %eax
  800ad1:	6a 03                	push   $0x3
  800ad3:	68 44 12 80 00       	push   $0x801244
  800ad8:	6a 23                	push   $0x23
  800ada:	68 61 12 80 00       	push   $0x801261
  800adf:	e8 f5 01 00 00       	call   800cd9 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ae4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae7:	5b                   	pop    %ebx
  800ae8:	5e                   	pop    %esi
  800ae9:	5f                   	pop    %edi
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	57                   	push   %edi
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af2:	ba 00 00 00 00       	mov    $0x0,%edx
  800af7:	b8 02 00 00 00       	mov    $0x2,%eax
  800afc:	89 d1                	mov    %edx,%ecx
  800afe:	89 d3                	mov    %edx,%ebx
  800b00:	89 d7                	mov    %edx,%edi
  800b02:	89 d6                	mov    %edx,%esi
  800b04:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800b06:	5b                   	pop    %ebx
  800b07:	5e                   	pop    %esi
  800b08:	5f                   	pop    %edi
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <sys_yield>:

void
sys_yield(void)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	57                   	push   %edi
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b11:	ba 00 00 00 00       	mov    $0x0,%edx
  800b16:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b1b:	89 d1                	mov    %edx,%ecx
  800b1d:	89 d3                	mov    %edx,%ebx
  800b1f:	89 d7                	mov    %edx,%edi
  800b21:	89 d6                	mov    %edx,%esi
  800b23:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b25:	5b                   	pop    %ebx
  800b26:	5e                   	pop    %esi
  800b27:	5f                   	pop    %edi
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	57                   	push   %edi
  800b2e:	56                   	push   %esi
  800b2f:	53                   	push   %ebx
  800b30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b33:	be 00 00 00 00       	mov    $0x0,%esi
  800b38:	b8 04 00 00 00       	mov    $0x4,%eax
  800b3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b40:	8b 55 08             	mov    0x8(%ebp),%edx
  800b43:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b46:	89 f7                	mov    %esi,%edi
  800b48:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b4a:	85 c0                	test   %eax,%eax
  800b4c:	7e 17                	jle    800b65 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4e:	83 ec 0c             	sub    $0xc,%esp
  800b51:	50                   	push   %eax
  800b52:	6a 04                	push   $0x4
  800b54:	68 44 12 80 00       	push   $0x801244
  800b59:	6a 23                	push   $0x23
  800b5b:	68 61 12 80 00       	push   $0x801261
  800b60:	e8 74 01 00 00       	call   800cd9 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	57                   	push   %edi
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
  800b73:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b76:	b8 05 00 00 00       	mov    $0x5,%eax
  800b7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b84:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b87:	8b 75 18             	mov    0x18(%ebp),%esi
  800b8a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b8c:	85 c0                	test   %eax,%eax
  800b8e:	7e 17                	jle    800ba7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b90:	83 ec 0c             	sub    $0xc,%esp
  800b93:	50                   	push   %eax
  800b94:	6a 05                	push   $0x5
  800b96:	68 44 12 80 00       	push   $0x801244
  800b9b:	6a 23                	push   $0x23
  800b9d:	68 61 12 80 00       	push   $0x801261
  800ba2:	e8 32 01 00 00       	call   800cd9 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ba7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
  800bb5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bbd:	b8 06 00 00 00       	mov    $0x6,%eax
  800bc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc8:	89 df                	mov    %ebx,%edi
  800bca:	89 de                	mov    %ebx,%esi
  800bcc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	7e 17                	jle    800be9 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	50                   	push   %eax
  800bd6:	6a 06                	push   $0x6
  800bd8:	68 44 12 80 00       	push   $0x801244
  800bdd:	6a 23                	push   $0x23
  800bdf:	68 61 12 80 00       	push   $0x801261
  800be4:	e8 f0 00 00 00       	call   800cd9 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800be9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bff:	b8 08 00 00 00       	mov    $0x8,%eax
  800c04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c07:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0a:	89 df                	mov    %ebx,%edi
  800c0c:	89 de                	mov    %ebx,%esi
  800c0e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7e 17                	jle    800c2b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c14:	83 ec 0c             	sub    $0xc,%esp
  800c17:	50                   	push   %eax
  800c18:	6a 08                	push   $0x8
  800c1a:	68 44 12 80 00       	push   $0x801244
  800c1f:	6a 23                	push   $0x23
  800c21:	68 61 12 80 00       	push   $0x801261
  800c26:	e8 ae 00 00 00       	call   800cd9 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c41:	b8 09 00 00 00       	mov    $0x9,%eax
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	89 df                	mov    %ebx,%edi
  800c4e:	89 de                	mov    %ebx,%esi
  800c50:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7e 17                	jle    800c6d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c56:	83 ec 0c             	sub    $0xc,%esp
  800c59:	50                   	push   %eax
  800c5a:	6a 09                	push   $0x9
  800c5c:	68 44 12 80 00       	push   $0x801244
  800c61:	6a 23                	push   $0x23
  800c63:	68 61 12 80 00       	push   $0x801261
  800c68:	e8 6c 00 00 00       	call   800cd9 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7b:	be 00 00 00 00       	mov    $0x0,%esi
  800c80:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c88:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c91:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c93:	5b                   	pop    %ebx
  800c94:	5e                   	pop    %esi
  800c95:	5f                   	pop    %edi
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	57                   	push   %edi
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
  800c9e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cab:	8b 55 08             	mov    0x8(%ebp),%edx
  800cae:	89 cb                	mov    %ecx,%ebx
  800cb0:	89 cf                	mov    %ecx,%edi
  800cb2:	89 ce                	mov    %ecx,%esi
  800cb4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	7e 17                	jle    800cd1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cba:	83 ec 0c             	sub    $0xc,%esp
  800cbd:	50                   	push   %eax
  800cbe:	6a 0c                	push   $0xc
  800cc0:	68 44 12 80 00       	push   $0x801244
  800cc5:	6a 23                	push   $0x23
  800cc7:	68 61 12 80 00       	push   $0x801261
  800ccc:	e8 08 00 00 00       	call   800cd9 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800cde:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ce1:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ce7:	e8 00 fe ff ff       	call   800aec <sys_getenvid>
  800cec:	83 ec 0c             	sub    $0xc,%esp
  800cef:	ff 75 0c             	pushl  0xc(%ebp)
  800cf2:	ff 75 08             	pushl  0x8(%ebp)
  800cf5:	56                   	push   %esi
  800cf6:	50                   	push   %eax
  800cf7:	68 70 12 80 00       	push   $0x801270
  800cfc:	e8 5b f4 ff ff       	call   80015c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d01:	83 c4 18             	add    $0x18,%esp
  800d04:	53                   	push   %ebx
  800d05:	ff 75 10             	pushl  0x10(%ebp)
  800d08:	e8 fe f3 ff ff       	call   80010b <vcprintf>
	cprintf("\n");
  800d0d:	c7 04 24 cc 0f 80 00 	movl   $0x800fcc,(%esp)
  800d14:	e8 43 f4 ff ff       	call   80015c <cprintf>
  800d19:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d1c:	cc                   	int3   
  800d1d:	eb fd                	jmp    800d1c <_panic+0x43>
  800d1f:	90                   	nop

00800d20 <__udivdi3>:
  800d20:	55                   	push   %ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 1c             	sub    $0x1c,%esp
  800d27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d37:	85 f6                	test   %esi,%esi
  800d39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d3d:	89 ca                	mov    %ecx,%edx
  800d3f:	89 f8                	mov    %edi,%eax
  800d41:	75 3d                	jne    800d80 <__udivdi3+0x60>
  800d43:	39 cf                	cmp    %ecx,%edi
  800d45:	0f 87 c5 00 00 00    	ja     800e10 <__udivdi3+0xf0>
  800d4b:	85 ff                	test   %edi,%edi
  800d4d:	89 fd                	mov    %edi,%ebp
  800d4f:	75 0b                	jne    800d5c <__udivdi3+0x3c>
  800d51:	b8 01 00 00 00       	mov    $0x1,%eax
  800d56:	31 d2                	xor    %edx,%edx
  800d58:	f7 f7                	div    %edi
  800d5a:	89 c5                	mov    %eax,%ebp
  800d5c:	89 c8                	mov    %ecx,%eax
  800d5e:	31 d2                	xor    %edx,%edx
  800d60:	f7 f5                	div    %ebp
  800d62:	89 c1                	mov    %eax,%ecx
  800d64:	89 d8                	mov    %ebx,%eax
  800d66:	89 cf                	mov    %ecx,%edi
  800d68:	f7 f5                	div    %ebp
  800d6a:	89 c3                	mov    %eax,%ebx
  800d6c:	89 d8                	mov    %ebx,%eax
  800d6e:	89 fa                	mov    %edi,%edx
  800d70:	83 c4 1c             	add    $0x1c,%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    
  800d78:	90                   	nop
  800d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d80:	39 ce                	cmp    %ecx,%esi
  800d82:	77 74                	ja     800df8 <__udivdi3+0xd8>
  800d84:	0f bd fe             	bsr    %esi,%edi
  800d87:	83 f7 1f             	xor    $0x1f,%edi
  800d8a:	0f 84 98 00 00 00    	je     800e28 <__udivdi3+0x108>
  800d90:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d95:	89 f9                	mov    %edi,%ecx
  800d97:	89 c5                	mov    %eax,%ebp
  800d99:	29 fb                	sub    %edi,%ebx
  800d9b:	d3 e6                	shl    %cl,%esi
  800d9d:	89 d9                	mov    %ebx,%ecx
  800d9f:	d3 ed                	shr    %cl,%ebp
  800da1:	89 f9                	mov    %edi,%ecx
  800da3:	d3 e0                	shl    %cl,%eax
  800da5:	09 ee                	or     %ebp,%esi
  800da7:	89 d9                	mov    %ebx,%ecx
  800da9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dad:	89 d5                	mov    %edx,%ebp
  800daf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800db3:	d3 ed                	shr    %cl,%ebp
  800db5:	89 f9                	mov    %edi,%ecx
  800db7:	d3 e2                	shl    %cl,%edx
  800db9:	89 d9                	mov    %ebx,%ecx
  800dbb:	d3 e8                	shr    %cl,%eax
  800dbd:	09 c2                	or     %eax,%edx
  800dbf:	89 d0                	mov    %edx,%eax
  800dc1:	89 ea                	mov    %ebp,%edx
  800dc3:	f7 f6                	div    %esi
  800dc5:	89 d5                	mov    %edx,%ebp
  800dc7:	89 c3                	mov    %eax,%ebx
  800dc9:	f7 64 24 0c          	mull   0xc(%esp)
  800dcd:	39 d5                	cmp    %edx,%ebp
  800dcf:	72 10                	jb     800de1 <__udivdi3+0xc1>
  800dd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800dd5:	89 f9                	mov    %edi,%ecx
  800dd7:	d3 e6                	shl    %cl,%esi
  800dd9:	39 c6                	cmp    %eax,%esi
  800ddb:	73 07                	jae    800de4 <__udivdi3+0xc4>
  800ddd:	39 d5                	cmp    %edx,%ebp
  800ddf:	75 03                	jne    800de4 <__udivdi3+0xc4>
  800de1:	83 eb 01             	sub    $0x1,%ebx
  800de4:	31 ff                	xor    %edi,%edi
  800de6:	89 d8                	mov    %ebx,%eax
  800de8:	89 fa                	mov    %edi,%edx
  800dea:	83 c4 1c             	add    $0x1c,%esp
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    
  800df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800df8:	31 ff                	xor    %edi,%edi
  800dfa:	31 db                	xor    %ebx,%ebx
  800dfc:	89 d8                	mov    %ebx,%eax
  800dfe:	89 fa                	mov    %edi,%edx
  800e00:	83 c4 1c             	add    $0x1c,%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    
  800e08:	90                   	nop
  800e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e10:	89 d8                	mov    %ebx,%eax
  800e12:	f7 f7                	div    %edi
  800e14:	31 ff                	xor    %edi,%edi
  800e16:	89 c3                	mov    %eax,%ebx
  800e18:	89 d8                	mov    %ebx,%eax
  800e1a:	89 fa                	mov    %edi,%edx
  800e1c:	83 c4 1c             	add    $0x1c,%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    
  800e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e28:	39 ce                	cmp    %ecx,%esi
  800e2a:	72 0c                	jb     800e38 <__udivdi3+0x118>
  800e2c:	31 db                	xor    %ebx,%ebx
  800e2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e32:	0f 87 34 ff ff ff    	ja     800d6c <__udivdi3+0x4c>
  800e38:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e3d:	e9 2a ff ff ff       	jmp    800d6c <__udivdi3+0x4c>
  800e42:	66 90                	xchg   %ax,%ax
  800e44:	66 90                	xchg   %ax,%ax
  800e46:	66 90                	xchg   %ax,%ax
  800e48:	66 90                	xchg   %ax,%ax
  800e4a:	66 90                	xchg   %ax,%ax
  800e4c:	66 90                	xchg   %ax,%ax
  800e4e:	66 90                	xchg   %ax,%ax

00800e50 <__umoddi3>:
  800e50:	55                   	push   %ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 1c             	sub    $0x1c,%esp
  800e57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e67:	85 d2                	test   %edx,%edx
  800e69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e71:	89 f3                	mov    %esi,%ebx
  800e73:	89 3c 24             	mov    %edi,(%esp)
  800e76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e7a:	75 1c                	jne    800e98 <__umoddi3+0x48>
  800e7c:	39 f7                	cmp    %esi,%edi
  800e7e:	76 50                	jbe    800ed0 <__umoddi3+0x80>
  800e80:	89 c8                	mov    %ecx,%eax
  800e82:	89 f2                	mov    %esi,%edx
  800e84:	f7 f7                	div    %edi
  800e86:	89 d0                	mov    %edx,%eax
  800e88:	31 d2                	xor    %edx,%edx
  800e8a:	83 c4 1c             	add    $0x1c,%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    
  800e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e98:	39 f2                	cmp    %esi,%edx
  800e9a:	89 d0                	mov    %edx,%eax
  800e9c:	77 52                	ja     800ef0 <__umoddi3+0xa0>
  800e9e:	0f bd ea             	bsr    %edx,%ebp
  800ea1:	83 f5 1f             	xor    $0x1f,%ebp
  800ea4:	75 5a                	jne    800f00 <__umoddi3+0xb0>
  800ea6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800eaa:	0f 82 e0 00 00 00    	jb     800f90 <__umoddi3+0x140>
  800eb0:	39 0c 24             	cmp    %ecx,(%esp)
  800eb3:	0f 86 d7 00 00 00    	jbe    800f90 <__umoddi3+0x140>
  800eb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ebd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ec1:	83 c4 1c             	add    $0x1c,%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    
  800ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	85 ff                	test   %edi,%edi
  800ed2:	89 fd                	mov    %edi,%ebp
  800ed4:	75 0b                	jne    800ee1 <__umoddi3+0x91>
  800ed6:	b8 01 00 00 00       	mov    $0x1,%eax
  800edb:	31 d2                	xor    %edx,%edx
  800edd:	f7 f7                	div    %edi
  800edf:	89 c5                	mov    %eax,%ebp
  800ee1:	89 f0                	mov    %esi,%eax
  800ee3:	31 d2                	xor    %edx,%edx
  800ee5:	f7 f5                	div    %ebp
  800ee7:	89 c8                	mov    %ecx,%eax
  800ee9:	f7 f5                	div    %ebp
  800eeb:	89 d0                	mov    %edx,%eax
  800eed:	eb 99                	jmp    800e88 <__umoddi3+0x38>
  800eef:	90                   	nop
  800ef0:	89 c8                	mov    %ecx,%eax
  800ef2:	89 f2                	mov    %esi,%edx
  800ef4:	83 c4 1c             	add    $0x1c,%esp
  800ef7:	5b                   	pop    %ebx
  800ef8:	5e                   	pop    %esi
  800ef9:	5f                   	pop    %edi
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    
  800efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f00:	8b 34 24             	mov    (%esp),%esi
  800f03:	bf 20 00 00 00       	mov    $0x20,%edi
  800f08:	89 e9                	mov    %ebp,%ecx
  800f0a:	29 ef                	sub    %ebp,%edi
  800f0c:	d3 e0                	shl    %cl,%eax
  800f0e:	89 f9                	mov    %edi,%ecx
  800f10:	89 f2                	mov    %esi,%edx
  800f12:	d3 ea                	shr    %cl,%edx
  800f14:	89 e9                	mov    %ebp,%ecx
  800f16:	09 c2                	or     %eax,%edx
  800f18:	89 d8                	mov    %ebx,%eax
  800f1a:	89 14 24             	mov    %edx,(%esp)
  800f1d:	89 f2                	mov    %esi,%edx
  800f1f:	d3 e2                	shl    %cl,%edx
  800f21:	89 f9                	mov    %edi,%ecx
  800f23:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f27:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f2b:	d3 e8                	shr    %cl,%eax
  800f2d:	89 e9                	mov    %ebp,%ecx
  800f2f:	89 c6                	mov    %eax,%esi
  800f31:	d3 e3                	shl    %cl,%ebx
  800f33:	89 f9                	mov    %edi,%ecx
  800f35:	89 d0                	mov    %edx,%eax
  800f37:	d3 e8                	shr    %cl,%eax
  800f39:	89 e9                	mov    %ebp,%ecx
  800f3b:	09 d8                	or     %ebx,%eax
  800f3d:	89 d3                	mov    %edx,%ebx
  800f3f:	89 f2                	mov    %esi,%edx
  800f41:	f7 34 24             	divl   (%esp)
  800f44:	89 d6                	mov    %edx,%esi
  800f46:	d3 e3                	shl    %cl,%ebx
  800f48:	f7 64 24 04          	mull   0x4(%esp)
  800f4c:	39 d6                	cmp    %edx,%esi
  800f4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f52:	89 d1                	mov    %edx,%ecx
  800f54:	89 c3                	mov    %eax,%ebx
  800f56:	72 08                	jb     800f60 <__umoddi3+0x110>
  800f58:	75 11                	jne    800f6b <__umoddi3+0x11b>
  800f5a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f5e:	73 0b                	jae    800f6b <__umoddi3+0x11b>
  800f60:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f64:	1b 14 24             	sbb    (%esp),%edx
  800f67:	89 d1                	mov    %edx,%ecx
  800f69:	89 c3                	mov    %eax,%ebx
  800f6b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f6f:	29 da                	sub    %ebx,%edx
  800f71:	19 ce                	sbb    %ecx,%esi
  800f73:	89 f9                	mov    %edi,%ecx
  800f75:	89 f0                	mov    %esi,%eax
  800f77:	d3 e0                	shl    %cl,%eax
  800f79:	89 e9                	mov    %ebp,%ecx
  800f7b:	d3 ea                	shr    %cl,%edx
  800f7d:	89 e9                	mov    %ebp,%ecx
  800f7f:	d3 ee                	shr    %cl,%esi
  800f81:	09 d0                	or     %edx,%eax
  800f83:	89 f2                	mov    %esi,%edx
  800f85:	83 c4 1c             	add    $0x1c,%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    
  800f8d:	8d 76 00             	lea    0x0(%esi),%esi
  800f90:	29 f9                	sub    %edi,%ecx
  800f92:	19 d6                	sbb    %edx,%esi
  800f94:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f9c:	e9 18 ff ff ff       	jmp    800eb9 <__umoddi3+0x69>
