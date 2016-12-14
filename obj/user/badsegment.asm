
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800049:	e8 ce 00 00 00       	call   80011c <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008a:	e8 6b 05 00 00       	call   8005fa <close_all>
	sys_env_destroy(0);
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	6a 00                	push   $0x0
  800094:	e8 42 00 00 00       	call   8000db <sys_env_destroy>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cc:	89 d1                	mov    %edx,%ecx
  8000ce:	89 d3                	mov    %edx,%ebx
  8000d0:	89 d7                	mov    %edx,%edi
  8000d2:	89 d6                	mov    %edx,%esi
  8000d4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f1:	89 cb                	mov    %ecx,%ebx
  8000f3:	89 cf                	mov    %ecx,%edi
  8000f5:	89 ce                	mov    %ecx,%esi
  8000f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	7e 17                	jle    800114 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	50                   	push   %eax
  800101:	6a 03                	push   $0x3
  800103:	68 2a 23 80 00       	push   $0x80232a
  800108:	6a 23                	push   $0x23
  80010a:	68 47 23 80 00       	push   $0x802347
  80010f:	e8 95 14 00 00       	call   8015a9 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5f                   	pop    %edi
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    

0080011c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	57                   	push   %edi
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800122:	ba 00 00 00 00       	mov    $0x0,%edx
  800127:	b8 02 00 00 00       	mov    $0x2,%eax
  80012c:	89 d1                	mov    %edx,%ecx
  80012e:	89 d3                	mov    %edx,%ebx
  800130:	89 d7                	mov    %edx,%edi
  800132:	89 d6                	mov    %edx,%esi
  800134:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_yield>:

void
sys_yield(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800163:	be 00 00 00 00       	mov    $0x0,%esi
  800168:	b8 04 00 00 00       	mov    $0x4,%eax
  80016d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800176:	89 f7                	mov    %esi,%edi
  800178:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017a:	85 c0                	test   %eax,%eax
  80017c:	7e 17                	jle    800195 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	50                   	push   %eax
  800182:	6a 04                	push   $0x4
  800184:	68 2a 23 80 00       	push   $0x80232a
  800189:	6a 23                	push   $0x23
  80018b:	68 47 23 80 00       	push   $0x802347
  800190:	e8 14 14 00 00       	call   8015a9 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800198:	5b                   	pop    %ebx
  800199:	5e                   	pop    %esi
  80019a:	5f                   	pop    %edi
  80019b:	5d                   	pop    %ebp
  80019c:	c3                   	ret    

0080019d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001bc:	85 c0                	test   %eax,%eax
  8001be:	7e 17                	jle    8001d7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	50                   	push   %eax
  8001c4:	6a 05                	push   $0x5
  8001c6:	68 2a 23 80 00       	push   $0x80232a
  8001cb:	6a 23                	push   $0x23
  8001cd:	68 47 23 80 00       	push   $0x802347
  8001d2:	e8 d2 13 00 00       	call   8015a9 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001da:	5b                   	pop    %ebx
  8001db:	5e                   	pop    %esi
  8001dc:	5f                   	pop    %edi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	57                   	push   %edi
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f8:	89 df                	mov    %ebx,%edi
  8001fa:	89 de                	mov    %ebx,%esi
  8001fc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001fe:	85 c0                	test   %eax,%eax
  800200:	7e 17                	jle    800219 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	50                   	push   %eax
  800206:	6a 06                	push   $0x6
  800208:	68 2a 23 80 00       	push   $0x80232a
  80020d:	6a 23                	push   $0x23
  80020f:	68 47 23 80 00       	push   $0x802347
  800214:	e8 90 13 00 00       	call   8015a9 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021c:	5b                   	pop    %ebx
  80021d:	5e                   	pop    %esi
  80021e:	5f                   	pop    %edi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022f:	b8 08 00 00 00       	mov    $0x8,%eax
  800234:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800237:	8b 55 08             	mov    0x8(%ebp),%edx
  80023a:	89 df                	mov    %ebx,%edi
  80023c:	89 de                	mov    %ebx,%esi
  80023e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7e 17                	jle    80025b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	50                   	push   %eax
  800248:	6a 08                	push   $0x8
  80024a:	68 2a 23 80 00       	push   $0x80232a
  80024f:	6a 23                	push   $0x23
  800251:	68 47 23 80 00       	push   $0x802347
  800256:	e8 4e 13 00 00       	call   8015a9 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800271:	b8 09 00 00 00       	mov    $0x9,%eax
  800276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
  80027c:	89 df                	mov    %ebx,%edi
  80027e:	89 de                	mov    %ebx,%esi
  800280:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800282:	85 c0                	test   %eax,%eax
  800284:	7e 17                	jle    80029d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	50                   	push   %eax
  80028a:	6a 09                	push   $0x9
  80028c:	68 2a 23 80 00       	push   $0x80232a
  800291:	6a 23                	push   $0x23
  800293:	68 47 23 80 00       	push   $0x802347
  800298:	e8 0c 13 00 00       	call   8015a9 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80029d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a0:	5b                   	pop    %ebx
  8002a1:	5e                   	pop    %esi
  8002a2:	5f                   	pop    %edi
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002be:	89 df                	mov    %ebx,%edi
  8002c0:	89 de                	mov    %ebx,%esi
  8002c2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	7e 17                	jle    8002df <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c8:	83 ec 0c             	sub    $0xc,%esp
  8002cb:	50                   	push   %eax
  8002cc:	6a 0a                	push   $0xa
  8002ce:	68 2a 23 80 00       	push   $0x80232a
  8002d3:	6a 23                	push   $0x23
  8002d5:	68 47 23 80 00       	push   $0x802347
  8002da:	e8 ca 12 00 00       	call   8015a9 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ed:	be 00 00 00 00       	mov    $0x0,%esi
  8002f2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800300:	8b 7d 14             	mov    0x14(%ebp),%edi
  800303:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800313:	b9 00 00 00 00       	mov    $0x0,%ecx
  800318:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	89 cb                	mov    %ecx,%ebx
  800322:	89 cf                	mov    %ecx,%edi
  800324:	89 ce                	mov    %ecx,%esi
  800326:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800328:	85 c0                	test   %eax,%eax
  80032a:	7e 17                	jle    800343 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032c:	83 ec 0c             	sub    $0xc,%esp
  80032f:	50                   	push   %eax
  800330:	6a 0d                	push   $0xd
  800332:	68 2a 23 80 00       	push   $0x80232a
  800337:	6a 23                	push   $0x23
  800339:	68 47 23 80 00       	push   $0x802347
  80033e:	e8 66 12 00 00       	call   8015a9 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800343:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800346:	5b                   	pop    %ebx
  800347:	5e                   	pop    %esi
  800348:	5f                   	pop    %edi
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	57                   	push   %edi
  80034f:	56                   	push   %esi
  800350:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
  800356:	b8 0e 00 00 00       	mov    $0xe,%eax
  80035b:	89 d1                	mov    %edx,%ecx
  80035d:	89 d3                	mov    %edx,%ebx
  80035f:	89 d7                	mov    %edx,%edi
  800361:	89 d6                	mov    %edx,%esi
  800363:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800365:	5b                   	pop    %ebx
  800366:	5e                   	pop    %esi
  800367:	5f                   	pop    %edi
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <sys_transmit_packet>:

int
sys_transmit_packet(void *buf, size_t size)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	57                   	push   %edi
  80036e:	56                   	push   %esi
  80036f:	53                   	push   %ebx
  800370:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800373:	bb 00 00 00 00       	mov    $0x0,%ebx
  800378:	b8 0f 00 00 00       	mov    $0xf,%eax
  80037d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800380:	8b 55 08             	mov    0x8(%ebp),%edx
  800383:	89 df                	mov    %ebx,%edi
  800385:	89 de                	mov    %ebx,%esi
  800387:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800389:	85 c0                	test   %eax,%eax
  80038b:	7e 17                	jle    8003a4 <sys_transmit_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80038d:	83 ec 0c             	sub    $0xc,%esp
  800390:	50                   	push   %eax
  800391:	6a 0f                	push   $0xf
  800393:	68 2a 23 80 00       	push   $0x80232a
  800398:	6a 23                	push   $0x23
  80039a:	68 47 23 80 00       	push   $0x802347
  80039f:	e8 05 12 00 00       	call   8015a9 <_panic>
int
sys_transmit_packet(void *buf, size_t size)
{
	return syscall(SYS_transmit_packet, 1,
		(uint32_t) buf, (uint32_t) size, 0, 0, 0);
}
  8003a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003a7:	5b                   	pop    %ebx
  8003a8:	5e                   	pop    %esi
  8003a9:	5f                   	pop    %edi
  8003aa:	5d                   	pop    %ebp
  8003ab:	c3                   	ret    

008003ac <sys_receive_packet>:

int
sys_receive_packet(void *buf, size_t *size_store)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	57                   	push   %edi
  8003b0:	56                   	push   %esi
  8003b1:	53                   	push   %ebx
  8003b2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003ba:	b8 10 00 00 00       	mov    $0x10,%eax
  8003bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c5:	89 df                	mov    %ebx,%edi
  8003c7:	89 de                	mov    %ebx,%esi
  8003c9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003cb:	85 c0                	test   %eax,%eax
  8003cd:	7e 17                	jle    8003e6 <sys_receive_packet+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003cf:	83 ec 0c             	sub    $0xc,%esp
  8003d2:	50                   	push   %eax
  8003d3:	6a 10                	push   $0x10
  8003d5:	68 2a 23 80 00       	push   $0x80232a
  8003da:	6a 23                	push   $0x23
  8003dc:	68 47 23 80 00       	push   $0x802347
  8003e1:	e8 c3 11 00 00       	call   8015a9 <_panic>
int
sys_receive_packet(void *buf, size_t *size_store)
{
	return syscall(SYS_receive_packet, 1,
		(uint32_t) buf, (uint32_t) size_store, 0, 0, 0);
}
  8003e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e9:	5b                   	pop    %ebx
  8003ea:	5e                   	pop    %esi
  8003eb:	5f                   	pop    %edi
  8003ec:	5d                   	pop    %ebp
  8003ed:	c3                   	ret    

008003ee <sys_get_mac_address>:

int
sys_get_mac_address(void *buf)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	57                   	push   %edi
  8003f2:	56                   	push   %esi
  8003f3:	53                   	push   %ebx
  8003f4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fc:	b8 11 00 00 00       	mov    $0x11,%eax
  800401:	8b 55 08             	mov    0x8(%ebp),%edx
  800404:	89 cb                	mov    %ecx,%ebx
  800406:	89 cf                	mov    %ecx,%edi
  800408:	89 ce                	mov    %ecx,%esi
  80040a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80040c:	85 c0                	test   %eax,%eax
  80040e:	7e 17                	jle    800427 <sys_get_mac_address+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800410:	83 ec 0c             	sub    $0xc,%esp
  800413:	50                   	push   %eax
  800414:	6a 11                	push   $0x11
  800416:	68 2a 23 80 00       	push   $0x80232a
  80041b:	6a 23                	push   $0x23
  80041d:	68 47 23 80 00       	push   $0x802347
  800422:	e8 82 11 00 00       	call   8015a9 <_panic>
int
sys_get_mac_address(void *buf)
{
	return syscall(SYS_get_mac_address, 1,
		(uint32_t) buf, 0, 0, 0, 0);
}
  800427:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042a:	5b                   	pop    %ebx
  80042b:	5e                   	pop    %esi
  80042c:	5f                   	pop    %edi
  80042d:	5d                   	pop    %ebp
  80042e:	c3                   	ret    

0080042f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800432:	8b 45 08             	mov    0x8(%ebp),%eax
  800435:	05 00 00 00 30       	add    $0x30000000,%eax
  80043a:	c1 e8 0c             	shr    $0xc,%eax
}
  80043d:	5d                   	pop    %ebp
  80043e:	c3                   	ret    

0080043f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80043f:	55                   	push   %ebp
  800440:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800442:	8b 45 08             	mov    0x8(%ebp),%eax
  800445:	05 00 00 00 30       	add    $0x30000000,%eax
  80044a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80044f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800454:	5d                   	pop    %ebp
  800455:	c3                   	ret    

00800456 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800456:	55                   	push   %ebp
  800457:	89 e5                	mov    %esp,%ebp
  800459:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800461:	89 c2                	mov    %eax,%edx
  800463:	c1 ea 16             	shr    $0x16,%edx
  800466:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80046d:	f6 c2 01             	test   $0x1,%dl
  800470:	74 11                	je     800483 <fd_alloc+0x2d>
  800472:	89 c2                	mov    %eax,%edx
  800474:	c1 ea 0c             	shr    $0xc,%edx
  800477:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80047e:	f6 c2 01             	test   $0x1,%dl
  800481:	75 09                	jne    80048c <fd_alloc+0x36>
			*fd_store = fd;
  800483:	89 01                	mov    %eax,(%ecx)
			return 0;
  800485:	b8 00 00 00 00       	mov    $0x0,%eax
  80048a:	eb 17                	jmp    8004a3 <fd_alloc+0x4d>
  80048c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800491:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800496:	75 c9                	jne    800461 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800498:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80049e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8004a3:	5d                   	pop    %ebp
  8004a4:	c3                   	ret    

008004a5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8004a5:	55                   	push   %ebp
  8004a6:	89 e5                	mov    %esp,%ebp
  8004a8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8004ab:	83 f8 1f             	cmp    $0x1f,%eax
  8004ae:	77 36                	ja     8004e6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8004b0:	c1 e0 0c             	shl    $0xc,%eax
  8004b3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8004b8:	89 c2                	mov    %eax,%edx
  8004ba:	c1 ea 16             	shr    $0x16,%edx
  8004bd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004c4:	f6 c2 01             	test   $0x1,%dl
  8004c7:	74 24                	je     8004ed <fd_lookup+0x48>
  8004c9:	89 c2                	mov    %eax,%edx
  8004cb:	c1 ea 0c             	shr    $0xc,%edx
  8004ce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004d5:	f6 c2 01             	test   $0x1,%dl
  8004d8:	74 1a                	je     8004f4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004dd:	89 02                	mov    %eax,(%edx)
	return 0;
  8004df:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e4:	eb 13                	jmp    8004f9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004eb:	eb 0c                	jmp    8004f9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004f2:	eb 05                	jmp    8004f9 <fd_lookup+0x54>
  8004f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800504:	ba d4 23 80 00       	mov    $0x8023d4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800509:	eb 13                	jmp    80051e <dev_lookup+0x23>
  80050b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80050e:	39 08                	cmp    %ecx,(%eax)
  800510:	75 0c                	jne    80051e <dev_lookup+0x23>
			*dev = devtab[i];
  800512:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800515:	89 01                	mov    %eax,(%ecx)
			return 0;
  800517:	b8 00 00 00 00       	mov    $0x0,%eax
  80051c:	eb 2e                	jmp    80054c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80051e:	8b 02                	mov    (%edx),%eax
  800520:	85 c0                	test   %eax,%eax
  800522:	75 e7                	jne    80050b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800524:	a1 08 40 80 00       	mov    0x804008,%eax
  800529:	8b 40 48             	mov    0x48(%eax),%eax
  80052c:	83 ec 04             	sub    $0x4,%esp
  80052f:	51                   	push   %ecx
  800530:	50                   	push   %eax
  800531:	68 58 23 80 00       	push   $0x802358
  800536:	e8 47 11 00 00       	call   801682 <cprintf>
	*dev = 0;
  80053b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80053e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800544:	83 c4 10             	add    $0x10,%esp
  800547:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80054c:	c9                   	leave  
  80054d:	c3                   	ret    

0080054e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80054e:	55                   	push   %ebp
  80054f:	89 e5                	mov    %esp,%ebp
  800551:	56                   	push   %esi
  800552:	53                   	push   %ebx
  800553:	83 ec 10             	sub    $0x10,%esp
  800556:	8b 75 08             	mov    0x8(%ebp),%esi
  800559:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80055c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80055f:	50                   	push   %eax
  800560:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800566:	c1 e8 0c             	shr    $0xc,%eax
  800569:	50                   	push   %eax
  80056a:	e8 36 ff ff ff       	call   8004a5 <fd_lookup>
  80056f:	83 c4 08             	add    $0x8,%esp
  800572:	85 c0                	test   %eax,%eax
  800574:	78 05                	js     80057b <fd_close+0x2d>
	    || fd != fd2)
  800576:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800579:	74 0c                	je     800587 <fd_close+0x39>
		return (must_exist ? r : 0);
  80057b:	84 db                	test   %bl,%bl
  80057d:	ba 00 00 00 00       	mov    $0x0,%edx
  800582:	0f 44 c2             	cmove  %edx,%eax
  800585:	eb 41                	jmp    8005c8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80058d:	50                   	push   %eax
  80058e:	ff 36                	pushl  (%esi)
  800590:	e8 66 ff ff ff       	call   8004fb <dev_lookup>
  800595:	89 c3                	mov    %eax,%ebx
  800597:	83 c4 10             	add    $0x10,%esp
  80059a:	85 c0                	test   %eax,%eax
  80059c:	78 1a                	js     8005b8 <fd_close+0x6a>
		if (dev->dev_close)
  80059e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005a1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8005a4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8005a9:	85 c0                	test   %eax,%eax
  8005ab:	74 0b                	je     8005b8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8005ad:	83 ec 0c             	sub    $0xc,%esp
  8005b0:	56                   	push   %esi
  8005b1:	ff d0                	call   *%eax
  8005b3:	89 c3                	mov    %eax,%ebx
  8005b5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8005b8:	83 ec 08             	sub    $0x8,%esp
  8005bb:	56                   	push   %esi
  8005bc:	6a 00                	push   $0x0
  8005be:	e8 1c fc ff ff       	call   8001df <sys_page_unmap>
	return r;
  8005c3:	83 c4 10             	add    $0x10,%esp
  8005c6:	89 d8                	mov    %ebx,%eax
}
  8005c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005cb:	5b                   	pop    %ebx
  8005cc:	5e                   	pop    %esi
  8005cd:	5d                   	pop    %ebp
  8005ce:	c3                   	ret    

008005cf <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005cf:	55                   	push   %ebp
  8005d0:	89 e5                	mov    %esp,%ebp
  8005d2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005d8:	50                   	push   %eax
  8005d9:	ff 75 08             	pushl  0x8(%ebp)
  8005dc:	e8 c4 fe ff ff       	call   8004a5 <fd_lookup>
  8005e1:	83 c4 08             	add    $0x8,%esp
  8005e4:	85 c0                	test   %eax,%eax
  8005e6:	78 10                	js     8005f8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	6a 01                	push   $0x1
  8005ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8005f0:	e8 59 ff ff ff       	call   80054e <fd_close>
  8005f5:	83 c4 10             	add    $0x10,%esp
}
  8005f8:	c9                   	leave  
  8005f9:	c3                   	ret    

008005fa <close_all>:

void
close_all(void)
{
  8005fa:	55                   	push   %ebp
  8005fb:	89 e5                	mov    %esp,%ebp
  8005fd:	53                   	push   %ebx
  8005fe:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800601:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800606:	83 ec 0c             	sub    $0xc,%esp
  800609:	53                   	push   %ebx
  80060a:	e8 c0 ff ff ff       	call   8005cf <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80060f:	83 c3 01             	add    $0x1,%ebx
  800612:	83 c4 10             	add    $0x10,%esp
  800615:	83 fb 20             	cmp    $0x20,%ebx
  800618:	75 ec                	jne    800606 <close_all+0xc>
		close(i);
}
  80061a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80061d:	c9                   	leave  
  80061e:	c3                   	ret    

0080061f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80061f:	55                   	push   %ebp
  800620:	89 e5                	mov    %esp,%ebp
  800622:	57                   	push   %edi
  800623:	56                   	push   %esi
  800624:	53                   	push   %ebx
  800625:	83 ec 2c             	sub    $0x2c,%esp
  800628:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80062b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80062e:	50                   	push   %eax
  80062f:	ff 75 08             	pushl  0x8(%ebp)
  800632:	e8 6e fe ff ff       	call   8004a5 <fd_lookup>
  800637:	83 c4 08             	add    $0x8,%esp
  80063a:	85 c0                	test   %eax,%eax
  80063c:	0f 88 c1 00 00 00    	js     800703 <dup+0xe4>
		return r;
	close(newfdnum);
  800642:	83 ec 0c             	sub    $0xc,%esp
  800645:	56                   	push   %esi
  800646:	e8 84 ff ff ff       	call   8005cf <close>

	newfd = INDEX2FD(newfdnum);
  80064b:	89 f3                	mov    %esi,%ebx
  80064d:	c1 e3 0c             	shl    $0xc,%ebx
  800650:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800656:	83 c4 04             	add    $0x4,%esp
  800659:	ff 75 e4             	pushl  -0x1c(%ebp)
  80065c:	e8 de fd ff ff       	call   80043f <fd2data>
  800661:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800663:	89 1c 24             	mov    %ebx,(%esp)
  800666:	e8 d4 fd ff ff       	call   80043f <fd2data>
  80066b:	83 c4 10             	add    $0x10,%esp
  80066e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800671:	89 f8                	mov    %edi,%eax
  800673:	c1 e8 16             	shr    $0x16,%eax
  800676:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80067d:	a8 01                	test   $0x1,%al
  80067f:	74 37                	je     8006b8 <dup+0x99>
  800681:	89 f8                	mov    %edi,%eax
  800683:	c1 e8 0c             	shr    $0xc,%eax
  800686:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80068d:	f6 c2 01             	test   $0x1,%dl
  800690:	74 26                	je     8006b8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800692:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800699:	83 ec 0c             	sub    $0xc,%esp
  80069c:	25 07 0e 00 00       	and    $0xe07,%eax
  8006a1:	50                   	push   %eax
  8006a2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006a5:	6a 00                	push   $0x0
  8006a7:	57                   	push   %edi
  8006a8:	6a 00                	push   $0x0
  8006aa:	e8 ee fa ff ff       	call   80019d <sys_page_map>
  8006af:	89 c7                	mov    %eax,%edi
  8006b1:	83 c4 20             	add    $0x20,%esp
  8006b4:	85 c0                	test   %eax,%eax
  8006b6:	78 2e                	js     8006e6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006bb:	89 d0                	mov    %edx,%eax
  8006bd:	c1 e8 0c             	shr    $0xc,%eax
  8006c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006c7:	83 ec 0c             	sub    $0xc,%esp
  8006ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8006cf:	50                   	push   %eax
  8006d0:	53                   	push   %ebx
  8006d1:	6a 00                	push   $0x0
  8006d3:	52                   	push   %edx
  8006d4:	6a 00                	push   $0x0
  8006d6:	e8 c2 fa ff ff       	call   80019d <sys_page_map>
  8006db:	89 c7                	mov    %eax,%edi
  8006dd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8006e0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006e2:	85 ff                	test   %edi,%edi
  8006e4:	79 1d                	jns    800703 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006e6:	83 ec 08             	sub    $0x8,%esp
  8006e9:	53                   	push   %ebx
  8006ea:	6a 00                	push   $0x0
  8006ec:	e8 ee fa ff ff       	call   8001df <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006f1:	83 c4 08             	add    $0x8,%esp
  8006f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006f7:	6a 00                	push   $0x0
  8006f9:	e8 e1 fa ff ff       	call   8001df <sys_page_unmap>
	return r;
  8006fe:	83 c4 10             	add    $0x10,%esp
  800701:	89 f8                	mov    %edi,%eax
}
  800703:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800706:	5b                   	pop    %ebx
  800707:	5e                   	pop    %esi
  800708:	5f                   	pop    %edi
  800709:	5d                   	pop    %ebp
  80070a:	c3                   	ret    

0080070b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	53                   	push   %ebx
  80070f:	83 ec 14             	sub    $0x14,%esp
  800712:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800715:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800718:	50                   	push   %eax
  800719:	53                   	push   %ebx
  80071a:	e8 86 fd ff ff       	call   8004a5 <fd_lookup>
  80071f:	83 c4 08             	add    $0x8,%esp
  800722:	89 c2                	mov    %eax,%edx
  800724:	85 c0                	test   %eax,%eax
  800726:	78 6d                	js     800795 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072e:	50                   	push   %eax
  80072f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800732:	ff 30                	pushl  (%eax)
  800734:	e8 c2 fd ff ff       	call   8004fb <dev_lookup>
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	85 c0                	test   %eax,%eax
  80073e:	78 4c                	js     80078c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800740:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800743:	8b 42 08             	mov    0x8(%edx),%eax
  800746:	83 e0 03             	and    $0x3,%eax
  800749:	83 f8 01             	cmp    $0x1,%eax
  80074c:	75 21                	jne    80076f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80074e:	a1 08 40 80 00       	mov    0x804008,%eax
  800753:	8b 40 48             	mov    0x48(%eax),%eax
  800756:	83 ec 04             	sub    $0x4,%esp
  800759:	53                   	push   %ebx
  80075a:	50                   	push   %eax
  80075b:	68 99 23 80 00       	push   $0x802399
  800760:	e8 1d 0f 00 00       	call   801682 <cprintf>
		return -E_INVAL;
  800765:	83 c4 10             	add    $0x10,%esp
  800768:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80076d:	eb 26                	jmp    800795 <read+0x8a>
	}
	if (!dev->dev_read)
  80076f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800772:	8b 40 08             	mov    0x8(%eax),%eax
  800775:	85 c0                	test   %eax,%eax
  800777:	74 17                	je     800790 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800779:	83 ec 04             	sub    $0x4,%esp
  80077c:	ff 75 10             	pushl  0x10(%ebp)
  80077f:	ff 75 0c             	pushl  0xc(%ebp)
  800782:	52                   	push   %edx
  800783:	ff d0                	call   *%eax
  800785:	89 c2                	mov    %eax,%edx
  800787:	83 c4 10             	add    $0x10,%esp
  80078a:	eb 09                	jmp    800795 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80078c:	89 c2                	mov    %eax,%edx
  80078e:	eb 05                	jmp    800795 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800790:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800795:	89 d0                	mov    %edx,%eax
  800797:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079a:	c9                   	leave  
  80079b:	c3                   	ret    

0080079c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	57                   	push   %edi
  8007a0:	56                   	push   %esi
  8007a1:	53                   	push   %ebx
  8007a2:	83 ec 0c             	sub    $0xc,%esp
  8007a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007a8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007b0:	eb 21                	jmp    8007d3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007b2:	83 ec 04             	sub    $0x4,%esp
  8007b5:	89 f0                	mov    %esi,%eax
  8007b7:	29 d8                	sub    %ebx,%eax
  8007b9:	50                   	push   %eax
  8007ba:	89 d8                	mov    %ebx,%eax
  8007bc:	03 45 0c             	add    0xc(%ebp),%eax
  8007bf:	50                   	push   %eax
  8007c0:	57                   	push   %edi
  8007c1:	e8 45 ff ff ff       	call   80070b <read>
		if (m < 0)
  8007c6:	83 c4 10             	add    $0x10,%esp
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	78 10                	js     8007dd <readn+0x41>
			return m;
		if (m == 0)
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	74 0a                	je     8007db <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007d1:	01 c3                	add    %eax,%ebx
  8007d3:	39 f3                	cmp    %esi,%ebx
  8007d5:	72 db                	jb     8007b2 <readn+0x16>
  8007d7:	89 d8                	mov    %ebx,%eax
  8007d9:	eb 02                	jmp    8007dd <readn+0x41>
  8007db:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8007dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007e0:	5b                   	pop    %ebx
  8007e1:	5e                   	pop    %esi
  8007e2:	5f                   	pop    %edi
  8007e3:	5d                   	pop    %ebp
  8007e4:	c3                   	ret    

008007e5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	53                   	push   %ebx
  8007e9:	83 ec 14             	sub    $0x14,%esp
  8007ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007f2:	50                   	push   %eax
  8007f3:	53                   	push   %ebx
  8007f4:	e8 ac fc ff ff       	call   8004a5 <fd_lookup>
  8007f9:	83 c4 08             	add    $0x8,%esp
  8007fc:	89 c2                	mov    %eax,%edx
  8007fe:	85 c0                	test   %eax,%eax
  800800:	78 68                	js     80086a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800802:	83 ec 08             	sub    $0x8,%esp
  800805:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800808:	50                   	push   %eax
  800809:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80080c:	ff 30                	pushl  (%eax)
  80080e:	e8 e8 fc ff ff       	call   8004fb <dev_lookup>
  800813:	83 c4 10             	add    $0x10,%esp
  800816:	85 c0                	test   %eax,%eax
  800818:	78 47                	js     800861 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80081a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80081d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800821:	75 21                	jne    800844 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800823:	a1 08 40 80 00       	mov    0x804008,%eax
  800828:	8b 40 48             	mov    0x48(%eax),%eax
  80082b:	83 ec 04             	sub    $0x4,%esp
  80082e:	53                   	push   %ebx
  80082f:	50                   	push   %eax
  800830:	68 b5 23 80 00       	push   $0x8023b5
  800835:	e8 48 0e 00 00       	call   801682 <cprintf>
		return -E_INVAL;
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800842:	eb 26                	jmp    80086a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800844:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800847:	8b 52 0c             	mov    0xc(%edx),%edx
  80084a:	85 d2                	test   %edx,%edx
  80084c:	74 17                	je     800865 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80084e:	83 ec 04             	sub    $0x4,%esp
  800851:	ff 75 10             	pushl  0x10(%ebp)
  800854:	ff 75 0c             	pushl  0xc(%ebp)
  800857:	50                   	push   %eax
  800858:	ff d2                	call   *%edx
  80085a:	89 c2                	mov    %eax,%edx
  80085c:	83 c4 10             	add    $0x10,%esp
  80085f:	eb 09                	jmp    80086a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800861:	89 c2                	mov    %eax,%edx
  800863:	eb 05                	jmp    80086a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800865:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80086a:	89 d0                	mov    %edx,%eax
  80086c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086f:	c9                   	leave  
  800870:	c3                   	ret    

00800871 <seek>:

int
seek(int fdnum, off_t offset)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800877:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80087a:	50                   	push   %eax
  80087b:	ff 75 08             	pushl  0x8(%ebp)
  80087e:	e8 22 fc ff ff       	call   8004a5 <fd_lookup>
  800883:	83 c4 08             	add    $0x8,%esp
  800886:	85 c0                	test   %eax,%eax
  800888:	78 0e                	js     800898 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80088a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80088d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800890:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800893:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800898:	c9                   	leave  
  800899:	c3                   	ret    

0080089a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	53                   	push   %ebx
  80089e:	83 ec 14             	sub    $0x14,%esp
  8008a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008a7:	50                   	push   %eax
  8008a8:	53                   	push   %ebx
  8008a9:	e8 f7 fb ff ff       	call   8004a5 <fd_lookup>
  8008ae:	83 c4 08             	add    $0x8,%esp
  8008b1:	89 c2                	mov    %eax,%edx
  8008b3:	85 c0                	test   %eax,%eax
  8008b5:	78 65                	js     80091c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b7:	83 ec 08             	sub    $0x8,%esp
  8008ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008bd:	50                   	push   %eax
  8008be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c1:	ff 30                	pushl  (%eax)
  8008c3:	e8 33 fc ff ff       	call   8004fb <dev_lookup>
  8008c8:	83 c4 10             	add    $0x10,%esp
  8008cb:	85 c0                	test   %eax,%eax
  8008cd:	78 44                	js     800913 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008d6:	75 21                	jne    8008f9 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008d8:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008dd:	8b 40 48             	mov    0x48(%eax),%eax
  8008e0:	83 ec 04             	sub    $0x4,%esp
  8008e3:	53                   	push   %ebx
  8008e4:	50                   	push   %eax
  8008e5:	68 78 23 80 00       	push   $0x802378
  8008ea:	e8 93 0d 00 00       	call   801682 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008ef:	83 c4 10             	add    $0x10,%esp
  8008f2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8008f7:	eb 23                	jmp    80091c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8008f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008fc:	8b 52 18             	mov    0x18(%edx),%edx
  8008ff:	85 d2                	test   %edx,%edx
  800901:	74 14                	je     800917 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800903:	83 ec 08             	sub    $0x8,%esp
  800906:	ff 75 0c             	pushl  0xc(%ebp)
  800909:	50                   	push   %eax
  80090a:	ff d2                	call   *%edx
  80090c:	89 c2                	mov    %eax,%edx
  80090e:	83 c4 10             	add    $0x10,%esp
  800911:	eb 09                	jmp    80091c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800913:	89 c2                	mov    %eax,%edx
  800915:	eb 05                	jmp    80091c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800917:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80091c:	89 d0                	mov    %edx,%eax
  80091e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800921:	c9                   	leave  
  800922:	c3                   	ret    

00800923 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	53                   	push   %ebx
  800927:	83 ec 14             	sub    $0x14,%esp
  80092a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80092d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800930:	50                   	push   %eax
  800931:	ff 75 08             	pushl  0x8(%ebp)
  800934:	e8 6c fb ff ff       	call   8004a5 <fd_lookup>
  800939:	83 c4 08             	add    $0x8,%esp
  80093c:	89 c2                	mov    %eax,%edx
  80093e:	85 c0                	test   %eax,%eax
  800940:	78 58                	js     80099a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800942:	83 ec 08             	sub    $0x8,%esp
  800945:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800948:	50                   	push   %eax
  800949:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80094c:	ff 30                	pushl  (%eax)
  80094e:	e8 a8 fb ff ff       	call   8004fb <dev_lookup>
  800953:	83 c4 10             	add    $0x10,%esp
  800956:	85 c0                	test   %eax,%eax
  800958:	78 37                	js     800991 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80095a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800961:	74 32                	je     800995 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800963:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800966:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80096d:	00 00 00 
	stat->st_isdir = 0;
  800970:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800977:	00 00 00 
	stat->st_dev = dev;
  80097a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800980:	83 ec 08             	sub    $0x8,%esp
  800983:	53                   	push   %ebx
  800984:	ff 75 f0             	pushl  -0x10(%ebp)
  800987:	ff 50 14             	call   *0x14(%eax)
  80098a:	89 c2                	mov    %eax,%edx
  80098c:	83 c4 10             	add    $0x10,%esp
  80098f:	eb 09                	jmp    80099a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800991:	89 c2                	mov    %eax,%edx
  800993:	eb 05                	jmp    80099a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800995:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80099a:	89 d0                	mov    %edx,%eax
  80099c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	56                   	push   %esi
  8009a5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009a6:	83 ec 08             	sub    $0x8,%esp
  8009a9:	6a 00                	push   $0x0
  8009ab:	ff 75 08             	pushl  0x8(%ebp)
  8009ae:	e8 0c 02 00 00       	call   800bbf <open>
  8009b3:	89 c3                	mov    %eax,%ebx
  8009b5:	83 c4 10             	add    $0x10,%esp
  8009b8:	85 c0                	test   %eax,%eax
  8009ba:	78 1b                	js     8009d7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8009bc:	83 ec 08             	sub    $0x8,%esp
  8009bf:	ff 75 0c             	pushl  0xc(%ebp)
  8009c2:	50                   	push   %eax
  8009c3:	e8 5b ff ff ff       	call   800923 <fstat>
  8009c8:	89 c6                	mov    %eax,%esi
	close(fd);
  8009ca:	89 1c 24             	mov    %ebx,(%esp)
  8009cd:	e8 fd fb ff ff       	call   8005cf <close>
	return r;
  8009d2:	83 c4 10             	add    $0x10,%esp
  8009d5:	89 f0                	mov    %esi,%eax
}
  8009d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009da:	5b                   	pop    %ebx
  8009db:	5e                   	pop    %esi
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	56                   	push   %esi
  8009e2:	53                   	push   %ebx
  8009e3:	89 c6                	mov    %eax,%esi
  8009e5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8009e7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009ee:	75 12                	jne    800a02 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009f0:	83 ec 0c             	sub    $0xc,%esp
  8009f3:	6a 01                	push   $0x1
  8009f5:	e8 11 16 00 00       	call   80200b <ipc_find_env>
  8009fa:	a3 00 40 80 00       	mov    %eax,0x804000
  8009ff:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a02:	6a 07                	push   $0x7
  800a04:	68 00 50 80 00       	push   $0x805000
  800a09:	56                   	push   %esi
  800a0a:	ff 35 00 40 80 00    	pushl  0x804000
  800a10:	e8 a2 15 00 00       	call   801fb7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a15:	83 c4 0c             	add    $0xc,%esp
  800a18:	6a 00                	push   $0x0
  800a1a:	53                   	push   %ebx
  800a1b:	6a 00                	push   $0x0
  800a1d:	e8 2c 15 00 00       	call   801f4e <ipc_recv>
}
  800a22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a25:	5b                   	pop    %ebx
  800a26:	5e                   	pop    %esi
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	8b 40 0c             	mov    0xc(%eax),%eax
  800a35:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a42:	ba 00 00 00 00       	mov    $0x0,%edx
  800a47:	b8 02 00 00 00       	mov    $0x2,%eax
  800a4c:	e8 8d ff ff ff       	call   8009de <fsipc>
}
  800a51:	c9                   	leave  
  800a52:	c3                   	ret    

00800a53 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a59:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5c:	8b 40 0c             	mov    0xc(%eax),%eax
  800a5f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a64:	ba 00 00 00 00       	mov    $0x0,%edx
  800a69:	b8 06 00 00 00       	mov    $0x6,%eax
  800a6e:	e8 6b ff ff ff       	call   8009de <fsipc>
}
  800a73:	c9                   	leave  
  800a74:	c3                   	ret    

00800a75 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	53                   	push   %ebx
  800a79:	83 ec 04             	sub    $0x4,%esp
  800a7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a82:	8b 40 0c             	mov    0xc(%eax),%eax
  800a85:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8f:	b8 05 00 00 00       	mov    $0x5,%eax
  800a94:	e8 45 ff ff ff       	call   8009de <fsipc>
  800a99:	85 c0                	test   %eax,%eax
  800a9b:	78 2c                	js     800ac9 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a9d:	83 ec 08             	sub    $0x8,%esp
  800aa0:	68 00 50 80 00       	push   $0x805000
  800aa5:	53                   	push   %ebx
  800aa6:	e8 5c 11 00 00       	call   801c07 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800aab:	a1 80 50 80 00       	mov    0x805080,%eax
  800ab0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ab6:	a1 84 50 80 00       	mov    0x805084,%eax
  800abb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ac1:	83 c4 10             	add    $0x10,%esp
  800ac4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800acc:	c9                   	leave  
  800acd:	c3                   	ret    

00800ace <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	53                   	push   %ebx
  800ad2:	83 ec 08             	sub    $0x8,%esp
  800ad5:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800ad8:	8b 55 08             	mov    0x8(%ebp),%edx
  800adb:	8b 52 0c             	mov    0xc(%edx),%edx
  800ade:	89 15 00 50 80 00    	mov    %edx,0x805000
  800ae4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800ae9:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800aee:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  800af1:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  800af7:	53                   	push   %ebx
  800af8:	ff 75 0c             	pushl  0xc(%ebp)
  800afb:	68 08 50 80 00       	push   $0x805008
  800b00:	e8 94 12 00 00       	call   801d99 <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  800b05:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b0f:	e8 ca fe ff ff       	call   8009de <fsipc>
  800b14:	83 c4 10             	add    $0x10,%esp
  800b17:	85 c0                	test   %eax,%eax
  800b19:	78 1d                	js     800b38 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  800b1b:	39 d8                	cmp    %ebx,%eax
  800b1d:	76 19                	jbe    800b38 <devfile_write+0x6a>
  800b1f:	68 e8 23 80 00       	push   $0x8023e8
  800b24:	68 f4 23 80 00       	push   $0x8023f4
  800b29:	68 a5 00 00 00       	push   $0xa5
  800b2e:	68 09 24 80 00       	push   $0x802409
  800b33:	e8 71 0a 00 00       	call   8015a9 <_panic>
	return r;
}
  800b38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b3b:	c9                   	leave  
  800b3c:	c3                   	ret    

00800b3d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b45:	8b 45 08             	mov    0x8(%ebp),%eax
  800b48:	8b 40 0c             	mov    0xc(%eax),%eax
  800b4b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b50:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b56:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b60:	e8 79 fe ff ff       	call   8009de <fsipc>
  800b65:	89 c3                	mov    %eax,%ebx
  800b67:	85 c0                	test   %eax,%eax
  800b69:	78 4b                	js     800bb6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800b6b:	39 c6                	cmp    %eax,%esi
  800b6d:	73 16                	jae    800b85 <devfile_read+0x48>
  800b6f:	68 14 24 80 00       	push   $0x802414
  800b74:	68 f4 23 80 00       	push   $0x8023f4
  800b79:	6a 7c                	push   $0x7c
  800b7b:	68 09 24 80 00       	push   $0x802409
  800b80:	e8 24 0a 00 00       	call   8015a9 <_panic>
	assert(r <= PGSIZE);
  800b85:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b8a:	7e 16                	jle    800ba2 <devfile_read+0x65>
  800b8c:	68 1b 24 80 00       	push   $0x80241b
  800b91:	68 f4 23 80 00       	push   $0x8023f4
  800b96:	6a 7d                	push   $0x7d
  800b98:	68 09 24 80 00       	push   $0x802409
  800b9d:	e8 07 0a 00 00       	call   8015a9 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ba2:	83 ec 04             	sub    $0x4,%esp
  800ba5:	50                   	push   %eax
  800ba6:	68 00 50 80 00       	push   $0x805000
  800bab:	ff 75 0c             	pushl  0xc(%ebp)
  800bae:	e8 e6 11 00 00       	call   801d99 <memmove>
	return r;
  800bb3:	83 c4 10             	add    $0x10,%esp
}
  800bb6:	89 d8                	mov    %ebx,%eax
  800bb8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 20             	sub    $0x20,%esp
  800bc6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800bc9:	53                   	push   %ebx
  800bca:	e8 ff 0f 00 00       	call   801bce <strlen>
  800bcf:	83 c4 10             	add    $0x10,%esp
  800bd2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800bd7:	7f 67                	jg     800c40 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800bd9:	83 ec 0c             	sub    $0xc,%esp
  800bdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bdf:	50                   	push   %eax
  800be0:	e8 71 f8 ff ff       	call   800456 <fd_alloc>
  800be5:	83 c4 10             	add    $0x10,%esp
		return r;
  800be8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800bea:	85 c0                	test   %eax,%eax
  800bec:	78 57                	js     800c45 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800bee:	83 ec 08             	sub    $0x8,%esp
  800bf1:	53                   	push   %ebx
  800bf2:	68 00 50 80 00       	push   $0x805000
  800bf7:	e8 0b 10 00 00       	call   801c07 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800bfc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bff:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800c04:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c07:	b8 01 00 00 00       	mov    $0x1,%eax
  800c0c:	e8 cd fd ff ff       	call   8009de <fsipc>
  800c11:	89 c3                	mov    %eax,%ebx
  800c13:	83 c4 10             	add    $0x10,%esp
  800c16:	85 c0                	test   %eax,%eax
  800c18:	79 14                	jns    800c2e <open+0x6f>
		fd_close(fd, 0);
  800c1a:	83 ec 08             	sub    $0x8,%esp
  800c1d:	6a 00                	push   $0x0
  800c1f:	ff 75 f4             	pushl  -0xc(%ebp)
  800c22:	e8 27 f9 ff ff       	call   80054e <fd_close>
		return r;
  800c27:	83 c4 10             	add    $0x10,%esp
  800c2a:	89 da                	mov    %ebx,%edx
  800c2c:	eb 17                	jmp    800c45 <open+0x86>
	}

	return fd2num(fd);
  800c2e:	83 ec 0c             	sub    $0xc,%esp
  800c31:	ff 75 f4             	pushl  -0xc(%ebp)
  800c34:	e8 f6 f7 ff ff       	call   80042f <fd2num>
  800c39:	89 c2                	mov    %eax,%edx
  800c3b:	83 c4 10             	add    $0x10,%esp
  800c3e:	eb 05                	jmp    800c45 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800c40:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800c45:	89 d0                	mov    %edx,%eax
  800c47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c4a:	c9                   	leave  
  800c4b:	c3                   	ret    

00800c4c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c52:	ba 00 00 00 00       	mov    $0x0,%edx
  800c57:	b8 08 00 00 00       	mov    $0x8,%eax
  800c5c:	e8 7d fd ff ff       	call   8009de <fsipc>
}
  800c61:	c9                   	leave  
  800c62:	c3                   	ret    

00800c63 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800c69:	68 27 24 80 00       	push   $0x802427
  800c6e:	ff 75 0c             	pushl  0xc(%ebp)
  800c71:	e8 91 0f 00 00       	call   801c07 <strcpy>
	return 0;
}
  800c76:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7b:	c9                   	leave  
  800c7c:	c3                   	ret    

00800c7d <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	53                   	push   %ebx
  800c81:	83 ec 10             	sub    $0x10,%esp
  800c84:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c87:	53                   	push   %ebx
  800c88:	e8 b7 13 00 00       	call   802044 <pageref>
  800c8d:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c90:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c95:	83 f8 01             	cmp    $0x1,%eax
  800c98:	75 10                	jne    800caa <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c9a:	83 ec 0c             	sub    $0xc,%esp
  800c9d:	ff 73 0c             	pushl  0xc(%ebx)
  800ca0:	e8 c0 02 00 00       	call   800f65 <nsipc_close>
  800ca5:	89 c2                	mov    %eax,%edx
  800ca7:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800caa:	89 d0                	mov    %edx,%eax
  800cac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800caf:	c9                   	leave  
  800cb0:	c3                   	ret    

00800cb1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800cb7:	6a 00                	push   $0x0
  800cb9:	ff 75 10             	pushl  0x10(%ebp)
  800cbc:	ff 75 0c             	pushl  0xc(%ebp)
  800cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc2:	ff 70 0c             	pushl  0xc(%eax)
  800cc5:	e8 78 03 00 00       	call   801042 <nsipc_send>
}
  800cca:	c9                   	leave  
  800ccb:	c3                   	ret    

00800ccc <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800cd2:	6a 00                	push   $0x0
  800cd4:	ff 75 10             	pushl  0x10(%ebp)
  800cd7:	ff 75 0c             	pushl  0xc(%ebp)
  800cda:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdd:	ff 70 0c             	pushl  0xc(%eax)
  800ce0:	e8 f1 02 00 00       	call   800fd6 <nsipc_recv>
}
  800ce5:	c9                   	leave  
  800ce6:	c3                   	ret    

00800ce7 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800ced:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800cf0:	52                   	push   %edx
  800cf1:	50                   	push   %eax
  800cf2:	e8 ae f7 ff ff       	call   8004a5 <fd_lookup>
  800cf7:	83 c4 10             	add    $0x10,%esp
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	78 17                	js     800d15 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800cfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d01:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800d07:	39 08                	cmp    %ecx,(%eax)
  800d09:	75 05                	jne    800d10 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800d0b:	8b 40 0c             	mov    0xc(%eax),%eax
  800d0e:	eb 05                	jmp    800d15 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800d10:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800d15:	c9                   	leave  
  800d16:	c3                   	ret    

00800d17 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	56                   	push   %esi
  800d1b:	53                   	push   %ebx
  800d1c:	83 ec 1c             	sub    $0x1c,%esp
  800d1f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800d21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d24:	50                   	push   %eax
  800d25:	e8 2c f7 ff ff       	call   800456 <fd_alloc>
  800d2a:	89 c3                	mov    %eax,%ebx
  800d2c:	83 c4 10             	add    $0x10,%esp
  800d2f:	85 c0                	test   %eax,%eax
  800d31:	78 1b                	js     800d4e <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800d33:	83 ec 04             	sub    $0x4,%esp
  800d36:	68 07 04 00 00       	push   $0x407
  800d3b:	ff 75 f4             	pushl  -0xc(%ebp)
  800d3e:	6a 00                	push   $0x0
  800d40:	e8 15 f4 ff ff       	call   80015a <sys_page_alloc>
  800d45:	89 c3                	mov    %eax,%ebx
  800d47:	83 c4 10             	add    $0x10,%esp
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	79 10                	jns    800d5e <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800d4e:	83 ec 0c             	sub    $0xc,%esp
  800d51:	56                   	push   %esi
  800d52:	e8 0e 02 00 00       	call   800f65 <nsipc_close>
		return r;
  800d57:	83 c4 10             	add    $0x10,%esp
  800d5a:	89 d8                	mov    %ebx,%eax
  800d5c:	eb 24                	jmp    800d82 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800d5e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d67:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800d69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d6c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800d73:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800d76:	83 ec 0c             	sub    $0xc,%esp
  800d79:	50                   	push   %eax
  800d7a:	e8 b0 f6 ff ff       	call   80042f <fd2num>
  800d7f:	83 c4 10             	add    $0x10,%esp
}
  800d82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d92:	e8 50 ff ff ff       	call   800ce7 <fd2sockid>
		return r;
  800d97:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d99:	85 c0                	test   %eax,%eax
  800d9b:	78 1f                	js     800dbc <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d9d:	83 ec 04             	sub    $0x4,%esp
  800da0:	ff 75 10             	pushl  0x10(%ebp)
  800da3:	ff 75 0c             	pushl  0xc(%ebp)
  800da6:	50                   	push   %eax
  800da7:	e8 12 01 00 00       	call   800ebe <nsipc_accept>
  800dac:	83 c4 10             	add    $0x10,%esp
		return r;
  800daf:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800db1:	85 c0                	test   %eax,%eax
  800db3:	78 07                	js     800dbc <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800db5:	e8 5d ff ff ff       	call   800d17 <alloc_sockfd>
  800dba:	89 c1                	mov    %eax,%ecx
}
  800dbc:	89 c8                	mov    %ecx,%eax
  800dbe:	c9                   	leave  
  800dbf:	c3                   	ret    

00800dc0 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc9:	e8 19 ff ff ff       	call   800ce7 <fd2sockid>
  800dce:	85 c0                	test   %eax,%eax
  800dd0:	78 12                	js     800de4 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800dd2:	83 ec 04             	sub    $0x4,%esp
  800dd5:	ff 75 10             	pushl  0x10(%ebp)
  800dd8:	ff 75 0c             	pushl  0xc(%ebp)
  800ddb:	50                   	push   %eax
  800ddc:	e8 2d 01 00 00       	call   800f0e <nsipc_bind>
  800de1:	83 c4 10             	add    $0x10,%esp
}
  800de4:	c9                   	leave  
  800de5:	c3                   	ret    

00800de6 <shutdown>:

int
shutdown(int s, int how)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800dec:	8b 45 08             	mov    0x8(%ebp),%eax
  800def:	e8 f3 fe ff ff       	call   800ce7 <fd2sockid>
  800df4:	85 c0                	test   %eax,%eax
  800df6:	78 0f                	js     800e07 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800df8:	83 ec 08             	sub    $0x8,%esp
  800dfb:	ff 75 0c             	pushl  0xc(%ebp)
  800dfe:	50                   	push   %eax
  800dff:	e8 3f 01 00 00       	call   800f43 <nsipc_shutdown>
  800e04:	83 c4 10             	add    $0x10,%esp
}
  800e07:	c9                   	leave  
  800e08:	c3                   	ret    

00800e09 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e12:	e8 d0 fe ff ff       	call   800ce7 <fd2sockid>
  800e17:	85 c0                	test   %eax,%eax
  800e19:	78 12                	js     800e2d <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800e1b:	83 ec 04             	sub    $0x4,%esp
  800e1e:	ff 75 10             	pushl  0x10(%ebp)
  800e21:	ff 75 0c             	pushl  0xc(%ebp)
  800e24:	50                   	push   %eax
  800e25:	e8 55 01 00 00       	call   800f7f <nsipc_connect>
  800e2a:	83 c4 10             	add    $0x10,%esp
}
  800e2d:	c9                   	leave  
  800e2e:	c3                   	ret    

00800e2f <listen>:

int
listen(int s, int backlog)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e35:	8b 45 08             	mov    0x8(%ebp),%eax
  800e38:	e8 aa fe ff ff       	call   800ce7 <fd2sockid>
  800e3d:	85 c0                	test   %eax,%eax
  800e3f:	78 0f                	js     800e50 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800e41:	83 ec 08             	sub    $0x8,%esp
  800e44:	ff 75 0c             	pushl  0xc(%ebp)
  800e47:	50                   	push   %eax
  800e48:	e8 67 01 00 00       	call   800fb4 <nsipc_listen>
  800e4d:	83 c4 10             	add    $0x10,%esp
}
  800e50:	c9                   	leave  
  800e51:	c3                   	ret    

00800e52 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800e58:	ff 75 10             	pushl  0x10(%ebp)
  800e5b:	ff 75 0c             	pushl  0xc(%ebp)
  800e5e:	ff 75 08             	pushl  0x8(%ebp)
  800e61:	e8 3a 02 00 00       	call   8010a0 <nsipc_socket>
  800e66:	83 c4 10             	add    $0x10,%esp
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	78 05                	js     800e72 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800e6d:	e8 a5 fe ff ff       	call   800d17 <alloc_sockfd>
}
  800e72:	c9                   	leave  
  800e73:	c3                   	ret    

00800e74 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	53                   	push   %ebx
  800e78:	83 ec 04             	sub    $0x4,%esp
  800e7b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800e7d:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e84:	75 12                	jne    800e98 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e86:	83 ec 0c             	sub    $0xc,%esp
  800e89:	6a 02                	push   $0x2
  800e8b:	e8 7b 11 00 00       	call   80200b <ipc_find_env>
  800e90:	a3 04 40 80 00       	mov    %eax,0x804004
  800e95:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e98:	6a 07                	push   $0x7
  800e9a:	68 00 60 80 00       	push   $0x806000
  800e9f:	53                   	push   %ebx
  800ea0:	ff 35 04 40 80 00    	pushl  0x804004
  800ea6:	e8 0c 11 00 00       	call   801fb7 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800eab:	83 c4 0c             	add    $0xc,%esp
  800eae:	6a 00                	push   $0x0
  800eb0:	6a 00                	push   $0x0
  800eb2:	6a 00                	push   $0x0
  800eb4:	e8 95 10 00 00       	call   801f4e <ipc_recv>
}
  800eb9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ebc:	c9                   	leave  
  800ebd:	c3                   	ret    

00800ebe <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	56                   	push   %esi
  800ec2:	53                   	push   %ebx
  800ec3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800ec6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800ece:	8b 06                	mov    (%esi),%eax
  800ed0:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800ed5:	b8 01 00 00 00       	mov    $0x1,%eax
  800eda:	e8 95 ff ff ff       	call   800e74 <nsipc>
  800edf:	89 c3                	mov    %eax,%ebx
  800ee1:	85 c0                	test   %eax,%eax
  800ee3:	78 20                	js     800f05 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800ee5:	83 ec 04             	sub    $0x4,%esp
  800ee8:	ff 35 10 60 80 00    	pushl  0x806010
  800eee:	68 00 60 80 00       	push   $0x806000
  800ef3:	ff 75 0c             	pushl  0xc(%ebp)
  800ef6:	e8 9e 0e 00 00       	call   801d99 <memmove>
		*addrlen = ret->ret_addrlen;
  800efb:	a1 10 60 80 00       	mov    0x806010,%eax
  800f00:	89 06                	mov    %eax,(%esi)
  800f02:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800f05:	89 d8                	mov    %ebx,%eax
  800f07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f0a:	5b                   	pop    %ebx
  800f0b:	5e                   	pop    %esi
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    

00800f0e <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	53                   	push   %ebx
  800f12:	83 ec 08             	sub    $0x8,%esp
  800f15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800f18:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800f20:	53                   	push   %ebx
  800f21:	ff 75 0c             	pushl  0xc(%ebp)
  800f24:	68 04 60 80 00       	push   $0x806004
  800f29:	e8 6b 0e 00 00       	call   801d99 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800f2e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800f34:	b8 02 00 00 00       	mov    $0x2,%eax
  800f39:	e8 36 ff ff ff       	call   800e74 <nsipc>
}
  800f3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f41:	c9                   	leave  
  800f42:	c3                   	ret    

00800f43 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800f49:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800f51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f54:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800f59:	b8 03 00 00 00       	mov    $0x3,%eax
  800f5e:	e8 11 ff ff ff       	call   800e74 <nsipc>
}
  800f63:	c9                   	leave  
  800f64:	c3                   	ret    

00800f65 <nsipc_close>:

int
nsipc_close(int s)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800f6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800f73:	b8 04 00 00 00       	mov    $0x4,%eax
  800f78:	e8 f7 fe ff ff       	call   800e74 <nsipc>
}
  800f7d:	c9                   	leave  
  800f7e:	c3                   	ret    

00800f7f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	53                   	push   %ebx
  800f83:	83 ec 08             	sub    $0x8,%esp
  800f86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f89:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f91:	53                   	push   %ebx
  800f92:	ff 75 0c             	pushl  0xc(%ebp)
  800f95:	68 04 60 80 00       	push   $0x806004
  800f9a:	e8 fa 0d 00 00       	call   801d99 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f9f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800fa5:	b8 05 00 00 00       	mov    $0x5,%eax
  800faa:	e8 c5 fe ff ff       	call   800e74 <nsipc>
}
  800faf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb2:	c9                   	leave  
  800fb3:	c3                   	ret    

00800fb4 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800fba:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800fc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc5:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800fca:	b8 06 00 00 00       	mov    $0x6,%eax
  800fcf:	e8 a0 fe ff ff       	call   800e74 <nsipc>
}
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	56                   	push   %esi
  800fda:	53                   	push   %ebx
  800fdb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800fde:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800fe6:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800fec:	8b 45 14             	mov    0x14(%ebp),%eax
  800fef:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800ff4:	b8 07 00 00 00       	mov    $0x7,%eax
  800ff9:	e8 76 fe ff ff       	call   800e74 <nsipc>
  800ffe:	89 c3                	mov    %eax,%ebx
  801000:	85 c0                	test   %eax,%eax
  801002:	78 35                	js     801039 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801004:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801009:	7f 04                	jg     80100f <nsipc_recv+0x39>
  80100b:	39 c6                	cmp    %eax,%esi
  80100d:	7d 16                	jge    801025 <nsipc_recv+0x4f>
  80100f:	68 33 24 80 00       	push   $0x802433
  801014:	68 f4 23 80 00       	push   $0x8023f4
  801019:	6a 62                	push   $0x62
  80101b:	68 48 24 80 00       	push   $0x802448
  801020:	e8 84 05 00 00       	call   8015a9 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801025:	83 ec 04             	sub    $0x4,%esp
  801028:	50                   	push   %eax
  801029:	68 00 60 80 00       	push   $0x806000
  80102e:	ff 75 0c             	pushl  0xc(%ebp)
  801031:	e8 63 0d 00 00       	call   801d99 <memmove>
  801036:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801039:	89 d8                	mov    %ebx,%eax
  80103b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80103e:	5b                   	pop    %ebx
  80103f:	5e                   	pop    %esi
  801040:	5d                   	pop    %ebp
  801041:	c3                   	ret    

00801042 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	53                   	push   %ebx
  801046:	83 ec 04             	sub    $0x4,%esp
  801049:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80104c:	8b 45 08             	mov    0x8(%ebp),%eax
  80104f:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801054:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80105a:	7e 16                	jle    801072 <nsipc_send+0x30>
  80105c:	68 54 24 80 00       	push   $0x802454
  801061:	68 f4 23 80 00       	push   $0x8023f4
  801066:	6a 6d                	push   $0x6d
  801068:	68 48 24 80 00       	push   $0x802448
  80106d:	e8 37 05 00 00       	call   8015a9 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801072:	83 ec 04             	sub    $0x4,%esp
  801075:	53                   	push   %ebx
  801076:	ff 75 0c             	pushl  0xc(%ebp)
  801079:	68 0c 60 80 00       	push   $0x80600c
  80107e:	e8 16 0d 00 00       	call   801d99 <memmove>
	nsipcbuf.send.req_size = size;
  801083:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801089:	8b 45 14             	mov    0x14(%ebp),%eax
  80108c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801091:	b8 08 00 00 00       	mov    $0x8,%eax
  801096:	e8 d9 fd ff ff       	call   800e74 <nsipc>
}
  80109b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80109e:	c9                   	leave  
  80109f:	c3                   	ret    

008010a0 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8010a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8010ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b1:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8010b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8010b9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8010be:	b8 09 00 00 00       	mov    $0x9,%eax
  8010c3:	e8 ac fd ff ff       	call   800e74 <nsipc>
}
  8010c8:	c9                   	leave  
  8010c9:	c3                   	ret    

008010ca <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	56                   	push   %esi
  8010ce:	53                   	push   %ebx
  8010cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8010d2:	83 ec 0c             	sub    $0xc,%esp
  8010d5:	ff 75 08             	pushl  0x8(%ebp)
  8010d8:	e8 62 f3 ff ff       	call   80043f <fd2data>
  8010dd:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8010df:	83 c4 08             	add    $0x8,%esp
  8010e2:	68 60 24 80 00       	push   $0x802460
  8010e7:	53                   	push   %ebx
  8010e8:	e8 1a 0b 00 00       	call   801c07 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8010ed:	8b 46 04             	mov    0x4(%esi),%eax
  8010f0:	2b 06                	sub    (%esi),%eax
  8010f2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8010f8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8010ff:	00 00 00 
	stat->st_dev = &devpipe;
  801102:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801109:	30 80 00 
	return 0;
}
  80110c:	b8 00 00 00 00       	mov    $0x0,%eax
  801111:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801114:	5b                   	pop    %ebx
  801115:	5e                   	pop    %esi
  801116:	5d                   	pop    %ebp
  801117:	c3                   	ret    

00801118 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	53                   	push   %ebx
  80111c:	83 ec 0c             	sub    $0xc,%esp
  80111f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801122:	53                   	push   %ebx
  801123:	6a 00                	push   $0x0
  801125:	e8 b5 f0 ff ff       	call   8001df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80112a:	89 1c 24             	mov    %ebx,(%esp)
  80112d:	e8 0d f3 ff ff       	call   80043f <fd2data>
  801132:	83 c4 08             	add    $0x8,%esp
  801135:	50                   	push   %eax
  801136:	6a 00                	push   $0x0
  801138:	e8 a2 f0 ff ff       	call   8001df <sys_page_unmap>
}
  80113d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801140:	c9                   	leave  
  801141:	c3                   	ret    

00801142 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	57                   	push   %edi
  801146:	56                   	push   %esi
  801147:	53                   	push   %ebx
  801148:	83 ec 1c             	sub    $0x1c,%esp
  80114b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80114e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801150:	a1 08 40 80 00       	mov    0x804008,%eax
  801155:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801158:	83 ec 0c             	sub    $0xc,%esp
  80115b:	ff 75 e0             	pushl  -0x20(%ebp)
  80115e:	e8 e1 0e 00 00       	call   802044 <pageref>
  801163:	89 c3                	mov    %eax,%ebx
  801165:	89 3c 24             	mov    %edi,(%esp)
  801168:	e8 d7 0e 00 00       	call   802044 <pageref>
  80116d:	83 c4 10             	add    $0x10,%esp
  801170:	39 c3                	cmp    %eax,%ebx
  801172:	0f 94 c1             	sete   %cl
  801175:	0f b6 c9             	movzbl %cl,%ecx
  801178:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80117b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801181:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801184:	39 ce                	cmp    %ecx,%esi
  801186:	74 1b                	je     8011a3 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801188:	39 c3                	cmp    %eax,%ebx
  80118a:	75 c4                	jne    801150 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80118c:	8b 42 58             	mov    0x58(%edx),%eax
  80118f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801192:	50                   	push   %eax
  801193:	56                   	push   %esi
  801194:	68 67 24 80 00       	push   $0x802467
  801199:	e8 e4 04 00 00       	call   801682 <cprintf>
  80119e:	83 c4 10             	add    $0x10,%esp
  8011a1:	eb ad                	jmp    801150 <_pipeisclosed+0xe>
	}
}
  8011a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a9:	5b                   	pop    %ebx
  8011aa:	5e                   	pop    %esi
  8011ab:	5f                   	pop    %edi
  8011ac:	5d                   	pop    %ebp
  8011ad:	c3                   	ret    

008011ae <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
  8011b1:	57                   	push   %edi
  8011b2:	56                   	push   %esi
  8011b3:	53                   	push   %ebx
  8011b4:	83 ec 28             	sub    $0x28,%esp
  8011b7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8011ba:	56                   	push   %esi
  8011bb:	e8 7f f2 ff ff       	call   80043f <fd2data>
  8011c0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011c2:	83 c4 10             	add    $0x10,%esp
  8011c5:	bf 00 00 00 00       	mov    $0x0,%edi
  8011ca:	eb 4b                	jmp    801217 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8011cc:	89 da                	mov    %ebx,%edx
  8011ce:	89 f0                	mov    %esi,%eax
  8011d0:	e8 6d ff ff ff       	call   801142 <_pipeisclosed>
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	75 48                	jne    801221 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8011d9:	e8 5d ef ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8011de:	8b 43 04             	mov    0x4(%ebx),%eax
  8011e1:	8b 0b                	mov    (%ebx),%ecx
  8011e3:	8d 51 20             	lea    0x20(%ecx),%edx
  8011e6:	39 d0                	cmp    %edx,%eax
  8011e8:	73 e2                	jae    8011cc <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8011ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ed:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8011f1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8011f4:	89 c2                	mov    %eax,%edx
  8011f6:	c1 fa 1f             	sar    $0x1f,%edx
  8011f9:	89 d1                	mov    %edx,%ecx
  8011fb:	c1 e9 1b             	shr    $0x1b,%ecx
  8011fe:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801201:	83 e2 1f             	and    $0x1f,%edx
  801204:	29 ca                	sub    %ecx,%edx
  801206:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80120a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80120e:	83 c0 01             	add    $0x1,%eax
  801211:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801214:	83 c7 01             	add    $0x1,%edi
  801217:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80121a:	75 c2                	jne    8011de <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80121c:	8b 45 10             	mov    0x10(%ebp),%eax
  80121f:	eb 05                	jmp    801226 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801221:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801226:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801229:	5b                   	pop    %ebx
  80122a:	5e                   	pop    %esi
  80122b:	5f                   	pop    %edi
  80122c:	5d                   	pop    %ebp
  80122d:	c3                   	ret    

0080122e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	57                   	push   %edi
  801232:	56                   	push   %esi
  801233:	53                   	push   %ebx
  801234:	83 ec 18             	sub    $0x18,%esp
  801237:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80123a:	57                   	push   %edi
  80123b:	e8 ff f1 ff ff       	call   80043f <fd2data>
  801240:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801242:	83 c4 10             	add    $0x10,%esp
  801245:	bb 00 00 00 00       	mov    $0x0,%ebx
  80124a:	eb 3d                	jmp    801289 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80124c:	85 db                	test   %ebx,%ebx
  80124e:	74 04                	je     801254 <devpipe_read+0x26>
				return i;
  801250:	89 d8                	mov    %ebx,%eax
  801252:	eb 44                	jmp    801298 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801254:	89 f2                	mov    %esi,%edx
  801256:	89 f8                	mov    %edi,%eax
  801258:	e8 e5 fe ff ff       	call   801142 <_pipeisclosed>
  80125d:	85 c0                	test   %eax,%eax
  80125f:	75 32                	jne    801293 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801261:	e8 d5 ee ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801266:	8b 06                	mov    (%esi),%eax
  801268:	3b 46 04             	cmp    0x4(%esi),%eax
  80126b:	74 df                	je     80124c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80126d:	99                   	cltd   
  80126e:	c1 ea 1b             	shr    $0x1b,%edx
  801271:	01 d0                	add    %edx,%eax
  801273:	83 e0 1f             	and    $0x1f,%eax
  801276:	29 d0                	sub    %edx,%eax
  801278:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80127d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801280:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801283:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801286:	83 c3 01             	add    $0x1,%ebx
  801289:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80128c:	75 d8                	jne    801266 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80128e:	8b 45 10             	mov    0x10(%ebp),%eax
  801291:	eb 05                	jmp    801298 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801293:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801298:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80129b:	5b                   	pop    %ebx
  80129c:	5e                   	pop    %esi
  80129d:	5f                   	pop    %edi
  80129e:	5d                   	pop    %ebp
  80129f:	c3                   	ret    

008012a0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	56                   	push   %esi
  8012a4:	53                   	push   %ebx
  8012a5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8012a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ab:	50                   	push   %eax
  8012ac:	e8 a5 f1 ff ff       	call   800456 <fd_alloc>
  8012b1:	83 c4 10             	add    $0x10,%esp
  8012b4:	89 c2                	mov    %eax,%edx
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	0f 88 2c 01 00 00    	js     8013ea <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012be:	83 ec 04             	sub    $0x4,%esp
  8012c1:	68 07 04 00 00       	push   $0x407
  8012c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8012c9:	6a 00                	push   $0x0
  8012cb:	e8 8a ee ff ff       	call   80015a <sys_page_alloc>
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	89 c2                	mov    %eax,%edx
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	0f 88 0d 01 00 00    	js     8013ea <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8012dd:	83 ec 0c             	sub    $0xc,%esp
  8012e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e3:	50                   	push   %eax
  8012e4:	e8 6d f1 ff ff       	call   800456 <fd_alloc>
  8012e9:	89 c3                	mov    %eax,%ebx
  8012eb:	83 c4 10             	add    $0x10,%esp
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	0f 88 e2 00 00 00    	js     8013d8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012f6:	83 ec 04             	sub    $0x4,%esp
  8012f9:	68 07 04 00 00       	push   $0x407
  8012fe:	ff 75 f0             	pushl  -0x10(%ebp)
  801301:	6a 00                	push   $0x0
  801303:	e8 52 ee ff ff       	call   80015a <sys_page_alloc>
  801308:	89 c3                	mov    %eax,%ebx
  80130a:	83 c4 10             	add    $0x10,%esp
  80130d:	85 c0                	test   %eax,%eax
  80130f:	0f 88 c3 00 00 00    	js     8013d8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801315:	83 ec 0c             	sub    $0xc,%esp
  801318:	ff 75 f4             	pushl  -0xc(%ebp)
  80131b:	e8 1f f1 ff ff       	call   80043f <fd2data>
  801320:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801322:	83 c4 0c             	add    $0xc,%esp
  801325:	68 07 04 00 00       	push   $0x407
  80132a:	50                   	push   %eax
  80132b:	6a 00                	push   $0x0
  80132d:	e8 28 ee ff ff       	call   80015a <sys_page_alloc>
  801332:	89 c3                	mov    %eax,%ebx
  801334:	83 c4 10             	add    $0x10,%esp
  801337:	85 c0                	test   %eax,%eax
  801339:	0f 88 89 00 00 00    	js     8013c8 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80133f:	83 ec 0c             	sub    $0xc,%esp
  801342:	ff 75 f0             	pushl  -0x10(%ebp)
  801345:	e8 f5 f0 ff ff       	call   80043f <fd2data>
  80134a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801351:	50                   	push   %eax
  801352:	6a 00                	push   $0x0
  801354:	56                   	push   %esi
  801355:	6a 00                	push   $0x0
  801357:	e8 41 ee ff ff       	call   80019d <sys_page_map>
  80135c:	89 c3                	mov    %eax,%ebx
  80135e:	83 c4 20             	add    $0x20,%esp
  801361:	85 c0                	test   %eax,%eax
  801363:	78 55                	js     8013ba <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801365:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80136b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801370:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801373:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80137a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801380:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801383:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801385:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801388:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80138f:	83 ec 0c             	sub    $0xc,%esp
  801392:	ff 75 f4             	pushl  -0xc(%ebp)
  801395:	e8 95 f0 ff ff       	call   80042f <fd2num>
  80139a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80139d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80139f:	83 c4 04             	add    $0x4,%esp
  8013a2:	ff 75 f0             	pushl  -0x10(%ebp)
  8013a5:	e8 85 f0 ff ff       	call   80042f <fd2num>
  8013aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ad:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b8:	eb 30                	jmp    8013ea <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8013ba:	83 ec 08             	sub    $0x8,%esp
  8013bd:	56                   	push   %esi
  8013be:	6a 00                	push   $0x0
  8013c0:	e8 1a ee ff ff       	call   8001df <sys_page_unmap>
  8013c5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8013c8:	83 ec 08             	sub    $0x8,%esp
  8013cb:	ff 75 f0             	pushl  -0x10(%ebp)
  8013ce:	6a 00                	push   $0x0
  8013d0:	e8 0a ee ff ff       	call   8001df <sys_page_unmap>
  8013d5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8013d8:	83 ec 08             	sub    $0x8,%esp
  8013db:	ff 75 f4             	pushl  -0xc(%ebp)
  8013de:	6a 00                	push   $0x0
  8013e0:	e8 fa ed ff ff       	call   8001df <sys_page_unmap>
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8013ea:	89 d0                	mov    %edx,%eax
  8013ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ef:	5b                   	pop    %ebx
  8013f0:	5e                   	pop    %esi
  8013f1:	5d                   	pop    %ebp
  8013f2:	c3                   	ret    

008013f3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8013f3:	55                   	push   %ebp
  8013f4:	89 e5                	mov    %esp,%ebp
  8013f6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fc:	50                   	push   %eax
  8013fd:	ff 75 08             	pushl  0x8(%ebp)
  801400:	e8 a0 f0 ff ff       	call   8004a5 <fd_lookup>
  801405:	83 c4 10             	add    $0x10,%esp
  801408:	85 c0                	test   %eax,%eax
  80140a:	78 18                	js     801424 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80140c:	83 ec 0c             	sub    $0xc,%esp
  80140f:	ff 75 f4             	pushl  -0xc(%ebp)
  801412:	e8 28 f0 ff ff       	call   80043f <fd2data>
	return _pipeisclosed(fd, p);
  801417:	89 c2                	mov    %eax,%edx
  801419:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80141c:	e8 21 fd ff ff       	call   801142 <_pipeisclosed>
  801421:	83 c4 10             	add    $0x10,%esp
}
  801424:	c9                   	leave  
  801425:	c3                   	ret    

00801426 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801429:	b8 00 00 00 00       	mov    $0x0,%eax
  80142e:	5d                   	pop    %ebp
  80142f:	c3                   	ret    

00801430 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801436:	68 7f 24 80 00       	push   $0x80247f
  80143b:	ff 75 0c             	pushl  0xc(%ebp)
  80143e:	e8 c4 07 00 00       	call   801c07 <strcpy>
	return 0;
}
  801443:	b8 00 00 00 00       	mov    $0x0,%eax
  801448:	c9                   	leave  
  801449:	c3                   	ret    

0080144a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80144a:	55                   	push   %ebp
  80144b:	89 e5                	mov    %esp,%ebp
  80144d:	57                   	push   %edi
  80144e:	56                   	push   %esi
  80144f:	53                   	push   %ebx
  801450:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801456:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80145b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801461:	eb 2d                	jmp    801490 <devcons_write+0x46>
		m = n - tot;
  801463:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801466:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801468:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80146b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801470:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801473:	83 ec 04             	sub    $0x4,%esp
  801476:	53                   	push   %ebx
  801477:	03 45 0c             	add    0xc(%ebp),%eax
  80147a:	50                   	push   %eax
  80147b:	57                   	push   %edi
  80147c:	e8 18 09 00 00       	call   801d99 <memmove>
		sys_cputs(buf, m);
  801481:	83 c4 08             	add    $0x8,%esp
  801484:	53                   	push   %ebx
  801485:	57                   	push   %edi
  801486:	e8 13 ec ff ff       	call   80009e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80148b:	01 de                	add    %ebx,%esi
  80148d:	83 c4 10             	add    $0x10,%esp
  801490:	89 f0                	mov    %esi,%eax
  801492:	3b 75 10             	cmp    0x10(%ebp),%esi
  801495:	72 cc                	jb     801463 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801497:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80149a:	5b                   	pop    %ebx
  80149b:	5e                   	pop    %esi
  80149c:	5f                   	pop    %edi
  80149d:	5d                   	pop    %ebp
  80149e:	c3                   	ret    

0080149f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	83 ec 08             	sub    $0x8,%esp
  8014a5:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8014aa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8014ae:	74 2a                	je     8014da <devcons_read+0x3b>
  8014b0:	eb 05                	jmp    8014b7 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8014b2:	e8 84 ec ff ff       	call   80013b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8014b7:	e8 00 ec ff ff       	call   8000bc <sys_cgetc>
  8014bc:	85 c0                	test   %eax,%eax
  8014be:	74 f2                	je     8014b2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8014c0:	85 c0                	test   %eax,%eax
  8014c2:	78 16                	js     8014da <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8014c4:	83 f8 04             	cmp    $0x4,%eax
  8014c7:	74 0c                	je     8014d5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8014c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014cc:	88 02                	mov    %al,(%edx)
	return 1;
  8014ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8014d3:	eb 05                	jmp    8014da <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8014d5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8014da:	c9                   	leave  
  8014db:	c3                   	ret    

008014dc <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8014e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8014e8:	6a 01                	push   $0x1
  8014ea:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014ed:	50                   	push   %eax
  8014ee:	e8 ab eb ff ff       	call   80009e <sys_cputs>
}
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	c9                   	leave  
  8014f7:	c3                   	ret    

008014f8 <getchar>:

int
getchar(void)
{
  8014f8:	55                   	push   %ebp
  8014f9:	89 e5                	mov    %esp,%ebp
  8014fb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8014fe:	6a 01                	push   $0x1
  801500:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801503:	50                   	push   %eax
  801504:	6a 00                	push   $0x0
  801506:	e8 00 f2 ff ff       	call   80070b <read>
	if (r < 0)
  80150b:	83 c4 10             	add    $0x10,%esp
  80150e:	85 c0                	test   %eax,%eax
  801510:	78 0f                	js     801521 <getchar+0x29>
		return r;
	if (r < 1)
  801512:	85 c0                	test   %eax,%eax
  801514:	7e 06                	jle    80151c <getchar+0x24>
		return -E_EOF;
	return c;
  801516:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80151a:	eb 05                	jmp    801521 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80151c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801521:	c9                   	leave  
  801522:	c3                   	ret    

00801523 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801529:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152c:	50                   	push   %eax
  80152d:	ff 75 08             	pushl  0x8(%ebp)
  801530:	e8 70 ef ff ff       	call   8004a5 <fd_lookup>
  801535:	83 c4 10             	add    $0x10,%esp
  801538:	85 c0                	test   %eax,%eax
  80153a:	78 11                	js     80154d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80153c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80153f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801545:	39 10                	cmp    %edx,(%eax)
  801547:	0f 94 c0             	sete   %al
  80154a:	0f b6 c0             	movzbl %al,%eax
}
  80154d:	c9                   	leave  
  80154e:	c3                   	ret    

0080154f <opencons>:

int
opencons(void)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801555:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801558:	50                   	push   %eax
  801559:	e8 f8 ee ff ff       	call   800456 <fd_alloc>
  80155e:	83 c4 10             	add    $0x10,%esp
		return r;
  801561:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801563:	85 c0                	test   %eax,%eax
  801565:	78 3e                	js     8015a5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801567:	83 ec 04             	sub    $0x4,%esp
  80156a:	68 07 04 00 00       	push   $0x407
  80156f:	ff 75 f4             	pushl  -0xc(%ebp)
  801572:	6a 00                	push   $0x0
  801574:	e8 e1 eb ff ff       	call   80015a <sys_page_alloc>
  801579:	83 c4 10             	add    $0x10,%esp
		return r;
  80157c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80157e:	85 c0                	test   %eax,%eax
  801580:	78 23                	js     8015a5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801582:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801588:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80158b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80158d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801590:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801597:	83 ec 0c             	sub    $0xc,%esp
  80159a:	50                   	push   %eax
  80159b:	e8 8f ee ff ff       	call   80042f <fd2num>
  8015a0:	89 c2                	mov    %eax,%edx
  8015a2:	83 c4 10             	add    $0x10,%esp
}
  8015a5:	89 d0                	mov    %edx,%eax
  8015a7:	c9                   	leave  
  8015a8:	c3                   	ret    

008015a9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	56                   	push   %esi
  8015ad:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8015ae:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8015b1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8015b7:	e8 60 eb ff ff       	call   80011c <sys_getenvid>
  8015bc:	83 ec 0c             	sub    $0xc,%esp
  8015bf:	ff 75 0c             	pushl  0xc(%ebp)
  8015c2:	ff 75 08             	pushl  0x8(%ebp)
  8015c5:	56                   	push   %esi
  8015c6:	50                   	push   %eax
  8015c7:	68 8c 24 80 00       	push   $0x80248c
  8015cc:	e8 b1 00 00 00       	call   801682 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015d1:	83 c4 18             	add    $0x18,%esp
  8015d4:	53                   	push   %ebx
  8015d5:	ff 75 10             	pushl  0x10(%ebp)
  8015d8:	e8 54 00 00 00       	call   801631 <vcprintf>
	cprintf("\n");
  8015dd:	c7 04 24 78 24 80 00 	movl   $0x802478,(%esp)
  8015e4:	e8 99 00 00 00       	call   801682 <cprintf>
  8015e9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8015ec:	cc                   	int3   
  8015ed:	eb fd                	jmp    8015ec <_panic+0x43>

008015ef <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	53                   	push   %ebx
  8015f3:	83 ec 04             	sub    $0x4,%esp
  8015f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8015f9:	8b 13                	mov    (%ebx),%edx
  8015fb:	8d 42 01             	lea    0x1(%edx),%eax
  8015fe:	89 03                	mov    %eax,(%ebx)
  801600:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801603:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801607:	3d ff 00 00 00       	cmp    $0xff,%eax
  80160c:	75 1a                	jne    801628 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80160e:	83 ec 08             	sub    $0x8,%esp
  801611:	68 ff 00 00 00       	push   $0xff
  801616:	8d 43 08             	lea    0x8(%ebx),%eax
  801619:	50                   	push   %eax
  80161a:	e8 7f ea ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  80161f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801625:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801628:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80162c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162f:	c9                   	leave  
  801630:	c3                   	ret    

00801631 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80163a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801641:	00 00 00 
	b.cnt = 0;
  801644:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80164b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80164e:	ff 75 0c             	pushl  0xc(%ebp)
  801651:	ff 75 08             	pushl  0x8(%ebp)
  801654:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80165a:	50                   	push   %eax
  80165b:	68 ef 15 80 00       	push   $0x8015ef
  801660:	e8 54 01 00 00       	call   8017b9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801665:	83 c4 08             	add    $0x8,%esp
  801668:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80166e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801674:	50                   	push   %eax
  801675:	e8 24 ea ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  80167a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801680:	c9                   	leave  
  801681:	c3                   	ret    

00801682 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801688:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80168b:	50                   	push   %eax
  80168c:	ff 75 08             	pushl  0x8(%ebp)
  80168f:	e8 9d ff ff ff       	call   801631 <vcprintf>
	va_end(ap);

	return cnt;
}
  801694:	c9                   	leave  
  801695:	c3                   	ret    

00801696 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	57                   	push   %edi
  80169a:	56                   	push   %esi
  80169b:	53                   	push   %ebx
  80169c:	83 ec 1c             	sub    $0x1c,%esp
  80169f:	89 c7                	mov    %eax,%edi
  8016a1:	89 d6                	mov    %edx,%esi
  8016a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016ac:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016af:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016b7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8016ba:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8016bd:	39 d3                	cmp    %edx,%ebx
  8016bf:	72 05                	jb     8016c6 <printnum+0x30>
  8016c1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8016c4:	77 45                	ja     80170b <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8016c6:	83 ec 0c             	sub    $0xc,%esp
  8016c9:	ff 75 18             	pushl  0x18(%ebp)
  8016cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8016cf:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8016d2:	53                   	push   %ebx
  8016d3:	ff 75 10             	pushl  0x10(%ebp)
  8016d6:	83 ec 08             	sub    $0x8,%esp
  8016d9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8016df:	ff 75 dc             	pushl  -0x24(%ebp)
  8016e2:	ff 75 d8             	pushl  -0x28(%ebp)
  8016e5:	e8 96 09 00 00       	call   802080 <__udivdi3>
  8016ea:	83 c4 18             	add    $0x18,%esp
  8016ed:	52                   	push   %edx
  8016ee:	50                   	push   %eax
  8016ef:	89 f2                	mov    %esi,%edx
  8016f1:	89 f8                	mov    %edi,%eax
  8016f3:	e8 9e ff ff ff       	call   801696 <printnum>
  8016f8:	83 c4 20             	add    $0x20,%esp
  8016fb:	eb 18                	jmp    801715 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8016fd:	83 ec 08             	sub    $0x8,%esp
  801700:	56                   	push   %esi
  801701:	ff 75 18             	pushl  0x18(%ebp)
  801704:	ff d7                	call   *%edi
  801706:	83 c4 10             	add    $0x10,%esp
  801709:	eb 03                	jmp    80170e <printnum+0x78>
  80170b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80170e:	83 eb 01             	sub    $0x1,%ebx
  801711:	85 db                	test   %ebx,%ebx
  801713:	7f e8                	jg     8016fd <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801715:	83 ec 08             	sub    $0x8,%esp
  801718:	56                   	push   %esi
  801719:	83 ec 04             	sub    $0x4,%esp
  80171c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80171f:	ff 75 e0             	pushl  -0x20(%ebp)
  801722:	ff 75 dc             	pushl  -0x24(%ebp)
  801725:	ff 75 d8             	pushl  -0x28(%ebp)
  801728:	e8 83 0a 00 00       	call   8021b0 <__umoddi3>
  80172d:	83 c4 14             	add    $0x14,%esp
  801730:	0f be 80 af 24 80 00 	movsbl 0x8024af(%eax),%eax
  801737:	50                   	push   %eax
  801738:	ff d7                	call   *%edi
}
  80173a:	83 c4 10             	add    $0x10,%esp
  80173d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801740:	5b                   	pop    %ebx
  801741:	5e                   	pop    %esi
  801742:	5f                   	pop    %edi
  801743:	5d                   	pop    %ebp
  801744:	c3                   	ret    

00801745 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801748:	83 fa 01             	cmp    $0x1,%edx
  80174b:	7e 0e                	jle    80175b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80174d:	8b 10                	mov    (%eax),%edx
  80174f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801752:	89 08                	mov    %ecx,(%eax)
  801754:	8b 02                	mov    (%edx),%eax
  801756:	8b 52 04             	mov    0x4(%edx),%edx
  801759:	eb 22                	jmp    80177d <getuint+0x38>
	else if (lflag)
  80175b:	85 d2                	test   %edx,%edx
  80175d:	74 10                	je     80176f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80175f:	8b 10                	mov    (%eax),%edx
  801761:	8d 4a 04             	lea    0x4(%edx),%ecx
  801764:	89 08                	mov    %ecx,(%eax)
  801766:	8b 02                	mov    (%edx),%eax
  801768:	ba 00 00 00 00       	mov    $0x0,%edx
  80176d:	eb 0e                	jmp    80177d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80176f:	8b 10                	mov    (%eax),%edx
  801771:	8d 4a 04             	lea    0x4(%edx),%ecx
  801774:	89 08                	mov    %ecx,(%eax)
  801776:	8b 02                	mov    (%edx),%eax
  801778:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80177d:	5d                   	pop    %ebp
  80177e:	c3                   	ret    

0080177f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801785:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801789:	8b 10                	mov    (%eax),%edx
  80178b:	3b 50 04             	cmp    0x4(%eax),%edx
  80178e:	73 0a                	jae    80179a <sprintputch+0x1b>
		*b->buf++ = ch;
  801790:	8d 4a 01             	lea    0x1(%edx),%ecx
  801793:	89 08                	mov    %ecx,(%eax)
  801795:	8b 45 08             	mov    0x8(%ebp),%eax
  801798:	88 02                	mov    %al,(%edx)
}
  80179a:	5d                   	pop    %ebp
  80179b:	c3                   	ret    

0080179c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8017a2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017a5:	50                   	push   %eax
  8017a6:	ff 75 10             	pushl  0x10(%ebp)
  8017a9:	ff 75 0c             	pushl  0xc(%ebp)
  8017ac:	ff 75 08             	pushl  0x8(%ebp)
  8017af:	e8 05 00 00 00       	call   8017b9 <vprintfmt>
	va_end(ap);
}
  8017b4:	83 c4 10             	add    $0x10,%esp
  8017b7:	c9                   	leave  
  8017b8:	c3                   	ret    

008017b9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017b9:	55                   	push   %ebp
  8017ba:	89 e5                	mov    %esp,%ebp
  8017bc:	57                   	push   %edi
  8017bd:	56                   	push   %esi
  8017be:	53                   	push   %ebx
  8017bf:	83 ec 2c             	sub    $0x2c,%esp
  8017c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8017c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017c8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8017cb:	eb 12                	jmp    8017df <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	0f 84 89 03 00 00    	je     801b5e <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8017d5:	83 ec 08             	sub    $0x8,%esp
  8017d8:	53                   	push   %ebx
  8017d9:	50                   	push   %eax
  8017da:	ff d6                	call   *%esi
  8017dc:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8017df:	83 c7 01             	add    $0x1,%edi
  8017e2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017e6:	83 f8 25             	cmp    $0x25,%eax
  8017e9:	75 e2                	jne    8017cd <vprintfmt+0x14>
  8017eb:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8017ef:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8017f6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017fd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801804:	ba 00 00 00 00       	mov    $0x0,%edx
  801809:	eb 07                	jmp    801812 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80180b:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80180e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801812:	8d 47 01             	lea    0x1(%edi),%eax
  801815:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801818:	0f b6 07             	movzbl (%edi),%eax
  80181b:	0f b6 c8             	movzbl %al,%ecx
  80181e:	83 e8 23             	sub    $0x23,%eax
  801821:	3c 55                	cmp    $0x55,%al
  801823:	0f 87 1a 03 00 00    	ja     801b43 <vprintfmt+0x38a>
  801829:	0f b6 c0             	movzbl %al,%eax
  80182c:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  801833:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801836:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80183a:	eb d6                	jmp    801812 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80183c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80183f:	b8 00 00 00 00       	mov    $0x0,%eax
  801844:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801847:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80184a:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80184e:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801851:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801854:	83 fa 09             	cmp    $0x9,%edx
  801857:	77 39                	ja     801892 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801859:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80185c:	eb e9                	jmp    801847 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80185e:	8b 45 14             	mov    0x14(%ebp),%eax
  801861:	8d 48 04             	lea    0x4(%eax),%ecx
  801864:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801867:	8b 00                	mov    (%eax),%eax
  801869:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80186c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80186f:	eb 27                	jmp    801898 <vprintfmt+0xdf>
  801871:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801874:	85 c0                	test   %eax,%eax
  801876:	b9 00 00 00 00       	mov    $0x0,%ecx
  80187b:	0f 49 c8             	cmovns %eax,%ecx
  80187e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801881:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801884:	eb 8c                	jmp    801812 <vprintfmt+0x59>
  801886:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801889:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801890:	eb 80                	jmp    801812 <vprintfmt+0x59>
  801892:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801895:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801898:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80189c:	0f 89 70 ff ff ff    	jns    801812 <vprintfmt+0x59>
				width = precision, precision = -1;
  8018a2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8018a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018a8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018af:	e9 5e ff ff ff       	jmp    801812 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018b4:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8018ba:	e9 53 ff ff ff       	jmp    801812 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8018c2:	8d 50 04             	lea    0x4(%eax),%edx
  8018c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8018c8:	83 ec 08             	sub    $0x8,%esp
  8018cb:	53                   	push   %ebx
  8018cc:	ff 30                	pushl  (%eax)
  8018ce:	ff d6                	call   *%esi
			break;
  8018d0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8018d6:	e9 04 ff ff ff       	jmp    8017df <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8018db:	8b 45 14             	mov    0x14(%ebp),%eax
  8018de:	8d 50 04             	lea    0x4(%eax),%edx
  8018e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8018e4:	8b 00                	mov    (%eax),%eax
  8018e6:	99                   	cltd   
  8018e7:	31 d0                	xor    %edx,%eax
  8018e9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8018eb:	83 f8 0f             	cmp    $0xf,%eax
  8018ee:	7f 0b                	jg     8018fb <vprintfmt+0x142>
  8018f0:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  8018f7:	85 d2                	test   %edx,%edx
  8018f9:	75 18                	jne    801913 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8018fb:	50                   	push   %eax
  8018fc:	68 c7 24 80 00       	push   $0x8024c7
  801901:	53                   	push   %ebx
  801902:	56                   	push   %esi
  801903:	e8 94 fe ff ff       	call   80179c <printfmt>
  801908:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80190b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80190e:	e9 cc fe ff ff       	jmp    8017df <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801913:	52                   	push   %edx
  801914:	68 06 24 80 00       	push   $0x802406
  801919:	53                   	push   %ebx
  80191a:	56                   	push   %esi
  80191b:	e8 7c fe ff ff       	call   80179c <printfmt>
  801920:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801923:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801926:	e9 b4 fe ff ff       	jmp    8017df <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80192b:	8b 45 14             	mov    0x14(%ebp),%eax
  80192e:	8d 50 04             	lea    0x4(%eax),%edx
  801931:	89 55 14             	mov    %edx,0x14(%ebp)
  801934:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801936:	85 ff                	test   %edi,%edi
  801938:	b8 c0 24 80 00       	mov    $0x8024c0,%eax
  80193d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801940:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801944:	0f 8e 94 00 00 00    	jle    8019de <vprintfmt+0x225>
  80194a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80194e:	0f 84 98 00 00 00    	je     8019ec <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801954:	83 ec 08             	sub    $0x8,%esp
  801957:	ff 75 d0             	pushl  -0x30(%ebp)
  80195a:	57                   	push   %edi
  80195b:	e8 86 02 00 00       	call   801be6 <strnlen>
  801960:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801963:	29 c1                	sub    %eax,%ecx
  801965:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801968:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80196b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80196f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801972:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801975:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801977:	eb 0f                	jmp    801988 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801979:	83 ec 08             	sub    $0x8,%esp
  80197c:	53                   	push   %ebx
  80197d:	ff 75 e0             	pushl  -0x20(%ebp)
  801980:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801982:	83 ef 01             	sub    $0x1,%edi
  801985:	83 c4 10             	add    $0x10,%esp
  801988:	85 ff                	test   %edi,%edi
  80198a:	7f ed                	jg     801979 <vprintfmt+0x1c0>
  80198c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80198f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801992:	85 c9                	test   %ecx,%ecx
  801994:	b8 00 00 00 00       	mov    $0x0,%eax
  801999:	0f 49 c1             	cmovns %ecx,%eax
  80199c:	29 c1                	sub    %eax,%ecx
  80199e:	89 75 08             	mov    %esi,0x8(%ebp)
  8019a1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019a4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019a7:	89 cb                	mov    %ecx,%ebx
  8019a9:	eb 4d                	jmp    8019f8 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019ab:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8019af:	74 1b                	je     8019cc <vprintfmt+0x213>
  8019b1:	0f be c0             	movsbl %al,%eax
  8019b4:	83 e8 20             	sub    $0x20,%eax
  8019b7:	83 f8 5e             	cmp    $0x5e,%eax
  8019ba:	76 10                	jbe    8019cc <vprintfmt+0x213>
					putch('?', putdat);
  8019bc:	83 ec 08             	sub    $0x8,%esp
  8019bf:	ff 75 0c             	pushl  0xc(%ebp)
  8019c2:	6a 3f                	push   $0x3f
  8019c4:	ff 55 08             	call   *0x8(%ebp)
  8019c7:	83 c4 10             	add    $0x10,%esp
  8019ca:	eb 0d                	jmp    8019d9 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8019cc:	83 ec 08             	sub    $0x8,%esp
  8019cf:	ff 75 0c             	pushl  0xc(%ebp)
  8019d2:	52                   	push   %edx
  8019d3:	ff 55 08             	call   *0x8(%ebp)
  8019d6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8019d9:	83 eb 01             	sub    $0x1,%ebx
  8019dc:	eb 1a                	jmp    8019f8 <vprintfmt+0x23f>
  8019de:	89 75 08             	mov    %esi,0x8(%ebp)
  8019e1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019e4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019e7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019ea:	eb 0c                	jmp    8019f8 <vprintfmt+0x23f>
  8019ec:	89 75 08             	mov    %esi,0x8(%ebp)
  8019ef:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019f5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8019f8:	83 c7 01             	add    $0x1,%edi
  8019fb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8019ff:	0f be d0             	movsbl %al,%edx
  801a02:	85 d2                	test   %edx,%edx
  801a04:	74 23                	je     801a29 <vprintfmt+0x270>
  801a06:	85 f6                	test   %esi,%esi
  801a08:	78 a1                	js     8019ab <vprintfmt+0x1f2>
  801a0a:	83 ee 01             	sub    $0x1,%esi
  801a0d:	79 9c                	jns    8019ab <vprintfmt+0x1f2>
  801a0f:	89 df                	mov    %ebx,%edi
  801a11:	8b 75 08             	mov    0x8(%ebp),%esi
  801a14:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a17:	eb 18                	jmp    801a31 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a19:	83 ec 08             	sub    $0x8,%esp
  801a1c:	53                   	push   %ebx
  801a1d:	6a 20                	push   $0x20
  801a1f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a21:	83 ef 01             	sub    $0x1,%edi
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	eb 08                	jmp    801a31 <vprintfmt+0x278>
  801a29:	89 df                	mov    %ebx,%edi
  801a2b:	8b 75 08             	mov    0x8(%ebp),%esi
  801a2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a31:	85 ff                	test   %edi,%edi
  801a33:	7f e4                	jg     801a19 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a35:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a38:	e9 a2 fd ff ff       	jmp    8017df <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a3d:	83 fa 01             	cmp    $0x1,%edx
  801a40:	7e 16                	jle    801a58 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801a42:	8b 45 14             	mov    0x14(%ebp),%eax
  801a45:	8d 50 08             	lea    0x8(%eax),%edx
  801a48:	89 55 14             	mov    %edx,0x14(%ebp)
  801a4b:	8b 50 04             	mov    0x4(%eax),%edx
  801a4e:	8b 00                	mov    (%eax),%eax
  801a50:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a53:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a56:	eb 32                	jmp    801a8a <vprintfmt+0x2d1>
	else if (lflag)
  801a58:	85 d2                	test   %edx,%edx
  801a5a:	74 18                	je     801a74 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801a5c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a5f:	8d 50 04             	lea    0x4(%eax),%edx
  801a62:	89 55 14             	mov    %edx,0x14(%ebp)
  801a65:	8b 00                	mov    (%eax),%eax
  801a67:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a6a:	89 c1                	mov    %eax,%ecx
  801a6c:	c1 f9 1f             	sar    $0x1f,%ecx
  801a6f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a72:	eb 16                	jmp    801a8a <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801a74:	8b 45 14             	mov    0x14(%ebp),%eax
  801a77:	8d 50 04             	lea    0x4(%eax),%edx
  801a7a:	89 55 14             	mov    %edx,0x14(%ebp)
  801a7d:	8b 00                	mov    (%eax),%eax
  801a7f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a82:	89 c1                	mov    %eax,%ecx
  801a84:	c1 f9 1f             	sar    $0x1f,%ecx
  801a87:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a8a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a8d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a90:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a95:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a99:	79 74                	jns    801b0f <vprintfmt+0x356>
				putch('-', putdat);
  801a9b:	83 ec 08             	sub    $0x8,%esp
  801a9e:	53                   	push   %ebx
  801a9f:	6a 2d                	push   $0x2d
  801aa1:	ff d6                	call   *%esi
				num = -(long long) num;
  801aa3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801aa6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801aa9:	f7 d8                	neg    %eax
  801aab:	83 d2 00             	adc    $0x0,%edx
  801aae:	f7 da                	neg    %edx
  801ab0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801ab3:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801ab8:	eb 55                	jmp    801b0f <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801aba:	8d 45 14             	lea    0x14(%ebp),%eax
  801abd:	e8 83 fc ff ff       	call   801745 <getuint>
			base = 10;
  801ac2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801ac7:	eb 46                	jmp    801b0f <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801ac9:	8d 45 14             	lea    0x14(%ebp),%eax
  801acc:	e8 74 fc ff ff       	call   801745 <getuint>
                        base = 8;
  801ad1:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801ad6:	eb 37                	jmp    801b0f <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801ad8:	83 ec 08             	sub    $0x8,%esp
  801adb:	53                   	push   %ebx
  801adc:	6a 30                	push   $0x30
  801ade:	ff d6                	call   *%esi
			putch('x', putdat);
  801ae0:	83 c4 08             	add    $0x8,%esp
  801ae3:	53                   	push   %ebx
  801ae4:	6a 78                	push   $0x78
  801ae6:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801ae8:	8b 45 14             	mov    0x14(%ebp),%eax
  801aeb:	8d 50 04             	lea    0x4(%eax),%edx
  801aee:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801af1:	8b 00                	mov    (%eax),%eax
  801af3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801af8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801afb:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801b00:	eb 0d                	jmp    801b0f <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b02:	8d 45 14             	lea    0x14(%ebp),%eax
  801b05:	e8 3b fc ff ff       	call   801745 <getuint>
			base = 16;
  801b0a:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b0f:	83 ec 0c             	sub    $0xc,%esp
  801b12:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801b16:	57                   	push   %edi
  801b17:	ff 75 e0             	pushl  -0x20(%ebp)
  801b1a:	51                   	push   %ecx
  801b1b:	52                   	push   %edx
  801b1c:	50                   	push   %eax
  801b1d:	89 da                	mov    %ebx,%edx
  801b1f:	89 f0                	mov    %esi,%eax
  801b21:	e8 70 fb ff ff       	call   801696 <printnum>
			break;
  801b26:	83 c4 20             	add    $0x20,%esp
  801b29:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b2c:	e9 ae fc ff ff       	jmp    8017df <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b31:	83 ec 08             	sub    $0x8,%esp
  801b34:	53                   	push   %ebx
  801b35:	51                   	push   %ecx
  801b36:	ff d6                	call   *%esi
			break;
  801b38:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b3b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b3e:	e9 9c fc ff ff       	jmp    8017df <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b43:	83 ec 08             	sub    $0x8,%esp
  801b46:	53                   	push   %ebx
  801b47:	6a 25                	push   $0x25
  801b49:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b4b:	83 c4 10             	add    $0x10,%esp
  801b4e:	eb 03                	jmp    801b53 <vprintfmt+0x39a>
  801b50:	83 ef 01             	sub    $0x1,%edi
  801b53:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b57:	75 f7                	jne    801b50 <vprintfmt+0x397>
  801b59:	e9 81 fc ff ff       	jmp    8017df <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b61:	5b                   	pop    %ebx
  801b62:	5e                   	pop    %esi
  801b63:	5f                   	pop    %edi
  801b64:	5d                   	pop    %ebp
  801b65:	c3                   	ret    

00801b66 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	83 ec 18             	sub    $0x18,%esp
  801b6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b72:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b75:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b79:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b7c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b83:	85 c0                	test   %eax,%eax
  801b85:	74 26                	je     801bad <vsnprintf+0x47>
  801b87:	85 d2                	test   %edx,%edx
  801b89:	7e 22                	jle    801bad <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b8b:	ff 75 14             	pushl  0x14(%ebp)
  801b8e:	ff 75 10             	pushl  0x10(%ebp)
  801b91:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b94:	50                   	push   %eax
  801b95:	68 7f 17 80 00       	push   $0x80177f
  801b9a:	e8 1a fc ff ff       	call   8017b9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ba2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba8:	83 c4 10             	add    $0x10,%esp
  801bab:	eb 05                	jmp    801bb2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801bad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801bb2:	c9                   	leave  
  801bb3:	c3                   	ret    

00801bb4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801bba:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801bbd:	50                   	push   %eax
  801bbe:	ff 75 10             	pushl  0x10(%ebp)
  801bc1:	ff 75 0c             	pushl  0xc(%ebp)
  801bc4:	ff 75 08             	pushl  0x8(%ebp)
  801bc7:	e8 9a ff ff ff       	call   801b66 <vsnprintf>
	va_end(ap);

	return rc;
}
  801bcc:	c9                   	leave  
  801bcd:	c3                   	ret    

00801bce <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
  801bd1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801bd4:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd9:	eb 03                	jmp    801bde <strlen+0x10>
		n++;
  801bdb:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801bde:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801be2:	75 f7                	jne    801bdb <strlen+0xd>
		n++;
	return n;
}
  801be4:	5d                   	pop    %ebp
  801be5:	c3                   	ret    

00801be6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bec:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bef:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf4:	eb 03                	jmp    801bf9 <strnlen+0x13>
		n++;
  801bf6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bf9:	39 c2                	cmp    %eax,%edx
  801bfb:	74 08                	je     801c05 <strnlen+0x1f>
  801bfd:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801c01:	75 f3                	jne    801bf6 <strnlen+0x10>
  801c03:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801c05:	5d                   	pop    %ebp
  801c06:	c3                   	ret    

00801c07 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801c07:	55                   	push   %ebp
  801c08:	89 e5                	mov    %esp,%ebp
  801c0a:	53                   	push   %ebx
  801c0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c11:	89 c2                	mov    %eax,%edx
  801c13:	83 c2 01             	add    $0x1,%edx
  801c16:	83 c1 01             	add    $0x1,%ecx
  801c19:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801c1d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c20:	84 db                	test   %bl,%bl
  801c22:	75 ef                	jne    801c13 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801c24:	5b                   	pop    %ebx
  801c25:	5d                   	pop    %ebp
  801c26:	c3                   	ret    

00801c27 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
  801c2a:	53                   	push   %ebx
  801c2b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c2e:	53                   	push   %ebx
  801c2f:	e8 9a ff ff ff       	call   801bce <strlen>
  801c34:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c37:	ff 75 0c             	pushl  0xc(%ebp)
  801c3a:	01 d8                	add    %ebx,%eax
  801c3c:	50                   	push   %eax
  801c3d:	e8 c5 ff ff ff       	call   801c07 <strcpy>
	return dst;
}
  801c42:	89 d8                	mov    %ebx,%eax
  801c44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c47:	c9                   	leave  
  801c48:	c3                   	ret    

00801c49 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c49:	55                   	push   %ebp
  801c4a:	89 e5                	mov    %esp,%ebp
  801c4c:	56                   	push   %esi
  801c4d:	53                   	push   %ebx
  801c4e:	8b 75 08             	mov    0x8(%ebp),%esi
  801c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c54:	89 f3                	mov    %esi,%ebx
  801c56:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c59:	89 f2                	mov    %esi,%edx
  801c5b:	eb 0f                	jmp    801c6c <strncpy+0x23>
		*dst++ = *src;
  801c5d:	83 c2 01             	add    $0x1,%edx
  801c60:	0f b6 01             	movzbl (%ecx),%eax
  801c63:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c66:	80 39 01             	cmpb   $0x1,(%ecx)
  801c69:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c6c:	39 da                	cmp    %ebx,%edx
  801c6e:	75 ed                	jne    801c5d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c70:	89 f0                	mov    %esi,%eax
  801c72:	5b                   	pop    %ebx
  801c73:	5e                   	pop    %esi
  801c74:	5d                   	pop    %ebp
  801c75:	c3                   	ret    

00801c76 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c76:	55                   	push   %ebp
  801c77:	89 e5                	mov    %esp,%ebp
  801c79:	56                   	push   %esi
  801c7a:	53                   	push   %ebx
  801c7b:	8b 75 08             	mov    0x8(%ebp),%esi
  801c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c81:	8b 55 10             	mov    0x10(%ebp),%edx
  801c84:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c86:	85 d2                	test   %edx,%edx
  801c88:	74 21                	je     801cab <strlcpy+0x35>
  801c8a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c8e:	89 f2                	mov    %esi,%edx
  801c90:	eb 09                	jmp    801c9b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c92:	83 c2 01             	add    $0x1,%edx
  801c95:	83 c1 01             	add    $0x1,%ecx
  801c98:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c9b:	39 c2                	cmp    %eax,%edx
  801c9d:	74 09                	je     801ca8 <strlcpy+0x32>
  801c9f:	0f b6 19             	movzbl (%ecx),%ebx
  801ca2:	84 db                	test   %bl,%bl
  801ca4:	75 ec                	jne    801c92 <strlcpy+0x1c>
  801ca6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801ca8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801cab:	29 f0                	sub    %esi,%eax
}
  801cad:	5b                   	pop    %ebx
  801cae:	5e                   	pop    %esi
  801caf:	5d                   	pop    %ebp
  801cb0:	c3                   	ret    

00801cb1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801cba:	eb 06                	jmp    801cc2 <strcmp+0x11>
		p++, q++;
  801cbc:	83 c1 01             	add    $0x1,%ecx
  801cbf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801cc2:	0f b6 01             	movzbl (%ecx),%eax
  801cc5:	84 c0                	test   %al,%al
  801cc7:	74 04                	je     801ccd <strcmp+0x1c>
  801cc9:	3a 02                	cmp    (%edx),%al
  801ccb:	74 ef                	je     801cbc <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801ccd:	0f b6 c0             	movzbl %al,%eax
  801cd0:	0f b6 12             	movzbl (%edx),%edx
  801cd3:	29 d0                	sub    %edx,%eax
}
  801cd5:	5d                   	pop    %ebp
  801cd6:	c3                   	ret    

00801cd7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	53                   	push   %ebx
  801cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cde:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ce1:	89 c3                	mov    %eax,%ebx
  801ce3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801ce6:	eb 06                	jmp    801cee <strncmp+0x17>
		n--, p++, q++;
  801ce8:	83 c0 01             	add    $0x1,%eax
  801ceb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801cee:	39 d8                	cmp    %ebx,%eax
  801cf0:	74 15                	je     801d07 <strncmp+0x30>
  801cf2:	0f b6 08             	movzbl (%eax),%ecx
  801cf5:	84 c9                	test   %cl,%cl
  801cf7:	74 04                	je     801cfd <strncmp+0x26>
  801cf9:	3a 0a                	cmp    (%edx),%cl
  801cfb:	74 eb                	je     801ce8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801cfd:	0f b6 00             	movzbl (%eax),%eax
  801d00:	0f b6 12             	movzbl (%edx),%edx
  801d03:	29 d0                	sub    %edx,%eax
  801d05:	eb 05                	jmp    801d0c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801d07:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801d0c:	5b                   	pop    %ebx
  801d0d:	5d                   	pop    %ebp
  801d0e:	c3                   	ret    

00801d0f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	8b 45 08             	mov    0x8(%ebp),%eax
  801d15:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d19:	eb 07                	jmp    801d22 <strchr+0x13>
		if (*s == c)
  801d1b:	38 ca                	cmp    %cl,%dl
  801d1d:	74 0f                	je     801d2e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801d1f:	83 c0 01             	add    $0x1,%eax
  801d22:	0f b6 10             	movzbl (%eax),%edx
  801d25:	84 d2                	test   %dl,%dl
  801d27:	75 f2                	jne    801d1b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d29:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d2e:	5d                   	pop    %ebp
  801d2f:	c3                   	ret    

00801d30 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
  801d33:	8b 45 08             	mov    0x8(%ebp),%eax
  801d36:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d3a:	eb 03                	jmp    801d3f <strfind+0xf>
  801d3c:	83 c0 01             	add    $0x1,%eax
  801d3f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d42:	38 ca                	cmp    %cl,%dl
  801d44:	74 04                	je     801d4a <strfind+0x1a>
  801d46:	84 d2                	test   %dl,%dl
  801d48:	75 f2                	jne    801d3c <strfind+0xc>
			break;
	return (char *) s;
}
  801d4a:	5d                   	pop    %ebp
  801d4b:	c3                   	ret    

00801d4c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	57                   	push   %edi
  801d50:	56                   	push   %esi
  801d51:	53                   	push   %ebx
  801d52:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d55:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d58:	85 c9                	test   %ecx,%ecx
  801d5a:	74 36                	je     801d92 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d5c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d62:	75 28                	jne    801d8c <memset+0x40>
  801d64:	f6 c1 03             	test   $0x3,%cl
  801d67:	75 23                	jne    801d8c <memset+0x40>
		c &= 0xFF;
  801d69:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d6d:	89 d3                	mov    %edx,%ebx
  801d6f:	c1 e3 08             	shl    $0x8,%ebx
  801d72:	89 d6                	mov    %edx,%esi
  801d74:	c1 e6 18             	shl    $0x18,%esi
  801d77:	89 d0                	mov    %edx,%eax
  801d79:	c1 e0 10             	shl    $0x10,%eax
  801d7c:	09 f0                	or     %esi,%eax
  801d7e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d80:	89 d8                	mov    %ebx,%eax
  801d82:	09 d0                	or     %edx,%eax
  801d84:	c1 e9 02             	shr    $0x2,%ecx
  801d87:	fc                   	cld    
  801d88:	f3 ab                	rep stos %eax,%es:(%edi)
  801d8a:	eb 06                	jmp    801d92 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d8f:	fc                   	cld    
  801d90:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d92:	89 f8                	mov    %edi,%eax
  801d94:	5b                   	pop    %ebx
  801d95:	5e                   	pop    %esi
  801d96:	5f                   	pop    %edi
  801d97:	5d                   	pop    %ebp
  801d98:	c3                   	ret    

00801d99 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d99:	55                   	push   %ebp
  801d9a:	89 e5                	mov    %esp,%ebp
  801d9c:	57                   	push   %edi
  801d9d:	56                   	push   %esi
  801d9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801da1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801da4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801da7:	39 c6                	cmp    %eax,%esi
  801da9:	73 35                	jae    801de0 <memmove+0x47>
  801dab:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801dae:	39 d0                	cmp    %edx,%eax
  801db0:	73 2e                	jae    801de0 <memmove+0x47>
		s += n;
		d += n;
  801db2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801db5:	89 d6                	mov    %edx,%esi
  801db7:	09 fe                	or     %edi,%esi
  801db9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801dbf:	75 13                	jne    801dd4 <memmove+0x3b>
  801dc1:	f6 c1 03             	test   $0x3,%cl
  801dc4:	75 0e                	jne    801dd4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801dc6:	83 ef 04             	sub    $0x4,%edi
  801dc9:	8d 72 fc             	lea    -0x4(%edx),%esi
  801dcc:	c1 e9 02             	shr    $0x2,%ecx
  801dcf:	fd                   	std    
  801dd0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801dd2:	eb 09                	jmp    801ddd <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801dd4:	83 ef 01             	sub    $0x1,%edi
  801dd7:	8d 72 ff             	lea    -0x1(%edx),%esi
  801dda:	fd                   	std    
  801ddb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801ddd:	fc                   	cld    
  801dde:	eb 1d                	jmp    801dfd <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801de0:	89 f2                	mov    %esi,%edx
  801de2:	09 c2                	or     %eax,%edx
  801de4:	f6 c2 03             	test   $0x3,%dl
  801de7:	75 0f                	jne    801df8 <memmove+0x5f>
  801de9:	f6 c1 03             	test   $0x3,%cl
  801dec:	75 0a                	jne    801df8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801dee:	c1 e9 02             	shr    $0x2,%ecx
  801df1:	89 c7                	mov    %eax,%edi
  801df3:	fc                   	cld    
  801df4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801df6:	eb 05                	jmp    801dfd <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801df8:	89 c7                	mov    %eax,%edi
  801dfa:	fc                   	cld    
  801dfb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801dfd:	5e                   	pop    %esi
  801dfe:	5f                   	pop    %edi
  801dff:	5d                   	pop    %ebp
  801e00:	c3                   	ret    

00801e01 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e01:	55                   	push   %ebp
  801e02:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801e04:	ff 75 10             	pushl  0x10(%ebp)
  801e07:	ff 75 0c             	pushl  0xc(%ebp)
  801e0a:	ff 75 08             	pushl  0x8(%ebp)
  801e0d:	e8 87 ff ff ff       	call   801d99 <memmove>
}
  801e12:	c9                   	leave  
  801e13:	c3                   	ret    

00801e14 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	56                   	push   %esi
  801e18:	53                   	push   %ebx
  801e19:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e1f:	89 c6                	mov    %eax,%esi
  801e21:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e24:	eb 1a                	jmp    801e40 <memcmp+0x2c>
		if (*s1 != *s2)
  801e26:	0f b6 08             	movzbl (%eax),%ecx
  801e29:	0f b6 1a             	movzbl (%edx),%ebx
  801e2c:	38 d9                	cmp    %bl,%cl
  801e2e:	74 0a                	je     801e3a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e30:	0f b6 c1             	movzbl %cl,%eax
  801e33:	0f b6 db             	movzbl %bl,%ebx
  801e36:	29 d8                	sub    %ebx,%eax
  801e38:	eb 0f                	jmp    801e49 <memcmp+0x35>
		s1++, s2++;
  801e3a:	83 c0 01             	add    $0x1,%eax
  801e3d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e40:	39 f0                	cmp    %esi,%eax
  801e42:	75 e2                	jne    801e26 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e49:	5b                   	pop    %ebx
  801e4a:	5e                   	pop    %esi
  801e4b:	5d                   	pop    %ebp
  801e4c:	c3                   	ret    

00801e4d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e4d:	55                   	push   %ebp
  801e4e:	89 e5                	mov    %esp,%ebp
  801e50:	53                   	push   %ebx
  801e51:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e54:	89 c1                	mov    %eax,%ecx
  801e56:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e59:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e5d:	eb 0a                	jmp    801e69 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e5f:	0f b6 10             	movzbl (%eax),%edx
  801e62:	39 da                	cmp    %ebx,%edx
  801e64:	74 07                	je     801e6d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e66:	83 c0 01             	add    $0x1,%eax
  801e69:	39 c8                	cmp    %ecx,%eax
  801e6b:	72 f2                	jb     801e5f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e6d:	5b                   	pop    %ebx
  801e6e:	5d                   	pop    %ebp
  801e6f:	c3                   	ret    

00801e70 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e70:	55                   	push   %ebp
  801e71:	89 e5                	mov    %esp,%ebp
  801e73:	57                   	push   %edi
  801e74:	56                   	push   %esi
  801e75:	53                   	push   %ebx
  801e76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e79:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e7c:	eb 03                	jmp    801e81 <strtol+0x11>
		s++;
  801e7e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e81:	0f b6 01             	movzbl (%ecx),%eax
  801e84:	3c 20                	cmp    $0x20,%al
  801e86:	74 f6                	je     801e7e <strtol+0xe>
  801e88:	3c 09                	cmp    $0x9,%al
  801e8a:	74 f2                	je     801e7e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e8c:	3c 2b                	cmp    $0x2b,%al
  801e8e:	75 0a                	jne    801e9a <strtol+0x2a>
		s++;
  801e90:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e93:	bf 00 00 00 00       	mov    $0x0,%edi
  801e98:	eb 11                	jmp    801eab <strtol+0x3b>
  801e9a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e9f:	3c 2d                	cmp    $0x2d,%al
  801ea1:	75 08                	jne    801eab <strtol+0x3b>
		s++, neg = 1;
  801ea3:	83 c1 01             	add    $0x1,%ecx
  801ea6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801eab:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801eb1:	75 15                	jne    801ec8 <strtol+0x58>
  801eb3:	80 39 30             	cmpb   $0x30,(%ecx)
  801eb6:	75 10                	jne    801ec8 <strtol+0x58>
  801eb8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ebc:	75 7c                	jne    801f3a <strtol+0xca>
		s += 2, base = 16;
  801ebe:	83 c1 02             	add    $0x2,%ecx
  801ec1:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ec6:	eb 16                	jmp    801ede <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801ec8:	85 db                	test   %ebx,%ebx
  801eca:	75 12                	jne    801ede <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801ecc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ed1:	80 39 30             	cmpb   $0x30,(%ecx)
  801ed4:	75 08                	jne    801ede <strtol+0x6e>
		s++, base = 8;
  801ed6:	83 c1 01             	add    $0x1,%ecx
  801ed9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801ede:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801ee6:	0f b6 11             	movzbl (%ecx),%edx
  801ee9:	8d 72 d0             	lea    -0x30(%edx),%esi
  801eec:	89 f3                	mov    %esi,%ebx
  801eee:	80 fb 09             	cmp    $0x9,%bl
  801ef1:	77 08                	ja     801efb <strtol+0x8b>
			dig = *s - '0';
  801ef3:	0f be d2             	movsbl %dl,%edx
  801ef6:	83 ea 30             	sub    $0x30,%edx
  801ef9:	eb 22                	jmp    801f1d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801efb:	8d 72 9f             	lea    -0x61(%edx),%esi
  801efe:	89 f3                	mov    %esi,%ebx
  801f00:	80 fb 19             	cmp    $0x19,%bl
  801f03:	77 08                	ja     801f0d <strtol+0x9d>
			dig = *s - 'a' + 10;
  801f05:	0f be d2             	movsbl %dl,%edx
  801f08:	83 ea 57             	sub    $0x57,%edx
  801f0b:	eb 10                	jmp    801f1d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801f0d:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f10:	89 f3                	mov    %esi,%ebx
  801f12:	80 fb 19             	cmp    $0x19,%bl
  801f15:	77 16                	ja     801f2d <strtol+0xbd>
			dig = *s - 'A' + 10;
  801f17:	0f be d2             	movsbl %dl,%edx
  801f1a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801f1d:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f20:	7d 0b                	jge    801f2d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801f22:	83 c1 01             	add    $0x1,%ecx
  801f25:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f29:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f2b:	eb b9                	jmp    801ee6 <strtol+0x76>

	if (endptr)
  801f2d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f31:	74 0d                	je     801f40 <strtol+0xd0>
		*endptr = (char *) s;
  801f33:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f36:	89 0e                	mov    %ecx,(%esi)
  801f38:	eb 06                	jmp    801f40 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f3a:	85 db                	test   %ebx,%ebx
  801f3c:	74 98                	je     801ed6 <strtol+0x66>
  801f3e:	eb 9e                	jmp    801ede <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f40:	89 c2                	mov    %eax,%edx
  801f42:	f7 da                	neg    %edx
  801f44:	85 ff                	test   %edi,%edi
  801f46:	0f 45 c2             	cmovne %edx,%eax
}
  801f49:	5b                   	pop    %ebx
  801f4a:	5e                   	pop    %esi
  801f4b:	5f                   	pop    %edi
  801f4c:	5d                   	pop    %ebp
  801f4d:	c3                   	ret    

00801f4e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f4e:	55                   	push   %ebp
  801f4f:	89 e5                	mov    %esp,%ebp
  801f51:	56                   	push   %esi
  801f52:	53                   	push   %ebx
  801f53:	8b 75 08             	mov    0x8(%ebp),%esi
  801f56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f59:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801f5c:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801f5e:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801f63:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801f66:	83 ec 0c             	sub    $0xc,%esp
  801f69:	50                   	push   %eax
  801f6a:	e8 9b e3 ff ff       	call   80030a <sys_ipc_recv>

	if (r < 0) {
  801f6f:	83 c4 10             	add    $0x10,%esp
  801f72:	85 c0                	test   %eax,%eax
  801f74:	79 16                	jns    801f8c <ipc_recv+0x3e>
		if (from_env_store)
  801f76:	85 f6                	test   %esi,%esi
  801f78:	74 06                	je     801f80 <ipc_recv+0x32>
			*from_env_store = 0;
  801f7a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801f80:	85 db                	test   %ebx,%ebx
  801f82:	74 2c                	je     801fb0 <ipc_recv+0x62>
			*perm_store = 0;
  801f84:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f8a:	eb 24                	jmp    801fb0 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801f8c:	85 f6                	test   %esi,%esi
  801f8e:	74 0a                	je     801f9a <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801f90:	a1 08 40 80 00       	mov    0x804008,%eax
  801f95:	8b 40 74             	mov    0x74(%eax),%eax
  801f98:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801f9a:	85 db                	test   %ebx,%ebx
  801f9c:	74 0a                	je     801fa8 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801f9e:	a1 08 40 80 00       	mov    0x804008,%eax
  801fa3:	8b 40 78             	mov    0x78(%eax),%eax
  801fa6:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801fa8:	a1 08 40 80 00       	mov    0x804008,%eax
  801fad:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801fb0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb3:	5b                   	pop    %ebx
  801fb4:	5e                   	pop    %esi
  801fb5:	5d                   	pop    %ebp
  801fb6:	c3                   	ret    

00801fb7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fb7:	55                   	push   %ebp
  801fb8:	89 e5                	mov    %esp,%ebp
  801fba:	57                   	push   %edi
  801fbb:	56                   	push   %esi
  801fbc:	53                   	push   %ebx
  801fbd:	83 ec 0c             	sub    $0xc,%esp
  801fc0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fc3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801fc9:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801fcb:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801fd0:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801fd3:	ff 75 14             	pushl  0x14(%ebp)
  801fd6:	53                   	push   %ebx
  801fd7:	56                   	push   %esi
  801fd8:	57                   	push   %edi
  801fd9:	e8 09 e3 ff ff       	call   8002e7 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801fde:	83 c4 10             	add    $0x10,%esp
  801fe1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fe4:	75 07                	jne    801fed <ipc_send+0x36>
			sys_yield();
  801fe6:	e8 50 e1 ff ff       	call   80013b <sys_yield>
  801feb:	eb e6                	jmp    801fd3 <ipc_send+0x1c>
		} else if (r < 0) {
  801fed:	85 c0                	test   %eax,%eax
  801fef:	79 12                	jns    802003 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801ff1:	50                   	push   %eax
  801ff2:	68 c0 27 80 00       	push   $0x8027c0
  801ff7:	6a 51                	push   $0x51
  801ff9:	68 cd 27 80 00       	push   $0x8027cd
  801ffe:	e8 a6 f5 ff ff       	call   8015a9 <_panic>
		}
	}
}
  802003:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802006:	5b                   	pop    %ebx
  802007:	5e                   	pop    %esi
  802008:	5f                   	pop    %edi
  802009:	5d                   	pop    %ebp
  80200a:	c3                   	ret    

0080200b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80200b:	55                   	push   %ebp
  80200c:	89 e5                	mov    %esp,%ebp
  80200e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802011:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802016:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802019:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80201f:	8b 52 50             	mov    0x50(%edx),%edx
  802022:	39 ca                	cmp    %ecx,%edx
  802024:	75 0d                	jne    802033 <ipc_find_env+0x28>
			return envs[i].env_id;
  802026:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802029:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80202e:	8b 40 48             	mov    0x48(%eax),%eax
  802031:	eb 0f                	jmp    802042 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802033:	83 c0 01             	add    $0x1,%eax
  802036:	3d 00 04 00 00       	cmp    $0x400,%eax
  80203b:	75 d9                	jne    802016 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80203d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802042:	5d                   	pop    %ebp
  802043:	c3                   	ret    

00802044 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802044:	55                   	push   %ebp
  802045:	89 e5                	mov    %esp,%ebp
  802047:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80204a:	89 d0                	mov    %edx,%eax
  80204c:	c1 e8 16             	shr    $0x16,%eax
  80204f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802056:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80205b:	f6 c1 01             	test   $0x1,%cl
  80205e:	74 1d                	je     80207d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802060:	c1 ea 0c             	shr    $0xc,%edx
  802063:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80206a:	f6 c2 01             	test   $0x1,%dl
  80206d:	74 0e                	je     80207d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80206f:	c1 ea 0c             	shr    $0xc,%edx
  802072:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802079:	ef 
  80207a:	0f b7 c0             	movzwl %ax,%eax
}
  80207d:	5d                   	pop    %ebp
  80207e:	c3                   	ret    
  80207f:	90                   	nop

00802080 <__udivdi3>:
  802080:	55                   	push   %ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	53                   	push   %ebx
  802084:	83 ec 1c             	sub    $0x1c,%esp
  802087:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80208b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80208f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802093:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802097:	85 f6                	test   %esi,%esi
  802099:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80209d:	89 ca                	mov    %ecx,%edx
  80209f:	89 f8                	mov    %edi,%eax
  8020a1:	75 3d                	jne    8020e0 <__udivdi3+0x60>
  8020a3:	39 cf                	cmp    %ecx,%edi
  8020a5:	0f 87 c5 00 00 00    	ja     802170 <__udivdi3+0xf0>
  8020ab:	85 ff                	test   %edi,%edi
  8020ad:	89 fd                	mov    %edi,%ebp
  8020af:	75 0b                	jne    8020bc <__udivdi3+0x3c>
  8020b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b6:	31 d2                	xor    %edx,%edx
  8020b8:	f7 f7                	div    %edi
  8020ba:	89 c5                	mov    %eax,%ebp
  8020bc:	89 c8                	mov    %ecx,%eax
  8020be:	31 d2                	xor    %edx,%edx
  8020c0:	f7 f5                	div    %ebp
  8020c2:	89 c1                	mov    %eax,%ecx
  8020c4:	89 d8                	mov    %ebx,%eax
  8020c6:	89 cf                	mov    %ecx,%edi
  8020c8:	f7 f5                	div    %ebp
  8020ca:	89 c3                	mov    %eax,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	39 ce                	cmp    %ecx,%esi
  8020e2:	77 74                	ja     802158 <__udivdi3+0xd8>
  8020e4:	0f bd fe             	bsr    %esi,%edi
  8020e7:	83 f7 1f             	xor    $0x1f,%edi
  8020ea:	0f 84 98 00 00 00    	je     802188 <__udivdi3+0x108>
  8020f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	89 c5                	mov    %eax,%ebp
  8020f9:	29 fb                	sub    %edi,%ebx
  8020fb:	d3 e6                	shl    %cl,%esi
  8020fd:	89 d9                	mov    %ebx,%ecx
  8020ff:	d3 ed                	shr    %cl,%ebp
  802101:	89 f9                	mov    %edi,%ecx
  802103:	d3 e0                	shl    %cl,%eax
  802105:	09 ee                	or     %ebp,%esi
  802107:	89 d9                	mov    %ebx,%ecx
  802109:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80210d:	89 d5                	mov    %edx,%ebp
  80210f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802113:	d3 ed                	shr    %cl,%ebp
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 e2                	shl    %cl,%edx
  802119:	89 d9                	mov    %ebx,%ecx
  80211b:	d3 e8                	shr    %cl,%eax
  80211d:	09 c2                	or     %eax,%edx
  80211f:	89 d0                	mov    %edx,%eax
  802121:	89 ea                	mov    %ebp,%edx
  802123:	f7 f6                	div    %esi
  802125:	89 d5                	mov    %edx,%ebp
  802127:	89 c3                	mov    %eax,%ebx
  802129:	f7 64 24 0c          	mull   0xc(%esp)
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	72 10                	jb     802141 <__udivdi3+0xc1>
  802131:	8b 74 24 08          	mov    0x8(%esp),%esi
  802135:	89 f9                	mov    %edi,%ecx
  802137:	d3 e6                	shl    %cl,%esi
  802139:	39 c6                	cmp    %eax,%esi
  80213b:	73 07                	jae    802144 <__udivdi3+0xc4>
  80213d:	39 d5                	cmp    %edx,%ebp
  80213f:	75 03                	jne    802144 <__udivdi3+0xc4>
  802141:	83 eb 01             	sub    $0x1,%ebx
  802144:	31 ff                	xor    %edi,%edi
  802146:	89 d8                	mov    %ebx,%eax
  802148:	89 fa                	mov    %edi,%edx
  80214a:	83 c4 1c             	add    $0x1c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802158:	31 ff                	xor    %edi,%edi
  80215a:	31 db                	xor    %ebx,%ebx
  80215c:	89 d8                	mov    %ebx,%eax
  80215e:	89 fa                	mov    %edi,%edx
  802160:	83 c4 1c             	add    $0x1c,%esp
  802163:	5b                   	pop    %ebx
  802164:	5e                   	pop    %esi
  802165:	5f                   	pop    %edi
  802166:	5d                   	pop    %ebp
  802167:	c3                   	ret    
  802168:	90                   	nop
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	89 d8                	mov    %ebx,%eax
  802172:	f7 f7                	div    %edi
  802174:	31 ff                	xor    %edi,%edi
  802176:	89 c3                	mov    %eax,%ebx
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	89 fa                	mov    %edi,%edx
  80217c:	83 c4 1c             	add    $0x1c,%esp
  80217f:	5b                   	pop    %ebx
  802180:	5e                   	pop    %esi
  802181:	5f                   	pop    %edi
  802182:	5d                   	pop    %ebp
  802183:	c3                   	ret    
  802184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802188:	39 ce                	cmp    %ecx,%esi
  80218a:	72 0c                	jb     802198 <__udivdi3+0x118>
  80218c:	31 db                	xor    %ebx,%ebx
  80218e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802192:	0f 87 34 ff ff ff    	ja     8020cc <__udivdi3+0x4c>
  802198:	bb 01 00 00 00       	mov    $0x1,%ebx
  80219d:	e9 2a ff ff ff       	jmp    8020cc <__udivdi3+0x4c>
  8021a2:	66 90                	xchg   %ax,%ax
  8021a4:	66 90                	xchg   %ax,%ax
  8021a6:	66 90                	xchg   %ax,%ax
  8021a8:	66 90                	xchg   %ax,%ax
  8021aa:	66 90                	xchg   %ax,%ax
  8021ac:	66 90                	xchg   %ax,%ax
  8021ae:	66 90                	xchg   %ax,%ax

008021b0 <__umoddi3>:
  8021b0:	55                   	push   %ebp
  8021b1:	57                   	push   %edi
  8021b2:	56                   	push   %esi
  8021b3:	53                   	push   %ebx
  8021b4:	83 ec 1c             	sub    $0x1c,%esp
  8021b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021c7:	85 d2                	test   %edx,%edx
  8021c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021d1:	89 f3                	mov    %esi,%ebx
  8021d3:	89 3c 24             	mov    %edi,(%esp)
  8021d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021da:	75 1c                	jne    8021f8 <__umoddi3+0x48>
  8021dc:	39 f7                	cmp    %esi,%edi
  8021de:	76 50                	jbe    802230 <__umoddi3+0x80>
  8021e0:	89 c8                	mov    %ecx,%eax
  8021e2:	89 f2                	mov    %esi,%edx
  8021e4:	f7 f7                	div    %edi
  8021e6:	89 d0                	mov    %edx,%eax
  8021e8:	31 d2                	xor    %edx,%edx
  8021ea:	83 c4 1c             	add    $0x1c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
  8021f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f8:	39 f2                	cmp    %esi,%edx
  8021fa:	89 d0                	mov    %edx,%eax
  8021fc:	77 52                	ja     802250 <__umoddi3+0xa0>
  8021fe:	0f bd ea             	bsr    %edx,%ebp
  802201:	83 f5 1f             	xor    $0x1f,%ebp
  802204:	75 5a                	jne    802260 <__umoddi3+0xb0>
  802206:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80220a:	0f 82 e0 00 00 00    	jb     8022f0 <__umoddi3+0x140>
  802210:	39 0c 24             	cmp    %ecx,(%esp)
  802213:	0f 86 d7 00 00 00    	jbe    8022f0 <__umoddi3+0x140>
  802219:	8b 44 24 08          	mov    0x8(%esp),%eax
  80221d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802221:	83 c4 1c             	add    $0x1c,%esp
  802224:	5b                   	pop    %ebx
  802225:	5e                   	pop    %esi
  802226:	5f                   	pop    %edi
  802227:	5d                   	pop    %ebp
  802228:	c3                   	ret    
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	85 ff                	test   %edi,%edi
  802232:	89 fd                	mov    %edi,%ebp
  802234:	75 0b                	jne    802241 <__umoddi3+0x91>
  802236:	b8 01 00 00 00       	mov    $0x1,%eax
  80223b:	31 d2                	xor    %edx,%edx
  80223d:	f7 f7                	div    %edi
  80223f:	89 c5                	mov    %eax,%ebp
  802241:	89 f0                	mov    %esi,%eax
  802243:	31 d2                	xor    %edx,%edx
  802245:	f7 f5                	div    %ebp
  802247:	89 c8                	mov    %ecx,%eax
  802249:	f7 f5                	div    %ebp
  80224b:	89 d0                	mov    %edx,%eax
  80224d:	eb 99                	jmp    8021e8 <__umoddi3+0x38>
  80224f:	90                   	nop
  802250:	89 c8                	mov    %ecx,%eax
  802252:	89 f2                	mov    %esi,%edx
  802254:	83 c4 1c             	add    $0x1c,%esp
  802257:	5b                   	pop    %ebx
  802258:	5e                   	pop    %esi
  802259:	5f                   	pop    %edi
  80225a:	5d                   	pop    %ebp
  80225b:	c3                   	ret    
  80225c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802260:	8b 34 24             	mov    (%esp),%esi
  802263:	bf 20 00 00 00       	mov    $0x20,%edi
  802268:	89 e9                	mov    %ebp,%ecx
  80226a:	29 ef                	sub    %ebp,%edi
  80226c:	d3 e0                	shl    %cl,%eax
  80226e:	89 f9                	mov    %edi,%ecx
  802270:	89 f2                	mov    %esi,%edx
  802272:	d3 ea                	shr    %cl,%edx
  802274:	89 e9                	mov    %ebp,%ecx
  802276:	09 c2                	or     %eax,%edx
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	89 14 24             	mov    %edx,(%esp)
  80227d:	89 f2                	mov    %esi,%edx
  80227f:	d3 e2                	shl    %cl,%edx
  802281:	89 f9                	mov    %edi,%ecx
  802283:	89 54 24 04          	mov    %edx,0x4(%esp)
  802287:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80228b:	d3 e8                	shr    %cl,%eax
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	89 c6                	mov    %eax,%esi
  802291:	d3 e3                	shl    %cl,%ebx
  802293:	89 f9                	mov    %edi,%ecx
  802295:	89 d0                	mov    %edx,%eax
  802297:	d3 e8                	shr    %cl,%eax
  802299:	89 e9                	mov    %ebp,%ecx
  80229b:	09 d8                	or     %ebx,%eax
  80229d:	89 d3                	mov    %edx,%ebx
  80229f:	89 f2                	mov    %esi,%edx
  8022a1:	f7 34 24             	divl   (%esp)
  8022a4:	89 d6                	mov    %edx,%esi
  8022a6:	d3 e3                	shl    %cl,%ebx
  8022a8:	f7 64 24 04          	mull   0x4(%esp)
  8022ac:	39 d6                	cmp    %edx,%esi
  8022ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022b2:	89 d1                	mov    %edx,%ecx
  8022b4:	89 c3                	mov    %eax,%ebx
  8022b6:	72 08                	jb     8022c0 <__umoddi3+0x110>
  8022b8:	75 11                	jne    8022cb <__umoddi3+0x11b>
  8022ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022be:	73 0b                	jae    8022cb <__umoddi3+0x11b>
  8022c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022c4:	1b 14 24             	sbb    (%esp),%edx
  8022c7:	89 d1                	mov    %edx,%ecx
  8022c9:	89 c3                	mov    %eax,%ebx
  8022cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022cf:	29 da                	sub    %ebx,%edx
  8022d1:	19 ce                	sbb    %ecx,%esi
  8022d3:	89 f9                	mov    %edi,%ecx
  8022d5:	89 f0                	mov    %esi,%eax
  8022d7:	d3 e0                	shl    %cl,%eax
  8022d9:	89 e9                	mov    %ebp,%ecx
  8022db:	d3 ea                	shr    %cl,%edx
  8022dd:	89 e9                	mov    %ebp,%ecx
  8022df:	d3 ee                	shr    %cl,%esi
  8022e1:	09 d0                	or     %edx,%eax
  8022e3:	89 f2                	mov    %esi,%edx
  8022e5:	83 c4 1c             	add    $0x1c,%esp
  8022e8:	5b                   	pop    %ebx
  8022e9:	5e                   	pop    %esi
  8022ea:	5f                   	pop    %edi
  8022eb:	5d                   	pop    %ebp
  8022ec:	c3                   	ret    
  8022ed:	8d 76 00             	lea    0x0(%esi),%esi
  8022f0:	29 f9                	sub    %edi,%ecx
  8022f2:	19 d6                	sbb    %edx,%esi
  8022f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022fc:	e9 18 ff ff ff       	jmp    802219 <__umoddi3+0x69>
