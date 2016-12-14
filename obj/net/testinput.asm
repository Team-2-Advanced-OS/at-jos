
obj/net/testinput:     file format elf32-i386


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
  80002c:	e8 01 08 00 00       	call   800832 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 7c             	sub    $0x7c,%esp
	envid_t ns_envid = sys_getenvid();
  80003c:	e8 74 12 00 00       	call   8012b5 <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx
	int i, r, first = 1;

	binaryname = "testinput";
  800043:	c7 05 00 40 80 00 40 	movl   $0x802e40,0x804000
  80004a:	2e 80 00 

	output_envid = fork();
  80004d:	e8 4c 16 00 00       	call   80169e <fork>
  800052:	a3 04 50 80 00       	mov    %eax,0x805004
	if (output_envid < 0)
  800057:	85 c0                	test   %eax,%eax
  800059:	79 14                	jns    80006f <umain+0x3c>
		panic("error forking");
  80005b:	83 ec 04             	sub    $0x4,%esp
  80005e:	68 4a 2e 80 00       	push   $0x802e4a
  800063:	6a 4d                	push   $0x4d
  800065:	68 58 2e 80 00       	push   $0x802e58
  80006a:	e8 23 08 00 00       	call   800892 <_panic>
	else if (output_envid == 0) {
  80006f:	85 c0                	test   %eax,%eax
  800071:	75 11                	jne    800084 <umain+0x51>
		output(ns_envid);
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	53                   	push   %ebx
  800077:	e8 56 04 00 00       	call   8004d2 <output>
		return;
  80007c:	83 c4 10             	add    $0x10,%esp
  80007f:	e9 0b 03 00 00       	jmp    80038f <umain+0x35c>
	}

	input_envid = fork();
  800084:	e8 15 16 00 00       	call   80169e <fork>
  800089:	a3 00 50 80 00       	mov    %eax,0x805000
	if (input_envid < 0)
  80008e:	85 c0                	test   %eax,%eax
  800090:	79 14                	jns    8000a6 <umain+0x73>
		panic("error forking");
  800092:	83 ec 04             	sub    $0x4,%esp
  800095:	68 4a 2e 80 00       	push   $0x802e4a
  80009a:	6a 55                	push   $0x55
  80009c:	68 58 2e 80 00       	push   $0x802e58
  8000a1:	e8 ec 07 00 00       	call   800892 <_panic>
	else if (input_envid == 0) {
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 11                	jne    8000bb <umain+0x88>
		input(ns_envid);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	53                   	push   %ebx
  8000ae:	e8 77 03 00 00       	call   80042a <input>
		return;
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	e9 d4 02 00 00       	jmp    80038f <umain+0x35c>
	}

	cprintf("Sending ARP announcement...\n");
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 68 2e 80 00       	push   $0x802e68
  8000c3:	e8 a3 08 00 00       	call   80096b <cprintf>
	// with ARP requests.  Ideally, we would use gratuitous ARP
	// for this, but QEMU's ARP implementation is dumb and only
	// listens for very specific ARP requests, such as requests
	// for the gateway IP.

	uint8_t mac[6] = {0x52, 0x54, 0x00, 0x12, 0x34, 0x56};
  8000c8:	c6 45 98 52          	movb   $0x52,-0x68(%ebp)
  8000cc:	c6 45 99 54          	movb   $0x54,-0x67(%ebp)
  8000d0:	c6 45 9a 00          	movb   $0x0,-0x66(%ebp)
  8000d4:	c6 45 9b 12          	movb   $0x12,-0x65(%ebp)
  8000d8:	c6 45 9c 34          	movb   $0x34,-0x64(%ebp)
  8000dc:	c6 45 9d 56          	movb   $0x56,-0x63(%ebp)
	uint32_t myip = inet_addr(IP);
  8000e0:	c7 04 24 85 2e 80 00 	movl   $0x802e85,(%esp)
  8000e7:	e8 14 07 00 00       	call   800800 <inet_addr>
  8000ec:	89 45 90             	mov    %eax,-0x70(%ebp)
	uint32_t gwip = inet_addr(DEFAULT);
  8000ef:	c7 04 24 8f 2e 80 00 	movl   $0x802e8f,(%esp)
  8000f6:	e8 05 07 00 00       	call   800800 <inet_addr>
  8000fb:	89 45 94             	mov    %eax,-0x6c(%ebp)
	int r;

	if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  8000fe:	83 c4 0c             	add    $0xc,%esp
  800101:	6a 07                	push   $0x7
  800103:	68 00 b0 fe 0f       	push   $0xffeb000
  800108:	6a 00                	push   $0x0
  80010a:	e8 e4 11 00 00       	call   8012f3 <sys_page_alloc>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	85 c0                	test   %eax,%eax
  800114:	79 12                	jns    800128 <umain+0xf5>
		panic("sys_page_map: %e", r);
  800116:	50                   	push   %eax
  800117:	68 98 2e 80 00       	push   $0x802e98
  80011c:	6a 19                	push   $0x19
  80011e:	68 58 2e 80 00       	push   $0x802e58
  800123:	e8 6a 07 00 00       	call   800892 <_panic>

	struct etharp_hdr *arp = (struct etharp_hdr*)pkt->jp_data;
	pkt->jp_len = sizeof(*arp);
  800128:	c7 05 00 b0 fe 0f 2a 	movl   $0x2a,0xffeb000
  80012f:	00 00 00 

	memset(arp->ethhdr.dest.addr, 0xff, ETHARP_HWADDR_LEN);
  800132:	83 ec 04             	sub    $0x4,%esp
  800135:	6a 06                	push   $0x6
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	68 04 b0 fe 0f       	push   $0xffeb004
  800141:	e8 ef 0e 00 00       	call   801035 <memset>
	memcpy(arp->ethhdr.src.addr,  mac,  ETHARP_HWADDR_LEN);
  800146:	83 c4 0c             	add    $0xc,%esp
  800149:	6a 06                	push   $0x6
  80014b:	8d 5d 98             	lea    -0x68(%ebp),%ebx
  80014e:	53                   	push   %ebx
  80014f:	68 0a b0 fe 0f       	push   $0xffeb00a
  800154:	e8 91 0f 00 00       	call   8010ea <memcpy>
	arp->ethhdr.type = htons(ETHTYPE_ARP);
  800159:	c7 04 24 06 08 00 00 	movl   $0x806,(%esp)
  800160:	e8 82 04 00 00       	call   8005e7 <htons>
  800165:	66 a3 10 b0 fe 0f    	mov    %ax,0xffeb010
	arp->hwtype = htons(1); // Ethernet
  80016b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800172:	e8 70 04 00 00       	call   8005e7 <htons>
  800177:	66 a3 12 b0 fe 0f    	mov    %ax,0xffeb012
	arp->proto = htons(ETHTYPE_IP);
  80017d:	c7 04 24 00 08 00 00 	movl   $0x800,(%esp)
  800184:	e8 5e 04 00 00       	call   8005e7 <htons>
  800189:	66 a3 14 b0 fe 0f    	mov    %ax,0xffeb014
	arp->_hwlen_protolen = htons((ETHARP_HWADDR_LEN << 8) | 4);
  80018f:	c7 04 24 04 06 00 00 	movl   $0x604,(%esp)
  800196:	e8 4c 04 00 00       	call   8005e7 <htons>
  80019b:	66 a3 16 b0 fe 0f    	mov    %ax,0xffeb016
	arp->opcode = htons(ARP_REQUEST);
  8001a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001a8:	e8 3a 04 00 00       	call   8005e7 <htons>
  8001ad:	66 a3 18 b0 fe 0f    	mov    %ax,0xffeb018
	memcpy(arp->shwaddr.addr,  mac,   ETHARP_HWADDR_LEN);
  8001b3:	83 c4 0c             	add    $0xc,%esp
  8001b6:	6a 06                	push   $0x6
  8001b8:	53                   	push   %ebx
  8001b9:	68 1a b0 fe 0f       	push   $0xffeb01a
  8001be:	e8 27 0f 00 00       	call   8010ea <memcpy>
	memcpy(arp->sipaddr.addrw, &myip, 4);
  8001c3:	83 c4 0c             	add    $0xc,%esp
  8001c6:	6a 04                	push   $0x4
  8001c8:	8d 45 90             	lea    -0x70(%ebp),%eax
  8001cb:	50                   	push   %eax
  8001cc:	68 20 b0 fe 0f       	push   $0xffeb020
  8001d1:	e8 14 0f 00 00       	call   8010ea <memcpy>
	memset(arp->dhwaddr.addr,  0x00,  ETHARP_HWADDR_LEN);
  8001d6:	83 c4 0c             	add    $0xc,%esp
  8001d9:	6a 06                	push   $0x6
  8001db:	6a 00                	push   $0x0
  8001dd:	68 24 b0 fe 0f       	push   $0xffeb024
  8001e2:	e8 4e 0e 00 00       	call   801035 <memset>
	memcpy(arp->dipaddr.addrw, &gwip, 4);
  8001e7:	83 c4 0c             	add    $0xc,%esp
  8001ea:	6a 04                	push   $0x4
  8001ec:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	68 2a b0 fe 0f       	push   $0xffeb02a
  8001f5:	e8 f0 0e 00 00       	call   8010ea <memcpy>

	ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8001fa:	6a 07                	push   $0x7
  8001fc:	68 00 b0 fe 0f       	push   $0xffeb000
  800201:	6a 0b                	push   $0xb
  800203:	ff 35 04 50 80 00    	pushl  0x805004
  800209:	e8 d8 16 00 00       	call   8018e6 <ipc_send>
	sys_page_unmap(0, pkt);
  80020e:	83 c4 18             	add    $0x18,%esp
  800211:	68 00 b0 fe 0f       	push   $0xffeb000
  800216:	6a 00                	push   $0x0
  800218:	e8 5b 11 00 00       	call   801378 <sys_page_unmap>
  80021d:	83 c4 10             	add    $0x10,%esp

void
umain(int argc, char **argv)
{
	envid_t ns_envid = sys_getenvid();
	int i, r, first = 1;
  800220:	c7 85 7c ff ff ff 01 	movl   $0x1,-0x84(%ebp)
  800227:	00 00 00 

	while (1) {
		envid_t whom;
		int perm;

		int32_t req = ipc_recv((int32_t *)&whom, pkt, &perm);
  80022a:	83 ec 04             	sub    $0x4,%esp
  80022d:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800230:	50                   	push   %eax
  800231:	68 00 b0 fe 0f       	push   $0xffeb000
  800236:	8d 45 90             	lea    -0x70(%ebp),%eax
  800239:	50                   	push   %eax
  80023a:	e8 3e 16 00 00       	call   80187d <ipc_recv>
		if (req < 0)
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	85 c0                	test   %eax,%eax
  800244:	79 12                	jns    800258 <umain+0x225>
			panic("ipc_recv: %e", req);
  800246:	50                   	push   %eax
  800247:	68 a9 2e 80 00       	push   $0x802ea9
  80024c:	6a 64                	push   $0x64
  80024e:	68 58 2e 80 00       	push   $0x802e58
  800253:	e8 3a 06 00 00       	call   800892 <_panic>
		if (whom != input_envid)
  800258:	8b 55 90             	mov    -0x70(%ebp),%edx
  80025b:	3b 15 00 50 80 00    	cmp    0x805000,%edx
  800261:	74 12                	je     800275 <umain+0x242>
			panic("IPC from unexpected environment %08x", whom);
  800263:	52                   	push   %edx
  800264:	68 00 2f 80 00       	push   $0x802f00
  800269:	6a 66                	push   $0x66
  80026b:	68 58 2e 80 00       	push   $0x802e58
  800270:	e8 1d 06 00 00       	call   800892 <_panic>
		if (req != NSREQ_INPUT)
  800275:	83 f8 0a             	cmp    $0xa,%eax
  800278:	74 12                	je     80028c <umain+0x259>
			panic("Unexpected IPC %d", req);
  80027a:	50                   	push   %eax
  80027b:	68 b6 2e 80 00       	push   $0x802eb6
  800280:	6a 68                	push   $0x68
  800282:	68 58 2e 80 00       	push   $0x802e58
  800287:	e8 06 06 00 00       	call   800892 <_panic>

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
  80028c:	a1 00 b0 fe 0f       	mov    0xffeb000,%eax
  800291:	89 45 84             	mov    %eax,-0x7c(%ebp)
hexdump(const char *prefix, const void *data, int len)
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
  800294:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < len; i++) {
  800299:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i % 16 == 0)
			out = buf + snprintf(buf, end - buf,
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
		if (i % 16 == 15 || i == len - 1)
  80029e:	83 e8 01             	sub    $0x1,%eax
  8002a1:	89 45 80             	mov    %eax,-0x80(%ebp)
  8002a4:	e9 a5 00 00 00       	jmp    80034e <umain+0x31b>
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
		if (i % 16 == 0)
  8002a9:	89 df                	mov    %ebx,%edi
  8002ab:	f6 c3 0f             	test   $0xf,%bl
  8002ae:	75 22                	jne    8002d2 <umain+0x29f>
			out = buf + snprintf(buf, end - buf,
  8002b0:	83 ec 0c             	sub    $0xc,%esp
  8002b3:	53                   	push   %ebx
  8002b4:	68 c8 2e 80 00       	push   $0x802ec8
  8002b9:	68 d0 2e 80 00       	push   $0x802ed0
  8002be:	6a 50                	push   $0x50
  8002c0:	8d 45 98             	lea    -0x68(%ebp),%eax
  8002c3:	50                   	push   %eax
  8002c4:	e8 d4 0b 00 00       	call   800e9d <snprintf>
  8002c9:	8d 4d 98             	lea    -0x68(%ebp),%ecx
  8002cc:	8d 34 01             	lea    (%ecx,%eax,1),%esi
  8002cf:	83 c4 20             	add    $0x20,%esp
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
  8002d2:	b8 04 b0 fe 0f       	mov    $0xffeb004,%eax
  8002d7:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
  8002db:	50                   	push   %eax
  8002dc:	68 da 2e 80 00       	push   $0x802eda
  8002e1:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8002e4:	29 f0                	sub    %esi,%eax
  8002e6:	50                   	push   %eax
  8002e7:	56                   	push   %esi
  8002e8:	e8 b0 0b 00 00       	call   800e9d <snprintf>
  8002ed:	01 c6                	add    %eax,%esi
		if (i % 16 == 15 || i == len - 1)
  8002ef:	89 d8                	mov    %ebx,%eax
  8002f1:	c1 f8 1f             	sar    $0x1f,%eax
  8002f4:	c1 e8 1c             	shr    $0x1c,%eax
  8002f7:	8d 3c 03             	lea    (%ebx,%eax,1),%edi
  8002fa:	83 e7 0f             	and    $0xf,%edi
  8002fd:	29 c7                	sub    %eax,%edi
  8002ff:	83 c4 10             	add    $0x10,%esp
  800302:	83 ff 0f             	cmp    $0xf,%edi
  800305:	74 05                	je     80030c <umain+0x2d9>
  800307:	3b 5d 80             	cmp    -0x80(%ebp),%ebx
  80030a:	75 1c                	jne    800328 <umain+0x2f5>
			cprintf("%.*s\n", out - buf, buf);
  80030c:	83 ec 04             	sub    $0x4,%esp
  80030f:	8d 45 98             	lea    -0x68(%ebp),%eax
  800312:	50                   	push   %eax
  800313:	89 f0                	mov    %esi,%eax
  800315:	8d 4d 98             	lea    -0x68(%ebp),%ecx
  800318:	29 c8                	sub    %ecx,%eax
  80031a:	50                   	push   %eax
  80031b:	68 df 2e 80 00       	push   $0x802edf
  800320:	e8 46 06 00 00       	call   80096b <cprintf>
  800325:	83 c4 10             	add    $0x10,%esp
		if (i % 2 == 1)
  800328:	89 da                	mov    %ebx,%edx
  80032a:	c1 ea 1f             	shr    $0x1f,%edx
  80032d:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800330:	83 e0 01             	and    $0x1,%eax
  800333:	29 d0                	sub    %edx,%eax
  800335:	83 f8 01             	cmp    $0x1,%eax
  800338:	75 06                	jne    800340 <umain+0x30d>
			*(out++) = ' ';
  80033a:	c6 06 20             	movb   $0x20,(%esi)
  80033d:	8d 76 01             	lea    0x1(%esi),%esi
		if (i % 16 == 7)
  800340:	83 ff 07             	cmp    $0x7,%edi
  800343:	75 06                	jne    80034b <umain+0x318>
			*(out++) = ' ';
  800345:	c6 06 20             	movb   $0x20,(%esi)
  800348:	8d 76 01             	lea    0x1(%esi),%esi
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
  80034b:	83 c3 01             	add    $0x1,%ebx
  80034e:	3b 5d 84             	cmp    -0x7c(%ebp),%ebx
  800351:	0f 8c 52 ff ff ff    	jl     8002a9 <umain+0x276>
			panic("IPC from unexpected environment %08x", whom);
		if (req != NSREQ_INPUT)
			panic("Unexpected IPC %d", req);

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
		cprintf("\n");
  800357:	83 ec 0c             	sub    $0xc,%esp
  80035a:	68 a3 2f 80 00       	push   $0x802fa3
  80035f:	e8 07 06 00 00       	call   80096b <cprintf>

		// Only indicate that we're waiting for packets once
		// we've received the ARP reply
		if (first)
  800364:	83 c4 10             	add    $0x10,%esp
  800367:	83 bd 7c ff ff ff 00 	cmpl   $0x0,-0x84(%ebp)
  80036e:	74 10                	je     800380 <umain+0x34d>
			cprintf("Waiting for packets...\n");
  800370:	83 ec 0c             	sub    $0xc,%esp
  800373:	68 e5 2e 80 00       	push   $0x802ee5
  800378:	e8 ee 05 00 00       	call   80096b <cprintf>
  80037d:	83 c4 10             	add    $0x10,%esp
		first = 0;
  800380:	c7 85 7c ff ff ff 00 	movl   $0x0,-0x84(%ebp)
  800387:	00 00 00 
	}
  80038a:	e9 9b fe ff ff       	jmp    80022a <umain+0x1f7>
}
  80038f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800392:	5b                   	pop    %ebx
  800393:	5e                   	pop    %esi
  800394:	5f                   	pop    %edi
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	57                   	push   %edi
  80039b:	56                   	push   %esi
  80039c:	53                   	push   %ebx
  80039d:	83 ec 1c             	sub    $0x1c,%esp
  8003a0:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  8003a3:	e8 3c 11 00 00       	call   8014e4 <sys_time_msec>
  8003a8:	03 45 0c             	add    0xc(%ebp),%eax
  8003ab:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  8003ad:	c7 05 00 40 80 00 25 	movl   $0x802f25,0x804000
  8003b4:	2f 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8003b7:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8003ba:	eb 05                	jmp    8003c1 <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  8003bc:	e8 13 0f 00 00       	call   8012d4 <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  8003c1:	e8 1e 11 00 00       	call   8014e4 <sys_time_msec>
  8003c6:	89 c2                	mov    %eax,%edx
  8003c8:	85 c0                	test   %eax,%eax
  8003ca:	78 04                	js     8003d0 <timer+0x39>
  8003cc:	39 c3                	cmp    %eax,%ebx
  8003ce:	77 ec                	ja     8003bc <timer+0x25>
			sys_yield();
		}
		if (r < 0)
  8003d0:	85 c0                	test   %eax,%eax
  8003d2:	79 12                	jns    8003e6 <timer+0x4f>
			panic("sys_time_msec: %e", r);
  8003d4:	52                   	push   %edx
  8003d5:	68 2e 2f 80 00       	push   $0x802f2e
  8003da:	6a 0f                	push   $0xf
  8003dc:	68 40 2f 80 00       	push   $0x802f40
  8003e1:	e8 ac 04 00 00       	call   800892 <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8003e6:	6a 00                	push   $0x0
  8003e8:	6a 00                	push   $0x0
  8003ea:	6a 0c                	push   $0xc
  8003ec:	56                   	push   %esi
  8003ed:	e8 f4 14 00 00       	call   8018e6 <ipc_send>
  8003f2:	83 c4 10             	add    $0x10,%esp

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8003f5:	83 ec 04             	sub    $0x4,%esp
  8003f8:	6a 00                	push   $0x0
  8003fa:	6a 00                	push   $0x0
  8003fc:	57                   	push   %edi
  8003fd:	e8 7b 14 00 00       	call   80187d <ipc_recv>
  800402:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  800404:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800407:	83 c4 10             	add    $0x10,%esp
  80040a:	39 f0                	cmp    %esi,%eax
  80040c:	74 13                	je     800421 <timer+0x8a>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  80040e:	83 ec 08             	sub    $0x8,%esp
  800411:	50                   	push   %eax
  800412:	68 4c 2f 80 00       	push   $0x802f4c
  800417:	e8 4f 05 00 00       	call   80096b <cprintf>
				continue;
  80041c:	83 c4 10             	add    $0x10,%esp
  80041f:	eb d4                	jmp    8003f5 <timer+0x5e>
			}

			stop = sys_time_msec() + to;
  800421:	e8 be 10 00 00       	call   8014e4 <sys_time_msec>
  800426:	01 c3                	add    %eax,%ebx
  800428:	eb 97                	jmp    8003c1 <timer+0x2a>

0080042a <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	57                   	push   %edi
  80042e:	56                   	push   %esi
  80042f:	53                   	push   %ebx
  800430:	83 ec 48             	sub    $0x48,%esp
	binaryname = "ns_input";
  800433:	c7 05 00 40 80 00 87 	movl   $0x802f87,0x804000
  80043a:	2f 80 00 
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
	cprintf("NS INPUT ENV is on!\n");
  80043d:	68 90 2f 80 00       	push   $0x802f90
  800442:	e8 24 05 00 00       	call   80096b <cprintf>
  800447:	83 c4 10             	add    $0x10,%esp

	// Allocate some pages to receive page
	char *bufs[10];
	char *va = (char *) 0x0ffff000;
	int i;
	for (i = 0; i < 10; i++) {
  80044a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80044f:	8d b3 ff ff 00 00    	lea    0xffff(%ebx),%esi
  800455:	c1 e6 0c             	shl    $0xc,%esi
		sys_page_alloc(0, va, PTE_P | PTE_U | PTE_W);
  800458:	83 ec 04             	sub    $0x4,%esp
  80045b:	6a 07                	push   $0x7
  80045d:	56                   	push   %esi
  80045e:	6a 00                	push   $0x0
  800460:	e8 8e 0e 00 00       	call   8012f3 <sys_page_alloc>
		bufs[i] = va;
  800465:	89 74 9d c0          	mov    %esi,-0x40(%ebp,%ebx,4)

	// Allocate some pages to receive page
	char *bufs[10];
	char *va = (char *) 0x0ffff000;
	int i;
	for (i = 0; i < 10; i++) {
  800469:	83 c3 01             	add    $0x1,%ebx
  80046c:	83 c4 10             	add    $0x10,%esp
  80046f:	83 fb 0a             	cmp    $0xa,%ebx
  800472:	75 db                	jne    80044f <input+0x25>
  800474:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(1) {
		// Build request
		union Nsipc *nsipc = (union Nsipc *) bufs[current_buffer];
		char *packet_buf = (nsipc->pkt).jp_data;
		size_t size = -1; // Could pass the jp_len instead
		sys_receive_packet(packet_buf, &size);
  800479:	8d 7d bc             	lea    -0x44(%ebp),%edi
	// Infinity loop trying to receive packets and, if received, send it
	// to the network server
	int current_buffer = 0;
	while(1) {
		// Build request
		union Nsipc *nsipc = (union Nsipc *) bufs[current_buffer];
  80047c:	8b 74 9d c0          	mov    -0x40(%ebp,%ebx,4),%esi
		char *packet_buf = (nsipc->pkt).jp_data;
		size_t size = -1; // Could pass the jp_len instead
  800480:	c7 45 bc ff ff ff ff 	movl   $0xffffffff,-0x44(%ebp)
		sys_receive_packet(packet_buf, &size);
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	57                   	push   %edi
	// to the network server
	int current_buffer = 0;
	while(1) {
		// Build request
		union Nsipc *nsipc = (union Nsipc *) bufs[current_buffer];
		char *packet_buf = (nsipc->pkt).jp_data;
  80048b:	8d 46 04             	lea    0x4(%esi),%eax
		size_t size = -1; // Could pass the jp_len instead
		sys_receive_packet(packet_buf, &size);
  80048e:	50                   	push   %eax
  80048f:	e8 b1 10 00 00       	call   801545 <sys_receive_packet>

		// If it receives a packet, the size won't be -1 anymore
		if (size != -1) {
  800494:	8b 45 bc             	mov    -0x44(%ebp),%eax
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	83 f8 ff             	cmp    $0xffffffff,%eax
  80049d:	74 dd                	je     80047c <input+0x52>
			

			// Store the correct size
			(nsipc->pkt).jp_len = size;
  80049f:	89 06                	mov    %eax,(%esi)

			// Request is built, now send it
			ipc_send(nsenv, NSREQ_INPUT, nsipc, PTE_P|PTE_W|PTE_U);
  8004a1:	6a 07                	push   $0x7
  8004a3:	56                   	push   %esi
  8004a4:	6a 0a                	push   $0xa
  8004a6:	68 01 10 00 00       	push   $0x1001
  8004ab:	e8 36 14 00 00       	call   8018e6 <ipc_send>

			// Let the current buffer rest for a while. Go to next.
			current_buffer = (current_buffer + 1)%10;
  8004b0:	8d 4b 01             	lea    0x1(%ebx),%ecx
  8004b3:	b8 67 66 66 66       	mov    $0x66666667,%eax
  8004b8:	f7 e9                	imul   %ecx
  8004ba:	c1 fa 02             	sar    $0x2,%edx
  8004bd:	89 c8                	mov    %ecx,%eax
  8004bf:	c1 f8 1f             	sar    $0x1f,%eax
  8004c2:	29 c2                	sub    %eax,%edx
  8004c4:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8004c7:	01 c0                	add    %eax,%eax
  8004c9:	29 c1                	sub    %eax,%ecx
  8004cb:	89 cb                	mov    %ecx,%ebx
  8004cd:	83 c4 10             	add    $0x10,%esp
		}
	}
  8004d0:	eb aa                	jmp    80047c <input+0x52>

008004d2 <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	56                   	push   %esi
  8004d6:	53                   	push   %ebx
  8004d7:	83 ec 1c             	sub    $0x1c,%esp
	binaryname = "ns_output";
  8004da:	c7 05 00 40 80 00 a5 	movl   $0x802fa5,0x804000
  8004e1:	2f 80 00 

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
	cprintf("NS OUTPUT ENV is on!\n");
  8004e4:	68 af 2f 80 00       	push   $0x802faf
  8004e9:	e8 7d 04 00 00       	call   80096b <cprintf>
  8004ee:	83 c4 10             	add    $0x10,%esp
	
	union Nsipc *nsipc = (union Nsipc *)0x0ffff000;
	envid_t whom; 	int perm;     
	// Endless loop s
	while (1) {
		uint32_t req = ipc_recv(&whom, nsipc, &perm);
  8004f1:	8d 75 f0             	lea    -0x10(%ebp),%esi
  8004f4:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8004f7:	83 ec 04             	sub    $0x4,%esp
  8004fa:	56                   	push   %esi
  8004fb:	68 00 f0 ff 0f       	push   $0xffff000
  800500:	53                   	push   %ebx
  800501:	e8 77 13 00 00       	call   80187d <ipc_recv>

		// Check if the request is of the expected type
		if (req == NSREQ_OUTPUT) {
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	83 f8 0b             	cmp    $0xb,%eax
  80050c:	75 2c                	jne    80053a <output+0x68>
			char *buf = (nsipc->pkt).jp_data;

			
			// Transmit the packet
			int r;
			if ((r = sys_transmit_packet(buf, size)) < 0)
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	ff 35 00 f0 ff 0f    	pushl  0xffff000
  800517:	68 04 f0 ff 0f       	push   $0xffff004
  80051c:	e8 e2 0f 00 00       	call   801503 <sys_transmit_packet>
  800521:	83 c4 10             	add    $0x10,%esp
  800524:	85 c0                	test   %eax,%eax
  800526:	79 cf                	jns    8004f7 <output+0x25>
				panic("sys_transmit_packet: %e", r);
  800528:	50                   	push   %eax
  800529:	68 c5 2f 80 00       	push   $0x802fc5
  80052e:	6a 21                	push   $0x21
  800530:	68 dd 2f 80 00       	push   $0x802fdd
  800535:	e8 58 03 00 00       	call   800892 <_panic>
		} else {
			panic("NS OUTPUT ENV: Invalid request received!");
  80053a:	83 ec 04             	sub    $0x4,%esp
  80053d:	68 ec 2f 80 00       	push   $0x802fec
  800542:	6a 23                	push   $0x23
  800544:	68 dd 2f 80 00       	push   $0x802fdd
  800549:	e8 44 03 00 00       	call   800892 <_panic>

0080054e <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  80054e:	55                   	push   %ebp
  80054f:	89 e5                	mov    %esp,%ebp
  800551:	57                   	push   %edi
  800552:	56                   	push   %esi
  800553:	53                   	push   %ebx
  800554:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800557:	8b 45 08             	mov    0x8(%ebp),%eax
  80055a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  80055d:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  800560:	c7 45 e0 08 50 80 00 	movl   $0x805008,-0x20(%ebp)
  800567:	0f b6 0f             	movzbl (%edi),%ecx
  80056a:	ba 00 00 00 00       	mov    $0x0,%edx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  80056f:	0f b6 d9             	movzbl %cl,%ebx
  800572:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800575:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
  800578:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80057b:	66 c1 e8 0b          	shr    $0xb,%ax
  80057f:	89 c3                	mov    %eax,%ebx
  800581:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800584:	01 c0                	add    %eax,%eax
  800586:	29 c1                	sub    %eax,%ecx
  800588:	89 c8                	mov    %ecx,%eax
      *ap /= (u8_t)10;
  80058a:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  80058c:	8d 72 01             	lea    0x1(%edx),%esi
  80058f:	0f b6 d2             	movzbl %dl,%edx
  800592:	83 c0 30             	add    $0x30,%eax
  800595:	88 44 15 ed          	mov    %al,-0x13(%ebp,%edx,1)
  800599:	89 f2                	mov    %esi,%edx
    } while(*ap);
  80059b:	84 db                	test   %bl,%bl
  80059d:	75 d0                	jne    80056f <inet_ntoa+0x21>
  80059f:	c6 07 00             	movb   $0x0,(%edi)
  8005a2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005a5:	eb 0d                	jmp    8005b4 <inet_ntoa+0x66>
    while(i--)
      *rp++ = inv[i];
  8005a7:	0f b6 c2             	movzbl %dl,%eax
  8005aa:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  8005af:	88 01                	mov    %al,(%ecx)
  8005b1:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  8005b4:	83 ea 01             	sub    $0x1,%edx
  8005b7:	80 fa ff             	cmp    $0xff,%dl
  8005ba:	75 eb                	jne    8005a7 <inet_ntoa+0x59>
  8005bc:	89 f0                	mov    %esi,%eax
  8005be:	0f b6 f0             	movzbl %al,%esi
  8005c1:	03 75 e0             	add    -0x20(%ebp),%esi
      *rp++ = inv[i];
    *rp++ = '.';
  8005c4:	8d 46 01             	lea    0x1(%esi),%eax
  8005c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ca:	c6 06 2e             	movb   $0x2e,(%esi)
    ap++;
  8005cd:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  8005d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005d3:	39 c7                	cmp    %eax,%edi
  8005d5:	75 90                	jne    800567 <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  8005d7:	c6 06 00             	movb   $0x0,(%esi)
  return str;
}
  8005da:	b8 08 50 80 00       	mov    $0x805008,%eax
  8005df:	83 c4 14             	add    $0x14,%esp
  8005e2:	5b                   	pop    %ebx
  8005e3:	5e                   	pop    %esi
  8005e4:	5f                   	pop    %edi
  8005e5:	5d                   	pop    %ebp
  8005e6:	c3                   	ret    

008005e7 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  8005e7:	55                   	push   %ebp
  8005e8:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  8005ea:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8005ee:	66 c1 c0 08          	rol    $0x8,%ax
}
  8005f2:	5d                   	pop    %ebp
  8005f3:	c3                   	ret    

008005f4 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  8005f4:	55                   	push   %ebp
  8005f5:	89 e5                	mov    %esp,%ebp
  return htons(n);
  8005f7:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8005fb:	66 c1 c0 08          	rol    $0x8,%ax
}
  8005ff:	5d                   	pop    %ebp
  800600:	c3                   	ret    

00800601 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  800601:	55                   	push   %ebp
  800602:	89 e5                	mov    %esp,%ebp
  800604:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  800607:	89 d1                	mov    %edx,%ecx
  800609:	c1 e1 18             	shl    $0x18,%ecx
  80060c:	89 d0                	mov    %edx,%eax
  80060e:	c1 e8 18             	shr    $0x18,%eax
  800611:	09 c8                	or     %ecx,%eax
  800613:	89 d1                	mov    %edx,%ecx
  800615:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  80061b:	c1 e1 08             	shl    $0x8,%ecx
  80061e:	09 c8                	or     %ecx,%eax
  800620:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  800626:	c1 ea 08             	shr    $0x8,%edx
  800629:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  80062b:	5d                   	pop    %ebp
  80062c:	c3                   	ret    

0080062d <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  80062d:	55                   	push   %ebp
  80062e:	89 e5                	mov    %esp,%ebp
  800630:	57                   	push   %edi
  800631:	56                   	push   %esi
  800632:	53                   	push   %ebx
  800633:	83 ec 20             	sub    $0x20,%esp
  800636:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  800639:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  80063c:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  80063f:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  800642:	0f b6 ca             	movzbl %dl,%ecx
  800645:	83 e9 30             	sub    $0x30,%ecx
  800648:	83 f9 09             	cmp    $0x9,%ecx
  80064b:	0f 87 94 01 00 00    	ja     8007e5 <inet_aton+0x1b8>
      return (0);
    val = 0;
    base = 10;
  800651:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
    if (c == '0') {
  800658:	83 fa 30             	cmp    $0x30,%edx
  80065b:	75 2b                	jne    800688 <inet_aton+0x5b>
      c = *++cp;
  80065d:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  800661:	89 d1                	mov    %edx,%ecx
  800663:	83 e1 df             	and    $0xffffffdf,%ecx
  800666:	80 f9 58             	cmp    $0x58,%cl
  800669:	74 0f                	je     80067a <inet_aton+0x4d>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  80066b:	83 c0 01             	add    $0x1,%eax
  80066e:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  800671:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  800678:	eb 0e                	jmp    800688 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  80067a:	0f be 50 02          	movsbl 0x2(%eax),%edx
  80067e:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  800681:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  800688:	83 c0 01             	add    $0x1,%eax
  80068b:	be 00 00 00 00       	mov    $0x0,%esi
  800690:	eb 03                	jmp    800695 <inet_aton+0x68>
  800692:	83 c0 01             	add    $0x1,%eax
  800695:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  800698:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80069b:	0f b6 fa             	movzbl %dl,%edi
  80069e:	8d 4f d0             	lea    -0x30(%edi),%ecx
  8006a1:	83 f9 09             	cmp    $0x9,%ecx
  8006a4:	77 0d                	ja     8006b3 <inet_aton+0x86>
        val = (val * base) + (int)(c - '0');
  8006a6:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  8006aa:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  8006ae:	0f be 10             	movsbl (%eax),%edx
  8006b1:	eb df                	jmp    800692 <inet_aton+0x65>
      } else if (base == 16 && isxdigit(c)) {
  8006b3:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  8006b7:	75 32                	jne    8006eb <inet_aton+0xbe>
  8006b9:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  8006bc:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8006bf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006c2:	81 e1 df 00 00 00    	and    $0xdf,%ecx
  8006c8:	83 e9 41             	sub    $0x41,%ecx
  8006cb:	83 f9 05             	cmp    $0x5,%ecx
  8006ce:	77 1b                	ja     8006eb <inet_aton+0xbe>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  8006d0:	c1 e6 04             	shl    $0x4,%esi
  8006d3:	83 c2 0a             	add    $0xa,%edx
  8006d6:	83 7d d8 1a          	cmpl   $0x1a,-0x28(%ebp)
  8006da:	19 c9                	sbb    %ecx,%ecx
  8006dc:	83 e1 20             	and    $0x20,%ecx
  8006df:	83 c1 41             	add    $0x41,%ecx
  8006e2:	29 ca                	sub    %ecx,%edx
  8006e4:	09 d6                	or     %edx,%esi
        c = *++cp;
  8006e6:	0f be 10             	movsbl (%eax),%edx
  8006e9:	eb a7                	jmp    800692 <inet_aton+0x65>
      } else
        break;
    }
    if (c == '.') {
  8006eb:	83 fa 2e             	cmp    $0x2e,%edx
  8006ee:	75 23                	jne    800713 <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  8006f0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006f3:	8d 7d f0             	lea    -0x10(%ebp),%edi
  8006f6:	39 f8                	cmp    %edi,%eax
  8006f8:	0f 84 ee 00 00 00    	je     8007ec <inet_aton+0x1bf>
        return (0);
      *pp++ = val;
  8006fe:	83 c0 04             	add    $0x4,%eax
  800701:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800704:	89 70 fc             	mov    %esi,-0x4(%eax)
      c = *++cp;
  800707:	8d 43 01             	lea    0x1(%ebx),%eax
  80070a:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  80070e:	e9 2f ff ff ff       	jmp    800642 <inet_aton+0x15>
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  800713:	85 d2                	test   %edx,%edx
  800715:	74 25                	je     80073c <inet_aton+0x10f>
  800717:	8d 4f e0             	lea    -0x20(%edi),%ecx
    return (0);
  80071a:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80071f:	83 f9 5f             	cmp    $0x5f,%ecx
  800722:	0f 87 d0 00 00 00    	ja     8007f8 <inet_aton+0x1cb>
  800728:	83 fa 20             	cmp    $0x20,%edx
  80072b:	74 0f                	je     80073c <inet_aton+0x10f>
  80072d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800730:	83 ea 09             	sub    $0x9,%edx
  800733:	83 fa 04             	cmp    $0x4,%edx
  800736:	0f 87 bc 00 00 00    	ja     8007f8 <inet_aton+0x1cb>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  80073c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80073f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800742:	29 c2                	sub    %eax,%edx
  800744:	c1 fa 02             	sar    $0x2,%edx
  800747:	83 c2 01             	add    $0x1,%edx
  80074a:	83 fa 02             	cmp    $0x2,%edx
  80074d:	74 20                	je     80076f <inet_aton+0x142>
  80074f:	83 fa 02             	cmp    $0x2,%edx
  800752:	7f 0f                	jg     800763 <inet_aton+0x136>

  case 0:
    return (0);       /* initial nondigit */
  800754:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  800759:	85 d2                	test   %edx,%edx
  80075b:	0f 84 97 00 00 00    	je     8007f8 <inet_aton+0x1cb>
  800761:	eb 67                	jmp    8007ca <inet_aton+0x19d>
  800763:	83 fa 03             	cmp    $0x3,%edx
  800766:	74 1e                	je     800786 <inet_aton+0x159>
  800768:	83 fa 04             	cmp    $0x4,%edx
  80076b:	74 38                	je     8007a5 <inet_aton+0x178>
  80076d:	eb 5b                	jmp    8007ca <inet_aton+0x19d>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  80076f:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  800774:	81 fe ff ff ff 00    	cmp    $0xffffff,%esi
  80077a:	77 7c                	ja     8007f8 <inet_aton+0x1cb>
      return (0);
    val |= parts[0] << 24;
  80077c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80077f:	c1 e0 18             	shl    $0x18,%eax
  800782:	09 c6                	or     %eax,%esi
    break;
  800784:	eb 44                	jmp    8007ca <inet_aton+0x19d>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  80078b:	81 fe ff ff 00 00    	cmp    $0xffff,%esi
  800791:	77 65                	ja     8007f8 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  800793:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800796:	c1 e2 18             	shl    $0x18,%edx
  800799:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80079c:	c1 e0 10             	shl    $0x10,%eax
  80079f:	09 d0                	or     %edx,%eax
  8007a1:	09 c6                	or     %eax,%esi
    break;
  8007a3:	eb 25                	jmp    8007ca <inet_aton+0x19d>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  8007a5:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  8007aa:	81 fe ff 00 00 00    	cmp    $0xff,%esi
  8007b0:	77 46                	ja     8007f8 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  8007b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007b5:	c1 e2 18             	shl    $0x18,%edx
  8007b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8007bb:	c1 e0 10             	shl    $0x10,%eax
  8007be:	09 c2                	or     %eax,%edx
  8007c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c3:	c1 e0 08             	shl    $0x8,%eax
  8007c6:	09 d0                	or     %edx,%eax
  8007c8:	09 c6                	or     %eax,%esi
    break;
  }
  if (addr)
  8007ca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007ce:	74 23                	je     8007f3 <inet_aton+0x1c6>
    addr->s_addr = htonl(val);
  8007d0:	56                   	push   %esi
  8007d1:	e8 2b fe ff ff       	call   800601 <htonl>
  8007d6:	83 c4 04             	add    $0x4,%esp
  8007d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007dc:	89 03                	mov    %eax,(%ebx)
  return (1);
  8007de:	b8 01 00 00 00       	mov    $0x1,%eax
  8007e3:	eb 13                	jmp    8007f8 <inet_aton+0x1cb>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  8007e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ea:	eb 0c                	jmp    8007f8 <inet_aton+0x1cb>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  8007ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f1:	eb 05                	jmp    8007f8 <inet_aton+0x1cb>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  8007f3:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8007f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007fb:	5b                   	pop    %ebx
  8007fc:	5e                   	pop    %esi
  8007fd:	5f                   	pop    %edi
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  800806:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800809:	50                   	push   %eax
  80080a:	ff 75 08             	pushl  0x8(%ebp)
  80080d:	e8 1b fe ff ff       	call   80062d <inet_aton>
  800812:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  800815:	85 c0                	test   %eax,%eax
  800817:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80081c:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  800820:	c9                   	leave  
  800821:	c3                   	ret    

00800822 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  800825:	ff 75 08             	pushl  0x8(%ebp)
  800828:	e8 d4 fd ff ff       	call   800601 <htonl>
  80082d:	83 c4 04             	add    $0x4,%esp
}
  800830:	c9                   	leave  
  800831:	c3                   	ret    

00800832 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	56                   	push   %esi
  800836:	53                   	push   %ebx
  800837:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80083a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80083d:	e8 73 0a 00 00       	call   8012b5 <sys_getenvid>
  800842:	25 ff 03 00 00       	and    $0x3ff,%eax
  800847:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80084a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80084f:	a3 20 50 80 00       	mov    %eax,0x805020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800854:	85 db                	test   %ebx,%ebx
  800856:	7e 07                	jle    80085f <libmain+0x2d>
		binaryname = argv[0];
  800858:	8b 06                	mov    (%esi),%eax
  80085a:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  80085f:	83 ec 08             	sub    $0x8,%esp
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	e8 ca f7 ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800869:	e8 0a 00 00 00       	call   800878 <exit>
}
  80086e:	83 c4 10             	add    $0x10,%esp
  800871:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800874:	5b                   	pop    %ebx
  800875:	5e                   	pop    %esi
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80087e:	e8 bb 12 00 00       	call   801b3e <close_all>
	sys_env_destroy(0);
  800883:	83 ec 0c             	sub    $0xc,%esp
  800886:	6a 00                	push   $0x0
  800888:	e8 e7 09 00 00       	call   801274 <sys_env_destroy>
}
  80088d:	83 c4 10             	add    $0x10,%esp
  800890:	c9                   	leave  
  800891:	c3                   	ret    

00800892 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	56                   	push   %esi
  800896:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800897:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80089a:	8b 35 00 40 80 00    	mov    0x804000,%esi
  8008a0:	e8 10 0a 00 00       	call   8012b5 <sys_getenvid>
  8008a5:	83 ec 0c             	sub    $0xc,%esp
  8008a8:	ff 75 0c             	pushl  0xc(%ebp)
  8008ab:	ff 75 08             	pushl  0x8(%ebp)
  8008ae:	56                   	push   %esi
  8008af:	50                   	push   %eax
  8008b0:	68 20 30 80 00       	push   $0x803020
  8008b5:	e8 b1 00 00 00       	call   80096b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8008ba:	83 c4 18             	add    $0x18,%esp
  8008bd:	53                   	push   %ebx
  8008be:	ff 75 10             	pushl  0x10(%ebp)
  8008c1:	e8 54 00 00 00       	call   80091a <vcprintf>
	cprintf("\n");
  8008c6:	c7 04 24 a3 2f 80 00 	movl   $0x802fa3,(%esp)
  8008cd:	e8 99 00 00 00       	call   80096b <cprintf>
  8008d2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8008d5:	cc                   	int3   
  8008d6:	eb fd                	jmp    8008d5 <_panic+0x43>

008008d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	53                   	push   %ebx
  8008dc:	83 ec 04             	sub    $0x4,%esp
  8008df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8008e2:	8b 13                	mov    (%ebx),%edx
  8008e4:	8d 42 01             	lea    0x1(%edx),%eax
  8008e7:	89 03                	mov    %eax,(%ebx)
  8008e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8008f0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8008f5:	75 1a                	jne    800911 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	68 ff 00 00 00       	push   $0xff
  8008ff:	8d 43 08             	lea    0x8(%ebx),%eax
  800902:	50                   	push   %eax
  800903:	e8 2f 09 00 00       	call   801237 <sys_cputs>
		b->idx = 0;
  800908:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80090e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800911:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800915:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800918:	c9                   	leave  
  800919:	c3                   	ret    

0080091a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800923:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80092a:	00 00 00 
	b.cnt = 0;
  80092d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800934:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800937:	ff 75 0c             	pushl  0xc(%ebp)
  80093a:	ff 75 08             	pushl  0x8(%ebp)
  80093d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800943:	50                   	push   %eax
  800944:	68 d8 08 80 00       	push   $0x8008d8
  800949:	e8 54 01 00 00       	call   800aa2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80094e:	83 c4 08             	add    $0x8,%esp
  800951:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800957:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80095d:	50                   	push   %eax
  80095e:	e8 d4 08 00 00       	call   801237 <sys_cputs>

	return b.cnt;
}
  800963:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800971:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800974:	50                   	push   %eax
  800975:	ff 75 08             	pushl  0x8(%ebp)
  800978:	e8 9d ff ff ff       	call   80091a <vcprintf>
	va_end(ap);

	return cnt;
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	57                   	push   %edi
  800983:	56                   	push   %esi
  800984:	53                   	push   %ebx
  800985:	83 ec 1c             	sub    $0x1c,%esp
  800988:	89 c7                	mov    %eax,%edi
  80098a:	89 d6                	mov    %edx,%esi
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800992:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800995:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800998:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80099b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8009a0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8009a3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8009a6:	39 d3                	cmp    %edx,%ebx
  8009a8:	72 05                	jb     8009af <printnum+0x30>
  8009aa:	39 45 10             	cmp    %eax,0x10(%ebp)
  8009ad:	77 45                	ja     8009f4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8009af:	83 ec 0c             	sub    $0xc,%esp
  8009b2:	ff 75 18             	pushl  0x18(%ebp)
  8009b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8009bb:	53                   	push   %ebx
  8009bc:	ff 75 10             	pushl  0x10(%ebp)
  8009bf:	83 ec 08             	sub    $0x8,%esp
  8009c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8009c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8009c8:	ff 75 dc             	pushl  -0x24(%ebp)
  8009cb:	ff 75 d8             	pushl  -0x28(%ebp)
  8009ce:	e8 cd 21 00 00       	call   802ba0 <__udivdi3>
  8009d3:	83 c4 18             	add    $0x18,%esp
  8009d6:	52                   	push   %edx
  8009d7:	50                   	push   %eax
  8009d8:	89 f2                	mov    %esi,%edx
  8009da:	89 f8                	mov    %edi,%eax
  8009dc:	e8 9e ff ff ff       	call   80097f <printnum>
  8009e1:	83 c4 20             	add    $0x20,%esp
  8009e4:	eb 18                	jmp    8009fe <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8009e6:	83 ec 08             	sub    $0x8,%esp
  8009e9:	56                   	push   %esi
  8009ea:	ff 75 18             	pushl  0x18(%ebp)
  8009ed:	ff d7                	call   *%edi
  8009ef:	83 c4 10             	add    $0x10,%esp
  8009f2:	eb 03                	jmp    8009f7 <printnum+0x78>
  8009f4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8009f7:	83 eb 01             	sub    $0x1,%ebx
  8009fa:	85 db                	test   %ebx,%ebx
  8009fc:	7f e8                	jg     8009e6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8009fe:	83 ec 08             	sub    $0x8,%esp
  800a01:	56                   	push   %esi
  800a02:	83 ec 04             	sub    $0x4,%esp
  800a05:	ff 75 e4             	pushl  -0x1c(%ebp)
  800a08:	ff 75 e0             	pushl  -0x20(%ebp)
  800a0b:	ff 75 dc             	pushl  -0x24(%ebp)
  800a0e:	ff 75 d8             	pushl  -0x28(%ebp)
  800a11:	e8 ba 22 00 00       	call   802cd0 <__umoddi3>
  800a16:	83 c4 14             	add    $0x14,%esp
  800a19:	0f be 80 43 30 80 00 	movsbl 0x803043(%eax),%eax
  800a20:	50                   	push   %eax
  800a21:	ff d7                	call   *%edi
}
  800a23:	83 c4 10             	add    $0x10,%esp
  800a26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a29:	5b                   	pop    %ebx
  800a2a:	5e                   	pop    %esi
  800a2b:	5f                   	pop    %edi
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    

00800a2e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800a31:	83 fa 01             	cmp    $0x1,%edx
  800a34:	7e 0e                	jle    800a44 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800a36:	8b 10                	mov    (%eax),%edx
  800a38:	8d 4a 08             	lea    0x8(%edx),%ecx
  800a3b:	89 08                	mov    %ecx,(%eax)
  800a3d:	8b 02                	mov    (%edx),%eax
  800a3f:	8b 52 04             	mov    0x4(%edx),%edx
  800a42:	eb 22                	jmp    800a66 <getuint+0x38>
	else if (lflag)
  800a44:	85 d2                	test   %edx,%edx
  800a46:	74 10                	je     800a58 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800a48:	8b 10                	mov    (%eax),%edx
  800a4a:	8d 4a 04             	lea    0x4(%edx),%ecx
  800a4d:	89 08                	mov    %ecx,(%eax)
  800a4f:	8b 02                	mov    (%edx),%eax
  800a51:	ba 00 00 00 00       	mov    $0x0,%edx
  800a56:	eb 0e                	jmp    800a66 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800a58:	8b 10                	mov    (%eax),%edx
  800a5a:	8d 4a 04             	lea    0x4(%edx),%ecx
  800a5d:	89 08                	mov    %ecx,(%eax)
  800a5f:	8b 02                	mov    (%edx),%eax
  800a61:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800a6e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800a72:	8b 10                	mov    (%eax),%edx
  800a74:	3b 50 04             	cmp    0x4(%eax),%edx
  800a77:	73 0a                	jae    800a83 <sprintputch+0x1b>
		*b->buf++ = ch;
  800a79:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a7c:	89 08                	mov    %ecx,(%eax)
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a81:	88 02                	mov    %al,(%edx)
}
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800a8b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800a8e:	50                   	push   %eax
  800a8f:	ff 75 10             	pushl  0x10(%ebp)
  800a92:	ff 75 0c             	pushl  0xc(%ebp)
  800a95:	ff 75 08             	pushl  0x8(%ebp)
  800a98:	e8 05 00 00 00       	call   800aa2 <vprintfmt>
	va_end(ap);
}
  800a9d:	83 c4 10             	add    $0x10,%esp
  800aa0:	c9                   	leave  
  800aa1:	c3                   	ret    

00800aa2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	57                   	push   %edi
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	83 ec 2c             	sub    $0x2c,%esp
  800aab:	8b 75 08             	mov    0x8(%ebp),%esi
  800aae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ab1:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ab4:	eb 12                	jmp    800ac8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800ab6:	85 c0                	test   %eax,%eax
  800ab8:	0f 84 89 03 00 00    	je     800e47 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800abe:	83 ec 08             	sub    $0x8,%esp
  800ac1:	53                   	push   %ebx
  800ac2:	50                   	push   %eax
  800ac3:	ff d6                	call   *%esi
  800ac5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800ac8:	83 c7 01             	add    $0x1,%edi
  800acb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800acf:	83 f8 25             	cmp    $0x25,%eax
  800ad2:	75 e2                	jne    800ab6 <vprintfmt+0x14>
  800ad4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800ad8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800adf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800ae6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800aed:	ba 00 00 00 00       	mov    $0x0,%edx
  800af2:	eb 07                	jmp    800afb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800af4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800af7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800afb:	8d 47 01             	lea    0x1(%edi),%eax
  800afe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b01:	0f b6 07             	movzbl (%edi),%eax
  800b04:	0f b6 c8             	movzbl %al,%ecx
  800b07:	83 e8 23             	sub    $0x23,%eax
  800b0a:	3c 55                	cmp    $0x55,%al
  800b0c:	0f 87 1a 03 00 00    	ja     800e2c <vprintfmt+0x38a>
  800b12:	0f b6 c0             	movzbl %al,%eax
  800b15:	ff 24 85 80 31 80 00 	jmp    *0x803180(,%eax,4)
  800b1c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800b1f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800b23:	eb d6                	jmp    800afb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b25:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b28:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800b30:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800b33:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800b37:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800b3a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800b3d:	83 fa 09             	cmp    $0x9,%edx
  800b40:	77 39                	ja     800b7b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800b42:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800b45:	eb e9                	jmp    800b30 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800b47:	8b 45 14             	mov    0x14(%ebp),%eax
  800b4a:	8d 48 04             	lea    0x4(%eax),%ecx
  800b4d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800b50:	8b 00                	mov    (%eax),%eax
  800b52:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b55:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800b58:	eb 27                	jmp    800b81 <vprintfmt+0xdf>
  800b5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b64:	0f 49 c8             	cmovns %eax,%ecx
  800b67:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b6a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b6d:	eb 8c                	jmp    800afb <vprintfmt+0x59>
  800b6f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800b72:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800b79:	eb 80                	jmp    800afb <vprintfmt+0x59>
  800b7b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b7e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800b81:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b85:	0f 89 70 ff ff ff    	jns    800afb <vprintfmt+0x59>
				width = precision, precision = -1;
  800b8b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800b8e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b91:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800b98:	e9 5e ff ff ff       	jmp    800afb <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800b9d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ba0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800ba3:	e9 53 ff ff ff       	jmp    800afb <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800ba8:	8b 45 14             	mov    0x14(%ebp),%eax
  800bab:	8d 50 04             	lea    0x4(%eax),%edx
  800bae:	89 55 14             	mov    %edx,0x14(%ebp)
  800bb1:	83 ec 08             	sub    $0x8,%esp
  800bb4:	53                   	push   %ebx
  800bb5:	ff 30                	pushl  (%eax)
  800bb7:	ff d6                	call   *%esi
			break;
  800bb9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bbc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800bbf:	e9 04 ff ff ff       	jmp    800ac8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800bc4:	8b 45 14             	mov    0x14(%ebp),%eax
  800bc7:	8d 50 04             	lea    0x4(%eax),%edx
  800bca:	89 55 14             	mov    %edx,0x14(%ebp)
  800bcd:	8b 00                	mov    (%eax),%eax
  800bcf:	99                   	cltd   
  800bd0:	31 d0                	xor    %edx,%eax
  800bd2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800bd4:	83 f8 0f             	cmp    $0xf,%eax
  800bd7:	7f 0b                	jg     800be4 <vprintfmt+0x142>
  800bd9:	8b 14 85 e0 32 80 00 	mov    0x8032e0(,%eax,4),%edx
  800be0:	85 d2                	test   %edx,%edx
  800be2:	75 18                	jne    800bfc <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800be4:	50                   	push   %eax
  800be5:	68 5b 30 80 00       	push   $0x80305b
  800bea:	53                   	push   %ebx
  800beb:	56                   	push   %esi
  800bec:	e8 94 fe ff ff       	call   800a85 <printfmt>
  800bf1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bf4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800bf7:	e9 cc fe ff ff       	jmp    800ac8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800bfc:	52                   	push   %edx
  800bfd:	68 d6 34 80 00       	push   $0x8034d6
  800c02:	53                   	push   %ebx
  800c03:	56                   	push   %esi
  800c04:	e8 7c fe ff ff       	call   800a85 <printfmt>
  800c09:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c0c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c0f:	e9 b4 fe ff ff       	jmp    800ac8 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800c14:	8b 45 14             	mov    0x14(%ebp),%eax
  800c17:	8d 50 04             	lea    0x4(%eax),%edx
  800c1a:	89 55 14             	mov    %edx,0x14(%ebp)
  800c1d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800c1f:	85 ff                	test   %edi,%edi
  800c21:	b8 54 30 80 00       	mov    $0x803054,%eax
  800c26:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800c29:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800c2d:	0f 8e 94 00 00 00    	jle    800cc7 <vprintfmt+0x225>
  800c33:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800c37:	0f 84 98 00 00 00    	je     800cd5 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800c3d:	83 ec 08             	sub    $0x8,%esp
  800c40:	ff 75 d0             	pushl  -0x30(%ebp)
  800c43:	57                   	push   %edi
  800c44:	e8 86 02 00 00       	call   800ecf <strnlen>
  800c49:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800c4c:	29 c1                	sub    %eax,%ecx
  800c4e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800c51:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800c54:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800c58:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c5b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800c5e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800c60:	eb 0f                	jmp    800c71 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800c62:	83 ec 08             	sub    $0x8,%esp
  800c65:	53                   	push   %ebx
  800c66:	ff 75 e0             	pushl  -0x20(%ebp)
  800c69:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800c6b:	83 ef 01             	sub    $0x1,%edi
  800c6e:	83 c4 10             	add    $0x10,%esp
  800c71:	85 ff                	test   %edi,%edi
  800c73:	7f ed                	jg     800c62 <vprintfmt+0x1c0>
  800c75:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800c78:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800c7b:	85 c9                	test   %ecx,%ecx
  800c7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c82:	0f 49 c1             	cmovns %ecx,%eax
  800c85:	29 c1                	sub    %eax,%ecx
  800c87:	89 75 08             	mov    %esi,0x8(%ebp)
  800c8a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800c8d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800c90:	89 cb                	mov    %ecx,%ebx
  800c92:	eb 4d                	jmp    800ce1 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800c94:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800c98:	74 1b                	je     800cb5 <vprintfmt+0x213>
  800c9a:	0f be c0             	movsbl %al,%eax
  800c9d:	83 e8 20             	sub    $0x20,%eax
  800ca0:	83 f8 5e             	cmp    $0x5e,%eax
  800ca3:	76 10                	jbe    800cb5 <vprintfmt+0x213>
					putch('?', putdat);
  800ca5:	83 ec 08             	sub    $0x8,%esp
  800ca8:	ff 75 0c             	pushl  0xc(%ebp)
  800cab:	6a 3f                	push   $0x3f
  800cad:	ff 55 08             	call   *0x8(%ebp)
  800cb0:	83 c4 10             	add    $0x10,%esp
  800cb3:	eb 0d                	jmp    800cc2 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800cb5:	83 ec 08             	sub    $0x8,%esp
  800cb8:	ff 75 0c             	pushl  0xc(%ebp)
  800cbb:	52                   	push   %edx
  800cbc:	ff 55 08             	call   *0x8(%ebp)
  800cbf:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800cc2:	83 eb 01             	sub    $0x1,%ebx
  800cc5:	eb 1a                	jmp    800ce1 <vprintfmt+0x23f>
  800cc7:	89 75 08             	mov    %esi,0x8(%ebp)
  800cca:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ccd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800cd0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800cd3:	eb 0c                	jmp    800ce1 <vprintfmt+0x23f>
  800cd5:	89 75 08             	mov    %esi,0x8(%ebp)
  800cd8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800cdb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800cde:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ce1:	83 c7 01             	add    $0x1,%edi
  800ce4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ce8:	0f be d0             	movsbl %al,%edx
  800ceb:	85 d2                	test   %edx,%edx
  800ced:	74 23                	je     800d12 <vprintfmt+0x270>
  800cef:	85 f6                	test   %esi,%esi
  800cf1:	78 a1                	js     800c94 <vprintfmt+0x1f2>
  800cf3:	83 ee 01             	sub    $0x1,%esi
  800cf6:	79 9c                	jns    800c94 <vprintfmt+0x1f2>
  800cf8:	89 df                	mov    %ebx,%edi
  800cfa:	8b 75 08             	mov    0x8(%ebp),%esi
  800cfd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d00:	eb 18                	jmp    800d1a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800d02:	83 ec 08             	sub    $0x8,%esp
  800d05:	53                   	push   %ebx
  800d06:	6a 20                	push   $0x20
  800d08:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800d0a:	83 ef 01             	sub    $0x1,%edi
  800d0d:	83 c4 10             	add    $0x10,%esp
  800d10:	eb 08                	jmp    800d1a <vprintfmt+0x278>
  800d12:	89 df                	mov    %ebx,%edi
  800d14:	8b 75 08             	mov    0x8(%ebp),%esi
  800d17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d1a:	85 ff                	test   %edi,%edi
  800d1c:	7f e4                	jg     800d02 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d1e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d21:	e9 a2 fd ff ff       	jmp    800ac8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800d26:	83 fa 01             	cmp    $0x1,%edx
  800d29:	7e 16                	jle    800d41 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800d2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800d2e:	8d 50 08             	lea    0x8(%eax),%edx
  800d31:	89 55 14             	mov    %edx,0x14(%ebp)
  800d34:	8b 50 04             	mov    0x4(%eax),%edx
  800d37:	8b 00                	mov    (%eax),%eax
  800d39:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d3c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800d3f:	eb 32                	jmp    800d73 <vprintfmt+0x2d1>
	else if (lflag)
  800d41:	85 d2                	test   %edx,%edx
  800d43:	74 18                	je     800d5d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800d45:	8b 45 14             	mov    0x14(%ebp),%eax
  800d48:	8d 50 04             	lea    0x4(%eax),%edx
  800d4b:	89 55 14             	mov    %edx,0x14(%ebp)
  800d4e:	8b 00                	mov    (%eax),%eax
  800d50:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d53:	89 c1                	mov    %eax,%ecx
  800d55:	c1 f9 1f             	sar    $0x1f,%ecx
  800d58:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800d5b:	eb 16                	jmp    800d73 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800d5d:	8b 45 14             	mov    0x14(%ebp),%eax
  800d60:	8d 50 04             	lea    0x4(%eax),%edx
  800d63:	89 55 14             	mov    %edx,0x14(%ebp)
  800d66:	8b 00                	mov    (%eax),%eax
  800d68:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d6b:	89 c1                	mov    %eax,%ecx
  800d6d:	c1 f9 1f             	sar    $0x1f,%ecx
  800d70:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800d73:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d76:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800d79:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800d7e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800d82:	79 74                	jns    800df8 <vprintfmt+0x356>
				putch('-', putdat);
  800d84:	83 ec 08             	sub    $0x8,%esp
  800d87:	53                   	push   %ebx
  800d88:	6a 2d                	push   $0x2d
  800d8a:	ff d6                	call   *%esi
				num = -(long long) num;
  800d8c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d8f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800d92:	f7 d8                	neg    %eax
  800d94:	83 d2 00             	adc    $0x0,%edx
  800d97:	f7 da                	neg    %edx
  800d99:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800d9c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800da1:	eb 55                	jmp    800df8 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800da3:	8d 45 14             	lea    0x14(%ebp),%eax
  800da6:	e8 83 fc ff ff       	call   800a2e <getuint>
			base = 10;
  800dab:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800db0:	eb 46                	jmp    800df8 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800db2:	8d 45 14             	lea    0x14(%ebp),%eax
  800db5:	e8 74 fc ff ff       	call   800a2e <getuint>
                        base = 8;
  800dba:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800dbf:	eb 37                	jmp    800df8 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800dc1:	83 ec 08             	sub    $0x8,%esp
  800dc4:	53                   	push   %ebx
  800dc5:	6a 30                	push   $0x30
  800dc7:	ff d6                	call   *%esi
			putch('x', putdat);
  800dc9:	83 c4 08             	add    $0x8,%esp
  800dcc:	53                   	push   %ebx
  800dcd:	6a 78                	push   $0x78
  800dcf:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800dd1:	8b 45 14             	mov    0x14(%ebp),%eax
  800dd4:	8d 50 04             	lea    0x4(%eax),%edx
  800dd7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800dda:	8b 00                	mov    (%eax),%eax
  800ddc:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800de1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800de4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800de9:	eb 0d                	jmp    800df8 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800deb:	8d 45 14             	lea    0x14(%ebp),%eax
  800dee:	e8 3b fc ff ff       	call   800a2e <getuint>
			base = 16;
  800df3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800df8:	83 ec 0c             	sub    $0xc,%esp
  800dfb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800dff:	57                   	push   %edi
  800e00:	ff 75 e0             	pushl  -0x20(%ebp)
  800e03:	51                   	push   %ecx
  800e04:	52                   	push   %edx
  800e05:	50                   	push   %eax
  800e06:	89 da                	mov    %ebx,%edx
  800e08:	89 f0                	mov    %esi,%eax
  800e0a:	e8 70 fb ff ff       	call   80097f <printnum>
			break;
  800e0f:	83 c4 20             	add    $0x20,%esp
  800e12:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800e15:	e9 ae fc ff ff       	jmp    800ac8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800e1a:	83 ec 08             	sub    $0x8,%esp
  800e1d:	53                   	push   %ebx
  800e1e:	51                   	push   %ecx
  800e1f:	ff d6                	call   *%esi
			break;
  800e21:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e24:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800e27:	e9 9c fc ff ff       	jmp    800ac8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800e2c:	83 ec 08             	sub    $0x8,%esp
  800e2f:	53                   	push   %ebx
  800e30:	6a 25                	push   $0x25
  800e32:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800e34:	83 c4 10             	add    $0x10,%esp
  800e37:	eb 03                	jmp    800e3c <vprintfmt+0x39a>
  800e39:	83 ef 01             	sub    $0x1,%edi
  800e3c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800e40:	75 f7                	jne    800e39 <vprintfmt+0x397>
  800e42:	e9 81 fc ff ff       	jmp    800ac8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800e47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4a:	5b                   	pop    %ebx
  800e4b:	5e                   	pop    %esi
  800e4c:	5f                   	pop    %edi
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	83 ec 18             	sub    $0x18,%esp
  800e55:	8b 45 08             	mov    0x8(%ebp),%eax
  800e58:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800e5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e5e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800e62:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800e65:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	74 26                	je     800e96 <vsnprintf+0x47>
  800e70:	85 d2                	test   %edx,%edx
  800e72:	7e 22                	jle    800e96 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800e74:	ff 75 14             	pushl  0x14(%ebp)
  800e77:	ff 75 10             	pushl  0x10(%ebp)
  800e7a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800e7d:	50                   	push   %eax
  800e7e:	68 68 0a 80 00       	push   $0x800a68
  800e83:	e8 1a fc ff ff       	call   800aa2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800e88:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e8b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e91:	83 c4 10             	add    $0x10,%esp
  800e94:	eb 05                	jmp    800e9b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800e96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800e9b:	c9                   	leave  
  800e9c:	c3                   	ret    

00800e9d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ea3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ea6:	50                   	push   %eax
  800ea7:	ff 75 10             	pushl  0x10(%ebp)
  800eaa:	ff 75 0c             	pushl  0xc(%ebp)
  800ead:	ff 75 08             	pushl  0x8(%ebp)
  800eb0:	e8 9a ff ff ff       	call   800e4f <vsnprintf>
	va_end(ap);

	return rc;
}
  800eb5:	c9                   	leave  
  800eb6:	c3                   	ret    

00800eb7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ebd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec2:	eb 03                	jmp    800ec7 <strlen+0x10>
		n++;
  800ec4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ec7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ecb:	75 f7                	jne    800ec4 <strlen+0xd>
		n++;
	return n;
}
  800ecd:	5d                   	pop    %ebp
  800ece:	c3                   	ret    

00800ecf <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ed8:	ba 00 00 00 00       	mov    $0x0,%edx
  800edd:	eb 03                	jmp    800ee2 <strnlen+0x13>
		n++;
  800edf:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ee2:	39 c2                	cmp    %eax,%edx
  800ee4:	74 08                	je     800eee <strnlen+0x1f>
  800ee6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800eea:	75 f3                	jne    800edf <strnlen+0x10>
  800eec:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	53                   	push   %ebx
  800ef4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800efa:	89 c2                	mov    %eax,%edx
  800efc:	83 c2 01             	add    $0x1,%edx
  800eff:	83 c1 01             	add    $0x1,%ecx
  800f02:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800f06:	88 5a ff             	mov    %bl,-0x1(%edx)
  800f09:	84 db                	test   %bl,%bl
  800f0b:	75 ef                	jne    800efc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800f0d:	5b                   	pop    %ebx
  800f0e:	5d                   	pop    %ebp
  800f0f:	c3                   	ret    

00800f10 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	53                   	push   %ebx
  800f14:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800f17:	53                   	push   %ebx
  800f18:	e8 9a ff ff ff       	call   800eb7 <strlen>
  800f1d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800f20:	ff 75 0c             	pushl  0xc(%ebp)
  800f23:	01 d8                	add    %ebx,%eax
  800f25:	50                   	push   %eax
  800f26:	e8 c5 ff ff ff       	call   800ef0 <strcpy>
	return dst;
}
  800f2b:	89 d8                	mov    %ebx,%eax
  800f2d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f30:	c9                   	leave  
  800f31:	c3                   	ret    

00800f32 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	56                   	push   %esi
  800f36:	53                   	push   %ebx
  800f37:	8b 75 08             	mov    0x8(%ebp),%esi
  800f3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3d:	89 f3                	mov    %esi,%ebx
  800f3f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f42:	89 f2                	mov    %esi,%edx
  800f44:	eb 0f                	jmp    800f55 <strncpy+0x23>
		*dst++ = *src;
  800f46:	83 c2 01             	add    $0x1,%edx
  800f49:	0f b6 01             	movzbl (%ecx),%eax
  800f4c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800f4f:	80 39 01             	cmpb   $0x1,(%ecx)
  800f52:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f55:	39 da                	cmp    %ebx,%edx
  800f57:	75 ed                	jne    800f46 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800f59:	89 f0                	mov    %esi,%eax
  800f5b:	5b                   	pop    %ebx
  800f5c:	5e                   	pop    %esi
  800f5d:	5d                   	pop    %ebp
  800f5e:	c3                   	ret    

00800f5f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	56                   	push   %esi
  800f63:	53                   	push   %ebx
  800f64:	8b 75 08             	mov    0x8(%ebp),%esi
  800f67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f6a:	8b 55 10             	mov    0x10(%ebp),%edx
  800f6d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800f6f:	85 d2                	test   %edx,%edx
  800f71:	74 21                	je     800f94 <strlcpy+0x35>
  800f73:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800f77:	89 f2                	mov    %esi,%edx
  800f79:	eb 09                	jmp    800f84 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800f7b:	83 c2 01             	add    $0x1,%edx
  800f7e:	83 c1 01             	add    $0x1,%ecx
  800f81:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800f84:	39 c2                	cmp    %eax,%edx
  800f86:	74 09                	je     800f91 <strlcpy+0x32>
  800f88:	0f b6 19             	movzbl (%ecx),%ebx
  800f8b:	84 db                	test   %bl,%bl
  800f8d:	75 ec                	jne    800f7b <strlcpy+0x1c>
  800f8f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800f91:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800f94:	29 f0                	sub    %esi,%eax
}
  800f96:	5b                   	pop    %ebx
  800f97:	5e                   	pop    %esi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    

00800f9a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800fa3:	eb 06                	jmp    800fab <strcmp+0x11>
		p++, q++;
  800fa5:	83 c1 01             	add    $0x1,%ecx
  800fa8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800fab:	0f b6 01             	movzbl (%ecx),%eax
  800fae:	84 c0                	test   %al,%al
  800fb0:	74 04                	je     800fb6 <strcmp+0x1c>
  800fb2:	3a 02                	cmp    (%edx),%al
  800fb4:	74 ef                	je     800fa5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800fb6:	0f b6 c0             	movzbl %al,%eax
  800fb9:	0f b6 12             	movzbl (%edx),%edx
  800fbc:	29 d0                	sub    %edx,%eax
}
  800fbe:	5d                   	pop    %ebp
  800fbf:	c3                   	ret    

00800fc0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	53                   	push   %ebx
  800fc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fca:	89 c3                	mov    %eax,%ebx
  800fcc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800fcf:	eb 06                	jmp    800fd7 <strncmp+0x17>
		n--, p++, q++;
  800fd1:	83 c0 01             	add    $0x1,%eax
  800fd4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800fd7:	39 d8                	cmp    %ebx,%eax
  800fd9:	74 15                	je     800ff0 <strncmp+0x30>
  800fdb:	0f b6 08             	movzbl (%eax),%ecx
  800fde:	84 c9                	test   %cl,%cl
  800fe0:	74 04                	je     800fe6 <strncmp+0x26>
  800fe2:	3a 0a                	cmp    (%edx),%cl
  800fe4:	74 eb                	je     800fd1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800fe6:	0f b6 00             	movzbl (%eax),%eax
  800fe9:	0f b6 12             	movzbl (%edx),%edx
  800fec:	29 d0                	sub    %edx,%eax
  800fee:	eb 05                	jmp    800ff5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ff0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ff5:	5b                   	pop    %ebx
  800ff6:	5d                   	pop    %ebp
  800ff7:	c3                   	ret    

00800ff8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ffe:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801002:	eb 07                	jmp    80100b <strchr+0x13>
		if (*s == c)
  801004:	38 ca                	cmp    %cl,%dl
  801006:	74 0f                	je     801017 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801008:	83 c0 01             	add    $0x1,%eax
  80100b:	0f b6 10             	movzbl (%eax),%edx
  80100e:	84 d2                	test   %dl,%dl
  801010:	75 f2                	jne    801004 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801012:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801017:	5d                   	pop    %ebp
  801018:	c3                   	ret    

00801019 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	8b 45 08             	mov    0x8(%ebp),%eax
  80101f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801023:	eb 03                	jmp    801028 <strfind+0xf>
  801025:	83 c0 01             	add    $0x1,%eax
  801028:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80102b:	38 ca                	cmp    %cl,%dl
  80102d:	74 04                	je     801033 <strfind+0x1a>
  80102f:	84 d2                	test   %dl,%dl
  801031:	75 f2                	jne    801025 <strfind+0xc>
			break;
	return (char *) s;
}
  801033:	5d                   	pop    %ebp
  801034:	c3                   	ret    

00801035 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	57                   	push   %edi
  801039:	56                   	push   %esi
  80103a:	53                   	push   %ebx
  80103b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80103e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801041:	85 c9                	test   %ecx,%ecx
  801043:	74 36                	je     80107b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801045:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80104b:	75 28                	jne    801075 <memset+0x40>
  80104d:	f6 c1 03             	test   $0x3,%cl
  801050:	75 23                	jne    801075 <memset+0x40>
		c &= 0xFF;
  801052:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801056:	89 d3                	mov    %edx,%ebx
  801058:	c1 e3 08             	shl    $0x8,%ebx
  80105b:	89 d6                	mov    %edx,%esi
  80105d:	c1 e6 18             	shl    $0x18,%esi
  801060:	89 d0                	mov    %edx,%eax
  801062:	c1 e0 10             	shl    $0x10,%eax
  801065:	09 f0                	or     %esi,%eax
  801067:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801069:	89 d8                	mov    %ebx,%eax
  80106b:	09 d0                	or     %edx,%eax
  80106d:	c1 e9 02             	shr    $0x2,%ecx
  801070:	fc                   	cld    
  801071:	f3 ab                	rep stos %eax,%es:(%edi)
  801073:	eb 06                	jmp    80107b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801075:	8b 45 0c             	mov    0xc(%ebp),%eax
  801078:	fc                   	cld    
  801079:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80107b:	89 f8                	mov    %edi,%eax
  80107d:	5b                   	pop    %ebx
  80107e:	5e                   	pop    %esi
  80107f:	5f                   	pop    %edi
  801080:	5d                   	pop    %ebp
  801081:	c3                   	ret    

00801082 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	57                   	push   %edi
  801086:	56                   	push   %esi
  801087:	8b 45 08             	mov    0x8(%ebp),%eax
  80108a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80108d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801090:	39 c6                	cmp    %eax,%esi
  801092:	73 35                	jae    8010c9 <memmove+0x47>
  801094:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801097:	39 d0                	cmp    %edx,%eax
  801099:	73 2e                	jae    8010c9 <memmove+0x47>
		s += n;
		d += n;
  80109b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80109e:	89 d6                	mov    %edx,%esi
  8010a0:	09 fe                	or     %edi,%esi
  8010a2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8010a8:	75 13                	jne    8010bd <memmove+0x3b>
  8010aa:	f6 c1 03             	test   $0x3,%cl
  8010ad:	75 0e                	jne    8010bd <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8010af:	83 ef 04             	sub    $0x4,%edi
  8010b2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8010b5:	c1 e9 02             	shr    $0x2,%ecx
  8010b8:	fd                   	std    
  8010b9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8010bb:	eb 09                	jmp    8010c6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8010bd:	83 ef 01             	sub    $0x1,%edi
  8010c0:	8d 72 ff             	lea    -0x1(%edx),%esi
  8010c3:	fd                   	std    
  8010c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8010c6:	fc                   	cld    
  8010c7:	eb 1d                	jmp    8010e6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8010c9:	89 f2                	mov    %esi,%edx
  8010cb:	09 c2                	or     %eax,%edx
  8010cd:	f6 c2 03             	test   $0x3,%dl
  8010d0:	75 0f                	jne    8010e1 <memmove+0x5f>
  8010d2:	f6 c1 03             	test   $0x3,%cl
  8010d5:	75 0a                	jne    8010e1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8010d7:	c1 e9 02             	shr    $0x2,%ecx
  8010da:	89 c7                	mov    %eax,%edi
  8010dc:	fc                   	cld    
  8010dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8010df:	eb 05                	jmp    8010e6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8010e1:	89 c7                	mov    %eax,%edi
  8010e3:	fc                   	cld    
  8010e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8010e6:	5e                   	pop    %esi
  8010e7:	5f                   	pop    %edi
  8010e8:	5d                   	pop    %ebp
  8010e9:	c3                   	ret    

008010ea <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8010ed:	ff 75 10             	pushl  0x10(%ebp)
  8010f0:	ff 75 0c             	pushl  0xc(%ebp)
  8010f3:	ff 75 08             	pushl  0x8(%ebp)
  8010f6:	e8 87 ff ff ff       	call   801082 <memmove>
}
  8010fb:	c9                   	leave  
  8010fc:	c3                   	ret    

008010fd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
  801100:	56                   	push   %esi
  801101:	53                   	push   %ebx
  801102:	8b 45 08             	mov    0x8(%ebp),%eax
  801105:	8b 55 0c             	mov    0xc(%ebp),%edx
  801108:	89 c6                	mov    %eax,%esi
  80110a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80110d:	eb 1a                	jmp    801129 <memcmp+0x2c>
		if (*s1 != *s2)
  80110f:	0f b6 08             	movzbl (%eax),%ecx
  801112:	0f b6 1a             	movzbl (%edx),%ebx
  801115:	38 d9                	cmp    %bl,%cl
  801117:	74 0a                	je     801123 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801119:	0f b6 c1             	movzbl %cl,%eax
  80111c:	0f b6 db             	movzbl %bl,%ebx
  80111f:	29 d8                	sub    %ebx,%eax
  801121:	eb 0f                	jmp    801132 <memcmp+0x35>
		s1++, s2++;
  801123:	83 c0 01             	add    $0x1,%eax
  801126:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801129:	39 f0                	cmp    %esi,%eax
  80112b:	75 e2                	jne    80110f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80112d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801132:	5b                   	pop    %ebx
  801133:	5e                   	pop    %esi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	53                   	push   %ebx
  80113a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80113d:	89 c1                	mov    %eax,%ecx
  80113f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801142:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801146:	eb 0a                	jmp    801152 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801148:	0f b6 10             	movzbl (%eax),%edx
  80114b:	39 da                	cmp    %ebx,%edx
  80114d:	74 07                	je     801156 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80114f:	83 c0 01             	add    $0x1,%eax
  801152:	39 c8                	cmp    %ecx,%eax
  801154:	72 f2                	jb     801148 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801156:	5b                   	pop    %ebx
  801157:	5d                   	pop    %ebp
  801158:	c3                   	ret    

00801159 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801159:	55                   	push   %ebp
  80115a:	89 e5                	mov    %esp,%ebp
  80115c:	57                   	push   %edi
  80115d:	56                   	push   %esi
  80115e:	53                   	push   %ebx
  80115f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801162:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801165:	eb 03                	jmp    80116a <strtol+0x11>
		s++;
  801167:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80116a:	0f b6 01             	movzbl (%ecx),%eax
  80116d:	3c 20                	cmp    $0x20,%al
  80116f:	74 f6                	je     801167 <strtol+0xe>
  801171:	3c 09                	cmp    $0x9,%al
  801173:	74 f2                	je     801167 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801175:	3c 2b                	cmp    $0x2b,%al
  801177:	75 0a                	jne    801183 <strtol+0x2a>
		s++;
  801179:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80117c:	bf 00 00 00 00       	mov    $0x0,%edi
  801181:	eb 11                	jmp    801194 <strtol+0x3b>
  801183:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801188:	3c 2d                	cmp    $0x2d,%al
  80118a:	75 08                	jne    801194 <strtol+0x3b>
		s++, neg = 1;
  80118c:	83 c1 01             	add    $0x1,%ecx
  80118f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801194:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80119a:	75 15                	jne    8011b1 <strtol+0x58>
  80119c:	80 39 30             	cmpb   $0x30,(%ecx)
  80119f:	75 10                	jne    8011b1 <strtol+0x58>
  8011a1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8011a5:	75 7c                	jne    801223 <strtol+0xca>
		s += 2, base = 16;
  8011a7:	83 c1 02             	add    $0x2,%ecx
  8011aa:	bb 10 00 00 00       	mov    $0x10,%ebx
  8011af:	eb 16                	jmp    8011c7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8011b1:	85 db                	test   %ebx,%ebx
  8011b3:	75 12                	jne    8011c7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8011b5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8011ba:	80 39 30             	cmpb   $0x30,(%ecx)
  8011bd:	75 08                	jne    8011c7 <strtol+0x6e>
		s++, base = 8;
  8011bf:	83 c1 01             	add    $0x1,%ecx
  8011c2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8011c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011cc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8011cf:	0f b6 11             	movzbl (%ecx),%edx
  8011d2:	8d 72 d0             	lea    -0x30(%edx),%esi
  8011d5:	89 f3                	mov    %esi,%ebx
  8011d7:	80 fb 09             	cmp    $0x9,%bl
  8011da:	77 08                	ja     8011e4 <strtol+0x8b>
			dig = *s - '0';
  8011dc:	0f be d2             	movsbl %dl,%edx
  8011df:	83 ea 30             	sub    $0x30,%edx
  8011e2:	eb 22                	jmp    801206 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8011e4:	8d 72 9f             	lea    -0x61(%edx),%esi
  8011e7:	89 f3                	mov    %esi,%ebx
  8011e9:	80 fb 19             	cmp    $0x19,%bl
  8011ec:	77 08                	ja     8011f6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8011ee:	0f be d2             	movsbl %dl,%edx
  8011f1:	83 ea 57             	sub    $0x57,%edx
  8011f4:	eb 10                	jmp    801206 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8011f6:	8d 72 bf             	lea    -0x41(%edx),%esi
  8011f9:	89 f3                	mov    %esi,%ebx
  8011fb:	80 fb 19             	cmp    $0x19,%bl
  8011fe:	77 16                	ja     801216 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801200:	0f be d2             	movsbl %dl,%edx
  801203:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801206:	3b 55 10             	cmp    0x10(%ebp),%edx
  801209:	7d 0b                	jge    801216 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  80120b:	83 c1 01             	add    $0x1,%ecx
  80120e:	0f af 45 10          	imul   0x10(%ebp),%eax
  801212:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801214:	eb b9                	jmp    8011cf <strtol+0x76>

	if (endptr)
  801216:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80121a:	74 0d                	je     801229 <strtol+0xd0>
		*endptr = (char *) s;
  80121c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80121f:	89 0e                	mov    %ecx,(%esi)
  801221:	eb 06                	jmp    801229 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801223:	85 db                	test   %ebx,%ebx
  801225:	74 98                	je     8011bf <strtol+0x66>
  801227:	eb 9e                	jmp    8011c7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801229:	89 c2                	mov    %eax,%edx
  80122b:	f7 da                	neg    %edx
  80122d:	85 ff                	test   %edi,%edi
  80122f:	0f 45 c2             	cmovne %edx,%eax
}
  801232:	5b                   	pop    %ebx
  801233:	5e                   	pop    %esi
  801234:	5f                   	pop    %edi
  801235:	5d                   	pop    %ebp
  801236:	c3                   	ret    

00801237 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	57                   	push   %edi
  80123b:	56                   	push   %esi
  80123c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80123d:	b8 00 00 00 00       	mov    $0x0,%eax
  801242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801245:	8b 55 08             	mov    0x8(%ebp),%edx
  801248:	89 c3                	mov    %eax,%ebx
  80124a:	89 c7                	mov    %eax,%edi
  80124c:	89 c6                	mov    %eax,%esi
  80124e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801250:	5b                   	pop    %ebx
  801251:	5e                   	pop    %esi
  801252:	5f                   	pop    %edi
  801253:	5d                   	pop    %ebp
  801254:	c3                   	ret    

00801255 <sys_cgetc>:

int
sys_cgetc(void)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	57                   	push   %edi
  801259:	56                   	push   %esi
  80125a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80125b:	ba 00 00 00 00       	mov    $0x0,%edx
  801260:	b8 01 00 00 00       	mov    $0x1,%eax
  801265:	89 d1                	mov    %edx,%ecx
  801267:	89 d3                	mov    %edx,%ebx
  801269:	89 d7                	mov    %edx,%edi
  80126b:	89 d6                	mov    %edx,%esi
  80126d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80126f:	5b                   	pop    %ebx
  801270:	5e                   	pop    %esi
  801271:	5f                   	pop    %edi
  801272:	5d                   	pop    %ebp
  801273:	c3                   	ret    

00801274 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	57                   	push   %edi
  801278:	56                   	push   %esi
  801279:	53                   	push   %ebx
  80127a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80127d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801282:	b8 03 00 00 00       	mov    $0x3,%eax
  801287:	8b 55 08             	mov    0x8(%ebp),%edx
  80128a:	89 cb                	mov    %ecx,%ebx
  80128c:	89 cf                	mov    %ecx,%edi
  80128e:	89 ce                	mov    %ecx,%esi
  801290:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801292:	85 c0                	test   %eax,%eax
  801294:	7e 17                	jle    8012ad <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801296:	83 ec 0c             	sub    $0xc,%esp
  801299:	50                   	push   %eax
  80129a:	6a 03                	push   $0x3
  80129c:	68 3f 33 80 00       	push   $0x80333f
  8012a1:	6a 23                	push   $0x23
  8012a3:	68 5c 33 80 00       	push   $0x80335c
  8012a8:	e8 e5 f5 ff ff       	call   800892 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8012ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012b0:	5b                   	pop    %ebx
  8012b1:	5e                   	pop    %esi
  8012b2:	5f                   	pop    %edi
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    

008012b5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	57                   	push   %edi
  8012b9:	56                   	push   %esi
  8012ba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c0:	b8 02 00 00 00       	mov    $0x2,%eax
  8012c5:	89 d1                	mov    %edx,%ecx
  8012c7:	89 d3                	mov    %edx,%ebx
  8012c9:	89 d7                	mov    %edx,%edi
  8012cb:	89 d6                	mov    %edx,%esi
  8012cd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8012cf:	5b                   	pop    %ebx
  8012d0:	5e                   	pop    %esi
  8012d1:	5f                   	pop    %edi
  8012d2:	5d                   	pop    %ebp
  8012d3:	c3                   	ret    

008012d4 <sys_yield>:

void
sys_yield(void)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	57                   	push   %edi
  8012d8:	56                   	push   %esi
  8012d9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012da:	ba 00 00 00 00       	mov    $0x0,%edx
  8012df:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012e4:	89 d1                	mov    %edx,%ecx
  8012e6:	89 d3                	mov    %edx,%ebx
  8012e8:	89 d7                	mov    %edx,%edi
  8012ea:	89 d6                	mov    %edx,%esi
  8012ec:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8012ee:	5b                   	pop    %ebx
  8012ef:	5e                   	pop    %esi
  8012f0:	5f                   	pop    %edi
  8012f1:	5d                   	pop    %ebp
  8012f2:	c3                   	ret    

008012f3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	57                   	push   %edi
  8012f7:	56                   	push   %esi
  8012f8:	53                   	push   %ebx
  8012f9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012fc:	be 00 00 00 00       	mov    $0x0,%esi
  801301:	b8 04 00 00 00       	mov    $0x4,%eax
  801306:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801309:	8b 55 08             	mov    0x8(%ebp),%edx
  80130c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80130f:	89 f7                	mov    %esi,%edi
  801311:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801313:	85 c0                	test   %eax,%eax
  801315:	7e 17                	jle    80132e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801317:	83 ec 0c             	sub    $0xc,%esp
  80131a:	50                   	push   %eax
  80131b:	6a 04                	push   $0x4
  80131d:	68 3f 33 80 00       	push   $0x80333f
  801322:	6a 23                	push   $0x23
  801324:	68 5c 33 80 00       	push   $0x80335c
  801329:	e8 64 f5 ff ff       	call   800892 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80132e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801331:	5b                   	pop    %ebx
  801332:	5e                   	pop    %esi
  801333:	5f                   	pop    %edi
  801334:	5d                   	pop    %ebp
  801335:	c3                   	ret    

00801336 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	57                   	push   %edi
  80133a:	56                   	push   %esi
  80133b:	53                   	push   %ebx
  80133c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80133f:	b8 05 00 00 00       	mov    $0x5,%eax
  801344:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801347:	8b 55 08             	mov    0x8(%ebp),%edx
  80134a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80134d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801350:	8b 75 18             	mov    0x18(%ebp),%esi
  801353:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801355:	85 c0                	test   %eax,%eax
  801357:	7e 17                	jle    801370 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801359:	83 ec 0c             	sub    $0xc,%esp
  80135c:	50                   	push   %eax
  80135d:	6a 05                	push   $0x5
  80135f:	68 3f 33 80 00       	push   $0x80333f
  801364:	6a 23                	push   $0x23
  801366:	68 5c 33 80 00       	push   $0x80335c
  80136b:	e8 22 f5 ff ff       	call   800892 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801370:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801373:	5b                   	pop    %ebx
  801374:	5e                   	pop    %esi
  801375:	5f                   	pop    %edi
  801376:	5d                   	pop    %ebp
  801377:	c3                   	ret    

00801378 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	57                   	push   %edi
  80137c:	56                   	push   %esi
  80137d:	53                   	push   %ebx
  80137e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801381:	bb 00 00 00 00       	mov    $0x0,%ebx
  801386:	b8 06 00 00 00       	mov    $0x6,%eax
  80138b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80138e:	8b 55 08             	mov    0x8(%ebp),%edx
  801391:	89 df                	mov    %ebx,%edi
  801393:	89 de                	mov    %ebx,%esi
  801395:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801397:	85 c0                	test   %eax,%eax
  801399:	7e 17                	jle    8013b2 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80139b:	83 ec 0c             	sub    $0xc,%esp
  80139e:	50                   	push   %eax
  80139f:	6a 06                	push   $0x6
  8013a1:	68 3f 33 80 00       	push   $0x80333f
  8013a6:	6a 23                	push   $0x23
  8013a8:	68 5c 33 80 00       	push   $0x80335c
  8013ad:	e8 e0 f4 ff ff       	call   800892 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8013b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b5:	5b                   	pop    %ebx
  8013b6:	5e                   	pop    %esi
  8013b7:	5f                   	pop    %edi
  8013b8:	5d                   	pop    %ebp
  8013b9:	c3                   	ret    

008013ba <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	57                   	push   %edi
  8013be:	56                   	push   %esi
  8013bf:	53                   	push   %ebx
  8013c0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013c8:	b8 08 00 00 00       	mov    $0x8,%eax
  8013cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d3:	89 df                	mov    %ebx,%edi
  8013d5:	89 de                	mov    %ebx,%esi
  8013d7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	7e 17                	jle    8013f4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013dd:	83 ec 0c             	sub    $0xc,%esp
  8013e0:	50                   	push   %eax
  8013e1:	6a 08                	push   $0x8
  8013e3:	68 3f 33 80 00       	push   $0x80333f
  8013e8:	6a 23                	push   $0x23
  8013ea:	68 5c 33 80 00       	push   $0x80335c
  8013ef:	e8 9e f4 ff ff       	call   800892 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8013f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013f7:	5b                   	pop    %ebx
  8013f8:	5e                   	pop    %esi
  8013f9:	5f                   	pop    %edi
  8013fa:	5d                   	pop    %ebp
  8013fb:	c3                   	ret    

008013fc <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	57                   	push   %edi
  801400:	56                   	push   %esi
  801401:	53                   	push   %ebx
  801402:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801405:	bb 00 00 00 00       	mov    $0x0,%ebx
  80140a:	b8 09 00 00 00       	mov    $0x9,%eax
  80140f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801412:	8b 55 08             	mov    0x8(%ebp),%edx
  801415:	89 df                	mov    %ebx,%edi
  801417:	89 de                	mov    %ebx,%esi
  801419:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80141b:	85 c0                	test   %eax,%eax
  80141d:	7e 17                	jle    801436 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80141f:	83 ec 0c             	sub    $0xc,%esp
  801422:	50                   	push   %eax
  801423:	6a 09                	push   $0x9
  801425:	68 3f 33 80 00       	push   $0x80333f
  80142a:	6a 23                	push   $0x23
  80142c:	68 5c 33 80 00       	push   $0x80335c
  801431:	e8 5c f4 ff ff       	call   800892 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801436:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801439:	5b                   	pop    %ebx
  80143a:	5e                   	pop    %esi
  80143b:	5f                   	pop    %edi
  80143c:	5d                   	pop    %ebp
  80143d:	c3                   	ret    

0080143e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	57                   	push   %edi
  801442:	56                   	push   %esi
  801443:	53                   	push   %ebx
  801444:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801447:	bb 00 00 00 00       	mov    $0x0,%ebx
  80144c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801451:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801454:	8b 55 08             	mov    0x8(%ebp),%edx
  801457:	89 df                	mov    %ebx,%edi
  801459:	89 de                	mov    %ebx,%esi
  80145b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80145d:	85 c0                	test   %eax,%eax
  80145f:	7e 17                	jle    801478 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801461:	83 ec 0c             	sub    $0xc,%esp
  801464:	50                   	push   %eax
  801465:	6a 0a                	push   $0xa
  801467:	68 3f 33 80 00       	push   $0x80333f
  80146c:	6a 23                	push   $0x23
  80146e:	68 5c 33 80 00       	push   $0x80335c
  801473:	e8 1a f4 ff ff       	call   800892 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801478:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80147b:	5b                   	pop    %ebx
  80147c:	5e                   	pop    %esi
  80147d:	5f                   	pop    %edi
  80147e:	5d                   	pop    %ebp
  80147f:	c3                   	ret    

00801480 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
  801483:	57                   	push   %edi
  801484:	56                   	push   %esi
  801485:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801486:	be 00 00 00 00       	mov    $0x0,%esi
  80148b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801490:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801493:	8b 55 08             	mov    0x8(%ebp),%edx
  801496:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801499:	8b 7d 14             	mov    0x14(%ebp),%edi
  80149c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80149e:	5b                   	pop    %ebx
  80149f:	5e                   	pop    %esi
  8014a0:	5f                   	pop    %edi
  8014a1:	5d                   	pop    %ebp
  8014a2:	c3                   	ret    

008014a3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	57                   	push   %edi
  8014a7:	56                   	push   %esi
  8014a8:	53                   	push   %ebx
  8014a9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014b1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8014b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8014b9:	89 cb                	mov    %ecx,%ebx
  8014bb:	89 cf                	mov    %ecx,%edi
  8014bd:	89 ce                	mov    %ecx,%esi
  8014bf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	7e 17                	jle    8014dc <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014c5:	83 ec 0c             	sub    $0xc,%esp
  8014c8:	50                   	push   %eax
  8014c9:	6a 0d                	push   $0xd
  8014cb:	68 3f 33 80 00       	push   $0x80333f
  8014d0:	6a 23                	push   $0x23
  8014d2:	68 5c 33 80 00       	push   $0x80335c
  8014d7:	e8 b6 f3 ff ff       	call   800892 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8014dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014df:	5b                   	pop    %ebx
  8014e0:	5e                   	pop    %esi
  8014e1:	5f                   	pop    %edi
  8014e2:	5d                   	pop    %ebp
  8014e3:	c3                   	ret    

008014e4 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	57                   	push   %edi
  8014e8:	56                   	push   %esi
  8014e9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ef:	b8 0e 00 00 00       	mov    $0xe,%eax
  8014f4:	89 d1                	mov    %edx,%ecx
  8014f6:	89 d3                	mov    %edx,%ebx
  8014f8:	89 d7                	mov    %edx,%edi
  8014fa:	89 d6                	mov    %edx,%esi
  8014fc:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8014fe:	5b                   	pop    %ebx
  8014ff:	5e                   	pop    %esi
  801500:	5f                   	pop    %edi
  801501:	5d                   	pop    %ebp
  801502:	c3                   	ret    

00801503 <sys_transmit_packet>:

int
sys_transmit_packet(void *buf, size_t size)
{
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	57                   	push   %edi
  801507:	56                   	push   %esi
  801508:	53                   	push   %ebx
  801509:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80150c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801511:	b8 0f 00 00 00       	mov    $0xf,%eax
  801516:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801519:	8b 55 08             	mov    0x8(%ebp),%edx
  80151c:	89 df                	mov    %ebx,%edi
  80151e:	89 de                	mov    %ebx,%esi
  801520:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801522:	85 c0                	test   %eax,%eax
  801524:	7e 17                	jle    80153d <sys_transmit_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801526:	83 ec 0c             	sub    $0xc,%esp
  801529:	50                   	push   %eax
  80152a:	6a 0f                	push   $0xf
  80152c:	68 3f 33 80 00       	push   $0x80333f
  801531:	6a 23                	push   $0x23
  801533:	68 5c 33 80 00       	push   $0x80335c
  801538:	e8 55 f3 ff ff       	call   800892 <_panic>
int
sys_transmit_packet(void *buf, size_t size)
{
	return syscall(SYS_transmit_packet, 1,
		(uint32_t) buf, (uint32_t) size, 0, 0, 0);
}
  80153d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801540:	5b                   	pop    %ebx
  801541:	5e                   	pop    %esi
  801542:	5f                   	pop    %edi
  801543:	5d                   	pop    %ebp
  801544:	c3                   	ret    

00801545 <sys_receive_packet>:

int
sys_receive_packet(void *buf, size_t *size_store)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	57                   	push   %edi
  801549:	56                   	push   %esi
  80154a:	53                   	push   %ebx
  80154b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80154e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801553:	b8 10 00 00 00       	mov    $0x10,%eax
  801558:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80155b:	8b 55 08             	mov    0x8(%ebp),%edx
  80155e:	89 df                	mov    %ebx,%edi
  801560:	89 de                	mov    %ebx,%esi
  801562:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801564:	85 c0                	test   %eax,%eax
  801566:	7e 17                	jle    80157f <sys_receive_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801568:	83 ec 0c             	sub    $0xc,%esp
  80156b:	50                   	push   %eax
  80156c:	6a 10                	push   $0x10
  80156e:	68 3f 33 80 00       	push   $0x80333f
  801573:	6a 23                	push   $0x23
  801575:	68 5c 33 80 00       	push   $0x80335c
  80157a:	e8 13 f3 ff ff       	call   800892 <_panic>
int
sys_receive_packet(void *buf, size_t *size_store)
{
	return syscall(SYS_receive_packet, 1,
		(uint32_t) buf, (uint32_t) size_store, 0, 0, 0);
}
  80157f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801582:	5b                   	pop    %ebx
  801583:	5e                   	pop    %esi
  801584:	5f                   	pop    %edi
  801585:	5d                   	pop    %ebp
  801586:	c3                   	ret    

00801587 <sys_get_mac_address>:

int
sys_get_mac_address(void *buf)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	57                   	push   %edi
  80158b:	56                   	push   %esi
  80158c:	53                   	push   %ebx
  80158d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801590:	b9 00 00 00 00       	mov    $0x0,%ecx
  801595:	b8 11 00 00 00       	mov    $0x11,%eax
  80159a:	8b 55 08             	mov    0x8(%ebp),%edx
  80159d:	89 cb                	mov    %ecx,%ebx
  80159f:	89 cf                	mov    %ecx,%edi
  8015a1:	89 ce                	mov    %ecx,%esi
  8015a3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	7e 17                	jle    8015c0 <sys_get_mac_address+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015a9:	83 ec 0c             	sub    $0xc,%esp
  8015ac:	50                   	push   %eax
  8015ad:	6a 11                	push   $0x11
  8015af:	68 3f 33 80 00       	push   $0x80333f
  8015b4:	6a 23                	push   $0x23
  8015b6:	68 5c 33 80 00       	push   $0x80335c
  8015bb:	e8 d2 f2 ff ff       	call   800892 <_panic>
int
sys_get_mac_address(void *buf)
{
	return syscall(SYS_get_mac_address, 1,
		(uint32_t) buf, 0, 0, 0, 0);
}
  8015c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c3:	5b                   	pop    %ebx
  8015c4:	5e                   	pop    %esi
  8015c5:	5f                   	pop    %edi
  8015c6:	5d                   	pop    %ebp
  8015c7:	c3                   	ret    

008015c8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8015c8:	55                   	push   %ebp
  8015c9:	89 e5                	mov    %esp,%ebp
  8015cb:	53                   	push   %ebx
  8015cc:	83 ec 04             	sub    $0x4,%esp
  8015cf:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8015d2:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  8015d4:	89 da                	mov    %ebx,%edx
  8015d6:	c1 ea 0c             	shr    $0xc,%edx
	pte_t pte = uvpt[pn];
  8015d9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  8015e0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8015e4:	74 05                	je     8015eb <pgfault+0x23>
  8015e6:	f6 c6 08             	test   $0x8,%dh
  8015e9:	75 14                	jne    8015ff <pgfault+0x37>
		panic("fork pgfault handler: does not handle this fault");
  8015eb:	83 ec 04             	sub    $0x4,%esp
  8015ee:	68 6c 33 80 00       	push   $0x80336c
  8015f3:	6a 1f                	push   $0x1f
  8015f5:	68 9d 33 80 00       	push   $0x80339d
  8015fa:	e8 93 f2 ff ff       	call   800892 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  8015ff:	83 ec 04             	sub    $0x4,%esp
  801602:	6a 07                	push   $0x7
  801604:	68 00 f0 7f 00       	push   $0x7ff000
  801609:	6a 00                	push   $0x0
  80160b:	e8 e3 fc ff ff       	call   8012f3 <sys_page_alloc>
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	85 c0                	test   %eax,%eax
  801615:	79 12                	jns    801629 <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  801617:	50                   	push   %eax
  801618:	68 a8 33 80 00       	push   $0x8033a8
  80161d:	6a 2b                	push   $0x2b
  80161f:	68 9d 33 80 00       	push   $0x80339d
  801624:	e8 69 f2 ff ff       	call   800892 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  801629:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  80162f:	83 ec 04             	sub    $0x4,%esp
  801632:	68 00 10 00 00       	push   $0x1000
  801637:	53                   	push   %ebx
  801638:	68 00 f0 7f 00       	push   $0x7ff000
  80163d:	e8 40 fa ff ff       	call   801082 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  801642:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801649:	53                   	push   %ebx
  80164a:	6a 00                	push   $0x0
  80164c:	68 00 f0 7f 00       	push   $0x7ff000
  801651:	6a 00                	push   $0x0
  801653:	e8 de fc ff ff       	call   801336 <sys_page_map>
  801658:	83 c4 20             	add    $0x20,%esp
  80165b:	85 c0                	test   %eax,%eax
  80165d:	79 12                	jns    801671 <pgfault+0xa9>
		panic("sys_page_map: %e", r);
  80165f:	50                   	push   %eax
  801660:	68 98 2e 80 00       	push   $0x802e98
  801665:	6a 33                	push   $0x33
  801667:	68 9d 33 80 00       	push   $0x80339d
  80166c:	e8 21 f2 ff ff       	call   800892 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801671:	83 ec 08             	sub    $0x8,%esp
  801674:	68 00 f0 7f 00       	push   $0x7ff000
  801679:	6a 00                	push   $0x0
  80167b:	e8 f8 fc ff ff       	call   801378 <sys_page_unmap>
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	85 c0                	test   %eax,%eax
  801685:	79 12                	jns    801699 <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  801687:	50                   	push   %eax
  801688:	68 bb 33 80 00       	push   $0x8033bb
  80168d:	6a 37                	push   $0x37
  80168f:	68 9d 33 80 00       	push   $0x80339d
  801694:	e8 f9 f1 ff ff       	call   800892 <_panic>
}
  801699:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169c:	c9                   	leave  
  80169d:	c3                   	ret    

0080169e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	57                   	push   %edi
  8016a2:	56                   	push   %esi
  8016a3:	53                   	push   %ebx
  8016a4:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  8016a7:	68 c8 15 80 00       	push   $0x8015c8
  8016ac:	e8 3c 14 00 00       	call   802aed <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8016b1:	b8 07 00 00 00       	mov    $0x7,%eax
  8016b6:	cd 30                	int    $0x30
  8016b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Create child
	envid_t envid = sys_exofork();
	if (envid < 0) {
  8016be:	83 c4 10             	add    $0x10,%esp
  8016c1:	85 c0                	test   %eax,%eax
  8016c3:	79 15                	jns    8016da <fork+0x3c>
		panic("sys_exofork: %e", envid);
  8016c5:	50                   	push   %eax
  8016c6:	68 ce 33 80 00       	push   $0x8033ce
  8016cb:	68 93 00 00 00       	push   $0x93
  8016d0:	68 9d 33 80 00       	push   $0x80339d
  8016d5:	e8 b8 f1 ff ff       	call   800892 <_panic>
		return envid;
	}

	// If we are the child, fix thisenv.
	if (envid == 0) {
  8016da:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8016de:	75 21                	jne    801701 <fork+0x63>
		thisenv = &envs[ENVX(sys_getenvid())];
  8016e0:	e8 d0 fb ff ff       	call   8012b5 <sys_getenvid>
  8016e5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016ea:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8016ed:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8016f2:	a3 20 50 80 00       	mov    %eax,0x805020
		return 0;
  8016f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016fc:	e9 5a 01 00 00       	jmp    80185b <fork+0x1bd>
	// We are the parent!
	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle the
	// fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), PTE_P | PTE_U | PTE_W);
  801701:	83 ec 04             	sub    $0x4,%esp
  801704:	6a 07                	push   $0x7
  801706:	68 00 f0 bf ee       	push   $0xeebff000
  80170b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80170e:	57                   	push   %edi
  80170f:	e8 df fb ff ff       	call   8012f3 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801714:	83 c4 08             	add    $0x8,%esp
  801717:	68 32 2b 80 00       	push   $0x802b32
  80171c:	57                   	push   %edi
  80171d:	e8 1c fd ff ff       	call   80143e <sys_env_set_pgfault_upcall>
  801722:	83 c4 10             	add    $0x10,%esp

	// Copy our address space to child. Be careful not to copy the exception
	// stack too, so go until USTACKTOP instead of UTOP.
	unsigned pn;
	for (pn = UTEXT/PGSIZE; pn < USTACKTOP/PGSIZE; pn++) {
  801725:	bb 00 08 00 00       	mov    $0x800,%ebx
static int
duppage(envid_t envid, unsigned pn)
{
	// Check if the page table that contains the PTE we want is allocated
	// using UVPD. If it is not, just don't map anything, and silently succeed.
	if (!(uvpd[pn/NPTENTRIES] & PTE_P))
  80172a:	89 d8                	mov    %ebx,%eax
  80172c:	c1 e8 0a             	shr    $0xa,%eax
  80172f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801736:	a8 01                	test   $0x1,%al
  801738:	0f 84 e2 00 00 00    	je     801820 <fork+0x182>
		return 0;

	// Retrieve the PTE using UVPT
	pte_t pte = uvpt[pn];
  80173e:	8b 34 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%esi

	// If the page is present, duplicate according to it's permissions
	if (pte & PTE_P) {
  801745:	f7 c6 01 00 00 00    	test   $0x1,%esi
  80174b:	0f 84 cf 00 00 00    	je     801820 <fork+0x182>
		int r;
		uint32_t perm = pte & PTE_SYSCALL;
  801751:	89 f0                	mov    %esi,%eax
  801753:	25 07 0e 00 00       	and    $0xe07,%eax
  801758:	89 df                	mov    %ebx,%edi
  80175a:	c1 e7 0c             	shl    $0xc,%edi
		void *va = (void *) (pn * PGSIZE);

		// If PTE_SHARE is enabled, share it by just copying the
		// pte, which can be done by mapping on the same address
		// with the same permissions, even if it is writable
		if (pte & PTE_SHARE) {
  80175d:	f7 c6 00 04 00 00    	test   $0x400,%esi
  801763:	74 2d                	je     801792 <fork+0xf4>
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  801765:	83 ec 0c             	sub    $0xc,%esp
  801768:	50                   	push   %eax
  801769:	57                   	push   %edi
  80176a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80176d:	57                   	push   %edi
  80176e:	6a 00                	push   $0x0
  801770:	e8 c1 fb ff ff       	call   801336 <sys_page_map>
  801775:	83 c4 20             	add    $0x20,%esp
  801778:	85 c0                	test   %eax,%eax
  80177a:	0f 89 a0 00 00 00    	jns    801820 <fork+0x182>
				panic("sys_page_map: %e", r);
  801780:	50                   	push   %eax
  801781:	68 98 2e 80 00       	push   $0x802e98
  801786:	6a 5c                	push   $0x5c
  801788:	68 9d 33 80 00       	push   $0x80339d
  80178d:	e8 00 f1 ff ff       	call   800892 <_panic>
				return r;
			}
		// If writable or COW, make it COW on parent and child
		} else if (pte & (PTE_W | PTE_COW)) {
  801792:	f7 c6 02 08 00 00    	test   $0x802,%esi
  801798:	74 5d                	je     8017f7 <fork+0x159>
			perm &= ~PTE_W;  // Remove PTE_W, so it faults
  80179a:	81 e6 05 0e 00 00    	and    $0xe05,%esi
			perm |= PTE_COW; // Make it PTE_COW
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  8017a0:	81 ce 00 08 00 00    	or     $0x800,%esi
  8017a6:	83 ec 0c             	sub    $0xc,%esp
  8017a9:	56                   	push   %esi
  8017aa:	57                   	push   %edi
  8017ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017ae:	57                   	push   %edi
  8017af:	6a 00                	push   $0x0
  8017b1:	e8 80 fb ff ff       	call   801336 <sys_page_map>
  8017b6:	83 c4 20             	add    $0x20,%esp
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	79 12                	jns    8017cf <fork+0x131>
				panic("sys_page_map: %e", r);
  8017bd:	50                   	push   %eax
  8017be:	68 98 2e 80 00       	push   $0x802e98
  8017c3:	6a 65                	push   $0x65
  8017c5:	68 9d 33 80 00       	push   $0x80339d
  8017ca:	e8 c3 f0 ff ff       	call   800892 <_panic>
				return r;
			}
			// Change the permission on parent, mapping on itself
			if ((r = sys_page_map(0, va, 0, va, perm)) < 0) {
  8017cf:	83 ec 0c             	sub    $0xc,%esp
  8017d2:	56                   	push   %esi
  8017d3:	57                   	push   %edi
  8017d4:	6a 00                	push   $0x0
  8017d6:	57                   	push   %edi
  8017d7:	6a 00                	push   $0x0
  8017d9:	e8 58 fb ff ff       	call   801336 <sys_page_map>
  8017de:	83 c4 20             	add    $0x20,%esp
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	79 3b                	jns    801820 <fork+0x182>
				panic("sys_page_map: %e", r);
  8017e5:	50                   	push   %eax
  8017e6:	68 98 2e 80 00       	push   $0x802e98
  8017eb:	6a 6a                	push   $0x6a
  8017ed:	68 9d 33 80 00       	push   $0x80339d
  8017f2:	e8 9b f0 ff ff       	call   800892 <_panic>
				return r;
			}
		// If it is read-only, just share it.
		} else {
			// Map on the child
			if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  8017f7:	83 ec 0c             	sub    $0xc,%esp
  8017fa:	50                   	push   %eax
  8017fb:	57                   	push   %edi
  8017fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017ff:	57                   	push   %edi
  801800:	6a 00                	push   $0x0
  801802:	e8 2f fb ff ff       	call   801336 <sys_page_map>
  801807:	83 c4 20             	add    $0x20,%esp
  80180a:	85 c0                	test   %eax,%eax
  80180c:	79 12                	jns    801820 <fork+0x182>
				panic("sys_page_map: %e", r);
  80180e:	50                   	push   %eax
  80180f:	68 98 2e 80 00       	push   $0x802e98
  801814:	6a 71                	push   $0x71
  801816:	68 9d 33 80 00       	push   $0x80339d
  80181b:	e8 72 f0 ff ff       	call   800892 <_panic>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);

	// Copy our address space to child. Be careful not to copy the exception
	// stack too, so go until USTACKTOP instead of UTOP.
	unsigned pn;
	for (pn = UTEXT/PGSIZE; pn < USTACKTOP/PGSIZE; pn++) {
  801820:	83 c3 01             	add    $0x1,%ebx
  801823:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801829:	0f 85 fb fe ff ff    	jne    80172a <fork+0x8c>
		duppage(envid, pn);
	}

	// Make the child runnable
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  80182f:	83 ec 08             	sub    $0x8,%esp
  801832:	6a 02                	push   $0x2
  801834:	ff 75 e0             	pushl  -0x20(%ebp)
  801837:	e8 7e fb ff ff       	call   8013ba <sys_env_set_status>
  80183c:	83 c4 10             	add    $0x10,%esp
  80183f:	85 c0                	test   %eax,%eax
  801841:	79 15                	jns    801858 <fork+0x1ba>
		panic("sys_env_set_status: %e", r);
  801843:	50                   	push   %eax
  801844:	68 de 33 80 00       	push   $0x8033de
  801849:	68 af 00 00 00       	push   $0xaf
  80184e:	68 9d 33 80 00       	push   $0x80339d
  801853:	e8 3a f0 ff ff       	call   800892 <_panic>
		return r;
	}

	return envid;
  801858:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  80185b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80185e:	5b                   	pop    %ebx
  80185f:	5e                   	pop    %esi
  801860:	5f                   	pop    %edi
  801861:	5d                   	pop    %ebp
  801862:	c3                   	ret    

00801863 <sfork>:

// Challenge!
int
sfork(void)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801869:	68 f5 33 80 00       	push   $0x8033f5
  80186e:	68 ba 00 00 00       	push   $0xba
  801873:	68 9d 33 80 00       	push   $0x80339d
  801878:	e8 15 f0 ff ff       	call   800892 <_panic>

0080187d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
  801880:	56                   	push   %esi
  801881:	53                   	push   %ebx
  801882:	8b 75 08             	mov    0x8(%ebp),%esi
  801885:	8b 45 0c             	mov    0xc(%ebp),%eax
  801888:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  80188b:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80188d:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801892:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801895:	83 ec 0c             	sub    $0xc,%esp
  801898:	50                   	push   %eax
  801899:	e8 05 fc ff ff       	call   8014a3 <sys_ipc_recv>

	if (r < 0) {
  80189e:	83 c4 10             	add    $0x10,%esp
  8018a1:	85 c0                	test   %eax,%eax
  8018a3:	79 16                	jns    8018bb <ipc_recv+0x3e>
		if (from_env_store)
  8018a5:	85 f6                	test   %esi,%esi
  8018a7:	74 06                	je     8018af <ipc_recv+0x32>
			*from_env_store = 0;
  8018a9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  8018af:	85 db                	test   %ebx,%ebx
  8018b1:	74 2c                	je     8018df <ipc_recv+0x62>
			*perm_store = 0;
  8018b3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8018b9:	eb 24                	jmp    8018df <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  8018bb:	85 f6                	test   %esi,%esi
  8018bd:	74 0a                	je     8018c9 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  8018bf:	a1 20 50 80 00       	mov    0x805020,%eax
  8018c4:	8b 40 74             	mov    0x74(%eax),%eax
  8018c7:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  8018c9:	85 db                	test   %ebx,%ebx
  8018cb:	74 0a                	je     8018d7 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  8018cd:	a1 20 50 80 00       	mov    0x805020,%eax
  8018d2:	8b 40 78             	mov    0x78(%eax),%eax
  8018d5:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  8018d7:	a1 20 50 80 00       	mov    0x805020,%eax
  8018dc:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8018df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e2:	5b                   	pop    %ebx
  8018e3:	5e                   	pop    %esi
  8018e4:	5d                   	pop    %ebp
  8018e5:	c3                   	ret    

008018e6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8018e6:	55                   	push   %ebp
  8018e7:	89 e5                	mov    %esp,%ebp
  8018e9:	57                   	push   %edi
  8018ea:	56                   	push   %esi
  8018eb:	53                   	push   %ebx
  8018ec:	83 ec 0c             	sub    $0xc,%esp
  8018ef:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018f2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8018f8:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8018fa:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8018ff:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801902:	ff 75 14             	pushl  0x14(%ebp)
  801905:	53                   	push   %ebx
  801906:	56                   	push   %esi
  801907:	57                   	push   %edi
  801908:	e8 73 fb ff ff       	call   801480 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  80190d:	83 c4 10             	add    $0x10,%esp
  801910:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801913:	75 07                	jne    80191c <ipc_send+0x36>
			sys_yield();
  801915:	e8 ba f9 ff ff       	call   8012d4 <sys_yield>
  80191a:	eb e6                	jmp    801902 <ipc_send+0x1c>
		} else if (r < 0) {
  80191c:	85 c0                	test   %eax,%eax
  80191e:	79 12                	jns    801932 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801920:	50                   	push   %eax
  801921:	68 0b 34 80 00       	push   $0x80340b
  801926:	6a 51                	push   $0x51
  801928:	68 18 34 80 00       	push   $0x803418
  80192d:	e8 60 ef ff ff       	call   800892 <_panic>
		}
	}
}
  801932:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801935:	5b                   	pop    %ebx
  801936:	5e                   	pop    %esi
  801937:	5f                   	pop    %edi
  801938:	5d                   	pop    %ebp
  801939:	c3                   	ret    

0080193a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801940:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801945:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801948:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80194e:	8b 52 50             	mov    0x50(%edx),%edx
  801951:	39 ca                	cmp    %ecx,%edx
  801953:	75 0d                	jne    801962 <ipc_find_env+0x28>
			return envs[i].env_id;
  801955:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801958:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80195d:	8b 40 48             	mov    0x48(%eax),%eax
  801960:	eb 0f                	jmp    801971 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801962:	83 c0 01             	add    $0x1,%eax
  801965:	3d 00 04 00 00       	cmp    $0x400,%eax
  80196a:	75 d9                	jne    801945 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80196c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801971:	5d                   	pop    %ebp
  801972:	c3                   	ret    

00801973 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801976:	8b 45 08             	mov    0x8(%ebp),%eax
  801979:	05 00 00 00 30       	add    $0x30000000,%eax
  80197e:	c1 e8 0c             	shr    $0xc,%eax
}
  801981:	5d                   	pop    %ebp
  801982:	c3                   	ret    

00801983 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801986:	8b 45 08             	mov    0x8(%ebp),%eax
  801989:	05 00 00 00 30       	add    $0x30000000,%eax
  80198e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801993:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801998:	5d                   	pop    %ebp
  801999:	c3                   	ret    

0080199a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019a0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8019a5:	89 c2                	mov    %eax,%edx
  8019a7:	c1 ea 16             	shr    $0x16,%edx
  8019aa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8019b1:	f6 c2 01             	test   $0x1,%dl
  8019b4:	74 11                	je     8019c7 <fd_alloc+0x2d>
  8019b6:	89 c2                	mov    %eax,%edx
  8019b8:	c1 ea 0c             	shr    $0xc,%edx
  8019bb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019c2:	f6 c2 01             	test   $0x1,%dl
  8019c5:	75 09                	jne    8019d0 <fd_alloc+0x36>
			*fd_store = fd;
  8019c7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8019c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ce:	eb 17                	jmp    8019e7 <fd_alloc+0x4d>
  8019d0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8019d5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8019da:	75 c9                	jne    8019a5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8019dc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8019e2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8019e7:	5d                   	pop    %ebp
  8019e8:	c3                   	ret    

008019e9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8019ef:	83 f8 1f             	cmp    $0x1f,%eax
  8019f2:	77 36                	ja     801a2a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8019f4:	c1 e0 0c             	shl    $0xc,%eax
  8019f7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8019fc:	89 c2                	mov    %eax,%edx
  8019fe:	c1 ea 16             	shr    $0x16,%edx
  801a01:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801a08:	f6 c2 01             	test   $0x1,%dl
  801a0b:	74 24                	je     801a31 <fd_lookup+0x48>
  801a0d:	89 c2                	mov    %eax,%edx
  801a0f:	c1 ea 0c             	shr    $0xc,%edx
  801a12:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a19:	f6 c2 01             	test   $0x1,%dl
  801a1c:	74 1a                	je     801a38 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801a1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a21:	89 02                	mov    %eax,(%edx)
	return 0;
  801a23:	b8 00 00 00 00       	mov    $0x0,%eax
  801a28:	eb 13                	jmp    801a3d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801a2a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a2f:	eb 0c                	jmp    801a3d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801a31:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a36:	eb 05                	jmp    801a3d <fd_lookup+0x54>
  801a38:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801a3d:	5d                   	pop    %ebp
  801a3e:	c3                   	ret    

00801a3f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	83 ec 08             	sub    $0x8,%esp
  801a45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a48:	ba a4 34 80 00       	mov    $0x8034a4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801a4d:	eb 13                	jmp    801a62 <dev_lookup+0x23>
  801a4f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801a52:	39 08                	cmp    %ecx,(%eax)
  801a54:	75 0c                	jne    801a62 <dev_lookup+0x23>
			*dev = devtab[i];
  801a56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a59:	89 01                	mov    %eax,(%ecx)
			return 0;
  801a5b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a60:	eb 2e                	jmp    801a90 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801a62:	8b 02                	mov    (%edx),%eax
  801a64:	85 c0                	test   %eax,%eax
  801a66:	75 e7                	jne    801a4f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801a68:	a1 20 50 80 00       	mov    0x805020,%eax
  801a6d:	8b 40 48             	mov    0x48(%eax),%eax
  801a70:	83 ec 04             	sub    $0x4,%esp
  801a73:	51                   	push   %ecx
  801a74:	50                   	push   %eax
  801a75:	68 24 34 80 00       	push   $0x803424
  801a7a:	e8 ec ee ff ff       	call   80096b <cprintf>
	*dev = 0;
  801a7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a82:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801a90:	c9                   	leave  
  801a91:	c3                   	ret    

00801a92 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	56                   	push   %esi
  801a96:	53                   	push   %ebx
  801a97:	83 ec 10             	sub    $0x10,%esp
  801a9a:	8b 75 08             	mov    0x8(%ebp),%esi
  801a9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801aa0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa3:	50                   	push   %eax
  801aa4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801aaa:	c1 e8 0c             	shr    $0xc,%eax
  801aad:	50                   	push   %eax
  801aae:	e8 36 ff ff ff       	call   8019e9 <fd_lookup>
  801ab3:	83 c4 08             	add    $0x8,%esp
  801ab6:	85 c0                	test   %eax,%eax
  801ab8:	78 05                	js     801abf <fd_close+0x2d>
	    || fd != fd2)
  801aba:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801abd:	74 0c                	je     801acb <fd_close+0x39>
		return (must_exist ? r : 0);
  801abf:	84 db                	test   %bl,%bl
  801ac1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac6:	0f 44 c2             	cmove  %edx,%eax
  801ac9:	eb 41                	jmp    801b0c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801acb:	83 ec 08             	sub    $0x8,%esp
  801ace:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ad1:	50                   	push   %eax
  801ad2:	ff 36                	pushl  (%esi)
  801ad4:	e8 66 ff ff ff       	call   801a3f <dev_lookup>
  801ad9:	89 c3                	mov    %eax,%ebx
  801adb:	83 c4 10             	add    $0x10,%esp
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	78 1a                	js     801afc <fd_close+0x6a>
		if (dev->dev_close)
  801ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae5:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801ae8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801aed:	85 c0                	test   %eax,%eax
  801aef:	74 0b                	je     801afc <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801af1:	83 ec 0c             	sub    $0xc,%esp
  801af4:	56                   	push   %esi
  801af5:	ff d0                	call   *%eax
  801af7:	89 c3                	mov    %eax,%ebx
  801af9:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801afc:	83 ec 08             	sub    $0x8,%esp
  801aff:	56                   	push   %esi
  801b00:	6a 00                	push   $0x0
  801b02:	e8 71 f8 ff ff       	call   801378 <sys_page_unmap>
	return r;
  801b07:	83 c4 10             	add    $0x10,%esp
  801b0a:	89 d8                	mov    %ebx,%eax
}
  801b0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b0f:	5b                   	pop    %ebx
  801b10:	5e                   	pop    %esi
  801b11:	5d                   	pop    %ebp
  801b12:	c3                   	ret    

00801b13 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b1c:	50                   	push   %eax
  801b1d:	ff 75 08             	pushl  0x8(%ebp)
  801b20:	e8 c4 fe ff ff       	call   8019e9 <fd_lookup>
  801b25:	83 c4 08             	add    $0x8,%esp
  801b28:	85 c0                	test   %eax,%eax
  801b2a:	78 10                	js     801b3c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801b2c:	83 ec 08             	sub    $0x8,%esp
  801b2f:	6a 01                	push   $0x1
  801b31:	ff 75 f4             	pushl  -0xc(%ebp)
  801b34:	e8 59 ff ff ff       	call   801a92 <fd_close>
  801b39:	83 c4 10             	add    $0x10,%esp
}
  801b3c:	c9                   	leave  
  801b3d:	c3                   	ret    

00801b3e <close_all>:

void
close_all(void)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	53                   	push   %ebx
  801b42:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801b45:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801b4a:	83 ec 0c             	sub    $0xc,%esp
  801b4d:	53                   	push   %ebx
  801b4e:	e8 c0 ff ff ff       	call   801b13 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801b53:	83 c3 01             	add    $0x1,%ebx
  801b56:	83 c4 10             	add    $0x10,%esp
  801b59:	83 fb 20             	cmp    $0x20,%ebx
  801b5c:	75 ec                	jne    801b4a <close_all+0xc>
		close(i);
}
  801b5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b61:	c9                   	leave  
  801b62:	c3                   	ret    

00801b63 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801b63:	55                   	push   %ebp
  801b64:	89 e5                	mov    %esp,%ebp
  801b66:	57                   	push   %edi
  801b67:	56                   	push   %esi
  801b68:	53                   	push   %ebx
  801b69:	83 ec 2c             	sub    $0x2c,%esp
  801b6c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801b6f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b72:	50                   	push   %eax
  801b73:	ff 75 08             	pushl  0x8(%ebp)
  801b76:	e8 6e fe ff ff       	call   8019e9 <fd_lookup>
  801b7b:	83 c4 08             	add    $0x8,%esp
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	0f 88 c1 00 00 00    	js     801c47 <dup+0xe4>
		return r;
	close(newfdnum);
  801b86:	83 ec 0c             	sub    $0xc,%esp
  801b89:	56                   	push   %esi
  801b8a:	e8 84 ff ff ff       	call   801b13 <close>

	newfd = INDEX2FD(newfdnum);
  801b8f:	89 f3                	mov    %esi,%ebx
  801b91:	c1 e3 0c             	shl    $0xc,%ebx
  801b94:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801b9a:	83 c4 04             	add    $0x4,%esp
  801b9d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ba0:	e8 de fd ff ff       	call   801983 <fd2data>
  801ba5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801ba7:	89 1c 24             	mov    %ebx,(%esp)
  801baa:	e8 d4 fd ff ff       	call   801983 <fd2data>
  801baf:	83 c4 10             	add    $0x10,%esp
  801bb2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801bb5:	89 f8                	mov    %edi,%eax
  801bb7:	c1 e8 16             	shr    $0x16,%eax
  801bba:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801bc1:	a8 01                	test   $0x1,%al
  801bc3:	74 37                	je     801bfc <dup+0x99>
  801bc5:	89 f8                	mov    %edi,%eax
  801bc7:	c1 e8 0c             	shr    $0xc,%eax
  801bca:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801bd1:	f6 c2 01             	test   $0x1,%dl
  801bd4:	74 26                	je     801bfc <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801bd6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801bdd:	83 ec 0c             	sub    $0xc,%esp
  801be0:	25 07 0e 00 00       	and    $0xe07,%eax
  801be5:	50                   	push   %eax
  801be6:	ff 75 d4             	pushl  -0x2c(%ebp)
  801be9:	6a 00                	push   $0x0
  801beb:	57                   	push   %edi
  801bec:	6a 00                	push   $0x0
  801bee:	e8 43 f7 ff ff       	call   801336 <sys_page_map>
  801bf3:	89 c7                	mov    %eax,%edi
  801bf5:	83 c4 20             	add    $0x20,%esp
  801bf8:	85 c0                	test   %eax,%eax
  801bfa:	78 2e                	js     801c2a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801bfc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801bff:	89 d0                	mov    %edx,%eax
  801c01:	c1 e8 0c             	shr    $0xc,%eax
  801c04:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801c0b:	83 ec 0c             	sub    $0xc,%esp
  801c0e:	25 07 0e 00 00       	and    $0xe07,%eax
  801c13:	50                   	push   %eax
  801c14:	53                   	push   %ebx
  801c15:	6a 00                	push   $0x0
  801c17:	52                   	push   %edx
  801c18:	6a 00                	push   $0x0
  801c1a:	e8 17 f7 ff ff       	call   801336 <sys_page_map>
  801c1f:	89 c7                	mov    %eax,%edi
  801c21:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801c24:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801c26:	85 ff                	test   %edi,%edi
  801c28:	79 1d                	jns    801c47 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801c2a:	83 ec 08             	sub    $0x8,%esp
  801c2d:	53                   	push   %ebx
  801c2e:	6a 00                	push   $0x0
  801c30:	e8 43 f7 ff ff       	call   801378 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801c35:	83 c4 08             	add    $0x8,%esp
  801c38:	ff 75 d4             	pushl  -0x2c(%ebp)
  801c3b:	6a 00                	push   $0x0
  801c3d:	e8 36 f7 ff ff       	call   801378 <sys_page_unmap>
	return r;
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	89 f8                	mov    %edi,%eax
}
  801c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c4a:	5b                   	pop    %ebx
  801c4b:	5e                   	pop    %esi
  801c4c:	5f                   	pop    %edi
  801c4d:	5d                   	pop    %ebp
  801c4e:	c3                   	ret    

00801c4f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	53                   	push   %ebx
  801c53:	83 ec 14             	sub    $0x14,%esp
  801c56:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c59:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c5c:	50                   	push   %eax
  801c5d:	53                   	push   %ebx
  801c5e:	e8 86 fd ff ff       	call   8019e9 <fd_lookup>
  801c63:	83 c4 08             	add    $0x8,%esp
  801c66:	89 c2                	mov    %eax,%edx
  801c68:	85 c0                	test   %eax,%eax
  801c6a:	78 6d                	js     801cd9 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c6c:	83 ec 08             	sub    $0x8,%esp
  801c6f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c72:	50                   	push   %eax
  801c73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c76:	ff 30                	pushl  (%eax)
  801c78:	e8 c2 fd ff ff       	call   801a3f <dev_lookup>
  801c7d:	83 c4 10             	add    $0x10,%esp
  801c80:	85 c0                	test   %eax,%eax
  801c82:	78 4c                	js     801cd0 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801c84:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c87:	8b 42 08             	mov    0x8(%edx),%eax
  801c8a:	83 e0 03             	and    $0x3,%eax
  801c8d:	83 f8 01             	cmp    $0x1,%eax
  801c90:	75 21                	jne    801cb3 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801c92:	a1 20 50 80 00       	mov    0x805020,%eax
  801c97:	8b 40 48             	mov    0x48(%eax),%eax
  801c9a:	83 ec 04             	sub    $0x4,%esp
  801c9d:	53                   	push   %ebx
  801c9e:	50                   	push   %eax
  801c9f:	68 68 34 80 00       	push   $0x803468
  801ca4:	e8 c2 ec ff ff       	call   80096b <cprintf>
		return -E_INVAL;
  801ca9:	83 c4 10             	add    $0x10,%esp
  801cac:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801cb1:	eb 26                	jmp    801cd9 <read+0x8a>
	}
	if (!dev->dev_read)
  801cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb6:	8b 40 08             	mov    0x8(%eax),%eax
  801cb9:	85 c0                	test   %eax,%eax
  801cbb:	74 17                	je     801cd4 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801cbd:	83 ec 04             	sub    $0x4,%esp
  801cc0:	ff 75 10             	pushl  0x10(%ebp)
  801cc3:	ff 75 0c             	pushl  0xc(%ebp)
  801cc6:	52                   	push   %edx
  801cc7:	ff d0                	call   *%eax
  801cc9:	89 c2                	mov    %eax,%edx
  801ccb:	83 c4 10             	add    $0x10,%esp
  801cce:	eb 09                	jmp    801cd9 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cd0:	89 c2                	mov    %eax,%edx
  801cd2:	eb 05                	jmp    801cd9 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801cd4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801cd9:	89 d0                	mov    %edx,%eax
  801cdb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cde:	c9                   	leave  
  801cdf:	c3                   	ret    

00801ce0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	57                   	push   %edi
  801ce4:	56                   	push   %esi
  801ce5:	53                   	push   %ebx
  801ce6:	83 ec 0c             	sub    $0xc,%esp
  801ce9:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cec:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801cef:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cf4:	eb 21                	jmp    801d17 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801cf6:	83 ec 04             	sub    $0x4,%esp
  801cf9:	89 f0                	mov    %esi,%eax
  801cfb:	29 d8                	sub    %ebx,%eax
  801cfd:	50                   	push   %eax
  801cfe:	89 d8                	mov    %ebx,%eax
  801d00:	03 45 0c             	add    0xc(%ebp),%eax
  801d03:	50                   	push   %eax
  801d04:	57                   	push   %edi
  801d05:	e8 45 ff ff ff       	call   801c4f <read>
		if (m < 0)
  801d0a:	83 c4 10             	add    $0x10,%esp
  801d0d:	85 c0                	test   %eax,%eax
  801d0f:	78 10                	js     801d21 <readn+0x41>
			return m;
		if (m == 0)
  801d11:	85 c0                	test   %eax,%eax
  801d13:	74 0a                	je     801d1f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801d15:	01 c3                	add    %eax,%ebx
  801d17:	39 f3                	cmp    %esi,%ebx
  801d19:	72 db                	jb     801cf6 <readn+0x16>
  801d1b:	89 d8                	mov    %ebx,%eax
  801d1d:	eb 02                	jmp    801d21 <readn+0x41>
  801d1f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801d21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d24:	5b                   	pop    %ebx
  801d25:	5e                   	pop    %esi
  801d26:	5f                   	pop    %edi
  801d27:	5d                   	pop    %ebp
  801d28:	c3                   	ret    

00801d29 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801d29:	55                   	push   %ebp
  801d2a:	89 e5                	mov    %esp,%ebp
  801d2c:	53                   	push   %ebx
  801d2d:	83 ec 14             	sub    $0x14,%esp
  801d30:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d33:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d36:	50                   	push   %eax
  801d37:	53                   	push   %ebx
  801d38:	e8 ac fc ff ff       	call   8019e9 <fd_lookup>
  801d3d:	83 c4 08             	add    $0x8,%esp
  801d40:	89 c2                	mov    %eax,%edx
  801d42:	85 c0                	test   %eax,%eax
  801d44:	78 68                	js     801dae <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d46:	83 ec 08             	sub    $0x8,%esp
  801d49:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d4c:	50                   	push   %eax
  801d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d50:	ff 30                	pushl  (%eax)
  801d52:	e8 e8 fc ff ff       	call   801a3f <dev_lookup>
  801d57:	83 c4 10             	add    $0x10,%esp
  801d5a:	85 c0                	test   %eax,%eax
  801d5c:	78 47                	js     801da5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801d5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d61:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801d65:	75 21                	jne    801d88 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801d67:	a1 20 50 80 00       	mov    0x805020,%eax
  801d6c:	8b 40 48             	mov    0x48(%eax),%eax
  801d6f:	83 ec 04             	sub    $0x4,%esp
  801d72:	53                   	push   %ebx
  801d73:	50                   	push   %eax
  801d74:	68 84 34 80 00       	push   $0x803484
  801d79:	e8 ed eb ff ff       	call   80096b <cprintf>
		return -E_INVAL;
  801d7e:	83 c4 10             	add    $0x10,%esp
  801d81:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801d86:	eb 26                	jmp    801dae <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801d88:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d8b:	8b 52 0c             	mov    0xc(%edx),%edx
  801d8e:	85 d2                	test   %edx,%edx
  801d90:	74 17                	je     801da9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801d92:	83 ec 04             	sub    $0x4,%esp
  801d95:	ff 75 10             	pushl  0x10(%ebp)
  801d98:	ff 75 0c             	pushl  0xc(%ebp)
  801d9b:	50                   	push   %eax
  801d9c:	ff d2                	call   *%edx
  801d9e:	89 c2                	mov    %eax,%edx
  801da0:	83 c4 10             	add    $0x10,%esp
  801da3:	eb 09                	jmp    801dae <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801da5:	89 c2                	mov    %eax,%edx
  801da7:	eb 05                	jmp    801dae <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801da9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801dae:	89 d0                	mov    %edx,%eax
  801db0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801db3:	c9                   	leave  
  801db4:	c3                   	ret    

00801db5 <seek>:

int
seek(int fdnum, off_t offset)
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dbb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801dbe:	50                   	push   %eax
  801dbf:	ff 75 08             	pushl  0x8(%ebp)
  801dc2:	e8 22 fc ff ff       	call   8019e9 <fd_lookup>
  801dc7:	83 c4 08             	add    $0x8,%esp
  801dca:	85 c0                	test   %eax,%eax
  801dcc:	78 0e                	js     801ddc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801dce:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801dd1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dd4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801dd7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ddc:	c9                   	leave  
  801ddd:	c3                   	ret    

00801dde <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801dde:	55                   	push   %ebp
  801ddf:	89 e5                	mov    %esp,%ebp
  801de1:	53                   	push   %ebx
  801de2:	83 ec 14             	sub    $0x14,%esp
  801de5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801de8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801deb:	50                   	push   %eax
  801dec:	53                   	push   %ebx
  801ded:	e8 f7 fb ff ff       	call   8019e9 <fd_lookup>
  801df2:	83 c4 08             	add    $0x8,%esp
  801df5:	89 c2                	mov    %eax,%edx
  801df7:	85 c0                	test   %eax,%eax
  801df9:	78 65                	js     801e60 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801dfb:	83 ec 08             	sub    $0x8,%esp
  801dfe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e01:	50                   	push   %eax
  801e02:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e05:	ff 30                	pushl  (%eax)
  801e07:	e8 33 fc ff ff       	call   801a3f <dev_lookup>
  801e0c:	83 c4 10             	add    $0x10,%esp
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	78 44                	js     801e57 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801e13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e16:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801e1a:	75 21                	jne    801e3d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801e1c:	a1 20 50 80 00       	mov    0x805020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801e21:	8b 40 48             	mov    0x48(%eax),%eax
  801e24:	83 ec 04             	sub    $0x4,%esp
  801e27:	53                   	push   %ebx
  801e28:	50                   	push   %eax
  801e29:	68 44 34 80 00       	push   $0x803444
  801e2e:	e8 38 eb ff ff       	call   80096b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801e33:	83 c4 10             	add    $0x10,%esp
  801e36:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801e3b:	eb 23                	jmp    801e60 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801e3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e40:	8b 52 18             	mov    0x18(%edx),%edx
  801e43:	85 d2                	test   %edx,%edx
  801e45:	74 14                	je     801e5b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801e47:	83 ec 08             	sub    $0x8,%esp
  801e4a:	ff 75 0c             	pushl  0xc(%ebp)
  801e4d:	50                   	push   %eax
  801e4e:	ff d2                	call   *%edx
  801e50:	89 c2                	mov    %eax,%edx
  801e52:	83 c4 10             	add    $0x10,%esp
  801e55:	eb 09                	jmp    801e60 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e57:	89 c2                	mov    %eax,%edx
  801e59:	eb 05                	jmp    801e60 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801e5b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801e60:	89 d0                	mov    %edx,%eax
  801e62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e65:	c9                   	leave  
  801e66:	c3                   	ret    

00801e67 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	53                   	push   %ebx
  801e6b:	83 ec 14             	sub    $0x14,%esp
  801e6e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e71:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e74:	50                   	push   %eax
  801e75:	ff 75 08             	pushl  0x8(%ebp)
  801e78:	e8 6c fb ff ff       	call   8019e9 <fd_lookup>
  801e7d:	83 c4 08             	add    $0x8,%esp
  801e80:	89 c2                	mov    %eax,%edx
  801e82:	85 c0                	test   %eax,%eax
  801e84:	78 58                	js     801ede <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e86:	83 ec 08             	sub    $0x8,%esp
  801e89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e8c:	50                   	push   %eax
  801e8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e90:	ff 30                	pushl  (%eax)
  801e92:	e8 a8 fb ff ff       	call   801a3f <dev_lookup>
  801e97:	83 c4 10             	add    $0x10,%esp
  801e9a:	85 c0                	test   %eax,%eax
  801e9c:	78 37                	js     801ed5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801ea5:	74 32                	je     801ed9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801ea7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801eaa:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801eb1:	00 00 00 
	stat->st_isdir = 0;
  801eb4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ebb:	00 00 00 
	stat->st_dev = dev;
  801ebe:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801ec4:	83 ec 08             	sub    $0x8,%esp
  801ec7:	53                   	push   %ebx
  801ec8:	ff 75 f0             	pushl  -0x10(%ebp)
  801ecb:	ff 50 14             	call   *0x14(%eax)
  801ece:	89 c2                	mov    %eax,%edx
  801ed0:	83 c4 10             	add    $0x10,%esp
  801ed3:	eb 09                	jmp    801ede <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ed5:	89 c2                	mov    %eax,%edx
  801ed7:	eb 05                	jmp    801ede <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801ed9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801ede:	89 d0                	mov    %edx,%eax
  801ee0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ee3:	c9                   	leave  
  801ee4:	c3                   	ret    

00801ee5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801ee5:	55                   	push   %ebp
  801ee6:	89 e5                	mov    %esp,%ebp
  801ee8:	56                   	push   %esi
  801ee9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801eea:	83 ec 08             	sub    $0x8,%esp
  801eed:	6a 00                	push   $0x0
  801eef:	ff 75 08             	pushl  0x8(%ebp)
  801ef2:	e8 0c 02 00 00       	call   802103 <open>
  801ef7:	89 c3                	mov    %eax,%ebx
  801ef9:	83 c4 10             	add    $0x10,%esp
  801efc:	85 c0                	test   %eax,%eax
  801efe:	78 1b                	js     801f1b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801f00:	83 ec 08             	sub    $0x8,%esp
  801f03:	ff 75 0c             	pushl  0xc(%ebp)
  801f06:	50                   	push   %eax
  801f07:	e8 5b ff ff ff       	call   801e67 <fstat>
  801f0c:	89 c6                	mov    %eax,%esi
	close(fd);
  801f0e:	89 1c 24             	mov    %ebx,(%esp)
  801f11:	e8 fd fb ff ff       	call   801b13 <close>
	return r;
  801f16:	83 c4 10             	add    $0x10,%esp
  801f19:	89 f0                	mov    %esi,%eax
}
  801f1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f1e:	5b                   	pop    %ebx
  801f1f:	5e                   	pop    %esi
  801f20:	5d                   	pop    %ebp
  801f21:	c3                   	ret    

00801f22 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801f22:	55                   	push   %ebp
  801f23:	89 e5                	mov    %esp,%ebp
  801f25:	56                   	push   %esi
  801f26:	53                   	push   %ebx
  801f27:	89 c6                	mov    %eax,%esi
  801f29:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801f2b:	83 3d 18 50 80 00 00 	cmpl   $0x0,0x805018
  801f32:	75 12                	jne    801f46 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801f34:	83 ec 0c             	sub    $0xc,%esp
  801f37:	6a 01                	push   $0x1
  801f39:	e8 fc f9 ff ff       	call   80193a <ipc_find_env>
  801f3e:	a3 18 50 80 00       	mov    %eax,0x805018
  801f43:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801f46:	6a 07                	push   $0x7
  801f48:	68 00 60 80 00       	push   $0x806000
  801f4d:	56                   	push   %esi
  801f4e:	ff 35 18 50 80 00    	pushl  0x805018
  801f54:	e8 8d f9 ff ff       	call   8018e6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801f59:	83 c4 0c             	add    $0xc,%esp
  801f5c:	6a 00                	push   $0x0
  801f5e:	53                   	push   %ebx
  801f5f:	6a 00                	push   $0x0
  801f61:	e8 17 f9 ff ff       	call   80187d <ipc_recv>
}
  801f66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f69:	5b                   	pop    %ebx
  801f6a:	5e                   	pop    %esi
  801f6b:	5d                   	pop    %ebp
  801f6c:	c3                   	ret    

00801f6d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801f6d:	55                   	push   %ebp
  801f6e:	89 e5                	mov    %esp,%ebp
  801f70:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801f73:	8b 45 08             	mov    0x8(%ebp),%eax
  801f76:	8b 40 0c             	mov    0xc(%eax),%eax
  801f79:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801f7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f81:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801f86:	ba 00 00 00 00       	mov    $0x0,%edx
  801f8b:	b8 02 00 00 00       	mov    $0x2,%eax
  801f90:	e8 8d ff ff ff       	call   801f22 <fsipc>
}
  801f95:	c9                   	leave  
  801f96:	c3                   	ret    

00801f97 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801f97:	55                   	push   %ebp
  801f98:	89 e5                	mov    %esp,%ebp
  801f9a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801f9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa0:	8b 40 0c             	mov    0xc(%eax),%eax
  801fa3:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801fa8:	ba 00 00 00 00       	mov    $0x0,%edx
  801fad:	b8 06 00 00 00       	mov    $0x6,%eax
  801fb2:	e8 6b ff ff ff       	call   801f22 <fsipc>
}
  801fb7:	c9                   	leave  
  801fb8:	c3                   	ret    

00801fb9 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801fb9:	55                   	push   %ebp
  801fba:	89 e5                	mov    %esp,%ebp
  801fbc:	53                   	push   %ebx
  801fbd:	83 ec 04             	sub    $0x4,%esp
  801fc0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801fc3:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc6:	8b 40 0c             	mov    0xc(%eax),%eax
  801fc9:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801fce:	ba 00 00 00 00       	mov    $0x0,%edx
  801fd3:	b8 05 00 00 00       	mov    $0x5,%eax
  801fd8:	e8 45 ff ff ff       	call   801f22 <fsipc>
  801fdd:	85 c0                	test   %eax,%eax
  801fdf:	78 2c                	js     80200d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801fe1:	83 ec 08             	sub    $0x8,%esp
  801fe4:	68 00 60 80 00       	push   $0x806000
  801fe9:	53                   	push   %ebx
  801fea:	e8 01 ef ff ff       	call   800ef0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801fef:	a1 80 60 80 00       	mov    0x806080,%eax
  801ff4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ffa:	a1 84 60 80 00       	mov    0x806084,%eax
  801fff:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802005:	83 c4 10             	add    $0x10,%esp
  802008:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80200d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802010:	c9                   	leave  
  802011:	c3                   	ret    

00802012 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802012:	55                   	push   %ebp
  802013:	89 e5                	mov    %esp,%ebp
  802015:	53                   	push   %ebx
  802016:	83 ec 08             	sub    $0x8,%esp
  802019:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80201c:	8b 55 08             	mov    0x8(%ebp),%edx
  80201f:	8b 52 0c             	mov    0xc(%edx),%edx
  802022:	89 15 00 60 80 00    	mov    %edx,0x806000
  802028:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80202d:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  802032:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  802035:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  80203b:	53                   	push   %ebx
  80203c:	ff 75 0c             	pushl  0xc(%ebp)
  80203f:	68 08 60 80 00       	push   $0x806008
  802044:	e8 39 f0 ff ff       	call   801082 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  802049:	ba 00 00 00 00       	mov    $0x0,%edx
  80204e:	b8 04 00 00 00       	mov    $0x4,%eax
  802053:	e8 ca fe ff ff       	call   801f22 <fsipc>
  802058:	83 c4 10             	add    $0x10,%esp
  80205b:	85 c0                	test   %eax,%eax
  80205d:	78 1d                	js     80207c <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  80205f:	39 d8                	cmp    %ebx,%eax
  802061:	76 19                	jbe    80207c <devfile_write+0x6a>
  802063:	68 b8 34 80 00       	push   $0x8034b8
  802068:	68 c4 34 80 00       	push   $0x8034c4
  80206d:	68 a5 00 00 00       	push   $0xa5
  802072:	68 d9 34 80 00       	push   $0x8034d9
  802077:	e8 16 e8 ff ff       	call   800892 <_panic>
	return r;
}
  80207c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80207f:	c9                   	leave  
  802080:	c3                   	ret    

00802081 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802081:	55                   	push   %ebp
  802082:	89 e5                	mov    %esp,%ebp
  802084:	56                   	push   %esi
  802085:	53                   	push   %ebx
  802086:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802089:	8b 45 08             	mov    0x8(%ebp),%eax
  80208c:	8b 40 0c             	mov    0xc(%eax),%eax
  80208f:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  802094:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80209a:	ba 00 00 00 00       	mov    $0x0,%edx
  80209f:	b8 03 00 00 00       	mov    $0x3,%eax
  8020a4:	e8 79 fe ff ff       	call   801f22 <fsipc>
  8020a9:	89 c3                	mov    %eax,%ebx
  8020ab:	85 c0                	test   %eax,%eax
  8020ad:	78 4b                	js     8020fa <devfile_read+0x79>
		return r;
	assert(r <= n);
  8020af:	39 c6                	cmp    %eax,%esi
  8020b1:	73 16                	jae    8020c9 <devfile_read+0x48>
  8020b3:	68 e4 34 80 00       	push   $0x8034e4
  8020b8:	68 c4 34 80 00       	push   $0x8034c4
  8020bd:	6a 7c                	push   $0x7c
  8020bf:	68 d9 34 80 00       	push   $0x8034d9
  8020c4:	e8 c9 e7 ff ff       	call   800892 <_panic>
	assert(r <= PGSIZE);
  8020c9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8020ce:	7e 16                	jle    8020e6 <devfile_read+0x65>
  8020d0:	68 eb 34 80 00       	push   $0x8034eb
  8020d5:	68 c4 34 80 00       	push   $0x8034c4
  8020da:	6a 7d                	push   $0x7d
  8020dc:	68 d9 34 80 00       	push   $0x8034d9
  8020e1:	e8 ac e7 ff ff       	call   800892 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8020e6:	83 ec 04             	sub    $0x4,%esp
  8020e9:	50                   	push   %eax
  8020ea:	68 00 60 80 00       	push   $0x806000
  8020ef:	ff 75 0c             	pushl  0xc(%ebp)
  8020f2:	e8 8b ef ff ff       	call   801082 <memmove>
	return r;
  8020f7:	83 c4 10             	add    $0x10,%esp
}
  8020fa:	89 d8                	mov    %ebx,%eax
  8020fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020ff:	5b                   	pop    %ebx
  802100:	5e                   	pop    %esi
  802101:	5d                   	pop    %ebp
  802102:	c3                   	ret    

00802103 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802103:	55                   	push   %ebp
  802104:	89 e5                	mov    %esp,%ebp
  802106:	53                   	push   %ebx
  802107:	83 ec 20             	sub    $0x20,%esp
  80210a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80210d:	53                   	push   %ebx
  80210e:	e8 a4 ed ff ff       	call   800eb7 <strlen>
  802113:	83 c4 10             	add    $0x10,%esp
  802116:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80211b:	7f 67                	jg     802184 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80211d:	83 ec 0c             	sub    $0xc,%esp
  802120:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802123:	50                   	push   %eax
  802124:	e8 71 f8 ff ff       	call   80199a <fd_alloc>
  802129:	83 c4 10             	add    $0x10,%esp
		return r;
  80212c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80212e:	85 c0                	test   %eax,%eax
  802130:	78 57                	js     802189 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802132:	83 ec 08             	sub    $0x8,%esp
  802135:	53                   	push   %ebx
  802136:	68 00 60 80 00       	push   $0x806000
  80213b:	e8 b0 ed ff ff       	call   800ef0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802140:	8b 45 0c             	mov    0xc(%ebp),%eax
  802143:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802148:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80214b:	b8 01 00 00 00       	mov    $0x1,%eax
  802150:	e8 cd fd ff ff       	call   801f22 <fsipc>
  802155:	89 c3                	mov    %eax,%ebx
  802157:	83 c4 10             	add    $0x10,%esp
  80215a:	85 c0                	test   %eax,%eax
  80215c:	79 14                	jns    802172 <open+0x6f>
		fd_close(fd, 0);
  80215e:	83 ec 08             	sub    $0x8,%esp
  802161:	6a 00                	push   $0x0
  802163:	ff 75 f4             	pushl  -0xc(%ebp)
  802166:	e8 27 f9 ff ff       	call   801a92 <fd_close>
		return r;
  80216b:	83 c4 10             	add    $0x10,%esp
  80216e:	89 da                	mov    %ebx,%edx
  802170:	eb 17                	jmp    802189 <open+0x86>
	}

	return fd2num(fd);
  802172:	83 ec 0c             	sub    $0xc,%esp
  802175:	ff 75 f4             	pushl  -0xc(%ebp)
  802178:	e8 f6 f7 ff ff       	call   801973 <fd2num>
  80217d:	89 c2                	mov    %eax,%edx
  80217f:	83 c4 10             	add    $0x10,%esp
  802182:	eb 05                	jmp    802189 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802184:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802189:	89 d0                	mov    %edx,%eax
  80218b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80218e:	c9                   	leave  
  80218f:	c3                   	ret    

00802190 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802190:	55                   	push   %ebp
  802191:	89 e5                	mov    %esp,%ebp
  802193:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802196:	ba 00 00 00 00       	mov    $0x0,%edx
  80219b:	b8 08 00 00 00       	mov    $0x8,%eax
  8021a0:	e8 7d fd ff ff       	call   801f22 <fsipc>
}
  8021a5:	c9                   	leave  
  8021a6:	c3                   	ret    

008021a7 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8021a7:	55                   	push   %ebp
  8021a8:	89 e5                	mov    %esp,%ebp
  8021aa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8021ad:	68 f7 34 80 00       	push   $0x8034f7
  8021b2:	ff 75 0c             	pushl  0xc(%ebp)
  8021b5:	e8 36 ed ff ff       	call   800ef0 <strcpy>
	return 0;
}
  8021ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8021bf:	c9                   	leave  
  8021c0:	c3                   	ret    

008021c1 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8021c1:	55                   	push   %ebp
  8021c2:	89 e5                	mov    %esp,%ebp
  8021c4:	53                   	push   %ebx
  8021c5:	83 ec 10             	sub    $0x10,%esp
  8021c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8021cb:	53                   	push   %ebx
  8021cc:	e8 92 09 00 00       	call   802b63 <pageref>
  8021d1:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8021d4:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8021d9:	83 f8 01             	cmp    $0x1,%eax
  8021dc:	75 10                	jne    8021ee <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8021de:	83 ec 0c             	sub    $0xc,%esp
  8021e1:	ff 73 0c             	pushl  0xc(%ebx)
  8021e4:	e8 c0 02 00 00       	call   8024a9 <nsipc_close>
  8021e9:	89 c2                	mov    %eax,%edx
  8021eb:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8021ee:	89 d0                	mov    %edx,%eax
  8021f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021f3:	c9                   	leave  
  8021f4:	c3                   	ret    

008021f5 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8021f5:	55                   	push   %ebp
  8021f6:	89 e5                	mov    %esp,%ebp
  8021f8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8021fb:	6a 00                	push   $0x0
  8021fd:	ff 75 10             	pushl  0x10(%ebp)
  802200:	ff 75 0c             	pushl  0xc(%ebp)
  802203:	8b 45 08             	mov    0x8(%ebp),%eax
  802206:	ff 70 0c             	pushl  0xc(%eax)
  802209:	e8 78 03 00 00       	call   802586 <nsipc_send>
}
  80220e:	c9                   	leave  
  80220f:	c3                   	ret    

00802210 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802210:	55                   	push   %ebp
  802211:	89 e5                	mov    %esp,%ebp
  802213:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802216:	6a 00                	push   $0x0
  802218:	ff 75 10             	pushl  0x10(%ebp)
  80221b:	ff 75 0c             	pushl  0xc(%ebp)
  80221e:	8b 45 08             	mov    0x8(%ebp),%eax
  802221:	ff 70 0c             	pushl  0xc(%eax)
  802224:	e8 f1 02 00 00       	call   80251a <nsipc_recv>
}
  802229:	c9                   	leave  
  80222a:	c3                   	ret    

0080222b <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80222b:	55                   	push   %ebp
  80222c:	89 e5                	mov    %esp,%ebp
  80222e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802231:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802234:	52                   	push   %edx
  802235:	50                   	push   %eax
  802236:	e8 ae f7 ff ff       	call   8019e9 <fd_lookup>
  80223b:	83 c4 10             	add    $0x10,%esp
  80223e:	85 c0                	test   %eax,%eax
  802240:	78 17                	js     802259 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802242:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802245:	8b 0d 20 40 80 00    	mov    0x804020,%ecx
  80224b:	39 08                	cmp    %ecx,(%eax)
  80224d:	75 05                	jne    802254 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80224f:	8b 40 0c             	mov    0xc(%eax),%eax
  802252:	eb 05                	jmp    802259 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  802254:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802259:	c9                   	leave  
  80225a:	c3                   	ret    

0080225b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80225b:	55                   	push   %ebp
  80225c:	89 e5                	mov    %esp,%ebp
  80225e:	56                   	push   %esi
  80225f:	53                   	push   %ebx
  802260:	83 ec 1c             	sub    $0x1c,%esp
  802263:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802265:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802268:	50                   	push   %eax
  802269:	e8 2c f7 ff ff       	call   80199a <fd_alloc>
  80226e:	89 c3                	mov    %eax,%ebx
  802270:	83 c4 10             	add    $0x10,%esp
  802273:	85 c0                	test   %eax,%eax
  802275:	78 1b                	js     802292 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802277:	83 ec 04             	sub    $0x4,%esp
  80227a:	68 07 04 00 00       	push   $0x407
  80227f:	ff 75 f4             	pushl  -0xc(%ebp)
  802282:	6a 00                	push   $0x0
  802284:	e8 6a f0 ff ff       	call   8012f3 <sys_page_alloc>
  802289:	89 c3                	mov    %eax,%ebx
  80228b:	83 c4 10             	add    $0x10,%esp
  80228e:	85 c0                	test   %eax,%eax
  802290:	79 10                	jns    8022a2 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  802292:	83 ec 0c             	sub    $0xc,%esp
  802295:	56                   	push   %esi
  802296:	e8 0e 02 00 00       	call   8024a9 <nsipc_close>
		return r;
  80229b:	83 c4 10             	add    $0x10,%esp
  80229e:	89 d8                	mov    %ebx,%eax
  8022a0:	eb 24                	jmp    8022c6 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8022a2:	8b 15 20 40 80 00    	mov    0x804020,%edx
  8022a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ab:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8022ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8022b7:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8022ba:	83 ec 0c             	sub    $0xc,%esp
  8022bd:	50                   	push   %eax
  8022be:	e8 b0 f6 ff ff       	call   801973 <fd2num>
  8022c3:	83 c4 10             	add    $0x10,%esp
}
  8022c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022c9:	5b                   	pop    %ebx
  8022ca:	5e                   	pop    %esi
  8022cb:	5d                   	pop    %ebp
  8022cc:	c3                   	ret    

008022cd <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8022cd:	55                   	push   %ebp
  8022ce:	89 e5                	mov    %esp,%ebp
  8022d0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8022d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d6:	e8 50 ff ff ff       	call   80222b <fd2sockid>
		return r;
  8022db:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8022dd:	85 c0                	test   %eax,%eax
  8022df:	78 1f                	js     802300 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8022e1:	83 ec 04             	sub    $0x4,%esp
  8022e4:	ff 75 10             	pushl  0x10(%ebp)
  8022e7:	ff 75 0c             	pushl  0xc(%ebp)
  8022ea:	50                   	push   %eax
  8022eb:	e8 12 01 00 00       	call   802402 <nsipc_accept>
  8022f0:	83 c4 10             	add    $0x10,%esp
		return r;
  8022f3:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8022f5:	85 c0                	test   %eax,%eax
  8022f7:	78 07                	js     802300 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8022f9:	e8 5d ff ff ff       	call   80225b <alloc_sockfd>
  8022fe:	89 c1                	mov    %eax,%ecx
}
  802300:	89 c8                	mov    %ecx,%eax
  802302:	c9                   	leave  
  802303:	c3                   	ret    

00802304 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802304:	55                   	push   %ebp
  802305:	89 e5                	mov    %esp,%ebp
  802307:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80230a:	8b 45 08             	mov    0x8(%ebp),%eax
  80230d:	e8 19 ff ff ff       	call   80222b <fd2sockid>
  802312:	85 c0                	test   %eax,%eax
  802314:	78 12                	js     802328 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  802316:	83 ec 04             	sub    $0x4,%esp
  802319:	ff 75 10             	pushl  0x10(%ebp)
  80231c:	ff 75 0c             	pushl  0xc(%ebp)
  80231f:	50                   	push   %eax
  802320:	e8 2d 01 00 00       	call   802452 <nsipc_bind>
  802325:	83 c4 10             	add    $0x10,%esp
}
  802328:	c9                   	leave  
  802329:	c3                   	ret    

0080232a <shutdown>:

int
shutdown(int s, int how)
{
  80232a:	55                   	push   %ebp
  80232b:	89 e5                	mov    %esp,%ebp
  80232d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802330:	8b 45 08             	mov    0x8(%ebp),%eax
  802333:	e8 f3 fe ff ff       	call   80222b <fd2sockid>
  802338:	85 c0                	test   %eax,%eax
  80233a:	78 0f                	js     80234b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80233c:	83 ec 08             	sub    $0x8,%esp
  80233f:	ff 75 0c             	pushl  0xc(%ebp)
  802342:	50                   	push   %eax
  802343:	e8 3f 01 00 00       	call   802487 <nsipc_shutdown>
  802348:	83 c4 10             	add    $0x10,%esp
}
  80234b:	c9                   	leave  
  80234c:	c3                   	ret    

0080234d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80234d:	55                   	push   %ebp
  80234e:	89 e5                	mov    %esp,%ebp
  802350:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802353:	8b 45 08             	mov    0x8(%ebp),%eax
  802356:	e8 d0 fe ff ff       	call   80222b <fd2sockid>
  80235b:	85 c0                	test   %eax,%eax
  80235d:	78 12                	js     802371 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80235f:	83 ec 04             	sub    $0x4,%esp
  802362:	ff 75 10             	pushl  0x10(%ebp)
  802365:	ff 75 0c             	pushl  0xc(%ebp)
  802368:	50                   	push   %eax
  802369:	e8 55 01 00 00       	call   8024c3 <nsipc_connect>
  80236e:	83 c4 10             	add    $0x10,%esp
}
  802371:	c9                   	leave  
  802372:	c3                   	ret    

00802373 <listen>:

int
listen(int s, int backlog)
{
  802373:	55                   	push   %ebp
  802374:	89 e5                	mov    %esp,%ebp
  802376:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802379:	8b 45 08             	mov    0x8(%ebp),%eax
  80237c:	e8 aa fe ff ff       	call   80222b <fd2sockid>
  802381:	85 c0                	test   %eax,%eax
  802383:	78 0f                	js     802394 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802385:	83 ec 08             	sub    $0x8,%esp
  802388:	ff 75 0c             	pushl  0xc(%ebp)
  80238b:	50                   	push   %eax
  80238c:	e8 67 01 00 00       	call   8024f8 <nsipc_listen>
  802391:	83 c4 10             	add    $0x10,%esp
}
  802394:	c9                   	leave  
  802395:	c3                   	ret    

00802396 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802396:	55                   	push   %ebp
  802397:	89 e5                	mov    %esp,%ebp
  802399:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80239c:	ff 75 10             	pushl  0x10(%ebp)
  80239f:	ff 75 0c             	pushl  0xc(%ebp)
  8023a2:	ff 75 08             	pushl  0x8(%ebp)
  8023a5:	e8 3a 02 00 00       	call   8025e4 <nsipc_socket>
  8023aa:	83 c4 10             	add    $0x10,%esp
  8023ad:	85 c0                	test   %eax,%eax
  8023af:	78 05                	js     8023b6 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8023b1:	e8 a5 fe ff ff       	call   80225b <alloc_sockfd>
}
  8023b6:	c9                   	leave  
  8023b7:	c3                   	ret    

008023b8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8023b8:	55                   	push   %ebp
  8023b9:	89 e5                	mov    %esp,%ebp
  8023bb:	53                   	push   %ebx
  8023bc:	83 ec 04             	sub    $0x4,%esp
  8023bf:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8023c1:	83 3d 1c 50 80 00 00 	cmpl   $0x0,0x80501c
  8023c8:	75 12                	jne    8023dc <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8023ca:	83 ec 0c             	sub    $0xc,%esp
  8023cd:	6a 02                	push   $0x2
  8023cf:	e8 66 f5 ff ff       	call   80193a <ipc_find_env>
  8023d4:	a3 1c 50 80 00       	mov    %eax,0x80501c
  8023d9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8023dc:	6a 07                	push   $0x7
  8023de:	68 00 70 80 00       	push   $0x807000
  8023e3:	53                   	push   %ebx
  8023e4:	ff 35 1c 50 80 00    	pushl  0x80501c
  8023ea:	e8 f7 f4 ff ff       	call   8018e6 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8023ef:	83 c4 0c             	add    $0xc,%esp
  8023f2:	6a 00                	push   $0x0
  8023f4:	6a 00                	push   $0x0
  8023f6:	6a 00                	push   $0x0
  8023f8:	e8 80 f4 ff ff       	call   80187d <ipc_recv>
}
  8023fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802400:	c9                   	leave  
  802401:	c3                   	ret    

00802402 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802402:	55                   	push   %ebp
  802403:	89 e5                	mov    %esp,%ebp
  802405:	56                   	push   %esi
  802406:	53                   	push   %ebx
  802407:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80240a:	8b 45 08             	mov    0x8(%ebp),%eax
  80240d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802412:	8b 06                	mov    (%esi),%eax
  802414:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802419:	b8 01 00 00 00       	mov    $0x1,%eax
  80241e:	e8 95 ff ff ff       	call   8023b8 <nsipc>
  802423:	89 c3                	mov    %eax,%ebx
  802425:	85 c0                	test   %eax,%eax
  802427:	78 20                	js     802449 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802429:	83 ec 04             	sub    $0x4,%esp
  80242c:	ff 35 10 70 80 00    	pushl  0x807010
  802432:	68 00 70 80 00       	push   $0x807000
  802437:	ff 75 0c             	pushl  0xc(%ebp)
  80243a:	e8 43 ec ff ff       	call   801082 <memmove>
		*addrlen = ret->ret_addrlen;
  80243f:	a1 10 70 80 00       	mov    0x807010,%eax
  802444:	89 06                	mov    %eax,(%esi)
  802446:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802449:	89 d8                	mov    %ebx,%eax
  80244b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80244e:	5b                   	pop    %ebx
  80244f:	5e                   	pop    %esi
  802450:	5d                   	pop    %ebp
  802451:	c3                   	ret    

00802452 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802452:	55                   	push   %ebp
  802453:	89 e5                	mov    %esp,%ebp
  802455:	53                   	push   %ebx
  802456:	83 ec 08             	sub    $0x8,%esp
  802459:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80245c:	8b 45 08             	mov    0x8(%ebp),%eax
  80245f:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802464:	53                   	push   %ebx
  802465:	ff 75 0c             	pushl  0xc(%ebp)
  802468:	68 04 70 80 00       	push   $0x807004
  80246d:	e8 10 ec ff ff       	call   801082 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802472:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802478:	b8 02 00 00 00       	mov    $0x2,%eax
  80247d:	e8 36 ff ff ff       	call   8023b8 <nsipc>
}
  802482:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802485:	c9                   	leave  
  802486:	c3                   	ret    

00802487 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802487:	55                   	push   %ebp
  802488:	89 e5                	mov    %esp,%ebp
  80248a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80248d:	8b 45 08             	mov    0x8(%ebp),%eax
  802490:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802495:	8b 45 0c             	mov    0xc(%ebp),%eax
  802498:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  80249d:	b8 03 00 00 00       	mov    $0x3,%eax
  8024a2:	e8 11 ff ff ff       	call   8023b8 <nsipc>
}
  8024a7:	c9                   	leave  
  8024a8:	c3                   	ret    

008024a9 <nsipc_close>:

int
nsipc_close(int s)
{
  8024a9:	55                   	push   %ebp
  8024aa:	89 e5                	mov    %esp,%ebp
  8024ac:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8024af:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b2:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8024b7:	b8 04 00 00 00       	mov    $0x4,%eax
  8024bc:	e8 f7 fe ff ff       	call   8023b8 <nsipc>
}
  8024c1:	c9                   	leave  
  8024c2:	c3                   	ret    

008024c3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8024c3:	55                   	push   %ebp
  8024c4:	89 e5                	mov    %esp,%ebp
  8024c6:	53                   	push   %ebx
  8024c7:	83 ec 08             	sub    $0x8,%esp
  8024ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8024cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8024d0:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8024d5:	53                   	push   %ebx
  8024d6:	ff 75 0c             	pushl  0xc(%ebp)
  8024d9:	68 04 70 80 00       	push   $0x807004
  8024de:	e8 9f eb ff ff       	call   801082 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8024e3:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8024e9:	b8 05 00 00 00       	mov    $0x5,%eax
  8024ee:	e8 c5 fe ff ff       	call   8023b8 <nsipc>
}
  8024f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024f6:	c9                   	leave  
  8024f7:	c3                   	ret    

008024f8 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8024f8:	55                   	push   %ebp
  8024f9:	89 e5                	mov    %esp,%ebp
  8024fb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8024fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802501:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802506:	8b 45 0c             	mov    0xc(%ebp),%eax
  802509:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80250e:	b8 06 00 00 00       	mov    $0x6,%eax
  802513:	e8 a0 fe ff ff       	call   8023b8 <nsipc>
}
  802518:	c9                   	leave  
  802519:	c3                   	ret    

0080251a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80251a:	55                   	push   %ebp
  80251b:	89 e5                	mov    %esp,%ebp
  80251d:	56                   	push   %esi
  80251e:	53                   	push   %ebx
  80251f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802522:	8b 45 08             	mov    0x8(%ebp),%eax
  802525:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80252a:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802530:	8b 45 14             	mov    0x14(%ebp),%eax
  802533:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802538:	b8 07 00 00 00       	mov    $0x7,%eax
  80253d:	e8 76 fe ff ff       	call   8023b8 <nsipc>
  802542:	89 c3                	mov    %eax,%ebx
  802544:	85 c0                	test   %eax,%eax
  802546:	78 35                	js     80257d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802548:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80254d:	7f 04                	jg     802553 <nsipc_recv+0x39>
  80254f:	39 c6                	cmp    %eax,%esi
  802551:	7d 16                	jge    802569 <nsipc_recv+0x4f>
  802553:	68 03 35 80 00       	push   $0x803503
  802558:	68 c4 34 80 00       	push   $0x8034c4
  80255d:	6a 62                	push   $0x62
  80255f:	68 18 35 80 00       	push   $0x803518
  802564:	e8 29 e3 ff ff       	call   800892 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802569:	83 ec 04             	sub    $0x4,%esp
  80256c:	50                   	push   %eax
  80256d:	68 00 70 80 00       	push   $0x807000
  802572:	ff 75 0c             	pushl  0xc(%ebp)
  802575:	e8 08 eb ff ff       	call   801082 <memmove>
  80257a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80257d:	89 d8                	mov    %ebx,%eax
  80257f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802582:	5b                   	pop    %ebx
  802583:	5e                   	pop    %esi
  802584:	5d                   	pop    %ebp
  802585:	c3                   	ret    

00802586 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802586:	55                   	push   %ebp
  802587:	89 e5                	mov    %esp,%ebp
  802589:	53                   	push   %ebx
  80258a:	83 ec 04             	sub    $0x4,%esp
  80258d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802590:	8b 45 08             	mov    0x8(%ebp),%eax
  802593:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802598:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80259e:	7e 16                	jle    8025b6 <nsipc_send+0x30>
  8025a0:	68 24 35 80 00       	push   $0x803524
  8025a5:	68 c4 34 80 00       	push   $0x8034c4
  8025aa:	6a 6d                	push   $0x6d
  8025ac:	68 18 35 80 00       	push   $0x803518
  8025b1:	e8 dc e2 ff ff       	call   800892 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8025b6:	83 ec 04             	sub    $0x4,%esp
  8025b9:	53                   	push   %ebx
  8025ba:	ff 75 0c             	pushl  0xc(%ebp)
  8025bd:	68 0c 70 80 00       	push   $0x80700c
  8025c2:	e8 bb ea ff ff       	call   801082 <memmove>
	nsipcbuf.send.req_size = size;
  8025c7:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8025cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8025d0:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8025d5:	b8 08 00 00 00       	mov    $0x8,%eax
  8025da:	e8 d9 fd ff ff       	call   8023b8 <nsipc>
}
  8025df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8025e2:	c9                   	leave  
  8025e3:	c3                   	ret    

008025e4 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8025e4:	55                   	push   %ebp
  8025e5:	89 e5                	mov    %esp,%ebp
  8025e7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8025ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8025ed:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8025f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025f5:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8025fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8025fd:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802602:	b8 09 00 00 00       	mov    $0x9,%eax
  802607:	e8 ac fd ff ff       	call   8023b8 <nsipc>
}
  80260c:	c9                   	leave  
  80260d:	c3                   	ret    

0080260e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80260e:	55                   	push   %ebp
  80260f:	89 e5                	mov    %esp,%ebp
  802611:	56                   	push   %esi
  802612:	53                   	push   %ebx
  802613:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802616:	83 ec 0c             	sub    $0xc,%esp
  802619:	ff 75 08             	pushl  0x8(%ebp)
  80261c:	e8 62 f3 ff ff       	call   801983 <fd2data>
  802621:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802623:	83 c4 08             	add    $0x8,%esp
  802626:	68 30 35 80 00       	push   $0x803530
  80262b:	53                   	push   %ebx
  80262c:	e8 bf e8 ff ff       	call   800ef0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802631:	8b 46 04             	mov    0x4(%esi),%eax
  802634:	2b 06                	sub    (%esi),%eax
  802636:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80263c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802643:	00 00 00 
	stat->st_dev = &devpipe;
  802646:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  80264d:	40 80 00 
	return 0;
}
  802650:	b8 00 00 00 00       	mov    $0x0,%eax
  802655:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802658:	5b                   	pop    %ebx
  802659:	5e                   	pop    %esi
  80265a:	5d                   	pop    %ebp
  80265b:	c3                   	ret    

0080265c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80265c:	55                   	push   %ebp
  80265d:	89 e5                	mov    %esp,%ebp
  80265f:	53                   	push   %ebx
  802660:	83 ec 0c             	sub    $0xc,%esp
  802663:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802666:	53                   	push   %ebx
  802667:	6a 00                	push   $0x0
  802669:	e8 0a ed ff ff       	call   801378 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80266e:	89 1c 24             	mov    %ebx,(%esp)
  802671:	e8 0d f3 ff ff       	call   801983 <fd2data>
  802676:	83 c4 08             	add    $0x8,%esp
  802679:	50                   	push   %eax
  80267a:	6a 00                	push   $0x0
  80267c:	e8 f7 ec ff ff       	call   801378 <sys_page_unmap>
}
  802681:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802684:	c9                   	leave  
  802685:	c3                   	ret    

00802686 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802686:	55                   	push   %ebp
  802687:	89 e5                	mov    %esp,%ebp
  802689:	57                   	push   %edi
  80268a:	56                   	push   %esi
  80268b:	53                   	push   %ebx
  80268c:	83 ec 1c             	sub    $0x1c,%esp
  80268f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802692:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802694:	a1 20 50 80 00       	mov    0x805020,%eax
  802699:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80269c:	83 ec 0c             	sub    $0xc,%esp
  80269f:	ff 75 e0             	pushl  -0x20(%ebp)
  8026a2:	e8 bc 04 00 00       	call   802b63 <pageref>
  8026a7:	89 c3                	mov    %eax,%ebx
  8026a9:	89 3c 24             	mov    %edi,(%esp)
  8026ac:	e8 b2 04 00 00       	call   802b63 <pageref>
  8026b1:	83 c4 10             	add    $0x10,%esp
  8026b4:	39 c3                	cmp    %eax,%ebx
  8026b6:	0f 94 c1             	sete   %cl
  8026b9:	0f b6 c9             	movzbl %cl,%ecx
  8026bc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8026bf:	8b 15 20 50 80 00    	mov    0x805020,%edx
  8026c5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8026c8:	39 ce                	cmp    %ecx,%esi
  8026ca:	74 1b                	je     8026e7 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8026cc:	39 c3                	cmp    %eax,%ebx
  8026ce:	75 c4                	jne    802694 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8026d0:	8b 42 58             	mov    0x58(%edx),%eax
  8026d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8026d6:	50                   	push   %eax
  8026d7:	56                   	push   %esi
  8026d8:	68 37 35 80 00       	push   $0x803537
  8026dd:	e8 89 e2 ff ff       	call   80096b <cprintf>
  8026e2:	83 c4 10             	add    $0x10,%esp
  8026e5:	eb ad                	jmp    802694 <_pipeisclosed+0xe>
	}
}
  8026e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8026ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026ed:	5b                   	pop    %ebx
  8026ee:	5e                   	pop    %esi
  8026ef:	5f                   	pop    %edi
  8026f0:	5d                   	pop    %ebp
  8026f1:	c3                   	ret    

008026f2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8026f2:	55                   	push   %ebp
  8026f3:	89 e5                	mov    %esp,%ebp
  8026f5:	57                   	push   %edi
  8026f6:	56                   	push   %esi
  8026f7:	53                   	push   %ebx
  8026f8:	83 ec 28             	sub    $0x28,%esp
  8026fb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8026fe:	56                   	push   %esi
  8026ff:	e8 7f f2 ff ff       	call   801983 <fd2data>
  802704:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802706:	83 c4 10             	add    $0x10,%esp
  802709:	bf 00 00 00 00       	mov    $0x0,%edi
  80270e:	eb 4b                	jmp    80275b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802710:	89 da                	mov    %ebx,%edx
  802712:	89 f0                	mov    %esi,%eax
  802714:	e8 6d ff ff ff       	call   802686 <_pipeisclosed>
  802719:	85 c0                	test   %eax,%eax
  80271b:	75 48                	jne    802765 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80271d:	e8 b2 eb ff ff       	call   8012d4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802722:	8b 43 04             	mov    0x4(%ebx),%eax
  802725:	8b 0b                	mov    (%ebx),%ecx
  802727:	8d 51 20             	lea    0x20(%ecx),%edx
  80272a:	39 d0                	cmp    %edx,%eax
  80272c:	73 e2                	jae    802710 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80272e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802731:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802735:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802738:	89 c2                	mov    %eax,%edx
  80273a:	c1 fa 1f             	sar    $0x1f,%edx
  80273d:	89 d1                	mov    %edx,%ecx
  80273f:	c1 e9 1b             	shr    $0x1b,%ecx
  802742:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802745:	83 e2 1f             	and    $0x1f,%edx
  802748:	29 ca                	sub    %ecx,%edx
  80274a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80274e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802752:	83 c0 01             	add    $0x1,%eax
  802755:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802758:	83 c7 01             	add    $0x1,%edi
  80275b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80275e:	75 c2                	jne    802722 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802760:	8b 45 10             	mov    0x10(%ebp),%eax
  802763:	eb 05                	jmp    80276a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802765:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80276a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80276d:	5b                   	pop    %ebx
  80276e:	5e                   	pop    %esi
  80276f:	5f                   	pop    %edi
  802770:	5d                   	pop    %ebp
  802771:	c3                   	ret    

00802772 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802772:	55                   	push   %ebp
  802773:	89 e5                	mov    %esp,%ebp
  802775:	57                   	push   %edi
  802776:	56                   	push   %esi
  802777:	53                   	push   %ebx
  802778:	83 ec 18             	sub    $0x18,%esp
  80277b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80277e:	57                   	push   %edi
  80277f:	e8 ff f1 ff ff       	call   801983 <fd2data>
  802784:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802786:	83 c4 10             	add    $0x10,%esp
  802789:	bb 00 00 00 00       	mov    $0x0,%ebx
  80278e:	eb 3d                	jmp    8027cd <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802790:	85 db                	test   %ebx,%ebx
  802792:	74 04                	je     802798 <devpipe_read+0x26>
				return i;
  802794:	89 d8                	mov    %ebx,%eax
  802796:	eb 44                	jmp    8027dc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802798:	89 f2                	mov    %esi,%edx
  80279a:	89 f8                	mov    %edi,%eax
  80279c:	e8 e5 fe ff ff       	call   802686 <_pipeisclosed>
  8027a1:	85 c0                	test   %eax,%eax
  8027a3:	75 32                	jne    8027d7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8027a5:	e8 2a eb ff ff       	call   8012d4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8027aa:	8b 06                	mov    (%esi),%eax
  8027ac:	3b 46 04             	cmp    0x4(%esi),%eax
  8027af:	74 df                	je     802790 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8027b1:	99                   	cltd   
  8027b2:	c1 ea 1b             	shr    $0x1b,%edx
  8027b5:	01 d0                	add    %edx,%eax
  8027b7:	83 e0 1f             	and    $0x1f,%eax
  8027ba:	29 d0                	sub    %edx,%eax
  8027bc:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8027c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027c4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8027c7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8027ca:	83 c3 01             	add    $0x1,%ebx
  8027cd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8027d0:	75 d8                	jne    8027aa <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8027d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8027d5:	eb 05                	jmp    8027dc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8027d7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8027dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027df:	5b                   	pop    %ebx
  8027e0:	5e                   	pop    %esi
  8027e1:	5f                   	pop    %edi
  8027e2:	5d                   	pop    %ebp
  8027e3:	c3                   	ret    

008027e4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8027e4:	55                   	push   %ebp
  8027e5:	89 e5                	mov    %esp,%ebp
  8027e7:	56                   	push   %esi
  8027e8:	53                   	push   %ebx
  8027e9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8027ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027ef:	50                   	push   %eax
  8027f0:	e8 a5 f1 ff ff       	call   80199a <fd_alloc>
  8027f5:	83 c4 10             	add    $0x10,%esp
  8027f8:	89 c2                	mov    %eax,%edx
  8027fa:	85 c0                	test   %eax,%eax
  8027fc:	0f 88 2c 01 00 00    	js     80292e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802802:	83 ec 04             	sub    $0x4,%esp
  802805:	68 07 04 00 00       	push   $0x407
  80280a:	ff 75 f4             	pushl  -0xc(%ebp)
  80280d:	6a 00                	push   $0x0
  80280f:	e8 df ea ff ff       	call   8012f3 <sys_page_alloc>
  802814:	83 c4 10             	add    $0x10,%esp
  802817:	89 c2                	mov    %eax,%edx
  802819:	85 c0                	test   %eax,%eax
  80281b:	0f 88 0d 01 00 00    	js     80292e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802821:	83 ec 0c             	sub    $0xc,%esp
  802824:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802827:	50                   	push   %eax
  802828:	e8 6d f1 ff ff       	call   80199a <fd_alloc>
  80282d:	89 c3                	mov    %eax,%ebx
  80282f:	83 c4 10             	add    $0x10,%esp
  802832:	85 c0                	test   %eax,%eax
  802834:	0f 88 e2 00 00 00    	js     80291c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80283a:	83 ec 04             	sub    $0x4,%esp
  80283d:	68 07 04 00 00       	push   $0x407
  802842:	ff 75 f0             	pushl  -0x10(%ebp)
  802845:	6a 00                	push   $0x0
  802847:	e8 a7 ea ff ff       	call   8012f3 <sys_page_alloc>
  80284c:	89 c3                	mov    %eax,%ebx
  80284e:	83 c4 10             	add    $0x10,%esp
  802851:	85 c0                	test   %eax,%eax
  802853:	0f 88 c3 00 00 00    	js     80291c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802859:	83 ec 0c             	sub    $0xc,%esp
  80285c:	ff 75 f4             	pushl  -0xc(%ebp)
  80285f:	e8 1f f1 ff ff       	call   801983 <fd2data>
  802864:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802866:	83 c4 0c             	add    $0xc,%esp
  802869:	68 07 04 00 00       	push   $0x407
  80286e:	50                   	push   %eax
  80286f:	6a 00                	push   $0x0
  802871:	e8 7d ea ff ff       	call   8012f3 <sys_page_alloc>
  802876:	89 c3                	mov    %eax,%ebx
  802878:	83 c4 10             	add    $0x10,%esp
  80287b:	85 c0                	test   %eax,%eax
  80287d:	0f 88 89 00 00 00    	js     80290c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802883:	83 ec 0c             	sub    $0xc,%esp
  802886:	ff 75 f0             	pushl  -0x10(%ebp)
  802889:	e8 f5 f0 ff ff       	call   801983 <fd2data>
  80288e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802895:	50                   	push   %eax
  802896:	6a 00                	push   $0x0
  802898:	56                   	push   %esi
  802899:	6a 00                	push   $0x0
  80289b:	e8 96 ea ff ff       	call   801336 <sys_page_map>
  8028a0:	89 c3                	mov    %eax,%ebx
  8028a2:	83 c4 20             	add    $0x20,%esp
  8028a5:	85 c0                	test   %eax,%eax
  8028a7:	78 55                	js     8028fe <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8028a9:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8028af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028b2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8028b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028b7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8028be:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8028c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8028c7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8028c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8028cc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8028d3:	83 ec 0c             	sub    $0xc,%esp
  8028d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8028d9:	e8 95 f0 ff ff       	call   801973 <fd2num>
  8028de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8028e1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8028e3:	83 c4 04             	add    $0x4,%esp
  8028e6:	ff 75 f0             	pushl  -0x10(%ebp)
  8028e9:	e8 85 f0 ff ff       	call   801973 <fd2num>
  8028ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8028f1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8028f4:	83 c4 10             	add    $0x10,%esp
  8028f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8028fc:	eb 30                	jmp    80292e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8028fe:	83 ec 08             	sub    $0x8,%esp
  802901:	56                   	push   %esi
  802902:	6a 00                	push   $0x0
  802904:	e8 6f ea ff ff       	call   801378 <sys_page_unmap>
  802909:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80290c:	83 ec 08             	sub    $0x8,%esp
  80290f:	ff 75 f0             	pushl  -0x10(%ebp)
  802912:	6a 00                	push   $0x0
  802914:	e8 5f ea ff ff       	call   801378 <sys_page_unmap>
  802919:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80291c:	83 ec 08             	sub    $0x8,%esp
  80291f:	ff 75 f4             	pushl  -0xc(%ebp)
  802922:	6a 00                	push   $0x0
  802924:	e8 4f ea ff ff       	call   801378 <sys_page_unmap>
  802929:	83 c4 10             	add    $0x10,%esp
  80292c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80292e:	89 d0                	mov    %edx,%eax
  802930:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802933:	5b                   	pop    %ebx
  802934:	5e                   	pop    %esi
  802935:	5d                   	pop    %ebp
  802936:	c3                   	ret    

00802937 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802937:	55                   	push   %ebp
  802938:	89 e5                	mov    %esp,%ebp
  80293a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80293d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802940:	50                   	push   %eax
  802941:	ff 75 08             	pushl  0x8(%ebp)
  802944:	e8 a0 f0 ff ff       	call   8019e9 <fd_lookup>
  802949:	83 c4 10             	add    $0x10,%esp
  80294c:	85 c0                	test   %eax,%eax
  80294e:	78 18                	js     802968 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802950:	83 ec 0c             	sub    $0xc,%esp
  802953:	ff 75 f4             	pushl  -0xc(%ebp)
  802956:	e8 28 f0 ff ff       	call   801983 <fd2data>
	return _pipeisclosed(fd, p);
  80295b:	89 c2                	mov    %eax,%edx
  80295d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802960:	e8 21 fd ff ff       	call   802686 <_pipeisclosed>
  802965:	83 c4 10             	add    $0x10,%esp
}
  802968:	c9                   	leave  
  802969:	c3                   	ret    

0080296a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80296a:	55                   	push   %ebp
  80296b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80296d:	b8 00 00 00 00       	mov    $0x0,%eax
  802972:	5d                   	pop    %ebp
  802973:	c3                   	ret    

00802974 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802974:	55                   	push   %ebp
  802975:	89 e5                	mov    %esp,%ebp
  802977:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80297a:	68 4f 35 80 00       	push   $0x80354f
  80297f:	ff 75 0c             	pushl  0xc(%ebp)
  802982:	e8 69 e5 ff ff       	call   800ef0 <strcpy>
	return 0;
}
  802987:	b8 00 00 00 00       	mov    $0x0,%eax
  80298c:	c9                   	leave  
  80298d:	c3                   	ret    

0080298e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80298e:	55                   	push   %ebp
  80298f:	89 e5                	mov    %esp,%ebp
  802991:	57                   	push   %edi
  802992:	56                   	push   %esi
  802993:	53                   	push   %ebx
  802994:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80299a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80299f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8029a5:	eb 2d                	jmp    8029d4 <devcons_write+0x46>
		m = n - tot;
  8029a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8029aa:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8029ac:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8029af:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8029b4:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8029b7:	83 ec 04             	sub    $0x4,%esp
  8029ba:	53                   	push   %ebx
  8029bb:	03 45 0c             	add    0xc(%ebp),%eax
  8029be:	50                   	push   %eax
  8029bf:	57                   	push   %edi
  8029c0:	e8 bd e6 ff ff       	call   801082 <memmove>
		sys_cputs(buf, m);
  8029c5:	83 c4 08             	add    $0x8,%esp
  8029c8:	53                   	push   %ebx
  8029c9:	57                   	push   %edi
  8029ca:	e8 68 e8 ff ff       	call   801237 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8029cf:	01 de                	add    %ebx,%esi
  8029d1:	83 c4 10             	add    $0x10,%esp
  8029d4:	89 f0                	mov    %esi,%eax
  8029d6:	3b 75 10             	cmp    0x10(%ebp),%esi
  8029d9:	72 cc                	jb     8029a7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8029db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8029de:	5b                   	pop    %ebx
  8029df:	5e                   	pop    %esi
  8029e0:	5f                   	pop    %edi
  8029e1:	5d                   	pop    %ebp
  8029e2:	c3                   	ret    

008029e3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8029e3:	55                   	push   %ebp
  8029e4:	89 e5                	mov    %esp,%ebp
  8029e6:	83 ec 08             	sub    $0x8,%esp
  8029e9:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8029ee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8029f2:	74 2a                	je     802a1e <devcons_read+0x3b>
  8029f4:	eb 05                	jmp    8029fb <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8029f6:	e8 d9 e8 ff ff       	call   8012d4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8029fb:	e8 55 e8 ff ff       	call   801255 <sys_cgetc>
  802a00:	85 c0                	test   %eax,%eax
  802a02:	74 f2                	je     8029f6 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802a04:	85 c0                	test   %eax,%eax
  802a06:	78 16                	js     802a1e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802a08:	83 f8 04             	cmp    $0x4,%eax
  802a0b:	74 0c                	je     802a19 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802a0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802a10:	88 02                	mov    %al,(%edx)
	return 1;
  802a12:	b8 01 00 00 00       	mov    $0x1,%eax
  802a17:	eb 05                	jmp    802a1e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802a19:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802a1e:	c9                   	leave  
  802a1f:	c3                   	ret    

00802a20 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802a20:	55                   	push   %ebp
  802a21:	89 e5                	mov    %esp,%ebp
  802a23:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802a26:	8b 45 08             	mov    0x8(%ebp),%eax
  802a29:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802a2c:	6a 01                	push   $0x1
  802a2e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802a31:	50                   	push   %eax
  802a32:	e8 00 e8 ff ff       	call   801237 <sys_cputs>
}
  802a37:	83 c4 10             	add    $0x10,%esp
  802a3a:	c9                   	leave  
  802a3b:	c3                   	ret    

00802a3c <getchar>:

int
getchar(void)
{
  802a3c:	55                   	push   %ebp
  802a3d:	89 e5                	mov    %esp,%ebp
  802a3f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802a42:	6a 01                	push   $0x1
  802a44:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802a47:	50                   	push   %eax
  802a48:	6a 00                	push   $0x0
  802a4a:	e8 00 f2 ff ff       	call   801c4f <read>
	if (r < 0)
  802a4f:	83 c4 10             	add    $0x10,%esp
  802a52:	85 c0                	test   %eax,%eax
  802a54:	78 0f                	js     802a65 <getchar+0x29>
		return r;
	if (r < 1)
  802a56:	85 c0                	test   %eax,%eax
  802a58:	7e 06                	jle    802a60 <getchar+0x24>
		return -E_EOF;
	return c;
  802a5a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802a5e:	eb 05                	jmp    802a65 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802a60:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802a65:	c9                   	leave  
  802a66:	c3                   	ret    

00802a67 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802a67:	55                   	push   %ebp
  802a68:	89 e5                	mov    %esp,%ebp
  802a6a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802a6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a70:	50                   	push   %eax
  802a71:	ff 75 08             	pushl  0x8(%ebp)
  802a74:	e8 70 ef ff ff       	call   8019e9 <fd_lookup>
  802a79:	83 c4 10             	add    $0x10,%esp
  802a7c:	85 c0                	test   %eax,%eax
  802a7e:	78 11                	js     802a91 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a83:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802a89:	39 10                	cmp    %edx,(%eax)
  802a8b:	0f 94 c0             	sete   %al
  802a8e:	0f b6 c0             	movzbl %al,%eax
}
  802a91:	c9                   	leave  
  802a92:	c3                   	ret    

00802a93 <opencons>:

int
opencons(void)
{
  802a93:	55                   	push   %ebp
  802a94:	89 e5                	mov    %esp,%ebp
  802a96:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802a99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a9c:	50                   	push   %eax
  802a9d:	e8 f8 ee ff ff       	call   80199a <fd_alloc>
  802aa2:	83 c4 10             	add    $0x10,%esp
		return r;
  802aa5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802aa7:	85 c0                	test   %eax,%eax
  802aa9:	78 3e                	js     802ae9 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802aab:	83 ec 04             	sub    $0x4,%esp
  802aae:	68 07 04 00 00       	push   $0x407
  802ab3:	ff 75 f4             	pushl  -0xc(%ebp)
  802ab6:	6a 00                	push   $0x0
  802ab8:	e8 36 e8 ff ff       	call   8012f3 <sys_page_alloc>
  802abd:	83 c4 10             	add    $0x10,%esp
		return r;
  802ac0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802ac2:	85 c0                	test   %eax,%eax
  802ac4:	78 23                	js     802ae9 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802ac6:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802acf:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ad4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802adb:	83 ec 0c             	sub    $0xc,%esp
  802ade:	50                   	push   %eax
  802adf:	e8 8f ee ff ff       	call   801973 <fd2num>
  802ae4:	89 c2                	mov    %eax,%edx
  802ae6:	83 c4 10             	add    $0x10,%esp
}
  802ae9:	89 d0                	mov    %edx,%eax
  802aeb:	c9                   	leave  
  802aec:	c3                   	ret    

00802aed <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802aed:	55                   	push   %ebp
  802aee:	89 e5                	mov    %esp,%ebp
  802af0:	53                   	push   %ebx
  802af1:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  802af4:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802afb:	75 28                	jne    802b25 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802afd:	e8 b3 e7 ff ff       	call   8012b5 <sys_getenvid>
  802b02:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  802b04:	83 ec 04             	sub    $0x4,%esp
  802b07:	6a 06                	push   $0x6
  802b09:	68 00 f0 bf ee       	push   $0xeebff000
  802b0e:	50                   	push   %eax
  802b0f:	e8 df e7 ff ff       	call   8012f3 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  802b14:	83 c4 08             	add    $0x8,%esp
  802b17:	68 32 2b 80 00       	push   $0x802b32
  802b1c:	53                   	push   %ebx
  802b1d:	e8 1c e9 ff ff       	call   80143e <sys_env_set_pgfault_upcall>
  802b22:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802b25:	8b 45 08             	mov    0x8(%ebp),%eax
  802b28:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802b2d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b30:	c9                   	leave  
  802b31:	c3                   	ret    

00802b32 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802b32:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802b33:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802b38:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802b3a:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  802b3d:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  802b3f:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  802b42:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  802b45:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  802b48:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  802b4b:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  802b4e:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  802b51:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  802b54:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  802b57:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  802b5a:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  802b5d:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  802b60:	61                   	popa   
	popfl
  802b61:	9d                   	popf   
	ret
  802b62:	c3                   	ret    

00802b63 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802b63:	55                   	push   %ebp
  802b64:	89 e5                	mov    %esp,%ebp
  802b66:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802b69:	89 d0                	mov    %edx,%eax
  802b6b:	c1 e8 16             	shr    $0x16,%eax
  802b6e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802b75:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802b7a:	f6 c1 01             	test   $0x1,%cl
  802b7d:	74 1d                	je     802b9c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802b7f:	c1 ea 0c             	shr    $0xc,%edx
  802b82:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802b89:	f6 c2 01             	test   $0x1,%dl
  802b8c:	74 0e                	je     802b9c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802b8e:	c1 ea 0c             	shr    $0xc,%edx
  802b91:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802b98:	ef 
  802b99:	0f b7 c0             	movzwl %ax,%eax
}
  802b9c:	5d                   	pop    %ebp
  802b9d:	c3                   	ret    
  802b9e:	66 90                	xchg   %ax,%ax

00802ba0 <__udivdi3>:
  802ba0:	55                   	push   %ebp
  802ba1:	57                   	push   %edi
  802ba2:	56                   	push   %esi
  802ba3:	53                   	push   %ebx
  802ba4:	83 ec 1c             	sub    $0x1c,%esp
  802ba7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802bab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802baf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802bb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802bb7:	85 f6                	test   %esi,%esi
  802bb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802bbd:	89 ca                	mov    %ecx,%edx
  802bbf:	89 f8                	mov    %edi,%eax
  802bc1:	75 3d                	jne    802c00 <__udivdi3+0x60>
  802bc3:	39 cf                	cmp    %ecx,%edi
  802bc5:	0f 87 c5 00 00 00    	ja     802c90 <__udivdi3+0xf0>
  802bcb:	85 ff                	test   %edi,%edi
  802bcd:	89 fd                	mov    %edi,%ebp
  802bcf:	75 0b                	jne    802bdc <__udivdi3+0x3c>
  802bd1:	b8 01 00 00 00       	mov    $0x1,%eax
  802bd6:	31 d2                	xor    %edx,%edx
  802bd8:	f7 f7                	div    %edi
  802bda:	89 c5                	mov    %eax,%ebp
  802bdc:	89 c8                	mov    %ecx,%eax
  802bde:	31 d2                	xor    %edx,%edx
  802be0:	f7 f5                	div    %ebp
  802be2:	89 c1                	mov    %eax,%ecx
  802be4:	89 d8                	mov    %ebx,%eax
  802be6:	89 cf                	mov    %ecx,%edi
  802be8:	f7 f5                	div    %ebp
  802bea:	89 c3                	mov    %eax,%ebx
  802bec:	89 d8                	mov    %ebx,%eax
  802bee:	89 fa                	mov    %edi,%edx
  802bf0:	83 c4 1c             	add    $0x1c,%esp
  802bf3:	5b                   	pop    %ebx
  802bf4:	5e                   	pop    %esi
  802bf5:	5f                   	pop    %edi
  802bf6:	5d                   	pop    %ebp
  802bf7:	c3                   	ret    
  802bf8:	90                   	nop
  802bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c00:	39 ce                	cmp    %ecx,%esi
  802c02:	77 74                	ja     802c78 <__udivdi3+0xd8>
  802c04:	0f bd fe             	bsr    %esi,%edi
  802c07:	83 f7 1f             	xor    $0x1f,%edi
  802c0a:	0f 84 98 00 00 00    	je     802ca8 <__udivdi3+0x108>
  802c10:	bb 20 00 00 00       	mov    $0x20,%ebx
  802c15:	89 f9                	mov    %edi,%ecx
  802c17:	89 c5                	mov    %eax,%ebp
  802c19:	29 fb                	sub    %edi,%ebx
  802c1b:	d3 e6                	shl    %cl,%esi
  802c1d:	89 d9                	mov    %ebx,%ecx
  802c1f:	d3 ed                	shr    %cl,%ebp
  802c21:	89 f9                	mov    %edi,%ecx
  802c23:	d3 e0                	shl    %cl,%eax
  802c25:	09 ee                	or     %ebp,%esi
  802c27:	89 d9                	mov    %ebx,%ecx
  802c29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802c2d:	89 d5                	mov    %edx,%ebp
  802c2f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802c33:	d3 ed                	shr    %cl,%ebp
  802c35:	89 f9                	mov    %edi,%ecx
  802c37:	d3 e2                	shl    %cl,%edx
  802c39:	89 d9                	mov    %ebx,%ecx
  802c3b:	d3 e8                	shr    %cl,%eax
  802c3d:	09 c2                	or     %eax,%edx
  802c3f:	89 d0                	mov    %edx,%eax
  802c41:	89 ea                	mov    %ebp,%edx
  802c43:	f7 f6                	div    %esi
  802c45:	89 d5                	mov    %edx,%ebp
  802c47:	89 c3                	mov    %eax,%ebx
  802c49:	f7 64 24 0c          	mull   0xc(%esp)
  802c4d:	39 d5                	cmp    %edx,%ebp
  802c4f:	72 10                	jb     802c61 <__udivdi3+0xc1>
  802c51:	8b 74 24 08          	mov    0x8(%esp),%esi
  802c55:	89 f9                	mov    %edi,%ecx
  802c57:	d3 e6                	shl    %cl,%esi
  802c59:	39 c6                	cmp    %eax,%esi
  802c5b:	73 07                	jae    802c64 <__udivdi3+0xc4>
  802c5d:	39 d5                	cmp    %edx,%ebp
  802c5f:	75 03                	jne    802c64 <__udivdi3+0xc4>
  802c61:	83 eb 01             	sub    $0x1,%ebx
  802c64:	31 ff                	xor    %edi,%edi
  802c66:	89 d8                	mov    %ebx,%eax
  802c68:	89 fa                	mov    %edi,%edx
  802c6a:	83 c4 1c             	add    $0x1c,%esp
  802c6d:	5b                   	pop    %ebx
  802c6e:	5e                   	pop    %esi
  802c6f:	5f                   	pop    %edi
  802c70:	5d                   	pop    %ebp
  802c71:	c3                   	ret    
  802c72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802c78:	31 ff                	xor    %edi,%edi
  802c7a:	31 db                	xor    %ebx,%ebx
  802c7c:	89 d8                	mov    %ebx,%eax
  802c7e:	89 fa                	mov    %edi,%edx
  802c80:	83 c4 1c             	add    $0x1c,%esp
  802c83:	5b                   	pop    %ebx
  802c84:	5e                   	pop    %esi
  802c85:	5f                   	pop    %edi
  802c86:	5d                   	pop    %ebp
  802c87:	c3                   	ret    
  802c88:	90                   	nop
  802c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c90:	89 d8                	mov    %ebx,%eax
  802c92:	f7 f7                	div    %edi
  802c94:	31 ff                	xor    %edi,%edi
  802c96:	89 c3                	mov    %eax,%ebx
  802c98:	89 d8                	mov    %ebx,%eax
  802c9a:	89 fa                	mov    %edi,%edx
  802c9c:	83 c4 1c             	add    $0x1c,%esp
  802c9f:	5b                   	pop    %ebx
  802ca0:	5e                   	pop    %esi
  802ca1:	5f                   	pop    %edi
  802ca2:	5d                   	pop    %ebp
  802ca3:	c3                   	ret    
  802ca4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ca8:	39 ce                	cmp    %ecx,%esi
  802caa:	72 0c                	jb     802cb8 <__udivdi3+0x118>
  802cac:	31 db                	xor    %ebx,%ebx
  802cae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802cb2:	0f 87 34 ff ff ff    	ja     802bec <__udivdi3+0x4c>
  802cb8:	bb 01 00 00 00       	mov    $0x1,%ebx
  802cbd:	e9 2a ff ff ff       	jmp    802bec <__udivdi3+0x4c>
  802cc2:	66 90                	xchg   %ax,%ax
  802cc4:	66 90                	xchg   %ax,%ax
  802cc6:	66 90                	xchg   %ax,%ax
  802cc8:	66 90                	xchg   %ax,%ax
  802cca:	66 90                	xchg   %ax,%ax
  802ccc:	66 90                	xchg   %ax,%ax
  802cce:	66 90                	xchg   %ax,%ax

00802cd0 <__umoddi3>:
  802cd0:	55                   	push   %ebp
  802cd1:	57                   	push   %edi
  802cd2:	56                   	push   %esi
  802cd3:	53                   	push   %ebx
  802cd4:	83 ec 1c             	sub    $0x1c,%esp
  802cd7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802cdb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802cdf:	8b 74 24 34          	mov    0x34(%esp),%esi
  802ce3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802ce7:	85 d2                	test   %edx,%edx
  802ce9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802ced:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802cf1:	89 f3                	mov    %esi,%ebx
  802cf3:	89 3c 24             	mov    %edi,(%esp)
  802cf6:	89 74 24 04          	mov    %esi,0x4(%esp)
  802cfa:	75 1c                	jne    802d18 <__umoddi3+0x48>
  802cfc:	39 f7                	cmp    %esi,%edi
  802cfe:	76 50                	jbe    802d50 <__umoddi3+0x80>
  802d00:	89 c8                	mov    %ecx,%eax
  802d02:	89 f2                	mov    %esi,%edx
  802d04:	f7 f7                	div    %edi
  802d06:	89 d0                	mov    %edx,%eax
  802d08:	31 d2                	xor    %edx,%edx
  802d0a:	83 c4 1c             	add    $0x1c,%esp
  802d0d:	5b                   	pop    %ebx
  802d0e:	5e                   	pop    %esi
  802d0f:	5f                   	pop    %edi
  802d10:	5d                   	pop    %ebp
  802d11:	c3                   	ret    
  802d12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802d18:	39 f2                	cmp    %esi,%edx
  802d1a:	89 d0                	mov    %edx,%eax
  802d1c:	77 52                	ja     802d70 <__umoddi3+0xa0>
  802d1e:	0f bd ea             	bsr    %edx,%ebp
  802d21:	83 f5 1f             	xor    $0x1f,%ebp
  802d24:	75 5a                	jne    802d80 <__umoddi3+0xb0>
  802d26:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802d2a:	0f 82 e0 00 00 00    	jb     802e10 <__umoddi3+0x140>
  802d30:	39 0c 24             	cmp    %ecx,(%esp)
  802d33:	0f 86 d7 00 00 00    	jbe    802e10 <__umoddi3+0x140>
  802d39:	8b 44 24 08          	mov    0x8(%esp),%eax
  802d3d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802d41:	83 c4 1c             	add    $0x1c,%esp
  802d44:	5b                   	pop    %ebx
  802d45:	5e                   	pop    %esi
  802d46:	5f                   	pop    %edi
  802d47:	5d                   	pop    %ebp
  802d48:	c3                   	ret    
  802d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802d50:	85 ff                	test   %edi,%edi
  802d52:	89 fd                	mov    %edi,%ebp
  802d54:	75 0b                	jne    802d61 <__umoddi3+0x91>
  802d56:	b8 01 00 00 00       	mov    $0x1,%eax
  802d5b:	31 d2                	xor    %edx,%edx
  802d5d:	f7 f7                	div    %edi
  802d5f:	89 c5                	mov    %eax,%ebp
  802d61:	89 f0                	mov    %esi,%eax
  802d63:	31 d2                	xor    %edx,%edx
  802d65:	f7 f5                	div    %ebp
  802d67:	89 c8                	mov    %ecx,%eax
  802d69:	f7 f5                	div    %ebp
  802d6b:	89 d0                	mov    %edx,%eax
  802d6d:	eb 99                	jmp    802d08 <__umoddi3+0x38>
  802d6f:	90                   	nop
  802d70:	89 c8                	mov    %ecx,%eax
  802d72:	89 f2                	mov    %esi,%edx
  802d74:	83 c4 1c             	add    $0x1c,%esp
  802d77:	5b                   	pop    %ebx
  802d78:	5e                   	pop    %esi
  802d79:	5f                   	pop    %edi
  802d7a:	5d                   	pop    %ebp
  802d7b:	c3                   	ret    
  802d7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802d80:	8b 34 24             	mov    (%esp),%esi
  802d83:	bf 20 00 00 00       	mov    $0x20,%edi
  802d88:	89 e9                	mov    %ebp,%ecx
  802d8a:	29 ef                	sub    %ebp,%edi
  802d8c:	d3 e0                	shl    %cl,%eax
  802d8e:	89 f9                	mov    %edi,%ecx
  802d90:	89 f2                	mov    %esi,%edx
  802d92:	d3 ea                	shr    %cl,%edx
  802d94:	89 e9                	mov    %ebp,%ecx
  802d96:	09 c2                	or     %eax,%edx
  802d98:	89 d8                	mov    %ebx,%eax
  802d9a:	89 14 24             	mov    %edx,(%esp)
  802d9d:	89 f2                	mov    %esi,%edx
  802d9f:	d3 e2                	shl    %cl,%edx
  802da1:	89 f9                	mov    %edi,%ecx
  802da3:	89 54 24 04          	mov    %edx,0x4(%esp)
  802da7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802dab:	d3 e8                	shr    %cl,%eax
  802dad:	89 e9                	mov    %ebp,%ecx
  802daf:	89 c6                	mov    %eax,%esi
  802db1:	d3 e3                	shl    %cl,%ebx
  802db3:	89 f9                	mov    %edi,%ecx
  802db5:	89 d0                	mov    %edx,%eax
  802db7:	d3 e8                	shr    %cl,%eax
  802db9:	89 e9                	mov    %ebp,%ecx
  802dbb:	09 d8                	or     %ebx,%eax
  802dbd:	89 d3                	mov    %edx,%ebx
  802dbf:	89 f2                	mov    %esi,%edx
  802dc1:	f7 34 24             	divl   (%esp)
  802dc4:	89 d6                	mov    %edx,%esi
  802dc6:	d3 e3                	shl    %cl,%ebx
  802dc8:	f7 64 24 04          	mull   0x4(%esp)
  802dcc:	39 d6                	cmp    %edx,%esi
  802dce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802dd2:	89 d1                	mov    %edx,%ecx
  802dd4:	89 c3                	mov    %eax,%ebx
  802dd6:	72 08                	jb     802de0 <__umoddi3+0x110>
  802dd8:	75 11                	jne    802deb <__umoddi3+0x11b>
  802dda:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802dde:	73 0b                	jae    802deb <__umoddi3+0x11b>
  802de0:	2b 44 24 04          	sub    0x4(%esp),%eax
  802de4:	1b 14 24             	sbb    (%esp),%edx
  802de7:	89 d1                	mov    %edx,%ecx
  802de9:	89 c3                	mov    %eax,%ebx
  802deb:	8b 54 24 08          	mov    0x8(%esp),%edx
  802def:	29 da                	sub    %ebx,%edx
  802df1:	19 ce                	sbb    %ecx,%esi
  802df3:	89 f9                	mov    %edi,%ecx
  802df5:	89 f0                	mov    %esi,%eax
  802df7:	d3 e0                	shl    %cl,%eax
  802df9:	89 e9                	mov    %ebp,%ecx
  802dfb:	d3 ea                	shr    %cl,%edx
  802dfd:	89 e9                	mov    %ebp,%ecx
  802dff:	d3 ee                	shr    %cl,%esi
  802e01:	09 d0                	or     %edx,%eax
  802e03:	89 f2                	mov    %esi,%edx
  802e05:	83 c4 1c             	add    $0x1c,%esp
  802e08:	5b                   	pop    %ebx
  802e09:	5e                   	pop    %esi
  802e0a:	5f                   	pop    %edi
  802e0b:	5d                   	pop    %ebp
  802e0c:	c3                   	ret    
  802e0d:	8d 76 00             	lea    0x0(%esi),%esi
  802e10:	29 f9                	sub    %edi,%ecx
  802e12:	19 d6                	sbb    %edx,%esi
  802e14:	89 74 24 04          	mov    %esi,0x4(%esp)
  802e18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802e1c:	e9 18 ff ff ff       	jmp    802d39 <__umoddi3+0x69>
