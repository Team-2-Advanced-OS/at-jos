
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 54 01 00 00       	call   800185 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  80003e:	8d 5d f7             	lea    -0x9(%ebp),%ebx
  800041:	eb 6e                	jmp    8000b1 <num+0x7e>
		if (bol) {
  800043:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004a:	74 28                	je     800074 <num+0x41>
			printf("%5d ", ++line);
  80004c:	a1 00 40 80 00       	mov    0x804000,%eax
  800051:	83 c0 01             	add    $0x1,%eax
  800054:	a3 00 40 80 00       	mov    %eax,0x804000
  800059:	83 ec 08             	sub    $0x8,%esp
  80005c:	50                   	push   %eax
  80005d:	68 80 25 80 00       	push   $0x802580
  800062:	e8 e2 17 00 00       	call   801849 <printf>
			bol = 0;
  800067:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  80006e:	00 00 00 
  800071:	83 c4 10             	add    $0x10,%esp
		}
		if ((r = write(1, &c, 1)) != 1)
  800074:	83 ec 04             	sub    $0x4,%esp
  800077:	6a 01                	push   $0x1
  800079:	53                   	push   %ebx
  80007a:	6a 01                	push   $0x1
  80007c:	e8 50 12 00 00       	call   8012d1 <write>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	83 f8 01             	cmp    $0x1,%eax
  800087:	74 18                	je     8000a1 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	50                   	push   %eax
  80008d:	ff 75 0c             	pushl  0xc(%ebp)
  800090:	68 85 25 80 00       	push   $0x802585
  800095:	6a 13                	push   $0x13
  800097:	68 a0 25 80 00       	push   $0x8025a0
  80009c:	e8 44 01 00 00       	call   8001e5 <_panic>
		if (c == '\n')
  8000a1:	80 7d f7 0a          	cmpb   $0xa,-0x9(%ebp)
  8000a5:	75 0a                	jne    8000b1 <num+0x7e>
			bol = 1;
  8000a7:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000ae:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000b1:	83 ec 04             	sub    $0x4,%esp
  8000b4:	6a 01                	push   $0x1
  8000b6:	53                   	push   %ebx
  8000b7:	56                   	push   %esi
  8000b8:	e8 3a 11 00 00       	call   8011f7 <read>
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	85 c0                	test   %eax,%eax
  8000c2:	0f 8f 7b ff ff ff    	jg     800043 <num+0x10>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	79 18                	jns    8000e4 <num+0xb1>
		panic("error reading %s: %e", s, n);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	50                   	push   %eax
  8000d0:	ff 75 0c             	pushl  0xc(%ebp)
  8000d3:	68 ab 25 80 00       	push   $0x8025ab
  8000d8:	6a 18                	push   $0x18
  8000da:	68 a0 25 80 00       	push   $0x8025a0
  8000df:	e8 01 01 00 00       	call   8001e5 <_panic>
}
  8000e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 1c             	sub    $0x1c,%esp
	int f, i;

	binaryname = "num";
  8000f4:	c7 05 04 30 80 00 c0 	movl   $0x8025c0,0x803004
  8000fb:	25 80 00 
	if (argc == 1)
  8000fe:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800102:	74 0d                	je     800111 <umain+0x26>
  800104:	8b 45 0c             	mov    0xc(%ebp),%eax
  800107:	8d 58 04             	lea    0x4(%eax),%ebx
  80010a:	bf 01 00 00 00       	mov    $0x1,%edi
  80010f:	eb 62                	jmp    800173 <umain+0x88>
		num(0, "<stdin>");
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 c4 25 80 00       	push   $0x8025c4
  800119:	6a 00                	push   $0x0
  80011b:	e8 13 ff ff ff       	call   800033 <num>
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	eb 53                	jmp    800178 <umain+0x8d>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  800125:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 00                	push   $0x0
  80012d:	ff 33                	pushl  (%ebx)
  80012f:	e8 77 15 00 00       	call   8016ab <open>
  800134:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	85 c0                	test   %eax,%eax
  80013b:	79 1a                	jns    800157 <umain+0x6c>
				panic("can't open %s: %e", argv[i], f);
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	50                   	push   %eax
  800141:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800144:	ff 30                	pushl  (%eax)
  800146:	68 cc 25 80 00       	push   $0x8025cc
  80014b:	6a 27                	push   $0x27
  80014d:	68 a0 25 80 00       	push   $0x8025a0
  800152:	e8 8e 00 00 00       	call   8001e5 <_panic>
			else {
				num(f, argv[i]);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	ff 33                	pushl  (%ebx)
  80015c:	50                   	push   %eax
  80015d:	e8 d1 fe ff ff       	call   800033 <num>
				close(f);
  800162:	89 34 24             	mov    %esi,(%esp)
  800165:	e8 51 0f 00 00       	call   8010bb <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80016a:	83 c7 01             	add    $0x1,%edi
  80016d:	83 c3 04             	add    $0x4,%ebx
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	3b 7d 08             	cmp    0x8(%ebp),%edi
  800176:	7c ad                	jl     800125 <umain+0x3a>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  800178:	e8 4e 00 00 00       	call   8001cb <exit>
}
  80017d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    

00800185 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80018d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800190:	e8 73 0a 00 00       	call   800c08 <sys_getenvid>
  800195:	25 ff 03 00 00       	and    $0x3ff,%eax
  80019a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80019d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001a2:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001a7:	85 db                	test   %ebx,%ebx
  8001a9:	7e 07                	jle    8001b2 <libmain+0x2d>
		binaryname = argv[0];
  8001ab:	8b 06                	mov    (%esi),%eax
  8001ad:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	56                   	push   %esi
  8001b6:	53                   	push   %ebx
  8001b7:	e8 2f ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8001bc:	e8 0a 00 00 00       	call   8001cb <exit>
}
  8001c1:	83 c4 10             	add    $0x10,%esp
  8001c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001c7:	5b                   	pop    %ebx
  8001c8:	5e                   	pop    %esi
  8001c9:	5d                   	pop    %ebp
  8001ca:	c3                   	ret    

008001cb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001d1:	e8 10 0f 00 00       	call   8010e6 <close_all>
	sys_env_destroy(0);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	6a 00                	push   $0x0
  8001db:	e8 e7 09 00 00       	call   800bc7 <sys_env_destroy>
}
  8001e0:	83 c4 10             	add    $0x10,%esp
  8001e3:	c9                   	leave  
  8001e4:	c3                   	ret    

008001e5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001ea:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001ed:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8001f3:	e8 10 0a 00 00       	call   800c08 <sys_getenvid>
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 0c             	pushl  0xc(%ebp)
  8001fe:	ff 75 08             	pushl  0x8(%ebp)
  800201:	56                   	push   %esi
  800202:	50                   	push   %eax
  800203:	68 e8 25 80 00       	push   $0x8025e8
  800208:	e8 b1 00 00 00       	call   8002be <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020d:	83 c4 18             	add    $0x18,%esp
  800210:	53                   	push   %ebx
  800211:	ff 75 10             	pushl  0x10(%ebp)
  800214:	e8 54 00 00 00       	call   80026d <vcprintf>
	cprintf("\n");
  800219:	c7 04 24 50 2a 80 00 	movl   $0x802a50,(%esp)
  800220:	e8 99 00 00 00       	call   8002be <cprintf>
  800225:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800228:	cc                   	int3   
  800229:	eb fd                	jmp    800228 <_panic+0x43>

0080022b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	53                   	push   %ebx
  80022f:	83 ec 04             	sub    $0x4,%esp
  800232:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800235:	8b 13                	mov    (%ebx),%edx
  800237:	8d 42 01             	lea    0x1(%edx),%eax
  80023a:	89 03                	mov    %eax,(%ebx)
  80023c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800243:	3d ff 00 00 00       	cmp    $0xff,%eax
  800248:	75 1a                	jne    800264 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80024a:	83 ec 08             	sub    $0x8,%esp
  80024d:	68 ff 00 00 00       	push   $0xff
  800252:	8d 43 08             	lea    0x8(%ebx),%eax
  800255:	50                   	push   %eax
  800256:	e8 2f 09 00 00       	call   800b8a <sys_cputs>
		b->idx = 0;
  80025b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800261:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800264:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800268:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800276:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027d:	00 00 00 
	b.cnt = 0;
  800280:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800287:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80028a:	ff 75 0c             	pushl  0xc(%ebp)
  80028d:	ff 75 08             	pushl  0x8(%ebp)
  800290:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800296:	50                   	push   %eax
  800297:	68 2b 02 80 00       	push   $0x80022b
  80029c:	e8 54 01 00 00       	call   8003f5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a1:	83 c4 08             	add    $0x8,%esp
  8002a4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b0:	50                   	push   %eax
  8002b1:	e8 d4 08 00 00       	call   800b8a <sys_cputs>

	return b.cnt;
}
  8002b6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c7:	50                   	push   %eax
  8002c8:	ff 75 08             	pushl  0x8(%ebp)
  8002cb:	e8 9d ff ff ff       	call   80026d <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 1c             	sub    $0x1c,%esp
  8002db:	89 c7                	mov    %eax,%edi
  8002dd:	89 d6                	mov    %edx,%esi
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002f6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002f9:	39 d3                	cmp    %edx,%ebx
  8002fb:	72 05                	jb     800302 <printnum+0x30>
  8002fd:	39 45 10             	cmp    %eax,0x10(%ebp)
  800300:	77 45                	ja     800347 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800302:	83 ec 0c             	sub    $0xc,%esp
  800305:	ff 75 18             	pushl  0x18(%ebp)
  800308:	8b 45 14             	mov    0x14(%ebp),%eax
  80030b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80030e:	53                   	push   %ebx
  80030f:	ff 75 10             	pushl  0x10(%ebp)
  800312:	83 ec 08             	sub    $0x8,%esp
  800315:	ff 75 e4             	pushl  -0x1c(%ebp)
  800318:	ff 75 e0             	pushl  -0x20(%ebp)
  80031b:	ff 75 dc             	pushl  -0x24(%ebp)
  80031e:	ff 75 d8             	pushl  -0x28(%ebp)
  800321:	e8 ba 1f 00 00       	call   8022e0 <__udivdi3>
  800326:	83 c4 18             	add    $0x18,%esp
  800329:	52                   	push   %edx
  80032a:	50                   	push   %eax
  80032b:	89 f2                	mov    %esi,%edx
  80032d:	89 f8                	mov    %edi,%eax
  80032f:	e8 9e ff ff ff       	call   8002d2 <printnum>
  800334:	83 c4 20             	add    $0x20,%esp
  800337:	eb 18                	jmp    800351 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800339:	83 ec 08             	sub    $0x8,%esp
  80033c:	56                   	push   %esi
  80033d:	ff 75 18             	pushl  0x18(%ebp)
  800340:	ff d7                	call   *%edi
  800342:	83 c4 10             	add    $0x10,%esp
  800345:	eb 03                	jmp    80034a <printnum+0x78>
  800347:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80034a:	83 eb 01             	sub    $0x1,%ebx
  80034d:	85 db                	test   %ebx,%ebx
  80034f:	7f e8                	jg     800339 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800351:	83 ec 08             	sub    $0x8,%esp
  800354:	56                   	push   %esi
  800355:	83 ec 04             	sub    $0x4,%esp
  800358:	ff 75 e4             	pushl  -0x1c(%ebp)
  80035b:	ff 75 e0             	pushl  -0x20(%ebp)
  80035e:	ff 75 dc             	pushl  -0x24(%ebp)
  800361:	ff 75 d8             	pushl  -0x28(%ebp)
  800364:	e8 a7 20 00 00       	call   802410 <__umoddi3>
  800369:	83 c4 14             	add    $0x14,%esp
  80036c:	0f be 80 0b 26 80 00 	movsbl 0x80260b(%eax),%eax
  800373:	50                   	push   %eax
  800374:	ff d7                	call   *%edi
}
  800376:	83 c4 10             	add    $0x10,%esp
  800379:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80037c:	5b                   	pop    %ebx
  80037d:	5e                   	pop    %esi
  80037e:	5f                   	pop    %edi
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800384:	83 fa 01             	cmp    $0x1,%edx
  800387:	7e 0e                	jle    800397 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80038e:	89 08                	mov    %ecx,(%eax)
  800390:	8b 02                	mov    (%edx),%eax
  800392:	8b 52 04             	mov    0x4(%edx),%edx
  800395:	eb 22                	jmp    8003b9 <getuint+0x38>
	else if (lflag)
  800397:	85 d2                	test   %edx,%edx
  800399:	74 10                	je     8003ab <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80039b:	8b 10                	mov    (%eax),%edx
  80039d:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a0:	89 08                	mov    %ecx,(%eax)
  8003a2:	8b 02                	mov    (%edx),%eax
  8003a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a9:	eb 0e                	jmp    8003b9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003ab:	8b 10                	mov    (%eax),%edx
  8003ad:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b0:	89 08                	mov    %ecx,(%eax)
  8003b2:	8b 02                	mov    (%edx),%eax
  8003b4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b9:	5d                   	pop    %ebp
  8003ba:	c3                   	ret    

008003bb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003c5:	8b 10                	mov    (%eax),%edx
  8003c7:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ca:	73 0a                	jae    8003d6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003cc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003cf:	89 08                	mov    %ecx,(%eax)
  8003d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d4:	88 02                	mov    %al,(%edx)
}
  8003d6:	5d                   	pop    %ebp
  8003d7:	c3                   	ret    

008003d8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003de:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003e1:	50                   	push   %eax
  8003e2:	ff 75 10             	pushl  0x10(%ebp)
  8003e5:	ff 75 0c             	pushl  0xc(%ebp)
  8003e8:	ff 75 08             	pushl  0x8(%ebp)
  8003eb:	e8 05 00 00 00       	call   8003f5 <vprintfmt>
	va_end(ap);
}
  8003f0:	83 c4 10             	add    $0x10,%esp
  8003f3:	c9                   	leave  
  8003f4:	c3                   	ret    

008003f5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	57                   	push   %edi
  8003f9:	56                   	push   %esi
  8003fa:	53                   	push   %ebx
  8003fb:	83 ec 2c             	sub    $0x2c,%esp
  8003fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800401:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800404:	8b 7d 10             	mov    0x10(%ebp),%edi
  800407:	eb 12                	jmp    80041b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800409:	85 c0                	test   %eax,%eax
  80040b:	0f 84 89 03 00 00    	je     80079a <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800411:	83 ec 08             	sub    $0x8,%esp
  800414:	53                   	push   %ebx
  800415:	50                   	push   %eax
  800416:	ff d6                	call   *%esi
  800418:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80041b:	83 c7 01             	add    $0x1,%edi
  80041e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800422:	83 f8 25             	cmp    $0x25,%eax
  800425:	75 e2                	jne    800409 <vprintfmt+0x14>
  800427:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80042b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800432:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800439:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800440:	ba 00 00 00 00       	mov    $0x0,%edx
  800445:	eb 07                	jmp    80044e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80044a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8d 47 01             	lea    0x1(%edi),%eax
  800451:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800454:	0f b6 07             	movzbl (%edi),%eax
  800457:	0f b6 c8             	movzbl %al,%ecx
  80045a:	83 e8 23             	sub    $0x23,%eax
  80045d:	3c 55                	cmp    $0x55,%al
  80045f:	0f 87 1a 03 00 00    	ja     80077f <vprintfmt+0x38a>
  800465:	0f b6 c0             	movzbl %al,%eax
  800468:	ff 24 85 40 27 80 00 	jmp    *0x802740(,%eax,4)
  80046f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800472:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800476:	eb d6                	jmp    80044e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047b:	b8 00 00 00 00       	mov    $0x0,%eax
  800480:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800483:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800486:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80048a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80048d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800490:	83 fa 09             	cmp    $0x9,%edx
  800493:	77 39                	ja     8004ce <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800495:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800498:	eb e9                	jmp    800483 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 48 04             	lea    0x4(%eax),%ecx
  8004a0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004a3:	8b 00                	mov    (%eax),%eax
  8004a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ab:	eb 27                	jmp    8004d4 <vprintfmt+0xdf>
  8004ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004b0:	85 c0                	test   %eax,%eax
  8004b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004b7:	0f 49 c8             	cmovns %eax,%ecx
  8004ba:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c0:	eb 8c                	jmp    80044e <vprintfmt+0x59>
  8004c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004cc:	eb 80                	jmp    80044e <vprintfmt+0x59>
  8004ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004d1:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d8:	0f 89 70 ff ff ff    	jns    80044e <vprintfmt+0x59>
				width = precision, precision = -1;
  8004de:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004eb:	e9 5e ff ff ff       	jmp    80044e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004f0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004f6:	e9 53 ff ff ff       	jmp    80044e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fe:	8d 50 04             	lea    0x4(%eax),%edx
  800501:	89 55 14             	mov    %edx,0x14(%ebp)
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	53                   	push   %ebx
  800508:	ff 30                	pushl  (%eax)
  80050a:	ff d6                	call   *%esi
			break;
  80050c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800512:	e9 04 ff ff ff       	jmp    80041b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8d 50 04             	lea    0x4(%eax),%edx
  80051d:	89 55 14             	mov    %edx,0x14(%ebp)
  800520:	8b 00                	mov    (%eax),%eax
  800522:	99                   	cltd   
  800523:	31 d0                	xor    %edx,%eax
  800525:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800527:	83 f8 0f             	cmp    $0xf,%eax
  80052a:	7f 0b                	jg     800537 <vprintfmt+0x142>
  80052c:	8b 14 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%edx
  800533:	85 d2                	test   %edx,%edx
  800535:	75 18                	jne    80054f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800537:	50                   	push   %eax
  800538:	68 23 26 80 00       	push   $0x802623
  80053d:	53                   	push   %ebx
  80053e:	56                   	push   %esi
  80053f:	e8 94 fe ff ff       	call   8003d8 <printfmt>
  800544:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80054a:	e9 cc fe ff ff       	jmp    80041b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80054f:	52                   	push   %edx
  800550:	68 de 29 80 00       	push   $0x8029de
  800555:	53                   	push   %ebx
  800556:	56                   	push   %esi
  800557:	e8 7c fe ff ff       	call   8003d8 <printfmt>
  80055c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800562:	e9 b4 fe ff ff       	jmp    80041b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 50 04             	lea    0x4(%eax),%edx
  80056d:	89 55 14             	mov    %edx,0x14(%ebp)
  800570:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800572:	85 ff                	test   %edi,%edi
  800574:	b8 1c 26 80 00       	mov    $0x80261c,%eax
  800579:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80057c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800580:	0f 8e 94 00 00 00    	jle    80061a <vprintfmt+0x225>
  800586:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80058a:	0f 84 98 00 00 00    	je     800628 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800590:	83 ec 08             	sub    $0x8,%esp
  800593:	ff 75 d0             	pushl  -0x30(%ebp)
  800596:	57                   	push   %edi
  800597:	e8 86 02 00 00       	call   800822 <strnlen>
  80059c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80059f:	29 c1                	sub    %eax,%ecx
  8005a1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005a4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005a7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ae:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005b1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b3:	eb 0f                	jmp    8005c4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	53                   	push   %ebx
  8005b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8005bc:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005be:	83 ef 01             	sub    $0x1,%edi
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	85 ff                	test   %edi,%edi
  8005c6:	7f ed                	jg     8005b5 <vprintfmt+0x1c0>
  8005c8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005cb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005ce:	85 c9                	test   %ecx,%ecx
  8005d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d5:	0f 49 c1             	cmovns %ecx,%eax
  8005d8:	29 c1                	sub    %eax,%ecx
  8005da:	89 75 08             	mov    %esi,0x8(%ebp)
  8005dd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e3:	89 cb                	mov    %ecx,%ebx
  8005e5:	eb 4d                	jmp    800634 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005e7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005eb:	74 1b                	je     800608 <vprintfmt+0x213>
  8005ed:	0f be c0             	movsbl %al,%eax
  8005f0:	83 e8 20             	sub    $0x20,%eax
  8005f3:	83 f8 5e             	cmp    $0x5e,%eax
  8005f6:	76 10                	jbe    800608 <vprintfmt+0x213>
					putch('?', putdat);
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	ff 75 0c             	pushl  0xc(%ebp)
  8005fe:	6a 3f                	push   $0x3f
  800600:	ff 55 08             	call   *0x8(%ebp)
  800603:	83 c4 10             	add    $0x10,%esp
  800606:	eb 0d                	jmp    800615 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800608:	83 ec 08             	sub    $0x8,%esp
  80060b:	ff 75 0c             	pushl  0xc(%ebp)
  80060e:	52                   	push   %edx
  80060f:	ff 55 08             	call   *0x8(%ebp)
  800612:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800615:	83 eb 01             	sub    $0x1,%ebx
  800618:	eb 1a                	jmp    800634 <vprintfmt+0x23f>
  80061a:	89 75 08             	mov    %esi,0x8(%ebp)
  80061d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800620:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800623:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800626:	eb 0c                	jmp    800634 <vprintfmt+0x23f>
  800628:	89 75 08             	mov    %esi,0x8(%ebp)
  80062b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80062e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800631:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800634:	83 c7 01             	add    $0x1,%edi
  800637:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80063b:	0f be d0             	movsbl %al,%edx
  80063e:	85 d2                	test   %edx,%edx
  800640:	74 23                	je     800665 <vprintfmt+0x270>
  800642:	85 f6                	test   %esi,%esi
  800644:	78 a1                	js     8005e7 <vprintfmt+0x1f2>
  800646:	83 ee 01             	sub    $0x1,%esi
  800649:	79 9c                	jns    8005e7 <vprintfmt+0x1f2>
  80064b:	89 df                	mov    %ebx,%edi
  80064d:	8b 75 08             	mov    0x8(%ebp),%esi
  800650:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800653:	eb 18                	jmp    80066d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	53                   	push   %ebx
  800659:	6a 20                	push   $0x20
  80065b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065d:	83 ef 01             	sub    $0x1,%edi
  800660:	83 c4 10             	add    $0x10,%esp
  800663:	eb 08                	jmp    80066d <vprintfmt+0x278>
  800665:	89 df                	mov    %ebx,%edi
  800667:	8b 75 08             	mov    0x8(%ebp),%esi
  80066a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80066d:	85 ff                	test   %edi,%edi
  80066f:	7f e4                	jg     800655 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800671:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800674:	e9 a2 fd ff ff       	jmp    80041b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800679:	83 fa 01             	cmp    $0x1,%edx
  80067c:	7e 16                	jle    800694 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 50 08             	lea    0x8(%eax),%edx
  800684:	89 55 14             	mov    %edx,0x14(%ebp)
  800687:	8b 50 04             	mov    0x4(%eax),%edx
  80068a:	8b 00                	mov    (%eax),%eax
  80068c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800692:	eb 32                	jmp    8006c6 <vprintfmt+0x2d1>
	else if (lflag)
  800694:	85 d2                	test   %edx,%edx
  800696:	74 18                	je     8006b0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8d 50 04             	lea    0x4(%eax),%edx
  80069e:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a1:	8b 00                	mov    (%eax),%eax
  8006a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a6:	89 c1                	mov    %eax,%ecx
  8006a8:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ab:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006ae:	eb 16                	jmp    8006c6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8d 50 04             	lea    0x4(%eax),%edx
  8006b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b9:	8b 00                	mov    (%eax),%eax
  8006bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006be:	89 c1                	mov    %eax,%ecx
  8006c0:	c1 f9 1f             	sar    $0x1f,%ecx
  8006c3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006c9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006cc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006d1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006d5:	79 74                	jns    80074b <vprintfmt+0x356>
				putch('-', putdat);
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	53                   	push   %ebx
  8006db:	6a 2d                	push   $0x2d
  8006dd:	ff d6                	call   *%esi
				num = -(long long) num;
  8006df:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006e5:	f7 d8                	neg    %eax
  8006e7:	83 d2 00             	adc    $0x0,%edx
  8006ea:	f7 da                	neg    %edx
  8006ec:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006ef:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006f4:	eb 55                	jmp    80074b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f9:	e8 83 fc ff ff       	call   800381 <getuint>
			base = 10;
  8006fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800703:	eb 46                	jmp    80074b <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800705:	8d 45 14             	lea    0x14(%ebp),%eax
  800708:	e8 74 fc ff ff       	call   800381 <getuint>
                        base = 8;
  80070d:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800712:	eb 37                	jmp    80074b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	53                   	push   %ebx
  800718:	6a 30                	push   $0x30
  80071a:	ff d6                	call   *%esi
			putch('x', putdat);
  80071c:	83 c4 08             	add    $0x8,%esp
  80071f:	53                   	push   %ebx
  800720:	6a 78                	push   $0x78
  800722:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800724:	8b 45 14             	mov    0x14(%ebp),%eax
  800727:	8d 50 04             	lea    0x4(%eax),%edx
  80072a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80072d:	8b 00                	mov    (%eax),%eax
  80072f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800734:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800737:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80073c:	eb 0d                	jmp    80074b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80073e:	8d 45 14             	lea    0x14(%ebp),%eax
  800741:	e8 3b fc ff ff       	call   800381 <getuint>
			base = 16;
  800746:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80074b:	83 ec 0c             	sub    $0xc,%esp
  80074e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800752:	57                   	push   %edi
  800753:	ff 75 e0             	pushl  -0x20(%ebp)
  800756:	51                   	push   %ecx
  800757:	52                   	push   %edx
  800758:	50                   	push   %eax
  800759:	89 da                	mov    %ebx,%edx
  80075b:	89 f0                	mov    %esi,%eax
  80075d:	e8 70 fb ff ff       	call   8002d2 <printnum>
			break;
  800762:	83 c4 20             	add    $0x20,%esp
  800765:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800768:	e9 ae fc ff ff       	jmp    80041b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80076d:	83 ec 08             	sub    $0x8,%esp
  800770:	53                   	push   %ebx
  800771:	51                   	push   %ecx
  800772:	ff d6                	call   *%esi
			break;
  800774:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800777:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80077a:	e9 9c fc ff ff       	jmp    80041b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80077f:	83 ec 08             	sub    $0x8,%esp
  800782:	53                   	push   %ebx
  800783:	6a 25                	push   $0x25
  800785:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800787:	83 c4 10             	add    $0x10,%esp
  80078a:	eb 03                	jmp    80078f <vprintfmt+0x39a>
  80078c:	83 ef 01             	sub    $0x1,%edi
  80078f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800793:	75 f7                	jne    80078c <vprintfmt+0x397>
  800795:	e9 81 fc ff ff       	jmp    80041b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80079a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079d:	5b                   	pop    %ebx
  80079e:	5e                   	pop    %esi
  80079f:	5f                   	pop    %edi
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	83 ec 18             	sub    $0x18,%esp
  8007a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007bf:	85 c0                	test   %eax,%eax
  8007c1:	74 26                	je     8007e9 <vsnprintf+0x47>
  8007c3:	85 d2                	test   %edx,%edx
  8007c5:	7e 22                	jle    8007e9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c7:	ff 75 14             	pushl  0x14(%ebp)
  8007ca:	ff 75 10             	pushl  0x10(%ebp)
  8007cd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d0:	50                   	push   %eax
  8007d1:	68 bb 03 80 00       	push   $0x8003bb
  8007d6:	e8 1a fc ff ff       	call   8003f5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007db:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007de:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	eb 05                	jmp    8007ee <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f9:	50                   	push   %eax
  8007fa:	ff 75 10             	pushl  0x10(%ebp)
  8007fd:	ff 75 0c             	pushl  0xc(%ebp)
  800800:	ff 75 08             	pushl  0x8(%ebp)
  800803:	e8 9a ff ff ff       	call   8007a2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800808:	c9                   	leave  
  800809:	c3                   	ret    

0080080a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800810:	b8 00 00 00 00       	mov    $0x0,%eax
  800815:	eb 03                	jmp    80081a <strlen+0x10>
		n++;
  800817:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80081a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80081e:	75 f7                	jne    800817 <strlen+0xd>
		n++;
	return n;
}
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800828:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082b:	ba 00 00 00 00       	mov    $0x0,%edx
  800830:	eb 03                	jmp    800835 <strnlen+0x13>
		n++;
  800832:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800835:	39 c2                	cmp    %eax,%edx
  800837:	74 08                	je     800841 <strnlen+0x1f>
  800839:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80083d:	75 f3                	jne    800832 <strnlen+0x10>
  80083f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	53                   	push   %ebx
  800847:	8b 45 08             	mov    0x8(%ebp),%eax
  80084a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80084d:	89 c2                	mov    %eax,%edx
  80084f:	83 c2 01             	add    $0x1,%edx
  800852:	83 c1 01             	add    $0x1,%ecx
  800855:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800859:	88 5a ff             	mov    %bl,-0x1(%edx)
  80085c:	84 db                	test   %bl,%bl
  80085e:	75 ef                	jne    80084f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800860:	5b                   	pop    %ebx
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	53                   	push   %ebx
  800867:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80086a:	53                   	push   %ebx
  80086b:	e8 9a ff ff ff       	call   80080a <strlen>
  800870:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800873:	ff 75 0c             	pushl  0xc(%ebp)
  800876:	01 d8                	add    %ebx,%eax
  800878:	50                   	push   %eax
  800879:	e8 c5 ff ff ff       	call   800843 <strcpy>
	return dst;
}
  80087e:	89 d8                	mov    %ebx,%eax
  800880:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800883:	c9                   	leave  
  800884:	c3                   	ret    

00800885 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	56                   	push   %esi
  800889:	53                   	push   %ebx
  80088a:	8b 75 08             	mov    0x8(%ebp),%esi
  80088d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800890:	89 f3                	mov    %esi,%ebx
  800892:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800895:	89 f2                	mov    %esi,%edx
  800897:	eb 0f                	jmp    8008a8 <strncpy+0x23>
		*dst++ = *src;
  800899:	83 c2 01             	add    $0x1,%edx
  80089c:	0f b6 01             	movzbl (%ecx),%eax
  80089f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008a2:	80 39 01             	cmpb   $0x1,(%ecx)
  8008a5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a8:	39 da                	cmp    %ebx,%edx
  8008aa:	75 ed                	jne    800899 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008ac:	89 f0                	mov    %esi,%eax
  8008ae:	5b                   	pop    %ebx
  8008af:	5e                   	pop    %esi
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	56                   	push   %esi
  8008b6:	53                   	push   %ebx
  8008b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008bd:	8b 55 10             	mov    0x10(%ebp),%edx
  8008c0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c2:	85 d2                	test   %edx,%edx
  8008c4:	74 21                	je     8008e7 <strlcpy+0x35>
  8008c6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008ca:	89 f2                	mov    %esi,%edx
  8008cc:	eb 09                	jmp    8008d7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ce:	83 c2 01             	add    $0x1,%edx
  8008d1:	83 c1 01             	add    $0x1,%ecx
  8008d4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008d7:	39 c2                	cmp    %eax,%edx
  8008d9:	74 09                	je     8008e4 <strlcpy+0x32>
  8008db:	0f b6 19             	movzbl (%ecx),%ebx
  8008de:	84 db                	test   %bl,%bl
  8008e0:	75 ec                	jne    8008ce <strlcpy+0x1c>
  8008e2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008e4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008e7:	29 f0                	sub    %esi,%eax
}
  8008e9:	5b                   	pop    %ebx
  8008ea:	5e                   	pop    %esi
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f6:	eb 06                	jmp    8008fe <strcmp+0x11>
		p++, q++;
  8008f8:	83 c1 01             	add    $0x1,%ecx
  8008fb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008fe:	0f b6 01             	movzbl (%ecx),%eax
  800901:	84 c0                	test   %al,%al
  800903:	74 04                	je     800909 <strcmp+0x1c>
  800905:	3a 02                	cmp    (%edx),%al
  800907:	74 ef                	je     8008f8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800909:	0f b6 c0             	movzbl %al,%eax
  80090c:	0f b6 12             	movzbl (%edx),%edx
  80090f:	29 d0                	sub    %edx,%eax
}
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	53                   	push   %ebx
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091d:	89 c3                	mov    %eax,%ebx
  80091f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800922:	eb 06                	jmp    80092a <strncmp+0x17>
		n--, p++, q++;
  800924:	83 c0 01             	add    $0x1,%eax
  800927:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80092a:	39 d8                	cmp    %ebx,%eax
  80092c:	74 15                	je     800943 <strncmp+0x30>
  80092e:	0f b6 08             	movzbl (%eax),%ecx
  800931:	84 c9                	test   %cl,%cl
  800933:	74 04                	je     800939 <strncmp+0x26>
  800935:	3a 0a                	cmp    (%edx),%cl
  800937:	74 eb                	je     800924 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800939:	0f b6 00             	movzbl (%eax),%eax
  80093c:	0f b6 12             	movzbl (%edx),%edx
  80093f:	29 d0                	sub    %edx,%eax
  800941:	eb 05                	jmp    800948 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800943:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800948:	5b                   	pop    %ebx
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800955:	eb 07                	jmp    80095e <strchr+0x13>
		if (*s == c)
  800957:	38 ca                	cmp    %cl,%dl
  800959:	74 0f                	je     80096a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80095b:	83 c0 01             	add    $0x1,%eax
  80095e:	0f b6 10             	movzbl (%eax),%edx
  800961:	84 d2                	test   %dl,%dl
  800963:	75 f2                	jne    800957 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800965:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800976:	eb 03                	jmp    80097b <strfind+0xf>
  800978:	83 c0 01             	add    $0x1,%eax
  80097b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80097e:	38 ca                	cmp    %cl,%dl
  800980:	74 04                	je     800986 <strfind+0x1a>
  800982:	84 d2                	test   %dl,%dl
  800984:	75 f2                	jne    800978 <strfind+0xc>
			break;
	return (char *) s;
}
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	57                   	push   %edi
  80098c:	56                   	push   %esi
  80098d:	53                   	push   %ebx
  80098e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800991:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800994:	85 c9                	test   %ecx,%ecx
  800996:	74 36                	je     8009ce <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800998:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099e:	75 28                	jne    8009c8 <memset+0x40>
  8009a0:	f6 c1 03             	test   $0x3,%cl
  8009a3:	75 23                	jne    8009c8 <memset+0x40>
		c &= 0xFF;
  8009a5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a9:	89 d3                	mov    %edx,%ebx
  8009ab:	c1 e3 08             	shl    $0x8,%ebx
  8009ae:	89 d6                	mov    %edx,%esi
  8009b0:	c1 e6 18             	shl    $0x18,%esi
  8009b3:	89 d0                	mov    %edx,%eax
  8009b5:	c1 e0 10             	shl    $0x10,%eax
  8009b8:	09 f0                	or     %esi,%eax
  8009ba:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009bc:	89 d8                	mov    %ebx,%eax
  8009be:	09 d0                	or     %edx,%eax
  8009c0:	c1 e9 02             	shr    $0x2,%ecx
  8009c3:	fc                   	cld    
  8009c4:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c6:	eb 06                	jmp    8009ce <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cb:	fc                   	cld    
  8009cc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ce:	89 f8                	mov    %edi,%eax
  8009d0:	5b                   	pop    %ebx
  8009d1:	5e                   	pop    %esi
  8009d2:	5f                   	pop    %edi
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	57                   	push   %edi
  8009d9:	56                   	push   %esi
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e3:	39 c6                	cmp    %eax,%esi
  8009e5:	73 35                	jae    800a1c <memmove+0x47>
  8009e7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ea:	39 d0                	cmp    %edx,%eax
  8009ec:	73 2e                	jae    800a1c <memmove+0x47>
		s += n;
		d += n;
  8009ee:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f1:	89 d6                	mov    %edx,%esi
  8009f3:	09 fe                	or     %edi,%esi
  8009f5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009fb:	75 13                	jne    800a10 <memmove+0x3b>
  8009fd:	f6 c1 03             	test   $0x3,%cl
  800a00:	75 0e                	jne    800a10 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a02:	83 ef 04             	sub    $0x4,%edi
  800a05:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a08:	c1 e9 02             	shr    $0x2,%ecx
  800a0b:	fd                   	std    
  800a0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0e:	eb 09                	jmp    800a19 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a10:	83 ef 01             	sub    $0x1,%edi
  800a13:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a16:	fd                   	std    
  800a17:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a19:	fc                   	cld    
  800a1a:	eb 1d                	jmp    800a39 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1c:	89 f2                	mov    %esi,%edx
  800a1e:	09 c2                	or     %eax,%edx
  800a20:	f6 c2 03             	test   $0x3,%dl
  800a23:	75 0f                	jne    800a34 <memmove+0x5f>
  800a25:	f6 c1 03             	test   $0x3,%cl
  800a28:	75 0a                	jne    800a34 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a2a:	c1 e9 02             	shr    $0x2,%ecx
  800a2d:	89 c7                	mov    %eax,%edi
  800a2f:	fc                   	cld    
  800a30:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a32:	eb 05                	jmp    800a39 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a34:	89 c7                	mov    %eax,%edi
  800a36:	fc                   	cld    
  800a37:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a39:	5e                   	pop    %esi
  800a3a:	5f                   	pop    %edi
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a40:	ff 75 10             	pushl  0x10(%ebp)
  800a43:	ff 75 0c             	pushl  0xc(%ebp)
  800a46:	ff 75 08             	pushl  0x8(%ebp)
  800a49:	e8 87 ff ff ff       	call   8009d5 <memmove>
}
  800a4e:	c9                   	leave  
  800a4f:	c3                   	ret    

00800a50 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	56                   	push   %esi
  800a54:	53                   	push   %ebx
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5b:	89 c6                	mov    %eax,%esi
  800a5d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a60:	eb 1a                	jmp    800a7c <memcmp+0x2c>
		if (*s1 != *s2)
  800a62:	0f b6 08             	movzbl (%eax),%ecx
  800a65:	0f b6 1a             	movzbl (%edx),%ebx
  800a68:	38 d9                	cmp    %bl,%cl
  800a6a:	74 0a                	je     800a76 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a6c:	0f b6 c1             	movzbl %cl,%eax
  800a6f:	0f b6 db             	movzbl %bl,%ebx
  800a72:	29 d8                	sub    %ebx,%eax
  800a74:	eb 0f                	jmp    800a85 <memcmp+0x35>
		s1++, s2++;
  800a76:	83 c0 01             	add    $0x1,%eax
  800a79:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a7c:	39 f0                	cmp    %esi,%eax
  800a7e:	75 e2                	jne    800a62 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a85:	5b                   	pop    %ebx
  800a86:	5e                   	pop    %esi
  800a87:	5d                   	pop    %ebp
  800a88:	c3                   	ret    

00800a89 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a89:	55                   	push   %ebp
  800a8a:	89 e5                	mov    %esp,%ebp
  800a8c:	53                   	push   %ebx
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a90:	89 c1                	mov    %eax,%ecx
  800a92:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a95:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a99:	eb 0a                	jmp    800aa5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a9b:	0f b6 10             	movzbl (%eax),%edx
  800a9e:	39 da                	cmp    %ebx,%edx
  800aa0:	74 07                	je     800aa9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aa2:	83 c0 01             	add    $0x1,%eax
  800aa5:	39 c8                	cmp    %ecx,%eax
  800aa7:	72 f2                	jb     800a9b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aa9:	5b                   	pop    %ebx
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	57                   	push   %edi
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
  800ab2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab8:	eb 03                	jmp    800abd <strtol+0x11>
		s++;
  800aba:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800abd:	0f b6 01             	movzbl (%ecx),%eax
  800ac0:	3c 20                	cmp    $0x20,%al
  800ac2:	74 f6                	je     800aba <strtol+0xe>
  800ac4:	3c 09                	cmp    $0x9,%al
  800ac6:	74 f2                	je     800aba <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ac8:	3c 2b                	cmp    $0x2b,%al
  800aca:	75 0a                	jne    800ad6 <strtol+0x2a>
		s++;
  800acc:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800acf:	bf 00 00 00 00       	mov    $0x0,%edi
  800ad4:	eb 11                	jmp    800ae7 <strtol+0x3b>
  800ad6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800adb:	3c 2d                	cmp    $0x2d,%al
  800add:	75 08                	jne    800ae7 <strtol+0x3b>
		s++, neg = 1;
  800adf:	83 c1 01             	add    $0x1,%ecx
  800ae2:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aed:	75 15                	jne    800b04 <strtol+0x58>
  800aef:	80 39 30             	cmpb   $0x30,(%ecx)
  800af2:	75 10                	jne    800b04 <strtol+0x58>
  800af4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800af8:	75 7c                	jne    800b76 <strtol+0xca>
		s += 2, base = 16;
  800afa:	83 c1 02             	add    $0x2,%ecx
  800afd:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b02:	eb 16                	jmp    800b1a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b04:	85 db                	test   %ebx,%ebx
  800b06:	75 12                	jne    800b1a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b08:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b0d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b10:	75 08                	jne    800b1a <strtol+0x6e>
		s++, base = 8;
  800b12:	83 c1 01             	add    $0x1,%ecx
  800b15:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b22:	0f b6 11             	movzbl (%ecx),%edx
  800b25:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b28:	89 f3                	mov    %esi,%ebx
  800b2a:	80 fb 09             	cmp    $0x9,%bl
  800b2d:	77 08                	ja     800b37 <strtol+0x8b>
			dig = *s - '0';
  800b2f:	0f be d2             	movsbl %dl,%edx
  800b32:	83 ea 30             	sub    $0x30,%edx
  800b35:	eb 22                	jmp    800b59 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b37:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b3a:	89 f3                	mov    %esi,%ebx
  800b3c:	80 fb 19             	cmp    $0x19,%bl
  800b3f:	77 08                	ja     800b49 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b41:	0f be d2             	movsbl %dl,%edx
  800b44:	83 ea 57             	sub    $0x57,%edx
  800b47:	eb 10                	jmp    800b59 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b49:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b4c:	89 f3                	mov    %esi,%ebx
  800b4e:	80 fb 19             	cmp    $0x19,%bl
  800b51:	77 16                	ja     800b69 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b53:	0f be d2             	movsbl %dl,%edx
  800b56:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b59:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b5c:	7d 0b                	jge    800b69 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b5e:	83 c1 01             	add    $0x1,%ecx
  800b61:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b65:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b67:	eb b9                	jmp    800b22 <strtol+0x76>

	if (endptr)
  800b69:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6d:	74 0d                	je     800b7c <strtol+0xd0>
		*endptr = (char *) s;
  800b6f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b72:	89 0e                	mov    %ecx,(%esi)
  800b74:	eb 06                	jmp    800b7c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b76:	85 db                	test   %ebx,%ebx
  800b78:	74 98                	je     800b12 <strtol+0x66>
  800b7a:	eb 9e                	jmp    800b1a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b7c:	89 c2                	mov    %eax,%edx
  800b7e:	f7 da                	neg    %edx
  800b80:	85 ff                	test   %edi,%edi
  800b82:	0f 45 c2             	cmovne %edx,%eax
}
  800b85:	5b                   	pop    %ebx
  800b86:	5e                   	pop    %esi
  800b87:	5f                   	pop    %edi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	57                   	push   %edi
  800b8e:	56                   	push   %esi
  800b8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b90:	b8 00 00 00 00       	mov    $0x0,%eax
  800b95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b98:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9b:	89 c3                	mov    %eax,%ebx
  800b9d:	89 c7                	mov    %eax,%edi
  800b9f:	89 c6                	mov    %eax,%esi
  800ba1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bae:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb3:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb8:	89 d1                	mov    %edx,%ecx
  800bba:	89 d3                	mov    %edx,%ebx
  800bbc:	89 d7                	mov    %edx,%edi
  800bbe:	89 d6                	mov    %edx,%esi
  800bc0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5f                   	pop    %edi
  800bc5:	5d                   	pop    %ebp
  800bc6:	c3                   	ret    

00800bc7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	57                   	push   %edi
  800bcb:	56                   	push   %esi
  800bcc:	53                   	push   %ebx
  800bcd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd5:	b8 03 00 00 00       	mov    $0x3,%eax
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	89 cb                	mov    %ecx,%ebx
  800bdf:	89 cf                	mov    %ecx,%edi
  800be1:	89 ce                	mov    %ecx,%esi
  800be3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be5:	85 c0                	test   %eax,%eax
  800be7:	7e 17                	jle    800c00 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be9:	83 ec 0c             	sub    $0xc,%esp
  800bec:	50                   	push   %eax
  800bed:	6a 03                	push   $0x3
  800bef:	68 ff 28 80 00       	push   $0x8028ff
  800bf4:	6a 23                	push   $0x23
  800bf6:	68 1c 29 80 00       	push   $0x80291c
  800bfb:	e8 e5 f5 ff ff       	call   8001e5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c13:	b8 02 00 00 00       	mov    $0x2,%eax
  800c18:	89 d1                	mov    %edx,%ecx
  800c1a:	89 d3                	mov    %edx,%ebx
  800c1c:	89 d7                	mov    %edx,%edi
  800c1e:	89 d6                	mov    %edx,%esi
  800c20:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <sys_yield>:

void
sys_yield(void)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	57                   	push   %edi
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c32:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c37:	89 d1                	mov    %edx,%ecx
  800c39:	89 d3                	mov    %edx,%ebx
  800c3b:	89 d7                	mov    %edx,%edi
  800c3d:	89 d6                	mov    %edx,%esi
  800c3f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c4f:	be 00 00 00 00       	mov    $0x0,%esi
  800c54:	b8 04 00 00 00       	mov    $0x4,%eax
  800c59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c62:	89 f7                	mov    %esi,%edi
  800c64:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c66:	85 c0                	test   %eax,%eax
  800c68:	7e 17                	jle    800c81 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6a:	83 ec 0c             	sub    $0xc,%esp
  800c6d:	50                   	push   %eax
  800c6e:	6a 04                	push   $0x4
  800c70:	68 ff 28 80 00       	push   $0x8028ff
  800c75:	6a 23                	push   $0x23
  800c77:	68 1c 29 80 00       	push   $0x80291c
  800c7c:	e8 64 f5 ff ff       	call   8001e5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c92:	b8 05 00 00 00       	mov    $0x5,%eax
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca3:	8b 75 18             	mov    0x18(%ebp),%esi
  800ca6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca8:	85 c0                	test   %eax,%eax
  800caa:	7e 17                	jle    800cc3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	50                   	push   %eax
  800cb0:	6a 05                	push   $0x5
  800cb2:	68 ff 28 80 00       	push   $0x8028ff
  800cb7:	6a 23                	push   $0x23
  800cb9:	68 1c 29 80 00       	push   $0x80291c
  800cbe:	e8 22 f5 ff ff       	call   8001e5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc6:	5b                   	pop    %ebx
  800cc7:	5e                   	pop    %esi
  800cc8:	5f                   	pop    %edi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
  800cd1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd9:	b8 06 00 00 00       	mov    $0x6,%eax
  800cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	89 df                	mov    %ebx,%edi
  800ce6:	89 de                	mov    %ebx,%esi
  800ce8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7e 17                	jle    800d05 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	50                   	push   %eax
  800cf2:	6a 06                	push   $0x6
  800cf4:	68 ff 28 80 00       	push   $0x8028ff
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 1c 29 80 00       	push   $0x80291c
  800d00:	e8 e0 f4 ff ff       	call   8001e5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
  800d13:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
  800d26:	89 df                	mov    %ebx,%edi
  800d28:	89 de                	mov    %ebx,%esi
  800d2a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	7e 17                	jle    800d47 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d30:	83 ec 0c             	sub    $0xc,%esp
  800d33:	50                   	push   %eax
  800d34:	6a 08                	push   $0x8
  800d36:	68 ff 28 80 00       	push   $0x8028ff
  800d3b:	6a 23                	push   $0x23
  800d3d:	68 1c 29 80 00       	push   $0x80291c
  800d42:	e8 9e f4 ff ff       	call   8001e5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
  800d55:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5d:	b8 09 00 00 00       	mov    $0x9,%eax
  800d62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d65:	8b 55 08             	mov    0x8(%ebp),%edx
  800d68:	89 df                	mov    %ebx,%edi
  800d6a:	89 de                	mov    %ebx,%esi
  800d6c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6e:	85 c0                	test   %eax,%eax
  800d70:	7e 17                	jle    800d89 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d72:	83 ec 0c             	sub    $0xc,%esp
  800d75:	50                   	push   %eax
  800d76:	6a 09                	push   $0x9
  800d78:	68 ff 28 80 00       	push   $0x8028ff
  800d7d:	6a 23                	push   $0x23
  800d7f:	68 1c 29 80 00       	push   $0x80291c
  800d84:	e8 5c f4 ff ff       	call   8001e5 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5f                   	pop    %edi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	57                   	push   %edi
  800d95:	56                   	push   %esi
  800d96:	53                   	push   %ebx
  800d97:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800da4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da7:	8b 55 08             	mov    0x8(%ebp),%edx
  800daa:	89 df                	mov    %ebx,%edi
  800dac:	89 de                	mov    %ebx,%esi
  800dae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db0:	85 c0                	test   %eax,%eax
  800db2:	7e 17                	jle    800dcb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db4:	83 ec 0c             	sub    $0xc,%esp
  800db7:	50                   	push   %eax
  800db8:	6a 0a                	push   $0xa
  800dba:	68 ff 28 80 00       	push   $0x8028ff
  800dbf:	6a 23                	push   $0x23
  800dc1:	68 1c 29 80 00       	push   $0x80291c
  800dc6:	e8 1a f4 ff ff       	call   8001e5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	57                   	push   %edi
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd9:	be 00 00 00 00       	mov    $0x0,%esi
  800dde:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de6:	8b 55 08             	mov    0x8(%ebp),%edx
  800de9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dec:	8b 7d 14             	mov    0x14(%ebp),%edi
  800def:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	57                   	push   %edi
  800dfa:	56                   	push   %esi
  800dfb:	53                   	push   %ebx
  800dfc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e04:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	89 cb                	mov    %ecx,%ebx
  800e0e:	89 cf                	mov    %ecx,%edi
  800e10:	89 ce                	mov    %ecx,%esi
  800e12:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e14:	85 c0                	test   %eax,%eax
  800e16:	7e 17                	jle    800e2f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e18:	83 ec 0c             	sub    $0xc,%esp
  800e1b:	50                   	push   %eax
  800e1c:	6a 0d                	push   $0xd
  800e1e:	68 ff 28 80 00       	push   $0x8028ff
  800e23:	6a 23                	push   $0x23
  800e25:	68 1c 29 80 00       	push   $0x80291c
  800e2a:	e8 b6 f3 ff ff       	call   8001e5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e32:	5b                   	pop    %ebx
  800e33:	5e                   	pop    %esi
  800e34:	5f                   	pop    %edi
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    

00800e37 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	57                   	push   %edi
  800e3b:	56                   	push   %esi
  800e3c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e42:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e47:	89 d1                	mov    %edx,%ecx
  800e49:	89 d3                	mov    %edx,%ebx
  800e4b:	89 d7                	mov    %edx,%edi
  800e4d:	89 d6                	mov    %edx,%esi
  800e4f:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e51:	5b                   	pop    %ebx
  800e52:	5e                   	pop    %esi
  800e53:	5f                   	pop    %edi
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <sys_transmit_packet>:

int
sys_transmit_packet(void *buf, size_t size)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	57                   	push   %edi
  800e5a:	56                   	push   %esi
  800e5b:	53                   	push   %ebx
  800e5c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e64:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6f:	89 df                	mov    %ebx,%edi
  800e71:	89 de                	mov    %ebx,%esi
  800e73:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e75:	85 c0                	test   %eax,%eax
  800e77:	7e 17                	jle    800e90 <sys_transmit_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e79:	83 ec 0c             	sub    $0xc,%esp
  800e7c:	50                   	push   %eax
  800e7d:	6a 0f                	push   $0xf
  800e7f:	68 ff 28 80 00       	push   $0x8028ff
  800e84:	6a 23                	push   $0x23
  800e86:	68 1c 29 80 00       	push   $0x80291c
  800e8b:	e8 55 f3 ff ff       	call   8001e5 <_panic>
int
sys_transmit_packet(void *buf, size_t size)
{
	return syscall(SYS_transmit_packet, 1,
		(uint32_t) buf, (uint32_t) size, 0, 0, 0);
}
  800e90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e93:	5b                   	pop    %ebx
  800e94:	5e                   	pop    %esi
  800e95:	5f                   	pop    %edi
  800e96:	5d                   	pop    %ebp
  800e97:	c3                   	ret    

00800e98 <sys_receive_packet>:

int
sys_receive_packet(void *buf, size_t *size_store)
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	57                   	push   %edi
  800e9c:	56                   	push   %esi
  800e9d:	53                   	push   %ebx
  800e9e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea6:	b8 10 00 00 00       	mov    $0x10,%eax
  800eab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eae:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb1:	89 df                	mov    %ebx,%edi
  800eb3:	89 de                	mov    %ebx,%esi
  800eb5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	7e 17                	jle    800ed2 <sys_receive_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebb:	83 ec 0c             	sub    $0xc,%esp
  800ebe:	50                   	push   %eax
  800ebf:	6a 10                	push   $0x10
  800ec1:	68 ff 28 80 00       	push   $0x8028ff
  800ec6:	6a 23                	push   $0x23
  800ec8:	68 1c 29 80 00       	push   $0x80291c
  800ecd:	e8 13 f3 ff ff       	call   8001e5 <_panic>
int
sys_receive_packet(void *buf, size_t *size_store)
{
	return syscall(SYS_receive_packet, 1,
		(uint32_t) buf, (uint32_t) size_store, 0, 0, 0);
}
  800ed2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed5:	5b                   	pop    %ebx
  800ed6:	5e                   	pop    %esi
  800ed7:	5f                   	pop    %edi
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    

00800eda <sys_get_mac_address>:

int
sys_get_mac_address(void *buf)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	57                   	push   %edi
  800ede:	56                   	push   %esi
  800edf:	53                   	push   %ebx
  800ee0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee8:	b8 11 00 00 00       	mov    $0x11,%eax
  800eed:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef0:	89 cb                	mov    %ecx,%ebx
  800ef2:	89 cf                	mov    %ecx,%edi
  800ef4:	89 ce                	mov    %ecx,%esi
  800ef6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ef8:	85 c0                	test   %eax,%eax
  800efa:	7e 17                	jle    800f13 <sys_get_mac_address+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800efc:	83 ec 0c             	sub    $0xc,%esp
  800eff:	50                   	push   %eax
  800f00:	6a 11                	push   $0x11
  800f02:	68 ff 28 80 00       	push   $0x8028ff
  800f07:	6a 23                	push   $0x23
  800f09:	68 1c 29 80 00       	push   $0x80291c
  800f0e:	e8 d2 f2 ff ff       	call   8001e5 <_panic>
int
sys_get_mac_address(void *buf)
{
	return syscall(SYS_get_mac_address, 1,
		(uint32_t) buf, 0, 0, 0, 0);
}
  800f13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f16:	5b                   	pop    %ebx
  800f17:	5e                   	pop    %esi
  800f18:	5f                   	pop    %edi
  800f19:	5d                   	pop    %ebp
  800f1a:	c3                   	ret    

00800f1b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f21:	05 00 00 00 30       	add    $0x30000000,%eax
  800f26:	c1 e8 0c             	shr    $0xc,%eax
}
  800f29:	5d                   	pop    %ebp
  800f2a:	c3                   	ret    

00800f2b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f31:	05 00 00 00 30       	add    $0x30000000,%eax
  800f36:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f3b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    

00800f42 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f48:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f4d:	89 c2                	mov    %eax,%edx
  800f4f:	c1 ea 16             	shr    $0x16,%edx
  800f52:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f59:	f6 c2 01             	test   $0x1,%dl
  800f5c:	74 11                	je     800f6f <fd_alloc+0x2d>
  800f5e:	89 c2                	mov    %eax,%edx
  800f60:	c1 ea 0c             	shr    $0xc,%edx
  800f63:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f6a:	f6 c2 01             	test   $0x1,%dl
  800f6d:	75 09                	jne    800f78 <fd_alloc+0x36>
			*fd_store = fd;
  800f6f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f71:	b8 00 00 00 00       	mov    $0x0,%eax
  800f76:	eb 17                	jmp    800f8f <fd_alloc+0x4d>
  800f78:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f7d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f82:	75 c9                	jne    800f4d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f84:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f8a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f8f:	5d                   	pop    %ebp
  800f90:	c3                   	ret    

00800f91 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f91:	55                   	push   %ebp
  800f92:	89 e5                	mov    %esp,%ebp
  800f94:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f97:	83 f8 1f             	cmp    $0x1f,%eax
  800f9a:	77 36                	ja     800fd2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f9c:	c1 e0 0c             	shl    $0xc,%eax
  800f9f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fa4:	89 c2                	mov    %eax,%edx
  800fa6:	c1 ea 16             	shr    $0x16,%edx
  800fa9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fb0:	f6 c2 01             	test   $0x1,%dl
  800fb3:	74 24                	je     800fd9 <fd_lookup+0x48>
  800fb5:	89 c2                	mov    %eax,%edx
  800fb7:	c1 ea 0c             	shr    $0xc,%edx
  800fba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fc1:	f6 c2 01             	test   $0x1,%dl
  800fc4:	74 1a                	je     800fe0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fc6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc9:	89 02                	mov    %eax,(%edx)
	return 0;
  800fcb:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd0:	eb 13                	jmp    800fe5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fd2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fd7:	eb 0c                	jmp    800fe5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fd9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fde:	eb 05                	jmp    800fe5 <fd_lookup+0x54>
  800fe0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fe5:	5d                   	pop    %ebp
  800fe6:	c3                   	ret    

00800fe7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	83 ec 08             	sub    $0x8,%esp
  800fed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ff0:	ba ac 29 80 00       	mov    $0x8029ac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ff5:	eb 13                	jmp    80100a <dev_lookup+0x23>
  800ff7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ffa:	39 08                	cmp    %ecx,(%eax)
  800ffc:	75 0c                	jne    80100a <dev_lookup+0x23>
			*dev = devtab[i];
  800ffe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801001:	89 01                	mov    %eax,(%ecx)
			return 0;
  801003:	b8 00 00 00 00       	mov    $0x0,%eax
  801008:	eb 2e                	jmp    801038 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80100a:	8b 02                	mov    (%edx),%eax
  80100c:	85 c0                	test   %eax,%eax
  80100e:	75 e7                	jne    800ff7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801010:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801015:	8b 40 48             	mov    0x48(%eax),%eax
  801018:	83 ec 04             	sub    $0x4,%esp
  80101b:	51                   	push   %ecx
  80101c:	50                   	push   %eax
  80101d:	68 2c 29 80 00       	push   $0x80292c
  801022:	e8 97 f2 ff ff       	call   8002be <cprintf>
	*dev = 0;
  801027:	8b 45 0c             	mov    0xc(%ebp),%eax
  80102a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801030:	83 c4 10             	add    $0x10,%esp
  801033:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801038:	c9                   	leave  
  801039:	c3                   	ret    

0080103a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	56                   	push   %esi
  80103e:	53                   	push   %ebx
  80103f:	83 ec 10             	sub    $0x10,%esp
  801042:	8b 75 08             	mov    0x8(%ebp),%esi
  801045:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801048:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80104b:	50                   	push   %eax
  80104c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801052:	c1 e8 0c             	shr    $0xc,%eax
  801055:	50                   	push   %eax
  801056:	e8 36 ff ff ff       	call   800f91 <fd_lookup>
  80105b:	83 c4 08             	add    $0x8,%esp
  80105e:	85 c0                	test   %eax,%eax
  801060:	78 05                	js     801067 <fd_close+0x2d>
	    || fd != fd2)
  801062:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801065:	74 0c                	je     801073 <fd_close+0x39>
		return (must_exist ? r : 0);
  801067:	84 db                	test   %bl,%bl
  801069:	ba 00 00 00 00       	mov    $0x0,%edx
  80106e:	0f 44 c2             	cmove  %edx,%eax
  801071:	eb 41                	jmp    8010b4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801073:	83 ec 08             	sub    $0x8,%esp
  801076:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801079:	50                   	push   %eax
  80107a:	ff 36                	pushl  (%esi)
  80107c:	e8 66 ff ff ff       	call   800fe7 <dev_lookup>
  801081:	89 c3                	mov    %eax,%ebx
  801083:	83 c4 10             	add    $0x10,%esp
  801086:	85 c0                	test   %eax,%eax
  801088:	78 1a                	js     8010a4 <fd_close+0x6a>
		if (dev->dev_close)
  80108a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80108d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801090:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801095:	85 c0                	test   %eax,%eax
  801097:	74 0b                	je     8010a4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801099:	83 ec 0c             	sub    $0xc,%esp
  80109c:	56                   	push   %esi
  80109d:	ff d0                	call   *%eax
  80109f:	89 c3                	mov    %eax,%ebx
  8010a1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010a4:	83 ec 08             	sub    $0x8,%esp
  8010a7:	56                   	push   %esi
  8010a8:	6a 00                	push   $0x0
  8010aa:	e8 1c fc ff ff       	call   800ccb <sys_page_unmap>
	return r;
  8010af:	83 c4 10             	add    $0x10,%esp
  8010b2:	89 d8                	mov    %ebx,%eax
}
  8010b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b7:	5b                   	pop    %ebx
  8010b8:	5e                   	pop    %esi
  8010b9:	5d                   	pop    %ebp
  8010ba:	c3                   	ret    

008010bb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c4:	50                   	push   %eax
  8010c5:	ff 75 08             	pushl  0x8(%ebp)
  8010c8:	e8 c4 fe ff ff       	call   800f91 <fd_lookup>
  8010cd:	83 c4 08             	add    $0x8,%esp
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	78 10                	js     8010e4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8010d4:	83 ec 08             	sub    $0x8,%esp
  8010d7:	6a 01                	push   $0x1
  8010d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8010dc:	e8 59 ff ff ff       	call   80103a <fd_close>
  8010e1:	83 c4 10             	add    $0x10,%esp
}
  8010e4:	c9                   	leave  
  8010e5:	c3                   	ret    

008010e6 <close_all>:

void
close_all(void)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	53                   	push   %ebx
  8010ea:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010ed:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010f2:	83 ec 0c             	sub    $0xc,%esp
  8010f5:	53                   	push   %ebx
  8010f6:	e8 c0 ff ff ff       	call   8010bb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010fb:	83 c3 01             	add    $0x1,%ebx
  8010fe:	83 c4 10             	add    $0x10,%esp
  801101:	83 fb 20             	cmp    $0x20,%ebx
  801104:	75 ec                	jne    8010f2 <close_all+0xc>
		close(i);
}
  801106:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801109:	c9                   	leave  
  80110a:	c3                   	ret    

0080110b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	57                   	push   %edi
  80110f:	56                   	push   %esi
  801110:	53                   	push   %ebx
  801111:	83 ec 2c             	sub    $0x2c,%esp
  801114:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801117:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80111a:	50                   	push   %eax
  80111b:	ff 75 08             	pushl  0x8(%ebp)
  80111e:	e8 6e fe ff ff       	call   800f91 <fd_lookup>
  801123:	83 c4 08             	add    $0x8,%esp
  801126:	85 c0                	test   %eax,%eax
  801128:	0f 88 c1 00 00 00    	js     8011ef <dup+0xe4>
		return r;
	close(newfdnum);
  80112e:	83 ec 0c             	sub    $0xc,%esp
  801131:	56                   	push   %esi
  801132:	e8 84 ff ff ff       	call   8010bb <close>

	newfd = INDEX2FD(newfdnum);
  801137:	89 f3                	mov    %esi,%ebx
  801139:	c1 e3 0c             	shl    $0xc,%ebx
  80113c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801142:	83 c4 04             	add    $0x4,%esp
  801145:	ff 75 e4             	pushl  -0x1c(%ebp)
  801148:	e8 de fd ff ff       	call   800f2b <fd2data>
  80114d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80114f:	89 1c 24             	mov    %ebx,(%esp)
  801152:	e8 d4 fd ff ff       	call   800f2b <fd2data>
  801157:	83 c4 10             	add    $0x10,%esp
  80115a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80115d:	89 f8                	mov    %edi,%eax
  80115f:	c1 e8 16             	shr    $0x16,%eax
  801162:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801169:	a8 01                	test   $0x1,%al
  80116b:	74 37                	je     8011a4 <dup+0x99>
  80116d:	89 f8                	mov    %edi,%eax
  80116f:	c1 e8 0c             	shr    $0xc,%eax
  801172:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801179:	f6 c2 01             	test   $0x1,%dl
  80117c:	74 26                	je     8011a4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80117e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801185:	83 ec 0c             	sub    $0xc,%esp
  801188:	25 07 0e 00 00       	and    $0xe07,%eax
  80118d:	50                   	push   %eax
  80118e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801191:	6a 00                	push   $0x0
  801193:	57                   	push   %edi
  801194:	6a 00                	push   $0x0
  801196:	e8 ee fa ff ff       	call   800c89 <sys_page_map>
  80119b:	89 c7                	mov    %eax,%edi
  80119d:	83 c4 20             	add    $0x20,%esp
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	78 2e                	js     8011d2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011a7:	89 d0                	mov    %edx,%eax
  8011a9:	c1 e8 0c             	shr    $0xc,%eax
  8011ac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b3:	83 ec 0c             	sub    $0xc,%esp
  8011b6:	25 07 0e 00 00       	and    $0xe07,%eax
  8011bb:	50                   	push   %eax
  8011bc:	53                   	push   %ebx
  8011bd:	6a 00                	push   $0x0
  8011bf:	52                   	push   %edx
  8011c0:	6a 00                	push   $0x0
  8011c2:	e8 c2 fa ff ff       	call   800c89 <sys_page_map>
  8011c7:	89 c7                	mov    %eax,%edi
  8011c9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8011cc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011ce:	85 ff                	test   %edi,%edi
  8011d0:	79 1d                	jns    8011ef <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011d2:	83 ec 08             	sub    $0x8,%esp
  8011d5:	53                   	push   %ebx
  8011d6:	6a 00                	push   $0x0
  8011d8:	e8 ee fa ff ff       	call   800ccb <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011dd:	83 c4 08             	add    $0x8,%esp
  8011e0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011e3:	6a 00                	push   $0x0
  8011e5:	e8 e1 fa ff ff       	call   800ccb <sys_page_unmap>
	return r;
  8011ea:	83 c4 10             	add    $0x10,%esp
  8011ed:	89 f8                	mov    %edi,%eax
}
  8011ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f2:	5b                   	pop    %ebx
  8011f3:	5e                   	pop    %esi
  8011f4:	5f                   	pop    %edi
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	53                   	push   %ebx
  8011fb:	83 ec 14             	sub    $0x14,%esp
  8011fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801201:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801204:	50                   	push   %eax
  801205:	53                   	push   %ebx
  801206:	e8 86 fd ff ff       	call   800f91 <fd_lookup>
  80120b:	83 c4 08             	add    $0x8,%esp
  80120e:	89 c2                	mov    %eax,%edx
  801210:	85 c0                	test   %eax,%eax
  801212:	78 6d                	js     801281 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801214:	83 ec 08             	sub    $0x8,%esp
  801217:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80121a:	50                   	push   %eax
  80121b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121e:	ff 30                	pushl  (%eax)
  801220:	e8 c2 fd ff ff       	call   800fe7 <dev_lookup>
  801225:	83 c4 10             	add    $0x10,%esp
  801228:	85 c0                	test   %eax,%eax
  80122a:	78 4c                	js     801278 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80122c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80122f:	8b 42 08             	mov    0x8(%edx),%eax
  801232:	83 e0 03             	and    $0x3,%eax
  801235:	83 f8 01             	cmp    $0x1,%eax
  801238:	75 21                	jne    80125b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80123a:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80123f:	8b 40 48             	mov    0x48(%eax),%eax
  801242:	83 ec 04             	sub    $0x4,%esp
  801245:	53                   	push   %ebx
  801246:	50                   	push   %eax
  801247:	68 70 29 80 00       	push   $0x802970
  80124c:	e8 6d f0 ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  801251:	83 c4 10             	add    $0x10,%esp
  801254:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801259:	eb 26                	jmp    801281 <read+0x8a>
	}
	if (!dev->dev_read)
  80125b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80125e:	8b 40 08             	mov    0x8(%eax),%eax
  801261:	85 c0                	test   %eax,%eax
  801263:	74 17                	je     80127c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801265:	83 ec 04             	sub    $0x4,%esp
  801268:	ff 75 10             	pushl  0x10(%ebp)
  80126b:	ff 75 0c             	pushl  0xc(%ebp)
  80126e:	52                   	push   %edx
  80126f:	ff d0                	call   *%eax
  801271:	89 c2                	mov    %eax,%edx
  801273:	83 c4 10             	add    $0x10,%esp
  801276:	eb 09                	jmp    801281 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801278:	89 c2                	mov    %eax,%edx
  80127a:	eb 05                	jmp    801281 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80127c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801281:	89 d0                	mov    %edx,%eax
  801283:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801286:	c9                   	leave  
  801287:	c3                   	ret    

00801288 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	57                   	push   %edi
  80128c:	56                   	push   %esi
  80128d:	53                   	push   %ebx
  80128e:	83 ec 0c             	sub    $0xc,%esp
  801291:	8b 7d 08             	mov    0x8(%ebp),%edi
  801294:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801297:	bb 00 00 00 00       	mov    $0x0,%ebx
  80129c:	eb 21                	jmp    8012bf <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80129e:	83 ec 04             	sub    $0x4,%esp
  8012a1:	89 f0                	mov    %esi,%eax
  8012a3:	29 d8                	sub    %ebx,%eax
  8012a5:	50                   	push   %eax
  8012a6:	89 d8                	mov    %ebx,%eax
  8012a8:	03 45 0c             	add    0xc(%ebp),%eax
  8012ab:	50                   	push   %eax
  8012ac:	57                   	push   %edi
  8012ad:	e8 45 ff ff ff       	call   8011f7 <read>
		if (m < 0)
  8012b2:	83 c4 10             	add    $0x10,%esp
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	78 10                	js     8012c9 <readn+0x41>
			return m;
		if (m == 0)
  8012b9:	85 c0                	test   %eax,%eax
  8012bb:	74 0a                	je     8012c7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012bd:	01 c3                	add    %eax,%ebx
  8012bf:	39 f3                	cmp    %esi,%ebx
  8012c1:	72 db                	jb     80129e <readn+0x16>
  8012c3:	89 d8                	mov    %ebx,%eax
  8012c5:	eb 02                	jmp    8012c9 <readn+0x41>
  8012c7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012cc:	5b                   	pop    %ebx
  8012cd:	5e                   	pop    %esi
  8012ce:	5f                   	pop    %edi
  8012cf:	5d                   	pop    %ebp
  8012d0:	c3                   	ret    

008012d1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012d1:	55                   	push   %ebp
  8012d2:	89 e5                	mov    %esp,%ebp
  8012d4:	53                   	push   %ebx
  8012d5:	83 ec 14             	sub    $0x14,%esp
  8012d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012de:	50                   	push   %eax
  8012df:	53                   	push   %ebx
  8012e0:	e8 ac fc ff ff       	call   800f91 <fd_lookup>
  8012e5:	83 c4 08             	add    $0x8,%esp
  8012e8:	89 c2                	mov    %eax,%edx
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	78 68                	js     801356 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ee:	83 ec 08             	sub    $0x8,%esp
  8012f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f4:	50                   	push   %eax
  8012f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f8:	ff 30                	pushl  (%eax)
  8012fa:	e8 e8 fc ff ff       	call   800fe7 <dev_lookup>
  8012ff:	83 c4 10             	add    $0x10,%esp
  801302:	85 c0                	test   %eax,%eax
  801304:	78 47                	js     80134d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801306:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801309:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80130d:	75 21                	jne    801330 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80130f:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801314:	8b 40 48             	mov    0x48(%eax),%eax
  801317:	83 ec 04             	sub    $0x4,%esp
  80131a:	53                   	push   %ebx
  80131b:	50                   	push   %eax
  80131c:	68 8c 29 80 00       	push   $0x80298c
  801321:	e8 98 ef ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80132e:	eb 26                	jmp    801356 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801330:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801333:	8b 52 0c             	mov    0xc(%edx),%edx
  801336:	85 d2                	test   %edx,%edx
  801338:	74 17                	je     801351 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80133a:	83 ec 04             	sub    $0x4,%esp
  80133d:	ff 75 10             	pushl  0x10(%ebp)
  801340:	ff 75 0c             	pushl  0xc(%ebp)
  801343:	50                   	push   %eax
  801344:	ff d2                	call   *%edx
  801346:	89 c2                	mov    %eax,%edx
  801348:	83 c4 10             	add    $0x10,%esp
  80134b:	eb 09                	jmp    801356 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134d:	89 c2                	mov    %eax,%edx
  80134f:	eb 05                	jmp    801356 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801351:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801356:	89 d0                	mov    %edx,%eax
  801358:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135b:	c9                   	leave  
  80135c:	c3                   	ret    

0080135d <seek>:

int
seek(int fdnum, off_t offset)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801363:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801366:	50                   	push   %eax
  801367:	ff 75 08             	pushl  0x8(%ebp)
  80136a:	e8 22 fc ff ff       	call   800f91 <fd_lookup>
  80136f:	83 c4 08             	add    $0x8,%esp
  801372:	85 c0                	test   %eax,%eax
  801374:	78 0e                	js     801384 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801376:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801379:	8b 55 0c             	mov    0xc(%ebp),%edx
  80137c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80137f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801384:	c9                   	leave  
  801385:	c3                   	ret    

00801386 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	53                   	push   %ebx
  80138a:	83 ec 14             	sub    $0x14,%esp
  80138d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801390:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801393:	50                   	push   %eax
  801394:	53                   	push   %ebx
  801395:	e8 f7 fb ff ff       	call   800f91 <fd_lookup>
  80139a:	83 c4 08             	add    $0x8,%esp
  80139d:	89 c2                	mov    %eax,%edx
  80139f:	85 c0                	test   %eax,%eax
  8013a1:	78 65                	js     801408 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a3:	83 ec 08             	sub    $0x8,%esp
  8013a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a9:	50                   	push   %eax
  8013aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ad:	ff 30                	pushl  (%eax)
  8013af:	e8 33 fc ff ff       	call   800fe7 <dev_lookup>
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	78 44                	js     8013ff <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013be:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013c2:	75 21                	jne    8013e5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013c4:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013c9:	8b 40 48             	mov    0x48(%eax),%eax
  8013cc:	83 ec 04             	sub    $0x4,%esp
  8013cf:	53                   	push   %ebx
  8013d0:	50                   	push   %eax
  8013d1:	68 4c 29 80 00       	push   $0x80294c
  8013d6:	e8 e3 ee ff ff       	call   8002be <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013db:	83 c4 10             	add    $0x10,%esp
  8013de:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013e3:	eb 23                	jmp    801408 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013e8:	8b 52 18             	mov    0x18(%edx),%edx
  8013eb:	85 d2                	test   %edx,%edx
  8013ed:	74 14                	je     801403 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013ef:	83 ec 08             	sub    $0x8,%esp
  8013f2:	ff 75 0c             	pushl  0xc(%ebp)
  8013f5:	50                   	push   %eax
  8013f6:	ff d2                	call   *%edx
  8013f8:	89 c2                	mov    %eax,%edx
  8013fa:	83 c4 10             	add    $0x10,%esp
  8013fd:	eb 09                	jmp    801408 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ff:	89 c2                	mov    %eax,%edx
  801401:	eb 05                	jmp    801408 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801403:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801408:	89 d0                	mov    %edx,%eax
  80140a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140d:	c9                   	leave  
  80140e:	c3                   	ret    

0080140f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80140f:	55                   	push   %ebp
  801410:	89 e5                	mov    %esp,%ebp
  801412:	53                   	push   %ebx
  801413:	83 ec 14             	sub    $0x14,%esp
  801416:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801419:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141c:	50                   	push   %eax
  80141d:	ff 75 08             	pushl  0x8(%ebp)
  801420:	e8 6c fb ff ff       	call   800f91 <fd_lookup>
  801425:	83 c4 08             	add    $0x8,%esp
  801428:	89 c2                	mov    %eax,%edx
  80142a:	85 c0                	test   %eax,%eax
  80142c:	78 58                	js     801486 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142e:	83 ec 08             	sub    $0x8,%esp
  801431:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801434:	50                   	push   %eax
  801435:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801438:	ff 30                	pushl  (%eax)
  80143a:	e8 a8 fb ff ff       	call   800fe7 <dev_lookup>
  80143f:	83 c4 10             	add    $0x10,%esp
  801442:	85 c0                	test   %eax,%eax
  801444:	78 37                	js     80147d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801446:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801449:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80144d:	74 32                	je     801481 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80144f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801452:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801459:	00 00 00 
	stat->st_isdir = 0;
  80145c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801463:	00 00 00 
	stat->st_dev = dev;
  801466:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80146c:	83 ec 08             	sub    $0x8,%esp
  80146f:	53                   	push   %ebx
  801470:	ff 75 f0             	pushl  -0x10(%ebp)
  801473:	ff 50 14             	call   *0x14(%eax)
  801476:	89 c2                	mov    %eax,%edx
  801478:	83 c4 10             	add    $0x10,%esp
  80147b:	eb 09                	jmp    801486 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80147d:	89 c2                	mov    %eax,%edx
  80147f:	eb 05                	jmp    801486 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801481:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801486:	89 d0                	mov    %edx,%eax
  801488:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148b:	c9                   	leave  
  80148c:	c3                   	ret    

0080148d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80148d:	55                   	push   %ebp
  80148e:	89 e5                	mov    %esp,%ebp
  801490:	56                   	push   %esi
  801491:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801492:	83 ec 08             	sub    $0x8,%esp
  801495:	6a 00                	push   $0x0
  801497:	ff 75 08             	pushl  0x8(%ebp)
  80149a:	e8 0c 02 00 00       	call   8016ab <open>
  80149f:	89 c3                	mov    %eax,%ebx
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 1b                	js     8014c3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014a8:	83 ec 08             	sub    $0x8,%esp
  8014ab:	ff 75 0c             	pushl  0xc(%ebp)
  8014ae:	50                   	push   %eax
  8014af:	e8 5b ff ff ff       	call   80140f <fstat>
  8014b4:	89 c6                	mov    %eax,%esi
	close(fd);
  8014b6:	89 1c 24             	mov    %ebx,(%esp)
  8014b9:	e8 fd fb ff ff       	call   8010bb <close>
	return r;
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	89 f0                	mov    %esi,%eax
}
  8014c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014c6:	5b                   	pop    %ebx
  8014c7:	5e                   	pop    %esi
  8014c8:	5d                   	pop    %ebp
  8014c9:	c3                   	ret    

008014ca <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	56                   	push   %esi
  8014ce:	53                   	push   %ebx
  8014cf:	89 c6                	mov    %eax,%esi
  8014d1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014d3:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8014da:	75 12                	jne    8014ee <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014dc:	83 ec 0c             	sub    $0xc,%esp
  8014df:	6a 01                	push   $0x1
  8014e1:	e8 7c 0d 00 00       	call   802262 <ipc_find_env>
  8014e6:	a3 04 40 80 00       	mov    %eax,0x804004
  8014eb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014ee:	6a 07                	push   $0x7
  8014f0:	68 00 50 80 00       	push   $0x805000
  8014f5:	56                   	push   %esi
  8014f6:	ff 35 04 40 80 00    	pushl  0x804004
  8014fc:	e8 0d 0d 00 00       	call   80220e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801501:	83 c4 0c             	add    $0xc,%esp
  801504:	6a 00                	push   $0x0
  801506:	53                   	push   %ebx
  801507:	6a 00                	push   $0x0
  801509:	e8 97 0c 00 00       	call   8021a5 <ipc_recv>
}
  80150e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801511:	5b                   	pop    %ebx
  801512:	5e                   	pop    %esi
  801513:	5d                   	pop    %ebp
  801514:	c3                   	ret    

00801515 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80151b:	8b 45 08             	mov    0x8(%ebp),%eax
  80151e:	8b 40 0c             	mov    0xc(%eax),%eax
  801521:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801526:	8b 45 0c             	mov    0xc(%ebp),%eax
  801529:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80152e:	ba 00 00 00 00       	mov    $0x0,%edx
  801533:	b8 02 00 00 00       	mov    $0x2,%eax
  801538:	e8 8d ff ff ff       	call   8014ca <fsipc>
}
  80153d:	c9                   	leave  
  80153e:	c3                   	ret    

0080153f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801545:	8b 45 08             	mov    0x8(%ebp),%eax
  801548:	8b 40 0c             	mov    0xc(%eax),%eax
  80154b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801550:	ba 00 00 00 00       	mov    $0x0,%edx
  801555:	b8 06 00 00 00       	mov    $0x6,%eax
  80155a:	e8 6b ff ff ff       	call   8014ca <fsipc>
}
  80155f:	c9                   	leave  
  801560:	c3                   	ret    

00801561 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801561:	55                   	push   %ebp
  801562:	89 e5                	mov    %esp,%ebp
  801564:	53                   	push   %ebx
  801565:	83 ec 04             	sub    $0x4,%esp
  801568:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80156b:	8b 45 08             	mov    0x8(%ebp),%eax
  80156e:	8b 40 0c             	mov    0xc(%eax),%eax
  801571:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801576:	ba 00 00 00 00       	mov    $0x0,%edx
  80157b:	b8 05 00 00 00       	mov    $0x5,%eax
  801580:	e8 45 ff ff ff       	call   8014ca <fsipc>
  801585:	85 c0                	test   %eax,%eax
  801587:	78 2c                	js     8015b5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801589:	83 ec 08             	sub    $0x8,%esp
  80158c:	68 00 50 80 00       	push   $0x805000
  801591:	53                   	push   %ebx
  801592:	e8 ac f2 ff ff       	call   800843 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801597:	a1 80 50 80 00       	mov    0x805080,%eax
  80159c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015a2:	a1 84 50 80 00       	mov    0x805084,%eax
  8015a7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b8:	c9                   	leave  
  8015b9:	c3                   	ret    

008015ba <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015ba:	55                   	push   %ebp
  8015bb:	89 e5                	mov    %esp,%ebp
  8015bd:	53                   	push   %ebx
  8015be:	83 ec 08             	sub    $0x8,%esp
  8015c1:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8015c7:	8b 52 0c             	mov    0xc(%edx),%edx
  8015ca:	89 15 00 50 80 00    	mov    %edx,0x805000
  8015d0:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015d5:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8015da:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8015dd:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8015e3:	53                   	push   %ebx
  8015e4:	ff 75 0c             	pushl  0xc(%ebp)
  8015e7:	68 08 50 80 00       	push   $0x805008
  8015ec:	e8 e4 f3 ff ff       	call   8009d5 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  8015f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f6:	b8 04 00 00 00       	mov    $0x4,%eax
  8015fb:	e8 ca fe ff ff       	call   8014ca <fsipc>
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	85 c0                	test   %eax,%eax
  801605:	78 1d                	js     801624 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  801607:	39 d8                	cmp    %ebx,%eax
  801609:	76 19                	jbe    801624 <devfile_write+0x6a>
  80160b:	68 c0 29 80 00       	push   $0x8029c0
  801610:	68 cc 29 80 00       	push   $0x8029cc
  801615:	68 a5 00 00 00       	push   $0xa5
  80161a:	68 e1 29 80 00       	push   $0x8029e1
  80161f:	e8 c1 eb ff ff       	call   8001e5 <_panic>
	return r;
}
  801624:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801627:	c9                   	leave  
  801628:	c3                   	ret    

00801629 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801629:	55                   	push   %ebp
  80162a:	89 e5                	mov    %esp,%ebp
  80162c:	56                   	push   %esi
  80162d:	53                   	push   %ebx
  80162e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801631:	8b 45 08             	mov    0x8(%ebp),%eax
  801634:	8b 40 0c             	mov    0xc(%eax),%eax
  801637:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80163c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801642:	ba 00 00 00 00       	mov    $0x0,%edx
  801647:	b8 03 00 00 00       	mov    $0x3,%eax
  80164c:	e8 79 fe ff ff       	call   8014ca <fsipc>
  801651:	89 c3                	mov    %eax,%ebx
  801653:	85 c0                	test   %eax,%eax
  801655:	78 4b                	js     8016a2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801657:	39 c6                	cmp    %eax,%esi
  801659:	73 16                	jae    801671 <devfile_read+0x48>
  80165b:	68 ec 29 80 00       	push   $0x8029ec
  801660:	68 cc 29 80 00       	push   $0x8029cc
  801665:	6a 7c                	push   $0x7c
  801667:	68 e1 29 80 00       	push   $0x8029e1
  80166c:	e8 74 eb ff ff       	call   8001e5 <_panic>
	assert(r <= PGSIZE);
  801671:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801676:	7e 16                	jle    80168e <devfile_read+0x65>
  801678:	68 f3 29 80 00       	push   $0x8029f3
  80167d:	68 cc 29 80 00       	push   $0x8029cc
  801682:	6a 7d                	push   $0x7d
  801684:	68 e1 29 80 00       	push   $0x8029e1
  801689:	e8 57 eb ff ff       	call   8001e5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80168e:	83 ec 04             	sub    $0x4,%esp
  801691:	50                   	push   %eax
  801692:	68 00 50 80 00       	push   $0x805000
  801697:	ff 75 0c             	pushl  0xc(%ebp)
  80169a:	e8 36 f3 ff ff       	call   8009d5 <memmove>
	return r;
  80169f:	83 c4 10             	add    $0x10,%esp
}
  8016a2:	89 d8                	mov    %ebx,%eax
  8016a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a7:	5b                   	pop    %ebx
  8016a8:	5e                   	pop    %esi
  8016a9:	5d                   	pop    %ebp
  8016aa:	c3                   	ret    

008016ab <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	53                   	push   %ebx
  8016af:	83 ec 20             	sub    $0x20,%esp
  8016b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016b5:	53                   	push   %ebx
  8016b6:	e8 4f f1 ff ff       	call   80080a <strlen>
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016c3:	7f 67                	jg     80172c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016c5:	83 ec 0c             	sub    $0xc,%esp
  8016c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cb:	50                   	push   %eax
  8016cc:	e8 71 f8 ff ff       	call   800f42 <fd_alloc>
  8016d1:	83 c4 10             	add    $0x10,%esp
		return r;
  8016d4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 57                	js     801731 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016da:	83 ec 08             	sub    $0x8,%esp
  8016dd:	53                   	push   %ebx
  8016de:	68 00 50 80 00       	push   $0x805000
  8016e3:	e8 5b f1 ff ff       	call   800843 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016eb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8016f8:	e8 cd fd ff ff       	call   8014ca <fsipc>
  8016fd:	89 c3                	mov    %eax,%ebx
  8016ff:	83 c4 10             	add    $0x10,%esp
  801702:	85 c0                	test   %eax,%eax
  801704:	79 14                	jns    80171a <open+0x6f>
		fd_close(fd, 0);
  801706:	83 ec 08             	sub    $0x8,%esp
  801709:	6a 00                	push   $0x0
  80170b:	ff 75 f4             	pushl  -0xc(%ebp)
  80170e:	e8 27 f9 ff ff       	call   80103a <fd_close>
		return r;
  801713:	83 c4 10             	add    $0x10,%esp
  801716:	89 da                	mov    %ebx,%edx
  801718:	eb 17                	jmp    801731 <open+0x86>
	}

	return fd2num(fd);
  80171a:	83 ec 0c             	sub    $0xc,%esp
  80171d:	ff 75 f4             	pushl  -0xc(%ebp)
  801720:	e8 f6 f7 ff ff       	call   800f1b <fd2num>
  801725:	89 c2                	mov    %eax,%edx
  801727:	83 c4 10             	add    $0x10,%esp
  80172a:	eb 05                	jmp    801731 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80172c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801731:	89 d0                	mov    %edx,%eax
  801733:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801736:	c9                   	leave  
  801737:	c3                   	ret    

00801738 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801738:	55                   	push   %ebp
  801739:	89 e5                	mov    %esp,%ebp
  80173b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80173e:	ba 00 00 00 00       	mov    $0x0,%edx
  801743:	b8 08 00 00 00       	mov    $0x8,%eax
  801748:	e8 7d fd ff ff       	call   8014ca <fsipc>
}
  80174d:	c9                   	leave  
  80174e:	c3                   	ret    

0080174f <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80174f:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801753:	7e 37                	jle    80178c <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	53                   	push   %ebx
  801759:	83 ec 08             	sub    $0x8,%esp
  80175c:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80175e:	ff 70 04             	pushl  0x4(%eax)
  801761:	8d 40 10             	lea    0x10(%eax),%eax
  801764:	50                   	push   %eax
  801765:	ff 33                	pushl  (%ebx)
  801767:	e8 65 fb ff ff       	call   8012d1 <write>
		if (result > 0)
  80176c:	83 c4 10             	add    $0x10,%esp
  80176f:	85 c0                	test   %eax,%eax
  801771:	7e 03                	jle    801776 <writebuf+0x27>
			b->result += result;
  801773:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801776:	3b 43 04             	cmp    0x4(%ebx),%eax
  801779:	74 0d                	je     801788 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80177b:	85 c0                	test   %eax,%eax
  80177d:	ba 00 00 00 00       	mov    $0x0,%edx
  801782:	0f 4f c2             	cmovg  %edx,%eax
  801785:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801788:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178b:	c9                   	leave  
  80178c:	f3 c3                	repz ret 

0080178e <putch>:

static void
putch(int ch, void *thunk)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	53                   	push   %ebx
  801792:	83 ec 04             	sub    $0x4,%esp
  801795:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801798:	8b 53 04             	mov    0x4(%ebx),%edx
  80179b:	8d 42 01             	lea    0x1(%edx),%eax
  80179e:	89 43 04             	mov    %eax,0x4(%ebx)
  8017a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017a4:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8017a8:	3d 00 01 00 00       	cmp    $0x100,%eax
  8017ad:	75 0e                	jne    8017bd <putch+0x2f>
		writebuf(b);
  8017af:	89 d8                	mov    %ebx,%eax
  8017b1:	e8 99 ff ff ff       	call   80174f <writebuf>
		b->idx = 0;
  8017b6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8017bd:	83 c4 04             	add    $0x4,%esp
  8017c0:	5b                   	pop    %ebx
  8017c1:	5d                   	pop    %ebp
  8017c2:	c3                   	ret    

008017c3 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8017cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cf:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8017d5:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8017dc:	00 00 00 
	b.result = 0;
  8017df:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017e6:	00 00 00 
	b.error = 1;
  8017e9:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8017f0:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8017f3:	ff 75 10             	pushl  0x10(%ebp)
  8017f6:	ff 75 0c             	pushl  0xc(%ebp)
  8017f9:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017ff:	50                   	push   %eax
  801800:	68 8e 17 80 00       	push   $0x80178e
  801805:	e8 eb eb ff ff       	call   8003f5 <vprintfmt>
	if (b.idx > 0)
  80180a:	83 c4 10             	add    $0x10,%esp
  80180d:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801814:	7e 0b                	jle    801821 <vfprintf+0x5e>
		writebuf(&b);
  801816:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80181c:	e8 2e ff ff ff       	call   80174f <writebuf>

	return (b.result ? b.result : b.error);
  801821:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801827:	85 c0                	test   %eax,%eax
  801829:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801830:	c9                   	leave  
  801831:	c3                   	ret    

00801832 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801832:	55                   	push   %ebp
  801833:	89 e5                	mov    %esp,%ebp
  801835:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801838:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80183b:	50                   	push   %eax
  80183c:	ff 75 0c             	pushl  0xc(%ebp)
  80183f:	ff 75 08             	pushl  0x8(%ebp)
  801842:	e8 7c ff ff ff       	call   8017c3 <vfprintf>
	va_end(ap);

	return cnt;
}
  801847:	c9                   	leave  
  801848:	c3                   	ret    

00801849 <printf>:

int
printf(const char *fmt, ...)
{
  801849:	55                   	push   %ebp
  80184a:	89 e5                	mov    %esp,%ebp
  80184c:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80184f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801852:	50                   	push   %eax
  801853:	ff 75 08             	pushl  0x8(%ebp)
  801856:	6a 01                	push   $0x1
  801858:	e8 66 ff ff ff       	call   8017c3 <vfprintf>
	va_end(ap);

	return cnt;
}
  80185d:	c9                   	leave  
  80185e:	c3                   	ret    

0080185f <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801865:	68 ff 29 80 00       	push   $0x8029ff
  80186a:	ff 75 0c             	pushl  0xc(%ebp)
  80186d:	e8 d1 ef ff ff       	call   800843 <strcpy>
	return 0;
}
  801872:	b8 00 00 00 00       	mov    $0x0,%eax
  801877:	c9                   	leave  
  801878:	c3                   	ret    

00801879 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	53                   	push   %ebx
  80187d:	83 ec 10             	sub    $0x10,%esp
  801880:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801883:	53                   	push   %ebx
  801884:	e8 12 0a 00 00       	call   80229b <pageref>
  801889:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80188c:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801891:	83 f8 01             	cmp    $0x1,%eax
  801894:	75 10                	jne    8018a6 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801896:	83 ec 0c             	sub    $0xc,%esp
  801899:	ff 73 0c             	pushl  0xc(%ebx)
  80189c:	e8 c0 02 00 00       	call   801b61 <nsipc_close>
  8018a1:	89 c2                	mov    %eax,%edx
  8018a3:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8018a6:	89 d0                	mov    %edx,%eax
  8018a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ab:	c9                   	leave  
  8018ac:	c3                   	ret    

008018ad <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8018ad:	55                   	push   %ebp
  8018ae:	89 e5                	mov    %esp,%ebp
  8018b0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8018b3:	6a 00                	push   $0x0
  8018b5:	ff 75 10             	pushl  0x10(%ebp)
  8018b8:	ff 75 0c             	pushl  0xc(%ebp)
  8018bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018be:	ff 70 0c             	pushl  0xc(%eax)
  8018c1:	e8 78 03 00 00       	call   801c3e <nsipc_send>
}
  8018c6:	c9                   	leave  
  8018c7:	c3                   	ret    

008018c8 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8018ce:	6a 00                	push   $0x0
  8018d0:	ff 75 10             	pushl  0x10(%ebp)
  8018d3:	ff 75 0c             	pushl  0xc(%ebp)
  8018d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d9:	ff 70 0c             	pushl  0xc(%eax)
  8018dc:	e8 f1 02 00 00       	call   801bd2 <nsipc_recv>
}
  8018e1:	c9                   	leave  
  8018e2:	c3                   	ret    

008018e3 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8018e9:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8018ec:	52                   	push   %edx
  8018ed:	50                   	push   %eax
  8018ee:	e8 9e f6 ff ff       	call   800f91 <fd_lookup>
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	85 c0                	test   %eax,%eax
  8018f8:	78 17                	js     801911 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8018fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018fd:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  801903:	39 08                	cmp    %ecx,(%eax)
  801905:	75 05                	jne    80190c <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801907:	8b 40 0c             	mov    0xc(%eax),%eax
  80190a:	eb 05                	jmp    801911 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80190c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801911:	c9                   	leave  
  801912:	c3                   	ret    

00801913 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801913:	55                   	push   %ebp
  801914:	89 e5                	mov    %esp,%ebp
  801916:	56                   	push   %esi
  801917:	53                   	push   %ebx
  801918:	83 ec 1c             	sub    $0x1c,%esp
  80191b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80191d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801920:	50                   	push   %eax
  801921:	e8 1c f6 ff ff       	call   800f42 <fd_alloc>
  801926:	89 c3                	mov    %eax,%ebx
  801928:	83 c4 10             	add    $0x10,%esp
  80192b:	85 c0                	test   %eax,%eax
  80192d:	78 1b                	js     80194a <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80192f:	83 ec 04             	sub    $0x4,%esp
  801932:	68 07 04 00 00       	push   $0x407
  801937:	ff 75 f4             	pushl  -0xc(%ebp)
  80193a:	6a 00                	push   $0x0
  80193c:	e8 05 f3 ff ff       	call   800c46 <sys_page_alloc>
  801941:	89 c3                	mov    %eax,%ebx
  801943:	83 c4 10             	add    $0x10,%esp
  801946:	85 c0                	test   %eax,%eax
  801948:	79 10                	jns    80195a <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80194a:	83 ec 0c             	sub    $0xc,%esp
  80194d:	56                   	push   %esi
  80194e:	e8 0e 02 00 00       	call   801b61 <nsipc_close>
		return r;
  801953:	83 c4 10             	add    $0x10,%esp
  801956:	89 d8                	mov    %ebx,%eax
  801958:	eb 24                	jmp    80197e <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80195a:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801960:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801963:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801965:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801968:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80196f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801972:	83 ec 0c             	sub    $0xc,%esp
  801975:	50                   	push   %eax
  801976:	e8 a0 f5 ff ff       	call   800f1b <fd2num>
  80197b:	83 c4 10             	add    $0x10,%esp
}
  80197e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801981:	5b                   	pop    %ebx
  801982:	5e                   	pop    %esi
  801983:	5d                   	pop    %ebp
  801984:	c3                   	ret    

00801985 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801985:	55                   	push   %ebp
  801986:	89 e5                	mov    %esp,%ebp
  801988:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80198b:	8b 45 08             	mov    0x8(%ebp),%eax
  80198e:	e8 50 ff ff ff       	call   8018e3 <fd2sockid>
		return r;
  801993:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801995:	85 c0                	test   %eax,%eax
  801997:	78 1f                	js     8019b8 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801999:	83 ec 04             	sub    $0x4,%esp
  80199c:	ff 75 10             	pushl  0x10(%ebp)
  80199f:	ff 75 0c             	pushl  0xc(%ebp)
  8019a2:	50                   	push   %eax
  8019a3:	e8 12 01 00 00       	call   801aba <nsipc_accept>
  8019a8:	83 c4 10             	add    $0x10,%esp
		return r;
  8019ab:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019ad:	85 c0                	test   %eax,%eax
  8019af:	78 07                	js     8019b8 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8019b1:	e8 5d ff ff ff       	call   801913 <alloc_sockfd>
  8019b6:	89 c1                	mov    %eax,%ecx
}
  8019b8:	89 c8                	mov    %ecx,%eax
  8019ba:	c9                   	leave  
  8019bb:	c3                   	ret    

008019bc <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c5:	e8 19 ff ff ff       	call   8018e3 <fd2sockid>
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	78 12                	js     8019e0 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8019ce:	83 ec 04             	sub    $0x4,%esp
  8019d1:	ff 75 10             	pushl  0x10(%ebp)
  8019d4:	ff 75 0c             	pushl  0xc(%ebp)
  8019d7:	50                   	push   %eax
  8019d8:	e8 2d 01 00 00       	call   801b0a <nsipc_bind>
  8019dd:	83 c4 10             	add    $0x10,%esp
}
  8019e0:	c9                   	leave  
  8019e1:	c3                   	ret    

008019e2 <shutdown>:

int
shutdown(int s, int how)
{
  8019e2:	55                   	push   %ebp
  8019e3:	89 e5                	mov    %esp,%ebp
  8019e5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019eb:	e8 f3 fe ff ff       	call   8018e3 <fd2sockid>
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	78 0f                	js     801a03 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8019f4:	83 ec 08             	sub    $0x8,%esp
  8019f7:	ff 75 0c             	pushl  0xc(%ebp)
  8019fa:	50                   	push   %eax
  8019fb:	e8 3f 01 00 00       	call   801b3f <nsipc_shutdown>
  801a00:	83 c4 10             	add    $0x10,%esp
}
  801a03:	c9                   	leave  
  801a04:	c3                   	ret    

00801a05 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a05:	55                   	push   %ebp
  801a06:	89 e5                	mov    %esp,%ebp
  801a08:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0e:	e8 d0 fe ff ff       	call   8018e3 <fd2sockid>
  801a13:	85 c0                	test   %eax,%eax
  801a15:	78 12                	js     801a29 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801a17:	83 ec 04             	sub    $0x4,%esp
  801a1a:	ff 75 10             	pushl  0x10(%ebp)
  801a1d:	ff 75 0c             	pushl  0xc(%ebp)
  801a20:	50                   	push   %eax
  801a21:	e8 55 01 00 00       	call   801b7b <nsipc_connect>
  801a26:	83 c4 10             	add    $0x10,%esp
}
  801a29:	c9                   	leave  
  801a2a:	c3                   	ret    

00801a2b <listen>:

int
listen(int s, int backlog)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a31:	8b 45 08             	mov    0x8(%ebp),%eax
  801a34:	e8 aa fe ff ff       	call   8018e3 <fd2sockid>
  801a39:	85 c0                	test   %eax,%eax
  801a3b:	78 0f                	js     801a4c <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801a3d:	83 ec 08             	sub    $0x8,%esp
  801a40:	ff 75 0c             	pushl  0xc(%ebp)
  801a43:	50                   	push   %eax
  801a44:	e8 67 01 00 00       	call   801bb0 <nsipc_listen>
  801a49:	83 c4 10             	add    $0x10,%esp
}
  801a4c:	c9                   	leave  
  801a4d:	c3                   	ret    

00801a4e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a4e:	55                   	push   %ebp
  801a4f:	89 e5                	mov    %esp,%ebp
  801a51:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a54:	ff 75 10             	pushl  0x10(%ebp)
  801a57:	ff 75 0c             	pushl  0xc(%ebp)
  801a5a:	ff 75 08             	pushl  0x8(%ebp)
  801a5d:	e8 3a 02 00 00       	call   801c9c <nsipc_socket>
  801a62:	83 c4 10             	add    $0x10,%esp
  801a65:	85 c0                	test   %eax,%eax
  801a67:	78 05                	js     801a6e <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a69:	e8 a5 fe ff ff       	call   801913 <alloc_sockfd>
}
  801a6e:	c9                   	leave  
  801a6f:	c3                   	ret    

00801a70 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	53                   	push   %ebx
  801a74:	83 ec 04             	sub    $0x4,%esp
  801a77:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a79:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  801a80:	75 12                	jne    801a94 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a82:	83 ec 0c             	sub    $0xc,%esp
  801a85:	6a 02                	push   $0x2
  801a87:	e8 d6 07 00 00       	call   802262 <ipc_find_env>
  801a8c:	a3 08 40 80 00       	mov    %eax,0x804008
  801a91:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a94:	6a 07                	push   $0x7
  801a96:	68 00 60 80 00       	push   $0x806000
  801a9b:	53                   	push   %ebx
  801a9c:	ff 35 08 40 80 00    	pushl  0x804008
  801aa2:	e8 67 07 00 00       	call   80220e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801aa7:	83 c4 0c             	add    $0xc,%esp
  801aaa:	6a 00                	push   $0x0
  801aac:	6a 00                	push   $0x0
  801aae:	6a 00                	push   $0x0
  801ab0:	e8 f0 06 00 00       	call   8021a5 <ipc_recv>
}
  801ab5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab8:	c9                   	leave  
  801ab9:	c3                   	ret    

00801aba <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801aba:	55                   	push   %ebp
  801abb:	89 e5                	mov    %esp,%ebp
  801abd:	56                   	push   %esi
  801abe:	53                   	push   %ebx
  801abf:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801aca:	8b 06                	mov    (%esi),%eax
  801acc:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ad1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ad6:	e8 95 ff ff ff       	call   801a70 <nsipc>
  801adb:	89 c3                	mov    %eax,%ebx
  801add:	85 c0                	test   %eax,%eax
  801adf:	78 20                	js     801b01 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ae1:	83 ec 04             	sub    $0x4,%esp
  801ae4:	ff 35 10 60 80 00    	pushl  0x806010
  801aea:	68 00 60 80 00       	push   $0x806000
  801aef:	ff 75 0c             	pushl  0xc(%ebp)
  801af2:	e8 de ee ff ff       	call   8009d5 <memmove>
		*addrlen = ret->ret_addrlen;
  801af7:	a1 10 60 80 00       	mov    0x806010,%eax
  801afc:	89 06                	mov    %eax,(%esi)
  801afe:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801b01:	89 d8                	mov    %ebx,%eax
  801b03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b06:	5b                   	pop    %ebx
  801b07:	5e                   	pop    %esi
  801b08:	5d                   	pop    %ebp
  801b09:	c3                   	ret    

00801b0a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b0a:	55                   	push   %ebp
  801b0b:	89 e5                	mov    %esp,%ebp
  801b0d:	53                   	push   %ebx
  801b0e:	83 ec 08             	sub    $0x8,%esp
  801b11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b14:	8b 45 08             	mov    0x8(%ebp),%eax
  801b17:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b1c:	53                   	push   %ebx
  801b1d:	ff 75 0c             	pushl  0xc(%ebp)
  801b20:	68 04 60 80 00       	push   $0x806004
  801b25:	e8 ab ee ff ff       	call   8009d5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b2a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b30:	b8 02 00 00 00       	mov    $0x2,%eax
  801b35:	e8 36 ff ff ff       	call   801a70 <nsipc>
}
  801b3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b3d:	c9                   	leave  
  801b3e:	c3                   	ret    

00801b3f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b3f:	55                   	push   %ebp
  801b40:	89 e5                	mov    %esp,%ebp
  801b42:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b45:	8b 45 08             	mov    0x8(%ebp),%eax
  801b48:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801b4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b50:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b55:	b8 03 00 00 00       	mov    $0x3,%eax
  801b5a:	e8 11 ff ff ff       	call   801a70 <nsipc>
}
  801b5f:	c9                   	leave  
  801b60:	c3                   	ret    

00801b61 <nsipc_close>:

int
nsipc_close(int s)
{
  801b61:	55                   	push   %ebp
  801b62:	89 e5                	mov    %esp,%ebp
  801b64:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b67:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6a:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b6f:	b8 04 00 00 00       	mov    $0x4,%eax
  801b74:	e8 f7 fe ff ff       	call   801a70 <nsipc>
}
  801b79:	c9                   	leave  
  801b7a:	c3                   	ret    

00801b7b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	53                   	push   %ebx
  801b7f:	83 ec 08             	sub    $0x8,%esp
  801b82:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b85:	8b 45 08             	mov    0x8(%ebp),%eax
  801b88:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b8d:	53                   	push   %ebx
  801b8e:	ff 75 0c             	pushl  0xc(%ebp)
  801b91:	68 04 60 80 00       	push   $0x806004
  801b96:	e8 3a ee ff ff       	call   8009d5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b9b:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801ba1:	b8 05 00 00 00       	mov    $0x5,%eax
  801ba6:	e8 c5 fe ff ff       	call   801a70 <nsipc>
}
  801bab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bae:	c9                   	leave  
  801baf:	c3                   	ret    

00801bb0 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801bbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801bc6:	b8 06 00 00 00       	mov    $0x6,%eax
  801bcb:	e8 a0 fe ff ff       	call   801a70 <nsipc>
}
  801bd0:	c9                   	leave  
  801bd1:	c3                   	ret    

00801bd2 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	56                   	push   %esi
  801bd6:	53                   	push   %ebx
  801bd7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801bda:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801be2:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801be8:	8b 45 14             	mov    0x14(%ebp),%eax
  801beb:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801bf0:	b8 07 00 00 00       	mov    $0x7,%eax
  801bf5:	e8 76 fe ff ff       	call   801a70 <nsipc>
  801bfa:	89 c3                	mov    %eax,%ebx
  801bfc:	85 c0                	test   %eax,%eax
  801bfe:	78 35                	js     801c35 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801c00:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801c05:	7f 04                	jg     801c0b <nsipc_recv+0x39>
  801c07:	39 c6                	cmp    %eax,%esi
  801c09:	7d 16                	jge    801c21 <nsipc_recv+0x4f>
  801c0b:	68 0b 2a 80 00       	push   $0x802a0b
  801c10:	68 cc 29 80 00       	push   $0x8029cc
  801c15:	6a 62                	push   $0x62
  801c17:	68 20 2a 80 00       	push   $0x802a20
  801c1c:	e8 c4 e5 ff ff       	call   8001e5 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c21:	83 ec 04             	sub    $0x4,%esp
  801c24:	50                   	push   %eax
  801c25:	68 00 60 80 00       	push   $0x806000
  801c2a:	ff 75 0c             	pushl  0xc(%ebp)
  801c2d:	e8 a3 ed ff ff       	call   8009d5 <memmove>
  801c32:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c35:	89 d8                	mov    %ebx,%eax
  801c37:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c3a:	5b                   	pop    %ebx
  801c3b:	5e                   	pop    %esi
  801c3c:	5d                   	pop    %ebp
  801c3d:	c3                   	ret    

00801c3e <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	53                   	push   %ebx
  801c42:	83 ec 04             	sub    $0x4,%esp
  801c45:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c48:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c50:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c56:	7e 16                	jle    801c6e <nsipc_send+0x30>
  801c58:	68 2c 2a 80 00       	push   $0x802a2c
  801c5d:	68 cc 29 80 00       	push   $0x8029cc
  801c62:	6a 6d                	push   $0x6d
  801c64:	68 20 2a 80 00       	push   $0x802a20
  801c69:	e8 77 e5 ff ff       	call   8001e5 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c6e:	83 ec 04             	sub    $0x4,%esp
  801c71:	53                   	push   %ebx
  801c72:	ff 75 0c             	pushl  0xc(%ebp)
  801c75:	68 0c 60 80 00       	push   $0x80600c
  801c7a:	e8 56 ed ff ff       	call   8009d5 <memmove>
	nsipcbuf.send.req_size = size;
  801c7f:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801c85:	8b 45 14             	mov    0x14(%ebp),%eax
  801c88:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801c8d:	b8 08 00 00 00       	mov    $0x8,%eax
  801c92:	e8 d9 fd ff ff       	call   801a70 <nsipc>
}
  801c97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c9a:	c9                   	leave  
  801c9b:	c3                   	ret    

00801c9c <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c9c:	55                   	push   %ebp
  801c9d:	89 e5                	mov    %esp,%ebp
  801c9f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801caa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cad:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801cb2:	8b 45 10             	mov    0x10(%ebp),%eax
  801cb5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801cba:	b8 09 00 00 00       	mov    $0x9,%eax
  801cbf:	e8 ac fd ff ff       	call   801a70 <nsipc>
}
  801cc4:	c9                   	leave  
  801cc5:	c3                   	ret    

00801cc6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801cc6:	55                   	push   %ebp
  801cc7:	89 e5                	mov    %esp,%ebp
  801cc9:	56                   	push   %esi
  801cca:	53                   	push   %ebx
  801ccb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cce:	83 ec 0c             	sub    $0xc,%esp
  801cd1:	ff 75 08             	pushl  0x8(%ebp)
  801cd4:	e8 52 f2 ff ff       	call   800f2b <fd2data>
  801cd9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cdb:	83 c4 08             	add    $0x8,%esp
  801cde:	68 38 2a 80 00       	push   $0x802a38
  801ce3:	53                   	push   %ebx
  801ce4:	e8 5a eb ff ff       	call   800843 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ce9:	8b 46 04             	mov    0x4(%esi),%eax
  801cec:	2b 06                	sub    (%esi),%eax
  801cee:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cf4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cfb:	00 00 00 
	stat->st_dev = &devpipe;
  801cfe:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  801d05:	30 80 00 
	return 0;
}
  801d08:	b8 00 00 00 00       	mov    $0x0,%eax
  801d0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d10:	5b                   	pop    %ebx
  801d11:	5e                   	pop    %esi
  801d12:	5d                   	pop    %ebp
  801d13:	c3                   	ret    

00801d14 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d14:	55                   	push   %ebp
  801d15:	89 e5                	mov    %esp,%ebp
  801d17:	53                   	push   %ebx
  801d18:	83 ec 0c             	sub    $0xc,%esp
  801d1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d1e:	53                   	push   %ebx
  801d1f:	6a 00                	push   $0x0
  801d21:	e8 a5 ef ff ff       	call   800ccb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d26:	89 1c 24             	mov    %ebx,(%esp)
  801d29:	e8 fd f1 ff ff       	call   800f2b <fd2data>
  801d2e:	83 c4 08             	add    $0x8,%esp
  801d31:	50                   	push   %eax
  801d32:	6a 00                	push   $0x0
  801d34:	e8 92 ef ff ff       	call   800ccb <sys_page_unmap>
}
  801d39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d3c:	c9                   	leave  
  801d3d:	c3                   	ret    

00801d3e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
  801d41:	57                   	push   %edi
  801d42:	56                   	push   %esi
  801d43:	53                   	push   %ebx
  801d44:	83 ec 1c             	sub    $0x1c,%esp
  801d47:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d4a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d4c:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801d51:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d54:	83 ec 0c             	sub    $0xc,%esp
  801d57:	ff 75 e0             	pushl  -0x20(%ebp)
  801d5a:	e8 3c 05 00 00       	call   80229b <pageref>
  801d5f:	89 c3                	mov    %eax,%ebx
  801d61:	89 3c 24             	mov    %edi,(%esp)
  801d64:	e8 32 05 00 00       	call   80229b <pageref>
  801d69:	83 c4 10             	add    $0x10,%esp
  801d6c:	39 c3                	cmp    %eax,%ebx
  801d6e:	0f 94 c1             	sete   %cl
  801d71:	0f b6 c9             	movzbl %cl,%ecx
  801d74:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d77:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801d7d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d80:	39 ce                	cmp    %ecx,%esi
  801d82:	74 1b                	je     801d9f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d84:	39 c3                	cmp    %eax,%ebx
  801d86:	75 c4                	jne    801d4c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d88:	8b 42 58             	mov    0x58(%edx),%eax
  801d8b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d8e:	50                   	push   %eax
  801d8f:	56                   	push   %esi
  801d90:	68 3f 2a 80 00       	push   $0x802a3f
  801d95:	e8 24 e5 ff ff       	call   8002be <cprintf>
  801d9a:	83 c4 10             	add    $0x10,%esp
  801d9d:	eb ad                	jmp    801d4c <_pipeisclosed+0xe>
	}
}
  801d9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801da2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801da5:	5b                   	pop    %ebx
  801da6:	5e                   	pop    %esi
  801da7:	5f                   	pop    %edi
  801da8:	5d                   	pop    %ebp
  801da9:	c3                   	ret    

00801daa <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801daa:	55                   	push   %ebp
  801dab:	89 e5                	mov    %esp,%ebp
  801dad:	57                   	push   %edi
  801dae:	56                   	push   %esi
  801daf:	53                   	push   %ebx
  801db0:	83 ec 28             	sub    $0x28,%esp
  801db3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801db6:	56                   	push   %esi
  801db7:	e8 6f f1 ff ff       	call   800f2b <fd2data>
  801dbc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dbe:	83 c4 10             	add    $0x10,%esp
  801dc1:	bf 00 00 00 00       	mov    $0x0,%edi
  801dc6:	eb 4b                	jmp    801e13 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801dc8:	89 da                	mov    %ebx,%edx
  801dca:	89 f0                	mov    %esi,%eax
  801dcc:	e8 6d ff ff ff       	call   801d3e <_pipeisclosed>
  801dd1:	85 c0                	test   %eax,%eax
  801dd3:	75 48                	jne    801e1d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801dd5:	e8 4d ee ff ff       	call   800c27 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801dda:	8b 43 04             	mov    0x4(%ebx),%eax
  801ddd:	8b 0b                	mov    (%ebx),%ecx
  801ddf:	8d 51 20             	lea    0x20(%ecx),%edx
  801de2:	39 d0                	cmp    %edx,%eax
  801de4:	73 e2                	jae    801dc8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801de6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801de9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ded:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801df0:	89 c2                	mov    %eax,%edx
  801df2:	c1 fa 1f             	sar    $0x1f,%edx
  801df5:	89 d1                	mov    %edx,%ecx
  801df7:	c1 e9 1b             	shr    $0x1b,%ecx
  801dfa:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801dfd:	83 e2 1f             	and    $0x1f,%edx
  801e00:	29 ca                	sub    %ecx,%edx
  801e02:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e06:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e0a:	83 c0 01             	add    $0x1,%eax
  801e0d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e10:	83 c7 01             	add    $0x1,%edi
  801e13:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e16:	75 c2                	jne    801dda <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e18:	8b 45 10             	mov    0x10(%ebp),%eax
  801e1b:	eb 05                	jmp    801e22 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e1d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e25:	5b                   	pop    %ebx
  801e26:	5e                   	pop    %esi
  801e27:	5f                   	pop    %edi
  801e28:	5d                   	pop    %ebp
  801e29:	c3                   	ret    

00801e2a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e2a:	55                   	push   %ebp
  801e2b:	89 e5                	mov    %esp,%ebp
  801e2d:	57                   	push   %edi
  801e2e:	56                   	push   %esi
  801e2f:	53                   	push   %ebx
  801e30:	83 ec 18             	sub    $0x18,%esp
  801e33:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e36:	57                   	push   %edi
  801e37:	e8 ef f0 ff ff       	call   800f2b <fd2data>
  801e3c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e3e:	83 c4 10             	add    $0x10,%esp
  801e41:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e46:	eb 3d                	jmp    801e85 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e48:	85 db                	test   %ebx,%ebx
  801e4a:	74 04                	je     801e50 <devpipe_read+0x26>
				return i;
  801e4c:	89 d8                	mov    %ebx,%eax
  801e4e:	eb 44                	jmp    801e94 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e50:	89 f2                	mov    %esi,%edx
  801e52:	89 f8                	mov    %edi,%eax
  801e54:	e8 e5 fe ff ff       	call   801d3e <_pipeisclosed>
  801e59:	85 c0                	test   %eax,%eax
  801e5b:	75 32                	jne    801e8f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e5d:	e8 c5 ed ff ff       	call   800c27 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e62:	8b 06                	mov    (%esi),%eax
  801e64:	3b 46 04             	cmp    0x4(%esi),%eax
  801e67:	74 df                	je     801e48 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e69:	99                   	cltd   
  801e6a:	c1 ea 1b             	shr    $0x1b,%edx
  801e6d:	01 d0                	add    %edx,%eax
  801e6f:	83 e0 1f             	and    $0x1f,%eax
  801e72:	29 d0                	sub    %edx,%eax
  801e74:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e7c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e7f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e82:	83 c3 01             	add    $0x1,%ebx
  801e85:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e88:	75 d8                	jne    801e62 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e8a:	8b 45 10             	mov    0x10(%ebp),%eax
  801e8d:	eb 05                	jmp    801e94 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e8f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e97:	5b                   	pop    %ebx
  801e98:	5e                   	pop    %esi
  801e99:	5f                   	pop    %edi
  801e9a:	5d                   	pop    %ebp
  801e9b:	c3                   	ret    

00801e9c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	56                   	push   %esi
  801ea0:	53                   	push   %ebx
  801ea1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ea4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea7:	50                   	push   %eax
  801ea8:	e8 95 f0 ff ff       	call   800f42 <fd_alloc>
  801ead:	83 c4 10             	add    $0x10,%esp
  801eb0:	89 c2                	mov    %eax,%edx
  801eb2:	85 c0                	test   %eax,%eax
  801eb4:	0f 88 2c 01 00 00    	js     801fe6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eba:	83 ec 04             	sub    $0x4,%esp
  801ebd:	68 07 04 00 00       	push   $0x407
  801ec2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec5:	6a 00                	push   $0x0
  801ec7:	e8 7a ed ff ff       	call   800c46 <sys_page_alloc>
  801ecc:	83 c4 10             	add    $0x10,%esp
  801ecf:	89 c2                	mov    %eax,%edx
  801ed1:	85 c0                	test   %eax,%eax
  801ed3:	0f 88 0d 01 00 00    	js     801fe6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ed9:	83 ec 0c             	sub    $0xc,%esp
  801edc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801edf:	50                   	push   %eax
  801ee0:	e8 5d f0 ff ff       	call   800f42 <fd_alloc>
  801ee5:	89 c3                	mov    %eax,%ebx
  801ee7:	83 c4 10             	add    $0x10,%esp
  801eea:	85 c0                	test   %eax,%eax
  801eec:	0f 88 e2 00 00 00    	js     801fd4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ef2:	83 ec 04             	sub    $0x4,%esp
  801ef5:	68 07 04 00 00       	push   $0x407
  801efa:	ff 75 f0             	pushl  -0x10(%ebp)
  801efd:	6a 00                	push   $0x0
  801eff:	e8 42 ed ff ff       	call   800c46 <sys_page_alloc>
  801f04:	89 c3                	mov    %eax,%ebx
  801f06:	83 c4 10             	add    $0x10,%esp
  801f09:	85 c0                	test   %eax,%eax
  801f0b:	0f 88 c3 00 00 00    	js     801fd4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f11:	83 ec 0c             	sub    $0xc,%esp
  801f14:	ff 75 f4             	pushl  -0xc(%ebp)
  801f17:	e8 0f f0 ff ff       	call   800f2b <fd2data>
  801f1c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f1e:	83 c4 0c             	add    $0xc,%esp
  801f21:	68 07 04 00 00       	push   $0x407
  801f26:	50                   	push   %eax
  801f27:	6a 00                	push   $0x0
  801f29:	e8 18 ed ff ff       	call   800c46 <sys_page_alloc>
  801f2e:	89 c3                	mov    %eax,%ebx
  801f30:	83 c4 10             	add    $0x10,%esp
  801f33:	85 c0                	test   %eax,%eax
  801f35:	0f 88 89 00 00 00    	js     801fc4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f3b:	83 ec 0c             	sub    $0xc,%esp
  801f3e:	ff 75 f0             	pushl  -0x10(%ebp)
  801f41:	e8 e5 ef ff ff       	call   800f2b <fd2data>
  801f46:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f4d:	50                   	push   %eax
  801f4e:	6a 00                	push   $0x0
  801f50:	56                   	push   %esi
  801f51:	6a 00                	push   $0x0
  801f53:	e8 31 ed ff ff       	call   800c89 <sys_page_map>
  801f58:	89 c3                	mov    %eax,%ebx
  801f5a:	83 c4 20             	add    $0x20,%esp
  801f5d:	85 c0                	test   %eax,%eax
  801f5f:	78 55                	js     801fb6 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f61:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f76:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f7f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f81:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f84:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f8b:	83 ec 0c             	sub    $0xc,%esp
  801f8e:	ff 75 f4             	pushl  -0xc(%ebp)
  801f91:	e8 85 ef ff ff       	call   800f1b <fd2num>
  801f96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f99:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f9b:	83 c4 04             	add    $0x4,%esp
  801f9e:	ff 75 f0             	pushl  -0x10(%ebp)
  801fa1:	e8 75 ef ff ff       	call   800f1b <fd2num>
  801fa6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fa9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801fac:	83 c4 10             	add    $0x10,%esp
  801faf:	ba 00 00 00 00       	mov    $0x0,%edx
  801fb4:	eb 30                	jmp    801fe6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801fb6:	83 ec 08             	sub    $0x8,%esp
  801fb9:	56                   	push   %esi
  801fba:	6a 00                	push   $0x0
  801fbc:	e8 0a ed ff ff       	call   800ccb <sys_page_unmap>
  801fc1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801fc4:	83 ec 08             	sub    $0x8,%esp
  801fc7:	ff 75 f0             	pushl  -0x10(%ebp)
  801fca:	6a 00                	push   $0x0
  801fcc:	e8 fa ec ff ff       	call   800ccb <sys_page_unmap>
  801fd1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801fd4:	83 ec 08             	sub    $0x8,%esp
  801fd7:	ff 75 f4             	pushl  -0xc(%ebp)
  801fda:	6a 00                	push   $0x0
  801fdc:	e8 ea ec ff ff       	call   800ccb <sys_page_unmap>
  801fe1:	83 c4 10             	add    $0x10,%esp
  801fe4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801fe6:	89 d0                	mov    %edx,%eax
  801fe8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801feb:	5b                   	pop    %ebx
  801fec:	5e                   	pop    %esi
  801fed:	5d                   	pop    %ebp
  801fee:	c3                   	ret    

00801fef <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fef:	55                   	push   %ebp
  801ff0:	89 e5                	mov    %esp,%ebp
  801ff2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ff5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff8:	50                   	push   %eax
  801ff9:	ff 75 08             	pushl  0x8(%ebp)
  801ffc:	e8 90 ef ff ff       	call   800f91 <fd_lookup>
  802001:	83 c4 10             	add    $0x10,%esp
  802004:	85 c0                	test   %eax,%eax
  802006:	78 18                	js     802020 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802008:	83 ec 0c             	sub    $0xc,%esp
  80200b:	ff 75 f4             	pushl  -0xc(%ebp)
  80200e:	e8 18 ef ff ff       	call   800f2b <fd2data>
	return _pipeisclosed(fd, p);
  802013:	89 c2                	mov    %eax,%edx
  802015:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802018:	e8 21 fd ff ff       	call   801d3e <_pipeisclosed>
  80201d:	83 c4 10             	add    $0x10,%esp
}
  802020:	c9                   	leave  
  802021:	c3                   	ret    

00802022 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802022:	55                   	push   %ebp
  802023:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802025:	b8 00 00 00 00       	mov    $0x0,%eax
  80202a:	5d                   	pop    %ebp
  80202b:	c3                   	ret    

0080202c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80202c:	55                   	push   %ebp
  80202d:	89 e5                	mov    %esp,%ebp
  80202f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802032:	68 57 2a 80 00       	push   $0x802a57
  802037:	ff 75 0c             	pushl  0xc(%ebp)
  80203a:	e8 04 e8 ff ff       	call   800843 <strcpy>
	return 0;
}
  80203f:	b8 00 00 00 00       	mov    $0x0,%eax
  802044:	c9                   	leave  
  802045:	c3                   	ret    

00802046 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802046:	55                   	push   %ebp
  802047:	89 e5                	mov    %esp,%ebp
  802049:	57                   	push   %edi
  80204a:	56                   	push   %esi
  80204b:	53                   	push   %ebx
  80204c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802052:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802057:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80205d:	eb 2d                	jmp    80208c <devcons_write+0x46>
		m = n - tot;
  80205f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802062:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802064:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802067:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80206c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80206f:	83 ec 04             	sub    $0x4,%esp
  802072:	53                   	push   %ebx
  802073:	03 45 0c             	add    0xc(%ebp),%eax
  802076:	50                   	push   %eax
  802077:	57                   	push   %edi
  802078:	e8 58 e9 ff ff       	call   8009d5 <memmove>
		sys_cputs(buf, m);
  80207d:	83 c4 08             	add    $0x8,%esp
  802080:	53                   	push   %ebx
  802081:	57                   	push   %edi
  802082:	e8 03 eb ff ff       	call   800b8a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802087:	01 de                	add    %ebx,%esi
  802089:	83 c4 10             	add    $0x10,%esp
  80208c:	89 f0                	mov    %esi,%eax
  80208e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802091:	72 cc                	jb     80205f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802093:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802096:	5b                   	pop    %ebx
  802097:	5e                   	pop    %esi
  802098:	5f                   	pop    %edi
  802099:	5d                   	pop    %ebp
  80209a:	c3                   	ret    

0080209b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80209b:	55                   	push   %ebp
  80209c:	89 e5                	mov    %esp,%ebp
  80209e:	83 ec 08             	sub    $0x8,%esp
  8020a1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8020a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020aa:	74 2a                	je     8020d6 <devcons_read+0x3b>
  8020ac:	eb 05                	jmp    8020b3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020ae:	e8 74 eb ff ff       	call   800c27 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8020b3:	e8 f0 ea ff ff       	call   800ba8 <sys_cgetc>
  8020b8:	85 c0                	test   %eax,%eax
  8020ba:	74 f2                	je     8020ae <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8020bc:	85 c0                	test   %eax,%eax
  8020be:	78 16                	js     8020d6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020c0:	83 f8 04             	cmp    $0x4,%eax
  8020c3:	74 0c                	je     8020d1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8020c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020c8:	88 02                	mov    %al,(%edx)
	return 1;
  8020ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8020cf:	eb 05                	jmp    8020d6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020d1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020d6:	c9                   	leave  
  8020d7:	c3                   	ret    

008020d8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020d8:	55                   	push   %ebp
  8020d9:	89 e5                	mov    %esp,%ebp
  8020db:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020de:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020e4:	6a 01                	push   $0x1
  8020e6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020e9:	50                   	push   %eax
  8020ea:	e8 9b ea ff ff       	call   800b8a <sys_cputs>
}
  8020ef:	83 c4 10             	add    $0x10,%esp
  8020f2:	c9                   	leave  
  8020f3:	c3                   	ret    

008020f4 <getchar>:

int
getchar(void)
{
  8020f4:	55                   	push   %ebp
  8020f5:	89 e5                	mov    %esp,%ebp
  8020f7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020fa:	6a 01                	push   $0x1
  8020fc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020ff:	50                   	push   %eax
  802100:	6a 00                	push   $0x0
  802102:	e8 f0 f0 ff ff       	call   8011f7 <read>
	if (r < 0)
  802107:	83 c4 10             	add    $0x10,%esp
  80210a:	85 c0                	test   %eax,%eax
  80210c:	78 0f                	js     80211d <getchar+0x29>
		return r;
	if (r < 1)
  80210e:	85 c0                	test   %eax,%eax
  802110:	7e 06                	jle    802118 <getchar+0x24>
		return -E_EOF;
	return c;
  802112:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802116:	eb 05                	jmp    80211d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802118:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80211d:	c9                   	leave  
  80211e:	c3                   	ret    

0080211f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80211f:	55                   	push   %ebp
  802120:	89 e5                	mov    %esp,%ebp
  802122:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802125:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802128:	50                   	push   %eax
  802129:	ff 75 08             	pushl  0x8(%ebp)
  80212c:	e8 60 ee ff ff       	call   800f91 <fd_lookup>
  802131:	83 c4 10             	add    $0x10,%esp
  802134:	85 c0                	test   %eax,%eax
  802136:	78 11                	js     802149 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802138:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213b:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802141:	39 10                	cmp    %edx,(%eax)
  802143:	0f 94 c0             	sete   %al
  802146:	0f b6 c0             	movzbl %al,%eax
}
  802149:	c9                   	leave  
  80214a:	c3                   	ret    

0080214b <opencons>:

int
opencons(void)
{
  80214b:	55                   	push   %ebp
  80214c:	89 e5                	mov    %esp,%ebp
  80214e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802151:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802154:	50                   	push   %eax
  802155:	e8 e8 ed ff ff       	call   800f42 <fd_alloc>
  80215a:	83 c4 10             	add    $0x10,%esp
		return r;
  80215d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80215f:	85 c0                	test   %eax,%eax
  802161:	78 3e                	js     8021a1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802163:	83 ec 04             	sub    $0x4,%esp
  802166:	68 07 04 00 00       	push   $0x407
  80216b:	ff 75 f4             	pushl  -0xc(%ebp)
  80216e:	6a 00                	push   $0x0
  802170:	e8 d1 ea ff ff       	call   800c46 <sys_page_alloc>
  802175:	83 c4 10             	add    $0x10,%esp
		return r;
  802178:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80217a:	85 c0                	test   %eax,%eax
  80217c:	78 23                	js     8021a1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80217e:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802184:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802187:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802189:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80218c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802193:	83 ec 0c             	sub    $0xc,%esp
  802196:	50                   	push   %eax
  802197:	e8 7f ed ff ff       	call   800f1b <fd2num>
  80219c:	89 c2                	mov    %eax,%edx
  80219e:	83 c4 10             	add    $0x10,%esp
}
  8021a1:	89 d0                	mov    %edx,%eax
  8021a3:	c9                   	leave  
  8021a4:	c3                   	ret    

008021a5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021a5:	55                   	push   %ebp
  8021a6:	89 e5                	mov    %esp,%ebp
  8021a8:	56                   	push   %esi
  8021a9:	53                   	push   %ebx
  8021aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8021ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  8021b3:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8021b5:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  8021ba:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  8021bd:	83 ec 0c             	sub    $0xc,%esp
  8021c0:	50                   	push   %eax
  8021c1:	e8 30 ec ff ff       	call   800df6 <sys_ipc_recv>

	if (r < 0) {
  8021c6:	83 c4 10             	add    $0x10,%esp
  8021c9:	85 c0                	test   %eax,%eax
  8021cb:	79 16                	jns    8021e3 <ipc_recv+0x3e>
		if (from_env_store)
  8021cd:	85 f6                	test   %esi,%esi
  8021cf:	74 06                	je     8021d7 <ipc_recv+0x32>
			*from_env_store = 0;
  8021d1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  8021d7:	85 db                	test   %ebx,%ebx
  8021d9:	74 2c                	je     802207 <ipc_recv+0x62>
			*perm_store = 0;
  8021db:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8021e1:	eb 24                	jmp    802207 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  8021e3:	85 f6                	test   %esi,%esi
  8021e5:	74 0a                	je     8021f1 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  8021e7:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8021ec:	8b 40 74             	mov    0x74(%eax),%eax
  8021ef:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  8021f1:	85 db                	test   %ebx,%ebx
  8021f3:	74 0a                	je     8021ff <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  8021f5:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8021fa:	8b 40 78             	mov    0x78(%eax),%eax
  8021fd:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  8021ff:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802204:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  802207:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80220a:	5b                   	pop    %ebx
  80220b:	5e                   	pop    %esi
  80220c:	5d                   	pop    %ebp
  80220d:	c3                   	ret    

0080220e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80220e:	55                   	push   %ebp
  80220f:	89 e5                	mov    %esp,%ebp
  802211:	57                   	push   %edi
  802212:	56                   	push   %esi
  802213:	53                   	push   %ebx
  802214:	83 ec 0c             	sub    $0xc,%esp
  802217:	8b 7d 08             	mov    0x8(%ebp),%edi
  80221a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80221d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  802220:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802222:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802227:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  80222a:	ff 75 14             	pushl  0x14(%ebp)
  80222d:	53                   	push   %ebx
  80222e:	56                   	push   %esi
  80222f:	57                   	push   %edi
  802230:	e8 9e eb ff ff       	call   800dd3 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  802235:	83 c4 10             	add    $0x10,%esp
  802238:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80223b:	75 07                	jne    802244 <ipc_send+0x36>
			sys_yield();
  80223d:	e8 e5 e9 ff ff       	call   800c27 <sys_yield>
  802242:	eb e6                	jmp    80222a <ipc_send+0x1c>
		} else if (r < 0) {
  802244:	85 c0                	test   %eax,%eax
  802246:	79 12                	jns    80225a <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  802248:	50                   	push   %eax
  802249:	68 63 2a 80 00       	push   $0x802a63
  80224e:	6a 51                	push   $0x51
  802250:	68 70 2a 80 00       	push   $0x802a70
  802255:	e8 8b df ff ff       	call   8001e5 <_panic>
		}
	}
}
  80225a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80225d:	5b                   	pop    %ebx
  80225e:	5e                   	pop    %esi
  80225f:	5f                   	pop    %edi
  802260:	5d                   	pop    %ebp
  802261:	c3                   	ret    

00802262 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802262:	55                   	push   %ebp
  802263:	89 e5                	mov    %esp,%ebp
  802265:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802268:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80226d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802270:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802276:	8b 52 50             	mov    0x50(%edx),%edx
  802279:	39 ca                	cmp    %ecx,%edx
  80227b:	75 0d                	jne    80228a <ipc_find_env+0x28>
			return envs[i].env_id;
  80227d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802280:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802285:	8b 40 48             	mov    0x48(%eax),%eax
  802288:	eb 0f                	jmp    802299 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80228a:	83 c0 01             	add    $0x1,%eax
  80228d:	3d 00 04 00 00       	cmp    $0x400,%eax
  802292:	75 d9                	jne    80226d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802294:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802299:	5d                   	pop    %ebp
  80229a:	c3                   	ret    

0080229b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80229b:	55                   	push   %ebp
  80229c:	89 e5                	mov    %esp,%ebp
  80229e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022a1:	89 d0                	mov    %edx,%eax
  8022a3:	c1 e8 16             	shr    $0x16,%eax
  8022a6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022ad:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022b2:	f6 c1 01             	test   $0x1,%cl
  8022b5:	74 1d                	je     8022d4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022b7:	c1 ea 0c             	shr    $0xc,%edx
  8022ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8022c1:	f6 c2 01             	test   $0x1,%dl
  8022c4:	74 0e                	je     8022d4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022c6:	c1 ea 0c             	shr    $0xc,%edx
  8022c9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8022d0:	ef 
  8022d1:	0f b7 c0             	movzwl %ax,%eax
}
  8022d4:	5d                   	pop    %ebp
  8022d5:	c3                   	ret    
  8022d6:	66 90                	xchg   %ax,%ax
  8022d8:	66 90                	xchg   %ax,%ax
  8022da:	66 90                	xchg   %ax,%ax
  8022dc:	66 90                	xchg   %ax,%ax
  8022de:	66 90                	xchg   %ax,%ax

008022e0 <__udivdi3>:
  8022e0:	55                   	push   %ebp
  8022e1:	57                   	push   %edi
  8022e2:	56                   	push   %esi
  8022e3:	53                   	push   %ebx
  8022e4:	83 ec 1c             	sub    $0x1c,%esp
  8022e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8022eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8022ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8022f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022f7:	85 f6                	test   %esi,%esi
  8022f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022fd:	89 ca                	mov    %ecx,%edx
  8022ff:	89 f8                	mov    %edi,%eax
  802301:	75 3d                	jne    802340 <__udivdi3+0x60>
  802303:	39 cf                	cmp    %ecx,%edi
  802305:	0f 87 c5 00 00 00    	ja     8023d0 <__udivdi3+0xf0>
  80230b:	85 ff                	test   %edi,%edi
  80230d:	89 fd                	mov    %edi,%ebp
  80230f:	75 0b                	jne    80231c <__udivdi3+0x3c>
  802311:	b8 01 00 00 00       	mov    $0x1,%eax
  802316:	31 d2                	xor    %edx,%edx
  802318:	f7 f7                	div    %edi
  80231a:	89 c5                	mov    %eax,%ebp
  80231c:	89 c8                	mov    %ecx,%eax
  80231e:	31 d2                	xor    %edx,%edx
  802320:	f7 f5                	div    %ebp
  802322:	89 c1                	mov    %eax,%ecx
  802324:	89 d8                	mov    %ebx,%eax
  802326:	89 cf                	mov    %ecx,%edi
  802328:	f7 f5                	div    %ebp
  80232a:	89 c3                	mov    %eax,%ebx
  80232c:	89 d8                	mov    %ebx,%eax
  80232e:	89 fa                	mov    %edi,%edx
  802330:	83 c4 1c             	add    $0x1c,%esp
  802333:	5b                   	pop    %ebx
  802334:	5e                   	pop    %esi
  802335:	5f                   	pop    %edi
  802336:	5d                   	pop    %ebp
  802337:	c3                   	ret    
  802338:	90                   	nop
  802339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802340:	39 ce                	cmp    %ecx,%esi
  802342:	77 74                	ja     8023b8 <__udivdi3+0xd8>
  802344:	0f bd fe             	bsr    %esi,%edi
  802347:	83 f7 1f             	xor    $0x1f,%edi
  80234a:	0f 84 98 00 00 00    	je     8023e8 <__udivdi3+0x108>
  802350:	bb 20 00 00 00       	mov    $0x20,%ebx
  802355:	89 f9                	mov    %edi,%ecx
  802357:	89 c5                	mov    %eax,%ebp
  802359:	29 fb                	sub    %edi,%ebx
  80235b:	d3 e6                	shl    %cl,%esi
  80235d:	89 d9                	mov    %ebx,%ecx
  80235f:	d3 ed                	shr    %cl,%ebp
  802361:	89 f9                	mov    %edi,%ecx
  802363:	d3 e0                	shl    %cl,%eax
  802365:	09 ee                	or     %ebp,%esi
  802367:	89 d9                	mov    %ebx,%ecx
  802369:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80236d:	89 d5                	mov    %edx,%ebp
  80236f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802373:	d3 ed                	shr    %cl,%ebp
  802375:	89 f9                	mov    %edi,%ecx
  802377:	d3 e2                	shl    %cl,%edx
  802379:	89 d9                	mov    %ebx,%ecx
  80237b:	d3 e8                	shr    %cl,%eax
  80237d:	09 c2                	or     %eax,%edx
  80237f:	89 d0                	mov    %edx,%eax
  802381:	89 ea                	mov    %ebp,%edx
  802383:	f7 f6                	div    %esi
  802385:	89 d5                	mov    %edx,%ebp
  802387:	89 c3                	mov    %eax,%ebx
  802389:	f7 64 24 0c          	mull   0xc(%esp)
  80238d:	39 d5                	cmp    %edx,%ebp
  80238f:	72 10                	jb     8023a1 <__udivdi3+0xc1>
  802391:	8b 74 24 08          	mov    0x8(%esp),%esi
  802395:	89 f9                	mov    %edi,%ecx
  802397:	d3 e6                	shl    %cl,%esi
  802399:	39 c6                	cmp    %eax,%esi
  80239b:	73 07                	jae    8023a4 <__udivdi3+0xc4>
  80239d:	39 d5                	cmp    %edx,%ebp
  80239f:	75 03                	jne    8023a4 <__udivdi3+0xc4>
  8023a1:	83 eb 01             	sub    $0x1,%ebx
  8023a4:	31 ff                	xor    %edi,%edi
  8023a6:	89 d8                	mov    %ebx,%eax
  8023a8:	89 fa                	mov    %edi,%edx
  8023aa:	83 c4 1c             	add    $0x1c,%esp
  8023ad:	5b                   	pop    %ebx
  8023ae:	5e                   	pop    %esi
  8023af:	5f                   	pop    %edi
  8023b0:	5d                   	pop    %ebp
  8023b1:	c3                   	ret    
  8023b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023b8:	31 ff                	xor    %edi,%edi
  8023ba:	31 db                	xor    %ebx,%ebx
  8023bc:	89 d8                	mov    %ebx,%eax
  8023be:	89 fa                	mov    %edi,%edx
  8023c0:	83 c4 1c             	add    $0x1c,%esp
  8023c3:	5b                   	pop    %ebx
  8023c4:	5e                   	pop    %esi
  8023c5:	5f                   	pop    %edi
  8023c6:	5d                   	pop    %ebp
  8023c7:	c3                   	ret    
  8023c8:	90                   	nop
  8023c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023d0:	89 d8                	mov    %ebx,%eax
  8023d2:	f7 f7                	div    %edi
  8023d4:	31 ff                	xor    %edi,%edi
  8023d6:	89 c3                	mov    %eax,%ebx
  8023d8:	89 d8                	mov    %ebx,%eax
  8023da:	89 fa                	mov    %edi,%edx
  8023dc:	83 c4 1c             	add    $0x1c,%esp
  8023df:	5b                   	pop    %ebx
  8023e0:	5e                   	pop    %esi
  8023e1:	5f                   	pop    %edi
  8023e2:	5d                   	pop    %ebp
  8023e3:	c3                   	ret    
  8023e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023e8:	39 ce                	cmp    %ecx,%esi
  8023ea:	72 0c                	jb     8023f8 <__udivdi3+0x118>
  8023ec:	31 db                	xor    %ebx,%ebx
  8023ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8023f2:	0f 87 34 ff ff ff    	ja     80232c <__udivdi3+0x4c>
  8023f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8023fd:	e9 2a ff ff ff       	jmp    80232c <__udivdi3+0x4c>
  802402:	66 90                	xchg   %ax,%ax
  802404:	66 90                	xchg   %ax,%ax
  802406:	66 90                	xchg   %ax,%ax
  802408:	66 90                	xchg   %ax,%ax
  80240a:	66 90                	xchg   %ax,%ax
  80240c:	66 90                	xchg   %ax,%ax
  80240e:	66 90                	xchg   %ax,%ax

00802410 <__umoddi3>:
  802410:	55                   	push   %ebp
  802411:	57                   	push   %edi
  802412:	56                   	push   %esi
  802413:	53                   	push   %ebx
  802414:	83 ec 1c             	sub    $0x1c,%esp
  802417:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80241b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80241f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802423:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802427:	85 d2                	test   %edx,%edx
  802429:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80242d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802431:	89 f3                	mov    %esi,%ebx
  802433:	89 3c 24             	mov    %edi,(%esp)
  802436:	89 74 24 04          	mov    %esi,0x4(%esp)
  80243a:	75 1c                	jne    802458 <__umoddi3+0x48>
  80243c:	39 f7                	cmp    %esi,%edi
  80243e:	76 50                	jbe    802490 <__umoddi3+0x80>
  802440:	89 c8                	mov    %ecx,%eax
  802442:	89 f2                	mov    %esi,%edx
  802444:	f7 f7                	div    %edi
  802446:	89 d0                	mov    %edx,%eax
  802448:	31 d2                	xor    %edx,%edx
  80244a:	83 c4 1c             	add    $0x1c,%esp
  80244d:	5b                   	pop    %ebx
  80244e:	5e                   	pop    %esi
  80244f:	5f                   	pop    %edi
  802450:	5d                   	pop    %ebp
  802451:	c3                   	ret    
  802452:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802458:	39 f2                	cmp    %esi,%edx
  80245a:	89 d0                	mov    %edx,%eax
  80245c:	77 52                	ja     8024b0 <__umoddi3+0xa0>
  80245e:	0f bd ea             	bsr    %edx,%ebp
  802461:	83 f5 1f             	xor    $0x1f,%ebp
  802464:	75 5a                	jne    8024c0 <__umoddi3+0xb0>
  802466:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80246a:	0f 82 e0 00 00 00    	jb     802550 <__umoddi3+0x140>
  802470:	39 0c 24             	cmp    %ecx,(%esp)
  802473:	0f 86 d7 00 00 00    	jbe    802550 <__umoddi3+0x140>
  802479:	8b 44 24 08          	mov    0x8(%esp),%eax
  80247d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802481:	83 c4 1c             	add    $0x1c,%esp
  802484:	5b                   	pop    %ebx
  802485:	5e                   	pop    %esi
  802486:	5f                   	pop    %edi
  802487:	5d                   	pop    %ebp
  802488:	c3                   	ret    
  802489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802490:	85 ff                	test   %edi,%edi
  802492:	89 fd                	mov    %edi,%ebp
  802494:	75 0b                	jne    8024a1 <__umoddi3+0x91>
  802496:	b8 01 00 00 00       	mov    $0x1,%eax
  80249b:	31 d2                	xor    %edx,%edx
  80249d:	f7 f7                	div    %edi
  80249f:	89 c5                	mov    %eax,%ebp
  8024a1:	89 f0                	mov    %esi,%eax
  8024a3:	31 d2                	xor    %edx,%edx
  8024a5:	f7 f5                	div    %ebp
  8024a7:	89 c8                	mov    %ecx,%eax
  8024a9:	f7 f5                	div    %ebp
  8024ab:	89 d0                	mov    %edx,%eax
  8024ad:	eb 99                	jmp    802448 <__umoddi3+0x38>
  8024af:	90                   	nop
  8024b0:	89 c8                	mov    %ecx,%eax
  8024b2:	89 f2                	mov    %esi,%edx
  8024b4:	83 c4 1c             	add    $0x1c,%esp
  8024b7:	5b                   	pop    %ebx
  8024b8:	5e                   	pop    %esi
  8024b9:	5f                   	pop    %edi
  8024ba:	5d                   	pop    %ebp
  8024bb:	c3                   	ret    
  8024bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024c0:	8b 34 24             	mov    (%esp),%esi
  8024c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8024c8:	89 e9                	mov    %ebp,%ecx
  8024ca:	29 ef                	sub    %ebp,%edi
  8024cc:	d3 e0                	shl    %cl,%eax
  8024ce:	89 f9                	mov    %edi,%ecx
  8024d0:	89 f2                	mov    %esi,%edx
  8024d2:	d3 ea                	shr    %cl,%edx
  8024d4:	89 e9                	mov    %ebp,%ecx
  8024d6:	09 c2                	or     %eax,%edx
  8024d8:	89 d8                	mov    %ebx,%eax
  8024da:	89 14 24             	mov    %edx,(%esp)
  8024dd:	89 f2                	mov    %esi,%edx
  8024df:	d3 e2                	shl    %cl,%edx
  8024e1:	89 f9                	mov    %edi,%ecx
  8024e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8024e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8024eb:	d3 e8                	shr    %cl,%eax
  8024ed:	89 e9                	mov    %ebp,%ecx
  8024ef:	89 c6                	mov    %eax,%esi
  8024f1:	d3 e3                	shl    %cl,%ebx
  8024f3:	89 f9                	mov    %edi,%ecx
  8024f5:	89 d0                	mov    %edx,%eax
  8024f7:	d3 e8                	shr    %cl,%eax
  8024f9:	89 e9                	mov    %ebp,%ecx
  8024fb:	09 d8                	or     %ebx,%eax
  8024fd:	89 d3                	mov    %edx,%ebx
  8024ff:	89 f2                	mov    %esi,%edx
  802501:	f7 34 24             	divl   (%esp)
  802504:	89 d6                	mov    %edx,%esi
  802506:	d3 e3                	shl    %cl,%ebx
  802508:	f7 64 24 04          	mull   0x4(%esp)
  80250c:	39 d6                	cmp    %edx,%esi
  80250e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802512:	89 d1                	mov    %edx,%ecx
  802514:	89 c3                	mov    %eax,%ebx
  802516:	72 08                	jb     802520 <__umoddi3+0x110>
  802518:	75 11                	jne    80252b <__umoddi3+0x11b>
  80251a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80251e:	73 0b                	jae    80252b <__umoddi3+0x11b>
  802520:	2b 44 24 04          	sub    0x4(%esp),%eax
  802524:	1b 14 24             	sbb    (%esp),%edx
  802527:	89 d1                	mov    %edx,%ecx
  802529:	89 c3                	mov    %eax,%ebx
  80252b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80252f:	29 da                	sub    %ebx,%edx
  802531:	19 ce                	sbb    %ecx,%esi
  802533:	89 f9                	mov    %edi,%ecx
  802535:	89 f0                	mov    %esi,%eax
  802537:	d3 e0                	shl    %cl,%eax
  802539:	89 e9                	mov    %ebp,%ecx
  80253b:	d3 ea                	shr    %cl,%edx
  80253d:	89 e9                	mov    %ebp,%ecx
  80253f:	d3 ee                	shr    %cl,%esi
  802541:	09 d0                	or     %edx,%eax
  802543:	89 f2                	mov    %esi,%edx
  802545:	83 c4 1c             	add    $0x1c,%esp
  802548:	5b                   	pop    %ebx
  802549:	5e                   	pop    %esi
  80254a:	5f                   	pop    %edi
  80254b:	5d                   	pop    %ebp
  80254c:	c3                   	ret    
  80254d:	8d 76 00             	lea    0x0(%esi),%esi
  802550:	29 f9                	sub    %edi,%ecx
  802552:	19 d6                	sbb    %edx,%esi
  802554:	89 74 24 04          	mov    %esi,0x4(%esp)
  802558:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80255c:	e9 18 ff ff ff       	jmp    802479 <__umoddi3+0x69>
