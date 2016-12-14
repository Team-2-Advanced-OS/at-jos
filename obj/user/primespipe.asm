
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 07 02 00 00       	call   800238 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	6a 04                	push   $0x4
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	e8 9f 15 00 00       	call   8015f0 <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	74 20                	je     800079 <primeproc+0x46>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  800059:	83 ec 0c             	sub    $0xc,%esp
  80005c:	85 c0                	test   %eax,%eax
  80005e:	ba 00 00 00 00       	mov    $0x0,%edx
  800063:	0f 4e d0             	cmovle %eax,%edx
  800066:	52                   	push   %edx
  800067:	50                   	push   %eax
  800068:	68 40 28 80 00       	push   $0x802840
  80006d:	6a 15                	push   $0x15
  80006f:	68 6f 28 80 00       	push   $0x80286f
  800074:	e8 1f 02 00 00       	call   800298 <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 81 28 80 00       	push   $0x802881
  800084:	e8 e8 02 00 00       	call   800371 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 63 20 00 00       	call   8020f4 <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 85 28 80 00       	push   $0x802885
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 6f 28 80 00       	push   $0x80286f
  8000a8:	e8 eb 01 00 00       	call   800298 <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 f2 0f 00 00       	call   8010a4 <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 c6 2c 80 00       	push   $0x802cc6
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 6f 28 80 00       	push   $0x80286f
  8000c3:	e8 d0 01 00 00       	call   800298 <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 4e 13 00 00       	call   801423 <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 43 13 00 00       	call   801423 <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 2d 13 00 00       	call   801423 <close>
	wfd = pfd[1];
  8000f6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f9:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000fc:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000ff:	83 ec 04             	sub    $0x4,%esp
  800102:	6a 04                	push   $0x4
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
  800106:	e8 e5 14 00 00       	call   8015f0 <readn>
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	83 f8 04             	cmp    $0x4,%eax
  800111:	74 24                	je     800137 <primeproc+0x104>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800113:	83 ec 04             	sub    $0x4,%esp
  800116:	85 c0                	test   %eax,%eax
  800118:	ba 00 00 00 00       	mov    $0x0,%edx
  80011d:	0f 4e d0             	cmovle %eax,%edx
  800120:	52                   	push   %edx
  800121:	50                   	push   %eax
  800122:	53                   	push   %ebx
  800123:	ff 75 e0             	pushl  -0x20(%ebp)
  800126:	68 8e 28 80 00       	push   $0x80288e
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 6f 28 80 00       	push   $0x80286f
  800132:	e8 61 01 00 00       	call   800298 <_panic>
		if (i%p)
  800137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80013a:	99                   	cltd   
  80013b:	f7 7d e0             	idivl  -0x20(%ebp)
  80013e:	85 d2                	test   %edx,%edx
  800140:	74 bd                	je     8000ff <primeproc+0xcc>
			if ((r=write(wfd, &i, 4)) != 4)
  800142:	83 ec 04             	sub    $0x4,%esp
  800145:	6a 04                	push   $0x4
  800147:	56                   	push   %esi
  800148:	57                   	push   %edi
  800149:	e8 eb 14 00 00       	call   801639 <write>
  80014e:	83 c4 10             	add    $0x10,%esp
  800151:	83 f8 04             	cmp    $0x4,%eax
  800154:	74 a9                	je     8000ff <primeproc+0xcc>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  800156:	83 ec 08             	sub    $0x8,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
  800160:	0f 4e d0             	cmovle %eax,%edx
  800163:	52                   	push   %edx
  800164:	50                   	push   %eax
  800165:	ff 75 e0             	pushl  -0x20(%ebp)
  800168:	68 aa 28 80 00       	push   $0x8028aa
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 6f 28 80 00       	push   $0x80286f
  800174:	e8 1f 01 00 00       	call   800298 <_panic>

00800179 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	53                   	push   %ebx
  80017d:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800180:	c7 05 00 30 80 00 c4 	movl   $0x8028c4,0x803000
  800187:	28 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 61 1f 00 00       	call   8020f4 <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 85 28 80 00       	push   $0x802885
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 6f 28 80 00       	push   $0x80286f
  8001aa:	e8 e9 00 00 00       	call   800298 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 f0 0e 00 00       	call   8010a4 <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 c6 2c 80 00       	push   $0x802cc6
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 6f 28 80 00       	push   $0x80286f
  8001c5:	e8 ce 00 00 00       	call   800298 <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 4a 12 00 00       	call   801423 <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 34 12 00 00       	call   801423 <close>

	// feed all the integers through
	for (i=2;; i++)
  8001ef:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f6:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001f9:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001fc:	83 ec 04             	sub    $0x4,%esp
  8001ff:	6a 04                	push   $0x4
  800201:	53                   	push   %ebx
  800202:	ff 75 f0             	pushl  -0x10(%ebp)
  800205:	e8 2f 14 00 00       	call   801639 <write>
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	83 f8 04             	cmp    $0x4,%eax
  800210:	74 20                	je     800232 <umain+0xb9>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	85 c0                	test   %eax,%eax
  800217:	ba 00 00 00 00       	mov    $0x0,%edx
  80021c:	0f 4e d0             	cmovle %eax,%edx
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	68 cf 28 80 00       	push   $0x8028cf
  800226:	6a 4a                	push   $0x4a
  800228:	68 6f 28 80 00       	push   $0x80286f
  80022d:	e8 66 00 00 00       	call   800298 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  800232:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  800236:	eb c4                	jmp    8001fc <umain+0x83>

00800238 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800240:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800243:	e8 73 0a 00 00       	call   800cbb <sys_getenvid>
  800248:	25 ff 03 00 00       	and    $0x3ff,%eax
  80024d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800250:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800255:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80025a:	85 db                	test   %ebx,%ebx
  80025c:	7e 07                	jle    800265 <libmain+0x2d>
		binaryname = argv[0];
  80025e:	8b 06                	mov    (%esi),%eax
  800260:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	e8 0a ff ff ff       	call   800179 <umain>

	// exit gracefully
	exit();
  80026f:	e8 0a 00 00 00       	call   80027e <exit>
}
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800284:	e8 c5 11 00 00       	call   80144e <close_all>
	sys_env_destroy(0);
  800289:	83 ec 0c             	sub    $0xc,%esp
  80028c:	6a 00                	push   $0x0
  80028e:	e8 e7 09 00 00       	call   800c7a <sys_env_destroy>
}
  800293:	83 c4 10             	add    $0x10,%esp
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80029d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002a0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002a6:	e8 10 0a 00 00       	call   800cbb <sys_getenvid>
  8002ab:	83 ec 0c             	sub    $0xc,%esp
  8002ae:	ff 75 0c             	pushl  0xc(%ebp)
  8002b1:	ff 75 08             	pushl  0x8(%ebp)
  8002b4:	56                   	push   %esi
  8002b5:	50                   	push   %eax
  8002b6:	68 f4 28 80 00       	push   $0x8028f4
  8002bb:	e8 b1 00 00 00       	call   800371 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c0:	83 c4 18             	add    $0x18,%esp
  8002c3:	53                   	push   %ebx
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	e8 54 00 00 00       	call   800320 <vcprintf>
	cprintf("\n");
  8002cc:	c7 04 24 83 28 80 00 	movl   $0x802883,(%esp)
  8002d3:	e8 99 00 00 00       	call   800371 <cprintf>
  8002d8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002db:	cc                   	int3   
  8002dc:	eb fd                	jmp    8002db <_panic+0x43>

008002de <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	53                   	push   %ebx
  8002e2:	83 ec 04             	sub    $0x4,%esp
  8002e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e8:	8b 13                	mov    (%ebx),%edx
  8002ea:	8d 42 01             	lea    0x1(%edx),%eax
  8002ed:	89 03                	mov    %eax,(%ebx)
  8002ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002fb:	75 1a                	jne    800317 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002fd:	83 ec 08             	sub    $0x8,%esp
  800300:	68 ff 00 00 00       	push   $0xff
  800305:	8d 43 08             	lea    0x8(%ebx),%eax
  800308:	50                   	push   %eax
  800309:	e8 2f 09 00 00       	call   800c3d <sys_cputs>
		b->idx = 0;
  80030e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800314:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800317:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80031b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800329:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800330:	00 00 00 
	b.cnt = 0;
  800333:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80033a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033d:	ff 75 0c             	pushl  0xc(%ebp)
  800340:	ff 75 08             	pushl  0x8(%ebp)
  800343:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800349:	50                   	push   %eax
  80034a:	68 de 02 80 00       	push   $0x8002de
  80034f:	e8 54 01 00 00       	call   8004a8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800354:	83 c4 08             	add    $0x8,%esp
  800357:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80035d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800363:	50                   	push   %eax
  800364:	e8 d4 08 00 00       	call   800c3d <sys_cputs>

	return b.cnt;
}
  800369:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800377:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80037a:	50                   	push   %eax
  80037b:	ff 75 08             	pushl  0x8(%ebp)
  80037e:	e8 9d ff ff ff       	call   800320 <vcprintf>
	va_end(ap);

	return cnt;
}
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	57                   	push   %edi
  800389:	56                   	push   %esi
  80038a:	53                   	push   %ebx
  80038b:	83 ec 1c             	sub    $0x1c,%esp
  80038e:	89 c7                	mov    %eax,%edi
  800390:	89 d6                	mov    %edx,%esi
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	8b 55 0c             	mov    0xc(%ebp),%edx
  800398:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80039e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003ac:	39 d3                	cmp    %edx,%ebx
  8003ae:	72 05                	jb     8003b5 <printnum+0x30>
  8003b0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003b3:	77 45                	ja     8003fa <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b5:	83 ec 0c             	sub    $0xc,%esp
  8003b8:	ff 75 18             	pushl  0x18(%ebp)
  8003bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003be:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003c1:	53                   	push   %ebx
  8003c2:	ff 75 10             	pushl  0x10(%ebp)
  8003c5:	83 ec 08             	sub    $0x8,%esp
  8003c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d4:	e8 d7 21 00 00       	call   8025b0 <__udivdi3>
  8003d9:	83 c4 18             	add    $0x18,%esp
  8003dc:	52                   	push   %edx
  8003dd:	50                   	push   %eax
  8003de:	89 f2                	mov    %esi,%edx
  8003e0:	89 f8                	mov    %edi,%eax
  8003e2:	e8 9e ff ff ff       	call   800385 <printnum>
  8003e7:	83 c4 20             	add    $0x20,%esp
  8003ea:	eb 18                	jmp    800404 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003ec:	83 ec 08             	sub    $0x8,%esp
  8003ef:	56                   	push   %esi
  8003f0:	ff 75 18             	pushl  0x18(%ebp)
  8003f3:	ff d7                	call   *%edi
  8003f5:	83 c4 10             	add    $0x10,%esp
  8003f8:	eb 03                	jmp    8003fd <printnum+0x78>
  8003fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003fd:	83 eb 01             	sub    $0x1,%ebx
  800400:	85 db                	test   %ebx,%ebx
  800402:	7f e8                	jg     8003ec <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	56                   	push   %esi
  800408:	83 ec 04             	sub    $0x4,%esp
  80040b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80040e:	ff 75 e0             	pushl  -0x20(%ebp)
  800411:	ff 75 dc             	pushl  -0x24(%ebp)
  800414:	ff 75 d8             	pushl  -0x28(%ebp)
  800417:	e8 c4 22 00 00       	call   8026e0 <__umoddi3>
  80041c:	83 c4 14             	add    $0x14,%esp
  80041f:	0f be 80 17 29 80 00 	movsbl 0x802917(%eax),%eax
  800426:	50                   	push   %eax
  800427:	ff d7                	call   *%edi
}
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042f:	5b                   	pop    %ebx
  800430:	5e                   	pop    %esi
  800431:	5f                   	pop    %edi
  800432:	5d                   	pop    %ebp
  800433:	c3                   	ret    

00800434 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800437:	83 fa 01             	cmp    $0x1,%edx
  80043a:	7e 0e                	jle    80044a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80043c:	8b 10                	mov    (%eax),%edx
  80043e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800441:	89 08                	mov    %ecx,(%eax)
  800443:	8b 02                	mov    (%edx),%eax
  800445:	8b 52 04             	mov    0x4(%edx),%edx
  800448:	eb 22                	jmp    80046c <getuint+0x38>
	else if (lflag)
  80044a:	85 d2                	test   %edx,%edx
  80044c:	74 10                	je     80045e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80044e:	8b 10                	mov    (%eax),%edx
  800450:	8d 4a 04             	lea    0x4(%edx),%ecx
  800453:	89 08                	mov    %ecx,(%eax)
  800455:	8b 02                	mov    (%edx),%eax
  800457:	ba 00 00 00 00       	mov    $0x0,%edx
  80045c:	eb 0e                	jmp    80046c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80045e:	8b 10                	mov    (%eax),%edx
  800460:	8d 4a 04             	lea    0x4(%edx),%ecx
  800463:	89 08                	mov    %ecx,(%eax)
  800465:	8b 02                	mov    (%edx),%eax
  800467:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80046c:	5d                   	pop    %ebp
  80046d:	c3                   	ret    

0080046e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800474:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800478:	8b 10                	mov    (%eax),%edx
  80047a:	3b 50 04             	cmp    0x4(%eax),%edx
  80047d:	73 0a                	jae    800489 <sprintputch+0x1b>
		*b->buf++ = ch;
  80047f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800482:	89 08                	mov    %ecx,(%eax)
  800484:	8b 45 08             	mov    0x8(%ebp),%eax
  800487:	88 02                	mov    %al,(%edx)
}
  800489:	5d                   	pop    %ebp
  80048a:	c3                   	ret    

0080048b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80048b:	55                   	push   %ebp
  80048c:	89 e5                	mov    %esp,%ebp
  80048e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800491:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800494:	50                   	push   %eax
  800495:	ff 75 10             	pushl  0x10(%ebp)
  800498:	ff 75 0c             	pushl  0xc(%ebp)
  80049b:	ff 75 08             	pushl  0x8(%ebp)
  80049e:	e8 05 00 00 00       	call   8004a8 <vprintfmt>
	va_end(ap);
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	c9                   	leave  
  8004a7:	c3                   	ret    

008004a8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
  8004ab:	57                   	push   %edi
  8004ac:	56                   	push   %esi
  8004ad:	53                   	push   %ebx
  8004ae:	83 ec 2c             	sub    $0x2c,%esp
  8004b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004ba:	eb 12                	jmp    8004ce <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004bc:	85 c0                	test   %eax,%eax
  8004be:	0f 84 89 03 00 00    	je     80084d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	53                   	push   %ebx
  8004c8:	50                   	push   %eax
  8004c9:	ff d6                	call   *%esi
  8004cb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ce:	83 c7 01             	add    $0x1,%edi
  8004d1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d5:	83 f8 25             	cmp    $0x25,%eax
  8004d8:	75 e2                	jne    8004bc <vprintfmt+0x14>
  8004da:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004de:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004e5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004ec:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f8:	eb 07                	jmp    800501 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004fd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800501:	8d 47 01             	lea    0x1(%edi),%eax
  800504:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800507:	0f b6 07             	movzbl (%edi),%eax
  80050a:	0f b6 c8             	movzbl %al,%ecx
  80050d:	83 e8 23             	sub    $0x23,%eax
  800510:	3c 55                	cmp    $0x55,%al
  800512:	0f 87 1a 03 00 00    	ja     800832 <vprintfmt+0x38a>
  800518:	0f b6 c0             	movzbl %al,%eax
  80051b:	ff 24 85 60 2a 80 00 	jmp    *0x802a60(,%eax,4)
  800522:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800525:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800529:	eb d6                	jmp    800501 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80052e:	b8 00 00 00 00       	mov    $0x0,%eax
  800533:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800536:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800539:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80053d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800540:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800543:	83 fa 09             	cmp    $0x9,%edx
  800546:	77 39                	ja     800581 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800548:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80054b:	eb e9                	jmp    800536 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 48 04             	lea    0x4(%eax),%ecx
  800553:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800556:	8b 00                	mov    (%eax),%eax
  800558:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80055e:	eb 27                	jmp    800587 <vprintfmt+0xdf>
  800560:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800563:	85 c0                	test   %eax,%eax
  800565:	b9 00 00 00 00       	mov    $0x0,%ecx
  80056a:	0f 49 c8             	cmovns %eax,%ecx
  80056d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800570:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800573:	eb 8c                	jmp    800501 <vprintfmt+0x59>
  800575:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800578:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80057f:	eb 80                	jmp    800501 <vprintfmt+0x59>
  800581:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800584:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800587:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058b:	0f 89 70 ff ff ff    	jns    800501 <vprintfmt+0x59>
				width = precision, precision = -1;
  800591:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800594:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800597:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80059e:	e9 5e ff ff ff       	jmp    800501 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005a3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005a9:	e9 53 ff ff ff       	jmp    800501 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 04             	lea    0x4(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	53                   	push   %ebx
  8005bb:	ff 30                	pushl  (%eax)
  8005bd:	ff d6                	call   *%esi
			break;
  8005bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005c5:	e9 04 ff ff ff       	jmp    8004ce <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 04             	lea    0x4(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	99                   	cltd   
  8005d6:	31 d0                	xor    %edx,%eax
  8005d8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005da:	83 f8 0f             	cmp    $0xf,%eax
  8005dd:	7f 0b                	jg     8005ea <vprintfmt+0x142>
  8005df:	8b 14 85 c0 2b 80 00 	mov    0x802bc0(,%eax,4),%edx
  8005e6:	85 d2                	test   %edx,%edx
  8005e8:	75 18                	jne    800602 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8005ea:	50                   	push   %eax
  8005eb:	68 2f 29 80 00       	push   $0x80292f
  8005f0:	53                   	push   %ebx
  8005f1:	56                   	push   %esi
  8005f2:	e8 94 fe ff ff       	call   80048b <printfmt>
  8005f7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005fd:	e9 cc fe ff ff       	jmp    8004ce <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800602:	52                   	push   %edx
  800603:	68 ae 2d 80 00       	push   $0x802dae
  800608:	53                   	push   %ebx
  800609:	56                   	push   %esi
  80060a:	e8 7c fe ff ff       	call   80048b <printfmt>
  80060f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800612:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800615:	e9 b4 fe ff ff       	jmp    8004ce <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 50 04             	lea    0x4(%eax),%edx
  800620:	89 55 14             	mov    %edx,0x14(%ebp)
  800623:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800625:	85 ff                	test   %edi,%edi
  800627:	b8 28 29 80 00       	mov    $0x802928,%eax
  80062c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80062f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800633:	0f 8e 94 00 00 00    	jle    8006cd <vprintfmt+0x225>
  800639:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80063d:	0f 84 98 00 00 00    	je     8006db <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	ff 75 d0             	pushl  -0x30(%ebp)
  800649:	57                   	push   %edi
  80064a:	e8 86 02 00 00       	call   8008d5 <strnlen>
  80064f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800652:	29 c1                	sub    %eax,%ecx
  800654:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800657:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80065a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80065e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800661:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800664:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800666:	eb 0f                	jmp    800677 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	ff 75 e0             	pushl  -0x20(%ebp)
  80066f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800671:	83 ef 01             	sub    $0x1,%edi
  800674:	83 c4 10             	add    $0x10,%esp
  800677:	85 ff                	test   %edi,%edi
  800679:	7f ed                	jg     800668 <vprintfmt+0x1c0>
  80067b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80067e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800681:	85 c9                	test   %ecx,%ecx
  800683:	b8 00 00 00 00       	mov    $0x0,%eax
  800688:	0f 49 c1             	cmovns %ecx,%eax
  80068b:	29 c1                	sub    %eax,%ecx
  80068d:	89 75 08             	mov    %esi,0x8(%ebp)
  800690:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800693:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800696:	89 cb                	mov    %ecx,%ebx
  800698:	eb 4d                	jmp    8006e7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80069a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80069e:	74 1b                	je     8006bb <vprintfmt+0x213>
  8006a0:	0f be c0             	movsbl %al,%eax
  8006a3:	83 e8 20             	sub    $0x20,%eax
  8006a6:	83 f8 5e             	cmp    $0x5e,%eax
  8006a9:	76 10                	jbe    8006bb <vprintfmt+0x213>
					putch('?', putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	ff 75 0c             	pushl  0xc(%ebp)
  8006b1:	6a 3f                	push   $0x3f
  8006b3:	ff 55 08             	call   *0x8(%ebp)
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	eb 0d                	jmp    8006c8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	ff 75 0c             	pushl  0xc(%ebp)
  8006c1:	52                   	push   %edx
  8006c2:	ff 55 08             	call   *0x8(%ebp)
  8006c5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c8:	83 eb 01             	sub    $0x1,%ebx
  8006cb:	eb 1a                	jmp    8006e7 <vprintfmt+0x23f>
  8006cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8006d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006d6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006d9:	eb 0c                	jmp    8006e7 <vprintfmt+0x23f>
  8006db:	89 75 08             	mov    %esi,0x8(%ebp)
  8006de:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006e7:	83 c7 01             	add    $0x1,%edi
  8006ea:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ee:	0f be d0             	movsbl %al,%edx
  8006f1:	85 d2                	test   %edx,%edx
  8006f3:	74 23                	je     800718 <vprintfmt+0x270>
  8006f5:	85 f6                	test   %esi,%esi
  8006f7:	78 a1                	js     80069a <vprintfmt+0x1f2>
  8006f9:	83 ee 01             	sub    $0x1,%esi
  8006fc:	79 9c                	jns    80069a <vprintfmt+0x1f2>
  8006fe:	89 df                	mov    %ebx,%edi
  800700:	8b 75 08             	mov    0x8(%ebp),%esi
  800703:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800706:	eb 18                	jmp    800720 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	53                   	push   %ebx
  80070c:	6a 20                	push   $0x20
  80070e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800710:	83 ef 01             	sub    $0x1,%edi
  800713:	83 c4 10             	add    $0x10,%esp
  800716:	eb 08                	jmp    800720 <vprintfmt+0x278>
  800718:	89 df                	mov    %ebx,%edi
  80071a:	8b 75 08             	mov    0x8(%ebp),%esi
  80071d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800720:	85 ff                	test   %edi,%edi
  800722:	7f e4                	jg     800708 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800724:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800727:	e9 a2 fd ff ff       	jmp    8004ce <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80072c:	83 fa 01             	cmp    $0x1,%edx
  80072f:	7e 16                	jle    800747 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8d 50 08             	lea    0x8(%eax),%edx
  800737:	89 55 14             	mov    %edx,0x14(%ebp)
  80073a:	8b 50 04             	mov    0x4(%eax),%edx
  80073d:	8b 00                	mov    (%eax),%eax
  80073f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800742:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800745:	eb 32                	jmp    800779 <vprintfmt+0x2d1>
	else if (lflag)
  800747:	85 d2                	test   %edx,%edx
  800749:	74 18                	je     800763 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80074b:	8b 45 14             	mov    0x14(%ebp),%eax
  80074e:	8d 50 04             	lea    0x4(%eax),%edx
  800751:	89 55 14             	mov    %edx,0x14(%ebp)
  800754:	8b 00                	mov    (%eax),%eax
  800756:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800759:	89 c1                	mov    %eax,%ecx
  80075b:	c1 f9 1f             	sar    $0x1f,%ecx
  80075e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800761:	eb 16                	jmp    800779 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8d 50 04             	lea    0x4(%eax),%edx
  800769:	89 55 14             	mov    %edx,0x14(%ebp)
  80076c:	8b 00                	mov    (%eax),%eax
  80076e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800771:	89 c1                	mov    %eax,%ecx
  800773:	c1 f9 1f             	sar    $0x1f,%ecx
  800776:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800779:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80077c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80077f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800784:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800788:	79 74                	jns    8007fe <vprintfmt+0x356>
				putch('-', putdat);
  80078a:	83 ec 08             	sub    $0x8,%esp
  80078d:	53                   	push   %ebx
  80078e:	6a 2d                	push   $0x2d
  800790:	ff d6                	call   *%esi
				num = -(long long) num;
  800792:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800795:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800798:	f7 d8                	neg    %eax
  80079a:	83 d2 00             	adc    $0x0,%edx
  80079d:	f7 da                	neg    %edx
  80079f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007a2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007a7:	eb 55                	jmp    8007fe <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007a9:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ac:	e8 83 fc ff ff       	call   800434 <getuint>
			base = 10;
  8007b1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007b6:	eb 46                	jmp    8007fe <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007b8:	8d 45 14             	lea    0x14(%ebp),%eax
  8007bb:	e8 74 fc ff ff       	call   800434 <getuint>
                        base = 8;
  8007c0:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8007c5:	eb 37                	jmp    8007fe <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8007c7:	83 ec 08             	sub    $0x8,%esp
  8007ca:	53                   	push   %ebx
  8007cb:	6a 30                	push   $0x30
  8007cd:	ff d6                	call   *%esi
			putch('x', putdat);
  8007cf:	83 c4 08             	add    $0x8,%esp
  8007d2:	53                   	push   %ebx
  8007d3:	6a 78                	push   $0x78
  8007d5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	8d 50 04             	lea    0x4(%eax),%edx
  8007dd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007e0:	8b 00                	mov    (%eax),%eax
  8007e2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007e7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007ea:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007ef:	eb 0d                	jmp    8007fe <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f4:	e8 3b fc ff ff       	call   800434 <getuint>
			base = 16;
  8007f9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007fe:	83 ec 0c             	sub    $0xc,%esp
  800801:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800805:	57                   	push   %edi
  800806:	ff 75 e0             	pushl  -0x20(%ebp)
  800809:	51                   	push   %ecx
  80080a:	52                   	push   %edx
  80080b:	50                   	push   %eax
  80080c:	89 da                	mov    %ebx,%edx
  80080e:	89 f0                	mov    %esi,%eax
  800810:	e8 70 fb ff ff       	call   800385 <printnum>
			break;
  800815:	83 c4 20             	add    $0x20,%esp
  800818:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80081b:	e9 ae fc ff ff       	jmp    8004ce <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800820:	83 ec 08             	sub    $0x8,%esp
  800823:	53                   	push   %ebx
  800824:	51                   	push   %ecx
  800825:	ff d6                	call   *%esi
			break;
  800827:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80082d:	e9 9c fc ff ff       	jmp    8004ce <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800832:	83 ec 08             	sub    $0x8,%esp
  800835:	53                   	push   %ebx
  800836:	6a 25                	push   $0x25
  800838:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	eb 03                	jmp    800842 <vprintfmt+0x39a>
  80083f:	83 ef 01             	sub    $0x1,%edi
  800842:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800846:	75 f7                	jne    80083f <vprintfmt+0x397>
  800848:	e9 81 fc ff ff       	jmp    8004ce <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80084d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800850:	5b                   	pop    %ebx
  800851:	5e                   	pop    %esi
  800852:	5f                   	pop    %edi
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	83 ec 18             	sub    $0x18,%esp
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800861:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800864:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800868:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80086b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800872:	85 c0                	test   %eax,%eax
  800874:	74 26                	je     80089c <vsnprintf+0x47>
  800876:	85 d2                	test   %edx,%edx
  800878:	7e 22                	jle    80089c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80087a:	ff 75 14             	pushl  0x14(%ebp)
  80087d:	ff 75 10             	pushl  0x10(%ebp)
  800880:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800883:	50                   	push   %eax
  800884:	68 6e 04 80 00       	push   $0x80046e
  800889:	e8 1a fc ff ff       	call   8004a8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80088e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800891:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800894:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800897:	83 c4 10             	add    $0x10,%esp
  80089a:	eb 05                	jmp    8008a1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80089c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008a1:	c9                   	leave  
  8008a2:	c3                   	ret    

008008a3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ac:	50                   	push   %eax
  8008ad:	ff 75 10             	pushl  0x10(%ebp)
  8008b0:	ff 75 0c             	pushl  0xc(%ebp)
  8008b3:	ff 75 08             	pushl  0x8(%ebp)
  8008b6:	e8 9a ff ff ff       	call   800855 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c8:	eb 03                	jmp    8008cd <strlen+0x10>
		n++;
  8008ca:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008cd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d1:	75 f7                	jne    8008ca <strlen+0xd>
		n++;
	return n;
}
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008db:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008de:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e3:	eb 03                	jmp    8008e8 <strnlen+0x13>
		n++;
  8008e5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e8:	39 c2                	cmp    %eax,%edx
  8008ea:	74 08                	je     8008f4 <strnlen+0x1f>
  8008ec:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008f0:	75 f3                	jne    8008e5 <strnlen+0x10>
  8008f2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	53                   	push   %ebx
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800900:	89 c2                	mov    %eax,%edx
  800902:	83 c2 01             	add    $0x1,%edx
  800905:	83 c1 01             	add    $0x1,%ecx
  800908:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80090c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80090f:	84 db                	test   %bl,%bl
  800911:	75 ef                	jne    800902 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800913:	5b                   	pop    %ebx
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	53                   	push   %ebx
  80091a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80091d:	53                   	push   %ebx
  80091e:	e8 9a ff ff ff       	call   8008bd <strlen>
  800923:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800926:	ff 75 0c             	pushl  0xc(%ebp)
  800929:	01 d8                	add    %ebx,%eax
  80092b:	50                   	push   %eax
  80092c:	e8 c5 ff ff ff       	call   8008f6 <strcpy>
	return dst;
}
  800931:	89 d8                	mov    %ebx,%eax
  800933:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800936:	c9                   	leave  
  800937:	c3                   	ret    

00800938 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	8b 75 08             	mov    0x8(%ebp),%esi
  800940:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800943:	89 f3                	mov    %esi,%ebx
  800945:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800948:	89 f2                	mov    %esi,%edx
  80094a:	eb 0f                	jmp    80095b <strncpy+0x23>
		*dst++ = *src;
  80094c:	83 c2 01             	add    $0x1,%edx
  80094f:	0f b6 01             	movzbl (%ecx),%eax
  800952:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800955:	80 39 01             	cmpb   $0x1,(%ecx)
  800958:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80095b:	39 da                	cmp    %ebx,%edx
  80095d:	75 ed                	jne    80094c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80095f:	89 f0                	mov    %esi,%eax
  800961:	5b                   	pop    %ebx
  800962:	5e                   	pop    %esi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	56                   	push   %esi
  800969:	53                   	push   %ebx
  80096a:	8b 75 08             	mov    0x8(%ebp),%esi
  80096d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800970:	8b 55 10             	mov    0x10(%ebp),%edx
  800973:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800975:	85 d2                	test   %edx,%edx
  800977:	74 21                	je     80099a <strlcpy+0x35>
  800979:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80097d:	89 f2                	mov    %esi,%edx
  80097f:	eb 09                	jmp    80098a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800981:	83 c2 01             	add    $0x1,%edx
  800984:	83 c1 01             	add    $0x1,%ecx
  800987:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80098a:	39 c2                	cmp    %eax,%edx
  80098c:	74 09                	je     800997 <strlcpy+0x32>
  80098e:	0f b6 19             	movzbl (%ecx),%ebx
  800991:	84 db                	test   %bl,%bl
  800993:	75 ec                	jne    800981 <strlcpy+0x1c>
  800995:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800997:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80099a:	29 f0                	sub    %esi,%eax
}
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a9:	eb 06                	jmp    8009b1 <strcmp+0x11>
		p++, q++;
  8009ab:	83 c1 01             	add    $0x1,%ecx
  8009ae:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009b1:	0f b6 01             	movzbl (%ecx),%eax
  8009b4:	84 c0                	test   %al,%al
  8009b6:	74 04                	je     8009bc <strcmp+0x1c>
  8009b8:	3a 02                	cmp    (%edx),%al
  8009ba:	74 ef                	je     8009ab <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009bc:	0f b6 c0             	movzbl %al,%eax
  8009bf:	0f b6 12             	movzbl (%edx),%edx
  8009c2:	29 d0                	sub    %edx,%eax
}
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	53                   	push   %ebx
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d0:	89 c3                	mov    %eax,%ebx
  8009d2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009d5:	eb 06                	jmp    8009dd <strncmp+0x17>
		n--, p++, q++;
  8009d7:	83 c0 01             	add    $0x1,%eax
  8009da:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009dd:	39 d8                	cmp    %ebx,%eax
  8009df:	74 15                	je     8009f6 <strncmp+0x30>
  8009e1:	0f b6 08             	movzbl (%eax),%ecx
  8009e4:	84 c9                	test   %cl,%cl
  8009e6:	74 04                	je     8009ec <strncmp+0x26>
  8009e8:	3a 0a                	cmp    (%edx),%cl
  8009ea:	74 eb                	je     8009d7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ec:	0f b6 00             	movzbl (%eax),%eax
  8009ef:	0f b6 12             	movzbl (%edx),%edx
  8009f2:	29 d0                	sub    %edx,%eax
  8009f4:	eb 05                	jmp    8009fb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009fb:	5b                   	pop    %ebx
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
  800a04:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a08:	eb 07                	jmp    800a11 <strchr+0x13>
		if (*s == c)
  800a0a:	38 ca                	cmp    %cl,%dl
  800a0c:	74 0f                	je     800a1d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a0e:	83 c0 01             	add    $0x1,%eax
  800a11:	0f b6 10             	movzbl (%eax),%edx
  800a14:	84 d2                	test   %dl,%dl
  800a16:	75 f2                	jne    800a0a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a29:	eb 03                	jmp    800a2e <strfind+0xf>
  800a2b:	83 c0 01             	add    $0x1,%eax
  800a2e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a31:	38 ca                	cmp    %cl,%dl
  800a33:	74 04                	je     800a39 <strfind+0x1a>
  800a35:	84 d2                	test   %dl,%dl
  800a37:	75 f2                	jne    800a2b <strfind+0xc>
			break;
	return (char *) s;
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	57                   	push   %edi
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
  800a41:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a44:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a47:	85 c9                	test   %ecx,%ecx
  800a49:	74 36                	je     800a81 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a51:	75 28                	jne    800a7b <memset+0x40>
  800a53:	f6 c1 03             	test   $0x3,%cl
  800a56:	75 23                	jne    800a7b <memset+0x40>
		c &= 0xFF;
  800a58:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a5c:	89 d3                	mov    %edx,%ebx
  800a5e:	c1 e3 08             	shl    $0x8,%ebx
  800a61:	89 d6                	mov    %edx,%esi
  800a63:	c1 e6 18             	shl    $0x18,%esi
  800a66:	89 d0                	mov    %edx,%eax
  800a68:	c1 e0 10             	shl    $0x10,%eax
  800a6b:	09 f0                	or     %esi,%eax
  800a6d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a6f:	89 d8                	mov    %ebx,%eax
  800a71:	09 d0                	or     %edx,%eax
  800a73:	c1 e9 02             	shr    $0x2,%ecx
  800a76:	fc                   	cld    
  800a77:	f3 ab                	rep stos %eax,%es:(%edi)
  800a79:	eb 06                	jmp    800a81 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7e:	fc                   	cld    
  800a7f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a81:	89 f8                	mov    %edi,%eax
  800a83:	5b                   	pop    %ebx
  800a84:	5e                   	pop    %esi
  800a85:	5f                   	pop    %edi
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	57                   	push   %edi
  800a8c:	56                   	push   %esi
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a93:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a96:	39 c6                	cmp    %eax,%esi
  800a98:	73 35                	jae    800acf <memmove+0x47>
  800a9a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a9d:	39 d0                	cmp    %edx,%eax
  800a9f:	73 2e                	jae    800acf <memmove+0x47>
		s += n;
		d += n;
  800aa1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa4:	89 d6                	mov    %edx,%esi
  800aa6:	09 fe                	or     %edi,%esi
  800aa8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aae:	75 13                	jne    800ac3 <memmove+0x3b>
  800ab0:	f6 c1 03             	test   $0x3,%cl
  800ab3:	75 0e                	jne    800ac3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ab5:	83 ef 04             	sub    $0x4,%edi
  800ab8:	8d 72 fc             	lea    -0x4(%edx),%esi
  800abb:	c1 e9 02             	shr    $0x2,%ecx
  800abe:	fd                   	std    
  800abf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac1:	eb 09                	jmp    800acc <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ac3:	83 ef 01             	sub    $0x1,%edi
  800ac6:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ac9:	fd                   	std    
  800aca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800acc:	fc                   	cld    
  800acd:	eb 1d                	jmp    800aec <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800acf:	89 f2                	mov    %esi,%edx
  800ad1:	09 c2                	or     %eax,%edx
  800ad3:	f6 c2 03             	test   $0x3,%dl
  800ad6:	75 0f                	jne    800ae7 <memmove+0x5f>
  800ad8:	f6 c1 03             	test   $0x3,%cl
  800adb:	75 0a                	jne    800ae7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800add:	c1 e9 02             	shr    $0x2,%ecx
  800ae0:	89 c7                	mov    %eax,%edi
  800ae2:	fc                   	cld    
  800ae3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae5:	eb 05                	jmp    800aec <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ae7:	89 c7                	mov    %eax,%edi
  800ae9:	fc                   	cld    
  800aea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aec:	5e                   	pop    %esi
  800aed:	5f                   	pop    %edi
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800af3:	ff 75 10             	pushl  0x10(%ebp)
  800af6:	ff 75 0c             	pushl  0xc(%ebp)
  800af9:	ff 75 08             	pushl  0x8(%ebp)
  800afc:	e8 87 ff ff ff       	call   800a88 <memmove>
}
  800b01:	c9                   	leave  
  800b02:	c3                   	ret    

00800b03 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0e:	89 c6                	mov    %eax,%esi
  800b10:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b13:	eb 1a                	jmp    800b2f <memcmp+0x2c>
		if (*s1 != *s2)
  800b15:	0f b6 08             	movzbl (%eax),%ecx
  800b18:	0f b6 1a             	movzbl (%edx),%ebx
  800b1b:	38 d9                	cmp    %bl,%cl
  800b1d:	74 0a                	je     800b29 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b1f:	0f b6 c1             	movzbl %cl,%eax
  800b22:	0f b6 db             	movzbl %bl,%ebx
  800b25:	29 d8                	sub    %ebx,%eax
  800b27:	eb 0f                	jmp    800b38 <memcmp+0x35>
		s1++, s2++;
  800b29:	83 c0 01             	add    $0x1,%eax
  800b2c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2f:	39 f0                	cmp    %esi,%eax
  800b31:	75 e2                	jne    800b15 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	53                   	push   %ebx
  800b40:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b43:	89 c1                	mov    %eax,%ecx
  800b45:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b48:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b4c:	eb 0a                	jmp    800b58 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b4e:	0f b6 10             	movzbl (%eax),%edx
  800b51:	39 da                	cmp    %ebx,%edx
  800b53:	74 07                	je     800b5c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b55:	83 c0 01             	add    $0x1,%eax
  800b58:	39 c8                	cmp    %ecx,%eax
  800b5a:	72 f2                	jb     800b4e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6b:	eb 03                	jmp    800b70 <strtol+0x11>
		s++;
  800b6d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b70:	0f b6 01             	movzbl (%ecx),%eax
  800b73:	3c 20                	cmp    $0x20,%al
  800b75:	74 f6                	je     800b6d <strtol+0xe>
  800b77:	3c 09                	cmp    $0x9,%al
  800b79:	74 f2                	je     800b6d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b7b:	3c 2b                	cmp    $0x2b,%al
  800b7d:	75 0a                	jne    800b89 <strtol+0x2a>
		s++;
  800b7f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b82:	bf 00 00 00 00       	mov    $0x0,%edi
  800b87:	eb 11                	jmp    800b9a <strtol+0x3b>
  800b89:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b8e:	3c 2d                	cmp    $0x2d,%al
  800b90:	75 08                	jne    800b9a <strtol+0x3b>
		s++, neg = 1;
  800b92:	83 c1 01             	add    $0x1,%ecx
  800b95:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b9a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ba0:	75 15                	jne    800bb7 <strtol+0x58>
  800ba2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ba5:	75 10                	jne    800bb7 <strtol+0x58>
  800ba7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bab:	75 7c                	jne    800c29 <strtol+0xca>
		s += 2, base = 16;
  800bad:	83 c1 02             	add    $0x2,%ecx
  800bb0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bb5:	eb 16                	jmp    800bcd <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bb7:	85 db                	test   %ebx,%ebx
  800bb9:	75 12                	jne    800bcd <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bbb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc0:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc3:	75 08                	jne    800bcd <strtol+0x6e>
		s++, base = 8;
  800bc5:	83 c1 01             	add    $0x1,%ecx
  800bc8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bd5:	0f b6 11             	movzbl (%ecx),%edx
  800bd8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bdb:	89 f3                	mov    %esi,%ebx
  800bdd:	80 fb 09             	cmp    $0x9,%bl
  800be0:	77 08                	ja     800bea <strtol+0x8b>
			dig = *s - '0';
  800be2:	0f be d2             	movsbl %dl,%edx
  800be5:	83 ea 30             	sub    $0x30,%edx
  800be8:	eb 22                	jmp    800c0c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bea:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bed:	89 f3                	mov    %esi,%ebx
  800bef:	80 fb 19             	cmp    $0x19,%bl
  800bf2:	77 08                	ja     800bfc <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bf4:	0f be d2             	movsbl %dl,%edx
  800bf7:	83 ea 57             	sub    $0x57,%edx
  800bfa:	eb 10                	jmp    800c0c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bfc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bff:	89 f3                	mov    %esi,%ebx
  800c01:	80 fb 19             	cmp    $0x19,%bl
  800c04:	77 16                	ja     800c1c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c06:	0f be d2             	movsbl %dl,%edx
  800c09:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c0c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c0f:	7d 0b                	jge    800c1c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c11:	83 c1 01             	add    $0x1,%ecx
  800c14:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c18:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c1a:	eb b9                	jmp    800bd5 <strtol+0x76>

	if (endptr)
  800c1c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c20:	74 0d                	je     800c2f <strtol+0xd0>
		*endptr = (char *) s;
  800c22:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c25:	89 0e                	mov    %ecx,(%esi)
  800c27:	eb 06                	jmp    800c2f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c29:	85 db                	test   %ebx,%ebx
  800c2b:	74 98                	je     800bc5 <strtol+0x66>
  800c2d:	eb 9e                	jmp    800bcd <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c2f:	89 c2                	mov    %eax,%edx
  800c31:	f7 da                	neg    %edx
  800c33:	85 ff                	test   %edi,%edi
  800c35:	0f 45 c2             	cmovne %edx,%eax
}
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c43:	b8 00 00 00 00       	mov    $0x0,%eax
  800c48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4e:	89 c3                	mov    %eax,%ebx
  800c50:	89 c7                	mov    %eax,%edi
  800c52:	89 c6                	mov    %eax,%esi
  800c54:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <sys_cgetc>:

int
sys_cgetc(void)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c61:	ba 00 00 00 00       	mov    $0x0,%edx
  800c66:	b8 01 00 00 00       	mov    $0x1,%eax
  800c6b:	89 d1                	mov    %edx,%ecx
  800c6d:	89 d3                	mov    %edx,%ebx
  800c6f:	89 d7                	mov    %edx,%edi
  800c71:	89 d6                	mov    %edx,%esi
  800c73:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
  800c80:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c88:	b8 03 00 00 00       	mov    $0x3,%eax
  800c8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c90:	89 cb                	mov    %ecx,%ebx
  800c92:	89 cf                	mov    %ecx,%edi
  800c94:	89 ce                	mov    %ecx,%esi
  800c96:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c98:	85 c0                	test   %eax,%eax
  800c9a:	7e 17                	jle    800cb3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9c:	83 ec 0c             	sub    $0xc,%esp
  800c9f:	50                   	push   %eax
  800ca0:	6a 03                	push   $0x3
  800ca2:	68 1f 2c 80 00       	push   $0x802c1f
  800ca7:	6a 23                	push   $0x23
  800ca9:	68 3c 2c 80 00       	push   $0x802c3c
  800cae:	e8 e5 f5 ff ff       	call   800298 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb6:	5b                   	pop    %ebx
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc1:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc6:	b8 02 00 00 00       	mov    $0x2,%eax
  800ccb:	89 d1                	mov    %edx,%ecx
  800ccd:	89 d3                	mov    %edx,%ebx
  800ccf:	89 d7                	mov    %edx,%edi
  800cd1:	89 d6                	mov    %edx,%esi
  800cd3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_yield>:

void
sys_yield(void)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cea:	89 d1                	mov    %edx,%ecx
  800cec:	89 d3                	mov    %edx,%ebx
  800cee:	89 d7                	mov    %edx,%edi
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800d02:	be 00 00 00 00       	mov    $0x0,%esi
  800d07:	b8 04 00 00 00       	mov    $0x4,%eax
  800d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d15:	89 f7                	mov    %esi,%edi
  800d17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	7e 17                	jle    800d34 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1d:	83 ec 0c             	sub    $0xc,%esp
  800d20:	50                   	push   %eax
  800d21:	6a 04                	push   $0x4
  800d23:	68 1f 2c 80 00       	push   $0x802c1f
  800d28:	6a 23                	push   $0x23
  800d2a:	68 3c 2c 80 00       	push   $0x802c3c
  800d2f:	e8 64 f5 ff ff       	call   800298 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
  800d42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d45:	b8 05 00 00 00       	mov    $0x5,%eax
  800d4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d50:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d53:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d56:	8b 75 18             	mov    0x18(%ebp),%esi
  800d59:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	7e 17                	jle    800d76 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5f:	83 ec 0c             	sub    $0xc,%esp
  800d62:	50                   	push   %eax
  800d63:	6a 05                	push   $0x5
  800d65:	68 1f 2c 80 00       	push   $0x802c1f
  800d6a:	6a 23                	push   $0x23
  800d6c:	68 3c 2c 80 00       	push   $0x802c3c
  800d71:	e8 22 f5 ff ff       	call   800298 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
  800d84:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d87:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8c:	b8 06 00 00 00       	mov    $0x6,%eax
  800d91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d94:	8b 55 08             	mov    0x8(%ebp),%edx
  800d97:	89 df                	mov    %ebx,%edi
  800d99:	89 de                	mov    %ebx,%esi
  800d9b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	7e 17                	jle    800db8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da1:	83 ec 0c             	sub    $0xc,%esp
  800da4:	50                   	push   %eax
  800da5:	6a 06                	push   $0x6
  800da7:	68 1f 2c 80 00       	push   $0x802c1f
  800dac:	6a 23                	push   $0x23
  800dae:	68 3c 2c 80 00       	push   $0x802c3c
  800db3:	e8 e0 f4 ff ff       	call   800298 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800db8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
  800dc6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dce:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd9:	89 df                	mov    %ebx,%edi
  800ddb:	89 de                	mov    %ebx,%esi
  800ddd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	7e 17                	jle    800dfa <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de3:	83 ec 0c             	sub    $0xc,%esp
  800de6:	50                   	push   %eax
  800de7:	6a 08                	push   $0x8
  800de9:	68 1f 2c 80 00       	push   $0x802c1f
  800dee:	6a 23                	push   $0x23
  800df0:	68 3c 2c 80 00       	push   $0x802c3c
  800df5:	e8 9e f4 ff ff       	call   800298 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5f                   	pop    %edi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
  800e08:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e10:	b8 09 00 00 00       	mov    $0x9,%eax
  800e15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	89 df                	mov    %ebx,%edi
  800e1d:	89 de                	mov    %ebx,%esi
  800e1f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e21:	85 c0                	test   %eax,%eax
  800e23:	7e 17                	jle    800e3c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e25:	83 ec 0c             	sub    $0xc,%esp
  800e28:	50                   	push   %eax
  800e29:	6a 09                	push   $0x9
  800e2b:	68 1f 2c 80 00       	push   $0x802c1f
  800e30:	6a 23                	push   $0x23
  800e32:	68 3c 2c 80 00       	push   $0x802c3c
  800e37:	e8 5c f4 ff ff       	call   800298 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3f:	5b                   	pop    %ebx
  800e40:	5e                   	pop    %esi
  800e41:	5f                   	pop    %edi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	57                   	push   %edi
  800e48:	56                   	push   %esi
  800e49:	53                   	push   %ebx
  800e4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e52:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5d:	89 df                	mov    %ebx,%edi
  800e5f:	89 de                	mov    %ebx,%esi
  800e61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e63:	85 c0                	test   %eax,%eax
  800e65:	7e 17                	jle    800e7e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e67:	83 ec 0c             	sub    $0xc,%esp
  800e6a:	50                   	push   %eax
  800e6b:	6a 0a                	push   $0xa
  800e6d:	68 1f 2c 80 00       	push   $0x802c1f
  800e72:	6a 23                	push   $0x23
  800e74:	68 3c 2c 80 00       	push   $0x802c3c
  800e79:	e8 1a f4 ff ff       	call   800298 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	57                   	push   %edi
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8c:	be 00 00 00 00       	mov    $0x0,%esi
  800e91:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e99:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ea2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	57                   	push   %edi
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
  800eaf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ebc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebf:	89 cb                	mov    %ecx,%ebx
  800ec1:	89 cf                	mov    %ecx,%edi
  800ec3:	89 ce                	mov    %ecx,%esi
  800ec5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	7e 17                	jle    800ee2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecb:	83 ec 0c             	sub    $0xc,%esp
  800ece:	50                   	push   %eax
  800ecf:	6a 0d                	push   $0xd
  800ed1:	68 1f 2c 80 00       	push   $0x802c1f
  800ed6:	6a 23                	push   $0x23
  800ed8:	68 3c 2c 80 00       	push   $0x802c3c
  800edd:	e8 b6 f3 ff ff       	call   800298 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ee2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee5:	5b                   	pop    %ebx
  800ee6:	5e                   	pop    %esi
  800ee7:	5f                   	pop    %edi
  800ee8:	5d                   	pop    %ebp
  800ee9:	c3                   	ret    

00800eea <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	57                   	push   %edi
  800eee:	56                   	push   %esi
  800eef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef5:	b8 0e 00 00 00       	mov    $0xe,%eax
  800efa:	89 d1                	mov    %edx,%ecx
  800efc:	89 d3                	mov    %edx,%ebx
  800efe:	89 d7                	mov    %edx,%edi
  800f00:	89 d6                	mov    %edx,%esi
  800f02:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f04:	5b                   	pop    %ebx
  800f05:	5e                   	pop    %esi
  800f06:	5f                   	pop    %edi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    

00800f09 <sys_transmit_packet>:

int
sys_transmit_packet(void *buf, size_t size)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	57                   	push   %edi
  800f0d:	56                   	push   %esi
  800f0e:	53                   	push   %ebx
  800f0f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f12:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f17:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f22:	89 df                	mov    %ebx,%edi
  800f24:	89 de                	mov    %ebx,%esi
  800f26:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f28:	85 c0                	test   %eax,%eax
  800f2a:	7e 17                	jle    800f43 <sys_transmit_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2c:	83 ec 0c             	sub    $0xc,%esp
  800f2f:	50                   	push   %eax
  800f30:	6a 0f                	push   $0xf
  800f32:	68 1f 2c 80 00       	push   $0x802c1f
  800f37:	6a 23                	push   $0x23
  800f39:	68 3c 2c 80 00       	push   $0x802c3c
  800f3e:	e8 55 f3 ff ff       	call   800298 <_panic>
int
sys_transmit_packet(void *buf, size_t size)
{
	return syscall(SYS_transmit_packet, 1,
		(uint32_t) buf, (uint32_t) size, 0, 0, 0);
}
  800f43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f46:	5b                   	pop    %ebx
  800f47:	5e                   	pop    %esi
  800f48:	5f                   	pop    %edi
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    

00800f4b <sys_receive_packet>:

int
sys_receive_packet(void *buf, size_t *size_store)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	57                   	push   %edi
  800f4f:	56                   	push   %esi
  800f50:	53                   	push   %ebx
  800f51:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f54:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f59:	b8 10 00 00 00       	mov    $0x10,%eax
  800f5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f61:	8b 55 08             	mov    0x8(%ebp),%edx
  800f64:	89 df                	mov    %ebx,%edi
  800f66:	89 de                	mov    %ebx,%esi
  800f68:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	7e 17                	jle    800f85 <sys_receive_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6e:	83 ec 0c             	sub    $0xc,%esp
  800f71:	50                   	push   %eax
  800f72:	6a 10                	push   $0x10
  800f74:	68 1f 2c 80 00       	push   $0x802c1f
  800f79:	6a 23                	push   $0x23
  800f7b:	68 3c 2c 80 00       	push   $0x802c3c
  800f80:	e8 13 f3 ff ff       	call   800298 <_panic>
int
sys_receive_packet(void *buf, size_t *size_store)
{
	return syscall(SYS_receive_packet, 1,
		(uint32_t) buf, (uint32_t) size_store, 0, 0, 0);
}
  800f85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <sys_get_mac_address>:

int
sys_get_mac_address(void *buf)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	57                   	push   %edi
  800f91:	56                   	push   %esi
  800f92:	53                   	push   %ebx
  800f93:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f96:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f9b:	b8 11 00 00 00       	mov    $0x11,%eax
  800fa0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa3:	89 cb                	mov    %ecx,%ebx
  800fa5:	89 cf                	mov    %ecx,%edi
  800fa7:	89 ce                	mov    %ecx,%esi
  800fa9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fab:	85 c0                	test   %eax,%eax
  800fad:	7e 17                	jle    800fc6 <sys_get_mac_address+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800faf:	83 ec 0c             	sub    $0xc,%esp
  800fb2:	50                   	push   %eax
  800fb3:	6a 11                	push   $0x11
  800fb5:	68 1f 2c 80 00       	push   $0x802c1f
  800fba:	6a 23                	push   $0x23
  800fbc:	68 3c 2c 80 00       	push   $0x802c3c
  800fc1:	e8 d2 f2 ff ff       	call   800298 <_panic>
int
sys_get_mac_address(void *buf)
{
	return syscall(SYS_get_mac_address, 1,
		(uint32_t) buf, 0, 0, 0, 0);
}
  800fc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc9:	5b                   	pop    %ebx
  800fca:	5e                   	pop    %esi
  800fcb:	5f                   	pop    %edi
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    

00800fce <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	53                   	push   %ebx
  800fd2:	83 ec 04             	sub    $0x4,%esp
  800fd5:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fd8:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  800fda:	89 da                	mov    %ebx,%edx
  800fdc:	c1 ea 0c             	shr    $0xc,%edx
	pte_t pte = uvpt[pn];
  800fdf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  800fe6:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fea:	74 05                	je     800ff1 <pgfault+0x23>
  800fec:	f6 c6 08             	test   $0x8,%dh
  800fef:	75 14                	jne    801005 <pgfault+0x37>
		panic("fork pgfault handler: does not handle this fault");
  800ff1:	83 ec 04             	sub    $0x4,%esp
  800ff4:	68 4c 2c 80 00       	push   $0x802c4c
  800ff9:	6a 1f                	push   $0x1f
  800ffb:	68 7d 2c 80 00       	push   $0x802c7d
  801000:	e8 93 f2 ff ff       	call   800298 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  801005:	83 ec 04             	sub    $0x4,%esp
  801008:	6a 07                	push   $0x7
  80100a:	68 00 f0 7f 00       	push   $0x7ff000
  80100f:	6a 00                	push   $0x0
  801011:	e8 e3 fc ff ff       	call   800cf9 <sys_page_alloc>
  801016:	83 c4 10             	add    $0x10,%esp
  801019:	85 c0                	test   %eax,%eax
  80101b:	79 12                	jns    80102f <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  80101d:	50                   	push   %eax
  80101e:	68 88 2c 80 00       	push   $0x802c88
  801023:	6a 2b                	push   $0x2b
  801025:	68 7d 2c 80 00       	push   $0x802c7d
  80102a:	e8 69 f2 ff ff       	call   800298 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  80102f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  801035:	83 ec 04             	sub    $0x4,%esp
  801038:	68 00 10 00 00       	push   $0x1000
  80103d:	53                   	push   %ebx
  80103e:	68 00 f0 7f 00       	push   $0x7ff000
  801043:	e8 40 fa ff ff       	call   800a88 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  801048:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80104f:	53                   	push   %ebx
  801050:	6a 00                	push   $0x0
  801052:	68 00 f0 7f 00       	push   $0x7ff000
  801057:	6a 00                	push   $0x0
  801059:	e8 de fc ff ff       	call   800d3c <sys_page_map>
  80105e:	83 c4 20             	add    $0x20,%esp
  801061:	85 c0                	test   %eax,%eax
  801063:	79 12                	jns    801077 <pgfault+0xa9>
		panic("sys_page_map: %e", r);
  801065:	50                   	push   %eax
  801066:	68 9b 2c 80 00       	push   $0x802c9b
  80106b:	6a 33                	push   $0x33
  80106d:	68 7d 2c 80 00       	push   $0x802c7d
  801072:	e8 21 f2 ff ff       	call   800298 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801077:	83 ec 08             	sub    $0x8,%esp
  80107a:	68 00 f0 7f 00       	push   $0x7ff000
  80107f:	6a 00                	push   $0x0
  801081:	e8 f8 fc ff ff       	call   800d7e <sys_page_unmap>
  801086:	83 c4 10             	add    $0x10,%esp
  801089:	85 c0                	test   %eax,%eax
  80108b:	79 12                	jns    80109f <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  80108d:	50                   	push   %eax
  80108e:	68 ac 2c 80 00       	push   $0x802cac
  801093:	6a 37                	push   $0x37
  801095:	68 7d 2c 80 00       	push   $0x802c7d
  80109a:	e8 f9 f1 ff ff       	call   800298 <_panic>
}
  80109f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a2:	c9                   	leave  
  8010a3:	c3                   	ret    

008010a4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	57                   	push   %edi
  8010a8:	56                   	push   %esi
  8010a9:	53                   	push   %ebx
  8010aa:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  8010ad:	68 ce 0f 80 00       	push   $0x800fce
  8010b2:	e8 46 13 00 00       	call   8023fd <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8010b7:	b8 07 00 00 00       	mov    $0x7,%eax
  8010bc:	cd 30                	int    $0x30
  8010be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Create child
	envid_t envid = sys_exofork();
	if (envid < 0) {
  8010c4:	83 c4 10             	add    $0x10,%esp
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	79 15                	jns    8010e0 <fork+0x3c>
		panic("sys_exofork: %e", envid);
  8010cb:	50                   	push   %eax
  8010cc:	68 bf 2c 80 00       	push   $0x802cbf
  8010d1:	68 93 00 00 00       	push   $0x93
  8010d6:	68 7d 2c 80 00       	push   $0x802c7d
  8010db:	e8 b8 f1 ff ff       	call   800298 <_panic>
		return envid;
	}

	// If we are the child, fix thisenv.
	if (envid == 0) {
  8010e0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8010e4:	75 21                	jne    801107 <fork+0x63>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010e6:	e8 d0 fb ff ff       	call   800cbb <sys_getenvid>
  8010eb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010f0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010f3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010f8:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  8010fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801102:	e9 5a 01 00 00       	jmp    801261 <fork+0x1bd>
	// We are the parent!
	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle the
	// fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), PTE_P | PTE_U | PTE_W);
  801107:	83 ec 04             	sub    $0x4,%esp
  80110a:	6a 07                	push   $0x7
  80110c:	68 00 f0 bf ee       	push   $0xeebff000
  801111:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801114:	57                   	push   %edi
  801115:	e8 df fb ff ff       	call   800cf9 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  80111a:	83 c4 08             	add    $0x8,%esp
  80111d:	68 42 24 80 00       	push   $0x802442
  801122:	57                   	push   %edi
  801123:	e8 1c fd ff ff       	call   800e44 <sys_env_set_pgfault_upcall>
  801128:	83 c4 10             	add    $0x10,%esp

	// Copy our address space to child. Be careful not to copy the exception
	// stack too, so go until USTACKTOP instead of UTOP.
	unsigned pn;
	for (pn = UTEXT/PGSIZE; pn < USTACKTOP/PGSIZE; pn++) {
  80112b:	bb 00 08 00 00       	mov    $0x800,%ebx
static int
duppage(envid_t envid, unsigned pn)
{
	// Check if the page table that contains the PTE we want is allocated
	// using UVPD. If it is not, just don't map anything, and silently succeed.
	if (!(uvpd[pn/NPTENTRIES] & PTE_P))
  801130:	89 d8                	mov    %ebx,%eax
  801132:	c1 e8 0a             	shr    $0xa,%eax
  801135:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80113c:	a8 01                	test   $0x1,%al
  80113e:	0f 84 e2 00 00 00    	je     801226 <fork+0x182>
		return 0;

	// Retrieve the PTE using UVPT
	pte_t pte = uvpt[pn];
  801144:	8b 34 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%esi

	// If the page is present, duplicate according to it's permissions
	if (pte & PTE_P) {
  80114b:	f7 c6 01 00 00 00    	test   $0x1,%esi
  801151:	0f 84 cf 00 00 00    	je     801226 <fork+0x182>
		int r;
		uint32_t perm = pte & PTE_SYSCALL;
  801157:	89 f0                	mov    %esi,%eax
  801159:	25 07 0e 00 00       	and    $0xe07,%eax
  80115e:	89 df                	mov    %ebx,%edi
  801160:	c1 e7 0c             	shl    $0xc,%edi
		void *va = (void *) (pn * PGSIZE);

		// If PTE_SHARE is enabled, share it by just copying the
		// pte, which can be done by mapping on the same address
		// with the same permissions, even if it is writable
		if (pte & PTE_SHARE) {
  801163:	f7 c6 00 04 00 00    	test   $0x400,%esi
  801169:	74 2d                	je     801198 <fork+0xf4>
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  80116b:	83 ec 0c             	sub    $0xc,%esp
  80116e:	50                   	push   %eax
  80116f:	57                   	push   %edi
  801170:	ff 75 e4             	pushl  -0x1c(%ebp)
  801173:	57                   	push   %edi
  801174:	6a 00                	push   $0x0
  801176:	e8 c1 fb ff ff       	call   800d3c <sys_page_map>
  80117b:	83 c4 20             	add    $0x20,%esp
  80117e:	85 c0                	test   %eax,%eax
  801180:	0f 89 a0 00 00 00    	jns    801226 <fork+0x182>
				panic("sys_page_map: %e", r);
  801186:	50                   	push   %eax
  801187:	68 9b 2c 80 00       	push   $0x802c9b
  80118c:	6a 5c                	push   $0x5c
  80118e:	68 7d 2c 80 00       	push   $0x802c7d
  801193:	e8 00 f1 ff ff       	call   800298 <_panic>
				return r;
			}
		// If writable or COW, make it COW on parent and child
		} else if (pte & (PTE_W | PTE_COW)) {
  801198:	f7 c6 02 08 00 00    	test   $0x802,%esi
  80119e:	74 5d                	je     8011fd <fork+0x159>
			perm &= ~PTE_W;  // Remove PTE_W, so it faults
  8011a0:	81 e6 05 0e 00 00    	and    $0xe05,%esi
			perm |= PTE_COW; // Make it PTE_COW
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  8011a6:	81 ce 00 08 00 00    	or     $0x800,%esi
  8011ac:	83 ec 0c             	sub    $0xc,%esp
  8011af:	56                   	push   %esi
  8011b0:	57                   	push   %edi
  8011b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b4:	57                   	push   %edi
  8011b5:	6a 00                	push   $0x0
  8011b7:	e8 80 fb ff ff       	call   800d3c <sys_page_map>
  8011bc:	83 c4 20             	add    $0x20,%esp
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	79 12                	jns    8011d5 <fork+0x131>
				panic("sys_page_map: %e", r);
  8011c3:	50                   	push   %eax
  8011c4:	68 9b 2c 80 00       	push   $0x802c9b
  8011c9:	6a 65                	push   $0x65
  8011cb:	68 7d 2c 80 00       	push   $0x802c7d
  8011d0:	e8 c3 f0 ff ff       	call   800298 <_panic>
				return r;
			}
			// Change the permission on parent, mapping on itself
			if ((r = sys_page_map(0, va, 0, va, perm)) < 0) {
  8011d5:	83 ec 0c             	sub    $0xc,%esp
  8011d8:	56                   	push   %esi
  8011d9:	57                   	push   %edi
  8011da:	6a 00                	push   $0x0
  8011dc:	57                   	push   %edi
  8011dd:	6a 00                	push   $0x0
  8011df:	e8 58 fb ff ff       	call   800d3c <sys_page_map>
  8011e4:	83 c4 20             	add    $0x20,%esp
  8011e7:	85 c0                	test   %eax,%eax
  8011e9:	79 3b                	jns    801226 <fork+0x182>
				panic("sys_page_map: %e", r);
  8011eb:	50                   	push   %eax
  8011ec:	68 9b 2c 80 00       	push   $0x802c9b
  8011f1:	6a 6a                	push   $0x6a
  8011f3:	68 7d 2c 80 00       	push   $0x802c7d
  8011f8:	e8 9b f0 ff ff       	call   800298 <_panic>
				return r;
			}
		// If it is read-only, just share it.
		} else {
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  8011fd:	83 ec 0c             	sub    $0xc,%esp
  801200:	50                   	push   %eax
  801201:	57                   	push   %edi
  801202:	ff 75 e4             	pushl  -0x1c(%ebp)
  801205:	57                   	push   %edi
  801206:	6a 00                	push   $0x0
  801208:	e8 2f fb ff ff       	call   800d3c <sys_page_map>
  80120d:	83 c4 20             	add    $0x20,%esp
  801210:	85 c0                	test   %eax,%eax
  801212:	79 12                	jns    801226 <fork+0x182>
				panic("sys_page_map: %e", r);
  801214:	50                   	push   %eax
  801215:	68 9b 2c 80 00       	push   $0x802c9b
  80121a:	6a 71                	push   $0x71
  80121c:	68 7d 2c 80 00       	push   $0x802c7d
  801221:	e8 72 f0 ff ff       	call   800298 <_panic>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);

	// Copy our address space to child. Be careful not to copy the exception
	// stack too, so go until USTACKTOP instead of UTOP.
	unsigned pn;
	for (pn = UTEXT/PGSIZE; pn < USTACKTOP/PGSIZE; pn++) {
  801226:	83 c3 01             	add    $0x1,%ebx
  801229:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  80122f:	0f 85 fb fe ff ff    	jne    801130 <fork+0x8c>
		duppage(envid, pn);
	}

	// Make the child runnable
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801235:	83 ec 08             	sub    $0x8,%esp
  801238:	6a 02                	push   $0x2
  80123a:	ff 75 e0             	pushl  -0x20(%ebp)
  80123d:	e8 7e fb ff ff       	call   800dc0 <sys_env_set_status>
  801242:	83 c4 10             	add    $0x10,%esp
  801245:	85 c0                	test   %eax,%eax
  801247:	79 15                	jns    80125e <fork+0x1ba>
		panic("sys_env_set_status: %e", r);
  801249:	50                   	push   %eax
  80124a:	68 cf 2c 80 00       	push   $0x802ccf
  80124f:	68 af 00 00 00       	push   $0xaf
  801254:	68 7d 2c 80 00       	push   $0x802c7d
  801259:	e8 3a f0 ff ff       	call   800298 <_panic>
		return r;
	}

	return envid;
  80125e:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  801261:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801264:	5b                   	pop    %ebx
  801265:	5e                   	pop    %esi
  801266:	5f                   	pop    %edi
  801267:	5d                   	pop    %ebp
  801268:	c3                   	ret    

00801269 <sfork>:

// Challenge!
int
sfork(void)
{
  801269:	55                   	push   %ebp
  80126a:	89 e5                	mov    %esp,%ebp
  80126c:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80126f:	68 e6 2c 80 00       	push   $0x802ce6
  801274:	68 ba 00 00 00       	push   $0xba
  801279:	68 7d 2c 80 00       	push   $0x802c7d
  80127e:	e8 15 f0 ff ff       	call   800298 <_panic>

00801283 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801286:	8b 45 08             	mov    0x8(%ebp),%eax
  801289:	05 00 00 00 30       	add    $0x30000000,%eax
  80128e:	c1 e8 0c             	shr    $0xc,%eax
}
  801291:	5d                   	pop    %ebp
  801292:	c3                   	ret    

00801293 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801296:	8b 45 08             	mov    0x8(%ebp),%eax
  801299:	05 00 00 00 30       	add    $0x30000000,%eax
  80129e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012a3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012a8:	5d                   	pop    %ebp
  8012a9:	c3                   	ret    

008012aa <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012aa:	55                   	push   %ebp
  8012ab:	89 e5                	mov    %esp,%ebp
  8012ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012b5:	89 c2                	mov    %eax,%edx
  8012b7:	c1 ea 16             	shr    $0x16,%edx
  8012ba:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012c1:	f6 c2 01             	test   $0x1,%dl
  8012c4:	74 11                	je     8012d7 <fd_alloc+0x2d>
  8012c6:	89 c2                	mov    %eax,%edx
  8012c8:	c1 ea 0c             	shr    $0xc,%edx
  8012cb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012d2:	f6 c2 01             	test   $0x1,%dl
  8012d5:	75 09                	jne    8012e0 <fd_alloc+0x36>
			*fd_store = fd;
  8012d7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012de:	eb 17                	jmp    8012f7 <fd_alloc+0x4d>
  8012e0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012e5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012ea:	75 c9                	jne    8012b5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012ec:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012f2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012f7:	5d                   	pop    %ebp
  8012f8:	c3                   	ret    

008012f9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012ff:	83 f8 1f             	cmp    $0x1f,%eax
  801302:	77 36                	ja     80133a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801304:	c1 e0 0c             	shl    $0xc,%eax
  801307:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80130c:	89 c2                	mov    %eax,%edx
  80130e:	c1 ea 16             	shr    $0x16,%edx
  801311:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801318:	f6 c2 01             	test   $0x1,%dl
  80131b:	74 24                	je     801341 <fd_lookup+0x48>
  80131d:	89 c2                	mov    %eax,%edx
  80131f:	c1 ea 0c             	shr    $0xc,%edx
  801322:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801329:	f6 c2 01             	test   $0x1,%dl
  80132c:	74 1a                	je     801348 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80132e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801331:	89 02                	mov    %eax,(%edx)
	return 0;
  801333:	b8 00 00 00 00       	mov    $0x0,%eax
  801338:	eb 13                	jmp    80134d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80133a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80133f:	eb 0c                	jmp    80134d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801341:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801346:	eb 05                	jmp    80134d <fd_lookup+0x54>
  801348:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80134d:	5d                   	pop    %ebp
  80134e:	c3                   	ret    

0080134f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	83 ec 08             	sub    $0x8,%esp
  801355:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801358:	ba 7c 2d 80 00       	mov    $0x802d7c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80135d:	eb 13                	jmp    801372 <dev_lookup+0x23>
  80135f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801362:	39 08                	cmp    %ecx,(%eax)
  801364:	75 0c                	jne    801372 <dev_lookup+0x23>
			*dev = devtab[i];
  801366:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801369:	89 01                	mov    %eax,(%ecx)
			return 0;
  80136b:	b8 00 00 00 00       	mov    $0x0,%eax
  801370:	eb 2e                	jmp    8013a0 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801372:	8b 02                	mov    (%edx),%eax
  801374:	85 c0                	test   %eax,%eax
  801376:	75 e7                	jne    80135f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801378:	a1 08 40 80 00       	mov    0x804008,%eax
  80137d:	8b 40 48             	mov    0x48(%eax),%eax
  801380:	83 ec 04             	sub    $0x4,%esp
  801383:	51                   	push   %ecx
  801384:	50                   	push   %eax
  801385:	68 fc 2c 80 00       	push   $0x802cfc
  80138a:	e8 e2 ef ff ff       	call   800371 <cprintf>
	*dev = 0;
  80138f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801392:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801398:	83 c4 10             	add    $0x10,%esp
  80139b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013a0:	c9                   	leave  
  8013a1:	c3                   	ret    

008013a2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013a2:	55                   	push   %ebp
  8013a3:	89 e5                	mov    %esp,%ebp
  8013a5:	56                   	push   %esi
  8013a6:	53                   	push   %ebx
  8013a7:	83 ec 10             	sub    $0x10,%esp
  8013aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8013ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b3:	50                   	push   %eax
  8013b4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013ba:	c1 e8 0c             	shr    $0xc,%eax
  8013bd:	50                   	push   %eax
  8013be:	e8 36 ff ff ff       	call   8012f9 <fd_lookup>
  8013c3:	83 c4 08             	add    $0x8,%esp
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	78 05                	js     8013cf <fd_close+0x2d>
	    || fd != fd2)
  8013ca:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013cd:	74 0c                	je     8013db <fd_close+0x39>
		return (must_exist ? r : 0);
  8013cf:	84 db                	test   %bl,%bl
  8013d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d6:	0f 44 c2             	cmove  %edx,%eax
  8013d9:	eb 41                	jmp    80141c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013db:	83 ec 08             	sub    $0x8,%esp
  8013de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e1:	50                   	push   %eax
  8013e2:	ff 36                	pushl  (%esi)
  8013e4:	e8 66 ff ff ff       	call   80134f <dev_lookup>
  8013e9:	89 c3                	mov    %eax,%ebx
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	78 1a                	js     80140c <fd_close+0x6a>
		if (dev->dev_close)
  8013f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f5:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013f8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013fd:	85 c0                	test   %eax,%eax
  8013ff:	74 0b                	je     80140c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801401:	83 ec 0c             	sub    $0xc,%esp
  801404:	56                   	push   %esi
  801405:	ff d0                	call   *%eax
  801407:	89 c3                	mov    %eax,%ebx
  801409:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80140c:	83 ec 08             	sub    $0x8,%esp
  80140f:	56                   	push   %esi
  801410:	6a 00                	push   $0x0
  801412:	e8 67 f9 ff ff       	call   800d7e <sys_page_unmap>
	return r;
  801417:	83 c4 10             	add    $0x10,%esp
  80141a:	89 d8                	mov    %ebx,%eax
}
  80141c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80141f:	5b                   	pop    %ebx
  801420:	5e                   	pop    %esi
  801421:	5d                   	pop    %ebp
  801422:	c3                   	ret    

00801423 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801429:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142c:	50                   	push   %eax
  80142d:	ff 75 08             	pushl  0x8(%ebp)
  801430:	e8 c4 fe ff ff       	call   8012f9 <fd_lookup>
  801435:	83 c4 08             	add    $0x8,%esp
  801438:	85 c0                	test   %eax,%eax
  80143a:	78 10                	js     80144c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80143c:	83 ec 08             	sub    $0x8,%esp
  80143f:	6a 01                	push   $0x1
  801441:	ff 75 f4             	pushl  -0xc(%ebp)
  801444:	e8 59 ff ff ff       	call   8013a2 <fd_close>
  801449:	83 c4 10             	add    $0x10,%esp
}
  80144c:	c9                   	leave  
  80144d:	c3                   	ret    

0080144e <close_all>:

void
close_all(void)
{
  80144e:	55                   	push   %ebp
  80144f:	89 e5                	mov    %esp,%ebp
  801451:	53                   	push   %ebx
  801452:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801455:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80145a:	83 ec 0c             	sub    $0xc,%esp
  80145d:	53                   	push   %ebx
  80145e:	e8 c0 ff ff ff       	call   801423 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801463:	83 c3 01             	add    $0x1,%ebx
  801466:	83 c4 10             	add    $0x10,%esp
  801469:	83 fb 20             	cmp    $0x20,%ebx
  80146c:	75 ec                	jne    80145a <close_all+0xc>
		close(i);
}
  80146e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801471:	c9                   	leave  
  801472:	c3                   	ret    

00801473 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	57                   	push   %edi
  801477:	56                   	push   %esi
  801478:	53                   	push   %ebx
  801479:	83 ec 2c             	sub    $0x2c,%esp
  80147c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80147f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801482:	50                   	push   %eax
  801483:	ff 75 08             	pushl  0x8(%ebp)
  801486:	e8 6e fe ff ff       	call   8012f9 <fd_lookup>
  80148b:	83 c4 08             	add    $0x8,%esp
  80148e:	85 c0                	test   %eax,%eax
  801490:	0f 88 c1 00 00 00    	js     801557 <dup+0xe4>
		return r;
	close(newfdnum);
  801496:	83 ec 0c             	sub    $0xc,%esp
  801499:	56                   	push   %esi
  80149a:	e8 84 ff ff ff       	call   801423 <close>

	newfd = INDEX2FD(newfdnum);
  80149f:	89 f3                	mov    %esi,%ebx
  8014a1:	c1 e3 0c             	shl    $0xc,%ebx
  8014a4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014aa:	83 c4 04             	add    $0x4,%esp
  8014ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014b0:	e8 de fd ff ff       	call   801293 <fd2data>
  8014b5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014b7:	89 1c 24             	mov    %ebx,(%esp)
  8014ba:	e8 d4 fd ff ff       	call   801293 <fd2data>
  8014bf:	83 c4 10             	add    $0x10,%esp
  8014c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014c5:	89 f8                	mov    %edi,%eax
  8014c7:	c1 e8 16             	shr    $0x16,%eax
  8014ca:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014d1:	a8 01                	test   $0x1,%al
  8014d3:	74 37                	je     80150c <dup+0x99>
  8014d5:	89 f8                	mov    %edi,%eax
  8014d7:	c1 e8 0c             	shr    $0xc,%eax
  8014da:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014e1:	f6 c2 01             	test   $0x1,%dl
  8014e4:	74 26                	je     80150c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014ed:	83 ec 0c             	sub    $0xc,%esp
  8014f0:	25 07 0e 00 00       	and    $0xe07,%eax
  8014f5:	50                   	push   %eax
  8014f6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014f9:	6a 00                	push   $0x0
  8014fb:	57                   	push   %edi
  8014fc:	6a 00                	push   $0x0
  8014fe:	e8 39 f8 ff ff       	call   800d3c <sys_page_map>
  801503:	89 c7                	mov    %eax,%edi
  801505:	83 c4 20             	add    $0x20,%esp
  801508:	85 c0                	test   %eax,%eax
  80150a:	78 2e                	js     80153a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80150c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80150f:	89 d0                	mov    %edx,%eax
  801511:	c1 e8 0c             	shr    $0xc,%eax
  801514:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80151b:	83 ec 0c             	sub    $0xc,%esp
  80151e:	25 07 0e 00 00       	and    $0xe07,%eax
  801523:	50                   	push   %eax
  801524:	53                   	push   %ebx
  801525:	6a 00                	push   $0x0
  801527:	52                   	push   %edx
  801528:	6a 00                	push   $0x0
  80152a:	e8 0d f8 ff ff       	call   800d3c <sys_page_map>
  80152f:	89 c7                	mov    %eax,%edi
  801531:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801534:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801536:	85 ff                	test   %edi,%edi
  801538:	79 1d                	jns    801557 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80153a:	83 ec 08             	sub    $0x8,%esp
  80153d:	53                   	push   %ebx
  80153e:	6a 00                	push   $0x0
  801540:	e8 39 f8 ff ff       	call   800d7e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801545:	83 c4 08             	add    $0x8,%esp
  801548:	ff 75 d4             	pushl  -0x2c(%ebp)
  80154b:	6a 00                	push   $0x0
  80154d:	e8 2c f8 ff ff       	call   800d7e <sys_page_unmap>
	return r;
  801552:	83 c4 10             	add    $0x10,%esp
  801555:	89 f8                	mov    %edi,%eax
}
  801557:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80155a:	5b                   	pop    %ebx
  80155b:	5e                   	pop    %esi
  80155c:	5f                   	pop    %edi
  80155d:	5d                   	pop    %ebp
  80155e:	c3                   	ret    

0080155f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
  801562:	53                   	push   %ebx
  801563:	83 ec 14             	sub    $0x14,%esp
  801566:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801569:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156c:	50                   	push   %eax
  80156d:	53                   	push   %ebx
  80156e:	e8 86 fd ff ff       	call   8012f9 <fd_lookup>
  801573:	83 c4 08             	add    $0x8,%esp
  801576:	89 c2                	mov    %eax,%edx
  801578:	85 c0                	test   %eax,%eax
  80157a:	78 6d                	js     8015e9 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157c:	83 ec 08             	sub    $0x8,%esp
  80157f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801582:	50                   	push   %eax
  801583:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801586:	ff 30                	pushl  (%eax)
  801588:	e8 c2 fd ff ff       	call   80134f <dev_lookup>
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	85 c0                	test   %eax,%eax
  801592:	78 4c                	js     8015e0 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801594:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801597:	8b 42 08             	mov    0x8(%edx),%eax
  80159a:	83 e0 03             	and    $0x3,%eax
  80159d:	83 f8 01             	cmp    $0x1,%eax
  8015a0:	75 21                	jne    8015c3 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015a2:	a1 08 40 80 00       	mov    0x804008,%eax
  8015a7:	8b 40 48             	mov    0x48(%eax),%eax
  8015aa:	83 ec 04             	sub    $0x4,%esp
  8015ad:	53                   	push   %ebx
  8015ae:	50                   	push   %eax
  8015af:	68 40 2d 80 00       	push   $0x802d40
  8015b4:	e8 b8 ed ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c1:	eb 26                	jmp    8015e9 <read+0x8a>
	}
	if (!dev->dev_read)
  8015c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c6:	8b 40 08             	mov    0x8(%eax),%eax
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	74 17                	je     8015e4 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015cd:	83 ec 04             	sub    $0x4,%esp
  8015d0:	ff 75 10             	pushl  0x10(%ebp)
  8015d3:	ff 75 0c             	pushl  0xc(%ebp)
  8015d6:	52                   	push   %edx
  8015d7:	ff d0                	call   *%eax
  8015d9:	89 c2                	mov    %eax,%edx
  8015db:	83 c4 10             	add    $0x10,%esp
  8015de:	eb 09                	jmp    8015e9 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e0:	89 c2                	mov    %eax,%edx
  8015e2:	eb 05                	jmp    8015e9 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015e4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015e9:	89 d0                	mov    %edx,%eax
  8015eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ee:	c9                   	leave  
  8015ef:	c3                   	ret    

008015f0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	57                   	push   %edi
  8015f4:	56                   	push   %esi
  8015f5:	53                   	push   %ebx
  8015f6:	83 ec 0c             	sub    $0xc,%esp
  8015f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015fc:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  801604:	eb 21                	jmp    801627 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801606:	83 ec 04             	sub    $0x4,%esp
  801609:	89 f0                	mov    %esi,%eax
  80160b:	29 d8                	sub    %ebx,%eax
  80160d:	50                   	push   %eax
  80160e:	89 d8                	mov    %ebx,%eax
  801610:	03 45 0c             	add    0xc(%ebp),%eax
  801613:	50                   	push   %eax
  801614:	57                   	push   %edi
  801615:	e8 45 ff ff ff       	call   80155f <read>
		if (m < 0)
  80161a:	83 c4 10             	add    $0x10,%esp
  80161d:	85 c0                	test   %eax,%eax
  80161f:	78 10                	js     801631 <readn+0x41>
			return m;
		if (m == 0)
  801621:	85 c0                	test   %eax,%eax
  801623:	74 0a                	je     80162f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801625:	01 c3                	add    %eax,%ebx
  801627:	39 f3                	cmp    %esi,%ebx
  801629:	72 db                	jb     801606 <readn+0x16>
  80162b:	89 d8                	mov    %ebx,%eax
  80162d:	eb 02                	jmp    801631 <readn+0x41>
  80162f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801631:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801634:	5b                   	pop    %ebx
  801635:	5e                   	pop    %esi
  801636:	5f                   	pop    %edi
  801637:	5d                   	pop    %ebp
  801638:	c3                   	ret    

00801639 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801639:	55                   	push   %ebp
  80163a:	89 e5                	mov    %esp,%ebp
  80163c:	53                   	push   %ebx
  80163d:	83 ec 14             	sub    $0x14,%esp
  801640:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801643:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801646:	50                   	push   %eax
  801647:	53                   	push   %ebx
  801648:	e8 ac fc ff ff       	call   8012f9 <fd_lookup>
  80164d:	83 c4 08             	add    $0x8,%esp
  801650:	89 c2                	mov    %eax,%edx
  801652:	85 c0                	test   %eax,%eax
  801654:	78 68                	js     8016be <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801656:	83 ec 08             	sub    $0x8,%esp
  801659:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165c:	50                   	push   %eax
  80165d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801660:	ff 30                	pushl  (%eax)
  801662:	e8 e8 fc ff ff       	call   80134f <dev_lookup>
  801667:	83 c4 10             	add    $0x10,%esp
  80166a:	85 c0                	test   %eax,%eax
  80166c:	78 47                	js     8016b5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80166e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801671:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801675:	75 21                	jne    801698 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801677:	a1 08 40 80 00       	mov    0x804008,%eax
  80167c:	8b 40 48             	mov    0x48(%eax),%eax
  80167f:	83 ec 04             	sub    $0x4,%esp
  801682:	53                   	push   %ebx
  801683:	50                   	push   %eax
  801684:	68 5c 2d 80 00       	push   $0x802d5c
  801689:	e8 e3 ec ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  80168e:	83 c4 10             	add    $0x10,%esp
  801691:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801696:	eb 26                	jmp    8016be <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801698:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80169b:	8b 52 0c             	mov    0xc(%edx),%edx
  80169e:	85 d2                	test   %edx,%edx
  8016a0:	74 17                	je     8016b9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016a2:	83 ec 04             	sub    $0x4,%esp
  8016a5:	ff 75 10             	pushl  0x10(%ebp)
  8016a8:	ff 75 0c             	pushl  0xc(%ebp)
  8016ab:	50                   	push   %eax
  8016ac:	ff d2                	call   *%edx
  8016ae:	89 c2                	mov    %eax,%edx
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	eb 09                	jmp    8016be <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b5:	89 c2                	mov    %eax,%edx
  8016b7:	eb 05                	jmp    8016be <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016b9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016be:	89 d0                	mov    %edx,%eax
  8016c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c3:	c9                   	leave  
  8016c4:	c3                   	ret    

008016c5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016cb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016ce:	50                   	push   %eax
  8016cf:	ff 75 08             	pushl  0x8(%ebp)
  8016d2:	e8 22 fc ff ff       	call   8012f9 <fd_lookup>
  8016d7:	83 c4 08             	add    $0x8,%esp
  8016da:	85 c0                	test   %eax,%eax
  8016dc:	78 0e                	js     8016ec <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016de:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016e4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ec:	c9                   	leave  
  8016ed:	c3                   	ret    

008016ee <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	53                   	push   %ebx
  8016f2:	83 ec 14             	sub    $0x14,%esp
  8016f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016fb:	50                   	push   %eax
  8016fc:	53                   	push   %ebx
  8016fd:	e8 f7 fb ff ff       	call   8012f9 <fd_lookup>
  801702:	83 c4 08             	add    $0x8,%esp
  801705:	89 c2                	mov    %eax,%edx
  801707:	85 c0                	test   %eax,%eax
  801709:	78 65                	js     801770 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170b:	83 ec 08             	sub    $0x8,%esp
  80170e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801711:	50                   	push   %eax
  801712:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801715:	ff 30                	pushl  (%eax)
  801717:	e8 33 fc ff ff       	call   80134f <dev_lookup>
  80171c:	83 c4 10             	add    $0x10,%esp
  80171f:	85 c0                	test   %eax,%eax
  801721:	78 44                	js     801767 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801723:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801726:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80172a:	75 21                	jne    80174d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80172c:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801731:	8b 40 48             	mov    0x48(%eax),%eax
  801734:	83 ec 04             	sub    $0x4,%esp
  801737:	53                   	push   %ebx
  801738:	50                   	push   %eax
  801739:	68 1c 2d 80 00       	push   $0x802d1c
  80173e:	e8 2e ec ff ff       	call   800371 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80174b:	eb 23                	jmp    801770 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80174d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801750:	8b 52 18             	mov    0x18(%edx),%edx
  801753:	85 d2                	test   %edx,%edx
  801755:	74 14                	je     80176b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801757:	83 ec 08             	sub    $0x8,%esp
  80175a:	ff 75 0c             	pushl  0xc(%ebp)
  80175d:	50                   	push   %eax
  80175e:	ff d2                	call   *%edx
  801760:	89 c2                	mov    %eax,%edx
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	eb 09                	jmp    801770 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801767:	89 c2                	mov    %eax,%edx
  801769:	eb 05                	jmp    801770 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80176b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801770:	89 d0                	mov    %edx,%eax
  801772:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801775:	c9                   	leave  
  801776:	c3                   	ret    

00801777 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801777:	55                   	push   %ebp
  801778:	89 e5                	mov    %esp,%ebp
  80177a:	53                   	push   %ebx
  80177b:	83 ec 14             	sub    $0x14,%esp
  80177e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801781:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801784:	50                   	push   %eax
  801785:	ff 75 08             	pushl  0x8(%ebp)
  801788:	e8 6c fb ff ff       	call   8012f9 <fd_lookup>
  80178d:	83 c4 08             	add    $0x8,%esp
  801790:	89 c2                	mov    %eax,%edx
  801792:	85 c0                	test   %eax,%eax
  801794:	78 58                	js     8017ee <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801796:	83 ec 08             	sub    $0x8,%esp
  801799:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80179c:	50                   	push   %eax
  80179d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a0:	ff 30                	pushl  (%eax)
  8017a2:	e8 a8 fb ff ff       	call   80134f <dev_lookup>
  8017a7:	83 c4 10             	add    $0x10,%esp
  8017aa:	85 c0                	test   %eax,%eax
  8017ac:	78 37                	js     8017e5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017b5:	74 32                	je     8017e9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017b7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017ba:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017c1:	00 00 00 
	stat->st_isdir = 0;
  8017c4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017cb:	00 00 00 
	stat->st_dev = dev;
  8017ce:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017d4:	83 ec 08             	sub    $0x8,%esp
  8017d7:	53                   	push   %ebx
  8017d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8017db:	ff 50 14             	call   *0x14(%eax)
  8017de:	89 c2                	mov    %eax,%edx
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	eb 09                	jmp    8017ee <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e5:	89 c2                	mov    %eax,%edx
  8017e7:	eb 05                	jmp    8017ee <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017e9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017ee:	89 d0                	mov    %edx,%eax
  8017f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f3:	c9                   	leave  
  8017f4:	c3                   	ret    

008017f5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	56                   	push   %esi
  8017f9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017fa:	83 ec 08             	sub    $0x8,%esp
  8017fd:	6a 00                	push   $0x0
  8017ff:	ff 75 08             	pushl  0x8(%ebp)
  801802:	e8 0c 02 00 00       	call   801a13 <open>
  801807:	89 c3                	mov    %eax,%ebx
  801809:	83 c4 10             	add    $0x10,%esp
  80180c:	85 c0                	test   %eax,%eax
  80180e:	78 1b                	js     80182b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801810:	83 ec 08             	sub    $0x8,%esp
  801813:	ff 75 0c             	pushl  0xc(%ebp)
  801816:	50                   	push   %eax
  801817:	e8 5b ff ff ff       	call   801777 <fstat>
  80181c:	89 c6                	mov    %eax,%esi
	close(fd);
  80181e:	89 1c 24             	mov    %ebx,(%esp)
  801821:	e8 fd fb ff ff       	call   801423 <close>
	return r;
  801826:	83 c4 10             	add    $0x10,%esp
  801829:	89 f0                	mov    %esi,%eax
}
  80182b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80182e:	5b                   	pop    %ebx
  80182f:	5e                   	pop    %esi
  801830:	5d                   	pop    %ebp
  801831:	c3                   	ret    

00801832 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801832:	55                   	push   %ebp
  801833:	89 e5                	mov    %esp,%ebp
  801835:	56                   	push   %esi
  801836:	53                   	push   %ebx
  801837:	89 c6                	mov    %eax,%esi
  801839:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80183b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801842:	75 12                	jne    801856 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801844:	83 ec 0c             	sub    $0xc,%esp
  801847:	6a 01                	push   $0x1
  801849:	e8 e2 0c 00 00       	call   802530 <ipc_find_env>
  80184e:	a3 00 40 80 00       	mov    %eax,0x804000
  801853:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801856:	6a 07                	push   $0x7
  801858:	68 00 50 80 00       	push   $0x805000
  80185d:	56                   	push   %esi
  80185e:	ff 35 00 40 80 00    	pushl  0x804000
  801864:	e8 73 0c 00 00       	call   8024dc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801869:	83 c4 0c             	add    $0xc,%esp
  80186c:	6a 00                	push   $0x0
  80186e:	53                   	push   %ebx
  80186f:	6a 00                	push   $0x0
  801871:	e8 fd 0b 00 00       	call   802473 <ipc_recv>
}
  801876:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801879:	5b                   	pop    %ebx
  80187a:	5e                   	pop    %esi
  80187b:	5d                   	pop    %ebp
  80187c:	c3                   	ret    

0080187d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
  801880:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801883:	8b 45 08             	mov    0x8(%ebp),%eax
  801886:	8b 40 0c             	mov    0xc(%eax),%eax
  801889:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80188e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801891:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801896:	ba 00 00 00 00       	mov    $0x0,%edx
  80189b:	b8 02 00 00 00       	mov    $0x2,%eax
  8018a0:	e8 8d ff ff ff       	call   801832 <fsipc>
}
  8018a5:	c9                   	leave  
  8018a6:	c3                   	ret    

008018a7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bd:	b8 06 00 00 00       	mov    $0x6,%eax
  8018c2:	e8 6b ff ff ff       	call   801832 <fsipc>
}
  8018c7:	c9                   	leave  
  8018c8:	c3                   	ret    

008018c9 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018c9:	55                   	push   %ebp
  8018ca:	89 e5                	mov    %esp,%ebp
  8018cc:	53                   	push   %ebx
  8018cd:	83 ec 04             	sub    $0x4,%esp
  8018d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018de:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e3:	b8 05 00 00 00       	mov    $0x5,%eax
  8018e8:	e8 45 ff ff ff       	call   801832 <fsipc>
  8018ed:	85 c0                	test   %eax,%eax
  8018ef:	78 2c                	js     80191d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018f1:	83 ec 08             	sub    $0x8,%esp
  8018f4:	68 00 50 80 00       	push   $0x805000
  8018f9:	53                   	push   %ebx
  8018fa:	e8 f7 ef ff ff       	call   8008f6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018ff:	a1 80 50 80 00       	mov    0x805080,%eax
  801904:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80190a:	a1 84 50 80 00       	mov    0x805084,%eax
  80190f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801915:	83 c4 10             	add    $0x10,%esp
  801918:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80191d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801920:	c9                   	leave  
  801921:	c3                   	ret    

00801922 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
  801925:	53                   	push   %ebx
  801926:	83 ec 08             	sub    $0x8,%esp
  801929:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80192c:	8b 55 08             	mov    0x8(%ebp),%edx
  80192f:	8b 52 0c             	mov    0xc(%edx),%edx
  801932:	89 15 00 50 80 00    	mov    %edx,0x805000
  801938:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80193d:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801942:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  801945:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  80194b:	53                   	push   %ebx
  80194c:	ff 75 0c             	pushl  0xc(%ebp)
  80194f:	68 08 50 80 00       	push   $0x805008
  801954:	e8 2f f1 ff ff       	call   800a88 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  801959:	ba 00 00 00 00       	mov    $0x0,%edx
  80195e:	b8 04 00 00 00       	mov    $0x4,%eax
  801963:	e8 ca fe ff ff       	call   801832 <fsipc>
  801968:	83 c4 10             	add    $0x10,%esp
  80196b:	85 c0                	test   %eax,%eax
  80196d:	78 1d                	js     80198c <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  80196f:	39 d8                	cmp    %ebx,%eax
  801971:	76 19                	jbe    80198c <devfile_write+0x6a>
  801973:	68 90 2d 80 00       	push   $0x802d90
  801978:	68 9c 2d 80 00       	push   $0x802d9c
  80197d:	68 a5 00 00 00       	push   $0xa5
  801982:	68 b1 2d 80 00       	push   $0x802db1
  801987:	e8 0c e9 ff ff       	call   800298 <_panic>
	return r;
}
  80198c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198f:	c9                   	leave  
  801990:	c3                   	ret    

00801991 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	56                   	push   %esi
  801995:	53                   	push   %ebx
  801996:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801999:	8b 45 08             	mov    0x8(%ebp),%eax
  80199c:	8b 40 0c             	mov    0xc(%eax),%eax
  80199f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019a4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8019af:	b8 03 00 00 00       	mov    $0x3,%eax
  8019b4:	e8 79 fe ff ff       	call   801832 <fsipc>
  8019b9:	89 c3                	mov    %eax,%ebx
  8019bb:	85 c0                	test   %eax,%eax
  8019bd:	78 4b                	js     801a0a <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019bf:	39 c6                	cmp    %eax,%esi
  8019c1:	73 16                	jae    8019d9 <devfile_read+0x48>
  8019c3:	68 bc 2d 80 00       	push   $0x802dbc
  8019c8:	68 9c 2d 80 00       	push   $0x802d9c
  8019cd:	6a 7c                	push   $0x7c
  8019cf:	68 b1 2d 80 00       	push   $0x802db1
  8019d4:	e8 bf e8 ff ff       	call   800298 <_panic>
	assert(r <= PGSIZE);
  8019d9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019de:	7e 16                	jle    8019f6 <devfile_read+0x65>
  8019e0:	68 c3 2d 80 00       	push   $0x802dc3
  8019e5:	68 9c 2d 80 00       	push   $0x802d9c
  8019ea:	6a 7d                	push   $0x7d
  8019ec:	68 b1 2d 80 00       	push   $0x802db1
  8019f1:	e8 a2 e8 ff ff       	call   800298 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019f6:	83 ec 04             	sub    $0x4,%esp
  8019f9:	50                   	push   %eax
  8019fa:	68 00 50 80 00       	push   $0x805000
  8019ff:	ff 75 0c             	pushl  0xc(%ebp)
  801a02:	e8 81 f0 ff ff       	call   800a88 <memmove>
	return r;
  801a07:	83 c4 10             	add    $0x10,%esp
}
  801a0a:	89 d8                	mov    %ebx,%eax
  801a0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0f:	5b                   	pop    %ebx
  801a10:	5e                   	pop    %esi
  801a11:	5d                   	pop    %ebp
  801a12:	c3                   	ret    

00801a13 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	53                   	push   %ebx
  801a17:	83 ec 20             	sub    $0x20,%esp
  801a1a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a1d:	53                   	push   %ebx
  801a1e:	e8 9a ee ff ff       	call   8008bd <strlen>
  801a23:	83 c4 10             	add    $0x10,%esp
  801a26:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a2b:	7f 67                	jg     801a94 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a2d:	83 ec 0c             	sub    $0xc,%esp
  801a30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a33:	50                   	push   %eax
  801a34:	e8 71 f8 ff ff       	call   8012aa <fd_alloc>
  801a39:	83 c4 10             	add    $0x10,%esp
		return r;
  801a3c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a3e:	85 c0                	test   %eax,%eax
  801a40:	78 57                	js     801a99 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a42:	83 ec 08             	sub    $0x8,%esp
  801a45:	53                   	push   %ebx
  801a46:	68 00 50 80 00       	push   $0x805000
  801a4b:	e8 a6 ee ff ff       	call   8008f6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a50:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a53:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a58:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a5b:	b8 01 00 00 00       	mov    $0x1,%eax
  801a60:	e8 cd fd ff ff       	call   801832 <fsipc>
  801a65:	89 c3                	mov    %eax,%ebx
  801a67:	83 c4 10             	add    $0x10,%esp
  801a6a:	85 c0                	test   %eax,%eax
  801a6c:	79 14                	jns    801a82 <open+0x6f>
		fd_close(fd, 0);
  801a6e:	83 ec 08             	sub    $0x8,%esp
  801a71:	6a 00                	push   $0x0
  801a73:	ff 75 f4             	pushl  -0xc(%ebp)
  801a76:	e8 27 f9 ff ff       	call   8013a2 <fd_close>
		return r;
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	89 da                	mov    %ebx,%edx
  801a80:	eb 17                	jmp    801a99 <open+0x86>
	}

	return fd2num(fd);
  801a82:	83 ec 0c             	sub    $0xc,%esp
  801a85:	ff 75 f4             	pushl  -0xc(%ebp)
  801a88:	e8 f6 f7 ff ff       	call   801283 <fd2num>
  801a8d:	89 c2                	mov    %eax,%edx
  801a8f:	83 c4 10             	add    $0x10,%esp
  801a92:	eb 05                	jmp    801a99 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a94:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a99:	89 d0                	mov    %edx,%eax
  801a9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a9e:	c9                   	leave  
  801a9f:	c3                   	ret    

00801aa0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801aa6:	ba 00 00 00 00       	mov    $0x0,%edx
  801aab:	b8 08 00 00 00       	mov    $0x8,%eax
  801ab0:	e8 7d fd ff ff       	call   801832 <fsipc>
}
  801ab5:	c9                   	leave  
  801ab6:	c3                   	ret    

00801ab7 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801abd:	68 cf 2d 80 00       	push   $0x802dcf
  801ac2:	ff 75 0c             	pushl  0xc(%ebp)
  801ac5:	e8 2c ee ff ff       	call   8008f6 <strcpy>
	return 0;
}
  801aca:	b8 00 00 00 00       	mov    $0x0,%eax
  801acf:	c9                   	leave  
  801ad0:	c3                   	ret    

00801ad1 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	53                   	push   %ebx
  801ad5:	83 ec 10             	sub    $0x10,%esp
  801ad8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801adb:	53                   	push   %ebx
  801adc:	e8 88 0a 00 00       	call   802569 <pageref>
  801ae1:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801ae4:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801ae9:	83 f8 01             	cmp    $0x1,%eax
  801aec:	75 10                	jne    801afe <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801aee:	83 ec 0c             	sub    $0xc,%esp
  801af1:	ff 73 0c             	pushl  0xc(%ebx)
  801af4:	e8 c0 02 00 00       	call   801db9 <nsipc_close>
  801af9:	89 c2                	mov    %eax,%edx
  801afb:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801afe:	89 d0                	mov    %edx,%eax
  801b00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b03:	c9                   	leave  
  801b04:	c3                   	ret    

00801b05 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b05:	55                   	push   %ebp
  801b06:	89 e5                	mov    %esp,%ebp
  801b08:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b0b:	6a 00                	push   $0x0
  801b0d:	ff 75 10             	pushl  0x10(%ebp)
  801b10:	ff 75 0c             	pushl  0xc(%ebp)
  801b13:	8b 45 08             	mov    0x8(%ebp),%eax
  801b16:	ff 70 0c             	pushl  0xc(%eax)
  801b19:	e8 78 03 00 00       	call   801e96 <nsipc_send>
}
  801b1e:	c9                   	leave  
  801b1f:	c3                   	ret    

00801b20 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b26:	6a 00                	push   $0x0
  801b28:	ff 75 10             	pushl  0x10(%ebp)
  801b2b:	ff 75 0c             	pushl  0xc(%ebp)
  801b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b31:	ff 70 0c             	pushl  0xc(%eax)
  801b34:	e8 f1 02 00 00       	call   801e2a <nsipc_recv>
}
  801b39:	c9                   	leave  
  801b3a:	c3                   	ret    

00801b3b <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b3b:	55                   	push   %ebp
  801b3c:	89 e5                	mov    %esp,%ebp
  801b3e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b41:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b44:	52                   	push   %edx
  801b45:	50                   	push   %eax
  801b46:	e8 ae f7 ff ff       	call   8012f9 <fd_lookup>
  801b4b:	83 c4 10             	add    $0x10,%esp
  801b4e:	85 c0                	test   %eax,%eax
  801b50:	78 17                	js     801b69 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b55:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801b5b:	39 08                	cmp    %ecx,(%eax)
  801b5d:	75 05                	jne    801b64 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b5f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b62:	eb 05                	jmp    801b69 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b64:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b69:	c9                   	leave  
  801b6a:	c3                   	ret    

00801b6b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	56                   	push   %esi
  801b6f:	53                   	push   %ebx
  801b70:	83 ec 1c             	sub    $0x1c,%esp
  801b73:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b78:	50                   	push   %eax
  801b79:	e8 2c f7 ff ff       	call   8012aa <fd_alloc>
  801b7e:	89 c3                	mov    %eax,%ebx
  801b80:	83 c4 10             	add    $0x10,%esp
  801b83:	85 c0                	test   %eax,%eax
  801b85:	78 1b                	js     801ba2 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b87:	83 ec 04             	sub    $0x4,%esp
  801b8a:	68 07 04 00 00       	push   $0x407
  801b8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b92:	6a 00                	push   $0x0
  801b94:	e8 60 f1 ff ff       	call   800cf9 <sys_page_alloc>
  801b99:	89 c3                	mov    %eax,%ebx
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	85 c0                	test   %eax,%eax
  801ba0:	79 10                	jns    801bb2 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801ba2:	83 ec 0c             	sub    $0xc,%esp
  801ba5:	56                   	push   %esi
  801ba6:	e8 0e 02 00 00       	call   801db9 <nsipc_close>
		return r;
  801bab:	83 c4 10             	add    $0x10,%esp
  801bae:	89 d8                	mov    %ebx,%eax
  801bb0:	eb 24                	jmp    801bd6 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801bb2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bbb:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801bc7:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801bca:	83 ec 0c             	sub    $0xc,%esp
  801bcd:	50                   	push   %eax
  801bce:	e8 b0 f6 ff ff       	call   801283 <fd2num>
  801bd3:	83 c4 10             	add    $0x10,%esp
}
  801bd6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd9:	5b                   	pop    %ebx
  801bda:	5e                   	pop    %esi
  801bdb:	5d                   	pop    %ebp
  801bdc:	c3                   	ret    

00801bdd <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801be3:	8b 45 08             	mov    0x8(%ebp),%eax
  801be6:	e8 50 ff ff ff       	call   801b3b <fd2sockid>
		return r;
  801beb:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bed:	85 c0                	test   %eax,%eax
  801bef:	78 1f                	js     801c10 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bf1:	83 ec 04             	sub    $0x4,%esp
  801bf4:	ff 75 10             	pushl  0x10(%ebp)
  801bf7:	ff 75 0c             	pushl  0xc(%ebp)
  801bfa:	50                   	push   %eax
  801bfb:	e8 12 01 00 00       	call   801d12 <nsipc_accept>
  801c00:	83 c4 10             	add    $0x10,%esp
		return r;
  801c03:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c05:	85 c0                	test   %eax,%eax
  801c07:	78 07                	js     801c10 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801c09:	e8 5d ff ff ff       	call   801b6b <alloc_sockfd>
  801c0e:	89 c1                	mov    %eax,%ecx
}
  801c10:	89 c8                	mov    %ecx,%eax
  801c12:	c9                   	leave  
  801c13:	c3                   	ret    

00801c14 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c14:	55                   	push   %ebp
  801c15:	89 e5                	mov    %esp,%ebp
  801c17:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1d:	e8 19 ff ff ff       	call   801b3b <fd2sockid>
  801c22:	85 c0                	test   %eax,%eax
  801c24:	78 12                	js     801c38 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801c26:	83 ec 04             	sub    $0x4,%esp
  801c29:	ff 75 10             	pushl  0x10(%ebp)
  801c2c:	ff 75 0c             	pushl  0xc(%ebp)
  801c2f:	50                   	push   %eax
  801c30:	e8 2d 01 00 00       	call   801d62 <nsipc_bind>
  801c35:	83 c4 10             	add    $0x10,%esp
}
  801c38:	c9                   	leave  
  801c39:	c3                   	ret    

00801c3a <shutdown>:

int
shutdown(int s, int how)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c40:	8b 45 08             	mov    0x8(%ebp),%eax
  801c43:	e8 f3 fe ff ff       	call   801b3b <fd2sockid>
  801c48:	85 c0                	test   %eax,%eax
  801c4a:	78 0f                	js     801c5b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801c4c:	83 ec 08             	sub    $0x8,%esp
  801c4f:	ff 75 0c             	pushl  0xc(%ebp)
  801c52:	50                   	push   %eax
  801c53:	e8 3f 01 00 00       	call   801d97 <nsipc_shutdown>
  801c58:	83 c4 10             	add    $0x10,%esp
}
  801c5b:	c9                   	leave  
  801c5c:	c3                   	ret    

00801c5d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c63:	8b 45 08             	mov    0x8(%ebp),%eax
  801c66:	e8 d0 fe ff ff       	call   801b3b <fd2sockid>
  801c6b:	85 c0                	test   %eax,%eax
  801c6d:	78 12                	js     801c81 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801c6f:	83 ec 04             	sub    $0x4,%esp
  801c72:	ff 75 10             	pushl  0x10(%ebp)
  801c75:	ff 75 0c             	pushl  0xc(%ebp)
  801c78:	50                   	push   %eax
  801c79:	e8 55 01 00 00       	call   801dd3 <nsipc_connect>
  801c7e:	83 c4 10             	add    $0x10,%esp
}
  801c81:	c9                   	leave  
  801c82:	c3                   	ret    

00801c83 <listen>:

int
listen(int s, int backlog)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c89:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8c:	e8 aa fe ff ff       	call   801b3b <fd2sockid>
  801c91:	85 c0                	test   %eax,%eax
  801c93:	78 0f                	js     801ca4 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c95:	83 ec 08             	sub    $0x8,%esp
  801c98:	ff 75 0c             	pushl  0xc(%ebp)
  801c9b:	50                   	push   %eax
  801c9c:	e8 67 01 00 00       	call   801e08 <nsipc_listen>
  801ca1:	83 c4 10             	add    $0x10,%esp
}
  801ca4:	c9                   	leave  
  801ca5:	c3                   	ret    

00801ca6 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ca6:	55                   	push   %ebp
  801ca7:	89 e5                	mov    %esp,%ebp
  801ca9:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801cac:	ff 75 10             	pushl  0x10(%ebp)
  801caf:	ff 75 0c             	pushl  0xc(%ebp)
  801cb2:	ff 75 08             	pushl  0x8(%ebp)
  801cb5:	e8 3a 02 00 00       	call   801ef4 <nsipc_socket>
  801cba:	83 c4 10             	add    $0x10,%esp
  801cbd:	85 c0                	test   %eax,%eax
  801cbf:	78 05                	js     801cc6 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801cc1:	e8 a5 fe ff ff       	call   801b6b <alloc_sockfd>
}
  801cc6:	c9                   	leave  
  801cc7:	c3                   	ret    

00801cc8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801cc8:	55                   	push   %ebp
  801cc9:	89 e5                	mov    %esp,%ebp
  801ccb:	53                   	push   %ebx
  801ccc:	83 ec 04             	sub    $0x4,%esp
  801ccf:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801cd1:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801cd8:	75 12                	jne    801cec <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801cda:	83 ec 0c             	sub    $0xc,%esp
  801cdd:	6a 02                	push   $0x2
  801cdf:	e8 4c 08 00 00       	call   802530 <ipc_find_env>
  801ce4:	a3 04 40 80 00       	mov    %eax,0x804004
  801ce9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801cec:	6a 07                	push   $0x7
  801cee:	68 00 60 80 00       	push   $0x806000
  801cf3:	53                   	push   %ebx
  801cf4:	ff 35 04 40 80 00    	pushl  0x804004
  801cfa:	e8 dd 07 00 00       	call   8024dc <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801cff:	83 c4 0c             	add    $0xc,%esp
  801d02:	6a 00                	push   $0x0
  801d04:	6a 00                	push   $0x0
  801d06:	6a 00                	push   $0x0
  801d08:	e8 66 07 00 00       	call   802473 <ipc_recv>
}
  801d0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d10:	c9                   	leave  
  801d11:	c3                   	ret    

00801d12 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
  801d15:	56                   	push   %esi
  801d16:	53                   	push   %ebx
  801d17:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d22:	8b 06                	mov    (%esi),%eax
  801d24:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d29:	b8 01 00 00 00       	mov    $0x1,%eax
  801d2e:	e8 95 ff ff ff       	call   801cc8 <nsipc>
  801d33:	89 c3                	mov    %eax,%ebx
  801d35:	85 c0                	test   %eax,%eax
  801d37:	78 20                	js     801d59 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d39:	83 ec 04             	sub    $0x4,%esp
  801d3c:	ff 35 10 60 80 00    	pushl  0x806010
  801d42:	68 00 60 80 00       	push   $0x806000
  801d47:	ff 75 0c             	pushl  0xc(%ebp)
  801d4a:	e8 39 ed ff ff       	call   800a88 <memmove>
		*addrlen = ret->ret_addrlen;
  801d4f:	a1 10 60 80 00       	mov    0x806010,%eax
  801d54:	89 06                	mov    %eax,(%esi)
  801d56:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d59:	89 d8                	mov    %ebx,%eax
  801d5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d5e:	5b                   	pop    %ebx
  801d5f:	5e                   	pop    %esi
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    

00801d62 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	53                   	push   %ebx
  801d66:	83 ec 08             	sub    $0x8,%esp
  801d69:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d74:	53                   	push   %ebx
  801d75:	ff 75 0c             	pushl  0xc(%ebp)
  801d78:	68 04 60 80 00       	push   $0x806004
  801d7d:	e8 06 ed ff ff       	call   800a88 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d82:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d88:	b8 02 00 00 00       	mov    $0x2,%eax
  801d8d:	e8 36 ff ff ff       	call   801cc8 <nsipc>
}
  801d92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d95:	c9                   	leave  
  801d96:	c3                   	ret    

00801d97 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801da0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801da5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da8:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801dad:	b8 03 00 00 00       	mov    $0x3,%eax
  801db2:	e8 11 ff ff ff       	call   801cc8 <nsipc>
}
  801db7:	c9                   	leave  
  801db8:	c3                   	ret    

00801db9 <nsipc_close>:

int
nsipc_close(int s)
{
  801db9:	55                   	push   %ebp
  801dba:	89 e5                	mov    %esp,%ebp
  801dbc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc2:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801dc7:	b8 04 00 00 00       	mov    $0x4,%eax
  801dcc:	e8 f7 fe ff ff       	call   801cc8 <nsipc>
}
  801dd1:	c9                   	leave  
  801dd2:	c3                   	ret    

00801dd3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	53                   	push   %ebx
  801dd7:	83 ec 08             	sub    $0x8,%esp
  801dda:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  801de0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801de5:	53                   	push   %ebx
  801de6:	ff 75 0c             	pushl  0xc(%ebp)
  801de9:	68 04 60 80 00       	push   $0x806004
  801dee:	e8 95 ec ff ff       	call   800a88 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801df3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801df9:	b8 05 00 00 00       	mov    $0x5,%eax
  801dfe:	e8 c5 fe ff ff       	call   801cc8 <nsipc>
}
  801e03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e06:	c9                   	leave  
  801e07:	c3                   	ret    

00801e08 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e08:	55                   	push   %ebp
  801e09:	89 e5                	mov    %esp,%ebp
  801e0b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e11:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e16:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e19:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e1e:	b8 06 00 00 00       	mov    $0x6,%eax
  801e23:	e8 a0 fe ff ff       	call   801cc8 <nsipc>
}
  801e28:	c9                   	leave  
  801e29:	c3                   	ret    

00801e2a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e2a:	55                   	push   %ebp
  801e2b:	89 e5                	mov    %esp,%ebp
  801e2d:	56                   	push   %esi
  801e2e:	53                   	push   %ebx
  801e2f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e32:	8b 45 08             	mov    0x8(%ebp),%eax
  801e35:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e3a:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e40:	8b 45 14             	mov    0x14(%ebp),%eax
  801e43:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e48:	b8 07 00 00 00       	mov    $0x7,%eax
  801e4d:	e8 76 fe ff ff       	call   801cc8 <nsipc>
  801e52:	89 c3                	mov    %eax,%ebx
  801e54:	85 c0                	test   %eax,%eax
  801e56:	78 35                	js     801e8d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e58:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e5d:	7f 04                	jg     801e63 <nsipc_recv+0x39>
  801e5f:	39 c6                	cmp    %eax,%esi
  801e61:	7d 16                	jge    801e79 <nsipc_recv+0x4f>
  801e63:	68 db 2d 80 00       	push   $0x802ddb
  801e68:	68 9c 2d 80 00       	push   $0x802d9c
  801e6d:	6a 62                	push   $0x62
  801e6f:	68 f0 2d 80 00       	push   $0x802df0
  801e74:	e8 1f e4 ff ff       	call   800298 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e79:	83 ec 04             	sub    $0x4,%esp
  801e7c:	50                   	push   %eax
  801e7d:	68 00 60 80 00       	push   $0x806000
  801e82:	ff 75 0c             	pushl  0xc(%ebp)
  801e85:	e8 fe eb ff ff       	call   800a88 <memmove>
  801e8a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e8d:	89 d8                	mov    %ebx,%eax
  801e8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e92:	5b                   	pop    %ebx
  801e93:	5e                   	pop    %esi
  801e94:	5d                   	pop    %ebp
  801e95:	c3                   	ret    

00801e96 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e96:	55                   	push   %ebp
  801e97:	89 e5                	mov    %esp,%ebp
  801e99:	53                   	push   %ebx
  801e9a:	83 ec 04             	sub    $0x4,%esp
  801e9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ea0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea3:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ea8:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801eae:	7e 16                	jle    801ec6 <nsipc_send+0x30>
  801eb0:	68 fc 2d 80 00       	push   $0x802dfc
  801eb5:	68 9c 2d 80 00       	push   $0x802d9c
  801eba:	6a 6d                	push   $0x6d
  801ebc:	68 f0 2d 80 00       	push   $0x802df0
  801ec1:	e8 d2 e3 ff ff       	call   800298 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ec6:	83 ec 04             	sub    $0x4,%esp
  801ec9:	53                   	push   %ebx
  801eca:	ff 75 0c             	pushl  0xc(%ebp)
  801ecd:	68 0c 60 80 00       	push   $0x80600c
  801ed2:	e8 b1 eb ff ff       	call   800a88 <memmove>
	nsipcbuf.send.req_size = size;
  801ed7:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801edd:	8b 45 14             	mov    0x14(%ebp),%eax
  801ee0:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ee5:	b8 08 00 00 00       	mov    $0x8,%eax
  801eea:	e8 d9 fd ff ff       	call   801cc8 <nsipc>
}
  801eef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ef2:	c9                   	leave  
  801ef3:	c3                   	ret    

00801ef4 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ef4:	55                   	push   %ebp
  801ef5:	89 e5                	mov    %esp,%ebp
  801ef7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801efa:	8b 45 08             	mov    0x8(%ebp),%eax
  801efd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801f02:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f05:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801f0a:	8b 45 10             	mov    0x10(%ebp),%eax
  801f0d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801f12:	b8 09 00 00 00       	mov    $0x9,%eax
  801f17:	e8 ac fd ff ff       	call   801cc8 <nsipc>
}
  801f1c:	c9                   	leave  
  801f1d:	c3                   	ret    

00801f1e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f1e:	55                   	push   %ebp
  801f1f:	89 e5                	mov    %esp,%ebp
  801f21:	56                   	push   %esi
  801f22:	53                   	push   %ebx
  801f23:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f26:	83 ec 0c             	sub    $0xc,%esp
  801f29:	ff 75 08             	pushl  0x8(%ebp)
  801f2c:	e8 62 f3 ff ff       	call   801293 <fd2data>
  801f31:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f33:	83 c4 08             	add    $0x8,%esp
  801f36:	68 08 2e 80 00       	push   $0x802e08
  801f3b:	53                   	push   %ebx
  801f3c:	e8 b5 e9 ff ff       	call   8008f6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f41:	8b 46 04             	mov    0x4(%esi),%eax
  801f44:	2b 06                	sub    (%esi),%eax
  801f46:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f4c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f53:	00 00 00 
	stat->st_dev = &devpipe;
  801f56:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801f5d:	30 80 00 
	return 0;
}
  801f60:	b8 00 00 00 00       	mov    $0x0,%eax
  801f65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f68:	5b                   	pop    %ebx
  801f69:	5e                   	pop    %esi
  801f6a:	5d                   	pop    %ebp
  801f6b:	c3                   	ret    

00801f6c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f6c:	55                   	push   %ebp
  801f6d:	89 e5                	mov    %esp,%ebp
  801f6f:	53                   	push   %ebx
  801f70:	83 ec 0c             	sub    $0xc,%esp
  801f73:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f76:	53                   	push   %ebx
  801f77:	6a 00                	push   $0x0
  801f79:	e8 00 ee ff ff       	call   800d7e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f7e:	89 1c 24             	mov    %ebx,(%esp)
  801f81:	e8 0d f3 ff ff       	call   801293 <fd2data>
  801f86:	83 c4 08             	add    $0x8,%esp
  801f89:	50                   	push   %eax
  801f8a:	6a 00                	push   $0x0
  801f8c:	e8 ed ed ff ff       	call   800d7e <sys_page_unmap>
}
  801f91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f94:	c9                   	leave  
  801f95:	c3                   	ret    

00801f96 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f96:	55                   	push   %ebp
  801f97:	89 e5                	mov    %esp,%ebp
  801f99:	57                   	push   %edi
  801f9a:	56                   	push   %esi
  801f9b:	53                   	push   %ebx
  801f9c:	83 ec 1c             	sub    $0x1c,%esp
  801f9f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801fa2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801fa4:	a1 08 40 80 00       	mov    0x804008,%eax
  801fa9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801fac:	83 ec 0c             	sub    $0xc,%esp
  801faf:	ff 75 e0             	pushl  -0x20(%ebp)
  801fb2:	e8 b2 05 00 00       	call   802569 <pageref>
  801fb7:	89 c3                	mov    %eax,%ebx
  801fb9:	89 3c 24             	mov    %edi,(%esp)
  801fbc:	e8 a8 05 00 00       	call   802569 <pageref>
  801fc1:	83 c4 10             	add    $0x10,%esp
  801fc4:	39 c3                	cmp    %eax,%ebx
  801fc6:	0f 94 c1             	sete   %cl
  801fc9:	0f b6 c9             	movzbl %cl,%ecx
  801fcc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801fcf:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801fd5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fd8:	39 ce                	cmp    %ecx,%esi
  801fda:	74 1b                	je     801ff7 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801fdc:	39 c3                	cmp    %eax,%ebx
  801fde:	75 c4                	jne    801fa4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fe0:	8b 42 58             	mov    0x58(%edx),%eax
  801fe3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801fe6:	50                   	push   %eax
  801fe7:	56                   	push   %esi
  801fe8:	68 0f 2e 80 00       	push   $0x802e0f
  801fed:	e8 7f e3 ff ff       	call   800371 <cprintf>
  801ff2:	83 c4 10             	add    $0x10,%esp
  801ff5:	eb ad                	jmp    801fa4 <_pipeisclosed+0xe>
	}
}
  801ff7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ffa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ffd:	5b                   	pop    %ebx
  801ffe:	5e                   	pop    %esi
  801fff:	5f                   	pop    %edi
  802000:	5d                   	pop    %ebp
  802001:	c3                   	ret    

00802002 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802002:	55                   	push   %ebp
  802003:	89 e5                	mov    %esp,%ebp
  802005:	57                   	push   %edi
  802006:	56                   	push   %esi
  802007:	53                   	push   %ebx
  802008:	83 ec 28             	sub    $0x28,%esp
  80200b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80200e:	56                   	push   %esi
  80200f:	e8 7f f2 ff ff       	call   801293 <fd2data>
  802014:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802016:	83 c4 10             	add    $0x10,%esp
  802019:	bf 00 00 00 00       	mov    $0x0,%edi
  80201e:	eb 4b                	jmp    80206b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802020:	89 da                	mov    %ebx,%edx
  802022:	89 f0                	mov    %esi,%eax
  802024:	e8 6d ff ff ff       	call   801f96 <_pipeisclosed>
  802029:	85 c0                	test   %eax,%eax
  80202b:	75 48                	jne    802075 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80202d:	e8 a8 ec ff ff       	call   800cda <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802032:	8b 43 04             	mov    0x4(%ebx),%eax
  802035:	8b 0b                	mov    (%ebx),%ecx
  802037:	8d 51 20             	lea    0x20(%ecx),%edx
  80203a:	39 d0                	cmp    %edx,%eax
  80203c:	73 e2                	jae    802020 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80203e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802041:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802045:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802048:	89 c2                	mov    %eax,%edx
  80204a:	c1 fa 1f             	sar    $0x1f,%edx
  80204d:	89 d1                	mov    %edx,%ecx
  80204f:	c1 e9 1b             	shr    $0x1b,%ecx
  802052:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802055:	83 e2 1f             	and    $0x1f,%edx
  802058:	29 ca                	sub    %ecx,%edx
  80205a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80205e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802062:	83 c0 01             	add    $0x1,%eax
  802065:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802068:	83 c7 01             	add    $0x1,%edi
  80206b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80206e:	75 c2                	jne    802032 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802070:	8b 45 10             	mov    0x10(%ebp),%eax
  802073:	eb 05                	jmp    80207a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802075:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80207a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80207d:	5b                   	pop    %ebx
  80207e:	5e                   	pop    %esi
  80207f:	5f                   	pop    %edi
  802080:	5d                   	pop    %ebp
  802081:	c3                   	ret    

00802082 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802082:	55                   	push   %ebp
  802083:	89 e5                	mov    %esp,%ebp
  802085:	57                   	push   %edi
  802086:	56                   	push   %esi
  802087:	53                   	push   %ebx
  802088:	83 ec 18             	sub    $0x18,%esp
  80208b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80208e:	57                   	push   %edi
  80208f:	e8 ff f1 ff ff       	call   801293 <fd2data>
  802094:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802096:	83 c4 10             	add    $0x10,%esp
  802099:	bb 00 00 00 00       	mov    $0x0,%ebx
  80209e:	eb 3d                	jmp    8020dd <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020a0:	85 db                	test   %ebx,%ebx
  8020a2:	74 04                	je     8020a8 <devpipe_read+0x26>
				return i;
  8020a4:	89 d8                	mov    %ebx,%eax
  8020a6:	eb 44                	jmp    8020ec <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020a8:	89 f2                	mov    %esi,%edx
  8020aa:	89 f8                	mov    %edi,%eax
  8020ac:	e8 e5 fe ff ff       	call   801f96 <_pipeisclosed>
  8020b1:	85 c0                	test   %eax,%eax
  8020b3:	75 32                	jne    8020e7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020b5:	e8 20 ec ff ff       	call   800cda <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020ba:	8b 06                	mov    (%esi),%eax
  8020bc:	3b 46 04             	cmp    0x4(%esi),%eax
  8020bf:	74 df                	je     8020a0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020c1:	99                   	cltd   
  8020c2:	c1 ea 1b             	shr    $0x1b,%edx
  8020c5:	01 d0                	add    %edx,%eax
  8020c7:	83 e0 1f             	and    $0x1f,%eax
  8020ca:	29 d0                	sub    %edx,%eax
  8020cc:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8020d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020d4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8020d7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020da:	83 c3 01             	add    $0x1,%ebx
  8020dd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020e0:	75 d8                	jne    8020ba <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8020e5:	eb 05                	jmp    8020ec <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020e7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ef:	5b                   	pop    %ebx
  8020f0:	5e                   	pop    %esi
  8020f1:	5f                   	pop    %edi
  8020f2:	5d                   	pop    %ebp
  8020f3:	c3                   	ret    

008020f4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020f4:	55                   	push   %ebp
  8020f5:	89 e5                	mov    %esp,%ebp
  8020f7:	56                   	push   %esi
  8020f8:	53                   	push   %ebx
  8020f9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ff:	50                   	push   %eax
  802100:	e8 a5 f1 ff ff       	call   8012aa <fd_alloc>
  802105:	83 c4 10             	add    $0x10,%esp
  802108:	89 c2                	mov    %eax,%edx
  80210a:	85 c0                	test   %eax,%eax
  80210c:	0f 88 2c 01 00 00    	js     80223e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802112:	83 ec 04             	sub    $0x4,%esp
  802115:	68 07 04 00 00       	push   $0x407
  80211a:	ff 75 f4             	pushl  -0xc(%ebp)
  80211d:	6a 00                	push   $0x0
  80211f:	e8 d5 eb ff ff       	call   800cf9 <sys_page_alloc>
  802124:	83 c4 10             	add    $0x10,%esp
  802127:	89 c2                	mov    %eax,%edx
  802129:	85 c0                	test   %eax,%eax
  80212b:	0f 88 0d 01 00 00    	js     80223e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802131:	83 ec 0c             	sub    $0xc,%esp
  802134:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802137:	50                   	push   %eax
  802138:	e8 6d f1 ff ff       	call   8012aa <fd_alloc>
  80213d:	89 c3                	mov    %eax,%ebx
  80213f:	83 c4 10             	add    $0x10,%esp
  802142:	85 c0                	test   %eax,%eax
  802144:	0f 88 e2 00 00 00    	js     80222c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80214a:	83 ec 04             	sub    $0x4,%esp
  80214d:	68 07 04 00 00       	push   $0x407
  802152:	ff 75 f0             	pushl  -0x10(%ebp)
  802155:	6a 00                	push   $0x0
  802157:	e8 9d eb ff ff       	call   800cf9 <sys_page_alloc>
  80215c:	89 c3                	mov    %eax,%ebx
  80215e:	83 c4 10             	add    $0x10,%esp
  802161:	85 c0                	test   %eax,%eax
  802163:	0f 88 c3 00 00 00    	js     80222c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802169:	83 ec 0c             	sub    $0xc,%esp
  80216c:	ff 75 f4             	pushl  -0xc(%ebp)
  80216f:	e8 1f f1 ff ff       	call   801293 <fd2data>
  802174:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802176:	83 c4 0c             	add    $0xc,%esp
  802179:	68 07 04 00 00       	push   $0x407
  80217e:	50                   	push   %eax
  80217f:	6a 00                	push   $0x0
  802181:	e8 73 eb ff ff       	call   800cf9 <sys_page_alloc>
  802186:	89 c3                	mov    %eax,%ebx
  802188:	83 c4 10             	add    $0x10,%esp
  80218b:	85 c0                	test   %eax,%eax
  80218d:	0f 88 89 00 00 00    	js     80221c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802193:	83 ec 0c             	sub    $0xc,%esp
  802196:	ff 75 f0             	pushl  -0x10(%ebp)
  802199:	e8 f5 f0 ff ff       	call   801293 <fd2data>
  80219e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021a5:	50                   	push   %eax
  8021a6:	6a 00                	push   $0x0
  8021a8:	56                   	push   %esi
  8021a9:	6a 00                	push   $0x0
  8021ab:	e8 8c eb ff ff       	call   800d3c <sys_page_map>
  8021b0:	89 c3                	mov    %eax,%ebx
  8021b2:	83 c4 20             	add    $0x20,%esp
  8021b5:	85 c0                	test   %eax,%eax
  8021b7:	78 55                	js     80220e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021b9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021ce:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021d7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021dc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021e3:	83 ec 0c             	sub    $0xc,%esp
  8021e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8021e9:	e8 95 f0 ff ff       	call   801283 <fd2num>
  8021ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021f1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021f3:	83 c4 04             	add    $0x4,%esp
  8021f6:	ff 75 f0             	pushl  -0x10(%ebp)
  8021f9:	e8 85 f0 ff ff       	call   801283 <fd2num>
  8021fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802201:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802204:	83 c4 10             	add    $0x10,%esp
  802207:	ba 00 00 00 00       	mov    $0x0,%edx
  80220c:	eb 30                	jmp    80223e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80220e:	83 ec 08             	sub    $0x8,%esp
  802211:	56                   	push   %esi
  802212:	6a 00                	push   $0x0
  802214:	e8 65 eb ff ff       	call   800d7e <sys_page_unmap>
  802219:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80221c:	83 ec 08             	sub    $0x8,%esp
  80221f:	ff 75 f0             	pushl  -0x10(%ebp)
  802222:	6a 00                	push   $0x0
  802224:	e8 55 eb ff ff       	call   800d7e <sys_page_unmap>
  802229:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80222c:	83 ec 08             	sub    $0x8,%esp
  80222f:	ff 75 f4             	pushl  -0xc(%ebp)
  802232:	6a 00                	push   $0x0
  802234:	e8 45 eb ff ff       	call   800d7e <sys_page_unmap>
  802239:	83 c4 10             	add    $0x10,%esp
  80223c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80223e:	89 d0                	mov    %edx,%eax
  802240:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802243:	5b                   	pop    %ebx
  802244:	5e                   	pop    %esi
  802245:	5d                   	pop    %ebp
  802246:	c3                   	ret    

00802247 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802247:	55                   	push   %ebp
  802248:	89 e5                	mov    %esp,%ebp
  80224a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80224d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802250:	50                   	push   %eax
  802251:	ff 75 08             	pushl  0x8(%ebp)
  802254:	e8 a0 f0 ff ff       	call   8012f9 <fd_lookup>
  802259:	83 c4 10             	add    $0x10,%esp
  80225c:	85 c0                	test   %eax,%eax
  80225e:	78 18                	js     802278 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802260:	83 ec 0c             	sub    $0xc,%esp
  802263:	ff 75 f4             	pushl  -0xc(%ebp)
  802266:	e8 28 f0 ff ff       	call   801293 <fd2data>
	return _pipeisclosed(fd, p);
  80226b:	89 c2                	mov    %eax,%edx
  80226d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802270:	e8 21 fd ff ff       	call   801f96 <_pipeisclosed>
  802275:	83 c4 10             	add    $0x10,%esp
}
  802278:	c9                   	leave  
  802279:	c3                   	ret    

0080227a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80227a:	55                   	push   %ebp
  80227b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80227d:	b8 00 00 00 00       	mov    $0x0,%eax
  802282:	5d                   	pop    %ebp
  802283:	c3                   	ret    

00802284 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802284:	55                   	push   %ebp
  802285:	89 e5                	mov    %esp,%ebp
  802287:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80228a:	68 22 2e 80 00       	push   $0x802e22
  80228f:	ff 75 0c             	pushl  0xc(%ebp)
  802292:	e8 5f e6 ff ff       	call   8008f6 <strcpy>
	return 0;
}
  802297:	b8 00 00 00 00       	mov    $0x0,%eax
  80229c:	c9                   	leave  
  80229d:	c3                   	ret    

0080229e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80229e:	55                   	push   %ebp
  80229f:	89 e5                	mov    %esp,%ebp
  8022a1:	57                   	push   %edi
  8022a2:	56                   	push   %esi
  8022a3:	53                   	push   %ebx
  8022a4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022aa:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022af:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022b5:	eb 2d                	jmp    8022e4 <devcons_write+0x46>
		m = n - tot;
  8022b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022ba:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8022bc:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022bf:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8022c4:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022c7:	83 ec 04             	sub    $0x4,%esp
  8022ca:	53                   	push   %ebx
  8022cb:	03 45 0c             	add    0xc(%ebp),%eax
  8022ce:	50                   	push   %eax
  8022cf:	57                   	push   %edi
  8022d0:	e8 b3 e7 ff ff       	call   800a88 <memmove>
		sys_cputs(buf, m);
  8022d5:	83 c4 08             	add    $0x8,%esp
  8022d8:	53                   	push   %ebx
  8022d9:	57                   	push   %edi
  8022da:	e8 5e e9 ff ff       	call   800c3d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022df:	01 de                	add    %ebx,%esi
  8022e1:	83 c4 10             	add    $0x10,%esp
  8022e4:	89 f0                	mov    %esi,%eax
  8022e6:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022e9:	72 cc                	jb     8022b7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022ee:	5b                   	pop    %ebx
  8022ef:	5e                   	pop    %esi
  8022f0:	5f                   	pop    %edi
  8022f1:	5d                   	pop    %ebp
  8022f2:	c3                   	ret    

008022f3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022f3:	55                   	push   %ebp
  8022f4:	89 e5                	mov    %esp,%ebp
  8022f6:	83 ec 08             	sub    $0x8,%esp
  8022f9:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8022fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802302:	74 2a                	je     80232e <devcons_read+0x3b>
  802304:	eb 05                	jmp    80230b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802306:	e8 cf e9 ff ff       	call   800cda <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80230b:	e8 4b e9 ff ff       	call   800c5b <sys_cgetc>
  802310:	85 c0                	test   %eax,%eax
  802312:	74 f2                	je     802306 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802314:	85 c0                	test   %eax,%eax
  802316:	78 16                	js     80232e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802318:	83 f8 04             	cmp    $0x4,%eax
  80231b:	74 0c                	je     802329 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80231d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802320:	88 02                	mov    %al,(%edx)
	return 1;
  802322:	b8 01 00 00 00       	mov    $0x1,%eax
  802327:	eb 05                	jmp    80232e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802329:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80232e:	c9                   	leave  
  80232f:	c3                   	ret    

00802330 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802330:	55                   	push   %ebp
  802331:	89 e5                	mov    %esp,%ebp
  802333:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802336:	8b 45 08             	mov    0x8(%ebp),%eax
  802339:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80233c:	6a 01                	push   $0x1
  80233e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802341:	50                   	push   %eax
  802342:	e8 f6 e8 ff ff       	call   800c3d <sys_cputs>
}
  802347:	83 c4 10             	add    $0x10,%esp
  80234a:	c9                   	leave  
  80234b:	c3                   	ret    

0080234c <getchar>:

int
getchar(void)
{
  80234c:	55                   	push   %ebp
  80234d:	89 e5                	mov    %esp,%ebp
  80234f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802352:	6a 01                	push   $0x1
  802354:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802357:	50                   	push   %eax
  802358:	6a 00                	push   $0x0
  80235a:	e8 00 f2 ff ff       	call   80155f <read>
	if (r < 0)
  80235f:	83 c4 10             	add    $0x10,%esp
  802362:	85 c0                	test   %eax,%eax
  802364:	78 0f                	js     802375 <getchar+0x29>
		return r;
	if (r < 1)
  802366:	85 c0                	test   %eax,%eax
  802368:	7e 06                	jle    802370 <getchar+0x24>
		return -E_EOF;
	return c;
  80236a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80236e:	eb 05                	jmp    802375 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802370:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802375:	c9                   	leave  
  802376:	c3                   	ret    

00802377 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802377:	55                   	push   %ebp
  802378:	89 e5                	mov    %esp,%ebp
  80237a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80237d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802380:	50                   	push   %eax
  802381:	ff 75 08             	pushl  0x8(%ebp)
  802384:	e8 70 ef ff ff       	call   8012f9 <fd_lookup>
  802389:	83 c4 10             	add    $0x10,%esp
  80238c:	85 c0                	test   %eax,%eax
  80238e:	78 11                	js     8023a1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802390:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802393:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802399:	39 10                	cmp    %edx,(%eax)
  80239b:	0f 94 c0             	sete   %al
  80239e:	0f b6 c0             	movzbl %al,%eax
}
  8023a1:	c9                   	leave  
  8023a2:	c3                   	ret    

008023a3 <opencons>:

int
opencons(void)
{
  8023a3:	55                   	push   %ebp
  8023a4:	89 e5                	mov    %esp,%ebp
  8023a6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023ac:	50                   	push   %eax
  8023ad:	e8 f8 ee ff ff       	call   8012aa <fd_alloc>
  8023b2:	83 c4 10             	add    $0x10,%esp
		return r;
  8023b5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023b7:	85 c0                	test   %eax,%eax
  8023b9:	78 3e                	js     8023f9 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023bb:	83 ec 04             	sub    $0x4,%esp
  8023be:	68 07 04 00 00       	push   $0x407
  8023c3:	ff 75 f4             	pushl  -0xc(%ebp)
  8023c6:	6a 00                	push   $0x0
  8023c8:	e8 2c e9 ff ff       	call   800cf9 <sys_page_alloc>
  8023cd:	83 c4 10             	add    $0x10,%esp
		return r;
  8023d0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023d2:	85 c0                	test   %eax,%eax
  8023d4:	78 23                	js     8023f9 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023d6:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023df:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023e4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023eb:	83 ec 0c             	sub    $0xc,%esp
  8023ee:	50                   	push   %eax
  8023ef:	e8 8f ee ff ff       	call   801283 <fd2num>
  8023f4:	89 c2                	mov    %eax,%edx
  8023f6:	83 c4 10             	add    $0x10,%esp
}
  8023f9:	89 d0                	mov    %edx,%eax
  8023fb:	c9                   	leave  
  8023fc:	c3                   	ret    

008023fd <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023fd:	55                   	push   %ebp
  8023fe:	89 e5                	mov    %esp,%ebp
  802400:	53                   	push   %ebx
  802401:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  802404:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80240b:	75 28                	jne    802435 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  80240d:	e8 a9 e8 ff ff       	call   800cbb <sys_getenvid>
  802412:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  802414:	83 ec 04             	sub    $0x4,%esp
  802417:	6a 06                	push   $0x6
  802419:	68 00 f0 bf ee       	push   $0xeebff000
  80241e:	50                   	push   %eax
  80241f:	e8 d5 e8 ff ff       	call   800cf9 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  802424:	83 c4 08             	add    $0x8,%esp
  802427:	68 42 24 80 00       	push   $0x802442
  80242c:	53                   	push   %ebx
  80242d:	e8 12 ea ff ff       	call   800e44 <sys_env_set_pgfault_upcall>
  802432:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802435:	8b 45 08             	mov    0x8(%ebp),%eax
  802438:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80243d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802440:	c9                   	leave  
  802441:	c3                   	ret    

00802442 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802442:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802443:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802448:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80244a:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  80244d:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  80244f:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  802452:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  802455:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  802458:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  80245b:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  80245e:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  802461:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  802464:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  802467:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  80246a:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  80246d:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  802470:	61                   	popa   
	popfl
  802471:	9d                   	popf   
	ret
  802472:	c3                   	ret    

00802473 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802473:	55                   	push   %ebp
  802474:	89 e5                	mov    %esp,%ebp
  802476:	56                   	push   %esi
  802477:	53                   	push   %ebx
  802478:	8b 75 08             	mov    0x8(%ebp),%esi
  80247b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80247e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  802481:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802483:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802488:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  80248b:	83 ec 0c             	sub    $0xc,%esp
  80248e:	50                   	push   %eax
  80248f:	e8 15 ea ff ff       	call   800ea9 <sys_ipc_recv>

	if (r < 0) {
  802494:	83 c4 10             	add    $0x10,%esp
  802497:	85 c0                	test   %eax,%eax
  802499:	79 16                	jns    8024b1 <ipc_recv+0x3e>
		if (from_env_store)
  80249b:	85 f6                	test   %esi,%esi
  80249d:	74 06                	je     8024a5 <ipc_recv+0x32>
			*from_env_store = 0;
  80249f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  8024a5:	85 db                	test   %ebx,%ebx
  8024a7:	74 2c                	je     8024d5 <ipc_recv+0x62>
			*perm_store = 0;
  8024a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8024af:	eb 24                	jmp    8024d5 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  8024b1:	85 f6                	test   %esi,%esi
  8024b3:	74 0a                	je     8024bf <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  8024b5:	a1 08 40 80 00       	mov    0x804008,%eax
  8024ba:	8b 40 74             	mov    0x74(%eax),%eax
  8024bd:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  8024bf:	85 db                	test   %ebx,%ebx
  8024c1:	74 0a                	je     8024cd <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  8024c3:	a1 08 40 80 00       	mov    0x804008,%eax
  8024c8:	8b 40 78             	mov    0x78(%eax),%eax
  8024cb:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  8024cd:	a1 08 40 80 00       	mov    0x804008,%eax
  8024d2:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8024d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024d8:	5b                   	pop    %ebx
  8024d9:	5e                   	pop    %esi
  8024da:	5d                   	pop    %ebp
  8024db:	c3                   	ret    

008024dc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024dc:	55                   	push   %ebp
  8024dd:	89 e5                	mov    %esp,%ebp
  8024df:	57                   	push   %edi
  8024e0:	56                   	push   %esi
  8024e1:	53                   	push   %ebx
  8024e2:	83 ec 0c             	sub    $0xc,%esp
  8024e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024e8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8024ee:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8024f0:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8024f5:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8024f8:	ff 75 14             	pushl  0x14(%ebp)
  8024fb:	53                   	push   %ebx
  8024fc:	56                   	push   %esi
  8024fd:	57                   	push   %edi
  8024fe:	e8 83 e9 ff ff       	call   800e86 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  802503:	83 c4 10             	add    $0x10,%esp
  802506:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802509:	75 07                	jne    802512 <ipc_send+0x36>
			sys_yield();
  80250b:	e8 ca e7 ff ff       	call   800cda <sys_yield>
  802510:	eb e6                	jmp    8024f8 <ipc_send+0x1c>
		} else if (r < 0) {
  802512:	85 c0                	test   %eax,%eax
  802514:	79 12                	jns    802528 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  802516:	50                   	push   %eax
  802517:	68 2e 2e 80 00       	push   $0x802e2e
  80251c:	6a 51                	push   $0x51
  80251e:	68 3b 2e 80 00       	push   $0x802e3b
  802523:	e8 70 dd ff ff       	call   800298 <_panic>
		}
	}
}
  802528:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80252b:	5b                   	pop    %ebx
  80252c:	5e                   	pop    %esi
  80252d:	5f                   	pop    %edi
  80252e:	5d                   	pop    %ebp
  80252f:	c3                   	ret    

00802530 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802530:	55                   	push   %ebp
  802531:	89 e5                	mov    %esp,%ebp
  802533:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802536:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80253b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80253e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802544:	8b 52 50             	mov    0x50(%edx),%edx
  802547:	39 ca                	cmp    %ecx,%edx
  802549:	75 0d                	jne    802558 <ipc_find_env+0x28>
			return envs[i].env_id;
  80254b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80254e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802553:	8b 40 48             	mov    0x48(%eax),%eax
  802556:	eb 0f                	jmp    802567 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802558:	83 c0 01             	add    $0x1,%eax
  80255b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802560:	75 d9                	jne    80253b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802562:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802567:	5d                   	pop    %ebp
  802568:	c3                   	ret    

00802569 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802569:	55                   	push   %ebp
  80256a:	89 e5                	mov    %esp,%ebp
  80256c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80256f:	89 d0                	mov    %edx,%eax
  802571:	c1 e8 16             	shr    $0x16,%eax
  802574:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80257b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802580:	f6 c1 01             	test   $0x1,%cl
  802583:	74 1d                	je     8025a2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802585:	c1 ea 0c             	shr    $0xc,%edx
  802588:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80258f:	f6 c2 01             	test   $0x1,%dl
  802592:	74 0e                	je     8025a2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802594:	c1 ea 0c             	shr    $0xc,%edx
  802597:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80259e:	ef 
  80259f:	0f b7 c0             	movzwl %ax,%eax
}
  8025a2:	5d                   	pop    %ebp
  8025a3:	c3                   	ret    
  8025a4:	66 90                	xchg   %ax,%ax
  8025a6:	66 90                	xchg   %ax,%ax
  8025a8:	66 90                	xchg   %ax,%ax
  8025aa:	66 90                	xchg   %ax,%ax
  8025ac:	66 90                	xchg   %ax,%ax
  8025ae:	66 90                	xchg   %ax,%ax

008025b0 <__udivdi3>:
  8025b0:	55                   	push   %ebp
  8025b1:	57                   	push   %edi
  8025b2:	56                   	push   %esi
  8025b3:	53                   	push   %ebx
  8025b4:	83 ec 1c             	sub    $0x1c,%esp
  8025b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8025bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8025bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8025c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025c7:	85 f6                	test   %esi,%esi
  8025c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025cd:	89 ca                	mov    %ecx,%edx
  8025cf:	89 f8                	mov    %edi,%eax
  8025d1:	75 3d                	jne    802610 <__udivdi3+0x60>
  8025d3:	39 cf                	cmp    %ecx,%edi
  8025d5:	0f 87 c5 00 00 00    	ja     8026a0 <__udivdi3+0xf0>
  8025db:	85 ff                	test   %edi,%edi
  8025dd:	89 fd                	mov    %edi,%ebp
  8025df:	75 0b                	jne    8025ec <__udivdi3+0x3c>
  8025e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025e6:	31 d2                	xor    %edx,%edx
  8025e8:	f7 f7                	div    %edi
  8025ea:	89 c5                	mov    %eax,%ebp
  8025ec:	89 c8                	mov    %ecx,%eax
  8025ee:	31 d2                	xor    %edx,%edx
  8025f0:	f7 f5                	div    %ebp
  8025f2:	89 c1                	mov    %eax,%ecx
  8025f4:	89 d8                	mov    %ebx,%eax
  8025f6:	89 cf                	mov    %ecx,%edi
  8025f8:	f7 f5                	div    %ebp
  8025fa:	89 c3                	mov    %eax,%ebx
  8025fc:	89 d8                	mov    %ebx,%eax
  8025fe:	89 fa                	mov    %edi,%edx
  802600:	83 c4 1c             	add    $0x1c,%esp
  802603:	5b                   	pop    %ebx
  802604:	5e                   	pop    %esi
  802605:	5f                   	pop    %edi
  802606:	5d                   	pop    %ebp
  802607:	c3                   	ret    
  802608:	90                   	nop
  802609:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802610:	39 ce                	cmp    %ecx,%esi
  802612:	77 74                	ja     802688 <__udivdi3+0xd8>
  802614:	0f bd fe             	bsr    %esi,%edi
  802617:	83 f7 1f             	xor    $0x1f,%edi
  80261a:	0f 84 98 00 00 00    	je     8026b8 <__udivdi3+0x108>
  802620:	bb 20 00 00 00       	mov    $0x20,%ebx
  802625:	89 f9                	mov    %edi,%ecx
  802627:	89 c5                	mov    %eax,%ebp
  802629:	29 fb                	sub    %edi,%ebx
  80262b:	d3 e6                	shl    %cl,%esi
  80262d:	89 d9                	mov    %ebx,%ecx
  80262f:	d3 ed                	shr    %cl,%ebp
  802631:	89 f9                	mov    %edi,%ecx
  802633:	d3 e0                	shl    %cl,%eax
  802635:	09 ee                	or     %ebp,%esi
  802637:	89 d9                	mov    %ebx,%ecx
  802639:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80263d:	89 d5                	mov    %edx,%ebp
  80263f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802643:	d3 ed                	shr    %cl,%ebp
  802645:	89 f9                	mov    %edi,%ecx
  802647:	d3 e2                	shl    %cl,%edx
  802649:	89 d9                	mov    %ebx,%ecx
  80264b:	d3 e8                	shr    %cl,%eax
  80264d:	09 c2                	or     %eax,%edx
  80264f:	89 d0                	mov    %edx,%eax
  802651:	89 ea                	mov    %ebp,%edx
  802653:	f7 f6                	div    %esi
  802655:	89 d5                	mov    %edx,%ebp
  802657:	89 c3                	mov    %eax,%ebx
  802659:	f7 64 24 0c          	mull   0xc(%esp)
  80265d:	39 d5                	cmp    %edx,%ebp
  80265f:	72 10                	jb     802671 <__udivdi3+0xc1>
  802661:	8b 74 24 08          	mov    0x8(%esp),%esi
  802665:	89 f9                	mov    %edi,%ecx
  802667:	d3 e6                	shl    %cl,%esi
  802669:	39 c6                	cmp    %eax,%esi
  80266b:	73 07                	jae    802674 <__udivdi3+0xc4>
  80266d:	39 d5                	cmp    %edx,%ebp
  80266f:	75 03                	jne    802674 <__udivdi3+0xc4>
  802671:	83 eb 01             	sub    $0x1,%ebx
  802674:	31 ff                	xor    %edi,%edi
  802676:	89 d8                	mov    %ebx,%eax
  802678:	89 fa                	mov    %edi,%edx
  80267a:	83 c4 1c             	add    $0x1c,%esp
  80267d:	5b                   	pop    %ebx
  80267e:	5e                   	pop    %esi
  80267f:	5f                   	pop    %edi
  802680:	5d                   	pop    %ebp
  802681:	c3                   	ret    
  802682:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802688:	31 ff                	xor    %edi,%edi
  80268a:	31 db                	xor    %ebx,%ebx
  80268c:	89 d8                	mov    %ebx,%eax
  80268e:	89 fa                	mov    %edi,%edx
  802690:	83 c4 1c             	add    $0x1c,%esp
  802693:	5b                   	pop    %ebx
  802694:	5e                   	pop    %esi
  802695:	5f                   	pop    %edi
  802696:	5d                   	pop    %ebp
  802697:	c3                   	ret    
  802698:	90                   	nop
  802699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	89 d8                	mov    %ebx,%eax
  8026a2:	f7 f7                	div    %edi
  8026a4:	31 ff                	xor    %edi,%edi
  8026a6:	89 c3                	mov    %eax,%ebx
  8026a8:	89 d8                	mov    %ebx,%eax
  8026aa:	89 fa                	mov    %edi,%edx
  8026ac:	83 c4 1c             	add    $0x1c,%esp
  8026af:	5b                   	pop    %ebx
  8026b0:	5e                   	pop    %esi
  8026b1:	5f                   	pop    %edi
  8026b2:	5d                   	pop    %ebp
  8026b3:	c3                   	ret    
  8026b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026b8:	39 ce                	cmp    %ecx,%esi
  8026ba:	72 0c                	jb     8026c8 <__udivdi3+0x118>
  8026bc:	31 db                	xor    %ebx,%ebx
  8026be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8026c2:	0f 87 34 ff ff ff    	ja     8025fc <__udivdi3+0x4c>
  8026c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8026cd:	e9 2a ff ff ff       	jmp    8025fc <__udivdi3+0x4c>
  8026d2:	66 90                	xchg   %ax,%ax
  8026d4:	66 90                	xchg   %ax,%ax
  8026d6:	66 90                	xchg   %ax,%ax
  8026d8:	66 90                	xchg   %ax,%ax
  8026da:	66 90                	xchg   %ax,%ax
  8026dc:	66 90                	xchg   %ax,%ax
  8026de:	66 90                	xchg   %ax,%ax

008026e0 <__umoddi3>:
  8026e0:	55                   	push   %ebp
  8026e1:	57                   	push   %edi
  8026e2:	56                   	push   %esi
  8026e3:	53                   	push   %ebx
  8026e4:	83 ec 1c             	sub    $0x1c,%esp
  8026e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8026f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026f7:	85 d2                	test   %edx,%edx
  8026f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802701:	89 f3                	mov    %esi,%ebx
  802703:	89 3c 24             	mov    %edi,(%esp)
  802706:	89 74 24 04          	mov    %esi,0x4(%esp)
  80270a:	75 1c                	jne    802728 <__umoddi3+0x48>
  80270c:	39 f7                	cmp    %esi,%edi
  80270e:	76 50                	jbe    802760 <__umoddi3+0x80>
  802710:	89 c8                	mov    %ecx,%eax
  802712:	89 f2                	mov    %esi,%edx
  802714:	f7 f7                	div    %edi
  802716:	89 d0                	mov    %edx,%eax
  802718:	31 d2                	xor    %edx,%edx
  80271a:	83 c4 1c             	add    $0x1c,%esp
  80271d:	5b                   	pop    %ebx
  80271e:	5e                   	pop    %esi
  80271f:	5f                   	pop    %edi
  802720:	5d                   	pop    %ebp
  802721:	c3                   	ret    
  802722:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802728:	39 f2                	cmp    %esi,%edx
  80272a:	89 d0                	mov    %edx,%eax
  80272c:	77 52                	ja     802780 <__umoddi3+0xa0>
  80272e:	0f bd ea             	bsr    %edx,%ebp
  802731:	83 f5 1f             	xor    $0x1f,%ebp
  802734:	75 5a                	jne    802790 <__umoddi3+0xb0>
  802736:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80273a:	0f 82 e0 00 00 00    	jb     802820 <__umoddi3+0x140>
  802740:	39 0c 24             	cmp    %ecx,(%esp)
  802743:	0f 86 d7 00 00 00    	jbe    802820 <__umoddi3+0x140>
  802749:	8b 44 24 08          	mov    0x8(%esp),%eax
  80274d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802751:	83 c4 1c             	add    $0x1c,%esp
  802754:	5b                   	pop    %ebx
  802755:	5e                   	pop    %esi
  802756:	5f                   	pop    %edi
  802757:	5d                   	pop    %ebp
  802758:	c3                   	ret    
  802759:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802760:	85 ff                	test   %edi,%edi
  802762:	89 fd                	mov    %edi,%ebp
  802764:	75 0b                	jne    802771 <__umoddi3+0x91>
  802766:	b8 01 00 00 00       	mov    $0x1,%eax
  80276b:	31 d2                	xor    %edx,%edx
  80276d:	f7 f7                	div    %edi
  80276f:	89 c5                	mov    %eax,%ebp
  802771:	89 f0                	mov    %esi,%eax
  802773:	31 d2                	xor    %edx,%edx
  802775:	f7 f5                	div    %ebp
  802777:	89 c8                	mov    %ecx,%eax
  802779:	f7 f5                	div    %ebp
  80277b:	89 d0                	mov    %edx,%eax
  80277d:	eb 99                	jmp    802718 <__umoddi3+0x38>
  80277f:	90                   	nop
  802780:	89 c8                	mov    %ecx,%eax
  802782:	89 f2                	mov    %esi,%edx
  802784:	83 c4 1c             	add    $0x1c,%esp
  802787:	5b                   	pop    %ebx
  802788:	5e                   	pop    %esi
  802789:	5f                   	pop    %edi
  80278a:	5d                   	pop    %ebp
  80278b:	c3                   	ret    
  80278c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802790:	8b 34 24             	mov    (%esp),%esi
  802793:	bf 20 00 00 00       	mov    $0x20,%edi
  802798:	89 e9                	mov    %ebp,%ecx
  80279a:	29 ef                	sub    %ebp,%edi
  80279c:	d3 e0                	shl    %cl,%eax
  80279e:	89 f9                	mov    %edi,%ecx
  8027a0:	89 f2                	mov    %esi,%edx
  8027a2:	d3 ea                	shr    %cl,%edx
  8027a4:	89 e9                	mov    %ebp,%ecx
  8027a6:	09 c2                	or     %eax,%edx
  8027a8:	89 d8                	mov    %ebx,%eax
  8027aa:	89 14 24             	mov    %edx,(%esp)
  8027ad:	89 f2                	mov    %esi,%edx
  8027af:	d3 e2                	shl    %cl,%edx
  8027b1:	89 f9                	mov    %edi,%ecx
  8027b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8027bb:	d3 e8                	shr    %cl,%eax
  8027bd:	89 e9                	mov    %ebp,%ecx
  8027bf:	89 c6                	mov    %eax,%esi
  8027c1:	d3 e3                	shl    %cl,%ebx
  8027c3:	89 f9                	mov    %edi,%ecx
  8027c5:	89 d0                	mov    %edx,%eax
  8027c7:	d3 e8                	shr    %cl,%eax
  8027c9:	89 e9                	mov    %ebp,%ecx
  8027cb:	09 d8                	or     %ebx,%eax
  8027cd:	89 d3                	mov    %edx,%ebx
  8027cf:	89 f2                	mov    %esi,%edx
  8027d1:	f7 34 24             	divl   (%esp)
  8027d4:	89 d6                	mov    %edx,%esi
  8027d6:	d3 e3                	shl    %cl,%ebx
  8027d8:	f7 64 24 04          	mull   0x4(%esp)
  8027dc:	39 d6                	cmp    %edx,%esi
  8027de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027e2:	89 d1                	mov    %edx,%ecx
  8027e4:	89 c3                	mov    %eax,%ebx
  8027e6:	72 08                	jb     8027f0 <__umoddi3+0x110>
  8027e8:	75 11                	jne    8027fb <__umoddi3+0x11b>
  8027ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8027ee:	73 0b                	jae    8027fb <__umoddi3+0x11b>
  8027f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8027f4:	1b 14 24             	sbb    (%esp),%edx
  8027f7:	89 d1                	mov    %edx,%ecx
  8027f9:	89 c3                	mov    %eax,%ebx
  8027fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8027ff:	29 da                	sub    %ebx,%edx
  802801:	19 ce                	sbb    %ecx,%esi
  802803:	89 f9                	mov    %edi,%ecx
  802805:	89 f0                	mov    %esi,%eax
  802807:	d3 e0                	shl    %cl,%eax
  802809:	89 e9                	mov    %ebp,%ecx
  80280b:	d3 ea                	shr    %cl,%edx
  80280d:	89 e9                	mov    %ebp,%ecx
  80280f:	d3 ee                	shr    %cl,%esi
  802811:	09 d0                	or     %edx,%eax
  802813:	89 f2                	mov    %esi,%edx
  802815:	83 c4 1c             	add    $0x1c,%esp
  802818:	5b                   	pop    %ebx
  802819:	5e                   	pop    %esi
  80281a:	5f                   	pop    %edi
  80281b:	5d                   	pop    %ebp
  80281c:	c3                   	ret    
  80281d:	8d 76 00             	lea    0x0(%esi),%esi
  802820:	29 f9                	sub    %edi,%ecx
  802822:	19 d6                	sbb    %edx,%esi
  802824:	89 74 24 04          	mov    %esi,0x4(%esp)
  802828:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80282c:	e9 18 ff ff ff       	jmp    802749 <__umoddi3+0x69>
