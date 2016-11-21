
obj/user/faultbadhandler.debug:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 3a 01 00 00       	call   800181 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 ef be ad de       	push   $0xdeadbeef
  80004f:	6a 00                	push   $0x0
  800051:	e8 76 02 00 00       	call   8002cc <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800070:	e8 ce 00 00 00       	call   800143 <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b1:	e8 87 04 00 00       	call   80053d <close_all>
	sys_env_destroy(0);
  8000b6:	83 ec 0c             	sub    $0xc,%esp
  8000b9:	6a 00                	push   $0x0
  8000bb:	e8 42 00 00 00       	call   800102 <sys_env_destroy>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	57                   	push   %edi
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800110:	b8 03 00 00 00       	mov    $0x3,%eax
  800115:	8b 55 08             	mov    0x8(%ebp),%edx
  800118:	89 cb                	mov    %ecx,%ebx
  80011a:	89 cf                	mov    %ecx,%edi
  80011c:	89 ce                	mov    %ecx,%esi
  80011e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800120:	85 c0                	test   %eax,%eax
  800122:	7e 17                	jle    80013b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800124:	83 ec 0c             	sub    $0xc,%esp
  800127:	50                   	push   %eax
  800128:	6a 03                	push   $0x3
  80012a:	68 0a 1e 80 00       	push   $0x801e0a
  80012f:	6a 23                	push   $0x23
  800131:	68 27 1e 80 00       	push   $0x801e27
  800136:	e8 4a 0f 00 00       	call   801085 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	b8 04 00 00 00       	mov    $0x4,%eax
  800194:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800197:	8b 55 08             	mov    0x8(%ebp),%edx
  80019a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7e 17                	jle    8001bc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	83 ec 0c             	sub    $0xc,%esp
  8001a8:	50                   	push   %eax
  8001a9:	6a 04                	push   $0x4
  8001ab:	68 0a 1e 80 00       	push   $0x801e0a
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 27 1e 80 00       	push   $0x801e27
  8001b7:	e8 c9 0e 00 00       	call   801085 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    

008001c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001de:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001e3:	85 c0                	test   %eax,%eax
  8001e5:	7e 17                	jle    8001fe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	50                   	push   %eax
  8001eb:	6a 05                	push   $0x5
  8001ed:	68 0a 1e 80 00       	push   $0x801e0a
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 27 1e 80 00       	push   $0x801e27
  8001f9:	e8 87 0e 00 00       	call   801085 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    

00800206 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80020f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800214:	b8 06 00 00 00       	mov    $0x6,%eax
  800219:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021c:	8b 55 08             	mov    0x8(%ebp),%edx
  80021f:	89 df                	mov    %ebx,%edi
  800221:	89 de                	mov    %ebx,%esi
  800223:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800225:	85 c0                	test   %eax,%eax
  800227:	7e 17                	jle    800240 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800229:	83 ec 0c             	sub    $0xc,%esp
  80022c:	50                   	push   %eax
  80022d:	6a 06                	push   $0x6
  80022f:	68 0a 1e 80 00       	push   $0x801e0a
  800234:	6a 23                	push   $0x23
  800236:	68 27 1e 80 00       	push   $0x801e27
  80023b:	e8 45 0e 00 00       	call   801085 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800251:	bb 00 00 00 00       	mov    $0x0,%ebx
  800256:	b8 08 00 00 00       	mov    $0x8,%eax
  80025b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025e:	8b 55 08             	mov    0x8(%ebp),%edx
  800261:	89 df                	mov    %ebx,%edi
  800263:	89 de                	mov    %ebx,%esi
  800265:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800267:	85 c0                	test   %eax,%eax
  800269:	7e 17                	jle    800282 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026b:	83 ec 0c             	sub    $0xc,%esp
  80026e:	50                   	push   %eax
  80026f:	6a 08                	push   $0x8
  800271:	68 0a 1e 80 00       	push   $0x801e0a
  800276:	6a 23                	push   $0x23
  800278:	68 27 1e 80 00       	push   $0x801e27
  80027d:	e8 03 0e 00 00       	call   801085 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800293:	bb 00 00 00 00       	mov    $0x0,%ebx
  800298:	b8 09 00 00 00       	mov    $0x9,%eax
  80029d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a3:	89 df                	mov    %ebx,%edi
  8002a5:	89 de                	mov    %ebx,%esi
  8002a7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002a9:	85 c0                	test   %eax,%eax
  8002ab:	7e 17                	jle    8002c4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	50                   	push   %eax
  8002b1:	6a 09                	push   $0x9
  8002b3:	68 0a 1e 80 00       	push   $0x801e0a
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 27 1e 80 00       	push   $0x801e27
  8002bf:	e8 c1 0d 00 00       	call   801085 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e5:	89 df                	mov    %ebx,%edi
  8002e7:	89 de                	mov    %ebx,%esi
  8002e9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	7e 17                	jle    800306 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ef:	83 ec 0c             	sub    $0xc,%esp
  8002f2:	50                   	push   %eax
  8002f3:	6a 0a                	push   $0xa
  8002f5:	68 0a 1e 80 00       	push   $0x801e0a
  8002fa:	6a 23                	push   $0x23
  8002fc:	68 27 1e 80 00       	push   $0x801e27
  800301:	e8 7f 0d 00 00       	call   801085 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800306:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800314:	be 00 00 00 00       	mov    $0x0,%esi
  800319:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800327:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800344:	8b 55 08             	mov    0x8(%ebp),%edx
  800347:	89 cb                	mov    %ecx,%ebx
  800349:	89 cf                	mov    %ecx,%edi
  80034b:	89 ce                	mov    %ecx,%esi
  80034d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80034f:	85 c0                	test   %eax,%eax
  800351:	7e 17                	jle    80036a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	50                   	push   %eax
  800357:	6a 0d                	push   $0xd
  800359:	68 0a 1e 80 00       	push   $0x801e0a
  80035e:	6a 23                	push   $0x23
  800360:	68 27 1e 80 00       	push   $0x801e27
  800365:	e8 1b 0d 00 00       	call   801085 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036d:	5b                   	pop    %ebx
  80036e:	5e                   	pop    %esi
  80036f:	5f                   	pop    %edi
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800375:	8b 45 08             	mov    0x8(%ebp),%eax
  800378:	05 00 00 00 30       	add    $0x30000000,%eax
  80037d:	c1 e8 0c             	shr    $0xc,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	05 00 00 00 30       	add    $0x30000000,%eax
  80038d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800392:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a4:	89 c2                	mov    %eax,%edx
  8003a6:	c1 ea 16             	shr    $0x16,%edx
  8003a9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b0:	f6 c2 01             	test   $0x1,%dl
  8003b3:	74 11                	je     8003c6 <fd_alloc+0x2d>
  8003b5:	89 c2                	mov    %eax,%edx
  8003b7:	c1 ea 0c             	shr    $0xc,%edx
  8003ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c1:	f6 c2 01             	test   $0x1,%dl
  8003c4:	75 09                	jne    8003cf <fd_alloc+0x36>
			*fd_store = fd;
  8003c6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cd:	eb 17                	jmp    8003e6 <fd_alloc+0x4d>
  8003cf:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003d9:	75 c9                	jne    8003a4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003db:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003e1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    

008003e8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ee:	83 f8 1f             	cmp    $0x1f,%eax
  8003f1:	77 36                	ja     800429 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f3:	c1 e0 0c             	shl    $0xc,%eax
  8003f6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003fb:	89 c2                	mov    %eax,%edx
  8003fd:	c1 ea 16             	shr    $0x16,%edx
  800400:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800407:	f6 c2 01             	test   $0x1,%dl
  80040a:	74 24                	je     800430 <fd_lookup+0x48>
  80040c:	89 c2                	mov    %eax,%edx
  80040e:	c1 ea 0c             	shr    $0xc,%edx
  800411:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800418:	f6 c2 01             	test   $0x1,%dl
  80041b:	74 1a                	je     800437 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80041d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800420:	89 02                	mov    %eax,(%edx)
	return 0;
  800422:	b8 00 00 00 00       	mov    $0x0,%eax
  800427:	eb 13                	jmp    80043c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800429:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042e:	eb 0c                	jmp    80043c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800430:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800435:	eb 05                	jmp    80043c <fd_lookup+0x54>
  800437:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80043c:	5d                   	pop    %ebp
  80043d:	c3                   	ret    

0080043e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800447:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80044c:	eb 13                	jmp    800461 <dev_lookup+0x23>
  80044e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800451:	39 08                	cmp    %ecx,(%eax)
  800453:	75 0c                	jne    800461 <dev_lookup+0x23>
			*dev = devtab[i];
  800455:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800458:	89 01                	mov    %eax,(%ecx)
			return 0;
  80045a:	b8 00 00 00 00       	mov    $0x0,%eax
  80045f:	eb 2e                	jmp    80048f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800461:	8b 02                	mov    (%edx),%eax
  800463:	85 c0                	test   %eax,%eax
  800465:	75 e7                	jne    80044e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800467:	a1 04 40 80 00       	mov    0x804004,%eax
  80046c:	8b 40 48             	mov    0x48(%eax),%eax
  80046f:	83 ec 04             	sub    $0x4,%esp
  800472:	51                   	push   %ecx
  800473:	50                   	push   %eax
  800474:	68 38 1e 80 00       	push   $0x801e38
  800479:	e8 e0 0c 00 00       	call   80115e <cprintf>
	*dev = 0;
  80047e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800481:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80048f:	c9                   	leave  
  800490:	c3                   	ret    

00800491 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800491:	55                   	push   %ebp
  800492:	89 e5                	mov    %esp,%ebp
  800494:	56                   	push   %esi
  800495:	53                   	push   %ebx
  800496:	83 ec 10             	sub    $0x10,%esp
  800499:	8b 75 08             	mov    0x8(%ebp),%esi
  80049c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80049f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004a2:	50                   	push   %eax
  8004a3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004a9:	c1 e8 0c             	shr    $0xc,%eax
  8004ac:	50                   	push   %eax
  8004ad:	e8 36 ff ff ff       	call   8003e8 <fd_lookup>
  8004b2:	83 c4 08             	add    $0x8,%esp
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	78 05                	js     8004be <fd_close+0x2d>
	    || fd != fd2)
  8004b9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004bc:	74 0c                	je     8004ca <fd_close+0x39>
		return (must_exist ? r : 0);
  8004be:	84 db                	test   %bl,%bl
  8004c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c5:	0f 44 c2             	cmove  %edx,%eax
  8004c8:	eb 41                	jmp    80050b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004d0:	50                   	push   %eax
  8004d1:	ff 36                	pushl  (%esi)
  8004d3:	e8 66 ff ff ff       	call   80043e <dev_lookup>
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	78 1a                	js     8004fb <fd_close+0x6a>
		if (dev->dev_close)
  8004e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004e4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004e7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ec:	85 c0                	test   %eax,%eax
  8004ee:	74 0b                	je     8004fb <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004f0:	83 ec 0c             	sub    $0xc,%esp
  8004f3:	56                   	push   %esi
  8004f4:	ff d0                	call   *%eax
  8004f6:	89 c3                	mov    %eax,%ebx
  8004f8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	56                   	push   %esi
  8004ff:	6a 00                	push   $0x0
  800501:	e8 00 fd ff ff       	call   800206 <sys_page_unmap>
	return r;
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	89 d8                	mov    %ebx,%eax
}
  80050b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80050e:	5b                   	pop    %ebx
  80050f:	5e                   	pop    %esi
  800510:	5d                   	pop    %ebp
  800511:	c3                   	ret    

00800512 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800518:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80051b:	50                   	push   %eax
  80051c:	ff 75 08             	pushl  0x8(%ebp)
  80051f:	e8 c4 fe ff ff       	call   8003e8 <fd_lookup>
  800524:	83 c4 08             	add    $0x8,%esp
  800527:	85 c0                	test   %eax,%eax
  800529:	78 10                	js     80053b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	6a 01                	push   $0x1
  800530:	ff 75 f4             	pushl  -0xc(%ebp)
  800533:	e8 59 ff ff ff       	call   800491 <fd_close>
  800538:	83 c4 10             	add    $0x10,%esp
}
  80053b:	c9                   	leave  
  80053c:	c3                   	ret    

0080053d <close_all>:

void
close_all(void)
{
  80053d:	55                   	push   %ebp
  80053e:	89 e5                	mov    %esp,%ebp
  800540:	53                   	push   %ebx
  800541:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800544:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800549:	83 ec 0c             	sub    $0xc,%esp
  80054c:	53                   	push   %ebx
  80054d:	e8 c0 ff ff ff       	call   800512 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800552:	83 c3 01             	add    $0x1,%ebx
  800555:	83 c4 10             	add    $0x10,%esp
  800558:	83 fb 20             	cmp    $0x20,%ebx
  80055b:	75 ec                	jne    800549 <close_all+0xc>
		close(i);
}
  80055d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800560:	c9                   	leave  
  800561:	c3                   	ret    

00800562 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800562:	55                   	push   %ebp
  800563:	89 e5                	mov    %esp,%ebp
  800565:	57                   	push   %edi
  800566:	56                   	push   %esi
  800567:	53                   	push   %ebx
  800568:	83 ec 2c             	sub    $0x2c,%esp
  80056b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80056e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800571:	50                   	push   %eax
  800572:	ff 75 08             	pushl  0x8(%ebp)
  800575:	e8 6e fe ff ff       	call   8003e8 <fd_lookup>
  80057a:	83 c4 08             	add    $0x8,%esp
  80057d:	85 c0                	test   %eax,%eax
  80057f:	0f 88 c1 00 00 00    	js     800646 <dup+0xe4>
		return r;
	close(newfdnum);
  800585:	83 ec 0c             	sub    $0xc,%esp
  800588:	56                   	push   %esi
  800589:	e8 84 ff ff ff       	call   800512 <close>

	newfd = INDEX2FD(newfdnum);
  80058e:	89 f3                	mov    %esi,%ebx
  800590:	c1 e3 0c             	shl    $0xc,%ebx
  800593:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800599:	83 c4 04             	add    $0x4,%esp
  80059c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80059f:	e8 de fd ff ff       	call   800382 <fd2data>
  8005a4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005a6:	89 1c 24             	mov    %ebx,(%esp)
  8005a9:	e8 d4 fd ff ff       	call   800382 <fd2data>
  8005ae:	83 c4 10             	add    $0x10,%esp
  8005b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005b4:	89 f8                	mov    %edi,%eax
  8005b6:	c1 e8 16             	shr    $0x16,%eax
  8005b9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005c0:	a8 01                	test   $0x1,%al
  8005c2:	74 37                	je     8005fb <dup+0x99>
  8005c4:	89 f8                	mov    %edi,%eax
  8005c6:	c1 e8 0c             	shr    $0xc,%eax
  8005c9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005d0:	f6 c2 01             	test   $0x1,%dl
  8005d3:	74 26                	je     8005fb <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005dc:	83 ec 0c             	sub    $0xc,%esp
  8005df:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e4:	50                   	push   %eax
  8005e5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005e8:	6a 00                	push   $0x0
  8005ea:	57                   	push   %edi
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 d2 fb ff ff       	call   8001c4 <sys_page_map>
  8005f2:	89 c7                	mov    %eax,%edi
  8005f4:	83 c4 20             	add    $0x20,%esp
  8005f7:	85 c0                	test   %eax,%eax
  8005f9:	78 2e                	js     800629 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fe:	89 d0                	mov    %edx,%eax
  800600:	c1 e8 0c             	shr    $0xc,%eax
  800603:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060a:	83 ec 0c             	sub    $0xc,%esp
  80060d:	25 07 0e 00 00       	and    $0xe07,%eax
  800612:	50                   	push   %eax
  800613:	53                   	push   %ebx
  800614:	6a 00                	push   $0x0
  800616:	52                   	push   %edx
  800617:	6a 00                	push   $0x0
  800619:	e8 a6 fb ff ff       	call   8001c4 <sys_page_map>
  80061e:	89 c7                	mov    %eax,%edi
  800620:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800623:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800625:	85 ff                	test   %edi,%edi
  800627:	79 1d                	jns    800646 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	53                   	push   %ebx
  80062d:	6a 00                	push   $0x0
  80062f:	e8 d2 fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800634:	83 c4 08             	add    $0x8,%esp
  800637:	ff 75 d4             	pushl  -0x2c(%ebp)
  80063a:	6a 00                	push   $0x0
  80063c:	e8 c5 fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	89 f8                	mov    %edi,%eax
}
  800646:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800649:	5b                   	pop    %ebx
  80064a:	5e                   	pop    %esi
  80064b:	5f                   	pop    %edi
  80064c:	5d                   	pop    %ebp
  80064d:	c3                   	ret    

0080064e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80064e:	55                   	push   %ebp
  80064f:	89 e5                	mov    %esp,%ebp
  800651:	53                   	push   %ebx
  800652:	83 ec 14             	sub    $0x14,%esp
  800655:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800658:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80065b:	50                   	push   %eax
  80065c:	53                   	push   %ebx
  80065d:	e8 86 fd ff ff       	call   8003e8 <fd_lookup>
  800662:	83 c4 08             	add    $0x8,%esp
  800665:	89 c2                	mov    %eax,%edx
  800667:	85 c0                	test   %eax,%eax
  800669:	78 6d                	js     8006d8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800671:	50                   	push   %eax
  800672:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800675:	ff 30                	pushl  (%eax)
  800677:	e8 c2 fd ff ff       	call   80043e <dev_lookup>
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	85 c0                	test   %eax,%eax
  800681:	78 4c                	js     8006cf <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800683:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800686:	8b 42 08             	mov    0x8(%edx),%eax
  800689:	83 e0 03             	and    $0x3,%eax
  80068c:	83 f8 01             	cmp    $0x1,%eax
  80068f:	75 21                	jne    8006b2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800691:	a1 04 40 80 00       	mov    0x804004,%eax
  800696:	8b 40 48             	mov    0x48(%eax),%eax
  800699:	83 ec 04             	sub    $0x4,%esp
  80069c:	53                   	push   %ebx
  80069d:	50                   	push   %eax
  80069e:	68 79 1e 80 00       	push   $0x801e79
  8006a3:	e8 b6 0a 00 00       	call   80115e <cprintf>
		return -E_INVAL;
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006b0:	eb 26                	jmp    8006d8 <read+0x8a>
	}
	if (!dev->dev_read)
  8006b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b5:	8b 40 08             	mov    0x8(%eax),%eax
  8006b8:	85 c0                	test   %eax,%eax
  8006ba:	74 17                	je     8006d3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006bc:	83 ec 04             	sub    $0x4,%esp
  8006bf:	ff 75 10             	pushl  0x10(%ebp)
  8006c2:	ff 75 0c             	pushl  0xc(%ebp)
  8006c5:	52                   	push   %edx
  8006c6:	ff d0                	call   *%eax
  8006c8:	89 c2                	mov    %eax,%edx
  8006ca:	83 c4 10             	add    $0x10,%esp
  8006cd:	eb 09                	jmp    8006d8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006cf:	89 c2                	mov    %eax,%edx
  8006d1:	eb 05                	jmp    8006d8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006d3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006d8:	89 d0                	mov    %edx,%eax
  8006da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006dd:	c9                   	leave  
  8006de:	c3                   	ret    

008006df <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	57                   	push   %edi
  8006e3:	56                   	push   %esi
  8006e4:	53                   	push   %ebx
  8006e5:	83 ec 0c             	sub    $0xc,%esp
  8006e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006eb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f3:	eb 21                	jmp    800716 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f5:	83 ec 04             	sub    $0x4,%esp
  8006f8:	89 f0                	mov    %esi,%eax
  8006fa:	29 d8                	sub    %ebx,%eax
  8006fc:	50                   	push   %eax
  8006fd:	89 d8                	mov    %ebx,%eax
  8006ff:	03 45 0c             	add    0xc(%ebp),%eax
  800702:	50                   	push   %eax
  800703:	57                   	push   %edi
  800704:	e8 45 ff ff ff       	call   80064e <read>
		if (m < 0)
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	85 c0                	test   %eax,%eax
  80070e:	78 10                	js     800720 <readn+0x41>
			return m;
		if (m == 0)
  800710:	85 c0                	test   %eax,%eax
  800712:	74 0a                	je     80071e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800714:	01 c3                	add    %eax,%ebx
  800716:	39 f3                	cmp    %esi,%ebx
  800718:	72 db                	jb     8006f5 <readn+0x16>
  80071a:	89 d8                	mov    %ebx,%eax
  80071c:	eb 02                	jmp    800720 <readn+0x41>
  80071e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800720:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800723:	5b                   	pop    %ebx
  800724:	5e                   	pop    %esi
  800725:	5f                   	pop    %edi
  800726:	5d                   	pop    %ebp
  800727:	c3                   	ret    

00800728 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	53                   	push   %ebx
  80072c:	83 ec 14             	sub    $0x14,%esp
  80072f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800732:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800735:	50                   	push   %eax
  800736:	53                   	push   %ebx
  800737:	e8 ac fc ff ff       	call   8003e8 <fd_lookup>
  80073c:	83 c4 08             	add    $0x8,%esp
  80073f:	89 c2                	mov    %eax,%edx
  800741:	85 c0                	test   %eax,%eax
  800743:	78 68                	js     8007ad <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80074b:	50                   	push   %eax
  80074c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074f:	ff 30                	pushl  (%eax)
  800751:	e8 e8 fc ff ff       	call   80043e <dev_lookup>
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	85 c0                	test   %eax,%eax
  80075b:	78 47                	js     8007a4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80075d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800760:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800764:	75 21                	jne    800787 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800766:	a1 04 40 80 00       	mov    0x804004,%eax
  80076b:	8b 40 48             	mov    0x48(%eax),%eax
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	53                   	push   %ebx
  800772:	50                   	push   %eax
  800773:	68 95 1e 80 00       	push   $0x801e95
  800778:	e8 e1 09 00 00       	call   80115e <cprintf>
		return -E_INVAL;
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800785:	eb 26                	jmp    8007ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800787:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80078a:	8b 52 0c             	mov    0xc(%edx),%edx
  80078d:	85 d2                	test   %edx,%edx
  80078f:	74 17                	je     8007a8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800791:	83 ec 04             	sub    $0x4,%esp
  800794:	ff 75 10             	pushl  0x10(%ebp)
  800797:	ff 75 0c             	pushl  0xc(%ebp)
  80079a:	50                   	push   %eax
  80079b:	ff d2                	call   *%edx
  80079d:	89 c2                	mov    %eax,%edx
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	eb 09                	jmp    8007ad <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a4:	89 c2                	mov    %eax,%edx
  8007a6:	eb 05                	jmp    8007ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007ad:	89 d0                	mov    %edx,%eax
  8007af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ba:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007bd:	50                   	push   %eax
  8007be:	ff 75 08             	pushl  0x8(%ebp)
  8007c1:	e8 22 fc ff ff       	call   8003e8 <fd_lookup>
  8007c6:	83 c4 08             	add    $0x8,%esp
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	78 0e                	js     8007db <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    

008007dd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	53                   	push   %ebx
  8007e1:	83 ec 14             	sub    $0x14,%esp
  8007e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ea:	50                   	push   %eax
  8007eb:	53                   	push   %ebx
  8007ec:	e8 f7 fb ff ff       	call   8003e8 <fd_lookup>
  8007f1:	83 c4 08             	add    $0x8,%esp
  8007f4:	89 c2                	mov    %eax,%edx
  8007f6:	85 c0                	test   %eax,%eax
  8007f8:	78 65                	js     80085f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800800:	50                   	push   %eax
  800801:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800804:	ff 30                	pushl  (%eax)
  800806:	e8 33 fc ff ff       	call   80043e <dev_lookup>
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	85 c0                	test   %eax,%eax
  800810:	78 44                	js     800856 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800812:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800815:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800819:	75 21                	jne    80083c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80081b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800820:	8b 40 48             	mov    0x48(%eax),%eax
  800823:	83 ec 04             	sub    $0x4,%esp
  800826:	53                   	push   %ebx
  800827:	50                   	push   %eax
  800828:	68 58 1e 80 00       	push   $0x801e58
  80082d:	e8 2c 09 00 00       	call   80115e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800832:	83 c4 10             	add    $0x10,%esp
  800835:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80083a:	eb 23                	jmp    80085f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80083c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80083f:	8b 52 18             	mov    0x18(%edx),%edx
  800842:	85 d2                	test   %edx,%edx
  800844:	74 14                	je     80085a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800846:	83 ec 08             	sub    $0x8,%esp
  800849:	ff 75 0c             	pushl  0xc(%ebp)
  80084c:	50                   	push   %eax
  80084d:	ff d2                	call   *%edx
  80084f:	89 c2                	mov    %eax,%edx
  800851:	83 c4 10             	add    $0x10,%esp
  800854:	eb 09                	jmp    80085f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800856:	89 c2                	mov    %eax,%edx
  800858:	eb 05                	jmp    80085f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80085a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80085f:	89 d0                	mov    %edx,%eax
  800861:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800864:	c9                   	leave  
  800865:	c3                   	ret    

00800866 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	53                   	push   %ebx
  80086a:	83 ec 14             	sub    $0x14,%esp
  80086d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800870:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800873:	50                   	push   %eax
  800874:	ff 75 08             	pushl  0x8(%ebp)
  800877:	e8 6c fb ff ff       	call   8003e8 <fd_lookup>
  80087c:	83 c4 08             	add    $0x8,%esp
  80087f:	89 c2                	mov    %eax,%edx
  800881:	85 c0                	test   %eax,%eax
  800883:	78 58                	js     8008dd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088b:	50                   	push   %eax
  80088c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088f:	ff 30                	pushl  (%eax)
  800891:	e8 a8 fb ff ff       	call   80043e <dev_lookup>
  800896:	83 c4 10             	add    $0x10,%esp
  800899:	85 c0                	test   %eax,%eax
  80089b:	78 37                	js     8008d4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80089d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008a4:	74 32                	je     8008d8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008a6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008a9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008b0:	00 00 00 
	stat->st_isdir = 0;
  8008b3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ba:	00 00 00 
	stat->st_dev = dev;
  8008bd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008c3:	83 ec 08             	sub    $0x8,%esp
  8008c6:	53                   	push   %ebx
  8008c7:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ca:	ff 50 14             	call   *0x14(%eax)
  8008cd:	89 c2                	mov    %eax,%edx
  8008cf:	83 c4 10             	add    $0x10,%esp
  8008d2:	eb 09                	jmp    8008dd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d4:	89 c2                	mov    %eax,%edx
  8008d6:	eb 05                	jmp    8008dd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008dd:	89 d0                	mov    %edx,%eax
  8008df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008e9:	83 ec 08             	sub    $0x8,%esp
  8008ec:	6a 00                	push   $0x0
  8008ee:	ff 75 08             	pushl  0x8(%ebp)
  8008f1:	e8 0c 02 00 00       	call   800b02 <open>
  8008f6:	89 c3                	mov    %eax,%ebx
  8008f8:	83 c4 10             	add    $0x10,%esp
  8008fb:	85 c0                	test   %eax,%eax
  8008fd:	78 1b                	js     80091a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	ff 75 0c             	pushl  0xc(%ebp)
  800905:	50                   	push   %eax
  800906:	e8 5b ff ff ff       	call   800866 <fstat>
  80090b:	89 c6                	mov    %eax,%esi
	close(fd);
  80090d:	89 1c 24             	mov    %ebx,(%esp)
  800910:	e8 fd fb ff ff       	call   800512 <close>
	return r;
  800915:	83 c4 10             	add    $0x10,%esp
  800918:	89 f0                	mov    %esi,%eax
}
  80091a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80091d:	5b                   	pop    %ebx
  80091e:	5e                   	pop    %esi
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	56                   	push   %esi
  800925:	53                   	push   %ebx
  800926:	89 c6                	mov    %eax,%esi
  800928:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80092a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800931:	75 12                	jne    800945 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800933:	83 ec 0c             	sub    $0xc,%esp
  800936:	6a 01                	push   $0x1
  800938:	e8 aa 11 00 00       	call   801ae7 <ipc_find_env>
  80093d:	a3 00 40 80 00       	mov    %eax,0x804000
  800942:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800945:	6a 07                	push   $0x7
  800947:	68 00 50 80 00       	push   $0x805000
  80094c:	56                   	push   %esi
  80094d:	ff 35 00 40 80 00    	pushl  0x804000
  800953:	e8 3b 11 00 00       	call   801a93 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800958:	83 c4 0c             	add    $0xc,%esp
  80095b:	6a 00                	push   $0x0
  80095d:	53                   	push   %ebx
  80095e:	6a 00                	push   $0x0
  800960:	e8 c5 10 00 00       	call   801a2a <ipc_recv>
}
  800965:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	8b 40 0c             	mov    0xc(%eax),%eax
  800978:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80097d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800980:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800985:	ba 00 00 00 00       	mov    $0x0,%edx
  80098a:	b8 02 00 00 00       	mov    $0x2,%eax
  80098f:	e8 8d ff ff ff       	call   800921 <fsipc>
}
  800994:	c9                   	leave  
  800995:	c3                   	ret    

00800996 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ac:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b1:	e8 6b ff ff ff       	call   800921 <fsipc>
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	53                   	push   %ebx
  8009bc:	83 ec 04             	sub    $0x4,%esp
  8009bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8009d7:	e8 45 ff ff ff       	call   800921 <fsipc>
  8009dc:	85 c0                	test   %eax,%eax
  8009de:	78 2c                	js     800a0c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009e0:	83 ec 08             	sub    $0x8,%esp
  8009e3:	68 00 50 80 00       	push   $0x805000
  8009e8:	53                   	push   %ebx
  8009e9:	e8 f5 0c 00 00       	call   8016e3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ee:	a1 80 50 80 00       	mov    0x805080,%eax
  8009f3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009f9:	a1 84 50 80 00       	mov    0x805084,%eax
  8009fe:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a04:	83 c4 10             	add    $0x10,%esp
  800a07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    

00800a11 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	53                   	push   %ebx
  800a15:	83 ec 08             	sub    $0x8,%esp
  800a18:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1e:	8b 52 0c             	mov    0xc(%edx),%edx
  800a21:	89 15 00 50 80 00    	mov    %edx,0x805000
  800a27:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a2c:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a31:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  800a34:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  800a3a:	53                   	push   %ebx
  800a3b:	ff 75 0c             	pushl  0xc(%ebp)
  800a3e:	68 08 50 80 00       	push   $0x805008
  800a43:	e8 2d 0e 00 00       	call   801875 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  800a48:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4d:	b8 04 00 00 00       	mov    $0x4,%eax
  800a52:	e8 ca fe ff ff       	call   800921 <fsipc>
  800a57:	83 c4 10             	add    $0x10,%esp
  800a5a:	85 c0                	test   %eax,%eax
  800a5c:	78 1d                	js     800a7b <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  800a5e:	39 d8                	cmp    %ebx,%eax
  800a60:	76 19                	jbe    800a7b <devfile_write+0x6a>
  800a62:	68 c4 1e 80 00       	push   $0x801ec4
  800a67:	68 d0 1e 80 00       	push   $0x801ed0
  800a6c:	68 a5 00 00 00       	push   $0xa5
  800a71:	68 e5 1e 80 00       	push   $0x801ee5
  800a76:	e8 0a 06 00 00       	call   801085 <_panic>
	return r;
}
  800a7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a7e:	c9                   	leave  
  800a7f:	c3                   	ret    

00800a80 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	56                   	push   %esi
  800a84:	53                   	push   %ebx
  800a85:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a93:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a99:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9e:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa3:	e8 79 fe ff ff       	call   800921 <fsipc>
  800aa8:	89 c3                	mov    %eax,%ebx
  800aaa:	85 c0                	test   %eax,%eax
  800aac:	78 4b                	js     800af9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aae:	39 c6                	cmp    %eax,%esi
  800ab0:	73 16                	jae    800ac8 <devfile_read+0x48>
  800ab2:	68 f0 1e 80 00       	push   $0x801ef0
  800ab7:	68 d0 1e 80 00       	push   $0x801ed0
  800abc:	6a 7c                	push   $0x7c
  800abe:	68 e5 1e 80 00       	push   $0x801ee5
  800ac3:	e8 bd 05 00 00       	call   801085 <_panic>
	assert(r <= PGSIZE);
  800ac8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800acd:	7e 16                	jle    800ae5 <devfile_read+0x65>
  800acf:	68 f7 1e 80 00       	push   $0x801ef7
  800ad4:	68 d0 1e 80 00       	push   $0x801ed0
  800ad9:	6a 7d                	push   $0x7d
  800adb:	68 e5 1e 80 00       	push   $0x801ee5
  800ae0:	e8 a0 05 00 00       	call   801085 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae5:	83 ec 04             	sub    $0x4,%esp
  800ae8:	50                   	push   %eax
  800ae9:	68 00 50 80 00       	push   $0x805000
  800aee:	ff 75 0c             	pushl  0xc(%ebp)
  800af1:	e8 7f 0d 00 00       	call   801875 <memmove>
	return r;
  800af6:	83 c4 10             	add    $0x10,%esp
}
  800af9:	89 d8                	mov    %ebx,%eax
  800afb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	53                   	push   %ebx
  800b06:	83 ec 20             	sub    $0x20,%esp
  800b09:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b0c:	53                   	push   %ebx
  800b0d:	e8 98 0b 00 00       	call   8016aa <strlen>
  800b12:	83 c4 10             	add    $0x10,%esp
  800b15:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b1a:	7f 67                	jg     800b83 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b1c:	83 ec 0c             	sub    $0xc,%esp
  800b1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b22:	50                   	push   %eax
  800b23:	e8 71 f8 ff ff       	call   800399 <fd_alloc>
  800b28:	83 c4 10             	add    $0x10,%esp
		return r;
  800b2b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b2d:	85 c0                	test   %eax,%eax
  800b2f:	78 57                	js     800b88 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b31:	83 ec 08             	sub    $0x8,%esp
  800b34:	53                   	push   %ebx
  800b35:	68 00 50 80 00       	push   $0x805000
  800b3a:	e8 a4 0b 00 00       	call   8016e3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b42:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b47:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b4a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4f:	e8 cd fd ff ff       	call   800921 <fsipc>
  800b54:	89 c3                	mov    %eax,%ebx
  800b56:	83 c4 10             	add    $0x10,%esp
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	79 14                	jns    800b71 <open+0x6f>
		fd_close(fd, 0);
  800b5d:	83 ec 08             	sub    $0x8,%esp
  800b60:	6a 00                	push   $0x0
  800b62:	ff 75 f4             	pushl  -0xc(%ebp)
  800b65:	e8 27 f9 ff ff       	call   800491 <fd_close>
		return r;
  800b6a:	83 c4 10             	add    $0x10,%esp
  800b6d:	89 da                	mov    %ebx,%edx
  800b6f:	eb 17                	jmp    800b88 <open+0x86>
	}

	return fd2num(fd);
  800b71:	83 ec 0c             	sub    $0xc,%esp
  800b74:	ff 75 f4             	pushl  -0xc(%ebp)
  800b77:	e8 f6 f7 ff ff       	call   800372 <fd2num>
  800b7c:	89 c2                	mov    %eax,%edx
  800b7e:	83 c4 10             	add    $0x10,%esp
  800b81:	eb 05                	jmp    800b88 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b83:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b88:	89 d0                	mov    %edx,%eax
  800b8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b8d:	c9                   	leave  
  800b8e:	c3                   	ret    

00800b8f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	b8 08 00 00 00       	mov    $0x8,%eax
  800b9f:	e8 7d fd ff ff       	call   800921 <fsipc>
}
  800ba4:	c9                   	leave  
  800ba5:	c3                   	ret    

00800ba6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
  800bab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bae:	83 ec 0c             	sub    $0xc,%esp
  800bb1:	ff 75 08             	pushl  0x8(%ebp)
  800bb4:	e8 c9 f7 ff ff       	call   800382 <fd2data>
  800bb9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bbb:	83 c4 08             	add    $0x8,%esp
  800bbe:	68 03 1f 80 00       	push   $0x801f03
  800bc3:	53                   	push   %ebx
  800bc4:	e8 1a 0b 00 00       	call   8016e3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bc9:	8b 46 04             	mov    0x4(%esi),%eax
  800bcc:	2b 06                	sub    (%esi),%eax
  800bce:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bd4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bdb:	00 00 00 
	stat->st_dev = &devpipe;
  800bde:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800be5:	30 80 00 
	return 0;
}
  800be8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	53                   	push   %ebx
  800bf8:	83 ec 0c             	sub    $0xc,%esp
  800bfb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bfe:	53                   	push   %ebx
  800bff:	6a 00                	push   $0x0
  800c01:	e8 00 f6 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c06:	89 1c 24             	mov    %ebx,(%esp)
  800c09:	e8 74 f7 ff ff       	call   800382 <fd2data>
  800c0e:	83 c4 08             	add    $0x8,%esp
  800c11:	50                   	push   %eax
  800c12:	6a 00                	push   $0x0
  800c14:	e8 ed f5 ff ff       	call   800206 <sys_page_unmap>
}
  800c19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c1c:	c9                   	leave  
  800c1d:	c3                   	ret    

00800c1e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 1c             	sub    $0x1c,%esp
  800c27:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c2a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c2c:	a1 04 40 80 00       	mov    0x804004,%eax
  800c31:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c34:	83 ec 0c             	sub    $0xc,%esp
  800c37:	ff 75 e0             	pushl  -0x20(%ebp)
  800c3a:	e8 e1 0e 00 00       	call   801b20 <pageref>
  800c3f:	89 c3                	mov    %eax,%ebx
  800c41:	89 3c 24             	mov    %edi,(%esp)
  800c44:	e8 d7 0e 00 00       	call   801b20 <pageref>
  800c49:	83 c4 10             	add    $0x10,%esp
  800c4c:	39 c3                	cmp    %eax,%ebx
  800c4e:	0f 94 c1             	sete   %cl
  800c51:	0f b6 c9             	movzbl %cl,%ecx
  800c54:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c57:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c5d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c60:	39 ce                	cmp    %ecx,%esi
  800c62:	74 1b                	je     800c7f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c64:	39 c3                	cmp    %eax,%ebx
  800c66:	75 c4                	jne    800c2c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c68:	8b 42 58             	mov    0x58(%edx),%eax
  800c6b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c6e:	50                   	push   %eax
  800c6f:	56                   	push   %esi
  800c70:	68 0a 1f 80 00       	push   $0x801f0a
  800c75:	e8 e4 04 00 00       	call   80115e <cprintf>
  800c7a:	83 c4 10             	add    $0x10,%esp
  800c7d:	eb ad                	jmp    800c2c <_pipeisclosed+0xe>
	}
}
  800c7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 28             	sub    $0x28,%esp
  800c93:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c96:	56                   	push   %esi
  800c97:	e8 e6 f6 ff ff       	call   800382 <fd2data>
  800c9c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c9e:	83 c4 10             	add    $0x10,%esp
  800ca1:	bf 00 00 00 00       	mov    $0x0,%edi
  800ca6:	eb 4b                	jmp    800cf3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800ca8:	89 da                	mov    %ebx,%edx
  800caa:	89 f0                	mov    %esi,%eax
  800cac:	e8 6d ff ff ff       	call   800c1e <_pipeisclosed>
  800cb1:	85 c0                	test   %eax,%eax
  800cb3:	75 48                	jne    800cfd <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cb5:	e8 a8 f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cba:	8b 43 04             	mov    0x4(%ebx),%eax
  800cbd:	8b 0b                	mov    (%ebx),%ecx
  800cbf:	8d 51 20             	lea    0x20(%ecx),%edx
  800cc2:	39 d0                	cmp    %edx,%eax
  800cc4:	73 e2                	jae    800ca8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ccd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cd0:	89 c2                	mov    %eax,%edx
  800cd2:	c1 fa 1f             	sar    $0x1f,%edx
  800cd5:	89 d1                	mov    %edx,%ecx
  800cd7:	c1 e9 1b             	shr    $0x1b,%ecx
  800cda:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cdd:	83 e2 1f             	and    $0x1f,%edx
  800ce0:	29 ca                	sub    %ecx,%edx
  800ce2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ce6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cea:	83 c0 01             	add    $0x1,%eax
  800ced:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf0:	83 c7 01             	add    $0x1,%edi
  800cf3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cf6:	75 c2                	jne    800cba <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cf8:	8b 45 10             	mov    0x10(%ebp),%eax
  800cfb:	eb 05                	jmp    800d02 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cfd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800d02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
  800d10:	83 ec 18             	sub    $0x18,%esp
  800d13:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d16:	57                   	push   %edi
  800d17:	e8 66 f6 ff ff       	call   800382 <fd2data>
  800d1c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d1e:	83 c4 10             	add    $0x10,%esp
  800d21:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d26:	eb 3d                	jmp    800d65 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d28:	85 db                	test   %ebx,%ebx
  800d2a:	74 04                	je     800d30 <devpipe_read+0x26>
				return i;
  800d2c:	89 d8                	mov    %ebx,%eax
  800d2e:	eb 44                	jmp    800d74 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d30:	89 f2                	mov    %esi,%edx
  800d32:	89 f8                	mov    %edi,%eax
  800d34:	e8 e5 fe ff ff       	call   800c1e <_pipeisclosed>
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	75 32                	jne    800d6f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d3d:	e8 20 f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d42:	8b 06                	mov    (%esi),%eax
  800d44:	3b 46 04             	cmp    0x4(%esi),%eax
  800d47:	74 df                	je     800d28 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d49:	99                   	cltd   
  800d4a:	c1 ea 1b             	shr    $0x1b,%edx
  800d4d:	01 d0                	add    %edx,%eax
  800d4f:	83 e0 1f             	and    $0x1f,%eax
  800d52:	29 d0                	sub    %edx,%eax
  800d54:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d5f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d62:	83 c3 01             	add    $0x1,%ebx
  800d65:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d68:	75 d8                	jne    800d42 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d6a:	8b 45 10             	mov    0x10(%ebp),%eax
  800d6d:	eb 05                	jmp    800d74 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d6f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d77:	5b                   	pop    %ebx
  800d78:	5e                   	pop    %esi
  800d79:	5f                   	pop    %edi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	56                   	push   %esi
  800d80:	53                   	push   %ebx
  800d81:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d87:	50                   	push   %eax
  800d88:	e8 0c f6 ff ff       	call   800399 <fd_alloc>
  800d8d:	83 c4 10             	add    $0x10,%esp
  800d90:	89 c2                	mov    %eax,%edx
  800d92:	85 c0                	test   %eax,%eax
  800d94:	0f 88 2c 01 00 00    	js     800ec6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9a:	83 ec 04             	sub    $0x4,%esp
  800d9d:	68 07 04 00 00       	push   $0x407
  800da2:	ff 75 f4             	pushl  -0xc(%ebp)
  800da5:	6a 00                	push   $0x0
  800da7:	e8 d5 f3 ff ff       	call   800181 <sys_page_alloc>
  800dac:	83 c4 10             	add    $0x10,%esp
  800daf:	89 c2                	mov    %eax,%edx
  800db1:	85 c0                	test   %eax,%eax
  800db3:	0f 88 0d 01 00 00    	js     800ec6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800db9:	83 ec 0c             	sub    $0xc,%esp
  800dbc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dbf:	50                   	push   %eax
  800dc0:	e8 d4 f5 ff ff       	call   800399 <fd_alloc>
  800dc5:	89 c3                	mov    %eax,%ebx
  800dc7:	83 c4 10             	add    $0x10,%esp
  800dca:	85 c0                	test   %eax,%eax
  800dcc:	0f 88 e2 00 00 00    	js     800eb4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd2:	83 ec 04             	sub    $0x4,%esp
  800dd5:	68 07 04 00 00       	push   $0x407
  800dda:	ff 75 f0             	pushl  -0x10(%ebp)
  800ddd:	6a 00                	push   $0x0
  800ddf:	e8 9d f3 ff ff       	call   800181 <sys_page_alloc>
  800de4:	89 c3                	mov    %eax,%ebx
  800de6:	83 c4 10             	add    $0x10,%esp
  800de9:	85 c0                	test   %eax,%eax
  800deb:	0f 88 c3 00 00 00    	js     800eb4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800df1:	83 ec 0c             	sub    $0xc,%esp
  800df4:	ff 75 f4             	pushl  -0xc(%ebp)
  800df7:	e8 86 f5 ff ff       	call   800382 <fd2data>
  800dfc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dfe:	83 c4 0c             	add    $0xc,%esp
  800e01:	68 07 04 00 00       	push   $0x407
  800e06:	50                   	push   %eax
  800e07:	6a 00                	push   $0x0
  800e09:	e8 73 f3 ff ff       	call   800181 <sys_page_alloc>
  800e0e:	89 c3                	mov    %eax,%ebx
  800e10:	83 c4 10             	add    $0x10,%esp
  800e13:	85 c0                	test   %eax,%eax
  800e15:	0f 88 89 00 00 00    	js     800ea4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e1b:	83 ec 0c             	sub    $0xc,%esp
  800e1e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e21:	e8 5c f5 ff ff       	call   800382 <fd2data>
  800e26:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e2d:	50                   	push   %eax
  800e2e:	6a 00                	push   $0x0
  800e30:	56                   	push   %esi
  800e31:	6a 00                	push   $0x0
  800e33:	e8 8c f3 ff ff       	call   8001c4 <sys_page_map>
  800e38:	89 c3                	mov    %eax,%ebx
  800e3a:	83 c4 20             	add    $0x20,%esp
  800e3d:	85 c0                	test   %eax,%eax
  800e3f:	78 55                	js     800e96 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e41:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e4a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e4f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e56:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e5f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e64:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e6b:	83 ec 0c             	sub    $0xc,%esp
  800e6e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e71:	e8 fc f4 ff ff       	call   800372 <fd2num>
  800e76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e79:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e7b:	83 c4 04             	add    $0x4,%esp
  800e7e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e81:	e8 ec f4 ff ff       	call   800372 <fd2num>
  800e86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e89:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e8c:	83 c4 10             	add    $0x10,%esp
  800e8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e94:	eb 30                	jmp    800ec6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e96:	83 ec 08             	sub    $0x8,%esp
  800e99:	56                   	push   %esi
  800e9a:	6a 00                	push   $0x0
  800e9c:	e8 65 f3 ff ff       	call   800206 <sys_page_unmap>
  800ea1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800ea4:	83 ec 08             	sub    $0x8,%esp
  800ea7:	ff 75 f0             	pushl  -0x10(%ebp)
  800eaa:	6a 00                	push   $0x0
  800eac:	e8 55 f3 ff ff       	call   800206 <sys_page_unmap>
  800eb1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800eb4:	83 ec 08             	sub    $0x8,%esp
  800eb7:	ff 75 f4             	pushl  -0xc(%ebp)
  800eba:	6a 00                	push   $0x0
  800ebc:	e8 45 f3 ff ff       	call   800206 <sys_page_unmap>
  800ec1:	83 c4 10             	add    $0x10,%esp
  800ec4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ec6:	89 d0                	mov    %edx,%eax
  800ec8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ecb:	5b                   	pop    %ebx
  800ecc:	5e                   	pop    %esi
  800ecd:	5d                   	pop    %ebp
  800ece:	c3                   	ret    

00800ecf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ed5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed8:	50                   	push   %eax
  800ed9:	ff 75 08             	pushl  0x8(%ebp)
  800edc:	e8 07 f5 ff ff       	call   8003e8 <fd_lookup>
  800ee1:	83 c4 10             	add    $0x10,%esp
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	78 18                	js     800f00 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ee8:	83 ec 0c             	sub    $0xc,%esp
  800eeb:	ff 75 f4             	pushl  -0xc(%ebp)
  800eee:	e8 8f f4 ff ff       	call   800382 <fd2data>
	return _pipeisclosed(fd, p);
  800ef3:	89 c2                	mov    %eax,%edx
  800ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ef8:	e8 21 fd ff ff       	call   800c1e <_pipeisclosed>
  800efd:	83 c4 10             	add    $0x10,%esp
}
  800f00:	c9                   	leave  
  800f01:	c3                   	ret    

00800f02 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800f05:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f12:	68 22 1f 80 00       	push   $0x801f22
  800f17:	ff 75 0c             	pushl  0xc(%ebp)
  800f1a:	e8 c4 07 00 00       	call   8016e3 <strcpy>
	return 0;
}
  800f1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f24:	c9                   	leave  
  800f25:	c3                   	ret    

00800f26 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	57                   	push   %edi
  800f2a:	56                   	push   %esi
  800f2b:	53                   	push   %ebx
  800f2c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f32:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f37:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f3d:	eb 2d                	jmp    800f6c <devcons_write+0x46>
		m = n - tot;
  800f3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f42:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f44:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f47:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f4c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f4f:	83 ec 04             	sub    $0x4,%esp
  800f52:	53                   	push   %ebx
  800f53:	03 45 0c             	add    0xc(%ebp),%eax
  800f56:	50                   	push   %eax
  800f57:	57                   	push   %edi
  800f58:	e8 18 09 00 00       	call   801875 <memmove>
		sys_cputs(buf, m);
  800f5d:	83 c4 08             	add    $0x8,%esp
  800f60:	53                   	push   %ebx
  800f61:	57                   	push   %edi
  800f62:	e8 5e f1 ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f67:	01 de                	add    %ebx,%esi
  800f69:	83 c4 10             	add    $0x10,%esp
  800f6c:	89 f0                	mov    %esi,%eax
  800f6e:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f71:	72 cc                	jb     800f3f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f76:	5b                   	pop    %ebx
  800f77:	5e                   	pop    %esi
  800f78:	5f                   	pop    %edi
  800f79:	5d                   	pop    %ebp
  800f7a:	c3                   	ret    

00800f7b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	83 ec 08             	sub    $0x8,%esp
  800f81:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f86:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f8a:	74 2a                	je     800fb6 <devcons_read+0x3b>
  800f8c:	eb 05                	jmp    800f93 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f8e:	e8 cf f1 ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f93:	e8 4b f1 ff ff       	call   8000e3 <sys_cgetc>
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	74 f2                	je     800f8e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	78 16                	js     800fb6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800fa0:	83 f8 04             	cmp    $0x4,%eax
  800fa3:	74 0c                	je     800fb1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800fa5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa8:	88 02                	mov    %al,(%edx)
	return 1;
  800faa:	b8 01 00 00 00       	mov    $0x1,%eax
  800faf:	eb 05                	jmp    800fb6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fb1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fb6:	c9                   	leave  
  800fb7:	c3                   	ret    

00800fb8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fc4:	6a 01                	push   $0x1
  800fc6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fc9:	50                   	push   %eax
  800fca:	e8 f6 f0 ff ff       	call   8000c5 <sys_cputs>
}
  800fcf:	83 c4 10             	add    $0x10,%esp
  800fd2:	c9                   	leave  
  800fd3:	c3                   	ret    

00800fd4 <getchar>:

int
getchar(void)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fda:	6a 01                	push   $0x1
  800fdc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fdf:	50                   	push   %eax
  800fe0:	6a 00                	push   $0x0
  800fe2:	e8 67 f6 ff ff       	call   80064e <read>
	if (r < 0)
  800fe7:	83 c4 10             	add    $0x10,%esp
  800fea:	85 c0                	test   %eax,%eax
  800fec:	78 0f                	js     800ffd <getchar+0x29>
		return r;
	if (r < 1)
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	7e 06                	jle    800ff8 <getchar+0x24>
		return -E_EOF;
	return c;
  800ff2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800ff6:	eb 05                	jmp    800ffd <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800ff8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800ffd:	c9                   	leave  
  800ffe:	c3                   	ret    

00800fff <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
  801002:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801005:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801008:	50                   	push   %eax
  801009:	ff 75 08             	pushl  0x8(%ebp)
  80100c:	e8 d7 f3 ff ff       	call   8003e8 <fd_lookup>
  801011:	83 c4 10             	add    $0x10,%esp
  801014:	85 c0                	test   %eax,%eax
  801016:	78 11                	js     801029 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801018:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801021:	39 10                	cmp    %edx,(%eax)
  801023:	0f 94 c0             	sete   %al
  801026:	0f b6 c0             	movzbl %al,%eax
}
  801029:	c9                   	leave  
  80102a:	c3                   	ret    

0080102b <opencons>:

int
opencons(void)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801031:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801034:	50                   	push   %eax
  801035:	e8 5f f3 ff ff       	call   800399 <fd_alloc>
  80103a:	83 c4 10             	add    $0x10,%esp
		return r;
  80103d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80103f:	85 c0                	test   %eax,%eax
  801041:	78 3e                	js     801081 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801043:	83 ec 04             	sub    $0x4,%esp
  801046:	68 07 04 00 00       	push   $0x407
  80104b:	ff 75 f4             	pushl  -0xc(%ebp)
  80104e:	6a 00                	push   $0x0
  801050:	e8 2c f1 ff ff       	call   800181 <sys_page_alloc>
  801055:	83 c4 10             	add    $0x10,%esp
		return r;
  801058:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80105a:	85 c0                	test   %eax,%eax
  80105c:	78 23                	js     801081 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80105e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801064:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801067:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801069:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80106c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801073:	83 ec 0c             	sub    $0xc,%esp
  801076:	50                   	push   %eax
  801077:	e8 f6 f2 ff ff       	call   800372 <fd2num>
  80107c:	89 c2                	mov    %eax,%edx
  80107e:	83 c4 10             	add    $0x10,%esp
}
  801081:	89 d0                	mov    %edx,%eax
  801083:	c9                   	leave  
  801084:	c3                   	ret    

00801085 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	56                   	push   %esi
  801089:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80108a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80108d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801093:	e8 ab f0 ff ff       	call   800143 <sys_getenvid>
  801098:	83 ec 0c             	sub    $0xc,%esp
  80109b:	ff 75 0c             	pushl  0xc(%ebp)
  80109e:	ff 75 08             	pushl  0x8(%ebp)
  8010a1:	56                   	push   %esi
  8010a2:	50                   	push   %eax
  8010a3:	68 30 1f 80 00       	push   $0x801f30
  8010a8:	e8 b1 00 00 00       	call   80115e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010ad:	83 c4 18             	add    $0x18,%esp
  8010b0:	53                   	push   %ebx
  8010b1:	ff 75 10             	pushl  0x10(%ebp)
  8010b4:	e8 54 00 00 00       	call   80110d <vcprintf>
	cprintf("\n");
  8010b9:	c7 04 24 1b 1f 80 00 	movl   $0x801f1b,(%esp)
  8010c0:	e8 99 00 00 00       	call   80115e <cprintf>
  8010c5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010c8:	cc                   	int3   
  8010c9:	eb fd                	jmp    8010c8 <_panic+0x43>

008010cb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010cb:	55                   	push   %ebp
  8010cc:	89 e5                	mov    %esp,%ebp
  8010ce:	53                   	push   %ebx
  8010cf:	83 ec 04             	sub    $0x4,%esp
  8010d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010d5:	8b 13                	mov    (%ebx),%edx
  8010d7:	8d 42 01             	lea    0x1(%edx),%eax
  8010da:	89 03                	mov    %eax,(%ebx)
  8010dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010df:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010e3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010e8:	75 1a                	jne    801104 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010ea:	83 ec 08             	sub    $0x8,%esp
  8010ed:	68 ff 00 00 00       	push   $0xff
  8010f2:	8d 43 08             	lea    0x8(%ebx),%eax
  8010f5:	50                   	push   %eax
  8010f6:	e8 ca ef ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  8010fb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801101:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801104:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801108:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80110b:	c9                   	leave  
  80110c:	c3                   	ret    

0080110d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801116:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80111d:	00 00 00 
	b.cnt = 0;
  801120:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801127:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80112a:	ff 75 0c             	pushl  0xc(%ebp)
  80112d:	ff 75 08             	pushl  0x8(%ebp)
  801130:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801136:	50                   	push   %eax
  801137:	68 cb 10 80 00       	push   $0x8010cb
  80113c:	e8 54 01 00 00       	call   801295 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801141:	83 c4 08             	add    $0x8,%esp
  801144:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80114a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801150:	50                   	push   %eax
  801151:	e8 6f ef ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  801156:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80115c:	c9                   	leave  
  80115d:	c3                   	ret    

0080115e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801164:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801167:	50                   	push   %eax
  801168:	ff 75 08             	pushl  0x8(%ebp)
  80116b:	e8 9d ff ff ff       	call   80110d <vcprintf>
	va_end(ap);

	return cnt;
}
  801170:	c9                   	leave  
  801171:	c3                   	ret    

00801172 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
  801175:	57                   	push   %edi
  801176:	56                   	push   %esi
  801177:	53                   	push   %ebx
  801178:	83 ec 1c             	sub    $0x1c,%esp
  80117b:	89 c7                	mov    %eax,%edi
  80117d:	89 d6                	mov    %edx,%esi
  80117f:	8b 45 08             	mov    0x8(%ebp),%eax
  801182:	8b 55 0c             	mov    0xc(%ebp),%edx
  801185:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801188:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80118b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80118e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801193:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801196:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801199:	39 d3                	cmp    %edx,%ebx
  80119b:	72 05                	jb     8011a2 <printnum+0x30>
  80119d:	39 45 10             	cmp    %eax,0x10(%ebp)
  8011a0:	77 45                	ja     8011e7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011a2:	83 ec 0c             	sub    $0xc,%esp
  8011a5:	ff 75 18             	pushl  0x18(%ebp)
  8011a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8011ab:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011ae:	53                   	push   %ebx
  8011af:	ff 75 10             	pushl  0x10(%ebp)
  8011b2:	83 ec 08             	sub    $0x8,%esp
  8011b5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8011bb:	ff 75 dc             	pushl  -0x24(%ebp)
  8011be:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c1:	e8 9a 09 00 00       	call   801b60 <__udivdi3>
  8011c6:	83 c4 18             	add    $0x18,%esp
  8011c9:	52                   	push   %edx
  8011ca:	50                   	push   %eax
  8011cb:	89 f2                	mov    %esi,%edx
  8011cd:	89 f8                	mov    %edi,%eax
  8011cf:	e8 9e ff ff ff       	call   801172 <printnum>
  8011d4:	83 c4 20             	add    $0x20,%esp
  8011d7:	eb 18                	jmp    8011f1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011d9:	83 ec 08             	sub    $0x8,%esp
  8011dc:	56                   	push   %esi
  8011dd:	ff 75 18             	pushl  0x18(%ebp)
  8011e0:	ff d7                	call   *%edi
  8011e2:	83 c4 10             	add    $0x10,%esp
  8011e5:	eb 03                	jmp    8011ea <printnum+0x78>
  8011e7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011ea:	83 eb 01             	sub    $0x1,%ebx
  8011ed:	85 db                	test   %ebx,%ebx
  8011ef:	7f e8                	jg     8011d9 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011f1:	83 ec 08             	sub    $0x8,%esp
  8011f4:	56                   	push   %esi
  8011f5:	83 ec 04             	sub    $0x4,%esp
  8011f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8011fe:	ff 75 dc             	pushl  -0x24(%ebp)
  801201:	ff 75 d8             	pushl  -0x28(%ebp)
  801204:	e8 87 0a 00 00       	call   801c90 <__umoddi3>
  801209:	83 c4 14             	add    $0x14,%esp
  80120c:	0f be 80 53 1f 80 00 	movsbl 0x801f53(%eax),%eax
  801213:	50                   	push   %eax
  801214:	ff d7                	call   *%edi
}
  801216:	83 c4 10             	add    $0x10,%esp
  801219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121c:	5b                   	pop    %ebx
  80121d:	5e                   	pop    %esi
  80121e:	5f                   	pop    %edi
  80121f:	5d                   	pop    %ebp
  801220:	c3                   	ret    

00801221 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801224:	83 fa 01             	cmp    $0x1,%edx
  801227:	7e 0e                	jle    801237 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801229:	8b 10                	mov    (%eax),%edx
  80122b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80122e:	89 08                	mov    %ecx,(%eax)
  801230:	8b 02                	mov    (%edx),%eax
  801232:	8b 52 04             	mov    0x4(%edx),%edx
  801235:	eb 22                	jmp    801259 <getuint+0x38>
	else if (lflag)
  801237:	85 d2                	test   %edx,%edx
  801239:	74 10                	je     80124b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80123b:	8b 10                	mov    (%eax),%edx
  80123d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801240:	89 08                	mov    %ecx,(%eax)
  801242:	8b 02                	mov    (%edx),%eax
  801244:	ba 00 00 00 00       	mov    $0x0,%edx
  801249:	eb 0e                	jmp    801259 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80124b:	8b 10                	mov    (%eax),%edx
  80124d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801250:	89 08                	mov    %ecx,(%eax)
  801252:	8b 02                	mov    (%edx),%eax
  801254:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801259:	5d                   	pop    %ebp
  80125a:	c3                   	ret    

0080125b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801261:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801265:	8b 10                	mov    (%eax),%edx
  801267:	3b 50 04             	cmp    0x4(%eax),%edx
  80126a:	73 0a                	jae    801276 <sprintputch+0x1b>
		*b->buf++ = ch;
  80126c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80126f:	89 08                	mov    %ecx,(%eax)
  801271:	8b 45 08             	mov    0x8(%ebp),%eax
  801274:	88 02                	mov    %al,(%edx)
}
  801276:	5d                   	pop    %ebp
  801277:	c3                   	ret    

00801278 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80127e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801281:	50                   	push   %eax
  801282:	ff 75 10             	pushl  0x10(%ebp)
  801285:	ff 75 0c             	pushl  0xc(%ebp)
  801288:	ff 75 08             	pushl  0x8(%ebp)
  80128b:	e8 05 00 00 00       	call   801295 <vprintfmt>
	va_end(ap);
}
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	c9                   	leave  
  801294:	c3                   	ret    

00801295 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	57                   	push   %edi
  801299:	56                   	push   %esi
  80129a:	53                   	push   %ebx
  80129b:	83 ec 2c             	sub    $0x2c,%esp
  80129e:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012a4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012a7:	eb 12                	jmp    8012bb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	0f 84 89 03 00 00    	je     80163a <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8012b1:	83 ec 08             	sub    $0x8,%esp
  8012b4:	53                   	push   %ebx
  8012b5:	50                   	push   %eax
  8012b6:	ff d6                	call   *%esi
  8012b8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012bb:	83 c7 01             	add    $0x1,%edi
  8012be:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012c2:	83 f8 25             	cmp    $0x25,%eax
  8012c5:	75 e2                	jne    8012a9 <vprintfmt+0x14>
  8012c7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012cb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012d2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012d9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e5:	eb 07                	jmp    8012ee <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012ea:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ee:	8d 47 01             	lea    0x1(%edi),%eax
  8012f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012f4:	0f b6 07             	movzbl (%edi),%eax
  8012f7:	0f b6 c8             	movzbl %al,%ecx
  8012fa:	83 e8 23             	sub    $0x23,%eax
  8012fd:	3c 55                	cmp    $0x55,%al
  8012ff:	0f 87 1a 03 00 00    	ja     80161f <vprintfmt+0x38a>
  801305:	0f b6 c0             	movzbl %al,%eax
  801308:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  80130f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801312:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801316:	eb d6                	jmp    8012ee <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801318:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80131b:	b8 00 00 00 00       	mov    $0x0,%eax
  801320:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801323:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801326:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80132a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80132d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801330:	83 fa 09             	cmp    $0x9,%edx
  801333:	77 39                	ja     80136e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801335:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801338:	eb e9                	jmp    801323 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80133a:	8b 45 14             	mov    0x14(%ebp),%eax
  80133d:	8d 48 04             	lea    0x4(%eax),%ecx
  801340:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801343:	8b 00                	mov    (%eax),%eax
  801345:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801348:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80134b:	eb 27                	jmp    801374 <vprintfmt+0xdf>
  80134d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801350:	85 c0                	test   %eax,%eax
  801352:	b9 00 00 00 00       	mov    $0x0,%ecx
  801357:	0f 49 c8             	cmovns %eax,%ecx
  80135a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801360:	eb 8c                	jmp    8012ee <vprintfmt+0x59>
  801362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801365:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80136c:	eb 80                	jmp    8012ee <vprintfmt+0x59>
  80136e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801371:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801374:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801378:	0f 89 70 ff ff ff    	jns    8012ee <vprintfmt+0x59>
				width = precision, precision = -1;
  80137e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801381:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801384:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80138b:	e9 5e ff ff ff       	jmp    8012ee <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801390:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801396:	e9 53 ff ff ff       	jmp    8012ee <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80139b:	8b 45 14             	mov    0x14(%ebp),%eax
  80139e:	8d 50 04             	lea    0x4(%eax),%edx
  8013a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8013a4:	83 ec 08             	sub    $0x8,%esp
  8013a7:	53                   	push   %ebx
  8013a8:	ff 30                	pushl  (%eax)
  8013aa:	ff d6                	call   *%esi
			break;
  8013ac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013b2:	e9 04 ff ff ff       	jmp    8012bb <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ba:	8d 50 04             	lea    0x4(%eax),%edx
  8013bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8013c0:	8b 00                	mov    (%eax),%eax
  8013c2:	99                   	cltd   
  8013c3:	31 d0                	xor    %edx,%eax
  8013c5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013c7:	83 f8 0f             	cmp    $0xf,%eax
  8013ca:	7f 0b                	jg     8013d7 <vprintfmt+0x142>
  8013cc:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  8013d3:	85 d2                	test   %edx,%edx
  8013d5:	75 18                	jne    8013ef <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013d7:	50                   	push   %eax
  8013d8:	68 6b 1f 80 00       	push   $0x801f6b
  8013dd:	53                   	push   %ebx
  8013de:	56                   	push   %esi
  8013df:	e8 94 fe ff ff       	call   801278 <printfmt>
  8013e4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013ea:	e9 cc fe ff ff       	jmp    8012bb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013ef:	52                   	push   %edx
  8013f0:	68 e2 1e 80 00       	push   $0x801ee2
  8013f5:	53                   	push   %ebx
  8013f6:	56                   	push   %esi
  8013f7:	e8 7c fe ff ff       	call   801278 <printfmt>
  8013fc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801402:	e9 b4 fe ff ff       	jmp    8012bb <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801407:	8b 45 14             	mov    0x14(%ebp),%eax
  80140a:	8d 50 04             	lea    0x4(%eax),%edx
  80140d:	89 55 14             	mov    %edx,0x14(%ebp)
  801410:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801412:	85 ff                	test   %edi,%edi
  801414:	b8 64 1f 80 00       	mov    $0x801f64,%eax
  801419:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80141c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801420:	0f 8e 94 00 00 00    	jle    8014ba <vprintfmt+0x225>
  801426:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80142a:	0f 84 98 00 00 00    	je     8014c8 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801430:	83 ec 08             	sub    $0x8,%esp
  801433:	ff 75 d0             	pushl  -0x30(%ebp)
  801436:	57                   	push   %edi
  801437:	e8 86 02 00 00       	call   8016c2 <strnlen>
  80143c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80143f:	29 c1                	sub    %eax,%ecx
  801441:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801444:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801447:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80144b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80144e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801451:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801453:	eb 0f                	jmp    801464 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801455:	83 ec 08             	sub    $0x8,%esp
  801458:	53                   	push   %ebx
  801459:	ff 75 e0             	pushl  -0x20(%ebp)
  80145c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80145e:	83 ef 01             	sub    $0x1,%edi
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	85 ff                	test   %edi,%edi
  801466:	7f ed                	jg     801455 <vprintfmt+0x1c0>
  801468:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80146b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80146e:	85 c9                	test   %ecx,%ecx
  801470:	b8 00 00 00 00       	mov    $0x0,%eax
  801475:	0f 49 c1             	cmovns %ecx,%eax
  801478:	29 c1                	sub    %eax,%ecx
  80147a:	89 75 08             	mov    %esi,0x8(%ebp)
  80147d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801480:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801483:	89 cb                	mov    %ecx,%ebx
  801485:	eb 4d                	jmp    8014d4 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801487:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80148b:	74 1b                	je     8014a8 <vprintfmt+0x213>
  80148d:	0f be c0             	movsbl %al,%eax
  801490:	83 e8 20             	sub    $0x20,%eax
  801493:	83 f8 5e             	cmp    $0x5e,%eax
  801496:	76 10                	jbe    8014a8 <vprintfmt+0x213>
					putch('?', putdat);
  801498:	83 ec 08             	sub    $0x8,%esp
  80149b:	ff 75 0c             	pushl  0xc(%ebp)
  80149e:	6a 3f                	push   $0x3f
  8014a0:	ff 55 08             	call   *0x8(%ebp)
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	eb 0d                	jmp    8014b5 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8014a8:	83 ec 08             	sub    $0x8,%esp
  8014ab:	ff 75 0c             	pushl  0xc(%ebp)
  8014ae:	52                   	push   %edx
  8014af:	ff 55 08             	call   *0x8(%ebp)
  8014b2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014b5:	83 eb 01             	sub    $0x1,%ebx
  8014b8:	eb 1a                	jmp    8014d4 <vprintfmt+0x23f>
  8014ba:	89 75 08             	mov    %esi,0x8(%ebp)
  8014bd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014c0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014c3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014c6:	eb 0c                	jmp    8014d4 <vprintfmt+0x23f>
  8014c8:	89 75 08             	mov    %esi,0x8(%ebp)
  8014cb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014ce:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014d1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014d4:	83 c7 01             	add    $0x1,%edi
  8014d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014db:	0f be d0             	movsbl %al,%edx
  8014de:	85 d2                	test   %edx,%edx
  8014e0:	74 23                	je     801505 <vprintfmt+0x270>
  8014e2:	85 f6                	test   %esi,%esi
  8014e4:	78 a1                	js     801487 <vprintfmt+0x1f2>
  8014e6:	83 ee 01             	sub    $0x1,%esi
  8014e9:	79 9c                	jns    801487 <vprintfmt+0x1f2>
  8014eb:	89 df                	mov    %ebx,%edi
  8014ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8014f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014f3:	eb 18                	jmp    80150d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014f5:	83 ec 08             	sub    $0x8,%esp
  8014f8:	53                   	push   %ebx
  8014f9:	6a 20                	push   $0x20
  8014fb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014fd:	83 ef 01             	sub    $0x1,%edi
  801500:	83 c4 10             	add    $0x10,%esp
  801503:	eb 08                	jmp    80150d <vprintfmt+0x278>
  801505:	89 df                	mov    %ebx,%edi
  801507:	8b 75 08             	mov    0x8(%ebp),%esi
  80150a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80150d:	85 ff                	test   %edi,%edi
  80150f:	7f e4                	jg     8014f5 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801511:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801514:	e9 a2 fd ff ff       	jmp    8012bb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801519:	83 fa 01             	cmp    $0x1,%edx
  80151c:	7e 16                	jle    801534 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80151e:	8b 45 14             	mov    0x14(%ebp),%eax
  801521:	8d 50 08             	lea    0x8(%eax),%edx
  801524:	89 55 14             	mov    %edx,0x14(%ebp)
  801527:	8b 50 04             	mov    0x4(%eax),%edx
  80152a:	8b 00                	mov    (%eax),%eax
  80152c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80152f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801532:	eb 32                	jmp    801566 <vprintfmt+0x2d1>
	else if (lflag)
  801534:	85 d2                	test   %edx,%edx
  801536:	74 18                	je     801550 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801538:	8b 45 14             	mov    0x14(%ebp),%eax
  80153b:	8d 50 04             	lea    0x4(%eax),%edx
  80153e:	89 55 14             	mov    %edx,0x14(%ebp)
  801541:	8b 00                	mov    (%eax),%eax
  801543:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801546:	89 c1                	mov    %eax,%ecx
  801548:	c1 f9 1f             	sar    $0x1f,%ecx
  80154b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80154e:	eb 16                	jmp    801566 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801550:	8b 45 14             	mov    0x14(%ebp),%eax
  801553:	8d 50 04             	lea    0x4(%eax),%edx
  801556:	89 55 14             	mov    %edx,0x14(%ebp)
  801559:	8b 00                	mov    (%eax),%eax
  80155b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80155e:	89 c1                	mov    %eax,%ecx
  801560:	c1 f9 1f             	sar    $0x1f,%ecx
  801563:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801566:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801569:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80156c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801571:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801575:	79 74                	jns    8015eb <vprintfmt+0x356>
				putch('-', putdat);
  801577:	83 ec 08             	sub    $0x8,%esp
  80157a:	53                   	push   %ebx
  80157b:	6a 2d                	push   $0x2d
  80157d:	ff d6                	call   *%esi
				num = -(long long) num;
  80157f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801582:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801585:	f7 d8                	neg    %eax
  801587:	83 d2 00             	adc    $0x0,%edx
  80158a:	f7 da                	neg    %edx
  80158c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80158f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801594:	eb 55                	jmp    8015eb <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801596:	8d 45 14             	lea    0x14(%ebp),%eax
  801599:	e8 83 fc ff ff       	call   801221 <getuint>
			base = 10;
  80159e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8015a3:	eb 46                	jmp    8015eb <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8015a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8015a8:	e8 74 fc ff ff       	call   801221 <getuint>
                        base = 8;
  8015ad:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8015b2:	eb 37                	jmp    8015eb <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8015b4:	83 ec 08             	sub    $0x8,%esp
  8015b7:	53                   	push   %ebx
  8015b8:	6a 30                	push   $0x30
  8015ba:	ff d6                	call   *%esi
			putch('x', putdat);
  8015bc:	83 c4 08             	add    $0x8,%esp
  8015bf:	53                   	push   %ebx
  8015c0:	6a 78                	push   $0x78
  8015c2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c7:	8d 50 04             	lea    0x4(%eax),%edx
  8015ca:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015cd:	8b 00                	mov    (%eax),%eax
  8015cf:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015d4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015d7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015dc:	eb 0d                	jmp    8015eb <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015de:	8d 45 14             	lea    0x14(%ebp),%eax
  8015e1:	e8 3b fc ff ff       	call   801221 <getuint>
			base = 16;
  8015e6:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015eb:	83 ec 0c             	sub    $0xc,%esp
  8015ee:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015f2:	57                   	push   %edi
  8015f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8015f6:	51                   	push   %ecx
  8015f7:	52                   	push   %edx
  8015f8:	50                   	push   %eax
  8015f9:	89 da                	mov    %ebx,%edx
  8015fb:	89 f0                	mov    %esi,%eax
  8015fd:	e8 70 fb ff ff       	call   801172 <printnum>
			break;
  801602:	83 c4 20             	add    $0x20,%esp
  801605:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801608:	e9 ae fc ff ff       	jmp    8012bb <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80160d:	83 ec 08             	sub    $0x8,%esp
  801610:	53                   	push   %ebx
  801611:	51                   	push   %ecx
  801612:	ff d6                	call   *%esi
			break;
  801614:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801617:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80161a:	e9 9c fc ff ff       	jmp    8012bb <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80161f:	83 ec 08             	sub    $0x8,%esp
  801622:	53                   	push   %ebx
  801623:	6a 25                	push   $0x25
  801625:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	eb 03                	jmp    80162f <vprintfmt+0x39a>
  80162c:	83 ef 01             	sub    $0x1,%edi
  80162f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801633:	75 f7                	jne    80162c <vprintfmt+0x397>
  801635:	e9 81 fc ff ff       	jmp    8012bb <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80163a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163d:	5b                   	pop    %ebx
  80163e:	5e                   	pop    %esi
  80163f:	5f                   	pop    %edi
  801640:	5d                   	pop    %ebp
  801641:	c3                   	ret    

00801642 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801642:	55                   	push   %ebp
  801643:	89 e5                	mov    %esp,%ebp
  801645:	83 ec 18             	sub    $0x18,%esp
  801648:	8b 45 08             	mov    0x8(%ebp),%eax
  80164b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80164e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801651:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801655:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801658:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80165f:	85 c0                	test   %eax,%eax
  801661:	74 26                	je     801689 <vsnprintf+0x47>
  801663:	85 d2                	test   %edx,%edx
  801665:	7e 22                	jle    801689 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801667:	ff 75 14             	pushl  0x14(%ebp)
  80166a:	ff 75 10             	pushl  0x10(%ebp)
  80166d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801670:	50                   	push   %eax
  801671:	68 5b 12 80 00       	push   $0x80125b
  801676:	e8 1a fc ff ff       	call   801295 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80167b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80167e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801681:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	eb 05                	jmp    80168e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801689:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80168e:	c9                   	leave  
  80168f:	c3                   	ret    

00801690 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801696:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801699:	50                   	push   %eax
  80169a:	ff 75 10             	pushl  0x10(%ebp)
  80169d:	ff 75 0c             	pushl  0xc(%ebp)
  8016a0:	ff 75 08             	pushl  0x8(%ebp)
  8016a3:	e8 9a ff ff ff       	call   801642 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016a8:	c9                   	leave  
  8016a9:	c3                   	ret    

008016aa <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b5:	eb 03                	jmp    8016ba <strlen+0x10>
		n++;
  8016b7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016ba:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016be:	75 f7                	jne    8016b7 <strlen+0xd>
		n++;
	return n;
}
  8016c0:	5d                   	pop    %ebp
  8016c1:	c3                   	ret    

008016c2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016c8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d0:	eb 03                	jmp    8016d5 <strnlen+0x13>
		n++;
  8016d2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016d5:	39 c2                	cmp    %eax,%edx
  8016d7:	74 08                	je     8016e1 <strnlen+0x1f>
  8016d9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016dd:	75 f3                	jne    8016d2 <strnlen+0x10>
  8016df:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016e1:	5d                   	pop    %ebp
  8016e2:	c3                   	ret    

008016e3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	53                   	push   %ebx
  8016e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016ed:	89 c2                	mov    %eax,%edx
  8016ef:	83 c2 01             	add    $0x1,%edx
  8016f2:	83 c1 01             	add    $0x1,%ecx
  8016f5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016f9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016fc:	84 db                	test   %bl,%bl
  8016fe:	75 ef                	jne    8016ef <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801700:	5b                   	pop    %ebx
  801701:	5d                   	pop    %ebp
  801702:	c3                   	ret    

00801703 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	53                   	push   %ebx
  801707:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80170a:	53                   	push   %ebx
  80170b:	e8 9a ff ff ff       	call   8016aa <strlen>
  801710:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801713:	ff 75 0c             	pushl  0xc(%ebp)
  801716:	01 d8                	add    %ebx,%eax
  801718:	50                   	push   %eax
  801719:	e8 c5 ff ff ff       	call   8016e3 <strcpy>
	return dst;
}
  80171e:	89 d8                	mov    %ebx,%eax
  801720:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801723:	c9                   	leave  
  801724:	c3                   	ret    

00801725 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	56                   	push   %esi
  801729:	53                   	push   %ebx
  80172a:	8b 75 08             	mov    0x8(%ebp),%esi
  80172d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801730:	89 f3                	mov    %esi,%ebx
  801732:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801735:	89 f2                	mov    %esi,%edx
  801737:	eb 0f                	jmp    801748 <strncpy+0x23>
		*dst++ = *src;
  801739:	83 c2 01             	add    $0x1,%edx
  80173c:	0f b6 01             	movzbl (%ecx),%eax
  80173f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801742:	80 39 01             	cmpb   $0x1,(%ecx)
  801745:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801748:	39 da                	cmp    %ebx,%edx
  80174a:	75 ed                	jne    801739 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80174c:	89 f0                	mov    %esi,%eax
  80174e:	5b                   	pop    %ebx
  80174f:	5e                   	pop    %esi
  801750:	5d                   	pop    %ebp
  801751:	c3                   	ret    

00801752 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	56                   	push   %esi
  801756:	53                   	push   %ebx
  801757:	8b 75 08             	mov    0x8(%ebp),%esi
  80175a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80175d:	8b 55 10             	mov    0x10(%ebp),%edx
  801760:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801762:	85 d2                	test   %edx,%edx
  801764:	74 21                	je     801787 <strlcpy+0x35>
  801766:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80176a:	89 f2                	mov    %esi,%edx
  80176c:	eb 09                	jmp    801777 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80176e:	83 c2 01             	add    $0x1,%edx
  801771:	83 c1 01             	add    $0x1,%ecx
  801774:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801777:	39 c2                	cmp    %eax,%edx
  801779:	74 09                	je     801784 <strlcpy+0x32>
  80177b:	0f b6 19             	movzbl (%ecx),%ebx
  80177e:	84 db                	test   %bl,%bl
  801780:	75 ec                	jne    80176e <strlcpy+0x1c>
  801782:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801784:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801787:	29 f0                	sub    %esi,%eax
}
  801789:	5b                   	pop    %ebx
  80178a:	5e                   	pop    %esi
  80178b:	5d                   	pop    %ebp
  80178c:	c3                   	ret    

0080178d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801793:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801796:	eb 06                	jmp    80179e <strcmp+0x11>
		p++, q++;
  801798:	83 c1 01             	add    $0x1,%ecx
  80179b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80179e:	0f b6 01             	movzbl (%ecx),%eax
  8017a1:	84 c0                	test   %al,%al
  8017a3:	74 04                	je     8017a9 <strcmp+0x1c>
  8017a5:	3a 02                	cmp    (%edx),%al
  8017a7:	74 ef                	je     801798 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017a9:	0f b6 c0             	movzbl %al,%eax
  8017ac:	0f b6 12             	movzbl (%edx),%edx
  8017af:	29 d0                	sub    %edx,%eax
}
  8017b1:	5d                   	pop    %ebp
  8017b2:	c3                   	ret    

008017b3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	53                   	push   %ebx
  8017b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017bd:	89 c3                	mov    %eax,%ebx
  8017bf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017c2:	eb 06                	jmp    8017ca <strncmp+0x17>
		n--, p++, q++;
  8017c4:	83 c0 01             	add    $0x1,%eax
  8017c7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017ca:	39 d8                	cmp    %ebx,%eax
  8017cc:	74 15                	je     8017e3 <strncmp+0x30>
  8017ce:	0f b6 08             	movzbl (%eax),%ecx
  8017d1:	84 c9                	test   %cl,%cl
  8017d3:	74 04                	je     8017d9 <strncmp+0x26>
  8017d5:	3a 0a                	cmp    (%edx),%cl
  8017d7:	74 eb                	je     8017c4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017d9:	0f b6 00             	movzbl (%eax),%eax
  8017dc:	0f b6 12             	movzbl (%edx),%edx
  8017df:	29 d0                	sub    %edx,%eax
  8017e1:	eb 05                	jmp    8017e8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017e3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017e8:	5b                   	pop    %ebx
  8017e9:	5d                   	pop    %ebp
  8017ea:	c3                   	ret    

008017eb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017f5:	eb 07                	jmp    8017fe <strchr+0x13>
		if (*s == c)
  8017f7:	38 ca                	cmp    %cl,%dl
  8017f9:	74 0f                	je     80180a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017fb:	83 c0 01             	add    $0x1,%eax
  8017fe:	0f b6 10             	movzbl (%eax),%edx
  801801:	84 d2                	test   %dl,%dl
  801803:	75 f2                	jne    8017f7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801805:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80180a:	5d                   	pop    %ebp
  80180b:	c3                   	ret    

0080180c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	8b 45 08             	mov    0x8(%ebp),%eax
  801812:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801816:	eb 03                	jmp    80181b <strfind+0xf>
  801818:	83 c0 01             	add    $0x1,%eax
  80181b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80181e:	38 ca                	cmp    %cl,%dl
  801820:	74 04                	je     801826 <strfind+0x1a>
  801822:	84 d2                	test   %dl,%dl
  801824:	75 f2                	jne    801818 <strfind+0xc>
			break;
	return (char *) s;
}
  801826:	5d                   	pop    %ebp
  801827:	c3                   	ret    

00801828 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801828:	55                   	push   %ebp
  801829:	89 e5                	mov    %esp,%ebp
  80182b:	57                   	push   %edi
  80182c:	56                   	push   %esi
  80182d:	53                   	push   %ebx
  80182e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801831:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801834:	85 c9                	test   %ecx,%ecx
  801836:	74 36                	je     80186e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801838:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80183e:	75 28                	jne    801868 <memset+0x40>
  801840:	f6 c1 03             	test   $0x3,%cl
  801843:	75 23                	jne    801868 <memset+0x40>
		c &= 0xFF;
  801845:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801849:	89 d3                	mov    %edx,%ebx
  80184b:	c1 e3 08             	shl    $0x8,%ebx
  80184e:	89 d6                	mov    %edx,%esi
  801850:	c1 e6 18             	shl    $0x18,%esi
  801853:	89 d0                	mov    %edx,%eax
  801855:	c1 e0 10             	shl    $0x10,%eax
  801858:	09 f0                	or     %esi,%eax
  80185a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80185c:	89 d8                	mov    %ebx,%eax
  80185e:	09 d0                	or     %edx,%eax
  801860:	c1 e9 02             	shr    $0x2,%ecx
  801863:	fc                   	cld    
  801864:	f3 ab                	rep stos %eax,%es:(%edi)
  801866:	eb 06                	jmp    80186e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801868:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186b:	fc                   	cld    
  80186c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80186e:	89 f8                	mov    %edi,%eax
  801870:	5b                   	pop    %ebx
  801871:	5e                   	pop    %esi
  801872:	5f                   	pop    %edi
  801873:	5d                   	pop    %ebp
  801874:	c3                   	ret    

00801875 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801875:	55                   	push   %ebp
  801876:	89 e5                	mov    %esp,%ebp
  801878:	57                   	push   %edi
  801879:	56                   	push   %esi
  80187a:	8b 45 08             	mov    0x8(%ebp),%eax
  80187d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801880:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801883:	39 c6                	cmp    %eax,%esi
  801885:	73 35                	jae    8018bc <memmove+0x47>
  801887:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80188a:	39 d0                	cmp    %edx,%eax
  80188c:	73 2e                	jae    8018bc <memmove+0x47>
		s += n;
		d += n;
  80188e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801891:	89 d6                	mov    %edx,%esi
  801893:	09 fe                	or     %edi,%esi
  801895:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80189b:	75 13                	jne    8018b0 <memmove+0x3b>
  80189d:	f6 c1 03             	test   $0x3,%cl
  8018a0:	75 0e                	jne    8018b0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018a2:	83 ef 04             	sub    $0x4,%edi
  8018a5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018a8:	c1 e9 02             	shr    $0x2,%ecx
  8018ab:	fd                   	std    
  8018ac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ae:	eb 09                	jmp    8018b9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018b0:	83 ef 01             	sub    $0x1,%edi
  8018b3:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018b6:	fd                   	std    
  8018b7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018b9:	fc                   	cld    
  8018ba:	eb 1d                	jmp    8018d9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018bc:	89 f2                	mov    %esi,%edx
  8018be:	09 c2                	or     %eax,%edx
  8018c0:	f6 c2 03             	test   $0x3,%dl
  8018c3:	75 0f                	jne    8018d4 <memmove+0x5f>
  8018c5:	f6 c1 03             	test   $0x3,%cl
  8018c8:	75 0a                	jne    8018d4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018ca:	c1 e9 02             	shr    $0x2,%ecx
  8018cd:	89 c7                	mov    %eax,%edi
  8018cf:	fc                   	cld    
  8018d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018d2:	eb 05                	jmp    8018d9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018d4:	89 c7                	mov    %eax,%edi
  8018d6:	fc                   	cld    
  8018d7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018d9:	5e                   	pop    %esi
  8018da:	5f                   	pop    %edi
  8018db:	5d                   	pop    %ebp
  8018dc:	c3                   	ret    

008018dd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018dd:	55                   	push   %ebp
  8018de:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018e0:	ff 75 10             	pushl  0x10(%ebp)
  8018e3:	ff 75 0c             	pushl  0xc(%ebp)
  8018e6:	ff 75 08             	pushl  0x8(%ebp)
  8018e9:	e8 87 ff ff ff       	call   801875 <memmove>
}
  8018ee:	c9                   	leave  
  8018ef:	c3                   	ret    

008018f0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	56                   	push   %esi
  8018f4:	53                   	push   %ebx
  8018f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018fb:	89 c6                	mov    %eax,%esi
  8018fd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801900:	eb 1a                	jmp    80191c <memcmp+0x2c>
		if (*s1 != *s2)
  801902:	0f b6 08             	movzbl (%eax),%ecx
  801905:	0f b6 1a             	movzbl (%edx),%ebx
  801908:	38 d9                	cmp    %bl,%cl
  80190a:	74 0a                	je     801916 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80190c:	0f b6 c1             	movzbl %cl,%eax
  80190f:	0f b6 db             	movzbl %bl,%ebx
  801912:	29 d8                	sub    %ebx,%eax
  801914:	eb 0f                	jmp    801925 <memcmp+0x35>
		s1++, s2++;
  801916:	83 c0 01             	add    $0x1,%eax
  801919:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80191c:	39 f0                	cmp    %esi,%eax
  80191e:	75 e2                	jne    801902 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801920:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801925:	5b                   	pop    %ebx
  801926:	5e                   	pop    %esi
  801927:	5d                   	pop    %ebp
  801928:	c3                   	ret    

00801929 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	53                   	push   %ebx
  80192d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801930:	89 c1                	mov    %eax,%ecx
  801932:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801935:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801939:	eb 0a                	jmp    801945 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80193b:	0f b6 10             	movzbl (%eax),%edx
  80193e:	39 da                	cmp    %ebx,%edx
  801940:	74 07                	je     801949 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801942:	83 c0 01             	add    $0x1,%eax
  801945:	39 c8                	cmp    %ecx,%eax
  801947:	72 f2                	jb     80193b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801949:	5b                   	pop    %ebx
  80194a:	5d                   	pop    %ebp
  80194b:	c3                   	ret    

0080194c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	57                   	push   %edi
  801950:	56                   	push   %esi
  801951:	53                   	push   %ebx
  801952:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801955:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801958:	eb 03                	jmp    80195d <strtol+0x11>
		s++;
  80195a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80195d:	0f b6 01             	movzbl (%ecx),%eax
  801960:	3c 20                	cmp    $0x20,%al
  801962:	74 f6                	je     80195a <strtol+0xe>
  801964:	3c 09                	cmp    $0x9,%al
  801966:	74 f2                	je     80195a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801968:	3c 2b                	cmp    $0x2b,%al
  80196a:	75 0a                	jne    801976 <strtol+0x2a>
		s++;
  80196c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80196f:	bf 00 00 00 00       	mov    $0x0,%edi
  801974:	eb 11                	jmp    801987 <strtol+0x3b>
  801976:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80197b:	3c 2d                	cmp    $0x2d,%al
  80197d:	75 08                	jne    801987 <strtol+0x3b>
		s++, neg = 1;
  80197f:	83 c1 01             	add    $0x1,%ecx
  801982:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801987:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80198d:	75 15                	jne    8019a4 <strtol+0x58>
  80198f:	80 39 30             	cmpb   $0x30,(%ecx)
  801992:	75 10                	jne    8019a4 <strtol+0x58>
  801994:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801998:	75 7c                	jne    801a16 <strtol+0xca>
		s += 2, base = 16;
  80199a:	83 c1 02             	add    $0x2,%ecx
  80199d:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019a2:	eb 16                	jmp    8019ba <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019a4:	85 db                	test   %ebx,%ebx
  8019a6:	75 12                	jne    8019ba <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019a8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019ad:	80 39 30             	cmpb   $0x30,(%ecx)
  8019b0:	75 08                	jne    8019ba <strtol+0x6e>
		s++, base = 8;
  8019b2:	83 c1 01             	add    $0x1,%ecx
  8019b5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8019bf:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019c2:	0f b6 11             	movzbl (%ecx),%edx
  8019c5:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019c8:	89 f3                	mov    %esi,%ebx
  8019ca:	80 fb 09             	cmp    $0x9,%bl
  8019cd:	77 08                	ja     8019d7 <strtol+0x8b>
			dig = *s - '0';
  8019cf:	0f be d2             	movsbl %dl,%edx
  8019d2:	83 ea 30             	sub    $0x30,%edx
  8019d5:	eb 22                	jmp    8019f9 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019d7:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019da:	89 f3                	mov    %esi,%ebx
  8019dc:	80 fb 19             	cmp    $0x19,%bl
  8019df:	77 08                	ja     8019e9 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019e1:	0f be d2             	movsbl %dl,%edx
  8019e4:	83 ea 57             	sub    $0x57,%edx
  8019e7:	eb 10                	jmp    8019f9 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019e9:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019ec:	89 f3                	mov    %esi,%ebx
  8019ee:	80 fb 19             	cmp    $0x19,%bl
  8019f1:	77 16                	ja     801a09 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019f3:	0f be d2             	movsbl %dl,%edx
  8019f6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019f9:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019fc:	7d 0b                	jge    801a09 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019fe:	83 c1 01             	add    $0x1,%ecx
  801a01:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a05:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a07:	eb b9                	jmp    8019c2 <strtol+0x76>

	if (endptr)
  801a09:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a0d:	74 0d                	je     801a1c <strtol+0xd0>
		*endptr = (char *) s;
  801a0f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a12:	89 0e                	mov    %ecx,(%esi)
  801a14:	eb 06                	jmp    801a1c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a16:	85 db                	test   %ebx,%ebx
  801a18:	74 98                	je     8019b2 <strtol+0x66>
  801a1a:	eb 9e                	jmp    8019ba <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a1c:	89 c2                	mov    %eax,%edx
  801a1e:	f7 da                	neg    %edx
  801a20:	85 ff                	test   %edi,%edi
  801a22:	0f 45 c2             	cmovne %edx,%eax
}
  801a25:	5b                   	pop    %ebx
  801a26:	5e                   	pop    %esi
  801a27:	5f                   	pop    %edi
  801a28:	5d                   	pop    %ebp
  801a29:	c3                   	ret    

00801a2a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a2a:	55                   	push   %ebp
  801a2b:	89 e5                	mov    %esp,%ebp
  801a2d:	56                   	push   %esi
  801a2e:	53                   	push   %ebx
  801a2f:	8b 75 08             	mov    0x8(%ebp),%esi
  801a32:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a35:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801a38:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801a3a:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801a3f:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801a42:	83 ec 0c             	sub    $0xc,%esp
  801a45:	50                   	push   %eax
  801a46:	e8 e6 e8 ff ff       	call   800331 <sys_ipc_recv>

	if (r < 0) {
  801a4b:	83 c4 10             	add    $0x10,%esp
  801a4e:	85 c0                	test   %eax,%eax
  801a50:	79 16                	jns    801a68 <ipc_recv+0x3e>
		if (from_env_store)
  801a52:	85 f6                	test   %esi,%esi
  801a54:	74 06                	je     801a5c <ipc_recv+0x32>
			*from_env_store = 0;
  801a56:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801a5c:	85 db                	test   %ebx,%ebx
  801a5e:	74 2c                	je     801a8c <ipc_recv+0x62>
			*perm_store = 0;
  801a60:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a66:	eb 24                	jmp    801a8c <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801a68:	85 f6                	test   %esi,%esi
  801a6a:	74 0a                	je     801a76 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801a6c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a71:	8b 40 74             	mov    0x74(%eax),%eax
  801a74:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801a76:	85 db                	test   %ebx,%ebx
  801a78:	74 0a                	je     801a84 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801a7a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7f:	8b 40 78             	mov    0x78(%eax),%eax
  801a82:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801a84:	a1 04 40 80 00       	mov    0x804004,%eax
  801a89:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801a8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8f:	5b                   	pop    %ebx
  801a90:	5e                   	pop    %esi
  801a91:	5d                   	pop    %ebp
  801a92:	c3                   	ret    

00801a93 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	57                   	push   %edi
  801a97:	56                   	push   %esi
  801a98:	53                   	push   %ebx
  801a99:	83 ec 0c             	sub    $0xc,%esp
  801a9c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a9f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aa2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801aa5:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801aa7:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801aac:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801aaf:	ff 75 14             	pushl  0x14(%ebp)
  801ab2:	53                   	push   %ebx
  801ab3:	56                   	push   %esi
  801ab4:	57                   	push   %edi
  801ab5:	e8 54 e8 ff ff       	call   80030e <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801aba:	83 c4 10             	add    $0x10,%esp
  801abd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ac0:	75 07                	jne    801ac9 <ipc_send+0x36>
			sys_yield();
  801ac2:	e8 9b e6 ff ff       	call   800162 <sys_yield>
  801ac7:	eb e6                	jmp    801aaf <ipc_send+0x1c>
		} else if (r < 0) {
  801ac9:	85 c0                	test   %eax,%eax
  801acb:	79 12                	jns    801adf <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801acd:	50                   	push   %eax
  801ace:	68 60 22 80 00       	push   $0x802260
  801ad3:	6a 51                	push   $0x51
  801ad5:	68 6d 22 80 00       	push   $0x80226d
  801ada:	e8 a6 f5 ff ff       	call   801085 <_panic>
		}
	}
}
  801adf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae2:	5b                   	pop    %ebx
  801ae3:	5e                   	pop    %esi
  801ae4:	5f                   	pop    %edi
  801ae5:	5d                   	pop    %ebp
  801ae6:	c3                   	ret    

00801ae7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801aed:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801af2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801af5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801afb:	8b 52 50             	mov    0x50(%edx),%edx
  801afe:	39 ca                	cmp    %ecx,%edx
  801b00:	75 0d                	jne    801b0f <ipc_find_env+0x28>
			return envs[i].env_id;
  801b02:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b05:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b0a:	8b 40 48             	mov    0x48(%eax),%eax
  801b0d:	eb 0f                	jmp    801b1e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b0f:	83 c0 01             	add    $0x1,%eax
  801b12:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b17:	75 d9                	jne    801af2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b1e:	5d                   	pop    %ebp
  801b1f:	c3                   	ret    

00801b20 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b26:	89 d0                	mov    %edx,%eax
  801b28:	c1 e8 16             	shr    $0x16,%eax
  801b2b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b32:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b37:	f6 c1 01             	test   $0x1,%cl
  801b3a:	74 1d                	je     801b59 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b3c:	c1 ea 0c             	shr    $0xc,%edx
  801b3f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b46:	f6 c2 01             	test   $0x1,%dl
  801b49:	74 0e                	je     801b59 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b4b:	c1 ea 0c             	shr    $0xc,%edx
  801b4e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b55:	ef 
  801b56:	0f b7 c0             	movzwl %ax,%eax
}
  801b59:	5d                   	pop    %ebp
  801b5a:	c3                   	ret    
  801b5b:	66 90                	xchg   %ax,%ax
  801b5d:	66 90                	xchg   %ax,%ax
  801b5f:	90                   	nop

00801b60 <__udivdi3>:
  801b60:	55                   	push   %ebp
  801b61:	57                   	push   %edi
  801b62:	56                   	push   %esi
  801b63:	53                   	push   %ebx
  801b64:	83 ec 1c             	sub    $0x1c,%esp
  801b67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b77:	85 f6                	test   %esi,%esi
  801b79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b7d:	89 ca                	mov    %ecx,%edx
  801b7f:	89 f8                	mov    %edi,%eax
  801b81:	75 3d                	jne    801bc0 <__udivdi3+0x60>
  801b83:	39 cf                	cmp    %ecx,%edi
  801b85:	0f 87 c5 00 00 00    	ja     801c50 <__udivdi3+0xf0>
  801b8b:	85 ff                	test   %edi,%edi
  801b8d:	89 fd                	mov    %edi,%ebp
  801b8f:	75 0b                	jne    801b9c <__udivdi3+0x3c>
  801b91:	b8 01 00 00 00       	mov    $0x1,%eax
  801b96:	31 d2                	xor    %edx,%edx
  801b98:	f7 f7                	div    %edi
  801b9a:	89 c5                	mov    %eax,%ebp
  801b9c:	89 c8                	mov    %ecx,%eax
  801b9e:	31 d2                	xor    %edx,%edx
  801ba0:	f7 f5                	div    %ebp
  801ba2:	89 c1                	mov    %eax,%ecx
  801ba4:	89 d8                	mov    %ebx,%eax
  801ba6:	89 cf                	mov    %ecx,%edi
  801ba8:	f7 f5                	div    %ebp
  801baa:	89 c3                	mov    %eax,%ebx
  801bac:	89 d8                	mov    %ebx,%eax
  801bae:	89 fa                	mov    %edi,%edx
  801bb0:	83 c4 1c             	add    $0x1c,%esp
  801bb3:	5b                   	pop    %ebx
  801bb4:	5e                   	pop    %esi
  801bb5:	5f                   	pop    %edi
  801bb6:	5d                   	pop    %ebp
  801bb7:	c3                   	ret    
  801bb8:	90                   	nop
  801bb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bc0:	39 ce                	cmp    %ecx,%esi
  801bc2:	77 74                	ja     801c38 <__udivdi3+0xd8>
  801bc4:	0f bd fe             	bsr    %esi,%edi
  801bc7:	83 f7 1f             	xor    $0x1f,%edi
  801bca:	0f 84 98 00 00 00    	je     801c68 <__udivdi3+0x108>
  801bd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bd5:	89 f9                	mov    %edi,%ecx
  801bd7:	89 c5                	mov    %eax,%ebp
  801bd9:	29 fb                	sub    %edi,%ebx
  801bdb:	d3 e6                	shl    %cl,%esi
  801bdd:	89 d9                	mov    %ebx,%ecx
  801bdf:	d3 ed                	shr    %cl,%ebp
  801be1:	89 f9                	mov    %edi,%ecx
  801be3:	d3 e0                	shl    %cl,%eax
  801be5:	09 ee                	or     %ebp,%esi
  801be7:	89 d9                	mov    %ebx,%ecx
  801be9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bed:	89 d5                	mov    %edx,%ebp
  801bef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801bf3:	d3 ed                	shr    %cl,%ebp
  801bf5:	89 f9                	mov    %edi,%ecx
  801bf7:	d3 e2                	shl    %cl,%edx
  801bf9:	89 d9                	mov    %ebx,%ecx
  801bfb:	d3 e8                	shr    %cl,%eax
  801bfd:	09 c2                	or     %eax,%edx
  801bff:	89 d0                	mov    %edx,%eax
  801c01:	89 ea                	mov    %ebp,%edx
  801c03:	f7 f6                	div    %esi
  801c05:	89 d5                	mov    %edx,%ebp
  801c07:	89 c3                	mov    %eax,%ebx
  801c09:	f7 64 24 0c          	mull   0xc(%esp)
  801c0d:	39 d5                	cmp    %edx,%ebp
  801c0f:	72 10                	jb     801c21 <__udivdi3+0xc1>
  801c11:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c15:	89 f9                	mov    %edi,%ecx
  801c17:	d3 e6                	shl    %cl,%esi
  801c19:	39 c6                	cmp    %eax,%esi
  801c1b:	73 07                	jae    801c24 <__udivdi3+0xc4>
  801c1d:	39 d5                	cmp    %edx,%ebp
  801c1f:	75 03                	jne    801c24 <__udivdi3+0xc4>
  801c21:	83 eb 01             	sub    $0x1,%ebx
  801c24:	31 ff                	xor    %edi,%edi
  801c26:	89 d8                	mov    %ebx,%eax
  801c28:	89 fa                	mov    %edi,%edx
  801c2a:	83 c4 1c             	add    $0x1c,%esp
  801c2d:	5b                   	pop    %ebx
  801c2e:	5e                   	pop    %esi
  801c2f:	5f                   	pop    %edi
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    
  801c32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c38:	31 ff                	xor    %edi,%edi
  801c3a:	31 db                	xor    %ebx,%ebx
  801c3c:	89 d8                	mov    %ebx,%eax
  801c3e:	89 fa                	mov    %edi,%edx
  801c40:	83 c4 1c             	add    $0x1c,%esp
  801c43:	5b                   	pop    %ebx
  801c44:	5e                   	pop    %esi
  801c45:	5f                   	pop    %edi
  801c46:	5d                   	pop    %ebp
  801c47:	c3                   	ret    
  801c48:	90                   	nop
  801c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c50:	89 d8                	mov    %ebx,%eax
  801c52:	f7 f7                	div    %edi
  801c54:	31 ff                	xor    %edi,%edi
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	89 d8                	mov    %ebx,%eax
  801c5a:	89 fa                	mov    %edi,%edx
  801c5c:	83 c4 1c             	add    $0x1c,%esp
  801c5f:	5b                   	pop    %ebx
  801c60:	5e                   	pop    %esi
  801c61:	5f                   	pop    %edi
  801c62:	5d                   	pop    %ebp
  801c63:	c3                   	ret    
  801c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c68:	39 ce                	cmp    %ecx,%esi
  801c6a:	72 0c                	jb     801c78 <__udivdi3+0x118>
  801c6c:	31 db                	xor    %ebx,%ebx
  801c6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c72:	0f 87 34 ff ff ff    	ja     801bac <__udivdi3+0x4c>
  801c78:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c7d:	e9 2a ff ff ff       	jmp    801bac <__udivdi3+0x4c>
  801c82:	66 90                	xchg   %ax,%ax
  801c84:	66 90                	xchg   %ax,%ax
  801c86:	66 90                	xchg   %ax,%ax
  801c88:	66 90                	xchg   %ax,%ax
  801c8a:	66 90                	xchg   %ax,%ax
  801c8c:	66 90                	xchg   %ax,%ax
  801c8e:	66 90                	xchg   %ax,%ax

00801c90 <__umoddi3>:
  801c90:	55                   	push   %ebp
  801c91:	57                   	push   %edi
  801c92:	56                   	push   %esi
  801c93:	53                   	push   %ebx
  801c94:	83 ec 1c             	sub    $0x1c,%esp
  801c97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ca3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ca7:	85 d2                	test   %edx,%edx
  801ca9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cb1:	89 f3                	mov    %esi,%ebx
  801cb3:	89 3c 24             	mov    %edi,(%esp)
  801cb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cba:	75 1c                	jne    801cd8 <__umoddi3+0x48>
  801cbc:	39 f7                	cmp    %esi,%edi
  801cbe:	76 50                	jbe    801d10 <__umoddi3+0x80>
  801cc0:	89 c8                	mov    %ecx,%eax
  801cc2:	89 f2                	mov    %esi,%edx
  801cc4:	f7 f7                	div    %edi
  801cc6:	89 d0                	mov    %edx,%eax
  801cc8:	31 d2                	xor    %edx,%edx
  801cca:	83 c4 1c             	add    $0x1c,%esp
  801ccd:	5b                   	pop    %ebx
  801cce:	5e                   	pop    %esi
  801ccf:	5f                   	pop    %edi
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    
  801cd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cd8:	39 f2                	cmp    %esi,%edx
  801cda:	89 d0                	mov    %edx,%eax
  801cdc:	77 52                	ja     801d30 <__umoddi3+0xa0>
  801cde:	0f bd ea             	bsr    %edx,%ebp
  801ce1:	83 f5 1f             	xor    $0x1f,%ebp
  801ce4:	75 5a                	jne    801d40 <__umoddi3+0xb0>
  801ce6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cea:	0f 82 e0 00 00 00    	jb     801dd0 <__umoddi3+0x140>
  801cf0:	39 0c 24             	cmp    %ecx,(%esp)
  801cf3:	0f 86 d7 00 00 00    	jbe    801dd0 <__umoddi3+0x140>
  801cf9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cfd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d01:	83 c4 1c             	add    $0x1c,%esp
  801d04:	5b                   	pop    %ebx
  801d05:	5e                   	pop    %esi
  801d06:	5f                   	pop    %edi
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    
  801d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d10:	85 ff                	test   %edi,%edi
  801d12:	89 fd                	mov    %edi,%ebp
  801d14:	75 0b                	jne    801d21 <__umoddi3+0x91>
  801d16:	b8 01 00 00 00       	mov    $0x1,%eax
  801d1b:	31 d2                	xor    %edx,%edx
  801d1d:	f7 f7                	div    %edi
  801d1f:	89 c5                	mov    %eax,%ebp
  801d21:	89 f0                	mov    %esi,%eax
  801d23:	31 d2                	xor    %edx,%edx
  801d25:	f7 f5                	div    %ebp
  801d27:	89 c8                	mov    %ecx,%eax
  801d29:	f7 f5                	div    %ebp
  801d2b:	89 d0                	mov    %edx,%eax
  801d2d:	eb 99                	jmp    801cc8 <__umoddi3+0x38>
  801d2f:	90                   	nop
  801d30:	89 c8                	mov    %ecx,%eax
  801d32:	89 f2                	mov    %esi,%edx
  801d34:	83 c4 1c             	add    $0x1c,%esp
  801d37:	5b                   	pop    %ebx
  801d38:	5e                   	pop    %esi
  801d39:	5f                   	pop    %edi
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    
  801d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d40:	8b 34 24             	mov    (%esp),%esi
  801d43:	bf 20 00 00 00       	mov    $0x20,%edi
  801d48:	89 e9                	mov    %ebp,%ecx
  801d4a:	29 ef                	sub    %ebp,%edi
  801d4c:	d3 e0                	shl    %cl,%eax
  801d4e:	89 f9                	mov    %edi,%ecx
  801d50:	89 f2                	mov    %esi,%edx
  801d52:	d3 ea                	shr    %cl,%edx
  801d54:	89 e9                	mov    %ebp,%ecx
  801d56:	09 c2                	or     %eax,%edx
  801d58:	89 d8                	mov    %ebx,%eax
  801d5a:	89 14 24             	mov    %edx,(%esp)
  801d5d:	89 f2                	mov    %esi,%edx
  801d5f:	d3 e2                	shl    %cl,%edx
  801d61:	89 f9                	mov    %edi,%ecx
  801d63:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d67:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d6b:	d3 e8                	shr    %cl,%eax
  801d6d:	89 e9                	mov    %ebp,%ecx
  801d6f:	89 c6                	mov    %eax,%esi
  801d71:	d3 e3                	shl    %cl,%ebx
  801d73:	89 f9                	mov    %edi,%ecx
  801d75:	89 d0                	mov    %edx,%eax
  801d77:	d3 e8                	shr    %cl,%eax
  801d79:	89 e9                	mov    %ebp,%ecx
  801d7b:	09 d8                	or     %ebx,%eax
  801d7d:	89 d3                	mov    %edx,%ebx
  801d7f:	89 f2                	mov    %esi,%edx
  801d81:	f7 34 24             	divl   (%esp)
  801d84:	89 d6                	mov    %edx,%esi
  801d86:	d3 e3                	shl    %cl,%ebx
  801d88:	f7 64 24 04          	mull   0x4(%esp)
  801d8c:	39 d6                	cmp    %edx,%esi
  801d8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d92:	89 d1                	mov    %edx,%ecx
  801d94:	89 c3                	mov    %eax,%ebx
  801d96:	72 08                	jb     801da0 <__umoddi3+0x110>
  801d98:	75 11                	jne    801dab <__umoddi3+0x11b>
  801d9a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d9e:	73 0b                	jae    801dab <__umoddi3+0x11b>
  801da0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801da4:	1b 14 24             	sbb    (%esp),%edx
  801da7:	89 d1                	mov    %edx,%ecx
  801da9:	89 c3                	mov    %eax,%ebx
  801dab:	8b 54 24 08          	mov    0x8(%esp),%edx
  801daf:	29 da                	sub    %ebx,%edx
  801db1:	19 ce                	sbb    %ecx,%esi
  801db3:	89 f9                	mov    %edi,%ecx
  801db5:	89 f0                	mov    %esi,%eax
  801db7:	d3 e0                	shl    %cl,%eax
  801db9:	89 e9                	mov    %ebp,%ecx
  801dbb:	d3 ea                	shr    %cl,%edx
  801dbd:	89 e9                	mov    %ebp,%ecx
  801dbf:	d3 ee                	shr    %cl,%esi
  801dc1:	09 d0                	or     %edx,%eax
  801dc3:	89 f2                	mov    %esi,%edx
  801dc5:	83 c4 1c             	add    $0x1c,%esp
  801dc8:	5b                   	pop    %ebx
  801dc9:	5e                   	pop    %esi
  801dca:	5f                   	pop    %edi
  801dcb:	5d                   	pop    %ebp
  801dcc:	c3                   	ret    
  801dcd:	8d 76 00             	lea    0x0(%esi),%esi
  801dd0:	29 f9                	sub    %edi,%ecx
  801dd2:	19 d6                	sbb    %edx,%esi
  801dd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dd8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ddc:	e9 18 ff ff ff       	jmp    801cf9 <__umoddi3+0x69>
