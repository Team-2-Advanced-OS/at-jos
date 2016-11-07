
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 60 10 80 00       	push   $0x801060
  80004a:	e8 26 01 00 00       	call   800175 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 ad 0a 00 00       	call   800b01 <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 64 0a 00 00       	call   800ac0 <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 7d 0c 00 00       	call   800cee <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80008b:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800092:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  800095:	e8 67 0a 00 00       	call   800b01 <sys_getenvid>
  80009a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80009f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000a2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a7:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ac:	85 db                	test   %ebx,%ebx
  8000ae:	7e 07                	jle    8000b7 <libmain+0x37>
		binaryname = argv[0];
  8000b0:	8b 06                	mov    (%esi),%eax
  8000b2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000b7:	83 ec 08             	sub    $0x8,%esp
  8000ba:	56                   	push   %esi
  8000bb:	53                   	push   %ebx
  8000bc:	e8 a0 ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000c1:	e8 0a 00 00 00       	call   8000d0 <exit>
}
  8000c6:	83 c4 10             	add    $0x10,%esp
  8000c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5d                   	pop    %ebp
  8000cf:	c3                   	ret    

008000d0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000d6:	6a 00                	push   $0x0
  8000d8:	e8 e3 09 00 00       	call   800ac0 <sys_env_destroy>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	c9                   	leave  
  8000e1:	c3                   	ret    

008000e2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	53                   	push   %ebx
  8000e6:	83 ec 04             	sub    $0x4,%esp
  8000e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ec:	8b 13                	mov    (%ebx),%edx
  8000ee:	8d 42 01             	lea    0x1(%edx),%eax
  8000f1:	89 03                	mov    %eax,(%ebx)
  8000f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000fa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ff:	75 1a                	jne    80011b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800101:	83 ec 08             	sub    $0x8,%esp
  800104:	68 ff 00 00 00       	push   $0xff
  800109:	8d 43 08             	lea    0x8(%ebx),%eax
  80010c:	50                   	push   %eax
  80010d:	e8 71 09 00 00       	call   800a83 <sys_cputs>
		b->idx = 0;
  800112:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800118:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80011b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800122:	c9                   	leave  
  800123:	c3                   	ret    

00800124 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800134:	00 00 00 
	b.cnt = 0;
  800137:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800141:	ff 75 0c             	pushl  0xc(%ebp)
  800144:	ff 75 08             	pushl  0x8(%ebp)
  800147:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014d:	50                   	push   %eax
  80014e:	68 e2 00 80 00       	push   $0x8000e2
  800153:	e8 54 01 00 00       	call   8002ac <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800158:	83 c4 08             	add    $0x8,%esp
  80015b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800161:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800167:	50                   	push   %eax
  800168:	e8 16 09 00 00       	call   800a83 <sys_cputs>

	return b.cnt;
}
  80016d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800173:	c9                   	leave  
  800174:	c3                   	ret    

00800175 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017e:	50                   	push   %eax
  80017f:	ff 75 08             	pushl  0x8(%ebp)
  800182:	e8 9d ff ff ff       	call   800124 <vcprintf>
	va_end(ap);

	return cnt;
}
  800187:	c9                   	leave  
  800188:	c3                   	ret    

00800189 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	57                   	push   %edi
  80018d:	56                   	push   %esi
  80018e:	53                   	push   %ebx
  80018f:	83 ec 1c             	sub    $0x1c,%esp
  800192:	89 c7                	mov    %eax,%edi
  800194:	89 d6                	mov    %edx,%esi
  800196:	8b 45 08             	mov    0x8(%ebp),%eax
  800199:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001aa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ad:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001b0:	39 d3                	cmp    %edx,%ebx
  8001b2:	72 05                	jb     8001b9 <printnum+0x30>
  8001b4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b7:	77 45                	ja     8001fe <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b9:	83 ec 0c             	sub    $0xc,%esp
  8001bc:	ff 75 18             	pushl  0x18(%ebp)
  8001bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c5:	53                   	push   %ebx
  8001c6:	ff 75 10             	pushl  0x10(%ebp)
  8001c9:	83 ec 08             	sub    $0x8,%esp
  8001cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d8:	e8 f3 0b 00 00       	call   800dd0 <__udivdi3>
  8001dd:	83 c4 18             	add    $0x18,%esp
  8001e0:	52                   	push   %edx
  8001e1:	50                   	push   %eax
  8001e2:	89 f2                	mov    %esi,%edx
  8001e4:	89 f8                	mov    %edi,%eax
  8001e6:	e8 9e ff ff ff       	call   800189 <printnum>
  8001eb:	83 c4 20             	add    $0x20,%esp
  8001ee:	eb 18                	jmp    800208 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f0:	83 ec 08             	sub    $0x8,%esp
  8001f3:	56                   	push   %esi
  8001f4:	ff 75 18             	pushl  0x18(%ebp)
  8001f7:	ff d7                	call   *%edi
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	eb 03                	jmp    800201 <printnum+0x78>
  8001fe:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800201:	83 eb 01             	sub    $0x1,%ebx
  800204:	85 db                	test   %ebx,%ebx
  800206:	7f e8                	jg     8001f0 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	83 ec 04             	sub    $0x4,%esp
  80020f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800212:	ff 75 e0             	pushl  -0x20(%ebp)
  800215:	ff 75 dc             	pushl  -0x24(%ebp)
  800218:	ff 75 d8             	pushl  -0x28(%ebp)
  80021b:	e8 e0 0c 00 00       	call   800f00 <__umoddi3>
  800220:	83 c4 14             	add    $0x14,%esp
  800223:	0f be 80 86 10 80 00 	movsbl 0x801086(%eax),%eax
  80022a:	50                   	push   %eax
  80022b:	ff d7                	call   *%edi
}
  80022d:	83 c4 10             	add    $0x10,%esp
  800230:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800233:	5b                   	pop    %ebx
  800234:	5e                   	pop    %esi
  800235:	5f                   	pop    %edi
  800236:	5d                   	pop    %ebp
  800237:	c3                   	ret    

00800238 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80023b:	83 fa 01             	cmp    $0x1,%edx
  80023e:	7e 0e                	jle    80024e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800240:	8b 10                	mov    (%eax),%edx
  800242:	8d 4a 08             	lea    0x8(%edx),%ecx
  800245:	89 08                	mov    %ecx,(%eax)
  800247:	8b 02                	mov    (%edx),%eax
  800249:	8b 52 04             	mov    0x4(%edx),%edx
  80024c:	eb 22                	jmp    800270 <getuint+0x38>
	else if (lflag)
  80024e:	85 d2                	test   %edx,%edx
  800250:	74 10                	je     800262 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800252:	8b 10                	mov    (%eax),%edx
  800254:	8d 4a 04             	lea    0x4(%edx),%ecx
  800257:	89 08                	mov    %ecx,(%eax)
  800259:	8b 02                	mov    (%edx),%eax
  80025b:	ba 00 00 00 00       	mov    $0x0,%edx
  800260:	eb 0e                	jmp    800270 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800262:	8b 10                	mov    (%eax),%edx
  800264:	8d 4a 04             	lea    0x4(%edx),%ecx
  800267:	89 08                	mov    %ecx,(%eax)
  800269:	8b 02                	mov    (%edx),%eax
  80026b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800270:	5d                   	pop    %ebp
  800271:	c3                   	ret    

00800272 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800278:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027c:	8b 10                	mov    (%eax),%edx
  80027e:	3b 50 04             	cmp    0x4(%eax),%edx
  800281:	73 0a                	jae    80028d <sprintputch+0x1b>
		*b->buf++ = ch;
  800283:	8d 4a 01             	lea    0x1(%edx),%ecx
  800286:	89 08                	mov    %ecx,(%eax)
  800288:	8b 45 08             	mov    0x8(%ebp),%eax
  80028b:	88 02                	mov    %al,(%edx)
}
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    

0080028f <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800295:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800298:	50                   	push   %eax
  800299:	ff 75 10             	pushl  0x10(%ebp)
  80029c:	ff 75 0c             	pushl  0xc(%ebp)
  80029f:	ff 75 08             	pushl  0x8(%ebp)
  8002a2:	e8 05 00 00 00       	call   8002ac <vprintfmt>
	va_end(ap);
}
  8002a7:	83 c4 10             	add    $0x10,%esp
  8002aa:	c9                   	leave  
  8002ab:	c3                   	ret    

008002ac <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	57                   	push   %edi
  8002b0:	56                   	push   %esi
  8002b1:	53                   	push   %ebx
  8002b2:	83 ec 2c             	sub    $0x2c,%esp
  8002b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002bb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002be:	eb 12                	jmp    8002d2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	0f 84 cb 03 00 00    	je     800693 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  8002c8:	83 ec 08             	sub    $0x8,%esp
  8002cb:	53                   	push   %ebx
  8002cc:	50                   	push   %eax
  8002cd:	ff d6                	call   *%esi
  8002cf:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d2:	83 c7 01             	add    $0x1,%edi
  8002d5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002d9:	83 f8 25             	cmp    $0x25,%eax
  8002dc:	75 e2                	jne    8002c0 <vprintfmt+0x14>
  8002de:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002e2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002e9:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002f0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fc:	eb 07                	jmp    800305 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800301:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800305:	8d 47 01             	lea    0x1(%edi),%eax
  800308:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030b:	0f b6 07             	movzbl (%edi),%eax
  80030e:	0f b6 c8             	movzbl %al,%ecx
  800311:	83 e8 23             	sub    $0x23,%eax
  800314:	3c 55                	cmp    $0x55,%al
  800316:	0f 87 5c 03 00 00    	ja     800678 <vprintfmt+0x3cc>
  80031c:	0f b6 c0             	movzbl %al,%eax
  80031f:	ff 24 85 60 11 80 00 	jmp    *0x801160(,%eax,4)
  800326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800329:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80032d:	eb d6                	jmp    800305 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800332:	b8 00 00 00 00       	mov    $0x0,%eax
  800337:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80033a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800341:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800344:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800347:	83 fa 09             	cmp    $0x9,%edx
  80034a:	77 39                	ja     800385 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80034c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80034f:	eb e9                	jmp    80033a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800351:	8b 45 14             	mov    0x14(%ebp),%eax
  800354:	8d 48 04             	lea    0x4(%eax),%ecx
  800357:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80035a:	8b 00                	mov    (%eax),%eax
  80035c:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800362:	eb 27                	jmp    80038b <vprintfmt+0xdf>
  800364:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800367:	85 c0                	test   %eax,%eax
  800369:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036e:	0f 49 c8             	cmovns %eax,%ecx
  800371:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800374:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800377:	eb 8c                	jmp    800305 <vprintfmt+0x59>
  800379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80037c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800383:	eb 80                	jmp    800305 <vprintfmt+0x59>
  800385:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800388:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80038b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80038f:	0f 89 70 ff ff ff    	jns    800305 <vprintfmt+0x59>
				width = precision, precision = -1;
  800395:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800398:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80039b:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003a2:	e9 5e ff ff ff       	jmp    800305 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ad:	e9 53 ff ff ff       	jmp    800305 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b5:	8d 50 04             	lea    0x4(%eax),%edx
  8003b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003bb:	83 ec 08             	sub    $0x8,%esp
  8003be:	53                   	push   %ebx
  8003bf:	ff 30                	pushl  (%eax)
  8003c1:	ff d6                	call   *%esi
			break;
  8003c3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c9:	e9 04 ff ff ff       	jmp    8002d2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d1:	8d 50 04             	lea    0x4(%eax),%edx
  8003d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d7:	8b 00                	mov    (%eax),%eax
  8003d9:	99                   	cltd   
  8003da:	31 d0                	xor    %edx,%eax
  8003dc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003de:	83 f8 09             	cmp    $0x9,%eax
  8003e1:	7f 0b                	jg     8003ee <vprintfmt+0x142>
  8003e3:	8b 14 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edx
  8003ea:	85 d2                	test   %edx,%edx
  8003ec:	75 18                	jne    800406 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ee:	50                   	push   %eax
  8003ef:	68 9e 10 80 00       	push   $0x80109e
  8003f4:	53                   	push   %ebx
  8003f5:	56                   	push   %esi
  8003f6:	e8 94 fe ff ff       	call   80028f <printfmt>
  8003fb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800401:	e9 cc fe ff ff       	jmp    8002d2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800406:	52                   	push   %edx
  800407:	68 a7 10 80 00       	push   $0x8010a7
  80040c:	53                   	push   %ebx
  80040d:	56                   	push   %esi
  80040e:	e8 7c fe ff ff       	call   80028f <printfmt>
  800413:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800419:	e9 b4 fe ff ff       	jmp    8002d2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80041e:	8b 45 14             	mov    0x14(%ebp),%eax
  800421:	8d 50 04             	lea    0x4(%eax),%edx
  800424:	89 55 14             	mov    %edx,0x14(%ebp)
  800427:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800429:	85 ff                	test   %edi,%edi
  80042b:	b8 97 10 80 00       	mov    $0x801097,%eax
  800430:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800433:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800437:	0f 8e 94 00 00 00    	jle    8004d1 <vprintfmt+0x225>
  80043d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800441:	0f 84 98 00 00 00    	je     8004df <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800447:	83 ec 08             	sub    $0x8,%esp
  80044a:	ff 75 c8             	pushl  -0x38(%ebp)
  80044d:	57                   	push   %edi
  80044e:	e8 c8 02 00 00       	call   80071b <strnlen>
  800453:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800456:	29 c1                	sub    %eax,%ecx
  800458:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80045b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80045e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800462:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800465:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800468:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80046a:	eb 0f                	jmp    80047b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	53                   	push   %ebx
  800470:	ff 75 e0             	pushl  -0x20(%ebp)
  800473:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800475:	83 ef 01             	sub    $0x1,%edi
  800478:	83 c4 10             	add    $0x10,%esp
  80047b:	85 ff                	test   %edi,%edi
  80047d:	7f ed                	jg     80046c <vprintfmt+0x1c0>
  80047f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800482:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800485:	85 c9                	test   %ecx,%ecx
  800487:	b8 00 00 00 00       	mov    $0x0,%eax
  80048c:	0f 49 c1             	cmovns %ecx,%eax
  80048f:	29 c1                	sub    %eax,%ecx
  800491:	89 75 08             	mov    %esi,0x8(%ebp)
  800494:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800497:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80049a:	89 cb                	mov    %ecx,%ebx
  80049c:	eb 4d                	jmp    8004eb <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80049e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a2:	74 1b                	je     8004bf <vprintfmt+0x213>
  8004a4:	0f be c0             	movsbl %al,%eax
  8004a7:	83 e8 20             	sub    $0x20,%eax
  8004aa:	83 f8 5e             	cmp    $0x5e,%eax
  8004ad:	76 10                	jbe    8004bf <vprintfmt+0x213>
					putch('?', putdat);
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	ff 75 0c             	pushl  0xc(%ebp)
  8004b5:	6a 3f                	push   $0x3f
  8004b7:	ff 55 08             	call   *0x8(%ebp)
  8004ba:	83 c4 10             	add    $0x10,%esp
  8004bd:	eb 0d                	jmp    8004cc <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004bf:	83 ec 08             	sub    $0x8,%esp
  8004c2:	ff 75 0c             	pushl  0xc(%ebp)
  8004c5:	52                   	push   %edx
  8004c6:	ff 55 08             	call   *0x8(%ebp)
  8004c9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004cc:	83 eb 01             	sub    $0x1,%ebx
  8004cf:	eb 1a                	jmp    8004eb <vprintfmt+0x23f>
  8004d1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d4:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004d7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004da:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004dd:	eb 0c                	jmp    8004eb <vprintfmt+0x23f>
  8004df:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e2:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004eb:	83 c7 01             	add    $0x1,%edi
  8004ee:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f2:	0f be d0             	movsbl %al,%edx
  8004f5:	85 d2                	test   %edx,%edx
  8004f7:	74 23                	je     80051c <vprintfmt+0x270>
  8004f9:	85 f6                	test   %esi,%esi
  8004fb:	78 a1                	js     80049e <vprintfmt+0x1f2>
  8004fd:	83 ee 01             	sub    $0x1,%esi
  800500:	79 9c                	jns    80049e <vprintfmt+0x1f2>
  800502:	89 df                	mov    %ebx,%edi
  800504:	8b 75 08             	mov    0x8(%ebp),%esi
  800507:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050a:	eb 18                	jmp    800524 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	53                   	push   %ebx
  800510:	6a 20                	push   $0x20
  800512:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800514:	83 ef 01             	sub    $0x1,%edi
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	eb 08                	jmp    800524 <vprintfmt+0x278>
  80051c:	89 df                	mov    %ebx,%edi
  80051e:	8b 75 08             	mov    0x8(%ebp),%esi
  800521:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800524:	85 ff                	test   %edi,%edi
  800526:	7f e4                	jg     80050c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800528:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80052b:	e9 a2 fd ff ff       	jmp    8002d2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800530:	83 fa 01             	cmp    $0x1,%edx
  800533:	7e 16                	jle    80054b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 50 08             	lea    0x8(%eax),%edx
  80053b:	89 55 14             	mov    %edx,0x14(%ebp)
  80053e:	8b 50 04             	mov    0x4(%eax),%edx
  800541:	8b 00                	mov    (%eax),%eax
  800543:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800546:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800549:	eb 32                	jmp    80057d <vprintfmt+0x2d1>
	else if (lflag)
  80054b:	85 d2                	test   %edx,%edx
  80054d:	74 18                	je     800567 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 50 04             	lea    0x4(%eax),%edx
  800555:	89 55 14             	mov    %edx,0x14(%ebp)
  800558:	8b 00                	mov    (%eax),%eax
  80055a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80055d:	89 c1                	mov    %eax,%ecx
  80055f:	c1 f9 1f             	sar    $0x1f,%ecx
  800562:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800565:	eb 16                	jmp    80057d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 50 04             	lea    0x4(%eax),%edx
  80056d:	89 55 14             	mov    %edx,0x14(%ebp)
  800570:	8b 00                	mov    (%eax),%eax
  800572:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800575:	89 c1                	mov    %eax,%ecx
  800577:	c1 f9 1f             	sar    $0x1f,%ecx
  80057a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800580:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800583:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800586:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800589:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80058e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800592:	0f 89 a8 00 00 00    	jns    800640 <vprintfmt+0x394>
				putch('-', putdat);
  800598:	83 ec 08             	sub    $0x8,%esp
  80059b:	53                   	push   %ebx
  80059c:	6a 2d                	push   $0x2d
  80059e:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a0:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005a3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005a6:	f7 d8                	neg    %eax
  8005a8:	83 d2 00             	adc    $0x0,%edx
  8005ab:	f7 da                	neg    %edx
  8005ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005b6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bb:	e9 80 00 00 00       	jmp    800640 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c3:	e8 70 fc ff ff       	call   800238 <getuint>
  8005c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cb:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005ce:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005d3:	eb 6b                	jmp    800640 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d8:	e8 5b fc ff ff       	call   800238 <getuint>
  8005dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  8005e3:	6a 04                	push   $0x4
  8005e5:	6a 03                	push   $0x3
  8005e7:	6a 01                	push   $0x1
  8005e9:	68 aa 10 80 00       	push   $0x8010aa
  8005ee:	e8 82 fb ff ff       	call   800175 <cprintf>
			goto number;
  8005f3:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  8005f6:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  8005fb:	eb 43                	jmp    800640 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	6a 30                	push   $0x30
  800603:	ff d6                	call   *%esi
			putch('x', putdat);
  800605:	83 c4 08             	add    $0x8,%esp
  800608:	53                   	push   %ebx
  800609:	6a 78                	push   $0x78
  80060b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8d 50 04             	lea    0x4(%eax),%edx
  800613:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800616:	8b 00                	mov    (%eax),%eax
  800618:	ba 00 00 00 00       	mov    $0x0,%edx
  80061d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800620:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800623:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800626:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80062b:	eb 13                	jmp    800640 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80062d:	8d 45 14             	lea    0x14(%ebp),%eax
  800630:	e8 03 fc ff ff       	call   800238 <getuint>
  800635:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800638:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80063b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800640:	83 ec 0c             	sub    $0xc,%esp
  800643:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800647:	52                   	push   %edx
  800648:	ff 75 e0             	pushl  -0x20(%ebp)
  80064b:	50                   	push   %eax
  80064c:	ff 75 dc             	pushl  -0x24(%ebp)
  80064f:	ff 75 d8             	pushl  -0x28(%ebp)
  800652:	89 da                	mov    %ebx,%edx
  800654:	89 f0                	mov    %esi,%eax
  800656:	e8 2e fb ff ff       	call   800189 <printnum>

			break;
  80065b:	83 c4 20             	add    $0x20,%esp
  80065e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800661:	e9 6c fc ff ff       	jmp    8002d2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800666:	83 ec 08             	sub    $0x8,%esp
  800669:	53                   	push   %ebx
  80066a:	51                   	push   %ecx
  80066b:	ff d6                	call   *%esi
			break;
  80066d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800670:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800673:	e9 5a fc ff ff       	jmp    8002d2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800678:	83 ec 08             	sub    $0x8,%esp
  80067b:	53                   	push   %ebx
  80067c:	6a 25                	push   $0x25
  80067e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800680:	83 c4 10             	add    $0x10,%esp
  800683:	eb 03                	jmp    800688 <vprintfmt+0x3dc>
  800685:	83 ef 01             	sub    $0x1,%edi
  800688:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80068c:	75 f7                	jne    800685 <vprintfmt+0x3d9>
  80068e:	e9 3f fc ff ff       	jmp    8002d2 <vprintfmt+0x26>
			break;
		}

	}

}
  800693:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800696:	5b                   	pop    %ebx
  800697:	5e                   	pop    %esi
  800698:	5f                   	pop    %edi
  800699:	5d                   	pop    %ebp
  80069a:	c3                   	ret    

0080069b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069b:	55                   	push   %ebp
  80069c:	89 e5                	mov    %esp,%ebp
  80069e:	83 ec 18             	sub    $0x18,%esp
  8006a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006aa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ae:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b8:	85 c0                	test   %eax,%eax
  8006ba:	74 26                	je     8006e2 <vsnprintf+0x47>
  8006bc:	85 d2                	test   %edx,%edx
  8006be:	7e 22                	jle    8006e2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c0:	ff 75 14             	pushl  0x14(%ebp)
  8006c3:	ff 75 10             	pushl  0x10(%ebp)
  8006c6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c9:	50                   	push   %eax
  8006ca:	68 72 02 80 00       	push   $0x800272
  8006cf:	e8 d8 fb ff ff       	call   8002ac <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	eb 05                	jmp    8006e7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e7:	c9                   	leave  
  8006e8:	c3                   	ret    

008006e9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006f2:	50                   	push   %eax
  8006f3:	ff 75 10             	pushl  0x10(%ebp)
  8006f6:	ff 75 0c             	pushl  0xc(%ebp)
  8006f9:	ff 75 08             	pushl  0x8(%ebp)
  8006fc:	e8 9a ff ff ff       	call   80069b <vsnprintf>
	va_end(ap);

	return rc;
}
  800701:	c9                   	leave  
  800702:	c3                   	ret    

00800703 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800703:	55                   	push   %ebp
  800704:	89 e5                	mov    %esp,%ebp
  800706:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800709:	b8 00 00 00 00       	mov    $0x0,%eax
  80070e:	eb 03                	jmp    800713 <strlen+0x10>
		n++;
  800710:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800713:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800717:	75 f7                	jne    800710 <strlen+0xd>
		n++;
	return n;
}
  800719:	5d                   	pop    %ebp
  80071a:	c3                   	ret    

0080071b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800721:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800724:	ba 00 00 00 00       	mov    $0x0,%edx
  800729:	eb 03                	jmp    80072e <strnlen+0x13>
		n++;
  80072b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072e:	39 c2                	cmp    %eax,%edx
  800730:	74 08                	je     80073a <strnlen+0x1f>
  800732:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800736:	75 f3                	jne    80072b <strnlen+0x10>
  800738:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80073a:	5d                   	pop    %ebp
  80073b:	c3                   	ret    

0080073c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	53                   	push   %ebx
  800740:	8b 45 08             	mov    0x8(%ebp),%eax
  800743:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800746:	89 c2                	mov    %eax,%edx
  800748:	83 c2 01             	add    $0x1,%edx
  80074b:	83 c1 01             	add    $0x1,%ecx
  80074e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800752:	88 5a ff             	mov    %bl,-0x1(%edx)
  800755:	84 db                	test   %bl,%bl
  800757:	75 ef                	jne    800748 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800759:	5b                   	pop    %ebx
  80075a:	5d                   	pop    %ebp
  80075b:	c3                   	ret    

0080075c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	53                   	push   %ebx
  800760:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800763:	53                   	push   %ebx
  800764:	e8 9a ff ff ff       	call   800703 <strlen>
  800769:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80076c:	ff 75 0c             	pushl  0xc(%ebp)
  80076f:	01 d8                	add    %ebx,%eax
  800771:	50                   	push   %eax
  800772:	e8 c5 ff ff ff       	call   80073c <strcpy>
	return dst;
}
  800777:	89 d8                	mov    %ebx,%eax
  800779:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80077c:	c9                   	leave  
  80077d:	c3                   	ret    

0080077e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	56                   	push   %esi
  800782:	53                   	push   %ebx
  800783:	8b 75 08             	mov    0x8(%ebp),%esi
  800786:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800789:	89 f3                	mov    %esi,%ebx
  80078b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078e:	89 f2                	mov    %esi,%edx
  800790:	eb 0f                	jmp    8007a1 <strncpy+0x23>
		*dst++ = *src;
  800792:	83 c2 01             	add    $0x1,%edx
  800795:	0f b6 01             	movzbl (%ecx),%eax
  800798:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80079b:	80 39 01             	cmpb   $0x1,(%ecx)
  80079e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a1:	39 da                	cmp    %ebx,%edx
  8007a3:	75 ed                	jne    800792 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a5:	89 f0                	mov    %esi,%eax
  8007a7:	5b                   	pop    %ebx
  8007a8:	5e                   	pop    %esi
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	56                   	push   %esi
  8007af:	53                   	push   %ebx
  8007b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b6:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007bb:	85 d2                	test   %edx,%edx
  8007bd:	74 21                	je     8007e0 <strlcpy+0x35>
  8007bf:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007c3:	89 f2                	mov    %esi,%edx
  8007c5:	eb 09                	jmp    8007d0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c7:	83 c2 01             	add    $0x1,%edx
  8007ca:	83 c1 01             	add    $0x1,%ecx
  8007cd:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007d0:	39 c2                	cmp    %eax,%edx
  8007d2:	74 09                	je     8007dd <strlcpy+0x32>
  8007d4:	0f b6 19             	movzbl (%ecx),%ebx
  8007d7:	84 db                	test   %bl,%bl
  8007d9:	75 ec                	jne    8007c7 <strlcpy+0x1c>
  8007db:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007dd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007e0:	29 f0                	sub    %esi,%eax
}
  8007e2:	5b                   	pop    %ebx
  8007e3:	5e                   	pop    %esi
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ef:	eb 06                	jmp    8007f7 <strcmp+0x11>
		p++, q++;
  8007f1:	83 c1 01             	add    $0x1,%ecx
  8007f4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f7:	0f b6 01             	movzbl (%ecx),%eax
  8007fa:	84 c0                	test   %al,%al
  8007fc:	74 04                	je     800802 <strcmp+0x1c>
  8007fe:	3a 02                	cmp    (%edx),%al
  800800:	74 ef                	je     8007f1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800802:	0f b6 c0             	movzbl %al,%eax
  800805:	0f b6 12             	movzbl (%edx),%edx
  800808:	29 d0                	sub    %edx,%eax
}
  80080a:	5d                   	pop    %ebp
  80080b:	c3                   	ret    

0080080c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	53                   	push   %ebx
  800810:	8b 45 08             	mov    0x8(%ebp),%eax
  800813:	8b 55 0c             	mov    0xc(%ebp),%edx
  800816:	89 c3                	mov    %eax,%ebx
  800818:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80081b:	eb 06                	jmp    800823 <strncmp+0x17>
		n--, p++, q++;
  80081d:	83 c0 01             	add    $0x1,%eax
  800820:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800823:	39 d8                	cmp    %ebx,%eax
  800825:	74 15                	je     80083c <strncmp+0x30>
  800827:	0f b6 08             	movzbl (%eax),%ecx
  80082a:	84 c9                	test   %cl,%cl
  80082c:	74 04                	je     800832 <strncmp+0x26>
  80082e:	3a 0a                	cmp    (%edx),%cl
  800830:	74 eb                	je     80081d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800832:	0f b6 00             	movzbl (%eax),%eax
  800835:	0f b6 12             	movzbl (%edx),%edx
  800838:	29 d0                	sub    %edx,%eax
  80083a:	eb 05                	jmp    800841 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80083c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800841:	5b                   	pop    %ebx
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	8b 45 08             	mov    0x8(%ebp),%eax
  80084a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084e:	eb 07                	jmp    800857 <strchr+0x13>
		if (*s == c)
  800850:	38 ca                	cmp    %cl,%dl
  800852:	74 0f                	je     800863 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800854:	83 c0 01             	add    $0x1,%eax
  800857:	0f b6 10             	movzbl (%eax),%edx
  80085a:	84 d2                	test   %dl,%dl
  80085c:	75 f2                	jne    800850 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80085e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086f:	eb 03                	jmp    800874 <strfind+0xf>
  800871:	83 c0 01             	add    $0x1,%eax
  800874:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800877:	38 ca                	cmp    %cl,%dl
  800879:	74 04                	je     80087f <strfind+0x1a>
  80087b:	84 d2                	test   %dl,%dl
  80087d:	75 f2                	jne    800871 <strfind+0xc>
			break;
	return (char *) s;
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	57                   	push   %edi
  800885:	56                   	push   %esi
  800886:	53                   	push   %ebx
  800887:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80088d:	85 c9                	test   %ecx,%ecx
  80088f:	74 36                	je     8008c7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800891:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800897:	75 28                	jne    8008c1 <memset+0x40>
  800899:	f6 c1 03             	test   $0x3,%cl
  80089c:	75 23                	jne    8008c1 <memset+0x40>
		c &= 0xFF;
  80089e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008a2:	89 d3                	mov    %edx,%ebx
  8008a4:	c1 e3 08             	shl    $0x8,%ebx
  8008a7:	89 d6                	mov    %edx,%esi
  8008a9:	c1 e6 18             	shl    $0x18,%esi
  8008ac:	89 d0                	mov    %edx,%eax
  8008ae:	c1 e0 10             	shl    $0x10,%eax
  8008b1:	09 f0                	or     %esi,%eax
  8008b3:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008b5:	89 d8                	mov    %ebx,%eax
  8008b7:	09 d0                	or     %edx,%eax
  8008b9:	c1 e9 02             	shr    $0x2,%ecx
  8008bc:	fc                   	cld    
  8008bd:	f3 ab                	rep stos %eax,%es:(%edi)
  8008bf:	eb 06                	jmp    8008c7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c4:	fc                   	cld    
  8008c5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c7:	89 f8                	mov    %edi,%eax
  8008c9:	5b                   	pop    %ebx
  8008ca:	5e                   	pop    %esi
  8008cb:	5f                   	pop    %edi
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	57                   	push   %edi
  8008d2:	56                   	push   %esi
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008dc:	39 c6                	cmp    %eax,%esi
  8008de:	73 35                	jae    800915 <memmove+0x47>
  8008e0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e3:	39 d0                	cmp    %edx,%eax
  8008e5:	73 2e                	jae    800915 <memmove+0x47>
		s += n;
		d += n;
  8008e7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ea:	89 d6                	mov    %edx,%esi
  8008ec:	09 fe                	or     %edi,%esi
  8008ee:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f4:	75 13                	jne    800909 <memmove+0x3b>
  8008f6:	f6 c1 03             	test   $0x3,%cl
  8008f9:	75 0e                	jne    800909 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008fb:	83 ef 04             	sub    $0x4,%edi
  8008fe:	8d 72 fc             	lea    -0x4(%edx),%esi
  800901:	c1 e9 02             	shr    $0x2,%ecx
  800904:	fd                   	std    
  800905:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800907:	eb 09                	jmp    800912 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800909:	83 ef 01             	sub    $0x1,%edi
  80090c:	8d 72 ff             	lea    -0x1(%edx),%esi
  80090f:	fd                   	std    
  800910:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800912:	fc                   	cld    
  800913:	eb 1d                	jmp    800932 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800915:	89 f2                	mov    %esi,%edx
  800917:	09 c2                	or     %eax,%edx
  800919:	f6 c2 03             	test   $0x3,%dl
  80091c:	75 0f                	jne    80092d <memmove+0x5f>
  80091e:	f6 c1 03             	test   $0x3,%cl
  800921:	75 0a                	jne    80092d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800923:	c1 e9 02             	shr    $0x2,%ecx
  800926:	89 c7                	mov    %eax,%edi
  800928:	fc                   	cld    
  800929:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092b:	eb 05                	jmp    800932 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80092d:	89 c7                	mov    %eax,%edi
  80092f:	fc                   	cld    
  800930:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800932:	5e                   	pop    %esi
  800933:	5f                   	pop    %edi
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800939:	ff 75 10             	pushl  0x10(%ebp)
  80093c:	ff 75 0c             	pushl  0xc(%ebp)
  80093f:	ff 75 08             	pushl  0x8(%ebp)
  800942:	e8 87 ff ff ff       	call   8008ce <memmove>
}
  800947:	c9                   	leave  
  800948:	c3                   	ret    

00800949 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	56                   	push   %esi
  80094d:	53                   	push   %ebx
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8b 55 0c             	mov    0xc(%ebp),%edx
  800954:	89 c6                	mov    %eax,%esi
  800956:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800959:	eb 1a                	jmp    800975 <memcmp+0x2c>
		if (*s1 != *s2)
  80095b:	0f b6 08             	movzbl (%eax),%ecx
  80095e:	0f b6 1a             	movzbl (%edx),%ebx
  800961:	38 d9                	cmp    %bl,%cl
  800963:	74 0a                	je     80096f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800965:	0f b6 c1             	movzbl %cl,%eax
  800968:	0f b6 db             	movzbl %bl,%ebx
  80096b:	29 d8                	sub    %ebx,%eax
  80096d:	eb 0f                	jmp    80097e <memcmp+0x35>
		s1++, s2++;
  80096f:	83 c0 01             	add    $0x1,%eax
  800972:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800975:	39 f0                	cmp    %esi,%eax
  800977:	75 e2                	jne    80095b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800979:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	53                   	push   %ebx
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800989:	89 c1                	mov    %eax,%ecx
  80098b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80098e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800992:	eb 0a                	jmp    80099e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800994:	0f b6 10             	movzbl (%eax),%edx
  800997:	39 da                	cmp    %ebx,%edx
  800999:	74 07                	je     8009a2 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80099b:	83 c0 01             	add    $0x1,%eax
  80099e:	39 c8                	cmp    %ecx,%eax
  8009a0:	72 f2                	jb     800994 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009a2:	5b                   	pop    %ebx
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	57                   	push   %edi
  8009a9:	56                   	push   %esi
  8009aa:	53                   	push   %ebx
  8009ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b1:	eb 03                	jmp    8009b6 <strtol+0x11>
		s++;
  8009b3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b6:	0f b6 01             	movzbl (%ecx),%eax
  8009b9:	3c 20                	cmp    $0x20,%al
  8009bb:	74 f6                	je     8009b3 <strtol+0xe>
  8009bd:	3c 09                	cmp    $0x9,%al
  8009bf:	74 f2                	je     8009b3 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009c1:	3c 2b                	cmp    $0x2b,%al
  8009c3:	75 0a                	jne    8009cf <strtol+0x2a>
		s++;
  8009c5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c8:	bf 00 00 00 00       	mov    $0x0,%edi
  8009cd:	eb 11                	jmp    8009e0 <strtol+0x3b>
  8009cf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d4:	3c 2d                	cmp    $0x2d,%al
  8009d6:	75 08                	jne    8009e0 <strtol+0x3b>
		s++, neg = 1;
  8009d8:	83 c1 01             	add    $0x1,%ecx
  8009db:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e6:	75 15                	jne    8009fd <strtol+0x58>
  8009e8:	80 39 30             	cmpb   $0x30,(%ecx)
  8009eb:	75 10                	jne    8009fd <strtol+0x58>
  8009ed:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009f1:	75 7c                	jne    800a6f <strtol+0xca>
		s += 2, base = 16;
  8009f3:	83 c1 02             	add    $0x2,%ecx
  8009f6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009fb:	eb 16                	jmp    800a13 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009fd:	85 db                	test   %ebx,%ebx
  8009ff:	75 12                	jne    800a13 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a01:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a06:	80 39 30             	cmpb   $0x30,(%ecx)
  800a09:	75 08                	jne    800a13 <strtol+0x6e>
		s++, base = 8;
  800a0b:	83 c1 01             	add    $0x1,%ecx
  800a0e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
  800a18:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a1b:	0f b6 11             	movzbl (%ecx),%edx
  800a1e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a21:	89 f3                	mov    %esi,%ebx
  800a23:	80 fb 09             	cmp    $0x9,%bl
  800a26:	77 08                	ja     800a30 <strtol+0x8b>
			dig = *s - '0';
  800a28:	0f be d2             	movsbl %dl,%edx
  800a2b:	83 ea 30             	sub    $0x30,%edx
  800a2e:	eb 22                	jmp    800a52 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a30:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a33:	89 f3                	mov    %esi,%ebx
  800a35:	80 fb 19             	cmp    $0x19,%bl
  800a38:	77 08                	ja     800a42 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a3a:	0f be d2             	movsbl %dl,%edx
  800a3d:	83 ea 57             	sub    $0x57,%edx
  800a40:	eb 10                	jmp    800a52 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a42:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a45:	89 f3                	mov    %esi,%ebx
  800a47:	80 fb 19             	cmp    $0x19,%bl
  800a4a:	77 16                	ja     800a62 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a4c:	0f be d2             	movsbl %dl,%edx
  800a4f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a52:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a55:	7d 0b                	jge    800a62 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a57:	83 c1 01             	add    $0x1,%ecx
  800a5a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a5e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a60:	eb b9                	jmp    800a1b <strtol+0x76>

	if (endptr)
  800a62:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a66:	74 0d                	je     800a75 <strtol+0xd0>
		*endptr = (char *) s;
  800a68:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6b:	89 0e                	mov    %ecx,(%esi)
  800a6d:	eb 06                	jmp    800a75 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6f:	85 db                	test   %ebx,%ebx
  800a71:	74 98                	je     800a0b <strtol+0x66>
  800a73:	eb 9e                	jmp    800a13 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a75:	89 c2                	mov    %eax,%edx
  800a77:	f7 da                	neg    %edx
  800a79:	85 ff                	test   %edi,%edi
  800a7b:	0f 45 c2             	cmovne %edx,%eax
}
  800a7e:	5b                   	pop    %ebx
  800a7f:	5e                   	pop    %esi
  800a80:	5f                   	pop    %edi
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	57                   	push   %edi
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a89:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a91:	8b 55 08             	mov    0x8(%ebp),%edx
  800a94:	89 c3                	mov    %eax,%ebx
  800a96:	89 c7                	mov    %eax,%edi
  800a98:	89 c6                	mov    %eax,%esi
  800a9a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	57                   	push   %edi
  800aa5:	56                   	push   %esi
  800aa6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa7:	ba 00 00 00 00       	mov    $0x0,%edx
  800aac:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab1:	89 d1                	mov    %edx,%ecx
  800ab3:	89 d3                	mov    %edx,%ebx
  800ab5:	89 d7                	mov    %edx,%edi
  800ab7:	89 d6                	mov    %edx,%esi
  800ab9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800abb:	5b                   	pop    %ebx
  800abc:	5e                   	pop    %esi
  800abd:	5f                   	pop    %edi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	57                   	push   %edi
  800ac4:	56                   	push   %esi
  800ac5:	53                   	push   %ebx
  800ac6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ace:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad6:	89 cb                	mov    %ecx,%ebx
  800ad8:	89 cf                	mov    %ecx,%edi
  800ada:	89 ce                	mov    %ecx,%esi
  800adc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ade:	85 c0                	test   %eax,%eax
  800ae0:	7e 17                	jle    800af9 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae2:	83 ec 0c             	sub    $0xc,%esp
  800ae5:	50                   	push   %eax
  800ae6:	6a 03                	push   $0x3
  800ae8:	68 e8 12 80 00       	push   $0x8012e8
  800aed:	6a 23                	push   $0x23
  800aef:	68 05 13 80 00       	push   $0x801305
  800af4:	e8 86 02 00 00       	call   800d7f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b07:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0c:	b8 02 00 00 00       	mov    $0x2,%eax
  800b11:	89 d1                	mov    %edx,%ecx
  800b13:	89 d3                	mov    %edx,%ebx
  800b15:	89 d7                	mov    %edx,%edi
  800b17:	89 d6                	mov    %edx,%esi
  800b19:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b1b:	5b                   	pop    %ebx
  800b1c:	5e                   	pop    %esi
  800b1d:	5f                   	pop    %edi
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <sys_yield>:

void
sys_yield(void)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b26:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b30:	89 d1                	mov    %edx,%ecx
  800b32:	89 d3                	mov    %edx,%ebx
  800b34:	89 d7                	mov    %edx,%edi
  800b36:	89 d6                	mov    %edx,%esi
  800b38:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
  800b45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b48:	be 00 00 00 00       	mov    $0x0,%esi
  800b4d:	b8 04 00 00 00       	mov    $0x4,%eax
  800b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b55:	8b 55 08             	mov    0x8(%ebp),%edx
  800b58:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b5b:	89 f7                	mov    %esi,%edi
  800b5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b5f:	85 c0                	test   %eax,%eax
  800b61:	7e 17                	jle    800b7a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b63:	83 ec 0c             	sub    $0xc,%esp
  800b66:	50                   	push   %eax
  800b67:	6a 04                	push   $0x4
  800b69:	68 e8 12 80 00       	push   $0x8012e8
  800b6e:	6a 23                	push   $0x23
  800b70:	68 05 13 80 00       	push   $0x801305
  800b75:	e8 05 02 00 00       	call   800d7f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
  800b88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8b:	b8 05 00 00 00       	mov    $0x5,%eax
  800b90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b93:	8b 55 08             	mov    0x8(%ebp),%edx
  800b96:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b99:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b9c:	8b 75 18             	mov    0x18(%ebp),%esi
  800b9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba1:	85 c0                	test   %eax,%eax
  800ba3:	7e 17                	jle    800bbc <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba5:	83 ec 0c             	sub    $0xc,%esp
  800ba8:	50                   	push   %eax
  800ba9:	6a 05                	push   $0x5
  800bab:	68 e8 12 80 00       	push   $0x8012e8
  800bb0:	6a 23                	push   $0x23
  800bb2:	68 05 13 80 00       	push   $0x801305
  800bb7:	e8 c3 01 00 00       	call   800d7f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
  800bca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd2:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	89 df                	mov    %ebx,%edi
  800bdf:	89 de                	mov    %ebx,%esi
  800be1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be3:	85 c0                	test   %eax,%eax
  800be5:	7e 17                	jle    800bfe <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be7:	83 ec 0c             	sub    $0xc,%esp
  800bea:	50                   	push   %eax
  800beb:	6a 06                	push   $0x6
  800bed:	68 e8 12 80 00       	push   $0x8012e8
  800bf2:	6a 23                	push   $0x23
  800bf4:	68 05 13 80 00       	push   $0x801305
  800bf9:	e8 81 01 00 00       	call   800d7f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
  800c0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c14:	b8 08 00 00 00       	mov    $0x8,%eax
  800c19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1f:	89 df                	mov    %ebx,%edi
  800c21:	89 de                	mov    %ebx,%esi
  800c23:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c25:	85 c0                	test   %eax,%eax
  800c27:	7e 17                	jle    800c40 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c29:	83 ec 0c             	sub    $0xc,%esp
  800c2c:	50                   	push   %eax
  800c2d:	6a 08                	push   $0x8
  800c2f:	68 e8 12 80 00       	push   $0x8012e8
  800c34:	6a 23                	push   $0x23
  800c36:	68 05 13 80 00       	push   $0x801305
  800c3b:	e8 3f 01 00 00       	call   800d7f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c56:	b8 09 00 00 00       	mov    $0x9,%eax
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	89 df                	mov    %ebx,%edi
  800c63:	89 de                	mov    %ebx,%esi
  800c65:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	7e 17                	jle    800c82 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6b:	83 ec 0c             	sub    $0xc,%esp
  800c6e:	50                   	push   %eax
  800c6f:	6a 09                	push   $0x9
  800c71:	68 e8 12 80 00       	push   $0x8012e8
  800c76:	6a 23                	push   $0x23
  800c78:	68 05 13 80 00       	push   $0x801305
  800c7d:	e8 fd 00 00 00       	call   800d7f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c90:	be 00 00 00 00       	mov    $0x0,%esi
  800c95:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cbb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc3:	89 cb                	mov    %ecx,%ebx
  800cc5:	89 cf                	mov    %ecx,%edi
  800cc7:	89 ce                	mov    %ecx,%esi
  800cc9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	7e 17                	jle    800ce6 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	50                   	push   %eax
  800cd3:	6a 0c                	push   $0xc
  800cd5:	68 e8 12 80 00       	push   $0x8012e8
  800cda:	6a 23                	push   $0x23
  800cdc:	68 05 13 80 00       	push   $0x801305
  800ce1:	e8 99 00 00 00       	call   800d7f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ce6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800cf4:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800cfb:	75 2c                	jne    800d29 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  800cfd:	83 ec 04             	sub    $0x4,%esp
  800d00:	6a 07                	push   $0x7
  800d02:	68 00 f0 bf ee       	push   $0xeebff000
  800d07:	6a 00                	push   $0x0
  800d09:	e8 31 fe ff ff       	call   800b3f <sys_page_alloc>
  800d0e:	83 c4 10             	add    $0x10,%esp
  800d11:	85 c0                	test   %eax,%eax
  800d13:	79 14                	jns    800d29 <set_pgfault_handler+0x3b>
            panic("set sys_page_alloc");;
  800d15:	83 ec 04             	sub    $0x4,%esp
  800d18:	68 13 13 80 00       	push   $0x801313
  800d1d:	6a 21                	push   $0x21
  800d1f:	68 26 13 80 00       	push   $0x801326
  800d24:	e8 56 00 00 00       	call   800d7f <_panic>
	
	}
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800d29:	83 ec 08             	sub    $0x8,%esp
  800d2c:	68 5d 0d 80 00       	push   $0x800d5d
  800d31:	6a 00                	push   $0x0
  800d33:	e8 10 ff ff ff       	call   800c48 <sys_env_set_pgfault_upcall>
  800d38:	83 c4 10             	add    $0x10,%esp
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	79 14                	jns    800d53 <set_pgfault_handler+0x65>
        panic("set page fault handler");
  800d3f:	83 ec 04             	sub    $0x4,%esp
  800d42:	68 34 13 80 00       	push   $0x801334
  800d47:	6a 25                	push   $0x25
  800d49:	68 26 13 80 00       	push   $0x801326
  800d4e:	e8 2c 00 00 00       	call   800d7f <_panic>

	
	_pgfault_handler = handler;
  800d53:	8b 45 08             	mov    0x8(%ebp),%eax
  800d56:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d5b:	c9                   	leave  
  800d5c:	c3                   	ret    

00800d5d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d5d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d5e:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800d63:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d65:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	
	movl 0x28(%esp), %eax // moving trap-time eip in eax
  800d68:	8b 44 24 28          	mov    0x28(%esp),%eax

	
	movl %esp, %ebp// moving current stack
  800d6c:	89 e5                	mov    %esp,%ebp

	
	movl 0x30(%esp), %esp// Switch to trap-time stack
  800d6e:	8b 64 24 30          	mov    0x30(%esp),%esp

	
	pushl %eax// Push trap-time eip to the trap-time stack
  800d72:	50                   	push   %eax

	
	movl %esp, 0x30(%ebp)//update the trap-time esp with its new value
  800d73:	89 65 30             	mov    %esp,0x30(%ebp)

	
	movl %ebp, %esp// Go back to our exception stack
  800d76:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  800d78:	61                   	popa   
	
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp //eip
  800d79:	83 c4 04             	add    $0x4,%esp
   	popfl	
  800d7c:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
popl %esp
  800d7d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
ret
  800d7e:	c3                   	ret    

00800d7f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d84:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d87:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d8d:	e8 6f fd ff ff       	call   800b01 <sys_getenvid>
  800d92:	83 ec 0c             	sub    $0xc,%esp
  800d95:	ff 75 0c             	pushl  0xc(%ebp)
  800d98:	ff 75 08             	pushl  0x8(%ebp)
  800d9b:	56                   	push   %esi
  800d9c:	50                   	push   %eax
  800d9d:	68 4c 13 80 00       	push   $0x80134c
  800da2:	e8 ce f3 ff ff       	call   800175 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800da7:	83 c4 18             	add    $0x18,%esp
  800daa:	53                   	push   %ebx
  800dab:	ff 75 10             	pushl  0x10(%ebp)
  800dae:	e8 71 f3 ff ff       	call   800124 <vcprintf>
	cprintf("\n");
  800db3:	c7 04 24 ba 10 80 00 	movl   $0x8010ba,(%esp)
  800dba:	e8 b6 f3 ff ff       	call   800175 <cprintf>
  800dbf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800dc2:	cc                   	int3   
  800dc3:	eb fd                	jmp    800dc2 <_panic+0x43>
  800dc5:	66 90                	xchg   %ax,%ax
  800dc7:	66 90                	xchg   %ax,%ax
  800dc9:	66 90                	xchg   %ax,%ax
  800dcb:	66 90                	xchg   %ax,%ax
  800dcd:	66 90                	xchg   %ax,%ax
  800dcf:	90                   	nop

00800dd0 <__udivdi3>:
  800dd0:	55                   	push   %ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 1c             	sub    $0x1c,%esp
  800dd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800ddb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800ddf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800de3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800de7:	85 f6                	test   %esi,%esi
  800de9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ded:	89 ca                	mov    %ecx,%edx
  800def:	89 f8                	mov    %edi,%eax
  800df1:	75 3d                	jne    800e30 <__udivdi3+0x60>
  800df3:	39 cf                	cmp    %ecx,%edi
  800df5:	0f 87 c5 00 00 00    	ja     800ec0 <__udivdi3+0xf0>
  800dfb:	85 ff                	test   %edi,%edi
  800dfd:	89 fd                	mov    %edi,%ebp
  800dff:	75 0b                	jne    800e0c <__udivdi3+0x3c>
  800e01:	b8 01 00 00 00       	mov    $0x1,%eax
  800e06:	31 d2                	xor    %edx,%edx
  800e08:	f7 f7                	div    %edi
  800e0a:	89 c5                	mov    %eax,%ebp
  800e0c:	89 c8                	mov    %ecx,%eax
  800e0e:	31 d2                	xor    %edx,%edx
  800e10:	f7 f5                	div    %ebp
  800e12:	89 c1                	mov    %eax,%ecx
  800e14:	89 d8                	mov    %ebx,%eax
  800e16:	89 cf                	mov    %ecx,%edi
  800e18:	f7 f5                	div    %ebp
  800e1a:	89 c3                	mov    %eax,%ebx
  800e1c:	89 d8                	mov    %ebx,%eax
  800e1e:	89 fa                	mov    %edi,%edx
  800e20:	83 c4 1c             	add    $0x1c,%esp
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    
  800e28:	90                   	nop
  800e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e30:	39 ce                	cmp    %ecx,%esi
  800e32:	77 74                	ja     800ea8 <__udivdi3+0xd8>
  800e34:	0f bd fe             	bsr    %esi,%edi
  800e37:	83 f7 1f             	xor    $0x1f,%edi
  800e3a:	0f 84 98 00 00 00    	je     800ed8 <__udivdi3+0x108>
  800e40:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e45:	89 f9                	mov    %edi,%ecx
  800e47:	89 c5                	mov    %eax,%ebp
  800e49:	29 fb                	sub    %edi,%ebx
  800e4b:	d3 e6                	shl    %cl,%esi
  800e4d:	89 d9                	mov    %ebx,%ecx
  800e4f:	d3 ed                	shr    %cl,%ebp
  800e51:	89 f9                	mov    %edi,%ecx
  800e53:	d3 e0                	shl    %cl,%eax
  800e55:	09 ee                	or     %ebp,%esi
  800e57:	89 d9                	mov    %ebx,%ecx
  800e59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e5d:	89 d5                	mov    %edx,%ebp
  800e5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e63:	d3 ed                	shr    %cl,%ebp
  800e65:	89 f9                	mov    %edi,%ecx
  800e67:	d3 e2                	shl    %cl,%edx
  800e69:	89 d9                	mov    %ebx,%ecx
  800e6b:	d3 e8                	shr    %cl,%eax
  800e6d:	09 c2                	or     %eax,%edx
  800e6f:	89 d0                	mov    %edx,%eax
  800e71:	89 ea                	mov    %ebp,%edx
  800e73:	f7 f6                	div    %esi
  800e75:	89 d5                	mov    %edx,%ebp
  800e77:	89 c3                	mov    %eax,%ebx
  800e79:	f7 64 24 0c          	mull   0xc(%esp)
  800e7d:	39 d5                	cmp    %edx,%ebp
  800e7f:	72 10                	jb     800e91 <__udivdi3+0xc1>
  800e81:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e85:	89 f9                	mov    %edi,%ecx
  800e87:	d3 e6                	shl    %cl,%esi
  800e89:	39 c6                	cmp    %eax,%esi
  800e8b:	73 07                	jae    800e94 <__udivdi3+0xc4>
  800e8d:	39 d5                	cmp    %edx,%ebp
  800e8f:	75 03                	jne    800e94 <__udivdi3+0xc4>
  800e91:	83 eb 01             	sub    $0x1,%ebx
  800e94:	31 ff                	xor    %edi,%edi
  800e96:	89 d8                	mov    %ebx,%eax
  800e98:	89 fa                	mov    %edi,%edx
  800e9a:	83 c4 1c             	add    $0x1c,%esp
  800e9d:	5b                   	pop    %ebx
  800e9e:	5e                   	pop    %esi
  800e9f:	5f                   	pop    %edi
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    
  800ea2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ea8:	31 ff                	xor    %edi,%edi
  800eaa:	31 db                	xor    %ebx,%ebx
  800eac:	89 d8                	mov    %ebx,%eax
  800eae:	89 fa                	mov    %edi,%edx
  800eb0:	83 c4 1c             	add    $0x1c,%esp
  800eb3:	5b                   	pop    %ebx
  800eb4:	5e                   	pop    %esi
  800eb5:	5f                   	pop    %edi
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    
  800eb8:	90                   	nop
  800eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	89 d8                	mov    %ebx,%eax
  800ec2:	f7 f7                	div    %edi
  800ec4:	31 ff                	xor    %edi,%edi
  800ec6:	89 c3                	mov    %eax,%ebx
  800ec8:	89 d8                	mov    %ebx,%eax
  800eca:	89 fa                	mov    %edi,%edx
  800ecc:	83 c4 1c             	add    $0x1c,%esp
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5f                   	pop    %edi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    
  800ed4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ed8:	39 ce                	cmp    %ecx,%esi
  800eda:	72 0c                	jb     800ee8 <__udivdi3+0x118>
  800edc:	31 db                	xor    %ebx,%ebx
  800ede:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ee2:	0f 87 34 ff ff ff    	ja     800e1c <__udivdi3+0x4c>
  800ee8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800eed:	e9 2a ff ff ff       	jmp    800e1c <__udivdi3+0x4c>
  800ef2:	66 90                	xchg   %ax,%ax
  800ef4:	66 90                	xchg   %ax,%ax
  800ef6:	66 90                	xchg   %ax,%ax
  800ef8:	66 90                	xchg   %ax,%ax
  800efa:	66 90                	xchg   %ax,%ax
  800efc:	66 90                	xchg   %ax,%ax
  800efe:	66 90                	xchg   %ax,%ax

00800f00 <__umoddi3>:
  800f00:	55                   	push   %ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	83 ec 1c             	sub    $0x1c,%esp
  800f07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f17:	85 d2                	test   %edx,%edx
  800f19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f21:	89 f3                	mov    %esi,%ebx
  800f23:	89 3c 24             	mov    %edi,(%esp)
  800f26:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f2a:	75 1c                	jne    800f48 <__umoddi3+0x48>
  800f2c:	39 f7                	cmp    %esi,%edi
  800f2e:	76 50                	jbe    800f80 <__umoddi3+0x80>
  800f30:	89 c8                	mov    %ecx,%eax
  800f32:	89 f2                	mov    %esi,%edx
  800f34:	f7 f7                	div    %edi
  800f36:	89 d0                	mov    %edx,%eax
  800f38:	31 d2                	xor    %edx,%edx
  800f3a:	83 c4 1c             	add    $0x1c,%esp
  800f3d:	5b                   	pop    %ebx
  800f3e:	5e                   	pop    %esi
  800f3f:	5f                   	pop    %edi
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    
  800f42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f48:	39 f2                	cmp    %esi,%edx
  800f4a:	89 d0                	mov    %edx,%eax
  800f4c:	77 52                	ja     800fa0 <__umoddi3+0xa0>
  800f4e:	0f bd ea             	bsr    %edx,%ebp
  800f51:	83 f5 1f             	xor    $0x1f,%ebp
  800f54:	75 5a                	jne    800fb0 <__umoddi3+0xb0>
  800f56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f5a:	0f 82 e0 00 00 00    	jb     801040 <__umoddi3+0x140>
  800f60:	39 0c 24             	cmp    %ecx,(%esp)
  800f63:	0f 86 d7 00 00 00    	jbe    801040 <__umoddi3+0x140>
  800f69:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f71:	83 c4 1c             	add    $0x1c,%esp
  800f74:	5b                   	pop    %ebx
  800f75:	5e                   	pop    %esi
  800f76:	5f                   	pop    %edi
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    
  800f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f80:	85 ff                	test   %edi,%edi
  800f82:	89 fd                	mov    %edi,%ebp
  800f84:	75 0b                	jne    800f91 <__umoddi3+0x91>
  800f86:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8b:	31 d2                	xor    %edx,%edx
  800f8d:	f7 f7                	div    %edi
  800f8f:	89 c5                	mov    %eax,%ebp
  800f91:	89 f0                	mov    %esi,%eax
  800f93:	31 d2                	xor    %edx,%edx
  800f95:	f7 f5                	div    %ebp
  800f97:	89 c8                	mov    %ecx,%eax
  800f99:	f7 f5                	div    %ebp
  800f9b:	89 d0                	mov    %edx,%eax
  800f9d:	eb 99                	jmp    800f38 <__umoddi3+0x38>
  800f9f:	90                   	nop
  800fa0:	89 c8                	mov    %ecx,%eax
  800fa2:	89 f2                	mov    %esi,%edx
  800fa4:	83 c4 1c             	add    $0x1c,%esp
  800fa7:	5b                   	pop    %ebx
  800fa8:	5e                   	pop    %esi
  800fa9:	5f                   	pop    %edi
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    
  800fac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fb0:	8b 34 24             	mov    (%esp),%esi
  800fb3:	bf 20 00 00 00       	mov    $0x20,%edi
  800fb8:	89 e9                	mov    %ebp,%ecx
  800fba:	29 ef                	sub    %ebp,%edi
  800fbc:	d3 e0                	shl    %cl,%eax
  800fbe:	89 f9                	mov    %edi,%ecx
  800fc0:	89 f2                	mov    %esi,%edx
  800fc2:	d3 ea                	shr    %cl,%edx
  800fc4:	89 e9                	mov    %ebp,%ecx
  800fc6:	09 c2                	or     %eax,%edx
  800fc8:	89 d8                	mov    %ebx,%eax
  800fca:	89 14 24             	mov    %edx,(%esp)
  800fcd:	89 f2                	mov    %esi,%edx
  800fcf:	d3 e2                	shl    %cl,%edx
  800fd1:	89 f9                	mov    %edi,%ecx
  800fd3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fd7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800fdb:	d3 e8                	shr    %cl,%eax
  800fdd:	89 e9                	mov    %ebp,%ecx
  800fdf:	89 c6                	mov    %eax,%esi
  800fe1:	d3 e3                	shl    %cl,%ebx
  800fe3:	89 f9                	mov    %edi,%ecx
  800fe5:	89 d0                	mov    %edx,%eax
  800fe7:	d3 e8                	shr    %cl,%eax
  800fe9:	89 e9                	mov    %ebp,%ecx
  800feb:	09 d8                	or     %ebx,%eax
  800fed:	89 d3                	mov    %edx,%ebx
  800fef:	89 f2                	mov    %esi,%edx
  800ff1:	f7 34 24             	divl   (%esp)
  800ff4:	89 d6                	mov    %edx,%esi
  800ff6:	d3 e3                	shl    %cl,%ebx
  800ff8:	f7 64 24 04          	mull   0x4(%esp)
  800ffc:	39 d6                	cmp    %edx,%esi
  800ffe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801002:	89 d1                	mov    %edx,%ecx
  801004:	89 c3                	mov    %eax,%ebx
  801006:	72 08                	jb     801010 <__umoddi3+0x110>
  801008:	75 11                	jne    80101b <__umoddi3+0x11b>
  80100a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80100e:	73 0b                	jae    80101b <__umoddi3+0x11b>
  801010:	2b 44 24 04          	sub    0x4(%esp),%eax
  801014:	1b 14 24             	sbb    (%esp),%edx
  801017:	89 d1                	mov    %edx,%ecx
  801019:	89 c3                	mov    %eax,%ebx
  80101b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80101f:	29 da                	sub    %ebx,%edx
  801021:	19 ce                	sbb    %ecx,%esi
  801023:	89 f9                	mov    %edi,%ecx
  801025:	89 f0                	mov    %esi,%eax
  801027:	d3 e0                	shl    %cl,%eax
  801029:	89 e9                	mov    %ebp,%ecx
  80102b:	d3 ea                	shr    %cl,%edx
  80102d:	89 e9                	mov    %ebp,%ecx
  80102f:	d3 ee                	shr    %cl,%esi
  801031:	09 d0                	or     %edx,%eax
  801033:	89 f2                	mov    %esi,%edx
  801035:	83 c4 1c             	add    $0x1c,%esp
  801038:	5b                   	pop    %ebx
  801039:	5e                   	pop    %esi
  80103a:	5f                   	pop    %edi
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    
  80103d:	8d 76 00             	lea    0x0(%esi),%esi
  801040:	29 f9                	sub    %edi,%ecx
  801042:	19 d6                	sbb    %edx,%esi
  801044:	89 74 24 04          	mov    %esi,0x4(%esp)
  801048:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80104c:	e9 18 ff ff ff       	jmp    800f69 <__umoddi3+0x69>
