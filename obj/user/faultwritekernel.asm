
obj/user/faultwritekernel:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  80004d:	e8 c6 00 00 00       	call   800118 <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x2d>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008e:	6a 00                	push   $0x0
  800090:	e8 42 00 00 00       	call   8000d7 <sys_env_destroy>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ab:	89 c3                	mov    %eax,%ebx
  8000ad:	89 c7                	mov    %eax,%edi
  8000af:	89 c6                	mov    %eax,%esi
  8000b1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000be:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c8:	89 d1                	mov    %edx,%ecx
  8000ca:	89 d3                	mov    %edx,%ebx
  8000cc:	89 d7                	mov    %edx,%edi
  8000ce:	89 d6                	mov    %edx,%esi
  8000d0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ed:	89 cb                	mov    %ecx,%ebx
  8000ef:	89 cf                	mov    %ecx,%edi
  8000f1:	89 ce                	mov    %ecx,%esi
  8000f3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	7e 17                	jle    800110 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	50                   	push   %eax
  8000fd:	6a 03                	push   $0x3
  8000ff:	68 8a 0f 80 00       	push   $0x800f8a
  800104:	6a 23                	push   $0x23
  800106:	68 a7 0f 80 00       	push   $0x800fa7
  80010b:	e8 f5 01 00 00       	call   800305 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011e:	ba 00 00 00 00       	mov    $0x0,%edx
  800123:	b8 02 00 00 00       	mov    $0x2,%eax
  800128:	89 d1                	mov    %edx,%ecx
  80012a:	89 d3                	mov    %edx,%ebx
  80012c:	89 d7                	mov    %edx,%edi
  80012e:	89 d6                	mov    %edx,%esi
  800130:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_yield>:

void
sys_yield(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 0a 00 00 00       	mov    $0xa,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015f:	be 00 00 00 00       	mov    $0x0,%esi
  800164:	b8 04 00 00 00       	mov    $0x4,%eax
  800169:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800172:	89 f7                	mov    %esi,%edi
  800174:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800176:	85 c0                	test   %eax,%eax
  800178:	7e 17                	jle    800191 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017a:	83 ec 0c             	sub    $0xc,%esp
  80017d:	50                   	push   %eax
  80017e:	6a 04                	push   $0x4
  800180:	68 8a 0f 80 00       	push   $0x800f8a
  800185:	6a 23                	push   $0x23
  800187:	68 a7 0f 80 00       	push   $0x800fa7
  80018c:	e8 74 01 00 00       	call   800305 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	7e 17                	jle    8001d3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	50                   	push   %eax
  8001c0:	6a 05                	push   $0x5
  8001c2:	68 8a 0f 80 00       	push   $0x800f8a
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 a7 0f 80 00       	push   $0x800fa7
  8001ce:	e8 32 01 00 00       	call   800305 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	89 df                	mov    %ebx,%edi
  8001f6:	89 de                	mov    %ebx,%esi
  8001f8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7e 17                	jle    800215 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	50                   	push   %eax
  800202:	6a 06                	push   $0x6
  800204:	68 8a 0f 80 00       	push   $0x800f8a
  800209:	6a 23                	push   $0x23
  80020b:	68 a7 0f 80 00       	push   $0x800fa7
  800210:	e8 f0 00 00 00       	call   800305 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5f                   	pop    %edi
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    

0080021d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	b8 08 00 00 00       	mov    $0x8,%eax
  800230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800233:	8b 55 08             	mov    0x8(%ebp),%edx
  800236:	89 df                	mov    %ebx,%edi
  800238:	89 de                	mov    %ebx,%esi
  80023a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80023c:	85 c0                	test   %eax,%eax
  80023e:	7e 17                	jle    800257 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	50                   	push   %eax
  800244:	6a 08                	push   $0x8
  800246:	68 8a 0f 80 00       	push   $0x800f8a
  80024b:	6a 23                	push   $0x23
  80024d:	68 a7 0f 80 00       	push   $0x800fa7
  800252:	e8 ae 00 00 00       	call   800305 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	b8 09 00 00 00       	mov    $0x9,%eax
  800272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7e 17                	jle    800299 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	50                   	push   %eax
  800286:	6a 09                	push   $0x9
  800288:	68 8a 0f 80 00       	push   $0x800f8a
  80028d:	6a 23                	push   $0x23
  80028f:	68 a7 0f 80 00       	push   $0x800fa7
  800294:	e8 6c 00 00 00       	call   800305 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800299:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029c:	5b                   	pop    %ebx
  80029d:	5e                   	pop    %esi
  80029e:	5f                   	pop    %edi
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    

008002a1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a7:	be 00 00 00 00       	mov    $0x0,%esi
  8002ac:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ba:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002bd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002bf:	5b                   	pop    %ebx
  8002c0:	5e                   	pop    %esi
  8002c1:	5f                   	pop    %edi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
  8002ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002da:	89 cb                	mov    %ecx,%ebx
  8002dc:	89 cf                	mov    %ecx,%edi
  8002de:	89 ce                	mov    %ecx,%esi
  8002e0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e2:	85 c0                	test   %eax,%eax
  8002e4:	7e 17                	jle    8002fd <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e6:	83 ec 0c             	sub    $0xc,%esp
  8002e9:	50                   	push   %eax
  8002ea:	6a 0c                	push   $0xc
  8002ec:	68 8a 0f 80 00       	push   $0x800f8a
  8002f1:	6a 23                	push   $0x23
  8002f3:	68 a7 0f 80 00       	push   $0x800fa7
  8002f8:	e8 08 00 00 00       	call   800305 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	56                   	push   %esi
  800309:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80030a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80030d:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800313:	e8 00 fe ff ff       	call   800118 <sys_getenvid>
  800318:	83 ec 0c             	sub    $0xc,%esp
  80031b:	ff 75 0c             	pushl  0xc(%ebp)
  80031e:	ff 75 08             	pushl  0x8(%ebp)
  800321:	56                   	push   %esi
  800322:	50                   	push   %eax
  800323:	68 b8 0f 80 00       	push   $0x800fb8
  800328:	e8 b1 00 00 00       	call   8003de <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80032d:	83 c4 18             	add    $0x18,%esp
  800330:	53                   	push   %ebx
  800331:	ff 75 10             	pushl  0x10(%ebp)
  800334:	e8 54 00 00 00       	call   80038d <vcprintf>
	cprintf("\n");
  800339:	c7 04 24 dc 0f 80 00 	movl   $0x800fdc,(%esp)
  800340:	e8 99 00 00 00       	call   8003de <cprintf>
  800345:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800348:	cc                   	int3   
  800349:	eb fd                	jmp    800348 <_panic+0x43>

0080034b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	53                   	push   %ebx
  80034f:	83 ec 04             	sub    $0x4,%esp
  800352:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800355:	8b 13                	mov    (%ebx),%edx
  800357:	8d 42 01             	lea    0x1(%edx),%eax
  80035a:	89 03                	mov    %eax,(%ebx)
  80035c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80035f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800363:	3d ff 00 00 00       	cmp    $0xff,%eax
  800368:	75 1a                	jne    800384 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80036a:	83 ec 08             	sub    $0x8,%esp
  80036d:	68 ff 00 00 00       	push   $0xff
  800372:	8d 43 08             	lea    0x8(%ebx),%eax
  800375:	50                   	push   %eax
  800376:	e8 1f fd ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  80037b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800381:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800384:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800388:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80038b:	c9                   	leave  
  80038c:	c3                   	ret    

0080038d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800396:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80039d:	00 00 00 
	b.cnt = 0;
  8003a0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003a7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003aa:	ff 75 0c             	pushl  0xc(%ebp)
  8003ad:	ff 75 08             	pushl  0x8(%ebp)
  8003b0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003b6:	50                   	push   %eax
  8003b7:	68 4b 03 80 00       	push   $0x80034b
  8003bc:	e8 54 01 00 00       	call   800515 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003c1:	83 c4 08             	add    $0x8,%esp
  8003c4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003ca:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d0:	50                   	push   %eax
  8003d1:	e8 c4 fc ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  8003d6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003dc:	c9                   	leave  
  8003dd:	c3                   	ret    

008003de <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003de:	55                   	push   %ebp
  8003df:	89 e5                	mov    %esp,%ebp
  8003e1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003e4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003e7:	50                   	push   %eax
  8003e8:	ff 75 08             	pushl  0x8(%ebp)
  8003eb:	e8 9d ff ff ff       	call   80038d <vcprintf>
	va_end(ap);

	return cnt;
}
  8003f0:	c9                   	leave  
  8003f1:	c3                   	ret    

008003f2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
  8003f5:	57                   	push   %edi
  8003f6:	56                   	push   %esi
  8003f7:	53                   	push   %ebx
  8003f8:	83 ec 1c             	sub    $0x1c,%esp
  8003fb:	89 c7                	mov    %eax,%edi
  8003fd:	89 d6                	mov    %edx,%esi
  8003ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800402:	8b 55 0c             	mov    0xc(%ebp),%edx
  800405:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800408:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80040b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80040e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800413:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800416:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800419:	39 d3                	cmp    %edx,%ebx
  80041b:	72 05                	jb     800422 <printnum+0x30>
  80041d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800420:	77 45                	ja     800467 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800422:	83 ec 0c             	sub    $0xc,%esp
  800425:	ff 75 18             	pushl  0x18(%ebp)
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80042e:	53                   	push   %ebx
  80042f:	ff 75 10             	pushl  0x10(%ebp)
  800432:	83 ec 08             	sub    $0x8,%esp
  800435:	ff 75 e4             	pushl  -0x1c(%ebp)
  800438:	ff 75 e0             	pushl  -0x20(%ebp)
  80043b:	ff 75 dc             	pushl  -0x24(%ebp)
  80043e:	ff 75 d8             	pushl  -0x28(%ebp)
  800441:	e8 aa 08 00 00       	call   800cf0 <__udivdi3>
  800446:	83 c4 18             	add    $0x18,%esp
  800449:	52                   	push   %edx
  80044a:	50                   	push   %eax
  80044b:	89 f2                	mov    %esi,%edx
  80044d:	89 f8                	mov    %edi,%eax
  80044f:	e8 9e ff ff ff       	call   8003f2 <printnum>
  800454:	83 c4 20             	add    $0x20,%esp
  800457:	eb 18                	jmp    800471 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800459:	83 ec 08             	sub    $0x8,%esp
  80045c:	56                   	push   %esi
  80045d:	ff 75 18             	pushl  0x18(%ebp)
  800460:	ff d7                	call   *%edi
  800462:	83 c4 10             	add    $0x10,%esp
  800465:	eb 03                	jmp    80046a <printnum+0x78>
  800467:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80046a:	83 eb 01             	sub    $0x1,%ebx
  80046d:	85 db                	test   %ebx,%ebx
  80046f:	7f e8                	jg     800459 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	56                   	push   %esi
  800475:	83 ec 04             	sub    $0x4,%esp
  800478:	ff 75 e4             	pushl  -0x1c(%ebp)
  80047b:	ff 75 e0             	pushl  -0x20(%ebp)
  80047e:	ff 75 dc             	pushl  -0x24(%ebp)
  800481:	ff 75 d8             	pushl  -0x28(%ebp)
  800484:	e8 97 09 00 00       	call   800e20 <__umoddi3>
  800489:	83 c4 14             	add    $0x14,%esp
  80048c:	0f be 80 de 0f 80 00 	movsbl 0x800fde(%eax),%eax
  800493:	50                   	push   %eax
  800494:	ff d7                	call   *%edi
}
  800496:	83 c4 10             	add    $0x10,%esp
  800499:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80049c:	5b                   	pop    %ebx
  80049d:	5e                   	pop    %esi
  80049e:	5f                   	pop    %edi
  80049f:	5d                   	pop    %ebp
  8004a0:	c3                   	ret    

008004a1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004a1:	55                   	push   %ebp
  8004a2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004a4:	83 fa 01             	cmp    $0x1,%edx
  8004a7:	7e 0e                	jle    8004b7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004a9:	8b 10                	mov    (%eax),%edx
  8004ab:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004ae:	89 08                	mov    %ecx,(%eax)
  8004b0:	8b 02                	mov    (%edx),%eax
  8004b2:	8b 52 04             	mov    0x4(%edx),%edx
  8004b5:	eb 22                	jmp    8004d9 <getuint+0x38>
	else if (lflag)
  8004b7:	85 d2                	test   %edx,%edx
  8004b9:	74 10                	je     8004cb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004bb:	8b 10                	mov    (%eax),%edx
  8004bd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c0:	89 08                	mov    %ecx,(%eax)
  8004c2:	8b 02                	mov    (%edx),%eax
  8004c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c9:	eb 0e                	jmp    8004d9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004cb:	8b 10                	mov    (%eax),%edx
  8004cd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d0:	89 08                	mov    %ecx,(%eax)
  8004d2:	8b 02                	mov    (%edx),%eax
  8004d4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004d9:	5d                   	pop    %ebp
  8004da:	c3                   	ret    

008004db <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004db:	55                   	push   %ebp
  8004dc:	89 e5                	mov    %esp,%ebp
  8004de:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004e5:	8b 10                	mov    (%eax),%edx
  8004e7:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ea:	73 0a                	jae    8004f6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ec:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004ef:	89 08                	mov    %ecx,(%eax)
  8004f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f4:	88 02                	mov    %al,(%edx)
}
  8004f6:	5d                   	pop    %ebp
  8004f7:	c3                   	ret    

008004f8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004f8:	55                   	push   %ebp
  8004f9:	89 e5                	mov    %esp,%ebp
  8004fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004fe:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800501:	50                   	push   %eax
  800502:	ff 75 10             	pushl  0x10(%ebp)
  800505:	ff 75 0c             	pushl  0xc(%ebp)
  800508:	ff 75 08             	pushl  0x8(%ebp)
  80050b:	e8 05 00 00 00       	call   800515 <vprintfmt>
	va_end(ap);
}
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	c9                   	leave  
  800514:	c3                   	ret    

00800515 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800515:	55                   	push   %ebp
  800516:	89 e5                	mov    %esp,%ebp
  800518:	57                   	push   %edi
  800519:	56                   	push   %esi
  80051a:	53                   	push   %ebx
  80051b:	83 ec 2c             	sub    $0x2c,%esp
  80051e:	8b 75 08             	mov    0x8(%ebp),%esi
  800521:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800524:	8b 7d 10             	mov    0x10(%ebp),%edi
  800527:	eb 1d                	jmp    800546 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  800529:	85 c0                	test   %eax,%eax
  80052b:	75 0f                	jne    80053c <vprintfmt+0x27>
				csa = 0x0700;
  80052d:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  800534:	07 00 00 
				return;
  800537:	e9 c4 03 00 00       	jmp    800900 <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  80053c:	83 ec 08             	sub    $0x8,%esp
  80053f:	53                   	push   %ebx
  800540:	50                   	push   %eax
  800541:	ff d6                	call   *%esi
  800543:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800546:	83 c7 01             	add    $0x1,%edi
  800549:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80054d:	83 f8 25             	cmp    $0x25,%eax
  800550:	75 d7                	jne    800529 <vprintfmt+0x14>
  800552:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800556:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80055d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800564:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80056b:	ba 00 00 00 00       	mov    $0x0,%edx
  800570:	eb 07                	jmp    800579 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800572:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800575:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800579:	8d 47 01             	lea    0x1(%edi),%eax
  80057c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80057f:	0f b6 07             	movzbl (%edi),%eax
  800582:	0f b6 c8             	movzbl %al,%ecx
  800585:	83 e8 23             	sub    $0x23,%eax
  800588:	3c 55                	cmp    $0x55,%al
  80058a:	0f 87 55 03 00 00    	ja     8008e5 <vprintfmt+0x3d0>
  800590:	0f b6 c0             	movzbl %al,%eax
  800593:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  80059a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80059d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005a1:	eb d6                	jmp    800579 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ab:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005ae:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005b1:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005b5:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005b8:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005bb:	83 fa 09             	cmp    $0x9,%edx
  8005be:	77 39                	ja     8005f9 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005c3:	eb e9                	jmp    8005ae <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8d 48 04             	lea    0x4(%eax),%ecx
  8005cb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005ce:	8b 00                	mov    (%eax),%eax
  8005d0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005d6:	eb 27                	jmp    8005ff <vprintfmt+0xea>
  8005d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005db:	85 c0                	test   %eax,%eax
  8005dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e2:	0f 49 c8             	cmovns %eax,%ecx
  8005e5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005eb:	eb 8c                	jmp    800579 <vprintfmt+0x64>
  8005ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005f0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005f7:	eb 80                	jmp    800579 <vprintfmt+0x64>
  8005f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800603:	0f 89 70 ff ff ff    	jns    800579 <vprintfmt+0x64>
				width = precision, precision = -1;
  800609:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80060c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800616:	e9 5e ff ff ff       	jmp    800579 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80061b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800621:	e9 53 ff ff ff       	jmp    800579 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8d 50 04             	lea    0x4(%eax),%edx
  80062c:	89 55 14             	mov    %edx,0x14(%ebp)
  80062f:	83 ec 08             	sub    $0x8,%esp
  800632:	53                   	push   %ebx
  800633:	ff 30                	pushl  (%eax)
  800635:	ff d6                	call   *%esi
			break;
  800637:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80063d:	e9 04 ff ff ff       	jmp    800546 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 50 04             	lea    0x4(%eax),%edx
  800648:	89 55 14             	mov    %edx,0x14(%ebp)
  80064b:	8b 00                	mov    (%eax),%eax
  80064d:	99                   	cltd   
  80064e:	31 d0                	xor    %edx,%eax
  800650:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800652:	83 f8 08             	cmp    $0x8,%eax
  800655:	7f 0b                	jg     800662 <vprintfmt+0x14d>
  800657:	8b 14 85 00 12 80 00 	mov    0x801200(,%eax,4),%edx
  80065e:	85 d2                	test   %edx,%edx
  800660:	75 18                	jne    80067a <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  800662:	50                   	push   %eax
  800663:	68 f6 0f 80 00       	push   $0x800ff6
  800668:	53                   	push   %ebx
  800669:	56                   	push   %esi
  80066a:	e8 89 fe ff ff       	call   8004f8 <printfmt>
  80066f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800672:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800675:	e9 cc fe ff ff       	jmp    800546 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  80067a:	52                   	push   %edx
  80067b:	68 ff 0f 80 00       	push   $0x800fff
  800680:	53                   	push   %ebx
  800681:	56                   	push   %esi
  800682:	e8 71 fe ff ff       	call   8004f8 <printfmt>
  800687:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80068d:	e9 b4 fe ff ff       	jmp    800546 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8d 50 04             	lea    0x4(%eax),%edx
  800698:	89 55 14             	mov    %edx,0x14(%ebp)
  80069b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80069d:	85 ff                	test   %edi,%edi
  80069f:	b8 ef 0f 80 00       	mov    $0x800fef,%eax
  8006a4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006a7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ab:	0f 8e 94 00 00 00    	jle    800745 <vprintfmt+0x230>
  8006b1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006b5:	0f 84 98 00 00 00    	je     800753 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	ff 75 d0             	pushl  -0x30(%ebp)
  8006c1:	57                   	push   %edi
  8006c2:	e8 c1 02 00 00       	call   800988 <strnlen>
  8006c7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006ca:	29 c1                	sub    %eax,%ecx
  8006cc:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006cf:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006d2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006dc:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006de:	eb 0f                	jmp    8006ef <vprintfmt+0x1da>
					putch(padc, putdat);
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	53                   	push   %ebx
  8006e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e9:	83 ef 01             	sub    $0x1,%edi
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	85 ff                	test   %edi,%edi
  8006f1:	7f ed                	jg     8006e0 <vprintfmt+0x1cb>
  8006f3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006f6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006f9:	85 c9                	test   %ecx,%ecx
  8006fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800700:	0f 49 c1             	cmovns %ecx,%eax
  800703:	29 c1                	sub    %eax,%ecx
  800705:	89 75 08             	mov    %esi,0x8(%ebp)
  800708:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80070b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070e:	89 cb                	mov    %ecx,%ebx
  800710:	eb 4d                	jmp    80075f <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800712:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800716:	74 1b                	je     800733 <vprintfmt+0x21e>
  800718:	0f be c0             	movsbl %al,%eax
  80071b:	83 e8 20             	sub    $0x20,%eax
  80071e:	83 f8 5e             	cmp    $0x5e,%eax
  800721:	76 10                	jbe    800733 <vprintfmt+0x21e>
					putch('?', putdat);
  800723:	83 ec 08             	sub    $0x8,%esp
  800726:	ff 75 0c             	pushl  0xc(%ebp)
  800729:	6a 3f                	push   $0x3f
  80072b:	ff 55 08             	call   *0x8(%ebp)
  80072e:	83 c4 10             	add    $0x10,%esp
  800731:	eb 0d                	jmp    800740 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  800733:	83 ec 08             	sub    $0x8,%esp
  800736:	ff 75 0c             	pushl  0xc(%ebp)
  800739:	52                   	push   %edx
  80073a:	ff 55 08             	call   *0x8(%ebp)
  80073d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800740:	83 eb 01             	sub    $0x1,%ebx
  800743:	eb 1a                	jmp    80075f <vprintfmt+0x24a>
  800745:	89 75 08             	mov    %esi,0x8(%ebp)
  800748:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80074b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80074e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800751:	eb 0c                	jmp    80075f <vprintfmt+0x24a>
  800753:	89 75 08             	mov    %esi,0x8(%ebp)
  800756:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800759:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80075c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80075f:	83 c7 01             	add    $0x1,%edi
  800762:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800766:	0f be d0             	movsbl %al,%edx
  800769:	85 d2                	test   %edx,%edx
  80076b:	74 23                	je     800790 <vprintfmt+0x27b>
  80076d:	85 f6                	test   %esi,%esi
  80076f:	78 a1                	js     800712 <vprintfmt+0x1fd>
  800771:	83 ee 01             	sub    $0x1,%esi
  800774:	79 9c                	jns    800712 <vprintfmt+0x1fd>
  800776:	89 df                	mov    %ebx,%edi
  800778:	8b 75 08             	mov    0x8(%ebp),%esi
  80077b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80077e:	eb 18                	jmp    800798 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800780:	83 ec 08             	sub    $0x8,%esp
  800783:	53                   	push   %ebx
  800784:	6a 20                	push   $0x20
  800786:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800788:	83 ef 01             	sub    $0x1,%edi
  80078b:	83 c4 10             	add    $0x10,%esp
  80078e:	eb 08                	jmp    800798 <vprintfmt+0x283>
  800790:	89 df                	mov    %ebx,%edi
  800792:	8b 75 08             	mov    0x8(%ebp),%esi
  800795:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800798:	85 ff                	test   %edi,%edi
  80079a:	7f e4                	jg     800780 <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80079f:	e9 a2 fd ff ff       	jmp    800546 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a4:	83 fa 01             	cmp    $0x1,%edx
  8007a7:	7e 16                	jle    8007bf <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8007a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ac:	8d 50 08             	lea    0x8(%eax),%edx
  8007af:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b2:	8b 50 04             	mov    0x4(%eax),%edx
  8007b5:	8b 00                	mov    (%eax),%eax
  8007b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ba:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007bd:	eb 32                	jmp    8007f1 <vprintfmt+0x2dc>
	else if (lflag)
  8007bf:	85 d2                	test   %edx,%edx
  8007c1:	74 18                	je     8007db <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	8d 50 04             	lea    0x4(%eax),%edx
  8007c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cc:	8b 00                	mov    (%eax),%eax
  8007ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d1:	89 c1                	mov    %eax,%ecx
  8007d3:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007d9:	eb 16                	jmp    8007f1 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  8007db:	8b 45 14             	mov    0x14(%ebp),%eax
  8007de:	8d 50 04             	lea    0x4(%eax),%edx
  8007e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e4:	8b 00                	mov    (%eax),%eax
  8007e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e9:	89 c1                	mov    %eax,%ecx
  8007eb:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ee:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007f4:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007f7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007fc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800800:	79 74                	jns    800876 <vprintfmt+0x361>
				putch('-', putdat);
  800802:	83 ec 08             	sub    $0x8,%esp
  800805:	53                   	push   %ebx
  800806:	6a 2d                	push   $0x2d
  800808:	ff d6                	call   *%esi
				num = -(long long) num;
  80080a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80080d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800810:	f7 d8                	neg    %eax
  800812:	83 d2 00             	adc    $0x0,%edx
  800815:	f7 da                	neg    %edx
  800817:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80081a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80081f:	eb 55                	jmp    800876 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800821:	8d 45 14             	lea    0x14(%ebp),%eax
  800824:	e8 78 fc ff ff       	call   8004a1 <getuint>
			base = 10;
  800829:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80082e:	eb 46                	jmp    800876 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800830:	8d 45 14             	lea    0x14(%ebp),%eax
  800833:	e8 69 fc ff ff       	call   8004a1 <getuint>
      base = 8;
  800838:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  80083d:	eb 37                	jmp    800876 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  80083f:	83 ec 08             	sub    $0x8,%esp
  800842:	53                   	push   %ebx
  800843:	6a 30                	push   $0x30
  800845:	ff d6                	call   *%esi
			putch('x', putdat);
  800847:	83 c4 08             	add    $0x8,%esp
  80084a:	53                   	push   %ebx
  80084b:	6a 78                	push   $0x78
  80084d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80084f:	8b 45 14             	mov    0x14(%ebp),%eax
  800852:	8d 50 04             	lea    0x4(%eax),%edx
  800855:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800858:	8b 00                	mov    (%eax),%eax
  80085a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80085f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800862:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800867:	eb 0d                	jmp    800876 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800869:	8d 45 14             	lea    0x14(%ebp),%eax
  80086c:	e8 30 fc ff ff       	call   8004a1 <getuint>
			base = 16;
  800871:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800876:	83 ec 0c             	sub    $0xc,%esp
  800879:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80087d:	57                   	push   %edi
  80087e:	ff 75 e0             	pushl  -0x20(%ebp)
  800881:	51                   	push   %ecx
  800882:	52                   	push   %edx
  800883:	50                   	push   %eax
  800884:	89 da                	mov    %ebx,%edx
  800886:	89 f0                	mov    %esi,%eax
  800888:	e8 65 fb ff ff       	call   8003f2 <printnum>
			break;
  80088d:	83 c4 20             	add    $0x20,%esp
  800890:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800893:	e9 ae fc ff ff       	jmp    800546 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	53                   	push   %ebx
  80089c:	51                   	push   %ecx
  80089d:	ff d6                	call   *%esi
			break;
  80089f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008a5:	e9 9c fc ff ff       	jmp    800546 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008aa:	83 fa 01             	cmp    $0x1,%edx
  8008ad:	7e 0d                	jle    8008bc <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8008af:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b2:	8d 50 08             	lea    0x8(%eax),%edx
  8008b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b8:	8b 00                	mov    (%eax),%eax
  8008ba:	eb 1c                	jmp    8008d8 <vprintfmt+0x3c3>
	else if (lflag)
  8008bc:	85 d2                	test   %edx,%edx
  8008be:	74 0d                	je     8008cd <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  8008c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c3:	8d 50 04             	lea    0x4(%eax),%edx
  8008c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c9:	8b 00                	mov    (%eax),%eax
  8008cb:	eb 0b                	jmp    8008d8 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  8008cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d0:	8d 50 04             	lea    0x4(%eax),%edx
  8008d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d6:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  8008d8:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  8008e0:	e9 61 fc ff ff       	jmp    800546 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008e5:	83 ec 08             	sub    $0x8,%esp
  8008e8:	53                   	push   %ebx
  8008e9:	6a 25                	push   $0x25
  8008eb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ed:	83 c4 10             	add    $0x10,%esp
  8008f0:	eb 03                	jmp    8008f5 <vprintfmt+0x3e0>
  8008f2:	83 ef 01             	sub    $0x1,%edi
  8008f5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008f9:	75 f7                	jne    8008f2 <vprintfmt+0x3dd>
  8008fb:	e9 46 fc ff ff       	jmp    800546 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  800900:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800903:	5b                   	pop    %ebx
  800904:	5e                   	pop    %esi
  800905:	5f                   	pop    %edi
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	83 ec 18             	sub    $0x18,%esp
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800914:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800917:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80091b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80091e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800925:	85 c0                	test   %eax,%eax
  800927:	74 26                	je     80094f <vsnprintf+0x47>
  800929:	85 d2                	test   %edx,%edx
  80092b:	7e 22                	jle    80094f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80092d:	ff 75 14             	pushl  0x14(%ebp)
  800930:	ff 75 10             	pushl  0x10(%ebp)
  800933:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800936:	50                   	push   %eax
  800937:	68 db 04 80 00       	push   $0x8004db
  80093c:	e8 d4 fb ff ff       	call   800515 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800941:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800944:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800947:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094a:	83 c4 10             	add    $0x10,%esp
  80094d:	eb 05                	jmp    800954 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80094f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800954:	c9                   	leave  
  800955:	c3                   	ret    

00800956 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80095c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80095f:	50                   	push   %eax
  800960:	ff 75 10             	pushl  0x10(%ebp)
  800963:	ff 75 0c             	pushl  0xc(%ebp)
  800966:	ff 75 08             	pushl  0x8(%ebp)
  800969:	e8 9a ff ff ff       	call   800908 <vsnprintf>
	va_end(ap);

	return rc;
}
  80096e:	c9                   	leave  
  80096f:	c3                   	ret    

00800970 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
  80097b:	eb 03                	jmp    800980 <strlen+0x10>
		n++;
  80097d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800980:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800984:	75 f7                	jne    80097d <strlen+0xd>
		n++;
	return n;
}
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800991:	ba 00 00 00 00       	mov    $0x0,%edx
  800996:	eb 03                	jmp    80099b <strnlen+0x13>
		n++;
  800998:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80099b:	39 c2                	cmp    %eax,%edx
  80099d:	74 08                	je     8009a7 <strnlen+0x1f>
  80099f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009a3:	75 f3                	jne    800998 <strnlen+0x10>
  8009a5:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	53                   	push   %ebx
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009b3:	89 c2                	mov    %eax,%edx
  8009b5:	83 c2 01             	add    $0x1,%edx
  8009b8:	83 c1 01             	add    $0x1,%ecx
  8009bb:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009bf:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009c2:	84 db                	test   %bl,%bl
  8009c4:	75 ef                	jne    8009b5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009c6:	5b                   	pop    %ebx
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	53                   	push   %ebx
  8009cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009d0:	53                   	push   %ebx
  8009d1:	e8 9a ff ff ff       	call   800970 <strlen>
  8009d6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009d9:	ff 75 0c             	pushl  0xc(%ebp)
  8009dc:	01 d8                	add    %ebx,%eax
  8009de:	50                   	push   %eax
  8009df:	e8 c5 ff ff ff       	call   8009a9 <strcpy>
	return dst;
}
  8009e4:	89 d8                	mov    %ebx,%eax
  8009e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e9:	c9                   	leave  
  8009ea:	c3                   	ret    

008009eb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	56                   	push   %esi
  8009ef:	53                   	push   %ebx
  8009f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f6:	89 f3                	mov    %esi,%ebx
  8009f8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009fb:	89 f2                	mov    %esi,%edx
  8009fd:	eb 0f                	jmp    800a0e <strncpy+0x23>
		*dst++ = *src;
  8009ff:	83 c2 01             	add    $0x1,%edx
  800a02:	0f b6 01             	movzbl (%ecx),%eax
  800a05:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a08:	80 39 01             	cmpb   $0x1,(%ecx)
  800a0b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a0e:	39 da                	cmp    %ebx,%edx
  800a10:	75 ed                	jne    8009ff <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a12:	89 f0                	mov    %esi,%eax
  800a14:	5b                   	pop    %ebx
  800a15:	5e                   	pop    %esi
  800a16:	5d                   	pop    %ebp
  800a17:	c3                   	ret    

00800a18 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
  800a1d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a23:	8b 55 10             	mov    0x10(%ebp),%edx
  800a26:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a28:	85 d2                	test   %edx,%edx
  800a2a:	74 21                	je     800a4d <strlcpy+0x35>
  800a2c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a30:	89 f2                	mov    %esi,%edx
  800a32:	eb 09                	jmp    800a3d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a34:	83 c2 01             	add    $0x1,%edx
  800a37:	83 c1 01             	add    $0x1,%ecx
  800a3a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a3d:	39 c2                	cmp    %eax,%edx
  800a3f:	74 09                	je     800a4a <strlcpy+0x32>
  800a41:	0f b6 19             	movzbl (%ecx),%ebx
  800a44:	84 db                	test   %bl,%bl
  800a46:	75 ec                	jne    800a34 <strlcpy+0x1c>
  800a48:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a4a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a4d:	29 f0                	sub    %esi,%eax
}
  800a4f:	5b                   	pop    %ebx
  800a50:	5e                   	pop    %esi
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a59:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a5c:	eb 06                	jmp    800a64 <strcmp+0x11>
		p++, q++;
  800a5e:	83 c1 01             	add    $0x1,%ecx
  800a61:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a64:	0f b6 01             	movzbl (%ecx),%eax
  800a67:	84 c0                	test   %al,%al
  800a69:	74 04                	je     800a6f <strcmp+0x1c>
  800a6b:	3a 02                	cmp    (%edx),%al
  800a6d:	74 ef                	je     800a5e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a6f:	0f b6 c0             	movzbl %al,%eax
  800a72:	0f b6 12             	movzbl (%edx),%edx
  800a75:	29 d0                	sub    %edx,%eax
}
  800a77:	5d                   	pop    %ebp
  800a78:	c3                   	ret    

00800a79 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	53                   	push   %ebx
  800a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a80:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a83:	89 c3                	mov    %eax,%ebx
  800a85:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a88:	eb 06                	jmp    800a90 <strncmp+0x17>
		n--, p++, q++;
  800a8a:	83 c0 01             	add    $0x1,%eax
  800a8d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a90:	39 d8                	cmp    %ebx,%eax
  800a92:	74 15                	je     800aa9 <strncmp+0x30>
  800a94:	0f b6 08             	movzbl (%eax),%ecx
  800a97:	84 c9                	test   %cl,%cl
  800a99:	74 04                	je     800a9f <strncmp+0x26>
  800a9b:	3a 0a                	cmp    (%edx),%cl
  800a9d:	74 eb                	je     800a8a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a9f:	0f b6 00             	movzbl (%eax),%eax
  800aa2:	0f b6 12             	movzbl (%edx),%edx
  800aa5:	29 d0                	sub    %edx,%eax
  800aa7:	eb 05                	jmp    800aae <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aa9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aae:	5b                   	pop    %ebx
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800abb:	eb 07                	jmp    800ac4 <strchr+0x13>
		if (*s == c)
  800abd:	38 ca                	cmp    %cl,%dl
  800abf:	74 0f                	je     800ad0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ac1:	83 c0 01             	add    $0x1,%eax
  800ac4:	0f b6 10             	movzbl (%eax),%edx
  800ac7:	84 d2                	test   %dl,%dl
  800ac9:	75 f2                	jne    800abd <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800acb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800adc:	eb 03                	jmp    800ae1 <strfind+0xf>
  800ade:	83 c0 01             	add    $0x1,%eax
  800ae1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ae4:	38 ca                	cmp    %cl,%dl
  800ae6:	74 04                	je     800aec <strfind+0x1a>
  800ae8:	84 d2                	test   %dl,%dl
  800aea:	75 f2                	jne    800ade <strfind+0xc>
			break;
	return (char *) s;
}
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
  800af4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800af7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800afa:	85 c9                	test   %ecx,%ecx
  800afc:	74 36                	je     800b34 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800afe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b04:	75 28                	jne    800b2e <memset+0x40>
  800b06:	f6 c1 03             	test   $0x3,%cl
  800b09:	75 23                	jne    800b2e <memset+0x40>
		c &= 0xFF;
  800b0b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b0f:	89 d3                	mov    %edx,%ebx
  800b11:	c1 e3 08             	shl    $0x8,%ebx
  800b14:	89 d6                	mov    %edx,%esi
  800b16:	c1 e6 18             	shl    $0x18,%esi
  800b19:	89 d0                	mov    %edx,%eax
  800b1b:	c1 e0 10             	shl    $0x10,%eax
  800b1e:	09 f0                	or     %esi,%eax
  800b20:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b22:	89 d8                	mov    %ebx,%eax
  800b24:	09 d0                	or     %edx,%eax
  800b26:	c1 e9 02             	shr    $0x2,%ecx
  800b29:	fc                   	cld    
  800b2a:	f3 ab                	rep stos %eax,%es:(%edi)
  800b2c:	eb 06                	jmp    800b34 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b31:	fc                   	cld    
  800b32:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b34:	89 f8                	mov    %edi,%eax
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	8b 45 08             	mov    0x8(%ebp),%eax
  800b43:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b46:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b49:	39 c6                	cmp    %eax,%esi
  800b4b:	73 35                	jae    800b82 <memmove+0x47>
  800b4d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b50:	39 d0                	cmp    %edx,%eax
  800b52:	73 2e                	jae    800b82 <memmove+0x47>
		s += n;
		d += n;
  800b54:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b57:	89 d6                	mov    %edx,%esi
  800b59:	09 fe                	or     %edi,%esi
  800b5b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b61:	75 13                	jne    800b76 <memmove+0x3b>
  800b63:	f6 c1 03             	test   $0x3,%cl
  800b66:	75 0e                	jne    800b76 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b68:	83 ef 04             	sub    $0x4,%edi
  800b6b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b6e:	c1 e9 02             	shr    $0x2,%ecx
  800b71:	fd                   	std    
  800b72:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b74:	eb 09                	jmp    800b7f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b76:	83 ef 01             	sub    $0x1,%edi
  800b79:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b7c:	fd                   	std    
  800b7d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b7f:	fc                   	cld    
  800b80:	eb 1d                	jmp    800b9f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b82:	89 f2                	mov    %esi,%edx
  800b84:	09 c2                	or     %eax,%edx
  800b86:	f6 c2 03             	test   $0x3,%dl
  800b89:	75 0f                	jne    800b9a <memmove+0x5f>
  800b8b:	f6 c1 03             	test   $0x3,%cl
  800b8e:	75 0a                	jne    800b9a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b90:	c1 e9 02             	shr    $0x2,%ecx
  800b93:	89 c7                	mov    %eax,%edi
  800b95:	fc                   	cld    
  800b96:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b98:	eb 05                	jmp    800b9f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b9a:	89 c7                	mov    %eax,%edi
  800b9c:	fc                   	cld    
  800b9d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ba6:	ff 75 10             	pushl  0x10(%ebp)
  800ba9:	ff 75 0c             	pushl  0xc(%ebp)
  800bac:	ff 75 08             	pushl  0x8(%ebp)
  800baf:	e8 87 ff ff ff       	call   800b3b <memmove>
}
  800bb4:	c9                   	leave  
  800bb5:	c3                   	ret    

00800bb6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	56                   	push   %esi
  800bba:	53                   	push   %ebx
  800bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bc1:	89 c6                	mov    %eax,%esi
  800bc3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc6:	eb 1a                	jmp    800be2 <memcmp+0x2c>
		if (*s1 != *s2)
  800bc8:	0f b6 08             	movzbl (%eax),%ecx
  800bcb:	0f b6 1a             	movzbl (%edx),%ebx
  800bce:	38 d9                	cmp    %bl,%cl
  800bd0:	74 0a                	je     800bdc <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bd2:	0f b6 c1             	movzbl %cl,%eax
  800bd5:	0f b6 db             	movzbl %bl,%ebx
  800bd8:	29 d8                	sub    %ebx,%eax
  800bda:	eb 0f                	jmp    800beb <memcmp+0x35>
		s1++, s2++;
  800bdc:	83 c0 01             	add    $0x1,%eax
  800bdf:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be2:	39 f0                	cmp    %esi,%eax
  800be4:	75 e2                	jne    800bc8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800be6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	53                   	push   %ebx
  800bf3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bf6:	89 c1                	mov    %eax,%ecx
  800bf8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bfb:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bff:	eb 0a                	jmp    800c0b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c01:	0f b6 10             	movzbl (%eax),%edx
  800c04:	39 da                	cmp    %ebx,%edx
  800c06:	74 07                	je     800c0f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c08:	83 c0 01             	add    $0x1,%eax
  800c0b:	39 c8                	cmp    %ecx,%eax
  800c0d:	72 f2                	jb     800c01 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c0f:	5b                   	pop    %ebx
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c1e:	eb 03                	jmp    800c23 <strtol+0x11>
		s++;
  800c20:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c23:	0f b6 01             	movzbl (%ecx),%eax
  800c26:	3c 20                	cmp    $0x20,%al
  800c28:	74 f6                	je     800c20 <strtol+0xe>
  800c2a:	3c 09                	cmp    $0x9,%al
  800c2c:	74 f2                	je     800c20 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c2e:	3c 2b                	cmp    $0x2b,%al
  800c30:	75 0a                	jne    800c3c <strtol+0x2a>
		s++;
  800c32:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c35:	bf 00 00 00 00       	mov    $0x0,%edi
  800c3a:	eb 11                	jmp    800c4d <strtol+0x3b>
  800c3c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c41:	3c 2d                	cmp    $0x2d,%al
  800c43:	75 08                	jne    800c4d <strtol+0x3b>
		s++, neg = 1;
  800c45:	83 c1 01             	add    $0x1,%ecx
  800c48:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c4d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c53:	75 15                	jne    800c6a <strtol+0x58>
  800c55:	80 39 30             	cmpb   $0x30,(%ecx)
  800c58:	75 10                	jne    800c6a <strtol+0x58>
  800c5a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c5e:	75 7c                	jne    800cdc <strtol+0xca>
		s += 2, base = 16;
  800c60:	83 c1 02             	add    $0x2,%ecx
  800c63:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c68:	eb 16                	jmp    800c80 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c6a:	85 db                	test   %ebx,%ebx
  800c6c:	75 12                	jne    800c80 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c6e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c73:	80 39 30             	cmpb   $0x30,(%ecx)
  800c76:	75 08                	jne    800c80 <strtol+0x6e>
		s++, base = 8;
  800c78:	83 c1 01             	add    $0x1,%ecx
  800c7b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c80:	b8 00 00 00 00       	mov    $0x0,%eax
  800c85:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c88:	0f b6 11             	movzbl (%ecx),%edx
  800c8b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c8e:	89 f3                	mov    %esi,%ebx
  800c90:	80 fb 09             	cmp    $0x9,%bl
  800c93:	77 08                	ja     800c9d <strtol+0x8b>
			dig = *s - '0';
  800c95:	0f be d2             	movsbl %dl,%edx
  800c98:	83 ea 30             	sub    $0x30,%edx
  800c9b:	eb 22                	jmp    800cbf <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c9d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ca0:	89 f3                	mov    %esi,%ebx
  800ca2:	80 fb 19             	cmp    $0x19,%bl
  800ca5:	77 08                	ja     800caf <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ca7:	0f be d2             	movsbl %dl,%edx
  800caa:	83 ea 57             	sub    $0x57,%edx
  800cad:	eb 10                	jmp    800cbf <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800caf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cb2:	89 f3                	mov    %esi,%ebx
  800cb4:	80 fb 19             	cmp    $0x19,%bl
  800cb7:	77 16                	ja     800ccf <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cb9:	0f be d2             	movsbl %dl,%edx
  800cbc:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cbf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cc2:	7d 0b                	jge    800ccf <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cc4:	83 c1 01             	add    $0x1,%ecx
  800cc7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ccb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ccd:	eb b9                	jmp    800c88 <strtol+0x76>

	if (endptr)
  800ccf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cd3:	74 0d                	je     800ce2 <strtol+0xd0>
		*endptr = (char *) s;
  800cd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd8:	89 0e                	mov    %ecx,(%esi)
  800cda:	eb 06                	jmp    800ce2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cdc:	85 db                	test   %ebx,%ebx
  800cde:	74 98                	je     800c78 <strtol+0x66>
  800ce0:	eb 9e                	jmp    800c80 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ce2:	89 c2                	mov    %eax,%edx
  800ce4:	f7 da                	neg    %edx
  800ce6:	85 ff                	test   %edi,%edi
  800ce8:	0f 45 c2             	cmovne %edx,%eax
}
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <__udivdi3>:
  800cf0:	55                   	push   %ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 1c             	sub    $0x1c,%esp
  800cf7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800cfb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800cff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d07:	85 f6                	test   %esi,%esi
  800d09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d0d:	89 ca                	mov    %ecx,%edx
  800d0f:	89 f8                	mov    %edi,%eax
  800d11:	75 3d                	jne    800d50 <__udivdi3+0x60>
  800d13:	39 cf                	cmp    %ecx,%edi
  800d15:	0f 87 c5 00 00 00    	ja     800de0 <__udivdi3+0xf0>
  800d1b:	85 ff                	test   %edi,%edi
  800d1d:	89 fd                	mov    %edi,%ebp
  800d1f:	75 0b                	jne    800d2c <__udivdi3+0x3c>
  800d21:	b8 01 00 00 00       	mov    $0x1,%eax
  800d26:	31 d2                	xor    %edx,%edx
  800d28:	f7 f7                	div    %edi
  800d2a:	89 c5                	mov    %eax,%ebp
  800d2c:	89 c8                	mov    %ecx,%eax
  800d2e:	31 d2                	xor    %edx,%edx
  800d30:	f7 f5                	div    %ebp
  800d32:	89 c1                	mov    %eax,%ecx
  800d34:	89 d8                	mov    %ebx,%eax
  800d36:	89 cf                	mov    %ecx,%edi
  800d38:	f7 f5                	div    %ebp
  800d3a:	89 c3                	mov    %eax,%ebx
  800d3c:	89 d8                	mov    %ebx,%eax
  800d3e:	89 fa                	mov    %edi,%edx
  800d40:	83 c4 1c             	add    $0x1c,%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    
  800d48:	90                   	nop
  800d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d50:	39 ce                	cmp    %ecx,%esi
  800d52:	77 74                	ja     800dc8 <__udivdi3+0xd8>
  800d54:	0f bd fe             	bsr    %esi,%edi
  800d57:	83 f7 1f             	xor    $0x1f,%edi
  800d5a:	0f 84 98 00 00 00    	je     800df8 <__udivdi3+0x108>
  800d60:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d65:	89 f9                	mov    %edi,%ecx
  800d67:	89 c5                	mov    %eax,%ebp
  800d69:	29 fb                	sub    %edi,%ebx
  800d6b:	d3 e6                	shl    %cl,%esi
  800d6d:	89 d9                	mov    %ebx,%ecx
  800d6f:	d3 ed                	shr    %cl,%ebp
  800d71:	89 f9                	mov    %edi,%ecx
  800d73:	d3 e0                	shl    %cl,%eax
  800d75:	09 ee                	or     %ebp,%esi
  800d77:	89 d9                	mov    %ebx,%ecx
  800d79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d7d:	89 d5                	mov    %edx,%ebp
  800d7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d83:	d3 ed                	shr    %cl,%ebp
  800d85:	89 f9                	mov    %edi,%ecx
  800d87:	d3 e2                	shl    %cl,%edx
  800d89:	89 d9                	mov    %ebx,%ecx
  800d8b:	d3 e8                	shr    %cl,%eax
  800d8d:	09 c2                	or     %eax,%edx
  800d8f:	89 d0                	mov    %edx,%eax
  800d91:	89 ea                	mov    %ebp,%edx
  800d93:	f7 f6                	div    %esi
  800d95:	89 d5                	mov    %edx,%ebp
  800d97:	89 c3                	mov    %eax,%ebx
  800d99:	f7 64 24 0c          	mull   0xc(%esp)
  800d9d:	39 d5                	cmp    %edx,%ebp
  800d9f:	72 10                	jb     800db1 <__udivdi3+0xc1>
  800da1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800da5:	89 f9                	mov    %edi,%ecx
  800da7:	d3 e6                	shl    %cl,%esi
  800da9:	39 c6                	cmp    %eax,%esi
  800dab:	73 07                	jae    800db4 <__udivdi3+0xc4>
  800dad:	39 d5                	cmp    %edx,%ebp
  800daf:	75 03                	jne    800db4 <__udivdi3+0xc4>
  800db1:	83 eb 01             	sub    $0x1,%ebx
  800db4:	31 ff                	xor    %edi,%edi
  800db6:	89 d8                	mov    %ebx,%eax
  800db8:	89 fa                	mov    %edi,%edx
  800dba:	83 c4 1c             	add    $0x1c,%esp
  800dbd:	5b                   	pop    %ebx
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    
  800dc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800dc8:	31 ff                	xor    %edi,%edi
  800dca:	31 db                	xor    %ebx,%ebx
  800dcc:	89 d8                	mov    %ebx,%eax
  800dce:	89 fa                	mov    %edi,%edx
  800dd0:	83 c4 1c             	add    $0x1c,%esp
  800dd3:	5b                   	pop    %ebx
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    
  800dd8:	90                   	nop
  800dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800de0:	89 d8                	mov    %ebx,%eax
  800de2:	f7 f7                	div    %edi
  800de4:	31 ff                	xor    %edi,%edi
  800de6:	89 c3                	mov    %eax,%ebx
  800de8:	89 d8                	mov    %ebx,%eax
  800dea:	89 fa                	mov    %edi,%edx
  800dec:	83 c4 1c             	add    $0x1c,%esp
  800def:	5b                   	pop    %ebx
  800df0:	5e                   	pop    %esi
  800df1:	5f                   	pop    %edi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    
  800df4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800df8:	39 ce                	cmp    %ecx,%esi
  800dfa:	72 0c                	jb     800e08 <__udivdi3+0x118>
  800dfc:	31 db                	xor    %ebx,%ebx
  800dfe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e02:	0f 87 34 ff ff ff    	ja     800d3c <__udivdi3+0x4c>
  800e08:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e0d:	e9 2a ff ff ff       	jmp    800d3c <__udivdi3+0x4c>
  800e12:	66 90                	xchg   %ax,%ax
  800e14:	66 90                	xchg   %ax,%ax
  800e16:	66 90                	xchg   %ax,%ax
  800e18:	66 90                	xchg   %ax,%ax
  800e1a:	66 90                	xchg   %ax,%ax
  800e1c:	66 90                	xchg   %ax,%ax
  800e1e:	66 90                	xchg   %ax,%ax

00800e20 <__umoddi3>:
  800e20:	55                   	push   %ebp
  800e21:	57                   	push   %edi
  800e22:	56                   	push   %esi
  800e23:	53                   	push   %ebx
  800e24:	83 ec 1c             	sub    $0x1c,%esp
  800e27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e37:	85 d2                	test   %edx,%edx
  800e39:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e41:	89 f3                	mov    %esi,%ebx
  800e43:	89 3c 24             	mov    %edi,(%esp)
  800e46:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e4a:	75 1c                	jne    800e68 <__umoddi3+0x48>
  800e4c:	39 f7                	cmp    %esi,%edi
  800e4e:	76 50                	jbe    800ea0 <__umoddi3+0x80>
  800e50:	89 c8                	mov    %ecx,%eax
  800e52:	89 f2                	mov    %esi,%edx
  800e54:	f7 f7                	div    %edi
  800e56:	89 d0                	mov    %edx,%eax
  800e58:	31 d2                	xor    %edx,%edx
  800e5a:	83 c4 1c             	add    $0x1c,%esp
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5f                   	pop    %edi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    
  800e62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e68:	39 f2                	cmp    %esi,%edx
  800e6a:	89 d0                	mov    %edx,%eax
  800e6c:	77 52                	ja     800ec0 <__umoddi3+0xa0>
  800e6e:	0f bd ea             	bsr    %edx,%ebp
  800e71:	83 f5 1f             	xor    $0x1f,%ebp
  800e74:	75 5a                	jne    800ed0 <__umoddi3+0xb0>
  800e76:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800e7a:	0f 82 e0 00 00 00    	jb     800f60 <__umoddi3+0x140>
  800e80:	39 0c 24             	cmp    %ecx,(%esp)
  800e83:	0f 86 d7 00 00 00    	jbe    800f60 <__umoddi3+0x140>
  800e89:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e8d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e91:	83 c4 1c             	add    $0x1c,%esp
  800e94:	5b                   	pop    %ebx
  800e95:	5e                   	pop    %esi
  800e96:	5f                   	pop    %edi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    
  800e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	85 ff                	test   %edi,%edi
  800ea2:	89 fd                	mov    %edi,%ebp
  800ea4:	75 0b                	jne    800eb1 <__umoddi3+0x91>
  800ea6:	b8 01 00 00 00       	mov    $0x1,%eax
  800eab:	31 d2                	xor    %edx,%edx
  800ead:	f7 f7                	div    %edi
  800eaf:	89 c5                	mov    %eax,%ebp
  800eb1:	89 f0                	mov    %esi,%eax
  800eb3:	31 d2                	xor    %edx,%edx
  800eb5:	f7 f5                	div    %ebp
  800eb7:	89 c8                	mov    %ecx,%eax
  800eb9:	f7 f5                	div    %ebp
  800ebb:	89 d0                	mov    %edx,%eax
  800ebd:	eb 99                	jmp    800e58 <__umoddi3+0x38>
  800ebf:	90                   	nop
  800ec0:	89 c8                	mov    %ecx,%eax
  800ec2:	89 f2                	mov    %esi,%edx
  800ec4:	83 c4 1c             	add    $0x1c,%esp
  800ec7:	5b                   	pop    %ebx
  800ec8:	5e                   	pop    %esi
  800ec9:	5f                   	pop    %edi
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    
  800ecc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	8b 34 24             	mov    (%esp),%esi
  800ed3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ed8:	89 e9                	mov    %ebp,%ecx
  800eda:	29 ef                	sub    %ebp,%edi
  800edc:	d3 e0                	shl    %cl,%eax
  800ede:	89 f9                	mov    %edi,%ecx
  800ee0:	89 f2                	mov    %esi,%edx
  800ee2:	d3 ea                	shr    %cl,%edx
  800ee4:	89 e9                	mov    %ebp,%ecx
  800ee6:	09 c2                	or     %eax,%edx
  800ee8:	89 d8                	mov    %ebx,%eax
  800eea:	89 14 24             	mov    %edx,(%esp)
  800eed:	89 f2                	mov    %esi,%edx
  800eef:	d3 e2                	shl    %cl,%edx
  800ef1:	89 f9                	mov    %edi,%ecx
  800ef3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ef7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800efb:	d3 e8                	shr    %cl,%eax
  800efd:	89 e9                	mov    %ebp,%ecx
  800eff:	89 c6                	mov    %eax,%esi
  800f01:	d3 e3                	shl    %cl,%ebx
  800f03:	89 f9                	mov    %edi,%ecx
  800f05:	89 d0                	mov    %edx,%eax
  800f07:	d3 e8                	shr    %cl,%eax
  800f09:	89 e9                	mov    %ebp,%ecx
  800f0b:	09 d8                	or     %ebx,%eax
  800f0d:	89 d3                	mov    %edx,%ebx
  800f0f:	89 f2                	mov    %esi,%edx
  800f11:	f7 34 24             	divl   (%esp)
  800f14:	89 d6                	mov    %edx,%esi
  800f16:	d3 e3                	shl    %cl,%ebx
  800f18:	f7 64 24 04          	mull   0x4(%esp)
  800f1c:	39 d6                	cmp    %edx,%esi
  800f1e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f22:	89 d1                	mov    %edx,%ecx
  800f24:	89 c3                	mov    %eax,%ebx
  800f26:	72 08                	jb     800f30 <__umoddi3+0x110>
  800f28:	75 11                	jne    800f3b <__umoddi3+0x11b>
  800f2a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f2e:	73 0b                	jae    800f3b <__umoddi3+0x11b>
  800f30:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f34:	1b 14 24             	sbb    (%esp),%edx
  800f37:	89 d1                	mov    %edx,%ecx
  800f39:	89 c3                	mov    %eax,%ebx
  800f3b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f3f:	29 da                	sub    %ebx,%edx
  800f41:	19 ce                	sbb    %ecx,%esi
  800f43:	89 f9                	mov    %edi,%ecx
  800f45:	89 f0                	mov    %esi,%eax
  800f47:	d3 e0                	shl    %cl,%eax
  800f49:	89 e9                	mov    %ebp,%ecx
  800f4b:	d3 ea                	shr    %cl,%edx
  800f4d:	89 e9                	mov    %ebp,%ecx
  800f4f:	d3 ee                	shr    %cl,%esi
  800f51:	09 d0                	or     %edx,%eax
  800f53:	89 f2                	mov    %esi,%edx
  800f55:	83 c4 1c             	add    $0x1c,%esp
  800f58:	5b                   	pop    %ebx
  800f59:	5e                   	pop    %esi
  800f5a:	5f                   	pop    %edi
  800f5b:	5d                   	pop    %ebp
  800f5c:	c3                   	ret    
  800f5d:	8d 76 00             	lea    0x0(%esi),%esi
  800f60:	29 f9                	sub    %edi,%ecx
  800f62:	19 d6                	sbb    %edx,%esi
  800f64:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f6c:	e9 18 ff ff ff       	jmp    800e89 <__umoddi3+0x69>
