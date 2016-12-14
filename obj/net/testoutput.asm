
obj/net/testoutput:     file format elf32-i386


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
  80002c:	e8 a1 02 00 00       	call   8002d2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
static struct jif_pkt *pkt = (struct jif_pkt*)REQVA;


void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	envid_t ns_envid = sys_getenvid();
  800038:	e8 18 0d 00 00       	call   800d55 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi
	int i, r;

	binaryname = "testoutput";
  80003f:	c7 05 00 30 80 00 e0 	movl   $0x8028e0,0x803000
  800046:	28 80 00 

	output_envid = fork();
  800049:	e8 f0 10 00 00       	call   80113e <fork>
  80004e:	a3 00 40 80 00       	mov    %eax,0x804000
	if (output_envid < 0)
  800053:	85 c0                	test   %eax,%eax
  800055:	79 14                	jns    80006b <umain+0x38>
		panic("error forking");
  800057:	83 ec 04             	sub    $0x4,%esp
  80005a:	68 eb 28 80 00       	push   $0x8028eb
  80005f:	6a 16                	push   $0x16
  800061:	68 f9 28 80 00       	push   $0x8028f9
  800066:	e8 c7 02 00 00       	call   800332 <_panic>
  80006b:	bb 00 00 00 00       	mov    $0x0,%ebx
	else if (output_envid == 0) {
  800070:	85 c0                	test   %eax,%eax
  800072:	75 11                	jne    800085 <umain+0x52>
		output(ns_envid);
  800074:	83 ec 0c             	sub    $0xc,%esp
  800077:	56                   	push   %esi
  800078:	e8 d9 01 00 00       	call   800256 <output>
		return;
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	e9 8f 00 00 00       	jmp    800114 <umain+0xe1>
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
		if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  800085:	83 ec 04             	sub    $0x4,%esp
  800088:	6a 07                	push   $0x7
  80008a:	68 00 b0 fe 0f       	push   $0xffeb000
  80008f:	6a 00                	push   $0x0
  800091:	e8 fd 0c 00 00       	call   800d93 <sys_page_alloc>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x7c>
			panic("sys_page_alloc: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 0a 29 80 00       	push   $0x80290a
  8000a3:	6a 1e                	push   $0x1e
  8000a5:	68 f9 28 80 00       	push   $0x8028f9
  8000aa:	e8 83 02 00 00       	call   800332 <_panic>
		pkt->jp_len = snprintf(pkt->jp_data,
  8000af:	53                   	push   %ebx
  8000b0:	68 1d 29 80 00       	push   $0x80291d
  8000b5:	68 fc 0f 00 00       	push   $0xffc
  8000ba:	68 04 b0 fe 0f       	push   $0xffeb004
  8000bf:	e8 79 08 00 00       	call   80093d <snprintf>
  8000c4:	a3 00 b0 fe 0f       	mov    %eax,0xffeb000
				       PGSIZE - sizeof(pkt->jp_len),
				       "Packet %02d", i);
		cprintf("Transmitting packet %d\n", i);
  8000c9:	83 c4 08             	add    $0x8,%esp
  8000cc:	53                   	push   %ebx
  8000cd:	68 29 29 80 00       	push   $0x802929
  8000d2:	e8 34 03 00 00       	call   80040b <cprintf>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8000d7:	6a 07                	push   $0x7
  8000d9:	68 00 b0 fe 0f       	push   $0xffeb000
  8000de:	6a 0b                	push   $0xb
  8000e0:	ff 35 00 40 80 00    	pushl  0x804000
  8000e6:	e8 9b 12 00 00       	call   801386 <ipc_send>
		sys_page_unmap(0, pkt);
  8000eb:	83 c4 18             	add    $0x18,%esp
  8000ee:	68 00 b0 fe 0f       	push   $0xffeb000
  8000f3:	6a 00                	push   $0x0
  8000f5:	e8 1e 0d 00 00       	call   800e18 <sys_page_unmap>
	else if (output_envid == 0) {
		output(ns_envid);
		return;
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
  8000fa:	83 c3 01             	add    $0x1,%ebx
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	83 fb 0a             	cmp    $0xa,%ebx
  800103:	75 80                	jne    800085 <umain+0x52>
  800105:	bb 14 00 00 00       	mov    $0x14,%ebx
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
		sys_yield();
  80010a:	e8 65 0c 00 00       	call   800d74 <sys_yield>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
  80010f:	83 eb 01             	sub    $0x1,%ebx
  800112:	75 f6                	jne    80010a <umain+0xd7>
		sys_yield();
}
  800114:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    

0080011b <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	57                   	push   %edi
  80011f:	56                   	push   %esi
  800120:	53                   	push   %ebx
  800121:	83 ec 1c             	sub    $0x1c,%esp
  800124:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  800127:	e8 58 0e 00 00       	call   800f84 <sys_time_msec>
  80012c:	03 45 0c             	add    0xc(%ebp),%eax
  80012f:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  800131:	c7 05 00 30 80 00 41 	movl   $0x802941,0x803000
  800138:	29 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  80013b:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80013e:	eb 05                	jmp    800145 <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  800140:	e8 2f 0c 00 00       	call   800d74 <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  800145:	e8 3a 0e 00 00       	call   800f84 <sys_time_msec>
  80014a:	89 c2                	mov    %eax,%edx
  80014c:	85 c0                	test   %eax,%eax
  80014e:	78 04                	js     800154 <timer+0x39>
  800150:	39 c3                	cmp    %eax,%ebx
  800152:	77 ec                	ja     800140 <timer+0x25>
			sys_yield();
		}
		if (r < 0)
  800154:	85 c0                	test   %eax,%eax
  800156:	79 12                	jns    80016a <timer+0x4f>
			panic("sys_time_msec: %e", r);
  800158:	52                   	push   %edx
  800159:	68 4a 29 80 00       	push   $0x80294a
  80015e:	6a 0f                	push   $0xf
  800160:	68 5c 29 80 00       	push   $0x80295c
  800165:	e8 c8 01 00 00       	call   800332 <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  80016a:	6a 00                	push   $0x0
  80016c:	6a 00                	push   $0x0
  80016e:	6a 0c                	push   $0xc
  800170:	56                   	push   %esi
  800171:	e8 10 12 00 00       	call   801386 <ipc_send>
  800176:	83 c4 10             	add    $0x10,%esp

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800179:	83 ec 04             	sub    $0x4,%esp
  80017c:	6a 00                	push   $0x0
  80017e:	6a 00                	push   $0x0
  800180:	57                   	push   %edi
  800181:	e8 97 11 00 00       	call   80131d <ipc_recv>
  800186:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  800188:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80018b:	83 c4 10             	add    $0x10,%esp
  80018e:	39 f0                	cmp    %esi,%eax
  800190:	74 13                	je     8001a5 <timer+0x8a>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	50                   	push   %eax
  800196:	68 68 29 80 00       	push   $0x802968
  80019b:	e8 6b 02 00 00       	call   80040b <cprintf>
				continue;
  8001a0:	83 c4 10             	add    $0x10,%esp
  8001a3:	eb d4                	jmp    800179 <timer+0x5e>
			}

			stop = sys_time_msec() + to;
  8001a5:	e8 da 0d 00 00       	call   800f84 <sys_time_msec>
  8001aa:	01 c3                	add    %eax,%ebx
  8001ac:	eb 97                	jmp    800145 <timer+0x2a>

008001ae <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  8001ae:	55                   	push   %ebp
  8001af:	89 e5                	mov    %esp,%ebp
  8001b1:	57                   	push   %edi
  8001b2:	56                   	push   %esi
  8001b3:	53                   	push   %ebx
  8001b4:	83 ec 48             	sub    $0x48,%esp
	binaryname = "ns_input";
  8001b7:	c7 05 00 30 80 00 a3 	movl   $0x8029a3,0x803000
  8001be:	29 80 00 
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
	cprintf("NS INPUT ENV is on!\n");
  8001c1:	68 ac 29 80 00       	push   $0x8029ac
  8001c6:	e8 40 02 00 00       	call   80040b <cprintf>
  8001cb:	83 c4 10             	add    $0x10,%esp

	// Allocate some pages to receive page
	char *bufs[10];
	char *va = (char *) 0x0ffff000;
	int i;
	for (i = 0; i < 10; i++) {
  8001ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d3:	8d b3 ff ff 00 00    	lea    0xffff(%ebx),%esi
  8001d9:	c1 e6 0c             	shl    $0xc,%esi
		sys_page_alloc(0, va, PTE_P | PTE_U | PTE_W);
  8001dc:	83 ec 04             	sub    $0x4,%esp
  8001df:	6a 07                	push   $0x7
  8001e1:	56                   	push   %esi
  8001e2:	6a 00                	push   $0x0
  8001e4:	e8 aa 0b 00 00       	call   800d93 <sys_page_alloc>
		bufs[i] = va;
  8001e9:	89 74 9d c0          	mov    %esi,-0x40(%ebp,%ebx,4)

	// Allocate some pages to receive page
	char *bufs[10];
	char *va = (char *) 0x0ffff000;
	int i;
	for (i = 0; i < 10; i++) {
  8001ed:	83 c3 01             	add    $0x1,%ebx
  8001f0:	83 c4 10             	add    $0x10,%esp
  8001f3:	83 fb 0a             	cmp    $0xa,%ebx
  8001f6:	75 db                	jne    8001d3 <input+0x25>
  8001f8:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(1) {
		// Build request
		union Nsipc *nsipc = (union Nsipc *) bufs[current_buffer];
		char *packet_buf = (nsipc->pkt).jp_data;
		size_t size = -1; // Could pass the jp_len instead
		sys_receive_packet(packet_buf, &size);
  8001fd:	8d 7d bc             	lea    -0x44(%ebp),%edi
	// Infinity loop trying to receive packets and, if received, send it
	// to the network server
	int current_buffer = 0;
	while(1) {
		// Build request
		union Nsipc *nsipc = (union Nsipc *) bufs[current_buffer];
  800200:	8b 74 9d c0          	mov    -0x40(%ebp,%ebx,4),%esi
		char *packet_buf = (nsipc->pkt).jp_data;
		size_t size = -1; // Could pass the jp_len instead
  800204:	c7 45 bc ff ff ff ff 	movl   $0xffffffff,-0x44(%ebp)
		sys_receive_packet(packet_buf, &size);
  80020b:	83 ec 08             	sub    $0x8,%esp
  80020e:	57                   	push   %edi
	// to the network server
	int current_buffer = 0;
	while(1) {
		// Build request
		union Nsipc *nsipc = (union Nsipc *) bufs[current_buffer];
		char *packet_buf = (nsipc->pkt).jp_data;
  80020f:	8d 46 04             	lea    0x4(%esi),%eax
		size_t size = -1; // Could pass the jp_len instead
		sys_receive_packet(packet_buf, &size);
  800212:	50                   	push   %eax
  800213:	e8 cd 0d 00 00       	call   800fe5 <sys_receive_packet>

		// If it receives a packet, the size won't be -1 anymore
		if (size != -1) {
  800218:	8b 45 bc             	mov    -0x44(%ebp),%eax
  80021b:	83 c4 10             	add    $0x10,%esp
  80021e:	83 f8 ff             	cmp    $0xffffffff,%eax
  800221:	74 dd                	je     800200 <input+0x52>
			

			// Store the correct size
			(nsipc->pkt).jp_len = size;
  800223:	89 06                	mov    %eax,(%esi)

			// Request is built, now send it
			ipc_send(nsenv, NSREQ_INPUT, nsipc, PTE_P|PTE_W|PTE_U);
  800225:	6a 07                	push   $0x7
  800227:	56                   	push   %esi
  800228:	6a 0a                	push   $0xa
  80022a:	68 01 10 00 00       	push   $0x1001
  80022f:	e8 52 11 00 00       	call   801386 <ipc_send>

			// Let the current buffer rest for a while. Go to next.
			current_buffer = (current_buffer + 1)%10;
  800234:	8d 4b 01             	lea    0x1(%ebx),%ecx
  800237:	b8 67 66 66 66       	mov    $0x66666667,%eax
  80023c:	f7 e9                	imul   %ecx
  80023e:	c1 fa 02             	sar    $0x2,%edx
  800241:	89 c8                	mov    %ecx,%eax
  800243:	c1 f8 1f             	sar    $0x1f,%eax
  800246:	29 c2                	sub    %eax,%edx
  800248:	8d 04 92             	lea    (%edx,%edx,4),%eax
  80024b:	01 c0                	add    %eax,%eax
  80024d:	29 c1                	sub    %eax,%ecx
  80024f:	89 cb                	mov    %ecx,%ebx
  800251:	83 c4 10             	add    $0x10,%esp
		}
	}
  800254:	eb aa                	jmp    800200 <input+0x52>

00800256 <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	56                   	push   %esi
  80025a:	53                   	push   %ebx
  80025b:	83 ec 1c             	sub    $0x1c,%esp
	binaryname = "ns_output";
  80025e:	c7 05 00 30 80 00 c1 	movl   $0x8029c1,0x803000
  800265:	29 80 00 

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
	cprintf("NS OUTPUT ENV is on!\n");
  800268:	68 cb 29 80 00       	push   $0x8029cb
  80026d:	e8 99 01 00 00       	call   80040b <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
	
	union Nsipc *nsipc = (union Nsipc *)0x0ffff000;
	envid_t whom; 	int perm;     
	// Endless loop s
	while (1) {
		uint32_t req = ipc_recv(&whom, nsipc, &perm);
  800275:	8d 75 f0             	lea    -0x10(%ebp),%esi
  800278:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  80027b:	83 ec 04             	sub    $0x4,%esp
  80027e:	56                   	push   %esi
  80027f:	68 00 f0 ff 0f       	push   $0xffff000
  800284:	53                   	push   %ebx
  800285:	e8 93 10 00 00       	call   80131d <ipc_recv>

		// Check if the request is of the expected type
		if (req == NSREQ_OUTPUT) {
  80028a:	83 c4 10             	add    $0x10,%esp
  80028d:	83 f8 0b             	cmp    $0xb,%eax
  800290:	75 2c                	jne    8002be <output+0x68>
			char *buf = (nsipc->pkt).jp_data;

			
			// Transmit the packet
			int r;
			if ((r = sys_transmit_packet(buf, size)) < 0)
  800292:	83 ec 08             	sub    $0x8,%esp
  800295:	ff 35 00 f0 ff 0f    	pushl  0xffff000
  80029b:	68 04 f0 ff 0f       	push   $0xffff004
  8002a0:	e8 fe 0c 00 00       	call   800fa3 <sys_transmit_packet>
  8002a5:	83 c4 10             	add    $0x10,%esp
  8002a8:	85 c0                	test   %eax,%eax
  8002aa:	79 cf                	jns    80027b <output+0x25>
				panic("sys_transmit_packet: %e", r);
  8002ac:	50                   	push   %eax
  8002ad:	68 e1 29 80 00       	push   $0x8029e1
  8002b2:	6a 21                	push   $0x21
  8002b4:	68 f9 29 80 00       	push   $0x8029f9
  8002b9:	e8 74 00 00 00       	call   800332 <_panic>
		} else {
			panic("NS OUTPUT ENV: Invalid request received!");
  8002be:	83 ec 04             	sub    $0x4,%esp
  8002c1:	68 08 2a 80 00       	push   $0x802a08
  8002c6:	6a 23                	push   $0x23
  8002c8:	68 f9 29 80 00       	push   $0x8029f9
  8002cd:	e8 60 00 00 00       	call   800332 <_panic>

008002d2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	56                   	push   %esi
  8002d6:	53                   	push   %ebx
  8002d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002da:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002dd:	e8 73 0a 00 00       	call   800d55 <sys_getenvid>
  8002e2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002e7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002ea:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002ef:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002f4:	85 db                	test   %ebx,%ebx
  8002f6:	7e 07                	jle    8002ff <libmain+0x2d>
		binaryname = argv[0];
  8002f8:	8b 06                	mov    (%esi),%eax
  8002fa:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	56                   	push   %esi
  800303:	53                   	push   %ebx
  800304:	e8 2a fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800309:	e8 0a 00 00 00       	call   800318 <exit>
}
  80030e:	83 c4 10             	add    $0x10,%esp
  800311:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800314:	5b                   	pop    %ebx
  800315:	5e                   	pop    %esi
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80031e:	e8 bb 12 00 00       	call   8015de <close_all>
	sys_env_destroy(0);
  800323:	83 ec 0c             	sub    $0xc,%esp
  800326:	6a 00                	push   $0x0
  800328:	e8 e7 09 00 00       	call   800d14 <sys_env_destroy>
}
  80032d:	83 c4 10             	add    $0x10,%esp
  800330:	c9                   	leave  
  800331:	c3                   	ret    

00800332 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800337:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80033a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800340:	e8 10 0a 00 00       	call   800d55 <sys_getenvid>
  800345:	83 ec 0c             	sub    $0xc,%esp
  800348:	ff 75 0c             	pushl  0xc(%ebp)
  80034b:	ff 75 08             	pushl  0x8(%ebp)
  80034e:	56                   	push   %esi
  80034f:	50                   	push   %eax
  800350:	68 3c 2a 80 00       	push   $0x802a3c
  800355:	e8 b1 00 00 00       	call   80040b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80035a:	83 c4 18             	add    $0x18,%esp
  80035d:	53                   	push   %ebx
  80035e:	ff 75 10             	pushl  0x10(%ebp)
  800361:	e8 54 00 00 00       	call   8003ba <vcprintf>
	cprintf("\n");
  800366:	c7 04 24 bf 29 80 00 	movl   $0x8029bf,(%esp)
  80036d:	e8 99 00 00 00       	call   80040b <cprintf>
  800372:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800375:	cc                   	int3   
  800376:	eb fd                	jmp    800375 <_panic+0x43>

00800378 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	53                   	push   %ebx
  80037c:	83 ec 04             	sub    $0x4,%esp
  80037f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800382:	8b 13                	mov    (%ebx),%edx
  800384:	8d 42 01             	lea    0x1(%edx),%eax
  800387:	89 03                	mov    %eax,(%ebx)
  800389:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80038c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800390:	3d ff 00 00 00       	cmp    $0xff,%eax
  800395:	75 1a                	jne    8003b1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800397:	83 ec 08             	sub    $0x8,%esp
  80039a:	68 ff 00 00 00       	push   $0xff
  80039f:	8d 43 08             	lea    0x8(%ebx),%eax
  8003a2:	50                   	push   %eax
  8003a3:	e8 2f 09 00 00       	call   800cd7 <sys_cputs>
		b->idx = 0;
  8003a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003ae:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003b1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003b8:	c9                   	leave  
  8003b9:	c3                   	ret    

008003ba <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003ba:	55                   	push   %ebp
  8003bb:	89 e5                	mov    %esp,%ebp
  8003bd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003c3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003ca:	00 00 00 
	b.cnt = 0;
  8003cd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003d4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003d7:	ff 75 0c             	pushl  0xc(%ebp)
  8003da:	ff 75 08             	pushl  0x8(%ebp)
  8003dd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003e3:	50                   	push   %eax
  8003e4:	68 78 03 80 00       	push   $0x800378
  8003e9:	e8 54 01 00 00       	call   800542 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ee:	83 c4 08             	add    $0x8,%esp
  8003f1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003f7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003fd:	50                   	push   %eax
  8003fe:	e8 d4 08 00 00       	call   800cd7 <sys_cputs>

	return b.cnt;
}
  800403:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800409:	c9                   	leave  
  80040a:	c3                   	ret    

0080040b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80040b:	55                   	push   %ebp
  80040c:	89 e5                	mov    %esp,%ebp
  80040e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800411:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800414:	50                   	push   %eax
  800415:	ff 75 08             	pushl  0x8(%ebp)
  800418:	e8 9d ff ff ff       	call   8003ba <vcprintf>
	va_end(ap);

	return cnt;
}
  80041d:	c9                   	leave  
  80041e:	c3                   	ret    

0080041f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
  800422:	57                   	push   %edi
  800423:	56                   	push   %esi
  800424:	53                   	push   %ebx
  800425:	83 ec 1c             	sub    $0x1c,%esp
  800428:	89 c7                	mov    %eax,%edi
  80042a:	89 d6                	mov    %edx,%esi
  80042c:	8b 45 08             	mov    0x8(%ebp),%eax
  80042f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800432:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800435:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800438:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80043b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800440:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800443:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800446:	39 d3                	cmp    %edx,%ebx
  800448:	72 05                	jb     80044f <printnum+0x30>
  80044a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80044d:	77 45                	ja     800494 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80044f:	83 ec 0c             	sub    $0xc,%esp
  800452:	ff 75 18             	pushl  0x18(%ebp)
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80045b:	53                   	push   %ebx
  80045c:	ff 75 10             	pushl  0x10(%ebp)
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	ff 75 e4             	pushl  -0x1c(%ebp)
  800465:	ff 75 e0             	pushl  -0x20(%ebp)
  800468:	ff 75 dc             	pushl  -0x24(%ebp)
  80046b:	ff 75 d8             	pushl  -0x28(%ebp)
  80046e:	e8 cd 21 00 00       	call   802640 <__udivdi3>
  800473:	83 c4 18             	add    $0x18,%esp
  800476:	52                   	push   %edx
  800477:	50                   	push   %eax
  800478:	89 f2                	mov    %esi,%edx
  80047a:	89 f8                	mov    %edi,%eax
  80047c:	e8 9e ff ff ff       	call   80041f <printnum>
  800481:	83 c4 20             	add    $0x20,%esp
  800484:	eb 18                	jmp    80049e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	56                   	push   %esi
  80048a:	ff 75 18             	pushl  0x18(%ebp)
  80048d:	ff d7                	call   *%edi
  80048f:	83 c4 10             	add    $0x10,%esp
  800492:	eb 03                	jmp    800497 <printnum+0x78>
  800494:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800497:	83 eb 01             	sub    $0x1,%ebx
  80049a:	85 db                	test   %ebx,%ebx
  80049c:	7f e8                	jg     800486 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	56                   	push   %esi
  8004a2:	83 ec 04             	sub    $0x4,%esp
  8004a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ab:	ff 75 dc             	pushl  -0x24(%ebp)
  8004ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b1:	e8 ba 22 00 00       	call   802770 <__umoddi3>
  8004b6:	83 c4 14             	add    $0x14,%esp
  8004b9:	0f be 80 5f 2a 80 00 	movsbl 0x802a5f(%eax),%eax
  8004c0:	50                   	push   %eax
  8004c1:	ff d7                	call   *%edi
}
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004c9:	5b                   	pop    %ebx
  8004ca:	5e                   	pop    %esi
  8004cb:	5f                   	pop    %edi
  8004cc:	5d                   	pop    %ebp
  8004cd:	c3                   	ret    

008004ce <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004ce:	55                   	push   %ebp
  8004cf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004d1:	83 fa 01             	cmp    $0x1,%edx
  8004d4:	7e 0e                	jle    8004e4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004d6:	8b 10                	mov    (%eax),%edx
  8004d8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004db:	89 08                	mov    %ecx,(%eax)
  8004dd:	8b 02                	mov    (%edx),%eax
  8004df:	8b 52 04             	mov    0x4(%edx),%edx
  8004e2:	eb 22                	jmp    800506 <getuint+0x38>
	else if (lflag)
  8004e4:	85 d2                	test   %edx,%edx
  8004e6:	74 10                	je     8004f8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004e8:	8b 10                	mov    (%eax),%edx
  8004ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ed:	89 08                	mov    %ecx,(%eax)
  8004ef:	8b 02                	mov    (%edx),%eax
  8004f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f6:	eb 0e                	jmp    800506 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004f8:	8b 10                	mov    (%eax),%edx
  8004fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004fd:	89 08                	mov    %ecx,(%eax)
  8004ff:	8b 02                	mov    (%edx),%eax
  800501:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800506:	5d                   	pop    %ebp
  800507:	c3                   	ret    

00800508 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800508:	55                   	push   %ebp
  800509:	89 e5                	mov    %esp,%ebp
  80050b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80050e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800512:	8b 10                	mov    (%eax),%edx
  800514:	3b 50 04             	cmp    0x4(%eax),%edx
  800517:	73 0a                	jae    800523 <sprintputch+0x1b>
		*b->buf++ = ch;
  800519:	8d 4a 01             	lea    0x1(%edx),%ecx
  80051c:	89 08                	mov    %ecx,(%eax)
  80051e:	8b 45 08             	mov    0x8(%ebp),%eax
  800521:	88 02                	mov    %al,(%edx)
}
  800523:	5d                   	pop    %ebp
  800524:	c3                   	ret    

00800525 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800525:	55                   	push   %ebp
  800526:	89 e5                	mov    %esp,%ebp
  800528:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80052b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80052e:	50                   	push   %eax
  80052f:	ff 75 10             	pushl  0x10(%ebp)
  800532:	ff 75 0c             	pushl  0xc(%ebp)
  800535:	ff 75 08             	pushl  0x8(%ebp)
  800538:	e8 05 00 00 00       	call   800542 <vprintfmt>
	va_end(ap);
}
  80053d:	83 c4 10             	add    $0x10,%esp
  800540:	c9                   	leave  
  800541:	c3                   	ret    

00800542 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800542:	55                   	push   %ebp
  800543:	89 e5                	mov    %esp,%ebp
  800545:	57                   	push   %edi
  800546:	56                   	push   %esi
  800547:	53                   	push   %ebx
  800548:	83 ec 2c             	sub    $0x2c,%esp
  80054b:	8b 75 08             	mov    0x8(%ebp),%esi
  80054e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800551:	8b 7d 10             	mov    0x10(%ebp),%edi
  800554:	eb 12                	jmp    800568 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800556:	85 c0                	test   %eax,%eax
  800558:	0f 84 89 03 00 00    	je     8008e7 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	53                   	push   %ebx
  800562:	50                   	push   %eax
  800563:	ff d6                	call   *%esi
  800565:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800568:	83 c7 01             	add    $0x1,%edi
  80056b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056f:	83 f8 25             	cmp    $0x25,%eax
  800572:	75 e2                	jne    800556 <vprintfmt+0x14>
  800574:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800578:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80057f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800586:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80058d:	ba 00 00 00 00       	mov    $0x0,%edx
  800592:	eb 07                	jmp    80059b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800594:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800597:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059b:	8d 47 01             	lea    0x1(%edi),%eax
  80059e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005a1:	0f b6 07             	movzbl (%edi),%eax
  8005a4:	0f b6 c8             	movzbl %al,%ecx
  8005a7:	83 e8 23             	sub    $0x23,%eax
  8005aa:	3c 55                	cmp    $0x55,%al
  8005ac:	0f 87 1a 03 00 00    	ja     8008cc <vprintfmt+0x38a>
  8005b2:	0f b6 c0             	movzbl %al,%eax
  8005b5:	ff 24 85 a0 2b 80 00 	jmp    *0x802ba0(,%eax,4)
  8005bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005bf:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005c3:	eb d6                	jmp    80059b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005cd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005d0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005d3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005d7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005da:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005dd:	83 fa 09             	cmp    $0x9,%edx
  8005e0:	77 39                	ja     80061b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005e2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005e5:	eb e9                	jmp    8005d0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8d 48 04             	lea    0x4(%eax),%ecx
  8005ed:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005f0:	8b 00                	mov    (%eax),%eax
  8005f2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005f8:	eb 27                	jmp    800621 <vprintfmt+0xdf>
  8005fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005fd:	85 c0                	test   %eax,%eax
  8005ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800604:	0f 49 c8             	cmovns %eax,%ecx
  800607:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80060d:	eb 8c                	jmp    80059b <vprintfmt+0x59>
  80060f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800612:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800619:	eb 80                	jmp    80059b <vprintfmt+0x59>
  80061b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800621:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800625:	0f 89 70 ff ff ff    	jns    80059b <vprintfmt+0x59>
				width = precision, precision = -1;
  80062b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80062e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800631:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800638:	e9 5e ff ff ff       	jmp    80059b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80063d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800640:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800643:	e9 53 ff ff ff       	jmp    80059b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8d 50 04             	lea    0x4(%eax),%edx
  80064e:	89 55 14             	mov    %edx,0x14(%ebp)
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	ff 30                	pushl  (%eax)
  800657:	ff d6                	call   *%esi
			break;
  800659:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80065f:	e9 04 ff ff ff       	jmp    800568 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8d 50 04             	lea    0x4(%eax),%edx
  80066a:	89 55 14             	mov    %edx,0x14(%ebp)
  80066d:	8b 00                	mov    (%eax),%eax
  80066f:	99                   	cltd   
  800670:	31 d0                	xor    %edx,%eax
  800672:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800674:	83 f8 0f             	cmp    $0xf,%eax
  800677:	7f 0b                	jg     800684 <vprintfmt+0x142>
  800679:	8b 14 85 00 2d 80 00 	mov    0x802d00(,%eax,4),%edx
  800680:	85 d2                	test   %edx,%edx
  800682:	75 18                	jne    80069c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800684:	50                   	push   %eax
  800685:	68 77 2a 80 00       	push   $0x802a77
  80068a:	53                   	push   %ebx
  80068b:	56                   	push   %esi
  80068c:	e8 94 fe ff ff       	call   800525 <printfmt>
  800691:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800694:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800697:	e9 cc fe ff ff       	jmp    800568 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80069c:	52                   	push   %edx
  80069d:	68 f2 2e 80 00       	push   $0x802ef2
  8006a2:	53                   	push   %ebx
  8006a3:	56                   	push   %esi
  8006a4:	e8 7c fe ff ff       	call   800525 <printfmt>
  8006a9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006af:	e9 b4 fe ff ff       	jmp    800568 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bd:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006bf:	85 ff                	test   %edi,%edi
  8006c1:	b8 70 2a 80 00       	mov    $0x802a70,%eax
  8006c6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006cd:	0f 8e 94 00 00 00    	jle    800767 <vprintfmt+0x225>
  8006d3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006d7:	0f 84 98 00 00 00    	je     800775 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006dd:	83 ec 08             	sub    $0x8,%esp
  8006e0:	ff 75 d0             	pushl  -0x30(%ebp)
  8006e3:	57                   	push   %edi
  8006e4:	e8 86 02 00 00       	call   80096f <strnlen>
  8006e9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006ec:	29 c1                	sub    %eax,%ecx
  8006ee:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006f1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006f4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006fb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006fe:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800700:	eb 0f                	jmp    800711 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800702:	83 ec 08             	sub    $0x8,%esp
  800705:	53                   	push   %ebx
  800706:	ff 75 e0             	pushl  -0x20(%ebp)
  800709:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80070b:	83 ef 01             	sub    $0x1,%edi
  80070e:	83 c4 10             	add    $0x10,%esp
  800711:	85 ff                	test   %edi,%edi
  800713:	7f ed                	jg     800702 <vprintfmt+0x1c0>
  800715:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800718:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80071b:	85 c9                	test   %ecx,%ecx
  80071d:	b8 00 00 00 00       	mov    $0x0,%eax
  800722:	0f 49 c1             	cmovns %ecx,%eax
  800725:	29 c1                	sub    %eax,%ecx
  800727:	89 75 08             	mov    %esi,0x8(%ebp)
  80072a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80072d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800730:	89 cb                	mov    %ecx,%ebx
  800732:	eb 4d                	jmp    800781 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800734:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800738:	74 1b                	je     800755 <vprintfmt+0x213>
  80073a:	0f be c0             	movsbl %al,%eax
  80073d:	83 e8 20             	sub    $0x20,%eax
  800740:	83 f8 5e             	cmp    $0x5e,%eax
  800743:	76 10                	jbe    800755 <vprintfmt+0x213>
					putch('?', putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	ff 75 0c             	pushl  0xc(%ebp)
  80074b:	6a 3f                	push   $0x3f
  80074d:	ff 55 08             	call   *0x8(%ebp)
  800750:	83 c4 10             	add    $0x10,%esp
  800753:	eb 0d                	jmp    800762 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800755:	83 ec 08             	sub    $0x8,%esp
  800758:	ff 75 0c             	pushl  0xc(%ebp)
  80075b:	52                   	push   %edx
  80075c:	ff 55 08             	call   *0x8(%ebp)
  80075f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800762:	83 eb 01             	sub    $0x1,%ebx
  800765:	eb 1a                	jmp    800781 <vprintfmt+0x23f>
  800767:	89 75 08             	mov    %esi,0x8(%ebp)
  80076a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80076d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800770:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800773:	eb 0c                	jmp    800781 <vprintfmt+0x23f>
  800775:	89 75 08             	mov    %esi,0x8(%ebp)
  800778:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80077b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80077e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800781:	83 c7 01             	add    $0x1,%edi
  800784:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800788:	0f be d0             	movsbl %al,%edx
  80078b:	85 d2                	test   %edx,%edx
  80078d:	74 23                	je     8007b2 <vprintfmt+0x270>
  80078f:	85 f6                	test   %esi,%esi
  800791:	78 a1                	js     800734 <vprintfmt+0x1f2>
  800793:	83 ee 01             	sub    $0x1,%esi
  800796:	79 9c                	jns    800734 <vprintfmt+0x1f2>
  800798:	89 df                	mov    %ebx,%edi
  80079a:	8b 75 08             	mov    0x8(%ebp),%esi
  80079d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a0:	eb 18                	jmp    8007ba <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007a2:	83 ec 08             	sub    $0x8,%esp
  8007a5:	53                   	push   %ebx
  8007a6:	6a 20                	push   $0x20
  8007a8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007aa:	83 ef 01             	sub    $0x1,%edi
  8007ad:	83 c4 10             	add    $0x10,%esp
  8007b0:	eb 08                	jmp    8007ba <vprintfmt+0x278>
  8007b2:	89 df                	mov    %ebx,%edi
  8007b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ba:	85 ff                	test   %edi,%edi
  8007bc:	7f e4                	jg     8007a2 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c1:	e9 a2 fd ff ff       	jmp    800568 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007c6:	83 fa 01             	cmp    $0x1,%edx
  8007c9:	7e 16                	jle    8007e1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8d 50 08             	lea    0x8(%eax),%edx
  8007d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d4:	8b 50 04             	mov    0x4(%eax),%edx
  8007d7:	8b 00                	mov    (%eax),%eax
  8007d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007dc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007df:	eb 32                	jmp    800813 <vprintfmt+0x2d1>
	else if (lflag)
  8007e1:	85 d2                	test   %edx,%edx
  8007e3:	74 18                	je     8007fd <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e8:	8d 50 04             	lea    0x4(%eax),%edx
  8007eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ee:	8b 00                	mov    (%eax),%eax
  8007f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f3:	89 c1                	mov    %eax,%ecx
  8007f5:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007fb:	eb 16                	jmp    800813 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800800:	8d 50 04             	lea    0x4(%eax),%edx
  800803:	89 55 14             	mov    %edx,0x14(%ebp)
  800806:	8b 00                	mov    (%eax),%eax
  800808:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80080b:	89 c1                	mov    %eax,%ecx
  80080d:	c1 f9 1f             	sar    $0x1f,%ecx
  800810:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800813:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800816:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800819:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80081e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800822:	79 74                	jns    800898 <vprintfmt+0x356>
				putch('-', putdat);
  800824:	83 ec 08             	sub    $0x8,%esp
  800827:	53                   	push   %ebx
  800828:	6a 2d                	push   $0x2d
  80082a:	ff d6                	call   *%esi
				num = -(long long) num;
  80082c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80082f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800832:	f7 d8                	neg    %eax
  800834:	83 d2 00             	adc    $0x0,%edx
  800837:	f7 da                	neg    %edx
  800839:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80083c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800841:	eb 55                	jmp    800898 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800843:	8d 45 14             	lea    0x14(%ebp),%eax
  800846:	e8 83 fc ff ff       	call   8004ce <getuint>
			base = 10;
  80084b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800850:	eb 46                	jmp    800898 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800852:	8d 45 14             	lea    0x14(%ebp),%eax
  800855:	e8 74 fc ff ff       	call   8004ce <getuint>
                        base = 8;
  80085a:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80085f:	eb 37                	jmp    800898 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800861:	83 ec 08             	sub    $0x8,%esp
  800864:	53                   	push   %ebx
  800865:	6a 30                	push   $0x30
  800867:	ff d6                	call   *%esi
			putch('x', putdat);
  800869:	83 c4 08             	add    $0x8,%esp
  80086c:	53                   	push   %ebx
  80086d:	6a 78                	push   $0x78
  80086f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800871:	8b 45 14             	mov    0x14(%ebp),%eax
  800874:	8d 50 04             	lea    0x4(%eax),%edx
  800877:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80087a:	8b 00                	mov    (%eax),%eax
  80087c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800881:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800884:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800889:	eb 0d                	jmp    800898 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80088b:	8d 45 14             	lea    0x14(%ebp),%eax
  80088e:	e8 3b fc ff ff       	call   8004ce <getuint>
			base = 16;
  800893:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800898:	83 ec 0c             	sub    $0xc,%esp
  80089b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80089f:	57                   	push   %edi
  8008a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8008a3:	51                   	push   %ecx
  8008a4:	52                   	push   %edx
  8008a5:	50                   	push   %eax
  8008a6:	89 da                	mov    %ebx,%edx
  8008a8:	89 f0                	mov    %esi,%eax
  8008aa:	e8 70 fb ff ff       	call   80041f <printnum>
			break;
  8008af:	83 c4 20             	add    $0x20,%esp
  8008b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008b5:	e9 ae fc ff ff       	jmp    800568 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008ba:	83 ec 08             	sub    $0x8,%esp
  8008bd:	53                   	push   %ebx
  8008be:	51                   	push   %ecx
  8008bf:	ff d6                	call   *%esi
			break;
  8008c1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008c7:	e9 9c fc ff ff       	jmp    800568 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008cc:	83 ec 08             	sub    $0x8,%esp
  8008cf:	53                   	push   %ebx
  8008d0:	6a 25                	push   $0x25
  8008d2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008d4:	83 c4 10             	add    $0x10,%esp
  8008d7:	eb 03                	jmp    8008dc <vprintfmt+0x39a>
  8008d9:	83 ef 01             	sub    $0x1,%edi
  8008dc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008e0:	75 f7                	jne    8008d9 <vprintfmt+0x397>
  8008e2:	e9 81 fc ff ff       	jmp    800568 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008ea:	5b                   	pop    %ebx
  8008eb:	5e                   	pop    %esi
  8008ec:	5f                   	pop    %edi
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	83 ec 18             	sub    $0x18,%esp
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008fe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800902:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800905:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80090c:	85 c0                	test   %eax,%eax
  80090e:	74 26                	je     800936 <vsnprintf+0x47>
  800910:	85 d2                	test   %edx,%edx
  800912:	7e 22                	jle    800936 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800914:	ff 75 14             	pushl  0x14(%ebp)
  800917:	ff 75 10             	pushl  0x10(%ebp)
  80091a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80091d:	50                   	push   %eax
  80091e:	68 08 05 80 00       	push   $0x800508
  800923:	e8 1a fc ff ff       	call   800542 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800928:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80092b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80092e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800931:	83 c4 10             	add    $0x10,%esp
  800934:	eb 05                	jmp    80093b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800936:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80093b:	c9                   	leave  
  80093c:	c3                   	ret    

0080093d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800943:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800946:	50                   	push   %eax
  800947:	ff 75 10             	pushl  0x10(%ebp)
  80094a:	ff 75 0c             	pushl  0xc(%ebp)
  80094d:	ff 75 08             	pushl  0x8(%ebp)
  800950:	e8 9a ff ff ff       	call   8008ef <vsnprintf>
	va_end(ap);

	return rc;
}
  800955:	c9                   	leave  
  800956:	c3                   	ret    

00800957 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80095d:	b8 00 00 00 00       	mov    $0x0,%eax
  800962:	eb 03                	jmp    800967 <strlen+0x10>
		n++;
  800964:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800967:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80096b:	75 f7                	jne    800964 <strlen+0xd>
		n++;
	return n;
}
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800975:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800978:	ba 00 00 00 00       	mov    $0x0,%edx
  80097d:	eb 03                	jmp    800982 <strnlen+0x13>
		n++;
  80097f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800982:	39 c2                	cmp    %eax,%edx
  800984:	74 08                	je     80098e <strnlen+0x1f>
  800986:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80098a:	75 f3                	jne    80097f <strnlen+0x10>
  80098c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	53                   	push   %ebx
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80099a:	89 c2                	mov    %eax,%edx
  80099c:	83 c2 01             	add    $0x1,%edx
  80099f:	83 c1 01             	add    $0x1,%ecx
  8009a2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009a6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009a9:	84 db                	test   %bl,%bl
  8009ab:	75 ef                	jne    80099c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009ad:	5b                   	pop    %ebx
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	53                   	push   %ebx
  8009b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009b7:	53                   	push   %ebx
  8009b8:	e8 9a ff ff ff       	call   800957 <strlen>
  8009bd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009c0:	ff 75 0c             	pushl  0xc(%ebp)
  8009c3:	01 d8                	add    %ebx,%eax
  8009c5:	50                   	push   %eax
  8009c6:	e8 c5 ff ff ff       	call   800990 <strcpy>
	return dst;
}
  8009cb:	89 d8                	mov    %ebx,%eax
  8009cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d0:	c9                   	leave  
  8009d1:	c3                   	ret    

008009d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	56                   	push   %esi
  8009d6:	53                   	push   %ebx
  8009d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009dd:	89 f3                	mov    %esi,%ebx
  8009df:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e2:	89 f2                	mov    %esi,%edx
  8009e4:	eb 0f                	jmp    8009f5 <strncpy+0x23>
		*dst++ = *src;
  8009e6:	83 c2 01             	add    $0x1,%edx
  8009e9:	0f b6 01             	movzbl (%ecx),%eax
  8009ec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ef:	80 39 01             	cmpb   $0x1,(%ecx)
  8009f2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f5:	39 da                	cmp    %ebx,%edx
  8009f7:	75 ed                	jne    8009e6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009f9:	89 f0                	mov    %esi,%eax
  8009fb:	5b                   	pop    %ebx
  8009fc:	5e                   	pop    %esi
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	8b 75 08             	mov    0x8(%ebp),%esi
  800a07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a0a:	8b 55 10             	mov    0x10(%ebp),%edx
  800a0d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a0f:	85 d2                	test   %edx,%edx
  800a11:	74 21                	je     800a34 <strlcpy+0x35>
  800a13:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a17:	89 f2                	mov    %esi,%edx
  800a19:	eb 09                	jmp    800a24 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a1b:	83 c2 01             	add    $0x1,%edx
  800a1e:	83 c1 01             	add    $0x1,%ecx
  800a21:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a24:	39 c2                	cmp    %eax,%edx
  800a26:	74 09                	je     800a31 <strlcpy+0x32>
  800a28:	0f b6 19             	movzbl (%ecx),%ebx
  800a2b:	84 db                	test   %bl,%bl
  800a2d:	75 ec                	jne    800a1b <strlcpy+0x1c>
  800a2f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a31:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a34:	29 f0                	sub    %esi,%eax
}
  800a36:	5b                   	pop    %ebx
  800a37:	5e                   	pop    %esi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a40:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a43:	eb 06                	jmp    800a4b <strcmp+0x11>
		p++, q++;
  800a45:	83 c1 01             	add    $0x1,%ecx
  800a48:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a4b:	0f b6 01             	movzbl (%ecx),%eax
  800a4e:	84 c0                	test   %al,%al
  800a50:	74 04                	je     800a56 <strcmp+0x1c>
  800a52:	3a 02                	cmp    (%edx),%al
  800a54:	74 ef                	je     800a45 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a56:	0f b6 c0             	movzbl %al,%eax
  800a59:	0f b6 12             	movzbl (%edx),%edx
  800a5c:	29 d0                	sub    %edx,%eax
}
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	53                   	push   %ebx
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6a:	89 c3                	mov    %eax,%ebx
  800a6c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a6f:	eb 06                	jmp    800a77 <strncmp+0x17>
		n--, p++, q++;
  800a71:	83 c0 01             	add    $0x1,%eax
  800a74:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a77:	39 d8                	cmp    %ebx,%eax
  800a79:	74 15                	je     800a90 <strncmp+0x30>
  800a7b:	0f b6 08             	movzbl (%eax),%ecx
  800a7e:	84 c9                	test   %cl,%cl
  800a80:	74 04                	je     800a86 <strncmp+0x26>
  800a82:	3a 0a                	cmp    (%edx),%cl
  800a84:	74 eb                	je     800a71 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a86:	0f b6 00             	movzbl (%eax),%eax
  800a89:	0f b6 12             	movzbl (%edx),%edx
  800a8c:	29 d0                	sub    %edx,%eax
  800a8e:	eb 05                	jmp    800a95 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a90:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a95:	5b                   	pop    %ebx
  800a96:	5d                   	pop    %ebp
  800a97:	c3                   	ret    

00800a98 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa2:	eb 07                	jmp    800aab <strchr+0x13>
		if (*s == c)
  800aa4:	38 ca                	cmp    %cl,%dl
  800aa6:	74 0f                	je     800ab7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aa8:	83 c0 01             	add    $0x1,%eax
  800aab:	0f b6 10             	movzbl (%eax),%edx
  800aae:	84 d2                	test   %dl,%dl
  800ab0:	75 f2                	jne    800aa4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ab2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	8b 45 08             	mov    0x8(%ebp),%eax
  800abf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac3:	eb 03                	jmp    800ac8 <strfind+0xf>
  800ac5:	83 c0 01             	add    $0x1,%eax
  800ac8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800acb:	38 ca                	cmp    %cl,%dl
  800acd:	74 04                	je     800ad3 <strfind+0x1a>
  800acf:	84 d2                	test   %dl,%dl
  800ad1:	75 f2                	jne    800ac5 <strfind+0xc>
			break;
	return (char *) s;
}
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	57                   	push   %edi
  800ad9:	56                   	push   %esi
  800ada:	53                   	push   %ebx
  800adb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ade:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ae1:	85 c9                	test   %ecx,%ecx
  800ae3:	74 36                	je     800b1b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ae5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aeb:	75 28                	jne    800b15 <memset+0x40>
  800aed:	f6 c1 03             	test   $0x3,%cl
  800af0:	75 23                	jne    800b15 <memset+0x40>
		c &= 0xFF;
  800af2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800af6:	89 d3                	mov    %edx,%ebx
  800af8:	c1 e3 08             	shl    $0x8,%ebx
  800afb:	89 d6                	mov    %edx,%esi
  800afd:	c1 e6 18             	shl    $0x18,%esi
  800b00:	89 d0                	mov    %edx,%eax
  800b02:	c1 e0 10             	shl    $0x10,%eax
  800b05:	09 f0                	or     %esi,%eax
  800b07:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b09:	89 d8                	mov    %ebx,%eax
  800b0b:	09 d0                	or     %edx,%eax
  800b0d:	c1 e9 02             	shr    $0x2,%ecx
  800b10:	fc                   	cld    
  800b11:	f3 ab                	rep stos %eax,%es:(%edi)
  800b13:	eb 06                	jmp    800b1b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b18:	fc                   	cld    
  800b19:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b1b:	89 f8                	mov    %edi,%eax
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	57                   	push   %edi
  800b26:	56                   	push   %esi
  800b27:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b30:	39 c6                	cmp    %eax,%esi
  800b32:	73 35                	jae    800b69 <memmove+0x47>
  800b34:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b37:	39 d0                	cmp    %edx,%eax
  800b39:	73 2e                	jae    800b69 <memmove+0x47>
		s += n;
		d += n;
  800b3b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b3e:	89 d6                	mov    %edx,%esi
  800b40:	09 fe                	or     %edi,%esi
  800b42:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b48:	75 13                	jne    800b5d <memmove+0x3b>
  800b4a:	f6 c1 03             	test   $0x3,%cl
  800b4d:	75 0e                	jne    800b5d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b4f:	83 ef 04             	sub    $0x4,%edi
  800b52:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b55:	c1 e9 02             	shr    $0x2,%ecx
  800b58:	fd                   	std    
  800b59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b5b:	eb 09                	jmp    800b66 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b5d:	83 ef 01             	sub    $0x1,%edi
  800b60:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b63:	fd                   	std    
  800b64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b66:	fc                   	cld    
  800b67:	eb 1d                	jmp    800b86 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b69:	89 f2                	mov    %esi,%edx
  800b6b:	09 c2                	or     %eax,%edx
  800b6d:	f6 c2 03             	test   $0x3,%dl
  800b70:	75 0f                	jne    800b81 <memmove+0x5f>
  800b72:	f6 c1 03             	test   $0x3,%cl
  800b75:	75 0a                	jne    800b81 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b77:	c1 e9 02             	shr    $0x2,%ecx
  800b7a:	89 c7                	mov    %eax,%edi
  800b7c:	fc                   	cld    
  800b7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7f:	eb 05                	jmp    800b86 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b81:	89 c7                	mov    %eax,%edi
  800b83:	fc                   	cld    
  800b84:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b86:	5e                   	pop    %esi
  800b87:	5f                   	pop    %edi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b8d:	ff 75 10             	pushl  0x10(%ebp)
  800b90:	ff 75 0c             	pushl  0xc(%ebp)
  800b93:	ff 75 08             	pushl  0x8(%ebp)
  800b96:	e8 87 ff ff ff       	call   800b22 <memmove>
}
  800b9b:	c9                   	leave  
  800b9c:	c3                   	ret    

00800b9d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
  800ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba8:	89 c6                	mov    %eax,%esi
  800baa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bad:	eb 1a                	jmp    800bc9 <memcmp+0x2c>
		if (*s1 != *s2)
  800baf:	0f b6 08             	movzbl (%eax),%ecx
  800bb2:	0f b6 1a             	movzbl (%edx),%ebx
  800bb5:	38 d9                	cmp    %bl,%cl
  800bb7:	74 0a                	je     800bc3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bb9:	0f b6 c1             	movzbl %cl,%eax
  800bbc:	0f b6 db             	movzbl %bl,%ebx
  800bbf:	29 d8                	sub    %ebx,%eax
  800bc1:	eb 0f                	jmp    800bd2 <memcmp+0x35>
		s1++, s2++;
  800bc3:	83 c0 01             	add    $0x1,%eax
  800bc6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc9:	39 f0                	cmp    %esi,%eax
  800bcb:	75 e2                	jne    800baf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	53                   	push   %ebx
  800bda:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bdd:	89 c1                	mov    %eax,%ecx
  800bdf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800be2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be6:	eb 0a                	jmp    800bf2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800be8:	0f b6 10             	movzbl (%eax),%edx
  800beb:	39 da                	cmp    %ebx,%edx
  800bed:	74 07                	je     800bf6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bef:	83 c0 01             	add    $0x1,%eax
  800bf2:	39 c8                	cmp    %ecx,%eax
  800bf4:	72 f2                	jb     800be8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bf6:	5b                   	pop    %ebx
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
  800bff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c05:	eb 03                	jmp    800c0a <strtol+0x11>
		s++;
  800c07:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c0a:	0f b6 01             	movzbl (%ecx),%eax
  800c0d:	3c 20                	cmp    $0x20,%al
  800c0f:	74 f6                	je     800c07 <strtol+0xe>
  800c11:	3c 09                	cmp    $0x9,%al
  800c13:	74 f2                	je     800c07 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c15:	3c 2b                	cmp    $0x2b,%al
  800c17:	75 0a                	jne    800c23 <strtol+0x2a>
		s++;
  800c19:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c1c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c21:	eb 11                	jmp    800c34 <strtol+0x3b>
  800c23:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c28:	3c 2d                	cmp    $0x2d,%al
  800c2a:	75 08                	jne    800c34 <strtol+0x3b>
		s++, neg = 1;
  800c2c:	83 c1 01             	add    $0x1,%ecx
  800c2f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c34:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c3a:	75 15                	jne    800c51 <strtol+0x58>
  800c3c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c3f:	75 10                	jne    800c51 <strtol+0x58>
  800c41:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c45:	75 7c                	jne    800cc3 <strtol+0xca>
		s += 2, base = 16;
  800c47:	83 c1 02             	add    $0x2,%ecx
  800c4a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c4f:	eb 16                	jmp    800c67 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c51:	85 db                	test   %ebx,%ebx
  800c53:	75 12                	jne    800c67 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c55:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c5a:	80 39 30             	cmpb   $0x30,(%ecx)
  800c5d:	75 08                	jne    800c67 <strtol+0x6e>
		s++, base = 8;
  800c5f:	83 c1 01             	add    $0x1,%ecx
  800c62:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c67:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c6f:	0f b6 11             	movzbl (%ecx),%edx
  800c72:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c75:	89 f3                	mov    %esi,%ebx
  800c77:	80 fb 09             	cmp    $0x9,%bl
  800c7a:	77 08                	ja     800c84 <strtol+0x8b>
			dig = *s - '0';
  800c7c:	0f be d2             	movsbl %dl,%edx
  800c7f:	83 ea 30             	sub    $0x30,%edx
  800c82:	eb 22                	jmp    800ca6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c84:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c87:	89 f3                	mov    %esi,%ebx
  800c89:	80 fb 19             	cmp    $0x19,%bl
  800c8c:	77 08                	ja     800c96 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c8e:	0f be d2             	movsbl %dl,%edx
  800c91:	83 ea 57             	sub    $0x57,%edx
  800c94:	eb 10                	jmp    800ca6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c96:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c99:	89 f3                	mov    %esi,%ebx
  800c9b:	80 fb 19             	cmp    $0x19,%bl
  800c9e:	77 16                	ja     800cb6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ca0:	0f be d2             	movsbl %dl,%edx
  800ca3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ca6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ca9:	7d 0b                	jge    800cb6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cab:	83 c1 01             	add    $0x1,%ecx
  800cae:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cb2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cb4:	eb b9                	jmp    800c6f <strtol+0x76>

	if (endptr)
  800cb6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cba:	74 0d                	je     800cc9 <strtol+0xd0>
		*endptr = (char *) s;
  800cbc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cbf:	89 0e                	mov    %ecx,(%esi)
  800cc1:	eb 06                	jmp    800cc9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cc3:	85 db                	test   %ebx,%ebx
  800cc5:	74 98                	je     800c5f <strtol+0x66>
  800cc7:	eb 9e                	jmp    800c67 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cc9:	89 c2                	mov    %eax,%edx
  800ccb:	f7 da                	neg    %edx
  800ccd:	85 ff                	test   %edi,%edi
  800ccf:	0f 45 c2             	cmovne %edx,%eax
}
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce8:	89 c3                	mov    %eax,%ebx
  800cea:	89 c7                	mov    %eax,%edi
  800cec:	89 c6                	mov    %eax,%esi
  800cee:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	57                   	push   %edi
  800cf9:	56                   	push   %esi
  800cfa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800d00:	b8 01 00 00 00       	mov    $0x1,%eax
  800d05:	89 d1                	mov    %edx,%ecx
  800d07:	89 d3                	mov    %edx,%ebx
  800d09:	89 d7                	mov    %edx,%edi
  800d0b:	89 d6                	mov    %edx,%esi
  800d0d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
  800d1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d22:	b8 03 00 00 00       	mov    $0x3,%eax
  800d27:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2a:	89 cb                	mov    %ecx,%ebx
  800d2c:	89 cf                	mov    %ecx,%edi
  800d2e:	89 ce                	mov    %ecx,%esi
  800d30:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d32:	85 c0                	test   %eax,%eax
  800d34:	7e 17                	jle    800d4d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d36:	83 ec 0c             	sub    $0xc,%esp
  800d39:	50                   	push   %eax
  800d3a:	6a 03                	push   $0x3
  800d3c:	68 5f 2d 80 00       	push   $0x802d5f
  800d41:	6a 23                	push   $0x23
  800d43:	68 7c 2d 80 00       	push   $0x802d7c
  800d48:	e8 e5 f5 ff ff       	call   800332 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	57                   	push   %edi
  800d59:	56                   	push   %esi
  800d5a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d60:	b8 02 00 00 00       	mov    $0x2,%eax
  800d65:	89 d1                	mov    %edx,%ecx
  800d67:	89 d3                	mov    %edx,%ebx
  800d69:	89 d7                	mov    %edx,%edi
  800d6b:	89 d6                	mov    %edx,%esi
  800d6d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5f                   	pop    %edi
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <sys_yield>:

void
sys_yield(void)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d84:	89 d1                	mov    %edx,%ecx
  800d86:	89 d3                	mov    %edx,%ebx
  800d88:	89 d7                	mov    %edx,%edi
  800d8a:	89 d6                	mov    %edx,%esi
  800d8c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	57                   	push   %edi
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
  800d99:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9c:	be 00 00 00 00       	mov    $0x0,%esi
  800da1:	b8 04 00 00 00       	mov    $0x4,%eax
  800da6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800daf:	89 f7                	mov    %esi,%edi
  800db1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db3:	85 c0                	test   %eax,%eax
  800db5:	7e 17                	jle    800dce <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db7:	83 ec 0c             	sub    $0xc,%esp
  800dba:	50                   	push   %eax
  800dbb:	6a 04                	push   $0x4
  800dbd:	68 5f 2d 80 00       	push   $0x802d5f
  800dc2:	6a 23                	push   $0x23
  800dc4:	68 7c 2d 80 00       	push   $0x802d7c
  800dc9:	e8 64 f5 ff ff       	call   800332 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd1:	5b                   	pop    %ebx
  800dd2:	5e                   	pop    %esi
  800dd3:	5f                   	pop    %edi
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    

00800dd6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	57                   	push   %edi
  800dda:	56                   	push   %esi
  800ddb:	53                   	push   %ebx
  800ddc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddf:	b8 05 00 00 00       	mov    $0x5,%eax
  800de4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ded:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df0:	8b 75 18             	mov    0x18(%ebp),%esi
  800df3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df5:	85 c0                	test   %eax,%eax
  800df7:	7e 17                	jle    800e10 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df9:	83 ec 0c             	sub    $0xc,%esp
  800dfc:	50                   	push   %eax
  800dfd:	6a 05                	push   $0x5
  800dff:	68 5f 2d 80 00       	push   $0x802d5f
  800e04:	6a 23                	push   $0x23
  800e06:	68 7c 2d 80 00       	push   $0x802d7c
  800e0b:	e8 22 f5 ff ff       	call   800332 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    

00800e18 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	57                   	push   %edi
  800e1c:	56                   	push   %esi
  800e1d:	53                   	push   %ebx
  800e1e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e21:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e26:	b8 06 00 00 00       	mov    $0x6,%eax
  800e2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e31:	89 df                	mov    %ebx,%edi
  800e33:	89 de                	mov    %ebx,%esi
  800e35:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e37:	85 c0                	test   %eax,%eax
  800e39:	7e 17                	jle    800e52 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3b:	83 ec 0c             	sub    $0xc,%esp
  800e3e:	50                   	push   %eax
  800e3f:	6a 06                	push   $0x6
  800e41:	68 5f 2d 80 00       	push   $0x802d5f
  800e46:	6a 23                	push   $0x23
  800e48:	68 7c 2d 80 00       	push   $0x802d7c
  800e4d:	e8 e0 f4 ff ff       	call   800332 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	57                   	push   %edi
  800e5e:	56                   	push   %esi
  800e5f:	53                   	push   %ebx
  800e60:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e68:	b8 08 00 00 00       	mov    $0x8,%eax
  800e6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e70:	8b 55 08             	mov    0x8(%ebp),%edx
  800e73:	89 df                	mov    %ebx,%edi
  800e75:	89 de                	mov    %ebx,%esi
  800e77:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	7e 17                	jle    800e94 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7d:	83 ec 0c             	sub    $0xc,%esp
  800e80:	50                   	push   %eax
  800e81:	6a 08                	push   $0x8
  800e83:	68 5f 2d 80 00       	push   $0x802d5f
  800e88:	6a 23                	push   $0x23
  800e8a:	68 7c 2d 80 00       	push   $0x802d7c
  800e8f:	e8 9e f4 ff ff       	call   800332 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e97:	5b                   	pop    %ebx
  800e98:	5e                   	pop    %esi
  800e99:	5f                   	pop    %edi
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	57                   	push   %edi
  800ea0:	56                   	push   %esi
  800ea1:	53                   	push   %ebx
  800ea2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eaa:	b8 09 00 00 00       	mov    $0x9,%eax
  800eaf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb5:	89 df                	mov    %ebx,%edi
  800eb7:	89 de                	mov    %ebx,%esi
  800eb9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	7e 17                	jle    800ed6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebf:	83 ec 0c             	sub    $0xc,%esp
  800ec2:	50                   	push   %eax
  800ec3:	6a 09                	push   $0x9
  800ec5:	68 5f 2d 80 00       	push   $0x802d5f
  800eca:	6a 23                	push   $0x23
  800ecc:	68 7c 2d 80 00       	push   $0x802d7c
  800ed1:	e8 5c f4 ff ff       	call   800332 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ed6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed9:	5b                   	pop    %ebx
  800eda:	5e                   	pop    %esi
  800edb:	5f                   	pop    %edi
  800edc:	5d                   	pop    %ebp
  800edd:	c3                   	ret    

00800ede <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	57                   	push   %edi
  800ee2:	56                   	push   %esi
  800ee3:	53                   	push   %ebx
  800ee4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eec:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ef1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef7:	89 df                	mov    %ebx,%edi
  800ef9:	89 de                	mov    %ebx,%esi
  800efb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800efd:	85 c0                	test   %eax,%eax
  800eff:	7e 17                	jle    800f18 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f01:	83 ec 0c             	sub    $0xc,%esp
  800f04:	50                   	push   %eax
  800f05:	6a 0a                	push   $0xa
  800f07:	68 5f 2d 80 00       	push   $0x802d5f
  800f0c:	6a 23                	push   $0x23
  800f0e:	68 7c 2d 80 00       	push   $0x802d7c
  800f13:	e8 1a f4 ff ff       	call   800332 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f1b:	5b                   	pop    %ebx
  800f1c:	5e                   	pop    %esi
  800f1d:	5f                   	pop    %edi
  800f1e:	5d                   	pop    %ebp
  800f1f:	c3                   	ret    

00800f20 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	57                   	push   %edi
  800f24:	56                   	push   %esi
  800f25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f26:	be 00 00 00 00       	mov    $0x0,%esi
  800f2b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f33:	8b 55 08             	mov    0x8(%ebp),%edx
  800f36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f39:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f3c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f3e:	5b                   	pop    %ebx
  800f3f:	5e                   	pop    %esi
  800f40:	5f                   	pop    %edi
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    

00800f43 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	57                   	push   %edi
  800f47:	56                   	push   %esi
  800f48:	53                   	push   %ebx
  800f49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f51:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f56:	8b 55 08             	mov    0x8(%ebp),%edx
  800f59:	89 cb                	mov    %ecx,%ebx
  800f5b:	89 cf                	mov    %ecx,%edi
  800f5d:	89 ce                	mov    %ecx,%esi
  800f5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f61:	85 c0                	test   %eax,%eax
  800f63:	7e 17                	jle    800f7c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f65:	83 ec 0c             	sub    $0xc,%esp
  800f68:	50                   	push   %eax
  800f69:	6a 0d                	push   $0xd
  800f6b:	68 5f 2d 80 00       	push   $0x802d5f
  800f70:	6a 23                	push   $0x23
  800f72:	68 7c 2d 80 00       	push   $0x802d7c
  800f77:	e8 b6 f3 ff ff       	call   800332 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f7f:	5b                   	pop    %ebx
  800f80:	5e                   	pop    %esi
  800f81:	5f                   	pop    %edi
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    

00800f84 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	57                   	push   %edi
  800f88:	56                   	push   %esi
  800f89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f8f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f94:	89 d1                	mov    %edx,%ecx
  800f96:	89 d3                	mov    %edx,%ebx
  800f98:	89 d7                	mov    %edx,%edi
  800f9a:	89 d6                	mov    %edx,%esi
  800f9c:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f9e:	5b                   	pop    %ebx
  800f9f:	5e                   	pop    %esi
  800fa0:	5f                   	pop    %edi
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    

00800fa3 <sys_transmit_packet>:

int
sys_transmit_packet(void *buf, size_t size)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	57                   	push   %edi
  800fa7:	56                   	push   %esi
  800fa8:	53                   	push   %ebx
  800fa9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb1:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbc:	89 df                	mov    %ebx,%edi
  800fbe:	89 de                	mov    %ebx,%esi
  800fc0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	7e 17                	jle    800fdd <sys_transmit_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc6:	83 ec 0c             	sub    $0xc,%esp
  800fc9:	50                   	push   %eax
  800fca:	6a 0f                	push   $0xf
  800fcc:	68 5f 2d 80 00       	push   $0x802d5f
  800fd1:	6a 23                	push   $0x23
  800fd3:	68 7c 2d 80 00       	push   $0x802d7c
  800fd8:	e8 55 f3 ff ff       	call   800332 <_panic>
int
sys_transmit_packet(void *buf, size_t size)
{
	return syscall(SYS_transmit_packet, 1,
		(uint32_t) buf, (uint32_t) size, 0, 0, 0);
}
  800fdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe0:	5b                   	pop    %ebx
  800fe1:	5e                   	pop    %esi
  800fe2:	5f                   	pop    %edi
  800fe3:	5d                   	pop    %ebp
  800fe4:	c3                   	ret    

00800fe5 <sys_receive_packet>:

int
sys_receive_packet(void *buf, size_t *size_store)
{
  800fe5:	55                   	push   %ebp
  800fe6:	89 e5                	mov    %esp,%ebp
  800fe8:	57                   	push   %edi
  800fe9:	56                   	push   %esi
  800fea:	53                   	push   %ebx
  800feb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fee:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff3:	b8 10 00 00 00       	mov    $0x10,%eax
  800ff8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffe:	89 df                	mov    %ebx,%edi
  801000:	89 de                	mov    %ebx,%esi
  801002:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801004:	85 c0                	test   %eax,%eax
  801006:	7e 17                	jle    80101f <sys_receive_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	50                   	push   %eax
  80100c:	6a 10                	push   $0x10
  80100e:	68 5f 2d 80 00       	push   $0x802d5f
  801013:	6a 23                	push   $0x23
  801015:	68 7c 2d 80 00       	push   $0x802d7c
  80101a:	e8 13 f3 ff ff       	call   800332 <_panic>
int
sys_receive_packet(void *buf, size_t *size_store)
{
	return syscall(SYS_receive_packet, 1,
		(uint32_t) buf, (uint32_t) size_store, 0, 0, 0);
}
  80101f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801022:	5b                   	pop    %ebx
  801023:	5e                   	pop    %esi
  801024:	5f                   	pop    %edi
  801025:	5d                   	pop    %ebp
  801026:	c3                   	ret    

00801027 <sys_get_mac_address>:

int
sys_get_mac_address(void *buf)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	57                   	push   %edi
  80102b:	56                   	push   %esi
  80102c:	53                   	push   %ebx
  80102d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801030:	b9 00 00 00 00       	mov    $0x0,%ecx
  801035:	b8 11 00 00 00       	mov    $0x11,%eax
  80103a:	8b 55 08             	mov    0x8(%ebp),%edx
  80103d:	89 cb                	mov    %ecx,%ebx
  80103f:	89 cf                	mov    %ecx,%edi
  801041:	89 ce                	mov    %ecx,%esi
  801043:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801045:	85 c0                	test   %eax,%eax
  801047:	7e 17                	jle    801060 <sys_get_mac_address+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801049:	83 ec 0c             	sub    $0xc,%esp
  80104c:	50                   	push   %eax
  80104d:	6a 11                	push   $0x11
  80104f:	68 5f 2d 80 00       	push   $0x802d5f
  801054:	6a 23                	push   $0x23
  801056:	68 7c 2d 80 00       	push   $0x802d7c
  80105b:	e8 d2 f2 ff ff       	call   800332 <_panic>
int
sys_get_mac_address(void *buf)
{
	return syscall(SYS_get_mac_address, 1,
		(uint32_t) buf, 0, 0, 0, 0);
}
  801060:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801063:	5b                   	pop    %ebx
  801064:	5e                   	pop    %esi
  801065:	5f                   	pop    %edi
  801066:	5d                   	pop    %ebp
  801067:	c3                   	ret    

00801068 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	53                   	push   %ebx
  80106c:	83 ec 04             	sub    $0x4,%esp
  80106f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801072:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  801074:	89 da                	mov    %ebx,%edx
  801076:	c1 ea 0c             	shr    $0xc,%edx
	pte_t pte = uvpt[pn];
  801079:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  801080:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801084:	74 05                	je     80108b <pgfault+0x23>
  801086:	f6 c6 08             	test   $0x8,%dh
  801089:	75 14                	jne    80109f <pgfault+0x37>
		panic("fork pgfault handler: does not handle this fault");
  80108b:	83 ec 04             	sub    $0x4,%esp
  80108e:	68 8c 2d 80 00       	push   $0x802d8c
  801093:	6a 1f                	push   $0x1f
  801095:	68 bd 2d 80 00       	push   $0x802dbd
  80109a:	e8 93 f2 ff ff       	call   800332 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  80109f:	83 ec 04             	sub    $0x4,%esp
  8010a2:	6a 07                	push   $0x7
  8010a4:	68 00 f0 7f 00       	push   $0x7ff000
  8010a9:	6a 00                	push   $0x0
  8010ab:	e8 e3 fc ff ff       	call   800d93 <sys_page_alloc>
  8010b0:	83 c4 10             	add    $0x10,%esp
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	79 12                	jns    8010c9 <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  8010b7:	50                   	push   %eax
  8010b8:	68 0a 29 80 00       	push   $0x80290a
  8010bd:	6a 2b                	push   $0x2b
  8010bf:	68 bd 2d 80 00       	push   $0x802dbd
  8010c4:	e8 69 f2 ff ff       	call   800332 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  8010c9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  8010cf:	83 ec 04             	sub    $0x4,%esp
  8010d2:	68 00 10 00 00       	push   $0x1000
  8010d7:	53                   	push   %ebx
  8010d8:	68 00 f0 7f 00       	push   $0x7ff000
  8010dd:	e8 40 fa ff ff       	call   800b22 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  8010e2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8010e9:	53                   	push   %ebx
  8010ea:	6a 00                	push   $0x0
  8010ec:	68 00 f0 7f 00       	push   $0x7ff000
  8010f1:	6a 00                	push   $0x0
  8010f3:	e8 de fc ff ff       	call   800dd6 <sys_page_map>
  8010f8:	83 c4 20             	add    $0x20,%esp
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	79 12                	jns    801111 <pgfault+0xa9>
		panic("sys_page_map: %e", r);
  8010ff:	50                   	push   %eax
  801100:	68 c8 2d 80 00       	push   $0x802dc8
  801105:	6a 33                	push   $0x33
  801107:	68 bd 2d 80 00       	push   $0x802dbd
  80110c:	e8 21 f2 ff ff       	call   800332 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801111:	83 ec 08             	sub    $0x8,%esp
  801114:	68 00 f0 7f 00       	push   $0x7ff000
  801119:	6a 00                	push   $0x0
  80111b:	e8 f8 fc ff ff       	call   800e18 <sys_page_unmap>
  801120:	83 c4 10             	add    $0x10,%esp
  801123:	85 c0                	test   %eax,%eax
  801125:	79 12                	jns    801139 <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  801127:	50                   	push   %eax
  801128:	68 d9 2d 80 00       	push   $0x802dd9
  80112d:	6a 37                	push   $0x37
  80112f:	68 bd 2d 80 00       	push   $0x802dbd
  801134:	e8 f9 f1 ff ff       	call   800332 <_panic>
}
  801139:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80113c:	c9                   	leave  
  80113d:	c3                   	ret    

0080113e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	57                   	push   %edi
  801142:	56                   	push   %esi
  801143:	53                   	push   %ebx
  801144:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  801147:	68 68 10 80 00       	push   $0x801068
  80114c:	e8 3c 14 00 00       	call   80258d <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801151:	b8 07 00 00 00       	mov    $0x7,%eax
  801156:	cd 30                	int    $0x30
  801158:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80115b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Create child
	envid_t envid = sys_exofork();
	if (envid < 0) {
  80115e:	83 c4 10             	add    $0x10,%esp
  801161:	85 c0                	test   %eax,%eax
  801163:	79 15                	jns    80117a <fork+0x3c>
		panic("sys_exofork: %e", envid);
  801165:	50                   	push   %eax
  801166:	68 ec 2d 80 00       	push   $0x802dec
  80116b:	68 93 00 00 00       	push   $0x93
  801170:	68 bd 2d 80 00       	push   $0x802dbd
  801175:	e8 b8 f1 ff ff       	call   800332 <_panic>
		return envid;
	}

	// If we are the child, fix thisenv.
	if (envid == 0) {
  80117a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80117e:	75 21                	jne    8011a1 <fork+0x63>
		thisenv = &envs[ENVX(sys_getenvid())];
  801180:	e8 d0 fb ff ff       	call   800d55 <sys_getenvid>
  801185:	25 ff 03 00 00       	and    $0x3ff,%eax
  80118a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80118d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801192:	a3 0c 40 80 00       	mov    %eax,0x80400c
		return 0;
  801197:	b8 00 00 00 00       	mov    $0x0,%eax
  80119c:	e9 5a 01 00 00       	jmp    8012fb <fork+0x1bd>
	// We are the parent!
	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle the
	// fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), PTE_P | PTE_U | PTE_W);
  8011a1:	83 ec 04             	sub    $0x4,%esp
  8011a4:	6a 07                	push   $0x7
  8011a6:	68 00 f0 bf ee       	push   $0xeebff000
  8011ab:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8011ae:	57                   	push   %edi
  8011af:	e8 df fb ff ff       	call   800d93 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  8011b4:	83 c4 08             	add    $0x8,%esp
  8011b7:	68 d2 25 80 00       	push   $0x8025d2
  8011bc:	57                   	push   %edi
  8011bd:	e8 1c fd ff ff       	call   800ede <sys_env_set_pgfault_upcall>
  8011c2:	83 c4 10             	add    $0x10,%esp

	// Copy our address space to child. Be careful not to copy the exception
	// stack too, so go until USTACKTOP instead of UTOP.
	unsigned pn;
	for (pn = UTEXT/PGSIZE; pn < USTACKTOP/PGSIZE; pn++) {
  8011c5:	bb 00 08 00 00       	mov    $0x800,%ebx
static int
duppage(envid_t envid, unsigned pn)
{
	// Check if the page table that contains the PTE we want is allocated
	// using UVPD. If it is not, just don't map anything, and silently succeed.
	if (!(uvpd[pn/NPTENTRIES] & PTE_P))
  8011ca:	89 d8                	mov    %ebx,%eax
  8011cc:	c1 e8 0a             	shr    $0xa,%eax
  8011cf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011d6:	a8 01                	test   $0x1,%al
  8011d8:	0f 84 e2 00 00 00    	je     8012c0 <fork+0x182>
		return 0;

	// Retrieve the PTE using UVPT
	pte_t pte = uvpt[pn];
  8011de:	8b 34 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%esi

	// If the page is present, duplicate according to it's permissions
	if (pte & PTE_P) {
  8011e5:	f7 c6 01 00 00 00    	test   $0x1,%esi
  8011eb:	0f 84 cf 00 00 00    	je     8012c0 <fork+0x182>
		int r;
		uint32_t perm = pte & PTE_SYSCALL;
  8011f1:	89 f0                	mov    %esi,%eax
  8011f3:	25 07 0e 00 00       	and    $0xe07,%eax
  8011f8:	89 df                	mov    %ebx,%edi
  8011fa:	c1 e7 0c             	shl    $0xc,%edi
		void *va = (void *) (pn * PGSIZE);

		// If PTE_SHARE is enabled, share it by just copying the
		// pte, which can be done by mapping on the same address
		// with the same permissions, even if it is writable
		if (pte & PTE_SHARE) {
  8011fd:	f7 c6 00 04 00 00    	test   $0x400,%esi
  801203:	74 2d                	je     801232 <fork+0xf4>
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  801205:	83 ec 0c             	sub    $0xc,%esp
  801208:	50                   	push   %eax
  801209:	57                   	push   %edi
  80120a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80120d:	57                   	push   %edi
  80120e:	6a 00                	push   $0x0
  801210:	e8 c1 fb ff ff       	call   800dd6 <sys_page_map>
  801215:	83 c4 20             	add    $0x20,%esp
  801218:	85 c0                	test   %eax,%eax
  80121a:	0f 89 a0 00 00 00    	jns    8012c0 <fork+0x182>
				panic("sys_page_map: %e", r);
  801220:	50                   	push   %eax
  801221:	68 c8 2d 80 00       	push   $0x802dc8
  801226:	6a 5c                	push   $0x5c
  801228:	68 bd 2d 80 00       	push   $0x802dbd
  80122d:	e8 00 f1 ff ff       	call   800332 <_panic>
				return r;
			}
		// If writable or COW, make it COW on parent and child
		} else if (pte & (PTE_W | PTE_COW)) {
  801232:	f7 c6 02 08 00 00    	test   $0x802,%esi
  801238:	74 5d                	je     801297 <fork+0x159>
			perm &= ~PTE_W;  // Remove PTE_W, so it faults
  80123a:	81 e6 05 0e 00 00    	and    $0xe05,%esi
			perm |= PTE_COW; // Make it PTE_COW
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  801240:	81 ce 00 08 00 00    	or     $0x800,%esi
  801246:	83 ec 0c             	sub    $0xc,%esp
  801249:	56                   	push   %esi
  80124a:	57                   	push   %edi
  80124b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80124e:	57                   	push   %edi
  80124f:	6a 00                	push   $0x0
  801251:	e8 80 fb ff ff       	call   800dd6 <sys_page_map>
  801256:	83 c4 20             	add    $0x20,%esp
  801259:	85 c0                	test   %eax,%eax
  80125b:	79 12                	jns    80126f <fork+0x131>
				panic("sys_page_map: %e", r);
  80125d:	50                   	push   %eax
  80125e:	68 c8 2d 80 00       	push   $0x802dc8
  801263:	6a 65                	push   $0x65
  801265:	68 bd 2d 80 00       	push   $0x802dbd
  80126a:	e8 c3 f0 ff ff       	call   800332 <_panic>
				return r;
			}
			// Change the permission on parent, mapping on itself
			if ((r = sys_page_map(0, va, 0, va, perm)) < 0) {
  80126f:	83 ec 0c             	sub    $0xc,%esp
  801272:	56                   	push   %esi
  801273:	57                   	push   %edi
  801274:	6a 00                	push   $0x0
  801276:	57                   	push   %edi
  801277:	6a 00                	push   $0x0
  801279:	e8 58 fb ff ff       	call   800dd6 <sys_page_map>
  80127e:	83 c4 20             	add    $0x20,%esp
  801281:	85 c0                	test   %eax,%eax
  801283:	79 3b                	jns    8012c0 <fork+0x182>
				panic("sys_page_map: %e", r);
  801285:	50                   	push   %eax
  801286:	68 c8 2d 80 00       	push   $0x802dc8
  80128b:	6a 6a                	push   $0x6a
  80128d:	68 bd 2d 80 00       	push   $0x802dbd
  801292:	e8 9b f0 ff ff       	call   800332 <_panic>
				return r;
			}
		// If it is read-only, just share it.
		} else {
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  801297:	83 ec 0c             	sub    $0xc,%esp
  80129a:	50                   	push   %eax
  80129b:	57                   	push   %edi
  80129c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80129f:	57                   	push   %edi
  8012a0:	6a 00                	push   $0x0
  8012a2:	e8 2f fb ff ff       	call   800dd6 <sys_page_map>
  8012a7:	83 c4 20             	add    $0x20,%esp
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	79 12                	jns    8012c0 <fork+0x182>
				panic("sys_page_map: %e", r);
  8012ae:	50                   	push   %eax
  8012af:	68 c8 2d 80 00       	push   $0x802dc8
  8012b4:	6a 71                	push   $0x71
  8012b6:	68 bd 2d 80 00       	push   $0x802dbd
  8012bb:	e8 72 f0 ff ff       	call   800332 <_panic>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);

	// Copy our address space to child. Be careful not to copy the exception
	// stack too, so go until USTACKTOP instead of UTOP.
	unsigned pn;
	for (pn = UTEXT/PGSIZE; pn < USTACKTOP/PGSIZE; pn++) {
  8012c0:	83 c3 01             	add    $0x1,%ebx
  8012c3:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  8012c9:	0f 85 fb fe ff ff    	jne    8011ca <fork+0x8c>
		duppage(envid, pn);
	}

	// Make the child runnable
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8012cf:	83 ec 08             	sub    $0x8,%esp
  8012d2:	6a 02                	push   $0x2
  8012d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8012d7:	e8 7e fb ff ff       	call   800e5a <sys_env_set_status>
  8012dc:	83 c4 10             	add    $0x10,%esp
  8012df:	85 c0                	test   %eax,%eax
  8012e1:	79 15                	jns    8012f8 <fork+0x1ba>
		panic("sys_env_set_status: %e", r);
  8012e3:	50                   	push   %eax
  8012e4:	68 fc 2d 80 00       	push   $0x802dfc
  8012e9:	68 af 00 00 00       	push   $0xaf
  8012ee:	68 bd 2d 80 00       	push   $0x802dbd
  8012f3:	e8 3a f0 ff ff       	call   800332 <_panic>
		return r;
	}

	return envid;
  8012f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  8012fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012fe:	5b                   	pop    %ebx
  8012ff:	5e                   	pop    %esi
  801300:	5f                   	pop    %edi
  801301:	5d                   	pop    %ebp
  801302:	c3                   	ret    

00801303 <sfork>:

// Challenge!
int
sfork(void)
{
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
  801306:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801309:	68 13 2e 80 00       	push   $0x802e13
  80130e:	68 ba 00 00 00       	push   $0xba
  801313:	68 bd 2d 80 00       	push   $0x802dbd
  801318:	e8 15 f0 ff ff       	call   800332 <_panic>

0080131d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	56                   	push   %esi
  801321:	53                   	push   %ebx
  801322:	8b 75 08             	mov    0x8(%ebp),%esi
  801325:	8b 45 0c             	mov    0xc(%ebp),%eax
  801328:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  80132b:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80132d:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801332:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801335:	83 ec 0c             	sub    $0xc,%esp
  801338:	50                   	push   %eax
  801339:	e8 05 fc ff ff       	call   800f43 <sys_ipc_recv>

	if (r < 0) {
  80133e:	83 c4 10             	add    $0x10,%esp
  801341:	85 c0                	test   %eax,%eax
  801343:	79 16                	jns    80135b <ipc_recv+0x3e>
		if (from_env_store)
  801345:	85 f6                	test   %esi,%esi
  801347:	74 06                	je     80134f <ipc_recv+0x32>
			*from_env_store = 0;
  801349:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  80134f:	85 db                	test   %ebx,%ebx
  801351:	74 2c                	je     80137f <ipc_recv+0x62>
			*perm_store = 0;
  801353:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801359:	eb 24                	jmp    80137f <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  80135b:	85 f6                	test   %esi,%esi
  80135d:	74 0a                	je     801369 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  80135f:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801364:	8b 40 74             	mov    0x74(%eax),%eax
  801367:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801369:	85 db                	test   %ebx,%ebx
  80136b:	74 0a                	je     801377 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  80136d:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801372:	8b 40 78             	mov    0x78(%eax),%eax
  801375:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801377:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80137c:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  80137f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801382:	5b                   	pop    %ebx
  801383:	5e                   	pop    %esi
  801384:	5d                   	pop    %ebp
  801385:	c3                   	ret    

00801386 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	57                   	push   %edi
  80138a:	56                   	push   %esi
  80138b:	53                   	push   %ebx
  80138c:	83 ec 0c             	sub    $0xc,%esp
  80138f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801392:	8b 75 0c             	mov    0xc(%ebp),%esi
  801395:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801398:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80139a:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  80139f:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8013a2:	ff 75 14             	pushl  0x14(%ebp)
  8013a5:	53                   	push   %ebx
  8013a6:	56                   	push   %esi
  8013a7:	57                   	push   %edi
  8013a8:	e8 73 fb ff ff       	call   800f20 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  8013ad:	83 c4 10             	add    $0x10,%esp
  8013b0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013b3:	75 07                	jne    8013bc <ipc_send+0x36>
			sys_yield();
  8013b5:	e8 ba f9 ff ff       	call   800d74 <sys_yield>
  8013ba:	eb e6                	jmp    8013a2 <ipc_send+0x1c>
		} else if (r < 0) {
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	79 12                	jns    8013d2 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  8013c0:	50                   	push   %eax
  8013c1:	68 29 2e 80 00       	push   $0x802e29
  8013c6:	6a 51                	push   $0x51
  8013c8:	68 36 2e 80 00       	push   $0x802e36
  8013cd:	e8 60 ef ff ff       	call   800332 <_panic>
		}
	}
}
  8013d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d5:	5b                   	pop    %ebx
  8013d6:	5e                   	pop    %esi
  8013d7:	5f                   	pop    %edi
  8013d8:	5d                   	pop    %ebp
  8013d9:	c3                   	ret    

008013da <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013da:	55                   	push   %ebp
  8013db:	89 e5                	mov    %esp,%ebp
  8013dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8013e0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013e5:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8013e8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013ee:	8b 52 50             	mov    0x50(%edx),%edx
  8013f1:	39 ca                	cmp    %ecx,%edx
  8013f3:	75 0d                	jne    801402 <ipc_find_env+0x28>
			return envs[i].env_id;
  8013f5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8013f8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8013fd:	8b 40 48             	mov    0x48(%eax),%eax
  801400:	eb 0f                	jmp    801411 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801402:	83 c0 01             	add    $0x1,%eax
  801405:	3d 00 04 00 00       	cmp    $0x400,%eax
  80140a:	75 d9                	jne    8013e5 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80140c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801411:	5d                   	pop    %ebp
  801412:	c3                   	ret    

00801413 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801416:	8b 45 08             	mov    0x8(%ebp),%eax
  801419:	05 00 00 00 30       	add    $0x30000000,%eax
  80141e:	c1 e8 0c             	shr    $0xc,%eax
}
  801421:	5d                   	pop    %ebp
  801422:	c3                   	ret    

00801423 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801426:	8b 45 08             	mov    0x8(%ebp),%eax
  801429:	05 00 00 00 30       	add    $0x30000000,%eax
  80142e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801433:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801438:	5d                   	pop    %ebp
  801439:	c3                   	ret    

0080143a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80143a:	55                   	push   %ebp
  80143b:	89 e5                	mov    %esp,%ebp
  80143d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801440:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801445:	89 c2                	mov    %eax,%edx
  801447:	c1 ea 16             	shr    $0x16,%edx
  80144a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801451:	f6 c2 01             	test   $0x1,%dl
  801454:	74 11                	je     801467 <fd_alloc+0x2d>
  801456:	89 c2                	mov    %eax,%edx
  801458:	c1 ea 0c             	shr    $0xc,%edx
  80145b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801462:	f6 c2 01             	test   $0x1,%dl
  801465:	75 09                	jne    801470 <fd_alloc+0x36>
			*fd_store = fd;
  801467:	89 01                	mov    %eax,(%ecx)
			return 0;
  801469:	b8 00 00 00 00       	mov    $0x0,%eax
  80146e:	eb 17                	jmp    801487 <fd_alloc+0x4d>
  801470:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801475:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80147a:	75 c9                	jne    801445 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80147c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801482:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801487:	5d                   	pop    %ebp
  801488:	c3                   	ret    

00801489 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
  80148c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80148f:	83 f8 1f             	cmp    $0x1f,%eax
  801492:	77 36                	ja     8014ca <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801494:	c1 e0 0c             	shl    $0xc,%eax
  801497:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80149c:	89 c2                	mov    %eax,%edx
  80149e:	c1 ea 16             	shr    $0x16,%edx
  8014a1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014a8:	f6 c2 01             	test   $0x1,%dl
  8014ab:	74 24                	je     8014d1 <fd_lookup+0x48>
  8014ad:	89 c2                	mov    %eax,%edx
  8014af:	c1 ea 0c             	shr    $0xc,%edx
  8014b2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014b9:	f6 c2 01             	test   $0x1,%dl
  8014bc:	74 1a                	je     8014d8 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014c1:	89 02                	mov    %eax,(%edx)
	return 0;
  8014c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c8:	eb 13                	jmp    8014dd <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014cf:	eb 0c                	jmp    8014dd <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d6:	eb 05                	jmp    8014dd <fd_lookup+0x54>
  8014d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014dd:	5d                   	pop    %ebp
  8014de:	c3                   	ret    

008014df <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
  8014e2:	83 ec 08             	sub    $0x8,%esp
  8014e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014e8:	ba c0 2e 80 00       	mov    $0x802ec0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014ed:	eb 13                	jmp    801502 <dev_lookup+0x23>
  8014ef:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014f2:	39 08                	cmp    %ecx,(%eax)
  8014f4:	75 0c                	jne    801502 <dev_lookup+0x23>
			*dev = devtab[i];
  8014f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014f9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801500:	eb 2e                	jmp    801530 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801502:	8b 02                	mov    (%edx),%eax
  801504:	85 c0                	test   %eax,%eax
  801506:	75 e7                	jne    8014ef <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801508:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80150d:	8b 40 48             	mov    0x48(%eax),%eax
  801510:	83 ec 04             	sub    $0x4,%esp
  801513:	51                   	push   %ecx
  801514:	50                   	push   %eax
  801515:	68 40 2e 80 00       	push   $0x802e40
  80151a:	e8 ec ee ff ff       	call   80040b <cprintf>
	*dev = 0;
  80151f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801522:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801530:	c9                   	leave  
  801531:	c3                   	ret    

00801532 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801532:	55                   	push   %ebp
  801533:	89 e5                	mov    %esp,%ebp
  801535:	56                   	push   %esi
  801536:	53                   	push   %ebx
  801537:	83 ec 10             	sub    $0x10,%esp
  80153a:	8b 75 08             	mov    0x8(%ebp),%esi
  80153d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801540:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801543:	50                   	push   %eax
  801544:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80154a:	c1 e8 0c             	shr    $0xc,%eax
  80154d:	50                   	push   %eax
  80154e:	e8 36 ff ff ff       	call   801489 <fd_lookup>
  801553:	83 c4 08             	add    $0x8,%esp
  801556:	85 c0                	test   %eax,%eax
  801558:	78 05                	js     80155f <fd_close+0x2d>
	    || fd != fd2)
  80155a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80155d:	74 0c                	je     80156b <fd_close+0x39>
		return (must_exist ? r : 0);
  80155f:	84 db                	test   %bl,%bl
  801561:	ba 00 00 00 00       	mov    $0x0,%edx
  801566:	0f 44 c2             	cmove  %edx,%eax
  801569:	eb 41                	jmp    8015ac <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80156b:	83 ec 08             	sub    $0x8,%esp
  80156e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801571:	50                   	push   %eax
  801572:	ff 36                	pushl  (%esi)
  801574:	e8 66 ff ff ff       	call   8014df <dev_lookup>
  801579:	89 c3                	mov    %eax,%ebx
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	85 c0                	test   %eax,%eax
  801580:	78 1a                	js     80159c <fd_close+0x6a>
		if (dev->dev_close)
  801582:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801585:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801588:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80158d:	85 c0                	test   %eax,%eax
  80158f:	74 0b                	je     80159c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801591:	83 ec 0c             	sub    $0xc,%esp
  801594:	56                   	push   %esi
  801595:	ff d0                	call   *%eax
  801597:	89 c3                	mov    %eax,%ebx
  801599:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80159c:	83 ec 08             	sub    $0x8,%esp
  80159f:	56                   	push   %esi
  8015a0:	6a 00                	push   $0x0
  8015a2:	e8 71 f8 ff ff       	call   800e18 <sys_page_unmap>
	return r;
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	89 d8                	mov    %ebx,%eax
}
  8015ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015af:	5b                   	pop    %ebx
  8015b0:	5e                   	pop    %esi
  8015b1:	5d                   	pop    %ebp
  8015b2:	c3                   	ret    

008015b3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bc:	50                   	push   %eax
  8015bd:	ff 75 08             	pushl  0x8(%ebp)
  8015c0:	e8 c4 fe ff ff       	call   801489 <fd_lookup>
  8015c5:	83 c4 08             	add    $0x8,%esp
  8015c8:	85 c0                	test   %eax,%eax
  8015ca:	78 10                	js     8015dc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015cc:	83 ec 08             	sub    $0x8,%esp
  8015cf:	6a 01                	push   $0x1
  8015d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d4:	e8 59 ff ff ff       	call   801532 <fd_close>
  8015d9:	83 c4 10             	add    $0x10,%esp
}
  8015dc:	c9                   	leave  
  8015dd:	c3                   	ret    

008015de <close_all>:

void
close_all(void)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	53                   	push   %ebx
  8015e2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015e5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015ea:	83 ec 0c             	sub    $0xc,%esp
  8015ed:	53                   	push   %ebx
  8015ee:	e8 c0 ff ff ff       	call   8015b3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015f3:	83 c3 01             	add    $0x1,%ebx
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	83 fb 20             	cmp    $0x20,%ebx
  8015fc:	75 ec                	jne    8015ea <close_all+0xc>
		close(i);
}
  8015fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801601:	c9                   	leave  
  801602:	c3                   	ret    

00801603 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801603:	55                   	push   %ebp
  801604:	89 e5                	mov    %esp,%ebp
  801606:	57                   	push   %edi
  801607:	56                   	push   %esi
  801608:	53                   	push   %ebx
  801609:	83 ec 2c             	sub    $0x2c,%esp
  80160c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80160f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801612:	50                   	push   %eax
  801613:	ff 75 08             	pushl  0x8(%ebp)
  801616:	e8 6e fe ff ff       	call   801489 <fd_lookup>
  80161b:	83 c4 08             	add    $0x8,%esp
  80161e:	85 c0                	test   %eax,%eax
  801620:	0f 88 c1 00 00 00    	js     8016e7 <dup+0xe4>
		return r;
	close(newfdnum);
  801626:	83 ec 0c             	sub    $0xc,%esp
  801629:	56                   	push   %esi
  80162a:	e8 84 ff ff ff       	call   8015b3 <close>

	newfd = INDEX2FD(newfdnum);
  80162f:	89 f3                	mov    %esi,%ebx
  801631:	c1 e3 0c             	shl    $0xc,%ebx
  801634:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80163a:	83 c4 04             	add    $0x4,%esp
  80163d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801640:	e8 de fd ff ff       	call   801423 <fd2data>
  801645:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801647:	89 1c 24             	mov    %ebx,(%esp)
  80164a:	e8 d4 fd ff ff       	call   801423 <fd2data>
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801655:	89 f8                	mov    %edi,%eax
  801657:	c1 e8 16             	shr    $0x16,%eax
  80165a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801661:	a8 01                	test   $0x1,%al
  801663:	74 37                	je     80169c <dup+0x99>
  801665:	89 f8                	mov    %edi,%eax
  801667:	c1 e8 0c             	shr    $0xc,%eax
  80166a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801671:	f6 c2 01             	test   $0x1,%dl
  801674:	74 26                	je     80169c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801676:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80167d:	83 ec 0c             	sub    $0xc,%esp
  801680:	25 07 0e 00 00       	and    $0xe07,%eax
  801685:	50                   	push   %eax
  801686:	ff 75 d4             	pushl  -0x2c(%ebp)
  801689:	6a 00                	push   $0x0
  80168b:	57                   	push   %edi
  80168c:	6a 00                	push   $0x0
  80168e:	e8 43 f7 ff ff       	call   800dd6 <sys_page_map>
  801693:	89 c7                	mov    %eax,%edi
  801695:	83 c4 20             	add    $0x20,%esp
  801698:	85 c0                	test   %eax,%eax
  80169a:	78 2e                	js     8016ca <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80169c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80169f:	89 d0                	mov    %edx,%eax
  8016a1:	c1 e8 0c             	shr    $0xc,%eax
  8016a4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016ab:	83 ec 0c             	sub    $0xc,%esp
  8016ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8016b3:	50                   	push   %eax
  8016b4:	53                   	push   %ebx
  8016b5:	6a 00                	push   $0x0
  8016b7:	52                   	push   %edx
  8016b8:	6a 00                	push   $0x0
  8016ba:	e8 17 f7 ff ff       	call   800dd6 <sys_page_map>
  8016bf:	89 c7                	mov    %eax,%edi
  8016c1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016c4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016c6:	85 ff                	test   %edi,%edi
  8016c8:	79 1d                	jns    8016e7 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016ca:	83 ec 08             	sub    $0x8,%esp
  8016cd:	53                   	push   %ebx
  8016ce:	6a 00                	push   $0x0
  8016d0:	e8 43 f7 ff ff       	call   800e18 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016d5:	83 c4 08             	add    $0x8,%esp
  8016d8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016db:	6a 00                	push   $0x0
  8016dd:	e8 36 f7 ff ff       	call   800e18 <sys_page_unmap>
	return r;
  8016e2:	83 c4 10             	add    $0x10,%esp
  8016e5:	89 f8                	mov    %edi,%eax
}
  8016e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ea:	5b                   	pop    %ebx
  8016eb:	5e                   	pop    %esi
  8016ec:	5f                   	pop    %edi
  8016ed:	5d                   	pop    %ebp
  8016ee:	c3                   	ret    

008016ef <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	53                   	push   %ebx
  8016f3:	83 ec 14             	sub    $0x14,%esp
  8016f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016fc:	50                   	push   %eax
  8016fd:	53                   	push   %ebx
  8016fe:	e8 86 fd ff ff       	call   801489 <fd_lookup>
  801703:	83 c4 08             	add    $0x8,%esp
  801706:	89 c2                	mov    %eax,%edx
  801708:	85 c0                	test   %eax,%eax
  80170a:	78 6d                	js     801779 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170c:	83 ec 08             	sub    $0x8,%esp
  80170f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801712:	50                   	push   %eax
  801713:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801716:	ff 30                	pushl  (%eax)
  801718:	e8 c2 fd ff ff       	call   8014df <dev_lookup>
  80171d:	83 c4 10             	add    $0x10,%esp
  801720:	85 c0                	test   %eax,%eax
  801722:	78 4c                	js     801770 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801724:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801727:	8b 42 08             	mov    0x8(%edx),%eax
  80172a:	83 e0 03             	and    $0x3,%eax
  80172d:	83 f8 01             	cmp    $0x1,%eax
  801730:	75 21                	jne    801753 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801732:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801737:	8b 40 48             	mov    0x48(%eax),%eax
  80173a:	83 ec 04             	sub    $0x4,%esp
  80173d:	53                   	push   %ebx
  80173e:	50                   	push   %eax
  80173f:	68 84 2e 80 00       	push   $0x802e84
  801744:	e8 c2 ec ff ff       	call   80040b <cprintf>
		return -E_INVAL;
  801749:	83 c4 10             	add    $0x10,%esp
  80174c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801751:	eb 26                	jmp    801779 <read+0x8a>
	}
	if (!dev->dev_read)
  801753:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801756:	8b 40 08             	mov    0x8(%eax),%eax
  801759:	85 c0                	test   %eax,%eax
  80175b:	74 17                	je     801774 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80175d:	83 ec 04             	sub    $0x4,%esp
  801760:	ff 75 10             	pushl  0x10(%ebp)
  801763:	ff 75 0c             	pushl  0xc(%ebp)
  801766:	52                   	push   %edx
  801767:	ff d0                	call   *%eax
  801769:	89 c2                	mov    %eax,%edx
  80176b:	83 c4 10             	add    $0x10,%esp
  80176e:	eb 09                	jmp    801779 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801770:	89 c2                	mov    %eax,%edx
  801772:	eb 05                	jmp    801779 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801774:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801779:	89 d0                	mov    %edx,%eax
  80177b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177e:	c9                   	leave  
  80177f:	c3                   	ret    

00801780 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	57                   	push   %edi
  801784:	56                   	push   %esi
  801785:	53                   	push   %ebx
  801786:	83 ec 0c             	sub    $0xc,%esp
  801789:	8b 7d 08             	mov    0x8(%ebp),%edi
  80178c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80178f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801794:	eb 21                	jmp    8017b7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801796:	83 ec 04             	sub    $0x4,%esp
  801799:	89 f0                	mov    %esi,%eax
  80179b:	29 d8                	sub    %ebx,%eax
  80179d:	50                   	push   %eax
  80179e:	89 d8                	mov    %ebx,%eax
  8017a0:	03 45 0c             	add    0xc(%ebp),%eax
  8017a3:	50                   	push   %eax
  8017a4:	57                   	push   %edi
  8017a5:	e8 45 ff ff ff       	call   8016ef <read>
		if (m < 0)
  8017aa:	83 c4 10             	add    $0x10,%esp
  8017ad:	85 c0                	test   %eax,%eax
  8017af:	78 10                	js     8017c1 <readn+0x41>
			return m;
		if (m == 0)
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	74 0a                	je     8017bf <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017b5:	01 c3                	add    %eax,%ebx
  8017b7:	39 f3                	cmp    %esi,%ebx
  8017b9:	72 db                	jb     801796 <readn+0x16>
  8017bb:	89 d8                	mov    %ebx,%eax
  8017bd:	eb 02                	jmp    8017c1 <readn+0x41>
  8017bf:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8017c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017c4:	5b                   	pop    %ebx
  8017c5:	5e                   	pop    %esi
  8017c6:	5f                   	pop    %edi
  8017c7:	5d                   	pop    %ebp
  8017c8:	c3                   	ret    

008017c9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017c9:	55                   	push   %ebp
  8017ca:	89 e5                	mov    %esp,%ebp
  8017cc:	53                   	push   %ebx
  8017cd:	83 ec 14             	sub    $0x14,%esp
  8017d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d6:	50                   	push   %eax
  8017d7:	53                   	push   %ebx
  8017d8:	e8 ac fc ff ff       	call   801489 <fd_lookup>
  8017dd:	83 c4 08             	add    $0x8,%esp
  8017e0:	89 c2                	mov    %eax,%edx
  8017e2:	85 c0                	test   %eax,%eax
  8017e4:	78 68                	js     80184e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e6:	83 ec 08             	sub    $0x8,%esp
  8017e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ec:	50                   	push   %eax
  8017ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f0:	ff 30                	pushl  (%eax)
  8017f2:	e8 e8 fc ff ff       	call   8014df <dev_lookup>
  8017f7:	83 c4 10             	add    $0x10,%esp
  8017fa:	85 c0                	test   %eax,%eax
  8017fc:	78 47                	js     801845 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801801:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801805:	75 21                	jne    801828 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801807:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80180c:	8b 40 48             	mov    0x48(%eax),%eax
  80180f:	83 ec 04             	sub    $0x4,%esp
  801812:	53                   	push   %ebx
  801813:	50                   	push   %eax
  801814:	68 a0 2e 80 00       	push   $0x802ea0
  801819:	e8 ed eb ff ff       	call   80040b <cprintf>
		return -E_INVAL;
  80181e:	83 c4 10             	add    $0x10,%esp
  801821:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801826:	eb 26                	jmp    80184e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801828:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80182b:	8b 52 0c             	mov    0xc(%edx),%edx
  80182e:	85 d2                	test   %edx,%edx
  801830:	74 17                	je     801849 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801832:	83 ec 04             	sub    $0x4,%esp
  801835:	ff 75 10             	pushl  0x10(%ebp)
  801838:	ff 75 0c             	pushl  0xc(%ebp)
  80183b:	50                   	push   %eax
  80183c:	ff d2                	call   *%edx
  80183e:	89 c2                	mov    %eax,%edx
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	eb 09                	jmp    80184e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801845:	89 c2                	mov    %eax,%edx
  801847:	eb 05                	jmp    80184e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801849:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80184e:	89 d0                	mov    %edx,%eax
  801850:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801853:	c9                   	leave  
  801854:	c3                   	ret    

00801855 <seek>:

int
seek(int fdnum, off_t offset)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80185b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80185e:	50                   	push   %eax
  80185f:	ff 75 08             	pushl  0x8(%ebp)
  801862:	e8 22 fc ff ff       	call   801489 <fd_lookup>
  801867:	83 c4 08             	add    $0x8,%esp
  80186a:	85 c0                	test   %eax,%eax
  80186c:	78 0e                	js     80187c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80186e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801871:	8b 55 0c             	mov    0xc(%ebp),%edx
  801874:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801877:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80187c:	c9                   	leave  
  80187d:	c3                   	ret    

0080187e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	53                   	push   %ebx
  801882:	83 ec 14             	sub    $0x14,%esp
  801885:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801888:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80188b:	50                   	push   %eax
  80188c:	53                   	push   %ebx
  80188d:	e8 f7 fb ff ff       	call   801489 <fd_lookup>
  801892:	83 c4 08             	add    $0x8,%esp
  801895:	89 c2                	mov    %eax,%edx
  801897:	85 c0                	test   %eax,%eax
  801899:	78 65                	js     801900 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80189b:	83 ec 08             	sub    $0x8,%esp
  80189e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a1:	50                   	push   %eax
  8018a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a5:	ff 30                	pushl  (%eax)
  8018a7:	e8 33 fc ff ff       	call   8014df <dev_lookup>
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	78 44                	js     8018f7 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018ba:	75 21                	jne    8018dd <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018bc:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018c1:	8b 40 48             	mov    0x48(%eax),%eax
  8018c4:	83 ec 04             	sub    $0x4,%esp
  8018c7:	53                   	push   %ebx
  8018c8:	50                   	push   %eax
  8018c9:	68 60 2e 80 00       	push   $0x802e60
  8018ce:	e8 38 eb ff ff       	call   80040b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018d3:	83 c4 10             	add    $0x10,%esp
  8018d6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018db:	eb 23                	jmp    801900 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8018dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018e0:	8b 52 18             	mov    0x18(%edx),%edx
  8018e3:	85 d2                	test   %edx,%edx
  8018e5:	74 14                	je     8018fb <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018e7:	83 ec 08             	sub    $0x8,%esp
  8018ea:	ff 75 0c             	pushl  0xc(%ebp)
  8018ed:	50                   	push   %eax
  8018ee:	ff d2                	call   *%edx
  8018f0:	89 c2                	mov    %eax,%edx
  8018f2:	83 c4 10             	add    $0x10,%esp
  8018f5:	eb 09                	jmp    801900 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f7:	89 c2                	mov    %eax,%edx
  8018f9:	eb 05                	jmp    801900 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018fb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801900:	89 d0                	mov    %edx,%eax
  801902:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801905:	c9                   	leave  
  801906:	c3                   	ret    

00801907 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	53                   	push   %ebx
  80190b:	83 ec 14             	sub    $0x14,%esp
  80190e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801911:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801914:	50                   	push   %eax
  801915:	ff 75 08             	pushl  0x8(%ebp)
  801918:	e8 6c fb ff ff       	call   801489 <fd_lookup>
  80191d:	83 c4 08             	add    $0x8,%esp
  801920:	89 c2                	mov    %eax,%edx
  801922:	85 c0                	test   %eax,%eax
  801924:	78 58                	js     80197e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801926:	83 ec 08             	sub    $0x8,%esp
  801929:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192c:	50                   	push   %eax
  80192d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801930:	ff 30                	pushl  (%eax)
  801932:	e8 a8 fb ff ff       	call   8014df <dev_lookup>
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	85 c0                	test   %eax,%eax
  80193c:	78 37                	js     801975 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80193e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801941:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801945:	74 32                	je     801979 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801947:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80194a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801951:	00 00 00 
	stat->st_isdir = 0;
  801954:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80195b:	00 00 00 
	stat->st_dev = dev;
  80195e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801964:	83 ec 08             	sub    $0x8,%esp
  801967:	53                   	push   %ebx
  801968:	ff 75 f0             	pushl  -0x10(%ebp)
  80196b:	ff 50 14             	call   *0x14(%eax)
  80196e:	89 c2                	mov    %eax,%edx
  801970:	83 c4 10             	add    $0x10,%esp
  801973:	eb 09                	jmp    80197e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801975:	89 c2                	mov    %eax,%edx
  801977:	eb 05                	jmp    80197e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801979:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80197e:	89 d0                	mov    %edx,%eax
  801980:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801983:	c9                   	leave  
  801984:	c3                   	ret    

00801985 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801985:	55                   	push   %ebp
  801986:	89 e5                	mov    %esp,%ebp
  801988:	56                   	push   %esi
  801989:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80198a:	83 ec 08             	sub    $0x8,%esp
  80198d:	6a 00                	push   $0x0
  80198f:	ff 75 08             	pushl  0x8(%ebp)
  801992:	e8 0c 02 00 00       	call   801ba3 <open>
  801997:	89 c3                	mov    %eax,%ebx
  801999:	83 c4 10             	add    $0x10,%esp
  80199c:	85 c0                	test   %eax,%eax
  80199e:	78 1b                	js     8019bb <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019a0:	83 ec 08             	sub    $0x8,%esp
  8019a3:	ff 75 0c             	pushl  0xc(%ebp)
  8019a6:	50                   	push   %eax
  8019a7:	e8 5b ff ff ff       	call   801907 <fstat>
  8019ac:	89 c6                	mov    %eax,%esi
	close(fd);
  8019ae:	89 1c 24             	mov    %ebx,(%esp)
  8019b1:	e8 fd fb ff ff       	call   8015b3 <close>
	return r;
  8019b6:	83 c4 10             	add    $0x10,%esp
  8019b9:	89 f0                	mov    %esi,%eax
}
  8019bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019be:	5b                   	pop    %ebx
  8019bf:	5e                   	pop    %esi
  8019c0:	5d                   	pop    %ebp
  8019c1:	c3                   	ret    

008019c2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019c2:	55                   	push   %ebp
  8019c3:	89 e5                	mov    %esp,%ebp
  8019c5:	56                   	push   %esi
  8019c6:	53                   	push   %ebx
  8019c7:	89 c6                	mov    %eax,%esi
  8019c9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019cb:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8019d2:	75 12                	jne    8019e6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019d4:	83 ec 0c             	sub    $0xc,%esp
  8019d7:	6a 01                	push   $0x1
  8019d9:	e8 fc f9 ff ff       	call   8013da <ipc_find_env>
  8019de:	a3 04 40 80 00       	mov    %eax,0x804004
  8019e3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019e6:	6a 07                	push   $0x7
  8019e8:	68 00 50 80 00       	push   $0x805000
  8019ed:	56                   	push   %esi
  8019ee:	ff 35 04 40 80 00    	pushl  0x804004
  8019f4:	e8 8d f9 ff ff       	call   801386 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019f9:	83 c4 0c             	add    $0xc,%esp
  8019fc:	6a 00                	push   $0x0
  8019fe:	53                   	push   %ebx
  8019ff:	6a 00                	push   $0x0
  801a01:	e8 17 f9 ff ff       	call   80131d <ipc_recv>
}
  801a06:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a09:	5b                   	pop    %ebx
  801a0a:	5e                   	pop    %esi
  801a0b:	5d                   	pop    %ebp
  801a0c:	c3                   	ret    

00801a0d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a0d:	55                   	push   %ebp
  801a0e:	89 e5                	mov    %esp,%ebp
  801a10:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a13:	8b 45 08             	mov    0x8(%ebp),%eax
  801a16:	8b 40 0c             	mov    0xc(%eax),%eax
  801a19:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a21:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a26:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2b:	b8 02 00 00 00       	mov    $0x2,%eax
  801a30:	e8 8d ff ff ff       	call   8019c2 <fsipc>
}
  801a35:	c9                   	leave  
  801a36:	c3                   	ret    

00801a37 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a37:	55                   	push   %ebp
  801a38:	89 e5                	mov    %esp,%ebp
  801a3a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a40:	8b 40 0c             	mov    0xc(%eax),%eax
  801a43:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a48:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4d:	b8 06 00 00 00       	mov    $0x6,%eax
  801a52:	e8 6b ff ff ff       	call   8019c2 <fsipc>
}
  801a57:	c9                   	leave  
  801a58:	c3                   	ret    

00801a59 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	53                   	push   %ebx
  801a5d:	83 ec 04             	sub    $0x4,%esp
  801a60:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a63:	8b 45 08             	mov    0x8(%ebp),%eax
  801a66:	8b 40 0c             	mov    0xc(%eax),%eax
  801a69:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a6e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a73:	b8 05 00 00 00       	mov    $0x5,%eax
  801a78:	e8 45 ff ff ff       	call   8019c2 <fsipc>
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	78 2c                	js     801aad <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a81:	83 ec 08             	sub    $0x8,%esp
  801a84:	68 00 50 80 00       	push   $0x805000
  801a89:	53                   	push   %ebx
  801a8a:	e8 01 ef ff ff       	call   800990 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a8f:	a1 80 50 80 00       	mov    0x805080,%eax
  801a94:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a9a:	a1 84 50 80 00       	mov    0x805084,%eax
  801a9f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801aa5:	83 c4 10             	add    $0x10,%esp
  801aa8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab0:	c9                   	leave  
  801ab1:	c3                   	ret    

00801ab2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ab2:	55                   	push   %ebp
  801ab3:	89 e5                	mov    %esp,%ebp
  801ab5:	53                   	push   %ebx
  801ab6:	83 ec 08             	sub    $0x8,%esp
  801ab9:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801abc:	8b 55 08             	mov    0x8(%ebp),%edx
  801abf:	8b 52 0c             	mov    0xc(%edx),%edx
  801ac2:	89 15 00 50 80 00    	mov    %edx,0x805000
  801ac8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801acd:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801ad2:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  801ad5:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801adb:	53                   	push   %ebx
  801adc:	ff 75 0c             	pushl  0xc(%ebp)
  801adf:	68 08 50 80 00       	push   $0x805008
  801ae4:	e8 39 f0 ff ff       	call   800b22 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  801ae9:	ba 00 00 00 00       	mov    $0x0,%edx
  801aee:	b8 04 00 00 00       	mov    $0x4,%eax
  801af3:	e8 ca fe ff ff       	call   8019c2 <fsipc>
  801af8:	83 c4 10             	add    $0x10,%esp
  801afb:	85 c0                	test   %eax,%eax
  801afd:	78 1d                	js     801b1c <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  801aff:	39 d8                	cmp    %ebx,%eax
  801b01:	76 19                	jbe    801b1c <devfile_write+0x6a>
  801b03:	68 d4 2e 80 00       	push   $0x802ed4
  801b08:	68 e0 2e 80 00       	push   $0x802ee0
  801b0d:	68 a5 00 00 00       	push   $0xa5
  801b12:	68 f5 2e 80 00       	push   $0x802ef5
  801b17:	e8 16 e8 ff ff       	call   800332 <_panic>
	return r;
}
  801b1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b1f:	c9                   	leave  
  801b20:	c3                   	ret    

00801b21 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b21:	55                   	push   %ebp
  801b22:	89 e5                	mov    %esp,%ebp
  801b24:	56                   	push   %esi
  801b25:	53                   	push   %ebx
  801b26:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b29:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b2f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b34:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b3a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3f:	b8 03 00 00 00       	mov    $0x3,%eax
  801b44:	e8 79 fe ff ff       	call   8019c2 <fsipc>
  801b49:	89 c3                	mov    %eax,%ebx
  801b4b:	85 c0                	test   %eax,%eax
  801b4d:	78 4b                	js     801b9a <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b4f:	39 c6                	cmp    %eax,%esi
  801b51:	73 16                	jae    801b69 <devfile_read+0x48>
  801b53:	68 00 2f 80 00       	push   $0x802f00
  801b58:	68 e0 2e 80 00       	push   $0x802ee0
  801b5d:	6a 7c                	push   $0x7c
  801b5f:	68 f5 2e 80 00       	push   $0x802ef5
  801b64:	e8 c9 e7 ff ff       	call   800332 <_panic>
	assert(r <= PGSIZE);
  801b69:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b6e:	7e 16                	jle    801b86 <devfile_read+0x65>
  801b70:	68 07 2f 80 00       	push   $0x802f07
  801b75:	68 e0 2e 80 00       	push   $0x802ee0
  801b7a:	6a 7d                	push   $0x7d
  801b7c:	68 f5 2e 80 00       	push   $0x802ef5
  801b81:	e8 ac e7 ff ff       	call   800332 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b86:	83 ec 04             	sub    $0x4,%esp
  801b89:	50                   	push   %eax
  801b8a:	68 00 50 80 00       	push   $0x805000
  801b8f:	ff 75 0c             	pushl  0xc(%ebp)
  801b92:	e8 8b ef ff ff       	call   800b22 <memmove>
	return r;
  801b97:	83 c4 10             	add    $0x10,%esp
}
  801b9a:	89 d8                	mov    %ebx,%eax
  801b9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b9f:	5b                   	pop    %ebx
  801ba0:	5e                   	pop    %esi
  801ba1:	5d                   	pop    %ebp
  801ba2:	c3                   	ret    

00801ba3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	53                   	push   %ebx
  801ba7:	83 ec 20             	sub    $0x20,%esp
  801baa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bad:	53                   	push   %ebx
  801bae:	e8 a4 ed ff ff       	call   800957 <strlen>
  801bb3:	83 c4 10             	add    $0x10,%esp
  801bb6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bbb:	7f 67                	jg     801c24 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bbd:	83 ec 0c             	sub    $0xc,%esp
  801bc0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc3:	50                   	push   %eax
  801bc4:	e8 71 f8 ff ff       	call   80143a <fd_alloc>
  801bc9:	83 c4 10             	add    $0x10,%esp
		return r;
  801bcc:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bce:	85 c0                	test   %eax,%eax
  801bd0:	78 57                	js     801c29 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bd2:	83 ec 08             	sub    $0x8,%esp
  801bd5:	53                   	push   %ebx
  801bd6:	68 00 50 80 00       	push   $0x805000
  801bdb:	e8 b0 ed ff ff       	call   800990 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801be0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801be8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801beb:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf0:	e8 cd fd ff ff       	call   8019c2 <fsipc>
  801bf5:	89 c3                	mov    %eax,%ebx
  801bf7:	83 c4 10             	add    $0x10,%esp
  801bfa:	85 c0                	test   %eax,%eax
  801bfc:	79 14                	jns    801c12 <open+0x6f>
		fd_close(fd, 0);
  801bfe:	83 ec 08             	sub    $0x8,%esp
  801c01:	6a 00                	push   $0x0
  801c03:	ff 75 f4             	pushl  -0xc(%ebp)
  801c06:	e8 27 f9 ff ff       	call   801532 <fd_close>
		return r;
  801c0b:	83 c4 10             	add    $0x10,%esp
  801c0e:	89 da                	mov    %ebx,%edx
  801c10:	eb 17                	jmp    801c29 <open+0x86>
	}

	return fd2num(fd);
  801c12:	83 ec 0c             	sub    $0xc,%esp
  801c15:	ff 75 f4             	pushl  -0xc(%ebp)
  801c18:	e8 f6 f7 ff ff       	call   801413 <fd2num>
  801c1d:	89 c2                	mov    %eax,%edx
  801c1f:	83 c4 10             	add    $0x10,%esp
  801c22:	eb 05                	jmp    801c29 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c24:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c29:	89 d0                	mov    %edx,%eax
  801c2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c2e:	c9                   	leave  
  801c2f:	c3                   	ret    

00801c30 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c30:	55                   	push   %ebp
  801c31:	89 e5                	mov    %esp,%ebp
  801c33:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c36:	ba 00 00 00 00       	mov    $0x0,%edx
  801c3b:	b8 08 00 00 00       	mov    $0x8,%eax
  801c40:	e8 7d fd ff ff       	call   8019c2 <fsipc>
}
  801c45:	c9                   	leave  
  801c46:	c3                   	ret    

00801c47 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801c4d:	68 13 2f 80 00       	push   $0x802f13
  801c52:	ff 75 0c             	pushl  0xc(%ebp)
  801c55:	e8 36 ed ff ff       	call   800990 <strcpy>
	return 0;
}
  801c5a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c5f:	c9                   	leave  
  801c60:	c3                   	ret    

00801c61 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c61:	55                   	push   %ebp
  801c62:	89 e5                	mov    %esp,%ebp
  801c64:	53                   	push   %ebx
  801c65:	83 ec 10             	sub    $0x10,%esp
  801c68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c6b:	53                   	push   %ebx
  801c6c:	e8 92 09 00 00       	call   802603 <pageref>
  801c71:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801c74:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801c79:	83 f8 01             	cmp    $0x1,%eax
  801c7c:	75 10                	jne    801c8e <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801c7e:	83 ec 0c             	sub    $0xc,%esp
  801c81:	ff 73 0c             	pushl  0xc(%ebx)
  801c84:	e8 c0 02 00 00       	call   801f49 <nsipc_close>
  801c89:	89 c2                	mov    %eax,%edx
  801c8b:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801c8e:	89 d0                	mov    %edx,%eax
  801c90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c93:	c9                   	leave  
  801c94:	c3                   	ret    

00801c95 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c9b:	6a 00                	push   $0x0
  801c9d:	ff 75 10             	pushl  0x10(%ebp)
  801ca0:	ff 75 0c             	pushl  0xc(%ebp)
  801ca3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca6:	ff 70 0c             	pushl  0xc(%eax)
  801ca9:	e8 78 03 00 00       	call   802026 <nsipc_send>
}
  801cae:	c9                   	leave  
  801caf:	c3                   	ret    

00801cb0 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801cb6:	6a 00                	push   $0x0
  801cb8:	ff 75 10             	pushl  0x10(%ebp)
  801cbb:	ff 75 0c             	pushl  0xc(%ebp)
  801cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc1:	ff 70 0c             	pushl  0xc(%eax)
  801cc4:	e8 f1 02 00 00       	call   801fba <nsipc_recv>
}
  801cc9:	c9                   	leave  
  801cca:	c3                   	ret    

00801ccb <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801cd1:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801cd4:	52                   	push   %edx
  801cd5:	50                   	push   %eax
  801cd6:	e8 ae f7 ff ff       	call   801489 <fd_lookup>
  801cdb:	83 c4 10             	add    $0x10,%esp
  801cde:	85 c0                	test   %eax,%eax
  801ce0:	78 17                	js     801cf9 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce5:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801ceb:	39 08                	cmp    %ecx,(%eax)
  801ced:	75 05                	jne    801cf4 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801cef:	8b 40 0c             	mov    0xc(%eax),%eax
  801cf2:	eb 05                	jmp    801cf9 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801cf4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801cf9:	c9                   	leave  
  801cfa:	c3                   	ret    

00801cfb <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	56                   	push   %esi
  801cff:	53                   	push   %ebx
  801d00:	83 ec 1c             	sub    $0x1c,%esp
  801d03:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d08:	50                   	push   %eax
  801d09:	e8 2c f7 ff ff       	call   80143a <fd_alloc>
  801d0e:	89 c3                	mov    %eax,%ebx
  801d10:	83 c4 10             	add    $0x10,%esp
  801d13:	85 c0                	test   %eax,%eax
  801d15:	78 1b                	js     801d32 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d17:	83 ec 04             	sub    $0x4,%esp
  801d1a:	68 07 04 00 00       	push   $0x407
  801d1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d22:	6a 00                	push   $0x0
  801d24:	e8 6a f0 ff ff       	call   800d93 <sys_page_alloc>
  801d29:	89 c3                	mov    %eax,%ebx
  801d2b:	83 c4 10             	add    $0x10,%esp
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	79 10                	jns    801d42 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801d32:	83 ec 0c             	sub    $0xc,%esp
  801d35:	56                   	push   %esi
  801d36:	e8 0e 02 00 00       	call   801f49 <nsipc_close>
		return r;
  801d3b:	83 c4 10             	add    $0x10,%esp
  801d3e:	89 d8                	mov    %ebx,%eax
  801d40:	eb 24                	jmp    801d66 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d42:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d50:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d57:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d5a:	83 ec 0c             	sub    $0xc,%esp
  801d5d:	50                   	push   %eax
  801d5e:	e8 b0 f6 ff ff       	call   801413 <fd2num>
  801d63:	83 c4 10             	add    $0x10,%esp
}
  801d66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d69:	5b                   	pop    %ebx
  801d6a:	5e                   	pop    %esi
  801d6b:	5d                   	pop    %ebp
  801d6c:	c3                   	ret    

00801d6d <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d6d:	55                   	push   %ebp
  801d6e:	89 e5                	mov    %esp,%ebp
  801d70:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d73:	8b 45 08             	mov    0x8(%ebp),%eax
  801d76:	e8 50 ff ff ff       	call   801ccb <fd2sockid>
		return r;
  801d7b:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d7d:	85 c0                	test   %eax,%eax
  801d7f:	78 1f                	js     801da0 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d81:	83 ec 04             	sub    $0x4,%esp
  801d84:	ff 75 10             	pushl  0x10(%ebp)
  801d87:	ff 75 0c             	pushl  0xc(%ebp)
  801d8a:	50                   	push   %eax
  801d8b:	e8 12 01 00 00       	call   801ea2 <nsipc_accept>
  801d90:	83 c4 10             	add    $0x10,%esp
		return r;
  801d93:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d95:	85 c0                	test   %eax,%eax
  801d97:	78 07                	js     801da0 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801d99:	e8 5d ff ff ff       	call   801cfb <alloc_sockfd>
  801d9e:	89 c1                	mov    %eax,%ecx
}
  801da0:	89 c8                	mov    %ecx,%eax
  801da2:	c9                   	leave  
  801da3:	c3                   	ret    

00801da4 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801daa:	8b 45 08             	mov    0x8(%ebp),%eax
  801dad:	e8 19 ff ff ff       	call   801ccb <fd2sockid>
  801db2:	85 c0                	test   %eax,%eax
  801db4:	78 12                	js     801dc8 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801db6:	83 ec 04             	sub    $0x4,%esp
  801db9:	ff 75 10             	pushl  0x10(%ebp)
  801dbc:	ff 75 0c             	pushl  0xc(%ebp)
  801dbf:	50                   	push   %eax
  801dc0:	e8 2d 01 00 00       	call   801ef2 <nsipc_bind>
  801dc5:	83 c4 10             	add    $0x10,%esp
}
  801dc8:	c9                   	leave  
  801dc9:	c3                   	ret    

00801dca <shutdown>:

int
shutdown(int s, int how)
{
  801dca:	55                   	push   %ebp
  801dcb:	89 e5                	mov    %esp,%ebp
  801dcd:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd3:	e8 f3 fe ff ff       	call   801ccb <fd2sockid>
  801dd8:	85 c0                	test   %eax,%eax
  801dda:	78 0f                	js     801deb <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801ddc:	83 ec 08             	sub    $0x8,%esp
  801ddf:	ff 75 0c             	pushl  0xc(%ebp)
  801de2:	50                   	push   %eax
  801de3:	e8 3f 01 00 00       	call   801f27 <nsipc_shutdown>
  801de8:	83 c4 10             	add    $0x10,%esp
}
  801deb:	c9                   	leave  
  801dec:	c3                   	ret    

00801ded <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ded:	55                   	push   %ebp
  801dee:	89 e5                	mov    %esp,%ebp
  801df0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801df3:	8b 45 08             	mov    0x8(%ebp),%eax
  801df6:	e8 d0 fe ff ff       	call   801ccb <fd2sockid>
  801dfb:	85 c0                	test   %eax,%eax
  801dfd:	78 12                	js     801e11 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801dff:	83 ec 04             	sub    $0x4,%esp
  801e02:	ff 75 10             	pushl  0x10(%ebp)
  801e05:	ff 75 0c             	pushl  0xc(%ebp)
  801e08:	50                   	push   %eax
  801e09:	e8 55 01 00 00       	call   801f63 <nsipc_connect>
  801e0e:	83 c4 10             	add    $0x10,%esp
}
  801e11:	c9                   	leave  
  801e12:	c3                   	ret    

00801e13 <listen>:

int
listen(int s, int backlog)
{
  801e13:	55                   	push   %ebp
  801e14:	89 e5                	mov    %esp,%ebp
  801e16:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e19:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1c:	e8 aa fe ff ff       	call   801ccb <fd2sockid>
  801e21:	85 c0                	test   %eax,%eax
  801e23:	78 0f                	js     801e34 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801e25:	83 ec 08             	sub    $0x8,%esp
  801e28:	ff 75 0c             	pushl  0xc(%ebp)
  801e2b:	50                   	push   %eax
  801e2c:	e8 67 01 00 00       	call   801f98 <nsipc_listen>
  801e31:	83 c4 10             	add    $0x10,%esp
}
  801e34:	c9                   	leave  
  801e35:	c3                   	ret    

00801e36 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e36:	55                   	push   %ebp
  801e37:	89 e5                	mov    %esp,%ebp
  801e39:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e3c:	ff 75 10             	pushl  0x10(%ebp)
  801e3f:	ff 75 0c             	pushl  0xc(%ebp)
  801e42:	ff 75 08             	pushl  0x8(%ebp)
  801e45:	e8 3a 02 00 00       	call   802084 <nsipc_socket>
  801e4a:	83 c4 10             	add    $0x10,%esp
  801e4d:	85 c0                	test   %eax,%eax
  801e4f:	78 05                	js     801e56 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801e51:	e8 a5 fe ff ff       	call   801cfb <alloc_sockfd>
}
  801e56:	c9                   	leave  
  801e57:	c3                   	ret    

00801e58 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
  801e5b:	53                   	push   %ebx
  801e5c:	83 ec 04             	sub    $0x4,%esp
  801e5f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e61:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  801e68:	75 12                	jne    801e7c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e6a:	83 ec 0c             	sub    $0xc,%esp
  801e6d:	6a 02                	push   $0x2
  801e6f:	e8 66 f5 ff ff       	call   8013da <ipc_find_env>
  801e74:	a3 08 40 80 00       	mov    %eax,0x804008
  801e79:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e7c:	6a 07                	push   $0x7
  801e7e:	68 00 60 80 00       	push   $0x806000
  801e83:	53                   	push   %ebx
  801e84:	ff 35 08 40 80 00    	pushl  0x804008
  801e8a:	e8 f7 f4 ff ff       	call   801386 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801e8f:	83 c4 0c             	add    $0xc,%esp
  801e92:	6a 00                	push   $0x0
  801e94:	6a 00                	push   $0x0
  801e96:	6a 00                	push   $0x0
  801e98:	e8 80 f4 ff ff       	call   80131d <ipc_recv>
}
  801e9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ea0:	c9                   	leave  
  801ea1:	c3                   	ret    

00801ea2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	56                   	push   %esi
  801ea6:	53                   	push   %ebx
  801ea7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801eaa:	8b 45 08             	mov    0x8(%ebp),%eax
  801ead:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801eb2:	8b 06                	mov    (%esi),%eax
  801eb4:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801eb9:	b8 01 00 00 00       	mov    $0x1,%eax
  801ebe:	e8 95 ff ff ff       	call   801e58 <nsipc>
  801ec3:	89 c3                	mov    %eax,%ebx
  801ec5:	85 c0                	test   %eax,%eax
  801ec7:	78 20                	js     801ee9 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ec9:	83 ec 04             	sub    $0x4,%esp
  801ecc:	ff 35 10 60 80 00    	pushl  0x806010
  801ed2:	68 00 60 80 00       	push   $0x806000
  801ed7:	ff 75 0c             	pushl  0xc(%ebp)
  801eda:	e8 43 ec ff ff       	call   800b22 <memmove>
		*addrlen = ret->ret_addrlen;
  801edf:	a1 10 60 80 00       	mov    0x806010,%eax
  801ee4:	89 06                	mov    %eax,(%esi)
  801ee6:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801ee9:	89 d8                	mov    %ebx,%eax
  801eeb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eee:	5b                   	pop    %ebx
  801eef:	5e                   	pop    %esi
  801ef0:	5d                   	pop    %ebp
  801ef1:	c3                   	ret    

00801ef2 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ef2:	55                   	push   %ebp
  801ef3:	89 e5                	mov    %esp,%ebp
  801ef5:	53                   	push   %ebx
  801ef6:	83 ec 08             	sub    $0x8,%esp
  801ef9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801efc:	8b 45 08             	mov    0x8(%ebp),%eax
  801eff:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f04:	53                   	push   %ebx
  801f05:	ff 75 0c             	pushl  0xc(%ebp)
  801f08:	68 04 60 80 00       	push   $0x806004
  801f0d:	e8 10 ec ff ff       	call   800b22 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f12:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f18:	b8 02 00 00 00       	mov    $0x2,%eax
  801f1d:	e8 36 ff ff ff       	call   801e58 <nsipc>
}
  801f22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f25:	c9                   	leave  
  801f26:	c3                   	ret    

00801f27 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f27:	55                   	push   %ebp
  801f28:	89 e5                	mov    %esp,%ebp
  801f2a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f30:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801f35:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f38:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801f3d:	b8 03 00 00 00       	mov    $0x3,%eax
  801f42:	e8 11 ff ff ff       	call   801e58 <nsipc>
}
  801f47:	c9                   	leave  
  801f48:	c3                   	ret    

00801f49 <nsipc_close>:

int
nsipc_close(int s)
{
  801f49:	55                   	push   %ebp
  801f4a:	89 e5                	mov    %esp,%ebp
  801f4c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f52:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801f57:	b8 04 00 00 00       	mov    $0x4,%eax
  801f5c:	e8 f7 fe ff ff       	call   801e58 <nsipc>
}
  801f61:	c9                   	leave  
  801f62:	c3                   	ret    

00801f63 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f63:	55                   	push   %ebp
  801f64:	89 e5                	mov    %esp,%ebp
  801f66:	53                   	push   %ebx
  801f67:	83 ec 08             	sub    $0x8,%esp
  801f6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f70:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f75:	53                   	push   %ebx
  801f76:	ff 75 0c             	pushl  0xc(%ebp)
  801f79:	68 04 60 80 00       	push   $0x806004
  801f7e:	e8 9f eb ff ff       	call   800b22 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f83:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801f89:	b8 05 00 00 00       	mov    $0x5,%eax
  801f8e:	e8 c5 fe ff ff       	call   801e58 <nsipc>
}
  801f93:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f96:	c9                   	leave  
  801f97:	c3                   	ret    

00801f98 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801f98:	55                   	push   %ebp
  801f99:	89 e5                	mov    %esp,%ebp
  801f9b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801fa6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801fae:	b8 06 00 00 00       	mov    $0x6,%eax
  801fb3:	e8 a0 fe ff ff       	call   801e58 <nsipc>
}
  801fb8:	c9                   	leave  
  801fb9:	c3                   	ret    

00801fba <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801fba:	55                   	push   %ebp
  801fbb:	89 e5                	mov    %esp,%ebp
  801fbd:	56                   	push   %esi
  801fbe:	53                   	push   %ebx
  801fbf:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801fc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801fca:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801fd0:	8b 45 14             	mov    0x14(%ebp),%eax
  801fd3:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801fd8:	b8 07 00 00 00       	mov    $0x7,%eax
  801fdd:	e8 76 fe ff ff       	call   801e58 <nsipc>
  801fe2:	89 c3                	mov    %eax,%ebx
  801fe4:	85 c0                	test   %eax,%eax
  801fe6:	78 35                	js     80201d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801fe8:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801fed:	7f 04                	jg     801ff3 <nsipc_recv+0x39>
  801fef:	39 c6                	cmp    %eax,%esi
  801ff1:	7d 16                	jge    802009 <nsipc_recv+0x4f>
  801ff3:	68 1f 2f 80 00       	push   $0x802f1f
  801ff8:	68 e0 2e 80 00       	push   $0x802ee0
  801ffd:	6a 62                	push   $0x62
  801fff:	68 34 2f 80 00       	push   $0x802f34
  802004:	e8 29 e3 ff ff       	call   800332 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802009:	83 ec 04             	sub    $0x4,%esp
  80200c:	50                   	push   %eax
  80200d:	68 00 60 80 00       	push   $0x806000
  802012:	ff 75 0c             	pushl  0xc(%ebp)
  802015:	e8 08 eb ff ff       	call   800b22 <memmove>
  80201a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80201d:	89 d8                	mov    %ebx,%eax
  80201f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802022:	5b                   	pop    %ebx
  802023:	5e                   	pop    %esi
  802024:	5d                   	pop    %ebp
  802025:	c3                   	ret    

00802026 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802026:	55                   	push   %ebp
  802027:	89 e5                	mov    %esp,%ebp
  802029:	53                   	push   %ebx
  80202a:	83 ec 04             	sub    $0x4,%esp
  80202d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802030:	8b 45 08             	mov    0x8(%ebp),%eax
  802033:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802038:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80203e:	7e 16                	jle    802056 <nsipc_send+0x30>
  802040:	68 40 2f 80 00       	push   $0x802f40
  802045:	68 e0 2e 80 00       	push   $0x802ee0
  80204a:	6a 6d                	push   $0x6d
  80204c:	68 34 2f 80 00       	push   $0x802f34
  802051:	e8 dc e2 ff ff       	call   800332 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802056:	83 ec 04             	sub    $0x4,%esp
  802059:	53                   	push   %ebx
  80205a:	ff 75 0c             	pushl  0xc(%ebp)
  80205d:	68 0c 60 80 00       	push   $0x80600c
  802062:	e8 bb ea ff ff       	call   800b22 <memmove>
	nsipcbuf.send.req_size = size;
  802067:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80206d:	8b 45 14             	mov    0x14(%ebp),%eax
  802070:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802075:	b8 08 00 00 00       	mov    $0x8,%eax
  80207a:	e8 d9 fd ff ff       	call   801e58 <nsipc>
}
  80207f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802082:	c9                   	leave  
  802083:	c3                   	ret    

00802084 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802084:	55                   	push   %ebp
  802085:	89 e5                	mov    %esp,%ebp
  802087:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80208a:	8b 45 08             	mov    0x8(%ebp),%eax
  80208d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802092:	8b 45 0c             	mov    0xc(%ebp),%eax
  802095:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80209a:	8b 45 10             	mov    0x10(%ebp),%eax
  80209d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8020a2:	b8 09 00 00 00       	mov    $0x9,%eax
  8020a7:	e8 ac fd ff ff       	call   801e58 <nsipc>
}
  8020ac:	c9                   	leave  
  8020ad:	c3                   	ret    

008020ae <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8020ae:	55                   	push   %ebp
  8020af:	89 e5                	mov    %esp,%ebp
  8020b1:	56                   	push   %esi
  8020b2:	53                   	push   %ebx
  8020b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8020b6:	83 ec 0c             	sub    $0xc,%esp
  8020b9:	ff 75 08             	pushl  0x8(%ebp)
  8020bc:	e8 62 f3 ff ff       	call   801423 <fd2data>
  8020c1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8020c3:	83 c4 08             	add    $0x8,%esp
  8020c6:	68 4c 2f 80 00       	push   $0x802f4c
  8020cb:	53                   	push   %ebx
  8020cc:	e8 bf e8 ff ff       	call   800990 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8020d1:	8b 46 04             	mov    0x4(%esi),%eax
  8020d4:	2b 06                	sub    (%esi),%eax
  8020d6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8020dc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8020e3:	00 00 00 
	stat->st_dev = &devpipe;
  8020e6:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8020ed:	30 80 00 
	return 0;
}
  8020f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8020f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020f8:	5b                   	pop    %ebx
  8020f9:	5e                   	pop    %esi
  8020fa:	5d                   	pop    %ebp
  8020fb:	c3                   	ret    

008020fc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8020fc:	55                   	push   %ebp
  8020fd:	89 e5                	mov    %esp,%ebp
  8020ff:	53                   	push   %ebx
  802100:	83 ec 0c             	sub    $0xc,%esp
  802103:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802106:	53                   	push   %ebx
  802107:	6a 00                	push   $0x0
  802109:	e8 0a ed ff ff       	call   800e18 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80210e:	89 1c 24             	mov    %ebx,(%esp)
  802111:	e8 0d f3 ff ff       	call   801423 <fd2data>
  802116:	83 c4 08             	add    $0x8,%esp
  802119:	50                   	push   %eax
  80211a:	6a 00                	push   $0x0
  80211c:	e8 f7 ec ff ff       	call   800e18 <sys_page_unmap>
}
  802121:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802124:	c9                   	leave  
  802125:	c3                   	ret    

00802126 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802126:	55                   	push   %ebp
  802127:	89 e5                	mov    %esp,%ebp
  802129:	57                   	push   %edi
  80212a:	56                   	push   %esi
  80212b:	53                   	push   %ebx
  80212c:	83 ec 1c             	sub    $0x1c,%esp
  80212f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802132:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802134:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802139:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80213c:	83 ec 0c             	sub    $0xc,%esp
  80213f:	ff 75 e0             	pushl  -0x20(%ebp)
  802142:	e8 bc 04 00 00       	call   802603 <pageref>
  802147:	89 c3                	mov    %eax,%ebx
  802149:	89 3c 24             	mov    %edi,(%esp)
  80214c:	e8 b2 04 00 00       	call   802603 <pageref>
  802151:	83 c4 10             	add    $0x10,%esp
  802154:	39 c3                	cmp    %eax,%ebx
  802156:	0f 94 c1             	sete   %cl
  802159:	0f b6 c9             	movzbl %cl,%ecx
  80215c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80215f:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  802165:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802168:	39 ce                	cmp    %ecx,%esi
  80216a:	74 1b                	je     802187 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80216c:	39 c3                	cmp    %eax,%ebx
  80216e:	75 c4                	jne    802134 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802170:	8b 42 58             	mov    0x58(%edx),%eax
  802173:	ff 75 e4             	pushl  -0x1c(%ebp)
  802176:	50                   	push   %eax
  802177:	56                   	push   %esi
  802178:	68 53 2f 80 00       	push   $0x802f53
  80217d:	e8 89 e2 ff ff       	call   80040b <cprintf>
  802182:	83 c4 10             	add    $0x10,%esp
  802185:	eb ad                	jmp    802134 <_pipeisclosed+0xe>
	}
}
  802187:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80218a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    

00802192 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802192:	55                   	push   %ebp
  802193:	89 e5                	mov    %esp,%ebp
  802195:	57                   	push   %edi
  802196:	56                   	push   %esi
  802197:	53                   	push   %ebx
  802198:	83 ec 28             	sub    $0x28,%esp
  80219b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80219e:	56                   	push   %esi
  80219f:	e8 7f f2 ff ff       	call   801423 <fd2data>
  8021a4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021a6:	83 c4 10             	add    $0x10,%esp
  8021a9:	bf 00 00 00 00       	mov    $0x0,%edi
  8021ae:	eb 4b                	jmp    8021fb <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8021b0:	89 da                	mov    %ebx,%edx
  8021b2:	89 f0                	mov    %esi,%eax
  8021b4:	e8 6d ff ff ff       	call   802126 <_pipeisclosed>
  8021b9:	85 c0                	test   %eax,%eax
  8021bb:	75 48                	jne    802205 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8021bd:	e8 b2 eb ff ff       	call   800d74 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8021c2:	8b 43 04             	mov    0x4(%ebx),%eax
  8021c5:	8b 0b                	mov    (%ebx),%ecx
  8021c7:	8d 51 20             	lea    0x20(%ecx),%edx
  8021ca:	39 d0                	cmp    %edx,%eax
  8021cc:	73 e2                	jae    8021b0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8021ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021d1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8021d5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8021d8:	89 c2                	mov    %eax,%edx
  8021da:	c1 fa 1f             	sar    $0x1f,%edx
  8021dd:	89 d1                	mov    %edx,%ecx
  8021df:	c1 e9 1b             	shr    $0x1b,%ecx
  8021e2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8021e5:	83 e2 1f             	and    $0x1f,%edx
  8021e8:	29 ca                	sub    %ecx,%edx
  8021ea:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8021ee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8021f2:	83 c0 01             	add    $0x1,%eax
  8021f5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021f8:	83 c7 01             	add    $0x1,%edi
  8021fb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8021fe:	75 c2                	jne    8021c2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802200:	8b 45 10             	mov    0x10(%ebp),%eax
  802203:	eb 05                	jmp    80220a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802205:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80220a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80220d:	5b                   	pop    %ebx
  80220e:	5e                   	pop    %esi
  80220f:	5f                   	pop    %edi
  802210:	5d                   	pop    %ebp
  802211:	c3                   	ret    

00802212 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802212:	55                   	push   %ebp
  802213:	89 e5                	mov    %esp,%ebp
  802215:	57                   	push   %edi
  802216:	56                   	push   %esi
  802217:	53                   	push   %ebx
  802218:	83 ec 18             	sub    $0x18,%esp
  80221b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80221e:	57                   	push   %edi
  80221f:	e8 ff f1 ff ff       	call   801423 <fd2data>
  802224:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802226:	83 c4 10             	add    $0x10,%esp
  802229:	bb 00 00 00 00       	mov    $0x0,%ebx
  80222e:	eb 3d                	jmp    80226d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802230:	85 db                	test   %ebx,%ebx
  802232:	74 04                	je     802238 <devpipe_read+0x26>
				return i;
  802234:	89 d8                	mov    %ebx,%eax
  802236:	eb 44                	jmp    80227c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802238:	89 f2                	mov    %esi,%edx
  80223a:	89 f8                	mov    %edi,%eax
  80223c:	e8 e5 fe ff ff       	call   802126 <_pipeisclosed>
  802241:	85 c0                	test   %eax,%eax
  802243:	75 32                	jne    802277 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802245:	e8 2a eb ff ff       	call   800d74 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80224a:	8b 06                	mov    (%esi),%eax
  80224c:	3b 46 04             	cmp    0x4(%esi),%eax
  80224f:	74 df                	je     802230 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802251:	99                   	cltd   
  802252:	c1 ea 1b             	shr    $0x1b,%edx
  802255:	01 d0                	add    %edx,%eax
  802257:	83 e0 1f             	and    $0x1f,%eax
  80225a:	29 d0                	sub    %edx,%eax
  80225c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802261:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802264:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802267:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80226a:	83 c3 01             	add    $0x1,%ebx
  80226d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802270:	75 d8                	jne    80224a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802272:	8b 45 10             	mov    0x10(%ebp),%eax
  802275:	eb 05                	jmp    80227c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802277:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80227c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80227f:	5b                   	pop    %ebx
  802280:	5e                   	pop    %esi
  802281:	5f                   	pop    %edi
  802282:	5d                   	pop    %ebp
  802283:	c3                   	ret    

00802284 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802284:	55                   	push   %ebp
  802285:	89 e5                	mov    %esp,%ebp
  802287:	56                   	push   %esi
  802288:	53                   	push   %ebx
  802289:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80228c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80228f:	50                   	push   %eax
  802290:	e8 a5 f1 ff ff       	call   80143a <fd_alloc>
  802295:	83 c4 10             	add    $0x10,%esp
  802298:	89 c2                	mov    %eax,%edx
  80229a:	85 c0                	test   %eax,%eax
  80229c:	0f 88 2c 01 00 00    	js     8023ce <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022a2:	83 ec 04             	sub    $0x4,%esp
  8022a5:	68 07 04 00 00       	push   $0x407
  8022aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8022ad:	6a 00                	push   $0x0
  8022af:	e8 df ea ff ff       	call   800d93 <sys_page_alloc>
  8022b4:	83 c4 10             	add    $0x10,%esp
  8022b7:	89 c2                	mov    %eax,%edx
  8022b9:	85 c0                	test   %eax,%eax
  8022bb:	0f 88 0d 01 00 00    	js     8023ce <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8022c1:	83 ec 0c             	sub    $0xc,%esp
  8022c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8022c7:	50                   	push   %eax
  8022c8:	e8 6d f1 ff ff       	call   80143a <fd_alloc>
  8022cd:	89 c3                	mov    %eax,%ebx
  8022cf:	83 c4 10             	add    $0x10,%esp
  8022d2:	85 c0                	test   %eax,%eax
  8022d4:	0f 88 e2 00 00 00    	js     8023bc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022da:	83 ec 04             	sub    $0x4,%esp
  8022dd:	68 07 04 00 00       	push   $0x407
  8022e2:	ff 75 f0             	pushl  -0x10(%ebp)
  8022e5:	6a 00                	push   $0x0
  8022e7:	e8 a7 ea ff ff       	call   800d93 <sys_page_alloc>
  8022ec:	89 c3                	mov    %eax,%ebx
  8022ee:	83 c4 10             	add    $0x10,%esp
  8022f1:	85 c0                	test   %eax,%eax
  8022f3:	0f 88 c3 00 00 00    	js     8023bc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8022f9:	83 ec 0c             	sub    $0xc,%esp
  8022fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8022ff:	e8 1f f1 ff ff       	call   801423 <fd2data>
  802304:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802306:	83 c4 0c             	add    $0xc,%esp
  802309:	68 07 04 00 00       	push   $0x407
  80230e:	50                   	push   %eax
  80230f:	6a 00                	push   $0x0
  802311:	e8 7d ea ff ff       	call   800d93 <sys_page_alloc>
  802316:	89 c3                	mov    %eax,%ebx
  802318:	83 c4 10             	add    $0x10,%esp
  80231b:	85 c0                	test   %eax,%eax
  80231d:	0f 88 89 00 00 00    	js     8023ac <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802323:	83 ec 0c             	sub    $0xc,%esp
  802326:	ff 75 f0             	pushl  -0x10(%ebp)
  802329:	e8 f5 f0 ff ff       	call   801423 <fd2data>
  80232e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802335:	50                   	push   %eax
  802336:	6a 00                	push   $0x0
  802338:	56                   	push   %esi
  802339:	6a 00                	push   $0x0
  80233b:	e8 96 ea ff ff       	call   800dd6 <sys_page_map>
  802340:	89 c3                	mov    %eax,%ebx
  802342:	83 c4 20             	add    $0x20,%esp
  802345:	85 c0                	test   %eax,%eax
  802347:	78 55                	js     80239e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802349:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80234f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802352:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802354:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802357:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80235e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802364:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802367:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802369:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80236c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802373:	83 ec 0c             	sub    $0xc,%esp
  802376:	ff 75 f4             	pushl  -0xc(%ebp)
  802379:	e8 95 f0 ff ff       	call   801413 <fd2num>
  80237e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802381:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802383:	83 c4 04             	add    $0x4,%esp
  802386:	ff 75 f0             	pushl  -0x10(%ebp)
  802389:	e8 85 f0 ff ff       	call   801413 <fd2num>
  80238e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802391:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802394:	83 c4 10             	add    $0x10,%esp
  802397:	ba 00 00 00 00       	mov    $0x0,%edx
  80239c:	eb 30                	jmp    8023ce <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80239e:	83 ec 08             	sub    $0x8,%esp
  8023a1:	56                   	push   %esi
  8023a2:	6a 00                	push   $0x0
  8023a4:	e8 6f ea ff ff       	call   800e18 <sys_page_unmap>
  8023a9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8023ac:	83 ec 08             	sub    $0x8,%esp
  8023af:	ff 75 f0             	pushl  -0x10(%ebp)
  8023b2:	6a 00                	push   $0x0
  8023b4:	e8 5f ea ff ff       	call   800e18 <sys_page_unmap>
  8023b9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8023bc:	83 ec 08             	sub    $0x8,%esp
  8023bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8023c2:	6a 00                	push   $0x0
  8023c4:	e8 4f ea ff ff       	call   800e18 <sys_page_unmap>
  8023c9:	83 c4 10             	add    $0x10,%esp
  8023cc:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8023ce:	89 d0                	mov    %edx,%eax
  8023d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023d3:	5b                   	pop    %ebx
  8023d4:	5e                   	pop    %esi
  8023d5:	5d                   	pop    %ebp
  8023d6:	c3                   	ret    

008023d7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8023d7:	55                   	push   %ebp
  8023d8:	89 e5                	mov    %esp,%ebp
  8023da:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023e0:	50                   	push   %eax
  8023e1:	ff 75 08             	pushl  0x8(%ebp)
  8023e4:	e8 a0 f0 ff ff       	call   801489 <fd_lookup>
  8023e9:	83 c4 10             	add    $0x10,%esp
  8023ec:	85 c0                	test   %eax,%eax
  8023ee:	78 18                	js     802408 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8023f0:	83 ec 0c             	sub    $0xc,%esp
  8023f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8023f6:	e8 28 f0 ff ff       	call   801423 <fd2data>
	return _pipeisclosed(fd, p);
  8023fb:	89 c2                	mov    %eax,%edx
  8023fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802400:	e8 21 fd ff ff       	call   802126 <_pipeisclosed>
  802405:	83 c4 10             	add    $0x10,%esp
}
  802408:	c9                   	leave  
  802409:	c3                   	ret    

0080240a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80240a:	55                   	push   %ebp
  80240b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80240d:	b8 00 00 00 00       	mov    $0x0,%eax
  802412:	5d                   	pop    %ebp
  802413:	c3                   	ret    

00802414 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802414:	55                   	push   %ebp
  802415:	89 e5                	mov    %esp,%ebp
  802417:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80241a:	68 6b 2f 80 00       	push   $0x802f6b
  80241f:	ff 75 0c             	pushl  0xc(%ebp)
  802422:	e8 69 e5 ff ff       	call   800990 <strcpy>
	return 0;
}
  802427:	b8 00 00 00 00       	mov    $0x0,%eax
  80242c:	c9                   	leave  
  80242d:	c3                   	ret    

0080242e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80242e:	55                   	push   %ebp
  80242f:	89 e5                	mov    %esp,%ebp
  802431:	57                   	push   %edi
  802432:	56                   	push   %esi
  802433:	53                   	push   %ebx
  802434:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80243a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80243f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802445:	eb 2d                	jmp    802474 <devcons_write+0x46>
		m = n - tot;
  802447:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80244a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80244c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80244f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802454:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802457:	83 ec 04             	sub    $0x4,%esp
  80245a:	53                   	push   %ebx
  80245b:	03 45 0c             	add    0xc(%ebp),%eax
  80245e:	50                   	push   %eax
  80245f:	57                   	push   %edi
  802460:	e8 bd e6 ff ff       	call   800b22 <memmove>
		sys_cputs(buf, m);
  802465:	83 c4 08             	add    $0x8,%esp
  802468:	53                   	push   %ebx
  802469:	57                   	push   %edi
  80246a:	e8 68 e8 ff ff       	call   800cd7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80246f:	01 de                	add    %ebx,%esi
  802471:	83 c4 10             	add    $0x10,%esp
  802474:	89 f0                	mov    %esi,%eax
  802476:	3b 75 10             	cmp    0x10(%ebp),%esi
  802479:	72 cc                	jb     802447 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80247b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80247e:	5b                   	pop    %ebx
  80247f:	5e                   	pop    %esi
  802480:	5f                   	pop    %edi
  802481:	5d                   	pop    %ebp
  802482:	c3                   	ret    

00802483 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802483:	55                   	push   %ebp
  802484:	89 e5                	mov    %esp,%ebp
  802486:	83 ec 08             	sub    $0x8,%esp
  802489:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80248e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802492:	74 2a                	je     8024be <devcons_read+0x3b>
  802494:	eb 05                	jmp    80249b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802496:	e8 d9 e8 ff ff       	call   800d74 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80249b:	e8 55 e8 ff ff       	call   800cf5 <sys_cgetc>
  8024a0:	85 c0                	test   %eax,%eax
  8024a2:	74 f2                	je     802496 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8024a4:	85 c0                	test   %eax,%eax
  8024a6:	78 16                	js     8024be <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8024a8:	83 f8 04             	cmp    $0x4,%eax
  8024ab:	74 0c                	je     8024b9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8024ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024b0:	88 02                	mov    %al,(%edx)
	return 1;
  8024b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8024b7:	eb 05                	jmp    8024be <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8024b9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8024be:	c9                   	leave  
  8024bf:	c3                   	ret    

008024c0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8024c0:	55                   	push   %ebp
  8024c1:	89 e5                	mov    %esp,%ebp
  8024c3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8024c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8024c9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8024cc:	6a 01                	push   $0x1
  8024ce:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024d1:	50                   	push   %eax
  8024d2:	e8 00 e8 ff ff       	call   800cd7 <sys_cputs>
}
  8024d7:	83 c4 10             	add    $0x10,%esp
  8024da:	c9                   	leave  
  8024db:	c3                   	ret    

008024dc <getchar>:

int
getchar(void)
{
  8024dc:	55                   	push   %ebp
  8024dd:	89 e5                	mov    %esp,%ebp
  8024df:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8024e2:	6a 01                	push   $0x1
  8024e4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024e7:	50                   	push   %eax
  8024e8:	6a 00                	push   $0x0
  8024ea:	e8 00 f2 ff ff       	call   8016ef <read>
	if (r < 0)
  8024ef:	83 c4 10             	add    $0x10,%esp
  8024f2:	85 c0                	test   %eax,%eax
  8024f4:	78 0f                	js     802505 <getchar+0x29>
		return r;
	if (r < 1)
  8024f6:	85 c0                	test   %eax,%eax
  8024f8:	7e 06                	jle    802500 <getchar+0x24>
		return -E_EOF;
	return c;
  8024fa:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8024fe:	eb 05                	jmp    802505 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802500:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802505:	c9                   	leave  
  802506:	c3                   	ret    

00802507 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802507:	55                   	push   %ebp
  802508:	89 e5                	mov    %esp,%ebp
  80250a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80250d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802510:	50                   	push   %eax
  802511:	ff 75 08             	pushl  0x8(%ebp)
  802514:	e8 70 ef ff ff       	call   801489 <fd_lookup>
  802519:	83 c4 10             	add    $0x10,%esp
  80251c:	85 c0                	test   %eax,%eax
  80251e:	78 11                	js     802531 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802520:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802523:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802529:	39 10                	cmp    %edx,(%eax)
  80252b:	0f 94 c0             	sete   %al
  80252e:	0f b6 c0             	movzbl %al,%eax
}
  802531:	c9                   	leave  
  802532:	c3                   	ret    

00802533 <opencons>:

int
opencons(void)
{
  802533:	55                   	push   %ebp
  802534:	89 e5                	mov    %esp,%ebp
  802536:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802539:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80253c:	50                   	push   %eax
  80253d:	e8 f8 ee ff ff       	call   80143a <fd_alloc>
  802542:	83 c4 10             	add    $0x10,%esp
		return r;
  802545:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802547:	85 c0                	test   %eax,%eax
  802549:	78 3e                	js     802589 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80254b:	83 ec 04             	sub    $0x4,%esp
  80254e:	68 07 04 00 00       	push   $0x407
  802553:	ff 75 f4             	pushl  -0xc(%ebp)
  802556:	6a 00                	push   $0x0
  802558:	e8 36 e8 ff ff       	call   800d93 <sys_page_alloc>
  80255d:	83 c4 10             	add    $0x10,%esp
		return r;
  802560:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802562:	85 c0                	test   %eax,%eax
  802564:	78 23                	js     802589 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802566:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80256c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80256f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802571:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802574:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80257b:	83 ec 0c             	sub    $0xc,%esp
  80257e:	50                   	push   %eax
  80257f:	e8 8f ee ff ff       	call   801413 <fd2num>
  802584:	89 c2                	mov    %eax,%edx
  802586:	83 c4 10             	add    $0x10,%esp
}
  802589:	89 d0                	mov    %edx,%eax
  80258b:	c9                   	leave  
  80258c:	c3                   	ret    

0080258d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80258d:	55                   	push   %ebp
  80258e:	89 e5                	mov    %esp,%ebp
  802590:	53                   	push   %ebx
  802591:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  802594:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80259b:	75 28                	jne    8025c5 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  80259d:	e8 b3 e7 ff ff       	call   800d55 <sys_getenvid>
  8025a2:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  8025a4:	83 ec 04             	sub    $0x4,%esp
  8025a7:	6a 06                	push   $0x6
  8025a9:	68 00 f0 bf ee       	push   $0xeebff000
  8025ae:	50                   	push   %eax
  8025af:	e8 df e7 ff ff       	call   800d93 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  8025b4:	83 c4 08             	add    $0x8,%esp
  8025b7:	68 d2 25 80 00       	push   $0x8025d2
  8025bc:	53                   	push   %ebx
  8025bd:	e8 1c e9 ff ff       	call   800ede <sys_env_set_pgfault_upcall>
  8025c2:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8025c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8025c8:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8025cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8025d0:	c9                   	leave  
  8025d1:	c3                   	ret    

008025d2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8025d2:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8025d3:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8025d8:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8025da:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  8025dd:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  8025df:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  8025e2:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  8025e5:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  8025e8:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  8025eb:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  8025ee:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  8025f1:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  8025f4:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  8025f7:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  8025fa:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  8025fd:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  802600:	61                   	popa   
	popfl
  802601:	9d                   	popf   
	ret
  802602:	c3                   	ret    

00802603 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802603:	55                   	push   %ebp
  802604:	89 e5                	mov    %esp,%ebp
  802606:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802609:	89 d0                	mov    %edx,%eax
  80260b:	c1 e8 16             	shr    $0x16,%eax
  80260e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802615:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80261a:	f6 c1 01             	test   $0x1,%cl
  80261d:	74 1d                	je     80263c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80261f:	c1 ea 0c             	shr    $0xc,%edx
  802622:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802629:	f6 c2 01             	test   $0x1,%dl
  80262c:	74 0e                	je     80263c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80262e:	c1 ea 0c             	shr    $0xc,%edx
  802631:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802638:	ef 
  802639:	0f b7 c0             	movzwl %ax,%eax
}
  80263c:	5d                   	pop    %ebp
  80263d:	c3                   	ret    
  80263e:	66 90                	xchg   %ax,%ax

00802640 <__udivdi3>:
  802640:	55                   	push   %ebp
  802641:	57                   	push   %edi
  802642:	56                   	push   %esi
  802643:	53                   	push   %ebx
  802644:	83 ec 1c             	sub    $0x1c,%esp
  802647:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80264b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80264f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802653:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802657:	85 f6                	test   %esi,%esi
  802659:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80265d:	89 ca                	mov    %ecx,%edx
  80265f:	89 f8                	mov    %edi,%eax
  802661:	75 3d                	jne    8026a0 <__udivdi3+0x60>
  802663:	39 cf                	cmp    %ecx,%edi
  802665:	0f 87 c5 00 00 00    	ja     802730 <__udivdi3+0xf0>
  80266b:	85 ff                	test   %edi,%edi
  80266d:	89 fd                	mov    %edi,%ebp
  80266f:	75 0b                	jne    80267c <__udivdi3+0x3c>
  802671:	b8 01 00 00 00       	mov    $0x1,%eax
  802676:	31 d2                	xor    %edx,%edx
  802678:	f7 f7                	div    %edi
  80267a:	89 c5                	mov    %eax,%ebp
  80267c:	89 c8                	mov    %ecx,%eax
  80267e:	31 d2                	xor    %edx,%edx
  802680:	f7 f5                	div    %ebp
  802682:	89 c1                	mov    %eax,%ecx
  802684:	89 d8                	mov    %ebx,%eax
  802686:	89 cf                	mov    %ecx,%edi
  802688:	f7 f5                	div    %ebp
  80268a:	89 c3                	mov    %eax,%ebx
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
  8026a0:	39 ce                	cmp    %ecx,%esi
  8026a2:	77 74                	ja     802718 <__udivdi3+0xd8>
  8026a4:	0f bd fe             	bsr    %esi,%edi
  8026a7:	83 f7 1f             	xor    $0x1f,%edi
  8026aa:	0f 84 98 00 00 00    	je     802748 <__udivdi3+0x108>
  8026b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8026b5:	89 f9                	mov    %edi,%ecx
  8026b7:	89 c5                	mov    %eax,%ebp
  8026b9:	29 fb                	sub    %edi,%ebx
  8026bb:	d3 e6                	shl    %cl,%esi
  8026bd:	89 d9                	mov    %ebx,%ecx
  8026bf:	d3 ed                	shr    %cl,%ebp
  8026c1:	89 f9                	mov    %edi,%ecx
  8026c3:	d3 e0                	shl    %cl,%eax
  8026c5:	09 ee                	or     %ebp,%esi
  8026c7:	89 d9                	mov    %ebx,%ecx
  8026c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026cd:	89 d5                	mov    %edx,%ebp
  8026cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026d3:	d3 ed                	shr    %cl,%ebp
  8026d5:	89 f9                	mov    %edi,%ecx
  8026d7:	d3 e2                	shl    %cl,%edx
  8026d9:	89 d9                	mov    %ebx,%ecx
  8026db:	d3 e8                	shr    %cl,%eax
  8026dd:	09 c2                	or     %eax,%edx
  8026df:	89 d0                	mov    %edx,%eax
  8026e1:	89 ea                	mov    %ebp,%edx
  8026e3:	f7 f6                	div    %esi
  8026e5:	89 d5                	mov    %edx,%ebp
  8026e7:	89 c3                	mov    %eax,%ebx
  8026e9:	f7 64 24 0c          	mull   0xc(%esp)
  8026ed:	39 d5                	cmp    %edx,%ebp
  8026ef:	72 10                	jb     802701 <__udivdi3+0xc1>
  8026f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8026f5:	89 f9                	mov    %edi,%ecx
  8026f7:	d3 e6                	shl    %cl,%esi
  8026f9:	39 c6                	cmp    %eax,%esi
  8026fb:	73 07                	jae    802704 <__udivdi3+0xc4>
  8026fd:	39 d5                	cmp    %edx,%ebp
  8026ff:	75 03                	jne    802704 <__udivdi3+0xc4>
  802701:	83 eb 01             	sub    $0x1,%ebx
  802704:	31 ff                	xor    %edi,%edi
  802706:	89 d8                	mov    %ebx,%eax
  802708:	89 fa                	mov    %edi,%edx
  80270a:	83 c4 1c             	add    $0x1c,%esp
  80270d:	5b                   	pop    %ebx
  80270e:	5e                   	pop    %esi
  80270f:	5f                   	pop    %edi
  802710:	5d                   	pop    %ebp
  802711:	c3                   	ret    
  802712:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802718:	31 ff                	xor    %edi,%edi
  80271a:	31 db                	xor    %ebx,%ebx
  80271c:	89 d8                	mov    %ebx,%eax
  80271e:	89 fa                	mov    %edi,%edx
  802720:	83 c4 1c             	add    $0x1c,%esp
  802723:	5b                   	pop    %ebx
  802724:	5e                   	pop    %esi
  802725:	5f                   	pop    %edi
  802726:	5d                   	pop    %ebp
  802727:	c3                   	ret    
  802728:	90                   	nop
  802729:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802730:	89 d8                	mov    %ebx,%eax
  802732:	f7 f7                	div    %edi
  802734:	31 ff                	xor    %edi,%edi
  802736:	89 c3                	mov    %eax,%ebx
  802738:	89 d8                	mov    %ebx,%eax
  80273a:	89 fa                	mov    %edi,%edx
  80273c:	83 c4 1c             	add    $0x1c,%esp
  80273f:	5b                   	pop    %ebx
  802740:	5e                   	pop    %esi
  802741:	5f                   	pop    %edi
  802742:	5d                   	pop    %ebp
  802743:	c3                   	ret    
  802744:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802748:	39 ce                	cmp    %ecx,%esi
  80274a:	72 0c                	jb     802758 <__udivdi3+0x118>
  80274c:	31 db                	xor    %ebx,%ebx
  80274e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802752:	0f 87 34 ff ff ff    	ja     80268c <__udivdi3+0x4c>
  802758:	bb 01 00 00 00       	mov    $0x1,%ebx
  80275d:	e9 2a ff ff ff       	jmp    80268c <__udivdi3+0x4c>
  802762:	66 90                	xchg   %ax,%ax
  802764:	66 90                	xchg   %ax,%ax
  802766:	66 90                	xchg   %ax,%ax
  802768:	66 90                	xchg   %ax,%ax
  80276a:	66 90                	xchg   %ax,%ax
  80276c:	66 90                	xchg   %ax,%ax
  80276e:	66 90                	xchg   %ax,%ax

00802770 <__umoddi3>:
  802770:	55                   	push   %ebp
  802771:	57                   	push   %edi
  802772:	56                   	push   %esi
  802773:	53                   	push   %ebx
  802774:	83 ec 1c             	sub    $0x1c,%esp
  802777:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80277b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80277f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802783:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802787:	85 d2                	test   %edx,%edx
  802789:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80278d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802791:	89 f3                	mov    %esi,%ebx
  802793:	89 3c 24             	mov    %edi,(%esp)
  802796:	89 74 24 04          	mov    %esi,0x4(%esp)
  80279a:	75 1c                	jne    8027b8 <__umoddi3+0x48>
  80279c:	39 f7                	cmp    %esi,%edi
  80279e:	76 50                	jbe    8027f0 <__umoddi3+0x80>
  8027a0:	89 c8                	mov    %ecx,%eax
  8027a2:	89 f2                	mov    %esi,%edx
  8027a4:	f7 f7                	div    %edi
  8027a6:	89 d0                	mov    %edx,%eax
  8027a8:	31 d2                	xor    %edx,%edx
  8027aa:	83 c4 1c             	add    $0x1c,%esp
  8027ad:	5b                   	pop    %ebx
  8027ae:	5e                   	pop    %esi
  8027af:	5f                   	pop    %edi
  8027b0:	5d                   	pop    %ebp
  8027b1:	c3                   	ret    
  8027b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027b8:	39 f2                	cmp    %esi,%edx
  8027ba:	89 d0                	mov    %edx,%eax
  8027bc:	77 52                	ja     802810 <__umoddi3+0xa0>
  8027be:	0f bd ea             	bsr    %edx,%ebp
  8027c1:	83 f5 1f             	xor    $0x1f,%ebp
  8027c4:	75 5a                	jne    802820 <__umoddi3+0xb0>
  8027c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8027ca:	0f 82 e0 00 00 00    	jb     8028b0 <__umoddi3+0x140>
  8027d0:	39 0c 24             	cmp    %ecx,(%esp)
  8027d3:	0f 86 d7 00 00 00    	jbe    8028b0 <__umoddi3+0x140>
  8027d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8027e1:	83 c4 1c             	add    $0x1c,%esp
  8027e4:	5b                   	pop    %ebx
  8027e5:	5e                   	pop    %esi
  8027e6:	5f                   	pop    %edi
  8027e7:	5d                   	pop    %ebp
  8027e8:	c3                   	ret    
  8027e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027f0:	85 ff                	test   %edi,%edi
  8027f2:	89 fd                	mov    %edi,%ebp
  8027f4:	75 0b                	jne    802801 <__umoddi3+0x91>
  8027f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027fb:	31 d2                	xor    %edx,%edx
  8027fd:	f7 f7                	div    %edi
  8027ff:	89 c5                	mov    %eax,%ebp
  802801:	89 f0                	mov    %esi,%eax
  802803:	31 d2                	xor    %edx,%edx
  802805:	f7 f5                	div    %ebp
  802807:	89 c8                	mov    %ecx,%eax
  802809:	f7 f5                	div    %ebp
  80280b:	89 d0                	mov    %edx,%eax
  80280d:	eb 99                	jmp    8027a8 <__umoddi3+0x38>
  80280f:	90                   	nop
  802810:	89 c8                	mov    %ecx,%eax
  802812:	89 f2                	mov    %esi,%edx
  802814:	83 c4 1c             	add    $0x1c,%esp
  802817:	5b                   	pop    %ebx
  802818:	5e                   	pop    %esi
  802819:	5f                   	pop    %edi
  80281a:	5d                   	pop    %ebp
  80281b:	c3                   	ret    
  80281c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802820:	8b 34 24             	mov    (%esp),%esi
  802823:	bf 20 00 00 00       	mov    $0x20,%edi
  802828:	89 e9                	mov    %ebp,%ecx
  80282a:	29 ef                	sub    %ebp,%edi
  80282c:	d3 e0                	shl    %cl,%eax
  80282e:	89 f9                	mov    %edi,%ecx
  802830:	89 f2                	mov    %esi,%edx
  802832:	d3 ea                	shr    %cl,%edx
  802834:	89 e9                	mov    %ebp,%ecx
  802836:	09 c2                	or     %eax,%edx
  802838:	89 d8                	mov    %ebx,%eax
  80283a:	89 14 24             	mov    %edx,(%esp)
  80283d:	89 f2                	mov    %esi,%edx
  80283f:	d3 e2                	shl    %cl,%edx
  802841:	89 f9                	mov    %edi,%ecx
  802843:	89 54 24 04          	mov    %edx,0x4(%esp)
  802847:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80284b:	d3 e8                	shr    %cl,%eax
  80284d:	89 e9                	mov    %ebp,%ecx
  80284f:	89 c6                	mov    %eax,%esi
  802851:	d3 e3                	shl    %cl,%ebx
  802853:	89 f9                	mov    %edi,%ecx
  802855:	89 d0                	mov    %edx,%eax
  802857:	d3 e8                	shr    %cl,%eax
  802859:	89 e9                	mov    %ebp,%ecx
  80285b:	09 d8                	or     %ebx,%eax
  80285d:	89 d3                	mov    %edx,%ebx
  80285f:	89 f2                	mov    %esi,%edx
  802861:	f7 34 24             	divl   (%esp)
  802864:	89 d6                	mov    %edx,%esi
  802866:	d3 e3                	shl    %cl,%ebx
  802868:	f7 64 24 04          	mull   0x4(%esp)
  80286c:	39 d6                	cmp    %edx,%esi
  80286e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802872:	89 d1                	mov    %edx,%ecx
  802874:	89 c3                	mov    %eax,%ebx
  802876:	72 08                	jb     802880 <__umoddi3+0x110>
  802878:	75 11                	jne    80288b <__umoddi3+0x11b>
  80287a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80287e:	73 0b                	jae    80288b <__umoddi3+0x11b>
  802880:	2b 44 24 04          	sub    0x4(%esp),%eax
  802884:	1b 14 24             	sbb    (%esp),%edx
  802887:	89 d1                	mov    %edx,%ecx
  802889:	89 c3                	mov    %eax,%ebx
  80288b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80288f:	29 da                	sub    %ebx,%edx
  802891:	19 ce                	sbb    %ecx,%esi
  802893:	89 f9                	mov    %edi,%ecx
  802895:	89 f0                	mov    %esi,%eax
  802897:	d3 e0                	shl    %cl,%eax
  802899:	89 e9                	mov    %ebp,%ecx
  80289b:	d3 ea                	shr    %cl,%edx
  80289d:	89 e9                	mov    %ebp,%ecx
  80289f:	d3 ee                	shr    %cl,%esi
  8028a1:	09 d0                	or     %edx,%eax
  8028a3:	89 f2                	mov    %esi,%edx
  8028a5:	83 c4 1c             	add    $0x1c,%esp
  8028a8:	5b                   	pop    %ebx
  8028a9:	5e                   	pop    %esi
  8028aa:	5f                   	pop    %edi
  8028ab:	5d                   	pop    %ebp
  8028ac:	c3                   	ret    
  8028ad:	8d 76 00             	lea    0x0(%esi),%esi
  8028b0:	29 f9                	sub    %edi,%ecx
  8028b2:	19 d6                	sbb    %edx,%esi
  8028b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028bc:	e9 18 ff ff ff       	jmp    8027d9 <__umoddi3+0x69>
