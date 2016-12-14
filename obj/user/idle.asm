
obj/user/idle.debug:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  800039:	c7 05 00 30 80 00 20 	movl   $0x802320,0x803000
  800040:	23 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 ff 00 00 00       	call   800147 <sys_yield>
  800048:	eb f9                	jmp    800043 <umain+0x10>

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800055:	e8 ce 00 00 00       	call   800128 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800096:	e8 6b 05 00 00       	call   800606 <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 42 00 00 00       	call   8000e7 <sys_env_destroy>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fd:	89 cb                	mov    %ecx,%ebx
  8000ff:	89 cf                	mov    %ecx,%edi
  800101:	89 ce                	mov    %ecx,%esi
  800103:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800105:	85 c0                	test   %eax,%eax
  800107:	7e 17                	jle    800120 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	50                   	push   %eax
  80010d:	6a 03                	push   $0x3
  80010f:	68 2f 23 80 00       	push   $0x80232f
  800114:	6a 23                	push   $0x23
  800116:	68 4c 23 80 00       	push   $0x80234c
  80011b:	e8 95 14 00 00       	call   8015b5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5f                   	pop    %edi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 02 00 00 00       	mov    $0x2,%eax
  800138:	89 d1                	mov    %edx,%ecx
  80013a:	89 d3                	mov    %edx,%ebx
  80013c:	89 d7                	mov    %edx,%edi
  80013e:	89 d6                	mov    %edx,%esi
  800140:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_yield>:

void
sys_yield(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 0b 00 00 00       	mov    $0xb,%eax
  800157:	89 d1                	mov    %edx,%ecx
  800159:	89 d3                	mov    %edx,%ebx
  80015b:	89 d7                	mov    %edx,%edi
  80015d:	89 d6                	mov    %edx,%esi
  80015f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016f:	be 00 00 00 00       	mov    $0x0,%esi
  800174:	b8 04 00 00 00       	mov    $0x4,%eax
  800179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800182:	89 f7                	mov    %esi,%edi
  800184:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800186:	85 c0                	test   %eax,%eax
  800188:	7e 17                	jle    8001a1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	6a 04                	push   $0x4
  800190:	68 2f 23 80 00       	push   $0x80232f
  800195:	6a 23                	push   $0x23
  800197:	68 4c 23 80 00       	push   $0x80234c
  80019c:	e8 14 14 00 00       	call   8015b5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a4:	5b                   	pop    %ebx
  8001a5:	5e                   	pop    %esi
  8001a6:	5f                   	pop    %edi
  8001a7:	5d                   	pop    %ebp
  8001a8:	c3                   	ret    

008001a9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	7e 17                	jle    8001e3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	50                   	push   %eax
  8001d0:	6a 05                	push   $0x5
  8001d2:	68 2f 23 80 00       	push   $0x80232f
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 4c 23 80 00       	push   $0x80234c
  8001de:	e8 d2 13 00 00       	call   8015b5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5e                   	pop    %esi
  8001e8:	5f                   	pop    %edi
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    

008001eb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	8b 55 08             	mov    0x8(%ebp),%edx
  800204:	89 df                	mov    %ebx,%edi
  800206:	89 de                	mov    %ebx,%esi
  800208:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80020a:	85 c0                	test   %eax,%eax
  80020c:	7e 17                	jle    800225 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	6a 06                	push   $0x6
  800214:	68 2f 23 80 00       	push   $0x80232f
  800219:	6a 23                	push   $0x23
  80021b:	68 4c 23 80 00       	push   $0x80234c
  800220:	e8 90 13 00 00       	call   8015b5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800228:	5b                   	pop    %ebx
  800229:	5e                   	pop    %esi
  80022a:	5f                   	pop    %edi
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    

0080022d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	b8 08 00 00 00       	mov    $0x8,%eax
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	8b 55 08             	mov    0x8(%ebp),%edx
  800246:	89 df                	mov    %ebx,%edi
  800248:	89 de                	mov    %ebx,%esi
  80024a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024c:	85 c0                	test   %eax,%eax
  80024e:	7e 17                	jle    800267 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	50                   	push   %eax
  800254:	6a 08                	push   $0x8
  800256:	68 2f 23 80 00       	push   $0x80232f
  80025b:	6a 23                	push   $0x23
  80025d:	68 4c 23 80 00       	push   $0x80234c
  800262:	e8 4e 13 00 00       	call   8015b5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	b8 09 00 00 00       	mov    $0x9,%eax
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	8b 55 08             	mov    0x8(%ebp),%edx
  800288:	89 df                	mov    %ebx,%edi
  80028a:	89 de                	mov    %ebx,%esi
  80028c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7e 17                	jle    8002a9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	50                   	push   %eax
  800296:	6a 09                	push   $0x9
  800298:	68 2f 23 80 00       	push   $0x80232f
  80029d:	6a 23                	push   $0x23
  80029f:	68 4c 23 80 00       	push   $0x80234c
  8002a4:	e8 0c 13 00 00       	call   8015b5 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ca:	89 df                	mov    %ebx,%edi
  8002cc:	89 de                	mov    %ebx,%esi
  8002ce:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	7e 17                	jle    8002eb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	50                   	push   %eax
  8002d8:	6a 0a                	push   $0xa
  8002da:	68 2f 23 80 00       	push   $0x80232f
  8002df:	6a 23                	push   $0x23
  8002e1:	68 4c 23 80 00       	push   $0x80234c
  8002e6:	e8 ca 12 00 00       	call   8015b5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f9:	be 00 00 00 00       	mov    $0x0,%esi
  8002fe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800303:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800324:	b8 0d 00 00 00       	mov    $0xd,%eax
  800329:	8b 55 08             	mov    0x8(%ebp),%edx
  80032c:	89 cb                	mov    %ecx,%ebx
  80032e:	89 cf                	mov    %ecx,%edi
  800330:	89 ce                	mov    %ecx,%esi
  800332:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800334:	85 c0                	test   %eax,%eax
  800336:	7e 17                	jle    80034f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800338:	83 ec 0c             	sub    $0xc,%esp
  80033b:	50                   	push   %eax
  80033c:	6a 0d                	push   $0xd
  80033e:	68 2f 23 80 00       	push   $0x80232f
  800343:	6a 23                	push   $0x23
  800345:	68 4c 23 80 00       	push   $0x80234c
  80034a:	e8 66 12 00 00       	call   8015b5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800352:	5b                   	pop    %ebx
  800353:	5e                   	pop    %esi
  800354:	5f                   	pop    %edi
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	57                   	push   %edi
  80035b:	56                   	push   %esi
  80035c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
  800362:	b8 0e 00 00 00       	mov    $0xe,%eax
  800367:	89 d1                	mov    %edx,%ecx
  800369:	89 d3                	mov    %edx,%ebx
  80036b:	89 d7                	mov    %edx,%edi
  80036d:	89 d6                	mov    %edx,%esi
  80036f:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800371:	5b                   	pop    %ebx
  800372:	5e                   	pop    %esi
  800373:	5f                   	pop    %edi
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <sys_transmit_packet>:

int
sys_transmit_packet(void *buf, size_t size)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	57                   	push   %edi
  80037a:	56                   	push   %esi
  80037b:	53                   	push   %ebx
  80037c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80037f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800384:	b8 0f 00 00 00       	mov    $0xf,%eax
  800389:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80038c:	8b 55 08             	mov    0x8(%ebp),%edx
  80038f:	89 df                	mov    %ebx,%edi
  800391:	89 de                	mov    %ebx,%esi
  800393:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800395:	85 c0                	test   %eax,%eax
  800397:	7e 17                	jle    8003b0 <sys_transmit_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800399:	83 ec 0c             	sub    $0xc,%esp
  80039c:	50                   	push   %eax
  80039d:	6a 0f                	push   $0xf
  80039f:	68 2f 23 80 00       	push   $0x80232f
  8003a4:	6a 23                	push   $0x23
  8003a6:	68 4c 23 80 00       	push   $0x80234c
  8003ab:	e8 05 12 00 00       	call   8015b5 <_panic>
int
sys_transmit_packet(void *buf, size_t size)
{
	return syscall(SYS_transmit_packet, 1,
		(uint32_t) buf, (uint32_t) size, 0, 0, 0);
}
  8003b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b3:	5b                   	pop    %ebx
  8003b4:	5e                   	pop    %esi
  8003b5:	5f                   	pop    %edi
  8003b6:	5d                   	pop    %ebp
  8003b7:	c3                   	ret    

008003b8 <sys_receive_packet>:

int
sys_receive_packet(void *buf, size_t *size_store)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
  8003bb:	57                   	push   %edi
  8003bc:	56                   	push   %esi
  8003bd:	53                   	push   %ebx
  8003be:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003c6:	b8 10 00 00 00       	mov    $0x10,%eax
  8003cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d1:	89 df                	mov    %ebx,%edi
  8003d3:	89 de                	mov    %ebx,%esi
  8003d5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003d7:	85 c0                	test   %eax,%eax
  8003d9:	7e 17                	jle    8003f2 <sys_receive_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003db:	83 ec 0c             	sub    $0xc,%esp
  8003de:	50                   	push   %eax
  8003df:	6a 10                	push   $0x10
  8003e1:	68 2f 23 80 00       	push   $0x80232f
  8003e6:	6a 23                	push   $0x23
  8003e8:	68 4c 23 80 00       	push   $0x80234c
  8003ed:	e8 c3 11 00 00       	call   8015b5 <_panic>
int
sys_receive_packet(void *buf, size_t *size_store)
{
	return syscall(SYS_receive_packet, 1,
		(uint32_t) buf, (uint32_t) size_store, 0, 0, 0);
}
  8003f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003f5:	5b                   	pop    %ebx
  8003f6:	5e                   	pop    %esi
  8003f7:	5f                   	pop    %edi
  8003f8:	5d                   	pop    %ebp
  8003f9:	c3                   	ret    

008003fa <sys_get_mac_address>:

int
sys_get_mac_address(void *buf)
{
  8003fa:	55                   	push   %ebp
  8003fb:	89 e5                	mov    %esp,%ebp
  8003fd:	57                   	push   %edi
  8003fe:	56                   	push   %esi
  8003ff:	53                   	push   %ebx
  800400:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800403:	b9 00 00 00 00       	mov    $0x0,%ecx
  800408:	b8 11 00 00 00       	mov    $0x11,%eax
  80040d:	8b 55 08             	mov    0x8(%ebp),%edx
  800410:	89 cb                	mov    %ecx,%ebx
  800412:	89 cf                	mov    %ecx,%edi
  800414:	89 ce                	mov    %ecx,%esi
  800416:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800418:	85 c0                	test   %eax,%eax
  80041a:	7e 17                	jle    800433 <sys_get_mac_address+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80041c:	83 ec 0c             	sub    $0xc,%esp
  80041f:	50                   	push   %eax
  800420:	6a 11                	push   $0x11
  800422:	68 2f 23 80 00       	push   $0x80232f
  800427:	6a 23                	push   $0x23
  800429:	68 4c 23 80 00       	push   $0x80234c
  80042e:	e8 82 11 00 00       	call   8015b5 <_panic>
int
sys_get_mac_address(void *buf)
{
	return syscall(SYS_get_mac_address, 1,
		(uint32_t) buf, 0, 0, 0, 0);
}
  800433:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800436:	5b                   	pop    %ebx
  800437:	5e                   	pop    %esi
  800438:	5f                   	pop    %edi
  800439:	5d                   	pop    %ebp
  80043a:	c3                   	ret    

0080043b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80043b:	55                   	push   %ebp
  80043c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80043e:	8b 45 08             	mov    0x8(%ebp),%eax
  800441:	05 00 00 00 30       	add    $0x30000000,%eax
  800446:	c1 e8 0c             	shr    $0xc,%eax
}
  800449:	5d                   	pop    %ebp
  80044a:	c3                   	ret    

0080044b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80044b:	55                   	push   %ebp
  80044c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80044e:	8b 45 08             	mov    0x8(%ebp),%eax
  800451:	05 00 00 00 30       	add    $0x30000000,%eax
  800456:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80045b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800460:	5d                   	pop    %ebp
  800461:	c3                   	ret    

00800462 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800468:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80046d:	89 c2                	mov    %eax,%edx
  80046f:	c1 ea 16             	shr    $0x16,%edx
  800472:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800479:	f6 c2 01             	test   $0x1,%dl
  80047c:	74 11                	je     80048f <fd_alloc+0x2d>
  80047e:	89 c2                	mov    %eax,%edx
  800480:	c1 ea 0c             	shr    $0xc,%edx
  800483:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80048a:	f6 c2 01             	test   $0x1,%dl
  80048d:	75 09                	jne    800498 <fd_alloc+0x36>
			*fd_store = fd;
  80048f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800491:	b8 00 00 00 00       	mov    $0x0,%eax
  800496:	eb 17                	jmp    8004af <fd_alloc+0x4d>
  800498:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80049d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8004a2:	75 c9                	jne    80046d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8004a4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8004aa:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8004af:	5d                   	pop    %ebp
  8004b0:	c3                   	ret    

008004b1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8004b1:	55                   	push   %ebp
  8004b2:	89 e5                	mov    %esp,%ebp
  8004b4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8004b7:	83 f8 1f             	cmp    $0x1f,%eax
  8004ba:	77 36                	ja     8004f2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8004bc:	c1 e0 0c             	shl    $0xc,%eax
  8004bf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8004c4:	89 c2                	mov    %eax,%edx
  8004c6:	c1 ea 16             	shr    $0x16,%edx
  8004c9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004d0:	f6 c2 01             	test   $0x1,%dl
  8004d3:	74 24                	je     8004f9 <fd_lookup+0x48>
  8004d5:	89 c2                	mov    %eax,%edx
  8004d7:	c1 ea 0c             	shr    $0xc,%edx
  8004da:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004e1:	f6 c2 01             	test   $0x1,%dl
  8004e4:	74 1a                	je     800500 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004e9:	89 02                	mov    %eax,(%edx)
	return 0;
  8004eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f0:	eb 13                	jmp    800505 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004f7:	eb 0c                	jmp    800505 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004fe:	eb 05                	jmp    800505 <fd_lookup+0x54>
  800500:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800505:	5d                   	pop    %ebp
  800506:	c3                   	ret    

00800507 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800507:	55                   	push   %ebp
  800508:	89 e5                	mov    %esp,%ebp
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800510:	ba d8 23 80 00       	mov    $0x8023d8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800515:	eb 13                	jmp    80052a <dev_lookup+0x23>
  800517:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80051a:	39 08                	cmp    %ecx,(%eax)
  80051c:	75 0c                	jne    80052a <dev_lookup+0x23>
			*dev = devtab[i];
  80051e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800521:	89 01                	mov    %eax,(%ecx)
			return 0;
  800523:	b8 00 00 00 00       	mov    $0x0,%eax
  800528:	eb 2e                	jmp    800558 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80052a:	8b 02                	mov    (%edx),%eax
  80052c:	85 c0                	test   %eax,%eax
  80052e:	75 e7                	jne    800517 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800530:	a1 08 40 80 00       	mov    0x804008,%eax
  800535:	8b 40 48             	mov    0x48(%eax),%eax
  800538:	83 ec 04             	sub    $0x4,%esp
  80053b:	51                   	push   %ecx
  80053c:	50                   	push   %eax
  80053d:	68 5c 23 80 00       	push   $0x80235c
  800542:	e8 47 11 00 00       	call   80168e <cprintf>
	*dev = 0;
  800547:	8b 45 0c             	mov    0xc(%ebp),%eax
  80054a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800550:	83 c4 10             	add    $0x10,%esp
  800553:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800558:	c9                   	leave  
  800559:	c3                   	ret    

0080055a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80055a:	55                   	push   %ebp
  80055b:	89 e5                	mov    %esp,%ebp
  80055d:	56                   	push   %esi
  80055e:	53                   	push   %ebx
  80055f:	83 ec 10             	sub    $0x10,%esp
  800562:	8b 75 08             	mov    0x8(%ebp),%esi
  800565:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800568:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80056b:	50                   	push   %eax
  80056c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800572:	c1 e8 0c             	shr    $0xc,%eax
  800575:	50                   	push   %eax
  800576:	e8 36 ff ff ff       	call   8004b1 <fd_lookup>
  80057b:	83 c4 08             	add    $0x8,%esp
  80057e:	85 c0                	test   %eax,%eax
  800580:	78 05                	js     800587 <fd_close+0x2d>
	    || fd != fd2)
  800582:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800585:	74 0c                	je     800593 <fd_close+0x39>
		return (must_exist ? r : 0);
  800587:	84 db                	test   %bl,%bl
  800589:	ba 00 00 00 00       	mov    $0x0,%edx
  80058e:	0f 44 c2             	cmove  %edx,%eax
  800591:	eb 41                	jmp    8005d4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800593:	83 ec 08             	sub    $0x8,%esp
  800596:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800599:	50                   	push   %eax
  80059a:	ff 36                	pushl  (%esi)
  80059c:	e8 66 ff ff ff       	call   800507 <dev_lookup>
  8005a1:	89 c3                	mov    %eax,%ebx
  8005a3:	83 c4 10             	add    $0x10,%esp
  8005a6:	85 c0                	test   %eax,%eax
  8005a8:	78 1a                	js     8005c4 <fd_close+0x6a>
		if (dev->dev_close)
  8005aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005ad:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8005b0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8005b5:	85 c0                	test   %eax,%eax
  8005b7:	74 0b                	je     8005c4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8005b9:	83 ec 0c             	sub    $0xc,%esp
  8005bc:	56                   	push   %esi
  8005bd:	ff d0                	call   *%eax
  8005bf:	89 c3                	mov    %eax,%ebx
  8005c1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	56                   	push   %esi
  8005c8:	6a 00                	push   $0x0
  8005ca:	e8 1c fc ff ff       	call   8001eb <sys_page_unmap>
	return r;
  8005cf:	83 c4 10             	add    $0x10,%esp
  8005d2:	89 d8                	mov    %ebx,%eax
}
  8005d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005d7:	5b                   	pop    %ebx
  8005d8:	5e                   	pop    %esi
  8005d9:	5d                   	pop    %ebp
  8005da:	c3                   	ret    

008005db <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005db:	55                   	push   %ebp
  8005dc:	89 e5                	mov    %esp,%ebp
  8005de:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005e4:	50                   	push   %eax
  8005e5:	ff 75 08             	pushl  0x8(%ebp)
  8005e8:	e8 c4 fe ff ff       	call   8004b1 <fd_lookup>
  8005ed:	83 c4 08             	add    $0x8,%esp
  8005f0:	85 c0                	test   %eax,%eax
  8005f2:	78 10                	js     800604 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8005f4:	83 ec 08             	sub    $0x8,%esp
  8005f7:	6a 01                	push   $0x1
  8005f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8005fc:	e8 59 ff ff ff       	call   80055a <fd_close>
  800601:	83 c4 10             	add    $0x10,%esp
}
  800604:	c9                   	leave  
  800605:	c3                   	ret    

00800606 <close_all>:

void
close_all(void)
{
  800606:	55                   	push   %ebp
  800607:	89 e5                	mov    %esp,%ebp
  800609:	53                   	push   %ebx
  80060a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80060d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800612:	83 ec 0c             	sub    $0xc,%esp
  800615:	53                   	push   %ebx
  800616:	e8 c0 ff ff ff       	call   8005db <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80061b:	83 c3 01             	add    $0x1,%ebx
  80061e:	83 c4 10             	add    $0x10,%esp
  800621:	83 fb 20             	cmp    $0x20,%ebx
  800624:	75 ec                	jne    800612 <close_all+0xc>
		close(i);
}
  800626:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800629:	c9                   	leave  
  80062a:	c3                   	ret    

0080062b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80062b:	55                   	push   %ebp
  80062c:	89 e5                	mov    %esp,%ebp
  80062e:	57                   	push   %edi
  80062f:	56                   	push   %esi
  800630:	53                   	push   %ebx
  800631:	83 ec 2c             	sub    $0x2c,%esp
  800634:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800637:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80063a:	50                   	push   %eax
  80063b:	ff 75 08             	pushl  0x8(%ebp)
  80063e:	e8 6e fe ff ff       	call   8004b1 <fd_lookup>
  800643:	83 c4 08             	add    $0x8,%esp
  800646:	85 c0                	test   %eax,%eax
  800648:	0f 88 c1 00 00 00    	js     80070f <dup+0xe4>
		return r;
	close(newfdnum);
  80064e:	83 ec 0c             	sub    $0xc,%esp
  800651:	56                   	push   %esi
  800652:	e8 84 ff ff ff       	call   8005db <close>

	newfd = INDEX2FD(newfdnum);
  800657:	89 f3                	mov    %esi,%ebx
  800659:	c1 e3 0c             	shl    $0xc,%ebx
  80065c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800662:	83 c4 04             	add    $0x4,%esp
  800665:	ff 75 e4             	pushl  -0x1c(%ebp)
  800668:	e8 de fd ff ff       	call   80044b <fd2data>
  80066d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80066f:	89 1c 24             	mov    %ebx,(%esp)
  800672:	e8 d4 fd ff ff       	call   80044b <fd2data>
  800677:	83 c4 10             	add    $0x10,%esp
  80067a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80067d:	89 f8                	mov    %edi,%eax
  80067f:	c1 e8 16             	shr    $0x16,%eax
  800682:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800689:	a8 01                	test   $0x1,%al
  80068b:	74 37                	je     8006c4 <dup+0x99>
  80068d:	89 f8                	mov    %edi,%eax
  80068f:	c1 e8 0c             	shr    $0xc,%eax
  800692:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800699:	f6 c2 01             	test   $0x1,%dl
  80069c:	74 26                	je     8006c4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80069e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006a5:	83 ec 0c             	sub    $0xc,%esp
  8006a8:	25 07 0e 00 00       	and    $0xe07,%eax
  8006ad:	50                   	push   %eax
  8006ae:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006b1:	6a 00                	push   $0x0
  8006b3:	57                   	push   %edi
  8006b4:	6a 00                	push   $0x0
  8006b6:	e8 ee fa ff ff       	call   8001a9 <sys_page_map>
  8006bb:	89 c7                	mov    %eax,%edi
  8006bd:	83 c4 20             	add    $0x20,%esp
  8006c0:	85 c0                	test   %eax,%eax
  8006c2:	78 2e                	js     8006f2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006c7:	89 d0                	mov    %edx,%eax
  8006c9:	c1 e8 0c             	shr    $0xc,%eax
  8006cc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006d3:	83 ec 0c             	sub    $0xc,%esp
  8006d6:	25 07 0e 00 00       	and    $0xe07,%eax
  8006db:	50                   	push   %eax
  8006dc:	53                   	push   %ebx
  8006dd:	6a 00                	push   $0x0
  8006df:	52                   	push   %edx
  8006e0:	6a 00                	push   $0x0
  8006e2:	e8 c2 fa ff ff       	call   8001a9 <sys_page_map>
  8006e7:	89 c7                	mov    %eax,%edi
  8006e9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8006ec:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006ee:	85 ff                	test   %edi,%edi
  8006f0:	79 1d                	jns    80070f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	53                   	push   %ebx
  8006f6:	6a 00                	push   $0x0
  8006f8:	e8 ee fa ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006fd:	83 c4 08             	add    $0x8,%esp
  800700:	ff 75 d4             	pushl  -0x2c(%ebp)
  800703:	6a 00                	push   $0x0
  800705:	e8 e1 fa ff ff       	call   8001eb <sys_page_unmap>
	return r;
  80070a:	83 c4 10             	add    $0x10,%esp
  80070d:	89 f8                	mov    %edi,%eax
}
  80070f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800712:	5b                   	pop    %ebx
  800713:	5e                   	pop    %esi
  800714:	5f                   	pop    %edi
  800715:	5d                   	pop    %ebp
  800716:	c3                   	ret    

00800717 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	53                   	push   %ebx
  80071b:	83 ec 14             	sub    $0x14,%esp
  80071e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800721:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800724:	50                   	push   %eax
  800725:	53                   	push   %ebx
  800726:	e8 86 fd ff ff       	call   8004b1 <fd_lookup>
  80072b:	83 c4 08             	add    $0x8,%esp
  80072e:	89 c2                	mov    %eax,%edx
  800730:	85 c0                	test   %eax,%eax
  800732:	78 6d                	js     8007a1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800734:	83 ec 08             	sub    $0x8,%esp
  800737:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80073a:	50                   	push   %eax
  80073b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073e:	ff 30                	pushl  (%eax)
  800740:	e8 c2 fd ff ff       	call   800507 <dev_lookup>
  800745:	83 c4 10             	add    $0x10,%esp
  800748:	85 c0                	test   %eax,%eax
  80074a:	78 4c                	js     800798 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80074c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80074f:	8b 42 08             	mov    0x8(%edx),%eax
  800752:	83 e0 03             	and    $0x3,%eax
  800755:	83 f8 01             	cmp    $0x1,%eax
  800758:	75 21                	jne    80077b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80075a:	a1 08 40 80 00       	mov    0x804008,%eax
  80075f:	8b 40 48             	mov    0x48(%eax),%eax
  800762:	83 ec 04             	sub    $0x4,%esp
  800765:	53                   	push   %ebx
  800766:	50                   	push   %eax
  800767:	68 9d 23 80 00       	push   $0x80239d
  80076c:	e8 1d 0f 00 00       	call   80168e <cprintf>
		return -E_INVAL;
  800771:	83 c4 10             	add    $0x10,%esp
  800774:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800779:	eb 26                	jmp    8007a1 <read+0x8a>
	}
	if (!dev->dev_read)
  80077b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077e:	8b 40 08             	mov    0x8(%eax),%eax
  800781:	85 c0                	test   %eax,%eax
  800783:	74 17                	je     80079c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800785:	83 ec 04             	sub    $0x4,%esp
  800788:	ff 75 10             	pushl  0x10(%ebp)
  80078b:	ff 75 0c             	pushl  0xc(%ebp)
  80078e:	52                   	push   %edx
  80078f:	ff d0                	call   *%eax
  800791:	89 c2                	mov    %eax,%edx
  800793:	83 c4 10             	add    $0x10,%esp
  800796:	eb 09                	jmp    8007a1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800798:	89 c2                	mov    %eax,%edx
  80079a:	eb 05                	jmp    8007a1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80079c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8007a1:	89 d0                	mov    %edx,%eax
  8007a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a6:	c9                   	leave  
  8007a7:	c3                   	ret    

008007a8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	57                   	push   %edi
  8007ac:	56                   	push   %esi
  8007ad:	53                   	push   %ebx
  8007ae:	83 ec 0c             	sub    $0xc,%esp
  8007b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007b4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007bc:	eb 21                	jmp    8007df <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007be:	83 ec 04             	sub    $0x4,%esp
  8007c1:	89 f0                	mov    %esi,%eax
  8007c3:	29 d8                	sub    %ebx,%eax
  8007c5:	50                   	push   %eax
  8007c6:	89 d8                	mov    %ebx,%eax
  8007c8:	03 45 0c             	add    0xc(%ebp),%eax
  8007cb:	50                   	push   %eax
  8007cc:	57                   	push   %edi
  8007cd:	e8 45 ff ff ff       	call   800717 <read>
		if (m < 0)
  8007d2:	83 c4 10             	add    $0x10,%esp
  8007d5:	85 c0                	test   %eax,%eax
  8007d7:	78 10                	js     8007e9 <readn+0x41>
			return m;
		if (m == 0)
  8007d9:	85 c0                	test   %eax,%eax
  8007db:	74 0a                	je     8007e7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007dd:	01 c3                	add    %eax,%ebx
  8007df:	39 f3                	cmp    %esi,%ebx
  8007e1:	72 db                	jb     8007be <readn+0x16>
  8007e3:	89 d8                	mov    %ebx,%eax
  8007e5:	eb 02                	jmp    8007e9 <readn+0x41>
  8007e7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8007e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ec:	5b                   	pop    %ebx
  8007ed:	5e                   	pop    %esi
  8007ee:	5f                   	pop    %edi
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	53                   	push   %ebx
  8007f5:	83 ec 14             	sub    $0x14,%esp
  8007f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007fe:	50                   	push   %eax
  8007ff:	53                   	push   %ebx
  800800:	e8 ac fc ff ff       	call   8004b1 <fd_lookup>
  800805:	83 c4 08             	add    $0x8,%esp
  800808:	89 c2                	mov    %eax,%edx
  80080a:	85 c0                	test   %eax,%eax
  80080c:	78 68                	js     800876 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80080e:	83 ec 08             	sub    $0x8,%esp
  800811:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800814:	50                   	push   %eax
  800815:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800818:	ff 30                	pushl  (%eax)
  80081a:	e8 e8 fc ff ff       	call   800507 <dev_lookup>
  80081f:	83 c4 10             	add    $0x10,%esp
  800822:	85 c0                	test   %eax,%eax
  800824:	78 47                	js     80086d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800826:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800829:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80082d:	75 21                	jne    800850 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80082f:	a1 08 40 80 00       	mov    0x804008,%eax
  800834:	8b 40 48             	mov    0x48(%eax),%eax
  800837:	83 ec 04             	sub    $0x4,%esp
  80083a:	53                   	push   %ebx
  80083b:	50                   	push   %eax
  80083c:	68 b9 23 80 00       	push   $0x8023b9
  800841:	e8 48 0e 00 00       	call   80168e <cprintf>
		return -E_INVAL;
  800846:	83 c4 10             	add    $0x10,%esp
  800849:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80084e:	eb 26                	jmp    800876 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800850:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800853:	8b 52 0c             	mov    0xc(%edx),%edx
  800856:	85 d2                	test   %edx,%edx
  800858:	74 17                	je     800871 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80085a:	83 ec 04             	sub    $0x4,%esp
  80085d:	ff 75 10             	pushl  0x10(%ebp)
  800860:	ff 75 0c             	pushl  0xc(%ebp)
  800863:	50                   	push   %eax
  800864:	ff d2                	call   *%edx
  800866:	89 c2                	mov    %eax,%edx
  800868:	83 c4 10             	add    $0x10,%esp
  80086b:	eb 09                	jmp    800876 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086d:	89 c2                	mov    %eax,%edx
  80086f:	eb 05                	jmp    800876 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800871:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800876:	89 d0                	mov    %edx,%eax
  800878:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087b:	c9                   	leave  
  80087c:	c3                   	ret    

0080087d <seek>:

int
seek(int fdnum, off_t offset)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800883:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800886:	50                   	push   %eax
  800887:	ff 75 08             	pushl  0x8(%ebp)
  80088a:	e8 22 fc ff ff       	call   8004b1 <fd_lookup>
  80088f:	83 c4 08             	add    $0x8,%esp
  800892:	85 c0                	test   %eax,%eax
  800894:	78 0e                	js     8008a4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800896:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800899:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80089f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a4:	c9                   	leave  
  8008a5:	c3                   	ret    

008008a6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	53                   	push   %ebx
  8008aa:	83 ec 14             	sub    $0x14,%esp
  8008ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008b3:	50                   	push   %eax
  8008b4:	53                   	push   %ebx
  8008b5:	e8 f7 fb ff ff       	call   8004b1 <fd_lookup>
  8008ba:	83 c4 08             	add    $0x8,%esp
  8008bd:	89 c2                	mov    %eax,%edx
  8008bf:	85 c0                	test   %eax,%eax
  8008c1:	78 65                	js     800928 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008c3:	83 ec 08             	sub    $0x8,%esp
  8008c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008c9:	50                   	push   %eax
  8008ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008cd:	ff 30                	pushl  (%eax)
  8008cf:	e8 33 fc ff ff       	call   800507 <dev_lookup>
  8008d4:	83 c4 10             	add    $0x10,%esp
  8008d7:	85 c0                	test   %eax,%eax
  8008d9:	78 44                	js     80091f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008de:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008e2:	75 21                	jne    800905 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008e4:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008e9:	8b 40 48             	mov    0x48(%eax),%eax
  8008ec:	83 ec 04             	sub    $0x4,%esp
  8008ef:	53                   	push   %ebx
  8008f0:	50                   	push   %eax
  8008f1:	68 7c 23 80 00       	push   $0x80237c
  8008f6:	e8 93 0d 00 00       	call   80168e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008fb:	83 c4 10             	add    $0x10,%esp
  8008fe:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800903:	eb 23                	jmp    800928 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800905:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800908:	8b 52 18             	mov    0x18(%edx),%edx
  80090b:	85 d2                	test   %edx,%edx
  80090d:	74 14                	je     800923 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80090f:	83 ec 08             	sub    $0x8,%esp
  800912:	ff 75 0c             	pushl  0xc(%ebp)
  800915:	50                   	push   %eax
  800916:	ff d2                	call   *%edx
  800918:	89 c2                	mov    %eax,%edx
  80091a:	83 c4 10             	add    $0x10,%esp
  80091d:	eb 09                	jmp    800928 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80091f:	89 c2                	mov    %eax,%edx
  800921:	eb 05                	jmp    800928 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800923:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800928:	89 d0                	mov    %edx,%eax
  80092a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	53                   	push   %ebx
  800933:	83 ec 14             	sub    $0x14,%esp
  800936:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800939:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80093c:	50                   	push   %eax
  80093d:	ff 75 08             	pushl  0x8(%ebp)
  800940:	e8 6c fb ff ff       	call   8004b1 <fd_lookup>
  800945:	83 c4 08             	add    $0x8,%esp
  800948:	89 c2                	mov    %eax,%edx
  80094a:	85 c0                	test   %eax,%eax
  80094c:	78 58                	js     8009a6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80094e:	83 ec 08             	sub    $0x8,%esp
  800951:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800954:	50                   	push   %eax
  800955:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800958:	ff 30                	pushl  (%eax)
  80095a:	e8 a8 fb ff ff       	call   800507 <dev_lookup>
  80095f:	83 c4 10             	add    $0x10,%esp
  800962:	85 c0                	test   %eax,%eax
  800964:	78 37                	js     80099d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800966:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800969:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80096d:	74 32                	je     8009a1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80096f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800972:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800979:	00 00 00 
	stat->st_isdir = 0;
  80097c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800983:	00 00 00 
	stat->st_dev = dev;
  800986:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80098c:	83 ec 08             	sub    $0x8,%esp
  80098f:	53                   	push   %ebx
  800990:	ff 75 f0             	pushl  -0x10(%ebp)
  800993:	ff 50 14             	call   *0x14(%eax)
  800996:	89 c2                	mov    %eax,%edx
  800998:	83 c4 10             	add    $0x10,%esp
  80099b:	eb 09                	jmp    8009a6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80099d:	89 c2                	mov    %eax,%edx
  80099f:	eb 05                	jmp    8009a6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8009a1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8009a6:	89 d0                	mov    %edx,%eax
  8009a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ab:	c9                   	leave  
  8009ac:	c3                   	ret    

008009ad <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	56                   	push   %esi
  8009b1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009b2:	83 ec 08             	sub    $0x8,%esp
  8009b5:	6a 00                	push   $0x0
  8009b7:	ff 75 08             	pushl  0x8(%ebp)
  8009ba:	e8 0c 02 00 00       	call   800bcb <open>
  8009bf:	89 c3                	mov    %eax,%ebx
  8009c1:	83 c4 10             	add    $0x10,%esp
  8009c4:	85 c0                	test   %eax,%eax
  8009c6:	78 1b                	js     8009e3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8009c8:	83 ec 08             	sub    $0x8,%esp
  8009cb:	ff 75 0c             	pushl  0xc(%ebp)
  8009ce:	50                   	push   %eax
  8009cf:	e8 5b ff ff ff       	call   80092f <fstat>
  8009d4:	89 c6                	mov    %eax,%esi
	close(fd);
  8009d6:	89 1c 24             	mov    %ebx,(%esp)
  8009d9:	e8 fd fb ff ff       	call   8005db <close>
	return r;
  8009de:	83 c4 10             	add    $0x10,%esp
  8009e1:	89 f0                	mov    %esi,%eax
}
  8009e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009e6:	5b                   	pop    %ebx
  8009e7:	5e                   	pop    %esi
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	56                   	push   %esi
  8009ee:	53                   	push   %ebx
  8009ef:	89 c6                	mov    %eax,%esi
  8009f1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009f3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009fa:	75 12                	jne    800a0e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009fc:	83 ec 0c             	sub    $0xc,%esp
  8009ff:	6a 01                	push   $0x1
  800a01:	e8 11 16 00 00       	call   802017 <ipc_find_env>
  800a06:	a3 00 40 80 00       	mov    %eax,0x804000
  800a0b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a0e:	6a 07                	push   $0x7
  800a10:	68 00 50 80 00       	push   $0x805000
  800a15:	56                   	push   %esi
  800a16:	ff 35 00 40 80 00    	pushl  0x804000
  800a1c:	e8 a2 15 00 00       	call   801fc3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a21:	83 c4 0c             	add    $0xc,%esp
  800a24:	6a 00                	push   $0x0
  800a26:	53                   	push   %ebx
  800a27:	6a 00                	push   $0x0
  800a29:	e8 2c 15 00 00       	call   801f5a <ipc_recv>
}
  800a2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a31:	5b                   	pop    %ebx
  800a32:	5e                   	pop    %esi
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3e:	8b 40 0c             	mov    0xc(%eax),%eax
  800a41:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a49:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a53:	b8 02 00 00 00       	mov    $0x2,%eax
  800a58:	e8 8d ff ff ff       	call   8009ea <fsipc>
}
  800a5d:	c9                   	leave  
  800a5e:	c3                   	ret    

00800a5f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a65:	8b 45 08             	mov    0x8(%ebp),%eax
  800a68:	8b 40 0c             	mov    0xc(%eax),%eax
  800a6b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a70:	ba 00 00 00 00       	mov    $0x0,%edx
  800a75:	b8 06 00 00 00       	mov    $0x6,%eax
  800a7a:	e8 6b ff ff ff       	call   8009ea <fsipc>
}
  800a7f:	c9                   	leave  
  800a80:	c3                   	ret    

00800a81 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	53                   	push   %ebx
  800a85:	83 ec 04             	sub    $0x4,%esp
  800a88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8e:	8b 40 0c             	mov    0xc(%eax),%eax
  800a91:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a96:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9b:	b8 05 00 00 00       	mov    $0x5,%eax
  800aa0:	e8 45 ff ff ff       	call   8009ea <fsipc>
  800aa5:	85 c0                	test   %eax,%eax
  800aa7:	78 2c                	js     800ad5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800aa9:	83 ec 08             	sub    $0x8,%esp
  800aac:	68 00 50 80 00       	push   $0x805000
  800ab1:	53                   	push   %ebx
  800ab2:	e8 5c 11 00 00       	call   801c13 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800ab7:	a1 80 50 80 00       	mov    0x805080,%eax
  800abc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ac2:	a1 84 50 80 00       	mov    0x805084,%eax
  800ac7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800acd:	83 c4 10             	add    $0x10,%esp
  800ad0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ad8:	c9                   	leave  
  800ad9:	c3                   	ret    

00800ada <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	53                   	push   %ebx
  800ade:	83 ec 08             	sub    $0x8,%esp
  800ae1:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800ae4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae7:	8b 52 0c             	mov    0xc(%edx),%edx
  800aea:	89 15 00 50 80 00    	mov    %edx,0x805000
  800af0:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800af5:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800afa:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  800afd:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  800b03:	53                   	push   %ebx
  800b04:	ff 75 0c             	pushl  0xc(%ebp)
  800b07:	68 08 50 80 00       	push   $0x805008
  800b0c:	e8 94 12 00 00       	call   801da5 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  800b11:	ba 00 00 00 00       	mov    $0x0,%edx
  800b16:	b8 04 00 00 00       	mov    $0x4,%eax
  800b1b:	e8 ca fe ff ff       	call   8009ea <fsipc>
  800b20:	83 c4 10             	add    $0x10,%esp
  800b23:	85 c0                	test   %eax,%eax
  800b25:	78 1d                	js     800b44 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  800b27:	39 d8                	cmp    %ebx,%eax
  800b29:	76 19                	jbe    800b44 <devfile_write+0x6a>
  800b2b:	68 ec 23 80 00       	push   $0x8023ec
  800b30:	68 f8 23 80 00       	push   $0x8023f8
  800b35:	68 a5 00 00 00       	push   $0xa5
  800b3a:	68 0d 24 80 00       	push   $0x80240d
  800b3f:	e8 71 0a 00 00       	call   8015b5 <_panic>
	return r;
}
  800b44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b47:	c9                   	leave  
  800b48:	c3                   	ret    

00800b49 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
  800b4e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b51:	8b 45 08             	mov    0x8(%ebp),%eax
  800b54:	8b 40 0c             	mov    0xc(%eax),%eax
  800b57:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b5c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b62:	ba 00 00 00 00       	mov    $0x0,%edx
  800b67:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6c:	e8 79 fe ff ff       	call   8009ea <fsipc>
  800b71:	89 c3                	mov    %eax,%ebx
  800b73:	85 c0                	test   %eax,%eax
  800b75:	78 4b                	js     800bc2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800b77:	39 c6                	cmp    %eax,%esi
  800b79:	73 16                	jae    800b91 <devfile_read+0x48>
  800b7b:	68 18 24 80 00       	push   $0x802418
  800b80:	68 f8 23 80 00       	push   $0x8023f8
  800b85:	6a 7c                	push   $0x7c
  800b87:	68 0d 24 80 00       	push   $0x80240d
  800b8c:	e8 24 0a 00 00       	call   8015b5 <_panic>
	assert(r <= PGSIZE);
  800b91:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b96:	7e 16                	jle    800bae <devfile_read+0x65>
  800b98:	68 1f 24 80 00       	push   $0x80241f
  800b9d:	68 f8 23 80 00       	push   $0x8023f8
  800ba2:	6a 7d                	push   $0x7d
  800ba4:	68 0d 24 80 00       	push   $0x80240d
  800ba9:	e8 07 0a 00 00       	call   8015b5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800bae:	83 ec 04             	sub    $0x4,%esp
  800bb1:	50                   	push   %eax
  800bb2:	68 00 50 80 00       	push   $0x805000
  800bb7:	ff 75 0c             	pushl  0xc(%ebp)
  800bba:	e8 e6 11 00 00       	call   801da5 <memmove>
	return r;
  800bbf:	83 c4 10             	add    $0x10,%esp
}
  800bc2:	89 d8                	mov    %ebx,%eax
  800bc4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	53                   	push   %ebx
  800bcf:	83 ec 20             	sub    $0x20,%esp
  800bd2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800bd5:	53                   	push   %ebx
  800bd6:	e8 ff 0f 00 00       	call   801bda <strlen>
  800bdb:	83 c4 10             	add    $0x10,%esp
  800bde:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800be3:	7f 67                	jg     800c4c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800beb:	50                   	push   %eax
  800bec:	e8 71 f8 ff ff       	call   800462 <fd_alloc>
  800bf1:	83 c4 10             	add    $0x10,%esp
		return r;
  800bf4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800bf6:	85 c0                	test   %eax,%eax
  800bf8:	78 57                	js     800c51 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800bfa:	83 ec 08             	sub    $0x8,%esp
  800bfd:	53                   	push   %ebx
  800bfe:	68 00 50 80 00       	push   $0x805000
  800c03:	e8 0b 10 00 00       	call   801c13 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800c08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800c10:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c13:	b8 01 00 00 00       	mov    $0x1,%eax
  800c18:	e8 cd fd ff ff       	call   8009ea <fsipc>
  800c1d:	89 c3                	mov    %eax,%ebx
  800c1f:	83 c4 10             	add    $0x10,%esp
  800c22:	85 c0                	test   %eax,%eax
  800c24:	79 14                	jns    800c3a <open+0x6f>
		fd_close(fd, 0);
  800c26:	83 ec 08             	sub    $0x8,%esp
  800c29:	6a 00                	push   $0x0
  800c2b:	ff 75 f4             	pushl  -0xc(%ebp)
  800c2e:	e8 27 f9 ff ff       	call   80055a <fd_close>
		return r;
  800c33:	83 c4 10             	add    $0x10,%esp
  800c36:	89 da                	mov    %ebx,%edx
  800c38:	eb 17                	jmp    800c51 <open+0x86>
	}

	return fd2num(fd);
  800c3a:	83 ec 0c             	sub    $0xc,%esp
  800c3d:	ff 75 f4             	pushl  -0xc(%ebp)
  800c40:	e8 f6 f7 ff ff       	call   80043b <fd2num>
  800c45:	89 c2                	mov    %eax,%edx
  800c47:	83 c4 10             	add    $0x10,%esp
  800c4a:	eb 05                	jmp    800c51 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800c4c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800c51:	89 d0                	mov    %edx,%eax
  800c53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c56:	c9                   	leave  
  800c57:	c3                   	ret    

00800c58 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c63:	b8 08 00 00 00       	mov    $0x8,%eax
  800c68:	e8 7d fd ff ff       	call   8009ea <fsipc>
}
  800c6d:	c9                   	leave  
  800c6e:	c3                   	ret    

00800c6f <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800c75:	68 2b 24 80 00       	push   $0x80242b
  800c7a:	ff 75 0c             	pushl  0xc(%ebp)
  800c7d:	e8 91 0f 00 00       	call   801c13 <strcpy>
	return 0;
}
  800c82:	b8 00 00 00 00       	mov    $0x0,%eax
  800c87:	c9                   	leave  
  800c88:	c3                   	ret    

00800c89 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 10             	sub    $0x10,%esp
  800c90:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c93:	53                   	push   %ebx
  800c94:	e8 b7 13 00 00       	call   802050 <pageref>
  800c99:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c9c:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800ca1:	83 f8 01             	cmp    $0x1,%eax
  800ca4:	75 10                	jne    800cb6 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800ca6:	83 ec 0c             	sub    $0xc,%esp
  800ca9:	ff 73 0c             	pushl  0xc(%ebx)
  800cac:	e8 c0 02 00 00       	call   800f71 <nsipc_close>
  800cb1:	89 c2                	mov    %eax,%edx
  800cb3:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800cb6:	89 d0                	mov    %edx,%eax
  800cb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cbb:	c9                   	leave  
  800cbc:	c3                   	ret    

00800cbd <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800cc3:	6a 00                	push   $0x0
  800cc5:	ff 75 10             	pushl  0x10(%ebp)
  800cc8:	ff 75 0c             	pushl  0xc(%ebp)
  800ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cce:	ff 70 0c             	pushl  0xc(%eax)
  800cd1:	e8 78 03 00 00       	call   80104e <nsipc_send>
}
  800cd6:	c9                   	leave  
  800cd7:	c3                   	ret    

00800cd8 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800cde:	6a 00                	push   $0x0
  800ce0:	ff 75 10             	pushl  0x10(%ebp)
  800ce3:	ff 75 0c             	pushl  0xc(%ebp)
  800ce6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce9:	ff 70 0c             	pushl  0xc(%eax)
  800cec:	e8 f1 02 00 00       	call   800fe2 <nsipc_recv>
}
  800cf1:	c9                   	leave  
  800cf2:	c3                   	ret    

00800cf3 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800cf9:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800cfc:	52                   	push   %edx
  800cfd:	50                   	push   %eax
  800cfe:	e8 ae f7 ff ff       	call   8004b1 <fd_lookup>
  800d03:	83 c4 10             	add    $0x10,%esp
  800d06:	85 c0                	test   %eax,%eax
  800d08:	78 17                	js     800d21 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d0d:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800d13:	39 08                	cmp    %ecx,(%eax)
  800d15:	75 05                	jne    800d1c <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800d17:	8b 40 0c             	mov    0xc(%eax),%eax
  800d1a:	eb 05                	jmp    800d21 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800d1c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800d21:	c9                   	leave  
  800d22:	c3                   	ret    

00800d23 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
  800d28:	83 ec 1c             	sub    $0x1c,%esp
  800d2b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800d2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d30:	50                   	push   %eax
  800d31:	e8 2c f7 ff ff       	call   800462 <fd_alloc>
  800d36:	89 c3                	mov    %eax,%ebx
  800d38:	83 c4 10             	add    $0x10,%esp
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	78 1b                	js     800d5a <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800d3f:	83 ec 04             	sub    $0x4,%esp
  800d42:	68 07 04 00 00       	push   $0x407
  800d47:	ff 75 f4             	pushl  -0xc(%ebp)
  800d4a:	6a 00                	push   $0x0
  800d4c:	e8 15 f4 ff ff       	call   800166 <sys_page_alloc>
  800d51:	89 c3                	mov    %eax,%ebx
  800d53:	83 c4 10             	add    $0x10,%esp
  800d56:	85 c0                	test   %eax,%eax
  800d58:	79 10                	jns    800d6a <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800d5a:	83 ec 0c             	sub    $0xc,%esp
  800d5d:	56                   	push   %esi
  800d5e:	e8 0e 02 00 00       	call   800f71 <nsipc_close>
		return r;
  800d63:	83 c4 10             	add    $0x10,%esp
  800d66:	89 d8                	mov    %ebx,%eax
  800d68:	eb 24                	jmp    800d8e <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800d6a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d73:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d78:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800d7f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800d82:	83 ec 0c             	sub    $0xc,%esp
  800d85:	50                   	push   %eax
  800d86:	e8 b0 f6 ff ff       	call   80043b <fd2num>
  800d8b:	83 c4 10             	add    $0x10,%esp
}
  800d8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9e:	e8 50 ff ff ff       	call   800cf3 <fd2sockid>
		return r;
  800da3:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800da5:	85 c0                	test   %eax,%eax
  800da7:	78 1f                	js     800dc8 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800da9:	83 ec 04             	sub    $0x4,%esp
  800dac:	ff 75 10             	pushl  0x10(%ebp)
  800daf:	ff 75 0c             	pushl  0xc(%ebp)
  800db2:	50                   	push   %eax
  800db3:	e8 12 01 00 00       	call   800eca <nsipc_accept>
  800db8:	83 c4 10             	add    $0x10,%esp
		return r;
  800dbb:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	78 07                	js     800dc8 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800dc1:	e8 5d ff ff ff       	call   800d23 <alloc_sockfd>
  800dc6:	89 c1                	mov    %eax,%ecx
}
  800dc8:	89 c8                	mov    %ecx,%eax
  800dca:	c9                   	leave  
  800dcb:	c3                   	ret    

00800dcc <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd5:	e8 19 ff ff ff       	call   800cf3 <fd2sockid>
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	78 12                	js     800df0 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800dde:	83 ec 04             	sub    $0x4,%esp
  800de1:	ff 75 10             	pushl  0x10(%ebp)
  800de4:	ff 75 0c             	pushl  0xc(%ebp)
  800de7:	50                   	push   %eax
  800de8:	e8 2d 01 00 00       	call   800f1a <nsipc_bind>
  800ded:	83 c4 10             	add    $0x10,%esp
}
  800df0:	c9                   	leave  
  800df1:	c3                   	ret    

00800df2 <shutdown>:

int
shutdown(int s, int how)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800df8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfb:	e8 f3 fe ff ff       	call   800cf3 <fd2sockid>
  800e00:	85 c0                	test   %eax,%eax
  800e02:	78 0f                	js     800e13 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800e04:	83 ec 08             	sub    $0x8,%esp
  800e07:	ff 75 0c             	pushl  0xc(%ebp)
  800e0a:	50                   	push   %eax
  800e0b:	e8 3f 01 00 00       	call   800f4f <nsipc_shutdown>
  800e10:	83 c4 10             	add    $0x10,%esp
}
  800e13:	c9                   	leave  
  800e14:	c3                   	ret    

00800e15 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1e:	e8 d0 fe ff ff       	call   800cf3 <fd2sockid>
  800e23:	85 c0                	test   %eax,%eax
  800e25:	78 12                	js     800e39 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800e27:	83 ec 04             	sub    $0x4,%esp
  800e2a:	ff 75 10             	pushl  0x10(%ebp)
  800e2d:	ff 75 0c             	pushl  0xc(%ebp)
  800e30:	50                   	push   %eax
  800e31:	e8 55 01 00 00       	call   800f8b <nsipc_connect>
  800e36:	83 c4 10             	add    $0x10,%esp
}
  800e39:	c9                   	leave  
  800e3a:	c3                   	ret    

00800e3b <listen>:

int
listen(int s, int backlog)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e41:	8b 45 08             	mov    0x8(%ebp),%eax
  800e44:	e8 aa fe ff ff       	call   800cf3 <fd2sockid>
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	78 0f                	js     800e5c <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800e4d:	83 ec 08             	sub    $0x8,%esp
  800e50:	ff 75 0c             	pushl  0xc(%ebp)
  800e53:	50                   	push   %eax
  800e54:	e8 67 01 00 00       	call   800fc0 <nsipc_listen>
  800e59:	83 c4 10             	add    $0x10,%esp
}
  800e5c:	c9                   	leave  
  800e5d:	c3                   	ret    

00800e5e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800e64:	ff 75 10             	pushl  0x10(%ebp)
  800e67:	ff 75 0c             	pushl  0xc(%ebp)
  800e6a:	ff 75 08             	pushl  0x8(%ebp)
  800e6d:	e8 3a 02 00 00       	call   8010ac <nsipc_socket>
  800e72:	83 c4 10             	add    $0x10,%esp
  800e75:	85 c0                	test   %eax,%eax
  800e77:	78 05                	js     800e7e <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800e79:	e8 a5 fe ff ff       	call   800d23 <alloc_sockfd>
}
  800e7e:	c9                   	leave  
  800e7f:	c3                   	ret    

00800e80 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	53                   	push   %ebx
  800e84:	83 ec 04             	sub    $0x4,%esp
  800e87:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800e89:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e90:	75 12                	jne    800ea4 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e92:	83 ec 0c             	sub    $0xc,%esp
  800e95:	6a 02                	push   $0x2
  800e97:	e8 7b 11 00 00       	call   802017 <ipc_find_env>
  800e9c:	a3 04 40 80 00       	mov    %eax,0x804004
  800ea1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800ea4:	6a 07                	push   $0x7
  800ea6:	68 00 60 80 00       	push   $0x806000
  800eab:	53                   	push   %ebx
  800eac:	ff 35 04 40 80 00    	pushl  0x804004
  800eb2:	e8 0c 11 00 00       	call   801fc3 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800eb7:	83 c4 0c             	add    $0xc,%esp
  800eba:	6a 00                	push   $0x0
  800ebc:	6a 00                	push   $0x0
  800ebe:	6a 00                	push   $0x0
  800ec0:	e8 95 10 00 00       	call   801f5a <ipc_recv>
}
  800ec5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec8:	c9                   	leave  
  800ec9:	c3                   	ret    

00800eca <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	56                   	push   %esi
  800ece:	53                   	push   %ebx
  800ecf:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800ed2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800eda:	8b 06                	mov    (%esi),%eax
  800edc:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800ee1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ee6:	e8 95 ff ff ff       	call   800e80 <nsipc>
  800eeb:	89 c3                	mov    %eax,%ebx
  800eed:	85 c0                	test   %eax,%eax
  800eef:	78 20                	js     800f11 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800ef1:	83 ec 04             	sub    $0x4,%esp
  800ef4:	ff 35 10 60 80 00    	pushl  0x806010
  800efa:	68 00 60 80 00       	push   $0x806000
  800eff:	ff 75 0c             	pushl  0xc(%ebp)
  800f02:	e8 9e 0e 00 00       	call   801da5 <memmove>
		*addrlen = ret->ret_addrlen;
  800f07:	a1 10 60 80 00       	mov    0x806010,%eax
  800f0c:	89 06                	mov    %eax,(%esi)
  800f0e:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800f11:	89 d8                	mov    %ebx,%eax
  800f13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f16:	5b                   	pop    %ebx
  800f17:	5e                   	pop    %esi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	53                   	push   %ebx
  800f1e:	83 ec 08             	sub    $0x8,%esp
  800f21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800f24:	8b 45 08             	mov    0x8(%ebp),%eax
  800f27:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800f2c:	53                   	push   %ebx
  800f2d:	ff 75 0c             	pushl  0xc(%ebp)
  800f30:	68 04 60 80 00       	push   $0x806004
  800f35:	e8 6b 0e 00 00       	call   801da5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800f3a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800f40:	b8 02 00 00 00       	mov    $0x2,%eax
  800f45:	e8 36 ff ff ff       	call   800e80 <nsipc>
}
  800f4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f4d:	c9                   	leave  
  800f4e:	c3                   	ret    

00800f4f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800f55:	8b 45 08             	mov    0x8(%ebp),%eax
  800f58:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800f5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f60:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800f65:	b8 03 00 00 00       	mov    $0x3,%eax
  800f6a:	e8 11 ff ff ff       	call   800e80 <nsipc>
}
  800f6f:	c9                   	leave  
  800f70:	c3                   	ret    

00800f71 <nsipc_close>:

int
nsipc_close(int s)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800f77:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7a:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800f7f:	b8 04 00 00 00       	mov    $0x4,%eax
  800f84:	e8 f7 fe ff ff       	call   800e80 <nsipc>
}
  800f89:	c9                   	leave  
  800f8a:	c3                   	ret    

00800f8b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	53                   	push   %ebx
  800f8f:	83 ec 08             	sub    $0x8,%esp
  800f92:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f95:	8b 45 08             	mov    0x8(%ebp),%eax
  800f98:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f9d:	53                   	push   %ebx
  800f9e:	ff 75 0c             	pushl  0xc(%ebp)
  800fa1:	68 04 60 80 00       	push   $0x806004
  800fa6:	e8 fa 0d 00 00       	call   801da5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800fab:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800fb1:	b8 05 00 00 00       	mov    $0x5,%eax
  800fb6:	e8 c5 fe ff ff       	call   800e80 <nsipc>
}
  800fbb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fbe:	c9                   	leave  
  800fbf:	c3                   	ret    

00800fc0 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800fc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800fce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800fd6:	b8 06 00 00 00       	mov    $0x6,%eax
  800fdb:	e8 a0 fe ff ff       	call   800e80 <nsipc>
}
  800fe0:	c9                   	leave  
  800fe1:	c3                   	ret    

00800fe2 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	56                   	push   %esi
  800fe6:	53                   	push   %ebx
  800fe7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800fea:	8b 45 08             	mov    0x8(%ebp),%eax
  800fed:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800ff2:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800ff8:	8b 45 14             	mov    0x14(%ebp),%eax
  800ffb:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801000:	b8 07 00 00 00       	mov    $0x7,%eax
  801005:	e8 76 fe ff ff       	call   800e80 <nsipc>
  80100a:	89 c3                	mov    %eax,%ebx
  80100c:	85 c0                	test   %eax,%eax
  80100e:	78 35                	js     801045 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801010:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801015:	7f 04                	jg     80101b <nsipc_recv+0x39>
  801017:	39 c6                	cmp    %eax,%esi
  801019:	7d 16                	jge    801031 <nsipc_recv+0x4f>
  80101b:	68 37 24 80 00       	push   $0x802437
  801020:	68 f8 23 80 00       	push   $0x8023f8
  801025:	6a 62                	push   $0x62
  801027:	68 4c 24 80 00       	push   $0x80244c
  80102c:	e8 84 05 00 00       	call   8015b5 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801031:	83 ec 04             	sub    $0x4,%esp
  801034:	50                   	push   %eax
  801035:	68 00 60 80 00       	push   $0x806000
  80103a:	ff 75 0c             	pushl  0xc(%ebp)
  80103d:	e8 63 0d 00 00       	call   801da5 <memmove>
  801042:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801045:	89 d8                	mov    %ebx,%eax
  801047:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80104a:	5b                   	pop    %ebx
  80104b:	5e                   	pop    %esi
  80104c:	5d                   	pop    %ebp
  80104d:	c3                   	ret    

0080104e <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	53                   	push   %ebx
  801052:	83 ec 04             	sub    $0x4,%esp
  801055:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801058:	8b 45 08             	mov    0x8(%ebp),%eax
  80105b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801060:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801066:	7e 16                	jle    80107e <nsipc_send+0x30>
  801068:	68 58 24 80 00       	push   $0x802458
  80106d:	68 f8 23 80 00       	push   $0x8023f8
  801072:	6a 6d                	push   $0x6d
  801074:	68 4c 24 80 00       	push   $0x80244c
  801079:	e8 37 05 00 00       	call   8015b5 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80107e:	83 ec 04             	sub    $0x4,%esp
  801081:	53                   	push   %ebx
  801082:	ff 75 0c             	pushl  0xc(%ebp)
  801085:	68 0c 60 80 00       	push   $0x80600c
  80108a:	e8 16 0d 00 00       	call   801da5 <memmove>
	nsipcbuf.send.req_size = size;
  80108f:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801095:	8b 45 14             	mov    0x14(%ebp),%eax
  801098:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80109d:	b8 08 00 00 00       	mov    $0x8,%eax
  8010a2:	e8 d9 fd ff ff       	call   800e80 <nsipc>
}
  8010a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010aa:	c9                   	leave  
  8010ab:	c3                   	ret    

008010ac <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8010b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8010ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010bd:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8010c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8010c5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8010ca:	b8 09 00 00 00       	mov    $0x9,%eax
  8010cf:	e8 ac fd ff ff       	call   800e80 <nsipc>
}
  8010d4:	c9                   	leave  
  8010d5:	c3                   	ret    

008010d6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	56                   	push   %esi
  8010da:	53                   	push   %ebx
  8010db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8010de:	83 ec 0c             	sub    $0xc,%esp
  8010e1:	ff 75 08             	pushl  0x8(%ebp)
  8010e4:	e8 62 f3 ff ff       	call   80044b <fd2data>
  8010e9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8010eb:	83 c4 08             	add    $0x8,%esp
  8010ee:	68 64 24 80 00       	push   $0x802464
  8010f3:	53                   	push   %ebx
  8010f4:	e8 1a 0b 00 00       	call   801c13 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8010f9:	8b 46 04             	mov    0x4(%esi),%eax
  8010fc:	2b 06                	sub    (%esi),%eax
  8010fe:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801104:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80110b:	00 00 00 
	stat->st_dev = &devpipe;
  80110e:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801115:	30 80 00 
	return 0;
}
  801118:	b8 00 00 00 00       	mov    $0x0,%eax
  80111d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801120:	5b                   	pop    %ebx
  801121:	5e                   	pop    %esi
  801122:	5d                   	pop    %ebp
  801123:	c3                   	ret    

00801124 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	53                   	push   %ebx
  801128:	83 ec 0c             	sub    $0xc,%esp
  80112b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80112e:	53                   	push   %ebx
  80112f:	6a 00                	push   $0x0
  801131:	e8 b5 f0 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801136:	89 1c 24             	mov    %ebx,(%esp)
  801139:	e8 0d f3 ff ff       	call   80044b <fd2data>
  80113e:	83 c4 08             	add    $0x8,%esp
  801141:	50                   	push   %eax
  801142:	6a 00                	push   $0x0
  801144:	e8 a2 f0 ff ff       	call   8001eb <sys_page_unmap>
}
  801149:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80114c:	c9                   	leave  
  80114d:	c3                   	ret    

0080114e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80114e:	55                   	push   %ebp
  80114f:	89 e5                	mov    %esp,%ebp
  801151:	57                   	push   %edi
  801152:	56                   	push   %esi
  801153:	53                   	push   %ebx
  801154:	83 ec 1c             	sub    $0x1c,%esp
  801157:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80115a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80115c:	a1 08 40 80 00       	mov    0x804008,%eax
  801161:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801164:	83 ec 0c             	sub    $0xc,%esp
  801167:	ff 75 e0             	pushl  -0x20(%ebp)
  80116a:	e8 e1 0e 00 00       	call   802050 <pageref>
  80116f:	89 c3                	mov    %eax,%ebx
  801171:	89 3c 24             	mov    %edi,(%esp)
  801174:	e8 d7 0e 00 00       	call   802050 <pageref>
  801179:	83 c4 10             	add    $0x10,%esp
  80117c:	39 c3                	cmp    %eax,%ebx
  80117e:	0f 94 c1             	sete   %cl
  801181:	0f b6 c9             	movzbl %cl,%ecx
  801184:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801187:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80118d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801190:	39 ce                	cmp    %ecx,%esi
  801192:	74 1b                	je     8011af <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801194:	39 c3                	cmp    %eax,%ebx
  801196:	75 c4                	jne    80115c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801198:	8b 42 58             	mov    0x58(%edx),%eax
  80119b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80119e:	50                   	push   %eax
  80119f:	56                   	push   %esi
  8011a0:	68 6b 24 80 00       	push   $0x80246b
  8011a5:	e8 e4 04 00 00       	call   80168e <cprintf>
  8011aa:	83 c4 10             	add    $0x10,%esp
  8011ad:	eb ad                	jmp    80115c <_pipeisclosed+0xe>
	}
}
  8011af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b5:	5b                   	pop    %ebx
  8011b6:	5e                   	pop    %esi
  8011b7:	5f                   	pop    %edi
  8011b8:	5d                   	pop    %ebp
  8011b9:	c3                   	ret    

008011ba <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	57                   	push   %edi
  8011be:	56                   	push   %esi
  8011bf:	53                   	push   %ebx
  8011c0:	83 ec 28             	sub    $0x28,%esp
  8011c3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8011c6:	56                   	push   %esi
  8011c7:	e8 7f f2 ff ff       	call   80044b <fd2data>
  8011cc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011ce:	83 c4 10             	add    $0x10,%esp
  8011d1:	bf 00 00 00 00       	mov    $0x0,%edi
  8011d6:	eb 4b                	jmp    801223 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8011d8:	89 da                	mov    %ebx,%edx
  8011da:	89 f0                	mov    %esi,%eax
  8011dc:	e8 6d ff ff ff       	call   80114e <_pipeisclosed>
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	75 48                	jne    80122d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8011e5:	e8 5d ef ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8011ea:	8b 43 04             	mov    0x4(%ebx),%eax
  8011ed:	8b 0b                	mov    (%ebx),%ecx
  8011ef:	8d 51 20             	lea    0x20(%ecx),%edx
  8011f2:	39 d0                	cmp    %edx,%eax
  8011f4:	73 e2                	jae    8011d8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8011f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8011fd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801200:	89 c2                	mov    %eax,%edx
  801202:	c1 fa 1f             	sar    $0x1f,%edx
  801205:	89 d1                	mov    %edx,%ecx
  801207:	c1 e9 1b             	shr    $0x1b,%ecx
  80120a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80120d:	83 e2 1f             	and    $0x1f,%edx
  801210:	29 ca                	sub    %ecx,%edx
  801212:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801216:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80121a:	83 c0 01             	add    $0x1,%eax
  80121d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801220:	83 c7 01             	add    $0x1,%edi
  801223:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801226:	75 c2                	jne    8011ea <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801228:	8b 45 10             	mov    0x10(%ebp),%eax
  80122b:	eb 05                	jmp    801232 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80122d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801232:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801235:	5b                   	pop    %ebx
  801236:	5e                   	pop    %esi
  801237:	5f                   	pop    %edi
  801238:	5d                   	pop    %ebp
  801239:	c3                   	ret    

0080123a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
  80123d:	57                   	push   %edi
  80123e:	56                   	push   %esi
  80123f:	53                   	push   %ebx
  801240:	83 ec 18             	sub    $0x18,%esp
  801243:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801246:	57                   	push   %edi
  801247:	e8 ff f1 ff ff       	call   80044b <fd2data>
  80124c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80124e:	83 c4 10             	add    $0x10,%esp
  801251:	bb 00 00 00 00       	mov    $0x0,%ebx
  801256:	eb 3d                	jmp    801295 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801258:	85 db                	test   %ebx,%ebx
  80125a:	74 04                	je     801260 <devpipe_read+0x26>
				return i;
  80125c:	89 d8                	mov    %ebx,%eax
  80125e:	eb 44                	jmp    8012a4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801260:	89 f2                	mov    %esi,%edx
  801262:	89 f8                	mov    %edi,%eax
  801264:	e8 e5 fe ff ff       	call   80114e <_pipeisclosed>
  801269:	85 c0                	test   %eax,%eax
  80126b:	75 32                	jne    80129f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80126d:	e8 d5 ee ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801272:	8b 06                	mov    (%esi),%eax
  801274:	3b 46 04             	cmp    0x4(%esi),%eax
  801277:	74 df                	je     801258 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801279:	99                   	cltd   
  80127a:	c1 ea 1b             	shr    $0x1b,%edx
  80127d:	01 d0                	add    %edx,%eax
  80127f:	83 e0 1f             	and    $0x1f,%eax
  801282:	29 d0                	sub    %edx,%eax
  801284:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801289:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80128f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801292:	83 c3 01             	add    $0x1,%ebx
  801295:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801298:	75 d8                	jne    801272 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80129a:	8b 45 10             	mov    0x10(%ebp),%eax
  80129d:	eb 05                	jmp    8012a4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80129f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8012a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012a7:	5b                   	pop    %ebx
  8012a8:	5e                   	pop    %esi
  8012a9:	5f                   	pop    %edi
  8012aa:	5d                   	pop    %ebp
  8012ab:	c3                   	ret    

008012ac <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	56                   	push   %esi
  8012b0:	53                   	push   %ebx
  8012b1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8012b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b7:	50                   	push   %eax
  8012b8:	e8 a5 f1 ff ff       	call   800462 <fd_alloc>
  8012bd:	83 c4 10             	add    $0x10,%esp
  8012c0:	89 c2                	mov    %eax,%edx
  8012c2:	85 c0                	test   %eax,%eax
  8012c4:	0f 88 2c 01 00 00    	js     8013f6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012ca:	83 ec 04             	sub    $0x4,%esp
  8012cd:	68 07 04 00 00       	push   $0x407
  8012d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d5:	6a 00                	push   $0x0
  8012d7:	e8 8a ee ff ff       	call   800166 <sys_page_alloc>
  8012dc:	83 c4 10             	add    $0x10,%esp
  8012df:	89 c2                	mov    %eax,%edx
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	0f 88 0d 01 00 00    	js     8013f6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8012e9:	83 ec 0c             	sub    $0xc,%esp
  8012ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ef:	50                   	push   %eax
  8012f0:	e8 6d f1 ff ff       	call   800462 <fd_alloc>
  8012f5:	89 c3                	mov    %eax,%ebx
  8012f7:	83 c4 10             	add    $0x10,%esp
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	0f 88 e2 00 00 00    	js     8013e4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801302:	83 ec 04             	sub    $0x4,%esp
  801305:	68 07 04 00 00       	push   $0x407
  80130a:	ff 75 f0             	pushl  -0x10(%ebp)
  80130d:	6a 00                	push   $0x0
  80130f:	e8 52 ee ff ff       	call   800166 <sys_page_alloc>
  801314:	89 c3                	mov    %eax,%ebx
  801316:	83 c4 10             	add    $0x10,%esp
  801319:	85 c0                	test   %eax,%eax
  80131b:	0f 88 c3 00 00 00    	js     8013e4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801321:	83 ec 0c             	sub    $0xc,%esp
  801324:	ff 75 f4             	pushl  -0xc(%ebp)
  801327:	e8 1f f1 ff ff       	call   80044b <fd2data>
  80132c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80132e:	83 c4 0c             	add    $0xc,%esp
  801331:	68 07 04 00 00       	push   $0x407
  801336:	50                   	push   %eax
  801337:	6a 00                	push   $0x0
  801339:	e8 28 ee ff ff       	call   800166 <sys_page_alloc>
  80133e:	89 c3                	mov    %eax,%ebx
  801340:	83 c4 10             	add    $0x10,%esp
  801343:	85 c0                	test   %eax,%eax
  801345:	0f 88 89 00 00 00    	js     8013d4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80134b:	83 ec 0c             	sub    $0xc,%esp
  80134e:	ff 75 f0             	pushl  -0x10(%ebp)
  801351:	e8 f5 f0 ff ff       	call   80044b <fd2data>
  801356:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80135d:	50                   	push   %eax
  80135e:	6a 00                	push   $0x0
  801360:	56                   	push   %esi
  801361:	6a 00                	push   $0x0
  801363:	e8 41 ee ff ff       	call   8001a9 <sys_page_map>
  801368:	89 c3                	mov    %eax,%ebx
  80136a:	83 c4 20             	add    $0x20,%esp
  80136d:	85 c0                	test   %eax,%eax
  80136f:	78 55                	js     8013c6 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801371:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801377:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80137c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801386:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80138c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801391:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801394:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80139b:	83 ec 0c             	sub    $0xc,%esp
  80139e:	ff 75 f4             	pushl  -0xc(%ebp)
  8013a1:	e8 95 f0 ff ff       	call   80043b <fd2num>
  8013a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013a9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8013ab:	83 c4 04             	add    $0x4,%esp
  8013ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8013b1:	e8 85 f0 ff ff       	call   80043b <fd2num>
  8013b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013b9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8013bc:	83 c4 10             	add    $0x10,%esp
  8013bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c4:	eb 30                	jmp    8013f6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8013c6:	83 ec 08             	sub    $0x8,%esp
  8013c9:	56                   	push   %esi
  8013ca:	6a 00                	push   $0x0
  8013cc:	e8 1a ee ff ff       	call   8001eb <sys_page_unmap>
  8013d1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8013d4:	83 ec 08             	sub    $0x8,%esp
  8013d7:	ff 75 f0             	pushl  -0x10(%ebp)
  8013da:	6a 00                	push   $0x0
  8013dc:	e8 0a ee ff ff       	call   8001eb <sys_page_unmap>
  8013e1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8013e4:	83 ec 08             	sub    $0x8,%esp
  8013e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8013ea:	6a 00                	push   $0x0
  8013ec:	e8 fa ed ff ff       	call   8001eb <sys_page_unmap>
  8013f1:	83 c4 10             	add    $0x10,%esp
  8013f4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8013f6:	89 d0                	mov    %edx,%eax
  8013f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013fb:	5b                   	pop    %ebx
  8013fc:	5e                   	pop    %esi
  8013fd:	5d                   	pop    %ebp
  8013fe:	c3                   	ret    

008013ff <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8013ff:	55                   	push   %ebp
  801400:	89 e5                	mov    %esp,%ebp
  801402:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801405:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801408:	50                   	push   %eax
  801409:	ff 75 08             	pushl  0x8(%ebp)
  80140c:	e8 a0 f0 ff ff       	call   8004b1 <fd_lookup>
  801411:	83 c4 10             	add    $0x10,%esp
  801414:	85 c0                	test   %eax,%eax
  801416:	78 18                	js     801430 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801418:	83 ec 0c             	sub    $0xc,%esp
  80141b:	ff 75 f4             	pushl  -0xc(%ebp)
  80141e:	e8 28 f0 ff ff       	call   80044b <fd2data>
	return _pipeisclosed(fd, p);
  801423:	89 c2                	mov    %eax,%edx
  801425:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801428:	e8 21 fd ff ff       	call   80114e <_pipeisclosed>
  80142d:	83 c4 10             	add    $0x10,%esp
}
  801430:	c9                   	leave  
  801431:	c3                   	ret    

00801432 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801432:	55                   	push   %ebp
  801433:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801435:	b8 00 00 00 00       	mov    $0x0,%eax
  80143a:	5d                   	pop    %ebp
  80143b:	c3                   	ret    

0080143c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801442:	68 83 24 80 00       	push   $0x802483
  801447:	ff 75 0c             	pushl  0xc(%ebp)
  80144a:	e8 c4 07 00 00       	call   801c13 <strcpy>
	return 0;
}
  80144f:	b8 00 00 00 00       	mov    $0x0,%eax
  801454:	c9                   	leave  
  801455:	c3                   	ret    

00801456 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	57                   	push   %edi
  80145a:	56                   	push   %esi
  80145b:	53                   	push   %ebx
  80145c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801462:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801467:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80146d:	eb 2d                	jmp    80149c <devcons_write+0x46>
		m = n - tot;
  80146f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801472:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801474:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801477:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80147c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80147f:	83 ec 04             	sub    $0x4,%esp
  801482:	53                   	push   %ebx
  801483:	03 45 0c             	add    0xc(%ebp),%eax
  801486:	50                   	push   %eax
  801487:	57                   	push   %edi
  801488:	e8 18 09 00 00       	call   801da5 <memmove>
		sys_cputs(buf, m);
  80148d:	83 c4 08             	add    $0x8,%esp
  801490:	53                   	push   %ebx
  801491:	57                   	push   %edi
  801492:	e8 13 ec ff ff       	call   8000aa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801497:	01 de                	add    %ebx,%esi
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	89 f0                	mov    %esi,%eax
  80149e:	3b 75 10             	cmp    0x10(%ebp),%esi
  8014a1:	72 cc                	jb     80146f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8014a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014a6:	5b                   	pop    %ebx
  8014a7:	5e                   	pop    %esi
  8014a8:	5f                   	pop    %edi
  8014a9:	5d                   	pop    %ebp
  8014aa:	c3                   	ret    

008014ab <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8014ab:	55                   	push   %ebp
  8014ac:	89 e5                	mov    %esp,%ebp
  8014ae:	83 ec 08             	sub    $0x8,%esp
  8014b1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8014b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8014ba:	74 2a                	je     8014e6 <devcons_read+0x3b>
  8014bc:	eb 05                	jmp    8014c3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8014be:	e8 84 ec ff ff       	call   800147 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8014c3:	e8 00 ec ff ff       	call   8000c8 <sys_cgetc>
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	74 f2                	je     8014be <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 16                	js     8014e6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8014d0:	83 f8 04             	cmp    $0x4,%eax
  8014d3:	74 0c                	je     8014e1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8014d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014d8:	88 02                	mov    %al,(%edx)
	return 1;
  8014da:	b8 01 00 00 00       	mov    $0x1,%eax
  8014df:	eb 05                	jmp    8014e6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8014e1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8014e6:	c9                   	leave  
  8014e7:	c3                   	ret    

008014e8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8014ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8014f4:	6a 01                	push   $0x1
  8014f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014f9:	50                   	push   %eax
  8014fa:	e8 ab eb ff ff       	call   8000aa <sys_cputs>
}
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	c9                   	leave  
  801503:	c3                   	ret    

00801504 <getchar>:

int
getchar(void)
{
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80150a:	6a 01                	push   $0x1
  80150c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80150f:	50                   	push   %eax
  801510:	6a 00                	push   $0x0
  801512:	e8 00 f2 ff ff       	call   800717 <read>
	if (r < 0)
  801517:	83 c4 10             	add    $0x10,%esp
  80151a:	85 c0                	test   %eax,%eax
  80151c:	78 0f                	js     80152d <getchar+0x29>
		return r;
	if (r < 1)
  80151e:	85 c0                	test   %eax,%eax
  801520:	7e 06                	jle    801528 <getchar+0x24>
		return -E_EOF;
	return c;
  801522:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801526:	eb 05                	jmp    80152d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801528:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80152d:	c9                   	leave  
  80152e:	c3                   	ret    

0080152f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80152f:	55                   	push   %ebp
  801530:	89 e5                	mov    %esp,%ebp
  801532:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801535:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801538:	50                   	push   %eax
  801539:	ff 75 08             	pushl  0x8(%ebp)
  80153c:	e8 70 ef ff ff       	call   8004b1 <fd_lookup>
  801541:	83 c4 10             	add    $0x10,%esp
  801544:	85 c0                	test   %eax,%eax
  801546:	78 11                	js     801559 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801548:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801551:	39 10                	cmp    %edx,(%eax)
  801553:	0f 94 c0             	sete   %al
  801556:	0f b6 c0             	movzbl %al,%eax
}
  801559:	c9                   	leave  
  80155a:	c3                   	ret    

0080155b <opencons>:

int
opencons(void)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801561:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801564:	50                   	push   %eax
  801565:	e8 f8 ee ff ff       	call   800462 <fd_alloc>
  80156a:	83 c4 10             	add    $0x10,%esp
		return r;
  80156d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80156f:	85 c0                	test   %eax,%eax
  801571:	78 3e                	js     8015b1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801573:	83 ec 04             	sub    $0x4,%esp
  801576:	68 07 04 00 00       	push   $0x407
  80157b:	ff 75 f4             	pushl  -0xc(%ebp)
  80157e:	6a 00                	push   $0x0
  801580:	e8 e1 eb ff ff       	call   800166 <sys_page_alloc>
  801585:	83 c4 10             	add    $0x10,%esp
		return r;
  801588:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80158a:	85 c0                	test   %eax,%eax
  80158c:	78 23                	js     8015b1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80158e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801594:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801597:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801599:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8015a3:	83 ec 0c             	sub    $0xc,%esp
  8015a6:	50                   	push   %eax
  8015a7:	e8 8f ee ff ff       	call   80043b <fd2num>
  8015ac:	89 c2                	mov    %eax,%edx
  8015ae:	83 c4 10             	add    $0x10,%esp
}
  8015b1:	89 d0                	mov    %edx,%eax
  8015b3:	c9                   	leave  
  8015b4:	c3                   	ret    

008015b5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	56                   	push   %esi
  8015b9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8015ba:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8015bd:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8015c3:	e8 60 eb ff ff       	call   800128 <sys_getenvid>
  8015c8:	83 ec 0c             	sub    $0xc,%esp
  8015cb:	ff 75 0c             	pushl  0xc(%ebp)
  8015ce:	ff 75 08             	pushl  0x8(%ebp)
  8015d1:	56                   	push   %esi
  8015d2:	50                   	push   %eax
  8015d3:	68 90 24 80 00       	push   $0x802490
  8015d8:	e8 b1 00 00 00       	call   80168e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015dd:	83 c4 18             	add    $0x18,%esp
  8015e0:	53                   	push   %ebx
  8015e1:	ff 75 10             	pushl  0x10(%ebp)
  8015e4:	e8 54 00 00 00       	call   80163d <vcprintf>
	cprintf("\n");
  8015e9:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  8015f0:	e8 99 00 00 00       	call   80168e <cprintf>
  8015f5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8015f8:	cc                   	int3   
  8015f9:	eb fd                	jmp    8015f8 <_panic+0x43>

008015fb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8015fb:	55                   	push   %ebp
  8015fc:	89 e5                	mov    %esp,%ebp
  8015fe:	53                   	push   %ebx
  8015ff:	83 ec 04             	sub    $0x4,%esp
  801602:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801605:	8b 13                	mov    (%ebx),%edx
  801607:	8d 42 01             	lea    0x1(%edx),%eax
  80160a:	89 03                	mov    %eax,(%ebx)
  80160c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80160f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801613:	3d ff 00 00 00       	cmp    $0xff,%eax
  801618:	75 1a                	jne    801634 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80161a:	83 ec 08             	sub    $0x8,%esp
  80161d:	68 ff 00 00 00       	push   $0xff
  801622:	8d 43 08             	lea    0x8(%ebx),%eax
  801625:	50                   	push   %eax
  801626:	e8 7f ea ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  80162b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801631:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801634:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801638:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163b:	c9                   	leave  
  80163c:	c3                   	ret    

0080163d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80163d:	55                   	push   %ebp
  80163e:	89 e5                	mov    %esp,%ebp
  801640:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801646:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80164d:	00 00 00 
	b.cnt = 0;
  801650:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801657:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80165a:	ff 75 0c             	pushl  0xc(%ebp)
  80165d:	ff 75 08             	pushl  0x8(%ebp)
  801660:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801666:	50                   	push   %eax
  801667:	68 fb 15 80 00       	push   $0x8015fb
  80166c:	e8 54 01 00 00       	call   8017c5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801671:	83 c4 08             	add    $0x8,%esp
  801674:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80167a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801680:	50                   	push   %eax
  801681:	e8 24 ea ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  801686:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80168c:	c9                   	leave  
  80168d:	c3                   	ret    

0080168e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801694:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801697:	50                   	push   %eax
  801698:	ff 75 08             	pushl  0x8(%ebp)
  80169b:	e8 9d ff ff ff       	call   80163d <vcprintf>
	va_end(ap);

	return cnt;
}
  8016a0:	c9                   	leave  
  8016a1:	c3                   	ret    

008016a2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8016a2:	55                   	push   %ebp
  8016a3:	89 e5                	mov    %esp,%ebp
  8016a5:	57                   	push   %edi
  8016a6:	56                   	push   %esi
  8016a7:	53                   	push   %ebx
  8016a8:	83 ec 1c             	sub    $0x1c,%esp
  8016ab:	89 c7                	mov    %eax,%edi
  8016ad:	89 d6                	mov    %edx,%esi
  8016af:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016b8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016bb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016c3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8016c6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8016c9:	39 d3                	cmp    %edx,%ebx
  8016cb:	72 05                	jb     8016d2 <printnum+0x30>
  8016cd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8016d0:	77 45                	ja     801717 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8016d2:	83 ec 0c             	sub    $0xc,%esp
  8016d5:	ff 75 18             	pushl  0x18(%ebp)
  8016d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8016db:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8016de:	53                   	push   %ebx
  8016df:	ff 75 10             	pushl  0x10(%ebp)
  8016e2:	83 ec 08             	sub    $0x8,%esp
  8016e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8016eb:	ff 75 dc             	pushl  -0x24(%ebp)
  8016ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8016f1:	e8 9a 09 00 00       	call   802090 <__udivdi3>
  8016f6:	83 c4 18             	add    $0x18,%esp
  8016f9:	52                   	push   %edx
  8016fa:	50                   	push   %eax
  8016fb:	89 f2                	mov    %esi,%edx
  8016fd:	89 f8                	mov    %edi,%eax
  8016ff:	e8 9e ff ff ff       	call   8016a2 <printnum>
  801704:	83 c4 20             	add    $0x20,%esp
  801707:	eb 18                	jmp    801721 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801709:	83 ec 08             	sub    $0x8,%esp
  80170c:	56                   	push   %esi
  80170d:	ff 75 18             	pushl  0x18(%ebp)
  801710:	ff d7                	call   *%edi
  801712:	83 c4 10             	add    $0x10,%esp
  801715:	eb 03                	jmp    80171a <printnum+0x78>
  801717:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80171a:	83 eb 01             	sub    $0x1,%ebx
  80171d:	85 db                	test   %ebx,%ebx
  80171f:	7f e8                	jg     801709 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801721:	83 ec 08             	sub    $0x8,%esp
  801724:	56                   	push   %esi
  801725:	83 ec 04             	sub    $0x4,%esp
  801728:	ff 75 e4             	pushl  -0x1c(%ebp)
  80172b:	ff 75 e0             	pushl  -0x20(%ebp)
  80172e:	ff 75 dc             	pushl  -0x24(%ebp)
  801731:	ff 75 d8             	pushl  -0x28(%ebp)
  801734:	e8 87 0a 00 00       	call   8021c0 <__umoddi3>
  801739:	83 c4 14             	add    $0x14,%esp
  80173c:	0f be 80 b3 24 80 00 	movsbl 0x8024b3(%eax),%eax
  801743:	50                   	push   %eax
  801744:	ff d7                	call   *%edi
}
  801746:	83 c4 10             	add    $0x10,%esp
  801749:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80174c:	5b                   	pop    %ebx
  80174d:	5e                   	pop    %esi
  80174e:	5f                   	pop    %edi
  80174f:	5d                   	pop    %ebp
  801750:	c3                   	ret    

00801751 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801754:	83 fa 01             	cmp    $0x1,%edx
  801757:	7e 0e                	jle    801767 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801759:	8b 10                	mov    (%eax),%edx
  80175b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80175e:	89 08                	mov    %ecx,(%eax)
  801760:	8b 02                	mov    (%edx),%eax
  801762:	8b 52 04             	mov    0x4(%edx),%edx
  801765:	eb 22                	jmp    801789 <getuint+0x38>
	else if (lflag)
  801767:	85 d2                	test   %edx,%edx
  801769:	74 10                	je     80177b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80176b:	8b 10                	mov    (%eax),%edx
  80176d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801770:	89 08                	mov    %ecx,(%eax)
  801772:	8b 02                	mov    (%edx),%eax
  801774:	ba 00 00 00 00       	mov    $0x0,%edx
  801779:	eb 0e                	jmp    801789 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80177b:	8b 10                	mov    (%eax),%edx
  80177d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801780:	89 08                	mov    %ecx,(%eax)
  801782:	8b 02                	mov    (%edx),%eax
  801784:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801789:	5d                   	pop    %ebp
  80178a:	c3                   	ret    

0080178b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801791:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801795:	8b 10                	mov    (%eax),%edx
  801797:	3b 50 04             	cmp    0x4(%eax),%edx
  80179a:	73 0a                	jae    8017a6 <sprintputch+0x1b>
		*b->buf++ = ch;
  80179c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80179f:	89 08                	mov    %ecx,(%eax)
  8017a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a4:	88 02                	mov    %al,(%edx)
}
  8017a6:	5d                   	pop    %ebp
  8017a7:	c3                   	ret    

008017a8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
  8017ab:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8017ae:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017b1:	50                   	push   %eax
  8017b2:	ff 75 10             	pushl  0x10(%ebp)
  8017b5:	ff 75 0c             	pushl  0xc(%ebp)
  8017b8:	ff 75 08             	pushl  0x8(%ebp)
  8017bb:	e8 05 00 00 00       	call   8017c5 <vprintfmt>
	va_end(ap);
}
  8017c0:	83 c4 10             	add    $0x10,%esp
  8017c3:	c9                   	leave  
  8017c4:	c3                   	ret    

008017c5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	57                   	push   %edi
  8017c9:	56                   	push   %esi
  8017ca:	53                   	push   %ebx
  8017cb:	83 ec 2c             	sub    $0x2c,%esp
  8017ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8017d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017d4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8017d7:	eb 12                	jmp    8017eb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8017d9:	85 c0                	test   %eax,%eax
  8017db:	0f 84 89 03 00 00    	je     801b6a <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8017e1:	83 ec 08             	sub    $0x8,%esp
  8017e4:	53                   	push   %ebx
  8017e5:	50                   	push   %eax
  8017e6:	ff d6                	call   *%esi
  8017e8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8017eb:	83 c7 01             	add    $0x1,%edi
  8017ee:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017f2:	83 f8 25             	cmp    $0x25,%eax
  8017f5:	75 e2                	jne    8017d9 <vprintfmt+0x14>
  8017f7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8017fb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801802:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801809:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801810:	ba 00 00 00 00       	mov    $0x0,%edx
  801815:	eb 07                	jmp    80181e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801817:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80181a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80181e:	8d 47 01             	lea    0x1(%edi),%eax
  801821:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801824:	0f b6 07             	movzbl (%edi),%eax
  801827:	0f b6 c8             	movzbl %al,%ecx
  80182a:	83 e8 23             	sub    $0x23,%eax
  80182d:	3c 55                	cmp    $0x55,%al
  80182f:	0f 87 1a 03 00 00    	ja     801b4f <vprintfmt+0x38a>
  801835:	0f b6 c0             	movzbl %al,%eax
  801838:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  80183f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801842:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801846:	eb d6                	jmp    80181e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801848:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80184b:	b8 00 00 00 00       	mov    $0x0,%eax
  801850:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801853:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801856:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80185a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80185d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801860:	83 fa 09             	cmp    $0x9,%edx
  801863:	77 39                	ja     80189e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801865:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801868:	eb e9                	jmp    801853 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80186a:	8b 45 14             	mov    0x14(%ebp),%eax
  80186d:	8d 48 04             	lea    0x4(%eax),%ecx
  801870:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801873:	8b 00                	mov    (%eax),%eax
  801875:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801878:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80187b:	eb 27                	jmp    8018a4 <vprintfmt+0xdf>
  80187d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801880:	85 c0                	test   %eax,%eax
  801882:	b9 00 00 00 00       	mov    $0x0,%ecx
  801887:	0f 49 c8             	cmovns %eax,%ecx
  80188a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80188d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801890:	eb 8c                	jmp    80181e <vprintfmt+0x59>
  801892:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801895:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80189c:	eb 80                	jmp    80181e <vprintfmt+0x59>
  80189e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018a1:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8018a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018a8:	0f 89 70 ff ff ff    	jns    80181e <vprintfmt+0x59>
				width = precision, precision = -1;
  8018ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8018b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018b4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018bb:	e9 5e ff ff ff       	jmp    80181e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018c0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8018c6:	e9 53 ff ff ff       	jmp    80181e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8018ce:	8d 50 04             	lea    0x4(%eax),%edx
  8018d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8018d4:	83 ec 08             	sub    $0x8,%esp
  8018d7:	53                   	push   %ebx
  8018d8:	ff 30                	pushl  (%eax)
  8018da:	ff d6                	call   *%esi
			break;
  8018dc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8018e2:	e9 04 ff ff ff       	jmp    8017eb <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8018e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8018ea:	8d 50 04             	lea    0x4(%eax),%edx
  8018ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8018f0:	8b 00                	mov    (%eax),%eax
  8018f2:	99                   	cltd   
  8018f3:	31 d0                	xor    %edx,%eax
  8018f5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8018f7:	83 f8 0f             	cmp    $0xf,%eax
  8018fa:	7f 0b                	jg     801907 <vprintfmt+0x142>
  8018fc:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  801903:	85 d2                	test   %edx,%edx
  801905:	75 18                	jne    80191f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801907:	50                   	push   %eax
  801908:	68 cb 24 80 00       	push   $0x8024cb
  80190d:	53                   	push   %ebx
  80190e:	56                   	push   %esi
  80190f:	e8 94 fe ff ff       	call   8017a8 <printfmt>
  801914:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801917:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80191a:	e9 cc fe ff ff       	jmp    8017eb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80191f:	52                   	push   %edx
  801920:	68 0a 24 80 00       	push   $0x80240a
  801925:	53                   	push   %ebx
  801926:	56                   	push   %esi
  801927:	e8 7c fe ff ff       	call   8017a8 <printfmt>
  80192c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80192f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801932:	e9 b4 fe ff ff       	jmp    8017eb <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801937:	8b 45 14             	mov    0x14(%ebp),%eax
  80193a:	8d 50 04             	lea    0x4(%eax),%edx
  80193d:	89 55 14             	mov    %edx,0x14(%ebp)
  801940:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801942:	85 ff                	test   %edi,%edi
  801944:	b8 c4 24 80 00       	mov    $0x8024c4,%eax
  801949:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80194c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801950:	0f 8e 94 00 00 00    	jle    8019ea <vprintfmt+0x225>
  801956:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80195a:	0f 84 98 00 00 00    	je     8019f8 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801960:	83 ec 08             	sub    $0x8,%esp
  801963:	ff 75 d0             	pushl  -0x30(%ebp)
  801966:	57                   	push   %edi
  801967:	e8 86 02 00 00       	call   801bf2 <strnlen>
  80196c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80196f:	29 c1                	sub    %eax,%ecx
  801971:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801974:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801977:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80197b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80197e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801981:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801983:	eb 0f                	jmp    801994 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801985:	83 ec 08             	sub    $0x8,%esp
  801988:	53                   	push   %ebx
  801989:	ff 75 e0             	pushl  -0x20(%ebp)
  80198c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80198e:	83 ef 01             	sub    $0x1,%edi
  801991:	83 c4 10             	add    $0x10,%esp
  801994:	85 ff                	test   %edi,%edi
  801996:	7f ed                	jg     801985 <vprintfmt+0x1c0>
  801998:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80199b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80199e:	85 c9                	test   %ecx,%ecx
  8019a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a5:	0f 49 c1             	cmovns %ecx,%eax
  8019a8:	29 c1                	sub    %eax,%ecx
  8019aa:	89 75 08             	mov    %esi,0x8(%ebp)
  8019ad:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019b0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019b3:	89 cb                	mov    %ecx,%ebx
  8019b5:	eb 4d                	jmp    801a04 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019b7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8019bb:	74 1b                	je     8019d8 <vprintfmt+0x213>
  8019bd:	0f be c0             	movsbl %al,%eax
  8019c0:	83 e8 20             	sub    $0x20,%eax
  8019c3:	83 f8 5e             	cmp    $0x5e,%eax
  8019c6:	76 10                	jbe    8019d8 <vprintfmt+0x213>
					putch('?', putdat);
  8019c8:	83 ec 08             	sub    $0x8,%esp
  8019cb:	ff 75 0c             	pushl  0xc(%ebp)
  8019ce:	6a 3f                	push   $0x3f
  8019d0:	ff 55 08             	call   *0x8(%ebp)
  8019d3:	83 c4 10             	add    $0x10,%esp
  8019d6:	eb 0d                	jmp    8019e5 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8019d8:	83 ec 08             	sub    $0x8,%esp
  8019db:	ff 75 0c             	pushl  0xc(%ebp)
  8019de:	52                   	push   %edx
  8019df:	ff 55 08             	call   *0x8(%ebp)
  8019e2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8019e5:	83 eb 01             	sub    $0x1,%ebx
  8019e8:	eb 1a                	jmp    801a04 <vprintfmt+0x23f>
  8019ea:	89 75 08             	mov    %esi,0x8(%ebp)
  8019ed:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019f0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019f3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019f6:	eb 0c                	jmp    801a04 <vprintfmt+0x23f>
  8019f8:	89 75 08             	mov    %esi,0x8(%ebp)
  8019fb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019fe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a01:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a04:	83 c7 01             	add    $0x1,%edi
  801a07:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a0b:	0f be d0             	movsbl %al,%edx
  801a0e:	85 d2                	test   %edx,%edx
  801a10:	74 23                	je     801a35 <vprintfmt+0x270>
  801a12:	85 f6                	test   %esi,%esi
  801a14:	78 a1                	js     8019b7 <vprintfmt+0x1f2>
  801a16:	83 ee 01             	sub    $0x1,%esi
  801a19:	79 9c                	jns    8019b7 <vprintfmt+0x1f2>
  801a1b:	89 df                	mov    %ebx,%edi
  801a1d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a23:	eb 18                	jmp    801a3d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a25:	83 ec 08             	sub    $0x8,%esp
  801a28:	53                   	push   %ebx
  801a29:	6a 20                	push   $0x20
  801a2b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a2d:	83 ef 01             	sub    $0x1,%edi
  801a30:	83 c4 10             	add    $0x10,%esp
  801a33:	eb 08                	jmp    801a3d <vprintfmt+0x278>
  801a35:	89 df                	mov    %ebx,%edi
  801a37:	8b 75 08             	mov    0x8(%ebp),%esi
  801a3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a3d:	85 ff                	test   %edi,%edi
  801a3f:	7f e4                	jg     801a25 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a41:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a44:	e9 a2 fd ff ff       	jmp    8017eb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a49:	83 fa 01             	cmp    $0x1,%edx
  801a4c:	7e 16                	jle    801a64 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801a4e:	8b 45 14             	mov    0x14(%ebp),%eax
  801a51:	8d 50 08             	lea    0x8(%eax),%edx
  801a54:	89 55 14             	mov    %edx,0x14(%ebp)
  801a57:	8b 50 04             	mov    0x4(%eax),%edx
  801a5a:	8b 00                	mov    (%eax),%eax
  801a5c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a5f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a62:	eb 32                	jmp    801a96 <vprintfmt+0x2d1>
	else if (lflag)
  801a64:	85 d2                	test   %edx,%edx
  801a66:	74 18                	je     801a80 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801a68:	8b 45 14             	mov    0x14(%ebp),%eax
  801a6b:	8d 50 04             	lea    0x4(%eax),%edx
  801a6e:	89 55 14             	mov    %edx,0x14(%ebp)
  801a71:	8b 00                	mov    (%eax),%eax
  801a73:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a76:	89 c1                	mov    %eax,%ecx
  801a78:	c1 f9 1f             	sar    $0x1f,%ecx
  801a7b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a7e:	eb 16                	jmp    801a96 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801a80:	8b 45 14             	mov    0x14(%ebp),%eax
  801a83:	8d 50 04             	lea    0x4(%eax),%edx
  801a86:	89 55 14             	mov    %edx,0x14(%ebp)
  801a89:	8b 00                	mov    (%eax),%eax
  801a8b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a8e:	89 c1                	mov    %eax,%ecx
  801a90:	c1 f9 1f             	sar    $0x1f,%ecx
  801a93:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a96:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a99:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a9c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801aa1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801aa5:	79 74                	jns    801b1b <vprintfmt+0x356>
				putch('-', putdat);
  801aa7:	83 ec 08             	sub    $0x8,%esp
  801aaa:	53                   	push   %ebx
  801aab:	6a 2d                	push   $0x2d
  801aad:	ff d6                	call   *%esi
				num = -(long long) num;
  801aaf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ab2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801ab5:	f7 d8                	neg    %eax
  801ab7:	83 d2 00             	adc    $0x0,%edx
  801aba:	f7 da                	neg    %edx
  801abc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801abf:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801ac4:	eb 55                	jmp    801b1b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801ac6:	8d 45 14             	lea    0x14(%ebp),%eax
  801ac9:	e8 83 fc ff ff       	call   801751 <getuint>
			base = 10;
  801ace:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801ad3:	eb 46                	jmp    801b1b <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801ad5:	8d 45 14             	lea    0x14(%ebp),%eax
  801ad8:	e8 74 fc ff ff       	call   801751 <getuint>
                        base = 8;
  801add:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801ae2:	eb 37                	jmp    801b1b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801ae4:	83 ec 08             	sub    $0x8,%esp
  801ae7:	53                   	push   %ebx
  801ae8:	6a 30                	push   $0x30
  801aea:	ff d6                	call   *%esi
			putch('x', putdat);
  801aec:	83 c4 08             	add    $0x8,%esp
  801aef:	53                   	push   %ebx
  801af0:	6a 78                	push   $0x78
  801af2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801af4:	8b 45 14             	mov    0x14(%ebp),%eax
  801af7:	8d 50 04             	lea    0x4(%eax),%edx
  801afa:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801afd:	8b 00                	mov    (%eax),%eax
  801aff:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801b04:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b07:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801b0c:	eb 0d                	jmp    801b1b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b0e:	8d 45 14             	lea    0x14(%ebp),%eax
  801b11:	e8 3b fc ff ff       	call   801751 <getuint>
			base = 16;
  801b16:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b1b:	83 ec 0c             	sub    $0xc,%esp
  801b1e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801b22:	57                   	push   %edi
  801b23:	ff 75 e0             	pushl  -0x20(%ebp)
  801b26:	51                   	push   %ecx
  801b27:	52                   	push   %edx
  801b28:	50                   	push   %eax
  801b29:	89 da                	mov    %ebx,%edx
  801b2b:	89 f0                	mov    %esi,%eax
  801b2d:	e8 70 fb ff ff       	call   8016a2 <printnum>
			break;
  801b32:	83 c4 20             	add    $0x20,%esp
  801b35:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b38:	e9 ae fc ff ff       	jmp    8017eb <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b3d:	83 ec 08             	sub    $0x8,%esp
  801b40:	53                   	push   %ebx
  801b41:	51                   	push   %ecx
  801b42:	ff d6                	call   *%esi
			break;
  801b44:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b47:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b4a:	e9 9c fc ff ff       	jmp    8017eb <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b4f:	83 ec 08             	sub    $0x8,%esp
  801b52:	53                   	push   %ebx
  801b53:	6a 25                	push   $0x25
  801b55:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b57:	83 c4 10             	add    $0x10,%esp
  801b5a:	eb 03                	jmp    801b5f <vprintfmt+0x39a>
  801b5c:	83 ef 01             	sub    $0x1,%edi
  801b5f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b63:	75 f7                	jne    801b5c <vprintfmt+0x397>
  801b65:	e9 81 fc ff ff       	jmp    8017eb <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b6d:	5b                   	pop    %ebx
  801b6e:	5e                   	pop    %esi
  801b6f:	5f                   	pop    %edi
  801b70:	5d                   	pop    %ebp
  801b71:	c3                   	ret    

00801b72 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	83 ec 18             	sub    $0x18,%esp
  801b78:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b7e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b81:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b85:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b88:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b8f:	85 c0                	test   %eax,%eax
  801b91:	74 26                	je     801bb9 <vsnprintf+0x47>
  801b93:	85 d2                	test   %edx,%edx
  801b95:	7e 22                	jle    801bb9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b97:	ff 75 14             	pushl  0x14(%ebp)
  801b9a:	ff 75 10             	pushl  0x10(%ebp)
  801b9d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ba0:	50                   	push   %eax
  801ba1:	68 8b 17 80 00       	push   $0x80178b
  801ba6:	e8 1a fc ff ff       	call   8017c5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801bab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bae:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	eb 05                	jmp    801bbe <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801bb9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801bbe:	c9                   	leave  
  801bbf:	c3                   	ret    

00801bc0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801bc6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801bc9:	50                   	push   %eax
  801bca:	ff 75 10             	pushl  0x10(%ebp)
  801bcd:	ff 75 0c             	pushl  0xc(%ebp)
  801bd0:	ff 75 08             	pushl  0x8(%ebp)
  801bd3:	e8 9a ff ff ff       	call   801b72 <vsnprintf>
	va_end(ap);

	return rc;
}
  801bd8:	c9                   	leave  
  801bd9:	c3                   	ret    

00801bda <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801be0:	b8 00 00 00 00       	mov    $0x0,%eax
  801be5:	eb 03                	jmp    801bea <strlen+0x10>
		n++;
  801be7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801bea:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801bee:	75 f7                	jne    801be7 <strlen+0xd>
		n++;
	return n;
}
  801bf0:	5d                   	pop    %ebp
  801bf1:	c3                   	ret    

00801bf2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bfb:	ba 00 00 00 00       	mov    $0x0,%edx
  801c00:	eb 03                	jmp    801c05 <strnlen+0x13>
		n++;
  801c02:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c05:	39 c2                	cmp    %eax,%edx
  801c07:	74 08                	je     801c11 <strnlen+0x1f>
  801c09:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801c0d:	75 f3                	jne    801c02 <strnlen+0x10>
  801c0f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801c11:	5d                   	pop    %ebp
  801c12:	c3                   	ret    

00801c13 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801c13:	55                   	push   %ebp
  801c14:	89 e5                	mov    %esp,%ebp
  801c16:	53                   	push   %ebx
  801c17:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c1d:	89 c2                	mov    %eax,%edx
  801c1f:	83 c2 01             	add    $0x1,%edx
  801c22:	83 c1 01             	add    $0x1,%ecx
  801c25:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801c29:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c2c:	84 db                	test   %bl,%bl
  801c2e:	75 ef                	jne    801c1f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801c30:	5b                   	pop    %ebx
  801c31:	5d                   	pop    %ebp
  801c32:	c3                   	ret    

00801c33 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
  801c36:	53                   	push   %ebx
  801c37:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c3a:	53                   	push   %ebx
  801c3b:	e8 9a ff ff ff       	call   801bda <strlen>
  801c40:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c43:	ff 75 0c             	pushl  0xc(%ebp)
  801c46:	01 d8                	add    %ebx,%eax
  801c48:	50                   	push   %eax
  801c49:	e8 c5 ff ff ff       	call   801c13 <strcpy>
	return dst;
}
  801c4e:	89 d8                	mov    %ebx,%eax
  801c50:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c53:	c9                   	leave  
  801c54:	c3                   	ret    

00801c55 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c55:	55                   	push   %ebp
  801c56:	89 e5                	mov    %esp,%ebp
  801c58:	56                   	push   %esi
  801c59:	53                   	push   %ebx
  801c5a:	8b 75 08             	mov    0x8(%ebp),%esi
  801c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c60:	89 f3                	mov    %esi,%ebx
  801c62:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c65:	89 f2                	mov    %esi,%edx
  801c67:	eb 0f                	jmp    801c78 <strncpy+0x23>
		*dst++ = *src;
  801c69:	83 c2 01             	add    $0x1,%edx
  801c6c:	0f b6 01             	movzbl (%ecx),%eax
  801c6f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c72:	80 39 01             	cmpb   $0x1,(%ecx)
  801c75:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c78:	39 da                	cmp    %ebx,%edx
  801c7a:	75 ed                	jne    801c69 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c7c:	89 f0                	mov    %esi,%eax
  801c7e:	5b                   	pop    %ebx
  801c7f:	5e                   	pop    %esi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    

00801c82 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c82:	55                   	push   %ebp
  801c83:	89 e5                	mov    %esp,%ebp
  801c85:	56                   	push   %esi
  801c86:	53                   	push   %ebx
  801c87:	8b 75 08             	mov    0x8(%ebp),%esi
  801c8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c8d:	8b 55 10             	mov    0x10(%ebp),%edx
  801c90:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c92:	85 d2                	test   %edx,%edx
  801c94:	74 21                	je     801cb7 <strlcpy+0x35>
  801c96:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c9a:	89 f2                	mov    %esi,%edx
  801c9c:	eb 09                	jmp    801ca7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c9e:	83 c2 01             	add    $0x1,%edx
  801ca1:	83 c1 01             	add    $0x1,%ecx
  801ca4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801ca7:	39 c2                	cmp    %eax,%edx
  801ca9:	74 09                	je     801cb4 <strlcpy+0x32>
  801cab:	0f b6 19             	movzbl (%ecx),%ebx
  801cae:	84 db                	test   %bl,%bl
  801cb0:	75 ec                	jne    801c9e <strlcpy+0x1c>
  801cb2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801cb4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801cb7:	29 f0                	sub    %esi,%eax
}
  801cb9:	5b                   	pop    %ebx
  801cba:	5e                   	pop    %esi
  801cbb:	5d                   	pop    %ebp
  801cbc:	c3                   	ret    

00801cbd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801cbd:	55                   	push   %ebp
  801cbe:	89 e5                	mov    %esp,%ebp
  801cc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cc3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801cc6:	eb 06                	jmp    801cce <strcmp+0x11>
		p++, q++;
  801cc8:	83 c1 01             	add    $0x1,%ecx
  801ccb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801cce:	0f b6 01             	movzbl (%ecx),%eax
  801cd1:	84 c0                	test   %al,%al
  801cd3:	74 04                	je     801cd9 <strcmp+0x1c>
  801cd5:	3a 02                	cmp    (%edx),%al
  801cd7:	74 ef                	je     801cc8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801cd9:	0f b6 c0             	movzbl %al,%eax
  801cdc:	0f b6 12             	movzbl (%edx),%edx
  801cdf:	29 d0                	sub    %edx,%eax
}
  801ce1:	5d                   	pop    %ebp
  801ce2:	c3                   	ret    

00801ce3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801ce3:	55                   	push   %ebp
  801ce4:	89 e5                	mov    %esp,%ebp
  801ce6:	53                   	push   %ebx
  801ce7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cea:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ced:	89 c3                	mov    %eax,%ebx
  801cef:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801cf2:	eb 06                	jmp    801cfa <strncmp+0x17>
		n--, p++, q++;
  801cf4:	83 c0 01             	add    $0x1,%eax
  801cf7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801cfa:	39 d8                	cmp    %ebx,%eax
  801cfc:	74 15                	je     801d13 <strncmp+0x30>
  801cfe:	0f b6 08             	movzbl (%eax),%ecx
  801d01:	84 c9                	test   %cl,%cl
  801d03:	74 04                	je     801d09 <strncmp+0x26>
  801d05:	3a 0a                	cmp    (%edx),%cl
  801d07:	74 eb                	je     801cf4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d09:	0f b6 00             	movzbl (%eax),%eax
  801d0c:	0f b6 12             	movzbl (%edx),%edx
  801d0f:	29 d0                	sub    %edx,%eax
  801d11:	eb 05                	jmp    801d18 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801d13:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801d18:	5b                   	pop    %ebx
  801d19:	5d                   	pop    %ebp
  801d1a:	c3                   	ret    

00801d1b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d25:	eb 07                	jmp    801d2e <strchr+0x13>
		if (*s == c)
  801d27:	38 ca                	cmp    %cl,%dl
  801d29:	74 0f                	je     801d3a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801d2b:	83 c0 01             	add    $0x1,%eax
  801d2e:	0f b6 10             	movzbl (%eax),%edx
  801d31:	84 d2                	test   %dl,%dl
  801d33:	75 f2                	jne    801d27 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    

00801d3c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d42:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d46:	eb 03                	jmp    801d4b <strfind+0xf>
  801d48:	83 c0 01             	add    $0x1,%eax
  801d4b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d4e:	38 ca                	cmp    %cl,%dl
  801d50:	74 04                	je     801d56 <strfind+0x1a>
  801d52:	84 d2                	test   %dl,%dl
  801d54:	75 f2                	jne    801d48 <strfind+0xc>
			break;
	return (char *) s;
}
  801d56:	5d                   	pop    %ebp
  801d57:	c3                   	ret    

00801d58 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	57                   	push   %edi
  801d5c:	56                   	push   %esi
  801d5d:	53                   	push   %ebx
  801d5e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d61:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d64:	85 c9                	test   %ecx,%ecx
  801d66:	74 36                	je     801d9e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d68:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d6e:	75 28                	jne    801d98 <memset+0x40>
  801d70:	f6 c1 03             	test   $0x3,%cl
  801d73:	75 23                	jne    801d98 <memset+0x40>
		c &= 0xFF;
  801d75:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d79:	89 d3                	mov    %edx,%ebx
  801d7b:	c1 e3 08             	shl    $0x8,%ebx
  801d7e:	89 d6                	mov    %edx,%esi
  801d80:	c1 e6 18             	shl    $0x18,%esi
  801d83:	89 d0                	mov    %edx,%eax
  801d85:	c1 e0 10             	shl    $0x10,%eax
  801d88:	09 f0                	or     %esi,%eax
  801d8a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d8c:	89 d8                	mov    %ebx,%eax
  801d8e:	09 d0                	or     %edx,%eax
  801d90:	c1 e9 02             	shr    $0x2,%ecx
  801d93:	fc                   	cld    
  801d94:	f3 ab                	rep stos %eax,%es:(%edi)
  801d96:	eb 06                	jmp    801d9e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d9b:	fc                   	cld    
  801d9c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d9e:	89 f8                	mov    %edi,%eax
  801da0:	5b                   	pop    %ebx
  801da1:	5e                   	pop    %esi
  801da2:	5f                   	pop    %edi
  801da3:	5d                   	pop    %ebp
  801da4:	c3                   	ret    

00801da5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801da5:	55                   	push   %ebp
  801da6:	89 e5                	mov    %esp,%ebp
  801da8:	57                   	push   %edi
  801da9:	56                   	push   %esi
  801daa:	8b 45 08             	mov    0x8(%ebp),%eax
  801dad:	8b 75 0c             	mov    0xc(%ebp),%esi
  801db0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801db3:	39 c6                	cmp    %eax,%esi
  801db5:	73 35                	jae    801dec <memmove+0x47>
  801db7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801dba:	39 d0                	cmp    %edx,%eax
  801dbc:	73 2e                	jae    801dec <memmove+0x47>
		s += n;
		d += n;
  801dbe:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801dc1:	89 d6                	mov    %edx,%esi
  801dc3:	09 fe                	or     %edi,%esi
  801dc5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801dcb:	75 13                	jne    801de0 <memmove+0x3b>
  801dcd:	f6 c1 03             	test   $0x3,%cl
  801dd0:	75 0e                	jne    801de0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801dd2:	83 ef 04             	sub    $0x4,%edi
  801dd5:	8d 72 fc             	lea    -0x4(%edx),%esi
  801dd8:	c1 e9 02             	shr    $0x2,%ecx
  801ddb:	fd                   	std    
  801ddc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801dde:	eb 09                	jmp    801de9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801de0:	83 ef 01             	sub    $0x1,%edi
  801de3:	8d 72 ff             	lea    -0x1(%edx),%esi
  801de6:	fd                   	std    
  801de7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801de9:	fc                   	cld    
  801dea:	eb 1d                	jmp    801e09 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801dec:	89 f2                	mov    %esi,%edx
  801dee:	09 c2                	or     %eax,%edx
  801df0:	f6 c2 03             	test   $0x3,%dl
  801df3:	75 0f                	jne    801e04 <memmove+0x5f>
  801df5:	f6 c1 03             	test   $0x3,%cl
  801df8:	75 0a                	jne    801e04 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801dfa:	c1 e9 02             	shr    $0x2,%ecx
  801dfd:	89 c7                	mov    %eax,%edi
  801dff:	fc                   	cld    
  801e00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e02:	eb 05                	jmp    801e09 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801e04:	89 c7                	mov    %eax,%edi
  801e06:	fc                   	cld    
  801e07:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e09:	5e                   	pop    %esi
  801e0a:	5f                   	pop    %edi
  801e0b:	5d                   	pop    %ebp
  801e0c:	c3                   	ret    

00801e0d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e0d:	55                   	push   %ebp
  801e0e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801e10:	ff 75 10             	pushl  0x10(%ebp)
  801e13:	ff 75 0c             	pushl  0xc(%ebp)
  801e16:	ff 75 08             	pushl  0x8(%ebp)
  801e19:	e8 87 ff ff ff       	call   801da5 <memmove>
}
  801e1e:	c9                   	leave  
  801e1f:	c3                   	ret    

00801e20 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
  801e23:	56                   	push   %esi
  801e24:	53                   	push   %ebx
  801e25:	8b 45 08             	mov    0x8(%ebp),%eax
  801e28:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e2b:	89 c6                	mov    %eax,%esi
  801e2d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e30:	eb 1a                	jmp    801e4c <memcmp+0x2c>
		if (*s1 != *s2)
  801e32:	0f b6 08             	movzbl (%eax),%ecx
  801e35:	0f b6 1a             	movzbl (%edx),%ebx
  801e38:	38 d9                	cmp    %bl,%cl
  801e3a:	74 0a                	je     801e46 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e3c:	0f b6 c1             	movzbl %cl,%eax
  801e3f:	0f b6 db             	movzbl %bl,%ebx
  801e42:	29 d8                	sub    %ebx,%eax
  801e44:	eb 0f                	jmp    801e55 <memcmp+0x35>
		s1++, s2++;
  801e46:	83 c0 01             	add    $0x1,%eax
  801e49:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e4c:	39 f0                	cmp    %esi,%eax
  801e4e:	75 e2                	jne    801e32 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e55:	5b                   	pop    %ebx
  801e56:	5e                   	pop    %esi
  801e57:	5d                   	pop    %ebp
  801e58:	c3                   	ret    

00801e59 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e59:	55                   	push   %ebp
  801e5a:	89 e5                	mov    %esp,%ebp
  801e5c:	53                   	push   %ebx
  801e5d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e60:	89 c1                	mov    %eax,%ecx
  801e62:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e65:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e69:	eb 0a                	jmp    801e75 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e6b:	0f b6 10             	movzbl (%eax),%edx
  801e6e:	39 da                	cmp    %ebx,%edx
  801e70:	74 07                	je     801e79 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e72:	83 c0 01             	add    $0x1,%eax
  801e75:	39 c8                	cmp    %ecx,%eax
  801e77:	72 f2                	jb     801e6b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e79:	5b                   	pop    %ebx
  801e7a:	5d                   	pop    %ebp
  801e7b:	c3                   	ret    

00801e7c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	57                   	push   %edi
  801e80:	56                   	push   %esi
  801e81:	53                   	push   %ebx
  801e82:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e85:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e88:	eb 03                	jmp    801e8d <strtol+0x11>
		s++;
  801e8a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e8d:	0f b6 01             	movzbl (%ecx),%eax
  801e90:	3c 20                	cmp    $0x20,%al
  801e92:	74 f6                	je     801e8a <strtol+0xe>
  801e94:	3c 09                	cmp    $0x9,%al
  801e96:	74 f2                	je     801e8a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e98:	3c 2b                	cmp    $0x2b,%al
  801e9a:	75 0a                	jne    801ea6 <strtol+0x2a>
		s++;
  801e9c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e9f:	bf 00 00 00 00       	mov    $0x0,%edi
  801ea4:	eb 11                	jmp    801eb7 <strtol+0x3b>
  801ea6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801eab:	3c 2d                	cmp    $0x2d,%al
  801ead:	75 08                	jne    801eb7 <strtol+0x3b>
		s++, neg = 1;
  801eaf:	83 c1 01             	add    $0x1,%ecx
  801eb2:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801eb7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801ebd:	75 15                	jne    801ed4 <strtol+0x58>
  801ebf:	80 39 30             	cmpb   $0x30,(%ecx)
  801ec2:	75 10                	jne    801ed4 <strtol+0x58>
  801ec4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ec8:	75 7c                	jne    801f46 <strtol+0xca>
		s += 2, base = 16;
  801eca:	83 c1 02             	add    $0x2,%ecx
  801ecd:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ed2:	eb 16                	jmp    801eea <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801ed4:	85 db                	test   %ebx,%ebx
  801ed6:	75 12                	jne    801eea <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801ed8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801edd:	80 39 30             	cmpb   $0x30,(%ecx)
  801ee0:	75 08                	jne    801eea <strtol+0x6e>
		s++, base = 8;
  801ee2:	83 c1 01             	add    $0x1,%ecx
  801ee5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801eea:	b8 00 00 00 00       	mov    $0x0,%eax
  801eef:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801ef2:	0f b6 11             	movzbl (%ecx),%edx
  801ef5:	8d 72 d0             	lea    -0x30(%edx),%esi
  801ef8:	89 f3                	mov    %esi,%ebx
  801efa:	80 fb 09             	cmp    $0x9,%bl
  801efd:	77 08                	ja     801f07 <strtol+0x8b>
			dig = *s - '0';
  801eff:	0f be d2             	movsbl %dl,%edx
  801f02:	83 ea 30             	sub    $0x30,%edx
  801f05:	eb 22                	jmp    801f29 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801f07:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f0a:	89 f3                	mov    %esi,%ebx
  801f0c:	80 fb 19             	cmp    $0x19,%bl
  801f0f:	77 08                	ja     801f19 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801f11:	0f be d2             	movsbl %dl,%edx
  801f14:	83 ea 57             	sub    $0x57,%edx
  801f17:	eb 10                	jmp    801f29 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801f19:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f1c:	89 f3                	mov    %esi,%ebx
  801f1e:	80 fb 19             	cmp    $0x19,%bl
  801f21:	77 16                	ja     801f39 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801f23:	0f be d2             	movsbl %dl,%edx
  801f26:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801f29:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f2c:	7d 0b                	jge    801f39 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801f2e:	83 c1 01             	add    $0x1,%ecx
  801f31:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f35:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f37:	eb b9                	jmp    801ef2 <strtol+0x76>

	if (endptr)
  801f39:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f3d:	74 0d                	je     801f4c <strtol+0xd0>
		*endptr = (char *) s;
  801f3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f42:	89 0e                	mov    %ecx,(%esi)
  801f44:	eb 06                	jmp    801f4c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f46:	85 db                	test   %ebx,%ebx
  801f48:	74 98                	je     801ee2 <strtol+0x66>
  801f4a:	eb 9e                	jmp    801eea <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f4c:	89 c2                	mov    %eax,%edx
  801f4e:	f7 da                	neg    %edx
  801f50:	85 ff                	test   %edi,%edi
  801f52:	0f 45 c2             	cmovne %edx,%eax
}
  801f55:	5b                   	pop    %ebx
  801f56:	5e                   	pop    %esi
  801f57:	5f                   	pop    %edi
  801f58:	5d                   	pop    %ebp
  801f59:	c3                   	ret    

00801f5a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f5a:	55                   	push   %ebp
  801f5b:	89 e5                	mov    %esp,%ebp
  801f5d:	56                   	push   %esi
  801f5e:	53                   	push   %ebx
  801f5f:	8b 75 08             	mov    0x8(%ebp),%esi
  801f62:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f65:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801f68:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801f6a:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801f6f:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801f72:	83 ec 0c             	sub    $0xc,%esp
  801f75:	50                   	push   %eax
  801f76:	e8 9b e3 ff ff       	call   800316 <sys_ipc_recv>

	if (r < 0) {
  801f7b:	83 c4 10             	add    $0x10,%esp
  801f7e:	85 c0                	test   %eax,%eax
  801f80:	79 16                	jns    801f98 <ipc_recv+0x3e>
		if (from_env_store)
  801f82:	85 f6                	test   %esi,%esi
  801f84:	74 06                	je     801f8c <ipc_recv+0x32>
			*from_env_store = 0;
  801f86:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801f8c:	85 db                	test   %ebx,%ebx
  801f8e:	74 2c                	je     801fbc <ipc_recv+0x62>
			*perm_store = 0;
  801f90:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f96:	eb 24                	jmp    801fbc <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801f98:	85 f6                	test   %esi,%esi
  801f9a:	74 0a                	je     801fa6 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801f9c:	a1 08 40 80 00       	mov    0x804008,%eax
  801fa1:	8b 40 74             	mov    0x74(%eax),%eax
  801fa4:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801fa6:	85 db                	test   %ebx,%ebx
  801fa8:	74 0a                	je     801fb4 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801faa:	a1 08 40 80 00       	mov    0x804008,%eax
  801faf:	8b 40 78             	mov    0x78(%eax),%eax
  801fb2:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801fb4:	a1 08 40 80 00       	mov    0x804008,%eax
  801fb9:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801fbc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fbf:	5b                   	pop    %ebx
  801fc0:	5e                   	pop    %esi
  801fc1:	5d                   	pop    %ebp
  801fc2:	c3                   	ret    

00801fc3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fc3:	55                   	push   %ebp
  801fc4:	89 e5                	mov    %esp,%ebp
  801fc6:	57                   	push   %edi
  801fc7:	56                   	push   %esi
  801fc8:	53                   	push   %ebx
  801fc9:	83 ec 0c             	sub    $0xc,%esp
  801fcc:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fcf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801fd5:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801fd7:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801fdc:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801fdf:	ff 75 14             	pushl  0x14(%ebp)
  801fe2:	53                   	push   %ebx
  801fe3:	56                   	push   %esi
  801fe4:	57                   	push   %edi
  801fe5:	e8 09 e3 ff ff       	call   8002f3 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801fea:	83 c4 10             	add    $0x10,%esp
  801fed:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ff0:	75 07                	jne    801ff9 <ipc_send+0x36>
			sys_yield();
  801ff2:	e8 50 e1 ff ff       	call   800147 <sys_yield>
  801ff7:	eb e6                	jmp    801fdf <ipc_send+0x1c>
		} else if (r < 0) {
  801ff9:	85 c0                	test   %eax,%eax
  801ffb:	79 12                	jns    80200f <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801ffd:	50                   	push   %eax
  801ffe:	68 c0 27 80 00       	push   $0x8027c0
  802003:	6a 51                	push   $0x51
  802005:	68 cd 27 80 00       	push   $0x8027cd
  80200a:	e8 a6 f5 ff ff       	call   8015b5 <_panic>
		}
	}
}
  80200f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802012:	5b                   	pop    %ebx
  802013:	5e                   	pop    %esi
  802014:	5f                   	pop    %edi
  802015:	5d                   	pop    %ebp
  802016:	c3                   	ret    

00802017 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802017:	55                   	push   %ebp
  802018:	89 e5                	mov    %esp,%ebp
  80201a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80201d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802022:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802025:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80202b:	8b 52 50             	mov    0x50(%edx),%edx
  80202e:	39 ca                	cmp    %ecx,%edx
  802030:	75 0d                	jne    80203f <ipc_find_env+0x28>
			return envs[i].env_id;
  802032:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802035:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80203a:	8b 40 48             	mov    0x48(%eax),%eax
  80203d:	eb 0f                	jmp    80204e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80203f:	83 c0 01             	add    $0x1,%eax
  802042:	3d 00 04 00 00       	cmp    $0x400,%eax
  802047:	75 d9                	jne    802022 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802049:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80204e:	5d                   	pop    %ebp
  80204f:	c3                   	ret    

00802050 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802056:	89 d0                	mov    %edx,%eax
  802058:	c1 e8 16             	shr    $0x16,%eax
  80205b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802062:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802067:	f6 c1 01             	test   $0x1,%cl
  80206a:	74 1d                	je     802089 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80206c:	c1 ea 0c             	shr    $0xc,%edx
  80206f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802076:	f6 c2 01             	test   $0x1,%dl
  802079:	74 0e                	je     802089 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80207b:	c1 ea 0c             	shr    $0xc,%edx
  80207e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802085:	ef 
  802086:	0f b7 c0             	movzwl %ax,%eax
}
  802089:	5d                   	pop    %ebp
  80208a:	c3                   	ret    
  80208b:	66 90                	xchg   %ax,%ax
  80208d:	66 90                	xchg   %ax,%ax
  80208f:	90                   	nop

00802090 <__udivdi3>:
  802090:	55                   	push   %ebp
  802091:	57                   	push   %edi
  802092:	56                   	push   %esi
  802093:	53                   	push   %ebx
  802094:	83 ec 1c             	sub    $0x1c,%esp
  802097:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80209b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80209f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020a7:	85 f6                	test   %esi,%esi
  8020a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020ad:	89 ca                	mov    %ecx,%edx
  8020af:	89 f8                	mov    %edi,%eax
  8020b1:	75 3d                	jne    8020f0 <__udivdi3+0x60>
  8020b3:	39 cf                	cmp    %ecx,%edi
  8020b5:	0f 87 c5 00 00 00    	ja     802180 <__udivdi3+0xf0>
  8020bb:	85 ff                	test   %edi,%edi
  8020bd:	89 fd                	mov    %edi,%ebp
  8020bf:	75 0b                	jne    8020cc <__udivdi3+0x3c>
  8020c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020c6:	31 d2                	xor    %edx,%edx
  8020c8:	f7 f7                	div    %edi
  8020ca:	89 c5                	mov    %eax,%ebp
  8020cc:	89 c8                	mov    %ecx,%eax
  8020ce:	31 d2                	xor    %edx,%edx
  8020d0:	f7 f5                	div    %ebp
  8020d2:	89 c1                	mov    %eax,%ecx
  8020d4:	89 d8                	mov    %ebx,%eax
  8020d6:	89 cf                	mov    %ecx,%edi
  8020d8:	f7 f5                	div    %ebp
  8020da:	89 c3                	mov    %eax,%ebx
  8020dc:	89 d8                	mov    %ebx,%eax
  8020de:	89 fa                	mov    %edi,%edx
  8020e0:	83 c4 1c             	add    $0x1c,%esp
  8020e3:	5b                   	pop    %ebx
  8020e4:	5e                   	pop    %esi
  8020e5:	5f                   	pop    %edi
  8020e6:	5d                   	pop    %ebp
  8020e7:	c3                   	ret    
  8020e8:	90                   	nop
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	39 ce                	cmp    %ecx,%esi
  8020f2:	77 74                	ja     802168 <__udivdi3+0xd8>
  8020f4:	0f bd fe             	bsr    %esi,%edi
  8020f7:	83 f7 1f             	xor    $0x1f,%edi
  8020fa:	0f 84 98 00 00 00    	je     802198 <__udivdi3+0x108>
  802100:	bb 20 00 00 00       	mov    $0x20,%ebx
  802105:	89 f9                	mov    %edi,%ecx
  802107:	89 c5                	mov    %eax,%ebp
  802109:	29 fb                	sub    %edi,%ebx
  80210b:	d3 e6                	shl    %cl,%esi
  80210d:	89 d9                	mov    %ebx,%ecx
  80210f:	d3 ed                	shr    %cl,%ebp
  802111:	89 f9                	mov    %edi,%ecx
  802113:	d3 e0                	shl    %cl,%eax
  802115:	09 ee                	or     %ebp,%esi
  802117:	89 d9                	mov    %ebx,%ecx
  802119:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80211d:	89 d5                	mov    %edx,%ebp
  80211f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802123:	d3 ed                	shr    %cl,%ebp
  802125:	89 f9                	mov    %edi,%ecx
  802127:	d3 e2                	shl    %cl,%edx
  802129:	89 d9                	mov    %ebx,%ecx
  80212b:	d3 e8                	shr    %cl,%eax
  80212d:	09 c2                	or     %eax,%edx
  80212f:	89 d0                	mov    %edx,%eax
  802131:	89 ea                	mov    %ebp,%edx
  802133:	f7 f6                	div    %esi
  802135:	89 d5                	mov    %edx,%ebp
  802137:	89 c3                	mov    %eax,%ebx
  802139:	f7 64 24 0c          	mull   0xc(%esp)
  80213d:	39 d5                	cmp    %edx,%ebp
  80213f:	72 10                	jb     802151 <__udivdi3+0xc1>
  802141:	8b 74 24 08          	mov    0x8(%esp),%esi
  802145:	89 f9                	mov    %edi,%ecx
  802147:	d3 e6                	shl    %cl,%esi
  802149:	39 c6                	cmp    %eax,%esi
  80214b:	73 07                	jae    802154 <__udivdi3+0xc4>
  80214d:	39 d5                	cmp    %edx,%ebp
  80214f:	75 03                	jne    802154 <__udivdi3+0xc4>
  802151:	83 eb 01             	sub    $0x1,%ebx
  802154:	31 ff                	xor    %edi,%edi
  802156:	89 d8                	mov    %ebx,%eax
  802158:	89 fa                	mov    %edi,%edx
  80215a:	83 c4 1c             	add    $0x1c,%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	5f                   	pop    %edi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
  802162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802168:	31 ff                	xor    %edi,%edi
  80216a:	31 db                	xor    %ebx,%ebx
  80216c:	89 d8                	mov    %ebx,%eax
  80216e:	89 fa                	mov    %edi,%edx
  802170:	83 c4 1c             	add    $0x1c,%esp
  802173:	5b                   	pop    %ebx
  802174:	5e                   	pop    %esi
  802175:	5f                   	pop    %edi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    
  802178:	90                   	nop
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	89 d8                	mov    %ebx,%eax
  802182:	f7 f7                	div    %edi
  802184:	31 ff                	xor    %edi,%edi
  802186:	89 c3                	mov    %eax,%ebx
  802188:	89 d8                	mov    %ebx,%eax
  80218a:	89 fa                	mov    %edi,%edx
  80218c:	83 c4 1c             	add    $0x1c,%esp
  80218f:	5b                   	pop    %ebx
  802190:	5e                   	pop    %esi
  802191:	5f                   	pop    %edi
  802192:	5d                   	pop    %ebp
  802193:	c3                   	ret    
  802194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802198:	39 ce                	cmp    %ecx,%esi
  80219a:	72 0c                	jb     8021a8 <__udivdi3+0x118>
  80219c:	31 db                	xor    %ebx,%ebx
  80219e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021a2:	0f 87 34 ff ff ff    	ja     8020dc <__udivdi3+0x4c>
  8021a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021ad:	e9 2a ff ff ff       	jmp    8020dc <__udivdi3+0x4c>
  8021b2:	66 90                	xchg   %ax,%ax
  8021b4:	66 90                	xchg   %ax,%ax
  8021b6:	66 90                	xchg   %ax,%ax
  8021b8:	66 90                	xchg   %ax,%ax
  8021ba:	66 90                	xchg   %ax,%ax
  8021bc:	66 90                	xchg   %ax,%ax
  8021be:	66 90                	xchg   %ax,%ax

008021c0 <__umoddi3>:
  8021c0:	55                   	push   %ebp
  8021c1:	57                   	push   %edi
  8021c2:	56                   	push   %esi
  8021c3:	53                   	push   %ebx
  8021c4:	83 ec 1c             	sub    $0x1c,%esp
  8021c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021d7:	85 d2                	test   %edx,%edx
  8021d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021e1:	89 f3                	mov    %esi,%ebx
  8021e3:	89 3c 24             	mov    %edi,(%esp)
  8021e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ea:	75 1c                	jne    802208 <__umoddi3+0x48>
  8021ec:	39 f7                	cmp    %esi,%edi
  8021ee:	76 50                	jbe    802240 <__umoddi3+0x80>
  8021f0:	89 c8                	mov    %ecx,%eax
  8021f2:	89 f2                	mov    %esi,%edx
  8021f4:	f7 f7                	div    %edi
  8021f6:	89 d0                	mov    %edx,%eax
  8021f8:	31 d2                	xor    %edx,%edx
  8021fa:	83 c4 1c             	add    $0x1c,%esp
  8021fd:	5b                   	pop    %ebx
  8021fe:	5e                   	pop    %esi
  8021ff:	5f                   	pop    %edi
  802200:	5d                   	pop    %ebp
  802201:	c3                   	ret    
  802202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802208:	39 f2                	cmp    %esi,%edx
  80220a:	89 d0                	mov    %edx,%eax
  80220c:	77 52                	ja     802260 <__umoddi3+0xa0>
  80220e:	0f bd ea             	bsr    %edx,%ebp
  802211:	83 f5 1f             	xor    $0x1f,%ebp
  802214:	75 5a                	jne    802270 <__umoddi3+0xb0>
  802216:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80221a:	0f 82 e0 00 00 00    	jb     802300 <__umoddi3+0x140>
  802220:	39 0c 24             	cmp    %ecx,(%esp)
  802223:	0f 86 d7 00 00 00    	jbe    802300 <__umoddi3+0x140>
  802229:	8b 44 24 08          	mov    0x8(%esp),%eax
  80222d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802231:	83 c4 1c             	add    $0x1c,%esp
  802234:	5b                   	pop    %ebx
  802235:	5e                   	pop    %esi
  802236:	5f                   	pop    %edi
  802237:	5d                   	pop    %ebp
  802238:	c3                   	ret    
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	85 ff                	test   %edi,%edi
  802242:	89 fd                	mov    %edi,%ebp
  802244:	75 0b                	jne    802251 <__umoddi3+0x91>
  802246:	b8 01 00 00 00       	mov    $0x1,%eax
  80224b:	31 d2                	xor    %edx,%edx
  80224d:	f7 f7                	div    %edi
  80224f:	89 c5                	mov    %eax,%ebp
  802251:	89 f0                	mov    %esi,%eax
  802253:	31 d2                	xor    %edx,%edx
  802255:	f7 f5                	div    %ebp
  802257:	89 c8                	mov    %ecx,%eax
  802259:	f7 f5                	div    %ebp
  80225b:	89 d0                	mov    %edx,%eax
  80225d:	eb 99                	jmp    8021f8 <__umoddi3+0x38>
  80225f:	90                   	nop
  802260:	89 c8                	mov    %ecx,%eax
  802262:	89 f2                	mov    %esi,%edx
  802264:	83 c4 1c             	add    $0x1c,%esp
  802267:	5b                   	pop    %ebx
  802268:	5e                   	pop    %esi
  802269:	5f                   	pop    %edi
  80226a:	5d                   	pop    %ebp
  80226b:	c3                   	ret    
  80226c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802270:	8b 34 24             	mov    (%esp),%esi
  802273:	bf 20 00 00 00       	mov    $0x20,%edi
  802278:	89 e9                	mov    %ebp,%ecx
  80227a:	29 ef                	sub    %ebp,%edi
  80227c:	d3 e0                	shl    %cl,%eax
  80227e:	89 f9                	mov    %edi,%ecx
  802280:	89 f2                	mov    %esi,%edx
  802282:	d3 ea                	shr    %cl,%edx
  802284:	89 e9                	mov    %ebp,%ecx
  802286:	09 c2                	or     %eax,%edx
  802288:	89 d8                	mov    %ebx,%eax
  80228a:	89 14 24             	mov    %edx,(%esp)
  80228d:	89 f2                	mov    %esi,%edx
  80228f:	d3 e2                	shl    %cl,%edx
  802291:	89 f9                	mov    %edi,%ecx
  802293:	89 54 24 04          	mov    %edx,0x4(%esp)
  802297:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80229b:	d3 e8                	shr    %cl,%eax
  80229d:	89 e9                	mov    %ebp,%ecx
  80229f:	89 c6                	mov    %eax,%esi
  8022a1:	d3 e3                	shl    %cl,%ebx
  8022a3:	89 f9                	mov    %edi,%ecx
  8022a5:	89 d0                	mov    %edx,%eax
  8022a7:	d3 e8                	shr    %cl,%eax
  8022a9:	89 e9                	mov    %ebp,%ecx
  8022ab:	09 d8                	or     %ebx,%eax
  8022ad:	89 d3                	mov    %edx,%ebx
  8022af:	89 f2                	mov    %esi,%edx
  8022b1:	f7 34 24             	divl   (%esp)
  8022b4:	89 d6                	mov    %edx,%esi
  8022b6:	d3 e3                	shl    %cl,%ebx
  8022b8:	f7 64 24 04          	mull   0x4(%esp)
  8022bc:	39 d6                	cmp    %edx,%esi
  8022be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022c2:	89 d1                	mov    %edx,%ecx
  8022c4:	89 c3                	mov    %eax,%ebx
  8022c6:	72 08                	jb     8022d0 <__umoddi3+0x110>
  8022c8:	75 11                	jne    8022db <__umoddi3+0x11b>
  8022ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ce:	73 0b                	jae    8022db <__umoddi3+0x11b>
  8022d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022d4:	1b 14 24             	sbb    (%esp),%edx
  8022d7:	89 d1                	mov    %edx,%ecx
  8022d9:	89 c3                	mov    %eax,%ebx
  8022db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022df:	29 da                	sub    %ebx,%edx
  8022e1:	19 ce                	sbb    %ecx,%esi
  8022e3:	89 f9                	mov    %edi,%ecx
  8022e5:	89 f0                	mov    %esi,%eax
  8022e7:	d3 e0                	shl    %cl,%eax
  8022e9:	89 e9                	mov    %ebp,%ecx
  8022eb:	d3 ea                	shr    %cl,%edx
  8022ed:	89 e9                	mov    %ebp,%ecx
  8022ef:	d3 ee                	shr    %cl,%esi
  8022f1:	09 d0                	or     %edx,%eax
  8022f3:	89 f2                	mov    %esi,%edx
  8022f5:	83 c4 1c             	add    $0x1c,%esp
  8022f8:	5b                   	pop    %ebx
  8022f9:	5e                   	pop    %esi
  8022fa:	5f                   	pop    %edi
  8022fb:	5d                   	pop    %ebp
  8022fc:	c3                   	ret    
  8022fd:	8d 76 00             	lea    0x0(%esi),%esi
  802300:	29 f9                	sub    %edi,%ecx
  802302:	19 d6                	sbb    %edx,%esi
  802304:	89 74 24 04          	mov    %esi,0x4(%esp)
  802308:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80230c:	e9 18 ff ff ff       	jmp    802229 <__umoddi3+0x69>
