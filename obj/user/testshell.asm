
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 53 04 00 00       	call   800484 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 84 00 00 00    	sub    $0x84,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	53                   	push   %ebx
  800049:	56                   	push   %esi
  80004a:	e8 c2 18 00 00       	call   801911 <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 b8 18 00 00       	call   801911 <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 00 2f 80 00 	movl   $0x802f00,(%esp)
  800060:	e8 58 05 00 00       	call   8005bd <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 6b 2f 80 00 	movl   $0x802f6b,(%esp)
  80006c:	e8 4c 05 00 00       	call   8005bd <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 06 0e 00 00       	call   800e89 <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 19 17 00 00       	call   8017ab <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 7a 2f 80 00       	push   $0x802f7a
  8000a1:	e8 17 05 00 00       	call   8005bd <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 d1 0d 00 00       	call   800e89 <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 e4 16 00 00       	call   8017ab <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 75 2f 80 00       	push   $0x802f75
  8000d6:	e8 e2 04 00 00       	call   8005bd <cprintf>
	exit();
  8000db:	e8 ea 03 00 00       	call   8004ca <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 38             	sub    $0x38,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 74 15 00 00       	call   80166f <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 68 15 00 00       	call   80166f <close>
	opencons();
  800107:	e8 1e 03 00 00       	call   80042a <opencons>
	opencons();
  80010c:	e8 19 03 00 00       	call   80042a <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 88 2f 80 00       	push   $0x802f88
  80011b:	e8 3f 1b 00 00       	call   801c5f <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  800129:	50                   	push   %eax
  80012a:	68 95 2f 80 00       	push   $0x802f95
  80012f:	6a 13                	push   $0x13
  800131:	68 ab 2f 80 00       	push   $0x802fab
  800136:	e8 a9 03 00 00       	call   8004e4 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 a5 27 00 00       	call   8028ec <pipe>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0x75>
		panic("pipe: %e", wfd);
  80014e:	50                   	push   %eax
  80014f:	68 bc 2f 80 00       	push   $0x802fbc
  800154:	6a 15                	push   $0x15
  800156:	68 ab 2f 80 00       	push   $0x802fab
  80015b:	e8 84 03 00 00       	call   8004e4 <_panic>
	wfd = pfds[1];
  800160:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 24 2f 80 00       	push   $0x802f24
  80016b:	e8 4d 04 00 00       	call   8005bd <cprintf>
	if ((r = fork()) < 0)
  800170:	e8 7b 11 00 00       	call   8012f0 <fork>
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	85 c0                	test   %eax,%eax
  80017a:	79 12                	jns    80018e <umain+0xa3>
		panic("fork: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 06 34 80 00       	push   $0x803406
  800182:	6a 1a                	push   $0x1a
  800184:	68 ab 2f 80 00       	push   $0x802fab
  800189:	e8 56 03 00 00       	call   8004e4 <_panic>
	if (r == 0) {
  80018e:	85 c0                	test   %eax,%eax
  800190:	75 7d                	jne    80020f <umain+0x124>
		dup(rfd, 0);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	6a 00                	push   $0x0
  800197:	53                   	push   %ebx
  800198:	e8 22 15 00 00       	call   8016bf <dup>
		dup(wfd, 1);
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 01                	push   $0x1
  8001a2:	56                   	push   %esi
  8001a3:	e8 17 15 00 00       	call   8016bf <dup>
		close(rfd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 bf 14 00 00       	call   80166f <close>
		close(wfd);
  8001b0:	89 34 24             	mov    %esi,(%esp)
  8001b3:	e8 b7 14 00 00       	call   80166f <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b8:	6a 00                	push   $0x0
  8001ba:	68 c5 2f 80 00       	push   $0x802fc5
  8001bf:	68 92 2f 80 00       	push   $0x802f92
  8001c4:	68 c8 2f 80 00       	push   $0x802fc8
  8001c9:	e8 6e 20 00 00       	call   80223c <spawnl>
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	79 12                	jns    8001e9 <umain+0xfe>
			panic("spawn: %e", r);
  8001d7:	50                   	push   %eax
  8001d8:	68 cc 2f 80 00       	push   $0x802fcc
  8001dd:	6a 21                	push   $0x21
  8001df:	68 ab 2f 80 00       	push   $0x802fab
  8001e4:	e8 fb 02 00 00       	call   8004e4 <_panic>
		close(0);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	e8 7c 14 00 00       	call   80166f <close>
		close(1);
  8001f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fa:	e8 70 14 00 00       	call   80166f <close>
		wait(r);
  8001ff:	89 3c 24             	mov    %edi,(%esp)
  800202:	e8 6b 28 00 00       	call   802a72 <wait>
		exit();
  800207:	e8 be 02 00 00       	call   8004ca <exit>
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	53                   	push   %ebx
  800213:	e8 57 14 00 00       	call   80166f <close>
	close(wfd);
  800218:	89 34 24             	mov    %esi,(%esp)
  80021b:	e8 4f 14 00 00       	call   80166f <close>

	rfd = pfds[0];
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	6a 00                	push   $0x0
  80022b:	68 d6 2f 80 00       	push   $0x802fd6
  800230:	e8 2a 1a 00 00       	call   801c5f <open>
  800235:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 12                	jns    800251 <umain+0x166>
		panic("open testshell.key for reading: %e", kfd);
  80023f:	50                   	push   %eax
  800240:	68 48 2f 80 00       	push   $0x802f48
  800245:	6a 2c                	push   $0x2c
  800247:	68 ab 2f 80 00       	push   $0x802fab
  80024c:	e8 93 02 00 00       	call   8004e4 <_panic>
  800251:	be 01 00 00 00       	mov    $0x1,%esi
  800256:	bf 00 00 00 00       	mov    $0x0,%edi

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  80025b:	83 ec 04             	sub    $0x4,%esp
  80025e:	6a 01                	push   $0x1
  800260:	8d 45 e7             	lea    -0x19(%ebp),%eax
  800263:	50                   	push   %eax
  800264:	ff 75 d0             	pushl  -0x30(%ebp)
  800267:	e8 3f 15 00 00       	call   8017ab <read>
  80026c:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026e:	83 c4 0c             	add    $0xc,%esp
  800271:	6a 01                	push   $0x1
  800273:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	ff 75 d4             	pushl  -0x2c(%ebp)
  80027a:	e8 2c 15 00 00       	call   8017ab <read>
		if (n1 < 0)
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	85 db                	test   %ebx,%ebx
  800284:	79 12                	jns    800298 <umain+0x1ad>
			panic("reading testshell.out: %e", n1);
  800286:	53                   	push   %ebx
  800287:	68 e4 2f 80 00       	push   $0x802fe4
  80028c:	6a 33                	push   $0x33
  80028e:	68 ab 2f 80 00       	push   $0x802fab
  800293:	e8 4c 02 00 00       	call   8004e4 <_panic>
		if (n2 < 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	79 12                	jns    8002ae <umain+0x1c3>
			panic("reading testshell.key: %e", n2);
  80029c:	50                   	push   %eax
  80029d:	68 fe 2f 80 00       	push   $0x802ffe
  8002a2:	6a 35                	push   $0x35
  8002a4:	68 ab 2f 80 00       	push   $0x802fab
  8002a9:	e8 36 02 00 00       	call   8004e4 <_panic>
		if (n1 == 0 && n2 == 0)
  8002ae:	89 da                	mov    %ebx,%edx
  8002b0:	09 c2                	or     %eax,%edx
  8002b2:	74 34                	je     8002e8 <umain+0x1fd>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002b4:	83 fb 01             	cmp    $0x1,%ebx
  8002b7:	75 0e                	jne    8002c7 <umain+0x1dc>
  8002b9:	83 f8 01             	cmp    $0x1,%eax
  8002bc:	75 09                	jne    8002c7 <umain+0x1dc>
  8002be:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002c2:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002c5:	74 12                	je     8002d9 <umain+0x1ee>
			wrong(rfd, kfd, nloff);
  8002c7:	83 ec 04             	sub    $0x4,%esp
  8002ca:	57                   	push   %edi
  8002cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ce:	ff 75 d0             	pushl  -0x30(%ebp)
  8002d1:	e8 5d fd ff ff       	call   800033 <wrong>
  8002d6:	83 c4 10             	add    $0x10,%esp
		if (c1 == '\n')
			nloff = off+1;
  8002d9:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002dd:	0f 44 fe             	cmove  %esi,%edi
  8002e0:	83 c6 01             	add    $0x1,%esi
	}
  8002e3:	e9 73 ff ff ff       	jmp    80025b <umain+0x170>
	cprintf("shell ran correctly\n");
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	68 18 30 80 00       	push   $0x803018
  8002f0:	e8 c8 02 00 00       	call   8005bd <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8002f5:	cc                   	int3   

	breakpoint();
}
  8002f6:	83 c4 10             	add    $0x10,%esp
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800304:	b8 00 00 00 00       	mov    $0x0,%eax
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800311:	68 2d 30 80 00       	push   $0x80302d
  800316:	ff 75 0c             	pushl  0xc(%ebp)
  800319:	e8 24 08 00 00       	call   800b42 <strcpy>
	return 0;
}
  80031e:	b8 00 00 00 00       	mov    $0x0,%eax
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
  80032b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800331:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800336:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80033c:	eb 2d                	jmp    80036b <devcons_write+0x46>
		m = n - tot;
  80033e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800341:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800343:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800346:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80034b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	53                   	push   %ebx
  800352:	03 45 0c             	add    0xc(%ebp),%eax
  800355:	50                   	push   %eax
  800356:	57                   	push   %edi
  800357:	e8 78 09 00 00       	call   800cd4 <memmove>
		sys_cputs(buf, m);
  80035c:	83 c4 08             	add    $0x8,%esp
  80035f:	53                   	push   %ebx
  800360:	57                   	push   %edi
  800361:	e8 23 0b 00 00       	call   800e89 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800366:	01 de                	add    %ebx,%esi
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	89 f0                	mov    %esi,%eax
  80036d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800370:	72 cc                	jb     80033e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800385:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800389:	74 2a                	je     8003b5 <devcons_read+0x3b>
  80038b:	eb 05                	jmp    800392 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80038d:	e8 94 0b 00 00       	call   800f26 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800392:	e8 10 0b 00 00       	call   800ea7 <sys_cgetc>
  800397:	85 c0                	test   %eax,%eax
  800399:	74 f2                	je     80038d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80039b:	85 c0                	test   %eax,%eax
  80039d:	78 16                	js     8003b5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80039f:	83 f8 04             	cmp    $0x4,%eax
  8003a2:	74 0c                	je     8003b0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8003a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a7:	88 02                	mov    %al,(%edx)
	return 1;
  8003a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8003ae:	eb 05                	jmp    8003b5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8003b0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8003b5:	c9                   	leave  
  8003b6:	c3                   	ret    

008003b7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8003c3:	6a 01                	push   $0x1
  8003c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003c8:	50                   	push   %eax
  8003c9:	e8 bb 0a 00 00       	call   800e89 <sys_cputs>
}
  8003ce:	83 c4 10             	add    $0x10,%esp
  8003d1:	c9                   	leave  
  8003d2:	c3                   	ret    

008003d3 <getchar>:

int
getchar(void)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8003d9:	6a 01                	push   $0x1
  8003db:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003de:	50                   	push   %eax
  8003df:	6a 00                	push   $0x0
  8003e1:	e8 c5 13 00 00       	call   8017ab <read>
	if (r < 0)
  8003e6:	83 c4 10             	add    $0x10,%esp
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	78 0f                	js     8003fc <getchar+0x29>
		return r;
	if (r < 1)
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	7e 06                	jle    8003f7 <getchar+0x24>
		return -E_EOF;
	return c;
  8003f1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8003f5:	eb 05                	jmp    8003fc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8003f7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800404:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800407:	50                   	push   %eax
  800408:	ff 75 08             	pushl  0x8(%ebp)
  80040b:	e8 35 11 00 00       	call   801545 <fd_lookup>
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	85 c0                	test   %eax,%eax
  800415:	78 11                	js     800428 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800417:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80041a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800420:	39 10                	cmp    %edx,(%eax)
  800422:	0f 94 c0             	sete   %al
  800425:	0f b6 c0             	movzbl %al,%eax
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    

0080042a <opencons>:

int
opencons(void)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800430:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800433:	50                   	push   %eax
  800434:	e8 bd 10 00 00       	call   8014f6 <fd_alloc>
  800439:	83 c4 10             	add    $0x10,%esp
		return r;
  80043c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80043e:	85 c0                	test   %eax,%eax
  800440:	78 3e                	js     800480 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800442:	83 ec 04             	sub    $0x4,%esp
  800445:	68 07 04 00 00       	push   $0x407
  80044a:	ff 75 f4             	pushl  -0xc(%ebp)
  80044d:	6a 00                	push   $0x0
  80044f:	e8 f1 0a 00 00       	call   800f45 <sys_page_alloc>
  800454:	83 c4 10             	add    $0x10,%esp
		return r;
  800457:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800459:	85 c0                	test   %eax,%eax
  80045b:	78 23                	js     800480 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80045d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800463:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800466:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80046b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800472:	83 ec 0c             	sub    $0xc,%esp
  800475:	50                   	push   %eax
  800476:	e8 54 10 00 00       	call   8014cf <fd2num>
  80047b:	89 c2                	mov    %eax,%edx
  80047d:	83 c4 10             	add    $0x10,%esp
}
  800480:	89 d0                	mov    %edx,%eax
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	56                   	push   %esi
  800488:	53                   	push   %ebx
  800489:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80048c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80048f:	e8 73 0a 00 00       	call   800f07 <sys_getenvid>
  800494:	25 ff 03 00 00       	and    $0x3ff,%eax
  800499:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80049c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004a1:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004a6:	85 db                	test   %ebx,%ebx
  8004a8:	7e 07                	jle    8004b1 <libmain+0x2d>
		binaryname = argv[0];
  8004aa:	8b 06                	mov    (%esi),%eax
  8004ac:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	56                   	push   %esi
  8004b5:	53                   	push   %ebx
  8004b6:	e8 30 fc ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8004bb:	e8 0a 00 00 00       	call   8004ca <exit>
}
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004c6:	5b                   	pop    %ebx
  8004c7:	5e                   	pop    %esi
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004d0:	e8 c5 11 00 00       	call   80169a <close_all>
	sys_env_destroy(0);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 e7 09 00 00       	call   800ec6 <sys_env_destroy>
}
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	c9                   	leave  
  8004e3:	c3                   	ret    

008004e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	56                   	push   %esi
  8004e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8004e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004ec:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8004f2:	e8 10 0a 00 00       	call   800f07 <sys_getenvid>
  8004f7:	83 ec 0c             	sub    $0xc,%esp
  8004fa:	ff 75 0c             	pushl  0xc(%ebp)
  8004fd:	ff 75 08             	pushl  0x8(%ebp)
  800500:	56                   	push   %esi
  800501:	50                   	push   %eax
  800502:	68 44 30 80 00       	push   $0x803044
  800507:	e8 b1 00 00 00       	call   8005bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050c:	83 c4 18             	add    $0x18,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 10             	pushl  0x10(%ebp)
  800513:	e8 54 00 00 00       	call   80056c <vcprintf>
	cprintf("\n");
  800518:	c7 04 24 78 2f 80 00 	movl   $0x802f78,(%esp)
  80051f:	e8 99 00 00 00       	call   8005bd <cprintf>
  800524:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800527:	cc                   	int3   
  800528:	eb fd                	jmp    800527 <_panic+0x43>

0080052a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	53                   	push   %ebx
  80052e:	83 ec 04             	sub    $0x4,%esp
  800531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800534:	8b 13                	mov    (%ebx),%edx
  800536:	8d 42 01             	lea    0x1(%edx),%eax
  800539:	89 03                	mov    %eax,(%ebx)
  80053b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80053e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800542:	3d ff 00 00 00       	cmp    $0xff,%eax
  800547:	75 1a                	jne    800563 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	68 ff 00 00 00       	push   $0xff
  800551:	8d 43 08             	lea    0x8(%ebx),%eax
  800554:	50                   	push   %eax
  800555:	e8 2f 09 00 00       	call   800e89 <sys_cputs>
		b->idx = 0;
  80055a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800560:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800563:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800567:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80056a:	c9                   	leave  
  80056b:	c3                   	ret    

0080056c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800575:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80057c:	00 00 00 
	b.cnt = 0;
  80057f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800586:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800589:	ff 75 0c             	pushl  0xc(%ebp)
  80058c:	ff 75 08             	pushl  0x8(%ebp)
  80058f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800595:	50                   	push   %eax
  800596:	68 2a 05 80 00       	push   $0x80052a
  80059b:	e8 54 01 00 00       	call   8006f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a0:	83 c4 08             	add    $0x8,%esp
  8005a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005af:	50                   	push   %eax
  8005b0:	e8 d4 08 00 00       	call   800e89 <sys_cputs>

	return b.cnt;
}
  8005b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005bb:	c9                   	leave  
  8005bc:	c3                   	ret    

008005bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005c3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 08             	pushl  0x8(%ebp)
  8005ca:	e8 9d ff ff ff       	call   80056c <vcprintf>
	va_end(ap);

	return cnt;
}
  8005cf:	c9                   	leave  
  8005d0:	c3                   	ret    

008005d1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005d1:	55                   	push   %ebp
  8005d2:	89 e5                	mov    %esp,%ebp
  8005d4:	57                   	push   %edi
  8005d5:	56                   	push   %esi
  8005d6:	53                   	push   %ebx
  8005d7:	83 ec 1c             	sub    $0x1c,%esp
  8005da:	89 c7                	mov    %eax,%edi
  8005dc:	89 d6                	mov    %edx,%esi
  8005de:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005f5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005f8:	39 d3                	cmp    %edx,%ebx
  8005fa:	72 05                	jb     800601 <printnum+0x30>
  8005fc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005ff:	77 45                	ja     800646 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800601:	83 ec 0c             	sub    $0xc,%esp
  800604:	ff 75 18             	pushl  0x18(%ebp)
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80060d:	53                   	push   %ebx
  80060e:	ff 75 10             	pushl  0x10(%ebp)
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	ff 75 e4             	pushl  -0x1c(%ebp)
  800617:	ff 75 e0             	pushl  -0x20(%ebp)
  80061a:	ff 75 dc             	pushl  -0x24(%ebp)
  80061d:	ff 75 d8             	pushl  -0x28(%ebp)
  800620:	e8 4b 26 00 00       	call   802c70 <__udivdi3>
  800625:	83 c4 18             	add    $0x18,%esp
  800628:	52                   	push   %edx
  800629:	50                   	push   %eax
  80062a:	89 f2                	mov    %esi,%edx
  80062c:	89 f8                	mov    %edi,%eax
  80062e:	e8 9e ff ff ff       	call   8005d1 <printnum>
  800633:	83 c4 20             	add    $0x20,%esp
  800636:	eb 18                	jmp    800650 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	56                   	push   %esi
  80063c:	ff 75 18             	pushl  0x18(%ebp)
  80063f:	ff d7                	call   *%edi
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	eb 03                	jmp    800649 <printnum+0x78>
  800646:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800649:	83 eb 01             	sub    $0x1,%ebx
  80064c:	85 db                	test   %ebx,%ebx
  80064e:	7f e8                	jg     800638 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	56                   	push   %esi
  800654:	83 ec 04             	sub    $0x4,%esp
  800657:	ff 75 e4             	pushl  -0x1c(%ebp)
  80065a:	ff 75 e0             	pushl  -0x20(%ebp)
  80065d:	ff 75 dc             	pushl  -0x24(%ebp)
  800660:	ff 75 d8             	pushl  -0x28(%ebp)
  800663:	e8 38 27 00 00       	call   802da0 <__umoddi3>
  800668:	83 c4 14             	add    $0x14,%esp
  80066b:	0f be 80 67 30 80 00 	movsbl 0x803067(%eax),%eax
  800672:	50                   	push   %eax
  800673:	ff d7                	call   *%edi
}
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5f                   	pop    %edi
  80067e:	5d                   	pop    %ebp
  80067f:	c3                   	ret    

00800680 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800683:	83 fa 01             	cmp    $0x1,%edx
  800686:	7e 0e                	jle    800696 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800688:	8b 10                	mov    (%eax),%edx
  80068a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80068d:	89 08                	mov    %ecx,(%eax)
  80068f:	8b 02                	mov    (%edx),%eax
  800691:	8b 52 04             	mov    0x4(%edx),%edx
  800694:	eb 22                	jmp    8006b8 <getuint+0x38>
	else if (lflag)
  800696:	85 d2                	test   %edx,%edx
  800698:	74 10                	je     8006aa <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80069a:	8b 10                	mov    (%eax),%edx
  80069c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80069f:	89 08                	mov    %ecx,(%eax)
  8006a1:	8b 02                	mov    (%edx),%eax
  8006a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a8:	eb 0e                	jmp    8006b8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006af:	89 08                	mov    %ecx,(%eax)
  8006b1:	8b 02                	mov    (%edx),%eax
  8006b3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006b8:	5d                   	pop    %ebp
  8006b9:	c3                   	ret    

008006ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006c0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	3b 50 04             	cmp    0x4(%eax),%edx
  8006c9:	73 0a                	jae    8006d5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8006cb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006ce:	89 08                	mov    %ecx,(%eax)
  8006d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d3:	88 02                	mov    %al,(%edx)
}
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006dd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006e0:	50                   	push   %eax
  8006e1:	ff 75 10             	pushl  0x10(%ebp)
  8006e4:	ff 75 0c             	pushl  0xc(%ebp)
  8006e7:	ff 75 08             	pushl  0x8(%ebp)
  8006ea:	e8 05 00 00 00       	call   8006f4 <vprintfmt>
	va_end(ap);
}
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	57                   	push   %edi
  8006f8:	56                   	push   %esi
  8006f9:	53                   	push   %ebx
  8006fa:	83 ec 2c             	sub    $0x2c,%esp
  8006fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800700:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800703:	8b 7d 10             	mov    0x10(%ebp),%edi
  800706:	eb 12                	jmp    80071a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800708:	85 c0                	test   %eax,%eax
  80070a:	0f 84 89 03 00 00    	je     800a99 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	50                   	push   %eax
  800715:	ff d6                	call   *%esi
  800717:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80071a:	83 c7 01             	add    $0x1,%edi
  80071d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800721:	83 f8 25             	cmp    $0x25,%eax
  800724:	75 e2                	jne    800708 <vprintfmt+0x14>
  800726:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80072a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800731:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800738:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80073f:	ba 00 00 00 00       	mov    $0x0,%edx
  800744:	eb 07                	jmp    80074d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800746:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800749:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074d:	8d 47 01             	lea    0x1(%edi),%eax
  800750:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800753:	0f b6 07             	movzbl (%edi),%eax
  800756:	0f b6 c8             	movzbl %al,%ecx
  800759:	83 e8 23             	sub    $0x23,%eax
  80075c:	3c 55                	cmp    $0x55,%al
  80075e:	0f 87 1a 03 00 00    	ja     800a7e <vprintfmt+0x38a>
  800764:	0f b6 c0             	movzbl %al,%eax
  800767:	ff 24 85 a0 31 80 00 	jmp    *0x8031a0(,%eax,4)
  80076e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800771:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800775:	eb d6                	jmp    80074d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800777:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077a:	b8 00 00 00 00       	mov    $0x0,%eax
  80077f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800782:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800785:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800789:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80078c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80078f:	83 fa 09             	cmp    $0x9,%edx
  800792:	77 39                	ja     8007cd <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800794:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800797:	eb e9                	jmp    800782 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
  80079c:	8d 48 04             	lea    0x4(%eax),%ecx
  80079f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007a2:	8b 00                	mov    (%eax),%eax
  8007a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8007aa:	eb 27                	jmp    8007d3 <vprintfmt+0xdf>
  8007ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007af:	85 c0                	test   %eax,%eax
  8007b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b6:	0f 49 c8             	cmovns %eax,%ecx
  8007b9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007bf:	eb 8c                	jmp    80074d <vprintfmt+0x59>
  8007c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8007c4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8007cb:	eb 80                	jmp    80074d <vprintfmt+0x59>
  8007cd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8007d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007d7:	0f 89 70 ff ff ff    	jns    80074d <vprintfmt+0x59>
				width = precision, precision = -1;
  8007dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007e3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007ea:	e9 5e ff ff ff       	jmp    80074d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007ef:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007f5:	e9 53 ff ff ff       	jmp    80074d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8d 50 04             	lea    0x4(%eax),%edx
  800800:	89 55 14             	mov    %edx,0x14(%ebp)
  800803:	83 ec 08             	sub    $0x8,%esp
  800806:	53                   	push   %ebx
  800807:	ff 30                	pushl  (%eax)
  800809:	ff d6                	call   *%esi
			break;
  80080b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800811:	e9 04 ff ff ff       	jmp    80071a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	8d 50 04             	lea    0x4(%eax),%edx
  80081c:	89 55 14             	mov    %edx,0x14(%ebp)
  80081f:	8b 00                	mov    (%eax),%eax
  800821:	99                   	cltd   
  800822:	31 d0                	xor    %edx,%eax
  800824:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800826:	83 f8 0f             	cmp    $0xf,%eax
  800829:	7f 0b                	jg     800836 <vprintfmt+0x142>
  80082b:	8b 14 85 00 33 80 00 	mov    0x803300(,%eax,4),%edx
  800832:	85 d2                	test   %edx,%edx
  800834:	75 18                	jne    80084e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800836:	50                   	push   %eax
  800837:	68 7f 30 80 00       	push   $0x80307f
  80083c:	53                   	push   %ebx
  80083d:	56                   	push   %esi
  80083e:	e8 94 fe ff ff       	call   8006d7 <printfmt>
  800843:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800846:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800849:	e9 cc fe ff ff       	jmp    80071a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80084e:	52                   	push   %edx
  80084f:	68 ea 34 80 00       	push   $0x8034ea
  800854:	53                   	push   %ebx
  800855:	56                   	push   %esi
  800856:	e8 7c fe ff ff       	call   8006d7 <printfmt>
  80085b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800861:	e9 b4 fe ff ff       	jmp    80071a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800866:	8b 45 14             	mov    0x14(%ebp),%eax
  800869:	8d 50 04             	lea    0x4(%eax),%edx
  80086c:	89 55 14             	mov    %edx,0x14(%ebp)
  80086f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800871:	85 ff                	test   %edi,%edi
  800873:	b8 78 30 80 00       	mov    $0x803078,%eax
  800878:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80087b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80087f:	0f 8e 94 00 00 00    	jle    800919 <vprintfmt+0x225>
  800885:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800889:	0f 84 98 00 00 00    	je     800927 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80088f:	83 ec 08             	sub    $0x8,%esp
  800892:	ff 75 d0             	pushl  -0x30(%ebp)
  800895:	57                   	push   %edi
  800896:	e8 86 02 00 00       	call   800b21 <strnlen>
  80089b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80089e:	29 c1                	sub    %eax,%ecx
  8008a0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8008a3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8008a6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8008aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008ad:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008b0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b2:	eb 0f                	jmp    8008c3 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	53                   	push   %ebx
  8008b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8008bb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008bd:	83 ef 01             	sub    $0x1,%edi
  8008c0:	83 c4 10             	add    $0x10,%esp
  8008c3:	85 ff                	test   %edi,%edi
  8008c5:	7f ed                	jg     8008b4 <vprintfmt+0x1c0>
  8008c7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008ca:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8008cd:	85 c9                	test   %ecx,%ecx
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d4:	0f 49 c1             	cmovns %ecx,%eax
  8008d7:	29 c1                	sub    %eax,%ecx
  8008d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8008dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008e2:	89 cb                	mov    %ecx,%ebx
  8008e4:	eb 4d                	jmp    800933 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008ea:	74 1b                	je     800907 <vprintfmt+0x213>
  8008ec:	0f be c0             	movsbl %al,%eax
  8008ef:	83 e8 20             	sub    $0x20,%eax
  8008f2:	83 f8 5e             	cmp    $0x5e,%eax
  8008f5:	76 10                	jbe    800907 <vprintfmt+0x213>
					putch('?', putdat);
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	ff 75 0c             	pushl  0xc(%ebp)
  8008fd:	6a 3f                	push   $0x3f
  8008ff:	ff 55 08             	call   *0x8(%ebp)
  800902:	83 c4 10             	add    $0x10,%esp
  800905:	eb 0d                	jmp    800914 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800907:	83 ec 08             	sub    $0x8,%esp
  80090a:	ff 75 0c             	pushl  0xc(%ebp)
  80090d:	52                   	push   %edx
  80090e:	ff 55 08             	call   *0x8(%ebp)
  800911:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800914:	83 eb 01             	sub    $0x1,%ebx
  800917:	eb 1a                	jmp    800933 <vprintfmt+0x23f>
  800919:	89 75 08             	mov    %esi,0x8(%ebp)
  80091c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80091f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800922:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800925:	eb 0c                	jmp    800933 <vprintfmt+0x23f>
  800927:	89 75 08             	mov    %esi,0x8(%ebp)
  80092a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80092d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800930:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800933:	83 c7 01             	add    $0x1,%edi
  800936:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80093a:	0f be d0             	movsbl %al,%edx
  80093d:	85 d2                	test   %edx,%edx
  80093f:	74 23                	je     800964 <vprintfmt+0x270>
  800941:	85 f6                	test   %esi,%esi
  800943:	78 a1                	js     8008e6 <vprintfmt+0x1f2>
  800945:	83 ee 01             	sub    $0x1,%esi
  800948:	79 9c                	jns    8008e6 <vprintfmt+0x1f2>
  80094a:	89 df                	mov    %ebx,%edi
  80094c:	8b 75 08             	mov    0x8(%ebp),%esi
  80094f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800952:	eb 18                	jmp    80096c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800954:	83 ec 08             	sub    $0x8,%esp
  800957:	53                   	push   %ebx
  800958:	6a 20                	push   $0x20
  80095a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80095c:	83 ef 01             	sub    $0x1,%edi
  80095f:	83 c4 10             	add    $0x10,%esp
  800962:	eb 08                	jmp    80096c <vprintfmt+0x278>
  800964:	89 df                	mov    %ebx,%edi
  800966:	8b 75 08             	mov    0x8(%ebp),%esi
  800969:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80096c:	85 ff                	test   %edi,%edi
  80096e:	7f e4                	jg     800954 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800970:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800973:	e9 a2 fd ff ff       	jmp    80071a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800978:	83 fa 01             	cmp    $0x1,%edx
  80097b:	7e 16                	jle    800993 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80097d:	8b 45 14             	mov    0x14(%ebp),%eax
  800980:	8d 50 08             	lea    0x8(%eax),%edx
  800983:	89 55 14             	mov    %edx,0x14(%ebp)
  800986:	8b 50 04             	mov    0x4(%eax),%edx
  800989:	8b 00                	mov    (%eax),%eax
  80098b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80098e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800991:	eb 32                	jmp    8009c5 <vprintfmt+0x2d1>
	else if (lflag)
  800993:	85 d2                	test   %edx,%edx
  800995:	74 18                	je     8009af <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800997:	8b 45 14             	mov    0x14(%ebp),%eax
  80099a:	8d 50 04             	lea    0x4(%eax),%edx
  80099d:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a0:	8b 00                	mov    (%eax),%eax
  8009a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009a5:	89 c1                	mov    %eax,%ecx
  8009a7:	c1 f9 1f             	sar    $0x1f,%ecx
  8009aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8009ad:	eb 16                	jmp    8009c5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8009af:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b2:	8d 50 04             	lea    0x4(%eax),%edx
  8009b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b8:	8b 00                	mov    (%eax),%eax
  8009ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009bd:	89 c1                	mov    %eax,%ecx
  8009bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8009c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009c8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009cb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009d0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009d4:	79 74                	jns    800a4a <vprintfmt+0x356>
				putch('-', putdat);
  8009d6:	83 ec 08             	sub    $0x8,%esp
  8009d9:	53                   	push   %ebx
  8009da:	6a 2d                	push   $0x2d
  8009dc:	ff d6                	call   *%esi
				num = -(long long) num;
  8009de:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009e4:	f7 d8                	neg    %eax
  8009e6:	83 d2 00             	adc    $0x0,%edx
  8009e9:	f7 da                	neg    %edx
  8009eb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009ee:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009f3:	eb 55                	jmp    800a4a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8009f8:	e8 83 fc ff ff       	call   800680 <getuint>
			base = 10;
  8009fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a02:	eb 46                	jmp    800a4a <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a04:	8d 45 14             	lea    0x14(%ebp),%eax
  800a07:	e8 74 fc ff ff       	call   800680 <getuint>
                        base = 8;
  800a0c:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800a11:	eb 37                	jmp    800a4a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800a13:	83 ec 08             	sub    $0x8,%esp
  800a16:	53                   	push   %ebx
  800a17:	6a 30                	push   $0x30
  800a19:	ff d6                	call   *%esi
			putch('x', putdat);
  800a1b:	83 c4 08             	add    $0x8,%esp
  800a1e:	53                   	push   %ebx
  800a1f:	6a 78                	push   $0x78
  800a21:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a23:	8b 45 14             	mov    0x14(%ebp),%eax
  800a26:	8d 50 04             	lea    0x4(%eax),%edx
  800a29:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a2c:	8b 00                	mov    (%eax),%eax
  800a2e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a33:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a36:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a3b:	eb 0d                	jmp    800a4a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a3d:	8d 45 14             	lea    0x14(%ebp),%eax
  800a40:	e8 3b fc ff ff       	call   800680 <getuint>
			base = 16;
  800a45:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a4a:	83 ec 0c             	sub    $0xc,%esp
  800a4d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a51:	57                   	push   %edi
  800a52:	ff 75 e0             	pushl  -0x20(%ebp)
  800a55:	51                   	push   %ecx
  800a56:	52                   	push   %edx
  800a57:	50                   	push   %eax
  800a58:	89 da                	mov    %ebx,%edx
  800a5a:	89 f0                	mov    %esi,%eax
  800a5c:	e8 70 fb ff ff       	call   8005d1 <printnum>
			break;
  800a61:	83 c4 20             	add    $0x20,%esp
  800a64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a67:	e9 ae fc ff ff       	jmp    80071a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a6c:	83 ec 08             	sub    $0x8,%esp
  800a6f:	53                   	push   %ebx
  800a70:	51                   	push   %ecx
  800a71:	ff d6                	call   *%esi
			break;
  800a73:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800a79:	e9 9c fc ff ff       	jmp    80071a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a7e:	83 ec 08             	sub    $0x8,%esp
  800a81:	53                   	push   %ebx
  800a82:	6a 25                	push   $0x25
  800a84:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a86:	83 c4 10             	add    $0x10,%esp
  800a89:	eb 03                	jmp    800a8e <vprintfmt+0x39a>
  800a8b:	83 ef 01             	sub    $0x1,%edi
  800a8e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800a92:	75 f7                	jne    800a8b <vprintfmt+0x397>
  800a94:	e9 81 fc ff ff       	jmp    80071a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800a99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	83 ec 18             	sub    $0x18,%esp
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800aad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ab0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ab4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ab7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	74 26                	je     800ae8 <vsnprintf+0x47>
  800ac2:	85 d2                	test   %edx,%edx
  800ac4:	7e 22                	jle    800ae8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ac6:	ff 75 14             	pushl  0x14(%ebp)
  800ac9:	ff 75 10             	pushl  0x10(%ebp)
  800acc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800acf:	50                   	push   %eax
  800ad0:	68 ba 06 80 00       	push   $0x8006ba
  800ad5:	e8 1a fc ff ff       	call   8006f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ada:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800add:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ae3:	83 c4 10             	add    $0x10,%esp
  800ae6:	eb 05                	jmp    800aed <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ae8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800aed:	c9                   	leave  
  800aee:	c3                   	ret    

00800aef <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800af5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800af8:	50                   	push   %eax
  800af9:	ff 75 10             	pushl  0x10(%ebp)
  800afc:	ff 75 0c             	pushl  0xc(%ebp)
  800aff:	ff 75 08             	pushl  0x8(%ebp)
  800b02:	e8 9a ff ff ff       	call   800aa1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b07:	c9                   	leave  
  800b08:	c3                   	ret    

00800b09 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b14:	eb 03                	jmp    800b19 <strlen+0x10>
		n++;
  800b16:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b19:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b1d:	75 f7                	jne    800b16 <strlen+0xd>
		n++;
	return n;
}
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b27:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	eb 03                	jmp    800b34 <strnlen+0x13>
		n++;
  800b31:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b34:	39 c2                	cmp    %eax,%edx
  800b36:	74 08                	je     800b40 <strnlen+0x1f>
  800b38:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b3c:	75 f3                	jne    800b31 <strnlen+0x10>
  800b3e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	53                   	push   %ebx
  800b46:	8b 45 08             	mov    0x8(%ebp),%eax
  800b49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b4c:	89 c2                	mov    %eax,%edx
  800b4e:	83 c2 01             	add    $0x1,%edx
  800b51:	83 c1 01             	add    $0x1,%ecx
  800b54:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b58:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b5b:	84 db                	test   %bl,%bl
  800b5d:	75 ef                	jne    800b4e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	53                   	push   %ebx
  800b66:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b69:	53                   	push   %ebx
  800b6a:	e8 9a ff ff ff       	call   800b09 <strlen>
  800b6f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b72:	ff 75 0c             	pushl  0xc(%ebp)
  800b75:	01 d8                	add    %ebx,%eax
  800b77:	50                   	push   %eax
  800b78:	e8 c5 ff ff ff       	call   800b42 <strcpy>
	return dst;
}
  800b7d:	89 d8                	mov    %ebx,%eax
  800b7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b82:	c9                   	leave  
  800b83:	c3                   	ret    

00800b84 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	8b 75 08             	mov    0x8(%ebp),%esi
  800b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8f:	89 f3                	mov    %esi,%ebx
  800b91:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b94:	89 f2                	mov    %esi,%edx
  800b96:	eb 0f                	jmp    800ba7 <strncpy+0x23>
		*dst++ = *src;
  800b98:	83 c2 01             	add    $0x1,%edx
  800b9b:	0f b6 01             	movzbl (%ecx),%eax
  800b9e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ba1:	80 39 01             	cmpb   $0x1,(%ecx)
  800ba4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ba7:	39 da                	cmp    %ebx,%edx
  800ba9:	75 ed                	jne    800b98 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bab:	89 f0                	mov    %esi,%eax
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	8b 75 08             	mov    0x8(%ebp),%esi
  800bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbc:	8b 55 10             	mov    0x10(%ebp),%edx
  800bbf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bc1:	85 d2                	test   %edx,%edx
  800bc3:	74 21                	je     800be6 <strlcpy+0x35>
  800bc5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800bc9:	89 f2                	mov    %esi,%edx
  800bcb:	eb 09                	jmp    800bd6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bcd:	83 c2 01             	add    $0x1,%edx
  800bd0:	83 c1 01             	add    $0x1,%ecx
  800bd3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bd6:	39 c2                	cmp    %eax,%edx
  800bd8:	74 09                	je     800be3 <strlcpy+0x32>
  800bda:	0f b6 19             	movzbl (%ecx),%ebx
  800bdd:	84 db                	test   %bl,%bl
  800bdf:	75 ec                	jne    800bcd <strlcpy+0x1c>
  800be1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800be3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800be6:	29 f0                	sub    %esi,%eax
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bf5:	eb 06                	jmp    800bfd <strcmp+0x11>
		p++, q++;
  800bf7:	83 c1 01             	add    $0x1,%ecx
  800bfa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bfd:	0f b6 01             	movzbl (%ecx),%eax
  800c00:	84 c0                	test   %al,%al
  800c02:	74 04                	je     800c08 <strcmp+0x1c>
  800c04:	3a 02                	cmp    (%edx),%al
  800c06:	74 ef                	je     800bf7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c08:	0f b6 c0             	movzbl %al,%eax
  800c0b:	0f b6 12             	movzbl (%edx),%edx
  800c0e:	29 d0                	sub    %edx,%eax
}
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	53                   	push   %ebx
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
  800c19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1c:	89 c3                	mov    %eax,%ebx
  800c1e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c21:	eb 06                	jmp    800c29 <strncmp+0x17>
		n--, p++, q++;
  800c23:	83 c0 01             	add    $0x1,%eax
  800c26:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c29:	39 d8                	cmp    %ebx,%eax
  800c2b:	74 15                	je     800c42 <strncmp+0x30>
  800c2d:	0f b6 08             	movzbl (%eax),%ecx
  800c30:	84 c9                	test   %cl,%cl
  800c32:	74 04                	je     800c38 <strncmp+0x26>
  800c34:	3a 0a                	cmp    (%edx),%cl
  800c36:	74 eb                	je     800c23 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c38:	0f b6 00             	movzbl (%eax),%eax
  800c3b:	0f b6 12             	movzbl (%edx),%edx
  800c3e:	29 d0                	sub    %edx,%eax
  800c40:	eb 05                	jmp    800c47 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c42:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c47:	5b                   	pop    %ebx
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c54:	eb 07                	jmp    800c5d <strchr+0x13>
		if (*s == c)
  800c56:	38 ca                	cmp    %cl,%dl
  800c58:	74 0f                	je     800c69 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c5a:	83 c0 01             	add    $0x1,%eax
  800c5d:	0f b6 10             	movzbl (%eax),%edx
  800c60:	84 d2                	test   %dl,%dl
  800c62:	75 f2                	jne    800c56 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800c64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c75:	eb 03                	jmp    800c7a <strfind+0xf>
  800c77:	83 c0 01             	add    $0x1,%eax
  800c7a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c7d:	38 ca                	cmp    %cl,%dl
  800c7f:	74 04                	je     800c85 <strfind+0x1a>
  800c81:	84 d2                	test   %dl,%dl
  800c83:	75 f2                	jne    800c77 <strfind+0xc>
			break;
	return (char *) s;
}
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c93:	85 c9                	test   %ecx,%ecx
  800c95:	74 36                	je     800ccd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c97:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c9d:	75 28                	jne    800cc7 <memset+0x40>
  800c9f:	f6 c1 03             	test   $0x3,%cl
  800ca2:	75 23                	jne    800cc7 <memset+0x40>
		c &= 0xFF;
  800ca4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ca8:	89 d3                	mov    %edx,%ebx
  800caa:	c1 e3 08             	shl    $0x8,%ebx
  800cad:	89 d6                	mov    %edx,%esi
  800caf:	c1 e6 18             	shl    $0x18,%esi
  800cb2:	89 d0                	mov    %edx,%eax
  800cb4:	c1 e0 10             	shl    $0x10,%eax
  800cb7:	09 f0                	or     %esi,%eax
  800cb9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800cbb:	89 d8                	mov    %ebx,%eax
  800cbd:	09 d0                	or     %edx,%eax
  800cbf:	c1 e9 02             	shr    $0x2,%ecx
  800cc2:	fc                   	cld    
  800cc3:	f3 ab                	rep stos %eax,%es:(%edi)
  800cc5:	eb 06                	jmp    800ccd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cca:	fc                   	cld    
  800ccb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ccd:	89 f8                	mov    %edi,%eax
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cdf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ce2:	39 c6                	cmp    %eax,%esi
  800ce4:	73 35                	jae    800d1b <memmove+0x47>
  800ce6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ce9:	39 d0                	cmp    %edx,%eax
  800ceb:	73 2e                	jae    800d1b <memmove+0x47>
		s += n;
		d += n;
  800ced:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	09 fe                	or     %edi,%esi
  800cf4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cfa:	75 13                	jne    800d0f <memmove+0x3b>
  800cfc:	f6 c1 03             	test   $0x3,%cl
  800cff:	75 0e                	jne    800d0f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d01:	83 ef 04             	sub    $0x4,%edi
  800d04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d07:	c1 e9 02             	shr    $0x2,%ecx
  800d0a:	fd                   	std    
  800d0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d0d:	eb 09                	jmp    800d18 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d0f:	83 ef 01             	sub    $0x1,%edi
  800d12:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d15:	fd                   	std    
  800d16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d18:	fc                   	cld    
  800d19:	eb 1d                	jmp    800d38 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d1b:	89 f2                	mov    %esi,%edx
  800d1d:	09 c2                	or     %eax,%edx
  800d1f:	f6 c2 03             	test   $0x3,%dl
  800d22:	75 0f                	jne    800d33 <memmove+0x5f>
  800d24:	f6 c1 03             	test   $0x3,%cl
  800d27:	75 0a                	jne    800d33 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d29:	c1 e9 02             	shr    $0x2,%ecx
  800d2c:	89 c7                	mov    %eax,%edi
  800d2e:	fc                   	cld    
  800d2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d31:	eb 05                	jmp    800d38 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d33:	89 c7                	mov    %eax,%edi
  800d35:	fc                   	cld    
  800d36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d3f:	ff 75 10             	pushl  0x10(%ebp)
  800d42:	ff 75 0c             	pushl  0xc(%ebp)
  800d45:	ff 75 08             	pushl  0x8(%ebp)
  800d48:	e8 87 ff ff ff       	call   800cd4 <memmove>
}
  800d4d:	c9                   	leave  
  800d4e:	c3                   	ret    

00800d4f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	8b 45 08             	mov    0x8(%ebp),%eax
  800d57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d5a:	89 c6                	mov    %eax,%esi
  800d5c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d5f:	eb 1a                	jmp    800d7b <memcmp+0x2c>
		if (*s1 != *s2)
  800d61:	0f b6 08             	movzbl (%eax),%ecx
  800d64:	0f b6 1a             	movzbl (%edx),%ebx
  800d67:	38 d9                	cmp    %bl,%cl
  800d69:	74 0a                	je     800d75 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d6b:	0f b6 c1             	movzbl %cl,%eax
  800d6e:	0f b6 db             	movzbl %bl,%ebx
  800d71:	29 d8                	sub    %ebx,%eax
  800d73:	eb 0f                	jmp    800d84 <memcmp+0x35>
		s1++, s2++;
  800d75:	83 c0 01             	add    $0x1,%eax
  800d78:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d7b:	39 f0                	cmp    %esi,%eax
  800d7d:	75 e2                	jne    800d61 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	53                   	push   %ebx
  800d8c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d8f:	89 c1                	mov    %eax,%ecx
  800d91:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800d94:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d98:	eb 0a                	jmp    800da4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d9a:	0f b6 10             	movzbl (%eax),%edx
  800d9d:	39 da                	cmp    %ebx,%edx
  800d9f:	74 07                	je     800da8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800da1:	83 c0 01             	add    $0x1,%eax
  800da4:	39 c8                	cmp    %ecx,%eax
  800da6:	72 f2                	jb     800d9a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800da8:	5b                   	pop    %ebx
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
  800db1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db7:	eb 03                	jmp    800dbc <strtol+0x11>
		s++;
  800db9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dbc:	0f b6 01             	movzbl (%ecx),%eax
  800dbf:	3c 20                	cmp    $0x20,%al
  800dc1:	74 f6                	je     800db9 <strtol+0xe>
  800dc3:	3c 09                	cmp    $0x9,%al
  800dc5:	74 f2                	je     800db9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dc7:	3c 2b                	cmp    $0x2b,%al
  800dc9:	75 0a                	jne    800dd5 <strtol+0x2a>
		s++;
  800dcb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dce:	bf 00 00 00 00       	mov    $0x0,%edi
  800dd3:	eb 11                	jmp    800de6 <strtol+0x3b>
  800dd5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dda:	3c 2d                	cmp    $0x2d,%al
  800ddc:	75 08                	jne    800de6 <strtol+0x3b>
		s++, neg = 1;
  800dde:	83 c1 01             	add    $0x1,%ecx
  800de1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800de6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dec:	75 15                	jne    800e03 <strtol+0x58>
  800dee:	80 39 30             	cmpb   $0x30,(%ecx)
  800df1:	75 10                	jne    800e03 <strtol+0x58>
  800df3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800df7:	75 7c                	jne    800e75 <strtol+0xca>
		s += 2, base = 16;
  800df9:	83 c1 02             	add    $0x2,%ecx
  800dfc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e01:	eb 16                	jmp    800e19 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e03:	85 db                	test   %ebx,%ebx
  800e05:	75 12                	jne    800e19 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e07:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e0c:	80 39 30             	cmpb   $0x30,(%ecx)
  800e0f:	75 08                	jne    800e19 <strtol+0x6e>
		s++, base = 8;
  800e11:	83 c1 01             	add    $0x1,%ecx
  800e14:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e19:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e21:	0f b6 11             	movzbl (%ecx),%edx
  800e24:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e27:	89 f3                	mov    %esi,%ebx
  800e29:	80 fb 09             	cmp    $0x9,%bl
  800e2c:	77 08                	ja     800e36 <strtol+0x8b>
			dig = *s - '0';
  800e2e:	0f be d2             	movsbl %dl,%edx
  800e31:	83 ea 30             	sub    $0x30,%edx
  800e34:	eb 22                	jmp    800e58 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800e36:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e39:	89 f3                	mov    %esi,%ebx
  800e3b:	80 fb 19             	cmp    $0x19,%bl
  800e3e:	77 08                	ja     800e48 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800e40:	0f be d2             	movsbl %dl,%edx
  800e43:	83 ea 57             	sub    $0x57,%edx
  800e46:	eb 10                	jmp    800e58 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800e48:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e4b:	89 f3                	mov    %esi,%ebx
  800e4d:	80 fb 19             	cmp    $0x19,%bl
  800e50:	77 16                	ja     800e68 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800e52:	0f be d2             	movsbl %dl,%edx
  800e55:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e58:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e5b:	7d 0b                	jge    800e68 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800e5d:	83 c1 01             	add    $0x1,%ecx
  800e60:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e64:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e66:	eb b9                	jmp    800e21 <strtol+0x76>

	if (endptr)
  800e68:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e6c:	74 0d                	je     800e7b <strtol+0xd0>
		*endptr = (char *) s;
  800e6e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e71:	89 0e                	mov    %ecx,(%esi)
  800e73:	eb 06                	jmp    800e7b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e75:	85 db                	test   %ebx,%ebx
  800e77:	74 98                	je     800e11 <strtol+0x66>
  800e79:	eb 9e                	jmp    800e19 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e7b:	89 c2                	mov    %eax,%edx
  800e7d:	f7 da                	neg    %edx
  800e7f:	85 ff                	test   %edi,%edi
  800e81:	0f 45 c2             	cmovne %edx,%eax
}
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e97:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9a:	89 c3                	mov    %eax,%ebx
  800e9c:	89 c7                	mov    %eax,%edi
  800e9e:	89 c6                	mov    %eax,%esi
  800ea0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	57                   	push   %edi
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ead:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb7:	89 d1                	mov    %edx,%ecx
  800eb9:	89 d3                	mov    %edx,%ebx
  800ebb:	89 d7                	mov    %edx,%edi
  800ebd:	89 d6                	mov    %edx,%esi
  800ebf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5f                   	pop    %edi
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed4:	b8 03 00 00 00       	mov    $0x3,%eax
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	89 cb                	mov    %ecx,%ebx
  800ede:	89 cf                	mov    %ecx,%edi
  800ee0:	89 ce                	mov    %ecx,%esi
  800ee2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	7e 17                	jle    800eff <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee8:	83 ec 0c             	sub    $0xc,%esp
  800eeb:	50                   	push   %eax
  800eec:	6a 03                	push   $0x3
  800eee:	68 5f 33 80 00       	push   $0x80335f
  800ef3:	6a 23                	push   $0x23
  800ef5:	68 7c 33 80 00       	push   $0x80337c
  800efa:	e8 e5 f5 ff ff       	call   8004e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800eff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f02:	5b                   	pop    %ebx
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	57                   	push   %edi
  800f0b:	56                   	push   %esi
  800f0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f12:	b8 02 00 00 00       	mov    $0x2,%eax
  800f17:	89 d1                	mov    %edx,%ecx
  800f19:	89 d3                	mov    %edx,%ebx
  800f1b:	89 d7                	mov    %edx,%edi
  800f1d:	89 d6                	mov    %edx,%esi
  800f1f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <sys_yield>:

void
sys_yield(void)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	57                   	push   %edi
  800f2a:	56                   	push   %esi
  800f2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f31:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f36:	89 d1                	mov    %edx,%ecx
  800f38:	89 d3                	mov    %edx,%ebx
  800f3a:	89 d7                	mov    %edx,%edi
  800f3c:	89 d6                	mov    %edx,%esi
  800f3e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	57                   	push   %edi
  800f49:	56                   	push   %esi
  800f4a:	53                   	push   %ebx
  800f4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4e:	be 00 00 00 00       	mov    $0x0,%esi
  800f53:	b8 04 00 00 00       	mov    $0x4,%eax
  800f58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f61:	89 f7                	mov    %esi,%edi
  800f63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f65:	85 c0                	test   %eax,%eax
  800f67:	7e 17                	jle    800f80 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f69:	83 ec 0c             	sub    $0xc,%esp
  800f6c:	50                   	push   %eax
  800f6d:	6a 04                	push   $0x4
  800f6f:	68 5f 33 80 00       	push   $0x80335f
  800f74:	6a 23                	push   $0x23
  800f76:	68 7c 33 80 00       	push   $0x80337c
  800f7b:	e8 64 f5 ff ff       	call   8004e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f83:	5b                   	pop    %ebx
  800f84:	5e                   	pop    %esi
  800f85:	5f                   	pop    %edi
  800f86:	5d                   	pop    %ebp
  800f87:	c3                   	ret    

00800f88 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	57                   	push   %edi
  800f8c:	56                   	push   %esi
  800f8d:	53                   	push   %ebx
  800f8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f91:	b8 05 00 00 00       	mov    $0x5,%eax
  800f96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f99:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fa2:	8b 75 18             	mov    0x18(%ebp),%esi
  800fa5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	7e 17                	jle    800fc2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fab:	83 ec 0c             	sub    $0xc,%esp
  800fae:	50                   	push   %eax
  800faf:	6a 05                	push   $0x5
  800fb1:	68 5f 33 80 00       	push   $0x80335f
  800fb6:	6a 23                	push   $0x23
  800fb8:	68 7c 33 80 00       	push   $0x80337c
  800fbd:	e8 22 f5 ff ff       	call   8004e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc5:	5b                   	pop    %ebx
  800fc6:	5e                   	pop    %esi
  800fc7:	5f                   	pop    %edi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
  800fd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd8:	b8 06 00 00 00       	mov    $0x6,%eax
  800fdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe3:	89 df                	mov    %ebx,%edi
  800fe5:	89 de                	mov    %ebx,%esi
  800fe7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	7e 17                	jle    801004 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fed:	83 ec 0c             	sub    $0xc,%esp
  800ff0:	50                   	push   %eax
  800ff1:	6a 06                	push   $0x6
  800ff3:	68 5f 33 80 00       	push   $0x80335f
  800ff8:	6a 23                	push   $0x23
  800ffa:	68 7c 33 80 00       	push   $0x80337c
  800fff:	e8 e0 f4 ff ff       	call   8004e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801004:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801007:	5b                   	pop    %ebx
  801008:	5e                   	pop    %esi
  801009:	5f                   	pop    %edi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	57                   	push   %edi
  801010:	56                   	push   %esi
  801011:	53                   	push   %ebx
  801012:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801015:	bb 00 00 00 00       	mov    $0x0,%ebx
  80101a:	b8 08 00 00 00       	mov    $0x8,%eax
  80101f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801022:	8b 55 08             	mov    0x8(%ebp),%edx
  801025:	89 df                	mov    %ebx,%edi
  801027:	89 de                	mov    %ebx,%esi
  801029:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80102b:	85 c0                	test   %eax,%eax
  80102d:	7e 17                	jle    801046 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80102f:	83 ec 0c             	sub    $0xc,%esp
  801032:	50                   	push   %eax
  801033:	6a 08                	push   $0x8
  801035:	68 5f 33 80 00       	push   $0x80335f
  80103a:	6a 23                	push   $0x23
  80103c:	68 7c 33 80 00       	push   $0x80337c
  801041:	e8 9e f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801046:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801049:	5b                   	pop    %ebx
  80104a:	5e                   	pop    %esi
  80104b:	5f                   	pop    %edi
  80104c:	5d                   	pop    %ebp
  80104d:	c3                   	ret    

0080104e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
  801054:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801057:	bb 00 00 00 00       	mov    $0x0,%ebx
  80105c:	b8 09 00 00 00       	mov    $0x9,%eax
  801061:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801064:	8b 55 08             	mov    0x8(%ebp),%edx
  801067:	89 df                	mov    %ebx,%edi
  801069:	89 de                	mov    %ebx,%esi
  80106b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80106d:	85 c0                	test   %eax,%eax
  80106f:	7e 17                	jle    801088 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801071:	83 ec 0c             	sub    $0xc,%esp
  801074:	50                   	push   %eax
  801075:	6a 09                	push   $0x9
  801077:	68 5f 33 80 00       	push   $0x80335f
  80107c:	6a 23                	push   $0x23
  80107e:	68 7c 33 80 00       	push   $0x80337c
  801083:	e8 5c f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801088:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108b:	5b                   	pop    %ebx
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	57                   	push   %edi
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
  801096:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801099:	bb 00 00 00 00       	mov    $0x0,%ebx
  80109e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a9:	89 df                	mov    %ebx,%edi
  8010ab:	89 de                	mov    %ebx,%esi
  8010ad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	7e 17                	jle    8010ca <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b3:	83 ec 0c             	sub    $0xc,%esp
  8010b6:	50                   	push   %eax
  8010b7:	6a 0a                	push   $0xa
  8010b9:	68 5f 33 80 00       	push   $0x80335f
  8010be:	6a 23                	push   $0x23
  8010c0:	68 7c 33 80 00       	push   $0x80337c
  8010c5:	e8 1a f4 ff ff       	call   8004e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cd:	5b                   	pop    %ebx
  8010ce:	5e                   	pop    %esi
  8010cf:	5f                   	pop    %edi
  8010d0:	5d                   	pop    %ebp
  8010d1:	c3                   	ret    

008010d2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	57                   	push   %edi
  8010d6:	56                   	push   %esi
  8010d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d8:	be 00 00 00 00       	mov    $0x0,%esi
  8010dd:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010eb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ee:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	57                   	push   %edi
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
  8010fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  801103:	b8 0d 00 00 00       	mov    $0xd,%eax
  801108:	8b 55 08             	mov    0x8(%ebp),%edx
  80110b:	89 cb                	mov    %ecx,%ebx
  80110d:	89 cf                	mov    %ecx,%edi
  80110f:	89 ce                	mov    %ecx,%esi
  801111:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801113:	85 c0                	test   %eax,%eax
  801115:	7e 17                	jle    80112e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801117:	83 ec 0c             	sub    $0xc,%esp
  80111a:	50                   	push   %eax
  80111b:	6a 0d                	push   $0xd
  80111d:	68 5f 33 80 00       	push   $0x80335f
  801122:	6a 23                	push   $0x23
  801124:	68 7c 33 80 00       	push   $0x80337c
  801129:	e8 b6 f3 ff ff       	call   8004e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80112e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801131:	5b                   	pop    %ebx
  801132:	5e                   	pop    %esi
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	57                   	push   %edi
  80113a:	56                   	push   %esi
  80113b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113c:	ba 00 00 00 00       	mov    $0x0,%edx
  801141:	b8 0e 00 00 00       	mov    $0xe,%eax
  801146:	89 d1                	mov    %edx,%ecx
  801148:	89 d3                	mov    %edx,%ebx
  80114a:	89 d7                	mov    %edx,%edi
  80114c:	89 d6                	mov    %edx,%esi
  80114e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801150:	5b                   	pop    %ebx
  801151:	5e                   	pop    %esi
  801152:	5f                   	pop    %edi
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    

00801155 <sys_transmit_packet>:

int
sys_transmit_packet(void *buf, size_t size)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	57                   	push   %edi
  801159:	56                   	push   %esi
  80115a:	53                   	push   %ebx
  80115b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80115e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801163:	b8 0f 00 00 00       	mov    $0xf,%eax
  801168:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80116b:	8b 55 08             	mov    0x8(%ebp),%edx
  80116e:	89 df                	mov    %ebx,%edi
  801170:	89 de                	mov    %ebx,%esi
  801172:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801174:	85 c0                	test   %eax,%eax
  801176:	7e 17                	jle    80118f <sys_transmit_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801178:	83 ec 0c             	sub    $0xc,%esp
  80117b:	50                   	push   %eax
  80117c:	6a 0f                	push   $0xf
  80117e:	68 5f 33 80 00       	push   $0x80335f
  801183:	6a 23                	push   $0x23
  801185:	68 7c 33 80 00       	push   $0x80337c
  80118a:	e8 55 f3 ff ff       	call   8004e4 <_panic>
int
sys_transmit_packet(void *buf, size_t size)
{
	return syscall(SYS_transmit_packet, 1,
		(uint32_t) buf, (uint32_t) size, 0, 0, 0);
}
  80118f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801192:	5b                   	pop    %ebx
  801193:	5e                   	pop    %esi
  801194:	5f                   	pop    %edi
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    

00801197 <sys_receive_packet>:

int
sys_receive_packet(void *buf, size_t *size_store)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	57                   	push   %edi
  80119b:	56                   	push   %esi
  80119c:	53                   	push   %ebx
  80119d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a5:	b8 10 00 00 00       	mov    $0x10,%eax
  8011aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b0:	89 df                	mov    %ebx,%edi
  8011b2:	89 de                	mov    %ebx,%esi
  8011b4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	7e 17                	jle    8011d1 <sys_receive_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ba:	83 ec 0c             	sub    $0xc,%esp
  8011bd:	50                   	push   %eax
  8011be:	6a 10                	push   $0x10
  8011c0:	68 5f 33 80 00       	push   $0x80335f
  8011c5:	6a 23                	push   $0x23
  8011c7:	68 7c 33 80 00       	push   $0x80337c
  8011cc:	e8 13 f3 ff ff       	call   8004e4 <_panic>
int
sys_receive_packet(void *buf, size_t *size_store)
{
	return syscall(SYS_receive_packet, 1,
		(uint32_t) buf, (uint32_t) size_store, 0, 0, 0);
}
  8011d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d4:	5b                   	pop    %ebx
  8011d5:	5e                   	pop    %esi
  8011d6:	5f                   	pop    %edi
  8011d7:	5d                   	pop    %ebp
  8011d8:	c3                   	ret    

008011d9 <sys_get_mac_address>:

int
sys_get_mac_address(void *buf)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	57                   	push   %edi
  8011dd:	56                   	push   %esi
  8011de:	53                   	push   %ebx
  8011df:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011e7:	b8 11 00 00 00       	mov    $0x11,%eax
  8011ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ef:	89 cb                	mov    %ecx,%ebx
  8011f1:	89 cf                	mov    %ecx,%edi
  8011f3:	89 ce                	mov    %ecx,%esi
  8011f5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	7e 17                	jle    801212 <sys_get_mac_address+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011fb:	83 ec 0c             	sub    $0xc,%esp
  8011fe:	50                   	push   %eax
  8011ff:	6a 11                	push   $0x11
  801201:	68 5f 33 80 00       	push   $0x80335f
  801206:	6a 23                	push   $0x23
  801208:	68 7c 33 80 00       	push   $0x80337c
  80120d:	e8 d2 f2 ff ff       	call   8004e4 <_panic>
int
sys_get_mac_address(void *buf)
{
	return syscall(SYS_get_mac_address, 1,
		(uint32_t) buf, 0, 0, 0, 0);
}
  801212:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801215:	5b                   	pop    %ebx
  801216:	5e                   	pop    %esi
  801217:	5f                   	pop    %edi
  801218:	5d                   	pop    %ebp
  801219:	c3                   	ret    

0080121a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	53                   	push   %ebx
  80121e:	83 ec 04             	sub    $0x4,%esp
  801221:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801224:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  801226:	89 da                	mov    %ebx,%edx
  801228:	c1 ea 0c             	shr    $0xc,%edx
	pte_t pte = uvpt[pn];
  80122b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  801232:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801236:	74 05                	je     80123d <pgfault+0x23>
  801238:	f6 c6 08             	test   $0x8,%dh
  80123b:	75 14                	jne    801251 <pgfault+0x37>
		panic("fork pgfault handler: does not handle this fault");
  80123d:	83 ec 04             	sub    $0x4,%esp
  801240:	68 8c 33 80 00       	push   $0x80338c
  801245:	6a 1f                	push   $0x1f
  801247:	68 bd 33 80 00       	push   $0x8033bd
  80124c:	e8 93 f2 ff ff       	call   8004e4 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  801251:	83 ec 04             	sub    $0x4,%esp
  801254:	6a 07                	push   $0x7
  801256:	68 00 f0 7f 00       	push   $0x7ff000
  80125b:	6a 00                	push   $0x0
  80125d:	e8 e3 fc ff ff       	call   800f45 <sys_page_alloc>
  801262:	83 c4 10             	add    $0x10,%esp
  801265:	85 c0                	test   %eax,%eax
  801267:	79 12                	jns    80127b <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  801269:	50                   	push   %eax
  80126a:	68 c8 33 80 00       	push   $0x8033c8
  80126f:	6a 2b                	push   $0x2b
  801271:	68 bd 33 80 00       	push   $0x8033bd
  801276:	e8 69 f2 ff ff       	call   8004e4 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  80127b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  801281:	83 ec 04             	sub    $0x4,%esp
  801284:	68 00 10 00 00       	push   $0x1000
  801289:	53                   	push   %ebx
  80128a:	68 00 f0 7f 00       	push   $0x7ff000
  80128f:	e8 40 fa ff ff       	call   800cd4 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  801294:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80129b:	53                   	push   %ebx
  80129c:	6a 00                	push   $0x0
  80129e:	68 00 f0 7f 00       	push   $0x7ff000
  8012a3:	6a 00                	push   $0x0
  8012a5:	e8 de fc ff ff       	call   800f88 <sys_page_map>
  8012aa:	83 c4 20             	add    $0x20,%esp
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	79 12                	jns    8012c3 <pgfault+0xa9>
		panic("sys_page_map: %e", r);
  8012b1:	50                   	push   %eax
  8012b2:	68 db 33 80 00       	push   $0x8033db
  8012b7:	6a 33                	push   $0x33
  8012b9:	68 bd 33 80 00       	push   $0x8033bd
  8012be:	e8 21 f2 ff ff       	call   8004e4 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  8012c3:	83 ec 08             	sub    $0x8,%esp
  8012c6:	68 00 f0 7f 00       	push   $0x7ff000
  8012cb:	6a 00                	push   $0x0
  8012cd:	e8 f8 fc ff ff       	call   800fca <sys_page_unmap>
  8012d2:	83 c4 10             	add    $0x10,%esp
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	79 12                	jns    8012eb <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  8012d9:	50                   	push   %eax
  8012da:	68 ec 33 80 00       	push   $0x8033ec
  8012df:	6a 37                	push   $0x37
  8012e1:	68 bd 33 80 00       	push   $0x8033bd
  8012e6:	e8 f9 f1 ff ff       	call   8004e4 <_panic>
}
  8012eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ee:	c9                   	leave  
  8012ef:	c3                   	ret    

008012f0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	57                   	push   %edi
  8012f4:	56                   	push   %esi
  8012f5:	53                   	push   %ebx
  8012f6:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  8012f9:	68 1a 12 80 00       	push   $0x80121a
  8012fe:	e8 be 17 00 00       	call   802ac1 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801303:	b8 07 00 00 00       	mov    $0x7,%eax
  801308:	cd 30                	int    $0x30
  80130a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80130d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Create child
	envid_t envid = sys_exofork();
	if (envid < 0) {
  801310:	83 c4 10             	add    $0x10,%esp
  801313:	85 c0                	test   %eax,%eax
  801315:	79 15                	jns    80132c <fork+0x3c>
		panic("sys_exofork: %e", envid);
  801317:	50                   	push   %eax
  801318:	68 ff 33 80 00       	push   $0x8033ff
  80131d:	68 93 00 00 00       	push   $0x93
  801322:	68 bd 33 80 00       	push   $0x8033bd
  801327:	e8 b8 f1 ff ff       	call   8004e4 <_panic>
		return envid;
	}

	// If we are the child, fix thisenv.
	if (envid == 0) {
  80132c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801330:	75 21                	jne    801353 <fork+0x63>
		thisenv = &envs[ENVX(sys_getenvid())];
  801332:	e8 d0 fb ff ff       	call   800f07 <sys_getenvid>
  801337:	25 ff 03 00 00       	and    $0x3ff,%eax
  80133c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80133f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801344:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  801349:	b8 00 00 00 00       	mov    $0x0,%eax
  80134e:	e9 5a 01 00 00       	jmp    8014ad <fork+0x1bd>
	// We are the parent!
	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle the
	// fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), PTE_P | PTE_U | PTE_W);
  801353:	83 ec 04             	sub    $0x4,%esp
  801356:	6a 07                	push   $0x7
  801358:	68 00 f0 bf ee       	push   $0xeebff000
  80135d:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801360:	57                   	push   %edi
  801361:	e8 df fb ff ff       	call   800f45 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801366:	83 c4 08             	add    $0x8,%esp
  801369:	68 06 2b 80 00       	push   $0x802b06
  80136e:	57                   	push   %edi
  80136f:	e8 1c fd ff ff       	call   801090 <sys_env_set_pgfault_upcall>
  801374:	83 c4 10             	add    $0x10,%esp

	// Copy our address space to child. Be careful not to copy the exception
	// stack too, so go until USTACKTOP instead of UTOP.
	unsigned pn;
	for (pn = UTEXT/PGSIZE; pn < USTACKTOP/PGSIZE; pn++) {
  801377:	bb 00 08 00 00       	mov    $0x800,%ebx
static int
duppage(envid_t envid, unsigned pn)
{
	// Check if the page table that contains the PTE we want is allocated
	// using UVPD. If it is not, just don't map anything, and silently succeed.
	if (!(uvpd[pn/NPTENTRIES] & PTE_P))
  80137c:	89 d8                	mov    %ebx,%eax
  80137e:	c1 e8 0a             	shr    $0xa,%eax
  801381:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801388:	a8 01                	test   $0x1,%al
  80138a:	0f 84 e2 00 00 00    	je     801472 <fork+0x182>
		return 0;

	// Retrieve the PTE using UVPT
	pte_t pte = uvpt[pn];
  801390:	8b 34 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%esi

	// If the page is present, duplicate according to it's permissions
	if (pte & PTE_P) {
  801397:	f7 c6 01 00 00 00    	test   $0x1,%esi
  80139d:	0f 84 cf 00 00 00    	je     801472 <fork+0x182>
		int r;
		uint32_t perm = pte & PTE_SYSCALL;
  8013a3:	89 f0                	mov    %esi,%eax
  8013a5:	25 07 0e 00 00       	and    $0xe07,%eax
  8013aa:	89 df                	mov    %ebx,%edi
  8013ac:	c1 e7 0c             	shl    $0xc,%edi
		void *va = (void *) (pn * PGSIZE);

		// If PTE_SHARE is enabled, share it by just copying the
		// pte, which can be done by mapping on the same address
		// with the same permissions, even if it is writable
		if (pte & PTE_SHARE) {
  8013af:	f7 c6 00 04 00 00    	test   $0x400,%esi
  8013b5:	74 2d                	je     8013e4 <fork+0xf4>
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  8013b7:	83 ec 0c             	sub    $0xc,%esp
  8013ba:	50                   	push   %eax
  8013bb:	57                   	push   %edi
  8013bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013bf:	57                   	push   %edi
  8013c0:	6a 00                	push   $0x0
  8013c2:	e8 c1 fb ff ff       	call   800f88 <sys_page_map>
  8013c7:	83 c4 20             	add    $0x20,%esp
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	0f 89 a0 00 00 00    	jns    801472 <fork+0x182>
				panic("sys_page_map: %e", r);
  8013d2:	50                   	push   %eax
  8013d3:	68 db 33 80 00       	push   $0x8033db
  8013d8:	6a 5c                	push   $0x5c
  8013da:	68 bd 33 80 00       	push   $0x8033bd
  8013df:	e8 00 f1 ff ff       	call   8004e4 <_panic>
				return r;
			}
		// If writable or COW, make it COW on parent and child
		} else if (pte & (PTE_W | PTE_COW)) {
  8013e4:	f7 c6 02 08 00 00    	test   $0x802,%esi
  8013ea:	74 5d                	je     801449 <fork+0x159>
			perm &= ~PTE_W;  // Remove PTE_W, so it faults
  8013ec:	81 e6 05 0e 00 00    	and    $0xe05,%esi
			perm |= PTE_COW; // Make it PTE_COW
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  8013f2:	81 ce 00 08 00 00    	or     $0x800,%esi
  8013f8:	83 ec 0c             	sub    $0xc,%esp
  8013fb:	56                   	push   %esi
  8013fc:	57                   	push   %edi
  8013fd:	ff 75 e4             	pushl  -0x1c(%ebp)
  801400:	57                   	push   %edi
  801401:	6a 00                	push   $0x0
  801403:	e8 80 fb ff ff       	call   800f88 <sys_page_map>
  801408:	83 c4 20             	add    $0x20,%esp
  80140b:	85 c0                	test   %eax,%eax
  80140d:	79 12                	jns    801421 <fork+0x131>
				panic("sys_page_map: %e", r);
  80140f:	50                   	push   %eax
  801410:	68 db 33 80 00       	push   $0x8033db
  801415:	6a 65                	push   $0x65
  801417:	68 bd 33 80 00       	push   $0x8033bd
  80141c:	e8 c3 f0 ff ff       	call   8004e4 <_panic>
				return r;
			}
			// Change the permission on parent, mapping on itself
			if ((r = sys_page_map(0, va, 0, va, perm)) < 0) {
  801421:	83 ec 0c             	sub    $0xc,%esp
  801424:	56                   	push   %esi
  801425:	57                   	push   %edi
  801426:	6a 00                	push   $0x0
  801428:	57                   	push   %edi
  801429:	6a 00                	push   $0x0
  80142b:	e8 58 fb ff ff       	call   800f88 <sys_page_map>
  801430:	83 c4 20             	add    $0x20,%esp
  801433:	85 c0                	test   %eax,%eax
  801435:	79 3b                	jns    801472 <fork+0x182>
				panic("sys_page_map: %e", r);
  801437:	50                   	push   %eax
  801438:	68 db 33 80 00       	push   $0x8033db
  80143d:	6a 6a                	push   $0x6a
  80143f:	68 bd 33 80 00       	push   $0x8033bd
  801444:	e8 9b f0 ff ff       	call   8004e4 <_panic>
				return r;
			}
		// If it is read-only, just share it.
		} else {
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  801449:	83 ec 0c             	sub    $0xc,%esp
  80144c:	50                   	push   %eax
  80144d:	57                   	push   %edi
  80144e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801451:	57                   	push   %edi
  801452:	6a 00                	push   $0x0
  801454:	e8 2f fb ff ff       	call   800f88 <sys_page_map>
  801459:	83 c4 20             	add    $0x20,%esp
  80145c:	85 c0                	test   %eax,%eax
  80145e:	79 12                	jns    801472 <fork+0x182>
				panic("sys_page_map: %e", r);
  801460:	50                   	push   %eax
  801461:	68 db 33 80 00       	push   $0x8033db
  801466:	6a 71                	push   $0x71
  801468:	68 bd 33 80 00       	push   $0x8033bd
  80146d:	e8 72 f0 ff ff       	call   8004e4 <_panic>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);

	// Copy our address space to child. Be careful not to copy the exception
	// stack too, so go until USTACKTOP instead of UTOP.
	unsigned pn;
	for (pn = UTEXT/PGSIZE; pn < USTACKTOP/PGSIZE; pn++) {
  801472:	83 c3 01             	add    $0x1,%ebx
  801475:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  80147b:	0f 85 fb fe ff ff    	jne    80137c <fork+0x8c>
		duppage(envid, pn);
	}

	// Make the child runnable
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801481:	83 ec 08             	sub    $0x8,%esp
  801484:	6a 02                	push   $0x2
  801486:	ff 75 e0             	pushl  -0x20(%ebp)
  801489:	e8 7e fb ff ff       	call   80100c <sys_env_set_status>
  80148e:	83 c4 10             	add    $0x10,%esp
  801491:	85 c0                	test   %eax,%eax
  801493:	79 15                	jns    8014aa <fork+0x1ba>
		panic("sys_env_set_status: %e", r);
  801495:	50                   	push   %eax
  801496:	68 0f 34 80 00       	push   $0x80340f
  80149b:	68 af 00 00 00       	push   $0xaf
  8014a0:	68 bd 33 80 00       	push   $0x8033bd
  8014a5:	e8 3a f0 ff ff       	call   8004e4 <_panic>
		return r;
	}

	return envid;
  8014aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  8014ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b0:	5b                   	pop    %ebx
  8014b1:	5e                   	pop    %esi
  8014b2:	5f                   	pop    %edi
  8014b3:	5d                   	pop    %ebp
  8014b4:	c3                   	ret    

008014b5 <sfork>:

// Challenge!
int
sfork(void)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8014bb:	68 26 34 80 00       	push   $0x803426
  8014c0:	68 ba 00 00 00       	push   $0xba
  8014c5:	68 bd 33 80 00       	push   $0x8033bd
  8014ca:	e8 15 f0 ff ff       	call   8004e4 <_panic>

008014cf <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d5:	05 00 00 00 30       	add    $0x30000000,%eax
  8014da:	c1 e8 0c             	shr    $0xc,%eax
}
  8014dd:	5d                   	pop    %ebp
  8014de:	c3                   	ret    

008014df <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8014e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e5:	05 00 00 00 30       	add    $0x30000000,%eax
  8014ea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014ef:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014f4:	5d                   	pop    %ebp
  8014f5:	c3                   	ret    

008014f6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014fc:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801501:	89 c2                	mov    %eax,%edx
  801503:	c1 ea 16             	shr    $0x16,%edx
  801506:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80150d:	f6 c2 01             	test   $0x1,%dl
  801510:	74 11                	je     801523 <fd_alloc+0x2d>
  801512:	89 c2                	mov    %eax,%edx
  801514:	c1 ea 0c             	shr    $0xc,%edx
  801517:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80151e:	f6 c2 01             	test   $0x1,%dl
  801521:	75 09                	jne    80152c <fd_alloc+0x36>
			*fd_store = fd;
  801523:	89 01                	mov    %eax,(%ecx)
			return 0;
  801525:	b8 00 00 00 00       	mov    $0x0,%eax
  80152a:	eb 17                	jmp    801543 <fd_alloc+0x4d>
  80152c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801531:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801536:	75 c9                	jne    801501 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801538:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80153e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801543:	5d                   	pop    %ebp
  801544:	c3                   	ret    

00801545 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80154b:	83 f8 1f             	cmp    $0x1f,%eax
  80154e:	77 36                	ja     801586 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801550:	c1 e0 0c             	shl    $0xc,%eax
  801553:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801558:	89 c2                	mov    %eax,%edx
  80155a:	c1 ea 16             	shr    $0x16,%edx
  80155d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801564:	f6 c2 01             	test   $0x1,%dl
  801567:	74 24                	je     80158d <fd_lookup+0x48>
  801569:	89 c2                	mov    %eax,%edx
  80156b:	c1 ea 0c             	shr    $0xc,%edx
  80156e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801575:	f6 c2 01             	test   $0x1,%dl
  801578:	74 1a                	je     801594 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80157a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80157d:	89 02                	mov    %eax,(%edx)
	return 0;
  80157f:	b8 00 00 00 00       	mov    $0x0,%eax
  801584:	eb 13                	jmp    801599 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801586:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80158b:	eb 0c                	jmp    801599 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80158d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801592:	eb 05                	jmp    801599 <fd_lookup+0x54>
  801594:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801599:	5d                   	pop    %ebp
  80159a:	c3                   	ret    

0080159b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80159b:	55                   	push   %ebp
  80159c:	89 e5                	mov    %esp,%ebp
  80159e:	83 ec 08             	sub    $0x8,%esp
  8015a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015a4:	ba b8 34 80 00       	mov    $0x8034b8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8015a9:	eb 13                	jmp    8015be <dev_lookup+0x23>
  8015ab:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8015ae:	39 08                	cmp    %ecx,(%eax)
  8015b0:	75 0c                	jne    8015be <dev_lookup+0x23>
			*dev = devtab[i];
  8015b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015b5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8015b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8015bc:	eb 2e                	jmp    8015ec <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015be:	8b 02                	mov    (%edx),%eax
  8015c0:	85 c0                	test   %eax,%eax
  8015c2:	75 e7                	jne    8015ab <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015c4:	a1 08 50 80 00       	mov    0x805008,%eax
  8015c9:	8b 40 48             	mov    0x48(%eax),%eax
  8015cc:	83 ec 04             	sub    $0x4,%esp
  8015cf:	51                   	push   %ecx
  8015d0:	50                   	push   %eax
  8015d1:	68 3c 34 80 00       	push   $0x80343c
  8015d6:	e8 e2 ef ff ff       	call   8005bd <cprintf>
	*dev = 0;
  8015db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015de:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015ec:	c9                   	leave  
  8015ed:	c3                   	ret    

008015ee <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	56                   	push   %esi
  8015f2:	53                   	push   %ebx
  8015f3:	83 ec 10             	sub    $0x10,%esp
  8015f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8015f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ff:	50                   	push   %eax
  801600:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801606:	c1 e8 0c             	shr    $0xc,%eax
  801609:	50                   	push   %eax
  80160a:	e8 36 ff ff ff       	call   801545 <fd_lookup>
  80160f:	83 c4 08             	add    $0x8,%esp
  801612:	85 c0                	test   %eax,%eax
  801614:	78 05                	js     80161b <fd_close+0x2d>
	    || fd != fd2)
  801616:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801619:	74 0c                	je     801627 <fd_close+0x39>
		return (must_exist ? r : 0);
  80161b:	84 db                	test   %bl,%bl
  80161d:	ba 00 00 00 00       	mov    $0x0,%edx
  801622:	0f 44 c2             	cmove  %edx,%eax
  801625:	eb 41                	jmp    801668 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801627:	83 ec 08             	sub    $0x8,%esp
  80162a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162d:	50                   	push   %eax
  80162e:	ff 36                	pushl  (%esi)
  801630:	e8 66 ff ff ff       	call   80159b <dev_lookup>
  801635:	89 c3                	mov    %eax,%ebx
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	85 c0                	test   %eax,%eax
  80163c:	78 1a                	js     801658 <fd_close+0x6a>
		if (dev->dev_close)
  80163e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801641:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801644:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801649:	85 c0                	test   %eax,%eax
  80164b:	74 0b                	je     801658 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80164d:	83 ec 0c             	sub    $0xc,%esp
  801650:	56                   	push   %esi
  801651:	ff d0                	call   *%eax
  801653:	89 c3                	mov    %eax,%ebx
  801655:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801658:	83 ec 08             	sub    $0x8,%esp
  80165b:	56                   	push   %esi
  80165c:	6a 00                	push   $0x0
  80165e:	e8 67 f9 ff ff       	call   800fca <sys_page_unmap>
	return r;
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	89 d8                	mov    %ebx,%eax
}
  801668:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166b:	5b                   	pop    %ebx
  80166c:	5e                   	pop    %esi
  80166d:	5d                   	pop    %ebp
  80166e:	c3                   	ret    

0080166f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801675:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801678:	50                   	push   %eax
  801679:	ff 75 08             	pushl  0x8(%ebp)
  80167c:	e8 c4 fe ff ff       	call   801545 <fd_lookup>
  801681:	83 c4 08             	add    $0x8,%esp
  801684:	85 c0                	test   %eax,%eax
  801686:	78 10                	js     801698 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801688:	83 ec 08             	sub    $0x8,%esp
  80168b:	6a 01                	push   $0x1
  80168d:	ff 75 f4             	pushl  -0xc(%ebp)
  801690:	e8 59 ff ff ff       	call   8015ee <fd_close>
  801695:	83 c4 10             	add    $0x10,%esp
}
  801698:	c9                   	leave  
  801699:	c3                   	ret    

0080169a <close_all>:

void
close_all(void)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	53                   	push   %ebx
  80169e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016a1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016a6:	83 ec 0c             	sub    $0xc,%esp
  8016a9:	53                   	push   %ebx
  8016aa:	e8 c0 ff ff ff       	call   80166f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016af:	83 c3 01             	add    $0x1,%ebx
  8016b2:	83 c4 10             	add    $0x10,%esp
  8016b5:	83 fb 20             	cmp    $0x20,%ebx
  8016b8:	75 ec                	jne    8016a6 <close_all+0xc>
		close(i);
}
  8016ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    

008016bf <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	57                   	push   %edi
  8016c3:	56                   	push   %esi
  8016c4:	53                   	push   %ebx
  8016c5:	83 ec 2c             	sub    $0x2c,%esp
  8016c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016cb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016ce:	50                   	push   %eax
  8016cf:	ff 75 08             	pushl  0x8(%ebp)
  8016d2:	e8 6e fe ff ff       	call   801545 <fd_lookup>
  8016d7:	83 c4 08             	add    $0x8,%esp
  8016da:	85 c0                	test   %eax,%eax
  8016dc:	0f 88 c1 00 00 00    	js     8017a3 <dup+0xe4>
		return r;
	close(newfdnum);
  8016e2:	83 ec 0c             	sub    $0xc,%esp
  8016e5:	56                   	push   %esi
  8016e6:	e8 84 ff ff ff       	call   80166f <close>

	newfd = INDEX2FD(newfdnum);
  8016eb:	89 f3                	mov    %esi,%ebx
  8016ed:	c1 e3 0c             	shl    $0xc,%ebx
  8016f0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8016f6:	83 c4 04             	add    $0x4,%esp
  8016f9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016fc:	e8 de fd ff ff       	call   8014df <fd2data>
  801701:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801703:	89 1c 24             	mov    %ebx,(%esp)
  801706:	e8 d4 fd ff ff       	call   8014df <fd2data>
  80170b:	83 c4 10             	add    $0x10,%esp
  80170e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801711:	89 f8                	mov    %edi,%eax
  801713:	c1 e8 16             	shr    $0x16,%eax
  801716:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80171d:	a8 01                	test   $0x1,%al
  80171f:	74 37                	je     801758 <dup+0x99>
  801721:	89 f8                	mov    %edi,%eax
  801723:	c1 e8 0c             	shr    $0xc,%eax
  801726:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80172d:	f6 c2 01             	test   $0x1,%dl
  801730:	74 26                	je     801758 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801732:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801739:	83 ec 0c             	sub    $0xc,%esp
  80173c:	25 07 0e 00 00       	and    $0xe07,%eax
  801741:	50                   	push   %eax
  801742:	ff 75 d4             	pushl  -0x2c(%ebp)
  801745:	6a 00                	push   $0x0
  801747:	57                   	push   %edi
  801748:	6a 00                	push   $0x0
  80174a:	e8 39 f8 ff ff       	call   800f88 <sys_page_map>
  80174f:	89 c7                	mov    %eax,%edi
  801751:	83 c4 20             	add    $0x20,%esp
  801754:	85 c0                	test   %eax,%eax
  801756:	78 2e                	js     801786 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801758:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80175b:	89 d0                	mov    %edx,%eax
  80175d:	c1 e8 0c             	shr    $0xc,%eax
  801760:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801767:	83 ec 0c             	sub    $0xc,%esp
  80176a:	25 07 0e 00 00       	and    $0xe07,%eax
  80176f:	50                   	push   %eax
  801770:	53                   	push   %ebx
  801771:	6a 00                	push   $0x0
  801773:	52                   	push   %edx
  801774:	6a 00                	push   $0x0
  801776:	e8 0d f8 ff ff       	call   800f88 <sys_page_map>
  80177b:	89 c7                	mov    %eax,%edi
  80177d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801780:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801782:	85 ff                	test   %edi,%edi
  801784:	79 1d                	jns    8017a3 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801786:	83 ec 08             	sub    $0x8,%esp
  801789:	53                   	push   %ebx
  80178a:	6a 00                	push   $0x0
  80178c:	e8 39 f8 ff ff       	call   800fca <sys_page_unmap>
	sys_page_unmap(0, nva);
  801791:	83 c4 08             	add    $0x8,%esp
  801794:	ff 75 d4             	pushl  -0x2c(%ebp)
  801797:	6a 00                	push   $0x0
  801799:	e8 2c f8 ff ff       	call   800fca <sys_page_unmap>
	return r;
  80179e:	83 c4 10             	add    $0x10,%esp
  8017a1:	89 f8                	mov    %edi,%eax
}
  8017a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017a6:	5b                   	pop    %ebx
  8017a7:	5e                   	pop    %esi
  8017a8:	5f                   	pop    %edi
  8017a9:	5d                   	pop    %ebp
  8017aa:	c3                   	ret    

008017ab <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	53                   	push   %ebx
  8017af:	83 ec 14             	sub    $0x14,%esp
  8017b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b8:	50                   	push   %eax
  8017b9:	53                   	push   %ebx
  8017ba:	e8 86 fd ff ff       	call   801545 <fd_lookup>
  8017bf:	83 c4 08             	add    $0x8,%esp
  8017c2:	89 c2                	mov    %eax,%edx
  8017c4:	85 c0                	test   %eax,%eax
  8017c6:	78 6d                	js     801835 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c8:	83 ec 08             	sub    $0x8,%esp
  8017cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ce:	50                   	push   %eax
  8017cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d2:	ff 30                	pushl  (%eax)
  8017d4:	e8 c2 fd ff ff       	call   80159b <dev_lookup>
  8017d9:	83 c4 10             	add    $0x10,%esp
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	78 4c                	js     80182c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017e3:	8b 42 08             	mov    0x8(%edx),%eax
  8017e6:	83 e0 03             	and    $0x3,%eax
  8017e9:	83 f8 01             	cmp    $0x1,%eax
  8017ec:	75 21                	jne    80180f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017ee:	a1 08 50 80 00       	mov    0x805008,%eax
  8017f3:	8b 40 48             	mov    0x48(%eax),%eax
  8017f6:	83 ec 04             	sub    $0x4,%esp
  8017f9:	53                   	push   %ebx
  8017fa:	50                   	push   %eax
  8017fb:	68 7d 34 80 00       	push   $0x80347d
  801800:	e8 b8 ed ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  801805:	83 c4 10             	add    $0x10,%esp
  801808:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80180d:	eb 26                	jmp    801835 <read+0x8a>
	}
	if (!dev->dev_read)
  80180f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801812:	8b 40 08             	mov    0x8(%eax),%eax
  801815:	85 c0                	test   %eax,%eax
  801817:	74 17                	je     801830 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801819:	83 ec 04             	sub    $0x4,%esp
  80181c:	ff 75 10             	pushl  0x10(%ebp)
  80181f:	ff 75 0c             	pushl  0xc(%ebp)
  801822:	52                   	push   %edx
  801823:	ff d0                	call   *%eax
  801825:	89 c2                	mov    %eax,%edx
  801827:	83 c4 10             	add    $0x10,%esp
  80182a:	eb 09                	jmp    801835 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182c:	89 c2                	mov    %eax,%edx
  80182e:	eb 05                	jmp    801835 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801830:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801835:	89 d0                	mov    %edx,%eax
  801837:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183a:	c9                   	leave  
  80183b:	c3                   	ret    

0080183c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	57                   	push   %edi
  801840:	56                   	push   %esi
  801841:	53                   	push   %ebx
  801842:	83 ec 0c             	sub    $0xc,%esp
  801845:	8b 7d 08             	mov    0x8(%ebp),%edi
  801848:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80184b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801850:	eb 21                	jmp    801873 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801852:	83 ec 04             	sub    $0x4,%esp
  801855:	89 f0                	mov    %esi,%eax
  801857:	29 d8                	sub    %ebx,%eax
  801859:	50                   	push   %eax
  80185a:	89 d8                	mov    %ebx,%eax
  80185c:	03 45 0c             	add    0xc(%ebp),%eax
  80185f:	50                   	push   %eax
  801860:	57                   	push   %edi
  801861:	e8 45 ff ff ff       	call   8017ab <read>
		if (m < 0)
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	85 c0                	test   %eax,%eax
  80186b:	78 10                	js     80187d <readn+0x41>
			return m;
		if (m == 0)
  80186d:	85 c0                	test   %eax,%eax
  80186f:	74 0a                	je     80187b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801871:	01 c3                	add    %eax,%ebx
  801873:	39 f3                	cmp    %esi,%ebx
  801875:	72 db                	jb     801852 <readn+0x16>
  801877:	89 d8                	mov    %ebx,%eax
  801879:	eb 02                	jmp    80187d <readn+0x41>
  80187b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80187d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801880:	5b                   	pop    %ebx
  801881:	5e                   	pop    %esi
  801882:	5f                   	pop    %edi
  801883:	5d                   	pop    %ebp
  801884:	c3                   	ret    

00801885 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	53                   	push   %ebx
  801889:	83 ec 14             	sub    $0x14,%esp
  80188c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80188f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801892:	50                   	push   %eax
  801893:	53                   	push   %ebx
  801894:	e8 ac fc ff ff       	call   801545 <fd_lookup>
  801899:	83 c4 08             	add    $0x8,%esp
  80189c:	89 c2                	mov    %eax,%edx
  80189e:	85 c0                	test   %eax,%eax
  8018a0:	78 68                	js     80190a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a2:	83 ec 08             	sub    $0x8,%esp
  8018a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a8:	50                   	push   %eax
  8018a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ac:	ff 30                	pushl  (%eax)
  8018ae:	e8 e8 fc ff ff       	call   80159b <dev_lookup>
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	85 c0                	test   %eax,%eax
  8018b8:	78 47                	js     801901 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018bd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018c1:	75 21                	jne    8018e4 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018c3:	a1 08 50 80 00       	mov    0x805008,%eax
  8018c8:	8b 40 48             	mov    0x48(%eax),%eax
  8018cb:	83 ec 04             	sub    $0x4,%esp
  8018ce:	53                   	push   %ebx
  8018cf:	50                   	push   %eax
  8018d0:	68 99 34 80 00       	push   $0x803499
  8018d5:	e8 e3 ec ff ff       	call   8005bd <cprintf>
		return -E_INVAL;
  8018da:	83 c4 10             	add    $0x10,%esp
  8018dd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018e2:	eb 26                	jmp    80190a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018e7:	8b 52 0c             	mov    0xc(%edx),%edx
  8018ea:	85 d2                	test   %edx,%edx
  8018ec:	74 17                	je     801905 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018ee:	83 ec 04             	sub    $0x4,%esp
  8018f1:	ff 75 10             	pushl  0x10(%ebp)
  8018f4:	ff 75 0c             	pushl  0xc(%ebp)
  8018f7:	50                   	push   %eax
  8018f8:	ff d2                	call   *%edx
  8018fa:	89 c2                	mov    %eax,%edx
  8018fc:	83 c4 10             	add    $0x10,%esp
  8018ff:	eb 09                	jmp    80190a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801901:	89 c2                	mov    %eax,%edx
  801903:	eb 05                	jmp    80190a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801905:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80190a:	89 d0                	mov    %edx,%eax
  80190c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190f:	c9                   	leave  
  801910:	c3                   	ret    

00801911 <seek>:

int
seek(int fdnum, off_t offset)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801917:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80191a:	50                   	push   %eax
  80191b:	ff 75 08             	pushl  0x8(%ebp)
  80191e:	e8 22 fc ff ff       	call   801545 <fd_lookup>
  801923:	83 c4 08             	add    $0x8,%esp
  801926:	85 c0                	test   %eax,%eax
  801928:	78 0e                	js     801938 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80192a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80192d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801930:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801933:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801938:	c9                   	leave  
  801939:	c3                   	ret    

0080193a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	53                   	push   %ebx
  80193e:	83 ec 14             	sub    $0x14,%esp
  801941:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801944:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801947:	50                   	push   %eax
  801948:	53                   	push   %ebx
  801949:	e8 f7 fb ff ff       	call   801545 <fd_lookup>
  80194e:	83 c4 08             	add    $0x8,%esp
  801951:	89 c2                	mov    %eax,%edx
  801953:	85 c0                	test   %eax,%eax
  801955:	78 65                	js     8019bc <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801957:	83 ec 08             	sub    $0x8,%esp
  80195a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195d:	50                   	push   %eax
  80195e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801961:	ff 30                	pushl  (%eax)
  801963:	e8 33 fc ff ff       	call   80159b <dev_lookup>
  801968:	83 c4 10             	add    $0x10,%esp
  80196b:	85 c0                	test   %eax,%eax
  80196d:	78 44                	js     8019b3 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80196f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801972:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801976:	75 21                	jne    801999 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801978:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80197d:	8b 40 48             	mov    0x48(%eax),%eax
  801980:	83 ec 04             	sub    $0x4,%esp
  801983:	53                   	push   %ebx
  801984:	50                   	push   %eax
  801985:	68 5c 34 80 00       	push   $0x80345c
  80198a:	e8 2e ec ff ff       	call   8005bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80198f:	83 c4 10             	add    $0x10,%esp
  801992:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801997:	eb 23                	jmp    8019bc <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801999:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80199c:	8b 52 18             	mov    0x18(%edx),%edx
  80199f:	85 d2                	test   %edx,%edx
  8019a1:	74 14                	je     8019b7 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019a3:	83 ec 08             	sub    $0x8,%esp
  8019a6:	ff 75 0c             	pushl  0xc(%ebp)
  8019a9:	50                   	push   %eax
  8019aa:	ff d2                	call   *%edx
  8019ac:	89 c2                	mov    %eax,%edx
  8019ae:	83 c4 10             	add    $0x10,%esp
  8019b1:	eb 09                	jmp    8019bc <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019b3:	89 c2                	mov    %eax,%edx
  8019b5:	eb 05                	jmp    8019bc <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019b7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8019bc:	89 d0                	mov    %edx,%eax
  8019be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c1:	c9                   	leave  
  8019c2:	c3                   	ret    

008019c3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019c3:	55                   	push   %ebp
  8019c4:	89 e5                	mov    %esp,%ebp
  8019c6:	53                   	push   %ebx
  8019c7:	83 ec 14             	sub    $0x14,%esp
  8019ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019d0:	50                   	push   %eax
  8019d1:	ff 75 08             	pushl  0x8(%ebp)
  8019d4:	e8 6c fb ff ff       	call   801545 <fd_lookup>
  8019d9:	83 c4 08             	add    $0x8,%esp
  8019dc:	89 c2                	mov    %eax,%edx
  8019de:	85 c0                	test   %eax,%eax
  8019e0:	78 58                	js     801a3a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019e2:	83 ec 08             	sub    $0x8,%esp
  8019e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e8:	50                   	push   %eax
  8019e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ec:	ff 30                	pushl  (%eax)
  8019ee:	e8 a8 fb ff ff       	call   80159b <dev_lookup>
  8019f3:	83 c4 10             	add    $0x10,%esp
  8019f6:	85 c0                	test   %eax,%eax
  8019f8:	78 37                	js     801a31 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8019fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019fd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a01:	74 32                	je     801a35 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a03:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a06:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a0d:	00 00 00 
	stat->st_isdir = 0;
  801a10:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a17:	00 00 00 
	stat->st_dev = dev;
  801a1a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a20:	83 ec 08             	sub    $0x8,%esp
  801a23:	53                   	push   %ebx
  801a24:	ff 75 f0             	pushl  -0x10(%ebp)
  801a27:	ff 50 14             	call   *0x14(%eax)
  801a2a:	89 c2                	mov    %eax,%edx
  801a2c:	83 c4 10             	add    $0x10,%esp
  801a2f:	eb 09                	jmp    801a3a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a31:	89 c2                	mov    %eax,%edx
  801a33:	eb 05                	jmp    801a3a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a35:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a3a:	89 d0                	mov    %edx,%eax
  801a3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3f:	c9                   	leave  
  801a40:	c3                   	ret    

00801a41 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	56                   	push   %esi
  801a45:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a46:	83 ec 08             	sub    $0x8,%esp
  801a49:	6a 00                	push   $0x0
  801a4b:	ff 75 08             	pushl  0x8(%ebp)
  801a4e:	e8 0c 02 00 00       	call   801c5f <open>
  801a53:	89 c3                	mov    %eax,%ebx
  801a55:	83 c4 10             	add    $0x10,%esp
  801a58:	85 c0                	test   %eax,%eax
  801a5a:	78 1b                	js     801a77 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a5c:	83 ec 08             	sub    $0x8,%esp
  801a5f:	ff 75 0c             	pushl  0xc(%ebp)
  801a62:	50                   	push   %eax
  801a63:	e8 5b ff ff ff       	call   8019c3 <fstat>
  801a68:	89 c6                	mov    %eax,%esi
	close(fd);
  801a6a:	89 1c 24             	mov    %ebx,(%esp)
  801a6d:	e8 fd fb ff ff       	call   80166f <close>
	return r;
  801a72:	83 c4 10             	add    $0x10,%esp
  801a75:	89 f0                	mov    %esi,%eax
}
  801a77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7a:	5b                   	pop    %ebx
  801a7b:	5e                   	pop    %esi
  801a7c:	5d                   	pop    %ebp
  801a7d:	c3                   	ret    

00801a7e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	56                   	push   %esi
  801a82:	53                   	push   %ebx
  801a83:	89 c6                	mov    %eax,%esi
  801a85:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a87:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801a8e:	75 12                	jne    801aa2 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a90:	83 ec 0c             	sub    $0xc,%esp
  801a93:	6a 01                	push   $0x1
  801a95:	e8 5a 11 00 00       	call   802bf4 <ipc_find_env>
  801a9a:	a3 00 50 80 00       	mov    %eax,0x805000
  801a9f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801aa2:	6a 07                	push   $0x7
  801aa4:	68 00 60 80 00       	push   $0x806000
  801aa9:	56                   	push   %esi
  801aaa:	ff 35 00 50 80 00    	pushl  0x805000
  801ab0:	e8 eb 10 00 00       	call   802ba0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ab5:	83 c4 0c             	add    $0xc,%esp
  801ab8:	6a 00                	push   $0x0
  801aba:	53                   	push   %ebx
  801abb:	6a 00                	push   $0x0
  801abd:	e8 75 10 00 00       	call   802b37 <ipc_recv>
}
  801ac2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac5:	5b                   	pop    %ebx
  801ac6:	5e                   	pop    %esi
  801ac7:	5d                   	pop    %ebp
  801ac8:	c3                   	ret    

00801ac9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801acf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad2:	8b 40 0c             	mov    0xc(%eax),%eax
  801ad5:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801ada:	8b 45 0c             	mov    0xc(%ebp),%eax
  801add:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ae2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae7:	b8 02 00 00 00       	mov    $0x2,%eax
  801aec:	e8 8d ff ff ff       	call   801a7e <fsipc>
}
  801af1:	c9                   	leave  
  801af2:	c3                   	ret    

00801af3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801af9:	8b 45 08             	mov    0x8(%ebp),%eax
  801afc:	8b 40 0c             	mov    0xc(%eax),%eax
  801aff:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b04:	ba 00 00 00 00       	mov    $0x0,%edx
  801b09:	b8 06 00 00 00       	mov    $0x6,%eax
  801b0e:	e8 6b ff ff ff       	call   801a7e <fsipc>
}
  801b13:	c9                   	leave  
  801b14:	c3                   	ret    

00801b15 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	53                   	push   %ebx
  801b19:	83 ec 04             	sub    $0x4,%esp
  801b1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b22:	8b 40 0c             	mov    0xc(%eax),%eax
  801b25:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2f:	b8 05 00 00 00       	mov    $0x5,%eax
  801b34:	e8 45 ff ff ff       	call   801a7e <fsipc>
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	78 2c                	js     801b69 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b3d:	83 ec 08             	sub    $0x8,%esp
  801b40:	68 00 60 80 00       	push   $0x806000
  801b45:	53                   	push   %ebx
  801b46:	e8 f7 ef ff ff       	call   800b42 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b4b:	a1 80 60 80 00       	mov    0x806080,%eax
  801b50:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b56:	a1 84 60 80 00       	mov    0x806084,%eax
  801b5b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b61:	83 c4 10             	add    $0x10,%esp
  801b64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b6c:	c9                   	leave  
  801b6d:	c3                   	ret    

00801b6e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	53                   	push   %ebx
  801b72:	83 ec 08             	sub    $0x8,%esp
  801b75:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b78:	8b 55 08             	mov    0x8(%ebp),%edx
  801b7b:	8b 52 0c             	mov    0xc(%edx),%edx
  801b7e:	89 15 00 60 80 00    	mov    %edx,0x806000
  801b84:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b89:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801b8e:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  801b91:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801b97:	53                   	push   %ebx
  801b98:	ff 75 0c             	pushl  0xc(%ebp)
  801b9b:	68 08 60 80 00       	push   $0x806008
  801ba0:	e8 2f f1 ff ff       	call   800cd4 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  801ba5:	ba 00 00 00 00       	mov    $0x0,%edx
  801baa:	b8 04 00 00 00       	mov    $0x4,%eax
  801baf:	e8 ca fe ff ff       	call   801a7e <fsipc>
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	78 1d                	js     801bd8 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  801bbb:	39 d8                	cmp    %ebx,%eax
  801bbd:	76 19                	jbe    801bd8 <devfile_write+0x6a>
  801bbf:	68 cc 34 80 00       	push   $0x8034cc
  801bc4:	68 d8 34 80 00       	push   $0x8034d8
  801bc9:	68 a5 00 00 00       	push   $0xa5
  801bce:	68 ed 34 80 00       	push   $0x8034ed
  801bd3:	e8 0c e9 ff ff       	call   8004e4 <_panic>
	return r;
}
  801bd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bdb:	c9                   	leave  
  801bdc:	c3                   	ret    

00801bdd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	56                   	push   %esi
  801be1:	53                   	push   %ebx
  801be2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801be5:	8b 45 08             	mov    0x8(%ebp),%eax
  801be8:	8b 40 0c             	mov    0xc(%eax),%eax
  801beb:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801bf0:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bf6:	ba 00 00 00 00       	mov    $0x0,%edx
  801bfb:	b8 03 00 00 00       	mov    $0x3,%eax
  801c00:	e8 79 fe ff ff       	call   801a7e <fsipc>
  801c05:	89 c3                	mov    %eax,%ebx
  801c07:	85 c0                	test   %eax,%eax
  801c09:	78 4b                	js     801c56 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801c0b:	39 c6                	cmp    %eax,%esi
  801c0d:	73 16                	jae    801c25 <devfile_read+0x48>
  801c0f:	68 f8 34 80 00       	push   $0x8034f8
  801c14:	68 d8 34 80 00       	push   $0x8034d8
  801c19:	6a 7c                	push   $0x7c
  801c1b:	68 ed 34 80 00       	push   $0x8034ed
  801c20:	e8 bf e8 ff ff       	call   8004e4 <_panic>
	assert(r <= PGSIZE);
  801c25:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c2a:	7e 16                	jle    801c42 <devfile_read+0x65>
  801c2c:	68 ff 34 80 00       	push   $0x8034ff
  801c31:	68 d8 34 80 00       	push   $0x8034d8
  801c36:	6a 7d                	push   $0x7d
  801c38:	68 ed 34 80 00       	push   $0x8034ed
  801c3d:	e8 a2 e8 ff ff       	call   8004e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c42:	83 ec 04             	sub    $0x4,%esp
  801c45:	50                   	push   %eax
  801c46:	68 00 60 80 00       	push   $0x806000
  801c4b:	ff 75 0c             	pushl  0xc(%ebp)
  801c4e:	e8 81 f0 ff ff       	call   800cd4 <memmove>
	return r;
  801c53:	83 c4 10             	add    $0x10,%esp
}
  801c56:	89 d8                	mov    %ebx,%eax
  801c58:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c5b:	5b                   	pop    %ebx
  801c5c:	5e                   	pop    %esi
  801c5d:	5d                   	pop    %ebp
  801c5e:	c3                   	ret    

00801c5f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	53                   	push   %ebx
  801c63:	83 ec 20             	sub    $0x20,%esp
  801c66:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c69:	53                   	push   %ebx
  801c6a:	e8 9a ee ff ff       	call   800b09 <strlen>
  801c6f:	83 c4 10             	add    $0x10,%esp
  801c72:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c77:	7f 67                	jg     801ce0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c79:	83 ec 0c             	sub    $0xc,%esp
  801c7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c7f:	50                   	push   %eax
  801c80:	e8 71 f8 ff ff       	call   8014f6 <fd_alloc>
  801c85:	83 c4 10             	add    $0x10,%esp
		return r;
  801c88:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c8a:	85 c0                	test   %eax,%eax
  801c8c:	78 57                	js     801ce5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c8e:	83 ec 08             	sub    $0x8,%esp
  801c91:	53                   	push   %ebx
  801c92:	68 00 60 80 00       	push   $0x806000
  801c97:	e8 a6 ee ff ff       	call   800b42 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c9f:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ca4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ca7:	b8 01 00 00 00       	mov    $0x1,%eax
  801cac:	e8 cd fd ff ff       	call   801a7e <fsipc>
  801cb1:	89 c3                	mov    %eax,%ebx
  801cb3:	83 c4 10             	add    $0x10,%esp
  801cb6:	85 c0                	test   %eax,%eax
  801cb8:	79 14                	jns    801cce <open+0x6f>
		fd_close(fd, 0);
  801cba:	83 ec 08             	sub    $0x8,%esp
  801cbd:	6a 00                	push   $0x0
  801cbf:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc2:	e8 27 f9 ff ff       	call   8015ee <fd_close>
		return r;
  801cc7:	83 c4 10             	add    $0x10,%esp
  801cca:	89 da                	mov    %ebx,%edx
  801ccc:	eb 17                	jmp    801ce5 <open+0x86>
	}

	return fd2num(fd);
  801cce:	83 ec 0c             	sub    $0xc,%esp
  801cd1:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd4:	e8 f6 f7 ff ff       	call   8014cf <fd2num>
  801cd9:	89 c2                	mov    %eax,%edx
  801cdb:	83 c4 10             	add    $0x10,%esp
  801cde:	eb 05                	jmp    801ce5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ce0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ce5:	89 d0                	mov    %edx,%eax
  801ce7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cea:	c9                   	leave  
  801ceb:	c3                   	ret    

00801cec <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cf2:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf7:	b8 08 00 00 00       	mov    $0x8,%eax
  801cfc:	e8 7d fd ff ff       	call   801a7e <fsipc>
}
  801d01:	c9                   	leave  
  801d02:	c3                   	ret    

00801d03 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801d03:	55                   	push   %ebp
  801d04:	89 e5                	mov    %esp,%ebp
  801d06:	57                   	push   %edi
  801d07:	56                   	push   %esi
  801d08:	53                   	push   %ebx
  801d09:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801d0f:	6a 00                	push   $0x0
  801d11:	ff 75 08             	pushl  0x8(%ebp)
  801d14:	e8 46 ff ff ff       	call   801c5f <open>
  801d19:	89 c7                	mov    %eax,%edi
  801d1b:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801d21:	83 c4 10             	add    $0x10,%esp
  801d24:	85 c0                	test   %eax,%eax
  801d26:	0f 88 a6 04 00 00    	js     8021d2 <spawn+0x4cf>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801d2c:	83 ec 04             	sub    $0x4,%esp
  801d2f:	68 00 02 00 00       	push   $0x200
  801d34:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801d3a:	50                   	push   %eax
  801d3b:	57                   	push   %edi
  801d3c:	e8 fb fa ff ff       	call   80183c <readn>
  801d41:	83 c4 10             	add    $0x10,%esp
  801d44:	3d 00 02 00 00       	cmp    $0x200,%eax
  801d49:	75 0c                	jne    801d57 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801d4b:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801d52:	45 4c 46 
  801d55:	74 33                	je     801d8a <spawn+0x87>
		close(fd);
  801d57:	83 ec 0c             	sub    $0xc,%esp
  801d5a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d60:	e8 0a f9 ff ff       	call   80166f <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801d65:	83 c4 0c             	add    $0xc,%esp
  801d68:	68 7f 45 4c 46       	push   $0x464c457f
  801d6d:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801d73:	68 0b 35 80 00       	push   $0x80350b
  801d78:	e8 40 e8 ff ff       	call   8005bd <cprintf>
		return -E_NOT_EXEC;
  801d7d:	83 c4 10             	add    $0x10,%esp
  801d80:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801d85:	e9 a8 04 00 00       	jmp    802232 <spawn+0x52f>
  801d8a:	b8 07 00 00 00       	mov    $0x7,%eax
  801d8f:	cd 30                	int    $0x30
  801d91:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801d97:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801d9d:	85 c0                	test   %eax,%eax
  801d9f:	0f 88 35 04 00 00    	js     8021da <spawn+0x4d7>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801da5:	89 c6                	mov    %eax,%esi
  801da7:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801dad:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801db0:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801db6:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801dbc:	b9 11 00 00 00       	mov    $0x11,%ecx
  801dc1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801dc3:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801dc9:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801dcf:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801dd4:	be 00 00 00 00       	mov    $0x0,%esi
  801dd9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ddc:	eb 13                	jmp    801df1 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801dde:	83 ec 0c             	sub    $0xc,%esp
  801de1:	50                   	push   %eax
  801de2:	e8 22 ed ff ff       	call   800b09 <strlen>
  801de7:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801deb:	83 c3 01             	add    $0x1,%ebx
  801dee:	83 c4 10             	add    $0x10,%esp
  801df1:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801df8:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801dfb:	85 c0                	test   %eax,%eax
  801dfd:	75 df                	jne    801dde <spawn+0xdb>
  801dff:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801e05:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801e0b:	bf 00 10 40 00       	mov    $0x401000,%edi
  801e10:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801e12:	89 fa                	mov    %edi,%edx
  801e14:	83 e2 fc             	and    $0xfffffffc,%edx
  801e17:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801e1e:	29 c2                	sub    %eax,%edx
  801e20:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801e26:	8d 42 f8             	lea    -0x8(%edx),%eax
  801e29:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801e2e:	0f 86 b6 03 00 00    	jbe    8021ea <spawn+0x4e7>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e34:	83 ec 04             	sub    $0x4,%esp
  801e37:	6a 07                	push   $0x7
  801e39:	68 00 00 40 00       	push   $0x400000
  801e3e:	6a 00                	push   $0x0
  801e40:	e8 00 f1 ff ff       	call   800f45 <sys_page_alloc>
  801e45:	83 c4 10             	add    $0x10,%esp
  801e48:	85 c0                	test   %eax,%eax
  801e4a:	0f 88 a1 03 00 00    	js     8021f1 <spawn+0x4ee>
  801e50:	be 00 00 00 00       	mov    $0x0,%esi
  801e55:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801e5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e5e:	eb 30                	jmp    801e90 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801e60:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801e66:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801e6c:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801e6f:	83 ec 08             	sub    $0x8,%esp
  801e72:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801e75:	57                   	push   %edi
  801e76:	e8 c7 ec ff ff       	call   800b42 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801e7b:	83 c4 04             	add    $0x4,%esp
  801e7e:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801e81:	e8 83 ec ff ff       	call   800b09 <strlen>
  801e86:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801e8a:	83 c6 01             	add    $0x1,%esi
  801e8d:	83 c4 10             	add    $0x10,%esp
  801e90:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801e96:	7f c8                	jg     801e60 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801e98:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801e9e:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801ea4:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801eab:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801eb1:	74 19                	je     801ecc <spawn+0x1c9>
  801eb3:	68 68 35 80 00       	push   $0x803568
  801eb8:	68 d8 34 80 00       	push   $0x8034d8
  801ebd:	68 f1 00 00 00       	push   $0xf1
  801ec2:	68 25 35 80 00       	push   $0x803525
  801ec7:	e8 18 e6 ff ff       	call   8004e4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801ecc:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801ed2:	89 f8                	mov    %edi,%eax
  801ed4:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801ed9:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801edc:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ee2:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801ee5:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801eeb:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801ef1:	83 ec 0c             	sub    $0xc,%esp
  801ef4:	6a 07                	push   $0x7
  801ef6:	68 00 d0 bf ee       	push   $0xeebfd000
  801efb:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801f01:	68 00 00 40 00       	push   $0x400000
  801f06:	6a 00                	push   $0x0
  801f08:	e8 7b f0 ff ff       	call   800f88 <sys_page_map>
  801f0d:	89 c3                	mov    %eax,%ebx
  801f0f:	83 c4 20             	add    $0x20,%esp
  801f12:	85 c0                	test   %eax,%eax
  801f14:	0f 88 06 03 00 00    	js     802220 <spawn+0x51d>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801f1a:	83 ec 08             	sub    $0x8,%esp
  801f1d:	68 00 00 40 00       	push   $0x400000
  801f22:	6a 00                	push   $0x0
  801f24:	e8 a1 f0 ff ff       	call   800fca <sys_page_unmap>
  801f29:	89 c3                	mov    %eax,%ebx
  801f2b:	83 c4 10             	add    $0x10,%esp
  801f2e:	85 c0                	test   %eax,%eax
  801f30:	0f 88 ea 02 00 00    	js     802220 <spawn+0x51d>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801f36:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801f3c:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801f43:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f49:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801f50:	00 00 00 
  801f53:	e9 88 01 00 00       	jmp    8020e0 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801f58:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801f5e:	83 38 01             	cmpl   $0x1,(%eax)
  801f61:	0f 85 6b 01 00 00    	jne    8020d2 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801f67:	89 c7                	mov    %eax,%edi
  801f69:	8b 40 18             	mov    0x18(%eax),%eax
  801f6c:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801f72:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801f75:	83 f8 01             	cmp    $0x1,%eax
  801f78:	19 c0                	sbb    %eax,%eax
  801f7a:	83 e0 fe             	and    $0xfffffffe,%eax
  801f7d:	83 c0 07             	add    $0x7,%eax
  801f80:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801f86:	89 f8                	mov    %edi,%eax
  801f88:	8b 7f 04             	mov    0x4(%edi),%edi
  801f8b:	89 f9                	mov    %edi,%ecx
  801f8d:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801f93:	8b 78 10             	mov    0x10(%eax),%edi
  801f96:	8b 50 14             	mov    0x14(%eax),%edx
  801f99:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801f9f:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801fa2:	89 f0                	mov    %esi,%eax
  801fa4:	25 ff 0f 00 00       	and    $0xfff,%eax
  801fa9:	74 14                	je     801fbf <spawn+0x2bc>
		va -= i;
  801fab:	29 c6                	sub    %eax,%esi
		memsz += i;
  801fad:	01 c2                	add    %eax,%edx
  801faf:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801fb5:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801fb7:	29 c1                	sub    %eax,%ecx
  801fb9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801fbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fc4:	e9 f7 00 00 00       	jmp    8020c0 <spawn+0x3bd>
		if (i >= filesz) {
  801fc9:	39 df                	cmp    %ebx,%edi
  801fcb:	77 27                	ja     801ff4 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801fcd:	83 ec 04             	sub    $0x4,%esp
  801fd0:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801fd6:	56                   	push   %esi
  801fd7:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801fdd:	e8 63 ef ff ff       	call   800f45 <sys_page_alloc>
  801fe2:	83 c4 10             	add    $0x10,%esp
  801fe5:	85 c0                	test   %eax,%eax
  801fe7:	0f 89 c7 00 00 00    	jns    8020b4 <spawn+0x3b1>
  801fed:	89 c3                	mov    %eax,%ebx
  801fef:	e9 0b 02 00 00       	jmp    8021ff <spawn+0x4fc>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ff4:	83 ec 04             	sub    $0x4,%esp
  801ff7:	6a 07                	push   $0x7
  801ff9:	68 00 00 40 00       	push   $0x400000
  801ffe:	6a 00                	push   $0x0
  802000:	e8 40 ef ff ff       	call   800f45 <sys_page_alloc>
  802005:	83 c4 10             	add    $0x10,%esp
  802008:	85 c0                	test   %eax,%eax
  80200a:	0f 88 e5 01 00 00    	js     8021f5 <spawn+0x4f2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802010:	83 ec 08             	sub    $0x8,%esp
  802013:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802019:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  80201f:	50                   	push   %eax
  802020:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802026:	e8 e6 f8 ff ff       	call   801911 <seek>
  80202b:	83 c4 10             	add    $0x10,%esp
  80202e:	85 c0                	test   %eax,%eax
  802030:	0f 88 c3 01 00 00    	js     8021f9 <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802036:	83 ec 04             	sub    $0x4,%esp
  802039:	89 f8                	mov    %edi,%eax
  80203b:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  802041:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802046:	b9 00 10 00 00       	mov    $0x1000,%ecx
  80204b:	0f 47 c1             	cmova  %ecx,%eax
  80204e:	50                   	push   %eax
  80204f:	68 00 00 40 00       	push   $0x400000
  802054:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80205a:	e8 dd f7 ff ff       	call   80183c <readn>
  80205f:	83 c4 10             	add    $0x10,%esp
  802062:	85 c0                	test   %eax,%eax
  802064:	0f 88 93 01 00 00    	js     8021fd <spawn+0x4fa>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80206a:	83 ec 0c             	sub    $0xc,%esp
  80206d:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802073:	56                   	push   %esi
  802074:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80207a:	68 00 00 40 00       	push   $0x400000
  80207f:	6a 00                	push   $0x0
  802081:	e8 02 ef ff ff       	call   800f88 <sys_page_map>
  802086:	83 c4 20             	add    $0x20,%esp
  802089:	85 c0                	test   %eax,%eax
  80208b:	79 15                	jns    8020a2 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  80208d:	50                   	push   %eax
  80208e:	68 31 35 80 00       	push   $0x803531
  802093:	68 24 01 00 00       	push   $0x124
  802098:	68 25 35 80 00       	push   $0x803525
  80209d:	e8 42 e4 ff ff       	call   8004e4 <_panic>
			sys_page_unmap(0, UTEMP);
  8020a2:	83 ec 08             	sub    $0x8,%esp
  8020a5:	68 00 00 40 00       	push   $0x400000
  8020aa:	6a 00                	push   $0x0
  8020ac:	e8 19 ef ff ff       	call   800fca <sys_page_unmap>
  8020b1:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8020b4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8020ba:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8020c0:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8020c6:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  8020cc:	0f 87 f7 fe ff ff    	ja     801fc9 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8020d2:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8020d9:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8020e0:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8020e7:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8020ed:	0f 8c 65 fe ff ff    	jl     801f58 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8020f3:	83 ec 0c             	sub    $0xc,%esp
  8020f6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8020fc:	e8 6e f5 ff ff       	call   80166f <close>
  802101:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	// Loop through all the pte's of parent's pgdir in user space
        uint32_t pn;
        for (pn = UTEXT/PGSIZE; pn < UTOP/PGSIZE; pn++) {
  802104:	bb 00 08 00 00       	mov    $0x800,%ebx
  802109:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		
		if (uvpd[pn/NPTENTRIES] & PTE_P) {
  80210f:	89 d8                	mov    %ebx,%eax
  802111:	c1 e8 0a             	shr    $0xa,%eax
  802114:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80211b:	a8 01                	test   $0x1,%al
  80211d:	74 4b                	je     80216a <spawn+0x467>
		
			pte_t pte = uvpt[pn];
  80211f:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax

			
			if ((pte & PTE_P) && (pte & PTE_SHARE)) {
  802126:	89 c2                	mov    %eax,%edx
  802128:	81 e2 01 04 00 00    	and    $0x401,%edx
  80212e:	81 fa 01 04 00 00    	cmp    $0x401,%edx
  802134:	75 34                	jne    80216a <spawn+0x467>
  802136:	89 da                	mov    %ebx,%edx
  802138:	c1 e2 0c             	shl    $0xc,%edx
				void *va = (void *) (pn * PGSIZE);
				uint32_t perm = pte & PTE_SYSCALL;
				int r;
				if ((r = sys_page_map(0, va, child, va, perm)) < 0)
  80213b:	83 ec 0c             	sub    $0xc,%esp
  80213e:	25 07 0e 00 00       	and    $0xe07,%eax
  802143:	50                   	push   %eax
  802144:	52                   	push   %edx
  802145:	56                   	push   %esi
  802146:	52                   	push   %edx
  802147:	6a 00                	push   $0x0
  802149:	e8 3a ee ff ff       	call   800f88 <sys_page_map>
  80214e:	83 c4 20             	add    $0x20,%esp
  802151:	85 c0                	test   %eax,%eax
  802153:	79 15                	jns    80216a <spawn+0x467>
					panic("sys_page_map: %e", r);
  802155:	50                   	push   %eax
  802156:	68 db 33 80 00       	push   $0x8033db
  80215b:	68 3e 01 00 00       	push   $0x13e
  802160:	68 25 35 80 00       	push   $0x803525
  802165:	e8 7a e3 ff ff       	call   8004e4 <_panic>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	// Loop through all the pte's of parent's pgdir in user space
        uint32_t pn;
        for (pn = UTEXT/PGSIZE; pn < UTOP/PGSIZE; pn++) {
  80216a:	83 c3 01             	add    $0x1,%ebx
  80216d:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  802173:	75 9a                	jne    80210f <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802175:	83 ec 08             	sub    $0x8,%esp
  802178:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80217e:	50                   	push   %eax
  80217f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802185:	e8 c4 ee ff ff       	call   80104e <sys_env_set_trapframe>
  80218a:	83 c4 10             	add    $0x10,%esp
  80218d:	85 c0                	test   %eax,%eax
  80218f:	79 15                	jns    8021a6 <spawn+0x4a3>
		panic("sys_env_set_trapframe: %e", r);
  802191:	50                   	push   %eax
  802192:	68 4e 35 80 00       	push   $0x80354e
  802197:	68 85 00 00 00       	push   $0x85
  80219c:	68 25 35 80 00       	push   $0x803525
  8021a1:	e8 3e e3 ff ff       	call   8004e4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8021a6:	83 ec 08             	sub    $0x8,%esp
  8021a9:	6a 02                	push   $0x2
  8021ab:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8021b1:	e8 56 ee ff ff       	call   80100c <sys_env_set_status>
  8021b6:	83 c4 10             	add    $0x10,%esp
  8021b9:	85 c0                	test   %eax,%eax
  8021bb:	79 25                	jns    8021e2 <spawn+0x4df>
		panic("sys_env_set_status: %e", r);
  8021bd:	50                   	push   %eax
  8021be:	68 0f 34 80 00       	push   $0x80340f
  8021c3:	68 88 00 00 00       	push   $0x88
  8021c8:	68 25 35 80 00       	push   $0x803525
  8021cd:	e8 12 e3 ff ff       	call   8004e4 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8021d2:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  8021d8:	eb 58                	jmp    802232 <spawn+0x52f>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  8021da:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8021e0:	eb 50                	jmp    802232 <spawn+0x52f>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  8021e2:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8021e8:	eb 48                	jmp    802232 <spawn+0x52f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8021ea:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  8021ef:	eb 41                	jmp    802232 <spawn+0x52f>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  8021f1:	89 c3                	mov    %eax,%ebx
  8021f3:	eb 3d                	jmp    802232 <spawn+0x52f>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8021f5:	89 c3                	mov    %eax,%ebx
  8021f7:	eb 06                	jmp    8021ff <spawn+0x4fc>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8021f9:	89 c3                	mov    %eax,%ebx
  8021fb:	eb 02                	jmp    8021ff <spawn+0x4fc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8021fd:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  8021ff:	83 ec 0c             	sub    $0xc,%esp
  802202:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802208:	e8 b9 ec ff ff       	call   800ec6 <sys_env_destroy>
	close(fd);
  80220d:	83 c4 04             	add    $0x4,%esp
  802210:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802216:	e8 54 f4 ff ff       	call   80166f <close>
	return r;
  80221b:	83 c4 10             	add    $0x10,%esp
  80221e:	eb 12                	jmp    802232 <spawn+0x52f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802220:	83 ec 08             	sub    $0x8,%esp
  802223:	68 00 00 40 00       	push   $0x400000
  802228:	6a 00                	push   $0x0
  80222a:	e8 9b ed ff ff       	call   800fca <sys_page_unmap>
  80222f:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802232:	89 d8                	mov    %ebx,%eax
  802234:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802237:	5b                   	pop    %ebx
  802238:	5e                   	pop    %esi
  802239:	5f                   	pop    %edi
  80223a:	5d                   	pop    %ebp
  80223b:	c3                   	ret    

0080223c <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  80223c:	55                   	push   %ebp
  80223d:	89 e5                	mov    %esp,%ebp
  80223f:	56                   	push   %esi
  802240:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802241:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802244:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802249:	eb 03                	jmp    80224e <spawnl+0x12>
		argc++;
  80224b:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80224e:	83 c2 04             	add    $0x4,%edx
  802251:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802255:	75 f4                	jne    80224b <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802257:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  80225e:	83 e2 f0             	and    $0xfffffff0,%edx
  802261:	29 d4                	sub    %edx,%esp
  802263:	8d 54 24 03          	lea    0x3(%esp),%edx
  802267:	c1 ea 02             	shr    $0x2,%edx
  80226a:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802271:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802273:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802276:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  80227d:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802284:	00 
  802285:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802287:	b8 00 00 00 00       	mov    $0x0,%eax
  80228c:	eb 0a                	jmp    802298 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  80228e:	83 c0 01             	add    $0x1,%eax
  802291:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802295:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802298:	39 d0                	cmp    %edx,%eax
  80229a:	75 f2                	jne    80228e <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  80229c:	83 ec 08             	sub    $0x8,%esp
  80229f:	56                   	push   %esi
  8022a0:	ff 75 08             	pushl  0x8(%ebp)
  8022a3:	e8 5b fa ff ff       	call   801d03 <spawn>
}
  8022a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022ab:	5b                   	pop    %ebx
  8022ac:	5e                   	pop    %esi
  8022ad:	5d                   	pop    %ebp
  8022ae:	c3                   	ret    

008022af <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8022af:	55                   	push   %ebp
  8022b0:	89 e5                	mov    %esp,%ebp
  8022b2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8022b5:	68 90 35 80 00       	push   $0x803590
  8022ba:	ff 75 0c             	pushl  0xc(%ebp)
  8022bd:	e8 80 e8 ff ff       	call   800b42 <strcpy>
	return 0;
}
  8022c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8022c7:	c9                   	leave  
  8022c8:	c3                   	ret    

008022c9 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8022c9:	55                   	push   %ebp
  8022ca:	89 e5                	mov    %esp,%ebp
  8022cc:	53                   	push   %ebx
  8022cd:	83 ec 10             	sub    $0x10,%esp
  8022d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8022d3:	53                   	push   %ebx
  8022d4:	e8 54 09 00 00       	call   802c2d <pageref>
  8022d9:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8022dc:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8022e1:	83 f8 01             	cmp    $0x1,%eax
  8022e4:	75 10                	jne    8022f6 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8022e6:	83 ec 0c             	sub    $0xc,%esp
  8022e9:	ff 73 0c             	pushl  0xc(%ebx)
  8022ec:	e8 c0 02 00 00       	call   8025b1 <nsipc_close>
  8022f1:	89 c2                	mov    %eax,%edx
  8022f3:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8022f6:	89 d0                	mov    %edx,%eax
  8022f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022fb:	c9                   	leave  
  8022fc:	c3                   	ret    

008022fd <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8022fd:	55                   	push   %ebp
  8022fe:	89 e5                	mov    %esp,%ebp
  802300:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802303:	6a 00                	push   $0x0
  802305:	ff 75 10             	pushl  0x10(%ebp)
  802308:	ff 75 0c             	pushl  0xc(%ebp)
  80230b:	8b 45 08             	mov    0x8(%ebp),%eax
  80230e:	ff 70 0c             	pushl  0xc(%eax)
  802311:	e8 78 03 00 00       	call   80268e <nsipc_send>
}
  802316:	c9                   	leave  
  802317:	c3                   	ret    

00802318 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802318:	55                   	push   %ebp
  802319:	89 e5                	mov    %esp,%ebp
  80231b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80231e:	6a 00                	push   $0x0
  802320:	ff 75 10             	pushl  0x10(%ebp)
  802323:	ff 75 0c             	pushl  0xc(%ebp)
  802326:	8b 45 08             	mov    0x8(%ebp),%eax
  802329:	ff 70 0c             	pushl  0xc(%eax)
  80232c:	e8 f1 02 00 00       	call   802622 <nsipc_recv>
}
  802331:	c9                   	leave  
  802332:	c3                   	ret    

00802333 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802333:	55                   	push   %ebp
  802334:	89 e5                	mov    %esp,%ebp
  802336:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802339:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80233c:	52                   	push   %edx
  80233d:	50                   	push   %eax
  80233e:	e8 02 f2 ff ff       	call   801545 <fd_lookup>
  802343:	83 c4 10             	add    $0x10,%esp
  802346:	85 c0                	test   %eax,%eax
  802348:	78 17                	js     802361 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80234a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80234d:	8b 0d 3c 40 80 00    	mov    0x80403c,%ecx
  802353:	39 08                	cmp    %ecx,(%eax)
  802355:	75 05                	jne    80235c <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802357:	8b 40 0c             	mov    0xc(%eax),%eax
  80235a:	eb 05                	jmp    802361 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80235c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802361:	c9                   	leave  
  802362:	c3                   	ret    

00802363 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  802363:	55                   	push   %ebp
  802364:	89 e5                	mov    %esp,%ebp
  802366:	56                   	push   %esi
  802367:	53                   	push   %ebx
  802368:	83 ec 1c             	sub    $0x1c,%esp
  80236b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80236d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802370:	50                   	push   %eax
  802371:	e8 80 f1 ff ff       	call   8014f6 <fd_alloc>
  802376:	89 c3                	mov    %eax,%ebx
  802378:	83 c4 10             	add    $0x10,%esp
  80237b:	85 c0                	test   %eax,%eax
  80237d:	78 1b                	js     80239a <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80237f:	83 ec 04             	sub    $0x4,%esp
  802382:	68 07 04 00 00       	push   $0x407
  802387:	ff 75 f4             	pushl  -0xc(%ebp)
  80238a:	6a 00                	push   $0x0
  80238c:	e8 b4 eb ff ff       	call   800f45 <sys_page_alloc>
  802391:	89 c3                	mov    %eax,%ebx
  802393:	83 c4 10             	add    $0x10,%esp
  802396:	85 c0                	test   %eax,%eax
  802398:	79 10                	jns    8023aa <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80239a:	83 ec 0c             	sub    $0xc,%esp
  80239d:	56                   	push   %esi
  80239e:	e8 0e 02 00 00       	call   8025b1 <nsipc_close>
		return r;
  8023a3:	83 c4 10             	add    $0x10,%esp
  8023a6:	89 d8                	mov    %ebx,%eax
  8023a8:	eb 24                	jmp    8023ce <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8023aa:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8023b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023b3:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8023b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023b8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8023bf:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8023c2:	83 ec 0c             	sub    $0xc,%esp
  8023c5:	50                   	push   %eax
  8023c6:	e8 04 f1 ff ff       	call   8014cf <fd2num>
  8023cb:	83 c4 10             	add    $0x10,%esp
}
  8023ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023d1:	5b                   	pop    %ebx
  8023d2:	5e                   	pop    %esi
  8023d3:	5d                   	pop    %ebp
  8023d4:	c3                   	ret    

008023d5 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8023d5:	55                   	push   %ebp
  8023d6:	89 e5                	mov    %esp,%ebp
  8023d8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023db:	8b 45 08             	mov    0x8(%ebp),%eax
  8023de:	e8 50 ff ff ff       	call   802333 <fd2sockid>
		return r;
  8023e3:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023e5:	85 c0                	test   %eax,%eax
  8023e7:	78 1f                	js     802408 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8023e9:	83 ec 04             	sub    $0x4,%esp
  8023ec:	ff 75 10             	pushl  0x10(%ebp)
  8023ef:	ff 75 0c             	pushl  0xc(%ebp)
  8023f2:	50                   	push   %eax
  8023f3:	e8 12 01 00 00       	call   80250a <nsipc_accept>
  8023f8:	83 c4 10             	add    $0x10,%esp
		return r;
  8023fb:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8023fd:	85 c0                	test   %eax,%eax
  8023ff:	78 07                	js     802408 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  802401:	e8 5d ff ff ff       	call   802363 <alloc_sockfd>
  802406:	89 c1                	mov    %eax,%ecx
}
  802408:	89 c8                	mov    %ecx,%eax
  80240a:	c9                   	leave  
  80240b:	c3                   	ret    

0080240c <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80240c:	55                   	push   %ebp
  80240d:	89 e5                	mov    %esp,%ebp
  80240f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802412:	8b 45 08             	mov    0x8(%ebp),%eax
  802415:	e8 19 ff ff ff       	call   802333 <fd2sockid>
  80241a:	85 c0                	test   %eax,%eax
  80241c:	78 12                	js     802430 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80241e:	83 ec 04             	sub    $0x4,%esp
  802421:	ff 75 10             	pushl  0x10(%ebp)
  802424:	ff 75 0c             	pushl  0xc(%ebp)
  802427:	50                   	push   %eax
  802428:	e8 2d 01 00 00       	call   80255a <nsipc_bind>
  80242d:	83 c4 10             	add    $0x10,%esp
}
  802430:	c9                   	leave  
  802431:	c3                   	ret    

00802432 <shutdown>:

int
shutdown(int s, int how)
{
  802432:	55                   	push   %ebp
  802433:	89 e5                	mov    %esp,%ebp
  802435:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802438:	8b 45 08             	mov    0x8(%ebp),%eax
  80243b:	e8 f3 fe ff ff       	call   802333 <fd2sockid>
  802440:	85 c0                	test   %eax,%eax
  802442:	78 0f                	js     802453 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802444:	83 ec 08             	sub    $0x8,%esp
  802447:	ff 75 0c             	pushl  0xc(%ebp)
  80244a:	50                   	push   %eax
  80244b:	e8 3f 01 00 00       	call   80258f <nsipc_shutdown>
  802450:	83 c4 10             	add    $0x10,%esp
}
  802453:	c9                   	leave  
  802454:	c3                   	ret    

00802455 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802455:	55                   	push   %ebp
  802456:	89 e5                	mov    %esp,%ebp
  802458:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80245b:	8b 45 08             	mov    0x8(%ebp),%eax
  80245e:	e8 d0 fe ff ff       	call   802333 <fd2sockid>
  802463:	85 c0                	test   %eax,%eax
  802465:	78 12                	js     802479 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  802467:	83 ec 04             	sub    $0x4,%esp
  80246a:	ff 75 10             	pushl  0x10(%ebp)
  80246d:	ff 75 0c             	pushl  0xc(%ebp)
  802470:	50                   	push   %eax
  802471:	e8 55 01 00 00       	call   8025cb <nsipc_connect>
  802476:	83 c4 10             	add    $0x10,%esp
}
  802479:	c9                   	leave  
  80247a:	c3                   	ret    

0080247b <listen>:

int
listen(int s, int backlog)
{
  80247b:	55                   	push   %ebp
  80247c:	89 e5                	mov    %esp,%ebp
  80247e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802481:	8b 45 08             	mov    0x8(%ebp),%eax
  802484:	e8 aa fe ff ff       	call   802333 <fd2sockid>
  802489:	85 c0                	test   %eax,%eax
  80248b:	78 0f                	js     80249c <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80248d:	83 ec 08             	sub    $0x8,%esp
  802490:	ff 75 0c             	pushl  0xc(%ebp)
  802493:	50                   	push   %eax
  802494:	e8 67 01 00 00       	call   802600 <nsipc_listen>
  802499:	83 c4 10             	add    $0x10,%esp
}
  80249c:	c9                   	leave  
  80249d:	c3                   	ret    

0080249e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80249e:	55                   	push   %ebp
  80249f:	89 e5                	mov    %esp,%ebp
  8024a1:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8024a4:	ff 75 10             	pushl  0x10(%ebp)
  8024a7:	ff 75 0c             	pushl  0xc(%ebp)
  8024aa:	ff 75 08             	pushl  0x8(%ebp)
  8024ad:	e8 3a 02 00 00       	call   8026ec <nsipc_socket>
  8024b2:	83 c4 10             	add    $0x10,%esp
  8024b5:	85 c0                	test   %eax,%eax
  8024b7:	78 05                	js     8024be <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8024b9:	e8 a5 fe ff ff       	call   802363 <alloc_sockfd>
}
  8024be:	c9                   	leave  
  8024bf:	c3                   	ret    

008024c0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8024c0:	55                   	push   %ebp
  8024c1:	89 e5                	mov    %esp,%ebp
  8024c3:	53                   	push   %ebx
  8024c4:	83 ec 04             	sub    $0x4,%esp
  8024c7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8024c9:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  8024d0:	75 12                	jne    8024e4 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8024d2:	83 ec 0c             	sub    $0xc,%esp
  8024d5:	6a 02                	push   $0x2
  8024d7:	e8 18 07 00 00       	call   802bf4 <ipc_find_env>
  8024dc:	a3 04 50 80 00       	mov    %eax,0x805004
  8024e1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8024e4:	6a 07                	push   $0x7
  8024e6:	68 00 70 80 00       	push   $0x807000
  8024eb:	53                   	push   %ebx
  8024ec:	ff 35 04 50 80 00    	pushl  0x805004
  8024f2:	e8 a9 06 00 00       	call   802ba0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8024f7:	83 c4 0c             	add    $0xc,%esp
  8024fa:	6a 00                	push   $0x0
  8024fc:	6a 00                	push   $0x0
  8024fe:	6a 00                	push   $0x0
  802500:	e8 32 06 00 00       	call   802b37 <ipc_recv>
}
  802505:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802508:	c9                   	leave  
  802509:	c3                   	ret    

0080250a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80250a:	55                   	push   %ebp
  80250b:	89 e5                	mov    %esp,%ebp
  80250d:	56                   	push   %esi
  80250e:	53                   	push   %ebx
  80250f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802512:	8b 45 08             	mov    0x8(%ebp),%eax
  802515:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80251a:	8b 06                	mov    (%esi),%eax
  80251c:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802521:	b8 01 00 00 00       	mov    $0x1,%eax
  802526:	e8 95 ff ff ff       	call   8024c0 <nsipc>
  80252b:	89 c3                	mov    %eax,%ebx
  80252d:	85 c0                	test   %eax,%eax
  80252f:	78 20                	js     802551 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802531:	83 ec 04             	sub    $0x4,%esp
  802534:	ff 35 10 70 80 00    	pushl  0x807010
  80253a:	68 00 70 80 00       	push   $0x807000
  80253f:	ff 75 0c             	pushl  0xc(%ebp)
  802542:	e8 8d e7 ff ff       	call   800cd4 <memmove>
		*addrlen = ret->ret_addrlen;
  802547:	a1 10 70 80 00       	mov    0x807010,%eax
  80254c:	89 06                	mov    %eax,(%esi)
  80254e:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802551:	89 d8                	mov    %ebx,%eax
  802553:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802556:	5b                   	pop    %ebx
  802557:	5e                   	pop    %esi
  802558:	5d                   	pop    %ebp
  802559:	c3                   	ret    

0080255a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80255a:	55                   	push   %ebp
  80255b:	89 e5                	mov    %esp,%ebp
  80255d:	53                   	push   %ebx
  80255e:	83 ec 08             	sub    $0x8,%esp
  802561:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802564:	8b 45 08             	mov    0x8(%ebp),%eax
  802567:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80256c:	53                   	push   %ebx
  80256d:	ff 75 0c             	pushl  0xc(%ebp)
  802570:	68 04 70 80 00       	push   $0x807004
  802575:	e8 5a e7 ff ff       	call   800cd4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80257a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802580:	b8 02 00 00 00       	mov    $0x2,%eax
  802585:	e8 36 ff ff ff       	call   8024c0 <nsipc>
}
  80258a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80258d:	c9                   	leave  
  80258e:	c3                   	ret    

0080258f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80258f:	55                   	push   %ebp
  802590:	89 e5                	mov    %esp,%ebp
  802592:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802595:	8b 45 08             	mov    0x8(%ebp),%eax
  802598:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80259d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025a0:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8025a5:	b8 03 00 00 00       	mov    $0x3,%eax
  8025aa:	e8 11 ff ff ff       	call   8024c0 <nsipc>
}
  8025af:	c9                   	leave  
  8025b0:	c3                   	ret    

008025b1 <nsipc_close>:

int
nsipc_close(int s)
{
  8025b1:	55                   	push   %ebp
  8025b2:	89 e5                	mov    %esp,%ebp
  8025b4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8025b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8025ba:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8025bf:	b8 04 00 00 00       	mov    $0x4,%eax
  8025c4:	e8 f7 fe ff ff       	call   8024c0 <nsipc>
}
  8025c9:	c9                   	leave  
  8025ca:	c3                   	ret    

008025cb <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8025cb:	55                   	push   %ebp
  8025cc:	89 e5                	mov    %esp,%ebp
  8025ce:	53                   	push   %ebx
  8025cf:	83 ec 08             	sub    $0x8,%esp
  8025d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8025d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8025d8:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8025dd:	53                   	push   %ebx
  8025de:	ff 75 0c             	pushl  0xc(%ebp)
  8025e1:	68 04 70 80 00       	push   $0x807004
  8025e6:	e8 e9 e6 ff ff       	call   800cd4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8025eb:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8025f1:	b8 05 00 00 00       	mov    $0x5,%eax
  8025f6:	e8 c5 fe ff ff       	call   8024c0 <nsipc>
}
  8025fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8025fe:	c9                   	leave  
  8025ff:	c3                   	ret    

00802600 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802600:	55                   	push   %ebp
  802601:	89 e5                	mov    %esp,%ebp
  802603:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802606:	8b 45 08             	mov    0x8(%ebp),%eax
  802609:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80260e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802611:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802616:	b8 06 00 00 00       	mov    $0x6,%eax
  80261b:	e8 a0 fe ff ff       	call   8024c0 <nsipc>
}
  802620:	c9                   	leave  
  802621:	c3                   	ret    

00802622 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802622:	55                   	push   %ebp
  802623:	89 e5                	mov    %esp,%ebp
  802625:	56                   	push   %esi
  802626:	53                   	push   %ebx
  802627:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80262a:	8b 45 08             	mov    0x8(%ebp),%eax
  80262d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802632:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802638:	8b 45 14             	mov    0x14(%ebp),%eax
  80263b:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802640:	b8 07 00 00 00       	mov    $0x7,%eax
  802645:	e8 76 fe ff ff       	call   8024c0 <nsipc>
  80264a:	89 c3                	mov    %eax,%ebx
  80264c:	85 c0                	test   %eax,%eax
  80264e:	78 35                	js     802685 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802650:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802655:	7f 04                	jg     80265b <nsipc_recv+0x39>
  802657:	39 c6                	cmp    %eax,%esi
  802659:	7d 16                	jge    802671 <nsipc_recv+0x4f>
  80265b:	68 9c 35 80 00       	push   $0x80359c
  802660:	68 d8 34 80 00       	push   $0x8034d8
  802665:	6a 62                	push   $0x62
  802667:	68 b1 35 80 00       	push   $0x8035b1
  80266c:	e8 73 de ff ff       	call   8004e4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802671:	83 ec 04             	sub    $0x4,%esp
  802674:	50                   	push   %eax
  802675:	68 00 70 80 00       	push   $0x807000
  80267a:	ff 75 0c             	pushl  0xc(%ebp)
  80267d:	e8 52 e6 ff ff       	call   800cd4 <memmove>
  802682:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802685:	89 d8                	mov    %ebx,%eax
  802687:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80268a:	5b                   	pop    %ebx
  80268b:	5e                   	pop    %esi
  80268c:	5d                   	pop    %ebp
  80268d:	c3                   	ret    

0080268e <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80268e:	55                   	push   %ebp
  80268f:	89 e5                	mov    %esp,%ebp
  802691:	53                   	push   %ebx
  802692:	83 ec 04             	sub    $0x4,%esp
  802695:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802698:	8b 45 08             	mov    0x8(%ebp),%eax
  80269b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8026a0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8026a6:	7e 16                	jle    8026be <nsipc_send+0x30>
  8026a8:	68 bd 35 80 00       	push   $0x8035bd
  8026ad:	68 d8 34 80 00       	push   $0x8034d8
  8026b2:	6a 6d                	push   $0x6d
  8026b4:	68 b1 35 80 00       	push   $0x8035b1
  8026b9:	e8 26 de ff ff       	call   8004e4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8026be:	83 ec 04             	sub    $0x4,%esp
  8026c1:	53                   	push   %ebx
  8026c2:	ff 75 0c             	pushl  0xc(%ebp)
  8026c5:	68 0c 70 80 00       	push   $0x80700c
  8026ca:	e8 05 e6 ff ff       	call   800cd4 <memmove>
	nsipcbuf.send.req_size = size;
  8026cf:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8026d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8026d8:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8026dd:	b8 08 00 00 00       	mov    $0x8,%eax
  8026e2:	e8 d9 fd ff ff       	call   8024c0 <nsipc>
}
  8026e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8026ea:	c9                   	leave  
  8026eb:	c3                   	ret    

008026ec <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8026ec:	55                   	push   %ebp
  8026ed:	89 e5                	mov    %esp,%ebp
  8026ef:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8026f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8026f5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8026fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026fd:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802702:	8b 45 10             	mov    0x10(%ebp),%eax
  802705:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80270a:	b8 09 00 00 00       	mov    $0x9,%eax
  80270f:	e8 ac fd ff ff       	call   8024c0 <nsipc>
}
  802714:	c9                   	leave  
  802715:	c3                   	ret    

00802716 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802716:	55                   	push   %ebp
  802717:	89 e5                	mov    %esp,%ebp
  802719:	56                   	push   %esi
  80271a:	53                   	push   %ebx
  80271b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80271e:	83 ec 0c             	sub    $0xc,%esp
  802721:	ff 75 08             	pushl  0x8(%ebp)
  802724:	e8 b6 ed ff ff       	call   8014df <fd2data>
  802729:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80272b:	83 c4 08             	add    $0x8,%esp
  80272e:	68 c9 35 80 00       	push   $0x8035c9
  802733:	53                   	push   %ebx
  802734:	e8 09 e4 ff ff       	call   800b42 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802739:	8b 46 04             	mov    0x4(%esi),%eax
  80273c:	2b 06                	sub    (%esi),%eax
  80273e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802744:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80274b:	00 00 00 
	stat->st_dev = &devpipe;
  80274e:	c7 83 88 00 00 00 58 	movl   $0x804058,0x88(%ebx)
  802755:	40 80 00 
	return 0;
}
  802758:	b8 00 00 00 00       	mov    $0x0,%eax
  80275d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802760:	5b                   	pop    %ebx
  802761:	5e                   	pop    %esi
  802762:	5d                   	pop    %ebp
  802763:	c3                   	ret    

00802764 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802764:	55                   	push   %ebp
  802765:	89 e5                	mov    %esp,%ebp
  802767:	53                   	push   %ebx
  802768:	83 ec 0c             	sub    $0xc,%esp
  80276b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80276e:	53                   	push   %ebx
  80276f:	6a 00                	push   $0x0
  802771:	e8 54 e8 ff ff       	call   800fca <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802776:	89 1c 24             	mov    %ebx,(%esp)
  802779:	e8 61 ed ff ff       	call   8014df <fd2data>
  80277e:	83 c4 08             	add    $0x8,%esp
  802781:	50                   	push   %eax
  802782:	6a 00                	push   $0x0
  802784:	e8 41 e8 ff ff       	call   800fca <sys_page_unmap>
}
  802789:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80278c:	c9                   	leave  
  80278d:	c3                   	ret    

0080278e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80278e:	55                   	push   %ebp
  80278f:	89 e5                	mov    %esp,%ebp
  802791:	57                   	push   %edi
  802792:	56                   	push   %esi
  802793:	53                   	push   %ebx
  802794:	83 ec 1c             	sub    $0x1c,%esp
  802797:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80279a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80279c:	a1 08 50 80 00       	mov    0x805008,%eax
  8027a1:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8027a4:	83 ec 0c             	sub    $0xc,%esp
  8027a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8027aa:	e8 7e 04 00 00       	call   802c2d <pageref>
  8027af:	89 c3                	mov    %eax,%ebx
  8027b1:	89 3c 24             	mov    %edi,(%esp)
  8027b4:	e8 74 04 00 00       	call   802c2d <pageref>
  8027b9:	83 c4 10             	add    $0x10,%esp
  8027bc:	39 c3                	cmp    %eax,%ebx
  8027be:	0f 94 c1             	sete   %cl
  8027c1:	0f b6 c9             	movzbl %cl,%ecx
  8027c4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8027c7:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8027cd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8027d0:	39 ce                	cmp    %ecx,%esi
  8027d2:	74 1b                	je     8027ef <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8027d4:	39 c3                	cmp    %eax,%ebx
  8027d6:	75 c4                	jne    80279c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8027d8:	8b 42 58             	mov    0x58(%edx),%eax
  8027db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8027de:	50                   	push   %eax
  8027df:	56                   	push   %esi
  8027e0:	68 d0 35 80 00       	push   $0x8035d0
  8027e5:	e8 d3 dd ff ff       	call   8005bd <cprintf>
  8027ea:	83 c4 10             	add    $0x10,%esp
  8027ed:	eb ad                	jmp    80279c <_pipeisclosed+0xe>
	}
}
  8027ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8027f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027f5:	5b                   	pop    %ebx
  8027f6:	5e                   	pop    %esi
  8027f7:	5f                   	pop    %edi
  8027f8:	5d                   	pop    %ebp
  8027f9:	c3                   	ret    

008027fa <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8027fa:	55                   	push   %ebp
  8027fb:	89 e5                	mov    %esp,%ebp
  8027fd:	57                   	push   %edi
  8027fe:	56                   	push   %esi
  8027ff:	53                   	push   %ebx
  802800:	83 ec 28             	sub    $0x28,%esp
  802803:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802806:	56                   	push   %esi
  802807:	e8 d3 ec ff ff       	call   8014df <fd2data>
  80280c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80280e:	83 c4 10             	add    $0x10,%esp
  802811:	bf 00 00 00 00       	mov    $0x0,%edi
  802816:	eb 4b                	jmp    802863 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802818:	89 da                	mov    %ebx,%edx
  80281a:	89 f0                	mov    %esi,%eax
  80281c:	e8 6d ff ff ff       	call   80278e <_pipeisclosed>
  802821:	85 c0                	test   %eax,%eax
  802823:	75 48                	jne    80286d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802825:	e8 fc e6 ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80282a:	8b 43 04             	mov    0x4(%ebx),%eax
  80282d:	8b 0b                	mov    (%ebx),%ecx
  80282f:	8d 51 20             	lea    0x20(%ecx),%edx
  802832:	39 d0                	cmp    %edx,%eax
  802834:	73 e2                	jae    802818 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802836:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802839:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80283d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802840:	89 c2                	mov    %eax,%edx
  802842:	c1 fa 1f             	sar    $0x1f,%edx
  802845:	89 d1                	mov    %edx,%ecx
  802847:	c1 e9 1b             	shr    $0x1b,%ecx
  80284a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80284d:	83 e2 1f             	and    $0x1f,%edx
  802850:	29 ca                	sub    %ecx,%edx
  802852:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802856:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80285a:	83 c0 01             	add    $0x1,%eax
  80285d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802860:	83 c7 01             	add    $0x1,%edi
  802863:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802866:	75 c2                	jne    80282a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802868:	8b 45 10             	mov    0x10(%ebp),%eax
  80286b:	eb 05                	jmp    802872 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80286d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802872:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802875:	5b                   	pop    %ebx
  802876:	5e                   	pop    %esi
  802877:	5f                   	pop    %edi
  802878:	5d                   	pop    %ebp
  802879:	c3                   	ret    

0080287a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80287a:	55                   	push   %ebp
  80287b:	89 e5                	mov    %esp,%ebp
  80287d:	57                   	push   %edi
  80287e:	56                   	push   %esi
  80287f:	53                   	push   %ebx
  802880:	83 ec 18             	sub    $0x18,%esp
  802883:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802886:	57                   	push   %edi
  802887:	e8 53 ec ff ff       	call   8014df <fd2data>
  80288c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80288e:	83 c4 10             	add    $0x10,%esp
  802891:	bb 00 00 00 00       	mov    $0x0,%ebx
  802896:	eb 3d                	jmp    8028d5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802898:	85 db                	test   %ebx,%ebx
  80289a:	74 04                	je     8028a0 <devpipe_read+0x26>
				return i;
  80289c:	89 d8                	mov    %ebx,%eax
  80289e:	eb 44                	jmp    8028e4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8028a0:	89 f2                	mov    %esi,%edx
  8028a2:	89 f8                	mov    %edi,%eax
  8028a4:	e8 e5 fe ff ff       	call   80278e <_pipeisclosed>
  8028a9:	85 c0                	test   %eax,%eax
  8028ab:	75 32                	jne    8028df <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8028ad:	e8 74 e6 ff ff       	call   800f26 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8028b2:	8b 06                	mov    (%esi),%eax
  8028b4:	3b 46 04             	cmp    0x4(%esi),%eax
  8028b7:	74 df                	je     802898 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8028b9:	99                   	cltd   
  8028ba:	c1 ea 1b             	shr    $0x1b,%edx
  8028bd:	01 d0                	add    %edx,%eax
  8028bf:	83 e0 1f             	and    $0x1f,%eax
  8028c2:	29 d0                	sub    %edx,%eax
  8028c4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8028c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8028cc:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8028cf:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8028d2:	83 c3 01             	add    $0x1,%ebx
  8028d5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8028d8:	75 d8                	jne    8028b2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8028da:	8b 45 10             	mov    0x10(%ebp),%eax
  8028dd:	eb 05                	jmp    8028e4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8028df:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8028e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8028e7:	5b                   	pop    %ebx
  8028e8:	5e                   	pop    %esi
  8028e9:	5f                   	pop    %edi
  8028ea:	5d                   	pop    %ebp
  8028eb:	c3                   	ret    

008028ec <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8028ec:	55                   	push   %ebp
  8028ed:	89 e5                	mov    %esp,%ebp
  8028ef:	56                   	push   %esi
  8028f0:	53                   	push   %ebx
  8028f1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8028f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028f7:	50                   	push   %eax
  8028f8:	e8 f9 eb ff ff       	call   8014f6 <fd_alloc>
  8028fd:	83 c4 10             	add    $0x10,%esp
  802900:	89 c2                	mov    %eax,%edx
  802902:	85 c0                	test   %eax,%eax
  802904:	0f 88 2c 01 00 00    	js     802a36 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80290a:	83 ec 04             	sub    $0x4,%esp
  80290d:	68 07 04 00 00       	push   $0x407
  802912:	ff 75 f4             	pushl  -0xc(%ebp)
  802915:	6a 00                	push   $0x0
  802917:	e8 29 e6 ff ff       	call   800f45 <sys_page_alloc>
  80291c:	83 c4 10             	add    $0x10,%esp
  80291f:	89 c2                	mov    %eax,%edx
  802921:	85 c0                	test   %eax,%eax
  802923:	0f 88 0d 01 00 00    	js     802a36 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802929:	83 ec 0c             	sub    $0xc,%esp
  80292c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80292f:	50                   	push   %eax
  802930:	e8 c1 eb ff ff       	call   8014f6 <fd_alloc>
  802935:	89 c3                	mov    %eax,%ebx
  802937:	83 c4 10             	add    $0x10,%esp
  80293a:	85 c0                	test   %eax,%eax
  80293c:	0f 88 e2 00 00 00    	js     802a24 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802942:	83 ec 04             	sub    $0x4,%esp
  802945:	68 07 04 00 00       	push   $0x407
  80294a:	ff 75 f0             	pushl  -0x10(%ebp)
  80294d:	6a 00                	push   $0x0
  80294f:	e8 f1 e5 ff ff       	call   800f45 <sys_page_alloc>
  802954:	89 c3                	mov    %eax,%ebx
  802956:	83 c4 10             	add    $0x10,%esp
  802959:	85 c0                	test   %eax,%eax
  80295b:	0f 88 c3 00 00 00    	js     802a24 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802961:	83 ec 0c             	sub    $0xc,%esp
  802964:	ff 75 f4             	pushl  -0xc(%ebp)
  802967:	e8 73 eb ff ff       	call   8014df <fd2data>
  80296c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80296e:	83 c4 0c             	add    $0xc,%esp
  802971:	68 07 04 00 00       	push   $0x407
  802976:	50                   	push   %eax
  802977:	6a 00                	push   $0x0
  802979:	e8 c7 e5 ff ff       	call   800f45 <sys_page_alloc>
  80297e:	89 c3                	mov    %eax,%ebx
  802980:	83 c4 10             	add    $0x10,%esp
  802983:	85 c0                	test   %eax,%eax
  802985:	0f 88 89 00 00 00    	js     802a14 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80298b:	83 ec 0c             	sub    $0xc,%esp
  80298e:	ff 75 f0             	pushl  -0x10(%ebp)
  802991:	e8 49 eb ff ff       	call   8014df <fd2data>
  802996:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80299d:	50                   	push   %eax
  80299e:	6a 00                	push   $0x0
  8029a0:	56                   	push   %esi
  8029a1:	6a 00                	push   $0x0
  8029a3:	e8 e0 e5 ff ff       	call   800f88 <sys_page_map>
  8029a8:	89 c3                	mov    %eax,%ebx
  8029aa:	83 c4 20             	add    $0x20,%esp
  8029ad:	85 c0                	test   %eax,%eax
  8029af:	78 55                	js     802a06 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8029b1:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8029b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029ba:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8029bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029bf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8029c6:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8029cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8029cf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8029d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8029d4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8029db:	83 ec 0c             	sub    $0xc,%esp
  8029de:	ff 75 f4             	pushl  -0xc(%ebp)
  8029e1:	e8 e9 ea ff ff       	call   8014cf <fd2num>
  8029e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8029e9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8029eb:	83 c4 04             	add    $0x4,%esp
  8029ee:	ff 75 f0             	pushl  -0x10(%ebp)
  8029f1:	e8 d9 ea ff ff       	call   8014cf <fd2num>
  8029f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8029f9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8029fc:	83 c4 10             	add    $0x10,%esp
  8029ff:	ba 00 00 00 00       	mov    $0x0,%edx
  802a04:	eb 30                	jmp    802a36 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802a06:	83 ec 08             	sub    $0x8,%esp
  802a09:	56                   	push   %esi
  802a0a:	6a 00                	push   $0x0
  802a0c:	e8 b9 e5 ff ff       	call   800fca <sys_page_unmap>
  802a11:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802a14:	83 ec 08             	sub    $0x8,%esp
  802a17:	ff 75 f0             	pushl  -0x10(%ebp)
  802a1a:	6a 00                	push   $0x0
  802a1c:	e8 a9 e5 ff ff       	call   800fca <sys_page_unmap>
  802a21:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802a24:	83 ec 08             	sub    $0x8,%esp
  802a27:	ff 75 f4             	pushl  -0xc(%ebp)
  802a2a:	6a 00                	push   $0x0
  802a2c:	e8 99 e5 ff ff       	call   800fca <sys_page_unmap>
  802a31:	83 c4 10             	add    $0x10,%esp
  802a34:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802a36:	89 d0                	mov    %edx,%eax
  802a38:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a3b:	5b                   	pop    %ebx
  802a3c:	5e                   	pop    %esi
  802a3d:	5d                   	pop    %ebp
  802a3e:	c3                   	ret    

00802a3f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802a3f:	55                   	push   %ebp
  802a40:	89 e5                	mov    %esp,%ebp
  802a42:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802a45:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a48:	50                   	push   %eax
  802a49:	ff 75 08             	pushl  0x8(%ebp)
  802a4c:	e8 f4 ea ff ff       	call   801545 <fd_lookup>
  802a51:	83 c4 10             	add    $0x10,%esp
  802a54:	85 c0                	test   %eax,%eax
  802a56:	78 18                	js     802a70 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802a58:	83 ec 0c             	sub    $0xc,%esp
  802a5b:	ff 75 f4             	pushl  -0xc(%ebp)
  802a5e:	e8 7c ea ff ff       	call   8014df <fd2data>
	return _pipeisclosed(fd, p);
  802a63:	89 c2                	mov    %eax,%edx
  802a65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a68:	e8 21 fd ff ff       	call   80278e <_pipeisclosed>
  802a6d:	83 c4 10             	add    $0x10,%esp
}
  802a70:	c9                   	leave  
  802a71:	c3                   	ret    

00802a72 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802a72:	55                   	push   %ebp
  802a73:	89 e5                	mov    %esp,%ebp
  802a75:	56                   	push   %esi
  802a76:	53                   	push   %ebx
  802a77:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802a7a:	85 f6                	test   %esi,%esi
  802a7c:	75 16                	jne    802a94 <wait+0x22>
  802a7e:	68 e8 35 80 00       	push   $0x8035e8
  802a83:	68 d8 34 80 00       	push   $0x8034d8
  802a88:	6a 09                	push   $0x9
  802a8a:	68 f3 35 80 00       	push   $0x8035f3
  802a8f:	e8 50 da ff ff       	call   8004e4 <_panic>
	e = &envs[ENVX(envid)];
  802a94:	89 f3                	mov    %esi,%ebx
  802a96:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802a9c:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802a9f:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802aa5:	eb 05                	jmp    802aac <wait+0x3a>
		sys_yield();
  802aa7:	e8 7a e4 ff ff       	call   800f26 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802aac:	8b 43 48             	mov    0x48(%ebx),%eax
  802aaf:	39 c6                	cmp    %eax,%esi
  802ab1:	75 07                	jne    802aba <wait+0x48>
  802ab3:	8b 43 54             	mov    0x54(%ebx),%eax
  802ab6:	85 c0                	test   %eax,%eax
  802ab8:	75 ed                	jne    802aa7 <wait+0x35>
		sys_yield();
}
  802aba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802abd:	5b                   	pop    %ebx
  802abe:	5e                   	pop    %esi
  802abf:	5d                   	pop    %ebp
  802ac0:	c3                   	ret    

00802ac1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802ac1:	55                   	push   %ebp
  802ac2:	89 e5                	mov    %esp,%ebp
  802ac4:	53                   	push   %ebx
  802ac5:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  802ac8:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802acf:	75 28                	jne    802af9 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802ad1:	e8 31 e4 ff ff       	call   800f07 <sys_getenvid>
  802ad6:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  802ad8:	83 ec 04             	sub    $0x4,%esp
  802adb:	6a 06                	push   $0x6
  802add:	68 00 f0 bf ee       	push   $0xeebff000
  802ae2:	50                   	push   %eax
  802ae3:	e8 5d e4 ff ff       	call   800f45 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  802ae8:	83 c4 08             	add    $0x8,%esp
  802aeb:	68 06 2b 80 00       	push   $0x802b06
  802af0:	53                   	push   %ebx
  802af1:	e8 9a e5 ff ff       	call   801090 <sys_env_set_pgfault_upcall>
  802af6:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802af9:	8b 45 08             	mov    0x8(%ebp),%eax
  802afc:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802b01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b04:	c9                   	leave  
  802b05:	c3                   	ret    

00802b06 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802b06:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802b07:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802b0c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802b0e:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  802b11:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  802b13:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  802b16:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  802b19:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  802b1c:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  802b1f:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  802b22:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  802b25:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  802b28:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  802b2b:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  802b2e:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  802b31:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  802b34:	61                   	popa   
	popfl
  802b35:	9d                   	popf   
	ret
  802b36:	c3                   	ret    

00802b37 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802b37:	55                   	push   %ebp
  802b38:	89 e5                	mov    %esp,%ebp
  802b3a:	56                   	push   %esi
  802b3b:	53                   	push   %ebx
  802b3c:	8b 75 08             	mov    0x8(%ebp),%esi
  802b3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b42:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  802b45:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802b47:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802b4c:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  802b4f:	83 ec 0c             	sub    $0xc,%esp
  802b52:	50                   	push   %eax
  802b53:	e8 9d e5 ff ff       	call   8010f5 <sys_ipc_recv>

	if (r < 0) {
  802b58:	83 c4 10             	add    $0x10,%esp
  802b5b:	85 c0                	test   %eax,%eax
  802b5d:	79 16                	jns    802b75 <ipc_recv+0x3e>
		if (from_env_store)
  802b5f:	85 f6                	test   %esi,%esi
  802b61:	74 06                	je     802b69 <ipc_recv+0x32>
			*from_env_store = 0;
  802b63:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  802b69:	85 db                	test   %ebx,%ebx
  802b6b:	74 2c                	je     802b99 <ipc_recv+0x62>
			*perm_store = 0;
  802b6d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802b73:	eb 24                	jmp    802b99 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  802b75:	85 f6                	test   %esi,%esi
  802b77:	74 0a                	je     802b83 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  802b79:	a1 08 50 80 00       	mov    0x805008,%eax
  802b7e:	8b 40 74             	mov    0x74(%eax),%eax
  802b81:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  802b83:	85 db                	test   %ebx,%ebx
  802b85:	74 0a                	je     802b91 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  802b87:	a1 08 50 80 00       	mov    0x805008,%eax
  802b8c:	8b 40 78             	mov    0x78(%eax),%eax
  802b8f:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  802b91:	a1 08 50 80 00       	mov    0x805008,%eax
  802b96:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  802b99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b9c:	5b                   	pop    %ebx
  802b9d:	5e                   	pop    %esi
  802b9e:	5d                   	pop    %ebp
  802b9f:	c3                   	ret    

00802ba0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802ba0:	55                   	push   %ebp
  802ba1:	89 e5                	mov    %esp,%ebp
  802ba3:	57                   	push   %edi
  802ba4:	56                   	push   %esi
  802ba5:	53                   	push   %ebx
  802ba6:	83 ec 0c             	sub    $0xc,%esp
  802ba9:	8b 7d 08             	mov    0x8(%ebp),%edi
  802bac:	8b 75 0c             	mov    0xc(%ebp),%esi
  802baf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  802bb2:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802bb4:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802bb9:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  802bbc:	ff 75 14             	pushl  0x14(%ebp)
  802bbf:	53                   	push   %ebx
  802bc0:	56                   	push   %esi
  802bc1:	57                   	push   %edi
  802bc2:	e8 0b e5 ff ff       	call   8010d2 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  802bc7:	83 c4 10             	add    $0x10,%esp
  802bca:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802bcd:	75 07                	jne    802bd6 <ipc_send+0x36>
			sys_yield();
  802bcf:	e8 52 e3 ff ff       	call   800f26 <sys_yield>
  802bd4:	eb e6                	jmp    802bbc <ipc_send+0x1c>
		} else if (r < 0) {
  802bd6:	85 c0                	test   %eax,%eax
  802bd8:	79 12                	jns    802bec <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  802bda:	50                   	push   %eax
  802bdb:	68 fe 35 80 00       	push   $0x8035fe
  802be0:	6a 51                	push   $0x51
  802be2:	68 0b 36 80 00       	push   $0x80360b
  802be7:	e8 f8 d8 ff ff       	call   8004e4 <_panic>
		}
	}
}
  802bec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802bef:	5b                   	pop    %ebx
  802bf0:	5e                   	pop    %esi
  802bf1:	5f                   	pop    %edi
  802bf2:	5d                   	pop    %ebp
  802bf3:	c3                   	ret    

00802bf4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802bf4:	55                   	push   %ebp
  802bf5:	89 e5                	mov    %esp,%ebp
  802bf7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802bfa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802bff:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802c02:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802c08:	8b 52 50             	mov    0x50(%edx),%edx
  802c0b:	39 ca                	cmp    %ecx,%edx
  802c0d:	75 0d                	jne    802c1c <ipc_find_env+0x28>
			return envs[i].env_id;
  802c0f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802c12:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802c17:	8b 40 48             	mov    0x48(%eax),%eax
  802c1a:	eb 0f                	jmp    802c2b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802c1c:	83 c0 01             	add    $0x1,%eax
  802c1f:	3d 00 04 00 00       	cmp    $0x400,%eax
  802c24:	75 d9                	jne    802bff <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802c26:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802c2b:	5d                   	pop    %ebp
  802c2c:	c3                   	ret    

00802c2d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802c2d:	55                   	push   %ebp
  802c2e:	89 e5                	mov    %esp,%ebp
  802c30:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802c33:	89 d0                	mov    %edx,%eax
  802c35:	c1 e8 16             	shr    $0x16,%eax
  802c38:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802c3f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802c44:	f6 c1 01             	test   $0x1,%cl
  802c47:	74 1d                	je     802c66 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802c49:	c1 ea 0c             	shr    $0xc,%edx
  802c4c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802c53:	f6 c2 01             	test   $0x1,%dl
  802c56:	74 0e                	je     802c66 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802c58:	c1 ea 0c             	shr    $0xc,%edx
  802c5b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802c62:	ef 
  802c63:	0f b7 c0             	movzwl %ax,%eax
}
  802c66:	5d                   	pop    %ebp
  802c67:	c3                   	ret    
  802c68:	66 90                	xchg   %ax,%ax
  802c6a:	66 90                	xchg   %ax,%ax
  802c6c:	66 90                	xchg   %ax,%ax
  802c6e:	66 90                	xchg   %ax,%ax

00802c70 <__udivdi3>:
  802c70:	55                   	push   %ebp
  802c71:	57                   	push   %edi
  802c72:	56                   	push   %esi
  802c73:	53                   	push   %ebx
  802c74:	83 ec 1c             	sub    $0x1c,%esp
  802c77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802c7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802c7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802c83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802c87:	85 f6                	test   %esi,%esi
  802c89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802c8d:	89 ca                	mov    %ecx,%edx
  802c8f:	89 f8                	mov    %edi,%eax
  802c91:	75 3d                	jne    802cd0 <__udivdi3+0x60>
  802c93:	39 cf                	cmp    %ecx,%edi
  802c95:	0f 87 c5 00 00 00    	ja     802d60 <__udivdi3+0xf0>
  802c9b:	85 ff                	test   %edi,%edi
  802c9d:	89 fd                	mov    %edi,%ebp
  802c9f:	75 0b                	jne    802cac <__udivdi3+0x3c>
  802ca1:	b8 01 00 00 00       	mov    $0x1,%eax
  802ca6:	31 d2                	xor    %edx,%edx
  802ca8:	f7 f7                	div    %edi
  802caa:	89 c5                	mov    %eax,%ebp
  802cac:	89 c8                	mov    %ecx,%eax
  802cae:	31 d2                	xor    %edx,%edx
  802cb0:	f7 f5                	div    %ebp
  802cb2:	89 c1                	mov    %eax,%ecx
  802cb4:	89 d8                	mov    %ebx,%eax
  802cb6:	89 cf                	mov    %ecx,%edi
  802cb8:	f7 f5                	div    %ebp
  802cba:	89 c3                	mov    %eax,%ebx
  802cbc:	89 d8                	mov    %ebx,%eax
  802cbe:	89 fa                	mov    %edi,%edx
  802cc0:	83 c4 1c             	add    $0x1c,%esp
  802cc3:	5b                   	pop    %ebx
  802cc4:	5e                   	pop    %esi
  802cc5:	5f                   	pop    %edi
  802cc6:	5d                   	pop    %ebp
  802cc7:	c3                   	ret    
  802cc8:	90                   	nop
  802cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802cd0:	39 ce                	cmp    %ecx,%esi
  802cd2:	77 74                	ja     802d48 <__udivdi3+0xd8>
  802cd4:	0f bd fe             	bsr    %esi,%edi
  802cd7:	83 f7 1f             	xor    $0x1f,%edi
  802cda:	0f 84 98 00 00 00    	je     802d78 <__udivdi3+0x108>
  802ce0:	bb 20 00 00 00       	mov    $0x20,%ebx
  802ce5:	89 f9                	mov    %edi,%ecx
  802ce7:	89 c5                	mov    %eax,%ebp
  802ce9:	29 fb                	sub    %edi,%ebx
  802ceb:	d3 e6                	shl    %cl,%esi
  802ced:	89 d9                	mov    %ebx,%ecx
  802cef:	d3 ed                	shr    %cl,%ebp
  802cf1:	89 f9                	mov    %edi,%ecx
  802cf3:	d3 e0                	shl    %cl,%eax
  802cf5:	09 ee                	or     %ebp,%esi
  802cf7:	89 d9                	mov    %ebx,%ecx
  802cf9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802cfd:	89 d5                	mov    %edx,%ebp
  802cff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802d03:	d3 ed                	shr    %cl,%ebp
  802d05:	89 f9                	mov    %edi,%ecx
  802d07:	d3 e2                	shl    %cl,%edx
  802d09:	89 d9                	mov    %ebx,%ecx
  802d0b:	d3 e8                	shr    %cl,%eax
  802d0d:	09 c2                	or     %eax,%edx
  802d0f:	89 d0                	mov    %edx,%eax
  802d11:	89 ea                	mov    %ebp,%edx
  802d13:	f7 f6                	div    %esi
  802d15:	89 d5                	mov    %edx,%ebp
  802d17:	89 c3                	mov    %eax,%ebx
  802d19:	f7 64 24 0c          	mull   0xc(%esp)
  802d1d:	39 d5                	cmp    %edx,%ebp
  802d1f:	72 10                	jb     802d31 <__udivdi3+0xc1>
  802d21:	8b 74 24 08          	mov    0x8(%esp),%esi
  802d25:	89 f9                	mov    %edi,%ecx
  802d27:	d3 e6                	shl    %cl,%esi
  802d29:	39 c6                	cmp    %eax,%esi
  802d2b:	73 07                	jae    802d34 <__udivdi3+0xc4>
  802d2d:	39 d5                	cmp    %edx,%ebp
  802d2f:	75 03                	jne    802d34 <__udivdi3+0xc4>
  802d31:	83 eb 01             	sub    $0x1,%ebx
  802d34:	31 ff                	xor    %edi,%edi
  802d36:	89 d8                	mov    %ebx,%eax
  802d38:	89 fa                	mov    %edi,%edx
  802d3a:	83 c4 1c             	add    $0x1c,%esp
  802d3d:	5b                   	pop    %ebx
  802d3e:	5e                   	pop    %esi
  802d3f:	5f                   	pop    %edi
  802d40:	5d                   	pop    %ebp
  802d41:	c3                   	ret    
  802d42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802d48:	31 ff                	xor    %edi,%edi
  802d4a:	31 db                	xor    %ebx,%ebx
  802d4c:	89 d8                	mov    %ebx,%eax
  802d4e:	89 fa                	mov    %edi,%edx
  802d50:	83 c4 1c             	add    $0x1c,%esp
  802d53:	5b                   	pop    %ebx
  802d54:	5e                   	pop    %esi
  802d55:	5f                   	pop    %edi
  802d56:	5d                   	pop    %ebp
  802d57:	c3                   	ret    
  802d58:	90                   	nop
  802d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802d60:	89 d8                	mov    %ebx,%eax
  802d62:	f7 f7                	div    %edi
  802d64:	31 ff                	xor    %edi,%edi
  802d66:	89 c3                	mov    %eax,%ebx
  802d68:	89 d8                	mov    %ebx,%eax
  802d6a:	89 fa                	mov    %edi,%edx
  802d6c:	83 c4 1c             	add    $0x1c,%esp
  802d6f:	5b                   	pop    %ebx
  802d70:	5e                   	pop    %esi
  802d71:	5f                   	pop    %edi
  802d72:	5d                   	pop    %ebp
  802d73:	c3                   	ret    
  802d74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802d78:	39 ce                	cmp    %ecx,%esi
  802d7a:	72 0c                	jb     802d88 <__udivdi3+0x118>
  802d7c:	31 db                	xor    %ebx,%ebx
  802d7e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802d82:	0f 87 34 ff ff ff    	ja     802cbc <__udivdi3+0x4c>
  802d88:	bb 01 00 00 00       	mov    $0x1,%ebx
  802d8d:	e9 2a ff ff ff       	jmp    802cbc <__udivdi3+0x4c>
  802d92:	66 90                	xchg   %ax,%ax
  802d94:	66 90                	xchg   %ax,%ax
  802d96:	66 90                	xchg   %ax,%ax
  802d98:	66 90                	xchg   %ax,%ax
  802d9a:	66 90                	xchg   %ax,%ax
  802d9c:	66 90                	xchg   %ax,%ax
  802d9e:	66 90                	xchg   %ax,%ax

00802da0 <__umoddi3>:
  802da0:	55                   	push   %ebp
  802da1:	57                   	push   %edi
  802da2:	56                   	push   %esi
  802da3:	53                   	push   %ebx
  802da4:	83 ec 1c             	sub    $0x1c,%esp
  802da7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802dab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802daf:	8b 74 24 34          	mov    0x34(%esp),%esi
  802db3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802db7:	85 d2                	test   %edx,%edx
  802db9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802dbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802dc1:	89 f3                	mov    %esi,%ebx
  802dc3:	89 3c 24             	mov    %edi,(%esp)
  802dc6:	89 74 24 04          	mov    %esi,0x4(%esp)
  802dca:	75 1c                	jne    802de8 <__umoddi3+0x48>
  802dcc:	39 f7                	cmp    %esi,%edi
  802dce:	76 50                	jbe    802e20 <__umoddi3+0x80>
  802dd0:	89 c8                	mov    %ecx,%eax
  802dd2:	89 f2                	mov    %esi,%edx
  802dd4:	f7 f7                	div    %edi
  802dd6:	89 d0                	mov    %edx,%eax
  802dd8:	31 d2                	xor    %edx,%edx
  802dda:	83 c4 1c             	add    $0x1c,%esp
  802ddd:	5b                   	pop    %ebx
  802dde:	5e                   	pop    %esi
  802ddf:	5f                   	pop    %edi
  802de0:	5d                   	pop    %ebp
  802de1:	c3                   	ret    
  802de2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802de8:	39 f2                	cmp    %esi,%edx
  802dea:	89 d0                	mov    %edx,%eax
  802dec:	77 52                	ja     802e40 <__umoddi3+0xa0>
  802dee:	0f bd ea             	bsr    %edx,%ebp
  802df1:	83 f5 1f             	xor    $0x1f,%ebp
  802df4:	75 5a                	jne    802e50 <__umoddi3+0xb0>
  802df6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802dfa:	0f 82 e0 00 00 00    	jb     802ee0 <__umoddi3+0x140>
  802e00:	39 0c 24             	cmp    %ecx,(%esp)
  802e03:	0f 86 d7 00 00 00    	jbe    802ee0 <__umoddi3+0x140>
  802e09:	8b 44 24 08          	mov    0x8(%esp),%eax
  802e0d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802e11:	83 c4 1c             	add    $0x1c,%esp
  802e14:	5b                   	pop    %ebx
  802e15:	5e                   	pop    %esi
  802e16:	5f                   	pop    %edi
  802e17:	5d                   	pop    %ebp
  802e18:	c3                   	ret    
  802e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802e20:	85 ff                	test   %edi,%edi
  802e22:	89 fd                	mov    %edi,%ebp
  802e24:	75 0b                	jne    802e31 <__umoddi3+0x91>
  802e26:	b8 01 00 00 00       	mov    $0x1,%eax
  802e2b:	31 d2                	xor    %edx,%edx
  802e2d:	f7 f7                	div    %edi
  802e2f:	89 c5                	mov    %eax,%ebp
  802e31:	89 f0                	mov    %esi,%eax
  802e33:	31 d2                	xor    %edx,%edx
  802e35:	f7 f5                	div    %ebp
  802e37:	89 c8                	mov    %ecx,%eax
  802e39:	f7 f5                	div    %ebp
  802e3b:	89 d0                	mov    %edx,%eax
  802e3d:	eb 99                	jmp    802dd8 <__umoddi3+0x38>
  802e3f:	90                   	nop
  802e40:	89 c8                	mov    %ecx,%eax
  802e42:	89 f2                	mov    %esi,%edx
  802e44:	83 c4 1c             	add    $0x1c,%esp
  802e47:	5b                   	pop    %ebx
  802e48:	5e                   	pop    %esi
  802e49:	5f                   	pop    %edi
  802e4a:	5d                   	pop    %ebp
  802e4b:	c3                   	ret    
  802e4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802e50:	8b 34 24             	mov    (%esp),%esi
  802e53:	bf 20 00 00 00       	mov    $0x20,%edi
  802e58:	89 e9                	mov    %ebp,%ecx
  802e5a:	29 ef                	sub    %ebp,%edi
  802e5c:	d3 e0                	shl    %cl,%eax
  802e5e:	89 f9                	mov    %edi,%ecx
  802e60:	89 f2                	mov    %esi,%edx
  802e62:	d3 ea                	shr    %cl,%edx
  802e64:	89 e9                	mov    %ebp,%ecx
  802e66:	09 c2                	or     %eax,%edx
  802e68:	89 d8                	mov    %ebx,%eax
  802e6a:	89 14 24             	mov    %edx,(%esp)
  802e6d:	89 f2                	mov    %esi,%edx
  802e6f:	d3 e2                	shl    %cl,%edx
  802e71:	89 f9                	mov    %edi,%ecx
  802e73:	89 54 24 04          	mov    %edx,0x4(%esp)
  802e77:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802e7b:	d3 e8                	shr    %cl,%eax
  802e7d:	89 e9                	mov    %ebp,%ecx
  802e7f:	89 c6                	mov    %eax,%esi
  802e81:	d3 e3                	shl    %cl,%ebx
  802e83:	89 f9                	mov    %edi,%ecx
  802e85:	89 d0                	mov    %edx,%eax
  802e87:	d3 e8                	shr    %cl,%eax
  802e89:	89 e9                	mov    %ebp,%ecx
  802e8b:	09 d8                	or     %ebx,%eax
  802e8d:	89 d3                	mov    %edx,%ebx
  802e8f:	89 f2                	mov    %esi,%edx
  802e91:	f7 34 24             	divl   (%esp)
  802e94:	89 d6                	mov    %edx,%esi
  802e96:	d3 e3                	shl    %cl,%ebx
  802e98:	f7 64 24 04          	mull   0x4(%esp)
  802e9c:	39 d6                	cmp    %edx,%esi
  802e9e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802ea2:	89 d1                	mov    %edx,%ecx
  802ea4:	89 c3                	mov    %eax,%ebx
  802ea6:	72 08                	jb     802eb0 <__umoddi3+0x110>
  802ea8:	75 11                	jne    802ebb <__umoddi3+0x11b>
  802eaa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802eae:	73 0b                	jae    802ebb <__umoddi3+0x11b>
  802eb0:	2b 44 24 04          	sub    0x4(%esp),%eax
  802eb4:	1b 14 24             	sbb    (%esp),%edx
  802eb7:	89 d1                	mov    %edx,%ecx
  802eb9:	89 c3                	mov    %eax,%ebx
  802ebb:	8b 54 24 08          	mov    0x8(%esp),%edx
  802ebf:	29 da                	sub    %ebx,%edx
  802ec1:	19 ce                	sbb    %ecx,%esi
  802ec3:	89 f9                	mov    %edi,%ecx
  802ec5:	89 f0                	mov    %esi,%eax
  802ec7:	d3 e0                	shl    %cl,%eax
  802ec9:	89 e9                	mov    %ebp,%ecx
  802ecb:	d3 ea                	shr    %cl,%edx
  802ecd:	89 e9                	mov    %ebp,%ecx
  802ecf:	d3 ee                	shr    %cl,%esi
  802ed1:	09 d0                	or     %edx,%eax
  802ed3:	89 f2                	mov    %esi,%edx
  802ed5:	83 c4 1c             	add    $0x1c,%esp
  802ed8:	5b                   	pop    %ebx
  802ed9:	5e                   	pop    %esi
  802eda:	5f                   	pop    %edi
  802edb:	5d                   	pop    %ebp
  802edc:	c3                   	ret    
  802edd:	8d 76 00             	lea    0x0(%esi),%esi
  802ee0:	29 f9                	sub    %edi,%ecx
  802ee2:	19 d6                	sbb    %edx,%esi
  802ee4:	89 74 24 04          	mov    %esi,0x4(%esp)
  802ee8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802eec:	e9 18 ff ff ff       	jmp    802e09 <__umoddi3+0x69>
