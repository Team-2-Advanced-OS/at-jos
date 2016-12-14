
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 02 01 00 00       	call   800133 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003b:	eb 2f                	jmp    80006c <cat+0x39>
		if ((r = write(1, buf, n)) != n)
  80003d:	83 ec 04             	sub    $0x4,%esp
  800040:	53                   	push   %ebx
  800041:	68 20 40 80 00       	push   $0x804020
  800046:	6a 01                	push   $0x1
  800048:	e8 32 12 00 00       	call   80127f <write>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	39 c3                	cmp    %eax,%ebx
  800052:	74 18                	je     80006c <cat+0x39>
			panic("write error copying %s: %e", s, r);
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	50                   	push   %eax
  800058:	ff 75 0c             	pushl  0xc(%ebp)
  80005b:	68 20 25 80 00       	push   $0x802520
  800060:	6a 0d                	push   $0xd
  800062:	68 3b 25 80 00       	push   $0x80253b
  800067:	e8 27 01 00 00       	call   800193 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 00 20 00 00       	push   $0x2000
  800074:	68 20 40 80 00       	push   $0x804020
  800079:	56                   	push   %esi
  80007a:	e8 26 11 00 00       	call   8011a5 <read>
  80007f:	89 c3                	mov    %eax,%ebx
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	85 c0                	test   %eax,%eax
  800086:	7f b5                	jg     80003d <cat+0xa>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  800088:	85 c0                	test   %eax,%eax
  80008a:	79 18                	jns    8000a4 <cat+0x71>
		panic("error reading %s: %e", s, n);
  80008c:	83 ec 0c             	sub    $0xc,%esp
  80008f:	50                   	push   %eax
  800090:	ff 75 0c             	pushl  0xc(%ebp)
  800093:	68 46 25 80 00       	push   $0x802546
  800098:	6a 0f                	push   $0xf
  80009a:	68 3b 25 80 00       	push   $0x80253b
  80009f:	e8 ef 00 00 00       	call   800193 <_panic>
}
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <umain>:

void
umain(int argc, char **argv)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000b7:	c7 05 00 30 80 00 5b 	movl   $0x80255b,0x803000
  8000be:	25 80 00 
  8000c1:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  8000c6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ca:	75 5a                	jne    800126 <umain+0x7b>
		cat(0, "<stdin>");
  8000cc:	83 ec 08             	sub    $0x8,%esp
  8000cf:	68 5f 25 80 00       	push   $0x80255f
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 58 ff ff ff       	call   800033 <cat>
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	eb 4b                	jmp    80012b <umain+0x80>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  8000e0:	83 ec 08             	sub    $0x8,%esp
  8000e3:	6a 00                	push   $0x0
  8000e5:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000e8:	e8 6c 15 00 00       	call   801659 <open>
  8000ed:	89 c6                	mov    %eax,%esi
			if (f < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	79 16                	jns    80010c <umain+0x61>
				printf("can't open %s: %e\n", argv[i], f);
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	50                   	push   %eax
  8000fa:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000fd:	68 67 25 80 00       	push   $0x802567
  800102:	e8 f0 16 00 00       	call   8017f7 <printf>
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	eb 17                	jmp    800123 <umain+0x78>
			else {
				cat(f, argv[i]);
  80010c:	83 ec 08             	sub    $0x8,%esp
  80010f:	ff 34 9f             	pushl  (%edi,%ebx,4)
  800112:	50                   	push   %eax
  800113:	e8 1b ff ff ff       	call   800033 <cat>
				close(f);
  800118:	89 34 24             	mov    %esi,(%esp)
  80011b:	e8 49 0f 00 00       	call   801069 <close>
  800120:	83 c4 10             	add    $0x10,%esp

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800123:	83 c3 01             	add    $0x1,%ebx
  800126:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800129:	7c b5                	jl     8000e0 <umain+0x35>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  80012b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
  800138:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80013e:	e8 73 0a 00 00       	call   800bb6 <sys_getenvid>
  800143:	25 ff 03 00 00       	and    $0x3ff,%eax
  800148:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800150:	a3 20 60 80 00       	mov    %eax,0x806020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800155:	85 db                	test   %ebx,%ebx
  800157:	7e 07                	jle    800160 <libmain+0x2d>
		binaryname = argv[0];
  800159:	8b 06                	mov    (%esi),%eax
  80015b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	e8 41 ff ff ff       	call   8000ab <umain>

	// exit gracefully
	exit();
  80016a:	e8 0a 00 00 00       	call   800179 <exit>
}
  80016f:	83 c4 10             	add    $0x10,%esp
  800172:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80017f:	e8 10 0f 00 00       	call   801094 <close_all>
	sys_env_destroy(0);
  800184:	83 ec 0c             	sub    $0xc,%esp
  800187:	6a 00                	push   $0x0
  800189:	e8 e7 09 00 00       	call   800b75 <sys_env_destroy>
}
  80018e:	83 c4 10             	add    $0x10,%esp
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	56                   	push   %esi
  800197:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800198:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a1:	e8 10 0a 00 00       	call   800bb6 <sys_getenvid>
  8001a6:	83 ec 0c             	sub    $0xc,%esp
  8001a9:	ff 75 0c             	pushl  0xc(%ebp)
  8001ac:	ff 75 08             	pushl  0x8(%ebp)
  8001af:	56                   	push   %esi
  8001b0:	50                   	push   %eax
  8001b1:	68 84 25 80 00       	push   $0x802584
  8001b6:	e8 b1 00 00 00       	call   80026c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	53                   	push   %ebx
  8001bf:	ff 75 10             	pushl  0x10(%ebp)
  8001c2:	e8 54 00 00 00       	call   80021b <vcprintf>
	cprintf("\n");
  8001c7:	c7 04 24 f0 29 80 00 	movl   $0x8029f0,(%esp)
  8001ce:	e8 99 00 00 00       	call   80026c <cprintf>
  8001d3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d6:	cc                   	int3   
  8001d7:	eb fd                	jmp    8001d6 <_panic+0x43>

008001d9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 04             	sub    $0x4,%esp
  8001e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e3:	8b 13                	mov    (%ebx),%edx
  8001e5:	8d 42 01             	lea    0x1(%edx),%eax
  8001e8:	89 03                	mov    %eax,(%ebx)
  8001ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ed:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f6:	75 1a                	jne    800212 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f8:	83 ec 08             	sub    $0x8,%esp
  8001fb:	68 ff 00 00 00       	push   $0xff
  800200:	8d 43 08             	lea    0x8(%ebx),%eax
  800203:	50                   	push   %eax
  800204:	e8 2f 09 00 00       	call   800b38 <sys_cputs>
		b->idx = 0;
  800209:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80020f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800212:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800216:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800219:	c9                   	leave  
  80021a:	c3                   	ret    

0080021b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800224:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022b:	00 00 00 
	b.cnt = 0;
  80022e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800235:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800238:	ff 75 0c             	pushl  0xc(%ebp)
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800244:	50                   	push   %eax
  800245:	68 d9 01 80 00       	push   $0x8001d9
  80024a:	e8 54 01 00 00       	call   8003a3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024f:	83 c4 08             	add    $0x8,%esp
  800252:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800258:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025e:	50                   	push   %eax
  80025f:	e8 d4 08 00 00       	call   800b38 <sys_cputs>

	return b.cnt;
}
  800264:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800272:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800275:	50                   	push   %eax
  800276:	ff 75 08             	pushl  0x8(%ebp)
  800279:	e8 9d ff ff ff       	call   80021b <vcprintf>
	va_end(ap);

	return cnt;
}
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 1c             	sub    $0x1c,%esp
  800289:	89 c7                	mov    %eax,%edi
  80028b:	89 d6                	mov    %edx,%esi
  80028d:	8b 45 08             	mov    0x8(%ebp),%eax
  800290:	8b 55 0c             	mov    0xc(%ebp),%edx
  800293:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800296:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800299:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002a4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002a7:	39 d3                	cmp    %edx,%ebx
  8002a9:	72 05                	jb     8002b0 <printnum+0x30>
  8002ab:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ae:	77 45                	ja     8002f5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b0:	83 ec 0c             	sub    $0xc,%esp
  8002b3:	ff 75 18             	pushl  0x18(%ebp)
  8002b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002b9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002bc:	53                   	push   %ebx
  8002bd:	ff 75 10             	pushl  0x10(%ebp)
  8002c0:	83 ec 08             	sub    $0x8,%esp
  8002c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cf:	e8 bc 1f 00 00       	call   802290 <__udivdi3>
  8002d4:	83 c4 18             	add    $0x18,%esp
  8002d7:	52                   	push   %edx
  8002d8:	50                   	push   %eax
  8002d9:	89 f2                	mov    %esi,%edx
  8002db:	89 f8                	mov    %edi,%eax
  8002dd:	e8 9e ff ff ff       	call   800280 <printnum>
  8002e2:	83 c4 20             	add    $0x20,%esp
  8002e5:	eb 18                	jmp    8002ff <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e7:	83 ec 08             	sub    $0x8,%esp
  8002ea:	56                   	push   %esi
  8002eb:	ff 75 18             	pushl  0x18(%ebp)
  8002ee:	ff d7                	call   *%edi
  8002f0:	83 c4 10             	add    $0x10,%esp
  8002f3:	eb 03                	jmp    8002f8 <printnum+0x78>
  8002f5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f8:	83 eb 01             	sub    $0x1,%ebx
  8002fb:	85 db                	test   %ebx,%ebx
  8002fd:	7f e8                	jg     8002e7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	56                   	push   %esi
  800303:	83 ec 04             	sub    $0x4,%esp
  800306:	ff 75 e4             	pushl  -0x1c(%ebp)
  800309:	ff 75 e0             	pushl  -0x20(%ebp)
  80030c:	ff 75 dc             	pushl  -0x24(%ebp)
  80030f:	ff 75 d8             	pushl  -0x28(%ebp)
  800312:	e8 a9 20 00 00       	call   8023c0 <__umoddi3>
  800317:	83 c4 14             	add    $0x14,%esp
  80031a:	0f be 80 a7 25 80 00 	movsbl 0x8025a7(%eax),%eax
  800321:	50                   	push   %eax
  800322:	ff d7                	call   *%edi
}
  800324:	83 c4 10             	add    $0x10,%esp
  800327:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032a:	5b                   	pop    %ebx
  80032b:	5e                   	pop    %esi
  80032c:	5f                   	pop    %edi
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800332:	83 fa 01             	cmp    $0x1,%edx
  800335:	7e 0e                	jle    800345 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800337:	8b 10                	mov    (%eax),%edx
  800339:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033c:	89 08                	mov    %ecx,(%eax)
  80033e:	8b 02                	mov    (%edx),%eax
  800340:	8b 52 04             	mov    0x4(%edx),%edx
  800343:	eb 22                	jmp    800367 <getuint+0x38>
	else if (lflag)
  800345:	85 d2                	test   %edx,%edx
  800347:	74 10                	je     800359 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800349:	8b 10                	mov    (%eax),%edx
  80034b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034e:	89 08                	mov    %ecx,(%eax)
  800350:	8b 02                	mov    (%edx),%eax
  800352:	ba 00 00 00 00       	mov    $0x0,%edx
  800357:	eb 0e                	jmp    800367 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035e:	89 08                	mov    %ecx,(%eax)
  800360:	8b 02                	mov    (%edx),%eax
  800362:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800367:	5d                   	pop    %ebp
  800368:	c3                   	ret    

00800369 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800373:	8b 10                	mov    (%eax),%edx
  800375:	3b 50 04             	cmp    0x4(%eax),%edx
  800378:	73 0a                	jae    800384 <sprintputch+0x1b>
		*b->buf++ = ch;
  80037a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80037d:	89 08                	mov    %ecx,(%eax)
  80037f:	8b 45 08             	mov    0x8(%ebp),%eax
  800382:	88 02                	mov    %al,(%edx)
}
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80038c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038f:	50                   	push   %eax
  800390:	ff 75 10             	pushl  0x10(%ebp)
  800393:	ff 75 0c             	pushl  0xc(%ebp)
  800396:	ff 75 08             	pushl  0x8(%ebp)
  800399:	e8 05 00 00 00       	call   8003a3 <vprintfmt>
	va_end(ap);
}
  80039e:	83 c4 10             	add    $0x10,%esp
  8003a1:	c9                   	leave  
  8003a2:	c3                   	ret    

008003a3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	57                   	push   %edi
  8003a7:	56                   	push   %esi
  8003a8:	53                   	push   %ebx
  8003a9:	83 ec 2c             	sub    $0x2c,%esp
  8003ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8003af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b5:	eb 12                	jmp    8003c9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b7:	85 c0                	test   %eax,%eax
  8003b9:	0f 84 89 03 00 00    	je     800748 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8003bf:	83 ec 08             	sub    $0x8,%esp
  8003c2:	53                   	push   %ebx
  8003c3:	50                   	push   %eax
  8003c4:	ff d6                	call   *%esi
  8003c6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c9:	83 c7 01             	add    $0x1,%edi
  8003cc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003d0:	83 f8 25             	cmp    $0x25,%eax
  8003d3:	75 e2                	jne    8003b7 <vprintfmt+0x14>
  8003d5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003d9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003e0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f3:	eb 07                	jmp    8003fc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8d 47 01             	lea    0x1(%edi),%eax
  8003ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800402:	0f b6 07             	movzbl (%edi),%eax
  800405:	0f b6 c8             	movzbl %al,%ecx
  800408:	83 e8 23             	sub    $0x23,%eax
  80040b:	3c 55                	cmp    $0x55,%al
  80040d:	0f 87 1a 03 00 00    	ja     80072d <vprintfmt+0x38a>
  800413:	0f b6 c0             	movzbl %al,%eax
  800416:	ff 24 85 e0 26 80 00 	jmp    *0x8026e0(,%eax,4)
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800420:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800424:	eb d6                	jmp    8003fc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800429:	b8 00 00 00 00       	mov    $0x0,%eax
  80042e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800431:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800434:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800438:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80043b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80043e:	83 fa 09             	cmp    $0x9,%edx
  800441:	77 39                	ja     80047c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800443:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800446:	eb e9                	jmp    800431 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	8d 48 04             	lea    0x4(%eax),%ecx
  80044e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800451:	8b 00                	mov    (%eax),%eax
  800453:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800459:	eb 27                	jmp    800482 <vprintfmt+0xdf>
  80045b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045e:	85 c0                	test   %eax,%eax
  800460:	b9 00 00 00 00       	mov    $0x0,%ecx
  800465:	0f 49 c8             	cmovns %eax,%ecx
  800468:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046e:	eb 8c                	jmp    8003fc <vprintfmt+0x59>
  800470:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800473:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80047a:	eb 80                	jmp    8003fc <vprintfmt+0x59>
  80047c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80047f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800482:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800486:	0f 89 70 ff ff ff    	jns    8003fc <vprintfmt+0x59>
				width = precision, precision = -1;
  80048c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80048f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800492:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800499:	e9 5e ff ff ff       	jmp    8003fc <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80049e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a4:	e9 53 ff ff ff       	jmp    8003fc <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 50 04             	lea    0x4(%eax),%edx
  8004af:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	53                   	push   %ebx
  8004b6:	ff 30                	pushl  (%eax)
  8004b8:	ff d6                	call   *%esi
			break;
  8004ba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c0:	e9 04 ff ff ff       	jmp    8003c9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c8:	8d 50 04             	lea    0x4(%eax),%edx
  8004cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ce:	8b 00                	mov    (%eax),%eax
  8004d0:	99                   	cltd   
  8004d1:	31 d0                	xor    %edx,%eax
  8004d3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d5:	83 f8 0f             	cmp    $0xf,%eax
  8004d8:	7f 0b                	jg     8004e5 <vprintfmt+0x142>
  8004da:	8b 14 85 40 28 80 00 	mov    0x802840(,%eax,4),%edx
  8004e1:	85 d2                	test   %edx,%edx
  8004e3:	75 18                	jne    8004fd <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004e5:	50                   	push   %eax
  8004e6:	68 bf 25 80 00       	push   $0x8025bf
  8004eb:	53                   	push   %ebx
  8004ec:	56                   	push   %esi
  8004ed:	e8 94 fe ff ff       	call   800386 <printfmt>
  8004f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f8:	e9 cc fe ff ff       	jmp    8003c9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004fd:	52                   	push   %edx
  8004fe:	68 7e 29 80 00       	push   $0x80297e
  800503:	53                   	push   %ebx
  800504:	56                   	push   %esi
  800505:	e8 7c fe ff ff       	call   800386 <printfmt>
  80050a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800510:	e9 b4 fe ff ff       	jmp    8003c9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8d 50 04             	lea    0x4(%eax),%edx
  80051b:	89 55 14             	mov    %edx,0x14(%ebp)
  80051e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800520:	85 ff                	test   %edi,%edi
  800522:	b8 b8 25 80 00       	mov    $0x8025b8,%eax
  800527:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80052a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052e:	0f 8e 94 00 00 00    	jle    8005c8 <vprintfmt+0x225>
  800534:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800538:	0f 84 98 00 00 00    	je     8005d6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	ff 75 d0             	pushl  -0x30(%ebp)
  800544:	57                   	push   %edi
  800545:	e8 86 02 00 00       	call   8007d0 <strnlen>
  80054a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80054d:	29 c1                	sub    %eax,%ecx
  80054f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800552:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800555:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800559:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80055f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800561:	eb 0f                	jmp    800572 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	53                   	push   %ebx
  800567:	ff 75 e0             	pushl  -0x20(%ebp)
  80056a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056c:	83 ef 01             	sub    $0x1,%edi
  80056f:	83 c4 10             	add    $0x10,%esp
  800572:	85 ff                	test   %edi,%edi
  800574:	7f ed                	jg     800563 <vprintfmt+0x1c0>
  800576:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800579:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80057c:	85 c9                	test   %ecx,%ecx
  80057e:	b8 00 00 00 00       	mov    $0x0,%eax
  800583:	0f 49 c1             	cmovns %ecx,%eax
  800586:	29 c1                	sub    %eax,%ecx
  800588:	89 75 08             	mov    %esi,0x8(%ebp)
  80058b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800591:	89 cb                	mov    %ecx,%ebx
  800593:	eb 4d                	jmp    8005e2 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800595:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800599:	74 1b                	je     8005b6 <vprintfmt+0x213>
  80059b:	0f be c0             	movsbl %al,%eax
  80059e:	83 e8 20             	sub    $0x20,%eax
  8005a1:	83 f8 5e             	cmp    $0x5e,%eax
  8005a4:	76 10                	jbe    8005b6 <vprintfmt+0x213>
					putch('?', putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	ff 75 0c             	pushl  0xc(%ebp)
  8005ac:	6a 3f                	push   $0x3f
  8005ae:	ff 55 08             	call   *0x8(%ebp)
  8005b1:	83 c4 10             	add    $0x10,%esp
  8005b4:	eb 0d                	jmp    8005c3 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005b6:	83 ec 08             	sub    $0x8,%esp
  8005b9:	ff 75 0c             	pushl  0xc(%ebp)
  8005bc:	52                   	push   %edx
  8005bd:	ff 55 08             	call   *0x8(%ebp)
  8005c0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c3:	83 eb 01             	sub    $0x1,%ebx
  8005c6:	eb 1a                	jmp    8005e2 <vprintfmt+0x23f>
  8005c8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005cb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ce:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d4:	eb 0c                	jmp    8005e2 <vprintfmt+0x23f>
  8005d6:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005dc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005df:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005e2:	83 c7 01             	add    $0x1,%edi
  8005e5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005e9:	0f be d0             	movsbl %al,%edx
  8005ec:	85 d2                	test   %edx,%edx
  8005ee:	74 23                	je     800613 <vprintfmt+0x270>
  8005f0:	85 f6                	test   %esi,%esi
  8005f2:	78 a1                	js     800595 <vprintfmt+0x1f2>
  8005f4:	83 ee 01             	sub    $0x1,%esi
  8005f7:	79 9c                	jns    800595 <vprintfmt+0x1f2>
  8005f9:	89 df                	mov    %ebx,%edi
  8005fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800601:	eb 18                	jmp    80061b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800603:	83 ec 08             	sub    $0x8,%esp
  800606:	53                   	push   %ebx
  800607:	6a 20                	push   $0x20
  800609:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060b:	83 ef 01             	sub    $0x1,%edi
  80060e:	83 c4 10             	add    $0x10,%esp
  800611:	eb 08                	jmp    80061b <vprintfmt+0x278>
  800613:	89 df                	mov    %ebx,%edi
  800615:	8b 75 08             	mov    0x8(%ebp),%esi
  800618:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061b:	85 ff                	test   %edi,%edi
  80061d:	7f e4                	jg     800603 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800622:	e9 a2 fd ff ff       	jmp    8003c9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800627:	83 fa 01             	cmp    $0x1,%edx
  80062a:	7e 16                	jle    800642 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8d 50 08             	lea    0x8(%eax),%edx
  800632:	89 55 14             	mov    %edx,0x14(%ebp)
  800635:	8b 50 04             	mov    0x4(%eax),%edx
  800638:	8b 00                	mov    (%eax),%eax
  80063a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800640:	eb 32                	jmp    800674 <vprintfmt+0x2d1>
	else if (lflag)
  800642:	85 d2                	test   %edx,%edx
  800644:	74 18                	je     80065e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8d 50 04             	lea    0x4(%eax),%edx
  80064c:	89 55 14             	mov    %edx,0x14(%ebp)
  80064f:	8b 00                	mov    (%eax),%eax
  800651:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800654:	89 c1                	mov    %eax,%ecx
  800656:	c1 f9 1f             	sar    $0x1f,%ecx
  800659:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80065c:	eb 16                	jmp    800674 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)
  800667:	8b 00                	mov    (%eax),%eax
  800669:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066c:	89 c1                	mov    %eax,%ecx
  80066e:	c1 f9 1f             	sar    $0x1f,%ecx
  800671:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800674:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800677:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80067a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80067f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800683:	79 74                	jns    8006f9 <vprintfmt+0x356>
				putch('-', putdat);
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	53                   	push   %ebx
  800689:	6a 2d                	push   $0x2d
  80068b:	ff d6                	call   *%esi
				num = -(long long) num;
  80068d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800690:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800693:	f7 d8                	neg    %eax
  800695:	83 d2 00             	adc    $0x0,%edx
  800698:	f7 da                	neg    %edx
  80069a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80069d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006a2:	eb 55                	jmp    8006f9 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006a4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a7:	e8 83 fc ff ff       	call   80032f <getuint>
			base = 10;
  8006ac:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006b1:	eb 46                	jmp    8006f9 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b6:	e8 74 fc ff ff       	call   80032f <getuint>
                        base = 8;
  8006bb:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8006c0:	eb 37                	jmp    8006f9 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	53                   	push   %ebx
  8006c6:	6a 30                	push   $0x30
  8006c8:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ca:	83 c4 08             	add    $0x8,%esp
  8006cd:	53                   	push   %ebx
  8006ce:	6a 78                	push   $0x78
  8006d0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8d 50 04             	lea    0x4(%eax),%edx
  8006d8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006db:	8b 00                	mov    (%eax),%eax
  8006dd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006e2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006ea:	eb 0d                	jmp    8006f9 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ef:	e8 3b fc ff ff       	call   80032f <getuint>
			base = 16;
  8006f4:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f9:	83 ec 0c             	sub    $0xc,%esp
  8006fc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800700:	57                   	push   %edi
  800701:	ff 75 e0             	pushl  -0x20(%ebp)
  800704:	51                   	push   %ecx
  800705:	52                   	push   %edx
  800706:	50                   	push   %eax
  800707:	89 da                	mov    %ebx,%edx
  800709:	89 f0                	mov    %esi,%eax
  80070b:	e8 70 fb ff ff       	call   800280 <printnum>
			break;
  800710:	83 c4 20             	add    $0x20,%esp
  800713:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800716:	e9 ae fc ff ff       	jmp    8003c9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071b:	83 ec 08             	sub    $0x8,%esp
  80071e:	53                   	push   %ebx
  80071f:	51                   	push   %ecx
  800720:	ff d6                	call   *%esi
			break;
  800722:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800725:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800728:	e9 9c fc ff ff       	jmp    8003c9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	53                   	push   %ebx
  800731:	6a 25                	push   $0x25
  800733:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800735:	83 c4 10             	add    $0x10,%esp
  800738:	eb 03                	jmp    80073d <vprintfmt+0x39a>
  80073a:	83 ef 01             	sub    $0x1,%edi
  80073d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800741:	75 f7                	jne    80073a <vprintfmt+0x397>
  800743:	e9 81 fc ff ff       	jmp    8003c9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800748:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074b:	5b                   	pop    %ebx
  80074c:	5e                   	pop    %esi
  80074d:	5f                   	pop    %edi
  80074e:	5d                   	pop    %ebp
  80074f:	c3                   	ret    

00800750 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	83 ec 18             	sub    $0x18,%esp
  800756:	8b 45 08             	mov    0x8(%ebp),%eax
  800759:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800763:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800766:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076d:	85 c0                	test   %eax,%eax
  80076f:	74 26                	je     800797 <vsnprintf+0x47>
  800771:	85 d2                	test   %edx,%edx
  800773:	7e 22                	jle    800797 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800775:	ff 75 14             	pushl  0x14(%ebp)
  800778:	ff 75 10             	pushl  0x10(%ebp)
  80077b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077e:	50                   	push   %eax
  80077f:	68 69 03 80 00       	push   $0x800369
  800784:	e8 1a fc ff ff       	call   8003a3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800789:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800792:	83 c4 10             	add    $0x10,%esp
  800795:	eb 05                	jmp    80079c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800797:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079c:	c9                   	leave  
  80079d:	c3                   	ret    

0080079e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a7:	50                   	push   %eax
  8007a8:	ff 75 10             	pushl  0x10(%ebp)
  8007ab:	ff 75 0c             	pushl  0xc(%ebp)
  8007ae:	ff 75 08             	pushl  0x8(%ebp)
  8007b1:	e8 9a ff ff ff       	call   800750 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    

008007b8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007be:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c3:	eb 03                	jmp    8007c8 <strlen+0x10>
		n++;
  8007c5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007cc:	75 f7                	jne    8007c5 <strlen+0xd>
		n++;
	return n;
}
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007de:	eb 03                	jmp    8007e3 <strnlen+0x13>
		n++;
  8007e0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e3:	39 c2                	cmp    %eax,%edx
  8007e5:	74 08                	je     8007ef <strnlen+0x1f>
  8007e7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007eb:	75 f3                	jne    8007e0 <strnlen+0x10>
  8007ed:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	53                   	push   %ebx
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fb:	89 c2                	mov    %eax,%edx
  8007fd:	83 c2 01             	add    $0x1,%edx
  800800:	83 c1 01             	add    $0x1,%ecx
  800803:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800807:	88 5a ff             	mov    %bl,-0x1(%edx)
  80080a:	84 db                	test   %bl,%bl
  80080c:	75 ef                	jne    8007fd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80080e:	5b                   	pop    %ebx
  80080f:	5d                   	pop    %ebp
  800810:	c3                   	ret    

00800811 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	53                   	push   %ebx
  800815:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800818:	53                   	push   %ebx
  800819:	e8 9a ff ff ff       	call   8007b8 <strlen>
  80081e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800821:	ff 75 0c             	pushl  0xc(%ebp)
  800824:	01 d8                	add    %ebx,%eax
  800826:	50                   	push   %eax
  800827:	e8 c5 ff ff ff       	call   8007f1 <strcpy>
	return dst;
}
  80082c:	89 d8                	mov    %ebx,%eax
  80082e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800831:	c9                   	leave  
  800832:	c3                   	ret    

00800833 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	56                   	push   %esi
  800837:	53                   	push   %ebx
  800838:	8b 75 08             	mov    0x8(%ebp),%esi
  80083b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083e:	89 f3                	mov    %esi,%ebx
  800840:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800843:	89 f2                	mov    %esi,%edx
  800845:	eb 0f                	jmp    800856 <strncpy+0x23>
		*dst++ = *src;
  800847:	83 c2 01             	add    $0x1,%edx
  80084a:	0f b6 01             	movzbl (%ecx),%eax
  80084d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800850:	80 39 01             	cmpb   $0x1,(%ecx)
  800853:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800856:	39 da                	cmp    %ebx,%edx
  800858:	75 ed                	jne    800847 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085a:	89 f0                	mov    %esi,%eax
  80085c:	5b                   	pop    %ebx
  80085d:	5e                   	pop    %esi
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	56                   	push   %esi
  800864:	53                   	push   %ebx
  800865:	8b 75 08             	mov    0x8(%ebp),%esi
  800868:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086b:	8b 55 10             	mov    0x10(%ebp),%edx
  80086e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800870:	85 d2                	test   %edx,%edx
  800872:	74 21                	je     800895 <strlcpy+0x35>
  800874:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800878:	89 f2                	mov    %esi,%edx
  80087a:	eb 09                	jmp    800885 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087c:	83 c2 01             	add    $0x1,%edx
  80087f:	83 c1 01             	add    $0x1,%ecx
  800882:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800885:	39 c2                	cmp    %eax,%edx
  800887:	74 09                	je     800892 <strlcpy+0x32>
  800889:	0f b6 19             	movzbl (%ecx),%ebx
  80088c:	84 db                	test   %bl,%bl
  80088e:	75 ec                	jne    80087c <strlcpy+0x1c>
  800890:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800892:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800895:	29 f0                	sub    %esi,%eax
}
  800897:	5b                   	pop    %ebx
  800898:	5e                   	pop    %esi
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a4:	eb 06                	jmp    8008ac <strcmp+0x11>
		p++, q++;
  8008a6:	83 c1 01             	add    $0x1,%ecx
  8008a9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ac:	0f b6 01             	movzbl (%ecx),%eax
  8008af:	84 c0                	test   %al,%al
  8008b1:	74 04                	je     8008b7 <strcmp+0x1c>
  8008b3:	3a 02                	cmp    (%edx),%al
  8008b5:	74 ef                	je     8008a6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b7:	0f b6 c0             	movzbl %al,%eax
  8008ba:	0f b6 12             	movzbl (%edx),%edx
  8008bd:	29 d0                	sub    %edx,%eax
}
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	53                   	push   %ebx
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cb:	89 c3                	mov    %eax,%ebx
  8008cd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d0:	eb 06                	jmp    8008d8 <strncmp+0x17>
		n--, p++, q++;
  8008d2:	83 c0 01             	add    $0x1,%eax
  8008d5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d8:	39 d8                	cmp    %ebx,%eax
  8008da:	74 15                	je     8008f1 <strncmp+0x30>
  8008dc:	0f b6 08             	movzbl (%eax),%ecx
  8008df:	84 c9                	test   %cl,%cl
  8008e1:	74 04                	je     8008e7 <strncmp+0x26>
  8008e3:	3a 0a                	cmp    (%edx),%cl
  8008e5:	74 eb                	je     8008d2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e7:	0f b6 00             	movzbl (%eax),%eax
  8008ea:	0f b6 12             	movzbl (%edx),%edx
  8008ed:	29 d0                	sub    %edx,%eax
  8008ef:	eb 05                	jmp    8008f6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f6:	5b                   	pop    %ebx
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ff:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800903:	eb 07                	jmp    80090c <strchr+0x13>
		if (*s == c)
  800905:	38 ca                	cmp    %cl,%dl
  800907:	74 0f                	je     800918 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800909:	83 c0 01             	add    $0x1,%eax
  80090c:	0f b6 10             	movzbl (%eax),%edx
  80090f:	84 d2                	test   %dl,%dl
  800911:	75 f2                	jne    800905 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800924:	eb 03                	jmp    800929 <strfind+0xf>
  800926:	83 c0 01             	add    $0x1,%eax
  800929:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092c:	38 ca                	cmp    %cl,%dl
  80092e:	74 04                	je     800934 <strfind+0x1a>
  800930:	84 d2                	test   %dl,%dl
  800932:	75 f2                	jne    800926 <strfind+0xc>
			break;
	return (char *) s;
}
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	57                   	push   %edi
  80093a:	56                   	push   %esi
  80093b:	53                   	push   %ebx
  80093c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800942:	85 c9                	test   %ecx,%ecx
  800944:	74 36                	je     80097c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800946:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094c:	75 28                	jne    800976 <memset+0x40>
  80094e:	f6 c1 03             	test   $0x3,%cl
  800951:	75 23                	jne    800976 <memset+0x40>
		c &= 0xFF;
  800953:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800957:	89 d3                	mov    %edx,%ebx
  800959:	c1 e3 08             	shl    $0x8,%ebx
  80095c:	89 d6                	mov    %edx,%esi
  80095e:	c1 e6 18             	shl    $0x18,%esi
  800961:	89 d0                	mov    %edx,%eax
  800963:	c1 e0 10             	shl    $0x10,%eax
  800966:	09 f0                	or     %esi,%eax
  800968:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80096a:	89 d8                	mov    %ebx,%eax
  80096c:	09 d0                	or     %edx,%eax
  80096e:	c1 e9 02             	shr    $0x2,%ecx
  800971:	fc                   	cld    
  800972:	f3 ab                	rep stos %eax,%es:(%edi)
  800974:	eb 06                	jmp    80097c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800976:	8b 45 0c             	mov    0xc(%ebp),%eax
  800979:	fc                   	cld    
  80097a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097c:	89 f8                	mov    %edi,%eax
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	5f                   	pop    %edi
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	57                   	push   %edi
  800987:	56                   	push   %esi
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800991:	39 c6                	cmp    %eax,%esi
  800993:	73 35                	jae    8009ca <memmove+0x47>
  800995:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800998:	39 d0                	cmp    %edx,%eax
  80099a:	73 2e                	jae    8009ca <memmove+0x47>
		s += n;
		d += n;
  80099c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099f:	89 d6                	mov    %edx,%esi
  8009a1:	09 fe                	or     %edi,%esi
  8009a3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a9:	75 13                	jne    8009be <memmove+0x3b>
  8009ab:	f6 c1 03             	test   $0x3,%cl
  8009ae:	75 0e                	jne    8009be <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009b0:	83 ef 04             	sub    $0x4,%edi
  8009b3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b6:	c1 e9 02             	shr    $0x2,%ecx
  8009b9:	fd                   	std    
  8009ba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bc:	eb 09                	jmp    8009c7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009be:	83 ef 01             	sub    $0x1,%edi
  8009c1:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009c4:	fd                   	std    
  8009c5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c7:	fc                   	cld    
  8009c8:	eb 1d                	jmp    8009e7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ca:	89 f2                	mov    %esi,%edx
  8009cc:	09 c2                	or     %eax,%edx
  8009ce:	f6 c2 03             	test   $0x3,%dl
  8009d1:	75 0f                	jne    8009e2 <memmove+0x5f>
  8009d3:	f6 c1 03             	test   $0x3,%cl
  8009d6:	75 0a                	jne    8009e2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009d8:	c1 e9 02             	shr    $0x2,%ecx
  8009db:	89 c7                	mov    %eax,%edi
  8009dd:	fc                   	cld    
  8009de:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e0:	eb 05                	jmp    8009e7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e2:	89 c7                	mov    %eax,%edi
  8009e4:	fc                   	cld    
  8009e5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e7:	5e                   	pop    %esi
  8009e8:	5f                   	pop    %edi
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ee:	ff 75 10             	pushl  0x10(%ebp)
  8009f1:	ff 75 0c             	pushl  0xc(%ebp)
  8009f4:	ff 75 08             	pushl  0x8(%ebp)
  8009f7:	e8 87 ff ff ff       	call   800983 <memmove>
}
  8009fc:	c9                   	leave  
  8009fd:	c3                   	ret    

008009fe <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
  800a06:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a09:	89 c6                	mov    %eax,%esi
  800a0b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0e:	eb 1a                	jmp    800a2a <memcmp+0x2c>
		if (*s1 != *s2)
  800a10:	0f b6 08             	movzbl (%eax),%ecx
  800a13:	0f b6 1a             	movzbl (%edx),%ebx
  800a16:	38 d9                	cmp    %bl,%cl
  800a18:	74 0a                	je     800a24 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a1a:	0f b6 c1             	movzbl %cl,%eax
  800a1d:	0f b6 db             	movzbl %bl,%ebx
  800a20:	29 d8                	sub    %ebx,%eax
  800a22:	eb 0f                	jmp    800a33 <memcmp+0x35>
		s1++, s2++;
  800a24:	83 c0 01             	add    $0x1,%eax
  800a27:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2a:	39 f0                	cmp    %esi,%eax
  800a2c:	75 e2                	jne    800a10 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a33:	5b                   	pop    %ebx
  800a34:	5e                   	pop    %esi
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	53                   	push   %ebx
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a3e:	89 c1                	mov    %eax,%ecx
  800a40:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a43:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a47:	eb 0a                	jmp    800a53 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a49:	0f b6 10             	movzbl (%eax),%edx
  800a4c:	39 da                	cmp    %ebx,%edx
  800a4e:	74 07                	je     800a57 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a50:	83 c0 01             	add    $0x1,%eax
  800a53:	39 c8                	cmp    %ecx,%eax
  800a55:	72 f2                	jb     800a49 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a57:	5b                   	pop    %ebx
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	57                   	push   %edi
  800a5e:	56                   	push   %esi
  800a5f:	53                   	push   %ebx
  800a60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a66:	eb 03                	jmp    800a6b <strtol+0x11>
		s++;
  800a68:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6b:	0f b6 01             	movzbl (%ecx),%eax
  800a6e:	3c 20                	cmp    $0x20,%al
  800a70:	74 f6                	je     800a68 <strtol+0xe>
  800a72:	3c 09                	cmp    $0x9,%al
  800a74:	74 f2                	je     800a68 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a76:	3c 2b                	cmp    $0x2b,%al
  800a78:	75 0a                	jne    800a84 <strtol+0x2a>
		s++;
  800a7a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a82:	eb 11                	jmp    800a95 <strtol+0x3b>
  800a84:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a89:	3c 2d                	cmp    $0x2d,%al
  800a8b:	75 08                	jne    800a95 <strtol+0x3b>
		s++, neg = 1;
  800a8d:	83 c1 01             	add    $0x1,%ecx
  800a90:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a95:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9b:	75 15                	jne    800ab2 <strtol+0x58>
  800a9d:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa0:	75 10                	jne    800ab2 <strtol+0x58>
  800aa2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa6:	75 7c                	jne    800b24 <strtol+0xca>
		s += 2, base = 16;
  800aa8:	83 c1 02             	add    $0x2,%ecx
  800aab:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab0:	eb 16                	jmp    800ac8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ab2:	85 db                	test   %ebx,%ebx
  800ab4:	75 12                	jne    800ac8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abb:	80 39 30             	cmpb   $0x30,(%ecx)
  800abe:	75 08                	jne    800ac8 <strtol+0x6e>
		s++, base = 8;
  800ac0:	83 c1 01             	add    $0x1,%ecx
  800ac3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ac8:	b8 00 00 00 00       	mov    $0x0,%eax
  800acd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad0:	0f b6 11             	movzbl (%ecx),%edx
  800ad3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad6:	89 f3                	mov    %esi,%ebx
  800ad8:	80 fb 09             	cmp    $0x9,%bl
  800adb:	77 08                	ja     800ae5 <strtol+0x8b>
			dig = *s - '0';
  800add:	0f be d2             	movsbl %dl,%edx
  800ae0:	83 ea 30             	sub    $0x30,%edx
  800ae3:	eb 22                	jmp    800b07 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ae5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae8:	89 f3                	mov    %esi,%ebx
  800aea:	80 fb 19             	cmp    $0x19,%bl
  800aed:	77 08                	ja     800af7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aef:	0f be d2             	movsbl %dl,%edx
  800af2:	83 ea 57             	sub    $0x57,%edx
  800af5:	eb 10                	jmp    800b07 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800af7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800afa:	89 f3                	mov    %esi,%ebx
  800afc:	80 fb 19             	cmp    $0x19,%bl
  800aff:	77 16                	ja     800b17 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b01:	0f be d2             	movsbl %dl,%edx
  800b04:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b07:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b0a:	7d 0b                	jge    800b17 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b0c:	83 c1 01             	add    $0x1,%ecx
  800b0f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b13:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b15:	eb b9                	jmp    800ad0 <strtol+0x76>

	if (endptr)
  800b17:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1b:	74 0d                	je     800b2a <strtol+0xd0>
		*endptr = (char *) s;
  800b1d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b20:	89 0e                	mov    %ecx,(%esi)
  800b22:	eb 06                	jmp    800b2a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b24:	85 db                	test   %ebx,%ebx
  800b26:	74 98                	je     800ac0 <strtol+0x66>
  800b28:	eb 9e                	jmp    800ac8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b2a:	89 c2                	mov    %eax,%edx
  800b2c:	f7 da                	neg    %edx
  800b2e:	85 ff                	test   %edi,%edi
  800b30:	0f 45 c2             	cmovne %edx,%eax
}
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b46:	8b 55 08             	mov    0x8(%ebp),%edx
  800b49:	89 c3                	mov    %eax,%ebx
  800b4b:	89 c7                	mov    %eax,%edi
  800b4d:	89 c6                	mov    %eax,%esi
  800b4f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b61:	b8 01 00 00 00       	mov    $0x1,%eax
  800b66:	89 d1                	mov    %edx,%ecx
  800b68:	89 d3                	mov    %edx,%ebx
  800b6a:	89 d7                	mov    %edx,%edi
  800b6c:	89 d6                	mov    %edx,%esi
  800b6e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
  800b7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b83:	b8 03 00 00 00       	mov    $0x3,%eax
  800b88:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8b:	89 cb                	mov    %ecx,%ebx
  800b8d:	89 cf                	mov    %ecx,%edi
  800b8f:	89 ce                	mov    %ecx,%esi
  800b91:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b93:	85 c0                	test   %eax,%eax
  800b95:	7e 17                	jle    800bae <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b97:	83 ec 0c             	sub    $0xc,%esp
  800b9a:	50                   	push   %eax
  800b9b:	6a 03                	push   $0x3
  800b9d:	68 9f 28 80 00       	push   $0x80289f
  800ba2:	6a 23                	push   $0x23
  800ba4:	68 bc 28 80 00       	push   $0x8028bc
  800ba9:	e8 e5 f5 ff ff       	call   800193 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbc:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc1:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc6:	89 d1                	mov    %edx,%ecx
  800bc8:	89 d3                	mov    %edx,%ebx
  800bca:	89 d7                	mov    %edx,%edi
  800bcc:	89 d6                	mov    %edx,%esi
  800bce:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <sys_yield>:

void
sys_yield(void)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	57                   	push   %edi
  800bd9:	56                   	push   %esi
  800bda:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800be0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be5:	89 d1                	mov    %edx,%ecx
  800be7:	89 d3                	mov    %edx,%ebx
  800be9:	89 d7                	mov    %edx,%edi
  800beb:	89 d6                	mov    %edx,%esi
  800bed:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfd:	be 00 00 00 00       	mov    $0x0,%esi
  800c02:	b8 04 00 00 00       	mov    $0x4,%eax
  800c07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c10:	89 f7                	mov    %esi,%edi
  800c12:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c14:	85 c0                	test   %eax,%eax
  800c16:	7e 17                	jle    800c2f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c18:	83 ec 0c             	sub    $0xc,%esp
  800c1b:	50                   	push   %eax
  800c1c:	6a 04                	push   $0x4
  800c1e:	68 9f 28 80 00       	push   $0x80289f
  800c23:	6a 23                	push   $0x23
  800c25:	68 bc 28 80 00       	push   $0x8028bc
  800c2a:	e8 64 f5 ff ff       	call   800193 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c40:	b8 05 00 00 00       	mov    $0x5,%eax
  800c45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c48:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c51:	8b 75 18             	mov    0x18(%ebp),%esi
  800c54:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c56:	85 c0                	test   %eax,%eax
  800c58:	7e 17                	jle    800c71 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5a:	83 ec 0c             	sub    $0xc,%esp
  800c5d:	50                   	push   %eax
  800c5e:	6a 05                	push   $0x5
  800c60:	68 9f 28 80 00       	push   $0x80289f
  800c65:	6a 23                	push   $0x23
  800c67:	68 bc 28 80 00       	push   $0x8028bc
  800c6c:	e8 22 f5 ff ff       	call   800193 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800c82:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c87:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c92:	89 df                	mov    %ebx,%edi
  800c94:	89 de                	mov    %ebx,%esi
  800c96:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c98:	85 c0                	test   %eax,%eax
  800c9a:	7e 17                	jle    800cb3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9c:	83 ec 0c             	sub    $0xc,%esp
  800c9f:	50                   	push   %eax
  800ca0:	6a 06                	push   $0x6
  800ca2:	68 9f 28 80 00       	push   $0x80289f
  800ca7:	6a 23                	push   $0x23
  800ca9:	68 bc 28 80 00       	push   $0x8028bc
  800cae:	e8 e0 f4 ff ff       	call   800193 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb6:	5b                   	pop    %ebx
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
  800cc1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd4:	89 df                	mov    %ebx,%edi
  800cd6:	89 de                	mov    %ebx,%esi
  800cd8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cda:	85 c0                	test   %eax,%eax
  800cdc:	7e 17                	jle    800cf5 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cde:	83 ec 0c             	sub    $0xc,%esp
  800ce1:	50                   	push   %eax
  800ce2:	6a 08                	push   $0x8
  800ce4:	68 9f 28 80 00       	push   $0x80289f
  800ce9:	6a 23                	push   $0x23
  800ceb:	68 bc 28 80 00       	push   $0x8028bc
  800cf0:	e8 9e f4 ff ff       	call   800193 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
  800d03:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d13:	8b 55 08             	mov    0x8(%ebp),%edx
  800d16:	89 df                	mov    %ebx,%edi
  800d18:	89 de                	mov    %ebx,%esi
  800d1a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	7e 17                	jle    800d37 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d20:	83 ec 0c             	sub    $0xc,%esp
  800d23:	50                   	push   %eax
  800d24:	6a 09                	push   $0x9
  800d26:	68 9f 28 80 00       	push   $0x80289f
  800d2b:	6a 23                	push   $0x23
  800d2d:	68 bc 28 80 00       	push   $0x8028bc
  800d32:	e8 5c f4 ff ff       	call   800193 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3a:	5b                   	pop    %ebx
  800d3b:	5e                   	pop    %esi
  800d3c:	5f                   	pop    %edi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	57                   	push   %edi
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
  800d45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d55:	8b 55 08             	mov    0x8(%ebp),%edx
  800d58:	89 df                	mov    %ebx,%edi
  800d5a:	89 de                	mov    %ebx,%esi
  800d5c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	7e 17                	jle    800d79 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d62:	83 ec 0c             	sub    $0xc,%esp
  800d65:	50                   	push   %eax
  800d66:	6a 0a                	push   $0xa
  800d68:	68 9f 28 80 00       	push   $0x80289f
  800d6d:	6a 23                	push   $0x23
  800d6f:	68 bc 28 80 00       	push   $0x8028bc
  800d74:	e8 1a f4 ff ff       	call   800193 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5f                   	pop    %edi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d87:	be 00 00 00 00       	mov    $0x0,%esi
  800d8c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d94:	8b 55 08             	mov    0x8(%ebp),%edx
  800d97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d9f:	5b                   	pop    %ebx
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
  800daa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dad:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db2:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dba:	89 cb                	mov    %ecx,%ebx
  800dbc:	89 cf                	mov    %ecx,%edi
  800dbe:	89 ce                	mov    %ecx,%esi
  800dc0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	7e 17                	jle    800ddd <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc6:	83 ec 0c             	sub    $0xc,%esp
  800dc9:	50                   	push   %eax
  800dca:	6a 0d                	push   $0xd
  800dcc:	68 9f 28 80 00       	push   $0x80289f
  800dd1:	6a 23                	push   $0x23
  800dd3:	68 bc 28 80 00       	push   $0x8028bc
  800dd8:	e8 b6 f3 ff ff       	call   800193 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ddd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	57                   	push   %edi
  800de9:	56                   	push   %esi
  800dea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800deb:	ba 00 00 00 00       	mov    $0x0,%edx
  800df0:	b8 0e 00 00 00       	mov    $0xe,%eax
  800df5:	89 d1                	mov    %edx,%ecx
  800df7:	89 d3                	mov    %edx,%ebx
  800df9:	89 d7                	mov    %edx,%edi
  800dfb:	89 d6                	mov    %edx,%esi
  800dfd:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dff:	5b                   	pop    %ebx
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <sys_transmit_packet>:

int
sys_transmit_packet(void *buf, size_t size)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	57                   	push   %edi
  800e08:	56                   	push   %esi
  800e09:	53                   	push   %ebx
  800e0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e12:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1d:	89 df                	mov    %ebx,%edi
  800e1f:	89 de                	mov    %ebx,%esi
  800e21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e23:	85 c0                	test   %eax,%eax
  800e25:	7e 17                	jle    800e3e <sys_transmit_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e27:	83 ec 0c             	sub    $0xc,%esp
  800e2a:	50                   	push   %eax
  800e2b:	6a 0f                	push   $0xf
  800e2d:	68 9f 28 80 00       	push   $0x80289f
  800e32:	6a 23                	push   $0x23
  800e34:	68 bc 28 80 00       	push   $0x8028bc
  800e39:	e8 55 f3 ff ff       	call   800193 <_panic>
int
sys_transmit_packet(void *buf, size_t size)
{
	return syscall(SYS_transmit_packet, 1,
		(uint32_t) buf, (uint32_t) size, 0, 0, 0);
}
  800e3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e41:	5b                   	pop    %ebx
  800e42:	5e                   	pop    %esi
  800e43:	5f                   	pop    %edi
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    

00800e46 <sys_receive_packet>:

int
sys_receive_packet(void *buf, size_t *size_store)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	57                   	push   %edi
  800e4a:	56                   	push   %esi
  800e4b:	53                   	push   %ebx
  800e4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e54:	b8 10 00 00 00       	mov    $0x10,%eax
  800e59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5f:	89 df                	mov    %ebx,%edi
  800e61:	89 de                	mov    %ebx,%esi
  800e63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e65:	85 c0                	test   %eax,%eax
  800e67:	7e 17                	jle    800e80 <sys_receive_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e69:	83 ec 0c             	sub    $0xc,%esp
  800e6c:	50                   	push   %eax
  800e6d:	6a 10                	push   $0x10
  800e6f:	68 9f 28 80 00       	push   $0x80289f
  800e74:	6a 23                	push   $0x23
  800e76:	68 bc 28 80 00       	push   $0x8028bc
  800e7b:	e8 13 f3 ff ff       	call   800193 <_panic>
int
sys_receive_packet(void *buf, size_t *size_store)
{
	return syscall(SYS_receive_packet, 1,
		(uint32_t) buf, (uint32_t) size_store, 0, 0, 0);
}
  800e80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <sys_get_mac_address>:

int
sys_get_mac_address(void *buf)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	57                   	push   %edi
  800e8c:	56                   	push   %esi
  800e8d:	53                   	push   %ebx
  800e8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e91:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e96:	b8 11 00 00 00       	mov    $0x11,%eax
  800e9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9e:	89 cb                	mov    %ecx,%ebx
  800ea0:	89 cf                	mov    %ecx,%edi
  800ea2:	89 ce                	mov    %ecx,%esi
  800ea4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	7e 17                	jle    800ec1 <sys_get_mac_address+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eaa:	83 ec 0c             	sub    $0xc,%esp
  800ead:	50                   	push   %eax
  800eae:	6a 11                	push   $0x11
  800eb0:	68 9f 28 80 00       	push   $0x80289f
  800eb5:	6a 23                	push   $0x23
  800eb7:	68 bc 28 80 00       	push   $0x8028bc
  800ebc:	e8 d2 f2 ff ff       	call   800193 <_panic>
int
sys_get_mac_address(void *buf)
{
	return syscall(SYS_get_mac_address, 1,
		(uint32_t) buf, 0, 0, 0, 0);
}
  800ec1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    

00800ec9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ecc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecf:	05 00 00 00 30       	add    $0x30000000,%eax
  800ed4:	c1 e8 0c             	shr    $0xc,%eax
}
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    

00800ed9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800edc:	8b 45 08             	mov    0x8(%ebp),%eax
  800edf:	05 00 00 00 30       	add    $0x30000000,%eax
  800ee4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ee9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800efb:	89 c2                	mov    %eax,%edx
  800efd:	c1 ea 16             	shr    $0x16,%edx
  800f00:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f07:	f6 c2 01             	test   $0x1,%dl
  800f0a:	74 11                	je     800f1d <fd_alloc+0x2d>
  800f0c:	89 c2                	mov    %eax,%edx
  800f0e:	c1 ea 0c             	shr    $0xc,%edx
  800f11:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f18:	f6 c2 01             	test   $0x1,%dl
  800f1b:	75 09                	jne    800f26 <fd_alloc+0x36>
			*fd_store = fd;
  800f1d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f24:	eb 17                	jmp    800f3d <fd_alloc+0x4d>
  800f26:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f2b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f30:	75 c9                	jne    800efb <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f32:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f38:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f3d:	5d                   	pop    %ebp
  800f3e:	c3                   	ret    

00800f3f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f45:	83 f8 1f             	cmp    $0x1f,%eax
  800f48:	77 36                	ja     800f80 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f4a:	c1 e0 0c             	shl    $0xc,%eax
  800f4d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f52:	89 c2                	mov    %eax,%edx
  800f54:	c1 ea 16             	shr    $0x16,%edx
  800f57:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f5e:	f6 c2 01             	test   $0x1,%dl
  800f61:	74 24                	je     800f87 <fd_lookup+0x48>
  800f63:	89 c2                	mov    %eax,%edx
  800f65:	c1 ea 0c             	shr    $0xc,%edx
  800f68:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f6f:	f6 c2 01             	test   $0x1,%dl
  800f72:	74 1a                	je     800f8e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f74:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f77:	89 02                	mov    %eax,(%edx)
	return 0;
  800f79:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7e:	eb 13                	jmp    800f93 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f80:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f85:	eb 0c                	jmp    800f93 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f87:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f8c:	eb 05                	jmp    800f93 <fd_lookup+0x54>
  800f8e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    

00800f95 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	83 ec 08             	sub    $0x8,%esp
  800f9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f9e:	ba 4c 29 80 00       	mov    $0x80294c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800fa3:	eb 13                	jmp    800fb8 <dev_lookup+0x23>
  800fa5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800fa8:	39 08                	cmp    %ecx,(%eax)
  800faa:	75 0c                	jne    800fb8 <dev_lookup+0x23>
			*dev = devtab[i];
  800fac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800faf:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb6:	eb 2e                	jmp    800fe6 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fb8:	8b 02                	mov    (%edx),%eax
  800fba:	85 c0                	test   %eax,%eax
  800fbc:	75 e7                	jne    800fa5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fbe:	a1 20 60 80 00       	mov    0x806020,%eax
  800fc3:	8b 40 48             	mov    0x48(%eax),%eax
  800fc6:	83 ec 04             	sub    $0x4,%esp
  800fc9:	51                   	push   %ecx
  800fca:	50                   	push   %eax
  800fcb:	68 cc 28 80 00       	push   $0x8028cc
  800fd0:	e8 97 f2 ff ff       	call   80026c <cprintf>
	*dev = 0;
  800fd5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fde:	83 c4 10             	add    $0x10,%esp
  800fe1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fe6:	c9                   	leave  
  800fe7:	c3                   	ret    

00800fe8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	56                   	push   %esi
  800fec:	53                   	push   %ebx
  800fed:	83 ec 10             	sub    $0x10,%esp
  800ff0:	8b 75 08             	mov    0x8(%ebp),%esi
  800ff3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ff6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff9:	50                   	push   %eax
  800ffa:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801000:	c1 e8 0c             	shr    $0xc,%eax
  801003:	50                   	push   %eax
  801004:	e8 36 ff ff ff       	call   800f3f <fd_lookup>
  801009:	83 c4 08             	add    $0x8,%esp
  80100c:	85 c0                	test   %eax,%eax
  80100e:	78 05                	js     801015 <fd_close+0x2d>
	    || fd != fd2)
  801010:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801013:	74 0c                	je     801021 <fd_close+0x39>
		return (must_exist ? r : 0);
  801015:	84 db                	test   %bl,%bl
  801017:	ba 00 00 00 00       	mov    $0x0,%edx
  80101c:	0f 44 c2             	cmove  %edx,%eax
  80101f:	eb 41                	jmp    801062 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801021:	83 ec 08             	sub    $0x8,%esp
  801024:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801027:	50                   	push   %eax
  801028:	ff 36                	pushl  (%esi)
  80102a:	e8 66 ff ff ff       	call   800f95 <dev_lookup>
  80102f:	89 c3                	mov    %eax,%ebx
  801031:	83 c4 10             	add    $0x10,%esp
  801034:	85 c0                	test   %eax,%eax
  801036:	78 1a                	js     801052 <fd_close+0x6a>
		if (dev->dev_close)
  801038:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80103b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80103e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801043:	85 c0                	test   %eax,%eax
  801045:	74 0b                	je     801052 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801047:	83 ec 0c             	sub    $0xc,%esp
  80104a:	56                   	push   %esi
  80104b:	ff d0                	call   *%eax
  80104d:	89 c3                	mov    %eax,%ebx
  80104f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801052:	83 ec 08             	sub    $0x8,%esp
  801055:	56                   	push   %esi
  801056:	6a 00                	push   $0x0
  801058:	e8 1c fc ff ff       	call   800c79 <sys_page_unmap>
	return r;
  80105d:	83 c4 10             	add    $0x10,%esp
  801060:	89 d8                	mov    %ebx,%eax
}
  801062:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801065:	5b                   	pop    %ebx
  801066:	5e                   	pop    %esi
  801067:	5d                   	pop    %ebp
  801068:	c3                   	ret    

00801069 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
  80106c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80106f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801072:	50                   	push   %eax
  801073:	ff 75 08             	pushl  0x8(%ebp)
  801076:	e8 c4 fe ff ff       	call   800f3f <fd_lookup>
  80107b:	83 c4 08             	add    $0x8,%esp
  80107e:	85 c0                	test   %eax,%eax
  801080:	78 10                	js     801092 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801082:	83 ec 08             	sub    $0x8,%esp
  801085:	6a 01                	push   $0x1
  801087:	ff 75 f4             	pushl  -0xc(%ebp)
  80108a:	e8 59 ff ff ff       	call   800fe8 <fd_close>
  80108f:	83 c4 10             	add    $0x10,%esp
}
  801092:	c9                   	leave  
  801093:	c3                   	ret    

00801094 <close_all>:

void
close_all(void)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	53                   	push   %ebx
  801098:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80109b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010a0:	83 ec 0c             	sub    $0xc,%esp
  8010a3:	53                   	push   %ebx
  8010a4:	e8 c0 ff ff ff       	call   801069 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010a9:	83 c3 01             	add    $0x1,%ebx
  8010ac:	83 c4 10             	add    $0x10,%esp
  8010af:	83 fb 20             	cmp    $0x20,%ebx
  8010b2:	75 ec                	jne    8010a0 <close_all+0xc>
		close(i);
}
  8010b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b7:	c9                   	leave  
  8010b8:	c3                   	ret    

008010b9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	57                   	push   %edi
  8010bd:	56                   	push   %esi
  8010be:	53                   	push   %ebx
  8010bf:	83 ec 2c             	sub    $0x2c,%esp
  8010c2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010c5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010c8:	50                   	push   %eax
  8010c9:	ff 75 08             	pushl  0x8(%ebp)
  8010cc:	e8 6e fe ff ff       	call   800f3f <fd_lookup>
  8010d1:	83 c4 08             	add    $0x8,%esp
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	0f 88 c1 00 00 00    	js     80119d <dup+0xe4>
		return r;
	close(newfdnum);
  8010dc:	83 ec 0c             	sub    $0xc,%esp
  8010df:	56                   	push   %esi
  8010e0:	e8 84 ff ff ff       	call   801069 <close>

	newfd = INDEX2FD(newfdnum);
  8010e5:	89 f3                	mov    %esi,%ebx
  8010e7:	c1 e3 0c             	shl    $0xc,%ebx
  8010ea:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010f0:	83 c4 04             	add    $0x4,%esp
  8010f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f6:	e8 de fd ff ff       	call   800ed9 <fd2data>
  8010fb:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010fd:	89 1c 24             	mov    %ebx,(%esp)
  801100:	e8 d4 fd ff ff       	call   800ed9 <fd2data>
  801105:	83 c4 10             	add    $0x10,%esp
  801108:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80110b:	89 f8                	mov    %edi,%eax
  80110d:	c1 e8 16             	shr    $0x16,%eax
  801110:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801117:	a8 01                	test   $0x1,%al
  801119:	74 37                	je     801152 <dup+0x99>
  80111b:	89 f8                	mov    %edi,%eax
  80111d:	c1 e8 0c             	shr    $0xc,%eax
  801120:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801127:	f6 c2 01             	test   $0x1,%dl
  80112a:	74 26                	je     801152 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80112c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801133:	83 ec 0c             	sub    $0xc,%esp
  801136:	25 07 0e 00 00       	and    $0xe07,%eax
  80113b:	50                   	push   %eax
  80113c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80113f:	6a 00                	push   $0x0
  801141:	57                   	push   %edi
  801142:	6a 00                	push   $0x0
  801144:	e8 ee fa ff ff       	call   800c37 <sys_page_map>
  801149:	89 c7                	mov    %eax,%edi
  80114b:	83 c4 20             	add    $0x20,%esp
  80114e:	85 c0                	test   %eax,%eax
  801150:	78 2e                	js     801180 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801152:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801155:	89 d0                	mov    %edx,%eax
  801157:	c1 e8 0c             	shr    $0xc,%eax
  80115a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801161:	83 ec 0c             	sub    $0xc,%esp
  801164:	25 07 0e 00 00       	and    $0xe07,%eax
  801169:	50                   	push   %eax
  80116a:	53                   	push   %ebx
  80116b:	6a 00                	push   $0x0
  80116d:	52                   	push   %edx
  80116e:	6a 00                	push   $0x0
  801170:	e8 c2 fa ff ff       	call   800c37 <sys_page_map>
  801175:	89 c7                	mov    %eax,%edi
  801177:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80117a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80117c:	85 ff                	test   %edi,%edi
  80117e:	79 1d                	jns    80119d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801180:	83 ec 08             	sub    $0x8,%esp
  801183:	53                   	push   %ebx
  801184:	6a 00                	push   $0x0
  801186:	e8 ee fa ff ff       	call   800c79 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80118b:	83 c4 08             	add    $0x8,%esp
  80118e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801191:	6a 00                	push   $0x0
  801193:	e8 e1 fa ff ff       	call   800c79 <sys_page_unmap>
	return r;
  801198:	83 c4 10             	add    $0x10,%esp
  80119b:	89 f8                	mov    %edi,%eax
}
  80119d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a0:	5b                   	pop    %ebx
  8011a1:	5e                   	pop    %esi
  8011a2:	5f                   	pop    %edi
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    

008011a5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	53                   	push   %ebx
  8011a9:	83 ec 14             	sub    $0x14,%esp
  8011ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b2:	50                   	push   %eax
  8011b3:	53                   	push   %ebx
  8011b4:	e8 86 fd ff ff       	call   800f3f <fd_lookup>
  8011b9:	83 c4 08             	add    $0x8,%esp
  8011bc:	89 c2                	mov    %eax,%edx
  8011be:	85 c0                	test   %eax,%eax
  8011c0:	78 6d                	js     80122f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c2:	83 ec 08             	sub    $0x8,%esp
  8011c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c8:	50                   	push   %eax
  8011c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cc:	ff 30                	pushl  (%eax)
  8011ce:	e8 c2 fd ff ff       	call   800f95 <dev_lookup>
  8011d3:	83 c4 10             	add    $0x10,%esp
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	78 4c                	js     801226 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011da:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011dd:	8b 42 08             	mov    0x8(%edx),%eax
  8011e0:	83 e0 03             	and    $0x3,%eax
  8011e3:	83 f8 01             	cmp    $0x1,%eax
  8011e6:	75 21                	jne    801209 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e8:	a1 20 60 80 00       	mov    0x806020,%eax
  8011ed:	8b 40 48             	mov    0x48(%eax),%eax
  8011f0:	83 ec 04             	sub    $0x4,%esp
  8011f3:	53                   	push   %ebx
  8011f4:	50                   	push   %eax
  8011f5:	68 10 29 80 00       	push   $0x802910
  8011fa:	e8 6d f0 ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  8011ff:	83 c4 10             	add    $0x10,%esp
  801202:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801207:	eb 26                	jmp    80122f <read+0x8a>
	}
	if (!dev->dev_read)
  801209:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80120c:	8b 40 08             	mov    0x8(%eax),%eax
  80120f:	85 c0                	test   %eax,%eax
  801211:	74 17                	je     80122a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801213:	83 ec 04             	sub    $0x4,%esp
  801216:	ff 75 10             	pushl  0x10(%ebp)
  801219:	ff 75 0c             	pushl  0xc(%ebp)
  80121c:	52                   	push   %edx
  80121d:	ff d0                	call   *%eax
  80121f:	89 c2                	mov    %eax,%edx
  801221:	83 c4 10             	add    $0x10,%esp
  801224:	eb 09                	jmp    80122f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801226:	89 c2                	mov    %eax,%edx
  801228:	eb 05                	jmp    80122f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80122a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80122f:	89 d0                	mov    %edx,%eax
  801231:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801234:	c9                   	leave  
  801235:	c3                   	ret    

00801236 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	57                   	push   %edi
  80123a:	56                   	push   %esi
  80123b:	53                   	push   %ebx
  80123c:	83 ec 0c             	sub    $0xc,%esp
  80123f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801242:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801245:	bb 00 00 00 00       	mov    $0x0,%ebx
  80124a:	eb 21                	jmp    80126d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80124c:	83 ec 04             	sub    $0x4,%esp
  80124f:	89 f0                	mov    %esi,%eax
  801251:	29 d8                	sub    %ebx,%eax
  801253:	50                   	push   %eax
  801254:	89 d8                	mov    %ebx,%eax
  801256:	03 45 0c             	add    0xc(%ebp),%eax
  801259:	50                   	push   %eax
  80125a:	57                   	push   %edi
  80125b:	e8 45 ff ff ff       	call   8011a5 <read>
		if (m < 0)
  801260:	83 c4 10             	add    $0x10,%esp
  801263:	85 c0                	test   %eax,%eax
  801265:	78 10                	js     801277 <readn+0x41>
			return m;
		if (m == 0)
  801267:	85 c0                	test   %eax,%eax
  801269:	74 0a                	je     801275 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80126b:	01 c3                	add    %eax,%ebx
  80126d:	39 f3                	cmp    %esi,%ebx
  80126f:	72 db                	jb     80124c <readn+0x16>
  801271:	89 d8                	mov    %ebx,%eax
  801273:	eb 02                	jmp    801277 <readn+0x41>
  801275:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801277:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80127a:	5b                   	pop    %ebx
  80127b:	5e                   	pop    %esi
  80127c:	5f                   	pop    %edi
  80127d:	5d                   	pop    %ebp
  80127e:	c3                   	ret    

0080127f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
  801282:	53                   	push   %ebx
  801283:	83 ec 14             	sub    $0x14,%esp
  801286:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801289:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80128c:	50                   	push   %eax
  80128d:	53                   	push   %ebx
  80128e:	e8 ac fc ff ff       	call   800f3f <fd_lookup>
  801293:	83 c4 08             	add    $0x8,%esp
  801296:	89 c2                	mov    %eax,%edx
  801298:	85 c0                	test   %eax,%eax
  80129a:	78 68                	js     801304 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80129c:	83 ec 08             	sub    $0x8,%esp
  80129f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a2:	50                   	push   %eax
  8012a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a6:	ff 30                	pushl  (%eax)
  8012a8:	e8 e8 fc ff ff       	call   800f95 <dev_lookup>
  8012ad:	83 c4 10             	add    $0x10,%esp
  8012b0:	85 c0                	test   %eax,%eax
  8012b2:	78 47                	js     8012fb <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012bb:	75 21                	jne    8012de <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012bd:	a1 20 60 80 00       	mov    0x806020,%eax
  8012c2:	8b 40 48             	mov    0x48(%eax),%eax
  8012c5:	83 ec 04             	sub    $0x4,%esp
  8012c8:	53                   	push   %ebx
  8012c9:	50                   	push   %eax
  8012ca:	68 2c 29 80 00       	push   $0x80292c
  8012cf:	e8 98 ef ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  8012d4:	83 c4 10             	add    $0x10,%esp
  8012d7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012dc:	eb 26                	jmp    801304 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012e1:	8b 52 0c             	mov    0xc(%edx),%edx
  8012e4:	85 d2                	test   %edx,%edx
  8012e6:	74 17                	je     8012ff <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012e8:	83 ec 04             	sub    $0x4,%esp
  8012eb:	ff 75 10             	pushl  0x10(%ebp)
  8012ee:	ff 75 0c             	pushl  0xc(%ebp)
  8012f1:	50                   	push   %eax
  8012f2:	ff d2                	call   *%edx
  8012f4:	89 c2                	mov    %eax,%edx
  8012f6:	83 c4 10             	add    $0x10,%esp
  8012f9:	eb 09                	jmp    801304 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012fb:	89 c2                	mov    %eax,%edx
  8012fd:	eb 05                	jmp    801304 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012ff:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801304:	89 d0                	mov    %edx,%eax
  801306:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801309:	c9                   	leave  
  80130a:	c3                   	ret    

0080130b <seek>:

int
seek(int fdnum, off_t offset)
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801311:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801314:	50                   	push   %eax
  801315:	ff 75 08             	pushl  0x8(%ebp)
  801318:	e8 22 fc ff ff       	call   800f3f <fd_lookup>
  80131d:	83 c4 08             	add    $0x8,%esp
  801320:	85 c0                	test   %eax,%eax
  801322:	78 0e                	js     801332 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801324:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801327:	8b 55 0c             	mov    0xc(%ebp),%edx
  80132a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80132d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801332:	c9                   	leave  
  801333:	c3                   	ret    

00801334 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	53                   	push   %ebx
  801338:	83 ec 14             	sub    $0x14,%esp
  80133b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80133e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801341:	50                   	push   %eax
  801342:	53                   	push   %ebx
  801343:	e8 f7 fb ff ff       	call   800f3f <fd_lookup>
  801348:	83 c4 08             	add    $0x8,%esp
  80134b:	89 c2                	mov    %eax,%edx
  80134d:	85 c0                	test   %eax,%eax
  80134f:	78 65                	js     8013b6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801351:	83 ec 08             	sub    $0x8,%esp
  801354:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801357:	50                   	push   %eax
  801358:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135b:	ff 30                	pushl  (%eax)
  80135d:	e8 33 fc ff ff       	call   800f95 <dev_lookup>
  801362:	83 c4 10             	add    $0x10,%esp
  801365:	85 c0                	test   %eax,%eax
  801367:	78 44                	js     8013ad <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801369:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801370:	75 21                	jne    801393 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801372:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801377:	8b 40 48             	mov    0x48(%eax),%eax
  80137a:	83 ec 04             	sub    $0x4,%esp
  80137d:	53                   	push   %ebx
  80137e:	50                   	push   %eax
  80137f:	68 ec 28 80 00       	push   $0x8028ec
  801384:	e8 e3 ee ff ff       	call   80026c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801391:	eb 23                	jmp    8013b6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801393:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801396:	8b 52 18             	mov    0x18(%edx),%edx
  801399:	85 d2                	test   %edx,%edx
  80139b:	74 14                	je     8013b1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80139d:	83 ec 08             	sub    $0x8,%esp
  8013a0:	ff 75 0c             	pushl  0xc(%ebp)
  8013a3:	50                   	push   %eax
  8013a4:	ff d2                	call   *%edx
  8013a6:	89 c2                	mov    %eax,%edx
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	eb 09                	jmp    8013b6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ad:	89 c2                	mov    %eax,%edx
  8013af:	eb 05                	jmp    8013b6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013b6:	89 d0                	mov    %edx,%eax
  8013b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013bb:	c9                   	leave  
  8013bc:	c3                   	ret    

008013bd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	53                   	push   %ebx
  8013c1:	83 ec 14             	sub    $0x14,%esp
  8013c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ca:	50                   	push   %eax
  8013cb:	ff 75 08             	pushl  0x8(%ebp)
  8013ce:	e8 6c fb ff ff       	call   800f3f <fd_lookup>
  8013d3:	83 c4 08             	add    $0x8,%esp
  8013d6:	89 c2                	mov    %eax,%edx
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	78 58                	js     801434 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013dc:	83 ec 08             	sub    $0x8,%esp
  8013df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e2:	50                   	push   %eax
  8013e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e6:	ff 30                	pushl  (%eax)
  8013e8:	e8 a8 fb ff ff       	call   800f95 <dev_lookup>
  8013ed:	83 c4 10             	add    $0x10,%esp
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	78 37                	js     80142b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013fb:	74 32                	je     80142f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013fd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801400:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801407:	00 00 00 
	stat->st_isdir = 0;
  80140a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801411:	00 00 00 
	stat->st_dev = dev;
  801414:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80141a:	83 ec 08             	sub    $0x8,%esp
  80141d:	53                   	push   %ebx
  80141e:	ff 75 f0             	pushl  -0x10(%ebp)
  801421:	ff 50 14             	call   *0x14(%eax)
  801424:	89 c2                	mov    %eax,%edx
  801426:	83 c4 10             	add    $0x10,%esp
  801429:	eb 09                	jmp    801434 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142b:	89 c2                	mov    %eax,%edx
  80142d:	eb 05                	jmp    801434 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80142f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801434:	89 d0                	mov    %edx,%eax
  801436:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801439:	c9                   	leave  
  80143a:	c3                   	ret    

0080143b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	56                   	push   %esi
  80143f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801440:	83 ec 08             	sub    $0x8,%esp
  801443:	6a 00                	push   $0x0
  801445:	ff 75 08             	pushl  0x8(%ebp)
  801448:	e8 0c 02 00 00       	call   801659 <open>
  80144d:	89 c3                	mov    %eax,%ebx
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	85 c0                	test   %eax,%eax
  801454:	78 1b                	js     801471 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801456:	83 ec 08             	sub    $0x8,%esp
  801459:	ff 75 0c             	pushl  0xc(%ebp)
  80145c:	50                   	push   %eax
  80145d:	e8 5b ff ff ff       	call   8013bd <fstat>
  801462:	89 c6                	mov    %eax,%esi
	close(fd);
  801464:	89 1c 24             	mov    %ebx,(%esp)
  801467:	e8 fd fb ff ff       	call   801069 <close>
	return r;
  80146c:	83 c4 10             	add    $0x10,%esp
  80146f:	89 f0                	mov    %esi,%eax
}
  801471:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801474:	5b                   	pop    %ebx
  801475:	5e                   	pop    %esi
  801476:	5d                   	pop    %ebp
  801477:	c3                   	ret    

00801478 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801478:	55                   	push   %ebp
  801479:	89 e5                	mov    %esp,%ebp
  80147b:	56                   	push   %esi
  80147c:	53                   	push   %ebx
  80147d:	89 c6                	mov    %eax,%esi
  80147f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801481:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801488:	75 12                	jne    80149c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80148a:	83 ec 0c             	sub    $0xc,%esp
  80148d:	6a 01                	push   $0x1
  80148f:	e8 7c 0d 00 00       	call   802210 <ipc_find_env>
  801494:	a3 00 40 80 00       	mov    %eax,0x804000
  801499:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80149c:	6a 07                	push   $0x7
  80149e:	68 00 70 80 00       	push   $0x807000
  8014a3:	56                   	push   %esi
  8014a4:	ff 35 00 40 80 00    	pushl  0x804000
  8014aa:	e8 0d 0d 00 00       	call   8021bc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014af:	83 c4 0c             	add    $0xc,%esp
  8014b2:	6a 00                	push   $0x0
  8014b4:	53                   	push   %ebx
  8014b5:	6a 00                	push   $0x0
  8014b7:	e8 97 0c 00 00       	call   802153 <ipc_recv>
}
  8014bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014bf:	5b                   	pop    %ebx
  8014c0:	5e                   	pop    %esi
  8014c1:	5d                   	pop    %ebp
  8014c2:	c3                   	ret    

008014c3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014c3:	55                   	push   %ebp
  8014c4:	89 e5                	mov    %esp,%ebp
  8014c6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8014cf:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  8014d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d7:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e1:	b8 02 00 00 00       	mov    $0x2,%eax
  8014e6:	e8 8d ff ff ff       	call   801478 <fsipc>
}
  8014eb:	c9                   	leave  
  8014ec:	c3                   	ret    

008014ed <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f9:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8014fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801503:	b8 06 00 00 00       	mov    $0x6,%eax
  801508:	e8 6b ff ff ff       	call   801478 <fsipc>
}
  80150d:	c9                   	leave  
  80150e:	c3                   	ret    

0080150f <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80150f:	55                   	push   %ebp
  801510:	89 e5                	mov    %esp,%ebp
  801512:	53                   	push   %ebx
  801513:	83 ec 04             	sub    $0x4,%esp
  801516:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801519:	8b 45 08             	mov    0x8(%ebp),%eax
  80151c:	8b 40 0c             	mov    0xc(%eax),%eax
  80151f:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801524:	ba 00 00 00 00       	mov    $0x0,%edx
  801529:	b8 05 00 00 00       	mov    $0x5,%eax
  80152e:	e8 45 ff ff ff       	call   801478 <fsipc>
  801533:	85 c0                	test   %eax,%eax
  801535:	78 2c                	js     801563 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801537:	83 ec 08             	sub    $0x8,%esp
  80153a:	68 00 70 80 00       	push   $0x807000
  80153f:	53                   	push   %ebx
  801540:	e8 ac f2 ff ff       	call   8007f1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801545:	a1 80 70 80 00       	mov    0x807080,%eax
  80154a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801550:	a1 84 70 80 00       	mov    0x807084,%eax
  801555:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801563:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801566:	c9                   	leave  
  801567:	c3                   	ret    

00801568 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801568:	55                   	push   %ebp
  801569:	89 e5                	mov    %esp,%ebp
  80156b:	53                   	push   %ebx
  80156c:	83 ec 08             	sub    $0x8,%esp
  80156f:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801572:	8b 55 08             	mov    0x8(%ebp),%edx
  801575:	8b 52 0c             	mov    0xc(%edx),%edx
  801578:	89 15 00 70 80 00    	mov    %edx,0x807000
  80157e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801583:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801588:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  80158b:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801591:	53                   	push   %ebx
  801592:	ff 75 0c             	pushl  0xc(%ebp)
  801595:	68 08 70 80 00       	push   $0x807008
  80159a:	e8 e4 f3 ff ff       	call   800983 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  80159f:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a4:	b8 04 00 00 00       	mov    $0x4,%eax
  8015a9:	e8 ca fe ff ff       	call   801478 <fsipc>
  8015ae:	83 c4 10             	add    $0x10,%esp
  8015b1:	85 c0                	test   %eax,%eax
  8015b3:	78 1d                	js     8015d2 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  8015b5:	39 d8                	cmp    %ebx,%eax
  8015b7:	76 19                	jbe    8015d2 <devfile_write+0x6a>
  8015b9:	68 60 29 80 00       	push   $0x802960
  8015be:	68 6c 29 80 00       	push   $0x80296c
  8015c3:	68 a5 00 00 00       	push   $0xa5
  8015c8:	68 81 29 80 00       	push   $0x802981
  8015cd:	e8 c1 eb ff ff       	call   800193 <_panic>
	return r;
}
  8015d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d5:	c9                   	leave  
  8015d6:	c3                   	ret    

008015d7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	56                   	push   %esi
  8015db:	53                   	push   %ebx
  8015dc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015df:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8015e5:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8015ea:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8015fa:	e8 79 fe ff ff       	call   801478 <fsipc>
  8015ff:	89 c3                	mov    %eax,%ebx
  801601:	85 c0                	test   %eax,%eax
  801603:	78 4b                	js     801650 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801605:	39 c6                	cmp    %eax,%esi
  801607:	73 16                	jae    80161f <devfile_read+0x48>
  801609:	68 8c 29 80 00       	push   $0x80298c
  80160e:	68 6c 29 80 00       	push   $0x80296c
  801613:	6a 7c                	push   $0x7c
  801615:	68 81 29 80 00       	push   $0x802981
  80161a:	e8 74 eb ff ff       	call   800193 <_panic>
	assert(r <= PGSIZE);
  80161f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801624:	7e 16                	jle    80163c <devfile_read+0x65>
  801626:	68 93 29 80 00       	push   $0x802993
  80162b:	68 6c 29 80 00       	push   $0x80296c
  801630:	6a 7d                	push   $0x7d
  801632:	68 81 29 80 00       	push   $0x802981
  801637:	e8 57 eb ff ff       	call   800193 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80163c:	83 ec 04             	sub    $0x4,%esp
  80163f:	50                   	push   %eax
  801640:	68 00 70 80 00       	push   $0x807000
  801645:	ff 75 0c             	pushl  0xc(%ebp)
  801648:	e8 36 f3 ff ff       	call   800983 <memmove>
	return r;
  80164d:	83 c4 10             	add    $0x10,%esp
}
  801650:	89 d8                	mov    %ebx,%eax
  801652:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801655:	5b                   	pop    %ebx
  801656:	5e                   	pop    %esi
  801657:	5d                   	pop    %ebp
  801658:	c3                   	ret    

00801659 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	53                   	push   %ebx
  80165d:	83 ec 20             	sub    $0x20,%esp
  801660:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801663:	53                   	push   %ebx
  801664:	e8 4f f1 ff ff       	call   8007b8 <strlen>
  801669:	83 c4 10             	add    $0x10,%esp
  80166c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801671:	7f 67                	jg     8016da <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801673:	83 ec 0c             	sub    $0xc,%esp
  801676:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801679:	50                   	push   %eax
  80167a:	e8 71 f8 ff ff       	call   800ef0 <fd_alloc>
  80167f:	83 c4 10             	add    $0x10,%esp
		return r;
  801682:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801684:	85 c0                	test   %eax,%eax
  801686:	78 57                	js     8016df <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801688:	83 ec 08             	sub    $0x8,%esp
  80168b:	53                   	push   %ebx
  80168c:	68 00 70 80 00       	push   $0x807000
  801691:	e8 5b f1 ff ff       	call   8007f1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801696:	8b 45 0c             	mov    0xc(%ebp),%eax
  801699:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80169e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8016a6:	e8 cd fd ff ff       	call   801478 <fsipc>
  8016ab:	89 c3                	mov    %eax,%ebx
  8016ad:	83 c4 10             	add    $0x10,%esp
  8016b0:	85 c0                	test   %eax,%eax
  8016b2:	79 14                	jns    8016c8 <open+0x6f>
		fd_close(fd, 0);
  8016b4:	83 ec 08             	sub    $0x8,%esp
  8016b7:	6a 00                	push   $0x0
  8016b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8016bc:	e8 27 f9 ff ff       	call   800fe8 <fd_close>
		return r;
  8016c1:	83 c4 10             	add    $0x10,%esp
  8016c4:	89 da                	mov    %ebx,%edx
  8016c6:	eb 17                	jmp    8016df <open+0x86>
	}

	return fd2num(fd);
  8016c8:	83 ec 0c             	sub    $0xc,%esp
  8016cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8016ce:	e8 f6 f7 ff ff       	call   800ec9 <fd2num>
  8016d3:	89 c2                	mov    %eax,%edx
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	eb 05                	jmp    8016df <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016da:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016df:	89 d0                	mov    %edx,%eax
  8016e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e4:	c9                   	leave  
  8016e5:	c3                   	ret    

008016e6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f1:	b8 08 00 00 00       	mov    $0x8,%eax
  8016f6:	e8 7d fd ff ff       	call   801478 <fsipc>
}
  8016fb:	c9                   	leave  
  8016fc:	c3                   	ret    

008016fd <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8016fd:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801701:	7e 37                	jle    80173a <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	53                   	push   %ebx
  801707:	83 ec 08             	sub    $0x8,%esp
  80170a:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80170c:	ff 70 04             	pushl  0x4(%eax)
  80170f:	8d 40 10             	lea    0x10(%eax),%eax
  801712:	50                   	push   %eax
  801713:	ff 33                	pushl  (%ebx)
  801715:	e8 65 fb ff ff       	call   80127f <write>
		if (result > 0)
  80171a:	83 c4 10             	add    $0x10,%esp
  80171d:	85 c0                	test   %eax,%eax
  80171f:	7e 03                	jle    801724 <writebuf+0x27>
			b->result += result;
  801721:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801724:	3b 43 04             	cmp    0x4(%ebx),%eax
  801727:	74 0d                	je     801736 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801729:	85 c0                	test   %eax,%eax
  80172b:	ba 00 00 00 00       	mov    $0x0,%edx
  801730:	0f 4f c2             	cmovg  %edx,%eax
  801733:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801736:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801739:	c9                   	leave  
  80173a:	f3 c3                	repz ret 

0080173c <putch>:

static void
putch(int ch, void *thunk)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	53                   	push   %ebx
  801740:	83 ec 04             	sub    $0x4,%esp
  801743:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801746:	8b 53 04             	mov    0x4(%ebx),%edx
  801749:	8d 42 01             	lea    0x1(%edx),%eax
  80174c:	89 43 04             	mov    %eax,0x4(%ebx)
  80174f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801752:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801756:	3d 00 01 00 00       	cmp    $0x100,%eax
  80175b:	75 0e                	jne    80176b <putch+0x2f>
		writebuf(b);
  80175d:	89 d8                	mov    %ebx,%eax
  80175f:	e8 99 ff ff ff       	call   8016fd <writebuf>
		b->idx = 0;
  801764:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80176b:	83 c4 04             	add    $0x4,%esp
  80176e:	5b                   	pop    %ebx
  80176f:	5d                   	pop    %ebp
  801770:	c3                   	ret    

00801771 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80177a:	8b 45 08             	mov    0x8(%ebp),%eax
  80177d:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801783:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80178a:	00 00 00 
	b.result = 0;
  80178d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801794:	00 00 00 
	b.error = 1;
  801797:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80179e:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8017a1:	ff 75 10             	pushl  0x10(%ebp)
  8017a4:	ff 75 0c             	pushl  0xc(%ebp)
  8017a7:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017ad:	50                   	push   %eax
  8017ae:	68 3c 17 80 00       	push   $0x80173c
  8017b3:	e8 eb eb ff ff       	call   8003a3 <vprintfmt>
	if (b.idx > 0)
  8017b8:	83 c4 10             	add    $0x10,%esp
  8017bb:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8017c2:	7e 0b                	jle    8017cf <vfprintf+0x5e>
		writebuf(&b);
  8017c4:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017ca:	e8 2e ff ff ff       	call   8016fd <writebuf>

	return (b.result ? b.result : b.error);
  8017cf:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8017d5:	85 c0                	test   %eax,%eax
  8017d7:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8017de:	c9                   	leave  
  8017df:	c3                   	ret    

008017e0 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017e6:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8017e9:	50                   	push   %eax
  8017ea:	ff 75 0c             	pushl  0xc(%ebp)
  8017ed:	ff 75 08             	pushl  0x8(%ebp)
  8017f0:	e8 7c ff ff ff       	call   801771 <vfprintf>
	va_end(ap);

	return cnt;
}
  8017f5:	c9                   	leave  
  8017f6:	c3                   	ret    

008017f7 <printf>:

int
printf(const char *fmt, ...)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017fd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801800:	50                   	push   %eax
  801801:	ff 75 08             	pushl  0x8(%ebp)
  801804:	6a 01                	push   $0x1
  801806:	e8 66 ff ff ff       	call   801771 <vfprintf>
	va_end(ap);

	return cnt;
}
  80180b:	c9                   	leave  
  80180c:	c3                   	ret    

0080180d <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801813:	68 9f 29 80 00       	push   $0x80299f
  801818:	ff 75 0c             	pushl  0xc(%ebp)
  80181b:	e8 d1 ef ff ff       	call   8007f1 <strcpy>
	return 0;
}
  801820:	b8 00 00 00 00       	mov    $0x0,%eax
  801825:	c9                   	leave  
  801826:	c3                   	ret    

00801827 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	53                   	push   %ebx
  80182b:	83 ec 10             	sub    $0x10,%esp
  80182e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801831:	53                   	push   %ebx
  801832:	e8 12 0a 00 00       	call   802249 <pageref>
  801837:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80183a:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80183f:	83 f8 01             	cmp    $0x1,%eax
  801842:	75 10                	jne    801854 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801844:	83 ec 0c             	sub    $0xc,%esp
  801847:	ff 73 0c             	pushl  0xc(%ebx)
  80184a:	e8 c0 02 00 00       	call   801b0f <nsipc_close>
  80184f:	89 c2                	mov    %eax,%edx
  801851:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801854:	89 d0                	mov    %edx,%eax
  801856:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801859:	c9                   	leave  
  80185a:	c3                   	ret    

0080185b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80185b:	55                   	push   %ebp
  80185c:	89 e5                	mov    %esp,%ebp
  80185e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801861:	6a 00                	push   $0x0
  801863:	ff 75 10             	pushl  0x10(%ebp)
  801866:	ff 75 0c             	pushl  0xc(%ebp)
  801869:	8b 45 08             	mov    0x8(%ebp),%eax
  80186c:	ff 70 0c             	pushl  0xc(%eax)
  80186f:	e8 78 03 00 00       	call   801bec <nsipc_send>
}
  801874:	c9                   	leave  
  801875:	c3                   	ret    

00801876 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80187c:	6a 00                	push   $0x0
  80187e:	ff 75 10             	pushl  0x10(%ebp)
  801881:	ff 75 0c             	pushl  0xc(%ebp)
  801884:	8b 45 08             	mov    0x8(%ebp),%eax
  801887:	ff 70 0c             	pushl  0xc(%eax)
  80188a:	e8 f1 02 00 00       	call   801b80 <nsipc_recv>
}
  80188f:	c9                   	leave  
  801890:	c3                   	ret    

00801891 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801891:	55                   	push   %ebp
  801892:	89 e5                	mov    %esp,%ebp
  801894:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801897:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80189a:	52                   	push   %edx
  80189b:	50                   	push   %eax
  80189c:	e8 9e f6 ff ff       	call   800f3f <fd_lookup>
  8018a1:	83 c4 10             	add    $0x10,%esp
  8018a4:	85 c0                	test   %eax,%eax
  8018a6:	78 17                	js     8018bf <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8018a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ab:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8018b1:	39 08                	cmp    %ecx,(%eax)
  8018b3:	75 05                	jne    8018ba <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8018b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b8:	eb 05                	jmp    8018bf <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8018ba:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8018bf:	c9                   	leave  
  8018c0:	c3                   	ret    

008018c1 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8018c1:	55                   	push   %ebp
  8018c2:	89 e5                	mov    %esp,%ebp
  8018c4:	56                   	push   %esi
  8018c5:	53                   	push   %ebx
  8018c6:	83 ec 1c             	sub    $0x1c,%esp
  8018c9:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8018cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ce:	50                   	push   %eax
  8018cf:	e8 1c f6 ff ff       	call   800ef0 <fd_alloc>
  8018d4:	89 c3                	mov    %eax,%ebx
  8018d6:	83 c4 10             	add    $0x10,%esp
  8018d9:	85 c0                	test   %eax,%eax
  8018db:	78 1b                	js     8018f8 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8018dd:	83 ec 04             	sub    $0x4,%esp
  8018e0:	68 07 04 00 00       	push   $0x407
  8018e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e8:	6a 00                	push   $0x0
  8018ea:	e8 05 f3 ff ff       	call   800bf4 <sys_page_alloc>
  8018ef:	89 c3                	mov    %eax,%ebx
  8018f1:	83 c4 10             	add    $0x10,%esp
  8018f4:	85 c0                	test   %eax,%eax
  8018f6:	79 10                	jns    801908 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8018f8:	83 ec 0c             	sub    $0xc,%esp
  8018fb:	56                   	push   %esi
  8018fc:	e8 0e 02 00 00       	call   801b0f <nsipc_close>
		return r;
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	89 d8                	mov    %ebx,%eax
  801906:	eb 24                	jmp    80192c <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801908:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80190e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801911:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801913:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801916:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80191d:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801920:	83 ec 0c             	sub    $0xc,%esp
  801923:	50                   	push   %eax
  801924:	e8 a0 f5 ff ff       	call   800ec9 <fd2num>
  801929:	83 c4 10             	add    $0x10,%esp
}
  80192c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80192f:	5b                   	pop    %ebx
  801930:	5e                   	pop    %esi
  801931:	5d                   	pop    %ebp
  801932:	c3                   	ret    

00801933 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801933:	55                   	push   %ebp
  801934:	89 e5                	mov    %esp,%ebp
  801936:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801939:	8b 45 08             	mov    0x8(%ebp),%eax
  80193c:	e8 50 ff ff ff       	call   801891 <fd2sockid>
		return r;
  801941:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801943:	85 c0                	test   %eax,%eax
  801945:	78 1f                	js     801966 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801947:	83 ec 04             	sub    $0x4,%esp
  80194a:	ff 75 10             	pushl  0x10(%ebp)
  80194d:	ff 75 0c             	pushl  0xc(%ebp)
  801950:	50                   	push   %eax
  801951:	e8 12 01 00 00       	call   801a68 <nsipc_accept>
  801956:	83 c4 10             	add    $0x10,%esp
		return r;
  801959:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80195b:	85 c0                	test   %eax,%eax
  80195d:	78 07                	js     801966 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80195f:	e8 5d ff ff ff       	call   8018c1 <alloc_sockfd>
  801964:	89 c1                	mov    %eax,%ecx
}
  801966:	89 c8                	mov    %ecx,%eax
  801968:	c9                   	leave  
  801969:	c3                   	ret    

0080196a <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80196a:	55                   	push   %ebp
  80196b:	89 e5                	mov    %esp,%ebp
  80196d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801970:	8b 45 08             	mov    0x8(%ebp),%eax
  801973:	e8 19 ff ff ff       	call   801891 <fd2sockid>
  801978:	85 c0                	test   %eax,%eax
  80197a:	78 12                	js     80198e <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80197c:	83 ec 04             	sub    $0x4,%esp
  80197f:	ff 75 10             	pushl  0x10(%ebp)
  801982:	ff 75 0c             	pushl  0xc(%ebp)
  801985:	50                   	push   %eax
  801986:	e8 2d 01 00 00       	call   801ab8 <nsipc_bind>
  80198b:	83 c4 10             	add    $0x10,%esp
}
  80198e:	c9                   	leave  
  80198f:	c3                   	ret    

00801990 <shutdown>:

int
shutdown(int s, int how)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801996:	8b 45 08             	mov    0x8(%ebp),%eax
  801999:	e8 f3 fe ff ff       	call   801891 <fd2sockid>
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	78 0f                	js     8019b1 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8019a2:	83 ec 08             	sub    $0x8,%esp
  8019a5:	ff 75 0c             	pushl  0xc(%ebp)
  8019a8:	50                   	push   %eax
  8019a9:	e8 3f 01 00 00       	call   801aed <nsipc_shutdown>
  8019ae:	83 c4 10             	add    $0x10,%esp
}
  8019b1:	c9                   	leave  
  8019b2:	c3                   	ret    

008019b3 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019b3:	55                   	push   %ebp
  8019b4:	89 e5                	mov    %esp,%ebp
  8019b6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bc:	e8 d0 fe ff ff       	call   801891 <fd2sockid>
  8019c1:	85 c0                	test   %eax,%eax
  8019c3:	78 12                	js     8019d7 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8019c5:	83 ec 04             	sub    $0x4,%esp
  8019c8:	ff 75 10             	pushl  0x10(%ebp)
  8019cb:	ff 75 0c             	pushl  0xc(%ebp)
  8019ce:	50                   	push   %eax
  8019cf:	e8 55 01 00 00       	call   801b29 <nsipc_connect>
  8019d4:	83 c4 10             	add    $0x10,%esp
}
  8019d7:	c9                   	leave  
  8019d8:	c3                   	ret    

008019d9 <listen>:

int
listen(int s, int backlog)
{
  8019d9:	55                   	push   %ebp
  8019da:	89 e5                	mov    %esp,%ebp
  8019dc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019df:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e2:	e8 aa fe ff ff       	call   801891 <fd2sockid>
  8019e7:	85 c0                	test   %eax,%eax
  8019e9:	78 0f                	js     8019fa <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8019eb:	83 ec 08             	sub    $0x8,%esp
  8019ee:	ff 75 0c             	pushl  0xc(%ebp)
  8019f1:	50                   	push   %eax
  8019f2:	e8 67 01 00 00       	call   801b5e <nsipc_listen>
  8019f7:	83 c4 10             	add    $0x10,%esp
}
  8019fa:	c9                   	leave  
  8019fb:	c3                   	ret    

008019fc <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a02:	ff 75 10             	pushl  0x10(%ebp)
  801a05:	ff 75 0c             	pushl  0xc(%ebp)
  801a08:	ff 75 08             	pushl  0x8(%ebp)
  801a0b:	e8 3a 02 00 00       	call   801c4a <nsipc_socket>
  801a10:	83 c4 10             	add    $0x10,%esp
  801a13:	85 c0                	test   %eax,%eax
  801a15:	78 05                	js     801a1c <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a17:	e8 a5 fe ff ff       	call   8018c1 <alloc_sockfd>
}
  801a1c:	c9                   	leave  
  801a1d:	c3                   	ret    

00801a1e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	53                   	push   %ebx
  801a22:	83 ec 04             	sub    $0x4,%esp
  801a25:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a27:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801a2e:	75 12                	jne    801a42 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a30:	83 ec 0c             	sub    $0xc,%esp
  801a33:	6a 02                	push   $0x2
  801a35:	e8 d6 07 00 00       	call   802210 <ipc_find_env>
  801a3a:	a3 04 40 80 00       	mov    %eax,0x804004
  801a3f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a42:	6a 07                	push   $0x7
  801a44:	68 00 80 80 00       	push   $0x808000
  801a49:	53                   	push   %ebx
  801a4a:	ff 35 04 40 80 00    	pushl  0x804004
  801a50:	e8 67 07 00 00       	call   8021bc <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a55:	83 c4 0c             	add    $0xc,%esp
  801a58:	6a 00                	push   $0x0
  801a5a:	6a 00                	push   $0x0
  801a5c:	6a 00                	push   $0x0
  801a5e:	e8 f0 06 00 00       	call   802153 <ipc_recv>
}
  801a63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a66:	c9                   	leave  
  801a67:	c3                   	ret    

00801a68 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a68:	55                   	push   %ebp
  801a69:	89 e5                	mov    %esp,%ebp
  801a6b:	56                   	push   %esi
  801a6c:	53                   	push   %ebx
  801a6d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801a70:	8b 45 08             	mov    0x8(%ebp),%eax
  801a73:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801a78:	8b 06                	mov    (%esi),%eax
  801a7a:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801a7f:	b8 01 00 00 00       	mov    $0x1,%eax
  801a84:	e8 95 ff ff ff       	call   801a1e <nsipc>
  801a89:	89 c3                	mov    %eax,%ebx
  801a8b:	85 c0                	test   %eax,%eax
  801a8d:	78 20                	js     801aaf <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801a8f:	83 ec 04             	sub    $0x4,%esp
  801a92:	ff 35 10 80 80 00    	pushl  0x808010
  801a98:	68 00 80 80 00       	push   $0x808000
  801a9d:	ff 75 0c             	pushl  0xc(%ebp)
  801aa0:	e8 de ee ff ff       	call   800983 <memmove>
		*addrlen = ret->ret_addrlen;
  801aa5:	a1 10 80 80 00       	mov    0x808010,%eax
  801aaa:	89 06                	mov    %eax,(%esi)
  801aac:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801aaf:	89 d8                	mov    %ebx,%eax
  801ab1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab4:	5b                   	pop    %ebx
  801ab5:	5e                   	pop    %esi
  801ab6:	5d                   	pop    %ebp
  801ab7:	c3                   	ret    

00801ab8 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ab8:	55                   	push   %ebp
  801ab9:	89 e5                	mov    %esp,%ebp
  801abb:	53                   	push   %ebx
  801abc:	83 ec 08             	sub    $0x8,%esp
  801abf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac5:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801aca:	53                   	push   %ebx
  801acb:	ff 75 0c             	pushl  0xc(%ebp)
  801ace:	68 04 80 80 00       	push   $0x808004
  801ad3:	e8 ab ee ff ff       	call   800983 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ad8:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  801ade:	b8 02 00 00 00       	mov    $0x2,%eax
  801ae3:	e8 36 ff ff ff       	call   801a1e <nsipc>
}
  801ae8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aeb:	c9                   	leave  
  801aec:	c3                   	ret    

00801aed <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801aed:	55                   	push   %ebp
  801aee:	89 e5                	mov    %esp,%ebp
  801af0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801af3:	8b 45 08             	mov    0x8(%ebp),%eax
  801af6:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  801afb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afe:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  801b03:	b8 03 00 00 00       	mov    $0x3,%eax
  801b08:	e8 11 ff ff ff       	call   801a1e <nsipc>
}
  801b0d:	c9                   	leave  
  801b0e:	c3                   	ret    

00801b0f <nsipc_close>:

int
nsipc_close(int s)
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b15:	8b 45 08             	mov    0x8(%ebp),%eax
  801b18:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  801b1d:	b8 04 00 00 00       	mov    $0x4,%eax
  801b22:	e8 f7 fe ff ff       	call   801a1e <nsipc>
}
  801b27:	c9                   	leave  
  801b28:	c3                   	ret    

00801b29 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	53                   	push   %ebx
  801b2d:	83 ec 08             	sub    $0x8,%esp
  801b30:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b33:	8b 45 08             	mov    0x8(%ebp),%eax
  801b36:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b3b:	53                   	push   %ebx
  801b3c:	ff 75 0c             	pushl  0xc(%ebp)
  801b3f:	68 04 80 80 00       	push   $0x808004
  801b44:	e8 3a ee ff ff       	call   800983 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801b49:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  801b4f:	b8 05 00 00 00       	mov    $0x5,%eax
  801b54:	e8 c5 fe ff ff       	call   801a1e <nsipc>
}
  801b59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b5c:	c9                   	leave  
  801b5d:	c3                   	ret    

00801b5e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801b64:	8b 45 08             	mov    0x8(%ebp),%eax
  801b67:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  801b6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6f:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  801b74:	b8 06 00 00 00       	mov    $0x6,%eax
  801b79:	e8 a0 fe ff ff       	call   801a1e <nsipc>
}
  801b7e:	c9                   	leave  
  801b7f:	c3                   	ret    

00801b80 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	56                   	push   %esi
  801b84:	53                   	push   %ebx
  801b85:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801b88:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8b:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  801b90:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  801b96:	8b 45 14             	mov    0x14(%ebp),%eax
  801b99:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801b9e:	b8 07 00 00 00       	mov    $0x7,%eax
  801ba3:	e8 76 fe ff ff       	call   801a1e <nsipc>
  801ba8:	89 c3                	mov    %eax,%ebx
  801baa:	85 c0                	test   %eax,%eax
  801bac:	78 35                	js     801be3 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801bae:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801bb3:	7f 04                	jg     801bb9 <nsipc_recv+0x39>
  801bb5:	39 c6                	cmp    %eax,%esi
  801bb7:	7d 16                	jge    801bcf <nsipc_recv+0x4f>
  801bb9:	68 ab 29 80 00       	push   $0x8029ab
  801bbe:	68 6c 29 80 00       	push   $0x80296c
  801bc3:	6a 62                	push   $0x62
  801bc5:	68 c0 29 80 00       	push   $0x8029c0
  801bca:	e8 c4 e5 ff ff       	call   800193 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801bcf:	83 ec 04             	sub    $0x4,%esp
  801bd2:	50                   	push   %eax
  801bd3:	68 00 80 80 00       	push   $0x808000
  801bd8:	ff 75 0c             	pushl  0xc(%ebp)
  801bdb:	e8 a3 ed ff ff       	call   800983 <memmove>
  801be0:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801be3:	89 d8                	mov    %ebx,%eax
  801be5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801be8:	5b                   	pop    %ebx
  801be9:	5e                   	pop    %esi
  801bea:	5d                   	pop    %ebp
  801beb:	c3                   	ret    

00801bec <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801bec:	55                   	push   %ebp
  801bed:	89 e5                	mov    %esp,%ebp
  801bef:	53                   	push   %ebx
  801bf0:	83 ec 04             	sub    $0x4,%esp
  801bf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf9:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  801bfe:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c04:	7e 16                	jle    801c1c <nsipc_send+0x30>
  801c06:	68 cc 29 80 00       	push   $0x8029cc
  801c0b:	68 6c 29 80 00       	push   $0x80296c
  801c10:	6a 6d                	push   $0x6d
  801c12:	68 c0 29 80 00       	push   $0x8029c0
  801c17:	e8 77 e5 ff ff       	call   800193 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c1c:	83 ec 04             	sub    $0x4,%esp
  801c1f:	53                   	push   %ebx
  801c20:	ff 75 0c             	pushl  0xc(%ebp)
  801c23:	68 0c 80 80 00       	push   $0x80800c
  801c28:	e8 56 ed ff ff       	call   800983 <memmove>
	nsipcbuf.send.req_size = size;
  801c2d:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  801c33:	8b 45 14             	mov    0x14(%ebp),%eax
  801c36:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  801c3b:	b8 08 00 00 00       	mov    $0x8,%eax
  801c40:	e8 d9 fd ff ff       	call   801a1e <nsipc>
}
  801c45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c48:	c9                   	leave  
  801c49:	c3                   	ret    

00801c4a <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c50:	8b 45 08             	mov    0x8(%ebp),%eax
  801c53:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  801c58:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c5b:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  801c60:	8b 45 10             	mov    0x10(%ebp),%eax
  801c63:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  801c68:	b8 09 00 00 00       	mov    $0x9,%eax
  801c6d:	e8 ac fd ff ff       	call   801a1e <nsipc>
}
  801c72:	c9                   	leave  
  801c73:	c3                   	ret    

00801c74 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	56                   	push   %esi
  801c78:	53                   	push   %ebx
  801c79:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c7c:	83 ec 0c             	sub    $0xc,%esp
  801c7f:	ff 75 08             	pushl  0x8(%ebp)
  801c82:	e8 52 f2 ff ff       	call   800ed9 <fd2data>
  801c87:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c89:	83 c4 08             	add    $0x8,%esp
  801c8c:	68 d8 29 80 00       	push   $0x8029d8
  801c91:	53                   	push   %ebx
  801c92:	e8 5a eb ff ff       	call   8007f1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c97:	8b 46 04             	mov    0x4(%esi),%eax
  801c9a:	2b 06                	sub    (%esi),%eax
  801c9c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ca2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ca9:	00 00 00 
	stat->st_dev = &devpipe;
  801cac:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801cb3:	30 80 00 
	return 0;
}
  801cb6:	b8 00 00 00 00       	mov    $0x0,%eax
  801cbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cbe:	5b                   	pop    %ebx
  801cbf:	5e                   	pop    %esi
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    

00801cc2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	53                   	push   %ebx
  801cc6:	83 ec 0c             	sub    $0xc,%esp
  801cc9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ccc:	53                   	push   %ebx
  801ccd:	6a 00                	push   $0x0
  801ccf:	e8 a5 ef ff ff       	call   800c79 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cd4:	89 1c 24             	mov    %ebx,(%esp)
  801cd7:	e8 fd f1 ff ff       	call   800ed9 <fd2data>
  801cdc:	83 c4 08             	add    $0x8,%esp
  801cdf:	50                   	push   %eax
  801ce0:	6a 00                	push   $0x0
  801ce2:	e8 92 ef ff ff       	call   800c79 <sys_page_unmap>
}
  801ce7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cea:	c9                   	leave  
  801ceb:	c3                   	ret    

00801cec <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	57                   	push   %edi
  801cf0:	56                   	push   %esi
  801cf1:	53                   	push   %ebx
  801cf2:	83 ec 1c             	sub    $0x1c,%esp
  801cf5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801cf8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cfa:	a1 20 60 80 00       	mov    0x806020,%eax
  801cff:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d02:	83 ec 0c             	sub    $0xc,%esp
  801d05:	ff 75 e0             	pushl  -0x20(%ebp)
  801d08:	e8 3c 05 00 00       	call   802249 <pageref>
  801d0d:	89 c3                	mov    %eax,%ebx
  801d0f:	89 3c 24             	mov    %edi,(%esp)
  801d12:	e8 32 05 00 00       	call   802249 <pageref>
  801d17:	83 c4 10             	add    $0x10,%esp
  801d1a:	39 c3                	cmp    %eax,%ebx
  801d1c:	0f 94 c1             	sete   %cl
  801d1f:	0f b6 c9             	movzbl %cl,%ecx
  801d22:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d25:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801d2b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d2e:	39 ce                	cmp    %ecx,%esi
  801d30:	74 1b                	je     801d4d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d32:	39 c3                	cmp    %eax,%ebx
  801d34:	75 c4                	jne    801cfa <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d36:	8b 42 58             	mov    0x58(%edx),%eax
  801d39:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d3c:	50                   	push   %eax
  801d3d:	56                   	push   %esi
  801d3e:	68 df 29 80 00       	push   $0x8029df
  801d43:	e8 24 e5 ff ff       	call   80026c <cprintf>
  801d48:	83 c4 10             	add    $0x10,%esp
  801d4b:	eb ad                	jmp    801cfa <_pipeisclosed+0xe>
	}
}
  801d4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d53:	5b                   	pop    %ebx
  801d54:	5e                   	pop    %esi
  801d55:	5f                   	pop    %edi
  801d56:	5d                   	pop    %ebp
  801d57:	c3                   	ret    

00801d58 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	57                   	push   %edi
  801d5c:	56                   	push   %esi
  801d5d:	53                   	push   %ebx
  801d5e:	83 ec 28             	sub    $0x28,%esp
  801d61:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d64:	56                   	push   %esi
  801d65:	e8 6f f1 ff ff       	call   800ed9 <fd2data>
  801d6a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d6c:	83 c4 10             	add    $0x10,%esp
  801d6f:	bf 00 00 00 00       	mov    $0x0,%edi
  801d74:	eb 4b                	jmp    801dc1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d76:	89 da                	mov    %ebx,%edx
  801d78:	89 f0                	mov    %esi,%eax
  801d7a:	e8 6d ff ff ff       	call   801cec <_pipeisclosed>
  801d7f:	85 c0                	test   %eax,%eax
  801d81:	75 48                	jne    801dcb <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d83:	e8 4d ee ff ff       	call   800bd5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d88:	8b 43 04             	mov    0x4(%ebx),%eax
  801d8b:	8b 0b                	mov    (%ebx),%ecx
  801d8d:	8d 51 20             	lea    0x20(%ecx),%edx
  801d90:	39 d0                	cmp    %edx,%eax
  801d92:	73 e2                	jae    801d76 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d97:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d9b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d9e:	89 c2                	mov    %eax,%edx
  801da0:	c1 fa 1f             	sar    $0x1f,%edx
  801da3:	89 d1                	mov    %edx,%ecx
  801da5:	c1 e9 1b             	shr    $0x1b,%ecx
  801da8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801dab:	83 e2 1f             	and    $0x1f,%edx
  801dae:	29 ca                	sub    %ecx,%edx
  801db0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801db4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801db8:	83 c0 01             	add    $0x1,%eax
  801dbb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dbe:	83 c7 01             	add    $0x1,%edi
  801dc1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801dc4:	75 c2                	jne    801d88 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801dc6:	8b 45 10             	mov    0x10(%ebp),%eax
  801dc9:	eb 05                	jmp    801dd0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dcb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801dd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd3:	5b                   	pop    %ebx
  801dd4:	5e                   	pop    %esi
  801dd5:	5f                   	pop    %edi
  801dd6:	5d                   	pop    %ebp
  801dd7:	c3                   	ret    

00801dd8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dd8:	55                   	push   %ebp
  801dd9:	89 e5                	mov    %esp,%ebp
  801ddb:	57                   	push   %edi
  801ddc:	56                   	push   %esi
  801ddd:	53                   	push   %ebx
  801dde:	83 ec 18             	sub    $0x18,%esp
  801de1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801de4:	57                   	push   %edi
  801de5:	e8 ef f0 ff ff       	call   800ed9 <fd2data>
  801dea:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dec:	83 c4 10             	add    $0x10,%esp
  801def:	bb 00 00 00 00       	mov    $0x0,%ebx
  801df4:	eb 3d                	jmp    801e33 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801df6:	85 db                	test   %ebx,%ebx
  801df8:	74 04                	je     801dfe <devpipe_read+0x26>
				return i;
  801dfa:	89 d8                	mov    %ebx,%eax
  801dfc:	eb 44                	jmp    801e42 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801dfe:	89 f2                	mov    %esi,%edx
  801e00:	89 f8                	mov    %edi,%eax
  801e02:	e8 e5 fe ff ff       	call   801cec <_pipeisclosed>
  801e07:	85 c0                	test   %eax,%eax
  801e09:	75 32                	jne    801e3d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e0b:	e8 c5 ed ff ff       	call   800bd5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e10:	8b 06                	mov    (%esi),%eax
  801e12:	3b 46 04             	cmp    0x4(%esi),%eax
  801e15:	74 df                	je     801df6 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e17:	99                   	cltd   
  801e18:	c1 ea 1b             	shr    $0x1b,%edx
  801e1b:	01 d0                	add    %edx,%eax
  801e1d:	83 e0 1f             	and    $0x1f,%eax
  801e20:	29 d0                	sub    %edx,%eax
  801e22:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801e27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e2a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801e2d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e30:	83 c3 01             	add    $0x1,%ebx
  801e33:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e36:	75 d8                	jne    801e10 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e38:	8b 45 10             	mov    0x10(%ebp),%eax
  801e3b:	eb 05                	jmp    801e42 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e3d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e45:	5b                   	pop    %ebx
  801e46:	5e                   	pop    %esi
  801e47:	5f                   	pop    %edi
  801e48:	5d                   	pop    %ebp
  801e49:	c3                   	ret    

00801e4a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e4a:	55                   	push   %ebp
  801e4b:	89 e5                	mov    %esp,%ebp
  801e4d:	56                   	push   %esi
  801e4e:	53                   	push   %ebx
  801e4f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e55:	50                   	push   %eax
  801e56:	e8 95 f0 ff ff       	call   800ef0 <fd_alloc>
  801e5b:	83 c4 10             	add    $0x10,%esp
  801e5e:	89 c2                	mov    %eax,%edx
  801e60:	85 c0                	test   %eax,%eax
  801e62:	0f 88 2c 01 00 00    	js     801f94 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e68:	83 ec 04             	sub    $0x4,%esp
  801e6b:	68 07 04 00 00       	push   $0x407
  801e70:	ff 75 f4             	pushl  -0xc(%ebp)
  801e73:	6a 00                	push   $0x0
  801e75:	e8 7a ed ff ff       	call   800bf4 <sys_page_alloc>
  801e7a:	83 c4 10             	add    $0x10,%esp
  801e7d:	89 c2                	mov    %eax,%edx
  801e7f:	85 c0                	test   %eax,%eax
  801e81:	0f 88 0d 01 00 00    	js     801f94 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e87:	83 ec 0c             	sub    $0xc,%esp
  801e8a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e8d:	50                   	push   %eax
  801e8e:	e8 5d f0 ff ff       	call   800ef0 <fd_alloc>
  801e93:	89 c3                	mov    %eax,%ebx
  801e95:	83 c4 10             	add    $0x10,%esp
  801e98:	85 c0                	test   %eax,%eax
  801e9a:	0f 88 e2 00 00 00    	js     801f82 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea0:	83 ec 04             	sub    $0x4,%esp
  801ea3:	68 07 04 00 00       	push   $0x407
  801ea8:	ff 75 f0             	pushl  -0x10(%ebp)
  801eab:	6a 00                	push   $0x0
  801ead:	e8 42 ed ff ff       	call   800bf4 <sys_page_alloc>
  801eb2:	89 c3                	mov    %eax,%ebx
  801eb4:	83 c4 10             	add    $0x10,%esp
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	0f 88 c3 00 00 00    	js     801f82 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ebf:	83 ec 0c             	sub    $0xc,%esp
  801ec2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec5:	e8 0f f0 ff ff       	call   800ed9 <fd2data>
  801eca:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ecc:	83 c4 0c             	add    $0xc,%esp
  801ecf:	68 07 04 00 00       	push   $0x407
  801ed4:	50                   	push   %eax
  801ed5:	6a 00                	push   $0x0
  801ed7:	e8 18 ed ff ff       	call   800bf4 <sys_page_alloc>
  801edc:	89 c3                	mov    %eax,%ebx
  801ede:	83 c4 10             	add    $0x10,%esp
  801ee1:	85 c0                	test   %eax,%eax
  801ee3:	0f 88 89 00 00 00    	js     801f72 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ee9:	83 ec 0c             	sub    $0xc,%esp
  801eec:	ff 75 f0             	pushl  -0x10(%ebp)
  801eef:	e8 e5 ef ff ff       	call   800ed9 <fd2data>
  801ef4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801efb:	50                   	push   %eax
  801efc:	6a 00                	push   $0x0
  801efe:	56                   	push   %esi
  801eff:	6a 00                	push   $0x0
  801f01:	e8 31 ed ff ff       	call   800c37 <sys_page_map>
  801f06:	89 c3                	mov    %eax,%ebx
  801f08:	83 c4 20             	add    $0x20,%esp
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	78 55                	js     801f64 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f0f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f18:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f24:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f2d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f32:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f39:	83 ec 0c             	sub    $0xc,%esp
  801f3c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f3f:	e8 85 ef ff ff       	call   800ec9 <fd2num>
  801f44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f47:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f49:	83 c4 04             	add    $0x4,%esp
  801f4c:	ff 75 f0             	pushl  -0x10(%ebp)
  801f4f:	e8 75 ef ff ff       	call   800ec9 <fd2num>
  801f54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f57:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f5a:	83 c4 10             	add    $0x10,%esp
  801f5d:	ba 00 00 00 00       	mov    $0x0,%edx
  801f62:	eb 30                	jmp    801f94 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801f64:	83 ec 08             	sub    $0x8,%esp
  801f67:	56                   	push   %esi
  801f68:	6a 00                	push   $0x0
  801f6a:	e8 0a ed ff ff       	call   800c79 <sys_page_unmap>
  801f6f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f72:	83 ec 08             	sub    $0x8,%esp
  801f75:	ff 75 f0             	pushl  -0x10(%ebp)
  801f78:	6a 00                	push   $0x0
  801f7a:	e8 fa ec ff ff       	call   800c79 <sys_page_unmap>
  801f7f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f82:	83 ec 08             	sub    $0x8,%esp
  801f85:	ff 75 f4             	pushl  -0xc(%ebp)
  801f88:	6a 00                	push   $0x0
  801f8a:	e8 ea ec ff ff       	call   800c79 <sys_page_unmap>
  801f8f:	83 c4 10             	add    $0x10,%esp
  801f92:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f94:	89 d0                	mov    %edx,%eax
  801f96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f99:	5b                   	pop    %ebx
  801f9a:	5e                   	pop    %esi
  801f9b:	5d                   	pop    %ebp
  801f9c:	c3                   	ret    

00801f9d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f9d:	55                   	push   %ebp
  801f9e:	89 e5                	mov    %esp,%ebp
  801fa0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fa3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa6:	50                   	push   %eax
  801fa7:	ff 75 08             	pushl  0x8(%ebp)
  801faa:	e8 90 ef ff ff       	call   800f3f <fd_lookup>
  801faf:	83 c4 10             	add    $0x10,%esp
  801fb2:	85 c0                	test   %eax,%eax
  801fb4:	78 18                	js     801fce <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fb6:	83 ec 0c             	sub    $0xc,%esp
  801fb9:	ff 75 f4             	pushl  -0xc(%ebp)
  801fbc:	e8 18 ef ff ff       	call   800ed9 <fd2data>
	return _pipeisclosed(fd, p);
  801fc1:	89 c2                	mov    %eax,%edx
  801fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc6:	e8 21 fd ff ff       	call   801cec <_pipeisclosed>
  801fcb:	83 c4 10             	add    $0x10,%esp
}
  801fce:	c9                   	leave  
  801fcf:	c3                   	ret    

00801fd0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fd0:	55                   	push   %ebp
  801fd1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd8:	5d                   	pop    %ebp
  801fd9:	c3                   	ret    

00801fda <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fda:	55                   	push   %ebp
  801fdb:	89 e5                	mov    %esp,%ebp
  801fdd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fe0:	68 f7 29 80 00       	push   $0x8029f7
  801fe5:	ff 75 0c             	pushl  0xc(%ebp)
  801fe8:	e8 04 e8 ff ff       	call   8007f1 <strcpy>
	return 0;
}
  801fed:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff2:	c9                   	leave  
  801ff3:	c3                   	ret    

00801ff4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ff4:	55                   	push   %ebp
  801ff5:	89 e5                	mov    %esp,%ebp
  801ff7:	57                   	push   %edi
  801ff8:	56                   	push   %esi
  801ff9:	53                   	push   %ebx
  801ffa:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802000:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802005:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80200b:	eb 2d                	jmp    80203a <devcons_write+0x46>
		m = n - tot;
  80200d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802010:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802012:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802015:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80201a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80201d:	83 ec 04             	sub    $0x4,%esp
  802020:	53                   	push   %ebx
  802021:	03 45 0c             	add    0xc(%ebp),%eax
  802024:	50                   	push   %eax
  802025:	57                   	push   %edi
  802026:	e8 58 e9 ff ff       	call   800983 <memmove>
		sys_cputs(buf, m);
  80202b:	83 c4 08             	add    $0x8,%esp
  80202e:	53                   	push   %ebx
  80202f:	57                   	push   %edi
  802030:	e8 03 eb ff ff       	call   800b38 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802035:	01 de                	add    %ebx,%esi
  802037:	83 c4 10             	add    $0x10,%esp
  80203a:	89 f0                	mov    %esi,%eax
  80203c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80203f:	72 cc                	jb     80200d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802041:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802044:	5b                   	pop    %ebx
  802045:	5e                   	pop    %esi
  802046:	5f                   	pop    %edi
  802047:	5d                   	pop    %ebp
  802048:	c3                   	ret    

00802049 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802049:	55                   	push   %ebp
  80204a:	89 e5                	mov    %esp,%ebp
  80204c:	83 ec 08             	sub    $0x8,%esp
  80204f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802054:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802058:	74 2a                	je     802084 <devcons_read+0x3b>
  80205a:	eb 05                	jmp    802061 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80205c:	e8 74 eb ff ff       	call   800bd5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802061:	e8 f0 ea ff ff       	call   800b56 <sys_cgetc>
  802066:	85 c0                	test   %eax,%eax
  802068:	74 f2                	je     80205c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80206a:	85 c0                	test   %eax,%eax
  80206c:	78 16                	js     802084 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80206e:	83 f8 04             	cmp    $0x4,%eax
  802071:	74 0c                	je     80207f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802073:	8b 55 0c             	mov    0xc(%ebp),%edx
  802076:	88 02                	mov    %al,(%edx)
	return 1;
  802078:	b8 01 00 00 00       	mov    $0x1,%eax
  80207d:	eb 05                	jmp    802084 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80207f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802084:	c9                   	leave  
  802085:	c3                   	ret    

00802086 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802086:	55                   	push   %ebp
  802087:	89 e5                	mov    %esp,%ebp
  802089:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80208c:	8b 45 08             	mov    0x8(%ebp),%eax
  80208f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802092:	6a 01                	push   $0x1
  802094:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802097:	50                   	push   %eax
  802098:	e8 9b ea ff ff       	call   800b38 <sys_cputs>
}
  80209d:	83 c4 10             	add    $0x10,%esp
  8020a0:	c9                   	leave  
  8020a1:	c3                   	ret    

008020a2 <getchar>:

int
getchar(void)
{
  8020a2:	55                   	push   %ebp
  8020a3:	89 e5                	mov    %esp,%ebp
  8020a5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020a8:	6a 01                	push   $0x1
  8020aa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020ad:	50                   	push   %eax
  8020ae:	6a 00                	push   $0x0
  8020b0:	e8 f0 f0 ff ff       	call   8011a5 <read>
	if (r < 0)
  8020b5:	83 c4 10             	add    $0x10,%esp
  8020b8:	85 c0                	test   %eax,%eax
  8020ba:	78 0f                	js     8020cb <getchar+0x29>
		return r;
	if (r < 1)
  8020bc:	85 c0                	test   %eax,%eax
  8020be:	7e 06                	jle    8020c6 <getchar+0x24>
		return -E_EOF;
	return c;
  8020c0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020c4:	eb 05                	jmp    8020cb <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020c6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020cb:	c9                   	leave  
  8020cc:	c3                   	ret    

008020cd <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020cd:	55                   	push   %ebp
  8020ce:	89 e5                	mov    %esp,%ebp
  8020d0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d6:	50                   	push   %eax
  8020d7:	ff 75 08             	pushl  0x8(%ebp)
  8020da:	e8 60 ee ff ff       	call   800f3f <fd_lookup>
  8020df:	83 c4 10             	add    $0x10,%esp
  8020e2:	85 c0                	test   %eax,%eax
  8020e4:	78 11                	js     8020f7 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e9:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8020ef:	39 10                	cmp    %edx,(%eax)
  8020f1:	0f 94 c0             	sete   %al
  8020f4:	0f b6 c0             	movzbl %al,%eax
}
  8020f7:	c9                   	leave  
  8020f8:	c3                   	ret    

008020f9 <opencons>:

int
opencons(void)
{
  8020f9:	55                   	push   %ebp
  8020fa:	89 e5                	mov    %esp,%ebp
  8020fc:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802102:	50                   	push   %eax
  802103:	e8 e8 ed ff ff       	call   800ef0 <fd_alloc>
  802108:	83 c4 10             	add    $0x10,%esp
		return r;
  80210b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80210d:	85 c0                	test   %eax,%eax
  80210f:	78 3e                	js     80214f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802111:	83 ec 04             	sub    $0x4,%esp
  802114:	68 07 04 00 00       	push   $0x407
  802119:	ff 75 f4             	pushl  -0xc(%ebp)
  80211c:	6a 00                	push   $0x0
  80211e:	e8 d1 ea ff ff       	call   800bf4 <sys_page_alloc>
  802123:	83 c4 10             	add    $0x10,%esp
		return r;
  802126:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802128:	85 c0                	test   %eax,%eax
  80212a:	78 23                	js     80214f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80212c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802132:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802135:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802137:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802141:	83 ec 0c             	sub    $0xc,%esp
  802144:	50                   	push   %eax
  802145:	e8 7f ed ff ff       	call   800ec9 <fd2num>
  80214a:	89 c2                	mov    %eax,%edx
  80214c:	83 c4 10             	add    $0x10,%esp
}
  80214f:	89 d0                	mov    %edx,%eax
  802151:	c9                   	leave  
  802152:	c3                   	ret    

00802153 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802153:	55                   	push   %ebp
  802154:	89 e5                	mov    %esp,%ebp
  802156:	56                   	push   %esi
  802157:	53                   	push   %ebx
  802158:	8b 75 08             	mov    0x8(%ebp),%esi
  80215b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80215e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  802161:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802163:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802168:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  80216b:	83 ec 0c             	sub    $0xc,%esp
  80216e:	50                   	push   %eax
  80216f:	e8 30 ec ff ff       	call   800da4 <sys_ipc_recv>

	if (r < 0) {
  802174:	83 c4 10             	add    $0x10,%esp
  802177:	85 c0                	test   %eax,%eax
  802179:	79 16                	jns    802191 <ipc_recv+0x3e>
		if (from_env_store)
  80217b:	85 f6                	test   %esi,%esi
  80217d:	74 06                	je     802185 <ipc_recv+0x32>
			*from_env_store = 0;
  80217f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  802185:	85 db                	test   %ebx,%ebx
  802187:	74 2c                	je     8021b5 <ipc_recv+0x62>
			*perm_store = 0;
  802189:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80218f:	eb 24                	jmp    8021b5 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  802191:	85 f6                	test   %esi,%esi
  802193:	74 0a                	je     80219f <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  802195:	a1 20 60 80 00       	mov    0x806020,%eax
  80219a:	8b 40 74             	mov    0x74(%eax),%eax
  80219d:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  80219f:	85 db                	test   %ebx,%ebx
  8021a1:	74 0a                	je     8021ad <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  8021a3:	a1 20 60 80 00       	mov    0x806020,%eax
  8021a8:	8b 40 78             	mov    0x78(%eax),%eax
  8021ab:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  8021ad:	a1 20 60 80 00       	mov    0x806020,%eax
  8021b2:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8021b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021b8:	5b                   	pop    %ebx
  8021b9:	5e                   	pop    %esi
  8021ba:	5d                   	pop    %ebp
  8021bb:	c3                   	ret    

008021bc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021bc:	55                   	push   %ebp
  8021bd:	89 e5                	mov    %esp,%ebp
  8021bf:	57                   	push   %edi
  8021c0:	56                   	push   %esi
  8021c1:	53                   	push   %ebx
  8021c2:	83 ec 0c             	sub    $0xc,%esp
  8021c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021c8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8021ce:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8021d0:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8021d5:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8021d8:	ff 75 14             	pushl  0x14(%ebp)
  8021db:	53                   	push   %ebx
  8021dc:	56                   	push   %esi
  8021dd:	57                   	push   %edi
  8021de:	e8 9e eb ff ff       	call   800d81 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  8021e3:	83 c4 10             	add    $0x10,%esp
  8021e6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021e9:	75 07                	jne    8021f2 <ipc_send+0x36>
			sys_yield();
  8021eb:	e8 e5 e9 ff ff       	call   800bd5 <sys_yield>
  8021f0:	eb e6                	jmp    8021d8 <ipc_send+0x1c>
		} else if (r < 0) {
  8021f2:	85 c0                	test   %eax,%eax
  8021f4:	79 12                	jns    802208 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  8021f6:	50                   	push   %eax
  8021f7:	68 03 2a 80 00       	push   $0x802a03
  8021fc:	6a 51                	push   $0x51
  8021fe:	68 10 2a 80 00       	push   $0x802a10
  802203:	e8 8b df ff ff       	call   800193 <_panic>
		}
	}
}
  802208:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80220b:	5b                   	pop    %ebx
  80220c:	5e                   	pop    %esi
  80220d:	5f                   	pop    %edi
  80220e:	5d                   	pop    %ebp
  80220f:	c3                   	ret    

00802210 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802210:	55                   	push   %ebp
  802211:	89 e5                	mov    %esp,%ebp
  802213:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802216:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80221b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80221e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802224:	8b 52 50             	mov    0x50(%edx),%edx
  802227:	39 ca                	cmp    %ecx,%edx
  802229:	75 0d                	jne    802238 <ipc_find_env+0x28>
			return envs[i].env_id;
  80222b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80222e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802233:	8b 40 48             	mov    0x48(%eax),%eax
  802236:	eb 0f                	jmp    802247 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802238:	83 c0 01             	add    $0x1,%eax
  80223b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802240:	75 d9                	jne    80221b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802242:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802247:	5d                   	pop    %ebp
  802248:	c3                   	ret    

00802249 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802249:	55                   	push   %ebp
  80224a:	89 e5                	mov    %esp,%ebp
  80224c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80224f:	89 d0                	mov    %edx,%eax
  802251:	c1 e8 16             	shr    $0x16,%eax
  802254:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80225b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802260:	f6 c1 01             	test   $0x1,%cl
  802263:	74 1d                	je     802282 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802265:	c1 ea 0c             	shr    $0xc,%edx
  802268:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80226f:	f6 c2 01             	test   $0x1,%dl
  802272:	74 0e                	je     802282 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802274:	c1 ea 0c             	shr    $0xc,%edx
  802277:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80227e:	ef 
  80227f:	0f b7 c0             	movzwl %ax,%eax
}
  802282:	5d                   	pop    %ebp
  802283:	c3                   	ret    
  802284:	66 90                	xchg   %ax,%ax
  802286:	66 90                	xchg   %ax,%ax
  802288:	66 90                	xchg   %ax,%ax
  80228a:	66 90                	xchg   %ax,%ax
  80228c:	66 90                	xchg   %ax,%ax
  80228e:	66 90                	xchg   %ax,%ax

00802290 <__udivdi3>:
  802290:	55                   	push   %ebp
  802291:	57                   	push   %edi
  802292:	56                   	push   %esi
  802293:	53                   	push   %ebx
  802294:	83 ec 1c             	sub    $0x1c,%esp
  802297:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80229b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80229f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8022a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022a7:	85 f6                	test   %esi,%esi
  8022a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022ad:	89 ca                	mov    %ecx,%edx
  8022af:	89 f8                	mov    %edi,%eax
  8022b1:	75 3d                	jne    8022f0 <__udivdi3+0x60>
  8022b3:	39 cf                	cmp    %ecx,%edi
  8022b5:	0f 87 c5 00 00 00    	ja     802380 <__udivdi3+0xf0>
  8022bb:	85 ff                	test   %edi,%edi
  8022bd:	89 fd                	mov    %edi,%ebp
  8022bf:	75 0b                	jne    8022cc <__udivdi3+0x3c>
  8022c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8022c6:	31 d2                	xor    %edx,%edx
  8022c8:	f7 f7                	div    %edi
  8022ca:	89 c5                	mov    %eax,%ebp
  8022cc:	89 c8                	mov    %ecx,%eax
  8022ce:	31 d2                	xor    %edx,%edx
  8022d0:	f7 f5                	div    %ebp
  8022d2:	89 c1                	mov    %eax,%ecx
  8022d4:	89 d8                	mov    %ebx,%eax
  8022d6:	89 cf                	mov    %ecx,%edi
  8022d8:	f7 f5                	div    %ebp
  8022da:	89 c3                	mov    %eax,%ebx
  8022dc:	89 d8                	mov    %ebx,%eax
  8022de:	89 fa                	mov    %edi,%edx
  8022e0:	83 c4 1c             	add    $0x1c,%esp
  8022e3:	5b                   	pop    %ebx
  8022e4:	5e                   	pop    %esi
  8022e5:	5f                   	pop    %edi
  8022e6:	5d                   	pop    %ebp
  8022e7:	c3                   	ret    
  8022e8:	90                   	nop
  8022e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	39 ce                	cmp    %ecx,%esi
  8022f2:	77 74                	ja     802368 <__udivdi3+0xd8>
  8022f4:	0f bd fe             	bsr    %esi,%edi
  8022f7:	83 f7 1f             	xor    $0x1f,%edi
  8022fa:	0f 84 98 00 00 00    	je     802398 <__udivdi3+0x108>
  802300:	bb 20 00 00 00       	mov    $0x20,%ebx
  802305:	89 f9                	mov    %edi,%ecx
  802307:	89 c5                	mov    %eax,%ebp
  802309:	29 fb                	sub    %edi,%ebx
  80230b:	d3 e6                	shl    %cl,%esi
  80230d:	89 d9                	mov    %ebx,%ecx
  80230f:	d3 ed                	shr    %cl,%ebp
  802311:	89 f9                	mov    %edi,%ecx
  802313:	d3 e0                	shl    %cl,%eax
  802315:	09 ee                	or     %ebp,%esi
  802317:	89 d9                	mov    %ebx,%ecx
  802319:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80231d:	89 d5                	mov    %edx,%ebp
  80231f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802323:	d3 ed                	shr    %cl,%ebp
  802325:	89 f9                	mov    %edi,%ecx
  802327:	d3 e2                	shl    %cl,%edx
  802329:	89 d9                	mov    %ebx,%ecx
  80232b:	d3 e8                	shr    %cl,%eax
  80232d:	09 c2                	or     %eax,%edx
  80232f:	89 d0                	mov    %edx,%eax
  802331:	89 ea                	mov    %ebp,%edx
  802333:	f7 f6                	div    %esi
  802335:	89 d5                	mov    %edx,%ebp
  802337:	89 c3                	mov    %eax,%ebx
  802339:	f7 64 24 0c          	mull   0xc(%esp)
  80233d:	39 d5                	cmp    %edx,%ebp
  80233f:	72 10                	jb     802351 <__udivdi3+0xc1>
  802341:	8b 74 24 08          	mov    0x8(%esp),%esi
  802345:	89 f9                	mov    %edi,%ecx
  802347:	d3 e6                	shl    %cl,%esi
  802349:	39 c6                	cmp    %eax,%esi
  80234b:	73 07                	jae    802354 <__udivdi3+0xc4>
  80234d:	39 d5                	cmp    %edx,%ebp
  80234f:	75 03                	jne    802354 <__udivdi3+0xc4>
  802351:	83 eb 01             	sub    $0x1,%ebx
  802354:	31 ff                	xor    %edi,%edi
  802356:	89 d8                	mov    %ebx,%eax
  802358:	89 fa                	mov    %edi,%edx
  80235a:	83 c4 1c             	add    $0x1c,%esp
  80235d:	5b                   	pop    %ebx
  80235e:	5e                   	pop    %esi
  80235f:	5f                   	pop    %edi
  802360:	5d                   	pop    %ebp
  802361:	c3                   	ret    
  802362:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802368:	31 ff                	xor    %edi,%edi
  80236a:	31 db                	xor    %ebx,%ebx
  80236c:	89 d8                	mov    %ebx,%eax
  80236e:	89 fa                	mov    %edi,%edx
  802370:	83 c4 1c             	add    $0x1c,%esp
  802373:	5b                   	pop    %ebx
  802374:	5e                   	pop    %esi
  802375:	5f                   	pop    %edi
  802376:	5d                   	pop    %ebp
  802377:	c3                   	ret    
  802378:	90                   	nop
  802379:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802380:	89 d8                	mov    %ebx,%eax
  802382:	f7 f7                	div    %edi
  802384:	31 ff                	xor    %edi,%edi
  802386:	89 c3                	mov    %eax,%ebx
  802388:	89 d8                	mov    %ebx,%eax
  80238a:	89 fa                	mov    %edi,%edx
  80238c:	83 c4 1c             	add    $0x1c,%esp
  80238f:	5b                   	pop    %ebx
  802390:	5e                   	pop    %esi
  802391:	5f                   	pop    %edi
  802392:	5d                   	pop    %ebp
  802393:	c3                   	ret    
  802394:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802398:	39 ce                	cmp    %ecx,%esi
  80239a:	72 0c                	jb     8023a8 <__udivdi3+0x118>
  80239c:	31 db                	xor    %ebx,%ebx
  80239e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8023a2:	0f 87 34 ff ff ff    	ja     8022dc <__udivdi3+0x4c>
  8023a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8023ad:	e9 2a ff ff ff       	jmp    8022dc <__udivdi3+0x4c>
  8023b2:	66 90                	xchg   %ax,%ax
  8023b4:	66 90                	xchg   %ax,%ax
  8023b6:	66 90                	xchg   %ax,%ax
  8023b8:	66 90                	xchg   %ax,%ax
  8023ba:	66 90                	xchg   %ax,%ax
  8023bc:	66 90                	xchg   %ax,%ax
  8023be:	66 90                	xchg   %ax,%ax

008023c0 <__umoddi3>:
  8023c0:	55                   	push   %ebp
  8023c1:	57                   	push   %edi
  8023c2:	56                   	push   %esi
  8023c3:	53                   	push   %ebx
  8023c4:	83 ec 1c             	sub    $0x1c,%esp
  8023c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8023cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8023cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023d7:	85 d2                	test   %edx,%edx
  8023d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023e1:	89 f3                	mov    %esi,%ebx
  8023e3:	89 3c 24             	mov    %edi,(%esp)
  8023e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023ea:	75 1c                	jne    802408 <__umoddi3+0x48>
  8023ec:	39 f7                	cmp    %esi,%edi
  8023ee:	76 50                	jbe    802440 <__umoddi3+0x80>
  8023f0:	89 c8                	mov    %ecx,%eax
  8023f2:	89 f2                	mov    %esi,%edx
  8023f4:	f7 f7                	div    %edi
  8023f6:	89 d0                	mov    %edx,%eax
  8023f8:	31 d2                	xor    %edx,%edx
  8023fa:	83 c4 1c             	add    $0x1c,%esp
  8023fd:	5b                   	pop    %ebx
  8023fe:	5e                   	pop    %esi
  8023ff:	5f                   	pop    %edi
  802400:	5d                   	pop    %ebp
  802401:	c3                   	ret    
  802402:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802408:	39 f2                	cmp    %esi,%edx
  80240a:	89 d0                	mov    %edx,%eax
  80240c:	77 52                	ja     802460 <__umoddi3+0xa0>
  80240e:	0f bd ea             	bsr    %edx,%ebp
  802411:	83 f5 1f             	xor    $0x1f,%ebp
  802414:	75 5a                	jne    802470 <__umoddi3+0xb0>
  802416:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80241a:	0f 82 e0 00 00 00    	jb     802500 <__umoddi3+0x140>
  802420:	39 0c 24             	cmp    %ecx,(%esp)
  802423:	0f 86 d7 00 00 00    	jbe    802500 <__umoddi3+0x140>
  802429:	8b 44 24 08          	mov    0x8(%esp),%eax
  80242d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802431:	83 c4 1c             	add    $0x1c,%esp
  802434:	5b                   	pop    %ebx
  802435:	5e                   	pop    %esi
  802436:	5f                   	pop    %edi
  802437:	5d                   	pop    %ebp
  802438:	c3                   	ret    
  802439:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802440:	85 ff                	test   %edi,%edi
  802442:	89 fd                	mov    %edi,%ebp
  802444:	75 0b                	jne    802451 <__umoddi3+0x91>
  802446:	b8 01 00 00 00       	mov    $0x1,%eax
  80244b:	31 d2                	xor    %edx,%edx
  80244d:	f7 f7                	div    %edi
  80244f:	89 c5                	mov    %eax,%ebp
  802451:	89 f0                	mov    %esi,%eax
  802453:	31 d2                	xor    %edx,%edx
  802455:	f7 f5                	div    %ebp
  802457:	89 c8                	mov    %ecx,%eax
  802459:	f7 f5                	div    %ebp
  80245b:	89 d0                	mov    %edx,%eax
  80245d:	eb 99                	jmp    8023f8 <__umoddi3+0x38>
  80245f:	90                   	nop
  802460:	89 c8                	mov    %ecx,%eax
  802462:	89 f2                	mov    %esi,%edx
  802464:	83 c4 1c             	add    $0x1c,%esp
  802467:	5b                   	pop    %ebx
  802468:	5e                   	pop    %esi
  802469:	5f                   	pop    %edi
  80246a:	5d                   	pop    %ebp
  80246b:	c3                   	ret    
  80246c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802470:	8b 34 24             	mov    (%esp),%esi
  802473:	bf 20 00 00 00       	mov    $0x20,%edi
  802478:	89 e9                	mov    %ebp,%ecx
  80247a:	29 ef                	sub    %ebp,%edi
  80247c:	d3 e0                	shl    %cl,%eax
  80247e:	89 f9                	mov    %edi,%ecx
  802480:	89 f2                	mov    %esi,%edx
  802482:	d3 ea                	shr    %cl,%edx
  802484:	89 e9                	mov    %ebp,%ecx
  802486:	09 c2                	or     %eax,%edx
  802488:	89 d8                	mov    %ebx,%eax
  80248a:	89 14 24             	mov    %edx,(%esp)
  80248d:	89 f2                	mov    %esi,%edx
  80248f:	d3 e2                	shl    %cl,%edx
  802491:	89 f9                	mov    %edi,%ecx
  802493:	89 54 24 04          	mov    %edx,0x4(%esp)
  802497:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80249b:	d3 e8                	shr    %cl,%eax
  80249d:	89 e9                	mov    %ebp,%ecx
  80249f:	89 c6                	mov    %eax,%esi
  8024a1:	d3 e3                	shl    %cl,%ebx
  8024a3:	89 f9                	mov    %edi,%ecx
  8024a5:	89 d0                	mov    %edx,%eax
  8024a7:	d3 e8                	shr    %cl,%eax
  8024a9:	89 e9                	mov    %ebp,%ecx
  8024ab:	09 d8                	or     %ebx,%eax
  8024ad:	89 d3                	mov    %edx,%ebx
  8024af:	89 f2                	mov    %esi,%edx
  8024b1:	f7 34 24             	divl   (%esp)
  8024b4:	89 d6                	mov    %edx,%esi
  8024b6:	d3 e3                	shl    %cl,%ebx
  8024b8:	f7 64 24 04          	mull   0x4(%esp)
  8024bc:	39 d6                	cmp    %edx,%esi
  8024be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024c2:	89 d1                	mov    %edx,%ecx
  8024c4:	89 c3                	mov    %eax,%ebx
  8024c6:	72 08                	jb     8024d0 <__umoddi3+0x110>
  8024c8:	75 11                	jne    8024db <__umoddi3+0x11b>
  8024ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8024ce:	73 0b                	jae    8024db <__umoddi3+0x11b>
  8024d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8024d4:	1b 14 24             	sbb    (%esp),%edx
  8024d7:	89 d1                	mov    %edx,%ecx
  8024d9:	89 c3                	mov    %eax,%ebx
  8024db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8024df:	29 da                	sub    %ebx,%edx
  8024e1:	19 ce                	sbb    %ecx,%esi
  8024e3:	89 f9                	mov    %edi,%ecx
  8024e5:	89 f0                	mov    %esi,%eax
  8024e7:	d3 e0                	shl    %cl,%eax
  8024e9:	89 e9                	mov    %ebp,%ecx
  8024eb:	d3 ea                	shr    %cl,%edx
  8024ed:	89 e9                	mov    %ebp,%ecx
  8024ef:	d3 ee                	shr    %cl,%esi
  8024f1:	09 d0                	or     %edx,%eax
  8024f3:	89 f2                	mov    %esi,%edx
  8024f5:	83 c4 1c             	add    $0x1c,%esp
  8024f8:	5b                   	pop    %ebx
  8024f9:	5e                   	pop    %esi
  8024fa:	5f                   	pop    %edi
  8024fb:	5d                   	pop    %ebp
  8024fc:	c3                   	ret    
  8024fd:	8d 76 00             	lea    0x0(%esi),%esi
  802500:	29 f9                	sub    %edi,%ecx
  802502:	19 d6                	sbb    %edx,%esi
  802504:	89 74 24 04          	mov    %esi,0x4(%esp)
  802508:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80250c:	e9 18 ff ff ff       	jmp    802429 <__umoddi3+0x69>
