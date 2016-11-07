
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 21 03 80 00       	push   $0x800321
  80003e:	6a 00                	push   $0x0
  800040:	e8 36 02 00 00       	call   80027b <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005f:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800066:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  800069:	e8 c6 00 00 00       	call   800134 <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x37>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 42 00 00 00       	call   8000f3 <sys_env_destroy>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    

008000b6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	57                   	push   %edi
  8000ba:	56                   	push   %esi
  8000bb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c7:	89 c3                	mov    %eax,%ebx
  8000c9:	89 c7                	mov    %eax,%edi
  8000cb:	89 c6                	mov    %eax,%esi
  8000cd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cf:	5b                   	pop    %ebx
  8000d0:	5e                   	pop    %esi
  8000d1:	5f                   	pop    %edi
  8000d2:	5d                   	pop    %ebp
  8000d3:	c3                   	ret    

008000d4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	57                   	push   %edi
  8000d8:	56                   	push   %esi
  8000d9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000da:	ba 00 00 00 00       	mov    $0x0,%edx
  8000df:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e4:	89 d1                	mov    %edx,%ecx
  8000e6:	89 d3                	mov    %edx,%ebx
  8000e8:	89 d7                	mov    %edx,%edi
  8000ea:	89 d6                	mov    %edx,%esi
  8000ec:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ee:	5b                   	pop    %ebx
  8000ef:	5e                   	pop    %esi
  8000f0:	5f                   	pop    %edi
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	57                   	push   %edi
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800101:	b8 03 00 00 00       	mov    $0x3,%eax
  800106:	8b 55 08             	mov    0x8(%ebp),%edx
  800109:	89 cb                	mov    %ecx,%ebx
  80010b:	89 cf                	mov    %ecx,%edi
  80010d:	89 ce                	mov    %ecx,%esi
  80010f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800111:	85 c0                	test   %eax,%eax
  800113:	7e 17                	jle    80012c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	50                   	push   %eax
  800119:	6a 03                	push   $0x3
  80011b:	68 4a 10 80 00       	push   $0x80104a
  800120:	6a 23                	push   $0x23
  800122:	68 67 10 80 00       	push   $0x801067
  800127:	e8 17 02 00 00       	call   800343 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5f                   	pop    %edi
  800132:	5d                   	pop    %ebp
  800133:	c3                   	ret    

00800134 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	57                   	push   %edi
  800138:	56                   	push   %esi
  800139:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013a:	ba 00 00 00 00       	mov    $0x0,%edx
  80013f:	b8 02 00 00 00       	mov    $0x2,%eax
  800144:	89 d1                	mov    %edx,%ecx
  800146:	89 d3                	mov    %edx,%ebx
  800148:	89 d7                	mov    %edx,%edi
  80014a:	89 d6                	mov    %edx,%esi
  80014c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014e:	5b                   	pop    %ebx
  80014f:	5e                   	pop    %esi
  800150:	5f                   	pop    %edi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <sys_yield>:

void
sys_yield(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	57                   	push   %edi
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800159:	ba 00 00 00 00       	mov    $0x0,%edx
  80015e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800163:	89 d1                	mov    %edx,%ecx
  800165:	89 d3                	mov    %edx,%ebx
  800167:	89 d7                	mov    %edx,%edi
  800169:	89 d6                	mov    %edx,%esi
  80016b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016d:	5b                   	pop    %ebx
  80016e:	5e                   	pop    %esi
  80016f:	5f                   	pop    %edi
  800170:	5d                   	pop    %ebp
  800171:	c3                   	ret    

00800172 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	57                   	push   %edi
  800176:	56                   	push   %esi
  800177:	53                   	push   %ebx
  800178:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017b:	be 00 00 00 00       	mov    $0x0,%esi
  800180:	b8 04 00 00 00       	mov    $0x4,%eax
  800185:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800188:	8b 55 08             	mov    0x8(%ebp),%edx
  80018b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018e:	89 f7                	mov    %esi,%edi
  800190:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800192:	85 c0                	test   %eax,%eax
  800194:	7e 17                	jle    8001ad <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800196:	83 ec 0c             	sub    $0xc,%esp
  800199:	50                   	push   %eax
  80019a:	6a 04                	push   $0x4
  80019c:	68 4a 10 80 00       	push   $0x80104a
  8001a1:	6a 23                	push   $0x23
  8001a3:	68 67 10 80 00       	push   $0x801067
  8001a8:	e8 96 01 00 00       	call   800343 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b0:	5b                   	pop    %ebx
  8001b1:	5e                   	pop    %esi
  8001b2:	5f                   	pop    %edi
  8001b3:	5d                   	pop    %ebp
  8001b4:	c3                   	ret    

008001b5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	57                   	push   %edi
  8001b9:	56                   	push   %esi
  8001ba:	53                   	push   %ebx
  8001bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001be:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cf:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001d4:	85 c0                	test   %eax,%eax
  8001d6:	7e 17                	jle    8001ef <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	50                   	push   %eax
  8001dc:	6a 05                	push   $0x5
  8001de:	68 4a 10 80 00       	push   $0x80104a
  8001e3:	6a 23                	push   $0x23
  8001e5:	68 67 10 80 00       	push   $0x801067
  8001ea:	e8 54 01 00 00       	call   800343 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f2:	5b                   	pop    %ebx
  8001f3:	5e                   	pop    %esi
  8001f4:	5f                   	pop    %edi
  8001f5:	5d                   	pop    %ebp
  8001f6:	c3                   	ret    

008001f7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	57                   	push   %edi
  8001fb:	56                   	push   %esi
  8001fc:	53                   	push   %ebx
  8001fd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800200:	bb 00 00 00 00       	mov    $0x0,%ebx
  800205:	b8 06 00 00 00       	mov    $0x6,%eax
  80020a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020d:	8b 55 08             	mov    0x8(%ebp),%edx
  800210:	89 df                	mov    %ebx,%edi
  800212:	89 de                	mov    %ebx,%esi
  800214:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800216:	85 c0                	test   %eax,%eax
  800218:	7e 17                	jle    800231 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80021a:	83 ec 0c             	sub    $0xc,%esp
  80021d:	50                   	push   %eax
  80021e:	6a 06                	push   $0x6
  800220:	68 4a 10 80 00       	push   $0x80104a
  800225:	6a 23                	push   $0x23
  800227:	68 67 10 80 00       	push   $0x801067
  80022c:	e8 12 01 00 00       	call   800343 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800231:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800234:	5b                   	pop    %ebx
  800235:	5e                   	pop    %esi
  800236:	5f                   	pop    %edi
  800237:	5d                   	pop    %ebp
  800238:	c3                   	ret    

00800239 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	57                   	push   %edi
  80023d:	56                   	push   %esi
  80023e:	53                   	push   %ebx
  80023f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800242:	bb 00 00 00 00       	mov    $0x0,%ebx
  800247:	b8 08 00 00 00       	mov    $0x8,%eax
  80024c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024f:	8b 55 08             	mov    0x8(%ebp),%edx
  800252:	89 df                	mov    %ebx,%edi
  800254:	89 de                	mov    %ebx,%esi
  800256:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800258:	85 c0                	test   %eax,%eax
  80025a:	7e 17                	jle    800273 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025c:	83 ec 0c             	sub    $0xc,%esp
  80025f:	50                   	push   %eax
  800260:	6a 08                	push   $0x8
  800262:	68 4a 10 80 00       	push   $0x80104a
  800267:	6a 23                	push   $0x23
  800269:	68 67 10 80 00       	push   $0x801067
  80026e:	e8 d0 00 00 00       	call   800343 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800273:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800276:	5b                   	pop    %ebx
  800277:	5e                   	pop    %esi
  800278:	5f                   	pop    %edi
  800279:	5d                   	pop    %ebp
  80027a:	c3                   	ret    

0080027b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	57                   	push   %edi
  80027f:	56                   	push   %esi
  800280:	53                   	push   %ebx
  800281:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800284:	bb 00 00 00 00       	mov    $0x0,%ebx
  800289:	b8 09 00 00 00       	mov    $0x9,%eax
  80028e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800291:	8b 55 08             	mov    0x8(%ebp),%edx
  800294:	89 df                	mov    %ebx,%edi
  800296:	89 de                	mov    %ebx,%esi
  800298:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80029a:	85 c0                	test   %eax,%eax
  80029c:	7e 17                	jle    8002b5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029e:	83 ec 0c             	sub    $0xc,%esp
  8002a1:	50                   	push   %eax
  8002a2:	6a 09                	push   $0x9
  8002a4:	68 4a 10 80 00       	push   $0x80104a
  8002a9:	6a 23                	push   $0x23
  8002ab:	68 67 10 80 00       	push   $0x801067
  8002b0:	e8 8e 00 00 00       	call   800343 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b8:	5b                   	pop    %ebx
  8002b9:	5e                   	pop    %esi
  8002ba:	5f                   	pop    %edi
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	57                   	push   %edi
  8002c1:	56                   	push   %esi
  8002c2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c3:	be 00 00 00 00       	mov    $0x0,%esi
  8002c8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002d6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002d9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002db:	5b                   	pop    %ebx
  8002dc:	5e                   	pop    %esi
  8002dd:	5f                   	pop    %edi
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ee:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f6:	89 cb                	mov    %ecx,%ebx
  8002f8:	89 cf                	mov    %ecx,%edi
  8002fa:	89 ce                	mov    %ecx,%esi
  8002fc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002fe:	85 c0                	test   %eax,%eax
  800300:	7e 17                	jle    800319 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800302:	83 ec 0c             	sub    $0xc,%esp
  800305:	50                   	push   %eax
  800306:	6a 0c                	push   $0xc
  800308:	68 4a 10 80 00       	push   $0x80104a
  80030d:	6a 23                	push   $0x23
  80030f:	68 67 10 80 00       	push   $0x801067
  800314:	e8 2a 00 00 00       	call   800343 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800319:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80031c:	5b                   	pop    %ebx
  80031d:	5e                   	pop    %esi
  80031e:	5f                   	pop    %edi
  80031f:	5d                   	pop    %ebp
  800320:	c3                   	ret    

00800321 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800321:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800322:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800327:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800329:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	
	movl 0x28(%esp), %eax // moving trap-time eip in eax
  80032c:	8b 44 24 28          	mov    0x28(%esp),%eax

	
	movl %esp, %ebp// moving current stack
  800330:	89 e5                	mov    %esp,%ebp

	
	movl 0x30(%esp), %esp// Switch to trap-time stack
  800332:	8b 64 24 30          	mov    0x30(%esp),%esp

	
	pushl %eax// Push trap-time eip to the trap-time stack
  800336:	50                   	push   %eax

	
	movl %esp, 0x30(%ebp)//update the trap-time esp with its new value
  800337:	89 65 30             	mov    %esp,0x30(%ebp)

	
	movl %ebp, %esp// Go back to our exception stack
  80033a:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  80033c:	61                   	popa   
	
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp //eip
  80033d:	83 c4 04             	add    $0x4,%esp
   	popfl	
  800340:	9d                   	popf   


	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
popl %esp
  800341:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
ret
  800342:	c3                   	ret    

00800343 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	56                   	push   %esi
  800347:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800348:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80034b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800351:	e8 de fd ff ff       	call   800134 <sys_getenvid>
  800356:	83 ec 0c             	sub    $0xc,%esp
  800359:	ff 75 0c             	pushl  0xc(%ebp)
  80035c:	ff 75 08             	pushl  0x8(%ebp)
  80035f:	56                   	push   %esi
  800360:	50                   	push   %eax
  800361:	68 78 10 80 00       	push   $0x801078
  800366:	e8 b1 00 00 00       	call   80041c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80036b:	83 c4 18             	add    $0x18,%esp
  80036e:	53                   	push   %ebx
  80036f:	ff 75 10             	pushl  0x10(%ebp)
  800372:	e8 54 00 00 00       	call   8003cb <vcprintf>
	cprintf("\n");
  800377:	c7 04 24 d0 10 80 00 	movl   $0x8010d0,(%esp)
  80037e:	e8 99 00 00 00       	call   80041c <cprintf>
  800383:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800386:	cc                   	int3   
  800387:	eb fd                	jmp    800386 <_panic+0x43>

00800389 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	53                   	push   %ebx
  80038d:	83 ec 04             	sub    $0x4,%esp
  800390:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800393:	8b 13                	mov    (%ebx),%edx
  800395:	8d 42 01             	lea    0x1(%edx),%eax
  800398:	89 03                	mov    %eax,(%ebx)
  80039a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003a1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a6:	75 1a                	jne    8003c2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003a8:	83 ec 08             	sub    $0x8,%esp
  8003ab:	68 ff 00 00 00       	push   $0xff
  8003b0:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b3:	50                   	push   %eax
  8003b4:	e8 fd fc ff ff       	call   8000b6 <sys_cputs>
		b->idx = 0;
  8003b9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003bf:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003c2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003c9:	c9                   	leave  
  8003ca:	c3                   	ret    

008003cb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003d4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003db:	00 00 00 
	b.cnt = 0;
  8003de:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e8:	ff 75 0c             	pushl  0xc(%ebp)
  8003eb:	ff 75 08             	pushl  0x8(%ebp)
  8003ee:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f4:	50                   	push   %eax
  8003f5:	68 89 03 80 00       	push   $0x800389
  8003fa:	e8 54 01 00 00       	call   800553 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ff:	83 c4 08             	add    $0x8,%esp
  800402:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800408:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80040e:	50                   	push   %eax
  80040f:	e8 a2 fc ff ff       	call   8000b6 <sys_cputs>

	return b.cnt;
}
  800414:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80041a:	c9                   	leave  
  80041b:	c3                   	ret    

0080041c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80041c:	55                   	push   %ebp
  80041d:	89 e5                	mov    %esp,%ebp
  80041f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800422:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800425:	50                   	push   %eax
  800426:	ff 75 08             	pushl  0x8(%ebp)
  800429:	e8 9d ff ff ff       	call   8003cb <vcprintf>
	va_end(ap);

	return cnt;
}
  80042e:	c9                   	leave  
  80042f:	c3                   	ret    

00800430 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
  800433:	57                   	push   %edi
  800434:	56                   	push   %esi
  800435:	53                   	push   %ebx
  800436:	83 ec 1c             	sub    $0x1c,%esp
  800439:	89 c7                	mov    %eax,%edi
  80043b:	89 d6                	mov    %edx,%esi
  80043d:	8b 45 08             	mov    0x8(%ebp),%eax
  800440:	8b 55 0c             	mov    0xc(%ebp),%edx
  800443:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800446:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800449:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80044c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800451:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800454:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800457:	39 d3                	cmp    %edx,%ebx
  800459:	72 05                	jb     800460 <printnum+0x30>
  80045b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80045e:	77 45                	ja     8004a5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800460:	83 ec 0c             	sub    $0xc,%esp
  800463:	ff 75 18             	pushl  0x18(%ebp)
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80046c:	53                   	push   %ebx
  80046d:	ff 75 10             	pushl  0x10(%ebp)
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	ff 75 e4             	pushl  -0x1c(%ebp)
  800476:	ff 75 e0             	pushl  -0x20(%ebp)
  800479:	ff 75 dc             	pushl  -0x24(%ebp)
  80047c:	ff 75 d8             	pushl  -0x28(%ebp)
  80047f:	e8 1c 09 00 00       	call   800da0 <__udivdi3>
  800484:	83 c4 18             	add    $0x18,%esp
  800487:	52                   	push   %edx
  800488:	50                   	push   %eax
  800489:	89 f2                	mov    %esi,%edx
  80048b:	89 f8                	mov    %edi,%eax
  80048d:	e8 9e ff ff ff       	call   800430 <printnum>
  800492:	83 c4 20             	add    $0x20,%esp
  800495:	eb 18                	jmp    8004af <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800497:	83 ec 08             	sub    $0x8,%esp
  80049a:	56                   	push   %esi
  80049b:	ff 75 18             	pushl  0x18(%ebp)
  80049e:	ff d7                	call   *%edi
  8004a0:	83 c4 10             	add    $0x10,%esp
  8004a3:	eb 03                	jmp    8004a8 <printnum+0x78>
  8004a5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004a8:	83 eb 01             	sub    $0x1,%ebx
  8004ab:	85 db                	test   %ebx,%ebx
  8004ad:	7f e8                	jg     800497 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	56                   	push   %esi
  8004b3:	83 ec 04             	sub    $0x4,%esp
  8004b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8004bc:	ff 75 dc             	pushl  -0x24(%ebp)
  8004bf:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c2:	e8 09 0a 00 00       	call   800ed0 <__umoddi3>
  8004c7:	83 c4 14             	add    $0x14,%esp
  8004ca:	0f be 80 9c 10 80 00 	movsbl 0x80109c(%eax),%eax
  8004d1:	50                   	push   %eax
  8004d2:	ff d7                	call   *%edi
}
  8004d4:	83 c4 10             	add    $0x10,%esp
  8004d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004da:	5b                   	pop    %ebx
  8004db:	5e                   	pop    %esi
  8004dc:	5f                   	pop    %edi
  8004dd:	5d                   	pop    %ebp
  8004de:	c3                   	ret    

008004df <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004df:	55                   	push   %ebp
  8004e0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004e2:	83 fa 01             	cmp    $0x1,%edx
  8004e5:	7e 0e                	jle    8004f5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004e7:	8b 10                	mov    (%eax),%edx
  8004e9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004ec:	89 08                	mov    %ecx,(%eax)
  8004ee:	8b 02                	mov    (%edx),%eax
  8004f0:	8b 52 04             	mov    0x4(%edx),%edx
  8004f3:	eb 22                	jmp    800517 <getuint+0x38>
	else if (lflag)
  8004f5:	85 d2                	test   %edx,%edx
  8004f7:	74 10                	je     800509 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004f9:	8b 10                	mov    (%eax),%edx
  8004fb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004fe:	89 08                	mov    %ecx,(%eax)
  800500:	8b 02                	mov    (%edx),%eax
  800502:	ba 00 00 00 00       	mov    $0x0,%edx
  800507:	eb 0e                	jmp    800517 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800509:	8b 10                	mov    (%eax),%edx
  80050b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80050e:	89 08                	mov    %ecx,(%eax)
  800510:	8b 02                	mov    (%edx),%eax
  800512:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800517:	5d                   	pop    %ebp
  800518:	c3                   	ret    

00800519 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800519:	55                   	push   %ebp
  80051a:	89 e5                	mov    %esp,%ebp
  80051c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80051f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800523:	8b 10                	mov    (%eax),%edx
  800525:	3b 50 04             	cmp    0x4(%eax),%edx
  800528:	73 0a                	jae    800534 <sprintputch+0x1b>
		*b->buf++ = ch;
  80052a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80052d:	89 08                	mov    %ecx,(%eax)
  80052f:	8b 45 08             	mov    0x8(%ebp),%eax
  800532:	88 02                	mov    %al,(%edx)
}
  800534:	5d                   	pop    %ebp
  800535:	c3                   	ret    

00800536 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800536:	55                   	push   %ebp
  800537:	89 e5                	mov    %esp,%ebp
  800539:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80053c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80053f:	50                   	push   %eax
  800540:	ff 75 10             	pushl  0x10(%ebp)
  800543:	ff 75 0c             	pushl  0xc(%ebp)
  800546:	ff 75 08             	pushl  0x8(%ebp)
  800549:	e8 05 00 00 00       	call   800553 <vprintfmt>
	va_end(ap);
}
  80054e:	83 c4 10             	add    $0x10,%esp
  800551:	c9                   	leave  
  800552:	c3                   	ret    

00800553 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800553:	55                   	push   %ebp
  800554:	89 e5                	mov    %esp,%ebp
  800556:	57                   	push   %edi
  800557:	56                   	push   %esi
  800558:	53                   	push   %ebx
  800559:	83 ec 2c             	sub    $0x2c,%esp
  80055c:	8b 75 08             	mov    0x8(%ebp),%esi
  80055f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800562:	8b 7d 10             	mov    0x10(%ebp),%edi
  800565:	eb 12                	jmp    800579 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800567:	85 c0                	test   %eax,%eax
  800569:	0f 84 cb 03 00 00    	je     80093a <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  80056f:	83 ec 08             	sub    $0x8,%esp
  800572:	53                   	push   %ebx
  800573:	50                   	push   %eax
  800574:	ff d6                	call   *%esi
  800576:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800579:	83 c7 01             	add    $0x1,%edi
  80057c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800580:	83 f8 25             	cmp    $0x25,%eax
  800583:	75 e2                	jne    800567 <vprintfmt+0x14>
  800585:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800589:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800590:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800597:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80059e:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a3:	eb 07                	jmp    8005ac <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005a8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ac:	8d 47 01             	lea    0x1(%edi),%eax
  8005af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005b2:	0f b6 07             	movzbl (%edi),%eax
  8005b5:	0f b6 c8             	movzbl %al,%ecx
  8005b8:	83 e8 23             	sub    $0x23,%eax
  8005bb:	3c 55                	cmp    $0x55,%al
  8005bd:	0f 87 5c 03 00 00    	ja     80091f <vprintfmt+0x3cc>
  8005c3:	0f b6 c0             	movzbl %al,%eax
  8005c6:	ff 24 85 80 11 80 00 	jmp    *0x801180(,%eax,4)
  8005cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005d0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005d4:	eb d6                	jmp    8005ac <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8005de:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005e1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005e4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005e8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005eb:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005ee:	83 fa 09             	cmp    $0x9,%edx
  8005f1:	77 39                	ja     80062c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005f3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005f6:	eb e9                	jmp    8005e1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8d 48 04             	lea    0x4(%eax),%ecx
  8005fe:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800601:	8b 00                	mov    (%eax),%eax
  800603:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800606:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800609:	eb 27                	jmp    800632 <vprintfmt+0xdf>
  80060b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80060e:	85 c0                	test   %eax,%eax
  800610:	b9 00 00 00 00       	mov    $0x0,%ecx
  800615:	0f 49 c8             	cmovns %eax,%ecx
  800618:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061e:	eb 8c                	jmp    8005ac <vprintfmt+0x59>
  800620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800623:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80062a:	eb 80                	jmp    8005ac <vprintfmt+0x59>
  80062c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80062f:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800632:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800636:	0f 89 70 ff ff ff    	jns    8005ac <vprintfmt+0x59>
				width = precision, precision = -1;
  80063c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80063f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800642:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800649:	e9 5e ff ff ff       	jmp    8005ac <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80064e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800651:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800654:	e9 53 ff ff ff       	jmp    8005ac <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8d 50 04             	lea    0x4(%eax),%edx
  80065f:	89 55 14             	mov    %edx,0x14(%ebp)
  800662:	83 ec 08             	sub    $0x8,%esp
  800665:	53                   	push   %ebx
  800666:	ff 30                	pushl  (%eax)
  800668:	ff d6                	call   *%esi
			break;
  80066a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800670:	e9 04 ff ff ff       	jmp    800579 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8d 50 04             	lea    0x4(%eax),%edx
  80067b:	89 55 14             	mov    %edx,0x14(%ebp)
  80067e:	8b 00                	mov    (%eax),%eax
  800680:	99                   	cltd   
  800681:	31 d0                	xor    %edx,%eax
  800683:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800685:	83 f8 09             	cmp    $0x9,%eax
  800688:	7f 0b                	jg     800695 <vprintfmt+0x142>
  80068a:	8b 14 85 e0 12 80 00 	mov    0x8012e0(,%eax,4),%edx
  800691:	85 d2                	test   %edx,%edx
  800693:	75 18                	jne    8006ad <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800695:	50                   	push   %eax
  800696:	68 b4 10 80 00       	push   $0x8010b4
  80069b:	53                   	push   %ebx
  80069c:	56                   	push   %esi
  80069d:	e8 94 fe ff ff       	call   800536 <printfmt>
  8006a2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006a8:	e9 cc fe ff ff       	jmp    800579 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8006ad:	52                   	push   %edx
  8006ae:	68 bd 10 80 00       	push   $0x8010bd
  8006b3:	53                   	push   %ebx
  8006b4:	56                   	push   %esi
  8006b5:	e8 7c fe ff ff       	call   800536 <printfmt>
  8006ba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c0:	e9 b4 fe ff ff       	jmp    800579 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8d 50 04             	lea    0x4(%eax),%edx
  8006cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ce:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006d0:	85 ff                	test   %edi,%edi
  8006d2:	b8 ad 10 80 00       	mov    $0x8010ad,%eax
  8006d7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006da:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006de:	0f 8e 94 00 00 00    	jle    800778 <vprintfmt+0x225>
  8006e4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006e8:	0f 84 98 00 00 00    	je     800786 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	ff 75 c8             	pushl  -0x38(%ebp)
  8006f4:	57                   	push   %edi
  8006f5:	e8 c8 02 00 00       	call   8009c2 <strnlen>
  8006fa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006fd:	29 c1                	sub    %eax,%ecx
  8006ff:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800702:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800705:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800709:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80070c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80070f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800711:	eb 0f                	jmp    800722 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800713:	83 ec 08             	sub    $0x8,%esp
  800716:	53                   	push   %ebx
  800717:	ff 75 e0             	pushl  -0x20(%ebp)
  80071a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80071c:	83 ef 01             	sub    $0x1,%edi
  80071f:	83 c4 10             	add    $0x10,%esp
  800722:	85 ff                	test   %edi,%edi
  800724:	7f ed                	jg     800713 <vprintfmt+0x1c0>
  800726:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800729:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80072c:	85 c9                	test   %ecx,%ecx
  80072e:	b8 00 00 00 00       	mov    $0x0,%eax
  800733:	0f 49 c1             	cmovns %ecx,%eax
  800736:	29 c1                	sub    %eax,%ecx
  800738:	89 75 08             	mov    %esi,0x8(%ebp)
  80073b:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80073e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800741:	89 cb                	mov    %ecx,%ebx
  800743:	eb 4d                	jmp    800792 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800745:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800749:	74 1b                	je     800766 <vprintfmt+0x213>
  80074b:	0f be c0             	movsbl %al,%eax
  80074e:	83 e8 20             	sub    $0x20,%eax
  800751:	83 f8 5e             	cmp    $0x5e,%eax
  800754:	76 10                	jbe    800766 <vprintfmt+0x213>
					putch('?', putdat);
  800756:	83 ec 08             	sub    $0x8,%esp
  800759:	ff 75 0c             	pushl  0xc(%ebp)
  80075c:	6a 3f                	push   $0x3f
  80075e:	ff 55 08             	call   *0x8(%ebp)
  800761:	83 c4 10             	add    $0x10,%esp
  800764:	eb 0d                	jmp    800773 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	ff 75 0c             	pushl  0xc(%ebp)
  80076c:	52                   	push   %edx
  80076d:	ff 55 08             	call   *0x8(%ebp)
  800770:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800773:	83 eb 01             	sub    $0x1,%ebx
  800776:	eb 1a                	jmp    800792 <vprintfmt+0x23f>
  800778:	89 75 08             	mov    %esi,0x8(%ebp)
  80077b:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80077e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800781:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800784:	eb 0c                	jmp    800792 <vprintfmt+0x23f>
  800786:	89 75 08             	mov    %esi,0x8(%ebp)
  800789:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80078c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80078f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800792:	83 c7 01             	add    $0x1,%edi
  800795:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800799:	0f be d0             	movsbl %al,%edx
  80079c:	85 d2                	test   %edx,%edx
  80079e:	74 23                	je     8007c3 <vprintfmt+0x270>
  8007a0:	85 f6                	test   %esi,%esi
  8007a2:	78 a1                	js     800745 <vprintfmt+0x1f2>
  8007a4:	83 ee 01             	sub    $0x1,%esi
  8007a7:	79 9c                	jns    800745 <vprintfmt+0x1f2>
  8007a9:	89 df                	mov    %ebx,%edi
  8007ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007b1:	eb 18                	jmp    8007cb <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007b3:	83 ec 08             	sub    $0x8,%esp
  8007b6:	53                   	push   %ebx
  8007b7:	6a 20                	push   $0x20
  8007b9:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007bb:	83 ef 01             	sub    $0x1,%edi
  8007be:	83 c4 10             	add    $0x10,%esp
  8007c1:	eb 08                	jmp    8007cb <vprintfmt+0x278>
  8007c3:	89 df                	mov    %ebx,%edi
  8007c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007cb:	85 ff                	test   %edi,%edi
  8007cd:	7f e4                	jg     8007b3 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007d2:	e9 a2 fd ff ff       	jmp    800579 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007d7:	83 fa 01             	cmp    $0x1,%edx
  8007da:	7e 16                	jle    8007f2 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007df:	8d 50 08             	lea    0x8(%eax),%edx
  8007e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e5:	8b 50 04             	mov    0x4(%eax),%edx
  8007e8:	8b 00                	mov    (%eax),%eax
  8007ea:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007ed:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8007f0:	eb 32                	jmp    800824 <vprintfmt+0x2d1>
	else if (lflag)
  8007f2:	85 d2                	test   %edx,%edx
  8007f4:	74 18                	je     80080e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f9:	8d 50 04             	lea    0x4(%eax),%edx
  8007fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ff:	8b 00                	mov    (%eax),%eax
  800801:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800804:	89 c1                	mov    %eax,%ecx
  800806:	c1 f9 1f             	sar    $0x1f,%ecx
  800809:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80080c:	eb 16                	jmp    800824 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80080e:	8b 45 14             	mov    0x14(%ebp),%eax
  800811:	8d 50 04             	lea    0x4(%eax),%edx
  800814:	89 55 14             	mov    %edx,0x14(%ebp)
  800817:	8b 00                	mov    (%eax),%eax
  800819:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80081c:	89 c1                	mov    %eax,%ecx
  80081e:	c1 f9 1f             	sar    $0x1f,%ecx
  800821:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800824:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800827:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80082a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80082d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800830:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800835:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800839:	0f 89 a8 00 00 00    	jns    8008e7 <vprintfmt+0x394>
				putch('-', putdat);
  80083f:	83 ec 08             	sub    $0x8,%esp
  800842:	53                   	push   %ebx
  800843:	6a 2d                	push   $0x2d
  800845:	ff d6                	call   *%esi
				num = -(long long) num;
  800847:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80084a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80084d:	f7 d8                	neg    %eax
  80084f:	83 d2 00             	adc    $0x0,%edx
  800852:	f7 da                	neg    %edx
  800854:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800857:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80085a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80085d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800862:	e9 80 00 00 00       	jmp    8008e7 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800867:	8d 45 14             	lea    0x14(%ebp),%eax
  80086a:	e8 70 fc ff ff       	call   8004df <getuint>
  80086f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800872:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800875:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80087a:	eb 6b                	jmp    8008e7 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80087c:	8d 45 14             	lea    0x14(%ebp),%eax
  80087f:	e8 5b fc ff ff       	call   8004df <getuint>
  800884:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800887:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  80088a:	6a 04                	push   $0x4
  80088c:	6a 03                	push   $0x3
  80088e:	6a 01                	push   $0x1
  800890:	68 c0 10 80 00       	push   $0x8010c0
  800895:	e8 82 fb ff ff       	call   80041c <cprintf>
			goto number;
  80089a:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  80089d:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  8008a2:	eb 43                	jmp    8008e7 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  8008a4:	83 ec 08             	sub    $0x8,%esp
  8008a7:	53                   	push   %ebx
  8008a8:	6a 30                	push   $0x30
  8008aa:	ff d6                	call   *%esi
			putch('x', putdat);
  8008ac:	83 c4 08             	add    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	6a 78                	push   $0x78
  8008b2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b7:	8d 50 04             	lea    0x4(%eax),%edx
  8008ba:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008bd:	8b 00                	mov    (%eax),%eax
  8008bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8008c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008ca:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008cd:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008d2:	eb 13                	jmp    8008e7 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008d4:	8d 45 14             	lea    0x14(%ebp),%eax
  8008d7:	e8 03 fc ff ff       	call   8004df <getuint>
  8008dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008df:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008e2:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008e7:	83 ec 0c             	sub    $0xc,%esp
  8008ea:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8008ee:	52                   	push   %edx
  8008ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8008f2:	50                   	push   %eax
  8008f3:	ff 75 dc             	pushl  -0x24(%ebp)
  8008f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8008f9:	89 da                	mov    %ebx,%edx
  8008fb:	89 f0                	mov    %esi,%eax
  8008fd:	e8 2e fb ff ff       	call   800430 <printnum>

			break;
  800902:	83 c4 20             	add    $0x20,%esp
  800905:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800908:	e9 6c fc ff ff       	jmp    800579 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80090d:	83 ec 08             	sub    $0x8,%esp
  800910:	53                   	push   %ebx
  800911:	51                   	push   %ecx
  800912:	ff d6                	call   *%esi
			break;
  800914:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800917:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80091a:	e9 5a fc ff ff       	jmp    800579 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80091f:	83 ec 08             	sub    $0x8,%esp
  800922:	53                   	push   %ebx
  800923:	6a 25                	push   $0x25
  800925:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800927:	83 c4 10             	add    $0x10,%esp
  80092a:	eb 03                	jmp    80092f <vprintfmt+0x3dc>
  80092c:	83 ef 01             	sub    $0x1,%edi
  80092f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800933:	75 f7                	jne    80092c <vprintfmt+0x3d9>
  800935:	e9 3f fc ff ff       	jmp    800579 <vprintfmt+0x26>
			break;
		}

	}

}
  80093a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80093d:	5b                   	pop    %ebx
  80093e:	5e                   	pop    %esi
  80093f:	5f                   	pop    %edi
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	83 ec 18             	sub    $0x18,%esp
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80094e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800951:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800955:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800958:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80095f:	85 c0                	test   %eax,%eax
  800961:	74 26                	je     800989 <vsnprintf+0x47>
  800963:	85 d2                	test   %edx,%edx
  800965:	7e 22                	jle    800989 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800967:	ff 75 14             	pushl  0x14(%ebp)
  80096a:	ff 75 10             	pushl  0x10(%ebp)
  80096d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800970:	50                   	push   %eax
  800971:	68 19 05 80 00       	push   $0x800519
  800976:	e8 d8 fb ff ff       	call   800553 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80097b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80097e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800981:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800984:	83 c4 10             	add    $0x10,%esp
  800987:	eb 05                	jmp    80098e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800989:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80098e:	c9                   	leave  
  80098f:	c3                   	ret    

00800990 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800996:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800999:	50                   	push   %eax
  80099a:	ff 75 10             	pushl  0x10(%ebp)
  80099d:	ff 75 0c             	pushl  0xc(%ebp)
  8009a0:	ff 75 08             	pushl  0x8(%ebp)
  8009a3:	e8 9a ff ff ff       	call   800942 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009a8:	c9                   	leave  
  8009a9:	c3                   	ret    

008009aa <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b5:	eb 03                	jmp    8009ba <strlen+0x10>
		n++;
  8009b7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ba:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009be:	75 f7                	jne    8009b7 <strlen+0xd>
		n++;
	return n;
}
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d0:	eb 03                	jmp    8009d5 <strnlen+0x13>
		n++;
  8009d2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d5:	39 c2                	cmp    %eax,%edx
  8009d7:	74 08                	je     8009e1 <strnlen+0x1f>
  8009d9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009dd:	75 f3                	jne    8009d2 <strnlen+0x10>
  8009df:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    

008009e3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	53                   	push   %ebx
  8009e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009ed:	89 c2                	mov    %eax,%edx
  8009ef:	83 c2 01             	add    $0x1,%edx
  8009f2:	83 c1 01             	add    $0x1,%ecx
  8009f5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009f9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009fc:	84 db                	test   %bl,%bl
  8009fe:	75 ef                	jne    8009ef <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a00:	5b                   	pop    %ebx
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	53                   	push   %ebx
  800a07:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a0a:	53                   	push   %ebx
  800a0b:	e8 9a ff ff ff       	call   8009aa <strlen>
  800a10:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a13:	ff 75 0c             	pushl  0xc(%ebp)
  800a16:	01 d8                	add    %ebx,%eax
  800a18:	50                   	push   %eax
  800a19:	e8 c5 ff ff ff       	call   8009e3 <strcpy>
	return dst;
}
  800a1e:	89 d8                	mov    %ebx,%eax
  800a20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a23:	c9                   	leave  
  800a24:	c3                   	ret    

00800a25 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	56                   	push   %esi
  800a29:	53                   	push   %ebx
  800a2a:	8b 75 08             	mov    0x8(%ebp),%esi
  800a2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a30:	89 f3                	mov    %esi,%ebx
  800a32:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a35:	89 f2                	mov    %esi,%edx
  800a37:	eb 0f                	jmp    800a48 <strncpy+0x23>
		*dst++ = *src;
  800a39:	83 c2 01             	add    $0x1,%edx
  800a3c:	0f b6 01             	movzbl (%ecx),%eax
  800a3f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a42:	80 39 01             	cmpb   $0x1,(%ecx)
  800a45:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a48:	39 da                	cmp    %ebx,%edx
  800a4a:	75 ed                	jne    800a39 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a4c:	89 f0                	mov    %esi,%eax
  800a4e:	5b                   	pop    %ebx
  800a4f:	5e                   	pop    %esi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	56                   	push   %esi
  800a56:	53                   	push   %ebx
  800a57:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5d:	8b 55 10             	mov    0x10(%ebp),%edx
  800a60:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a62:	85 d2                	test   %edx,%edx
  800a64:	74 21                	je     800a87 <strlcpy+0x35>
  800a66:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a6a:	89 f2                	mov    %esi,%edx
  800a6c:	eb 09                	jmp    800a77 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a6e:	83 c2 01             	add    $0x1,%edx
  800a71:	83 c1 01             	add    $0x1,%ecx
  800a74:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a77:	39 c2                	cmp    %eax,%edx
  800a79:	74 09                	je     800a84 <strlcpy+0x32>
  800a7b:	0f b6 19             	movzbl (%ecx),%ebx
  800a7e:	84 db                	test   %bl,%bl
  800a80:	75 ec                	jne    800a6e <strlcpy+0x1c>
  800a82:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a84:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a87:	29 f0                	sub    %esi,%eax
}
  800a89:	5b                   	pop    %ebx
  800a8a:	5e                   	pop    %esi
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a93:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a96:	eb 06                	jmp    800a9e <strcmp+0x11>
		p++, q++;
  800a98:	83 c1 01             	add    $0x1,%ecx
  800a9b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a9e:	0f b6 01             	movzbl (%ecx),%eax
  800aa1:	84 c0                	test   %al,%al
  800aa3:	74 04                	je     800aa9 <strcmp+0x1c>
  800aa5:	3a 02                	cmp    (%edx),%al
  800aa7:	74 ef                	je     800a98 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa9:	0f b6 c0             	movzbl %al,%eax
  800aac:	0f b6 12             	movzbl (%edx),%edx
  800aaf:	29 d0                	sub    %edx,%eax
}
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	53                   	push   %ebx
  800ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aba:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abd:	89 c3                	mov    %eax,%ebx
  800abf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ac2:	eb 06                	jmp    800aca <strncmp+0x17>
		n--, p++, q++;
  800ac4:	83 c0 01             	add    $0x1,%eax
  800ac7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aca:	39 d8                	cmp    %ebx,%eax
  800acc:	74 15                	je     800ae3 <strncmp+0x30>
  800ace:	0f b6 08             	movzbl (%eax),%ecx
  800ad1:	84 c9                	test   %cl,%cl
  800ad3:	74 04                	je     800ad9 <strncmp+0x26>
  800ad5:	3a 0a                	cmp    (%edx),%cl
  800ad7:	74 eb                	je     800ac4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad9:	0f b6 00             	movzbl (%eax),%eax
  800adc:	0f b6 12             	movzbl (%edx),%edx
  800adf:	29 d0                	sub    %edx,%eax
  800ae1:	eb 05                	jmp    800ae8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ae3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ae8:	5b                   	pop    %ebx
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	8b 45 08             	mov    0x8(%ebp),%eax
  800af1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af5:	eb 07                	jmp    800afe <strchr+0x13>
		if (*s == c)
  800af7:	38 ca                	cmp    %cl,%dl
  800af9:	74 0f                	je     800b0a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800afb:	83 c0 01             	add    $0x1,%eax
  800afe:	0f b6 10             	movzbl (%eax),%edx
  800b01:	84 d2                	test   %dl,%dl
  800b03:	75 f2                	jne    800af7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b05:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b12:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b16:	eb 03                	jmp    800b1b <strfind+0xf>
  800b18:	83 c0 01             	add    $0x1,%eax
  800b1b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b1e:	38 ca                	cmp    %cl,%dl
  800b20:	74 04                	je     800b26 <strfind+0x1a>
  800b22:	84 d2                	test   %dl,%dl
  800b24:	75 f2                	jne    800b18 <strfind+0xc>
			break;
	return (char *) s;
}
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	57                   	push   %edi
  800b2c:	56                   	push   %esi
  800b2d:	53                   	push   %ebx
  800b2e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b31:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b34:	85 c9                	test   %ecx,%ecx
  800b36:	74 36                	je     800b6e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b38:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b3e:	75 28                	jne    800b68 <memset+0x40>
  800b40:	f6 c1 03             	test   $0x3,%cl
  800b43:	75 23                	jne    800b68 <memset+0x40>
		c &= 0xFF;
  800b45:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b49:	89 d3                	mov    %edx,%ebx
  800b4b:	c1 e3 08             	shl    $0x8,%ebx
  800b4e:	89 d6                	mov    %edx,%esi
  800b50:	c1 e6 18             	shl    $0x18,%esi
  800b53:	89 d0                	mov    %edx,%eax
  800b55:	c1 e0 10             	shl    $0x10,%eax
  800b58:	09 f0                	or     %esi,%eax
  800b5a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b5c:	89 d8                	mov    %ebx,%eax
  800b5e:	09 d0                	or     %edx,%eax
  800b60:	c1 e9 02             	shr    $0x2,%ecx
  800b63:	fc                   	cld    
  800b64:	f3 ab                	rep stos %eax,%es:(%edi)
  800b66:	eb 06                	jmp    800b6e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6b:	fc                   	cld    
  800b6c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b6e:	89 f8                	mov    %edi,%eax
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b80:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b83:	39 c6                	cmp    %eax,%esi
  800b85:	73 35                	jae    800bbc <memmove+0x47>
  800b87:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b8a:	39 d0                	cmp    %edx,%eax
  800b8c:	73 2e                	jae    800bbc <memmove+0x47>
		s += n;
		d += n;
  800b8e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b91:	89 d6                	mov    %edx,%esi
  800b93:	09 fe                	or     %edi,%esi
  800b95:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b9b:	75 13                	jne    800bb0 <memmove+0x3b>
  800b9d:	f6 c1 03             	test   $0x3,%cl
  800ba0:	75 0e                	jne    800bb0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ba2:	83 ef 04             	sub    $0x4,%edi
  800ba5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ba8:	c1 e9 02             	shr    $0x2,%ecx
  800bab:	fd                   	std    
  800bac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bae:	eb 09                	jmp    800bb9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bb0:	83 ef 01             	sub    $0x1,%edi
  800bb3:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bb6:	fd                   	std    
  800bb7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bb9:	fc                   	cld    
  800bba:	eb 1d                	jmp    800bd9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bbc:	89 f2                	mov    %esi,%edx
  800bbe:	09 c2                	or     %eax,%edx
  800bc0:	f6 c2 03             	test   $0x3,%dl
  800bc3:	75 0f                	jne    800bd4 <memmove+0x5f>
  800bc5:	f6 c1 03             	test   $0x3,%cl
  800bc8:	75 0a                	jne    800bd4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bca:	c1 e9 02             	shr    $0x2,%ecx
  800bcd:	89 c7                	mov    %eax,%edi
  800bcf:	fc                   	cld    
  800bd0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bd2:	eb 05                	jmp    800bd9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bd4:	89 c7                	mov    %eax,%edi
  800bd6:	fc                   	cld    
  800bd7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800be0:	ff 75 10             	pushl  0x10(%ebp)
  800be3:	ff 75 0c             	pushl  0xc(%ebp)
  800be6:	ff 75 08             	pushl  0x8(%ebp)
  800be9:	e8 87 ff ff ff       	call   800b75 <memmove>
}
  800bee:	c9                   	leave  
  800bef:	c3                   	ret    

00800bf0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
  800bf5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bfb:	89 c6                	mov    %eax,%esi
  800bfd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c00:	eb 1a                	jmp    800c1c <memcmp+0x2c>
		if (*s1 != *s2)
  800c02:	0f b6 08             	movzbl (%eax),%ecx
  800c05:	0f b6 1a             	movzbl (%edx),%ebx
  800c08:	38 d9                	cmp    %bl,%cl
  800c0a:	74 0a                	je     800c16 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c0c:	0f b6 c1             	movzbl %cl,%eax
  800c0f:	0f b6 db             	movzbl %bl,%ebx
  800c12:	29 d8                	sub    %ebx,%eax
  800c14:	eb 0f                	jmp    800c25 <memcmp+0x35>
		s1++, s2++;
  800c16:	83 c0 01             	add    $0x1,%eax
  800c19:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c1c:	39 f0                	cmp    %esi,%eax
  800c1e:	75 e2                	jne    800c02 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c20:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c25:	5b                   	pop    %ebx
  800c26:	5e                   	pop    %esi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	53                   	push   %ebx
  800c2d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c30:	89 c1                	mov    %eax,%ecx
  800c32:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c35:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c39:	eb 0a                	jmp    800c45 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c3b:	0f b6 10             	movzbl (%eax),%edx
  800c3e:	39 da                	cmp    %ebx,%edx
  800c40:	74 07                	je     800c49 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c42:	83 c0 01             	add    $0x1,%eax
  800c45:	39 c8                	cmp    %ecx,%eax
  800c47:	72 f2                	jb     800c3b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c49:	5b                   	pop    %ebx
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c55:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c58:	eb 03                	jmp    800c5d <strtol+0x11>
		s++;
  800c5a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c5d:	0f b6 01             	movzbl (%ecx),%eax
  800c60:	3c 20                	cmp    $0x20,%al
  800c62:	74 f6                	je     800c5a <strtol+0xe>
  800c64:	3c 09                	cmp    $0x9,%al
  800c66:	74 f2                	je     800c5a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c68:	3c 2b                	cmp    $0x2b,%al
  800c6a:	75 0a                	jne    800c76 <strtol+0x2a>
		s++;
  800c6c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c6f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c74:	eb 11                	jmp    800c87 <strtol+0x3b>
  800c76:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c7b:	3c 2d                	cmp    $0x2d,%al
  800c7d:	75 08                	jne    800c87 <strtol+0x3b>
		s++, neg = 1;
  800c7f:	83 c1 01             	add    $0x1,%ecx
  800c82:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c87:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c8d:	75 15                	jne    800ca4 <strtol+0x58>
  800c8f:	80 39 30             	cmpb   $0x30,(%ecx)
  800c92:	75 10                	jne    800ca4 <strtol+0x58>
  800c94:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c98:	75 7c                	jne    800d16 <strtol+0xca>
		s += 2, base = 16;
  800c9a:	83 c1 02             	add    $0x2,%ecx
  800c9d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ca2:	eb 16                	jmp    800cba <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ca4:	85 db                	test   %ebx,%ebx
  800ca6:	75 12                	jne    800cba <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ca8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cad:	80 39 30             	cmpb   $0x30,(%ecx)
  800cb0:	75 08                	jne    800cba <strtol+0x6e>
		s++, base = 8;
  800cb2:	83 c1 01             	add    $0x1,%ecx
  800cb5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cba:	b8 00 00 00 00       	mov    $0x0,%eax
  800cbf:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cc2:	0f b6 11             	movzbl (%ecx),%edx
  800cc5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cc8:	89 f3                	mov    %esi,%ebx
  800cca:	80 fb 09             	cmp    $0x9,%bl
  800ccd:	77 08                	ja     800cd7 <strtol+0x8b>
			dig = *s - '0';
  800ccf:	0f be d2             	movsbl %dl,%edx
  800cd2:	83 ea 30             	sub    $0x30,%edx
  800cd5:	eb 22                	jmp    800cf9 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cd7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cda:	89 f3                	mov    %esi,%ebx
  800cdc:	80 fb 19             	cmp    $0x19,%bl
  800cdf:	77 08                	ja     800ce9 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ce1:	0f be d2             	movsbl %dl,%edx
  800ce4:	83 ea 57             	sub    $0x57,%edx
  800ce7:	eb 10                	jmp    800cf9 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ce9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cec:	89 f3                	mov    %esi,%ebx
  800cee:	80 fb 19             	cmp    $0x19,%bl
  800cf1:	77 16                	ja     800d09 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cf3:	0f be d2             	movsbl %dl,%edx
  800cf6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cf9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cfc:	7d 0b                	jge    800d09 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cfe:	83 c1 01             	add    $0x1,%ecx
  800d01:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d05:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d07:	eb b9                	jmp    800cc2 <strtol+0x76>

	if (endptr)
  800d09:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d0d:	74 0d                	je     800d1c <strtol+0xd0>
		*endptr = (char *) s;
  800d0f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d12:	89 0e                	mov    %ecx,(%esi)
  800d14:	eb 06                	jmp    800d1c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d16:	85 db                	test   %ebx,%ebx
  800d18:	74 98                	je     800cb2 <strtol+0x66>
  800d1a:	eb 9e                	jmp    800cba <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d1c:	89 c2                	mov    %eax,%edx
  800d1e:	f7 da                	neg    %edx
  800d20:	85 ff                	test   %edi,%edi
  800d22:	0f 45 c2             	cmovne %edx,%eax
}
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d30:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d37:	75 2c                	jne    800d65 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  800d39:	83 ec 04             	sub    $0x4,%esp
  800d3c:	6a 07                	push   $0x7
  800d3e:	68 00 f0 bf ee       	push   $0xeebff000
  800d43:	6a 00                	push   $0x0
  800d45:	e8 28 f4 ff ff       	call   800172 <sys_page_alloc>
  800d4a:	83 c4 10             	add    $0x10,%esp
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	79 14                	jns    800d65 <set_pgfault_handler+0x3b>
            panic("set sys_page_alloc");;
  800d51:	83 ec 04             	sub    $0x4,%esp
  800d54:	68 08 13 80 00       	push   $0x801308
  800d59:	6a 21                	push   $0x21
  800d5b:	68 1b 13 80 00       	push   $0x80131b
  800d60:	e8 de f5 ff ff       	call   800343 <_panic>
	
	}
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800d65:	83 ec 08             	sub    $0x8,%esp
  800d68:	68 21 03 80 00       	push   $0x800321
  800d6d:	6a 00                	push   $0x0
  800d6f:	e8 07 f5 ff ff       	call   80027b <sys_env_set_pgfault_upcall>
  800d74:	83 c4 10             	add    $0x10,%esp
  800d77:	85 c0                	test   %eax,%eax
  800d79:	79 14                	jns    800d8f <set_pgfault_handler+0x65>
        panic("set page fault handler");
  800d7b:	83 ec 04             	sub    $0x4,%esp
  800d7e:	68 29 13 80 00       	push   $0x801329
  800d83:	6a 25                	push   $0x25
  800d85:	68 1b 13 80 00       	push   $0x80131b
  800d8a:	e8 b4 f5 ff ff       	call   800343 <_panic>

	
	_pgfault_handler = handler;
  800d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d92:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d97:	c9                   	leave  
  800d98:	c3                   	ret    
  800d99:	66 90                	xchg   %ax,%ax
  800d9b:	66 90                	xchg   %ax,%ax
  800d9d:	66 90                	xchg   %ax,%ax
  800d9f:	90                   	nop

00800da0 <__udivdi3>:
  800da0:	55                   	push   %ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	83 ec 1c             	sub    $0x1c,%esp
  800da7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800dab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800daf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800db3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800db7:	85 f6                	test   %esi,%esi
  800db9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800dbd:	89 ca                	mov    %ecx,%edx
  800dbf:	89 f8                	mov    %edi,%eax
  800dc1:	75 3d                	jne    800e00 <__udivdi3+0x60>
  800dc3:	39 cf                	cmp    %ecx,%edi
  800dc5:	0f 87 c5 00 00 00    	ja     800e90 <__udivdi3+0xf0>
  800dcb:	85 ff                	test   %edi,%edi
  800dcd:	89 fd                	mov    %edi,%ebp
  800dcf:	75 0b                	jne    800ddc <__udivdi3+0x3c>
  800dd1:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd6:	31 d2                	xor    %edx,%edx
  800dd8:	f7 f7                	div    %edi
  800dda:	89 c5                	mov    %eax,%ebp
  800ddc:	89 c8                	mov    %ecx,%eax
  800dde:	31 d2                	xor    %edx,%edx
  800de0:	f7 f5                	div    %ebp
  800de2:	89 c1                	mov    %eax,%ecx
  800de4:	89 d8                	mov    %ebx,%eax
  800de6:	89 cf                	mov    %ecx,%edi
  800de8:	f7 f5                	div    %ebp
  800dea:	89 c3                	mov    %eax,%ebx
  800dec:	89 d8                	mov    %ebx,%eax
  800dee:	89 fa                	mov    %edi,%edx
  800df0:	83 c4 1c             	add    $0x1c,%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    
  800df8:	90                   	nop
  800df9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e00:	39 ce                	cmp    %ecx,%esi
  800e02:	77 74                	ja     800e78 <__udivdi3+0xd8>
  800e04:	0f bd fe             	bsr    %esi,%edi
  800e07:	83 f7 1f             	xor    $0x1f,%edi
  800e0a:	0f 84 98 00 00 00    	je     800ea8 <__udivdi3+0x108>
  800e10:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e15:	89 f9                	mov    %edi,%ecx
  800e17:	89 c5                	mov    %eax,%ebp
  800e19:	29 fb                	sub    %edi,%ebx
  800e1b:	d3 e6                	shl    %cl,%esi
  800e1d:	89 d9                	mov    %ebx,%ecx
  800e1f:	d3 ed                	shr    %cl,%ebp
  800e21:	89 f9                	mov    %edi,%ecx
  800e23:	d3 e0                	shl    %cl,%eax
  800e25:	09 ee                	or     %ebp,%esi
  800e27:	89 d9                	mov    %ebx,%ecx
  800e29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e2d:	89 d5                	mov    %edx,%ebp
  800e2f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e33:	d3 ed                	shr    %cl,%ebp
  800e35:	89 f9                	mov    %edi,%ecx
  800e37:	d3 e2                	shl    %cl,%edx
  800e39:	89 d9                	mov    %ebx,%ecx
  800e3b:	d3 e8                	shr    %cl,%eax
  800e3d:	09 c2                	or     %eax,%edx
  800e3f:	89 d0                	mov    %edx,%eax
  800e41:	89 ea                	mov    %ebp,%edx
  800e43:	f7 f6                	div    %esi
  800e45:	89 d5                	mov    %edx,%ebp
  800e47:	89 c3                	mov    %eax,%ebx
  800e49:	f7 64 24 0c          	mull   0xc(%esp)
  800e4d:	39 d5                	cmp    %edx,%ebp
  800e4f:	72 10                	jb     800e61 <__udivdi3+0xc1>
  800e51:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e55:	89 f9                	mov    %edi,%ecx
  800e57:	d3 e6                	shl    %cl,%esi
  800e59:	39 c6                	cmp    %eax,%esi
  800e5b:	73 07                	jae    800e64 <__udivdi3+0xc4>
  800e5d:	39 d5                	cmp    %edx,%ebp
  800e5f:	75 03                	jne    800e64 <__udivdi3+0xc4>
  800e61:	83 eb 01             	sub    $0x1,%ebx
  800e64:	31 ff                	xor    %edi,%edi
  800e66:	89 d8                	mov    %ebx,%eax
  800e68:	89 fa                	mov    %edi,%edx
  800e6a:	83 c4 1c             	add    $0x1c,%esp
  800e6d:	5b                   	pop    %ebx
  800e6e:	5e                   	pop    %esi
  800e6f:	5f                   	pop    %edi
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    
  800e72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e78:	31 ff                	xor    %edi,%edi
  800e7a:	31 db                	xor    %ebx,%ebx
  800e7c:	89 d8                	mov    %ebx,%eax
  800e7e:	89 fa                	mov    %edi,%edx
  800e80:	83 c4 1c             	add    $0x1c,%esp
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    
  800e88:	90                   	nop
  800e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e90:	89 d8                	mov    %ebx,%eax
  800e92:	f7 f7                	div    %edi
  800e94:	31 ff                	xor    %edi,%edi
  800e96:	89 c3                	mov    %eax,%ebx
  800e98:	89 d8                	mov    %ebx,%eax
  800e9a:	89 fa                	mov    %edi,%edx
  800e9c:	83 c4 1c             	add    $0x1c,%esp
  800e9f:	5b                   	pop    %ebx
  800ea0:	5e                   	pop    %esi
  800ea1:	5f                   	pop    %edi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    
  800ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ea8:	39 ce                	cmp    %ecx,%esi
  800eaa:	72 0c                	jb     800eb8 <__udivdi3+0x118>
  800eac:	31 db                	xor    %ebx,%ebx
  800eae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800eb2:	0f 87 34 ff ff ff    	ja     800dec <__udivdi3+0x4c>
  800eb8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800ebd:	e9 2a ff ff ff       	jmp    800dec <__udivdi3+0x4c>
  800ec2:	66 90                	xchg   %ax,%ax
  800ec4:	66 90                	xchg   %ax,%ax
  800ec6:	66 90                	xchg   %ax,%ax
  800ec8:	66 90                	xchg   %ax,%ax
  800eca:	66 90                	xchg   %ax,%ax
  800ecc:	66 90                	xchg   %ax,%ax
  800ece:	66 90                	xchg   %ax,%ax

00800ed0 <__umoddi3>:
  800ed0:	55                   	push   %ebp
  800ed1:	57                   	push   %edi
  800ed2:	56                   	push   %esi
  800ed3:	53                   	push   %ebx
  800ed4:	83 ec 1c             	sub    $0x1c,%esp
  800ed7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800edb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800edf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ee3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ee7:	85 d2                	test   %edx,%edx
  800ee9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800eed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ef1:	89 f3                	mov    %esi,%ebx
  800ef3:	89 3c 24             	mov    %edi,(%esp)
  800ef6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800efa:	75 1c                	jne    800f18 <__umoddi3+0x48>
  800efc:	39 f7                	cmp    %esi,%edi
  800efe:	76 50                	jbe    800f50 <__umoddi3+0x80>
  800f00:	89 c8                	mov    %ecx,%eax
  800f02:	89 f2                	mov    %esi,%edx
  800f04:	f7 f7                	div    %edi
  800f06:	89 d0                	mov    %edx,%eax
  800f08:	31 d2                	xor    %edx,%edx
  800f0a:	83 c4 1c             	add    $0x1c,%esp
  800f0d:	5b                   	pop    %ebx
  800f0e:	5e                   	pop    %esi
  800f0f:	5f                   	pop    %edi
  800f10:	5d                   	pop    %ebp
  800f11:	c3                   	ret    
  800f12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f18:	39 f2                	cmp    %esi,%edx
  800f1a:	89 d0                	mov    %edx,%eax
  800f1c:	77 52                	ja     800f70 <__umoddi3+0xa0>
  800f1e:	0f bd ea             	bsr    %edx,%ebp
  800f21:	83 f5 1f             	xor    $0x1f,%ebp
  800f24:	75 5a                	jne    800f80 <__umoddi3+0xb0>
  800f26:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f2a:	0f 82 e0 00 00 00    	jb     801010 <__umoddi3+0x140>
  800f30:	39 0c 24             	cmp    %ecx,(%esp)
  800f33:	0f 86 d7 00 00 00    	jbe    801010 <__umoddi3+0x140>
  800f39:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f3d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f41:	83 c4 1c             	add    $0x1c,%esp
  800f44:	5b                   	pop    %ebx
  800f45:	5e                   	pop    %esi
  800f46:	5f                   	pop    %edi
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    
  800f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f50:	85 ff                	test   %edi,%edi
  800f52:	89 fd                	mov    %edi,%ebp
  800f54:	75 0b                	jne    800f61 <__umoddi3+0x91>
  800f56:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5b:	31 d2                	xor    %edx,%edx
  800f5d:	f7 f7                	div    %edi
  800f5f:	89 c5                	mov    %eax,%ebp
  800f61:	89 f0                	mov    %esi,%eax
  800f63:	31 d2                	xor    %edx,%edx
  800f65:	f7 f5                	div    %ebp
  800f67:	89 c8                	mov    %ecx,%eax
  800f69:	f7 f5                	div    %ebp
  800f6b:	89 d0                	mov    %edx,%eax
  800f6d:	eb 99                	jmp    800f08 <__umoddi3+0x38>
  800f6f:	90                   	nop
  800f70:	89 c8                	mov    %ecx,%eax
  800f72:	89 f2                	mov    %esi,%edx
  800f74:	83 c4 1c             	add    $0x1c,%esp
  800f77:	5b                   	pop    %ebx
  800f78:	5e                   	pop    %esi
  800f79:	5f                   	pop    %edi
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    
  800f7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f80:	8b 34 24             	mov    (%esp),%esi
  800f83:	bf 20 00 00 00       	mov    $0x20,%edi
  800f88:	89 e9                	mov    %ebp,%ecx
  800f8a:	29 ef                	sub    %ebp,%edi
  800f8c:	d3 e0                	shl    %cl,%eax
  800f8e:	89 f9                	mov    %edi,%ecx
  800f90:	89 f2                	mov    %esi,%edx
  800f92:	d3 ea                	shr    %cl,%edx
  800f94:	89 e9                	mov    %ebp,%ecx
  800f96:	09 c2                	or     %eax,%edx
  800f98:	89 d8                	mov    %ebx,%eax
  800f9a:	89 14 24             	mov    %edx,(%esp)
  800f9d:	89 f2                	mov    %esi,%edx
  800f9f:	d3 e2                	shl    %cl,%edx
  800fa1:	89 f9                	mov    %edi,%ecx
  800fa3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fa7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800fab:	d3 e8                	shr    %cl,%eax
  800fad:	89 e9                	mov    %ebp,%ecx
  800faf:	89 c6                	mov    %eax,%esi
  800fb1:	d3 e3                	shl    %cl,%ebx
  800fb3:	89 f9                	mov    %edi,%ecx
  800fb5:	89 d0                	mov    %edx,%eax
  800fb7:	d3 e8                	shr    %cl,%eax
  800fb9:	89 e9                	mov    %ebp,%ecx
  800fbb:	09 d8                	or     %ebx,%eax
  800fbd:	89 d3                	mov    %edx,%ebx
  800fbf:	89 f2                	mov    %esi,%edx
  800fc1:	f7 34 24             	divl   (%esp)
  800fc4:	89 d6                	mov    %edx,%esi
  800fc6:	d3 e3                	shl    %cl,%ebx
  800fc8:	f7 64 24 04          	mull   0x4(%esp)
  800fcc:	39 d6                	cmp    %edx,%esi
  800fce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fd2:	89 d1                	mov    %edx,%ecx
  800fd4:	89 c3                	mov    %eax,%ebx
  800fd6:	72 08                	jb     800fe0 <__umoddi3+0x110>
  800fd8:	75 11                	jne    800feb <__umoddi3+0x11b>
  800fda:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800fde:	73 0b                	jae    800feb <__umoddi3+0x11b>
  800fe0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800fe4:	1b 14 24             	sbb    (%esp),%edx
  800fe7:	89 d1                	mov    %edx,%ecx
  800fe9:	89 c3                	mov    %eax,%ebx
  800feb:	8b 54 24 08          	mov    0x8(%esp),%edx
  800fef:	29 da                	sub    %ebx,%edx
  800ff1:	19 ce                	sbb    %ecx,%esi
  800ff3:	89 f9                	mov    %edi,%ecx
  800ff5:	89 f0                	mov    %esi,%eax
  800ff7:	d3 e0                	shl    %cl,%eax
  800ff9:	89 e9                	mov    %ebp,%ecx
  800ffb:	d3 ea                	shr    %cl,%edx
  800ffd:	89 e9                	mov    %ebp,%ecx
  800fff:	d3 ee                	shr    %cl,%esi
  801001:	09 d0                	or     %edx,%eax
  801003:	89 f2                	mov    %esi,%edx
  801005:	83 c4 1c             	add    $0x1c,%esp
  801008:	5b                   	pop    %ebx
  801009:	5e                   	pop    %esi
  80100a:	5f                   	pop    %edi
  80100b:	5d                   	pop    %ebp
  80100c:	c3                   	ret    
  80100d:	8d 76 00             	lea    0x0(%esi),%esi
  801010:	29 f9                	sub    %edi,%ecx
  801012:	19 d6                	sbb    %edx,%esi
  801014:	89 74 24 04          	mov    %esi,0x4(%esp)
  801018:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80101c:	e9 18 ff ff ff       	jmp    800f39 <__umoddi3+0x69>
