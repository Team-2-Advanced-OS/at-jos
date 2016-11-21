
obj/user/faultnostack.debug:     file format elf32-i386


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
  800039:	68 61 03 80 00       	push   $0x800361
  80003e:	6a 00                	push   $0x0
  800040:	e8 76 02 00 00       	call   8002bb <sys_env_set_pgfault_upcall>
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
	thisenv = &envs[ENVX(sys_getenvid())];
  80005f:	e8 ce 00 00 00       	call   800132 <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 30 80 00       	mov    %eax,0x803000

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
  80009d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a0:	e8 b8 04 00 00       	call   80055d <close_all>
	sys_env_destroy(0);
  8000a5:	83 ec 0c             	sub    $0xc,%esp
  8000a8:	6a 00                	push   $0x0
  8000aa:	e8 42 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 17                	jle    80012a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	68 6a 1e 80 00       	push   $0x801e6a
  80011e:	6a 23                	push   $0x23
  800120:	68 87 1e 80 00       	push   $0x801e87
  800125:	e8 7b 0f 00 00       	call   8010a5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_yield>:

void
sys_yield(void)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	57                   	push   %edi
  800155:	56                   	push   %esi
  800156:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 d3                	mov    %edx,%ebx
  800165:	89 d7                	mov    %edx,%edi
  800167:	89 d6                	mov    %edx,%esi
  800169:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5f                   	pop    %edi
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800179:	be 00 00 00 00       	mov    $0x0,%esi
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	89 f7                	mov    %esi,%edi
  80018e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800190:	85 c0                	test   %eax,%eax
  800192:	7e 17                	jle    8001ab <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	6a 04                	push   $0x4
  80019a:	68 6a 1e 80 00       	push   $0x801e6a
  80019f:	6a 23                	push   $0x23
  8001a1:	68 87 1e 80 00       	push   $0x801e87
  8001a6:	e8 fa 0e 00 00       	call   8010a5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ae:	5b                   	pop    %ebx
  8001af:	5e                   	pop    %esi
  8001b0:	5f                   	pop    %edi
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    

008001b3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	57                   	push   %edi
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ca:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001d2:	85 c0                	test   %eax,%eax
  8001d4:	7e 17                	jle    8001ed <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 05                	push   $0x5
  8001dc:	68 6a 1e 80 00       	push   $0x801e6a
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 87 1e 80 00       	push   $0x801e87
  8001e8:	e8 b8 0e 00 00       	call   8010a5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f0:	5b                   	pop    %ebx
  8001f1:	5e                   	pop    %esi
  8001f2:	5f                   	pop    %edi
  8001f3:	5d                   	pop    %ebp
  8001f4:	c3                   	ret    

008001f5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	57                   	push   %edi
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800203:	b8 06 00 00 00       	mov    $0x6,%eax
  800208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020b:	8b 55 08             	mov    0x8(%ebp),%edx
  80020e:	89 df                	mov    %ebx,%edi
  800210:	89 de                	mov    %ebx,%esi
  800212:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800214:	85 c0                	test   %eax,%eax
  800216:	7e 17                	jle    80022f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 06                	push   $0x6
  80021e:	68 6a 1e 80 00       	push   $0x801e6a
  800223:	6a 23                	push   $0x23
  800225:	68 87 1e 80 00       	push   $0x801e87
  80022a:	e8 76 0e 00 00       	call   8010a5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5f                   	pop    %edi
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    

00800237 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800240:	bb 00 00 00 00       	mov    $0x0,%ebx
  800245:	b8 08 00 00 00       	mov    $0x8,%eax
  80024a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024d:	8b 55 08             	mov    0x8(%ebp),%edx
  800250:	89 df                	mov    %ebx,%edi
  800252:	89 de                	mov    %ebx,%esi
  800254:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800256:	85 c0                	test   %eax,%eax
  800258:	7e 17                	jle    800271 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 08                	push   $0x8
  800260:	68 6a 1e 80 00       	push   $0x801e6a
  800265:	6a 23                	push   $0x23
  800267:	68 87 1e 80 00       	push   $0x801e87
  80026c:	e8 34 0e 00 00       	call   8010a5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800271:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800274:	5b                   	pop    %ebx
  800275:	5e                   	pop    %esi
  800276:	5f                   	pop    %edi
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800282:	bb 00 00 00 00       	mov    $0x0,%ebx
  800287:	b8 09 00 00 00       	mov    $0x9,%eax
  80028c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028f:	8b 55 08             	mov    0x8(%ebp),%edx
  800292:	89 df                	mov    %ebx,%edi
  800294:	89 de                	mov    %ebx,%esi
  800296:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	7e 17                	jle    8002b3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 09                	push   $0x9
  8002a2:	68 6a 1e 80 00       	push   $0x801e6a
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 87 1e 80 00       	push   $0x801e87
  8002ae:	e8 f2 0d 00 00       	call   8010a5 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d4:	89 df                	mov    %ebx,%edi
  8002d6:	89 de                	mov    %ebx,%esi
  8002d8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 17                	jle    8002f5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	50                   	push   %eax
  8002e2:	6a 0a                	push   $0xa
  8002e4:	68 6a 1e 80 00       	push   $0x801e6a
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 87 1e 80 00       	push   $0x801e87
  8002f0:	e8 b0 0d 00 00       	call   8010a5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800303:	be 00 00 00 00       	mov    $0x0,%esi
  800308:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800310:	8b 55 08             	mov    0x8(%ebp),%edx
  800313:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800316:	8b 7d 14             	mov    0x14(%ebp),%edi
  800319:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800329:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	89 cb                	mov    %ecx,%ebx
  800338:	89 cf                	mov    %ecx,%edi
  80033a:	89 ce                	mov    %ecx,%esi
  80033c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80033e:	85 c0                	test   %eax,%eax
  800340:	7e 17                	jle    800359 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800342:	83 ec 0c             	sub    $0xc,%esp
  800345:	50                   	push   %eax
  800346:	6a 0d                	push   $0xd
  800348:	68 6a 1e 80 00       	push   $0x801e6a
  80034d:	6a 23                	push   $0x23
  80034f:	68 87 1e 80 00       	push   $0x801e87
  800354:	e8 4c 0d 00 00       	call   8010a5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800359:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035c:	5b                   	pop    %ebx
  80035d:	5e                   	pop    %esi
  80035e:	5f                   	pop    %edi
  80035f:	5d                   	pop    %ebp
  800360:	c3                   	ret    

00800361 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800361:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800362:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  800367:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800369:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  80036c:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  80036e:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  800371:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  800374:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  800377:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  80037a:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  80037d:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  800380:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  800383:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  800386:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  800389:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  80038c:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  80038f:	61                   	popa   
	popfl
  800390:	9d                   	popf   
	ret
  800391:	c3                   	ret    

00800392 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800392:	55                   	push   %ebp
  800393:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800395:	8b 45 08             	mov    0x8(%ebp),%eax
  800398:	05 00 00 00 30       	add    $0x30000000,%eax
  80039d:	c1 e8 0c             	shr    $0xc,%eax
}
  8003a0:	5d                   	pop    %ebp
  8003a1:	c3                   	ret    

008003a2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a8:	05 00 00 00 30       	add    $0x30000000,%eax
  8003ad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003b2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003b7:	5d                   	pop    %ebp
  8003b8:	c3                   	ret    

008003b9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003bf:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003c4:	89 c2                	mov    %eax,%edx
  8003c6:	c1 ea 16             	shr    $0x16,%edx
  8003c9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003d0:	f6 c2 01             	test   $0x1,%dl
  8003d3:	74 11                	je     8003e6 <fd_alloc+0x2d>
  8003d5:	89 c2                	mov    %eax,%edx
  8003d7:	c1 ea 0c             	shr    $0xc,%edx
  8003da:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003e1:	f6 c2 01             	test   $0x1,%dl
  8003e4:	75 09                	jne    8003ef <fd_alloc+0x36>
			*fd_store = fd;
  8003e6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ed:	eb 17                	jmp    800406 <fd_alloc+0x4d>
  8003ef:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003f4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003f9:	75 c9                	jne    8003c4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003fb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800401:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800406:	5d                   	pop    %ebp
  800407:	c3                   	ret    

00800408 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800408:	55                   	push   %ebp
  800409:	89 e5                	mov    %esp,%ebp
  80040b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80040e:	83 f8 1f             	cmp    $0x1f,%eax
  800411:	77 36                	ja     800449 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800413:	c1 e0 0c             	shl    $0xc,%eax
  800416:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80041b:	89 c2                	mov    %eax,%edx
  80041d:	c1 ea 16             	shr    $0x16,%edx
  800420:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800427:	f6 c2 01             	test   $0x1,%dl
  80042a:	74 24                	je     800450 <fd_lookup+0x48>
  80042c:	89 c2                	mov    %eax,%edx
  80042e:	c1 ea 0c             	shr    $0xc,%edx
  800431:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800438:	f6 c2 01             	test   $0x1,%dl
  80043b:	74 1a                	je     800457 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80043d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800440:	89 02                	mov    %eax,(%edx)
	return 0;
  800442:	b8 00 00 00 00       	mov    $0x0,%eax
  800447:	eb 13                	jmp    80045c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800449:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80044e:	eb 0c                	jmp    80045c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800450:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800455:	eb 05                	jmp    80045c <fd_lookup+0x54>
  800457:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80045c:	5d                   	pop    %ebp
  80045d:	c3                   	ret    

0080045e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80045e:	55                   	push   %ebp
  80045f:	89 e5                	mov    %esp,%ebp
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800467:	ba 14 1f 80 00       	mov    $0x801f14,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80046c:	eb 13                	jmp    800481 <dev_lookup+0x23>
  80046e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800471:	39 08                	cmp    %ecx,(%eax)
  800473:	75 0c                	jne    800481 <dev_lookup+0x23>
			*dev = devtab[i];
  800475:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800478:	89 01                	mov    %eax,(%ecx)
			return 0;
  80047a:	b8 00 00 00 00       	mov    $0x0,%eax
  80047f:	eb 2e                	jmp    8004af <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800481:	8b 02                	mov    (%edx),%eax
  800483:	85 c0                	test   %eax,%eax
  800485:	75 e7                	jne    80046e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800487:	a1 04 40 80 00       	mov    0x804004,%eax
  80048c:	8b 40 48             	mov    0x48(%eax),%eax
  80048f:	83 ec 04             	sub    $0x4,%esp
  800492:	51                   	push   %ecx
  800493:	50                   	push   %eax
  800494:	68 98 1e 80 00       	push   $0x801e98
  800499:	e8 e0 0c 00 00       	call   80117e <cprintf>
	*dev = 0;
  80049e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004a7:	83 c4 10             	add    $0x10,%esp
  8004aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004af:	c9                   	leave  
  8004b0:	c3                   	ret    

008004b1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004b1:	55                   	push   %ebp
  8004b2:	89 e5                	mov    %esp,%ebp
  8004b4:	56                   	push   %esi
  8004b5:	53                   	push   %ebx
  8004b6:	83 ec 10             	sub    $0x10,%esp
  8004b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c2:	50                   	push   %eax
  8004c3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004c9:	c1 e8 0c             	shr    $0xc,%eax
  8004cc:	50                   	push   %eax
  8004cd:	e8 36 ff ff ff       	call   800408 <fd_lookup>
  8004d2:	83 c4 08             	add    $0x8,%esp
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	78 05                	js     8004de <fd_close+0x2d>
	    || fd != fd2)
  8004d9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004dc:	74 0c                	je     8004ea <fd_close+0x39>
		return (must_exist ? r : 0);
  8004de:	84 db                	test   %bl,%bl
  8004e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e5:	0f 44 c2             	cmove  %edx,%eax
  8004e8:	eb 41                	jmp    80052b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004f0:	50                   	push   %eax
  8004f1:	ff 36                	pushl  (%esi)
  8004f3:	e8 66 ff ff ff       	call   80045e <dev_lookup>
  8004f8:	89 c3                	mov    %eax,%ebx
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	85 c0                	test   %eax,%eax
  8004ff:	78 1a                	js     80051b <fd_close+0x6a>
		if (dev->dev_close)
  800501:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800504:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800507:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80050c:	85 c0                	test   %eax,%eax
  80050e:	74 0b                	je     80051b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800510:	83 ec 0c             	sub    $0xc,%esp
  800513:	56                   	push   %esi
  800514:	ff d0                	call   *%eax
  800516:	89 c3                	mov    %eax,%ebx
  800518:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	56                   	push   %esi
  80051f:	6a 00                	push   $0x0
  800521:	e8 cf fc ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800526:	83 c4 10             	add    $0x10,%esp
  800529:	89 d8                	mov    %ebx,%eax
}
  80052b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80052e:	5b                   	pop    %ebx
  80052f:	5e                   	pop    %esi
  800530:	5d                   	pop    %ebp
  800531:	c3                   	ret    

00800532 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800532:	55                   	push   %ebp
  800533:	89 e5                	mov    %esp,%ebp
  800535:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800538:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80053b:	50                   	push   %eax
  80053c:	ff 75 08             	pushl  0x8(%ebp)
  80053f:	e8 c4 fe ff ff       	call   800408 <fd_lookup>
  800544:	83 c4 08             	add    $0x8,%esp
  800547:	85 c0                	test   %eax,%eax
  800549:	78 10                	js     80055b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	6a 01                	push   $0x1
  800550:	ff 75 f4             	pushl  -0xc(%ebp)
  800553:	e8 59 ff ff ff       	call   8004b1 <fd_close>
  800558:	83 c4 10             	add    $0x10,%esp
}
  80055b:	c9                   	leave  
  80055c:	c3                   	ret    

0080055d <close_all>:

void
close_all(void)
{
  80055d:	55                   	push   %ebp
  80055e:	89 e5                	mov    %esp,%ebp
  800560:	53                   	push   %ebx
  800561:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800564:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800569:	83 ec 0c             	sub    $0xc,%esp
  80056c:	53                   	push   %ebx
  80056d:	e8 c0 ff ff ff       	call   800532 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800572:	83 c3 01             	add    $0x1,%ebx
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	83 fb 20             	cmp    $0x20,%ebx
  80057b:	75 ec                	jne    800569 <close_all+0xc>
		close(i);
}
  80057d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800580:	c9                   	leave  
  800581:	c3                   	ret    

00800582 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800582:	55                   	push   %ebp
  800583:	89 e5                	mov    %esp,%ebp
  800585:	57                   	push   %edi
  800586:	56                   	push   %esi
  800587:	53                   	push   %ebx
  800588:	83 ec 2c             	sub    $0x2c,%esp
  80058b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80058e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800591:	50                   	push   %eax
  800592:	ff 75 08             	pushl  0x8(%ebp)
  800595:	e8 6e fe ff ff       	call   800408 <fd_lookup>
  80059a:	83 c4 08             	add    $0x8,%esp
  80059d:	85 c0                	test   %eax,%eax
  80059f:	0f 88 c1 00 00 00    	js     800666 <dup+0xe4>
		return r;
	close(newfdnum);
  8005a5:	83 ec 0c             	sub    $0xc,%esp
  8005a8:	56                   	push   %esi
  8005a9:	e8 84 ff ff ff       	call   800532 <close>

	newfd = INDEX2FD(newfdnum);
  8005ae:	89 f3                	mov    %esi,%ebx
  8005b0:	c1 e3 0c             	shl    $0xc,%ebx
  8005b3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005b9:	83 c4 04             	add    $0x4,%esp
  8005bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005bf:	e8 de fd ff ff       	call   8003a2 <fd2data>
  8005c4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005c6:	89 1c 24             	mov    %ebx,(%esp)
  8005c9:	e8 d4 fd ff ff       	call   8003a2 <fd2data>
  8005ce:	83 c4 10             	add    $0x10,%esp
  8005d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005d4:	89 f8                	mov    %edi,%eax
  8005d6:	c1 e8 16             	shr    $0x16,%eax
  8005d9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005e0:	a8 01                	test   $0x1,%al
  8005e2:	74 37                	je     80061b <dup+0x99>
  8005e4:	89 f8                	mov    %edi,%eax
  8005e6:	c1 e8 0c             	shr    $0xc,%eax
  8005e9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005f0:	f6 c2 01             	test   $0x1,%dl
  8005f3:	74 26                	je     80061b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fc:	83 ec 0c             	sub    $0xc,%esp
  8005ff:	25 07 0e 00 00       	and    $0xe07,%eax
  800604:	50                   	push   %eax
  800605:	ff 75 d4             	pushl  -0x2c(%ebp)
  800608:	6a 00                	push   $0x0
  80060a:	57                   	push   %edi
  80060b:	6a 00                	push   $0x0
  80060d:	e8 a1 fb ff ff       	call   8001b3 <sys_page_map>
  800612:	89 c7                	mov    %eax,%edi
  800614:	83 c4 20             	add    $0x20,%esp
  800617:	85 c0                	test   %eax,%eax
  800619:	78 2e                	js     800649 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80061b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061e:	89 d0                	mov    %edx,%eax
  800620:	c1 e8 0c             	shr    $0xc,%eax
  800623:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80062a:	83 ec 0c             	sub    $0xc,%esp
  80062d:	25 07 0e 00 00       	and    $0xe07,%eax
  800632:	50                   	push   %eax
  800633:	53                   	push   %ebx
  800634:	6a 00                	push   $0x0
  800636:	52                   	push   %edx
  800637:	6a 00                	push   $0x0
  800639:	e8 75 fb ff ff       	call   8001b3 <sys_page_map>
  80063e:	89 c7                	mov    %eax,%edi
  800640:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800643:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800645:	85 ff                	test   %edi,%edi
  800647:	79 1d                	jns    800666 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	6a 00                	push   $0x0
  80064f:	e8 a1 fb ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800654:	83 c4 08             	add    $0x8,%esp
  800657:	ff 75 d4             	pushl  -0x2c(%ebp)
  80065a:	6a 00                	push   $0x0
  80065c:	e8 94 fb ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	89 f8                	mov    %edi,%eax
}
  800666:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800669:	5b                   	pop    %ebx
  80066a:	5e                   	pop    %esi
  80066b:	5f                   	pop    %edi
  80066c:	5d                   	pop    %ebp
  80066d:	c3                   	ret    

0080066e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	53                   	push   %ebx
  800672:	83 ec 14             	sub    $0x14,%esp
  800675:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800678:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80067b:	50                   	push   %eax
  80067c:	53                   	push   %ebx
  80067d:	e8 86 fd ff ff       	call   800408 <fd_lookup>
  800682:	83 c4 08             	add    $0x8,%esp
  800685:	89 c2                	mov    %eax,%edx
  800687:	85 c0                	test   %eax,%eax
  800689:	78 6d                	js     8006f8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800691:	50                   	push   %eax
  800692:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800695:	ff 30                	pushl  (%eax)
  800697:	e8 c2 fd ff ff       	call   80045e <dev_lookup>
  80069c:	83 c4 10             	add    $0x10,%esp
  80069f:	85 c0                	test   %eax,%eax
  8006a1:	78 4c                	js     8006ef <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006a6:	8b 42 08             	mov    0x8(%edx),%eax
  8006a9:	83 e0 03             	and    $0x3,%eax
  8006ac:	83 f8 01             	cmp    $0x1,%eax
  8006af:	75 21                	jne    8006d2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006b1:	a1 04 40 80 00       	mov    0x804004,%eax
  8006b6:	8b 40 48             	mov    0x48(%eax),%eax
  8006b9:	83 ec 04             	sub    $0x4,%esp
  8006bc:	53                   	push   %ebx
  8006bd:	50                   	push   %eax
  8006be:	68 d9 1e 80 00       	push   $0x801ed9
  8006c3:	e8 b6 0a 00 00       	call   80117e <cprintf>
		return -E_INVAL;
  8006c8:	83 c4 10             	add    $0x10,%esp
  8006cb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006d0:	eb 26                	jmp    8006f8 <read+0x8a>
	}
	if (!dev->dev_read)
  8006d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d5:	8b 40 08             	mov    0x8(%eax),%eax
  8006d8:	85 c0                	test   %eax,%eax
  8006da:	74 17                	je     8006f3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006dc:	83 ec 04             	sub    $0x4,%esp
  8006df:	ff 75 10             	pushl  0x10(%ebp)
  8006e2:	ff 75 0c             	pushl  0xc(%ebp)
  8006e5:	52                   	push   %edx
  8006e6:	ff d0                	call   *%eax
  8006e8:	89 c2                	mov    %eax,%edx
  8006ea:	83 c4 10             	add    $0x10,%esp
  8006ed:	eb 09                	jmp    8006f8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ef:	89 c2                	mov    %eax,%edx
  8006f1:	eb 05                	jmp    8006f8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006f3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006f8:	89 d0                	mov    %edx,%eax
  8006fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006fd:	c9                   	leave  
  8006fe:	c3                   	ret    

008006ff <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	57                   	push   %edi
  800703:	56                   	push   %esi
  800704:	53                   	push   %ebx
  800705:	83 ec 0c             	sub    $0xc,%esp
  800708:	8b 7d 08             	mov    0x8(%ebp),%edi
  80070b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80070e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800713:	eb 21                	jmp    800736 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800715:	83 ec 04             	sub    $0x4,%esp
  800718:	89 f0                	mov    %esi,%eax
  80071a:	29 d8                	sub    %ebx,%eax
  80071c:	50                   	push   %eax
  80071d:	89 d8                	mov    %ebx,%eax
  80071f:	03 45 0c             	add    0xc(%ebp),%eax
  800722:	50                   	push   %eax
  800723:	57                   	push   %edi
  800724:	e8 45 ff ff ff       	call   80066e <read>
		if (m < 0)
  800729:	83 c4 10             	add    $0x10,%esp
  80072c:	85 c0                	test   %eax,%eax
  80072e:	78 10                	js     800740 <readn+0x41>
			return m;
		if (m == 0)
  800730:	85 c0                	test   %eax,%eax
  800732:	74 0a                	je     80073e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800734:	01 c3                	add    %eax,%ebx
  800736:	39 f3                	cmp    %esi,%ebx
  800738:	72 db                	jb     800715 <readn+0x16>
  80073a:	89 d8                	mov    %ebx,%eax
  80073c:	eb 02                	jmp    800740 <readn+0x41>
  80073e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800740:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800743:	5b                   	pop    %ebx
  800744:	5e                   	pop    %esi
  800745:	5f                   	pop    %edi
  800746:	5d                   	pop    %ebp
  800747:	c3                   	ret    

00800748 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800748:	55                   	push   %ebp
  800749:	89 e5                	mov    %esp,%ebp
  80074b:	53                   	push   %ebx
  80074c:	83 ec 14             	sub    $0x14,%esp
  80074f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800752:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800755:	50                   	push   %eax
  800756:	53                   	push   %ebx
  800757:	e8 ac fc ff ff       	call   800408 <fd_lookup>
  80075c:	83 c4 08             	add    $0x8,%esp
  80075f:	89 c2                	mov    %eax,%edx
  800761:	85 c0                	test   %eax,%eax
  800763:	78 68                	js     8007cd <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800765:	83 ec 08             	sub    $0x8,%esp
  800768:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80076b:	50                   	push   %eax
  80076c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80076f:	ff 30                	pushl  (%eax)
  800771:	e8 e8 fc ff ff       	call   80045e <dev_lookup>
  800776:	83 c4 10             	add    $0x10,%esp
  800779:	85 c0                	test   %eax,%eax
  80077b:	78 47                	js     8007c4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80077d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800780:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800784:	75 21                	jne    8007a7 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800786:	a1 04 40 80 00       	mov    0x804004,%eax
  80078b:	8b 40 48             	mov    0x48(%eax),%eax
  80078e:	83 ec 04             	sub    $0x4,%esp
  800791:	53                   	push   %ebx
  800792:	50                   	push   %eax
  800793:	68 f5 1e 80 00       	push   $0x801ef5
  800798:	e8 e1 09 00 00       	call   80117e <cprintf>
		return -E_INVAL;
  80079d:	83 c4 10             	add    $0x10,%esp
  8007a0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007a5:	eb 26                	jmp    8007cd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007aa:	8b 52 0c             	mov    0xc(%edx),%edx
  8007ad:	85 d2                	test   %edx,%edx
  8007af:	74 17                	je     8007c8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007b1:	83 ec 04             	sub    $0x4,%esp
  8007b4:	ff 75 10             	pushl  0x10(%ebp)
  8007b7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ba:	50                   	push   %eax
  8007bb:	ff d2                	call   *%edx
  8007bd:	89 c2                	mov    %eax,%edx
  8007bf:	83 c4 10             	add    $0x10,%esp
  8007c2:	eb 09                	jmp    8007cd <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c4:	89 c2                	mov    %eax,%edx
  8007c6:	eb 05                	jmp    8007cd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007c8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007cd:	89 d0                	mov    %edx,%eax
  8007cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d2:	c9                   	leave  
  8007d3:	c3                   	ret    

008007d4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007da:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007dd:	50                   	push   %eax
  8007de:	ff 75 08             	pushl  0x8(%ebp)
  8007e1:	e8 22 fc ff ff       	call   800408 <fd_lookup>
  8007e6:	83 c4 08             	add    $0x8,%esp
  8007e9:	85 c0                	test   %eax,%eax
  8007eb:	78 0e                	js     8007fb <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    

008007fd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	53                   	push   %ebx
  800801:	83 ec 14             	sub    $0x14,%esp
  800804:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800807:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80080a:	50                   	push   %eax
  80080b:	53                   	push   %ebx
  80080c:	e8 f7 fb ff ff       	call   800408 <fd_lookup>
  800811:	83 c4 08             	add    $0x8,%esp
  800814:	89 c2                	mov    %eax,%edx
  800816:	85 c0                	test   %eax,%eax
  800818:	78 65                	js     80087f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80081a:	83 ec 08             	sub    $0x8,%esp
  80081d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800820:	50                   	push   %eax
  800821:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800824:	ff 30                	pushl  (%eax)
  800826:	e8 33 fc ff ff       	call   80045e <dev_lookup>
  80082b:	83 c4 10             	add    $0x10,%esp
  80082e:	85 c0                	test   %eax,%eax
  800830:	78 44                	js     800876 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800832:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800835:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800839:	75 21                	jne    80085c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80083b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800840:	8b 40 48             	mov    0x48(%eax),%eax
  800843:	83 ec 04             	sub    $0x4,%esp
  800846:	53                   	push   %ebx
  800847:	50                   	push   %eax
  800848:	68 b8 1e 80 00       	push   $0x801eb8
  80084d:	e8 2c 09 00 00       	call   80117e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800852:	83 c4 10             	add    $0x10,%esp
  800855:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80085a:	eb 23                	jmp    80087f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80085c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80085f:	8b 52 18             	mov    0x18(%edx),%edx
  800862:	85 d2                	test   %edx,%edx
  800864:	74 14                	je     80087a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800866:	83 ec 08             	sub    $0x8,%esp
  800869:	ff 75 0c             	pushl  0xc(%ebp)
  80086c:	50                   	push   %eax
  80086d:	ff d2                	call   *%edx
  80086f:	89 c2                	mov    %eax,%edx
  800871:	83 c4 10             	add    $0x10,%esp
  800874:	eb 09                	jmp    80087f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800876:	89 c2                	mov    %eax,%edx
  800878:	eb 05                	jmp    80087f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80087a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80087f:	89 d0                	mov    %edx,%eax
  800881:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800884:	c9                   	leave  
  800885:	c3                   	ret    

00800886 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	53                   	push   %ebx
  80088a:	83 ec 14             	sub    $0x14,%esp
  80088d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800890:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800893:	50                   	push   %eax
  800894:	ff 75 08             	pushl  0x8(%ebp)
  800897:	e8 6c fb ff ff       	call   800408 <fd_lookup>
  80089c:	83 c4 08             	add    $0x8,%esp
  80089f:	89 c2                	mov    %eax,%edx
  8008a1:	85 c0                	test   %eax,%eax
  8008a3:	78 58                	js     8008fd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a5:	83 ec 08             	sub    $0x8,%esp
  8008a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ab:	50                   	push   %eax
  8008ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008af:	ff 30                	pushl  (%eax)
  8008b1:	e8 a8 fb ff ff       	call   80045e <dev_lookup>
  8008b6:	83 c4 10             	add    $0x10,%esp
  8008b9:	85 c0                	test   %eax,%eax
  8008bb:	78 37                	js     8008f4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008c4:	74 32                	je     8008f8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008c6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008c9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008d0:	00 00 00 
	stat->st_isdir = 0;
  8008d3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008da:	00 00 00 
	stat->st_dev = dev;
  8008dd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008e3:	83 ec 08             	sub    $0x8,%esp
  8008e6:	53                   	push   %ebx
  8008e7:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ea:	ff 50 14             	call   *0x14(%eax)
  8008ed:	89 c2                	mov    %eax,%edx
  8008ef:	83 c4 10             	add    $0x10,%esp
  8008f2:	eb 09                	jmp    8008fd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008f4:	89 c2                	mov    %eax,%edx
  8008f6:	eb 05                	jmp    8008fd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008f8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008fd:	89 d0                	mov    %edx,%eax
  8008ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	56                   	push   %esi
  800908:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800909:	83 ec 08             	sub    $0x8,%esp
  80090c:	6a 00                	push   $0x0
  80090e:	ff 75 08             	pushl  0x8(%ebp)
  800911:	e8 0c 02 00 00       	call   800b22 <open>
  800916:	89 c3                	mov    %eax,%ebx
  800918:	83 c4 10             	add    $0x10,%esp
  80091b:	85 c0                	test   %eax,%eax
  80091d:	78 1b                	js     80093a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80091f:	83 ec 08             	sub    $0x8,%esp
  800922:	ff 75 0c             	pushl  0xc(%ebp)
  800925:	50                   	push   %eax
  800926:	e8 5b ff ff ff       	call   800886 <fstat>
  80092b:	89 c6                	mov    %eax,%esi
	close(fd);
  80092d:	89 1c 24             	mov    %ebx,(%esp)
  800930:	e8 fd fb ff ff       	call   800532 <close>
	return r;
  800935:	83 c4 10             	add    $0x10,%esp
  800938:	89 f0                	mov    %esi,%eax
}
  80093a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093d:	5b                   	pop    %ebx
  80093e:	5e                   	pop    %esi
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	56                   	push   %esi
  800945:	53                   	push   %ebx
  800946:	89 c6                	mov    %eax,%esi
  800948:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80094a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800951:	75 12                	jne    800965 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800953:	83 ec 0c             	sub    $0xc,%esp
  800956:	6a 01                	push   $0x1
  800958:	e8 ef 11 00 00       	call   801b4c <ipc_find_env>
  80095d:	a3 00 40 80 00       	mov    %eax,0x804000
  800962:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800965:	6a 07                	push   $0x7
  800967:	68 00 50 80 00       	push   $0x805000
  80096c:	56                   	push   %esi
  80096d:	ff 35 00 40 80 00    	pushl  0x804000
  800973:	e8 80 11 00 00       	call   801af8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800978:	83 c4 0c             	add    $0xc,%esp
  80097b:	6a 00                	push   $0x0
  80097d:	53                   	push   %ebx
  80097e:	6a 00                	push   $0x0
  800980:	e8 0a 11 00 00       	call   801a8f <ipc_recv>
}
  800985:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800988:	5b                   	pop    %ebx
  800989:	5e                   	pop    %esi
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
  800995:	8b 40 0c             	mov    0xc(%eax),%eax
  800998:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80099d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009aa:	b8 02 00 00 00       	mov    $0x2,%eax
  8009af:	e8 8d ff ff ff       	call   800941 <fsipc>
}
  8009b4:	c9                   	leave  
  8009b5:	c3                   	ret    

008009b6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cc:	b8 06 00 00 00       	mov    $0x6,%eax
  8009d1:	e8 6b ff ff ff       	call   800941 <fsipc>
}
  8009d6:	c9                   	leave  
  8009d7:	c3                   	ret    

008009d8 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	53                   	push   %ebx
  8009dc:	83 ec 04             	sub    $0x4,%esp
  8009df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f2:	b8 05 00 00 00       	mov    $0x5,%eax
  8009f7:	e8 45 ff ff ff       	call   800941 <fsipc>
  8009fc:	85 c0                	test   %eax,%eax
  8009fe:	78 2c                	js     800a2c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a00:	83 ec 08             	sub    $0x8,%esp
  800a03:	68 00 50 80 00       	push   $0x805000
  800a08:	53                   	push   %ebx
  800a09:	e8 f5 0c 00 00       	call   801703 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a0e:	a1 80 50 80 00       	mov    0x805080,%eax
  800a13:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a19:	a1 84 50 80 00       	mov    0x805084,%eax
  800a1e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a24:	83 c4 10             	add    $0x10,%esp
  800a27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a2f:	c9                   	leave  
  800a30:	c3                   	ret    

00800a31 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	53                   	push   %ebx
  800a35:	83 ec 08             	sub    $0x8,%esp
  800a38:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3e:	8b 52 0c             	mov    0xc(%edx),%edx
  800a41:	89 15 00 50 80 00    	mov    %edx,0x805000
  800a47:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a4c:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a51:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  800a54:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  800a5a:	53                   	push   %ebx
  800a5b:	ff 75 0c             	pushl  0xc(%ebp)
  800a5e:	68 08 50 80 00       	push   $0x805008
  800a63:	e8 2d 0e 00 00       	call   801895 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  800a68:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6d:	b8 04 00 00 00       	mov    $0x4,%eax
  800a72:	e8 ca fe ff ff       	call   800941 <fsipc>
  800a77:	83 c4 10             	add    $0x10,%esp
  800a7a:	85 c0                	test   %eax,%eax
  800a7c:	78 1d                	js     800a9b <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  800a7e:	39 d8                	cmp    %ebx,%eax
  800a80:	76 19                	jbe    800a9b <devfile_write+0x6a>
  800a82:	68 24 1f 80 00       	push   $0x801f24
  800a87:	68 30 1f 80 00       	push   $0x801f30
  800a8c:	68 a5 00 00 00       	push   $0xa5
  800a91:	68 45 1f 80 00       	push   $0x801f45
  800a96:	e8 0a 06 00 00       	call   8010a5 <_panic>
	return r;
}
  800a9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9e:	c9                   	leave  
  800a9f:	c3                   	ret    

00800aa0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aab:	8b 40 0c             	mov    0xc(%eax),%eax
  800aae:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ab3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ab9:	ba 00 00 00 00       	mov    $0x0,%edx
  800abe:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac3:	e8 79 fe ff ff       	call   800941 <fsipc>
  800ac8:	89 c3                	mov    %eax,%ebx
  800aca:	85 c0                	test   %eax,%eax
  800acc:	78 4b                	js     800b19 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ace:	39 c6                	cmp    %eax,%esi
  800ad0:	73 16                	jae    800ae8 <devfile_read+0x48>
  800ad2:	68 50 1f 80 00       	push   $0x801f50
  800ad7:	68 30 1f 80 00       	push   $0x801f30
  800adc:	6a 7c                	push   $0x7c
  800ade:	68 45 1f 80 00       	push   $0x801f45
  800ae3:	e8 bd 05 00 00       	call   8010a5 <_panic>
	assert(r <= PGSIZE);
  800ae8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aed:	7e 16                	jle    800b05 <devfile_read+0x65>
  800aef:	68 57 1f 80 00       	push   $0x801f57
  800af4:	68 30 1f 80 00       	push   $0x801f30
  800af9:	6a 7d                	push   $0x7d
  800afb:	68 45 1f 80 00       	push   $0x801f45
  800b00:	e8 a0 05 00 00       	call   8010a5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b05:	83 ec 04             	sub    $0x4,%esp
  800b08:	50                   	push   %eax
  800b09:	68 00 50 80 00       	push   $0x805000
  800b0e:	ff 75 0c             	pushl  0xc(%ebp)
  800b11:	e8 7f 0d 00 00       	call   801895 <memmove>
	return r;
  800b16:	83 c4 10             	add    $0x10,%esp
}
  800b19:	89 d8                	mov    %ebx,%eax
  800b1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	53                   	push   %ebx
  800b26:	83 ec 20             	sub    $0x20,%esp
  800b29:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b2c:	53                   	push   %ebx
  800b2d:	e8 98 0b 00 00       	call   8016ca <strlen>
  800b32:	83 c4 10             	add    $0x10,%esp
  800b35:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b3a:	7f 67                	jg     800ba3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b3c:	83 ec 0c             	sub    $0xc,%esp
  800b3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b42:	50                   	push   %eax
  800b43:	e8 71 f8 ff ff       	call   8003b9 <fd_alloc>
  800b48:	83 c4 10             	add    $0x10,%esp
		return r;
  800b4b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	78 57                	js     800ba8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b51:	83 ec 08             	sub    $0x8,%esp
  800b54:	53                   	push   %ebx
  800b55:	68 00 50 80 00       	push   $0x805000
  800b5a:	e8 a4 0b 00 00       	call   801703 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b62:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b67:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b6a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6f:	e8 cd fd ff ff       	call   800941 <fsipc>
  800b74:	89 c3                	mov    %eax,%ebx
  800b76:	83 c4 10             	add    $0x10,%esp
  800b79:	85 c0                	test   %eax,%eax
  800b7b:	79 14                	jns    800b91 <open+0x6f>
		fd_close(fd, 0);
  800b7d:	83 ec 08             	sub    $0x8,%esp
  800b80:	6a 00                	push   $0x0
  800b82:	ff 75 f4             	pushl  -0xc(%ebp)
  800b85:	e8 27 f9 ff ff       	call   8004b1 <fd_close>
		return r;
  800b8a:	83 c4 10             	add    $0x10,%esp
  800b8d:	89 da                	mov    %ebx,%edx
  800b8f:	eb 17                	jmp    800ba8 <open+0x86>
	}

	return fd2num(fd);
  800b91:	83 ec 0c             	sub    $0xc,%esp
  800b94:	ff 75 f4             	pushl  -0xc(%ebp)
  800b97:	e8 f6 f7 ff ff       	call   800392 <fd2num>
  800b9c:	89 c2                	mov    %eax,%edx
  800b9e:	83 c4 10             	add    $0x10,%esp
  800ba1:	eb 05                	jmp    800ba8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ba3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800ba8:	89 d0                	mov    %edx,%eax
  800baa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bad:	c9                   	leave  
  800bae:	c3                   	ret    

00800baf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bba:	b8 08 00 00 00       	mov    $0x8,%eax
  800bbf:	e8 7d fd ff ff       	call   800941 <fsipc>
}
  800bc4:	c9                   	leave  
  800bc5:	c3                   	ret    

00800bc6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bce:	83 ec 0c             	sub    $0xc,%esp
  800bd1:	ff 75 08             	pushl  0x8(%ebp)
  800bd4:	e8 c9 f7 ff ff       	call   8003a2 <fd2data>
  800bd9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bdb:	83 c4 08             	add    $0x8,%esp
  800bde:	68 63 1f 80 00       	push   $0x801f63
  800be3:	53                   	push   %ebx
  800be4:	e8 1a 0b 00 00       	call   801703 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800be9:	8b 46 04             	mov    0x4(%esi),%eax
  800bec:	2b 06                	sub    (%esi),%eax
  800bee:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bf4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bfb:	00 00 00 
	stat->st_dev = &devpipe;
  800bfe:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c05:	30 80 00 
	return 0;
}
  800c08:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	53                   	push   %ebx
  800c18:	83 ec 0c             	sub    $0xc,%esp
  800c1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c1e:	53                   	push   %ebx
  800c1f:	6a 00                	push   $0x0
  800c21:	e8 cf f5 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c26:	89 1c 24             	mov    %ebx,(%esp)
  800c29:	e8 74 f7 ff ff       	call   8003a2 <fd2data>
  800c2e:	83 c4 08             	add    $0x8,%esp
  800c31:	50                   	push   %eax
  800c32:	6a 00                	push   $0x0
  800c34:	e8 bc f5 ff ff       	call   8001f5 <sys_page_unmap>
}
  800c39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c3c:	c9                   	leave  
  800c3d:	c3                   	ret    

00800c3e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 1c             	sub    $0x1c,%esp
  800c47:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c4a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c4c:	a1 04 40 80 00       	mov    0x804004,%eax
  800c51:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c54:	83 ec 0c             	sub    $0xc,%esp
  800c57:	ff 75 e0             	pushl  -0x20(%ebp)
  800c5a:	e8 26 0f 00 00       	call   801b85 <pageref>
  800c5f:	89 c3                	mov    %eax,%ebx
  800c61:	89 3c 24             	mov    %edi,(%esp)
  800c64:	e8 1c 0f 00 00       	call   801b85 <pageref>
  800c69:	83 c4 10             	add    $0x10,%esp
  800c6c:	39 c3                	cmp    %eax,%ebx
  800c6e:	0f 94 c1             	sete   %cl
  800c71:	0f b6 c9             	movzbl %cl,%ecx
  800c74:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c77:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c7d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c80:	39 ce                	cmp    %ecx,%esi
  800c82:	74 1b                	je     800c9f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c84:	39 c3                	cmp    %eax,%ebx
  800c86:	75 c4                	jne    800c4c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c88:	8b 42 58             	mov    0x58(%edx),%eax
  800c8b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c8e:	50                   	push   %eax
  800c8f:	56                   	push   %esi
  800c90:	68 6a 1f 80 00       	push   $0x801f6a
  800c95:	e8 e4 04 00 00       	call   80117e <cprintf>
  800c9a:	83 c4 10             	add    $0x10,%esp
  800c9d:	eb ad                	jmp    800c4c <_pipeisclosed+0xe>
	}
}
  800c9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ca2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
  800cb0:	83 ec 28             	sub    $0x28,%esp
  800cb3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800cb6:	56                   	push   %esi
  800cb7:	e8 e6 f6 ff ff       	call   8003a2 <fd2data>
  800cbc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cbe:	83 c4 10             	add    $0x10,%esp
  800cc1:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc6:	eb 4b                	jmp    800d13 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800cc8:	89 da                	mov    %ebx,%edx
  800cca:	89 f0                	mov    %esi,%eax
  800ccc:	e8 6d ff ff ff       	call   800c3e <_pipeisclosed>
  800cd1:	85 c0                	test   %eax,%eax
  800cd3:	75 48                	jne    800d1d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cd5:	e8 77 f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cda:	8b 43 04             	mov    0x4(%ebx),%eax
  800cdd:	8b 0b                	mov    (%ebx),%ecx
  800cdf:	8d 51 20             	lea    0x20(%ecx),%edx
  800ce2:	39 d0                	cmp    %edx,%eax
  800ce4:	73 e2                	jae    800cc8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ced:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cf0:	89 c2                	mov    %eax,%edx
  800cf2:	c1 fa 1f             	sar    $0x1f,%edx
  800cf5:	89 d1                	mov    %edx,%ecx
  800cf7:	c1 e9 1b             	shr    $0x1b,%ecx
  800cfa:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cfd:	83 e2 1f             	and    $0x1f,%edx
  800d00:	29 ca                	sub    %ecx,%edx
  800d02:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800d06:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d0a:	83 c0 01             	add    $0x1,%eax
  800d0d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d10:	83 c7 01             	add    $0x1,%edi
  800d13:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d16:	75 c2                	jne    800cda <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800d18:	8b 45 10             	mov    0x10(%ebp),%eax
  800d1b:	eb 05                	jmp    800d22 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d1d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 18             	sub    $0x18,%esp
  800d33:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d36:	57                   	push   %edi
  800d37:	e8 66 f6 ff ff       	call   8003a2 <fd2data>
  800d3c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d3e:	83 c4 10             	add    $0x10,%esp
  800d41:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d46:	eb 3d                	jmp    800d85 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d48:	85 db                	test   %ebx,%ebx
  800d4a:	74 04                	je     800d50 <devpipe_read+0x26>
				return i;
  800d4c:	89 d8                	mov    %ebx,%eax
  800d4e:	eb 44                	jmp    800d94 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d50:	89 f2                	mov    %esi,%edx
  800d52:	89 f8                	mov    %edi,%eax
  800d54:	e8 e5 fe ff ff       	call   800c3e <_pipeisclosed>
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	75 32                	jne    800d8f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d5d:	e8 ef f3 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d62:	8b 06                	mov    (%esi),%eax
  800d64:	3b 46 04             	cmp    0x4(%esi),%eax
  800d67:	74 df                	je     800d48 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d69:	99                   	cltd   
  800d6a:	c1 ea 1b             	shr    $0x1b,%edx
  800d6d:	01 d0                	add    %edx,%eax
  800d6f:	83 e0 1f             	and    $0x1f,%eax
  800d72:	29 d0                	sub    %edx,%eax
  800d74:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d7f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d82:	83 c3 01             	add    $0x1,%ebx
  800d85:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d88:	75 d8                	jne    800d62 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d8a:	8b 45 10             	mov    0x10(%ebp),%eax
  800d8d:	eb 05                	jmp    800d94 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d8f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	56                   	push   %esi
  800da0:	53                   	push   %ebx
  800da1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800da4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800da7:	50                   	push   %eax
  800da8:	e8 0c f6 ff ff       	call   8003b9 <fd_alloc>
  800dad:	83 c4 10             	add    $0x10,%esp
  800db0:	89 c2                	mov    %eax,%edx
  800db2:	85 c0                	test   %eax,%eax
  800db4:	0f 88 2c 01 00 00    	js     800ee6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dba:	83 ec 04             	sub    $0x4,%esp
  800dbd:	68 07 04 00 00       	push   $0x407
  800dc2:	ff 75 f4             	pushl  -0xc(%ebp)
  800dc5:	6a 00                	push   $0x0
  800dc7:	e8 a4 f3 ff ff       	call   800170 <sys_page_alloc>
  800dcc:	83 c4 10             	add    $0x10,%esp
  800dcf:	89 c2                	mov    %eax,%edx
  800dd1:	85 c0                	test   %eax,%eax
  800dd3:	0f 88 0d 01 00 00    	js     800ee6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dd9:	83 ec 0c             	sub    $0xc,%esp
  800ddc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ddf:	50                   	push   %eax
  800de0:	e8 d4 f5 ff ff       	call   8003b9 <fd_alloc>
  800de5:	89 c3                	mov    %eax,%ebx
  800de7:	83 c4 10             	add    $0x10,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	0f 88 e2 00 00 00    	js     800ed4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df2:	83 ec 04             	sub    $0x4,%esp
  800df5:	68 07 04 00 00       	push   $0x407
  800dfa:	ff 75 f0             	pushl  -0x10(%ebp)
  800dfd:	6a 00                	push   $0x0
  800dff:	e8 6c f3 ff ff       	call   800170 <sys_page_alloc>
  800e04:	89 c3                	mov    %eax,%ebx
  800e06:	83 c4 10             	add    $0x10,%esp
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	0f 88 c3 00 00 00    	js     800ed4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800e11:	83 ec 0c             	sub    $0xc,%esp
  800e14:	ff 75 f4             	pushl  -0xc(%ebp)
  800e17:	e8 86 f5 ff ff       	call   8003a2 <fd2data>
  800e1c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e1e:	83 c4 0c             	add    $0xc,%esp
  800e21:	68 07 04 00 00       	push   $0x407
  800e26:	50                   	push   %eax
  800e27:	6a 00                	push   $0x0
  800e29:	e8 42 f3 ff ff       	call   800170 <sys_page_alloc>
  800e2e:	89 c3                	mov    %eax,%ebx
  800e30:	83 c4 10             	add    $0x10,%esp
  800e33:	85 c0                	test   %eax,%eax
  800e35:	0f 88 89 00 00 00    	js     800ec4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e3b:	83 ec 0c             	sub    $0xc,%esp
  800e3e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e41:	e8 5c f5 ff ff       	call   8003a2 <fd2data>
  800e46:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e4d:	50                   	push   %eax
  800e4e:	6a 00                	push   $0x0
  800e50:	56                   	push   %esi
  800e51:	6a 00                	push   $0x0
  800e53:	e8 5b f3 ff ff       	call   8001b3 <sys_page_map>
  800e58:	89 c3                	mov    %eax,%ebx
  800e5a:	83 c4 20             	add    $0x20,%esp
  800e5d:	85 c0                	test   %eax,%eax
  800e5f:	78 55                	js     800eb6 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e61:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e6a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e6f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e76:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e7f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e81:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e84:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e8b:	83 ec 0c             	sub    $0xc,%esp
  800e8e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e91:	e8 fc f4 ff ff       	call   800392 <fd2num>
  800e96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e99:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e9b:	83 c4 04             	add    $0x4,%esp
  800e9e:	ff 75 f0             	pushl  -0x10(%ebp)
  800ea1:	e8 ec f4 ff ff       	call   800392 <fd2num>
  800ea6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800eac:	83 c4 10             	add    $0x10,%esp
  800eaf:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb4:	eb 30                	jmp    800ee6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800eb6:	83 ec 08             	sub    $0x8,%esp
  800eb9:	56                   	push   %esi
  800eba:	6a 00                	push   $0x0
  800ebc:	e8 34 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800ec1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800ec4:	83 ec 08             	sub    $0x8,%esp
  800ec7:	ff 75 f0             	pushl  -0x10(%ebp)
  800eca:	6a 00                	push   $0x0
  800ecc:	e8 24 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800ed1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800ed4:	83 ec 08             	sub    $0x8,%esp
  800ed7:	ff 75 f4             	pushl  -0xc(%ebp)
  800eda:	6a 00                	push   $0x0
  800edc:	e8 14 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800ee1:	83 c4 10             	add    $0x10,%esp
  800ee4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ee6:	89 d0                	mov    %edx,%eax
  800ee8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eeb:	5b                   	pop    %ebx
  800eec:	5e                   	pop    %esi
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    

00800eef <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ef5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ef8:	50                   	push   %eax
  800ef9:	ff 75 08             	pushl  0x8(%ebp)
  800efc:	e8 07 f5 ff ff       	call   800408 <fd_lookup>
  800f01:	83 c4 10             	add    $0x10,%esp
  800f04:	85 c0                	test   %eax,%eax
  800f06:	78 18                	js     800f20 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800f08:	83 ec 0c             	sub    $0xc,%esp
  800f0b:	ff 75 f4             	pushl  -0xc(%ebp)
  800f0e:	e8 8f f4 ff ff       	call   8003a2 <fd2data>
	return _pipeisclosed(fd, p);
  800f13:	89 c2                	mov    %eax,%edx
  800f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f18:	e8 21 fd ff ff       	call   800c3e <_pipeisclosed>
  800f1d:	83 c4 10             	add    $0x10,%esp
}
  800f20:	c9                   	leave  
  800f21:	c3                   	ret    

00800f22 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800f25:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f32:	68 82 1f 80 00       	push   $0x801f82
  800f37:	ff 75 0c             	pushl  0xc(%ebp)
  800f3a:	e8 c4 07 00 00       	call   801703 <strcpy>
	return 0;
}
  800f3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f44:	c9                   	leave  
  800f45:	c3                   	ret    

00800f46 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	57                   	push   %edi
  800f4a:	56                   	push   %esi
  800f4b:	53                   	push   %ebx
  800f4c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f52:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f57:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f5d:	eb 2d                	jmp    800f8c <devcons_write+0x46>
		m = n - tot;
  800f5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f62:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f64:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f67:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f6c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f6f:	83 ec 04             	sub    $0x4,%esp
  800f72:	53                   	push   %ebx
  800f73:	03 45 0c             	add    0xc(%ebp),%eax
  800f76:	50                   	push   %eax
  800f77:	57                   	push   %edi
  800f78:	e8 18 09 00 00       	call   801895 <memmove>
		sys_cputs(buf, m);
  800f7d:	83 c4 08             	add    $0x8,%esp
  800f80:	53                   	push   %ebx
  800f81:	57                   	push   %edi
  800f82:	e8 2d f1 ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f87:	01 de                	add    %ebx,%esi
  800f89:	83 c4 10             	add    $0x10,%esp
  800f8c:	89 f0                	mov    %esi,%eax
  800f8e:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f91:	72 cc                	jb     800f5f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f96:	5b                   	pop    %ebx
  800f97:	5e                   	pop    %esi
  800f98:	5f                   	pop    %edi
  800f99:	5d                   	pop    %ebp
  800f9a:	c3                   	ret    

00800f9b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	83 ec 08             	sub    $0x8,%esp
  800fa1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800fa6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800faa:	74 2a                	je     800fd6 <devcons_read+0x3b>
  800fac:	eb 05                	jmp    800fb3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800fae:	e8 9e f1 ff ff       	call   800151 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800fb3:	e8 1a f1 ff ff       	call   8000d2 <sys_cgetc>
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	74 f2                	je     800fae <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	78 16                	js     800fd6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800fc0:	83 f8 04             	cmp    $0x4,%eax
  800fc3:	74 0c                	je     800fd1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800fc5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc8:	88 02                	mov    %al,(%edx)
	return 1;
  800fca:	b8 01 00 00 00       	mov    $0x1,%eax
  800fcf:	eb 05                	jmp    800fd6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fd1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fd6:	c9                   	leave  
  800fd7:	c3                   	ret    

00800fd8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fde:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fe4:	6a 01                	push   $0x1
  800fe6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fe9:	50                   	push   %eax
  800fea:	e8 c5 f0 ff ff       	call   8000b4 <sys_cputs>
}
  800fef:	83 c4 10             	add    $0x10,%esp
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <getchar>:

int
getchar(void)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800ffa:	6a 01                	push   $0x1
  800ffc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fff:	50                   	push   %eax
  801000:	6a 00                	push   $0x0
  801002:	e8 67 f6 ff ff       	call   80066e <read>
	if (r < 0)
  801007:	83 c4 10             	add    $0x10,%esp
  80100a:	85 c0                	test   %eax,%eax
  80100c:	78 0f                	js     80101d <getchar+0x29>
		return r;
	if (r < 1)
  80100e:	85 c0                	test   %eax,%eax
  801010:	7e 06                	jle    801018 <getchar+0x24>
		return -E_EOF;
	return c;
  801012:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801016:	eb 05                	jmp    80101d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801018:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80101d:	c9                   	leave  
  80101e:	c3                   	ret    

0080101f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801025:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801028:	50                   	push   %eax
  801029:	ff 75 08             	pushl  0x8(%ebp)
  80102c:	e8 d7 f3 ff ff       	call   800408 <fd_lookup>
  801031:	83 c4 10             	add    $0x10,%esp
  801034:	85 c0                	test   %eax,%eax
  801036:	78 11                	js     801049 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801041:	39 10                	cmp    %edx,(%eax)
  801043:	0f 94 c0             	sete   %al
  801046:	0f b6 c0             	movzbl %al,%eax
}
  801049:	c9                   	leave  
  80104a:	c3                   	ret    

0080104b <opencons>:

int
opencons(void)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801051:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801054:	50                   	push   %eax
  801055:	e8 5f f3 ff ff       	call   8003b9 <fd_alloc>
  80105a:	83 c4 10             	add    $0x10,%esp
		return r;
  80105d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80105f:	85 c0                	test   %eax,%eax
  801061:	78 3e                	js     8010a1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801063:	83 ec 04             	sub    $0x4,%esp
  801066:	68 07 04 00 00       	push   $0x407
  80106b:	ff 75 f4             	pushl  -0xc(%ebp)
  80106e:	6a 00                	push   $0x0
  801070:	e8 fb f0 ff ff       	call   800170 <sys_page_alloc>
  801075:	83 c4 10             	add    $0x10,%esp
		return r;
  801078:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80107a:	85 c0                	test   %eax,%eax
  80107c:	78 23                	js     8010a1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80107e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801084:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801087:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801089:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80108c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801093:	83 ec 0c             	sub    $0xc,%esp
  801096:	50                   	push   %eax
  801097:	e8 f6 f2 ff ff       	call   800392 <fd2num>
  80109c:	89 c2                	mov    %eax,%edx
  80109e:	83 c4 10             	add    $0x10,%esp
}
  8010a1:	89 d0                	mov    %edx,%eax
  8010a3:	c9                   	leave  
  8010a4:	c3                   	ret    

008010a5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
  8010a8:	56                   	push   %esi
  8010a9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010aa:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010ad:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010b3:	e8 7a f0 ff ff       	call   800132 <sys_getenvid>
  8010b8:	83 ec 0c             	sub    $0xc,%esp
  8010bb:	ff 75 0c             	pushl  0xc(%ebp)
  8010be:	ff 75 08             	pushl  0x8(%ebp)
  8010c1:	56                   	push   %esi
  8010c2:	50                   	push   %eax
  8010c3:	68 90 1f 80 00       	push   $0x801f90
  8010c8:	e8 b1 00 00 00       	call   80117e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010cd:	83 c4 18             	add    $0x18,%esp
  8010d0:	53                   	push   %ebx
  8010d1:	ff 75 10             	pushl  0x10(%ebp)
  8010d4:	e8 54 00 00 00       	call   80112d <vcprintf>
	cprintf("\n");
  8010d9:	c7 04 24 7b 1f 80 00 	movl   $0x801f7b,(%esp)
  8010e0:	e8 99 00 00 00       	call   80117e <cprintf>
  8010e5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010e8:	cc                   	int3   
  8010e9:	eb fd                	jmp    8010e8 <_panic+0x43>

008010eb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	53                   	push   %ebx
  8010ef:	83 ec 04             	sub    $0x4,%esp
  8010f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010f5:	8b 13                	mov    (%ebx),%edx
  8010f7:	8d 42 01             	lea    0x1(%edx),%eax
  8010fa:	89 03                	mov    %eax,(%ebx)
  8010fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ff:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801103:	3d ff 00 00 00       	cmp    $0xff,%eax
  801108:	75 1a                	jne    801124 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80110a:	83 ec 08             	sub    $0x8,%esp
  80110d:	68 ff 00 00 00       	push   $0xff
  801112:	8d 43 08             	lea    0x8(%ebx),%eax
  801115:	50                   	push   %eax
  801116:	e8 99 ef ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  80111b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801121:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801124:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801128:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80112b:	c9                   	leave  
  80112c:	c3                   	ret    

0080112d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801136:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80113d:	00 00 00 
	b.cnt = 0;
  801140:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801147:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80114a:	ff 75 0c             	pushl  0xc(%ebp)
  80114d:	ff 75 08             	pushl  0x8(%ebp)
  801150:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801156:	50                   	push   %eax
  801157:	68 eb 10 80 00       	push   $0x8010eb
  80115c:	e8 54 01 00 00       	call   8012b5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801161:	83 c4 08             	add    $0x8,%esp
  801164:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80116a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801170:	50                   	push   %eax
  801171:	e8 3e ef ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  801176:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80117c:	c9                   	leave  
  80117d:	c3                   	ret    

0080117e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801184:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801187:	50                   	push   %eax
  801188:	ff 75 08             	pushl  0x8(%ebp)
  80118b:	e8 9d ff ff ff       	call   80112d <vcprintf>
	va_end(ap);

	return cnt;
}
  801190:	c9                   	leave  
  801191:	c3                   	ret    

00801192 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	57                   	push   %edi
  801196:	56                   	push   %esi
  801197:	53                   	push   %ebx
  801198:	83 ec 1c             	sub    $0x1c,%esp
  80119b:	89 c7                	mov    %eax,%edi
  80119d:	89 d6                	mov    %edx,%esi
  80119f:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8011a8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8011ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8011b6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8011b9:	39 d3                	cmp    %edx,%ebx
  8011bb:	72 05                	jb     8011c2 <printnum+0x30>
  8011bd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8011c0:	77 45                	ja     801207 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011c2:	83 ec 0c             	sub    $0xc,%esp
  8011c5:	ff 75 18             	pushl  0x18(%ebp)
  8011c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8011cb:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011ce:	53                   	push   %ebx
  8011cf:	ff 75 10             	pushl  0x10(%ebp)
  8011d2:	83 ec 08             	sub    $0x8,%esp
  8011d5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8011db:	ff 75 dc             	pushl  -0x24(%ebp)
  8011de:	ff 75 d8             	pushl  -0x28(%ebp)
  8011e1:	e8 da 09 00 00       	call   801bc0 <__udivdi3>
  8011e6:	83 c4 18             	add    $0x18,%esp
  8011e9:	52                   	push   %edx
  8011ea:	50                   	push   %eax
  8011eb:	89 f2                	mov    %esi,%edx
  8011ed:	89 f8                	mov    %edi,%eax
  8011ef:	e8 9e ff ff ff       	call   801192 <printnum>
  8011f4:	83 c4 20             	add    $0x20,%esp
  8011f7:	eb 18                	jmp    801211 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011f9:	83 ec 08             	sub    $0x8,%esp
  8011fc:	56                   	push   %esi
  8011fd:	ff 75 18             	pushl  0x18(%ebp)
  801200:	ff d7                	call   *%edi
  801202:	83 c4 10             	add    $0x10,%esp
  801205:	eb 03                	jmp    80120a <printnum+0x78>
  801207:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80120a:	83 eb 01             	sub    $0x1,%ebx
  80120d:	85 db                	test   %ebx,%ebx
  80120f:	7f e8                	jg     8011f9 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801211:	83 ec 08             	sub    $0x8,%esp
  801214:	56                   	push   %esi
  801215:	83 ec 04             	sub    $0x4,%esp
  801218:	ff 75 e4             	pushl  -0x1c(%ebp)
  80121b:	ff 75 e0             	pushl  -0x20(%ebp)
  80121e:	ff 75 dc             	pushl  -0x24(%ebp)
  801221:	ff 75 d8             	pushl  -0x28(%ebp)
  801224:	e8 c7 0a 00 00       	call   801cf0 <__umoddi3>
  801229:	83 c4 14             	add    $0x14,%esp
  80122c:	0f be 80 b3 1f 80 00 	movsbl 0x801fb3(%eax),%eax
  801233:	50                   	push   %eax
  801234:	ff d7                	call   *%edi
}
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123c:	5b                   	pop    %ebx
  80123d:	5e                   	pop    %esi
  80123e:	5f                   	pop    %edi
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    

00801241 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801244:	83 fa 01             	cmp    $0x1,%edx
  801247:	7e 0e                	jle    801257 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801249:	8b 10                	mov    (%eax),%edx
  80124b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80124e:	89 08                	mov    %ecx,(%eax)
  801250:	8b 02                	mov    (%edx),%eax
  801252:	8b 52 04             	mov    0x4(%edx),%edx
  801255:	eb 22                	jmp    801279 <getuint+0x38>
	else if (lflag)
  801257:	85 d2                	test   %edx,%edx
  801259:	74 10                	je     80126b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80125b:	8b 10                	mov    (%eax),%edx
  80125d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801260:	89 08                	mov    %ecx,(%eax)
  801262:	8b 02                	mov    (%edx),%eax
  801264:	ba 00 00 00 00       	mov    $0x0,%edx
  801269:	eb 0e                	jmp    801279 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80126b:	8b 10                	mov    (%eax),%edx
  80126d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801270:	89 08                	mov    %ecx,(%eax)
  801272:	8b 02                	mov    (%edx),%eax
  801274:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801279:	5d                   	pop    %ebp
  80127a:	c3                   	ret    

0080127b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801281:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801285:	8b 10                	mov    (%eax),%edx
  801287:	3b 50 04             	cmp    0x4(%eax),%edx
  80128a:	73 0a                	jae    801296 <sprintputch+0x1b>
		*b->buf++ = ch;
  80128c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80128f:	89 08                	mov    %ecx,(%eax)
  801291:	8b 45 08             	mov    0x8(%ebp),%eax
  801294:	88 02                	mov    %al,(%edx)
}
  801296:	5d                   	pop    %ebp
  801297:	c3                   	ret    

00801298 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80129e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012a1:	50                   	push   %eax
  8012a2:	ff 75 10             	pushl  0x10(%ebp)
  8012a5:	ff 75 0c             	pushl  0xc(%ebp)
  8012a8:	ff 75 08             	pushl  0x8(%ebp)
  8012ab:	e8 05 00 00 00       	call   8012b5 <vprintfmt>
	va_end(ap);
}
  8012b0:	83 c4 10             	add    $0x10,%esp
  8012b3:	c9                   	leave  
  8012b4:	c3                   	ret    

008012b5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	57                   	push   %edi
  8012b9:	56                   	push   %esi
  8012ba:	53                   	push   %ebx
  8012bb:	83 ec 2c             	sub    $0x2c,%esp
  8012be:	8b 75 08             	mov    0x8(%ebp),%esi
  8012c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012c4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012c7:	eb 12                	jmp    8012db <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	0f 84 89 03 00 00    	je     80165a <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8012d1:	83 ec 08             	sub    $0x8,%esp
  8012d4:	53                   	push   %ebx
  8012d5:	50                   	push   %eax
  8012d6:	ff d6                	call   *%esi
  8012d8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012db:	83 c7 01             	add    $0x1,%edi
  8012de:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012e2:	83 f8 25             	cmp    $0x25,%eax
  8012e5:	75 e2                	jne    8012c9 <vprintfmt+0x14>
  8012e7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012eb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012f2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012f9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801300:	ba 00 00 00 00       	mov    $0x0,%edx
  801305:	eb 07                	jmp    80130e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801307:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80130a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130e:	8d 47 01             	lea    0x1(%edi),%eax
  801311:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801314:	0f b6 07             	movzbl (%edi),%eax
  801317:	0f b6 c8             	movzbl %al,%ecx
  80131a:	83 e8 23             	sub    $0x23,%eax
  80131d:	3c 55                	cmp    $0x55,%al
  80131f:	0f 87 1a 03 00 00    	ja     80163f <vprintfmt+0x38a>
  801325:	0f b6 c0             	movzbl %al,%eax
  801328:	ff 24 85 00 21 80 00 	jmp    *0x802100(,%eax,4)
  80132f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801332:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801336:	eb d6                	jmp    80130e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801338:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80133b:	b8 00 00 00 00       	mov    $0x0,%eax
  801340:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801343:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801346:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80134a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80134d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801350:	83 fa 09             	cmp    $0x9,%edx
  801353:	77 39                	ja     80138e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801355:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801358:	eb e9                	jmp    801343 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80135a:	8b 45 14             	mov    0x14(%ebp),%eax
  80135d:	8d 48 04             	lea    0x4(%eax),%ecx
  801360:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801363:	8b 00                	mov    (%eax),%eax
  801365:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80136b:	eb 27                	jmp    801394 <vprintfmt+0xdf>
  80136d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801370:	85 c0                	test   %eax,%eax
  801372:	b9 00 00 00 00       	mov    $0x0,%ecx
  801377:	0f 49 c8             	cmovns %eax,%ecx
  80137a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801380:	eb 8c                	jmp    80130e <vprintfmt+0x59>
  801382:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801385:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80138c:	eb 80                	jmp    80130e <vprintfmt+0x59>
  80138e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801391:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801394:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801398:	0f 89 70 ff ff ff    	jns    80130e <vprintfmt+0x59>
				width = precision, precision = -1;
  80139e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8013a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013a4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8013ab:	e9 5e ff ff ff       	jmp    80130e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8013b0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8013b6:	e9 53 ff ff ff       	jmp    80130e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8013bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8013be:	8d 50 04             	lea    0x4(%eax),%edx
  8013c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8013c4:	83 ec 08             	sub    $0x8,%esp
  8013c7:	53                   	push   %ebx
  8013c8:	ff 30                	pushl  (%eax)
  8013ca:	ff d6                	call   *%esi
			break;
  8013cc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013d2:	e9 04 ff ff ff       	jmp    8012db <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8013da:	8d 50 04             	lea    0x4(%eax),%edx
  8013dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8013e0:	8b 00                	mov    (%eax),%eax
  8013e2:	99                   	cltd   
  8013e3:	31 d0                	xor    %edx,%eax
  8013e5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013e7:	83 f8 0f             	cmp    $0xf,%eax
  8013ea:	7f 0b                	jg     8013f7 <vprintfmt+0x142>
  8013ec:	8b 14 85 60 22 80 00 	mov    0x802260(,%eax,4),%edx
  8013f3:	85 d2                	test   %edx,%edx
  8013f5:	75 18                	jne    80140f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013f7:	50                   	push   %eax
  8013f8:	68 cb 1f 80 00       	push   $0x801fcb
  8013fd:	53                   	push   %ebx
  8013fe:	56                   	push   %esi
  8013ff:	e8 94 fe ff ff       	call   801298 <printfmt>
  801404:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80140a:	e9 cc fe ff ff       	jmp    8012db <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80140f:	52                   	push   %edx
  801410:	68 42 1f 80 00       	push   $0x801f42
  801415:	53                   	push   %ebx
  801416:	56                   	push   %esi
  801417:	e8 7c fe ff ff       	call   801298 <printfmt>
  80141c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80141f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801422:	e9 b4 fe ff ff       	jmp    8012db <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801427:	8b 45 14             	mov    0x14(%ebp),%eax
  80142a:	8d 50 04             	lea    0x4(%eax),%edx
  80142d:	89 55 14             	mov    %edx,0x14(%ebp)
  801430:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801432:	85 ff                	test   %edi,%edi
  801434:	b8 c4 1f 80 00       	mov    $0x801fc4,%eax
  801439:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80143c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801440:	0f 8e 94 00 00 00    	jle    8014da <vprintfmt+0x225>
  801446:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80144a:	0f 84 98 00 00 00    	je     8014e8 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801450:	83 ec 08             	sub    $0x8,%esp
  801453:	ff 75 d0             	pushl  -0x30(%ebp)
  801456:	57                   	push   %edi
  801457:	e8 86 02 00 00       	call   8016e2 <strnlen>
  80145c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80145f:	29 c1                	sub    %eax,%ecx
  801461:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801464:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801467:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80146b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80146e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801471:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801473:	eb 0f                	jmp    801484 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801475:	83 ec 08             	sub    $0x8,%esp
  801478:	53                   	push   %ebx
  801479:	ff 75 e0             	pushl  -0x20(%ebp)
  80147c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80147e:	83 ef 01             	sub    $0x1,%edi
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	85 ff                	test   %edi,%edi
  801486:	7f ed                	jg     801475 <vprintfmt+0x1c0>
  801488:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80148b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80148e:	85 c9                	test   %ecx,%ecx
  801490:	b8 00 00 00 00       	mov    $0x0,%eax
  801495:	0f 49 c1             	cmovns %ecx,%eax
  801498:	29 c1                	sub    %eax,%ecx
  80149a:	89 75 08             	mov    %esi,0x8(%ebp)
  80149d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014a0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014a3:	89 cb                	mov    %ecx,%ebx
  8014a5:	eb 4d                	jmp    8014f4 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8014a7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014ab:	74 1b                	je     8014c8 <vprintfmt+0x213>
  8014ad:	0f be c0             	movsbl %al,%eax
  8014b0:	83 e8 20             	sub    $0x20,%eax
  8014b3:	83 f8 5e             	cmp    $0x5e,%eax
  8014b6:	76 10                	jbe    8014c8 <vprintfmt+0x213>
					putch('?', putdat);
  8014b8:	83 ec 08             	sub    $0x8,%esp
  8014bb:	ff 75 0c             	pushl  0xc(%ebp)
  8014be:	6a 3f                	push   $0x3f
  8014c0:	ff 55 08             	call   *0x8(%ebp)
  8014c3:	83 c4 10             	add    $0x10,%esp
  8014c6:	eb 0d                	jmp    8014d5 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8014c8:	83 ec 08             	sub    $0x8,%esp
  8014cb:	ff 75 0c             	pushl  0xc(%ebp)
  8014ce:	52                   	push   %edx
  8014cf:	ff 55 08             	call   *0x8(%ebp)
  8014d2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014d5:	83 eb 01             	sub    $0x1,%ebx
  8014d8:	eb 1a                	jmp    8014f4 <vprintfmt+0x23f>
  8014da:	89 75 08             	mov    %esi,0x8(%ebp)
  8014dd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014e0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014e3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014e6:	eb 0c                	jmp    8014f4 <vprintfmt+0x23f>
  8014e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8014eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014f4:	83 c7 01             	add    $0x1,%edi
  8014f7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014fb:	0f be d0             	movsbl %al,%edx
  8014fe:	85 d2                	test   %edx,%edx
  801500:	74 23                	je     801525 <vprintfmt+0x270>
  801502:	85 f6                	test   %esi,%esi
  801504:	78 a1                	js     8014a7 <vprintfmt+0x1f2>
  801506:	83 ee 01             	sub    $0x1,%esi
  801509:	79 9c                	jns    8014a7 <vprintfmt+0x1f2>
  80150b:	89 df                	mov    %ebx,%edi
  80150d:	8b 75 08             	mov    0x8(%ebp),%esi
  801510:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801513:	eb 18                	jmp    80152d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801515:	83 ec 08             	sub    $0x8,%esp
  801518:	53                   	push   %ebx
  801519:	6a 20                	push   $0x20
  80151b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80151d:	83 ef 01             	sub    $0x1,%edi
  801520:	83 c4 10             	add    $0x10,%esp
  801523:	eb 08                	jmp    80152d <vprintfmt+0x278>
  801525:	89 df                	mov    %ebx,%edi
  801527:	8b 75 08             	mov    0x8(%ebp),%esi
  80152a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80152d:	85 ff                	test   %edi,%edi
  80152f:	7f e4                	jg     801515 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801531:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801534:	e9 a2 fd ff ff       	jmp    8012db <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801539:	83 fa 01             	cmp    $0x1,%edx
  80153c:	7e 16                	jle    801554 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80153e:	8b 45 14             	mov    0x14(%ebp),%eax
  801541:	8d 50 08             	lea    0x8(%eax),%edx
  801544:	89 55 14             	mov    %edx,0x14(%ebp)
  801547:	8b 50 04             	mov    0x4(%eax),%edx
  80154a:	8b 00                	mov    (%eax),%eax
  80154c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80154f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801552:	eb 32                	jmp    801586 <vprintfmt+0x2d1>
	else if (lflag)
  801554:	85 d2                	test   %edx,%edx
  801556:	74 18                	je     801570 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801558:	8b 45 14             	mov    0x14(%ebp),%eax
  80155b:	8d 50 04             	lea    0x4(%eax),%edx
  80155e:	89 55 14             	mov    %edx,0x14(%ebp)
  801561:	8b 00                	mov    (%eax),%eax
  801563:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801566:	89 c1                	mov    %eax,%ecx
  801568:	c1 f9 1f             	sar    $0x1f,%ecx
  80156b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80156e:	eb 16                	jmp    801586 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801570:	8b 45 14             	mov    0x14(%ebp),%eax
  801573:	8d 50 04             	lea    0x4(%eax),%edx
  801576:	89 55 14             	mov    %edx,0x14(%ebp)
  801579:	8b 00                	mov    (%eax),%eax
  80157b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80157e:	89 c1                	mov    %eax,%ecx
  801580:	c1 f9 1f             	sar    $0x1f,%ecx
  801583:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801586:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801589:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80158c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801591:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801595:	79 74                	jns    80160b <vprintfmt+0x356>
				putch('-', putdat);
  801597:	83 ec 08             	sub    $0x8,%esp
  80159a:	53                   	push   %ebx
  80159b:	6a 2d                	push   $0x2d
  80159d:	ff d6                	call   *%esi
				num = -(long long) num;
  80159f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8015a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8015a5:	f7 d8                	neg    %eax
  8015a7:	83 d2 00             	adc    $0x0,%edx
  8015aa:	f7 da                	neg    %edx
  8015ac:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8015af:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8015b4:	eb 55                	jmp    80160b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8015b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8015b9:	e8 83 fc ff ff       	call   801241 <getuint>
			base = 10;
  8015be:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8015c3:	eb 46                	jmp    80160b <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8015c5:	8d 45 14             	lea    0x14(%ebp),%eax
  8015c8:	e8 74 fc ff ff       	call   801241 <getuint>
                        base = 8;
  8015cd:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  8015d2:	eb 37                	jmp    80160b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8015d4:	83 ec 08             	sub    $0x8,%esp
  8015d7:	53                   	push   %ebx
  8015d8:	6a 30                	push   $0x30
  8015da:	ff d6                	call   *%esi
			putch('x', putdat);
  8015dc:	83 c4 08             	add    $0x8,%esp
  8015df:	53                   	push   %ebx
  8015e0:	6a 78                	push   $0x78
  8015e2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e7:	8d 50 04             	lea    0x4(%eax),%edx
  8015ea:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015ed:	8b 00                	mov    (%eax),%eax
  8015ef:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015f4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015f7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015fc:	eb 0d                	jmp    80160b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015fe:	8d 45 14             	lea    0x14(%ebp),%eax
  801601:	e8 3b fc ff ff       	call   801241 <getuint>
			base = 16;
  801606:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80160b:	83 ec 0c             	sub    $0xc,%esp
  80160e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801612:	57                   	push   %edi
  801613:	ff 75 e0             	pushl  -0x20(%ebp)
  801616:	51                   	push   %ecx
  801617:	52                   	push   %edx
  801618:	50                   	push   %eax
  801619:	89 da                	mov    %ebx,%edx
  80161b:	89 f0                	mov    %esi,%eax
  80161d:	e8 70 fb ff ff       	call   801192 <printnum>
			break;
  801622:	83 c4 20             	add    $0x20,%esp
  801625:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801628:	e9 ae fc ff ff       	jmp    8012db <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80162d:	83 ec 08             	sub    $0x8,%esp
  801630:	53                   	push   %ebx
  801631:	51                   	push   %ecx
  801632:	ff d6                	call   *%esi
			break;
  801634:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801637:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80163a:	e9 9c fc ff ff       	jmp    8012db <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80163f:	83 ec 08             	sub    $0x8,%esp
  801642:	53                   	push   %ebx
  801643:	6a 25                	push   $0x25
  801645:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801647:	83 c4 10             	add    $0x10,%esp
  80164a:	eb 03                	jmp    80164f <vprintfmt+0x39a>
  80164c:	83 ef 01             	sub    $0x1,%edi
  80164f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801653:	75 f7                	jne    80164c <vprintfmt+0x397>
  801655:	e9 81 fc ff ff       	jmp    8012db <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80165a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80165d:	5b                   	pop    %ebx
  80165e:	5e                   	pop    %esi
  80165f:	5f                   	pop    %edi
  801660:	5d                   	pop    %ebp
  801661:	c3                   	ret    

00801662 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	83 ec 18             	sub    $0x18,%esp
  801668:	8b 45 08             	mov    0x8(%ebp),%eax
  80166b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80166e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801671:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801675:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801678:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80167f:	85 c0                	test   %eax,%eax
  801681:	74 26                	je     8016a9 <vsnprintf+0x47>
  801683:	85 d2                	test   %edx,%edx
  801685:	7e 22                	jle    8016a9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801687:	ff 75 14             	pushl  0x14(%ebp)
  80168a:	ff 75 10             	pushl  0x10(%ebp)
  80168d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801690:	50                   	push   %eax
  801691:	68 7b 12 80 00       	push   $0x80127b
  801696:	e8 1a fc ff ff       	call   8012b5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80169b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80169e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a4:	83 c4 10             	add    $0x10,%esp
  8016a7:	eb 05                	jmp    8016ae <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016ae:	c9                   	leave  
  8016af:	c3                   	ret    

008016b0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016b6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016b9:	50                   	push   %eax
  8016ba:	ff 75 10             	pushl  0x10(%ebp)
  8016bd:	ff 75 0c             	pushl  0xc(%ebp)
  8016c0:	ff 75 08             	pushl  0x8(%ebp)
  8016c3:	e8 9a ff ff ff       	call   801662 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016c8:	c9                   	leave  
  8016c9:	c3                   	ret    

008016ca <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8016d5:	eb 03                	jmp    8016da <strlen+0x10>
		n++;
  8016d7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016da:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016de:	75 f7                	jne    8016d7 <strlen+0xd>
		n++;
	return n;
}
  8016e0:	5d                   	pop    %ebp
  8016e1:	c3                   	ret    

008016e2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016e2:	55                   	push   %ebp
  8016e3:	89 e5                	mov    %esp,%ebp
  8016e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016e8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f0:	eb 03                	jmp    8016f5 <strnlen+0x13>
		n++;
  8016f2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016f5:	39 c2                	cmp    %eax,%edx
  8016f7:	74 08                	je     801701 <strnlen+0x1f>
  8016f9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016fd:	75 f3                	jne    8016f2 <strnlen+0x10>
  8016ff:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801701:	5d                   	pop    %ebp
  801702:	c3                   	ret    

00801703 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	53                   	push   %ebx
  801707:	8b 45 08             	mov    0x8(%ebp),%eax
  80170a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80170d:	89 c2                	mov    %eax,%edx
  80170f:	83 c2 01             	add    $0x1,%edx
  801712:	83 c1 01             	add    $0x1,%ecx
  801715:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801719:	88 5a ff             	mov    %bl,-0x1(%edx)
  80171c:	84 db                	test   %bl,%bl
  80171e:	75 ef                	jne    80170f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801720:	5b                   	pop    %ebx
  801721:	5d                   	pop    %ebp
  801722:	c3                   	ret    

00801723 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	53                   	push   %ebx
  801727:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80172a:	53                   	push   %ebx
  80172b:	e8 9a ff ff ff       	call   8016ca <strlen>
  801730:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801733:	ff 75 0c             	pushl  0xc(%ebp)
  801736:	01 d8                	add    %ebx,%eax
  801738:	50                   	push   %eax
  801739:	e8 c5 ff ff ff       	call   801703 <strcpy>
	return dst;
}
  80173e:	89 d8                	mov    %ebx,%eax
  801740:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801743:	c9                   	leave  
  801744:	c3                   	ret    

00801745 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	56                   	push   %esi
  801749:	53                   	push   %ebx
  80174a:	8b 75 08             	mov    0x8(%ebp),%esi
  80174d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801750:	89 f3                	mov    %esi,%ebx
  801752:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801755:	89 f2                	mov    %esi,%edx
  801757:	eb 0f                	jmp    801768 <strncpy+0x23>
		*dst++ = *src;
  801759:	83 c2 01             	add    $0x1,%edx
  80175c:	0f b6 01             	movzbl (%ecx),%eax
  80175f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801762:	80 39 01             	cmpb   $0x1,(%ecx)
  801765:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801768:	39 da                	cmp    %ebx,%edx
  80176a:	75 ed                	jne    801759 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80176c:	89 f0                	mov    %esi,%eax
  80176e:	5b                   	pop    %ebx
  80176f:	5e                   	pop    %esi
  801770:	5d                   	pop    %ebp
  801771:	c3                   	ret    

00801772 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801772:	55                   	push   %ebp
  801773:	89 e5                	mov    %esp,%ebp
  801775:	56                   	push   %esi
  801776:	53                   	push   %ebx
  801777:	8b 75 08             	mov    0x8(%ebp),%esi
  80177a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80177d:	8b 55 10             	mov    0x10(%ebp),%edx
  801780:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801782:	85 d2                	test   %edx,%edx
  801784:	74 21                	je     8017a7 <strlcpy+0x35>
  801786:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80178a:	89 f2                	mov    %esi,%edx
  80178c:	eb 09                	jmp    801797 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80178e:	83 c2 01             	add    $0x1,%edx
  801791:	83 c1 01             	add    $0x1,%ecx
  801794:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801797:	39 c2                	cmp    %eax,%edx
  801799:	74 09                	je     8017a4 <strlcpy+0x32>
  80179b:	0f b6 19             	movzbl (%ecx),%ebx
  80179e:	84 db                	test   %bl,%bl
  8017a0:	75 ec                	jne    80178e <strlcpy+0x1c>
  8017a2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017a4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017a7:	29 f0                	sub    %esi,%eax
}
  8017a9:	5b                   	pop    %ebx
  8017aa:	5e                   	pop    %esi
  8017ab:	5d                   	pop    %ebp
  8017ac:	c3                   	ret    

008017ad <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017ad:	55                   	push   %ebp
  8017ae:	89 e5                	mov    %esp,%ebp
  8017b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017b3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017b6:	eb 06                	jmp    8017be <strcmp+0x11>
		p++, q++;
  8017b8:	83 c1 01             	add    $0x1,%ecx
  8017bb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017be:	0f b6 01             	movzbl (%ecx),%eax
  8017c1:	84 c0                	test   %al,%al
  8017c3:	74 04                	je     8017c9 <strcmp+0x1c>
  8017c5:	3a 02                	cmp    (%edx),%al
  8017c7:	74 ef                	je     8017b8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017c9:	0f b6 c0             	movzbl %al,%eax
  8017cc:	0f b6 12             	movzbl (%edx),%edx
  8017cf:	29 d0                	sub    %edx,%eax
}
  8017d1:	5d                   	pop    %ebp
  8017d2:	c3                   	ret    

008017d3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	53                   	push   %ebx
  8017d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017dd:	89 c3                	mov    %eax,%ebx
  8017df:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017e2:	eb 06                	jmp    8017ea <strncmp+0x17>
		n--, p++, q++;
  8017e4:	83 c0 01             	add    $0x1,%eax
  8017e7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017ea:	39 d8                	cmp    %ebx,%eax
  8017ec:	74 15                	je     801803 <strncmp+0x30>
  8017ee:	0f b6 08             	movzbl (%eax),%ecx
  8017f1:	84 c9                	test   %cl,%cl
  8017f3:	74 04                	je     8017f9 <strncmp+0x26>
  8017f5:	3a 0a                	cmp    (%edx),%cl
  8017f7:	74 eb                	je     8017e4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017f9:	0f b6 00             	movzbl (%eax),%eax
  8017fc:	0f b6 12             	movzbl (%edx),%edx
  8017ff:	29 d0                	sub    %edx,%eax
  801801:	eb 05                	jmp    801808 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801803:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801808:	5b                   	pop    %ebx
  801809:	5d                   	pop    %ebp
  80180a:	c3                   	ret    

0080180b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80180b:	55                   	push   %ebp
  80180c:	89 e5                	mov    %esp,%ebp
  80180e:	8b 45 08             	mov    0x8(%ebp),%eax
  801811:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801815:	eb 07                	jmp    80181e <strchr+0x13>
		if (*s == c)
  801817:	38 ca                	cmp    %cl,%dl
  801819:	74 0f                	je     80182a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80181b:	83 c0 01             	add    $0x1,%eax
  80181e:	0f b6 10             	movzbl (%eax),%edx
  801821:	84 d2                	test   %dl,%dl
  801823:	75 f2                	jne    801817 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801825:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80182a:	5d                   	pop    %ebp
  80182b:	c3                   	ret    

0080182c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	8b 45 08             	mov    0x8(%ebp),%eax
  801832:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801836:	eb 03                	jmp    80183b <strfind+0xf>
  801838:	83 c0 01             	add    $0x1,%eax
  80183b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80183e:	38 ca                	cmp    %cl,%dl
  801840:	74 04                	je     801846 <strfind+0x1a>
  801842:	84 d2                	test   %dl,%dl
  801844:	75 f2                	jne    801838 <strfind+0xc>
			break;
	return (char *) s;
}
  801846:	5d                   	pop    %ebp
  801847:	c3                   	ret    

00801848 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	57                   	push   %edi
  80184c:	56                   	push   %esi
  80184d:	53                   	push   %ebx
  80184e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801851:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801854:	85 c9                	test   %ecx,%ecx
  801856:	74 36                	je     80188e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801858:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80185e:	75 28                	jne    801888 <memset+0x40>
  801860:	f6 c1 03             	test   $0x3,%cl
  801863:	75 23                	jne    801888 <memset+0x40>
		c &= 0xFF;
  801865:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801869:	89 d3                	mov    %edx,%ebx
  80186b:	c1 e3 08             	shl    $0x8,%ebx
  80186e:	89 d6                	mov    %edx,%esi
  801870:	c1 e6 18             	shl    $0x18,%esi
  801873:	89 d0                	mov    %edx,%eax
  801875:	c1 e0 10             	shl    $0x10,%eax
  801878:	09 f0                	or     %esi,%eax
  80187a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80187c:	89 d8                	mov    %ebx,%eax
  80187e:	09 d0                	or     %edx,%eax
  801880:	c1 e9 02             	shr    $0x2,%ecx
  801883:	fc                   	cld    
  801884:	f3 ab                	rep stos %eax,%es:(%edi)
  801886:	eb 06                	jmp    80188e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801888:	8b 45 0c             	mov    0xc(%ebp),%eax
  80188b:	fc                   	cld    
  80188c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80188e:	89 f8                	mov    %edi,%eax
  801890:	5b                   	pop    %ebx
  801891:	5e                   	pop    %esi
  801892:	5f                   	pop    %edi
  801893:	5d                   	pop    %ebp
  801894:	c3                   	ret    

00801895 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801895:	55                   	push   %ebp
  801896:	89 e5                	mov    %esp,%ebp
  801898:	57                   	push   %edi
  801899:	56                   	push   %esi
  80189a:	8b 45 08             	mov    0x8(%ebp),%eax
  80189d:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018a3:	39 c6                	cmp    %eax,%esi
  8018a5:	73 35                	jae    8018dc <memmove+0x47>
  8018a7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018aa:	39 d0                	cmp    %edx,%eax
  8018ac:	73 2e                	jae    8018dc <memmove+0x47>
		s += n;
		d += n;
  8018ae:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b1:	89 d6                	mov    %edx,%esi
  8018b3:	09 fe                	or     %edi,%esi
  8018b5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018bb:	75 13                	jne    8018d0 <memmove+0x3b>
  8018bd:	f6 c1 03             	test   $0x3,%cl
  8018c0:	75 0e                	jne    8018d0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018c2:	83 ef 04             	sub    $0x4,%edi
  8018c5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018c8:	c1 e9 02             	shr    $0x2,%ecx
  8018cb:	fd                   	std    
  8018cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ce:	eb 09                	jmp    8018d9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018d0:	83 ef 01             	sub    $0x1,%edi
  8018d3:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018d6:	fd                   	std    
  8018d7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018d9:	fc                   	cld    
  8018da:	eb 1d                	jmp    8018f9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018dc:	89 f2                	mov    %esi,%edx
  8018de:	09 c2                	or     %eax,%edx
  8018e0:	f6 c2 03             	test   $0x3,%dl
  8018e3:	75 0f                	jne    8018f4 <memmove+0x5f>
  8018e5:	f6 c1 03             	test   $0x3,%cl
  8018e8:	75 0a                	jne    8018f4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018ea:	c1 e9 02             	shr    $0x2,%ecx
  8018ed:	89 c7                	mov    %eax,%edi
  8018ef:	fc                   	cld    
  8018f0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018f2:	eb 05                	jmp    8018f9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018f4:	89 c7                	mov    %eax,%edi
  8018f6:	fc                   	cld    
  8018f7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018f9:	5e                   	pop    %esi
  8018fa:	5f                   	pop    %edi
  8018fb:	5d                   	pop    %ebp
  8018fc:	c3                   	ret    

008018fd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018fd:	55                   	push   %ebp
  8018fe:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801900:	ff 75 10             	pushl  0x10(%ebp)
  801903:	ff 75 0c             	pushl  0xc(%ebp)
  801906:	ff 75 08             	pushl  0x8(%ebp)
  801909:	e8 87 ff ff ff       	call   801895 <memmove>
}
  80190e:	c9                   	leave  
  80190f:	c3                   	ret    

00801910 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	56                   	push   %esi
  801914:	53                   	push   %ebx
  801915:	8b 45 08             	mov    0x8(%ebp),%eax
  801918:	8b 55 0c             	mov    0xc(%ebp),%edx
  80191b:	89 c6                	mov    %eax,%esi
  80191d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801920:	eb 1a                	jmp    80193c <memcmp+0x2c>
		if (*s1 != *s2)
  801922:	0f b6 08             	movzbl (%eax),%ecx
  801925:	0f b6 1a             	movzbl (%edx),%ebx
  801928:	38 d9                	cmp    %bl,%cl
  80192a:	74 0a                	je     801936 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80192c:	0f b6 c1             	movzbl %cl,%eax
  80192f:	0f b6 db             	movzbl %bl,%ebx
  801932:	29 d8                	sub    %ebx,%eax
  801934:	eb 0f                	jmp    801945 <memcmp+0x35>
		s1++, s2++;
  801936:	83 c0 01             	add    $0x1,%eax
  801939:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80193c:	39 f0                	cmp    %esi,%eax
  80193e:	75 e2                	jne    801922 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801940:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801945:	5b                   	pop    %ebx
  801946:	5e                   	pop    %esi
  801947:	5d                   	pop    %ebp
  801948:	c3                   	ret    

00801949 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801949:	55                   	push   %ebp
  80194a:	89 e5                	mov    %esp,%ebp
  80194c:	53                   	push   %ebx
  80194d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801950:	89 c1                	mov    %eax,%ecx
  801952:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801955:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801959:	eb 0a                	jmp    801965 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80195b:	0f b6 10             	movzbl (%eax),%edx
  80195e:	39 da                	cmp    %ebx,%edx
  801960:	74 07                	je     801969 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801962:	83 c0 01             	add    $0x1,%eax
  801965:	39 c8                	cmp    %ecx,%eax
  801967:	72 f2                	jb     80195b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801969:	5b                   	pop    %ebx
  80196a:	5d                   	pop    %ebp
  80196b:	c3                   	ret    

0080196c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	57                   	push   %edi
  801970:	56                   	push   %esi
  801971:	53                   	push   %ebx
  801972:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801975:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801978:	eb 03                	jmp    80197d <strtol+0x11>
		s++;
  80197a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80197d:	0f b6 01             	movzbl (%ecx),%eax
  801980:	3c 20                	cmp    $0x20,%al
  801982:	74 f6                	je     80197a <strtol+0xe>
  801984:	3c 09                	cmp    $0x9,%al
  801986:	74 f2                	je     80197a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801988:	3c 2b                	cmp    $0x2b,%al
  80198a:	75 0a                	jne    801996 <strtol+0x2a>
		s++;
  80198c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80198f:	bf 00 00 00 00       	mov    $0x0,%edi
  801994:	eb 11                	jmp    8019a7 <strtol+0x3b>
  801996:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80199b:	3c 2d                	cmp    $0x2d,%al
  80199d:	75 08                	jne    8019a7 <strtol+0x3b>
		s++, neg = 1;
  80199f:	83 c1 01             	add    $0x1,%ecx
  8019a2:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019a7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019ad:	75 15                	jne    8019c4 <strtol+0x58>
  8019af:	80 39 30             	cmpb   $0x30,(%ecx)
  8019b2:	75 10                	jne    8019c4 <strtol+0x58>
  8019b4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019b8:	75 7c                	jne    801a36 <strtol+0xca>
		s += 2, base = 16;
  8019ba:	83 c1 02             	add    $0x2,%ecx
  8019bd:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019c2:	eb 16                	jmp    8019da <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019c4:	85 db                	test   %ebx,%ebx
  8019c6:	75 12                	jne    8019da <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019c8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019cd:	80 39 30             	cmpb   $0x30,(%ecx)
  8019d0:	75 08                	jne    8019da <strtol+0x6e>
		s++, base = 8;
  8019d2:	83 c1 01             	add    $0x1,%ecx
  8019d5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019da:	b8 00 00 00 00       	mov    $0x0,%eax
  8019df:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019e2:	0f b6 11             	movzbl (%ecx),%edx
  8019e5:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019e8:	89 f3                	mov    %esi,%ebx
  8019ea:	80 fb 09             	cmp    $0x9,%bl
  8019ed:	77 08                	ja     8019f7 <strtol+0x8b>
			dig = *s - '0';
  8019ef:	0f be d2             	movsbl %dl,%edx
  8019f2:	83 ea 30             	sub    $0x30,%edx
  8019f5:	eb 22                	jmp    801a19 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019f7:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019fa:	89 f3                	mov    %esi,%ebx
  8019fc:	80 fb 19             	cmp    $0x19,%bl
  8019ff:	77 08                	ja     801a09 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a01:	0f be d2             	movsbl %dl,%edx
  801a04:	83 ea 57             	sub    $0x57,%edx
  801a07:	eb 10                	jmp    801a19 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a09:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a0c:	89 f3                	mov    %esi,%ebx
  801a0e:	80 fb 19             	cmp    $0x19,%bl
  801a11:	77 16                	ja     801a29 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a13:	0f be d2             	movsbl %dl,%edx
  801a16:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a19:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a1c:	7d 0b                	jge    801a29 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a1e:	83 c1 01             	add    $0x1,%ecx
  801a21:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a25:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a27:	eb b9                	jmp    8019e2 <strtol+0x76>

	if (endptr)
  801a29:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a2d:	74 0d                	je     801a3c <strtol+0xd0>
		*endptr = (char *) s;
  801a2f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a32:	89 0e                	mov    %ecx,(%esi)
  801a34:	eb 06                	jmp    801a3c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a36:	85 db                	test   %ebx,%ebx
  801a38:	74 98                	je     8019d2 <strtol+0x66>
  801a3a:	eb 9e                	jmp    8019da <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a3c:	89 c2                	mov    %eax,%edx
  801a3e:	f7 da                	neg    %edx
  801a40:	85 ff                	test   %edi,%edi
  801a42:	0f 45 c2             	cmovne %edx,%eax
}
  801a45:	5b                   	pop    %ebx
  801a46:	5e                   	pop    %esi
  801a47:	5f                   	pop    %edi
  801a48:	5d                   	pop    %ebp
  801a49:	c3                   	ret    

00801a4a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	53                   	push   %ebx
  801a4e:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801a51:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801a58:	75 28                	jne    801a82 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  801a5a:	e8 d3 e6 ff ff       	call   800132 <sys_getenvid>
  801a5f:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  801a61:	83 ec 04             	sub    $0x4,%esp
  801a64:	6a 06                	push   $0x6
  801a66:	68 00 f0 bf ee       	push   $0xeebff000
  801a6b:	50                   	push   %eax
  801a6c:	e8 ff e6 ff ff       	call   800170 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801a71:	83 c4 08             	add    $0x8,%esp
  801a74:	68 61 03 80 00       	push   $0x800361
  801a79:	53                   	push   %ebx
  801a7a:	e8 3c e8 ff ff       	call   8002bb <sys_env_set_pgfault_upcall>
  801a7f:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801a82:	8b 45 08             	mov    0x8(%ebp),%eax
  801a85:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801a8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a8d:	c9                   	leave  
  801a8e:	c3                   	ret    

00801a8f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	56                   	push   %esi
  801a93:	53                   	push   %ebx
  801a94:	8b 75 08             	mov    0x8(%ebp),%esi
  801a97:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801a9d:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801a9f:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801aa4:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801aa7:	83 ec 0c             	sub    $0xc,%esp
  801aaa:	50                   	push   %eax
  801aab:	e8 70 e8 ff ff       	call   800320 <sys_ipc_recv>

	if (r < 0) {
  801ab0:	83 c4 10             	add    $0x10,%esp
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	79 16                	jns    801acd <ipc_recv+0x3e>
		if (from_env_store)
  801ab7:	85 f6                	test   %esi,%esi
  801ab9:	74 06                	je     801ac1 <ipc_recv+0x32>
			*from_env_store = 0;
  801abb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801ac1:	85 db                	test   %ebx,%ebx
  801ac3:	74 2c                	je     801af1 <ipc_recv+0x62>
			*perm_store = 0;
  801ac5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801acb:	eb 24                	jmp    801af1 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801acd:	85 f6                	test   %esi,%esi
  801acf:	74 0a                	je     801adb <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801ad1:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad6:	8b 40 74             	mov    0x74(%eax),%eax
  801ad9:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801adb:	85 db                	test   %ebx,%ebx
  801add:	74 0a                	je     801ae9 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801adf:	a1 04 40 80 00       	mov    0x804004,%eax
  801ae4:	8b 40 78             	mov    0x78(%eax),%eax
  801ae7:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801ae9:	a1 04 40 80 00       	mov    0x804004,%eax
  801aee:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801af1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af4:	5b                   	pop    %ebx
  801af5:	5e                   	pop    %esi
  801af6:	5d                   	pop    %ebp
  801af7:	c3                   	ret    

00801af8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	57                   	push   %edi
  801afc:	56                   	push   %esi
  801afd:	53                   	push   %ebx
  801afe:	83 ec 0c             	sub    $0xc,%esp
  801b01:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b04:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801b0a:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801b0c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801b11:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801b14:	ff 75 14             	pushl  0x14(%ebp)
  801b17:	53                   	push   %ebx
  801b18:	56                   	push   %esi
  801b19:	57                   	push   %edi
  801b1a:	e8 de e7 ff ff       	call   8002fd <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801b1f:	83 c4 10             	add    $0x10,%esp
  801b22:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b25:	75 07                	jne    801b2e <ipc_send+0x36>
			sys_yield();
  801b27:	e8 25 e6 ff ff       	call   800151 <sys_yield>
  801b2c:	eb e6                	jmp    801b14 <ipc_send+0x1c>
		} else if (r < 0) {
  801b2e:	85 c0                	test   %eax,%eax
  801b30:	79 12                	jns    801b44 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801b32:	50                   	push   %eax
  801b33:	68 c0 22 80 00       	push   $0x8022c0
  801b38:	6a 51                	push   $0x51
  801b3a:	68 cd 22 80 00       	push   $0x8022cd
  801b3f:	e8 61 f5 ff ff       	call   8010a5 <_panic>
		}
	}
}
  801b44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b47:	5b                   	pop    %ebx
  801b48:	5e                   	pop    %esi
  801b49:	5f                   	pop    %edi
  801b4a:	5d                   	pop    %ebp
  801b4b:	c3                   	ret    

00801b4c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b52:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b57:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b5a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b60:	8b 52 50             	mov    0x50(%edx),%edx
  801b63:	39 ca                	cmp    %ecx,%edx
  801b65:	75 0d                	jne    801b74 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b67:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b6a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b6f:	8b 40 48             	mov    0x48(%eax),%eax
  801b72:	eb 0f                	jmp    801b83 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b74:	83 c0 01             	add    $0x1,%eax
  801b77:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b7c:	75 d9                	jne    801b57 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b83:	5d                   	pop    %ebp
  801b84:	c3                   	ret    

00801b85 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b85:	55                   	push   %ebp
  801b86:	89 e5                	mov    %esp,%ebp
  801b88:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b8b:	89 d0                	mov    %edx,%eax
  801b8d:	c1 e8 16             	shr    $0x16,%eax
  801b90:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b97:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b9c:	f6 c1 01             	test   $0x1,%cl
  801b9f:	74 1d                	je     801bbe <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ba1:	c1 ea 0c             	shr    $0xc,%edx
  801ba4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bab:	f6 c2 01             	test   $0x1,%dl
  801bae:	74 0e                	je     801bbe <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bb0:	c1 ea 0c             	shr    $0xc,%edx
  801bb3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bba:	ef 
  801bbb:	0f b7 c0             	movzwl %ax,%eax
}
  801bbe:	5d                   	pop    %ebp
  801bbf:	c3                   	ret    

00801bc0 <__udivdi3>:
  801bc0:	55                   	push   %ebp
  801bc1:	57                   	push   %edi
  801bc2:	56                   	push   %esi
  801bc3:	53                   	push   %ebx
  801bc4:	83 ec 1c             	sub    $0x1c,%esp
  801bc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bd7:	85 f6                	test   %esi,%esi
  801bd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bdd:	89 ca                	mov    %ecx,%edx
  801bdf:	89 f8                	mov    %edi,%eax
  801be1:	75 3d                	jne    801c20 <__udivdi3+0x60>
  801be3:	39 cf                	cmp    %ecx,%edi
  801be5:	0f 87 c5 00 00 00    	ja     801cb0 <__udivdi3+0xf0>
  801beb:	85 ff                	test   %edi,%edi
  801bed:	89 fd                	mov    %edi,%ebp
  801bef:	75 0b                	jne    801bfc <__udivdi3+0x3c>
  801bf1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf6:	31 d2                	xor    %edx,%edx
  801bf8:	f7 f7                	div    %edi
  801bfa:	89 c5                	mov    %eax,%ebp
  801bfc:	89 c8                	mov    %ecx,%eax
  801bfe:	31 d2                	xor    %edx,%edx
  801c00:	f7 f5                	div    %ebp
  801c02:	89 c1                	mov    %eax,%ecx
  801c04:	89 d8                	mov    %ebx,%eax
  801c06:	89 cf                	mov    %ecx,%edi
  801c08:	f7 f5                	div    %ebp
  801c0a:	89 c3                	mov    %eax,%ebx
  801c0c:	89 d8                	mov    %ebx,%eax
  801c0e:	89 fa                	mov    %edi,%edx
  801c10:	83 c4 1c             	add    $0x1c,%esp
  801c13:	5b                   	pop    %ebx
  801c14:	5e                   	pop    %esi
  801c15:	5f                   	pop    %edi
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    
  801c18:	90                   	nop
  801c19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c20:	39 ce                	cmp    %ecx,%esi
  801c22:	77 74                	ja     801c98 <__udivdi3+0xd8>
  801c24:	0f bd fe             	bsr    %esi,%edi
  801c27:	83 f7 1f             	xor    $0x1f,%edi
  801c2a:	0f 84 98 00 00 00    	je     801cc8 <__udivdi3+0x108>
  801c30:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	89 c5                	mov    %eax,%ebp
  801c39:	29 fb                	sub    %edi,%ebx
  801c3b:	d3 e6                	shl    %cl,%esi
  801c3d:	89 d9                	mov    %ebx,%ecx
  801c3f:	d3 ed                	shr    %cl,%ebp
  801c41:	89 f9                	mov    %edi,%ecx
  801c43:	d3 e0                	shl    %cl,%eax
  801c45:	09 ee                	or     %ebp,%esi
  801c47:	89 d9                	mov    %ebx,%ecx
  801c49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c4d:	89 d5                	mov    %edx,%ebp
  801c4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c53:	d3 ed                	shr    %cl,%ebp
  801c55:	89 f9                	mov    %edi,%ecx
  801c57:	d3 e2                	shl    %cl,%edx
  801c59:	89 d9                	mov    %ebx,%ecx
  801c5b:	d3 e8                	shr    %cl,%eax
  801c5d:	09 c2                	or     %eax,%edx
  801c5f:	89 d0                	mov    %edx,%eax
  801c61:	89 ea                	mov    %ebp,%edx
  801c63:	f7 f6                	div    %esi
  801c65:	89 d5                	mov    %edx,%ebp
  801c67:	89 c3                	mov    %eax,%ebx
  801c69:	f7 64 24 0c          	mull   0xc(%esp)
  801c6d:	39 d5                	cmp    %edx,%ebp
  801c6f:	72 10                	jb     801c81 <__udivdi3+0xc1>
  801c71:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c75:	89 f9                	mov    %edi,%ecx
  801c77:	d3 e6                	shl    %cl,%esi
  801c79:	39 c6                	cmp    %eax,%esi
  801c7b:	73 07                	jae    801c84 <__udivdi3+0xc4>
  801c7d:	39 d5                	cmp    %edx,%ebp
  801c7f:	75 03                	jne    801c84 <__udivdi3+0xc4>
  801c81:	83 eb 01             	sub    $0x1,%ebx
  801c84:	31 ff                	xor    %edi,%edi
  801c86:	89 d8                	mov    %ebx,%eax
  801c88:	89 fa                	mov    %edi,%edx
  801c8a:	83 c4 1c             	add    $0x1c,%esp
  801c8d:	5b                   	pop    %ebx
  801c8e:	5e                   	pop    %esi
  801c8f:	5f                   	pop    %edi
  801c90:	5d                   	pop    %ebp
  801c91:	c3                   	ret    
  801c92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c98:	31 ff                	xor    %edi,%edi
  801c9a:	31 db                	xor    %ebx,%ebx
  801c9c:	89 d8                	mov    %ebx,%eax
  801c9e:	89 fa                	mov    %edi,%edx
  801ca0:	83 c4 1c             	add    $0x1c,%esp
  801ca3:	5b                   	pop    %ebx
  801ca4:	5e                   	pop    %esi
  801ca5:	5f                   	pop    %edi
  801ca6:	5d                   	pop    %ebp
  801ca7:	c3                   	ret    
  801ca8:	90                   	nop
  801ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cb0:	89 d8                	mov    %ebx,%eax
  801cb2:	f7 f7                	div    %edi
  801cb4:	31 ff                	xor    %edi,%edi
  801cb6:	89 c3                	mov    %eax,%ebx
  801cb8:	89 d8                	mov    %ebx,%eax
  801cba:	89 fa                	mov    %edi,%edx
  801cbc:	83 c4 1c             	add    $0x1c,%esp
  801cbf:	5b                   	pop    %ebx
  801cc0:	5e                   	pop    %esi
  801cc1:	5f                   	pop    %edi
  801cc2:	5d                   	pop    %ebp
  801cc3:	c3                   	ret    
  801cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc8:	39 ce                	cmp    %ecx,%esi
  801cca:	72 0c                	jb     801cd8 <__udivdi3+0x118>
  801ccc:	31 db                	xor    %ebx,%ebx
  801cce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cd2:	0f 87 34 ff ff ff    	ja     801c0c <__udivdi3+0x4c>
  801cd8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cdd:	e9 2a ff ff ff       	jmp    801c0c <__udivdi3+0x4c>
  801ce2:	66 90                	xchg   %ax,%ax
  801ce4:	66 90                	xchg   %ax,%ax
  801ce6:	66 90                	xchg   %ax,%ax
  801ce8:	66 90                	xchg   %ax,%ax
  801cea:	66 90                	xchg   %ax,%ax
  801cec:	66 90                	xchg   %ax,%ax
  801cee:	66 90                	xchg   %ax,%ax

00801cf0 <__umoddi3>:
  801cf0:	55                   	push   %ebp
  801cf1:	57                   	push   %edi
  801cf2:	56                   	push   %esi
  801cf3:	53                   	push   %ebx
  801cf4:	83 ec 1c             	sub    $0x1c,%esp
  801cf7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cfb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d07:	85 d2                	test   %edx,%edx
  801d09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d11:	89 f3                	mov    %esi,%ebx
  801d13:	89 3c 24             	mov    %edi,(%esp)
  801d16:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d1a:	75 1c                	jne    801d38 <__umoddi3+0x48>
  801d1c:	39 f7                	cmp    %esi,%edi
  801d1e:	76 50                	jbe    801d70 <__umoddi3+0x80>
  801d20:	89 c8                	mov    %ecx,%eax
  801d22:	89 f2                	mov    %esi,%edx
  801d24:	f7 f7                	div    %edi
  801d26:	89 d0                	mov    %edx,%eax
  801d28:	31 d2                	xor    %edx,%edx
  801d2a:	83 c4 1c             	add    $0x1c,%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	5f                   	pop    %edi
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    
  801d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d38:	39 f2                	cmp    %esi,%edx
  801d3a:	89 d0                	mov    %edx,%eax
  801d3c:	77 52                	ja     801d90 <__umoddi3+0xa0>
  801d3e:	0f bd ea             	bsr    %edx,%ebp
  801d41:	83 f5 1f             	xor    $0x1f,%ebp
  801d44:	75 5a                	jne    801da0 <__umoddi3+0xb0>
  801d46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d4a:	0f 82 e0 00 00 00    	jb     801e30 <__umoddi3+0x140>
  801d50:	39 0c 24             	cmp    %ecx,(%esp)
  801d53:	0f 86 d7 00 00 00    	jbe    801e30 <__umoddi3+0x140>
  801d59:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d61:	83 c4 1c             	add    $0x1c,%esp
  801d64:	5b                   	pop    %ebx
  801d65:	5e                   	pop    %esi
  801d66:	5f                   	pop    %edi
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    
  801d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d70:	85 ff                	test   %edi,%edi
  801d72:	89 fd                	mov    %edi,%ebp
  801d74:	75 0b                	jne    801d81 <__umoddi3+0x91>
  801d76:	b8 01 00 00 00       	mov    $0x1,%eax
  801d7b:	31 d2                	xor    %edx,%edx
  801d7d:	f7 f7                	div    %edi
  801d7f:	89 c5                	mov    %eax,%ebp
  801d81:	89 f0                	mov    %esi,%eax
  801d83:	31 d2                	xor    %edx,%edx
  801d85:	f7 f5                	div    %ebp
  801d87:	89 c8                	mov    %ecx,%eax
  801d89:	f7 f5                	div    %ebp
  801d8b:	89 d0                	mov    %edx,%eax
  801d8d:	eb 99                	jmp    801d28 <__umoddi3+0x38>
  801d8f:	90                   	nop
  801d90:	89 c8                	mov    %ecx,%eax
  801d92:	89 f2                	mov    %esi,%edx
  801d94:	83 c4 1c             	add    $0x1c,%esp
  801d97:	5b                   	pop    %ebx
  801d98:	5e                   	pop    %esi
  801d99:	5f                   	pop    %edi
  801d9a:	5d                   	pop    %ebp
  801d9b:	c3                   	ret    
  801d9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801da0:	8b 34 24             	mov    (%esp),%esi
  801da3:	bf 20 00 00 00       	mov    $0x20,%edi
  801da8:	89 e9                	mov    %ebp,%ecx
  801daa:	29 ef                	sub    %ebp,%edi
  801dac:	d3 e0                	shl    %cl,%eax
  801dae:	89 f9                	mov    %edi,%ecx
  801db0:	89 f2                	mov    %esi,%edx
  801db2:	d3 ea                	shr    %cl,%edx
  801db4:	89 e9                	mov    %ebp,%ecx
  801db6:	09 c2                	or     %eax,%edx
  801db8:	89 d8                	mov    %ebx,%eax
  801dba:	89 14 24             	mov    %edx,(%esp)
  801dbd:	89 f2                	mov    %esi,%edx
  801dbf:	d3 e2                	shl    %cl,%edx
  801dc1:	89 f9                	mov    %edi,%ecx
  801dc3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dc7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dcb:	d3 e8                	shr    %cl,%eax
  801dcd:	89 e9                	mov    %ebp,%ecx
  801dcf:	89 c6                	mov    %eax,%esi
  801dd1:	d3 e3                	shl    %cl,%ebx
  801dd3:	89 f9                	mov    %edi,%ecx
  801dd5:	89 d0                	mov    %edx,%eax
  801dd7:	d3 e8                	shr    %cl,%eax
  801dd9:	89 e9                	mov    %ebp,%ecx
  801ddb:	09 d8                	or     %ebx,%eax
  801ddd:	89 d3                	mov    %edx,%ebx
  801ddf:	89 f2                	mov    %esi,%edx
  801de1:	f7 34 24             	divl   (%esp)
  801de4:	89 d6                	mov    %edx,%esi
  801de6:	d3 e3                	shl    %cl,%ebx
  801de8:	f7 64 24 04          	mull   0x4(%esp)
  801dec:	39 d6                	cmp    %edx,%esi
  801dee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801df2:	89 d1                	mov    %edx,%ecx
  801df4:	89 c3                	mov    %eax,%ebx
  801df6:	72 08                	jb     801e00 <__umoddi3+0x110>
  801df8:	75 11                	jne    801e0b <__umoddi3+0x11b>
  801dfa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dfe:	73 0b                	jae    801e0b <__umoddi3+0x11b>
  801e00:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e04:	1b 14 24             	sbb    (%esp),%edx
  801e07:	89 d1                	mov    %edx,%ecx
  801e09:	89 c3                	mov    %eax,%ebx
  801e0b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e0f:	29 da                	sub    %ebx,%edx
  801e11:	19 ce                	sbb    %ecx,%esi
  801e13:	89 f9                	mov    %edi,%ecx
  801e15:	89 f0                	mov    %esi,%eax
  801e17:	d3 e0                	shl    %cl,%eax
  801e19:	89 e9                	mov    %ebp,%ecx
  801e1b:	d3 ea                	shr    %cl,%edx
  801e1d:	89 e9                	mov    %ebp,%ecx
  801e1f:	d3 ee                	shr    %cl,%esi
  801e21:	09 d0                	or     %edx,%eax
  801e23:	89 f2                	mov    %esi,%edx
  801e25:	83 c4 1c             	add    $0x1c,%esp
  801e28:	5b                   	pop    %ebx
  801e29:	5e                   	pop    %esi
  801e2a:	5f                   	pop    %edi
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    
  801e2d:	8d 76 00             	lea    0x0(%esi),%esi
  801e30:	29 f9                	sub    %edi,%ecx
  801e32:	19 d6                	sbb    %edx,%esi
  801e34:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e38:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e3c:	e9 18 ff ff ff       	jmp    801d59 <__umoddi3+0x69>
