
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 f7 05 00 00       	call   800628 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 60 80 00       	push   $0x806000
  800042:	e8 9f 0c 00 00       	call   800ce6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 64 80 00    	mov    %ebx,0x806400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 22 14 00 00       	call   80147b <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 60 80 00       	push   $0x806000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 bf 13 00 00       	call   801427 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 45 13 00 00       	call   8013be <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008a:	ba 00 00 00 00       	mov    $0x0,%edx
  80008f:	b8 00 29 80 00       	mov    $0x802900,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009c:	74 1b                	je     8000b9 <umain+0x3b>
  80009e:	89 c2                	mov    %eax,%edx
  8000a0:	c1 ea 1f             	shr    $0x1f,%edx
  8000a3:	84 d2                	test   %dl,%dl
  8000a5:	74 12                	je     8000b9 <umain+0x3b>
		panic("serve_open /not-found: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 0b 29 80 00       	push   $0x80290b
  8000ad:	6a 20                	push   $0x20
  8000af:	68 25 29 80 00       	push   $0x802925
  8000b4:	e8 cf 05 00 00       	call   800688 <_panic>
	else if (r >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 14                	js     8000d1 <umain+0x53>
		panic("serve_open /not-found succeeded!");
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	68 c0 2a 80 00       	push   $0x802ac0
  8000c5:	6a 22                	push   $0x22
  8000c7:	68 25 29 80 00       	push   $0x802925
  8000cc:	e8 b7 05 00 00       	call   800688 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 35 29 80 00       	mov    $0x802935,%eax
  8000db:	e8 53 ff ff ff       	call   800033 <xopen>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	79 12                	jns    8000f6 <umain+0x78>
		panic("serve_open /newmotd: %e", r);
  8000e4:	50                   	push   %eax
  8000e5:	68 3e 29 80 00       	push   $0x80293e
  8000ea:	6a 25                	push   $0x25
  8000ec:	68 25 29 80 00       	push   $0x802925
  8000f1:	e8 92 05 00 00       	call   800688 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000f6:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000fd:	75 12                	jne    800111 <umain+0x93>
  8000ff:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800106:	75 09                	jne    800111 <umain+0x93>
  800108:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80010f:	74 14                	je     800125 <umain+0xa7>
		panic("serve_open did not fill struct Fd correctly\n");
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	68 e4 2a 80 00       	push   $0x802ae4
  800119:	6a 27                	push   $0x27
  80011b:	68 25 29 80 00       	push   $0x802925
  800120:	e8 63 05 00 00       	call   800688 <_panic>
	cprintf("serve_open is good\n");
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	68 56 29 80 00       	push   $0x802956
  80012d:	e8 2f 06 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800132:	83 c4 08             	add    $0x8,%esp
  800135:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	68 00 c0 cc cc       	push   $0xccccc000
  800141:	ff 15 1c 40 80 00    	call   *0x80401c
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0xe2>
		panic("file_stat: %e", r);
  80014e:	50                   	push   %eax
  80014f:	68 6a 29 80 00       	push   $0x80296a
  800154:	6a 2b                	push   $0x2b
  800156:	68 25 29 80 00       	push   $0x802925
  80015b:	e8 28 05 00 00       	call   800688 <_panic>
	if (strlen(msg) != st.st_size)
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 35 00 40 80 00    	pushl  0x804000
  800169:	e8 3f 0b 00 00       	call   800cad <strlen>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800174:	74 25                	je     80019b <umain+0x11d>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	ff 35 00 40 80 00    	pushl  0x804000
  80017f:	e8 29 0b 00 00       	call   800cad <strlen>
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	ff 75 cc             	pushl  -0x34(%ebp)
  80018a:	68 14 2b 80 00       	push   $0x802b14
  80018f:	6a 2d                	push   $0x2d
  800191:	68 25 29 80 00       	push   $0x802925
  800196:	e8 ed 04 00 00       	call   800688 <_panic>
	cprintf("file_stat is good\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 78 29 80 00       	push   $0x802978
  8001a3:	e8 b9 05 00 00       	call   800761 <cprintf>

	memset(buf, 0, sizeof buf);
  8001a8:	83 c4 0c             	add    $0xc,%esp
  8001ab:	68 00 02 00 00       	push   $0x200
  8001b0:	6a 00                	push   $0x0
  8001b2:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8001b8:	53                   	push   %ebx
  8001b9:	e8 6d 0c 00 00       	call   800e2b <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8001be:	83 c4 0c             	add    $0xc,%esp
  8001c1:	68 00 02 00 00       	push   $0x200
  8001c6:	53                   	push   %ebx
  8001c7:	68 00 c0 cc cc       	push   $0xccccc000
  8001cc:	ff 15 10 40 80 00    	call   *0x804010
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	79 12                	jns    8001eb <umain+0x16d>
		panic("file_read: %e", r);
  8001d9:	50                   	push   %eax
  8001da:	68 8b 29 80 00       	push   $0x80298b
  8001df:	6a 32                	push   $0x32
  8001e1:	68 25 29 80 00       	push   $0x802925
  8001e6:	e8 9d 04 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	ff 35 00 40 80 00    	pushl  0x804000
  8001f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 90 0b 00 00       	call   800d90 <strcmp>
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	85 c0                	test   %eax,%eax
  800205:	74 14                	je     80021b <umain+0x19d>
		panic("file_read returned wrong data");
  800207:	83 ec 04             	sub    $0x4,%esp
  80020a:	68 99 29 80 00       	push   $0x802999
  80020f:	6a 34                	push   $0x34
  800211:	68 25 29 80 00       	push   $0x802925
  800216:	e8 6d 04 00 00       	call   800688 <_panic>
	cprintf("file_read is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 b7 29 80 00       	push   $0x8029b7
  800223:	e8 39 05 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800228:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022f:	ff 15 18 40 80 00    	call   *0x804018
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x1d0>
		panic("file_close: %e", r);
  80023c:	50                   	push   %eax
  80023d:	68 ca 29 80 00       	push   $0x8029ca
  800242:	6a 38                	push   $0x38
  800244:	68 25 29 80 00       	push   $0x802925
  800249:	e8 3a 04 00 00       	call   800688 <_panic>
	cprintf("file_close is good\n");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 d9 29 80 00       	push   $0x8029d9
  800256:	e8 06 05 00 00       	call   800761 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  80025b:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  800260:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800263:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  800268:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80026b:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  800270:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800273:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  800278:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  80027b:	83 c4 08             	add    $0x8,%esp
  80027e:	68 00 c0 cc cc       	push   $0xccccc000
  800283:	6a 00                	push   $0x0
  800285:	e8 e4 0e 00 00       	call   80116e <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80028a:	83 c4 0c             	add    $0xc,%esp
  80028d:	68 00 02 00 00       	push   $0x200
  800292:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800298:	50                   	push   %eax
  800299:	8d 45 d8             	lea    -0x28(%ebp),%eax
  80029c:	50                   	push   %eax
  80029d:	ff 15 10 40 80 00    	call   *0x804010
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8002a9:	74 12                	je     8002bd <umain+0x23f>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  8002ab:	50                   	push   %eax
  8002ac:	68 3c 2b 80 00       	push   $0x802b3c
  8002b1:	6a 43                	push   $0x43
  8002b3:	68 25 29 80 00       	push   $0x802925
  8002b8:	e8 cb 03 00 00       	call   800688 <_panic>
	cprintf("stale fileid is good\n");
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	68 ed 29 80 00       	push   $0x8029ed
  8002c5:	e8 97 04 00 00       	call   800761 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002ca:	ba 02 01 00 00       	mov    $0x102,%edx
  8002cf:	b8 03 2a 80 00       	mov    $0x802a03,%eax
  8002d4:	e8 5a fd ff ff       	call   800033 <xopen>
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	79 12                	jns    8002f2 <umain+0x274>
		panic("serve_open /new-file: %e", r);
  8002e0:	50                   	push   %eax
  8002e1:	68 0d 2a 80 00       	push   $0x802a0d
  8002e6:	6a 48                	push   $0x48
  8002e8:	68 25 29 80 00       	push   $0x802925
  8002ed:	e8 96 03 00 00       	call   800688 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002f2:	8b 1d 14 40 80 00    	mov    0x804014,%ebx
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	ff 35 00 40 80 00    	pushl  0x804000
  800301:	e8 a7 09 00 00       	call   800cad <strlen>
  800306:	83 c4 0c             	add    $0xc,%esp
  800309:	50                   	push   %eax
  80030a:	ff 35 00 40 80 00    	pushl  0x804000
  800310:	68 00 c0 cc cc       	push   $0xccccc000
  800315:	ff d3                	call   *%ebx
  800317:	89 c3                	mov    %eax,%ebx
  800319:	83 c4 04             	add    $0x4,%esp
  80031c:	ff 35 00 40 80 00    	pushl  0x804000
  800322:	e8 86 09 00 00       	call   800cad <strlen>
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	39 c3                	cmp    %eax,%ebx
  80032c:	74 12                	je     800340 <umain+0x2c2>
		panic("file_write: %e", r);
  80032e:	53                   	push   %ebx
  80032f:	68 26 2a 80 00       	push   $0x802a26
  800334:	6a 4b                	push   $0x4b
  800336:	68 25 29 80 00       	push   $0x802925
  80033b:	e8 48 03 00 00       	call   800688 <_panic>
	cprintf("file_write is good\n");
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	68 35 2a 80 00       	push   $0x802a35
  800348:	e8 14 04 00 00       	call   800761 <cprintf>

	FVA->fd_offset = 0;
  80034d:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800354:	00 00 00 
	memset(buf, 0, sizeof buf);
  800357:	83 c4 0c             	add    $0xc,%esp
  80035a:	68 00 02 00 00       	push   $0x200
  80035f:	6a 00                	push   $0x0
  800361:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800367:	53                   	push   %ebx
  800368:	e8 be 0a 00 00       	call   800e2b <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80036d:	83 c4 0c             	add    $0xc,%esp
  800370:	68 00 02 00 00       	push   $0x200
  800375:	53                   	push   %ebx
  800376:	68 00 c0 cc cc       	push   $0xccccc000
  80037b:	ff 15 10 40 80 00    	call   *0x804010
  800381:	89 c3                	mov    %eax,%ebx
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	85 c0                	test   %eax,%eax
  800388:	79 12                	jns    80039c <umain+0x31e>
		panic("file_read after file_write: %e", r);
  80038a:	50                   	push   %eax
  80038b:	68 74 2b 80 00       	push   $0x802b74
  800390:	6a 51                	push   $0x51
  800392:	68 25 29 80 00       	push   $0x802925
  800397:	e8 ec 02 00 00       	call   800688 <_panic>
	if (r != strlen(msg))
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	ff 35 00 40 80 00    	pushl  0x804000
  8003a5:	e8 03 09 00 00       	call   800cad <strlen>
  8003aa:	83 c4 10             	add    $0x10,%esp
  8003ad:	39 c3                	cmp    %eax,%ebx
  8003af:	74 12                	je     8003c3 <umain+0x345>
		panic("file_read after file_write returned wrong length: %d", r);
  8003b1:	53                   	push   %ebx
  8003b2:	68 94 2b 80 00       	push   $0x802b94
  8003b7:	6a 53                	push   $0x53
  8003b9:	68 25 29 80 00       	push   $0x802925
  8003be:	e8 c5 02 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	ff 35 00 40 80 00    	pushl  0x804000
  8003cc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003d2:	50                   	push   %eax
  8003d3:	e8 b8 09 00 00       	call   800d90 <strcmp>
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	74 14                	je     8003f3 <umain+0x375>
		panic("file_read after file_write returned wrong data");
  8003df:	83 ec 04             	sub    $0x4,%esp
  8003e2:	68 cc 2b 80 00       	push   $0x802bcc
  8003e7:	6a 55                	push   $0x55
  8003e9:	68 25 29 80 00       	push   $0x802925
  8003ee:	e8 95 02 00 00       	call   800688 <_panic>
	cprintf("file_read after file_write is good\n");
  8003f3:	83 ec 0c             	sub    $0xc,%esp
  8003f6:	68 fc 2b 80 00       	push   $0x802bfc
  8003fb:	e8 61 03 00 00       	call   800761 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	6a 00                	push   $0x0
  800405:	68 00 29 80 00       	push   $0x802900
  80040a:	e8 35 18 00 00       	call   801c44 <open>
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800415:	74 1b                	je     800432 <umain+0x3b4>
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 ea 1f             	shr    $0x1f,%edx
  80041c:	84 d2                	test   %dl,%dl
  80041e:	74 12                	je     800432 <umain+0x3b4>
		panic("open /not-found: %e", r);
  800420:	50                   	push   %eax
  800421:	68 11 29 80 00       	push   $0x802911
  800426:	6a 5a                	push   $0x5a
  800428:	68 25 29 80 00       	push   $0x802925
  80042d:	e8 56 02 00 00       	call   800688 <_panic>
	else if (r >= 0)
  800432:	85 c0                	test   %eax,%eax
  800434:	78 14                	js     80044a <umain+0x3cc>
		panic("open /not-found succeeded!");
  800436:	83 ec 04             	sub    $0x4,%esp
  800439:	68 49 2a 80 00       	push   $0x802a49
  80043e:	6a 5c                	push   $0x5c
  800440:	68 25 29 80 00       	push   $0x802925
  800445:	e8 3e 02 00 00       	call   800688 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 00                	push   $0x0
  80044f:	68 35 29 80 00       	push   $0x802935
  800454:	e8 eb 17 00 00       	call   801c44 <open>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	79 12                	jns    800472 <umain+0x3f4>
		panic("open /newmotd: %e", r);
  800460:	50                   	push   %eax
  800461:	68 44 29 80 00       	push   $0x802944
  800466:	6a 5f                	push   $0x5f
  800468:	68 25 29 80 00       	push   $0x802925
  80046d:	e8 16 02 00 00       	call   800688 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800472:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800475:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  80047c:	75 12                	jne    800490 <umain+0x412>
  80047e:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  800485:	75 09                	jne    800490 <umain+0x412>
  800487:	83 b8 08 00 00 d0 00 	cmpl   $0x0,-0x2ffffff8(%eax)
  80048e:	74 14                	je     8004a4 <umain+0x426>
		panic("open did not fill struct Fd correctly\n");
  800490:	83 ec 04             	sub    $0x4,%esp
  800493:	68 20 2c 80 00       	push   $0x802c20
  800498:	6a 62                	push   $0x62
  80049a:	68 25 29 80 00       	push   $0x802925
  80049f:	e8 e4 01 00 00       	call   800688 <_panic>
	cprintf("open is good\n");
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	68 5c 29 80 00       	push   $0x80295c
  8004ac:	e8 b0 02 00 00       	call   800761 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004b1:	83 c4 08             	add    $0x8,%esp
  8004b4:	68 01 01 00 00       	push   $0x101
  8004b9:	68 64 2a 80 00       	push   $0x802a64
  8004be:	e8 81 17 00 00       	call   801c44 <open>
  8004c3:	89 c6                	mov    %eax,%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 12                	jns    8004de <umain+0x460>
		panic("creat /big: %e", f);
  8004cc:	50                   	push   %eax
  8004cd:	68 69 2a 80 00       	push   $0x802a69
  8004d2:	6a 67                	push   $0x67
  8004d4:	68 25 29 80 00       	push   $0x802925
  8004d9:	e8 aa 01 00 00       	call   800688 <_panic>
	memset(buf, 0, sizeof(buf));
  8004de:	83 ec 04             	sub    $0x4,%esp
  8004e1:	68 00 02 00 00       	push   $0x200
  8004e6:	6a 00                	push   $0x0
  8004e8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	e8 37 09 00 00       	call   800e2b <memset>
  8004f4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8004f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8004fc:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800502:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800508:	83 ec 04             	sub    $0x4,%esp
  80050b:	68 00 02 00 00       	push   $0x200
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	e8 53 13 00 00       	call   80186a <write>
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	79 16                	jns    800534 <umain+0x4b6>
			panic("write /big@%d: %e", i, r);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	50                   	push   %eax
  800522:	53                   	push   %ebx
  800523:	68 78 2a 80 00       	push   $0x802a78
  800528:	6a 6c                	push   $0x6c
  80052a:	68 25 29 80 00       	push   $0x802925
  80052f:	e8 54 01 00 00       	call   800688 <_panic>
  800534:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  80053a:	89 c3                	mov    %eax,%ebx

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80053c:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800541:	75 bf                	jne    800502 <umain+0x484>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800543:	83 ec 0c             	sub    $0xc,%esp
  800546:	56                   	push   %esi
  800547:	e8 08 11 00 00       	call   801654 <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	6a 00                	push   $0x0
  800551:	68 64 2a 80 00       	push   $0x802a64
  800556:	e8 e9 16 00 00       	call   801c44 <open>
  80055b:	89 c6                	mov    %eax,%esi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	79 12                	jns    800576 <umain+0x4f8>
		panic("open /big: %e", f);
  800564:	50                   	push   %eax
  800565:	68 8a 2a 80 00       	push   $0x802a8a
  80056a:	6a 71                	push   $0x71
  80056c:	68 25 29 80 00       	push   $0x802925
  800571:	e8 12 01 00 00       	call   800688 <_panic>
  800576:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  80057b:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800581:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800587:	83 ec 04             	sub    $0x4,%esp
  80058a:	68 00 02 00 00       	push   $0x200
  80058f:	57                   	push   %edi
  800590:	56                   	push   %esi
  800591:	e8 8b 12 00 00       	call   801821 <readn>
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	79 16                	jns    8005b3 <umain+0x535>
			panic("read /big@%d: %e", i, r);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	50                   	push   %eax
  8005a1:	53                   	push   %ebx
  8005a2:	68 98 2a 80 00       	push   $0x802a98
  8005a7:	6a 75                	push   $0x75
  8005a9:	68 25 29 80 00       	push   $0x802925
  8005ae:	e8 d5 00 00 00       	call   800688 <_panic>
		if (r != sizeof(buf))
  8005b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005b8:	74 1b                	je     8005d5 <umain+0x557>
			panic("read /big from %d returned %d < %d bytes",
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	68 00 02 00 00       	push   $0x200
  8005c2:	50                   	push   %eax
  8005c3:	53                   	push   %ebx
  8005c4:	68 48 2c 80 00       	push   $0x802c48
  8005c9:	6a 78                	push   $0x78
  8005cb:	68 25 29 80 00       	push   $0x802925
  8005d0:	e8 b3 00 00 00       	call   800688 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005d5:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  8005db:	39 d8                	cmp    %ebx,%eax
  8005dd:	74 16                	je     8005f5 <umain+0x577>
			panic("read /big from %d returned bad data %d",
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	50                   	push   %eax
  8005e3:	53                   	push   %ebx
  8005e4:	68 74 2c 80 00       	push   $0x802c74
  8005e9:	6a 7b                	push   $0x7b
  8005eb:	68 25 29 80 00       	push   $0x802925
  8005f0:	e8 93 00 00 00       	call   800688 <_panic>
  8005f5:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  8005fb:	89 c3                	mov    %eax,%ebx
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005fd:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800602:	0f 85 79 ff ff ff    	jne    800581 <umain+0x503>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800608:	83 ec 0c             	sub    $0xc,%esp
  80060b:	56                   	push   %esi
  80060c:	e8 43 10 00 00       	call   801654 <close>
	cprintf("large file is good\n");
  800611:	c7 04 24 a9 2a 80 00 	movl   $0x802aa9,(%esp)
  800618:	e8 44 01 00 00       	call   800761 <cprintf>
}
  80061d:	83 c4 10             	add    $0x10,%esp
  800620:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800623:	5b                   	pop    %ebx
  800624:	5e                   	pop    %esi
  800625:	5f                   	pop    %edi
  800626:	5d                   	pop    %ebp
  800627:	c3                   	ret    

00800628 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800628:	55                   	push   %ebp
  800629:	89 e5                	mov    %esp,%ebp
  80062b:	56                   	push   %esi
  80062c:	53                   	push   %ebx
  80062d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800630:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800633:	e8 73 0a 00 00       	call   8010ab <sys_getenvid>
  800638:	25 ff 03 00 00       	and    $0x3ff,%eax
  80063d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800640:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800645:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80064a:	85 db                	test   %ebx,%ebx
  80064c:	7e 07                	jle    800655 <libmain+0x2d>
		binaryname = argv[0];
  80064e:	8b 06                	mov    (%esi),%eax
  800650:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	56                   	push   %esi
  800659:	53                   	push   %ebx
  80065a:	e8 1f fa ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  80065f:	e8 0a 00 00 00       	call   80066e <exit>
}
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80066a:	5b                   	pop    %ebx
  80066b:	5e                   	pop    %esi
  80066c:	5d                   	pop    %ebp
  80066d:	c3                   	ret    

0080066e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800674:	e8 06 10 00 00       	call   80167f <close_all>
	sys_env_destroy(0);
  800679:	83 ec 0c             	sub    $0xc,%esp
  80067c:	6a 00                	push   $0x0
  80067e:	e8 e7 09 00 00       	call   80106a <sys_env_destroy>
}
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	c9                   	leave  
  800687:	c3                   	ret    

00800688 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800688:	55                   	push   %ebp
  800689:	89 e5                	mov    %esp,%ebp
  80068b:	56                   	push   %esi
  80068c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80068d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800690:	8b 35 04 40 80 00    	mov    0x804004,%esi
  800696:	e8 10 0a 00 00       	call   8010ab <sys_getenvid>
  80069b:	83 ec 0c             	sub    $0xc,%esp
  80069e:	ff 75 0c             	pushl  0xc(%ebp)
  8006a1:	ff 75 08             	pushl  0x8(%ebp)
  8006a4:	56                   	push   %esi
  8006a5:	50                   	push   %eax
  8006a6:	68 cc 2c 80 00       	push   $0x802ccc
  8006ab:	e8 b1 00 00 00       	call   800761 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006b0:	83 c4 18             	add    $0x18,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	ff 75 10             	pushl  0x10(%ebp)
  8006b7:	e8 54 00 00 00       	call   800710 <vcprintf>
	cprintf("\n");
  8006bc:	c7 04 24 68 31 80 00 	movl   $0x803168,(%esp)
  8006c3:	e8 99 00 00 00       	call   800761 <cprintf>
  8006c8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006cb:	cc                   	int3   
  8006cc:	eb fd                	jmp    8006cb <_panic+0x43>

008006ce <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	53                   	push   %ebx
  8006d2:	83 ec 04             	sub    $0x4,%esp
  8006d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006d8:	8b 13                	mov    (%ebx),%edx
  8006da:	8d 42 01             	lea    0x1(%edx),%eax
  8006dd:	89 03                	mov    %eax,(%ebx)
  8006df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006eb:	75 1a                	jne    800707 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	68 ff 00 00 00       	push   $0xff
  8006f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8006f8:	50                   	push   %eax
  8006f9:	e8 2f 09 00 00       	call   80102d <sys_cputs>
		b->idx = 0;
  8006fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800704:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800707:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80070b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    

00800710 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800719:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800720:	00 00 00 
	b.cnt = 0;
  800723:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80072a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	ff 75 08             	pushl  0x8(%ebp)
  800733:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	68 ce 06 80 00       	push   $0x8006ce
  80073f:	e8 54 01 00 00       	call   800898 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800744:	83 c4 08             	add    $0x8,%esp
  800747:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80074d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800753:	50                   	push   %eax
  800754:	e8 d4 08 00 00       	call   80102d <sys_cputs>

	return b.cnt;
}
  800759:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800767:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80076a:	50                   	push   %eax
  80076b:	ff 75 08             	pushl  0x8(%ebp)
  80076e:	e8 9d ff ff ff       	call   800710 <vcprintf>
	va_end(ap);

	return cnt;
}
  800773:	c9                   	leave  
  800774:	c3                   	ret    

00800775 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	57                   	push   %edi
  800779:	56                   	push   %esi
  80077a:	53                   	push   %ebx
  80077b:	83 ec 1c             	sub    $0x1c,%esp
  80077e:	89 c7                	mov    %eax,%edi
  800780:	89 d6                	mov    %edx,%esi
  800782:	8b 45 08             	mov    0x8(%ebp),%eax
  800785:	8b 55 0c             	mov    0xc(%ebp),%edx
  800788:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80078e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800791:	bb 00 00 00 00       	mov    $0x0,%ebx
  800796:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800799:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80079c:	39 d3                	cmp    %edx,%ebx
  80079e:	72 05                	jb     8007a5 <printnum+0x30>
  8007a0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8007a3:	77 45                	ja     8007ea <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8007a5:	83 ec 0c             	sub    $0xc,%esp
  8007a8:	ff 75 18             	pushl  0x18(%ebp)
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8007b1:	53                   	push   %ebx
  8007b2:	ff 75 10             	pushl  0x10(%ebp)
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8007be:	ff 75 dc             	pushl  -0x24(%ebp)
  8007c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8007c4:	e8 a7 1e 00 00       	call   802670 <__udivdi3>
  8007c9:	83 c4 18             	add    $0x18,%esp
  8007cc:	52                   	push   %edx
  8007cd:	50                   	push   %eax
  8007ce:	89 f2                	mov    %esi,%edx
  8007d0:	89 f8                	mov    %edi,%eax
  8007d2:	e8 9e ff ff ff       	call   800775 <printnum>
  8007d7:	83 c4 20             	add    $0x20,%esp
  8007da:	eb 18                	jmp    8007f4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	56                   	push   %esi
  8007e0:	ff 75 18             	pushl  0x18(%ebp)
  8007e3:	ff d7                	call   *%edi
  8007e5:	83 c4 10             	add    $0x10,%esp
  8007e8:	eb 03                	jmp    8007ed <printnum+0x78>
  8007ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007ed:	83 eb 01             	sub    $0x1,%ebx
  8007f0:	85 db                	test   %ebx,%ebx
  8007f2:	7f e8                	jg     8007dc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	56                   	push   %esi
  8007f8:	83 ec 04             	sub    $0x4,%esp
  8007fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800801:	ff 75 dc             	pushl  -0x24(%ebp)
  800804:	ff 75 d8             	pushl  -0x28(%ebp)
  800807:	e8 94 1f 00 00       	call   8027a0 <__umoddi3>
  80080c:	83 c4 14             	add    $0x14,%esp
  80080f:	0f be 80 ef 2c 80 00 	movsbl 0x802cef(%eax),%eax
  800816:	50                   	push   %eax
  800817:	ff d7                	call   *%edi
}
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80081f:	5b                   	pop    %ebx
  800820:	5e                   	pop    %esi
  800821:	5f                   	pop    %edi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800827:	83 fa 01             	cmp    $0x1,%edx
  80082a:	7e 0e                	jle    80083a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80082c:	8b 10                	mov    (%eax),%edx
  80082e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800831:	89 08                	mov    %ecx,(%eax)
  800833:	8b 02                	mov    (%edx),%eax
  800835:	8b 52 04             	mov    0x4(%edx),%edx
  800838:	eb 22                	jmp    80085c <getuint+0x38>
	else if (lflag)
  80083a:	85 d2                	test   %edx,%edx
  80083c:	74 10                	je     80084e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80083e:	8b 10                	mov    (%eax),%edx
  800840:	8d 4a 04             	lea    0x4(%edx),%ecx
  800843:	89 08                	mov    %ecx,(%eax)
  800845:	8b 02                	mov    (%edx),%eax
  800847:	ba 00 00 00 00       	mov    $0x0,%edx
  80084c:	eb 0e                	jmp    80085c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80084e:	8b 10                	mov    (%eax),%edx
  800850:	8d 4a 04             	lea    0x4(%edx),%ecx
  800853:	89 08                	mov    %ecx,(%eax)
  800855:	8b 02                	mov    (%edx),%eax
  800857:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800864:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800868:	8b 10                	mov    (%eax),%edx
  80086a:	3b 50 04             	cmp    0x4(%eax),%edx
  80086d:	73 0a                	jae    800879 <sprintputch+0x1b>
		*b->buf++ = ch;
  80086f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800872:	89 08                	mov    %ecx,(%eax)
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	88 02                	mov    %al,(%edx)
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800881:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800884:	50                   	push   %eax
  800885:	ff 75 10             	pushl  0x10(%ebp)
  800888:	ff 75 0c             	pushl  0xc(%ebp)
  80088b:	ff 75 08             	pushl  0x8(%ebp)
  80088e:	e8 05 00 00 00       	call   800898 <vprintfmt>
	va_end(ap);
}
  800893:	83 c4 10             	add    $0x10,%esp
  800896:	c9                   	leave  
  800897:	c3                   	ret    

00800898 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	57                   	push   %edi
  80089c:	56                   	push   %esi
  80089d:	53                   	push   %ebx
  80089e:	83 ec 2c             	sub    $0x2c,%esp
  8008a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008aa:	eb 12                	jmp    8008be <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	0f 84 89 03 00 00    	je     800c3d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	53                   	push   %ebx
  8008b8:	50                   	push   %eax
  8008b9:	ff d6                	call   *%esi
  8008bb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008be:	83 c7 01             	add    $0x1,%edi
  8008c1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008c5:	83 f8 25             	cmp    $0x25,%eax
  8008c8:	75 e2                	jne    8008ac <vprintfmt+0x14>
  8008ca:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8008ce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8008d5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008dc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8008e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e8:	eb 07                	jmp    8008f1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008ed:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f1:	8d 47 01             	lea    0x1(%edi),%eax
  8008f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008f7:	0f b6 07             	movzbl (%edi),%eax
  8008fa:	0f b6 c8             	movzbl %al,%ecx
  8008fd:	83 e8 23             	sub    $0x23,%eax
  800900:	3c 55                	cmp    $0x55,%al
  800902:	0f 87 1a 03 00 00    	ja     800c22 <vprintfmt+0x38a>
  800908:	0f b6 c0             	movzbl %al,%eax
  80090b:	ff 24 85 40 2e 80 00 	jmp    *0x802e40(,%eax,4)
  800912:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800915:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800919:	eb d6                	jmp    8008f1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80091e:	b8 00 00 00 00       	mov    $0x0,%eax
  800923:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800926:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800929:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80092d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800930:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800933:	83 fa 09             	cmp    $0x9,%edx
  800936:	77 39                	ja     800971 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800938:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80093b:	eb e9                	jmp    800926 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80093d:	8b 45 14             	mov    0x14(%ebp),%eax
  800940:	8d 48 04             	lea    0x4(%eax),%ecx
  800943:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800946:	8b 00                	mov    (%eax),%eax
  800948:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80094e:	eb 27                	jmp    800977 <vprintfmt+0xdf>
  800950:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800953:	85 c0                	test   %eax,%eax
  800955:	b9 00 00 00 00       	mov    $0x0,%ecx
  80095a:	0f 49 c8             	cmovns %eax,%ecx
  80095d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800960:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800963:	eb 8c                	jmp    8008f1 <vprintfmt+0x59>
  800965:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800968:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80096f:	eb 80                	jmp    8008f1 <vprintfmt+0x59>
  800971:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800974:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800977:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80097b:	0f 89 70 ff ff ff    	jns    8008f1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800981:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800984:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800987:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80098e:	e9 5e ff ff ff       	jmp    8008f1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800993:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800996:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800999:	e9 53 ff ff ff       	jmp    8008f1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80099e:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a1:	8d 50 04             	lea    0x4(%eax),%edx
  8009a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a7:	83 ec 08             	sub    $0x8,%esp
  8009aa:	53                   	push   %ebx
  8009ab:	ff 30                	pushl  (%eax)
  8009ad:	ff d6                	call   *%esi
			break;
  8009af:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8009b5:	e9 04 ff ff ff       	jmp    8008be <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8009bd:	8d 50 04             	lea    0x4(%eax),%edx
  8009c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8009c3:	8b 00                	mov    (%eax),%eax
  8009c5:	99                   	cltd   
  8009c6:	31 d0                	xor    %edx,%eax
  8009c8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009ca:	83 f8 0f             	cmp    $0xf,%eax
  8009cd:	7f 0b                	jg     8009da <vprintfmt+0x142>
  8009cf:	8b 14 85 a0 2f 80 00 	mov    0x802fa0(,%eax,4),%edx
  8009d6:	85 d2                	test   %edx,%edx
  8009d8:	75 18                	jne    8009f2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8009da:	50                   	push   %eax
  8009db:	68 07 2d 80 00       	push   $0x802d07
  8009e0:	53                   	push   %ebx
  8009e1:	56                   	push   %esi
  8009e2:	e8 94 fe ff ff       	call   80087b <printfmt>
  8009e7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8009ed:	e9 cc fe ff ff       	jmp    8008be <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8009f2:	52                   	push   %edx
  8009f3:	68 f6 30 80 00       	push   $0x8030f6
  8009f8:	53                   	push   %ebx
  8009f9:	56                   	push   %esi
  8009fa:	e8 7c fe ff ff       	call   80087b <printfmt>
  8009ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a02:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a05:	e9 b4 fe ff ff       	jmp    8008be <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a0a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0d:	8d 50 04             	lea    0x4(%eax),%edx
  800a10:	89 55 14             	mov    %edx,0x14(%ebp)
  800a13:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a15:	85 ff                	test   %edi,%edi
  800a17:	b8 00 2d 80 00       	mov    $0x802d00,%eax
  800a1c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a1f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a23:	0f 8e 94 00 00 00    	jle    800abd <vprintfmt+0x225>
  800a29:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800a2d:	0f 84 98 00 00 00    	je     800acb <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a33:	83 ec 08             	sub    $0x8,%esp
  800a36:	ff 75 d0             	pushl  -0x30(%ebp)
  800a39:	57                   	push   %edi
  800a3a:	e8 86 02 00 00       	call   800cc5 <strnlen>
  800a3f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a42:	29 c1                	sub    %eax,%ecx
  800a44:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800a47:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a4a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a4e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a51:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a54:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a56:	eb 0f                	jmp    800a67 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800a58:	83 ec 08             	sub    $0x8,%esp
  800a5b:	53                   	push   %ebx
  800a5c:	ff 75 e0             	pushl  -0x20(%ebp)
  800a5f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a61:	83 ef 01             	sub    $0x1,%edi
  800a64:	83 c4 10             	add    $0x10,%esp
  800a67:	85 ff                	test   %edi,%edi
  800a69:	7f ed                	jg     800a58 <vprintfmt+0x1c0>
  800a6b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a6e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a71:	85 c9                	test   %ecx,%ecx
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
  800a78:	0f 49 c1             	cmovns %ecx,%eax
  800a7b:	29 c1                	sub    %eax,%ecx
  800a7d:	89 75 08             	mov    %esi,0x8(%ebp)
  800a80:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a83:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a86:	89 cb                	mov    %ecx,%ebx
  800a88:	eb 4d                	jmp    800ad7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a8a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a8e:	74 1b                	je     800aab <vprintfmt+0x213>
  800a90:	0f be c0             	movsbl %al,%eax
  800a93:	83 e8 20             	sub    $0x20,%eax
  800a96:	83 f8 5e             	cmp    $0x5e,%eax
  800a99:	76 10                	jbe    800aab <vprintfmt+0x213>
					putch('?', putdat);
  800a9b:	83 ec 08             	sub    $0x8,%esp
  800a9e:	ff 75 0c             	pushl  0xc(%ebp)
  800aa1:	6a 3f                	push   $0x3f
  800aa3:	ff 55 08             	call   *0x8(%ebp)
  800aa6:	83 c4 10             	add    $0x10,%esp
  800aa9:	eb 0d                	jmp    800ab8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800aab:	83 ec 08             	sub    $0x8,%esp
  800aae:	ff 75 0c             	pushl  0xc(%ebp)
  800ab1:	52                   	push   %edx
  800ab2:	ff 55 08             	call   *0x8(%ebp)
  800ab5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ab8:	83 eb 01             	sub    $0x1,%ebx
  800abb:	eb 1a                	jmp    800ad7 <vprintfmt+0x23f>
  800abd:	89 75 08             	mov    %esi,0x8(%ebp)
  800ac0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ac3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ac6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ac9:	eb 0c                	jmp    800ad7 <vprintfmt+0x23f>
  800acb:	89 75 08             	mov    %esi,0x8(%ebp)
  800ace:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ad1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ad4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ad7:	83 c7 01             	add    $0x1,%edi
  800ada:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ade:	0f be d0             	movsbl %al,%edx
  800ae1:	85 d2                	test   %edx,%edx
  800ae3:	74 23                	je     800b08 <vprintfmt+0x270>
  800ae5:	85 f6                	test   %esi,%esi
  800ae7:	78 a1                	js     800a8a <vprintfmt+0x1f2>
  800ae9:	83 ee 01             	sub    $0x1,%esi
  800aec:	79 9c                	jns    800a8a <vprintfmt+0x1f2>
  800aee:	89 df                	mov    %ebx,%edi
  800af0:	8b 75 08             	mov    0x8(%ebp),%esi
  800af3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af6:	eb 18                	jmp    800b10 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800af8:	83 ec 08             	sub    $0x8,%esp
  800afb:	53                   	push   %ebx
  800afc:	6a 20                	push   $0x20
  800afe:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b00:	83 ef 01             	sub    $0x1,%edi
  800b03:	83 c4 10             	add    $0x10,%esp
  800b06:	eb 08                	jmp    800b10 <vprintfmt+0x278>
  800b08:	89 df                	mov    %ebx,%edi
  800b0a:	8b 75 08             	mov    0x8(%ebp),%esi
  800b0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b10:	85 ff                	test   %edi,%edi
  800b12:	7f e4                	jg     800af8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b14:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b17:	e9 a2 fd ff ff       	jmp    8008be <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b1c:	83 fa 01             	cmp    $0x1,%edx
  800b1f:	7e 16                	jle    800b37 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800b21:	8b 45 14             	mov    0x14(%ebp),%eax
  800b24:	8d 50 08             	lea    0x8(%eax),%edx
  800b27:	89 55 14             	mov    %edx,0x14(%ebp)
  800b2a:	8b 50 04             	mov    0x4(%eax),%edx
  800b2d:	8b 00                	mov    (%eax),%eax
  800b2f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b32:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b35:	eb 32                	jmp    800b69 <vprintfmt+0x2d1>
	else if (lflag)
  800b37:	85 d2                	test   %edx,%edx
  800b39:	74 18                	je     800b53 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800b3b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3e:	8d 50 04             	lea    0x4(%eax),%edx
  800b41:	89 55 14             	mov    %edx,0x14(%ebp)
  800b44:	8b 00                	mov    (%eax),%eax
  800b46:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b49:	89 c1                	mov    %eax,%ecx
  800b4b:	c1 f9 1f             	sar    $0x1f,%ecx
  800b4e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b51:	eb 16                	jmp    800b69 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800b53:	8b 45 14             	mov    0x14(%ebp),%eax
  800b56:	8d 50 04             	lea    0x4(%eax),%edx
  800b59:	89 55 14             	mov    %edx,0x14(%ebp)
  800b5c:	8b 00                	mov    (%eax),%eax
  800b5e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b61:	89 c1                	mov    %eax,%ecx
  800b63:	c1 f9 1f             	sar    $0x1f,%ecx
  800b66:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b69:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b6c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b6f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b74:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b78:	79 74                	jns    800bee <vprintfmt+0x356>
				putch('-', putdat);
  800b7a:	83 ec 08             	sub    $0x8,%esp
  800b7d:	53                   	push   %ebx
  800b7e:	6a 2d                	push   $0x2d
  800b80:	ff d6                	call   *%esi
				num = -(long long) num;
  800b82:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b85:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800b88:	f7 d8                	neg    %eax
  800b8a:	83 d2 00             	adc    $0x0,%edx
  800b8d:	f7 da                	neg    %edx
  800b8f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b92:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b97:	eb 55                	jmp    800bee <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b99:	8d 45 14             	lea    0x14(%ebp),%eax
  800b9c:	e8 83 fc ff ff       	call   800824 <getuint>
			base = 10;
  800ba1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800ba6:	eb 46                	jmp    800bee <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800ba8:	8d 45 14             	lea    0x14(%ebp),%eax
  800bab:	e8 74 fc ff ff       	call   800824 <getuint>
                        base = 8;
  800bb0:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800bb5:	eb 37                	jmp    800bee <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800bb7:	83 ec 08             	sub    $0x8,%esp
  800bba:	53                   	push   %ebx
  800bbb:	6a 30                	push   $0x30
  800bbd:	ff d6                	call   *%esi
			putch('x', putdat);
  800bbf:	83 c4 08             	add    $0x8,%esp
  800bc2:	53                   	push   %ebx
  800bc3:	6a 78                	push   $0x78
  800bc5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800bc7:	8b 45 14             	mov    0x14(%ebp),%eax
  800bca:	8d 50 04             	lea    0x4(%eax),%edx
  800bcd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bd0:	8b 00                	mov    (%eax),%eax
  800bd2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bd7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bda:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800bdf:	eb 0d                	jmp    800bee <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800be1:	8d 45 14             	lea    0x14(%ebp),%eax
  800be4:	e8 3b fc ff ff       	call   800824 <getuint>
			base = 16;
  800be9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bee:	83 ec 0c             	sub    $0xc,%esp
  800bf1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800bf5:	57                   	push   %edi
  800bf6:	ff 75 e0             	pushl  -0x20(%ebp)
  800bf9:	51                   	push   %ecx
  800bfa:	52                   	push   %edx
  800bfb:	50                   	push   %eax
  800bfc:	89 da                	mov    %ebx,%edx
  800bfe:	89 f0                	mov    %esi,%eax
  800c00:	e8 70 fb ff ff       	call   800775 <printnum>
			break;
  800c05:	83 c4 20             	add    $0x20,%esp
  800c08:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c0b:	e9 ae fc ff ff       	jmp    8008be <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c10:	83 ec 08             	sub    $0x8,%esp
  800c13:	53                   	push   %ebx
  800c14:	51                   	push   %ecx
  800c15:	ff d6                	call   *%esi
			break;
  800c17:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c1a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c1d:	e9 9c fc ff ff       	jmp    8008be <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c22:	83 ec 08             	sub    $0x8,%esp
  800c25:	53                   	push   %ebx
  800c26:	6a 25                	push   $0x25
  800c28:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c2a:	83 c4 10             	add    $0x10,%esp
  800c2d:	eb 03                	jmp    800c32 <vprintfmt+0x39a>
  800c2f:	83 ef 01             	sub    $0x1,%edi
  800c32:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c36:	75 f7                	jne    800c2f <vprintfmt+0x397>
  800c38:	e9 81 fc ff ff       	jmp    8008be <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	83 ec 18             	sub    $0x18,%esp
  800c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c51:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c54:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c58:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	74 26                	je     800c8c <vsnprintf+0x47>
  800c66:	85 d2                	test   %edx,%edx
  800c68:	7e 22                	jle    800c8c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c6a:	ff 75 14             	pushl  0x14(%ebp)
  800c6d:	ff 75 10             	pushl  0x10(%ebp)
  800c70:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c73:	50                   	push   %eax
  800c74:	68 5e 08 80 00       	push   $0x80085e
  800c79:	e8 1a fc ff ff       	call   800898 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c81:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c87:	83 c4 10             	add    $0x10,%esp
  800c8a:	eb 05                	jmp    800c91 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c8c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c91:	c9                   	leave  
  800c92:	c3                   	ret    

00800c93 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c99:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c9c:	50                   	push   %eax
  800c9d:	ff 75 10             	pushl  0x10(%ebp)
  800ca0:	ff 75 0c             	pushl  0xc(%ebp)
  800ca3:	ff 75 08             	pushl  0x8(%ebp)
  800ca6:	e8 9a ff ff ff       	call   800c45 <vsnprintf>
	va_end(ap);

	return rc;
}
  800cab:	c9                   	leave  
  800cac:	c3                   	ret    

00800cad <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb8:	eb 03                	jmp    800cbd <strlen+0x10>
		n++;
  800cba:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cbd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cc1:	75 f7                	jne    800cba <strlen+0xd>
		n++;
	return n;
}
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cce:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd3:	eb 03                	jmp    800cd8 <strnlen+0x13>
		n++;
  800cd5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cd8:	39 c2                	cmp    %eax,%edx
  800cda:	74 08                	je     800ce4 <strnlen+0x1f>
  800cdc:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800ce0:	75 f3                	jne    800cd5 <strnlen+0x10>
  800ce2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	53                   	push   %ebx
  800cea:	8b 45 08             	mov    0x8(%ebp),%eax
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cf0:	89 c2                	mov    %eax,%edx
  800cf2:	83 c2 01             	add    $0x1,%edx
  800cf5:	83 c1 01             	add    $0x1,%ecx
  800cf8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800cfc:	88 5a ff             	mov    %bl,-0x1(%edx)
  800cff:	84 db                	test   %bl,%bl
  800d01:	75 ef                	jne    800cf2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d03:	5b                   	pop    %ebx
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	53                   	push   %ebx
  800d0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d0d:	53                   	push   %ebx
  800d0e:	e8 9a ff ff ff       	call   800cad <strlen>
  800d13:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d16:	ff 75 0c             	pushl  0xc(%ebp)
  800d19:	01 d8                	add    %ebx,%eax
  800d1b:	50                   	push   %eax
  800d1c:	e8 c5 ff ff ff       	call   800ce6 <strcpy>
	return dst;
}
  800d21:	89 d8                	mov    %ebx,%eax
  800d23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d26:	c9                   	leave  
  800d27:	c3                   	ret    

00800d28 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	8b 75 08             	mov    0x8(%ebp),%esi
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	89 f3                	mov    %esi,%ebx
  800d35:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d38:	89 f2                	mov    %esi,%edx
  800d3a:	eb 0f                	jmp    800d4b <strncpy+0x23>
		*dst++ = *src;
  800d3c:	83 c2 01             	add    $0x1,%edx
  800d3f:	0f b6 01             	movzbl (%ecx),%eax
  800d42:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d45:	80 39 01             	cmpb   $0x1,(%ecx)
  800d48:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d4b:	39 da                	cmp    %ebx,%edx
  800d4d:	75 ed                	jne    800d3c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d4f:	89 f0                	mov    %esi,%eax
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	8b 75 08             	mov    0x8(%ebp),%esi
  800d5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d60:	8b 55 10             	mov    0x10(%ebp),%edx
  800d63:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d65:	85 d2                	test   %edx,%edx
  800d67:	74 21                	je     800d8a <strlcpy+0x35>
  800d69:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d6d:	89 f2                	mov    %esi,%edx
  800d6f:	eb 09                	jmp    800d7a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d71:	83 c2 01             	add    $0x1,%edx
  800d74:	83 c1 01             	add    $0x1,%ecx
  800d77:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d7a:	39 c2                	cmp    %eax,%edx
  800d7c:	74 09                	je     800d87 <strlcpy+0x32>
  800d7e:	0f b6 19             	movzbl (%ecx),%ebx
  800d81:	84 db                	test   %bl,%bl
  800d83:	75 ec                	jne    800d71 <strlcpy+0x1c>
  800d85:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d87:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d8a:	29 f0                	sub    %esi,%eax
}
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d96:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d99:	eb 06                	jmp    800da1 <strcmp+0x11>
		p++, q++;
  800d9b:	83 c1 01             	add    $0x1,%ecx
  800d9e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800da1:	0f b6 01             	movzbl (%ecx),%eax
  800da4:	84 c0                	test   %al,%al
  800da6:	74 04                	je     800dac <strcmp+0x1c>
  800da8:	3a 02                	cmp    (%edx),%al
  800daa:	74 ef                	je     800d9b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dac:	0f b6 c0             	movzbl %al,%eax
  800daf:	0f b6 12             	movzbl (%edx),%edx
  800db2:	29 d0                	sub    %edx,%eax
}
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	53                   	push   %ebx
  800dba:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc0:	89 c3                	mov    %eax,%ebx
  800dc2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800dc5:	eb 06                	jmp    800dcd <strncmp+0x17>
		n--, p++, q++;
  800dc7:	83 c0 01             	add    $0x1,%eax
  800dca:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dcd:	39 d8                	cmp    %ebx,%eax
  800dcf:	74 15                	je     800de6 <strncmp+0x30>
  800dd1:	0f b6 08             	movzbl (%eax),%ecx
  800dd4:	84 c9                	test   %cl,%cl
  800dd6:	74 04                	je     800ddc <strncmp+0x26>
  800dd8:	3a 0a                	cmp    (%edx),%cl
  800dda:	74 eb                	je     800dc7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ddc:	0f b6 00             	movzbl (%eax),%eax
  800ddf:	0f b6 12             	movzbl (%edx),%edx
  800de2:	29 d0                	sub    %edx,%eax
  800de4:	eb 05                	jmp    800deb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800de6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800deb:	5b                   	pop    %ebx
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    

00800dee <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	8b 45 08             	mov    0x8(%ebp),%eax
  800df4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800df8:	eb 07                	jmp    800e01 <strchr+0x13>
		if (*s == c)
  800dfa:	38 ca                	cmp    %cl,%dl
  800dfc:	74 0f                	je     800e0d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dfe:	83 c0 01             	add    $0x1,%eax
  800e01:	0f b6 10             	movzbl (%eax),%edx
  800e04:	84 d2                	test   %dl,%dl
  800e06:	75 f2                	jne    800dfa <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	8b 45 08             	mov    0x8(%ebp),%eax
  800e15:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e19:	eb 03                	jmp    800e1e <strfind+0xf>
  800e1b:	83 c0 01             	add    $0x1,%eax
  800e1e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e21:	38 ca                	cmp    %cl,%dl
  800e23:	74 04                	je     800e29 <strfind+0x1a>
  800e25:	84 d2                	test   %dl,%dl
  800e27:	75 f2                	jne    800e1b <strfind+0xc>
			break;
	return (char *) s;
}
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    

00800e2b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	57                   	push   %edi
  800e2f:	56                   	push   %esi
  800e30:	53                   	push   %ebx
  800e31:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e34:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e37:	85 c9                	test   %ecx,%ecx
  800e39:	74 36                	je     800e71 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e3b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e41:	75 28                	jne    800e6b <memset+0x40>
  800e43:	f6 c1 03             	test   $0x3,%cl
  800e46:	75 23                	jne    800e6b <memset+0x40>
		c &= 0xFF;
  800e48:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e4c:	89 d3                	mov    %edx,%ebx
  800e4e:	c1 e3 08             	shl    $0x8,%ebx
  800e51:	89 d6                	mov    %edx,%esi
  800e53:	c1 e6 18             	shl    $0x18,%esi
  800e56:	89 d0                	mov    %edx,%eax
  800e58:	c1 e0 10             	shl    $0x10,%eax
  800e5b:	09 f0                	or     %esi,%eax
  800e5d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800e5f:	89 d8                	mov    %ebx,%eax
  800e61:	09 d0                	or     %edx,%eax
  800e63:	c1 e9 02             	shr    $0x2,%ecx
  800e66:	fc                   	cld    
  800e67:	f3 ab                	rep stos %eax,%es:(%edi)
  800e69:	eb 06                	jmp    800e71 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6e:	fc                   	cld    
  800e6f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e71:	89 f8                	mov    %edi,%eax
  800e73:	5b                   	pop    %ebx
  800e74:	5e                   	pop    %esi
  800e75:	5f                   	pop    %edi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    

00800e78 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	57                   	push   %edi
  800e7c:	56                   	push   %esi
  800e7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e80:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e83:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e86:	39 c6                	cmp    %eax,%esi
  800e88:	73 35                	jae    800ebf <memmove+0x47>
  800e8a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e8d:	39 d0                	cmp    %edx,%eax
  800e8f:	73 2e                	jae    800ebf <memmove+0x47>
		s += n;
		d += n;
  800e91:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e94:	89 d6                	mov    %edx,%esi
  800e96:	09 fe                	or     %edi,%esi
  800e98:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e9e:	75 13                	jne    800eb3 <memmove+0x3b>
  800ea0:	f6 c1 03             	test   $0x3,%cl
  800ea3:	75 0e                	jne    800eb3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ea5:	83 ef 04             	sub    $0x4,%edi
  800ea8:	8d 72 fc             	lea    -0x4(%edx),%esi
  800eab:	c1 e9 02             	shr    $0x2,%ecx
  800eae:	fd                   	std    
  800eaf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800eb1:	eb 09                	jmp    800ebc <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800eb3:	83 ef 01             	sub    $0x1,%edi
  800eb6:	8d 72 ff             	lea    -0x1(%edx),%esi
  800eb9:	fd                   	std    
  800eba:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ebc:	fc                   	cld    
  800ebd:	eb 1d                	jmp    800edc <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ebf:	89 f2                	mov    %esi,%edx
  800ec1:	09 c2                	or     %eax,%edx
  800ec3:	f6 c2 03             	test   $0x3,%dl
  800ec6:	75 0f                	jne    800ed7 <memmove+0x5f>
  800ec8:	f6 c1 03             	test   $0x3,%cl
  800ecb:	75 0a                	jne    800ed7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ecd:	c1 e9 02             	shr    $0x2,%ecx
  800ed0:	89 c7                	mov    %eax,%edi
  800ed2:	fc                   	cld    
  800ed3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ed5:	eb 05                	jmp    800edc <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ed7:	89 c7                	mov    %eax,%edi
  800ed9:	fc                   	cld    
  800eda:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800edc:	5e                   	pop    %esi
  800edd:	5f                   	pop    %edi
  800ede:	5d                   	pop    %ebp
  800edf:	c3                   	ret    

00800ee0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ee3:	ff 75 10             	pushl  0x10(%ebp)
  800ee6:	ff 75 0c             	pushl  0xc(%ebp)
  800ee9:	ff 75 08             	pushl  0x8(%ebp)
  800eec:	e8 87 ff ff ff       	call   800e78 <memmove>
}
  800ef1:	c9                   	leave  
  800ef2:	c3                   	ret    

00800ef3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	56                   	push   %esi
  800ef7:	53                   	push   %ebx
  800ef8:	8b 45 08             	mov    0x8(%ebp),%eax
  800efb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800efe:	89 c6                	mov    %eax,%esi
  800f00:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f03:	eb 1a                	jmp    800f1f <memcmp+0x2c>
		if (*s1 != *s2)
  800f05:	0f b6 08             	movzbl (%eax),%ecx
  800f08:	0f b6 1a             	movzbl (%edx),%ebx
  800f0b:	38 d9                	cmp    %bl,%cl
  800f0d:	74 0a                	je     800f19 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f0f:	0f b6 c1             	movzbl %cl,%eax
  800f12:	0f b6 db             	movzbl %bl,%ebx
  800f15:	29 d8                	sub    %ebx,%eax
  800f17:	eb 0f                	jmp    800f28 <memcmp+0x35>
		s1++, s2++;
  800f19:	83 c0 01             	add    $0x1,%eax
  800f1c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f1f:	39 f0                	cmp    %esi,%eax
  800f21:	75 e2                	jne    800f05 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	53                   	push   %ebx
  800f30:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f33:	89 c1                	mov    %eax,%ecx
  800f35:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800f38:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f3c:	eb 0a                	jmp    800f48 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f3e:	0f b6 10             	movzbl (%eax),%edx
  800f41:	39 da                	cmp    %ebx,%edx
  800f43:	74 07                	je     800f4c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f45:	83 c0 01             	add    $0x1,%eax
  800f48:	39 c8                	cmp    %ecx,%eax
  800f4a:	72 f2                	jb     800f3e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f4c:	5b                   	pop    %ebx
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    

00800f4f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	57                   	push   %edi
  800f53:	56                   	push   %esi
  800f54:	53                   	push   %ebx
  800f55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f5b:	eb 03                	jmp    800f60 <strtol+0x11>
		s++;
  800f5d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f60:	0f b6 01             	movzbl (%ecx),%eax
  800f63:	3c 20                	cmp    $0x20,%al
  800f65:	74 f6                	je     800f5d <strtol+0xe>
  800f67:	3c 09                	cmp    $0x9,%al
  800f69:	74 f2                	je     800f5d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f6b:	3c 2b                	cmp    $0x2b,%al
  800f6d:	75 0a                	jne    800f79 <strtol+0x2a>
		s++;
  800f6f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f72:	bf 00 00 00 00       	mov    $0x0,%edi
  800f77:	eb 11                	jmp    800f8a <strtol+0x3b>
  800f79:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f7e:	3c 2d                	cmp    $0x2d,%al
  800f80:	75 08                	jne    800f8a <strtol+0x3b>
		s++, neg = 1;
  800f82:	83 c1 01             	add    $0x1,%ecx
  800f85:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f8a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f90:	75 15                	jne    800fa7 <strtol+0x58>
  800f92:	80 39 30             	cmpb   $0x30,(%ecx)
  800f95:	75 10                	jne    800fa7 <strtol+0x58>
  800f97:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f9b:	75 7c                	jne    801019 <strtol+0xca>
		s += 2, base = 16;
  800f9d:	83 c1 02             	add    $0x2,%ecx
  800fa0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fa5:	eb 16                	jmp    800fbd <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800fa7:	85 db                	test   %ebx,%ebx
  800fa9:	75 12                	jne    800fbd <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fab:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fb0:	80 39 30             	cmpb   $0x30,(%ecx)
  800fb3:	75 08                	jne    800fbd <strtol+0x6e>
		s++, base = 8;
  800fb5:	83 c1 01             	add    $0x1,%ecx
  800fb8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800fbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fc5:	0f b6 11             	movzbl (%ecx),%edx
  800fc8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800fcb:	89 f3                	mov    %esi,%ebx
  800fcd:	80 fb 09             	cmp    $0x9,%bl
  800fd0:	77 08                	ja     800fda <strtol+0x8b>
			dig = *s - '0';
  800fd2:	0f be d2             	movsbl %dl,%edx
  800fd5:	83 ea 30             	sub    $0x30,%edx
  800fd8:	eb 22                	jmp    800ffc <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800fda:	8d 72 9f             	lea    -0x61(%edx),%esi
  800fdd:	89 f3                	mov    %esi,%ebx
  800fdf:	80 fb 19             	cmp    $0x19,%bl
  800fe2:	77 08                	ja     800fec <strtol+0x9d>
			dig = *s - 'a' + 10;
  800fe4:	0f be d2             	movsbl %dl,%edx
  800fe7:	83 ea 57             	sub    $0x57,%edx
  800fea:	eb 10                	jmp    800ffc <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800fec:	8d 72 bf             	lea    -0x41(%edx),%esi
  800fef:	89 f3                	mov    %esi,%ebx
  800ff1:	80 fb 19             	cmp    $0x19,%bl
  800ff4:	77 16                	ja     80100c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ff6:	0f be d2             	movsbl %dl,%edx
  800ff9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ffc:	3b 55 10             	cmp    0x10(%ebp),%edx
  800fff:	7d 0b                	jge    80100c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801001:	83 c1 01             	add    $0x1,%ecx
  801004:	0f af 45 10          	imul   0x10(%ebp),%eax
  801008:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80100a:	eb b9                	jmp    800fc5 <strtol+0x76>

	if (endptr)
  80100c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801010:	74 0d                	je     80101f <strtol+0xd0>
		*endptr = (char *) s;
  801012:	8b 75 0c             	mov    0xc(%ebp),%esi
  801015:	89 0e                	mov    %ecx,(%esi)
  801017:	eb 06                	jmp    80101f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801019:	85 db                	test   %ebx,%ebx
  80101b:	74 98                	je     800fb5 <strtol+0x66>
  80101d:	eb 9e                	jmp    800fbd <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80101f:	89 c2                	mov    %eax,%edx
  801021:	f7 da                	neg    %edx
  801023:	85 ff                	test   %edi,%edi
  801025:	0f 45 c2             	cmovne %edx,%eax
}
  801028:	5b                   	pop    %ebx
  801029:	5e                   	pop    %esi
  80102a:	5f                   	pop    %edi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    

0080102d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	57                   	push   %edi
  801031:	56                   	push   %esi
  801032:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801033:	b8 00 00 00 00       	mov    $0x0,%eax
  801038:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103b:	8b 55 08             	mov    0x8(%ebp),%edx
  80103e:	89 c3                	mov    %eax,%ebx
  801040:	89 c7                	mov    %eax,%edi
  801042:	89 c6                	mov    %eax,%esi
  801044:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801046:	5b                   	pop    %ebx
  801047:	5e                   	pop    %esi
  801048:	5f                   	pop    %edi
  801049:	5d                   	pop    %ebp
  80104a:	c3                   	ret    

0080104b <sys_cgetc>:

int
sys_cgetc(void)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	57                   	push   %edi
  80104f:	56                   	push   %esi
  801050:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801051:	ba 00 00 00 00       	mov    $0x0,%edx
  801056:	b8 01 00 00 00       	mov    $0x1,%eax
  80105b:	89 d1                	mov    %edx,%ecx
  80105d:	89 d3                	mov    %edx,%ebx
  80105f:	89 d7                	mov    %edx,%edi
  801061:	89 d6                	mov    %edx,%esi
  801063:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801065:	5b                   	pop    %ebx
  801066:	5e                   	pop    %esi
  801067:	5f                   	pop    %edi
  801068:	5d                   	pop    %ebp
  801069:	c3                   	ret    

0080106a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	57                   	push   %edi
  80106e:	56                   	push   %esi
  80106f:	53                   	push   %ebx
  801070:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801073:	b9 00 00 00 00       	mov    $0x0,%ecx
  801078:	b8 03 00 00 00       	mov    $0x3,%eax
  80107d:	8b 55 08             	mov    0x8(%ebp),%edx
  801080:	89 cb                	mov    %ecx,%ebx
  801082:	89 cf                	mov    %ecx,%edi
  801084:	89 ce                	mov    %ecx,%esi
  801086:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801088:	85 c0                	test   %eax,%eax
  80108a:	7e 17                	jle    8010a3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80108c:	83 ec 0c             	sub    $0xc,%esp
  80108f:	50                   	push   %eax
  801090:	6a 03                	push   $0x3
  801092:	68 ff 2f 80 00       	push   $0x802fff
  801097:	6a 23                	push   $0x23
  801099:	68 1c 30 80 00       	push   $0x80301c
  80109e:	e8 e5 f5 ff ff       	call   800688 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a6:	5b                   	pop    %ebx
  8010a7:	5e                   	pop    %esi
  8010a8:	5f                   	pop    %edi
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    

008010ab <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	57                   	push   %edi
  8010af:	56                   	push   %esi
  8010b0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b6:	b8 02 00 00 00       	mov    $0x2,%eax
  8010bb:	89 d1                	mov    %edx,%ecx
  8010bd:	89 d3                	mov    %edx,%ebx
  8010bf:	89 d7                	mov    %edx,%edi
  8010c1:	89 d6                	mov    %edx,%esi
  8010c3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010c5:	5b                   	pop    %ebx
  8010c6:	5e                   	pop    %esi
  8010c7:	5f                   	pop    %edi
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <sys_yield>:

void
sys_yield(void)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	57                   	push   %edi
  8010ce:	56                   	push   %esi
  8010cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010da:	89 d1                	mov    %edx,%ecx
  8010dc:	89 d3                	mov    %edx,%ebx
  8010de:	89 d7                	mov    %edx,%edi
  8010e0:	89 d6                	mov    %edx,%esi
  8010e2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010e4:	5b                   	pop    %ebx
  8010e5:	5e                   	pop    %esi
  8010e6:	5f                   	pop    %edi
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    

008010e9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	57                   	push   %edi
  8010ed:	56                   	push   %esi
  8010ee:	53                   	push   %ebx
  8010ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f2:	be 00 00 00 00       	mov    $0x0,%esi
  8010f7:	b8 04 00 00 00       	mov    $0x4,%eax
  8010fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801102:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801105:	89 f7                	mov    %esi,%edi
  801107:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801109:	85 c0                	test   %eax,%eax
  80110b:	7e 17                	jle    801124 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110d:	83 ec 0c             	sub    $0xc,%esp
  801110:	50                   	push   %eax
  801111:	6a 04                	push   $0x4
  801113:	68 ff 2f 80 00       	push   $0x802fff
  801118:	6a 23                	push   $0x23
  80111a:	68 1c 30 80 00       	push   $0x80301c
  80111f:	e8 64 f5 ff ff       	call   800688 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801127:	5b                   	pop    %ebx
  801128:	5e                   	pop    %esi
  801129:	5f                   	pop    %edi
  80112a:	5d                   	pop    %ebp
  80112b:	c3                   	ret    

0080112c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	57                   	push   %edi
  801130:	56                   	push   %esi
  801131:	53                   	push   %ebx
  801132:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801135:	b8 05 00 00 00       	mov    $0x5,%eax
  80113a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113d:	8b 55 08             	mov    0x8(%ebp),%edx
  801140:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801143:	8b 7d 14             	mov    0x14(%ebp),%edi
  801146:	8b 75 18             	mov    0x18(%ebp),%esi
  801149:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80114b:	85 c0                	test   %eax,%eax
  80114d:	7e 17                	jle    801166 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80114f:	83 ec 0c             	sub    $0xc,%esp
  801152:	50                   	push   %eax
  801153:	6a 05                	push   $0x5
  801155:	68 ff 2f 80 00       	push   $0x802fff
  80115a:	6a 23                	push   $0x23
  80115c:	68 1c 30 80 00       	push   $0x80301c
  801161:	e8 22 f5 ff ff       	call   800688 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801166:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801169:	5b                   	pop    %ebx
  80116a:	5e                   	pop    %esi
  80116b:	5f                   	pop    %edi
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    

0080116e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	57                   	push   %edi
  801172:	56                   	push   %esi
  801173:	53                   	push   %ebx
  801174:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801177:	bb 00 00 00 00       	mov    $0x0,%ebx
  80117c:	b8 06 00 00 00       	mov    $0x6,%eax
  801181:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801184:	8b 55 08             	mov    0x8(%ebp),%edx
  801187:	89 df                	mov    %ebx,%edi
  801189:	89 de                	mov    %ebx,%esi
  80118b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80118d:	85 c0                	test   %eax,%eax
  80118f:	7e 17                	jle    8011a8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801191:	83 ec 0c             	sub    $0xc,%esp
  801194:	50                   	push   %eax
  801195:	6a 06                	push   $0x6
  801197:	68 ff 2f 80 00       	push   $0x802fff
  80119c:	6a 23                	push   $0x23
  80119e:	68 1c 30 80 00       	push   $0x80301c
  8011a3:	e8 e0 f4 ff ff       	call   800688 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ab:	5b                   	pop    %ebx
  8011ac:	5e                   	pop    %esi
  8011ad:	5f                   	pop    %edi
  8011ae:	5d                   	pop    %ebp
  8011af:	c3                   	ret    

008011b0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	57                   	push   %edi
  8011b4:	56                   	push   %esi
  8011b5:	53                   	push   %ebx
  8011b6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011be:	b8 08 00 00 00       	mov    $0x8,%eax
  8011c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c9:	89 df                	mov    %ebx,%edi
  8011cb:	89 de                	mov    %ebx,%esi
  8011cd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	7e 17                	jle    8011ea <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011d3:	83 ec 0c             	sub    $0xc,%esp
  8011d6:	50                   	push   %eax
  8011d7:	6a 08                	push   $0x8
  8011d9:	68 ff 2f 80 00       	push   $0x802fff
  8011de:	6a 23                	push   $0x23
  8011e0:	68 1c 30 80 00       	push   $0x80301c
  8011e5:	e8 9e f4 ff ff       	call   800688 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ed:	5b                   	pop    %ebx
  8011ee:	5e                   	pop    %esi
  8011ef:	5f                   	pop    %edi
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    

008011f2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	57                   	push   %edi
  8011f6:	56                   	push   %esi
  8011f7:	53                   	push   %ebx
  8011f8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801200:	b8 09 00 00 00       	mov    $0x9,%eax
  801205:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801208:	8b 55 08             	mov    0x8(%ebp),%edx
  80120b:	89 df                	mov    %ebx,%edi
  80120d:	89 de                	mov    %ebx,%esi
  80120f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801211:	85 c0                	test   %eax,%eax
  801213:	7e 17                	jle    80122c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801215:	83 ec 0c             	sub    $0xc,%esp
  801218:	50                   	push   %eax
  801219:	6a 09                	push   $0x9
  80121b:	68 ff 2f 80 00       	push   $0x802fff
  801220:	6a 23                	push   $0x23
  801222:	68 1c 30 80 00       	push   $0x80301c
  801227:	e8 5c f4 ff ff       	call   800688 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80122c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80122f:	5b                   	pop    %ebx
  801230:	5e                   	pop    %esi
  801231:	5f                   	pop    %edi
  801232:	5d                   	pop    %ebp
  801233:	c3                   	ret    

00801234 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	57                   	push   %edi
  801238:	56                   	push   %esi
  801239:	53                   	push   %ebx
  80123a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80123d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801242:	b8 0a 00 00 00       	mov    $0xa,%eax
  801247:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80124a:	8b 55 08             	mov    0x8(%ebp),%edx
  80124d:	89 df                	mov    %ebx,%edi
  80124f:	89 de                	mov    %ebx,%esi
  801251:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801253:	85 c0                	test   %eax,%eax
  801255:	7e 17                	jle    80126e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801257:	83 ec 0c             	sub    $0xc,%esp
  80125a:	50                   	push   %eax
  80125b:	6a 0a                	push   $0xa
  80125d:	68 ff 2f 80 00       	push   $0x802fff
  801262:	6a 23                	push   $0x23
  801264:	68 1c 30 80 00       	push   $0x80301c
  801269:	e8 1a f4 ff ff       	call   800688 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80126e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801271:	5b                   	pop    %ebx
  801272:	5e                   	pop    %esi
  801273:	5f                   	pop    %edi
  801274:	5d                   	pop    %ebp
  801275:	c3                   	ret    

00801276 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801276:	55                   	push   %ebp
  801277:	89 e5                	mov    %esp,%ebp
  801279:	57                   	push   %edi
  80127a:	56                   	push   %esi
  80127b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80127c:	be 00 00 00 00       	mov    $0x0,%esi
  801281:	b8 0c 00 00 00       	mov    $0xc,%eax
  801286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801289:	8b 55 08             	mov    0x8(%ebp),%edx
  80128c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80128f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801292:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801294:	5b                   	pop    %ebx
  801295:	5e                   	pop    %esi
  801296:	5f                   	pop    %edi
  801297:	5d                   	pop    %ebp
  801298:	c3                   	ret    

00801299 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	57                   	push   %edi
  80129d:	56                   	push   %esi
  80129e:	53                   	push   %ebx
  80129f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012a7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8012af:	89 cb                	mov    %ecx,%ebx
  8012b1:	89 cf                	mov    %ecx,%edi
  8012b3:	89 ce                	mov    %ecx,%esi
  8012b5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	7e 17                	jle    8012d2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012bb:	83 ec 0c             	sub    $0xc,%esp
  8012be:	50                   	push   %eax
  8012bf:	6a 0d                	push   $0xd
  8012c1:	68 ff 2f 80 00       	push   $0x802fff
  8012c6:	6a 23                	push   $0x23
  8012c8:	68 1c 30 80 00       	push   $0x80301c
  8012cd:	e8 b6 f3 ff ff       	call   800688 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d5:	5b                   	pop    %ebx
  8012d6:	5e                   	pop    %esi
  8012d7:	5f                   	pop    %edi
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    

008012da <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	57                   	push   %edi
  8012de:	56                   	push   %esi
  8012df:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e5:	b8 0e 00 00 00       	mov    $0xe,%eax
  8012ea:	89 d1                	mov    %edx,%ecx
  8012ec:	89 d3                	mov    %edx,%ebx
  8012ee:	89 d7                	mov    %edx,%edi
  8012f0:	89 d6                	mov    %edx,%esi
  8012f2:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8012f4:	5b                   	pop    %ebx
  8012f5:	5e                   	pop    %esi
  8012f6:	5f                   	pop    %edi
  8012f7:	5d                   	pop    %ebp
  8012f8:	c3                   	ret    

008012f9 <sys_transmit_packet>:

int
sys_transmit_packet(void *buf, size_t size)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	57                   	push   %edi
  8012fd:	56                   	push   %esi
  8012fe:	53                   	push   %ebx
  8012ff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801302:	bb 00 00 00 00       	mov    $0x0,%ebx
  801307:	b8 0f 00 00 00       	mov    $0xf,%eax
  80130c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80130f:	8b 55 08             	mov    0x8(%ebp),%edx
  801312:	89 df                	mov    %ebx,%edi
  801314:	89 de                	mov    %ebx,%esi
  801316:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801318:	85 c0                	test   %eax,%eax
  80131a:	7e 17                	jle    801333 <sys_transmit_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80131c:	83 ec 0c             	sub    $0xc,%esp
  80131f:	50                   	push   %eax
  801320:	6a 0f                	push   $0xf
  801322:	68 ff 2f 80 00       	push   $0x802fff
  801327:	6a 23                	push   $0x23
  801329:	68 1c 30 80 00       	push   $0x80301c
  80132e:	e8 55 f3 ff ff       	call   800688 <_panic>
int
sys_transmit_packet(void *buf, size_t size)
{
	return syscall(SYS_transmit_packet, 1,
		(uint32_t) buf, (uint32_t) size, 0, 0, 0);
}
  801333:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801336:	5b                   	pop    %ebx
  801337:	5e                   	pop    %esi
  801338:	5f                   	pop    %edi
  801339:	5d                   	pop    %ebp
  80133a:	c3                   	ret    

0080133b <sys_receive_packet>:

int
sys_receive_packet(void *buf, size_t *size_store)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	57                   	push   %edi
  80133f:	56                   	push   %esi
  801340:	53                   	push   %ebx
  801341:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801344:	bb 00 00 00 00       	mov    $0x0,%ebx
  801349:	b8 10 00 00 00       	mov    $0x10,%eax
  80134e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801351:	8b 55 08             	mov    0x8(%ebp),%edx
  801354:	89 df                	mov    %ebx,%edi
  801356:	89 de                	mov    %ebx,%esi
  801358:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80135a:	85 c0                	test   %eax,%eax
  80135c:	7e 17                	jle    801375 <sys_receive_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80135e:	83 ec 0c             	sub    $0xc,%esp
  801361:	50                   	push   %eax
  801362:	6a 10                	push   $0x10
  801364:	68 ff 2f 80 00       	push   $0x802fff
  801369:	6a 23                	push   $0x23
  80136b:	68 1c 30 80 00       	push   $0x80301c
  801370:	e8 13 f3 ff ff       	call   800688 <_panic>
int
sys_receive_packet(void *buf, size_t *size_store)
{
	return syscall(SYS_receive_packet, 1,
		(uint32_t) buf, (uint32_t) size_store, 0, 0, 0);
}
  801375:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801378:	5b                   	pop    %ebx
  801379:	5e                   	pop    %esi
  80137a:	5f                   	pop    %edi
  80137b:	5d                   	pop    %ebp
  80137c:	c3                   	ret    

0080137d <sys_get_mac_address>:

int
sys_get_mac_address(void *buf)
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	57                   	push   %edi
  801381:	56                   	push   %esi
  801382:	53                   	push   %ebx
  801383:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801386:	b9 00 00 00 00       	mov    $0x0,%ecx
  80138b:	b8 11 00 00 00       	mov    $0x11,%eax
  801390:	8b 55 08             	mov    0x8(%ebp),%edx
  801393:	89 cb                	mov    %ecx,%ebx
  801395:	89 cf                	mov    %ecx,%edi
  801397:	89 ce                	mov    %ecx,%esi
  801399:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80139b:	85 c0                	test   %eax,%eax
  80139d:	7e 17                	jle    8013b6 <sys_get_mac_address+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80139f:	83 ec 0c             	sub    $0xc,%esp
  8013a2:	50                   	push   %eax
  8013a3:	6a 11                	push   $0x11
  8013a5:	68 ff 2f 80 00       	push   $0x802fff
  8013aa:	6a 23                	push   $0x23
  8013ac:	68 1c 30 80 00       	push   $0x80301c
  8013b1:	e8 d2 f2 ff ff       	call   800688 <_panic>
int
sys_get_mac_address(void *buf)
{
	return syscall(SYS_get_mac_address, 1,
		(uint32_t) buf, 0, 0, 0, 0);
}
  8013b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b9:	5b                   	pop    %ebx
  8013ba:	5e                   	pop    %esi
  8013bb:	5f                   	pop    %edi
  8013bc:	5d                   	pop    %ebp
  8013bd:	c3                   	ret    

008013be <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
  8013c1:	56                   	push   %esi
  8013c2:	53                   	push   %ebx
  8013c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8013c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  8013cc:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8013ce:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  8013d3:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  8013d6:	83 ec 0c             	sub    $0xc,%esp
  8013d9:	50                   	push   %eax
  8013da:	e8 ba fe ff ff       	call   801299 <sys_ipc_recv>

	if (r < 0) {
  8013df:	83 c4 10             	add    $0x10,%esp
  8013e2:	85 c0                	test   %eax,%eax
  8013e4:	79 16                	jns    8013fc <ipc_recv+0x3e>
		if (from_env_store)
  8013e6:	85 f6                	test   %esi,%esi
  8013e8:	74 06                	je     8013f0 <ipc_recv+0x32>
			*from_env_store = 0;
  8013ea:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  8013f0:	85 db                	test   %ebx,%ebx
  8013f2:	74 2c                	je     801420 <ipc_recv+0x62>
			*perm_store = 0;
  8013f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8013fa:	eb 24                	jmp    801420 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  8013fc:	85 f6                	test   %esi,%esi
  8013fe:	74 0a                	je     80140a <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801400:	a1 08 50 80 00       	mov    0x805008,%eax
  801405:	8b 40 74             	mov    0x74(%eax),%eax
  801408:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  80140a:	85 db                	test   %ebx,%ebx
  80140c:	74 0a                	je     801418 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  80140e:	a1 08 50 80 00       	mov    0x805008,%eax
  801413:	8b 40 78             	mov    0x78(%eax),%eax
  801416:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801418:	a1 08 50 80 00       	mov    0x805008,%eax
  80141d:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801420:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801423:	5b                   	pop    %ebx
  801424:	5e                   	pop    %esi
  801425:	5d                   	pop    %ebp
  801426:	c3                   	ret    

00801427 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	57                   	push   %edi
  80142b:	56                   	push   %esi
  80142c:	53                   	push   %ebx
  80142d:	83 ec 0c             	sub    $0xc,%esp
  801430:	8b 7d 08             	mov    0x8(%ebp),%edi
  801433:	8b 75 0c             	mov    0xc(%ebp),%esi
  801436:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801439:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80143b:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801440:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801443:	ff 75 14             	pushl  0x14(%ebp)
  801446:	53                   	push   %ebx
  801447:	56                   	push   %esi
  801448:	57                   	push   %edi
  801449:	e8 28 fe ff ff       	call   801276 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  80144e:	83 c4 10             	add    $0x10,%esp
  801451:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801454:	75 07                	jne    80145d <ipc_send+0x36>
			sys_yield();
  801456:	e8 6f fc ff ff       	call   8010ca <sys_yield>
  80145b:	eb e6                	jmp    801443 <ipc_send+0x1c>
		} else if (r < 0) {
  80145d:	85 c0                	test   %eax,%eax
  80145f:	79 12                	jns    801473 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801461:	50                   	push   %eax
  801462:	68 2a 30 80 00       	push   $0x80302a
  801467:	6a 51                	push   $0x51
  801469:	68 37 30 80 00       	push   $0x803037
  80146e:	e8 15 f2 ff ff       	call   800688 <_panic>
		}
	}
}
  801473:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801476:	5b                   	pop    %ebx
  801477:	5e                   	pop    %esi
  801478:	5f                   	pop    %edi
  801479:	5d                   	pop    %ebp
  80147a:	c3                   	ret    

0080147b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801481:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801486:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801489:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80148f:	8b 52 50             	mov    0x50(%edx),%edx
  801492:	39 ca                	cmp    %ecx,%edx
  801494:	75 0d                	jne    8014a3 <ipc_find_env+0x28>
			return envs[i].env_id;
  801496:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801499:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80149e:	8b 40 48             	mov    0x48(%eax),%eax
  8014a1:	eb 0f                	jmp    8014b2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8014a3:	83 c0 01             	add    $0x1,%eax
  8014a6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8014ab:	75 d9                	jne    801486 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8014ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014b2:	5d                   	pop    %ebp
  8014b3:	c3                   	ret    

008014b4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014b4:	55                   	push   %ebp
  8014b5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ba:	05 00 00 00 30       	add    $0x30000000,%eax
  8014bf:	c1 e8 0c             	shr    $0xc,%eax
}
  8014c2:	5d                   	pop    %ebp
  8014c3:	c3                   	ret    

008014c4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014c4:	55                   	push   %ebp
  8014c5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8014c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ca:	05 00 00 00 30       	add    $0x30000000,%eax
  8014cf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014d4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014d9:	5d                   	pop    %ebp
  8014da:	c3                   	ret    

008014db <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014e1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014e6:	89 c2                	mov    %eax,%edx
  8014e8:	c1 ea 16             	shr    $0x16,%edx
  8014eb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014f2:	f6 c2 01             	test   $0x1,%dl
  8014f5:	74 11                	je     801508 <fd_alloc+0x2d>
  8014f7:	89 c2                	mov    %eax,%edx
  8014f9:	c1 ea 0c             	shr    $0xc,%edx
  8014fc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801503:	f6 c2 01             	test   $0x1,%dl
  801506:	75 09                	jne    801511 <fd_alloc+0x36>
			*fd_store = fd;
  801508:	89 01                	mov    %eax,(%ecx)
			return 0;
  80150a:	b8 00 00 00 00       	mov    $0x0,%eax
  80150f:	eb 17                	jmp    801528 <fd_alloc+0x4d>
  801511:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801516:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80151b:	75 c9                	jne    8014e6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80151d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801523:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801528:	5d                   	pop    %ebp
  801529:	c3                   	ret    

0080152a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801530:	83 f8 1f             	cmp    $0x1f,%eax
  801533:	77 36                	ja     80156b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801535:	c1 e0 0c             	shl    $0xc,%eax
  801538:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80153d:	89 c2                	mov    %eax,%edx
  80153f:	c1 ea 16             	shr    $0x16,%edx
  801542:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801549:	f6 c2 01             	test   $0x1,%dl
  80154c:	74 24                	je     801572 <fd_lookup+0x48>
  80154e:	89 c2                	mov    %eax,%edx
  801550:	c1 ea 0c             	shr    $0xc,%edx
  801553:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80155a:	f6 c2 01             	test   $0x1,%dl
  80155d:	74 1a                	je     801579 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80155f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801562:	89 02                	mov    %eax,(%edx)
	return 0;
  801564:	b8 00 00 00 00       	mov    $0x0,%eax
  801569:	eb 13                	jmp    80157e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80156b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801570:	eb 0c                	jmp    80157e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801572:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801577:	eb 05                	jmp    80157e <fd_lookup+0x54>
  801579:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80157e:	5d                   	pop    %ebp
  80157f:	c3                   	ret    

00801580 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	83 ec 08             	sub    $0x8,%esp
  801586:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801589:	ba c4 30 80 00       	mov    $0x8030c4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80158e:	eb 13                	jmp    8015a3 <dev_lookup+0x23>
  801590:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801593:	39 08                	cmp    %ecx,(%eax)
  801595:	75 0c                	jne    8015a3 <dev_lookup+0x23>
			*dev = devtab[i];
  801597:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80159a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80159c:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a1:	eb 2e                	jmp    8015d1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015a3:	8b 02                	mov    (%edx),%eax
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	75 e7                	jne    801590 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015a9:	a1 08 50 80 00       	mov    0x805008,%eax
  8015ae:	8b 40 48             	mov    0x48(%eax),%eax
  8015b1:	83 ec 04             	sub    $0x4,%esp
  8015b4:	51                   	push   %ecx
  8015b5:	50                   	push   %eax
  8015b6:	68 44 30 80 00       	push   $0x803044
  8015bb:	e8 a1 f1 ff ff       	call   800761 <cprintf>
	*dev = 0;
  8015c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015c9:	83 c4 10             	add    $0x10,%esp
  8015cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015d1:	c9                   	leave  
  8015d2:	c3                   	ret    

008015d3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015d3:	55                   	push   %ebp
  8015d4:	89 e5                	mov    %esp,%ebp
  8015d6:	56                   	push   %esi
  8015d7:	53                   	push   %ebx
  8015d8:	83 ec 10             	sub    $0x10,%esp
  8015db:	8b 75 08             	mov    0x8(%ebp),%esi
  8015de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e4:	50                   	push   %eax
  8015e5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015eb:	c1 e8 0c             	shr    $0xc,%eax
  8015ee:	50                   	push   %eax
  8015ef:	e8 36 ff ff ff       	call   80152a <fd_lookup>
  8015f4:	83 c4 08             	add    $0x8,%esp
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	78 05                	js     801600 <fd_close+0x2d>
	    || fd != fd2)
  8015fb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015fe:	74 0c                	je     80160c <fd_close+0x39>
		return (must_exist ? r : 0);
  801600:	84 db                	test   %bl,%bl
  801602:	ba 00 00 00 00       	mov    $0x0,%edx
  801607:	0f 44 c2             	cmove  %edx,%eax
  80160a:	eb 41                	jmp    80164d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80160c:	83 ec 08             	sub    $0x8,%esp
  80160f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801612:	50                   	push   %eax
  801613:	ff 36                	pushl  (%esi)
  801615:	e8 66 ff ff ff       	call   801580 <dev_lookup>
  80161a:	89 c3                	mov    %eax,%ebx
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	85 c0                	test   %eax,%eax
  801621:	78 1a                	js     80163d <fd_close+0x6a>
		if (dev->dev_close)
  801623:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801626:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801629:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80162e:	85 c0                	test   %eax,%eax
  801630:	74 0b                	je     80163d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801632:	83 ec 0c             	sub    $0xc,%esp
  801635:	56                   	push   %esi
  801636:	ff d0                	call   *%eax
  801638:	89 c3                	mov    %eax,%ebx
  80163a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80163d:	83 ec 08             	sub    $0x8,%esp
  801640:	56                   	push   %esi
  801641:	6a 00                	push   $0x0
  801643:	e8 26 fb ff ff       	call   80116e <sys_page_unmap>
	return r;
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	89 d8                	mov    %ebx,%eax
}
  80164d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801650:	5b                   	pop    %ebx
  801651:	5e                   	pop    %esi
  801652:	5d                   	pop    %ebp
  801653:	c3                   	ret    

00801654 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80165a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165d:	50                   	push   %eax
  80165e:	ff 75 08             	pushl  0x8(%ebp)
  801661:	e8 c4 fe ff ff       	call   80152a <fd_lookup>
  801666:	83 c4 08             	add    $0x8,%esp
  801669:	85 c0                	test   %eax,%eax
  80166b:	78 10                	js     80167d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80166d:	83 ec 08             	sub    $0x8,%esp
  801670:	6a 01                	push   $0x1
  801672:	ff 75 f4             	pushl  -0xc(%ebp)
  801675:	e8 59 ff ff ff       	call   8015d3 <fd_close>
  80167a:	83 c4 10             	add    $0x10,%esp
}
  80167d:	c9                   	leave  
  80167e:	c3                   	ret    

0080167f <close_all>:

void
close_all(void)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	53                   	push   %ebx
  801683:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801686:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80168b:	83 ec 0c             	sub    $0xc,%esp
  80168e:	53                   	push   %ebx
  80168f:	e8 c0 ff ff ff       	call   801654 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801694:	83 c3 01             	add    $0x1,%ebx
  801697:	83 c4 10             	add    $0x10,%esp
  80169a:	83 fb 20             	cmp    $0x20,%ebx
  80169d:	75 ec                	jne    80168b <close_all+0xc>
		close(i);
}
  80169f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a2:	c9                   	leave  
  8016a3:	c3                   	ret    

008016a4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	57                   	push   %edi
  8016a8:	56                   	push   %esi
  8016a9:	53                   	push   %ebx
  8016aa:	83 ec 2c             	sub    $0x2c,%esp
  8016ad:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016b0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016b3:	50                   	push   %eax
  8016b4:	ff 75 08             	pushl  0x8(%ebp)
  8016b7:	e8 6e fe ff ff       	call   80152a <fd_lookup>
  8016bc:	83 c4 08             	add    $0x8,%esp
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	0f 88 c1 00 00 00    	js     801788 <dup+0xe4>
		return r;
	close(newfdnum);
  8016c7:	83 ec 0c             	sub    $0xc,%esp
  8016ca:	56                   	push   %esi
  8016cb:	e8 84 ff ff ff       	call   801654 <close>

	newfd = INDEX2FD(newfdnum);
  8016d0:	89 f3                	mov    %esi,%ebx
  8016d2:	c1 e3 0c             	shl    $0xc,%ebx
  8016d5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8016db:	83 c4 04             	add    $0x4,%esp
  8016de:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016e1:	e8 de fd ff ff       	call   8014c4 <fd2data>
  8016e6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8016e8:	89 1c 24             	mov    %ebx,(%esp)
  8016eb:	e8 d4 fd ff ff       	call   8014c4 <fd2data>
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016f6:	89 f8                	mov    %edi,%eax
  8016f8:	c1 e8 16             	shr    $0x16,%eax
  8016fb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801702:	a8 01                	test   $0x1,%al
  801704:	74 37                	je     80173d <dup+0x99>
  801706:	89 f8                	mov    %edi,%eax
  801708:	c1 e8 0c             	shr    $0xc,%eax
  80170b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801712:	f6 c2 01             	test   $0x1,%dl
  801715:	74 26                	je     80173d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801717:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80171e:	83 ec 0c             	sub    $0xc,%esp
  801721:	25 07 0e 00 00       	and    $0xe07,%eax
  801726:	50                   	push   %eax
  801727:	ff 75 d4             	pushl  -0x2c(%ebp)
  80172a:	6a 00                	push   $0x0
  80172c:	57                   	push   %edi
  80172d:	6a 00                	push   $0x0
  80172f:	e8 f8 f9 ff ff       	call   80112c <sys_page_map>
  801734:	89 c7                	mov    %eax,%edi
  801736:	83 c4 20             	add    $0x20,%esp
  801739:	85 c0                	test   %eax,%eax
  80173b:	78 2e                	js     80176b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80173d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801740:	89 d0                	mov    %edx,%eax
  801742:	c1 e8 0c             	shr    $0xc,%eax
  801745:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80174c:	83 ec 0c             	sub    $0xc,%esp
  80174f:	25 07 0e 00 00       	and    $0xe07,%eax
  801754:	50                   	push   %eax
  801755:	53                   	push   %ebx
  801756:	6a 00                	push   $0x0
  801758:	52                   	push   %edx
  801759:	6a 00                	push   $0x0
  80175b:	e8 cc f9 ff ff       	call   80112c <sys_page_map>
  801760:	89 c7                	mov    %eax,%edi
  801762:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801765:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801767:	85 ff                	test   %edi,%edi
  801769:	79 1d                	jns    801788 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80176b:	83 ec 08             	sub    $0x8,%esp
  80176e:	53                   	push   %ebx
  80176f:	6a 00                	push   $0x0
  801771:	e8 f8 f9 ff ff       	call   80116e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801776:	83 c4 08             	add    $0x8,%esp
  801779:	ff 75 d4             	pushl  -0x2c(%ebp)
  80177c:	6a 00                	push   $0x0
  80177e:	e8 eb f9 ff ff       	call   80116e <sys_page_unmap>
	return r;
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	89 f8                	mov    %edi,%eax
}
  801788:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80178b:	5b                   	pop    %ebx
  80178c:	5e                   	pop    %esi
  80178d:	5f                   	pop    %edi
  80178e:	5d                   	pop    %ebp
  80178f:	c3                   	ret    

00801790 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
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
  80179f:	e8 86 fd ff ff       	call   80152a <fd_lookup>
  8017a4:	83 c4 08             	add    $0x8,%esp
  8017a7:	89 c2                	mov    %eax,%edx
  8017a9:	85 c0                	test   %eax,%eax
  8017ab:	78 6d                	js     80181a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ad:	83 ec 08             	sub    $0x8,%esp
  8017b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b3:	50                   	push   %eax
  8017b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b7:	ff 30                	pushl  (%eax)
  8017b9:	e8 c2 fd ff ff       	call   801580 <dev_lookup>
  8017be:	83 c4 10             	add    $0x10,%esp
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	78 4c                	js     801811 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017c5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017c8:	8b 42 08             	mov    0x8(%edx),%eax
  8017cb:	83 e0 03             	and    $0x3,%eax
  8017ce:	83 f8 01             	cmp    $0x1,%eax
  8017d1:	75 21                	jne    8017f4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017d3:	a1 08 50 80 00       	mov    0x805008,%eax
  8017d8:	8b 40 48             	mov    0x48(%eax),%eax
  8017db:	83 ec 04             	sub    $0x4,%esp
  8017de:	53                   	push   %ebx
  8017df:	50                   	push   %eax
  8017e0:	68 88 30 80 00       	push   $0x803088
  8017e5:	e8 77 ef ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  8017ea:	83 c4 10             	add    $0x10,%esp
  8017ed:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017f2:	eb 26                	jmp    80181a <read+0x8a>
	}
	if (!dev->dev_read)
  8017f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f7:	8b 40 08             	mov    0x8(%eax),%eax
  8017fa:	85 c0                	test   %eax,%eax
  8017fc:	74 17                	je     801815 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017fe:	83 ec 04             	sub    $0x4,%esp
  801801:	ff 75 10             	pushl  0x10(%ebp)
  801804:	ff 75 0c             	pushl  0xc(%ebp)
  801807:	52                   	push   %edx
  801808:	ff d0                	call   *%eax
  80180a:	89 c2                	mov    %eax,%edx
  80180c:	83 c4 10             	add    $0x10,%esp
  80180f:	eb 09                	jmp    80181a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801811:	89 c2                	mov    %eax,%edx
  801813:	eb 05                	jmp    80181a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801815:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80181a:	89 d0                	mov    %edx,%eax
  80181c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181f:	c9                   	leave  
  801820:	c3                   	ret    

00801821 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	57                   	push   %edi
  801825:	56                   	push   %esi
  801826:	53                   	push   %ebx
  801827:	83 ec 0c             	sub    $0xc,%esp
  80182a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80182d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801830:	bb 00 00 00 00       	mov    $0x0,%ebx
  801835:	eb 21                	jmp    801858 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801837:	83 ec 04             	sub    $0x4,%esp
  80183a:	89 f0                	mov    %esi,%eax
  80183c:	29 d8                	sub    %ebx,%eax
  80183e:	50                   	push   %eax
  80183f:	89 d8                	mov    %ebx,%eax
  801841:	03 45 0c             	add    0xc(%ebp),%eax
  801844:	50                   	push   %eax
  801845:	57                   	push   %edi
  801846:	e8 45 ff ff ff       	call   801790 <read>
		if (m < 0)
  80184b:	83 c4 10             	add    $0x10,%esp
  80184e:	85 c0                	test   %eax,%eax
  801850:	78 10                	js     801862 <readn+0x41>
			return m;
		if (m == 0)
  801852:	85 c0                	test   %eax,%eax
  801854:	74 0a                	je     801860 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801856:	01 c3                	add    %eax,%ebx
  801858:	39 f3                	cmp    %esi,%ebx
  80185a:	72 db                	jb     801837 <readn+0x16>
  80185c:	89 d8                	mov    %ebx,%eax
  80185e:	eb 02                	jmp    801862 <readn+0x41>
  801860:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801862:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801865:	5b                   	pop    %ebx
  801866:	5e                   	pop    %esi
  801867:	5f                   	pop    %edi
  801868:	5d                   	pop    %ebp
  801869:	c3                   	ret    

0080186a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	53                   	push   %ebx
  80186e:	83 ec 14             	sub    $0x14,%esp
  801871:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801874:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801877:	50                   	push   %eax
  801878:	53                   	push   %ebx
  801879:	e8 ac fc ff ff       	call   80152a <fd_lookup>
  80187e:	83 c4 08             	add    $0x8,%esp
  801881:	89 c2                	mov    %eax,%edx
  801883:	85 c0                	test   %eax,%eax
  801885:	78 68                	js     8018ef <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801887:	83 ec 08             	sub    $0x8,%esp
  80188a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188d:	50                   	push   %eax
  80188e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801891:	ff 30                	pushl  (%eax)
  801893:	e8 e8 fc ff ff       	call   801580 <dev_lookup>
  801898:	83 c4 10             	add    $0x10,%esp
  80189b:	85 c0                	test   %eax,%eax
  80189d:	78 47                	js     8018e6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80189f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018a6:	75 21                	jne    8018c9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018a8:	a1 08 50 80 00       	mov    0x805008,%eax
  8018ad:	8b 40 48             	mov    0x48(%eax),%eax
  8018b0:	83 ec 04             	sub    $0x4,%esp
  8018b3:	53                   	push   %ebx
  8018b4:	50                   	push   %eax
  8018b5:	68 a4 30 80 00       	push   $0x8030a4
  8018ba:	e8 a2 ee ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  8018bf:	83 c4 10             	add    $0x10,%esp
  8018c2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018c7:	eb 26                	jmp    8018ef <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018cc:	8b 52 0c             	mov    0xc(%edx),%edx
  8018cf:	85 d2                	test   %edx,%edx
  8018d1:	74 17                	je     8018ea <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018d3:	83 ec 04             	sub    $0x4,%esp
  8018d6:	ff 75 10             	pushl  0x10(%ebp)
  8018d9:	ff 75 0c             	pushl  0xc(%ebp)
  8018dc:	50                   	push   %eax
  8018dd:	ff d2                	call   *%edx
  8018df:	89 c2                	mov    %eax,%edx
  8018e1:	83 c4 10             	add    $0x10,%esp
  8018e4:	eb 09                	jmp    8018ef <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018e6:	89 c2                	mov    %eax,%edx
  8018e8:	eb 05                	jmp    8018ef <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018ea:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8018ef:	89 d0                	mov    %edx,%eax
  8018f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f4:	c9                   	leave  
  8018f5:	c3                   	ret    

008018f6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018f6:	55                   	push   %ebp
  8018f7:	89 e5                	mov    %esp,%ebp
  8018f9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018fc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018ff:	50                   	push   %eax
  801900:	ff 75 08             	pushl  0x8(%ebp)
  801903:	e8 22 fc ff ff       	call   80152a <fd_lookup>
  801908:	83 c4 08             	add    $0x8,%esp
  80190b:	85 c0                	test   %eax,%eax
  80190d:	78 0e                	js     80191d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80190f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801912:	8b 55 0c             	mov    0xc(%ebp),%edx
  801915:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801918:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80191d:	c9                   	leave  
  80191e:	c3                   	ret    

0080191f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	53                   	push   %ebx
  801923:	83 ec 14             	sub    $0x14,%esp
  801926:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801929:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80192c:	50                   	push   %eax
  80192d:	53                   	push   %ebx
  80192e:	e8 f7 fb ff ff       	call   80152a <fd_lookup>
  801933:	83 c4 08             	add    $0x8,%esp
  801936:	89 c2                	mov    %eax,%edx
  801938:	85 c0                	test   %eax,%eax
  80193a:	78 65                	js     8019a1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80193c:	83 ec 08             	sub    $0x8,%esp
  80193f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801942:	50                   	push   %eax
  801943:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801946:	ff 30                	pushl  (%eax)
  801948:	e8 33 fc ff ff       	call   801580 <dev_lookup>
  80194d:	83 c4 10             	add    $0x10,%esp
  801950:	85 c0                	test   %eax,%eax
  801952:	78 44                	js     801998 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801954:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801957:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80195b:	75 21                	jne    80197e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80195d:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801962:	8b 40 48             	mov    0x48(%eax),%eax
  801965:	83 ec 04             	sub    $0x4,%esp
  801968:	53                   	push   %ebx
  801969:	50                   	push   %eax
  80196a:	68 64 30 80 00       	push   $0x803064
  80196f:	e8 ed ed ff ff       	call   800761 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80197c:	eb 23                	jmp    8019a1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80197e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801981:	8b 52 18             	mov    0x18(%edx),%edx
  801984:	85 d2                	test   %edx,%edx
  801986:	74 14                	je     80199c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801988:	83 ec 08             	sub    $0x8,%esp
  80198b:	ff 75 0c             	pushl  0xc(%ebp)
  80198e:	50                   	push   %eax
  80198f:	ff d2                	call   *%edx
  801991:	89 c2                	mov    %eax,%edx
  801993:	83 c4 10             	add    $0x10,%esp
  801996:	eb 09                	jmp    8019a1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801998:	89 c2                	mov    %eax,%edx
  80199a:	eb 05                	jmp    8019a1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80199c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8019a1:	89 d0                	mov    %edx,%eax
  8019a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a6:	c9                   	leave  
  8019a7:	c3                   	ret    

008019a8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	53                   	push   %ebx
  8019ac:	83 ec 14             	sub    $0x14,%esp
  8019af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019b5:	50                   	push   %eax
  8019b6:	ff 75 08             	pushl  0x8(%ebp)
  8019b9:	e8 6c fb ff ff       	call   80152a <fd_lookup>
  8019be:	83 c4 08             	add    $0x8,%esp
  8019c1:	89 c2                	mov    %eax,%edx
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	78 58                	js     801a1f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019c7:	83 ec 08             	sub    $0x8,%esp
  8019ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019cd:	50                   	push   %eax
  8019ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019d1:	ff 30                	pushl  (%eax)
  8019d3:	e8 a8 fb ff ff       	call   801580 <dev_lookup>
  8019d8:	83 c4 10             	add    $0x10,%esp
  8019db:	85 c0                	test   %eax,%eax
  8019dd:	78 37                	js     801a16 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8019df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019e6:	74 32                	je     801a1a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019e8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019eb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019f2:	00 00 00 
	stat->st_isdir = 0;
  8019f5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019fc:	00 00 00 
	stat->st_dev = dev;
  8019ff:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a05:	83 ec 08             	sub    $0x8,%esp
  801a08:	53                   	push   %ebx
  801a09:	ff 75 f0             	pushl  -0x10(%ebp)
  801a0c:	ff 50 14             	call   *0x14(%eax)
  801a0f:	89 c2                	mov    %eax,%edx
  801a11:	83 c4 10             	add    $0x10,%esp
  801a14:	eb 09                	jmp    801a1f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a16:	89 c2                	mov    %eax,%edx
  801a18:	eb 05                	jmp    801a1f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a1a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a1f:	89 d0                	mov    %edx,%eax
  801a21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a24:	c9                   	leave  
  801a25:	c3                   	ret    

00801a26 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a26:	55                   	push   %ebp
  801a27:	89 e5                	mov    %esp,%ebp
  801a29:	56                   	push   %esi
  801a2a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a2b:	83 ec 08             	sub    $0x8,%esp
  801a2e:	6a 00                	push   $0x0
  801a30:	ff 75 08             	pushl  0x8(%ebp)
  801a33:	e8 0c 02 00 00       	call   801c44 <open>
  801a38:	89 c3                	mov    %eax,%ebx
  801a3a:	83 c4 10             	add    $0x10,%esp
  801a3d:	85 c0                	test   %eax,%eax
  801a3f:	78 1b                	js     801a5c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a41:	83 ec 08             	sub    $0x8,%esp
  801a44:	ff 75 0c             	pushl  0xc(%ebp)
  801a47:	50                   	push   %eax
  801a48:	e8 5b ff ff ff       	call   8019a8 <fstat>
  801a4d:	89 c6                	mov    %eax,%esi
	close(fd);
  801a4f:	89 1c 24             	mov    %ebx,(%esp)
  801a52:	e8 fd fb ff ff       	call   801654 <close>
	return r;
  801a57:	83 c4 10             	add    $0x10,%esp
  801a5a:	89 f0                	mov    %esi,%eax
}
  801a5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a5f:	5b                   	pop    %ebx
  801a60:	5e                   	pop    %esi
  801a61:	5d                   	pop    %ebp
  801a62:	c3                   	ret    

00801a63 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
  801a66:	56                   	push   %esi
  801a67:	53                   	push   %ebx
  801a68:	89 c6                	mov    %eax,%esi
  801a6a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a6c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801a73:	75 12                	jne    801a87 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a75:	83 ec 0c             	sub    $0xc,%esp
  801a78:	6a 01                	push   $0x1
  801a7a:	e8 fc f9 ff ff       	call   80147b <ipc_find_env>
  801a7f:	a3 00 50 80 00       	mov    %eax,0x805000
  801a84:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a87:	6a 07                	push   $0x7
  801a89:	68 00 60 80 00       	push   $0x806000
  801a8e:	56                   	push   %esi
  801a8f:	ff 35 00 50 80 00    	pushl  0x805000
  801a95:	e8 8d f9 ff ff       	call   801427 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a9a:	83 c4 0c             	add    $0xc,%esp
  801a9d:	6a 00                	push   $0x0
  801a9f:	53                   	push   %ebx
  801aa0:	6a 00                	push   $0x0
  801aa2:	e8 17 f9 ff ff       	call   8013be <ipc_recv>
}
  801aa7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aaa:	5b                   	pop    %ebx
  801aab:	5e                   	pop    %esi
  801aac:	5d                   	pop    %ebp
  801aad:	c3                   	ret    

00801aae <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab7:	8b 40 0c             	mov    0xc(%eax),%eax
  801aba:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801abf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac2:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ac7:	ba 00 00 00 00       	mov    $0x0,%edx
  801acc:	b8 02 00 00 00       	mov    $0x2,%eax
  801ad1:	e8 8d ff ff ff       	call   801a63 <fsipc>
}
  801ad6:	c9                   	leave  
  801ad7:	c3                   	ret    

00801ad8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ade:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae1:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae4:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801ae9:	ba 00 00 00 00       	mov    $0x0,%edx
  801aee:	b8 06 00 00 00       	mov    $0x6,%eax
  801af3:	e8 6b ff ff ff       	call   801a63 <fsipc>
}
  801af8:	c9                   	leave  
  801af9:	c3                   	ret    

00801afa <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	53                   	push   %ebx
  801afe:	83 ec 04             	sub    $0x4,%esp
  801b01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b04:	8b 45 08             	mov    0x8(%ebp),%eax
  801b07:	8b 40 0c             	mov    0xc(%eax),%eax
  801b0a:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b0f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b14:	b8 05 00 00 00       	mov    $0x5,%eax
  801b19:	e8 45 ff ff ff       	call   801a63 <fsipc>
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	78 2c                	js     801b4e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b22:	83 ec 08             	sub    $0x8,%esp
  801b25:	68 00 60 80 00       	push   $0x806000
  801b2a:	53                   	push   %ebx
  801b2b:	e8 b6 f1 ff ff       	call   800ce6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b30:	a1 80 60 80 00       	mov    0x806080,%eax
  801b35:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b3b:	a1 84 60 80 00       	mov    0x806084,%eax
  801b40:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b46:	83 c4 10             	add    $0x10,%esp
  801b49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b51:	c9                   	leave  
  801b52:	c3                   	ret    

00801b53 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	53                   	push   %ebx
  801b57:	83 ec 08             	sub    $0x8,%esp
  801b5a:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b5d:	8b 55 08             	mov    0x8(%ebp),%edx
  801b60:	8b 52 0c             	mov    0xc(%edx),%edx
  801b63:	89 15 00 60 80 00    	mov    %edx,0x806000
  801b69:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b6e:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801b73:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  801b76:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801b7c:	53                   	push   %ebx
  801b7d:	ff 75 0c             	pushl  0xc(%ebp)
  801b80:	68 08 60 80 00       	push   $0x806008
  801b85:	e8 ee f2 ff ff       	call   800e78 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  801b8a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b8f:	b8 04 00 00 00       	mov    $0x4,%eax
  801b94:	e8 ca fe ff ff       	call   801a63 <fsipc>
  801b99:	83 c4 10             	add    $0x10,%esp
  801b9c:	85 c0                	test   %eax,%eax
  801b9e:	78 1d                	js     801bbd <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  801ba0:	39 d8                	cmp    %ebx,%eax
  801ba2:	76 19                	jbe    801bbd <devfile_write+0x6a>
  801ba4:	68 d8 30 80 00       	push   $0x8030d8
  801ba9:	68 e4 30 80 00       	push   $0x8030e4
  801bae:	68 a5 00 00 00       	push   $0xa5
  801bb3:	68 f9 30 80 00       	push   $0x8030f9
  801bb8:	e8 cb ea ff ff       	call   800688 <_panic>
	return r;
}
  801bbd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc0:	c9                   	leave  
  801bc1:	c3                   	ret    

00801bc2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bc2:	55                   	push   %ebp
  801bc3:	89 e5                	mov    %esp,%ebp
  801bc5:	56                   	push   %esi
  801bc6:	53                   	push   %ebx
  801bc7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bca:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcd:	8b 40 0c             	mov    0xc(%eax),%eax
  801bd0:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801bd5:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bdb:	ba 00 00 00 00       	mov    $0x0,%edx
  801be0:	b8 03 00 00 00       	mov    $0x3,%eax
  801be5:	e8 79 fe ff ff       	call   801a63 <fsipc>
  801bea:	89 c3                	mov    %eax,%ebx
  801bec:	85 c0                	test   %eax,%eax
  801bee:	78 4b                	js     801c3b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801bf0:	39 c6                	cmp    %eax,%esi
  801bf2:	73 16                	jae    801c0a <devfile_read+0x48>
  801bf4:	68 04 31 80 00       	push   $0x803104
  801bf9:	68 e4 30 80 00       	push   $0x8030e4
  801bfe:	6a 7c                	push   $0x7c
  801c00:	68 f9 30 80 00       	push   $0x8030f9
  801c05:	e8 7e ea ff ff       	call   800688 <_panic>
	assert(r <= PGSIZE);
  801c0a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c0f:	7e 16                	jle    801c27 <devfile_read+0x65>
  801c11:	68 0b 31 80 00       	push   $0x80310b
  801c16:	68 e4 30 80 00       	push   $0x8030e4
  801c1b:	6a 7d                	push   $0x7d
  801c1d:	68 f9 30 80 00       	push   $0x8030f9
  801c22:	e8 61 ea ff ff       	call   800688 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c27:	83 ec 04             	sub    $0x4,%esp
  801c2a:	50                   	push   %eax
  801c2b:	68 00 60 80 00       	push   $0x806000
  801c30:	ff 75 0c             	pushl  0xc(%ebp)
  801c33:	e8 40 f2 ff ff       	call   800e78 <memmove>
	return r;
  801c38:	83 c4 10             	add    $0x10,%esp
}
  801c3b:	89 d8                	mov    %ebx,%eax
  801c3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c40:	5b                   	pop    %ebx
  801c41:	5e                   	pop    %esi
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    

00801c44 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
  801c47:	53                   	push   %ebx
  801c48:	83 ec 20             	sub    $0x20,%esp
  801c4b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c4e:	53                   	push   %ebx
  801c4f:	e8 59 f0 ff ff       	call   800cad <strlen>
  801c54:	83 c4 10             	add    $0x10,%esp
  801c57:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c5c:	7f 67                	jg     801cc5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c5e:	83 ec 0c             	sub    $0xc,%esp
  801c61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c64:	50                   	push   %eax
  801c65:	e8 71 f8 ff ff       	call   8014db <fd_alloc>
  801c6a:	83 c4 10             	add    $0x10,%esp
		return r;
  801c6d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	78 57                	js     801cca <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c73:	83 ec 08             	sub    $0x8,%esp
  801c76:	53                   	push   %ebx
  801c77:	68 00 60 80 00       	push   $0x806000
  801c7c:	e8 65 f0 ff ff       	call   800ce6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c81:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c84:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c89:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c8c:	b8 01 00 00 00       	mov    $0x1,%eax
  801c91:	e8 cd fd ff ff       	call   801a63 <fsipc>
  801c96:	89 c3                	mov    %eax,%ebx
  801c98:	83 c4 10             	add    $0x10,%esp
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	79 14                	jns    801cb3 <open+0x6f>
		fd_close(fd, 0);
  801c9f:	83 ec 08             	sub    $0x8,%esp
  801ca2:	6a 00                	push   $0x0
  801ca4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca7:	e8 27 f9 ff ff       	call   8015d3 <fd_close>
		return r;
  801cac:	83 c4 10             	add    $0x10,%esp
  801caf:	89 da                	mov    %ebx,%edx
  801cb1:	eb 17                	jmp    801cca <open+0x86>
	}

	return fd2num(fd);
  801cb3:	83 ec 0c             	sub    $0xc,%esp
  801cb6:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb9:	e8 f6 f7 ff ff       	call   8014b4 <fd2num>
  801cbe:	89 c2                	mov    %eax,%edx
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	eb 05                	jmp    801cca <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801cc5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801cca:	89 d0                	mov    %edx,%eax
  801ccc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ccf:	c9                   	leave  
  801cd0:	c3                   	ret    

00801cd1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801cd1:	55                   	push   %ebp
  801cd2:	89 e5                	mov    %esp,%ebp
  801cd4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cd7:	ba 00 00 00 00       	mov    $0x0,%edx
  801cdc:	b8 08 00 00 00       	mov    $0x8,%eax
  801ce1:	e8 7d fd ff ff       	call   801a63 <fsipc>
}
  801ce6:	c9                   	leave  
  801ce7:	c3                   	ret    

00801ce8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801cee:	68 17 31 80 00       	push   $0x803117
  801cf3:	ff 75 0c             	pushl  0xc(%ebp)
  801cf6:	e8 eb ef ff ff       	call   800ce6 <strcpy>
	return 0;
}
  801cfb:	b8 00 00 00 00       	mov    $0x0,%eax
  801d00:	c9                   	leave  
  801d01:	c3                   	ret    

00801d02 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801d02:	55                   	push   %ebp
  801d03:	89 e5                	mov    %esp,%ebp
  801d05:	53                   	push   %ebx
  801d06:	83 ec 10             	sub    $0x10,%esp
  801d09:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d0c:	53                   	push   %ebx
  801d0d:	e8 1c 09 00 00       	call   80262e <pageref>
  801d12:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801d15:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801d1a:	83 f8 01             	cmp    $0x1,%eax
  801d1d:	75 10                	jne    801d2f <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801d1f:	83 ec 0c             	sub    $0xc,%esp
  801d22:	ff 73 0c             	pushl  0xc(%ebx)
  801d25:	e8 c0 02 00 00       	call   801fea <nsipc_close>
  801d2a:	89 c2                	mov    %eax,%edx
  801d2c:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801d2f:	89 d0                	mov    %edx,%eax
  801d31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d34:	c9                   	leave  
  801d35:	c3                   	ret    

00801d36 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801d36:	55                   	push   %ebp
  801d37:	89 e5                	mov    %esp,%ebp
  801d39:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d3c:	6a 00                	push   $0x0
  801d3e:	ff 75 10             	pushl  0x10(%ebp)
  801d41:	ff 75 0c             	pushl  0xc(%ebp)
  801d44:	8b 45 08             	mov    0x8(%ebp),%eax
  801d47:	ff 70 0c             	pushl  0xc(%eax)
  801d4a:	e8 78 03 00 00       	call   8020c7 <nsipc_send>
}
  801d4f:	c9                   	leave  
  801d50:	c3                   	ret    

00801d51 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
  801d54:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d57:	6a 00                	push   $0x0
  801d59:	ff 75 10             	pushl  0x10(%ebp)
  801d5c:	ff 75 0c             	pushl  0xc(%ebp)
  801d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d62:	ff 70 0c             	pushl  0xc(%eax)
  801d65:	e8 f1 02 00 00       	call   80205b <nsipc_recv>
}
  801d6a:	c9                   	leave  
  801d6b:	c3                   	ret    

00801d6c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d72:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d75:	52                   	push   %edx
  801d76:	50                   	push   %eax
  801d77:	e8 ae f7 ff ff       	call   80152a <fd_lookup>
  801d7c:	83 c4 10             	add    $0x10,%esp
  801d7f:	85 c0                	test   %eax,%eax
  801d81:	78 17                	js     801d9a <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d86:	8b 0d 24 40 80 00    	mov    0x804024,%ecx
  801d8c:	39 08                	cmp    %ecx,(%eax)
  801d8e:	75 05                	jne    801d95 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d90:	8b 40 0c             	mov    0xc(%eax),%eax
  801d93:	eb 05                	jmp    801d9a <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d95:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d9a:	c9                   	leave  
  801d9b:	c3                   	ret    

00801d9c <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801d9c:	55                   	push   %ebp
  801d9d:	89 e5                	mov    %esp,%ebp
  801d9f:	56                   	push   %esi
  801da0:	53                   	push   %ebx
  801da1:	83 ec 1c             	sub    $0x1c,%esp
  801da4:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801da6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da9:	50                   	push   %eax
  801daa:	e8 2c f7 ff ff       	call   8014db <fd_alloc>
  801daf:	89 c3                	mov    %eax,%ebx
  801db1:	83 c4 10             	add    $0x10,%esp
  801db4:	85 c0                	test   %eax,%eax
  801db6:	78 1b                	js     801dd3 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801db8:	83 ec 04             	sub    $0x4,%esp
  801dbb:	68 07 04 00 00       	push   $0x407
  801dc0:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc3:	6a 00                	push   $0x0
  801dc5:	e8 1f f3 ff ff       	call   8010e9 <sys_page_alloc>
  801dca:	89 c3                	mov    %eax,%ebx
  801dcc:	83 c4 10             	add    $0x10,%esp
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	79 10                	jns    801de3 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801dd3:	83 ec 0c             	sub    $0xc,%esp
  801dd6:	56                   	push   %esi
  801dd7:	e8 0e 02 00 00       	call   801fea <nsipc_close>
		return r;
  801ddc:	83 c4 10             	add    $0x10,%esp
  801ddf:	89 d8                	mov    %ebx,%eax
  801de1:	eb 24                	jmp    801e07 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801de3:	8b 15 24 40 80 00    	mov    0x804024,%edx
  801de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dec:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801df8:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801dfb:	83 ec 0c             	sub    $0xc,%esp
  801dfe:	50                   	push   %eax
  801dff:	e8 b0 f6 ff ff       	call   8014b4 <fd2num>
  801e04:	83 c4 10             	add    $0x10,%esp
}
  801e07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e0a:	5b                   	pop    %ebx
  801e0b:	5e                   	pop    %esi
  801e0c:	5d                   	pop    %ebp
  801e0d:	c3                   	ret    

00801e0e <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
  801e11:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e14:	8b 45 08             	mov    0x8(%ebp),%eax
  801e17:	e8 50 ff ff ff       	call   801d6c <fd2sockid>
		return r;
  801e1c:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e1e:	85 c0                	test   %eax,%eax
  801e20:	78 1f                	js     801e41 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e22:	83 ec 04             	sub    $0x4,%esp
  801e25:	ff 75 10             	pushl  0x10(%ebp)
  801e28:	ff 75 0c             	pushl  0xc(%ebp)
  801e2b:	50                   	push   %eax
  801e2c:	e8 12 01 00 00       	call   801f43 <nsipc_accept>
  801e31:	83 c4 10             	add    $0x10,%esp
		return r;
  801e34:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e36:	85 c0                	test   %eax,%eax
  801e38:	78 07                	js     801e41 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801e3a:	e8 5d ff ff ff       	call   801d9c <alloc_sockfd>
  801e3f:	89 c1                	mov    %eax,%ecx
}
  801e41:	89 c8                	mov    %ecx,%eax
  801e43:	c9                   	leave  
  801e44:	c3                   	ret    

00801e45 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e45:	55                   	push   %ebp
  801e46:	89 e5                	mov    %esp,%ebp
  801e48:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4e:	e8 19 ff ff ff       	call   801d6c <fd2sockid>
  801e53:	85 c0                	test   %eax,%eax
  801e55:	78 12                	js     801e69 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801e57:	83 ec 04             	sub    $0x4,%esp
  801e5a:	ff 75 10             	pushl  0x10(%ebp)
  801e5d:	ff 75 0c             	pushl  0xc(%ebp)
  801e60:	50                   	push   %eax
  801e61:	e8 2d 01 00 00       	call   801f93 <nsipc_bind>
  801e66:	83 c4 10             	add    $0x10,%esp
}
  801e69:	c9                   	leave  
  801e6a:	c3                   	ret    

00801e6b <shutdown>:

int
shutdown(int s, int how)
{
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e71:	8b 45 08             	mov    0x8(%ebp),%eax
  801e74:	e8 f3 fe ff ff       	call   801d6c <fd2sockid>
  801e79:	85 c0                	test   %eax,%eax
  801e7b:	78 0f                	js     801e8c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801e7d:	83 ec 08             	sub    $0x8,%esp
  801e80:	ff 75 0c             	pushl  0xc(%ebp)
  801e83:	50                   	push   %eax
  801e84:	e8 3f 01 00 00       	call   801fc8 <nsipc_shutdown>
  801e89:	83 c4 10             	add    $0x10,%esp
}
  801e8c:	c9                   	leave  
  801e8d:	c3                   	ret    

00801e8e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e8e:	55                   	push   %ebp
  801e8f:	89 e5                	mov    %esp,%ebp
  801e91:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e94:	8b 45 08             	mov    0x8(%ebp),%eax
  801e97:	e8 d0 fe ff ff       	call   801d6c <fd2sockid>
  801e9c:	85 c0                	test   %eax,%eax
  801e9e:	78 12                	js     801eb2 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801ea0:	83 ec 04             	sub    $0x4,%esp
  801ea3:	ff 75 10             	pushl  0x10(%ebp)
  801ea6:	ff 75 0c             	pushl  0xc(%ebp)
  801ea9:	50                   	push   %eax
  801eaa:	e8 55 01 00 00       	call   802004 <nsipc_connect>
  801eaf:	83 c4 10             	add    $0x10,%esp
}
  801eb2:	c9                   	leave  
  801eb3:	c3                   	ret    

00801eb4 <listen>:

int
listen(int s, int backlog)
{
  801eb4:	55                   	push   %ebp
  801eb5:	89 e5                	mov    %esp,%ebp
  801eb7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eba:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebd:	e8 aa fe ff ff       	call   801d6c <fd2sockid>
  801ec2:	85 c0                	test   %eax,%eax
  801ec4:	78 0f                	js     801ed5 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801ec6:	83 ec 08             	sub    $0x8,%esp
  801ec9:	ff 75 0c             	pushl  0xc(%ebp)
  801ecc:	50                   	push   %eax
  801ecd:	e8 67 01 00 00       	call   802039 <nsipc_listen>
  801ed2:	83 c4 10             	add    $0x10,%esp
}
  801ed5:	c9                   	leave  
  801ed6:	c3                   	ret    

00801ed7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ed7:	55                   	push   %ebp
  801ed8:	89 e5                	mov    %esp,%ebp
  801eda:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801edd:	ff 75 10             	pushl  0x10(%ebp)
  801ee0:	ff 75 0c             	pushl  0xc(%ebp)
  801ee3:	ff 75 08             	pushl  0x8(%ebp)
  801ee6:	e8 3a 02 00 00       	call   802125 <nsipc_socket>
  801eeb:	83 c4 10             	add    $0x10,%esp
  801eee:	85 c0                	test   %eax,%eax
  801ef0:	78 05                	js     801ef7 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801ef2:	e8 a5 fe ff ff       	call   801d9c <alloc_sockfd>
}
  801ef7:	c9                   	leave  
  801ef8:	c3                   	ret    

00801ef9 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ef9:	55                   	push   %ebp
  801efa:	89 e5                	mov    %esp,%ebp
  801efc:	53                   	push   %ebx
  801efd:	83 ec 04             	sub    $0x4,%esp
  801f00:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801f02:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801f09:	75 12                	jne    801f1d <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801f0b:	83 ec 0c             	sub    $0xc,%esp
  801f0e:	6a 02                	push   $0x2
  801f10:	e8 66 f5 ff ff       	call   80147b <ipc_find_env>
  801f15:	a3 04 50 80 00       	mov    %eax,0x805004
  801f1a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801f1d:	6a 07                	push   $0x7
  801f1f:	68 00 70 80 00       	push   $0x807000
  801f24:	53                   	push   %ebx
  801f25:	ff 35 04 50 80 00    	pushl  0x805004
  801f2b:	e8 f7 f4 ff ff       	call   801427 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f30:	83 c4 0c             	add    $0xc,%esp
  801f33:	6a 00                	push   $0x0
  801f35:	6a 00                	push   $0x0
  801f37:	6a 00                	push   $0x0
  801f39:	e8 80 f4 ff ff       	call   8013be <ipc_recv>
}
  801f3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f41:	c9                   	leave  
  801f42:	c3                   	ret    

00801f43 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f43:	55                   	push   %ebp
  801f44:	89 e5                	mov    %esp,%ebp
  801f46:	56                   	push   %esi
  801f47:	53                   	push   %ebx
  801f48:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f53:	8b 06                	mov    (%esi),%eax
  801f55:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f5a:	b8 01 00 00 00       	mov    $0x1,%eax
  801f5f:	e8 95 ff ff ff       	call   801ef9 <nsipc>
  801f64:	89 c3                	mov    %eax,%ebx
  801f66:	85 c0                	test   %eax,%eax
  801f68:	78 20                	js     801f8a <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f6a:	83 ec 04             	sub    $0x4,%esp
  801f6d:	ff 35 10 70 80 00    	pushl  0x807010
  801f73:	68 00 70 80 00       	push   $0x807000
  801f78:	ff 75 0c             	pushl  0xc(%ebp)
  801f7b:	e8 f8 ee ff ff       	call   800e78 <memmove>
		*addrlen = ret->ret_addrlen;
  801f80:	a1 10 70 80 00       	mov    0x807010,%eax
  801f85:	89 06                	mov    %eax,(%esi)
  801f87:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801f8a:	89 d8                	mov    %ebx,%eax
  801f8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f8f:	5b                   	pop    %ebx
  801f90:	5e                   	pop    %esi
  801f91:	5d                   	pop    %ebp
  801f92:	c3                   	ret    

00801f93 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f93:	55                   	push   %ebp
  801f94:	89 e5                	mov    %esp,%ebp
  801f96:	53                   	push   %ebx
  801f97:	83 ec 08             	sub    $0x8,%esp
  801f9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa0:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801fa5:	53                   	push   %ebx
  801fa6:	ff 75 0c             	pushl  0xc(%ebp)
  801fa9:	68 04 70 80 00       	push   $0x807004
  801fae:	e8 c5 ee ff ff       	call   800e78 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801fb3:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801fb9:	b8 02 00 00 00       	mov    $0x2,%eax
  801fbe:	e8 36 ff ff ff       	call   801ef9 <nsipc>
}
  801fc3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fc6:	c9                   	leave  
  801fc7:	c3                   	ret    

00801fc8 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801fce:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd1:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801fd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd9:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801fde:	b8 03 00 00 00       	mov    $0x3,%eax
  801fe3:	e8 11 ff ff ff       	call   801ef9 <nsipc>
}
  801fe8:	c9                   	leave  
  801fe9:	c3                   	ret    

00801fea <nsipc_close>:

int
nsipc_close(int s)
{
  801fea:	55                   	push   %ebp
  801feb:	89 e5                	mov    %esp,%ebp
  801fed:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ff0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff3:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801ff8:	b8 04 00 00 00       	mov    $0x4,%eax
  801ffd:	e8 f7 fe ff ff       	call   801ef9 <nsipc>
}
  802002:	c9                   	leave  
  802003:	c3                   	ret    

00802004 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802004:	55                   	push   %ebp
  802005:	89 e5                	mov    %esp,%ebp
  802007:	53                   	push   %ebx
  802008:	83 ec 08             	sub    $0x8,%esp
  80200b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80200e:	8b 45 08             	mov    0x8(%ebp),%eax
  802011:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802016:	53                   	push   %ebx
  802017:	ff 75 0c             	pushl  0xc(%ebp)
  80201a:	68 04 70 80 00       	push   $0x807004
  80201f:	e8 54 ee ff ff       	call   800e78 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802024:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  80202a:	b8 05 00 00 00       	mov    $0x5,%eax
  80202f:	e8 c5 fe ff ff       	call   801ef9 <nsipc>
}
  802034:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802037:	c9                   	leave  
  802038:	c3                   	ret    

00802039 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802039:	55                   	push   %ebp
  80203a:	89 e5                	mov    %esp,%ebp
  80203c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80203f:	8b 45 08             	mov    0x8(%ebp),%eax
  802042:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802047:	8b 45 0c             	mov    0xc(%ebp),%eax
  80204a:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80204f:	b8 06 00 00 00       	mov    $0x6,%eax
  802054:	e8 a0 fe ff ff       	call   801ef9 <nsipc>
}
  802059:	c9                   	leave  
  80205a:	c3                   	ret    

0080205b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80205b:	55                   	push   %ebp
  80205c:	89 e5                	mov    %esp,%ebp
  80205e:	56                   	push   %esi
  80205f:	53                   	push   %ebx
  802060:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802063:	8b 45 08             	mov    0x8(%ebp),%eax
  802066:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80206b:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802071:	8b 45 14             	mov    0x14(%ebp),%eax
  802074:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802079:	b8 07 00 00 00       	mov    $0x7,%eax
  80207e:	e8 76 fe ff ff       	call   801ef9 <nsipc>
  802083:	89 c3                	mov    %eax,%ebx
  802085:	85 c0                	test   %eax,%eax
  802087:	78 35                	js     8020be <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802089:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80208e:	7f 04                	jg     802094 <nsipc_recv+0x39>
  802090:	39 c6                	cmp    %eax,%esi
  802092:	7d 16                	jge    8020aa <nsipc_recv+0x4f>
  802094:	68 23 31 80 00       	push   $0x803123
  802099:	68 e4 30 80 00       	push   $0x8030e4
  80209e:	6a 62                	push   $0x62
  8020a0:	68 38 31 80 00       	push   $0x803138
  8020a5:	e8 de e5 ff ff       	call   800688 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8020aa:	83 ec 04             	sub    $0x4,%esp
  8020ad:	50                   	push   %eax
  8020ae:	68 00 70 80 00       	push   $0x807000
  8020b3:	ff 75 0c             	pushl  0xc(%ebp)
  8020b6:	e8 bd ed ff ff       	call   800e78 <memmove>
  8020bb:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8020be:	89 d8                	mov    %ebx,%eax
  8020c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020c3:	5b                   	pop    %ebx
  8020c4:	5e                   	pop    %esi
  8020c5:	5d                   	pop    %ebp
  8020c6:	c3                   	ret    

008020c7 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8020c7:	55                   	push   %ebp
  8020c8:	89 e5                	mov    %esp,%ebp
  8020ca:	53                   	push   %ebx
  8020cb:	83 ec 04             	sub    $0x4,%esp
  8020ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8020d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d4:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8020d9:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8020df:	7e 16                	jle    8020f7 <nsipc_send+0x30>
  8020e1:	68 44 31 80 00       	push   $0x803144
  8020e6:	68 e4 30 80 00       	push   $0x8030e4
  8020eb:	6a 6d                	push   $0x6d
  8020ed:	68 38 31 80 00       	push   $0x803138
  8020f2:	e8 91 e5 ff ff       	call   800688 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8020f7:	83 ec 04             	sub    $0x4,%esp
  8020fa:	53                   	push   %ebx
  8020fb:	ff 75 0c             	pushl  0xc(%ebp)
  8020fe:	68 0c 70 80 00       	push   $0x80700c
  802103:	e8 70 ed ff ff       	call   800e78 <memmove>
	nsipcbuf.send.req_size = size;
  802108:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  80210e:	8b 45 14             	mov    0x14(%ebp),%eax
  802111:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802116:	b8 08 00 00 00       	mov    $0x8,%eax
  80211b:	e8 d9 fd ff ff       	call   801ef9 <nsipc>
}
  802120:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802123:	c9                   	leave  
  802124:	c3                   	ret    

00802125 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802125:	55                   	push   %ebp
  802126:	89 e5                	mov    %esp,%ebp
  802128:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80212b:	8b 45 08             	mov    0x8(%ebp),%eax
  80212e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802133:	8b 45 0c             	mov    0xc(%ebp),%eax
  802136:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80213b:	8b 45 10             	mov    0x10(%ebp),%eax
  80213e:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802143:	b8 09 00 00 00       	mov    $0x9,%eax
  802148:	e8 ac fd ff ff       	call   801ef9 <nsipc>
}
  80214d:	c9                   	leave  
  80214e:	c3                   	ret    

0080214f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80214f:	55                   	push   %ebp
  802150:	89 e5                	mov    %esp,%ebp
  802152:	56                   	push   %esi
  802153:	53                   	push   %ebx
  802154:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802157:	83 ec 0c             	sub    $0xc,%esp
  80215a:	ff 75 08             	pushl  0x8(%ebp)
  80215d:	e8 62 f3 ff ff       	call   8014c4 <fd2data>
  802162:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802164:	83 c4 08             	add    $0x8,%esp
  802167:	68 50 31 80 00       	push   $0x803150
  80216c:	53                   	push   %ebx
  80216d:	e8 74 eb ff ff       	call   800ce6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802172:	8b 46 04             	mov    0x4(%esi),%eax
  802175:	2b 06                	sub    (%esi),%eax
  802177:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80217d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802184:	00 00 00 
	stat->st_dev = &devpipe;
  802187:	c7 83 88 00 00 00 40 	movl   $0x804040,0x88(%ebx)
  80218e:	40 80 00 
	return 0;
}
  802191:	b8 00 00 00 00       	mov    $0x0,%eax
  802196:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802199:	5b                   	pop    %ebx
  80219a:	5e                   	pop    %esi
  80219b:	5d                   	pop    %ebp
  80219c:	c3                   	ret    

0080219d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80219d:	55                   	push   %ebp
  80219e:	89 e5                	mov    %esp,%ebp
  8021a0:	53                   	push   %ebx
  8021a1:	83 ec 0c             	sub    $0xc,%esp
  8021a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8021a7:	53                   	push   %ebx
  8021a8:	6a 00                	push   $0x0
  8021aa:	e8 bf ef ff ff       	call   80116e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8021af:	89 1c 24             	mov    %ebx,(%esp)
  8021b2:	e8 0d f3 ff ff       	call   8014c4 <fd2data>
  8021b7:	83 c4 08             	add    $0x8,%esp
  8021ba:	50                   	push   %eax
  8021bb:	6a 00                	push   $0x0
  8021bd:	e8 ac ef ff ff       	call   80116e <sys_page_unmap>
}
  8021c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021c5:	c9                   	leave  
  8021c6:	c3                   	ret    

008021c7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8021c7:	55                   	push   %ebp
  8021c8:	89 e5                	mov    %esp,%ebp
  8021ca:	57                   	push   %edi
  8021cb:	56                   	push   %esi
  8021cc:	53                   	push   %ebx
  8021cd:	83 ec 1c             	sub    $0x1c,%esp
  8021d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8021d3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8021d5:	a1 08 50 80 00       	mov    0x805008,%eax
  8021da:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8021dd:	83 ec 0c             	sub    $0xc,%esp
  8021e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8021e3:	e8 46 04 00 00       	call   80262e <pageref>
  8021e8:	89 c3                	mov    %eax,%ebx
  8021ea:	89 3c 24             	mov    %edi,(%esp)
  8021ed:	e8 3c 04 00 00       	call   80262e <pageref>
  8021f2:	83 c4 10             	add    $0x10,%esp
  8021f5:	39 c3                	cmp    %eax,%ebx
  8021f7:	0f 94 c1             	sete   %cl
  8021fa:	0f b6 c9             	movzbl %cl,%ecx
  8021fd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802200:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802206:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802209:	39 ce                	cmp    %ecx,%esi
  80220b:	74 1b                	je     802228 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80220d:	39 c3                	cmp    %eax,%ebx
  80220f:	75 c4                	jne    8021d5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802211:	8b 42 58             	mov    0x58(%edx),%eax
  802214:	ff 75 e4             	pushl  -0x1c(%ebp)
  802217:	50                   	push   %eax
  802218:	56                   	push   %esi
  802219:	68 57 31 80 00       	push   $0x803157
  80221e:	e8 3e e5 ff ff       	call   800761 <cprintf>
  802223:	83 c4 10             	add    $0x10,%esp
  802226:	eb ad                	jmp    8021d5 <_pipeisclosed+0xe>
	}
}
  802228:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80222b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80222e:	5b                   	pop    %ebx
  80222f:	5e                   	pop    %esi
  802230:	5f                   	pop    %edi
  802231:	5d                   	pop    %ebp
  802232:	c3                   	ret    

00802233 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802233:	55                   	push   %ebp
  802234:	89 e5                	mov    %esp,%ebp
  802236:	57                   	push   %edi
  802237:	56                   	push   %esi
  802238:	53                   	push   %ebx
  802239:	83 ec 28             	sub    $0x28,%esp
  80223c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80223f:	56                   	push   %esi
  802240:	e8 7f f2 ff ff       	call   8014c4 <fd2data>
  802245:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802247:	83 c4 10             	add    $0x10,%esp
  80224a:	bf 00 00 00 00       	mov    $0x0,%edi
  80224f:	eb 4b                	jmp    80229c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802251:	89 da                	mov    %ebx,%edx
  802253:	89 f0                	mov    %esi,%eax
  802255:	e8 6d ff ff ff       	call   8021c7 <_pipeisclosed>
  80225a:	85 c0                	test   %eax,%eax
  80225c:	75 48                	jne    8022a6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80225e:	e8 67 ee ff ff       	call   8010ca <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802263:	8b 43 04             	mov    0x4(%ebx),%eax
  802266:	8b 0b                	mov    (%ebx),%ecx
  802268:	8d 51 20             	lea    0x20(%ecx),%edx
  80226b:	39 d0                	cmp    %edx,%eax
  80226d:	73 e2                	jae    802251 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80226f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802272:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802276:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802279:	89 c2                	mov    %eax,%edx
  80227b:	c1 fa 1f             	sar    $0x1f,%edx
  80227e:	89 d1                	mov    %edx,%ecx
  802280:	c1 e9 1b             	shr    $0x1b,%ecx
  802283:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802286:	83 e2 1f             	and    $0x1f,%edx
  802289:	29 ca                	sub    %ecx,%edx
  80228b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80228f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802293:	83 c0 01             	add    $0x1,%eax
  802296:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802299:	83 c7 01             	add    $0x1,%edi
  80229c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80229f:	75 c2                	jne    802263 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8022a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8022a4:	eb 05                	jmp    8022ab <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022a6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8022ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022ae:	5b                   	pop    %ebx
  8022af:	5e                   	pop    %esi
  8022b0:	5f                   	pop    %edi
  8022b1:	5d                   	pop    %ebp
  8022b2:	c3                   	ret    

008022b3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022b3:	55                   	push   %ebp
  8022b4:	89 e5                	mov    %esp,%ebp
  8022b6:	57                   	push   %edi
  8022b7:	56                   	push   %esi
  8022b8:	53                   	push   %ebx
  8022b9:	83 ec 18             	sub    $0x18,%esp
  8022bc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8022bf:	57                   	push   %edi
  8022c0:	e8 ff f1 ff ff       	call   8014c4 <fd2data>
  8022c5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022c7:	83 c4 10             	add    $0x10,%esp
  8022ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8022cf:	eb 3d                	jmp    80230e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8022d1:	85 db                	test   %ebx,%ebx
  8022d3:	74 04                	je     8022d9 <devpipe_read+0x26>
				return i;
  8022d5:	89 d8                	mov    %ebx,%eax
  8022d7:	eb 44                	jmp    80231d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8022d9:	89 f2                	mov    %esi,%edx
  8022db:	89 f8                	mov    %edi,%eax
  8022dd:	e8 e5 fe ff ff       	call   8021c7 <_pipeisclosed>
  8022e2:	85 c0                	test   %eax,%eax
  8022e4:	75 32                	jne    802318 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8022e6:	e8 df ed ff ff       	call   8010ca <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8022eb:	8b 06                	mov    (%esi),%eax
  8022ed:	3b 46 04             	cmp    0x4(%esi),%eax
  8022f0:	74 df                	je     8022d1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8022f2:	99                   	cltd   
  8022f3:	c1 ea 1b             	shr    $0x1b,%edx
  8022f6:	01 d0                	add    %edx,%eax
  8022f8:	83 e0 1f             	and    $0x1f,%eax
  8022fb:	29 d0                	sub    %edx,%eax
  8022fd:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802302:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802305:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802308:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80230b:	83 c3 01             	add    $0x1,%ebx
  80230e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802311:	75 d8                	jne    8022eb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802313:	8b 45 10             	mov    0x10(%ebp),%eax
  802316:	eb 05                	jmp    80231d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802318:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80231d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802320:	5b                   	pop    %ebx
  802321:	5e                   	pop    %esi
  802322:	5f                   	pop    %edi
  802323:	5d                   	pop    %ebp
  802324:	c3                   	ret    

00802325 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802325:	55                   	push   %ebp
  802326:	89 e5                	mov    %esp,%ebp
  802328:	56                   	push   %esi
  802329:	53                   	push   %ebx
  80232a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80232d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802330:	50                   	push   %eax
  802331:	e8 a5 f1 ff ff       	call   8014db <fd_alloc>
  802336:	83 c4 10             	add    $0x10,%esp
  802339:	89 c2                	mov    %eax,%edx
  80233b:	85 c0                	test   %eax,%eax
  80233d:	0f 88 2c 01 00 00    	js     80246f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802343:	83 ec 04             	sub    $0x4,%esp
  802346:	68 07 04 00 00       	push   $0x407
  80234b:	ff 75 f4             	pushl  -0xc(%ebp)
  80234e:	6a 00                	push   $0x0
  802350:	e8 94 ed ff ff       	call   8010e9 <sys_page_alloc>
  802355:	83 c4 10             	add    $0x10,%esp
  802358:	89 c2                	mov    %eax,%edx
  80235a:	85 c0                	test   %eax,%eax
  80235c:	0f 88 0d 01 00 00    	js     80246f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802362:	83 ec 0c             	sub    $0xc,%esp
  802365:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802368:	50                   	push   %eax
  802369:	e8 6d f1 ff ff       	call   8014db <fd_alloc>
  80236e:	89 c3                	mov    %eax,%ebx
  802370:	83 c4 10             	add    $0x10,%esp
  802373:	85 c0                	test   %eax,%eax
  802375:	0f 88 e2 00 00 00    	js     80245d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80237b:	83 ec 04             	sub    $0x4,%esp
  80237e:	68 07 04 00 00       	push   $0x407
  802383:	ff 75 f0             	pushl  -0x10(%ebp)
  802386:	6a 00                	push   $0x0
  802388:	e8 5c ed ff ff       	call   8010e9 <sys_page_alloc>
  80238d:	89 c3                	mov    %eax,%ebx
  80238f:	83 c4 10             	add    $0x10,%esp
  802392:	85 c0                	test   %eax,%eax
  802394:	0f 88 c3 00 00 00    	js     80245d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80239a:	83 ec 0c             	sub    $0xc,%esp
  80239d:	ff 75 f4             	pushl  -0xc(%ebp)
  8023a0:	e8 1f f1 ff ff       	call   8014c4 <fd2data>
  8023a5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023a7:	83 c4 0c             	add    $0xc,%esp
  8023aa:	68 07 04 00 00       	push   $0x407
  8023af:	50                   	push   %eax
  8023b0:	6a 00                	push   $0x0
  8023b2:	e8 32 ed ff ff       	call   8010e9 <sys_page_alloc>
  8023b7:	89 c3                	mov    %eax,%ebx
  8023b9:	83 c4 10             	add    $0x10,%esp
  8023bc:	85 c0                	test   %eax,%eax
  8023be:	0f 88 89 00 00 00    	js     80244d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023c4:	83 ec 0c             	sub    $0xc,%esp
  8023c7:	ff 75 f0             	pushl  -0x10(%ebp)
  8023ca:	e8 f5 f0 ff ff       	call   8014c4 <fd2data>
  8023cf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8023d6:	50                   	push   %eax
  8023d7:	6a 00                	push   $0x0
  8023d9:	56                   	push   %esi
  8023da:	6a 00                	push   $0x0
  8023dc:	e8 4b ed ff ff       	call   80112c <sys_page_map>
  8023e1:	89 c3                	mov    %eax,%ebx
  8023e3:	83 c4 20             	add    $0x20,%esp
  8023e6:	85 c0                	test   %eax,%eax
  8023e8:	78 55                	js     80243f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8023ea:	8b 15 40 40 80 00    	mov    0x804040,%edx
  8023f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023f3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8023f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023f8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8023ff:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802405:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802408:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80240a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80240d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802414:	83 ec 0c             	sub    $0xc,%esp
  802417:	ff 75 f4             	pushl  -0xc(%ebp)
  80241a:	e8 95 f0 ff ff       	call   8014b4 <fd2num>
  80241f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802422:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802424:	83 c4 04             	add    $0x4,%esp
  802427:	ff 75 f0             	pushl  -0x10(%ebp)
  80242a:	e8 85 f0 ff ff       	call   8014b4 <fd2num>
  80242f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802432:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802435:	83 c4 10             	add    $0x10,%esp
  802438:	ba 00 00 00 00       	mov    $0x0,%edx
  80243d:	eb 30                	jmp    80246f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80243f:	83 ec 08             	sub    $0x8,%esp
  802442:	56                   	push   %esi
  802443:	6a 00                	push   $0x0
  802445:	e8 24 ed ff ff       	call   80116e <sys_page_unmap>
  80244a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80244d:	83 ec 08             	sub    $0x8,%esp
  802450:	ff 75 f0             	pushl  -0x10(%ebp)
  802453:	6a 00                	push   $0x0
  802455:	e8 14 ed ff ff       	call   80116e <sys_page_unmap>
  80245a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80245d:	83 ec 08             	sub    $0x8,%esp
  802460:	ff 75 f4             	pushl  -0xc(%ebp)
  802463:	6a 00                	push   $0x0
  802465:	e8 04 ed ff ff       	call   80116e <sys_page_unmap>
  80246a:	83 c4 10             	add    $0x10,%esp
  80246d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80246f:	89 d0                	mov    %edx,%eax
  802471:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802474:	5b                   	pop    %ebx
  802475:	5e                   	pop    %esi
  802476:	5d                   	pop    %ebp
  802477:	c3                   	ret    

00802478 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802478:	55                   	push   %ebp
  802479:	89 e5                	mov    %esp,%ebp
  80247b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80247e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802481:	50                   	push   %eax
  802482:	ff 75 08             	pushl  0x8(%ebp)
  802485:	e8 a0 f0 ff ff       	call   80152a <fd_lookup>
  80248a:	83 c4 10             	add    $0x10,%esp
  80248d:	85 c0                	test   %eax,%eax
  80248f:	78 18                	js     8024a9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802491:	83 ec 0c             	sub    $0xc,%esp
  802494:	ff 75 f4             	pushl  -0xc(%ebp)
  802497:	e8 28 f0 ff ff       	call   8014c4 <fd2data>
	return _pipeisclosed(fd, p);
  80249c:	89 c2                	mov    %eax,%edx
  80249e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024a1:	e8 21 fd ff ff       	call   8021c7 <_pipeisclosed>
  8024a6:	83 c4 10             	add    $0x10,%esp
}
  8024a9:	c9                   	leave  
  8024aa:	c3                   	ret    

008024ab <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8024ab:	55                   	push   %ebp
  8024ac:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8024ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8024b3:	5d                   	pop    %ebp
  8024b4:	c3                   	ret    

008024b5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8024b5:	55                   	push   %ebp
  8024b6:	89 e5                	mov    %esp,%ebp
  8024b8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8024bb:	68 6f 31 80 00       	push   $0x80316f
  8024c0:	ff 75 0c             	pushl  0xc(%ebp)
  8024c3:	e8 1e e8 ff ff       	call   800ce6 <strcpy>
	return 0;
}
  8024c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8024cd:	c9                   	leave  
  8024ce:	c3                   	ret    

008024cf <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8024cf:	55                   	push   %ebp
  8024d0:	89 e5                	mov    %esp,%ebp
  8024d2:	57                   	push   %edi
  8024d3:	56                   	push   %esi
  8024d4:	53                   	push   %ebx
  8024d5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024db:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8024e0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024e6:	eb 2d                	jmp    802515 <devcons_write+0x46>
		m = n - tot;
  8024e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8024eb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8024ed:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8024f0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8024f5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8024f8:	83 ec 04             	sub    $0x4,%esp
  8024fb:	53                   	push   %ebx
  8024fc:	03 45 0c             	add    0xc(%ebp),%eax
  8024ff:	50                   	push   %eax
  802500:	57                   	push   %edi
  802501:	e8 72 e9 ff ff       	call   800e78 <memmove>
		sys_cputs(buf, m);
  802506:	83 c4 08             	add    $0x8,%esp
  802509:	53                   	push   %ebx
  80250a:	57                   	push   %edi
  80250b:	e8 1d eb ff ff       	call   80102d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802510:	01 de                	add    %ebx,%esi
  802512:	83 c4 10             	add    $0x10,%esp
  802515:	89 f0                	mov    %esi,%eax
  802517:	3b 75 10             	cmp    0x10(%ebp),%esi
  80251a:	72 cc                	jb     8024e8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80251c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80251f:	5b                   	pop    %ebx
  802520:	5e                   	pop    %esi
  802521:	5f                   	pop    %edi
  802522:	5d                   	pop    %ebp
  802523:	c3                   	ret    

00802524 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802524:	55                   	push   %ebp
  802525:	89 e5                	mov    %esp,%ebp
  802527:	83 ec 08             	sub    $0x8,%esp
  80252a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80252f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802533:	74 2a                	je     80255f <devcons_read+0x3b>
  802535:	eb 05                	jmp    80253c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802537:	e8 8e eb ff ff       	call   8010ca <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80253c:	e8 0a eb ff ff       	call   80104b <sys_cgetc>
  802541:	85 c0                	test   %eax,%eax
  802543:	74 f2                	je     802537 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802545:	85 c0                	test   %eax,%eax
  802547:	78 16                	js     80255f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802549:	83 f8 04             	cmp    $0x4,%eax
  80254c:	74 0c                	je     80255a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80254e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802551:	88 02                	mov    %al,(%edx)
	return 1;
  802553:	b8 01 00 00 00       	mov    $0x1,%eax
  802558:	eb 05                	jmp    80255f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80255a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80255f:	c9                   	leave  
  802560:	c3                   	ret    

00802561 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802561:	55                   	push   %ebp
  802562:	89 e5                	mov    %esp,%ebp
  802564:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802567:	8b 45 08             	mov    0x8(%ebp),%eax
  80256a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80256d:	6a 01                	push   $0x1
  80256f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802572:	50                   	push   %eax
  802573:	e8 b5 ea ff ff       	call   80102d <sys_cputs>
}
  802578:	83 c4 10             	add    $0x10,%esp
  80257b:	c9                   	leave  
  80257c:	c3                   	ret    

0080257d <getchar>:

int
getchar(void)
{
  80257d:	55                   	push   %ebp
  80257e:	89 e5                	mov    %esp,%ebp
  802580:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802583:	6a 01                	push   $0x1
  802585:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802588:	50                   	push   %eax
  802589:	6a 00                	push   $0x0
  80258b:	e8 00 f2 ff ff       	call   801790 <read>
	if (r < 0)
  802590:	83 c4 10             	add    $0x10,%esp
  802593:	85 c0                	test   %eax,%eax
  802595:	78 0f                	js     8025a6 <getchar+0x29>
		return r;
	if (r < 1)
  802597:	85 c0                	test   %eax,%eax
  802599:	7e 06                	jle    8025a1 <getchar+0x24>
		return -E_EOF;
	return c;
  80259b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80259f:	eb 05                	jmp    8025a6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8025a1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8025a6:	c9                   	leave  
  8025a7:	c3                   	ret    

008025a8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8025a8:	55                   	push   %ebp
  8025a9:	89 e5                	mov    %esp,%ebp
  8025ab:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025b1:	50                   	push   %eax
  8025b2:	ff 75 08             	pushl  0x8(%ebp)
  8025b5:	e8 70 ef ff ff       	call   80152a <fd_lookup>
  8025ba:	83 c4 10             	add    $0x10,%esp
  8025bd:	85 c0                	test   %eax,%eax
  8025bf:	78 11                	js     8025d2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8025c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025c4:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  8025ca:	39 10                	cmp    %edx,(%eax)
  8025cc:	0f 94 c0             	sete   %al
  8025cf:	0f b6 c0             	movzbl %al,%eax
}
  8025d2:	c9                   	leave  
  8025d3:	c3                   	ret    

008025d4 <opencons>:

int
opencons(void)
{
  8025d4:	55                   	push   %ebp
  8025d5:	89 e5                	mov    %esp,%ebp
  8025d7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8025da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025dd:	50                   	push   %eax
  8025de:	e8 f8 ee ff ff       	call   8014db <fd_alloc>
  8025e3:	83 c4 10             	add    $0x10,%esp
		return r;
  8025e6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8025e8:	85 c0                	test   %eax,%eax
  8025ea:	78 3e                	js     80262a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8025ec:	83 ec 04             	sub    $0x4,%esp
  8025ef:	68 07 04 00 00       	push   $0x407
  8025f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8025f7:	6a 00                	push   $0x0
  8025f9:	e8 eb ea ff ff       	call   8010e9 <sys_page_alloc>
  8025fe:	83 c4 10             	add    $0x10,%esp
		return r;
  802601:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802603:	85 c0                	test   %eax,%eax
  802605:	78 23                	js     80262a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802607:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  80260d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802610:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802612:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802615:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80261c:	83 ec 0c             	sub    $0xc,%esp
  80261f:	50                   	push   %eax
  802620:	e8 8f ee ff ff       	call   8014b4 <fd2num>
  802625:	89 c2                	mov    %eax,%edx
  802627:	83 c4 10             	add    $0x10,%esp
}
  80262a:	89 d0                	mov    %edx,%eax
  80262c:	c9                   	leave  
  80262d:	c3                   	ret    

0080262e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80262e:	55                   	push   %ebp
  80262f:	89 e5                	mov    %esp,%ebp
  802631:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802634:	89 d0                	mov    %edx,%eax
  802636:	c1 e8 16             	shr    $0x16,%eax
  802639:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802640:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802645:	f6 c1 01             	test   $0x1,%cl
  802648:	74 1d                	je     802667 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80264a:	c1 ea 0c             	shr    $0xc,%edx
  80264d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802654:	f6 c2 01             	test   $0x1,%dl
  802657:	74 0e                	je     802667 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802659:	c1 ea 0c             	shr    $0xc,%edx
  80265c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802663:	ef 
  802664:	0f b7 c0             	movzwl %ax,%eax
}
  802667:	5d                   	pop    %ebp
  802668:	c3                   	ret    
  802669:	66 90                	xchg   %ax,%ax
  80266b:	66 90                	xchg   %ax,%ax
  80266d:	66 90                	xchg   %ax,%ax
  80266f:	90                   	nop

00802670 <__udivdi3>:
  802670:	55                   	push   %ebp
  802671:	57                   	push   %edi
  802672:	56                   	push   %esi
  802673:	53                   	push   %ebx
  802674:	83 ec 1c             	sub    $0x1c,%esp
  802677:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80267b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80267f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802683:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802687:	85 f6                	test   %esi,%esi
  802689:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80268d:	89 ca                	mov    %ecx,%edx
  80268f:	89 f8                	mov    %edi,%eax
  802691:	75 3d                	jne    8026d0 <__udivdi3+0x60>
  802693:	39 cf                	cmp    %ecx,%edi
  802695:	0f 87 c5 00 00 00    	ja     802760 <__udivdi3+0xf0>
  80269b:	85 ff                	test   %edi,%edi
  80269d:	89 fd                	mov    %edi,%ebp
  80269f:	75 0b                	jne    8026ac <__udivdi3+0x3c>
  8026a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8026a6:	31 d2                	xor    %edx,%edx
  8026a8:	f7 f7                	div    %edi
  8026aa:	89 c5                	mov    %eax,%ebp
  8026ac:	89 c8                	mov    %ecx,%eax
  8026ae:	31 d2                	xor    %edx,%edx
  8026b0:	f7 f5                	div    %ebp
  8026b2:	89 c1                	mov    %eax,%ecx
  8026b4:	89 d8                	mov    %ebx,%eax
  8026b6:	89 cf                	mov    %ecx,%edi
  8026b8:	f7 f5                	div    %ebp
  8026ba:	89 c3                	mov    %eax,%ebx
  8026bc:	89 d8                	mov    %ebx,%eax
  8026be:	89 fa                	mov    %edi,%edx
  8026c0:	83 c4 1c             	add    $0x1c,%esp
  8026c3:	5b                   	pop    %ebx
  8026c4:	5e                   	pop    %esi
  8026c5:	5f                   	pop    %edi
  8026c6:	5d                   	pop    %ebp
  8026c7:	c3                   	ret    
  8026c8:	90                   	nop
  8026c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026d0:	39 ce                	cmp    %ecx,%esi
  8026d2:	77 74                	ja     802748 <__udivdi3+0xd8>
  8026d4:	0f bd fe             	bsr    %esi,%edi
  8026d7:	83 f7 1f             	xor    $0x1f,%edi
  8026da:	0f 84 98 00 00 00    	je     802778 <__udivdi3+0x108>
  8026e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8026e5:	89 f9                	mov    %edi,%ecx
  8026e7:	89 c5                	mov    %eax,%ebp
  8026e9:	29 fb                	sub    %edi,%ebx
  8026eb:	d3 e6                	shl    %cl,%esi
  8026ed:	89 d9                	mov    %ebx,%ecx
  8026ef:	d3 ed                	shr    %cl,%ebp
  8026f1:	89 f9                	mov    %edi,%ecx
  8026f3:	d3 e0                	shl    %cl,%eax
  8026f5:	09 ee                	or     %ebp,%esi
  8026f7:	89 d9                	mov    %ebx,%ecx
  8026f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026fd:	89 d5                	mov    %edx,%ebp
  8026ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802703:	d3 ed                	shr    %cl,%ebp
  802705:	89 f9                	mov    %edi,%ecx
  802707:	d3 e2                	shl    %cl,%edx
  802709:	89 d9                	mov    %ebx,%ecx
  80270b:	d3 e8                	shr    %cl,%eax
  80270d:	09 c2                	or     %eax,%edx
  80270f:	89 d0                	mov    %edx,%eax
  802711:	89 ea                	mov    %ebp,%edx
  802713:	f7 f6                	div    %esi
  802715:	89 d5                	mov    %edx,%ebp
  802717:	89 c3                	mov    %eax,%ebx
  802719:	f7 64 24 0c          	mull   0xc(%esp)
  80271d:	39 d5                	cmp    %edx,%ebp
  80271f:	72 10                	jb     802731 <__udivdi3+0xc1>
  802721:	8b 74 24 08          	mov    0x8(%esp),%esi
  802725:	89 f9                	mov    %edi,%ecx
  802727:	d3 e6                	shl    %cl,%esi
  802729:	39 c6                	cmp    %eax,%esi
  80272b:	73 07                	jae    802734 <__udivdi3+0xc4>
  80272d:	39 d5                	cmp    %edx,%ebp
  80272f:	75 03                	jne    802734 <__udivdi3+0xc4>
  802731:	83 eb 01             	sub    $0x1,%ebx
  802734:	31 ff                	xor    %edi,%edi
  802736:	89 d8                	mov    %ebx,%eax
  802738:	89 fa                	mov    %edi,%edx
  80273a:	83 c4 1c             	add    $0x1c,%esp
  80273d:	5b                   	pop    %ebx
  80273e:	5e                   	pop    %esi
  80273f:	5f                   	pop    %edi
  802740:	5d                   	pop    %ebp
  802741:	c3                   	ret    
  802742:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802748:	31 ff                	xor    %edi,%edi
  80274a:	31 db                	xor    %ebx,%ebx
  80274c:	89 d8                	mov    %ebx,%eax
  80274e:	89 fa                	mov    %edi,%edx
  802750:	83 c4 1c             	add    $0x1c,%esp
  802753:	5b                   	pop    %ebx
  802754:	5e                   	pop    %esi
  802755:	5f                   	pop    %edi
  802756:	5d                   	pop    %ebp
  802757:	c3                   	ret    
  802758:	90                   	nop
  802759:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802760:	89 d8                	mov    %ebx,%eax
  802762:	f7 f7                	div    %edi
  802764:	31 ff                	xor    %edi,%edi
  802766:	89 c3                	mov    %eax,%ebx
  802768:	89 d8                	mov    %ebx,%eax
  80276a:	89 fa                	mov    %edi,%edx
  80276c:	83 c4 1c             	add    $0x1c,%esp
  80276f:	5b                   	pop    %ebx
  802770:	5e                   	pop    %esi
  802771:	5f                   	pop    %edi
  802772:	5d                   	pop    %ebp
  802773:	c3                   	ret    
  802774:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802778:	39 ce                	cmp    %ecx,%esi
  80277a:	72 0c                	jb     802788 <__udivdi3+0x118>
  80277c:	31 db                	xor    %ebx,%ebx
  80277e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802782:	0f 87 34 ff ff ff    	ja     8026bc <__udivdi3+0x4c>
  802788:	bb 01 00 00 00       	mov    $0x1,%ebx
  80278d:	e9 2a ff ff ff       	jmp    8026bc <__udivdi3+0x4c>
  802792:	66 90                	xchg   %ax,%ax
  802794:	66 90                	xchg   %ax,%ax
  802796:	66 90                	xchg   %ax,%ax
  802798:	66 90                	xchg   %ax,%ax
  80279a:	66 90                	xchg   %ax,%ax
  80279c:	66 90                	xchg   %ax,%ax
  80279e:	66 90                	xchg   %ax,%ax

008027a0 <__umoddi3>:
  8027a0:	55                   	push   %ebp
  8027a1:	57                   	push   %edi
  8027a2:	56                   	push   %esi
  8027a3:	53                   	push   %ebx
  8027a4:	83 ec 1c             	sub    $0x1c,%esp
  8027a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8027ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8027af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8027b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027b7:	85 d2                	test   %edx,%edx
  8027b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8027bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027c1:	89 f3                	mov    %esi,%ebx
  8027c3:	89 3c 24             	mov    %edi,(%esp)
  8027c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027ca:	75 1c                	jne    8027e8 <__umoddi3+0x48>
  8027cc:	39 f7                	cmp    %esi,%edi
  8027ce:	76 50                	jbe    802820 <__umoddi3+0x80>
  8027d0:	89 c8                	mov    %ecx,%eax
  8027d2:	89 f2                	mov    %esi,%edx
  8027d4:	f7 f7                	div    %edi
  8027d6:	89 d0                	mov    %edx,%eax
  8027d8:	31 d2                	xor    %edx,%edx
  8027da:	83 c4 1c             	add    $0x1c,%esp
  8027dd:	5b                   	pop    %ebx
  8027de:	5e                   	pop    %esi
  8027df:	5f                   	pop    %edi
  8027e0:	5d                   	pop    %ebp
  8027e1:	c3                   	ret    
  8027e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027e8:	39 f2                	cmp    %esi,%edx
  8027ea:	89 d0                	mov    %edx,%eax
  8027ec:	77 52                	ja     802840 <__umoddi3+0xa0>
  8027ee:	0f bd ea             	bsr    %edx,%ebp
  8027f1:	83 f5 1f             	xor    $0x1f,%ebp
  8027f4:	75 5a                	jne    802850 <__umoddi3+0xb0>
  8027f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8027fa:	0f 82 e0 00 00 00    	jb     8028e0 <__umoddi3+0x140>
  802800:	39 0c 24             	cmp    %ecx,(%esp)
  802803:	0f 86 d7 00 00 00    	jbe    8028e0 <__umoddi3+0x140>
  802809:	8b 44 24 08          	mov    0x8(%esp),%eax
  80280d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802811:	83 c4 1c             	add    $0x1c,%esp
  802814:	5b                   	pop    %ebx
  802815:	5e                   	pop    %esi
  802816:	5f                   	pop    %edi
  802817:	5d                   	pop    %ebp
  802818:	c3                   	ret    
  802819:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802820:	85 ff                	test   %edi,%edi
  802822:	89 fd                	mov    %edi,%ebp
  802824:	75 0b                	jne    802831 <__umoddi3+0x91>
  802826:	b8 01 00 00 00       	mov    $0x1,%eax
  80282b:	31 d2                	xor    %edx,%edx
  80282d:	f7 f7                	div    %edi
  80282f:	89 c5                	mov    %eax,%ebp
  802831:	89 f0                	mov    %esi,%eax
  802833:	31 d2                	xor    %edx,%edx
  802835:	f7 f5                	div    %ebp
  802837:	89 c8                	mov    %ecx,%eax
  802839:	f7 f5                	div    %ebp
  80283b:	89 d0                	mov    %edx,%eax
  80283d:	eb 99                	jmp    8027d8 <__umoddi3+0x38>
  80283f:	90                   	nop
  802840:	89 c8                	mov    %ecx,%eax
  802842:	89 f2                	mov    %esi,%edx
  802844:	83 c4 1c             	add    $0x1c,%esp
  802847:	5b                   	pop    %ebx
  802848:	5e                   	pop    %esi
  802849:	5f                   	pop    %edi
  80284a:	5d                   	pop    %ebp
  80284b:	c3                   	ret    
  80284c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802850:	8b 34 24             	mov    (%esp),%esi
  802853:	bf 20 00 00 00       	mov    $0x20,%edi
  802858:	89 e9                	mov    %ebp,%ecx
  80285a:	29 ef                	sub    %ebp,%edi
  80285c:	d3 e0                	shl    %cl,%eax
  80285e:	89 f9                	mov    %edi,%ecx
  802860:	89 f2                	mov    %esi,%edx
  802862:	d3 ea                	shr    %cl,%edx
  802864:	89 e9                	mov    %ebp,%ecx
  802866:	09 c2                	or     %eax,%edx
  802868:	89 d8                	mov    %ebx,%eax
  80286a:	89 14 24             	mov    %edx,(%esp)
  80286d:	89 f2                	mov    %esi,%edx
  80286f:	d3 e2                	shl    %cl,%edx
  802871:	89 f9                	mov    %edi,%ecx
  802873:	89 54 24 04          	mov    %edx,0x4(%esp)
  802877:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80287b:	d3 e8                	shr    %cl,%eax
  80287d:	89 e9                	mov    %ebp,%ecx
  80287f:	89 c6                	mov    %eax,%esi
  802881:	d3 e3                	shl    %cl,%ebx
  802883:	89 f9                	mov    %edi,%ecx
  802885:	89 d0                	mov    %edx,%eax
  802887:	d3 e8                	shr    %cl,%eax
  802889:	89 e9                	mov    %ebp,%ecx
  80288b:	09 d8                	or     %ebx,%eax
  80288d:	89 d3                	mov    %edx,%ebx
  80288f:	89 f2                	mov    %esi,%edx
  802891:	f7 34 24             	divl   (%esp)
  802894:	89 d6                	mov    %edx,%esi
  802896:	d3 e3                	shl    %cl,%ebx
  802898:	f7 64 24 04          	mull   0x4(%esp)
  80289c:	39 d6                	cmp    %edx,%esi
  80289e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028a2:	89 d1                	mov    %edx,%ecx
  8028a4:	89 c3                	mov    %eax,%ebx
  8028a6:	72 08                	jb     8028b0 <__umoddi3+0x110>
  8028a8:	75 11                	jne    8028bb <__umoddi3+0x11b>
  8028aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8028ae:	73 0b                	jae    8028bb <__umoddi3+0x11b>
  8028b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8028b4:	1b 14 24             	sbb    (%esp),%edx
  8028b7:	89 d1                	mov    %edx,%ecx
  8028b9:	89 c3                	mov    %eax,%ebx
  8028bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8028bf:	29 da                	sub    %ebx,%edx
  8028c1:	19 ce                	sbb    %ecx,%esi
  8028c3:	89 f9                	mov    %edi,%ecx
  8028c5:	89 f0                	mov    %esi,%eax
  8028c7:	d3 e0                	shl    %cl,%eax
  8028c9:	89 e9                	mov    %ebp,%ecx
  8028cb:	d3 ea                	shr    %cl,%edx
  8028cd:	89 e9                	mov    %ebp,%ecx
  8028cf:	d3 ee                	shr    %cl,%esi
  8028d1:	09 d0                	or     %edx,%eax
  8028d3:	89 f2                	mov    %esi,%edx
  8028d5:	83 c4 1c             	add    $0x1c,%esp
  8028d8:	5b                   	pop    %ebx
  8028d9:	5e                   	pop    %esi
  8028da:	5f                   	pop    %edi
  8028db:	5d                   	pop    %ebp
  8028dc:	c3                   	ret    
  8028dd:	8d 76 00             	lea    0x0(%esi),%esi
  8028e0:	29 f9                	sub    %edi,%ecx
  8028e2:	19 d6                	sbb    %edx,%esi
  8028e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028ec:	e9 18 ff ff ff       	jmp    802809 <__umoddi3+0x69>
