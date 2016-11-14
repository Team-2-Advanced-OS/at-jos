
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800044:	e8 c6 00 00 00       	call   80010f <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800070:	e8 0a 00 00 00       	call   80007f <exit>
}
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007b:	5b                   	pop    %ebx
  80007c:	5e                   	pop    %esi
  80007d:	5d                   	pop    %ebp
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800085:	6a 00                	push   $0x0
  800087:	e8 42 00 00 00       	call   8000ce <sys_env_destroy>
}
  80008c:	83 c4 10             	add    $0x10,%esp
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	57                   	push   %edi
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800097:	b8 00 00 00 00       	mov    $0x0,%eax
  80009c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009f:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a2:	89 c3                	mov    %eax,%ebx
  8000a4:	89 c7                	mov    %eax,%edi
  8000a6:	89 c6                	mov    %eax,%esi
  8000a8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000aa:	5b                   	pop    %ebx
  8000ab:	5e                   	pop    %esi
  8000ac:	5f                   	pop    %edi
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    

008000af <sys_cgetc>:

int
sys_cgetc(void)
{
  8000af:	55                   	push   %ebp
  8000b0:	89 e5                	mov    %esp,%ebp
  8000b2:	57                   	push   %edi
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8000bf:	89 d1                	mov    %edx,%ecx
  8000c1:	89 d3                	mov    %edx,%ebx
  8000c3:	89 d7                	mov    %edx,%edi
  8000c5:	89 d6                	mov    %edx,%esi
  8000c7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5f                   	pop    %edi
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    

008000ce <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	57                   	push   %edi
  8000d2:	56                   	push   %esi
  8000d3:	53                   	push   %ebx
  8000d4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000dc:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e4:	89 cb                	mov    %ecx,%ebx
  8000e6:	89 cf                	mov    %ecx,%edi
  8000e8:	89 ce                	mov    %ecx,%esi
  8000ea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000ec:	85 c0                	test   %eax,%eax
  8000ee:	7e 17                	jle    800107 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f0:	83 ec 0c             	sub    $0xc,%esp
  8000f3:	50                   	push   %eax
  8000f4:	6a 03                	push   $0x3
  8000f6:	68 8a 0f 80 00       	push   $0x800f8a
  8000fb:	6a 23                	push   $0x23
  8000fd:	68 a7 0f 80 00       	push   $0x800fa7
  800102:	e8 f5 01 00 00       	call   8002fc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800107:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010a:	5b                   	pop    %ebx
  80010b:	5e                   	pop    %esi
  80010c:	5f                   	pop    %edi
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    

0080010f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	57                   	push   %edi
  800113:	56                   	push   %esi
  800114:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800115:	ba 00 00 00 00       	mov    $0x0,%edx
  80011a:	b8 02 00 00 00       	mov    $0x2,%eax
  80011f:	89 d1                	mov    %edx,%ecx
  800121:	89 d3                	mov    %edx,%ebx
  800123:	89 d7                	mov    %edx,%edi
  800125:	89 d6                	mov    %edx,%esi
  800127:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800129:	5b                   	pop    %ebx
  80012a:	5e                   	pop    %esi
  80012b:	5f                   	pop    %edi
  80012c:	5d                   	pop    %ebp
  80012d:	c3                   	ret    

0080012e <sys_yield>:

void
sys_yield(void)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	57                   	push   %edi
  800132:	56                   	push   %esi
  800133:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800134:	ba 00 00 00 00       	mov    $0x0,%edx
  800139:	b8 0a 00 00 00       	mov    $0xa,%eax
  80013e:	89 d1                	mov    %edx,%ecx
  800140:	89 d3                	mov    %edx,%ebx
  800142:	89 d7                	mov    %edx,%edi
  800144:	89 d6                	mov    %edx,%esi
  800146:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800148:	5b                   	pop    %ebx
  800149:	5e                   	pop    %esi
  80014a:	5f                   	pop    %edi
  80014b:	5d                   	pop    %ebp
  80014c:	c3                   	ret    

0080014d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
  800153:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800156:	be 00 00 00 00       	mov    $0x0,%esi
  80015b:	b8 04 00 00 00       	mov    $0x4,%eax
  800160:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800163:	8b 55 08             	mov    0x8(%ebp),%edx
  800166:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800169:	89 f7                	mov    %esi,%edi
  80016b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80016d:	85 c0                	test   %eax,%eax
  80016f:	7e 17                	jle    800188 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800171:	83 ec 0c             	sub    $0xc,%esp
  800174:	50                   	push   %eax
  800175:	6a 04                	push   $0x4
  800177:	68 8a 0f 80 00       	push   $0x800f8a
  80017c:	6a 23                	push   $0x23
  80017e:	68 a7 0f 80 00       	push   $0x800fa7
  800183:	e8 74 01 00 00       	call   8002fc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800188:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018b:	5b                   	pop    %ebx
  80018c:	5e                   	pop    %esi
  80018d:	5f                   	pop    %edi
  80018e:	5d                   	pop    %ebp
  80018f:	c3                   	ret    

00800190 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800199:	b8 05 00 00 00       	mov    $0x5,%eax
  80019e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001aa:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001af:	85 c0                	test   %eax,%eax
  8001b1:	7e 17                	jle    8001ca <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b3:	83 ec 0c             	sub    $0xc,%esp
  8001b6:	50                   	push   %eax
  8001b7:	6a 05                	push   $0x5
  8001b9:	68 8a 0f 80 00       	push   $0x800f8a
  8001be:	6a 23                	push   $0x23
  8001c0:	68 a7 0f 80 00       	push   $0x800fa7
  8001c5:	e8 32 01 00 00       	call   8002fc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cd:	5b                   	pop    %ebx
  8001ce:	5e                   	pop    %esi
  8001cf:	5f                   	pop    %edi
  8001d0:	5d                   	pop    %ebp
  8001d1:	c3                   	ret    

008001d2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	57                   	push   %edi
  8001d6:	56                   	push   %esi
  8001d7:	53                   	push   %ebx
  8001d8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e0:	b8 06 00 00 00       	mov    $0x6,%eax
  8001e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001eb:	89 df                	mov    %ebx,%edi
  8001ed:	89 de                	mov    %ebx,%esi
  8001ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f1:	85 c0                	test   %eax,%eax
  8001f3:	7e 17                	jle    80020c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	50                   	push   %eax
  8001f9:	6a 06                	push   $0x6
  8001fb:	68 8a 0f 80 00       	push   $0x800f8a
  800200:	6a 23                	push   $0x23
  800202:	68 a7 0f 80 00       	push   $0x800fa7
  800207:	e8 f0 00 00 00       	call   8002fc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5f                   	pop    %edi
  800212:	5d                   	pop    %ebp
  800213:	c3                   	ret    

00800214 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80021d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800222:	b8 08 00 00 00       	mov    $0x8,%eax
  800227:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022a:	8b 55 08             	mov    0x8(%ebp),%edx
  80022d:	89 df                	mov    %ebx,%edi
  80022f:	89 de                	mov    %ebx,%esi
  800231:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800233:	85 c0                	test   %eax,%eax
  800235:	7e 17                	jle    80024e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800237:	83 ec 0c             	sub    $0xc,%esp
  80023a:	50                   	push   %eax
  80023b:	6a 08                	push   $0x8
  80023d:	68 8a 0f 80 00       	push   $0x800f8a
  800242:	6a 23                	push   $0x23
  800244:	68 a7 0f 80 00       	push   $0x800fa7
  800249:	e8 ae 00 00 00       	call   8002fc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80024e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800251:	5b                   	pop    %ebx
  800252:	5e                   	pop    %esi
  800253:	5f                   	pop    %edi
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    

00800256 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	57                   	push   %edi
  80025a:	56                   	push   %esi
  80025b:	53                   	push   %ebx
  80025c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80025f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800264:	b8 09 00 00 00       	mov    $0x9,%eax
  800269:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026c:	8b 55 08             	mov    0x8(%ebp),%edx
  80026f:	89 df                	mov    %ebx,%edi
  800271:	89 de                	mov    %ebx,%esi
  800273:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800275:	85 c0                	test   %eax,%eax
  800277:	7e 17                	jle    800290 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800279:	83 ec 0c             	sub    $0xc,%esp
  80027c:	50                   	push   %eax
  80027d:	6a 09                	push   $0x9
  80027f:	68 8a 0f 80 00       	push   $0x800f8a
  800284:	6a 23                	push   $0x23
  800286:	68 a7 0f 80 00       	push   $0x800fa7
  80028b:	e8 6c 00 00 00       	call   8002fc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800290:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800293:	5b                   	pop    %ebx
  800294:	5e                   	pop    %esi
  800295:	5f                   	pop    %edi
  800296:	5d                   	pop    %ebp
  800297:	c3                   	ret    

00800298 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80029e:	be 00 00 00 00       	mov    $0x0,%esi
  8002a3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  8002c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d1:	89 cb                	mov    %ecx,%ebx
  8002d3:	89 cf                	mov    %ecx,%edi
  8002d5:	89 ce                	mov    %ecx,%esi
  8002d7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d9:	85 c0                	test   %eax,%eax
  8002db:	7e 17                	jle    8002f4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002dd:	83 ec 0c             	sub    $0xc,%esp
  8002e0:	50                   	push   %eax
  8002e1:	6a 0c                	push   $0xc
  8002e3:	68 8a 0f 80 00       	push   $0x800f8a
  8002e8:	6a 23                	push   $0x23
  8002ea:	68 a7 0f 80 00       	push   $0x800fa7
  8002ef:	e8 08 00 00 00       	call   8002fc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f7:	5b                   	pop    %ebx
  8002f8:	5e                   	pop    %esi
  8002f9:	5f                   	pop    %edi
  8002fa:	5d                   	pop    %ebp
  8002fb:	c3                   	ret    

008002fc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	56                   	push   %esi
  800300:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800301:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800304:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80030a:	e8 00 fe ff ff       	call   80010f <sys_getenvid>
  80030f:	83 ec 0c             	sub    $0xc,%esp
  800312:	ff 75 0c             	pushl  0xc(%ebp)
  800315:	ff 75 08             	pushl  0x8(%ebp)
  800318:	56                   	push   %esi
  800319:	50                   	push   %eax
  80031a:	68 b8 0f 80 00       	push   $0x800fb8
  80031f:	e8 b1 00 00 00       	call   8003d5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800324:	83 c4 18             	add    $0x18,%esp
  800327:	53                   	push   %ebx
  800328:	ff 75 10             	pushl  0x10(%ebp)
  80032b:	e8 54 00 00 00       	call   800384 <vcprintf>
	cprintf("\n");
  800330:	c7 04 24 dc 0f 80 00 	movl   $0x800fdc,(%esp)
  800337:	e8 99 00 00 00       	call   8003d5 <cprintf>
  80033c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80033f:	cc                   	int3   
  800340:	eb fd                	jmp    80033f <_panic+0x43>

00800342 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	53                   	push   %ebx
  800346:	83 ec 04             	sub    $0x4,%esp
  800349:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80034c:	8b 13                	mov    (%ebx),%edx
  80034e:	8d 42 01             	lea    0x1(%edx),%eax
  800351:	89 03                	mov    %eax,(%ebx)
  800353:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800356:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80035a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80035f:	75 1a                	jne    80037b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800361:	83 ec 08             	sub    $0x8,%esp
  800364:	68 ff 00 00 00       	push   $0xff
  800369:	8d 43 08             	lea    0x8(%ebx),%eax
  80036c:	50                   	push   %eax
  80036d:	e8 1f fd ff ff       	call   800091 <sys_cputs>
		b->idx = 0;
  800372:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800378:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80037b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80037f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80038d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800394:	00 00 00 
	b.cnt = 0;
  800397:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80039e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003a1:	ff 75 0c             	pushl  0xc(%ebp)
  8003a4:	ff 75 08             	pushl  0x8(%ebp)
  8003a7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ad:	50                   	push   %eax
  8003ae:	68 42 03 80 00       	push   $0x800342
  8003b3:	e8 54 01 00 00       	call   80050c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003b8:	83 c4 08             	add    $0x8,%esp
  8003bb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003c1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003c7:	50                   	push   %eax
  8003c8:	e8 c4 fc ff ff       	call   800091 <sys_cputs>

	return b.cnt;
}
  8003cd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003d3:	c9                   	leave  
  8003d4:	c3                   	ret    

008003d5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003d5:	55                   	push   %ebp
  8003d6:	89 e5                	mov    %esp,%ebp
  8003d8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003db:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003de:	50                   	push   %eax
  8003df:	ff 75 08             	pushl  0x8(%ebp)
  8003e2:	e8 9d ff ff ff       	call   800384 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003e7:	c9                   	leave  
  8003e8:	c3                   	ret    

008003e9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	57                   	push   %edi
  8003ed:	56                   	push   %esi
  8003ee:	53                   	push   %ebx
  8003ef:	83 ec 1c             	sub    $0x1c,%esp
  8003f2:	89 c7                	mov    %eax,%edi
  8003f4:	89 d6                	mov    %edx,%esi
  8003f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ff:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800402:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800405:	bb 00 00 00 00       	mov    $0x0,%ebx
  80040a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80040d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800410:	39 d3                	cmp    %edx,%ebx
  800412:	72 05                	jb     800419 <printnum+0x30>
  800414:	39 45 10             	cmp    %eax,0x10(%ebp)
  800417:	77 45                	ja     80045e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800419:	83 ec 0c             	sub    $0xc,%esp
  80041c:	ff 75 18             	pushl  0x18(%ebp)
  80041f:	8b 45 14             	mov    0x14(%ebp),%eax
  800422:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800425:	53                   	push   %ebx
  800426:	ff 75 10             	pushl  0x10(%ebp)
  800429:	83 ec 08             	sub    $0x8,%esp
  80042c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80042f:	ff 75 e0             	pushl  -0x20(%ebp)
  800432:	ff 75 dc             	pushl  -0x24(%ebp)
  800435:	ff 75 d8             	pushl  -0x28(%ebp)
  800438:	e8 b3 08 00 00       	call   800cf0 <__udivdi3>
  80043d:	83 c4 18             	add    $0x18,%esp
  800440:	52                   	push   %edx
  800441:	50                   	push   %eax
  800442:	89 f2                	mov    %esi,%edx
  800444:	89 f8                	mov    %edi,%eax
  800446:	e8 9e ff ff ff       	call   8003e9 <printnum>
  80044b:	83 c4 20             	add    $0x20,%esp
  80044e:	eb 18                	jmp    800468 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800450:	83 ec 08             	sub    $0x8,%esp
  800453:	56                   	push   %esi
  800454:	ff 75 18             	pushl  0x18(%ebp)
  800457:	ff d7                	call   *%edi
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	eb 03                	jmp    800461 <printnum+0x78>
  80045e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800461:	83 eb 01             	sub    $0x1,%ebx
  800464:	85 db                	test   %ebx,%ebx
  800466:	7f e8                	jg     800450 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800468:	83 ec 08             	sub    $0x8,%esp
  80046b:	56                   	push   %esi
  80046c:	83 ec 04             	sub    $0x4,%esp
  80046f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800472:	ff 75 e0             	pushl  -0x20(%ebp)
  800475:	ff 75 dc             	pushl  -0x24(%ebp)
  800478:	ff 75 d8             	pushl  -0x28(%ebp)
  80047b:	e8 a0 09 00 00       	call   800e20 <__umoddi3>
  800480:	83 c4 14             	add    $0x14,%esp
  800483:	0f be 80 de 0f 80 00 	movsbl 0x800fde(%eax),%eax
  80048a:	50                   	push   %eax
  80048b:	ff d7                	call   *%edi
}
  80048d:	83 c4 10             	add    $0x10,%esp
  800490:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800493:	5b                   	pop    %ebx
  800494:	5e                   	pop    %esi
  800495:	5f                   	pop    %edi
  800496:	5d                   	pop    %ebp
  800497:	c3                   	ret    

00800498 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800498:	55                   	push   %ebp
  800499:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80049b:	83 fa 01             	cmp    $0x1,%edx
  80049e:	7e 0e                	jle    8004ae <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004a0:	8b 10                	mov    (%eax),%edx
  8004a2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004a5:	89 08                	mov    %ecx,(%eax)
  8004a7:	8b 02                	mov    (%edx),%eax
  8004a9:	8b 52 04             	mov    0x4(%edx),%edx
  8004ac:	eb 22                	jmp    8004d0 <getuint+0x38>
	else if (lflag)
  8004ae:	85 d2                	test   %edx,%edx
  8004b0:	74 10                	je     8004c2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004b2:	8b 10                	mov    (%eax),%edx
  8004b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b7:	89 08                	mov    %ecx,(%eax)
  8004b9:	8b 02                	mov    (%edx),%eax
  8004bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c0:	eb 0e                	jmp    8004d0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004c2:	8b 10                	mov    (%eax),%edx
  8004c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c7:	89 08                	mov    %ecx,(%eax)
  8004c9:	8b 02                	mov    (%edx),%eax
  8004cb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004d0:	5d                   	pop    %ebp
  8004d1:	c3                   	ret    

008004d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004dc:	8b 10                	mov    (%eax),%edx
  8004de:	3b 50 04             	cmp    0x4(%eax),%edx
  8004e1:	73 0a                	jae    8004ed <sprintputch+0x1b>
		*b->buf++ = ch;
  8004e3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e6:	89 08                	mov    %ecx,(%eax)
  8004e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004eb:	88 02                	mov    %al,(%edx)
}
  8004ed:	5d                   	pop    %ebp
  8004ee:	c3                   	ret    

008004ef <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004ef:	55                   	push   %ebp
  8004f0:	89 e5                	mov    %esp,%ebp
  8004f2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004f5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f8:	50                   	push   %eax
  8004f9:	ff 75 10             	pushl  0x10(%ebp)
  8004fc:	ff 75 0c             	pushl  0xc(%ebp)
  8004ff:	ff 75 08             	pushl  0x8(%ebp)
  800502:	e8 05 00 00 00       	call   80050c <vprintfmt>
	va_end(ap);
}
  800507:	83 c4 10             	add    $0x10,%esp
  80050a:	c9                   	leave  
  80050b:	c3                   	ret    

0080050c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80050c:	55                   	push   %ebp
  80050d:	89 e5                	mov    %esp,%ebp
  80050f:	57                   	push   %edi
  800510:	56                   	push   %esi
  800511:	53                   	push   %ebx
  800512:	83 ec 2c             	sub    $0x2c,%esp
  800515:	8b 75 08             	mov    0x8(%ebp),%esi
  800518:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80051e:	eb 1d                	jmp    80053d <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  800520:	85 c0                	test   %eax,%eax
  800522:	75 0f                	jne    800533 <vprintfmt+0x27>
				csa = 0x0700;
  800524:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80052b:	07 00 00 
				return;
  80052e:	e9 c4 03 00 00       	jmp    8008f7 <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  800533:	83 ec 08             	sub    $0x8,%esp
  800536:	53                   	push   %ebx
  800537:	50                   	push   %eax
  800538:	ff d6                	call   *%esi
  80053a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80053d:	83 c7 01             	add    $0x1,%edi
  800540:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800544:	83 f8 25             	cmp    $0x25,%eax
  800547:	75 d7                	jne    800520 <vprintfmt+0x14>
  800549:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80054d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800554:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80055b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800562:	ba 00 00 00 00       	mov    $0x0,%edx
  800567:	eb 07                	jmp    800570 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800569:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80056c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800570:	8d 47 01             	lea    0x1(%edi),%eax
  800573:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800576:	0f b6 07             	movzbl (%edi),%eax
  800579:	0f b6 c8             	movzbl %al,%ecx
  80057c:	83 e8 23             	sub    $0x23,%eax
  80057f:	3c 55                	cmp    $0x55,%al
  800581:	0f 87 55 03 00 00    	ja     8008dc <vprintfmt+0x3d0>
  800587:	0f b6 c0             	movzbl %al,%eax
  80058a:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  800591:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800594:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800598:	eb d6                	jmp    800570 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059d:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005a5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005a8:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005ac:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005af:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005b2:	83 fa 09             	cmp    $0x9,%edx
  8005b5:	77 39                	ja     8005f0 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005b7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005ba:	eb e9                	jmp    8005a5 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8d 48 04             	lea    0x4(%eax),%ecx
  8005c2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005c5:	8b 00                	mov    (%eax),%eax
  8005c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005cd:	eb 27                	jmp    8005f6 <vprintfmt+0xea>
  8005cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d2:	85 c0                	test   %eax,%eax
  8005d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d9:	0f 49 c8             	cmovns %eax,%ecx
  8005dc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e2:	eb 8c                	jmp    800570 <vprintfmt+0x64>
  8005e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005e7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005ee:	eb 80                	jmp    800570 <vprintfmt+0x64>
  8005f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005f6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005fa:	0f 89 70 ff ff ff    	jns    800570 <vprintfmt+0x64>
				width = precision, precision = -1;
  800600:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800603:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800606:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80060d:	e9 5e ff ff ff       	jmp    800570 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800612:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800615:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800618:	e9 53 ff ff ff       	jmp    800570 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8d 50 04             	lea    0x4(%eax),%edx
  800623:	89 55 14             	mov    %edx,0x14(%ebp)
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	53                   	push   %ebx
  80062a:	ff 30                	pushl  (%eax)
  80062c:	ff d6                	call   *%esi
			break;
  80062e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800631:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800634:	e9 04 ff ff ff       	jmp    80053d <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8d 50 04             	lea    0x4(%eax),%edx
  80063f:	89 55 14             	mov    %edx,0x14(%ebp)
  800642:	8b 00                	mov    (%eax),%eax
  800644:	99                   	cltd   
  800645:	31 d0                	xor    %edx,%eax
  800647:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800649:	83 f8 08             	cmp    $0x8,%eax
  80064c:	7f 0b                	jg     800659 <vprintfmt+0x14d>
  80064e:	8b 14 85 00 12 80 00 	mov    0x801200(,%eax,4),%edx
  800655:	85 d2                	test   %edx,%edx
  800657:	75 18                	jne    800671 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  800659:	50                   	push   %eax
  80065a:	68 f6 0f 80 00       	push   $0x800ff6
  80065f:	53                   	push   %ebx
  800660:	56                   	push   %esi
  800661:	e8 89 fe ff ff       	call   8004ef <printfmt>
  800666:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800669:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80066c:	e9 cc fe ff ff       	jmp    80053d <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  800671:	52                   	push   %edx
  800672:	68 ff 0f 80 00       	push   $0x800fff
  800677:	53                   	push   %ebx
  800678:	56                   	push   %esi
  800679:	e8 71 fe ff ff       	call   8004ef <printfmt>
  80067e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800681:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800684:	e9 b4 fe ff ff       	jmp    80053d <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800689:	8b 45 14             	mov    0x14(%ebp),%eax
  80068c:	8d 50 04             	lea    0x4(%eax),%edx
  80068f:	89 55 14             	mov    %edx,0x14(%ebp)
  800692:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800694:	85 ff                	test   %edi,%edi
  800696:	b8 ef 0f 80 00       	mov    $0x800fef,%eax
  80069b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80069e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006a2:	0f 8e 94 00 00 00    	jle    80073c <vprintfmt+0x230>
  8006a8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006ac:	0f 84 98 00 00 00    	je     80074a <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b2:	83 ec 08             	sub    $0x8,%esp
  8006b5:	ff 75 d0             	pushl  -0x30(%ebp)
  8006b8:	57                   	push   %edi
  8006b9:	e8 c1 02 00 00       	call   80097f <strnlen>
  8006be:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006c1:	29 c1                	sub    %eax,%ecx
  8006c3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006c6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006c9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006d3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d5:	eb 0f                	jmp    8006e6 <vprintfmt+0x1da>
					putch(padc, putdat);
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	53                   	push   %ebx
  8006db:	ff 75 e0             	pushl  -0x20(%ebp)
  8006de:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e0:	83 ef 01             	sub    $0x1,%edi
  8006e3:	83 c4 10             	add    $0x10,%esp
  8006e6:	85 ff                	test   %edi,%edi
  8006e8:	7f ed                	jg     8006d7 <vprintfmt+0x1cb>
  8006ea:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006ed:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006f0:	85 c9                	test   %ecx,%ecx
  8006f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f7:	0f 49 c1             	cmovns %ecx,%eax
  8006fa:	29 c1                	sub    %eax,%ecx
  8006fc:	89 75 08             	mov    %esi,0x8(%ebp)
  8006ff:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800702:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800705:	89 cb                	mov    %ecx,%ebx
  800707:	eb 4d                	jmp    800756 <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800709:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80070d:	74 1b                	je     80072a <vprintfmt+0x21e>
  80070f:	0f be c0             	movsbl %al,%eax
  800712:	83 e8 20             	sub    $0x20,%eax
  800715:	83 f8 5e             	cmp    $0x5e,%eax
  800718:	76 10                	jbe    80072a <vprintfmt+0x21e>
					putch('?', putdat);
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	ff 75 0c             	pushl  0xc(%ebp)
  800720:	6a 3f                	push   $0x3f
  800722:	ff 55 08             	call   *0x8(%ebp)
  800725:	83 c4 10             	add    $0x10,%esp
  800728:	eb 0d                	jmp    800737 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	52                   	push   %edx
  800731:	ff 55 08             	call   *0x8(%ebp)
  800734:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800737:	83 eb 01             	sub    $0x1,%ebx
  80073a:	eb 1a                	jmp    800756 <vprintfmt+0x24a>
  80073c:	89 75 08             	mov    %esi,0x8(%ebp)
  80073f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800742:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800745:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800748:	eb 0c                	jmp    800756 <vprintfmt+0x24a>
  80074a:	89 75 08             	mov    %esi,0x8(%ebp)
  80074d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800750:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800753:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800756:	83 c7 01             	add    $0x1,%edi
  800759:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80075d:	0f be d0             	movsbl %al,%edx
  800760:	85 d2                	test   %edx,%edx
  800762:	74 23                	je     800787 <vprintfmt+0x27b>
  800764:	85 f6                	test   %esi,%esi
  800766:	78 a1                	js     800709 <vprintfmt+0x1fd>
  800768:	83 ee 01             	sub    $0x1,%esi
  80076b:	79 9c                	jns    800709 <vprintfmt+0x1fd>
  80076d:	89 df                	mov    %ebx,%edi
  80076f:	8b 75 08             	mov    0x8(%ebp),%esi
  800772:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800775:	eb 18                	jmp    80078f <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800777:	83 ec 08             	sub    $0x8,%esp
  80077a:	53                   	push   %ebx
  80077b:	6a 20                	push   $0x20
  80077d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80077f:	83 ef 01             	sub    $0x1,%edi
  800782:	83 c4 10             	add    $0x10,%esp
  800785:	eb 08                	jmp    80078f <vprintfmt+0x283>
  800787:	89 df                	mov    %ebx,%edi
  800789:	8b 75 08             	mov    0x8(%ebp),%esi
  80078c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80078f:	85 ff                	test   %edi,%edi
  800791:	7f e4                	jg     800777 <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800793:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800796:	e9 a2 fd ff ff       	jmp    80053d <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80079b:	83 fa 01             	cmp    $0x1,%edx
  80079e:	7e 16                	jle    8007b6 <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8007a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a3:	8d 50 08             	lea    0x8(%eax),%edx
  8007a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a9:	8b 50 04             	mov    0x4(%eax),%edx
  8007ac:	8b 00                	mov    (%eax),%eax
  8007ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007b4:	eb 32                	jmp    8007e8 <vprintfmt+0x2dc>
	else if (lflag)
  8007b6:	85 d2                	test   %edx,%edx
  8007b8:	74 18                	je     8007d2 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  8007ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bd:	8d 50 04             	lea    0x4(%eax),%edx
  8007c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c3:	8b 00                	mov    (%eax),%eax
  8007c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c8:	89 c1                	mov    %eax,%ecx
  8007ca:	c1 f9 1f             	sar    $0x1f,%ecx
  8007cd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007d0:	eb 16                	jmp    8007e8 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	8d 50 04             	lea    0x4(%eax),%edx
  8007d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007db:	8b 00                	mov    (%eax),%eax
  8007dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e0:	89 c1                	mov    %eax,%ecx
  8007e2:	c1 f9 1f             	sar    $0x1f,%ecx
  8007e5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007e8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007eb:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007ee:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007f3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007f7:	79 74                	jns    80086d <vprintfmt+0x361>
				putch('-', putdat);
  8007f9:	83 ec 08             	sub    $0x8,%esp
  8007fc:	53                   	push   %ebx
  8007fd:	6a 2d                	push   $0x2d
  8007ff:	ff d6                	call   *%esi
				num = -(long long) num;
  800801:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800804:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800807:	f7 d8                	neg    %eax
  800809:	83 d2 00             	adc    $0x0,%edx
  80080c:	f7 da                	neg    %edx
  80080e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800811:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800816:	eb 55                	jmp    80086d <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800818:	8d 45 14             	lea    0x14(%ebp),%eax
  80081b:	e8 78 fc ff ff       	call   800498 <getuint>
			base = 10;
  800820:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800825:	eb 46                	jmp    80086d <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800827:	8d 45 14             	lea    0x14(%ebp),%eax
  80082a:	e8 69 fc ff ff       	call   800498 <getuint>
      base = 8;
  80082f:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800834:	eb 37                	jmp    80086d <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  800836:	83 ec 08             	sub    $0x8,%esp
  800839:	53                   	push   %ebx
  80083a:	6a 30                	push   $0x30
  80083c:	ff d6                	call   *%esi
			putch('x', putdat);
  80083e:	83 c4 08             	add    $0x8,%esp
  800841:	53                   	push   %ebx
  800842:	6a 78                	push   $0x78
  800844:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800846:	8b 45 14             	mov    0x14(%ebp),%eax
  800849:	8d 50 04             	lea    0x4(%eax),%edx
  80084c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80084f:	8b 00                	mov    (%eax),%eax
  800851:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800856:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800859:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80085e:	eb 0d                	jmp    80086d <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800860:	8d 45 14             	lea    0x14(%ebp),%eax
  800863:	e8 30 fc ff ff       	call   800498 <getuint>
			base = 16;
  800868:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80086d:	83 ec 0c             	sub    $0xc,%esp
  800870:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800874:	57                   	push   %edi
  800875:	ff 75 e0             	pushl  -0x20(%ebp)
  800878:	51                   	push   %ecx
  800879:	52                   	push   %edx
  80087a:	50                   	push   %eax
  80087b:	89 da                	mov    %ebx,%edx
  80087d:	89 f0                	mov    %esi,%eax
  80087f:	e8 65 fb ff ff       	call   8003e9 <printnum>
			break;
  800884:	83 c4 20             	add    $0x20,%esp
  800887:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80088a:	e9 ae fc ff ff       	jmp    80053d <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80088f:	83 ec 08             	sub    $0x8,%esp
  800892:	53                   	push   %ebx
  800893:	51                   	push   %ecx
  800894:	ff d6                	call   *%esi
			break;
  800896:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800899:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80089c:	e9 9c fc ff ff       	jmp    80053d <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008a1:	83 fa 01             	cmp    $0x1,%edx
  8008a4:	7e 0d                	jle    8008b3 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8008a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a9:	8d 50 08             	lea    0x8(%eax),%edx
  8008ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8008af:	8b 00                	mov    (%eax),%eax
  8008b1:	eb 1c                	jmp    8008cf <vprintfmt+0x3c3>
	else if (lflag)
  8008b3:	85 d2                	test   %edx,%edx
  8008b5:	74 0d                	je     8008c4 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  8008b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ba:	8d 50 04             	lea    0x4(%eax),%edx
  8008bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c0:	8b 00                	mov    (%eax),%eax
  8008c2:	eb 0b                	jmp    8008cf <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  8008c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c7:	8d 50 04             	lea    0x4(%eax),%edx
  8008ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8008cd:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  8008cf:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  8008d7:	e9 61 fc ff ff       	jmp    80053d <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008dc:	83 ec 08             	sub    $0x8,%esp
  8008df:	53                   	push   %ebx
  8008e0:	6a 25                	push   $0x25
  8008e2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008e4:	83 c4 10             	add    $0x10,%esp
  8008e7:	eb 03                	jmp    8008ec <vprintfmt+0x3e0>
  8008e9:	83 ef 01             	sub    $0x1,%edi
  8008ec:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008f0:	75 f7                	jne    8008e9 <vprintfmt+0x3dd>
  8008f2:	e9 46 fc ff ff       	jmp    80053d <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  8008f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5f                   	pop    %edi
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	83 ec 18             	sub    $0x18,%esp
  800905:	8b 45 08             	mov    0x8(%ebp),%eax
  800908:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80090b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80090e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800912:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800915:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80091c:	85 c0                	test   %eax,%eax
  80091e:	74 26                	je     800946 <vsnprintf+0x47>
  800920:	85 d2                	test   %edx,%edx
  800922:	7e 22                	jle    800946 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800924:	ff 75 14             	pushl  0x14(%ebp)
  800927:	ff 75 10             	pushl  0x10(%ebp)
  80092a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80092d:	50                   	push   %eax
  80092e:	68 d2 04 80 00       	push   $0x8004d2
  800933:	e8 d4 fb ff ff       	call   80050c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800938:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80093b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80093e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800941:	83 c4 10             	add    $0x10,%esp
  800944:	eb 05                	jmp    80094b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800946:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80094b:	c9                   	leave  
  80094c:	c3                   	ret    

0080094d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800953:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800956:	50                   	push   %eax
  800957:	ff 75 10             	pushl  0x10(%ebp)
  80095a:	ff 75 0c             	pushl  0xc(%ebp)
  80095d:	ff 75 08             	pushl  0x8(%ebp)
  800960:	e8 9a ff ff ff       	call   8008ff <vsnprintf>
	va_end(ap);

	return rc;
}
  800965:	c9                   	leave  
  800966:	c3                   	ret    

00800967 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80096d:	b8 00 00 00 00       	mov    $0x0,%eax
  800972:	eb 03                	jmp    800977 <strlen+0x10>
		n++;
  800974:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800977:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80097b:	75 f7                	jne    800974 <strlen+0xd>
		n++;
	return n;
}
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800985:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800988:	ba 00 00 00 00       	mov    $0x0,%edx
  80098d:	eb 03                	jmp    800992 <strnlen+0x13>
		n++;
  80098f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800992:	39 c2                	cmp    %eax,%edx
  800994:	74 08                	je     80099e <strnlen+0x1f>
  800996:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80099a:	75 f3                	jne    80098f <strnlen+0x10>
  80099c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	53                   	push   %ebx
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009aa:	89 c2                	mov    %eax,%edx
  8009ac:	83 c2 01             	add    $0x1,%edx
  8009af:	83 c1 01             	add    $0x1,%ecx
  8009b2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009b6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009b9:	84 db                	test   %bl,%bl
  8009bb:	75 ef                	jne    8009ac <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009bd:	5b                   	pop    %ebx
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	53                   	push   %ebx
  8009c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009c7:	53                   	push   %ebx
  8009c8:	e8 9a ff ff ff       	call   800967 <strlen>
  8009cd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009d0:	ff 75 0c             	pushl  0xc(%ebp)
  8009d3:	01 d8                	add    %ebx,%eax
  8009d5:	50                   	push   %eax
  8009d6:	e8 c5 ff ff ff       	call   8009a0 <strcpy>
	return dst;
}
  8009db:	89 d8                	mov    %ebx,%eax
  8009dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e0:	c9                   	leave  
  8009e1:	c3                   	ret    

008009e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	56                   	push   %esi
  8009e6:	53                   	push   %ebx
  8009e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ed:	89 f3                	mov    %esi,%ebx
  8009ef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f2:	89 f2                	mov    %esi,%edx
  8009f4:	eb 0f                	jmp    800a05 <strncpy+0x23>
		*dst++ = *src;
  8009f6:	83 c2 01             	add    $0x1,%edx
  8009f9:	0f b6 01             	movzbl (%ecx),%eax
  8009fc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ff:	80 39 01             	cmpb   $0x1,(%ecx)
  800a02:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a05:	39 da                	cmp    %ebx,%edx
  800a07:	75 ed                	jne    8009f6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a09:	89 f0                	mov    %esi,%eax
  800a0b:	5b                   	pop    %ebx
  800a0c:	5e                   	pop    %esi
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	56                   	push   %esi
  800a13:	53                   	push   %ebx
  800a14:	8b 75 08             	mov    0x8(%ebp),%esi
  800a17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1a:	8b 55 10             	mov    0x10(%ebp),%edx
  800a1d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a1f:	85 d2                	test   %edx,%edx
  800a21:	74 21                	je     800a44 <strlcpy+0x35>
  800a23:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a27:	89 f2                	mov    %esi,%edx
  800a29:	eb 09                	jmp    800a34 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a2b:	83 c2 01             	add    $0x1,%edx
  800a2e:	83 c1 01             	add    $0x1,%ecx
  800a31:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a34:	39 c2                	cmp    %eax,%edx
  800a36:	74 09                	je     800a41 <strlcpy+0x32>
  800a38:	0f b6 19             	movzbl (%ecx),%ebx
  800a3b:	84 db                	test   %bl,%bl
  800a3d:	75 ec                	jne    800a2b <strlcpy+0x1c>
  800a3f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a41:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a44:	29 f0                	sub    %esi,%eax
}
  800a46:	5b                   	pop    %ebx
  800a47:	5e                   	pop    %esi
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a50:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a53:	eb 06                	jmp    800a5b <strcmp+0x11>
		p++, q++;
  800a55:	83 c1 01             	add    $0x1,%ecx
  800a58:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a5b:	0f b6 01             	movzbl (%ecx),%eax
  800a5e:	84 c0                	test   %al,%al
  800a60:	74 04                	je     800a66 <strcmp+0x1c>
  800a62:	3a 02                	cmp    (%edx),%al
  800a64:	74 ef                	je     800a55 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a66:	0f b6 c0             	movzbl %al,%eax
  800a69:	0f b6 12             	movzbl (%edx),%edx
  800a6c:	29 d0                	sub    %edx,%eax
}
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	53                   	push   %ebx
  800a74:	8b 45 08             	mov    0x8(%ebp),%eax
  800a77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7a:	89 c3                	mov    %eax,%ebx
  800a7c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a7f:	eb 06                	jmp    800a87 <strncmp+0x17>
		n--, p++, q++;
  800a81:	83 c0 01             	add    $0x1,%eax
  800a84:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a87:	39 d8                	cmp    %ebx,%eax
  800a89:	74 15                	je     800aa0 <strncmp+0x30>
  800a8b:	0f b6 08             	movzbl (%eax),%ecx
  800a8e:	84 c9                	test   %cl,%cl
  800a90:	74 04                	je     800a96 <strncmp+0x26>
  800a92:	3a 0a                	cmp    (%edx),%cl
  800a94:	74 eb                	je     800a81 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a96:	0f b6 00             	movzbl (%eax),%eax
  800a99:	0f b6 12             	movzbl (%edx),%edx
  800a9c:	29 d0                	sub    %edx,%eax
  800a9e:	eb 05                	jmp    800aa5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aa0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aa5:	5b                   	pop    %ebx
  800aa6:	5d                   	pop    %ebp
  800aa7:	c3                   	ret    

00800aa8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab2:	eb 07                	jmp    800abb <strchr+0x13>
		if (*s == c)
  800ab4:	38 ca                	cmp    %cl,%dl
  800ab6:	74 0f                	je     800ac7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ab8:	83 c0 01             	add    $0x1,%eax
  800abb:	0f b6 10             	movzbl (%eax),%edx
  800abe:	84 d2                	test   %dl,%dl
  800ac0:	75 f2                	jne    800ab4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ac2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	8b 45 08             	mov    0x8(%ebp),%eax
  800acf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad3:	eb 03                	jmp    800ad8 <strfind+0xf>
  800ad5:	83 c0 01             	add    $0x1,%eax
  800ad8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800adb:	38 ca                	cmp    %cl,%dl
  800add:	74 04                	je     800ae3 <strfind+0x1a>
  800adf:	84 d2                	test   %dl,%dl
  800ae1:	75 f2                	jne    800ad5 <strfind+0xc>
			break;
	return (char *) s;
}
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	57                   	push   %edi
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
  800aeb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800af1:	85 c9                	test   %ecx,%ecx
  800af3:	74 36                	je     800b2b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800af5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800afb:	75 28                	jne    800b25 <memset+0x40>
  800afd:	f6 c1 03             	test   $0x3,%cl
  800b00:	75 23                	jne    800b25 <memset+0x40>
		c &= 0xFF;
  800b02:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b06:	89 d3                	mov    %edx,%ebx
  800b08:	c1 e3 08             	shl    $0x8,%ebx
  800b0b:	89 d6                	mov    %edx,%esi
  800b0d:	c1 e6 18             	shl    $0x18,%esi
  800b10:	89 d0                	mov    %edx,%eax
  800b12:	c1 e0 10             	shl    $0x10,%eax
  800b15:	09 f0                	or     %esi,%eax
  800b17:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b19:	89 d8                	mov    %ebx,%eax
  800b1b:	09 d0                	or     %edx,%eax
  800b1d:	c1 e9 02             	shr    $0x2,%ecx
  800b20:	fc                   	cld    
  800b21:	f3 ab                	rep stos %eax,%es:(%edi)
  800b23:	eb 06                	jmp    800b2b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b28:	fc                   	cld    
  800b29:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b2b:	89 f8                	mov    %edi,%eax
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	57                   	push   %edi
  800b36:	56                   	push   %esi
  800b37:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b40:	39 c6                	cmp    %eax,%esi
  800b42:	73 35                	jae    800b79 <memmove+0x47>
  800b44:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b47:	39 d0                	cmp    %edx,%eax
  800b49:	73 2e                	jae    800b79 <memmove+0x47>
		s += n;
		d += n;
  800b4b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4e:	89 d6                	mov    %edx,%esi
  800b50:	09 fe                	or     %edi,%esi
  800b52:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b58:	75 13                	jne    800b6d <memmove+0x3b>
  800b5a:	f6 c1 03             	test   $0x3,%cl
  800b5d:	75 0e                	jne    800b6d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b5f:	83 ef 04             	sub    $0x4,%edi
  800b62:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b65:	c1 e9 02             	shr    $0x2,%ecx
  800b68:	fd                   	std    
  800b69:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b6b:	eb 09                	jmp    800b76 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b6d:	83 ef 01             	sub    $0x1,%edi
  800b70:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b73:	fd                   	std    
  800b74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b76:	fc                   	cld    
  800b77:	eb 1d                	jmp    800b96 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b79:	89 f2                	mov    %esi,%edx
  800b7b:	09 c2                	or     %eax,%edx
  800b7d:	f6 c2 03             	test   $0x3,%dl
  800b80:	75 0f                	jne    800b91 <memmove+0x5f>
  800b82:	f6 c1 03             	test   $0x3,%cl
  800b85:	75 0a                	jne    800b91 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b87:	c1 e9 02             	shr    $0x2,%ecx
  800b8a:	89 c7                	mov    %eax,%edi
  800b8c:	fc                   	cld    
  800b8d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b8f:	eb 05                	jmp    800b96 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b91:	89 c7                	mov    %eax,%edi
  800b93:	fc                   	cld    
  800b94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b9d:	ff 75 10             	pushl  0x10(%ebp)
  800ba0:	ff 75 0c             	pushl  0xc(%ebp)
  800ba3:	ff 75 08             	pushl  0x8(%ebp)
  800ba6:	e8 87 ff ff ff       	call   800b32 <memmove>
}
  800bab:	c9                   	leave  
  800bac:	c3                   	ret    

00800bad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb8:	89 c6                	mov    %eax,%esi
  800bba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbd:	eb 1a                	jmp    800bd9 <memcmp+0x2c>
		if (*s1 != *s2)
  800bbf:	0f b6 08             	movzbl (%eax),%ecx
  800bc2:	0f b6 1a             	movzbl (%edx),%ebx
  800bc5:	38 d9                	cmp    %bl,%cl
  800bc7:	74 0a                	je     800bd3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bc9:	0f b6 c1             	movzbl %cl,%eax
  800bcc:	0f b6 db             	movzbl %bl,%ebx
  800bcf:	29 d8                	sub    %ebx,%eax
  800bd1:	eb 0f                	jmp    800be2 <memcmp+0x35>
		s1++, s2++;
  800bd3:	83 c0 01             	add    $0x1,%eax
  800bd6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd9:	39 f0                	cmp    %esi,%eax
  800bdb:	75 e2                	jne    800bbf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bdd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	53                   	push   %ebx
  800bea:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bed:	89 c1                	mov    %eax,%ecx
  800bef:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bf6:	eb 0a                	jmp    800c02 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf8:	0f b6 10             	movzbl (%eax),%edx
  800bfb:	39 da                	cmp    %ebx,%edx
  800bfd:	74 07                	je     800c06 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bff:	83 c0 01             	add    $0x1,%eax
  800c02:	39 c8                	cmp    %ecx,%eax
  800c04:	72 f2                	jb     800bf8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c06:	5b                   	pop    %ebx
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	57                   	push   %edi
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
  800c0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c12:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c15:	eb 03                	jmp    800c1a <strtol+0x11>
		s++;
  800c17:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c1a:	0f b6 01             	movzbl (%ecx),%eax
  800c1d:	3c 20                	cmp    $0x20,%al
  800c1f:	74 f6                	je     800c17 <strtol+0xe>
  800c21:	3c 09                	cmp    $0x9,%al
  800c23:	74 f2                	je     800c17 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c25:	3c 2b                	cmp    $0x2b,%al
  800c27:	75 0a                	jne    800c33 <strtol+0x2a>
		s++;
  800c29:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c2c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c31:	eb 11                	jmp    800c44 <strtol+0x3b>
  800c33:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c38:	3c 2d                	cmp    $0x2d,%al
  800c3a:	75 08                	jne    800c44 <strtol+0x3b>
		s++, neg = 1;
  800c3c:	83 c1 01             	add    $0x1,%ecx
  800c3f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c44:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c4a:	75 15                	jne    800c61 <strtol+0x58>
  800c4c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c4f:	75 10                	jne    800c61 <strtol+0x58>
  800c51:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c55:	75 7c                	jne    800cd3 <strtol+0xca>
		s += 2, base = 16;
  800c57:	83 c1 02             	add    $0x2,%ecx
  800c5a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c5f:	eb 16                	jmp    800c77 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c61:	85 db                	test   %ebx,%ebx
  800c63:	75 12                	jne    800c77 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c65:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c6a:	80 39 30             	cmpb   $0x30,(%ecx)
  800c6d:	75 08                	jne    800c77 <strtol+0x6e>
		s++, base = 8;
  800c6f:	83 c1 01             	add    $0x1,%ecx
  800c72:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c77:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c7f:	0f b6 11             	movzbl (%ecx),%edx
  800c82:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c85:	89 f3                	mov    %esi,%ebx
  800c87:	80 fb 09             	cmp    $0x9,%bl
  800c8a:	77 08                	ja     800c94 <strtol+0x8b>
			dig = *s - '0';
  800c8c:	0f be d2             	movsbl %dl,%edx
  800c8f:	83 ea 30             	sub    $0x30,%edx
  800c92:	eb 22                	jmp    800cb6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c94:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c97:	89 f3                	mov    %esi,%ebx
  800c99:	80 fb 19             	cmp    $0x19,%bl
  800c9c:	77 08                	ja     800ca6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c9e:	0f be d2             	movsbl %dl,%edx
  800ca1:	83 ea 57             	sub    $0x57,%edx
  800ca4:	eb 10                	jmp    800cb6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ca6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ca9:	89 f3                	mov    %esi,%ebx
  800cab:	80 fb 19             	cmp    $0x19,%bl
  800cae:	77 16                	ja     800cc6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cb0:	0f be d2             	movsbl %dl,%edx
  800cb3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cb6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cb9:	7d 0b                	jge    800cc6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cbb:	83 c1 01             	add    $0x1,%ecx
  800cbe:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cc2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cc4:	eb b9                	jmp    800c7f <strtol+0x76>

	if (endptr)
  800cc6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cca:	74 0d                	je     800cd9 <strtol+0xd0>
		*endptr = (char *) s;
  800ccc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ccf:	89 0e                	mov    %ecx,(%esi)
  800cd1:	eb 06                	jmp    800cd9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cd3:	85 db                	test   %ebx,%ebx
  800cd5:	74 98                	je     800c6f <strtol+0x66>
  800cd7:	eb 9e                	jmp    800c77 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cd9:	89 c2                	mov    %eax,%edx
  800cdb:	f7 da                	neg    %edx
  800cdd:	85 ff                	test   %edi,%edi
  800cdf:	0f 45 c2             	cmovne %edx,%eax
}
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    
  800ce7:	66 90                	xchg   %ax,%ax
  800ce9:	66 90                	xchg   %ax,%ax
  800ceb:	66 90                	xchg   %ax,%ax
  800ced:	66 90                	xchg   %ax,%ax
  800cef:	90                   	nop

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
