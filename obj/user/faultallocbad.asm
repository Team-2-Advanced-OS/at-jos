
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 c0 1e 80 00       	push   $0x801ec0
  800045:	e8 a4 01 00 00       	call   8001ee <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 18 0b 00 00       	call   800b76 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 e0 1e 80 00       	push   $0x801ee0
  80006f:	6a 0f                	push   $0xf
  800071:	68 ca 1e 80 00       	push   $0x801eca
  800076:	e8 9a 00 00 00       	call   800115 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 0c 1f 80 00       	push   $0x801f0c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 97 06 00 00       	call   800720 <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 c6 0c 00 00       	call   800d67 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 0a 0a 00 00       	call   800aba <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 73 0a 00 00       	call   800b38 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 a2 0e 00 00       	call   800fa8 <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 e7 09 00 00       	call   800af7 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80011a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80011d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800123:	e8 10 0a 00 00       	call   800b38 <sys_getenvid>
  800128:	83 ec 0c             	sub    $0xc,%esp
  80012b:	ff 75 0c             	pushl  0xc(%ebp)
  80012e:	ff 75 08             	pushl  0x8(%ebp)
  800131:	56                   	push   %esi
  800132:	50                   	push   %eax
  800133:	68 38 1f 80 00       	push   $0x801f38
  800138:	e8 b1 00 00 00       	call   8001ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013d:	83 c4 18             	add    $0x18,%esp
  800140:	53                   	push   %ebx
  800141:	ff 75 10             	pushl  0x10(%ebp)
  800144:	e8 54 00 00 00       	call   80019d <vcprintf>
	cprintf("\n");
  800149:	c7 04 24 73 23 80 00 	movl   $0x802373,(%esp)
  800150:	e8 99 00 00 00       	call   8001ee <cprintf>
  800155:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800158:	cc                   	int3   
  800159:	eb fd                	jmp    800158 <_panic+0x43>

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800165:	8b 13                	mov    (%ebx),%edx
  800167:	8d 42 01             	lea    0x1(%edx),%eax
  80016a:	89 03                	mov    %eax,(%ebx)
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800173:	3d ff 00 00 00       	cmp    $0xff,%eax
  800178:	75 1a                	jne    800194 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017a:	83 ec 08             	sub    $0x8,%esp
  80017d:	68 ff 00 00 00       	push   $0xff
  800182:	8d 43 08             	lea    0x8(%ebx),%eax
  800185:	50                   	push   %eax
  800186:	e8 2f 09 00 00       	call   800aba <sys_cputs>
		b->idx = 0;
  80018b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800191:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800194:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800198:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ad:	00 00 00 
	b.cnt = 0;
  8001b0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ba:	ff 75 0c             	pushl  0xc(%ebp)
  8001bd:	ff 75 08             	pushl  0x8(%ebp)
  8001c0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	68 5b 01 80 00       	push   $0x80015b
  8001cc:	e8 54 01 00 00       	call   800325 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d1:	83 c4 08             	add    $0x8,%esp
  8001d4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e0:	50                   	push   %eax
  8001e1:	e8 d4 08 00 00       	call   800aba <sys_cputs>

	return b.cnt;
}
  8001e6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    

008001ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f7:	50                   	push   %eax
  8001f8:	ff 75 08             	pushl  0x8(%ebp)
  8001fb:	e8 9d ff ff ff       	call   80019d <vcprintf>
	va_end(ap);

	return cnt;
}
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	57                   	push   %edi
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	83 ec 1c             	sub    $0x1c,%esp
  80020b:	89 c7                	mov    %eax,%edi
  80020d:	89 d6                	mov    %edx,%esi
  80020f:	8b 45 08             	mov    0x8(%ebp),%eax
  800212:	8b 55 0c             	mov    0xc(%ebp),%edx
  800215:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800218:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80021e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800223:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800226:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800229:	39 d3                	cmp    %edx,%ebx
  80022b:	72 05                	jb     800232 <printnum+0x30>
  80022d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800230:	77 45                	ja     800277 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800232:	83 ec 0c             	sub    $0xc,%esp
  800235:	ff 75 18             	pushl  0x18(%ebp)
  800238:	8b 45 14             	mov    0x14(%ebp),%eax
  80023b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80023e:	53                   	push   %ebx
  80023f:	ff 75 10             	pushl  0x10(%ebp)
  800242:	83 ec 08             	sub    $0x8,%esp
  800245:	ff 75 e4             	pushl  -0x1c(%ebp)
  800248:	ff 75 e0             	pushl  -0x20(%ebp)
  80024b:	ff 75 dc             	pushl  -0x24(%ebp)
  80024e:	ff 75 d8             	pushl  -0x28(%ebp)
  800251:	e8 da 19 00 00       	call   801c30 <__udivdi3>
  800256:	83 c4 18             	add    $0x18,%esp
  800259:	52                   	push   %edx
  80025a:	50                   	push   %eax
  80025b:	89 f2                	mov    %esi,%edx
  80025d:	89 f8                	mov    %edi,%eax
  80025f:	e8 9e ff ff ff       	call   800202 <printnum>
  800264:	83 c4 20             	add    $0x20,%esp
  800267:	eb 18                	jmp    800281 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	56                   	push   %esi
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	ff d7                	call   *%edi
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 03                	jmp    80027a <printnum+0x78>
  800277:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027a:	83 eb 01             	sub    $0x1,%ebx
  80027d:	85 db                	test   %ebx,%ebx
  80027f:	7f e8                	jg     800269 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	56                   	push   %esi
  800285:	83 ec 04             	sub    $0x4,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 c7 1a 00 00       	call   801d60 <__umoddi3>
  800299:	83 c4 14             	add    $0x14,%esp
  80029c:	0f be 80 5b 1f 80 00 	movsbl 0x801f5b(%eax),%eax
  8002a3:	50                   	push   %eax
  8002a4:	ff d7                	call   *%edi
}
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b4:	83 fa 01             	cmp    $0x1,%edx
  8002b7:	7e 0e                	jle    8002c7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002be:	89 08                	mov    %ecx,(%eax)
  8002c0:	8b 02                	mov    (%edx),%eax
  8002c2:	8b 52 04             	mov    0x4(%edx),%edx
  8002c5:	eb 22                	jmp    8002e9 <getuint+0x38>
	else if (lflag)
  8002c7:	85 d2                	test   %edx,%edx
  8002c9:	74 10                	je     8002db <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d9:	eb 0e                	jmp    8002e9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e0:	89 08                	mov    %ecx,(%eax)
  8002e2:	8b 02                	mov    (%edx),%eax
  8002e4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f5:	8b 10                	mov    (%eax),%edx
  8002f7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fa:	73 0a                	jae    800306 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ff:	89 08                	mov    %ecx,(%eax)
  800301:	8b 45 08             	mov    0x8(%ebp),%eax
  800304:	88 02                	mov    %al,(%edx)
}
  800306:	5d                   	pop    %ebp
  800307:	c3                   	ret    

00800308 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80030e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800311:	50                   	push   %eax
  800312:	ff 75 10             	pushl  0x10(%ebp)
  800315:	ff 75 0c             	pushl  0xc(%ebp)
  800318:	ff 75 08             	pushl  0x8(%ebp)
  80031b:	e8 05 00 00 00       	call   800325 <vprintfmt>
	va_end(ap);
}
  800320:	83 c4 10             	add    $0x10,%esp
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	83 ec 2c             	sub    $0x2c,%esp
  80032e:	8b 75 08             	mov    0x8(%ebp),%esi
  800331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800334:	8b 7d 10             	mov    0x10(%ebp),%edi
  800337:	eb 12                	jmp    80034b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800339:	85 c0                	test   %eax,%eax
  80033b:	0f 84 89 03 00 00    	je     8006ca <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800341:	83 ec 08             	sub    $0x8,%esp
  800344:	53                   	push   %ebx
  800345:	50                   	push   %eax
  800346:	ff d6                	call   *%esi
  800348:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034b:	83 c7 01             	add    $0x1,%edi
  80034e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800352:	83 f8 25             	cmp    $0x25,%eax
  800355:	75 e2                	jne    800339 <vprintfmt+0x14>
  800357:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80035b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800362:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800369:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800370:	ba 00 00 00 00       	mov    $0x0,%edx
  800375:	eb 07                	jmp    80037e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80037a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8d 47 01             	lea    0x1(%edi),%eax
  800381:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800384:	0f b6 07             	movzbl (%edi),%eax
  800387:	0f b6 c8             	movzbl %al,%ecx
  80038a:	83 e8 23             	sub    $0x23,%eax
  80038d:	3c 55                	cmp    $0x55,%al
  80038f:	0f 87 1a 03 00 00    	ja     8006af <vprintfmt+0x38a>
  800395:	0f b6 c0             	movzbl %al,%eax
  800398:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  80039f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a6:	eb d6                	jmp    80037e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003ba:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003bd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c0:	83 fa 09             	cmp    $0x9,%edx
  8003c3:	77 39                	ja     8003fe <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c8:	eb e9                	jmp    8003b3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cd:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d3:	8b 00                	mov    (%eax),%eax
  8003d5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003db:	eb 27                	jmp    800404 <vprintfmt+0xdf>
  8003dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e0:	85 c0                	test   %eax,%eax
  8003e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e7:	0f 49 c8             	cmovns %eax,%ecx
  8003ea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f0:	eb 8c                	jmp    80037e <vprintfmt+0x59>
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003fc:	eb 80                	jmp    80037e <vprintfmt+0x59>
  8003fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800401:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800404:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800408:	0f 89 70 ff ff ff    	jns    80037e <vprintfmt+0x59>
				width = precision, precision = -1;
  80040e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800411:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800414:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80041b:	e9 5e ff ff ff       	jmp    80037e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800420:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800426:	e9 53 ff ff ff       	jmp    80037e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042b:	8b 45 14             	mov    0x14(%ebp),%eax
  80042e:	8d 50 04             	lea    0x4(%eax),%edx
  800431:	89 55 14             	mov    %edx,0x14(%ebp)
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	53                   	push   %ebx
  800438:	ff 30                	pushl  (%eax)
  80043a:	ff d6                	call   *%esi
			break;
  80043c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800442:	e9 04 ff ff ff       	jmp    80034b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 50 04             	lea    0x4(%eax),%edx
  80044d:	89 55 14             	mov    %edx,0x14(%ebp)
  800450:	8b 00                	mov    (%eax),%eax
  800452:	99                   	cltd   
  800453:	31 d0                	xor    %edx,%eax
  800455:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800457:	83 f8 0f             	cmp    $0xf,%eax
  80045a:	7f 0b                	jg     800467 <vprintfmt+0x142>
  80045c:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  800463:	85 d2                	test   %edx,%edx
  800465:	75 18                	jne    80047f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800467:	50                   	push   %eax
  800468:	68 73 1f 80 00       	push   $0x801f73
  80046d:	53                   	push   %ebx
  80046e:	56                   	push   %esi
  80046f:	e8 94 fe ff ff       	call   800308 <printfmt>
  800474:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047a:	e9 cc fe ff ff       	jmp    80034b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80047f:	52                   	push   %edx
  800480:	68 3a 23 80 00       	push   $0x80233a
  800485:	53                   	push   %ebx
  800486:	56                   	push   %esi
  800487:	e8 7c fe ff ff       	call   800308 <printfmt>
  80048c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800492:	e9 b4 fe ff ff       	jmp    80034b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800497:	8b 45 14             	mov    0x14(%ebp),%eax
  80049a:	8d 50 04             	lea    0x4(%eax),%edx
  80049d:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a2:	85 ff                	test   %edi,%edi
  8004a4:	b8 6c 1f 80 00       	mov    $0x801f6c,%eax
  8004a9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b0:	0f 8e 94 00 00 00    	jle    80054a <vprintfmt+0x225>
  8004b6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ba:	0f 84 98 00 00 00    	je     800558 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c6:	57                   	push   %edi
  8004c7:	e8 86 02 00 00       	call   800752 <strnlen>
  8004cc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004cf:	29 c1                	sub    %eax,%ecx
  8004d1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004d4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004de:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e3:	eb 0f                	jmp    8004f4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	53                   	push   %ebx
  8004e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ec:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ee:	83 ef 01             	sub    $0x1,%edi
  8004f1:	83 c4 10             	add    $0x10,%esp
  8004f4:	85 ff                	test   %edi,%edi
  8004f6:	7f ed                	jg     8004e5 <vprintfmt+0x1c0>
  8004f8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004fe:	85 c9                	test   %ecx,%ecx
  800500:	b8 00 00 00 00       	mov    $0x0,%eax
  800505:	0f 49 c1             	cmovns %ecx,%eax
  800508:	29 c1                	sub    %eax,%ecx
  80050a:	89 75 08             	mov    %esi,0x8(%ebp)
  80050d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800510:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800513:	89 cb                	mov    %ecx,%ebx
  800515:	eb 4d                	jmp    800564 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800517:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051b:	74 1b                	je     800538 <vprintfmt+0x213>
  80051d:	0f be c0             	movsbl %al,%eax
  800520:	83 e8 20             	sub    $0x20,%eax
  800523:	83 f8 5e             	cmp    $0x5e,%eax
  800526:	76 10                	jbe    800538 <vprintfmt+0x213>
					putch('?', putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	ff 75 0c             	pushl  0xc(%ebp)
  80052e:	6a 3f                	push   $0x3f
  800530:	ff 55 08             	call   *0x8(%ebp)
  800533:	83 c4 10             	add    $0x10,%esp
  800536:	eb 0d                	jmp    800545 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800538:	83 ec 08             	sub    $0x8,%esp
  80053b:	ff 75 0c             	pushl  0xc(%ebp)
  80053e:	52                   	push   %edx
  80053f:	ff 55 08             	call   *0x8(%ebp)
  800542:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800545:	83 eb 01             	sub    $0x1,%ebx
  800548:	eb 1a                	jmp    800564 <vprintfmt+0x23f>
  80054a:	89 75 08             	mov    %esi,0x8(%ebp)
  80054d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800550:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800553:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800556:	eb 0c                	jmp    800564 <vprintfmt+0x23f>
  800558:	89 75 08             	mov    %esi,0x8(%ebp)
  80055b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800561:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800564:	83 c7 01             	add    $0x1,%edi
  800567:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056b:	0f be d0             	movsbl %al,%edx
  80056e:	85 d2                	test   %edx,%edx
  800570:	74 23                	je     800595 <vprintfmt+0x270>
  800572:	85 f6                	test   %esi,%esi
  800574:	78 a1                	js     800517 <vprintfmt+0x1f2>
  800576:	83 ee 01             	sub    $0x1,%esi
  800579:	79 9c                	jns    800517 <vprintfmt+0x1f2>
  80057b:	89 df                	mov    %ebx,%edi
  80057d:	8b 75 08             	mov    0x8(%ebp),%esi
  800580:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800583:	eb 18                	jmp    80059d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800585:	83 ec 08             	sub    $0x8,%esp
  800588:	53                   	push   %ebx
  800589:	6a 20                	push   $0x20
  80058b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058d:	83 ef 01             	sub    $0x1,%edi
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	eb 08                	jmp    80059d <vprintfmt+0x278>
  800595:	89 df                	mov    %ebx,%edi
  800597:	8b 75 08             	mov    0x8(%ebp),%esi
  80059a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059d:	85 ff                	test   %edi,%edi
  80059f:	7f e4                	jg     800585 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a4:	e9 a2 fd ff ff       	jmp    80034b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a9:	83 fa 01             	cmp    $0x1,%edx
  8005ac:	7e 16                	jle    8005c4 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 08             	lea    0x8(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	8b 50 04             	mov    0x4(%eax),%edx
  8005ba:	8b 00                	mov    (%eax),%eax
  8005bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c2:	eb 32                	jmp    8005f6 <vprintfmt+0x2d1>
	else if (lflag)
  8005c4:	85 d2                	test   %edx,%edx
  8005c6:	74 18                	je     8005e0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d6:	89 c1                	mov    %eax,%ecx
  8005d8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005db:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005de:	eb 16                	jmp    8005f6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 50 04             	lea    0x4(%eax),%edx
  8005e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e9:	8b 00                	mov    (%eax),%eax
  8005eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ee:	89 c1                	mov    %eax,%ecx
  8005f0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800601:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800605:	79 74                	jns    80067b <vprintfmt+0x356>
				putch('-', putdat);
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	53                   	push   %ebx
  80060b:	6a 2d                	push   $0x2d
  80060d:	ff d6                	call   *%esi
				num = -(long long) num;
  80060f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800612:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800615:	f7 d8                	neg    %eax
  800617:	83 d2 00             	adc    $0x0,%edx
  80061a:	f7 da                	neg    %edx
  80061c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80061f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800624:	eb 55                	jmp    80067b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800626:	8d 45 14             	lea    0x14(%ebp),%eax
  800629:	e8 83 fc ff ff       	call   8002b1 <getuint>
			base = 10;
  80062e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800633:	eb 46                	jmp    80067b <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800635:	8d 45 14             	lea    0x14(%ebp),%eax
  800638:	e8 74 fc ff ff       	call   8002b1 <getuint>
                        base = 8;
  80063d:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800642:	eb 37                	jmp    80067b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	6a 30                	push   $0x30
  80064a:	ff d6                	call   *%esi
			putch('x', putdat);
  80064c:	83 c4 08             	add    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	6a 78                	push   $0x78
  800652:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8d 50 04             	lea    0x4(%eax),%edx
  80065a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80065d:	8b 00                	mov    (%eax),%eax
  80065f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800664:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800667:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80066c:	eb 0d                	jmp    80067b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80066e:	8d 45 14             	lea    0x14(%ebp),%eax
  800671:	e8 3b fc ff ff       	call   8002b1 <getuint>
			base = 16;
  800676:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067b:	83 ec 0c             	sub    $0xc,%esp
  80067e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800682:	57                   	push   %edi
  800683:	ff 75 e0             	pushl  -0x20(%ebp)
  800686:	51                   	push   %ecx
  800687:	52                   	push   %edx
  800688:	50                   	push   %eax
  800689:	89 da                	mov    %ebx,%edx
  80068b:	89 f0                	mov    %esi,%eax
  80068d:	e8 70 fb ff ff       	call   800202 <printnum>
			break;
  800692:	83 c4 20             	add    $0x20,%esp
  800695:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800698:	e9 ae fc ff ff       	jmp    80034b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	51                   	push   %ecx
  8006a2:	ff d6                	call   *%esi
			break;
  8006a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006aa:	e9 9c fc ff ff       	jmp    80034b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	6a 25                	push   $0x25
  8006b5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b7:	83 c4 10             	add    $0x10,%esp
  8006ba:	eb 03                	jmp    8006bf <vprintfmt+0x39a>
  8006bc:	83 ef 01             	sub    $0x1,%edi
  8006bf:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c3:	75 f7                	jne    8006bc <vprintfmt+0x397>
  8006c5:	e9 81 fc ff ff       	jmp    80034b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006cd:	5b                   	pop    %ebx
  8006ce:	5e                   	pop    %esi
  8006cf:	5f                   	pop    %edi
  8006d0:	5d                   	pop    %ebp
  8006d1:	c3                   	ret    

008006d2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	83 ec 18             	sub    $0x18,%esp
  8006d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006db:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	74 26                	je     800719 <vsnprintf+0x47>
  8006f3:	85 d2                	test   %edx,%edx
  8006f5:	7e 22                	jle    800719 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f7:	ff 75 14             	pushl  0x14(%ebp)
  8006fa:	ff 75 10             	pushl  0x10(%ebp)
  8006fd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800700:	50                   	push   %eax
  800701:	68 eb 02 80 00       	push   $0x8002eb
  800706:	e8 1a fc ff ff       	call   800325 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800711:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	eb 05                	jmp    80071e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800719:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    

00800720 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800726:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800729:	50                   	push   %eax
  80072a:	ff 75 10             	pushl  0x10(%ebp)
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	ff 75 08             	pushl  0x8(%ebp)
  800733:	e8 9a ff ff ff       	call   8006d2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800738:	c9                   	leave  
  800739:	c3                   	ret    

0080073a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800740:	b8 00 00 00 00       	mov    $0x0,%eax
  800745:	eb 03                	jmp    80074a <strlen+0x10>
		n++;
  800747:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074e:	75 f7                	jne    800747 <strlen+0xd>
		n++;
	return n;
}
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800758:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075b:	ba 00 00 00 00       	mov    $0x0,%edx
  800760:	eb 03                	jmp    800765 <strnlen+0x13>
		n++;
  800762:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800765:	39 c2                	cmp    %eax,%edx
  800767:	74 08                	je     800771 <strnlen+0x1f>
  800769:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80076d:	75 f3                	jne    800762 <strnlen+0x10>
  80076f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800771:	5d                   	pop    %ebp
  800772:	c3                   	ret    

00800773 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	53                   	push   %ebx
  800777:	8b 45 08             	mov    0x8(%ebp),%eax
  80077a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077d:	89 c2                	mov    %eax,%edx
  80077f:	83 c2 01             	add    $0x1,%edx
  800782:	83 c1 01             	add    $0x1,%ecx
  800785:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800789:	88 5a ff             	mov    %bl,-0x1(%edx)
  80078c:	84 db                	test   %bl,%bl
  80078e:	75 ef                	jne    80077f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800790:	5b                   	pop    %ebx
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	53                   	push   %ebx
  800797:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079a:	53                   	push   %ebx
  80079b:	e8 9a ff ff ff       	call   80073a <strlen>
  8007a0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a3:	ff 75 0c             	pushl  0xc(%ebp)
  8007a6:	01 d8                	add    %ebx,%eax
  8007a8:	50                   	push   %eax
  8007a9:	e8 c5 ff ff ff       	call   800773 <strcpy>
	return dst;
}
  8007ae:	89 d8                	mov    %ebx,%eax
  8007b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	56                   	push   %esi
  8007b9:	53                   	push   %ebx
  8007ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c0:	89 f3                	mov    %esi,%ebx
  8007c2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c5:	89 f2                	mov    %esi,%edx
  8007c7:	eb 0f                	jmp    8007d8 <strncpy+0x23>
		*dst++ = *src;
  8007c9:	83 c2 01             	add    $0x1,%edx
  8007cc:	0f b6 01             	movzbl (%ecx),%eax
  8007cf:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d2:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d8:	39 da                	cmp    %ebx,%edx
  8007da:	75 ed                	jne    8007c9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007dc:	89 f0                	mov    %esi,%eax
  8007de:	5b                   	pop    %ebx
  8007df:	5e                   	pop    %esi
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	56                   	push   %esi
  8007e6:	53                   	push   %ebx
  8007e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ed:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f2:	85 d2                	test   %edx,%edx
  8007f4:	74 21                	je     800817 <strlcpy+0x35>
  8007f6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fa:	89 f2                	mov    %esi,%edx
  8007fc:	eb 09                	jmp    800807 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fe:	83 c2 01             	add    $0x1,%edx
  800801:	83 c1 01             	add    $0x1,%ecx
  800804:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800807:	39 c2                	cmp    %eax,%edx
  800809:	74 09                	je     800814 <strlcpy+0x32>
  80080b:	0f b6 19             	movzbl (%ecx),%ebx
  80080e:	84 db                	test   %bl,%bl
  800810:	75 ec                	jne    8007fe <strlcpy+0x1c>
  800812:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800814:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800817:	29 f0                	sub    %esi,%eax
}
  800819:	5b                   	pop    %ebx
  80081a:	5e                   	pop    %esi
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800823:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800826:	eb 06                	jmp    80082e <strcmp+0x11>
		p++, q++;
  800828:	83 c1 01             	add    $0x1,%ecx
  80082b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80082e:	0f b6 01             	movzbl (%ecx),%eax
  800831:	84 c0                	test   %al,%al
  800833:	74 04                	je     800839 <strcmp+0x1c>
  800835:	3a 02                	cmp    (%edx),%al
  800837:	74 ef                	je     800828 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800839:	0f b6 c0             	movzbl %al,%eax
  80083c:	0f b6 12             	movzbl (%edx),%edx
  80083f:	29 d0                	sub    %edx,%eax
}
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	53                   	push   %ebx
  800847:	8b 45 08             	mov    0x8(%ebp),%eax
  80084a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084d:	89 c3                	mov    %eax,%ebx
  80084f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800852:	eb 06                	jmp    80085a <strncmp+0x17>
		n--, p++, q++;
  800854:	83 c0 01             	add    $0x1,%eax
  800857:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085a:	39 d8                	cmp    %ebx,%eax
  80085c:	74 15                	je     800873 <strncmp+0x30>
  80085e:	0f b6 08             	movzbl (%eax),%ecx
  800861:	84 c9                	test   %cl,%cl
  800863:	74 04                	je     800869 <strncmp+0x26>
  800865:	3a 0a                	cmp    (%edx),%cl
  800867:	74 eb                	je     800854 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800869:	0f b6 00             	movzbl (%eax),%eax
  80086c:	0f b6 12             	movzbl (%edx),%edx
  80086f:	29 d0                	sub    %edx,%eax
  800871:	eb 05                	jmp    800878 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800873:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800878:	5b                   	pop    %ebx
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	8b 45 08             	mov    0x8(%ebp),%eax
  800881:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800885:	eb 07                	jmp    80088e <strchr+0x13>
		if (*s == c)
  800887:	38 ca                	cmp    %cl,%dl
  800889:	74 0f                	je     80089a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088b:	83 c0 01             	add    $0x1,%eax
  80088e:	0f b6 10             	movzbl (%eax),%edx
  800891:	84 d2                	test   %dl,%dl
  800893:	75 f2                	jne    800887 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800895:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a6:	eb 03                	jmp    8008ab <strfind+0xf>
  8008a8:	83 c0 01             	add    $0x1,%eax
  8008ab:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ae:	38 ca                	cmp    %cl,%dl
  8008b0:	74 04                	je     8008b6 <strfind+0x1a>
  8008b2:	84 d2                	test   %dl,%dl
  8008b4:	75 f2                	jne    8008a8 <strfind+0xc>
			break;
	return (char *) s;
}
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	57                   	push   %edi
  8008bc:	56                   	push   %esi
  8008bd:	53                   	push   %ebx
  8008be:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c4:	85 c9                	test   %ecx,%ecx
  8008c6:	74 36                	je     8008fe <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ce:	75 28                	jne    8008f8 <memset+0x40>
  8008d0:	f6 c1 03             	test   $0x3,%cl
  8008d3:	75 23                	jne    8008f8 <memset+0x40>
		c &= 0xFF;
  8008d5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d9:	89 d3                	mov    %edx,%ebx
  8008db:	c1 e3 08             	shl    $0x8,%ebx
  8008de:	89 d6                	mov    %edx,%esi
  8008e0:	c1 e6 18             	shl    $0x18,%esi
  8008e3:	89 d0                	mov    %edx,%eax
  8008e5:	c1 e0 10             	shl    $0x10,%eax
  8008e8:	09 f0                	or     %esi,%eax
  8008ea:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008ec:	89 d8                	mov    %ebx,%eax
  8008ee:	09 d0                	or     %edx,%eax
  8008f0:	c1 e9 02             	shr    $0x2,%ecx
  8008f3:	fc                   	cld    
  8008f4:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f6:	eb 06                	jmp    8008fe <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fb:	fc                   	cld    
  8008fc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008fe:	89 f8                	mov    %edi,%eax
  800900:	5b                   	pop    %ebx
  800901:	5e                   	pop    %esi
  800902:	5f                   	pop    %edi
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	57                   	push   %edi
  800909:	56                   	push   %esi
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800910:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800913:	39 c6                	cmp    %eax,%esi
  800915:	73 35                	jae    80094c <memmove+0x47>
  800917:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091a:	39 d0                	cmp    %edx,%eax
  80091c:	73 2e                	jae    80094c <memmove+0x47>
		s += n;
		d += n;
  80091e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800921:	89 d6                	mov    %edx,%esi
  800923:	09 fe                	or     %edi,%esi
  800925:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092b:	75 13                	jne    800940 <memmove+0x3b>
  80092d:	f6 c1 03             	test   $0x3,%cl
  800930:	75 0e                	jne    800940 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800932:	83 ef 04             	sub    $0x4,%edi
  800935:	8d 72 fc             	lea    -0x4(%edx),%esi
  800938:	c1 e9 02             	shr    $0x2,%ecx
  80093b:	fd                   	std    
  80093c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093e:	eb 09                	jmp    800949 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800940:	83 ef 01             	sub    $0x1,%edi
  800943:	8d 72 ff             	lea    -0x1(%edx),%esi
  800946:	fd                   	std    
  800947:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800949:	fc                   	cld    
  80094a:	eb 1d                	jmp    800969 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094c:	89 f2                	mov    %esi,%edx
  80094e:	09 c2                	or     %eax,%edx
  800950:	f6 c2 03             	test   $0x3,%dl
  800953:	75 0f                	jne    800964 <memmove+0x5f>
  800955:	f6 c1 03             	test   $0x3,%cl
  800958:	75 0a                	jne    800964 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80095a:	c1 e9 02             	shr    $0x2,%ecx
  80095d:	89 c7                	mov    %eax,%edi
  80095f:	fc                   	cld    
  800960:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800962:	eb 05                	jmp    800969 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800964:	89 c7                	mov    %eax,%edi
  800966:	fc                   	cld    
  800967:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800969:	5e                   	pop    %esi
  80096a:	5f                   	pop    %edi
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800970:	ff 75 10             	pushl  0x10(%ebp)
  800973:	ff 75 0c             	pushl  0xc(%ebp)
  800976:	ff 75 08             	pushl  0x8(%ebp)
  800979:	e8 87 ff ff ff       	call   800905 <memmove>
}
  80097e:	c9                   	leave  
  80097f:	c3                   	ret    

00800980 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	56                   	push   %esi
  800984:	53                   	push   %ebx
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098b:	89 c6                	mov    %eax,%esi
  80098d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800990:	eb 1a                	jmp    8009ac <memcmp+0x2c>
		if (*s1 != *s2)
  800992:	0f b6 08             	movzbl (%eax),%ecx
  800995:	0f b6 1a             	movzbl (%edx),%ebx
  800998:	38 d9                	cmp    %bl,%cl
  80099a:	74 0a                	je     8009a6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80099c:	0f b6 c1             	movzbl %cl,%eax
  80099f:	0f b6 db             	movzbl %bl,%ebx
  8009a2:	29 d8                	sub    %ebx,%eax
  8009a4:	eb 0f                	jmp    8009b5 <memcmp+0x35>
		s1++, s2++;
  8009a6:	83 c0 01             	add    $0x1,%eax
  8009a9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ac:	39 f0                	cmp    %esi,%eax
  8009ae:	75 e2                	jne    800992 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b5:	5b                   	pop    %ebx
  8009b6:	5e                   	pop    %esi
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	53                   	push   %ebx
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c0:	89 c1                	mov    %eax,%ecx
  8009c2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c9:	eb 0a                	jmp    8009d5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cb:	0f b6 10             	movzbl (%eax),%edx
  8009ce:	39 da                	cmp    %ebx,%edx
  8009d0:	74 07                	je     8009d9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d2:	83 c0 01             	add    $0x1,%eax
  8009d5:	39 c8                	cmp    %ecx,%eax
  8009d7:	72 f2                	jb     8009cb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d9:	5b                   	pop    %ebx
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	57                   	push   %edi
  8009e0:	56                   	push   %esi
  8009e1:	53                   	push   %ebx
  8009e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e8:	eb 03                	jmp    8009ed <strtol+0x11>
		s++;
  8009ea:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ed:	0f b6 01             	movzbl (%ecx),%eax
  8009f0:	3c 20                	cmp    $0x20,%al
  8009f2:	74 f6                	je     8009ea <strtol+0xe>
  8009f4:	3c 09                	cmp    $0x9,%al
  8009f6:	74 f2                	je     8009ea <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f8:	3c 2b                	cmp    $0x2b,%al
  8009fa:	75 0a                	jne    800a06 <strtol+0x2a>
		s++;
  8009fc:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ff:	bf 00 00 00 00       	mov    $0x0,%edi
  800a04:	eb 11                	jmp    800a17 <strtol+0x3b>
  800a06:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a0b:	3c 2d                	cmp    $0x2d,%al
  800a0d:	75 08                	jne    800a17 <strtol+0x3b>
		s++, neg = 1;
  800a0f:	83 c1 01             	add    $0x1,%ecx
  800a12:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a17:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a1d:	75 15                	jne    800a34 <strtol+0x58>
  800a1f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a22:	75 10                	jne    800a34 <strtol+0x58>
  800a24:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a28:	75 7c                	jne    800aa6 <strtol+0xca>
		s += 2, base = 16;
  800a2a:	83 c1 02             	add    $0x2,%ecx
  800a2d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a32:	eb 16                	jmp    800a4a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a34:	85 db                	test   %ebx,%ebx
  800a36:	75 12                	jne    800a4a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a38:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a40:	75 08                	jne    800a4a <strtol+0x6e>
		s++, base = 8;
  800a42:	83 c1 01             	add    $0x1,%ecx
  800a45:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a52:	0f b6 11             	movzbl (%ecx),%edx
  800a55:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a58:	89 f3                	mov    %esi,%ebx
  800a5a:	80 fb 09             	cmp    $0x9,%bl
  800a5d:	77 08                	ja     800a67 <strtol+0x8b>
			dig = *s - '0';
  800a5f:	0f be d2             	movsbl %dl,%edx
  800a62:	83 ea 30             	sub    $0x30,%edx
  800a65:	eb 22                	jmp    800a89 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a67:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a6a:	89 f3                	mov    %esi,%ebx
  800a6c:	80 fb 19             	cmp    $0x19,%bl
  800a6f:	77 08                	ja     800a79 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a71:	0f be d2             	movsbl %dl,%edx
  800a74:	83 ea 57             	sub    $0x57,%edx
  800a77:	eb 10                	jmp    800a89 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a79:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a7c:	89 f3                	mov    %esi,%ebx
  800a7e:	80 fb 19             	cmp    $0x19,%bl
  800a81:	77 16                	ja     800a99 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a83:	0f be d2             	movsbl %dl,%edx
  800a86:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a89:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a8c:	7d 0b                	jge    800a99 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a8e:	83 c1 01             	add    $0x1,%ecx
  800a91:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a95:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a97:	eb b9                	jmp    800a52 <strtol+0x76>

	if (endptr)
  800a99:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9d:	74 0d                	je     800aac <strtol+0xd0>
		*endptr = (char *) s;
  800a9f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa2:	89 0e                	mov    %ecx,(%esi)
  800aa4:	eb 06                	jmp    800aac <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa6:	85 db                	test   %ebx,%ebx
  800aa8:	74 98                	je     800a42 <strtol+0x66>
  800aaa:	eb 9e                	jmp    800a4a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aac:	89 c2                	mov    %eax,%edx
  800aae:	f7 da                	neg    %edx
  800ab0:	85 ff                	test   %edi,%edi
  800ab2:	0f 45 c2             	cmovne %edx,%eax
}
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac8:	8b 55 08             	mov    0x8(%ebp),%edx
  800acb:	89 c3                	mov    %eax,%ebx
  800acd:	89 c7                	mov    %eax,%edi
  800acf:	89 c6                	mov    %eax,%esi
  800ad1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad3:	5b                   	pop    %ebx
  800ad4:	5e                   	pop    %esi
  800ad5:	5f                   	pop    %edi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ade:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae8:	89 d1                	mov    %edx,%ecx
  800aea:	89 d3                	mov    %edx,%ebx
  800aec:	89 d7                	mov    %edx,%edi
  800aee:	89 d6                	mov    %edx,%esi
  800af0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5f                   	pop    %edi
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b00:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b05:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0d:	89 cb                	mov    %ecx,%ebx
  800b0f:	89 cf                	mov    %ecx,%edi
  800b11:	89 ce                	mov    %ecx,%esi
  800b13:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b15:	85 c0                	test   %eax,%eax
  800b17:	7e 17                	jle    800b30 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b19:	83 ec 0c             	sub    $0xc,%esp
  800b1c:	50                   	push   %eax
  800b1d:	6a 03                	push   $0x3
  800b1f:	68 5f 22 80 00       	push   $0x80225f
  800b24:	6a 23                	push   $0x23
  800b26:	68 7c 22 80 00       	push   $0x80227c
  800b2b:	e8 e5 f5 ff ff       	call   800115 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800b3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b43:	b8 02 00 00 00       	mov    $0x2,%eax
  800b48:	89 d1                	mov    %edx,%ecx
  800b4a:	89 d3                	mov    %edx,%ebx
  800b4c:	89 d7                	mov    %edx,%edi
  800b4e:	89 d6                	mov    %edx,%esi
  800b50:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_yield>:

void
sys_yield(void)
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
  800b62:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b67:	89 d1                	mov    %edx,%ecx
  800b69:	89 d3                	mov    %edx,%ebx
  800b6b:	89 d7                	mov    %edx,%edi
  800b6d:	89 d6                	mov    %edx,%esi
  800b6f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800b7f:	be 00 00 00 00       	mov    $0x0,%esi
  800b84:	b8 04 00 00 00       	mov    $0x4,%eax
  800b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b92:	89 f7                	mov    %esi,%edi
  800b94:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b96:	85 c0                	test   %eax,%eax
  800b98:	7e 17                	jle    800bb1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9a:	83 ec 0c             	sub    $0xc,%esp
  800b9d:	50                   	push   %eax
  800b9e:	6a 04                	push   $0x4
  800ba0:	68 5f 22 80 00       	push   $0x80225f
  800ba5:	6a 23                	push   $0x23
  800ba7:	68 7c 22 80 00       	push   $0x80227c
  800bac:	e8 64 f5 ff ff       	call   800115 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	53                   	push   %ebx
  800bbf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bca:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd3:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	7e 17                	jle    800bf3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	50                   	push   %eax
  800be0:	6a 05                	push   $0x5
  800be2:	68 5f 22 80 00       	push   $0x80225f
  800be7:	6a 23                	push   $0x23
  800be9:	68 7c 22 80 00       	push   $0x80227c
  800bee:	e8 22 f5 ff ff       	call   800115 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c09:	b8 06 00 00 00       	mov    $0x6,%eax
  800c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c11:	8b 55 08             	mov    0x8(%ebp),%edx
  800c14:	89 df                	mov    %ebx,%edi
  800c16:	89 de                	mov    %ebx,%esi
  800c18:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	7e 17                	jle    800c35 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1e:	83 ec 0c             	sub    $0xc,%esp
  800c21:	50                   	push   %eax
  800c22:	6a 06                	push   $0x6
  800c24:	68 5f 22 80 00       	push   $0x80225f
  800c29:	6a 23                	push   $0x23
  800c2b:	68 7c 22 80 00       	push   $0x80227c
  800c30:	e8 e0 f4 ff ff       	call   800115 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4b:	b8 08 00 00 00       	mov    $0x8,%eax
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
  800c56:	89 df                	mov    %ebx,%edi
  800c58:	89 de                	mov    %ebx,%esi
  800c5a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	7e 17                	jle    800c77 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c60:	83 ec 0c             	sub    $0xc,%esp
  800c63:	50                   	push   %eax
  800c64:	6a 08                	push   $0x8
  800c66:	68 5f 22 80 00       	push   $0x80225f
  800c6b:	6a 23                	push   $0x23
  800c6d:	68 7c 22 80 00       	push   $0x80227c
  800c72:	e8 9e f4 ff ff       	call   800115 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
  800c85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8d:	b8 09 00 00 00       	mov    $0x9,%eax
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	89 df                	mov    %ebx,%edi
  800c9a:	89 de                	mov    %ebx,%esi
  800c9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9e:	85 c0                	test   %eax,%eax
  800ca0:	7e 17                	jle    800cb9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca2:	83 ec 0c             	sub    $0xc,%esp
  800ca5:	50                   	push   %eax
  800ca6:	6a 09                	push   $0x9
  800ca8:	68 5f 22 80 00       	push   $0x80225f
  800cad:	6a 23                	push   $0x23
  800caf:	68 7c 22 80 00       	push   $0x80227c
  800cb4:	e8 5c f4 ff ff       	call   800115 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	89 df                	mov    %ebx,%edi
  800cdc:	89 de                	mov    %ebx,%esi
  800cde:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7e 17                	jle    800cfb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce4:	83 ec 0c             	sub    $0xc,%esp
  800ce7:	50                   	push   %eax
  800ce8:	6a 0a                	push   $0xa
  800cea:	68 5f 22 80 00       	push   $0x80225f
  800cef:	6a 23                	push   $0x23
  800cf1:	68 7c 22 80 00       	push   $0x80227c
  800cf6:	e8 1a f4 ff ff       	call   800115 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d09:	be 00 00 00 00       	mov    $0x0,%esi
  800d0e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d1f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d34:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	89 cb                	mov    %ecx,%ebx
  800d3e:	89 cf                	mov    %ecx,%edi
  800d40:	89 ce                	mov    %ecx,%esi
  800d42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d44:	85 c0                	test   %eax,%eax
  800d46:	7e 17                	jle    800d5f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	50                   	push   %eax
  800d4c:	6a 0d                	push   $0xd
  800d4e:	68 5f 22 80 00       	push   $0x80225f
  800d53:	6a 23                	push   $0x23
  800d55:	68 7c 22 80 00       	push   $0x80227c
  800d5a:	e8 b6 f3 ff ff       	call   800115 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	53                   	push   %ebx
  800d6b:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d6e:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d75:	75 28                	jne    800d9f <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  800d77:	e8 bc fd ff ff       	call   800b38 <sys_getenvid>
  800d7c:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  800d7e:	83 ec 04             	sub    $0x4,%esp
  800d81:	6a 06                	push   $0x6
  800d83:	68 00 f0 bf ee       	push   $0xeebff000
  800d88:	50                   	push   %eax
  800d89:	e8 e8 fd ff ff       	call   800b76 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  800d8e:	83 c4 08             	add    $0x8,%esp
  800d91:	68 ac 0d 80 00       	push   $0x800dac
  800d96:	53                   	push   %ebx
  800d97:	e8 25 ff ff ff       	call   800cc1 <sys_env_set_pgfault_upcall>
  800d9c:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800da2:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800da7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800daa:	c9                   	leave  
  800dab:	c3                   	ret    

00800dac <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800dac:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800dad:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800db2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800db4:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  800db7:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  800db9:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  800dbc:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  800dbf:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  800dc2:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  800dc5:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  800dc8:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  800dcb:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  800dce:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  800dd1:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  800dd4:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  800dd7:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  800dda:	61                   	popa   
	popfl
  800ddb:	9d                   	popf   
	ret
  800ddc:	c3                   	ret    

00800ddd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800de0:	8b 45 08             	mov    0x8(%ebp),%eax
  800de3:	05 00 00 00 30       	add    $0x30000000,%eax
  800de8:	c1 e8 0c             	shr    $0xc,%eax
}
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    

00800ded <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800df0:	8b 45 08             	mov    0x8(%ebp),%eax
  800df3:	05 00 00 00 30       	add    $0x30000000,%eax
  800df8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dfd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e0f:	89 c2                	mov    %eax,%edx
  800e11:	c1 ea 16             	shr    $0x16,%edx
  800e14:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e1b:	f6 c2 01             	test   $0x1,%dl
  800e1e:	74 11                	je     800e31 <fd_alloc+0x2d>
  800e20:	89 c2                	mov    %eax,%edx
  800e22:	c1 ea 0c             	shr    $0xc,%edx
  800e25:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e2c:	f6 c2 01             	test   $0x1,%dl
  800e2f:	75 09                	jne    800e3a <fd_alloc+0x36>
			*fd_store = fd;
  800e31:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e33:	b8 00 00 00 00       	mov    $0x0,%eax
  800e38:	eb 17                	jmp    800e51 <fd_alloc+0x4d>
  800e3a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e3f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e44:	75 c9                	jne    800e0f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e46:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e4c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e59:	83 f8 1f             	cmp    $0x1f,%eax
  800e5c:	77 36                	ja     800e94 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e5e:	c1 e0 0c             	shl    $0xc,%eax
  800e61:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e66:	89 c2                	mov    %eax,%edx
  800e68:	c1 ea 16             	shr    $0x16,%edx
  800e6b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e72:	f6 c2 01             	test   $0x1,%dl
  800e75:	74 24                	je     800e9b <fd_lookup+0x48>
  800e77:	89 c2                	mov    %eax,%edx
  800e79:	c1 ea 0c             	shr    $0xc,%edx
  800e7c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e83:	f6 c2 01             	test   $0x1,%dl
  800e86:	74 1a                	je     800ea2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e88:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e8b:	89 02                	mov    %eax,(%edx)
	return 0;
  800e8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e92:	eb 13                	jmp    800ea7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e94:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e99:	eb 0c                	jmp    800ea7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e9b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea0:	eb 05                	jmp    800ea7 <fd_lookup+0x54>
  800ea2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	83 ec 08             	sub    $0x8,%esp
  800eaf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb2:	ba 0c 23 80 00       	mov    $0x80230c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800eb7:	eb 13                	jmp    800ecc <dev_lookup+0x23>
  800eb9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ebc:	39 08                	cmp    %ecx,(%eax)
  800ebe:	75 0c                	jne    800ecc <dev_lookup+0x23>
			*dev = devtab[i];
  800ec0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec3:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ec5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eca:	eb 2e                	jmp    800efa <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ecc:	8b 02                	mov    (%edx),%eax
  800ece:	85 c0                	test   %eax,%eax
  800ed0:	75 e7                	jne    800eb9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ed2:	a1 04 40 80 00       	mov    0x804004,%eax
  800ed7:	8b 40 48             	mov    0x48(%eax),%eax
  800eda:	83 ec 04             	sub    $0x4,%esp
  800edd:	51                   	push   %ecx
  800ede:	50                   	push   %eax
  800edf:	68 8c 22 80 00       	push   $0x80228c
  800ee4:	e8 05 f3 ff ff       	call   8001ee <cprintf>
	*dev = 0;
  800ee9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eec:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ef2:	83 c4 10             	add    $0x10,%esp
  800ef5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800efa:	c9                   	leave  
  800efb:	c3                   	ret    

00800efc <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	56                   	push   %esi
  800f00:	53                   	push   %ebx
  800f01:	83 ec 10             	sub    $0x10,%esp
  800f04:	8b 75 08             	mov    0x8(%ebp),%esi
  800f07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f0d:	50                   	push   %eax
  800f0e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f14:	c1 e8 0c             	shr    $0xc,%eax
  800f17:	50                   	push   %eax
  800f18:	e8 36 ff ff ff       	call   800e53 <fd_lookup>
  800f1d:	83 c4 08             	add    $0x8,%esp
  800f20:	85 c0                	test   %eax,%eax
  800f22:	78 05                	js     800f29 <fd_close+0x2d>
	    || fd != fd2)
  800f24:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f27:	74 0c                	je     800f35 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f29:	84 db                	test   %bl,%bl
  800f2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f30:	0f 44 c2             	cmove  %edx,%eax
  800f33:	eb 41                	jmp    800f76 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f35:	83 ec 08             	sub    $0x8,%esp
  800f38:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f3b:	50                   	push   %eax
  800f3c:	ff 36                	pushl  (%esi)
  800f3e:	e8 66 ff ff ff       	call   800ea9 <dev_lookup>
  800f43:	89 c3                	mov    %eax,%ebx
  800f45:	83 c4 10             	add    $0x10,%esp
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	78 1a                	js     800f66 <fd_close+0x6a>
		if (dev->dev_close)
  800f4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f4f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f52:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f57:	85 c0                	test   %eax,%eax
  800f59:	74 0b                	je     800f66 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f5b:	83 ec 0c             	sub    $0xc,%esp
  800f5e:	56                   	push   %esi
  800f5f:	ff d0                	call   *%eax
  800f61:	89 c3                	mov    %eax,%ebx
  800f63:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f66:	83 ec 08             	sub    $0x8,%esp
  800f69:	56                   	push   %esi
  800f6a:	6a 00                	push   $0x0
  800f6c:	e8 8a fc ff ff       	call   800bfb <sys_page_unmap>
	return r;
  800f71:	83 c4 10             	add    $0x10,%esp
  800f74:	89 d8                	mov    %ebx,%eax
}
  800f76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f79:	5b                   	pop    %ebx
  800f7a:	5e                   	pop    %esi
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    

00800f7d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f86:	50                   	push   %eax
  800f87:	ff 75 08             	pushl  0x8(%ebp)
  800f8a:	e8 c4 fe ff ff       	call   800e53 <fd_lookup>
  800f8f:	83 c4 08             	add    $0x8,%esp
  800f92:	85 c0                	test   %eax,%eax
  800f94:	78 10                	js     800fa6 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f96:	83 ec 08             	sub    $0x8,%esp
  800f99:	6a 01                	push   $0x1
  800f9b:	ff 75 f4             	pushl  -0xc(%ebp)
  800f9e:	e8 59 ff ff ff       	call   800efc <fd_close>
  800fa3:	83 c4 10             	add    $0x10,%esp
}
  800fa6:	c9                   	leave  
  800fa7:	c3                   	ret    

00800fa8 <close_all>:

void
close_all(void)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	53                   	push   %ebx
  800fac:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800faf:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fb4:	83 ec 0c             	sub    $0xc,%esp
  800fb7:	53                   	push   %ebx
  800fb8:	e8 c0 ff ff ff       	call   800f7d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fbd:	83 c3 01             	add    $0x1,%ebx
  800fc0:	83 c4 10             	add    $0x10,%esp
  800fc3:	83 fb 20             	cmp    $0x20,%ebx
  800fc6:	75 ec                	jne    800fb4 <close_all+0xc>
		close(i);
}
  800fc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fcb:	c9                   	leave  
  800fcc:	c3                   	ret    

00800fcd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	57                   	push   %edi
  800fd1:	56                   	push   %esi
  800fd2:	53                   	push   %ebx
  800fd3:	83 ec 2c             	sub    $0x2c,%esp
  800fd6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fd9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fdc:	50                   	push   %eax
  800fdd:	ff 75 08             	pushl  0x8(%ebp)
  800fe0:	e8 6e fe ff ff       	call   800e53 <fd_lookup>
  800fe5:	83 c4 08             	add    $0x8,%esp
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	0f 88 c1 00 00 00    	js     8010b1 <dup+0xe4>
		return r;
	close(newfdnum);
  800ff0:	83 ec 0c             	sub    $0xc,%esp
  800ff3:	56                   	push   %esi
  800ff4:	e8 84 ff ff ff       	call   800f7d <close>

	newfd = INDEX2FD(newfdnum);
  800ff9:	89 f3                	mov    %esi,%ebx
  800ffb:	c1 e3 0c             	shl    $0xc,%ebx
  800ffe:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801004:	83 c4 04             	add    $0x4,%esp
  801007:	ff 75 e4             	pushl  -0x1c(%ebp)
  80100a:	e8 de fd ff ff       	call   800ded <fd2data>
  80100f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801011:	89 1c 24             	mov    %ebx,(%esp)
  801014:	e8 d4 fd ff ff       	call   800ded <fd2data>
  801019:	83 c4 10             	add    $0x10,%esp
  80101c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80101f:	89 f8                	mov    %edi,%eax
  801021:	c1 e8 16             	shr    $0x16,%eax
  801024:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80102b:	a8 01                	test   $0x1,%al
  80102d:	74 37                	je     801066 <dup+0x99>
  80102f:	89 f8                	mov    %edi,%eax
  801031:	c1 e8 0c             	shr    $0xc,%eax
  801034:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80103b:	f6 c2 01             	test   $0x1,%dl
  80103e:	74 26                	je     801066 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801040:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801047:	83 ec 0c             	sub    $0xc,%esp
  80104a:	25 07 0e 00 00       	and    $0xe07,%eax
  80104f:	50                   	push   %eax
  801050:	ff 75 d4             	pushl  -0x2c(%ebp)
  801053:	6a 00                	push   $0x0
  801055:	57                   	push   %edi
  801056:	6a 00                	push   $0x0
  801058:	e8 5c fb ff ff       	call   800bb9 <sys_page_map>
  80105d:	89 c7                	mov    %eax,%edi
  80105f:	83 c4 20             	add    $0x20,%esp
  801062:	85 c0                	test   %eax,%eax
  801064:	78 2e                	js     801094 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801066:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801069:	89 d0                	mov    %edx,%eax
  80106b:	c1 e8 0c             	shr    $0xc,%eax
  80106e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801075:	83 ec 0c             	sub    $0xc,%esp
  801078:	25 07 0e 00 00       	and    $0xe07,%eax
  80107d:	50                   	push   %eax
  80107e:	53                   	push   %ebx
  80107f:	6a 00                	push   $0x0
  801081:	52                   	push   %edx
  801082:	6a 00                	push   $0x0
  801084:	e8 30 fb ff ff       	call   800bb9 <sys_page_map>
  801089:	89 c7                	mov    %eax,%edi
  80108b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80108e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801090:	85 ff                	test   %edi,%edi
  801092:	79 1d                	jns    8010b1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801094:	83 ec 08             	sub    $0x8,%esp
  801097:	53                   	push   %ebx
  801098:	6a 00                	push   $0x0
  80109a:	e8 5c fb ff ff       	call   800bfb <sys_page_unmap>
	sys_page_unmap(0, nva);
  80109f:	83 c4 08             	add    $0x8,%esp
  8010a2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010a5:	6a 00                	push   $0x0
  8010a7:	e8 4f fb ff ff       	call   800bfb <sys_page_unmap>
	return r;
  8010ac:	83 c4 10             	add    $0x10,%esp
  8010af:	89 f8                	mov    %edi,%eax
}
  8010b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b4:	5b                   	pop    %ebx
  8010b5:	5e                   	pop    %esi
  8010b6:	5f                   	pop    %edi
  8010b7:	5d                   	pop    %ebp
  8010b8:	c3                   	ret    

008010b9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	53                   	push   %ebx
  8010bd:	83 ec 14             	sub    $0x14,%esp
  8010c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c6:	50                   	push   %eax
  8010c7:	53                   	push   %ebx
  8010c8:	e8 86 fd ff ff       	call   800e53 <fd_lookup>
  8010cd:	83 c4 08             	add    $0x8,%esp
  8010d0:	89 c2                	mov    %eax,%edx
  8010d2:	85 c0                	test   %eax,%eax
  8010d4:	78 6d                	js     801143 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d6:	83 ec 08             	sub    $0x8,%esp
  8010d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010dc:	50                   	push   %eax
  8010dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e0:	ff 30                	pushl  (%eax)
  8010e2:	e8 c2 fd ff ff       	call   800ea9 <dev_lookup>
  8010e7:	83 c4 10             	add    $0x10,%esp
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	78 4c                	js     80113a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010f1:	8b 42 08             	mov    0x8(%edx),%eax
  8010f4:	83 e0 03             	and    $0x3,%eax
  8010f7:	83 f8 01             	cmp    $0x1,%eax
  8010fa:	75 21                	jne    80111d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010fc:	a1 04 40 80 00       	mov    0x804004,%eax
  801101:	8b 40 48             	mov    0x48(%eax),%eax
  801104:	83 ec 04             	sub    $0x4,%esp
  801107:	53                   	push   %ebx
  801108:	50                   	push   %eax
  801109:	68 d0 22 80 00       	push   $0x8022d0
  80110e:	e8 db f0 ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  801113:	83 c4 10             	add    $0x10,%esp
  801116:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80111b:	eb 26                	jmp    801143 <read+0x8a>
	}
	if (!dev->dev_read)
  80111d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801120:	8b 40 08             	mov    0x8(%eax),%eax
  801123:	85 c0                	test   %eax,%eax
  801125:	74 17                	je     80113e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801127:	83 ec 04             	sub    $0x4,%esp
  80112a:	ff 75 10             	pushl  0x10(%ebp)
  80112d:	ff 75 0c             	pushl  0xc(%ebp)
  801130:	52                   	push   %edx
  801131:	ff d0                	call   *%eax
  801133:	89 c2                	mov    %eax,%edx
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	eb 09                	jmp    801143 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80113a:	89 c2                	mov    %eax,%edx
  80113c:	eb 05                	jmp    801143 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80113e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801143:	89 d0                	mov    %edx,%eax
  801145:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801148:	c9                   	leave  
  801149:	c3                   	ret    

0080114a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
  80114d:	57                   	push   %edi
  80114e:	56                   	push   %esi
  80114f:	53                   	push   %ebx
  801150:	83 ec 0c             	sub    $0xc,%esp
  801153:	8b 7d 08             	mov    0x8(%ebp),%edi
  801156:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801159:	bb 00 00 00 00       	mov    $0x0,%ebx
  80115e:	eb 21                	jmp    801181 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801160:	83 ec 04             	sub    $0x4,%esp
  801163:	89 f0                	mov    %esi,%eax
  801165:	29 d8                	sub    %ebx,%eax
  801167:	50                   	push   %eax
  801168:	89 d8                	mov    %ebx,%eax
  80116a:	03 45 0c             	add    0xc(%ebp),%eax
  80116d:	50                   	push   %eax
  80116e:	57                   	push   %edi
  80116f:	e8 45 ff ff ff       	call   8010b9 <read>
		if (m < 0)
  801174:	83 c4 10             	add    $0x10,%esp
  801177:	85 c0                	test   %eax,%eax
  801179:	78 10                	js     80118b <readn+0x41>
			return m;
		if (m == 0)
  80117b:	85 c0                	test   %eax,%eax
  80117d:	74 0a                	je     801189 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80117f:	01 c3                	add    %eax,%ebx
  801181:	39 f3                	cmp    %esi,%ebx
  801183:	72 db                	jb     801160 <readn+0x16>
  801185:	89 d8                	mov    %ebx,%eax
  801187:	eb 02                	jmp    80118b <readn+0x41>
  801189:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80118b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118e:	5b                   	pop    %ebx
  80118f:	5e                   	pop    %esi
  801190:	5f                   	pop    %edi
  801191:	5d                   	pop    %ebp
  801192:	c3                   	ret    

00801193 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	53                   	push   %ebx
  801197:	83 ec 14             	sub    $0x14,%esp
  80119a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80119d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011a0:	50                   	push   %eax
  8011a1:	53                   	push   %ebx
  8011a2:	e8 ac fc ff ff       	call   800e53 <fd_lookup>
  8011a7:	83 c4 08             	add    $0x8,%esp
  8011aa:	89 c2                	mov    %eax,%edx
  8011ac:	85 c0                	test   %eax,%eax
  8011ae:	78 68                	js     801218 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b0:	83 ec 08             	sub    $0x8,%esp
  8011b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b6:	50                   	push   %eax
  8011b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ba:	ff 30                	pushl  (%eax)
  8011bc:	e8 e8 fc ff ff       	call   800ea9 <dev_lookup>
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	78 47                	js     80120f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011cf:	75 21                	jne    8011f2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8011d6:	8b 40 48             	mov    0x48(%eax),%eax
  8011d9:	83 ec 04             	sub    $0x4,%esp
  8011dc:	53                   	push   %ebx
  8011dd:	50                   	push   %eax
  8011de:	68 ec 22 80 00       	push   $0x8022ec
  8011e3:	e8 06 f0 ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  8011e8:	83 c4 10             	add    $0x10,%esp
  8011eb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011f0:	eb 26                	jmp    801218 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f5:	8b 52 0c             	mov    0xc(%edx),%edx
  8011f8:	85 d2                	test   %edx,%edx
  8011fa:	74 17                	je     801213 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011fc:	83 ec 04             	sub    $0x4,%esp
  8011ff:	ff 75 10             	pushl  0x10(%ebp)
  801202:	ff 75 0c             	pushl  0xc(%ebp)
  801205:	50                   	push   %eax
  801206:	ff d2                	call   *%edx
  801208:	89 c2                	mov    %eax,%edx
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	eb 09                	jmp    801218 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120f:	89 c2                	mov    %eax,%edx
  801211:	eb 05                	jmp    801218 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801213:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801218:	89 d0                	mov    %edx,%eax
  80121a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121d:	c9                   	leave  
  80121e:	c3                   	ret    

0080121f <seek>:

int
seek(int fdnum, off_t offset)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801225:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801228:	50                   	push   %eax
  801229:	ff 75 08             	pushl  0x8(%ebp)
  80122c:	e8 22 fc ff ff       	call   800e53 <fd_lookup>
  801231:	83 c4 08             	add    $0x8,%esp
  801234:	85 c0                	test   %eax,%eax
  801236:	78 0e                	js     801246 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801238:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80123b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801241:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801246:	c9                   	leave  
  801247:	c3                   	ret    

00801248 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	53                   	push   %ebx
  80124c:	83 ec 14             	sub    $0x14,%esp
  80124f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801252:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801255:	50                   	push   %eax
  801256:	53                   	push   %ebx
  801257:	e8 f7 fb ff ff       	call   800e53 <fd_lookup>
  80125c:	83 c4 08             	add    $0x8,%esp
  80125f:	89 c2                	mov    %eax,%edx
  801261:	85 c0                	test   %eax,%eax
  801263:	78 65                	js     8012ca <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801265:	83 ec 08             	sub    $0x8,%esp
  801268:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126b:	50                   	push   %eax
  80126c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126f:	ff 30                	pushl  (%eax)
  801271:	e8 33 fc ff ff       	call   800ea9 <dev_lookup>
  801276:	83 c4 10             	add    $0x10,%esp
  801279:	85 c0                	test   %eax,%eax
  80127b:	78 44                	js     8012c1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80127d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801280:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801284:	75 21                	jne    8012a7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801286:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80128b:	8b 40 48             	mov    0x48(%eax),%eax
  80128e:	83 ec 04             	sub    $0x4,%esp
  801291:	53                   	push   %ebx
  801292:	50                   	push   %eax
  801293:	68 ac 22 80 00       	push   $0x8022ac
  801298:	e8 51 ef ff ff       	call   8001ee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80129d:	83 c4 10             	add    $0x10,%esp
  8012a0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012a5:	eb 23                	jmp    8012ca <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012aa:	8b 52 18             	mov    0x18(%edx),%edx
  8012ad:	85 d2                	test   %edx,%edx
  8012af:	74 14                	je     8012c5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012b1:	83 ec 08             	sub    $0x8,%esp
  8012b4:	ff 75 0c             	pushl  0xc(%ebp)
  8012b7:	50                   	push   %eax
  8012b8:	ff d2                	call   *%edx
  8012ba:	89 c2                	mov    %eax,%edx
  8012bc:	83 c4 10             	add    $0x10,%esp
  8012bf:	eb 09                	jmp    8012ca <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c1:	89 c2                	mov    %eax,%edx
  8012c3:	eb 05                	jmp    8012ca <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012c5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012ca:	89 d0                	mov    %edx,%eax
  8012cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012cf:	c9                   	leave  
  8012d0:	c3                   	ret    

008012d1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012d1:	55                   	push   %ebp
  8012d2:	89 e5                	mov    %esp,%ebp
  8012d4:	53                   	push   %ebx
  8012d5:	83 ec 14             	sub    $0x14,%esp
  8012d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012de:	50                   	push   %eax
  8012df:	ff 75 08             	pushl  0x8(%ebp)
  8012e2:	e8 6c fb ff ff       	call   800e53 <fd_lookup>
  8012e7:	83 c4 08             	add    $0x8,%esp
  8012ea:	89 c2                	mov    %eax,%edx
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	78 58                	js     801348 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f0:	83 ec 08             	sub    $0x8,%esp
  8012f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f6:	50                   	push   %eax
  8012f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fa:	ff 30                	pushl  (%eax)
  8012fc:	e8 a8 fb ff ff       	call   800ea9 <dev_lookup>
  801301:	83 c4 10             	add    $0x10,%esp
  801304:	85 c0                	test   %eax,%eax
  801306:	78 37                	js     80133f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801308:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80130b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80130f:	74 32                	je     801343 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801311:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801314:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80131b:	00 00 00 
	stat->st_isdir = 0;
  80131e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801325:	00 00 00 
	stat->st_dev = dev;
  801328:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80132e:	83 ec 08             	sub    $0x8,%esp
  801331:	53                   	push   %ebx
  801332:	ff 75 f0             	pushl  -0x10(%ebp)
  801335:	ff 50 14             	call   *0x14(%eax)
  801338:	89 c2                	mov    %eax,%edx
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	eb 09                	jmp    801348 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133f:	89 c2                	mov    %eax,%edx
  801341:	eb 05                	jmp    801348 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801343:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801348:	89 d0                	mov    %edx,%eax
  80134a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80134d:	c9                   	leave  
  80134e:	c3                   	ret    

0080134f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	56                   	push   %esi
  801353:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801354:	83 ec 08             	sub    $0x8,%esp
  801357:	6a 00                	push   $0x0
  801359:	ff 75 08             	pushl  0x8(%ebp)
  80135c:	e8 0c 02 00 00       	call   80156d <open>
  801361:	89 c3                	mov    %eax,%ebx
  801363:	83 c4 10             	add    $0x10,%esp
  801366:	85 c0                	test   %eax,%eax
  801368:	78 1b                	js     801385 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80136a:	83 ec 08             	sub    $0x8,%esp
  80136d:	ff 75 0c             	pushl  0xc(%ebp)
  801370:	50                   	push   %eax
  801371:	e8 5b ff ff ff       	call   8012d1 <fstat>
  801376:	89 c6                	mov    %eax,%esi
	close(fd);
  801378:	89 1c 24             	mov    %ebx,(%esp)
  80137b:	e8 fd fb ff ff       	call   800f7d <close>
	return r;
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	89 f0                	mov    %esi,%eax
}
  801385:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801388:	5b                   	pop    %ebx
  801389:	5e                   	pop    %esi
  80138a:	5d                   	pop    %ebp
  80138b:	c3                   	ret    

0080138c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	56                   	push   %esi
  801390:	53                   	push   %ebx
  801391:	89 c6                	mov    %eax,%esi
  801393:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801395:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80139c:	75 12                	jne    8013b0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80139e:	83 ec 0c             	sub    $0xc,%esp
  8013a1:	6a 01                	push   $0x1
  8013a3:	e8 05 08 00 00       	call   801bad <ipc_find_env>
  8013a8:	a3 00 40 80 00       	mov    %eax,0x804000
  8013ad:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013b0:	6a 07                	push   $0x7
  8013b2:	68 00 50 80 00       	push   $0x805000
  8013b7:	56                   	push   %esi
  8013b8:	ff 35 00 40 80 00    	pushl  0x804000
  8013be:	e8 96 07 00 00       	call   801b59 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013c3:	83 c4 0c             	add    $0xc,%esp
  8013c6:	6a 00                	push   $0x0
  8013c8:	53                   	push   %ebx
  8013c9:	6a 00                	push   $0x0
  8013cb:	e8 20 07 00 00       	call   801af0 <ipc_recv>
}
  8013d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d3:	5b                   	pop    %ebx
  8013d4:	5e                   	pop    %esi
  8013d5:	5d                   	pop    %ebp
  8013d6:	c3                   	ret    

008013d7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e0:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013eb:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f5:	b8 02 00 00 00       	mov    $0x2,%eax
  8013fa:	e8 8d ff ff ff       	call   80138c <fsipc>
}
  8013ff:	c9                   	leave  
  801400:	c3                   	ret    

00801401 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801407:	8b 45 08             	mov    0x8(%ebp),%eax
  80140a:	8b 40 0c             	mov    0xc(%eax),%eax
  80140d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801412:	ba 00 00 00 00       	mov    $0x0,%edx
  801417:	b8 06 00 00 00       	mov    $0x6,%eax
  80141c:	e8 6b ff ff ff       	call   80138c <fsipc>
}
  801421:	c9                   	leave  
  801422:	c3                   	ret    

00801423 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	53                   	push   %ebx
  801427:	83 ec 04             	sub    $0x4,%esp
  80142a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80142d:	8b 45 08             	mov    0x8(%ebp),%eax
  801430:	8b 40 0c             	mov    0xc(%eax),%eax
  801433:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801438:	ba 00 00 00 00       	mov    $0x0,%edx
  80143d:	b8 05 00 00 00       	mov    $0x5,%eax
  801442:	e8 45 ff ff ff       	call   80138c <fsipc>
  801447:	85 c0                	test   %eax,%eax
  801449:	78 2c                	js     801477 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80144b:	83 ec 08             	sub    $0x8,%esp
  80144e:	68 00 50 80 00       	push   $0x805000
  801453:	53                   	push   %ebx
  801454:	e8 1a f3 ff ff       	call   800773 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801459:	a1 80 50 80 00       	mov    0x805080,%eax
  80145e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801464:	a1 84 50 80 00       	mov    0x805084,%eax
  801469:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801477:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147a:	c9                   	leave  
  80147b:	c3                   	ret    

0080147c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	53                   	push   %ebx
  801480:	83 ec 08             	sub    $0x8,%esp
  801483:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801486:	8b 55 08             	mov    0x8(%ebp),%edx
  801489:	8b 52 0c             	mov    0xc(%edx),%edx
  80148c:	89 15 00 50 80 00    	mov    %edx,0x805000
  801492:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801497:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80149c:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  80149f:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8014a5:	53                   	push   %ebx
  8014a6:	ff 75 0c             	pushl  0xc(%ebp)
  8014a9:	68 08 50 80 00       	push   $0x805008
  8014ae:	e8 52 f4 ff ff       	call   800905 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  8014b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b8:	b8 04 00 00 00       	mov    $0x4,%eax
  8014bd:	e8 ca fe ff ff       	call   80138c <fsipc>
  8014c2:	83 c4 10             	add    $0x10,%esp
  8014c5:	85 c0                	test   %eax,%eax
  8014c7:	78 1d                	js     8014e6 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  8014c9:	39 d8                	cmp    %ebx,%eax
  8014cb:	76 19                	jbe    8014e6 <devfile_write+0x6a>
  8014cd:	68 1c 23 80 00       	push   $0x80231c
  8014d2:	68 28 23 80 00       	push   $0x802328
  8014d7:	68 a5 00 00 00       	push   $0xa5
  8014dc:	68 3d 23 80 00       	push   $0x80233d
  8014e1:	e8 2f ec ff ff       	call   800115 <_panic>
	return r;
}
  8014e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e9:	c9                   	leave  
  8014ea:	c3                   	ret    

008014eb <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
  8014ee:	56                   	push   %esi
  8014ef:	53                   	push   %ebx
  8014f0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014fe:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801504:	ba 00 00 00 00       	mov    $0x0,%edx
  801509:	b8 03 00 00 00       	mov    $0x3,%eax
  80150e:	e8 79 fe ff ff       	call   80138c <fsipc>
  801513:	89 c3                	mov    %eax,%ebx
  801515:	85 c0                	test   %eax,%eax
  801517:	78 4b                	js     801564 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801519:	39 c6                	cmp    %eax,%esi
  80151b:	73 16                	jae    801533 <devfile_read+0x48>
  80151d:	68 48 23 80 00       	push   $0x802348
  801522:	68 28 23 80 00       	push   $0x802328
  801527:	6a 7c                	push   $0x7c
  801529:	68 3d 23 80 00       	push   $0x80233d
  80152e:	e8 e2 eb ff ff       	call   800115 <_panic>
	assert(r <= PGSIZE);
  801533:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801538:	7e 16                	jle    801550 <devfile_read+0x65>
  80153a:	68 4f 23 80 00       	push   $0x80234f
  80153f:	68 28 23 80 00       	push   $0x802328
  801544:	6a 7d                	push   $0x7d
  801546:	68 3d 23 80 00       	push   $0x80233d
  80154b:	e8 c5 eb ff ff       	call   800115 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801550:	83 ec 04             	sub    $0x4,%esp
  801553:	50                   	push   %eax
  801554:	68 00 50 80 00       	push   $0x805000
  801559:	ff 75 0c             	pushl  0xc(%ebp)
  80155c:	e8 a4 f3 ff ff       	call   800905 <memmove>
	return r;
  801561:	83 c4 10             	add    $0x10,%esp
}
  801564:	89 d8                	mov    %ebx,%eax
  801566:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801569:	5b                   	pop    %ebx
  80156a:	5e                   	pop    %esi
  80156b:	5d                   	pop    %ebp
  80156c:	c3                   	ret    

0080156d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80156d:	55                   	push   %ebp
  80156e:	89 e5                	mov    %esp,%ebp
  801570:	53                   	push   %ebx
  801571:	83 ec 20             	sub    $0x20,%esp
  801574:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801577:	53                   	push   %ebx
  801578:	e8 bd f1 ff ff       	call   80073a <strlen>
  80157d:	83 c4 10             	add    $0x10,%esp
  801580:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801585:	7f 67                	jg     8015ee <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801587:	83 ec 0c             	sub    $0xc,%esp
  80158a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158d:	50                   	push   %eax
  80158e:	e8 71 f8 ff ff       	call   800e04 <fd_alloc>
  801593:	83 c4 10             	add    $0x10,%esp
		return r;
  801596:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801598:	85 c0                	test   %eax,%eax
  80159a:	78 57                	js     8015f3 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80159c:	83 ec 08             	sub    $0x8,%esp
  80159f:	53                   	push   %ebx
  8015a0:	68 00 50 80 00       	push   $0x805000
  8015a5:	e8 c9 f1 ff ff       	call   800773 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015ad:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b5:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ba:	e8 cd fd ff ff       	call   80138c <fsipc>
  8015bf:	89 c3                	mov    %eax,%ebx
  8015c1:	83 c4 10             	add    $0x10,%esp
  8015c4:	85 c0                	test   %eax,%eax
  8015c6:	79 14                	jns    8015dc <open+0x6f>
		fd_close(fd, 0);
  8015c8:	83 ec 08             	sub    $0x8,%esp
  8015cb:	6a 00                	push   $0x0
  8015cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d0:	e8 27 f9 ff ff       	call   800efc <fd_close>
		return r;
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	89 da                	mov    %ebx,%edx
  8015da:	eb 17                	jmp    8015f3 <open+0x86>
	}

	return fd2num(fd);
  8015dc:	83 ec 0c             	sub    $0xc,%esp
  8015df:	ff 75 f4             	pushl  -0xc(%ebp)
  8015e2:	e8 f6 f7 ff ff       	call   800ddd <fd2num>
  8015e7:	89 c2                	mov    %eax,%edx
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	eb 05                	jmp    8015f3 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015ee:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015f3:	89 d0                	mov    %edx,%eax
  8015f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f8:	c9                   	leave  
  8015f9:	c3                   	ret    

008015fa <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015fa:	55                   	push   %ebp
  8015fb:	89 e5                	mov    %esp,%ebp
  8015fd:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801600:	ba 00 00 00 00       	mov    $0x0,%edx
  801605:	b8 08 00 00 00       	mov    $0x8,%eax
  80160a:	e8 7d fd ff ff       	call   80138c <fsipc>
}
  80160f:	c9                   	leave  
  801610:	c3                   	ret    

00801611 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801611:	55                   	push   %ebp
  801612:	89 e5                	mov    %esp,%ebp
  801614:	56                   	push   %esi
  801615:	53                   	push   %ebx
  801616:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801619:	83 ec 0c             	sub    $0xc,%esp
  80161c:	ff 75 08             	pushl  0x8(%ebp)
  80161f:	e8 c9 f7 ff ff       	call   800ded <fd2data>
  801624:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801626:	83 c4 08             	add    $0x8,%esp
  801629:	68 5b 23 80 00       	push   $0x80235b
  80162e:	53                   	push   %ebx
  80162f:	e8 3f f1 ff ff       	call   800773 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801634:	8b 46 04             	mov    0x4(%esi),%eax
  801637:	2b 06                	sub    (%esi),%eax
  801639:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80163f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801646:	00 00 00 
	stat->st_dev = &devpipe;
  801649:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801650:	30 80 00 
	return 0;
}
  801653:	b8 00 00 00 00       	mov    $0x0,%eax
  801658:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80165b:	5b                   	pop    %ebx
  80165c:	5e                   	pop    %esi
  80165d:	5d                   	pop    %ebp
  80165e:	c3                   	ret    

0080165f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	53                   	push   %ebx
  801663:	83 ec 0c             	sub    $0xc,%esp
  801666:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801669:	53                   	push   %ebx
  80166a:	6a 00                	push   $0x0
  80166c:	e8 8a f5 ff ff       	call   800bfb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801671:	89 1c 24             	mov    %ebx,(%esp)
  801674:	e8 74 f7 ff ff       	call   800ded <fd2data>
  801679:	83 c4 08             	add    $0x8,%esp
  80167c:	50                   	push   %eax
  80167d:	6a 00                	push   $0x0
  80167f:	e8 77 f5 ff ff       	call   800bfb <sys_page_unmap>
}
  801684:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801687:	c9                   	leave  
  801688:	c3                   	ret    

00801689 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801689:	55                   	push   %ebp
  80168a:	89 e5                	mov    %esp,%ebp
  80168c:	57                   	push   %edi
  80168d:	56                   	push   %esi
  80168e:	53                   	push   %ebx
  80168f:	83 ec 1c             	sub    $0x1c,%esp
  801692:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801695:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801697:	a1 04 40 80 00       	mov    0x804004,%eax
  80169c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80169f:	83 ec 0c             	sub    $0xc,%esp
  8016a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8016a5:	e8 3c 05 00 00       	call   801be6 <pageref>
  8016aa:	89 c3                	mov    %eax,%ebx
  8016ac:	89 3c 24             	mov    %edi,(%esp)
  8016af:	e8 32 05 00 00       	call   801be6 <pageref>
  8016b4:	83 c4 10             	add    $0x10,%esp
  8016b7:	39 c3                	cmp    %eax,%ebx
  8016b9:	0f 94 c1             	sete   %cl
  8016bc:	0f b6 c9             	movzbl %cl,%ecx
  8016bf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016c2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016c8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016cb:	39 ce                	cmp    %ecx,%esi
  8016cd:	74 1b                	je     8016ea <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8016cf:	39 c3                	cmp    %eax,%ebx
  8016d1:	75 c4                	jne    801697 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016d3:	8b 42 58             	mov    0x58(%edx),%eax
  8016d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016d9:	50                   	push   %eax
  8016da:	56                   	push   %esi
  8016db:	68 62 23 80 00       	push   $0x802362
  8016e0:	e8 09 eb ff ff       	call   8001ee <cprintf>
  8016e5:	83 c4 10             	add    $0x10,%esp
  8016e8:	eb ad                	jmp    801697 <_pipeisclosed+0xe>
	}
}
  8016ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f0:	5b                   	pop    %ebx
  8016f1:	5e                   	pop    %esi
  8016f2:	5f                   	pop    %edi
  8016f3:	5d                   	pop    %ebp
  8016f4:	c3                   	ret    

008016f5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	57                   	push   %edi
  8016f9:	56                   	push   %esi
  8016fa:	53                   	push   %ebx
  8016fb:	83 ec 28             	sub    $0x28,%esp
  8016fe:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801701:	56                   	push   %esi
  801702:	e8 e6 f6 ff ff       	call   800ded <fd2data>
  801707:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801709:	83 c4 10             	add    $0x10,%esp
  80170c:	bf 00 00 00 00       	mov    $0x0,%edi
  801711:	eb 4b                	jmp    80175e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801713:	89 da                	mov    %ebx,%edx
  801715:	89 f0                	mov    %esi,%eax
  801717:	e8 6d ff ff ff       	call   801689 <_pipeisclosed>
  80171c:	85 c0                	test   %eax,%eax
  80171e:	75 48                	jne    801768 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801720:	e8 32 f4 ff ff       	call   800b57 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801725:	8b 43 04             	mov    0x4(%ebx),%eax
  801728:	8b 0b                	mov    (%ebx),%ecx
  80172a:	8d 51 20             	lea    0x20(%ecx),%edx
  80172d:	39 d0                	cmp    %edx,%eax
  80172f:	73 e2                	jae    801713 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801731:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801734:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801738:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80173b:	89 c2                	mov    %eax,%edx
  80173d:	c1 fa 1f             	sar    $0x1f,%edx
  801740:	89 d1                	mov    %edx,%ecx
  801742:	c1 e9 1b             	shr    $0x1b,%ecx
  801745:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801748:	83 e2 1f             	and    $0x1f,%edx
  80174b:	29 ca                	sub    %ecx,%edx
  80174d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801751:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801755:	83 c0 01             	add    $0x1,%eax
  801758:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80175b:	83 c7 01             	add    $0x1,%edi
  80175e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801761:	75 c2                	jne    801725 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801763:	8b 45 10             	mov    0x10(%ebp),%eax
  801766:	eb 05                	jmp    80176d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801768:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80176d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801770:	5b                   	pop    %ebx
  801771:	5e                   	pop    %esi
  801772:	5f                   	pop    %edi
  801773:	5d                   	pop    %ebp
  801774:	c3                   	ret    

00801775 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	57                   	push   %edi
  801779:	56                   	push   %esi
  80177a:	53                   	push   %ebx
  80177b:	83 ec 18             	sub    $0x18,%esp
  80177e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801781:	57                   	push   %edi
  801782:	e8 66 f6 ff ff       	call   800ded <fd2data>
  801787:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801789:	83 c4 10             	add    $0x10,%esp
  80178c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801791:	eb 3d                	jmp    8017d0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801793:	85 db                	test   %ebx,%ebx
  801795:	74 04                	je     80179b <devpipe_read+0x26>
				return i;
  801797:	89 d8                	mov    %ebx,%eax
  801799:	eb 44                	jmp    8017df <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80179b:	89 f2                	mov    %esi,%edx
  80179d:	89 f8                	mov    %edi,%eax
  80179f:	e8 e5 fe ff ff       	call   801689 <_pipeisclosed>
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	75 32                	jne    8017da <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017a8:	e8 aa f3 ff ff       	call   800b57 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017ad:	8b 06                	mov    (%esi),%eax
  8017af:	3b 46 04             	cmp    0x4(%esi),%eax
  8017b2:	74 df                	je     801793 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017b4:	99                   	cltd   
  8017b5:	c1 ea 1b             	shr    $0x1b,%edx
  8017b8:	01 d0                	add    %edx,%eax
  8017ba:	83 e0 1f             	and    $0x1f,%eax
  8017bd:	29 d0                	sub    %edx,%eax
  8017bf:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017c7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017ca:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017cd:	83 c3 01             	add    $0x1,%ebx
  8017d0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017d3:	75 d8                	jne    8017ad <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8017d8:	eb 05                	jmp    8017df <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017da:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e2:	5b                   	pop    %ebx
  8017e3:	5e                   	pop    %esi
  8017e4:	5f                   	pop    %edi
  8017e5:	5d                   	pop    %ebp
  8017e6:	c3                   	ret    

008017e7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	56                   	push   %esi
  8017eb:	53                   	push   %ebx
  8017ec:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f2:	50                   	push   %eax
  8017f3:	e8 0c f6 ff ff       	call   800e04 <fd_alloc>
  8017f8:	83 c4 10             	add    $0x10,%esp
  8017fb:	89 c2                	mov    %eax,%edx
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	0f 88 2c 01 00 00    	js     801931 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801805:	83 ec 04             	sub    $0x4,%esp
  801808:	68 07 04 00 00       	push   $0x407
  80180d:	ff 75 f4             	pushl  -0xc(%ebp)
  801810:	6a 00                	push   $0x0
  801812:	e8 5f f3 ff ff       	call   800b76 <sys_page_alloc>
  801817:	83 c4 10             	add    $0x10,%esp
  80181a:	89 c2                	mov    %eax,%edx
  80181c:	85 c0                	test   %eax,%eax
  80181e:	0f 88 0d 01 00 00    	js     801931 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801824:	83 ec 0c             	sub    $0xc,%esp
  801827:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80182a:	50                   	push   %eax
  80182b:	e8 d4 f5 ff ff       	call   800e04 <fd_alloc>
  801830:	89 c3                	mov    %eax,%ebx
  801832:	83 c4 10             	add    $0x10,%esp
  801835:	85 c0                	test   %eax,%eax
  801837:	0f 88 e2 00 00 00    	js     80191f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80183d:	83 ec 04             	sub    $0x4,%esp
  801840:	68 07 04 00 00       	push   $0x407
  801845:	ff 75 f0             	pushl  -0x10(%ebp)
  801848:	6a 00                	push   $0x0
  80184a:	e8 27 f3 ff ff       	call   800b76 <sys_page_alloc>
  80184f:	89 c3                	mov    %eax,%ebx
  801851:	83 c4 10             	add    $0x10,%esp
  801854:	85 c0                	test   %eax,%eax
  801856:	0f 88 c3 00 00 00    	js     80191f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80185c:	83 ec 0c             	sub    $0xc,%esp
  80185f:	ff 75 f4             	pushl  -0xc(%ebp)
  801862:	e8 86 f5 ff ff       	call   800ded <fd2data>
  801867:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801869:	83 c4 0c             	add    $0xc,%esp
  80186c:	68 07 04 00 00       	push   $0x407
  801871:	50                   	push   %eax
  801872:	6a 00                	push   $0x0
  801874:	e8 fd f2 ff ff       	call   800b76 <sys_page_alloc>
  801879:	89 c3                	mov    %eax,%ebx
  80187b:	83 c4 10             	add    $0x10,%esp
  80187e:	85 c0                	test   %eax,%eax
  801880:	0f 88 89 00 00 00    	js     80190f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801886:	83 ec 0c             	sub    $0xc,%esp
  801889:	ff 75 f0             	pushl  -0x10(%ebp)
  80188c:	e8 5c f5 ff ff       	call   800ded <fd2data>
  801891:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801898:	50                   	push   %eax
  801899:	6a 00                	push   $0x0
  80189b:	56                   	push   %esi
  80189c:	6a 00                	push   $0x0
  80189e:	e8 16 f3 ff ff       	call   800bb9 <sys_page_map>
  8018a3:	89 c3                	mov    %eax,%ebx
  8018a5:	83 c4 20             	add    $0x20,%esp
  8018a8:	85 c0                	test   %eax,%eax
  8018aa:	78 55                	js     801901 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018ac:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ba:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018c1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ca:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018cf:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018d6:	83 ec 0c             	sub    $0xc,%esp
  8018d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018dc:	e8 fc f4 ff ff       	call   800ddd <fd2num>
  8018e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018e4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018e6:	83 c4 04             	add    $0x4,%esp
  8018e9:	ff 75 f0             	pushl  -0x10(%ebp)
  8018ec:	e8 ec f4 ff ff       	call   800ddd <fd2num>
  8018f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018f4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018f7:	83 c4 10             	add    $0x10,%esp
  8018fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ff:	eb 30                	jmp    801931 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801901:	83 ec 08             	sub    $0x8,%esp
  801904:	56                   	push   %esi
  801905:	6a 00                	push   $0x0
  801907:	e8 ef f2 ff ff       	call   800bfb <sys_page_unmap>
  80190c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80190f:	83 ec 08             	sub    $0x8,%esp
  801912:	ff 75 f0             	pushl  -0x10(%ebp)
  801915:	6a 00                	push   $0x0
  801917:	e8 df f2 ff ff       	call   800bfb <sys_page_unmap>
  80191c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80191f:	83 ec 08             	sub    $0x8,%esp
  801922:	ff 75 f4             	pushl  -0xc(%ebp)
  801925:	6a 00                	push   $0x0
  801927:	e8 cf f2 ff ff       	call   800bfb <sys_page_unmap>
  80192c:	83 c4 10             	add    $0x10,%esp
  80192f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801931:	89 d0                	mov    %edx,%eax
  801933:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801936:	5b                   	pop    %ebx
  801937:	5e                   	pop    %esi
  801938:	5d                   	pop    %ebp
  801939:	c3                   	ret    

0080193a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801940:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801943:	50                   	push   %eax
  801944:	ff 75 08             	pushl  0x8(%ebp)
  801947:	e8 07 f5 ff ff       	call   800e53 <fd_lookup>
  80194c:	83 c4 10             	add    $0x10,%esp
  80194f:	85 c0                	test   %eax,%eax
  801951:	78 18                	js     80196b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801953:	83 ec 0c             	sub    $0xc,%esp
  801956:	ff 75 f4             	pushl  -0xc(%ebp)
  801959:	e8 8f f4 ff ff       	call   800ded <fd2data>
	return _pipeisclosed(fd, p);
  80195e:	89 c2                	mov    %eax,%edx
  801960:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801963:	e8 21 fd ff ff       	call   801689 <_pipeisclosed>
  801968:	83 c4 10             	add    $0x10,%esp
}
  80196b:	c9                   	leave  
  80196c:	c3                   	ret    

0080196d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80196d:	55                   	push   %ebp
  80196e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801970:	b8 00 00 00 00       	mov    $0x0,%eax
  801975:	5d                   	pop    %ebp
  801976:	c3                   	ret    

00801977 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801977:	55                   	push   %ebp
  801978:	89 e5                	mov    %esp,%ebp
  80197a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80197d:	68 7a 23 80 00       	push   $0x80237a
  801982:	ff 75 0c             	pushl  0xc(%ebp)
  801985:	e8 e9 ed ff ff       	call   800773 <strcpy>
	return 0;
}
  80198a:	b8 00 00 00 00       	mov    $0x0,%eax
  80198f:	c9                   	leave  
  801990:	c3                   	ret    

00801991 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	57                   	push   %edi
  801995:	56                   	push   %esi
  801996:	53                   	push   %ebx
  801997:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80199d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019a2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019a8:	eb 2d                	jmp    8019d7 <devcons_write+0x46>
		m = n - tot;
  8019aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019ad:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019af:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019b2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019b7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019ba:	83 ec 04             	sub    $0x4,%esp
  8019bd:	53                   	push   %ebx
  8019be:	03 45 0c             	add    0xc(%ebp),%eax
  8019c1:	50                   	push   %eax
  8019c2:	57                   	push   %edi
  8019c3:	e8 3d ef ff ff       	call   800905 <memmove>
		sys_cputs(buf, m);
  8019c8:	83 c4 08             	add    $0x8,%esp
  8019cb:	53                   	push   %ebx
  8019cc:	57                   	push   %edi
  8019cd:	e8 e8 f0 ff ff       	call   800aba <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019d2:	01 de                	add    %ebx,%esi
  8019d4:	83 c4 10             	add    $0x10,%esp
  8019d7:	89 f0                	mov    %esi,%eax
  8019d9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019dc:	72 cc                	jb     8019aa <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e1:	5b                   	pop    %ebx
  8019e2:	5e                   	pop    %esi
  8019e3:	5f                   	pop    %edi
  8019e4:	5d                   	pop    %ebp
  8019e5:	c3                   	ret    

008019e6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	83 ec 08             	sub    $0x8,%esp
  8019ec:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8019f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019f5:	74 2a                	je     801a21 <devcons_read+0x3b>
  8019f7:	eb 05                	jmp    8019fe <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019f9:	e8 59 f1 ff ff       	call   800b57 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019fe:	e8 d5 f0 ff ff       	call   800ad8 <sys_cgetc>
  801a03:	85 c0                	test   %eax,%eax
  801a05:	74 f2                	je     8019f9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a07:	85 c0                	test   %eax,%eax
  801a09:	78 16                	js     801a21 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a0b:	83 f8 04             	cmp    $0x4,%eax
  801a0e:	74 0c                	je     801a1c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a10:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a13:	88 02                	mov    %al,(%edx)
	return 1;
  801a15:	b8 01 00 00 00       	mov    $0x1,%eax
  801a1a:	eb 05                	jmp    801a21 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a1c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a21:	c9                   	leave  
  801a22:	c3                   	ret    

00801a23 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a23:	55                   	push   %ebp
  801a24:	89 e5                	mov    %esp,%ebp
  801a26:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a29:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a2f:	6a 01                	push   $0x1
  801a31:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a34:	50                   	push   %eax
  801a35:	e8 80 f0 ff ff       	call   800aba <sys_cputs>
}
  801a3a:	83 c4 10             	add    $0x10,%esp
  801a3d:	c9                   	leave  
  801a3e:	c3                   	ret    

00801a3f <getchar>:

int
getchar(void)
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a45:	6a 01                	push   $0x1
  801a47:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a4a:	50                   	push   %eax
  801a4b:	6a 00                	push   $0x0
  801a4d:	e8 67 f6 ff ff       	call   8010b9 <read>
	if (r < 0)
  801a52:	83 c4 10             	add    $0x10,%esp
  801a55:	85 c0                	test   %eax,%eax
  801a57:	78 0f                	js     801a68 <getchar+0x29>
		return r;
	if (r < 1)
  801a59:	85 c0                	test   %eax,%eax
  801a5b:	7e 06                	jle    801a63 <getchar+0x24>
		return -E_EOF;
	return c;
  801a5d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a61:	eb 05                	jmp    801a68 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a63:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a68:	c9                   	leave  
  801a69:	c3                   	ret    

00801a6a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a6a:	55                   	push   %ebp
  801a6b:	89 e5                	mov    %esp,%ebp
  801a6d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a73:	50                   	push   %eax
  801a74:	ff 75 08             	pushl  0x8(%ebp)
  801a77:	e8 d7 f3 ff ff       	call   800e53 <fd_lookup>
  801a7c:	83 c4 10             	add    $0x10,%esp
  801a7f:	85 c0                	test   %eax,%eax
  801a81:	78 11                	js     801a94 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a86:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a8c:	39 10                	cmp    %edx,(%eax)
  801a8e:	0f 94 c0             	sete   %al
  801a91:	0f b6 c0             	movzbl %al,%eax
}
  801a94:	c9                   	leave  
  801a95:	c3                   	ret    

00801a96 <opencons>:

int
opencons(void)
{
  801a96:	55                   	push   %ebp
  801a97:	89 e5                	mov    %esp,%ebp
  801a99:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a9f:	50                   	push   %eax
  801aa0:	e8 5f f3 ff ff       	call   800e04 <fd_alloc>
  801aa5:	83 c4 10             	add    $0x10,%esp
		return r;
  801aa8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801aaa:	85 c0                	test   %eax,%eax
  801aac:	78 3e                	js     801aec <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801aae:	83 ec 04             	sub    $0x4,%esp
  801ab1:	68 07 04 00 00       	push   $0x407
  801ab6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab9:	6a 00                	push   $0x0
  801abb:	e8 b6 f0 ff ff       	call   800b76 <sys_page_alloc>
  801ac0:	83 c4 10             	add    $0x10,%esp
		return r;
  801ac3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	78 23                	js     801aec <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ac9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ade:	83 ec 0c             	sub    $0xc,%esp
  801ae1:	50                   	push   %eax
  801ae2:	e8 f6 f2 ff ff       	call   800ddd <fd2num>
  801ae7:	89 c2                	mov    %eax,%edx
  801ae9:	83 c4 10             	add    $0x10,%esp
}
  801aec:	89 d0                	mov    %edx,%eax
  801aee:	c9                   	leave  
  801aef:	c3                   	ret    

00801af0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	56                   	push   %esi
  801af4:	53                   	push   %ebx
  801af5:	8b 75 08             	mov    0x8(%ebp),%esi
  801af8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801afe:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801b00:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801b05:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801b08:	83 ec 0c             	sub    $0xc,%esp
  801b0b:	50                   	push   %eax
  801b0c:	e8 15 f2 ff ff       	call   800d26 <sys_ipc_recv>

	if (r < 0) {
  801b11:	83 c4 10             	add    $0x10,%esp
  801b14:	85 c0                	test   %eax,%eax
  801b16:	79 16                	jns    801b2e <ipc_recv+0x3e>
		if (from_env_store)
  801b18:	85 f6                	test   %esi,%esi
  801b1a:	74 06                	je     801b22 <ipc_recv+0x32>
			*from_env_store = 0;
  801b1c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801b22:	85 db                	test   %ebx,%ebx
  801b24:	74 2c                	je     801b52 <ipc_recv+0x62>
			*perm_store = 0;
  801b26:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b2c:	eb 24                	jmp    801b52 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801b2e:	85 f6                	test   %esi,%esi
  801b30:	74 0a                	je     801b3c <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801b32:	a1 04 40 80 00       	mov    0x804004,%eax
  801b37:	8b 40 74             	mov    0x74(%eax),%eax
  801b3a:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801b3c:	85 db                	test   %ebx,%ebx
  801b3e:	74 0a                	je     801b4a <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801b40:	a1 04 40 80 00       	mov    0x804004,%eax
  801b45:	8b 40 78             	mov    0x78(%eax),%eax
  801b48:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801b4a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b4f:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801b52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b55:	5b                   	pop    %ebx
  801b56:	5e                   	pop    %esi
  801b57:	5d                   	pop    %ebp
  801b58:	c3                   	ret    

00801b59 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	57                   	push   %edi
  801b5d:	56                   	push   %esi
  801b5e:	53                   	push   %ebx
  801b5f:	83 ec 0c             	sub    $0xc,%esp
  801b62:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b65:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801b6b:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801b6d:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801b72:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801b75:	ff 75 14             	pushl  0x14(%ebp)
  801b78:	53                   	push   %ebx
  801b79:	56                   	push   %esi
  801b7a:	57                   	push   %edi
  801b7b:	e8 83 f1 ff ff       	call   800d03 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801b80:	83 c4 10             	add    $0x10,%esp
  801b83:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b86:	75 07                	jne    801b8f <ipc_send+0x36>
			sys_yield();
  801b88:	e8 ca ef ff ff       	call   800b57 <sys_yield>
  801b8d:	eb e6                	jmp    801b75 <ipc_send+0x1c>
		} else if (r < 0) {
  801b8f:	85 c0                	test   %eax,%eax
  801b91:	79 12                	jns    801ba5 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801b93:	50                   	push   %eax
  801b94:	68 86 23 80 00       	push   $0x802386
  801b99:	6a 51                	push   $0x51
  801b9b:	68 93 23 80 00       	push   $0x802393
  801ba0:	e8 70 e5 ff ff       	call   800115 <_panic>
		}
	}
}
  801ba5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba8:	5b                   	pop    %ebx
  801ba9:	5e                   	pop    %esi
  801baa:	5f                   	pop    %edi
  801bab:	5d                   	pop    %ebp
  801bac:	c3                   	ret    

00801bad <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bad:	55                   	push   %ebp
  801bae:	89 e5                	mov    %esp,%ebp
  801bb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bb3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bb8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bbb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bc1:	8b 52 50             	mov    0x50(%edx),%edx
  801bc4:	39 ca                	cmp    %ecx,%edx
  801bc6:	75 0d                	jne    801bd5 <ipc_find_env+0x28>
			return envs[i].env_id;
  801bc8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bcb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bd0:	8b 40 48             	mov    0x48(%eax),%eax
  801bd3:	eb 0f                	jmp    801be4 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bd5:	83 c0 01             	add    $0x1,%eax
  801bd8:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bdd:	75 d9                	jne    801bb8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bdf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801be4:	5d                   	pop    %ebp
  801be5:	c3                   	ret    

00801be6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bec:	89 d0                	mov    %edx,%eax
  801bee:	c1 e8 16             	shr    $0x16,%eax
  801bf1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bf8:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bfd:	f6 c1 01             	test   $0x1,%cl
  801c00:	74 1d                	je     801c1f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c02:	c1 ea 0c             	shr    $0xc,%edx
  801c05:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c0c:	f6 c2 01             	test   $0x1,%dl
  801c0f:	74 0e                	je     801c1f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c11:	c1 ea 0c             	shr    $0xc,%edx
  801c14:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c1b:	ef 
  801c1c:	0f b7 c0             	movzwl %ax,%eax
}
  801c1f:	5d                   	pop    %ebp
  801c20:	c3                   	ret    
  801c21:	66 90                	xchg   %ax,%ax
  801c23:	66 90                	xchg   %ax,%ax
  801c25:	66 90                	xchg   %ax,%ax
  801c27:	66 90                	xchg   %ax,%ax
  801c29:	66 90                	xchg   %ax,%ax
  801c2b:	66 90                	xchg   %ax,%ax
  801c2d:	66 90                	xchg   %ax,%ax
  801c2f:	90                   	nop

00801c30 <__udivdi3>:
  801c30:	55                   	push   %ebp
  801c31:	57                   	push   %edi
  801c32:	56                   	push   %esi
  801c33:	53                   	push   %ebx
  801c34:	83 ec 1c             	sub    $0x1c,%esp
  801c37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c47:	85 f6                	test   %esi,%esi
  801c49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c4d:	89 ca                	mov    %ecx,%edx
  801c4f:	89 f8                	mov    %edi,%eax
  801c51:	75 3d                	jne    801c90 <__udivdi3+0x60>
  801c53:	39 cf                	cmp    %ecx,%edi
  801c55:	0f 87 c5 00 00 00    	ja     801d20 <__udivdi3+0xf0>
  801c5b:	85 ff                	test   %edi,%edi
  801c5d:	89 fd                	mov    %edi,%ebp
  801c5f:	75 0b                	jne    801c6c <__udivdi3+0x3c>
  801c61:	b8 01 00 00 00       	mov    $0x1,%eax
  801c66:	31 d2                	xor    %edx,%edx
  801c68:	f7 f7                	div    %edi
  801c6a:	89 c5                	mov    %eax,%ebp
  801c6c:	89 c8                	mov    %ecx,%eax
  801c6e:	31 d2                	xor    %edx,%edx
  801c70:	f7 f5                	div    %ebp
  801c72:	89 c1                	mov    %eax,%ecx
  801c74:	89 d8                	mov    %ebx,%eax
  801c76:	89 cf                	mov    %ecx,%edi
  801c78:	f7 f5                	div    %ebp
  801c7a:	89 c3                	mov    %eax,%ebx
  801c7c:	89 d8                	mov    %ebx,%eax
  801c7e:	89 fa                	mov    %edi,%edx
  801c80:	83 c4 1c             	add    $0x1c,%esp
  801c83:	5b                   	pop    %ebx
  801c84:	5e                   	pop    %esi
  801c85:	5f                   	pop    %edi
  801c86:	5d                   	pop    %ebp
  801c87:	c3                   	ret    
  801c88:	90                   	nop
  801c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c90:	39 ce                	cmp    %ecx,%esi
  801c92:	77 74                	ja     801d08 <__udivdi3+0xd8>
  801c94:	0f bd fe             	bsr    %esi,%edi
  801c97:	83 f7 1f             	xor    $0x1f,%edi
  801c9a:	0f 84 98 00 00 00    	je     801d38 <__udivdi3+0x108>
  801ca0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ca5:	89 f9                	mov    %edi,%ecx
  801ca7:	89 c5                	mov    %eax,%ebp
  801ca9:	29 fb                	sub    %edi,%ebx
  801cab:	d3 e6                	shl    %cl,%esi
  801cad:	89 d9                	mov    %ebx,%ecx
  801caf:	d3 ed                	shr    %cl,%ebp
  801cb1:	89 f9                	mov    %edi,%ecx
  801cb3:	d3 e0                	shl    %cl,%eax
  801cb5:	09 ee                	or     %ebp,%esi
  801cb7:	89 d9                	mov    %ebx,%ecx
  801cb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cbd:	89 d5                	mov    %edx,%ebp
  801cbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cc3:	d3 ed                	shr    %cl,%ebp
  801cc5:	89 f9                	mov    %edi,%ecx
  801cc7:	d3 e2                	shl    %cl,%edx
  801cc9:	89 d9                	mov    %ebx,%ecx
  801ccb:	d3 e8                	shr    %cl,%eax
  801ccd:	09 c2                	or     %eax,%edx
  801ccf:	89 d0                	mov    %edx,%eax
  801cd1:	89 ea                	mov    %ebp,%edx
  801cd3:	f7 f6                	div    %esi
  801cd5:	89 d5                	mov    %edx,%ebp
  801cd7:	89 c3                	mov    %eax,%ebx
  801cd9:	f7 64 24 0c          	mull   0xc(%esp)
  801cdd:	39 d5                	cmp    %edx,%ebp
  801cdf:	72 10                	jb     801cf1 <__udivdi3+0xc1>
  801ce1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ce5:	89 f9                	mov    %edi,%ecx
  801ce7:	d3 e6                	shl    %cl,%esi
  801ce9:	39 c6                	cmp    %eax,%esi
  801ceb:	73 07                	jae    801cf4 <__udivdi3+0xc4>
  801ced:	39 d5                	cmp    %edx,%ebp
  801cef:	75 03                	jne    801cf4 <__udivdi3+0xc4>
  801cf1:	83 eb 01             	sub    $0x1,%ebx
  801cf4:	31 ff                	xor    %edi,%edi
  801cf6:	89 d8                	mov    %ebx,%eax
  801cf8:	89 fa                	mov    %edi,%edx
  801cfa:	83 c4 1c             	add    $0x1c,%esp
  801cfd:	5b                   	pop    %ebx
  801cfe:	5e                   	pop    %esi
  801cff:	5f                   	pop    %edi
  801d00:	5d                   	pop    %ebp
  801d01:	c3                   	ret    
  801d02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d08:	31 ff                	xor    %edi,%edi
  801d0a:	31 db                	xor    %ebx,%ebx
  801d0c:	89 d8                	mov    %ebx,%eax
  801d0e:	89 fa                	mov    %edi,%edx
  801d10:	83 c4 1c             	add    $0x1c,%esp
  801d13:	5b                   	pop    %ebx
  801d14:	5e                   	pop    %esi
  801d15:	5f                   	pop    %edi
  801d16:	5d                   	pop    %ebp
  801d17:	c3                   	ret    
  801d18:	90                   	nop
  801d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d20:	89 d8                	mov    %ebx,%eax
  801d22:	f7 f7                	div    %edi
  801d24:	31 ff                	xor    %edi,%edi
  801d26:	89 c3                	mov    %eax,%ebx
  801d28:	89 d8                	mov    %ebx,%eax
  801d2a:	89 fa                	mov    %edi,%edx
  801d2c:	83 c4 1c             	add    $0x1c,%esp
  801d2f:	5b                   	pop    %ebx
  801d30:	5e                   	pop    %esi
  801d31:	5f                   	pop    %edi
  801d32:	5d                   	pop    %ebp
  801d33:	c3                   	ret    
  801d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d38:	39 ce                	cmp    %ecx,%esi
  801d3a:	72 0c                	jb     801d48 <__udivdi3+0x118>
  801d3c:	31 db                	xor    %ebx,%ebx
  801d3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d42:	0f 87 34 ff ff ff    	ja     801c7c <__udivdi3+0x4c>
  801d48:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d4d:	e9 2a ff ff ff       	jmp    801c7c <__udivdi3+0x4c>
  801d52:	66 90                	xchg   %ax,%ax
  801d54:	66 90                	xchg   %ax,%ax
  801d56:	66 90                	xchg   %ax,%ax
  801d58:	66 90                	xchg   %ax,%ax
  801d5a:	66 90                	xchg   %ax,%ax
  801d5c:	66 90                	xchg   %ax,%ax
  801d5e:	66 90                	xchg   %ax,%ax

00801d60 <__umoddi3>:
  801d60:	55                   	push   %ebp
  801d61:	57                   	push   %edi
  801d62:	56                   	push   %esi
  801d63:	53                   	push   %ebx
  801d64:	83 ec 1c             	sub    $0x1c,%esp
  801d67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d77:	85 d2                	test   %edx,%edx
  801d79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d81:	89 f3                	mov    %esi,%ebx
  801d83:	89 3c 24             	mov    %edi,(%esp)
  801d86:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d8a:	75 1c                	jne    801da8 <__umoddi3+0x48>
  801d8c:	39 f7                	cmp    %esi,%edi
  801d8e:	76 50                	jbe    801de0 <__umoddi3+0x80>
  801d90:	89 c8                	mov    %ecx,%eax
  801d92:	89 f2                	mov    %esi,%edx
  801d94:	f7 f7                	div    %edi
  801d96:	89 d0                	mov    %edx,%eax
  801d98:	31 d2                	xor    %edx,%edx
  801d9a:	83 c4 1c             	add    $0x1c,%esp
  801d9d:	5b                   	pop    %ebx
  801d9e:	5e                   	pop    %esi
  801d9f:	5f                   	pop    %edi
  801da0:	5d                   	pop    %ebp
  801da1:	c3                   	ret    
  801da2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801da8:	39 f2                	cmp    %esi,%edx
  801daa:	89 d0                	mov    %edx,%eax
  801dac:	77 52                	ja     801e00 <__umoddi3+0xa0>
  801dae:	0f bd ea             	bsr    %edx,%ebp
  801db1:	83 f5 1f             	xor    $0x1f,%ebp
  801db4:	75 5a                	jne    801e10 <__umoddi3+0xb0>
  801db6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801dba:	0f 82 e0 00 00 00    	jb     801ea0 <__umoddi3+0x140>
  801dc0:	39 0c 24             	cmp    %ecx,(%esp)
  801dc3:	0f 86 d7 00 00 00    	jbe    801ea0 <__umoddi3+0x140>
  801dc9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dcd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dd1:	83 c4 1c             	add    $0x1c,%esp
  801dd4:	5b                   	pop    %ebx
  801dd5:	5e                   	pop    %esi
  801dd6:	5f                   	pop    %edi
  801dd7:	5d                   	pop    %ebp
  801dd8:	c3                   	ret    
  801dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801de0:	85 ff                	test   %edi,%edi
  801de2:	89 fd                	mov    %edi,%ebp
  801de4:	75 0b                	jne    801df1 <__umoddi3+0x91>
  801de6:	b8 01 00 00 00       	mov    $0x1,%eax
  801deb:	31 d2                	xor    %edx,%edx
  801ded:	f7 f7                	div    %edi
  801def:	89 c5                	mov    %eax,%ebp
  801df1:	89 f0                	mov    %esi,%eax
  801df3:	31 d2                	xor    %edx,%edx
  801df5:	f7 f5                	div    %ebp
  801df7:	89 c8                	mov    %ecx,%eax
  801df9:	f7 f5                	div    %ebp
  801dfb:	89 d0                	mov    %edx,%eax
  801dfd:	eb 99                	jmp    801d98 <__umoddi3+0x38>
  801dff:	90                   	nop
  801e00:	89 c8                	mov    %ecx,%eax
  801e02:	89 f2                	mov    %esi,%edx
  801e04:	83 c4 1c             	add    $0x1c,%esp
  801e07:	5b                   	pop    %ebx
  801e08:	5e                   	pop    %esi
  801e09:	5f                   	pop    %edi
  801e0a:	5d                   	pop    %ebp
  801e0b:	c3                   	ret    
  801e0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e10:	8b 34 24             	mov    (%esp),%esi
  801e13:	bf 20 00 00 00       	mov    $0x20,%edi
  801e18:	89 e9                	mov    %ebp,%ecx
  801e1a:	29 ef                	sub    %ebp,%edi
  801e1c:	d3 e0                	shl    %cl,%eax
  801e1e:	89 f9                	mov    %edi,%ecx
  801e20:	89 f2                	mov    %esi,%edx
  801e22:	d3 ea                	shr    %cl,%edx
  801e24:	89 e9                	mov    %ebp,%ecx
  801e26:	09 c2                	or     %eax,%edx
  801e28:	89 d8                	mov    %ebx,%eax
  801e2a:	89 14 24             	mov    %edx,(%esp)
  801e2d:	89 f2                	mov    %esi,%edx
  801e2f:	d3 e2                	shl    %cl,%edx
  801e31:	89 f9                	mov    %edi,%ecx
  801e33:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e37:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e3b:	d3 e8                	shr    %cl,%eax
  801e3d:	89 e9                	mov    %ebp,%ecx
  801e3f:	89 c6                	mov    %eax,%esi
  801e41:	d3 e3                	shl    %cl,%ebx
  801e43:	89 f9                	mov    %edi,%ecx
  801e45:	89 d0                	mov    %edx,%eax
  801e47:	d3 e8                	shr    %cl,%eax
  801e49:	89 e9                	mov    %ebp,%ecx
  801e4b:	09 d8                	or     %ebx,%eax
  801e4d:	89 d3                	mov    %edx,%ebx
  801e4f:	89 f2                	mov    %esi,%edx
  801e51:	f7 34 24             	divl   (%esp)
  801e54:	89 d6                	mov    %edx,%esi
  801e56:	d3 e3                	shl    %cl,%ebx
  801e58:	f7 64 24 04          	mull   0x4(%esp)
  801e5c:	39 d6                	cmp    %edx,%esi
  801e5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e62:	89 d1                	mov    %edx,%ecx
  801e64:	89 c3                	mov    %eax,%ebx
  801e66:	72 08                	jb     801e70 <__umoddi3+0x110>
  801e68:	75 11                	jne    801e7b <__umoddi3+0x11b>
  801e6a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e6e:	73 0b                	jae    801e7b <__umoddi3+0x11b>
  801e70:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e74:	1b 14 24             	sbb    (%esp),%edx
  801e77:	89 d1                	mov    %edx,%ecx
  801e79:	89 c3                	mov    %eax,%ebx
  801e7b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e7f:	29 da                	sub    %ebx,%edx
  801e81:	19 ce                	sbb    %ecx,%esi
  801e83:	89 f9                	mov    %edi,%ecx
  801e85:	89 f0                	mov    %esi,%eax
  801e87:	d3 e0                	shl    %cl,%eax
  801e89:	89 e9                	mov    %ebp,%ecx
  801e8b:	d3 ea                	shr    %cl,%edx
  801e8d:	89 e9                	mov    %ebp,%ecx
  801e8f:	d3 ee                	shr    %cl,%esi
  801e91:	09 d0                	or     %edx,%eax
  801e93:	89 f2                	mov    %esi,%edx
  801e95:	83 c4 1c             	add    $0x1c,%esp
  801e98:	5b                   	pop    %ebx
  801e99:	5e                   	pop    %esi
  801e9a:	5f                   	pop    %edi
  801e9b:	5d                   	pop    %ebp
  801e9c:	c3                   	ret    
  801e9d:	8d 76 00             	lea    0x0(%esi),%esi
  801ea0:	29 f9                	sub    %edi,%ecx
  801ea2:	19 d6                	sbb    %edx,%esi
  801ea4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ea8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801eac:	e9 18 ff ff ff       	jmp    801dc9 <__umoddi3+0x69>
