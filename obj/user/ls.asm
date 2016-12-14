
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 93 02 00 00       	call   8002c4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003b:	8b 75 0c             	mov    0xc(%ebp),%esi
	const char *sep;

	if(flag['l'])
  80003e:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  800045:	74 20                	je     800067 <ls1+0x34>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  800047:	89 f0                	mov    %esi,%eax
  800049:	3c 01                	cmp    $0x1,%al
  80004b:	19 c0                	sbb    %eax,%eax
  80004d:	83 e0 c9             	and    $0xffffffc9,%eax
  800050:	83 c0 64             	add    $0x64,%eax
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	50                   	push   %eax
  800057:	ff 75 10             	pushl  0x10(%ebp)
  80005a:	68 02 28 80 00       	push   $0x802802
  80005f:	e8 78 1a 00 00       	call   801adc <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 3a                	je     8000a5 <ls1+0x72>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006b:	b8 68 28 80 00       	mov    $0x802868,%eax
	const char *sep;

	if(flag['l'])
		printf("%11d %c ", size, isdir ? 'd' : '-');
	if(prefix) {
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800070:	80 3b 00             	cmpb   $0x0,(%ebx)
  800073:	74 1e                	je     800093 <ls1+0x60>
  800075:	83 ec 0c             	sub    $0xc,%esp
  800078:	53                   	push   %ebx
  800079:	e8 cb 08 00 00       	call   800949 <strlen>
  80007e:	83 c4 10             	add    $0x10,%esp
			sep = "/";
		else
			sep = "";
  800081:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800086:	ba 68 28 80 00       	mov    $0x802868,%edx
  80008b:	b8 00 28 80 00       	mov    $0x802800,%eax
  800090:	0f 44 c2             	cmove  %edx,%eax
		printf("%s%s", prefix, sep);
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	50                   	push   %eax
  800097:	53                   	push   %ebx
  800098:	68 0b 28 80 00       	push   $0x80280b
  80009d:	e8 3a 1a 00 00       	call   801adc <printf>
  8000a2:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	ff 75 14             	pushl  0x14(%ebp)
  8000ab:	68 9e 2c 80 00       	push   $0x802c9e
  8000b0:	e8 27 1a 00 00       	call   801adc <printf>
	if(flag['F'] && isdir)
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000bf:	74 16                	je     8000d7 <ls1+0xa4>
  8000c1:	89 f0                	mov    %esi,%eax
  8000c3:	84 c0                	test   %al,%al
  8000c5:	74 10                	je     8000d7 <ls1+0xa4>
		printf("/");
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	68 00 28 80 00       	push   $0x802800
  8000cf:	e8 08 1a 00 00       	call   801adc <printf>
  8000d4:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	68 67 28 80 00       	push   $0x802867
  8000df:	e8 f8 19 00 00       	call   801adc <printf>
}
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	57                   	push   %edi
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	81 ec 14 01 00 00    	sub    $0x114,%esp
  8000fa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  8000fd:	6a 00                	push   $0x0
  8000ff:	57                   	push   %edi
  800100:	e8 39 18 00 00       	call   80193e <open>
  800105:	89 c3                	mov    %eax,%ebx
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	85 c0                	test   %eax,%eax
  80010c:	79 41                	jns    80014f <lsdir+0x61>
		panic("open %s: %e", path, fd);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	57                   	push   %edi
  800113:	68 10 28 80 00       	push   $0x802810
  800118:	6a 1d                	push   $0x1d
  80011a:	68 1c 28 80 00       	push   $0x80281c
  80011f:	e8 00 02 00 00       	call   800324 <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  800124:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  80012b:	74 28                	je     800155 <lsdir+0x67>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  80012d:	56                   	push   %esi
  80012e:	ff b5 68 ff ff ff    	pushl  -0x98(%ebp)
  800134:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  80013b:	0f 94 c0             	sete   %al
  80013e:	0f b6 c0             	movzbl %al,%eax
  800141:	50                   	push   %eax
  800142:	ff 75 0c             	pushl  0xc(%ebp)
  800145:	e8 e9 fe ff ff       	call   800033 <ls1>
  80014a:	83 c4 10             	add    $0x10,%esp
  80014d:	eb 06                	jmp    800155 <lsdir+0x67>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80014f:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800155:	83 ec 04             	sub    $0x4,%esp
  800158:	68 00 01 00 00       	push   $0x100
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
  80015f:	e8 b7 13 00 00       	call   80151b <readn>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	3d 00 01 00 00       	cmp    $0x100,%eax
  80016c:	74 b6                	je     800124 <lsdir+0x36>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  80016e:	85 c0                	test   %eax,%eax
  800170:	7e 12                	jle    800184 <lsdir+0x96>
		panic("short read in directory %s", path);
  800172:	57                   	push   %edi
  800173:	68 26 28 80 00       	push   $0x802826
  800178:	6a 22                	push   $0x22
  80017a:	68 1c 28 80 00       	push   $0x80281c
  80017f:	e8 a0 01 00 00       	call   800324 <_panic>
	if (n < 0)
  800184:	85 c0                	test   %eax,%eax
  800186:	79 16                	jns    80019e <lsdir+0xb0>
		panic("error reading directory %s: %e", path, n);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	50                   	push   %eax
  80018c:	57                   	push   %edi
  80018d:	68 6c 28 80 00       	push   $0x80286c
  800192:	6a 24                	push   $0x24
  800194:	68 1c 28 80 00       	push   $0x80281c
  800199:	e8 86 01 00 00       	call   800324 <_panic>
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	53                   	push   %ebx
  8001aa:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  8001b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001b3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001b9:	50                   	push   %eax
  8001ba:	53                   	push   %ebx
  8001bb:	e8 60 15 00 00       	call   801720 <stat>
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	79 16                	jns    8001dd <ls+0x37>
		panic("stat %s: %e", path, r);
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	50                   	push   %eax
  8001cb:	53                   	push   %ebx
  8001cc:	68 41 28 80 00       	push   $0x802841
  8001d1:	6a 0f                	push   $0xf
  8001d3:	68 1c 28 80 00       	push   $0x80281c
  8001d8:	e8 47 01 00 00       	call   800324 <_panic>
	if (st.st_isdir && !flag['d'])
  8001dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001e0:	85 c0                	test   %eax,%eax
  8001e2:	74 1a                	je     8001fe <ls+0x58>
  8001e4:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  8001eb:	75 11                	jne    8001fe <ls+0x58>
		lsdir(path, prefix);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	ff 75 0c             	pushl  0xc(%ebp)
  8001f3:	53                   	push   %ebx
  8001f4:	e8 f5 fe ff ff       	call   8000ee <lsdir>
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	eb 17                	jmp    800215 <ls+0x6f>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  8001fe:	53                   	push   %ebx
  8001ff:	ff 75 ec             	pushl  -0x14(%ebp)
  800202:	85 c0                	test   %eax,%eax
  800204:	0f 95 c0             	setne  %al
  800207:	0f b6 c0             	movzbl %al,%eax
  80020a:	50                   	push   %eax
  80020b:	6a 00                	push   $0x0
  80020d:	e8 21 fe ff ff       	call   800033 <ls1>
  800212:	83 c4 10             	add    $0x10,%esp
}
  800215:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <usage>:
	printf("\n");
}

void
usage(void)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	83 ec 14             	sub    $0x14,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800220:	68 4d 28 80 00       	push   $0x80284d
  800225:	e8 b2 18 00 00       	call   801adc <printf>
	exit();
  80022a:	e8 db 00 00 00       	call   80030a <exit>
}
  80022f:	83 c4 10             	add    $0x10,%esp
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <umain>:

void
umain(int argc, char **argv)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 14             	sub    $0x14,%esp
  80023c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  80023f:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800242:	50                   	push   %eax
  800243:	56                   	push   %esi
  800244:	8d 45 08             	lea    0x8(%ebp),%eax
  800247:	50                   	push   %eax
  800248:	e8 0d 0e 00 00       	call   80105a <argstart>
	while ((i = argnext(&args)) >= 0)
  80024d:	83 c4 10             	add    $0x10,%esp
  800250:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  800253:	eb 1e                	jmp    800273 <umain+0x3f>
		switch (i) {
  800255:	83 f8 64             	cmp    $0x64,%eax
  800258:	74 0a                	je     800264 <umain+0x30>
  80025a:	83 f8 6c             	cmp    $0x6c,%eax
  80025d:	74 05                	je     800264 <umain+0x30>
  80025f:	83 f8 46             	cmp    $0x46,%eax
  800262:	75 0a                	jne    80026e <umain+0x3a>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  800264:	83 04 85 20 40 80 00 	addl   $0x1,0x804020(,%eax,4)
  80026b:	01 
			break;
  80026c:	eb 05                	jmp    800273 <umain+0x3f>
		default:
			usage();
  80026e:	e8 a7 ff ff ff       	call   80021a <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	53                   	push   %ebx
  800277:	e8 0e 0e 00 00       	call   80108a <argnext>
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	85 c0                	test   %eax,%eax
  800281:	79 d2                	jns    800255 <umain+0x21>
  800283:	bb 01 00 00 00       	mov    $0x1,%ebx
			break;
		default:
			usage();
		}

	if (argc == 1)
  800288:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80028c:	75 2a                	jne    8002b8 <umain+0x84>
		ls("/", "");
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	68 68 28 80 00       	push   $0x802868
  800296:	68 00 28 80 00       	push   $0x802800
  80029b:	e8 06 ff ff ff       	call   8001a6 <ls>
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	eb 18                	jmp    8002bd <umain+0x89>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  8002a5:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	50                   	push   %eax
  8002ac:	50                   	push   %eax
  8002ad:	e8 f4 fe ff ff       	call   8001a6 <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  8002b2:	83 c3 01             	add    $0x1,%ebx
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  8002bb:	7c e8                	jl     8002a5 <umain+0x71>
			ls(argv[i], argv[i]);
	}
}
  8002bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002cf:	e8 73 0a 00 00       	call   800d47 <sys_getenvid>
  8002d4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002dc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e1:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002e6:	85 db                	test   %ebx,%ebx
  8002e8:	7e 07                	jle    8002f1 <libmain+0x2d>
		binaryname = argv[0];
  8002ea:	8b 06                	mov    (%esi),%eax
  8002ec:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002f1:	83 ec 08             	sub    $0x8,%esp
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	e8 39 ff ff ff       	call   800234 <umain>

	// exit gracefully
	exit();
  8002fb:	e8 0a 00 00 00       	call   80030a <exit>
}
  800300:	83 c4 10             	add    $0x10,%esp
  800303:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800306:	5b                   	pop    %ebx
  800307:	5e                   	pop    %esi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800310:	e8 64 10 00 00       	call   801379 <close_all>
	sys_env_destroy(0);
  800315:	83 ec 0c             	sub    $0xc,%esp
  800318:	6a 00                	push   $0x0
  80031a:	e8 e7 09 00 00       	call   800d06 <sys_env_destroy>
}
  80031f:	83 c4 10             	add    $0x10,%esp
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800329:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80032c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800332:	e8 10 0a 00 00       	call   800d47 <sys_getenvid>
  800337:	83 ec 0c             	sub    $0xc,%esp
  80033a:	ff 75 0c             	pushl  0xc(%ebp)
  80033d:	ff 75 08             	pushl  0x8(%ebp)
  800340:	56                   	push   %esi
  800341:	50                   	push   %eax
  800342:	68 98 28 80 00       	push   $0x802898
  800347:	e8 b1 00 00 00       	call   8003fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80034c:	83 c4 18             	add    $0x18,%esp
  80034f:	53                   	push   %ebx
  800350:	ff 75 10             	pushl  0x10(%ebp)
  800353:	e8 54 00 00 00       	call   8003ac <vcprintf>
	cprintf("\n");
  800358:	c7 04 24 67 28 80 00 	movl   $0x802867,(%esp)
  80035f:	e8 99 00 00 00       	call   8003fd <cprintf>
  800364:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800367:	cc                   	int3   
  800368:	eb fd                	jmp    800367 <_panic+0x43>

0080036a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	53                   	push   %ebx
  80036e:	83 ec 04             	sub    $0x4,%esp
  800371:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800374:	8b 13                	mov    (%ebx),%edx
  800376:	8d 42 01             	lea    0x1(%edx),%eax
  800379:	89 03                	mov    %eax,(%ebx)
  80037b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800382:	3d ff 00 00 00       	cmp    $0xff,%eax
  800387:	75 1a                	jne    8003a3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800389:	83 ec 08             	sub    $0x8,%esp
  80038c:	68 ff 00 00 00       	push   $0xff
  800391:	8d 43 08             	lea    0x8(%ebx),%eax
  800394:	50                   	push   %eax
  800395:	e8 2f 09 00 00       	call   800cc9 <sys_cputs>
		b->idx = 0;
  80039a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003a0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003aa:	c9                   	leave  
  8003ab:	c3                   	ret    

008003ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003bc:	00 00 00 
	b.cnt = 0;
  8003bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c9:	ff 75 0c             	pushl  0xc(%ebp)
  8003cc:	ff 75 08             	pushl  0x8(%ebp)
  8003cf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003d5:	50                   	push   %eax
  8003d6:	68 6a 03 80 00       	push   $0x80036a
  8003db:	e8 54 01 00 00       	call   800534 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e0:	83 c4 08             	add    $0x8,%esp
  8003e3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ef:	50                   	push   %eax
  8003f0:	e8 d4 08 00 00       	call   800cc9 <sys_cputs>

	return b.cnt;
}
  8003f5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003fb:	c9                   	leave  
  8003fc:	c3                   	ret    

008003fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800403:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800406:	50                   	push   %eax
  800407:	ff 75 08             	pushl  0x8(%ebp)
  80040a:	e8 9d ff ff ff       	call   8003ac <vcprintf>
	va_end(ap);

	return cnt;
}
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	57                   	push   %edi
  800415:	56                   	push   %esi
  800416:	53                   	push   %ebx
  800417:	83 ec 1c             	sub    $0x1c,%esp
  80041a:	89 c7                	mov    %eax,%edi
  80041c:	89 d6                	mov    %edx,%esi
  80041e:	8b 45 08             	mov    0x8(%ebp),%eax
  800421:	8b 55 0c             	mov    0xc(%ebp),%edx
  800424:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800427:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80042a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80042d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800432:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800435:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800438:	39 d3                	cmp    %edx,%ebx
  80043a:	72 05                	jb     800441 <printnum+0x30>
  80043c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80043f:	77 45                	ja     800486 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800441:	83 ec 0c             	sub    $0xc,%esp
  800444:	ff 75 18             	pushl  0x18(%ebp)
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80044d:	53                   	push   %ebx
  80044e:	ff 75 10             	pushl  0x10(%ebp)
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	ff 75 e4             	pushl  -0x1c(%ebp)
  800457:	ff 75 e0             	pushl  -0x20(%ebp)
  80045a:	ff 75 dc             	pushl  -0x24(%ebp)
  80045d:	ff 75 d8             	pushl  -0x28(%ebp)
  800460:	e8 0b 21 00 00       	call   802570 <__udivdi3>
  800465:	83 c4 18             	add    $0x18,%esp
  800468:	52                   	push   %edx
  800469:	50                   	push   %eax
  80046a:	89 f2                	mov    %esi,%edx
  80046c:	89 f8                	mov    %edi,%eax
  80046e:	e8 9e ff ff ff       	call   800411 <printnum>
  800473:	83 c4 20             	add    $0x20,%esp
  800476:	eb 18                	jmp    800490 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	56                   	push   %esi
  80047c:	ff 75 18             	pushl  0x18(%ebp)
  80047f:	ff d7                	call   *%edi
  800481:	83 c4 10             	add    $0x10,%esp
  800484:	eb 03                	jmp    800489 <printnum+0x78>
  800486:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800489:	83 eb 01             	sub    $0x1,%ebx
  80048c:	85 db                	test   %ebx,%ebx
  80048e:	7f e8                	jg     800478 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	56                   	push   %esi
  800494:	83 ec 04             	sub    $0x4,%esp
  800497:	ff 75 e4             	pushl  -0x1c(%ebp)
  80049a:	ff 75 e0             	pushl  -0x20(%ebp)
  80049d:	ff 75 dc             	pushl  -0x24(%ebp)
  8004a0:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a3:	e8 f8 21 00 00       	call   8026a0 <__umoddi3>
  8004a8:	83 c4 14             	add    $0x14,%esp
  8004ab:	0f be 80 bb 28 80 00 	movsbl 0x8028bb(%eax),%eax
  8004b2:	50                   	push   %eax
  8004b3:	ff d7                	call   *%edi
}
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004bb:	5b                   	pop    %ebx
  8004bc:	5e                   	pop    %esi
  8004bd:	5f                   	pop    %edi
  8004be:	5d                   	pop    %ebp
  8004bf:	c3                   	ret    

008004c0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004c3:	83 fa 01             	cmp    $0x1,%edx
  8004c6:	7e 0e                	jle    8004d6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004c8:	8b 10                	mov    (%eax),%edx
  8004ca:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004cd:	89 08                	mov    %ecx,(%eax)
  8004cf:	8b 02                	mov    (%edx),%eax
  8004d1:	8b 52 04             	mov    0x4(%edx),%edx
  8004d4:	eb 22                	jmp    8004f8 <getuint+0x38>
	else if (lflag)
  8004d6:	85 d2                	test   %edx,%edx
  8004d8:	74 10                	je     8004ea <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004da:	8b 10                	mov    (%eax),%edx
  8004dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004df:	89 08                	mov    %ecx,(%eax)
  8004e1:	8b 02                	mov    (%edx),%eax
  8004e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e8:	eb 0e                	jmp    8004f8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004ea:	8b 10                	mov    (%eax),%edx
  8004ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ef:	89 08                	mov    %ecx,(%eax)
  8004f1:	8b 02                	mov    (%edx),%eax
  8004f3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f8:	5d                   	pop    %ebp
  8004f9:	c3                   	ret    

008004fa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800500:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800504:	8b 10                	mov    (%eax),%edx
  800506:	3b 50 04             	cmp    0x4(%eax),%edx
  800509:	73 0a                	jae    800515 <sprintputch+0x1b>
		*b->buf++ = ch;
  80050b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80050e:	89 08                	mov    %ecx,(%eax)
  800510:	8b 45 08             	mov    0x8(%ebp),%eax
  800513:	88 02                	mov    %al,(%edx)
}
  800515:	5d                   	pop    %ebp
  800516:	c3                   	ret    

00800517 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800517:	55                   	push   %ebp
  800518:	89 e5                	mov    %esp,%ebp
  80051a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80051d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800520:	50                   	push   %eax
  800521:	ff 75 10             	pushl  0x10(%ebp)
  800524:	ff 75 0c             	pushl  0xc(%ebp)
  800527:	ff 75 08             	pushl  0x8(%ebp)
  80052a:	e8 05 00 00 00       	call   800534 <vprintfmt>
	va_end(ap);
}
  80052f:	83 c4 10             	add    $0x10,%esp
  800532:	c9                   	leave  
  800533:	c3                   	ret    

00800534 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	57                   	push   %edi
  800538:	56                   	push   %esi
  800539:	53                   	push   %ebx
  80053a:	83 ec 2c             	sub    $0x2c,%esp
  80053d:	8b 75 08             	mov    0x8(%ebp),%esi
  800540:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800543:	8b 7d 10             	mov    0x10(%ebp),%edi
  800546:	eb 12                	jmp    80055a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800548:	85 c0                	test   %eax,%eax
  80054a:	0f 84 89 03 00 00    	je     8008d9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	53                   	push   %ebx
  800554:	50                   	push   %eax
  800555:	ff d6                	call   *%esi
  800557:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80055a:	83 c7 01             	add    $0x1,%edi
  80055d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800561:	83 f8 25             	cmp    $0x25,%eax
  800564:	75 e2                	jne    800548 <vprintfmt+0x14>
  800566:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80056a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800571:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800578:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80057f:	ba 00 00 00 00       	mov    $0x0,%edx
  800584:	eb 07                	jmp    80058d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800586:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800589:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8d 47 01             	lea    0x1(%edi),%eax
  800590:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800593:	0f b6 07             	movzbl (%edi),%eax
  800596:	0f b6 c8             	movzbl %al,%ecx
  800599:	83 e8 23             	sub    $0x23,%eax
  80059c:	3c 55                	cmp    $0x55,%al
  80059e:	0f 87 1a 03 00 00    	ja     8008be <vprintfmt+0x38a>
  8005a4:	0f b6 c0             	movzbl %al,%eax
  8005a7:	ff 24 85 00 2a 80 00 	jmp    *0x802a00(,%eax,4)
  8005ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005b1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005b5:	eb d6                	jmp    80058d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8005bf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005c2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005c5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005c9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005cc:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005cf:	83 fa 09             	cmp    $0x9,%edx
  8005d2:	77 39                	ja     80060d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005d4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005d7:	eb e9                	jmp    8005c2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8d 48 04             	lea    0x4(%eax),%ecx
  8005df:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005ea:	eb 27                	jmp    800613 <vprintfmt+0xdf>
  8005ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ef:	85 c0                	test   %eax,%eax
  8005f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f6:	0f 49 c8             	cmovns %eax,%ecx
  8005f9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ff:	eb 8c                	jmp    80058d <vprintfmt+0x59>
  800601:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800604:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80060b:	eb 80                	jmp    80058d <vprintfmt+0x59>
  80060d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800610:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800613:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800617:	0f 89 70 ff ff ff    	jns    80058d <vprintfmt+0x59>
				width = precision, precision = -1;
  80061d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800620:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800623:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80062a:	e9 5e ff ff ff       	jmp    80058d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80062f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800632:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800635:	e9 53 ff ff ff       	jmp    80058d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	53                   	push   %ebx
  800647:	ff 30                	pushl  (%eax)
  800649:	ff d6                	call   *%esi
			break;
  80064b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800651:	e9 04 ff ff ff       	jmp    80055a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 50 04             	lea    0x4(%eax),%edx
  80065c:	89 55 14             	mov    %edx,0x14(%ebp)
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	99                   	cltd   
  800662:	31 d0                	xor    %edx,%eax
  800664:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800666:	83 f8 0f             	cmp    $0xf,%eax
  800669:	7f 0b                	jg     800676 <vprintfmt+0x142>
  80066b:	8b 14 85 60 2b 80 00 	mov    0x802b60(,%eax,4),%edx
  800672:	85 d2                	test   %edx,%edx
  800674:	75 18                	jne    80068e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800676:	50                   	push   %eax
  800677:	68 d3 28 80 00       	push   $0x8028d3
  80067c:	53                   	push   %ebx
  80067d:	56                   	push   %esi
  80067e:	e8 94 fe ff ff       	call   800517 <printfmt>
  800683:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800686:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800689:	e9 cc fe ff ff       	jmp    80055a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80068e:	52                   	push   %edx
  80068f:	68 9e 2c 80 00       	push   $0x802c9e
  800694:	53                   	push   %ebx
  800695:	56                   	push   %esi
  800696:	e8 7c fe ff ff       	call   800517 <printfmt>
  80069b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a1:	e9 b4 fe ff ff       	jmp    80055a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8006af:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006b1:	85 ff                	test   %edi,%edi
  8006b3:	b8 cc 28 80 00       	mov    $0x8028cc,%eax
  8006b8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006bf:	0f 8e 94 00 00 00    	jle    800759 <vprintfmt+0x225>
  8006c5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006c9:	0f 84 98 00 00 00    	je     800767 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	ff 75 d0             	pushl  -0x30(%ebp)
  8006d5:	57                   	push   %edi
  8006d6:	e8 86 02 00 00       	call   800961 <strnlen>
  8006db:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006de:	29 c1                	sub    %eax,%ecx
  8006e0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006e3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006e6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ed:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006f0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f2:	eb 0f                	jmp    800703 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006f4:	83 ec 08             	sub    $0x8,%esp
  8006f7:	53                   	push   %ebx
  8006f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006fb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fd:	83 ef 01             	sub    $0x1,%edi
  800700:	83 c4 10             	add    $0x10,%esp
  800703:	85 ff                	test   %edi,%edi
  800705:	7f ed                	jg     8006f4 <vprintfmt+0x1c0>
  800707:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80070a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80070d:	85 c9                	test   %ecx,%ecx
  80070f:	b8 00 00 00 00       	mov    $0x0,%eax
  800714:	0f 49 c1             	cmovns %ecx,%eax
  800717:	29 c1                	sub    %eax,%ecx
  800719:	89 75 08             	mov    %esi,0x8(%ebp)
  80071c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80071f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800722:	89 cb                	mov    %ecx,%ebx
  800724:	eb 4d                	jmp    800773 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800726:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80072a:	74 1b                	je     800747 <vprintfmt+0x213>
  80072c:	0f be c0             	movsbl %al,%eax
  80072f:	83 e8 20             	sub    $0x20,%eax
  800732:	83 f8 5e             	cmp    $0x5e,%eax
  800735:	76 10                	jbe    800747 <vprintfmt+0x213>
					putch('?', putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	ff 75 0c             	pushl  0xc(%ebp)
  80073d:	6a 3f                	push   $0x3f
  80073f:	ff 55 08             	call   *0x8(%ebp)
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	eb 0d                	jmp    800754 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	ff 75 0c             	pushl  0xc(%ebp)
  80074d:	52                   	push   %edx
  80074e:	ff 55 08             	call   *0x8(%ebp)
  800751:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800754:	83 eb 01             	sub    $0x1,%ebx
  800757:	eb 1a                	jmp    800773 <vprintfmt+0x23f>
  800759:	89 75 08             	mov    %esi,0x8(%ebp)
  80075c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80075f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800762:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800765:	eb 0c                	jmp    800773 <vprintfmt+0x23f>
  800767:	89 75 08             	mov    %esi,0x8(%ebp)
  80076a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80076d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800770:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800773:	83 c7 01             	add    $0x1,%edi
  800776:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80077a:	0f be d0             	movsbl %al,%edx
  80077d:	85 d2                	test   %edx,%edx
  80077f:	74 23                	je     8007a4 <vprintfmt+0x270>
  800781:	85 f6                	test   %esi,%esi
  800783:	78 a1                	js     800726 <vprintfmt+0x1f2>
  800785:	83 ee 01             	sub    $0x1,%esi
  800788:	79 9c                	jns    800726 <vprintfmt+0x1f2>
  80078a:	89 df                	mov    %ebx,%edi
  80078c:	8b 75 08             	mov    0x8(%ebp),%esi
  80078f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800792:	eb 18                	jmp    8007ac <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800794:	83 ec 08             	sub    $0x8,%esp
  800797:	53                   	push   %ebx
  800798:	6a 20                	push   $0x20
  80079a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80079c:	83 ef 01             	sub    $0x1,%edi
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	eb 08                	jmp    8007ac <vprintfmt+0x278>
  8007a4:	89 df                	mov    %ebx,%edi
  8007a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ac:	85 ff                	test   %edi,%edi
  8007ae:	7f e4                	jg     800794 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b3:	e9 a2 fd ff ff       	jmp    80055a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007b8:	83 fa 01             	cmp    $0x1,%edx
  8007bb:	7e 16                	jle    8007d3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8d 50 08             	lea    0x8(%eax),%edx
  8007c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c6:	8b 50 04             	mov    0x4(%eax),%edx
  8007c9:	8b 00                	mov    (%eax),%eax
  8007cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d1:	eb 32                	jmp    800805 <vprintfmt+0x2d1>
	else if (lflag)
  8007d3:	85 d2                	test   %edx,%edx
  8007d5:	74 18                	je     8007ef <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	8d 50 04             	lea    0x4(%eax),%edx
  8007dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e0:	8b 00                	mov    (%eax),%eax
  8007e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e5:	89 c1                	mov    %eax,%ecx
  8007e7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007ed:	eb 16                	jmp    800805 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8d 50 04             	lea    0x4(%eax),%edx
  8007f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f8:	8b 00                	mov    (%eax),%eax
  8007fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007fd:	89 c1                	mov    %eax,%ecx
  8007ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800802:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800805:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800808:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80080b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800810:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800814:	79 74                	jns    80088a <vprintfmt+0x356>
				putch('-', putdat);
  800816:	83 ec 08             	sub    $0x8,%esp
  800819:	53                   	push   %ebx
  80081a:	6a 2d                	push   $0x2d
  80081c:	ff d6                	call   *%esi
				num = -(long long) num;
  80081e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800821:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800824:	f7 d8                	neg    %eax
  800826:	83 d2 00             	adc    $0x0,%edx
  800829:	f7 da                	neg    %edx
  80082b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80082e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800833:	eb 55                	jmp    80088a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800835:	8d 45 14             	lea    0x14(%ebp),%eax
  800838:	e8 83 fc ff ff       	call   8004c0 <getuint>
			base = 10;
  80083d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800842:	eb 46                	jmp    80088a <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800844:	8d 45 14             	lea    0x14(%ebp),%eax
  800847:	e8 74 fc ff ff       	call   8004c0 <getuint>
                        base = 8;
  80084c:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800851:	eb 37                	jmp    80088a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800853:	83 ec 08             	sub    $0x8,%esp
  800856:	53                   	push   %ebx
  800857:	6a 30                	push   $0x30
  800859:	ff d6                	call   *%esi
			putch('x', putdat);
  80085b:	83 c4 08             	add    $0x8,%esp
  80085e:	53                   	push   %ebx
  80085f:	6a 78                	push   $0x78
  800861:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800863:	8b 45 14             	mov    0x14(%ebp),%eax
  800866:	8d 50 04             	lea    0x4(%eax),%edx
  800869:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80086c:	8b 00                	mov    (%eax),%eax
  80086e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800873:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800876:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80087b:	eb 0d                	jmp    80088a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80087d:	8d 45 14             	lea    0x14(%ebp),%eax
  800880:	e8 3b fc ff ff       	call   8004c0 <getuint>
			base = 16;
  800885:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80088a:	83 ec 0c             	sub    $0xc,%esp
  80088d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800891:	57                   	push   %edi
  800892:	ff 75 e0             	pushl  -0x20(%ebp)
  800895:	51                   	push   %ecx
  800896:	52                   	push   %edx
  800897:	50                   	push   %eax
  800898:	89 da                	mov    %ebx,%edx
  80089a:	89 f0                	mov    %esi,%eax
  80089c:	e8 70 fb ff ff       	call   800411 <printnum>
			break;
  8008a1:	83 c4 20             	add    $0x20,%esp
  8008a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008a7:	e9 ae fc ff ff       	jmp    80055a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	51                   	push   %ecx
  8008b1:	ff d6                	call   *%esi
			break;
  8008b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008b9:	e9 9c fc ff ff       	jmp    80055a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	53                   	push   %ebx
  8008c2:	6a 25                	push   $0x25
  8008c4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008c6:	83 c4 10             	add    $0x10,%esp
  8008c9:	eb 03                	jmp    8008ce <vprintfmt+0x39a>
  8008cb:	83 ef 01             	sub    $0x1,%edi
  8008ce:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008d2:	75 f7                	jne    8008cb <vprintfmt+0x397>
  8008d4:	e9 81 fc ff ff       	jmp    80055a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008dc:	5b                   	pop    %ebx
  8008dd:	5e                   	pop    %esi
  8008de:	5f                   	pop    %edi
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	83 ec 18             	sub    $0x18,%esp
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008f0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008f4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008fe:	85 c0                	test   %eax,%eax
  800900:	74 26                	je     800928 <vsnprintf+0x47>
  800902:	85 d2                	test   %edx,%edx
  800904:	7e 22                	jle    800928 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800906:	ff 75 14             	pushl  0x14(%ebp)
  800909:	ff 75 10             	pushl  0x10(%ebp)
  80090c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80090f:	50                   	push   %eax
  800910:	68 fa 04 80 00       	push   $0x8004fa
  800915:	e8 1a fc ff ff       	call   800534 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80091a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80091d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800920:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800923:	83 c4 10             	add    $0x10,%esp
  800926:	eb 05                	jmp    80092d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800928:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800935:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800938:	50                   	push   %eax
  800939:	ff 75 10             	pushl  0x10(%ebp)
  80093c:	ff 75 0c             	pushl  0xc(%ebp)
  80093f:	ff 75 08             	pushl  0x8(%ebp)
  800942:	e8 9a ff ff ff       	call   8008e1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800947:	c9                   	leave  
  800948:	c3                   	ret    

00800949 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
  800954:	eb 03                	jmp    800959 <strlen+0x10>
		n++;
  800956:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800959:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80095d:	75 f7                	jne    800956 <strlen+0xd>
		n++;
	return n;
}
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800967:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80096a:	ba 00 00 00 00       	mov    $0x0,%edx
  80096f:	eb 03                	jmp    800974 <strnlen+0x13>
		n++;
  800971:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800974:	39 c2                	cmp    %eax,%edx
  800976:	74 08                	je     800980 <strnlen+0x1f>
  800978:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80097c:	75 f3                	jne    800971 <strnlen+0x10>
  80097e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	53                   	push   %ebx
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80098c:	89 c2                	mov    %eax,%edx
  80098e:	83 c2 01             	add    $0x1,%edx
  800991:	83 c1 01             	add    $0x1,%ecx
  800994:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800998:	88 5a ff             	mov    %bl,-0x1(%edx)
  80099b:	84 db                	test   %bl,%bl
  80099d:	75 ef                	jne    80098e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80099f:	5b                   	pop    %ebx
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	53                   	push   %ebx
  8009a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009a9:	53                   	push   %ebx
  8009aa:	e8 9a ff ff ff       	call   800949 <strlen>
  8009af:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009b2:	ff 75 0c             	pushl  0xc(%ebp)
  8009b5:	01 d8                	add    %ebx,%eax
  8009b7:	50                   	push   %eax
  8009b8:	e8 c5 ff ff ff       	call   800982 <strcpy>
	return dst;
}
  8009bd:	89 d8                	mov    %ebx,%eax
  8009bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c2:	c9                   	leave  
  8009c3:	c3                   	ret    

008009c4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	56                   	push   %esi
  8009c8:	53                   	push   %ebx
  8009c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009cf:	89 f3                	mov    %esi,%ebx
  8009d1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d4:	89 f2                	mov    %esi,%edx
  8009d6:	eb 0f                	jmp    8009e7 <strncpy+0x23>
		*dst++ = *src;
  8009d8:	83 c2 01             	add    $0x1,%edx
  8009db:	0f b6 01             	movzbl (%ecx),%eax
  8009de:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009e1:	80 39 01             	cmpb   $0x1,(%ecx)
  8009e4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e7:	39 da                	cmp    %ebx,%edx
  8009e9:	75 ed                	jne    8009d8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009eb:	89 f0                	mov    %esi,%eax
  8009ed:	5b                   	pop    %ebx
  8009ee:	5e                   	pop    %esi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	56                   	push   %esi
  8009f5:	53                   	push   %ebx
  8009f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009fc:	8b 55 10             	mov    0x10(%ebp),%edx
  8009ff:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a01:	85 d2                	test   %edx,%edx
  800a03:	74 21                	je     800a26 <strlcpy+0x35>
  800a05:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a09:	89 f2                	mov    %esi,%edx
  800a0b:	eb 09                	jmp    800a16 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a0d:	83 c2 01             	add    $0x1,%edx
  800a10:	83 c1 01             	add    $0x1,%ecx
  800a13:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a16:	39 c2                	cmp    %eax,%edx
  800a18:	74 09                	je     800a23 <strlcpy+0x32>
  800a1a:	0f b6 19             	movzbl (%ecx),%ebx
  800a1d:	84 db                	test   %bl,%bl
  800a1f:	75 ec                	jne    800a0d <strlcpy+0x1c>
  800a21:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a23:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a26:	29 f0                	sub    %esi,%eax
}
  800a28:	5b                   	pop    %ebx
  800a29:	5e                   	pop    %esi
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a32:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a35:	eb 06                	jmp    800a3d <strcmp+0x11>
		p++, q++;
  800a37:	83 c1 01             	add    $0x1,%ecx
  800a3a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a3d:	0f b6 01             	movzbl (%ecx),%eax
  800a40:	84 c0                	test   %al,%al
  800a42:	74 04                	je     800a48 <strcmp+0x1c>
  800a44:	3a 02                	cmp    (%edx),%al
  800a46:	74 ef                	je     800a37 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a48:	0f b6 c0             	movzbl %al,%eax
  800a4b:	0f b6 12             	movzbl (%edx),%edx
  800a4e:	29 d0                	sub    %edx,%eax
}
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	53                   	push   %ebx
  800a56:	8b 45 08             	mov    0x8(%ebp),%eax
  800a59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5c:	89 c3                	mov    %eax,%ebx
  800a5e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a61:	eb 06                	jmp    800a69 <strncmp+0x17>
		n--, p++, q++;
  800a63:	83 c0 01             	add    $0x1,%eax
  800a66:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a69:	39 d8                	cmp    %ebx,%eax
  800a6b:	74 15                	je     800a82 <strncmp+0x30>
  800a6d:	0f b6 08             	movzbl (%eax),%ecx
  800a70:	84 c9                	test   %cl,%cl
  800a72:	74 04                	je     800a78 <strncmp+0x26>
  800a74:	3a 0a                	cmp    (%edx),%cl
  800a76:	74 eb                	je     800a63 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a78:	0f b6 00             	movzbl (%eax),%eax
  800a7b:	0f b6 12             	movzbl (%edx),%edx
  800a7e:	29 d0                	sub    %edx,%eax
  800a80:	eb 05                	jmp    800a87 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a82:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a87:	5b                   	pop    %ebx
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a94:	eb 07                	jmp    800a9d <strchr+0x13>
		if (*s == c)
  800a96:	38 ca                	cmp    %cl,%dl
  800a98:	74 0f                	je     800aa9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	0f b6 10             	movzbl (%eax),%edx
  800aa0:	84 d2                	test   %dl,%dl
  800aa2:	75 f2                	jne    800a96 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800aa4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab5:	eb 03                	jmp    800aba <strfind+0xf>
  800ab7:	83 c0 01             	add    $0x1,%eax
  800aba:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800abd:	38 ca                	cmp    %cl,%dl
  800abf:	74 04                	je     800ac5 <strfind+0x1a>
  800ac1:	84 d2                	test   %dl,%dl
  800ac3:	75 f2                	jne    800ab7 <strfind+0xc>
			break;
	return (char *) s;
}
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
  800acd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ad0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ad3:	85 c9                	test   %ecx,%ecx
  800ad5:	74 36                	je     800b0d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ad7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800add:	75 28                	jne    800b07 <memset+0x40>
  800adf:	f6 c1 03             	test   $0x3,%cl
  800ae2:	75 23                	jne    800b07 <memset+0x40>
		c &= 0xFF;
  800ae4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ae8:	89 d3                	mov    %edx,%ebx
  800aea:	c1 e3 08             	shl    $0x8,%ebx
  800aed:	89 d6                	mov    %edx,%esi
  800aef:	c1 e6 18             	shl    $0x18,%esi
  800af2:	89 d0                	mov    %edx,%eax
  800af4:	c1 e0 10             	shl    $0x10,%eax
  800af7:	09 f0                	or     %esi,%eax
  800af9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800afb:	89 d8                	mov    %ebx,%eax
  800afd:	09 d0                	or     %edx,%eax
  800aff:	c1 e9 02             	shr    $0x2,%ecx
  800b02:	fc                   	cld    
  800b03:	f3 ab                	rep stos %eax,%es:(%edi)
  800b05:	eb 06                	jmp    800b0d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0a:	fc                   	cld    
  800b0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b0d:	89 f8                	mov    %edi,%eax
  800b0f:	5b                   	pop    %ebx
  800b10:	5e                   	pop    %esi
  800b11:	5f                   	pop    %edi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b22:	39 c6                	cmp    %eax,%esi
  800b24:	73 35                	jae    800b5b <memmove+0x47>
  800b26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b29:	39 d0                	cmp    %edx,%eax
  800b2b:	73 2e                	jae    800b5b <memmove+0x47>
		s += n;
		d += n;
  800b2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b30:	89 d6                	mov    %edx,%esi
  800b32:	09 fe                	or     %edi,%esi
  800b34:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b3a:	75 13                	jne    800b4f <memmove+0x3b>
  800b3c:	f6 c1 03             	test   $0x3,%cl
  800b3f:	75 0e                	jne    800b4f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b41:	83 ef 04             	sub    $0x4,%edi
  800b44:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b47:	c1 e9 02             	shr    $0x2,%ecx
  800b4a:	fd                   	std    
  800b4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4d:	eb 09                	jmp    800b58 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b4f:	83 ef 01             	sub    $0x1,%edi
  800b52:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b55:	fd                   	std    
  800b56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b58:	fc                   	cld    
  800b59:	eb 1d                	jmp    800b78 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5b:	89 f2                	mov    %esi,%edx
  800b5d:	09 c2                	or     %eax,%edx
  800b5f:	f6 c2 03             	test   $0x3,%dl
  800b62:	75 0f                	jne    800b73 <memmove+0x5f>
  800b64:	f6 c1 03             	test   $0x3,%cl
  800b67:	75 0a                	jne    800b73 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b69:	c1 e9 02             	shr    $0x2,%ecx
  800b6c:	89 c7                	mov    %eax,%edi
  800b6e:	fc                   	cld    
  800b6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b71:	eb 05                	jmp    800b78 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b73:	89 c7                	mov    %eax,%edi
  800b75:	fc                   	cld    
  800b76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b7f:	ff 75 10             	pushl  0x10(%ebp)
  800b82:	ff 75 0c             	pushl  0xc(%ebp)
  800b85:	ff 75 08             	pushl  0x8(%ebp)
  800b88:	e8 87 ff ff ff       	call   800b14 <memmove>
}
  800b8d:	c9                   	leave  
  800b8e:	c3                   	ret    

00800b8f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
  800b94:	8b 45 08             	mov    0x8(%ebp),%eax
  800b97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b9a:	89 c6                	mov    %eax,%esi
  800b9c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b9f:	eb 1a                	jmp    800bbb <memcmp+0x2c>
		if (*s1 != *s2)
  800ba1:	0f b6 08             	movzbl (%eax),%ecx
  800ba4:	0f b6 1a             	movzbl (%edx),%ebx
  800ba7:	38 d9                	cmp    %bl,%cl
  800ba9:	74 0a                	je     800bb5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bab:	0f b6 c1             	movzbl %cl,%eax
  800bae:	0f b6 db             	movzbl %bl,%ebx
  800bb1:	29 d8                	sub    %ebx,%eax
  800bb3:	eb 0f                	jmp    800bc4 <memcmp+0x35>
		s1++, s2++;
  800bb5:	83 c0 01             	add    $0x1,%eax
  800bb8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbb:	39 f0                	cmp    %esi,%eax
  800bbd:	75 e2                	jne    800ba1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	53                   	push   %ebx
  800bcc:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bcf:	89 c1                	mov    %eax,%ecx
  800bd1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd8:	eb 0a                	jmp    800be4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bda:	0f b6 10             	movzbl (%eax),%edx
  800bdd:	39 da                	cmp    %ebx,%edx
  800bdf:	74 07                	je     800be8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be1:	83 c0 01             	add    $0x1,%eax
  800be4:	39 c8                	cmp    %ecx,%eax
  800be6:	72 f2                	jb     800bda <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be8:	5b                   	pop    %ebx
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf7:	eb 03                	jmp    800bfc <strtol+0x11>
		s++;
  800bf9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bfc:	0f b6 01             	movzbl (%ecx),%eax
  800bff:	3c 20                	cmp    $0x20,%al
  800c01:	74 f6                	je     800bf9 <strtol+0xe>
  800c03:	3c 09                	cmp    $0x9,%al
  800c05:	74 f2                	je     800bf9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c07:	3c 2b                	cmp    $0x2b,%al
  800c09:	75 0a                	jne    800c15 <strtol+0x2a>
		s++;
  800c0b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c0e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c13:	eb 11                	jmp    800c26 <strtol+0x3b>
  800c15:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c1a:	3c 2d                	cmp    $0x2d,%al
  800c1c:	75 08                	jne    800c26 <strtol+0x3b>
		s++, neg = 1;
  800c1e:	83 c1 01             	add    $0x1,%ecx
  800c21:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c26:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c2c:	75 15                	jne    800c43 <strtol+0x58>
  800c2e:	80 39 30             	cmpb   $0x30,(%ecx)
  800c31:	75 10                	jne    800c43 <strtol+0x58>
  800c33:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c37:	75 7c                	jne    800cb5 <strtol+0xca>
		s += 2, base = 16;
  800c39:	83 c1 02             	add    $0x2,%ecx
  800c3c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c41:	eb 16                	jmp    800c59 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c43:	85 db                	test   %ebx,%ebx
  800c45:	75 12                	jne    800c59 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c47:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c4c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c4f:	75 08                	jne    800c59 <strtol+0x6e>
		s++, base = 8;
  800c51:	83 c1 01             	add    $0x1,%ecx
  800c54:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c59:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c61:	0f b6 11             	movzbl (%ecx),%edx
  800c64:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c67:	89 f3                	mov    %esi,%ebx
  800c69:	80 fb 09             	cmp    $0x9,%bl
  800c6c:	77 08                	ja     800c76 <strtol+0x8b>
			dig = *s - '0';
  800c6e:	0f be d2             	movsbl %dl,%edx
  800c71:	83 ea 30             	sub    $0x30,%edx
  800c74:	eb 22                	jmp    800c98 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c76:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c79:	89 f3                	mov    %esi,%ebx
  800c7b:	80 fb 19             	cmp    $0x19,%bl
  800c7e:	77 08                	ja     800c88 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c80:	0f be d2             	movsbl %dl,%edx
  800c83:	83 ea 57             	sub    $0x57,%edx
  800c86:	eb 10                	jmp    800c98 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c88:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c8b:	89 f3                	mov    %esi,%ebx
  800c8d:	80 fb 19             	cmp    $0x19,%bl
  800c90:	77 16                	ja     800ca8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c92:	0f be d2             	movsbl %dl,%edx
  800c95:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c98:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c9b:	7d 0b                	jge    800ca8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c9d:	83 c1 01             	add    $0x1,%ecx
  800ca0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ca4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ca6:	eb b9                	jmp    800c61 <strtol+0x76>

	if (endptr)
  800ca8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cac:	74 0d                	je     800cbb <strtol+0xd0>
		*endptr = (char *) s;
  800cae:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cb1:	89 0e                	mov    %ecx,(%esi)
  800cb3:	eb 06                	jmp    800cbb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cb5:	85 db                	test   %ebx,%ebx
  800cb7:	74 98                	je     800c51 <strtol+0x66>
  800cb9:	eb 9e                	jmp    800c59 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cbb:	89 c2                	mov    %eax,%edx
  800cbd:	f7 da                	neg    %edx
  800cbf:	85 ff                	test   %edi,%edi
  800cc1:	0f 45 c2             	cmovne %edx,%eax
}
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800ccf:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	89 c3                	mov    %eax,%ebx
  800cdc:	89 c7                	mov    %eax,%edi
  800cde:	89 c6                	mov    %eax,%esi
  800ce0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ced:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf2:	b8 01 00 00 00       	mov    $0x1,%eax
  800cf7:	89 d1                	mov    %edx,%ecx
  800cf9:	89 d3                	mov    %edx,%ebx
  800cfb:	89 d7                	mov    %edx,%edi
  800cfd:	89 d6                	mov    %edx,%esi
  800cff:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d14:	b8 03 00 00 00       	mov    $0x3,%eax
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	89 cb                	mov    %ecx,%ebx
  800d1e:	89 cf                	mov    %ecx,%edi
  800d20:	89 ce                	mov    %ecx,%esi
  800d22:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d24:	85 c0                	test   %eax,%eax
  800d26:	7e 17                	jle    800d3f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d28:	83 ec 0c             	sub    $0xc,%esp
  800d2b:	50                   	push   %eax
  800d2c:	6a 03                	push   $0x3
  800d2e:	68 bf 2b 80 00       	push   $0x802bbf
  800d33:	6a 23                	push   $0x23
  800d35:	68 dc 2b 80 00       	push   $0x802bdc
  800d3a:	e8 e5 f5 ff ff       	call   800324 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	57                   	push   %edi
  800d4b:	56                   	push   %esi
  800d4c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d52:	b8 02 00 00 00       	mov    $0x2,%eax
  800d57:	89 d1                	mov    %edx,%ecx
  800d59:	89 d3                	mov    %edx,%ebx
  800d5b:	89 d7                	mov    %edx,%edi
  800d5d:	89 d6                	mov    %edx,%esi
  800d5f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <sys_yield>:

void
sys_yield(void)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d71:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d76:	89 d1                	mov    %edx,%ecx
  800d78:	89 d3                	mov    %edx,%ebx
  800d7a:	89 d7                	mov    %edx,%edi
  800d7c:	89 d6                	mov    %edx,%esi
  800d7e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	57                   	push   %edi
  800d89:	56                   	push   %esi
  800d8a:	53                   	push   %ebx
  800d8b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8e:	be 00 00 00 00       	mov    $0x0,%esi
  800d93:	b8 04 00 00 00       	mov    $0x4,%eax
  800d98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da1:	89 f7                	mov    %esi,%edi
  800da3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da5:	85 c0                	test   %eax,%eax
  800da7:	7e 17                	jle    800dc0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da9:	83 ec 0c             	sub    $0xc,%esp
  800dac:	50                   	push   %eax
  800dad:	6a 04                	push   $0x4
  800daf:	68 bf 2b 80 00       	push   $0x802bbf
  800db4:	6a 23                	push   $0x23
  800db6:	68 dc 2b 80 00       	push   $0x802bdc
  800dbb:	e8 64 f5 ff ff       	call   800324 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd1:	b8 05 00 00 00       	mov    $0x5,%eax
  800dd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ddf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de2:	8b 75 18             	mov    0x18(%ebp),%esi
  800de5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de7:	85 c0                	test   %eax,%eax
  800de9:	7e 17                	jle    800e02 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800deb:	83 ec 0c             	sub    $0xc,%esp
  800dee:	50                   	push   %eax
  800def:	6a 05                	push   $0x5
  800df1:	68 bf 2b 80 00       	push   $0x802bbf
  800df6:	6a 23                	push   $0x23
  800df8:	68 dc 2b 80 00       	push   $0x802bdc
  800dfd:	e8 22 f5 ff ff       	call   800324 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e18:	b8 06 00 00 00       	mov    $0x6,%eax
  800e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e20:	8b 55 08             	mov    0x8(%ebp),%edx
  800e23:	89 df                	mov    %ebx,%edi
  800e25:	89 de                	mov    %ebx,%esi
  800e27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7e 17                	jle    800e44 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2d:	83 ec 0c             	sub    $0xc,%esp
  800e30:	50                   	push   %eax
  800e31:	6a 06                	push   $0x6
  800e33:	68 bf 2b 80 00       	push   $0x802bbf
  800e38:	6a 23                	push   $0x23
  800e3a:	68 dc 2b 80 00       	push   $0x802bdc
  800e3f:	e8 e0 f4 ff ff       	call   800324 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5f                   	pop    %edi
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	57                   	push   %edi
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
  800e52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5a:	b8 08 00 00 00       	mov    $0x8,%eax
  800e5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e62:	8b 55 08             	mov    0x8(%ebp),%edx
  800e65:	89 df                	mov    %ebx,%edi
  800e67:	89 de                	mov    %ebx,%esi
  800e69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	7e 17                	jle    800e86 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6f:	83 ec 0c             	sub    $0xc,%esp
  800e72:	50                   	push   %eax
  800e73:	6a 08                	push   $0x8
  800e75:	68 bf 2b 80 00       	push   $0x802bbf
  800e7a:	6a 23                	push   $0x23
  800e7c:	68 dc 2b 80 00       	push   $0x802bdc
  800e81:	e8 9e f4 ff ff       	call   800324 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e89:	5b                   	pop    %ebx
  800e8a:	5e                   	pop    %esi
  800e8b:	5f                   	pop    %edi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9c:	b8 09 00 00 00       	mov    $0x9,%eax
  800ea1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea7:	89 df                	mov    %ebx,%edi
  800ea9:	89 de                	mov    %ebx,%esi
  800eab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	7e 17                	jle    800ec8 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb1:	83 ec 0c             	sub    $0xc,%esp
  800eb4:	50                   	push   %eax
  800eb5:	6a 09                	push   $0x9
  800eb7:	68 bf 2b 80 00       	push   $0x802bbf
  800ebc:	6a 23                	push   $0x23
  800ebe:	68 dc 2b 80 00       	push   $0x802bdc
  800ec3:	e8 5c f4 ff ff       	call   800324 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ec8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ecb:	5b                   	pop    %ebx
  800ecc:	5e                   	pop    %esi
  800ecd:	5f                   	pop    %edi
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	53                   	push   %ebx
  800ed6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ede:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ee3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee9:	89 df                	mov    %ebx,%edi
  800eeb:	89 de                	mov    %ebx,%esi
  800eed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	7e 17                	jle    800f0a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef3:	83 ec 0c             	sub    $0xc,%esp
  800ef6:	50                   	push   %eax
  800ef7:	6a 0a                	push   $0xa
  800ef9:	68 bf 2b 80 00       	push   $0x802bbf
  800efe:	6a 23                	push   $0x23
  800f00:	68 dc 2b 80 00       	push   $0x802bdc
  800f05:	e8 1a f4 ff ff       	call   800324 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f0d:	5b                   	pop    %ebx
  800f0e:	5e                   	pop    %esi
  800f0f:	5f                   	pop    %edi
  800f10:	5d                   	pop    %ebp
  800f11:	c3                   	ret    

00800f12 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	57                   	push   %edi
  800f16:	56                   	push   %esi
  800f17:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f18:	be 00 00 00 00       	mov    $0x0,%esi
  800f1d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f25:	8b 55 08             	mov    0x8(%ebp),%edx
  800f28:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f2e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    

00800f35 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	57                   	push   %edi
  800f39:	56                   	push   %esi
  800f3a:	53                   	push   %ebx
  800f3b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f43:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f48:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4b:	89 cb                	mov    %ecx,%ebx
  800f4d:	89 cf                	mov    %ecx,%edi
  800f4f:	89 ce                	mov    %ecx,%esi
  800f51:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f53:	85 c0                	test   %eax,%eax
  800f55:	7e 17                	jle    800f6e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f57:	83 ec 0c             	sub    $0xc,%esp
  800f5a:	50                   	push   %eax
  800f5b:	6a 0d                	push   $0xd
  800f5d:	68 bf 2b 80 00       	push   $0x802bbf
  800f62:	6a 23                	push   $0x23
  800f64:	68 dc 2b 80 00       	push   $0x802bdc
  800f69:	e8 b6 f3 ff ff       	call   800324 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f71:	5b                   	pop    %ebx
  800f72:	5e                   	pop    %esi
  800f73:	5f                   	pop    %edi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    

00800f76 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	57                   	push   %edi
  800f7a:	56                   	push   %esi
  800f7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f81:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f86:	89 d1                	mov    %edx,%ecx
  800f88:	89 d3                	mov    %edx,%ebx
  800f8a:	89 d7                	mov    %edx,%edi
  800f8c:	89 d6                	mov    %edx,%esi
  800f8e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f90:	5b                   	pop    %ebx
  800f91:	5e                   	pop    %esi
  800f92:	5f                   	pop    %edi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    

00800f95 <sys_transmit_packet>:

int
sys_transmit_packet(void *buf, size_t size)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	57                   	push   %edi
  800f99:	56                   	push   %esi
  800f9a:	53                   	push   %ebx
  800f9b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fa3:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fa8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fab:	8b 55 08             	mov    0x8(%ebp),%edx
  800fae:	89 df                	mov    %ebx,%edi
  800fb0:	89 de                	mov    %ebx,%esi
  800fb2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	7e 17                	jle    800fcf <sys_transmit_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb8:	83 ec 0c             	sub    $0xc,%esp
  800fbb:	50                   	push   %eax
  800fbc:	6a 0f                	push   $0xf
  800fbe:	68 bf 2b 80 00       	push   $0x802bbf
  800fc3:	6a 23                	push   $0x23
  800fc5:	68 dc 2b 80 00       	push   $0x802bdc
  800fca:	e8 55 f3 ff ff       	call   800324 <_panic>
int
sys_transmit_packet(void *buf, size_t size)
{
	return syscall(SYS_transmit_packet, 1,
		(uint32_t) buf, (uint32_t) size, 0, 0, 0);
}
  800fcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd2:	5b                   	pop    %ebx
  800fd3:	5e                   	pop    %esi
  800fd4:	5f                   	pop    %edi
  800fd5:	5d                   	pop    %ebp
  800fd6:	c3                   	ret    

00800fd7 <sys_receive_packet>:

int
sys_receive_packet(void *buf, size_t *size_store)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	57                   	push   %edi
  800fdb:	56                   	push   %esi
  800fdc:	53                   	push   %ebx
  800fdd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe5:	b8 10 00 00 00       	mov    $0x10,%eax
  800fea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fed:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff0:	89 df                	mov    %ebx,%edi
  800ff2:	89 de                	mov    %ebx,%esi
  800ff4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	7e 17                	jle    801011 <sys_receive_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ffa:	83 ec 0c             	sub    $0xc,%esp
  800ffd:	50                   	push   %eax
  800ffe:	6a 10                	push   $0x10
  801000:	68 bf 2b 80 00       	push   $0x802bbf
  801005:	6a 23                	push   $0x23
  801007:	68 dc 2b 80 00       	push   $0x802bdc
  80100c:	e8 13 f3 ff ff       	call   800324 <_panic>
int
sys_receive_packet(void *buf, size_t *size_store)
{
	return syscall(SYS_receive_packet, 1,
		(uint32_t) buf, (uint32_t) size_store, 0, 0, 0);
}
  801011:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801014:	5b                   	pop    %ebx
  801015:	5e                   	pop    %esi
  801016:	5f                   	pop    %edi
  801017:	5d                   	pop    %ebp
  801018:	c3                   	ret    

00801019 <sys_get_mac_address>:

int
sys_get_mac_address(void *buf)
{
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	57                   	push   %edi
  80101d:	56                   	push   %esi
  80101e:	53                   	push   %ebx
  80101f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801022:	b9 00 00 00 00       	mov    $0x0,%ecx
  801027:	b8 11 00 00 00       	mov    $0x11,%eax
  80102c:	8b 55 08             	mov    0x8(%ebp),%edx
  80102f:	89 cb                	mov    %ecx,%ebx
  801031:	89 cf                	mov    %ecx,%edi
  801033:	89 ce                	mov    %ecx,%esi
  801035:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801037:	85 c0                	test   %eax,%eax
  801039:	7e 17                	jle    801052 <sys_get_mac_address+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80103b:	83 ec 0c             	sub    $0xc,%esp
  80103e:	50                   	push   %eax
  80103f:	6a 11                	push   $0x11
  801041:	68 bf 2b 80 00       	push   $0x802bbf
  801046:	6a 23                	push   $0x23
  801048:	68 dc 2b 80 00       	push   $0x802bdc
  80104d:	e8 d2 f2 ff ff       	call   800324 <_panic>
int
sys_get_mac_address(void *buf)
{
	return syscall(SYS_get_mac_address, 1,
		(uint32_t) buf, 0, 0, 0, 0);
}
  801052:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801055:	5b                   	pop    %ebx
  801056:	5e                   	pop    %esi
  801057:	5f                   	pop    %edi
  801058:	5d                   	pop    %ebp
  801059:	c3                   	ret    

0080105a <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	8b 55 08             	mov    0x8(%ebp),%edx
  801060:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801063:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801066:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801068:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  80106b:	83 3a 01             	cmpl   $0x1,(%edx)
  80106e:	7e 09                	jle    801079 <argstart+0x1f>
  801070:	ba 68 28 80 00       	mov    $0x802868,%edx
  801075:	85 c9                	test   %ecx,%ecx
  801077:	75 05                	jne    80107e <argstart+0x24>
  801079:	ba 00 00 00 00       	mov    $0x0,%edx
  80107e:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801081:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801088:	5d                   	pop    %ebp
  801089:	c3                   	ret    

0080108a <argnext>:

int
argnext(struct Argstate *args)
{
  80108a:	55                   	push   %ebp
  80108b:	89 e5                	mov    %esp,%ebp
  80108d:	53                   	push   %ebx
  80108e:	83 ec 04             	sub    $0x4,%esp
  801091:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801094:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  80109b:	8b 43 08             	mov    0x8(%ebx),%eax
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	74 6f                	je     801111 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  8010a2:	80 38 00             	cmpb   $0x0,(%eax)
  8010a5:	75 4e                	jne    8010f5 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  8010a7:	8b 0b                	mov    (%ebx),%ecx
  8010a9:	83 39 01             	cmpl   $0x1,(%ecx)
  8010ac:	74 55                	je     801103 <argnext+0x79>
		    || args->argv[1][0] != '-'
  8010ae:	8b 53 04             	mov    0x4(%ebx),%edx
  8010b1:	8b 42 04             	mov    0x4(%edx),%eax
  8010b4:	80 38 2d             	cmpb   $0x2d,(%eax)
  8010b7:	75 4a                	jne    801103 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  8010b9:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  8010bd:	74 44                	je     801103 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  8010bf:	83 c0 01             	add    $0x1,%eax
  8010c2:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8010c5:	83 ec 04             	sub    $0x4,%esp
  8010c8:	8b 01                	mov    (%ecx),%eax
  8010ca:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  8010d1:	50                   	push   %eax
  8010d2:	8d 42 08             	lea    0x8(%edx),%eax
  8010d5:	50                   	push   %eax
  8010d6:	83 c2 04             	add    $0x4,%edx
  8010d9:	52                   	push   %edx
  8010da:	e8 35 fa ff ff       	call   800b14 <memmove>
		(*args->argc)--;
  8010df:	8b 03                	mov    (%ebx),%eax
  8010e1:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  8010e4:	8b 43 08             	mov    0x8(%ebx),%eax
  8010e7:	83 c4 10             	add    $0x10,%esp
  8010ea:	80 38 2d             	cmpb   $0x2d,(%eax)
  8010ed:	75 06                	jne    8010f5 <argnext+0x6b>
  8010ef:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  8010f3:	74 0e                	je     801103 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  8010f5:	8b 53 08             	mov    0x8(%ebx),%edx
  8010f8:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  8010fb:	83 c2 01             	add    $0x1,%edx
  8010fe:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801101:	eb 13                	jmp    801116 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801103:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  80110a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80110f:	eb 05                	jmp    801116 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801111:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801116:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801119:	c9                   	leave  
  80111a:	c3                   	ret    

0080111b <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	53                   	push   %ebx
  80111f:	83 ec 04             	sub    $0x4,%esp
  801122:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801125:	8b 43 08             	mov    0x8(%ebx),%eax
  801128:	85 c0                	test   %eax,%eax
  80112a:	74 58                	je     801184 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  80112c:	80 38 00             	cmpb   $0x0,(%eax)
  80112f:	74 0c                	je     80113d <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801131:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801134:	c7 43 08 68 28 80 00 	movl   $0x802868,0x8(%ebx)
  80113b:	eb 42                	jmp    80117f <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  80113d:	8b 13                	mov    (%ebx),%edx
  80113f:	83 3a 01             	cmpl   $0x1,(%edx)
  801142:	7e 2d                	jle    801171 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801144:	8b 43 04             	mov    0x4(%ebx),%eax
  801147:	8b 48 04             	mov    0x4(%eax),%ecx
  80114a:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80114d:	83 ec 04             	sub    $0x4,%esp
  801150:	8b 12                	mov    (%edx),%edx
  801152:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801159:	52                   	push   %edx
  80115a:	8d 50 08             	lea    0x8(%eax),%edx
  80115d:	52                   	push   %edx
  80115e:	83 c0 04             	add    $0x4,%eax
  801161:	50                   	push   %eax
  801162:	e8 ad f9 ff ff       	call   800b14 <memmove>
		(*args->argc)--;
  801167:	8b 03                	mov    (%ebx),%eax
  801169:	83 28 01             	subl   $0x1,(%eax)
  80116c:	83 c4 10             	add    $0x10,%esp
  80116f:	eb 0e                	jmp    80117f <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801171:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801178:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  80117f:	8b 43 0c             	mov    0xc(%ebx),%eax
  801182:	eb 05                	jmp    801189 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801184:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801189:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80118c:	c9                   	leave  
  80118d:	c3                   	ret    

0080118e <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  80118e:	55                   	push   %ebp
  80118f:	89 e5                	mov    %esp,%ebp
  801191:	83 ec 08             	sub    $0x8,%esp
  801194:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801197:	8b 51 0c             	mov    0xc(%ecx),%edx
  80119a:	89 d0                	mov    %edx,%eax
  80119c:	85 d2                	test   %edx,%edx
  80119e:	75 0c                	jne    8011ac <argvalue+0x1e>
  8011a0:	83 ec 0c             	sub    $0xc,%esp
  8011a3:	51                   	push   %ecx
  8011a4:	e8 72 ff ff ff       	call   80111b <argnextvalue>
  8011a9:	83 c4 10             	add    $0x10,%esp
}
  8011ac:	c9                   	leave  
  8011ad:	c3                   	ret    

008011ae <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b4:	05 00 00 00 30       	add    $0x30000000,%eax
  8011b9:	c1 e8 0c             	shr    $0xc,%eax
}
  8011bc:	5d                   	pop    %ebp
  8011bd:	c3                   	ret    

008011be <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c4:	05 00 00 00 30       	add    $0x30000000,%eax
  8011c9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011ce:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011d3:	5d                   	pop    %ebp
  8011d4:	c3                   	ret    

008011d5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011db:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011e0:	89 c2                	mov    %eax,%edx
  8011e2:	c1 ea 16             	shr    $0x16,%edx
  8011e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ec:	f6 c2 01             	test   $0x1,%dl
  8011ef:	74 11                	je     801202 <fd_alloc+0x2d>
  8011f1:	89 c2                	mov    %eax,%edx
  8011f3:	c1 ea 0c             	shr    $0xc,%edx
  8011f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011fd:	f6 c2 01             	test   $0x1,%dl
  801200:	75 09                	jne    80120b <fd_alloc+0x36>
			*fd_store = fd;
  801202:	89 01                	mov    %eax,(%ecx)
			return 0;
  801204:	b8 00 00 00 00       	mov    $0x0,%eax
  801209:	eb 17                	jmp    801222 <fd_alloc+0x4d>
  80120b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801210:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801215:	75 c9                	jne    8011e0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801217:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80121d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801222:	5d                   	pop    %ebp
  801223:	c3                   	ret    

00801224 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80122a:	83 f8 1f             	cmp    $0x1f,%eax
  80122d:	77 36                	ja     801265 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80122f:	c1 e0 0c             	shl    $0xc,%eax
  801232:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801237:	89 c2                	mov    %eax,%edx
  801239:	c1 ea 16             	shr    $0x16,%edx
  80123c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801243:	f6 c2 01             	test   $0x1,%dl
  801246:	74 24                	je     80126c <fd_lookup+0x48>
  801248:	89 c2                	mov    %eax,%edx
  80124a:	c1 ea 0c             	shr    $0xc,%edx
  80124d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801254:	f6 c2 01             	test   $0x1,%dl
  801257:	74 1a                	je     801273 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801259:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125c:	89 02                	mov    %eax,(%edx)
	return 0;
  80125e:	b8 00 00 00 00       	mov    $0x0,%eax
  801263:	eb 13                	jmp    801278 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801265:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126a:	eb 0c                	jmp    801278 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80126c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801271:	eb 05                	jmp    801278 <fd_lookup+0x54>
  801273:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801278:	5d                   	pop    %ebp
  801279:	c3                   	ret    

0080127a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	83 ec 08             	sub    $0x8,%esp
  801280:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801283:	ba 6c 2c 80 00       	mov    $0x802c6c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801288:	eb 13                	jmp    80129d <dev_lookup+0x23>
  80128a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80128d:	39 08                	cmp    %ecx,(%eax)
  80128f:	75 0c                	jne    80129d <dev_lookup+0x23>
			*dev = devtab[i];
  801291:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801294:	89 01                	mov    %eax,(%ecx)
			return 0;
  801296:	b8 00 00 00 00       	mov    $0x0,%eax
  80129b:	eb 2e                	jmp    8012cb <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80129d:	8b 02                	mov    (%edx),%eax
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	75 e7                	jne    80128a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012a3:	a1 20 44 80 00       	mov    0x804420,%eax
  8012a8:	8b 40 48             	mov    0x48(%eax),%eax
  8012ab:	83 ec 04             	sub    $0x4,%esp
  8012ae:	51                   	push   %ecx
  8012af:	50                   	push   %eax
  8012b0:	68 ec 2b 80 00       	push   $0x802bec
  8012b5:	e8 43 f1 ff ff       	call   8003fd <cprintf>
	*dev = 0;
  8012ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012c3:	83 c4 10             	add    $0x10,%esp
  8012c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012cb:	c9                   	leave  
  8012cc:	c3                   	ret    

008012cd <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	56                   	push   %esi
  8012d1:	53                   	push   %ebx
  8012d2:	83 ec 10             	sub    $0x10,%esp
  8012d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8012d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012de:	50                   	push   %eax
  8012df:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012e5:	c1 e8 0c             	shr    $0xc,%eax
  8012e8:	50                   	push   %eax
  8012e9:	e8 36 ff ff ff       	call   801224 <fd_lookup>
  8012ee:	83 c4 08             	add    $0x8,%esp
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	78 05                	js     8012fa <fd_close+0x2d>
	    || fd != fd2)
  8012f5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012f8:	74 0c                	je     801306 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012fa:	84 db                	test   %bl,%bl
  8012fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801301:	0f 44 c2             	cmove  %edx,%eax
  801304:	eb 41                	jmp    801347 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801306:	83 ec 08             	sub    $0x8,%esp
  801309:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130c:	50                   	push   %eax
  80130d:	ff 36                	pushl  (%esi)
  80130f:	e8 66 ff ff ff       	call   80127a <dev_lookup>
  801314:	89 c3                	mov    %eax,%ebx
  801316:	83 c4 10             	add    $0x10,%esp
  801319:	85 c0                	test   %eax,%eax
  80131b:	78 1a                	js     801337 <fd_close+0x6a>
		if (dev->dev_close)
  80131d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801320:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801323:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801328:	85 c0                	test   %eax,%eax
  80132a:	74 0b                	je     801337 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80132c:	83 ec 0c             	sub    $0xc,%esp
  80132f:	56                   	push   %esi
  801330:	ff d0                	call   *%eax
  801332:	89 c3                	mov    %eax,%ebx
  801334:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801337:	83 ec 08             	sub    $0x8,%esp
  80133a:	56                   	push   %esi
  80133b:	6a 00                	push   $0x0
  80133d:	e8 c8 fa ff ff       	call   800e0a <sys_page_unmap>
	return r;
  801342:	83 c4 10             	add    $0x10,%esp
  801345:	89 d8                	mov    %ebx,%eax
}
  801347:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80134a:	5b                   	pop    %ebx
  80134b:	5e                   	pop    %esi
  80134c:	5d                   	pop    %ebp
  80134d:	c3                   	ret    

0080134e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801354:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801357:	50                   	push   %eax
  801358:	ff 75 08             	pushl  0x8(%ebp)
  80135b:	e8 c4 fe ff ff       	call   801224 <fd_lookup>
  801360:	83 c4 08             	add    $0x8,%esp
  801363:	85 c0                	test   %eax,%eax
  801365:	78 10                	js     801377 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801367:	83 ec 08             	sub    $0x8,%esp
  80136a:	6a 01                	push   $0x1
  80136c:	ff 75 f4             	pushl  -0xc(%ebp)
  80136f:	e8 59 ff ff ff       	call   8012cd <fd_close>
  801374:	83 c4 10             	add    $0x10,%esp
}
  801377:	c9                   	leave  
  801378:	c3                   	ret    

00801379 <close_all>:

void
close_all(void)
{
  801379:	55                   	push   %ebp
  80137a:	89 e5                	mov    %esp,%ebp
  80137c:	53                   	push   %ebx
  80137d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801380:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801385:	83 ec 0c             	sub    $0xc,%esp
  801388:	53                   	push   %ebx
  801389:	e8 c0 ff ff ff       	call   80134e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80138e:	83 c3 01             	add    $0x1,%ebx
  801391:	83 c4 10             	add    $0x10,%esp
  801394:	83 fb 20             	cmp    $0x20,%ebx
  801397:	75 ec                	jne    801385 <close_all+0xc>
		close(i);
}
  801399:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139c:	c9                   	leave  
  80139d:	c3                   	ret    

0080139e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	57                   	push   %edi
  8013a2:	56                   	push   %esi
  8013a3:	53                   	push   %ebx
  8013a4:	83 ec 2c             	sub    $0x2c,%esp
  8013a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013aa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013ad:	50                   	push   %eax
  8013ae:	ff 75 08             	pushl  0x8(%ebp)
  8013b1:	e8 6e fe ff ff       	call   801224 <fd_lookup>
  8013b6:	83 c4 08             	add    $0x8,%esp
  8013b9:	85 c0                	test   %eax,%eax
  8013bb:	0f 88 c1 00 00 00    	js     801482 <dup+0xe4>
		return r;
	close(newfdnum);
  8013c1:	83 ec 0c             	sub    $0xc,%esp
  8013c4:	56                   	push   %esi
  8013c5:	e8 84 ff ff ff       	call   80134e <close>

	newfd = INDEX2FD(newfdnum);
  8013ca:	89 f3                	mov    %esi,%ebx
  8013cc:	c1 e3 0c             	shl    $0xc,%ebx
  8013cf:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013d5:	83 c4 04             	add    $0x4,%esp
  8013d8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013db:	e8 de fd ff ff       	call   8011be <fd2data>
  8013e0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013e2:	89 1c 24             	mov    %ebx,(%esp)
  8013e5:	e8 d4 fd ff ff       	call   8011be <fd2data>
  8013ea:	83 c4 10             	add    $0x10,%esp
  8013ed:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013f0:	89 f8                	mov    %edi,%eax
  8013f2:	c1 e8 16             	shr    $0x16,%eax
  8013f5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013fc:	a8 01                	test   $0x1,%al
  8013fe:	74 37                	je     801437 <dup+0x99>
  801400:	89 f8                	mov    %edi,%eax
  801402:	c1 e8 0c             	shr    $0xc,%eax
  801405:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80140c:	f6 c2 01             	test   $0x1,%dl
  80140f:	74 26                	je     801437 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801411:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801418:	83 ec 0c             	sub    $0xc,%esp
  80141b:	25 07 0e 00 00       	and    $0xe07,%eax
  801420:	50                   	push   %eax
  801421:	ff 75 d4             	pushl  -0x2c(%ebp)
  801424:	6a 00                	push   $0x0
  801426:	57                   	push   %edi
  801427:	6a 00                	push   $0x0
  801429:	e8 9a f9 ff ff       	call   800dc8 <sys_page_map>
  80142e:	89 c7                	mov    %eax,%edi
  801430:	83 c4 20             	add    $0x20,%esp
  801433:	85 c0                	test   %eax,%eax
  801435:	78 2e                	js     801465 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801437:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80143a:	89 d0                	mov    %edx,%eax
  80143c:	c1 e8 0c             	shr    $0xc,%eax
  80143f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801446:	83 ec 0c             	sub    $0xc,%esp
  801449:	25 07 0e 00 00       	and    $0xe07,%eax
  80144e:	50                   	push   %eax
  80144f:	53                   	push   %ebx
  801450:	6a 00                	push   $0x0
  801452:	52                   	push   %edx
  801453:	6a 00                	push   $0x0
  801455:	e8 6e f9 ff ff       	call   800dc8 <sys_page_map>
  80145a:	89 c7                	mov    %eax,%edi
  80145c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80145f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801461:	85 ff                	test   %edi,%edi
  801463:	79 1d                	jns    801482 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801465:	83 ec 08             	sub    $0x8,%esp
  801468:	53                   	push   %ebx
  801469:	6a 00                	push   $0x0
  80146b:	e8 9a f9 ff ff       	call   800e0a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801470:	83 c4 08             	add    $0x8,%esp
  801473:	ff 75 d4             	pushl  -0x2c(%ebp)
  801476:	6a 00                	push   $0x0
  801478:	e8 8d f9 ff ff       	call   800e0a <sys_page_unmap>
	return r;
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	89 f8                	mov    %edi,%eax
}
  801482:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801485:	5b                   	pop    %ebx
  801486:	5e                   	pop    %esi
  801487:	5f                   	pop    %edi
  801488:	5d                   	pop    %ebp
  801489:	c3                   	ret    

0080148a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	53                   	push   %ebx
  80148e:	83 ec 14             	sub    $0x14,%esp
  801491:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801494:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801497:	50                   	push   %eax
  801498:	53                   	push   %ebx
  801499:	e8 86 fd ff ff       	call   801224 <fd_lookup>
  80149e:	83 c4 08             	add    $0x8,%esp
  8014a1:	89 c2                	mov    %eax,%edx
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 6d                	js     801514 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a7:	83 ec 08             	sub    $0x8,%esp
  8014aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ad:	50                   	push   %eax
  8014ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b1:	ff 30                	pushl  (%eax)
  8014b3:	e8 c2 fd ff ff       	call   80127a <dev_lookup>
  8014b8:	83 c4 10             	add    $0x10,%esp
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	78 4c                	js     80150b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014c2:	8b 42 08             	mov    0x8(%edx),%eax
  8014c5:	83 e0 03             	and    $0x3,%eax
  8014c8:	83 f8 01             	cmp    $0x1,%eax
  8014cb:	75 21                	jne    8014ee <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014cd:	a1 20 44 80 00       	mov    0x804420,%eax
  8014d2:	8b 40 48             	mov    0x48(%eax),%eax
  8014d5:	83 ec 04             	sub    $0x4,%esp
  8014d8:	53                   	push   %ebx
  8014d9:	50                   	push   %eax
  8014da:	68 30 2c 80 00       	push   $0x802c30
  8014df:	e8 19 ef ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014ec:	eb 26                	jmp    801514 <read+0x8a>
	}
	if (!dev->dev_read)
  8014ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f1:	8b 40 08             	mov    0x8(%eax),%eax
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	74 17                	je     80150f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014f8:	83 ec 04             	sub    $0x4,%esp
  8014fb:	ff 75 10             	pushl  0x10(%ebp)
  8014fe:	ff 75 0c             	pushl  0xc(%ebp)
  801501:	52                   	push   %edx
  801502:	ff d0                	call   *%eax
  801504:	89 c2                	mov    %eax,%edx
  801506:	83 c4 10             	add    $0x10,%esp
  801509:	eb 09                	jmp    801514 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150b:	89 c2                	mov    %eax,%edx
  80150d:	eb 05                	jmp    801514 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80150f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801514:	89 d0                	mov    %edx,%eax
  801516:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801519:	c9                   	leave  
  80151a:	c3                   	ret    

0080151b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80151b:	55                   	push   %ebp
  80151c:	89 e5                	mov    %esp,%ebp
  80151e:	57                   	push   %edi
  80151f:	56                   	push   %esi
  801520:	53                   	push   %ebx
  801521:	83 ec 0c             	sub    $0xc,%esp
  801524:	8b 7d 08             	mov    0x8(%ebp),%edi
  801527:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80152a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80152f:	eb 21                	jmp    801552 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801531:	83 ec 04             	sub    $0x4,%esp
  801534:	89 f0                	mov    %esi,%eax
  801536:	29 d8                	sub    %ebx,%eax
  801538:	50                   	push   %eax
  801539:	89 d8                	mov    %ebx,%eax
  80153b:	03 45 0c             	add    0xc(%ebp),%eax
  80153e:	50                   	push   %eax
  80153f:	57                   	push   %edi
  801540:	e8 45 ff ff ff       	call   80148a <read>
		if (m < 0)
  801545:	83 c4 10             	add    $0x10,%esp
  801548:	85 c0                	test   %eax,%eax
  80154a:	78 10                	js     80155c <readn+0x41>
			return m;
		if (m == 0)
  80154c:	85 c0                	test   %eax,%eax
  80154e:	74 0a                	je     80155a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801550:	01 c3                	add    %eax,%ebx
  801552:	39 f3                	cmp    %esi,%ebx
  801554:	72 db                	jb     801531 <readn+0x16>
  801556:	89 d8                	mov    %ebx,%eax
  801558:	eb 02                	jmp    80155c <readn+0x41>
  80155a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80155c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80155f:	5b                   	pop    %ebx
  801560:	5e                   	pop    %esi
  801561:	5f                   	pop    %edi
  801562:	5d                   	pop    %ebp
  801563:	c3                   	ret    

00801564 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
  801567:	53                   	push   %ebx
  801568:	83 ec 14             	sub    $0x14,%esp
  80156b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801571:	50                   	push   %eax
  801572:	53                   	push   %ebx
  801573:	e8 ac fc ff ff       	call   801224 <fd_lookup>
  801578:	83 c4 08             	add    $0x8,%esp
  80157b:	89 c2                	mov    %eax,%edx
  80157d:	85 c0                	test   %eax,%eax
  80157f:	78 68                	js     8015e9 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801581:	83 ec 08             	sub    $0x8,%esp
  801584:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801587:	50                   	push   %eax
  801588:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158b:	ff 30                	pushl  (%eax)
  80158d:	e8 e8 fc ff ff       	call   80127a <dev_lookup>
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	85 c0                	test   %eax,%eax
  801597:	78 47                	js     8015e0 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801599:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015a0:	75 21                	jne    8015c3 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015a2:	a1 20 44 80 00       	mov    0x804420,%eax
  8015a7:	8b 40 48             	mov    0x48(%eax),%eax
  8015aa:	83 ec 04             	sub    $0x4,%esp
  8015ad:	53                   	push   %ebx
  8015ae:	50                   	push   %eax
  8015af:	68 4c 2c 80 00       	push   $0x802c4c
  8015b4:	e8 44 ee ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c1:	eb 26                	jmp    8015e9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c6:	8b 52 0c             	mov    0xc(%edx),%edx
  8015c9:	85 d2                	test   %edx,%edx
  8015cb:	74 17                	je     8015e4 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015cd:	83 ec 04             	sub    $0x4,%esp
  8015d0:	ff 75 10             	pushl  0x10(%ebp)
  8015d3:	ff 75 0c             	pushl  0xc(%ebp)
  8015d6:	50                   	push   %eax
  8015d7:	ff d2                	call   *%edx
  8015d9:	89 c2                	mov    %eax,%edx
  8015db:	83 c4 10             	add    $0x10,%esp
  8015de:	eb 09                	jmp    8015e9 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e0:	89 c2                	mov    %eax,%edx
  8015e2:	eb 05                	jmp    8015e9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015e4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015e9:	89 d0                	mov    %edx,%eax
  8015eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ee:	c9                   	leave  
  8015ef:	c3                   	ret    

008015f0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015f6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015f9:	50                   	push   %eax
  8015fa:	ff 75 08             	pushl  0x8(%ebp)
  8015fd:	e8 22 fc ff ff       	call   801224 <fd_lookup>
  801602:	83 c4 08             	add    $0x8,%esp
  801605:	85 c0                	test   %eax,%eax
  801607:	78 0e                	js     801617 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801609:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80160c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80160f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801612:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801617:	c9                   	leave  
  801618:	c3                   	ret    

00801619 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801619:	55                   	push   %ebp
  80161a:	89 e5                	mov    %esp,%ebp
  80161c:	53                   	push   %ebx
  80161d:	83 ec 14             	sub    $0x14,%esp
  801620:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801623:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801626:	50                   	push   %eax
  801627:	53                   	push   %ebx
  801628:	e8 f7 fb ff ff       	call   801224 <fd_lookup>
  80162d:	83 c4 08             	add    $0x8,%esp
  801630:	89 c2                	mov    %eax,%edx
  801632:	85 c0                	test   %eax,%eax
  801634:	78 65                	js     80169b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801636:	83 ec 08             	sub    $0x8,%esp
  801639:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80163c:	50                   	push   %eax
  80163d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801640:	ff 30                	pushl  (%eax)
  801642:	e8 33 fc ff ff       	call   80127a <dev_lookup>
  801647:	83 c4 10             	add    $0x10,%esp
  80164a:	85 c0                	test   %eax,%eax
  80164c:	78 44                	js     801692 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80164e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801651:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801655:	75 21                	jne    801678 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801657:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80165c:	8b 40 48             	mov    0x48(%eax),%eax
  80165f:	83 ec 04             	sub    $0x4,%esp
  801662:	53                   	push   %ebx
  801663:	50                   	push   %eax
  801664:	68 0c 2c 80 00       	push   $0x802c0c
  801669:	e8 8f ed ff ff       	call   8003fd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801676:	eb 23                	jmp    80169b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801678:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80167b:	8b 52 18             	mov    0x18(%edx),%edx
  80167e:	85 d2                	test   %edx,%edx
  801680:	74 14                	je     801696 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801682:	83 ec 08             	sub    $0x8,%esp
  801685:	ff 75 0c             	pushl  0xc(%ebp)
  801688:	50                   	push   %eax
  801689:	ff d2                	call   *%edx
  80168b:	89 c2                	mov    %eax,%edx
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	eb 09                	jmp    80169b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801692:	89 c2                	mov    %eax,%edx
  801694:	eb 05                	jmp    80169b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801696:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80169b:	89 d0                	mov    %edx,%eax
  80169d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a0:	c9                   	leave  
  8016a1:	c3                   	ret    

008016a2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016a2:	55                   	push   %ebp
  8016a3:	89 e5                	mov    %esp,%ebp
  8016a5:	53                   	push   %ebx
  8016a6:	83 ec 14             	sub    $0x14,%esp
  8016a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016af:	50                   	push   %eax
  8016b0:	ff 75 08             	pushl  0x8(%ebp)
  8016b3:	e8 6c fb ff ff       	call   801224 <fd_lookup>
  8016b8:	83 c4 08             	add    $0x8,%esp
  8016bb:	89 c2                	mov    %eax,%edx
  8016bd:	85 c0                	test   %eax,%eax
  8016bf:	78 58                	js     801719 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c1:	83 ec 08             	sub    $0x8,%esp
  8016c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c7:	50                   	push   %eax
  8016c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cb:	ff 30                	pushl  (%eax)
  8016cd:	e8 a8 fb ff ff       	call   80127a <dev_lookup>
  8016d2:	83 c4 10             	add    $0x10,%esp
  8016d5:	85 c0                	test   %eax,%eax
  8016d7:	78 37                	js     801710 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016dc:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016e0:	74 32                	je     801714 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016e2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016e5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016ec:	00 00 00 
	stat->st_isdir = 0;
  8016ef:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016f6:	00 00 00 
	stat->st_dev = dev;
  8016f9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016ff:	83 ec 08             	sub    $0x8,%esp
  801702:	53                   	push   %ebx
  801703:	ff 75 f0             	pushl  -0x10(%ebp)
  801706:	ff 50 14             	call   *0x14(%eax)
  801709:	89 c2                	mov    %eax,%edx
  80170b:	83 c4 10             	add    $0x10,%esp
  80170e:	eb 09                	jmp    801719 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801710:	89 c2                	mov    %eax,%edx
  801712:	eb 05                	jmp    801719 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801714:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801719:	89 d0                	mov    %edx,%eax
  80171b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171e:	c9                   	leave  
  80171f:	c3                   	ret    

00801720 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	56                   	push   %esi
  801724:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801725:	83 ec 08             	sub    $0x8,%esp
  801728:	6a 00                	push   $0x0
  80172a:	ff 75 08             	pushl  0x8(%ebp)
  80172d:	e8 0c 02 00 00       	call   80193e <open>
  801732:	89 c3                	mov    %eax,%ebx
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	85 c0                	test   %eax,%eax
  801739:	78 1b                	js     801756 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80173b:	83 ec 08             	sub    $0x8,%esp
  80173e:	ff 75 0c             	pushl  0xc(%ebp)
  801741:	50                   	push   %eax
  801742:	e8 5b ff ff ff       	call   8016a2 <fstat>
  801747:	89 c6                	mov    %eax,%esi
	close(fd);
  801749:	89 1c 24             	mov    %ebx,(%esp)
  80174c:	e8 fd fb ff ff       	call   80134e <close>
	return r;
  801751:	83 c4 10             	add    $0x10,%esp
  801754:	89 f0                	mov    %esi,%eax
}
  801756:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801759:	5b                   	pop    %ebx
  80175a:	5e                   	pop    %esi
  80175b:	5d                   	pop    %ebp
  80175c:	c3                   	ret    

0080175d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80175d:	55                   	push   %ebp
  80175e:	89 e5                	mov    %esp,%ebp
  801760:	56                   	push   %esi
  801761:	53                   	push   %ebx
  801762:	89 c6                	mov    %eax,%esi
  801764:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801766:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80176d:	75 12                	jne    801781 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80176f:	83 ec 0c             	sub    $0xc,%esp
  801772:	6a 01                	push   $0x1
  801774:	e8 7c 0d 00 00       	call   8024f5 <ipc_find_env>
  801779:	a3 00 40 80 00       	mov    %eax,0x804000
  80177e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801781:	6a 07                	push   $0x7
  801783:	68 00 50 80 00       	push   $0x805000
  801788:	56                   	push   %esi
  801789:	ff 35 00 40 80 00    	pushl  0x804000
  80178f:	e8 0d 0d 00 00       	call   8024a1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801794:	83 c4 0c             	add    $0xc,%esp
  801797:	6a 00                	push   $0x0
  801799:	53                   	push   %ebx
  80179a:	6a 00                	push   $0x0
  80179c:	e8 97 0c 00 00       	call   802438 <ipc_recv>
}
  8017a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a4:	5b                   	pop    %ebx
  8017a5:	5e                   	pop    %esi
  8017a6:	5d                   	pop    %ebp
  8017a7:	c3                   	ret    

008017a8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
  8017ab:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b1:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017bc:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c6:	b8 02 00 00 00       	mov    $0x2,%eax
  8017cb:	e8 8d ff ff ff       	call   80175d <fsipc>
}
  8017d0:	c9                   	leave  
  8017d1:	c3                   	ret    

008017d2 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017db:	8b 40 0c             	mov    0xc(%eax),%eax
  8017de:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e8:	b8 06 00 00 00       	mov    $0x6,%eax
  8017ed:	e8 6b ff ff ff       	call   80175d <fsipc>
}
  8017f2:	c9                   	leave  
  8017f3:	c3                   	ret    

008017f4 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	53                   	push   %ebx
  8017f8:	83 ec 04             	sub    $0x4,%esp
  8017fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801801:	8b 40 0c             	mov    0xc(%eax),%eax
  801804:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801809:	ba 00 00 00 00       	mov    $0x0,%edx
  80180e:	b8 05 00 00 00       	mov    $0x5,%eax
  801813:	e8 45 ff ff ff       	call   80175d <fsipc>
  801818:	85 c0                	test   %eax,%eax
  80181a:	78 2c                	js     801848 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80181c:	83 ec 08             	sub    $0x8,%esp
  80181f:	68 00 50 80 00       	push   $0x805000
  801824:	53                   	push   %ebx
  801825:	e8 58 f1 ff ff       	call   800982 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80182a:	a1 80 50 80 00       	mov    0x805080,%eax
  80182f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801835:	a1 84 50 80 00       	mov    0x805084,%eax
  80183a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801848:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184b:	c9                   	leave  
  80184c:	c3                   	ret    

0080184d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	53                   	push   %ebx
  801851:	83 ec 08             	sub    $0x8,%esp
  801854:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801857:	8b 55 08             	mov    0x8(%ebp),%edx
  80185a:	8b 52 0c             	mov    0xc(%edx),%edx
  80185d:	89 15 00 50 80 00    	mov    %edx,0x805000
  801863:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801868:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  80186d:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  801870:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801876:	53                   	push   %ebx
  801877:	ff 75 0c             	pushl  0xc(%ebp)
  80187a:	68 08 50 80 00       	push   $0x805008
  80187f:	e8 90 f2 ff ff       	call   800b14 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  801884:	ba 00 00 00 00       	mov    $0x0,%edx
  801889:	b8 04 00 00 00       	mov    $0x4,%eax
  80188e:	e8 ca fe ff ff       	call   80175d <fsipc>
  801893:	83 c4 10             	add    $0x10,%esp
  801896:	85 c0                	test   %eax,%eax
  801898:	78 1d                	js     8018b7 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  80189a:	39 d8                	cmp    %ebx,%eax
  80189c:	76 19                	jbe    8018b7 <devfile_write+0x6a>
  80189e:	68 80 2c 80 00       	push   $0x802c80
  8018a3:	68 8c 2c 80 00       	push   $0x802c8c
  8018a8:	68 a5 00 00 00       	push   $0xa5
  8018ad:	68 a1 2c 80 00       	push   $0x802ca1
  8018b2:	e8 6d ea ff ff       	call   800324 <_panic>
	return r;
}
  8018b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ba:	c9                   	leave  
  8018bb:	c3                   	ret    

008018bc <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	56                   	push   %esi
  8018c0:	53                   	push   %ebx
  8018c1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ca:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018cf:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018da:	b8 03 00 00 00       	mov    $0x3,%eax
  8018df:	e8 79 fe ff ff       	call   80175d <fsipc>
  8018e4:	89 c3                	mov    %eax,%ebx
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	78 4b                	js     801935 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018ea:	39 c6                	cmp    %eax,%esi
  8018ec:	73 16                	jae    801904 <devfile_read+0x48>
  8018ee:	68 ac 2c 80 00       	push   $0x802cac
  8018f3:	68 8c 2c 80 00       	push   $0x802c8c
  8018f8:	6a 7c                	push   $0x7c
  8018fa:	68 a1 2c 80 00       	push   $0x802ca1
  8018ff:	e8 20 ea ff ff       	call   800324 <_panic>
	assert(r <= PGSIZE);
  801904:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801909:	7e 16                	jle    801921 <devfile_read+0x65>
  80190b:	68 b3 2c 80 00       	push   $0x802cb3
  801910:	68 8c 2c 80 00       	push   $0x802c8c
  801915:	6a 7d                	push   $0x7d
  801917:	68 a1 2c 80 00       	push   $0x802ca1
  80191c:	e8 03 ea ff ff       	call   800324 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801921:	83 ec 04             	sub    $0x4,%esp
  801924:	50                   	push   %eax
  801925:	68 00 50 80 00       	push   $0x805000
  80192a:	ff 75 0c             	pushl  0xc(%ebp)
  80192d:	e8 e2 f1 ff ff       	call   800b14 <memmove>
	return r;
  801932:	83 c4 10             	add    $0x10,%esp
}
  801935:	89 d8                	mov    %ebx,%eax
  801937:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193a:	5b                   	pop    %ebx
  80193b:	5e                   	pop    %esi
  80193c:	5d                   	pop    %ebp
  80193d:	c3                   	ret    

0080193e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	53                   	push   %ebx
  801942:	83 ec 20             	sub    $0x20,%esp
  801945:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801948:	53                   	push   %ebx
  801949:	e8 fb ef ff ff       	call   800949 <strlen>
  80194e:	83 c4 10             	add    $0x10,%esp
  801951:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801956:	7f 67                	jg     8019bf <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801958:	83 ec 0c             	sub    $0xc,%esp
  80195b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195e:	50                   	push   %eax
  80195f:	e8 71 f8 ff ff       	call   8011d5 <fd_alloc>
  801964:	83 c4 10             	add    $0x10,%esp
		return r;
  801967:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801969:	85 c0                	test   %eax,%eax
  80196b:	78 57                	js     8019c4 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80196d:	83 ec 08             	sub    $0x8,%esp
  801970:	53                   	push   %ebx
  801971:	68 00 50 80 00       	push   $0x805000
  801976:	e8 07 f0 ff ff       	call   800982 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80197b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80197e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801983:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801986:	b8 01 00 00 00       	mov    $0x1,%eax
  80198b:	e8 cd fd ff ff       	call   80175d <fsipc>
  801990:	89 c3                	mov    %eax,%ebx
  801992:	83 c4 10             	add    $0x10,%esp
  801995:	85 c0                	test   %eax,%eax
  801997:	79 14                	jns    8019ad <open+0x6f>
		fd_close(fd, 0);
  801999:	83 ec 08             	sub    $0x8,%esp
  80199c:	6a 00                	push   $0x0
  80199e:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a1:	e8 27 f9 ff ff       	call   8012cd <fd_close>
		return r;
  8019a6:	83 c4 10             	add    $0x10,%esp
  8019a9:	89 da                	mov    %ebx,%edx
  8019ab:	eb 17                	jmp    8019c4 <open+0x86>
	}

	return fd2num(fd);
  8019ad:	83 ec 0c             	sub    $0xc,%esp
  8019b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b3:	e8 f6 f7 ff ff       	call   8011ae <fd2num>
  8019b8:	89 c2                	mov    %eax,%edx
  8019ba:	83 c4 10             	add    $0x10,%esp
  8019bd:	eb 05                	jmp    8019c4 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019bf:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019c4:	89 d0                	mov    %edx,%eax
  8019c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c9:	c9                   	leave  
  8019ca:	c3                   	ret    

008019cb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d6:	b8 08 00 00 00       	mov    $0x8,%eax
  8019db:	e8 7d fd ff ff       	call   80175d <fsipc>
}
  8019e0:	c9                   	leave  
  8019e1:	c3                   	ret    

008019e2 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8019e2:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8019e6:	7e 37                	jle    801a1f <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	53                   	push   %ebx
  8019ec:	83 ec 08             	sub    $0x8,%esp
  8019ef:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8019f1:	ff 70 04             	pushl  0x4(%eax)
  8019f4:	8d 40 10             	lea    0x10(%eax),%eax
  8019f7:	50                   	push   %eax
  8019f8:	ff 33                	pushl  (%ebx)
  8019fa:	e8 65 fb ff ff       	call   801564 <write>
		if (result > 0)
  8019ff:	83 c4 10             	add    $0x10,%esp
  801a02:	85 c0                	test   %eax,%eax
  801a04:	7e 03                	jle    801a09 <writebuf+0x27>
			b->result += result;
  801a06:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801a09:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a0c:	74 0d                	je     801a1b <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	ba 00 00 00 00       	mov    $0x0,%edx
  801a15:	0f 4f c2             	cmovg  %edx,%eax
  801a18:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801a1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1e:	c9                   	leave  
  801a1f:	f3 c3                	repz ret 

00801a21 <putch>:

static void
putch(int ch, void *thunk)
{
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	53                   	push   %ebx
  801a25:	83 ec 04             	sub    $0x4,%esp
  801a28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801a2b:	8b 53 04             	mov    0x4(%ebx),%edx
  801a2e:	8d 42 01             	lea    0x1(%edx),%eax
  801a31:	89 43 04             	mov    %eax,0x4(%ebx)
  801a34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a37:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801a3b:	3d 00 01 00 00       	cmp    $0x100,%eax
  801a40:	75 0e                	jne    801a50 <putch+0x2f>
		writebuf(b);
  801a42:	89 d8                	mov    %ebx,%eax
  801a44:	e8 99 ff ff ff       	call   8019e2 <writebuf>
		b->idx = 0;
  801a49:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801a50:	83 c4 04             	add    $0x4,%esp
  801a53:	5b                   	pop    %ebx
  801a54:	5d                   	pop    %ebp
  801a55:	c3                   	ret    

00801a56 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a62:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801a68:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801a6f:	00 00 00 
	b.result = 0;
  801a72:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a79:	00 00 00 
	b.error = 1;
  801a7c:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801a83:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801a86:	ff 75 10             	pushl  0x10(%ebp)
  801a89:	ff 75 0c             	pushl  0xc(%ebp)
  801a8c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a92:	50                   	push   %eax
  801a93:	68 21 1a 80 00       	push   $0x801a21
  801a98:	e8 97 ea ff ff       	call   800534 <vprintfmt>
	if (b.idx > 0)
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801aa7:	7e 0b                	jle    801ab4 <vfprintf+0x5e>
		writebuf(&b);
  801aa9:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801aaf:	e8 2e ff ff ff       	call   8019e2 <writebuf>

	return (b.result ? b.result : b.error);
  801ab4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801aba:	85 c0                	test   %eax,%eax
  801abc:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801ac3:	c9                   	leave  
  801ac4:	c3                   	ret    

00801ac5 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801ac5:	55                   	push   %ebp
  801ac6:	89 e5                	mov    %esp,%ebp
  801ac8:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801acb:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801ace:	50                   	push   %eax
  801acf:	ff 75 0c             	pushl  0xc(%ebp)
  801ad2:	ff 75 08             	pushl  0x8(%ebp)
  801ad5:	e8 7c ff ff ff       	call   801a56 <vfprintf>
	va_end(ap);

	return cnt;
}
  801ada:	c9                   	leave  
  801adb:	c3                   	ret    

00801adc <printf>:

int
printf(const char *fmt, ...)
{
  801adc:	55                   	push   %ebp
  801add:	89 e5                	mov    %esp,%ebp
  801adf:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801ae2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801ae5:	50                   	push   %eax
  801ae6:	ff 75 08             	pushl  0x8(%ebp)
  801ae9:	6a 01                	push   $0x1
  801aeb:	e8 66 ff ff ff       	call   801a56 <vfprintf>
	va_end(ap);

	return cnt;
}
  801af0:	c9                   	leave  
  801af1:	c3                   	ret    

00801af2 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801af8:	68 bf 2c 80 00       	push   $0x802cbf
  801afd:	ff 75 0c             	pushl  0xc(%ebp)
  801b00:	e8 7d ee ff ff       	call   800982 <strcpy>
	return 0;
}
  801b05:	b8 00 00 00 00       	mov    $0x0,%eax
  801b0a:	c9                   	leave  
  801b0b:	c3                   	ret    

00801b0c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	53                   	push   %ebx
  801b10:	83 ec 10             	sub    $0x10,%esp
  801b13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b16:	53                   	push   %ebx
  801b17:	e8 12 0a 00 00       	call   80252e <pageref>
  801b1c:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801b1f:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801b24:	83 f8 01             	cmp    $0x1,%eax
  801b27:	75 10                	jne    801b39 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801b29:	83 ec 0c             	sub    $0xc,%esp
  801b2c:	ff 73 0c             	pushl  0xc(%ebx)
  801b2f:	e8 c0 02 00 00       	call   801df4 <nsipc_close>
  801b34:	89 c2                	mov    %eax,%edx
  801b36:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801b39:	89 d0                	mov    %edx,%eax
  801b3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b3e:	c9                   	leave  
  801b3f:	c3                   	ret    

00801b40 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b46:	6a 00                	push   $0x0
  801b48:	ff 75 10             	pushl  0x10(%ebp)
  801b4b:	ff 75 0c             	pushl  0xc(%ebp)
  801b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b51:	ff 70 0c             	pushl  0xc(%eax)
  801b54:	e8 78 03 00 00       	call   801ed1 <nsipc_send>
}
  801b59:	c9                   	leave  
  801b5a:	c3                   	ret    

00801b5b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b61:	6a 00                	push   $0x0
  801b63:	ff 75 10             	pushl  0x10(%ebp)
  801b66:	ff 75 0c             	pushl  0xc(%ebp)
  801b69:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6c:	ff 70 0c             	pushl  0xc(%eax)
  801b6f:	e8 f1 02 00 00       	call   801e65 <nsipc_recv>
}
  801b74:	c9                   	leave  
  801b75:	c3                   	ret    

00801b76 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b76:	55                   	push   %ebp
  801b77:	89 e5                	mov    %esp,%ebp
  801b79:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b7c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b7f:	52                   	push   %edx
  801b80:	50                   	push   %eax
  801b81:	e8 9e f6 ff ff       	call   801224 <fd_lookup>
  801b86:	83 c4 10             	add    $0x10,%esp
  801b89:	85 c0                	test   %eax,%eax
  801b8b:	78 17                	js     801ba4 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b90:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801b96:	39 08                	cmp    %ecx,(%eax)
  801b98:	75 05                	jne    801b9f <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b9a:	8b 40 0c             	mov    0xc(%eax),%eax
  801b9d:	eb 05                	jmp    801ba4 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b9f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801ba4:	c9                   	leave  
  801ba5:	c3                   	ret    

00801ba6 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801ba6:	55                   	push   %ebp
  801ba7:	89 e5                	mov    %esp,%ebp
  801ba9:	56                   	push   %esi
  801baa:	53                   	push   %ebx
  801bab:	83 ec 1c             	sub    $0x1c,%esp
  801bae:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801bb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb3:	50                   	push   %eax
  801bb4:	e8 1c f6 ff ff       	call   8011d5 <fd_alloc>
  801bb9:	89 c3                	mov    %eax,%ebx
  801bbb:	83 c4 10             	add    $0x10,%esp
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	78 1b                	js     801bdd <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801bc2:	83 ec 04             	sub    $0x4,%esp
  801bc5:	68 07 04 00 00       	push   $0x407
  801bca:	ff 75 f4             	pushl  -0xc(%ebp)
  801bcd:	6a 00                	push   $0x0
  801bcf:	e8 b1 f1 ff ff       	call   800d85 <sys_page_alloc>
  801bd4:	89 c3                	mov    %eax,%ebx
  801bd6:	83 c4 10             	add    $0x10,%esp
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	79 10                	jns    801bed <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801bdd:	83 ec 0c             	sub    $0xc,%esp
  801be0:	56                   	push   %esi
  801be1:	e8 0e 02 00 00       	call   801df4 <nsipc_close>
		return r;
  801be6:	83 c4 10             	add    $0x10,%esp
  801be9:	89 d8                	mov    %ebx,%eax
  801beb:	eb 24                	jmp    801c11 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801bed:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c02:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c05:	83 ec 0c             	sub    $0xc,%esp
  801c08:	50                   	push   %eax
  801c09:	e8 a0 f5 ff ff       	call   8011ae <fd2num>
  801c0e:	83 c4 10             	add    $0x10,%esp
}
  801c11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c14:	5b                   	pop    %ebx
  801c15:	5e                   	pop    %esi
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    

00801c18 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c21:	e8 50 ff ff ff       	call   801b76 <fd2sockid>
		return r;
  801c26:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c28:	85 c0                	test   %eax,%eax
  801c2a:	78 1f                	js     801c4b <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c2c:	83 ec 04             	sub    $0x4,%esp
  801c2f:	ff 75 10             	pushl  0x10(%ebp)
  801c32:	ff 75 0c             	pushl  0xc(%ebp)
  801c35:	50                   	push   %eax
  801c36:	e8 12 01 00 00       	call   801d4d <nsipc_accept>
  801c3b:	83 c4 10             	add    $0x10,%esp
		return r;
  801c3e:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c40:	85 c0                	test   %eax,%eax
  801c42:	78 07                	js     801c4b <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801c44:	e8 5d ff ff ff       	call   801ba6 <alloc_sockfd>
  801c49:	89 c1                	mov    %eax,%ecx
}
  801c4b:	89 c8                	mov    %ecx,%eax
  801c4d:	c9                   	leave  
  801c4e:	c3                   	ret    

00801c4f <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c55:	8b 45 08             	mov    0x8(%ebp),%eax
  801c58:	e8 19 ff ff ff       	call   801b76 <fd2sockid>
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	78 12                	js     801c73 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801c61:	83 ec 04             	sub    $0x4,%esp
  801c64:	ff 75 10             	pushl  0x10(%ebp)
  801c67:	ff 75 0c             	pushl  0xc(%ebp)
  801c6a:	50                   	push   %eax
  801c6b:	e8 2d 01 00 00       	call   801d9d <nsipc_bind>
  801c70:	83 c4 10             	add    $0x10,%esp
}
  801c73:	c9                   	leave  
  801c74:	c3                   	ret    

00801c75 <shutdown>:

int
shutdown(int s, int how)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7e:	e8 f3 fe ff ff       	call   801b76 <fd2sockid>
  801c83:	85 c0                	test   %eax,%eax
  801c85:	78 0f                	js     801c96 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801c87:	83 ec 08             	sub    $0x8,%esp
  801c8a:	ff 75 0c             	pushl  0xc(%ebp)
  801c8d:	50                   	push   %eax
  801c8e:	e8 3f 01 00 00       	call   801dd2 <nsipc_shutdown>
  801c93:	83 c4 10             	add    $0x10,%esp
}
  801c96:	c9                   	leave  
  801c97:	c3                   	ret    

00801c98 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca1:	e8 d0 fe ff ff       	call   801b76 <fd2sockid>
  801ca6:	85 c0                	test   %eax,%eax
  801ca8:	78 12                	js     801cbc <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801caa:	83 ec 04             	sub    $0x4,%esp
  801cad:	ff 75 10             	pushl  0x10(%ebp)
  801cb0:	ff 75 0c             	pushl  0xc(%ebp)
  801cb3:	50                   	push   %eax
  801cb4:	e8 55 01 00 00       	call   801e0e <nsipc_connect>
  801cb9:	83 c4 10             	add    $0x10,%esp
}
  801cbc:	c9                   	leave  
  801cbd:	c3                   	ret    

00801cbe <listen>:

int
listen(int s, int backlog)
{
  801cbe:	55                   	push   %ebp
  801cbf:	89 e5                	mov    %esp,%ebp
  801cc1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc7:	e8 aa fe ff ff       	call   801b76 <fd2sockid>
  801ccc:	85 c0                	test   %eax,%eax
  801cce:	78 0f                	js     801cdf <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801cd0:	83 ec 08             	sub    $0x8,%esp
  801cd3:	ff 75 0c             	pushl  0xc(%ebp)
  801cd6:	50                   	push   %eax
  801cd7:	e8 67 01 00 00       	call   801e43 <nsipc_listen>
  801cdc:	83 c4 10             	add    $0x10,%esp
}
  801cdf:	c9                   	leave  
  801ce0:	c3                   	ret    

00801ce1 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ce1:	55                   	push   %ebp
  801ce2:	89 e5                	mov    %esp,%ebp
  801ce4:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801ce7:	ff 75 10             	pushl  0x10(%ebp)
  801cea:	ff 75 0c             	pushl  0xc(%ebp)
  801ced:	ff 75 08             	pushl  0x8(%ebp)
  801cf0:	e8 3a 02 00 00       	call   801f2f <nsipc_socket>
  801cf5:	83 c4 10             	add    $0x10,%esp
  801cf8:	85 c0                	test   %eax,%eax
  801cfa:	78 05                	js     801d01 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801cfc:	e8 a5 fe ff ff       	call   801ba6 <alloc_sockfd>
}
  801d01:	c9                   	leave  
  801d02:	c3                   	ret    

00801d03 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d03:	55                   	push   %ebp
  801d04:	89 e5                	mov    %esp,%ebp
  801d06:	53                   	push   %ebx
  801d07:	83 ec 04             	sub    $0x4,%esp
  801d0a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d0c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801d13:	75 12                	jne    801d27 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d15:	83 ec 0c             	sub    $0xc,%esp
  801d18:	6a 02                	push   $0x2
  801d1a:	e8 d6 07 00 00       	call   8024f5 <ipc_find_env>
  801d1f:	a3 04 40 80 00       	mov    %eax,0x804004
  801d24:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d27:	6a 07                	push   $0x7
  801d29:	68 00 60 80 00       	push   $0x806000
  801d2e:	53                   	push   %ebx
  801d2f:	ff 35 04 40 80 00    	pushl  0x804004
  801d35:	e8 67 07 00 00       	call   8024a1 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d3a:	83 c4 0c             	add    $0xc,%esp
  801d3d:	6a 00                	push   $0x0
  801d3f:	6a 00                	push   $0x0
  801d41:	6a 00                	push   $0x0
  801d43:	e8 f0 06 00 00       	call   802438 <ipc_recv>
}
  801d48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d4b:	c9                   	leave  
  801d4c:	c3                   	ret    

00801d4d <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d4d:	55                   	push   %ebp
  801d4e:	89 e5                	mov    %esp,%ebp
  801d50:	56                   	push   %esi
  801d51:	53                   	push   %ebx
  801d52:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d55:	8b 45 08             	mov    0x8(%ebp),%eax
  801d58:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d5d:	8b 06                	mov    (%esi),%eax
  801d5f:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d64:	b8 01 00 00 00       	mov    $0x1,%eax
  801d69:	e8 95 ff ff ff       	call   801d03 <nsipc>
  801d6e:	89 c3                	mov    %eax,%ebx
  801d70:	85 c0                	test   %eax,%eax
  801d72:	78 20                	js     801d94 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d74:	83 ec 04             	sub    $0x4,%esp
  801d77:	ff 35 10 60 80 00    	pushl  0x806010
  801d7d:	68 00 60 80 00       	push   $0x806000
  801d82:	ff 75 0c             	pushl  0xc(%ebp)
  801d85:	e8 8a ed ff ff       	call   800b14 <memmove>
		*addrlen = ret->ret_addrlen;
  801d8a:	a1 10 60 80 00       	mov    0x806010,%eax
  801d8f:	89 06                	mov    %eax,(%esi)
  801d91:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d94:	89 d8                	mov    %ebx,%eax
  801d96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d99:	5b                   	pop    %ebx
  801d9a:	5e                   	pop    %esi
  801d9b:	5d                   	pop    %ebp
  801d9c:	c3                   	ret    

00801d9d <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
  801da0:	53                   	push   %ebx
  801da1:	83 ec 08             	sub    $0x8,%esp
  801da4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801da7:	8b 45 08             	mov    0x8(%ebp),%eax
  801daa:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801daf:	53                   	push   %ebx
  801db0:	ff 75 0c             	pushl  0xc(%ebp)
  801db3:	68 04 60 80 00       	push   $0x806004
  801db8:	e8 57 ed ff ff       	call   800b14 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801dbd:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801dc3:	b8 02 00 00 00       	mov    $0x2,%eax
  801dc8:	e8 36 ff ff ff       	call   801d03 <nsipc>
}
  801dcd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dd0:	c9                   	leave  
  801dd1:	c3                   	ret    

00801dd2 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801dd2:	55                   	push   %ebp
  801dd3:	89 e5                	mov    %esp,%ebp
  801dd5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801dd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801de0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de3:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801de8:	b8 03 00 00 00       	mov    $0x3,%eax
  801ded:	e8 11 ff ff ff       	call   801d03 <nsipc>
}
  801df2:	c9                   	leave  
  801df3:	c3                   	ret    

00801df4 <nsipc_close>:

int
nsipc_close(int s)
{
  801df4:	55                   	push   %ebp
  801df5:	89 e5                	mov    %esp,%ebp
  801df7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801dfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfd:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801e02:	b8 04 00 00 00       	mov    $0x4,%eax
  801e07:	e8 f7 fe ff ff       	call   801d03 <nsipc>
}
  801e0c:	c9                   	leave  
  801e0d:	c3                   	ret    

00801e0e <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
  801e11:	53                   	push   %ebx
  801e12:	83 ec 08             	sub    $0x8,%esp
  801e15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e18:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e20:	53                   	push   %ebx
  801e21:	ff 75 0c             	pushl  0xc(%ebp)
  801e24:	68 04 60 80 00       	push   $0x806004
  801e29:	e8 e6 ec ff ff       	call   800b14 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e2e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e34:	b8 05 00 00 00       	mov    $0x5,%eax
  801e39:	e8 c5 fe ff ff       	call   801d03 <nsipc>
}
  801e3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e41:	c9                   	leave  
  801e42:	c3                   	ret    

00801e43 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e43:	55                   	push   %ebp
  801e44:	89 e5                	mov    %esp,%ebp
  801e46:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e49:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e51:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e54:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e59:	b8 06 00 00 00       	mov    $0x6,%eax
  801e5e:	e8 a0 fe ff ff       	call   801d03 <nsipc>
}
  801e63:	c9                   	leave  
  801e64:	c3                   	ret    

00801e65 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e65:	55                   	push   %ebp
  801e66:	89 e5                	mov    %esp,%ebp
  801e68:	56                   	push   %esi
  801e69:	53                   	push   %ebx
  801e6a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e70:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e75:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e7b:	8b 45 14             	mov    0x14(%ebp),%eax
  801e7e:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e83:	b8 07 00 00 00       	mov    $0x7,%eax
  801e88:	e8 76 fe ff ff       	call   801d03 <nsipc>
  801e8d:	89 c3                	mov    %eax,%ebx
  801e8f:	85 c0                	test   %eax,%eax
  801e91:	78 35                	js     801ec8 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e93:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e98:	7f 04                	jg     801e9e <nsipc_recv+0x39>
  801e9a:	39 c6                	cmp    %eax,%esi
  801e9c:	7d 16                	jge    801eb4 <nsipc_recv+0x4f>
  801e9e:	68 cb 2c 80 00       	push   $0x802ccb
  801ea3:	68 8c 2c 80 00       	push   $0x802c8c
  801ea8:	6a 62                	push   $0x62
  801eaa:	68 e0 2c 80 00       	push   $0x802ce0
  801eaf:	e8 70 e4 ff ff       	call   800324 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801eb4:	83 ec 04             	sub    $0x4,%esp
  801eb7:	50                   	push   %eax
  801eb8:	68 00 60 80 00       	push   $0x806000
  801ebd:	ff 75 0c             	pushl  0xc(%ebp)
  801ec0:	e8 4f ec ff ff       	call   800b14 <memmove>
  801ec5:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ec8:	89 d8                	mov    %ebx,%eax
  801eca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ecd:	5b                   	pop    %ebx
  801ece:	5e                   	pop    %esi
  801ecf:	5d                   	pop    %ebp
  801ed0:	c3                   	ret    

00801ed1 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ed1:	55                   	push   %ebp
  801ed2:	89 e5                	mov    %esp,%ebp
  801ed4:	53                   	push   %ebx
  801ed5:	83 ec 04             	sub    $0x4,%esp
  801ed8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801edb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ede:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ee3:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ee9:	7e 16                	jle    801f01 <nsipc_send+0x30>
  801eeb:	68 ec 2c 80 00       	push   $0x802cec
  801ef0:	68 8c 2c 80 00       	push   $0x802c8c
  801ef5:	6a 6d                	push   $0x6d
  801ef7:	68 e0 2c 80 00       	push   $0x802ce0
  801efc:	e8 23 e4 ff ff       	call   800324 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801f01:	83 ec 04             	sub    $0x4,%esp
  801f04:	53                   	push   %ebx
  801f05:	ff 75 0c             	pushl  0xc(%ebp)
  801f08:	68 0c 60 80 00       	push   $0x80600c
  801f0d:	e8 02 ec ff ff       	call   800b14 <memmove>
	nsipcbuf.send.req_size = size;
  801f12:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801f18:	8b 45 14             	mov    0x14(%ebp),%eax
  801f1b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801f20:	b8 08 00 00 00       	mov    $0x8,%eax
  801f25:	e8 d9 fd ff ff       	call   801d03 <nsipc>
}
  801f2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f2d:	c9                   	leave  
  801f2e:	c3                   	ret    

00801f2f <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f2f:	55                   	push   %ebp
  801f30:	89 e5                	mov    %esp,%ebp
  801f32:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f35:	8b 45 08             	mov    0x8(%ebp),%eax
  801f38:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801f3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f40:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801f45:	8b 45 10             	mov    0x10(%ebp),%eax
  801f48:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801f4d:	b8 09 00 00 00       	mov    $0x9,%eax
  801f52:	e8 ac fd ff ff       	call   801d03 <nsipc>
}
  801f57:	c9                   	leave  
  801f58:	c3                   	ret    

00801f59 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	56                   	push   %esi
  801f5d:	53                   	push   %ebx
  801f5e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f61:	83 ec 0c             	sub    $0xc,%esp
  801f64:	ff 75 08             	pushl  0x8(%ebp)
  801f67:	e8 52 f2 ff ff       	call   8011be <fd2data>
  801f6c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f6e:	83 c4 08             	add    $0x8,%esp
  801f71:	68 f8 2c 80 00       	push   $0x802cf8
  801f76:	53                   	push   %ebx
  801f77:	e8 06 ea ff ff       	call   800982 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f7c:	8b 46 04             	mov    0x4(%esi),%eax
  801f7f:	2b 06                	sub    (%esi),%eax
  801f81:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f87:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f8e:	00 00 00 
	stat->st_dev = &devpipe;
  801f91:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801f98:	30 80 00 
	return 0;
}
  801f9b:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fa3:	5b                   	pop    %ebx
  801fa4:	5e                   	pop    %esi
  801fa5:	5d                   	pop    %ebp
  801fa6:	c3                   	ret    

00801fa7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fa7:	55                   	push   %ebp
  801fa8:	89 e5                	mov    %esp,%ebp
  801faa:	53                   	push   %ebx
  801fab:	83 ec 0c             	sub    $0xc,%esp
  801fae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fb1:	53                   	push   %ebx
  801fb2:	6a 00                	push   $0x0
  801fb4:	e8 51 ee ff ff       	call   800e0a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fb9:	89 1c 24             	mov    %ebx,(%esp)
  801fbc:	e8 fd f1 ff ff       	call   8011be <fd2data>
  801fc1:	83 c4 08             	add    $0x8,%esp
  801fc4:	50                   	push   %eax
  801fc5:	6a 00                	push   $0x0
  801fc7:	e8 3e ee ff ff       	call   800e0a <sys_page_unmap>
}
  801fcc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fcf:	c9                   	leave  
  801fd0:	c3                   	ret    

00801fd1 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801fd1:	55                   	push   %ebp
  801fd2:	89 e5                	mov    %esp,%ebp
  801fd4:	57                   	push   %edi
  801fd5:	56                   	push   %esi
  801fd6:	53                   	push   %ebx
  801fd7:	83 ec 1c             	sub    $0x1c,%esp
  801fda:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801fdd:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801fdf:	a1 20 44 80 00       	mov    0x804420,%eax
  801fe4:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801fe7:	83 ec 0c             	sub    $0xc,%esp
  801fea:	ff 75 e0             	pushl  -0x20(%ebp)
  801fed:	e8 3c 05 00 00       	call   80252e <pageref>
  801ff2:	89 c3                	mov    %eax,%ebx
  801ff4:	89 3c 24             	mov    %edi,(%esp)
  801ff7:	e8 32 05 00 00       	call   80252e <pageref>
  801ffc:	83 c4 10             	add    $0x10,%esp
  801fff:	39 c3                	cmp    %eax,%ebx
  802001:	0f 94 c1             	sete   %cl
  802004:	0f b6 c9             	movzbl %cl,%ecx
  802007:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80200a:	8b 15 20 44 80 00    	mov    0x804420,%edx
  802010:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802013:	39 ce                	cmp    %ecx,%esi
  802015:	74 1b                	je     802032 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802017:	39 c3                	cmp    %eax,%ebx
  802019:	75 c4                	jne    801fdf <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80201b:	8b 42 58             	mov    0x58(%edx),%eax
  80201e:	ff 75 e4             	pushl  -0x1c(%ebp)
  802021:	50                   	push   %eax
  802022:	56                   	push   %esi
  802023:	68 ff 2c 80 00       	push   $0x802cff
  802028:	e8 d0 e3 ff ff       	call   8003fd <cprintf>
  80202d:	83 c4 10             	add    $0x10,%esp
  802030:	eb ad                	jmp    801fdf <_pipeisclosed+0xe>
	}
}
  802032:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802035:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802038:	5b                   	pop    %ebx
  802039:	5e                   	pop    %esi
  80203a:	5f                   	pop    %edi
  80203b:	5d                   	pop    %ebp
  80203c:	c3                   	ret    

0080203d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80203d:	55                   	push   %ebp
  80203e:	89 e5                	mov    %esp,%ebp
  802040:	57                   	push   %edi
  802041:	56                   	push   %esi
  802042:	53                   	push   %ebx
  802043:	83 ec 28             	sub    $0x28,%esp
  802046:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802049:	56                   	push   %esi
  80204a:	e8 6f f1 ff ff       	call   8011be <fd2data>
  80204f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802051:	83 c4 10             	add    $0x10,%esp
  802054:	bf 00 00 00 00       	mov    $0x0,%edi
  802059:	eb 4b                	jmp    8020a6 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80205b:	89 da                	mov    %ebx,%edx
  80205d:	89 f0                	mov    %esi,%eax
  80205f:	e8 6d ff ff ff       	call   801fd1 <_pipeisclosed>
  802064:	85 c0                	test   %eax,%eax
  802066:	75 48                	jne    8020b0 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802068:	e8 f9 ec ff ff       	call   800d66 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80206d:	8b 43 04             	mov    0x4(%ebx),%eax
  802070:	8b 0b                	mov    (%ebx),%ecx
  802072:	8d 51 20             	lea    0x20(%ecx),%edx
  802075:	39 d0                	cmp    %edx,%eax
  802077:	73 e2                	jae    80205b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802079:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80207c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802080:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802083:	89 c2                	mov    %eax,%edx
  802085:	c1 fa 1f             	sar    $0x1f,%edx
  802088:	89 d1                	mov    %edx,%ecx
  80208a:	c1 e9 1b             	shr    $0x1b,%ecx
  80208d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802090:	83 e2 1f             	and    $0x1f,%edx
  802093:	29 ca                	sub    %ecx,%edx
  802095:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802099:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80209d:	83 c0 01             	add    $0x1,%eax
  8020a0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020a3:	83 c7 01             	add    $0x1,%edi
  8020a6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020a9:	75 c2                	jne    80206d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8020ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8020ae:	eb 05                	jmp    8020b5 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020b0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020b8:	5b                   	pop    %ebx
  8020b9:	5e                   	pop    %esi
  8020ba:	5f                   	pop    %edi
  8020bb:	5d                   	pop    %ebp
  8020bc:	c3                   	ret    

008020bd <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020bd:	55                   	push   %ebp
  8020be:	89 e5                	mov    %esp,%ebp
  8020c0:	57                   	push   %edi
  8020c1:	56                   	push   %esi
  8020c2:	53                   	push   %ebx
  8020c3:	83 ec 18             	sub    $0x18,%esp
  8020c6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020c9:	57                   	push   %edi
  8020ca:	e8 ef f0 ff ff       	call   8011be <fd2data>
  8020cf:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020d1:	83 c4 10             	add    $0x10,%esp
  8020d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020d9:	eb 3d                	jmp    802118 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020db:	85 db                	test   %ebx,%ebx
  8020dd:	74 04                	je     8020e3 <devpipe_read+0x26>
				return i;
  8020df:	89 d8                	mov    %ebx,%eax
  8020e1:	eb 44                	jmp    802127 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020e3:	89 f2                	mov    %esi,%edx
  8020e5:	89 f8                	mov    %edi,%eax
  8020e7:	e8 e5 fe ff ff       	call   801fd1 <_pipeisclosed>
  8020ec:	85 c0                	test   %eax,%eax
  8020ee:	75 32                	jne    802122 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020f0:	e8 71 ec ff ff       	call   800d66 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020f5:	8b 06                	mov    (%esi),%eax
  8020f7:	3b 46 04             	cmp    0x4(%esi),%eax
  8020fa:	74 df                	je     8020db <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020fc:	99                   	cltd   
  8020fd:	c1 ea 1b             	shr    $0x1b,%edx
  802100:	01 d0                	add    %edx,%eax
  802102:	83 e0 1f             	and    $0x1f,%eax
  802105:	29 d0                	sub    %edx,%eax
  802107:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80210c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80210f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802112:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802115:	83 c3 01             	add    $0x1,%ebx
  802118:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80211b:	75 d8                	jne    8020f5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80211d:	8b 45 10             	mov    0x10(%ebp),%eax
  802120:	eb 05                	jmp    802127 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802122:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802127:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80212a:	5b                   	pop    %ebx
  80212b:	5e                   	pop    %esi
  80212c:	5f                   	pop    %edi
  80212d:	5d                   	pop    %ebp
  80212e:	c3                   	ret    

0080212f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80212f:	55                   	push   %ebp
  802130:	89 e5                	mov    %esp,%ebp
  802132:	56                   	push   %esi
  802133:	53                   	push   %ebx
  802134:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802137:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80213a:	50                   	push   %eax
  80213b:	e8 95 f0 ff ff       	call   8011d5 <fd_alloc>
  802140:	83 c4 10             	add    $0x10,%esp
  802143:	89 c2                	mov    %eax,%edx
  802145:	85 c0                	test   %eax,%eax
  802147:	0f 88 2c 01 00 00    	js     802279 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80214d:	83 ec 04             	sub    $0x4,%esp
  802150:	68 07 04 00 00       	push   $0x407
  802155:	ff 75 f4             	pushl  -0xc(%ebp)
  802158:	6a 00                	push   $0x0
  80215a:	e8 26 ec ff ff       	call   800d85 <sys_page_alloc>
  80215f:	83 c4 10             	add    $0x10,%esp
  802162:	89 c2                	mov    %eax,%edx
  802164:	85 c0                	test   %eax,%eax
  802166:	0f 88 0d 01 00 00    	js     802279 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80216c:	83 ec 0c             	sub    $0xc,%esp
  80216f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802172:	50                   	push   %eax
  802173:	e8 5d f0 ff ff       	call   8011d5 <fd_alloc>
  802178:	89 c3                	mov    %eax,%ebx
  80217a:	83 c4 10             	add    $0x10,%esp
  80217d:	85 c0                	test   %eax,%eax
  80217f:	0f 88 e2 00 00 00    	js     802267 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802185:	83 ec 04             	sub    $0x4,%esp
  802188:	68 07 04 00 00       	push   $0x407
  80218d:	ff 75 f0             	pushl  -0x10(%ebp)
  802190:	6a 00                	push   $0x0
  802192:	e8 ee eb ff ff       	call   800d85 <sys_page_alloc>
  802197:	89 c3                	mov    %eax,%ebx
  802199:	83 c4 10             	add    $0x10,%esp
  80219c:	85 c0                	test   %eax,%eax
  80219e:	0f 88 c3 00 00 00    	js     802267 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021a4:	83 ec 0c             	sub    $0xc,%esp
  8021a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8021aa:	e8 0f f0 ff ff       	call   8011be <fd2data>
  8021af:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021b1:	83 c4 0c             	add    $0xc,%esp
  8021b4:	68 07 04 00 00       	push   $0x407
  8021b9:	50                   	push   %eax
  8021ba:	6a 00                	push   $0x0
  8021bc:	e8 c4 eb ff ff       	call   800d85 <sys_page_alloc>
  8021c1:	89 c3                	mov    %eax,%ebx
  8021c3:	83 c4 10             	add    $0x10,%esp
  8021c6:	85 c0                	test   %eax,%eax
  8021c8:	0f 88 89 00 00 00    	js     802257 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021ce:	83 ec 0c             	sub    $0xc,%esp
  8021d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8021d4:	e8 e5 ef ff ff       	call   8011be <fd2data>
  8021d9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021e0:	50                   	push   %eax
  8021e1:	6a 00                	push   $0x0
  8021e3:	56                   	push   %esi
  8021e4:	6a 00                	push   $0x0
  8021e6:	e8 dd eb ff ff       	call   800dc8 <sys_page_map>
  8021eb:	89 c3                	mov    %eax,%ebx
  8021ed:	83 c4 20             	add    $0x20,%esp
  8021f0:	85 c0                	test   %eax,%eax
  8021f2:	78 55                	js     802249 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021f4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021fd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802202:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802209:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80220f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802212:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802214:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802217:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80221e:	83 ec 0c             	sub    $0xc,%esp
  802221:	ff 75 f4             	pushl  -0xc(%ebp)
  802224:	e8 85 ef ff ff       	call   8011ae <fd2num>
  802229:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80222c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80222e:	83 c4 04             	add    $0x4,%esp
  802231:	ff 75 f0             	pushl  -0x10(%ebp)
  802234:	e8 75 ef ff ff       	call   8011ae <fd2num>
  802239:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80223c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80223f:	83 c4 10             	add    $0x10,%esp
  802242:	ba 00 00 00 00       	mov    $0x0,%edx
  802247:	eb 30                	jmp    802279 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802249:	83 ec 08             	sub    $0x8,%esp
  80224c:	56                   	push   %esi
  80224d:	6a 00                	push   $0x0
  80224f:	e8 b6 eb ff ff       	call   800e0a <sys_page_unmap>
  802254:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802257:	83 ec 08             	sub    $0x8,%esp
  80225a:	ff 75 f0             	pushl  -0x10(%ebp)
  80225d:	6a 00                	push   $0x0
  80225f:	e8 a6 eb ff ff       	call   800e0a <sys_page_unmap>
  802264:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802267:	83 ec 08             	sub    $0x8,%esp
  80226a:	ff 75 f4             	pushl  -0xc(%ebp)
  80226d:	6a 00                	push   $0x0
  80226f:	e8 96 eb ff ff       	call   800e0a <sys_page_unmap>
  802274:	83 c4 10             	add    $0x10,%esp
  802277:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802279:	89 d0                	mov    %edx,%eax
  80227b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80227e:	5b                   	pop    %ebx
  80227f:	5e                   	pop    %esi
  802280:	5d                   	pop    %ebp
  802281:	c3                   	ret    

00802282 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802282:	55                   	push   %ebp
  802283:	89 e5                	mov    %esp,%ebp
  802285:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802288:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80228b:	50                   	push   %eax
  80228c:	ff 75 08             	pushl  0x8(%ebp)
  80228f:	e8 90 ef ff ff       	call   801224 <fd_lookup>
  802294:	83 c4 10             	add    $0x10,%esp
  802297:	85 c0                	test   %eax,%eax
  802299:	78 18                	js     8022b3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80229b:	83 ec 0c             	sub    $0xc,%esp
  80229e:	ff 75 f4             	pushl  -0xc(%ebp)
  8022a1:	e8 18 ef ff ff       	call   8011be <fd2data>
	return _pipeisclosed(fd, p);
  8022a6:	89 c2                	mov    %eax,%edx
  8022a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ab:	e8 21 fd ff ff       	call   801fd1 <_pipeisclosed>
  8022b0:	83 c4 10             	add    $0x10,%esp
}
  8022b3:	c9                   	leave  
  8022b4:	c3                   	ret    

008022b5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022b5:	55                   	push   %ebp
  8022b6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8022bd:	5d                   	pop    %ebp
  8022be:	c3                   	ret    

008022bf <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022bf:	55                   	push   %ebp
  8022c0:	89 e5                	mov    %esp,%ebp
  8022c2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022c5:	68 17 2d 80 00       	push   $0x802d17
  8022ca:	ff 75 0c             	pushl  0xc(%ebp)
  8022cd:	e8 b0 e6 ff ff       	call   800982 <strcpy>
	return 0;
}
  8022d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8022d7:	c9                   	leave  
  8022d8:	c3                   	ret    

008022d9 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022d9:	55                   	push   %ebp
  8022da:	89 e5                	mov    %esp,%ebp
  8022dc:	57                   	push   %edi
  8022dd:	56                   	push   %esi
  8022de:	53                   	push   %ebx
  8022df:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022e5:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022ea:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022f0:	eb 2d                	jmp    80231f <devcons_write+0x46>
		m = n - tot;
  8022f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022f5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8022f7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022fa:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8022ff:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802302:	83 ec 04             	sub    $0x4,%esp
  802305:	53                   	push   %ebx
  802306:	03 45 0c             	add    0xc(%ebp),%eax
  802309:	50                   	push   %eax
  80230a:	57                   	push   %edi
  80230b:	e8 04 e8 ff ff       	call   800b14 <memmove>
		sys_cputs(buf, m);
  802310:	83 c4 08             	add    $0x8,%esp
  802313:	53                   	push   %ebx
  802314:	57                   	push   %edi
  802315:	e8 af e9 ff ff       	call   800cc9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80231a:	01 de                	add    %ebx,%esi
  80231c:	83 c4 10             	add    $0x10,%esp
  80231f:	89 f0                	mov    %esi,%eax
  802321:	3b 75 10             	cmp    0x10(%ebp),%esi
  802324:	72 cc                	jb     8022f2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802326:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802329:	5b                   	pop    %ebx
  80232a:	5e                   	pop    %esi
  80232b:	5f                   	pop    %edi
  80232c:	5d                   	pop    %ebp
  80232d:	c3                   	ret    

0080232e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80232e:	55                   	push   %ebp
  80232f:	89 e5                	mov    %esp,%ebp
  802331:	83 ec 08             	sub    $0x8,%esp
  802334:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802339:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80233d:	74 2a                	je     802369 <devcons_read+0x3b>
  80233f:	eb 05                	jmp    802346 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802341:	e8 20 ea ff ff       	call   800d66 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802346:	e8 9c e9 ff ff       	call   800ce7 <sys_cgetc>
  80234b:	85 c0                	test   %eax,%eax
  80234d:	74 f2                	je     802341 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80234f:	85 c0                	test   %eax,%eax
  802351:	78 16                	js     802369 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802353:	83 f8 04             	cmp    $0x4,%eax
  802356:	74 0c                	je     802364 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802358:	8b 55 0c             	mov    0xc(%ebp),%edx
  80235b:	88 02                	mov    %al,(%edx)
	return 1;
  80235d:	b8 01 00 00 00       	mov    $0x1,%eax
  802362:	eb 05                	jmp    802369 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802364:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802369:	c9                   	leave  
  80236a:	c3                   	ret    

0080236b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80236b:	55                   	push   %ebp
  80236c:	89 e5                	mov    %esp,%ebp
  80236e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802371:	8b 45 08             	mov    0x8(%ebp),%eax
  802374:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802377:	6a 01                	push   $0x1
  802379:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80237c:	50                   	push   %eax
  80237d:	e8 47 e9 ff ff       	call   800cc9 <sys_cputs>
}
  802382:	83 c4 10             	add    $0x10,%esp
  802385:	c9                   	leave  
  802386:	c3                   	ret    

00802387 <getchar>:

int
getchar(void)
{
  802387:	55                   	push   %ebp
  802388:	89 e5                	mov    %esp,%ebp
  80238a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80238d:	6a 01                	push   $0x1
  80238f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802392:	50                   	push   %eax
  802393:	6a 00                	push   $0x0
  802395:	e8 f0 f0 ff ff       	call   80148a <read>
	if (r < 0)
  80239a:	83 c4 10             	add    $0x10,%esp
  80239d:	85 c0                	test   %eax,%eax
  80239f:	78 0f                	js     8023b0 <getchar+0x29>
		return r;
	if (r < 1)
  8023a1:	85 c0                	test   %eax,%eax
  8023a3:	7e 06                	jle    8023ab <getchar+0x24>
		return -E_EOF;
	return c;
  8023a5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023a9:	eb 05                	jmp    8023b0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023ab:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023b0:	c9                   	leave  
  8023b1:	c3                   	ret    

008023b2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023b2:	55                   	push   %ebp
  8023b3:	89 e5                	mov    %esp,%ebp
  8023b5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023bb:	50                   	push   %eax
  8023bc:	ff 75 08             	pushl  0x8(%ebp)
  8023bf:	e8 60 ee ff ff       	call   801224 <fd_lookup>
  8023c4:	83 c4 10             	add    $0x10,%esp
  8023c7:	85 c0                	test   %eax,%eax
  8023c9:	78 11                	js     8023dc <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ce:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023d4:	39 10                	cmp    %edx,(%eax)
  8023d6:	0f 94 c0             	sete   %al
  8023d9:	0f b6 c0             	movzbl %al,%eax
}
  8023dc:	c9                   	leave  
  8023dd:	c3                   	ret    

008023de <opencons>:

int
opencons(void)
{
  8023de:	55                   	push   %ebp
  8023df:	89 e5                	mov    %esp,%ebp
  8023e1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023e7:	50                   	push   %eax
  8023e8:	e8 e8 ed ff ff       	call   8011d5 <fd_alloc>
  8023ed:	83 c4 10             	add    $0x10,%esp
		return r;
  8023f0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023f2:	85 c0                	test   %eax,%eax
  8023f4:	78 3e                	js     802434 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023f6:	83 ec 04             	sub    $0x4,%esp
  8023f9:	68 07 04 00 00       	push   $0x407
  8023fe:	ff 75 f4             	pushl  -0xc(%ebp)
  802401:	6a 00                	push   $0x0
  802403:	e8 7d e9 ff ff       	call   800d85 <sys_page_alloc>
  802408:	83 c4 10             	add    $0x10,%esp
		return r;
  80240b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80240d:	85 c0                	test   %eax,%eax
  80240f:	78 23                	js     802434 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802411:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802417:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80241a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80241c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80241f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802426:	83 ec 0c             	sub    $0xc,%esp
  802429:	50                   	push   %eax
  80242a:	e8 7f ed ff ff       	call   8011ae <fd2num>
  80242f:	89 c2                	mov    %eax,%edx
  802431:	83 c4 10             	add    $0x10,%esp
}
  802434:	89 d0                	mov    %edx,%eax
  802436:	c9                   	leave  
  802437:	c3                   	ret    

00802438 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802438:	55                   	push   %ebp
  802439:	89 e5                	mov    %esp,%ebp
  80243b:	56                   	push   %esi
  80243c:	53                   	push   %ebx
  80243d:	8b 75 08             	mov    0x8(%ebp),%esi
  802440:	8b 45 0c             	mov    0xc(%ebp),%eax
  802443:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  802446:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802448:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  80244d:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  802450:	83 ec 0c             	sub    $0xc,%esp
  802453:	50                   	push   %eax
  802454:	e8 dc ea ff ff       	call   800f35 <sys_ipc_recv>

	if (r < 0) {
  802459:	83 c4 10             	add    $0x10,%esp
  80245c:	85 c0                	test   %eax,%eax
  80245e:	79 16                	jns    802476 <ipc_recv+0x3e>
		if (from_env_store)
  802460:	85 f6                	test   %esi,%esi
  802462:	74 06                	je     80246a <ipc_recv+0x32>
			*from_env_store = 0;
  802464:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  80246a:	85 db                	test   %ebx,%ebx
  80246c:	74 2c                	je     80249a <ipc_recv+0x62>
			*perm_store = 0;
  80246e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802474:	eb 24                	jmp    80249a <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  802476:	85 f6                	test   %esi,%esi
  802478:	74 0a                	je     802484 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  80247a:	a1 20 44 80 00       	mov    0x804420,%eax
  80247f:	8b 40 74             	mov    0x74(%eax),%eax
  802482:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  802484:	85 db                	test   %ebx,%ebx
  802486:	74 0a                	je     802492 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  802488:	a1 20 44 80 00       	mov    0x804420,%eax
  80248d:	8b 40 78             	mov    0x78(%eax),%eax
  802490:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  802492:	a1 20 44 80 00       	mov    0x804420,%eax
  802497:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  80249a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80249d:	5b                   	pop    %ebx
  80249e:	5e                   	pop    %esi
  80249f:	5d                   	pop    %ebp
  8024a0:	c3                   	ret    

008024a1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024a1:	55                   	push   %ebp
  8024a2:	89 e5                	mov    %esp,%ebp
  8024a4:	57                   	push   %edi
  8024a5:	56                   	push   %esi
  8024a6:	53                   	push   %ebx
  8024a7:	83 ec 0c             	sub    $0xc,%esp
  8024aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024ad:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8024b3:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8024b5:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8024ba:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8024bd:	ff 75 14             	pushl  0x14(%ebp)
  8024c0:	53                   	push   %ebx
  8024c1:	56                   	push   %esi
  8024c2:	57                   	push   %edi
  8024c3:	e8 4a ea ff ff       	call   800f12 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  8024c8:	83 c4 10             	add    $0x10,%esp
  8024cb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024ce:	75 07                	jne    8024d7 <ipc_send+0x36>
			sys_yield();
  8024d0:	e8 91 e8 ff ff       	call   800d66 <sys_yield>
  8024d5:	eb e6                	jmp    8024bd <ipc_send+0x1c>
		} else if (r < 0) {
  8024d7:	85 c0                	test   %eax,%eax
  8024d9:	79 12                	jns    8024ed <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  8024db:	50                   	push   %eax
  8024dc:	68 23 2d 80 00       	push   $0x802d23
  8024e1:	6a 51                	push   $0x51
  8024e3:	68 30 2d 80 00       	push   $0x802d30
  8024e8:	e8 37 de ff ff       	call   800324 <_panic>
		}
	}
}
  8024ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024f0:	5b                   	pop    %ebx
  8024f1:	5e                   	pop    %esi
  8024f2:	5f                   	pop    %edi
  8024f3:	5d                   	pop    %ebp
  8024f4:	c3                   	ret    

008024f5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8024f5:	55                   	push   %ebp
  8024f6:	89 e5                	mov    %esp,%ebp
  8024f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8024fb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802500:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802503:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802509:	8b 52 50             	mov    0x50(%edx),%edx
  80250c:	39 ca                	cmp    %ecx,%edx
  80250e:	75 0d                	jne    80251d <ipc_find_env+0x28>
			return envs[i].env_id;
  802510:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802513:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802518:	8b 40 48             	mov    0x48(%eax),%eax
  80251b:	eb 0f                	jmp    80252c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80251d:	83 c0 01             	add    $0x1,%eax
  802520:	3d 00 04 00 00       	cmp    $0x400,%eax
  802525:	75 d9                	jne    802500 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802527:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80252c:	5d                   	pop    %ebp
  80252d:	c3                   	ret    

0080252e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80252e:	55                   	push   %ebp
  80252f:	89 e5                	mov    %esp,%ebp
  802531:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802534:	89 d0                	mov    %edx,%eax
  802536:	c1 e8 16             	shr    $0x16,%eax
  802539:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802540:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802545:	f6 c1 01             	test   $0x1,%cl
  802548:	74 1d                	je     802567 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80254a:	c1 ea 0c             	shr    $0xc,%edx
  80254d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802554:	f6 c2 01             	test   $0x1,%dl
  802557:	74 0e                	je     802567 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802559:	c1 ea 0c             	shr    $0xc,%edx
  80255c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802563:	ef 
  802564:	0f b7 c0             	movzwl %ax,%eax
}
  802567:	5d                   	pop    %ebp
  802568:	c3                   	ret    
  802569:	66 90                	xchg   %ax,%ax
  80256b:	66 90                	xchg   %ax,%ax
  80256d:	66 90                	xchg   %ax,%ax
  80256f:	90                   	nop

00802570 <__udivdi3>:
  802570:	55                   	push   %ebp
  802571:	57                   	push   %edi
  802572:	56                   	push   %esi
  802573:	53                   	push   %ebx
  802574:	83 ec 1c             	sub    $0x1c,%esp
  802577:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80257b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80257f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802583:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802587:	85 f6                	test   %esi,%esi
  802589:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80258d:	89 ca                	mov    %ecx,%edx
  80258f:	89 f8                	mov    %edi,%eax
  802591:	75 3d                	jne    8025d0 <__udivdi3+0x60>
  802593:	39 cf                	cmp    %ecx,%edi
  802595:	0f 87 c5 00 00 00    	ja     802660 <__udivdi3+0xf0>
  80259b:	85 ff                	test   %edi,%edi
  80259d:	89 fd                	mov    %edi,%ebp
  80259f:	75 0b                	jne    8025ac <__udivdi3+0x3c>
  8025a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025a6:	31 d2                	xor    %edx,%edx
  8025a8:	f7 f7                	div    %edi
  8025aa:	89 c5                	mov    %eax,%ebp
  8025ac:	89 c8                	mov    %ecx,%eax
  8025ae:	31 d2                	xor    %edx,%edx
  8025b0:	f7 f5                	div    %ebp
  8025b2:	89 c1                	mov    %eax,%ecx
  8025b4:	89 d8                	mov    %ebx,%eax
  8025b6:	89 cf                	mov    %ecx,%edi
  8025b8:	f7 f5                	div    %ebp
  8025ba:	89 c3                	mov    %eax,%ebx
  8025bc:	89 d8                	mov    %ebx,%eax
  8025be:	89 fa                	mov    %edi,%edx
  8025c0:	83 c4 1c             	add    $0x1c,%esp
  8025c3:	5b                   	pop    %ebx
  8025c4:	5e                   	pop    %esi
  8025c5:	5f                   	pop    %edi
  8025c6:	5d                   	pop    %ebp
  8025c7:	c3                   	ret    
  8025c8:	90                   	nop
  8025c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025d0:	39 ce                	cmp    %ecx,%esi
  8025d2:	77 74                	ja     802648 <__udivdi3+0xd8>
  8025d4:	0f bd fe             	bsr    %esi,%edi
  8025d7:	83 f7 1f             	xor    $0x1f,%edi
  8025da:	0f 84 98 00 00 00    	je     802678 <__udivdi3+0x108>
  8025e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8025e5:	89 f9                	mov    %edi,%ecx
  8025e7:	89 c5                	mov    %eax,%ebp
  8025e9:	29 fb                	sub    %edi,%ebx
  8025eb:	d3 e6                	shl    %cl,%esi
  8025ed:	89 d9                	mov    %ebx,%ecx
  8025ef:	d3 ed                	shr    %cl,%ebp
  8025f1:	89 f9                	mov    %edi,%ecx
  8025f3:	d3 e0                	shl    %cl,%eax
  8025f5:	09 ee                	or     %ebp,%esi
  8025f7:	89 d9                	mov    %ebx,%ecx
  8025f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025fd:	89 d5                	mov    %edx,%ebp
  8025ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802603:	d3 ed                	shr    %cl,%ebp
  802605:	89 f9                	mov    %edi,%ecx
  802607:	d3 e2                	shl    %cl,%edx
  802609:	89 d9                	mov    %ebx,%ecx
  80260b:	d3 e8                	shr    %cl,%eax
  80260d:	09 c2                	or     %eax,%edx
  80260f:	89 d0                	mov    %edx,%eax
  802611:	89 ea                	mov    %ebp,%edx
  802613:	f7 f6                	div    %esi
  802615:	89 d5                	mov    %edx,%ebp
  802617:	89 c3                	mov    %eax,%ebx
  802619:	f7 64 24 0c          	mull   0xc(%esp)
  80261d:	39 d5                	cmp    %edx,%ebp
  80261f:	72 10                	jb     802631 <__udivdi3+0xc1>
  802621:	8b 74 24 08          	mov    0x8(%esp),%esi
  802625:	89 f9                	mov    %edi,%ecx
  802627:	d3 e6                	shl    %cl,%esi
  802629:	39 c6                	cmp    %eax,%esi
  80262b:	73 07                	jae    802634 <__udivdi3+0xc4>
  80262d:	39 d5                	cmp    %edx,%ebp
  80262f:	75 03                	jne    802634 <__udivdi3+0xc4>
  802631:	83 eb 01             	sub    $0x1,%ebx
  802634:	31 ff                	xor    %edi,%edi
  802636:	89 d8                	mov    %ebx,%eax
  802638:	89 fa                	mov    %edi,%edx
  80263a:	83 c4 1c             	add    $0x1c,%esp
  80263d:	5b                   	pop    %ebx
  80263e:	5e                   	pop    %esi
  80263f:	5f                   	pop    %edi
  802640:	5d                   	pop    %ebp
  802641:	c3                   	ret    
  802642:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802648:	31 ff                	xor    %edi,%edi
  80264a:	31 db                	xor    %ebx,%ebx
  80264c:	89 d8                	mov    %ebx,%eax
  80264e:	89 fa                	mov    %edi,%edx
  802650:	83 c4 1c             	add    $0x1c,%esp
  802653:	5b                   	pop    %ebx
  802654:	5e                   	pop    %esi
  802655:	5f                   	pop    %edi
  802656:	5d                   	pop    %ebp
  802657:	c3                   	ret    
  802658:	90                   	nop
  802659:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802660:	89 d8                	mov    %ebx,%eax
  802662:	f7 f7                	div    %edi
  802664:	31 ff                	xor    %edi,%edi
  802666:	89 c3                	mov    %eax,%ebx
  802668:	89 d8                	mov    %ebx,%eax
  80266a:	89 fa                	mov    %edi,%edx
  80266c:	83 c4 1c             	add    $0x1c,%esp
  80266f:	5b                   	pop    %ebx
  802670:	5e                   	pop    %esi
  802671:	5f                   	pop    %edi
  802672:	5d                   	pop    %ebp
  802673:	c3                   	ret    
  802674:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802678:	39 ce                	cmp    %ecx,%esi
  80267a:	72 0c                	jb     802688 <__udivdi3+0x118>
  80267c:	31 db                	xor    %ebx,%ebx
  80267e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802682:	0f 87 34 ff ff ff    	ja     8025bc <__udivdi3+0x4c>
  802688:	bb 01 00 00 00       	mov    $0x1,%ebx
  80268d:	e9 2a ff ff ff       	jmp    8025bc <__udivdi3+0x4c>
  802692:	66 90                	xchg   %ax,%ax
  802694:	66 90                	xchg   %ax,%ax
  802696:	66 90                	xchg   %ax,%ax
  802698:	66 90                	xchg   %ax,%ax
  80269a:	66 90                	xchg   %ax,%ax
  80269c:	66 90                	xchg   %ax,%ax
  80269e:	66 90                	xchg   %ax,%ax

008026a0 <__umoddi3>:
  8026a0:	55                   	push   %ebp
  8026a1:	57                   	push   %edi
  8026a2:	56                   	push   %esi
  8026a3:	53                   	push   %ebx
  8026a4:	83 ec 1c             	sub    $0x1c,%esp
  8026a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8026b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026b7:	85 d2                	test   %edx,%edx
  8026b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026c1:	89 f3                	mov    %esi,%ebx
  8026c3:	89 3c 24             	mov    %edi,(%esp)
  8026c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026ca:	75 1c                	jne    8026e8 <__umoddi3+0x48>
  8026cc:	39 f7                	cmp    %esi,%edi
  8026ce:	76 50                	jbe    802720 <__umoddi3+0x80>
  8026d0:	89 c8                	mov    %ecx,%eax
  8026d2:	89 f2                	mov    %esi,%edx
  8026d4:	f7 f7                	div    %edi
  8026d6:	89 d0                	mov    %edx,%eax
  8026d8:	31 d2                	xor    %edx,%edx
  8026da:	83 c4 1c             	add    $0x1c,%esp
  8026dd:	5b                   	pop    %ebx
  8026de:	5e                   	pop    %esi
  8026df:	5f                   	pop    %edi
  8026e0:	5d                   	pop    %ebp
  8026e1:	c3                   	ret    
  8026e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026e8:	39 f2                	cmp    %esi,%edx
  8026ea:	89 d0                	mov    %edx,%eax
  8026ec:	77 52                	ja     802740 <__umoddi3+0xa0>
  8026ee:	0f bd ea             	bsr    %edx,%ebp
  8026f1:	83 f5 1f             	xor    $0x1f,%ebp
  8026f4:	75 5a                	jne    802750 <__umoddi3+0xb0>
  8026f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8026fa:	0f 82 e0 00 00 00    	jb     8027e0 <__umoddi3+0x140>
  802700:	39 0c 24             	cmp    %ecx,(%esp)
  802703:	0f 86 d7 00 00 00    	jbe    8027e0 <__umoddi3+0x140>
  802709:	8b 44 24 08          	mov    0x8(%esp),%eax
  80270d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802711:	83 c4 1c             	add    $0x1c,%esp
  802714:	5b                   	pop    %ebx
  802715:	5e                   	pop    %esi
  802716:	5f                   	pop    %edi
  802717:	5d                   	pop    %ebp
  802718:	c3                   	ret    
  802719:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802720:	85 ff                	test   %edi,%edi
  802722:	89 fd                	mov    %edi,%ebp
  802724:	75 0b                	jne    802731 <__umoddi3+0x91>
  802726:	b8 01 00 00 00       	mov    $0x1,%eax
  80272b:	31 d2                	xor    %edx,%edx
  80272d:	f7 f7                	div    %edi
  80272f:	89 c5                	mov    %eax,%ebp
  802731:	89 f0                	mov    %esi,%eax
  802733:	31 d2                	xor    %edx,%edx
  802735:	f7 f5                	div    %ebp
  802737:	89 c8                	mov    %ecx,%eax
  802739:	f7 f5                	div    %ebp
  80273b:	89 d0                	mov    %edx,%eax
  80273d:	eb 99                	jmp    8026d8 <__umoddi3+0x38>
  80273f:	90                   	nop
  802740:	89 c8                	mov    %ecx,%eax
  802742:	89 f2                	mov    %esi,%edx
  802744:	83 c4 1c             	add    $0x1c,%esp
  802747:	5b                   	pop    %ebx
  802748:	5e                   	pop    %esi
  802749:	5f                   	pop    %edi
  80274a:	5d                   	pop    %ebp
  80274b:	c3                   	ret    
  80274c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802750:	8b 34 24             	mov    (%esp),%esi
  802753:	bf 20 00 00 00       	mov    $0x20,%edi
  802758:	89 e9                	mov    %ebp,%ecx
  80275a:	29 ef                	sub    %ebp,%edi
  80275c:	d3 e0                	shl    %cl,%eax
  80275e:	89 f9                	mov    %edi,%ecx
  802760:	89 f2                	mov    %esi,%edx
  802762:	d3 ea                	shr    %cl,%edx
  802764:	89 e9                	mov    %ebp,%ecx
  802766:	09 c2                	or     %eax,%edx
  802768:	89 d8                	mov    %ebx,%eax
  80276a:	89 14 24             	mov    %edx,(%esp)
  80276d:	89 f2                	mov    %esi,%edx
  80276f:	d3 e2                	shl    %cl,%edx
  802771:	89 f9                	mov    %edi,%ecx
  802773:	89 54 24 04          	mov    %edx,0x4(%esp)
  802777:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80277b:	d3 e8                	shr    %cl,%eax
  80277d:	89 e9                	mov    %ebp,%ecx
  80277f:	89 c6                	mov    %eax,%esi
  802781:	d3 e3                	shl    %cl,%ebx
  802783:	89 f9                	mov    %edi,%ecx
  802785:	89 d0                	mov    %edx,%eax
  802787:	d3 e8                	shr    %cl,%eax
  802789:	89 e9                	mov    %ebp,%ecx
  80278b:	09 d8                	or     %ebx,%eax
  80278d:	89 d3                	mov    %edx,%ebx
  80278f:	89 f2                	mov    %esi,%edx
  802791:	f7 34 24             	divl   (%esp)
  802794:	89 d6                	mov    %edx,%esi
  802796:	d3 e3                	shl    %cl,%ebx
  802798:	f7 64 24 04          	mull   0x4(%esp)
  80279c:	39 d6                	cmp    %edx,%esi
  80279e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027a2:	89 d1                	mov    %edx,%ecx
  8027a4:	89 c3                	mov    %eax,%ebx
  8027a6:	72 08                	jb     8027b0 <__umoddi3+0x110>
  8027a8:	75 11                	jne    8027bb <__umoddi3+0x11b>
  8027aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8027ae:	73 0b                	jae    8027bb <__umoddi3+0x11b>
  8027b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8027b4:	1b 14 24             	sbb    (%esp),%edx
  8027b7:	89 d1                	mov    %edx,%ecx
  8027b9:	89 c3                	mov    %eax,%ebx
  8027bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8027bf:	29 da                	sub    %ebx,%edx
  8027c1:	19 ce                	sbb    %ecx,%esi
  8027c3:	89 f9                	mov    %edi,%ecx
  8027c5:	89 f0                	mov    %esi,%eax
  8027c7:	d3 e0                	shl    %cl,%eax
  8027c9:	89 e9                	mov    %ebp,%ecx
  8027cb:	d3 ea                	shr    %cl,%edx
  8027cd:	89 e9                	mov    %ebp,%ecx
  8027cf:	d3 ee                	shr    %cl,%esi
  8027d1:	09 d0                	or     %edx,%eax
  8027d3:	89 f2                	mov    %esi,%edx
  8027d5:	83 c4 1c             	add    $0x1c,%esp
  8027d8:	5b                   	pop    %ebx
  8027d9:	5e                   	pop    %esi
  8027da:	5f                   	pop    %edi
  8027db:	5d                   	pop    %ebp
  8027dc:	c3                   	ret    
  8027dd:	8d 76 00             	lea    0x0(%esi),%esi
  8027e0:	29 f9                	sub    %edi,%ecx
  8027e2:	19 d6                	sbb    %edx,%esi
  8027e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027ec:	e9 18 ff ff ff       	jmp    802709 <__umoddi3+0x69>
