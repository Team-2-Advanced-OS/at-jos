
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 84 09 00 00       	call   8009b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int t;

	if (s == 0) {
  800042:	85 db                	test   %ebx,%ebx
  800044:	75 2c                	jne    800072 <_gettoken+0x3f>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
_gettoken(char *s, char **p1, char **p2)
{
	int t;

	if (s == 0) {
		if (debug > 1)
  80004b:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800052:	0f 8e 3e 01 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("GETTOKEN NULL\n");
  800058:	83 ec 0c             	sub    $0xc,%esp
  80005b:	68 80 37 80 00       	push   $0x803780
  800060:	e8 89 0a 00 00       	call   800aee <cprintf>
  800065:	83 c4 10             	add    $0x10,%esp
		return 0;
  800068:	b8 00 00 00 00       	mov    $0x0,%eax
  80006d:	e9 24 01 00 00       	jmp    800196 <_gettoken+0x163>
	}

	if (debug > 1)
  800072:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800079:	7e 11                	jle    80008c <_gettoken+0x59>
		cprintf("GETTOKEN: %s\n", s);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	53                   	push   %ebx
  80007f:	68 8f 37 80 00       	push   $0x80378f
  800084:	e8 65 0a 00 00       	call   800aee <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp

	*p1 = 0;
  80008c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	*p2 = 0;
  800092:	8b 45 10             	mov    0x10(%ebp),%eax
  800095:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80009b:	eb 07                	jmp    8000a4 <_gettoken+0x71>
		*s++ = 0;
  80009d:	83 c3 01             	add    $0x1,%ebx
  8000a0:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	0f be 03             	movsbl (%ebx),%eax
  8000aa:	50                   	push   %eax
  8000ab:	68 9d 37 80 00       	push   $0x80379d
  8000b0:	e8 b9 11 00 00       	call   80126e <strchr>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	85 c0                	test   %eax,%eax
  8000ba:	75 e1                	jne    80009d <_gettoken+0x6a>
		*s++ = 0;
	if (*s == 0) {
  8000bc:	0f b6 03             	movzbl (%ebx),%eax
  8000bf:	84 c0                	test   %al,%al
  8000c1:	75 2c                	jne    8000ef <_gettoken+0xbc>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
  8000c8:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000cf:	0f 8e c1 00 00 00    	jle    800196 <_gettoken+0x163>
			cprintf("EOL\n");
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	68 a2 37 80 00       	push   $0x8037a2
  8000dd:	e8 0c 0a 00 00       	call   800aee <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ea:	e9 a7 00 00 00       	jmp    800196 <_gettoken+0x163>
	}
	if (strchr(SYMBOLS, *s)) {
  8000ef:	83 ec 08             	sub    $0x8,%esp
  8000f2:	0f be c0             	movsbl %al,%eax
  8000f5:	50                   	push   %eax
  8000f6:	68 b3 37 80 00       	push   $0x8037b3
  8000fb:	e8 6e 11 00 00       	call   80126e <strchr>
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	85 c0                	test   %eax,%eax
  800105:	74 30                	je     800137 <_gettoken+0x104>
		t = *s;
  800107:	0f be 3b             	movsbl (%ebx),%edi
		*p1 = s;
  80010a:	89 1e                	mov    %ebx,(%esi)
		*s++ = 0;
  80010c:	c6 03 00             	movb   $0x0,(%ebx)
		*p2 = s;
  80010f:	83 c3 01             	add    $0x1,%ebx
  800112:	8b 45 10             	mov    0x10(%ebp),%eax
  800115:	89 18                	mov    %ebx,(%eax)
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
  800117:	89 f8                	mov    %edi,%eax
	if (strchr(SYMBOLS, *s)) {
		t = *s;
		*p1 = s;
		*s++ = 0;
		*p2 = s;
		if (debug > 1)
  800119:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800120:	7e 74                	jle    800196 <_gettoken+0x163>
			cprintf("TOK %c\n", t);
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	57                   	push   %edi
  800126:	68 a7 37 80 00       	push   $0x8037a7
  80012b:	e8 be 09 00 00       	call   800aee <cprintf>
  800130:	83 c4 10             	add    $0x10,%esp
		return t;
  800133:	89 f8                	mov    %edi,%eax
  800135:	eb 5f                	jmp    800196 <_gettoken+0x163>
	}
	*p1 = s;
  800137:	89 1e                	mov    %ebx,(%esi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800139:	eb 03                	jmp    80013e <_gettoken+0x10b>
		s++;
  80013b:	83 c3 01             	add    $0x1,%ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80013e:	0f b6 03             	movzbl (%ebx),%eax
  800141:	84 c0                	test   %al,%al
  800143:	74 18                	je     80015d <_gettoken+0x12a>
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	0f be c0             	movsbl %al,%eax
  80014b:	50                   	push   %eax
  80014c:	68 af 37 80 00       	push   $0x8037af
  800151:	e8 18 11 00 00       	call   80126e <strchr>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	74 de                	je     80013b <_gettoken+0x108>
		s++;
	*p2 = s;
  80015d:	8b 45 10             	mov    0x10(%ebp),%eax
  800160:	89 18                	mov    %ebx,(%eax)
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  800162:	b8 77 00 00 00       	mov    $0x77,%eax
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
		s++;
	*p2 = s;
	if (debug > 1) {
  800167:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80016e:	7e 26                	jle    800196 <_gettoken+0x163>
		t = **p2;
  800170:	0f b6 3b             	movzbl (%ebx),%edi
		**p2 = 0;
  800173:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  800176:	83 ec 08             	sub    $0x8,%esp
  800179:	ff 36                	pushl  (%esi)
  80017b:	68 bb 37 80 00       	push   $0x8037bb
  800180:	e8 69 09 00 00       	call   800aee <cprintf>
		**p2 = t;
  800185:	8b 45 10             	mov    0x10(%ebp),%eax
  800188:	8b 00                	mov    (%eax),%eax
  80018a:	89 fa                	mov    %edi,%edx
  80018c:	88 10                	mov    %dl,(%eax)
  80018e:	83 c4 10             	add    $0x10,%esp
	}
	return 'w';
  800191:	b8 77 00 00 00       	mov    $0x77,%eax
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <gettoken>:

int
gettoken(char *s, char **p1)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	74 22                	je     8001cd <gettoken+0x2f>
		nc = _gettoken(s, &np1, &np2);
  8001ab:	83 ec 04             	sub    $0x4,%esp
  8001ae:	68 0c 50 80 00       	push   $0x80500c
  8001b3:	68 10 50 80 00       	push   $0x805010
  8001b8:	50                   	push   %eax
  8001b9:	e8 75 fe ff ff       	call   800033 <_gettoken>
  8001be:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8001cb:	eb 3a                	jmp    800207 <gettoken+0x69>
	}
	c = nc;
  8001cd:	a1 08 50 80 00       	mov    0x805008,%eax
  8001d2:	a3 04 50 80 00       	mov    %eax,0x805004
	*p1 = np1;
  8001d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001da:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001e0:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001e2:	83 ec 04             	sub    $0x4,%esp
  8001e5:	68 0c 50 80 00       	push   $0x80500c
  8001ea:	68 10 50 80 00       	push   $0x805010
  8001ef:	ff 35 0c 50 80 00    	pushl  0x80500c
  8001f5:	e8 39 fe ff ff       	call   800033 <_gettoken>
  8001fa:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  8001ff:	a1 04 50 80 00       	mov    0x805004,%eax
  800204:	83 c4 10             	add    $0x10,%esp
}
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	81 ec 64 04 00 00    	sub    $0x464,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  800215:	6a 00                	push   $0x0
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	e8 7f ff ff ff       	call   80019e <gettoken>
  80021f:	83 c4 10             	add    $0x10,%esp

again:
	argc = 0;
	while (1) {
		switch ((c = gettoken(0, &t))) {
  800222:	8d 5d a4             	lea    -0x5c(%ebp),%ebx

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  800225:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	53                   	push   %ebx
  80022e:	6a 00                	push   $0x0
  800230:	e8 69 ff ff ff       	call   80019e <gettoken>
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	83 f8 3e             	cmp    $0x3e,%eax
  80023b:	0f 84 cc 00 00 00    	je     80030d <runcmd+0x104>
  800241:	83 f8 3e             	cmp    $0x3e,%eax
  800244:	7f 12                	jg     800258 <runcmd+0x4f>
  800246:	85 c0                	test   %eax,%eax
  800248:	0f 84 3b 02 00 00    	je     800489 <runcmd+0x280>
  80024e:	83 f8 3c             	cmp    $0x3c,%eax
  800251:	74 3e                	je     800291 <runcmd+0x88>
  800253:	e9 1f 02 00 00       	jmp    800477 <runcmd+0x26e>
  800258:	83 f8 77             	cmp    $0x77,%eax
  80025b:	74 0e                	je     80026b <runcmd+0x62>
  80025d:	83 f8 7c             	cmp    $0x7c,%eax
  800260:	0f 84 25 01 00 00    	je     80038b <runcmd+0x182>
  800266:	e9 0c 02 00 00       	jmp    800477 <runcmd+0x26e>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  80026b:	83 fe 10             	cmp    $0x10,%esi
  80026e:	75 15                	jne    800285 <runcmd+0x7c>
				cprintf("too many arguments\n");
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	68 c5 37 80 00       	push   $0x8037c5
  800278:	e8 71 08 00 00       	call   800aee <cprintf>
				exit();
  80027d:	e8 79 07 00 00       	call   8009fb <exit>
  800282:	83 c4 10             	add    $0x10,%esp
			}
			argv[argc++] = t;
  800285:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800288:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  80028c:	8d 76 01             	lea    0x1(%esi),%esi
			break;
  80028f:	eb 99                	jmp    80022a <runcmd+0x21>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	53                   	push   %ebx
  800295:	6a 00                	push   $0x0
  800297:	e8 02 ff ff ff       	call   80019e <gettoken>
  80029c:	83 c4 10             	add    $0x10,%esp
  80029f:	83 f8 77             	cmp    $0x77,%eax
  8002a2:	74 15                	je     8002b9 <runcmd+0xb0>
				cprintf("syntax error: < not followed by word\n");
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	68 10 39 80 00       	push   $0x803910
  8002ac:	e8 3d 08 00 00       	call   800aee <cprintf>
				exit();
  8002b1:	e8 45 07 00 00       	call   8009fb <exit>
  8002b6:	83 c4 10             	add    $0x10,%esp
			// then check whether 'fd' is 0.
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			if((fd = open(t, O_RDONLY)) < 0) {
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	6a 00                	push   $0x0
  8002be:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002c1:	e8 11 21 00 00       	call   8023d7 <open>
  8002c6:	89 c7                	mov    %eax,%edi
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	79 1b                	jns    8002ea <runcmd+0xe1>
				cprintf("open %s for read: %e", t, fd);
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	50                   	push   %eax
  8002d3:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d6:	68 d9 37 80 00       	push   $0x8037d9
  8002db:	e8 0e 08 00 00       	call   800aee <cprintf>
				exit();
  8002e0:	e8 16 07 00 00       	call   8009fb <exit>
  8002e5:	83 c4 10             	add    $0x10,%esp
  8002e8:	eb 08                	jmp    8002f2 <runcmd+0xe9>
			}
			if (fd != 0) {
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	0f 84 38 ff ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 0);
  8002f2:	83 ec 08             	sub    $0x8,%esp
  8002f5:	6a 00                	push   $0x0
  8002f7:	57                   	push   %edi
  8002f8:	e8 3a 1b 00 00       	call   801e37 <dup>
				close(fd);
  8002fd:	89 3c 24             	mov    %edi,(%esp)
  800300:	e8 e2 1a 00 00       	call   801de7 <close>
  800305:	83 c4 10             	add    $0x10,%esp
  800308:	e9 1d ff ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  80030d:	83 ec 08             	sub    $0x8,%esp
  800310:	53                   	push   %ebx
  800311:	6a 00                	push   $0x0
  800313:	e8 86 fe ff ff       	call   80019e <gettoken>
  800318:	83 c4 10             	add    $0x10,%esp
  80031b:	83 f8 77             	cmp    $0x77,%eax
  80031e:	74 15                	je     800335 <runcmd+0x12c>
				cprintf("syntax error: > not followed by word\n");
  800320:	83 ec 0c             	sub    $0xc,%esp
  800323:	68 38 39 80 00       	push   $0x803938
  800328:	e8 c1 07 00 00       	call   800aee <cprintf>
				exit();
  80032d:	e8 c9 06 00 00       	call   8009fb <exit>
  800332:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	68 01 03 00 00       	push   $0x301
  80033d:	ff 75 a4             	pushl  -0x5c(%ebp)
  800340:	e8 92 20 00 00       	call   8023d7 <open>
  800345:	89 c7                	mov    %eax,%edi
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	85 c0                	test   %eax,%eax
  80034c:	79 19                	jns    800367 <runcmd+0x15e>
				cprintf("open %s for write: %e", t, fd);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	50                   	push   %eax
  800352:	ff 75 a4             	pushl  -0x5c(%ebp)
  800355:	68 ee 37 80 00       	push   $0x8037ee
  80035a:	e8 8f 07 00 00       	call   800aee <cprintf>
				exit();
  80035f:	e8 97 06 00 00       	call   8009fb <exit>
  800364:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  800367:	83 ff 01             	cmp    $0x1,%edi
  80036a:	0f 84 ba fe ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 1);
  800370:	83 ec 08             	sub    $0x8,%esp
  800373:	6a 01                	push   $0x1
  800375:	57                   	push   %edi
  800376:	e8 bc 1a 00 00       	call   801e37 <dup>
				close(fd);
  80037b:	89 3c 24             	mov    %edi,(%esp)
  80037e:	e8 64 1a 00 00       	call   801de7 <close>
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	e9 9f fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038b:	83 ec 0c             	sub    $0xc,%esp
  80038e:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800394:	50                   	push   %eax
  800395:	e8 da 2d 00 00       	call   803174 <pipe>
  80039a:	83 c4 10             	add    $0x10,%esp
  80039d:	85 c0                	test   %eax,%eax
  80039f:	79 16                	jns    8003b7 <runcmd+0x1ae>
				cprintf("pipe: %e", r);
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	50                   	push   %eax
  8003a5:	68 04 38 80 00       	push   $0x803804
  8003aa:	e8 3f 07 00 00       	call   800aee <cprintf>
				exit();
  8003af:	e8 47 06 00 00       	call   8009fb <exit>
  8003b4:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  8003b7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8003be:	74 1c                	je     8003dc <runcmd+0x1d3>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003c0:	83 ec 04             	sub    $0x4,%esp
  8003c3:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003c9:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003cf:	68 0d 38 80 00       	push   $0x80380d
  8003d4:	e8 15 07 00 00       	call   800aee <cprintf>
  8003d9:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003dc:	e8 33 15 00 00       	call   801914 <fork>
  8003e1:	89 c7                	mov    %eax,%edi
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	79 16                	jns    8003fd <runcmd+0x1f4>
				cprintf("fork: %e", r);
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	50                   	push   %eax
  8003eb:	68 76 3d 80 00       	push   $0x803d76
  8003f0:	e8 f9 06 00 00       	call   800aee <cprintf>
				exit();
  8003f5:	e8 01 06 00 00       	call   8009fb <exit>
  8003fa:	83 c4 10             	add    $0x10,%esp
			}
			if (r == 0) {
  8003fd:	85 ff                	test   %edi,%edi
  8003ff:	75 3c                	jne    80043d <runcmd+0x234>
				if (p[0] != 0) {
  800401:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800407:	85 c0                	test   %eax,%eax
  800409:	74 1c                	je     800427 <runcmd+0x21e>
					dup(p[0], 0);
  80040b:	83 ec 08             	sub    $0x8,%esp
  80040e:	6a 00                	push   $0x0
  800410:	50                   	push   %eax
  800411:	e8 21 1a 00 00       	call   801e37 <dup>
					close(p[0]);
  800416:	83 c4 04             	add    $0x4,%esp
  800419:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80041f:	e8 c3 19 00 00       	call   801de7 <close>
  800424:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800430:	e8 b2 19 00 00       	call   801de7 <close>
				goto again;
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	e9 e8 fd ff ff       	jmp    800225 <runcmd+0x1c>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  80043d:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800443:	83 f8 01             	cmp    $0x1,%eax
  800446:	74 1c                	je     800464 <runcmd+0x25b>
					dup(p[1], 1);
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	6a 01                	push   $0x1
  80044d:	50                   	push   %eax
  80044e:	e8 e4 19 00 00       	call   801e37 <dup>
					close(p[1]);
  800453:	83 c4 04             	add    $0x4,%esp
  800456:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80045c:	e8 86 19 00 00       	call   801de7 <close>
  800461:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800464:	83 ec 0c             	sub    $0xc,%esp
  800467:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80046d:	e8 75 19 00 00       	call   801de7 <close>
				goto runit;
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	eb 17                	jmp    80048e <runcmd+0x285>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800477:	50                   	push   %eax
  800478:	68 1a 38 80 00       	push   $0x80381a
  80047d:	6a 77                	push   $0x77
  80047f:	68 36 38 80 00       	push   $0x803836
  800484:	e8 8c 05 00 00       	call   800a15 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  800489:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  80048e:	85 f6                	test   %esi,%esi
  800490:	75 22                	jne    8004b4 <runcmd+0x2ab>
		if (debug)
  800492:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800499:	0f 84 96 01 00 00    	je     800635 <runcmd+0x42c>
			cprintf("EMPTY COMMAND\n");
  80049f:	83 ec 0c             	sub    $0xc,%esp
  8004a2:	68 40 38 80 00       	push   $0x803840
  8004a7:	e8 42 06 00 00       	call   800aee <cprintf>
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	e9 81 01 00 00       	jmp    800635 <runcmd+0x42c>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  8004b4:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004b7:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004ba:	74 23                	je     8004df <runcmd+0x2d6>
		argv0buf[0] = '/';
  8004bc:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	50                   	push   %eax
  8004c7:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004cd:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004d3:	50                   	push   %eax
  8004d4:	e8 8d 0c 00 00       	call   801166 <strcpy>
		argv[0] = argv0buf;
  8004d9:	89 5d a8             	mov    %ebx,-0x58(%ebp)
  8004dc:	83 c4 10             	add    $0x10,%esp
	}
	argv[argc] = 0;
  8004df:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004e6:	00 

	// Print the command.
	if (debug) {
  8004e7:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004ee:	74 49                	je     800539 <runcmd+0x330>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004f0:	a1 28 54 80 00       	mov    0x805428,%eax
  8004f5:	8b 40 48             	mov    0x48(%eax),%eax
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	50                   	push   %eax
  8004fc:	68 4f 38 80 00       	push   $0x80384f
  800501:	e8 e8 05 00 00       	call   800aee <cprintf>
  800506:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	eb 11                	jmp    80051f <runcmd+0x316>
			cprintf(" %s", argv[i]);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	50                   	push   %eax
  800512:	68 d7 38 80 00       	push   $0x8038d7
  800517:	e8 d2 05 00 00       	call   800aee <cprintf>
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  800522:	8b 43 fc             	mov    -0x4(%ebx),%eax
  800525:	85 c0                	test   %eax,%eax
  800527:	75 e5                	jne    80050e <runcmd+0x305>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  800529:	83 ec 0c             	sub    $0xc,%esp
  80052c:	68 a0 37 80 00       	push   $0x8037a0
  800531:	e8 b8 05 00 00       	call   800aee <cprintf>
  800536:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80053f:	50                   	push   %eax
  800540:	ff 75 a8             	pushl  -0x58(%ebp)
  800543:	e8 43 20 00 00       	call   80258b <spawn>
  800548:	89 c3                	mov    %eax,%ebx
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	85 c0                	test   %eax,%eax
  80054f:	0f 89 c3 00 00 00    	jns    800618 <runcmd+0x40f>
		cprintf("spawn %s: %e\n", argv[0], r);
  800555:	83 ec 04             	sub    $0x4,%esp
  800558:	50                   	push   %eax
  800559:	ff 75 a8             	pushl  -0x58(%ebp)
  80055c:	68 5d 38 80 00       	push   $0x80385d
  800561:	e8 88 05 00 00       	call   800aee <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800566:	e8 a7 18 00 00       	call   801e12 <close_all>
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb 4c                	jmp    8005bc <runcmd+0x3b3>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800570:	a1 28 54 80 00       	mov    0x805428,%eax
  800575:	8b 40 48             	mov    0x48(%eax),%eax
  800578:	53                   	push   %ebx
  800579:	ff 75 a8             	pushl  -0x58(%ebp)
  80057c:	50                   	push   %eax
  80057d:	68 6b 38 80 00       	push   $0x80386b
  800582:	e8 67 05 00 00       	call   800aee <cprintf>
  800587:	83 c4 10             	add    $0x10,%esp
		wait(r);
  80058a:	83 ec 0c             	sub    $0xc,%esp
  80058d:	53                   	push   %ebx
  80058e:	e8 67 2d 00 00       	call   8032fa <wait>
		if (debug)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80059d:	0f 84 8c 00 00 00    	je     80062f <runcmd+0x426>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005a3:	a1 28 54 80 00       	mov    0x805428,%eax
  8005a8:	8b 40 48             	mov    0x48(%eax),%eax
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	50                   	push   %eax
  8005af:	68 80 38 80 00       	push   $0x803880
  8005b4:	e8 35 05 00 00       	call   800aee <cprintf>
  8005b9:	83 c4 10             	add    $0x10,%esp
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005bc:	85 ff                	test   %edi,%edi
  8005be:	74 51                	je     800611 <runcmd+0x408>
		if (debug)
  8005c0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005c7:	74 1a                	je     8005e3 <runcmd+0x3da>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005c9:	a1 28 54 80 00       	mov    0x805428,%eax
  8005ce:	8b 40 48             	mov    0x48(%eax),%eax
  8005d1:	83 ec 04             	sub    $0x4,%esp
  8005d4:	57                   	push   %edi
  8005d5:	50                   	push   %eax
  8005d6:	68 96 38 80 00       	push   $0x803896
  8005db:	e8 0e 05 00 00       	call   800aee <cprintf>
  8005e0:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	57                   	push   %edi
  8005e7:	e8 0e 2d 00 00       	call   8032fa <wait>
		if (debug)
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005f6:	74 19                	je     800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005f8:	a1 28 54 80 00       	mov    0x805428,%eax
  8005fd:	8b 40 48             	mov    0x48(%eax),%eax
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	50                   	push   %eax
  800604:	68 80 38 80 00       	push   $0x803880
  800609:	e8 e0 04 00 00       	call   800aee <cprintf>
  80060e:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  800611:	e8 e5 03 00 00       	call   8009fb <exit>
  800616:	eb 1d                	jmp    800635 <runcmd+0x42c>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800618:	e8 f5 17 00 00       	call   801e12 <close_all>
	if (r >= 0) {
		if (debug)
  80061d:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800624:	0f 84 60 ff ff ff    	je     80058a <runcmd+0x381>
  80062a:	e9 41 ff ff ff       	jmp    800570 <runcmd+0x367>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  80062f:	85 ff                	test   %edi,%edi
  800631:	75 b0                	jne    8005e3 <runcmd+0x3da>
  800633:	eb dc                	jmp    800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// Done!
	exit();
}
  800635:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800638:	5b                   	pop    %ebx
  800639:	5e                   	pop    %esi
  80063a:	5f                   	pop    %edi
  80063b:	5d                   	pop    %ebp
  80063c:	c3                   	ret    

0080063d <usage>:
}


void
usage(void)
{
  80063d:	55                   	push   %ebp
  80063e:	89 e5                	mov    %esp,%ebp
  800640:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800643:	68 60 39 80 00       	push   $0x803960
  800648:	e8 a1 04 00 00       	call   800aee <cprintf>
	exit();
  80064d:	e8 a9 03 00 00       	call   8009fb <exit>
}
  800652:	83 c4 10             	add    $0x10,%esp
  800655:	c9                   	leave  
  800656:	c3                   	ret    

00800657 <umain>:

void
umain(int argc, char **argv)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	57                   	push   %edi
  80065b:	56                   	push   %esi
  80065c:	53                   	push   %ebx
  80065d:	83 ec 30             	sub    $0x30,%esp
  800660:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  800663:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800666:	50                   	push   %eax
  800667:	57                   	push   %edi
  800668:	8d 45 08             	lea    0x8(%ebp),%eax
  80066b:	50                   	push   %eax
  80066c:	e8 82 14 00 00       	call   801af3 <argstart>
	while ((r = argnext(&args)) >= 0)
  800671:	83 c4 10             	add    $0x10,%esp
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800674:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80067b:	be 3f 00 00 00       	mov    $0x3f,%esi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800680:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800683:	eb 2f                	jmp    8006b4 <umain+0x5d>
		switch (r) {
  800685:	83 f8 69             	cmp    $0x69,%eax
  800688:	74 25                	je     8006af <umain+0x58>
  80068a:	83 f8 78             	cmp    $0x78,%eax
  80068d:	74 07                	je     800696 <umain+0x3f>
  80068f:	83 f8 64             	cmp    $0x64,%eax
  800692:	75 14                	jne    8006a8 <umain+0x51>
  800694:	eb 09                	jmp    80069f <umain+0x48>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  800696:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  80069d:	eb 15                	jmp    8006b4 <umain+0x5d>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  80069f:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
			break;
  8006a6:	eb 0c                	jmp    8006b4 <umain+0x5d>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  8006a8:	e8 90 ff ff ff       	call   80063d <usage>
  8006ad:	eb 05                	jmp    8006b4 <umain+0x5d>
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006af:	be 01 00 00 00       	mov    $0x1,%esi
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  8006b4:	83 ec 0c             	sub    $0xc,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	e8 66 14 00 00       	call   801b23 <argnext>
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	85 c0                	test   %eax,%eax
  8006c2:	79 c1                	jns    800685 <umain+0x2e>
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006c4:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006c8:	7e 05                	jle    8006cf <umain+0x78>
		usage();
  8006ca:	e8 6e ff ff ff       	call   80063d <usage>
	if (argc == 2) {
  8006cf:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006d3:	75 56                	jne    80072b <umain+0xd4>
		close(0);
  8006d5:	83 ec 0c             	sub    $0xc,%esp
  8006d8:	6a 00                	push   $0x0
  8006da:	e8 08 17 00 00       	call   801de7 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006df:	83 c4 08             	add    $0x8,%esp
  8006e2:	6a 00                	push   $0x0
  8006e4:	ff 77 04             	pushl  0x4(%edi)
  8006e7:	e8 eb 1c 00 00       	call   8023d7 <open>
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	79 1b                	jns    80070e <umain+0xb7>
			panic("open %s: %e", argv[1], r);
  8006f3:	83 ec 0c             	sub    $0xc,%esp
  8006f6:	50                   	push   %eax
  8006f7:	ff 77 04             	pushl  0x4(%edi)
  8006fa:	68 b3 38 80 00       	push   $0x8038b3
  8006ff:	68 27 01 00 00       	push   $0x127
  800704:	68 36 38 80 00       	push   $0x803836
  800709:	e8 07 03 00 00       	call   800a15 <_panic>
		assert(r == 0);
  80070e:	85 c0                	test   %eax,%eax
  800710:	74 19                	je     80072b <umain+0xd4>
  800712:	68 bf 38 80 00       	push   $0x8038bf
  800717:	68 c6 38 80 00       	push   $0x8038c6
  80071c:	68 28 01 00 00       	push   $0x128
  800721:	68 36 38 80 00       	push   $0x803836
  800726:	e8 ea 02 00 00       	call   800a15 <_panic>
	}
	if (interactive == '?')
  80072b:	83 fe 3f             	cmp    $0x3f,%esi
  80072e:	75 0f                	jne    80073f <umain+0xe8>
		interactive = iscons(0);
  800730:	83 ec 0c             	sub    $0xc,%esp
  800733:	6a 00                	push   $0x0
  800735:	e8 f5 01 00 00       	call   80092f <iscons>
  80073a:	89 c6                	mov    %eax,%esi
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	85 f6                	test   %esi,%esi
  800741:	b8 00 00 00 00       	mov    $0x0,%eax
  800746:	bf db 38 80 00       	mov    $0x8038db,%edi
  80074b:	0f 44 f8             	cmove  %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  80074e:	83 ec 0c             	sub    $0xc,%esp
  800751:	57                   	push   %edi
  800752:	e8 e3 08 00 00       	call   80103a <readline>
  800757:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	85 c0                	test   %eax,%eax
  80075e:	75 1e                	jne    80077e <umain+0x127>
			if (debug)
  800760:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800767:	74 10                	je     800779 <umain+0x122>
				cprintf("EXITING\n");
  800769:	83 ec 0c             	sub    $0xc,%esp
  80076c:	68 de 38 80 00       	push   $0x8038de
  800771:	e8 78 03 00 00       	call   800aee <cprintf>
  800776:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  800779:	e8 7d 02 00 00       	call   8009fb <exit>
		}
		if (debug)
  80077e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800785:	74 11                	je     800798 <umain+0x141>
			cprintf("LINE: %s\n", buf);
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	53                   	push   %ebx
  80078b:	68 e7 38 80 00       	push   $0x8038e7
  800790:	e8 59 03 00 00       	call   800aee <cprintf>
  800795:	83 c4 10             	add    $0x10,%esp
		if (buf[0] == '#')
  800798:	80 3b 23             	cmpb   $0x23,(%ebx)
  80079b:	74 b1                	je     80074e <umain+0xf7>
			continue;
		if (echocmds)
  80079d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007a1:	74 11                	je     8007b4 <umain+0x15d>
			printf("# %s\n", buf);
  8007a3:	83 ec 08             	sub    $0x8,%esp
  8007a6:	53                   	push   %ebx
  8007a7:	68 f1 38 80 00       	push   $0x8038f1
  8007ac:	e8 c4 1d 00 00       	call   802575 <printf>
  8007b1:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007b4:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007bb:	74 10                	je     8007cd <umain+0x176>
			cprintf("BEFORE FORK\n");
  8007bd:	83 ec 0c             	sub    $0xc,%esp
  8007c0:	68 f7 38 80 00       	push   $0x8038f7
  8007c5:	e8 24 03 00 00       	call   800aee <cprintf>
  8007ca:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007cd:	e8 42 11 00 00       	call   801914 <fork>
  8007d2:	89 c6                	mov    %eax,%esi
  8007d4:	85 c0                	test   %eax,%eax
  8007d6:	79 15                	jns    8007ed <umain+0x196>
			panic("fork: %e", r);
  8007d8:	50                   	push   %eax
  8007d9:	68 76 3d 80 00       	push   $0x803d76
  8007de:	68 3f 01 00 00       	push   $0x13f
  8007e3:	68 36 38 80 00       	push   $0x803836
  8007e8:	e8 28 02 00 00       	call   800a15 <_panic>
		if (debug)
  8007ed:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007f4:	74 11                	je     800807 <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	50                   	push   %eax
  8007fa:	68 04 39 80 00       	push   $0x803904
  8007ff:	e8 ea 02 00 00       	call   800aee <cprintf>
  800804:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  800807:	85 f6                	test   %esi,%esi
  800809:	75 16                	jne    800821 <umain+0x1ca>
			runcmd(buf);
  80080b:	83 ec 0c             	sub    $0xc,%esp
  80080e:	53                   	push   %ebx
  80080f:	e8 f5 f9 ff ff       	call   800209 <runcmd>
			exit();
  800814:	e8 e2 01 00 00       	call   8009fb <exit>
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	e9 2d ff ff ff       	jmp    80074e <umain+0xf7>
		} else
			wait(r);
  800821:	83 ec 0c             	sub    $0xc,%esp
  800824:	56                   	push   %esi
  800825:	e8 d0 2a 00 00       	call   8032fa <wait>
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	e9 1c ff ff ff       	jmp    80074e <umain+0xf7>

00800832 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800835:	b8 00 00 00 00       	mov    $0x0,%eax
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800842:	68 81 39 80 00       	push   $0x803981
  800847:	ff 75 0c             	pushl  0xc(%ebp)
  80084a:	e8 17 09 00 00       	call   801166 <strcpy>
	return 0;
}
  80084f:	b8 00 00 00 00       	mov    $0x0,%eax
  800854:	c9                   	leave  
  800855:	c3                   	ret    

00800856 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	57                   	push   %edi
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800862:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800867:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80086d:	eb 2d                	jmp    80089c <devcons_write+0x46>
		m = n - tot;
  80086f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800872:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800874:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800877:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80087c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80087f:	83 ec 04             	sub    $0x4,%esp
  800882:	53                   	push   %ebx
  800883:	03 45 0c             	add    0xc(%ebp),%eax
  800886:	50                   	push   %eax
  800887:	57                   	push   %edi
  800888:	e8 6b 0a 00 00       	call   8012f8 <memmove>
		sys_cputs(buf, m);
  80088d:	83 c4 08             	add    $0x8,%esp
  800890:	53                   	push   %ebx
  800891:	57                   	push   %edi
  800892:	e8 16 0c 00 00       	call   8014ad <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800897:	01 de                	add    %ebx,%esi
  800899:	83 c4 10             	add    $0x10,%esp
  80089c:	89 f0                	mov    %esi,%eax
  80089e:	3b 75 10             	cmp    0x10(%ebp),%esi
  8008a1:	72 cc                	jb     80086f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8008a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5f                   	pop    %edi
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8008b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008ba:	74 2a                	je     8008e6 <devcons_read+0x3b>
  8008bc:	eb 05                	jmp    8008c3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008be:	e8 87 0c 00 00       	call   80154a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008c3:	e8 03 0c 00 00       	call   8014cb <sys_cgetc>
  8008c8:	85 c0                	test   %eax,%eax
  8008ca:	74 f2                	je     8008be <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8008cc:	85 c0                	test   %eax,%eax
  8008ce:	78 16                	js     8008e6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8008d0:	83 f8 04             	cmp    $0x4,%eax
  8008d3:	74 0c                	je     8008e1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8008d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d8:	88 02                	mov    %al,(%edx)
	return 1;
  8008da:	b8 01 00 00 00       	mov    $0x1,%eax
  8008df:	eb 05                	jmp    8008e6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8008f4:	6a 01                	push   $0x1
  8008f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008f9:	50                   	push   %eax
  8008fa:	e8 ae 0b 00 00       	call   8014ad <sys_cputs>
}
  8008ff:	83 c4 10             	add    $0x10,%esp
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <getchar>:

int
getchar(void)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80090a:	6a 01                	push   $0x1
  80090c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80090f:	50                   	push   %eax
  800910:	6a 00                	push   $0x0
  800912:	e8 0c 16 00 00       	call   801f23 <read>
	if (r < 0)
  800917:	83 c4 10             	add    $0x10,%esp
  80091a:	85 c0                	test   %eax,%eax
  80091c:	78 0f                	js     80092d <getchar+0x29>
		return r;
	if (r < 1)
  80091e:	85 c0                	test   %eax,%eax
  800920:	7e 06                	jle    800928 <getchar+0x24>
		return -E_EOF;
	return c;
  800922:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800926:	eb 05                	jmp    80092d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800928:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800935:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800938:	50                   	push   %eax
  800939:	ff 75 08             	pushl  0x8(%ebp)
  80093c:	e8 7c 13 00 00       	call   801cbd <fd_lookup>
  800941:	83 c4 10             	add    $0x10,%esp
  800944:	85 c0                	test   %eax,%eax
  800946:	78 11                	js     800959 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800948:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094b:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800951:	39 10                	cmp    %edx,(%eax)
  800953:	0f 94 c0             	sete   %al
  800956:	0f b6 c0             	movzbl %al,%eax
}
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <opencons>:

int
opencons(void)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800961:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800964:	50                   	push   %eax
  800965:	e8 04 13 00 00       	call   801c6e <fd_alloc>
  80096a:	83 c4 10             	add    $0x10,%esp
		return r;
  80096d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80096f:	85 c0                	test   %eax,%eax
  800971:	78 3e                	js     8009b1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800973:	83 ec 04             	sub    $0x4,%esp
  800976:	68 07 04 00 00       	push   $0x407
  80097b:	ff 75 f4             	pushl  -0xc(%ebp)
  80097e:	6a 00                	push   $0x0
  800980:	e8 e4 0b 00 00       	call   801569 <sys_page_alloc>
  800985:	83 c4 10             	add    $0x10,%esp
		return r;
  800988:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80098a:	85 c0                	test   %eax,%eax
  80098c:	78 23                	js     8009b1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80098e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800994:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800997:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009a3:	83 ec 0c             	sub    $0xc,%esp
  8009a6:	50                   	push   %eax
  8009a7:	e8 9b 12 00 00       	call   801c47 <fd2num>
  8009ac:	89 c2                	mov    %eax,%edx
  8009ae:	83 c4 10             	add    $0x10,%esp
}
  8009b1:	89 d0                	mov    %edx,%eax
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    

008009b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8009c0:	e8 66 0b 00 00       	call   80152b <sys_getenvid>
  8009c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8009cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009d2:	a3 28 54 80 00       	mov    %eax,0x805428

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009d7:	85 db                	test   %ebx,%ebx
  8009d9:	7e 07                	jle    8009e2 <libmain+0x2d>
		binaryname = argv[0];
  8009db:	8b 06                	mov    (%esi),%eax
  8009dd:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8009e2:	83 ec 08             	sub    $0x8,%esp
  8009e5:	56                   	push   %esi
  8009e6:	53                   	push   %ebx
  8009e7:	e8 6b fc ff ff       	call   800657 <umain>

	// exit gracefully
	exit();
  8009ec:	e8 0a 00 00 00       	call   8009fb <exit>
}
  8009f1:	83 c4 10             	add    $0x10,%esp
  8009f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009f7:	5b                   	pop    %ebx
  8009f8:	5e                   	pop    %esi
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a01:	e8 0c 14 00 00       	call   801e12 <close_all>
	sys_env_destroy(0);
  800a06:	83 ec 0c             	sub    $0xc,%esp
  800a09:	6a 00                	push   $0x0
  800a0b:	e8 da 0a 00 00       	call   8014ea <sys_env_destroy>
}
  800a10:	83 c4 10             	add    $0x10,%esp
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a1a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a1d:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a23:	e8 03 0b 00 00       	call   80152b <sys_getenvid>
  800a28:	83 ec 0c             	sub    $0xc,%esp
  800a2b:	ff 75 0c             	pushl  0xc(%ebp)
  800a2e:	ff 75 08             	pushl  0x8(%ebp)
  800a31:	56                   	push   %esi
  800a32:	50                   	push   %eax
  800a33:	68 98 39 80 00       	push   $0x803998
  800a38:	e8 b1 00 00 00       	call   800aee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a3d:	83 c4 18             	add    $0x18,%esp
  800a40:	53                   	push   %ebx
  800a41:	ff 75 10             	pushl  0x10(%ebp)
  800a44:	e8 54 00 00 00       	call   800a9d <vcprintf>
	cprintf("\n");
  800a49:	c7 04 24 a0 37 80 00 	movl   $0x8037a0,(%esp)
  800a50:	e8 99 00 00 00       	call   800aee <cprintf>
  800a55:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a58:	cc                   	int3   
  800a59:	eb fd                	jmp    800a58 <_panic+0x43>

00800a5b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	83 ec 04             	sub    $0x4,%esp
  800a62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a65:	8b 13                	mov    (%ebx),%edx
  800a67:	8d 42 01             	lea    0x1(%edx),%eax
  800a6a:	89 03                	mov    %eax,(%ebx)
  800a6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a73:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a78:	75 1a                	jne    800a94 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800a7a:	83 ec 08             	sub    $0x8,%esp
  800a7d:	68 ff 00 00 00       	push   $0xff
  800a82:	8d 43 08             	lea    0x8(%ebx),%eax
  800a85:	50                   	push   %eax
  800a86:	e8 22 0a 00 00       	call   8014ad <sys_cputs>
		b->idx = 0;
  800a8b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800a91:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800a94:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800a98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800aa6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800aad:	00 00 00 
	b.cnt = 0;
  800ab0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ab7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800aba:	ff 75 0c             	pushl  0xc(%ebp)
  800abd:	ff 75 08             	pushl  0x8(%ebp)
  800ac0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800ac6:	50                   	push   %eax
  800ac7:	68 5b 0a 80 00       	push   $0x800a5b
  800acc:	e8 54 01 00 00       	call   800c25 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800ad1:	83 c4 08             	add    $0x8,%esp
  800ad4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800ada:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800ae0:	50                   	push   %eax
  800ae1:	e8 c7 09 00 00       	call   8014ad <sys_cputs>

	return b.cnt;
}
  800ae6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800aec:	c9                   	leave  
  800aed:	c3                   	ret    

00800aee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800af4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800af7:	50                   	push   %eax
  800af8:	ff 75 08             	pushl  0x8(%ebp)
  800afb:	e8 9d ff ff ff       	call   800a9d <vcprintf>
	va_end(ap);

	return cnt;
}
  800b00:	c9                   	leave  
  800b01:	c3                   	ret    

00800b02 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	83 ec 1c             	sub    $0x1c,%esp
  800b0b:	89 c7                	mov    %eax,%edi
  800b0d:	89 d6                	mov    %edx,%esi
  800b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b15:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b18:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b1b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b23:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800b26:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800b29:	39 d3                	cmp    %edx,%ebx
  800b2b:	72 05                	jb     800b32 <printnum+0x30>
  800b2d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b30:	77 45                	ja     800b77 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b32:	83 ec 0c             	sub    $0xc,%esp
  800b35:	ff 75 18             	pushl  0x18(%ebp)
  800b38:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800b3e:	53                   	push   %ebx
  800b3f:	ff 75 10             	pushl  0x10(%ebp)
  800b42:	83 ec 08             	sub    $0x8,%esp
  800b45:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b48:	ff 75 e0             	pushl  -0x20(%ebp)
  800b4b:	ff 75 dc             	pushl  -0x24(%ebp)
  800b4e:	ff 75 d8             	pushl  -0x28(%ebp)
  800b51:	e8 9a 29 00 00       	call   8034f0 <__udivdi3>
  800b56:	83 c4 18             	add    $0x18,%esp
  800b59:	52                   	push   %edx
  800b5a:	50                   	push   %eax
  800b5b:	89 f2                	mov    %esi,%edx
  800b5d:	89 f8                	mov    %edi,%eax
  800b5f:	e8 9e ff ff ff       	call   800b02 <printnum>
  800b64:	83 c4 20             	add    $0x20,%esp
  800b67:	eb 18                	jmp    800b81 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b69:	83 ec 08             	sub    $0x8,%esp
  800b6c:	56                   	push   %esi
  800b6d:	ff 75 18             	pushl  0x18(%ebp)
  800b70:	ff d7                	call   *%edi
  800b72:	83 c4 10             	add    $0x10,%esp
  800b75:	eb 03                	jmp    800b7a <printnum+0x78>
  800b77:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b7a:	83 eb 01             	sub    $0x1,%ebx
  800b7d:	85 db                	test   %ebx,%ebx
  800b7f:	7f e8                	jg     800b69 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b81:	83 ec 08             	sub    $0x8,%esp
  800b84:	56                   	push   %esi
  800b85:	83 ec 04             	sub    $0x4,%esp
  800b88:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b8b:	ff 75 e0             	pushl  -0x20(%ebp)
  800b8e:	ff 75 dc             	pushl  -0x24(%ebp)
  800b91:	ff 75 d8             	pushl  -0x28(%ebp)
  800b94:	e8 87 2a 00 00       	call   803620 <__umoddi3>
  800b99:	83 c4 14             	add    $0x14,%esp
  800b9c:	0f be 80 bb 39 80 00 	movsbl 0x8039bb(%eax),%eax
  800ba3:	50                   	push   %eax
  800ba4:	ff d7                	call   *%edi
}
  800ba6:	83 c4 10             	add    $0x10,%esp
  800ba9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800bb4:	83 fa 01             	cmp    $0x1,%edx
  800bb7:	7e 0e                	jle    800bc7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800bb9:	8b 10                	mov    (%eax),%edx
  800bbb:	8d 4a 08             	lea    0x8(%edx),%ecx
  800bbe:	89 08                	mov    %ecx,(%eax)
  800bc0:	8b 02                	mov    (%edx),%eax
  800bc2:	8b 52 04             	mov    0x4(%edx),%edx
  800bc5:	eb 22                	jmp    800be9 <getuint+0x38>
	else if (lflag)
  800bc7:	85 d2                	test   %edx,%edx
  800bc9:	74 10                	je     800bdb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800bcb:	8b 10                	mov    (%eax),%edx
  800bcd:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bd0:	89 08                	mov    %ecx,(%eax)
  800bd2:	8b 02                	mov    (%edx),%eax
  800bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd9:	eb 0e                	jmp    800be9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800bdb:	8b 10                	mov    (%eax),%edx
  800bdd:	8d 4a 04             	lea    0x4(%edx),%ecx
  800be0:	89 08                	mov    %ecx,(%eax)
  800be2:	8b 02                	mov    (%edx),%eax
  800be4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800bf1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800bf5:	8b 10                	mov    (%eax),%edx
  800bf7:	3b 50 04             	cmp    0x4(%eax),%edx
  800bfa:	73 0a                	jae    800c06 <sprintputch+0x1b>
		*b->buf++ = ch;
  800bfc:	8d 4a 01             	lea    0x1(%edx),%ecx
  800bff:	89 08                	mov    %ecx,(%eax)
  800c01:	8b 45 08             	mov    0x8(%ebp),%eax
  800c04:	88 02                	mov    %al,(%edx)
}
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800c0e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c11:	50                   	push   %eax
  800c12:	ff 75 10             	pushl  0x10(%ebp)
  800c15:	ff 75 0c             	pushl  0xc(%ebp)
  800c18:	ff 75 08             	pushl  0x8(%ebp)
  800c1b:	e8 05 00 00 00       	call   800c25 <vprintfmt>
	va_end(ap);
}
  800c20:	83 c4 10             	add    $0x10,%esp
  800c23:	c9                   	leave  
  800c24:	c3                   	ret    

00800c25 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	83 ec 2c             	sub    $0x2c,%esp
  800c2e:	8b 75 08             	mov    0x8(%ebp),%esi
  800c31:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c34:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c37:	eb 12                	jmp    800c4b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	0f 84 89 03 00 00    	je     800fca <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800c41:	83 ec 08             	sub    $0x8,%esp
  800c44:	53                   	push   %ebx
  800c45:	50                   	push   %eax
  800c46:	ff d6                	call   *%esi
  800c48:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c4b:	83 c7 01             	add    $0x1,%edi
  800c4e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c52:	83 f8 25             	cmp    $0x25,%eax
  800c55:	75 e2                	jne    800c39 <vprintfmt+0x14>
  800c57:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800c5b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c62:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800c69:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800c70:	ba 00 00 00 00       	mov    $0x0,%edx
  800c75:	eb 07                	jmp    800c7e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c77:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800c7a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c7e:	8d 47 01             	lea    0x1(%edi),%eax
  800c81:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c84:	0f b6 07             	movzbl (%edi),%eax
  800c87:	0f b6 c8             	movzbl %al,%ecx
  800c8a:	83 e8 23             	sub    $0x23,%eax
  800c8d:	3c 55                	cmp    $0x55,%al
  800c8f:	0f 87 1a 03 00 00    	ja     800faf <vprintfmt+0x38a>
  800c95:	0f b6 c0             	movzbl %al,%eax
  800c98:	ff 24 85 00 3b 80 00 	jmp    *0x803b00(,%eax,4)
  800c9f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800ca2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800ca6:	eb d6                	jmp    800c7e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cab:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800cb3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800cb6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800cba:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800cbd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800cc0:	83 fa 09             	cmp    $0x9,%edx
  800cc3:	77 39                	ja     800cfe <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800cc5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800cc8:	eb e9                	jmp    800cb3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800cca:	8b 45 14             	mov    0x14(%ebp),%eax
  800ccd:	8d 48 04             	lea    0x4(%eax),%ecx
  800cd0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800cd3:	8b 00                	mov    (%eax),%eax
  800cd5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cd8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800cdb:	eb 27                	jmp    800d04 <vprintfmt+0xdf>
  800cdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce7:	0f 49 c8             	cmovns %eax,%ecx
  800cea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ced:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cf0:	eb 8c                	jmp    800c7e <vprintfmt+0x59>
  800cf2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800cf5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800cfc:	eb 80                	jmp    800c7e <vprintfmt+0x59>
  800cfe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d01:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800d04:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d08:	0f 89 70 ff ff ff    	jns    800c7e <vprintfmt+0x59>
				width = precision, precision = -1;
  800d0e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800d11:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d14:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800d1b:	e9 5e ff ff ff       	jmp    800c7e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d20:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d23:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d26:	e9 53 ff ff ff       	jmp    800c7e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800d2e:	8d 50 04             	lea    0x4(%eax),%edx
  800d31:	89 55 14             	mov    %edx,0x14(%ebp)
  800d34:	83 ec 08             	sub    $0x8,%esp
  800d37:	53                   	push   %ebx
  800d38:	ff 30                	pushl  (%eax)
  800d3a:	ff d6                	call   *%esi
			break;
  800d3c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d3f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d42:	e9 04 ff ff ff       	jmp    800c4b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d47:	8b 45 14             	mov    0x14(%ebp),%eax
  800d4a:	8d 50 04             	lea    0x4(%eax),%edx
  800d4d:	89 55 14             	mov    %edx,0x14(%ebp)
  800d50:	8b 00                	mov    (%eax),%eax
  800d52:	99                   	cltd   
  800d53:	31 d0                	xor    %edx,%eax
  800d55:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d57:	83 f8 0f             	cmp    $0xf,%eax
  800d5a:	7f 0b                	jg     800d67 <vprintfmt+0x142>
  800d5c:	8b 14 85 60 3c 80 00 	mov    0x803c60(,%eax,4),%edx
  800d63:	85 d2                	test   %edx,%edx
  800d65:	75 18                	jne    800d7f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800d67:	50                   	push   %eax
  800d68:	68 d3 39 80 00       	push   $0x8039d3
  800d6d:	53                   	push   %ebx
  800d6e:	56                   	push   %esi
  800d6f:	e8 94 fe ff ff       	call   800c08 <printfmt>
  800d74:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d7a:	e9 cc fe ff ff       	jmp    800c4b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800d7f:	52                   	push   %edx
  800d80:	68 d8 38 80 00       	push   $0x8038d8
  800d85:	53                   	push   %ebx
  800d86:	56                   	push   %esi
  800d87:	e8 7c fe ff ff       	call   800c08 <printfmt>
  800d8c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d8f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d92:	e9 b4 fe ff ff       	jmp    800c4b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d97:	8b 45 14             	mov    0x14(%ebp),%eax
  800d9a:	8d 50 04             	lea    0x4(%eax),%edx
  800d9d:	89 55 14             	mov    %edx,0x14(%ebp)
  800da0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800da2:	85 ff                	test   %edi,%edi
  800da4:	b8 cc 39 80 00       	mov    $0x8039cc,%eax
  800da9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800dac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800db0:	0f 8e 94 00 00 00    	jle    800e4a <vprintfmt+0x225>
  800db6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800dba:	0f 84 98 00 00 00    	je     800e58 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800dc0:	83 ec 08             	sub    $0x8,%esp
  800dc3:	ff 75 d0             	pushl  -0x30(%ebp)
  800dc6:	57                   	push   %edi
  800dc7:	e8 79 03 00 00       	call   801145 <strnlen>
  800dcc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800dcf:	29 c1                	sub    %eax,%ecx
  800dd1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800dd4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800dd7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800ddb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800dde:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800de1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800de3:	eb 0f                	jmp    800df4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800de5:	83 ec 08             	sub    $0x8,%esp
  800de8:	53                   	push   %ebx
  800de9:	ff 75 e0             	pushl  -0x20(%ebp)
  800dec:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800dee:	83 ef 01             	sub    $0x1,%edi
  800df1:	83 c4 10             	add    $0x10,%esp
  800df4:	85 ff                	test   %edi,%edi
  800df6:	7f ed                	jg     800de5 <vprintfmt+0x1c0>
  800df8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800dfb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800dfe:	85 c9                	test   %ecx,%ecx
  800e00:	b8 00 00 00 00       	mov    $0x0,%eax
  800e05:	0f 49 c1             	cmovns %ecx,%eax
  800e08:	29 c1                	sub    %eax,%ecx
  800e0a:	89 75 08             	mov    %esi,0x8(%ebp)
  800e0d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e10:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e13:	89 cb                	mov    %ecx,%ebx
  800e15:	eb 4d                	jmp    800e64 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e17:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e1b:	74 1b                	je     800e38 <vprintfmt+0x213>
  800e1d:	0f be c0             	movsbl %al,%eax
  800e20:	83 e8 20             	sub    $0x20,%eax
  800e23:	83 f8 5e             	cmp    $0x5e,%eax
  800e26:	76 10                	jbe    800e38 <vprintfmt+0x213>
					putch('?', putdat);
  800e28:	83 ec 08             	sub    $0x8,%esp
  800e2b:	ff 75 0c             	pushl  0xc(%ebp)
  800e2e:	6a 3f                	push   $0x3f
  800e30:	ff 55 08             	call   *0x8(%ebp)
  800e33:	83 c4 10             	add    $0x10,%esp
  800e36:	eb 0d                	jmp    800e45 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800e38:	83 ec 08             	sub    $0x8,%esp
  800e3b:	ff 75 0c             	pushl  0xc(%ebp)
  800e3e:	52                   	push   %edx
  800e3f:	ff 55 08             	call   *0x8(%ebp)
  800e42:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e45:	83 eb 01             	sub    $0x1,%ebx
  800e48:	eb 1a                	jmp    800e64 <vprintfmt+0x23f>
  800e4a:	89 75 08             	mov    %esi,0x8(%ebp)
  800e4d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e50:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e53:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e56:	eb 0c                	jmp    800e64 <vprintfmt+0x23f>
  800e58:	89 75 08             	mov    %esi,0x8(%ebp)
  800e5b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e5e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e61:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e64:	83 c7 01             	add    $0x1,%edi
  800e67:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e6b:	0f be d0             	movsbl %al,%edx
  800e6e:	85 d2                	test   %edx,%edx
  800e70:	74 23                	je     800e95 <vprintfmt+0x270>
  800e72:	85 f6                	test   %esi,%esi
  800e74:	78 a1                	js     800e17 <vprintfmt+0x1f2>
  800e76:	83 ee 01             	sub    $0x1,%esi
  800e79:	79 9c                	jns    800e17 <vprintfmt+0x1f2>
  800e7b:	89 df                	mov    %ebx,%edi
  800e7d:	8b 75 08             	mov    0x8(%ebp),%esi
  800e80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e83:	eb 18                	jmp    800e9d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e85:	83 ec 08             	sub    $0x8,%esp
  800e88:	53                   	push   %ebx
  800e89:	6a 20                	push   $0x20
  800e8b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e8d:	83 ef 01             	sub    $0x1,%edi
  800e90:	83 c4 10             	add    $0x10,%esp
  800e93:	eb 08                	jmp    800e9d <vprintfmt+0x278>
  800e95:	89 df                	mov    %ebx,%edi
  800e97:	8b 75 08             	mov    0x8(%ebp),%esi
  800e9a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e9d:	85 ff                	test   %edi,%edi
  800e9f:	7f e4                	jg     800e85 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ea1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ea4:	e9 a2 fd ff ff       	jmp    800c4b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ea9:	83 fa 01             	cmp    $0x1,%edx
  800eac:	7e 16                	jle    800ec4 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800eae:	8b 45 14             	mov    0x14(%ebp),%eax
  800eb1:	8d 50 08             	lea    0x8(%eax),%edx
  800eb4:	89 55 14             	mov    %edx,0x14(%ebp)
  800eb7:	8b 50 04             	mov    0x4(%eax),%edx
  800eba:	8b 00                	mov    (%eax),%eax
  800ebc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ebf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ec2:	eb 32                	jmp    800ef6 <vprintfmt+0x2d1>
	else if (lflag)
  800ec4:	85 d2                	test   %edx,%edx
  800ec6:	74 18                	je     800ee0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800ec8:	8b 45 14             	mov    0x14(%ebp),%eax
  800ecb:	8d 50 04             	lea    0x4(%eax),%edx
  800ece:	89 55 14             	mov    %edx,0x14(%ebp)
  800ed1:	8b 00                	mov    (%eax),%eax
  800ed3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ed6:	89 c1                	mov    %eax,%ecx
  800ed8:	c1 f9 1f             	sar    $0x1f,%ecx
  800edb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ede:	eb 16                	jmp    800ef6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800ee0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ee3:	8d 50 04             	lea    0x4(%eax),%edx
  800ee6:	89 55 14             	mov    %edx,0x14(%ebp)
  800ee9:	8b 00                	mov    (%eax),%eax
  800eeb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800eee:	89 c1                	mov    %eax,%ecx
  800ef0:	c1 f9 1f             	sar    $0x1f,%ecx
  800ef3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ef6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ef9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800efc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800f01:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f05:	79 74                	jns    800f7b <vprintfmt+0x356>
				putch('-', putdat);
  800f07:	83 ec 08             	sub    $0x8,%esp
  800f0a:	53                   	push   %ebx
  800f0b:	6a 2d                	push   $0x2d
  800f0d:	ff d6                	call   *%esi
				num = -(long long) num;
  800f0f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f12:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800f15:	f7 d8                	neg    %eax
  800f17:	83 d2 00             	adc    $0x0,%edx
  800f1a:	f7 da                	neg    %edx
  800f1c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800f1f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800f24:	eb 55                	jmp    800f7b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f26:	8d 45 14             	lea    0x14(%ebp),%eax
  800f29:	e8 83 fc ff ff       	call   800bb1 <getuint>
			base = 10;
  800f2e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800f33:	eb 46                	jmp    800f7b <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800f35:	8d 45 14             	lea    0x14(%ebp),%eax
  800f38:	e8 74 fc ff ff       	call   800bb1 <getuint>
                        base = 8;
  800f3d:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800f42:	eb 37                	jmp    800f7b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800f44:	83 ec 08             	sub    $0x8,%esp
  800f47:	53                   	push   %ebx
  800f48:	6a 30                	push   $0x30
  800f4a:	ff d6                	call   *%esi
			putch('x', putdat);
  800f4c:	83 c4 08             	add    $0x8,%esp
  800f4f:	53                   	push   %ebx
  800f50:	6a 78                	push   $0x78
  800f52:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f54:	8b 45 14             	mov    0x14(%ebp),%eax
  800f57:	8d 50 04             	lea    0x4(%eax),%edx
  800f5a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f5d:	8b 00                	mov    (%eax),%eax
  800f5f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800f64:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f67:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800f6c:	eb 0d                	jmp    800f7b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f6e:	8d 45 14             	lea    0x14(%ebp),%eax
  800f71:	e8 3b fc ff ff       	call   800bb1 <getuint>
			base = 16;
  800f76:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800f7b:	83 ec 0c             	sub    $0xc,%esp
  800f7e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800f82:	57                   	push   %edi
  800f83:	ff 75 e0             	pushl  -0x20(%ebp)
  800f86:	51                   	push   %ecx
  800f87:	52                   	push   %edx
  800f88:	50                   	push   %eax
  800f89:	89 da                	mov    %ebx,%edx
  800f8b:	89 f0                	mov    %esi,%eax
  800f8d:	e8 70 fb ff ff       	call   800b02 <printnum>
			break;
  800f92:	83 c4 20             	add    $0x20,%esp
  800f95:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f98:	e9 ae fc ff ff       	jmp    800c4b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800f9d:	83 ec 08             	sub    $0x8,%esp
  800fa0:	53                   	push   %ebx
  800fa1:	51                   	push   %ecx
  800fa2:	ff d6                	call   *%esi
			break;
  800fa4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fa7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800faa:	e9 9c fc ff ff       	jmp    800c4b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800faf:	83 ec 08             	sub    $0x8,%esp
  800fb2:	53                   	push   %ebx
  800fb3:	6a 25                	push   $0x25
  800fb5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800fb7:	83 c4 10             	add    $0x10,%esp
  800fba:	eb 03                	jmp    800fbf <vprintfmt+0x39a>
  800fbc:	83 ef 01             	sub    $0x1,%edi
  800fbf:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800fc3:	75 f7                	jne    800fbc <vprintfmt+0x397>
  800fc5:	e9 81 fc ff ff       	jmp    800c4b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800fca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fcd:	5b                   	pop    %ebx
  800fce:	5e                   	pop    %esi
  800fcf:	5f                   	pop    %edi
  800fd0:	5d                   	pop    %ebp
  800fd1:	c3                   	ret    

00800fd2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	83 ec 18             	sub    $0x18,%esp
  800fd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800fde:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fe1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800fe5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800fe8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	74 26                	je     801019 <vsnprintf+0x47>
  800ff3:	85 d2                	test   %edx,%edx
  800ff5:	7e 22                	jle    801019 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ff7:	ff 75 14             	pushl  0x14(%ebp)
  800ffa:	ff 75 10             	pushl  0x10(%ebp)
  800ffd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801000:	50                   	push   %eax
  801001:	68 eb 0b 80 00       	push   $0x800beb
  801006:	e8 1a fc ff ff       	call   800c25 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80100b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80100e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801011:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801014:	83 c4 10             	add    $0x10,%esp
  801017:	eb 05                	jmp    80101e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801019:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80101e:	c9                   	leave  
  80101f:	c3                   	ret    

00801020 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801026:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801029:	50                   	push   %eax
  80102a:	ff 75 10             	pushl  0x10(%ebp)
  80102d:	ff 75 0c             	pushl  0xc(%ebp)
  801030:	ff 75 08             	pushl  0x8(%ebp)
  801033:	e8 9a ff ff ff       	call   800fd2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801038:	c9                   	leave  
  801039:	c3                   	ret    

0080103a <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	57                   	push   %edi
  80103e:	56                   	push   %esi
  80103f:	53                   	push   %ebx
  801040:	83 ec 0c             	sub    $0xc,%esp
  801043:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  801046:	85 c0                	test   %eax,%eax
  801048:	74 13                	je     80105d <readline+0x23>
		fprintf(1, "%s", prompt);
  80104a:	83 ec 04             	sub    $0x4,%esp
  80104d:	50                   	push   %eax
  80104e:	68 d8 38 80 00       	push   $0x8038d8
  801053:	6a 01                	push   $0x1
  801055:	e8 04 15 00 00       	call   80255e <fprintf>
  80105a:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  80105d:	83 ec 0c             	sub    $0xc,%esp
  801060:	6a 00                	push   $0x0
  801062:	e8 c8 f8 ff ff       	call   80092f <iscons>
  801067:	89 c7                	mov    %eax,%edi
  801069:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  80106c:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  801071:	e8 8e f8 ff ff       	call   800904 <getchar>
  801076:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  801078:	85 c0                	test   %eax,%eax
  80107a:	79 29                	jns    8010a5 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  80107c:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  801081:	83 fb f8             	cmp    $0xfffffff8,%ebx
  801084:	0f 84 9b 00 00 00    	je     801125 <readline+0xeb>
				cprintf("read error: %e\n", c);
  80108a:	83 ec 08             	sub    $0x8,%esp
  80108d:	53                   	push   %ebx
  80108e:	68 bf 3c 80 00       	push   $0x803cbf
  801093:	e8 56 fa ff ff       	call   800aee <cprintf>
  801098:	83 c4 10             	add    $0x10,%esp
			return NULL;
  80109b:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a0:	e9 80 00 00 00       	jmp    801125 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8010a5:	83 f8 08             	cmp    $0x8,%eax
  8010a8:	0f 94 c2             	sete   %dl
  8010ab:	83 f8 7f             	cmp    $0x7f,%eax
  8010ae:	0f 94 c0             	sete   %al
  8010b1:	08 c2                	or     %al,%dl
  8010b3:	74 1a                	je     8010cf <readline+0x95>
  8010b5:	85 f6                	test   %esi,%esi
  8010b7:	7e 16                	jle    8010cf <readline+0x95>
			if (echoing)
  8010b9:	85 ff                	test   %edi,%edi
  8010bb:	74 0d                	je     8010ca <readline+0x90>
				cputchar('\b');
  8010bd:	83 ec 0c             	sub    $0xc,%esp
  8010c0:	6a 08                	push   $0x8
  8010c2:	e8 21 f8 ff ff       	call   8008e8 <cputchar>
  8010c7:	83 c4 10             	add    $0x10,%esp
			i--;
  8010ca:	83 ee 01             	sub    $0x1,%esi
  8010cd:	eb a2                	jmp    801071 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8010cf:	83 fb 1f             	cmp    $0x1f,%ebx
  8010d2:	7e 26                	jle    8010fa <readline+0xc0>
  8010d4:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8010da:	7f 1e                	jg     8010fa <readline+0xc0>
			if (echoing)
  8010dc:	85 ff                	test   %edi,%edi
  8010de:	74 0c                	je     8010ec <readline+0xb2>
				cputchar(c);
  8010e0:	83 ec 0c             	sub    $0xc,%esp
  8010e3:	53                   	push   %ebx
  8010e4:	e8 ff f7 ff ff       	call   8008e8 <cputchar>
  8010e9:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8010ec:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  8010f2:	8d 76 01             	lea    0x1(%esi),%esi
  8010f5:	e9 77 ff ff ff       	jmp    801071 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  8010fa:	83 fb 0a             	cmp    $0xa,%ebx
  8010fd:	74 09                	je     801108 <readline+0xce>
  8010ff:	83 fb 0d             	cmp    $0xd,%ebx
  801102:	0f 85 69 ff ff ff    	jne    801071 <readline+0x37>
			if (echoing)
  801108:	85 ff                	test   %edi,%edi
  80110a:	74 0d                	je     801119 <readline+0xdf>
				cputchar('\n');
  80110c:	83 ec 0c             	sub    $0xc,%esp
  80110f:	6a 0a                	push   $0xa
  801111:	e8 d2 f7 ff ff       	call   8008e8 <cputchar>
  801116:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  801119:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  801120:	b8 20 50 80 00       	mov    $0x805020,%eax
		}
	}
}
  801125:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801128:	5b                   	pop    %ebx
  801129:	5e                   	pop    %esi
  80112a:	5f                   	pop    %edi
  80112b:	5d                   	pop    %ebp
  80112c:	c3                   	ret    

0080112d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801133:	b8 00 00 00 00       	mov    $0x0,%eax
  801138:	eb 03                	jmp    80113d <strlen+0x10>
		n++;
  80113a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80113d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801141:	75 f7                	jne    80113a <strlen+0xd>
		n++;
	return n;
}
  801143:	5d                   	pop    %ebp
  801144:	c3                   	ret    

00801145 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80114b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80114e:	ba 00 00 00 00       	mov    $0x0,%edx
  801153:	eb 03                	jmp    801158 <strnlen+0x13>
		n++;
  801155:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801158:	39 c2                	cmp    %eax,%edx
  80115a:	74 08                	je     801164 <strnlen+0x1f>
  80115c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801160:	75 f3                	jne    801155 <strnlen+0x10>
  801162:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801164:	5d                   	pop    %ebp
  801165:	c3                   	ret    

00801166 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	53                   	push   %ebx
  80116a:	8b 45 08             	mov    0x8(%ebp),%eax
  80116d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801170:	89 c2                	mov    %eax,%edx
  801172:	83 c2 01             	add    $0x1,%edx
  801175:	83 c1 01             	add    $0x1,%ecx
  801178:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80117c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80117f:	84 db                	test   %bl,%bl
  801181:	75 ef                	jne    801172 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801183:	5b                   	pop    %ebx
  801184:	5d                   	pop    %ebp
  801185:	c3                   	ret    

00801186 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
  801189:	53                   	push   %ebx
  80118a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80118d:	53                   	push   %ebx
  80118e:	e8 9a ff ff ff       	call   80112d <strlen>
  801193:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801196:	ff 75 0c             	pushl  0xc(%ebp)
  801199:	01 d8                	add    %ebx,%eax
  80119b:	50                   	push   %eax
  80119c:	e8 c5 ff ff ff       	call   801166 <strcpy>
	return dst;
}
  8011a1:	89 d8                	mov    %ebx,%eax
  8011a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a6:	c9                   	leave  
  8011a7:	c3                   	ret    

008011a8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	56                   	push   %esi
  8011ac:	53                   	push   %ebx
  8011ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8011b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b3:	89 f3                	mov    %esi,%ebx
  8011b5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011b8:	89 f2                	mov    %esi,%edx
  8011ba:	eb 0f                	jmp    8011cb <strncpy+0x23>
		*dst++ = *src;
  8011bc:	83 c2 01             	add    $0x1,%edx
  8011bf:	0f b6 01             	movzbl (%ecx),%eax
  8011c2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8011c5:	80 39 01             	cmpb   $0x1,(%ecx)
  8011c8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8011cb:	39 da                	cmp    %ebx,%edx
  8011cd:	75 ed                	jne    8011bc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8011cf:	89 f0                	mov    %esi,%eax
  8011d1:	5b                   	pop    %ebx
  8011d2:	5e                   	pop    %esi
  8011d3:	5d                   	pop    %ebp
  8011d4:	c3                   	ret    

008011d5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	56                   	push   %esi
  8011d9:	53                   	push   %ebx
  8011da:	8b 75 08             	mov    0x8(%ebp),%esi
  8011dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e0:	8b 55 10             	mov    0x10(%ebp),%edx
  8011e3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8011e5:	85 d2                	test   %edx,%edx
  8011e7:	74 21                	je     80120a <strlcpy+0x35>
  8011e9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8011ed:	89 f2                	mov    %esi,%edx
  8011ef:	eb 09                	jmp    8011fa <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8011f1:	83 c2 01             	add    $0x1,%edx
  8011f4:	83 c1 01             	add    $0x1,%ecx
  8011f7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8011fa:	39 c2                	cmp    %eax,%edx
  8011fc:	74 09                	je     801207 <strlcpy+0x32>
  8011fe:	0f b6 19             	movzbl (%ecx),%ebx
  801201:	84 db                	test   %bl,%bl
  801203:	75 ec                	jne    8011f1 <strlcpy+0x1c>
  801205:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801207:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80120a:	29 f0                	sub    %esi,%eax
}
  80120c:	5b                   	pop    %ebx
  80120d:	5e                   	pop    %esi
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801216:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801219:	eb 06                	jmp    801221 <strcmp+0x11>
		p++, q++;
  80121b:	83 c1 01             	add    $0x1,%ecx
  80121e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801221:	0f b6 01             	movzbl (%ecx),%eax
  801224:	84 c0                	test   %al,%al
  801226:	74 04                	je     80122c <strcmp+0x1c>
  801228:	3a 02                	cmp    (%edx),%al
  80122a:	74 ef                	je     80121b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80122c:	0f b6 c0             	movzbl %al,%eax
  80122f:	0f b6 12             	movzbl (%edx),%edx
  801232:	29 d0                	sub    %edx,%eax
}
  801234:	5d                   	pop    %ebp
  801235:	c3                   	ret    

00801236 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	53                   	push   %ebx
  80123a:	8b 45 08             	mov    0x8(%ebp),%eax
  80123d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801240:	89 c3                	mov    %eax,%ebx
  801242:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801245:	eb 06                	jmp    80124d <strncmp+0x17>
		n--, p++, q++;
  801247:	83 c0 01             	add    $0x1,%eax
  80124a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80124d:	39 d8                	cmp    %ebx,%eax
  80124f:	74 15                	je     801266 <strncmp+0x30>
  801251:	0f b6 08             	movzbl (%eax),%ecx
  801254:	84 c9                	test   %cl,%cl
  801256:	74 04                	je     80125c <strncmp+0x26>
  801258:	3a 0a                	cmp    (%edx),%cl
  80125a:	74 eb                	je     801247 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80125c:	0f b6 00             	movzbl (%eax),%eax
  80125f:	0f b6 12             	movzbl (%edx),%edx
  801262:	29 d0                	sub    %edx,%eax
  801264:	eb 05                	jmp    80126b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801266:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80126b:	5b                   	pop    %ebx
  80126c:	5d                   	pop    %ebp
  80126d:	c3                   	ret    

0080126e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	8b 45 08             	mov    0x8(%ebp),%eax
  801274:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801278:	eb 07                	jmp    801281 <strchr+0x13>
		if (*s == c)
  80127a:	38 ca                	cmp    %cl,%dl
  80127c:	74 0f                	je     80128d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80127e:	83 c0 01             	add    $0x1,%eax
  801281:	0f b6 10             	movzbl (%eax),%edx
  801284:	84 d2                	test   %dl,%dl
  801286:	75 f2                	jne    80127a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801288:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    

0080128f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	8b 45 08             	mov    0x8(%ebp),%eax
  801295:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801299:	eb 03                	jmp    80129e <strfind+0xf>
  80129b:	83 c0 01             	add    $0x1,%eax
  80129e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8012a1:	38 ca                	cmp    %cl,%dl
  8012a3:	74 04                	je     8012a9 <strfind+0x1a>
  8012a5:	84 d2                	test   %dl,%dl
  8012a7:	75 f2                	jne    80129b <strfind+0xc>
			break;
	return (char *) s;
}
  8012a9:	5d                   	pop    %ebp
  8012aa:	c3                   	ret    

008012ab <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
  8012ae:	57                   	push   %edi
  8012af:	56                   	push   %esi
  8012b0:	53                   	push   %ebx
  8012b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8012b7:	85 c9                	test   %ecx,%ecx
  8012b9:	74 36                	je     8012f1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8012bb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012c1:	75 28                	jne    8012eb <memset+0x40>
  8012c3:	f6 c1 03             	test   $0x3,%cl
  8012c6:	75 23                	jne    8012eb <memset+0x40>
		c &= 0xFF;
  8012c8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8012cc:	89 d3                	mov    %edx,%ebx
  8012ce:	c1 e3 08             	shl    $0x8,%ebx
  8012d1:	89 d6                	mov    %edx,%esi
  8012d3:	c1 e6 18             	shl    $0x18,%esi
  8012d6:	89 d0                	mov    %edx,%eax
  8012d8:	c1 e0 10             	shl    $0x10,%eax
  8012db:	09 f0                	or     %esi,%eax
  8012dd:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8012df:	89 d8                	mov    %ebx,%eax
  8012e1:	09 d0                	or     %edx,%eax
  8012e3:	c1 e9 02             	shr    $0x2,%ecx
  8012e6:	fc                   	cld    
  8012e7:	f3 ab                	rep stos %eax,%es:(%edi)
  8012e9:	eb 06                	jmp    8012f1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8012eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ee:	fc                   	cld    
  8012ef:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8012f1:	89 f8                	mov    %edi,%eax
  8012f3:	5b                   	pop    %ebx
  8012f4:	5e                   	pop    %esi
  8012f5:	5f                   	pop    %edi
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    

008012f8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	57                   	push   %edi
  8012fc:	56                   	push   %esi
  8012fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801300:	8b 75 0c             	mov    0xc(%ebp),%esi
  801303:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801306:	39 c6                	cmp    %eax,%esi
  801308:	73 35                	jae    80133f <memmove+0x47>
  80130a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80130d:	39 d0                	cmp    %edx,%eax
  80130f:	73 2e                	jae    80133f <memmove+0x47>
		s += n;
		d += n;
  801311:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801314:	89 d6                	mov    %edx,%esi
  801316:	09 fe                	or     %edi,%esi
  801318:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80131e:	75 13                	jne    801333 <memmove+0x3b>
  801320:	f6 c1 03             	test   $0x3,%cl
  801323:	75 0e                	jne    801333 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801325:	83 ef 04             	sub    $0x4,%edi
  801328:	8d 72 fc             	lea    -0x4(%edx),%esi
  80132b:	c1 e9 02             	shr    $0x2,%ecx
  80132e:	fd                   	std    
  80132f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801331:	eb 09                	jmp    80133c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801333:	83 ef 01             	sub    $0x1,%edi
  801336:	8d 72 ff             	lea    -0x1(%edx),%esi
  801339:	fd                   	std    
  80133a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80133c:	fc                   	cld    
  80133d:	eb 1d                	jmp    80135c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80133f:	89 f2                	mov    %esi,%edx
  801341:	09 c2                	or     %eax,%edx
  801343:	f6 c2 03             	test   $0x3,%dl
  801346:	75 0f                	jne    801357 <memmove+0x5f>
  801348:	f6 c1 03             	test   $0x3,%cl
  80134b:	75 0a                	jne    801357 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80134d:	c1 e9 02             	shr    $0x2,%ecx
  801350:	89 c7                	mov    %eax,%edi
  801352:	fc                   	cld    
  801353:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801355:	eb 05                	jmp    80135c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801357:	89 c7                	mov    %eax,%edi
  801359:	fc                   	cld    
  80135a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80135c:	5e                   	pop    %esi
  80135d:	5f                   	pop    %edi
  80135e:	5d                   	pop    %ebp
  80135f:	c3                   	ret    

00801360 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801363:	ff 75 10             	pushl  0x10(%ebp)
  801366:	ff 75 0c             	pushl  0xc(%ebp)
  801369:	ff 75 08             	pushl  0x8(%ebp)
  80136c:	e8 87 ff ff ff       	call   8012f8 <memmove>
}
  801371:	c9                   	leave  
  801372:	c3                   	ret    

00801373 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	56                   	push   %esi
  801377:	53                   	push   %ebx
  801378:	8b 45 08             	mov    0x8(%ebp),%eax
  80137b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80137e:	89 c6                	mov    %eax,%esi
  801380:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801383:	eb 1a                	jmp    80139f <memcmp+0x2c>
		if (*s1 != *s2)
  801385:	0f b6 08             	movzbl (%eax),%ecx
  801388:	0f b6 1a             	movzbl (%edx),%ebx
  80138b:	38 d9                	cmp    %bl,%cl
  80138d:	74 0a                	je     801399 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80138f:	0f b6 c1             	movzbl %cl,%eax
  801392:	0f b6 db             	movzbl %bl,%ebx
  801395:	29 d8                	sub    %ebx,%eax
  801397:	eb 0f                	jmp    8013a8 <memcmp+0x35>
		s1++, s2++;
  801399:	83 c0 01             	add    $0x1,%eax
  80139c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80139f:	39 f0                	cmp    %esi,%eax
  8013a1:	75 e2                	jne    801385 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8013a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013a8:	5b                   	pop    %ebx
  8013a9:	5e                   	pop    %esi
  8013aa:	5d                   	pop    %ebp
  8013ab:	c3                   	ret    

008013ac <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	53                   	push   %ebx
  8013b0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8013b3:	89 c1                	mov    %eax,%ecx
  8013b5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8013b8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013bc:	eb 0a                	jmp    8013c8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8013be:	0f b6 10             	movzbl (%eax),%edx
  8013c1:	39 da                	cmp    %ebx,%edx
  8013c3:	74 07                	je     8013cc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8013c5:	83 c0 01             	add    $0x1,%eax
  8013c8:	39 c8                	cmp    %ecx,%eax
  8013ca:	72 f2                	jb     8013be <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8013cc:	5b                   	pop    %ebx
  8013cd:	5d                   	pop    %ebp
  8013ce:	c3                   	ret    

008013cf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8013cf:	55                   	push   %ebp
  8013d0:	89 e5                	mov    %esp,%ebp
  8013d2:	57                   	push   %edi
  8013d3:	56                   	push   %esi
  8013d4:	53                   	push   %ebx
  8013d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013db:	eb 03                	jmp    8013e0 <strtol+0x11>
		s++;
  8013dd:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013e0:	0f b6 01             	movzbl (%ecx),%eax
  8013e3:	3c 20                	cmp    $0x20,%al
  8013e5:	74 f6                	je     8013dd <strtol+0xe>
  8013e7:	3c 09                	cmp    $0x9,%al
  8013e9:	74 f2                	je     8013dd <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8013eb:	3c 2b                	cmp    $0x2b,%al
  8013ed:	75 0a                	jne    8013f9 <strtol+0x2a>
		s++;
  8013ef:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8013f2:	bf 00 00 00 00       	mov    $0x0,%edi
  8013f7:	eb 11                	jmp    80140a <strtol+0x3b>
  8013f9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8013fe:	3c 2d                	cmp    $0x2d,%al
  801400:	75 08                	jne    80140a <strtol+0x3b>
		s++, neg = 1;
  801402:	83 c1 01             	add    $0x1,%ecx
  801405:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80140a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801410:	75 15                	jne    801427 <strtol+0x58>
  801412:	80 39 30             	cmpb   $0x30,(%ecx)
  801415:	75 10                	jne    801427 <strtol+0x58>
  801417:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80141b:	75 7c                	jne    801499 <strtol+0xca>
		s += 2, base = 16;
  80141d:	83 c1 02             	add    $0x2,%ecx
  801420:	bb 10 00 00 00       	mov    $0x10,%ebx
  801425:	eb 16                	jmp    80143d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801427:	85 db                	test   %ebx,%ebx
  801429:	75 12                	jne    80143d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80142b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801430:	80 39 30             	cmpb   $0x30,(%ecx)
  801433:	75 08                	jne    80143d <strtol+0x6e>
		s++, base = 8;
  801435:	83 c1 01             	add    $0x1,%ecx
  801438:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80143d:	b8 00 00 00 00       	mov    $0x0,%eax
  801442:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801445:	0f b6 11             	movzbl (%ecx),%edx
  801448:	8d 72 d0             	lea    -0x30(%edx),%esi
  80144b:	89 f3                	mov    %esi,%ebx
  80144d:	80 fb 09             	cmp    $0x9,%bl
  801450:	77 08                	ja     80145a <strtol+0x8b>
			dig = *s - '0';
  801452:	0f be d2             	movsbl %dl,%edx
  801455:	83 ea 30             	sub    $0x30,%edx
  801458:	eb 22                	jmp    80147c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80145a:	8d 72 9f             	lea    -0x61(%edx),%esi
  80145d:	89 f3                	mov    %esi,%ebx
  80145f:	80 fb 19             	cmp    $0x19,%bl
  801462:	77 08                	ja     80146c <strtol+0x9d>
			dig = *s - 'a' + 10;
  801464:	0f be d2             	movsbl %dl,%edx
  801467:	83 ea 57             	sub    $0x57,%edx
  80146a:	eb 10                	jmp    80147c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80146c:	8d 72 bf             	lea    -0x41(%edx),%esi
  80146f:	89 f3                	mov    %esi,%ebx
  801471:	80 fb 19             	cmp    $0x19,%bl
  801474:	77 16                	ja     80148c <strtol+0xbd>
			dig = *s - 'A' + 10;
  801476:	0f be d2             	movsbl %dl,%edx
  801479:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80147c:	3b 55 10             	cmp    0x10(%ebp),%edx
  80147f:	7d 0b                	jge    80148c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801481:	83 c1 01             	add    $0x1,%ecx
  801484:	0f af 45 10          	imul   0x10(%ebp),%eax
  801488:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80148a:	eb b9                	jmp    801445 <strtol+0x76>

	if (endptr)
  80148c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801490:	74 0d                	je     80149f <strtol+0xd0>
		*endptr = (char *) s;
  801492:	8b 75 0c             	mov    0xc(%ebp),%esi
  801495:	89 0e                	mov    %ecx,(%esi)
  801497:	eb 06                	jmp    80149f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801499:	85 db                	test   %ebx,%ebx
  80149b:	74 98                	je     801435 <strtol+0x66>
  80149d:	eb 9e                	jmp    80143d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80149f:	89 c2                	mov    %eax,%edx
  8014a1:	f7 da                	neg    %edx
  8014a3:	85 ff                	test   %edi,%edi
  8014a5:	0f 45 c2             	cmovne %edx,%eax
}
  8014a8:	5b                   	pop    %ebx
  8014a9:	5e                   	pop    %esi
  8014aa:	5f                   	pop    %edi
  8014ab:	5d                   	pop    %ebp
  8014ac:	c3                   	ret    

008014ad <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8014ad:	55                   	push   %ebp
  8014ae:	89 e5                	mov    %esp,%ebp
  8014b0:	57                   	push   %edi
  8014b1:	56                   	push   %esi
  8014b2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8014be:	89 c3                	mov    %eax,%ebx
  8014c0:	89 c7                	mov    %eax,%edi
  8014c2:	89 c6                	mov    %eax,%esi
  8014c4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8014c6:	5b                   	pop    %ebx
  8014c7:	5e                   	pop    %esi
  8014c8:	5f                   	pop    %edi
  8014c9:	5d                   	pop    %ebp
  8014ca:	c3                   	ret    

008014cb <sys_cgetc>:

int
sys_cgetc(void)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	57                   	push   %edi
  8014cf:	56                   	push   %esi
  8014d0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014db:	89 d1                	mov    %edx,%ecx
  8014dd:	89 d3                	mov    %edx,%ebx
  8014df:	89 d7                	mov    %edx,%edi
  8014e1:	89 d6                	mov    %edx,%esi
  8014e3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8014e5:	5b                   	pop    %ebx
  8014e6:	5e                   	pop    %esi
  8014e7:	5f                   	pop    %edi
  8014e8:	5d                   	pop    %ebp
  8014e9:	c3                   	ret    

008014ea <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	57                   	push   %edi
  8014ee:	56                   	push   %esi
  8014ef:	53                   	push   %ebx
  8014f0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014f8:	b8 03 00 00 00       	mov    $0x3,%eax
  8014fd:	8b 55 08             	mov    0x8(%ebp),%edx
  801500:	89 cb                	mov    %ecx,%ebx
  801502:	89 cf                	mov    %ecx,%edi
  801504:	89 ce                	mov    %ecx,%esi
  801506:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801508:	85 c0                	test   %eax,%eax
  80150a:	7e 17                	jle    801523 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80150c:	83 ec 0c             	sub    $0xc,%esp
  80150f:	50                   	push   %eax
  801510:	6a 03                	push   $0x3
  801512:	68 cf 3c 80 00       	push   $0x803ccf
  801517:	6a 23                	push   $0x23
  801519:	68 ec 3c 80 00       	push   $0x803cec
  80151e:	e8 f2 f4 ff ff       	call   800a15 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801523:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801526:	5b                   	pop    %ebx
  801527:	5e                   	pop    %esi
  801528:	5f                   	pop    %edi
  801529:	5d                   	pop    %ebp
  80152a:	c3                   	ret    

0080152b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	57                   	push   %edi
  80152f:	56                   	push   %esi
  801530:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801531:	ba 00 00 00 00       	mov    $0x0,%edx
  801536:	b8 02 00 00 00       	mov    $0x2,%eax
  80153b:	89 d1                	mov    %edx,%ecx
  80153d:	89 d3                	mov    %edx,%ebx
  80153f:	89 d7                	mov    %edx,%edi
  801541:	89 d6                	mov    %edx,%esi
  801543:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801545:	5b                   	pop    %ebx
  801546:	5e                   	pop    %esi
  801547:	5f                   	pop    %edi
  801548:	5d                   	pop    %ebp
  801549:	c3                   	ret    

0080154a <sys_yield>:

void
sys_yield(void)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	57                   	push   %edi
  80154e:	56                   	push   %esi
  80154f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801550:	ba 00 00 00 00       	mov    $0x0,%edx
  801555:	b8 0b 00 00 00       	mov    $0xb,%eax
  80155a:	89 d1                	mov    %edx,%ecx
  80155c:	89 d3                	mov    %edx,%ebx
  80155e:	89 d7                	mov    %edx,%edi
  801560:	89 d6                	mov    %edx,%esi
  801562:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801564:	5b                   	pop    %ebx
  801565:	5e                   	pop    %esi
  801566:	5f                   	pop    %edi
  801567:	5d                   	pop    %ebp
  801568:	c3                   	ret    

00801569 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801569:	55                   	push   %ebp
  80156a:	89 e5                	mov    %esp,%ebp
  80156c:	57                   	push   %edi
  80156d:	56                   	push   %esi
  80156e:	53                   	push   %ebx
  80156f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801572:	be 00 00 00 00       	mov    $0x0,%esi
  801577:	b8 04 00 00 00       	mov    $0x4,%eax
  80157c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80157f:	8b 55 08             	mov    0x8(%ebp),%edx
  801582:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801585:	89 f7                	mov    %esi,%edi
  801587:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801589:	85 c0                	test   %eax,%eax
  80158b:	7e 17                	jle    8015a4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80158d:	83 ec 0c             	sub    $0xc,%esp
  801590:	50                   	push   %eax
  801591:	6a 04                	push   $0x4
  801593:	68 cf 3c 80 00       	push   $0x803ccf
  801598:	6a 23                	push   $0x23
  80159a:	68 ec 3c 80 00       	push   $0x803cec
  80159f:	e8 71 f4 ff ff       	call   800a15 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8015a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a7:	5b                   	pop    %ebx
  8015a8:	5e                   	pop    %esi
  8015a9:	5f                   	pop    %edi
  8015aa:	5d                   	pop    %ebp
  8015ab:	c3                   	ret    

008015ac <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	57                   	push   %edi
  8015b0:	56                   	push   %esi
  8015b1:	53                   	push   %ebx
  8015b2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015b5:	b8 05 00 00 00       	mov    $0x5,%eax
  8015ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8015c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015c3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8015c6:	8b 75 18             	mov    0x18(%ebp),%esi
  8015c9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	7e 17                	jle    8015e6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015cf:	83 ec 0c             	sub    $0xc,%esp
  8015d2:	50                   	push   %eax
  8015d3:	6a 05                	push   $0x5
  8015d5:	68 cf 3c 80 00       	push   $0x803ccf
  8015da:	6a 23                	push   $0x23
  8015dc:	68 ec 3c 80 00       	push   $0x803cec
  8015e1:	e8 2f f4 ff ff       	call   800a15 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8015e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e9:	5b                   	pop    %ebx
  8015ea:	5e                   	pop    %esi
  8015eb:	5f                   	pop    %edi
  8015ec:	5d                   	pop    %ebp
  8015ed:	c3                   	ret    

008015ee <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	57                   	push   %edi
  8015f2:	56                   	push   %esi
  8015f3:	53                   	push   %ebx
  8015f4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015fc:	b8 06 00 00 00       	mov    $0x6,%eax
  801601:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801604:	8b 55 08             	mov    0x8(%ebp),%edx
  801607:	89 df                	mov    %ebx,%edi
  801609:	89 de                	mov    %ebx,%esi
  80160b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80160d:	85 c0                	test   %eax,%eax
  80160f:	7e 17                	jle    801628 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801611:	83 ec 0c             	sub    $0xc,%esp
  801614:	50                   	push   %eax
  801615:	6a 06                	push   $0x6
  801617:	68 cf 3c 80 00       	push   $0x803ccf
  80161c:	6a 23                	push   $0x23
  80161e:	68 ec 3c 80 00       	push   $0x803cec
  801623:	e8 ed f3 ff ff       	call   800a15 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801628:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80162b:	5b                   	pop    %ebx
  80162c:	5e                   	pop    %esi
  80162d:	5f                   	pop    %edi
  80162e:	5d                   	pop    %ebp
  80162f:	c3                   	ret    

00801630 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	57                   	push   %edi
  801634:	56                   	push   %esi
  801635:	53                   	push   %ebx
  801636:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801639:	bb 00 00 00 00       	mov    $0x0,%ebx
  80163e:	b8 08 00 00 00       	mov    $0x8,%eax
  801643:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801646:	8b 55 08             	mov    0x8(%ebp),%edx
  801649:	89 df                	mov    %ebx,%edi
  80164b:	89 de                	mov    %ebx,%esi
  80164d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80164f:	85 c0                	test   %eax,%eax
  801651:	7e 17                	jle    80166a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801653:	83 ec 0c             	sub    $0xc,%esp
  801656:	50                   	push   %eax
  801657:	6a 08                	push   $0x8
  801659:	68 cf 3c 80 00       	push   $0x803ccf
  80165e:	6a 23                	push   $0x23
  801660:	68 ec 3c 80 00       	push   $0x803cec
  801665:	e8 ab f3 ff ff       	call   800a15 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80166a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166d:	5b                   	pop    %ebx
  80166e:	5e                   	pop    %esi
  80166f:	5f                   	pop    %edi
  801670:	5d                   	pop    %ebp
  801671:	c3                   	ret    

00801672 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	57                   	push   %edi
  801676:	56                   	push   %esi
  801677:	53                   	push   %ebx
  801678:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80167b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801680:	b8 09 00 00 00       	mov    $0x9,%eax
  801685:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801688:	8b 55 08             	mov    0x8(%ebp),%edx
  80168b:	89 df                	mov    %ebx,%edi
  80168d:	89 de                	mov    %ebx,%esi
  80168f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801691:	85 c0                	test   %eax,%eax
  801693:	7e 17                	jle    8016ac <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801695:	83 ec 0c             	sub    $0xc,%esp
  801698:	50                   	push   %eax
  801699:	6a 09                	push   $0x9
  80169b:	68 cf 3c 80 00       	push   $0x803ccf
  8016a0:	6a 23                	push   $0x23
  8016a2:	68 ec 3c 80 00       	push   $0x803cec
  8016a7:	e8 69 f3 ff ff       	call   800a15 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8016ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016af:	5b                   	pop    %ebx
  8016b0:	5e                   	pop    %esi
  8016b1:	5f                   	pop    %edi
  8016b2:	5d                   	pop    %ebp
  8016b3:	c3                   	ret    

008016b4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	57                   	push   %edi
  8016b8:	56                   	push   %esi
  8016b9:	53                   	push   %ebx
  8016ba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8016cd:	89 df                	mov    %ebx,%edi
  8016cf:	89 de                	mov    %ebx,%esi
  8016d1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	7e 17                	jle    8016ee <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016d7:	83 ec 0c             	sub    $0xc,%esp
  8016da:	50                   	push   %eax
  8016db:	6a 0a                	push   $0xa
  8016dd:	68 cf 3c 80 00       	push   $0x803ccf
  8016e2:	6a 23                	push   $0x23
  8016e4:	68 ec 3c 80 00       	push   $0x803cec
  8016e9:	e8 27 f3 ff ff       	call   800a15 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8016ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f1:	5b                   	pop    %ebx
  8016f2:	5e                   	pop    %esi
  8016f3:	5f                   	pop    %edi
  8016f4:	5d                   	pop    %ebp
  8016f5:	c3                   	ret    

008016f6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	57                   	push   %edi
  8016fa:	56                   	push   %esi
  8016fb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016fc:	be 00 00 00 00       	mov    $0x0,%esi
  801701:	b8 0c 00 00 00       	mov    $0xc,%eax
  801706:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801709:	8b 55 08             	mov    0x8(%ebp),%edx
  80170c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80170f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801712:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801714:	5b                   	pop    %ebx
  801715:	5e                   	pop    %esi
  801716:	5f                   	pop    %edi
  801717:	5d                   	pop    %ebp
  801718:	c3                   	ret    

00801719 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801719:	55                   	push   %ebp
  80171a:	89 e5                	mov    %esp,%ebp
  80171c:	57                   	push   %edi
  80171d:	56                   	push   %esi
  80171e:	53                   	push   %ebx
  80171f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801722:	b9 00 00 00 00       	mov    $0x0,%ecx
  801727:	b8 0d 00 00 00       	mov    $0xd,%eax
  80172c:	8b 55 08             	mov    0x8(%ebp),%edx
  80172f:	89 cb                	mov    %ecx,%ebx
  801731:	89 cf                	mov    %ecx,%edi
  801733:	89 ce                	mov    %ecx,%esi
  801735:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801737:	85 c0                	test   %eax,%eax
  801739:	7e 17                	jle    801752 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80173b:	83 ec 0c             	sub    $0xc,%esp
  80173e:	50                   	push   %eax
  80173f:	6a 0d                	push   $0xd
  801741:	68 cf 3c 80 00       	push   $0x803ccf
  801746:	6a 23                	push   $0x23
  801748:	68 ec 3c 80 00       	push   $0x803cec
  80174d:	e8 c3 f2 ff ff       	call   800a15 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801752:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801755:	5b                   	pop    %ebx
  801756:	5e                   	pop    %esi
  801757:	5f                   	pop    %edi
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    

0080175a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	57                   	push   %edi
  80175e:	56                   	push   %esi
  80175f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801760:	ba 00 00 00 00       	mov    $0x0,%edx
  801765:	b8 0e 00 00 00       	mov    $0xe,%eax
  80176a:	89 d1                	mov    %edx,%ecx
  80176c:	89 d3                	mov    %edx,%ebx
  80176e:	89 d7                	mov    %edx,%edi
  801770:	89 d6                	mov    %edx,%esi
  801772:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801774:	5b                   	pop    %ebx
  801775:	5e                   	pop    %esi
  801776:	5f                   	pop    %edi
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    

00801779 <sys_transmit_packet>:

int
sys_transmit_packet(void *buf, size_t size)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	57                   	push   %edi
  80177d:	56                   	push   %esi
  80177e:	53                   	push   %ebx
  80177f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801782:	bb 00 00 00 00       	mov    $0x0,%ebx
  801787:	b8 0f 00 00 00       	mov    $0xf,%eax
  80178c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80178f:	8b 55 08             	mov    0x8(%ebp),%edx
  801792:	89 df                	mov    %ebx,%edi
  801794:	89 de                	mov    %ebx,%esi
  801796:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801798:	85 c0                	test   %eax,%eax
  80179a:	7e 17                	jle    8017b3 <sys_transmit_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80179c:	83 ec 0c             	sub    $0xc,%esp
  80179f:	50                   	push   %eax
  8017a0:	6a 0f                	push   $0xf
  8017a2:	68 cf 3c 80 00       	push   $0x803ccf
  8017a7:	6a 23                	push   $0x23
  8017a9:	68 ec 3c 80 00       	push   $0x803cec
  8017ae:	e8 62 f2 ff ff       	call   800a15 <_panic>
int
sys_transmit_packet(void *buf, size_t size)
{
	return syscall(SYS_transmit_packet, 1,
		(uint32_t) buf, (uint32_t) size, 0, 0, 0);
}
  8017b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017b6:	5b                   	pop    %ebx
  8017b7:	5e                   	pop    %esi
  8017b8:	5f                   	pop    %edi
  8017b9:	5d                   	pop    %ebp
  8017ba:	c3                   	ret    

008017bb <sys_receive_packet>:

int
sys_receive_packet(void *buf, size_t *size_store)
{
  8017bb:	55                   	push   %ebp
  8017bc:	89 e5                	mov    %esp,%ebp
  8017be:	57                   	push   %edi
  8017bf:	56                   	push   %esi
  8017c0:	53                   	push   %ebx
  8017c1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017c9:	b8 10 00 00 00       	mov    $0x10,%eax
  8017ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8017d4:	89 df                	mov    %ebx,%edi
  8017d6:	89 de                	mov    %ebx,%esi
  8017d8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8017da:	85 c0                	test   %eax,%eax
  8017dc:	7e 17                	jle    8017f5 <sys_receive_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017de:	83 ec 0c             	sub    $0xc,%esp
  8017e1:	50                   	push   %eax
  8017e2:	6a 10                	push   $0x10
  8017e4:	68 cf 3c 80 00       	push   $0x803ccf
  8017e9:	6a 23                	push   $0x23
  8017eb:	68 ec 3c 80 00       	push   $0x803cec
  8017f0:	e8 20 f2 ff ff       	call   800a15 <_panic>
int
sys_receive_packet(void *buf, size_t *size_store)
{
	return syscall(SYS_receive_packet, 1,
		(uint32_t) buf, (uint32_t) size_store, 0, 0, 0);
}
  8017f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017f8:	5b                   	pop    %ebx
  8017f9:	5e                   	pop    %esi
  8017fa:	5f                   	pop    %edi
  8017fb:	5d                   	pop    %ebp
  8017fc:	c3                   	ret    

008017fd <sys_get_mac_address>:

int
sys_get_mac_address(void *buf)
{
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	57                   	push   %edi
  801801:	56                   	push   %esi
  801802:	53                   	push   %ebx
  801803:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801806:	b9 00 00 00 00       	mov    $0x0,%ecx
  80180b:	b8 11 00 00 00       	mov    $0x11,%eax
  801810:	8b 55 08             	mov    0x8(%ebp),%edx
  801813:	89 cb                	mov    %ecx,%ebx
  801815:	89 cf                	mov    %ecx,%edi
  801817:	89 ce                	mov    %ecx,%esi
  801819:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80181b:	85 c0                	test   %eax,%eax
  80181d:	7e 17                	jle    801836 <sys_get_mac_address+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80181f:	83 ec 0c             	sub    $0xc,%esp
  801822:	50                   	push   %eax
  801823:	6a 11                	push   $0x11
  801825:	68 cf 3c 80 00       	push   $0x803ccf
  80182a:	6a 23                	push   $0x23
  80182c:	68 ec 3c 80 00       	push   $0x803cec
  801831:	e8 df f1 ff ff       	call   800a15 <_panic>
int
sys_get_mac_address(void *buf)
{
	return syscall(SYS_get_mac_address, 1,
		(uint32_t) buf, 0, 0, 0, 0);
}
  801836:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801839:	5b                   	pop    %ebx
  80183a:	5e                   	pop    %esi
  80183b:	5f                   	pop    %edi
  80183c:	5d                   	pop    %ebp
  80183d:	c3                   	ret    

0080183e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	53                   	push   %ebx
  801842:	83 ec 04             	sub    $0x4,%esp
  801845:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801848:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  80184a:	89 da                	mov    %ebx,%edx
  80184c:	c1 ea 0c             	shr    $0xc,%edx
	pte_t pte = uvpt[pn];
  80184f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  801856:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80185a:	74 05                	je     801861 <pgfault+0x23>
  80185c:	f6 c6 08             	test   $0x8,%dh
  80185f:	75 14                	jne    801875 <pgfault+0x37>
		panic("fork pgfault handler: does not handle this fault");
  801861:	83 ec 04             	sub    $0x4,%esp
  801864:	68 fc 3c 80 00       	push   $0x803cfc
  801869:	6a 1f                	push   $0x1f
  80186b:	68 2d 3d 80 00       	push   $0x803d2d
  801870:	e8 a0 f1 ff ff       	call   800a15 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  801875:	83 ec 04             	sub    $0x4,%esp
  801878:	6a 07                	push   $0x7
  80187a:	68 00 f0 7f 00       	push   $0x7ff000
  80187f:	6a 00                	push   $0x0
  801881:	e8 e3 fc ff ff       	call   801569 <sys_page_alloc>
  801886:	83 c4 10             	add    $0x10,%esp
  801889:	85 c0                	test   %eax,%eax
  80188b:	79 12                	jns    80189f <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  80188d:	50                   	push   %eax
  80188e:	68 38 3d 80 00       	push   $0x803d38
  801893:	6a 2b                	push   $0x2b
  801895:	68 2d 3d 80 00       	push   $0x803d2d
  80189a:	e8 76 f1 ff ff       	call   800a15 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  80189f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  8018a5:	83 ec 04             	sub    $0x4,%esp
  8018a8:	68 00 10 00 00       	push   $0x1000
  8018ad:	53                   	push   %ebx
  8018ae:	68 00 f0 7f 00       	push   $0x7ff000
  8018b3:	e8 40 fa ff ff       	call   8012f8 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  8018b8:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8018bf:	53                   	push   %ebx
  8018c0:	6a 00                	push   $0x0
  8018c2:	68 00 f0 7f 00       	push   $0x7ff000
  8018c7:	6a 00                	push   $0x0
  8018c9:	e8 de fc ff ff       	call   8015ac <sys_page_map>
  8018ce:	83 c4 20             	add    $0x20,%esp
  8018d1:	85 c0                	test   %eax,%eax
  8018d3:	79 12                	jns    8018e7 <pgfault+0xa9>
		panic("sys_page_map: %e", r);
  8018d5:	50                   	push   %eax
  8018d6:	68 4b 3d 80 00       	push   $0x803d4b
  8018db:	6a 33                	push   $0x33
  8018dd:	68 2d 3d 80 00       	push   $0x803d2d
  8018e2:	e8 2e f1 ff ff       	call   800a15 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  8018e7:	83 ec 08             	sub    $0x8,%esp
  8018ea:	68 00 f0 7f 00       	push   $0x7ff000
  8018ef:	6a 00                	push   $0x0
  8018f1:	e8 f8 fc ff ff       	call   8015ee <sys_page_unmap>
  8018f6:	83 c4 10             	add    $0x10,%esp
  8018f9:	85 c0                	test   %eax,%eax
  8018fb:	79 12                	jns    80190f <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  8018fd:	50                   	push   %eax
  8018fe:	68 5c 3d 80 00       	push   $0x803d5c
  801903:	6a 37                	push   $0x37
  801905:	68 2d 3d 80 00       	push   $0x803d2d
  80190a:	e8 06 f1 ff ff       	call   800a15 <_panic>
}
  80190f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801912:	c9                   	leave  
  801913:	c3                   	ret    

00801914 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	57                   	push   %edi
  801918:	56                   	push   %esi
  801919:	53                   	push   %ebx
  80191a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  80191d:	68 3e 18 80 00       	push   $0x80183e
  801922:	e8 22 1a 00 00       	call   803349 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801927:	b8 07 00 00 00       	mov    $0x7,%eax
  80192c:	cd 30                	int    $0x30
  80192e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801931:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Create child
	envid_t envid = sys_exofork();
	if (envid < 0) {
  801934:	83 c4 10             	add    $0x10,%esp
  801937:	85 c0                	test   %eax,%eax
  801939:	79 15                	jns    801950 <fork+0x3c>
		panic("sys_exofork: %e", envid);
  80193b:	50                   	push   %eax
  80193c:	68 6f 3d 80 00       	push   $0x803d6f
  801941:	68 93 00 00 00       	push   $0x93
  801946:	68 2d 3d 80 00       	push   $0x803d2d
  80194b:	e8 c5 f0 ff ff       	call   800a15 <_panic>
		return envid;
	}

	// If we are the child, fix thisenv.
	if (envid == 0) {
  801950:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801954:	75 21                	jne    801977 <fork+0x63>
		thisenv = &envs[ENVX(sys_getenvid())];
  801956:	e8 d0 fb ff ff       	call   80152b <sys_getenvid>
  80195b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801960:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801963:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801968:	a3 28 54 80 00       	mov    %eax,0x805428
		return 0;
  80196d:	b8 00 00 00 00       	mov    $0x0,%eax
  801972:	e9 5a 01 00 00       	jmp    801ad1 <fork+0x1bd>
	// We are the parent!
	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle the
	// fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), PTE_P | PTE_U | PTE_W);
  801977:	83 ec 04             	sub    $0x4,%esp
  80197a:	6a 07                	push   $0x7
  80197c:	68 00 f0 bf ee       	push   $0xeebff000
  801981:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801984:	57                   	push   %edi
  801985:	e8 df fb ff ff       	call   801569 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  80198a:	83 c4 08             	add    $0x8,%esp
  80198d:	68 8e 33 80 00       	push   $0x80338e
  801992:	57                   	push   %edi
  801993:	e8 1c fd ff ff       	call   8016b4 <sys_env_set_pgfault_upcall>
  801998:	83 c4 10             	add    $0x10,%esp

	// Copy our address space to child. Be careful not to copy the exception
	// stack too, so go until USTACKTOP instead of UTOP.
	unsigned pn;
	for (pn = UTEXT/PGSIZE; pn < USTACKTOP/PGSIZE; pn++) {
  80199b:	bb 00 08 00 00       	mov    $0x800,%ebx
static int
duppage(envid_t envid, unsigned pn)
{
	// Check if the page table that contains the PTE we want is allocated
	// using UVPD. If it is not, just don't map anything, and silently succeed.
	if (!(uvpd[pn/NPTENTRIES] & PTE_P))
  8019a0:	89 d8                	mov    %ebx,%eax
  8019a2:	c1 e8 0a             	shr    $0xa,%eax
  8019a5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019ac:	a8 01                	test   $0x1,%al
  8019ae:	0f 84 e2 00 00 00    	je     801a96 <fork+0x182>
		return 0;

	// Retrieve the PTE using UVPT
	pte_t pte = uvpt[pn];
  8019b4:	8b 34 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%esi

	// If the page is present, duplicate according to it's permissions
	if (pte & PTE_P) {
  8019bb:	f7 c6 01 00 00 00    	test   $0x1,%esi
  8019c1:	0f 84 cf 00 00 00    	je     801a96 <fork+0x182>
		int r;
		uint32_t perm = pte & PTE_SYSCALL;
  8019c7:	89 f0                	mov    %esi,%eax
  8019c9:	25 07 0e 00 00       	and    $0xe07,%eax
  8019ce:	89 df                	mov    %ebx,%edi
  8019d0:	c1 e7 0c             	shl    $0xc,%edi
		void *va = (void *) (pn * PGSIZE);

		// If PTE_SHARE is enabled, share it by just copying the
		// pte, which can be done by mapping on the same address
		// with the same permissions, even if it is writable
		if (pte & PTE_SHARE) {
  8019d3:	f7 c6 00 04 00 00    	test   $0x400,%esi
  8019d9:	74 2d                	je     801a08 <fork+0xf4>
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  8019db:	83 ec 0c             	sub    $0xc,%esp
  8019de:	50                   	push   %eax
  8019df:	57                   	push   %edi
  8019e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019e3:	57                   	push   %edi
  8019e4:	6a 00                	push   $0x0
  8019e6:	e8 c1 fb ff ff       	call   8015ac <sys_page_map>
  8019eb:	83 c4 20             	add    $0x20,%esp
  8019ee:	85 c0                	test   %eax,%eax
  8019f0:	0f 89 a0 00 00 00    	jns    801a96 <fork+0x182>
				panic("sys_page_map: %e", r);
  8019f6:	50                   	push   %eax
  8019f7:	68 4b 3d 80 00       	push   $0x803d4b
  8019fc:	6a 5c                	push   $0x5c
  8019fe:	68 2d 3d 80 00       	push   $0x803d2d
  801a03:	e8 0d f0 ff ff       	call   800a15 <_panic>
				return r;
			}
		// If writable or COW, make it COW on parent and child
		} else if (pte & (PTE_W | PTE_COW)) {
  801a08:	f7 c6 02 08 00 00    	test   $0x802,%esi
  801a0e:	74 5d                	je     801a6d <fork+0x159>
			perm &= ~PTE_W;  // Remove PTE_W, so it faults
  801a10:	81 e6 05 0e 00 00    	and    $0xe05,%esi
			perm |= PTE_COW; // Make it PTE_COW
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  801a16:	81 ce 00 08 00 00    	or     $0x800,%esi
  801a1c:	83 ec 0c             	sub    $0xc,%esp
  801a1f:	56                   	push   %esi
  801a20:	57                   	push   %edi
  801a21:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a24:	57                   	push   %edi
  801a25:	6a 00                	push   $0x0
  801a27:	e8 80 fb ff ff       	call   8015ac <sys_page_map>
  801a2c:	83 c4 20             	add    $0x20,%esp
  801a2f:	85 c0                	test   %eax,%eax
  801a31:	79 12                	jns    801a45 <fork+0x131>
				panic("sys_page_map: %e", r);
  801a33:	50                   	push   %eax
  801a34:	68 4b 3d 80 00       	push   $0x803d4b
  801a39:	6a 65                	push   $0x65
  801a3b:	68 2d 3d 80 00       	push   $0x803d2d
  801a40:	e8 d0 ef ff ff       	call   800a15 <_panic>
				return r;
			}
			// Change the permission on parent, mapping on itself
			if ((r = sys_page_map(0, va, 0, va, perm)) < 0) {
  801a45:	83 ec 0c             	sub    $0xc,%esp
  801a48:	56                   	push   %esi
  801a49:	57                   	push   %edi
  801a4a:	6a 00                	push   $0x0
  801a4c:	57                   	push   %edi
  801a4d:	6a 00                	push   $0x0
  801a4f:	e8 58 fb ff ff       	call   8015ac <sys_page_map>
  801a54:	83 c4 20             	add    $0x20,%esp
  801a57:	85 c0                	test   %eax,%eax
  801a59:	79 3b                	jns    801a96 <fork+0x182>
				panic("sys_page_map: %e", r);
  801a5b:	50                   	push   %eax
  801a5c:	68 4b 3d 80 00       	push   $0x803d4b
  801a61:	6a 6a                	push   $0x6a
  801a63:	68 2d 3d 80 00       	push   $0x803d2d
  801a68:	e8 a8 ef ff ff       	call   800a15 <_panic>
				return r;
			}
		// If it is read-only, just share it.
		} else {
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  801a6d:	83 ec 0c             	sub    $0xc,%esp
  801a70:	50                   	push   %eax
  801a71:	57                   	push   %edi
  801a72:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a75:	57                   	push   %edi
  801a76:	6a 00                	push   $0x0
  801a78:	e8 2f fb ff ff       	call   8015ac <sys_page_map>
  801a7d:	83 c4 20             	add    $0x20,%esp
  801a80:	85 c0                	test   %eax,%eax
  801a82:	79 12                	jns    801a96 <fork+0x182>
				panic("sys_page_map: %e", r);
  801a84:	50                   	push   %eax
  801a85:	68 4b 3d 80 00       	push   $0x803d4b
  801a8a:	6a 71                	push   $0x71
  801a8c:	68 2d 3d 80 00       	push   $0x803d2d
  801a91:	e8 7f ef ff ff       	call   800a15 <_panic>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);

	// Copy our address space to child. Be careful not to copy the exception
	// stack too, so go until USTACKTOP instead of UTOP.
	unsigned pn;
	for (pn = UTEXT/PGSIZE; pn < USTACKTOP/PGSIZE; pn++) {
  801a96:	83 c3 01             	add    $0x1,%ebx
  801a99:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801a9f:	0f 85 fb fe ff ff    	jne    8019a0 <fork+0x8c>
		duppage(envid, pn);
	}

	// Make the child runnable
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801aa5:	83 ec 08             	sub    $0x8,%esp
  801aa8:	6a 02                	push   $0x2
  801aaa:	ff 75 e0             	pushl  -0x20(%ebp)
  801aad:	e8 7e fb ff ff       	call   801630 <sys_env_set_status>
  801ab2:	83 c4 10             	add    $0x10,%esp
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	79 15                	jns    801ace <fork+0x1ba>
		panic("sys_env_set_status: %e", r);
  801ab9:	50                   	push   %eax
  801aba:	68 7f 3d 80 00       	push   $0x803d7f
  801abf:	68 af 00 00 00       	push   $0xaf
  801ac4:	68 2d 3d 80 00       	push   $0x803d2d
  801ac9:	e8 47 ef ff ff       	call   800a15 <_panic>
		return r;
	}

	return envid;
  801ace:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  801ad1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad4:	5b                   	pop    %ebx
  801ad5:	5e                   	pop    %esi
  801ad6:	5f                   	pop    %edi
  801ad7:	5d                   	pop    %ebp
  801ad8:	c3                   	ret    

00801ad9 <sfork>:

// Challenge!
int
sfork(void)
{
  801ad9:	55                   	push   %ebp
  801ada:	89 e5                	mov    %esp,%ebp
  801adc:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801adf:	68 96 3d 80 00       	push   $0x803d96
  801ae4:	68 ba 00 00 00       	push   $0xba
  801ae9:	68 2d 3d 80 00       	push   $0x803d2d
  801aee:	e8 22 ef ff ff       	call   800a15 <_panic>

00801af3 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	8b 55 08             	mov    0x8(%ebp),%edx
  801af9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801afc:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801aff:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801b01:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801b04:	83 3a 01             	cmpl   $0x1,(%edx)
  801b07:	7e 09                	jle    801b12 <argstart+0x1f>
  801b09:	ba a1 37 80 00       	mov    $0x8037a1,%edx
  801b0e:	85 c9                	test   %ecx,%ecx
  801b10:	75 05                	jne    801b17 <argstart+0x24>
  801b12:	ba 00 00 00 00       	mov    $0x0,%edx
  801b17:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801b1a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801b21:	5d                   	pop    %ebp
  801b22:	c3                   	ret    

00801b23 <argnext>:

int
argnext(struct Argstate *args)
{
  801b23:	55                   	push   %ebp
  801b24:	89 e5                	mov    %esp,%ebp
  801b26:	53                   	push   %ebx
  801b27:	83 ec 04             	sub    $0x4,%esp
  801b2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801b2d:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801b34:	8b 43 08             	mov    0x8(%ebx),%eax
  801b37:	85 c0                	test   %eax,%eax
  801b39:	74 6f                	je     801baa <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801b3b:	80 38 00             	cmpb   $0x0,(%eax)
  801b3e:	75 4e                	jne    801b8e <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801b40:	8b 0b                	mov    (%ebx),%ecx
  801b42:	83 39 01             	cmpl   $0x1,(%ecx)
  801b45:	74 55                	je     801b9c <argnext+0x79>
		    || args->argv[1][0] != '-'
  801b47:	8b 53 04             	mov    0x4(%ebx),%edx
  801b4a:	8b 42 04             	mov    0x4(%edx),%eax
  801b4d:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b50:	75 4a                	jne    801b9c <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801b52:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b56:	74 44                	je     801b9c <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801b58:	83 c0 01             	add    $0x1,%eax
  801b5b:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b5e:	83 ec 04             	sub    $0x4,%esp
  801b61:	8b 01                	mov    (%ecx),%eax
  801b63:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801b6a:	50                   	push   %eax
  801b6b:	8d 42 08             	lea    0x8(%edx),%eax
  801b6e:	50                   	push   %eax
  801b6f:	83 c2 04             	add    $0x4,%edx
  801b72:	52                   	push   %edx
  801b73:	e8 80 f7 ff ff       	call   8012f8 <memmove>
		(*args->argc)--;
  801b78:	8b 03                	mov    (%ebx),%eax
  801b7a:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801b7d:	8b 43 08             	mov    0x8(%ebx),%eax
  801b80:	83 c4 10             	add    $0x10,%esp
  801b83:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b86:	75 06                	jne    801b8e <argnext+0x6b>
  801b88:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801b8c:	74 0e                	je     801b9c <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801b8e:	8b 53 08             	mov    0x8(%ebx),%edx
  801b91:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801b94:	83 c2 01             	add    $0x1,%edx
  801b97:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801b9a:	eb 13                	jmp    801baf <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801b9c:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801ba3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ba8:	eb 05                	jmp    801baf <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801baa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801baf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb2:	c9                   	leave  
  801bb3:	c3                   	ret    

00801bb4 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	53                   	push   %ebx
  801bb8:	83 ec 04             	sub    $0x4,%esp
  801bbb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801bbe:	8b 43 08             	mov    0x8(%ebx),%eax
  801bc1:	85 c0                	test   %eax,%eax
  801bc3:	74 58                	je     801c1d <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801bc5:	80 38 00             	cmpb   $0x0,(%eax)
  801bc8:	74 0c                	je     801bd6 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801bca:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801bcd:	c7 43 08 a1 37 80 00 	movl   $0x8037a1,0x8(%ebx)
  801bd4:	eb 42                	jmp    801c18 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801bd6:	8b 13                	mov    (%ebx),%edx
  801bd8:	83 3a 01             	cmpl   $0x1,(%edx)
  801bdb:	7e 2d                	jle    801c0a <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801bdd:	8b 43 04             	mov    0x4(%ebx),%eax
  801be0:	8b 48 04             	mov    0x4(%eax),%ecx
  801be3:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801be6:	83 ec 04             	sub    $0x4,%esp
  801be9:	8b 12                	mov    (%edx),%edx
  801beb:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801bf2:	52                   	push   %edx
  801bf3:	8d 50 08             	lea    0x8(%eax),%edx
  801bf6:	52                   	push   %edx
  801bf7:	83 c0 04             	add    $0x4,%eax
  801bfa:	50                   	push   %eax
  801bfb:	e8 f8 f6 ff ff       	call   8012f8 <memmove>
		(*args->argc)--;
  801c00:	8b 03                	mov    (%ebx),%eax
  801c02:	83 28 01             	subl   $0x1,(%eax)
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	eb 0e                	jmp    801c18 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801c0a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801c11:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801c18:	8b 43 0c             	mov    0xc(%ebx),%eax
  801c1b:	eb 05                	jmp    801c22 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801c1d:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801c22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c25:	c9                   	leave  
  801c26:	c3                   	ret    

00801c27 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
  801c2a:	83 ec 08             	sub    $0x8,%esp
  801c2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801c30:	8b 51 0c             	mov    0xc(%ecx),%edx
  801c33:	89 d0                	mov    %edx,%eax
  801c35:	85 d2                	test   %edx,%edx
  801c37:	75 0c                	jne    801c45 <argvalue+0x1e>
  801c39:	83 ec 0c             	sub    $0xc,%esp
  801c3c:	51                   	push   %ecx
  801c3d:	e8 72 ff ff ff       	call   801bb4 <argnextvalue>
  801c42:	83 c4 10             	add    $0x10,%esp
}
  801c45:	c9                   	leave  
  801c46:	c3                   	ret    

00801c47 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4d:	05 00 00 00 30       	add    $0x30000000,%eax
  801c52:	c1 e8 0c             	shr    $0xc,%eax
}
  801c55:	5d                   	pop    %ebp
  801c56:	c3                   	ret    

00801c57 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801c57:	55                   	push   %ebp
  801c58:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5d:	05 00 00 00 30       	add    $0x30000000,%eax
  801c62:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801c67:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801c6c:	5d                   	pop    %ebp
  801c6d:	c3                   	ret    

00801c6e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801c6e:	55                   	push   %ebp
  801c6f:	89 e5                	mov    %esp,%ebp
  801c71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c74:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801c79:	89 c2                	mov    %eax,%edx
  801c7b:	c1 ea 16             	shr    $0x16,%edx
  801c7e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c85:	f6 c2 01             	test   $0x1,%dl
  801c88:	74 11                	je     801c9b <fd_alloc+0x2d>
  801c8a:	89 c2                	mov    %eax,%edx
  801c8c:	c1 ea 0c             	shr    $0xc,%edx
  801c8f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c96:	f6 c2 01             	test   $0x1,%dl
  801c99:	75 09                	jne    801ca4 <fd_alloc+0x36>
			*fd_store = fd;
  801c9b:	89 01                	mov    %eax,(%ecx)
			return 0;
  801c9d:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca2:	eb 17                	jmp    801cbb <fd_alloc+0x4d>
  801ca4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801ca9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801cae:	75 c9                	jne    801c79 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801cb0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801cb6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801cbb:	5d                   	pop    %ebp
  801cbc:	c3                   	ret    

00801cbd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801cbd:	55                   	push   %ebp
  801cbe:	89 e5                	mov    %esp,%ebp
  801cc0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801cc3:	83 f8 1f             	cmp    $0x1f,%eax
  801cc6:	77 36                	ja     801cfe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801cc8:	c1 e0 0c             	shl    $0xc,%eax
  801ccb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801cd0:	89 c2                	mov    %eax,%edx
  801cd2:	c1 ea 16             	shr    $0x16,%edx
  801cd5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cdc:	f6 c2 01             	test   $0x1,%dl
  801cdf:	74 24                	je     801d05 <fd_lookup+0x48>
  801ce1:	89 c2                	mov    %eax,%edx
  801ce3:	c1 ea 0c             	shr    $0xc,%edx
  801ce6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801ced:	f6 c2 01             	test   $0x1,%dl
  801cf0:	74 1a                	je     801d0c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801cf2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cf5:	89 02                	mov    %eax,(%edx)
	return 0;
  801cf7:	b8 00 00 00 00       	mov    $0x0,%eax
  801cfc:	eb 13                	jmp    801d11 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801cfe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d03:	eb 0c                	jmp    801d11 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801d05:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d0a:	eb 05                	jmp    801d11 <fd_lookup+0x54>
  801d0c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801d11:	5d                   	pop    %ebp
  801d12:	c3                   	ret    

00801d13 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	83 ec 08             	sub    $0x8,%esp
  801d19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d1c:	ba 28 3e 80 00       	mov    $0x803e28,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801d21:	eb 13                	jmp    801d36 <dev_lookup+0x23>
  801d23:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801d26:	39 08                	cmp    %ecx,(%eax)
  801d28:	75 0c                	jne    801d36 <dev_lookup+0x23>
			*dev = devtab[i];
  801d2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d2d:	89 01                	mov    %eax,(%ecx)
			return 0;
  801d2f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d34:	eb 2e                	jmp    801d64 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801d36:	8b 02                	mov    (%edx),%eax
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	75 e7                	jne    801d23 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801d3c:	a1 28 54 80 00       	mov    0x805428,%eax
  801d41:	8b 40 48             	mov    0x48(%eax),%eax
  801d44:	83 ec 04             	sub    $0x4,%esp
  801d47:	51                   	push   %ecx
  801d48:	50                   	push   %eax
  801d49:	68 ac 3d 80 00       	push   $0x803dac
  801d4e:	e8 9b ed ff ff       	call   800aee <cprintf>
	*dev = 0;
  801d53:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d56:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801d5c:	83 c4 10             	add    $0x10,%esp
  801d5f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801d64:	c9                   	leave  
  801d65:	c3                   	ret    

00801d66 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801d66:	55                   	push   %ebp
  801d67:	89 e5                	mov    %esp,%ebp
  801d69:	56                   	push   %esi
  801d6a:	53                   	push   %ebx
  801d6b:	83 ec 10             	sub    $0x10,%esp
  801d6e:	8b 75 08             	mov    0x8(%ebp),%esi
  801d71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d77:	50                   	push   %eax
  801d78:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801d7e:	c1 e8 0c             	shr    $0xc,%eax
  801d81:	50                   	push   %eax
  801d82:	e8 36 ff ff ff       	call   801cbd <fd_lookup>
  801d87:	83 c4 08             	add    $0x8,%esp
  801d8a:	85 c0                	test   %eax,%eax
  801d8c:	78 05                	js     801d93 <fd_close+0x2d>
	    || fd != fd2)
  801d8e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801d91:	74 0c                	je     801d9f <fd_close+0x39>
		return (must_exist ? r : 0);
  801d93:	84 db                	test   %bl,%bl
  801d95:	ba 00 00 00 00       	mov    $0x0,%edx
  801d9a:	0f 44 c2             	cmove  %edx,%eax
  801d9d:	eb 41                	jmp    801de0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d9f:	83 ec 08             	sub    $0x8,%esp
  801da2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801da5:	50                   	push   %eax
  801da6:	ff 36                	pushl  (%esi)
  801da8:	e8 66 ff ff ff       	call   801d13 <dev_lookup>
  801dad:	89 c3                	mov    %eax,%ebx
  801daf:	83 c4 10             	add    $0x10,%esp
  801db2:	85 c0                	test   %eax,%eax
  801db4:	78 1a                	js     801dd0 <fd_close+0x6a>
		if (dev->dev_close)
  801db6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801db9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801dbc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801dc1:	85 c0                	test   %eax,%eax
  801dc3:	74 0b                	je     801dd0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801dc5:	83 ec 0c             	sub    $0xc,%esp
  801dc8:	56                   	push   %esi
  801dc9:	ff d0                	call   *%eax
  801dcb:	89 c3                	mov    %eax,%ebx
  801dcd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801dd0:	83 ec 08             	sub    $0x8,%esp
  801dd3:	56                   	push   %esi
  801dd4:	6a 00                	push   $0x0
  801dd6:	e8 13 f8 ff ff       	call   8015ee <sys_page_unmap>
	return r;
  801ddb:	83 c4 10             	add    $0x10,%esp
  801dde:	89 d8                	mov    %ebx,%eax
}
  801de0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801de3:	5b                   	pop    %ebx
  801de4:	5e                   	pop    %esi
  801de5:	5d                   	pop    %ebp
  801de6:	c3                   	ret    

00801de7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ded:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df0:	50                   	push   %eax
  801df1:	ff 75 08             	pushl  0x8(%ebp)
  801df4:	e8 c4 fe ff ff       	call   801cbd <fd_lookup>
  801df9:	83 c4 08             	add    $0x8,%esp
  801dfc:	85 c0                	test   %eax,%eax
  801dfe:	78 10                	js     801e10 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801e00:	83 ec 08             	sub    $0x8,%esp
  801e03:	6a 01                	push   $0x1
  801e05:	ff 75 f4             	pushl  -0xc(%ebp)
  801e08:	e8 59 ff ff ff       	call   801d66 <fd_close>
  801e0d:	83 c4 10             	add    $0x10,%esp
}
  801e10:	c9                   	leave  
  801e11:	c3                   	ret    

00801e12 <close_all>:

void
close_all(void)
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	53                   	push   %ebx
  801e16:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801e19:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801e1e:	83 ec 0c             	sub    $0xc,%esp
  801e21:	53                   	push   %ebx
  801e22:	e8 c0 ff ff ff       	call   801de7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801e27:	83 c3 01             	add    $0x1,%ebx
  801e2a:	83 c4 10             	add    $0x10,%esp
  801e2d:	83 fb 20             	cmp    $0x20,%ebx
  801e30:	75 ec                	jne    801e1e <close_all+0xc>
		close(i);
}
  801e32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e35:	c9                   	leave  
  801e36:	c3                   	ret    

00801e37 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801e37:	55                   	push   %ebp
  801e38:	89 e5                	mov    %esp,%ebp
  801e3a:	57                   	push   %edi
  801e3b:	56                   	push   %esi
  801e3c:	53                   	push   %ebx
  801e3d:	83 ec 2c             	sub    $0x2c,%esp
  801e40:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801e43:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e46:	50                   	push   %eax
  801e47:	ff 75 08             	pushl  0x8(%ebp)
  801e4a:	e8 6e fe ff ff       	call   801cbd <fd_lookup>
  801e4f:	83 c4 08             	add    $0x8,%esp
  801e52:	85 c0                	test   %eax,%eax
  801e54:	0f 88 c1 00 00 00    	js     801f1b <dup+0xe4>
		return r;
	close(newfdnum);
  801e5a:	83 ec 0c             	sub    $0xc,%esp
  801e5d:	56                   	push   %esi
  801e5e:	e8 84 ff ff ff       	call   801de7 <close>

	newfd = INDEX2FD(newfdnum);
  801e63:	89 f3                	mov    %esi,%ebx
  801e65:	c1 e3 0c             	shl    $0xc,%ebx
  801e68:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801e6e:	83 c4 04             	add    $0x4,%esp
  801e71:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e74:	e8 de fd ff ff       	call   801c57 <fd2data>
  801e79:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801e7b:	89 1c 24             	mov    %ebx,(%esp)
  801e7e:	e8 d4 fd ff ff       	call   801c57 <fd2data>
  801e83:	83 c4 10             	add    $0x10,%esp
  801e86:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801e89:	89 f8                	mov    %edi,%eax
  801e8b:	c1 e8 16             	shr    $0x16,%eax
  801e8e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e95:	a8 01                	test   $0x1,%al
  801e97:	74 37                	je     801ed0 <dup+0x99>
  801e99:	89 f8                	mov    %edi,%eax
  801e9b:	c1 e8 0c             	shr    $0xc,%eax
  801e9e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801ea5:	f6 c2 01             	test   $0x1,%dl
  801ea8:	74 26                	je     801ed0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801eaa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801eb1:	83 ec 0c             	sub    $0xc,%esp
  801eb4:	25 07 0e 00 00       	and    $0xe07,%eax
  801eb9:	50                   	push   %eax
  801eba:	ff 75 d4             	pushl  -0x2c(%ebp)
  801ebd:	6a 00                	push   $0x0
  801ebf:	57                   	push   %edi
  801ec0:	6a 00                	push   $0x0
  801ec2:	e8 e5 f6 ff ff       	call   8015ac <sys_page_map>
  801ec7:	89 c7                	mov    %eax,%edi
  801ec9:	83 c4 20             	add    $0x20,%esp
  801ecc:	85 c0                	test   %eax,%eax
  801ece:	78 2e                	js     801efe <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801ed0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801ed3:	89 d0                	mov    %edx,%eax
  801ed5:	c1 e8 0c             	shr    $0xc,%eax
  801ed8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801edf:	83 ec 0c             	sub    $0xc,%esp
  801ee2:	25 07 0e 00 00       	and    $0xe07,%eax
  801ee7:	50                   	push   %eax
  801ee8:	53                   	push   %ebx
  801ee9:	6a 00                	push   $0x0
  801eeb:	52                   	push   %edx
  801eec:	6a 00                	push   $0x0
  801eee:	e8 b9 f6 ff ff       	call   8015ac <sys_page_map>
  801ef3:	89 c7                	mov    %eax,%edi
  801ef5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801ef8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801efa:	85 ff                	test   %edi,%edi
  801efc:	79 1d                	jns    801f1b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801efe:	83 ec 08             	sub    $0x8,%esp
  801f01:	53                   	push   %ebx
  801f02:	6a 00                	push   $0x0
  801f04:	e8 e5 f6 ff ff       	call   8015ee <sys_page_unmap>
	sys_page_unmap(0, nva);
  801f09:	83 c4 08             	add    $0x8,%esp
  801f0c:	ff 75 d4             	pushl  -0x2c(%ebp)
  801f0f:	6a 00                	push   $0x0
  801f11:	e8 d8 f6 ff ff       	call   8015ee <sys_page_unmap>
	return r;
  801f16:	83 c4 10             	add    $0x10,%esp
  801f19:	89 f8                	mov    %edi,%eax
}
  801f1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f1e:	5b                   	pop    %ebx
  801f1f:	5e                   	pop    %esi
  801f20:	5f                   	pop    %edi
  801f21:	5d                   	pop    %ebp
  801f22:	c3                   	ret    

00801f23 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801f23:	55                   	push   %ebp
  801f24:	89 e5                	mov    %esp,%ebp
  801f26:	53                   	push   %ebx
  801f27:	83 ec 14             	sub    $0x14,%esp
  801f2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f2d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f30:	50                   	push   %eax
  801f31:	53                   	push   %ebx
  801f32:	e8 86 fd ff ff       	call   801cbd <fd_lookup>
  801f37:	83 c4 08             	add    $0x8,%esp
  801f3a:	89 c2                	mov    %eax,%edx
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	78 6d                	js     801fad <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f40:	83 ec 08             	sub    $0x8,%esp
  801f43:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f46:	50                   	push   %eax
  801f47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f4a:	ff 30                	pushl  (%eax)
  801f4c:	e8 c2 fd ff ff       	call   801d13 <dev_lookup>
  801f51:	83 c4 10             	add    $0x10,%esp
  801f54:	85 c0                	test   %eax,%eax
  801f56:	78 4c                	js     801fa4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801f58:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f5b:	8b 42 08             	mov    0x8(%edx),%eax
  801f5e:	83 e0 03             	and    $0x3,%eax
  801f61:	83 f8 01             	cmp    $0x1,%eax
  801f64:	75 21                	jne    801f87 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801f66:	a1 28 54 80 00       	mov    0x805428,%eax
  801f6b:	8b 40 48             	mov    0x48(%eax),%eax
  801f6e:	83 ec 04             	sub    $0x4,%esp
  801f71:	53                   	push   %ebx
  801f72:	50                   	push   %eax
  801f73:	68 ed 3d 80 00       	push   $0x803ded
  801f78:	e8 71 eb ff ff       	call   800aee <cprintf>
		return -E_INVAL;
  801f7d:	83 c4 10             	add    $0x10,%esp
  801f80:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801f85:	eb 26                	jmp    801fad <read+0x8a>
	}
	if (!dev->dev_read)
  801f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8a:	8b 40 08             	mov    0x8(%eax),%eax
  801f8d:	85 c0                	test   %eax,%eax
  801f8f:	74 17                	je     801fa8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801f91:	83 ec 04             	sub    $0x4,%esp
  801f94:	ff 75 10             	pushl  0x10(%ebp)
  801f97:	ff 75 0c             	pushl  0xc(%ebp)
  801f9a:	52                   	push   %edx
  801f9b:	ff d0                	call   *%eax
  801f9d:	89 c2                	mov    %eax,%edx
  801f9f:	83 c4 10             	add    $0x10,%esp
  801fa2:	eb 09                	jmp    801fad <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fa4:	89 c2                	mov    %eax,%edx
  801fa6:	eb 05                	jmp    801fad <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801fa8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801fad:	89 d0                	mov    %edx,%eax
  801faf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fb2:	c9                   	leave  
  801fb3:	c3                   	ret    

00801fb4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801fb4:	55                   	push   %ebp
  801fb5:	89 e5                	mov    %esp,%ebp
  801fb7:	57                   	push   %edi
  801fb8:	56                   	push   %esi
  801fb9:	53                   	push   %ebx
  801fba:	83 ec 0c             	sub    $0xc,%esp
  801fbd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fc0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801fc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fc8:	eb 21                	jmp    801feb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801fca:	83 ec 04             	sub    $0x4,%esp
  801fcd:	89 f0                	mov    %esi,%eax
  801fcf:	29 d8                	sub    %ebx,%eax
  801fd1:	50                   	push   %eax
  801fd2:	89 d8                	mov    %ebx,%eax
  801fd4:	03 45 0c             	add    0xc(%ebp),%eax
  801fd7:	50                   	push   %eax
  801fd8:	57                   	push   %edi
  801fd9:	e8 45 ff ff ff       	call   801f23 <read>
		if (m < 0)
  801fde:	83 c4 10             	add    $0x10,%esp
  801fe1:	85 c0                	test   %eax,%eax
  801fe3:	78 10                	js     801ff5 <readn+0x41>
			return m;
		if (m == 0)
  801fe5:	85 c0                	test   %eax,%eax
  801fe7:	74 0a                	je     801ff3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801fe9:	01 c3                	add    %eax,%ebx
  801feb:	39 f3                	cmp    %esi,%ebx
  801fed:	72 db                	jb     801fca <readn+0x16>
  801fef:	89 d8                	mov    %ebx,%eax
  801ff1:	eb 02                	jmp    801ff5 <readn+0x41>
  801ff3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801ff5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ff8:	5b                   	pop    %ebx
  801ff9:	5e                   	pop    %esi
  801ffa:	5f                   	pop    %edi
  801ffb:	5d                   	pop    %ebp
  801ffc:	c3                   	ret    

00801ffd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801ffd:	55                   	push   %ebp
  801ffe:	89 e5                	mov    %esp,%ebp
  802000:	53                   	push   %ebx
  802001:	83 ec 14             	sub    $0x14,%esp
  802004:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802007:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80200a:	50                   	push   %eax
  80200b:	53                   	push   %ebx
  80200c:	e8 ac fc ff ff       	call   801cbd <fd_lookup>
  802011:	83 c4 08             	add    $0x8,%esp
  802014:	89 c2                	mov    %eax,%edx
  802016:	85 c0                	test   %eax,%eax
  802018:	78 68                	js     802082 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80201a:	83 ec 08             	sub    $0x8,%esp
  80201d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802020:	50                   	push   %eax
  802021:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802024:	ff 30                	pushl  (%eax)
  802026:	e8 e8 fc ff ff       	call   801d13 <dev_lookup>
  80202b:	83 c4 10             	add    $0x10,%esp
  80202e:	85 c0                	test   %eax,%eax
  802030:	78 47                	js     802079 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802032:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802035:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802039:	75 21                	jne    80205c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80203b:	a1 28 54 80 00       	mov    0x805428,%eax
  802040:	8b 40 48             	mov    0x48(%eax),%eax
  802043:	83 ec 04             	sub    $0x4,%esp
  802046:	53                   	push   %ebx
  802047:	50                   	push   %eax
  802048:	68 09 3e 80 00       	push   $0x803e09
  80204d:	e8 9c ea ff ff       	call   800aee <cprintf>
		return -E_INVAL;
  802052:	83 c4 10             	add    $0x10,%esp
  802055:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80205a:	eb 26                	jmp    802082 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80205c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80205f:	8b 52 0c             	mov    0xc(%edx),%edx
  802062:	85 d2                	test   %edx,%edx
  802064:	74 17                	je     80207d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802066:	83 ec 04             	sub    $0x4,%esp
  802069:	ff 75 10             	pushl  0x10(%ebp)
  80206c:	ff 75 0c             	pushl  0xc(%ebp)
  80206f:	50                   	push   %eax
  802070:	ff d2                	call   *%edx
  802072:	89 c2                	mov    %eax,%edx
  802074:	83 c4 10             	add    $0x10,%esp
  802077:	eb 09                	jmp    802082 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802079:	89 c2                	mov    %eax,%edx
  80207b:	eb 05                	jmp    802082 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80207d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802082:	89 d0                	mov    %edx,%eax
  802084:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802087:	c9                   	leave  
  802088:	c3                   	ret    

00802089 <seek>:

int
seek(int fdnum, off_t offset)
{
  802089:	55                   	push   %ebp
  80208a:	89 e5                	mov    %esp,%ebp
  80208c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80208f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802092:	50                   	push   %eax
  802093:	ff 75 08             	pushl  0x8(%ebp)
  802096:	e8 22 fc ff ff       	call   801cbd <fd_lookup>
  80209b:	83 c4 08             	add    $0x8,%esp
  80209e:	85 c0                	test   %eax,%eax
  8020a0:	78 0e                	js     8020b0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8020a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8020a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020a8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8020ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020b0:	c9                   	leave  
  8020b1:	c3                   	ret    

008020b2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8020b2:	55                   	push   %ebp
  8020b3:	89 e5                	mov    %esp,%ebp
  8020b5:	53                   	push   %ebx
  8020b6:	83 ec 14             	sub    $0x14,%esp
  8020b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8020bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020bf:	50                   	push   %eax
  8020c0:	53                   	push   %ebx
  8020c1:	e8 f7 fb ff ff       	call   801cbd <fd_lookup>
  8020c6:	83 c4 08             	add    $0x8,%esp
  8020c9:	89 c2                	mov    %eax,%edx
  8020cb:	85 c0                	test   %eax,%eax
  8020cd:	78 65                	js     802134 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020cf:	83 ec 08             	sub    $0x8,%esp
  8020d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d5:	50                   	push   %eax
  8020d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020d9:	ff 30                	pushl  (%eax)
  8020db:	e8 33 fc ff ff       	call   801d13 <dev_lookup>
  8020e0:	83 c4 10             	add    $0x10,%esp
  8020e3:	85 c0                	test   %eax,%eax
  8020e5:	78 44                	js     80212b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8020e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8020ee:	75 21                	jne    802111 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8020f0:	a1 28 54 80 00       	mov    0x805428,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8020f5:	8b 40 48             	mov    0x48(%eax),%eax
  8020f8:	83 ec 04             	sub    $0x4,%esp
  8020fb:	53                   	push   %ebx
  8020fc:	50                   	push   %eax
  8020fd:	68 cc 3d 80 00       	push   $0x803dcc
  802102:	e8 e7 e9 ff ff       	call   800aee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802107:	83 c4 10             	add    $0x10,%esp
  80210a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80210f:	eb 23                	jmp    802134 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802111:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802114:	8b 52 18             	mov    0x18(%edx),%edx
  802117:	85 d2                	test   %edx,%edx
  802119:	74 14                	je     80212f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80211b:	83 ec 08             	sub    $0x8,%esp
  80211e:	ff 75 0c             	pushl  0xc(%ebp)
  802121:	50                   	push   %eax
  802122:	ff d2                	call   *%edx
  802124:	89 c2                	mov    %eax,%edx
  802126:	83 c4 10             	add    $0x10,%esp
  802129:	eb 09                	jmp    802134 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80212b:	89 c2                	mov    %eax,%edx
  80212d:	eb 05                	jmp    802134 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80212f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802134:	89 d0                	mov    %edx,%eax
  802136:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802139:	c9                   	leave  
  80213a:	c3                   	ret    

0080213b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80213b:	55                   	push   %ebp
  80213c:	89 e5                	mov    %esp,%ebp
  80213e:	53                   	push   %ebx
  80213f:	83 ec 14             	sub    $0x14,%esp
  802142:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802145:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802148:	50                   	push   %eax
  802149:	ff 75 08             	pushl  0x8(%ebp)
  80214c:	e8 6c fb ff ff       	call   801cbd <fd_lookup>
  802151:	83 c4 08             	add    $0x8,%esp
  802154:	89 c2                	mov    %eax,%edx
  802156:	85 c0                	test   %eax,%eax
  802158:	78 58                	js     8021b2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80215a:	83 ec 08             	sub    $0x8,%esp
  80215d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802160:	50                   	push   %eax
  802161:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802164:	ff 30                	pushl  (%eax)
  802166:	e8 a8 fb ff ff       	call   801d13 <dev_lookup>
  80216b:	83 c4 10             	add    $0x10,%esp
  80216e:	85 c0                	test   %eax,%eax
  802170:	78 37                	js     8021a9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802172:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802175:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802179:	74 32                	je     8021ad <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80217b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80217e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802185:	00 00 00 
	stat->st_isdir = 0;
  802188:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80218f:	00 00 00 
	stat->st_dev = dev;
  802192:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802198:	83 ec 08             	sub    $0x8,%esp
  80219b:	53                   	push   %ebx
  80219c:	ff 75 f0             	pushl  -0x10(%ebp)
  80219f:	ff 50 14             	call   *0x14(%eax)
  8021a2:	89 c2                	mov    %eax,%edx
  8021a4:	83 c4 10             	add    $0x10,%esp
  8021a7:	eb 09                	jmp    8021b2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8021a9:	89 c2                	mov    %eax,%edx
  8021ab:	eb 05                	jmp    8021b2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8021ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8021b2:	89 d0                	mov    %edx,%eax
  8021b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021b7:	c9                   	leave  
  8021b8:	c3                   	ret    

008021b9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8021b9:	55                   	push   %ebp
  8021ba:	89 e5                	mov    %esp,%ebp
  8021bc:	56                   	push   %esi
  8021bd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8021be:	83 ec 08             	sub    $0x8,%esp
  8021c1:	6a 00                	push   $0x0
  8021c3:	ff 75 08             	pushl  0x8(%ebp)
  8021c6:	e8 0c 02 00 00       	call   8023d7 <open>
  8021cb:	89 c3                	mov    %eax,%ebx
  8021cd:	83 c4 10             	add    $0x10,%esp
  8021d0:	85 c0                	test   %eax,%eax
  8021d2:	78 1b                	js     8021ef <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8021d4:	83 ec 08             	sub    $0x8,%esp
  8021d7:	ff 75 0c             	pushl  0xc(%ebp)
  8021da:	50                   	push   %eax
  8021db:	e8 5b ff ff ff       	call   80213b <fstat>
  8021e0:	89 c6                	mov    %eax,%esi
	close(fd);
  8021e2:	89 1c 24             	mov    %ebx,(%esp)
  8021e5:	e8 fd fb ff ff       	call   801de7 <close>
	return r;
  8021ea:	83 c4 10             	add    $0x10,%esp
  8021ed:	89 f0                	mov    %esi,%eax
}
  8021ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021f2:	5b                   	pop    %ebx
  8021f3:	5e                   	pop    %esi
  8021f4:	5d                   	pop    %ebp
  8021f5:	c3                   	ret    

008021f6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8021f6:	55                   	push   %ebp
  8021f7:	89 e5                	mov    %esp,%ebp
  8021f9:	56                   	push   %esi
  8021fa:	53                   	push   %ebx
  8021fb:	89 c6                	mov    %eax,%esi
  8021fd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8021ff:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  802206:	75 12                	jne    80221a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802208:	83 ec 0c             	sub    $0xc,%esp
  80220b:	6a 01                	push   $0x1
  80220d:	e8 6a 12 00 00       	call   80347c <ipc_find_env>
  802212:	a3 20 54 80 00       	mov    %eax,0x805420
  802217:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80221a:	6a 07                	push   $0x7
  80221c:	68 00 60 80 00       	push   $0x806000
  802221:	56                   	push   %esi
  802222:	ff 35 20 54 80 00    	pushl  0x805420
  802228:	e8 fb 11 00 00       	call   803428 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80222d:	83 c4 0c             	add    $0xc,%esp
  802230:	6a 00                	push   $0x0
  802232:	53                   	push   %ebx
  802233:	6a 00                	push   $0x0
  802235:	e8 85 11 00 00       	call   8033bf <ipc_recv>
}
  80223a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80223d:	5b                   	pop    %ebx
  80223e:	5e                   	pop    %esi
  80223f:	5d                   	pop    %ebp
  802240:	c3                   	ret    

00802241 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802241:	55                   	push   %ebp
  802242:	89 e5                	mov    %esp,%ebp
  802244:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802247:	8b 45 08             	mov    0x8(%ebp),%eax
  80224a:	8b 40 0c             	mov    0xc(%eax),%eax
  80224d:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  802252:	8b 45 0c             	mov    0xc(%ebp),%eax
  802255:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80225a:	ba 00 00 00 00       	mov    $0x0,%edx
  80225f:	b8 02 00 00 00       	mov    $0x2,%eax
  802264:	e8 8d ff ff ff       	call   8021f6 <fsipc>
}
  802269:	c9                   	leave  
  80226a:	c3                   	ret    

0080226b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80226b:	55                   	push   %ebp
  80226c:	89 e5                	mov    %esp,%ebp
  80226e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802271:	8b 45 08             	mov    0x8(%ebp),%eax
  802274:	8b 40 0c             	mov    0xc(%eax),%eax
  802277:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80227c:	ba 00 00 00 00       	mov    $0x0,%edx
  802281:	b8 06 00 00 00       	mov    $0x6,%eax
  802286:	e8 6b ff ff ff       	call   8021f6 <fsipc>
}
  80228b:	c9                   	leave  
  80228c:	c3                   	ret    

0080228d <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80228d:	55                   	push   %ebp
  80228e:	89 e5                	mov    %esp,%ebp
  802290:	53                   	push   %ebx
  802291:	83 ec 04             	sub    $0x4,%esp
  802294:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802297:	8b 45 08             	mov    0x8(%ebp),%eax
  80229a:	8b 40 0c             	mov    0xc(%eax),%eax
  80229d:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8022a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8022a7:	b8 05 00 00 00       	mov    $0x5,%eax
  8022ac:	e8 45 ff ff ff       	call   8021f6 <fsipc>
  8022b1:	85 c0                	test   %eax,%eax
  8022b3:	78 2c                	js     8022e1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8022b5:	83 ec 08             	sub    $0x8,%esp
  8022b8:	68 00 60 80 00       	push   $0x806000
  8022bd:	53                   	push   %ebx
  8022be:	e8 a3 ee ff ff       	call   801166 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8022c3:	a1 80 60 80 00       	mov    0x806080,%eax
  8022c8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8022ce:	a1 84 60 80 00       	mov    0x806084,%eax
  8022d3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8022d9:	83 c4 10             	add    $0x10,%esp
  8022dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022e4:	c9                   	leave  
  8022e5:	c3                   	ret    

008022e6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8022e6:	55                   	push   %ebp
  8022e7:	89 e5                	mov    %esp,%ebp
  8022e9:	53                   	push   %ebx
  8022ea:	83 ec 08             	sub    $0x8,%esp
  8022ed:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8022f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8022f3:	8b 52 0c             	mov    0xc(%edx),%edx
  8022f6:	89 15 00 60 80 00    	mov    %edx,0x806000
  8022fc:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802301:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  802306:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  802309:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  80230f:	53                   	push   %ebx
  802310:	ff 75 0c             	pushl  0xc(%ebp)
  802313:	68 08 60 80 00       	push   $0x806008
  802318:	e8 db ef ff ff       	call   8012f8 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  80231d:	ba 00 00 00 00       	mov    $0x0,%edx
  802322:	b8 04 00 00 00       	mov    $0x4,%eax
  802327:	e8 ca fe ff ff       	call   8021f6 <fsipc>
  80232c:	83 c4 10             	add    $0x10,%esp
  80232f:	85 c0                	test   %eax,%eax
  802331:	78 1d                	js     802350 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  802333:	39 d8                	cmp    %ebx,%eax
  802335:	76 19                	jbe    802350 <devfile_write+0x6a>
  802337:	68 3c 3e 80 00       	push   $0x803e3c
  80233c:	68 c6 38 80 00       	push   $0x8038c6
  802341:	68 a5 00 00 00       	push   $0xa5
  802346:	68 48 3e 80 00       	push   $0x803e48
  80234b:	e8 c5 e6 ff ff       	call   800a15 <_panic>
	return r;
}
  802350:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802353:	c9                   	leave  
  802354:	c3                   	ret    

00802355 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802355:	55                   	push   %ebp
  802356:	89 e5                	mov    %esp,%ebp
  802358:	56                   	push   %esi
  802359:	53                   	push   %ebx
  80235a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80235d:	8b 45 08             	mov    0x8(%ebp),%eax
  802360:	8b 40 0c             	mov    0xc(%eax),%eax
  802363:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  802368:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80236e:	ba 00 00 00 00       	mov    $0x0,%edx
  802373:	b8 03 00 00 00       	mov    $0x3,%eax
  802378:	e8 79 fe ff ff       	call   8021f6 <fsipc>
  80237d:	89 c3                	mov    %eax,%ebx
  80237f:	85 c0                	test   %eax,%eax
  802381:	78 4b                	js     8023ce <devfile_read+0x79>
		return r;
	assert(r <= n);
  802383:	39 c6                	cmp    %eax,%esi
  802385:	73 16                	jae    80239d <devfile_read+0x48>
  802387:	68 53 3e 80 00       	push   $0x803e53
  80238c:	68 c6 38 80 00       	push   $0x8038c6
  802391:	6a 7c                	push   $0x7c
  802393:	68 48 3e 80 00       	push   $0x803e48
  802398:	e8 78 e6 ff ff       	call   800a15 <_panic>
	assert(r <= PGSIZE);
  80239d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8023a2:	7e 16                	jle    8023ba <devfile_read+0x65>
  8023a4:	68 5a 3e 80 00       	push   $0x803e5a
  8023a9:	68 c6 38 80 00       	push   $0x8038c6
  8023ae:	6a 7d                	push   $0x7d
  8023b0:	68 48 3e 80 00       	push   $0x803e48
  8023b5:	e8 5b e6 ff ff       	call   800a15 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8023ba:	83 ec 04             	sub    $0x4,%esp
  8023bd:	50                   	push   %eax
  8023be:	68 00 60 80 00       	push   $0x806000
  8023c3:	ff 75 0c             	pushl  0xc(%ebp)
  8023c6:	e8 2d ef ff ff       	call   8012f8 <memmove>
	return r;
  8023cb:	83 c4 10             	add    $0x10,%esp
}
  8023ce:	89 d8                	mov    %ebx,%eax
  8023d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023d3:	5b                   	pop    %ebx
  8023d4:	5e                   	pop    %esi
  8023d5:	5d                   	pop    %ebp
  8023d6:	c3                   	ret    

008023d7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8023d7:	55                   	push   %ebp
  8023d8:	89 e5                	mov    %esp,%ebp
  8023da:	53                   	push   %ebx
  8023db:	83 ec 20             	sub    $0x20,%esp
  8023de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8023e1:	53                   	push   %ebx
  8023e2:	e8 46 ed ff ff       	call   80112d <strlen>
  8023e7:	83 c4 10             	add    $0x10,%esp
  8023ea:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8023ef:	7f 67                	jg     802458 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8023f1:	83 ec 0c             	sub    $0xc,%esp
  8023f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023f7:	50                   	push   %eax
  8023f8:	e8 71 f8 ff ff       	call   801c6e <fd_alloc>
  8023fd:	83 c4 10             	add    $0x10,%esp
		return r;
  802400:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802402:	85 c0                	test   %eax,%eax
  802404:	78 57                	js     80245d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802406:	83 ec 08             	sub    $0x8,%esp
  802409:	53                   	push   %ebx
  80240a:	68 00 60 80 00       	push   $0x806000
  80240f:	e8 52 ed ff ff       	call   801166 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802414:	8b 45 0c             	mov    0xc(%ebp),%eax
  802417:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80241c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80241f:	b8 01 00 00 00       	mov    $0x1,%eax
  802424:	e8 cd fd ff ff       	call   8021f6 <fsipc>
  802429:	89 c3                	mov    %eax,%ebx
  80242b:	83 c4 10             	add    $0x10,%esp
  80242e:	85 c0                	test   %eax,%eax
  802430:	79 14                	jns    802446 <open+0x6f>
		fd_close(fd, 0);
  802432:	83 ec 08             	sub    $0x8,%esp
  802435:	6a 00                	push   $0x0
  802437:	ff 75 f4             	pushl  -0xc(%ebp)
  80243a:	e8 27 f9 ff ff       	call   801d66 <fd_close>
		return r;
  80243f:	83 c4 10             	add    $0x10,%esp
  802442:	89 da                	mov    %ebx,%edx
  802444:	eb 17                	jmp    80245d <open+0x86>
	}

	return fd2num(fd);
  802446:	83 ec 0c             	sub    $0xc,%esp
  802449:	ff 75 f4             	pushl  -0xc(%ebp)
  80244c:	e8 f6 f7 ff ff       	call   801c47 <fd2num>
  802451:	89 c2                	mov    %eax,%edx
  802453:	83 c4 10             	add    $0x10,%esp
  802456:	eb 05                	jmp    80245d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802458:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80245d:	89 d0                	mov    %edx,%eax
  80245f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802462:	c9                   	leave  
  802463:	c3                   	ret    

00802464 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802464:	55                   	push   %ebp
  802465:	89 e5                	mov    %esp,%ebp
  802467:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80246a:	ba 00 00 00 00       	mov    $0x0,%edx
  80246f:	b8 08 00 00 00       	mov    $0x8,%eax
  802474:	e8 7d fd ff ff       	call   8021f6 <fsipc>
}
  802479:	c9                   	leave  
  80247a:	c3                   	ret    

0080247b <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80247b:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80247f:	7e 37                	jle    8024b8 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  802481:	55                   	push   %ebp
  802482:	89 e5                	mov    %esp,%ebp
  802484:	53                   	push   %ebx
  802485:	83 ec 08             	sub    $0x8,%esp
  802488:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80248a:	ff 70 04             	pushl  0x4(%eax)
  80248d:	8d 40 10             	lea    0x10(%eax),%eax
  802490:	50                   	push   %eax
  802491:	ff 33                	pushl  (%ebx)
  802493:	e8 65 fb ff ff       	call   801ffd <write>
		if (result > 0)
  802498:	83 c4 10             	add    $0x10,%esp
  80249b:	85 c0                	test   %eax,%eax
  80249d:	7e 03                	jle    8024a2 <writebuf+0x27>
			b->result += result;
  80249f:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8024a2:	3b 43 04             	cmp    0x4(%ebx),%eax
  8024a5:	74 0d                	je     8024b4 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8024a7:	85 c0                	test   %eax,%eax
  8024a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8024ae:	0f 4f c2             	cmovg  %edx,%eax
  8024b1:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8024b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024b7:	c9                   	leave  
  8024b8:	f3 c3                	repz ret 

008024ba <putch>:

static void
putch(int ch, void *thunk)
{
  8024ba:	55                   	push   %ebp
  8024bb:	89 e5                	mov    %esp,%ebp
  8024bd:	53                   	push   %ebx
  8024be:	83 ec 04             	sub    $0x4,%esp
  8024c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8024c4:	8b 53 04             	mov    0x4(%ebx),%edx
  8024c7:	8d 42 01             	lea    0x1(%edx),%eax
  8024ca:	89 43 04             	mov    %eax,0x4(%ebx)
  8024cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024d0:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8024d4:	3d 00 01 00 00       	cmp    $0x100,%eax
  8024d9:	75 0e                	jne    8024e9 <putch+0x2f>
		writebuf(b);
  8024db:	89 d8                	mov    %ebx,%eax
  8024dd:	e8 99 ff ff ff       	call   80247b <writebuf>
		b->idx = 0;
  8024e2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8024e9:	83 c4 04             	add    $0x4,%esp
  8024ec:	5b                   	pop    %ebx
  8024ed:	5d                   	pop    %ebp
  8024ee:	c3                   	ret    

008024ef <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8024ef:	55                   	push   %ebp
  8024f0:	89 e5                	mov    %esp,%ebp
  8024f2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8024f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8024fb:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  802501:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  802508:	00 00 00 
	b.result = 0;
  80250b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  802512:	00 00 00 
	b.error = 1;
  802515:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80251c:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80251f:	ff 75 10             	pushl  0x10(%ebp)
  802522:	ff 75 0c             	pushl  0xc(%ebp)
  802525:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80252b:	50                   	push   %eax
  80252c:	68 ba 24 80 00       	push   $0x8024ba
  802531:	e8 ef e6 ff ff       	call   800c25 <vprintfmt>
	if (b.idx > 0)
  802536:	83 c4 10             	add    $0x10,%esp
  802539:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  802540:	7e 0b                	jle    80254d <vfprintf+0x5e>
		writebuf(&b);
  802542:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802548:	e8 2e ff ff ff       	call   80247b <writebuf>

	return (b.result ? b.result : b.error);
  80254d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  802553:	85 c0                	test   %eax,%eax
  802555:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80255c:	c9                   	leave  
  80255d:	c3                   	ret    

0080255e <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80255e:	55                   	push   %ebp
  80255f:	89 e5                	mov    %esp,%ebp
  802561:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802564:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  802567:	50                   	push   %eax
  802568:	ff 75 0c             	pushl  0xc(%ebp)
  80256b:	ff 75 08             	pushl  0x8(%ebp)
  80256e:	e8 7c ff ff ff       	call   8024ef <vfprintf>
	va_end(ap);

	return cnt;
}
  802573:	c9                   	leave  
  802574:	c3                   	ret    

00802575 <printf>:

int
printf(const char *fmt, ...)
{
  802575:	55                   	push   %ebp
  802576:	89 e5                	mov    %esp,%ebp
  802578:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80257b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80257e:	50                   	push   %eax
  80257f:	ff 75 08             	pushl  0x8(%ebp)
  802582:	6a 01                	push   $0x1
  802584:	e8 66 ff ff ff       	call   8024ef <vfprintf>
	va_end(ap);

	return cnt;
}
  802589:	c9                   	leave  
  80258a:	c3                   	ret    

0080258b <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80258b:	55                   	push   %ebp
  80258c:	89 e5                	mov    %esp,%ebp
  80258e:	57                   	push   %edi
  80258f:	56                   	push   %esi
  802590:	53                   	push   %ebx
  802591:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  802597:	6a 00                	push   $0x0
  802599:	ff 75 08             	pushl  0x8(%ebp)
  80259c:	e8 36 fe ff ff       	call   8023d7 <open>
  8025a1:	89 c7                	mov    %eax,%edi
  8025a3:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8025a9:	83 c4 10             	add    $0x10,%esp
  8025ac:	85 c0                	test   %eax,%eax
  8025ae:	0f 88 a6 04 00 00    	js     802a5a <spawn+0x4cf>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8025b4:	83 ec 04             	sub    $0x4,%esp
  8025b7:	68 00 02 00 00       	push   $0x200
  8025bc:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8025c2:	50                   	push   %eax
  8025c3:	57                   	push   %edi
  8025c4:	e8 eb f9 ff ff       	call   801fb4 <readn>
  8025c9:	83 c4 10             	add    $0x10,%esp
  8025cc:	3d 00 02 00 00       	cmp    $0x200,%eax
  8025d1:	75 0c                	jne    8025df <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8025d3:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8025da:	45 4c 46 
  8025dd:	74 33                	je     802612 <spawn+0x87>
		close(fd);
  8025df:	83 ec 0c             	sub    $0xc,%esp
  8025e2:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8025e8:	e8 fa f7 ff ff       	call   801de7 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8025ed:	83 c4 0c             	add    $0xc,%esp
  8025f0:	68 7f 45 4c 46       	push   $0x464c457f
  8025f5:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8025fb:	68 66 3e 80 00       	push   $0x803e66
  802600:	e8 e9 e4 ff ff       	call   800aee <cprintf>
		return -E_NOT_EXEC;
  802605:	83 c4 10             	add    $0x10,%esp
  802608:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  80260d:	e9 a8 04 00 00       	jmp    802aba <spawn+0x52f>
  802612:	b8 07 00 00 00       	mov    $0x7,%eax
  802617:	cd 30                	int    $0x30
  802619:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80261f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802625:	85 c0                	test   %eax,%eax
  802627:	0f 88 35 04 00 00    	js     802a62 <spawn+0x4d7>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80262d:	89 c6                	mov    %eax,%esi
  80262f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  802635:	6b f6 7c             	imul   $0x7c,%esi,%esi
  802638:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80263e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802644:	b9 11 00 00 00       	mov    $0x11,%ecx
  802649:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80264b:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802651:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802657:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80265c:	be 00 00 00 00       	mov    $0x0,%esi
  802661:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802664:	eb 13                	jmp    802679 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  802666:	83 ec 0c             	sub    $0xc,%esp
  802669:	50                   	push   %eax
  80266a:	e8 be ea ff ff       	call   80112d <strlen>
  80266f:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802673:	83 c3 01             	add    $0x1,%ebx
  802676:	83 c4 10             	add    $0x10,%esp
  802679:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  802680:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  802683:	85 c0                	test   %eax,%eax
  802685:	75 df                	jne    802666 <spawn+0xdb>
  802687:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  80268d:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802693:	bf 00 10 40 00       	mov    $0x401000,%edi
  802698:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80269a:	89 fa                	mov    %edi,%edx
  80269c:	83 e2 fc             	and    $0xfffffffc,%edx
  80269f:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8026a6:	29 c2                	sub    %eax,%edx
  8026a8:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8026ae:	8d 42 f8             	lea    -0x8(%edx),%eax
  8026b1:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8026b6:	0f 86 b6 03 00 00    	jbe    802a72 <spawn+0x4e7>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8026bc:	83 ec 04             	sub    $0x4,%esp
  8026bf:	6a 07                	push   $0x7
  8026c1:	68 00 00 40 00       	push   $0x400000
  8026c6:	6a 00                	push   $0x0
  8026c8:	e8 9c ee ff ff       	call   801569 <sys_page_alloc>
  8026cd:	83 c4 10             	add    $0x10,%esp
  8026d0:	85 c0                	test   %eax,%eax
  8026d2:	0f 88 a1 03 00 00    	js     802a79 <spawn+0x4ee>
  8026d8:	be 00 00 00 00       	mov    $0x0,%esi
  8026dd:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8026e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8026e6:	eb 30                	jmp    802718 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8026e8:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8026ee:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8026f4:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8026f7:	83 ec 08             	sub    $0x8,%esp
  8026fa:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8026fd:	57                   	push   %edi
  8026fe:	e8 63 ea ff ff       	call   801166 <strcpy>
		string_store += strlen(argv[i]) + 1;
  802703:	83 c4 04             	add    $0x4,%esp
  802706:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802709:	e8 1f ea ff ff       	call   80112d <strlen>
  80270e:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802712:	83 c6 01             	add    $0x1,%esi
  802715:	83 c4 10             	add    $0x10,%esp
  802718:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  80271e:	7f c8                	jg     8026e8 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  802720:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802726:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  80272c:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802733:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802739:	74 19                	je     802754 <spawn+0x1c9>
  80273b:	68 c4 3e 80 00       	push   $0x803ec4
  802740:	68 c6 38 80 00       	push   $0x8038c6
  802745:	68 f1 00 00 00       	push   $0xf1
  80274a:	68 80 3e 80 00       	push   $0x803e80
  80274f:	e8 c1 e2 ff ff       	call   800a15 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802754:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  80275a:	89 f8                	mov    %edi,%eax
  80275c:	2d 00 30 80 11       	sub    $0x11803000,%eax
  802761:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  802764:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80276a:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80276d:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  802773:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802779:	83 ec 0c             	sub    $0xc,%esp
  80277c:	6a 07                	push   $0x7
  80277e:	68 00 d0 bf ee       	push   $0xeebfd000
  802783:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802789:	68 00 00 40 00       	push   $0x400000
  80278e:	6a 00                	push   $0x0
  802790:	e8 17 ee ff ff       	call   8015ac <sys_page_map>
  802795:	89 c3                	mov    %eax,%ebx
  802797:	83 c4 20             	add    $0x20,%esp
  80279a:	85 c0                	test   %eax,%eax
  80279c:	0f 88 06 03 00 00    	js     802aa8 <spawn+0x51d>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8027a2:	83 ec 08             	sub    $0x8,%esp
  8027a5:	68 00 00 40 00       	push   $0x400000
  8027aa:	6a 00                	push   $0x0
  8027ac:	e8 3d ee ff ff       	call   8015ee <sys_page_unmap>
  8027b1:	89 c3                	mov    %eax,%ebx
  8027b3:	83 c4 10             	add    $0x10,%esp
  8027b6:	85 c0                	test   %eax,%eax
  8027b8:	0f 88 ea 02 00 00    	js     802aa8 <spawn+0x51d>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8027be:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8027c4:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8027cb:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8027d1:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8027d8:	00 00 00 
  8027db:	e9 88 01 00 00       	jmp    802968 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  8027e0:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8027e6:	83 38 01             	cmpl   $0x1,(%eax)
  8027e9:	0f 85 6b 01 00 00    	jne    80295a <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8027ef:	89 c7                	mov    %eax,%edi
  8027f1:	8b 40 18             	mov    0x18(%eax),%eax
  8027f4:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8027fa:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8027fd:	83 f8 01             	cmp    $0x1,%eax
  802800:	19 c0                	sbb    %eax,%eax
  802802:	83 e0 fe             	and    $0xfffffffe,%eax
  802805:	83 c0 07             	add    $0x7,%eax
  802808:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80280e:	89 f8                	mov    %edi,%eax
  802810:	8b 7f 04             	mov    0x4(%edi),%edi
  802813:	89 f9                	mov    %edi,%ecx
  802815:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  80281b:	8b 78 10             	mov    0x10(%eax),%edi
  80281e:	8b 50 14             	mov    0x14(%eax),%edx
  802821:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  802827:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80282a:	89 f0                	mov    %esi,%eax
  80282c:	25 ff 0f 00 00       	and    $0xfff,%eax
  802831:	74 14                	je     802847 <spawn+0x2bc>
		va -= i;
  802833:	29 c6                	sub    %eax,%esi
		memsz += i;
  802835:	01 c2                	add    %eax,%edx
  802837:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  80283d:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  80283f:	29 c1                	sub    %eax,%ecx
  802841:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802847:	bb 00 00 00 00       	mov    $0x0,%ebx
  80284c:	e9 f7 00 00 00       	jmp    802948 <spawn+0x3bd>
		if (i >= filesz) {
  802851:	39 df                	cmp    %ebx,%edi
  802853:	77 27                	ja     80287c <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802855:	83 ec 04             	sub    $0x4,%esp
  802858:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80285e:	56                   	push   %esi
  80285f:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802865:	e8 ff ec ff ff       	call   801569 <sys_page_alloc>
  80286a:	83 c4 10             	add    $0x10,%esp
  80286d:	85 c0                	test   %eax,%eax
  80286f:	0f 89 c7 00 00 00    	jns    80293c <spawn+0x3b1>
  802875:	89 c3                	mov    %eax,%ebx
  802877:	e9 0b 02 00 00       	jmp    802a87 <spawn+0x4fc>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80287c:	83 ec 04             	sub    $0x4,%esp
  80287f:	6a 07                	push   $0x7
  802881:	68 00 00 40 00       	push   $0x400000
  802886:	6a 00                	push   $0x0
  802888:	e8 dc ec ff ff       	call   801569 <sys_page_alloc>
  80288d:	83 c4 10             	add    $0x10,%esp
  802890:	85 c0                	test   %eax,%eax
  802892:	0f 88 e5 01 00 00    	js     802a7d <spawn+0x4f2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802898:	83 ec 08             	sub    $0x8,%esp
  80289b:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8028a1:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  8028a7:	50                   	push   %eax
  8028a8:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8028ae:	e8 d6 f7 ff ff       	call   802089 <seek>
  8028b3:	83 c4 10             	add    $0x10,%esp
  8028b6:	85 c0                	test   %eax,%eax
  8028b8:	0f 88 c3 01 00 00    	js     802a81 <spawn+0x4f6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8028be:	83 ec 04             	sub    $0x4,%esp
  8028c1:	89 f8                	mov    %edi,%eax
  8028c3:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8028c9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8028ce:	b9 00 10 00 00       	mov    $0x1000,%ecx
  8028d3:	0f 47 c1             	cmova  %ecx,%eax
  8028d6:	50                   	push   %eax
  8028d7:	68 00 00 40 00       	push   $0x400000
  8028dc:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8028e2:	e8 cd f6 ff ff       	call   801fb4 <readn>
  8028e7:	83 c4 10             	add    $0x10,%esp
  8028ea:	85 c0                	test   %eax,%eax
  8028ec:	0f 88 93 01 00 00    	js     802a85 <spawn+0x4fa>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8028f2:	83 ec 0c             	sub    $0xc,%esp
  8028f5:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8028fb:	56                   	push   %esi
  8028fc:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802902:	68 00 00 40 00       	push   $0x400000
  802907:	6a 00                	push   $0x0
  802909:	e8 9e ec ff ff       	call   8015ac <sys_page_map>
  80290e:	83 c4 20             	add    $0x20,%esp
  802911:	85 c0                	test   %eax,%eax
  802913:	79 15                	jns    80292a <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  802915:	50                   	push   %eax
  802916:	68 8c 3e 80 00       	push   $0x803e8c
  80291b:	68 24 01 00 00       	push   $0x124
  802920:	68 80 3e 80 00       	push   $0x803e80
  802925:	e8 eb e0 ff ff       	call   800a15 <_panic>
			sys_page_unmap(0, UTEMP);
  80292a:	83 ec 08             	sub    $0x8,%esp
  80292d:	68 00 00 40 00       	push   $0x400000
  802932:	6a 00                	push   $0x0
  802934:	e8 b5 ec ff ff       	call   8015ee <sys_page_unmap>
  802939:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80293c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802942:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802948:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  80294e:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  802954:	0f 87 f7 fe ff ff    	ja     802851 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80295a:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802961:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802968:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80296f:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802975:	0f 8c 65 fe ff ff    	jl     8027e0 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  80297b:	83 ec 0c             	sub    $0xc,%esp
  80297e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802984:	e8 5e f4 ff ff       	call   801de7 <close>
  802989:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	// Loop through all the pte's of parent's pgdir in user space
        uint32_t pn;
        for (pn = UTEXT/PGSIZE; pn < UTOP/PGSIZE; pn++) {
  80298c:	bb 00 08 00 00       	mov    $0x800,%ebx
  802991:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		
		if (uvpd[pn/NPTENTRIES] & PTE_P) {
  802997:	89 d8                	mov    %ebx,%eax
  802999:	c1 e8 0a             	shr    $0xa,%eax
  80299c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8029a3:	a8 01                	test   $0x1,%al
  8029a5:	74 4b                	je     8029f2 <spawn+0x467>
		
			pte_t pte = uvpt[pn];
  8029a7:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax

			
			if ((pte & PTE_P) && (pte & PTE_SHARE)) {
  8029ae:	89 c2                	mov    %eax,%edx
  8029b0:	81 e2 01 04 00 00    	and    $0x401,%edx
  8029b6:	81 fa 01 04 00 00    	cmp    $0x401,%edx
  8029bc:	75 34                	jne    8029f2 <spawn+0x467>
  8029be:	89 da                	mov    %ebx,%edx
  8029c0:	c1 e2 0c             	shl    $0xc,%edx
				void *va = (void *) (pn * PGSIZE);
				uint32_t perm = pte & PTE_SYSCALL;
				int r;
				if ((r = sys_page_map(0, va, child, va, perm)) < 0)
  8029c3:	83 ec 0c             	sub    $0xc,%esp
  8029c6:	25 07 0e 00 00       	and    $0xe07,%eax
  8029cb:	50                   	push   %eax
  8029cc:	52                   	push   %edx
  8029cd:	56                   	push   %esi
  8029ce:	52                   	push   %edx
  8029cf:	6a 00                	push   $0x0
  8029d1:	e8 d6 eb ff ff       	call   8015ac <sys_page_map>
  8029d6:	83 c4 20             	add    $0x20,%esp
  8029d9:	85 c0                	test   %eax,%eax
  8029db:	79 15                	jns    8029f2 <spawn+0x467>
					panic("sys_page_map: %e", r);
  8029dd:	50                   	push   %eax
  8029de:	68 4b 3d 80 00       	push   $0x803d4b
  8029e3:	68 3e 01 00 00       	push   $0x13e
  8029e8:	68 80 3e 80 00       	push   $0x803e80
  8029ed:	e8 23 e0 ff ff       	call   800a15 <_panic>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	// Loop through all the pte's of parent's pgdir in user space
        uint32_t pn;
        for (pn = UTEXT/PGSIZE; pn < UTOP/PGSIZE; pn++) {
  8029f2:	83 c3 01             	add    $0x1,%ebx
  8029f5:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  8029fb:	75 9a                	jne    802997 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8029fd:	83 ec 08             	sub    $0x8,%esp
  802a00:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802a06:	50                   	push   %eax
  802a07:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a0d:	e8 60 ec ff ff       	call   801672 <sys_env_set_trapframe>
  802a12:	83 c4 10             	add    $0x10,%esp
  802a15:	85 c0                	test   %eax,%eax
  802a17:	79 15                	jns    802a2e <spawn+0x4a3>
		panic("sys_env_set_trapframe: %e", r);
  802a19:	50                   	push   %eax
  802a1a:	68 a9 3e 80 00       	push   $0x803ea9
  802a1f:	68 85 00 00 00       	push   $0x85
  802a24:	68 80 3e 80 00       	push   $0x803e80
  802a29:	e8 e7 df ff ff       	call   800a15 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802a2e:	83 ec 08             	sub    $0x8,%esp
  802a31:	6a 02                	push   $0x2
  802a33:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a39:	e8 f2 eb ff ff       	call   801630 <sys_env_set_status>
  802a3e:	83 c4 10             	add    $0x10,%esp
  802a41:	85 c0                	test   %eax,%eax
  802a43:	79 25                	jns    802a6a <spawn+0x4df>
		panic("sys_env_set_status: %e", r);
  802a45:	50                   	push   %eax
  802a46:	68 7f 3d 80 00       	push   $0x803d7f
  802a4b:	68 88 00 00 00       	push   $0x88
  802a50:	68 80 3e 80 00       	push   $0x803e80
  802a55:	e8 bb df ff ff       	call   800a15 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802a5a:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  802a60:	eb 58                	jmp    802aba <spawn+0x52f>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802a62:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802a68:	eb 50                	jmp    802aba <spawn+0x52f>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802a6a:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802a70:	eb 48                	jmp    802aba <spawn+0x52f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802a72:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  802a77:	eb 41                	jmp    802aba <spawn+0x52f>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802a79:	89 c3                	mov    %eax,%ebx
  802a7b:	eb 3d                	jmp    802aba <spawn+0x52f>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802a7d:	89 c3                	mov    %eax,%ebx
  802a7f:	eb 06                	jmp    802a87 <spawn+0x4fc>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802a81:	89 c3                	mov    %eax,%ebx
  802a83:	eb 02                	jmp    802a87 <spawn+0x4fc>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802a85:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802a87:	83 ec 0c             	sub    $0xc,%esp
  802a8a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a90:	e8 55 ea ff ff       	call   8014ea <sys_env_destroy>
	close(fd);
  802a95:	83 c4 04             	add    $0x4,%esp
  802a98:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802a9e:	e8 44 f3 ff ff       	call   801de7 <close>
	return r;
  802aa3:	83 c4 10             	add    $0x10,%esp
  802aa6:	eb 12                	jmp    802aba <spawn+0x52f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802aa8:	83 ec 08             	sub    $0x8,%esp
  802aab:	68 00 00 40 00       	push   $0x400000
  802ab0:	6a 00                	push   $0x0
  802ab2:	e8 37 eb ff ff       	call   8015ee <sys_page_unmap>
  802ab7:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802aba:	89 d8                	mov    %ebx,%eax
  802abc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802abf:	5b                   	pop    %ebx
  802ac0:	5e                   	pop    %esi
  802ac1:	5f                   	pop    %edi
  802ac2:	5d                   	pop    %ebp
  802ac3:	c3                   	ret    

00802ac4 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802ac4:	55                   	push   %ebp
  802ac5:	89 e5                	mov    %esp,%ebp
  802ac7:	56                   	push   %esi
  802ac8:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802ac9:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802acc:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802ad1:	eb 03                	jmp    802ad6 <spawnl+0x12>
		argc++;
  802ad3:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802ad6:	83 c2 04             	add    $0x4,%edx
  802ad9:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802add:	75 f4                	jne    802ad3 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802adf:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802ae6:	83 e2 f0             	and    $0xfffffff0,%edx
  802ae9:	29 d4                	sub    %edx,%esp
  802aeb:	8d 54 24 03          	lea    0x3(%esp),%edx
  802aef:	c1 ea 02             	shr    $0x2,%edx
  802af2:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802af9:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802afb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802afe:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802b05:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802b0c:	00 
  802b0d:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802b0f:	b8 00 00 00 00       	mov    $0x0,%eax
  802b14:	eb 0a                	jmp    802b20 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802b16:	83 c0 01             	add    $0x1,%eax
  802b19:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802b1d:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802b20:	39 d0                	cmp    %edx,%eax
  802b22:	75 f2                	jne    802b16 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802b24:	83 ec 08             	sub    $0x8,%esp
  802b27:	56                   	push   %esi
  802b28:	ff 75 08             	pushl  0x8(%ebp)
  802b2b:	e8 5b fa ff ff       	call   80258b <spawn>
}
  802b30:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b33:	5b                   	pop    %ebx
  802b34:	5e                   	pop    %esi
  802b35:	5d                   	pop    %ebp
  802b36:	c3                   	ret    

00802b37 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802b37:	55                   	push   %ebp
  802b38:	89 e5                	mov    %esp,%ebp
  802b3a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  802b3d:	68 ec 3e 80 00       	push   $0x803eec
  802b42:	ff 75 0c             	pushl  0xc(%ebp)
  802b45:	e8 1c e6 ff ff       	call   801166 <strcpy>
	return 0;
}
  802b4a:	b8 00 00 00 00       	mov    $0x0,%eax
  802b4f:	c9                   	leave  
  802b50:	c3                   	ret    

00802b51 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802b51:	55                   	push   %ebp
  802b52:	89 e5                	mov    %esp,%ebp
  802b54:	53                   	push   %ebx
  802b55:	83 ec 10             	sub    $0x10,%esp
  802b58:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802b5b:	53                   	push   %ebx
  802b5c:	e8 54 09 00 00       	call   8034b5 <pageref>
  802b61:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  802b64:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  802b69:	83 f8 01             	cmp    $0x1,%eax
  802b6c:	75 10                	jne    802b7e <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  802b6e:	83 ec 0c             	sub    $0xc,%esp
  802b71:	ff 73 0c             	pushl  0xc(%ebx)
  802b74:	e8 c0 02 00 00       	call   802e39 <nsipc_close>
  802b79:	89 c2                	mov    %eax,%edx
  802b7b:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  802b7e:	89 d0                	mov    %edx,%eax
  802b80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b83:	c9                   	leave  
  802b84:	c3                   	ret    

00802b85 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802b85:	55                   	push   %ebp
  802b86:	89 e5                	mov    %esp,%ebp
  802b88:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802b8b:	6a 00                	push   $0x0
  802b8d:	ff 75 10             	pushl  0x10(%ebp)
  802b90:	ff 75 0c             	pushl  0xc(%ebp)
  802b93:	8b 45 08             	mov    0x8(%ebp),%eax
  802b96:	ff 70 0c             	pushl  0xc(%eax)
  802b99:	e8 78 03 00 00       	call   802f16 <nsipc_send>
}
  802b9e:	c9                   	leave  
  802b9f:	c3                   	ret    

00802ba0 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802ba0:	55                   	push   %ebp
  802ba1:	89 e5                	mov    %esp,%ebp
  802ba3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802ba6:	6a 00                	push   $0x0
  802ba8:	ff 75 10             	pushl  0x10(%ebp)
  802bab:	ff 75 0c             	pushl  0xc(%ebp)
  802bae:	8b 45 08             	mov    0x8(%ebp),%eax
  802bb1:	ff 70 0c             	pushl  0xc(%eax)
  802bb4:	e8 f1 02 00 00       	call   802eaa <nsipc_recv>
}
  802bb9:	c9                   	leave  
  802bba:	c3                   	ret    

00802bbb <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802bbb:	55                   	push   %ebp
  802bbc:	89 e5                	mov    %esp,%ebp
  802bbe:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802bc1:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802bc4:	52                   	push   %edx
  802bc5:	50                   	push   %eax
  802bc6:	e8 f2 f0 ff ff       	call   801cbd <fd_lookup>
  802bcb:	83 c4 10             	add    $0x10,%esp
  802bce:	85 c0                	test   %eax,%eax
  802bd0:	78 17                	js     802be9 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802bd5:	8b 0d 3c 40 80 00    	mov    0x80403c,%ecx
  802bdb:	39 08                	cmp    %ecx,(%eax)
  802bdd:	75 05                	jne    802be4 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802bdf:	8b 40 0c             	mov    0xc(%eax),%eax
  802be2:	eb 05                	jmp    802be9 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  802be4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802be9:	c9                   	leave  
  802bea:	c3                   	ret    

00802beb <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  802beb:	55                   	push   %ebp
  802bec:	89 e5                	mov    %esp,%ebp
  802bee:	56                   	push   %esi
  802bef:	53                   	push   %ebx
  802bf0:	83 ec 1c             	sub    $0x1c,%esp
  802bf3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802bf5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802bf8:	50                   	push   %eax
  802bf9:	e8 70 f0 ff ff       	call   801c6e <fd_alloc>
  802bfe:	89 c3                	mov    %eax,%ebx
  802c00:	83 c4 10             	add    $0x10,%esp
  802c03:	85 c0                	test   %eax,%eax
  802c05:	78 1b                	js     802c22 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802c07:	83 ec 04             	sub    $0x4,%esp
  802c0a:	68 07 04 00 00       	push   $0x407
  802c0f:	ff 75 f4             	pushl  -0xc(%ebp)
  802c12:	6a 00                	push   $0x0
  802c14:	e8 50 e9 ff ff       	call   801569 <sys_page_alloc>
  802c19:	89 c3                	mov    %eax,%ebx
  802c1b:	83 c4 10             	add    $0x10,%esp
  802c1e:	85 c0                	test   %eax,%eax
  802c20:	79 10                	jns    802c32 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  802c22:	83 ec 0c             	sub    $0xc,%esp
  802c25:	56                   	push   %esi
  802c26:	e8 0e 02 00 00       	call   802e39 <nsipc_close>
		return r;
  802c2b:	83 c4 10             	add    $0x10,%esp
  802c2e:	89 d8                	mov    %ebx,%eax
  802c30:	eb 24                	jmp    802c56 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802c32:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c3b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c40:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802c47:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802c4a:	83 ec 0c             	sub    $0xc,%esp
  802c4d:	50                   	push   %eax
  802c4e:	e8 f4 ef ff ff       	call   801c47 <fd2num>
  802c53:	83 c4 10             	add    $0x10,%esp
}
  802c56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802c59:	5b                   	pop    %ebx
  802c5a:	5e                   	pop    %esi
  802c5b:	5d                   	pop    %ebp
  802c5c:	c3                   	ret    

00802c5d <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802c5d:	55                   	push   %ebp
  802c5e:	89 e5                	mov    %esp,%ebp
  802c60:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802c63:	8b 45 08             	mov    0x8(%ebp),%eax
  802c66:	e8 50 ff ff ff       	call   802bbb <fd2sockid>
		return r;
  802c6b:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  802c6d:	85 c0                	test   %eax,%eax
  802c6f:	78 1f                	js     802c90 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802c71:	83 ec 04             	sub    $0x4,%esp
  802c74:	ff 75 10             	pushl  0x10(%ebp)
  802c77:	ff 75 0c             	pushl  0xc(%ebp)
  802c7a:	50                   	push   %eax
  802c7b:	e8 12 01 00 00       	call   802d92 <nsipc_accept>
  802c80:	83 c4 10             	add    $0x10,%esp
		return r;
  802c83:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802c85:	85 c0                	test   %eax,%eax
  802c87:	78 07                	js     802c90 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  802c89:	e8 5d ff ff ff       	call   802beb <alloc_sockfd>
  802c8e:	89 c1                	mov    %eax,%ecx
}
  802c90:	89 c8                	mov    %ecx,%eax
  802c92:	c9                   	leave  
  802c93:	c3                   	ret    

00802c94 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802c94:	55                   	push   %ebp
  802c95:	89 e5                	mov    %esp,%ebp
  802c97:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802c9a:	8b 45 08             	mov    0x8(%ebp),%eax
  802c9d:	e8 19 ff ff ff       	call   802bbb <fd2sockid>
  802ca2:	85 c0                	test   %eax,%eax
  802ca4:	78 12                	js     802cb8 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  802ca6:	83 ec 04             	sub    $0x4,%esp
  802ca9:	ff 75 10             	pushl  0x10(%ebp)
  802cac:	ff 75 0c             	pushl  0xc(%ebp)
  802caf:	50                   	push   %eax
  802cb0:	e8 2d 01 00 00       	call   802de2 <nsipc_bind>
  802cb5:	83 c4 10             	add    $0x10,%esp
}
  802cb8:	c9                   	leave  
  802cb9:	c3                   	ret    

00802cba <shutdown>:

int
shutdown(int s, int how)
{
  802cba:	55                   	push   %ebp
  802cbb:	89 e5                	mov    %esp,%ebp
  802cbd:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  802cc3:	e8 f3 fe ff ff       	call   802bbb <fd2sockid>
  802cc8:	85 c0                	test   %eax,%eax
  802cca:	78 0f                	js     802cdb <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802ccc:	83 ec 08             	sub    $0x8,%esp
  802ccf:	ff 75 0c             	pushl  0xc(%ebp)
  802cd2:	50                   	push   %eax
  802cd3:	e8 3f 01 00 00       	call   802e17 <nsipc_shutdown>
  802cd8:	83 c4 10             	add    $0x10,%esp
}
  802cdb:	c9                   	leave  
  802cdc:	c3                   	ret    

00802cdd <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802cdd:	55                   	push   %ebp
  802cde:	89 e5                	mov    %esp,%ebp
  802ce0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  802ce6:	e8 d0 fe ff ff       	call   802bbb <fd2sockid>
  802ceb:	85 c0                	test   %eax,%eax
  802ced:	78 12                	js     802d01 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  802cef:	83 ec 04             	sub    $0x4,%esp
  802cf2:	ff 75 10             	pushl  0x10(%ebp)
  802cf5:	ff 75 0c             	pushl  0xc(%ebp)
  802cf8:	50                   	push   %eax
  802cf9:	e8 55 01 00 00       	call   802e53 <nsipc_connect>
  802cfe:	83 c4 10             	add    $0x10,%esp
}
  802d01:	c9                   	leave  
  802d02:	c3                   	ret    

00802d03 <listen>:

int
listen(int s, int backlog)
{
  802d03:	55                   	push   %ebp
  802d04:	89 e5                	mov    %esp,%ebp
  802d06:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802d09:	8b 45 08             	mov    0x8(%ebp),%eax
  802d0c:	e8 aa fe ff ff       	call   802bbb <fd2sockid>
  802d11:	85 c0                	test   %eax,%eax
  802d13:	78 0f                	js     802d24 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802d15:	83 ec 08             	sub    $0x8,%esp
  802d18:	ff 75 0c             	pushl  0xc(%ebp)
  802d1b:	50                   	push   %eax
  802d1c:	e8 67 01 00 00       	call   802e88 <nsipc_listen>
  802d21:	83 c4 10             	add    $0x10,%esp
}
  802d24:	c9                   	leave  
  802d25:	c3                   	ret    

00802d26 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802d26:	55                   	push   %ebp
  802d27:	89 e5                	mov    %esp,%ebp
  802d29:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802d2c:	ff 75 10             	pushl  0x10(%ebp)
  802d2f:	ff 75 0c             	pushl  0xc(%ebp)
  802d32:	ff 75 08             	pushl  0x8(%ebp)
  802d35:	e8 3a 02 00 00       	call   802f74 <nsipc_socket>
  802d3a:	83 c4 10             	add    $0x10,%esp
  802d3d:	85 c0                	test   %eax,%eax
  802d3f:	78 05                	js     802d46 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  802d41:	e8 a5 fe ff ff       	call   802beb <alloc_sockfd>
}
  802d46:	c9                   	leave  
  802d47:	c3                   	ret    

00802d48 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802d48:	55                   	push   %ebp
  802d49:	89 e5                	mov    %esp,%ebp
  802d4b:	53                   	push   %ebx
  802d4c:	83 ec 04             	sub    $0x4,%esp
  802d4f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802d51:	83 3d 24 54 80 00 00 	cmpl   $0x0,0x805424
  802d58:	75 12                	jne    802d6c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802d5a:	83 ec 0c             	sub    $0xc,%esp
  802d5d:	6a 02                	push   $0x2
  802d5f:	e8 18 07 00 00       	call   80347c <ipc_find_env>
  802d64:	a3 24 54 80 00       	mov    %eax,0x805424
  802d69:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802d6c:	6a 07                	push   $0x7
  802d6e:	68 00 70 80 00       	push   $0x807000
  802d73:	53                   	push   %ebx
  802d74:	ff 35 24 54 80 00    	pushl  0x805424
  802d7a:	e8 a9 06 00 00       	call   803428 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802d7f:	83 c4 0c             	add    $0xc,%esp
  802d82:	6a 00                	push   $0x0
  802d84:	6a 00                	push   $0x0
  802d86:	6a 00                	push   $0x0
  802d88:	e8 32 06 00 00       	call   8033bf <ipc_recv>
}
  802d8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d90:	c9                   	leave  
  802d91:	c3                   	ret    

00802d92 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802d92:	55                   	push   %ebp
  802d93:	89 e5                	mov    %esp,%ebp
  802d95:	56                   	push   %esi
  802d96:	53                   	push   %ebx
  802d97:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802d9a:	8b 45 08             	mov    0x8(%ebp),%eax
  802d9d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802da2:	8b 06                	mov    (%esi),%eax
  802da4:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802da9:	b8 01 00 00 00       	mov    $0x1,%eax
  802dae:	e8 95 ff ff ff       	call   802d48 <nsipc>
  802db3:	89 c3                	mov    %eax,%ebx
  802db5:	85 c0                	test   %eax,%eax
  802db7:	78 20                	js     802dd9 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802db9:	83 ec 04             	sub    $0x4,%esp
  802dbc:	ff 35 10 70 80 00    	pushl  0x807010
  802dc2:	68 00 70 80 00       	push   $0x807000
  802dc7:	ff 75 0c             	pushl  0xc(%ebp)
  802dca:	e8 29 e5 ff ff       	call   8012f8 <memmove>
		*addrlen = ret->ret_addrlen;
  802dcf:	a1 10 70 80 00       	mov    0x807010,%eax
  802dd4:	89 06                	mov    %eax,(%esi)
  802dd6:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802dd9:	89 d8                	mov    %ebx,%eax
  802ddb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802dde:	5b                   	pop    %ebx
  802ddf:	5e                   	pop    %esi
  802de0:	5d                   	pop    %ebp
  802de1:	c3                   	ret    

00802de2 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802de2:	55                   	push   %ebp
  802de3:	89 e5                	mov    %esp,%ebp
  802de5:	53                   	push   %ebx
  802de6:	83 ec 08             	sub    $0x8,%esp
  802de9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802dec:	8b 45 08             	mov    0x8(%ebp),%eax
  802def:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802df4:	53                   	push   %ebx
  802df5:	ff 75 0c             	pushl  0xc(%ebp)
  802df8:	68 04 70 80 00       	push   $0x807004
  802dfd:	e8 f6 e4 ff ff       	call   8012f8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802e02:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802e08:	b8 02 00 00 00       	mov    $0x2,%eax
  802e0d:	e8 36 ff ff ff       	call   802d48 <nsipc>
}
  802e12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e15:	c9                   	leave  
  802e16:	c3                   	ret    

00802e17 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802e17:	55                   	push   %ebp
  802e18:	89 e5                	mov    %esp,%ebp
  802e1a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  802e20:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802e25:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e28:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802e2d:	b8 03 00 00 00       	mov    $0x3,%eax
  802e32:	e8 11 ff ff ff       	call   802d48 <nsipc>
}
  802e37:	c9                   	leave  
  802e38:	c3                   	ret    

00802e39 <nsipc_close>:

int
nsipc_close(int s)
{
  802e39:	55                   	push   %ebp
  802e3a:	89 e5                	mov    %esp,%ebp
  802e3c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802e3f:	8b 45 08             	mov    0x8(%ebp),%eax
  802e42:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802e47:	b8 04 00 00 00       	mov    $0x4,%eax
  802e4c:	e8 f7 fe ff ff       	call   802d48 <nsipc>
}
  802e51:	c9                   	leave  
  802e52:	c3                   	ret    

00802e53 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802e53:	55                   	push   %ebp
  802e54:	89 e5                	mov    %esp,%ebp
  802e56:	53                   	push   %ebx
  802e57:	83 ec 08             	sub    $0x8,%esp
  802e5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802e5d:	8b 45 08             	mov    0x8(%ebp),%eax
  802e60:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802e65:	53                   	push   %ebx
  802e66:	ff 75 0c             	pushl  0xc(%ebp)
  802e69:	68 04 70 80 00       	push   $0x807004
  802e6e:	e8 85 e4 ff ff       	call   8012f8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802e73:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802e79:	b8 05 00 00 00       	mov    $0x5,%eax
  802e7e:	e8 c5 fe ff ff       	call   802d48 <nsipc>
}
  802e83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e86:	c9                   	leave  
  802e87:	c3                   	ret    

00802e88 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802e88:	55                   	push   %ebp
  802e89:	89 e5                	mov    %esp,%ebp
  802e8b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802e8e:	8b 45 08             	mov    0x8(%ebp),%eax
  802e91:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802e96:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e99:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802e9e:	b8 06 00 00 00       	mov    $0x6,%eax
  802ea3:	e8 a0 fe ff ff       	call   802d48 <nsipc>
}
  802ea8:	c9                   	leave  
  802ea9:	c3                   	ret    

00802eaa <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802eaa:	55                   	push   %ebp
  802eab:	89 e5                	mov    %esp,%ebp
  802ead:	56                   	push   %esi
  802eae:	53                   	push   %ebx
  802eaf:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802eb2:	8b 45 08             	mov    0x8(%ebp),%eax
  802eb5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802eba:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802ec0:	8b 45 14             	mov    0x14(%ebp),%eax
  802ec3:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802ec8:	b8 07 00 00 00       	mov    $0x7,%eax
  802ecd:	e8 76 fe ff ff       	call   802d48 <nsipc>
  802ed2:	89 c3                	mov    %eax,%ebx
  802ed4:	85 c0                	test   %eax,%eax
  802ed6:	78 35                	js     802f0d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802ed8:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802edd:	7f 04                	jg     802ee3 <nsipc_recv+0x39>
  802edf:	39 c6                	cmp    %eax,%esi
  802ee1:	7d 16                	jge    802ef9 <nsipc_recv+0x4f>
  802ee3:	68 f8 3e 80 00       	push   $0x803ef8
  802ee8:	68 c6 38 80 00       	push   $0x8038c6
  802eed:	6a 62                	push   $0x62
  802eef:	68 0d 3f 80 00       	push   $0x803f0d
  802ef4:	e8 1c db ff ff       	call   800a15 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802ef9:	83 ec 04             	sub    $0x4,%esp
  802efc:	50                   	push   %eax
  802efd:	68 00 70 80 00       	push   $0x807000
  802f02:	ff 75 0c             	pushl  0xc(%ebp)
  802f05:	e8 ee e3 ff ff       	call   8012f8 <memmove>
  802f0a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802f0d:	89 d8                	mov    %ebx,%eax
  802f0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f12:	5b                   	pop    %ebx
  802f13:	5e                   	pop    %esi
  802f14:	5d                   	pop    %ebp
  802f15:	c3                   	ret    

00802f16 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802f16:	55                   	push   %ebp
  802f17:	89 e5                	mov    %esp,%ebp
  802f19:	53                   	push   %ebx
  802f1a:	83 ec 04             	sub    $0x4,%esp
  802f1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802f20:	8b 45 08             	mov    0x8(%ebp),%eax
  802f23:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802f28:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802f2e:	7e 16                	jle    802f46 <nsipc_send+0x30>
  802f30:	68 19 3f 80 00       	push   $0x803f19
  802f35:	68 c6 38 80 00       	push   $0x8038c6
  802f3a:	6a 6d                	push   $0x6d
  802f3c:	68 0d 3f 80 00       	push   $0x803f0d
  802f41:	e8 cf da ff ff       	call   800a15 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802f46:	83 ec 04             	sub    $0x4,%esp
  802f49:	53                   	push   %ebx
  802f4a:	ff 75 0c             	pushl  0xc(%ebp)
  802f4d:	68 0c 70 80 00       	push   $0x80700c
  802f52:	e8 a1 e3 ff ff       	call   8012f8 <memmove>
	nsipcbuf.send.req_size = size;
  802f57:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802f5d:	8b 45 14             	mov    0x14(%ebp),%eax
  802f60:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802f65:	b8 08 00 00 00       	mov    $0x8,%eax
  802f6a:	e8 d9 fd ff ff       	call   802d48 <nsipc>
}
  802f6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f72:	c9                   	leave  
  802f73:	c3                   	ret    

00802f74 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802f74:	55                   	push   %ebp
  802f75:	89 e5                	mov    %esp,%ebp
  802f77:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802f7a:	8b 45 08             	mov    0x8(%ebp),%eax
  802f7d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802f82:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f85:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802f8a:	8b 45 10             	mov    0x10(%ebp),%eax
  802f8d:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802f92:	b8 09 00 00 00       	mov    $0x9,%eax
  802f97:	e8 ac fd ff ff       	call   802d48 <nsipc>
}
  802f9c:	c9                   	leave  
  802f9d:	c3                   	ret    

00802f9e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802f9e:	55                   	push   %ebp
  802f9f:	89 e5                	mov    %esp,%ebp
  802fa1:	56                   	push   %esi
  802fa2:	53                   	push   %ebx
  802fa3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802fa6:	83 ec 0c             	sub    $0xc,%esp
  802fa9:	ff 75 08             	pushl  0x8(%ebp)
  802fac:	e8 a6 ec ff ff       	call   801c57 <fd2data>
  802fb1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802fb3:	83 c4 08             	add    $0x8,%esp
  802fb6:	68 25 3f 80 00       	push   $0x803f25
  802fbb:	53                   	push   %ebx
  802fbc:	e8 a5 e1 ff ff       	call   801166 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802fc1:	8b 46 04             	mov    0x4(%esi),%eax
  802fc4:	2b 06                	sub    (%esi),%eax
  802fc6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802fcc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802fd3:	00 00 00 
	stat->st_dev = &devpipe;
  802fd6:	c7 83 88 00 00 00 58 	movl   $0x804058,0x88(%ebx)
  802fdd:	40 80 00 
	return 0;
}
  802fe0:	b8 00 00 00 00       	mov    $0x0,%eax
  802fe5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802fe8:	5b                   	pop    %ebx
  802fe9:	5e                   	pop    %esi
  802fea:	5d                   	pop    %ebp
  802feb:	c3                   	ret    

00802fec <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802fec:	55                   	push   %ebp
  802fed:	89 e5                	mov    %esp,%ebp
  802fef:	53                   	push   %ebx
  802ff0:	83 ec 0c             	sub    $0xc,%esp
  802ff3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802ff6:	53                   	push   %ebx
  802ff7:	6a 00                	push   $0x0
  802ff9:	e8 f0 e5 ff ff       	call   8015ee <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802ffe:	89 1c 24             	mov    %ebx,(%esp)
  803001:	e8 51 ec ff ff       	call   801c57 <fd2data>
  803006:	83 c4 08             	add    $0x8,%esp
  803009:	50                   	push   %eax
  80300a:	6a 00                	push   $0x0
  80300c:	e8 dd e5 ff ff       	call   8015ee <sys_page_unmap>
}
  803011:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803014:	c9                   	leave  
  803015:	c3                   	ret    

00803016 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  803016:	55                   	push   %ebp
  803017:	89 e5                	mov    %esp,%ebp
  803019:	57                   	push   %edi
  80301a:	56                   	push   %esi
  80301b:	53                   	push   %ebx
  80301c:	83 ec 1c             	sub    $0x1c,%esp
  80301f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  803022:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  803024:	a1 28 54 80 00       	mov    0x805428,%eax
  803029:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80302c:	83 ec 0c             	sub    $0xc,%esp
  80302f:	ff 75 e0             	pushl  -0x20(%ebp)
  803032:	e8 7e 04 00 00       	call   8034b5 <pageref>
  803037:	89 c3                	mov    %eax,%ebx
  803039:	89 3c 24             	mov    %edi,(%esp)
  80303c:	e8 74 04 00 00       	call   8034b5 <pageref>
  803041:	83 c4 10             	add    $0x10,%esp
  803044:	39 c3                	cmp    %eax,%ebx
  803046:	0f 94 c1             	sete   %cl
  803049:	0f b6 c9             	movzbl %cl,%ecx
  80304c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80304f:	8b 15 28 54 80 00    	mov    0x805428,%edx
  803055:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  803058:	39 ce                	cmp    %ecx,%esi
  80305a:	74 1b                	je     803077 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80305c:	39 c3                	cmp    %eax,%ebx
  80305e:	75 c4                	jne    803024 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803060:	8b 42 58             	mov    0x58(%edx),%eax
  803063:	ff 75 e4             	pushl  -0x1c(%ebp)
  803066:	50                   	push   %eax
  803067:	56                   	push   %esi
  803068:	68 2c 3f 80 00       	push   $0x803f2c
  80306d:	e8 7c da ff ff       	call   800aee <cprintf>
  803072:	83 c4 10             	add    $0x10,%esp
  803075:	eb ad                	jmp    803024 <_pipeisclosed+0xe>
	}
}
  803077:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80307a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80307d:	5b                   	pop    %ebx
  80307e:	5e                   	pop    %esi
  80307f:	5f                   	pop    %edi
  803080:	5d                   	pop    %ebp
  803081:	c3                   	ret    

00803082 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803082:	55                   	push   %ebp
  803083:	89 e5                	mov    %esp,%ebp
  803085:	57                   	push   %edi
  803086:	56                   	push   %esi
  803087:	53                   	push   %ebx
  803088:	83 ec 28             	sub    $0x28,%esp
  80308b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80308e:	56                   	push   %esi
  80308f:	e8 c3 eb ff ff       	call   801c57 <fd2data>
  803094:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803096:	83 c4 10             	add    $0x10,%esp
  803099:	bf 00 00 00 00       	mov    $0x0,%edi
  80309e:	eb 4b                	jmp    8030eb <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8030a0:	89 da                	mov    %ebx,%edx
  8030a2:	89 f0                	mov    %esi,%eax
  8030a4:	e8 6d ff ff ff       	call   803016 <_pipeisclosed>
  8030a9:	85 c0                	test   %eax,%eax
  8030ab:	75 48                	jne    8030f5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8030ad:	e8 98 e4 ff ff       	call   80154a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8030b2:	8b 43 04             	mov    0x4(%ebx),%eax
  8030b5:	8b 0b                	mov    (%ebx),%ecx
  8030b7:	8d 51 20             	lea    0x20(%ecx),%edx
  8030ba:	39 d0                	cmp    %edx,%eax
  8030bc:	73 e2                	jae    8030a0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8030be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8030c1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8030c5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8030c8:	89 c2                	mov    %eax,%edx
  8030ca:	c1 fa 1f             	sar    $0x1f,%edx
  8030cd:	89 d1                	mov    %edx,%ecx
  8030cf:	c1 e9 1b             	shr    $0x1b,%ecx
  8030d2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8030d5:	83 e2 1f             	and    $0x1f,%edx
  8030d8:	29 ca                	sub    %ecx,%edx
  8030da:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8030de:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8030e2:	83 c0 01             	add    $0x1,%eax
  8030e5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8030e8:	83 c7 01             	add    $0x1,%edi
  8030eb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8030ee:	75 c2                	jne    8030b2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8030f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8030f3:	eb 05                	jmp    8030fa <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8030f5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8030fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8030fd:	5b                   	pop    %ebx
  8030fe:	5e                   	pop    %esi
  8030ff:	5f                   	pop    %edi
  803100:	5d                   	pop    %ebp
  803101:	c3                   	ret    

00803102 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803102:	55                   	push   %ebp
  803103:	89 e5                	mov    %esp,%ebp
  803105:	57                   	push   %edi
  803106:	56                   	push   %esi
  803107:	53                   	push   %ebx
  803108:	83 ec 18             	sub    $0x18,%esp
  80310b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80310e:	57                   	push   %edi
  80310f:	e8 43 eb ff ff       	call   801c57 <fd2data>
  803114:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803116:	83 c4 10             	add    $0x10,%esp
  803119:	bb 00 00 00 00       	mov    $0x0,%ebx
  80311e:	eb 3d                	jmp    80315d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  803120:	85 db                	test   %ebx,%ebx
  803122:	74 04                	je     803128 <devpipe_read+0x26>
				return i;
  803124:	89 d8                	mov    %ebx,%eax
  803126:	eb 44                	jmp    80316c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  803128:	89 f2                	mov    %esi,%edx
  80312a:	89 f8                	mov    %edi,%eax
  80312c:	e8 e5 fe ff ff       	call   803016 <_pipeisclosed>
  803131:	85 c0                	test   %eax,%eax
  803133:	75 32                	jne    803167 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  803135:	e8 10 e4 ff ff       	call   80154a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80313a:	8b 06                	mov    (%esi),%eax
  80313c:	3b 46 04             	cmp    0x4(%esi),%eax
  80313f:	74 df                	je     803120 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803141:	99                   	cltd   
  803142:	c1 ea 1b             	shr    $0x1b,%edx
  803145:	01 d0                	add    %edx,%eax
  803147:	83 e0 1f             	and    $0x1f,%eax
  80314a:	29 d0                	sub    %edx,%eax
  80314c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  803151:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803154:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  803157:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80315a:	83 c3 01             	add    $0x1,%ebx
  80315d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803160:	75 d8                	jne    80313a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803162:	8b 45 10             	mov    0x10(%ebp),%eax
  803165:	eb 05                	jmp    80316c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803167:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80316c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80316f:	5b                   	pop    %ebx
  803170:	5e                   	pop    %esi
  803171:	5f                   	pop    %edi
  803172:	5d                   	pop    %ebp
  803173:	c3                   	ret    

00803174 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803174:	55                   	push   %ebp
  803175:	89 e5                	mov    %esp,%ebp
  803177:	56                   	push   %esi
  803178:	53                   	push   %ebx
  803179:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80317c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80317f:	50                   	push   %eax
  803180:	e8 e9 ea ff ff       	call   801c6e <fd_alloc>
  803185:	83 c4 10             	add    $0x10,%esp
  803188:	89 c2                	mov    %eax,%edx
  80318a:	85 c0                	test   %eax,%eax
  80318c:	0f 88 2c 01 00 00    	js     8032be <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803192:	83 ec 04             	sub    $0x4,%esp
  803195:	68 07 04 00 00       	push   $0x407
  80319a:	ff 75 f4             	pushl  -0xc(%ebp)
  80319d:	6a 00                	push   $0x0
  80319f:	e8 c5 e3 ff ff       	call   801569 <sys_page_alloc>
  8031a4:	83 c4 10             	add    $0x10,%esp
  8031a7:	89 c2                	mov    %eax,%edx
  8031a9:	85 c0                	test   %eax,%eax
  8031ab:	0f 88 0d 01 00 00    	js     8032be <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8031b1:	83 ec 0c             	sub    $0xc,%esp
  8031b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8031b7:	50                   	push   %eax
  8031b8:	e8 b1 ea ff ff       	call   801c6e <fd_alloc>
  8031bd:	89 c3                	mov    %eax,%ebx
  8031bf:	83 c4 10             	add    $0x10,%esp
  8031c2:	85 c0                	test   %eax,%eax
  8031c4:	0f 88 e2 00 00 00    	js     8032ac <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8031ca:	83 ec 04             	sub    $0x4,%esp
  8031cd:	68 07 04 00 00       	push   $0x407
  8031d2:	ff 75 f0             	pushl  -0x10(%ebp)
  8031d5:	6a 00                	push   $0x0
  8031d7:	e8 8d e3 ff ff       	call   801569 <sys_page_alloc>
  8031dc:	89 c3                	mov    %eax,%ebx
  8031de:	83 c4 10             	add    $0x10,%esp
  8031e1:	85 c0                	test   %eax,%eax
  8031e3:	0f 88 c3 00 00 00    	js     8032ac <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8031e9:	83 ec 0c             	sub    $0xc,%esp
  8031ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8031ef:	e8 63 ea ff ff       	call   801c57 <fd2data>
  8031f4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8031f6:	83 c4 0c             	add    $0xc,%esp
  8031f9:	68 07 04 00 00       	push   $0x407
  8031fe:	50                   	push   %eax
  8031ff:	6a 00                	push   $0x0
  803201:	e8 63 e3 ff ff       	call   801569 <sys_page_alloc>
  803206:	89 c3                	mov    %eax,%ebx
  803208:	83 c4 10             	add    $0x10,%esp
  80320b:	85 c0                	test   %eax,%eax
  80320d:	0f 88 89 00 00 00    	js     80329c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803213:	83 ec 0c             	sub    $0xc,%esp
  803216:	ff 75 f0             	pushl  -0x10(%ebp)
  803219:	e8 39 ea ff ff       	call   801c57 <fd2data>
  80321e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  803225:	50                   	push   %eax
  803226:	6a 00                	push   $0x0
  803228:	56                   	push   %esi
  803229:	6a 00                	push   $0x0
  80322b:	e8 7c e3 ff ff       	call   8015ac <sys_page_map>
  803230:	89 c3                	mov    %eax,%ebx
  803232:	83 c4 20             	add    $0x20,%esp
  803235:	85 c0                	test   %eax,%eax
  803237:	78 55                	js     80328e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  803239:	8b 15 58 40 80 00    	mov    0x804058,%edx
  80323f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803242:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803244:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803247:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80324e:	8b 15 58 40 80 00    	mov    0x804058,%edx
  803254:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803257:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  803259:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80325c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803263:	83 ec 0c             	sub    $0xc,%esp
  803266:	ff 75 f4             	pushl  -0xc(%ebp)
  803269:	e8 d9 e9 ff ff       	call   801c47 <fd2num>
  80326e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803271:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  803273:	83 c4 04             	add    $0x4,%esp
  803276:	ff 75 f0             	pushl  -0x10(%ebp)
  803279:	e8 c9 e9 ff ff       	call   801c47 <fd2num>
  80327e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803281:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803284:	83 c4 10             	add    $0x10,%esp
  803287:	ba 00 00 00 00       	mov    $0x0,%edx
  80328c:	eb 30                	jmp    8032be <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80328e:	83 ec 08             	sub    $0x8,%esp
  803291:	56                   	push   %esi
  803292:	6a 00                	push   $0x0
  803294:	e8 55 e3 ff ff       	call   8015ee <sys_page_unmap>
  803299:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80329c:	83 ec 08             	sub    $0x8,%esp
  80329f:	ff 75 f0             	pushl  -0x10(%ebp)
  8032a2:	6a 00                	push   $0x0
  8032a4:	e8 45 e3 ff ff       	call   8015ee <sys_page_unmap>
  8032a9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8032ac:	83 ec 08             	sub    $0x8,%esp
  8032af:	ff 75 f4             	pushl  -0xc(%ebp)
  8032b2:	6a 00                	push   $0x0
  8032b4:	e8 35 e3 ff ff       	call   8015ee <sys_page_unmap>
  8032b9:	83 c4 10             	add    $0x10,%esp
  8032bc:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8032be:	89 d0                	mov    %edx,%eax
  8032c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8032c3:	5b                   	pop    %ebx
  8032c4:	5e                   	pop    %esi
  8032c5:	5d                   	pop    %ebp
  8032c6:	c3                   	ret    

008032c7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8032c7:	55                   	push   %ebp
  8032c8:	89 e5                	mov    %esp,%ebp
  8032ca:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8032cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8032d0:	50                   	push   %eax
  8032d1:	ff 75 08             	pushl  0x8(%ebp)
  8032d4:	e8 e4 e9 ff ff       	call   801cbd <fd_lookup>
  8032d9:	83 c4 10             	add    $0x10,%esp
  8032dc:	85 c0                	test   %eax,%eax
  8032de:	78 18                	js     8032f8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8032e0:	83 ec 0c             	sub    $0xc,%esp
  8032e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8032e6:	e8 6c e9 ff ff       	call   801c57 <fd2data>
	return _pipeisclosed(fd, p);
  8032eb:	89 c2                	mov    %eax,%edx
  8032ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8032f0:	e8 21 fd ff ff       	call   803016 <_pipeisclosed>
  8032f5:	83 c4 10             	add    $0x10,%esp
}
  8032f8:	c9                   	leave  
  8032f9:	c3                   	ret    

008032fa <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8032fa:	55                   	push   %ebp
  8032fb:	89 e5                	mov    %esp,%ebp
  8032fd:	56                   	push   %esi
  8032fe:	53                   	push   %ebx
  8032ff:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  803302:	85 f6                	test   %esi,%esi
  803304:	75 16                	jne    80331c <wait+0x22>
  803306:	68 44 3f 80 00       	push   $0x803f44
  80330b:	68 c6 38 80 00       	push   $0x8038c6
  803310:	6a 09                	push   $0x9
  803312:	68 4f 3f 80 00       	push   $0x803f4f
  803317:	e8 f9 d6 ff ff       	call   800a15 <_panic>
	e = &envs[ENVX(envid)];
  80331c:	89 f3                	mov    %esi,%ebx
  80331e:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  803324:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  803327:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80332d:	eb 05                	jmp    803334 <wait+0x3a>
		sys_yield();
  80332f:	e8 16 e2 ff ff       	call   80154a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  803334:	8b 43 48             	mov    0x48(%ebx),%eax
  803337:	39 c6                	cmp    %eax,%esi
  803339:	75 07                	jne    803342 <wait+0x48>
  80333b:	8b 43 54             	mov    0x54(%ebx),%eax
  80333e:	85 c0                	test   %eax,%eax
  803340:	75 ed                	jne    80332f <wait+0x35>
		sys_yield();
}
  803342:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803345:	5b                   	pop    %ebx
  803346:	5e                   	pop    %esi
  803347:	5d                   	pop    %ebp
  803348:	c3                   	ret    

00803349 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  803349:	55                   	push   %ebp
  80334a:	89 e5                	mov    %esp,%ebp
  80334c:	53                   	push   %ebx
  80334d:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  803350:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  803357:	75 28                	jne    803381 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  803359:	e8 cd e1 ff ff       	call   80152b <sys_getenvid>
  80335e:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  803360:	83 ec 04             	sub    $0x4,%esp
  803363:	6a 06                	push   $0x6
  803365:	68 00 f0 bf ee       	push   $0xeebff000
  80336a:	50                   	push   %eax
  80336b:	e8 f9 e1 ff ff       	call   801569 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  803370:	83 c4 08             	add    $0x8,%esp
  803373:	68 8e 33 80 00       	push   $0x80338e
  803378:	53                   	push   %ebx
  803379:	e8 36 e3 ff ff       	call   8016b4 <sys_env_set_pgfault_upcall>
  80337e:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  803381:	8b 45 08             	mov    0x8(%ebp),%eax
  803384:	a3 00 80 80 00       	mov    %eax,0x808000
}
  803389:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80338c:	c9                   	leave  
  80338d:	c3                   	ret    

0080338e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80338e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80338f:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  803394:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  803396:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  803399:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  80339b:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  80339e:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  8033a1:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  8033a4:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  8033a7:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  8033aa:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  8033ad:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  8033b0:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  8033b3:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  8033b6:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  8033b9:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  8033bc:	61                   	popa   
	popfl
  8033bd:	9d                   	popf   
	ret
  8033be:	c3                   	ret    

008033bf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8033bf:	55                   	push   %ebp
  8033c0:	89 e5                	mov    %esp,%ebp
  8033c2:	56                   	push   %esi
  8033c3:	53                   	push   %ebx
  8033c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8033c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8033ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  8033cd:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8033cf:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  8033d4:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  8033d7:	83 ec 0c             	sub    $0xc,%esp
  8033da:	50                   	push   %eax
  8033db:	e8 39 e3 ff ff       	call   801719 <sys_ipc_recv>

	if (r < 0) {
  8033e0:	83 c4 10             	add    $0x10,%esp
  8033e3:	85 c0                	test   %eax,%eax
  8033e5:	79 16                	jns    8033fd <ipc_recv+0x3e>
		if (from_env_store)
  8033e7:	85 f6                	test   %esi,%esi
  8033e9:	74 06                	je     8033f1 <ipc_recv+0x32>
			*from_env_store = 0;
  8033eb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  8033f1:	85 db                	test   %ebx,%ebx
  8033f3:	74 2c                	je     803421 <ipc_recv+0x62>
			*perm_store = 0;
  8033f5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8033fb:	eb 24                	jmp    803421 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  8033fd:	85 f6                	test   %esi,%esi
  8033ff:	74 0a                	je     80340b <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  803401:	a1 28 54 80 00       	mov    0x805428,%eax
  803406:	8b 40 74             	mov    0x74(%eax),%eax
  803409:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  80340b:	85 db                	test   %ebx,%ebx
  80340d:	74 0a                	je     803419 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  80340f:	a1 28 54 80 00       	mov    0x805428,%eax
  803414:	8b 40 78             	mov    0x78(%eax),%eax
  803417:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  803419:	a1 28 54 80 00       	mov    0x805428,%eax
  80341e:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  803421:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803424:	5b                   	pop    %ebx
  803425:	5e                   	pop    %esi
  803426:	5d                   	pop    %ebp
  803427:	c3                   	ret    

00803428 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  803428:	55                   	push   %ebp
  803429:	89 e5                	mov    %esp,%ebp
  80342b:	57                   	push   %edi
  80342c:	56                   	push   %esi
  80342d:	53                   	push   %ebx
  80342e:	83 ec 0c             	sub    $0xc,%esp
  803431:	8b 7d 08             	mov    0x8(%ebp),%edi
  803434:	8b 75 0c             	mov    0xc(%ebp),%esi
  803437:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  80343a:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80343c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  803441:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  803444:	ff 75 14             	pushl  0x14(%ebp)
  803447:	53                   	push   %ebx
  803448:	56                   	push   %esi
  803449:	57                   	push   %edi
  80344a:	e8 a7 e2 ff ff       	call   8016f6 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  80344f:	83 c4 10             	add    $0x10,%esp
  803452:	83 f8 f9             	cmp    $0xfffffff9,%eax
  803455:	75 07                	jne    80345e <ipc_send+0x36>
			sys_yield();
  803457:	e8 ee e0 ff ff       	call   80154a <sys_yield>
  80345c:	eb e6                	jmp    803444 <ipc_send+0x1c>
		} else if (r < 0) {
  80345e:	85 c0                	test   %eax,%eax
  803460:	79 12                	jns    803474 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  803462:	50                   	push   %eax
  803463:	68 5a 3f 80 00       	push   $0x803f5a
  803468:	6a 51                	push   $0x51
  80346a:	68 67 3f 80 00       	push   $0x803f67
  80346f:	e8 a1 d5 ff ff       	call   800a15 <_panic>
		}
	}
}
  803474:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803477:	5b                   	pop    %ebx
  803478:	5e                   	pop    %esi
  803479:	5f                   	pop    %edi
  80347a:	5d                   	pop    %ebp
  80347b:	c3                   	ret    

0080347c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80347c:	55                   	push   %ebp
  80347d:	89 e5                	mov    %esp,%ebp
  80347f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  803482:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  803487:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80348a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  803490:	8b 52 50             	mov    0x50(%edx),%edx
  803493:	39 ca                	cmp    %ecx,%edx
  803495:	75 0d                	jne    8034a4 <ipc_find_env+0x28>
			return envs[i].env_id;
  803497:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80349a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80349f:	8b 40 48             	mov    0x48(%eax),%eax
  8034a2:	eb 0f                	jmp    8034b3 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8034a4:	83 c0 01             	add    $0x1,%eax
  8034a7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8034ac:	75 d9                	jne    803487 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8034ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8034b3:	5d                   	pop    %ebp
  8034b4:	c3                   	ret    

008034b5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8034b5:	55                   	push   %ebp
  8034b6:	89 e5                	mov    %esp,%ebp
  8034b8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8034bb:	89 d0                	mov    %edx,%eax
  8034bd:	c1 e8 16             	shr    $0x16,%eax
  8034c0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8034c7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8034cc:	f6 c1 01             	test   $0x1,%cl
  8034cf:	74 1d                	je     8034ee <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8034d1:	c1 ea 0c             	shr    $0xc,%edx
  8034d4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8034db:	f6 c2 01             	test   $0x1,%dl
  8034de:	74 0e                	je     8034ee <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8034e0:	c1 ea 0c             	shr    $0xc,%edx
  8034e3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8034ea:	ef 
  8034eb:	0f b7 c0             	movzwl %ax,%eax
}
  8034ee:	5d                   	pop    %ebp
  8034ef:	c3                   	ret    

008034f0 <__udivdi3>:
  8034f0:	55                   	push   %ebp
  8034f1:	57                   	push   %edi
  8034f2:	56                   	push   %esi
  8034f3:	53                   	push   %ebx
  8034f4:	83 ec 1c             	sub    $0x1c,%esp
  8034f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8034fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8034ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803503:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803507:	85 f6                	test   %esi,%esi
  803509:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80350d:	89 ca                	mov    %ecx,%edx
  80350f:	89 f8                	mov    %edi,%eax
  803511:	75 3d                	jne    803550 <__udivdi3+0x60>
  803513:	39 cf                	cmp    %ecx,%edi
  803515:	0f 87 c5 00 00 00    	ja     8035e0 <__udivdi3+0xf0>
  80351b:	85 ff                	test   %edi,%edi
  80351d:	89 fd                	mov    %edi,%ebp
  80351f:	75 0b                	jne    80352c <__udivdi3+0x3c>
  803521:	b8 01 00 00 00       	mov    $0x1,%eax
  803526:	31 d2                	xor    %edx,%edx
  803528:	f7 f7                	div    %edi
  80352a:	89 c5                	mov    %eax,%ebp
  80352c:	89 c8                	mov    %ecx,%eax
  80352e:	31 d2                	xor    %edx,%edx
  803530:	f7 f5                	div    %ebp
  803532:	89 c1                	mov    %eax,%ecx
  803534:	89 d8                	mov    %ebx,%eax
  803536:	89 cf                	mov    %ecx,%edi
  803538:	f7 f5                	div    %ebp
  80353a:	89 c3                	mov    %eax,%ebx
  80353c:	89 d8                	mov    %ebx,%eax
  80353e:	89 fa                	mov    %edi,%edx
  803540:	83 c4 1c             	add    $0x1c,%esp
  803543:	5b                   	pop    %ebx
  803544:	5e                   	pop    %esi
  803545:	5f                   	pop    %edi
  803546:	5d                   	pop    %ebp
  803547:	c3                   	ret    
  803548:	90                   	nop
  803549:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803550:	39 ce                	cmp    %ecx,%esi
  803552:	77 74                	ja     8035c8 <__udivdi3+0xd8>
  803554:	0f bd fe             	bsr    %esi,%edi
  803557:	83 f7 1f             	xor    $0x1f,%edi
  80355a:	0f 84 98 00 00 00    	je     8035f8 <__udivdi3+0x108>
  803560:	bb 20 00 00 00       	mov    $0x20,%ebx
  803565:	89 f9                	mov    %edi,%ecx
  803567:	89 c5                	mov    %eax,%ebp
  803569:	29 fb                	sub    %edi,%ebx
  80356b:	d3 e6                	shl    %cl,%esi
  80356d:	89 d9                	mov    %ebx,%ecx
  80356f:	d3 ed                	shr    %cl,%ebp
  803571:	89 f9                	mov    %edi,%ecx
  803573:	d3 e0                	shl    %cl,%eax
  803575:	09 ee                	or     %ebp,%esi
  803577:	89 d9                	mov    %ebx,%ecx
  803579:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80357d:	89 d5                	mov    %edx,%ebp
  80357f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803583:	d3 ed                	shr    %cl,%ebp
  803585:	89 f9                	mov    %edi,%ecx
  803587:	d3 e2                	shl    %cl,%edx
  803589:	89 d9                	mov    %ebx,%ecx
  80358b:	d3 e8                	shr    %cl,%eax
  80358d:	09 c2                	or     %eax,%edx
  80358f:	89 d0                	mov    %edx,%eax
  803591:	89 ea                	mov    %ebp,%edx
  803593:	f7 f6                	div    %esi
  803595:	89 d5                	mov    %edx,%ebp
  803597:	89 c3                	mov    %eax,%ebx
  803599:	f7 64 24 0c          	mull   0xc(%esp)
  80359d:	39 d5                	cmp    %edx,%ebp
  80359f:	72 10                	jb     8035b1 <__udivdi3+0xc1>
  8035a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8035a5:	89 f9                	mov    %edi,%ecx
  8035a7:	d3 e6                	shl    %cl,%esi
  8035a9:	39 c6                	cmp    %eax,%esi
  8035ab:	73 07                	jae    8035b4 <__udivdi3+0xc4>
  8035ad:	39 d5                	cmp    %edx,%ebp
  8035af:	75 03                	jne    8035b4 <__udivdi3+0xc4>
  8035b1:	83 eb 01             	sub    $0x1,%ebx
  8035b4:	31 ff                	xor    %edi,%edi
  8035b6:	89 d8                	mov    %ebx,%eax
  8035b8:	89 fa                	mov    %edi,%edx
  8035ba:	83 c4 1c             	add    $0x1c,%esp
  8035bd:	5b                   	pop    %ebx
  8035be:	5e                   	pop    %esi
  8035bf:	5f                   	pop    %edi
  8035c0:	5d                   	pop    %ebp
  8035c1:	c3                   	ret    
  8035c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8035c8:	31 ff                	xor    %edi,%edi
  8035ca:	31 db                	xor    %ebx,%ebx
  8035cc:	89 d8                	mov    %ebx,%eax
  8035ce:	89 fa                	mov    %edi,%edx
  8035d0:	83 c4 1c             	add    $0x1c,%esp
  8035d3:	5b                   	pop    %ebx
  8035d4:	5e                   	pop    %esi
  8035d5:	5f                   	pop    %edi
  8035d6:	5d                   	pop    %ebp
  8035d7:	c3                   	ret    
  8035d8:	90                   	nop
  8035d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8035e0:	89 d8                	mov    %ebx,%eax
  8035e2:	f7 f7                	div    %edi
  8035e4:	31 ff                	xor    %edi,%edi
  8035e6:	89 c3                	mov    %eax,%ebx
  8035e8:	89 d8                	mov    %ebx,%eax
  8035ea:	89 fa                	mov    %edi,%edx
  8035ec:	83 c4 1c             	add    $0x1c,%esp
  8035ef:	5b                   	pop    %ebx
  8035f0:	5e                   	pop    %esi
  8035f1:	5f                   	pop    %edi
  8035f2:	5d                   	pop    %ebp
  8035f3:	c3                   	ret    
  8035f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8035f8:	39 ce                	cmp    %ecx,%esi
  8035fa:	72 0c                	jb     803608 <__udivdi3+0x118>
  8035fc:	31 db                	xor    %ebx,%ebx
  8035fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803602:	0f 87 34 ff ff ff    	ja     80353c <__udivdi3+0x4c>
  803608:	bb 01 00 00 00       	mov    $0x1,%ebx
  80360d:	e9 2a ff ff ff       	jmp    80353c <__udivdi3+0x4c>
  803612:	66 90                	xchg   %ax,%ax
  803614:	66 90                	xchg   %ax,%ax
  803616:	66 90                	xchg   %ax,%ax
  803618:	66 90                	xchg   %ax,%ax
  80361a:	66 90                	xchg   %ax,%ax
  80361c:	66 90                	xchg   %ax,%ax
  80361e:	66 90                	xchg   %ax,%ax

00803620 <__umoddi3>:
  803620:	55                   	push   %ebp
  803621:	57                   	push   %edi
  803622:	56                   	push   %esi
  803623:	53                   	push   %ebx
  803624:	83 ec 1c             	sub    $0x1c,%esp
  803627:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80362b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80362f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803633:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803637:	85 d2                	test   %edx,%edx
  803639:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80363d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803641:	89 f3                	mov    %esi,%ebx
  803643:	89 3c 24             	mov    %edi,(%esp)
  803646:	89 74 24 04          	mov    %esi,0x4(%esp)
  80364a:	75 1c                	jne    803668 <__umoddi3+0x48>
  80364c:	39 f7                	cmp    %esi,%edi
  80364e:	76 50                	jbe    8036a0 <__umoddi3+0x80>
  803650:	89 c8                	mov    %ecx,%eax
  803652:	89 f2                	mov    %esi,%edx
  803654:	f7 f7                	div    %edi
  803656:	89 d0                	mov    %edx,%eax
  803658:	31 d2                	xor    %edx,%edx
  80365a:	83 c4 1c             	add    $0x1c,%esp
  80365d:	5b                   	pop    %ebx
  80365e:	5e                   	pop    %esi
  80365f:	5f                   	pop    %edi
  803660:	5d                   	pop    %ebp
  803661:	c3                   	ret    
  803662:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803668:	39 f2                	cmp    %esi,%edx
  80366a:	89 d0                	mov    %edx,%eax
  80366c:	77 52                	ja     8036c0 <__umoddi3+0xa0>
  80366e:	0f bd ea             	bsr    %edx,%ebp
  803671:	83 f5 1f             	xor    $0x1f,%ebp
  803674:	75 5a                	jne    8036d0 <__umoddi3+0xb0>
  803676:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80367a:	0f 82 e0 00 00 00    	jb     803760 <__umoddi3+0x140>
  803680:	39 0c 24             	cmp    %ecx,(%esp)
  803683:	0f 86 d7 00 00 00    	jbe    803760 <__umoddi3+0x140>
  803689:	8b 44 24 08          	mov    0x8(%esp),%eax
  80368d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803691:	83 c4 1c             	add    $0x1c,%esp
  803694:	5b                   	pop    %ebx
  803695:	5e                   	pop    %esi
  803696:	5f                   	pop    %edi
  803697:	5d                   	pop    %ebp
  803698:	c3                   	ret    
  803699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8036a0:	85 ff                	test   %edi,%edi
  8036a2:	89 fd                	mov    %edi,%ebp
  8036a4:	75 0b                	jne    8036b1 <__umoddi3+0x91>
  8036a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8036ab:	31 d2                	xor    %edx,%edx
  8036ad:	f7 f7                	div    %edi
  8036af:	89 c5                	mov    %eax,%ebp
  8036b1:	89 f0                	mov    %esi,%eax
  8036b3:	31 d2                	xor    %edx,%edx
  8036b5:	f7 f5                	div    %ebp
  8036b7:	89 c8                	mov    %ecx,%eax
  8036b9:	f7 f5                	div    %ebp
  8036bb:	89 d0                	mov    %edx,%eax
  8036bd:	eb 99                	jmp    803658 <__umoddi3+0x38>
  8036bf:	90                   	nop
  8036c0:	89 c8                	mov    %ecx,%eax
  8036c2:	89 f2                	mov    %esi,%edx
  8036c4:	83 c4 1c             	add    $0x1c,%esp
  8036c7:	5b                   	pop    %ebx
  8036c8:	5e                   	pop    %esi
  8036c9:	5f                   	pop    %edi
  8036ca:	5d                   	pop    %ebp
  8036cb:	c3                   	ret    
  8036cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8036d0:	8b 34 24             	mov    (%esp),%esi
  8036d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8036d8:	89 e9                	mov    %ebp,%ecx
  8036da:	29 ef                	sub    %ebp,%edi
  8036dc:	d3 e0                	shl    %cl,%eax
  8036de:	89 f9                	mov    %edi,%ecx
  8036e0:	89 f2                	mov    %esi,%edx
  8036e2:	d3 ea                	shr    %cl,%edx
  8036e4:	89 e9                	mov    %ebp,%ecx
  8036e6:	09 c2                	or     %eax,%edx
  8036e8:	89 d8                	mov    %ebx,%eax
  8036ea:	89 14 24             	mov    %edx,(%esp)
  8036ed:	89 f2                	mov    %esi,%edx
  8036ef:	d3 e2                	shl    %cl,%edx
  8036f1:	89 f9                	mov    %edi,%ecx
  8036f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8036f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8036fb:	d3 e8                	shr    %cl,%eax
  8036fd:	89 e9                	mov    %ebp,%ecx
  8036ff:	89 c6                	mov    %eax,%esi
  803701:	d3 e3                	shl    %cl,%ebx
  803703:	89 f9                	mov    %edi,%ecx
  803705:	89 d0                	mov    %edx,%eax
  803707:	d3 e8                	shr    %cl,%eax
  803709:	89 e9                	mov    %ebp,%ecx
  80370b:	09 d8                	or     %ebx,%eax
  80370d:	89 d3                	mov    %edx,%ebx
  80370f:	89 f2                	mov    %esi,%edx
  803711:	f7 34 24             	divl   (%esp)
  803714:	89 d6                	mov    %edx,%esi
  803716:	d3 e3                	shl    %cl,%ebx
  803718:	f7 64 24 04          	mull   0x4(%esp)
  80371c:	39 d6                	cmp    %edx,%esi
  80371e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803722:	89 d1                	mov    %edx,%ecx
  803724:	89 c3                	mov    %eax,%ebx
  803726:	72 08                	jb     803730 <__umoddi3+0x110>
  803728:	75 11                	jne    80373b <__umoddi3+0x11b>
  80372a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80372e:	73 0b                	jae    80373b <__umoddi3+0x11b>
  803730:	2b 44 24 04          	sub    0x4(%esp),%eax
  803734:	1b 14 24             	sbb    (%esp),%edx
  803737:	89 d1                	mov    %edx,%ecx
  803739:	89 c3                	mov    %eax,%ebx
  80373b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80373f:	29 da                	sub    %ebx,%edx
  803741:	19 ce                	sbb    %ecx,%esi
  803743:	89 f9                	mov    %edi,%ecx
  803745:	89 f0                	mov    %esi,%eax
  803747:	d3 e0                	shl    %cl,%eax
  803749:	89 e9                	mov    %ebp,%ecx
  80374b:	d3 ea                	shr    %cl,%edx
  80374d:	89 e9                	mov    %ebp,%ecx
  80374f:	d3 ee                	shr    %cl,%esi
  803751:	09 d0                	or     %edx,%eax
  803753:	89 f2                	mov    %esi,%edx
  803755:	83 c4 1c             	add    $0x1c,%esp
  803758:	5b                   	pop    %ebx
  803759:	5e                   	pop    %esi
  80375a:	5f                   	pop    %edi
  80375b:	5d                   	pop    %ebp
  80375c:	c3                   	ret    
  80375d:	8d 76 00             	lea    0x0(%esi),%esi
  803760:	29 f9                	sub    %edi,%ecx
  803762:	19 d6                	sbb    %edx,%esi
  803764:	89 74 24 04          	mov    %esi,0x4(%esp)
  803768:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80376c:	e9 18 ff ff ff       	jmp    803689 <__umoddi3+0x69>
