
obj/user/spawnhello.debug:     file format elf32-i386


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
  80002c:	e8 4a 00 00 00       	call   80007b <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 08 40 80 00       	mov    0x804008,%eax
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	50                   	push   %eax
  800042:	68 00 29 80 00       	push   $0x802900
  800047:	e8 68 01 00 00       	call   8001b4 <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 1e 29 80 00       	push   $0x80291e
  800056:	68 1e 29 80 00       	push   $0x80291e
  80005b:	e8 1e 1b 00 00       	call   801b7e <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	79 12                	jns    800079 <umain+0x46>
		panic("spawn(hello) failed: %e", r);
  800067:	50                   	push   %eax
  800068:	68 24 29 80 00       	push   $0x802924
  80006d:	6a 09                	push   $0x9
  80006f:	68 3c 29 80 00       	push   $0x80293c
  800074:	e8 62 00 00 00       	call   8000db <_panic>
}
  800079:	c9                   	leave  
  80007a:	c3                   	ret    

0080007b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800083:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800086:	e8 73 0a 00 00       	call   800afe <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800093:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800098:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009d:	85 db                	test   %ebx,%ebx
  80009f:	7e 07                	jle    8000a8 <libmain+0x2d>
		binaryname = argv[0];
  8000a1:	8b 06                	mov    (%esi),%eax
  8000a3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 81 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b2:	e8 0a 00 00 00       	call   8000c1 <exit>
}
  8000b7:	83 c4 10             	add    $0x10,%esp
  8000ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c7:	e8 10 0f 00 00       	call   800fdc <close_all>
	sys_env_destroy(0);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	6a 00                	push   $0x0
  8000d1:	e8 e7 09 00 00       	call   800abd <sys_env_destroy>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000e0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000e3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8000e9:	e8 10 0a 00 00       	call   800afe <sys_getenvid>
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	ff 75 0c             	pushl  0xc(%ebp)
  8000f4:	ff 75 08             	pushl  0x8(%ebp)
  8000f7:	56                   	push   %esi
  8000f8:	50                   	push   %eax
  8000f9:	68 58 29 80 00       	push   $0x802958
  8000fe:	e8 b1 00 00 00       	call   8001b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800103:	83 c4 18             	add    $0x18,%esp
  800106:	53                   	push   %ebx
  800107:	ff 75 10             	pushl  0x10(%ebp)
  80010a:	e8 54 00 00 00       	call   800163 <vcprintf>
	cprintf("\n");
  80010f:	c7 04 24 79 2e 80 00 	movl   $0x802e79,(%esp)
  800116:	e8 99 00 00 00       	call   8001b4 <cprintf>
  80011b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80011e:	cc                   	int3   
  80011f:	eb fd                	jmp    80011e <_panic+0x43>

00800121 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	53                   	push   %ebx
  800125:	83 ec 04             	sub    $0x4,%esp
  800128:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012b:	8b 13                	mov    (%ebx),%edx
  80012d:	8d 42 01             	lea    0x1(%edx),%eax
  800130:	89 03                	mov    %eax,(%ebx)
  800132:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800135:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800139:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013e:	75 1a                	jne    80015a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800140:	83 ec 08             	sub    $0x8,%esp
  800143:	68 ff 00 00 00       	push   $0xff
  800148:	8d 43 08             	lea    0x8(%ebx),%eax
  80014b:	50                   	push   %eax
  80014c:	e8 2f 09 00 00       	call   800a80 <sys_cputs>
		b->idx = 0;
  800151:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800157:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80015a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800173:	00 00 00 
	b.cnt = 0;
  800176:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800180:	ff 75 0c             	pushl  0xc(%ebp)
  800183:	ff 75 08             	pushl  0x8(%ebp)
  800186:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018c:	50                   	push   %eax
  80018d:	68 21 01 80 00       	push   $0x800121
  800192:	e8 54 01 00 00       	call   8002eb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800197:	83 c4 08             	add    $0x8,%esp
  80019a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 d4 08 00 00       	call   800a80 <sys_cputs>

	return b.cnt;
}
  8001ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bd:	50                   	push   %eax
  8001be:	ff 75 08             	pushl  0x8(%ebp)
  8001c1:	e8 9d ff ff ff       	call   800163 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	57                   	push   %edi
  8001cc:	56                   	push   %esi
  8001cd:	53                   	push   %ebx
  8001ce:	83 ec 1c             	sub    $0x1c,%esp
  8001d1:	89 c7                	mov    %eax,%edi
  8001d3:	89 d6                	mov    %edx,%esi
  8001d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001de:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ec:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ef:	39 d3                	cmp    %edx,%ebx
  8001f1:	72 05                	jb     8001f8 <printnum+0x30>
  8001f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f6:	77 45                	ja     80023d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 18             	pushl  0x18(%ebp)
  8001fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800201:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800204:	53                   	push   %ebx
  800205:	ff 75 10             	pushl  0x10(%ebp)
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020e:	ff 75 e0             	pushl  -0x20(%ebp)
  800211:	ff 75 dc             	pushl  -0x24(%ebp)
  800214:	ff 75 d8             	pushl  -0x28(%ebp)
  800217:	e8 54 24 00 00       	call   802670 <__udivdi3>
  80021c:	83 c4 18             	add    $0x18,%esp
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	89 f2                	mov    %esi,%edx
  800223:	89 f8                	mov    %edi,%eax
  800225:	e8 9e ff ff ff       	call   8001c8 <printnum>
  80022a:	83 c4 20             	add    $0x20,%esp
  80022d:	eb 18                	jmp    800247 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	56                   	push   %esi
  800233:	ff 75 18             	pushl  0x18(%ebp)
  800236:	ff d7                	call   *%edi
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	eb 03                	jmp    800240 <printnum+0x78>
  80023d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800240:	83 eb 01             	sub    $0x1,%ebx
  800243:	85 db                	test   %ebx,%ebx
  800245:	7f e8                	jg     80022f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	56                   	push   %esi
  80024b:	83 ec 04             	sub    $0x4,%esp
  80024e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800251:	ff 75 e0             	pushl  -0x20(%ebp)
  800254:	ff 75 dc             	pushl  -0x24(%ebp)
  800257:	ff 75 d8             	pushl  -0x28(%ebp)
  80025a:	e8 41 25 00 00       	call   8027a0 <__umoddi3>
  80025f:	83 c4 14             	add    $0x14,%esp
  800262:	0f be 80 7b 29 80 00 	movsbl 0x80297b(%eax),%eax
  800269:	50                   	push   %eax
  80026a:	ff d7                	call   *%edi
}
  80026c:	83 c4 10             	add    $0x10,%esp
  80026f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027a:	83 fa 01             	cmp    $0x1,%edx
  80027d:	7e 0e                	jle    80028d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027f:	8b 10                	mov    (%eax),%edx
  800281:	8d 4a 08             	lea    0x8(%edx),%ecx
  800284:	89 08                	mov    %ecx,(%eax)
  800286:	8b 02                	mov    (%edx),%eax
  800288:	8b 52 04             	mov    0x4(%edx),%edx
  80028b:	eb 22                	jmp    8002af <getuint+0x38>
	else if (lflag)
  80028d:	85 d2                	test   %edx,%edx
  80028f:	74 10                	je     8002a1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800291:	8b 10                	mov    (%eax),%edx
  800293:	8d 4a 04             	lea    0x4(%edx),%ecx
  800296:	89 08                	mov    %ecx,(%eax)
  800298:	8b 02                	mov    (%edx),%eax
  80029a:	ba 00 00 00 00       	mov    $0x0,%edx
  80029f:	eb 0e                	jmp    8002af <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a1:	8b 10                	mov    (%eax),%edx
  8002a3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a6:	89 08                	mov    %ecx,(%eax)
  8002a8:	8b 02                	mov    (%edx),%eax
  8002aa:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bb:	8b 10                	mov    (%eax),%edx
  8002bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c0:	73 0a                	jae    8002cc <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ca:	88 02                	mov    %al,(%edx)
}
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d7:	50                   	push   %eax
  8002d8:	ff 75 10             	pushl  0x10(%ebp)
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	e8 05 00 00 00       	call   8002eb <vprintfmt>
	va_end(ap);
}
  8002e6:	83 c4 10             	add    $0x10,%esp
  8002e9:	c9                   	leave  
  8002ea:	c3                   	ret    

008002eb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
  8002f1:	83 ec 2c             	sub    $0x2c,%esp
  8002f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fd:	eb 12                	jmp    800311 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ff:	85 c0                	test   %eax,%eax
  800301:	0f 84 89 03 00 00    	je     800690 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	53                   	push   %ebx
  80030b:	50                   	push   %eax
  80030c:	ff d6                	call   *%esi
  80030e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800311:	83 c7 01             	add    $0x1,%edi
  800314:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800318:	83 f8 25             	cmp    $0x25,%eax
  80031b:	75 e2                	jne    8002ff <vprintfmt+0x14>
  80031d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800321:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800328:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800336:	ba 00 00 00 00       	mov    $0x0,%edx
  80033b:	eb 07                	jmp    800344 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800340:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8d 47 01             	lea    0x1(%edi),%eax
  800347:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034a:	0f b6 07             	movzbl (%edi),%eax
  80034d:	0f b6 c8             	movzbl %al,%ecx
  800350:	83 e8 23             	sub    $0x23,%eax
  800353:	3c 55                	cmp    $0x55,%al
  800355:	0f 87 1a 03 00 00    	ja     800675 <vprintfmt+0x38a>
  80035b:	0f b6 c0             	movzbl %al,%eax
  80035e:	ff 24 85 c0 2a 80 00 	jmp    *0x802ac0(,%eax,4)
  800365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800368:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036c:	eb d6                	jmp    800344 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800371:	b8 00 00 00 00       	mov    $0x0,%eax
  800376:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800379:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800380:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800383:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800386:	83 fa 09             	cmp    $0x9,%edx
  800389:	77 39                	ja     8003c4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038e:	eb e9                	jmp    800379 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8d 48 04             	lea    0x4(%eax),%ecx
  800396:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800399:	8b 00                	mov    (%eax),%eax
  80039b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a1:	eb 27                	jmp    8003ca <vprintfmt+0xdf>
  8003a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a6:	85 c0                	test   %eax,%eax
  8003a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ad:	0f 49 c8             	cmovns %eax,%ecx
  8003b0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b6:	eb 8c                	jmp    800344 <vprintfmt+0x59>
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003bb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c2:	eb 80                	jmp    800344 <vprintfmt+0x59>
  8003c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003c7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ce:	0f 89 70 ff ff ff    	jns    800344 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003d4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003da:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e1:	e9 5e ff ff ff       	jmp    800344 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ec:	e9 53 ff ff ff       	jmp    800344 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 50 04             	lea    0x4(%eax),%edx
  8003f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fa:	83 ec 08             	sub    $0x8,%esp
  8003fd:	53                   	push   %ebx
  8003fe:	ff 30                	pushl  (%eax)
  800400:	ff d6                	call   *%esi
			break;
  800402:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800408:	e9 04 ff ff ff       	jmp    800311 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 50 04             	lea    0x4(%eax),%edx
  800413:	89 55 14             	mov    %edx,0x14(%ebp)
  800416:	8b 00                	mov    (%eax),%eax
  800418:	99                   	cltd   
  800419:	31 d0                	xor    %edx,%eax
  80041b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041d:	83 f8 0f             	cmp    $0xf,%eax
  800420:	7f 0b                	jg     80042d <vprintfmt+0x142>
  800422:	8b 14 85 20 2c 80 00 	mov    0x802c20(,%eax,4),%edx
  800429:	85 d2                	test   %edx,%edx
  80042b:	75 18                	jne    800445 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80042d:	50                   	push   %eax
  80042e:	68 93 29 80 00       	push   $0x802993
  800433:	53                   	push   %ebx
  800434:	56                   	push   %esi
  800435:	e8 94 fe ff ff       	call   8002ce <printfmt>
  80043a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800440:	e9 cc fe ff ff       	jmp    800311 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800445:	52                   	push   %edx
  800446:	68 5a 2d 80 00       	push   $0x802d5a
  80044b:	53                   	push   %ebx
  80044c:	56                   	push   %esi
  80044d:	e8 7c fe ff ff       	call   8002ce <printfmt>
  800452:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800458:	e9 b4 fe ff ff       	jmp    800311 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045d:	8b 45 14             	mov    0x14(%ebp),%eax
  800460:	8d 50 04             	lea    0x4(%eax),%edx
  800463:	89 55 14             	mov    %edx,0x14(%ebp)
  800466:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800468:	85 ff                	test   %edi,%edi
  80046a:	b8 8c 29 80 00       	mov    $0x80298c,%eax
  80046f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800472:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800476:	0f 8e 94 00 00 00    	jle    800510 <vprintfmt+0x225>
  80047c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800480:	0f 84 98 00 00 00    	je     80051e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	ff 75 d0             	pushl  -0x30(%ebp)
  80048c:	57                   	push   %edi
  80048d:	e8 86 02 00 00       	call   800718 <strnlen>
  800492:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800495:	29 c1                	sub    %eax,%ecx
  800497:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80049a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	eb 0f                	jmp    8004ba <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	53                   	push   %ebx
  8004af:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b4:	83 ef 01             	sub    $0x1,%edi
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	85 ff                	test   %edi,%edi
  8004bc:	7f ed                	jg     8004ab <vprintfmt+0x1c0>
  8004be:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c4:	85 c9                	test   %ecx,%ecx
  8004c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cb:	0f 49 c1             	cmovns %ecx,%eax
  8004ce:	29 c1                	sub    %eax,%ecx
  8004d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d9:	89 cb                	mov    %ecx,%ebx
  8004db:	eb 4d                	jmp    80052a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e1:	74 1b                	je     8004fe <vprintfmt+0x213>
  8004e3:	0f be c0             	movsbl %al,%eax
  8004e6:	83 e8 20             	sub    $0x20,%eax
  8004e9:	83 f8 5e             	cmp    $0x5e,%eax
  8004ec:	76 10                	jbe    8004fe <vprintfmt+0x213>
					putch('?', putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	ff 75 0c             	pushl  0xc(%ebp)
  8004f4:	6a 3f                	push   $0x3f
  8004f6:	ff 55 08             	call   *0x8(%ebp)
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	eb 0d                	jmp    80050b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	ff 75 0c             	pushl  0xc(%ebp)
  800504:	52                   	push   %edx
  800505:	ff 55 08             	call   *0x8(%ebp)
  800508:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050b:	83 eb 01             	sub    $0x1,%ebx
  80050e:	eb 1a                	jmp    80052a <vprintfmt+0x23f>
  800510:	89 75 08             	mov    %esi,0x8(%ebp)
  800513:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800516:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800519:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051c:	eb 0c                	jmp    80052a <vprintfmt+0x23f>
  80051e:	89 75 08             	mov    %esi,0x8(%ebp)
  800521:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800524:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800527:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052a:	83 c7 01             	add    $0x1,%edi
  80052d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800531:	0f be d0             	movsbl %al,%edx
  800534:	85 d2                	test   %edx,%edx
  800536:	74 23                	je     80055b <vprintfmt+0x270>
  800538:	85 f6                	test   %esi,%esi
  80053a:	78 a1                	js     8004dd <vprintfmt+0x1f2>
  80053c:	83 ee 01             	sub    $0x1,%esi
  80053f:	79 9c                	jns    8004dd <vprintfmt+0x1f2>
  800541:	89 df                	mov    %ebx,%edi
  800543:	8b 75 08             	mov    0x8(%ebp),%esi
  800546:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800549:	eb 18                	jmp    800563 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	53                   	push   %ebx
  80054f:	6a 20                	push   $0x20
  800551:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800553:	83 ef 01             	sub    $0x1,%edi
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	eb 08                	jmp    800563 <vprintfmt+0x278>
  80055b:	89 df                	mov    %ebx,%edi
  80055d:	8b 75 08             	mov    0x8(%ebp),%esi
  800560:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800563:	85 ff                	test   %edi,%edi
  800565:	7f e4                	jg     80054b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800567:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056a:	e9 a2 fd ff ff       	jmp    800311 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056f:	83 fa 01             	cmp    $0x1,%edx
  800572:	7e 16                	jle    80058a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 50 08             	lea    0x8(%eax),%edx
  80057a:	89 55 14             	mov    %edx,0x14(%ebp)
  80057d:	8b 50 04             	mov    0x4(%eax),%edx
  800580:	8b 00                	mov    (%eax),%eax
  800582:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800585:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800588:	eb 32                	jmp    8005bc <vprintfmt+0x2d1>
	else if (lflag)
  80058a:	85 d2                	test   %edx,%edx
  80058c:	74 18                	je     8005a6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8d 50 04             	lea    0x4(%eax),%edx
  800594:	89 55 14             	mov    %edx,0x14(%ebp)
  800597:	8b 00                	mov    (%eax),%eax
  800599:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059c:	89 c1                	mov    %eax,%ecx
  80059e:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a4:	eb 16                	jmp    8005bc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8005af:	8b 00                	mov    (%eax),%eax
  8005b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b4:	89 c1                	mov    %eax,%ecx
  8005b6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005bf:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005cb:	79 74                	jns    800641 <vprintfmt+0x356>
				putch('-', putdat);
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	53                   	push   %ebx
  8005d1:	6a 2d                	push   $0x2d
  8005d3:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005db:	f7 d8                	neg    %eax
  8005dd:	83 d2 00             	adc    $0x0,%edx
  8005e0:	f7 da                	neg    %edx
  8005e2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ea:	eb 55                	jmp    800641 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ef:	e8 83 fc ff ff       	call   800277 <getuint>
			base = 10;
  8005f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005f9:	eb 46                	jmp    800641 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fe:	e8 74 fc ff ff       	call   800277 <getuint>
                        base = 8;
  800603:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800608:	eb 37                	jmp    800641 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	6a 30                	push   $0x30
  800610:	ff d6                	call   *%esi
			putch('x', putdat);
  800612:	83 c4 08             	add    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 78                	push   $0x78
  800618:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 50 04             	lea    0x4(%eax),%edx
  800620:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800623:	8b 00                	mov    (%eax),%eax
  800625:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80062a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800632:	eb 0d                	jmp    800641 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800634:	8d 45 14             	lea    0x14(%ebp),%eax
  800637:	e8 3b fc ff ff       	call   800277 <getuint>
			base = 16;
  80063c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800641:	83 ec 0c             	sub    $0xc,%esp
  800644:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800648:	57                   	push   %edi
  800649:	ff 75 e0             	pushl  -0x20(%ebp)
  80064c:	51                   	push   %ecx
  80064d:	52                   	push   %edx
  80064e:	50                   	push   %eax
  80064f:	89 da                	mov    %ebx,%edx
  800651:	89 f0                	mov    %esi,%eax
  800653:	e8 70 fb ff ff       	call   8001c8 <printnum>
			break;
  800658:	83 c4 20             	add    $0x20,%esp
  80065b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065e:	e9 ae fc ff ff       	jmp    800311 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	53                   	push   %ebx
  800667:	51                   	push   %ecx
  800668:	ff d6                	call   *%esi
			break;
  80066a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800670:	e9 9c fc ff ff       	jmp    800311 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800675:	83 ec 08             	sub    $0x8,%esp
  800678:	53                   	push   %ebx
  800679:	6a 25                	push   $0x25
  80067b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	eb 03                	jmp    800685 <vprintfmt+0x39a>
  800682:	83 ef 01             	sub    $0x1,%edi
  800685:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800689:	75 f7                	jne    800682 <vprintfmt+0x397>
  80068b:	e9 81 fc ff ff       	jmp    800311 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800690:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800693:	5b                   	pop    %ebx
  800694:	5e                   	pop    %esi
  800695:	5f                   	pop    %edi
  800696:	5d                   	pop    %ebp
  800697:	c3                   	ret    

00800698 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800698:	55                   	push   %ebp
  800699:	89 e5                	mov    %esp,%ebp
  80069b:	83 ec 18             	sub    $0x18,%esp
  80069e:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ab:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b5:	85 c0                	test   %eax,%eax
  8006b7:	74 26                	je     8006df <vsnprintf+0x47>
  8006b9:	85 d2                	test   %edx,%edx
  8006bb:	7e 22                	jle    8006df <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006bd:	ff 75 14             	pushl  0x14(%ebp)
  8006c0:	ff 75 10             	pushl  0x10(%ebp)
  8006c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c6:	50                   	push   %eax
  8006c7:	68 b1 02 80 00       	push   $0x8002b1
  8006cc:	e8 1a fc ff ff       	call   8002eb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	eb 05                	jmp    8006e4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e4:	c9                   	leave  
  8006e5:	c3                   	ret    

008006e6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e6:	55                   	push   %ebp
  8006e7:	89 e5                	mov    %esp,%ebp
  8006e9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ec:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ef:	50                   	push   %eax
  8006f0:	ff 75 10             	pushl  0x10(%ebp)
  8006f3:	ff 75 0c             	pushl  0xc(%ebp)
  8006f6:	ff 75 08             	pushl  0x8(%ebp)
  8006f9:	e8 9a ff ff ff       	call   800698 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006fe:	c9                   	leave  
  8006ff:	c3                   	ret    

00800700 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800706:	b8 00 00 00 00       	mov    $0x0,%eax
  80070b:	eb 03                	jmp    800710 <strlen+0x10>
		n++;
  80070d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800710:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800714:	75 f7                	jne    80070d <strlen+0xd>
		n++;
	return n;
}
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800721:	ba 00 00 00 00       	mov    $0x0,%edx
  800726:	eb 03                	jmp    80072b <strnlen+0x13>
		n++;
  800728:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072b:	39 c2                	cmp    %eax,%edx
  80072d:	74 08                	je     800737 <strnlen+0x1f>
  80072f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800733:	75 f3                	jne    800728 <strnlen+0x10>
  800735:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800737:	5d                   	pop    %ebp
  800738:	c3                   	ret    

00800739 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	53                   	push   %ebx
  80073d:	8b 45 08             	mov    0x8(%ebp),%eax
  800740:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800743:	89 c2                	mov    %eax,%edx
  800745:	83 c2 01             	add    $0x1,%edx
  800748:	83 c1 01             	add    $0x1,%ecx
  80074b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80074f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800752:	84 db                	test   %bl,%bl
  800754:	75 ef                	jne    800745 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800756:	5b                   	pop    %ebx
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	53                   	push   %ebx
  80075d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800760:	53                   	push   %ebx
  800761:	e8 9a ff ff ff       	call   800700 <strlen>
  800766:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800769:	ff 75 0c             	pushl  0xc(%ebp)
  80076c:	01 d8                	add    %ebx,%eax
  80076e:	50                   	push   %eax
  80076f:	e8 c5 ff ff ff       	call   800739 <strcpy>
	return dst;
}
  800774:	89 d8                	mov    %ebx,%eax
  800776:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800779:	c9                   	leave  
  80077a:	c3                   	ret    

0080077b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	56                   	push   %esi
  80077f:	53                   	push   %ebx
  800780:	8b 75 08             	mov    0x8(%ebp),%esi
  800783:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800786:	89 f3                	mov    %esi,%ebx
  800788:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078b:	89 f2                	mov    %esi,%edx
  80078d:	eb 0f                	jmp    80079e <strncpy+0x23>
		*dst++ = *src;
  80078f:	83 c2 01             	add    $0x1,%edx
  800792:	0f b6 01             	movzbl (%ecx),%eax
  800795:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800798:	80 39 01             	cmpb   $0x1,(%ecx)
  80079b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079e:	39 da                	cmp    %ebx,%edx
  8007a0:	75 ed                	jne    80078f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a2:	89 f0                	mov    %esi,%eax
  8007a4:	5b                   	pop    %ebx
  8007a5:	5e                   	pop    %esi
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	56                   	push   %esi
  8007ac:	53                   	push   %ebx
  8007ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b3:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b8:	85 d2                	test   %edx,%edx
  8007ba:	74 21                	je     8007dd <strlcpy+0x35>
  8007bc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007c0:	89 f2                	mov    %esi,%edx
  8007c2:	eb 09                	jmp    8007cd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c4:	83 c2 01             	add    $0x1,%edx
  8007c7:	83 c1 01             	add    $0x1,%ecx
  8007ca:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007cd:	39 c2                	cmp    %eax,%edx
  8007cf:	74 09                	je     8007da <strlcpy+0x32>
  8007d1:	0f b6 19             	movzbl (%ecx),%ebx
  8007d4:	84 db                	test   %bl,%bl
  8007d6:	75 ec                	jne    8007c4 <strlcpy+0x1c>
  8007d8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007da:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007dd:	29 f0                	sub    %esi,%eax
}
  8007df:	5b                   	pop    %ebx
  8007e0:	5e                   	pop    %esi
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ec:	eb 06                	jmp    8007f4 <strcmp+0x11>
		p++, q++;
  8007ee:	83 c1 01             	add    $0x1,%ecx
  8007f1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f4:	0f b6 01             	movzbl (%ecx),%eax
  8007f7:	84 c0                	test   %al,%al
  8007f9:	74 04                	je     8007ff <strcmp+0x1c>
  8007fb:	3a 02                	cmp    (%edx),%al
  8007fd:	74 ef                	je     8007ee <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ff:	0f b6 c0             	movzbl %al,%eax
  800802:	0f b6 12             	movzbl (%edx),%edx
  800805:	29 d0                	sub    %edx,%eax
}
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	53                   	push   %ebx
  80080d:	8b 45 08             	mov    0x8(%ebp),%eax
  800810:	8b 55 0c             	mov    0xc(%ebp),%edx
  800813:	89 c3                	mov    %eax,%ebx
  800815:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800818:	eb 06                	jmp    800820 <strncmp+0x17>
		n--, p++, q++;
  80081a:	83 c0 01             	add    $0x1,%eax
  80081d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800820:	39 d8                	cmp    %ebx,%eax
  800822:	74 15                	je     800839 <strncmp+0x30>
  800824:	0f b6 08             	movzbl (%eax),%ecx
  800827:	84 c9                	test   %cl,%cl
  800829:	74 04                	je     80082f <strncmp+0x26>
  80082b:	3a 0a                	cmp    (%edx),%cl
  80082d:	74 eb                	je     80081a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082f:	0f b6 00             	movzbl (%eax),%eax
  800832:	0f b6 12             	movzbl (%edx),%edx
  800835:	29 d0                	sub    %edx,%eax
  800837:	eb 05                	jmp    80083e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800839:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80083e:	5b                   	pop    %ebx
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084b:	eb 07                	jmp    800854 <strchr+0x13>
		if (*s == c)
  80084d:	38 ca                	cmp    %cl,%dl
  80084f:	74 0f                	je     800860 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800851:	83 c0 01             	add    $0x1,%eax
  800854:	0f b6 10             	movzbl (%eax),%edx
  800857:	84 d2                	test   %dl,%dl
  800859:	75 f2                	jne    80084d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80085b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	8b 45 08             	mov    0x8(%ebp),%eax
  800868:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086c:	eb 03                	jmp    800871 <strfind+0xf>
  80086e:	83 c0 01             	add    $0x1,%eax
  800871:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800874:	38 ca                	cmp    %cl,%dl
  800876:	74 04                	je     80087c <strfind+0x1a>
  800878:	84 d2                	test   %dl,%dl
  80087a:	75 f2                	jne    80086e <strfind+0xc>
			break;
	return (char *) s;
}
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	57                   	push   %edi
  800882:	56                   	push   %esi
  800883:	53                   	push   %ebx
  800884:	8b 7d 08             	mov    0x8(%ebp),%edi
  800887:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80088a:	85 c9                	test   %ecx,%ecx
  80088c:	74 36                	je     8008c4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800894:	75 28                	jne    8008be <memset+0x40>
  800896:	f6 c1 03             	test   $0x3,%cl
  800899:	75 23                	jne    8008be <memset+0x40>
		c &= 0xFF;
  80089b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089f:	89 d3                	mov    %edx,%ebx
  8008a1:	c1 e3 08             	shl    $0x8,%ebx
  8008a4:	89 d6                	mov    %edx,%esi
  8008a6:	c1 e6 18             	shl    $0x18,%esi
  8008a9:	89 d0                	mov    %edx,%eax
  8008ab:	c1 e0 10             	shl    $0x10,%eax
  8008ae:	09 f0                	or     %esi,%eax
  8008b0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008b2:	89 d8                	mov    %ebx,%eax
  8008b4:	09 d0                	or     %edx,%eax
  8008b6:	c1 e9 02             	shr    $0x2,%ecx
  8008b9:	fc                   	cld    
  8008ba:	f3 ab                	rep stos %eax,%es:(%edi)
  8008bc:	eb 06                	jmp    8008c4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c1:	fc                   	cld    
  8008c2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c4:	89 f8                	mov    %edi,%eax
  8008c6:	5b                   	pop    %ebx
  8008c7:	5e                   	pop    %esi
  8008c8:	5f                   	pop    %edi
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	57                   	push   %edi
  8008cf:	56                   	push   %esi
  8008d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d9:	39 c6                	cmp    %eax,%esi
  8008db:	73 35                	jae    800912 <memmove+0x47>
  8008dd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e0:	39 d0                	cmp    %edx,%eax
  8008e2:	73 2e                	jae    800912 <memmove+0x47>
		s += n;
		d += n;
  8008e4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e7:	89 d6                	mov    %edx,%esi
  8008e9:	09 fe                	or     %edi,%esi
  8008eb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f1:	75 13                	jne    800906 <memmove+0x3b>
  8008f3:	f6 c1 03             	test   $0x3,%cl
  8008f6:	75 0e                	jne    800906 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008f8:	83 ef 04             	sub    $0x4,%edi
  8008fb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008fe:	c1 e9 02             	shr    $0x2,%ecx
  800901:	fd                   	std    
  800902:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800904:	eb 09                	jmp    80090f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800906:	83 ef 01             	sub    $0x1,%edi
  800909:	8d 72 ff             	lea    -0x1(%edx),%esi
  80090c:	fd                   	std    
  80090d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090f:	fc                   	cld    
  800910:	eb 1d                	jmp    80092f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800912:	89 f2                	mov    %esi,%edx
  800914:	09 c2                	or     %eax,%edx
  800916:	f6 c2 03             	test   $0x3,%dl
  800919:	75 0f                	jne    80092a <memmove+0x5f>
  80091b:	f6 c1 03             	test   $0x3,%cl
  80091e:	75 0a                	jne    80092a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800920:	c1 e9 02             	shr    $0x2,%ecx
  800923:	89 c7                	mov    %eax,%edi
  800925:	fc                   	cld    
  800926:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800928:	eb 05                	jmp    80092f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80092a:	89 c7                	mov    %eax,%edi
  80092c:	fc                   	cld    
  80092d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80092f:	5e                   	pop    %esi
  800930:	5f                   	pop    %edi
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800936:	ff 75 10             	pushl  0x10(%ebp)
  800939:	ff 75 0c             	pushl  0xc(%ebp)
  80093c:	ff 75 08             	pushl  0x8(%ebp)
  80093f:	e8 87 ff ff ff       	call   8008cb <memmove>
}
  800944:	c9                   	leave  
  800945:	c3                   	ret    

00800946 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	56                   	push   %esi
  80094a:	53                   	push   %ebx
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800951:	89 c6                	mov    %eax,%esi
  800953:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800956:	eb 1a                	jmp    800972 <memcmp+0x2c>
		if (*s1 != *s2)
  800958:	0f b6 08             	movzbl (%eax),%ecx
  80095b:	0f b6 1a             	movzbl (%edx),%ebx
  80095e:	38 d9                	cmp    %bl,%cl
  800960:	74 0a                	je     80096c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800962:	0f b6 c1             	movzbl %cl,%eax
  800965:	0f b6 db             	movzbl %bl,%ebx
  800968:	29 d8                	sub    %ebx,%eax
  80096a:	eb 0f                	jmp    80097b <memcmp+0x35>
		s1++, s2++;
  80096c:	83 c0 01             	add    $0x1,%eax
  80096f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800972:	39 f0                	cmp    %esi,%eax
  800974:	75 e2                	jne    800958 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	53                   	push   %ebx
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800986:	89 c1                	mov    %eax,%ecx
  800988:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80098b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098f:	eb 0a                	jmp    80099b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800991:	0f b6 10             	movzbl (%eax),%edx
  800994:	39 da                	cmp    %ebx,%edx
  800996:	74 07                	je     80099f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800998:	83 c0 01             	add    $0x1,%eax
  80099b:	39 c8                	cmp    %ecx,%eax
  80099d:	72 f2                	jb     800991 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80099f:	5b                   	pop    %ebx
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	57                   	push   %edi
  8009a6:	56                   	push   %esi
  8009a7:	53                   	push   %ebx
  8009a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ae:	eb 03                	jmp    8009b3 <strtol+0x11>
		s++;
  8009b0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b3:	0f b6 01             	movzbl (%ecx),%eax
  8009b6:	3c 20                	cmp    $0x20,%al
  8009b8:	74 f6                	je     8009b0 <strtol+0xe>
  8009ba:	3c 09                	cmp    $0x9,%al
  8009bc:	74 f2                	je     8009b0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009be:	3c 2b                	cmp    $0x2b,%al
  8009c0:	75 0a                	jne    8009cc <strtol+0x2a>
		s++;
  8009c2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c5:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ca:	eb 11                	jmp    8009dd <strtol+0x3b>
  8009cc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d1:	3c 2d                	cmp    $0x2d,%al
  8009d3:	75 08                	jne    8009dd <strtol+0x3b>
		s++, neg = 1;
  8009d5:	83 c1 01             	add    $0x1,%ecx
  8009d8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009dd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e3:	75 15                	jne    8009fa <strtol+0x58>
  8009e5:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e8:	75 10                	jne    8009fa <strtol+0x58>
  8009ea:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ee:	75 7c                	jne    800a6c <strtol+0xca>
		s += 2, base = 16;
  8009f0:	83 c1 02             	add    $0x2,%ecx
  8009f3:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f8:	eb 16                	jmp    800a10 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009fa:	85 db                	test   %ebx,%ebx
  8009fc:	75 12                	jne    800a10 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009fe:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a03:	80 39 30             	cmpb   $0x30,(%ecx)
  800a06:	75 08                	jne    800a10 <strtol+0x6e>
		s++, base = 8;
  800a08:	83 c1 01             	add    $0x1,%ecx
  800a0b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a10:	b8 00 00 00 00       	mov    $0x0,%eax
  800a15:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a18:	0f b6 11             	movzbl (%ecx),%edx
  800a1b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a1e:	89 f3                	mov    %esi,%ebx
  800a20:	80 fb 09             	cmp    $0x9,%bl
  800a23:	77 08                	ja     800a2d <strtol+0x8b>
			dig = *s - '0';
  800a25:	0f be d2             	movsbl %dl,%edx
  800a28:	83 ea 30             	sub    $0x30,%edx
  800a2b:	eb 22                	jmp    800a4f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a2d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a30:	89 f3                	mov    %esi,%ebx
  800a32:	80 fb 19             	cmp    $0x19,%bl
  800a35:	77 08                	ja     800a3f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a37:	0f be d2             	movsbl %dl,%edx
  800a3a:	83 ea 57             	sub    $0x57,%edx
  800a3d:	eb 10                	jmp    800a4f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a3f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a42:	89 f3                	mov    %esi,%ebx
  800a44:	80 fb 19             	cmp    $0x19,%bl
  800a47:	77 16                	ja     800a5f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a49:	0f be d2             	movsbl %dl,%edx
  800a4c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a4f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a52:	7d 0b                	jge    800a5f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a54:	83 c1 01             	add    $0x1,%ecx
  800a57:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a5b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a5d:	eb b9                	jmp    800a18 <strtol+0x76>

	if (endptr)
  800a5f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a63:	74 0d                	je     800a72 <strtol+0xd0>
		*endptr = (char *) s;
  800a65:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a68:	89 0e                	mov    %ecx,(%esi)
  800a6a:	eb 06                	jmp    800a72 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6c:	85 db                	test   %ebx,%ebx
  800a6e:	74 98                	je     800a08 <strtol+0x66>
  800a70:	eb 9e                	jmp    800a10 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a72:	89 c2                	mov    %eax,%edx
  800a74:	f7 da                	neg    %edx
  800a76:	85 ff                	test   %edi,%edi
  800a78:	0f 45 c2             	cmovne %edx,%eax
}
  800a7b:	5b                   	pop    %ebx
  800a7c:	5e                   	pop    %esi
  800a7d:	5f                   	pop    %edi
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	57                   	push   %edi
  800a84:	56                   	push   %esi
  800a85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a86:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a91:	89 c3                	mov    %eax,%ebx
  800a93:	89 c7                	mov    %eax,%edi
  800a95:	89 c6                	mov    %eax,%esi
  800a97:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a99:	5b                   	pop    %ebx
  800a9a:	5e                   	pop    %esi
  800a9b:	5f                   	pop    %edi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	57                   	push   %edi
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa4:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa9:	b8 01 00 00 00       	mov    $0x1,%eax
  800aae:	89 d1                	mov    %edx,%ecx
  800ab0:	89 d3                	mov    %edx,%ebx
  800ab2:	89 d7                	mov    %edx,%edi
  800ab4:	89 d6                	mov    %edx,%esi
  800ab6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
  800ac3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800acb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad3:	89 cb                	mov    %ecx,%ebx
  800ad5:	89 cf                	mov    %ecx,%edi
  800ad7:	89 ce                	mov    %ecx,%esi
  800ad9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800adb:	85 c0                	test   %eax,%eax
  800add:	7e 17                	jle    800af6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800adf:	83 ec 0c             	sub    $0xc,%esp
  800ae2:	50                   	push   %eax
  800ae3:	6a 03                	push   $0x3
  800ae5:	68 7f 2c 80 00       	push   $0x802c7f
  800aea:	6a 23                	push   $0x23
  800aec:	68 9c 2c 80 00       	push   $0x802c9c
  800af1:	e8 e5 f5 ff ff       	call   8000db <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	ba 00 00 00 00       	mov    $0x0,%edx
  800b09:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0e:	89 d1                	mov    %edx,%ecx
  800b10:	89 d3                	mov    %edx,%ebx
  800b12:	89 d7                	mov    %edx,%edi
  800b14:	89 d6                	mov    %edx,%esi
  800b16:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <sys_yield>:

void
sys_yield(void)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b23:	ba 00 00 00 00       	mov    $0x0,%edx
  800b28:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b2d:	89 d1                	mov    %edx,%ecx
  800b2f:	89 d3                	mov    %edx,%ebx
  800b31:	89 d7                	mov    %edx,%edi
  800b33:	89 d6                	mov    %edx,%esi
  800b35:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b45:	be 00 00 00 00       	mov    $0x0,%esi
  800b4a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b52:	8b 55 08             	mov    0x8(%ebp),%edx
  800b55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b58:	89 f7                	mov    %esi,%edi
  800b5a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b5c:	85 c0                	test   %eax,%eax
  800b5e:	7e 17                	jle    800b77 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b60:	83 ec 0c             	sub    $0xc,%esp
  800b63:	50                   	push   %eax
  800b64:	6a 04                	push   $0x4
  800b66:	68 7f 2c 80 00       	push   $0x802c7f
  800b6b:	6a 23                	push   $0x23
  800b6d:	68 9c 2c 80 00       	push   $0x802c9c
  800b72:	e8 64 f5 ff ff       	call   8000db <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
  800b85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b88:	b8 05 00 00 00       	mov    $0x5,%eax
  800b8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b96:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b99:	8b 75 18             	mov    0x18(%ebp),%esi
  800b9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9e:	85 c0                	test   %eax,%eax
  800ba0:	7e 17                	jle    800bb9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba2:	83 ec 0c             	sub    $0xc,%esp
  800ba5:	50                   	push   %eax
  800ba6:	6a 05                	push   $0x5
  800ba8:	68 7f 2c 80 00       	push   $0x802c7f
  800bad:	6a 23                	push   $0x23
  800baf:	68 9c 2c 80 00       	push   $0x802c9c
  800bb4:	e8 22 f5 ff ff       	call   8000db <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
  800bc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bcf:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bda:	89 df                	mov    %ebx,%edi
  800bdc:	89 de                	mov    %ebx,%esi
  800bde:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be0:	85 c0                	test   %eax,%eax
  800be2:	7e 17                	jle    800bfb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be4:	83 ec 0c             	sub    $0xc,%esp
  800be7:	50                   	push   %eax
  800be8:	6a 06                	push   $0x6
  800bea:	68 7f 2c 80 00       	push   $0x802c7f
  800bef:	6a 23                	push   $0x23
  800bf1:	68 9c 2c 80 00       	push   $0x802c9c
  800bf6:	e8 e0 f4 ff ff       	call   8000db <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c11:	b8 08 00 00 00       	mov    $0x8,%eax
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	89 df                	mov    %ebx,%edi
  800c1e:	89 de                	mov    %ebx,%esi
  800c20:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c22:	85 c0                	test   %eax,%eax
  800c24:	7e 17                	jle    800c3d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c26:	83 ec 0c             	sub    $0xc,%esp
  800c29:	50                   	push   %eax
  800c2a:	6a 08                	push   $0x8
  800c2c:	68 7f 2c 80 00       	push   $0x802c7f
  800c31:	6a 23                	push   $0x23
  800c33:	68 9c 2c 80 00       	push   $0x802c9c
  800c38:	e8 9e f4 ff ff       	call   8000db <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c53:	b8 09 00 00 00       	mov    $0x9,%eax
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5e:	89 df                	mov    %ebx,%edi
  800c60:	89 de                	mov    %ebx,%esi
  800c62:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c64:	85 c0                	test   %eax,%eax
  800c66:	7e 17                	jle    800c7f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	50                   	push   %eax
  800c6c:	6a 09                	push   $0x9
  800c6e:	68 7f 2c 80 00       	push   $0x802c7f
  800c73:	6a 23                	push   $0x23
  800c75:	68 9c 2c 80 00       	push   $0x802c9c
  800c7a:	e8 5c f4 ff ff       	call   8000db <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c90:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c95:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca0:	89 df                	mov    %ebx,%edi
  800ca2:	89 de                	mov    %ebx,%esi
  800ca4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	7e 17                	jle    800cc1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caa:	83 ec 0c             	sub    $0xc,%esp
  800cad:	50                   	push   %eax
  800cae:	6a 0a                	push   $0xa
  800cb0:	68 7f 2c 80 00       	push   $0x802c7f
  800cb5:	6a 23                	push   $0x23
  800cb7:	68 9c 2c 80 00       	push   $0x802c9c
  800cbc:	e8 1a f4 ff ff       	call   8000db <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccf:	be 00 00 00 00       	mov    $0x0,%esi
  800cd4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
  800cf2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfa:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	89 cb                	mov    %ecx,%ebx
  800d04:	89 cf                	mov    %ecx,%edi
  800d06:	89 ce                	mov    %ecx,%esi
  800d08:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0a:	85 c0                	test   %eax,%eax
  800d0c:	7e 17                	jle    800d25 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0e:	83 ec 0c             	sub    $0xc,%esp
  800d11:	50                   	push   %eax
  800d12:	6a 0d                	push   $0xd
  800d14:	68 7f 2c 80 00       	push   $0x802c7f
  800d19:	6a 23                	push   $0x23
  800d1b:	68 9c 2c 80 00       	push   $0x802c9c
  800d20:	e8 b6 f3 ff ff       	call   8000db <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	57                   	push   %edi
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d33:	ba 00 00 00 00       	mov    $0x0,%edx
  800d38:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d3d:	89 d1                	mov    %edx,%ecx
  800d3f:	89 d3                	mov    %edx,%ebx
  800d41:	89 d7                	mov    %edx,%edi
  800d43:	89 d6                	mov    %edx,%esi
  800d45:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_transmit_packet>:

int
sys_transmit_packet(void *buf, size_t size)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
  800d52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5a:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	89 df                	mov    %ebx,%edi
  800d67:	89 de                	mov    %ebx,%esi
  800d69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	7e 17                	jle    800d86 <sys_transmit_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	50                   	push   %eax
  800d73:	6a 0f                	push   $0xf
  800d75:	68 7f 2c 80 00       	push   $0x802c7f
  800d7a:	6a 23                	push   $0x23
  800d7c:	68 9c 2c 80 00       	push   $0x802c9c
  800d81:	e8 55 f3 ff ff       	call   8000db <_panic>
int
sys_transmit_packet(void *buf, size_t size)
{
	return syscall(SYS_transmit_packet, 1,
		(uint32_t) buf, (uint32_t) size, 0, 0, 0);
}
  800d86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <sys_receive_packet>:

int
sys_receive_packet(void *buf, size_t *size_store)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9c:	b8 10 00 00 00       	mov    $0x10,%eax
  800da1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	89 df                	mov    %ebx,%edi
  800da9:	89 de                	mov    %ebx,%esi
  800dab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dad:	85 c0                	test   %eax,%eax
  800daf:	7e 17                	jle    800dc8 <sys_receive_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	50                   	push   %eax
  800db5:	6a 10                	push   $0x10
  800db7:	68 7f 2c 80 00       	push   $0x802c7f
  800dbc:	6a 23                	push   $0x23
  800dbe:	68 9c 2c 80 00       	push   $0x802c9c
  800dc3:	e8 13 f3 ff ff       	call   8000db <_panic>
int
sys_receive_packet(void *buf, size_t *size_store)
{
	return syscall(SYS_receive_packet, 1,
		(uint32_t) buf, (uint32_t) size_store, 0, 0, 0);
}
  800dc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <sys_get_mac_address>:

int
sys_get_mac_address(void *buf)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
  800dd6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dde:	b8 11 00 00 00       	mov    $0x11,%eax
  800de3:	8b 55 08             	mov    0x8(%ebp),%edx
  800de6:	89 cb                	mov    %ecx,%ebx
  800de8:	89 cf                	mov    %ecx,%edi
  800dea:	89 ce                	mov    %ecx,%esi
  800dec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dee:	85 c0                	test   %eax,%eax
  800df0:	7e 17                	jle    800e09 <sys_get_mac_address+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df2:	83 ec 0c             	sub    $0xc,%esp
  800df5:	50                   	push   %eax
  800df6:	6a 11                	push   $0x11
  800df8:	68 7f 2c 80 00       	push   $0x802c7f
  800dfd:	6a 23                	push   $0x23
  800dff:	68 9c 2c 80 00       	push   $0x802c9c
  800e04:	e8 d2 f2 ff ff       	call   8000db <_panic>
int
sys_get_mac_address(void *buf)
{
	return syscall(SYS_get_mac_address, 1,
		(uint32_t) buf, 0, 0, 0, 0);
}
  800e09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0c:	5b                   	pop    %ebx
  800e0d:	5e                   	pop    %esi
  800e0e:	5f                   	pop    %edi
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    

00800e11 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e14:	8b 45 08             	mov    0x8(%ebp),%eax
  800e17:	05 00 00 00 30       	add    $0x30000000,%eax
  800e1c:	c1 e8 0c             	shr    $0xc,%eax
}
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    

00800e21 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e24:	8b 45 08             	mov    0x8(%ebp),%eax
  800e27:	05 00 00 00 30       	add    $0x30000000,%eax
  800e2c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e31:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    

00800e38 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e43:	89 c2                	mov    %eax,%edx
  800e45:	c1 ea 16             	shr    $0x16,%edx
  800e48:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e4f:	f6 c2 01             	test   $0x1,%dl
  800e52:	74 11                	je     800e65 <fd_alloc+0x2d>
  800e54:	89 c2                	mov    %eax,%edx
  800e56:	c1 ea 0c             	shr    $0xc,%edx
  800e59:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e60:	f6 c2 01             	test   $0x1,%dl
  800e63:	75 09                	jne    800e6e <fd_alloc+0x36>
			*fd_store = fd;
  800e65:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e67:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6c:	eb 17                	jmp    800e85 <fd_alloc+0x4d>
  800e6e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e73:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e78:	75 c9                	jne    800e43 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e7a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e80:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e85:	5d                   	pop    %ebp
  800e86:	c3                   	ret    

00800e87 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e8d:	83 f8 1f             	cmp    $0x1f,%eax
  800e90:	77 36                	ja     800ec8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e92:	c1 e0 0c             	shl    $0xc,%eax
  800e95:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e9a:	89 c2                	mov    %eax,%edx
  800e9c:	c1 ea 16             	shr    $0x16,%edx
  800e9f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea6:	f6 c2 01             	test   $0x1,%dl
  800ea9:	74 24                	je     800ecf <fd_lookup+0x48>
  800eab:	89 c2                	mov    %eax,%edx
  800ead:	c1 ea 0c             	shr    $0xc,%edx
  800eb0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb7:	f6 c2 01             	test   $0x1,%dl
  800eba:	74 1a                	je     800ed6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ebc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ebf:	89 02                	mov    %eax,(%edx)
	return 0;
  800ec1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec6:	eb 13                	jmp    800edb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ec8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ecd:	eb 0c                	jmp    800edb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ecf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ed4:	eb 05                	jmp    800edb <fd_lookup+0x54>
  800ed6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800edb:	5d                   	pop    %ebp
  800edc:	c3                   	ret    

00800edd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	83 ec 08             	sub    $0x8,%esp
  800ee3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee6:	ba 28 2d 80 00       	mov    $0x802d28,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800eeb:	eb 13                	jmp    800f00 <dev_lookup+0x23>
  800eed:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ef0:	39 08                	cmp    %ecx,(%eax)
  800ef2:	75 0c                	jne    800f00 <dev_lookup+0x23>
			*dev = devtab[i];
  800ef4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef7:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ef9:	b8 00 00 00 00       	mov    $0x0,%eax
  800efe:	eb 2e                	jmp    800f2e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f00:	8b 02                	mov    (%edx),%eax
  800f02:	85 c0                	test   %eax,%eax
  800f04:	75 e7                	jne    800eed <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f06:	a1 08 40 80 00       	mov    0x804008,%eax
  800f0b:	8b 40 48             	mov    0x48(%eax),%eax
  800f0e:	83 ec 04             	sub    $0x4,%esp
  800f11:	51                   	push   %ecx
  800f12:	50                   	push   %eax
  800f13:	68 ac 2c 80 00       	push   $0x802cac
  800f18:	e8 97 f2 ff ff       	call   8001b4 <cprintf>
	*dev = 0;
  800f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f20:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f26:	83 c4 10             	add    $0x10,%esp
  800f29:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f2e:	c9                   	leave  
  800f2f:	c3                   	ret    

00800f30 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	56                   	push   %esi
  800f34:	53                   	push   %ebx
  800f35:	83 ec 10             	sub    $0x10,%esp
  800f38:	8b 75 08             	mov    0x8(%ebp),%esi
  800f3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f41:	50                   	push   %eax
  800f42:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f48:	c1 e8 0c             	shr    $0xc,%eax
  800f4b:	50                   	push   %eax
  800f4c:	e8 36 ff ff ff       	call   800e87 <fd_lookup>
  800f51:	83 c4 08             	add    $0x8,%esp
  800f54:	85 c0                	test   %eax,%eax
  800f56:	78 05                	js     800f5d <fd_close+0x2d>
	    || fd != fd2)
  800f58:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f5b:	74 0c                	je     800f69 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f5d:	84 db                	test   %bl,%bl
  800f5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f64:	0f 44 c2             	cmove  %edx,%eax
  800f67:	eb 41                	jmp    800faa <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f69:	83 ec 08             	sub    $0x8,%esp
  800f6c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f6f:	50                   	push   %eax
  800f70:	ff 36                	pushl  (%esi)
  800f72:	e8 66 ff ff ff       	call   800edd <dev_lookup>
  800f77:	89 c3                	mov    %eax,%ebx
  800f79:	83 c4 10             	add    $0x10,%esp
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	78 1a                	js     800f9a <fd_close+0x6a>
		if (dev->dev_close)
  800f80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f83:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f86:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	74 0b                	je     800f9a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f8f:	83 ec 0c             	sub    $0xc,%esp
  800f92:	56                   	push   %esi
  800f93:	ff d0                	call   *%eax
  800f95:	89 c3                	mov    %eax,%ebx
  800f97:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f9a:	83 ec 08             	sub    $0x8,%esp
  800f9d:	56                   	push   %esi
  800f9e:	6a 00                	push   $0x0
  800fa0:	e8 1c fc ff ff       	call   800bc1 <sys_page_unmap>
	return r;
  800fa5:	83 c4 10             	add    $0x10,%esp
  800fa8:	89 d8                	mov    %ebx,%eax
}
  800faa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fad:	5b                   	pop    %ebx
  800fae:	5e                   	pop    %esi
  800faf:	5d                   	pop    %ebp
  800fb0:	c3                   	ret    

00800fb1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fba:	50                   	push   %eax
  800fbb:	ff 75 08             	pushl  0x8(%ebp)
  800fbe:	e8 c4 fe ff ff       	call   800e87 <fd_lookup>
  800fc3:	83 c4 08             	add    $0x8,%esp
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	78 10                	js     800fda <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fca:	83 ec 08             	sub    $0x8,%esp
  800fcd:	6a 01                	push   $0x1
  800fcf:	ff 75 f4             	pushl  -0xc(%ebp)
  800fd2:	e8 59 ff ff ff       	call   800f30 <fd_close>
  800fd7:	83 c4 10             	add    $0x10,%esp
}
  800fda:	c9                   	leave  
  800fdb:	c3                   	ret    

00800fdc <close_all>:

void
close_all(void)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	53                   	push   %ebx
  800fe0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fe3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fe8:	83 ec 0c             	sub    $0xc,%esp
  800feb:	53                   	push   %ebx
  800fec:	e8 c0 ff ff ff       	call   800fb1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ff1:	83 c3 01             	add    $0x1,%ebx
  800ff4:	83 c4 10             	add    $0x10,%esp
  800ff7:	83 fb 20             	cmp    $0x20,%ebx
  800ffa:	75 ec                	jne    800fe8 <close_all+0xc>
		close(i);
}
  800ffc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fff:	c9                   	leave  
  801000:	c3                   	ret    

00801001 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	57                   	push   %edi
  801005:	56                   	push   %esi
  801006:	53                   	push   %ebx
  801007:	83 ec 2c             	sub    $0x2c,%esp
  80100a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80100d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801010:	50                   	push   %eax
  801011:	ff 75 08             	pushl  0x8(%ebp)
  801014:	e8 6e fe ff ff       	call   800e87 <fd_lookup>
  801019:	83 c4 08             	add    $0x8,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	0f 88 c1 00 00 00    	js     8010e5 <dup+0xe4>
		return r;
	close(newfdnum);
  801024:	83 ec 0c             	sub    $0xc,%esp
  801027:	56                   	push   %esi
  801028:	e8 84 ff ff ff       	call   800fb1 <close>

	newfd = INDEX2FD(newfdnum);
  80102d:	89 f3                	mov    %esi,%ebx
  80102f:	c1 e3 0c             	shl    $0xc,%ebx
  801032:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801038:	83 c4 04             	add    $0x4,%esp
  80103b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80103e:	e8 de fd ff ff       	call   800e21 <fd2data>
  801043:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801045:	89 1c 24             	mov    %ebx,(%esp)
  801048:	e8 d4 fd ff ff       	call   800e21 <fd2data>
  80104d:	83 c4 10             	add    $0x10,%esp
  801050:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801053:	89 f8                	mov    %edi,%eax
  801055:	c1 e8 16             	shr    $0x16,%eax
  801058:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80105f:	a8 01                	test   $0x1,%al
  801061:	74 37                	je     80109a <dup+0x99>
  801063:	89 f8                	mov    %edi,%eax
  801065:	c1 e8 0c             	shr    $0xc,%eax
  801068:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80106f:	f6 c2 01             	test   $0x1,%dl
  801072:	74 26                	je     80109a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801074:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80107b:	83 ec 0c             	sub    $0xc,%esp
  80107e:	25 07 0e 00 00       	and    $0xe07,%eax
  801083:	50                   	push   %eax
  801084:	ff 75 d4             	pushl  -0x2c(%ebp)
  801087:	6a 00                	push   $0x0
  801089:	57                   	push   %edi
  80108a:	6a 00                	push   $0x0
  80108c:	e8 ee fa ff ff       	call   800b7f <sys_page_map>
  801091:	89 c7                	mov    %eax,%edi
  801093:	83 c4 20             	add    $0x20,%esp
  801096:	85 c0                	test   %eax,%eax
  801098:	78 2e                	js     8010c8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80109a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80109d:	89 d0                	mov    %edx,%eax
  80109f:	c1 e8 0c             	shr    $0xc,%eax
  8010a2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a9:	83 ec 0c             	sub    $0xc,%esp
  8010ac:	25 07 0e 00 00       	and    $0xe07,%eax
  8010b1:	50                   	push   %eax
  8010b2:	53                   	push   %ebx
  8010b3:	6a 00                	push   $0x0
  8010b5:	52                   	push   %edx
  8010b6:	6a 00                	push   $0x0
  8010b8:	e8 c2 fa ff ff       	call   800b7f <sys_page_map>
  8010bd:	89 c7                	mov    %eax,%edi
  8010bf:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010c2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010c4:	85 ff                	test   %edi,%edi
  8010c6:	79 1d                	jns    8010e5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010c8:	83 ec 08             	sub    $0x8,%esp
  8010cb:	53                   	push   %ebx
  8010cc:	6a 00                	push   $0x0
  8010ce:	e8 ee fa ff ff       	call   800bc1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010d3:	83 c4 08             	add    $0x8,%esp
  8010d6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010d9:	6a 00                	push   $0x0
  8010db:	e8 e1 fa ff ff       	call   800bc1 <sys_page_unmap>
	return r;
  8010e0:	83 c4 10             	add    $0x10,%esp
  8010e3:	89 f8                	mov    %edi,%eax
}
  8010e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e8:	5b                   	pop    %ebx
  8010e9:	5e                   	pop    %esi
  8010ea:	5f                   	pop    %edi
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	53                   	push   %ebx
  8010f1:	83 ec 14             	sub    $0x14,%esp
  8010f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010fa:	50                   	push   %eax
  8010fb:	53                   	push   %ebx
  8010fc:	e8 86 fd ff ff       	call   800e87 <fd_lookup>
  801101:	83 c4 08             	add    $0x8,%esp
  801104:	89 c2                	mov    %eax,%edx
  801106:	85 c0                	test   %eax,%eax
  801108:	78 6d                	js     801177 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80110a:	83 ec 08             	sub    $0x8,%esp
  80110d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801110:	50                   	push   %eax
  801111:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801114:	ff 30                	pushl  (%eax)
  801116:	e8 c2 fd ff ff       	call   800edd <dev_lookup>
  80111b:	83 c4 10             	add    $0x10,%esp
  80111e:	85 c0                	test   %eax,%eax
  801120:	78 4c                	js     80116e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801122:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801125:	8b 42 08             	mov    0x8(%edx),%eax
  801128:	83 e0 03             	and    $0x3,%eax
  80112b:	83 f8 01             	cmp    $0x1,%eax
  80112e:	75 21                	jne    801151 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801130:	a1 08 40 80 00       	mov    0x804008,%eax
  801135:	8b 40 48             	mov    0x48(%eax),%eax
  801138:	83 ec 04             	sub    $0x4,%esp
  80113b:	53                   	push   %ebx
  80113c:	50                   	push   %eax
  80113d:	68 ed 2c 80 00       	push   $0x802ced
  801142:	e8 6d f0 ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  801147:	83 c4 10             	add    $0x10,%esp
  80114a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80114f:	eb 26                	jmp    801177 <read+0x8a>
	}
	if (!dev->dev_read)
  801151:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801154:	8b 40 08             	mov    0x8(%eax),%eax
  801157:	85 c0                	test   %eax,%eax
  801159:	74 17                	je     801172 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80115b:	83 ec 04             	sub    $0x4,%esp
  80115e:	ff 75 10             	pushl  0x10(%ebp)
  801161:	ff 75 0c             	pushl  0xc(%ebp)
  801164:	52                   	push   %edx
  801165:	ff d0                	call   *%eax
  801167:	89 c2                	mov    %eax,%edx
  801169:	83 c4 10             	add    $0x10,%esp
  80116c:	eb 09                	jmp    801177 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80116e:	89 c2                	mov    %eax,%edx
  801170:	eb 05                	jmp    801177 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801172:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801177:	89 d0                	mov    %edx,%eax
  801179:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80117c:	c9                   	leave  
  80117d:	c3                   	ret    

0080117e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	57                   	push   %edi
  801182:	56                   	push   %esi
  801183:	53                   	push   %ebx
  801184:	83 ec 0c             	sub    $0xc,%esp
  801187:	8b 7d 08             	mov    0x8(%ebp),%edi
  80118a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80118d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801192:	eb 21                	jmp    8011b5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801194:	83 ec 04             	sub    $0x4,%esp
  801197:	89 f0                	mov    %esi,%eax
  801199:	29 d8                	sub    %ebx,%eax
  80119b:	50                   	push   %eax
  80119c:	89 d8                	mov    %ebx,%eax
  80119e:	03 45 0c             	add    0xc(%ebp),%eax
  8011a1:	50                   	push   %eax
  8011a2:	57                   	push   %edi
  8011a3:	e8 45 ff ff ff       	call   8010ed <read>
		if (m < 0)
  8011a8:	83 c4 10             	add    $0x10,%esp
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	78 10                	js     8011bf <readn+0x41>
			return m;
		if (m == 0)
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	74 0a                	je     8011bd <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011b3:	01 c3                	add    %eax,%ebx
  8011b5:	39 f3                	cmp    %esi,%ebx
  8011b7:	72 db                	jb     801194 <readn+0x16>
  8011b9:	89 d8                	mov    %ebx,%eax
  8011bb:	eb 02                	jmp    8011bf <readn+0x41>
  8011bd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c2:	5b                   	pop    %ebx
  8011c3:	5e                   	pop    %esi
  8011c4:	5f                   	pop    %edi
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	53                   	push   %ebx
  8011cb:	83 ec 14             	sub    $0x14,%esp
  8011ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d4:	50                   	push   %eax
  8011d5:	53                   	push   %ebx
  8011d6:	e8 ac fc ff ff       	call   800e87 <fd_lookup>
  8011db:	83 c4 08             	add    $0x8,%esp
  8011de:	89 c2                	mov    %eax,%edx
  8011e0:	85 c0                	test   %eax,%eax
  8011e2:	78 68                	js     80124c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e4:	83 ec 08             	sub    $0x8,%esp
  8011e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ea:	50                   	push   %eax
  8011eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ee:	ff 30                	pushl  (%eax)
  8011f0:	e8 e8 fc ff ff       	call   800edd <dev_lookup>
  8011f5:	83 c4 10             	add    $0x10,%esp
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	78 47                	js     801243 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ff:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801203:	75 21                	jne    801226 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801205:	a1 08 40 80 00       	mov    0x804008,%eax
  80120a:	8b 40 48             	mov    0x48(%eax),%eax
  80120d:	83 ec 04             	sub    $0x4,%esp
  801210:	53                   	push   %ebx
  801211:	50                   	push   %eax
  801212:	68 09 2d 80 00       	push   $0x802d09
  801217:	e8 98 ef ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  80121c:	83 c4 10             	add    $0x10,%esp
  80121f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801224:	eb 26                	jmp    80124c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801226:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801229:	8b 52 0c             	mov    0xc(%edx),%edx
  80122c:	85 d2                	test   %edx,%edx
  80122e:	74 17                	je     801247 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801230:	83 ec 04             	sub    $0x4,%esp
  801233:	ff 75 10             	pushl  0x10(%ebp)
  801236:	ff 75 0c             	pushl  0xc(%ebp)
  801239:	50                   	push   %eax
  80123a:	ff d2                	call   *%edx
  80123c:	89 c2                	mov    %eax,%edx
  80123e:	83 c4 10             	add    $0x10,%esp
  801241:	eb 09                	jmp    80124c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801243:	89 c2                	mov    %eax,%edx
  801245:	eb 05                	jmp    80124c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801247:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80124c:	89 d0                	mov    %edx,%eax
  80124e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801251:	c9                   	leave  
  801252:	c3                   	ret    

00801253 <seek>:

int
seek(int fdnum, off_t offset)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801259:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80125c:	50                   	push   %eax
  80125d:	ff 75 08             	pushl  0x8(%ebp)
  801260:	e8 22 fc ff ff       	call   800e87 <fd_lookup>
  801265:	83 c4 08             	add    $0x8,%esp
  801268:	85 c0                	test   %eax,%eax
  80126a:	78 0e                	js     80127a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80126c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80126f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801272:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801275:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80127a:	c9                   	leave  
  80127b:	c3                   	ret    

0080127c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	53                   	push   %ebx
  801280:	83 ec 14             	sub    $0x14,%esp
  801283:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801286:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801289:	50                   	push   %eax
  80128a:	53                   	push   %ebx
  80128b:	e8 f7 fb ff ff       	call   800e87 <fd_lookup>
  801290:	83 c4 08             	add    $0x8,%esp
  801293:	89 c2                	mov    %eax,%edx
  801295:	85 c0                	test   %eax,%eax
  801297:	78 65                	js     8012fe <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801299:	83 ec 08             	sub    $0x8,%esp
  80129c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129f:	50                   	push   %eax
  8012a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a3:	ff 30                	pushl  (%eax)
  8012a5:	e8 33 fc ff ff       	call   800edd <dev_lookup>
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 44                	js     8012f5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012b8:	75 21                	jne    8012db <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012ba:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012bf:	8b 40 48             	mov    0x48(%eax),%eax
  8012c2:	83 ec 04             	sub    $0x4,%esp
  8012c5:	53                   	push   %ebx
  8012c6:	50                   	push   %eax
  8012c7:	68 cc 2c 80 00       	push   $0x802ccc
  8012cc:	e8 e3 ee ff ff       	call   8001b4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012d9:	eb 23                	jmp    8012fe <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012de:	8b 52 18             	mov    0x18(%edx),%edx
  8012e1:	85 d2                	test   %edx,%edx
  8012e3:	74 14                	je     8012f9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012e5:	83 ec 08             	sub    $0x8,%esp
  8012e8:	ff 75 0c             	pushl  0xc(%ebp)
  8012eb:	50                   	push   %eax
  8012ec:	ff d2                	call   *%edx
  8012ee:	89 c2                	mov    %eax,%edx
  8012f0:	83 c4 10             	add    $0x10,%esp
  8012f3:	eb 09                	jmp    8012fe <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f5:	89 c2                	mov    %eax,%edx
  8012f7:	eb 05                	jmp    8012fe <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012f9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012fe:	89 d0                	mov    %edx,%eax
  801300:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801303:	c9                   	leave  
  801304:	c3                   	ret    

00801305 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	53                   	push   %ebx
  801309:	83 ec 14             	sub    $0x14,%esp
  80130c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801312:	50                   	push   %eax
  801313:	ff 75 08             	pushl  0x8(%ebp)
  801316:	e8 6c fb ff ff       	call   800e87 <fd_lookup>
  80131b:	83 c4 08             	add    $0x8,%esp
  80131e:	89 c2                	mov    %eax,%edx
  801320:	85 c0                	test   %eax,%eax
  801322:	78 58                	js     80137c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801324:	83 ec 08             	sub    $0x8,%esp
  801327:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132a:	50                   	push   %eax
  80132b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132e:	ff 30                	pushl  (%eax)
  801330:	e8 a8 fb ff ff       	call   800edd <dev_lookup>
  801335:	83 c4 10             	add    $0x10,%esp
  801338:	85 c0                	test   %eax,%eax
  80133a:	78 37                	js     801373 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80133c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801343:	74 32                	je     801377 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801345:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801348:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80134f:	00 00 00 
	stat->st_isdir = 0;
  801352:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801359:	00 00 00 
	stat->st_dev = dev;
  80135c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801362:	83 ec 08             	sub    $0x8,%esp
  801365:	53                   	push   %ebx
  801366:	ff 75 f0             	pushl  -0x10(%ebp)
  801369:	ff 50 14             	call   *0x14(%eax)
  80136c:	89 c2                	mov    %eax,%edx
  80136e:	83 c4 10             	add    $0x10,%esp
  801371:	eb 09                	jmp    80137c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801373:	89 c2                	mov    %eax,%edx
  801375:	eb 05                	jmp    80137c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801377:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80137c:	89 d0                	mov    %edx,%eax
  80137e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801381:	c9                   	leave  
  801382:	c3                   	ret    

00801383 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801383:	55                   	push   %ebp
  801384:	89 e5                	mov    %esp,%ebp
  801386:	56                   	push   %esi
  801387:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	6a 00                	push   $0x0
  80138d:	ff 75 08             	pushl  0x8(%ebp)
  801390:	e8 0c 02 00 00       	call   8015a1 <open>
  801395:	89 c3                	mov    %eax,%ebx
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	85 c0                	test   %eax,%eax
  80139c:	78 1b                	js     8013b9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80139e:	83 ec 08             	sub    $0x8,%esp
  8013a1:	ff 75 0c             	pushl  0xc(%ebp)
  8013a4:	50                   	push   %eax
  8013a5:	e8 5b ff ff ff       	call   801305 <fstat>
  8013aa:	89 c6                	mov    %eax,%esi
	close(fd);
  8013ac:	89 1c 24             	mov    %ebx,(%esp)
  8013af:	e8 fd fb ff ff       	call   800fb1 <close>
	return r;
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	89 f0                	mov    %esi,%eax
}
  8013b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013bc:	5b                   	pop    %ebx
  8013bd:	5e                   	pop    %esi
  8013be:	5d                   	pop    %ebp
  8013bf:	c3                   	ret    

008013c0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	56                   	push   %esi
  8013c4:	53                   	push   %ebx
  8013c5:	89 c6                	mov    %eax,%esi
  8013c7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013c9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013d0:	75 12                	jne    8013e4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013d2:	83 ec 0c             	sub    $0xc,%esp
  8013d5:	6a 01                	push   $0x1
  8013d7:	e8 18 12 00 00       	call   8025f4 <ipc_find_env>
  8013dc:	a3 00 40 80 00       	mov    %eax,0x804000
  8013e1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013e4:	6a 07                	push   $0x7
  8013e6:	68 00 50 80 00       	push   $0x805000
  8013eb:	56                   	push   %esi
  8013ec:	ff 35 00 40 80 00    	pushl  0x804000
  8013f2:	e8 a9 11 00 00       	call   8025a0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013f7:	83 c4 0c             	add    $0xc,%esp
  8013fa:	6a 00                	push   $0x0
  8013fc:	53                   	push   %ebx
  8013fd:	6a 00                	push   $0x0
  8013ff:	e8 33 11 00 00       	call   802537 <ipc_recv>
}
  801404:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801407:	5b                   	pop    %ebx
  801408:	5e                   	pop    %esi
  801409:	5d                   	pop    %ebp
  80140a:	c3                   	ret    

0080140b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801411:	8b 45 08             	mov    0x8(%ebp),%eax
  801414:	8b 40 0c             	mov    0xc(%eax),%eax
  801417:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80141c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80141f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801424:	ba 00 00 00 00       	mov    $0x0,%edx
  801429:	b8 02 00 00 00       	mov    $0x2,%eax
  80142e:	e8 8d ff ff ff       	call   8013c0 <fsipc>
}
  801433:	c9                   	leave  
  801434:	c3                   	ret    

00801435 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80143b:	8b 45 08             	mov    0x8(%ebp),%eax
  80143e:	8b 40 0c             	mov    0xc(%eax),%eax
  801441:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801446:	ba 00 00 00 00       	mov    $0x0,%edx
  80144b:	b8 06 00 00 00       	mov    $0x6,%eax
  801450:	e8 6b ff ff ff       	call   8013c0 <fsipc>
}
  801455:	c9                   	leave  
  801456:	c3                   	ret    

00801457 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	53                   	push   %ebx
  80145b:	83 ec 04             	sub    $0x4,%esp
  80145e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801461:	8b 45 08             	mov    0x8(%ebp),%eax
  801464:	8b 40 0c             	mov    0xc(%eax),%eax
  801467:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80146c:	ba 00 00 00 00       	mov    $0x0,%edx
  801471:	b8 05 00 00 00       	mov    $0x5,%eax
  801476:	e8 45 ff ff ff       	call   8013c0 <fsipc>
  80147b:	85 c0                	test   %eax,%eax
  80147d:	78 2c                	js     8014ab <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80147f:	83 ec 08             	sub    $0x8,%esp
  801482:	68 00 50 80 00       	push   $0x805000
  801487:	53                   	push   %ebx
  801488:	e8 ac f2 ff ff       	call   800739 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80148d:	a1 80 50 80 00       	mov    0x805080,%eax
  801492:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801498:	a1 84 50 80 00       	mov    0x805084,%eax
  80149d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ae:	c9                   	leave  
  8014af:	c3                   	ret    

008014b0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	53                   	push   %ebx
  8014b4:	83 ec 08             	sub    $0x8,%esp
  8014b7:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8014bd:	8b 52 0c             	mov    0xc(%edx),%edx
  8014c0:	89 15 00 50 80 00    	mov    %edx,0x805000
  8014c6:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014cb:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8014d0:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8014d3:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8014d9:	53                   	push   %ebx
  8014da:	ff 75 0c             	pushl  0xc(%ebp)
  8014dd:	68 08 50 80 00       	push   $0x805008
  8014e2:	e8 e4 f3 ff ff       	call   8008cb <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  8014e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ec:	b8 04 00 00 00       	mov    $0x4,%eax
  8014f1:	e8 ca fe ff ff       	call   8013c0 <fsipc>
  8014f6:	83 c4 10             	add    $0x10,%esp
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	78 1d                	js     80151a <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  8014fd:	39 d8                	cmp    %ebx,%eax
  8014ff:	76 19                	jbe    80151a <devfile_write+0x6a>
  801501:	68 3c 2d 80 00       	push   $0x802d3c
  801506:	68 48 2d 80 00       	push   $0x802d48
  80150b:	68 a5 00 00 00       	push   $0xa5
  801510:	68 5d 2d 80 00       	push   $0x802d5d
  801515:	e8 c1 eb ff ff       	call   8000db <_panic>
	return r;
}
  80151a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151d:	c9                   	leave  
  80151e:	c3                   	ret    

0080151f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80151f:	55                   	push   %ebp
  801520:	89 e5                	mov    %esp,%ebp
  801522:	56                   	push   %esi
  801523:	53                   	push   %ebx
  801524:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801527:	8b 45 08             	mov    0x8(%ebp),%eax
  80152a:	8b 40 0c             	mov    0xc(%eax),%eax
  80152d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801532:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801538:	ba 00 00 00 00       	mov    $0x0,%edx
  80153d:	b8 03 00 00 00       	mov    $0x3,%eax
  801542:	e8 79 fe ff ff       	call   8013c0 <fsipc>
  801547:	89 c3                	mov    %eax,%ebx
  801549:	85 c0                	test   %eax,%eax
  80154b:	78 4b                	js     801598 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80154d:	39 c6                	cmp    %eax,%esi
  80154f:	73 16                	jae    801567 <devfile_read+0x48>
  801551:	68 68 2d 80 00       	push   $0x802d68
  801556:	68 48 2d 80 00       	push   $0x802d48
  80155b:	6a 7c                	push   $0x7c
  80155d:	68 5d 2d 80 00       	push   $0x802d5d
  801562:	e8 74 eb ff ff       	call   8000db <_panic>
	assert(r <= PGSIZE);
  801567:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80156c:	7e 16                	jle    801584 <devfile_read+0x65>
  80156e:	68 6f 2d 80 00       	push   $0x802d6f
  801573:	68 48 2d 80 00       	push   $0x802d48
  801578:	6a 7d                	push   $0x7d
  80157a:	68 5d 2d 80 00       	push   $0x802d5d
  80157f:	e8 57 eb ff ff       	call   8000db <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801584:	83 ec 04             	sub    $0x4,%esp
  801587:	50                   	push   %eax
  801588:	68 00 50 80 00       	push   $0x805000
  80158d:	ff 75 0c             	pushl  0xc(%ebp)
  801590:	e8 36 f3 ff ff       	call   8008cb <memmove>
	return r;
  801595:	83 c4 10             	add    $0x10,%esp
}
  801598:	89 d8                	mov    %ebx,%eax
  80159a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80159d:	5b                   	pop    %ebx
  80159e:	5e                   	pop    %esi
  80159f:	5d                   	pop    %ebp
  8015a0:	c3                   	ret    

008015a1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	53                   	push   %ebx
  8015a5:	83 ec 20             	sub    $0x20,%esp
  8015a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015ab:	53                   	push   %ebx
  8015ac:	e8 4f f1 ff ff       	call   800700 <strlen>
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015b9:	7f 67                	jg     801622 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015bb:	83 ec 0c             	sub    $0xc,%esp
  8015be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c1:	50                   	push   %eax
  8015c2:	e8 71 f8 ff ff       	call   800e38 <fd_alloc>
  8015c7:	83 c4 10             	add    $0x10,%esp
		return r;
  8015ca:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	78 57                	js     801627 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015d0:	83 ec 08             	sub    $0x8,%esp
  8015d3:	53                   	push   %ebx
  8015d4:	68 00 50 80 00       	push   $0x805000
  8015d9:	e8 5b f1 ff ff       	call   800739 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015e1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ee:	e8 cd fd ff ff       	call   8013c0 <fsipc>
  8015f3:	89 c3                	mov    %eax,%ebx
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	85 c0                	test   %eax,%eax
  8015fa:	79 14                	jns    801610 <open+0x6f>
		fd_close(fd, 0);
  8015fc:	83 ec 08             	sub    $0x8,%esp
  8015ff:	6a 00                	push   $0x0
  801601:	ff 75 f4             	pushl  -0xc(%ebp)
  801604:	e8 27 f9 ff ff       	call   800f30 <fd_close>
		return r;
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	89 da                	mov    %ebx,%edx
  80160e:	eb 17                	jmp    801627 <open+0x86>
	}

	return fd2num(fd);
  801610:	83 ec 0c             	sub    $0xc,%esp
  801613:	ff 75 f4             	pushl  -0xc(%ebp)
  801616:	e8 f6 f7 ff ff       	call   800e11 <fd2num>
  80161b:	89 c2                	mov    %eax,%edx
  80161d:	83 c4 10             	add    $0x10,%esp
  801620:	eb 05                	jmp    801627 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801622:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801627:	89 d0                	mov    %edx,%eax
  801629:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162c:	c9                   	leave  
  80162d:	c3                   	ret    

0080162e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80162e:	55                   	push   %ebp
  80162f:	89 e5                	mov    %esp,%ebp
  801631:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801634:	ba 00 00 00 00       	mov    $0x0,%edx
  801639:	b8 08 00 00 00       	mov    $0x8,%eax
  80163e:	e8 7d fd ff ff       	call   8013c0 <fsipc>
}
  801643:	c9                   	leave  
  801644:	c3                   	ret    

00801645 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	57                   	push   %edi
  801649:	56                   	push   %esi
  80164a:	53                   	push   %ebx
  80164b:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801651:	6a 00                	push   $0x0
  801653:	ff 75 08             	pushl  0x8(%ebp)
  801656:	e8 46 ff ff ff       	call   8015a1 <open>
  80165b:	89 c7                	mov    %eax,%edi
  80165d:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	85 c0                	test   %eax,%eax
  801668:	0f 88 a6 04 00 00    	js     801b14 <spawn+0x4cf>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80166e:	83 ec 04             	sub    $0x4,%esp
  801671:	68 00 02 00 00       	push   $0x200
  801676:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80167c:	50                   	push   %eax
  80167d:	57                   	push   %edi
  80167e:	e8 fb fa ff ff       	call   80117e <readn>
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	3d 00 02 00 00       	cmp    $0x200,%eax
  80168b:	75 0c                	jne    801699 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80168d:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801694:	45 4c 46 
  801697:	74 33                	je     8016cc <spawn+0x87>
		close(fd);
  801699:	83 ec 0c             	sub    $0xc,%esp
  80169c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8016a2:	e8 0a f9 ff ff       	call   800fb1 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8016a7:	83 c4 0c             	add    $0xc,%esp
  8016aa:	68 7f 45 4c 46       	push   $0x464c457f
  8016af:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8016b5:	68 7b 2d 80 00       	push   $0x802d7b
  8016ba:	e8 f5 ea ff ff       	call   8001b4 <cprintf>
		return -E_NOT_EXEC;
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8016c7:	e9 a8 04 00 00       	jmp    801b74 <spawn+0x52f>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8016cc:	b8 07 00 00 00       	mov    $0x7,%eax
  8016d1:	cd 30                	int    $0x30
  8016d3:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8016d9:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	0f 88 35 04 00 00    	js     801b1c <spawn+0x4d7>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8016e7:	89 c6                	mov    %eax,%esi
  8016e9:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8016ef:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8016f2:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8016f8:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8016fe:	b9 11 00 00 00       	mov    $0x11,%ecx
  801703:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801705:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80170b:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801711:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801716:	be 00 00 00 00       	mov    $0x0,%esi
  80171b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80171e:	eb 13                	jmp    801733 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801720:	83 ec 0c             	sub    $0xc,%esp
  801723:	50                   	push   %eax
  801724:	e8 d7 ef ff ff       	call   800700 <strlen>
  801729:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80172d:	83 c3 01             	add    $0x1,%ebx
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80173a:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80173d:	85 c0                	test   %eax,%eax
  80173f:	75 df                	jne    801720 <spawn+0xdb>
  801741:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801747:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80174d:	bf 00 10 40 00       	mov    $0x401000,%edi
  801752:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801754:	89 fa                	mov    %edi,%edx
  801756:	83 e2 fc             	and    $0xfffffffc,%edx
  801759:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801760:	29 c2                	sub    %eax,%edx
  801762:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801768:	8d 42 f8             	lea    -0x8(%edx),%eax
  80176b:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801770:	0f 86 b6 03 00 00    	jbe    801b2c <spawn+0x4e7>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801776:	83 ec 04             	sub    $0x4,%esp
  801779:	6a 07                	push   $0x7
  80177b:	68 00 00 40 00       	push   $0x400000
  801780:	6a 00                	push   $0x0
  801782:	e8 b5 f3 ff ff       	call   800b3c <sys_page_alloc>
  801787:	83 c4 10             	add    $0x10,%esp
  80178a:	85 c0                	test   %eax,%eax
  80178c:	0f 88 a1 03 00 00    	js     801b33 <spawn+0x4ee>
  801792:	be 00 00 00 00       	mov    $0x0,%esi
  801797:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80179d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017a0:	eb 30                	jmp    8017d2 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8017a2:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8017a8:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8017ae:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8017b1:	83 ec 08             	sub    $0x8,%esp
  8017b4:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017b7:	57                   	push   %edi
  8017b8:	e8 7c ef ff ff       	call   800739 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8017bd:	83 c4 04             	add    $0x4,%esp
  8017c0:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017c3:	e8 38 ef ff ff       	call   800700 <strlen>
  8017c8:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8017cc:	83 c6 01             	add    $0x1,%esi
  8017cf:	83 c4 10             	add    $0x10,%esp
  8017d2:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8017d8:	7f c8                	jg     8017a2 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8017da:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8017e0:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8017e6:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8017ed:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8017f3:	74 19                	je     80180e <spawn+0x1c9>
  8017f5:	68 00 2e 80 00       	push   $0x802e00
  8017fa:	68 48 2d 80 00       	push   $0x802d48
  8017ff:	68 f1 00 00 00       	push   $0xf1
  801804:	68 95 2d 80 00       	push   $0x802d95
  801809:	e8 cd e8 ff ff       	call   8000db <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80180e:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801814:	89 f8                	mov    %edi,%eax
  801816:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80181b:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  80181e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801824:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801827:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  80182d:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801833:	83 ec 0c             	sub    $0xc,%esp
  801836:	6a 07                	push   $0x7
  801838:	68 00 d0 bf ee       	push   $0xeebfd000
  80183d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801843:	68 00 00 40 00       	push   $0x400000
  801848:	6a 00                	push   $0x0
  80184a:	e8 30 f3 ff ff       	call   800b7f <sys_page_map>
  80184f:	89 c3                	mov    %eax,%ebx
  801851:	83 c4 20             	add    $0x20,%esp
  801854:	85 c0                	test   %eax,%eax
  801856:	0f 88 06 03 00 00    	js     801b62 <spawn+0x51d>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80185c:	83 ec 08             	sub    $0x8,%esp
  80185f:	68 00 00 40 00       	push   $0x400000
  801864:	6a 00                	push   $0x0
  801866:	e8 56 f3 ff ff       	call   800bc1 <sys_page_unmap>
  80186b:	89 c3                	mov    %eax,%ebx
  80186d:	83 c4 10             	add    $0x10,%esp
  801870:	85 c0                	test   %eax,%eax
  801872:	0f 88 ea 02 00 00    	js     801b62 <spawn+0x51d>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801878:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  80187e:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801885:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80188b:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801892:	00 00 00 
  801895:	e9 88 01 00 00       	jmp    801a22 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  80189a:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8018a0:	83 38 01             	cmpl   $0x1,(%eax)
  8018a3:	0f 85 6b 01 00 00    	jne    801a14 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8018a9:	89 c7                	mov    %eax,%edi
  8018ab:	8b 40 18             	mov    0x18(%eax),%eax
  8018ae:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8018b4:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8018b7:	83 f8 01             	cmp    $0x1,%eax
  8018ba:	19 c0                	sbb    %eax,%eax
  8018bc:	83 e0 fe             	and    $0xfffffffe,%eax
  8018bf:	83 c0 07             	add    $0x7,%eax
  8018c2:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8018c8:	89 f8                	mov    %edi,%eax
  8018ca:	8b 7f 04             	mov    0x4(%edi),%edi
  8018cd:	89 f9                	mov    %edi,%ecx
  8018cf:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  8018d5:	8b 78 10             	mov    0x10(%eax),%edi
  8018d8:	8b 50 14             	mov    0x14(%eax),%edx
  8018db:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  8018e1:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8018e4:	89 f0                	mov    %esi,%eax
  8018e6:	25 ff 0f 00 00       	and    $0xfff,%eax
  8018eb:	74 14                	je     801901 <spawn+0x2bc>
		va -= i;
  8018ed:	29 c6                	sub    %eax,%esi
		memsz += i;
  8018ef:	01 c2                	add    %eax,%edx
  8018f1:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  8018f7:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8018f9:	29 c1                	sub    %eax,%ecx
  8018fb:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801901:	bb 00 00 00 00       	mov    $0x0,%ebx
  801906:	e9 f7 00 00 00       	jmp    801a02 <spawn+0x3bd>
		if (i >= filesz) {
  80190b:	39 df                	cmp    %ebx,%edi
  80190d:	77 27                	ja     801936 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80190f:	83 ec 04             	sub    $0x4,%esp
  801912:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801918:	56                   	push   %esi
  801919:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80191f:	e8 18 f2 ff ff       	call   800b3c <sys_page_alloc>
  801924:	83 c4 10             	add    $0x10,%esp
  801927:	85 c0                	test   %eax,%eax
  801929:	0f 89 c7 00 00 00    	jns    8019f6 <spawn+0x3b1>
  80192f:	89 c3                	mov    %eax,%ebx
  801931:	e9 0b 02 00 00       	jmp    801b41 <spawn+0x4fc>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801936:	83 ec 04             	sub    $0x4,%esp
  801939:	6a 07                	push   $0x7
  80193b:	68 00 00 40 00       	push   $0x400000
  801940:	6a 00                	push   $0x0
  801942:	e8 f5 f1 ff ff       	call   800b3c <sys_page_alloc>
  801947:	83 c4 10             	add    $0x10,%esp
  80194a:	85 c0                	test   %eax,%eax
  80194c:	0f 88 e5 01 00 00    	js     801b37 <spawn+0x4f2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801952:	83 ec 08             	sub    $0x8,%esp
  801955:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80195b:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801961:	50                   	push   %eax
  801962:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801968:	e8 e6 f8 ff ff       	call   801253 <seek>
  80196d:	83 c4 10             	add    $0x10,%esp
  801970:	85 c0                	test   %eax,%eax
  801972:	0f 88 c3 01 00 00    	js     801b3b <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801978:	83 ec 04             	sub    $0x4,%esp
  80197b:	89 f8                	mov    %edi,%eax
  80197d:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801983:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801988:	b9 00 10 00 00       	mov    $0x1000,%ecx
  80198d:	0f 47 c1             	cmova  %ecx,%eax
  801990:	50                   	push   %eax
  801991:	68 00 00 40 00       	push   $0x400000
  801996:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80199c:	e8 dd f7 ff ff       	call   80117e <readn>
  8019a1:	83 c4 10             	add    $0x10,%esp
  8019a4:	85 c0                	test   %eax,%eax
  8019a6:	0f 88 93 01 00 00    	js     801b3f <spawn+0x4fa>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8019ac:	83 ec 0c             	sub    $0xc,%esp
  8019af:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8019b5:	56                   	push   %esi
  8019b6:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8019bc:	68 00 00 40 00       	push   $0x400000
  8019c1:	6a 00                	push   $0x0
  8019c3:	e8 b7 f1 ff ff       	call   800b7f <sys_page_map>
  8019c8:	83 c4 20             	add    $0x20,%esp
  8019cb:	85 c0                	test   %eax,%eax
  8019cd:	79 15                	jns    8019e4 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  8019cf:	50                   	push   %eax
  8019d0:	68 a1 2d 80 00       	push   $0x802da1
  8019d5:	68 24 01 00 00       	push   $0x124
  8019da:	68 95 2d 80 00       	push   $0x802d95
  8019df:	e8 f7 e6 ff ff       	call   8000db <_panic>
			sys_page_unmap(0, UTEMP);
  8019e4:	83 ec 08             	sub    $0x8,%esp
  8019e7:	68 00 00 40 00       	push   $0x400000
  8019ec:	6a 00                	push   $0x0
  8019ee:	e8 ce f1 ff ff       	call   800bc1 <sys_page_unmap>
  8019f3:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8019f6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019fc:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801a02:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801a08:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801a0e:	0f 87 f7 fe ff ff    	ja     80190b <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a14:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801a1b:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801a22:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801a29:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801a2f:	0f 8c 65 fe ff ff    	jl     80189a <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801a35:	83 ec 0c             	sub    $0xc,%esp
  801a38:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a3e:	e8 6e f5 ff ff       	call   800fb1 <close>
  801a43:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	// Loop through all the pte's of parent's pgdir in user space
        uint32_t pn;
        for (pn = UTEXT/PGSIZE; pn < UTOP/PGSIZE; pn++) {
  801a46:	bb 00 08 00 00       	mov    $0x800,%ebx
  801a4b:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		
		if (uvpd[pn/NPTENTRIES] & PTE_P) {
  801a51:	89 d8                	mov    %ebx,%eax
  801a53:	c1 e8 0a             	shr    $0xa,%eax
  801a56:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a5d:	a8 01                	test   $0x1,%al
  801a5f:	74 4b                	je     801aac <spawn+0x467>
		
			pte_t pte = uvpt[pn];
  801a61:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax

			
			if ((pte & PTE_P) && (pte & PTE_SHARE)) {
  801a68:	89 c2                	mov    %eax,%edx
  801a6a:	81 e2 01 04 00 00    	and    $0x401,%edx
  801a70:	81 fa 01 04 00 00    	cmp    $0x401,%edx
  801a76:	75 34                	jne    801aac <spawn+0x467>
  801a78:	89 da                	mov    %ebx,%edx
  801a7a:	c1 e2 0c             	shl    $0xc,%edx
				void *va = (void *) (pn * PGSIZE);
				uint32_t perm = pte & PTE_SYSCALL;
				int r;
				if ((r = sys_page_map(0, va, child, va, perm)) < 0)
  801a7d:	83 ec 0c             	sub    $0xc,%esp
  801a80:	25 07 0e 00 00       	and    $0xe07,%eax
  801a85:	50                   	push   %eax
  801a86:	52                   	push   %edx
  801a87:	56                   	push   %esi
  801a88:	52                   	push   %edx
  801a89:	6a 00                	push   $0x0
  801a8b:	e8 ef f0 ff ff       	call   800b7f <sys_page_map>
  801a90:	83 c4 20             	add    $0x20,%esp
  801a93:	85 c0                	test   %eax,%eax
  801a95:	79 15                	jns    801aac <spawn+0x467>
					panic("sys_page_map: %e", r);
  801a97:	50                   	push   %eax
  801a98:	68 be 2d 80 00       	push   $0x802dbe
  801a9d:	68 3e 01 00 00       	push   $0x13e
  801aa2:	68 95 2d 80 00       	push   $0x802d95
  801aa7:	e8 2f e6 ff ff       	call   8000db <_panic>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	// Loop through all the pte's of parent's pgdir in user space
        uint32_t pn;
        for (pn = UTEXT/PGSIZE; pn < UTOP/PGSIZE; pn++) {
  801aac:	83 c3 01             	add    $0x1,%ebx
  801aaf:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  801ab5:	75 9a                	jne    801a51 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801ab7:	83 ec 08             	sub    $0x8,%esp
  801aba:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ac0:	50                   	push   %eax
  801ac1:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ac7:	e8 79 f1 ff ff       	call   800c45 <sys_env_set_trapframe>
  801acc:	83 c4 10             	add    $0x10,%esp
  801acf:	85 c0                	test   %eax,%eax
  801ad1:	79 15                	jns    801ae8 <spawn+0x4a3>
		panic("sys_env_set_trapframe: %e", r);
  801ad3:	50                   	push   %eax
  801ad4:	68 cf 2d 80 00       	push   $0x802dcf
  801ad9:	68 85 00 00 00       	push   $0x85
  801ade:	68 95 2d 80 00       	push   $0x802d95
  801ae3:	e8 f3 e5 ff ff       	call   8000db <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801ae8:	83 ec 08             	sub    $0x8,%esp
  801aeb:	6a 02                	push   $0x2
  801aed:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801af3:	e8 0b f1 ff ff       	call   800c03 <sys_env_set_status>
  801af8:	83 c4 10             	add    $0x10,%esp
  801afb:	85 c0                	test   %eax,%eax
  801afd:	79 25                	jns    801b24 <spawn+0x4df>
		panic("sys_env_set_status: %e", r);
  801aff:	50                   	push   %eax
  801b00:	68 e9 2d 80 00       	push   $0x802de9
  801b05:	68 88 00 00 00       	push   $0x88
  801b0a:	68 95 2d 80 00       	push   $0x802d95
  801b0f:	e8 c7 e5 ff ff       	call   8000db <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801b14:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801b1a:	eb 58                	jmp    801b74 <spawn+0x52f>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801b1c:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b22:	eb 50                	jmp    801b74 <spawn+0x52f>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801b24:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b2a:	eb 48                	jmp    801b74 <spawn+0x52f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801b2c:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801b31:	eb 41                	jmp    801b74 <spawn+0x52f>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801b33:	89 c3                	mov    %eax,%ebx
  801b35:	eb 3d                	jmp    801b74 <spawn+0x52f>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b37:	89 c3                	mov    %eax,%ebx
  801b39:	eb 06                	jmp    801b41 <spawn+0x4fc>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b3b:	89 c3                	mov    %eax,%ebx
  801b3d:	eb 02                	jmp    801b41 <spawn+0x4fc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b3f:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801b41:	83 ec 0c             	sub    $0xc,%esp
  801b44:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b4a:	e8 6e ef ff ff       	call   800abd <sys_env_destroy>
	close(fd);
  801b4f:	83 c4 04             	add    $0x4,%esp
  801b52:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b58:	e8 54 f4 ff ff       	call   800fb1 <close>
	return r;
  801b5d:	83 c4 10             	add    $0x10,%esp
  801b60:	eb 12                	jmp    801b74 <spawn+0x52f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801b62:	83 ec 08             	sub    $0x8,%esp
  801b65:	68 00 00 40 00       	push   $0x400000
  801b6a:	6a 00                	push   $0x0
  801b6c:	e8 50 f0 ff ff       	call   800bc1 <sys_page_unmap>
  801b71:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801b74:	89 d8                	mov    %ebx,%eax
  801b76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b79:	5b                   	pop    %ebx
  801b7a:	5e                   	pop    %esi
  801b7b:	5f                   	pop    %edi
  801b7c:	5d                   	pop    %ebp
  801b7d:	c3                   	ret    

00801b7e <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	56                   	push   %esi
  801b82:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b83:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801b86:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b8b:	eb 03                	jmp    801b90 <spawnl+0x12>
		argc++;
  801b8d:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b90:	83 c2 04             	add    $0x4,%edx
  801b93:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801b97:	75 f4                	jne    801b8d <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801b99:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801ba0:	83 e2 f0             	and    $0xfffffff0,%edx
  801ba3:	29 d4                	sub    %edx,%esp
  801ba5:	8d 54 24 03          	lea    0x3(%esp),%edx
  801ba9:	c1 ea 02             	shr    $0x2,%edx
  801bac:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801bb3:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801bb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb8:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801bbf:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801bc6:	00 
  801bc7:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801bc9:	b8 00 00 00 00       	mov    $0x0,%eax
  801bce:	eb 0a                	jmp    801bda <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801bd0:	83 c0 01             	add    $0x1,%eax
  801bd3:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801bd7:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801bda:	39 d0                	cmp    %edx,%eax
  801bdc:	75 f2                	jne    801bd0 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801bde:	83 ec 08             	sub    $0x8,%esp
  801be1:	56                   	push   %esi
  801be2:	ff 75 08             	pushl  0x8(%ebp)
  801be5:	e8 5b fa ff ff       	call   801645 <spawn>
}
  801bea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bed:	5b                   	pop    %ebx
  801bee:	5e                   	pop    %esi
  801bef:	5d                   	pop    %ebp
  801bf0:	c3                   	ret    

00801bf1 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801bf1:	55                   	push   %ebp
  801bf2:	89 e5                	mov    %esp,%ebp
  801bf4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801bf7:	68 28 2e 80 00       	push   $0x802e28
  801bfc:	ff 75 0c             	pushl  0xc(%ebp)
  801bff:	e8 35 eb ff ff       	call   800739 <strcpy>
	return 0;
}
  801c04:	b8 00 00 00 00       	mov    $0x0,%eax
  801c09:	c9                   	leave  
  801c0a:	c3                   	ret    

00801c0b <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	53                   	push   %ebx
  801c0f:	83 ec 10             	sub    $0x10,%esp
  801c12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c15:	53                   	push   %ebx
  801c16:	e8 12 0a 00 00       	call   80262d <pageref>
  801c1b:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801c1e:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801c23:	83 f8 01             	cmp    $0x1,%eax
  801c26:	75 10                	jne    801c38 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801c28:	83 ec 0c             	sub    $0xc,%esp
  801c2b:	ff 73 0c             	pushl  0xc(%ebx)
  801c2e:	e8 c0 02 00 00       	call   801ef3 <nsipc_close>
  801c33:	89 c2                	mov    %eax,%edx
  801c35:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801c38:	89 d0                	mov    %edx,%eax
  801c3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c3d:	c9                   	leave  
  801c3e:	c3                   	ret    

00801c3f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c3f:	55                   	push   %ebp
  801c40:	89 e5                	mov    %esp,%ebp
  801c42:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c45:	6a 00                	push   $0x0
  801c47:	ff 75 10             	pushl  0x10(%ebp)
  801c4a:	ff 75 0c             	pushl  0xc(%ebp)
  801c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c50:	ff 70 0c             	pushl  0xc(%eax)
  801c53:	e8 78 03 00 00       	call   801fd0 <nsipc_send>
}
  801c58:	c9                   	leave  
  801c59:	c3                   	ret    

00801c5a <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c60:	6a 00                	push   $0x0
  801c62:	ff 75 10             	pushl  0x10(%ebp)
  801c65:	ff 75 0c             	pushl  0xc(%ebp)
  801c68:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6b:	ff 70 0c             	pushl  0xc(%eax)
  801c6e:	e8 f1 02 00 00       	call   801f64 <nsipc_recv>
}
  801c73:	c9                   	leave  
  801c74:	c3                   	ret    

00801c75 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c7b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c7e:	52                   	push   %edx
  801c7f:	50                   	push   %eax
  801c80:	e8 02 f2 ff ff       	call   800e87 <fd_lookup>
  801c85:	83 c4 10             	add    $0x10,%esp
  801c88:	85 c0                	test   %eax,%eax
  801c8a:	78 17                	js     801ca3 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8f:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801c95:	39 08                	cmp    %ecx,(%eax)
  801c97:	75 05                	jne    801c9e <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c99:	8b 40 0c             	mov    0xc(%eax),%eax
  801c9c:	eb 05                	jmp    801ca3 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801c9e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801ca3:	c9                   	leave  
  801ca4:	c3                   	ret    

00801ca5 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801ca5:	55                   	push   %ebp
  801ca6:	89 e5                	mov    %esp,%ebp
  801ca8:	56                   	push   %esi
  801ca9:	53                   	push   %ebx
  801caa:	83 ec 1c             	sub    $0x1c,%esp
  801cad:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801caf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb2:	50                   	push   %eax
  801cb3:	e8 80 f1 ff ff       	call   800e38 <fd_alloc>
  801cb8:	89 c3                	mov    %eax,%ebx
  801cba:	83 c4 10             	add    $0x10,%esp
  801cbd:	85 c0                	test   %eax,%eax
  801cbf:	78 1b                	js     801cdc <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801cc1:	83 ec 04             	sub    $0x4,%esp
  801cc4:	68 07 04 00 00       	push   $0x407
  801cc9:	ff 75 f4             	pushl  -0xc(%ebp)
  801ccc:	6a 00                	push   $0x0
  801cce:	e8 69 ee ff ff       	call   800b3c <sys_page_alloc>
  801cd3:	89 c3                	mov    %eax,%ebx
  801cd5:	83 c4 10             	add    $0x10,%esp
  801cd8:	85 c0                	test   %eax,%eax
  801cda:	79 10                	jns    801cec <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801cdc:	83 ec 0c             	sub    $0xc,%esp
  801cdf:	56                   	push   %esi
  801ce0:	e8 0e 02 00 00       	call   801ef3 <nsipc_close>
		return r;
  801ce5:	83 c4 10             	add    $0x10,%esp
  801ce8:	89 d8                	mov    %ebx,%eax
  801cea:	eb 24                	jmp    801d10 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801cec:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf5:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d01:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d04:	83 ec 0c             	sub    $0xc,%esp
  801d07:	50                   	push   %eax
  801d08:	e8 04 f1 ff ff       	call   800e11 <fd2num>
  801d0d:	83 c4 10             	add    $0x10,%esp
}
  801d10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d13:	5b                   	pop    %ebx
  801d14:	5e                   	pop    %esi
  801d15:	5d                   	pop    %ebp
  801d16:	c3                   	ret    

00801d17 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d17:	55                   	push   %ebp
  801d18:	89 e5                	mov    %esp,%ebp
  801d1a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d20:	e8 50 ff ff ff       	call   801c75 <fd2sockid>
		return r;
  801d25:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d27:	85 c0                	test   %eax,%eax
  801d29:	78 1f                	js     801d4a <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d2b:	83 ec 04             	sub    $0x4,%esp
  801d2e:	ff 75 10             	pushl  0x10(%ebp)
  801d31:	ff 75 0c             	pushl  0xc(%ebp)
  801d34:	50                   	push   %eax
  801d35:	e8 12 01 00 00       	call   801e4c <nsipc_accept>
  801d3a:	83 c4 10             	add    $0x10,%esp
		return r;
  801d3d:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d3f:	85 c0                	test   %eax,%eax
  801d41:	78 07                	js     801d4a <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801d43:	e8 5d ff ff ff       	call   801ca5 <alloc_sockfd>
  801d48:	89 c1                	mov    %eax,%ecx
}
  801d4a:	89 c8                	mov    %ecx,%eax
  801d4c:	c9                   	leave  
  801d4d:	c3                   	ret    

00801d4e <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d54:	8b 45 08             	mov    0x8(%ebp),%eax
  801d57:	e8 19 ff ff ff       	call   801c75 <fd2sockid>
  801d5c:	85 c0                	test   %eax,%eax
  801d5e:	78 12                	js     801d72 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801d60:	83 ec 04             	sub    $0x4,%esp
  801d63:	ff 75 10             	pushl  0x10(%ebp)
  801d66:	ff 75 0c             	pushl  0xc(%ebp)
  801d69:	50                   	push   %eax
  801d6a:	e8 2d 01 00 00       	call   801e9c <nsipc_bind>
  801d6f:	83 c4 10             	add    $0x10,%esp
}
  801d72:	c9                   	leave  
  801d73:	c3                   	ret    

00801d74 <shutdown>:

int
shutdown(int s, int how)
{
  801d74:	55                   	push   %ebp
  801d75:	89 e5                	mov    %esp,%ebp
  801d77:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7d:	e8 f3 fe ff ff       	call   801c75 <fd2sockid>
  801d82:	85 c0                	test   %eax,%eax
  801d84:	78 0f                	js     801d95 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801d86:	83 ec 08             	sub    $0x8,%esp
  801d89:	ff 75 0c             	pushl  0xc(%ebp)
  801d8c:	50                   	push   %eax
  801d8d:	e8 3f 01 00 00       	call   801ed1 <nsipc_shutdown>
  801d92:	83 c4 10             	add    $0x10,%esp
}
  801d95:	c9                   	leave  
  801d96:	c3                   	ret    

00801d97 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801da0:	e8 d0 fe ff ff       	call   801c75 <fd2sockid>
  801da5:	85 c0                	test   %eax,%eax
  801da7:	78 12                	js     801dbb <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801da9:	83 ec 04             	sub    $0x4,%esp
  801dac:	ff 75 10             	pushl  0x10(%ebp)
  801daf:	ff 75 0c             	pushl  0xc(%ebp)
  801db2:	50                   	push   %eax
  801db3:	e8 55 01 00 00       	call   801f0d <nsipc_connect>
  801db8:	83 c4 10             	add    $0x10,%esp
}
  801dbb:	c9                   	leave  
  801dbc:	c3                   	ret    

00801dbd <listen>:

int
listen(int s, int backlog)
{
  801dbd:	55                   	push   %ebp
  801dbe:	89 e5                	mov    %esp,%ebp
  801dc0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dc3:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc6:	e8 aa fe ff ff       	call   801c75 <fd2sockid>
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	78 0f                	js     801dde <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801dcf:	83 ec 08             	sub    $0x8,%esp
  801dd2:	ff 75 0c             	pushl  0xc(%ebp)
  801dd5:	50                   	push   %eax
  801dd6:	e8 67 01 00 00       	call   801f42 <nsipc_listen>
  801ddb:	83 c4 10             	add    $0x10,%esp
}
  801dde:	c9                   	leave  
  801ddf:	c3                   	ret    

00801de0 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801de6:	ff 75 10             	pushl  0x10(%ebp)
  801de9:	ff 75 0c             	pushl  0xc(%ebp)
  801dec:	ff 75 08             	pushl  0x8(%ebp)
  801def:	e8 3a 02 00 00       	call   80202e <nsipc_socket>
  801df4:	83 c4 10             	add    $0x10,%esp
  801df7:	85 c0                	test   %eax,%eax
  801df9:	78 05                	js     801e00 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801dfb:	e8 a5 fe ff ff       	call   801ca5 <alloc_sockfd>
}
  801e00:	c9                   	leave  
  801e01:	c3                   	ret    

00801e02 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	53                   	push   %ebx
  801e06:	83 ec 04             	sub    $0x4,%esp
  801e09:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e0b:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801e12:	75 12                	jne    801e26 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e14:	83 ec 0c             	sub    $0xc,%esp
  801e17:	6a 02                	push   $0x2
  801e19:	e8 d6 07 00 00       	call   8025f4 <ipc_find_env>
  801e1e:	a3 04 40 80 00       	mov    %eax,0x804004
  801e23:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e26:	6a 07                	push   $0x7
  801e28:	68 00 60 80 00       	push   $0x806000
  801e2d:	53                   	push   %ebx
  801e2e:	ff 35 04 40 80 00    	pushl  0x804004
  801e34:	e8 67 07 00 00       	call   8025a0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801e39:	83 c4 0c             	add    $0xc,%esp
  801e3c:	6a 00                	push   $0x0
  801e3e:	6a 00                	push   $0x0
  801e40:	6a 00                	push   $0x0
  801e42:	e8 f0 06 00 00       	call   802537 <ipc_recv>
}
  801e47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e4a:	c9                   	leave  
  801e4b:	c3                   	ret    

00801e4c <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	56                   	push   %esi
  801e50:	53                   	push   %ebx
  801e51:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801e54:	8b 45 08             	mov    0x8(%ebp),%eax
  801e57:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e5c:	8b 06                	mov    (%esi),%eax
  801e5e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e63:	b8 01 00 00 00       	mov    $0x1,%eax
  801e68:	e8 95 ff ff ff       	call   801e02 <nsipc>
  801e6d:	89 c3                	mov    %eax,%ebx
  801e6f:	85 c0                	test   %eax,%eax
  801e71:	78 20                	js     801e93 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e73:	83 ec 04             	sub    $0x4,%esp
  801e76:	ff 35 10 60 80 00    	pushl  0x806010
  801e7c:	68 00 60 80 00       	push   $0x806000
  801e81:	ff 75 0c             	pushl  0xc(%ebp)
  801e84:	e8 42 ea ff ff       	call   8008cb <memmove>
		*addrlen = ret->ret_addrlen;
  801e89:	a1 10 60 80 00       	mov    0x806010,%eax
  801e8e:	89 06                	mov    %eax,(%esi)
  801e90:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801e93:	89 d8                	mov    %ebx,%eax
  801e95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e98:	5b                   	pop    %ebx
  801e99:	5e                   	pop    %esi
  801e9a:	5d                   	pop    %ebp
  801e9b:	c3                   	ret    

00801e9c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	53                   	push   %ebx
  801ea0:	83 ec 08             	sub    $0x8,%esp
  801ea3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea9:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801eae:	53                   	push   %ebx
  801eaf:	ff 75 0c             	pushl  0xc(%ebp)
  801eb2:	68 04 60 80 00       	push   $0x806004
  801eb7:	e8 0f ea ff ff       	call   8008cb <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ebc:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801ec2:	b8 02 00 00 00       	mov    $0x2,%eax
  801ec7:	e8 36 ff ff ff       	call   801e02 <nsipc>
}
  801ecc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ecf:	c9                   	leave  
  801ed0:	c3                   	ret    

00801ed1 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801ed1:	55                   	push   %ebp
  801ed2:	89 e5                	mov    %esp,%ebp
  801ed4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ed7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eda:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801edf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee2:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801ee7:	b8 03 00 00 00       	mov    $0x3,%eax
  801eec:	e8 11 ff ff ff       	call   801e02 <nsipc>
}
  801ef1:	c9                   	leave  
  801ef2:	c3                   	ret    

00801ef3 <nsipc_close>:

int
nsipc_close(int s)
{
  801ef3:	55                   	push   %ebp
  801ef4:	89 e5                	mov    %esp,%ebp
  801ef6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ef9:	8b 45 08             	mov    0x8(%ebp),%eax
  801efc:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801f01:	b8 04 00 00 00       	mov    $0x4,%eax
  801f06:	e8 f7 fe ff ff       	call   801e02 <nsipc>
}
  801f0b:	c9                   	leave  
  801f0c:	c3                   	ret    

00801f0d <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f0d:	55                   	push   %ebp
  801f0e:	89 e5                	mov    %esp,%ebp
  801f10:	53                   	push   %ebx
  801f11:	83 ec 08             	sub    $0x8,%esp
  801f14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f17:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1a:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f1f:	53                   	push   %ebx
  801f20:	ff 75 0c             	pushl  0xc(%ebp)
  801f23:	68 04 60 80 00       	push   $0x806004
  801f28:	e8 9e e9 ff ff       	call   8008cb <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f2d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801f33:	b8 05 00 00 00       	mov    $0x5,%eax
  801f38:	e8 c5 fe ff ff       	call   801e02 <nsipc>
}
  801f3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f40:	c9                   	leave  
  801f41:	c3                   	ret    

00801f42 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801f42:	55                   	push   %ebp
  801f43:	89 e5                	mov    %esp,%ebp
  801f45:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f48:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801f50:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f53:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801f58:	b8 06 00 00 00       	mov    $0x6,%eax
  801f5d:	e8 a0 fe ff ff       	call   801e02 <nsipc>
}
  801f62:	c9                   	leave  
  801f63:	c3                   	ret    

00801f64 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f64:	55                   	push   %ebp
  801f65:	89 e5                	mov    %esp,%ebp
  801f67:	56                   	push   %esi
  801f68:	53                   	push   %ebx
  801f69:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801f74:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801f7a:	8b 45 14             	mov    0x14(%ebp),%eax
  801f7d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f82:	b8 07 00 00 00       	mov    $0x7,%eax
  801f87:	e8 76 fe ff ff       	call   801e02 <nsipc>
  801f8c:	89 c3                	mov    %eax,%ebx
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	78 35                	js     801fc7 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801f92:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801f97:	7f 04                	jg     801f9d <nsipc_recv+0x39>
  801f99:	39 c6                	cmp    %eax,%esi
  801f9b:	7d 16                	jge    801fb3 <nsipc_recv+0x4f>
  801f9d:	68 34 2e 80 00       	push   $0x802e34
  801fa2:	68 48 2d 80 00       	push   $0x802d48
  801fa7:	6a 62                	push   $0x62
  801fa9:	68 49 2e 80 00       	push   $0x802e49
  801fae:	e8 28 e1 ff ff       	call   8000db <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801fb3:	83 ec 04             	sub    $0x4,%esp
  801fb6:	50                   	push   %eax
  801fb7:	68 00 60 80 00       	push   $0x806000
  801fbc:	ff 75 0c             	pushl  0xc(%ebp)
  801fbf:	e8 07 e9 ff ff       	call   8008cb <memmove>
  801fc4:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801fc7:	89 d8                	mov    %ebx,%eax
  801fc9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fcc:	5b                   	pop    %ebx
  801fcd:	5e                   	pop    %esi
  801fce:	5d                   	pop    %ebp
  801fcf:	c3                   	ret    

00801fd0 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801fd0:	55                   	push   %ebp
  801fd1:	89 e5                	mov    %esp,%ebp
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 04             	sub    $0x4,%esp
  801fd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801fda:	8b 45 08             	mov    0x8(%ebp),%eax
  801fdd:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801fe2:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801fe8:	7e 16                	jle    802000 <nsipc_send+0x30>
  801fea:	68 55 2e 80 00       	push   $0x802e55
  801fef:	68 48 2d 80 00       	push   $0x802d48
  801ff4:	6a 6d                	push   $0x6d
  801ff6:	68 49 2e 80 00       	push   $0x802e49
  801ffb:	e8 db e0 ff ff       	call   8000db <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802000:	83 ec 04             	sub    $0x4,%esp
  802003:	53                   	push   %ebx
  802004:	ff 75 0c             	pushl  0xc(%ebp)
  802007:	68 0c 60 80 00       	push   $0x80600c
  80200c:	e8 ba e8 ff ff       	call   8008cb <memmove>
	nsipcbuf.send.req_size = size;
  802011:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  802017:	8b 45 14             	mov    0x14(%ebp),%eax
  80201a:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80201f:	b8 08 00 00 00       	mov    $0x8,%eax
  802024:	e8 d9 fd ff ff       	call   801e02 <nsipc>
}
  802029:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80202c:	c9                   	leave  
  80202d:	c3                   	ret    

0080202e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80202e:	55                   	push   %ebp
  80202f:	89 e5                	mov    %esp,%ebp
  802031:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802034:	8b 45 08             	mov    0x8(%ebp),%eax
  802037:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80203c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80203f:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802044:	8b 45 10             	mov    0x10(%ebp),%eax
  802047:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80204c:	b8 09 00 00 00       	mov    $0x9,%eax
  802051:	e8 ac fd ff ff       	call   801e02 <nsipc>
}
  802056:	c9                   	leave  
  802057:	c3                   	ret    

00802058 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802058:	55                   	push   %ebp
  802059:	89 e5                	mov    %esp,%ebp
  80205b:	56                   	push   %esi
  80205c:	53                   	push   %ebx
  80205d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802060:	83 ec 0c             	sub    $0xc,%esp
  802063:	ff 75 08             	pushl  0x8(%ebp)
  802066:	e8 b6 ed ff ff       	call   800e21 <fd2data>
  80206b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80206d:	83 c4 08             	add    $0x8,%esp
  802070:	68 61 2e 80 00       	push   $0x802e61
  802075:	53                   	push   %ebx
  802076:	e8 be e6 ff ff       	call   800739 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80207b:	8b 46 04             	mov    0x4(%esi),%eax
  80207e:	2b 06                	sub    (%esi),%eax
  802080:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802086:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80208d:	00 00 00 
	stat->st_dev = &devpipe;
  802090:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  802097:	30 80 00 
	return 0;
}
  80209a:	b8 00 00 00 00       	mov    $0x0,%eax
  80209f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020a2:	5b                   	pop    %ebx
  8020a3:	5e                   	pop    %esi
  8020a4:	5d                   	pop    %ebp
  8020a5:	c3                   	ret    

008020a6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8020a6:	55                   	push   %ebp
  8020a7:	89 e5                	mov    %esp,%ebp
  8020a9:	53                   	push   %ebx
  8020aa:	83 ec 0c             	sub    $0xc,%esp
  8020ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8020b0:	53                   	push   %ebx
  8020b1:	6a 00                	push   $0x0
  8020b3:	e8 09 eb ff ff       	call   800bc1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8020b8:	89 1c 24             	mov    %ebx,(%esp)
  8020bb:	e8 61 ed ff ff       	call   800e21 <fd2data>
  8020c0:	83 c4 08             	add    $0x8,%esp
  8020c3:	50                   	push   %eax
  8020c4:	6a 00                	push   $0x0
  8020c6:	e8 f6 ea ff ff       	call   800bc1 <sys_page_unmap>
}
  8020cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020ce:	c9                   	leave  
  8020cf:	c3                   	ret    

008020d0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8020d0:	55                   	push   %ebp
  8020d1:	89 e5                	mov    %esp,%ebp
  8020d3:	57                   	push   %edi
  8020d4:	56                   	push   %esi
  8020d5:	53                   	push   %ebx
  8020d6:	83 ec 1c             	sub    $0x1c,%esp
  8020d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8020dc:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8020de:	a1 08 40 80 00       	mov    0x804008,%eax
  8020e3:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8020e6:	83 ec 0c             	sub    $0xc,%esp
  8020e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8020ec:	e8 3c 05 00 00       	call   80262d <pageref>
  8020f1:	89 c3                	mov    %eax,%ebx
  8020f3:	89 3c 24             	mov    %edi,(%esp)
  8020f6:	e8 32 05 00 00       	call   80262d <pageref>
  8020fb:	83 c4 10             	add    $0x10,%esp
  8020fe:	39 c3                	cmp    %eax,%ebx
  802100:	0f 94 c1             	sete   %cl
  802103:	0f b6 c9             	movzbl %cl,%ecx
  802106:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802109:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80210f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802112:	39 ce                	cmp    %ecx,%esi
  802114:	74 1b                	je     802131 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802116:	39 c3                	cmp    %eax,%ebx
  802118:	75 c4                	jne    8020de <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80211a:	8b 42 58             	mov    0x58(%edx),%eax
  80211d:	ff 75 e4             	pushl  -0x1c(%ebp)
  802120:	50                   	push   %eax
  802121:	56                   	push   %esi
  802122:	68 68 2e 80 00       	push   $0x802e68
  802127:	e8 88 e0 ff ff       	call   8001b4 <cprintf>
  80212c:	83 c4 10             	add    $0x10,%esp
  80212f:	eb ad                	jmp    8020de <_pipeisclosed+0xe>
	}
}
  802131:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802134:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802137:	5b                   	pop    %ebx
  802138:	5e                   	pop    %esi
  802139:	5f                   	pop    %edi
  80213a:	5d                   	pop    %ebp
  80213b:	c3                   	ret    

0080213c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80213c:	55                   	push   %ebp
  80213d:	89 e5                	mov    %esp,%ebp
  80213f:	57                   	push   %edi
  802140:	56                   	push   %esi
  802141:	53                   	push   %ebx
  802142:	83 ec 28             	sub    $0x28,%esp
  802145:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802148:	56                   	push   %esi
  802149:	e8 d3 ec ff ff       	call   800e21 <fd2data>
  80214e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802150:	83 c4 10             	add    $0x10,%esp
  802153:	bf 00 00 00 00       	mov    $0x0,%edi
  802158:	eb 4b                	jmp    8021a5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80215a:	89 da                	mov    %ebx,%edx
  80215c:	89 f0                	mov    %esi,%eax
  80215e:	e8 6d ff ff ff       	call   8020d0 <_pipeisclosed>
  802163:	85 c0                	test   %eax,%eax
  802165:	75 48                	jne    8021af <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802167:	e8 b1 e9 ff ff       	call   800b1d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80216c:	8b 43 04             	mov    0x4(%ebx),%eax
  80216f:	8b 0b                	mov    (%ebx),%ecx
  802171:	8d 51 20             	lea    0x20(%ecx),%edx
  802174:	39 d0                	cmp    %edx,%eax
  802176:	73 e2                	jae    80215a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802178:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80217b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80217f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802182:	89 c2                	mov    %eax,%edx
  802184:	c1 fa 1f             	sar    $0x1f,%edx
  802187:	89 d1                	mov    %edx,%ecx
  802189:	c1 e9 1b             	shr    $0x1b,%ecx
  80218c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80218f:	83 e2 1f             	and    $0x1f,%edx
  802192:	29 ca                	sub    %ecx,%edx
  802194:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802198:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80219c:	83 c0 01             	add    $0x1,%eax
  80219f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021a2:	83 c7 01             	add    $0x1,%edi
  8021a5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8021a8:	75 c2                	jne    80216c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8021aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8021ad:	eb 05                	jmp    8021b4 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021af:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8021b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021b7:	5b                   	pop    %ebx
  8021b8:	5e                   	pop    %esi
  8021b9:	5f                   	pop    %edi
  8021ba:	5d                   	pop    %ebp
  8021bb:	c3                   	ret    

008021bc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021bc:	55                   	push   %ebp
  8021bd:	89 e5                	mov    %esp,%ebp
  8021bf:	57                   	push   %edi
  8021c0:	56                   	push   %esi
  8021c1:	53                   	push   %ebx
  8021c2:	83 ec 18             	sub    $0x18,%esp
  8021c5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8021c8:	57                   	push   %edi
  8021c9:	e8 53 ec ff ff       	call   800e21 <fd2data>
  8021ce:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021d0:	83 c4 10             	add    $0x10,%esp
  8021d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021d8:	eb 3d                	jmp    802217 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8021da:	85 db                	test   %ebx,%ebx
  8021dc:	74 04                	je     8021e2 <devpipe_read+0x26>
				return i;
  8021de:	89 d8                	mov    %ebx,%eax
  8021e0:	eb 44                	jmp    802226 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8021e2:	89 f2                	mov    %esi,%edx
  8021e4:	89 f8                	mov    %edi,%eax
  8021e6:	e8 e5 fe ff ff       	call   8020d0 <_pipeisclosed>
  8021eb:	85 c0                	test   %eax,%eax
  8021ed:	75 32                	jne    802221 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8021ef:	e8 29 e9 ff ff       	call   800b1d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8021f4:	8b 06                	mov    (%esi),%eax
  8021f6:	3b 46 04             	cmp    0x4(%esi),%eax
  8021f9:	74 df                	je     8021da <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021fb:	99                   	cltd   
  8021fc:	c1 ea 1b             	shr    $0x1b,%edx
  8021ff:	01 d0                	add    %edx,%eax
  802201:	83 e0 1f             	and    $0x1f,%eax
  802204:	29 d0                	sub    %edx,%eax
  802206:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80220b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80220e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802211:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802214:	83 c3 01             	add    $0x1,%ebx
  802217:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80221a:	75 d8                	jne    8021f4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80221c:	8b 45 10             	mov    0x10(%ebp),%eax
  80221f:	eb 05                	jmp    802226 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802221:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802226:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802229:	5b                   	pop    %ebx
  80222a:	5e                   	pop    %esi
  80222b:	5f                   	pop    %edi
  80222c:	5d                   	pop    %ebp
  80222d:	c3                   	ret    

0080222e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80222e:	55                   	push   %ebp
  80222f:	89 e5                	mov    %esp,%ebp
  802231:	56                   	push   %esi
  802232:	53                   	push   %ebx
  802233:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802236:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802239:	50                   	push   %eax
  80223a:	e8 f9 eb ff ff       	call   800e38 <fd_alloc>
  80223f:	83 c4 10             	add    $0x10,%esp
  802242:	89 c2                	mov    %eax,%edx
  802244:	85 c0                	test   %eax,%eax
  802246:	0f 88 2c 01 00 00    	js     802378 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80224c:	83 ec 04             	sub    $0x4,%esp
  80224f:	68 07 04 00 00       	push   $0x407
  802254:	ff 75 f4             	pushl  -0xc(%ebp)
  802257:	6a 00                	push   $0x0
  802259:	e8 de e8 ff ff       	call   800b3c <sys_page_alloc>
  80225e:	83 c4 10             	add    $0x10,%esp
  802261:	89 c2                	mov    %eax,%edx
  802263:	85 c0                	test   %eax,%eax
  802265:	0f 88 0d 01 00 00    	js     802378 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80226b:	83 ec 0c             	sub    $0xc,%esp
  80226e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802271:	50                   	push   %eax
  802272:	e8 c1 eb ff ff       	call   800e38 <fd_alloc>
  802277:	89 c3                	mov    %eax,%ebx
  802279:	83 c4 10             	add    $0x10,%esp
  80227c:	85 c0                	test   %eax,%eax
  80227e:	0f 88 e2 00 00 00    	js     802366 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802284:	83 ec 04             	sub    $0x4,%esp
  802287:	68 07 04 00 00       	push   $0x407
  80228c:	ff 75 f0             	pushl  -0x10(%ebp)
  80228f:	6a 00                	push   $0x0
  802291:	e8 a6 e8 ff ff       	call   800b3c <sys_page_alloc>
  802296:	89 c3                	mov    %eax,%ebx
  802298:	83 c4 10             	add    $0x10,%esp
  80229b:	85 c0                	test   %eax,%eax
  80229d:	0f 88 c3 00 00 00    	js     802366 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8022a3:	83 ec 0c             	sub    $0xc,%esp
  8022a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8022a9:	e8 73 eb ff ff       	call   800e21 <fd2data>
  8022ae:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022b0:	83 c4 0c             	add    $0xc,%esp
  8022b3:	68 07 04 00 00       	push   $0x407
  8022b8:	50                   	push   %eax
  8022b9:	6a 00                	push   $0x0
  8022bb:	e8 7c e8 ff ff       	call   800b3c <sys_page_alloc>
  8022c0:	89 c3                	mov    %eax,%ebx
  8022c2:	83 c4 10             	add    $0x10,%esp
  8022c5:	85 c0                	test   %eax,%eax
  8022c7:	0f 88 89 00 00 00    	js     802356 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022cd:	83 ec 0c             	sub    $0xc,%esp
  8022d0:	ff 75 f0             	pushl  -0x10(%ebp)
  8022d3:	e8 49 eb ff ff       	call   800e21 <fd2data>
  8022d8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8022df:	50                   	push   %eax
  8022e0:	6a 00                	push   $0x0
  8022e2:	56                   	push   %esi
  8022e3:	6a 00                	push   $0x0
  8022e5:	e8 95 e8 ff ff       	call   800b7f <sys_page_map>
  8022ea:	89 c3                	mov    %eax,%ebx
  8022ec:	83 c4 20             	add    $0x20,%esp
  8022ef:	85 c0                	test   %eax,%eax
  8022f1:	78 55                	js     802348 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8022f3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022fc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8022fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802301:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802308:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80230e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802311:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802313:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802316:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80231d:	83 ec 0c             	sub    $0xc,%esp
  802320:	ff 75 f4             	pushl  -0xc(%ebp)
  802323:	e8 e9 ea ff ff       	call   800e11 <fd2num>
  802328:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80232b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80232d:	83 c4 04             	add    $0x4,%esp
  802330:	ff 75 f0             	pushl  -0x10(%ebp)
  802333:	e8 d9 ea ff ff       	call   800e11 <fd2num>
  802338:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80233b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80233e:	83 c4 10             	add    $0x10,%esp
  802341:	ba 00 00 00 00       	mov    $0x0,%edx
  802346:	eb 30                	jmp    802378 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802348:	83 ec 08             	sub    $0x8,%esp
  80234b:	56                   	push   %esi
  80234c:	6a 00                	push   $0x0
  80234e:	e8 6e e8 ff ff       	call   800bc1 <sys_page_unmap>
  802353:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802356:	83 ec 08             	sub    $0x8,%esp
  802359:	ff 75 f0             	pushl  -0x10(%ebp)
  80235c:	6a 00                	push   $0x0
  80235e:	e8 5e e8 ff ff       	call   800bc1 <sys_page_unmap>
  802363:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802366:	83 ec 08             	sub    $0x8,%esp
  802369:	ff 75 f4             	pushl  -0xc(%ebp)
  80236c:	6a 00                	push   $0x0
  80236e:	e8 4e e8 ff ff       	call   800bc1 <sys_page_unmap>
  802373:	83 c4 10             	add    $0x10,%esp
  802376:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802378:	89 d0                	mov    %edx,%eax
  80237a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80237d:	5b                   	pop    %ebx
  80237e:	5e                   	pop    %esi
  80237f:	5d                   	pop    %ebp
  802380:	c3                   	ret    

00802381 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802381:	55                   	push   %ebp
  802382:	89 e5                	mov    %esp,%ebp
  802384:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802387:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80238a:	50                   	push   %eax
  80238b:	ff 75 08             	pushl  0x8(%ebp)
  80238e:	e8 f4 ea ff ff       	call   800e87 <fd_lookup>
  802393:	83 c4 10             	add    $0x10,%esp
  802396:	85 c0                	test   %eax,%eax
  802398:	78 18                	js     8023b2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80239a:	83 ec 0c             	sub    $0xc,%esp
  80239d:	ff 75 f4             	pushl  -0xc(%ebp)
  8023a0:	e8 7c ea ff ff       	call   800e21 <fd2data>
	return _pipeisclosed(fd, p);
  8023a5:	89 c2                	mov    %eax,%edx
  8023a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023aa:	e8 21 fd ff ff       	call   8020d0 <_pipeisclosed>
  8023af:	83 c4 10             	add    $0x10,%esp
}
  8023b2:	c9                   	leave  
  8023b3:	c3                   	ret    

008023b4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8023b4:	55                   	push   %ebp
  8023b5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8023b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8023bc:	5d                   	pop    %ebp
  8023bd:	c3                   	ret    

008023be <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8023be:	55                   	push   %ebp
  8023bf:	89 e5                	mov    %esp,%ebp
  8023c1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8023c4:	68 80 2e 80 00       	push   $0x802e80
  8023c9:	ff 75 0c             	pushl  0xc(%ebp)
  8023cc:	e8 68 e3 ff ff       	call   800739 <strcpy>
	return 0;
}
  8023d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8023d6:	c9                   	leave  
  8023d7:	c3                   	ret    

008023d8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023d8:	55                   	push   %ebp
  8023d9:	89 e5                	mov    %esp,%ebp
  8023db:	57                   	push   %edi
  8023dc:	56                   	push   %esi
  8023dd:	53                   	push   %ebx
  8023de:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023e4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023e9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023ef:	eb 2d                	jmp    80241e <devcons_write+0x46>
		m = n - tot;
  8023f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023f4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8023f6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8023f9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8023fe:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802401:	83 ec 04             	sub    $0x4,%esp
  802404:	53                   	push   %ebx
  802405:	03 45 0c             	add    0xc(%ebp),%eax
  802408:	50                   	push   %eax
  802409:	57                   	push   %edi
  80240a:	e8 bc e4 ff ff       	call   8008cb <memmove>
		sys_cputs(buf, m);
  80240f:	83 c4 08             	add    $0x8,%esp
  802412:	53                   	push   %ebx
  802413:	57                   	push   %edi
  802414:	e8 67 e6 ff ff       	call   800a80 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802419:	01 de                	add    %ebx,%esi
  80241b:	83 c4 10             	add    $0x10,%esp
  80241e:	89 f0                	mov    %esi,%eax
  802420:	3b 75 10             	cmp    0x10(%ebp),%esi
  802423:	72 cc                	jb     8023f1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802425:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802428:	5b                   	pop    %ebx
  802429:	5e                   	pop    %esi
  80242a:	5f                   	pop    %edi
  80242b:	5d                   	pop    %ebp
  80242c:	c3                   	ret    

0080242d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80242d:	55                   	push   %ebp
  80242e:	89 e5                	mov    %esp,%ebp
  802430:	83 ec 08             	sub    $0x8,%esp
  802433:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802438:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80243c:	74 2a                	je     802468 <devcons_read+0x3b>
  80243e:	eb 05                	jmp    802445 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802440:	e8 d8 e6 ff ff       	call   800b1d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802445:	e8 54 e6 ff ff       	call   800a9e <sys_cgetc>
  80244a:	85 c0                	test   %eax,%eax
  80244c:	74 f2                	je     802440 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80244e:	85 c0                	test   %eax,%eax
  802450:	78 16                	js     802468 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802452:	83 f8 04             	cmp    $0x4,%eax
  802455:	74 0c                	je     802463 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802457:	8b 55 0c             	mov    0xc(%ebp),%edx
  80245a:	88 02                	mov    %al,(%edx)
	return 1;
  80245c:	b8 01 00 00 00       	mov    $0x1,%eax
  802461:	eb 05                	jmp    802468 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802463:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802468:	c9                   	leave  
  802469:	c3                   	ret    

0080246a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80246a:	55                   	push   %ebp
  80246b:	89 e5                	mov    %esp,%ebp
  80246d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802470:	8b 45 08             	mov    0x8(%ebp),%eax
  802473:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802476:	6a 01                	push   $0x1
  802478:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80247b:	50                   	push   %eax
  80247c:	e8 ff e5 ff ff       	call   800a80 <sys_cputs>
}
  802481:	83 c4 10             	add    $0x10,%esp
  802484:	c9                   	leave  
  802485:	c3                   	ret    

00802486 <getchar>:

int
getchar(void)
{
  802486:	55                   	push   %ebp
  802487:	89 e5                	mov    %esp,%ebp
  802489:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80248c:	6a 01                	push   $0x1
  80248e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802491:	50                   	push   %eax
  802492:	6a 00                	push   $0x0
  802494:	e8 54 ec ff ff       	call   8010ed <read>
	if (r < 0)
  802499:	83 c4 10             	add    $0x10,%esp
  80249c:	85 c0                	test   %eax,%eax
  80249e:	78 0f                	js     8024af <getchar+0x29>
		return r;
	if (r < 1)
  8024a0:	85 c0                	test   %eax,%eax
  8024a2:	7e 06                	jle    8024aa <getchar+0x24>
		return -E_EOF;
	return c;
  8024a4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8024a8:	eb 05                	jmp    8024af <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8024aa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8024af:	c9                   	leave  
  8024b0:	c3                   	ret    

008024b1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8024b1:	55                   	push   %ebp
  8024b2:	89 e5                	mov    %esp,%ebp
  8024b4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024ba:	50                   	push   %eax
  8024bb:	ff 75 08             	pushl  0x8(%ebp)
  8024be:	e8 c4 e9 ff ff       	call   800e87 <fd_lookup>
  8024c3:	83 c4 10             	add    $0x10,%esp
  8024c6:	85 c0                	test   %eax,%eax
  8024c8:	78 11                	js     8024db <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8024ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024cd:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024d3:	39 10                	cmp    %edx,(%eax)
  8024d5:	0f 94 c0             	sete   %al
  8024d8:	0f b6 c0             	movzbl %al,%eax
}
  8024db:	c9                   	leave  
  8024dc:	c3                   	ret    

008024dd <opencons>:

int
opencons(void)
{
  8024dd:	55                   	push   %ebp
  8024de:	89 e5                	mov    %esp,%ebp
  8024e0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024e6:	50                   	push   %eax
  8024e7:	e8 4c e9 ff ff       	call   800e38 <fd_alloc>
  8024ec:	83 c4 10             	add    $0x10,%esp
		return r;
  8024ef:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024f1:	85 c0                	test   %eax,%eax
  8024f3:	78 3e                	js     802533 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024f5:	83 ec 04             	sub    $0x4,%esp
  8024f8:	68 07 04 00 00       	push   $0x407
  8024fd:	ff 75 f4             	pushl  -0xc(%ebp)
  802500:	6a 00                	push   $0x0
  802502:	e8 35 e6 ff ff       	call   800b3c <sys_page_alloc>
  802507:	83 c4 10             	add    $0x10,%esp
		return r;
  80250a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80250c:	85 c0                	test   %eax,%eax
  80250e:	78 23                	js     802533 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802510:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802516:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802519:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80251b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80251e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802525:	83 ec 0c             	sub    $0xc,%esp
  802528:	50                   	push   %eax
  802529:	e8 e3 e8 ff ff       	call   800e11 <fd2num>
  80252e:	89 c2                	mov    %eax,%edx
  802530:	83 c4 10             	add    $0x10,%esp
}
  802533:	89 d0                	mov    %edx,%eax
  802535:	c9                   	leave  
  802536:	c3                   	ret    

00802537 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802537:	55                   	push   %ebp
  802538:	89 e5                	mov    %esp,%ebp
  80253a:	56                   	push   %esi
  80253b:	53                   	push   %ebx
  80253c:	8b 75 08             	mov    0x8(%ebp),%esi
  80253f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802542:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  802545:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802547:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  80254c:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  80254f:	83 ec 0c             	sub    $0xc,%esp
  802552:	50                   	push   %eax
  802553:	e8 94 e7 ff ff       	call   800cec <sys_ipc_recv>

	if (r < 0) {
  802558:	83 c4 10             	add    $0x10,%esp
  80255b:	85 c0                	test   %eax,%eax
  80255d:	79 16                	jns    802575 <ipc_recv+0x3e>
		if (from_env_store)
  80255f:	85 f6                	test   %esi,%esi
  802561:	74 06                	je     802569 <ipc_recv+0x32>
			*from_env_store = 0;
  802563:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  802569:	85 db                	test   %ebx,%ebx
  80256b:	74 2c                	je     802599 <ipc_recv+0x62>
			*perm_store = 0;
  80256d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802573:	eb 24                	jmp    802599 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  802575:	85 f6                	test   %esi,%esi
  802577:	74 0a                	je     802583 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  802579:	a1 08 40 80 00       	mov    0x804008,%eax
  80257e:	8b 40 74             	mov    0x74(%eax),%eax
  802581:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  802583:	85 db                	test   %ebx,%ebx
  802585:	74 0a                	je     802591 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  802587:	a1 08 40 80 00       	mov    0x804008,%eax
  80258c:	8b 40 78             	mov    0x78(%eax),%eax
  80258f:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  802591:	a1 08 40 80 00       	mov    0x804008,%eax
  802596:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  802599:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80259c:	5b                   	pop    %ebx
  80259d:	5e                   	pop    %esi
  80259e:	5d                   	pop    %ebp
  80259f:	c3                   	ret    

008025a0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8025a0:	55                   	push   %ebp
  8025a1:	89 e5                	mov    %esp,%ebp
  8025a3:	57                   	push   %edi
  8025a4:	56                   	push   %esi
  8025a5:	53                   	push   %ebx
  8025a6:	83 ec 0c             	sub    $0xc,%esp
  8025a9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8025ac:	8b 75 0c             	mov    0xc(%ebp),%esi
  8025af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8025b2:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8025b4:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8025b9:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8025bc:	ff 75 14             	pushl  0x14(%ebp)
  8025bf:	53                   	push   %ebx
  8025c0:	56                   	push   %esi
  8025c1:	57                   	push   %edi
  8025c2:	e8 02 e7 ff ff       	call   800cc9 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  8025c7:	83 c4 10             	add    $0x10,%esp
  8025ca:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8025cd:	75 07                	jne    8025d6 <ipc_send+0x36>
			sys_yield();
  8025cf:	e8 49 e5 ff ff       	call   800b1d <sys_yield>
  8025d4:	eb e6                	jmp    8025bc <ipc_send+0x1c>
		} else if (r < 0) {
  8025d6:	85 c0                	test   %eax,%eax
  8025d8:	79 12                	jns    8025ec <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  8025da:	50                   	push   %eax
  8025db:	68 8c 2e 80 00       	push   $0x802e8c
  8025e0:	6a 51                	push   $0x51
  8025e2:	68 99 2e 80 00       	push   $0x802e99
  8025e7:	e8 ef da ff ff       	call   8000db <_panic>
		}
	}
}
  8025ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025ef:	5b                   	pop    %ebx
  8025f0:	5e                   	pop    %esi
  8025f1:	5f                   	pop    %edi
  8025f2:	5d                   	pop    %ebp
  8025f3:	c3                   	ret    

008025f4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025f4:	55                   	push   %ebp
  8025f5:	89 e5                	mov    %esp,%ebp
  8025f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8025fa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8025ff:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802602:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802608:	8b 52 50             	mov    0x50(%edx),%edx
  80260b:	39 ca                	cmp    %ecx,%edx
  80260d:	75 0d                	jne    80261c <ipc_find_env+0x28>
			return envs[i].env_id;
  80260f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802612:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802617:	8b 40 48             	mov    0x48(%eax),%eax
  80261a:	eb 0f                	jmp    80262b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80261c:	83 c0 01             	add    $0x1,%eax
  80261f:	3d 00 04 00 00       	cmp    $0x400,%eax
  802624:	75 d9                	jne    8025ff <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802626:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80262b:	5d                   	pop    %ebp
  80262c:	c3                   	ret    

0080262d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80262d:	55                   	push   %ebp
  80262e:	89 e5                	mov    %esp,%ebp
  802630:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802633:	89 d0                	mov    %edx,%eax
  802635:	c1 e8 16             	shr    $0x16,%eax
  802638:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80263f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802644:	f6 c1 01             	test   $0x1,%cl
  802647:	74 1d                	je     802666 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802649:	c1 ea 0c             	shr    $0xc,%edx
  80264c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802653:	f6 c2 01             	test   $0x1,%dl
  802656:	74 0e                	je     802666 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802658:	c1 ea 0c             	shr    $0xc,%edx
  80265b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802662:	ef 
  802663:	0f b7 c0             	movzwl %ax,%eax
}
  802666:	5d                   	pop    %ebp
  802667:	c3                   	ret    
  802668:	66 90                	xchg   %ax,%ax
  80266a:	66 90                	xchg   %ax,%ax
  80266c:	66 90                	xchg   %ax,%ax
  80266e:	66 90                	xchg   %ax,%ax

00802670 <__udivdi3>:
  802670:	55                   	push   %ebp
  802671:	57                   	push   %edi
  802672:	56                   	push   %esi
  802673:	53                   	push   %ebx
  802674:	83 ec 1c             	sub    $0x1c,%esp
  802677:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80267b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80267f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802683:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802687:	85 f6                	test   %esi,%esi
  802689:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80268d:	89 ca                	mov    %ecx,%edx
  80268f:	89 f8                	mov    %edi,%eax
  802691:	75 3d                	jne    8026d0 <__udivdi3+0x60>
  802693:	39 cf                	cmp    %ecx,%edi
  802695:	0f 87 c5 00 00 00    	ja     802760 <__udivdi3+0xf0>
  80269b:	85 ff                	test   %edi,%edi
  80269d:	89 fd                	mov    %edi,%ebp
  80269f:	75 0b                	jne    8026ac <__udivdi3+0x3c>
  8026a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8026a6:	31 d2                	xor    %edx,%edx
  8026a8:	f7 f7                	div    %edi
  8026aa:	89 c5                	mov    %eax,%ebp
  8026ac:	89 c8                	mov    %ecx,%eax
  8026ae:	31 d2                	xor    %edx,%edx
  8026b0:	f7 f5                	div    %ebp
  8026b2:	89 c1                	mov    %eax,%ecx
  8026b4:	89 d8                	mov    %ebx,%eax
  8026b6:	89 cf                	mov    %ecx,%edi
  8026b8:	f7 f5                	div    %ebp
  8026ba:	89 c3                	mov    %eax,%ebx
  8026bc:	89 d8                	mov    %ebx,%eax
  8026be:	89 fa                	mov    %edi,%edx
  8026c0:	83 c4 1c             	add    $0x1c,%esp
  8026c3:	5b                   	pop    %ebx
  8026c4:	5e                   	pop    %esi
  8026c5:	5f                   	pop    %edi
  8026c6:	5d                   	pop    %ebp
  8026c7:	c3                   	ret    
  8026c8:	90                   	nop
  8026c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026d0:	39 ce                	cmp    %ecx,%esi
  8026d2:	77 74                	ja     802748 <__udivdi3+0xd8>
  8026d4:	0f bd fe             	bsr    %esi,%edi
  8026d7:	83 f7 1f             	xor    $0x1f,%edi
  8026da:	0f 84 98 00 00 00    	je     802778 <__udivdi3+0x108>
  8026e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8026e5:	89 f9                	mov    %edi,%ecx
  8026e7:	89 c5                	mov    %eax,%ebp
  8026e9:	29 fb                	sub    %edi,%ebx
  8026eb:	d3 e6                	shl    %cl,%esi
  8026ed:	89 d9                	mov    %ebx,%ecx
  8026ef:	d3 ed                	shr    %cl,%ebp
  8026f1:	89 f9                	mov    %edi,%ecx
  8026f3:	d3 e0                	shl    %cl,%eax
  8026f5:	09 ee                	or     %ebp,%esi
  8026f7:	89 d9                	mov    %ebx,%ecx
  8026f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026fd:	89 d5                	mov    %edx,%ebp
  8026ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802703:	d3 ed                	shr    %cl,%ebp
  802705:	89 f9                	mov    %edi,%ecx
  802707:	d3 e2                	shl    %cl,%edx
  802709:	89 d9                	mov    %ebx,%ecx
  80270b:	d3 e8                	shr    %cl,%eax
  80270d:	09 c2                	or     %eax,%edx
  80270f:	89 d0                	mov    %edx,%eax
  802711:	89 ea                	mov    %ebp,%edx
  802713:	f7 f6                	div    %esi
  802715:	89 d5                	mov    %edx,%ebp
  802717:	89 c3                	mov    %eax,%ebx
  802719:	f7 64 24 0c          	mull   0xc(%esp)
  80271d:	39 d5                	cmp    %edx,%ebp
  80271f:	72 10                	jb     802731 <__udivdi3+0xc1>
  802721:	8b 74 24 08          	mov    0x8(%esp),%esi
  802725:	89 f9                	mov    %edi,%ecx
  802727:	d3 e6                	shl    %cl,%esi
  802729:	39 c6                	cmp    %eax,%esi
  80272b:	73 07                	jae    802734 <__udivdi3+0xc4>
  80272d:	39 d5                	cmp    %edx,%ebp
  80272f:	75 03                	jne    802734 <__udivdi3+0xc4>
  802731:	83 eb 01             	sub    $0x1,%ebx
  802734:	31 ff                	xor    %edi,%edi
  802736:	89 d8                	mov    %ebx,%eax
  802738:	89 fa                	mov    %edi,%edx
  80273a:	83 c4 1c             	add    $0x1c,%esp
  80273d:	5b                   	pop    %ebx
  80273e:	5e                   	pop    %esi
  80273f:	5f                   	pop    %edi
  802740:	5d                   	pop    %ebp
  802741:	c3                   	ret    
  802742:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802748:	31 ff                	xor    %edi,%edi
  80274a:	31 db                	xor    %ebx,%ebx
  80274c:	89 d8                	mov    %ebx,%eax
  80274e:	89 fa                	mov    %edi,%edx
  802750:	83 c4 1c             	add    $0x1c,%esp
  802753:	5b                   	pop    %ebx
  802754:	5e                   	pop    %esi
  802755:	5f                   	pop    %edi
  802756:	5d                   	pop    %ebp
  802757:	c3                   	ret    
  802758:	90                   	nop
  802759:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802760:	89 d8                	mov    %ebx,%eax
  802762:	f7 f7                	div    %edi
  802764:	31 ff                	xor    %edi,%edi
  802766:	89 c3                	mov    %eax,%ebx
  802768:	89 d8                	mov    %ebx,%eax
  80276a:	89 fa                	mov    %edi,%edx
  80276c:	83 c4 1c             	add    $0x1c,%esp
  80276f:	5b                   	pop    %ebx
  802770:	5e                   	pop    %esi
  802771:	5f                   	pop    %edi
  802772:	5d                   	pop    %ebp
  802773:	c3                   	ret    
  802774:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802778:	39 ce                	cmp    %ecx,%esi
  80277a:	72 0c                	jb     802788 <__udivdi3+0x118>
  80277c:	31 db                	xor    %ebx,%ebx
  80277e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802782:	0f 87 34 ff ff ff    	ja     8026bc <__udivdi3+0x4c>
  802788:	bb 01 00 00 00       	mov    $0x1,%ebx
  80278d:	e9 2a ff ff ff       	jmp    8026bc <__udivdi3+0x4c>
  802792:	66 90                	xchg   %ax,%ax
  802794:	66 90                	xchg   %ax,%ax
  802796:	66 90                	xchg   %ax,%ax
  802798:	66 90                	xchg   %ax,%ax
  80279a:	66 90                	xchg   %ax,%ax
  80279c:	66 90                	xchg   %ax,%ax
  80279e:	66 90                	xchg   %ax,%ax

008027a0 <__umoddi3>:
  8027a0:	55                   	push   %ebp
  8027a1:	57                   	push   %edi
  8027a2:	56                   	push   %esi
  8027a3:	53                   	push   %ebx
  8027a4:	83 ec 1c             	sub    $0x1c,%esp
  8027a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8027ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8027af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8027b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027b7:	85 d2                	test   %edx,%edx
  8027b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8027bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027c1:	89 f3                	mov    %esi,%ebx
  8027c3:	89 3c 24             	mov    %edi,(%esp)
  8027c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027ca:	75 1c                	jne    8027e8 <__umoddi3+0x48>
  8027cc:	39 f7                	cmp    %esi,%edi
  8027ce:	76 50                	jbe    802820 <__umoddi3+0x80>
  8027d0:	89 c8                	mov    %ecx,%eax
  8027d2:	89 f2                	mov    %esi,%edx
  8027d4:	f7 f7                	div    %edi
  8027d6:	89 d0                	mov    %edx,%eax
  8027d8:	31 d2                	xor    %edx,%edx
  8027da:	83 c4 1c             	add    $0x1c,%esp
  8027dd:	5b                   	pop    %ebx
  8027de:	5e                   	pop    %esi
  8027df:	5f                   	pop    %edi
  8027e0:	5d                   	pop    %ebp
  8027e1:	c3                   	ret    
  8027e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027e8:	39 f2                	cmp    %esi,%edx
  8027ea:	89 d0                	mov    %edx,%eax
  8027ec:	77 52                	ja     802840 <__umoddi3+0xa0>
  8027ee:	0f bd ea             	bsr    %edx,%ebp
  8027f1:	83 f5 1f             	xor    $0x1f,%ebp
  8027f4:	75 5a                	jne    802850 <__umoddi3+0xb0>
  8027f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8027fa:	0f 82 e0 00 00 00    	jb     8028e0 <__umoddi3+0x140>
  802800:	39 0c 24             	cmp    %ecx,(%esp)
  802803:	0f 86 d7 00 00 00    	jbe    8028e0 <__umoddi3+0x140>
  802809:	8b 44 24 08          	mov    0x8(%esp),%eax
  80280d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802811:	83 c4 1c             	add    $0x1c,%esp
  802814:	5b                   	pop    %ebx
  802815:	5e                   	pop    %esi
  802816:	5f                   	pop    %edi
  802817:	5d                   	pop    %ebp
  802818:	c3                   	ret    
  802819:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802820:	85 ff                	test   %edi,%edi
  802822:	89 fd                	mov    %edi,%ebp
  802824:	75 0b                	jne    802831 <__umoddi3+0x91>
  802826:	b8 01 00 00 00       	mov    $0x1,%eax
  80282b:	31 d2                	xor    %edx,%edx
  80282d:	f7 f7                	div    %edi
  80282f:	89 c5                	mov    %eax,%ebp
  802831:	89 f0                	mov    %esi,%eax
  802833:	31 d2                	xor    %edx,%edx
  802835:	f7 f5                	div    %ebp
  802837:	89 c8                	mov    %ecx,%eax
  802839:	f7 f5                	div    %ebp
  80283b:	89 d0                	mov    %edx,%eax
  80283d:	eb 99                	jmp    8027d8 <__umoddi3+0x38>
  80283f:	90                   	nop
  802840:	89 c8                	mov    %ecx,%eax
  802842:	89 f2                	mov    %esi,%edx
  802844:	83 c4 1c             	add    $0x1c,%esp
  802847:	5b                   	pop    %ebx
  802848:	5e                   	pop    %esi
  802849:	5f                   	pop    %edi
  80284a:	5d                   	pop    %ebp
  80284b:	c3                   	ret    
  80284c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802850:	8b 34 24             	mov    (%esp),%esi
  802853:	bf 20 00 00 00       	mov    $0x20,%edi
  802858:	89 e9                	mov    %ebp,%ecx
  80285a:	29 ef                	sub    %ebp,%edi
  80285c:	d3 e0                	shl    %cl,%eax
  80285e:	89 f9                	mov    %edi,%ecx
  802860:	89 f2                	mov    %esi,%edx
  802862:	d3 ea                	shr    %cl,%edx
  802864:	89 e9                	mov    %ebp,%ecx
  802866:	09 c2                	or     %eax,%edx
  802868:	89 d8                	mov    %ebx,%eax
  80286a:	89 14 24             	mov    %edx,(%esp)
  80286d:	89 f2                	mov    %esi,%edx
  80286f:	d3 e2                	shl    %cl,%edx
  802871:	89 f9                	mov    %edi,%ecx
  802873:	89 54 24 04          	mov    %edx,0x4(%esp)
  802877:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80287b:	d3 e8                	shr    %cl,%eax
  80287d:	89 e9                	mov    %ebp,%ecx
  80287f:	89 c6                	mov    %eax,%esi
  802881:	d3 e3                	shl    %cl,%ebx
  802883:	89 f9                	mov    %edi,%ecx
  802885:	89 d0                	mov    %edx,%eax
  802887:	d3 e8                	shr    %cl,%eax
  802889:	89 e9                	mov    %ebp,%ecx
  80288b:	09 d8                	or     %ebx,%eax
  80288d:	89 d3                	mov    %edx,%ebx
  80288f:	89 f2                	mov    %esi,%edx
  802891:	f7 34 24             	divl   (%esp)
  802894:	89 d6                	mov    %edx,%esi
  802896:	d3 e3                	shl    %cl,%ebx
  802898:	f7 64 24 04          	mull   0x4(%esp)
  80289c:	39 d6                	cmp    %edx,%esi
  80289e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028a2:	89 d1                	mov    %edx,%ecx
  8028a4:	89 c3                	mov    %eax,%ebx
  8028a6:	72 08                	jb     8028b0 <__umoddi3+0x110>
  8028a8:	75 11                	jne    8028bb <__umoddi3+0x11b>
  8028aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8028ae:	73 0b                	jae    8028bb <__umoddi3+0x11b>
  8028b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8028b4:	1b 14 24             	sbb    (%esp),%edx
  8028b7:	89 d1                	mov    %edx,%ecx
  8028b9:	89 c3                	mov    %eax,%ebx
  8028bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8028bf:	29 da                	sub    %ebx,%edx
  8028c1:	19 ce                	sbb    %ecx,%esi
  8028c3:	89 f9                	mov    %edi,%ecx
  8028c5:	89 f0                	mov    %esi,%eax
  8028c7:	d3 e0                	shl    %cl,%eax
  8028c9:	89 e9                	mov    %ebp,%ecx
  8028cb:	d3 ea                	shr    %cl,%edx
  8028cd:	89 e9                	mov    %ebp,%ecx
  8028cf:	d3 ee                	shr    %cl,%esi
  8028d1:	09 d0                	or     %edx,%eax
  8028d3:	89 f2                	mov    %esi,%edx
  8028d5:	83 c4 1c             	add    $0x1c,%esp
  8028d8:	5b                   	pop    %ebx
  8028d9:	5e                   	pop    %esi
  8028da:	5f                   	pop    %edi
  8028db:	5d                   	pop    %ebp
  8028dc:	c3                   	ret    
  8028dd:	8d 76 00             	lea    0x0(%esi),%esi
  8028e0:	29 f9                	sub    %edi,%ecx
  8028e2:	19 d6                	sbb    %edx,%esi
  8028e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028ec:	e9 18 ff ff ff       	jmp    802809 <__umoddi3+0x69>
