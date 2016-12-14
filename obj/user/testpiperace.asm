
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 b3 01 00 00       	call   8001e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003b:	68 e0 27 80 00       	push   $0x8027e0
  800040:	e8 d8 02 00 00       	call   80031d <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 81 21 00 00       	call   8021d1 <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 f9 27 80 00       	push   $0x8027f9
  80005d:	6a 0d                	push   $0xd
  80005f:	68 02 28 80 00       	push   $0x802802
  800064:	e8 db 01 00 00       	call   800244 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 e2 0f 00 00       	call   801050 <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 a6 2c 80 00       	push   $0x802ca6
  80007a:	6a 10                	push   $0x10
  80007c:	68 02 28 80 00       	push   $0x802802
  800081:	e8 be 01 00 00       	call   800244 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 30 14 00 00       	call   8014c5 <close>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  80009d:	83 ec 0c             	sub    $0xc,%esp
  8000a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8000a3:	e8 7c 22 00 00       	call   802324 <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 16 28 80 00       	push   $0x802816
  8000b7:	e8 61 02 00 00       	call   80031d <cprintf>
				exit();
  8000bc:	e8 69 01 00 00       	call   80022a <exit>
  8000c1:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c4:	e8 bd 0b 00 00       	call   800c86 <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000c9:	83 eb 01             	sub    $0x1,%ebx
  8000cc:	75 cf                	jne    80009d <umain+0x6a>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	6a 00                	push   $0x0
  8000d3:	6a 00                	push   $0x0
  8000d5:	6a 00                	push   $0x0
  8000d7:	e8 53 11 00 00       	call   80122f <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 31 28 80 00       	push   $0x802831
  8000e8:	e8 30 02 00 00       	call   80031d <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000ed:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	6b c6 7c             	imul   $0x7c,%esi,%eax
  8000f9:	c1 f8 02             	sar    $0x2,%eax
  8000fc:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
  800102:	50                   	push   %eax
  800103:	68 3c 28 80 00       	push   $0x80283c
  800108:	e8 10 02 00 00       	call   80031d <cprintf>
	dup(p[0], 10);
  80010d:	83 c4 08             	add    $0x8,%esp
  800110:	6a 0a                	push   $0xa
  800112:	ff 75 f0             	pushl  -0x10(%ebp)
  800115:	e8 fb 13 00 00       	call   801515 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	6b de 7c             	imul   $0x7c,%esi,%ebx
  800120:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800126:	eb 10                	jmp    800138 <umain+0x105>
		dup(p[0], 10);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 0a                	push   $0xa
  80012d:	ff 75 f0             	pushl  -0x10(%ebp)
  800130:	e8 e0 13 00 00       	call   801515 <dup>
  800135:	83 c4 10             	add    $0x10,%esp
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800138:	8b 53 54             	mov    0x54(%ebx),%edx
  80013b:	83 fa 02             	cmp    $0x2,%edx
  80013e:	74 e8                	je     800128 <umain+0xf5>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	68 47 28 80 00       	push   $0x802847
  800148:	e8 d0 01 00 00       	call   80031d <cprintf>
	if (pipeisclosed(p[0]))
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 f0             	pushl  -0x10(%ebp)
  800153:	e8 cc 21 00 00       	call   802324 <pipeisclosed>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 14                	je     800173 <umain+0x140>
		panic("somehow the other end of p[0] got closed!");
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	68 a0 28 80 00       	push   $0x8028a0
  800167:	6a 3a                	push   $0x3a
  800169:	68 02 28 80 00       	push   $0x802802
  80016e:	e8 d1 00 00 00       	call   800244 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	ff 75 f0             	pushl  -0x10(%ebp)
  80017d:	e8 19 12 00 00       	call   80139b <fd_lookup>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	85 c0                	test   %eax,%eax
  800187:	79 12                	jns    80019b <umain+0x168>
		panic("cannot look up p[0]: %e", r);
  800189:	50                   	push   %eax
  80018a:	68 5d 28 80 00       	push   $0x80285d
  80018f:	6a 3c                	push   $0x3c
  800191:	68 02 28 80 00       	push   $0x802802
  800196:	e8 a9 00 00 00       	call   800244 <_panic>
	va = fd2data(fd);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a1:	e8 8f 11 00 00       	call   801335 <fd2data>
	if (pageref(va) != 3+1)
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 ab 19 00 00       	call   801b59 <pageref>
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	83 f8 04             	cmp    $0x4,%eax
  8001b4:	74 12                	je     8001c8 <umain+0x195>
		cprintf("\nchild detected race\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 75 28 80 00       	push   $0x802875
  8001be:	e8 5a 01 00 00       	call   80031d <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb 15                	jmp    8001dd <umain+0x1aa>
	else
		cprintf("\nrace didn't happen\n", max);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 c8 00 00 00       	push   $0xc8
  8001d0:	68 8b 28 80 00       	push   $0x80288b
  8001d5:	e8 43 01 00 00       	call   80031d <cprintf>
  8001da:	83 c4 10             	add    $0x10,%esp
}
  8001dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ef:	e8 73 0a 00 00       	call   800c67 <sys_getenvid>
  8001f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800201:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800206:	85 db                	test   %ebx,%ebx
  800208:	7e 07                	jle    800211 <libmain+0x2d>
		binaryname = argv[0];
  80020a:	8b 06                	mov    (%esi),%eax
  80020c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	e8 18 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80021b:	e8 0a 00 00 00       	call   80022a <exit>
}
  800220:	83 c4 10             	add    $0x10,%esp
  800223:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800230:	e8 bb 12 00 00       	call   8014f0 <close_all>
	sys_env_destroy(0);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	6a 00                	push   $0x0
  80023a:	e8 e7 09 00 00       	call   800c26 <sys_env_destroy>
}
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800249:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80024c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800252:	e8 10 0a 00 00       	call   800c67 <sys_getenvid>
  800257:	83 ec 0c             	sub    $0xc,%esp
  80025a:	ff 75 0c             	pushl  0xc(%ebp)
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	56                   	push   %esi
  800261:	50                   	push   %eax
  800262:	68 d4 28 80 00       	push   $0x8028d4
  800267:	e8 b1 00 00 00       	call   80031d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026c:	83 c4 18             	add    $0x18,%esp
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	e8 54 00 00 00       	call   8002cc <vcprintf>
	cprintf("\n");
  800278:	c7 04 24 f7 27 80 00 	movl   $0x8027f7,(%esp)
  80027f:	e8 99 00 00 00       	call   80031d <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800287:	cc                   	int3   
  800288:	eb fd                	jmp    800287 <_panic+0x43>

0080028a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	53                   	push   %ebx
  80028e:	83 ec 04             	sub    $0x4,%esp
  800291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800294:	8b 13                	mov    (%ebx),%edx
  800296:	8d 42 01             	lea    0x1(%edx),%eax
  800299:	89 03                	mov    %eax,(%ebx)
  80029b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a7:	75 1a                	jne    8002c3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	68 ff 00 00 00       	push   $0xff
  8002b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b4:	50                   	push   %eax
  8002b5:	e8 2f 09 00 00       	call   800be9 <sys_cputs>
		b->idx = 0;
  8002ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002dc:	00 00 00 
	b.cnt = 0;
  8002df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ec:	ff 75 08             	pushl  0x8(%ebp)
  8002ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f5:	50                   	push   %eax
  8002f6:	68 8a 02 80 00       	push   $0x80028a
  8002fb:	e8 54 01 00 00       	call   800454 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800300:	83 c4 08             	add    $0x8,%esp
  800303:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800309:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80030f:	50                   	push   %eax
  800310:	e8 d4 08 00 00       	call   800be9 <sys_cputs>

	return b.cnt;
}
  800315:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800323:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800326:	50                   	push   %eax
  800327:	ff 75 08             	pushl  0x8(%ebp)
  80032a:	e8 9d ff ff ff       	call   8002cc <vcprintf>
	va_end(ap);

	return cnt;
}
  80032f:	c9                   	leave  
  800330:	c3                   	ret    

00800331 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 1c             	sub    $0x1c,%esp
  80033a:	89 c7                	mov    %eax,%edi
  80033c:	89 d6                	mov    %edx,%esi
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	8b 55 0c             	mov    0xc(%ebp),%edx
  800344:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800347:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80034a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80034d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800352:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800355:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800358:	39 d3                	cmp    %edx,%ebx
  80035a:	72 05                	jb     800361 <printnum+0x30>
  80035c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80035f:	77 45                	ja     8003a6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800361:	83 ec 0c             	sub    $0xc,%esp
  800364:	ff 75 18             	pushl  0x18(%ebp)
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80036d:	53                   	push   %ebx
  80036e:	ff 75 10             	pushl  0x10(%ebp)
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	ff 75 e4             	pushl  -0x1c(%ebp)
  800377:	ff 75 e0             	pushl  -0x20(%ebp)
  80037a:	ff 75 dc             	pushl  -0x24(%ebp)
  80037d:	ff 75 d8             	pushl  -0x28(%ebp)
  800380:	e8 cb 21 00 00       	call   802550 <__udivdi3>
  800385:	83 c4 18             	add    $0x18,%esp
  800388:	52                   	push   %edx
  800389:	50                   	push   %eax
  80038a:	89 f2                	mov    %esi,%edx
  80038c:	89 f8                	mov    %edi,%eax
  80038e:	e8 9e ff ff ff       	call   800331 <printnum>
  800393:	83 c4 20             	add    $0x20,%esp
  800396:	eb 18                	jmp    8003b0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	56                   	push   %esi
  80039c:	ff 75 18             	pushl  0x18(%ebp)
  80039f:	ff d7                	call   *%edi
  8003a1:	83 c4 10             	add    $0x10,%esp
  8003a4:	eb 03                	jmp    8003a9 <printnum+0x78>
  8003a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a9:	83 eb 01             	sub    $0x1,%ebx
  8003ac:	85 db                	test   %ebx,%ebx
  8003ae:	7f e8                	jg     800398 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b0:	83 ec 08             	sub    $0x8,%esp
  8003b3:	56                   	push   %esi
  8003b4:	83 ec 04             	sub    $0x4,%esp
  8003b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8003bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c3:	e8 b8 22 00 00       	call   802680 <__umoddi3>
  8003c8:	83 c4 14             	add    $0x14,%esp
  8003cb:	0f be 80 f7 28 80 00 	movsbl 0x8028f7(%eax),%eax
  8003d2:	50                   	push   %eax
  8003d3:	ff d7                	call   *%edi
}
  8003d5:	83 c4 10             	add    $0x10,%esp
  8003d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003db:	5b                   	pop    %ebx
  8003dc:	5e                   	pop    %esi
  8003dd:	5f                   	pop    %edi
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e3:	83 fa 01             	cmp    $0x1,%edx
  8003e6:	7e 0e                	jle    8003f6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003e8:	8b 10                	mov    (%eax),%edx
  8003ea:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003ed:	89 08                	mov    %ecx,(%eax)
  8003ef:	8b 02                	mov    (%edx),%eax
  8003f1:	8b 52 04             	mov    0x4(%edx),%edx
  8003f4:	eb 22                	jmp    800418 <getuint+0x38>
	else if (lflag)
  8003f6:	85 d2                	test   %edx,%edx
  8003f8:	74 10                	je     80040a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003fa:	8b 10                	mov    (%eax),%edx
  8003fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ff:	89 08                	mov    %ecx,(%eax)
  800401:	8b 02                	mov    (%edx),%eax
  800403:	ba 00 00 00 00       	mov    $0x0,%edx
  800408:	eb 0e                	jmp    800418 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80040a:	8b 10                	mov    (%eax),%edx
  80040c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80040f:	89 08                	mov    %ecx,(%eax)
  800411:	8b 02                	mov    (%edx),%eax
  800413:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800418:	5d                   	pop    %ebp
  800419:	c3                   	ret    

0080041a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800420:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800424:	8b 10                	mov    (%eax),%edx
  800426:	3b 50 04             	cmp    0x4(%eax),%edx
  800429:	73 0a                	jae    800435 <sprintputch+0x1b>
		*b->buf++ = ch;
  80042b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80042e:	89 08                	mov    %ecx,(%eax)
  800430:	8b 45 08             	mov    0x8(%ebp),%eax
  800433:	88 02                	mov    %al,(%edx)
}
  800435:	5d                   	pop    %ebp
  800436:	c3                   	ret    

00800437 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800437:	55                   	push   %ebp
  800438:	89 e5                	mov    %esp,%ebp
  80043a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80043d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800440:	50                   	push   %eax
  800441:	ff 75 10             	pushl  0x10(%ebp)
  800444:	ff 75 0c             	pushl  0xc(%ebp)
  800447:	ff 75 08             	pushl  0x8(%ebp)
  80044a:	e8 05 00 00 00       	call   800454 <vprintfmt>
	va_end(ap);
}
  80044f:	83 c4 10             	add    $0x10,%esp
  800452:	c9                   	leave  
  800453:	c3                   	ret    

00800454 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	57                   	push   %edi
  800458:	56                   	push   %esi
  800459:	53                   	push   %ebx
  80045a:	83 ec 2c             	sub    $0x2c,%esp
  80045d:	8b 75 08             	mov    0x8(%ebp),%esi
  800460:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800463:	8b 7d 10             	mov    0x10(%ebp),%edi
  800466:	eb 12                	jmp    80047a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800468:	85 c0                	test   %eax,%eax
  80046a:	0f 84 89 03 00 00    	je     8007f9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	53                   	push   %ebx
  800474:	50                   	push   %eax
  800475:	ff d6                	call   *%esi
  800477:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80047a:	83 c7 01             	add    $0x1,%edi
  80047d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800481:	83 f8 25             	cmp    $0x25,%eax
  800484:	75 e2                	jne    800468 <vprintfmt+0x14>
  800486:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80048a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800491:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800498:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80049f:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a4:	eb 07                	jmp    8004ad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8d 47 01             	lea    0x1(%edi),%eax
  8004b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b3:	0f b6 07             	movzbl (%edi),%eax
  8004b6:	0f b6 c8             	movzbl %al,%ecx
  8004b9:	83 e8 23             	sub    $0x23,%eax
  8004bc:	3c 55                	cmp    $0x55,%al
  8004be:	0f 87 1a 03 00 00    	ja     8007de <vprintfmt+0x38a>
  8004c4:	0f b6 c0             	movzbl %al,%eax
  8004c7:	ff 24 85 40 2a 80 00 	jmp    *0x802a40(,%eax,4)
  8004ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004d1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004d5:	eb d6                	jmp    8004ad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004da:	b8 00 00 00 00       	mov    $0x0,%eax
  8004df:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004e5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004e9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004ec:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004ef:	83 fa 09             	cmp    $0x9,%edx
  8004f2:	77 39                	ja     80052d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f7:	eb e9                	jmp    8004e2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8d 48 04             	lea    0x4(%eax),%ecx
  8004ff:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800502:	8b 00                	mov    (%eax),%eax
  800504:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80050a:	eb 27                	jmp    800533 <vprintfmt+0xdf>
  80050c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80050f:	85 c0                	test   %eax,%eax
  800511:	b9 00 00 00 00       	mov    $0x0,%ecx
  800516:	0f 49 c8             	cmovns %eax,%ecx
  800519:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051f:	eb 8c                	jmp    8004ad <vprintfmt+0x59>
  800521:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800524:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80052b:	eb 80                	jmp    8004ad <vprintfmt+0x59>
  80052d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800530:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800533:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800537:	0f 89 70 ff ff ff    	jns    8004ad <vprintfmt+0x59>
				width = precision, precision = -1;
  80053d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800540:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800543:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80054a:	e9 5e ff ff ff       	jmp    8004ad <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80054f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800555:	e9 53 ff ff ff       	jmp    8004ad <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 50 04             	lea    0x4(%eax),%edx
  800560:	89 55 14             	mov    %edx,0x14(%ebp)
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	53                   	push   %ebx
  800567:	ff 30                	pushl  (%eax)
  800569:	ff d6                	call   *%esi
			break;
  80056b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800571:	e9 04 ff ff ff       	jmp    80047a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8d 50 04             	lea    0x4(%eax),%edx
  80057c:	89 55 14             	mov    %edx,0x14(%ebp)
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	99                   	cltd   
  800582:	31 d0                	xor    %edx,%eax
  800584:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800586:	83 f8 0f             	cmp    $0xf,%eax
  800589:	7f 0b                	jg     800596 <vprintfmt+0x142>
  80058b:	8b 14 85 a0 2b 80 00 	mov    0x802ba0(,%eax,4),%edx
  800592:	85 d2                	test   %edx,%edx
  800594:	75 18                	jne    8005ae <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800596:	50                   	push   %eax
  800597:	68 0f 29 80 00       	push   $0x80290f
  80059c:	53                   	push   %ebx
  80059d:	56                   	push   %esi
  80059e:	e8 94 fe ff ff       	call   800437 <printfmt>
  8005a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005a9:	e9 cc fe ff ff       	jmp    80047a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005ae:	52                   	push   %edx
  8005af:	68 a6 2d 80 00       	push   $0x802da6
  8005b4:	53                   	push   %ebx
  8005b5:	56                   	push   %esi
  8005b6:	e8 7c fe ff ff       	call   800437 <printfmt>
  8005bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c1:	e9 b4 fe ff ff       	jmp    80047a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 50 04             	lea    0x4(%eax),%edx
  8005cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cf:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005d1:	85 ff                	test   %edi,%edi
  8005d3:	b8 08 29 80 00       	mov    $0x802908,%eax
  8005d8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005df:	0f 8e 94 00 00 00    	jle    800679 <vprintfmt+0x225>
  8005e5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005e9:	0f 84 98 00 00 00    	je     800687 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	ff 75 d0             	pushl  -0x30(%ebp)
  8005f5:	57                   	push   %edi
  8005f6:	e8 86 02 00 00       	call   800881 <strnlen>
  8005fb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005fe:	29 c1                	sub    %eax,%ecx
  800600:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800603:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800606:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80060a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800610:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800612:	eb 0f                	jmp    800623 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	53                   	push   %ebx
  800618:	ff 75 e0             	pushl  -0x20(%ebp)
  80061b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80061d:	83 ef 01             	sub    $0x1,%edi
  800620:	83 c4 10             	add    $0x10,%esp
  800623:	85 ff                	test   %edi,%edi
  800625:	7f ed                	jg     800614 <vprintfmt+0x1c0>
  800627:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80062a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80062d:	85 c9                	test   %ecx,%ecx
  80062f:	b8 00 00 00 00       	mov    $0x0,%eax
  800634:	0f 49 c1             	cmovns %ecx,%eax
  800637:	29 c1                	sub    %eax,%ecx
  800639:	89 75 08             	mov    %esi,0x8(%ebp)
  80063c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80063f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800642:	89 cb                	mov    %ecx,%ebx
  800644:	eb 4d                	jmp    800693 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800646:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80064a:	74 1b                	je     800667 <vprintfmt+0x213>
  80064c:	0f be c0             	movsbl %al,%eax
  80064f:	83 e8 20             	sub    $0x20,%eax
  800652:	83 f8 5e             	cmp    $0x5e,%eax
  800655:	76 10                	jbe    800667 <vprintfmt+0x213>
					putch('?', putdat);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	ff 75 0c             	pushl  0xc(%ebp)
  80065d:	6a 3f                	push   $0x3f
  80065f:	ff 55 08             	call   *0x8(%ebp)
  800662:	83 c4 10             	add    $0x10,%esp
  800665:	eb 0d                	jmp    800674 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	ff 75 0c             	pushl  0xc(%ebp)
  80066d:	52                   	push   %edx
  80066e:	ff 55 08             	call   *0x8(%ebp)
  800671:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800674:	83 eb 01             	sub    $0x1,%ebx
  800677:	eb 1a                	jmp    800693 <vprintfmt+0x23f>
  800679:	89 75 08             	mov    %esi,0x8(%ebp)
  80067c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80067f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800682:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800685:	eb 0c                	jmp    800693 <vprintfmt+0x23f>
  800687:	89 75 08             	mov    %esi,0x8(%ebp)
  80068a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80068d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800690:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800693:	83 c7 01             	add    $0x1,%edi
  800696:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80069a:	0f be d0             	movsbl %al,%edx
  80069d:	85 d2                	test   %edx,%edx
  80069f:	74 23                	je     8006c4 <vprintfmt+0x270>
  8006a1:	85 f6                	test   %esi,%esi
  8006a3:	78 a1                	js     800646 <vprintfmt+0x1f2>
  8006a5:	83 ee 01             	sub    $0x1,%esi
  8006a8:	79 9c                	jns    800646 <vprintfmt+0x1f2>
  8006aa:	89 df                	mov    %ebx,%edi
  8006ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8006af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b2:	eb 18                	jmp    8006cc <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	6a 20                	push   $0x20
  8006ba:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006bc:	83 ef 01             	sub    $0x1,%edi
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	eb 08                	jmp    8006cc <vprintfmt+0x278>
  8006c4:	89 df                	mov    %ebx,%edi
  8006c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006cc:	85 ff                	test   %edi,%edi
  8006ce:	7f e4                	jg     8006b4 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d3:	e9 a2 fd ff ff       	jmp    80047a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d8:	83 fa 01             	cmp    $0x1,%edx
  8006db:	7e 16                	jle    8006f3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8d 50 08             	lea    0x8(%eax),%edx
  8006e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e6:	8b 50 04             	mov    0x4(%eax),%edx
  8006e9:	8b 00                	mov    (%eax),%eax
  8006eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006f1:	eb 32                	jmp    800725 <vprintfmt+0x2d1>
	else if (lflag)
  8006f3:	85 d2                	test   %edx,%edx
  8006f5:	74 18                	je     80070f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8d 50 04             	lea    0x4(%eax),%edx
  8006fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800700:	8b 00                	mov    (%eax),%eax
  800702:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800705:	89 c1                	mov    %eax,%ecx
  800707:	c1 f9 1f             	sar    $0x1f,%ecx
  80070a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80070d:	eb 16                	jmp    800725 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8d 50 04             	lea    0x4(%eax),%edx
  800715:	89 55 14             	mov    %edx,0x14(%ebp)
  800718:	8b 00                	mov    (%eax),%eax
  80071a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80071d:	89 c1                	mov    %eax,%ecx
  80071f:	c1 f9 1f             	sar    $0x1f,%ecx
  800722:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800725:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800728:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80072b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800730:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800734:	79 74                	jns    8007aa <vprintfmt+0x356>
				putch('-', putdat);
  800736:	83 ec 08             	sub    $0x8,%esp
  800739:	53                   	push   %ebx
  80073a:	6a 2d                	push   $0x2d
  80073c:	ff d6                	call   *%esi
				num = -(long long) num;
  80073e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800741:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800744:	f7 d8                	neg    %eax
  800746:	83 d2 00             	adc    $0x0,%edx
  800749:	f7 da                	neg    %edx
  80074b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80074e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800753:	eb 55                	jmp    8007aa <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800755:	8d 45 14             	lea    0x14(%ebp),%eax
  800758:	e8 83 fc ff ff       	call   8003e0 <getuint>
			base = 10;
  80075d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800762:	eb 46                	jmp    8007aa <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800764:	8d 45 14             	lea    0x14(%ebp),%eax
  800767:	e8 74 fc ff ff       	call   8003e0 <getuint>
                        base = 8;
  80076c:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800771:	eb 37                	jmp    8007aa <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	53                   	push   %ebx
  800777:	6a 30                	push   $0x30
  800779:	ff d6                	call   *%esi
			putch('x', putdat);
  80077b:	83 c4 08             	add    $0x8,%esp
  80077e:	53                   	push   %ebx
  80077f:	6a 78                	push   $0x78
  800781:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8d 50 04             	lea    0x4(%eax),%edx
  800789:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80078c:	8b 00                	mov    (%eax),%eax
  80078e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800793:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800796:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80079b:	eb 0d                	jmp    8007aa <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80079d:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a0:	e8 3b fc ff ff       	call   8003e0 <getuint>
			base = 16;
  8007a5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007aa:	83 ec 0c             	sub    $0xc,%esp
  8007ad:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007b1:	57                   	push   %edi
  8007b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8007b5:	51                   	push   %ecx
  8007b6:	52                   	push   %edx
  8007b7:	50                   	push   %eax
  8007b8:	89 da                	mov    %ebx,%edx
  8007ba:	89 f0                	mov    %esi,%eax
  8007bc:	e8 70 fb ff ff       	call   800331 <printnum>
			break;
  8007c1:	83 c4 20             	add    $0x20,%esp
  8007c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c7:	e9 ae fc ff ff       	jmp    80047a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	53                   	push   %ebx
  8007d0:	51                   	push   %ecx
  8007d1:	ff d6                	call   *%esi
			break;
  8007d3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007d9:	e9 9c fc ff ff       	jmp    80047a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007de:	83 ec 08             	sub    $0x8,%esp
  8007e1:	53                   	push   %ebx
  8007e2:	6a 25                	push   $0x25
  8007e4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e6:	83 c4 10             	add    $0x10,%esp
  8007e9:	eb 03                	jmp    8007ee <vprintfmt+0x39a>
  8007eb:	83 ef 01             	sub    $0x1,%edi
  8007ee:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007f2:	75 f7                	jne    8007eb <vprintfmt+0x397>
  8007f4:	e9 81 fc ff ff       	jmp    80047a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007fc:	5b                   	pop    %ebx
  8007fd:	5e                   	pop    %esi
  8007fe:	5f                   	pop    %edi
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	83 ec 18             	sub    $0x18,%esp
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
  80080a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800810:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800814:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800817:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081e:	85 c0                	test   %eax,%eax
  800820:	74 26                	je     800848 <vsnprintf+0x47>
  800822:	85 d2                	test   %edx,%edx
  800824:	7e 22                	jle    800848 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800826:	ff 75 14             	pushl  0x14(%ebp)
  800829:	ff 75 10             	pushl  0x10(%ebp)
  80082c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80082f:	50                   	push   %eax
  800830:	68 1a 04 80 00       	push   $0x80041a
  800835:	e8 1a fc ff ff       	call   800454 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80083a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800840:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800843:	83 c4 10             	add    $0x10,%esp
  800846:	eb 05                	jmp    80084d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800848:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800855:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800858:	50                   	push   %eax
  800859:	ff 75 10             	pushl  0x10(%ebp)
  80085c:	ff 75 0c             	pushl  0xc(%ebp)
  80085f:	ff 75 08             	pushl  0x8(%ebp)
  800862:	e8 9a ff ff ff       	call   800801 <vsnprintf>
	va_end(ap);

	return rc;
}
  800867:	c9                   	leave  
  800868:	c3                   	ret    

00800869 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80086f:	b8 00 00 00 00       	mov    $0x0,%eax
  800874:	eb 03                	jmp    800879 <strlen+0x10>
		n++;
  800876:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800879:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80087d:	75 f7                	jne    800876 <strlen+0xd>
		n++;
	return n;
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800887:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088a:	ba 00 00 00 00       	mov    $0x0,%edx
  80088f:	eb 03                	jmp    800894 <strnlen+0x13>
		n++;
  800891:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800894:	39 c2                	cmp    %eax,%edx
  800896:	74 08                	je     8008a0 <strnlen+0x1f>
  800898:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80089c:	75 f3                	jne    800891 <strnlen+0x10>
  80089e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	53                   	push   %ebx
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ac:	89 c2                	mov    %eax,%edx
  8008ae:	83 c2 01             	add    $0x1,%edx
  8008b1:	83 c1 01             	add    $0x1,%ecx
  8008b4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008b8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008bb:	84 db                	test   %bl,%bl
  8008bd:	75 ef                	jne    8008ae <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008bf:	5b                   	pop    %ebx
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	53                   	push   %ebx
  8008c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c9:	53                   	push   %ebx
  8008ca:	e8 9a ff ff ff       	call   800869 <strlen>
  8008cf:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008d2:	ff 75 0c             	pushl  0xc(%ebp)
  8008d5:	01 d8                	add    %ebx,%eax
  8008d7:	50                   	push   %eax
  8008d8:	e8 c5 ff ff ff       	call   8008a2 <strcpy>
	return dst;
}
  8008dd:	89 d8                	mov    %ebx,%eax
  8008df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
  8008e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ef:	89 f3                	mov    %esi,%ebx
  8008f1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f4:	89 f2                	mov    %esi,%edx
  8008f6:	eb 0f                	jmp    800907 <strncpy+0x23>
		*dst++ = *src;
  8008f8:	83 c2 01             	add    $0x1,%edx
  8008fb:	0f b6 01             	movzbl (%ecx),%eax
  8008fe:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800901:	80 39 01             	cmpb   $0x1,(%ecx)
  800904:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800907:	39 da                	cmp    %ebx,%edx
  800909:	75 ed                	jne    8008f8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80090b:	89 f0                	mov    %esi,%eax
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	56                   	push   %esi
  800915:	53                   	push   %ebx
  800916:	8b 75 08             	mov    0x8(%ebp),%esi
  800919:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091c:	8b 55 10             	mov    0x10(%ebp),%edx
  80091f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800921:	85 d2                	test   %edx,%edx
  800923:	74 21                	je     800946 <strlcpy+0x35>
  800925:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800929:	89 f2                	mov    %esi,%edx
  80092b:	eb 09                	jmp    800936 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80092d:	83 c2 01             	add    $0x1,%edx
  800930:	83 c1 01             	add    $0x1,%ecx
  800933:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800936:	39 c2                	cmp    %eax,%edx
  800938:	74 09                	je     800943 <strlcpy+0x32>
  80093a:	0f b6 19             	movzbl (%ecx),%ebx
  80093d:	84 db                	test   %bl,%bl
  80093f:	75 ec                	jne    80092d <strlcpy+0x1c>
  800941:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800943:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800946:	29 f0                	sub    %esi,%eax
}
  800948:	5b                   	pop    %ebx
  800949:	5e                   	pop    %esi
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800952:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800955:	eb 06                	jmp    80095d <strcmp+0x11>
		p++, q++;
  800957:	83 c1 01             	add    $0x1,%ecx
  80095a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80095d:	0f b6 01             	movzbl (%ecx),%eax
  800960:	84 c0                	test   %al,%al
  800962:	74 04                	je     800968 <strcmp+0x1c>
  800964:	3a 02                	cmp    (%edx),%al
  800966:	74 ef                	je     800957 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800968:	0f b6 c0             	movzbl %al,%eax
  80096b:	0f b6 12             	movzbl (%edx),%edx
  80096e:	29 d0                	sub    %edx,%eax
}
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	53                   	push   %ebx
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097c:	89 c3                	mov    %eax,%ebx
  80097e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800981:	eb 06                	jmp    800989 <strncmp+0x17>
		n--, p++, q++;
  800983:	83 c0 01             	add    $0x1,%eax
  800986:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800989:	39 d8                	cmp    %ebx,%eax
  80098b:	74 15                	je     8009a2 <strncmp+0x30>
  80098d:	0f b6 08             	movzbl (%eax),%ecx
  800990:	84 c9                	test   %cl,%cl
  800992:	74 04                	je     800998 <strncmp+0x26>
  800994:	3a 0a                	cmp    (%edx),%cl
  800996:	74 eb                	je     800983 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800998:	0f b6 00             	movzbl (%eax),%eax
  80099b:	0f b6 12             	movzbl (%edx),%edx
  80099e:	29 d0                	sub    %edx,%eax
  8009a0:	eb 05                	jmp    8009a7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009a2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009a7:	5b                   	pop    %ebx
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b4:	eb 07                	jmp    8009bd <strchr+0x13>
		if (*s == c)
  8009b6:	38 ca                	cmp    %cl,%dl
  8009b8:	74 0f                	je     8009c9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	0f b6 10             	movzbl (%eax),%edx
  8009c0:	84 d2                	test   %dl,%dl
  8009c2:	75 f2                	jne    8009b6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d5:	eb 03                	jmp    8009da <strfind+0xf>
  8009d7:	83 c0 01             	add    $0x1,%eax
  8009da:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009dd:	38 ca                	cmp    %cl,%dl
  8009df:	74 04                	je     8009e5 <strfind+0x1a>
  8009e1:	84 d2                	test   %dl,%dl
  8009e3:	75 f2                	jne    8009d7 <strfind+0xc>
			break;
	return (char *) s;
}
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	57                   	push   %edi
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f3:	85 c9                	test   %ecx,%ecx
  8009f5:	74 36                	je     800a2d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fd:	75 28                	jne    800a27 <memset+0x40>
  8009ff:	f6 c1 03             	test   $0x3,%cl
  800a02:	75 23                	jne    800a27 <memset+0x40>
		c &= 0xFF;
  800a04:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a08:	89 d3                	mov    %edx,%ebx
  800a0a:	c1 e3 08             	shl    $0x8,%ebx
  800a0d:	89 d6                	mov    %edx,%esi
  800a0f:	c1 e6 18             	shl    $0x18,%esi
  800a12:	89 d0                	mov    %edx,%eax
  800a14:	c1 e0 10             	shl    $0x10,%eax
  800a17:	09 f0                	or     %esi,%eax
  800a19:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a1b:	89 d8                	mov    %ebx,%eax
  800a1d:	09 d0                	or     %edx,%eax
  800a1f:	c1 e9 02             	shr    $0x2,%ecx
  800a22:	fc                   	cld    
  800a23:	f3 ab                	rep stos %eax,%es:(%edi)
  800a25:	eb 06                	jmp    800a2d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2a:	fc                   	cld    
  800a2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a2d:	89 f8                	mov    %edi,%eax
  800a2f:	5b                   	pop    %ebx
  800a30:	5e                   	pop    %esi
  800a31:	5f                   	pop    %edi
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a42:	39 c6                	cmp    %eax,%esi
  800a44:	73 35                	jae    800a7b <memmove+0x47>
  800a46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a49:	39 d0                	cmp    %edx,%eax
  800a4b:	73 2e                	jae    800a7b <memmove+0x47>
		s += n;
		d += n;
  800a4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a50:	89 d6                	mov    %edx,%esi
  800a52:	09 fe                	or     %edi,%esi
  800a54:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a5a:	75 13                	jne    800a6f <memmove+0x3b>
  800a5c:	f6 c1 03             	test   $0x3,%cl
  800a5f:	75 0e                	jne    800a6f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a61:	83 ef 04             	sub    $0x4,%edi
  800a64:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a67:	c1 e9 02             	shr    $0x2,%ecx
  800a6a:	fd                   	std    
  800a6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6d:	eb 09                	jmp    800a78 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a6f:	83 ef 01             	sub    $0x1,%edi
  800a72:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a75:	fd                   	std    
  800a76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a78:	fc                   	cld    
  800a79:	eb 1d                	jmp    800a98 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7b:	89 f2                	mov    %esi,%edx
  800a7d:	09 c2                	or     %eax,%edx
  800a7f:	f6 c2 03             	test   $0x3,%dl
  800a82:	75 0f                	jne    800a93 <memmove+0x5f>
  800a84:	f6 c1 03             	test   $0x3,%cl
  800a87:	75 0a                	jne    800a93 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a89:	c1 e9 02             	shr    $0x2,%ecx
  800a8c:	89 c7                	mov    %eax,%edi
  800a8e:	fc                   	cld    
  800a8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a91:	eb 05                	jmp    800a98 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a93:	89 c7                	mov    %eax,%edi
  800a95:	fc                   	cld    
  800a96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a98:	5e                   	pop    %esi
  800a99:	5f                   	pop    %edi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a9f:	ff 75 10             	pushl  0x10(%ebp)
  800aa2:	ff 75 0c             	pushl  0xc(%ebp)
  800aa5:	ff 75 08             	pushl  0x8(%ebp)
  800aa8:	e8 87 ff ff ff       	call   800a34 <memmove>
}
  800aad:	c9                   	leave  
  800aae:	c3                   	ret    

00800aaf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	56                   	push   %esi
  800ab3:	53                   	push   %ebx
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aba:	89 c6                	mov    %eax,%esi
  800abc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800abf:	eb 1a                	jmp    800adb <memcmp+0x2c>
		if (*s1 != *s2)
  800ac1:	0f b6 08             	movzbl (%eax),%ecx
  800ac4:	0f b6 1a             	movzbl (%edx),%ebx
  800ac7:	38 d9                	cmp    %bl,%cl
  800ac9:	74 0a                	je     800ad5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800acb:	0f b6 c1             	movzbl %cl,%eax
  800ace:	0f b6 db             	movzbl %bl,%ebx
  800ad1:	29 d8                	sub    %ebx,%eax
  800ad3:	eb 0f                	jmp    800ae4 <memcmp+0x35>
		s1++, s2++;
  800ad5:	83 c0 01             	add    $0x1,%eax
  800ad8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800adb:	39 f0                	cmp    %esi,%eax
  800add:	75 e2                	jne    800ac1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800adf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae4:	5b                   	pop    %ebx
  800ae5:	5e                   	pop    %esi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	53                   	push   %ebx
  800aec:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aef:	89 c1                	mov    %eax,%ecx
  800af1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800af4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af8:	eb 0a                	jmp    800b04 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800afa:	0f b6 10             	movzbl (%eax),%edx
  800afd:	39 da                	cmp    %ebx,%edx
  800aff:	74 07                	je     800b08 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b01:	83 c0 01             	add    $0x1,%eax
  800b04:	39 c8                	cmp    %ecx,%eax
  800b06:	72 f2                	jb     800afa <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b08:	5b                   	pop    %ebx
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	57                   	push   %edi
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b17:	eb 03                	jmp    800b1c <strtol+0x11>
		s++;
  800b19:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1c:	0f b6 01             	movzbl (%ecx),%eax
  800b1f:	3c 20                	cmp    $0x20,%al
  800b21:	74 f6                	je     800b19 <strtol+0xe>
  800b23:	3c 09                	cmp    $0x9,%al
  800b25:	74 f2                	je     800b19 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b27:	3c 2b                	cmp    $0x2b,%al
  800b29:	75 0a                	jne    800b35 <strtol+0x2a>
		s++;
  800b2b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b2e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b33:	eb 11                	jmp    800b46 <strtol+0x3b>
  800b35:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b3a:	3c 2d                	cmp    $0x2d,%al
  800b3c:	75 08                	jne    800b46 <strtol+0x3b>
		s++, neg = 1;
  800b3e:	83 c1 01             	add    $0x1,%ecx
  800b41:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b46:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b4c:	75 15                	jne    800b63 <strtol+0x58>
  800b4e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b51:	75 10                	jne    800b63 <strtol+0x58>
  800b53:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b57:	75 7c                	jne    800bd5 <strtol+0xca>
		s += 2, base = 16;
  800b59:	83 c1 02             	add    $0x2,%ecx
  800b5c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b61:	eb 16                	jmp    800b79 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b63:	85 db                	test   %ebx,%ebx
  800b65:	75 12                	jne    800b79 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b67:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b6c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b6f:	75 08                	jne    800b79 <strtol+0x6e>
		s++, base = 8;
  800b71:	83 c1 01             	add    $0x1,%ecx
  800b74:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b79:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b81:	0f b6 11             	movzbl (%ecx),%edx
  800b84:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b87:	89 f3                	mov    %esi,%ebx
  800b89:	80 fb 09             	cmp    $0x9,%bl
  800b8c:	77 08                	ja     800b96 <strtol+0x8b>
			dig = *s - '0';
  800b8e:	0f be d2             	movsbl %dl,%edx
  800b91:	83 ea 30             	sub    $0x30,%edx
  800b94:	eb 22                	jmp    800bb8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b96:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b99:	89 f3                	mov    %esi,%ebx
  800b9b:	80 fb 19             	cmp    $0x19,%bl
  800b9e:	77 08                	ja     800ba8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ba0:	0f be d2             	movsbl %dl,%edx
  800ba3:	83 ea 57             	sub    $0x57,%edx
  800ba6:	eb 10                	jmp    800bb8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ba8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bab:	89 f3                	mov    %esi,%ebx
  800bad:	80 fb 19             	cmp    $0x19,%bl
  800bb0:	77 16                	ja     800bc8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bb2:	0f be d2             	movsbl %dl,%edx
  800bb5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bb8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bbb:	7d 0b                	jge    800bc8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bbd:	83 c1 01             	add    $0x1,%ecx
  800bc0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bc4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bc6:	eb b9                	jmp    800b81 <strtol+0x76>

	if (endptr)
  800bc8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bcc:	74 0d                	je     800bdb <strtol+0xd0>
		*endptr = (char *) s;
  800bce:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd1:	89 0e                	mov    %ecx,(%esi)
  800bd3:	eb 06                	jmp    800bdb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd5:	85 db                	test   %ebx,%ebx
  800bd7:	74 98                	je     800b71 <strtol+0x66>
  800bd9:	eb 9e                	jmp    800b79 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bdb:	89 c2                	mov    %eax,%edx
  800bdd:	f7 da                	neg    %edx
  800bdf:	85 ff                	test   %edi,%edi
  800be1:	0f 45 c2             	cmovne %edx,%eax
}
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bef:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfa:	89 c3                	mov    %eax,%ebx
  800bfc:	89 c7                	mov    %eax,%edi
  800bfe:	89 c6                	mov    %eax,%esi
  800c00:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c12:	b8 01 00 00 00       	mov    $0x1,%eax
  800c17:	89 d1                	mov    %edx,%ecx
  800c19:	89 d3                	mov    %edx,%ebx
  800c1b:	89 d7                	mov    %edx,%edi
  800c1d:	89 d6                	mov    %edx,%esi
  800c1f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c34:	b8 03 00 00 00       	mov    $0x3,%eax
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	89 cb                	mov    %ecx,%ebx
  800c3e:	89 cf                	mov    %ecx,%edi
  800c40:	89 ce                	mov    %ecx,%esi
  800c42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c44:	85 c0                	test   %eax,%eax
  800c46:	7e 17                	jle    800c5f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c48:	83 ec 0c             	sub    $0xc,%esp
  800c4b:	50                   	push   %eax
  800c4c:	6a 03                	push   $0x3
  800c4e:	68 ff 2b 80 00       	push   $0x802bff
  800c53:	6a 23                	push   $0x23
  800c55:	68 1c 2c 80 00       	push   $0x802c1c
  800c5a:	e8 e5 f5 ff ff       	call   800244 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c72:	b8 02 00 00 00       	mov    $0x2,%eax
  800c77:	89 d1                	mov    %edx,%ecx
  800c79:	89 d3                	mov    %edx,%ebx
  800c7b:	89 d7                	mov    %edx,%edi
  800c7d:	89 d6                	mov    %edx,%esi
  800c7f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_yield>:

void
sys_yield(void)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c91:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c96:	89 d1                	mov    %edx,%ecx
  800c98:	89 d3                	mov    %edx,%ebx
  800c9a:	89 d7                	mov    %edx,%edi
  800c9c:	89 d6                	mov    %edx,%esi
  800c9e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cae:	be 00 00 00 00       	mov    $0x0,%esi
  800cb3:	b8 04 00 00 00       	mov    $0x4,%eax
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc1:	89 f7                	mov    %esi,%edi
  800cc3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	7e 17                	jle    800ce0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc9:	83 ec 0c             	sub    $0xc,%esp
  800ccc:	50                   	push   %eax
  800ccd:	6a 04                	push   $0x4
  800ccf:	68 ff 2b 80 00       	push   $0x802bff
  800cd4:	6a 23                	push   $0x23
  800cd6:	68 1c 2c 80 00       	push   $0x802c1c
  800cdb:	e8 64 f5 ff ff       	call   800244 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ce0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5f                   	pop    %edi
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	57                   	push   %edi
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
  800cee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf1:	b8 05 00 00 00       	mov    $0x5,%eax
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cff:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d02:	8b 75 18             	mov    0x18(%ebp),%esi
  800d05:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d07:	85 c0                	test   %eax,%eax
  800d09:	7e 17                	jle    800d22 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	50                   	push   %eax
  800d0f:	6a 05                	push   $0x5
  800d11:	68 ff 2b 80 00       	push   $0x802bff
  800d16:	6a 23                	push   $0x23
  800d18:	68 1c 2c 80 00       	push   $0x802c1c
  800d1d:	e8 22 f5 ff ff       	call   800244 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d38:	b8 06 00 00 00       	mov    $0x6,%eax
  800d3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	89 df                	mov    %ebx,%edi
  800d45:	89 de                	mov    %ebx,%esi
  800d47:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	7e 17                	jle    800d64 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4d:	83 ec 0c             	sub    $0xc,%esp
  800d50:	50                   	push   %eax
  800d51:	6a 06                	push   $0x6
  800d53:	68 ff 2b 80 00       	push   $0x802bff
  800d58:	6a 23                	push   $0x23
  800d5a:	68 1c 2c 80 00       	push   $0x802c1c
  800d5f:	e8 e0 f4 ff ff       	call   800244 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5f                   	pop    %edi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7a:	b8 08 00 00 00       	mov    $0x8,%eax
  800d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d82:	8b 55 08             	mov    0x8(%ebp),%edx
  800d85:	89 df                	mov    %ebx,%edi
  800d87:	89 de                	mov    %ebx,%esi
  800d89:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	7e 17                	jle    800da6 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8f:	83 ec 0c             	sub    $0xc,%esp
  800d92:	50                   	push   %eax
  800d93:	6a 08                	push   $0x8
  800d95:	68 ff 2b 80 00       	push   $0x802bff
  800d9a:	6a 23                	push   $0x23
  800d9c:	68 1c 2c 80 00       	push   $0x802c1c
  800da1:	e8 9e f4 ff ff       	call   800244 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800da6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
  800db4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbc:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc7:	89 df                	mov    %ebx,%edi
  800dc9:	89 de                	mov    %ebx,%esi
  800dcb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	7e 17                	jle    800de8 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd1:	83 ec 0c             	sub    $0xc,%esp
  800dd4:	50                   	push   %eax
  800dd5:	6a 09                	push   $0x9
  800dd7:	68 ff 2b 80 00       	push   $0x802bff
  800ddc:	6a 23                	push   $0x23
  800dde:	68 1c 2c 80 00       	push   $0x802c1c
  800de3:	e8 5c f4 ff ff       	call   800244 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800de8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	57                   	push   %edi
  800df4:	56                   	push   %esi
  800df5:	53                   	push   %ebx
  800df6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e06:	8b 55 08             	mov    0x8(%ebp),%edx
  800e09:	89 df                	mov    %ebx,%edi
  800e0b:	89 de                	mov    %ebx,%esi
  800e0d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	7e 17                	jle    800e2a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e13:	83 ec 0c             	sub    $0xc,%esp
  800e16:	50                   	push   %eax
  800e17:	6a 0a                	push   $0xa
  800e19:	68 ff 2b 80 00       	push   $0x802bff
  800e1e:	6a 23                	push   $0x23
  800e20:	68 1c 2c 80 00       	push   $0x802c1c
  800e25:	e8 1a f4 ff ff       	call   800244 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    

00800e32 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	57                   	push   %edi
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e38:	be 00 00 00 00       	mov    $0x0,%esi
  800e3d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e45:	8b 55 08             	mov    0x8(%ebp),%edx
  800e48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e4b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e4e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	57                   	push   %edi
  800e59:	56                   	push   %esi
  800e5a:	53                   	push   %ebx
  800e5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e63:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e68:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6b:	89 cb                	mov    %ecx,%ebx
  800e6d:	89 cf                	mov    %ecx,%edi
  800e6f:	89 ce                	mov    %ecx,%esi
  800e71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e73:	85 c0                	test   %eax,%eax
  800e75:	7e 17                	jle    800e8e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e77:	83 ec 0c             	sub    $0xc,%esp
  800e7a:	50                   	push   %eax
  800e7b:	6a 0d                	push   $0xd
  800e7d:	68 ff 2b 80 00       	push   $0x802bff
  800e82:	6a 23                	push   $0x23
  800e84:	68 1c 2c 80 00       	push   $0x802c1c
  800e89:	e8 b6 f3 ff ff       	call   800244 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5f                   	pop    %edi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	57                   	push   %edi
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea1:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ea6:	89 d1                	mov    %edx,%ecx
  800ea8:	89 d3                	mov    %edx,%ebx
  800eaa:	89 d7                	mov    %edx,%edi
  800eac:	89 d6                	mov    %edx,%esi
  800eae:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800eb0:	5b                   	pop    %ebx
  800eb1:	5e                   	pop    %esi
  800eb2:	5f                   	pop    %edi
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    

00800eb5 <sys_transmit_packet>:

int
sys_transmit_packet(void *buf, size_t size)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	57                   	push   %edi
  800eb9:	56                   	push   %esi
  800eba:	53                   	push   %ebx
  800ebb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec3:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ec8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ece:	89 df                	mov    %ebx,%edi
  800ed0:	89 de                	mov    %ebx,%esi
  800ed2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed4:	85 c0                	test   %eax,%eax
  800ed6:	7e 17                	jle    800eef <sys_transmit_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed8:	83 ec 0c             	sub    $0xc,%esp
  800edb:	50                   	push   %eax
  800edc:	6a 0f                	push   $0xf
  800ede:	68 ff 2b 80 00       	push   $0x802bff
  800ee3:	6a 23                	push   $0x23
  800ee5:	68 1c 2c 80 00       	push   $0x802c1c
  800eea:	e8 55 f3 ff ff       	call   800244 <_panic>
int
sys_transmit_packet(void *buf, size_t size)
{
	return syscall(SYS_transmit_packet, 1,
		(uint32_t) buf, (uint32_t) size, 0, 0, 0);
}
  800eef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef2:	5b                   	pop    %ebx
  800ef3:	5e                   	pop    %esi
  800ef4:	5f                   	pop    %edi
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <sys_receive_packet>:

int
sys_receive_packet(void *buf, size_t *size_store)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	57                   	push   %edi
  800efb:	56                   	push   %esi
  800efc:	53                   	push   %ebx
  800efd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f05:	b8 10 00 00 00       	mov    $0x10,%eax
  800f0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f10:	89 df                	mov    %ebx,%edi
  800f12:	89 de                	mov    %ebx,%esi
  800f14:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f16:	85 c0                	test   %eax,%eax
  800f18:	7e 17                	jle    800f31 <sys_receive_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1a:	83 ec 0c             	sub    $0xc,%esp
  800f1d:	50                   	push   %eax
  800f1e:	6a 10                	push   $0x10
  800f20:	68 ff 2b 80 00       	push   $0x802bff
  800f25:	6a 23                	push   $0x23
  800f27:	68 1c 2c 80 00       	push   $0x802c1c
  800f2c:	e8 13 f3 ff ff       	call   800244 <_panic>
int
sys_receive_packet(void *buf, size_t *size_store)
{
	return syscall(SYS_receive_packet, 1,
		(uint32_t) buf, (uint32_t) size_store, 0, 0, 0);
}
  800f31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f34:	5b                   	pop    %ebx
  800f35:	5e                   	pop    %esi
  800f36:	5f                   	pop    %edi
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    

00800f39 <sys_get_mac_address>:

int
sys_get_mac_address(void *buf)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	57                   	push   %edi
  800f3d:	56                   	push   %esi
  800f3e:	53                   	push   %ebx
  800f3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f47:	b8 11 00 00 00       	mov    $0x11,%eax
  800f4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4f:	89 cb                	mov    %ecx,%ebx
  800f51:	89 cf                	mov    %ecx,%edi
  800f53:	89 ce                	mov    %ecx,%esi
  800f55:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f57:	85 c0                	test   %eax,%eax
  800f59:	7e 17                	jle    800f72 <sys_get_mac_address+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5b:	83 ec 0c             	sub    $0xc,%esp
  800f5e:	50                   	push   %eax
  800f5f:	6a 11                	push   $0x11
  800f61:	68 ff 2b 80 00       	push   $0x802bff
  800f66:	6a 23                	push   $0x23
  800f68:	68 1c 2c 80 00       	push   $0x802c1c
  800f6d:	e8 d2 f2 ff ff       	call   800244 <_panic>
int
sys_get_mac_address(void *buf)
{
	return syscall(SYS_get_mac_address, 1,
		(uint32_t) buf, 0, 0, 0, 0);
}
  800f72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f75:	5b                   	pop    %ebx
  800f76:	5e                   	pop    %esi
  800f77:	5f                   	pop    %edi
  800f78:	5d                   	pop    %ebp
  800f79:	c3                   	ret    

00800f7a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	53                   	push   %ebx
  800f7e:	83 ec 04             	sub    $0x4,%esp
  800f81:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f84:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800f86:	89 da                	mov    %ebx,%edx
  800f88:	c1 ea 0c             	shr    $0xc,%edx
	pte_t pte = uvpt[pn];
  800f8b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  800f92:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f96:	74 05                	je     800f9d <pgfault+0x23>
  800f98:	f6 c6 08             	test   $0x8,%dh
  800f9b:	75 14                	jne    800fb1 <pgfault+0x37>
		panic("fork pgfault handler: does not handle this fault");
  800f9d:	83 ec 04             	sub    $0x4,%esp
  800fa0:	68 2c 2c 80 00       	push   $0x802c2c
  800fa5:	6a 1f                	push   $0x1f
  800fa7:	68 5d 2c 80 00       	push   $0x802c5d
  800fac:	e8 93 f2 ff ff       	call   800244 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800fb1:	83 ec 04             	sub    $0x4,%esp
  800fb4:	6a 07                	push   $0x7
  800fb6:	68 00 f0 7f 00       	push   $0x7ff000
  800fbb:	6a 00                	push   $0x0
  800fbd:	e8 e3 fc ff ff       	call   800ca5 <sys_page_alloc>
  800fc2:	83 c4 10             	add    $0x10,%esp
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	79 12                	jns    800fdb <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  800fc9:	50                   	push   %eax
  800fca:	68 68 2c 80 00       	push   $0x802c68
  800fcf:	6a 2b                	push   $0x2b
  800fd1:	68 5d 2c 80 00       	push   $0x802c5d
  800fd6:	e8 69 f2 ff ff       	call   800244 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  800fdb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  800fe1:	83 ec 04             	sub    $0x4,%esp
  800fe4:	68 00 10 00 00       	push   $0x1000
  800fe9:	53                   	push   %ebx
  800fea:	68 00 f0 7f 00       	push   $0x7ff000
  800fef:	e8 40 fa ff ff       	call   800a34 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  800ff4:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ffb:	53                   	push   %ebx
  800ffc:	6a 00                	push   $0x0
  800ffe:	68 00 f0 7f 00       	push   $0x7ff000
  801003:	6a 00                	push   $0x0
  801005:	e8 de fc ff ff       	call   800ce8 <sys_page_map>
  80100a:	83 c4 20             	add    $0x20,%esp
  80100d:	85 c0                	test   %eax,%eax
  80100f:	79 12                	jns    801023 <pgfault+0xa9>
		panic("sys_page_map: %e", r);
  801011:	50                   	push   %eax
  801012:	68 7b 2c 80 00       	push   $0x802c7b
  801017:	6a 33                	push   $0x33
  801019:	68 5d 2c 80 00       	push   $0x802c5d
  80101e:	e8 21 f2 ff ff       	call   800244 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801023:	83 ec 08             	sub    $0x8,%esp
  801026:	68 00 f0 7f 00       	push   $0x7ff000
  80102b:	6a 00                	push   $0x0
  80102d:	e8 f8 fc ff ff       	call   800d2a <sys_page_unmap>
  801032:	83 c4 10             	add    $0x10,%esp
  801035:	85 c0                	test   %eax,%eax
  801037:	79 12                	jns    80104b <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  801039:	50                   	push   %eax
  80103a:	68 8c 2c 80 00       	push   $0x802c8c
  80103f:	6a 37                	push   $0x37
  801041:	68 5d 2c 80 00       	push   $0x802c5d
  801046:	e8 f9 f1 ff ff       	call   800244 <_panic>
}
  80104b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80104e:	c9                   	leave  
  80104f:	c3                   	ret    

00801050 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	57                   	push   %edi
  801054:	56                   	push   %esi
  801055:	53                   	push   %ebx
  801056:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  801059:	68 7a 0f 80 00       	push   $0x800f7a
  80105e:	e8 77 14 00 00       	call   8024da <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801063:	b8 07 00 00 00       	mov    $0x7,%eax
  801068:	cd 30                	int    $0x30
  80106a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80106d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Create child
	envid_t envid = sys_exofork();
	if (envid < 0) {
  801070:	83 c4 10             	add    $0x10,%esp
  801073:	85 c0                	test   %eax,%eax
  801075:	79 15                	jns    80108c <fork+0x3c>
		panic("sys_exofork: %e", envid);
  801077:	50                   	push   %eax
  801078:	68 9f 2c 80 00       	push   $0x802c9f
  80107d:	68 93 00 00 00       	push   $0x93
  801082:	68 5d 2c 80 00       	push   $0x802c5d
  801087:	e8 b8 f1 ff ff       	call   800244 <_panic>
		return envid;
	}

	// If we are the child, fix thisenv.
	if (envid == 0) {
  80108c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801090:	75 21                	jne    8010b3 <fork+0x63>
		thisenv = &envs[ENVX(sys_getenvid())];
  801092:	e8 d0 fb ff ff       	call   800c67 <sys_getenvid>
  801097:	25 ff 03 00 00       	and    $0x3ff,%eax
  80109c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80109f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010a4:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  8010a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ae:	e9 5a 01 00 00       	jmp    80120d <fork+0x1bd>
	// We are the parent!
	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle the
	// fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), PTE_P | PTE_U | PTE_W);
  8010b3:	83 ec 04             	sub    $0x4,%esp
  8010b6:	6a 07                	push   $0x7
  8010b8:	68 00 f0 bf ee       	push   $0xeebff000
  8010bd:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8010c0:	57                   	push   %edi
  8010c1:	e8 df fb ff ff       	call   800ca5 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  8010c6:	83 c4 08             	add    $0x8,%esp
  8010c9:	68 1f 25 80 00       	push   $0x80251f
  8010ce:	57                   	push   %edi
  8010cf:	e8 1c fd ff ff       	call   800df0 <sys_env_set_pgfault_upcall>
  8010d4:	83 c4 10             	add    $0x10,%esp

	// Copy our address space to child. Be careful not to copy the exception
	// stack too, so go until USTACKTOP instead of UTOP.
	unsigned pn;
	for (pn = UTEXT/PGSIZE; pn < USTACKTOP/PGSIZE; pn++) {
  8010d7:	bb 00 08 00 00       	mov    $0x800,%ebx
static int
duppage(envid_t envid, unsigned pn)
{
	// Check if the page table that contains the PTE we want is allocated
	// using UVPD. If it is not, just don't map anything, and silently succeed.
	if (!(uvpd[pn/NPTENTRIES] & PTE_P))
  8010dc:	89 d8                	mov    %ebx,%eax
  8010de:	c1 e8 0a             	shr    $0xa,%eax
  8010e1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010e8:	a8 01                	test   $0x1,%al
  8010ea:	0f 84 e2 00 00 00    	je     8011d2 <fork+0x182>
		return 0;

	// Retrieve the PTE using UVPT
	pte_t pte = uvpt[pn];
  8010f0:	8b 34 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%esi

	// If the page is present, duplicate according to it's permissions
	if (pte & PTE_P) {
  8010f7:	f7 c6 01 00 00 00    	test   $0x1,%esi
  8010fd:	0f 84 cf 00 00 00    	je     8011d2 <fork+0x182>
		int r;
		uint32_t perm = pte & PTE_SYSCALL;
  801103:	89 f0                	mov    %esi,%eax
  801105:	25 07 0e 00 00       	and    $0xe07,%eax
  80110a:	89 df                	mov    %ebx,%edi
  80110c:	c1 e7 0c             	shl    $0xc,%edi
		void *va = (void *) (pn * PGSIZE);

		// If PTE_SHARE is enabled, share it by just copying the
		// pte, which can be done by mapping on the same address
		// with the same permissions, even if it is writable
		if (pte & PTE_SHARE) {
  80110f:	f7 c6 00 04 00 00    	test   $0x400,%esi
  801115:	74 2d                	je     801144 <fork+0xf4>
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  801117:	83 ec 0c             	sub    $0xc,%esp
  80111a:	50                   	push   %eax
  80111b:	57                   	push   %edi
  80111c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80111f:	57                   	push   %edi
  801120:	6a 00                	push   $0x0
  801122:	e8 c1 fb ff ff       	call   800ce8 <sys_page_map>
  801127:	83 c4 20             	add    $0x20,%esp
  80112a:	85 c0                	test   %eax,%eax
  80112c:	0f 89 a0 00 00 00    	jns    8011d2 <fork+0x182>
				panic("sys_page_map: %e", r);
  801132:	50                   	push   %eax
  801133:	68 7b 2c 80 00       	push   $0x802c7b
  801138:	6a 5c                	push   $0x5c
  80113a:	68 5d 2c 80 00       	push   $0x802c5d
  80113f:	e8 00 f1 ff ff       	call   800244 <_panic>
				return r;
			}
		// If writable or COW, make it COW on parent and child
		} else if (pte & (PTE_W | PTE_COW)) {
  801144:	f7 c6 02 08 00 00    	test   $0x802,%esi
  80114a:	74 5d                	je     8011a9 <fork+0x159>
			perm &= ~PTE_W;  // Remove PTE_W, so it faults
  80114c:	81 e6 05 0e 00 00    	and    $0xe05,%esi
			perm |= PTE_COW; // Make it PTE_COW
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  801152:	81 ce 00 08 00 00    	or     $0x800,%esi
  801158:	83 ec 0c             	sub    $0xc,%esp
  80115b:	56                   	push   %esi
  80115c:	57                   	push   %edi
  80115d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801160:	57                   	push   %edi
  801161:	6a 00                	push   $0x0
  801163:	e8 80 fb ff ff       	call   800ce8 <sys_page_map>
  801168:	83 c4 20             	add    $0x20,%esp
  80116b:	85 c0                	test   %eax,%eax
  80116d:	79 12                	jns    801181 <fork+0x131>
				panic("sys_page_map: %e", r);
  80116f:	50                   	push   %eax
  801170:	68 7b 2c 80 00       	push   $0x802c7b
  801175:	6a 65                	push   $0x65
  801177:	68 5d 2c 80 00       	push   $0x802c5d
  80117c:	e8 c3 f0 ff ff       	call   800244 <_panic>
				return r;
			}
			// Change the permission on parent, mapping on itself
			if ((r = sys_page_map(0, va, 0, va, perm)) < 0) {
  801181:	83 ec 0c             	sub    $0xc,%esp
  801184:	56                   	push   %esi
  801185:	57                   	push   %edi
  801186:	6a 00                	push   $0x0
  801188:	57                   	push   %edi
  801189:	6a 00                	push   $0x0
  80118b:	e8 58 fb ff ff       	call   800ce8 <sys_page_map>
  801190:	83 c4 20             	add    $0x20,%esp
  801193:	85 c0                	test   %eax,%eax
  801195:	79 3b                	jns    8011d2 <fork+0x182>
				panic("sys_page_map: %e", r);
  801197:	50                   	push   %eax
  801198:	68 7b 2c 80 00       	push   $0x802c7b
  80119d:	6a 6a                	push   $0x6a
  80119f:	68 5d 2c 80 00       	push   $0x802c5d
  8011a4:	e8 9b f0 ff ff       	call   800244 <_panic>
				return r;
			}
		// If it is read-only, just share it.
		} else {
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  8011a9:	83 ec 0c             	sub    $0xc,%esp
  8011ac:	50                   	push   %eax
  8011ad:	57                   	push   %edi
  8011ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b1:	57                   	push   %edi
  8011b2:	6a 00                	push   $0x0
  8011b4:	e8 2f fb ff ff       	call   800ce8 <sys_page_map>
  8011b9:	83 c4 20             	add    $0x20,%esp
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	79 12                	jns    8011d2 <fork+0x182>
				panic("sys_page_map: %e", r);
  8011c0:	50                   	push   %eax
  8011c1:	68 7b 2c 80 00       	push   $0x802c7b
  8011c6:	6a 71                	push   $0x71
  8011c8:	68 5d 2c 80 00       	push   $0x802c5d
  8011cd:	e8 72 f0 ff ff       	call   800244 <_panic>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);

	// Copy our address space to child. Be careful not to copy the exception
	// stack too, so go until USTACKTOP instead of UTOP.
	unsigned pn;
	for (pn = UTEXT/PGSIZE; pn < USTACKTOP/PGSIZE; pn++) {
  8011d2:	83 c3 01             	add    $0x1,%ebx
  8011d5:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  8011db:	0f 85 fb fe ff ff    	jne    8010dc <fork+0x8c>
		duppage(envid, pn);
	}

	// Make the child runnable
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8011e1:	83 ec 08             	sub    $0x8,%esp
  8011e4:	6a 02                	push   $0x2
  8011e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8011e9:	e8 7e fb ff ff       	call   800d6c <sys_env_set_status>
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	79 15                	jns    80120a <fork+0x1ba>
		panic("sys_env_set_status: %e", r);
  8011f5:	50                   	push   %eax
  8011f6:	68 af 2c 80 00       	push   $0x802caf
  8011fb:	68 af 00 00 00       	push   $0xaf
  801200:	68 5d 2c 80 00       	push   $0x802c5d
  801205:	e8 3a f0 ff ff       	call   800244 <_panic>
		return r;
	}

	return envid;
  80120a:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  80120d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801210:	5b                   	pop    %ebx
  801211:	5e                   	pop    %esi
  801212:	5f                   	pop    %edi
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    

00801215 <sfork>:

// Challenge!
int
sfork(void)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80121b:	68 c6 2c 80 00       	push   $0x802cc6
  801220:	68 ba 00 00 00       	push   $0xba
  801225:	68 5d 2c 80 00       	push   $0x802c5d
  80122a:	e8 15 f0 ff ff       	call   800244 <_panic>

0080122f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	56                   	push   %esi
  801233:	53                   	push   %ebx
  801234:	8b 75 08             	mov    0x8(%ebp),%esi
  801237:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  80123d:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80123f:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801244:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801247:	83 ec 0c             	sub    $0xc,%esp
  80124a:	50                   	push   %eax
  80124b:	e8 05 fc ff ff       	call   800e55 <sys_ipc_recv>

	if (r < 0) {
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	85 c0                	test   %eax,%eax
  801255:	79 16                	jns    80126d <ipc_recv+0x3e>
		if (from_env_store)
  801257:	85 f6                	test   %esi,%esi
  801259:	74 06                	je     801261 <ipc_recv+0x32>
			*from_env_store = 0;
  80125b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801261:	85 db                	test   %ebx,%ebx
  801263:	74 2c                	je     801291 <ipc_recv+0x62>
			*perm_store = 0;
  801265:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80126b:	eb 24                	jmp    801291 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  80126d:	85 f6                	test   %esi,%esi
  80126f:	74 0a                	je     80127b <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801271:	a1 08 40 80 00       	mov    0x804008,%eax
  801276:	8b 40 74             	mov    0x74(%eax),%eax
  801279:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  80127b:	85 db                	test   %ebx,%ebx
  80127d:	74 0a                	je     801289 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  80127f:	a1 08 40 80 00       	mov    0x804008,%eax
  801284:	8b 40 78             	mov    0x78(%eax),%eax
  801287:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801289:	a1 08 40 80 00       	mov    0x804008,%eax
  80128e:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801291:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801294:	5b                   	pop    %ebx
  801295:	5e                   	pop    %esi
  801296:	5d                   	pop    %ebp
  801297:	c3                   	ret    

00801298 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	57                   	push   %edi
  80129c:	56                   	push   %esi
  80129d:	53                   	push   %ebx
  80129e:	83 ec 0c             	sub    $0xc,%esp
  8012a1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012a4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8012aa:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8012ac:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8012b1:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8012b4:	ff 75 14             	pushl  0x14(%ebp)
  8012b7:	53                   	push   %ebx
  8012b8:	56                   	push   %esi
  8012b9:	57                   	push   %edi
  8012ba:	e8 73 fb ff ff       	call   800e32 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  8012bf:	83 c4 10             	add    $0x10,%esp
  8012c2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012c5:	75 07                	jne    8012ce <ipc_send+0x36>
			sys_yield();
  8012c7:	e8 ba f9 ff ff       	call   800c86 <sys_yield>
  8012cc:	eb e6                	jmp    8012b4 <ipc_send+0x1c>
		} else if (r < 0) {
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	79 12                	jns    8012e4 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  8012d2:	50                   	push   %eax
  8012d3:	68 dc 2c 80 00       	push   $0x802cdc
  8012d8:	6a 51                	push   $0x51
  8012da:	68 e9 2c 80 00       	push   $0x802ce9
  8012df:	e8 60 ef ff ff       	call   800244 <_panic>
		}
	}
}
  8012e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e7:	5b                   	pop    %ebx
  8012e8:	5e                   	pop    %esi
  8012e9:	5f                   	pop    %edi
  8012ea:	5d                   	pop    %ebp
  8012eb:	c3                   	ret    

008012ec <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012ec:	55                   	push   %ebp
  8012ed:	89 e5                	mov    %esp,%ebp
  8012ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8012f2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012f7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8012fa:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801300:	8b 52 50             	mov    0x50(%edx),%edx
  801303:	39 ca                	cmp    %ecx,%edx
  801305:	75 0d                	jne    801314 <ipc_find_env+0x28>
			return envs[i].env_id;
  801307:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80130a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80130f:	8b 40 48             	mov    0x48(%eax),%eax
  801312:	eb 0f                	jmp    801323 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801314:	83 c0 01             	add    $0x1,%eax
  801317:	3d 00 04 00 00       	cmp    $0x400,%eax
  80131c:	75 d9                	jne    8012f7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80131e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801323:	5d                   	pop    %ebp
  801324:	c3                   	ret    

00801325 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801328:	8b 45 08             	mov    0x8(%ebp),%eax
  80132b:	05 00 00 00 30       	add    $0x30000000,%eax
  801330:	c1 e8 0c             	shr    $0xc,%eax
}
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    

00801335 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801338:	8b 45 08             	mov    0x8(%ebp),%eax
  80133b:	05 00 00 00 30       	add    $0x30000000,%eax
  801340:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801345:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80134a:	5d                   	pop    %ebp
  80134b:	c3                   	ret    

0080134c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801352:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801357:	89 c2                	mov    %eax,%edx
  801359:	c1 ea 16             	shr    $0x16,%edx
  80135c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801363:	f6 c2 01             	test   $0x1,%dl
  801366:	74 11                	je     801379 <fd_alloc+0x2d>
  801368:	89 c2                	mov    %eax,%edx
  80136a:	c1 ea 0c             	shr    $0xc,%edx
  80136d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801374:	f6 c2 01             	test   $0x1,%dl
  801377:	75 09                	jne    801382 <fd_alloc+0x36>
			*fd_store = fd;
  801379:	89 01                	mov    %eax,(%ecx)
			return 0;
  80137b:	b8 00 00 00 00       	mov    $0x0,%eax
  801380:	eb 17                	jmp    801399 <fd_alloc+0x4d>
  801382:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801387:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80138c:	75 c9                	jne    801357 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80138e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801394:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801399:	5d                   	pop    %ebp
  80139a:	c3                   	ret    

0080139b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013a1:	83 f8 1f             	cmp    $0x1f,%eax
  8013a4:	77 36                	ja     8013dc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013a6:	c1 e0 0c             	shl    $0xc,%eax
  8013a9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013ae:	89 c2                	mov    %eax,%edx
  8013b0:	c1 ea 16             	shr    $0x16,%edx
  8013b3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013ba:	f6 c2 01             	test   $0x1,%dl
  8013bd:	74 24                	je     8013e3 <fd_lookup+0x48>
  8013bf:	89 c2                	mov    %eax,%edx
  8013c1:	c1 ea 0c             	shr    $0xc,%edx
  8013c4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013cb:	f6 c2 01             	test   $0x1,%dl
  8013ce:	74 1a                	je     8013ea <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013d3:	89 02                	mov    %eax,(%edx)
	return 0;
  8013d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013da:	eb 13                	jmp    8013ef <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e1:	eb 0c                	jmp    8013ef <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e8:	eb 05                	jmp    8013ef <fd_lookup+0x54>
  8013ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013ef:	5d                   	pop    %ebp
  8013f0:	c3                   	ret    

008013f1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	83 ec 08             	sub    $0x8,%esp
  8013f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013fa:	ba 74 2d 80 00       	mov    $0x802d74,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013ff:	eb 13                	jmp    801414 <dev_lookup+0x23>
  801401:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801404:	39 08                	cmp    %ecx,(%eax)
  801406:	75 0c                	jne    801414 <dev_lookup+0x23>
			*dev = devtab[i];
  801408:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80140b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80140d:	b8 00 00 00 00       	mov    $0x0,%eax
  801412:	eb 2e                	jmp    801442 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801414:	8b 02                	mov    (%edx),%eax
  801416:	85 c0                	test   %eax,%eax
  801418:	75 e7                	jne    801401 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80141a:	a1 08 40 80 00       	mov    0x804008,%eax
  80141f:	8b 40 48             	mov    0x48(%eax),%eax
  801422:	83 ec 04             	sub    $0x4,%esp
  801425:	51                   	push   %ecx
  801426:	50                   	push   %eax
  801427:	68 f4 2c 80 00       	push   $0x802cf4
  80142c:	e8 ec ee ff ff       	call   80031d <cprintf>
	*dev = 0;
  801431:	8b 45 0c             	mov    0xc(%ebp),%eax
  801434:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80143a:	83 c4 10             	add    $0x10,%esp
  80143d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801442:	c9                   	leave  
  801443:	c3                   	ret    

00801444 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	56                   	push   %esi
  801448:	53                   	push   %ebx
  801449:	83 ec 10             	sub    $0x10,%esp
  80144c:	8b 75 08             	mov    0x8(%ebp),%esi
  80144f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801452:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801455:	50                   	push   %eax
  801456:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80145c:	c1 e8 0c             	shr    $0xc,%eax
  80145f:	50                   	push   %eax
  801460:	e8 36 ff ff ff       	call   80139b <fd_lookup>
  801465:	83 c4 08             	add    $0x8,%esp
  801468:	85 c0                	test   %eax,%eax
  80146a:	78 05                	js     801471 <fd_close+0x2d>
	    || fd != fd2)
  80146c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80146f:	74 0c                	je     80147d <fd_close+0x39>
		return (must_exist ? r : 0);
  801471:	84 db                	test   %bl,%bl
  801473:	ba 00 00 00 00       	mov    $0x0,%edx
  801478:	0f 44 c2             	cmove  %edx,%eax
  80147b:	eb 41                	jmp    8014be <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80147d:	83 ec 08             	sub    $0x8,%esp
  801480:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801483:	50                   	push   %eax
  801484:	ff 36                	pushl  (%esi)
  801486:	e8 66 ff ff ff       	call   8013f1 <dev_lookup>
  80148b:	89 c3                	mov    %eax,%ebx
  80148d:	83 c4 10             	add    $0x10,%esp
  801490:	85 c0                	test   %eax,%eax
  801492:	78 1a                	js     8014ae <fd_close+0x6a>
		if (dev->dev_close)
  801494:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801497:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80149a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	74 0b                	je     8014ae <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014a3:	83 ec 0c             	sub    $0xc,%esp
  8014a6:	56                   	push   %esi
  8014a7:	ff d0                	call   *%eax
  8014a9:	89 c3                	mov    %eax,%ebx
  8014ab:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014ae:	83 ec 08             	sub    $0x8,%esp
  8014b1:	56                   	push   %esi
  8014b2:	6a 00                	push   $0x0
  8014b4:	e8 71 f8 ff ff       	call   800d2a <sys_page_unmap>
	return r;
  8014b9:	83 c4 10             	add    $0x10,%esp
  8014bc:	89 d8                	mov    %ebx,%eax
}
  8014be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014c1:	5b                   	pop    %ebx
  8014c2:	5e                   	pop    %esi
  8014c3:	5d                   	pop    %ebp
  8014c4:	c3                   	ret    

008014c5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014c5:	55                   	push   %ebp
  8014c6:	89 e5                	mov    %esp,%ebp
  8014c8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ce:	50                   	push   %eax
  8014cf:	ff 75 08             	pushl  0x8(%ebp)
  8014d2:	e8 c4 fe ff ff       	call   80139b <fd_lookup>
  8014d7:	83 c4 08             	add    $0x8,%esp
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	78 10                	js     8014ee <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014de:	83 ec 08             	sub    $0x8,%esp
  8014e1:	6a 01                	push   $0x1
  8014e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8014e6:	e8 59 ff ff ff       	call   801444 <fd_close>
  8014eb:	83 c4 10             	add    $0x10,%esp
}
  8014ee:	c9                   	leave  
  8014ef:	c3                   	ret    

008014f0 <close_all>:

void
close_all(void)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	53                   	push   %ebx
  8014f4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014fc:	83 ec 0c             	sub    $0xc,%esp
  8014ff:	53                   	push   %ebx
  801500:	e8 c0 ff ff ff       	call   8014c5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801505:	83 c3 01             	add    $0x1,%ebx
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	83 fb 20             	cmp    $0x20,%ebx
  80150e:	75 ec                	jne    8014fc <close_all+0xc>
		close(i);
}
  801510:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801513:	c9                   	leave  
  801514:	c3                   	ret    

00801515 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	57                   	push   %edi
  801519:	56                   	push   %esi
  80151a:	53                   	push   %ebx
  80151b:	83 ec 2c             	sub    $0x2c,%esp
  80151e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801521:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801524:	50                   	push   %eax
  801525:	ff 75 08             	pushl  0x8(%ebp)
  801528:	e8 6e fe ff ff       	call   80139b <fd_lookup>
  80152d:	83 c4 08             	add    $0x8,%esp
  801530:	85 c0                	test   %eax,%eax
  801532:	0f 88 c1 00 00 00    	js     8015f9 <dup+0xe4>
		return r;
	close(newfdnum);
  801538:	83 ec 0c             	sub    $0xc,%esp
  80153b:	56                   	push   %esi
  80153c:	e8 84 ff ff ff       	call   8014c5 <close>

	newfd = INDEX2FD(newfdnum);
  801541:	89 f3                	mov    %esi,%ebx
  801543:	c1 e3 0c             	shl    $0xc,%ebx
  801546:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80154c:	83 c4 04             	add    $0x4,%esp
  80154f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801552:	e8 de fd ff ff       	call   801335 <fd2data>
  801557:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801559:	89 1c 24             	mov    %ebx,(%esp)
  80155c:	e8 d4 fd ff ff       	call   801335 <fd2data>
  801561:	83 c4 10             	add    $0x10,%esp
  801564:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801567:	89 f8                	mov    %edi,%eax
  801569:	c1 e8 16             	shr    $0x16,%eax
  80156c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801573:	a8 01                	test   $0x1,%al
  801575:	74 37                	je     8015ae <dup+0x99>
  801577:	89 f8                	mov    %edi,%eax
  801579:	c1 e8 0c             	shr    $0xc,%eax
  80157c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801583:	f6 c2 01             	test   $0x1,%dl
  801586:	74 26                	je     8015ae <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801588:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80158f:	83 ec 0c             	sub    $0xc,%esp
  801592:	25 07 0e 00 00       	and    $0xe07,%eax
  801597:	50                   	push   %eax
  801598:	ff 75 d4             	pushl  -0x2c(%ebp)
  80159b:	6a 00                	push   $0x0
  80159d:	57                   	push   %edi
  80159e:	6a 00                	push   $0x0
  8015a0:	e8 43 f7 ff ff       	call   800ce8 <sys_page_map>
  8015a5:	89 c7                	mov    %eax,%edi
  8015a7:	83 c4 20             	add    $0x20,%esp
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	78 2e                	js     8015dc <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015b1:	89 d0                	mov    %edx,%eax
  8015b3:	c1 e8 0c             	shr    $0xc,%eax
  8015b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015bd:	83 ec 0c             	sub    $0xc,%esp
  8015c0:	25 07 0e 00 00       	and    $0xe07,%eax
  8015c5:	50                   	push   %eax
  8015c6:	53                   	push   %ebx
  8015c7:	6a 00                	push   $0x0
  8015c9:	52                   	push   %edx
  8015ca:	6a 00                	push   $0x0
  8015cc:	e8 17 f7 ff ff       	call   800ce8 <sys_page_map>
  8015d1:	89 c7                	mov    %eax,%edi
  8015d3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015d6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015d8:	85 ff                	test   %edi,%edi
  8015da:	79 1d                	jns    8015f9 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015dc:	83 ec 08             	sub    $0x8,%esp
  8015df:	53                   	push   %ebx
  8015e0:	6a 00                	push   $0x0
  8015e2:	e8 43 f7 ff ff       	call   800d2a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015e7:	83 c4 08             	add    $0x8,%esp
  8015ea:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015ed:	6a 00                	push   $0x0
  8015ef:	e8 36 f7 ff ff       	call   800d2a <sys_page_unmap>
	return r;
  8015f4:	83 c4 10             	add    $0x10,%esp
  8015f7:	89 f8                	mov    %edi,%eax
}
  8015f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015fc:	5b                   	pop    %ebx
  8015fd:	5e                   	pop    %esi
  8015fe:	5f                   	pop    %edi
  8015ff:	5d                   	pop    %ebp
  801600:	c3                   	ret    

00801601 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	53                   	push   %ebx
  801605:	83 ec 14             	sub    $0x14,%esp
  801608:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80160b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160e:	50                   	push   %eax
  80160f:	53                   	push   %ebx
  801610:	e8 86 fd ff ff       	call   80139b <fd_lookup>
  801615:	83 c4 08             	add    $0x8,%esp
  801618:	89 c2                	mov    %eax,%edx
  80161a:	85 c0                	test   %eax,%eax
  80161c:	78 6d                	js     80168b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161e:	83 ec 08             	sub    $0x8,%esp
  801621:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801624:	50                   	push   %eax
  801625:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801628:	ff 30                	pushl  (%eax)
  80162a:	e8 c2 fd ff ff       	call   8013f1 <dev_lookup>
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	85 c0                	test   %eax,%eax
  801634:	78 4c                	js     801682 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801636:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801639:	8b 42 08             	mov    0x8(%edx),%eax
  80163c:	83 e0 03             	and    $0x3,%eax
  80163f:	83 f8 01             	cmp    $0x1,%eax
  801642:	75 21                	jne    801665 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801644:	a1 08 40 80 00       	mov    0x804008,%eax
  801649:	8b 40 48             	mov    0x48(%eax),%eax
  80164c:	83 ec 04             	sub    $0x4,%esp
  80164f:	53                   	push   %ebx
  801650:	50                   	push   %eax
  801651:	68 38 2d 80 00       	push   $0x802d38
  801656:	e8 c2 ec ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801663:	eb 26                	jmp    80168b <read+0x8a>
	}
	if (!dev->dev_read)
  801665:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801668:	8b 40 08             	mov    0x8(%eax),%eax
  80166b:	85 c0                	test   %eax,%eax
  80166d:	74 17                	je     801686 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80166f:	83 ec 04             	sub    $0x4,%esp
  801672:	ff 75 10             	pushl  0x10(%ebp)
  801675:	ff 75 0c             	pushl  0xc(%ebp)
  801678:	52                   	push   %edx
  801679:	ff d0                	call   *%eax
  80167b:	89 c2                	mov    %eax,%edx
  80167d:	83 c4 10             	add    $0x10,%esp
  801680:	eb 09                	jmp    80168b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801682:	89 c2                	mov    %eax,%edx
  801684:	eb 05                	jmp    80168b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801686:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80168b:	89 d0                	mov    %edx,%eax
  80168d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801690:	c9                   	leave  
  801691:	c3                   	ret    

00801692 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	57                   	push   %edi
  801696:	56                   	push   %esi
  801697:	53                   	push   %ebx
  801698:	83 ec 0c             	sub    $0xc,%esp
  80169b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80169e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016a6:	eb 21                	jmp    8016c9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016a8:	83 ec 04             	sub    $0x4,%esp
  8016ab:	89 f0                	mov    %esi,%eax
  8016ad:	29 d8                	sub    %ebx,%eax
  8016af:	50                   	push   %eax
  8016b0:	89 d8                	mov    %ebx,%eax
  8016b2:	03 45 0c             	add    0xc(%ebp),%eax
  8016b5:	50                   	push   %eax
  8016b6:	57                   	push   %edi
  8016b7:	e8 45 ff ff ff       	call   801601 <read>
		if (m < 0)
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	78 10                	js     8016d3 <readn+0x41>
			return m;
		if (m == 0)
  8016c3:	85 c0                	test   %eax,%eax
  8016c5:	74 0a                	je     8016d1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016c7:	01 c3                	add    %eax,%ebx
  8016c9:	39 f3                	cmp    %esi,%ebx
  8016cb:	72 db                	jb     8016a8 <readn+0x16>
  8016cd:	89 d8                	mov    %ebx,%eax
  8016cf:	eb 02                	jmp    8016d3 <readn+0x41>
  8016d1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016d6:	5b                   	pop    %ebx
  8016d7:	5e                   	pop    %esi
  8016d8:	5f                   	pop    %edi
  8016d9:	5d                   	pop    %ebp
  8016da:	c3                   	ret    

008016db <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	53                   	push   %ebx
  8016df:	83 ec 14             	sub    $0x14,%esp
  8016e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e8:	50                   	push   %eax
  8016e9:	53                   	push   %ebx
  8016ea:	e8 ac fc ff ff       	call   80139b <fd_lookup>
  8016ef:	83 c4 08             	add    $0x8,%esp
  8016f2:	89 c2                	mov    %eax,%edx
  8016f4:	85 c0                	test   %eax,%eax
  8016f6:	78 68                	js     801760 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f8:	83 ec 08             	sub    $0x8,%esp
  8016fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fe:	50                   	push   %eax
  8016ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801702:	ff 30                	pushl  (%eax)
  801704:	e8 e8 fc ff ff       	call   8013f1 <dev_lookup>
  801709:	83 c4 10             	add    $0x10,%esp
  80170c:	85 c0                	test   %eax,%eax
  80170e:	78 47                	js     801757 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801710:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801713:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801717:	75 21                	jne    80173a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801719:	a1 08 40 80 00       	mov    0x804008,%eax
  80171e:	8b 40 48             	mov    0x48(%eax),%eax
  801721:	83 ec 04             	sub    $0x4,%esp
  801724:	53                   	push   %ebx
  801725:	50                   	push   %eax
  801726:	68 54 2d 80 00       	push   $0x802d54
  80172b:	e8 ed eb ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801738:	eb 26                	jmp    801760 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80173a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80173d:	8b 52 0c             	mov    0xc(%edx),%edx
  801740:	85 d2                	test   %edx,%edx
  801742:	74 17                	je     80175b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801744:	83 ec 04             	sub    $0x4,%esp
  801747:	ff 75 10             	pushl  0x10(%ebp)
  80174a:	ff 75 0c             	pushl  0xc(%ebp)
  80174d:	50                   	push   %eax
  80174e:	ff d2                	call   *%edx
  801750:	89 c2                	mov    %eax,%edx
  801752:	83 c4 10             	add    $0x10,%esp
  801755:	eb 09                	jmp    801760 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801757:	89 c2                	mov    %eax,%edx
  801759:	eb 05                	jmp    801760 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80175b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801760:	89 d0                	mov    %edx,%eax
  801762:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801765:	c9                   	leave  
  801766:	c3                   	ret    

00801767 <seek>:

int
seek(int fdnum, off_t offset)
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80176d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801770:	50                   	push   %eax
  801771:	ff 75 08             	pushl  0x8(%ebp)
  801774:	e8 22 fc ff ff       	call   80139b <fd_lookup>
  801779:	83 c4 08             	add    $0x8,%esp
  80177c:	85 c0                	test   %eax,%eax
  80177e:	78 0e                	js     80178e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801780:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801783:	8b 55 0c             	mov    0xc(%ebp),%edx
  801786:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801789:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80178e:	c9                   	leave  
  80178f:	c3                   	ret    

00801790 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	53                   	push   %ebx
  801794:	83 ec 14             	sub    $0x14,%esp
  801797:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80179a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80179d:	50                   	push   %eax
  80179e:	53                   	push   %ebx
  80179f:	e8 f7 fb ff ff       	call   80139b <fd_lookup>
  8017a4:	83 c4 08             	add    $0x8,%esp
  8017a7:	89 c2                	mov    %eax,%edx
  8017a9:	85 c0                	test   %eax,%eax
  8017ab:	78 65                	js     801812 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ad:	83 ec 08             	sub    $0x8,%esp
  8017b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b3:	50                   	push   %eax
  8017b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b7:	ff 30                	pushl  (%eax)
  8017b9:	e8 33 fc ff ff       	call   8013f1 <dev_lookup>
  8017be:	83 c4 10             	add    $0x10,%esp
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	78 44                	js     801809 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017cc:	75 21                	jne    8017ef <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017ce:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017d3:	8b 40 48             	mov    0x48(%eax),%eax
  8017d6:	83 ec 04             	sub    $0x4,%esp
  8017d9:	53                   	push   %ebx
  8017da:	50                   	push   %eax
  8017db:	68 14 2d 80 00       	push   $0x802d14
  8017e0:	e8 38 eb ff ff       	call   80031d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017ed:	eb 23                	jmp    801812 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017f2:	8b 52 18             	mov    0x18(%edx),%edx
  8017f5:	85 d2                	test   %edx,%edx
  8017f7:	74 14                	je     80180d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017f9:	83 ec 08             	sub    $0x8,%esp
  8017fc:	ff 75 0c             	pushl  0xc(%ebp)
  8017ff:	50                   	push   %eax
  801800:	ff d2                	call   *%edx
  801802:	89 c2                	mov    %eax,%edx
  801804:	83 c4 10             	add    $0x10,%esp
  801807:	eb 09                	jmp    801812 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801809:	89 c2                	mov    %eax,%edx
  80180b:	eb 05                	jmp    801812 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80180d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801812:	89 d0                	mov    %edx,%eax
  801814:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801817:	c9                   	leave  
  801818:	c3                   	ret    

00801819 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801819:	55                   	push   %ebp
  80181a:	89 e5                	mov    %esp,%ebp
  80181c:	53                   	push   %ebx
  80181d:	83 ec 14             	sub    $0x14,%esp
  801820:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801823:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801826:	50                   	push   %eax
  801827:	ff 75 08             	pushl  0x8(%ebp)
  80182a:	e8 6c fb ff ff       	call   80139b <fd_lookup>
  80182f:	83 c4 08             	add    $0x8,%esp
  801832:	89 c2                	mov    %eax,%edx
  801834:	85 c0                	test   %eax,%eax
  801836:	78 58                	js     801890 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801838:	83 ec 08             	sub    $0x8,%esp
  80183b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80183e:	50                   	push   %eax
  80183f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801842:	ff 30                	pushl  (%eax)
  801844:	e8 a8 fb ff ff       	call   8013f1 <dev_lookup>
  801849:	83 c4 10             	add    $0x10,%esp
  80184c:	85 c0                	test   %eax,%eax
  80184e:	78 37                	js     801887 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801850:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801853:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801857:	74 32                	je     80188b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801859:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80185c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801863:	00 00 00 
	stat->st_isdir = 0;
  801866:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80186d:	00 00 00 
	stat->st_dev = dev;
  801870:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801876:	83 ec 08             	sub    $0x8,%esp
  801879:	53                   	push   %ebx
  80187a:	ff 75 f0             	pushl  -0x10(%ebp)
  80187d:	ff 50 14             	call   *0x14(%eax)
  801880:	89 c2                	mov    %eax,%edx
  801882:	83 c4 10             	add    $0x10,%esp
  801885:	eb 09                	jmp    801890 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801887:	89 c2                	mov    %eax,%edx
  801889:	eb 05                	jmp    801890 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80188b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801890:	89 d0                	mov    %edx,%eax
  801892:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801895:	c9                   	leave  
  801896:	c3                   	ret    

00801897 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801897:	55                   	push   %ebp
  801898:	89 e5                	mov    %esp,%ebp
  80189a:	56                   	push   %esi
  80189b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80189c:	83 ec 08             	sub    $0x8,%esp
  80189f:	6a 00                	push   $0x0
  8018a1:	ff 75 08             	pushl  0x8(%ebp)
  8018a4:	e8 0c 02 00 00       	call   801ab5 <open>
  8018a9:	89 c3                	mov    %eax,%ebx
  8018ab:	83 c4 10             	add    $0x10,%esp
  8018ae:	85 c0                	test   %eax,%eax
  8018b0:	78 1b                	js     8018cd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018b2:	83 ec 08             	sub    $0x8,%esp
  8018b5:	ff 75 0c             	pushl  0xc(%ebp)
  8018b8:	50                   	push   %eax
  8018b9:	e8 5b ff ff ff       	call   801819 <fstat>
  8018be:	89 c6                	mov    %eax,%esi
	close(fd);
  8018c0:	89 1c 24             	mov    %ebx,(%esp)
  8018c3:	e8 fd fb ff ff       	call   8014c5 <close>
	return r;
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	89 f0                	mov    %esi,%eax
}
  8018cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d0:	5b                   	pop    %ebx
  8018d1:	5e                   	pop    %esi
  8018d2:	5d                   	pop    %ebp
  8018d3:	c3                   	ret    

008018d4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	56                   	push   %esi
  8018d8:	53                   	push   %ebx
  8018d9:	89 c6                	mov    %eax,%esi
  8018db:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018dd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018e4:	75 12                	jne    8018f8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018e6:	83 ec 0c             	sub    $0xc,%esp
  8018e9:	6a 01                	push   $0x1
  8018eb:	e8 fc f9 ff ff       	call   8012ec <ipc_find_env>
  8018f0:	a3 00 40 80 00       	mov    %eax,0x804000
  8018f5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018f8:	6a 07                	push   $0x7
  8018fa:	68 00 50 80 00       	push   $0x805000
  8018ff:	56                   	push   %esi
  801900:	ff 35 00 40 80 00    	pushl  0x804000
  801906:	e8 8d f9 ff ff       	call   801298 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80190b:	83 c4 0c             	add    $0xc,%esp
  80190e:	6a 00                	push   $0x0
  801910:	53                   	push   %ebx
  801911:	6a 00                	push   $0x0
  801913:	e8 17 f9 ff ff       	call   80122f <ipc_recv>
}
  801918:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191b:	5b                   	pop    %ebx
  80191c:	5e                   	pop    %esi
  80191d:	5d                   	pop    %ebp
  80191e:	c3                   	ret    

0080191f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801925:	8b 45 08             	mov    0x8(%ebp),%eax
  801928:	8b 40 0c             	mov    0xc(%eax),%eax
  80192b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801930:	8b 45 0c             	mov    0xc(%ebp),%eax
  801933:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801938:	ba 00 00 00 00       	mov    $0x0,%edx
  80193d:	b8 02 00 00 00       	mov    $0x2,%eax
  801942:	e8 8d ff ff ff       	call   8018d4 <fsipc>
}
  801947:	c9                   	leave  
  801948:	c3                   	ret    

00801949 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801949:	55                   	push   %ebp
  80194a:	89 e5                	mov    %esp,%ebp
  80194c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80194f:	8b 45 08             	mov    0x8(%ebp),%eax
  801952:	8b 40 0c             	mov    0xc(%eax),%eax
  801955:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80195a:	ba 00 00 00 00       	mov    $0x0,%edx
  80195f:	b8 06 00 00 00       	mov    $0x6,%eax
  801964:	e8 6b ff ff ff       	call   8018d4 <fsipc>
}
  801969:	c9                   	leave  
  80196a:	c3                   	ret    

0080196b <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80196b:	55                   	push   %ebp
  80196c:	89 e5                	mov    %esp,%ebp
  80196e:	53                   	push   %ebx
  80196f:	83 ec 04             	sub    $0x4,%esp
  801972:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801975:	8b 45 08             	mov    0x8(%ebp),%eax
  801978:	8b 40 0c             	mov    0xc(%eax),%eax
  80197b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801980:	ba 00 00 00 00       	mov    $0x0,%edx
  801985:	b8 05 00 00 00       	mov    $0x5,%eax
  80198a:	e8 45 ff ff ff       	call   8018d4 <fsipc>
  80198f:	85 c0                	test   %eax,%eax
  801991:	78 2c                	js     8019bf <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801993:	83 ec 08             	sub    $0x8,%esp
  801996:	68 00 50 80 00       	push   $0x805000
  80199b:	53                   	push   %ebx
  80199c:	e8 01 ef ff ff       	call   8008a2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019a1:	a1 80 50 80 00       	mov    0x805080,%eax
  8019a6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019ac:	a1 84 50 80 00       	mov    0x805084,%eax
  8019b1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019b7:	83 c4 10             	add    $0x10,%esp
  8019ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c2:	c9                   	leave  
  8019c3:	c3                   	ret    

008019c4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	53                   	push   %ebx
  8019c8:	83 ec 08             	sub    $0x8,%esp
  8019cb:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8019d1:	8b 52 0c             	mov    0xc(%edx),%edx
  8019d4:	89 15 00 50 80 00    	mov    %edx,0x805000
  8019da:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019df:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8019e4:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8019e7:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8019ed:	53                   	push   %ebx
  8019ee:	ff 75 0c             	pushl  0xc(%ebp)
  8019f1:	68 08 50 80 00       	push   $0x805008
  8019f6:	e8 39 f0 ff ff       	call   800a34 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  8019fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801a00:	b8 04 00 00 00       	mov    $0x4,%eax
  801a05:	e8 ca fe ff ff       	call   8018d4 <fsipc>
  801a0a:	83 c4 10             	add    $0x10,%esp
  801a0d:	85 c0                	test   %eax,%eax
  801a0f:	78 1d                	js     801a2e <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  801a11:	39 d8                	cmp    %ebx,%eax
  801a13:	76 19                	jbe    801a2e <devfile_write+0x6a>
  801a15:	68 88 2d 80 00       	push   $0x802d88
  801a1a:	68 94 2d 80 00       	push   $0x802d94
  801a1f:	68 a5 00 00 00       	push   $0xa5
  801a24:	68 a9 2d 80 00       	push   $0x802da9
  801a29:	e8 16 e8 ff ff       	call   800244 <_panic>
	return r;
}
  801a2e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a31:	c9                   	leave  
  801a32:	c3                   	ret    

00801a33 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	56                   	push   %esi
  801a37:	53                   	push   %ebx
  801a38:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3e:	8b 40 0c             	mov    0xc(%eax),%eax
  801a41:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a46:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a4c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a51:	b8 03 00 00 00       	mov    $0x3,%eax
  801a56:	e8 79 fe ff ff       	call   8018d4 <fsipc>
  801a5b:	89 c3                	mov    %eax,%ebx
  801a5d:	85 c0                	test   %eax,%eax
  801a5f:	78 4b                	js     801aac <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a61:	39 c6                	cmp    %eax,%esi
  801a63:	73 16                	jae    801a7b <devfile_read+0x48>
  801a65:	68 b4 2d 80 00       	push   $0x802db4
  801a6a:	68 94 2d 80 00       	push   $0x802d94
  801a6f:	6a 7c                	push   $0x7c
  801a71:	68 a9 2d 80 00       	push   $0x802da9
  801a76:	e8 c9 e7 ff ff       	call   800244 <_panic>
	assert(r <= PGSIZE);
  801a7b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a80:	7e 16                	jle    801a98 <devfile_read+0x65>
  801a82:	68 bb 2d 80 00       	push   $0x802dbb
  801a87:	68 94 2d 80 00       	push   $0x802d94
  801a8c:	6a 7d                	push   $0x7d
  801a8e:	68 a9 2d 80 00       	push   $0x802da9
  801a93:	e8 ac e7 ff ff       	call   800244 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a98:	83 ec 04             	sub    $0x4,%esp
  801a9b:	50                   	push   %eax
  801a9c:	68 00 50 80 00       	push   $0x805000
  801aa1:	ff 75 0c             	pushl  0xc(%ebp)
  801aa4:	e8 8b ef ff ff       	call   800a34 <memmove>
	return r;
  801aa9:	83 c4 10             	add    $0x10,%esp
}
  801aac:	89 d8                	mov    %ebx,%eax
  801aae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab1:	5b                   	pop    %ebx
  801ab2:	5e                   	pop    %esi
  801ab3:	5d                   	pop    %ebp
  801ab4:	c3                   	ret    

00801ab5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	53                   	push   %ebx
  801ab9:	83 ec 20             	sub    $0x20,%esp
  801abc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801abf:	53                   	push   %ebx
  801ac0:	e8 a4 ed ff ff       	call   800869 <strlen>
  801ac5:	83 c4 10             	add    $0x10,%esp
  801ac8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801acd:	7f 67                	jg     801b36 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801acf:	83 ec 0c             	sub    $0xc,%esp
  801ad2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad5:	50                   	push   %eax
  801ad6:	e8 71 f8 ff ff       	call   80134c <fd_alloc>
  801adb:	83 c4 10             	add    $0x10,%esp
		return r;
  801ade:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ae0:	85 c0                	test   %eax,%eax
  801ae2:	78 57                	js     801b3b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ae4:	83 ec 08             	sub    $0x8,%esp
  801ae7:	53                   	push   %ebx
  801ae8:	68 00 50 80 00       	push   $0x805000
  801aed:	e8 b0 ed ff ff       	call   8008a2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801af2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801afa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801afd:	b8 01 00 00 00       	mov    $0x1,%eax
  801b02:	e8 cd fd ff ff       	call   8018d4 <fsipc>
  801b07:	89 c3                	mov    %eax,%ebx
  801b09:	83 c4 10             	add    $0x10,%esp
  801b0c:	85 c0                	test   %eax,%eax
  801b0e:	79 14                	jns    801b24 <open+0x6f>
		fd_close(fd, 0);
  801b10:	83 ec 08             	sub    $0x8,%esp
  801b13:	6a 00                	push   $0x0
  801b15:	ff 75 f4             	pushl  -0xc(%ebp)
  801b18:	e8 27 f9 ff ff       	call   801444 <fd_close>
		return r;
  801b1d:	83 c4 10             	add    $0x10,%esp
  801b20:	89 da                	mov    %ebx,%edx
  801b22:	eb 17                	jmp    801b3b <open+0x86>
	}

	return fd2num(fd);
  801b24:	83 ec 0c             	sub    $0xc,%esp
  801b27:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2a:	e8 f6 f7 ff ff       	call   801325 <fd2num>
  801b2f:	89 c2                	mov    %eax,%edx
  801b31:	83 c4 10             	add    $0x10,%esp
  801b34:	eb 05                	jmp    801b3b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b36:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b3b:	89 d0                	mov    %edx,%eax
  801b3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b40:	c9                   	leave  
  801b41:	c3                   	ret    

00801b42 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b42:	55                   	push   %ebp
  801b43:	89 e5                	mov    %esp,%ebp
  801b45:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b48:	ba 00 00 00 00       	mov    $0x0,%edx
  801b4d:	b8 08 00 00 00       	mov    $0x8,%eax
  801b52:	e8 7d fd ff ff       	call   8018d4 <fsipc>
}
  801b57:	c9                   	leave  
  801b58:	c3                   	ret    

00801b59 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b5f:	89 d0                	mov    %edx,%eax
  801b61:	c1 e8 16             	shr    $0x16,%eax
  801b64:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b6b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b70:	f6 c1 01             	test   $0x1,%cl
  801b73:	74 1d                	je     801b92 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b75:	c1 ea 0c             	shr    $0xc,%edx
  801b78:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b7f:	f6 c2 01             	test   $0x1,%dl
  801b82:	74 0e                	je     801b92 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b84:	c1 ea 0c             	shr    $0xc,%edx
  801b87:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b8e:	ef 
  801b8f:	0f b7 c0             	movzwl %ax,%eax
}
  801b92:	5d                   	pop    %ebp
  801b93:	c3                   	ret    

00801b94 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801b9a:	68 c7 2d 80 00       	push   $0x802dc7
  801b9f:	ff 75 0c             	pushl  0xc(%ebp)
  801ba2:	e8 fb ec ff ff       	call   8008a2 <strcpy>
	return 0;
}
  801ba7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bac:	c9                   	leave  
  801bad:	c3                   	ret    

00801bae <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801bae:	55                   	push   %ebp
  801baf:	89 e5                	mov    %esp,%ebp
  801bb1:	53                   	push   %ebx
  801bb2:	83 ec 10             	sub    $0x10,%esp
  801bb5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801bb8:	53                   	push   %ebx
  801bb9:	e8 9b ff ff ff       	call   801b59 <pageref>
  801bbe:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801bc1:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801bc6:	83 f8 01             	cmp    $0x1,%eax
  801bc9:	75 10                	jne    801bdb <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801bcb:	83 ec 0c             	sub    $0xc,%esp
  801bce:	ff 73 0c             	pushl  0xc(%ebx)
  801bd1:	e8 c0 02 00 00       	call   801e96 <nsipc_close>
  801bd6:	89 c2                	mov    %eax,%edx
  801bd8:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801bdb:	89 d0                	mov    %edx,%eax
  801bdd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be0:	c9                   	leave  
  801be1:	c3                   	ret    

00801be2 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801be8:	6a 00                	push   $0x0
  801bea:	ff 75 10             	pushl  0x10(%ebp)
  801bed:	ff 75 0c             	pushl  0xc(%ebp)
  801bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf3:	ff 70 0c             	pushl  0xc(%eax)
  801bf6:	e8 78 03 00 00       	call   801f73 <nsipc_send>
}
  801bfb:	c9                   	leave  
  801bfc:	c3                   	ret    

00801bfd <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801bfd:	55                   	push   %ebp
  801bfe:	89 e5                	mov    %esp,%ebp
  801c00:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c03:	6a 00                	push   $0x0
  801c05:	ff 75 10             	pushl  0x10(%ebp)
  801c08:	ff 75 0c             	pushl  0xc(%ebp)
  801c0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0e:	ff 70 0c             	pushl  0xc(%eax)
  801c11:	e8 f1 02 00 00       	call   801f07 <nsipc_recv>
}
  801c16:	c9                   	leave  
  801c17:	c3                   	ret    

00801c18 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c1e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c21:	52                   	push   %edx
  801c22:	50                   	push   %eax
  801c23:	e8 73 f7 ff ff       	call   80139b <fd_lookup>
  801c28:	83 c4 10             	add    $0x10,%esp
  801c2b:	85 c0                	test   %eax,%eax
  801c2d:	78 17                	js     801c46 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c32:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801c38:	39 08                	cmp    %ecx,(%eax)
  801c3a:	75 05                	jne    801c41 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c3c:	8b 40 0c             	mov    0xc(%eax),%eax
  801c3f:	eb 05                	jmp    801c46 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801c41:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801c46:	c9                   	leave  
  801c47:	c3                   	ret    

00801c48 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	56                   	push   %esi
  801c4c:	53                   	push   %ebx
  801c4d:	83 ec 1c             	sub    $0x1c,%esp
  801c50:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801c52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c55:	50                   	push   %eax
  801c56:	e8 f1 f6 ff ff       	call   80134c <fd_alloc>
  801c5b:	89 c3                	mov    %eax,%ebx
  801c5d:	83 c4 10             	add    $0x10,%esp
  801c60:	85 c0                	test   %eax,%eax
  801c62:	78 1b                	js     801c7f <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c64:	83 ec 04             	sub    $0x4,%esp
  801c67:	68 07 04 00 00       	push   $0x407
  801c6c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6f:	6a 00                	push   $0x0
  801c71:	e8 2f f0 ff ff       	call   800ca5 <sys_page_alloc>
  801c76:	89 c3                	mov    %eax,%ebx
  801c78:	83 c4 10             	add    $0x10,%esp
  801c7b:	85 c0                	test   %eax,%eax
  801c7d:	79 10                	jns    801c8f <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801c7f:	83 ec 0c             	sub    $0xc,%esp
  801c82:	56                   	push   %esi
  801c83:	e8 0e 02 00 00       	call   801e96 <nsipc_close>
		return r;
  801c88:	83 c4 10             	add    $0x10,%esp
  801c8b:	89 d8                	mov    %ebx,%eax
  801c8d:	eb 24                	jmp    801cb3 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801c8f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c98:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ca4:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ca7:	83 ec 0c             	sub    $0xc,%esp
  801caa:	50                   	push   %eax
  801cab:	e8 75 f6 ff ff       	call   801325 <fd2num>
  801cb0:	83 c4 10             	add    $0x10,%esp
}
  801cb3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb6:	5b                   	pop    %ebx
  801cb7:	5e                   	pop    %esi
  801cb8:	5d                   	pop    %ebp
  801cb9:	c3                   	ret    

00801cba <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cba:	55                   	push   %ebp
  801cbb:	89 e5                	mov    %esp,%ebp
  801cbd:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc3:	e8 50 ff ff ff       	call   801c18 <fd2sockid>
		return r;
  801cc8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cca:	85 c0                	test   %eax,%eax
  801ccc:	78 1f                	js     801ced <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801cce:	83 ec 04             	sub    $0x4,%esp
  801cd1:	ff 75 10             	pushl  0x10(%ebp)
  801cd4:	ff 75 0c             	pushl  0xc(%ebp)
  801cd7:	50                   	push   %eax
  801cd8:	e8 12 01 00 00       	call   801def <nsipc_accept>
  801cdd:	83 c4 10             	add    $0x10,%esp
		return r;
  801ce0:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ce2:	85 c0                	test   %eax,%eax
  801ce4:	78 07                	js     801ced <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ce6:	e8 5d ff ff ff       	call   801c48 <alloc_sockfd>
  801ceb:	89 c1                	mov    %eax,%ecx
}
  801ced:	89 c8                	mov    %ecx,%eax
  801cef:	c9                   	leave  
  801cf0:	c3                   	ret    

00801cf1 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cf1:	55                   	push   %ebp
  801cf2:	89 e5                	mov    %esp,%ebp
  801cf4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cf7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfa:	e8 19 ff ff ff       	call   801c18 <fd2sockid>
  801cff:	85 c0                	test   %eax,%eax
  801d01:	78 12                	js     801d15 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801d03:	83 ec 04             	sub    $0x4,%esp
  801d06:	ff 75 10             	pushl  0x10(%ebp)
  801d09:	ff 75 0c             	pushl  0xc(%ebp)
  801d0c:	50                   	push   %eax
  801d0d:	e8 2d 01 00 00       	call   801e3f <nsipc_bind>
  801d12:	83 c4 10             	add    $0x10,%esp
}
  801d15:	c9                   	leave  
  801d16:	c3                   	ret    

00801d17 <shutdown>:

int
shutdown(int s, int how)
{
  801d17:	55                   	push   %ebp
  801d18:	89 e5                	mov    %esp,%ebp
  801d1a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d20:	e8 f3 fe ff ff       	call   801c18 <fd2sockid>
  801d25:	85 c0                	test   %eax,%eax
  801d27:	78 0f                	js     801d38 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801d29:	83 ec 08             	sub    $0x8,%esp
  801d2c:	ff 75 0c             	pushl  0xc(%ebp)
  801d2f:	50                   	push   %eax
  801d30:	e8 3f 01 00 00       	call   801e74 <nsipc_shutdown>
  801d35:	83 c4 10             	add    $0x10,%esp
}
  801d38:	c9                   	leave  
  801d39:	c3                   	ret    

00801d3a <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
  801d3d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d40:	8b 45 08             	mov    0x8(%ebp),%eax
  801d43:	e8 d0 fe ff ff       	call   801c18 <fd2sockid>
  801d48:	85 c0                	test   %eax,%eax
  801d4a:	78 12                	js     801d5e <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801d4c:	83 ec 04             	sub    $0x4,%esp
  801d4f:	ff 75 10             	pushl  0x10(%ebp)
  801d52:	ff 75 0c             	pushl  0xc(%ebp)
  801d55:	50                   	push   %eax
  801d56:	e8 55 01 00 00       	call   801eb0 <nsipc_connect>
  801d5b:	83 c4 10             	add    $0x10,%esp
}
  801d5e:	c9                   	leave  
  801d5f:	c3                   	ret    

00801d60 <listen>:

int
listen(int s, int backlog)
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d66:	8b 45 08             	mov    0x8(%ebp),%eax
  801d69:	e8 aa fe ff ff       	call   801c18 <fd2sockid>
  801d6e:	85 c0                	test   %eax,%eax
  801d70:	78 0f                	js     801d81 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801d72:	83 ec 08             	sub    $0x8,%esp
  801d75:	ff 75 0c             	pushl  0xc(%ebp)
  801d78:	50                   	push   %eax
  801d79:	e8 67 01 00 00       	call   801ee5 <nsipc_listen>
  801d7e:	83 c4 10             	add    $0x10,%esp
}
  801d81:	c9                   	leave  
  801d82:	c3                   	ret    

00801d83 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801d83:	55                   	push   %ebp
  801d84:	89 e5                	mov    %esp,%ebp
  801d86:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d89:	ff 75 10             	pushl  0x10(%ebp)
  801d8c:	ff 75 0c             	pushl  0xc(%ebp)
  801d8f:	ff 75 08             	pushl  0x8(%ebp)
  801d92:	e8 3a 02 00 00       	call   801fd1 <nsipc_socket>
  801d97:	83 c4 10             	add    $0x10,%esp
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	78 05                	js     801da3 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801d9e:	e8 a5 fe ff ff       	call   801c48 <alloc_sockfd>
}
  801da3:	c9                   	leave  
  801da4:	c3                   	ret    

00801da5 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801da5:	55                   	push   %ebp
  801da6:	89 e5                	mov    %esp,%ebp
  801da8:	53                   	push   %ebx
  801da9:	83 ec 04             	sub    $0x4,%esp
  801dac:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801dae:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801db5:	75 12                	jne    801dc9 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801db7:	83 ec 0c             	sub    $0xc,%esp
  801dba:	6a 02                	push   $0x2
  801dbc:	e8 2b f5 ff ff       	call   8012ec <ipc_find_env>
  801dc1:	a3 04 40 80 00       	mov    %eax,0x804004
  801dc6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801dc9:	6a 07                	push   $0x7
  801dcb:	68 00 60 80 00       	push   $0x806000
  801dd0:	53                   	push   %ebx
  801dd1:	ff 35 04 40 80 00    	pushl  0x804004
  801dd7:	e8 bc f4 ff ff       	call   801298 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ddc:	83 c4 0c             	add    $0xc,%esp
  801ddf:	6a 00                	push   $0x0
  801de1:	6a 00                	push   $0x0
  801de3:	6a 00                	push   $0x0
  801de5:	e8 45 f4 ff ff       	call   80122f <ipc_recv>
}
  801dea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ded:	c9                   	leave  
  801dee:	c3                   	ret    

00801def <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801def:	55                   	push   %ebp
  801df0:	89 e5                	mov    %esp,%ebp
  801df2:	56                   	push   %esi
  801df3:	53                   	push   %ebx
  801df4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801df7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfa:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801dff:	8b 06                	mov    (%esi),%eax
  801e01:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e06:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0b:	e8 95 ff ff ff       	call   801da5 <nsipc>
  801e10:	89 c3                	mov    %eax,%ebx
  801e12:	85 c0                	test   %eax,%eax
  801e14:	78 20                	js     801e36 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e16:	83 ec 04             	sub    $0x4,%esp
  801e19:	ff 35 10 60 80 00    	pushl  0x806010
  801e1f:	68 00 60 80 00       	push   $0x806000
  801e24:	ff 75 0c             	pushl  0xc(%ebp)
  801e27:	e8 08 ec ff ff       	call   800a34 <memmove>
		*addrlen = ret->ret_addrlen;
  801e2c:	a1 10 60 80 00       	mov    0x806010,%eax
  801e31:	89 06                	mov    %eax,(%esi)
  801e33:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801e36:	89 d8                	mov    %ebx,%eax
  801e38:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e3b:	5b                   	pop    %ebx
  801e3c:	5e                   	pop    %esi
  801e3d:	5d                   	pop    %ebp
  801e3e:	c3                   	ret    

00801e3f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e3f:	55                   	push   %ebp
  801e40:	89 e5                	mov    %esp,%ebp
  801e42:	53                   	push   %ebx
  801e43:	83 ec 08             	sub    $0x8,%esp
  801e46:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e49:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e51:	53                   	push   %ebx
  801e52:	ff 75 0c             	pushl  0xc(%ebp)
  801e55:	68 04 60 80 00       	push   $0x806004
  801e5a:	e8 d5 eb ff ff       	call   800a34 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e5f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801e65:	b8 02 00 00 00       	mov    $0x2,%eax
  801e6a:	e8 36 ff ff ff       	call   801da5 <nsipc>
}
  801e6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e72:	c9                   	leave  
  801e73:	c3                   	ret    

00801e74 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e74:	55                   	push   %ebp
  801e75:	89 e5                	mov    %esp,%ebp
  801e77:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e82:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e85:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e8a:	b8 03 00 00 00       	mov    $0x3,%eax
  801e8f:	e8 11 ff ff ff       	call   801da5 <nsipc>
}
  801e94:	c9                   	leave  
  801e95:	c3                   	ret    

00801e96 <nsipc_close>:

int
nsipc_close(int s)
{
  801e96:	55                   	push   %ebp
  801e97:	89 e5                	mov    %esp,%ebp
  801e99:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9f:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801ea4:	b8 04 00 00 00       	mov    $0x4,%eax
  801ea9:	e8 f7 fe ff ff       	call   801da5 <nsipc>
}
  801eae:	c9                   	leave  
  801eaf:	c3                   	ret    

00801eb0 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801eb0:	55                   	push   %ebp
  801eb1:	89 e5                	mov    %esp,%ebp
  801eb3:	53                   	push   %ebx
  801eb4:	83 ec 08             	sub    $0x8,%esp
  801eb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801eba:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebd:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ec2:	53                   	push   %ebx
  801ec3:	ff 75 0c             	pushl  0xc(%ebp)
  801ec6:	68 04 60 80 00       	push   $0x806004
  801ecb:	e8 64 eb ff ff       	call   800a34 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ed0:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801ed6:	b8 05 00 00 00       	mov    $0x5,%eax
  801edb:	e8 c5 fe ff ff       	call   801da5 <nsipc>
}
  801ee0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ee3:	c9                   	leave  
  801ee4:	c3                   	ret    

00801ee5 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ee5:	55                   	push   %ebp
  801ee6:	89 e5                	mov    %esp,%ebp
  801ee8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801eeb:	8b 45 08             	mov    0x8(%ebp),%eax
  801eee:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801ef3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef6:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801efb:	b8 06 00 00 00       	mov    $0x6,%eax
  801f00:	e8 a0 fe ff ff       	call   801da5 <nsipc>
}
  801f05:	c9                   	leave  
  801f06:	c3                   	ret    

00801f07 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f07:	55                   	push   %ebp
  801f08:	89 e5                	mov    %esp,%ebp
  801f0a:	56                   	push   %esi
  801f0b:	53                   	push   %ebx
  801f0c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f12:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801f17:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801f1d:	8b 45 14             	mov    0x14(%ebp),%eax
  801f20:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f25:	b8 07 00 00 00       	mov    $0x7,%eax
  801f2a:	e8 76 fe ff ff       	call   801da5 <nsipc>
  801f2f:	89 c3                	mov    %eax,%ebx
  801f31:	85 c0                	test   %eax,%eax
  801f33:	78 35                	js     801f6a <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801f35:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801f3a:	7f 04                	jg     801f40 <nsipc_recv+0x39>
  801f3c:	39 c6                	cmp    %eax,%esi
  801f3e:	7d 16                	jge    801f56 <nsipc_recv+0x4f>
  801f40:	68 d3 2d 80 00       	push   $0x802dd3
  801f45:	68 94 2d 80 00       	push   $0x802d94
  801f4a:	6a 62                	push   $0x62
  801f4c:	68 e8 2d 80 00       	push   $0x802de8
  801f51:	e8 ee e2 ff ff       	call   800244 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f56:	83 ec 04             	sub    $0x4,%esp
  801f59:	50                   	push   %eax
  801f5a:	68 00 60 80 00       	push   $0x806000
  801f5f:	ff 75 0c             	pushl  0xc(%ebp)
  801f62:	e8 cd ea ff ff       	call   800a34 <memmove>
  801f67:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f6a:	89 d8                	mov    %ebx,%eax
  801f6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f6f:	5b                   	pop    %ebx
  801f70:	5e                   	pop    %esi
  801f71:	5d                   	pop    %ebp
  801f72:	c3                   	ret    

00801f73 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f73:	55                   	push   %ebp
  801f74:	89 e5                	mov    %esp,%ebp
  801f76:	53                   	push   %ebx
  801f77:	83 ec 04             	sub    $0x4,%esp
  801f7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f80:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801f85:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f8b:	7e 16                	jle    801fa3 <nsipc_send+0x30>
  801f8d:	68 f4 2d 80 00       	push   $0x802df4
  801f92:	68 94 2d 80 00       	push   $0x802d94
  801f97:	6a 6d                	push   $0x6d
  801f99:	68 e8 2d 80 00       	push   $0x802de8
  801f9e:	e8 a1 e2 ff ff       	call   800244 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801fa3:	83 ec 04             	sub    $0x4,%esp
  801fa6:	53                   	push   %ebx
  801fa7:	ff 75 0c             	pushl  0xc(%ebp)
  801faa:	68 0c 60 80 00       	push   $0x80600c
  801faf:	e8 80 ea ff ff       	call   800a34 <memmove>
	nsipcbuf.send.req_size = size;
  801fb4:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801fba:	8b 45 14             	mov    0x14(%ebp),%eax
  801fbd:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801fc2:	b8 08 00 00 00       	mov    $0x8,%eax
  801fc7:	e8 d9 fd ff ff       	call   801da5 <nsipc>
}
  801fcc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fcf:	c9                   	leave  
  801fd0:	c3                   	ret    

00801fd1 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801fd1:	55                   	push   %ebp
  801fd2:	89 e5                	mov    %esp,%ebp
  801fd4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801fd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801fda:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801fdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe2:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801fe7:	8b 45 10             	mov    0x10(%ebp),%eax
  801fea:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801fef:	b8 09 00 00 00       	mov    $0x9,%eax
  801ff4:	e8 ac fd ff ff       	call   801da5 <nsipc>
}
  801ff9:	c9                   	leave  
  801ffa:	c3                   	ret    

00801ffb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ffb:	55                   	push   %ebp
  801ffc:	89 e5                	mov    %esp,%ebp
  801ffe:	56                   	push   %esi
  801fff:	53                   	push   %ebx
  802000:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802003:	83 ec 0c             	sub    $0xc,%esp
  802006:	ff 75 08             	pushl  0x8(%ebp)
  802009:	e8 27 f3 ff ff       	call   801335 <fd2data>
  80200e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802010:	83 c4 08             	add    $0x8,%esp
  802013:	68 00 2e 80 00       	push   $0x802e00
  802018:	53                   	push   %ebx
  802019:	e8 84 e8 ff ff       	call   8008a2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80201e:	8b 46 04             	mov    0x4(%esi),%eax
  802021:	2b 06                	sub    (%esi),%eax
  802023:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802029:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802030:	00 00 00 
	stat->st_dev = &devpipe;
  802033:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80203a:	30 80 00 
	return 0;
}
  80203d:	b8 00 00 00 00       	mov    $0x0,%eax
  802042:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802045:	5b                   	pop    %ebx
  802046:	5e                   	pop    %esi
  802047:	5d                   	pop    %ebp
  802048:	c3                   	ret    

00802049 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802049:	55                   	push   %ebp
  80204a:	89 e5                	mov    %esp,%ebp
  80204c:	53                   	push   %ebx
  80204d:	83 ec 0c             	sub    $0xc,%esp
  802050:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802053:	53                   	push   %ebx
  802054:	6a 00                	push   $0x0
  802056:	e8 cf ec ff ff       	call   800d2a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80205b:	89 1c 24             	mov    %ebx,(%esp)
  80205e:	e8 d2 f2 ff ff       	call   801335 <fd2data>
  802063:	83 c4 08             	add    $0x8,%esp
  802066:	50                   	push   %eax
  802067:	6a 00                	push   $0x0
  802069:	e8 bc ec ff ff       	call   800d2a <sys_page_unmap>
}
  80206e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802071:	c9                   	leave  
  802072:	c3                   	ret    

00802073 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802073:	55                   	push   %ebp
  802074:	89 e5                	mov    %esp,%ebp
  802076:	57                   	push   %edi
  802077:	56                   	push   %esi
  802078:	53                   	push   %ebx
  802079:	83 ec 1c             	sub    $0x1c,%esp
  80207c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80207f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802081:	a1 08 40 80 00       	mov    0x804008,%eax
  802086:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802089:	83 ec 0c             	sub    $0xc,%esp
  80208c:	ff 75 e0             	pushl  -0x20(%ebp)
  80208f:	e8 c5 fa ff ff       	call   801b59 <pageref>
  802094:	89 c3                	mov    %eax,%ebx
  802096:	89 3c 24             	mov    %edi,(%esp)
  802099:	e8 bb fa ff ff       	call   801b59 <pageref>
  80209e:	83 c4 10             	add    $0x10,%esp
  8020a1:	39 c3                	cmp    %eax,%ebx
  8020a3:	0f 94 c1             	sete   %cl
  8020a6:	0f b6 c9             	movzbl %cl,%ecx
  8020a9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8020ac:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8020b2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8020b5:	39 ce                	cmp    %ecx,%esi
  8020b7:	74 1b                	je     8020d4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8020b9:	39 c3                	cmp    %eax,%ebx
  8020bb:	75 c4                	jne    802081 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8020bd:	8b 42 58             	mov    0x58(%edx),%eax
  8020c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8020c3:	50                   	push   %eax
  8020c4:	56                   	push   %esi
  8020c5:	68 07 2e 80 00       	push   $0x802e07
  8020ca:	e8 4e e2 ff ff       	call   80031d <cprintf>
  8020cf:	83 c4 10             	add    $0x10,%esp
  8020d2:	eb ad                	jmp    802081 <_pipeisclosed+0xe>
	}
}
  8020d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020da:	5b                   	pop    %ebx
  8020db:	5e                   	pop    %esi
  8020dc:	5f                   	pop    %edi
  8020dd:	5d                   	pop    %ebp
  8020de:	c3                   	ret    

008020df <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020df:	55                   	push   %ebp
  8020e0:	89 e5                	mov    %esp,%ebp
  8020e2:	57                   	push   %edi
  8020e3:	56                   	push   %esi
  8020e4:	53                   	push   %ebx
  8020e5:	83 ec 28             	sub    $0x28,%esp
  8020e8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8020eb:	56                   	push   %esi
  8020ec:	e8 44 f2 ff ff       	call   801335 <fd2data>
  8020f1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020f3:	83 c4 10             	add    $0x10,%esp
  8020f6:	bf 00 00 00 00       	mov    $0x0,%edi
  8020fb:	eb 4b                	jmp    802148 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8020fd:	89 da                	mov    %ebx,%edx
  8020ff:	89 f0                	mov    %esi,%eax
  802101:	e8 6d ff ff ff       	call   802073 <_pipeisclosed>
  802106:	85 c0                	test   %eax,%eax
  802108:	75 48                	jne    802152 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80210a:	e8 77 eb ff ff       	call   800c86 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80210f:	8b 43 04             	mov    0x4(%ebx),%eax
  802112:	8b 0b                	mov    (%ebx),%ecx
  802114:	8d 51 20             	lea    0x20(%ecx),%edx
  802117:	39 d0                	cmp    %edx,%eax
  802119:	73 e2                	jae    8020fd <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80211b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80211e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802122:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802125:	89 c2                	mov    %eax,%edx
  802127:	c1 fa 1f             	sar    $0x1f,%edx
  80212a:	89 d1                	mov    %edx,%ecx
  80212c:	c1 e9 1b             	shr    $0x1b,%ecx
  80212f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802132:	83 e2 1f             	and    $0x1f,%edx
  802135:	29 ca                	sub    %ecx,%edx
  802137:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80213b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80213f:	83 c0 01             	add    $0x1,%eax
  802142:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802145:	83 c7 01             	add    $0x1,%edi
  802148:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80214b:	75 c2                	jne    80210f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80214d:	8b 45 10             	mov    0x10(%ebp),%eax
  802150:	eb 05                	jmp    802157 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802152:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802157:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80215a:	5b                   	pop    %ebx
  80215b:	5e                   	pop    %esi
  80215c:	5f                   	pop    %edi
  80215d:	5d                   	pop    %ebp
  80215e:	c3                   	ret    

0080215f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80215f:	55                   	push   %ebp
  802160:	89 e5                	mov    %esp,%ebp
  802162:	57                   	push   %edi
  802163:	56                   	push   %esi
  802164:	53                   	push   %ebx
  802165:	83 ec 18             	sub    $0x18,%esp
  802168:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80216b:	57                   	push   %edi
  80216c:	e8 c4 f1 ff ff       	call   801335 <fd2data>
  802171:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802173:	83 c4 10             	add    $0x10,%esp
  802176:	bb 00 00 00 00       	mov    $0x0,%ebx
  80217b:	eb 3d                	jmp    8021ba <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80217d:	85 db                	test   %ebx,%ebx
  80217f:	74 04                	je     802185 <devpipe_read+0x26>
				return i;
  802181:	89 d8                	mov    %ebx,%eax
  802183:	eb 44                	jmp    8021c9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802185:	89 f2                	mov    %esi,%edx
  802187:	89 f8                	mov    %edi,%eax
  802189:	e8 e5 fe ff ff       	call   802073 <_pipeisclosed>
  80218e:	85 c0                	test   %eax,%eax
  802190:	75 32                	jne    8021c4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802192:	e8 ef ea ff ff       	call   800c86 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802197:	8b 06                	mov    (%esi),%eax
  802199:	3b 46 04             	cmp    0x4(%esi),%eax
  80219c:	74 df                	je     80217d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80219e:	99                   	cltd   
  80219f:	c1 ea 1b             	shr    $0x1b,%edx
  8021a2:	01 d0                	add    %edx,%eax
  8021a4:	83 e0 1f             	and    $0x1f,%eax
  8021a7:	29 d0                	sub    %edx,%eax
  8021a9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8021ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021b1:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8021b4:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021b7:	83 c3 01             	add    $0x1,%ebx
  8021ba:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8021bd:	75 d8                	jne    802197 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8021bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8021c2:	eb 05                	jmp    8021c9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021c4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8021c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021cc:	5b                   	pop    %ebx
  8021cd:	5e                   	pop    %esi
  8021ce:	5f                   	pop    %edi
  8021cf:	5d                   	pop    %ebp
  8021d0:	c3                   	ret    

008021d1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8021d1:	55                   	push   %ebp
  8021d2:	89 e5                	mov    %esp,%ebp
  8021d4:	56                   	push   %esi
  8021d5:	53                   	push   %ebx
  8021d6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8021d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021dc:	50                   	push   %eax
  8021dd:	e8 6a f1 ff ff       	call   80134c <fd_alloc>
  8021e2:	83 c4 10             	add    $0x10,%esp
  8021e5:	89 c2                	mov    %eax,%edx
  8021e7:	85 c0                	test   %eax,%eax
  8021e9:	0f 88 2c 01 00 00    	js     80231b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021ef:	83 ec 04             	sub    $0x4,%esp
  8021f2:	68 07 04 00 00       	push   $0x407
  8021f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8021fa:	6a 00                	push   $0x0
  8021fc:	e8 a4 ea ff ff       	call   800ca5 <sys_page_alloc>
  802201:	83 c4 10             	add    $0x10,%esp
  802204:	89 c2                	mov    %eax,%edx
  802206:	85 c0                	test   %eax,%eax
  802208:	0f 88 0d 01 00 00    	js     80231b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80220e:	83 ec 0c             	sub    $0xc,%esp
  802211:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802214:	50                   	push   %eax
  802215:	e8 32 f1 ff ff       	call   80134c <fd_alloc>
  80221a:	89 c3                	mov    %eax,%ebx
  80221c:	83 c4 10             	add    $0x10,%esp
  80221f:	85 c0                	test   %eax,%eax
  802221:	0f 88 e2 00 00 00    	js     802309 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802227:	83 ec 04             	sub    $0x4,%esp
  80222a:	68 07 04 00 00       	push   $0x407
  80222f:	ff 75 f0             	pushl  -0x10(%ebp)
  802232:	6a 00                	push   $0x0
  802234:	e8 6c ea ff ff       	call   800ca5 <sys_page_alloc>
  802239:	89 c3                	mov    %eax,%ebx
  80223b:	83 c4 10             	add    $0x10,%esp
  80223e:	85 c0                	test   %eax,%eax
  802240:	0f 88 c3 00 00 00    	js     802309 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802246:	83 ec 0c             	sub    $0xc,%esp
  802249:	ff 75 f4             	pushl  -0xc(%ebp)
  80224c:	e8 e4 f0 ff ff       	call   801335 <fd2data>
  802251:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802253:	83 c4 0c             	add    $0xc,%esp
  802256:	68 07 04 00 00       	push   $0x407
  80225b:	50                   	push   %eax
  80225c:	6a 00                	push   $0x0
  80225e:	e8 42 ea ff ff       	call   800ca5 <sys_page_alloc>
  802263:	89 c3                	mov    %eax,%ebx
  802265:	83 c4 10             	add    $0x10,%esp
  802268:	85 c0                	test   %eax,%eax
  80226a:	0f 88 89 00 00 00    	js     8022f9 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802270:	83 ec 0c             	sub    $0xc,%esp
  802273:	ff 75 f0             	pushl  -0x10(%ebp)
  802276:	e8 ba f0 ff ff       	call   801335 <fd2data>
  80227b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802282:	50                   	push   %eax
  802283:	6a 00                	push   $0x0
  802285:	56                   	push   %esi
  802286:	6a 00                	push   $0x0
  802288:	e8 5b ea ff ff       	call   800ce8 <sys_page_map>
  80228d:	89 c3                	mov    %eax,%ebx
  80228f:	83 c4 20             	add    $0x20,%esp
  802292:	85 c0                	test   %eax,%eax
  802294:	78 55                	js     8022eb <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802296:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80229c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80229f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8022a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022a4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8022ab:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022b4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8022b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022b9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8022c0:	83 ec 0c             	sub    $0xc,%esp
  8022c3:	ff 75 f4             	pushl  -0xc(%ebp)
  8022c6:	e8 5a f0 ff ff       	call   801325 <fd2num>
  8022cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022ce:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8022d0:	83 c4 04             	add    $0x4,%esp
  8022d3:	ff 75 f0             	pushl  -0x10(%ebp)
  8022d6:	e8 4a f0 ff ff       	call   801325 <fd2num>
  8022db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022de:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8022e1:	83 c4 10             	add    $0x10,%esp
  8022e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8022e9:	eb 30                	jmp    80231b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8022eb:	83 ec 08             	sub    $0x8,%esp
  8022ee:	56                   	push   %esi
  8022ef:	6a 00                	push   $0x0
  8022f1:	e8 34 ea ff ff       	call   800d2a <sys_page_unmap>
  8022f6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8022f9:	83 ec 08             	sub    $0x8,%esp
  8022fc:	ff 75 f0             	pushl  -0x10(%ebp)
  8022ff:	6a 00                	push   $0x0
  802301:	e8 24 ea ff ff       	call   800d2a <sys_page_unmap>
  802306:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802309:	83 ec 08             	sub    $0x8,%esp
  80230c:	ff 75 f4             	pushl  -0xc(%ebp)
  80230f:	6a 00                	push   $0x0
  802311:	e8 14 ea ff ff       	call   800d2a <sys_page_unmap>
  802316:	83 c4 10             	add    $0x10,%esp
  802319:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80231b:	89 d0                	mov    %edx,%eax
  80231d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802320:	5b                   	pop    %ebx
  802321:	5e                   	pop    %esi
  802322:	5d                   	pop    %ebp
  802323:	c3                   	ret    

00802324 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802324:	55                   	push   %ebp
  802325:	89 e5                	mov    %esp,%ebp
  802327:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80232a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80232d:	50                   	push   %eax
  80232e:	ff 75 08             	pushl  0x8(%ebp)
  802331:	e8 65 f0 ff ff       	call   80139b <fd_lookup>
  802336:	83 c4 10             	add    $0x10,%esp
  802339:	85 c0                	test   %eax,%eax
  80233b:	78 18                	js     802355 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80233d:	83 ec 0c             	sub    $0xc,%esp
  802340:	ff 75 f4             	pushl  -0xc(%ebp)
  802343:	e8 ed ef ff ff       	call   801335 <fd2data>
	return _pipeisclosed(fd, p);
  802348:	89 c2                	mov    %eax,%edx
  80234a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80234d:	e8 21 fd ff ff       	call   802073 <_pipeisclosed>
  802352:	83 c4 10             	add    $0x10,%esp
}
  802355:	c9                   	leave  
  802356:	c3                   	ret    

00802357 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802357:	55                   	push   %ebp
  802358:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80235a:	b8 00 00 00 00       	mov    $0x0,%eax
  80235f:	5d                   	pop    %ebp
  802360:	c3                   	ret    

00802361 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802361:	55                   	push   %ebp
  802362:	89 e5                	mov    %esp,%ebp
  802364:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802367:	68 1f 2e 80 00       	push   $0x802e1f
  80236c:	ff 75 0c             	pushl  0xc(%ebp)
  80236f:	e8 2e e5 ff ff       	call   8008a2 <strcpy>
	return 0;
}
  802374:	b8 00 00 00 00       	mov    $0x0,%eax
  802379:	c9                   	leave  
  80237a:	c3                   	ret    

0080237b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80237b:	55                   	push   %ebp
  80237c:	89 e5                	mov    %esp,%ebp
  80237e:	57                   	push   %edi
  80237f:	56                   	push   %esi
  802380:	53                   	push   %ebx
  802381:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802387:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80238c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802392:	eb 2d                	jmp    8023c1 <devcons_write+0x46>
		m = n - tot;
  802394:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802397:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802399:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80239c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8023a1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023a4:	83 ec 04             	sub    $0x4,%esp
  8023a7:	53                   	push   %ebx
  8023a8:	03 45 0c             	add    0xc(%ebp),%eax
  8023ab:	50                   	push   %eax
  8023ac:	57                   	push   %edi
  8023ad:	e8 82 e6 ff ff       	call   800a34 <memmove>
		sys_cputs(buf, m);
  8023b2:	83 c4 08             	add    $0x8,%esp
  8023b5:	53                   	push   %ebx
  8023b6:	57                   	push   %edi
  8023b7:	e8 2d e8 ff ff       	call   800be9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023bc:	01 de                	add    %ebx,%esi
  8023be:	83 c4 10             	add    $0x10,%esp
  8023c1:	89 f0                	mov    %esi,%eax
  8023c3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023c6:	72 cc                	jb     802394 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8023c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023cb:	5b                   	pop    %ebx
  8023cc:	5e                   	pop    %esi
  8023cd:	5f                   	pop    %edi
  8023ce:	5d                   	pop    %ebp
  8023cf:	c3                   	ret    

008023d0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023d0:	55                   	push   %ebp
  8023d1:	89 e5                	mov    %esp,%ebp
  8023d3:	83 ec 08             	sub    $0x8,%esp
  8023d6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8023db:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023df:	74 2a                	je     80240b <devcons_read+0x3b>
  8023e1:	eb 05                	jmp    8023e8 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8023e3:	e8 9e e8 ff ff       	call   800c86 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8023e8:	e8 1a e8 ff ff       	call   800c07 <sys_cgetc>
  8023ed:	85 c0                	test   %eax,%eax
  8023ef:	74 f2                	je     8023e3 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8023f1:	85 c0                	test   %eax,%eax
  8023f3:	78 16                	js     80240b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8023f5:	83 f8 04             	cmp    $0x4,%eax
  8023f8:	74 0c                	je     802406 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8023fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023fd:	88 02                	mov    %al,(%edx)
	return 1;
  8023ff:	b8 01 00 00 00       	mov    $0x1,%eax
  802404:	eb 05                	jmp    80240b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802406:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80240b:	c9                   	leave  
  80240c:	c3                   	ret    

0080240d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80240d:	55                   	push   %ebp
  80240e:	89 e5                	mov    %esp,%ebp
  802410:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802413:	8b 45 08             	mov    0x8(%ebp),%eax
  802416:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802419:	6a 01                	push   $0x1
  80241b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80241e:	50                   	push   %eax
  80241f:	e8 c5 e7 ff ff       	call   800be9 <sys_cputs>
}
  802424:	83 c4 10             	add    $0x10,%esp
  802427:	c9                   	leave  
  802428:	c3                   	ret    

00802429 <getchar>:

int
getchar(void)
{
  802429:	55                   	push   %ebp
  80242a:	89 e5                	mov    %esp,%ebp
  80242c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80242f:	6a 01                	push   $0x1
  802431:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802434:	50                   	push   %eax
  802435:	6a 00                	push   $0x0
  802437:	e8 c5 f1 ff ff       	call   801601 <read>
	if (r < 0)
  80243c:	83 c4 10             	add    $0x10,%esp
  80243f:	85 c0                	test   %eax,%eax
  802441:	78 0f                	js     802452 <getchar+0x29>
		return r;
	if (r < 1)
  802443:	85 c0                	test   %eax,%eax
  802445:	7e 06                	jle    80244d <getchar+0x24>
		return -E_EOF;
	return c;
  802447:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80244b:	eb 05                	jmp    802452 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80244d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802452:	c9                   	leave  
  802453:	c3                   	ret    

00802454 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802454:	55                   	push   %ebp
  802455:	89 e5                	mov    %esp,%ebp
  802457:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80245a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80245d:	50                   	push   %eax
  80245e:	ff 75 08             	pushl  0x8(%ebp)
  802461:	e8 35 ef ff ff       	call   80139b <fd_lookup>
  802466:	83 c4 10             	add    $0x10,%esp
  802469:	85 c0                	test   %eax,%eax
  80246b:	78 11                	js     80247e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80246d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802470:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802476:	39 10                	cmp    %edx,(%eax)
  802478:	0f 94 c0             	sete   %al
  80247b:	0f b6 c0             	movzbl %al,%eax
}
  80247e:	c9                   	leave  
  80247f:	c3                   	ret    

00802480 <opencons>:

int
opencons(void)
{
  802480:	55                   	push   %ebp
  802481:	89 e5                	mov    %esp,%ebp
  802483:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802486:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802489:	50                   	push   %eax
  80248a:	e8 bd ee ff ff       	call   80134c <fd_alloc>
  80248f:	83 c4 10             	add    $0x10,%esp
		return r;
  802492:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802494:	85 c0                	test   %eax,%eax
  802496:	78 3e                	js     8024d6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802498:	83 ec 04             	sub    $0x4,%esp
  80249b:	68 07 04 00 00       	push   $0x407
  8024a0:	ff 75 f4             	pushl  -0xc(%ebp)
  8024a3:	6a 00                	push   $0x0
  8024a5:	e8 fb e7 ff ff       	call   800ca5 <sys_page_alloc>
  8024aa:	83 c4 10             	add    $0x10,%esp
		return r;
  8024ad:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024af:	85 c0                	test   %eax,%eax
  8024b1:	78 23                	js     8024d6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8024b3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024bc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024c1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8024c8:	83 ec 0c             	sub    $0xc,%esp
  8024cb:	50                   	push   %eax
  8024cc:	e8 54 ee ff ff       	call   801325 <fd2num>
  8024d1:	89 c2                	mov    %eax,%edx
  8024d3:	83 c4 10             	add    $0x10,%esp
}
  8024d6:	89 d0                	mov    %edx,%eax
  8024d8:	c9                   	leave  
  8024d9:	c3                   	ret    

008024da <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8024da:	55                   	push   %ebp
  8024db:	89 e5                	mov    %esp,%ebp
  8024dd:	53                   	push   %ebx
  8024de:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  8024e1:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8024e8:	75 28                	jne    802512 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  8024ea:	e8 78 e7 ff ff       	call   800c67 <sys_getenvid>
  8024ef:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  8024f1:	83 ec 04             	sub    $0x4,%esp
  8024f4:	6a 06                	push   $0x6
  8024f6:	68 00 f0 bf ee       	push   $0xeebff000
  8024fb:	50                   	push   %eax
  8024fc:	e8 a4 e7 ff ff       	call   800ca5 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  802501:	83 c4 08             	add    $0x8,%esp
  802504:	68 1f 25 80 00       	push   $0x80251f
  802509:	53                   	push   %ebx
  80250a:	e8 e1 e8 ff ff       	call   800df0 <sys_env_set_pgfault_upcall>
  80250f:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802512:	8b 45 08             	mov    0x8(%ebp),%eax
  802515:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80251a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80251d:	c9                   	leave  
  80251e:	c3                   	ret    

0080251f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80251f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802520:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802525:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802527:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  80252a:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  80252c:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  80252f:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  802532:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  802535:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  802538:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  80253b:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  80253e:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  802541:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  802544:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  802547:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  80254a:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  80254d:	61                   	popa   
	popfl
  80254e:	9d                   	popf   
	ret
  80254f:	c3                   	ret    

00802550 <__udivdi3>:
  802550:	55                   	push   %ebp
  802551:	57                   	push   %edi
  802552:	56                   	push   %esi
  802553:	53                   	push   %ebx
  802554:	83 ec 1c             	sub    $0x1c,%esp
  802557:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80255b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80255f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802563:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802567:	85 f6                	test   %esi,%esi
  802569:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80256d:	89 ca                	mov    %ecx,%edx
  80256f:	89 f8                	mov    %edi,%eax
  802571:	75 3d                	jne    8025b0 <__udivdi3+0x60>
  802573:	39 cf                	cmp    %ecx,%edi
  802575:	0f 87 c5 00 00 00    	ja     802640 <__udivdi3+0xf0>
  80257b:	85 ff                	test   %edi,%edi
  80257d:	89 fd                	mov    %edi,%ebp
  80257f:	75 0b                	jne    80258c <__udivdi3+0x3c>
  802581:	b8 01 00 00 00       	mov    $0x1,%eax
  802586:	31 d2                	xor    %edx,%edx
  802588:	f7 f7                	div    %edi
  80258a:	89 c5                	mov    %eax,%ebp
  80258c:	89 c8                	mov    %ecx,%eax
  80258e:	31 d2                	xor    %edx,%edx
  802590:	f7 f5                	div    %ebp
  802592:	89 c1                	mov    %eax,%ecx
  802594:	89 d8                	mov    %ebx,%eax
  802596:	89 cf                	mov    %ecx,%edi
  802598:	f7 f5                	div    %ebp
  80259a:	89 c3                	mov    %eax,%ebx
  80259c:	89 d8                	mov    %ebx,%eax
  80259e:	89 fa                	mov    %edi,%edx
  8025a0:	83 c4 1c             	add    $0x1c,%esp
  8025a3:	5b                   	pop    %ebx
  8025a4:	5e                   	pop    %esi
  8025a5:	5f                   	pop    %edi
  8025a6:	5d                   	pop    %ebp
  8025a7:	c3                   	ret    
  8025a8:	90                   	nop
  8025a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025b0:	39 ce                	cmp    %ecx,%esi
  8025b2:	77 74                	ja     802628 <__udivdi3+0xd8>
  8025b4:	0f bd fe             	bsr    %esi,%edi
  8025b7:	83 f7 1f             	xor    $0x1f,%edi
  8025ba:	0f 84 98 00 00 00    	je     802658 <__udivdi3+0x108>
  8025c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8025c5:	89 f9                	mov    %edi,%ecx
  8025c7:	89 c5                	mov    %eax,%ebp
  8025c9:	29 fb                	sub    %edi,%ebx
  8025cb:	d3 e6                	shl    %cl,%esi
  8025cd:	89 d9                	mov    %ebx,%ecx
  8025cf:	d3 ed                	shr    %cl,%ebp
  8025d1:	89 f9                	mov    %edi,%ecx
  8025d3:	d3 e0                	shl    %cl,%eax
  8025d5:	09 ee                	or     %ebp,%esi
  8025d7:	89 d9                	mov    %ebx,%ecx
  8025d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025dd:	89 d5                	mov    %edx,%ebp
  8025df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025e3:	d3 ed                	shr    %cl,%ebp
  8025e5:	89 f9                	mov    %edi,%ecx
  8025e7:	d3 e2                	shl    %cl,%edx
  8025e9:	89 d9                	mov    %ebx,%ecx
  8025eb:	d3 e8                	shr    %cl,%eax
  8025ed:	09 c2                	or     %eax,%edx
  8025ef:	89 d0                	mov    %edx,%eax
  8025f1:	89 ea                	mov    %ebp,%edx
  8025f3:	f7 f6                	div    %esi
  8025f5:	89 d5                	mov    %edx,%ebp
  8025f7:	89 c3                	mov    %eax,%ebx
  8025f9:	f7 64 24 0c          	mull   0xc(%esp)
  8025fd:	39 d5                	cmp    %edx,%ebp
  8025ff:	72 10                	jb     802611 <__udivdi3+0xc1>
  802601:	8b 74 24 08          	mov    0x8(%esp),%esi
  802605:	89 f9                	mov    %edi,%ecx
  802607:	d3 e6                	shl    %cl,%esi
  802609:	39 c6                	cmp    %eax,%esi
  80260b:	73 07                	jae    802614 <__udivdi3+0xc4>
  80260d:	39 d5                	cmp    %edx,%ebp
  80260f:	75 03                	jne    802614 <__udivdi3+0xc4>
  802611:	83 eb 01             	sub    $0x1,%ebx
  802614:	31 ff                	xor    %edi,%edi
  802616:	89 d8                	mov    %ebx,%eax
  802618:	89 fa                	mov    %edi,%edx
  80261a:	83 c4 1c             	add    $0x1c,%esp
  80261d:	5b                   	pop    %ebx
  80261e:	5e                   	pop    %esi
  80261f:	5f                   	pop    %edi
  802620:	5d                   	pop    %ebp
  802621:	c3                   	ret    
  802622:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802628:	31 ff                	xor    %edi,%edi
  80262a:	31 db                	xor    %ebx,%ebx
  80262c:	89 d8                	mov    %ebx,%eax
  80262e:	89 fa                	mov    %edi,%edx
  802630:	83 c4 1c             	add    $0x1c,%esp
  802633:	5b                   	pop    %ebx
  802634:	5e                   	pop    %esi
  802635:	5f                   	pop    %edi
  802636:	5d                   	pop    %ebp
  802637:	c3                   	ret    
  802638:	90                   	nop
  802639:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802640:	89 d8                	mov    %ebx,%eax
  802642:	f7 f7                	div    %edi
  802644:	31 ff                	xor    %edi,%edi
  802646:	89 c3                	mov    %eax,%ebx
  802648:	89 d8                	mov    %ebx,%eax
  80264a:	89 fa                	mov    %edi,%edx
  80264c:	83 c4 1c             	add    $0x1c,%esp
  80264f:	5b                   	pop    %ebx
  802650:	5e                   	pop    %esi
  802651:	5f                   	pop    %edi
  802652:	5d                   	pop    %ebp
  802653:	c3                   	ret    
  802654:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802658:	39 ce                	cmp    %ecx,%esi
  80265a:	72 0c                	jb     802668 <__udivdi3+0x118>
  80265c:	31 db                	xor    %ebx,%ebx
  80265e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802662:	0f 87 34 ff ff ff    	ja     80259c <__udivdi3+0x4c>
  802668:	bb 01 00 00 00       	mov    $0x1,%ebx
  80266d:	e9 2a ff ff ff       	jmp    80259c <__udivdi3+0x4c>
  802672:	66 90                	xchg   %ax,%ax
  802674:	66 90                	xchg   %ax,%ax
  802676:	66 90                	xchg   %ax,%ax
  802678:	66 90                	xchg   %ax,%ax
  80267a:	66 90                	xchg   %ax,%ax
  80267c:	66 90                	xchg   %ax,%ax
  80267e:	66 90                	xchg   %ax,%ax

00802680 <__umoddi3>:
  802680:	55                   	push   %ebp
  802681:	57                   	push   %edi
  802682:	56                   	push   %esi
  802683:	53                   	push   %ebx
  802684:	83 ec 1c             	sub    $0x1c,%esp
  802687:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80268b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80268f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802693:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802697:	85 d2                	test   %edx,%edx
  802699:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80269d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026a1:	89 f3                	mov    %esi,%ebx
  8026a3:	89 3c 24             	mov    %edi,(%esp)
  8026a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026aa:	75 1c                	jne    8026c8 <__umoddi3+0x48>
  8026ac:	39 f7                	cmp    %esi,%edi
  8026ae:	76 50                	jbe    802700 <__umoddi3+0x80>
  8026b0:	89 c8                	mov    %ecx,%eax
  8026b2:	89 f2                	mov    %esi,%edx
  8026b4:	f7 f7                	div    %edi
  8026b6:	89 d0                	mov    %edx,%eax
  8026b8:	31 d2                	xor    %edx,%edx
  8026ba:	83 c4 1c             	add    $0x1c,%esp
  8026bd:	5b                   	pop    %ebx
  8026be:	5e                   	pop    %esi
  8026bf:	5f                   	pop    %edi
  8026c0:	5d                   	pop    %ebp
  8026c1:	c3                   	ret    
  8026c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026c8:	39 f2                	cmp    %esi,%edx
  8026ca:	89 d0                	mov    %edx,%eax
  8026cc:	77 52                	ja     802720 <__umoddi3+0xa0>
  8026ce:	0f bd ea             	bsr    %edx,%ebp
  8026d1:	83 f5 1f             	xor    $0x1f,%ebp
  8026d4:	75 5a                	jne    802730 <__umoddi3+0xb0>
  8026d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8026da:	0f 82 e0 00 00 00    	jb     8027c0 <__umoddi3+0x140>
  8026e0:	39 0c 24             	cmp    %ecx,(%esp)
  8026e3:	0f 86 d7 00 00 00    	jbe    8027c0 <__umoddi3+0x140>
  8026e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026f1:	83 c4 1c             	add    $0x1c,%esp
  8026f4:	5b                   	pop    %ebx
  8026f5:	5e                   	pop    %esi
  8026f6:	5f                   	pop    %edi
  8026f7:	5d                   	pop    %ebp
  8026f8:	c3                   	ret    
  8026f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802700:	85 ff                	test   %edi,%edi
  802702:	89 fd                	mov    %edi,%ebp
  802704:	75 0b                	jne    802711 <__umoddi3+0x91>
  802706:	b8 01 00 00 00       	mov    $0x1,%eax
  80270b:	31 d2                	xor    %edx,%edx
  80270d:	f7 f7                	div    %edi
  80270f:	89 c5                	mov    %eax,%ebp
  802711:	89 f0                	mov    %esi,%eax
  802713:	31 d2                	xor    %edx,%edx
  802715:	f7 f5                	div    %ebp
  802717:	89 c8                	mov    %ecx,%eax
  802719:	f7 f5                	div    %ebp
  80271b:	89 d0                	mov    %edx,%eax
  80271d:	eb 99                	jmp    8026b8 <__umoddi3+0x38>
  80271f:	90                   	nop
  802720:	89 c8                	mov    %ecx,%eax
  802722:	89 f2                	mov    %esi,%edx
  802724:	83 c4 1c             	add    $0x1c,%esp
  802727:	5b                   	pop    %ebx
  802728:	5e                   	pop    %esi
  802729:	5f                   	pop    %edi
  80272a:	5d                   	pop    %ebp
  80272b:	c3                   	ret    
  80272c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802730:	8b 34 24             	mov    (%esp),%esi
  802733:	bf 20 00 00 00       	mov    $0x20,%edi
  802738:	89 e9                	mov    %ebp,%ecx
  80273a:	29 ef                	sub    %ebp,%edi
  80273c:	d3 e0                	shl    %cl,%eax
  80273e:	89 f9                	mov    %edi,%ecx
  802740:	89 f2                	mov    %esi,%edx
  802742:	d3 ea                	shr    %cl,%edx
  802744:	89 e9                	mov    %ebp,%ecx
  802746:	09 c2                	or     %eax,%edx
  802748:	89 d8                	mov    %ebx,%eax
  80274a:	89 14 24             	mov    %edx,(%esp)
  80274d:	89 f2                	mov    %esi,%edx
  80274f:	d3 e2                	shl    %cl,%edx
  802751:	89 f9                	mov    %edi,%ecx
  802753:	89 54 24 04          	mov    %edx,0x4(%esp)
  802757:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80275b:	d3 e8                	shr    %cl,%eax
  80275d:	89 e9                	mov    %ebp,%ecx
  80275f:	89 c6                	mov    %eax,%esi
  802761:	d3 e3                	shl    %cl,%ebx
  802763:	89 f9                	mov    %edi,%ecx
  802765:	89 d0                	mov    %edx,%eax
  802767:	d3 e8                	shr    %cl,%eax
  802769:	89 e9                	mov    %ebp,%ecx
  80276b:	09 d8                	or     %ebx,%eax
  80276d:	89 d3                	mov    %edx,%ebx
  80276f:	89 f2                	mov    %esi,%edx
  802771:	f7 34 24             	divl   (%esp)
  802774:	89 d6                	mov    %edx,%esi
  802776:	d3 e3                	shl    %cl,%ebx
  802778:	f7 64 24 04          	mull   0x4(%esp)
  80277c:	39 d6                	cmp    %edx,%esi
  80277e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802782:	89 d1                	mov    %edx,%ecx
  802784:	89 c3                	mov    %eax,%ebx
  802786:	72 08                	jb     802790 <__umoddi3+0x110>
  802788:	75 11                	jne    80279b <__umoddi3+0x11b>
  80278a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80278e:	73 0b                	jae    80279b <__umoddi3+0x11b>
  802790:	2b 44 24 04          	sub    0x4(%esp),%eax
  802794:	1b 14 24             	sbb    (%esp),%edx
  802797:	89 d1                	mov    %edx,%ecx
  802799:	89 c3                	mov    %eax,%ebx
  80279b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80279f:	29 da                	sub    %ebx,%edx
  8027a1:	19 ce                	sbb    %ecx,%esi
  8027a3:	89 f9                	mov    %edi,%ecx
  8027a5:	89 f0                	mov    %esi,%eax
  8027a7:	d3 e0                	shl    %cl,%eax
  8027a9:	89 e9                	mov    %ebp,%ecx
  8027ab:	d3 ea                	shr    %cl,%edx
  8027ad:	89 e9                	mov    %ebp,%ecx
  8027af:	d3 ee                	shr    %cl,%esi
  8027b1:	09 d0                	or     %edx,%eax
  8027b3:	89 f2                	mov    %esi,%edx
  8027b5:	83 c4 1c             	add    $0x1c,%esp
  8027b8:	5b                   	pop    %ebx
  8027b9:	5e                   	pop    %esi
  8027ba:	5f                   	pop    %edi
  8027bb:	5d                   	pop    %ebp
  8027bc:	c3                   	ret    
  8027bd:	8d 76 00             	lea    0x0(%esi),%esi
  8027c0:	29 f9                	sub    %edi,%ecx
  8027c2:	19 d6                	sbb    %edx,%esi
  8027c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027cc:	e9 18 ff ff ff       	jmp    8026e9 <__umoddi3+0x69>
