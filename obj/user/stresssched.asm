
obj/user/stresssched.debug:     file format elf32-i386


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
  80002c:	e8 bc 00 00 00       	call   8000ed <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 33 0b 00 00       	call   800b70 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 10 0f 00 00       	call   800f59 <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0a                	je     800057 <umain+0x24>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
  800055:	eb 05                	jmp    80005c <umain+0x29>
		if (fork() == 0)
			break;
	if (i == 20) {
  800057:	83 fb 14             	cmp    $0x14,%ebx
  80005a:	75 0e                	jne    80006a <umain+0x37>
		sys_yield();
  80005c:	e8 2e 0b 00 00       	call   800b8f <sys_yield>
		return;
  800061:	e9 80 00 00 00       	jmp    8000e6 <umain+0xb3>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800066:	f3 90                	pause  
  800068:	eb 0f                	jmp    800079 <umain+0x46>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800070:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800073:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800079:	8b 42 54             	mov    0x54(%edx),%eax
  80007c:	85 c0                	test   %eax,%eax
  80007e:	75 e6                	jne    800066 <umain+0x33>
  800080:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800085:	e8 05 0b 00 00       	call   800b8f <sys_yield>
  80008a:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008f:	a1 08 40 80 00       	mov    0x804008,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 08 40 80 00       	mov    %eax,0x804008
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  80009c:	83 ea 01             	sub    $0x1,%edx
  80009f:	75 ee                	jne    80008f <umain+0x5c>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000a1:	83 eb 01             	sub    $0x1,%ebx
  8000a4:	75 df                	jne    800085 <umain+0x52>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000a6:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 00 27 80 00       	push   $0x802700
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 28 27 80 00       	push   $0x802728
  8000c4:	e8 84 00 00 00       	call   80014d <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 3b 27 80 00       	push   $0x80273b
  8000de:	e8 43 01 00 00       	call   800226 <cprintf>
  8000e3:	83 c4 10             	add    $0x10,%esp

}
  8000e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000f8:	e8 73 0a 00 00       	call   800b70 <sys_getenvid>
  8000fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800102:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 db                	test   %ebx,%ebx
  800111:	7e 07                	jle    80011a <libmain+0x2d>
		binaryname = argv[0];
  800113:	8b 06                	mov    (%esi),%eax
  800115:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
  80011f:	e8 0f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800124:	e8 0a 00 00 00       	call   800133 <exit>
}
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800139:	e8 c5 11 00 00       	call   801303 <close_all>
	sys_env_destroy(0);
  80013e:	83 ec 0c             	sub    $0xc,%esp
  800141:	6a 00                	push   $0x0
  800143:	e8 e7 09 00 00       	call   800b2f <sys_env_destroy>
}
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800152:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800155:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80015b:	e8 10 0a 00 00       	call   800b70 <sys_getenvid>
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 75 0c             	pushl  0xc(%ebp)
  800166:	ff 75 08             	pushl  0x8(%ebp)
  800169:	56                   	push   %esi
  80016a:	50                   	push   %eax
  80016b:	68 64 27 80 00       	push   $0x802764
  800170:	e8 b1 00 00 00       	call   800226 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800175:	83 c4 18             	add    $0x18,%esp
  800178:	53                   	push   %ebx
  800179:	ff 75 10             	pushl  0x10(%ebp)
  80017c:	e8 54 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  800181:	c7 04 24 57 27 80 00 	movl   $0x802757,(%esp)
  800188:	e8 99 00 00 00       	call   800226 <cprintf>
  80018d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800190:	cc                   	int3   
  800191:	eb fd                	jmp    800190 <_panic+0x43>

00800193 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	53                   	push   %ebx
  800197:	83 ec 04             	sub    $0x4,%esp
  80019a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019d:	8b 13                	mov    (%ebx),%edx
  80019f:	8d 42 01             	lea    0x1(%edx),%eax
  8001a2:	89 03                	mov    %eax,(%ebx)
  8001a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ab:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b0:	75 1a                	jne    8001cc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	68 ff 00 00 00       	push   $0xff
  8001ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bd:	50                   	push   %eax
  8001be:	e8 2f 09 00 00       	call   800af2 <sys_cputs>
		b->idx = 0;
  8001c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d3:	c9                   	leave  
  8001d4:	c3                   	ret    

008001d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e5:	00 00 00 
	b.cnt = 0;
  8001e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f2:	ff 75 0c             	pushl  0xc(%ebp)
  8001f5:	ff 75 08             	pushl  0x8(%ebp)
  8001f8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fe:	50                   	push   %eax
  8001ff:	68 93 01 80 00       	push   $0x800193
  800204:	e8 54 01 00 00       	call   80035d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800209:	83 c4 08             	add    $0x8,%esp
  80020c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800212:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800218:	50                   	push   %eax
  800219:	e8 d4 08 00 00       	call   800af2 <sys_cputs>

	return b.cnt;
}
  80021e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022f:	50                   	push   %eax
  800230:	ff 75 08             	pushl  0x8(%ebp)
  800233:	e8 9d ff ff ff       	call   8001d5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	57                   	push   %edi
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
  800240:	83 ec 1c             	sub    $0x1c,%esp
  800243:	89 c7                	mov    %eax,%edi
  800245:	89 d6                	mov    %edx,%esi
  800247:	8b 45 08             	mov    0x8(%ebp),%eax
  80024a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800250:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800253:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800256:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800261:	39 d3                	cmp    %edx,%ebx
  800263:	72 05                	jb     80026a <printnum+0x30>
  800265:	39 45 10             	cmp    %eax,0x10(%ebp)
  800268:	77 45                	ja     8002af <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	8b 45 14             	mov    0x14(%ebp),%eax
  800273:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800276:	53                   	push   %ebx
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	83 ec 08             	sub    $0x8,%esp
  80027d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800280:	ff 75 e0             	pushl  -0x20(%ebp)
  800283:	ff 75 dc             	pushl  -0x24(%ebp)
  800286:	ff 75 d8             	pushl  -0x28(%ebp)
  800289:	e8 d2 21 00 00       	call   802460 <__udivdi3>
  80028e:	83 c4 18             	add    $0x18,%esp
  800291:	52                   	push   %edx
  800292:	50                   	push   %eax
  800293:	89 f2                	mov    %esi,%edx
  800295:	89 f8                	mov    %edi,%eax
  800297:	e8 9e ff ff ff       	call   80023a <printnum>
  80029c:	83 c4 20             	add    $0x20,%esp
  80029f:	eb 18                	jmp    8002b9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	ff 75 18             	pushl  0x18(%ebp)
  8002a8:	ff d7                	call   *%edi
  8002aa:	83 c4 10             	add    $0x10,%esp
  8002ad:	eb 03                	jmp    8002b2 <printnum+0x78>
  8002af:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b2:	83 eb 01             	sub    $0x1,%ebx
  8002b5:	85 db                	test   %ebx,%ebx
  8002b7:	7f e8                	jg     8002a1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	56                   	push   %esi
  8002bd:	83 ec 04             	sub    $0x4,%esp
  8002c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cc:	e8 bf 22 00 00       	call   802590 <__umoddi3>
  8002d1:	83 c4 14             	add    $0x14,%esp
  8002d4:	0f be 80 87 27 80 00 	movsbl 0x802787(%eax),%eax
  8002db:	50                   	push   %eax
  8002dc:	ff d7                	call   *%edi
}
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e4:	5b                   	pop    %ebx
  8002e5:	5e                   	pop    %esi
  8002e6:	5f                   	pop    %edi
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ec:	83 fa 01             	cmp    $0x1,%edx
  8002ef:	7e 0e                	jle    8002ff <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f1:	8b 10                	mov    (%eax),%edx
  8002f3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f6:	89 08                	mov    %ecx,(%eax)
  8002f8:	8b 02                	mov    (%edx),%eax
  8002fa:	8b 52 04             	mov    0x4(%edx),%edx
  8002fd:	eb 22                	jmp    800321 <getuint+0x38>
	else if (lflag)
  8002ff:	85 d2                	test   %edx,%edx
  800301:	74 10                	je     800313 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800303:	8b 10                	mov    (%eax),%edx
  800305:	8d 4a 04             	lea    0x4(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 02                	mov    (%edx),%eax
  80030c:	ba 00 00 00 00       	mov    $0x0,%edx
  800311:	eb 0e                	jmp    800321 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800313:	8b 10                	mov    (%eax),%edx
  800315:	8d 4a 04             	lea    0x4(%edx),%ecx
  800318:	89 08                	mov    %ecx,(%eax)
  80031a:	8b 02                	mov    (%edx),%eax
  80031c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800329:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032d:	8b 10                	mov    (%eax),%edx
  80032f:	3b 50 04             	cmp    0x4(%eax),%edx
  800332:	73 0a                	jae    80033e <sprintputch+0x1b>
		*b->buf++ = ch;
  800334:	8d 4a 01             	lea    0x1(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 45 08             	mov    0x8(%ebp),%eax
  80033c:	88 02                	mov    %al,(%edx)
}
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    

00800340 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800346:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800349:	50                   	push   %eax
  80034a:	ff 75 10             	pushl  0x10(%ebp)
  80034d:	ff 75 0c             	pushl  0xc(%ebp)
  800350:	ff 75 08             	pushl  0x8(%ebp)
  800353:	e8 05 00 00 00       	call   80035d <vprintfmt>
	va_end(ap);
}
  800358:	83 c4 10             	add    $0x10,%esp
  80035b:	c9                   	leave  
  80035c:	c3                   	ret    

0080035d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	57                   	push   %edi
  800361:	56                   	push   %esi
  800362:	53                   	push   %ebx
  800363:	83 ec 2c             	sub    $0x2c,%esp
  800366:	8b 75 08             	mov    0x8(%ebp),%esi
  800369:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80036f:	eb 12                	jmp    800383 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800371:	85 c0                	test   %eax,%eax
  800373:	0f 84 89 03 00 00    	je     800702 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800379:	83 ec 08             	sub    $0x8,%esp
  80037c:	53                   	push   %ebx
  80037d:	50                   	push   %eax
  80037e:	ff d6                	call   *%esi
  800380:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800383:	83 c7 01             	add    $0x1,%edi
  800386:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80038a:	83 f8 25             	cmp    $0x25,%eax
  80038d:	75 e2                	jne    800371 <vprintfmt+0x14>
  80038f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800393:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80039a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ad:	eb 07                	jmp    8003b6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8d 47 01             	lea    0x1(%edi),%eax
  8003b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003bc:	0f b6 07             	movzbl (%edi),%eax
  8003bf:	0f b6 c8             	movzbl %al,%ecx
  8003c2:	83 e8 23             	sub    $0x23,%eax
  8003c5:	3c 55                	cmp    $0x55,%al
  8003c7:	0f 87 1a 03 00 00    	ja     8006e7 <vprintfmt+0x38a>
  8003cd:	0f b6 c0             	movzbl %al,%eax
  8003d0:	ff 24 85 c0 28 80 00 	jmp    *0x8028c0(,%eax,4)
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003da:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003de:	eb d6                	jmp    8003b6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003eb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ee:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003f2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003f5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003f8:	83 fa 09             	cmp    $0x9,%edx
  8003fb:	77 39                	ja     800436 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003fd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800400:	eb e9                	jmp    8003eb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800402:	8b 45 14             	mov    0x14(%ebp),%eax
  800405:	8d 48 04             	lea    0x4(%eax),%ecx
  800408:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80040b:	8b 00                	mov    (%eax),%eax
  80040d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800413:	eb 27                	jmp    80043c <vprintfmt+0xdf>
  800415:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800418:	85 c0                	test   %eax,%eax
  80041a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041f:	0f 49 c8             	cmovns %eax,%ecx
  800422:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800428:	eb 8c                	jmp    8003b6 <vprintfmt+0x59>
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800434:	eb 80                	jmp    8003b6 <vprintfmt+0x59>
  800436:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800439:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80043c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800440:	0f 89 70 ff ff ff    	jns    8003b6 <vprintfmt+0x59>
				width = precision, precision = -1;
  800446:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800449:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800453:	e9 5e ff ff ff       	jmp    8003b6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800458:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80045e:	e9 53 ff ff ff       	jmp    8003b6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800463:	8b 45 14             	mov    0x14(%ebp),%eax
  800466:	8d 50 04             	lea    0x4(%eax),%edx
  800469:	89 55 14             	mov    %edx,0x14(%ebp)
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	53                   	push   %ebx
  800470:	ff 30                	pushl  (%eax)
  800472:	ff d6                	call   *%esi
			break;
  800474:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80047a:	e9 04 ff ff ff       	jmp    800383 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047f:	8b 45 14             	mov    0x14(%ebp),%eax
  800482:	8d 50 04             	lea    0x4(%eax),%edx
  800485:	89 55 14             	mov    %edx,0x14(%ebp)
  800488:	8b 00                	mov    (%eax),%eax
  80048a:	99                   	cltd   
  80048b:	31 d0                	xor    %edx,%eax
  80048d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048f:	83 f8 0f             	cmp    $0xf,%eax
  800492:	7f 0b                	jg     80049f <vprintfmt+0x142>
  800494:	8b 14 85 20 2a 80 00 	mov    0x802a20(,%eax,4),%edx
  80049b:	85 d2                	test   %edx,%edx
  80049d:	75 18                	jne    8004b7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80049f:	50                   	push   %eax
  8004a0:	68 9f 27 80 00       	push   $0x80279f
  8004a5:	53                   	push   %ebx
  8004a6:	56                   	push   %esi
  8004a7:	e8 94 fe ff ff       	call   800340 <printfmt>
  8004ac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b2:	e9 cc fe ff ff       	jmp    800383 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004b7:	52                   	push   %edx
  8004b8:	68 0e 2c 80 00       	push   $0x802c0e
  8004bd:	53                   	push   %ebx
  8004be:	56                   	push   %esi
  8004bf:	e8 7c fe ff ff       	call   800340 <printfmt>
  8004c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ca:	e9 b4 fe ff ff       	jmp    800383 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d2:	8d 50 04             	lea    0x4(%eax),%edx
  8004d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004da:	85 ff                	test   %edi,%edi
  8004dc:	b8 98 27 80 00       	mov    $0x802798,%eax
  8004e1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004e4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e8:	0f 8e 94 00 00 00    	jle    800582 <vprintfmt+0x225>
  8004ee:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004f2:	0f 84 98 00 00 00    	je     800590 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	ff 75 d0             	pushl  -0x30(%ebp)
  8004fe:	57                   	push   %edi
  8004ff:	e8 86 02 00 00       	call   80078a <strnlen>
  800504:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800507:	29 c1                	sub    %eax,%ecx
  800509:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80050c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80050f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800513:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800516:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800519:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051b:	eb 0f                	jmp    80052c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	53                   	push   %ebx
  800521:	ff 75 e0             	pushl  -0x20(%ebp)
  800524:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800526:	83 ef 01             	sub    $0x1,%edi
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	85 ff                	test   %edi,%edi
  80052e:	7f ed                	jg     80051d <vprintfmt+0x1c0>
  800530:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800533:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800536:	85 c9                	test   %ecx,%ecx
  800538:	b8 00 00 00 00       	mov    $0x0,%eax
  80053d:	0f 49 c1             	cmovns %ecx,%eax
  800540:	29 c1                	sub    %eax,%ecx
  800542:	89 75 08             	mov    %esi,0x8(%ebp)
  800545:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800548:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054b:	89 cb                	mov    %ecx,%ebx
  80054d:	eb 4d                	jmp    80059c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80054f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800553:	74 1b                	je     800570 <vprintfmt+0x213>
  800555:	0f be c0             	movsbl %al,%eax
  800558:	83 e8 20             	sub    $0x20,%eax
  80055b:	83 f8 5e             	cmp    $0x5e,%eax
  80055e:	76 10                	jbe    800570 <vprintfmt+0x213>
					putch('?', putdat);
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	ff 75 0c             	pushl  0xc(%ebp)
  800566:	6a 3f                	push   $0x3f
  800568:	ff 55 08             	call   *0x8(%ebp)
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb 0d                	jmp    80057d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	ff 75 0c             	pushl  0xc(%ebp)
  800576:	52                   	push   %edx
  800577:	ff 55 08             	call   *0x8(%ebp)
  80057a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057d:	83 eb 01             	sub    $0x1,%ebx
  800580:	eb 1a                	jmp    80059c <vprintfmt+0x23f>
  800582:	89 75 08             	mov    %esi,0x8(%ebp)
  800585:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800588:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058e:	eb 0c                	jmp    80059c <vprintfmt+0x23f>
  800590:	89 75 08             	mov    %esi,0x8(%ebp)
  800593:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800596:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800599:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059c:	83 c7 01             	add    $0x1,%edi
  80059f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a3:	0f be d0             	movsbl %al,%edx
  8005a6:	85 d2                	test   %edx,%edx
  8005a8:	74 23                	je     8005cd <vprintfmt+0x270>
  8005aa:	85 f6                	test   %esi,%esi
  8005ac:	78 a1                	js     80054f <vprintfmt+0x1f2>
  8005ae:	83 ee 01             	sub    $0x1,%esi
  8005b1:	79 9c                	jns    80054f <vprintfmt+0x1f2>
  8005b3:	89 df                	mov    %ebx,%edi
  8005b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005bb:	eb 18                	jmp    8005d5 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005bd:	83 ec 08             	sub    $0x8,%esp
  8005c0:	53                   	push   %ebx
  8005c1:	6a 20                	push   $0x20
  8005c3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c5:	83 ef 01             	sub    $0x1,%edi
  8005c8:	83 c4 10             	add    $0x10,%esp
  8005cb:	eb 08                	jmp    8005d5 <vprintfmt+0x278>
  8005cd:	89 df                	mov    %ebx,%edi
  8005cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d5:	85 ff                	test   %edi,%edi
  8005d7:	7f e4                	jg     8005bd <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005dc:	e9 a2 fd ff ff       	jmp    800383 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e1:	83 fa 01             	cmp    $0x1,%edx
  8005e4:	7e 16                	jle    8005fc <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 08             	lea    0x8(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 50 04             	mov    0x4(%eax),%edx
  8005f2:	8b 00                	mov    (%eax),%eax
  8005f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005fa:	eb 32                	jmp    80062e <vprintfmt+0x2d1>
	else if (lflag)
  8005fc:	85 d2                	test   %edx,%edx
  8005fe:	74 18                	je     800618 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 04             	lea    0x4(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)
  800609:	8b 00                	mov    (%eax),%eax
  80060b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060e:	89 c1                	mov    %eax,%ecx
  800610:	c1 f9 1f             	sar    $0x1f,%ecx
  800613:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800616:	eb 16                	jmp    80062e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 50 04             	lea    0x4(%eax),%edx
  80061e:	89 55 14             	mov    %edx,0x14(%ebp)
  800621:	8b 00                	mov    (%eax),%eax
  800623:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800626:	89 c1                	mov    %eax,%ecx
  800628:	c1 f9 1f             	sar    $0x1f,%ecx
  80062b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80062e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800631:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800634:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800639:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80063d:	79 74                	jns    8006b3 <vprintfmt+0x356>
				putch('-', putdat);
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	53                   	push   %ebx
  800643:	6a 2d                	push   $0x2d
  800645:	ff d6                	call   *%esi
				num = -(long long) num;
  800647:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80064a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80064d:	f7 d8                	neg    %eax
  80064f:	83 d2 00             	adc    $0x0,%edx
  800652:	f7 da                	neg    %edx
  800654:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800657:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80065c:	eb 55                	jmp    8006b3 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80065e:	8d 45 14             	lea    0x14(%ebp),%eax
  800661:	e8 83 fc ff ff       	call   8002e9 <getuint>
			base = 10;
  800666:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80066b:	eb 46                	jmp    8006b3 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80066d:	8d 45 14             	lea    0x14(%ebp),%eax
  800670:	e8 74 fc ff ff       	call   8002e9 <getuint>
                        base = 8;
  800675:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80067a:	eb 37                	jmp    8006b3 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	53                   	push   %ebx
  800680:	6a 30                	push   $0x30
  800682:	ff d6                	call   *%esi
			putch('x', putdat);
  800684:	83 c4 08             	add    $0x8,%esp
  800687:	53                   	push   %ebx
  800688:	6a 78                	push   $0x78
  80068a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8d 50 04             	lea    0x4(%eax),%edx
  800692:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800695:	8b 00                	mov    (%eax),%eax
  800697:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80069c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80069f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006a4:	eb 0d                	jmp    8006b3 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a9:	e8 3b fc ff ff       	call   8002e9 <getuint>
			base = 16;
  8006ae:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b3:	83 ec 0c             	sub    $0xc,%esp
  8006b6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006ba:	57                   	push   %edi
  8006bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8006be:	51                   	push   %ecx
  8006bf:	52                   	push   %edx
  8006c0:	50                   	push   %eax
  8006c1:	89 da                	mov    %ebx,%edx
  8006c3:	89 f0                	mov    %esi,%eax
  8006c5:	e8 70 fb ff ff       	call   80023a <printnum>
			break;
  8006ca:	83 c4 20             	add    $0x20,%esp
  8006cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d0:	e9 ae fc ff ff       	jmp    800383 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	53                   	push   %ebx
  8006d9:	51                   	push   %ecx
  8006da:	ff d6                	call   *%esi
			break;
  8006dc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e2:	e9 9c fc ff ff       	jmp    800383 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	53                   	push   %ebx
  8006eb:	6a 25                	push   $0x25
  8006ed:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	eb 03                	jmp    8006f7 <vprintfmt+0x39a>
  8006f4:	83 ef 01             	sub    $0x1,%edi
  8006f7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006fb:	75 f7                	jne    8006f4 <vprintfmt+0x397>
  8006fd:	e9 81 fc ff ff       	jmp    800383 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800702:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800705:	5b                   	pop    %ebx
  800706:	5e                   	pop    %esi
  800707:	5f                   	pop    %edi
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	83 ec 18             	sub    $0x18,%esp
  800710:	8b 45 08             	mov    0x8(%ebp),%eax
  800713:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800716:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800719:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800720:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800727:	85 c0                	test   %eax,%eax
  800729:	74 26                	je     800751 <vsnprintf+0x47>
  80072b:	85 d2                	test   %edx,%edx
  80072d:	7e 22                	jle    800751 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072f:	ff 75 14             	pushl  0x14(%ebp)
  800732:	ff 75 10             	pushl  0x10(%ebp)
  800735:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800738:	50                   	push   %eax
  800739:	68 23 03 80 00       	push   $0x800323
  80073e:	e8 1a fc ff ff       	call   80035d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800743:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800746:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800749:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	eb 05                	jmp    800756 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800751:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800761:	50                   	push   %eax
  800762:	ff 75 10             	pushl  0x10(%ebp)
  800765:	ff 75 0c             	pushl  0xc(%ebp)
  800768:	ff 75 08             	pushl  0x8(%ebp)
  80076b:	e8 9a ff ff ff       	call   80070a <vsnprintf>
	va_end(ap);

	return rc;
}
  800770:	c9                   	leave  
  800771:	c3                   	ret    

00800772 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800778:	b8 00 00 00 00       	mov    $0x0,%eax
  80077d:	eb 03                	jmp    800782 <strlen+0x10>
		n++;
  80077f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800782:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800786:	75 f7                	jne    80077f <strlen+0xd>
		n++;
	return n;
}
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800790:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800793:	ba 00 00 00 00       	mov    $0x0,%edx
  800798:	eb 03                	jmp    80079d <strnlen+0x13>
		n++;
  80079a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079d:	39 c2                	cmp    %eax,%edx
  80079f:	74 08                	je     8007a9 <strnlen+0x1f>
  8007a1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007a5:	75 f3                	jne    80079a <strnlen+0x10>
  8007a7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	53                   	push   %ebx
  8007af:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b5:	89 c2                	mov    %eax,%edx
  8007b7:	83 c2 01             	add    $0x1,%edx
  8007ba:	83 c1 01             	add    $0x1,%ecx
  8007bd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007c1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c4:	84 db                	test   %bl,%bl
  8007c6:	75 ef                	jne    8007b7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c8:	5b                   	pop    %ebx
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	53                   	push   %ebx
  8007cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d2:	53                   	push   %ebx
  8007d3:	e8 9a ff ff ff       	call   800772 <strlen>
  8007d8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007db:	ff 75 0c             	pushl  0xc(%ebp)
  8007de:	01 d8                	add    %ebx,%eax
  8007e0:	50                   	push   %eax
  8007e1:	e8 c5 ff ff ff       	call   8007ab <strcpy>
	return dst;
}
  8007e6:	89 d8                	mov    %ebx,%eax
  8007e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    

008007ed <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	56                   	push   %esi
  8007f1:	53                   	push   %ebx
  8007f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f8:	89 f3                	mov    %esi,%ebx
  8007fa:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fd:	89 f2                	mov    %esi,%edx
  8007ff:	eb 0f                	jmp    800810 <strncpy+0x23>
		*dst++ = *src;
  800801:	83 c2 01             	add    $0x1,%edx
  800804:	0f b6 01             	movzbl (%ecx),%eax
  800807:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080a:	80 39 01             	cmpb   $0x1,(%ecx)
  80080d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800810:	39 da                	cmp    %ebx,%edx
  800812:	75 ed                	jne    800801 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800814:	89 f0                	mov    %esi,%eax
  800816:	5b                   	pop    %ebx
  800817:	5e                   	pop    %esi
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	8b 75 08             	mov    0x8(%ebp),%esi
  800822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800825:	8b 55 10             	mov    0x10(%ebp),%edx
  800828:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082a:	85 d2                	test   %edx,%edx
  80082c:	74 21                	je     80084f <strlcpy+0x35>
  80082e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800832:	89 f2                	mov    %esi,%edx
  800834:	eb 09                	jmp    80083f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800836:	83 c2 01             	add    $0x1,%edx
  800839:	83 c1 01             	add    $0x1,%ecx
  80083c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80083f:	39 c2                	cmp    %eax,%edx
  800841:	74 09                	je     80084c <strlcpy+0x32>
  800843:	0f b6 19             	movzbl (%ecx),%ebx
  800846:	84 db                	test   %bl,%bl
  800848:	75 ec                	jne    800836 <strlcpy+0x1c>
  80084a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80084c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80084f:	29 f0                	sub    %esi,%eax
}
  800851:	5b                   	pop    %ebx
  800852:	5e                   	pop    %esi
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085e:	eb 06                	jmp    800866 <strcmp+0x11>
		p++, q++;
  800860:	83 c1 01             	add    $0x1,%ecx
  800863:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800866:	0f b6 01             	movzbl (%ecx),%eax
  800869:	84 c0                	test   %al,%al
  80086b:	74 04                	je     800871 <strcmp+0x1c>
  80086d:	3a 02                	cmp    (%edx),%al
  80086f:	74 ef                	je     800860 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800871:	0f b6 c0             	movzbl %al,%eax
  800874:	0f b6 12             	movzbl (%edx),%edx
  800877:	29 d0                	sub    %edx,%eax
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	8b 55 0c             	mov    0xc(%ebp),%edx
  800885:	89 c3                	mov    %eax,%ebx
  800887:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80088a:	eb 06                	jmp    800892 <strncmp+0x17>
		n--, p++, q++;
  80088c:	83 c0 01             	add    $0x1,%eax
  80088f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800892:	39 d8                	cmp    %ebx,%eax
  800894:	74 15                	je     8008ab <strncmp+0x30>
  800896:	0f b6 08             	movzbl (%eax),%ecx
  800899:	84 c9                	test   %cl,%cl
  80089b:	74 04                	je     8008a1 <strncmp+0x26>
  80089d:	3a 0a                	cmp    (%edx),%cl
  80089f:	74 eb                	je     80088c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a1:	0f b6 00             	movzbl (%eax),%eax
  8008a4:	0f b6 12             	movzbl (%edx),%edx
  8008a7:	29 d0                	sub    %edx,%eax
  8008a9:	eb 05                	jmp    8008b0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ab:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b0:	5b                   	pop    %ebx
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008bd:	eb 07                	jmp    8008c6 <strchr+0x13>
		if (*s == c)
  8008bf:	38 ca                	cmp    %cl,%dl
  8008c1:	74 0f                	je     8008d2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c3:	83 c0 01             	add    $0x1,%eax
  8008c6:	0f b6 10             	movzbl (%eax),%edx
  8008c9:	84 d2                	test   %dl,%dl
  8008cb:	75 f2                	jne    8008bf <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008de:	eb 03                	jmp    8008e3 <strfind+0xf>
  8008e0:	83 c0 01             	add    $0x1,%eax
  8008e3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e6:	38 ca                	cmp    %cl,%dl
  8008e8:	74 04                	je     8008ee <strfind+0x1a>
  8008ea:	84 d2                	test   %dl,%dl
  8008ec:	75 f2                	jne    8008e0 <strfind+0xc>
			break;
	return (char *) s;
}
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	57                   	push   %edi
  8008f4:	56                   	push   %esi
  8008f5:	53                   	push   %ebx
  8008f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008fc:	85 c9                	test   %ecx,%ecx
  8008fe:	74 36                	je     800936 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800900:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800906:	75 28                	jne    800930 <memset+0x40>
  800908:	f6 c1 03             	test   $0x3,%cl
  80090b:	75 23                	jne    800930 <memset+0x40>
		c &= 0xFF;
  80090d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800911:	89 d3                	mov    %edx,%ebx
  800913:	c1 e3 08             	shl    $0x8,%ebx
  800916:	89 d6                	mov    %edx,%esi
  800918:	c1 e6 18             	shl    $0x18,%esi
  80091b:	89 d0                	mov    %edx,%eax
  80091d:	c1 e0 10             	shl    $0x10,%eax
  800920:	09 f0                	or     %esi,%eax
  800922:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800924:	89 d8                	mov    %ebx,%eax
  800926:	09 d0                	or     %edx,%eax
  800928:	c1 e9 02             	shr    $0x2,%ecx
  80092b:	fc                   	cld    
  80092c:	f3 ab                	rep stos %eax,%es:(%edi)
  80092e:	eb 06                	jmp    800936 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800930:	8b 45 0c             	mov    0xc(%ebp),%eax
  800933:	fc                   	cld    
  800934:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800936:	89 f8                	mov    %edi,%eax
  800938:	5b                   	pop    %ebx
  800939:	5e                   	pop    %esi
  80093a:	5f                   	pop    %edi
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	57                   	push   %edi
  800941:	56                   	push   %esi
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	8b 75 0c             	mov    0xc(%ebp),%esi
  800948:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80094b:	39 c6                	cmp    %eax,%esi
  80094d:	73 35                	jae    800984 <memmove+0x47>
  80094f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800952:	39 d0                	cmp    %edx,%eax
  800954:	73 2e                	jae    800984 <memmove+0x47>
		s += n;
		d += n;
  800956:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800959:	89 d6                	mov    %edx,%esi
  80095b:	09 fe                	or     %edi,%esi
  80095d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800963:	75 13                	jne    800978 <memmove+0x3b>
  800965:	f6 c1 03             	test   $0x3,%cl
  800968:	75 0e                	jne    800978 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80096a:	83 ef 04             	sub    $0x4,%edi
  80096d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800970:	c1 e9 02             	shr    $0x2,%ecx
  800973:	fd                   	std    
  800974:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800976:	eb 09                	jmp    800981 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800978:	83 ef 01             	sub    $0x1,%edi
  80097b:	8d 72 ff             	lea    -0x1(%edx),%esi
  80097e:	fd                   	std    
  80097f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800981:	fc                   	cld    
  800982:	eb 1d                	jmp    8009a1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800984:	89 f2                	mov    %esi,%edx
  800986:	09 c2                	or     %eax,%edx
  800988:	f6 c2 03             	test   $0x3,%dl
  80098b:	75 0f                	jne    80099c <memmove+0x5f>
  80098d:	f6 c1 03             	test   $0x3,%cl
  800990:	75 0a                	jne    80099c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800992:	c1 e9 02             	shr    $0x2,%ecx
  800995:	89 c7                	mov    %eax,%edi
  800997:	fc                   	cld    
  800998:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099a:	eb 05                	jmp    8009a1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80099c:	89 c7                	mov    %eax,%edi
  80099e:	fc                   	cld    
  80099f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a1:	5e                   	pop    %esi
  8009a2:	5f                   	pop    %edi
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a8:	ff 75 10             	pushl  0x10(%ebp)
  8009ab:	ff 75 0c             	pushl  0xc(%ebp)
  8009ae:	ff 75 08             	pushl  0x8(%ebp)
  8009b1:	e8 87 ff ff ff       	call   80093d <memmove>
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c3:	89 c6                	mov    %eax,%esi
  8009c5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c8:	eb 1a                	jmp    8009e4 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ca:	0f b6 08             	movzbl (%eax),%ecx
  8009cd:	0f b6 1a             	movzbl (%edx),%ebx
  8009d0:	38 d9                	cmp    %bl,%cl
  8009d2:	74 0a                	je     8009de <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009d4:	0f b6 c1             	movzbl %cl,%eax
  8009d7:	0f b6 db             	movzbl %bl,%ebx
  8009da:	29 d8                	sub    %ebx,%eax
  8009dc:	eb 0f                	jmp    8009ed <memcmp+0x35>
		s1++, s2++;
  8009de:	83 c0 01             	add    $0x1,%eax
  8009e1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e4:	39 f0                	cmp    %esi,%eax
  8009e6:	75 e2                	jne    8009ca <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ed:	5b                   	pop    %ebx
  8009ee:	5e                   	pop    %esi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	53                   	push   %ebx
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009f8:	89 c1                	mov    %eax,%ecx
  8009fa:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fd:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a01:	eb 0a                	jmp    800a0d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a03:	0f b6 10             	movzbl (%eax),%edx
  800a06:	39 da                	cmp    %ebx,%edx
  800a08:	74 07                	je     800a11 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	39 c8                	cmp    %ecx,%eax
  800a0f:	72 f2                	jb     800a03 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a11:	5b                   	pop    %ebx
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a20:	eb 03                	jmp    800a25 <strtol+0x11>
		s++;
  800a22:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a25:	0f b6 01             	movzbl (%ecx),%eax
  800a28:	3c 20                	cmp    $0x20,%al
  800a2a:	74 f6                	je     800a22 <strtol+0xe>
  800a2c:	3c 09                	cmp    $0x9,%al
  800a2e:	74 f2                	je     800a22 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a30:	3c 2b                	cmp    $0x2b,%al
  800a32:	75 0a                	jne    800a3e <strtol+0x2a>
		s++;
  800a34:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a37:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3c:	eb 11                	jmp    800a4f <strtol+0x3b>
  800a3e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a43:	3c 2d                	cmp    $0x2d,%al
  800a45:	75 08                	jne    800a4f <strtol+0x3b>
		s++, neg = 1;
  800a47:	83 c1 01             	add    $0x1,%ecx
  800a4a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a55:	75 15                	jne    800a6c <strtol+0x58>
  800a57:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5a:	75 10                	jne    800a6c <strtol+0x58>
  800a5c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a60:	75 7c                	jne    800ade <strtol+0xca>
		s += 2, base = 16;
  800a62:	83 c1 02             	add    $0x2,%ecx
  800a65:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a6a:	eb 16                	jmp    800a82 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a6c:	85 db                	test   %ebx,%ebx
  800a6e:	75 12                	jne    800a82 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a70:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a75:	80 39 30             	cmpb   $0x30,(%ecx)
  800a78:	75 08                	jne    800a82 <strtol+0x6e>
		s++, base = 8;
  800a7a:	83 c1 01             	add    $0x1,%ecx
  800a7d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a82:	b8 00 00 00 00       	mov    $0x0,%eax
  800a87:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a8a:	0f b6 11             	movzbl (%ecx),%edx
  800a8d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a90:	89 f3                	mov    %esi,%ebx
  800a92:	80 fb 09             	cmp    $0x9,%bl
  800a95:	77 08                	ja     800a9f <strtol+0x8b>
			dig = *s - '0';
  800a97:	0f be d2             	movsbl %dl,%edx
  800a9a:	83 ea 30             	sub    $0x30,%edx
  800a9d:	eb 22                	jmp    800ac1 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a9f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa2:	89 f3                	mov    %esi,%ebx
  800aa4:	80 fb 19             	cmp    $0x19,%bl
  800aa7:	77 08                	ja     800ab1 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aa9:	0f be d2             	movsbl %dl,%edx
  800aac:	83 ea 57             	sub    $0x57,%edx
  800aaf:	eb 10                	jmp    800ac1 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ab1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab4:	89 f3                	mov    %esi,%ebx
  800ab6:	80 fb 19             	cmp    $0x19,%bl
  800ab9:	77 16                	ja     800ad1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800abb:	0f be d2             	movsbl %dl,%edx
  800abe:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ac1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac4:	7d 0b                	jge    800ad1 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ac6:	83 c1 01             	add    $0x1,%ecx
  800ac9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800acd:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800acf:	eb b9                	jmp    800a8a <strtol+0x76>

	if (endptr)
  800ad1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad5:	74 0d                	je     800ae4 <strtol+0xd0>
		*endptr = (char *) s;
  800ad7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ada:	89 0e                	mov    %ecx,(%esi)
  800adc:	eb 06                	jmp    800ae4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ade:	85 db                	test   %ebx,%ebx
  800ae0:	74 98                	je     800a7a <strtol+0x66>
  800ae2:	eb 9e                	jmp    800a82 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ae4:	89 c2                	mov    %eax,%edx
  800ae6:	f7 da                	neg    %edx
  800ae8:	85 ff                	test   %edi,%edi
  800aea:	0f 45 c2             	cmovne %edx,%eax
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af8:	b8 00 00 00 00       	mov    $0x0,%eax
  800afd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b00:	8b 55 08             	mov    0x8(%ebp),%edx
  800b03:	89 c3                	mov    %eax,%ebx
  800b05:	89 c7                	mov    %eax,%edi
  800b07:	89 c6                	mov    %eax,%esi
  800b09:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b16:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b20:	89 d1                	mov    %edx,%ecx
  800b22:	89 d3                	mov    %edx,%ebx
  800b24:	89 d7                	mov    %edx,%edi
  800b26:	89 d6                	mov    %edx,%esi
  800b28:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b42:	8b 55 08             	mov    0x8(%ebp),%edx
  800b45:	89 cb                	mov    %ecx,%ebx
  800b47:	89 cf                	mov    %ecx,%edi
  800b49:	89 ce                	mov    %ecx,%esi
  800b4b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	7e 17                	jle    800b68 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b51:	83 ec 0c             	sub    $0xc,%esp
  800b54:	50                   	push   %eax
  800b55:	6a 03                	push   $0x3
  800b57:	68 7f 2a 80 00       	push   $0x802a7f
  800b5c:	6a 23                	push   $0x23
  800b5e:	68 9c 2a 80 00       	push   $0x802a9c
  800b63:	e8 e5 f5 ff ff       	call   80014d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5f                   	pop    %edi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b76:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b80:	89 d1                	mov    %edx,%ecx
  800b82:	89 d3                	mov    %edx,%ebx
  800b84:	89 d7                	mov    %edx,%edi
  800b86:	89 d6                	mov    %edx,%esi
  800b88:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_yield>:

void
sys_yield(void)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b9f:	89 d1                	mov    %edx,%ecx
  800ba1:	89 d3                	mov    %edx,%ebx
  800ba3:	89 d7                	mov    %edx,%edi
  800ba5:	89 d6                	mov    %edx,%esi
  800ba7:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb7:	be 00 00 00 00       	mov    $0x0,%esi
  800bbc:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bca:	89 f7                	mov    %esi,%edi
  800bcc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	7e 17                	jle    800be9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	50                   	push   %eax
  800bd6:	6a 04                	push   $0x4
  800bd8:	68 7f 2a 80 00       	push   $0x802a7f
  800bdd:	6a 23                	push   $0x23
  800bdf:	68 9c 2a 80 00       	push   $0x802a9c
  800be4:	e8 64 f5 ff ff       	call   80014d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800bfa:	b8 05 00 00 00       	mov    $0x5,%eax
  800bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c08:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7e 17                	jle    800c2b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c14:	83 ec 0c             	sub    $0xc,%esp
  800c17:	50                   	push   %eax
  800c18:	6a 05                	push   $0x5
  800c1a:	68 7f 2a 80 00       	push   $0x802a7f
  800c1f:	6a 23                	push   $0x23
  800c21:	68 9c 2a 80 00       	push   $0x802a9c
  800c26:	e8 22 f5 ff ff       	call   80014d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800c41:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800c54:	7e 17                	jle    800c6d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c56:	83 ec 0c             	sub    $0xc,%esp
  800c59:	50                   	push   %eax
  800c5a:	6a 06                	push   $0x6
  800c5c:	68 7f 2a 80 00       	push   $0x802a7f
  800c61:	6a 23                	push   $0x23
  800c63:	68 9c 2a 80 00       	push   $0x802a9c
  800c68:	e8 e0 f4 ff ff       	call   80014d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c83:	b8 08 00 00 00       	mov    $0x8,%eax
  800c88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8e:	89 df                	mov    %ebx,%edi
  800c90:	89 de                	mov    %ebx,%esi
  800c92:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7e 17                	jle    800caf <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c98:	83 ec 0c             	sub    $0xc,%esp
  800c9b:	50                   	push   %eax
  800c9c:	6a 08                	push   $0x8
  800c9e:	68 7f 2a 80 00       	push   $0x802a7f
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 9c 2a 80 00       	push   $0x802a9c
  800caa:	e8 9e f4 ff ff       	call   80014d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc5:	b8 09 00 00 00       	mov    $0x9,%eax
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7e 17                	jle    800cf1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cda:	83 ec 0c             	sub    $0xc,%esp
  800cdd:	50                   	push   %eax
  800cde:	6a 09                	push   $0x9
  800ce0:	68 7f 2a 80 00       	push   $0x802a7f
  800ce5:	6a 23                	push   $0x23
  800ce7:	68 9c 2a 80 00       	push   $0x802a9c
  800cec:	e8 5c f4 ff ff       	call   80014d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d07:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	89 df                	mov    %ebx,%edi
  800d14:	89 de                	mov    %ebx,%esi
  800d16:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7e 17                	jle    800d33 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1c:	83 ec 0c             	sub    $0xc,%esp
  800d1f:	50                   	push   %eax
  800d20:	6a 0a                	push   $0xa
  800d22:	68 7f 2a 80 00       	push   $0x802a7f
  800d27:	6a 23                	push   $0x23
  800d29:	68 9c 2a 80 00       	push   $0x802a9c
  800d2e:	e8 1a f4 ff ff       	call   80014d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d41:	be 00 00 00 00       	mov    $0x0,%esi
  800d46:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d54:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d57:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d67:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	89 cb                	mov    %ecx,%ebx
  800d76:	89 cf                	mov    %ecx,%edi
  800d78:	89 ce                	mov    %ecx,%esi
  800d7a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	7e 17                	jle    800d97 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	50                   	push   %eax
  800d84:	6a 0d                	push   $0xd
  800d86:	68 7f 2a 80 00       	push   $0x802a7f
  800d8b:	6a 23                	push   $0x23
  800d8d:	68 9c 2a 80 00       	push   $0x802a9c
  800d92:	e8 b6 f3 ff ff       	call   80014d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9a:	5b                   	pop    %ebx
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	57                   	push   %edi
  800da3:	56                   	push   %esi
  800da4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da5:	ba 00 00 00 00       	mov    $0x0,%edx
  800daa:	b8 0e 00 00 00       	mov    $0xe,%eax
  800daf:	89 d1                	mov    %edx,%ecx
  800db1:	89 d3                	mov    %edx,%ebx
  800db3:	89 d7                	mov    %edx,%edi
  800db5:	89 d6                	mov    %edx,%esi
  800db7:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800db9:	5b                   	pop    %ebx
  800dba:	5e                   	pop    %esi
  800dbb:	5f                   	pop    %edi
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    

00800dbe <sys_transmit_packet>:

int
sys_transmit_packet(void *buf, size_t size)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	57                   	push   %edi
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
  800dc4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcc:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd7:	89 df                	mov    %ebx,%edi
  800dd9:	89 de                	mov    %ebx,%esi
  800ddb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	7e 17                	jle    800df8 <sys_transmit_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de1:	83 ec 0c             	sub    $0xc,%esp
  800de4:	50                   	push   %eax
  800de5:	6a 0f                	push   $0xf
  800de7:	68 7f 2a 80 00       	push   $0x802a7f
  800dec:	6a 23                	push   $0x23
  800dee:	68 9c 2a 80 00       	push   $0x802a9c
  800df3:	e8 55 f3 ff ff       	call   80014d <_panic>
int
sys_transmit_packet(void *buf, size_t size)
{
	return syscall(SYS_transmit_packet, 1,
		(uint32_t) buf, (uint32_t) size, 0, 0, 0);
}
  800df8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <sys_receive_packet>:

int
sys_receive_packet(void *buf, size_t *size_store)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
  800e06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0e:	b8 10 00 00 00       	mov    $0x10,%eax
  800e13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e16:	8b 55 08             	mov    0x8(%ebp),%edx
  800e19:	89 df                	mov    %ebx,%edi
  800e1b:	89 de                	mov    %ebx,%esi
  800e1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	7e 17                	jle    800e3a <sys_receive_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e23:	83 ec 0c             	sub    $0xc,%esp
  800e26:	50                   	push   %eax
  800e27:	6a 10                	push   $0x10
  800e29:	68 7f 2a 80 00       	push   $0x802a7f
  800e2e:	6a 23                	push   $0x23
  800e30:	68 9c 2a 80 00       	push   $0x802a9c
  800e35:	e8 13 f3 ff ff       	call   80014d <_panic>
int
sys_receive_packet(void *buf, size_t *size_store)
{
	return syscall(SYS_receive_packet, 1,
		(uint32_t) buf, (uint32_t) size_store, 0, 0, 0);
}
  800e3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    

00800e42 <sys_get_mac_address>:

int
sys_get_mac_address(void *buf)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	57                   	push   %edi
  800e46:	56                   	push   %esi
  800e47:	53                   	push   %ebx
  800e48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e50:	b8 11 00 00 00       	mov    $0x11,%eax
  800e55:	8b 55 08             	mov    0x8(%ebp),%edx
  800e58:	89 cb                	mov    %ecx,%ebx
  800e5a:	89 cf                	mov    %ecx,%edi
  800e5c:	89 ce                	mov    %ecx,%esi
  800e5e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e60:	85 c0                	test   %eax,%eax
  800e62:	7e 17                	jle    800e7b <sys_get_mac_address+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e64:	83 ec 0c             	sub    $0xc,%esp
  800e67:	50                   	push   %eax
  800e68:	6a 11                	push   $0x11
  800e6a:	68 7f 2a 80 00       	push   $0x802a7f
  800e6f:	6a 23                	push   $0x23
  800e71:	68 9c 2a 80 00       	push   $0x802a9c
  800e76:	e8 d2 f2 ff ff       	call   80014d <_panic>
int
sys_get_mac_address(void *buf)
{
	return syscall(SYS_get_mac_address, 1,
		(uint32_t) buf, 0, 0, 0, 0);
}
  800e7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7e:	5b                   	pop    %ebx
  800e7f:	5e                   	pop    %esi
  800e80:	5f                   	pop    %edi
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	53                   	push   %ebx
  800e87:	83 ec 04             	sub    $0x4,%esp
  800e8a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e8d:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800e8f:	89 da                	mov    %ebx,%edx
  800e91:	c1 ea 0c             	shr    $0xc,%edx
	pte_t pte = uvpt[pn];
  800e94:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  800e9b:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e9f:	74 05                	je     800ea6 <pgfault+0x23>
  800ea1:	f6 c6 08             	test   $0x8,%dh
  800ea4:	75 14                	jne    800eba <pgfault+0x37>
		panic("fork pgfault handler: does not handle this fault");
  800ea6:	83 ec 04             	sub    $0x4,%esp
  800ea9:	68 ac 2a 80 00       	push   $0x802aac
  800eae:	6a 1f                	push   $0x1f
  800eb0:	68 dd 2a 80 00       	push   $0x802add
  800eb5:	e8 93 f2 ff ff       	call   80014d <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800eba:	83 ec 04             	sub    $0x4,%esp
  800ebd:	6a 07                	push   $0x7
  800ebf:	68 00 f0 7f 00       	push   $0x7ff000
  800ec4:	6a 00                	push   $0x0
  800ec6:	e8 e3 fc ff ff       	call   800bae <sys_page_alloc>
  800ecb:	83 c4 10             	add    $0x10,%esp
  800ece:	85 c0                	test   %eax,%eax
  800ed0:	79 12                	jns    800ee4 <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  800ed2:	50                   	push   %eax
  800ed3:	68 e8 2a 80 00       	push   $0x802ae8
  800ed8:	6a 2b                	push   $0x2b
  800eda:	68 dd 2a 80 00       	push   $0x802add
  800edf:	e8 69 f2 ff ff       	call   80014d <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800ee4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800eea:	83 ec 04             	sub    $0x4,%esp
  800eed:	68 00 10 00 00       	push   $0x1000
  800ef2:	53                   	push   %ebx
  800ef3:	68 00 f0 7f 00       	push   $0x7ff000
  800ef8:	e8 40 fa ff ff       	call   80093d <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800efd:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f04:	53                   	push   %ebx
  800f05:	6a 00                	push   $0x0
  800f07:	68 00 f0 7f 00       	push   $0x7ff000
  800f0c:	6a 00                	push   $0x0
  800f0e:	e8 de fc ff ff       	call   800bf1 <sys_page_map>
  800f13:	83 c4 20             	add    $0x20,%esp
  800f16:	85 c0                	test   %eax,%eax
  800f18:	79 12                	jns    800f2c <pgfault+0xa9>
		panic("sys_page_map: %e", r);
  800f1a:	50                   	push   %eax
  800f1b:	68 fb 2a 80 00       	push   $0x802afb
  800f20:	6a 33                	push   $0x33
  800f22:	68 dd 2a 80 00       	push   $0x802add
  800f27:	e8 21 f2 ff ff       	call   80014d <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f2c:	83 ec 08             	sub    $0x8,%esp
  800f2f:	68 00 f0 7f 00       	push   $0x7ff000
  800f34:	6a 00                	push   $0x0
  800f36:	e8 f8 fc ff ff       	call   800c33 <sys_page_unmap>
  800f3b:	83 c4 10             	add    $0x10,%esp
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	79 12                	jns    800f54 <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  800f42:	50                   	push   %eax
  800f43:	68 0c 2b 80 00       	push   $0x802b0c
  800f48:	6a 37                	push   $0x37
  800f4a:	68 dd 2a 80 00       	push   $0x802add
  800f4f:	e8 f9 f1 ff ff       	call   80014d <_panic>
}
  800f54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f57:	c9                   	leave  
  800f58:	c3                   	ret    

00800f59 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	57                   	push   %edi
  800f5d:	56                   	push   %esi
  800f5e:	53                   	push   %ebx
  800f5f:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  800f62:	68 83 0e 80 00       	push   $0x800e83
  800f67:	e8 46 13 00 00       	call   8022b2 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f6c:	b8 07 00 00 00       	mov    $0x7,%eax
  800f71:	cd 30                	int    $0x30
  800f73:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f76:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Create child
	envid_t envid = sys_exofork();
	if (envid < 0) {
  800f79:	83 c4 10             	add    $0x10,%esp
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	79 15                	jns    800f95 <fork+0x3c>
		panic("sys_exofork: %e", envid);
  800f80:	50                   	push   %eax
  800f81:	68 1f 2b 80 00       	push   $0x802b1f
  800f86:	68 93 00 00 00       	push   $0x93
  800f8b:	68 dd 2a 80 00       	push   $0x802add
  800f90:	e8 b8 f1 ff ff       	call   80014d <_panic>
		return envid;
	}

	// If we are the child, fix thisenv.
	if (envid == 0) {
  800f95:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f99:	75 21                	jne    800fbc <fork+0x63>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f9b:	e8 d0 fb ff ff       	call   800b70 <sys_getenvid>
  800fa0:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fa5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fa8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fad:	a3 0c 40 80 00       	mov    %eax,0x80400c
		return 0;
  800fb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb7:	e9 5a 01 00 00       	jmp    801116 <fork+0x1bd>
	// We are the parent!
	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle the
	// fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), PTE_P | PTE_U | PTE_W);
  800fbc:	83 ec 04             	sub    $0x4,%esp
  800fbf:	6a 07                	push   $0x7
  800fc1:	68 00 f0 bf ee       	push   $0xeebff000
  800fc6:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800fc9:	57                   	push   %edi
  800fca:	e8 df fb ff ff       	call   800bae <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  800fcf:	83 c4 08             	add    $0x8,%esp
  800fd2:	68 f7 22 80 00       	push   $0x8022f7
  800fd7:	57                   	push   %edi
  800fd8:	e8 1c fd ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>
  800fdd:	83 c4 10             	add    $0x10,%esp

	// Copy our address space to child. Be careful not to copy the exception
	// stack too, so go until USTACKTOP instead of UTOP.
	unsigned pn;
	for (pn = UTEXT/PGSIZE; pn < USTACKTOP/PGSIZE; pn++) {
  800fe0:	bb 00 08 00 00       	mov    $0x800,%ebx
static int
duppage(envid_t envid, unsigned pn)
{
	// Check if the page table that contains the PTE we want is allocated
	// using UVPD. If it is not, just don't map anything, and silently succeed.
	if (!(uvpd[pn/NPTENTRIES] & PTE_P))
  800fe5:	89 d8                	mov    %ebx,%eax
  800fe7:	c1 e8 0a             	shr    $0xa,%eax
  800fea:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff1:	a8 01                	test   $0x1,%al
  800ff3:	0f 84 e2 00 00 00    	je     8010db <fork+0x182>
		return 0;

	// Retrieve the PTE using UVPT
	pte_t pte = uvpt[pn];
  800ff9:	8b 34 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%esi

	// If the page is present, duplicate according to it's permissions
	if (pte & PTE_P) {
  801000:	f7 c6 01 00 00 00    	test   $0x1,%esi
  801006:	0f 84 cf 00 00 00    	je     8010db <fork+0x182>
		int r;
		uint32_t perm = pte & PTE_SYSCALL;
  80100c:	89 f0                	mov    %esi,%eax
  80100e:	25 07 0e 00 00       	and    $0xe07,%eax
  801013:	89 df                	mov    %ebx,%edi
  801015:	c1 e7 0c             	shl    $0xc,%edi
		void *va = (void *) (pn * PGSIZE);

		// If PTE_SHARE is enabled, share it by just copying the
		// pte, which can be done by mapping on the same address
		// with the same permissions, even if it is writable
		if (pte & PTE_SHARE) {
  801018:	f7 c6 00 04 00 00    	test   $0x400,%esi
  80101e:	74 2d                	je     80104d <fork+0xf4>
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  801020:	83 ec 0c             	sub    $0xc,%esp
  801023:	50                   	push   %eax
  801024:	57                   	push   %edi
  801025:	ff 75 e4             	pushl  -0x1c(%ebp)
  801028:	57                   	push   %edi
  801029:	6a 00                	push   $0x0
  80102b:	e8 c1 fb ff ff       	call   800bf1 <sys_page_map>
  801030:	83 c4 20             	add    $0x20,%esp
  801033:	85 c0                	test   %eax,%eax
  801035:	0f 89 a0 00 00 00    	jns    8010db <fork+0x182>
				panic("sys_page_map: %e", r);
  80103b:	50                   	push   %eax
  80103c:	68 fb 2a 80 00       	push   $0x802afb
  801041:	6a 5c                	push   $0x5c
  801043:	68 dd 2a 80 00       	push   $0x802add
  801048:	e8 00 f1 ff ff       	call   80014d <_panic>
				return r;
			}
		// If writable or COW, make it COW on parent and child
		} else if (pte & (PTE_W | PTE_COW)) {
  80104d:	f7 c6 02 08 00 00    	test   $0x802,%esi
  801053:	74 5d                	je     8010b2 <fork+0x159>
			perm &= ~PTE_W;  // Remove PTE_W, so it faults
  801055:	81 e6 05 0e 00 00    	and    $0xe05,%esi
			perm |= PTE_COW; // Make it PTE_COW
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  80105b:	81 ce 00 08 00 00    	or     $0x800,%esi
  801061:	83 ec 0c             	sub    $0xc,%esp
  801064:	56                   	push   %esi
  801065:	57                   	push   %edi
  801066:	ff 75 e4             	pushl  -0x1c(%ebp)
  801069:	57                   	push   %edi
  80106a:	6a 00                	push   $0x0
  80106c:	e8 80 fb ff ff       	call   800bf1 <sys_page_map>
  801071:	83 c4 20             	add    $0x20,%esp
  801074:	85 c0                	test   %eax,%eax
  801076:	79 12                	jns    80108a <fork+0x131>
				panic("sys_page_map: %e", r);
  801078:	50                   	push   %eax
  801079:	68 fb 2a 80 00       	push   $0x802afb
  80107e:	6a 65                	push   $0x65
  801080:	68 dd 2a 80 00       	push   $0x802add
  801085:	e8 c3 f0 ff ff       	call   80014d <_panic>
				return r;
			}
			// Change the permission on parent, mapping on itself
			if ((r = sys_page_map(0, va, 0, va, perm)) < 0) {
  80108a:	83 ec 0c             	sub    $0xc,%esp
  80108d:	56                   	push   %esi
  80108e:	57                   	push   %edi
  80108f:	6a 00                	push   $0x0
  801091:	57                   	push   %edi
  801092:	6a 00                	push   $0x0
  801094:	e8 58 fb ff ff       	call   800bf1 <sys_page_map>
  801099:	83 c4 20             	add    $0x20,%esp
  80109c:	85 c0                	test   %eax,%eax
  80109e:	79 3b                	jns    8010db <fork+0x182>
				panic("sys_page_map: %e", r);
  8010a0:	50                   	push   %eax
  8010a1:	68 fb 2a 80 00       	push   $0x802afb
  8010a6:	6a 6a                	push   $0x6a
  8010a8:	68 dd 2a 80 00       	push   $0x802add
  8010ad:	e8 9b f0 ff ff       	call   80014d <_panic>
				return r;
			}
		// If it is read-only, just share it.
		} else {
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  8010b2:	83 ec 0c             	sub    $0xc,%esp
  8010b5:	50                   	push   %eax
  8010b6:	57                   	push   %edi
  8010b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ba:	57                   	push   %edi
  8010bb:	6a 00                	push   $0x0
  8010bd:	e8 2f fb ff ff       	call   800bf1 <sys_page_map>
  8010c2:	83 c4 20             	add    $0x20,%esp
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	79 12                	jns    8010db <fork+0x182>
				panic("sys_page_map: %e", r);
  8010c9:	50                   	push   %eax
  8010ca:	68 fb 2a 80 00       	push   $0x802afb
  8010cf:	6a 71                	push   $0x71
  8010d1:	68 dd 2a 80 00       	push   $0x802add
  8010d6:	e8 72 f0 ff ff       	call   80014d <_panic>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);

	// Copy our address space to child. Be careful not to copy the exception
	// stack too, so go until USTACKTOP instead of UTOP.
	unsigned pn;
	for (pn = UTEXT/PGSIZE; pn < USTACKTOP/PGSIZE; pn++) {
  8010db:	83 c3 01             	add    $0x1,%ebx
  8010de:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  8010e4:	0f 85 fb fe ff ff    	jne    800fe5 <fork+0x8c>
		duppage(envid, pn);
	}

	// Make the child runnable
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8010ea:	83 ec 08             	sub    $0x8,%esp
  8010ed:	6a 02                	push   $0x2
  8010ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8010f2:	e8 7e fb ff ff       	call   800c75 <sys_env_set_status>
  8010f7:	83 c4 10             	add    $0x10,%esp
  8010fa:	85 c0                	test   %eax,%eax
  8010fc:	79 15                	jns    801113 <fork+0x1ba>
		panic("sys_env_set_status: %e", r);
  8010fe:	50                   	push   %eax
  8010ff:	68 2f 2b 80 00       	push   $0x802b2f
  801104:	68 af 00 00 00       	push   $0xaf
  801109:	68 dd 2a 80 00       	push   $0x802add
  80110e:	e8 3a f0 ff ff       	call   80014d <_panic>
		return r;
	}

	return envid;
  801113:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  801116:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801119:	5b                   	pop    %ebx
  80111a:	5e                   	pop    %esi
  80111b:	5f                   	pop    %edi
  80111c:	5d                   	pop    %ebp
  80111d:	c3                   	ret    

0080111e <sfork>:

// Challenge!
int
sfork(void)
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
  801121:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801124:	68 46 2b 80 00       	push   $0x802b46
  801129:	68 ba 00 00 00       	push   $0xba
  80112e:	68 dd 2a 80 00       	push   $0x802add
  801133:	e8 15 f0 ff ff       	call   80014d <_panic>

00801138 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80113b:	8b 45 08             	mov    0x8(%ebp),%eax
  80113e:	05 00 00 00 30       	add    $0x30000000,%eax
  801143:	c1 e8 0c             	shr    $0xc,%eax
}
  801146:	5d                   	pop    %ebp
  801147:	c3                   	ret    

00801148 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80114b:	8b 45 08             	mov    0x8(%ebp),%eax
  80114e:	05 00 00 00 30       	add    $0x30000000,%eax
  801153:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801158:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80115d:	5d                   	pop    %ebp
  80115e:	c3                   	ret    

0080115f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801165:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80116a:	89 c2                	mov    %eax,%edx
  80116c:	c1 ea 16             	shr    $0x16,%edx
  80116f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801176:	f6 c2 01             	test   $0x1,%dl
  801179:	74 11                	je     80118c <fd_alloc+0x2d>
  80117b:	89 c2                	mov    %eax,%edx
  80117d:	c1 ea 0c             	shr    $0xc,%edx
  801180:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801187:	f6 c2 01             	test   $0x1,%dl
  80118a:	75 09                	jne    801195 <fd_alloc+0x36>
			*fd_store = fd;
  80118c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80118e:	b8 00 00 00 00       	mov    $0x0,%eax
  801193:	eb 17                	jmp    8011ac <fd_alloc+0x4d>
  801195:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80119a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80119f:	75 c9                	jne    80116a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011a1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011a7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011ac:	5d                   	pop    %ebp
  8011ad:	c3                   	ret    

008011ae <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
  8011b1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011b4:	83 f8 1f             	cmp    $0x1f,%eax
  8011b7:	77 36                	ja     8011ef <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011b9:	c1 e0 0c             	shl    $0xc,%eax
  8011bc:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011c1:	89 c2                	mov    %eax,%edx
  8011c3:	c1 ea 16             	shr    $0x16,%edx
  8011c6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011cd:	f6 c2 01             	test   $0x1,%dl
  8011d0:	74 24                	je     8011f6 <fd_lookup+0x48>
  8011d2:	89 c2                	mov    %eax,%edx
  8011d4:	c1 ea 0c             	shr    $0xc,%edx
  8011d7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011de:	f6 c2 01             	test   $0x1,%dl
  8011e1:	74 1a                	je     8011fd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e6:	89 02                	mov    %eax,(%edx)
	return 0;
  8011e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ed:	eb 13                	jmp    801202 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f4:	eb 0c                	jmp    801202 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011fb:	eb 05                	jmp    801202 <fd_lookup+0x54>
  8011fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801202:	5d                   	pop    %ebp
  801203:	c3                   	ret    

00801204 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
  801207:	83 ec 08             	sub    $0x8,%esp
  80120a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120d:	ba dc 2b 80 00       	mov    $0x802bdc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801212:	eb 13                	jmp    801227 <dev_lookup+0x23>
  801214:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801217:	39 08                	cmp    %ecx,(%eax)
  801219:	75 0c                	jne    801227 <dev_lookup+0x23>
			*dev = devtab[i];
  80121b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80121e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801220:	b8 00 00 00 00       	mov    $0x0,%eax
  801225:	eb 2e                	jmp    801255 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801227:	8b 02                	mov    (%edx),%eax
  801229:	85 c0                	test   %eax,%eax
  80122b:	75 e7                	jne    801214 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80122d:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801232:	8b 40 48             	mov    0x48(%eax),%eax
  801235:	83 ec 04             	sub    $0x4,%esp
  801238:	51                   	push   %ecx
  801239:	50                   	push   %eax
  80123a:	68 5c 2b 80 00       	push   $0x802b5c
  80123f:	e8 e2 ef ff ff       	call   800226 <cprintf>
	*dev = 0;
  801244:	8b 45 0c             	mov    0xc(%ebp),%eax
  801247:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80124d:	83 c4 10             	add    $0x10,%esp
  801250:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801255:	c9                   	leave  
  801256:	c3                   	ret    

00801257 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	56                   	push   %esi
  80125b:	53                   	push   %ebx
  80125c:	83 ec 10             	sub    $0x10,%esp
  80125f:	8b 75 08             	mov    0x8(%ebp),%esi
  801262:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801265:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801268:	50                   	push   %eax
  801269:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80126f:	c1 e8 0c             	shr    $0xc,%eax
  801272:	50                   	push   %eax
  801273:	e8 36 ff ff ff       	call   8011ae <fd_lookup>
  801278:	83 c4 08             	add    $0x8,%esp
  80127b:	85 c0                	test   %eax,%eax
  80127d:	78 05                	js     801284 <fd_close+0x2d>
	    || fd != fd2)
  80127f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801282:	74 0c                	je     801290 <fd_close+0x39>
		return (must_exist ? r : 0);
  801284:	84 db                	test   %bl,%bl
  801286:	ba 00 00 00 00       	mov    $0x0,%edx
  80128b:	0f 44 c2             	cmove  %edx,%eax
  80128e:	eb 41                	jmp    8012d1 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801290:	83 ec 08             	sub    $0x8,%esp
  801293:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801296:	50                   	push   %eax
  801297:	ff 36                	pushl  (%esi)
  801299:	e8 66 ff ff ff       	call   801204 <dev_lookup>
  80129e:	89 c3                	mov    %eax,%ebx
  8012a0:	83 c4 10             	add    $0x10,%esp
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	78 1a                	js     8012c1 <fd_close+0x6a>
		if (dev->dev_close)
  8012a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012aa:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012ad:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	74 0b                	je     8012c1 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012b6:	83 ec 0c             	sub    $0xc,%esp
  8012b9:	56                   	push   %esi
  8012ba:	ff d0                	call   *%eax
  8012bc:	89 c3                	mov    %eax,%ebx
  8012be:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012c1:	83 ec 08             	sub    $0x8,%esp
  8012c4:	56                   	push   %esi
  8012c5:	6a 00                	push   $0x0
  8012c7:	e8 67 f9 ff ff       	call   800c33 <sys_page_unmap>
	return r;
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	89 d8                	mov    %ebx,%eax
}
  8012d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d4:	5b                   	pop    %ebx
  8012d5:	5e                   	pop    %esi
  8012d6:	5d                   	pop    %ebp
  8012d7:	c3                   	ret    

008012d8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e1:	50                   	push   %eax
  8012e2:	ff 75 08             	pushl  0x8(%ebp)
  8012e5:	e8 c4 fe ff ff       	call   8011ae <fd_lookup>
  8012ea:	83 c4 08             	add    $0x8,%esp
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	78 10                	js     801301 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012f1:	83 ec 08             	sub    $0x8,%esp
  8012f4:	6a 01                	push   $0x1
  8012f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8012f9:	e8 59 ff ff ff       	call   801257 <fd_close>
  8012fe:	83 c4 10             	add    $0x10,%esp
}
  801301:	c9                   	leave  
  801302:	c3                   	ret    

00801303 <close_all>:

void
close_all(void)
{
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
  801306:	53                   	push   %ebx
  801307:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80130a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80130f:	83 ec 0c             	sub    $0xc,%esp
  801312:	53                   	push   %ebx
  801313:	e8 c0 ff ff ff       	call   8012d8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801318:	83 c3 01             	add    $0x1,%ebx
  80131b:	83 c4 10             	add    $0x10,%esp
  80131e:	83 fb 20             	cmp    $0x20,%ebx
  801321:	75 ec                	jne    80130f <close_all+0xc>
		close(i);
}
  801323:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801326:	c9                   	leave  
  801327:	c3                   	ret    

00801328 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801328:	55                   	push   %ebp
  801329:	89 e5                	mov    %esp,%ebp
  80132b:	57                   	push   %edi
  80132c:	56                   	push   %esi
  80132d:	53                   	push   %ebx
  80132e:	83 ec 2c             	sub    $0x2c,%esp
  801331:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801334:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801337:	50                   	push   %eax
  801338:	ff 75 08             	pushl  0x8(%ebp)
  80133b:	e8 6e fe ff ff       	call   8011ae <fd_lookup>
  801340:	83 c4 08             	add    $0x8,%esp
  801343:	85 c0                	test   %eax,%eax
  801345:	0f 88 c1 00 00 00    	js     80140c <dup+0xe4>
		return r;
	close(newfdnum);
  80134b:	83 ec 0c             	sub    $0xc,%esp
  80134e:	56                   	push   %esi
  80134f:	e8 84 ff ff ff       	call   8012d8 <close>

	newfd = INDEX2FD(newfdnum);
  801354:	89 f3                	mov    %esi,%ebx
  801356:	c1 e3 0c             	shl    $0xc,%ebx
  801359:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80135f:	83 c4 04             	add    $0x4,%esp
  801362:	ff 75 e4             	pushl  -0x1c(%ebp)
  801365:	e8 de fd ff ff       	call   801148 <fd2data>
  80136a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80136c:	89 1c 24             	mov    %ebx,(%esp)
  80136f:	e8 d4 fd ff ff       	call   801148 <fd2data>
  801374:	83 c4 10             	add    $0x10,%esp
  801377:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80137a:	89 f8                	mov    %edi,%eax
  80137c:	c1 e8 16             	shr    $0x16,%eax
  80137f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801386:	a8 01                	test   $0x1,%al
  801388:	74 37                	je     8013c1 <dup+0x99>
  80138a:	89 f8                	mov    %edi,%eax
  80138c:	c1 e8 0c             	shr    $0xc,%eax
  80138f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801396:	f6 c2 01             	test   $0x1,%dl
  801399:	74 26                	je     8013c1 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80139b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a2:	83 ec 0c             	sub    $0xc,%esp
  8013a5:	25 07 0e 00 00       	and    $0xe07,%eax
  8013aa:	50                   	push   %eax
  8013ab:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013ae:	6a 00                	push   $0x0
  8013b0:	57                   	push   %edi
  8013b1:	6a 00                	push   $0x0
  8013b3:	e8 39 f8 ff ff       	call   800bf1 <sys_page_map>
  8013b8:	89 c7                	mov    %eax,%edi
  8013ba:	83 c4 20             	add    $0x20,%esp
  8013bd:	85 c0                	test   %eax,%eax
  8013bf:	78 2e                	js     8013ef <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013c4:	89 d0                	mov    %edx,%eax
  8013c6:	c1 e8 0c             	shr    $0xc,%eax
  8013c9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d0:	83 ec 0c             	sub    $0xc,%esp
  8013d3:	25 07 0e 00 00       	and    $0xe07,%eax
  8013d8:	50                   	push   %eax
  8013d9:	53                   	push   %ebx
  8013da:	6a 00                	push   $0x0
  8013dc:	52                   	push   %edx
  8013dd:	6a 00                	push   $0x0
  8013df:	e8 0d f8 ff ff       	call   800bf1 <sys_page_map>
  8013e4:	89 c7                	mov    %eax,%edi
  8013e6:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013e9:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013eb:	85 ff                	test   %edi,%edi
  8013ed:	79 1d                	jns    80140c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013ef:	83 ec 08             	sub    $0x8,%esp
  8013f2:	53                   	push   %ebx
  8013f3:	6a 00                	push   $0x0
  8013f5:	e8 39 f8 ff ff       	call   800c33 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013fa:	83 c4 08             	add    $0x8,%esp
  8013fd:	ff 75 d4             	pushl  -0x2c(%ebp)
  801400:	6a 00                	push   $0x0
  801402:	e8 2c f8 ff ff       	call   800c33 <sys_page_unmap>
	return r;
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	89 f8                	mov    %edi,%eax
}
  80140c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80140f:	5b                   	pop    %ebx
  801410:	5e                   	pop    %esi
  801411:	5f                   	pop    %edi
  801412:	5d                   	pop    %ebp
  801413:	c3                   	ret    

00801414 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	53                   	push   %ebx
  801418:	83 ec 14             	sub    $0x14,%esp
  80141b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80141e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801421:	50                   	push   %eax
  801422:	53                   	push   %ebx
  801423:	e8 86 fd ff ff       	call   8011ae <fd_lookup>
  801428:	83 c4 08             	add    $0x8,%esp
  80142b:	89 c2                	mov    %eax,%edx
  80142d:	85 c0                	test   %eax,%eax
  80142f:	78 6d                	js     80149e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801431:	83 ec 08             	sub    $0x8,%esp
  801434:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801437:	50                   	push   %eax
  801438:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143b:	ff 30                	pushl  (%eax)
  80143d:	e8 c2 fd ff ff       	call   801204 <dev_lookup>
  801442:	83 c4 10             	add    $0x10,%esp
  801445:	85 c0                	test   %eax,%eax
  801447:	78 4c                	js     801495 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801449:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80144c:	8b 42 08             	mov    0x8(%edx),%eax
  80144f:	83 e0 03             	and    $0x3,%eax
  801452:	83 f8 01             	cmp    $0x1,%eax
  801455:	75 21                	jne    801478 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801457:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80145c:	8b 40 48             	mov    0x48(%eax),%eax
  80145f:	83 ec 04             	sub    $0x4,%esp
  801462:	53                   	push   %ebx
  801463:	50                   	push   %eax
  801464:	68 a0 2b 80 00       	push   $0x802ba0
  801469:	e8 b8 ed ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801476:	eb 26                	jmp    80149e <read+0x8a>
	}
	if (!dev->dev_read)
  801478:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147b:	8b 40 08             	mov    0x8(%eax),%eax
  80147e:	85 c0                	test   %eax,%eax
  801480:	74 17                	je     801499 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801482:	83 ec 04             	sub    $0x4,%esp
  801485:	ff 75 10             	pushl  0x10(%ebp)
  801488:	ff 75 0c             	pushl  0xc(%ebp)
  80148b:	52                   	push   %edx
  80148c:	ff d0                	call   *%eax
  80148e:	89 c2                	mov    %eax,%edx
  801490:	83 c4 10             	add    $0x10,%esp
  801493:	eb 09                	jmp    80149e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801495:	89 c2                	mov    %eax,%edx
  801497:	eb 05                	jmp    80149e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801499:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80149e:	89 d0                	mov    %edx,%eax
  8014a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a3:	c9                   	leave  
  8014a4:	c3                   	ret    

008014a5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014a5:	55                   	push   %ebp
  8014a6:	89 e5                	mov    %esp,%ebp
  8014a8:	57                   	push   %edi
  8014a9:	56                   	push   %esi
  8014aa:	53                   	push   %ebx
  8014ab:	83 ec 0c             	sub    $0xc,%esp
  8014ae:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014b1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014b9:	eb 21                	jmp    8014dc <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014bb:	83 ec 04             	sub    $0x4,%esp
  8014be:	89 f0                	mov    %esi,%eax
  8014c0:	29 d8                	sub    %ebx,%eax
  8014c2:	50                   	push   %eax
  8014c3:	89 d8                	mov    %ebx,%eax
  8014c5:	03 45 0c             	add    0xc(%ebp),%eax
  8014c8:	50                   	push   %eax
  8014c9:	57                   	push   %edi
  8014ca:	e8 45 ff ff ff       	call   801414 <read>
		if (m < 0)
  8014cf:	83 c4 10             	add    $0x10,%esp
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	78 10                	js     8014e6 <readn+0x41>
			return m;
		if (m == 0)
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	74 0a                	je     8014e4 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014da:	01 c3                	add    %eax,%ebx
  8014dc:	39 f3                	cmp    %esi,%ebx
  8014de:	72 db                	jb     8014bb <readn+0x16>
  8014e0:	89 d8                	mov    %ebx,%eax
  8014e2:	eb 02                	jmp    8014e6 <readn+0x41>
  8014e4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e9:	5b                   	pop    %ebx
  8014ea:	5e                   	pop    %esi
  8014eb:	5f                   	pop    %edi
  8014ec:	5d                   	pop    %ebp
  8014ed:	c3                   	ret    

008014ee <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	53                   	push   %ebx
  8014f2:	83 ec 14             	sub    $0x14,%esp
  8014f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014fb:	50                   	push   %eax
  8014fc:	53                   	push   %ebx
  8014fd:	e8 ac fc ff ff       	call   8011ae <fd_lookup>
  801502:	83 c4 08             	add    $0x8,%esp
  801505:	89 c2                	mov    %eax,%edx
  801507:	85 c0                	test   %eax,%eax
  801509:	78 68                	js     801573 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150b:	83 ec 08             	sub    $0x8,%esp
  80150e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801511:	50                   	push   %eax
  801512:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801515:	ff 30                	pushl  (%eax)
  801517:	e8 e8 fc ff ff       	call   801204 <dev_lookup>
  80151c:	83 c4 10             	add    $0x10,%esp
  80151f:	85 c0                	test   %eax,%eax
  801521:	78 47                	js     80156a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801523:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801526:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80152a:	75 21                	jne    80154d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80152c:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801531:	8b 40 48             	mov    0x48(%eax),%eax
  801534:	83 ec 04             	sub    $0x4,%esp
  801537:	53                   	push   %ebx
  801538:	50                   	push   %eax
  801539:	68 bc 2b 80 00       	push   $0x802bbc
  80153e:	e8 e3 ec ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80154b:	eb 26                	jmp    801573 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80154d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801550:	8b 52 0c             	mov    0xc(%edx),%edx
  801553:	85 d2                	test   %edx,%edx
  801555:	74 17                	je     80156e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801557:	83 ec 04             	sub    $0x4,%esp
  80155a:	ff 75 10             	pushl  0x10(%ebp)
  80155d:	ff 75 0c             	pushl  0xc(%ebp)
  801560:	50                   	push   %eax
  801561:	ff d2                	call   *%edx
  801563:	89 c2                	mov    %eax,%edx
  801565:	83 c4 10             	add    $0x10,%esp
  801568:	eb 09                	jmp    801573 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156a:	89 c2                	mov    %eax,%edx
  80156c:	eb 05                	jmp    801573 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80156e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801573:	89 d0                	mov    %edx,%eax
  801575:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801578:	c9                   	leave  
  801579:	c3                   	ret    

0080157a <seek>:

int
seek(int fdnum, off_t offset)
{
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801580:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801583:	50                   	push   %eax
  801584:	ff 75 08             	pushl  0x8(%ebp)
  801587:	e8 22 fc ff ff       	call   8011ae <fd_lookup>
  80158c:	83 c4 08             	add    $0x8,%esp
  80158f:	85 c0                	test   %eax,%eax
  801591:	78 0e                	js     8015a1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801593:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801596:	8b 55 0c             	mov    0xc(%ebp),%edx
  801599:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80159c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015a1:	c9                   	leave  
  8015a2:	c3                   	ret    

008015a3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	53                   	push   %ebx
  8015a7:	83 ec 14             	sub    $0x14,%esp
  8015aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b0:	50                   	push   %eax
  8015b1:	53                   	push   %ebx
  8015b2:	e8 f7 fb ff ff       	call   8011ae <fd_lookup>
  8015b7:	83 c4 08             	add    $0x8,%esp
  8015ba:	89 c2                	mov    %eax,%edx
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	78 65                	js     801625 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c0:	83 ec 08             	sub    $0x8,%esp
  8015c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c6:	50                   	push   %eax
  8015c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ca:	ff 30                	pushl  (%eax)
  8015cc:	e8 33 fc ff ff       	call   801204 <dev_lookup>
  8015d1:	83 c4 10             	add    $0x10,%esp
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 44                	js     80161c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015db:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015df:	75 21                	jne    801602 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015e1:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015e6:	8b 40 48             	mov    0x48(%eax),%eax
  8015e9:	83 ec 04             	sub    $0x4,%esp
  8015ec:	53                   	push   %ebx
  8015ed:	50                   	push   %eax
  8015ee:	68 7c 2b 80 00       	push   $0x802b7c
  8015f3:	e8 2e ec ff ff       	call   800226 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801600:	eb 23                	jmp    801625 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801602:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801605:	8b 52 18             	mov    0x18(%edx),%edx
  801608:	85 d2                	test   %edx,%edx
  80160a:	74 14                	je     801620 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80160c:	83 ec 08             	sub    $0x8,%esp
  80160f:	ff 75 0c             	pushl  0xc(%ebp)
  801612:	50                   	push   %eax
  801613:	ff d2                	call   *%edx
  801615:	89 c2                	mov    %eax,%edx
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	eb 09                	jmp    801625 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161c:	89 c2                	mov    %eax,%edx
  80161e:	eb 05                	jmp    801625 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801620:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801625:	89 d0                	mov    %edx,%eax
  801627:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162a:	c9                   	leave  
  80162b:	c3                   	ret    

0080162c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80162c:	55                   	push   %ebp
  80162d:	89 e5                	mov    %esp,%ebp
  80162f:	53                   	push   %ebx
  801630:	83 ec 14             	sub    $0x14,%esp
  801633:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801636:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801639:	50                   	push   %eax
  80163a:	ff 75 08             	pushl  0x8(%ebp)
  80163d:	e8 6c fb ff ff       	call   8011ae <fd_lookup>
  801642:	83 c4 08             	add    $0x8,%esp
  801645:	89 c2                	mov    %eax,%edx
  801647:	85 c0                	test   %eax,%eax
  801649:	78 58                	js     8016a3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164b:	83 ec 08             	sub    $0x8,%esp
  80164e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801651:	50                   	push   %eax
  801652:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801655:	ff 30                	pushl  (%eax)
  801657:	e8 a8 fb ff ff       	call   801204 <dev_lookup>
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	85 c0                	test   %eax,%eax
  801661:	78 37                	js     80169a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801663:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801666:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80166a:	74 32                	je     80169e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80166c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80166f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801676:	00 00 00 
	stat->st_isdir = 0;
  801679:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801680:	00 00 00 
	stat->st_dev = dev;
  801683:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801689:	83 ec 08             	sub    $0x8,%esp
  80168c:	53                   	push   %ebx
  80168d:	ff 75 f0             	pushl  -0x10(%ebp)
  801690:	ff 50 14             	call   *0x14(%eax)
  801693:	89 c2                	mov    %eax,%edx
  801695:	83 c4 10             	add    $0x10,%esp
  801698:	eb 09                	jmp    8016a3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169a:	89 c2                	mov    %eax,%edx
  80169c:	eb 05                	jmp    8016a3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80169e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016a3:	89 d0                	mov    %edx,%eax
  8016a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a8:	c9                   	leave  
  8016a9:	c3                   	ret    

008016aa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	56                   	push   %esi
  8016ae:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016af:	83 ec 08             	sub    $0x8,%esp
  8016b2:	6a 00                	push   $0x0
  8016b4:	ff 75 08             	pushl  0x8(%ebp)
  8016b7:	e8 0c 02 00 00       	call   8018c8 <open>
  8016bc:	89 c3                	mov    %eax,%ebx
  8016be:	83 c4 10             	add    $0x10,%esp
  8016c1:	85 c0                	test   %eax,%eax
  8016c3:	78 1b                	js     8016e0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016c5:	83 ec 08             	sub    $0x8,%esp
  8016c8:	ff 75 0c             	pushl  0xc(%ebp)
  8016cb:	50                   	push   %eax
  8016cc:	e8 5b ff ff ff       	call   80162c <fstat>
  8016d1:	89 c6                	mov    %eax,%esi
	close(fd);
  8016d3:	89 1c 24             	mov    %ebx,(%esp)
  8016d6:	e8 fd fb ff ff       	call   8012d8 <close>
	return r;
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	89 f0                	mov    %esi,%eax
}
  8016e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e3:	5b                   	pop    %ebx
  8016e4:	5e                   	pop    %esi
  8016e5:	5d                   	pop    %ebp
  8016e6:	c3                   	ret    

008016e7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	56                   	push   %esi
  8016eb:	53                   	push   %ebx
  8016ec:	89 c6                	mov    %eax,%esi
  8016ee:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016f0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016f7:	75 12                	jne    80170b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016f9:	83 ec 0c             	sub    $0xc,%esp
  8016fc:	6a 01                	push   $0x1
  8016fe:	e8 e2 0c 00 00       	call   8023e5 <ipc_find_env>
  801703:	a3 00 40 80 00       	mov    %eax,0x804000
  801708:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80170b:	6a 07                	push   $0x7
  80170d:	68 00 50 80 00       	push   $0x805000
  801712:	56                   	push   %esi
  801713:	ff 35 00 40 80 00    	pushl  0x804000
  801719:	e8 73 0c 00 00       	call   802391 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80171e:	83 c4 0c             	add    $0xc,%esp
  801721:	6a 00                	push   $0x0
  801723:	53                   	push   %ebx
  801724:	6a 00                	push   $0x0
  801726:	e8 fd 0b 00 00       	call   802328 <ipc_recv>
}
  80172b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80172e:	5b                   	pop    %ebx
  80172f:	5e                   	pop    %esi
  801730:	5d                   	pop    %ebp
  801731:	c3                   	ret    

00801732 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801738:	8b 45 08             	mov    0x8(%ebp),%eax
  80173b:	8b 40 0c             	mov    0xc(%eax),%eax
  80173e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801743:	8b 45 0c             	mov    0xc(%ebp),%eax
  801746:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80174b:	ba 00 00 00 00       	mov    $0x0,%edx
  801750:	b8 02 00 00 00       	mov    $0x2,%eax
  801755:	e8 8d ff ff ff       	call   8016e7 <fsipc>
}
  80175a:	c9                   	leave  
  80175b:	c3                   	ret    

0080175c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801762:	8b 45 08             	mov    0x8(%ebp),%eax
  801765:	8b 40 0c             	mov    0xc(%eax),%eax
  801768:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80176d:	ba 00 00 00 00       	mov    $0x0,%edx
  801772:	b8 06 00 00 00       	mov    $0x6,%eax
  801777:	e8 6b ff ff ff       	call   8016e7 <fsipc>
}
  80177c:	c9                   	leave  
  80177d:	c3                   	ret    

0080177e <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	53                   	push   %ebx
  801782:	83 ec 04             	sub    $0x4,%esp
  801785:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801788:	8b 45 08             	mov    0x8(%ebp),%eax
  80178b:	8b 40 0c             	mov    0xc(%eax),%eax
  80178e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801793:	ba 00 00 00 00       	mov    $0x0,%edx
  801798:	b8 05 00 00 00       	mov    $0x5,%eax
  80179d:	e8 45 ff ff ff       	call   8016e7 <fsipc>
  8017a2:	85 c0                	test   %eax,%eax
  8017a4:	78 2c                	js     8017d2 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017a6:	83 ec 08             	sub    $0x8,%esp
  8017a9:	68 00 50 80 00       	push   $0x805000
  8017ae:	53                   	push   %ebx
  8017af:	e8 f7 ef ff ff       	call   8007ab <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017b4:	a1 80 50 80 00       	mov    0x805080,%eax
  8017b9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017bf:	a1 84 50 80 00       	mov    0x805084,%eax
  8017c4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017ca:	83 c4 10             	add    $0x10,%esp
  8017cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d5:	c9                   	leave  
  8017d6:	c3                   	ret    

008017d7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	53                   	push   %ebx
  8017db:	83 ec 08             	sub    $0x8,%esp
  8017de:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8017e4:	8b 52 0c             	mov    0xc(%edx),%edx
  8017e7:	89 15 00 50 80 00    	mov    %edx,0x805000
  8017ed:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017f2:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8017f7:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8017fa:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801800:	53                   	push   %ebx
  801801:	ff 75 0c             	pushl  0xc(%ebp)
  801804:	68 08 50 80 00       	push   $0x805008
  801809:	e8 2f f1 ff ff       	call   80093d <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  80180e:	ba 00 00 00 00       	mov    $0x0,%edx
  801813:	b8 04 00 00 00       	mov    $0x4,%eax
  801818:	e8 ca fe ff ff       	call   8016e7 <fsipc>
  80181d:	83 c4 10             	add    $0x10,%esp
  801820:	85 c0                	test   %eax,%eax
  801822:	78 1d                	js     801841 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  801824:	39 d8                	cmp    %ebx,%eax
  801826:	76 19                	jbe    801841 <devfile_write+0x6a>
  801828:	68 f0 2b 80 00       	push   $0x802bf0
  80182d:	68 fc 2b 80 00       	push   $0x802bfc
  801832:	68 a5 00 00 00       	push   $0xa5
  801837:	68 11 2c 80 00       	push   $0x802c11
  80183c:	e8 0c e9 ff ff       	call   80014d <_panic>
	return r;
}
  801841:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801844:	c9                   	leave  
  801845:	c3                   	ret    

00801846 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	56                   	push   %esi
  80184a:	53                   	push   %ebx
  80184b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80184e:	8b 45 08             	mov    0x8(%ebp),%eax
  801851:	8b 40 0c             	mov    0xc(%eax),%eax
  801854:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801859:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80185f:	ba 00 00 00 00       	mov    $0x0,%edx
  801864:	b8 03 00 00 00       	mov    $0x3,%eax
  801869:	e8 79 fe ff ff       	call   8016e7 <fsipc>
  80186e:	89 c3                	mov    %eax,%ebx
  801870:	85 c0                	test   %eax,%eax
  801872:	78 4b                	js     8018bf <devfile_read+0x79>
		return r;
	assert(r <= n);
  801874:	39 c6                	cmp    %eax,%esi
  801876:	73 16                	jae    80188e <devfile_read+0x48>
  801878:	68 1c 2c 80 00       	push   $0x802c1c
  80187d:	68 fc 2b 80 00       	push   $0x802bfc
  801882:	6a 7c                	push   $0x7c
  801884:	68 11 2c 80 00       	push   $0x802c11
  801889:	e8 bf e8 ff ff       	call   80014d <_panic>
	assert(r <= PGSIZE);
  80188e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801893:	7e 16                	jle    8018ab <devfile_read+0x65>
  801895:	68 23 2c 80 00       	push   $0x802c23
  80189a:	68 fc 2b 80 00       	push   $0x802bfc
  80189f:	6a 7d                	push   $0x7d
  8018a1:	68 11 2c 80 00       	push   $0x802c11
  8018a6:	e8 a2 e8 ff ff       	call   80014d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018ab:	83 ec 04             	sub    $0x4,%esp
  8018ae:	50                   	push   %eax
  8018af:	68 00 50 80 00       	push   $0x805000
  8018b4:	ff 75 0c             	pushl  0xc(%ebp)
  8018b7:	e8 81 f0 ff ff       	call   80093d <memmove>
	return r;
  8018bc:	83 c4 10             	add    $0x10,%esp
}
  8018bf:	89 d8                	mov    %ebx,%eax
  8018c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c4:	5b                   	pop    %ebx
  8018c5:	5e                   	pop    %esi
  8018c6:	5d                   	pop    %ebp
  8018c7:	c3                   	ret    

008018c8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	53                   	push   %ebx
  8018cc:	83 ec 20             	sub    $0x20,%esp
  8018cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018d2:	53                   	push   %ebx
  8018d3:	e8 9a ee ff ff       	call   800772 <strlen>
  8018d8:	83 c4 10             	add    $0x10,%esp
  8018db:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018e0:	7f 67                	jg     801949 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018e2:	83 ec 0c             	sub    $0xc,%esp
  8018e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e8:	50                   	push   %eax
  8018e9:	e8 71 f8 ff ff       	call   80115f <fd_alloc>
  8018ee:	83 c4 10             	add    $0x10,%esp
		return r;
  8018f1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018f3:	85 c0                	test   %eax,%eax
  8018f5:	78 57                	js     80194e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018f7:	83 ec 08             	sub    $0x8,%esp
  8018fa:	53                   	push   %ebx
  8018fb:	68 00 50 80 00       	push   $0x805000
  801900:	e8 a6 ee ff ff       	call   8007ab <strcpy>
	fsipcbuf.open.req_omode = mode;
  801905:	8b 45 0c             	mov    0xc(%ebp),%eax
  801908:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80190d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801910:	b8 01 00 00 00       	mov    $0x1,%eax
  801915:	e8 cd fd ff ff       	call   8016e7 <fsipc>
  80191a:	89 c3                	mov    %eax,%ebx
  80191c:	83 c4 10             	add    $0x10,%esp
  80191f:	85 c0                	test   %eax,%eax
  801921:	79 14                	jns    801937 <open+0x6f>
		fd_close(fd, 0);
  801923:	83 ec 08             	sub    $0x8,%esp
  801926:	6a 00                	push   $0x0
  801928:	ff 75 f4             	pushl  -0xc(%ebp)
  80192b:	e8 27 f9 ff ff       	call   801257 <fd_close>
		return r;
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	89 da                	mov    %ebx,%edx
  801935:	eb 17                	jmp    80194e <open+0x86>
	}

	return fd2num(fd);
  801937:	83 ec 0c             	sub    $0xc,%esp
  80193a:	ff 75 f4             	pushl  -0xc(%ebp)
  80193d:	e8 f6 f7 ff ff       	call   801138 <fd2num>
  801942:	89 c2                	mov    %eax,%edx
  801944:	83 c4 10             	add    $0x10,%esp
  801947:	eb 05                	jmp    80194e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801949:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80194e:	89 d0                	mov    %edx,%eax
  801950:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801953:	c9                   	leave  
  801954:	c3                   	ret    

00801955 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80195b:	ba 00 00 00 00       	mov    $0x0,%edx
  801960:	b8 08 00 00 00       	mov    $0x8,%eax
  801965:	e8 7d fd ff ff       	call   8016e7 <fsipc>
}
  80196a:	c9                   	leave  
  80196b:	c3                   	ret    

0080196c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801972:	68 2f 2c 80 00       	push   $0x802c2f
  801977:	ff 75 0c             	pushl  0xc(%ebp)
  80197a:	e8 2c ee ff ff       	call   8007ab <strcpy>
	return 0;
}
  80197f:	b8 00 00 00 00       	mov    $0x0,%eax
  801984:	c9                   	leave  
  801985:	c3                   	ret    

00801986 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801986:	55                   	push   %ebp
  801987:	89 e5                	mov    %esp,%ebp
  801989:	53                   	push   %ebx
  80198a:	83 ec 10             	sub    $0x10,%esp
  80198d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801990:	53                   	push   %ebx
  801991:	e8 88 0a 00 00       	call   80241e <pageref>
  801996:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801999:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80199e:	83 f8 01             	cmp    $0x1,%eax
  8019a1:	75 10                	jne    8019b3 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8019a3:	83 ec 0c             	sub    $0xc,%esp
  8019a6:	ff 73 0c             	pushl  0xc(%ebx)
  8019a9:	e8 c0 02 00 00       	call   801c6e <nsipc_close>
  8019ae:	89 c2                	mov    %eax,%edx
  8019b0:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8019b3:	89 d0                	mov    %edx,%eax
  8019b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b8:	c9                   	leave  
  8019b9:	c3                   	ret    

008019ba <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019c0:	6a 00                	push   $0x0
  8019c2:	ff 75 10             	pushl  0x10(%ebp)
  8019c5:	ff 75 0c             	pushl  0xc(%ebp)
  8019c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cb:	ff 70 0c             	pushl  0xc(%eax)
  8019ce:	e8 78 03 00 00       	call   801d4b <nsipc_send>
}
  8019d3:	c9                   	leave  
  8019d4:	c3                   	ret    

008019d5 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019db:	6a 00                	push   $0x0
  8019dd:	ff 75 10             	pushl  0x10(%ebp)
  8019e0:	ff 75 0c             	pushl  0xc(%ebp)
  8019e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e6:	ff 70 0c             	pushl  0xc(%eax)
  8019e9:	e8 f1 02 00 00       	call   801cdf <nsipc_recv>
}
  8019ee:	c9                   	leave  
  8019ef:	c3                   	ret    

008019f0 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
  8019f3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8019f6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019f9:	52                   	push   %edx
  8019fa:	50                   	push   %eax
  8019fb:	e8 ae f7 ff ff       	call   8011ae <fd_lookup>
  801a00:	83 c4 10             	add    $0x10,%esp
  801a03:	85 c0                	test   %eax,%eax
  801a05:	78 17                	js     801a1e <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0a:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a10:	39 08                	cmp    %ecx,(%eax)
  801a12:	75 05                	jne    801a19 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a14:	8b 40 0c             	mov    0xc(%eax),%eax
  801a17:	eb 05                	jmp    801a1e <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a19:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a1e:	c9                   	leave  
  801a1f:	c3                   	ret    

00801a20 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	56                   	push   %esi
  801a24:	53                   	push   %ebx
  801a25:	83 ec 1c             	sub    $0x1c,%esp
  801a28:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a2d:	50                   	push   %eax
  801a2e:	e8 2c f7 ff ff       	call   80115f <fd_alloc>
  801a33:	89 c3                	mov    %eax,%ebx
  801a35:	83 c4 10             	add    $0x10,%esp
  801a38:	85 c0                	test   %eax,%eax
  801a3a:	78 1b                	js     801a57 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a3c:	83 ec 04             	sub    $0x4,%esp
  801a3f:	68 07 04 00 00       	push   $0x407
  801a44:	ff 75 f4             	pushl  -0xc(%ebp)
  801a47:	6a 00                	push   $0x0
  801a49:	e8 60 f1 ff ff       	call   800bae <sys_page_alloc>
  801a4e:	89 c3                	mov    %eax,%ebx
  801a50:	83 c4 10             	add    $0x10,%esp
  801a53:	85 c0                	test   %eax,%eax
  801a55:	79 10                	jns    801a67 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a57:	83 ec 0c             	sub    $0xc,%esp
  801a5a:	56                   	push   %esi
  801a5b:	e8 0e 02 00 00       	call   801c6e <nsipc_close>
		return r;
  801a60:	83 c4 10             	add    $0x10,%esp
  801a63:	89 d8                	mov    %ebx,%eax
  801a65:	eb 24                	jmp    801a8b <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a67:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a70:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a75:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a7c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a7f:	83 ec 0c             	sub    $0xc,%esp
  801a82:	50                   	push   %eax
  801a83:	e8 b0 f6 ff ff       	call   801138 <fd2num>
  801a88:	83 c4 10             	add    $0x10,%esp
}
  801a8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8e:	5b                   	pop    %ebx
  801a8f:	5e                   	pop    %esi
  801a90:	5d                   	pop    %ebp
  801a91:	c3                   	ret    

00801a92 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a98:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9b:	e8 50 ff ff ff       	call   8019f0 <fd2sockid>
		return r;
  801aa0:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aa2:	85 c0                	test   %eax,%eax
  801aa4:	78 1f                	js     801ac5 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801aa6:	83 ec 04             	sub    $0x4,%esp
  801aa9:	ff 75 10             	pushl  0x10(%ebp)
  801aac:	ff 75 0c             	pushl  0xc(%ebp)
  801aaf:	50                   	push   %eax
  801ab0:	e8 12 01 00 00       	call   801bc7 <nsipc_accept>
  801ab5:	83 c4 10             	add    $0x10,%esp
		return r;
  801ab8:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801aba:	85 c0                	test   %eax,%eax
  801abc:	78 07                	js     801ac5 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801abe:	e8 5d ff ff ff       	call   801a20 <alloc_sockfd>
  801ac3:	89 c1                	mov    %eax,%ecx
}
  801ac5:	89 c8                	mov    %ecx,%eax
  801ac7:	c9                   	leave  
  801ac8:	c3                   	ret    

00801ac9 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801acf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad2:	e8 19 ff ff ff       	call   8019f0 <fd2sockid>
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	78 12                	js     801aed <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801adb:	83 ec 04             	sub    $0x4,%esp
  801ade:	ff 75 10             	pushl  0x10(%ebp)
  801ae1:	ff 75 0c             	pushl  0xc(%ebp)
  801ae4:	50                   	push   %eax
  801ae5:	e8 2d 01 00 00       	call   801c17 <nsipc_bind>
  801aea:	83 c4 10             	add    $0x10,%esp
}
  801aed:	c9                   	leave  
  801aee:	c3                   	ret    

00801aef <shutdown>:

int
shutdown(int s, int how)
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801af5:	8b 45 08             	mov    0x8(%ebp),%eax
  801af8:	e8 f3 fe ff ff       	call   8019f0 <fd2sockid>
  801afd:	85 c0                	test   %eax,%eax
  801aff:	78 0f                	js     801b10 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b01:	83 ec 08             	sub    $0x8,%esp
  801b04:	ff 75 0c             	pushl  0xc(%ebp)
  801b07:	50                   	push   %eax
  801b08:	e8 3f 01 00 00       	call   801c4c <nsipc_shutdown>
  801b0d:	83 c4 10             	add    $0x10,%esp
}
  801b10:	c9                   	leave  
  801b11:	c3                   	ret    

00801b12 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b18:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1b:	e8 d0 fe ff ff       	call   8019f0 <fd2sockid>
  801b20:	85 c0                	test   %eax,%eax
  801b22:	78 12                	js     801b36 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b24:	83 ec 04             	sub    $0x4,%esp
  801b27:	ff 75 10             	pushl  0x10(%ebp)
  801b2a:	ff 75 0c             	pushl  0xc(%ebp)
  801b2d:	50                   	push   %eax
  801b2e:	e8 55 01 00 00       	call   801c88 <nsipc_connect>
  801b33:	83 c4 10             	add    $0x10,%esp
}
  801b36:	c9                   	leave  
  801b37:	c3                   	ret    

00801b38 <listen>:

int
listen(int s, int backlog)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b41:	e8 aa fe ff ff       	call   8019f0 <fd2sockid>
  801b46:	85 c0                	test   %eax,%eax
  801b48:	78 0f                	js     801b59 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b4a:	83 ec 08             	sub    $0x8,%esp
  801b4d:	ff 75 0c             	pushl  0xc(%ebp)
  801b50:	50                   	push   %eax
  801b51:	e8 67 01 00 00       	call   801cbd <nsipc_listen>
  801b56:	83 c4 10             	add    $0x10,%esp
}
  801b59:	c9                   	leave  
  801b5a:	c3                   	ret    

00801b5b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b61:	ff 75 10             	pushl  0x10(%ebp)
  801b64:	ff 75 0c             	pushl  0xc(%ebp)
  801b67:	ff 75 08             	pushl  0x8(%ebp)
  801b6a:	e8 3a 02 00 00       	call   801da9 <nsipc_socket>
  801b6f:	83 c4 10             	add    $0x10,%esp
  801b72:	85 c0                	test   %eax,%eax
  801b74:	78 05                	js     801b7b <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b76:	e8 a5 fe ff ff       	call   801a20 <alloc_sockfd>
}
  801b7b:	c9                   	leave  
  801b7c:	c3                   	ret    

00801b7d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	53                   	push   %ebx
  801b81:	83 ec 04             	sub    $0x4,%esp
  801b84:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b86:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801b8d:	75 12                	jne    801ba1 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b8f:	83 ec 0c             	sub    $0xc,%esp
  801b92:	6a 02                	push   $0x2
  801b94:	e8 4c 08 00 00       	call   8023e5 <ipc_find_env>
  801b99:	a3 04 40 80 00       	mov    %eax,0x804004
  801b9e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ba1:	6a 07                	push   $0x7
  801ba3:	68 00 60 80 00       	push   $0x806000
  801ba8:	53                   	push   %ebx
  801ba9:	ff 35 04 40 80 00    	pushl  0x804004
  801baf:	e8 dd 07 00 00       	call   802391 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bb4:	83 c4 0c             	add    $0xc,%esp
  801bb7:	6a 00                	push   $0x0
  801bb9:	6a 00                	push   $0x0
  801bbb:	6a 00                	push   $0x0
  801bbd:	e8 66 07 00 00       	call   802328 <ipc_recv>
}
  801bc2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc5:	c9                   	leave  
  801bc6:	c3                   	ret    

00801bc7 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bc7:	55                   	push   %ebp
  801bc8:	89 e5                	mov    %esp,%ebp
  801bca:	56                   	push   %esi
  801bcb:	53                   	push   %ebx
  801bcc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801bd7:	8b 06                	mov    (%esi),%eax
  801bd9:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801bde:	b8 01 00 00 00       	mov    $0x1,%eax
  801be3:	e8 95 ff ff ff       	call   801b7d <nsipc>
  801be8:	89 c3                	mov    %eax,%ebx
  801bea:	85 c0                	test   %eax,%eax
  801bec:	78 20                	js     801c0e <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801bee:	83 ec 04             	sub    $0x4,%esp
  801bf1:	ff 35 10 60 80 00    	pushl  0x806010
  801bf7:	68 00 60 80 00       	push   $0x806000
  801bfc:	ff 75 0c             	pushl  0xc(%ebp)
  801bff:	e8 39 ed ff ff       	call   80093d <memmove>
		*addrlen = ret->ret_addrlen;
  801c04:	a1 10 60 80 00       	mov    0x806010,%eax
  801c09:	89 06                	mov    %eax,(%esi)
  801c0b:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c0e:	89 d8                	mov    %ebx,%eax
  801c10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c13:	5b                   	pop    %ebx
  801c14:	5e                   	pop    %esi
  801c15:	5d                   	pop    %ebp
  801c16:	c3                   	ret    

00801c17 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	53                   	push   %ebx
  801c1b:	83 ec 08             	sub    $0x8,%esp
  801c1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c21:	8b 45 08             	mov    0x8(%ebp),%eax
  801c24:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c29:	53                   	push   %ebx
  801c2a:	ff 75 0c             	pushl  0xc(%ebp)
  801c2d:	68 04 60 80 00       	push   $0x806004
  801c32:	e8 06 ed ff ff       	call   80093d <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c37:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c3d:	b8 02 00 00 00       	mov    $0x2,%eax
  801c42:	e8 36 ff ff ff       	call   801b7d <nsipc>
}
  801c47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c4a:	c9                   	leave  
  801c4b:	c3                   	ret    

00801c4c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c52:	8b 45 08             	mov    0x8(%ebp),%eax
  801c55:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c5d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c62:	b8 03 00 00 00       	mov    $0x3,%eax
  801c67:	e8 11 ff ff ff       	call   801b7d <nsipc>
}
  801c6c:	c9                   	leave  
  801c6d:	c3                   	ret    

00801c6e <nsipc_close>:

int
nsipc_close(int s)
{
  801c6e:	55                   	push   %ebp
  801c6f:	89 e5                	mov    %esp,%ebp
  801c71:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c74:	8b 45 08             	mov    0x8(%ebp),%eax
  801c77:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c7c:	b8 04 00 00 00       	mov    $0x4,%eax
  801c81:	e8 f7 fe ff ff       	call   801b7d <nsipc>
}
  801c86:	c9                   	leave  
  801c87:	c3                   	ret    

00801c88 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c88:	55                   	push   %ebp
  801c89:	89 e5                	mov    %esp,%ebp
  801c8b:	53                   	push   %ebx
  801c8c:	83 ec 08             	sub    $0x8,%esp
  801c8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c92:	8b 45 08             	mov    0x8(%ebp),%eax
  801c95:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c9a:	53                   	push   %ebx
  801c9b:	ff 75 0c             	pushl  0xc(%ebp)
  801c9e:	68 04 60 80 00       	push   $0x806004
  801ca3:	e8 95 ec ff ff       	call   80093d <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ca8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801cae:	b8 05 00 00 00       	mov    $0x5,%eax
  801cb3:	e8 c5 fe ff ff       	call   801b7d <nsipc>
}
  801cb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cbb:	c9                   	leave  
  801cbc:	c3                   	ret    

00801cbd <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801cbd:	55                   	push   %ebp
  801cbe:	89 e5                	mov    %esp,%ebp
  801cc0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801cc3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801ccb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cce:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801cd3:	b8 06 00 00 00       	mov    $0x6,%eax
  801cd8:	e8 a0 fe ff ff       	call   801b7d <nsipc>
}
  801cdd:	c9                   	leave  
  801cde:	c3                   	ret    

00801cdf <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ce7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cea:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801cef:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801cf5:	8b 45 14             	mov    0x14(%ebp),%eax
  801cf8:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801cfd:	b8 07 00 00 00       	mov    $0x7,%eax
  801d02:	e8 76 fe ff ff       	call   801b7d <nsipc>
  801d07:	89 c3                	mov    %eax,%ebx
  801d09:	85 c0                	test   %eax,%eax
  801d0b:	78 35                	js     801d42 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d0d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d12:	7f 04                	jg     801d18 <nsipc_recv+0x39>
  801d14:	39 c6                	cmp    %eax,%esi
  801d16:	7d 16                	jge    801d2e <nsipc_recv+0x4f>
  801d18:	68 3b 2c 80 00       	push   $0x802c3b
  801d1d:	68 fc 2b 80 00       	push   $0x802bfc
  801d22:	6a 62                	push   $0x62
  801d24:	68 50 2c 80 00       	push   $0x802c50
  801d29:	e8 1f e4 ff ff       	call   80014d <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d2e:	83 ec 04             	sub    $0x4,%esp
  801d31:	50                   	push   %eax
  801d32:	68 00 60 80 00       	push   $0x806000
  801d37:	ff 75 0c             	pushl  0xc(%ebp)
  801d3a:	e8 fe eb ff ff       	call   80093d <memmove>
  801d3f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d42:	89 d8                	mov    %ebx,%eax
  801d44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d47:	5b                   	pop    %ebx
  801d48:	5e                   	pop    %esi
  801d49:	5d                   	pop    %ebp
  801d4a:	c3                   	ret    

00801d4b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d4b:	55                   	push   %ebp
  801d4c:	89 e5                	mov    %esp,%ebp
  801d4e:	53                   	push   %ebx
  801d4f:	83 ec 04             	sub    $0x4,%esp
  801d52:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d55:	8b 45 08             	mov    0x8(%ebp),%eax
  801d58:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d5d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d63:	7e 16                	jle    801d7b <nsipc_send+0x30>
  801d65:	68 5c 2c 80 00       	push   $0x802c5c
  801d6a:	68 fc 2b 80 00       	push   $0x802bfc
  801d6f:	6a 6d                	push   $0x6d
  801d71:	68 50 2c 80 00       	push   $0x802c50
  801d76:	e8 d2 e3 ff ff       	call   80014d <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d7b:	83 ec 04             	sub    $0x4,%esp
  801d7e:	53                   	push   %ebx
  801d7f:	ff 75 0c             	pushl  0xc(%ebp)
  801d82:	68 0c 60 80 00       	push   $0x80600c
  801d87:	e8 b1 eb ff ff       	call   80093d <memmove>
	nsipcbuf.send.req_size = size;
  801d8c:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d92:	8b 45 14             	mov    0x14(%ebp),%eax
  801d95:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d9a:	b8 08 00 00 00       	mov    $0x8,%eax
  801d9f:	e8 d9 fd ff ff       	call   801b7d <nsipc>
}
  801da4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801da7:	c9                   	leave  
  801da8:	c3                   	ret    

00801da9 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801da9:	55                   	push   %ebp
  801daa:	89 e5                	mov    %esp,%ebp
  801dac:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801daf:	8b 45 08             	mov    0x8(%ebp),%eax
  801db2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801db7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dba:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801dbf:	8b 45 10             	mov    0x10(%ebp),%eax
  801dc2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801dc7:	b8 09 00 00 00       	mov    $0x9,%eax
  801dcc:	e8 ac fd ff ff       	call   801b7d <nsipc>
}
  801dd1:	c9                   	leave  
  801dd2:	c3                   	ret    

00801dd3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	56                   	push   %esi
  801dd7:	53                   	push   %ebx
  801dd8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ddb:	83 ec 0c             	sub    $0xc,%esp
  801dde:	ff 75 08             	pushl  0x8(%ebp)
  801de1:	e8 62 f3 ff ff       	call   801148 <fd2data>
  801de6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801de8:	83 c4 08             	add    $0x8,%esp
  801deb:	68 68 2c 80 00       	push   $0x802c68
  801df0:	53                   	push   %ebx
  801df1:	e8 b5 e9 ff ff       	call   8007ab <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801df6:	8b 46 04             	mov    0x4(%esi),%eax
  801df9:	2b 06                	sub    (%esi),%eax
  801dfb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e01:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e08:	00 00 00 
	stat->st_dev = &devpipe;
  801e0b:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e12:	30 80 00 
	return 0;
}
  801e15:	b8 00 00 00 00       	mov    $0x0,%eax
  801e1a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e1d:	5b                   	pop    %ebx
  801e1e:	5e                   	pop    %esi
  801e1f:	5d                   	pop    %ebp
  801e20:	c3                   	ret    

00801e21 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	53                   	push   %ebx
  801e25:	83 ec 0c             	sub    $0xc,%esp
  801e28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e2b:	53                   	push   %ebx
  801e2c:	6a 00                	push   $0x0
  801e2e:	e8 00 ee ff ff       	call   800c33 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e33:	89 1c 24             	mov    %ebx,(%esp)
  801e36:	e8 0d f3 ff ff       	call   801148 <fd2data>
  801e3b:	83 c4 08             	add    $0x8,%esp
  801e3e:	50                   	push   %eax
  801e3f:	6a 00                	push   $0x0
  801e41:	e8 ed ed ff ff       	call   800c33 <sys_page_unmap>
}
  801e46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e49:	c9                   	leave  
  801e4a:	c3                   	ret    

00801e4b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
  801e4e:	57                   	push   %edi
  801e4f:	56                   	push   %esi
  801e50:	53                   	push   %ebx
  801e51:	83 ec 1c             	sub    $0x1c,%esp
  801e54:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e57:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e59:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801e5e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e61:	83 ec 0c             	sub    $0xc,%esp
  801e64:	ff 75 e0             	pushl  -0x20(%ebp)
  801e67:	e8 b2 05 00 00       	call   80241e <pageref>
  801e6c:	89 c3                	mov    %eax,%ebx
  801e6e:	89 3c 24             	mov    %edi,(%esp)
  801e71:	e8 a8 05 00 00       	call   80241e <pageref>
  801e76:	83 c4 10             	add    $0x10,%esp
  801e79:	39 c3                	cmp    %eax,%ebx
  801e7b:	0f 94 c1             	sete   %cl
  801e7e:	0f b6 c9             	movzbl %cl,%ecx
  801e81:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801e84:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801e8a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e8d:	39 ce                	cmp    %ecx,%esi
  801e8f:	74 1b                	je     801eac <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801e91:	39 c3                	cmp    %eax,%ebx
  801e93:	75 c4                	jne    801e59 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e95:	8b 42 58             	mov    0x58(%edx),%eax
  801e98:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e9b:	50                   	push   %eax
  801e9c:	56                   	push   %esi
  801e9d:	68 6f 2c 80 00       	push   $0x802c6f
  801ea2:	e8 7f e3 ff ff       	call   800226 <cprintf>
  801ea7:	83 c4 10             	add    $0x10,%esp
  801eaa:	eb ad                	jmp    801e59 <_pipeisclosed+0xe>
	}
}
  801eac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eaf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb2:	5b                   	pop    %ebx
  801eb3:	5e                   	pop    %esi
  801eb4:	5f                   	pop    %edi
  801eb5:	5d                   	pop    %ebp
  801eb6:	c3                   	ret    

00801eb7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801eb7:	55                   	push   %ebp
  801eb8:	89 e5                	mov    %esp,%ebp
  801eba:	57                   	push   %edi
  801ebb:	56                   	push   %esi
  801ebc:	53                   	push   %ebx
  801ebd:	83 ec 28             	sub    $0x28,%esp
  801ec0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ec3:	56                   	push   %esi
  801ec4:	e8 7f f2 ff ff       	call   801148 <fd2data>
  801ec9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ecb:	83 c4 10             	add    $0x10,%esp
  801ece:	bf 00 00 00 00       	mov    $0x0,%edi
  801ed3:	eb 4b                	jmp    801f20 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ed5:	89 da                	mov    %ebx,%edx
  801ed7:	89 f0                	mov    %esi,%eax
  801ed9:	e8 6d ff ff ff       	call   801e4b <_pipeisclosed>
  801ede:	85 c0                	test   %eax,%eax
  801ee0:	75 48                	jne    801f2a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ee2:	e8 a8 ec ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ee7:	8b 43 04             	mov    0x4(%ebx),%eax
  801eea:	8b 0b                	mov    (%ebx),%ecx
  801eec:	8d 51 20             	lea    0x20(%ecx),%edx
  801eef:	39 d0                	cmp    %edx,%eax
  801ef1:	73 e2                	jae    801ed5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ef3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ef6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801efa:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801efd:	89 c2                	mov    %eax,%edx
  801eff:	c1 fa 1f             	sar    $0x1f,%edx
  801f02:	89 d1                	mov    %edx,%ecx
  801f04:	c1 e9 1b             	shr    $0x1b,%ecx
  801f07:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f0a:	83 e2 1f             	and    $0x1f,%edx
  801f0d:	29 ca                	sub    %ecx,%edx
  801f0f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f13:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f17:	83 c0 01             	add    $0x1,%eax
  801f1a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f1d:	83 c7 01             	add    $0x1,%edi
  801f20:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f23:	75 c2                	jne    801ee7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f25:	8b 45 10             	mov    0x10(%ebp),%eax
  801f28:	eb 05                	jmp    801f2f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f2a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f32:	5b                   	pop    %ebx
  801f33:	5e                   	pop    %esi
  801f34:	5f                   	pop    %edi
  801f35:	5d                   	pop    %ebp
  801f36:	c3                   	ret    

00801f37 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f37:	55                   	push   %ebp
  801f38:	89 e5                	mov    %esp,%ebp
  801f3a:	57                   	push   %edi
  801f3b:	56                   	push   %esi
  801f3c:	53                   	push   %ebx
  801f3d:	83 ec 18             	sub    $0x18,%esp
  801f40:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f43:	57                   	push   %edi
  801f44:	e8 ff f1 ff ff       	call   801148 <fd2data>
  801f49:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f4b:	83 c4 10             	add    $0x10,%esp
  801f4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f53:	eb 3d                	jmp    801f92 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f55:	85 db                	test   %ebx,%ebx
  801f57:	74 04                	je     801f5d <devpipe_read+0x26>
				return i;
  801f59:	89 d8                	mov    %ebx,%eax
  801f5b:	eb 44                	jmp    801fa1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f5d:	89 f2                	mov    %esi,%edx
  801f5f:	89 f8                	mov    %edi,%eax
  801f61:	e8 e5 fe ff ff       	call   801e4b <_pipeisclosed>
  801f66:	85 c0                	test   %eax,%eax
  801f68:	75 32                	jne    801f9c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f6a:	e8 20 ec ff ff       	call   800b8f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f6f:	8b 06                	mov    (%esi),%eax
  801f71:	3b 46 04             	cmp    0x4(%esi),%eax
  801f74:	74 df                	je     801f55 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f76:	99                   	cltd   
  801f77:	c1 ea 1b             	shr    $0x1b,%edx
  801f7a:	01 d0                	add    %edx,%eax
  801f7c:	83 e0 1f             	and    $0x1f,%eax
  801f7f:	29 d0                	sub    %edx,%eax
  801f81:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801f86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f89:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801f8c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f8f:	83 c3 01             	add    $0x1,%ebx
  801f92:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801f95:	75 d8                	jne    801f6f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f97:	8b 45 10             	mov    0x10(%ebp),%eax
  801f9a:	eb 05                	jmp    801fa1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f9c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fa1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa4:	5b                   	pop    %ebx
  801fa5:	5e                   	pop    %esi
  801fa6:	5f                   	pop    %edi
  801fa7:	5d                   	pop    %ebp
  801fa8:	c3                   	ret    

00801fa9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fa9:	55                   	push   %ebp
  801faa:	89 e5                	mov    %esp,%ebp
  801fac:	56                   	push   %esi
  801fad:	53                   	push   %ebx
  801fae:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb4:	50                   	push   %eax
  801fb5:	e8 a5 f1 ff ff       	call   80115f <fd_alloc>
  801fba:	83 c4 10             	add    $0x10,%esp
  801fbd:	89 c2                	mov    %eax,%edx
  801fbf:	85 c0                	test   %eax,%eax
  801fc1:	0f 88 2c 01 00 00    	js     8020f3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fc7:	83 ec 04             	sub    $0x4,%esp
  801fca:	68 07 04 00 00       	push   $0x407
  801fcf:	ff 75 f4             	pushl  -0xc(%ebp)
  801fd2:	6a 00                	push   $0x0
  801fd4:	e8 d5 eb ff ff       	call   800bae <sys_page_alloc>
  801fd9:	83 c4 10             	add    $0x10,%esp
  801fdc:	89 c2                	mov    %eax,%edx
  801fde:	85 c0                	test   %eax,%eax
  801fe0:	0f 88 0d 01 00 00    	js     8020f3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801fe6:	83 ec 0c             	sub    $0xc,%esp
  801fe9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fec:	50                   	push   %eax
  801fed:	e8 6d f1 ff ff       	call   80115f <fd_alloc>
  801ff2:	89 c3                	mov    %eax,%ebx
  801ff4:	83 c4 10             	add    $0x10,%esp
  801ff7:	85 c0                	test   %eax,%eax
  801ff9:	0f 88 e2 00 00 00    	js     8020e1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fff:	83 ec 04             	sub    $0x4,%esp
  802002:	68 07 04 00 00       	push   $0x407
  802007:	ff 75 f0             	pushl  -0x10(%ebp)
  80200a:	6a 00                	push   $0x0
  80200c:	e8 9d eb ff ff       	call   800bae <sys_page_alloc>
  802011:	89 c3                	mov    %eax,%ebx
  802013:	83 c4 10             	add    $0x10,%esp
  802016:	85 c0                	test   %eax,%eax
  802018:	0f 88 c3 00 00 00    	js     8020e1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80201e:	83 ec 0c             	sub    $0xc,%esp
  802021:	ff 75 f4             	pushl  -0xc(%ebp)
  802024:	e8 1f f1 ff ff       	call   801148 <fd2data>
  802029:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80202b:	83 c4 0c             	add    $0xc,%esp
  80202e:	68 07 04 00 00       	push   $0x407
  802033:	50                   	push   %eax
  802034:	6a 00                	push   $0x0
  802036:	e8 73 eb ff ff       	call   800bae <sys_page_alloc>
  80203b:	89 c3                	mov    %eax,%ebx
  80203d:	83 c4 10             	add    $0x10,%esp
  802040:	85 c0                	test   %eax,%eax
  802042:	0f 88 89 00 00 00    	js     8020d1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802048:	83 ec 0c             	sub    $0xc,%esp
  80204b:	ff 75 f0             	pushl  -0x10(%ebp)
  80204e:	e8 f5 f0 ff ff       	call   801148 <fd2data>
  802053:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80205a:	50                   	push   %eax
  80205b:	6a 00                	push   $0x0
  80205d:	56                   	push   %esi
  80205e:	6a 00                	push   $0x0
  802060:	e8 8c eb ff ff       	call   800bf1 <sys_page_map>
  802065:	89 c3                	mov    %eax,%ebx
  802067:	83 c4 20             	add    $0x20,%esp
  80206a:	85 c0                	test   %eax,%eax
  80206c:	78 55                	js     8020c3 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80206e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802074:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802077:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802079:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80207c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802083:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802089:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80208c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80208e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802091:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802098:	83 ec 0c             	sub    $0xc,%esp
  80209b:	ff 75 f4             	pushl  -0xc(%ebp)
  80209e:	e8 95 f0 ff ff       	call   801138 <fd2num>
  8020a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020a6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020a8:	83 c4 04             	add    $0x4,%esp
  8020ab:	ff 75 f0             	pushl  -0x10(%ebp)
  8020ae:	e8 85 f0 ff ff       	call   801138 <fd2num>
  8020b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020b6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020b9:	83 c4 10             	add    $0x10,%esp
  8020bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8020c1:	eb 30                	jmp    8020f3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8020c3:	83 ec 08             	sub    $0x8,%esp
  8020c6:	56                   	push   %esi
  8020c7:	6a 00                	push   $0x0
  8020c9:	e8 65 eb ff ff       	call   800c33 <sys_page_unmap>
  8020ce:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8020d1:	83 ec 08             	sub    $0x8,%esp
  8020d4:	ff 75 f0             	pushl  -0x10(%ebp)
  8020d7:	6a 00                	push   $0x0
  8020d9:	e8 55 eb ff ff       	call   800c33 <sys_page_unmap>
  8020de:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8020e1:	83 ec 08             	sub    $0x8,%esp
  8020e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8020e7:	6a 00                	push   $0x0
  8020e9:	e8 45 eb ff ff       	call   800c33 <sys_page_unmap>
  8020ee:	83 c4 10             	add    $0x10,%esp
  8020f1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8020f3:	89 d0                	mov    %edx,%eax
  8020f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020f8:	5b                   	pop    %ebx
  8020f9:	5e                   	pop    %esi
  8020fa:	5d                   	pop    %ebp
  8020fb:	c3                   	ret    

008020fc <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020fc:	55                   	push   %ebp
  8020fd:	89 e5                	mov    %esp,%ebp
  8020ff:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802102:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802105:	50                   	push   %eax
  802106:	ff 75 08             	pushl  0x8(%ebp)
  802109:	e8 a0 f0 ff ff       	call   8011ae <fd_lookup>
  80210e:	83 c4 10             	add    $0x10,%esp
  802111:	85 c0                	test   %eax,%eax
  802113:	78 18                	js     80212d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802115:	83 ec 0c             	sub    $0xc,%esp
  802118:	ff 75 f4             	pushl  -0xc(%ebp)
  80211b:	e8 28 f0 ff ff       	call   801148 <fd2data>
	return _pipeisclosed(fd, p);
  802120:	89 c2                	mov    %eax,%edx
  802122:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802125:	e8 21 fd ff ff       	call   801e4b <_pipeisclosed>
  80212a:	83 c4 10             	add    $0x10,%esp
}
  80212d:	c9                   	leave  
  80212e:	c3                   	ret    

0080212f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80212f:	55                   	push   %ebp
  802130:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802132:	b8 00 00 00 00       	mov    $0x0,%eax
  802137:	5d                   	pop    %ebp
  802138:	c3                   	ret    

00802139 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802139:	55                   	push   %ebp
  80213a:	89 e5                	mov    %esp,%ebp
  80213c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80213f:	68 87 2c 80 00       	push   $0x802c87
  802144:	ff 75 0c             	pushl  0xc(%ebp)
  802147:	e8 5f e6 ff ff       	call   8007ab <strcpy>
	return 0;
}
  80214c:	b8 00 00 00 00       	mov    $0x0,%eax
  802151:	c9                   	leave  
  802152:	c3                   	ret    

00802153 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802153:	55                   	push   %ebp
  802154:	89 e5                	mov    %esp,%ebp
  802156:	57                   	push   %edi
  802157:	56                   	push   %esi
  802158:	53                   	push   %ebx
  802159:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80215f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802164:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80216a:	eb 2d                	jmp    802199 <devcons_write+0x46>
		m = n - tot;
  80216c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80216f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802171:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802174:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802179:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80217c:	83 ec 04             	sub    $0x4,%esp
  80217f:	53                   	push   %ebx
  802180:	03 45 0c             	add    0xc(%ebp),%eax
  802183:	50                   	push   %eax
  802184:	57                   	push   %edi
  802185:	e8 b3 e7 ff ff       	call   80093d <memmove>
		sys_cputs(buf, m);
  80218a:	83 c4 08             	add    $0x8,%esp
  80218d:	53                   	push   %ebx
  80218e:	57                   	push   %edi
  80218f:	e8 5e e9 ff ff       	call   800af2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802194:	01 de                	add    %ebx,%esi
  802196:	83 c4 10             	add    $0x10,%esp
  802199:	89 f0                	mov    %esi,%eax
  80219b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80219e:	72 cc                	jb     80216c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021a3:	5b                   	pop    %ebx
  8021a4:	5e                   	pop    %esi
  8021a5:	5f                   	pop    %edi
  8021a6:	5d                   	pop    %ebp
  8021a7:	c3                   	ret    

008021a8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021a8:	55                   	push   %ebp
  8021a9:	89 e5                	mov    %esp,%ebp
  8021ab:	83 ec 08             	sub    $0x8,%esp
  8021ae:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8021b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021b7:	74 2a                	je     8021e3 <devcons_read+0x3b>
  8021b9:	eb 05                	jmp    8021c0 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021bb:	e8 cf e9 ff ff       	call   800b8f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021c0:	e8 4b e9 ff ff       	call   800b10 <sys_cgetc>
  8021c5:	85 c0                	test   %eax,%eax
  8021c7:	74 f2                	je     8021bb <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021c9:	85 c0                	test   %eax,%eax
  8021cb:	78 16                	js     8021e3 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021cd:	83 f8 04             	cmp    $0x4,%eax
  8021d0:	74 0c                	je     8021de <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8021d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021d5:	88 02                	mov    %al,(%edx)
	return 1;
  8021d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8021dc:	eb 05                	jmp    8021e3 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021de:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021e3:	c9                   	leave  
  8021e4:	c3                   	ret    

008021e5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021e5:	55                   	push   %ebp
  8021e6:	89 e5                	mov    %esp,%ebp
  8021e8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8021eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ee:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021f1:	6a 01                	push   $0x1
  8021f3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021f6:	50                   	push   %eax
  8021f7:	e8 f6 e8 ff ff       	call   800af2 <sys_cputs>
}
  8021fc:	83 c4 10             	add    $0x10,%esp
  8021ff:	c9                   	leave  
  802200:	c3                   	ret    

00802201 <getchar>:

int
getchar(void)
{
  802201:	55                   	push   %ebp
  802202:	89 e5                	mov    %esp,%ebp
  802204:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802207:	6a 01                	push   $0x1
  802209:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80220c:	50                   	push   %eax
  80220d:	6a 00                	push   $0x0
  80220f:	e8 00 f2 ff ff       	call   801414 <read>
	if (r < 0)
  802214:	83 c4 10             	add    $0x10,%esp
  802217:	85 c0                	test   %eax,%eax
  802219:	78 0f                	js     80222a <getchar+0x29>
		return r;
	if (r < 1)
  80221b:	85 c0                	test   %eax,%eax
  80221d:	7e 06                	jle    802225 <getchar+0x24>
		return -E_EOF;
	return c;
  80221f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802223:	eb 05                	jmp    80222a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802225:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80222a:	c9                   	leave  
  80222b:	c3                   	ret    

0080222c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80222c:	55                   	push   %ebp
  80222d:	89 e5                	mov    %esp,%ebp
  80222f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802232:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802235:	50                   	push   %eax
  802236:	ff 75 08             	pushl  0x8(%ebp)
  802239:	e8 70 ef ff ff       	call   8011ae <fd_lookup>
  80223e:	83 c4 10             	add    $0x10,%esp
  802241:	85 c0                	test   %eax,%eax
  802243:	78 11                	js     802256 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802245:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802248:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80224e:	39 10                	cmp    %edx,(%eax)
  802250:	0f 94 c0             	sete   %al
  802253:	0f b6 c0             	movzbl %al,%eax
}
  802256:	c9                   	leave  
  802257:	c3                   	ret    

00802258 <opencons>:

int
opencons(void)
{
  802258:	55                   	push   %ebp
  802259:	89 e5                	mov    %esp,%ebp
  80225b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80225e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802261:	50                   	push   %eax
  802262:	e8 f8 ee ff ff       	call   80115f <fd_alloc>
  802267:	83 c4 10             	add    $0x10,%esp
		return r;
  80226a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80226c:	85 c0                	test   %eax,%eax
  80226e:	78 3e                	js     8022ae <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802270:	83 ec 04             	sub    $0x4,%esp
  802273:	68 07 04 00 00       	push   $0x407
  802278:	ff 75 f4             	pushl  -0xc(%ebp)
  80227b:	6a 00                	push   $0x0
  80227d:	e8 2c e9 ff ff       	call   800bae <sys_page_alloc>
  802282:	83 c4 10             	add    $0x10,%esp
		return r;
  802285:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802287:	85 c0                	test   %eax,%eax
  802289:	78 23                	js     8022ae <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80228b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802291:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802294:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802296:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802299:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022a0:	83 ec 0c             	sub    $0xc,%esp
  8022a3:	50                   	push   %eax
  8022a4:	e8 8f ee ff ff       	call   801138 <fd2num>
  8022a9:	89 c2                	mov    %eax,%edx
  8022ab:	83 c4 10             	add    $0x10,%esp
}
  8022ae:	89 d0                	mov    %edx,%eax
  8022b0:	c9                   	leave  
  8022b1:	c3                   	ret    

008022b2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022b2:	55                   	push   %ebp
  8022b3:	89 e5                	mov    %esp,%ebp
  8022b5:	53                   	push   %ebx
  8022b6:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022b9:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8022c0:	75 28                	jne    8022ea <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  8022c2:	e8 a9 e8 ff ff       	call   800b70 <sys_getenvid>
  8022c7:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  8022c9:	83 ec 04             	sub    $0x4,%esp
  8022cc:	6a 06                	push   $0x6
  8022ce:	68 00 f0 bf ee       	push   $0xeebff000
  8022d3:	50                   	push   %eax
  8022d4:	e8 d5 e8 ff ff       	call   800bae <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  8022d9:	83 c4 08             	add    $0x8,%esp
  8022dc:	68 f7 22 80 00       	push   $0x8022f7
  8022e1:	53                   	push   %ebx
  8022e2:	e8 12 ea ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>
  8022e7:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ed:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8022f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022f5:	c9                   	leave  
  8022f6:	c3                   	ret    

008022f7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8022f7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022f8:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8022fd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022ff:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  802302:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  802304:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  802307:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  80230a:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  80230d:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  802310:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  802313:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  802316:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  802319:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  80231c:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  80231f:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  802322:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  802325:	61                   	popa   
	popfl
  802326:	9d                   	popf   
	ret
  802327:	c3                   	ret    

00802328 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802328:	55                   	push   %ebp
  802329:	89 e5                	mov    %esp,%ebp
  80232b:	56                   	push   %esi
  80232c:	53                   	push   %ebx
  80232d:	8b 75 08             	mov    0x8(%ebp),%esi
  802330:	8b 45 0c             	mov    0xc(%ebp),%eax
  802333:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  802336:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802338:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  80233d:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  802340:	83 ec 0c             	sub    $0xc,%esp
  802343:	50                   	push   %eax
  802344:	e8 15 ea ff ff       	call   800d5e <sys_ipc_recv>

	if (r < 0) {
  802349:	83 c4 10             	add    $0x10,%esp
  80234c:	85 c0                	test   %eax,%eax
  80234e:	79 16                	jns    802366 <ipc_recv+0x3e>
		if (from_env_store)
  802350:	85 f6                	test   %esi,%esi
  802352:	74 06                	je     80235a <ipc_recv+0x32>
			*from_env_store = 0;
  802354:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  80235a:	85 db                	test   %ebx,%ebx
  80235c:	74 2c                	je     80238a <ipc_recv+0x62>
			*perm_store = 0;
  80235e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802364:	eb 24                	jmp    80238a <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  802366:	85 f6                	test   %esi,%esi
  802368:	74 0a                	je     802374 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  80236a:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80236f:	8b 40 74             	mov    0x74(%eax),%eax
  802372:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  802374:	85 db                	test   %ebx,%ebx
  802376:	74 0a                	je     802382 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  802378:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80237d:	8b 40 78             	mov    0x78(%eax),%eax
  802380:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  802382:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802387:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  80238a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80238d:	5b                   	pop    %ebx
  80238e:	5e                   	pop    %esi
  80238f:	5d                   	pop    %ebp
  802390:	c3                   	ret    

00802391 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802391:	55                   	push   %ebp
  802392:	89 e5                	mov    %esp,%ebp
  802394:	57                   	push   %edi
  802395:	56                   	push   %esi
  802396:	53                   	push   %ebx
  802397:	83 ec 0c             	sub    $0xc,%esp
  80239a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80239d:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8023a3:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8023a5:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8023aa:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8023ad:	ff 75 14             	pushl  0x14(%ebp)
  8023b0:	53                   	push   %ebx
  8023b1:	56                   	push   %esi
  8023b2:	57                   	push   %edi
  8023b3:	e8 83 e9 ff ff       	call   800d3b <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  8023b8:	83 c4 10             	add    $0x10,%esp
  8023bb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023be:	75 07                	jne    8023c7 <ipc_send+0x36>
			sys_yield();
  8023c0:	e8 ca e7 ff ff       	call   800b8f <sys_yield>
  8023c5:	eb e6                	jmp    8023ad <ipc_send+0x1c>
		} else if (r < 0) {
  8023c7:	85 c0                	test   %eax,%eax
  8023c9:	79 12                	jns    8023dd <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  8023cb:	50                   	push   %eax
  8023cc:	68 93 2c 80 00       	push   $0x802c93
  8023d1:	6a 51                	push   $0x51
  8023d3:	68 a0 2c 80 00       	push   $0x802ca0
  8023d8:	e8 70 dd ff ff       	call   80014d <_panic>
		}
	}
}
  8023dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023e0:	5b                   	pop    %ebx
  8023e1:	5e                   	pop    %esi
  8023e2:	5f                   	pop    %edi
  8023e3:	5d                   	pop    %ebp
  8023e4:	c3                   	ret    

008023e5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023e5:	55                   	push   %ebp
  8023e6:	89 e5                	mov    %esp,%ebp
  8023e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023eb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023f0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8023f3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023f9:	8b 52 50             	mov    0x50(%edx),%edx
  8023fc:	39 ca                	cmp    %ecx,%edx
  8023fe:	75 0d                	jne    80240d <ipc_find_env+0x28>
			return envs[i].env_id;
  802400:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802403:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802408:	8b 40 48             	mov    0x48(%eax),%eax
  80240b:	eb 0f                	jmp    80241c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80240d:	83 c0 01             	add    $0x1,%eax
  802410:	3d 00 04 00 00       	cmp    $0x400,%eax
  802415:	75 d9                	jne    8023f0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802417:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80241c:	5d                   	pop    %ebp
  80241d:	c3                   	ret    

0080241e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80241e:	55                   	push   %ebp
  80241f:	89 e5                	mov    %esp,%ebp
  802421:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802424:	89 d0                	mov    %edx,%eax
  802426:	c1 e8 16             	shr    $0x16,%eax
  802429:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802430:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802435:	f6 c1 01             	test   $0x1,%cl
  802438:	74 1d                	je     802457 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80243a:	c1 ea 0c             	shr    $0xc,%edx
  80243d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802444:	f6 c2 01             	test   $0x1,%dl
  802447:	74 0e                	je     802457 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802449:	c1 ea 0c             	shr    $0xc,%edx
  80244c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802453:	ef 
  802454:	0f b7 c0             	movzwl %ax,%eax
}
  802457:	5d                   	pop    %ebp
  802458:	c3                   	ret    
  802459:	66 90                	xchg   %ax,%ax
  80245b:	66 90                	xchg   %ax,%ax
  80245d:	66 90                	xchg   %ax,%ax
  80245f:	90                   	nop

00802460 <__udivdi3>:
  802460:	55                   	push   %ebp
  802461:	57                   	push   %edi
  802462:	56                   	push   %esi
  802463:	53                   	push   %ebx
  802464:	83 ec 1c             	sub    $0x1c,%esp
  802467:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80246b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80246f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802473:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802477:	85 f6                	test   %esi,%esi
  802479:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80247d:	89 ca                	mov    %ecx,%edx
  80247f:	89 f8                	mov    %edi,%eax
  802481:	75 3d                	jne    8024c0 <__udivdi3+0x60>
  802483:	39 cf                	cmp    %ecx,%edi
  802485:	0f 87 c5 00 00 00    	ja     802550 <__udivdi3+0xf0>
  80248b:	85 ff                	test   %edi,%edi
  80248d:	89 fd                	mov    %edi,%ebp
  80248f:	75 0b                	jne    80249c <__udivdi3+0x3c>
  802491:	b8 01 00 00 00       	mov    $0x1,%eax
  802496:	31 d2                	xor    %edx,%edx
  802498:	f7 f7                	div    %edi
  80249a:	89 c5                	mov    %eax,%ebp
  80249c:	89 c8                	mov    %ecx,%eax
  80249e:	31 d2                	xor    %edx,%edx
  8024a0:	f7 f5                	div    %ebp
  8024a2:	89 c1                	mov    %eax,%ecx
  8024a4:	89 d8                	mov    %ebx,%eax
  8024a6:	89 cf                	mov    %ecx,%edi
  8024a8:	f7 f5                	div    %ebp
  8024aa:	89 c3                	mov    %eax,%ebx
  8024ac:	89 d8                	mov    %ebx,%eax
  8024ae:	89 fa                	mov    %edi,%edx
  8024b0:	83 c4 1c             	add    $0x1c,%esp
  8024b3:	5b                   	pop    %ebx
  8024b4:	5e                   	pop    %esi
  8024b5:	5f                   	pop    %edi
  8024b6:	5d                   	pop    %ebp
  8024b7:	c3                   	ret    
  8024b8:	90                   	nop
  8024b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024c0:	39 ce                	cmp    %ecx,%esi
  8024c2:	77 74                	ja     802538 <__udivdi3+0xd8>
  8024c4:	0f bd fe             	bsr    %esi,%edi
  8024c7:	83 f7 1f             	xor    $0x1f,%edi
  8024ca:	0f 84 98 00 00 00    	je     802568 <__udivdi3+0x108>
  8024d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024d5:	89 f9                	mov    %edi,%ecx
  8024d7:	89 c5                	mov    %eax,%ebp
  8024d9:	29 fb                	sub    %edi,%ebx
  8024db:	d3 e6                	shl    %cl,%esi
  8024dd:	89 d9                	mov    %ebx,%ecx
  8024df:	d3 ed                	shr    %cl,%ebp
  8024e1:	89 f9                	mov    %edi,%ecx
  8024e3:	d3 e0                	shl    %cl,%eax
  8024e5:	09 ee                	or     %ebp,%esi
  8024e7:	89 d9                	mov    %ebx,%ecx
  8024e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024ed:	89 d5                	mov    %edx,%ebp
  8024ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024f3:	d3 ed                	shr    %cl,%ebp
  8024f5:	89 f9                	mov    %edi,%ecx
  8024f7:	d3 e2                	shl    %cl,%edx
  8024f9:	89 d9                	mov    %ebx,%ecx
  8024fb:	d3 e8                	shr    %cl,%eax
  8024fd:	09 c2                	or     %eax,%edx
  8024ff:	89 d0                	mov    %edx,%eax
  802501:	89 ea                	mov    %ebp,%edx
  802503:	f7 f6                	div    %esi
  802505:	89 d5                	mov    %edx,%ebp
  802507:	89 c3                	mov    %eax,%ebx
  802509:	f7 64 24 0c          	mull   0xc(%esp)
  80250d:	39 d5                	cmp    %edx,%ebp
  80250f:	72 10                	jb     802521 <__udivdi3+0xc1>
  802511:	8b 74 24 08          	mov    0x8(%esp),%esi
  802515:	89 f9                	mov    %edi,%ecx
  802517:	d3 e6                	shl    %cl,%esi
  802519:	39 c6                	cmp    %eax,%esi
  80251b:	73 07                	jae    802524 <__udivdi3+0xc4>
  80251d:	39 d5                	cmp    %edx,%ebp
  80251f:	75 03                	jne    802524 <__udivdi3+0xc4>
  802521:	83 eb 01             	sub    $0x1,%ebx
  802524:	31 ff                	xor    %edi,%edi
  802526:	89 d8                	mov    %ebx,%eax
  802528:	89 fa                	mov    %edi,%edx
  80252a:	83 c4 1c             	add    $0x1c,%esp
  80252d:	5b                   	pop    %ebx
  80252e:	5e                   	pop    %esi
  80252f:	5f                   	pop    %edi
  802530:	5d                   	pop    %ebp
  802531:	c3                   	ret    
  802532:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802538:	31 ff                	xor    %edi,%edi
  80253a:	31 db                	xor    %ebx,%ebx
  80253c:	89 d8                	mov    %ebx,%eax
  80253e:	89 fa                	mov    %edi,%edx
  802540:	83 c4 1c             	add    $0x1c,%esp
  802543:	5b                   	pop    %ebx
  802544:	5e                   	pop    %esi
  802545:	5f                   	pop    %edi
  802546:	5d                   	pop    %ebp
  802547:	c3                   	ret    
  802548:	90                   	nop
  802549:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802550:	89 d8                	mov    %ebx,%eax
  802552:	f7 f7                	div    %edi
  802554:	31 ff                	xor    %edi,%edi
  802556:	89 c3                	mov    %eax,%ebx
  802558:	89 d8                	mov    %ebx,%eax
  80255a:	89 fa                	mov    %edi,%edx
  80255c:	83 c4 1c             	add    $0x1c,%esp
  80255f:	5b                   	pop    %ebx
  802560:	5e                   	pop    %esi
  802561:	5f                   	pop    %edi
  802562:	5d                   	pop    %ebp
  802563:	c3                   	ret    
  802564:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802568:	39 ce                	cmp    %ecx,%esi
  80256a:	72 0c                	jb     802578 <__udivdi3+0x118>
  80256c:	31 db                	xor    %ebx,%ebx
  80256e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802572:	0f 87 34 ff ff ff    	ja     8024ac <__udivdi3+0x4c>
  802578:	bb 01 00 00 00       	mov    $0x1,%ebx
  80257d:	e9 2a ff ff ff       	jmp    8024ac <__udivdi3+0x4c>
  802582:	66 90                	xchg   %ax,%ax
  802584:	66 90                	xchg   %ax,%ax
  802586:	66 90                	xchg   %ax,%ax
  802588:	66 90                	xchg   %ax,%ax
  80258a:	66 90                	xchg   %ax,%ax
  80258c:	66 90                	xchg   %ax,%ax
  80258e:	66 90                	xchg   %ax,%ax

00802590 <__umoddi3>:
  802590:	55                   	push   %ebp
  802591:	57                   	push   %edi
  802592:	56                   	push   %esi
  802593:	53                   	push   %ebx
  802594:	83 ec 1c             	sub    $0x1c,%esp
  802597:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80259b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80259f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025a7:	85 d2                	test   %edx,%edx
  8025a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025b1:	89 f3                	mov    %esi,%ebx
  8025b3:	89 3c 24             	mov    %edi,(%esp)
  8025b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025ba:	75 1c                	jne    8025d8 <__umoddi3+0x48>
  8025bc:	39 f7                	cmp    %esi,%edi
  8025be:	76 50                	jbe    802610 <__umoddi3+0x80>
  8025c0:	89 c8                	mov    %ecx,%eax
  8025c2:	89 f2                	mov    %esi,%edx
  8025c4:	f7 f7                	div    %edi
  8025c6:	89 d0                	mov    %edx,%eax
  8025c8:	31 d2                	xor    %edx,%edx
  8025ca:	83 c4 1c             	add    $0x1c,%esp
  8025cd:	5b                   	pop    %ebx
  8025ce:	5e                   	pop    %esi
  8025cf:	5f                   	pop    %edi
  8025d0:	5d                   	pop    %ebp
  8025d1:	c3                   	ret    
  8025d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025d8:	39 f2                	cmp    %esi,%edx
  8025da:	89 d0                	mov    %edx,%eax
  8025dc:	77 52                	ja     802630 <__umoddi3+0xa0>
  8025de:	0f bd ea             	bsr    %edx,%ebp
  8025e1:	83 f5 1f             	xor    $0x1f,%ebp
  8025e4:	75 5a                	jne    802640 <__umoddi3+0xb0>
  8025e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025ea:	0f 82 e0 00 00 00    	jb     8026d0 <__umoddi3+0x140>
  8025f0:	39 0c 24             	cmp    %ecx,(%esp)
  8025f3:	0f 86 d7 00 00 00    	jbe    8026d0 <__umoddi3+0x140>
  8025f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802601:	83 c4 1c             	add    $0x1c,%esp
  802604:	5b                   	pop    %ebx
  802605:	5e                   	pop    %esi
  802606:	5f                   	pop    %edi
  802607:	5d                   	pop    %ebp
  802608:	c3                   	ret    
  802609:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802610:	85 ff                	test   %edi,%edi
  802612:	89 fd                	mov    %edi,%ebp
  802614:	75 0b                	jne    802621 <__umoddi3+0x91>
  802616:	b8 01 00 00 00       	mov    $0x1,%eax
  80261b:	31 d2                	xor    %edx,%edx
  80261d:	f7 f7                	div    %edi
  80261f:	89 c5                	mov    %eax,%ebp
  802621:	89 f0                	mov    %esi,%eax
  802623:	31 d2                	xor    %edx,%edx
  802625:	f7 f5                	div    %ebp
  802627:	89 c8                	mov    %ecx,%eax
  802629:	f7 f5                	div    %ebp
  80262b:	89 d0                	mov    %edx,%eax
  80262d:	eb 99                	jmp    8025c8 <__umoddi3+0x38>
  80262f:	90                   	nop
  802630:	89 c8                	mov    %ecx,%eax
  802632:	89 f2                	mov    %esi,%edx
  802634:	83 c4 1c             	add    $0x1c,%esp
  802637:	5b                   	pop    %ebx
  802638:	5e                   	pop    %esi
  802639:	5f                   	pop    %edi
  80263a:	5d                   	pop    %ebp
  80263b:	c3                   	ret    
  80263c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802640:	8b 34 24             	mov    (%esp),%esi
  802643:	bf 20 00 00 00       	mov    $0x20,%edi
  802648:	89 e9                	mov    %ebp,%ecx
  80264a:	29 ef                	sub    %ebp,%edi
  80264c:	d3 e0                	shl    %cl,%eax
  80264e:	89 f9                	mov    %edi,%ecx
  802650:	89 f2                	mov    %esi,%edx
  802652:	d3 ea                	shr    %cl,%edx
  802654:	89 e9                	mov    %ebp,%ecx
  802656:	09 c2                	or     %eax,%edx
  802658:	89 d8                	mov    %ebx,%eax
  80265a:	89 14 24             	mov    %edx,(%esp)
  80265d:	89 f2                	mov    %esi,%edx
  80265f:	d3 e2                	shl    %cl,%edx
  802661:	89 f9                	mov    %edi,%ecx
  802663:	89 54 24 04          	mov    %edx,0x4(%esp)
  802667:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80266b:	d3 e8                	shr    %cl,%eax
  80266d:	89 e9                	mov    %ebp,%ecx
  80266f:	89 c6                	mov    %eax,%esi
  802671:	d3 e3                	shl    %cl,%ebx
  802673:	89 f9                	mov    %edi,%ecx
  802675:	89 d0                	mov    %edx,%eax
  802677:	d3 e8                	shr    %cl,%eax
  802679:	89 e9                	mov    %ebp,%ecx
  80267b:	09 d8                	or     %ebx,%eax
  80267d:	89 d3                	mov    %edx,%ebx
  80267f:	89 f2                	mov    %esi,%edx
  802681:	f7 34 24             	divl   (%esp)
  802684:	89 d6                	mov    %edx,%esi
  802686:	d3 e3                	shl    %cl,%ebx
  802688:	f7 64 24 04          	mull   0x4(%esp)
  80268c:	39 d6                	cmp    %edx,%esi
  80268e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802692:	89 d1                	mov    %edx,%ecx
  802694:	89 c3                	mov    %eax,%ebx
  802696:	72 08                	jb     8026a0 <__umoddi3+0x110>
  802698:	75 11                	jne    8026ab <__umoddi3+0x11b>
  80269a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80269e:	73 0b                	jae    8026ab <__umoddi3+0x11b>
  8026a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026a4:	1b 14 24             	sbb    (%esp),%edx
  8026a7:	89 d1                	mov    %edx,%ecx
  8026a9:	89 c3                	mov    %eax,%ebx
  8026ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8026af:	29 da                	sub    %ebx,%edx
  8026b1:	19 ce                	sbb    %ecx,%esi
  8026b3:	89 f9                	mov    %edi,%ecx
  8026b5:	89 f0                	mov    %esi,%eax
  8026b7:	d3 e0                	shl    %cl,%eax
  8026b9:	89 e9                	mov    %ebp,%ecx
  8026bb:	d3 ea                	shr    %cl,%edx
  8026bd:	89 e9                	mov    %ebp,%ecx
  8026bf:	d3 ee                	shr    %cl,%esi
  8026c1:	09 d0                	or     %edx,%eax
  8026c3:	89 f2                	mov    %esi,%edx
  8026c5:	83 c4 1c             	add    $0x1c,%esp
  8026c8:	5b                   	pop    %ebx
  8026c9:	5e                   	pop    %esi
  8026ca:	5f                   	pop    %edi
  8026cb:	5d                   	pop    %ebp
  8026cc:	c3                   	ret    
  8026cd:	8d 76 00             	lea    0x0(%esi),%esi
  8026d0:	29 f9                	sub    %edi,%ecx
  8026d2:	19 d6                	sbb    %edx,%esi
  8026d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026dc:	e9 18 ff ff ff       	jmp    8025f9 <__umoddi3+0x69>
