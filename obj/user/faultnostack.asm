
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
  800039:	68 17 03 80 00       	push   $0x800317
  80003e:	6a 00                	push   $0x0
  800040:	e8 2c 02 00 00       	call   800271 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
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
	
	thisenv = envs+ENVX(sys_getenvid());
  80005f:	e8 c6 00 00 00       	call   80012a <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a0:	6a 00                	push   $0x0
  8000a2:	e8 42 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7e 17                	jle    800122 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	50                   	push   %eax
  80010f:	6a 03                	push   $0x3
  800111:	68 4a 10 80 00       	push   $0x80104a
  800116:	6a 23                	push   $0x23
  800118:	68 67 10 80 00       	push   $0x801067
  80011d:	e8 19 02 00 00       	call   80033b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800122:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5f                   	pop    %edi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 02 00 00 00       	mov    $0x2,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_yield>:

void
sys_yield(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 0a 00 00 00       	mov    $0xa,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800171:	be 00 00 00 00       	mov    $0x0,%esi
  800176:	b8 04 00 00 00       	mov    $0x4,%eax
  80017b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017e:	8b 55 08             	mov    0x8(%ebp),%edx
  800181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800184:	89 f7                	mov    %esi,%edi
  800186:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800188:	85 c0                	test   %eax,%eax
  80018a:	7e 17                	jle    8001a3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018c:	83 ec 0c             	sub    $0xc,%esp
  80018f:	50                   	push   %eax
  800190:	6a 04                	push   $0x4
  800192:	68 4a 10 80 00       	push   $0x80104a
  800197:	6a 23                	push   $0x23
  800199:	68 67 10 80 00       	push   $0x801067
  80019e:	e8 98 01 00 00       	call   80033b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a6:	5b                   	pop    %ebx
  8001a7:	5e                   	pop    %esi
  8001a8:	5f                   	pop    %edi
  8001a9:	5d                   	pop    %ebp
  8001aa:	c3                   	ret    

008001ab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	7e 17                	jle    8001e5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	50                   	push   %eax
  8001d2:	6a 05                	push   $0x5
  8001d4:	68 4a 10 80 00       	push   $0x80104a
  8001d9:	6a 23                	push   $0x23
  8001db:	68 67 10 80 00       	push   $0x801067
  8001e0:	e8 56 01 00 00       	call   80033b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5e                   	pop    %esi
  8001ea:	5f                   	pop    %edi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fb:	b8 06 00 00 00       	mov    $0x6,%eax
  800200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800203:	8b 55 08             	mov    0x8(%ebp),%edx
  800206:	89 df                	mov    %ebx,%edi
  800208:	89 de                	mov    %ebx,%esi
  80020a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7e 17                	jle    800227 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	50                   	push   %eax
  800214:	6a 06                	push   $0x6
  800216:	68 4a 10 80 00       	push   $0x80104a
  80021b:	6a 23                	push   $0x23
  80021d:	68 67 10 80 00       	push   $0x801067
  800222:	e8 14 01 00 00       	call   80033b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800227:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022a:	5b                   	pop    %ebx
  80022b:	5e                   	pop    %esi
  80022c:	5f                   	pop    %edi
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    

0080022f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	b8 08 00 00 00       	mov    $0x8,%eax
  800242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800245:	8b 55 08             	mov    0x8(%ebp),%edx
  800248:	89 df                	mov    %ebx,%edi
  80024a:	89 de                	mov    %ebx,%esi
  80024c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024e:	85 c0                	test   %eax,%eax
  800250:	7e 17                	jle    800269 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800252:	83 ec 0c             	sub    $0xc,%esp
  800255:	50                   	push   %eax
  800256:	6a 08                	push   $0x8
  800258:	68 4a 10 80 00       	push   $0x80104a
  80025d:	6a 23                	push   $0x23
  80025f:	68 67 10 80 00       	push   $0x801067
  800264:	e8 d2 00 00 00       	call   80033b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800269:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026c:	5b                   	pop    %ebx
  80026d:	5e                   	pop    %esi
  80026e:	5f                   	pop    %edi
  80026f:	5d                   	pop    %ebp
  800270:	c3                   	ret    

00800271 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	57                   	push   %edi
  800275:	56                   	push   %esi
  800276:	53                   	push   %ebx
  800277:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027f:	b8 09 00 00 00       	mov    $0x9,%eax
  800284:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800287:	8b 55 08             	mov    0x8(%ebp),%edx
  80028a:	89 df                	mov    %ebx,%edi
  80028c:	89 de                	mov    %ebx,%esi
  80028e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800290:	85 c0                	test   %eax,%eax
  800292:	7e 17                	jle    8002ab <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800294:	83 ec 0c             	sub    $0xc,%esp
  800297:	50                   	push   %eax
  800298:	6a 09                	push   $0x9
  80029a:	68 4a 10 80 00       	push   $0x80104a
  80029f:	6a 23                	push   $0x23
  8002a1:	68 67 10 80 00       	push   $0x801067
  8002a6:	e8 90 00 00 00       	call   80033b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5f                   	pop    %edi
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b9:	be 00 00 00 00       	mov    $0x0,%esi
  8002be:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002cf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ec:	89 cb                	mov    %ecx,%ebx
  8002ee:	89 cf                	mov    %ecx,%edi
  8002f0:	89 ce                	mov    %ecx,%esi
  8002f2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	7e 17                	jle    80030f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	50                   	push   %eax
  8002fc:	6a 0c                	push   $0xc
  8002fe:	68 4a 10 80 00       	push   $0x80104a
  800303:	6a 23                	push   $0x23
  800305:	68 67 10 80 00       	push   $0x801067
  80030a:	e8 2c 00 00 00       	call   80033b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80030f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800312:	5b                   	pop    %ebx
  800313:	5e                   	pop    %esi
  800314:	5f                   	pop    %edi
  800315:	5d                   	pop    %ebp
  800316:	c3                   	ret    

00800317 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800317:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800318:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80031d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80031f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx #trap-time eip
  800322:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)
  800326:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax #trap-time esp-4
  80032b:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)
  80032f:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp
  800331:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  800334:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp #eip
  800335:	83 c4 04             	add    $0x4,%esp
	popfl
  800338:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800339:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80033a:	c3                   	ret    

0080033b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	56                   	push   %esi
  80033f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800340:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800343:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800349:	e8 dc fd ff ff       	call   80012a <sys_getenvid>
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	ff 75 0c             	pushl  0xc(%ebp)
  800354:	ff 75 08             	pushl  0x8(%ebp)
  800357:	56                   	push   %esi
  800358:	50                   	push   %eax
  800359:	68 78 10 80 00       	push   $0x801078
  80035e:	e8 b1 00 00 00       	call   800414 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800363:	83 c4 18             	add    $0x18,%esp
  800366:	53                   	push   %ebx
  800367:	ff 75 10             	pushl  0x10(%ebp)
  80036a:	e8 54 00 00 00       	call   8003c3 <vcprintf>
	cprintf("\n");
  80036f:	c7 04 24 9b 10 80 00 	movl   $0x80109b,(%esp)
  800376:	e8 99 00 00 00       	call   800414 <cprintf>
  80037b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80037e:	cc                   	int3   
  80037f:	eb fd                	jmp    80037e <_panic+0x43>

00800381 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	53                   	push   %ebx
  800385:	83 ec 04             	sub    $0x4,%esp
  800388:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80038b:	8b 13                	mov    (%ebx),%edx
  80038d:	8d 42 01             	lea    0x1(%edx),%eax
  800390:	89 03                	mov    %eax,(%ebx)
  800392:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800395:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800399:	3d ff 00 00 00       	cmp    $0xff,%eax
  80039e:	75 1a                	jne    8003ba <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003a0:	83 ec 08             	sub    $0x8,%esp
  8003a3:	68 ff 00 00 00       	push   $0xff
  8003a8:	8d 43 08             	lea    0x8(%ebx),%eax
  8003ab:	50                   	push   %eax
  8003ac:	e8 fb fc ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8003b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003b7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003ba:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003c1:	c9                   	leave  
  8003c2:	c3                   	ret    

008003c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d3:	00 00 00 
	b.cnt = 0;
  8003d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e0:	ff 75 0c             	pushl  0xc(%ebp)
  8003e3:	ff 75 08             	pushl  0x8(%ebp)
  8003e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ec:	50                   	push   %eax
  8003ed:	68 81 03 80 00       	push   $0x800381
  8003f2:	e8 54 01 00 00       	call   80054b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003f7:	83 c4 08             	add    $0x8,%esp
  8003fa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800400:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800406:	50                   	push   %eax
  800407:	e8 a0 fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  80040c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800412:	c9                   	leave  
  800413:	c3                   	ret    

00800414 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800414:	55                   	push   %ebp
  800415:	89 e5                	mov    %esp,%ebp
  800417:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80041a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80041d:	50                   	push   %eax
  80041e:	ff 75 08             	pushl  0x8(%ebp)
  800421:	e8 9d ff ff ff       	call   8003c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	57                   	push   %edi
  80042c:	56                   	push   %esi
  80042d:	53                   	push   %ebx
  80042e:	83 ec 1c             	sub    $0x1c,%esp
  800431:	89 c7                	mov    %eax,%edi
  800433:	89 d6                	mov    %edx,%esi
  800435:	8b 45 08             	mov    0x8(%ebp),%eax
  800438:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80043e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800441:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800444:	bb 00 00 00 00       	mov    $0x0,%ebx
  800449:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80044c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80044f:	39 d3                	cmp    %edx,%ebx
  800451:	72 05                	jb     800458 <printnum+0x30>
  800453:	39 45 10             	cmp    %eax,0x10(%ebp)
  800456:	77 45                	ja     80049d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800458:	83 ec 0c             	sub    $0xc,%esp
  80045b:	ff 75 18             	pushl  0x18(%ebp)
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800464:	53                   	push   %ebx
  800465:	ff 75 10             	pushl  0x10(%ebp)
  800468:	83 ec 08             	sub    $0x8,%esp
  80046b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80046e:	ff 75 e0             	pushl  -0x20(%ebp)
  800471:	ff 75 dc             	pushl  -0x24(%ebp)
  800474:	ff 75 d8             	pushl  -0x28(%ebp)
  800477:	e8 24 09 00 00       	call   800da0 <__udivdi3>
  80047c:	83 c4 18             	add    $0x18,%esp
  80047f:	52                   	push   %edx
  800480:	50                   	push   %eax
  800481:	89 f2                	mov    %esi,%edx
  800483:	89 f8                	mov    %edi,%eax
  800485:	e8 9e ff ff ff       	call   800428 <printnum>
  80048a:	83 c4 20             	add    $0x20,%esp
  80048d:	eb 18                	jmp    8004a7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80048f:	83 ec 08             	sub    $0x8,%esp
  800492:	56                   	push   %esi
  800493:	ff 75 18             	pushl  0x18(%ebp)
  800496:	ff d7                	call   *%edi
  800498:	83 c4 10             	add    $0x10,%esp
  80049b:	eb 03                	jmp    8004a0 <printnum+0x78>
  80049d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004a0:	83 eb 01             	sub    $0x1,%ebx
  8004a3:	85 db                	test   %ebx,%ebx
  8004a5:	7f e8                	jg     80048f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	56                   	push   %esi
  8004ab:	83 ec 04             	sub    $0x4,%esp
  8004ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8004b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ba:	e8 11 0a 00 00       	call   800ed0 <__umoddi3>
  8004bf:	83 c4 14             	add    $0x14,%esp
  8004c2:	0f be 80 9d 10 80 00 	movsbl 0x80109d(%eax),%eax
  8004c9:	50                   	push   %eax
  8004ca:	ff d7                	call   *%edi
}
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004d2:	5b                   	pop    %ebx
  8004d3:	5e                   	pop    %esi
  8004d4:	5f                   	pop    %edi
  8004d5:	5d                   	pop    %ebp
  8004d6:	c3                   	ret    

008004d7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004d7:	55                   	push   %ebp
  8004d8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004da:	83 fa 01             	cmp    $0x1,%edx
  8004dd:	7e 0e                	jle    8004ed <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004df:	8b 10                	mov    (%eax),%edx
  8004e1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004e4:	89 08                	mov    %ecx,(%eax)
  8004e6:	8b 02                	mov    (%edx),%eax
  8004e8:	8b 52 04             	mov    0x4(%edx),%edx
  8004eb:	eb 22                	jmp    80050f <getuint+0x38>
	else if (lflag)
  8004ed:	85 d2                	test   %edx,%edx
  8004ef:	74 10                	je     800501 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004f1:	8b 10                	mov    (%eax),%edx
  8004f3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f6:	89 08                	mov    %ecx,(%eax)
  8004f8:	8b 02                	mov    (%edx),%eax
  8004fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ff:	eb 0e                	jmp    80050f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800501:	8b 10                	mov    (%eax),%edx
  800503:	8d 4a 04             	lea    0x4(%edx),%ecx
  800506:	89 08                	mov    %ecx,(%eax)
  800508:	8b 02                	mov    (%edx),%eax
  80050a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80050f:	5d                   	pop    %ebp
  800510:	c3                   	ret    

00800511 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800511:	55                   	push   %ebp
  800512:	89 e5                	mov    %esp,%ebp
  800514:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800517:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80051b:	8b 10                	mov    (%eax),%edx
  80051d:	3b 50 04             	cmp    0x4(%eax),%edx
  800520:	73 0a                	jae    80052c <sprintputch+0x1b>
		*b->buf++ = ch;
  800522:	8d 4a 01             	lea    0x1(%edx),%ecx
  800525:	89 08                	mov    %ecx,(%eax)
  800527:	8b 45 08             	mov    0x8(%ebp),%eax
  80052a:	88 02                	mov    %al,(%edx)
}
  80052c:	5d                   	pop    %ebp
  80052d:	c3                   	ret    

0080052e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80052e:	55                   	push   %ebp
  80052f:	89 e5                	mov    %esp,%ebp
  800531:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800534:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800537:	50                   	push   %eax
  800538:	ff 75 10             	pushl  0x10(%ebp)
  80053b:	ff 75 0c             	pushl  0xc(%ebp)
  80053e:	ff 75 08             	pushl  0x8(%ebp)
  800541:	e8 05 00 00 00       	call   80054b <vprintfmt>
	va_end(ap);
}
  800546:	83 c4 10             	add    $0x10,%esp
  800549:	c9                   	leave  
  80054a:	c3                   	ret    

0080054b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80054b:	55                   	push   %ebp
  80054c:	89 e5                	mov    %esp,%ebp
  80054e:	57                   	push   %edi
  80054f:	56                   	push   %esi
  800550:	53                   	push   %ebx
  800551:	83 ec 2c             	sub    $0x2c,%esp
  800554:	8b 75 08             	mov    0x8(%ebp),%esi
  800557:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80055a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80055d:	eb 1d                	jmp    80057c <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80055f:	85 c0                	test   %eax,%eax
  800561:	75 0f                	jne    800572 <vprintfmt+0x27>
				csa = 0x0700;
  800563:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80056a:	07 00 00 
				return;
  80056d:	e9 c4 03 00 00       	jmp    800936 <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  800572:	83 ec 08             	sub    $0x8,%esp
  800575:	53                   	push   %ebx
  800576:	50                   	push   %eax
  800577:	ff d6                	call   *%esi
  800579:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80057c:	83 c7 01             	add    $0x1,%edi
  80057f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800583:	83 f8 25             	cmp    $0x25,%eax
  800586:	75 d7                	jne    80055f <vprintfmt+0x14>
  800588:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80058c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800593:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80059a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a6:	eb 07                	jmp    8005af <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005ab:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005af:	8d 47 01             	lea    0x1(%edi),%eax
  8005b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005b5:	0f b6 07             	movzbl (%edi),%eax
  8005b8:	0f b6 c8             	movzbl %al,%ecx
  8005bb:	83 e8 23             	sub    $0x23,%eax
  8005be:	3c 55                	cmp    $0x55,%al
  8005c0:	0f 87 55 03 00 00    	ja     80091b <vprintfmt+0x3d0>
  8005c6:	0f b6 c0             	movzbl %al,%eax
  8005c9:	ff 24 85 60 11 80 00 	jmp    *0x801160(,%eax,4)
  8005d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005d3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005d7:	eb d6                	jmp    8005af <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005e4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005e7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005eb:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005ee:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005f1:	83 fa 09             	cmp    $0x9,%edx
  8005f4:	77 39                	ja     80062f <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005f6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005f9:	eb e9                	jmp    8005e4 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 48 04             	lea    0x4(%eax),%ecx
  800601:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800604:	8b 00                	mov    (%eax),%eax
  800606:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800609:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80060c:	eb 27                	jmp    800635 <vprintfmt+0xea>
  80060e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800611:	85 c0                	test   %eax,%eax
  800613:	b9 00 00 00 00       	mov    $0x0,%ecx
  800618:	0f 49 c8             	cmovns %eax,%ecx
  80061b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800621:	eb 8c                	jmp    8005af <vprintfmt+0x64>
  800623:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800626:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80062d:	eb 80                	jmp    8005af <vprintfmt+0x64>
  80062f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800632:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800635:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800639:	0f 89 70 ff ff ff    	jns    8005af <vprintfmt+0x64>
				width = precision, precision = -1;
  80063f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800642:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800645:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80064c:	e9 5e ff ff ff       	jmp    8005af <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800651:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800654:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800657:	e9 53 ff ff ff       	jmp    8005af <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8d 50 04             	lea    0x4(%eax),%edx
  800662:	89 55 14             	mov    %edx,0x14(%ebp)
  800665:	83 ec 08             	sub    $0x8,%esp
  800668:	53                   	push   %ebx
  800669:	ff 30                	pushl  (%eax)
  80066b:	ff d6                	call   *%esi
			break;
  80066d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800670:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800673:	e9 04 ff ff ff       	jmp    80057c <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8d 50 04             	lea    0x4(%eax),%edx
  80067e:	89 55 14             	mov    %edx,0x14(%ebp)
  800681:	8b 00                	mov    (%eax),%eax
  800683:	99                   	cltd   
  800684:	31 d0                	xor    %edx,%eax
  800686:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800688:	83 f8 08             	cmp    $0x8,%eax
  80068b:	7f 0b                	jg     800698 <vprintfmt+0x14d>
  80068d:	8b 14 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edx
  800694:	85 d2                	test   %edx,%edx
  800696:	75 18                	jne    8006b0 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  800698:	50                   	push   %eax
  800699:	68 b5 10 80 00       	push   $0x8010b5
  80069e:	53                   	push   %ebx
  80069f:	56                   	push   %esi
  8006a0:	e8 89 fe ff ff       	call   80052e <printfmt>
  8006a5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006ab:	e9 cc fe ff ff       	jmp    80057c <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8006b0:	52                   	push   %edx
  8006b1:	68 be 10 80 00       	push   $0x8010be
  8006b6:	53                   	push   %ebx
  8006b7:	56                   	push   %esi
  8006b8:	e8 71 fe ff ff       	call   80052e <printfmt>
  8006bd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c3:	e9 b4 fe ff ff       	jmp    80057c <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8d 50 04             	lea    0x4(%eax),%edx
  8006ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006d3:	85 ff                	test   %edi,%edi
  8006d5:	b8 ae 10 80 00       	mov    $0x8010ae,%eax
  8006da:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006e1:	0f 8e 94 00 00 00    	jle    80077b <vprintfmt+0x230>
  8006e7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006eb:	0f 84 98 00 00 00    	je     800789 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f1:	83 ec 08             	sub    $0x8,%esp
  8006f4:	ff 75 d0             	pushl  -0x30(%ebp)
  8006f7:	57                   	push   %edi
  8006f8:	e8 c1 02 00 00       	call   8009be <strnlen>
  8006fd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800700:	29 c1                	sub    %eax,%ecx
  800702:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800705:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800708:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80070c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80070f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800712:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800714:	eb 0f                	jmp    800725 <vprintfmt+0x1da>
					putch(padc, putdat);
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	53                   	push   %ebx
  80071a:	ff 75 e0             	pushl  -0x20(%ebp)
  80071d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80071f:	83 ef 01             	sub    $0x1,%edi
  800722:	83 c4 10             	add    $0x10,%esp
  800725:	85 ff                	test   %edi,%edi
  800727:	7f ed                	jg     800716 <vprintfmt+0x1cb>
  800729:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80072c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80072f:	85 c9                	test   %ecx,%ecx
  800731:	b8 00 00 00 00       	mov    $0x0,%eax
  800736:	0f 49 c1             	cmovns %ecx,%eax
  800739:	29 c1                	sub    %eax,%ecx
  80073b:	89 75 08             	mov    %esi,0x8(%ebp)
  80073e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800741:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800744:	89 cb                	mov    %ecx,%ebx
  800746:	eb 4d                	jmp    800795 <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800748:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80074c:	74 1b                	je     800769 <vprintfmt+0x21e>
  80074e:	0f be c0             	movsbl %al,%eax
  800751:	83 e8 20             	sub    $0x20,%eax
  800754:	83 f8 5e             	cmp    $0x5e,%eax
  800757:	76 10                	jbe    800769 <vprintfmt+0x21e>
					putch('?', putdat);
  800759:	83 ec 08             	sub    $0x8,%esp
  80075c:	ff 75 0c             	pushl  0xc(%ebp)
  80075f:	6a 3f                	push   $0x3f
  800761:	ff 55 08             	call   *0x8(%ebp)
  800764:	83 c4 10             	add    $0x10,%esp
  800767:	eb 0d                	jmp    800776 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  800769:	83 ec 08             	sub    $0x8,%esp
  80076c:	ff 75 0c             	pushl  0xc(%ebp)
  80076f:	52                   	push   %edx
  800770:	ff 55 08             	call   *0x8(%ebp)
  800773:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800776:	83 eb 01             	sub    $0x1,%ebx
  800779:	eb 1a                	jmp    800795 <vprintfmt+0x24a>
  80077b:	89 75 08             	mov    %esi,0x8(%ebp)
  80077e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800781:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800784:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800787:	eb 0c                	jmp    800795 <vprintfmt+0x24a>
  800789:	89 75 08             	mov    %esi,0x8(%ebp)
  80078c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80078f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800792:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800795:	83 c7 01             	add    $0x1,%edi
  800798:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80079c:	0f be d0             	movsbl %al,%edx
  80079f:	85 d2                	test   %edx,%edx
  8007a1:	74 23                	je     8007c6 <vprintfmt+0x27b>
  8007a3:	85 f6                	test   %esi,%esi
  8007a5:	78 a1                	js     800748 <vprintfmt+0x1fd>
  8007a7:	83 ee 01             	sub    $0x1,%esi
  8007aa:	79 9c                	jns    800748 <vprintfmt+0x1fd>
  8007ac:	89 df                	mov    %ebx,%edi
  8007ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007b4:	eb 18                	jmp    8007ce <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007b6:	83 ec 08             	sub    $0x8,%esp
  8007b9:	53                   	push   %ebx
  8007ba:	6a 20                	push   $0x20
  8007bc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007be:	83 ef 01             	sub    $0x1,%edi
  8007c1:	83 c4 10             	add    $0x10,%esp
  8007c4:	eb 08                	jmp    8007ce <vprintfmt+0x283>
  8007c6:	89 df                	mov    %ebx,%edi
  8007c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ce:	85 ff                	test   %edi,%edi
  8007d0:	7f e4                	jg     8007b6 <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007d5:	e9 a2 fd ff ff       	jmp    80057c <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007da:	83 fa 01             	cmp    $0x1,%edx
  8007dd:	7e 16                	jle    8007f5 <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	8d 50 08             	lea    0x8(%eax),%edx
  8007e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e8:	8b 50 04             	mov    0x4(%eax),%edx
  8007eb:	8b 00                	mov    (%eax),%eax
  8007ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007f3:	eb 32                	jmp    800827 <vprintfmt+0x2dc>
	else if (lflag)
  8007f5:	85 d2                	test   %edx,%edx
  8007f7:	74 18                	je     800811 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  8007f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fc:	8d 50 04             	lea    0x4(%eax),%edx
  8007ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800802:	8b 00                	mov    (%eax),%eax
  800804:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800807:	89 c1                	mov    %eax,%ecx
  800809:	c1 f9 1f             	sar    $0x1f,%ecx
  80080c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80080f:	eb 16                	jmp    800827 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  800811:	8b 45 14             	mov    0x14(%ebp),%eax
  800814:	8d 50 04             	lea    0x4(%eax),%edx
  800817:	89 55 14             	mov    %edx,0x14(%ebp)
  80081a:	8b 00                	mov    (%eax),%eax
  80081c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80081f:	89 c1                	mov    %eax,%ecx
  800821:	c1 f9 1f             	sar    $0x1f,%ecx
  800824:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800827:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80082a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80082d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800832:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800836:	79 74                	jns    8008ac <vprintfmt+0x361>
				putch('-', putdat);
  800838:	83 ec 08             	sub    $0x8,%esp
  80083b:	53                   	push   %ebx
  80083c:	6a 2d                	push   $0x2d
  80083e:	ff d6                	call   *%esi
				num = -(long long) num;
  800840:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800843:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800846:	f7 d8                	neg    %eax
  800848:	83 d2 00             	adc    $0x0,%edx
  80084b:	f7 da                	neg    %edx
  80084d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800850:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800855:	eb 55                	jmp    8008ac <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800857:	8d 45 14             	lea    0x14(%ebp),%eax
  80085a:	e8 78 fc ff ff       	call   8004d7 <getuint>
			base = 10;
  80085f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800864:	eb 46                	jmp    8008ac <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800866:	8d 45 14             	lea    0x14(%ebp),%eax
  800869:	e8 69 fc ff ff       	call   8004d7 <getuint>
      base = 8;
  80086e:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800873:	eb 37                	jmp    8008ac <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  800875:	83 ec 08             	sub    $0x8,%esp
  800878:	53                   	push   %ebx
  800879:	6a 30                	push   $0x30
  80087b:	ff d6                	call   *%esi
			putch('x', putdat);
  80087d:	83 c4 08             	add    $0x8,%esp
  800880:	53                   	push   %ebx
  800881:	6a 78                	push   $0x78
  800883:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800885:	8b 45 14             	mov    0x14(%ebp),%eax
  800888:	8d 50 04             	lea    0x4(%eax),%edx
  80088b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80088e:	8b 00                	mov    (%eax),%eax
  800890:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800895:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800898:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80089d:	eb 0d                	jmp    8008ac <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80089f:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a2:	e8 30 fc ff ff       	call   8004d7 <getuint>
			base = 16;
  8008a7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008ac:	83 ec 0c             	sub    $0xc,%esp
  8008af:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008b3:	57                   	push   %edi
  8008b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8008b7:	51                   	push   %ecx
  8008b8:	52                   	push   %edx
  8008b9:	50                   	push   %eax
  8008ba:	89 da                	mov    %ebx,%edx
  8008bc:	89 f0                	mov    %esi,%eax
  8008be:	e8 65 fb ff ff       	call   800428 <printnum>
			break;
  8008c3:	83 c4 20             	add    $0x20,%esp
  8008c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008c9:	e9 ae fc ff ff       	jmp    80057c <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008ce:	83 ec 08             	sub    $0x8,%esp
  8008d1:	53                   	push   %ebx
  8008d2:	51                   	push   %ecx
  8008d3:	ff d6                	call   *%esi
			break;
  8008d5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008db:	e9 9c fc ff ff       	jmp    80057c <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008e0:	83 fa 01             	cmp    $0x1,%edx
  8008e3:	7e 0d                	jle    8008f2 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8008e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e8:	8d 50 08             	lea    0x8(%eax),%edx
  8008eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ee:	8b 00                	mov    (%eax),%eax
  8008f0:	eb 1c                	jmp    80090e <vprintfmt+0x3c3>
	else if (lflag)
  8008f2:	85 d2                	test   %edx,%edx
  8008f4:	74 0d                	je     800903 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  8008f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f9:	8d 50 04             	lea    0x4(%eax),%edx
  8008fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ff:	8b 00                	mov    (%eax),%eax
  800901:	eb 0b                	jmp    80090e <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  800903:	8b 45 14             	mov    0x14(%ebp),%eax
  800906:	8d 50 04             	lea    0x4(%eax),%edx
  800909:	89 55 14             	mov    %edx,0x14(%ebp)
  80090c:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  80090e:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800913:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  800916:	e9 61 fc ff ff       	jmp    80057c <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80091b:	83 ec 08             	sub    $0x8,%esp
  80091e:	53                   	push   %ebx
  80091f:	6a 25                	push   $0x25
  800921:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800923:	83 c4 10             	add    $0x10,%esp
  800926:	eb 03                	jmp    80092b <vprintfmt+0x3e0>
  800928:	83 ef 01             	sub    $0x1,%edi
  80092b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80092f:	75 f7                	jne    800928 <vprintfmt+0x3dd>
  800931:	e9 46 fc ff ff       	jmp    80057c <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  800936:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800939:	5b                   	pop    %ebx
  80093a:	5e                   	pop    %esi
  80093b:	5f                   	pop    %edi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	83 ec 18             	sub    $0x18,%esp
  800944:	8b 45 08             	mov    0x8(%ebp),%eax
  800947:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80094a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80094d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800951:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800954:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80095b:	85 c0                	test   %eax,%eax
  80095d:	74 26                	je     800985 <vsnprintf+0x47>
  80095f:	85 d2                	test   %edx,%edx
  800961:	7e 22                	jle    800985 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800963:	ff 75 14             	pushl  0x14(%ebp)
  800966:	ff 75 10             	pushl  0x10(%ebp)
  800969:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80096c:	50                   	push   %eax
  80096d:	68 11 05 80 00       	push   $0x800511
  800972:	e8 d4 fb ff ff       	call   80054b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800977:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80097a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80097d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800980:	83 c4 10             	add    $0x10,%esp
  800983:	eb 05                	jmp    80098a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800985:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    

0080098c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800992:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800995:	50                   	push   %eax
  800996:	ff 75 10             	pushl  0x10(%ebp)
  800999:	ff 75 0c             	pushl  0xc(%ebp)
  80099c:	ff 75 08             	pushl  0x8(%ebp)
  80099f:	e8 9a ff ff ff       	call   80093e <vsnprintf>
	va_end(ap);

	return rc;
}
  8009a4:	c9                   	leave  
  8009a5:	c3                   	ret    

008009a6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b1:	eb 03                	jmp    8009b6 <strlen+0x10>
		n++;
  8009b3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009ba:	75 f7                	jne    8009b3 <strlen+0xd>
		n++;
	return n;
}
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cc:	eb 03                	jmp    8009d1 <strnlen+0x13>
		n++;
  8009ce:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d1:	39 c2                	cmp    %eax,%edx
  8009d3:	74 08                	je     8009dd <strnlen+0x1f>
  8009d5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009d9:	75 f3                	jne    8009ce <strnlen+0x10>
  8009db:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	53                   	push   %ebx
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009e9:	89 c2                	mov    %eax,%edx
  8009eb:	83 c2 01             	add    $0x1,%edx
  8009ee:	83 c1 01             	add    $0x1,%ecx
  8009f1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009f5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009f8:	84 db                	test   %bl,%bl
  8009fa:	75 ef                	jne    8009eb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009fc:	5b                   	pop    %ebx
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	53                   	push   %ebx
  800a03:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a06:	53                   	push   %ebx
  800a07:	e8 9a ff ff ff       	call   8009a6 <strlen>
  800a0c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a0f:	ff 75 0c             	pushl  0xc(%ebp)
  800a12:	01 d8                	add    %ebx,%eax
  800a14:	50                   	push   %eax
  800a15:	e8 c5 ff ff ff       	call   8009df <strcpy>
	return dst;
}
  800a1a:	89 d8                	mov    %ebx,%eax
  800a1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a1f:	c9                   	leave  
  800a20:	c3                   	ret    

00800a21 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	56                   	push   %esi
  800a25:	53                   	push   %ebx
  800a26:	8b 75 08             	mov    0x8(%ebp),%esi
  800a29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2c:	89 f3                	mov    %esi,%ebx
  800a2e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a31:	89 f2                	mov    %esi,%edx
  800a33:	eb 0f                	jmp    800a44 <strncpy+0x23>
		*dst++ = *src;
  800a35:	83 c2 01             	add    $0x1,%edx
  800a38:	0f b6 01             	movzbl (%ecx),%eax
  800a3b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a3e:	80 39 01             	cmpb   $0x1,(%ecx)
  800a41:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a44:	39 da                	cmp    %ebx,%edx
  800a46:	75 ed                	jne    800a35 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a48:	89 f0                	mov    %esi,%eax
  800a4a:	5b                   	pop    %ebx
  800a4b:	5e                   	pop    %esi
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	56                   	push   %esi
  800a52:	53                   	push   %ebx
  800a53:	8b 75 08             	mov    0x8(%ebp),%esi
  800a56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a59:	8b 55 10             	mov    0x10(%ebp),%edx
  800a5c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a5e:	85 d2                	test   %edx,%edx
  800a60:	74 21                	je     800a83 <strlcpy+0x35>
  800a62:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a66:	89 f2                	mov    %esi,%edx
  800a68:	eb 09                	jmp    800a73 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a6a:	83 c2 01             	add    $0x1,%edx
  800a6d:	83 c1 01             	add    $0x1,%ecx
  800a70:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a73:	39 c2                	cmp    %eax,%edx
  800a75:	74 09                	je     800a80 <strlcpy+0x32>
  800a77:	0f b6 19             	movzbl (%ecx),%ebx
  800a7a:	84 db                	test   %bl,%bl
  800a7c:	75 ec                	jne    800a6a <strlcpy+0x1c>
  800a7e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a80:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a83:	29 f0                	sub    %esi,%eax
}
  800a85:	5b                   	pop    %ebx
  800a86:	5e                   	pop    %esi
  800a87:	5d                   	pop    %ebp
  800a88:	c3                   	ret    

00800a89 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a89:	55                   	push   %ebp
  800a8a:	89 e5                	mov    %esp,%ebp
  800a8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a92:	eb 06                	jmp    800a9a <strcmp+0x11>
		p++, q++;
  800a94:	83 c1 01             	add    $0x1,%ecx
  800a97:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a9a:	0f b6 01             	movzbl (%ecx),%eax
  800a9d:	84 c0                	test   %al,%al
  800a9f:	74 04                	je     800aa5 <strcmp+0x1c>
  800aa1:	3a 02                	cmp    (%edx),%al
  800aa3:	74 ef                	je     800a94 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa5:	0f b6 c0             	movzbl %al,%eax
  800aa8:	0f b6 12             	movzbl (%edx),%edx
  800aab:	29 d0                	sub    %edx,%eax
}
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	53                   	push   %ebx
  800ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab9:	89 c3                	mov    %eax,%ebx
  800abb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800abe:	eb 06                	jmp    800ac6 <strncmp+0x17>
		n--, p++, q++;
  800ac0:	83 c0 01             	add    $0x1,%eax
  800ac3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ac6:	39 d8                	cmp    %ebx,%eax
  800ac8:	74 15                	je     800adf <strncmp+0x30>
  800aca:	0f b6 08             	movzbl (%eax),%ecx
  800acd:	84 c9                	test   %cl,%cl
  800acf:	74 04                	je     800ad5 <strncmp+0x26>
  800ad1:	3a 0a                	cmp    (%edx),%cl
  800ad3:	74 eb                	je     800ac0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad5:	0f b6 00             	movzbl (%eax),%eax
  800ad8:	0f b6 12             	movzbl (%edx),%edx
  800adb:	29 d0                	sub    %edx,%eax
  800add:	eb 05                	jmp    800ae4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800adf:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ae4:	5b                   	pop    %ebx
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	8b 45 08             	mov    0x8(%ebp),%eax
  800aed:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af1:	eb 07                	jmp    800afa <strchr+0x13>
		if (*s == c)
  800af3:	38 ca                	cmp    %cl,%dl
  800af5:	74 0f                	je     800b06 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800af7:	83 c0 01             	add    $0x1,%eax
  800afa:	0f b6 10             	movzbl (%eax),%edx
  800afd:	84 d2                	test   %dl,%dl
  800aff:	75 f2                	jne    800af3 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b01:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    

00800b08 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b12:	eb 03                	jmp    800b17 <strfind+0xf>
  800b14:	83 c0 01             	add    $0x1,%eax
  800b17:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b1a:	38 ca                	cmp    %cl,%dl
  800b1c:	74 04                	je     800b22 <strfind+0x1a>
  800b1e:	84 d2                	test   %dl,%dl
  800b20:	75 f2                	jne    800b14 <strfind+0xc>
			break;
	return (char *) s;
}
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
  800b2a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b2d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b30:	85 c9                	test   %ecx,%ecx
  800b32:	74 36                	je     800b6a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b34:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b3a:	75 28                	jne    800b64 <memset+0x40>
  800b3c:	f6 c1 03             	test   $0x3,%cl
  800b3f:	75 23                	jne    800b64 <memset+0x40>
		c &= 0xFF;
  800b41:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b45:	89 d3                	mov    %edx,%ebx
  800b47:	c1 e3 08             	shl    $0x8,%ebx
  800b4a:	89 d6                	mov    %edx,%esi
  800b4c:	c1 e6 18             	shl    $0x18,%esi
  800b4f:	89 d0                	mov    %edx,%eax
  800b51:	c1 e0 10             	shl    $0x10,%eax
  800b54:	09 f0                	or     %esi,%eax
  800b56:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b58:	89 d8                	mov    %ebx,%eax
  800b5a:	09 d0                	or     %edx,%eax
  800b5c:	c1 e9 02             	shr    $0x2,%ecx
  800b5f:	fc                   	cld    
  800b60:	f3 ab                	rep stos %eax,%es:(%edi)
  800b62:	eb 06                	jmp    800b6a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b64:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b67:	fc                   	cld    
  800b68:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b6a:	89 f8                	mov    %edi,%eax
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	8b 45 08             	mov    0x8(%ebp),%eax
  800b79:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b7f:	39 c6                	cmp    %eax,%esi
  800b81:	73 35                	jae    800bb8 <memmove+0x47>
  800b83:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b86:	39 d0                	cmp    %edx,%eax
  800b88:	73 2e                	jae    800bb8 <memmove+0x47>
		s += n;
		d += n;
  800b8a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b8d:	89 d6                	mov    %edx,%esi
  800b8f:	09 fe                	or     %edi,%esi
  800b91:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b97:	75 13                	jne    800bac <memmove+0x3b>
  800b99:	f6 c1 03             	test   $0x3,%cl
  800b9c:	75 0e                	jne    800bac <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b9e:	83 ef 04             	sub    $0x4,%edi
  800ba1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ba4:	c1 e9 02             	shr    $0x2,%ecx
  800ba7:	fd                   	std    
  800ba8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800baa:	eb 09                	jmp    800bb5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bac:	83 ef 01             	sub    $0x1,%edi
  800baf:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bb2:	fd                   	std    
  800bb3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bb5:	fc                   	cld    
  800bb6:	eb 1d                	jmp    800bd5 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb8:	89 f2                	mov    %esi,%edx
  800bba:	09 c2                	or     %eax,%edx
  800bbc:	f6 c2 03             	test   $0x3,%dl
  800bbf:	75 0f                	jne    800bd0 <memmove+0x5f>
  800bc1:	f6 c1 03             	test   $0x3,%cl
  800bc4:	75 0a                	jne    800bd0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bc6:	c1 e9 02             	shr    $0x2,%ecx
  800bc9:	89 c7                	mov    %eax,%edi
  800bcb:	fc                   	cld    
  800bcc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bce:	eb 05                	jmp    800bd5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bd0:	89 c7                	mov    %eax,%edi
  800bd2:	fc                   	cld    
  800bd3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bdc:	ff 75 10             	pushl  0x10(%ebp)
  800bdf:	ff 75 0c             	pushl  0xc(%ebp)
  800be2:	ff 75 08             	pushl  0x8(%ebp)
  800be5:	e8 87 ff ff ff       	call   800b71 <memmove>
}
  800bea:	c9                   	leave  
  800beb:	c3                   	ret    

00800bec <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bf7:	89 c6                	mov    %eax,%esi
  800bf9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bfc:	eb 1a                	jmp    800c18 <memcmp+0x2c>
		if (*s1 != *s2)
  800bfe:	0f b6 08             	movzbl (%eax),%ecx
  800c01:	0f b6 1a             	movzbl (%edx),%ebx
  800c04:	38 d9                	cmp    %bl,%cl
  800c06:	74 0a                	je     800c12 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c08:	0f b6 c1             	movzbl %cl,%eax
  800c0b:	0f b6 db             	movzbl %bl,%ebx
  800c0e:	29 d8                	sub    %ebx,%eax
  800c10:	eb 0f                	jmp    800c21 <memcmp+0x35>
		s1++, s2++;
  800c12:	83 c0 01             	add    $0x1,%eax
  800c15:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c18:	39 f0                	cmp    %esi,%eax
  800c1a:	75 e2                	jne    800bfe <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	53                   	push   %ebx
  800c29:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c2c:	89 c1                	mov    %eax,%ecx
  800c2e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c31:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c35:	eb 0a                	jmp    800c41 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c37:	0f b6 10             	movzbl (%eax),%edx
  800c3a:	39 da                	cmp    %ebx,%edx
  800c3c:	74 07                	je     800c45 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c3e:	83 c0 01             	add    $0x1,%eax
  800c41:	39 c8                	cmp    %ecx,%eax
  800c43:	72 f2                	jb     800c37 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c45:	5b                   	pop    %ebx
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c54:	eb 03                	jmp    800c59 <strtol+0x11>
		s++;
  800c56:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c59:	0f b6 01             	movzbl (%ecx),%eax
  800c5c:	3c 20                	cmp    $0x20,%al
  800c5e:	74 f6                	je     800c56 <strtol+0xe>
  800c60:	3c 09                	cmp    $0x9,%al
  800c62:	74 f2                	je     800c56 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c64:	3c 2b                	cmp    $0x2b,%al
  800c66:	75 0a                	jne    800c72 <strtol+0x2a>
		s++;
  800c68:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c6b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c70:	eb 11                	jmp    800c83 <strtol+0x3b>
  800c72:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c77:	3c 2d                	cmp    $0x2d,%al
  800c79:	75 08                	jne    800c83 <strtol+0x3b>
		s++, neg = 1;
  800c7b:	83 c1 01             	add    $0x1,%ecx
  800c7e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c83:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c89:	75 15                	jne    800ca0 <strtol+0x58>
  800c8b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c8e:	75 10                	jne    800ca0 <strtol+0x58>
  800c90:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c94:	75 7c                	jne    800d12 <strtol+0xca>
		s += 2, base = 16;
  800c96:	83 c1 02             	add    $0x2,%ecx
  800c99:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c9e:	eb 16                	jmp    800cb6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ca0:	85 db                	test   %ebx,%ebx
  800ca2:	75 12                	jne    800cb6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ca4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca9:	80 39 30             	cmpb   $0x30,(%ecx)
  800cac:	75 08                	jne    800cb6 <strtol+0x6e>
		s++, base = 8;
  800cae:	83 c1 01             	add    $0x1,%ecx
  800cb1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800cbb:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cbe:	0f b6 11             	movzbl (%ecx),%edx
  800cc1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cc4:	89 f3                	mov    %esi,%ebx
  800cc6:	80 fb 09             	cmp    $0x9,%bl
  800cc9:	77 08                	ja     800cd3 <strtol+0x8b>
			dig = *s - '0';
  800ccb:	0f be d2             	movsbl %dl,%edx
  800cce:	83 ea 30             	sub    $0x30,%edx
  800cd1:	eb 22                	jmp    800cf5 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cd3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cd6:	89 f3                	mov    %esi,%ebx
  800cd8:	80 fb 19             	cmp    $0x19,%bl
  800cdb:	77 08                	ja     800ce5 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cdd:	0f be d2             	movsbl %dl,%edx
  800ce0:	83 ea 57             	sub    $0x57,%edx
  800ce3:	eb 10                	jmp    800cf5 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ce5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ce8:	89 f3                	mov    %esi,%ebx
  800cea:	80 fb 19             	cmp    $0x19,%bl
  800ced:	77 16                	ja     800d05 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cef:	0f be d2             	movsbl %dl,%edx
  800cf2:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cf5:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cf8:	7d 0b                	jge    800d05 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cfa:	83 c1 01             	add    $0x1,%ecx
  800cfd:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d01:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d03:	eb b9                	jmp    800cbe <strtol+0x76>

	if (endptr)
  800d05:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d09:	74 0d                	je     800d18 <strtol+0xd0>
		*endptr = (char *) s;
  800d0b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d0e:	89 0e                	mov    %ecx,(%esi)
  800d10:	eb 06                	jmp    800d18 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d12:	85 db                	test   %ebx,%ebx
  800d14:	74 98                	je     800cae <strtol+0x66>
  800d16:	eb 9e                	jmp    800cb6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d18:	89 c2                	mov    %eax,%edx
  800d1a:	f7 da                	neg    %edx
  800d1c:	85 ff                	test   %edi,%edi
  800d1e:	0f 45 c2             	cmovne %edx,%eax
}
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	83 ec 08             	sub    $0x8,%esp
	// int r;

	if (_pgfault_handler == 0) {
  800d2c:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  800d33:	75 2c                	jne    800d61 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  800d35:	83 ec 04             	sub    $0x4,%esp
  800d38:	6a 07                	push   $0x7
  800d3a:	68 00 f0 bf ee       	push   $0xeebff000
  800d3f:	6a 00                	push   $0x0
  800d41:	e8 22 f4 ff ff       	call   800168 <sys_page_alloc>
  800d46:	83 c4 10             	add    $0x10,%esp
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	79 14                	jns    800d61 <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");;
  800d4d:	83 ec 04             	sub    $0x4,%esp
  800d50:	68 e4 12 80 00       	push   $0x8012e4
  800d55:	6a 21                	push   $0x21
  800d57:	68 48 13 80 00       	push   $0x801348
  800d5c:	e8 da f5 ff ff       	call   80033b <_panic>
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d61:	8b 45 08             	mov    0x8(%ebp),%eax
  800d64:	a3 0c 20 80 00       	mov    %eax,0x80200c
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800d69:	83 ec 08             	sub    $0x8,%esp
  800d6c:	68 17 03 80 00       	push   $0x800317
  800d71:	6a 00                	push   $0x0
  800d73:	e8 f9 f4 ff ff       	call   800271 <sys_env_set_pgfault_upcall>
  800d78:	83 c4 10             	add    $0x10,%esp
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	79 14                	jns    800d93 <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  800d7f:	83 ec 04             	sub    $0x4,%esp
  800d82:	68 10 13 80 00       	push   $0x801310
  800d87:	6a 26                	push   $0x26
  800d89:	68 48 13 80 00       	push   $0x801348
  800d8e:	e8 a8 f5 ff ff       	call   80033b <_panic>
}
  800d93:	c9                   	leave  
  800d94:	c3                   	ret    
  800d95:	66 90                	xchg   %ax,%ax
  800d97:	66 90                	xchg   %ax,%ax
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
