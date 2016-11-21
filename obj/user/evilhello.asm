
obj/user/evilhello.debug:     file format elf32-i386


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

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 65 00 00 00       	call   8000aa <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

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
  800067:	a3 04 40 80 00       	mov    %eax,0x804004

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
  800096:	e8 87 04 00 00       	call   800522 <close_all>
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
  80010f:	68 ea 1d 80 00       	push   $0x801dea
  800114:	6a 23                	push   $0x23
  800116:	68 07 1e 80 00       	push   $0x801e07
  80011b:	e8 4a 0f 00 00       	call   80106a <_panic>

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
  800190:	68 ea 1d 80 00       	push   $0x801dea
  800195:	6a 23                	push   $0x23
  800197:	68 07 1e 80 00       	push   $0x801e07
  80019c:	e8 c9 0e 00 00       	call   80106a <_panic>

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
  8001d2:	68 ea 1d 80 00       	push   $0x801dea
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 07 1e 80 00       	push   $0x801e07
  8001de:	e8 87 0e 00 00       	call   80106a <_panic>

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
  800214:	68 ea 1d 80 00       	push   $0x801dea
  800219:	6a 23                	push   $0x23
  80021b:	68 07 1e 80 00       	push   $0x801e07
  800220:	e8 45 0e 00 00       	call   80106a <_panic>

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
  800256:	68 ea 1d 80 00       	push   $0x801dea
  80025b:	6a 23                	push   $0x23
  80025d:	68 07 1e 80 00       	push   $0x801e07
  800262:	e8 03 0e 00 00       	call   80106a <_panic>

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
  800298:	68 ea 1d 80 00       	push   $0x801dea
  80029d:	6a 23                	push   $0x23
  80029f:	68 07 1e 80 00       	push   $0x801e07
  8002a4:	e8 c1 0d 00 00       	call   80106a <_panic>

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
  8002da:	68 ea 1d 80 00       	push   $0x801dea
  8002df:	6a 23                	push   $0x23
  8002e1:	68 07 1e 80 00       	push   $0x801e07
  8002e6:	e8 7f 0d 00 00       	call   80106a <_panic>

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
  80033e:	68 ea 1d 80 00       	push   $0x801dea
  800343:	6a 23                	push   $0x23
  800345:	68 07 1e 80 00       	push   $0x801e07
  80034a:	e8 1b 0d 00 00       	call   80106a <_panic>

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

00800357 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
  800362:	c1 e8 0c             	shr    $0xc,%eax
}
  800365:	5d                   	pop    %ebp
  800366:	c3                   	ret    

00800367 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80036a:	8b 45 08             	mov    0x8(%ebp),%eax
  80036d:	05 00 00 00 30       	add    $0x30000000,%eax
  800372:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800377:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800384:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 16             	shr    $0x16,%edx
  80038e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	74 11                	je     8003ab <fd_alloc+0x2d>
  80039a:	89 c2                	mov    %eax,%edx
  80039c:	c1 ea 0c             	shr    $0xc,%edx
  80039f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a6:	f6 c2 01             	test   $0x1,%dl
  8003a9:	75 09                	jne    8003b4 <fd_alloc+0x36>
			*fd_store = fd;
  8003ab:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b2:	eb 17                	jmp    8003cb <fd_alloc+0x4d>
  8003b4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003be:	75 c9                	jne    800389 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003c0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d3:	83 f8 1f             	cmp    $0x1f,%eax
  8003d6:	77 36                	ja     80040e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d8:	c1 e0 0c             	shl    $0xc,%eax
  8003db:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 16             	shr    $0x16,%edx
  8003e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 24                	je     800415 <fd_lookup+0x48>
  8003f1:	89 c2                	mov    %eax,%edx
  8003f3:	c1 ea 0c             	shr    $0xc,%edx
  8003f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fd:	f6 c2 01             	test   $0x1,%dl
  800400:	74 1a                	je     80041c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800402:	8b 55 0c             	mov    0xc(%ebp),%edx
  800405:	89 02                	mov    %eax,(%edx)
	return 0;
  800407:	b8 00 00 00 00       	mov    $0x0,%eax
  80040c:	eb 13                	jmp    800421 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800413:	eb 0c                	jmp    800421 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800415:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041a:	eb 05                	jmp    800421 <fd_lookup+0x54>
  80041c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800421:	5d                   	pop    %ebp
  800422:	c3                   	ret    

00800423 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80042c:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800431:	eb 13                	jmp    800446 <dev_lookup+0x23>
  800433:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800436:	39 08                	cmp    %ecx,(%eax)
  800438:	75 0c                	jne    800446 <dev_lookup+0x23>
			*dev = devtab[i];
  80043a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043f:	b8 00 00 00 00       	mov    $0x0,%eax
  800444:	eb 2e                	jmp    800474 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800446:	8b 02                	mov    (%edx),%eax
  800448:	85 c0                	test   %eax,%eax
  80044a:	75 e7                	jne    800433 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80044c:	a1 04 40 80 00       	mov    0x804004,%eax
  800451:	8b 40 48             	mov    0x48(%eax),%eax
  800454:	83 ec 04             	sub    $0x4,%esp
  800457:	51                   	push   %ecx
  800458:	50                   	push   %eax
  800459:	68 18 1e 80 00       	push   $0x801e18
  80045e:	e8 e0 0c 00 00       	call   801143 <cprintf>
	*dev = 0;
  800463:	8b 45 0c             	mov    0xc(%ebp),%eax
  800466:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80046c:	83 c4 10             	add    $0x10,%esp
  80046f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800474:	c9                   	leave  
  800475:	c3                   	ret    

00800476 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	56                   	push   %esi
  80047a:	53                   	push   %ebx
  80047b:	83 ec 10             	sub    $0x10,%esp
  80047e:	8b 75 08             	mov    0x8(%ebp),%esi
  800481:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800484:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800487:	50                   	push   %eax
  800488:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048e:	c1 e8 0c             	shr    $0xc,%eax
  800491:	50                   	push   %eax
  800492:	e8 36 ff ff ff       	call   8003cd <fd_lookup>
  800497:	83 c4 08             	add    $0x8,%esp
  80049a:	85 c0                	test   %eax,%eax
  80049c:	78 05                	js     8004a3 <fd_close+0x2d>
	    || fd != fd2)
  80049e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004a1:	74 0c                	je     8004af <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a3:	84 db                	test   %bl,%bl
  8004a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004aa:	0f 44 c2             	cmove  %edx,%eax
  8004ad:	eb 41                	jmp    8004f0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b5:	50                   	push   %eax
  8004b6:	ff 36                	pushl  (%esi)
  8004b8:	e8 66 ff ff ff       	call   800423 <dev_lookup>
  8004bd:	89 c3                	mov    %eax,%ebx
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	85 c0                	test   %eax,%eax
  8004c4:	78 1a                	js     8004e0 <fd_close+0x6a>
		if (dev->dev_close)
  8004c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004cc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	74 0b                	je     8004e0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	56                   	push   %esi
  8004d9:	ff d0                	call   *%eax
  8004db:	89 c3                	mov    %eax,%ebx
  8004dd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	56                   	push   %esi
  8004e4:	6a 00                	push   $0x0
  8004e6:	e8 00 fd ff ff       	call   8001eb <sys_page_unmap>
	return r;
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	89 d8                	mov    %ebx,%eax
}
  8004f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f3:	5b                   	pop    %ebx
  8004f4:	5e                   	pop    %esi
  8004f5:	5d                   	pop    %ebp
  8004f6:	c3                   	ret    

008004f7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f7:	55                   	push   %ebp
  8004f8:	89 e5                	mov    %esp,%ebp
  8004fa:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800500:	50                   	push   %eax
  800501:	ff 75 08             	pushl  0x8(%ebp)
  800504:	e8 c4 fe ff ff       	call   8003cd <fd_lookup>
  800509:	83 c4 08             	add    $0x8,%esp
  80050c:	85 c0                	test   %eax,%eax
  80050e:	78 10                	js     800520 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	6a 01                	push   $0x1
  800515:	ff 75 f4             	pushl  -0xc(%ebp)
  800518:	e8 59 ff ff ff       	call   800476 <fd_close>
  80051d:	83 c4 10             	add    $0x10,%esp
}
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <close_all>:

void
close_all(void)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	53                   	push   %ebx
  800526:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800529:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052e:	83 ec 0c             	sub    $0xc,%esp
  800531:	53                   	push   %ebx
  800532:	e8 c0 ff ff ff       	call   8004f7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800537:	83 c3 01             	add    $0x1,%ebx
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	83 fb 20             	cmp    $0x20,%ebx
  800540:	75 ec                	jne    80052e <close_all+0xc>
		close(i);
}
  800542:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800545:	c9                   	leave  
  800546:	c3                   	ret    

00800547 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800547:	55                   	push   %ebp
  800548:	89 e5                	mov    %esp,%ebp
  80054a:	57                   	push   %edi
  80054b:	56                   	push   %esi
  80054c:	53                   	push   %ebx
  80054d:	83 ec 2c             	sub    $0x2c,%esp
  800550:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800553:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800556:	50                   	push   %eax
  800557:	ff 75 08             	pushl  0x8(%ebp)
  80055a:	e8 6e fe ff ff       	call   8003cd <fd_lookup>
  80055f:	83 c4 08             	add    $0x8,%esp
  800562:	85 c0                	test   %eax,%eax
  800564:	0f 88 c1 00 00 00    	js     80062b <dup+0xe4>
		return r;
	close(newfdnum);
  80056a:	83 ec 0c             	sub    $0xc,%esp
  80056d:	56                   	push   %esi
  80056e:	e8 84 ff ff ff       	call   8004f7 <close>

	newfd = INDEX2FD(newfdnum);
  800573:	89 f3                	mov    %esi,%ebx
  800575:	c1 e3 0c             	shl    $0xc,%ebx
  800578:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80057e:	83 c4 04             	add    $0x4,%esp
  800581:	ff 75 e4             	pushl  -0x1c(%ebp)
  800584:	e8 de fd ff ff       	call   800367 <fd2data>
  800589:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80058b:	89 1c 24             	mov    %ebx,(%esp)
  80058e:	e8 d4 fd ff ff       	call   800367 <fd2data>
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800599:	89 f8                	mov    %edi,%eax
  80059b:	c1 e8 16             	shr    $0x16,%eax
  80059e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a5:	a8 01                	test   $0x1,%al
  8005a7:	74 37                	je     8005e0 <dup+0x99>
  8005a9:	89 f8                	mov    %edi,%eax
  8005ab:	c1 e8 0c             	shr    $0xc,%eax
  8005ae:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b5:	f6 c2 01             	test   $0x1,%dl
  8005b8:	74 26                	je     8005e0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c1:	83 ec 0c             	sub    $0xc,%esp
  8005c4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c9:	50                   	push   %eax
  8005ca:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005cd:	6a 00                	push   $0x0
  8005cf:	57                   	push   %edi
  8005d0:	6a 00                	push   $0x0
  8005d2:	e8 d2 fb ff ff       	call   8001a9 <sys_page_map>
  8005d7:	89 c7                	mov    %eax,%edi
  8005d9:	83 c4 20             	add    $0x20,%esp
  8005dc:	85 c0                	test   %eax,%eax
  8005de:	78 2e                	js     80060e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e3:	89 d0                	mov    %edx,%eax
  8005e5:	c1 e8 0c             	shr    $0xc,%eax
  8005e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ef:	83 ec 0c             	sub    $0xc,%esp
  8005f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f7:	50                   	push   %eax
  8005f8:	53                   	push   %ebx
  8005f9:	6a 00                	push   $0x0
  8005fb:	52                   	push   %edx
  8005fc:	6a 00                	push   $0x0
  8005fe:	e8 a6 fb ff ff       	call   8001a9 <sys_page_map>
  800603:	89 c7                	mov    %eax,%edi
  800605:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800608:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060a:	85 ff                	test   %edi,%edi
  80060c:	79 1d                	jns    80062b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 00                	push   $0x0
  800614:	e8 d2 fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  800619:	83 c4 08             	add    $0x8,%esp
  80061c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061f:	6a 00                	push   $0x0
  800621:	e8 c5 fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	89 f8                	mov    %edi,%eax
}
  80062b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062e:	5b                   	pop    %ebx
  80062f:	5e                   	pop    %esi
  800630:	5f                   	pop    %edi
  800631:	5d                   	pop    %ebp
  800632:	c3                   	ret    

00800633 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800633:	55                   	push   %ebp
  800634:	89 e5                	mov    %esp,%ebp
  800636:	53                   	push   %ebx
  800637:	83 ec 14             	sub    $0x14,%esp
  80063a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800640:	50                   	push   %eax
  800641:	53                   	push   %ebx
  800642:	e8 86 fd ff ff       	call   8003cd <fd_lookup>
  800647:	83 c4 08             	add    $0x8,%esp
  80064a:	89 c2                	mov    %eax,%edx
  80064c:	85 c0                	test   %eax,%eax
  80064e:	78 6d                	js     8006bd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800656:	50                   	push   %eax
  800657:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065a:	ff 30                	pushl  (%eax)
  80065c:	e8 c2 fd ff ff       	call   800423 <dev_lookup>
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	85 c0                	test   %eax,%eax
  800666:	78 4c                	js     8006b4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800668:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066b:	8b 42 08             	mov    0x8(%edx),%eax
  80066e:	83 e0 03             	and    $0x3,%eax
  800671:	83 f8 01             	cmp    $0x1,%eax
  800674:	75 21                	jne    800697 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800676:	a1 04 40 80 00       	mov    0x804004,%eax
  80067b:	8b 40 48             	mov    0x48(%eax),%eax
  80067e:	83 ec 04             	sub    $0x4,%esp
  800681:	53                   	push   %ebx
  800682:	50                   	push   %eax
  800683:	68 59 1e 80 00       	push   $0x801e59
  800688:	e8 b6 0a 00 00       	call   801143 <cprintf>
		return -E_INVAL;
  80068d:	83 c4 10             	add    $0x10,%esp
  800690:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800695:	eb 26                	jmp    8006bd <read+0x8a>
	}
	if (!dev->dev_read)
  800697:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069a:	8b 40 08             	mov    0x8(%eax),%eax
  80069d:	85 c0                	test   %eax,%eax
  80069f:	74 17                	je     8006b8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a1:	83 ec 04             	sub    $0x4,%esp
  8006a4:	ff 75 10             	pushl  0x10(%ebp)
  8006a7:	ff 75 0c             	pushl  0xc(%ebp)
  8006aa:	52                   	push   %edx
  8006ab:	ff d0                	call   *%eax
  8006ad:	89 c2                	mov    %eax,%edx
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	eb 09                	jmp    8006bd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b4:	89 c2                	mov    %eax,%edx
  8006b6:	eb 05                	jmp    8006bd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006bd:	89 d0                	mov    %edx,%eax
  8006bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c2:	c9                   	leave  
  8006c3:	c3                   	ret    

008006c4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	57                   	push   %edi
  8006c8:	56                   	push   %esi
  8006c9:	53                   	push   %ebx
  8006ca:	83 ec 0c             	sub    $0xc,%esp
  8006cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d8:	eb 21                	jmp    8006fb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006da:	83 ec 04             	sub    $0x4,%esp
  8006dd:	89 f0                	mov    %esi,%eax
  8006df:	29 d8                	sub    %ebx,%eax
  8006e1:	50                   	push   %eax
  8006e2:	89 d8                	mov    %ebx,%eax
  8006e4:	03 45 0c             	add    0xc(%ebp),%eax
  8006e7:	50                   	push   %eax
  8006e8:	57                   	push   %edi
  8006e9:	e8 45 ff ff ff       	call   800633 <read>
		if (m < 0)
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	78 10                	js     800705 <readn+0x41>
			return m;
		if (m == 0)
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	74 0a                	je     800703 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f9:	01 c3                	add    %eax,%ebx
  8006fb:	39 f3                	cmp    %esi,%ebx
  8006fd:	72 db                	jb     8006da <readn+0x16>
  8006ff:	89 d8                	mov    %ebx,%eax
  800701:	eb 02                	jmp    800705 <readn+0x41>
  800703:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800705:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800708:	5b                   	pop    %ebx
  800709:	5e                   	pop    %esi
  80070a:	5f                   	pop    %edi
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	53                   	push   %ebx
  800711:	83 ec 14             	sub    $0x14,%esp
  800714:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800717:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071a:	50                   	push   %eax
  80071b:	53                   	push   %ebx
  80071c:	e8 ac fc ff ff       	call   8003cd <fd_lookup>
  800721:	83 c4 08             	add    $0x8,%esp
  800724:	89 c2                	mov    %eax,%edx
  800726:	85 c0                	test   %eax,%eax
  800728:	78 68                	js     800792 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800730:	50                   	push   %eax
  800731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800734:	ff 30                	pushl  (%eax)
  800736:	e8 e8 fc ff ff       	call   800423 <dev_lookup>
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	85 c0                	test   %eax,%eax
  800740:	78 47                	js     800789 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800742:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800745:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800749:	75 21                	jne    80076c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074b:	a1 04 40 80 00       	mov    0x804004,%eax
  800750:	8b 40 48             	mov    0x48(%eax),%eax
  800753:	83 ec 04             	sub    $0x4,%esp
  800756:	53                   	push   %ebx
  800757:	50                   	push   %eax
  800758:	68 75 1e 80 00       	push   $0x801e75
  80075d:	e8 e1 09 00 00       	call   801143 <cprintf>
		return -E_INVAL;
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80076a:	eb 26                	jmp    800792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80076c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076f:	8b 52 0c             	mov    0xc(%edx),%edx
  800772:	85 d2                	test   %edx,%edx
  800774:	74 17                	je     80078d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800776:	83 ec 04             	sub    $0x4,%esp
  800779:	ff 75 10             	pushl  0x10(%ebp)
  80077c:	ff 75 0c             	pushl  0xc(%ebp)
  80077f:	50                   	push   %eax
  800780:	ff d2                	call   *%edx
  800782:	89 c2                	mov    %eax,%edx
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	eb 09                	jmp    800792 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800789:	89 c2                	mov    %eax,%edx
  80078b:	eb 05                	jmp    800792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80078d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800792:	89 d0                	mov    %edx,%eax
  800794:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <seek>:

int
seek(int fdnum, off_t offset)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a2:	50                   	push   %eax
  8007a3:	ff 75 08             	pushl  0x8(%ebp)
  8007a6:	e8 22 fc ff ff       	call   8003cd <fd_lookup>
  8007ab:	83 c4 08             	add    $0x8,%esp
  8007ae:	85 c0                	test   %eax,%eax
  8007b0:	78 0e                	js     8007c0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	83 ec 14             	sub    $0x14,%esp
  8007c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cf:	50                   	push   %eax
  8007d0:	53                   	push   %ebx
  8007d1:	e8 f7 fb ff ff       	call   8003cd <fd_lookup>
  8007d6:	83 c4 08             	add    $0x8,%esp
  8007d9:	89 c2                	mov    %eax,%edx
  8007db:	85 c0                	test   %eax,%eax
  8007dd:	78 65                	js     800844 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e5:	50                   	push   %eax
  8007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e9:	ff 30                	pushl  (%eax)
  8007eb:	e8 33 fc ff ff       	call   800423 <dev_lookup>
  8007f0:	83 c4 10             	add    $0x10,%esp
  8007f3:	85 c0                	test   %eax,%eax
  8007f5:	78 44                	js     80083b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fe:	75 21                	jne    800821 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800800:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800805:	8b 40 48             	mov    0x48(%eax),%eax
  800808:	83 ec 04             	sub    $0x4,%esp
  80080b:	53                   	push   %ebx
  80080c:	50                   	push   %eax
  80080d:	68 38 1e 80 00       	push   $0x801e38
  800812:	e8 2c 09 00 00       	call   801143 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800817:	83 c4 10             	add    $0x10,%esp
  80081a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80081f:	eb 23                	jmp    800844 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800821:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800824:	8b 52 18             	mov    0x18(%edx),%edx
  800827:	85 d2                	test   %edx,%edx
  800829:	74 14                	je     80083f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082b:	83 ec 08             	sub    $0x8,%esp
  80082e:	ff 75 0c             	pushl  0xc(%ebp)
  800831:	50                   	push   %eax
  800832:	ff d2                	call   *%edx
  800834:	89 c2                	mov    %eax,%edx
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	eb 09                	jmp    800844 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083b:	89 c2                	mov    %eax,%edx
  80083d:	eb 05                	jmp    800844 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80083f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800844:	89 d0                	mov    %edx,%eax
  800846:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	83 ec 14             	sub    $0x14,%esp
  800852:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800855:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800858:	50                   	push   %eax
  800859:	ff 75 08             	pushl  0x8(%ebp)
  80085c:	e8 6c fb ff ff       	call   8003cd <fd_lookup>
  800861:	83 c4 08             	add    $0x8,%esp
  800864:	89 c2                	mov    %eax,%edx
  800866:	85 c0                	test   %eax,%eax
  800868:	78 58                	js     8008c2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800870:	50                   	push   %eax
  800871:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800874:	ff 30                	pushl  (%eax)
  800876:	e8 a8 fb ff ff       	call   800423 <dev_lookup>
  80087b:	83 c4 10             	add    $0x10,%esp
  80087e:	85 c0                	test   %eax,%eax
  800880:	78 37                	js     8008b9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800885:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800889:	74 32                	je     8008bd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80088e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800895:	00 00 00 
	stat->st_isdir = 0;
  800898:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80089f:	00 00 00 
	stat->st_dev = dev;
  8008a2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	53                   	push   %ebx
  8008ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8008af:	ff 50 14             	call   *0x14(%eax)
  8008b2:	89 c2                	mov    %eax,%edx
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	eb 09                	jmp    8008c2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b9:	89 c2                	mov    %eax,%edx
  8008bb:	eb 05                	jmp    8008c2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008c2:	89 d0                	mov    %edx,%eax
  8008c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c7:	c9                   	leave  
  8008c8:	c3                   	ret    

008008c9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	56                   	push   %esi
  8008cd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ce:	83 ec 08             	sub    $0x8,%esp
  8008d1:	6a 00                	push   $0x0
  8008d3:	ff 75 08             	pushl  0x8(%ebp)
  8008d6:	e8 0c 02 00 00       	call   800ae7 <open>
  8008db:	89 c3                	mov    %eax,%ebx
  8008dd:	83 c4 10             	add    $0x10,%esp
  8008e0:	85 c0                	test   %eax,%eax
  8008e2:	78 1b                	js     8008ff <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e4:	83 ec 08             	sub    $0x8,%esp
  8008e7:	ff 75 0c             	pushl  0xc(%ebp)
  8008ea:	50                   	push   %eax
  8008eb:	e8 5b ff ff ff       	call   80084b <fstat>
  8008f0:	89 c6                	mov    %eax,%esi
	close(fd);
  8008f2:	89 1c 24             	mov    %ebx,(%esp)
  8008f5:	e8 fd fb ff ff       	call   8004f7 <close>
	return r;
  8008fa:	83 c4 10             	add    $0x10,%esp
  8008fd:	89 f0                	mov    %esi,%eax
}
  8008ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800902:	5b                   	pop    %ebx
  800903:	5e                   	pop    %esi
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	56                   	push   %esi
  80090a:	53                   	push   %ebx
  80090b:	89 c6                	mov    %eax,%esi
  80090d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80090f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800916:	75 12                	jne    80092a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800918:	83 ec 0c             	sub    $0xc,%esp
  80091b:	6a 01                	push   $0x1
  80091d:	e8 aa 11 00 00       	call   801acc <ipc_find_env>
  800922:	a3 00 40 80 00       	mov    %eax,0x804000
  800927:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80092a:	6a 07                	push   $0x7
  80092c:	68 00 50 80 00       	push   $0x805000
  800931:	56                   	push   %esi
  800932:	ff 35 00 40 80 00    	pushl  0x804000
  800938:	e8 3b 11 00 00       	call   801a78 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80093d:	83 c4 0c             	add    $0xc,%esp
  800940:	6a 00                	push   $0x0
  800942:	53                   	push   %ebx
  800943:	6a 00                	push   $0x0
  800945:	e8 c5 10 00 00       	call   801a0f <ipc_recv>
}
  80094a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094d:	5b                   	pop    %ebx
  80094e:	5e                   	pop    %esi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 40 0c             	mov    0xc(%eax),%eax
  80095d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80096a:	ba 00 00 00 00       	mov    $0x0,%edx
  80096f:	b8 02 00 00 00       	mov    $0x2,%eax
  800974:	e8 8d ff ff ff       	call   800906 <fsipc>
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 40 0c             	mov    0xc(%eax),%eax
  800987:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80098c:	ba 00 00 00 00       	mov    $0x0,%edx
  800991:	b8 06 00 00 00       	mov    $0x6,%eax
  800996:	e8 6b ff ff ff       	call   800906 <fsipc>
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	53                   	push   %ebx
  8009a1:	83 ec 04             	sub    $0x4,%esp
  8009a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ad:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009bc:	e8 45 ff ff ff       	call   800906 <fsipc>
  8009c1:	85 c0                	test   %eax,%eax
  8009c3:	78 2c                	js     8009f1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c5:	83 ec 08             	sub    $0x8,%esp
  8009c8:	68 00 50 80 00       	push   $0x805000
  8009cd:	53                   	push   %ebx
  8009ce:	e8 f5 0c 00 00       	call   8016c8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009de:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e9:	83 c4 10             	add    $0x10,%esp
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f4:	c9                   	leave  
  8009f5:	c3                   	ret    

008009f6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	53                   	push   %ebx
  8009fa:	83 ec 08             	sub    $0x8,%esp
  8009fd:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a00:	8b 55 08             	mov    0x8(%ebp),%edx
  800a03:	8b 52 0c             	mov    0xc(%edx),%edx
  800a06:	89 15 00 50 80 00    	mov    %edx,0x805000
  800a0c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a11:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a16:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  800a19:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  800a1f:	53                   	push   %ebx
  800a20:	ff 75 0c             	pushl  0xc(%ebp)
  800a23:	68 08 50 80 00       	push   $0x805008
  800a28:	e8 2d 0e 00 00       	call   80185a <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  800a2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a32:	b8 04 00 00 00       	mov    $0x4,%eax
  800a37:	e8 ca fe ff ff       	call   800906 <fsipc>
  800a3c:	83 c4 10             	add    $0x10,%esp
  800a3f:	85 c0                	test   %eax,%eax
  800a41:	78 1d                	js     800a60 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  800a43:	39 d8                	cmp    %ebx,%eax
  800a45:	76 19                	jbe    800a60 <devfile_write+0x6a>
  800a47:	68 a4 1e 80 00       	push   $0x801ea4
  800a4c:	68 b0 1e 80 00       	push   $0x801eb0
  800a51:	68 a5 00 00 00       	push   $0xa5
  800a56:	68 c5 1e 80 00       	push   $0x801ec5
  800a5b:	e8 0a 06 00 00       	call   80106a <_panic>
	return r;
}
  800a60:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a63:	c9                   	leave  
  800a64:	c3                   	ret    

00800a65 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
  800a6a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a70:	8b 40 0c             	mov    0xc(%eax),%eax
  800a73:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a78:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a83:	b8 03 00 00 00       	mov    $0x3,%eax
  800a88:	e8 79 fe ff ff       	call   800906 <fsipc>
  800a8d:	89 c3                	mov    %eax,%ebx
  800a8f:	85 c0                	test   %eax,%eax
  800a91:	78 4b                	js     800ade <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a93:	39 c6                	cmp    %eax,%esi
  800a95:	73 16                	jae    800aad <devfile_read+0x48>
  800a97:	68 d0 1e 80 00       	push   $0x801ed0
  800a9c:	68 b0 1e 80 00       	push   $0x801eb0
  800aa1:	6a 7c                	push   $0x7c
  800aa3:	68 c5 1e 80 00       	push   $0x801ec5
  800aa8:	e8 bd 05 00 00       	call   80106a <_panic>
	assert(r <= PGSIZE);
  800aad:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ab2:	7e 16                	jle    800aca <devfile_read+0x65>
  800ab4:	68 d7 1e 80 00       	push   $0x801ed7
  800ab9:	68 b0 1e 80 00       	push   $0x801eb0
  800abe:	6a 7d                	push   $0x7d
  800ac0:	68 c5 1e 80 00       	push   $0x801ec5
  800ac5:	e8 a0 05 00 00       	call   80106a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aca:	83 ec 04             	sub    $0x4,%esp
  800acd:	50                   	push   %eax
  800ace:	68 00 50 80 00       	push   $0x805000
  800ad3:	ff 75 0c             	pushl  0xc(%ebp)
  800ad6:	e8 7f 0d 00 00       	call   80185a <memmove>
	return r;
  800adb:	83 c4 10             	add    $0x10,%esp
}
  800ade:	89 d8                	mov    %ebx,%eax
  800ae0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae3:	5b                   	pop    %ebx
  800ae4:	5e                   	pop    %esi
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	53                   	push   %ebx
  800aeb:	83 ec 20             	sub    $0x20,%esp
  800aee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800af1:	53                   	push   %ebx
  800af2:	e8 98 0b 00 00       	call   80168f <strlen>
  800af7:	83 c4 10             	add    $0x10,%esp
  800afa:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aff:	7f 67                	jg     800b68 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b01:	83 ec 0c             	sub    $0xc,%esp
  800b04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b07:	50                   	push   %eax
  800b08:	e8 71 f8 ff ff       	call   80037e <fd_alloc>
  800b0d:	83 c4 10             	add    $0x10,%esp
		return r;
  800b10:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b12:	85 c0                	test   %eax,%eax
  800b14:	78 57                	js     800b6d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b16:	83 ec 08             	sub    $0x8,%esp
  800b19:	53                   	push   %ebx
  800b1a:	68 00 50 80 00       	push   $0x805000
  800b1f:	e8 a4 0b 00 00       	call   8016c8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b27:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b34:	e8 cd fd ff ff       	call   800906 <fsipc>
  800b39:	89 c3                	mov    %eax,%ebx
  800b3b:	83 c4 10             	add    $0x10,%esp
  800b3e:	85 c0                	test   %eax,%eax
  800b40:	79 14                	jns    800b56 <open+0x6f>
		fd_close(fd, 0);
  800b42:	83 ec 08             	sub    $0x8,%esp
  800b45:	6a 00                	push   $0x0
  800b47:	ff 75 f4             	pushl  -0xc(%ebp)
  800b4a:	e8 27 f9 ff ff       	call   800476 <fd_close>
		return r;
  800b4f:	83 c4 10             	add    $0x10,%esp
  800b52:	89 da                	mov    %ebx,%edx
  800b54:	eb 17                	jmp    800b6d <open+0x86>
	}

	return fd2num(fd);
  800b56:	83 ec 0c             	sub    $0xc,%esp
  800b59:	ff 75 f4             	pushl  -0xc(%ebp)
  800b5c:	e8 f6 f7 ff ff       	call   800357 <fd2num>
  800b61:	89 c2                	mov    %eax,%edx
  800b63:	83 c4 10             	add    $0x10,%esp
  800b66:	eb 05                	jmp    800b6d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b68:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b6d:	89 d0                	mov    %edx,%eax
  800b6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b72:	c9                   	leave  
  800b73:	c3                   	ret    

00800b74 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7f:	b8 08 00 00 00       	mov    $0x8,%eax
  800b84:	e8 7d fd ff ff       	call   800906 <fsipc>
}
  800b89:	c9                   	leave  
  800b8a:	c3                   	ret    

00800b8b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	56                   	push   %esi
  800b8f:	53                   	push   %ebx
  800b90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b93:	83 ec 0c             	sub    $0xc,%esp
  800b96:	ff 75 08             	pushl  0x8(%ebp)
  800b99:	e8 c9 f7 ff ff       	call   800367 <fd2data>
  800b9e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ba0:	83 c4 08             	add    $0x8,%esp
  800ba3:	68 e3 1e 80 00       	push   $0x801ee3
  800ba8:	53                   	push   %ebx
  800ba9:	e8 1a 0b 00 00       	call   8016c8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bae:	8b 46 04             	mov    0x4(%esi),%eax
  800bb1:	2b 06                	sub    (%esi),%eax
  800bb3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bb9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bc0:	00 00 00 
	stat->st_dev = &devpipe;
  800bc3:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bca:	30 80 00 
	return 0;
}
  800bcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	53                   	push   %ebx
  800bdd:	83 ec 0c             	sub    $0xc,%esp
  800be0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800be3:	53                   	push   %ebx
  800be4:	6a 00                	push   $0x0
  800be6:	e8 00 f6 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800beb:	89 1c 24             	mov    %ebx,(%esp)
  800bee:	e8 74 f7 ff ff       	call   800367 <fd2data>
  800bf3:	83 c4 08             	add    $0x8,%esp
  800bf6:	50                   	push   %eax
  800bf7:	6a 00                	push   $0x0
  800bf9:	e8 ed f5 ff ff       	call   8001eb <sys_page_unmap>
}
  800bfe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c01:	c9                   	leave  
  800c02:	c3                   	ret    

00800c03 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 1c             	sub    $0x1c,%esp
  800c0c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c0f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c11:	a1 04 40 80 00       	mov    0x804004,%eax
  800c16:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c19:	83 ec 0c             	sub    $0xc,%esp
  800c1c:	ff 75 e0             	pushl  -0x20(%ebp)
  800c1f:	e8 e1 0e 00 00       	call   801b05 <pageref>
  800c24:	89 c3                	mov    %eax,%ebx
  800c26:	89 3c 24             	mov    %edi,(%esp)
  800c29:	e8 d7 0e 00 00       	call   801b05 <pageref>
  800c2e:	83 c4 10             	add    $0x10,%esp
  800c31:	39 c3                	cmp    %eax,%ebx
  800c33:	0f 94 c1             	sete   %cl
  800c36:	0f b6 c9             	movzbl %cl,%ecx
  800c39:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c3c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c42:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c45:	39 ce                	cmp    %ecx,%esi
  800c47:	74 1b                	je     800c64 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c49:	39 c3                	cmp    %eax,%ebx
  800c4b:	75 c4                	jne    800c11 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c4d:	8b 42 58             	mov    0x58(%edx),%eax
  800c50:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c53:	50                   	push   %eax
  800c54:	56                   	push   %esi
  800c55:	68 ea 1e 80 00       	push   $0x801eea
  800c5a:	e8 e4 04 00 00       	call   801143 <cprintf>
  800c5f:	83 c4 10             	add    $0x10,%esp
  800c62:	eb ad                	jmp    800c11 <_pipeisclosed+0xe>
	}
}
  800c64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	57                   	push   %edi
  800c73:	56                   	push   %esi
  800c74:	53                   	push   %ebx
  800c75:	83 ec 28             	sub    $0x28,%esp
  800c78:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c7b:	56                   	push   %esi
  800c7c:	e8 e6 f6 ff ff       	call   800367 <fd2data>
  800c81:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c83:	83 c4 10             	add    $0x10,%esp
  800c86:	bf 00 00 00 00       	mov    $0x0,%edi
  800c8b:	eb 4b                	jmp    800cd8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c8d:	89 da                	mov    %ebx,%edx
  800c8f:	89 f0                	mov    %esi,%eax
  800c91:	e8 6d ff ff ff       	call   800c03 <_pipeisclosed>
  800c96:	85 c0                	test   %eax,%eax
  800c98:	75 48                	jne    800ce2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c9a:	e8 a8 f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c9f:	8b 43 04             	mov    0x4(%ebx),%eax
  800ca2:	8b 0b                	mov    (%ebx),%ecx
  800ca4:	8d 51 20             	lea    0x20(%ecx),%edx
  800ca7:	39 d0                	cmp    %edx,%eax
  800ca9:	73 e2                	jae    800c8d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cae:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cb2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cb5:	89 c2                	mov    %eax,%edx
  800cb7:	c1 fa 1f             	sar    $0x1f,%edx
  800cba:	89 d1                	mov    %edx,%ecx
  800cbc:	c1 e9 1b             	shr    $0x1b,%ecx
  800cbf:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cc2:	83 e2 1f             	and    $0x1f,%edx
  800cc5:	29 ca                	sub    %ecx,%edx
  800cc7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ccb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ccf:	83 c0 01             	add    $0x1,%eax
  800cd2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cd5:	83 c7 01             	add    $0x1,%edi
  800cd8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cdb:	75 c2                	jne    800c9f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cdd:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce0:	eb 05                	jmp    800ce7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ce2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800ce7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
  800cf5:	83 ec 18             	sub    $0x18,%esp
  800cf8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cfb:	57                   	push   %edi
  800cfc:	e8 66 f6 ff ff       	call   800367 <fd2data>
  800d01:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d03:	83 c4 10             	add    $0x10,%esp
  800d06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0b:	eb 3d                	jmp    800d4a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d0d:	85 db                	test   %ebx,%ebx
  800d0f:	74 04                	je     800d15 <devpipe_read+0x26>
				return i;
  800d11:	89 d8                	mov    %ebx,%eax
  800d13:	eb 44                	jmp    800d59 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d15:	89 f2                	mov    %esi,%edx
  800d17:	89 f8                	mov    %edi,%eax
  800d19:	e8 e5 fe ff ff       	call   800c03 <_pipeisclosed>
  800d1e:	85 c0                	test   %eax,%eax
  800d20:	75 32                	jne    800d54 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d22:	e8 20 f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d27:	8b 06                	mov    (%esi),%eax
  800d29:	3b 46 04             	cmp    0x4(%esi),%eax
  800d2c:	74 df                	je     800d0d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d2e:	99                   	cltd   
  800d2f:	c1 ea 1b             	shr    $0x1b,%edx
  800d32:	01 d0                	add    %edx,%eax
  800d34:	83 e0 1f             	and    $0x1f,%eax
  800d37:	29 d0                	sub    %edx,%eax
  800d39:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d41:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d44:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d47:	83 c3 01             	add    $0x1,%ebx
  800d4a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d4d:	75 d8                	jne    800d27 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d4f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d52:	eb 05                	jmp    800d59 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d54:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5c:	5b                   	pop    %ebx
  800d5d:	5e                   	pop    %esi
  800d5e:	5f                   	pop    %edi
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    

00800d61 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	56                   	push   %esi
  800d65:	53                   	push   %ebx
  800d66:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d6c:	50                   	push   %eax
  800d6d:	e8 0c f6 ff ff       	call   80037e <fd_alloc>
  800d72:	83 c4 10             	add    $0x10,%esp
  800d75:	89 c2                	mov    %eax,%edx
  800d77:	85 c0                	test   %eax,%eax
  800d79:	0f 88 2c 01 00 00    	js     800eab <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7f:	83 ec 04             	sub    $0x4,%esp
  800d82:	68 07 04 00 00       	push   $0x407
  800d87:	ff 75 f4             	pushl  -0xc(%ebp)
  800d8a:	6a 00                	push   $0x0
  800d8c:	e8 d5 f3 ff ff       	call   800166 <sys_page_alloc>
  800d91:	83 c4 10             	add    $0x10,%esp
  800d94:	89 c2                	mov    %eax,%edx
  800d96:	85 c0                	test   %eax,%eax
  800d98:	0f 88 0d 01 00 00    	js     800eab <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d9e:	83 ec 0c             	sub    $0xc,%esp
  800da1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800da4:	50                   	push   %eax
  800da5:	e8 d4 f5 ff ff       	call   80037e <fd_alloc>
  800daa:	89 c3                	mov    %eax,%ebx
  800dac:	83 c4 10             	add    $0x10,%esp
  800daf:	85 c0                	test   %eax,%eax
  800db1:	0f 88 e2 00 00 00    	js     800e99 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db7:	83 ec 04             	sub    $0x4,%esp
  800dba:	68 07 04 00 00       	push   $0x407
  800dbf:	ff 75 f0             	pushl  -0x10(%ebp)
  800dc2:	6a 00                	push   $0x0
  800dc4:	e8 9d f3 ff ff       	call   800166 <sys_page_alloc>
  800dc9:	89 c3                	mov    %eax,%ebx
  800dcb:	83 c4 10             	add    $0x10,%esp
  800dce:	85 c0                	test   %eax,%eax
  800dd0:	0f 88 c3 00 00 00    	js     800e99 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dd6:	83 ec 0c             	sub    $0xc,%esp
  800dd9:	ff 75 f4             	pushl  -0xc(%ebp)
  800ddc:	e8 86 f5 ff ff       	call   800367 <fd2data>
  800de1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de3:	83 c4 0c             	add    $0xc,%esp
  800de6:	68 07 04 00 00       	push   $0x407
  800deb:	50                   	push   %eax
  800dec:	6a 00                	push   $0x0
  800dee:	e8 73 f3 ff ff       	call   800166 <sys_page_alloc>
  800df3:	89 c3                	mov    %eax,%ebx
  800df5:	83 c4 10             	add    $0x10,%esp
  800df8:	85 c0                	test   %eax,%eax
  800dfa:	0f 88 89 00 00 00    	js     800e89 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e00:	83 ec 0c             	sub    $0xc,%esp
  800e03:	ff 75 f0             	pushl  -0x10(%ebp)
  800e06:	e8 5c f5 ff ff       	call   800367 <fd2data>
  800e0b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e12:	50                   	push   %eax
  800e13:	6a 00                	push   $0x0
  800e15:	56                   	push   %esi
  800e16:	6a 00                	push   $0x0
  800e18:	e8 8c f3 ff ff       	call   8001a9 <sys_page_map>
  800e1d:	89 c3                	mov    %eax,%ebx
  800e1f:	83 c4 20             	add    $0x20,%esp
  800e22:	85 c0                	test   %eax,%eax
  800e24:	78 55                	js     800e7b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e26:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e2f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e34:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e3b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e44:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e46:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e49:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e50:	83 ec 0c             	sub    $0xc,%esp
  800e53:	ff 75 f4             	pushl  -0xc(%ebp)
  800e56:	e8 fc f4 ff ff       	call   800357 <fd2num>
  800e5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e60:	83 c4 04             	add    $0x4,%esp
  800e63:	ff 75 f0             	pushl  -0x10(%ebp)
  800e66:	e8 ec f4 ff ff       	call   800357 <fd2num>
  800e6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e71:	83 c4 10             	add    $0x10,%esp
  800e74:	ba 00 00 00 00       	mov    $0x0,%edx
  800e79:	eb 30                	jmp    800eab <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e7b:	83 ec 08             	sub    $0x8,%esp
  800e7e:	56                   	push   %esi
  800e7f:	6a 00                	push   $0x0
  800e81:	e8 65 f3 ff ff       	call   8001eb <sys_page_unmap>
  800e86:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e89:	83 ec 08             	sub    $0x8,%esp
  800e8c:	ff 75 f0             	pushl  -0x10(%ebp)
  800e8f:	6a 00                	push   $0x0
  800e91:	e8 55 f3 ff ff       	call   8001eb <sys_page_unmap>
  800e96:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e99:	83 ec 08             	sub    $0x8,%esp
  800e9c:	ff 75 f4             	pushl  -0xc(%ebp)
  800e9f:	6a 00                	push   $0x0
  800ea1:	e8 45 f3 ff ff       	call   8001eb <sys_page_unmap>
  800ea6:	83 c4 10             	add    $0x10,%esp
  800ea9:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800eab:	89 d0                	mov    %edx,%eax
  800ead:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eb0:	5b                   	pop    %ebx
  800eb1:	5e                   	pop    %esi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ebd:	50                   	push   %eax
  800ebe:	ff 75 08             	pushl  0x8(%ebp)
  800ec1:	e8 07 f5 ff ff       	call   8003cd <fd_lookup>
  800ec6:	83 c4 10             	add    $0x10,%esp
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	78 18                	js     800ee5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ecd:	83 ec 0c             	sub    $0xc,%esp
  800ed0:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed3:	e8 8f f4 ff ff       	call   800367 <fd2data>
	return _pipeisclosed(fd, p);
  800ed8:	89 c2                	mov    %eax,%edx
  800eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800edd:	e8 21 fd ff ff       	call   800c03 <_pipeisclosed>
  800ee2:	83 c4 10             	add    $0x10,%esp
}
  800ee5:	c9                   	leave  
  800ee6:	c3                   	ret    

00800ee7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eea:	b8 00 00 00 00       	mov    $0x0,%eax
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ef7:	68 02 1f 80 00       	push   $0x801f02
  800efc:	ff 75 0c             	pushl  0xc(%ebp)
  800eff:	e8 c4 07 00 00       	call   8016c8 <strcpy>
	return 0;
}
  800f04:	b8 00 00 00 00       	mov    $0x0,%eax
  800f09:	c9                   	leave  
  800f0a:	c3                   	ret    

00800f0b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	57                   	push   %edi
  800f0f:	56                   	push   %esi
  800f10:	53                   	push   %ebx
  800f11:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f17:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f1c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f22:	eb 2d                	jmp    800f51 <devcons_write+0x46>
		m = n - tot;
  800f24:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f27:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f29:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f2c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f31:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f34:	83 ec 04             	sub    $0x4,%esp
  800f37:	53                   	push   %ebx
  800f38:	03 45 0c             	add    0xc(%ebp),%eax
  800f3b:	50                   	push   %eax
  800f3c:	57                   	push   %edi
  800f3d:	e8 18 09 00 00       	call   80185a <memmove>
		sys_cputs(buf, m);
  800f42:	83 c4 08             	add    $0x8,%esp
  800f45:	53                   	push   %ebx
  800f46:	57                   	push   %edi
  800f47:	e8 5e f1 ff ff       	call   8000aa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f4c:	01 de                	add    %ebx,%esi
  800f4e:	83 c4 10             	add    $0x10,%esp
  800f51:	89 f0                	mov    %esi,%eax
  800f53:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f56:	72 cc                	jb     800f24 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f5b:	5b                   	pop    %ebx
  800f5c:	5e                   	pop    %esi
  800f5d:	5f                   	pop    %edi
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    

00800f60 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	83 ec 08             	sub    $0x8,%esp
  800f66:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f6b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f6f:	74 2a                	je     800f9b <devcons_read+0x3b>
  800f71:	eb 05                	jmp    800f78 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f73:	e8 cf f1 ff ff       	call   800147 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f78:	e8 4b f1 ff ff       	call   8000c8 <sys_cgetc>
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	74 f2                	je     800f73 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f81:	85 c0                	test   %eax,%eax
  800f83:	78 16                	js     800f9b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f85:	83 f8 04             	cmp    $0x4,%eax
  800f88:	74 0c                	je     800f96 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8d:	88 02                	mov    %al,(%edx)
	return 1;
  800f8f:	b8 01 00 00 00       	mov    $0x1,%eax
  800f94:	eb 05                	jmp    800f9b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f96:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f9b:	c9                   	leave  
  800f9c:	c3                   	ret    

00800f9d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fa3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa6:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fa9:	6a 01                	push   $0x1
  800fab:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fae:	50                   	push   %eax
  800faf:	e8 f6 f0 ff ff       	call   8000aa <sys_cputs>
}
  800fb4:	83 c4 10             	add    $0x10,%esp
  800fb7:	c9                   	leave  
  800fb8:	c3                   	ret    

00800fb9 <getchar>:

int
getchar(void)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fbf:	6a 01                	push   $0x1
  800fc1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fc4:	50                   	push   %eax
  800fc5:	6a 00                	push   $0x0
  800fc7:	e8 67 f6 ff ff       	call   800633 <read>
	if (r < 0)
  800fcc:	83 c4 10             	add    $0x10,%esp
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	78 0f                	js     800fe2 <getchar+0x29>
		return r;
	if (r < 1)
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	7e 06                	jle    800fdd <getchar+0x24>
		return -E_EOF;
	return c;
  800fd7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fdb:	eb 05                	jmp    800fe2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fdd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fe2:	c9                   	leave  
  800fe3:	c3                   	ret    

00800fe4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fed:	50                   	push   %eax
  800fee:	ff 75 08             	pushl  0x8(%ebp)
  800ff1:	e8 d7 f3 ff ff       	call   8003cd <fd_lookup>
  800ff6:	83 c4 10             	add    $0x10,%esp
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	78 11                	js     80100e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801000:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801006:	39 10                	cmp    %edx,(%eax)
  801008:	0f 94 c0             	sete   %al
  80100b:	0f b6 c0             	movzbl %al,%eax
}
  80100e:	c9                   	leave  
  80100f:	c3                   	ret    

00801010 <opencons>:

int
opencons(void)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801016:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801019:	50                   	push   %eax
  80101a:	e8 5f f3 ff ff       	call   80037e <fd_alloc>
  80101f:	83 c4 10             	add    $0x10,%esp
		return r;
  801022:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801024:	85 c0                	test   %eax,%eax
  801026:	78 3e                	js     801066 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801028:	83 ec 04             	sub    $0x4,%esp
  80102b:	68 07 04 00 00       	push   $0x407
  801030:	ff 75 f4             	pushl  -0xc(%ebp)
  801033:	6a 00                	push   $0x0
  801035:	e8 2c f1 ff ff       	call   800166 <sys_page_alloc>
  80103a:	83 c4 10             	add    $0x10,%esp
		return r;
  80103d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80103f:	85 c0                	test   %eax,%eax
  801041:	78 23                	js     801066 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801043:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801049:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80104c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80104e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801051:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801058:	83 ec 0c             	sub    $0xc,%esp
  80105b:	50                   	push   %eax
  80105c:	e8 f6 f2 ff ff       	call   800357 <fd2num>
  801061:	89 c2                	mov    %eax,%edx
  801063:	83 c4 10             	add    $0x10,%esp
}
  801066:	89 d0                	mov    %edx,%eax
  801068:	c9                   	leave  
  801069:	c3                   	ret    

0080106a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	56                   	push   %esi
  80106e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80106f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801072:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801078:	e8 ab f0 ff ff       	call   800128 <sys_getenvid>
  80107d:	83 ec 0c             	sub    $0xc,%esp
  801080:	ff 75 0c             	pushl  0xc(%ebp)
  801083:	ff 75 08             	pushl  0x8(%ebp)
  801086:	56                   	push   %esi
  801087:	50                   	push   %eax
  801088:	68 10 1f 80 00       	push   $0x801f10
  80108d:	e8 b1 00 00 00       	call   801143 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801092:	83 c4 18             	add    $0x18,%esp
  801095:	53                   	push   %ebx
  801096:	ff 75 10             	pushl  0x10(%ebp)
  801099:	e8 54 00 00 00       	call   8010f2 <vcprintf>
	cprintf("\n");
  80109e:	c7 04 24 fb 1e 80 00 	movl   $0x801efb,(%esp)
  8010a5:	e8 99 00 00 00       	call   801143 <cprintf>
  8010aa:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010ad:	cc                   	int3   
  8010ae:	eb fd                	jmp    8010ad <_panic+0x43>

008010b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	53                   	push   %ebx
  8010b4:	83 ec 04             	sub    $0x4,%esp
  8010b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010ba:	8b 13                	mov    (%ebx),%edx
  8010bc:	8d 42 01             	lea    0x1(%edx),%eax
  8010bf:	89 03                	mov    %eax,(%ebx)
  8010c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010c4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010c8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010cd:	75 1a                	jne    8010e9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010cf:	83 ec 08             	sub    $0x8,%esp
  8010d2:	68 ff 00 00 00       	push   $0xff
  8010d7:	8d 43 08             	lea    0x8(%ebx),%eax
  8010da:	50                   	push   %eax
  8010db:	e8 ca ef ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  8010e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010e6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010e9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010f0:	c9                   	leave  
  8010f1:	c3                   	ret    

008010f2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010fb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801102:	00 00 00 
	b.cnt = 0;
  801105:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80110c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80110f:	ff 75 0c             	pushl  0xc(%ebp)
  801112:	ff 75 08             	pushl  0x8(%ebp)
  801115:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80111b:	50                   	push   %eax
  80111c:	68 b0 10 80 00       	push   $0x8010b0
  801121:	e8 54 01 00 00       	call   80127a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801126:	83 c4 08             	add    $0x8,%esp
  801129:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80112f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801135:	50                   	push   %eax
  801136:	e8 6f ef ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  80113b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801141:	c9                   	leave  
  801142:	c3                   	ret    

00801143 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801149:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80114c:	50                   	push   %eax
  80114d:	ff 75 08             	pushl  0x8(%ebp)
  801150:	e8 9d ff ff ff       	call   8010f2 <vcprintf>
	va_end(ap);

	return cnt;
}
  801155:	c9                   	leave  
  801156:	c3                   	ret    

00801157 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	57                   	push   %edi
  80115b:	56                   	push   %esi
  80115c:	53                   	push   %ebx
  80115d:	83 ec 1c             	sub    $0x1c,%esp
  801160:	89 c7                	mov    %eax,%edi
  801162:	89 d6                	mov    %edx,%esi
  801164:	8b 45 08             	mov    0x8(%ebp),%eax
  801167:	8b 55 0c             	mov    0xc(%ebp),%edx
  80116a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80116d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801170:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801173:	bb 00 00 00 00       	mov    $0x0,%ebx
  801178:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80117b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80117e:	39 d3                	cmp    %edx,%ebx
  801180:	72 05                	jb     801187 <printnum+0x30>
  801182:	39 45 10             	cmp    %eax,0x10(%ebp)
  801185:	77 45                	ja     8011cc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801187:	83 ec 0c             	sub    $0xc,%esp
  80118a:	ff 75 18             	pushl  0x18(%ebp)
  80118d:	8b 45 14             	mov    0x14(%ebp),%eax
  801190:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801193:	53                   	push   %ebx
  801194:	ff 75 10             	pushl  0x10(%ebp)
  801197:	83 ec 08             	sub    $0x8,%esp
  80119a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80119d:	ff 75 e0             	pushl  -0x20(%ebp)
  8011a0:	ff 75 dc             	pushl  -0x24(%ebp)
  8011a3:	ff 75 d8             	pushl  -0x28(%ebp)
  8011a6:	e8 95 09 00 00       	call   801b40 <__udivdi3>
  8011ab:	83 c4 18             	add    $0x18,%esp
  8011ae:	52                   	push   %edx
  8011af:	50                   	push   %eax
  8011b0:	89 f2                	mov    %esi,%edx
  8011b2:	89 f8                	mov    %edi,%eax
  8011b4:	e8 9e ff ff ff       	call   801157 <printnum>
  8011b9:	83 c4 20             	add    $0x20,%esp
  8011bc:	eb 18                	jmp    8011d6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011be:	83 ec 08             	sub    $0x8,%esp
  8011c1:	56                   	push   %esi
  8011c2:	ff 75 18             	pushl  0x18(%ebp)
  8011c5:	ff d7                	call   *%edi
  8011c7:	83 c4 10             	add    $0x10,%esp
  8011ca:	eb 03                	jmp    8011cf <printnum+0x78>
  8011cc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011cf:	83 eb 01             	sub    $0x1,%ebx
  8011d2:	85 db                	test   %ebx,%ebx
  8011d4:	7f e8                	jg     8011be <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011d6:	83 ec 08             	sub    $0x8,%esp
  8011d9:	56                   	push   %esi
  8011da:	83 ec 04             	sub    $0x4,%esp
  8011dd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8011e3:	ff 75 dc             	pushl  -0x24(%ebp)
  8011e6:	ff 75 d8             	pushl  -0x28(%ebp)
  8011e9:	e8 82 0a 00 00       	call   801c70 <__umoddi3>
  8011ee:	83 c4 14             	add    $0x14,%esp
  8011f1:	0f be 80 33 1f 80 00 	movsbl 0x801f33(%eax),%eax
  8011f8:	50                   	push   %eax
  8011f9:	ff d7                	call   *%edi
}
  8011fb:	83 c4 10             	add    $0x10,%esp
  8011fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801201:	5b                   	pop    %ebx
  801202:	5e                   	pop    %esi
  801203:	5f                   	pop    %edi
  801204:	5d                   	pop    %ebp
  801205:	c3                   	ret    

00801206 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801209:	83 fa 01             	cmp    $0x1,%edx
  80120c:	7e 0e                	jle    80121c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80120e:	8b 10                	mov    (%eax),%edx
  801210:	8d 4a 08             	lea    0x8(%edx),%ecx
  801213:	89 08                	mov    %ecx,(%eax)
  801215:	8b 02                	mov    (%edx),%eax
  801217:	8b 52 04             	mov    0x4(%edx),%edx
  80121a:	eb 22                	jmp    80123e <getuint+0x38>
	else if (lflag)
  80121c:	85 d2                	test   %edx,%edx
  80121e:	74 10                	je     801230 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801220:	8b 10                	mov    (%eax),%edx
  801222:	8d 4a 04             	lea    0x4(%edx),%ecx
  801225:	89 08                	mov    %ecx,(%eax)
  801227:	8b 02                	mov    (%edx),%eax
  801229:	ba 00 00 00 00       	mov    $0x0,%edx
  80122e:	eb 0e                	jmp    80123e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801230:	8b 10                	mov    (%eax),%edx
  801232:	8d 4a 04             	lea    0x4(%edx),%ecx
  801235:	89 08                	mov    %ecx,(%eax)
  801237:	8b 02                	mov    (%edx),%eax
  801239:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80123e:	5d                   	pop    %ebp
  80123f:	c3                   	ret    

00801240 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801246:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80124a:	8b 10                	mov    (%eax),%edx
  80124c:	3b 50 04             	cmp    0x4(%eax),%edx
  80124f:	73 0a                	jae    80125b <sprintputch+0x1b>
		*b->buf++ = ch;
  801251:	8d 4a 01             	lea    0x1(%edx),%ecx
  801254:	89 08                	mov    %ecx,(%eax)
  801256:	8b 45 08             	mov    0x8(%ebp),%eax
  801259:	88 02                	mov    %al,(%edx)
}
  80125b:	5d                   	pop    %ebp
  80125c:	c3                   	ret    

0080125d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801263:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801266:	50                   	push   %eax
  801267:	ff 75 10             	pushl  0x10(%ebp)
  80126a:	ff 75 0c             	pushl  0xc(%ebp)
  80126d:	ff 75 08             	pushl  0x8(%ebp)
  801270:	e8 05 00 00 00       	call   80127a <vprintfmt>
	va_end(ap);
}
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	c9                   	leave  
  801279:	c3                   	ret    

0080127a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	57                   	push   %edi
  80127e:	56                   	push   %esi
  80127f:	53                   	push   %ebx
  801280:	83 ec 2c             	sub    $0x2c,%esp
  801283:	8b 75 08             	mov    0x8(%ebp),%esi
  801286:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801289:	8b 7d 10             	mov    0x10(%ebp),%edi
  80128c:	eb 12                	jmp    8012a0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80128e:	85 c0                	test   %eax,%eax
  801290:	0f 84 89 03 00 00    	je     80161f <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801296:	83 ec 08             	sub    $0x8,%esp
  801299:	53                   	push   %ebx
  80129a:	50                   	push   %eax
  80129b:	ff d6                	call   *%esi
  80129d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012a0:	83 c7 01             	add    $0x1,%edi
  8012a3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012a7:	83 f8 25             	cmp    $0x25,%eax
  8012aa:	75 e2                	jne    80128e <vprintfmt+0x14>
  8012ac:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012b0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012b7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012be:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ca:	eb 07                	jmp    8012d3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012cf:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d3:	8d 47 01             	lea    0x1(%edi),%eax
  8012d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012d9:	0f b6 07             	movzbl (%edi),%eax
  8012dc:	0f b6 c8             	movzbl %al,%ecx
  8012df:	83 e8 23             	sub    $0x23,%eax
  8012e2:	3c 55                	cmp    $0x55,%al
  8012e4:	0f 87 1a 03 00 00    	ja     801604 <vprintfmt+0x38a>
  8012ea:	0f b6 c0             	movzbl %al,%eax
  8012ed:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  8012f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012f7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012fb:	eb d6                	jmp    8012d3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801300:	b8 00 00 00 00       	mov    $0x0,%eax
  801305:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801308:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80130b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80130f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801312:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801315:	83 fa 09             	cmp    $0x9,%edx
  801318:	77 39                	ja     801353 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80131a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80131d:	eb e9                	jmp    801308 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80131f:	8b 45 14             	mov    0x14(%ebp),%eax
  801322:	8d 48 04             	lea    0x4(%eax),%ecx
  801325:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801328:	8b 00                	mov    (%eax),%eax
  80132a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80132d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801330:	eb 27                	jmp    801359 <vprintfmt+0xdf>
  801332:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801335:	85 c0                	test   %eax,%eax
  801337:	b9 00 00 00 00       	mov    $0x0,%ecx
  80133c:	0f 49 c8             	cmovns %eax,%ecx
  80133f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801342:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801345:	eb 8c                	jmp    8012d3 <vprintfmt+0x59>
  801347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80134a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801351:	eb 80                	jmp    8012d3 <vprintfmt+0x59>
  801353:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801356:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801359:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80135d:	0f 89 70 ff ff ff    	jns    8012d3 <vprintfmt+0x59>
				width = precision, precision = -1;
  801363:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801366:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801369:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801370:	e9 5e ff ff ff       	jmp    8012d3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801375:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801378:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80137b:	e9 53 ff ff ff       	jmp    8012d3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801380:	8b 45 14             	mov    0x14(%ebp),%eax
  801383:	8d 50 04             	lea    0x4(%eax),%edx
  801386:	89 55 14             	mov    %edx,0x14(%ebp)
  801389:	83 ec 08             	sub    $0x8,%esp
  80138c:	53                   	push   %ebx
  80138d:	ff 30                	pushl  (%eax)
  80138f:	ff d6                	call   *%esi
			break;
  801391:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801394:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801397:	e9 04 ff ff ff       	jmp    8012a0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80139c:	8b 45 14             	mov    0x14(%ebp),%eax
  80139f:	8d 50 04             	lea    0x4(%eax),%edx
  8013a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8013a5:	8b 00                	mov    (%eax),%eax
  8013a7:	99                   	cltd   
  8013a8:	31 d0                	xor    %edx,%eax
  8013aa:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013ac:	83 f8 0f             	cmp    $0xf,%eax
  8013af:	7f 0b                	jg     8013bc <vprintfmt+0x142>
  8013b1:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  8013b8:	85 d2                	test   %edx,%edx
  8013ba:	75 18                	jne    8013d4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013bc:	50                   	push   %eax
  8013bd:	68 4b 1f 80 00       	push   $0x801f4b
  8013c2:	53                   	push   %ebx
  8013c3:	56                   	push   %esi
  8013c4:	e8 94 fe ff ff       	call   80125d <printfmt>
  8013c9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013cf:	e9 cc fe ff ff       	jmp    8012a0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013d4:	52                   	push   %edx
  8013d5:	68 c2 1e 80 00       	push   $0x801ec2
  8013da:	53                   	push   %ebx
  8013db:	56                   	push   %esi
  8013dc:	e8 7c fe ff ff       	call   80125d <printfmt>
  8013e1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013e7:	e9 b4 fe ff ff       	jmp    8012a0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ef:	8d 50 04             	lea    0x4(%eax),%edx
  8013f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8013f5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013f7:	85 ff                	test   %edi,%edi
  8013f9:	b8 44 1f 80 00       	mov    $0x801f44,%eax
  8013fe:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801401:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801405:	0f 8e 94 00 00 00    	jle    80149f <vprintfmt+0x225>
  80140b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80140f:	0f 84 98 00 00 00    	je     8014ad <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801415:	83 ec 08             	sub    $0x8,%esp
  801418:	ff 75 d0             	pushl  -0x30(%ebp)
  80141b:	57                   	push   %edi
  80141c:	e8 86 02 00 00       	call   8016a7 <strnlen>
  801421:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801424:	29 c1                	sub    %eax,%ecx
  801426:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801429:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80142c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801430:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801433:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801436:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801438:	eb 0f                	jmp    801449 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80143a:	83 ec 08             	sub    $0x8,%esp
  80143d:	53                   	push   %ebx
  80143e:	ff 75 e0             	pushl  -0x20(%ebp)
  801441:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801443:	83 ef 01             	sub    $0x1,%edi
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	85 ff                	test   %edi,%edi
  80144b:	7f ed                	jg     80143a <vprintfmt+0x1c0>
  80144d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801450:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801453:	85 c9                	test   %ecx,%ecx
  801455:	b8 00 00 00 00       	mov    $0x0,%eax
  80145a:	0f 49 c1             	cmovns %ecx,%eax
  80145d:	29 c1                	sub    %eax,%ecx
  80145f:	89 75 08             	mov    %esi,0x8(%ebp)
  801462:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801465:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801468:	89 cb                	mov    %ecx,%ebx
  80146a:	eb 4d                	jmp    8014b9 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80146c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801470:	74 1b                	je     80148d <vprintfmt+0x213>
  801472:	0f be c0             	movsbl %al,%eax
  801475:	83 e8 20             	sub    $0x20,%eax
  801478:	83 f8 5e             	cmp    $0x5e,%eax
  80147b:	76 10                	jbe    80148d <vprintfmt+0x213>
					putch('?', putdat);
  80147d:	83 ec 08             	sub    $0x8,%esp
  801480:	ff 75 0c             	pushl  0xc(%ebp)
  801483:	6a 3f                	push   $0x3f
  801485:	ff 55 08             	call   *0x8(%ebp)
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	eb 0d                	jmp    80149a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80148d:	83 ec 08             	sub    $0x8,%esp
  801490:	ff 75 0c             	pushl  0xc(%ebp)
  801493:	52                   	push   %edx
  801494:	ff 55 08             	call   *0x8(%ebp)
  801497:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80149a:	83 eb 01             	sub    $0x1,%ebx
  80149d:	eb 1a                	jmp    8014b9 <vprintfmt+0x23f>
  80149f:	89 75 08             	mov    %esi,0x8(%ebp)
  8014a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014a8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014ab:	eb 0c                	jmp    8014b9 <vprintfmt+0x23f>
  8014ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8014b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014b6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014b9:	83 c7 01             	add    $0x1,%edi
  8014bc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014c0:	0f be d0             	movsbl %al,%edx
  8014c3:	85 d2                	test   %edx,%edx
  8014c5:	74 23                	je     8014ea <vprintfmt+0x270>
  8014c7:	85 f6                	test   %esi,%esi
  8014c9:	78 a1                	js     80146c <vprintfmt+0x1f2>
  8014cb:	83 ee 01             	sub    $0x1,%esi
  8014ce:	79 9c                	jns    80146c <vprintfmt+0x1f2>
  8014d0:	89 df                	mov    %ebx,%edi
  8014d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8014d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014d8:	eb 18                	jmp    8014f2 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014da:	83 ec 08             	sub    $0x8,%esp
  8014dd:	53                   	push   %ebx
  8014de:	6a 20                	push   $0x20
  8014e0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014e2:	83 ef 01             	sub    $0x1,%edi
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	eb 08                	jmp    8014f2 <vprintfmt+0x278>
  8014ea:	89 df                	mov    %ebx,%edi
  8014ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014f2:	85 ff                	test   %edi,%edi
  8014f4:	7f e4                	jg     8014da <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014f9:	e9 a2 fd ff ff       	jmp    8012a0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014fe:	83 fa 01             	cmp    $0x1,%edx
  801501:	7e 16                	jle    801519 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801503:	8b 45 14             	mov    0x14(%ebp),%eax
  801506:	8d 50 08             	lea    0x8(%eax),%edx
  801509:	89 55 14             	mov    %edx,0x14(%ebp)
  80150c:	8b 50 04             	mov    0x4(%eax),%edx
  80150f:	8b 00                	mov    (%eax),%eax
  801511:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801514:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801517:	eb 32                	jmp    80154b <vprintfmt+0x2d1>
	else if (lflag)
  801519:	85 d2                	test   %edx,%edx
  80151b:	74 18                	je     801535 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80151d:	8b 45 14             	mov    0x14(%ebp),%eax
  801520:	8d 50 04             	lea    0x4(%eax),%edx
  801523:	89 55 14             	mov    %edx,0x14(%ebp)
  801526:	8b 00                	mov    (%eax),%eax
  801528:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80152b:	89 c1                	mov    %eax,%ecx
  80152d:	c1 f9 1f             	sar    $0x1f,%ecx
  801530:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801533:	eb 16                	jmp    80154b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801535:	8b 45 14             	mov    0x14(%ebp),%eax
  801538:	8d 50 04             	lea    0x4(%eax),%edx
  80153b:	89 55 14             	mov    %edx,0x14(%ebp)
  80153e:	8b 00                	mov    (%eax),%eax
  801540:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801543:	89 c1                	mov    %eax,%ecx
  801545:	c1 f9 1f             	sar    $0x1f,%ecx
  801548:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80154b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80154e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801551:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801556:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80155a:	79 74                	jns    8015d0 <vprintfmt+0x356>
				putch('-', putdat);
  80155c:	83 ec 08             	sub    $0x8,%esp
  80155f:	53                   	push   %ebx
  801560:	6a 2d                	push   $0x2d
  801562:	ff d6                	call   *%esi
				num = -(long long) num;
  801564:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801567:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80156a:	f7 d8                	neg    %eax
  80156c:	83 d2 00             	adc    $0x0,%edx
  80156f:	f7 da                	neg    %edx
  801571:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801574:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801579:	eb 55                	jmp    8015d0 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80157b:	8d 45 14             	lea    0x14(%ebp),%eax
  80157e:	e8 83 fc ff ff       	call   801206 <getuint>
			base = 10;
  801583:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801588:	eb 46                	jmp    8015d0 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80158a:	8d 45 14             	lea    0x14(%ebp),%eax
  80158d:	e8 74 fc ff ff       	call   801206 <getuint>
                        base = 8;
  801592:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801597:	eb 37                	jmp    8015d0 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801599:	83 ec 08             	sub    $0x8,%esp
  80159c:	53                   	push   %ebx
  80159d:	6a 30                	push   $0x30
  80159f:	ff d6                	call   *%esi
			putch('x', putdat);
  8015a1:	83 c4 08             	add    $0x8,%esp
  8015a4:	53                   	push   %ebx
  8015a5:	6a 78                	push   $0x78
  8015a7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ac:	8d 50 04             	lea    0x4(%eax),%edx
  8015af:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015b2:	8b 00                	mov    (%eax),%eax
  8015b4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015b9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015bc:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015c1:	eb 0d                	jmp    8015d0 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8015c6:	e8 3b fc ff ff       	call   801206 <getuint>
			base = 16;
  8015cb:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015d0:	83 ec 0c             	sub    $0xc,%esp
  8015d3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015d7:	57                   	push   %edi
  8015d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8015db:	51                   	push   %ecx
  8015dc:	52                   	push   %edx
  8015dd:	50                   	push   %eax
  8015de:	89 da                	mov    %ebx,%edx
  8015e0:	89 f0                	mov    %esi,%eax
  8015e2:	e8 70 fb ff ff       	call   801157 <printnum>
			break;
  8015e7:	83 c4 20             	add    $0x20,%esp
  8015ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015ed:	e9 ae fc ff ff       	jmp    8012a0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015f2:	83 ec 08             	sub    $0x8,%esp
  8015f5:	53                   	push   %ebx
  8015f6:	51                   	push   %ecx
  8015f7:	ff d6                	call   *%esi
			break;
  8015f9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015ff:	e9 9c fc ff ff       	jmp    8012a0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801604:	83 ec 08             	sub    $0x8,%esp
  801607:	53                   	push   %ebx
  801608:	6a 25                	push   $0x25
  80160a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	eb 03                	jmp    801614 <vprintfmt+0x39a>
  801611:	83 ef 01             	sub    $0x1,%edi
  801614:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801618:	75 f7                	jne    801611 <vprintfmt+0x397>
  80161a:	e9 81 fc ff ff       	jmp    8012a0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80161f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801622:	5b                   	pop    %ebx
  801623:	5e                   	pop    %esi
  801624:	5f                   	pop    %edi
  801625:	5d                   	pop    %ebp
  801626:	c3                   	ret    

00801627 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	83 ec 18             	sub    $0x18,%esp
  80162d:	8b 45 08             	mov    0x8(%ebp),%eax
  801630:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801633:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801636:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80163a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80163d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801644:	85 c0                	test   %eax,%eax
  801646:	74 26                	je     80166e <vsnprintf+0x47>
  801648:	85 d2                	test   %edx,%edx
  80164a:	7e 22                	jle    80166e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80164c:	ff 75 14             	pushl  0x14(%ebp)
  80164f:	ff 75 10             	pushl  0x10(%ebp)
  801652:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801655:	50                   	push   %eax
  801656:	68 40 12 80 00       	push   $0x801240
  80165b:	e8 1a fc ff ff       	call   80127a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801660:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801663:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801666:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801669:	83 c4 10             	add    $0x10,%esp
  80166c:	eb 05                	jmp    801673 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80166e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801673:	c9                   	leave  
  801674:	c3                   	ret    

00801675 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80167b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80167e:	50                   	push   %eax
  80167f:	ff 75 10             	pushl  0x10(%ebp)
  801682:	ff 75 0c             	pushl  0xc(%ebp)
  801685:	ff 75 08             	pushl  0x8(%ebp)
  801688:	e8 9a ff ff ff       	call   801627 <vsnprintf>
	va_end(ap);

	return rc;
}
  80168d:	c9                   	leave  
  80168e:	c3                   	ret    

0080168f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801695:	b8 00 00 00 00       	mov    $0x0,%eax
  80169a:	eb 03                	jmp    80169f <strlen+0x10>
		n++;
  80169c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80169f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016a3:	75 f7                	jne    80169c <strlen+0xd>
		n++;
	return n;
}
  8016a5:	5d                   	pop    %ebp
  8016a6:	c3                   	ret    

008016a7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ad:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b5:	eb 03                	jmp    8016ba <strnlen+0x13>
		n++;
  8016b7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016ba:	39 c2                	cmp    %eax,%edx
  8016bc:	74 08                	je     8016c6 <strnlen+0x1f>
  8016be:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016c2:	75 f3                	jne    8016b7 <strnlen+0x10>
  8016c4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016c6:	5d                   	pop    %ebp
  8016c7:	c3                   	ret    

008016c8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	53                   	push   %ebx
  8016cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016d2:	89 c2                	mov    %eax,%edx
  8016d4:	83 c2 01             	add    $0x1,%edx
  8016d7:	83 c1 01             	add    $0x1,%ecx
  8016da:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016de:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016e1:	84 db                	test   %bl,%bl
  8016e3:	75 ef                	jne    8016d4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016e5:	5b                   	pop    %ebx
  8016e6:	5d                   	pop    %ebp
  8016e7:	c3                   	ret    

008016e8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	53                   	push   %ebx
  8016ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016ef:	53                   	push   %ebx
  8016f0:	e8 9a ff ff ff       	call   80168f <strlen>
  8016f5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016f8:	ff 75 0c             	pushl  0xc(%ebp)
  8016fb:	01 d8                	add    %ebx,%eax
  8016fd:	50                   	push   %eax
  8016fe:	e8 c5 ff ff ff       	call   8016c8 <strcpy>
	return dst;
}
  801703:	89 d8                	mov    %ebx,%eax
  801705:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801708:	c9                   	leave  
  801709:	c3                   	ret    

0080170a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	56                   	push   %esi
  80170e:	53                   	push   %ebx
  80170f:	8b 75 08             	mov    0x8(%ebp),%esi
  801712:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801715:	89 f3                	mov    %esi,%ebx
  801717:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80171a:	89 f2                	mov    %esi,%edx
  80171c:	eb 0f                	jmp    80172d <strncpy+0x23>
		*dst++ = *src;
  80171e:	83 c2 01             	add    $0x1,%edx
  801721:	0f b6 01             	movzbl (%ecx),%eax
  801724:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801727:	80 39 01             	cmpb   $0x1,(%ecx)
  80172a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80172d:	39 da                	cmp    %ebx,%edx
  80172f:	75 ed                	jne    80171e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801731:	89 f0                	mov    %esi,%eax
  801733:	5b                   	pop    %ebx
  801734:	5e                   	pop    %esi
  801735:	5d                   	pop    %ebp
  801736:	c3                   	ret    

00801737 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	56                   	push   %esi
  80173b:	53                   	push   %ebx
  80173c:	8b 75 08             	mov    0x8(%ebp),%esi
  80173f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801742:	8b 55 10             	mov    0x10(%ebp),%edx
  801745:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801747:	85 d2                	test   %edx,%edx
  801749:	74 21                	je     80176c <strlcpy+0x35>
  80174b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80174f:	89 f2                	mov    %esi,%edx
  801751:	eb 09                	jmp    80175c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801753:	83 c2 01             	add    $0x1,%edx
  801756:	83 c1 01             	add    $0x1,%ecx
  801759:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80175c:	39 c2                	cmp    %eax,%edx
  80175e:	74 09                	je     801769 <strlcpy+0x32>
  801760:	0f b6 19             	movzbl (%ecx),%ebx
  801763:	84 db                	test   %bl,%bl
  801765:	75 ec                	jne    801753 <strlcpy+0x1c>
  801767:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801769:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80176c:	29 f0                	sub    %esi,%eax
}
  80176e:	5b                   	pop    %ebx
  80176f:	5e                   	pop    %esi
  801770:	5d                   	pop    %ebp
  801771:	c3                   	ret    

00801772 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801772:	55                   	push   %ebp
  801773:	89 e5                	mov    %esp,%ebp
  801775:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801778:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80177b:	eb 06                	jmp    801783 <strcmp+0x11>
		p++, q++;
  80177d:	83 c1 01             	add    $0x1,%ecx
  801780:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801783:	0f b6 01             	movzbl (%ecx),%eax
  801786:	84 c0                	test   %al,%al
  801788:	74 04                	je     80178e <strcmp+0x1c>
  80178a:	3a 02                	cmp    (%edx),%al
  80178c:	74 ef                	je     80177d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80178e:	0f b6 c0             	movzbl %al,%eax
  801791:	0f b6 12             	movzbl (%edx),%edx
  801794:	29 d0                	sub    %edx,%eax
}
  801796:	5d                   	pop    %ebp
  801797:	c3                   	ret    

00801798 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	53                   	push   %ebx
  80179c:	8b 45 08             	mov    0x8(%ebp),%eax
  80179f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017a2:	89 c3                	mov    %eax,%ebx
  8017a4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017a7:	eb 06                	jmp    8017af <strncmp+0x17>
		n--, p++, q++;
  8017a9:	83 c0 01             	add    $0x1,%eax
  8017ac:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017af:	39 d8                	cmp    %ebx,%eax
  8017b1:	74 15                	je     8017c8 <strncmp+0x30>
  8017b3:	0f b6 08             	movzbl (%eax),%ecx
  8017b6:	84 c9                	test   %cl,%cl
  8017b8:	74 04                	je     8017be <strncmp+0x26>
  8017ba:	3a 0a                	cmp    (%edx),%cl
  8017bc:	74 eb                	je     8017a9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017be:	0f b6 00             	movzbl (%eax),%eax
  8017c1:	0f b6 12             	movzbl (%edx),%edx
  8017c4:	29 d0                	sub    %edx,%eax
  8017c6:	eb 05                	jmp    8017cd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017c8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017cd:	5b                   	pop    %ebx
  8017ce:	5d                   	pop    %ebp
  8017cf:	c3                   	ret    

008017d0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017da:	eb 07                	jmp    8017e3 <strchr+0x13>
		if (*s == c)
  8017dc:	38 ca                	cmp    %cl,%dl
  8017de:	74 0f                	je     8017ef <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017e0:	83 c0 01             	add    $0x1,%eax
  8017e3:	0f b6 10             	movzbl (%eax),%edx
  8017e6:	84 d2                	test   %dl,%dl
  8017e8:	75 f2                	jne    8017dc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ef:	5d                   	pop    %ebp
  8017f0:	c3                   	ret    

008017f1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017fb:	eb 03                	jmp    801800 <strfind+0xf>
  8017fd:	83 c0 01             	add    $0x1,%eax
  801800:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801803:	38 ca                	cmp    %cl,%dl
  801805:	74 04                	je     80180b <strfind+0x1a>
  801807:	84 d2                	test   %dl,%dl
  801809:	75 f2                	jne    8017fd <strfind+0xc>
			break;
	return (char *) s;
}
  80180b:	5d                   	pop    %ebp
  80180c:	c3                   	ret    

0080180d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	57                   	push   %edi
  801811:	56                   	push   %esi
  801812:	53                   	push   %ebx
  801813:	8b 7d 08             	mov    0x8(%ebp),%edi
  801816:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801819:	85 c9                	test   %ecx,%ecx
  80181b:	74 36                	je     801853 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80181d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801823:	75 28                	jne    80184d <memset+0x40>
  801825:	f6 c1 03             	test   $0x3,%cl
  801828:	75 23                	jne    80184d <memset+0x40>
		c &= 0xFF;
  80182a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80182e:	89 d3                	mov    %edx,%ebx
  801830:	c1 e3 08             	shl    $0x8,%ebx
  801833:	89 d6                	mov    %edx,%esi
  801835:	c1 e6 18             	shl    $0x18,%esi
  801838:	89 d0                	mov    %edx,%eax
  80183a:	c1 e0 10             	shl    $0x10,%eax
  80183d:	09 f0                	or     %esi,%eax
  80183f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801841:	89 d8                	mov    %ebx,%eax
  801843:	09 d0                	or     %edx,%eax
  801845:	c1 e9 02             	shr    $0x2,%ecx
  801848:	fc                   	cld    
  801849:	f3 ab                	rep stos %eax,%es:(%edi)
  80184b:	eb 06                	jmp    801853 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80184d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801850:	fc                   	cld    
  801851:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801853:	89 f8                	mov    %edi,%eax
  801855:	5b                   	pop    %ebx
  801856:	5e                   	pop    %esi
  801857:	5f                   	pop    %edi
  801858:	5d                   	pop    %ebp
  801859:	c3                   	ret    

0080185a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	57                   	push   %edi
  80185e:	56                   	push   %esi
  80185f:	8b 45 08             	mov    0x8(%ebp),%eax
  801862:	8b 75 0c             	mov    0xc(%ebp),%esi
  801865:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801868:	39 c6                	cmp    %eax,%esi
  80186a:	73 35                	jae    8018a1 <memmove+0x47>
  80186c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80186f:	39 d0                	cmp    %edx,%eax
  801871:	73 2e                	jae    8018a1 <memmove+0x47>
		s += n;
		d += n;
  801873:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801876:	89 d6                	mov    %edx,%esi
  801878:	09 fe                	or     %edi,%esi
  80187a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801880:	75 13                	jne    801895 <memmove+0x3b>
  801882:	f6 c1 03             	test   $0x3,%cl
  801885:	75 0e                	jne    801895 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801887:	83 ef 04             	sub    $0x4,%edi
  80188a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80188d:	c1 e9 02             	shr    $0x2,%ecx
  801890:	fd                   	std    
  801891:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801893:	eb 09                	jmp    80189e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801895:	83 ef 01             	sub    $0x1,%edi
  801898:	8d 72 ff             	lea    -0x1(%edx),%esi
  80189b:	fd                   	std    
  80189c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80189e:	fc                   	cld    
  80189f:	eb 1d                	jmp    8018be <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018a1:	89 f2                	mov    %esi,%edx
  8018a3:	09 c2                	or     %eax,%edx
  8018a5:	f6 c2 03             	test   $0x3,%dl
  8018a8:	75 0f                	jne    8018b9 <memmove+0x5f>
  8018aa:	f6 c1 03             	test   $0x3,%cl
  8018ad:	75 0a                	jne    8018b9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018af:	c1 e9 02             	shr    $0x2,%ecx
  8018b2:	89 c7                	mov    %eax,%edi
  8018b4:	fc                   	cld    
  8018b5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b7:	eb 05                	jmp    8018be <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018b9:	89 c7                	mov    %eax,%edi
  8018bb:	fc                   	cld    
  8018bc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018be:	5e                   	pop    %esi
  8018bf:	5f                   	pop    %edi
  8018c0:	5d                   	pop    %ebp
  8018c1:	c3                   	ret    

008018c2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018c2:	55                   	push   %ebp
  8018c3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018c5:	ff 75 10             	pushl  0x10(%ebp)
  8018c8:	ff 75 0c             	pushl  0xc(%ebp)
  8018cb:	ff 75 08             	pushl  0x8(%ebp)
  8018ce:	e8 87 ff ff ff       	call   80185a <memmove>
}
  8018d3:	c9                   	leave  
  8018d4:	c3                   	ret    

008018d5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	56                   	push   %esi
  8018d9:	53                   	push   %ebx
  8018da:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e0:	89 c6                	mov    %eax,%esi
  8018e2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018e5:	eb 1a                	jmp    801901 <memcmp+0x2c>
		if (*s1 != *s2)
  8018e7:	0f b6 08             	movzbl (%eax),%ecx
  8018ea:	0f b6 1a             	movzbl (%edx),%ebx
  8018ed:	38 d9                	cmp    %bl,%cl
  8018ef:	74 0a                	je     8018fb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018f1:	0f b6 c1             	movzbl %cl,%eax
  8018f4:	0f b6 db             	movzbl %bl,%ebx
  8018f7:	29 d8                	sub    %ebx,%eax
  8018f9:	eb 0f                	jmp    80190a <memcmp+0x35>
		s1++, s2++;
  8018fb:	83 c0 01             	add    $0x1,%eax
  8018fe:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801901:	39 f0                	cmp    %esi,%eax
  801903:	75 e2                	jne    8018e7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801905:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80190a:	5b                   	pop    %ebx
  80190b:	5e                   	pop    %esi
  80190c:	5d                   	pop    %ebp
  80190d:	c3                   	ret    

0080190e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	53                   	push   %ebx
  801912:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801915:	89 c1                	mov    %eax,%ecx
  801917:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80191a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80191e:	eb 0a                	jmp    80192a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801920:	0f b6 10             	movzbl (%eax),%edx
  801923:	39 da                	cmp    %ebx,%edx
  801925:	74 07                	je     80192e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801927:	83 c0 01             	add    $0x1,%eax
  80192a:	39 c8                	cmp    %ecx,%eax
  80192c:	72 f2                	jb     801920 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80192e:	5b                   	pop    %ebx
  80192f:	5d                   	pop    %ebp
  801930:	c3                   	ret    

00801931 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801931:	55                   	push   %ebp
  801932:	89 e5                	mov    %esp,%ebp
  801934:	57                   	push   %edi
  801935:	56                   	push   %esi
  801936:	53                   	push   %ebx
  801937:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80193a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80193d:	eb 03                	jmp    801942 <strtol+0x11>
		s++;
  80193f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801942:	0f b6 01             	movzbl (%ecx),%eax
  801945:	3c 20                	cmp    $0x20,%al
  801947:	74 f6                	je     80193f <strtol+0xe>
  801949:	3c 09                	cmp    $0x9,%al
  80194b:	74 f2                	je     80193f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80194d:	3c 2b                	cmp    $0x2b,%al
  80194f:	75 0a                	jne    80195b <strtol+0x2a>
		s++;
  801951:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801954:	bf 00 00 00 00       	mov    $0x0,%edi
  801959:	eb 11                	jmp    80196c <strtol+0x3b>
  80195b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801960:	3c 2d                	cmp    $0x2d,%al
  801962:	75 08                	jne    80196c <strtol+0x3b>
		s++, neg = 1;
  801964:	83 c1 01             	add    $0x1,%ecx
  801967:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80196c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801972:	75 15                	jne    801989 <strtol+0x58>
  801974:	80 39 30             	cmpb   $0x30,(%ecx)
  801977:	75 10                	jne    801989 <strtol+0x58>
  801979:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80197d:	75 7c                	jne    8019fb <strtol+0xca>
		s += 2, base = 16;
  80197f:	83 c1 02             	add    $0x2,%ecx
  801982:	bb 10 00 00 00       	mov    $0x10,%ebx
  801987:	eb 16                	jmp    80199f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801989:	85 db                	test   %ebx,%ebx
  80198b:	75 12                	jne    80199f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80198d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801992:	80 39 30             	cmpb   $0x30,(%ecx)
  801995:	75 08                	jne    80199f <strtol+0x6e>
		s++, base = 8;
  801997:	83 c1 01             	add    $0x1,%ecx
  80199a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80199f:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019a7:	0f b6 11             	movzbl (%ecx),%edx
  8019aa:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019ad:	89 f3                	mov    %esi,%ebx
  8019af:	80 fb 09             	cmp    $0x9,%bl
  8019b2:	77 08                	ja     8019bc <strtol+0x8b>
			dig = *s - '0';
  8019b4:	0f be d2             	movsbl %dl,%edx
  8019b7:	83 ea 30             	sub    $0x30,%edx
  8019ba:	eb 22                	jmp    8019de <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019bc:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019bf:	89 f3                	mov    %esi,%ebx
  8019c1:	80 fb 19             	cmp    $0x19,%bl
  8019c4:	77 08                	ja     8019ce <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019c6:	0f be d2             	movsbl %dl,%edx
  8019c9:	83 ea 57             	sub    $0x57,%edx
  8019cc:	eb 10                	jmp    8019de <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019ce:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019d1:	89 f3                	mov    %esi,%ebx
  8019d3:	80 fb 19             	cmp    $0x19,%bl
  8019d6:	77 16                	ja     8019ee <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019d8:	0f be d2             	movsbl %dl,%edx
  8019db:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019de:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019e1:	7d 0b                	jge    8019ee <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019e3:	83 c1 01             	add    $0x1,%ecx
  8019e6:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019ea:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019ec:	eb b9                	jmp    8019a7 <strtol+0x76>

	if (endptr)
  8019ee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019f2:	74 0d                	je     801a01 <strtol+0xd0>
		*endptr = (char *) s;
  8019f4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019f7:	89 0e                	mov    %ecx,(%esi)
  8019f9:	eb 06                	jmp    801a01 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019fb:	85 db                	test   %ebx,%ebx
  8019fd:	74 98                	je     801997 <strtol+0x66>
  8019ff:	eb 9e                	jmp    80199f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a01:	89 c2                	mov    %eax,%edx
  801a03:	f7 da                	neg    %edx
  801a05:	85 ff                	test   %edi,%edi
  801a07:	0f 45 c2             	cmovne %edx,%eax
}
  801a0a:	5b                   	pop    %ebx
  801a0b:	5e                   	pop    %esi
  801a0c:	5f                   	pop    %edi
  801a0d:	5d                   	pop    %ebp
  801a0e:	c3                   	ret    

00801a0f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	56                   	push   %esi
  801a13:	53                   	push   %ebx
  801a14:	8b 75 08             	mov    0x8(%ebp),%esi
  801a17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801a1d:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801a1f:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801a24:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801a27:	83 ec 0c             	sub    $0xc,%esp
  801a2a:	50                   	push   %eax
  801a2b:	e8 e6 e8 ff ff       	call   800316 <sys_ipc_recv>

	if (r < 0) {
  801a30:	83 c4 10             	add    $0x10,%esp
  801a33:	85 c0                	test   %eax,%eax
  801a35:	79 16                	jns    801a4d <ipc_recv+0x3e>
		if (from_env_store)
  801a37:	85 f6                	test   %esi,%esi
  801a39:	74 06                	je     801a41 <ipc_recv+0x32>
			*from_env_store = 0;
  801a3b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801a41:	85 db                	test   %ebx,%ebx
  801a43:	74 2c                	je     801a71 <ipc_recv+0x62>
			*perm_store = 0;
  801a45:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a4b:	eb 24                	jmp    801a71 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801a4d:	85 f6                	test   %esi,%esi
  801a4f:	74 0a                	je     801a5b <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801a51:	a1 04 40 80 00       	mov    0x804004,%eax
  801a56:	8b 40 74             	mov    0x74(%eax),%eax
  801a59:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801a5b:	85 db                	test   %ebx,%ebx
  801a5d:	74 0a                	je     801a69 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801a5f:	a1 04 40 80 00       	mov    0x804004,%eax
  801a64:	8b 40 78             	mov    0x78(%eax),%eax
  801a67:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801a69:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6e:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801a71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a74:	5b                   	pop    %ebx
  801a75:	5e                   	pop    %esi
  801a76:	5d                   	pop    %ebp
  801a77:	c3                   	ret    

00801a78 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	57                   	push   %edi
  801a7c:	56                   	push   %esi
  801a7d:	53                   	push   %ebx
  801a7e:	83 ec 0c             	sub    $0xc,%esp
  801a81:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a84:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801a8a:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801a8c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801a91:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801a94:	ff 75 14             	pushl  0x14(%ebp)
  801a97:	53                   	push   %ebx
  801a98:	56                   	push   %esi
  801a99:	57                   	push   %edi
  801a9a:	e8 54 e8 ff ff       	call   8002f3 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801a9f:	83 c4 10             	add    $0x10,%esp
  801aa2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aa5:	75 07                	jne    801aae <ipc_send+0x36>
			sys_yield();
  801aa7:	e8 9b e6 ff ff       	call   800147 <sys_yield>
  801aac:	eb e6                	jmp    801a94 <ipc_send+0x1c>
		} else if (r < 0) {
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	79 12                	jns    801ac4 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801ab2:	50                   	push   %eax
  801ab3:	68 40 22 80 00       	push   $0x802240
  801ab8:	6a 51                	push   $0x51
  801aba:	68 4d 22 80 00       	push   $0x80224d
  801abf:	e8 a6 f5 ff ff       	call   80106a <_panic>
		}
	}
}
  801ac4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac7:	5b                   	pop    %ebx
  801ac8:	5e                   	pop    %esi
  801ac9:	5f                   	pop    %edi
  801aca:	5d                   	pop    %ebp
  801acb:	c3                   	ret    

00801acc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ad2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ad7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ada:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ae0:	8b 52 50             	mov    0x50(%edx),%edx
  801ae3:	39 ca                	cmp    %ecx,%edx
  801ae5:	75 0d                	jne    801af4 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ae7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801aea:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801aef:	8b 40 48             	mov    0x48(%eax),%eax
  801af2:	eb 0f                	jmp    801b03 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801af4:	83 c0 01             	add    $0x1,%eax
  801af7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801afc:	75 d9                	jne    801ad7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801afe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b03:	5d                   	pop    %ebp
  801b04:	c3                   	ret    

00801b05 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b05:	55                   	push   %ebp
  801b06:	89 e5                	mov    %esp,%ebp
  801b08:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b0b:	89 d0                	mov    %edx,%eax
  801b0d:	c1 e8 16             	shr    $0x16,%eax
  801b10:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b17:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b1c:	f6 c1 01             	test   $0x1,%cl
  801b1f:	74 1d                	je     801b3e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b21:	c1 ea 0c             	shr    $0xc,%edx
  801b24:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b2b:	f6 c2 01             	test   $0x1,%dl
  801b2e:	74 0e                	je     801b3e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b30:	c1 ea 0c             	shr    $0xc,%edx
  801b33:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b3a:	ef 
  801b3b:	0f b7 c0             	movzwl %ax,%eax
}
  801b3e:	5d                   	pop    %ebp
  801b3f:	c3                   	ret    

00801b40 <__udivdi3>:
  801b40:	55                   	push   %ebp
  801b41:	57                   	push   %edi
  801b42:	56                   	push   %esi
  801b43:	53                   	push   %ebx
  801b44:	83 ec 1c             	sub    $0x1c,%esp
  801b47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b57:	85 f6                	test   %esi,%esi
  801b59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b5d:	89 ca                	mov    %ecx,%edx
  801b5f:	89 f8                	mov    %edi,%eax
  801b61:	75 3d                	jne    801ba0 <__udivdi3+0x60>
  801b63:	39 cf                	cmp    %ecx,%edi
  801b65:	0f 87 c5 00 00 00    	ja     801c30 <__udivdi3+0xf0>
  801b6b:	85 ff                	test   %edi,%edi
  801b6d:	89 fd                	mov    %edi,%ebp
  801b6f:	75 0b                	jne    801b7c <__udivdi3+0x3c>
  801b71:	b8 01 00 00 00       	mov    $0x1,%eax
  801b76:	31 d2                	xor    %edx,%edx
  801b78:	f7 f7                	div    %edi
  801b7a:	89 c5                	mov    %eax,%ebp
  801b7c:	89 c8                	mov    %ecx,%eax
  801b7e:	31 d2                	xor    %edx,%edx
  801b80:	f7 f5                	div    %ebp
  801b82:	89 c1                	mov    %eax,%ecx
  801b84:	89 d8                	mov    %ebx,%eax
  801b86:	89 cf                	mov    %ecx,%edi
  801b88:	f7 f5                	div    %ebp
  801b8a:	89 c3                	mov    %eax,%ebx
  801b8c:	89 d8                	mov    %ebx,%eax
  801b8e:	89 fa                	mov    %edi,%edx
  801b90:	83 c4 1c             	add    $0x1c,%esp
  801b93:	5b                   	pop    %ebx
  801b94:	5e                   	pop    %esi
  801b95:	5f                   	pop    %edi
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    
  801b98:	90                   	nop
  801b99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ba0:	39 ce                	cmp    %ecx,%esi
  801ba2:	77 74                	ja     801c18 <__udivdi3+0xd8>
  801ba4:	0f bd fe             	bsr    %esi,%edi
  801ba7:	83 f7 1f             	xor    $0x1f,%edi
  801baa:	0f 84 98 00 00 00    	je     801c48 <__udivdi3+0x108>
  801bb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bb5:	89 f9                	mov    %edi,%ecx
  801bb7:	89 c5                	mov    %eax,%ebp
  801bb9:	29 fb                	sub    %edi,%ebx
  801bbb:	d3 e6                	shl    %cl,%esi
  801bbd:	89 d9                	mov    %ebx,%ecx
  801bbf:	d3 ed                	shr    %cl,%ebp
  801bc1:	89 f9                	mov    %edi,%ecx
  801bc3:	d3 e0                	shl    %cl,%eax
  801bc5:	09 ee                	or     %ebp,%esi
  801bc7:	89 d9                	mov    %ebx,%ecx
  801bc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bcd:	89 d5                	mov    %edx,%ebp
  801bcf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801bd3:	d3 ed                	shr    %cl,%ebp
  801bd5:	89 f9                	mov    %edi,%ecx
  801bd7:	d3 e2                	shl    %cl,%edx
  801bd9:	89 d9                	mov    %ebx,%ecx
  801bdb:	d3 e8                	shr    %cl,%eax
  801bdd:	09 c2                	or     %eax,%edx
  801bdf:	89 d0                	mov    %edx,%eax
  801be1:	89 ea                	mov    %ebp,%edx
  801be3:	f7 f6                	div    %esi
  801be5:	89 d5                	mov    %edx,%ebp
  801be7:	89 c3                	mov    %eax,%ebx
  801be9:	f7 64 24 0c          	mull   0xc(%esp)
  801bed:	39 d5                	cmp    %edx,%ebp
  801bef:	72 10                	jb     801c01 <__udivdi3+0xc1>
  801bf1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801bf5:	89 f9                	mov    %edi,%ecx
  801bf7:	d3 e6                	shl    %cl,%esi
  801bf9:	39 c6                	cmp    %eax,%esi
  801bfb:	73 07                	jae    801c04 <__udivdi3+0xc4>
  801bfd:	39 d5                	cmp    %edx,%ebp
  801bff:	75 03                	jne    801c04 <__udivdi3+0xc4>
  801c01:	83 eb 01             	sub    $0x1,%ebx
  801c04:	31 ff                	xor    %edi,%edi
  801c06:	89 d8                	mov    %ebx,%eax
  801c08:	89 fa                	mov    %edi,%edx
  801c0a:	83 c4 1c             	add    $0x1c,%esp
  801c0d:	5b                   	pop    %ebx
  801c0e:	5e                   	pop    %esi
  801c0f:	5f                   	pop    %edi
  801c10:	5d                   	pop    %ebp
  801c11:	c3                   	ret    
  801c12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c18:	31 ff                	xor    %edi,%edi
  801c1a:	31 db                	xor    %ebx,%ebx
  801c1c:	89 d8                	mov    %ebx,%eax
  801c1e:	89 fa                	mov    %edi,%edx
  801c20:	83 c4 1c             	add    $0x1c,%esp
  801c23:	5b                   	pop    %ebx
  801c24:	5e                   	pop    %esi
  801c25:	5f                   	pop    %edi
  801c26:	5d                   	pop    %ebp
  801c27:	c3                   	ret    
  801c28:	90                   	nop
  801c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c30:	89 d8                	mov    %ebx,%eax
  801c32:	f7 f7                	div    %edi
  801c34:	31 ff                	xor    %edi,%edi
  801c36:	89 c3                	mov    %eax,%ebx
  801c38:	89 d8                	mov    %ebx,%eax
  801c3a:	89 fa                	mov    %edi,%edx
  801c3c:	83 c4 1c             	add    $0x1c,%esp
  801c3f:	5b                   	pop    %ebx
  801c40:	5e                   	pop    %esi
  801c41:	5f                   	pop    %edi
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    
  801c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c48:	39 ce                	cmp    %ecx,%esi
  801c4a:	72 0c                	jb     801c58 <__udivdi3+0x118>
  801c4c:	31 db                	xor    %ebx,%ebx
  801c4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c52:	0f 87 34 ff ff ff    	ja     801b8c <__udivdi3+0x4c>
  801c58:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c5d:	e9 2a ff ff ff       	jmp    801b8c <__udivdi3+0x4c>
  801c62:	66 90                	xchg   %ax,%ax
  801c64:	66 90                	xchg   %ax,%ax
  801c66:	66 90                	xchg   %ax,%ax
  801c68:	66 90                	xchg   %ax,%ax
  801c6a:	66 90                	xchg   %ax,%ax
  801c6c:	66 90                	xchg   %ax,%ax
  801c6e:	66 90                	xchg   %ax,%ax

00801c70 <__umoddi3>:
  801c70:	55                   	push   %ebp
  801c71:	57                   	push   %edi
  801c72:	56                   	push   %esi
  801c73:	53                   	push   %ebx
  801c74:	83 ec 1c             	sub    $0x1c,%esp
  801c77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c87:	85 d2                	test   %edx,%edx
  801c89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c91:	89 f3                	mov    %esi,%ebx
  801c93:	89 3c 24             	mov    %edi,(%esp)
  801c96:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c9a:	75 1c                	jne    801cb8 <__umoddi3+0x48>
  801c9c:	39 f7                	cmp    %esi,%edi
  801c9e:	76 50                	jbe    801cf0 <__umoddi3+0x80>
  801ca0:	89 c8                	mov    %ecx,%eax
  801ca2:	89 f2                	mov    %esi,%edx
  801ca4:	f7 f7                	div    %edi
  801ca6:	89 d0                	mov    %edx,%eax
  801ca8:	31 d2                	xor    %edx,%edx
  801caa:	83 c4 1c             	add    $0x1c,%esp
  801cad:	5b                   	pop    %ebx
  801cae:	5e                   	pop    %esi
  801caf:	5f                   	pop    %edi
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    
  801cb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cb8:	39 f2                	cmp    %esi,%edx
  801cba:	89 d0                	mov    %edx,%eax
  801cbc:	77 52                	ja     801d10 <__umoddi3+0xa0>
  801cbe:	0f bd ea             	bsr    %edx,%ebp
  801cc1:	83 f5 1f             	xor    $0x1f,%ebp
  801cc4:	75 5a                	jne    801d20 <__umoddi3+0xb0>
  801cc6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cca:	0f 82 e0 00 00 00    	jb     801db0 <__umoddi3+0x140>
  801cd0:	39 0c 24             	cmp    %ecx,(%esp)
  801cd3:	0f 86 d7 00 00 00    	jbe    801db0 <__umoddi3+0x140>
  801cd9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cdd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ce1:	83 c4 1c             	add    $0x1c,%esp
  801ce4:	5b                   	pop    %ebx
  801ce5:	5e                   	pop    %esi
  801ce6:	5f                   	pop    %edi
  801ce7:	5d                   	pop    %ebp
  801ce8:	c3                   	ret    
  801ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	85 ff                	test   %edi,%edi
  801cf2:	89 fd                	mov    %edi,%ebp
  801cf4:	75 0b                	jne    801d01 <__umoddi3+0x91>
  801cf6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cfb:	31 d2                	xor    %edx,%edx
  801cfd:	f7 f7                	div    %edi
  801cff:	89 c5                	mov    %eax,%ebp
  801d01:	89 f0                	mov    %esi,%eax
  801d03:	31 d2                	xor    %edx,%edx
  801d05:	f7 f5                	div    %ebp
  801d07:	89 c8                	mov    %ecx,%eax
  801d09:	f7 f5                	div    %ebp
  801d0b:	89 d0                	mov    %edx,%eax
  801d0d:	eb 99                	jmp    801ca8 <__umoddi3+0x38>
  801d0f:	90                   	nop
  801d10:	89 c8                	mov    %ecx,%eax
  801d12:	89 f2                	mov    %esi,%edx
  801d14:	83 c4 1c             	add    $0x1c,%esp
  801d17:	5b                   	pop    %ebx
  801d18:	5e                   	pop    %esi
  801d19:	5f                   	pop    %edi
  801d1a:	5d                   	pop    %ebp
  801d1b:	c3                   	ret    
  801d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d20:	8b 34 24             	mov    (%esp),%esi
  801d23:	bf 20 00 00 00       	mov    $0x20,%edi
  801d28:	89 e9                	mov    %ebp,%ecx
  801d2a:	29 ef                	sub    %ebp,%edi
  801d2c:	d3 e0                	shl    %cl,%eax
  801d2e:	89 f9                	mov    %edi,%ecx
  801d30:	89 f2                	mov    %esi,%edx
  801d32:	d3 ea                	shr    %cl,%edx
  801d34:	89 e9                	mov    %ebp,%ecx
  801d36:	09 c2                	or     %eax,%edx
  801d38:	89 d8                	mov    %ebx,%eax
  801d3a:	89 14 24             	mov    %edx,(%esp)
  801d3d:	89 f2                	mov    %esi,%edx
  801d3f:	d3 e2                	shl    %cl,%edx
  801d41:	89 f9                	mov    %edi,%ecx
  801d43:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d47:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d4b:	d3 e8                	shr    %cl,%eax
  801d4d:	89 e9                	mov    %ebp,%ecx
  801d4f:	89 c6                	mov    %eax,%esi
  801d51:	d3 e3                	shl    %cl,%ebx
  801d53:	89 f9                	mov    %edi,%ecx
  801d55:	89 d0                	mov    %edx,%eax
  801d57:	d3 e8                	shr    %cl,%eax
  801d59:	89 e9                	mov    %ebp,%ecx
  801d5b:	09 d8                	or     %ebx,%eax
  801d5d:	89 d3                	mov    %edx,%ebx
  801d5f:	89 f2                	mov    %esi,%edx
  801d61:	f7 34 24             	divl   (%esp)
  801d64:	89 d6                	mov    %edx,%esi
  801d66:	d3 e3                	shl    %cl,%ebx
  801d68:	f7 64 24 04          	mull   0x4(%esp)
  801d6c:	39 d6                	cmp    %edx,%esi
  801d6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d72:	89 d1                	mov    %edx,%ecx
  801d74:	89 c3                	mov    %eax,%ebx
  801d76:	72 08                	jb     801d80 <__umoddi3+0x110>
  801d78:	75 11                	jne    801d8b <__umoddi3+0x11b>
  801d7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d7e:	73 0b                	jae    801d8b <__umoddi3+0x11b>
  801d80:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d84:	1b 14 24             	sbb    (%esp),%edx
  801d87:	89 d1                	mov    %edx,%ecx
  801d89:	89 c3                	mov    %eax,%ebx
  801d8b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d8f:	29 da                	sub    %ebx,%edx
  801d91:	19 ce                	sbb    %ecx,%esi
  801d93:	89 f9                	mov    %edi,%ecx
  801d95:	89 f0                	mov    %esi,%eax
  801d97:	d3 e0                	shl    %cl,%eax
  801d99:	89 e9                	mov    %ebp,%ecx
  801d9b:	d3 ea                	shr    %cl,%edx
  801d9d:	89 e9                	mov    %ebp,%ecx
  801d9f:	d3 ee                	shr    %cl,%esi
  801da1:	09 d0                	or     %edx,%eax
  801da3:	89 f2                	mov    %esi,%edx
  801da5:	83 c4 1c             	add    $0x1c,%esp
  801da8:	5b                   	pop    %ebx
  801da9:	5e                   	pop    %esi
  801daa:	5f                   	pop    %edi
  801dab:	5d                   	pop    %ebp
  801dac:	c3                   	ret    
  801dad:	8d 76 00             	lea    0x0(%esi),%esi
  801db0:	29 f9                	sub    %edi,%ecx
  801db2:	19 d6                	sbb    %edx,%esi
  801db4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801db8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dbc:	e9 18 ff ff ff       	jmp    801cd9 <__umoddi3+0x69>
