
obj/user/faultdie.debug:     file format elf32-i386


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
  800045:	68 80 1e 80 00       	push   $0x801e80
  80004a:	e8 24 01 00 00       	call   800173 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 69 0a 00 00       	call   800abd <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 20 0a 00 00       	call   800a7c <sys_env_destroy>
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
  80006c:	e8 7b 0c 00 00       	call   800cec <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
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
	thisenv = &envs[ENVX(sys_getenvid())];
  80008b:	e8 2d 0a 00 00       	call   800abd <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	e8 aa ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 0a 00 00 00       	call   8000c6 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000cc:	e8 5c 0e 00 00       	call   800f2d <close_all>
	sys_env_destroy(0);
  8000d1:	83 ec 0c             	sub    $0xc,%esp
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 a1 09 00 00       	call   800a7c <sys_env_destroy>
}
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 04             	sub    $0x4,%esp
  8000e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ea:	8b 13                	mov    (%ebx),%edx
  8000ec:	8d 42 01             	lea    0x1(%edx),%eax
  8000ef:	89 03                	mov    %eax,(%ebx)
  8000f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000fd:	75 1a                	jne    800119 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000ff:	83 ec 08             	sub    $0x8,%esp
  800102:	68 ff 00 00 00       	push   $0xff
  800107:	8d 43 08             	lea    0x8(%ebx),%eax
  80010a:	50                   	push   %eax
  80010b:	e8 2f 09 00 00       	call   800a3f <sys_cputs>
		b->idx = 0;
  800110:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800116:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800119:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800132:	00 00 00 
	b.cnt = 0;
  800135:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013f:	ff 75 0c             	pushl  0xc(%ebp)
  800142:	ff 75 08             	pushl  0x8(%ebp)
  800145:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014b:	50                   	push   %eax
  80014c:	68 e0 00 80 00       	push   $0x8000e0
  800151:	e8 54 01 00 00       	call   8002aa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80015f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	e8 d4 08 00 00       	call   800a3f <sys_cputs>

	return b.cnt;
}
  80016b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800179:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017c:	50                   	push   %eax
  80017d:	ff 75 08             	pushl  0x8(%ebp)
  800180:	e8 9d ff ff ff       	call   800122 <vcprintf>
	va_end(ap);

	return cnt;
}
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 1c             	sub    $0x1c,%esp
  800190:	89 c7                	mov    %eax,%edi
  800192:	89 d6                	mov    %edx,%esi
  800194:	8b 45 08             	mov    0x8(%ebp),%eax
  800197:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ab:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ae:	39 d3                	cmp    %edx,%ebx
  8001b0:	72 05                	jb     8001b7 <printnum+0x30>
  8001b2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b5:	77 45                	ja     8001fc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b7:	83 ec 0c             	sub    $0xc,%esp
  8001ba:	ff 75 18             	pushl  0x18(%ebp)
  8001bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c3:	53                   	push   %ebx
  8001c4:	ff 75 10             	pushl  0x10(%ebp)
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d6:	e8 15 1a 00 00       	call   801bf0 <__udivdi3>
  8001db:	83 c4 18             	add    $0x18,%esp
  8001de:	52                   	push   %edx
  8001df:	50                   	push   %eax
  8001e0:	89 f2                	mov    %esi,%edx
  8001e2:	89 f8                	mov    %edi,%eax
  8001e4:	e8 9e ff ff ff       	call   800187 <printnum>
  8001e9:	83 c4 20             	add    $0x20,%esp
  8001ec:	eb 18                	jmp    800206 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	56                   	push   %esi
  8001f2:	ff 75 18             	pushl  0x18(%ebp)
  8001f5:	ff d7                	call   *%edi
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	eb 03                	jmp    8001ff <printnum+0x78>
  8001fc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ff:	83 eb 01             	sub    $0x1,%ebx
  800202:	85 db                	test   %ebx,%ebx
  800204:	7f e8                	jg     8001ee <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800206:	83 ec 08             	sub    $0x8,%esp
  800209:	56                   	push   %esi
  80020a:	83 ec 04             	sub    $0x4,%esp
  80020d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800210:	ff 75 e0             	pushl  -0x20(%ebp)
  800213:	ff 75 dc             	pushl  -0x24(%ebp)
  800216:	ff 75 d8             	pushl  -0x28(%ebp)
  800219:	e8 02 1b 00 00       	call   801d20 <__umoddi3>
  80021e:	83 c4 14             	add    $0x14,%esp
  800221:	0f be 80 a6 1e 80 00 	movsbl 0x801ea6(%eax),%eax
  800228:	50                   	push   %eax
  800229:	ff d7                	call   *%edi
}
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800231:	5b                   	pop    %ebx
  800232:	5e                   	pop    %esi
  800233:	5f                   	pop    %edi
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800239:	83 fa 01             	cmp    $0x1,%edx
  80023c:	7e 0e                	jle    80024c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80023e:	8b 10                	mov    (%eax),%edx
  800240:	8d 4a 08             	lea    0x8(%edx),%ecx
  800243:	89 08                	mov    %ecx,(%eax)
  800245:	8b 02                	mov    (%edx),%eax
  800247:	8b 52 04             	mov    0x4(%edx),%edx
  80024a:	eb 22                	jmp    80026e <getuint+0x38>
	else if (lflag)
  80024c:	85 d2                	test   %edx,%edx
  80024e:	74 10                	je     800260 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800250:	8b 10                	mov    (%eax),%edx
  800252:	8d 4a 04             	lea    0x4(%edx),%ecx
  800255:	89 08                	mov    %ecx,(%eax)
  800257:	8b 02                	mov    (%edx),%eax
  800259:	ba 00 00 00 00       	mov    $0x0,%edx
  80025e:	eb 0e                	jmp    80026e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800260:	8b 10                	mov    (%eax),%edx
  800262:	8d 4a 04             	lea    0x4(%edx),%ecx
  800265:	89 08                	mov    %ecx,(%eax)
  800267:	8b 02                	mov    (%edx),%eax
  800269:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80026e:	5d                   	pop    %ebp
  80026f:	c3                   	ret    

00800270 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800276:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	3b 50 04             	cmp    0x4(%eax),%edx
  80027f:	73 0a                	jae    80028b <sprintputch+0x1b>
		*b->buf++ = ch;
  800281:	8d 4a 01             	lea    0x1(%edx),%ecx
  800284:	89 08                	mov    %ecx,(%eax)
  800286:	8b 45 08             	mov    0x8(%ebp),%eax
  800289:	88 02                	mov    %al,(%edx)
}
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    

0080028d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800293:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800296:	50                   	push   %eax
  800297:	ff 75 10             	pushl  0x10(%ebp)
  80029a:	ff 75 0c             	pushl  0xc(%ebp)
  80029d:	ff 75 08             	pushl  0x8(%ebp)
  8002a0:	e8 05 00 00 00       	call   8002aa <vprintfmt>
	va_end(ap);
}
  8002a5:	83 c4 10             	add    $0x10,%esp
  8002a8:	c9                   	leave  
  8002a9:	c3                   	ret    

008002aa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	57                   	push   %edi
  8002ae:	56                   	push   %esi
  8002af:	53                   	push   %ebx
  8002b0:	83 ec 2c             	sub    $0x2c,%esp
  8002b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002bc:	eb 12                	jmp    8002d0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002be:	85 c0                	test   %eax,%eax
  8002c0:	0f 84 89 03 00 00    	je     80064f <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002c6:	83 ec 08             	sub    $0x8,%esp
  8002c9:	53                   	push   %ebx
  8002ca:	50                   	push   %eax
  8002cb:	ff d6                	call   *%esi
  8002cd:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d0:	83 c7 01             	add    $0x1,%edi
  8002d3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002d7:	83 f8 25             	cmp    $0x25,%eax
  8002da:	75 e2                	jne    8002be <vprintfmt+0x14>
  8002dc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002e0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002e7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002ee:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fa:	eb 07                	jmp    800303 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002ff:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800303:	8d 47 01             	lea    0x1(%edi),%eax
  800306:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800309:	0f b6 07             	movzbl (%edi),%eax
  80030c:	0f b6 c8             	movzbl %al,%ecx
  80030f:	83 e8 23             	sub    $0x23,%eax
  800312:	3c 55                	cmp    $0x55,%al
  800314:	0f 87 1a 03 00 00    	ja     800634 <vprintfmt+0x38a>
  80031a:	0f b6 c0             	movzbl %al,%eax
  80031d:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  800324:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800327:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80032b:	eb d6                	jmp    800303 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800330:	b8 00 00 00 00       	mov    $0x0,%eax
  800335:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800338:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80033f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800342:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800345:	83 fa 09             	cmp    $0x9,%edx
  800348:	77 39                	ja     800383 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80034a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80034d:	eb e9                	jmp    800338 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80034f:	8b 45 14             	mov    0x14(%ebp),%eax
  800352:	8d 48 04             	lea    0x4(%eax),%ecx
  800355:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800358:	8b 00                	mov    (%eax),%eax
  80035a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800360:	eb 27                	jmp    800389 <vprintfmt+0xdf>
  800362:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800365:	85 c0                	test   %eax,%eax
  800367:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036c:	0f 49 c8             	cmovns %eax,%ecx
  80036f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800375:	eb 8c                	jmp    800303 <vprintfmt+0x59>
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80037a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800381:	eb 80                	jmp    800303 <vprintfmt+0x59>
  800383:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800386:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800389:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80038d:	0f 89 70 ff ff ff    	jns    800303 <vprintfmt+0x59>
				width = precision, precision = -1;
  800393:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800396:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800399:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a0:	e9 5e ff ff ff       	jmp    800303 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a5:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ab:	e9 53 ff ff ff       	jmp    800303 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8d 50 04             	lea    0x4(%eax),%edx
  8003b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b9:	83 ec 08             	sub    $0x8,%esp
  8003bc:	53                   	push   %ebx
  8003bd:	ff 30                	pushl  (%eax)
  8003bf:	ff d6                	call   *%esi
			break;
  8003c1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c7:	e9 04 ff ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cf:	8d 50 04             	lea    0x4(%eax),%edx
  8003d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d5:	8b 00                	mov    (%eax),%eax
  8003d7:	99                   	cltd   
  8003d8:	31 d0                	xor    %edx,%eax
  8003da:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003dc:	83 f8 0f             	cmp    $0xf,%eax
  8003df:	7f 0b                	jg     8003ec <vprintfmt+0x142>
  8003e1:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  8003e8:	85 d2                	test   %edx,%edx
  8003ea:	75 18                	jne    800404 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ec:	50                   	push   %eax
  8003ed:	68 be 1e 80 00       	push   $0x801ebe
  8003f2:	53                   	push   %ebx
  8003f3:	56                   	push   %esi
  8003f4:	e8 94 fe ff ff       	call   80028d <printfmt>
  8003f9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003ff:	e9 cc fe ff ff       	jmp    8002d0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800404:	52                   	push   %edx
  800405:	68 76 22 80 00       	push   $0x802276
  80040a:	53                   	push   %ebx
  80040b:	56                   	push   %esi
  80040c:	e8 7c fe ff ff       	call   80028d <printfmt>
  800411:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800417:	e9 b4 fe ff ff       	jmp    8002d0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80041c:	8b 45 14             	mov    0x14(%ebp),%eax
  80041f:	8d 50 04             	lea    0x4(%eax),%edx
  800422:	89 55 14             	mov    %edx,0x14(%ebp)
  800425:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800427:	85 ff                	test   %edi,%edi
  800429:	b8 b7 1e 80 00       	mov    $0x801eb7,%eax
  80042e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800431:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800435:	0f 8e 94 00 00 00    	jle    8004cf <vprintfmt+0x225>
  80043b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80043f:	0f 84 98 00 00 00    	je     8004dd <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800445:	83 ec 08             	sub    $0x8,%esp
  800448:	ff 75 d0             	pushl  -0x30(%ebp)
  80044b:	57                   	push   %edi
  80044c:	e8 86 02 00 00       	call   8006d7 <strnlen>
  800451:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800454:	29 c1                	sub    %eax,%ecx
  800456:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800459:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80045c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800460:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800463:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800466:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800468:	eb 0f                	jmp    800479 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80046a:	83 ec 08             	sub    $0x8,%esp
  80046d:	53                   	push   %ebx
  80046e:	ff 75 e0             	pushl  -0x20(%ebp)
  800471:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800473:	83 ef 01             	sub    $0x1,%edi
  800476:	83 c4 10             	add    $0x10,%esp
  800479:	85 ff                	test   %edi,%edi
  80047b:	7f ed                	jg     80046a <vprintfmt+0x1c0>
  80047d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800480:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800483:	85 c9                	test   %ecx,%ecx
  800485:	b8 00 00 00 00       	mov    $0x0,%eax
  80048a:	0f 49 c1             	cmovns %ecx,%eax
  80048d:	29 c1                	sub    %eax,%ecx
  80048f:	89 75 08             	mov    %esi,0x8(%ebp)
  800492:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800495:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800498:	89 cb                	mov    %ecx,%ebx
  80049a:	eb 4d                	jmp    8004e9 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80049c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a0:	74 1b                	je     8004bd <vprintfmt+0x213>
  8004a2:	0f be c0             	movsbl %al,%eax
  8004a5:	83 e8 20             	sub    $0x20,%eax
  8004a8:	83 f8 5e             	cmp    $0x5e,%eax
  8004ab:	76 10                	jbe    8004bd <vprintfmt+0x213>
					putch('?', putdat);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	ff 75 0c             	pushl  0xc(%ebp)
  8004b3:	6a 3f                	push   $0x3f
  8004b5:	ff 55 08             	call   *0x8(%ebp)
  8004b8:	83 c4 10             	add    $0x10,%esp
  8004bb:	eb 0d                	jmp    8004ca <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	ff 75 0c             	pushl  0xc(%ebp)
  8004c3:	52                   	push   %edx
  8004c4:	ff 55 08             	call   *0x8(%ebp)
  8004c7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ca:	83 eb 01             	sub    $0x1,%ebx
  8004cd:	eb 1a                	jmp    8004e9 <vprintfmt+0x23f>
  8004cf:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004db:	eb 0c                	jmp    8004e9 <vprintfmt+0x23f>
  8004dd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004e9:	83 c7 01             	add    $0x1,%edi
  8004ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f0:	0f be d0             	movsbl %al,%edx
  8004f3:	85 d2                	test   %edx,%edx
  8004f5:	74 23                	je     80051a <vprintfmt+0x270>
  8004f7:	85 f6                	test   %esi,%esi
  8004f9:	78 a1                	js     80049c <vprintfmt+0x1f2>
  8004fb:	83 ee 01             	sub    $0x1,%esi
  8004fe:	79 9c                	jns    80049c <vprintfmt+0x1f2>
  800500:	89 df                	mov    %ebx,%edi
  800502:	8b 75 08             	mov    0x8(%ebp),%esi
  800505:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800508:	eb 18                	jmp    800522 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	53                   	push   %ebx
  80050e:	6a 20                	push   $0x20
  800510:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800512:	83 ef 01             	sub    $0x1,%edi
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	eb 08                	jmp    800522 <vprintfmt+0x278>
  80051a:	89 df                	mov    %ebx,%edi
  80051c:	8b 75 08             	mov    0x8(%ebp),%esi
  80051f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800522:	85 ff                	test   %edi,%edi
  800524:	7f e4                	jg     80050a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800529:	e9 a2 fd ff ff       	jmp    8002d0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80052e:	83 fa 01             	cmp    $0x1,%edx
  800531:	7e 16                	jle    800549 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 50 08             	lea    0x8(%eax),%edx
  800539:	89 55 14             	mov    %edx,0x14(%ebp)
  80053c:	8b 50 04             	mov    0x4(%eax),%edx
  80053f:	8b 00                	mov    (%eax),%eax
  800541:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800544:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800547:	eb 32                	jmp    80057b <vprintfmt+0x2d1>
	else if (lflag)
  800549:	85 d2                	test   %edx,%edx
  80054b:	74 18                	je     800565 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 50 04             	lea    0x4(%eax),%edx
  800553:	89 55 14             	mov    %edx,0x14(%ebp)
  800556:	8b 00                	mov    (%eax),%eax
  800558:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055b:	89 c1                	mov    %eax,%ecx
  80055d:	c1 f9 1f             	sar    $0x1f,%ecx
  800560:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800563:	eb 16                	jmp    80057b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8d 50 04             	lea    0x4(%eax),%edx
  80056b:	89 55 14             	mov    %edx,0x14(%ebp)
  80056e:	8b 00                	mov    (%eax),%eax
  800570:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800573:	89 c1                	mov    %eax,%ecx
  800575:	c1 f9 1f             	sar    $0x1f,%ecx
  800578:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80057e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800581:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800586:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80058a:	79 74                	jns    800600 <vprintfmt+0x356>
				putch('-', putdat);
  80058c:	83 ec 08             	sub    $0x8,%esp
  80058f:	53                   	push   %ebx
  800590:	6a 2d                	push   $0x2d
  800592:	ff d6                	call   *%esi
				num = -(long long) num;
  800594:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800597:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80059a:	f7 d8                	neg    %eax
  80059c:	83 d2 00             	adc    $0x0,%edx
  80059f:	f7 da                	neg    %edx
  8005a1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a4:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005a9:	eb 55                	jmp    800600 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ae:	e8 83 fc ff ff       	call   800236 <getuint>
			base = 10;
  8005b3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005b8:	eb 46                	jmp    800600 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bd:	e8 74 fc ff ff       	call   800236 <getuint>
                        base = 8;
  8005c2:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8005c7:	eb 37                	jmp    800600 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	53                   	push   %ebx
  8005cd:	6a 30                	push   $0x30
  8005cf:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d1:	83 c4 08             	add    $0x8,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	6a 78                	push   $0x78
  8005d7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8d 50 04             	lea    0x4(%eax),%edx
  8005df:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005e9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ec:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005f1:	eb 0d                	jmp    800600 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f6:	e8 3b fc ff ff       	call   800236 <getuint>
			base = 16;
  8005fb:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800600:	83 ec 0c             	sub    $0xc,%esp
  800603:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800607:	57                   	push   %edi
  800608:	ff 75 e0             	pushl  -0x20(%ebp)
  80060b:	51                   	push   %ecx
  80060c:	52                   	push   %edx
  80060d:	50                   	push   %eax
  80060e:	89 da                	mov    %ebx,%edx
  800610:	89 f0                	mov    %esi,%eax
  800612:	e8 70 fb ff ff       	call   800187 <printnum>
			break;
  800617:	83 c4 20             	add    $0x20,%esp
  80061a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061d:	e9 ae fc ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800622:	83 ec 08             	sub    $0x8,%esp
  800625:	53                   	push   %ebx
  800626:	51                   	push   %ecx
  800627:	ff d6                	call   *%esi
			break;
  800629:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80062f:	e9 9c fc ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800634:	83 ec 08             	sub    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	6a 25                	push   $0x25
  80063a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80063c:	83 c4 10             	add    $0x10,%esp
  80063f:	eb 03                	jmp    800644 <vprintfmt+0x39a>
  800641:	83 ef 01             	sub    $0x1,%edi
  800644:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800648:	75 f7                	jne    800641 <vprintfmt+0x397>
  80064a:	e9 81 fc ff ff       	jmp    8002d0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80064f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800652:	5b                   	pop    %ebx
  800653:	5e                   	pop    %esi
  800654:	5f                   	pop    %edi
  800655:	5d                   	pop    %ebp
  800656:	c3                   	ret    

00800657 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	83 ec 18             	sub    $0x18,%esp
  80065d:	8b 45 08             	mov    0x8(%ebp),%eax
  800660:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800663:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800666:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80066a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80066d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800674:	85 c0                	test   %eax,%eax
  800676:	74 26                	je     80069e <vsnprintf+0x47>
  800678:	85 d2                	test   %edx,%edx
  80067a:	7e 22                	jle    80069e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80067c:	ff 75 14             	pushl  0x14(%ebp)
  80067f:	ff 75 10             	pushl  0x10(%ebp)
  800682:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800685:	50                   	push   %eax
  800686:	68 70 02 80 00       	push   $0x800270
  80068b:	e8 1a fc ff ff       	call   8002aa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800690:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800693:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800696:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800699:	83 c4 10             	add    $0x10,%esp
  80069c:	eb 05                	jmp    8006a3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80069e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006a3:	c9                   	leave  
  8006a4:	c3                   	ret    

008006a5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a5:	55                   	push   %ebp
  8006a6:	89 e5                	mov    %esp,%ebp
  8006a8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ab:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ae:	50                   	push   %eax
  8006af:	ff 75 10             	pushl  0x10(%ebp)
  8006b2:	ff 75 0c             	pushl  0xc(%ebp)
  8006b5:	ff 75 08             	pushl  0x8(%ebp)
  8006b8:	e8 9a ff ff ff       	call   800657 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006bd:	c9                   	leave  
  8006be:	c3                   	ret    

008006bf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006bf:	55                   	push   %ebp
  8006c0:	89 e5                	mov    %esp,%ebp
  8006c2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ca:	eb 03                	jmp    8006cf <strlen+0x10>
		n++;
  8006cc:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006cf:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006d3:	75 f7                	jne    8006cc <strlen+0xd>
		n++;
	return n;
}
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006dd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e5:	eb 03                	jmp    8006ea <strnlen+0x13>
		n++;
  8006e7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ea:	39 c2                	cmp    %eax,%edx
  8006ec:	74 08                	je     8006f6 <strnlen+0x1f>
  8006ee:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006f2:	75 f3                	jne    8006e7 <strnlen+0x10>
  8006f4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006f6:	5d                   	pop    %ebp
  8006f7:	c3                   	ret    

008006f8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	53                   	push   %ebx
  8006fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800702:	89 c2                	mov    %eax,%edx
  800704:	83 c2 01             	add    $0x1,%edx
  800707:	83 c1 01             	add    $0x1,%ecx
  80070a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80070e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800711:	84 db                	test   %bl,%bl
  800713:	75 ef                	jne    800704 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800715:	5b                   	pop    %ebx
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	53                   	push   %ebx
  80071c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80071f:	53                   	push   %ebx
  800720:	e8 9a ff ff ff       	call   8006bf <strlen>
  800725:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800728:	ff 75 0c             	pushl  0xc(%ebp)
  80072b:	01 d8                	add    %ebx,%eax
  80072d:	50                   	push   %eax
  80072e:	e8 c5 ff ff ff       	call   8006f8 <strcpy>
	return dst;
}
  800733:	89 d8                	mov    %ebx,%eax
  800735:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800738:	c9                   	leave  
  800739:	c3                   	ret    

0080073a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	56                   	push   %esi
  80073e:	53                   	push   %ebx
  80073f:	8b 75 08             	mov    0x8(%ebp),%esi
  800742:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800745:	89 f3                	mov    %esi,%ebx
  800747:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80074a:	89 f2                	mov    %esi,%edx
  80074c:	eb 0f                	jmp    80075d <strncpy+0x23>
		*dst++ = *src;
  80074e:	83 c2 01             	add    $0x1,%edx
  800751:	0f b6 01             	movzbl (%ecx),%eax
  800754:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800757:	80 39 01             	cmpb   $0x1,(%ecx)
  80075a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075d:	39 da                	cmp    %ebx,%edx
  80075f:	75 ed                	jne    80074e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800761:	89 f0                	mov    %esi,%eax
  800763:	5b                   	pop    %ebx
  800764:	5e                   	pop    %esi
  800765:	5d                   	pop    %ebp
  800766:	c3                   	ret    

00800767 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	56                   	push   %esi
  80076b:	53                   	push   %ebx
  80076c:	8b 75 08             	mov    0x8(%ebp),%esi
  80076f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800772:	8b 55 10             	mov    0x10(%ebp),%edx
  800775:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800777:	85 d2                	test   %edx,%edx
  800779:	74 21                	je     80079c <strlcpy+0x35>
  80077b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80077f:	89 f2                	mov    %esi,%edx
  800781:	eb 09                	jmp    80078c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800783:	83 c2 01             	add    $0x1,%edx
  800786:	83 c1 01             	add    $0x1,%ecx
  800789:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80078c:	39 c2                	cmp    %eax,%edx
  80078e:	74 09                	je     800799 <strlcpy+0x32>
  800790:	0f b6 19             	movzbl (%ecx),%ebx
  800793:	84 db                	test   %bl,%bl
  800795:	75 ec                	jne    800783 <strlcpy+0x1c>
  800797:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800799:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80079c:	29 f0                	sub    %esi,%eax
}
  80079e:	5b                   	pop    %ebx
  80079f:	5e                   	pop    %esi
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ab:	eb 06                	jmp    8007b3 <strcmp+0x11>
		p++, q++;
  8007ad:	83 c1 01             	add    $0x1,%ecx
  8007b0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007b3:	0f b6 01             	movzbl (%ecx),%eax
  8007b6:	84 c0                	test   %al,%al
  8007b8:	74 04                	je     8007be <strcmp+0x1c>
  8007ba:	3a 02                	cmp    (%edx),%al
  8007bc:	74 ef                	je     8007ad <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007be:	0f b6 c0             	movzbl %al,%eax
  8007c1:	0f b6 12             	movzbl (%edx),%edx
  8007c4:	29 d0                	sub    %edx,%eax
}
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	53                   	push   %ebx
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d2:	89 c3                	mov    %eax,%ebx
  8007d4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007d7:	eb 06                	jmp    8007df <strncmp+0x17>
		n--, p++, q++;
  8007d9:	83 c0 01             	add    $0x1,%eax
  8007dc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007df:	39 d8                	cmp    %ebx,%eax
  8007e1:	74 15                	je     8007f8 <strncmp+0x30>
  8007e3:	0f b6 08             	movzbl (%eax),%ecx
  8007e6:	84 c9                	test   %cl,%cl
  8007e8:	74 04                	je     8007ee <strncmp+0x26>
  8007ea:	3a 0a                	cmp    (%edx),%cl
  8007ec:	74 eb                	je     8007d9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ee:	0f b6 00             	movzbl (%eax),%eax
  8007f1:	0f b6 12             	movzbl (%edx),%edx
  8007f4:	29 d0                	sub    %edx,%eax
  8007f6:	eb 05                	jmp    8007fd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007f8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007fd:	5b                   	pop    %ebx
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80080a:	eb 07                	jmp    800813 <strchr+0x13>
		if (*s == c)
  80080c:	38 ca                	cmp    %cl,%dl
  80080e:	74 0f                	je     80081f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800810:	83 c0 01             	add    $0x1,%eax
  800813:	0f b6 10             	movzbl (%eax),%edx
  800816:	84 d2                	test   %dl,%dl
  800818:	75 f2                	jne    80080c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80081a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082b:	eb 03                	jmp    800830 <strfind+0xf>
  80082d:	83 c0 01             	add    $0x1,%eax
  800830:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800833:	38 ca                	cmp    %cl,%dl
  800835:	74 04                	je     80083b <strfind+0x1a>
  800837:	84 d2                	test   %dl,%dl
  800839:	75 f2                	jne    80082d <strfind+0xc>
			break;
	return (char *) s;
}
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	57                   	push   %edi
  800841:	56                   	push   %esi
  800842:	53                   	push   %ebx
  800843:	8b 7d 08             	mov    0x8(%ebp),%edi
  800846:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800849:	85 c9                	test   %ecx,%ecx
  80084b:	74 36                	je     800883 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80084d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800853:	75 28                	jne    80087d <memset+0x40>
  800855:	f6 c1 03             	test   $0x3,%cl
  800858:	75 23                	jne    80087d <memset+0x40>
		c &= 0xFF;
  80085a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80085e:	89 d3                	mov    %edx,%ebx
  800860:	c1 e3 08             	shl    $0x8,%ebx
  800863:	89 d6                	mov    %edx,%esi
  800865:	c1 e6 18             	shl    $0x18,%esi
  800868:	89 d0                	mov    %edx,%eax
  80086a:	c1 e0 10             	shl    $0x10,%eax
  80086d:	09 f0                	or     %esi,%eax
  80086f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800871:	89 d8                	mov    %ebx,%eax
  800873:	09 d0                	or     %edx,%eax
  800875:	c1 e9 02             	shr    $0x2,%ecx
  800878:	fc                   	cld    
  800879:	f3 ab                	rep stos %eax,%es:(%edi)
  80087b:	eb 06                	jmp    800883 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80087d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800880:	fc                   	cld    
  800881:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800883:	89 f8                	mov    %edi,%eax
  800885:	5b                   	pop    %ebx
  800886:	5e                   	pop    %esi
  800887:	5f                   	pop    %edi
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	57                   	push   %edi
  80088e:	56                   	push   %esi
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	8b 75 0c             	mov    0xc(%ebp),%esi
  800895:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800898:	39 c6                	cmp    %eax,%esi
  80089a:	73 35                	jae    8008d1 <memmove+0x47>
  80089c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80089f:	39 d0                	cmp    %edx,%eax
  8008a1:	73 2e                	jae    8008d1 <memmove+0x47>
		s += n;
		d += n;
  8008a3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a6:	89 d6                	mov    %edx,%esi
  8008a8:	09 fe                	or     %edi,%esi
  8008aa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008b0:	75 13                	jne    8008c5 <memmove+0x3b>
  8008b2:	f6 c1 03             	test   $0x3,%cl
  8008b5:	75 0e                	jne    8008c5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008b7:	83 ef 04             	sub    $0x4,%edi
  8008ba:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008bd:	c1 e9 02             	shr    $0x2,%ecx
  8008c0:	fd                   	std    
  8008c1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c3:	eb 09                	jmp    8008ce <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008c5:	83 ef 01             	sub    $0x1,%edi
  8008c8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008cb:	fd                   	std    
  8008cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ce:	fc                   	cld    
  8008cf:	eb 1d                	jmp    8008ee <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d1:	89 f2                	mov    %esi,%edx
  8008d3:	09 c2                	or     %eax,%edx
  8008d5:	f6 c2 03             	test   $0x3,%dl
  8008d8:	75 0f                	jne    8008e9 <memmove+0x5f>
  8008da:	f6 c1 03             	test   $0x3,%cl
  8008dd:	75 0a                	jne    8008e9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008df:	c1 e9 02             	shr    $0x2,%ecx
  8008e2:	89 c7                	mov    %eax,%edi
  8008e4:	fc                   	cld    
  8008e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e7:	eb 05                	jmp    8008ee <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008e9:	89 c7                	mov    %eax,%edi
  8008eb:	fc                   	cld    
  8008ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ee:	5e                   	pop    %esi
  8008ef:	5f                   	pop    %edi
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008f5:	ff 75 10             	pushl  0x10(%ebp)
  8008f8:	ff 75 0c             	pushl  0xc(%ebp)
  8008fb:	ff 75 08             	pushl  0x8(%ebp)
  8008fe:	e8 87 ff ff ff       	call   80088a <memmove>
}
  800903:	c9                   	leave  
  800904:	c3                   	ret    

00800905 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	56                   	push   %esi
  800909:	53                   	push   %ebx
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800910:	89 c6                	mov    %eax,%esi
  800912:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800915:	eb 1a                	jmp    800931 <memcmp+0x2c>
		if (*s1 != *s2)
  800917:	0f b6 08             	movzbl (%eax),%ecx
  80091a:	0f b6 1a             	movzbl (%edx),%ebx
  80091d:	38 d9                	cmp    %bl,%cl
  80091f:	74 0a                	je     80092b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800921:	0f b6 c1             	movzbl %cl,%eax
  800924:	0f b6 db             	movzbl %bl,%ebx
  800927:	29 d8                	sub    %ebx,%eax
  800929:	eb 0f                	jmp    80093a <memcmp+0x35>
		s1++, s2++;
  80092b:	83 c0 01             	add    $0x1,%eax
  80092e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800931:	39 f0                	cmp    %esi,%eax
  800933:	75 e2                	jne    800917 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093a:	5b                   	pop    %ebx
  80093b:	5e                   	pop    %esi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	53                   	push   %ebx
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800945:	89 c1                	mov    %eax,%ecx
  800947:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80094a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80094e:	eb 0a                	jmp    80095a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800950:	0f b6 10             	movzbl (%eax),%edx
  800953:	39 da                	cmp    %ebx,%edx
  800955:	74 07                	je     80095e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800957:	83 c0 01             	add    $0x1,%eax
  80095a:	39 c8                	cmp    %ecx,%eax
  80095c:	72 f2                	jb     800950 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80095e:	5b                   	pop    %ebx
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	57                   	push   %edi
  800965:	56                   	push   %esi
  800966:	53                   	push   %ebx
  800967:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80096d:	eb 03                	jmp    800972 <strtol+0x11>
		s++;
  80096f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800972:	0f b6 01             	movzbl (%ecx),%eax
  800975:	3c 20                	cmp    $0x20,%al
  800977:	74 f6                	je     80096f <strtol+0xe>
  800979:	3c 09                	cmp    $0x9,%al
  80097b:	74 f2                	je     80096f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80097d:	3c 2b                	cmp    $0x2b,%al
  80097f:	75 0a                	jne    80098b <strtol+0x2a>
		s++;
  800981:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800984:	bf 00 00 00 00       	mov    $0x0,%edi
  800989:	eb 11                	jmp    80099c <strtol+0x3b>
  80098b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800990:	3c 2d                	cmp    $0x2d,%al
  800992:	75 08                	jne    80099c <strtol+0x3b>
		s++, neg = 1;
  800994:	83 c1 01             	add    $0x1,%ecx
  800997:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80099c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009a2:	75 15                	jne    8009b9 <strtol+0x58>
  8009a4:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a7:	75 10                	jne    8009b9 <strtol+0x58>
  8009a9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ad:	75 7c                	jne    800a2b <strtol+0xca>
		s += 2, base = 16;
  8009af:	83 c1 02             	add    $0x2,%ecx
  8009b2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009b7:	eb 16                	jmp    8009cf <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009b9:	85 db                	test   %ebx,%ebx
  8009bb:	75 12                	jne    8009cf <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009bd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009c2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c5:	75 08                	jne    8009cf <strtol+0x6e>
		s++, base = 8;
  8009c7:	83 c1 01             	add    $0x1,%ecx
  8009ca:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009d7:	0f b6 11             	movzbl (%ecx),%edx
  8009da:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009dd:	89 f3                	mov    %esi,%ebx
  8009df:	80 fb 09             	cmp    $0x9,%bl
  8009e2:	77 08                	ja     8009ec <strtol+0x8b>
			dig = *s - '0';
  8009e4:	0f be d2             	movsbl %dl,%edx
  8009e7:	83 ea 30             	sub    $0x30,%edx
  8009ea:	eb 22                	jmp    800a0e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009ec:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009ef:	89 f3                	mov    %esi,%ebx
  8009f1:	80 fb 19             	cmp    $0x19,%bl
  8009f4:	77 08                	ja     8009fe <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009f6:	0f be d2             	movsbl %dl,%edx
  8009f9:	83 ea 57             	sub    $0x57,%edx
  8009fc:	eb 10                	jmp    800a0e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009fe:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a01:	89 f3                	mov    %esi,%ebx
  800a03:	80 fb 19             	cmp    $0x19,%bl
  800a06:	77 16                	ja     800a1e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a08:	0f be d2             	movsbl %dl,%edx
  800a0b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a0e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a11:	7d 0b                	jge    800a1e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a13:	83 c1 01             	add    $0x1,%ecx
  800a16:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a1a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a1c:	eb b9                	jmp    8009d7 <strtol+0x76>

	if (endptr)
  800a1e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a22:	74 0d                	je     800a31 <strtol+0xd0>
		*endptr = (char *) s;
  800a24:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a27:	89 0e                	mov    %ecx,(%esi)
  800a29:	eb 06                	jmp    800a31 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a2b:	85 db                	test   %ebx,%ebx
  800a2d:	74 98                	je     8009c7 <strtol+0x66>
  800a2f:	eb 9e                	jmp    8009cf <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a31:	89 c2                	mov    %eax,%edx
  800a33:	f7 da                	neg    %edx
  800a35:	85 ff                	test   %edi,%edi
  800a37:	0f 45 c2             	cmovne %edx,%eax
}
  800a3a:	5b                   	pop    %ebx
  800a3b:	5e                   	pop    %esi
  800a3c:	5f                   	pop    %edi
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	57                   	push   %edi
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a50:	89 c3                	mov    %eax,%ebx
  800a52:	89 c7                	mov    %eax,%edi
  800a54:	89 c6                	mov    %eax,%esi
  800a56:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a58:	5b                   	pop    %ebx
  800a59:	5e                   	pop    %esi
  800a5a:	5f                   	pop    %edi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <sys_cgetc>:

int
sys_cgetc(void)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	57                   	push   %edi
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a63:	ba 00 00 00 00       	mov    $0x0,%edx
  800a68:	b8 01 00 00 00       	mov    $0x1,%eax
  800a6d:	89 d1                	mov    %edx,%ecx
  800a6f:	89 d3                	mov    %edx,%ebx
  800a71:	89 d7                	mov    %edx,%edi
  800a73:	89 d6                	mov    %edx,%esi
  800a75:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5f                   	pop    %edi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	57                   	push   %edi
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
  800a82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a92:	89 cb                	mov    %ecx,%ebx
  800a94:	89 cf                	mov    %ecx,%edi
  800a96:	89 ce                	mov    %ecx,%esi
  800a98:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a9a:	85 c0                	test   %eax,%eax
  800a9c:	7e 17                	jle    800ab5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a9e:	83 ec 0c             	sub    $0xc,%esp
  800aa1:	50                   	push   %eax
  800aa2:	6a 03                	push   $0x3
  800aa4:	68 9f 21 80 00       	push   $0x80219f
  800aa9:	6a 23                	push   $0x23
  800aab:	68 bc 21 80 00       	push   $0x8021bc
  800ab0:	e8 c0 0f 00 00       	call   801a75 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ab5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac8:	b8 02 00 00 00       	mov    $0x2,%eax
  800acd:	89 d1                	mov    %edx,%ecx
  800acf:	89 d3                	mov    %edx,%ebx
  800ad1:	89 d7                	mov    %edx,%edi
  800ad3:	89 d6                	mov    %edx,%esi
  800ad5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <sys_yield>:

void
sys_yield(void)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	57                   	push   %edi
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800aec:	89 d1                	mov    %edx,%ecx
  800aee:	89 d3                	mov    %edx,%ebx
  800af0:	89 d7                	mov    %edx,%edi
  800af2:	89 d6                	mov    %edx,%esi
  800af4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
  800b01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	be 00 00 00 00       	mov    $0x0,%esi
  800b09:	b8 04 00 00 00       	mov    $0x4,%eax
  800b0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b11:	8b 55 08             	mov    0x8(%ebp),%edx
  800b14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b17:	89 f7                	mov    %esi,%edi
  800b19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	7e 17                	jle    800b36 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1f:	83 ec 0c             	sub    $0xc,%esp
  800b22:	50                   	push   %eax
  800b23:	6a 04                	push   $0x4
  800b25:	68 9f 21 80 00       	push   $0x80219f
  800b2a:	6a 23                	push   $0x23
  800b2c:	68 bc 21 80 00       	push   $0x8021bc
  800b31:	e8 3f 0f 00 00       	call   801a75 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
  800b44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b47:	b8 05 00 00 00       	mov    $0x5,%eax
  800b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b55:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b58:	8b 75 18             	mov    0x18(%ebp),%esi
  800b5b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	7e 17                	jle    800b78 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b61:	83 ec 0c             	sub    $0xc,%esp
  800b64:	50                   	push   %eax
  800b65:	6a 05                	push   $0x5
  800b67:	68 9f 21 80 00       	push   $0x80219f
  800b6c:	6a 23                	push   $0x23
  800b6e:	68 bc 21 80 00       	push   $0x8021bc
  800b73:	e8 fd 0e 00 00       	call   801a75 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b8e:	b8 06 00 00 00       	mov    $0x6,%eax
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b96:	8b 55 08             	mov    0x8(%ebp),%edx
  800b99:	89 df                	mov    %ebx,%edi
  800b9b:	89 de                	mov    %ebx,%esi
  800b9d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9f:	85 c0                	test   %eax,%eax
  800ba1:	7e 17                	jle    800bba <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	50                   	push   %eax
  800ba7:	6a 06                	push   $0x6
  800ba9:	68 9f 21 80 00       	push   $0x80219f
  800bae:	6a 23                	push   $0x23
  800bb0:	68 bc 21 80 00       	push   $0x8021bc
  800bb5:	e8 bb 0e 00 00       	call   801a75 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd0:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdb:	89 df                	mov    %ebx,%edi
  800bdd:	89 de                	mov    %ebx,%esi
  800bdf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be1:	85 c0                	test   %eax,%eax
  800be3:	7e 17                	jle    800bfc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	50                   	push   %eax
  800be9:	6a 08                	push   $0x8
  800beb:	68 9f 21 80 00       	push   $0x80219f
  800bf0:	6a 23                	push   $0x23
  800bf2:	68 bc 21 80 00       	push   $0x8021bc
  800bf7:	e8 79 0e 00 00       	call   801a75 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c12:	b8 09 00 00 00       	mov    $0x9,%eax
  800c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	89 df                	mov    %ebx,%edi
  800c1f:	89 de                	mov    %ebx,%esi
  800c21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 17                	jle    800c3e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	50                   	push   %eax
  800c2b:	6a 09                	push   $0x9
  800c2d:	68 9f 21 80 00       	push   $0x80219f
  800c32:	6a 23                	push   $0x23
  800c34:	68 bc 21 80 00       	push   $0x8021bc
  800c39:	e8 37 0e 00 00       	call   801a75 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c54:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	89 df                	mov    %ebx,%edi
  800c61:	89 de                	mov    %ebx,%esi
  800c63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7e 17                	jle    800c80 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	50                   	push   %eax
  800c6d:	6a 0a                	push   $0xa
  800c6f:	68 9f 21 80 00       	push   $0x80219f
  800c74:	6a 23                	push   $0x23
  800c76:	68 bc 21 80 00       	push   $0x8021bc
  800c7b:	e8 f5 0d 00 00       	call   801a75 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8e:	be 00 00 00 00       	mov    $0x0,%esi
  800c93:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ca6:	5b                   	pop    %ebx
  800ca7:	5e                   	pop    %esi
  800ca8:	5f                   	pop    %edi
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
  800cb1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	89 cb                	mov    %ecx,%ebx
  800cc3:	89 cf                	mov    %ecx,%edi
  800cc5:	89 ce                	mov    %ecx,%esi
  800cc7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	7e 17                	jle    800ce4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	83 ec 0c             	sub    $0xc,%esp
  800cd0:	50                   	push   %eax
  800cd1:	6a 0d                	push   $0xd
  800cd3:	68 9f 21 80 00       	push   $0x80219f
  800cd8:	6a 23                	push   $0x23
  800cda:	68 bc 21 80 00       	push   $0x8021bc
  800cdf:	e8 91 0d 00 00       	call   801a75 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ce4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	53                   	push   %ebx
  800cf0:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  800cf3:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800cfa:	75 28                	jne    800d24 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  800cfc:	e8 bc fd ff ff       	call   800abd <sys_getenvid>
  800d01:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  800d03:	83 ec 04             	sub    $0x4,%esp
  800d06:	6a 06                	push   $0x6
  800d08:	68 00 f0 bf ee       	push   $0xeebff000
  800d0d:	50                   	push   %eax
  800d0e:	e8 e8 fd ff ff       	call   800afb <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  800d13:	83 c4 08             	add    $0x8,%esp
  800d16:	68 31 0d 80 00       	push   $0x800d31
  800d1b:	53                   	push   %ebx
  800d1c:	e8 25 ff ff ff       	call   800c46 <sys_env_set_pgfault_upcall>
  800d21:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d24:	8b 45 08             	mov    0x8(%ebp),%eax
  800d27:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800d2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d2f:	c9                   	leave  
  800d30:	c3                   	ret    

00800d31 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d31:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d32:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800d37:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d39:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  800d3c:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  800d3e:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  800d41:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  800d44:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  800d47:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  800d4a:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  800d4d:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  800d50:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  800d53:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  800d56:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  800d59:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  800d5c:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  800d5f:	61                   	popa   
	popfl
  800d60:	9d                   	popf   
	ret
  800d61:	c3                   	ret    

00800d62 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d65:	8b 45 08             	mov    0x8(%ebp),%eax
  800d68:	05 00 00 00 30       	add    $0x30000000,%eax
  800d6d:	c1 e8 0c             	shr    $0xc,%eax
}
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d75:	8b 45 08             	mov    0x8(%ebp),%eax
  800d78:	05 00 00 00 30       	add    $0x30000000,%eax
  800d7d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d82:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d8f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d94:	89 c2                	mov    %eax,%edx
  800d96:	c1 ea 16             	shr    $0x16,%edx
  800d99:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800da0:	f6 c2 01             	test   $0x1,%dl
  800da3:	74 11                	je     800db6 <fd_alloc+0x2d>
  800da5:	89 c2                	mov    %eax,%edx
  800da7:	c1 ea 0c             	shr    $0xc,%edx
  800daa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800db1:	f6 c2 01             	test   $0x1,%dl
  800db4:	75 09                	jne    800dbf <fd_alloc+0x36>
			*fd_store = fd;
  800db6:	89 01                	mov    %eax,(%ecx)
			return 0;
  800db8:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbd:	eb 17                	jmp    800dd6 <fd_alloc+0x4d>
  800dbf:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dc4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dc9:	75 c9                	jne    800d94 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dcb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dd1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    

00800dd8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dde:	83 f8 1f             	cmp    $0x1f,%eax
  800de1:	77 36                	ja     800e19 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800de3:	c1 e0 0c             	shl    $0xc,%eax
  800de6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800deb:	89 c2                	mov    %eax,%edx
  800ded:	c1 ea 16             	shr    $0x16,%edx
  800df0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800df7:	f6 c2 01             	test   $0x1,%dl
  800dfa:	74 24                	je     800e20 <fd_lookup+0x48>
  800dfc:	89 c2                	mov    %eax,%edx
  800dfe:	c1 ea 0c             	shr    $0xc,%edx
  800e01:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e08:	f6 c2 01             	test   $0x1,%dl
  800e0b:	74 1a                	je     800e27 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e10:	89 02                	mov    %eax,(%edx)
	return 0;
  800e12:	b8 00 00 00 00       	mov    $0x0,%eax
  800e17:	eb 13                	jmp    800e2c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e19:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e1e:	eb 0c                	jmp    800e2c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e20:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e25:	eb 05                	jmp    800e2c <fd_lookup+0x54>
  800e27:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    

00800e2e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	83 ec 08             	sub    $0x8,%esp
  800e34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e37:	ba 48 22 80 00       	mov    $0x802248,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e3c:	eb 13                	jmp    800e51 <dev_lookup+0x23>
  800e3e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e41:	39 08                	cmp    %ecx,(%eax)
  800e43:	75 0c                	jne    800e51 <dev_lookup+0x23>
			*dev = devtab[i];
  800e45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e48:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4f:	eb 2e                	jmp    800e7f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e51:	8b 02                	mov    (%edx),%eax
  800e53:	85 c0                	test   %eax,%eax
  800e55:	75 e7                	jne    800e3e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e57:	a1 04 40 80 00       	mov    0x804004,%eax
  800e5c:	8b 40 48             	mov    0x48(%eax),%eax
  800e5f:	83 ec 04             	sub    $0x4,%esp
  800e62:	51                   	push   %ecx
  800e63:	50                   	push   %eax
  800e64:	68 cc 21 80 00       	push   $0x8021cc
  800e69:	e8 05 f3 ff ff       	call   800173 <cprintf>
	*dev = 0;
  800e6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e71:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e77:	83 c4 10             	add    $0x10,%esp
  800e7a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e7f:	c9                   	leave  
  800e80:	c3                   	ret    

00800e81 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	56                   	push   %esi
  800e85:	53                   	push   %ebx
  800e86:	83 ec 10             	sub    $0x10,%esp
  800e89:	8b 75 08             	mov    0x8(%ebp),%esi
  800e8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e92:	50                   	push   %eax
  800e93:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e99:	c1 e8 0c             	shr    $0xc,%eax
  800e9c:	50                   	push   %eax
  800e9d:	e8 36 ff ff ff       	call   800dd8 <fd_lookup>
  800ea2:	83 c4 08             	add    $0x8,%esp
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	78 05                	js     800eae <fd_close+0x2d>
	    || fd != fd2)
  800ea9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800eac:	74 0c                	je     800eba <fd_close+0x39>
		return (must_exist ? r : 0);
  800eae:	84 db                	test   %bl,%bl
  800eb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb5:	0f 44 c2             	cmove  %edx,%eax
  800eb8:	eb 41                	jmp    800efb <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800eba:	83 ec 08             	sub    $0x8,%esp
  800ebd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ec0:	50                   	push   %eax
  800ec1:	ff 36                	pushl  (%esi)
  800ec3:	e8 66 ff ff ff       	call   800e2e <dev_lookup>
  800ec8:	89 c3                	mov    %eax,%ebx
  800eca:	83 c4 10             	add    $0x10,%esp
  800ecd:	85 c0                	test   %eax,%eax
  800ecf:	78 1a                	js     800eeb <fd_close+0x6a>
		if (dev->dev_close)
  800ed1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ed4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ed7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800edc:	85 c0                	test   %eax,%eax
  800ede:	74 0b                	je     800eeb <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ee0:	83 ec 0c             	sub    $0xc,%esp
  800ee3:	56                   	push   %esi
  800ee4:	ff d0                	call   *%eax
  800ee6:	89 c3                	mov    %eax,%ebx
  800ee8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800eeb:	83 ec 08             	sub    $0x8,%esp
  800eee:	56                   	push   %esi
  800eef:	6a 00                	push   $0x0
  800ef1:	e8 8a fc ff ff       	call   800b80 <sys_page_unmap>
	return r;
  800ef6:	83 c4 10             	add    $0x10,%esp
  800ef9:	89 d8                	mov    %ebx,%eax
}
  800efb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800efe:	5b                   	pop    %ebx
  800eff:	5e                   	pop    %esi
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    

00800f02 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
  800f05:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f0b:	50                   	push   %eax
  800f0c:	ff 75 08             	pushl  0x8(%ebp)
  800f0f:	e8 c4 fe ff ff       	call   800dd8 <fd_lookup>
  800f14:	83 c4 08             	add    $0x8,%esp
  800f17:	85 c0                	test   %eax,%eax
  800f19:	78 10                	js     800f2b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f1b:	83 ec 08             	sub    $0x8,%esp
  800f1e:	6a 01                	push   $0x1
  800f20:	ff 75 f4             	pushl  -0xc(%ebp)
  800f23:	e8 59 ff ff ff       	call   800e81 <fd_close>
  800f28:	83 c4 10             	add    $0x10,%esp
}
  800f2b:	c9                   	leave  
  800f2c:	c3                   	ret    

00800f2d <close_all>:

void
close_all(void)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	53                   	push   %ebx
  800f31:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f34:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f39:	83 ec 0c             	sub    $0xc,%esp
  800f3c:	53                   	push   %ebx
  800f3d:	e8 c0 ff ff ff       	call   800f02 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f42:	83 c3 01             	add    $0x1,%ebx
  800f45:	83 c4 10             	add    $0x10,%esp
  800f48:	83 fb 20             	cmp    $0x20,%ebx
  800f4b:	75 ec                	jne    800f39 <close_all+0xc>
		close(i);
}
  800f4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f50:	c9                   	leave  
  800f51:	c3                   	ret    

00800f52 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	57                   	push   %edi
  800f56:	56                   	push   %esi
  800f57:	53                   	push   %ebx
  800f58:	83 ec 2c             	sub    $0x2c,%esp
  800f5b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f5e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f61:	50                   	push   %eax
  800f62:	ff 75 08             	pushl  0x8(%ebp)
  800f65:	e8 6e fe ff ff       	call   800dd8 <fd_lookup>
  800f6a:	83 c4 08             	add    $0x8,%esp
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	0f 88 c1 00 00 00    	js     801036 <dup+0xe4>
		return r;
	close(newfdnum);
  800f75:	83 ec 0c             	sub    $0xc,%esp
  800f78:	56                   	push   %esi
  800f79:	e8 84 ff ff ff       	call   800f02 <close>

	newfd = INDEX2FD(newfdnum);
  800f7e:	89 f3                	mov    %esi,%ebx
  800f80:	c1 e3 0c             	shl    $0xc,%ebx
  800f83:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f89:	83 c4 04             	add    $0x4,%esp
  800f8c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f8f:	e8 de fd ff ff       	call   800d72 <fd2data>
  800f94:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f96:	89 1c 24             	mov    %ebx,(%esp)
  800f99:	e8 d4 fd ff ff       	call   800d72 <fd2data>
  800f9e:	83 c4 10             	add    $0x10,%esp
  800fa1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fa4:	89 f8                	mov    %edi,%eax
  800fa6:	c1 e8 16             	shr    $0x16,%eax
  800fa9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fb0:	a8 01                	test   $0x1,%al
  800fb2:	74 37                	je     800feb <dup+0x99>
  800fb4:	89 f8                	mov    %edi,%eax
  800fb6:	c1 e8 0c             	shr    $0xc,%eax
  800fb9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fc0:	f6 c2 01             	test   $0x1,%dl
  800fc3:	74 26                	je     800feb <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fc5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fcc:	83 ec 0c             	sub    $0xc,%esp
  800fcf:	25 07 0e 00 00       	and    $0xe07,%eax
  800fd4:	50                   	push   %eax
  800fd5:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fd8:	6a 00                	push   $0x0
  800fda:	57                   	push   %edi
  800fdb:	6a 00                	push   $0x0
  800fdd:	e8 5c fb ff ff       	call   800b3e <sys_page_map>
  800fe2:	89 c7                	mov    %eax,%edi
  800fe4:	83 c4 20             	add    $0x20,%esp
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	78 2e                	js     801019 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800feb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fee:	89 d0                	mov    %edx,%eax
  800ff0:	c1 e8 0c             	shr    $0xc,%eax
  800ff3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ffa:	83 ec 0c             	sub    $0xc,%esp
  800ffd:	25 07 0e 00 00       	and    $0xe07,%eax
  801002:	50                   	push   %eax
  801003:	53                   	push   %ebx
  801004:	6a 00                	push   $0x0
  801006:	52                   	push   %edx
  801007:	6a 00                	push   $0x0
  801009:	e8 30 fb ff ff       	call   800b3e <sys_page_map>
  80100e:	89 c7                	mov    %eax,%edi
  801010:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801013:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801015:	85 ff                	test   %edi,%edi
  801017:	79 1d                	jns    801036 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801019:	83 ec 08             	sub    $0x8,%esp
  80101c:	53                   	push   %ebx
  80101d:	6a 00                	push   $0x0
  80101f:	e8 5c fb ff ff       	call   800b80 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801024:	83 c4 08             	add    $0x8,%esp
  801027:	ff 75 d4             	pushl  -0x2c(%ebp)
  80102a:	6a 00                	push   $0x0
  80102c:	e8 4f fb ff ff       	call   800b80 <sys_page_unmap>
	return r;
  801031:	83 c4 10             	add    $0x10,%esp
  801034:	89 f8                	mov    %edi,%eax
}
  801036:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801039:	5b                   	pop    %ebx
  80103a:	5e                   	pop    %esi
  80103b:	5f                   	pop    %edi
  80103c:	5d                   	pop    %ebp
  80103d:	c3                   	ret    

0080103e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
  801041:	53                   	push   %ebx
  801042:	83 ec 14             	sub    $0x14,%esp
  801045:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801048:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80104b:	50                   	push   %eax
  80104c:	53                   	push   %ebx
  80104d:	e8 86 fd ff ff       	call   800dd8 <fd_lookup>
  801052:	83 c4 08             	add    $0x8,%esp
  801055:	89 c2                	mov    %eax,%edx
  801057:	85 c0                	test   %eax,%eax
  801059:	78 6d                	js     8010c8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80105b:	83 ec 08             	sub    $0x8,%esp
  80105e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801061:	50                   	push   %eax
  801062:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801065:	ff 30                	pushl  (%eax)
  801067:	e8 c2 fd ff ff       	call   800e2e <dev_lookup>
  80106c:	83 c4 10             	add    $0x10,%esp
  80106f:	85 c0                	test   %eax,%eax
  801071:	78 4c                	js     8010bf <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801073:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801076:	8b 42 08             	mov    0x8(%edx),%eax
  801079:	83 e0 03             	and    $0x3,%eax
  80107c:	83 f8 01             	cmp    $0x1,%eax
  80107f:	75 21                	jne    8010a2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801081:	a1 04 40 80 00       	mov    0x804004,%eax
  801086:	8b 40 48             	mov    0x48(%eax),%eax
  801089:	83 ec 04             	sub    $0x4,%esp
  80108c:	53                   	push   %ebx
  80108d:	50                   	push   %eax
  80108e:	68 0d 22 80 00       	push   $0x80220d
  801093:	e8 db f0 ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  801098:	83 c4 10             	add    $0x10,%esp
  80109b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010a0:	eb 26                	jmp    8010c8 <read+0x8a>
	}
	if (!dev->dev_read)
  8010a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a5:	8b 40 08             	mov    0x8(%eax),%eax
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	74 17                	je     8010c3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010ac:	83 ec 04             	sub    $0x4,%esp
  8010af:	ff 75 10             	pushl  0x10(%ebp)
  8010b2:	ff 75 0c             	pushl  0xc(%ebp)
  8010b5:	52                   	push   %edx
  8010b6:	ff d0                	call   *%eax
  8010b8:	89 c2                	mov    %eax,%edx
  8010ba:	83 c4 10             	add    $0x10,%esp
  8010bd:	eb 09                	jmp    8010c8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010bf:	89 c2                	mov    %eax,%edx
  8010c1:	eb 05                	jmp    8010c8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010c3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010c8:	89 d0                	mov    %edx,%eax
  8010ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010cd:	c9                   	leave  
  8010ce:	c3                   	ret    

008010cf <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	57                   	push   %edi
  8010d3:	56                   	push   %esi
  8010d4:	53                   	push   %ebx
  8010d5:	83 ec 0c             	sub    $0xc,%esp
  8010d8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010db:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010e3:	eb 21                	jmp    801106 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010e5:	83 ec 04             	sub    $0x4,%esp
  8010e8:	89 f0                	mov    %esi,%eax
  8010ea:	29 d8                	sub    %ebx,%eax
  8010ec:	50                   	push   %eax
  8010ed:	89 d8                	mov    %ebx,%eax
  8010ef:	03 45 0c             	add    0xc(%ebp),%eax
  8010f2:	50                   	push   %eax
  8010f3:	57                   	push   %edi
  8010f4:	e8 45 ff ff ff       	call   80103e <read>
		if (m < 0)
  8010f9:	83 c4 10             	add    $0x10,%esp
  8010fc:	85 c0                	test   %eax,%eax
  8010fe:	78 10                	js     801110 <readn+0x41>
			return m;
		if (m == 0)
  801100:	85 c0                	test   %eax,%eax
  801102:	74 0a                	je     80110e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801104:	01 c3                	add    %eax,%ebx
  801106:	39 f3                	cmp    %esi,%ebx
  801108:	72 db                	jb     8010e5 <readn+0x16>
  80110a:	89 d8                	mov    %ebx,%eax
  80110c:	eb 02                	jmp    801110 <readn+0x41>
  80110e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801113:	5b                   	pop    %ebx
  801114:	5e                   	pop    %esi
  801115:	5f                   	pop    %edi
  801116:	5d                   	pop    %ebp
  801117:	c3                   	ret    

00801118 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	53                   	push   %ebx
  80111c:	83 ec 14             	sub    $0x14,%esp
  80111f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801122:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801125:	50                   	push   %eax
  801126:	53                   	push   %ebx
  801127:	e8 ac fc ff ff       	call   800dd8 <fd_lookup>
  80112c:	83 c4 08             	add    $0x8,%esp
  80112f:	89 c2                	mov    %eax,%edx
  801131:	85 c0                	test   %eax,%eax
  801133:	78 68                	js     80119d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801135:	83 ec 08             	sub    $0x8,%esp
  801138:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80113b:	50                   	push   %eax
  80113c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80113f:	ff 30                	pushl  (%eax)
  801141:	e8 e8 fc ff ff       	call   800e2e <dev_lookup>
  801146:	83 c4 10             	add    $0x10,%esp
  801149:	85 c0                	test   %eax,%eax
  80114b:	78 47                	js     801194 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80114d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801150:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801154:	75 21                	jne    801177 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801156:	a1 04 40 80 00       	mov    0x804004,%eax
  80115b:	8b 40 48             	mov    0x48(%eax),%eax
  80115e:	83 ec 04             	sub    $0x4,%esp
  801161:	53                   	push   %ebx
  801162:	50                   	push   %eax
  801163:	68 29 22 80 00       	push   $0x802229
  801168:	e8 06 f0 ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  80116d:	83 c4 10             	add    $0x10,%esp
  801170:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801175:	eb 26                	jmp    80119d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801177:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80117a:	8b 52 0c             	mov    0xc(%edx),%edx
  80117d:	85 d2                	test   %edx,%edx
  80117f:	74 17                	je     801198 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801181:	83 ec 04             	sub    $0x4,%esp
  801184:	ff 75 10             	pushl  0x10(%ebp)
  801187:	ff 75 0c             	pushl  0xc(%ebp)
  80118a:	50                   	push   %eax
  80118b:	ff d2                	call   *%edx
  80118d:	89 c2                	mov    %eax,%edx
  80118f:	83 c4 10             	add    $0x10,%esp
  801192:	eb 09                	jmp    80119d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801194:	89 c2                	mov    %eax,%edx
  801196:	eb 05                	jmp    80119d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801198:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80119d:	89 d0                	mov    %edx,%eax
  80119f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a2:	c9                   	leave  
  8011a3:	c3                   	ret    

008011a4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011aa:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011ad:	50                   	push   %eax
  8011ae:	ff 75 08             	pushl  0x8(%ebp)
  8011b1:	e8 22 fc ff ff       	call   800dd8 <fd_lookup>
  8011b6:	83 c4 08             	add    $0x8,%esp
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	78 0e                	js     8011cb <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011cb:	c9                   	leave  
  8011cc:	c3                   	ret    

008011cd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	53                   	push   %ebx
  8011d1:	83 ec 14             	sub    $0x14,%esp
  8011d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011da:	50                   	push   %eax
  8011db:	53                   	push   %ebx
  8011dc:	e8 f7 fb ff ff       	call   800dd8 <fd_lookup>
  8011e1:	83 c4 08             	add    $0x8,%esp
  8011e4:	89 c2                	mov    %eax,%edx
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	78 65                	js     80124f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ea:	83 ec 08             	sub    $0x8,%esp
  8011ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f0:	50                   	push   %eax
  8011f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f4:	ff 30                	pushl  (%eax)
  8011f6:	e8 33 fc ff ff       	call   800e2e <dev_lookup>
  8011fb:	83 c4 10             	add    $0x10,%esp
  8011fe:	85 c0                	test   %eax,%eax
  801200:	78 44                	js     801246 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801202:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801205:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801209:	75 21                	jne    80122c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80120b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801210:	8b 40 48             	mov    0x48(%eax),%eax
  801213:	83 ec 04             	sub    $0x4,%esp
  801216:	53                   	push   %ebx
  801217:	50                   	push   %eax
  801218:	68 ec 21 80 00       	push   $0x8021ec
  80121d:	e8 51 ef ff ff       	call   800173 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801222:	83 c4 10             	add    $0x10,%esp
  801225:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80122a:	eb 23                	jmp    80124f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80122c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80122f:	8b 52 18             	mov    0x18(%edx),%edx
  801232:	85 d2                	test   %edx,%edx
  801234:	74 14                	je     80124a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801236:	83 ec 08             	sub    $0x8,%esp
  801239:	ff 75 0c             	pushl  0xc(%ebp)
  80123c:	50                   	push   %eax
  80123d:	ff d2                	call   *%edx
  80123f:	89 c2                	mov    %eax,%edx
  801241:	83 c4 10             	add    $0x10,%esp
  801244:	eb 09                	jmp    80124f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801246:	89 c2                	mov    %eax,%edx
  801248:	eb 05                	jmp    80124f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80124a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80124f:	89 d0                	mov    %edx,%eax
  801251:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801254:	c9                   	leave  
  801255:	c3                   	ret    

00801256 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	53                   	push   %ebx
  80125a:	83 ec 14             	sub    $0x14,%esp
  80125d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801260:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801263:	50                   	push   %eax
  801264:	ff 75 08             	pushl  0x8(%ebp)
  801267:	e8 6c fb ff ff       	call   800dd8 <fd_lookup>
  80126c:	83 c4 08             	add    $0x8,%esp
  80126f:	89 c2                	mov    %eax,%edx
  801271:	85 c0                	test   %eax,%eax
  801273:	78 58                	js     8012cd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801275:	83 ec 08             	sub    $0x8,%esp
  801278:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127b:	50                   	push   %eax
  80127c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127f:	ff 30                	pushl  (%eax)
  801281:	e8 a8 fb ff ff       	call   800e2e <dev_lookup>
  801286:	83 c4 10             	add    $0x10,%esp
  801289:	85 c0                	test   %eax,%eax
  80128b:	78 37                	js     8012c4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80128d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801290:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801294:	74 32                	je     8012c8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801296:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801299:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012a0:	00 00 00 
	stat->st_isdir = 0;
  8012a3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012aa:	00 00 00 
	stat->st_dev = dev;
  8012ad:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012b3:	83 ec 08             	sub    $0x8,%esp
  8012b6:	53                   	push   %ebx
  8012b7:	ff 75 f0             	pushl  -0x10(%ebp)
  8012ba:	ff 50 14             	call   *0x14(%eax)
  8012bd:	89 c2                	mov    %eax,%edx
  8012bf:	83 c4 10             	add    $0x10,%esp
  8012c2:	eb 09                	jmp    8012cd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c4:	89 c2                	mov    %eax,%edx
  8012c6:	eb 05                	jmp    8012cd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012c8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012cd:	89 d0                	mov    %edx,%eax
  8012cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d2:	c9                   	leave  
  8012d3:	c3                   	ret    

008012d4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	56                   	push   %esi
  8012d8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	6a 00                	push   $0x0
  8012de:	ff 75 08             	pushl  0x8(%ebp)
  8012e1:	e8 0c 02 00 00       	call   8014f2 <open>
  8012e6:	89 c3                	mov    %eax,%ebx
  8012e8:	83 c4 10             	add    $0x10,%esp
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	78 1b                	js     80130a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012ef:	83 ec 08             	sub    $0x8,%esp
  8012f2:	ff 75 0c             	pushl  0xc(%ebp)
  8012f5:	50                   	push   %eax
  8012f6:	e8 5b ff ff ff       	call   801256 <fstat>
  8012fb:	89 c6                	mov    %eax,%esi
	close(fd);
  8012fd:	89 1c 24             	mov    %ebx,(%esp)
  801300:	e8 fd fb ff ff       	call   800f02 <close>
	return r;
  801305:	83 c4 10             	add    $0x10,%esp
  801308:	89 f0                	mov    %esi,%eax
}
  80130a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80130d:	5b                   	pop    %ebx
  80130e:	5e                   	pop    %esi
  80130f:	5d                   	pop    %ebp
  801310:	c3                   	ret    

00801311 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801311:	55                   	push   %ebp
  801312:	89 e5                	mov    %esp,%ebp
  801314:	56                   	push   %esi
  801315:	53                   	push   %ebx
  801316:	89 c6                	mov    %eax,%esi
  801318:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80131a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801321:	75 12                	jne    801335 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801323:	83 ec 0c             	sub    $0xc,%esp
  801326:	6a 01                	push   $0x1
  801328:	e8 4b 08 00 00       	call   801b78 <ipc_find_env>
  80132d:	a3 00 40 80 00       	mov    %eax,0x804000
  801332:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801335:	6a 07                	push   $0x7
  801337:	68 00 50 80 00       	push   $0x805000
  80133c:	56                   	push   %esi
  80133d:	ff 35 00 40 80 00    	pushl  0x804000
  801343:	e8 dc 07 00 00       	call   801b24 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801348:	83 c4 0c             	add    $0xc,%esp
  80134b:	6a 00                	push   $0x0
  80134d:	53                   	push   %ebx
  80134e:	6a 00                	push   $0x0
  801350:	e8 66 07 00 00       	call   801abb <ipc_recv>
}
  801355:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801358:	5b                   	pop    %ebx
  801359:	5e                   	pop    %esi
  80135a:	5d                   	pop    %ebp
  80135b:	c3                   	ret    

0080135c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801362:	8b 45 08             	mov    0x8(%ebp),%eax
  801365:	8b 40 0c             	mov    0xc(%eax),%eax
  801368:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80136d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801370:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801375:	ba 00 00 00 00       	mov    $0x0,%edx
  80137a:	b8 02 00 00 00       	mov    $0x2,%eax
  80137f:	e8 8d ff ff ff       	call   801311 <fsipc>
}
  801384:	c9                   	leave  
  801385:	c3                   	ret    

00801386 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80138c:	8b 45 08             	mov    0x8(%ebp),%eax
  80138f:	8b 40 0c             	mov    0xc(%eax),%eax
  801392:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801397:	ba 00 00 00 00       	mov    $0x0,%edx
  80139c:	b8 06 00 00 00       	mov    $0x6,%eax
  8013a1:	e8 6b ff ff ff       	call   801311 <fsipc>
}
  8013a6:	c9                   	leave  
  8013a7:	c3                   	ret    

008013a8 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	53                   	push   %ebx
  8013ac:	83 ec 04             	sub    $0x4,%esp
  8013af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c2:	b8 05 00 00 00       	mov    $0x5,%eax
  8013c7:	e8 45 ff ff ff       	call   801311 <fsipc>
  8013cc:	85 c0                	test   %eax,%eax
  8013ce:	78 2c                	js     8013fc <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013d0:	83 ec 08             	sub    $0x8,%esp
  8013d3:	68 00 50 80 00       	push   $0x805000
  8013d8:	53                   	push   %ebx
  8013d9:	e8 1a f3 ff ff       	call   8006f8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013de:	a1 80 50 80 00       	mov    0x805080,%eax
  8013e3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013e9:	a1 84 50 80 00       	mov    0x805084,%eax
  8013ee:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ff:	c9                   	leave  
  801400:	c3                   	ret    

00801401 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	53                   	push   %ebx
  801405:	83 ec 08             	sub    $0x8,%esp
  801408:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80140b:	8b 55 08             	mov    0x8(%ebp),%edx
  80140e:	8b 52 0c             	mov    0xc(%edx),%edx
  801411:	89 15 00 50 80 00    	mov    %edx,0x805000
  801417:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80141c:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801421:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  801424:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  80142a:	53                   	push   %ebx
  80142b:	ff 75 0c             	pushl  0xc(%ebp)
  80142e:	68 08 50 80 00       	push   $0x805008
  801433:	e8 52 f4 ff ff       	call   80088a <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  801438:	ba 00 00 00 00       	mov    $0x0,%edx
  80143d:	b8 04 00 00 00       	mov    $0x4,%eax
  801442:	e8 ca fe ff ff       	call   801311 <fsipc>
  801447:	83 c4 10             	add    $0x10,%esp
  80144a:	85 c0                	test   %eax,%eax
  80144c:	78 1d                	js     80146b <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  80144e:	39 d8                	cmp    %ebx,%eax
  801450:	76 19                	jbe    80146b <devfile_write+0x6a>
  801452:	68 58 22 80 00       	push   $0x802258
  801457:	68 64 22 80 00       	push   $0x802264
  80145c:	68 a5 00 00 00       	push   $0xa5
  801461:	68 79 22 80 00       	push   $0x802279
  801466:	e8 0a 06 00 00       	call   801a75 <_panic>
	return r;
}
  80146b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146e:	c9                   	leave  
  80146f:	c3                   	ret    

00801470 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	56                   	push   %esi
  801474:	53                   	push   %ebx
  801475:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801478:	8b 45 08             	mov    0x8(%ebp),%eax
  80147b:	8b 40 0c             	mov    0xc(%eax),%eax
  80147e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801483:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801489:	ba 00 00 00 00       	mov    $0x0,%edx
  80148e:	b8 03 00 00 00       	mov    $0x3,%eax
  801493:	e8 79 fe ff ff       	call   801311 <fsipc>
  801498:	89 c3                	mov    %eax,%ebx
  80149a:	85 c0                	test   %eax,%eax
  80149c:	78 4b                	js     8014e9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80149e:	39 c6                	cmp    %eax,%esi
  8014a0:	73 16                	jae    8014b8 <devfile_read+0x48>
  8014a2:	68 84 22 80 00       	push   $0x802284
  8014a7:	68 64 22 80 00       	push   $0x802264
  8014ac:	6a 7c                	push   $0x7c
  8014ae:	68 79 22 80 00       	push   $0x802279
  8014b3:	e8 bd 05 00 00       	call   801a75 <_panic>
	assert(r <= PGSIZE);
  8014b8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014bd:	7e 16                	jle    8014d5 <devfile_read+0x65>
  8014bf:	68 8b 22 80 00       	push   $0x80228b
  8014c4:	68 64 22 80 00       	push   $0x802264
  8014c9:	6a 7d                	push   $0x7d
  8014cb:	68 79 22 80 00       	push   $0x802279
  8014d0:	e8 a0 05 00 00       	call   801a75 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014d5:	83 ec 04             	sub    $0x4,%esp
  8014d8:	50                   	push   %eax
  8014d9:	68 00 50 80 00       	push   $0x805000
  8014de:	ff 75 0c             	pushl  0xc(%ebp)
  8014e1:	e8 a4 f3 ff ff       	call   80088a <memmove>
	return r;
  8014e6:	83 c4 10             	add    $0x10,%esp
}
  8014e9:	89 d8                	mov    %ebx,%eax
  8014eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ee:	5b                   	pop    %ebx
  8014ef:	5e                   	pop    %esi
  8014f0:	5d                   	pop    %ebp
  8014f1:	c3                   	ret    

008014f2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	53                   	push   %ebx
  8014f6:	83 ec 20             	sub    $0x20,%esp
  8014f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014fc:	53                   	push   %ebx
  8014fd:	e8 bd f1 ff ff       	call   8006bf <strlen>
  801502:	83 c4 10             	add    $0x10,%esp
  801505:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80150a:	7f 67                	jg     801573 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80150c:	83 ec 0c             	sub    $0xc,%esp
  80150f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801512:	50                   	push   %eax
  801513:	e8 71 f8 ff ff       	call   800d89 <fd_alloc>
  801518:	83 c4 10             	add    $0x10,%esp
		return r;
  80151b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80151d:	85 c0                	test   %eax,%eax
  80151f:	78 57                	js     801578 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801521:	83 ec 08             	sub    $0x8,%esp
  801524:	53                   	push   %ebx
  801525:	68 00 50 80 00       	push   $0x805000
  80152a:	e8 c9 f1 ff ff       	call   8006f8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80152f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801532:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801537:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80153a:	b8 01 00 00 00       	mov    $0x1,%eax
  80153f:	e8 cd fd ff ff       	call   801311 <fsipc>
  801544:	89 c3                	mov    %eax,%ebx
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	85 c0                	test   %eax,%eax
  80154b:	79 14                	jns    801561 <open+0x6f>
		fd_close(fd, 0);
  80154d:	83 ec 08             	sub    $0x8,%esp
  801550:	6a 00                	push   $0x0
  801552:	ff 75 f4             	pushl  -0xc(%ebp)
  801555:	e8 27 f9 ff ff       	call   800e81 <fd_close>
		return r;
  80155a:	83 c4 10             	add    $0x10,%esp
  80155d:	89 da                	mov    %ebx,%edx
  80155f:	eb 17                	jmp    801578 <open+0x86>
	}

	return fd2num(fd);
  801561:	83 ec 0c             	sub    $0xc,%esp
  801564:	ff 75 f4             	pushl  -0xc(%ebp)
  801567:	e8 f6 f7 ff ff       	call   800d62 <fd2num>
  80156c:	89 c2                	mov    %eax,%edx
  80156e:	83 c4 10             	add    $0x10,%esp
  801571:	eb 05                	jmp    801578 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801573:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801578:	89 d0                	mov    %edx,%eax
  80157a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157d:	c9                   	leave  
  80157e:	c3                   	ret    

0080157f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801585:	ba 00 00 00 00       	mov    $0x0,%edx
  80158a:	b8 08 00 00 00       	mov    $0x8,%eax
  80158f:	e8 7d fd ff ff       	call   801311 <fsipc>
}
  801594:	c9                   	leave  
  801595:	c3                   	ret    

00801596 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	56                   	push   %esi
  80159a:	53                   	push   %ebx
  80159b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80159e:	83 ec 0c             	sub    $0xc,%esp
  8015a1:	ff 75 08             	pushl  0x8(%ebp)
  8015a4:	e8 c9 f7 ff ff       	call   800d72 <fd2data>
  8015a9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015ab:	83 c4 08             	add    $0x8,%esp
  8015ae:	68 97 22 80 00       	push   $0x802297
  8015b3:	53                   	push   %ebx
  8015b4:	e8 3f f1 ff ff       	call   8006f8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015b9:	8b 46 04             	mov    0x4(%esi),%eax
  8015bc:	2b 06                	sub    (%esi),%eax
  8015be:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8015c4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015cb:	00 00 00 
	stat->st_dev = &devpipe;
  8015ce:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8015d5:	30 80 00 
	return 0;
}
  8015d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8015dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015e0:	5b                   	pop    %ebx
  8015e1:	5e                   	pop    %esi
  8015e2:	5d                   	pop    %ebp
  8015e3:	c3                   	ret    

008015e4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015e4:	55                   	push   %ebp
  8015e5:	89 e5                	mov    %esp,%ebp
  8015e7:	53                   	push   %ebx
  8015e8:	83 ec 0c             	sub    $0xc,%esp
  8015eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015ee:	53                   	push   %ebx
  8015ef:	6a 00                	push   $0x0
  8015f1:	e8 8a f5 ff ff       	call   800b80 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015f6:	89 1c 24             	mov    %ebx,(%esp)
  8015f9:	e8 74 f7 ff ff       	call   800d72 <fd2data>
  8015fe:	83 c4 08             	add    $0x8,%esp
  801601:	50                   	push   %eax
  801602:	6a 00                	push   $0x0
  801604:	e8 77 f5 ff ff       	call   800b80 <sys_page_unmap>
}
  801609:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160c:	c9                   	leave  
  80160d:	c3                   	ret    

0080160e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	57                   	push   %edi
  801612:	56                   	push   %esi
  801613:	53                   	push   %ebx
  801614:	83 ec 1c             	sub    $0x1c,%esp
  801617:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80161a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80161c:	a1 04 40 80 00       	mov    0x804004,%eax
  801621:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801624:	83 ec 0c             	sub    $0xc,%esp
  801627:	ff 75 e0             	pushl  -0x20(%ebp)
  80162a:	e8 82 05 00 00       	call   801bb1 <pageref>
  80162f:	89 c3                	mov    %eax,%ebx
  801631:	89 3c 24             	mov    %edi,(%esp)
  801634:	e8 78 05 00 00       	call   801bb1 <pageref>
  801639:	83 c4 10             	add    $0x10,%esp
  80163c:	39 c3                	cmp    %eax,%ebx
  80163e:	0f 94 c1             	sete   %cl
  801641:	0f b6 c9             	movzbl %cl,%ecx
  801644:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801647:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80164d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801650:	39 ce                	cmp    %ecx,%esi
  801652:	74 1b                	je     80166f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801654:	39 c3                	cmp    %eax,%ebx
  801656:	75 c4                	jne    80161c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801658:	8b 42 58             	mov    0x58(%edx),%eax
  80165b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80165e:	50                   	push   %eax
  80165f:	56                   	push   %esi
  801660:	68 9e 22 80 00       	push   $0x80229e
  801665:	e8 09 eb ff ff       	call   800173 <cprintf>
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	eb ad                	jmp    80161c <_pipeisclosed+0xe>
	}
}
  80166f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801672:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801675:	5b                   	pop    %ebx
  801676:	5e                   	pop    %esi
  801677:	5f                   	pop    %edi
  801678:	5d                   	pop    %ebp
  801679:	c3                   	ret    

0080167a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	57                   	push   %edi
  80167e:	56                   	push   %esi
  80167f:	53                   	push   %ebx
  801680:	83 ec 28             	sub    $0x28,%esp
  801683:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801686:	56                   	push   %esi
  801687:	e8 e6 f6 ff ff       	call   800d72 <fd2data>
  80168c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80168e:	83 c4 10             	add    $0x10,%esp
  801691:	bf 00 00 00 00       	mov    $0x0,%edi
  801696:	eb 4b                	jmp    8016e3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801698:	89 da                	mov    %ebx,%edx
  80169a:	89 f0                	mov    %esi,%eax
  80169c:	e8 6d ff ff ff       	call   80160e <_pipeisclosed>
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	75 48                	jne    8016ed <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016a5:	e8 32 f4 ff ff       	call   800adc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016aa:	8b 43 04             	mov    0x4(%ebx),%eax
  8016ad:	8b 0b                	mov    (%ebx),%ecx
  8016af:	8d 51 20             	lea    0x20(%ecx),%edx
  8016b2:	39 d0                	cmp    %edx,%eax
  8016b4:	73 e2                	jae    801698 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016b9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016bd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8016c0:	89 c2                	mov    %eax,%edx
  8016c2:	c1 fa 1f             	sar    $0x1f,%edx
  8016c5:	89 d1                	mov    %edx,%ecx
  8016c7:	c1 e9 1b             	shr    $0x1b,%ecx
  8016ca:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8016cd:	83 e2 1f             	and    $0x1f,%edx
  8016d0:	29 ca                	sub    %ecx,%edx
  8016d2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8016d6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8016da:	83 c0 01             	add    $0x1,%eax
  8016dd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016e0:	83 c7 01             	add    $0x1,%edi
  8016e3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016e6:	75 c2                	jne    8016aa <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8016eb:	eb 05                	jmp    8016f2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016ed:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f5:	5b                   	pop    %ebx
  8016f6:	5e                   	pop    %esi
  8016f7:	5f                   	pop    %edi
  8016f8:	5d                   	pop    %ebp
  8016f9:	c3                   	ret    

008016fa <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	57                   	push   %edi
  8016fe:	56                   	push   %esi
  8016ff:	53                   	push   %ebx
  801700:	83 ec 18             	sub    $0x18,%esp
  801703:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801706:	57                   	push   %edi
  801707:	e8 66 f6 ff ff       	call   800d72 <fd2data>
  80170c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	bb 00 00 00 00       	mov    $0x0,%ebx
  801716:	eb 3d                	jmp    801755 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801718:	85 db                	test   %ebx,%ebx
  80171a:	74 04                	je     801720 <devpipe_read+0x26>
				return i;
  80171c:	89 d8                	mov    %ebx,%eax
  80171e:	eb 44                	jmp    801764 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801720:	89 f2                	mov    %esi,%edx
  801722:	89 f8                	mov    %edi,%eax
  801724:	e8 e5 fe ff ff       	call   80160e <_pipeisclosed>
  801729:	85 c0                	test   %eax,%eax
  80172b:	75 32                	jne    80175f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80172d:	e8 aa f3 ff ff       	call   800adc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801732:	8b 06                	mov    (%esi),%eax
  801734:	3b 46 04             	cmp    0x4(%esi),%eax
  801737:	74 df                	je     801718 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801739:	99                   	cltd   
  80173a:	c1 ea 1b             	shr    $0x1b,%edx
  80173d:	01 d0                	add    %edx,%eax
  80173f:	83 e0 1f             	and    $0x1f,%eax
  801742:	29 d0                	sub    %edx,%eax
  801744:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801749:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80174c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80174f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801752:	83 c3 01             	add    $0x1,%ebx
  801755:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801758:	75 d8                	jne    801732 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80175a:	8b 45 10             	mov    0x10(%ebp),%eax
  80175d:	eb 05                	jmp    801764 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80175f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801764:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801767:	5b                   	pop    %ebx
  801768:	5e                   	pop    %esi
  801769:	5f                   	pop    %edi
  80176a:	5d                   	pop    %ebp
  80176b:	c3                   	ret    

0080176c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	56                   	push   %esi
  801770:	53                   	push   %ebx
  801771:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801774:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801777:	50                   	push   %eax
  801778:	e8 0c f6 ff ff       	call   800d89 <fd_alloc>
  80177d:	83 c4 10             	add    $0x10,%esp
  801780:	89 c2                	mov    %eax,%edx
  801782:	85 c0                	test   %eax,%eax
  801784:	0f 88 2c 01 00 00    	js     8018b6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80178a:	83 ec 04             	sub    $0x4,%esp
  80178d:	68 07 04 00 00       	push   $0x407
  801792:	ff 75 f4             	pushl  -0xc(%ebp)
  801795:	6a 00                	push   $0x0
  801797:	e8 5f f3 ff ff       	call   800afb <sys_page_alloc>
  80179c:	83 c4 10             	add    $0x10,%esp
  80179f:	89 c2                	mov    %eax,%edx
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	0f 88 0d 01 00 00    	js     8018b6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017a9:	83 ec 0c             	sub    $0xc,%esp
  8017ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017af:	50                   	push   %eax
  8017b0:	e8 d4 f5 ff ff       	call   800d89 <fd_alloc>
  8017b5:	89 c3                	mov    %eax,%ebx
  8017b7:	83 c4 10             	add    $0x10,%esp
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	0f 88 e2 00 00 00    	js     8018a4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017c2:	83 ec 04             	sub    $0x4,%esp
  8017c5:	68 07 04 00 00       	push   $0x407
  8017ca:	ff 75 f0             	pushl  -0x10(%ebp)
  8017cd:	6a 00                	push   $0x0
  8017cf:	e8 27 f3 ff ff       	call   800afb <sys_page_alloc>
  8017d4:	89 c3                	mov    %eax,%ebx
  8017d6:	83 c4 10             	add    $0x10,%esp
  8017d9:	85 c0                	test   %eax,%eax
  8017db:	0f 88 c3 00 00 00    	js     8018a4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017e1:	83 ec 0c             	sub    $0xc,%esp
  8017e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8017e7:	e8 86 f5 ff ff       	call   800d72 <fd2data>
  8017ec:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ee:	83 c4 0c             	add    $0xc,%esp
  8017f1:	68 07 04 00 00       	push   $0x407
  8017f6:	50                   	push   %eax
  8017f7:	6a 00                	push   $0x0
  8017f9:	e8 fd f2 ff ff       	call   800afb <sys_page_alloc>
  8017fe:	89 c3                	mov    %eax,%ebx
  801800:	83 c4 10             	add    $0x10,%esp
  801803:	85 c0                	test   %eax,%eax
  801805:	0f 88 89 00 00 00    	js     801894 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80180b:	83 ec 0c             	sub    $0xc,%esp
  80180e:	ff 75 f0             	pushl  -0x10(%ebp)
  801811:	e8 5c f5 ff ff       	call   800d72 <fd2data>
  801816:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80181d:	50                   	push   %eax
  80181e:	6a 00                	push   $0x0
  801820:	56                   	push   %esi
  801821:	6a 00                	push   $0x0
  801823:	e8 16 f3 ff ff       	call   800b3e <sys_page_map>
  801828:	89 c3                	mov    %eax,%ebx
  80182a:	83 c4 20             	add    $0x20,%esp
  80182d:	85 c0                	test   %eax,%eax
  80182f:	78 55                	js     801886 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801831:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801837:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80183c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801846:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80184c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801851:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801854:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80185b:	83 ec 0c             	sub    $0xc,%esp
  80185e:	ff 75 f4             	pushl  -0xc(%ebp)
  801861:	e8 fc f4 ff ff       	call   800d62 <fd2num>
  801866:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801869:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80186b:	83 c4 04             	add    $0x4,%esp
  80186e:	ff 75 f0             	pushl  -0x10(%ebp)
  801871:	e8 ec f4 ff ff       	call   800d62 <fd2num>
  801876:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801879:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	ba 00 00 00 00       	mov    $0x0,%edx
  801884:	eb 30                	jmp    8018b6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801886:	83 ec 08             	sub    $0x8,%esp
  801889:	56                   	push   %esi
  80188a:	6a 00                	push   $0x0
  80188c:	e8 ef f2 ff ff       	call   800b80 <sys_page_unmap>
  801891:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801894:	83 ec 08             	sub    $0x8,%esp
  801897:	ff 75 f0             	pushl  -0x10(%ebp)
  80189a:	6a 00                	push   $0x0
  80189c:	e8 df f2 ff ff       	call   800b80 <sys_page_unmap>
  8018a1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018a4:	83 ec 08             	sub    $0x8,%esp
  8018a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8018aa:	6a 00                	push   $0x0
  8018ac:	e8 cf f2 ff ff       	call   800b80 <sys_page_unmap>
  8018b1:	83 c4 10             	add    $0x10,%esp
  8018b4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8018b6:	89 d0                	mov    %edx,%eax
  8018b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018bb:	5b                   	pop    %ebx
  8018bc:	5e                   	pop    %esi
  8018bd:	5d                   	pop    %ebp
  8018be:	c3                   	ret    

008018bf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c8:	50                   	push   %eax
  8018c9:	ff 75 08             	pushl  0x8(%ebp)
  8018cc:	e8 07 f5 ff ff       	call   800dd8 <fd_lookup>
  8018d1:	83 c4 10             	add    $0x10,%esp
  8018d4:	85 c0                	test   %eax,%eax
  8018d6:	78 18                	js     8018f0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018d8:	83 ec 0c             	sub    $0xc,%esp
  8018db:	ff 75 f4             	pushl  -0xc(%ebp)
  8018de:	e8 8f f4 ff ff       	call   800d72 <fd2data>
	return _pipeisclosed(fd, p);
  8018e3:	89 c2                	mov    %eax,%edx
  8018e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e8:	e8 21 fd ff ff       	call   80160e <_pipeisclosed>
  8018ed:	83 c4 10             	add    $0x10,%esp
}
  8018f0:	c9                   	leave  
  8018f1:	c3                   	ret    

008018f2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8018fa:	5d                   	pop    %ebp
  8018fb:	c3                   	ret    

008018fc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801902:	68 b6 22 80 00       	push   $0x8022b6
  801907:	ff 75 0c             	pushl  0xc(%ebp)
  80190a:	e8 e9 ed ff ff       	call   8006f8 <strcpy>
	return 0;
}
  80190f:	b8 00 00 00 00       	mov    $0x0,%eax
  801914:	c9                   	leave  
  801915:	c3                   	ret    

00801916 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	57                   	push   %edi
  80191a:	56                   	push   %esi
  80191b:	53                   	push   %ebx
  80191c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801922:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801927:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80192d:	eb 2d                	jmp    80195c <devcons_write+0x46>
		m = n - tot;
  80192f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801932:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801934:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801937:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80193c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80193f:	83 ec 04             	sub    $0x4,%esp
  801942:	53                   	push   %ebx
  801943:	03 45 0c             	add    0xc(%ebp),%eax
  801946:	50                   	push   %eax
  801947:	57                   	push   %edi
  801948:	e8 3d ef ff ff       	call   80088a <memmove>
		sys_cputs(buf, m);
  80194d:	83 c4 08             	add    $0x8,%esp
  801950:	53                   	push   %ebx
  801951:	57                   	push   %edi
  801952:	e8 e8 f0 ff ff       	call   800a3f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801957:	01 de                	add    %ebx,%esi
  801959:	83 c4 10             	add    $0x10,%esp
  80195c:	89 f0                	mov    %esi,%eax
  80195e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801961:	72 cc                	jb     80192f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801963:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801966:	5b                   	pop    %ebx
  801967:	5e                   	pop    %esi
  801968:	5f                   	pop    %edi
  801969:	5d                   	pop    %ebp
  80196a:	c3                   	ret    

0080196b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80196b:	55                   	push   %ebp
  80196c:	89 e5                	mov    %esp,%ebp
  80196e:	83 ec 08             	sub    $0x8,%esp
  801971:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801976:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80197a:	74 2a                	je     8019a6 <devcons_read+0x3b>
  80197c:	eb 05                	jmp    801983 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80197e:	e8 59 f1 ff ff       	call   800adc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801983:	e8 d5 f0 ff ff       	call   800a5d <sys_cgetc>
  801988:	85 c0                	test   %eax,%eax
  80198a:	74 f2                	je     80197e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80198c:	85 c0                	test   %eax,%eax
  80198e:	78 16                	js     8019a6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801990:	83 f8 04             	cmp    $0x4,%eax
  801993:	74 0c                	je     8019a1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801995:	8b 55 0c             	mov    0xc(%ebp),%edx
  801998:	88 02                	mov    %al,(%edx)
	return 1;
  80199a:	b8 01 00 00 00       	mov    $0x1,%eax
  80199f:	eb 05                	jmp    8019a6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8019a1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019a6:	c9                   	leave  
  8019a7:	c3                   	ret    

008019a8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019b4:	6a 01                	push   $0x1
  8019b6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019b9:	50                   	push   %eax
  8019ba:	e8 80 f0 ff ff       	call   800a3f <sys_cputs>
}
  8019bf:	83 c4 10             	add    $0x10,%esp
  8019c2:	c9                   	leave  
  8019c3:	c3                   	ret    

008019c4 <getchar>:

int
getchar(void)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8019ca:	6a 01                	push   $0x1
  8019cc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019cf:	50                   	push   %eax
  8019d0:	6a 00                	push   $0x0
  8019d2:	e8 67 f6 ff ff       	call   80103e <read>
	if (r < 0)
  8019d7:	83 c4 10             	add    $0x10,%esp
  8019da:	85 c0                	test   %eax,%eax
  8019dc:	78 0f                	js     8019ed <getchar+0x29>
		return r;
	if (r < 1)
  8019de:	85 c0                	test   %eax,%eax
  8019e0:	7e 06                	jle    8019e8 <getchar+0x24>
		return -E_EOF;
	return c;
  8019e2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019e6:	eb 05                	jmp    8019ed <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019e8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019ed:	c9                   	leave  
  8019ee:	c3                   	ret    

008019ef <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019ef:	55                   	push   %ebp
  8019f0:	89 e5                	mov    %esp,%ebp
  8019f2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f8:	50                   	push   %eax
  8019f9:	ff 75 08             	pushl  0x8(%ebp)
  8019fc:	e8 d7 f3 ff ff       	call   800dd8 <fd_lookup>
  801a01:	83 c4 10             	add    $0x10,%esp
  801a04:	85 c0                	test   %eax,%eax
  801a06:	78 11                	js     801a19 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a11:	39 10                	cmp    %edx,(%eax)
  801a13:	0f 94 c0             	sete   %al
  801a16:	0f b6 c0             	movzbl %al,%eax
}
  801a19:	c9                   	leave  
  801a1a:	c3                   	ret    

00801a1b <opencons>:

int
opencons(void)
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a24:	50                   	push   %eax
  801a25:	e8 5f f3 ff ff       	call   800d89 <fd_alloc>
  801a2a:	83 c4 10             	add    $0x10,%esp
		return r;
  801a2d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a2f:	85 c0                	test   %eax,%eax
  801a31:	78 3e                	js     801a71 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a33:	83 ec 04             	sub    $0x4,%esp
  801a36:	68 07 04 00 00       	push   $0x407
  801a3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801a3e:	6a 00                	push   $0x0
  801a40:	e8 b6 f0 ff ff       	call   800afb <sys_page_alloc>
  801a45:	83 c4 10             	add    $0x10,%esp
		return r;
  801a48:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a4a:	85 c0                	test   %eax,%eax
  801a4c:	78 23                	js     801a71 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a4e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a57:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a5c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a63:	83 ec 0c             	sub    $0xc,%esp
  801a66:	50                   	push   %eax
  801a67:	e8 f6 f2 ff ff       	call   800d62 <fd2num>
  801a6c:	89 c2                	mov    %eax,%edx
  801a6e:	83 c4 10             	add    $0x10,%esp
}
  801a71:	89 d0                	mov    %edx,%eax
  801a73:	c9                   	leave  
  801a74:	c3                   	ret    

00801a75 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	56                   	push   %esi
  801a79:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a7a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a7d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a83:	e8 35 f0 ff ff       	call   800abd <sys_getenvid>
  801a88:	83 ec 0c             	sub    $0xc,%esp
  801a8b:	ff 75 0c             	pushl  0xc(%ebp)
  801a8e:	ff 75 08             	pushl  0x8(%ebp)
  801a91:	56                   	push   %esi
  801a92:	50                   	push   %eax
  801a93:	68 c4 22 80 00       	push   $0x8022c4
  801a98:	e8 d6 e6 ff ff       	call   800173 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a9d:	83 c4 18             	add    $0x18,%esp
  801aa0:	53                   	push   %ebx
  801aa1:	ff 75 10             	pushl  0x10(%ebp)
  801aa4:	e8 79 e6 ff ff       	call   800122 <vcprintf>
	cprintf("\n");
  801aa9:	c7 04 24 af 22 80 00 	movl   $0x8022af,(%esp)
  801ab0:	e8 be e6 ff ff       	call   800173 <cprintf>
  801ab5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ab8:	cc                   	int3   
  801ab9:	eb fd                	jmp    801ab8 <_panic+0x43>

00801abb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	56                   	push   %esi
  801abf:	53                   	push   %ebx
  801ac0:	8b 75 08             	mov    0x8(%ebp),%esi
  801ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801ac9:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801acb:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801ad0:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801ad3:	83 ec 0c             	sub    $0xc,%esp
  801ad6:	50                   	push   %eax
  801ad7:	e8 cf f1 ff ff       	call   800cab <sys_ipc_recv>

	if (r < 0) {
  801adc:	83 c4 10             	add    $0x10,%esp
  801adf:	85 c0                	test   %eax,%eax
  801ae1:	79 16                	jns    801af9 <ipc_recv+0x3e>
		if (from_env_store)
  801ae3:	85 f6                	test   %esi,%esi
  801ae5:	74 06                	je     801aed <ipc_recv+0x32>
			*from_env_store = 0;
  801ae7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801aed:	85 db                	test   %ebx,%ebx
  801aef:	74 2c                	je     801b1d <ipc_recv+0x62>
			*perm_store = 0;
  801af1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801af7:	eb 24                	jmp    801b1d <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801af9:	85 f6                	test   %esi,%esi
  801afb:	74 0a                	je     801b07 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801afd:	a1 04 40 80 00       	mov    0x804004,%eax
  801b02:	8b 40 74             	mov    0x74(%eax),%eax
  801b05:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801b07:	85 db                	test   %ebx,%ebx
  801b09:	74 0a                	je     801b15 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801b0b:	a1 04 40 80 00       	mov    0x804004,%eax
  801b10:	8b 40 78             	mov    0x78(%eax),%eax
  801b13:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801b15:	a1 04 40 80 00       	mov    0x804004,%eax
  801b1a:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801b1d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b20:	5b                   	pop    %ebx
  801b21:	5e                   	pop    %esi
  801b22:	5d                   	pop    %ebp
  801b23:	c3                   	ret    

00801b24 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	57                   	push   %edi
  801b28:	56                   	push   %esi
  801b29:	53                   	push   %ebx
  801b2a:	83 ec 0c             	sub    $0xc,%esp
  801b2d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b30:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801b36:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801b38:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801b3d:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801b40:	ff 75 14             	pushl  0x14(%ebp)
  801b43:	53                   	push   %ebx
  801b44:	56                   	push   %esi
  801b45:	57                   	push   %edi
  801b46:	e8 3d f1 ff ff       	call   800c88 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801b4b:	83 c4 10             	add    $0x10,%esp
  801b4e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b51:	75 07                	jne    801b5a <ipc_send+0x36>
			sys_yield();
  801b53:	e8 84 ef ff ff       	call   800adc <sys_yield>
  801b58:	eb e6                	jmp    801b40 <ipc_send+0x1c>
		} else if (r < 0) {
  801b5a:	85 c0                	test   %eax,%eax
  801b5c:	79 12                	jns    801b70 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801b5e:	50                   	push   %eax
  801b5f:	68 e8 22 80 00       	push   $0x8022e8
  801b64:	6a 51                	push   $0x51
  801b66:	68 f5 22 80 00       	push   $0x8022f5
  801b6b:	e8 05 ff ff ff       	call   801a75 <_panic>
		}
	}
}
  801b70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b73:	5b                   	pop    %ebx
  801b74:	5e                   	pop    %esi
  801b75:	5f                   	pop    %edi
  801b76:	5d                   	pop    %ebp
  801b77:	c3                   	ret    

00801b78 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b7e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b83:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b86:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b8c:	8b 52 50             	mov    0x50(%edx),%edx
  801b8f:	39 ca                	cmp    %ecx,%edx
  801b91:	75 0d                	jne    801ba0 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b93:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b96:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b9b:	8b 40 48             	mov    0x48(%eax),%eax
  801b9e:	eb 0f                	jmp    801baf <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ba0:	83 c0 01             	add    $0x1,%eax
  801ba3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ba8:	75 d9                	jne    801b83 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801baa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801baf:	5d                   	pop    %ebp
  801bb0:	c3                   	ret    

00801bb1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bb7:	89 d0                	mov    %edx,%eax
  801bb9:	c1 e8 16             	shr    $0x16,%eax
  801bbc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bc3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bc8:	f6 c1 01             	test   $0x1,%cl
  801bcb:	74 1d                	je     801bea <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bcd:	c1 ea 0c             	shr    $0xc,%edx
  801bd0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bd7:	f6 c2 01             	test   $0x1,%dl
  801bda:	74 0e                	je     801bea <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bdc:	c1 ea 0c             	shr    $0xc,%edx
  801bdf:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801be6:	ef 
  801be7:	0f b7 c0             	movzwl %ax,%eax
}
  801bea:	5d                   	pop    %ebp
  801beb:	c3                   	ret    
  801bec:	66 90                	xchg   %ax,%ax
  801bee:	66 90                	xchg   %ax,%ax

00801bf0 <__udivdi3>:
  801bf0:	55                   	push   %ebp
  801bf1:	57                   	push   %edi
  801bf2:	56                   	push   %esi
  801bf3:	53                   	push   %ebx
  801bf4:	83 ec 1c             	sub    $0x1c,%esp
  801bf7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bfb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c07:	85 f6                	test   %esi,%esi
  801c09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c0d:	89 ca                	mov    %ecx,%edx
  801c0f:	89 f8                	mov    %edi,%eax
  801c11:	75 3d                	jne    801c50 <__udivdi3+0x60>
  801c13:	39 cf                	cmp    %ecx,%edi
  801c15:	0f 87 c5 00 00 00    	ja     801ce0 <__udivdi3+0xf0>
  801c1b:	85 ff                	test   %edi,%edi
  801c1d:	89 fd                	mov    %edi,%ebp
  801c1f:	75 0b                	jne    801c2c <__udivdi3+0x3c>
  801c21:	b8 01 00 00 00       	mov    $0x1,%eax
  801c26:	31 d2                	xor    %edx,%edx
  801c28:	f7 f7                	div    %edi
  801c2a:	89 c5                	mov    %eax,%ebp
  801c2c:	89 c8                	mov    %ecx,%eax
  801c2e:	31 d2                	xor    %edx,%edx
  801c30:	f7 f5                	div    %ebp
  801c32:	89 c1                	mov    %eax,%ecx
  801c34:	89 d8                	mov    %ebx,%eax
  801c36:	89 cf                	mov    %ecx,%edi
  801c38:	f7 f5                	div    %ebp
  801c3a:	89 c3                	mov    %eax,%ebx
  801c3c:	89 d8                	mov    %ebx,%eax
  801c3e:	89 fa                	mov    %edi,%edx
  801c40:	83 c4 1c             	add    $0x1c,%esp
  801c43:	5b                   	pop    %ebx
  801c44:	5e                   	pop    %esi
  801c45:	5f                   	pop    %edi
  801c46:	5d                   	pop    %ebp
  801c47:	c3                   	ret    
  801c48:	90                   	nop
  801c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c50:	39 ce                	cmp    %ecx,%esi
  801c52:	77 74                	ja     801cc8 <__udivdi3+0xd8>
  801c54:	0f bd fe             	bsr    %esi,%edi
  801c57:	83 f7 1f             	xor    $0x1f,%edi
  801c5a:	0f 84 98 00 00 00    	je     801cf8 <__udivdi3+0x108>
  801c60:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c65:	89 f9                	mov    %edi,%ecx
  801c67:	89 c5                	mov    %eax,%ebp
  801c69:	29 fb                	sub    %edi,%ebx
  801c6b:	d3 e6                	shl    %cl,%esi
  801c6d:	89 d9                	mov    %ebx,%ecx
  801c6f:	d3 ed                	shr    %cl,%ebp
  801c71:	89 f9                	mov    %edi,%ecx
  801c73:	d3 e0                	shl    %cl,%eax
  801c75:	09 ee                	or     %ebp,%esi
  801c77:	89 d9                	mov    %ebx,%ecx
  801c79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c7d:	89 d5                	mov    %edx,%ebp
  801c7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c83:	d3 ed                	shr    %cl,%ebp
  801c85:	89 f9                	mov    %edi,%ecx
  801c87:	d3 e2                	shl    %cl,%edx
  801c89:	89 d9                	mov    %ebx,%ecx
  801c8b:	d3 e8                	shr    %cl,%eax
  801c8d:	09 c2                	or     %eax,%edx
  801c8f:	89 d0                	mov    %edx,%eax
  801c91:	89 ea                	mov    %ebp,%edx
  801c93:	f7 f6                	div    %esi
  801c95:	89 d5                	mov    %edx,%ebp
  801c97:	89 c3                	mov    %eax,%ebx
  801c99:	f7 64 24 0c          	mull   0xc(%esp)
  801c9d:	39 d5                	cmp    %edx,%ebp
  801c9f:	72 10                	jb     801cb1 <__udivdi3+0xc1>
  801ca1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ca5:	89 f9                	mov    %edi,%ecx
  801ca7:	d3 e6                	shl    %cl,%esi
  801ca9:	39 c6                	cmp    %eax,%esi
  801cab:	73 07                	jae    801cb4 <__udivdi3+0xc4>
  801cad:	39 d5                	cmp    %edx,%ebp
  801caf:	75 03                	jne    801cb4 <__udivdi3+0xc4>
  801cb1:	83 eb 01             	sub    $0x1,%ebx
  801cb4:	31 ff                	xor    %edi,%edi
  801cb6:	89 d8                	mov    %ebx,%eax
  801cb8:	89 fa                	mov    %edi,%edx
  801cba:	83 c4 1c             	add    $0x1c,%esp
  801cbd:	5b                   	pop    %ebx
  801cbe:	5e                   	pop    %esi
  801cbf:	5f                   	pop    %edi
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    
  801cc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cc8:	31 ff                	xor    %edi,%edi
  801cca:	31 db                	xor    %ebx,%ebx
  801ccc:	89 d8                	mov    %ebx,%eax
  801cce:	89 fa                	mov    %edi,%edx
  801cd0:	83 c4 1c             	add    $0x1c,%esp
  801cd3:	5b                   	pop    %ebx
  801cd4:	5e                   	pop    %esi
  801cd5:	5f                   	pop    %edi
  801cd6:	5d                   	pop    %ebp
  801cd7:	c3                   	ret    
  801cd8:	90                   	nop
  801cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	89 d8                	mov    %ebx,%eax
  801ce2:	f7 f7                	div    %edi
  801ce4:	31 ff                	xor    %edi,%edi
  801ce6:	89 c3                	mov    %eax,%ebx
  801ce8:	89 d8                	mov    %ebx,%eax
  801cea:	89 fa                	mov    %edi,%edx
  801cec:	83 c4 1c             	add    $0x1c,%esp
  801cef:	5b                   	pop    %ebx
  801cf0:	5e                   	pop    %esi
  801cf1:	5f                   	pop    %edi
  801cf2:	5d                   	pop    %ebp
  801cf3:	c3                   	ret    
  801cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cf8:	39 ce                	cmp    %ecx,%esi
  801cfa:	72 0c                	jb     801d08 <__udivdi3+0x118>
  801cfc:	31 db                	xor    %ebx,%ebx
  801cfe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d02:	0f 87 34 ff ff ff    	ja     801c3c <__udivdi3+0x4c>
  801d08:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d0d:	e9 2a ff ff ff       	jmp    801c3c <__udivdi3+0x4c>
  801d12:	66 90                	xchg   %ax,%ax
  801d14:	66 90                	xchg   %ax,%ax
  801d16:	66 90                	xchg   %ax,%ax
  801d18:	66 90                	xchg   %ax,%ax
  801d1a:	66 90                	xchg   %ax,%ax
  801d1c:	66 90                	xchg   %ax,%ax
  801d1e:	66 90                	xchg   %ax,%ax

00801d20 <__umoddi3>:
  801d20:	55                   	push   %ebp
  801d21:	57                   	push   %edi
  801d22:	56                   	push   %esi
  801d23:	53                   	push   %ebx
  801d24:	83 ec 1c             	sub    $0x1c,%esp
  801d27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d37:	85 d2                	test   %edx,%edx
  801d39:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d41:	89 f3                	mov    %esi,%ebx
  801d43:	89 3c 24             	mov    %edi,(%esp)
  801d46:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d4a:	75 1c                	jne    801d68 <__umoddi3+0x48>
  801d4c:	39 f7                	cmp    %esi,%edi
  801d4e:	76 50                	jbe    801da0 <__umoddi3+0x80>
  801d50:	89 c8                	mov    %ecx,%eax
  801d52:	89 f2                	mov    %esi,%edx
  801d54:	f7 f7                	div    %edi
  801d56:	89 d0                	mov    %edx,%eax
  801d58:	31 d2                	xor    %edx,%edx
  801d5a:	83 c4 1c             	add    $0x1c,%esp
  801d5d:	5b                   	pop    %ebx
  801d5e:	5e                   	pop    %esi
  801d5f:	5f                   	pop    %edi
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    
  801d62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d68:	39 f2                	cmp    %esi,%edx
  801d6a:	89 d0                	mov    %edx,%eax
  801d6c:	77 52                	ja     801dc0 <__umoddi3+0xa0>
  801d6e:	0f bd ea             	bsr    %edx,%ebp
  801d71:	83 f5 1f             	xor    $0x1f,%ebp
  801d74:	75 5a                	jne    801dd0 <__umoddi3+0xb0>
  801d76:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d7a:	0f 82 e0 00 00 00    	jb     801e60 <__umoddi3+0x140>
  801d80:	39 0c 24             	cmp    %ecx,(%esp)
  801d83:	0f 86 d7 00 00 00    	jbe    801e60 <__umoddi3+0x140>
  801d89:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d8d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d91:	83 c4 1c             	add    $0x1c,%esp
  801d94:	5b                   	pop    %ebx
  801d95:	5e                   	pop    %esi
  801d96:	5f                   	pop    %edi
  801d97:	5d                   	pop    %ebp
  801d98:	c3                   	ret    
  801d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801da0:	85 ff                	test   %edi,%edi
  801da2:	89 fd                	mov    %edi,%ebp
  801da4:	75 0b                	jne    801db1 <__umoddi3+0x91>
  801da6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dab:	31 d2                	xor    %edx,%edx
  801dad:	f7 f7                	div    %edi
  801daf:	89 c5                	mov    %eax,%ebp
  801db1:	89 f0                	mov    %esi,%eax
  801db3:	31 d2                	xor    %edx,%edx
  801db5:	f7 f5                	div    %ebp
  801db7:	89 c8                	mov    %ecx,%eax
  801db9:	f7 f5                	div    %ebp
  801dbb:	89 d0                	mov    %edx,%eax
  801dbd:	eb 99                	jmp    801d58 <__umoddi3+0x38>
  801dbf:	90                   	nop
  801dc0:	89 c8                	mov    %ecx,%eax
  801dc2:	89 f2                	mov    %esi,%edx
  801dc4:	83 c4 1c             	add    $0x1c,%esp
  801dc7:	5b                   	pop    %ebx
  801dc8:	5e                   	pop    %esi
  801dc9:	5f                   	pop    %edi
  801dca:	5d                   	pop    %ebp
  801dcb:	c3                   	ret    
  801dcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dd0:	8b 34 24             	mov    (%esp),%esi
  801dd3:	bf 20 00 00 00       	mov    $0x20,%edi
  801dd8:	89 e9                	mov    %ebp,%ecx
  801dda:	29 ef                	sub    %ebp,%edi
  801ddc:	d3 e0                	shl    %cl,%eax
  801dde:	89 f9                	mov    %edi,%ecx
  801de0:	89 f2                	mov    %esi,%edx
  801de2:	d3 ea                	shr    %cl,%edx
  801de4:	89 e9                	mov    %ebp,%ecx
  801de6:	09 c2                	or     %eax,%edx
  801de8:	89 d8                	mov    %ebx,%eax
  801dea:	89 14 24             	mov    %edx,(%esp)
  801ded:	89 f2                	mov    %esi,%edx
  801def:	d3 e2                	shl    %cl,%edx
  801df1:	89 f9                	mov    %edi,%ecx
  801df3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801df7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dfb:	d3 e8                	shr    %cl,%eax
  801dfd:	89 e9                	mov    %ebp,%ecx
  801dff:	89 c6                	mov    %eax,%esi
  801e01:	d3 e3                	shl    %cl,%ebx
  801e03:	89 f9                	mov    %edi,%ecx
  801e05:	89 d0                	mov    %edx,%eax
  801e07:	d3 e8                	shr    %cl,%eax
  801e09:	89 e9                	mov    %ebp,%ecx
  801e0b:	09 d8                	or     %ebx,%eax
  801e0d:	89 d3                	mov    %edx,%ebx
  801e0f:	89 f2                	mov    %esi,%edx
  801e11:	f7 34 24             	divl   (%esp)
  801e14:	89 d6                	mov    %edx,%esi
  801e16:	d3 e3                	shl    %cl,%ebx
  801e18:	f7 64 24 04          	mull   0x4(%esp)
  801e1c:	39 d6                	cmp    %edx,%esi
  801e1e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e22:	89 d1                	mov    %edx,%ecx
  801e24:	89 c3                	mov    %eax,%ebx
  801e26:	72 08                	jb     801e30 <__umoddi3+0x110>
  801e28:	75 11                	jne    801e3b <__umoddi3+0x11b>
  801e2a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e2e:	73 0b                	jae    801e3b <__umoddi3+0x11b>
  801e30:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e34:	1b 14 24             	sbb    (%esp),%edx
  801e37:	89 d1                	mov    %edx,%ecx
  801e39:	89 c3                	mov    %eax,%ebx
  801e3b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e3f:	29 da                	sub    %ebx,%edx
  801e41:	19 ce                	sbb    %ecx,%esi
  801e43:	89 f9                	mov    %edi,%ecx
  801e45:	89 f0                	mov    %esi,%eax
  801e47:	d3 e0                	shl    %cl,%eax
  801e49:	89 e9                	mov    %ebp,%ecx
  801e4b:	d3 ea                	shr    %cl,%edx
  801e4d:	89 e9                	mov    %ebp,%ecx
  801e4f:	d3 ee                	shr    %cl,%esi
  801e51:	09 d0                	or     %edx,%eax
  801e53:	89 f2                	mov    %esi,%edx
  801e55:	83 c4 1c             	add    $0x1c,%esp
  801e58:	5b                   	pop    %ebx
  801e59:	5e                   	pop    %esi
  801e5a:	5f                   	pop    %edi
  801e5b:	5d                   	pop    %ebp
  801e5c:	c3                   	ret    
  801e5d:	8d 76 00             	lea    0x0(%esi),%esi
  801e60:	29 f9                	sub    %edi,%ecx
  801e62:	19 d6                	sbb    %edx,%esi
  801e64:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e6c:	e9 18 ff ff ff       	jmp    801d89 <__umoddi3+0x69>
