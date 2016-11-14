
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 df 0d 00 00       	call   800e20 <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 ea 0a 00 00       	call   800b39 <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 20 14 80 00       	push   $0x801420
  800059:	e8 4b 01 00 00       	call   8001a9 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 dc 0f 00 00       	call   801048 <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 62 0f 00 00       	call   800fe1 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 b0 0a 00 00       	call   800b39 <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 36 14 80 00       	push   $0x801436
  800091:	e8 13 01 00 00       	call   8001a9 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 9a 0f 00 00       	call   801048 <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  8000c9:	e8 6b 0a 00 00       	call   800b39 <sys_getenvid>
  8000ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000db:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e0:	85 db                	test   %ebx,%ebx
  8000e2:	7e 07                	jle    8000eb <libmain+0x2d>
		binaryname = argv[0];
  8000e4:	8b 06                	mov    (%esi),%eax
  8000e6:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	e8 3e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80010a:	6a 00                	push   $0x0
  80010c:	e8 e7 09 00 00       	call   800af8 <sys_env_destroy>
}
  800111:	83 c4 10             	add    $0x10,%esp
  800114:	c9                   	leave  
  800115:	c3                   	ret    

00800116 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	53                   	push   %ebx
  80011a:	83 ec 04             	sub    $0x4,%esp
  80011d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800120:	8b 13                	mov    (%ebx),%edx
  800122:	8d 42 01             	lea    0x1(%edx),%eax
  800125:	89 03                	mov    %eax,(%ebx)
  800127:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80012a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800133:	75 1a                	jne    80014f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800135:	83 ec 08             	sub    $0x8,%esp
  800138:	68 ff 00 00 00       	push   $0xff
  80013d:	8d 43 08             	lea    0x8(%ebx),%eax
  800140:	50                   	push   %eax
  800141:	e8 75 09 00 00       	call   800abb <sys_cputs>
		b->idx = 0;
  800146:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800153:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800161:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800168:	00 00 00 
	b.cnt = 0;
  80016b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800172:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800175:	ff 75 0c             	pushl  0xc(%ebp)
  800178:	ff 75 08             	pushl  0x8(%ebp)
  80017b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800181:	50                   	push   %eax
  800182:	68 16 01 80 00       	push   $0x800116
  800187:	e8 54 01 00 00       	call   8002e0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018c:	83 c4 08             	add    $0x8,%esp
  80018f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800195:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019b:	50                   	push   %eax
  80019c:	e8 1a 09 00 00       	call   800abb <sys_cputs>

	return b.cnt;
}
  8001a1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a7:	c9                   	leave  
  8001a8:	c3                   	ret    

008001a9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001af:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b2:	50                   	push   %eax
  8001b3:	ff 75 08             	pushl  0x8(%ebp)
  8001b6:	e8 9d ff ff ff       	call   800158 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    

008001bd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	57                   	push   %edi
  8001c1:	56                   	push   %esi
  8001c2:	53                   	push   %ebx
  8001c3:	83 ec 1c             	sub    $0x1c,%esp
  8001c6:	89 c7                	mov    %eax,%edi
  8001c8:	89 d6                	mov    %edx,%esi
  8001ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001de:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e4:	39 d3                	cmp    %edx,%ebx
  8001e6:	72 05                	jb     8001ed <printnum+0x30>
  8001e8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001eb:	77 45                	ja     800232 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ed:	83 ec 0c             	sub    $0xc,%esp
  8001f0:	ff 75 18             	pushl  0x18(%ebp)
  8001f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f6:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f9:	53                   	push   %ebx
  8001fa:	ff 75 10             	pushl  0x10(%ebp)
  8001fd:	83 ec 08             	sub    $0x8,%esp
  800200:	ff 75 e4             	pushl  -0x1c(%ebp)
  800203:	ff 75 e0             	pushl  -0x20(%ebp)
  800206:	ff 75 dc             	pushl  -0x24(%ebp)
  800209:	ff 75 d8             	pushl  -0x28(%ebp)
  80020c:	e8 7f 0f 00 00       	call   801190 <__udivdi3>
  800211:	83 c4 18             	add    $0x18,%esp
  800214:	52                   	push   %edx
  800215:	50                   	push   %eax
  800216:	89 f2                	mov    %esi,%edx
  800218:	89 f8                	mov    %edi,%eax
  80021a:	e8 9e ff ff ff       	call   8001bd <printnum>
  80021f:	83 c4 20             	add    $0x20,%esp
  800222:	eb 18                	jmp    80023c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800224:	83 ec 08             	sub    $0x8,%esp
  800227:	56                   	push   %esi
  800228:	ff 75 18             	pushl  0x18(%ebp)
  80022b:	ff d7                	call   *%edi
  80022d:	83 c4 10             	add    $0x10,%esp
  800230:	eb 03                	jmp    800235 <printnum+0x78>
  800232:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800235:	83 eb 01             	sub    $0x1,%ebx
  800238:	85 db                	test   %ebx,%ebx
  80023a:	7f e8                	jg     800224 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023c:	83 ec 08             	sub    $0x8,%esp
  80023f:	56                   	push   %esi
  800240:	83 ec 04             	sub    $0x4,%esp
  800243:	ff 75 e4             	pushl  -0x1c(%ebp)
  800246:	ff 75 e0             	pushl  -0x20(%ebp)
  800249:	ff 75 dc             	pushl  -0x24(%ebp)
  80024c:	ff 75 d8             	pushl  -0x28(%ebp)
  80024f:	e8 6c 10 00 00       	call   8012c0 <__umoddi3>
  800254:	83 c4 14             	add    $0x14,%esp
  800257:	0f be 80 53 14 80 00 	movsbl 0x801453(%eax),%eax
  80025e:	50                   	push   %eax
  80025f:	ff d7                	call   *%edi
}
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026f:	83 fa 01             	cmp    $0x1,%edx
  800272:	7e 0e                	jle    800282 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800274:	8b 10                	mov    (%eax),%edx
  800276:	8d 4a 08             	lea    0x8(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	8b 52 04             	mov    0x4(%edx),%edx
  800280:	eb 22                	jmp    8002a4 <getuint+0x38>
	else if (lflag)
  800282:	85 d2                	test   %edx,%edx
  800284:	74 10                	je     800296 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800286:	8b 10                	mov    (%eax),%edx
  800288:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028b:	89 08                	mov    %ecx,(%eax)
  80028d:	8b 02                	mov    (%edx),%eax
  80028f:	ba 00 00 00 00       	mov    $0x0,%edx
  800294:	eb 0e                	jmp    8002a4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800296:	8b 10                	mov    (%eax),%edx
  800298:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029b:	89 08                	mov    %ecx,(%eax)
  80029d:	8b 02                	mov    (%edx),%eax
  80029f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ac:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b0:	8b 10                	mov    (%eax),%edx
  8002b2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b5:	73 0a                	jae    8002c1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ba:	89 08                	mov    %ecx,(%eax)
  8002bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bf:	88 02                	mov    %al,(%edx)
}
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002cc:	50                   	push   %eax
  8002cd:	ff 75 10             	pushl  0x10(%ebp)
  8002d0:	ff 75 0c             	pushl  0xc(%ebp)
  8002d3:	ff 75 08             	pushl  0x8(%ebp)
  8002d6:	e8 05 00 00 00       	call   8002e0 <vprintfmt>
	va_end(ap);
}
  8002db:	83 c4 10             	add    $0x10,%esp
  8002de:	c9                   	leave  
  8002df:	c3                   	ret    

008002e0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 2c             	sub    $0x2c,%esp
  8002e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ef:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f2:	eb 1d                	jmp    800311 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	75 0f                	jne    800307 <vprintfmt+0x27>
				csa = 0x0700;
  8002f8:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  8002ff:	07 00 00 
				return;
  800302:	e9 c4 03 00 00       	jmp    8006cb <vprintfmt+0x3eb>
			}
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
  80031b:	75 d7                	jne    8002f4 <vprintfmt+0x14>
  80031d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800321:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800328:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800336:	ba 00 00 00 00       	mov    $0x0,%edx
  80033b:	eb 07                	jmp    800344 <vprintfmt+0x64>
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
  800355:	0f 87 55 03 00 00    	ja     8006b0 <vprintfmt+0x3d0>
  80035b:	0f b6 c0             	movzbl %al,%eax
  80035e:	ff 24 85 20 15 80 00 	jmp    *0x801520(,%eax,4)
  800365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800368:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036c:	eb d6                	jmp    800344 <vprintfmt+0x64>
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
  800389:	77 39                	ja     8003c4 <vprintfmt+0xe4>
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
  80038e:	eb e9                	jmp    800379 <vprintfmt+0x99>
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
  8003a1:	eb 27                	jmp    8003ca <vprintfmt+0xea>
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
  8003b6:	eb 8c                	jmp    800344 <vprintfmt+0x64>
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003bb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c2:	eb 80                	jmp    800344 <vprintfmt+0x64>
  8003c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003c7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ce:	0f 89 70 ff ff ff    	jns    800344 <vprintfmt+0x64>
				width = precision, precision = -1;
  8003d4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003da:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e1:	e9 5e ff ff ff       	jmp    800344 <vprintfmt+0x64>
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
  8003ec:	e9 53 ff ff ff       	jmp    800344 <vprintfmt+0x64>

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
  800408:	e9 04 ff ff ff       	jmp    800311 <vprintfmt+0x31>

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
  80041d:	83 f8 08             	cmp    $0x8,%eax
  800420:	7f 0b                	jg     80042d <vprintfmt+0x14d>
  800422:	8b 14 85 80 16 80 00 	mov    0x801680(,%eax,4),%edx
  800429:	85 d2                	test   %edx,%edx
  80042b:	75 18                	jne    800445 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  80042d:	50                   	push   %eax
  80042e:	68 6b 14 80 00       	push   $0x80146b
  800433:	53                   	push   %ebx
  800434:	56                   	push   %esi
  800435:	e8 89 fe ff ff       	call   8002c3 <printfmt>
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
  800440:	e9 cc fe ff ff       	jmp    800311 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  800445:	52                   	push   %edx
  800446:	68 74 14 80 00       	push   $0x801474
  80044b:	53                   	push   %ebx
  80044c:	56                   	push   %esi
  80044d:	e8 71 fe ff ff       	call   8002c3 <printfmt>
  800452:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800458:	e9 b4 fe ff ff       	jmp    800311 <vprintfmt+0x31>
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
  80046a:	b8 64 14 80 00       	mov    $0x801464,%eax
  80046f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800472:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800476:	0f 8e 94 00 00 00    	jle    800510 <vprintfmt+0x230>
  80047c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800480:	0f 84 98 00 00 00    	je     80051e <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	ff 75 d0             	pushl  -0x30(%ebp)
  80048c:	57                   	push   %edi
  80048d:	e8 c1 02 00 00       	call   800753 <strnlen>
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
  8004a9:	eb 0f                	jmp    8004ba <vprintfmt+0x1da>
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
  8004bc:	7f ed                	jg     8004ab <vprintfmt+0x1cb>
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
  8004db:	eb 4d                	jmp    80052a <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e1:	74 1b                	je     8004fe <vprintfmt+0x21e>
  8004e3:	0f be c0             	movsbl %al,%eax
  8004e6:	83 e8 20             	sub    $0x20,%eax
  8004e9:	83 f8 5e             	cmp    $0x5e,%eax
  8004ec:	76 10                	jbe    8004fe <vprintfmt+0x21e>
					putch('?', putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	ff 75 0c             	pushl  0xc(%ebp)
  8004f4:	6a 3f                	push   $0x3f
  8004f6:	ff 55 08             	call   *0x8(%ebp)
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	eb 0d                	jmp    80050b <vprintfmt+0x22b>
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
  80050e:	eb 1a                	jmp    80052a <vprintfmt+0x24a>
  800510:	89 75 08             	mov    %esi,0x8(%ebp)
  800513:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800516:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800519:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051c:	eb 0c                	jmp    80052a <vprintfmt+0x24a>
  80051e:	89 75 08             	mov    %esi,0x8(%ebp)
  800521:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800524:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800527:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052a:	83 c7 01             	add    $0x1,%edi
  80052d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800531:	0f be d0             	movsbl %al,%edx
  800534:	85 d2                	test   %edx,%edx
  800536:	74 23                	je     80055b <vprintfmt+0x27b>
  800538:	85 f6                	test   %esi,%esi
  80053a:	78 a1                	js     8004dd <vprintfmt+0x1fd>
  80053c:	83 ee 01             	sub    $0x1,%esi
  80053f:	79 9c                	jns    8004dd <vprintfmt+0x1fd>
  800541:	89 df                	mov    %ebx,%edi
  800543:	8b 75 08             	mov    0x8(%ebp),%esi
  800546:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800549:	eb 18                	jmp    800563 <vprintfmt+0x283>
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
  800559:	eb 08                	jmp    800563 <vprintfmt+0x283>
  80055b:	89 df                	mov    %ebx,%edi
  80055d:	8b 75 08             	mov    0x8(%ebp),%esi
  800560:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800563:	85 ff                	test   %edi,%edi
  800565:	7f e4                	jg     80054b <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800567:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056a:	e9 a2 fd ff ff       	jmp    800311 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056f:	83 fa 01             	cmp    $0x1,%edx
  800572:	7e 16                	jle    80058a <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 50 08             	lea    0x8(%eax),%edx
  80057a:	89 55 14             	mov    %edx,0x14(%ebp)
  80057d:	8b 50 04             	mov    0x4(%eax),%edx
  800580:	8b 00                	mov    (%eax),%eax
  800582:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800585:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800588:	eb 32                	jmp    8005bc <vprintfmt+0x2dc>
	else if (lflag)
  80058a:	85 d2                	test   %edx,%edx
  80058c:	74 18                	je     8005a6 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8d 50 04             	lea    0x4(%eax),%edx
  800594:	89 55 14             	mov    %edx,0x14(%ebp)
  800597:	8b 00                	mov    (%eax),%eax
  800599:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059c:	89 c1                	mov    %eax,%ecx
  80059e:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a4:	eb 16                	jmp    8005bc <vprintfmt+0x2dc>
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
  8005cb:	79 74                	jns    800641 <vprintfmt+0x361>
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
  8005ea:	eb 55                	jmp    800641 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ef:	e8 78 fc ff ff       	call   80026c <getuint>
			base = 10;
  8005f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005f9:	eb 46                	jmp    800641 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  8005fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fe:	e8 69 fc ff ff       	call   80026c <getuint>
      base = 8;
  800603:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800608:	eb 37                	jmp    800641 <vprintfmt+0x361>

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
  800632:	eb 0d                	jmp    800641 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800634:	8d 45 14             	lea    0x14(%ebp),%eax
  800637:	e8 30 fc ff ff       	call   80026c <getuint>
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
  800653:	e8 65 fb ff ff       	call   8001bd <printnum>
			break;
  800658:	83 c4 20             	add    $0x20,%esp
  80065b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065e:	e9 ae fc ff ff       	jmp    800311 <vprintfmt+0x31>

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
  800670:	e9 9c fc ff ff       	jmp    800311 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800675:	83 fa 01             	cmp    $0x1,%edx
  800678:	7e 0d                	jle    800687 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8d 50 08             	lea    0x8(%eax),%edx
  800680:	89 55 14             	mov    %edx,0x14(%ebp)
  800683:	8b 00                	mov    (%eax),%eax
  800685:	eb 1c                	jmp    8006a3 <vprintfmt+0x3c3>
	else if (lflag)
  800687:	85 d2                	test   %edx,%edx
  800689:	74 0d                	je     800698 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8d 50 04             	lea    0x4(%eax),%edx
  800691:	89 55 14             	mov    %edx,0x14(%ebp)
  800694:	8b 00                	mov    (%eax),%eax
  800696:	eb 0b                	jmp    8006a3 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8d 50 04             	lea    0x4(%eax),%edx
  80069e:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a1:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  8006a3:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  8006ab:	e9 61 fc ff ff       	jmp    800311 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b0:	83 ec 08             	sub    $0x8,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	6a 25                	push   $0x25
  8006b6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	eb 03                	jmp    8006c0 <vprintfmt+0x3e0>
  8006bd:	83 ef 01             	sub    $0x1,%edi
  8006c0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c4:	75 f7                	jne    8006bd <vprintfmt+0x3dd>
  8006c6:	e9 46 fc ff ff       	jmp    800311 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  8006cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ce:	5b                   	pop    %ebx
  8006cf:	5e                   	pop    %esi
  8006d0:	5f                   	pop    %edi
  8006d1:	5d                   	pop    %ebp
  8006d2:	c3                   	ret    

008006d3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d3:	55                   	push   %ebp
  8006d4:	89 e5                	mov    %esp,%ebp
  8006d6:	83 ec 18             	sub    $0x18,%esp
  8006d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f0:	85 c0                	test   %eax,%eax
  8006f2:	74 26                	je     80071a <vsnprintf+0x47>
  8006f4:	85 d2                	test   %edx,%edx
  8006f6:	7e 22                	jle    80071a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f8:	ff 75 14             	pushl  0x14(%ebp)
  8006fb:	ff 75 10             	pushl  0x10(%ebp)
  8006fe:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800701:	50                   	push   %eax
  800702:	68 a6 02 80 00       	push   $0x8002a6
  800707:	e8 d4 fb ff ff       	call   8002e0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800712:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800715:	83 c4 10             	add    $0x10,%esp
  800718:	eb 05                	jmp    80071f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80071f:	c9                   	leave  
  800720:	c3                   	ret    

00800721 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800721:	55                   	push   %ebp
  800722:	89 e5                	mov    %esp,%ebp
  800724:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800727:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072a:	50                   	push   %eax
  80072b:	ff 75 10             	pushl  0x10(%ebp)
  80072e:	ff 75 0c             	pushl  0xc(%ebp)
  800731:	ff 75 08             	pushl  0x8(%ebp)
  800734:	e8 9a ff ff ff       	call   8006d3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800739:	c9                   	leave  
  80073a:	c3                   	ret    

0080073b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800741:	b8 00 00 00 00       	mov    $0x0,%eax
  800746:	eb 03                	jmp    80074b <strlen+0x10>
		n++;
  800748:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074f:	75 f7                	jne    800748 <strlen+0xd>
		n++;
	return n;
}
  800751:	5d                   	pop    %ebp
  800752:	c3                   	ret    

00800753 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800759:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075c:	ba 00 00 00 00       	mov    $0x0,%edx
  800761:	eb 03                	jmp    800766 <strnlen+0x13>
		n++;
  800763:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800766:	39 c2                	cmp    %eax,%edx
  800768:	74 08                	je     800772 <strnlen+0x1f>
  80076a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80076e:	75 f3                	jne    800763 <strnlen+0x10>
  800770:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800772:	5d                   	pop    %ebp
  800773:	c3                   	ret    

00800774 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	53                   	push   %ebx
  800778:	8b 45 08             	mov    0x8(%ebp),%eax
  80077b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077e:	89 c2                	mov    %eax,%edx
  800780:	83 c2 01             	add    $0x1,%edx
  800783:	83 c1 01             	add    $0x1,%ecx
  800786:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80078d:	84 db                	test   %bl,%bl
  80078f:	75 ef                	jne    800780 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800791:	5b                   	pop    %ebx
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	53                   	push   %ebx
  800798:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079b:	53                   	push   %ebx
  80079c:	e8 9a ff ff ff       	call   80073b <strlen>
  8007a1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a4:	ff 75 0c             	pushl  0xc(%ebp)
  8007a7:	01 d8                	add    %ebx,%eax
  8007a9:	50                   	push   %eax
  8007aa:	e8 c5 ff ff ff       	call   800774 <strcpy>
	return dst;
}
  8007af:	89 d8                	mov    %ebx,%eax
  8007b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    

008007b6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	56                   	push   %esi
  8007ba:	53                   	push   %ebx
  8007bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c1:	89 f3                	mov    %esi,%ebx
  8007c3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c6:	89 f2                	mov    %esi,%edx
  8007c8:	eb 0f                	jmp    8007d9 <strncpy+0x23>
		*dst++ = *src;
  8007ca:	83 c2 01             	add    $0x1,%edx
  8007cd:	0f b6 01             	movzbl (%ecx),%eax
  8007d0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d3:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d9:	39 da                	cmp    %ebx,%edx
  8007db:	75 ed                	jne    8007ca <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007dd:	89 f0                	mov    %esi,%eax
  8007df:	5b                   	pop    %ebx
  8007e0:	5e                   	pop    %esi
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	56                   	push   %esi
  8007e7:	53                   	push   %ebx
  8007e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ee:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f3:	85 d2                	test   %edx,%edx
  8007f5:	74 21                	je     800818 <strlcpy+0x35>
  8007f7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fb:	89 f2                	mov    %esi,%edx
  8007fd:	eb 09                	jmp    800808 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ff:	83 c2 01             	add    $0x1,%edx
  800802:	83 c1 01             	add    $0x1,%ecx
  800805:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800808:	39 c2                	cmp    %eax,%edx
  80080a:	74 09                	je     800815 <strlcpy+0x32>
  80080c:	0f b6 19             	movzbl (%ecx),%ebx
  80080f:	84 db                	test   %bl,%bl
  800811:	75 ec                	jne    8007ff <strlcpy+0x1c>
  800813:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800815:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800818:	29 f0                	sub    %esi,%eax
}
  80081a:	5b                   	pop    %ebx
  80081b:	5e                   	pop    %esi
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800824:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800827:	eb 06                	jmp    80082f <strcmp+0x11>
		p++, q++;
  800829:	83 c1 01             	add    $0x1,%ecx
  80082c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80082f:	0f b6 01             	movzbl (%ecx),%eax
  800832:	84 c0                	test   %al,%al
  800834:	74 04                	je     80083a <strcmp+0x1c>
  800836:	3a 02                	cmp    (%edx),%al
  800838:	74 ef                	je     800829 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083a:	0f b6 c0             	movzbl %al,%eax
  80083d:	0f b6 12             	movzbl (%edx),%edx
  800840:	29 d0                	sub    %edx,%eax
}
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	53                   	push   %ebx
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084e:	89 c3                	mov    %eax,%ebx
  800850:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800853:	eb 06                	jmp    80085b <strncmp+0x17>
		n--, p++, q++;
  800855:	83 c0 01             	add    $0x1,%eax
  800858:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085b:	39 d8                	cmp    %ebx,%eax
  80085d:	74 15                	je     800874 <strncmp+0x30>
  80085f:	0f b6 08             	movzbl (%eax),%ecx
  800862:	84 c9                	test   %cl,%cl
  800864:	74 04                	je     80086a <strncmp+0x26>
  800866:	3a 0a                	cmp    (%edx),%cl
  800868:	74 eb                	je     800855 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086a:	0f b6 00             	movzbl (%eax),%eax
  80086d:	0f b6 12             	movzbl (%edx),%edx
  800870:	29 d0                	sub    %edx,%eax
  800872:	eb 05                	jmp    800879 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800874:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800879:	5b                   	pop    %ebx
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800886:	eb 07                	jmp    80088f <strchr+0x13>
		if (*s == c)
  800888:	38 ca                	cmp    %cl,%dl
  80088a:	74 0f                	je     80089b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088c:	83 c0 01             	add    $0x1,%eax
  80088f:	0f b6 10             	movzbl (%eax),%edx
  800892:	84 d2                	test   %dl,%dl
  800894:	75 f2                	jne    800888 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800896:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a7:	eb 03                	jmp    8008ac <strfind+0xf>
  8008a9:	83 c0 01             	add    $0x1,%eax
  8008ac:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008af:	38 ca                	cmp    %cl,%dl
  8008b1:	74 04                	je     8008b7 <strfind+0x1a>
  8008b3:	84 d2                	test   %dl,%dl
  8008b5:	75 f2                	jne    8008a9 <strfind+0xc>
			break;
	return (char *) s;
}
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	57                   	push   %edi
  8008bd:	56                   	push   %esi
  8008be:	53                   	push   %ebx
  8008bf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c5:	85 c9                	test   %ecx,%ecx
  8008c7:	74 36                	je     8008ff <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008cf:	75 28                	jne    8008f9 <memset+0x40>
  8008d1:	f6 c1 03             	test   $0x3,%cl
  8008d4:	75 23                	jne    8008f9 <memset+0x40>
		c &= 0xFF;
  8008d6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008da:	89 d3                	mov    %edx,%ebx
  8008dc:	c1 e3 08             	shl    $0x8,%ebx
  8008df:	89 d6                	mov    %edx,%esi
  8008e1:	c1 e6 18             	shl    $0x18,%esi
  8008e4:	89 d0                	mov    %edx,%eax
  8008e6:	c1 e0 10             	shl    $0x10,%eax
  8008e9:	09 f0                	or     %esi,%eax
  8008eb:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008ed:	89 d8                	mov    %ebx,%eax
  8008ef:	09 d0                	or     %edx,%eax
  8008f1:	c1 e9 02             	shr    $0x2,%ecx
  8008f4:	fc                   	cld    
  8008f5:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f7:	eb 06                	jmp    8008ff <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fc:	fc                   	cld    
  8008fd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ff:	89 f8                	mov    %edi,%eax
  800901:	5b                   	pop    %ebx
  800902:	5e                   	pop    %esi
  800903:	5f                   	pop    %edi
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	57                   	push   %edi
  80090a:	56                   	push   %esi
  80090b:	8b 45 08             	mov    0x8(%ebp),%eax
  80090e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800911:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800914:	39 c6                	cmp    %eax,%esi
  800916:	73 35                	jae    80094d <memmove+0x47>
  800918:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091b:	39 d0                	cmp    %edx,%eax
  80091d:	73 2e                	jae    80094d <memmove+0x47>
		s += n;
		d += n;
  80091f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800922:	89 d6                	mov    %edx,%esi
  800924:	09 fe                	or     %edi,%esi
  800926:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092c:	75 13                	jne    800941 <memmove+0x3b>
  80092e:	f6 c1 03             	test   $0x3,%cl
  800931:	75 0e                	jne    800941 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800933:	83 ef 04             	sub    $0x4,%edi
  800936:	8d 72 fc             	lea    -0x4(%edx),%esi
  800939:	c1 e9 02             	shr    $0x2,%ecx
  80093c:	fd                   	std    
  80093d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093f:	eb 09                	jmp    80094a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800941:	83 ef 01             	sub    $0x1,%edi
  800944:	8d 72 ff             	lea    -0x1(%edx),%esi
  800947:	fd                   	std    
  800948:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094a:	fc                   	cld    
  80094b:	eb 1d                	jmp    80096a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094d:	89 f2                	mov    %esi,%edx
  80094f:	09 c2                	or     %eax,%edx
  800951:	f6 c2 03             	test   $0x3,%dl
  800954:	75 0f                	jne    800965 <memmove+0x5f>
  800956:	f6 c1 03             	test   $0x3,%cl
  800959:	75 0a                	jne    800965 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80095b:	c1 e9 02             	shr    $0x2,%ecx
  80095e:	89 c7                	mov    %eax,%edi
  800960:	fc                   	cld    
  800961:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800963:	eb 05                	jmp    80096a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800965:	89 c7                	mov    %eax,%edi
  800967:	fc                   	cld    
  800968:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096a:	5e                   	pop    %esi
  80096b:	5f                   	pop    %edi
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800971:	ff 75 10             	pushl  0x10(%ebp)
  800974:	ff 75 0c             	pushl  0xc(%ebp)
  800977:	ff 75 08             	pushl  0x8(%ebp)
  80097a:	e8 87 ff ff ff       	call   800906 <memmove>
}
  80097f:	c9                   	leave  
  800980:	c3                   	ret    

00800981 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	56                   	push   %esi
  800985:	53                   	push   %ebx
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098c:	89 c6                	mov    %eax,%esi
  80098e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800991:	eb 1a                	jmp    8009ad <memcmp+0x2c>
		if (*s1 != *s2)
  800993:	0f b6 08             	movzbl (%eax),%ecx
  800996:	0f b6 1a             	movzbl (%edx),%ebx
  800999:	38 d9                	cmp    %bl,%cl
  80099b:	74 0a                	je     8009a7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80099d:	0f b6 c1             	movzbl %cl,%eax
  8009a0:	0f b6 db             	movzbl %bl,%ebx
  8009a3:	29 d8                	sub    %ebx,%eax
  8009a5:	eb 0f                	jmp    8009b6 <memcmp+0x35>
		s1++, s2++;
  8009a7:	83 c0 01             	add    $0x1,%eax
  8009aa:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ad:	39 f0                	cmp    %esi,%eax
  8009af:	75 e2                	jne    800993 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b6:	5b                   	pop    %ebx
  8009b7:	5e                   	pop    %esi
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	53                   	push   %ebx
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c1:	89 c1                	mov    %eax,%ecx
  8009c3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ca:	eb 0a                	jmp    8009d6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cc:	0f b6 10             	movzbl (%eax),%edx
  8009cf:	39 da                	cmp    %ebx,%edx
  8009d1:	74 07                	je     8009da <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d3:	83 c0 01             	add    $0x1,%eax
  8009d6:	39 c8                	cmp    %ecx,%eax
  8009d8:	72 f2                	jb     8009cc <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009da:	5b                   	pop    %ebx
  8009db:	5d                   	pop    %ebp
  8009dc:	c3                   	ret    

008009dd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	57                   	push   %edi
  8009e1:	56                   	push   %esi
  8009e2:	53                   	push   %ebx
  8009e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e9:	eb 03                	jmp    8009ee <strtol+0x11>
		s++;
  8009eb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ee:	0f b6 01             	movzbl (%ecx),%eax
  8009f1:	3c 20                	cmp    $0x20,%al
  8009f3:	74 f6                	je     8009eb <strtol+0xe>
  8009f5:	3c 09                	cmp    $0x9,%al
  8009f7:	74 f2                	je     8009eb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f9:	3c 2b                	cmp    $0x2b,%al
  8009fb:	75 0a                	jne    800a07 <strtol+0x2a>
		s++;
  8009fd:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a00:	bf 00 00 00 00       	mov    $0x0,%edi
  800a05:	eb 11                	jmp    800a18 <strtol+0x3b>
  800a07:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a0c:	3c 2d                	cmp    $0x2d,%al
  800a0e:	75 08                	jne    800a18 <strtol+0x3b>
		s++, neg = 1;
  800a10:	83 c1 01             	add    $0x1,%ecx
  800a13:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a18:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a1e:	75 15                	jne    800a35 <strtol+0x58>
  800a20:	80 39 30             	cmpb   $0x30,(%ecx)
  800a23:	75 10                	jne    800a35 <strtol+0x58>
  800a25:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a29:	75 7c                	jne    800aa7 <strtol+0xca>
		s += 2, base = 16;
  800a2b:	83 c1 02             	add    $0x2,%ecx
  800a2e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a33:	eb 16                	jmp    800a4b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a35:	85 db                	test   %ebx,%ebx
  800a37:	75 12                	jne    800a4b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a39:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a41:	75 08                	jne    800a4b <strtol+0x6e>
		s++, base = 8;
  800a43:	83 c1 01             	add    $0x1,%ecx
  800a46:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a50:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a53:	0f b6 11             	movzbl (%ecx),%edx
  800a56:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a59:	89 f3                	mov    %esi,%ebx
  800a5b:	80 fb 09             	cmp    $0x9,%bl
  800a5e:	77 08                	ja     800a68 <strtol+0x8b>
			dig = *s - '0';
  800a60:	0f be d2             	movsbl %dl,%edx
  800a63:	83 ea 30             	sub    $0x30,%edx
  800a66:	eb 22                	jmp    800a8a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a68:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a6b:	89 f3                	mov    %esi,%ebx
  800a6d:	80 fb 19             	cmp    $0x19,%bl
  800a70:	77 08                	ja     800a7a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a72:	0f be d2             	movsbl %dl,%edx
  800a75:	83 ea 57             	sub    $0x57,%edx
  800a78:	eb 10                	jmp    800a8a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a7a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a7d:	89 f3                	mov    %esi,%ebx
  800a7f:	80 fb 19             	cmp    $0x19,%bl
  800a82:	77 16                	ja     800a9a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a84:	0f be d2             	movsbl %dl,%edx
  800a87:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a8a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a8d:	7d 0b                	jge    800a9a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a8f:	83 c1 01             	add    $0x1,%ecx
  800a92:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a96:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a98:	eb b9                	jmp    800a53 <strtol+0x76>

	if (endptr)
  800a9a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9e:	74 0d                	je     800aad <strtol+0xd0>
		*endptr = (char *) s;
  800aa0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa3:	89 0e                	mov    %ecx,(%esi)
  800aa5:	eb 06                	jmp    800aad <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa7:	85 db                	test   %ebx,%ebx
  800aa9:	74 98                	je     800a43 <strtol+0x66>
  800aab:	eb 9e                	jmp    800a4b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aad:	89 c2                	mov    %eax,%edx
  800aaf:	f7 da                	neg    %edx
  800ab1:	85 ff                	test   %edi,%edi
  800ab3:	0f 45 c2             	cmovne %edx,%eax
}
  800ab6:	5b                   	pop    %ebx
  800ab7:	5e                   	pop    %esi
  800ab8:	5f                   	pop    %edi
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	57                   	push   %edi
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac9:	8b 55 08             	mov    0x8(%ebp),%edx
  800acc:	89 c3                	mov    %eax,%ebx
  800ace:	89 c7                	mov    %eax,%edi
  800ad0:	89 c6                	mov    %eax,%esi
  800ad2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5f                   	pop    %edi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	57                   	push   %edi
  800add:	56                   	push   %esi
  800ade:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800adf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae4:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae9:	89 d1                	mov    %edx,%ecx
  800aeb:	89 d3                	mov    %edx,%ebx
  800aed:	89 d7                	mov    %edx,%edi
  800aef:	89 d6                	mov    %edx,%esi
  800af1:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af3:	5b                   	pop    %ebx
  800af4:	5e                   	pop    %esi
  800af5:	5f                   	pop    %edi
  800af6:	5d                   	pop    %ebp
  800af7:	c3                   	ret    

00800af8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	57                   	push   %edi
  800afc:	56                   	push   %esi
  800afd:	53                   	push   %ebx
  800afe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b01:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b06:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0e:	89 cb                	mov    %ecx,%ebx
  800b10:	89 cf                	mov    %ecx,%edi
  800b12:	89 ce                	mov    %ecx,%esi
  800b14:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b16:	85 c0                	test   %eax,%eax
  800b18:	7e 17                	jle    800b31 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1a:	83 ec 0c             	sub    $0xc,%esp
  800b1d:	50                   	push   %eax
  800b1e:	6a 03                	push   $0x3
  800b20:	68 a4 16 80 00       	push   $0x8016a4
  800b25:	6a 23                	push   $0x23
  800b27:	68 c1 16 80 00       	push   $0x8016c1
  800b2c:	e8 77 05 00 00       	call   8010a8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800b3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b44:	b8 02 00 00 00       	mov    $0x2,%eax
  800b49:	89 d1                	mov    %edx,%ecx
  800b4b:	89 d3                	mov    %edx,%ebx
  800b4d:	89 d7                	mov    %edx,%edi
  800b4f:	89 d6                	mov    %edx,%esi
  800b51:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <sys_yield>:

void
sys_yield(void)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b63:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b68:	89 d1                	mov    %edx,%ecx
  800b6a:	89 d3                	mov    %edx,%ebx
  800b6c:	89 d7                	mov    %edx,%edi
  800b6e:	89 d6                	mov    %edx,%esi
  800b70:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b72:	5b                   	pop    %ebx
  800b73:	5e                   	pop    %esi
  800b74:	5f                   	pop    %edi
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	57                   	push   %edi
  800b7b:	56                   	push   %esi
  800b7c:	53                   	push   %ebx
  800b7d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b80:	be 00 00 00 00       	mov    $0x0,%esi
  800b85:	b8 04 00 00 00       	mov    $0x4,%eax
  800b8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b93:	89 f7                	mov    %esi,%edi
  800b95:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b97:	85 c0                	test   %eax,%eax
  800b99:	7e 17                	jle    800bb2 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9b:	83 ec 0c             	sub    $0xc,%esp
  800b9e:	50                   	push   %eax
  800b9f:	6a 04                	push   $0x4
  800ba1:	68 a4 16 80 00       	push   $0x8016a4
  800ba6:	6a 23                	push   $0x23
  800ba8:	68 c1 16 80 00       	push   $0x8016c1
  800bad:	e8 f6 04 00 00       	call   8010a8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
  800bc0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc3:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd4:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	7e 17                	jle    800bf4 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdd:	83 ec 0c             	sub    $0xc,%esp
  800be0:	50                   	push   %eax
  800be1:	6a 05                	push   $0x5
  800be3:	68 a4 16 80 00       	push   $0x8016a4
  800be8:	6a 23                	push   $0x23
  800bea:	68 c1 16 80 00       	push   $0x8016c1
  800bef:	e8 b4 04 00 00       	call   8010a8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c12:	8b 55 08             	mov    0x8(%ebp),%edx
  800c15:	89 df                	mov    %ebx,%edi
  800c17:	89 de                	mov    %ebx,%esi
  800c19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	7e 17                	jle    800c36 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1f:	83 ec 0c             	sub    $0xc,%esp
  800c22:	50                   	push   %eax
  800c23:	6a 06                	push   $0x6
  800c25:	68 a4 16 80 00       	push   $0x8016a4
  800c2a:	6a 23                	push   $0x23
  800c2c:	68 c1 16 80 00       	push   $0x8016c1
  800c31:	e8 72 04 00 00       	call   8010a8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c47:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	89 df                	mov    %ebx,%edi
  800c59:	89 de                	mov    %ebx,%esi
  800c5b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5d:	85 c0                	test   %eax,%eax
  800c5f:	7e 17                	jle    800c78 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c61:	83 ec 0c             	sub    $0xc,%esp
  800c64:	50                   	push   %eax
  800c65:	6a 08                	push   $0x8
  800c67:	68 a4 16 80 00       	push   $0x8016a4
  800c6c:	6a 23                	push   $0x23
  800c6e:	68 c1 16 80 00       	push   $0x8016c1
  800c73:	e8 30 04 00 00       	call   8010a8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
  800c86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8e:	b8 09 00 00 00       	mov    $0x9,%eax
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	89 df                	mov    %ebx,%edi
  800c9b:	89 de                	mov    %ebx,%esi
  800c9d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	7e 17                	jle    800cba <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	50                   	push   %eax
  800ca7:	6a 09                	push   $0x9
  800ca9:	68 a4 16 80 00       	push   $0x8016a4
  800cae:	6a 23                	push   $0x23
  800cb0:	68 c1 16 80 00       	push   $0x8016c1
  800cb5:	e8 ee 03 00 00       	call   8010a8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc8:	be 00 00 00 00       	mov    $0x0,%esi
  800ccd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cde:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
  800ceb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	89 cb                	mov    %ecx,%ebx
  800cfd:	89 cf                	mov    %ecx,%edi
  800cff:	89 ce                	mov    %ecx,%esi
  800d01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7e 17                	jle    800d1e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d07:	83 ec 0c             	sub    $0xc,%esp
  800d0a:	50                   	push   %eax
  800d0b:	6a 0c                	push   $0xc
  800d0d:	68 a4 16 80 00       	push   $0x8016a4
  800d12:	6a 23                	push   $0x23
  800d14:	68 c1 16 80 00       	push   $0x8016c1
  800d19:	e8 8a 03 00 00       	call   8010a8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	53                   	push   %ebx
  800d2a:	83 ec 04             	sub    $0x4,%esp
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
	
	void *fault_addr = (void *) utf->utf_fault_va;
  800d30:	8b 02                	mov    (%edx),%eax
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800d32:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800d36:	74 2e                	je     800d66 <pgfault+0x40>
			(err & FEC_WR) && (uvpd[PDX(fault_addr)] & PTE_P) && 
  800d38:	89 c2                	mov    %eax,%edx
  800d3a:	c1 ea 16             	shr    $0x16,%edx
  800d3d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d44:	f6 c2 01             	test   $0x1,%dl
  800d47:	74 1d                	je     800d66 <pgfault+0x40>
			(uvpt[PGNUM(fault_addr)] & PTE_P) && (uvpt[PGNUM(fault_addr)] & PTE_COW)))
  800d49:	89 c2                	mov    %eax,%edx
  800d4b:	c1 ea 0c             	shr    $0xc,%edx
  800d4e:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
			(err & FEC_WR) && (uvpd[PDX(fault_addr)] & PTE_P) && 
  800d55:	f6 c1 01             	test   $0x1,%cl
  800d58:	74 0c                	je     800d66 <pgfault+0x40>
			(uvpt[PGNUM(fault_addr)] & PTE_P) && (uvpt[PGNUM(fault_addr)] & PTE_COW)))
  800d5a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800d61:	f6 c6 08             	test   $0x8,%dh
  800d64:	75 14                	jne    800d7a <pgfault+0x54>
			(err & FEC_WR) && (uvpd[PDX(fault_addr)] & PTE_P) && 
			(uvpt[PGNUM(fault_addr)] & PTE_P) && (uvpt[PGNUM(fault_addr)] & PTE_COW)))
		panic("copy-on-write not there");
  800d66:	83 ec 04             	sub    $0x4,%esp
  800d69:	68 cf 16 80 00       	push   $0x8016cf
  800d6e:	6a 20                	push   $0x20
  800d70:	68 e7 16 80 00       	push   $0x8016e7
  800d75:	e8 2e 03 00 00       	call   8010a8 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	fault_addr = ROUNDDOWN(fault_addr, PGSIZE);
  800d7a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d7f:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800d81:	83 ec 04             	sub    $0x4,%esp
  800d84:	6a 07                	push   $0x7
  800d86:	68 00 f0 7f 00       	push   $0x7ff000
  800d8b:	6a 00                	push   $0x0
  800d8d:	e8 e5 fd ff ff       	call   800b77 <sys_page_alloc>
  800d92:	83 c4 10             	add    $0x10,%esp
  800d95:	85 c0                	test   %eax,%eax
  800d97:	79 14                	jns    800dad <pgfault+0x87>
		panic("page alloc failed");
  800d99:	83 ec 04             	sub    $0x4,%esp
  800d9c:	68 f2 16 80 00       	push   $0x8016f2
  800da1:	6a 2c                	push   $0x2c
  800da3:	68 e7 16 80 00       	push   $0x8016e7
  800da8:	e8 fb 02 00 00       	call   8010a8 <_panic>
	memcpy(PFTEMP, fault_addr, PGSIZE);
  800dad:	83 ec 04             	sub    $0x4,%esp
  800db0:	68 00 10 00 00       	push   $0x1000
  800db5:	53                   	push   %ebx
  800db6:	68 00 f0 7f 00       	push   $0x7ff000
  800dbb:	e8 ae fb ff ff       	call   80096e <memcpy>
	if (sys_page_map(0, PFTEMP, 0, fault_addr, PTE_W|PTE_U|PTE_P) < 0)
  800dc0:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dc7:	53                   	push   %ebx
  800dc8:	6a 00                	push   $0x0
  800dca:	68 00 f0 7f 00       	push   $0x7ff000
  800dcf:	6a 00                	push   $0x0
  800dd1:	e8 e4 fd ff ff       	call   800bba <sys_page_map>
  800dd6:	83 c4 20             	add    $0x20,%esp
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	79 14                	jns    800df1 <pgfault+0xcb>
		panic("pagemap failed");
  800ddd:	83 ec 04             	sub    $0x4,%esp
  800de0:	68 04 17 80 00       	push   $0x801704
  800de5:	6a 2f                	push   $0x2f
  800de7:	68 e7 16 80 00       	push   $0x8016e7
  800dec:	e8 b7 02 00 00       	call   8010a8 <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  800df1:	83 ec 08             	sub    $0x8,%esp
  800df4:	68 00 f0 7f 00       	push   $0x7ff000
  800df9:	6a 00                	push   $0x0
  800dfb:	e8 fc fd ff ff       	call   800bfc <sys_page_unmap>
  800e00:	83 c4 10             	add    $0x10,%esp
  800e03:	85 c0                	test   %eax,%eax
  800e05:	79 14                	jns    800e1b <pgfault+0xf5>
		panic("page unmap failed");
  800e07:	83 ec 04             	sub    $0x4,%esp
  800e0a:	68 13 17 80 00       	push   $0x801713
  800e0f:	6a 31                	push   $0x31
  800e11:	68 e7 16 80 00       	push   $0x8016e7
  800e16:	e8 8d 02 00 00       	call   8010a8 <_panic>
	//return;
}
  800e1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e1e:	c9                   	leave  
  800e1f:	c3                   	ret    

00800e20 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	57                   	push   %edi
  800e24:	56                   	push   %esi
  800e25:	53                   	push   %ebx
  800e26:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800e29:	68 26 0d 80 00       	push   $0x800d26
  800e2e:	e8 bb 02 00 00       	call   8010ee <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e33:	b8 07 00 00 00       	mov    $0x7,%eax
  800e38:	cd 30                	int    $0x30
  800e3a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t ad;
	envid = sys_exofork();
	if (envid == 0) {
  800e3d:	83 c4 10             	add    $0x10,%esp
  800e40:	85 c0                	test   %eax,%eax
  800e42:	75 21                	jne    800e65 <fork+0x45>
		
		thisenv = &envs[ENVX(sys_getenvid())];
  800e44:	e8 f0 fc ff ff       	call   800b39 <sys_getenvid>
  800e49:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e4e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e51:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e56:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800e5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e60:	e9 5a 01 00 00       	jmp    800fbf <fork+0x19f>
  800e65:	89 c7                	mov    %eax,%edi
	}
	
	if (envid < 0)
  800e67:	85 c0                	test   %eax,%eax
  800e69:	79 12                	jns    800e7d <fork+0x5d>
		panic("sys_exofork: %e", envid);
  800e6b:	50                   	push   %eax
  800e6c:	68 25 17 80 00       	push   $0x801725
  800e71:	6a 71                	push   $0x71
  800e73:	68 e7 16 80 00       	push   $0x8016e7
  800e78:	e8 2b 02 00 00       	call   8010a8 <_panic>
  800e7d:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (ad = 0; ad < USTACKTOP; ad += PGSIZE)
		if ((uvpd[PDX(ad)] & PTE_P) && (uvpt[PGNUM(ad)] & PTE_P)
  800e82:	89 d8                	mov    %ebx,%eax
  800e84:	c1 e8 16             	shr    $0x16,%eax
  800e87:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e8e:	a8 01                	test   $0x1,%al
  800e90:	0f 84 b3 00 00 00    	je     800f49 <fork+0x129>
  800e96:	89 d8                	mov    %ebx,%eax
  800e98:	c1 e8 0c             	shr    $0xc,%eax
  800e9b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ea2:	f6 c2 01             	test   $0x1,%dl
  800ea5:	0f 84 9e 00 00 00    	je     800f49 <fork+0x129>
			&& (uvpt[PGNUM(ad)] & PTE_U)) {
  800eab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eb2:	f6 c2 04             	test   $0x4,%dl
  800eb5:	0f 84 8e 00 00 00    	je     800f49 <fork+0x129>
duppage(envid_t envid, unsigned pn)
{
	//int r;
	// LAB 4: Your code here.
	
	void *vir_addr = (void*) (pn*PGSIZE);
  800ebb:	89 c6                	mov    %eax,%esi
  800ebd:	c1 e6 0c             	shl    $0xc,%esi
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800ec0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ec7:	f6 c2 02             	test   $0x2,%dl
  800eca:	75 0c                	jne    800ed8 <fork+0xb8>
  800ecc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ed3:	f6 c4 08             	test   $0x8,%ah
  800ed6:	74 5d                	je     800f35 <fork+0x115>
		if (sys_page_map(0, vir_addr, envid, vir_addr, PTE_COW|PTE_U|PTE_P) < 0)
  800ed8:	83 ec 0c             	sub    $0xc,%esp
  800edb:	68 05 08 00 00       	push   $0x805
  800ee0:	56                   	push   %esi
  800ee1:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ee4:	56                   	push   %esi
  800ee5:	6a 00                	push   $0x0
  800ee7:	e8 ce fc ff ff       	call   800bba <sys_page_map>
  800eec:	83 c4 20             	add    $0x20,%esp
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	79 14                	jns    800f07 <fork+0xe7>
			panic("page map failed");
  800ef3:	83 ec 04             	sub    $0x4,%esp
  800ef6:	68 35 17 80 00       	push   $0x801735
  800efb:	6a 49                	push   $0x49
  800efd:	68 e7 16 80 00       	push   $0x8016e7
  800f02:	e8 a1 01 00 00       	call   8010a8 <_panic>
		if (sys_page_map(0, vir_addr, 0, vir_addr, PTE_COW|PTE_U|PTE_P) < 0)
  800f07:	83 ec 0c             	sub    $0xc,%esp
  800f0a:	68 05 08 00 00       	push   $0x805
  800f0f:	56                   	push   %esi
  800f10:	6a 00                	push   $0x0
  800f12:	56                   	push   %esi
  800f13:	6a 00                	push   $0x0
  800f15:	e8 a0 fc ff ff       	call   800bba <sys_page_map>
  800f1a:	83 c4 20             	add    $0x20,%esp
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	79 28                	jns    800f49 <fork+0x129>
			panic("page map failed");
  800f21:	83 ec 04             	sub    $0x4,%esp
  800f24:	68 35 17 80 00       	push   $0x801735
  800f29:	6a 4b                	push   $0x4b
  800f2b:	68 e7 16 80 00       	push   $0x8016e7
  800f30:	e8 73 01 00 00       	call   8010a8 <_panic>
	} else sys_page_map(0, vir_addr, envid, vir_addr, PTE_U|PTE_P);
  800f35:	83 ec 0c             	sub    $0xc,%esp
  800f38:	6a 05                	push   $0x5
  800f3a:	56                   	push   %esi
  800f3b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f3e:	56                   	push   %esi
  800f3f:	6a 00                	push   $0x0
  800f41:	e8 74 fc ff ff       	call   800bba <sys_page_map>
  800f46:	83 c4 20             	add    $0x20,%esp
	}
	
	if (envid < 0)
		panic("sys_exofork: %e", envid);

	for (ad = 0; ad < USTACKTOP; ad += PGSIZE)
  800f49:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f4f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f55:	0f 85 27 ff ff ff    	jne    800e82 <fork+0x62>
			
		}
	


	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  800f5b:	83 ec 04             	sub    $0x4,%esp
  800f5e:	6a 07                	push   $0x7
  800f60:	68 00 f0 bf ee       	push   $0xeebff000
  800f65:	57                   	push   %edi
  800f66:	e8 0c fc ff ff       	call   800b77 <sys_page_alloc>
  800f6b:	83 c4 10             	add    $0x10,%esp
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	79 14                	jns    800f86 <fork+0x166>
		panic("alloc failed");
  800f72:	83 ec 04             	sub    $0x4,%esp
  800f75:	68 f7 16 80 00       	push   $0x8016f7
  800f7a:	6a 7e                	push   $0x7e
  800f7c:	68 e7 16 80 00       	push   $0x8016e7
  800f81:	e8 22 01 00 00       	call   8010a8 <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800f86:	83 ec 08             	sub    $0x8,%esp
  800f89:	68 5d 11 80 00       	push   $0x80115d
  800f8e:	57                   	push   %edi
  800f8f:	e8 ec fc ff ff       	call   800c80 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  800f94:	83 c4 08             	add    $0x8,%esp
  800f97:	6a 02                	push   $0x2
  800f99:	57                   	push   %edi
  800f9a:	e8 9f fc ff ff       	call   800c3e <sys_env_set_status>
  800f9f:	83 c4 10             	add    $0x10,%esp
  800fa2:	85 c0                	test   %eax,%eax
  800fa4:	79 17                	jns    800fbd <fork+0x19d>
		panic("set status failed");
  800fa6:	83 ec 04             	sub    $0x4,%esp
  800fa9:	68 45 17 80 00       	push   $0x801745
  800fae:	68 83 00 00 00       	push   $0x83
  800fb3:	68 e7 16 80 00       	push   $0x8016e7
  800fb8:	e8 eb 00 00 00       	call   8010a8 <_panic>

	return envid;
  800fbd:	89 f8                	mov    %edi,%eax
	
}
  800fbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc2:	5b                   	pop    %ebx
  800fc3:	5e                   	pop    %esi
  800fc4:	5f                   	pop    %edi
  800fc5:	5d                   	pop    %ebp
  800fc6:	c3                   	ret    

00800fc7 <sfork>:

int
sfork(void)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fcd:	68 57 17 80 00       	push   $0x801757
  800fd2:	68 8c 00 00 00       	push   $0x8c
  800fd7:	68 e7 16 80 00       	push   $0x8016e7
  800fdc:	e8 c7 00 00 00       	call   8010a8 <_panic>

00800fe1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	56                   	push   %esi
  800fe5:	53                   	push   %ebx
  800fe6:	8b 75 08             	mov    0x8(%ebp),%esi
  800fe9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  800fef:	85 f6                	test   %esi,%esi
  800ff1:	74 06                	je     800ff9 <ipc_recv+0x18>
  800ff3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  800ff9:	85 db                	test   %ebx,%ebx
  800ffb:	74 06                	je     801003 <ipc_recv+0x22>
  800ffd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801003:	85 c0                	test   %eax,%eax
  801005:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80100a:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  80100d:	83 ec 0c             	sub    $0xc,%esp
  801010:	50                   	push   %eax
  801011:	e8 cf fc ff ff       	call   800ce5 <sys_ipc_recv>
	if (ret) return ret;
  801016:	83 c4 10             	add    $0x10,%esp
  801019:	85 c0                	test   %eax,%eax
  80101b:	75 24                	jne    801041 <ipc_recv+0x60>
	if (from_env_store)
  80101d:	85 f6                	test   %esi,%esi
  80101f:	74 0a                	je     80102b <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801021:	a1 04 20 80 00       	mov    0x802004,%eax
  801026:	8b 40 74             	mov    0x74(%eax),%eax
  801029:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  80102b:	85 db                	test   %ebx,%ebx
  80102d:	74 0a                	je     801039 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  80102f:	a1 04 20 80 00       	mov    0x802004,%eax
  801034:	8b 40 78             	mov    0x78(%eax),%eax
  801037:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801039:	a1 04 20 80 00       	mov    0x802004,%eax
  80103e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801041:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801044:	5b                   	pop    %ebx
  801045:	5e                   	pop    %esi
  801046:	5d                   	pop    %ebp
  801047:	c3                   	ret    

00801048 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	83 ec 08             	sub    $0x8,%esp
  80104e:	8b 45 10             	mov    0x10(%ebp),%eax
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801051:	85 c0                	test   %eax,%eax
  801053:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801058:	0f 44 c2             	cmove  %edx,%eax
	int success = sys_ipc_try_send(to_env, val, pg, perm) ;
  80105b:	ff 75 14             	pushl  0x14(%ebp)
  80105e:	50                   	push   %eax
  80105f:	ff 75 0c             	pushl  0xc(%ebp)
  801062:	ff 75 08             	pushl  0x8(%ebp)
  801065:	e8 58 fc ff ff       	call   800cc2 <sys_ipc_try_send>
		if (success == 0) break;
		if (success != -E_IPC_NOT_RECV) 
	panic("receive fail");
		sys_yield();
	}
}
  80106a:	83 c4 10             	add    $0x10,%esp
  80106d:	c9                   	leave  
  80106e:	c3                   	ret    

0080106f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801075:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80107a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80107d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801083:	8b 52 50             	mov    0x50(%edx),%edx
  801086:	39 ca                	cmp    %ecx,%edx
  801088:	75 0d                	jne    801097 <ipc_find_env+0x28>
			return envs[i].env_id;
  80108a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80108d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801092:	8b 40 48             	mov    0x48(%eax),%eax
  801095:	eb 0f                	jmp    8010a6 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801097:	83 c0 01             	add    $0x1,%eax
  80109a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80109f:	75 d9                	jne    80107a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8010a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010a6:	5d                   	pop    %ebp
  8010a7:	c3                   	ret    

008010a8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010a8:	55                   	push   %ebp
  8010a9:	89 e5                	mov    %esp,%ebp
  8010ab:	56                   	push   %esi
  8010ac:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010ad:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010b0:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8010b6:	e8 7e fa ff ff       	call   800b39 <sys_getenvid>
  8010bb:	83 ec 0c             	sub    $0xc,%esp
  8010be:	ff 75 0c             	pushl  0xc(%ebp)
  8010c1:	ff 75 08             	pushl  0x8(%ebp)
  8010c4:	56                   	push   %esi
  8010c5:	50                   	push   %eax
  8010c6:	68 70 17 80 00       	push   $0x801770
  8010cb:	e8 d9 f0 ff ff       	call   8001a9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010d0:	83 c4 18             	add    $0x18,%esp
  8010d3:	53                   	push   %ebx
  8010d4:	ff 75 10             	pushl  0x10(%ebp)
  8010d7:	e8 7c f0 ff ff       	call   800158 <vcprintf>
	cprintf("\n");
  8010dc:	c7 04 24 47 14 80 00 	movl   $0x801447,(%esp)
  8010e3:	e8 c1 f0 ff ff       	call   8001a9 <cprintf>
  8010e8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010eb:	cc                   	int3   
  8010ec:	eb fd                	jmp    8010eb <_panic+0x43>

008010ee <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	83 ec 08             	sub    $0x8,%esp
	// int r;

	if (_pgfault_handler == 0) {
  8010f4:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8010fb:	75 2c                	jne    801129 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  8010fd:	83 ec 04             	sub    $0x4,%esp
  801100:	6a 07                	push   $0x7
  801102:	68 00 f0 bf ee       	push   $0xeebff000
  801107:	6a 00                	push   $0x0
  801109:	e8 69 fa ff ff       	call   800b77 <sys_page_alloc>
  80110e:	83 c4 10             	add    $0x10,%esp
  801111:	85 c0                	test   %eax,%eax
  801113:	79 14                	jns    801129 <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");;
  801115:	83 ec 04             	sub    $0x4,%esp
  801118:	68 94 17 80 00       	push   $0x801794
  80111d:	6a 21                	push   $0x21
  80111f:	68 f8 17 80 00       	push   $0x8017f8
  801124:	e8 7f ff ff ff       	call   8010a8 <_panic>
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801129:	8b 45 08             	mov    0x8(%ebp),%eax
  80112c:	a3 0c 20 80 00       	mov    %eax,0x80200c
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801131:	83 ec 08             	sub    $0x8,%esp
  801134:	68 5d 11 80 00       	push   $0x80115d
  801139:	6a 00                	push   $0x0
  80113b:	e8 40 fb ff ff       	call   800c80 <sys_env_set_pgfault_upcall>
  801140:	83 c4 10             	add    $0x10,%esp
  801143:	85 c0                	test   %eax,%eax
  801145:	79 14                	jns    80115b <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801147:	83 ec 04             	sub    $0x4,%esp
  80114a:	68 c0 17 80 00       	push   $0x8017c0
  80114f:	6a 26                	push   $0x26
  801151:	68 f8 17 80 00       	push   $0x8017f8
  801156:	e8 4d ff ff ff       	call   8010a8 <_panic>
}
  80115b:	c9                   	leave  
  80115c:	c3                   	ret    

0080115d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80115d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80115e:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801163:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801165:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx #trap-time eip
  801168:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)
  80116c:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax #trap-time esp-4
  801171:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)
  801175:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp
  801177:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  80117a:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp #eip
  80117b:	83 c4 04             	add    $0x4,%esp
	popfl
  80117e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80117f:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801180:	c3                   	ret    
  801181:	66 90                	xchg   %ax,%ax
  801183:	66 90                	xchg   %ax,%ax
  801185:	66 90                	xchg   %ax,%ax
  801187:	66 90                	xchg   %ax,%ax
  801189:	66 90                	xchg   %ax,%ax
  80118b:	66 90                	xchg   %ax,%ax
  80118d:	66 90                	xchg   %ax,%ax
  80118f:	90                   	nop

00801190 <__udivdi3>:
  801190:	55                   	push   %ebp
  801191:	57                   	push   %edi
  801192:	56                   	push   %esi
  801193:	53                   	push   %ebx
  801194:	83 ec 1c             	sub    $0x1c,%esp
  801197:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80119b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80119f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8011a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8011a7:	85 f6                	test   %esi,%esi
  8011a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011ad:	89 ca                	mov    %ecx,%edx
  8011af:	89 f8                	mov    %edi,%eax
  8011b1:	75 3d                	jne    8011f0 <__udivdi3+0x60>
  8011b3:	39 cf                	cmp    %ecx,%edi
  8011b5:	0f 87 c5 00 00 00    	ja     801280 <__udivdi3+0xf0>
  8011bb:	85 ff                	test   %edi,%edi
  8011bd:	89 fd                	mov    %edi,%ebp
  8011bf:	75 0b                	jne    8011cc <__udivdi3+0x3c>
  8011c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8011c6:	31 d2                	xor    %edx,%edx
  8011c8:	f7 f7                	div    %edi
  8011ca:	89 c5                	mov    %eax,%ebp
  8011cc:	89 c8                	mov    %ecx,%eax
  8011ce:	31 d2                	xor    %edx,%edx
  8011d0:	f7 f5                	div    %ebp
  8011d2:	89 c1                	mov    %eax,%ecx
  8011d4:	89 d8                	mov    %ebx,%eax
  8011d6:	89 cf                	mov    %ecx,%edi
  8011d8:	f7 f5                	div    %ebp
  8011da:	89 c3                	mov    %eax,%ebx
  8011dc:	89 d8                	mov    %ebx,%eax
  8011de:	89 fa                	mov    %edi,%edx
  8011e0:	83 c4 1c             	add    $0x1c,%esp
  8011e3:	5b                   	pop    %ebx
  8011e4:	5e                   	pop    %esi
  8011e5:	5f                   	pop    %edi
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    
  8011e8:	90                   	nop
  8011e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011f0:	39 ce                	cmp    %ecx,%esi
  8011f2:	77 74                	ja     801268 <__udivdi3+0xd8>
  8011f4:	0f bd fe             	bsr    %esi,%edi
  8011f7:	83 f7 1f             	xor    $0x1f,%edi
  8011fa:	0f 84 98 00 00 00    	je     801298 <__udivdi3+0x108>
  801200:	bb 20 00 00 00       	mov    $0x20,%ebx
  801205:	89 f9                	mov    %edi,%ecx
  801207:	89 c5                	mov    %eax,%ebp
  801209:	29 fb                	sub    %edi,%ebx
  80120b:	d3 e6                	shl    %cl,%esi
  80120d:	89 d9                	mov    %ebx,%ecx
  80120f:	d3 ed                	shr    %cl,%ebp
  801211:	89 f9                	mov    %edi,%ecx
  801213:	d3 e0                	shl    %cl,%eax
  801215:	09 ee                	or     %ebp,%esi
  801217:	89 d9                	mov    %ebx,%ecx
  801219:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80121d:	89 d5                	mov    %edx,%ebp
  80121f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801223:	d3 ed                	shr    %cl,%ebp
  801225:	89 f9                	mov    %edi,%ecx
  801227:	d3 e2                	shl    %cl,%edx
  801229:	89 d9                	mov    %ebx,%ecx
  80122b:	d3 e8                	shr    %cl,%eax
  80122d:	09 c2                	or     %eax,%edx
  80122f:	89 d0                	mov    %edx,%eax
  801231:	89 ea                	mov    %ebp,%edx
  801233:	f7 f6                	div    %esi
  801235:	89 d5                	mov    %edx,%ebp
  801237:	89 c3                	mov    %eax,%ebx
  801239:	f7 64 24 0c          	mull   0xc(%esp)
  80123d:	39 d5                	cmp    %edx,%ebp
  80123f:	72 10                	jb     801251 <__udivdi3+0xc1>
  801241:	8b 74 24 08          	mov    0x8(%esp),%esi
  801245:	89 f9                	mov    %edi,%ecx
  801247:	d3 e6                	shl    %cl,%esi
  801249:	39 c6                	cmp    %eax,%esi
  80124b:	73 07                	jae    801254 <__udivdi3+0xc4>
  80124d:	39 d5                	cmp    %edx,%ebp
  80124f:	75 03                	jne    801254 <__udivdi3+0xc4>
  801251:	83 eb 01             	sub    $0x1,%ebx
  801254:	31 ff                	xor    %edi,%edi
  801256:	89 d8                	mov    %ebx,%eax
  801258:	89 fa                	mov    %edi,%edx
  80125a:	83 c4 1c             	add    $0x1c,%esp
  80125d:	5b                   	pop    %ebx
  80125e:	5e                   	pop    %esi
  80125f:	5f                   	pop    %edi
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    
  801262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801268:	31 ff                	xor    %edi,%edi
  80126a:	31 db                	xor    %ebx,%ebx
  80126c:	89 d8                	mov    %ebx,%eax
  80126e:	89 fa                	mov    %edi,%edx
  801270:	83 c4 1c             	add    $0x1c,%esp
  801273:	5b                   	pop    %ebx
  801274:	5e                   	pop    %esi
  801275:	5f                   	pop    %edi
  801276:	5d                   	pop    %ebp
  801277:	c3                   	ret    
  801278:	90                   	nop
  801279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801280:	89 d8                	mov    %ebx,%eax
  801282:	f7 f7                	div    %edi
  801284:	31 ff                	xor    %edi,%edi
  801286:	89 c3                	mov    %eax,%ebx
  801288:	89 d8                	mov    %ebx,%eax
  80128a:	89 fa                	mov    %edi,%edx
  80128c:	83 c4 1c             	add    $0x1c,%esp
  80128f:	5b                   	pop    %ebx
  801290:	5e                   	pop    %esi
  801291:	5f                   	pop    %edi
  801292:	5d                   	pop    %ebp
  801293:	c3                   	ret    
  801294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801298:	39 ce                	cmp    %ecx,%esi
  80129a:	72 0c                	jb     8012a8 <__udivdi3+0x118>
  80129c:	31 db                	xor    %ebx,%ebx
  80129e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8012a2:	0f 87 34 ff ff ff    	ja     8011dc <__udivdi3+0x4c>
  8012a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8012ad:	e9 2a ff ff ff       	jmp    8011dc <__udivdi3+0x4c>
  8012b2:	66 90                	xchg   %ax,%ax
  8012b4:	66 90                	xchg   %ax,%ax
  8012b6:	66 90                	xchg   %ax,%ax
  8012b8:	66 90                	xchg   %ax,%ax
  8012ba:	66 90                	xchg   %ax,%ax
  8012bc:	66 90                	xchg   %ax,%ax
  8012be:	66 90                	xchg   %ax,%ax

008012c0 <__umoddi3>:
  8012c0:	55                   	push   %ebp
  8012c1:	57                   	push   %edi
  8012c2:	56                   	push   %esi
  8012c3:	53                   	push   %ebx
  8012c4:	83 ec 1c             	sub    $0x1c,%esp
  8012c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8012cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8012cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8012d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012d7:	85 d2                	test   %edx,%edx
  8012d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8012dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012e1:	89 f3                	mov    %esi,%ebx
  8012e3:	89 3c 24             	mov    %edi,(%esp)
  8012e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012ea:	75 1c                	jne    801308 <__umoddi3+0x48>
  8012ec:	39 f7                	cmp    %esi,%edi
  8012ee:	76 50                	jbe    801340 <__umoddi3+0x80>
  8012f0:	89 c8                	mov    %ecx,%eax
  8012f2:	89 f2                	mov    %esi,%edx
  8012f4:	f7 f7                	div    %edi
  8012f6:	89 d0                	mov    %edx,%eax
  8012f8:	31 d2                	xor    %edx,%edx
  8012fa:	83 c4 1c             	add    $0x1c,%esp
  8012fd:	5b                   	pop    %ebx
  8012fe:	5e                   	pop    %esi
  8012ff:	5f                   	pop    %edi
  801300:	5d                   	pop    %ebp
  801301:	c3                   	ret    
  801302:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801308:	39 f2                	cmp    %esi,%edx
  80130a:	89 d0                	mov    %edx,%eax
  80130c:	77 52                	ja     801360 <__umoddi3+0xa0>
  80130e:	0f bd ea             	bsr    %edx,%ebp
  801311:	83 f5 1f             	xor    $0x1f,%ebp
  801314:	75 5a                	jne    801370 <__umoddi3+0xb0>
  801316:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80131a:	0f 82 e0 00 00 00    	jb     801400 <__umoddi3+0x140>
  801320:	39 0c 24             	cmp    %ecx,(%esp)
  801323:	0f 86 d7 00 00 00    	jbe    801400 <__umoddi3+0x140>
  801329:	8b 44 24 08          	mov    0x8(%esp),%eax
  80132d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801331:	83 c4 1c             	add    $0x1c,%esp
  801334:	5b                   	pop    %ebx
  801335:	5e                   	pop    %esi
  801336:	5f                   	pop    %edi
  801337:	5d                   	pop    %ebp
  801338:	c3                   	ret    
  801339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801340:	85 ff                	test   %edi,%edi
  801342:	89 fd                	mov    %edi,%ebp
  801344:	75 0b                	jne    801351 <__umoddi3+0x91>
  801346:	b8 01 00 00 00       	mov    $0x1,%eax
  80134b:	31 d2                	xor    %edx,%edx
  80134d:	f7 f7                	div    %edi
  80134f:	89 c5                	mov    %eax,%ebp
  801351:	89 f0                	mov    %esi,%eax
  801353:	31 d2                	xor    %edx,%edx
  801355:	f7 f5                	div    %ebp
  801357:	89 c8                	mov    %ecx,%eax
  801359:	f7 f5                	div    %ebp
  80135b:	89 d0                	mov    %edx,%eax
  80135d:	eb 99                	jmp    8012f8 <__umoddi3+0x38>
  80135f:	90                   	nop
  801360:	89 c8                	mov    %ecx,%eax
  801362:	89 f2                	mov    %esi,%edx
  801364:	83 c4 1c             	add    $0x1c,%esp
  801367:	5b                   	pop    %ebx
  801368:	5e                   	pop    %esi
  801369:	5f                   	pop    %edi
  80136a:	5d                   	pop    %ebp
  80136b:	c3                   	ret    
  80136c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801370:	8b 34 24             	mov    (%esp),%esi
  801373:	bf 20 00 00 00       	mov    $0x20,%edi
  801378:	89 e9                	mov    %ebp,%ecx
  80137a:	29 ef                	sub    %ebp,%edi
  80137c:	d3 e0                	shl    %cl,%eax
  80137e:	89 f9                	mov    %edi,%ecx
  801380:	89 f2                	mov    %esi,%edx
  801382:	d3 ea                	shr    %cl,%edx
  801384:	89 e9                	mov    %ebp,%ecx
  801386:	09 c2                	or     %eax,%edx
  801388:	89 d8                	mov    %ebx,%eax
  80138a:	89 14 24             	mov    %edx,(%esp)
  80138d:	89 f2                	mov    %esi,%edx
  80138f:	d3 e2                	shl    %cl,%edx
  801391:	89 f9                	mov    %edi,%ecx
  801393:	89 54 24 04          	mov    %edx,0x4(%esp)
  801397:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80139b:	d3 e8                	shr    %cl,%eax
  80139d:	89 e9                	mov    %ebp,%ecx
  80139f:	89 c6                	mov    %eax,%esi
  8013a1:	d3 e3                	shl    %cl,%ebx
  8013a3:	89 f9                	mov    %edi,%ecx
  8013a5:	89 d0                	mov    %edx,%eax
  8013a7:	d3 e8                	shr    %cl,%eax
  8013a9:	89 e9                	mov    %ebp,%ecx
  8013ab:	09 d8                	or     %ebx,%eax
  8013ad:	89 d3                	mov    %edx,%ebx
  8013af:	89 f2                	mov    %esi,%edx
  8013b1:	f7 34 24             	divl   (%esp)
  8013b4:	89 d6                	mov    %edx,%esi
  8013b6:	d3 e3                	shl    %cl,%ebx
  8013b8:	f7 64 24 04          	mull   0x4(%esp)
  8013bc:	39 d6                	cmp    %edx,%esi
  8013be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013c2:	89 d1                	mov    %edx,%ecx
  8013c4:	89 c3                	mov    %eax,%ebx
  8013c6:	72 08                	jb     8013d0 <__umoddi3+0x110>
  8013c8:	75 11                	jne    8013db <__umoddi3+0x11b>
  8013ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8013ce:	73 0b                	jae    8013db <__umoddi3+0x11b>
  8013d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8013d4:	1b 14 24             	sbb    (%esp),%edx
  8013d7:	89 d1                	mov    %edx,%ecx
  8013d9:	89 c3                	mov    %eax,%ebx
  8013db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8013df:	29 da                	sub    %ebx,%edx
  8013e1:	19 ce                	sbb    %ecx,%esi
  8013e3:	89 f9                	mov    %edi,%ecx
  8013e5:	89 f0                	mov    %esi,%eax
  8013e7:	d3 e0                	shl    %cl,%eax
  8013e9:	89 e9                	mov    %ebp,%ecx
  8013eb:	d3 ea                	shr    %cl,%edx
  8013ed:	89 e9                	mov    %ebp,%ecx
  8013ef:	d3 ee                	shr    %cl,%esi
  8013f1:	09 d0                	or     %edx,%eax
  8013f3:	89 f2                	mov    %esi,%edx
  8013f5:	83 c4 1c             	add    $0x1c,%esp
  8013f8:	5b                   	pop    %ebx
  8013f9:	5e                   	pop    %esi
  8013fa:	5f                   	pop    %edi
  8013fb:	5d                   	pop    %ebp
  8013fc:	c3                   	ret    
  8013fd:	8d 76 00             	lea    0x0(%esi),%esi
  801400:	29 f9                	sub    %edi,%ecx
  801402:	19 d6                	sbb    %edx,%esi
  801404:	89 74 24 04          	mov    %esi,0x4(%esp)
  801408:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80140c:	e9 18 ff ff ff       	jmp    801329 <__umoddi3+0x69>
