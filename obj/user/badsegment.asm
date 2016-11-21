
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
  80005b:	a3 04 40 80 00       	mov    %eax,0x804004

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
  80008a:	e8 87 04 00 00       	call   800516 <close_all>
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
  800103:	68 ea 1d 80 00       	push   $0x801dea
  800108:	6a 23                	push   $0x23
  80010a:	68 07 1e 80 00       	push   $0x801e07
  80010f:	e8 4a 0f 00 00       	call   80105e <_panic>

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
  800184:	68 ea 1d 80 00       	push   $0x801dea
  800189:	6a 23                	push   $0x23
  80018b:	68 07 1e 80 00       	push   $0x801e07
  800190:	e8 c9 0e 00 00       	call   80105e <_panic>

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
  8001c6:	68 ea 1d 80 00       	push   $0x801dea
  8001cb:	6a 23                	push   $0x23
  8001cd:	68 07 1e 80 00       	push   $0x801e07
  8001d2:	e8 87 0e 00 00       	call   80105e <_panic>

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
  800208:	68 ea 1d 80 00       	push   $0x801dea
  80020d:	6a 23                	push   $0x23
  80020f:	68 07 1e 80 00       	push   $0x801e07
  800214:	e8 45 0e 00 00       	call   80105e <_panic>

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
  80024a:	68 ea 1d 80 00       	push   $0x801dea
  80024f:	6a 23                	push   $0x23
  800251:	68 07 1e 80 00       	push   $0x801e07
  800256:	e8 03 0e 00 00       	call   80105e <_panic>

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
  80028c:	68 ea 1d 80 00       	push   $0x801dea
  800291:	6a 23                	push   $0x23
  800293:	68 07 1e 80 00       	push   $0x801e07
  800298:	e8 c1 0d 00 00       	call   80105e <_panic>

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
  8002ce:	68 ea 1d 80 00       	push   $0x801dea
  8002d3:	6a 23                	push   $0x23
  8002d5:	68 07 1e 80 00       	push   $0x801e07
  8002da:	e8 7f 0d 00 00       	call   80105e <_panic>

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
  800332:	68 ea 1d 80 00       	push   $0x801dea
  800337:	6a 23                	push   $0x23
  800339:	68 07 1e 80 00       	push   $0x801e07
  80033e:	e8 1b 0d 00 00       	call   80105e <_panic>

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

0080034b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	05 00 00 00 30       	add    $0x30000000,%eax
  800356:	c1 e8 0c             	shr    $0xc,%eax
}
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
  800366:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80036b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800378:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80037d:	89 c2                	mov    %eax,%edx
  80037f:	c1 ea 16             	shr    $0x16,%edx
  800382:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800389:	f6 c2 01             	test   $0x1,%dl
  80038c:	74 11                	je     80039f <fd_alloc+0x2d>
  80038e:	89 c2                	mov    %eax,%edx
  800390:	c1 ea 0c             	shr    $0xc,%edx
  800393:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039a:	f6 c2 01             	test   $0x1,%dl
  80039d:	75 09                	jne    8003a8 <fd_alloc+0x36>
			*fd_store = fd;
  80039f:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a6:	eb 17                	jmp    8003bf <fd_alloc+0x4d>
  8003a8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003ad:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b2:	75 c9                	jne    80037d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ba:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003bf:	5d                   	pop    %ebp
  8003c0:	c3                   	ret    

008003c1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
  8003c4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c7:	83 f8 1f             	cmp    $0x1f,%eax
  8003ca:	77 36                	ja     800402 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003cc:	c1 e0 0c             	shl    $0xc,%eax
  8003cf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d4:	89 c2                	mov    %eax,%edx
  8003d6:	c1 ea 16             	shr    $0x16,%edx
  8003d9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e0:	f6 c2 01             	test   $0x1,%dl
  8003e3:	74 24                	je     800409 <fd_lookup+0x48>
  8003e5:	89 c2                	mov    %eax,%edx
  8003e7:	c1 ea 0c             	shr    $0xc,%edx
  8003ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f1:	f6 c2 01             	test   $0x1,%dl
  8003f4:	74 1a                	je     800410 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f9:	89 02                	mov    %eax,(%edx)
	return 0;
  8003fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800400:	eb 13                	jmp    800415 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800402:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800407:	eb 0c                	jmp    800415 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800409:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040e:	eb 05                	jmp    800415 <fd_lookup+0x54>
  800410:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800415:	5d                   	pop    %ebp
  800416:	c3                   	ret    

00800417 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	83 ec 08             	sub    $0x8,%esp
  80041d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800420:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800425:	eb 13                	jmp    80043a <dev_lookup+0x23>
  800427:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80042a:	39 08                	cmp    %ecx,(%eax)
  80042c:	75 0c                	jne    80043a <dev_lookup+0x23>
			*dev = devtab[i];
  80042e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800431:	89 01                	mov    %eax,(%ecx)
			return 0;
  800433:	b8 00 00 00 00       	mov    $0x0,%eax
  800438:	eb 2e                	jmp    800468 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80043a:	8b 02                	mov    (%edx),%eax
  80043c:	85 c0                	test   %eax,%eax
  80043e:	75 e7                	jne    800427 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800440:	a1 04 40 80 00       	mov    0x804004,%eax
  800445:	8b 40 48             	mov    0x48(%eax),%eax
  800448:	83 ec 04             	sub    $0x4,%esp
  80044b:	51                   	push   %ecx
  80044c:	50                   	push   %eax
  80044d:	68 18 1e 80 00       	push   $0x801e18
  800452:	e8 e0 0c 00 00       	call   801137 <cprintf>
	*dev = 0;
  800457:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800460:	83 c4 10             	add    $0x10,%esp
  800463:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800468:	c9                   	leave  
  800469:	c3                   	ret    

0080046a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
  80046d:	56                   	push   %esi
  80046e:	53                   	push   %ebx
  80046f:	83 ec 10             	sub    $0x10,%esp
  800472:	8b 75 08             	mov    0x8(%ebp),%esi
  800475:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800478:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80047b:	50                   	push   %eax
  80047c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800482:	c1 e8 0c             	shr    $0xc,%eax
  800485:	50                   	push   %eax
  800486:	e8 36 ff ff ff       	call   8003c1 <fd_lookup>
  80048b:	83 c4 08             	add    $0x8,%esp
  80048e:	85 c0                	test   %eax,%eax
  800490:	78 05                	js     800497 <fd_close+0x2d>
	    || fd != fd2)
  800492:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800495:	74 0c                	je     8004a3 <fd_close+0x39>
		return (must_exist ? r : 0);
  800497:	84 db                	test   %bl,%bl
  800499:	ba 00 00 00 00       	mov    $0x0,%edx
  80049e:	0f 44 c2             	cmove  %edx,%eax
  8004a1:	eb 41                	jmp    8004e4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a9:	50                   	push   %eax
  8004aa:	ff 36                	pushl  (%esi)
  8004ac:	e8 66 ff ff ff       	call   800417 <dev_lookup>
  8004b1:	89 c3                	mov    %eax,%ebx
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	85 c0                	test   %eax,%eax
  8004b8:	78 1a                	js     8004d4 <fd_close+0x6a>
		if (dev->dev_close)
  8004ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004bd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c5:	85 c0                	test   %eax,%eax
  8004c7:	74 0b                	je     8004d4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c9:	83 ec 0c             	sub    $0xc,%esp
  8004cc:	56                   	push   %esi
  8004cd:	ff d0                	call   *%eax
  8004cf:	89 c3                	mov    %eax,%ebx
  8004d1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	56                   	push   %esi
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 00 fd ff ff       	call   8001df <sys_page_unmap>
	return r;
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	89 d8                	mov    %ebx,%eax
}
  8004e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e7:	5b                   	pop    %ebx
  8004e8:	5e                   	pop    %esi
  8004e9:	5d                   	pop    %ebp
  8004ea:	c3                   	ret    

008004eb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f4:	50                   	push   %eax
  8004f5:	ff 75 08             	pushl  0x8(%ebp)
  8004f8:	e8 c4 fe ff ff       	call   8003c1 <fd_lookup>
  8004fd:	83 c4 08             	add    $0x8,%esp
  800500:	85 c0                	test   %eax,%eax
  800502:	78 10                	js     800514 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	6a 01                	push   $0x1
  800509:	ff 75 f4             	pushl  -0xc(%ebp)
  80050c:	e8 59 ff ff ff       	call   80046a <fd_close>
  800511:	83 c4 10             	add    $0x10,%esp
}
  800514:	c9                   	leave  
  800515:	c3                   	ret    

00800516 <close_all>:

void
close_all(void)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	53                   	push   %ebx
  80051a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80051d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800522:	83 ec 0c             	sub    $0xc,%esp
  800525:	53                   	push   %ebx
  800526:	e8 c0 ff ff ff       	call   8004eb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80052b:	83 c3 01             	add    $0x1,%ebx
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	83 fb 20             	cmp    $0x20,%ebx
  800534:	75 ec                	jne    800522 <close_all+0xc>
		close(i);
}
  800536:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800539:	c9                   	leave  
  80053a:	c3                   	ret    

0080053b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80053b:	55                   	push   %ebp
  80053c:	89 e5                	mov    %esp,%ebp
  80053e:	57                   	push   %edi
  80053f:	56                   	push   %esi
  800540:	53                   	push   %ebx
  800541:	83 ec 2c             	sub    $0x2c,%esp
  800544:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800547:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054a:	50                   	push   %eax
  80054b:	ff 75 08             	pushl  0x8(%ebp)
  80054e:	e8 6e fe ff ff       	call   8003c1 <fd_lookup>
  800553:	83 c4 08             	add    $0x8,%esp
  800556:	85 c0                	test   %eax,%eax
  800558:	0f 88 c1 00 00 00    	js     80061f <dup+0xe4>
		return r;
	close(newfdnum);
  80055e:	83 ec 0c             	sub    $0xc,%esp
  800561:	56                   	push   %esi
  800562:	e8 84 ff ff ff       	call   8004eb <close>

	newfd = INDEX2FD(newfdnum);
  800567:	89 f3                	mov    %esi,%ebx
  800569:	c1 e3 0c             	shl    $0xc,%ebx
  80056c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800572:	83 c4 04             	add    $0x4,%esp
  800575:	ff 75 e4             	pushl  -0x1c(%ebp)
  800578:	e8 de fd ff ff       	call   80035b <fd2data>
  80057d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057f:	89 1c 24             	mov    %ebx,(%esp)
  800582:	e8 d4 fd ff ff       	call   80035b <fd2data>
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80058d:	89 f8                	mov    %edi,%eax
  80058f:	c1 e8 16             	shr    $0x16,%eax
  800592:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800599:	a8 01                	test   $0x1,%al
  80059b:	74 37                	je     8005d4 <dup+0x99>
  80059d:	89 f8                	mov    %edi,%eax
  80059f:	c1 e8 0c             	shr    $0xc,%eax
  8005a2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a9:	f6 c2 01             	test   $0x1,%dl
  8005ac:	74 26                	je     8005d4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b5:	83 ec 0c             	sub    $0xc,%esp
  8005b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005bd:	50                   	push   %eax
  8005be:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005c1:	6a 00                	push   $0x0
  8005c3:	57                   	push   %edi
  8005c4:	6a 00                	push   $0x0
  8005c6:	e8 d2 fb ff ff       	call   80019d <sys_page_map>
  8005cb:	89 c7                	mov    %eax,%edi
  8005cd:	83 c4 20             	add    $0x20,%esp
  8005d0:	85 c0                	test   %eax,%eax
  8005d2:	78 2e                	js     800602 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d7:	89 d0                	mov    %edx,%eax
  8005d9:	c1 e8 0c             	shr    $0xc,%eax
  8005dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005eb:	50                   	push   %eax
  8005ec:	53                   	push   %ebx
  8005ed:	6a 00                	push   $0x0
  8005ef:	52                   	push   %edx
  8005f0:	6a 00                	push   $0x0
  8005f2:	e8 a6 fb ff ff       	call   80019d <sys_page_map>
  8005f7:	89 c7                	mov    %eax,%edi
  8005f9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005fc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fe:	85 ff                	test   %edi,%edi
  800600:	79 1d                	jns    80061f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	53                   	push   %ebx
  800606:	6a 00                	push   $0x0
  800608:	e8 d2 fb ff ff       	call   8001df <sys_page_unmap>
	sys_page_unmap(0, nva);
  80060d:	83 c4 08             	add    $0x8,%esp
  800610:	ff 75 d4             	pushl  -0x2c(%ebp)
  800613:	6a 00                	push   $0x0
  800615:	e8 c5 fb ff ff       	call   8001df <sys_page_unmap>
	return r;
  80061a:	83 c4 10             	add    $0x10,%esp
  80061d:	89 f8                	mov    %edi,%eax
}
  80061f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800622:	5b                   	pop    %ebx
  800623:	5e                   	pop    %esi
  800624:	5f                   	pop    %edi
  800625:	5d                   	pop    %ebp
  800626:	c3                   	ret    

00800627 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800627:	55                   	push   %ebp
  800628:	89 e5                	mov    %esp,%ebp
  80062a:	53                   	push   %ebx
  80062b:	83 ec 14             	sub    $0x14,%esp
  80062e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800631:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800634:	50                   	push   %eax
  800635:	53                   	push   %ebx
  800636:	e8 86 fd ff ff       	call   8003c1 <fd_lookup>
  80063b:	83 c4 08             	add    $0x8,%esp
  80063e:	89 c2                	mov    %eax,%edx
  800640:	85 c0                	test   %eax,%eax
  800642:	78 6d                	js     8006b1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064a:	50                   	push   %eax
  80064b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064e:	ff 30                	pushl  (%eax)
  800650:	e8 c2 fd ff ff       	call   800417 <dev_lookup>
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	85 c0                	test   %eax,%eax
  80065a:	78 4c                	js     8006a8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80065c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065f:	8b 42 08             	mov    0x8(%edx),%eax
  800662:	83 e0 03             	and    $0x3,%eax
  800665:	83 f8 01             	cmp    $0x1,%eax
  800668:	75 21                	jne    80068b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80066a:	a1 04 40 80 00       	mov    0x804004,%eax
  80066f:	8b 40 48             	mov    0x48(%eax),%eax
  800672:	83 ec 04             	sub    $0x4,%esp
  800675:	53                   	push   %ebx
  800676:	50                   	push   %eax
  800677:	68 59 1e 80 00       	push   $0x801e59
  80067c:	e8 b6 0a 00 00       	call   801137 <cprintf>
		return -E_INVAL;
  800681:	83 c4 10             	add    $0x10,%esp
  800684:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800689:	eb 26                	jmp    8006b1 <read+0x8a>
	}
	if (!dev->dev_read)
  80068b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068e:	8b 40 08             	mov    0x8(%eax),%eax
  800691:	85 c0                	test   %eax,%eax
  800693:	74 17                	je     8006ac <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800695:	83 ec 04             	sub    $0x4,%esp
  800698:	ff 75 10             	pushl  0x10(%ebp)
  80069b:	ff 75 0c             	pushl  0xc(%ebp)
  80069e:	52                   	push   %edx
  80069f:	ff d0                	call   *%eax
  8006a1:	89 c2                	mov    %eax,%edx
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	eb 09                	jmp    8006b1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a8:	89 c2                	mov    %eax,%edx
  8006aa:	eb 05                	jmp    8006b1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006b1:	89 d0                	mov    %edx,%eax
  8006b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b6:	c9                   	leave  
  8006b7:	c3                   	ret    

008006b8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	57                   	push   %edi
  8006bc:	56                   	push   %esi
  8006bd:	53                   	push   %ebx
  8006be:	83 ec 0c             	sub    $0xc,%esp
  8006c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006cc:	eb 21                	jmp    8006ef <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ce:	83 ec 04             	sub    $0x4,%esp
  8006d1:	89 f0                	mov    %esi,%eax
  8006d3:	29 d8                	sub    %ebx,%eax
  8006d5:	50                   	push   %eax
  8006d6:	89 d8                	mov    %ebx,%eax
  8006d8:	03 45 0c             	add    0xc(%ebp),%eax
  8006db:	50                   	push   %eax
  8006dc:	57                   	push   %edi
  8006dd:	e8 45 ff ff ff       	call   800627 <read>
		if (m < 0)
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	78 10                	js     8006f9 <readn+0x41>
			return m;
		if (m == 0)
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	74 0a                	je     8006f7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ed:	01 c3                	add    %eax,%ebx
  8006ef:	39 f3                	cmp    %esi,%ebx
  8006f1:	72 db                	jb     8006ce <readn+0x16>
  8006f3:	89 d8                	mov    %ebx,%eax
  8006f5:	eb 02                	jmp    8006f9 <readn+0x41>
  8006f7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fc:	5b                   	pop    %ebx
  8006fd:	5e                   	pop    %esi
  8006fe:	5f                   	pop    %edi
  8006ff:	5d                   	pop    %ebp
  800700:	c3                   	ret    

00800701 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	53                   	push   %ebx
  800705:	83 ec 14             	sub    $0x14,%esp
  800708:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070e:	50                   	push   %eax
  80070f:	53                   	push   %ebx
  800710:	e8 ac fc ff ff       	call   8003c1 <fd_lookup>
  800715:	83 c4 08             	add    $0x8,%esp
  800718:	89 c2                	mov    %eax,%edx
  80071a:	85 c0                	test   %eax,%eax
  80071c:	78 68                	js     800786 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800724:	50                   	push   %eax
  800725:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800728:	ff 30                	pushl  (%eax)
  80072a:	e8 e8 fc ff ff       	call   800417 <dev_lookup>
  80072f:	83 c4 10             	add    $0x10,%esp
  800732:	85 c0                	test   %eax,%eax
  800734:	78 47                	js     80077d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800736:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800739:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80073d:	75 21                	jne    800760 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073f:	a1 04 40 80 00       	mov    0x804004,%eax
  800744:	8b 40 48             	mov    0x48(%eax),%eax
  800747:	83 ec 04             	sub    $0x4,%esp
  80074a:	53                   	push   %ebx
  80074b:	50                   	push   %eax
  80074c:	68 75 1e 80 00       	push   $0x801e75
  800751:	e8 e1 09 00 00       	call   801137 <cprintf>
		return -E_INVAL;
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80075e:	eb 26                	jmp    800786 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800760:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800763:	8b 52 0c             	mov    0xc(%edx),%edx
  800766:	85 d2                	test   %edx,%edx
  800768:	74 17                	je     800781 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80076a:	83 ec 04             	sub    $0x4,%esp
  80076d:	ff 75 10             	pushl  0x10(%ebp)
  800770:	ff 75 0c             	pushl  0xc(%ebp)
  800773:	50                   	push   %eax
  800774:	ff d2                	call   *%edx
  800776:	89 c2                	mov    %eax,%edx
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	eb 09                	jmp    800786 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80077d:	89 c2                	mov    %eax,%edx
  80077f:	eb 05                	jmp    800786 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800781:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800786:	89 d0                	mov    %edx,%eax
  800788:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    

0080078d <seek>:

int
seek(int fdnum, off_t offset)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800793:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800796:	50                   	push   %eax
  800797:	ff 75 08             	pushl  0x8(%ebp)
  80079a:	e8 22 fc ff ff       	call   8003c1 <fd_lookup>
  80079f:	83 c4 08             	add    $0x8,%esp
  8007a2:	85 c0                	test   %eax,%eax
  8007a4:	78 0e                	js     8007b4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ac:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    

008007b6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	83 ec 14             	sub    $0x14,%esp
  8007bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c3:	50                   	push   %eax
  8007c4:	53                   	push   %ebx
  8007c5:	e8 f7 fb ff ff       	call   8003c1 <fd_lookup>
  8007ca:	83 c4 08             	add    $0x8,%esp
  8007cd:	89 c2                	mov    %eax,%edx
  8007cf:	85 c0                	test   %eax,%eax
  8007d1:	78 65                	js     800838 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d3:	83 ec 08             	sub    $0x8,%esp
  8007d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d9:	50                   	push   %eax
  8007da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007dd:	ff 30                	pushl  (%eax)
  8007df:	e8 33 fc ff ff       	call   800417 <dev_lookup>
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	85 c0                	test   %eax,%eax
  8007e9:	78 44                	js     80082f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ee:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f2:	75 21                	jne    800815 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f4:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f9:	8b 40 48             	mov    0x48(%eax),%eax
  8007fc:	83 ec 04             	sub    $0x4,%esp
  8007ff:	53                   	push   %ebx
  800800:	50                   	push   %eax
  800801:	68 38 1e 80 00       	push   $0x801e38
  800806:	e8 2c 09 00 00       	call   801137 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800813:	eb 23                	jmp    800838 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800815:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800818:	8b 52 18             	mov    0x18(%edx),%edx
  80081b:	85 d2                	test   %edx,%edx
  80081d:	74 14                	je     800833 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	ff 75 0c             	pushl  0xc(%ebp)
  800825:	50                   	push   %eax
  800826:	ff d2                	call   *%edx
  800828:	89 c2                	mov    %eax,%edx
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	eb 09                	jmp    800838 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082f:	89 c2                	mov    %eax,%edx
  800831:	eb 05                	jmp    800838 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800833:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800838:	89 d0                	mov    %edx,%eax
  80083a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083d:	c9                   	leave  
  80083e:	c3                   	ret    

0080083f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	53                   	push   %ebx
  800843:	83 ec 14             	sub    $0x14,%esp
  800846:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800849:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80084c:	50                   	push   %eax
  80084d:	ff 75 08             	pushl  0x8(%ebp)
  800850:	e8 6c fb ff ff       	call   8003c1 <fd_lookup>
  800855:	83 c4 08             	add    $0x8,%esp
  800858:	89 c2                	mov    %eax,%edx
  80085a:	85 c0                	test   %eax,%eax
  80085c:	78 58                	js     8008b6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085e:	83 ec 08             	sub    $0x8,%esp
  800861:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800864:	50                   	push   %eax
  800865:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800868:	ff 30                	pushl  (%eax)
  80086a:	e8 a8 fb ff ff       	call   800417 <dev_lookup>
  80086f:	83 c4 10             	add    $0x10,%esp
  800872:	85 c0                	test   %eax,%eax
  800874:	78 37                	js     8008ad <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800876:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800879:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80087d:	74 32                	je     8008b1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800882:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800889:	00 00 00 
	stat->st_isdir = 0;
  80088c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800893:	00 00 00 
	stat->st_dev = dev;
  800896:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80089c:	83 ec 08             	sub    $0x8,%esp
  80089f:	53                   	push   %ebx
  8008a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8008a3:	ff 50 14             	call   *0x14(%eax)
  8008a6:	89 c2                	mov    %eax,%edx
  8008a8:	83 c4 10             	add    $0x10,%esp
  8008ab:	eb 09                	jmp    8008b6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ad:	89 c2                	mov    %eax,%edx
  8008af:	eb 05                	jmp    8008b6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b6:	89 d0                	mov    %edx,%eax
  8008b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	56                   	push   %esi
  8008c1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008c2:	83 ec 08             	sub    $0x8,%esp
  8008c5:	6a 00                	push   $0x0
  8008c7:	ff 75 08             	pushl  0x8(%ebp)
  8008ca:	e8 0c 02 00 00       	call   800adb <open>
  8008cf:	89 c3                	mov    %eax,%ebx
  8008d1:	83 c4 10             	add    $0x10,%esp
  8008d4:	85 c0                	test   %eax,%eax
  8008d6:	78 1b                	js     8008f3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d8:	83 ec 08             	sub    $0x8,%esp
  8008db:	ff 75 0c             	pushl  0xc(%ebp)
  8008de:	50                   	push   %eax
  8008df:	e8 5b ff ff ff       	call   80083f <fstat>
  8008e4:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e6:	89 1c 24             	mov    %ebx,(%esp)
  8008e9:	e8 fd fb ff ff       	call   8004eb <close>
	return r;
  8008ee:	83 c4 10             	add    $0x10,%esp
  8008f1:	89 f0                	mov    %esi,%eax
}
  8008f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f6:	5b                   	pop    %ebx
  8008f7:	5e                   	pop    %esi
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	56                   	push   %esi
  8008fe:	53                   	push   %ebx
  8008ff:	89 c6                	mov    %eax,%esi
  800901:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800903:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80090a:	75 12                	jne    80091e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80090c:	83 ec 0c             	sub    $0xc,%esp
  80090f:	6a 01                	push   $0x1
  800911:	e8 aa 11 00 00       	call   801ac0 <ipc_find_env>
  800916:	a3 00 40 80 00       	mov    %eax,0x804000
  80091b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80091e:	6a 07                	push   $0x7
  800920:	68 00 50 80 00       	push   $0x805000
  800925:	56                   	push   %esi
  800926:	ff 35 00 40 80 00    	pushl  0x804000
  80092c:	e8 3b 11 00 00       	call   801a6c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800931:	83 c4 0c             	add    $0xc,%esp
  800934:	6a 00                	push   $0x0
  800936:	53                   	push   %ebx
  800937:	6a 00                	push   $0x0
  800939:	e8 c5 10 00 00       	call   801a03 <ipc_recv>
}
  80093e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800941:	5b                   	pop    %ebx
  800942:	5e                   	pop    %esi
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 40 0c             	mov    0xc(%eax),%eax
  800951:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800956:	8b 45 0c             	mov    0xc(%ebp),%eax
  800959:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80095e:	ba 00 00 00 00       	mov    $0x0,%edx
  800963:	b8 02 00 00 00       	mov    $0x2,%eax
  800968:	e8 8d ff ff ff       	call   8008fa <fsipc>
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8b 40 0c             	mov    0xc(%eax),%eax
  80097b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800980:	ba 00 00 00 00       	mov    $0x0,%edx
  800985:	b8 06 00 00 00       	mov    $0x6,%eax
  80098a:	e8 6b ff ff ff       	call   8008fa <fsipc>
}
  80098f:	c9                   	leave  
  800990:	c3                   	ret    

00800991 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	53                   	push   %ebx
  800995:	83 ec 04             	sub    $0x4,%esp
  800998:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ab:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b0:	e8 45 ff ff ff       	call   8008fa <fsipc>
  8009b5:	85 c0                	test   %eax,%eax
  8009b7:	78 2c                	js     8009e5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b9:	83 ec 08             	sub    $0x8,%esp
  8009bc:	68 00 50 80 00       	push   $0x805000
  8009c1:	53                   	push   %ebx
  8009c2:	e8 f5 0c 00 00       	call   8016bc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c7:	a1 80 50 80 00       	mov    0x805080,%eax
  8009cc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009d2:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009dd:	83 c4 10             	add    $0x10,%esp
  8009e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    

008009ea <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	53                   	push   %ebx
  8009ee:	83 ec 08             	sub    $0x8,%esp
  8009f1:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here

	// Build up arguments of the write request
	// The file to write is stored in the request req_fileid
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f7:	8b 52 0c             	mov    0xc(%edx),%edx
  8009fa:	89 15 00 50 80 00    	mov    %edx,0x805000
  800a00:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a05:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a0a:	0f 46 d8             	cmovbe %eax,%ebx
	// The size is capped to the size of the request buffer
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  800a0d:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	// The data to write is stored in the request buffer
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  800a13:	53                   	push   %ebx
  800a14:	ff 75 0c             	pushl  0xc(%ebp)
  800a17:	68 08 50 80 00       	push   $0x805008
  800a1c:	e8 2d 0e 00 00       	call   80184e <memmove>

	// Send request via fsipc
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) // Error occurred
  800a21:	ba 00 00 00 00       	mov    $0x0,%edx
  800a26:	b8 04 00 00 00       	mov    $0x4,%eax
  800a2b:	e8 ca fe ff ff       	call   8008fa <fsipc>
  800a30:	83 c4 10             	add    $0x10,%esp
  800a33:	85 c0                	test   %eax,%eax
  800a35:	78 1d                	js     800a54 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); // Number of bytes written should be <= n_real
  800a37:	39 d8                	cmp    %ebx,%eax
  800a39:	76 19                	jbe    800a54 <devfile_write+0x6a>
  800a3b:	68 a4 1e 80 00       	push   $0x801ea4
  800a40:	68 b0 1e 80 00       	push   $0x801eb0
  800a45:	68 a5 00 00 00       	push   $0xa5
  800a4a:	68 c5 1e 80 00       	push   $0x801ec5
  800a4f:	e8 0a 06 00 00       	call   80105e <_panic>
	return r;
}
  800a54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a57:	c9                   	leave  
  800a58:	c3                   	ret    

00800a59 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	56                   	push   %esi
  800a5d:	53                   	push   %ebx
  800a5e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a61:	8b 45 08             	mov    0x8(%ebp),%eax
  800a64:	8b 40 0c             	mov    0xc(%eax),%eax
  800a67:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a6c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a72:	ba 00 00 00 00       	mov    $0x0,%edx
  800a77:	b8 03 00 00 00       	mov    $0x3,%eax
  800a7c:	e8 79 fe ff ff       	call   8008fa <fsipc>
  800a81:	89 c3                	mov    %eax,%ebx
  800a83:	85 c0                	test   %eax,%eax
  800a85:	78 4b                	js     800ad2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a87:	39 c6                	cmp    %eax,%esi
  800a89:	73 16                	jae    800aa1 <devfile_read+0x48>
  800a8b:	68 d0 1e 80 00       	push   $0x801ed0
  800a90:	68 b0 1e 80 00       	push   $0x801eb0
  800a95:	6a 7c                	push   $0x7c
  800a97:	68 c5 1e 80 00       	push   $0x801ec5
  800a9c:	e8 bd 05 00 00       	call   80105e <_panic>
	assert(r <= PGSIZE);
  800aa1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aa6:	7e 16                	jle    800abe <devfile_read+0x65>
  800aa8:	68 d7 1e 80 00       	push   $0x801ed7
  800aad:	68 b0 1e 80 00       	push   $0x801eb0
  800ab2:	6a 7d                	push   $0x7d
  800ab4:	68 c5 1e 80 00       	push   $0x801ec5
  800ab9:	e8 a0 05 00 00       	call   80105e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800abe:	83 ec 04             	sub    $0x4,%esp
  800ac1:	50                   	push   %eax
  800ac2:	68 00 50 80 00       	push   $0x805000
  800ac7:	ff 75 0c             	pushl  0xc(%ebp)
  800aca:	e8 7f 0d 00 00       	call   80184e <memmove>
	return r;
  800acf:	83 c4 10             	add    $0x10,%esp
}
  800ad2:	89 d8                	mov    %ebx,%eax
  800ad4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	53                   	push   %ebx
  800adf:	83 ec 20             	sub    $0x20,%esp
  800ae2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ae5:	53                   	push   %ebx
  800ae6:	e8 98 0b 00 00       	call   801683 <strlen>
  800aeb:	83 c4 10             	add    $0x10,%esp
  800aee:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800af3:	7f 67                	jg     800b5c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800af5:	83 ec 0c             	sub    $0xc,%esp
  800af8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800afb:	50                   	push   %eax
  800afc:	e8 71 f8 ff ff       	call   800372 <fd_alloc>
  800b01:	83 c4 10             	add    $0x10,%esp
		return r;
  800b04:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b06:	85 c0                	test   %eax,%eax
  800b08:	78 57                	js     800b61 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b0a:	83 ec 08             	sub    $0x8,%esp
  800b0d:	53                   	push   %ebx
  800b0e:	68 00 50 80 00       	push   $0x805000
  800b13:	e8 a4 0b 00 00       	call   8016bc <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b20:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b23:	b8 01 00 00 00       	mov    $0x1,%eax
  800b28:	e8 cd fd ff ff       	call   8008fa <fsipc>
  800b2d:	89 c3                	mov    %eax,%ebx
  800b2f:	83 c4 10             	add    $0x10,%esp
  800b32:	85 c0                	test   %eax,%eax
  800b34:	79 14                	jns    800b4a <open+0x6f>
		fd_close(fd, 0);
  800b36:	83 ec 08             	sub    $0x8,%esp
  800b39:	6a 00                	push   $0x0
  800b3b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b3e:	e8 27 f9 ff ff       	call   80046a <fd_close>
		return r;
  800b43:	83 c4 10             	add    $0x10,%esp
  800b46:	89 da                	mov    %ebx,%edx
  800b48:	eb 17                	jmp    800b61 <open+0x86>
	}

	return fd2num(fd);
  800b4a:	83 ec 0c             	sub    $0xc,%esp
  800b4d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b50:	e8 f6 f7 ff ff       	call   80034b <fd2num>
  800b55:	89 c2                	mov    %eax,%edx
  800b57:	83 c4 10             	add    $0x10,%esp
  800b5a:	eb 05                	jmp    800b61 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b5c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b61:	89 d0                	mov    %edx,%eax
  800b63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b66:	c9                   	leave  
  800b67:	c3                   	ret    

00800b68 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b73:	b8 08 00 00 00       	mov    $0x8,%eax
  800b78:	e8 7d fd ff ff       	call   8008fa <fsipc>
}
  800b7d:	c9                   	leave  
  800b7e:	c3                   	ret    

00800b7f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
  800b84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b87:	83 ec 0c             	sub    $0xc,%esp
  800b8a:	ff 75 08             	pushl  0x8(%ebp)
  800b8d:	e8 c9 f7 ff ff       	call   80035b <fd2data>
  800b92:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b94:	83 c4 08             	add    $0x8,%esp
  800b97:	68 e3 1e 80 00       	push   $0x801ee3
  800b9c:	53                   	push   %ebx
  800b9d:	e8 1a 0b 00 00       	call   8016bc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ba2:	8b 46 04             	mov    0x4(%esi),%eax
  800ba5:	2b 06                	sub    (%esi),%eax
  800ba7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bad:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bb4:	00 00 00 
	stat->st_dev = &devpipe;
  800bb7:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bbe:	30 80 00 
	return 0;
}
  800bc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	53                   	push   %ebx
  800bd1:	83 ec 0c             	sub    $0xc,%esp
  800bd4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bd7:	53                   	push   %ebx
  800bd8:	6a 00                	push   $0x0
  800bda:	e8 00 f6 ff ff       	call   8001df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bdf:	89 1c 24             	mov    %ebx,(%esp)
  800be2:	e8 74 f7 ff ff       	call   80035b <fd2data>
  800be7:	83 c4 08             	add    $0x8,%esp
  800bea:	50                   	push   %eax
  800beb:	6a 00                	push   $0x0
  800bed:	e8 ed f5 ff ff       	call   8001df <sys_page_unmap>
}
  800bf2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf5:	c9                   	leave  
  800bf6:	c3                   	ret    

00800bf7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	83 ec 1c             	sub    $0x1c,%esp
  800c00:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c03:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c05:	a1 04 40 80 00       	mov    0x804004,%eax
  800c0a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c0d:	83 ec 0c             	sub    $0xc,%esp
  800c10:	ff 75 e0             	pushl  -0x20(%ebp)
  800c13:	e8 e1 0e 00 00       	call   801af9 <pageref>
  800c18:	89 c3                	mov    %eax,%ebx
  800c1a:	89 3c 24             	mov    %edi,(%esp)
  800c1d:	e8 d7 0e 00 00       	call   801af9 <pageref>
  800c22:	83 c4 10             	add    $0x10,%esp
  800c25:	39 c3                	cmp    %eax,%ebx
  800c27:	0f 94 c1             	sete   %cl
  800c2a:	0f b6 c9             	movzbl %cl,%ecx
  800c2d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c30:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c36:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c39:	39 ce                	cmp    %ecx,%esi
  800c3b:	74 1b                	je     800c58 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c3d:	39 c3                	cmp    %eax,%ebx
  800c3f:	75 c4                	jne    800c05 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c41:	8b 42 58             	mov    0x58(%edx),%eax
  800c44:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c47:	50                   	push   %eax
  800c48:	56                   	push   %esi
  800c49:	68 ea 1e 80 00       	push   $0x801eea
  800c4e:	e8 e4 04 00 00       	call   801137 <cprintf>
  800c53:	83 c4 10             	add    $0x10,%esp
  800c56:	eb ad                	jmp    800c05 <_pipeisclosed+0xe>
	}
}
  800c58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	83 ec 28             	sub    $0x28,%esp
  800c6c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c6f:	56                   	push   %esi
  800c70:	e8 e6 f6 ff ff       	call   80035b <fd2data>
  800c75:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c77:	83 c4 10             	add    $0x10,%esp
  800c7a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7f:	eb 4b                	jmp    800ccc <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c81:	89 da                	mov    %ebx,%edx
  800c83:	89 f0                	mov    %esi,%eax
  800c85:	e8 6d ff ff ff       	call   800bf7 <_pipeisclosed>
  800c8a:	85 c0                	test   %eax,%eax
  800c8c:	75 48                	jne    800cd6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c8e:	e8 a8 f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c93:	8b 43 04             	mov    0x4(%ebx),%eax
  800c96:	8b 0b                	mov    (%ebx),%ecx
  800c98:	8d 51 20             	lea    0x20(%ecx),%edx
  800c9b:	39 d0                	cmp    %edx,%eax
  800c9d:	73 e2                	jae    800c81 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ca6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ca9:	89 c2                	mov    %eax,%edx
  800cab:	c1 fa 1f             	sar    $0x1f,%edx
  800cae:	89 d1                	mov    %edx,%ecx
  800cb0:	c1 e9 1b             	shr    $0x1b,%ecx
  800cb3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cb6:	83 e2 1f             	and    $0x1f,%edx
  800cb9:	29 ca                	sub    %ecx,%edx
  800cbb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cbf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cc3:	83 c0 01             	add    $0x1,%eax
  800cc6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc9:	83 c7 01             	add    $0x1,%edi
  800ccc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ccf:	75 c2                	jne    800c93 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cd1:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd4:	eb 05                	jmp    800cdb <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cd6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    

00800ce3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	57                   	push   %edi
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
  800ce9:	83 ec 18             	sub    $0x18,%esp
  800cec:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cef:	57                   	push   %edi
  800cf0:	e8 66 f6 ff ff       	call   80035b <fd2data>
  800cf5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf7:	83 c4 10             	add    $0x10,%esp
  800cfa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cff:	eb 3d                	jmp    800d3e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d01:	85 db                	test   %ebx,%ebx
  800d03:	74 04                	je     800d09 <devpipe_read+0x26>
				return i;
  800d05:	89 d8                	mov    %ebx,%eax
  800d07:	eb 44                	jmp    800d4d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d09:	89 f2                	mov    %esi,%edx
  800d0b:	89 f8                	mov    %edi,%eax
  800d0d:	e8 e5 fe ff ff       	call   800bf7 <_pipeisclosed>
  800d12:	85 c0                	test   %eax,%eax
  800d14:	75 32                	jne    800d48 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d16:	e8 20 f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d1b:	8b 06                	mov    (%esi),%eax
  800d1d:	3b 46 04             	cmp    0x4(%esi),%eax
  800d20:	74 df                	je     800d01 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d22:	99                   	cltd   
  800d23:	c1 ea 1b             	shr    $0x1b,%edx
  800d26:	01 d0                	add    %edx,%eax
  800d28:	83 e0 1f             	and    $0x1f,%eax
  800d2b:	29 d0                	sub    %edx,%eax
  800d2d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d35:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d38:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d3b:	83 c3 01             	add    $0x1,%ebx
  800d3e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d41:	75 d8                	jne    800d1b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d43:	8b 45 10             	mov    0x10(%ebp),%eax
  800d46:	eb 05                	jmp    800d4d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d48:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d60:	50                   	push   %eax
  800d61:	e8 0c f6 ff ff       	call   800372 <fd_alloc>
  800d66:	83 c4 10             	add    $0x10,%esp
  800d69:	89 c2                	mov    %eax,%edx
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	0f 88 2c 01 00 00    	js     800e9f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d73:	83 ec 04             	sub    $0x4,%esp
  800d76:	68 07 04 00 00       	push   $0x407
  800d7b:	ff 75 f4             	pushl  -0xc(%ebp)
  800d7e:	6a 00                	push   $0x0
  800d80:	e8 d5 f3 ff ff       	call   80015a <sys_page_alloc>
  800d85:	83 c4 10             	add    $0x10,%esp
  800d88:	89 c2                	mov    %eax,%edx
  800d8a:	85 c0                	test   %eax,%eax
  800d8c:	0f 88 0d 01 00 00    	js     800e9f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d92:	83 ec 0c             	sub    $0xc,%esp
  800d95:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d98:	50                   	push   %eax
  800d99:	e8 d4 f5 ff ff       	call   800372 <fd_alloc>
  800d9e:	89 c3                	mov    %eax,%ebx
  800da0:	83 c4 10             	add    $0x10,%esp
  800da3:	85 c0                	test   %eax,%eax
  800da5:	0f 88 e2 00 00 00    	js     800e8d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dab:	83 ec 04             	sub    $0x4,%esp
  800dae:	68 07 04 00 00       	push   $0x407
  800db3:	ff 75 f0             	pushl  -0x10(%ebp)
  800db6:	6a 00                	push   $0x0
  800db8:	e8 9d f3 ff ff       	call   80015a <sys_page_alloc>
  800dbd:	89 c3                	mov    %eax,%ebx
  800dbf:	83 c4 10             	add    $0x10,%esp
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	0f 88 c3 00 00 00    	js     800e8d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dca:	83 ec 0c             	sub    $0xc,%esp
  800dcd:	ff 75 f4             	pushl  -0xc(%ebp)
  800dd0:	e8 86 f5 ff ff       	call   80035b <fd2data>
  800dd5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd7:	83 c4 0c             	add    $0xc,%esp
  800dda:	68 07 04 00 00       	push   $0x407
  800ddf:	50                   	push   %eax
  800de0:	6a 00                	push   $0x0
  800de2:	e8 73 f3 ff ff       	call   80015a <sys_page_alloc>
  800de7:	89 c3                	mov    %eax,%ebx
  800de9:	83 c4 10             	add    $0x10,%esp
  800dec:	85 c0                	test   %eax,%eax
  800dee:	0f 88 89 00 00 00    	js     800e7d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df4:	83 ec 0c             	sub    $0xc,%esp
  800df7:	ff 75 f0             	pushl  -0x10(%ebp)
  800dfa:	e8 5c f5 ff ff       	call   80035b <fd2data>
  800dff:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e06:	50                   	push   %eax
  800e07:	6a 00                	push   $0x0
  800e09:	56                   	push   %esi
  800e0a:	6a 00                	push   $0x0
  800e0c:	e8 8c f3 ff ff       	call   80019d <sys_page_map>
  800e11:	89 c3                	mov    %eax,%ebx
  800e13:	83 c4 20             	add    $0x20,%esp
  800e16:	85 c0                	test   %eax,%eax
  800e18:	78 55                	js     800e6f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e1a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e23:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e28:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e2f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e38:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e3d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e44:	83 ec 0c             	sub    $0xc,%esp
  800e47:	ff 75 f4             	pushl  -0xc(%ebp)
  800e4a:	e8 fc f4 ff ff       	call   80034b <fd2num>
  800e4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e52:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e54:	83 c4 04             	add    $0x4,%esp
  800e57:	ff 75 f0             	pushl  -0x10(%ebp)
  800e5a:	e8 ec f4 ff ff       	call   80034b <fd2num>
  800e5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e62:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e65:	83 c4 10             	add    $0x10,%esp
  800e68:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6d:	eb 30                	jmp    800e9f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e6f:	83 ec 08             	sub    $0x8,%esp
  800e72:	56                   	push   %esi
  800e73:	6a 00                	push   $0x0
  800e75:	e8 65 f3 ff ff       	call   8001df <sys_page_unmap>
  800e7a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e7d:	83 ec 08             	sub    $0x8,%esp
  800e80:	ff 75 f0             	pushl  -0x10(%ebp)
  800e83:	6a 00                	push   $0x0
  800e85:	e8 55 f3 ff ff       	call   8001df <sys_page_unmap>
  800e8a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e8d:	83 ec 08             	sub    $0x8,%esp
  800e90:	ff 75 f4             	pushl  -0xc(%ebp)
  800e93:	6a 00                	push   $0x0
  800e95:	e8 45 f3 ff ff       	call   8001df <sys_page_unmap>
  800e9a:	83 c4 10             	add    $0x10,%esp
  800e9d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e9f:	89 d0                	mov    %edx,%eax
  800ea1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    

00800ea8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb1:	50                   	push   %eax
  800eb2:	ff 75 08             	pushl  0x8(%ebp)
  800eb5:	e8 07 f5 ff ff       	call   8003c1 <fd_lookup>
  800eba:	83 c4 10             	add    $0x10,%esp
  800ebd:	85 c0                	test   %eax,%eax
  800ebf:	78 18                	js     800ed9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ec1:	83 ec 0c             	sub    $0xc,%esp
  800ec4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec7:	e8 8f f4 ff ff       	call   80035b <fd2data>
	return _pipeisclosed(fd, p);
  800ecc:	89 c2                	mov    %eax,%edx
  800ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ed1:	e8 21 fd ff ff       	call   800bf7 <_pipeisclosed>
  800ed6:	83 c4 10             	add    $0x10,%esp
}
  800ed9:	c9                   	leave  
  800eda:	c3                   	ret    

00800edb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ede:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800eeb:	68 02 1f 80 00       	push   $0x801f02
  800ef0:	ff 75 0c             	pushl  0xc(%ebp)
  800ef3:	e8 c4 07 00 00       	call   8016bc <strcpy>
	return 0;
}
  800ef8:	b8 00 00 00 00       	mov    $0x0,%eax
  800efd:	c9                   	leave  
  800efe:	c3                   	ret    

00800eff <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	57                   	push   %edi
  800f03:	56                   	push   %esi
  800f04:	53                   	push   %ebx
  800f05:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f0b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f10:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f16:	eb 2d                	jmp    800f45 <devcons_write+0x46>
		m = n - tot;
  800f18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f1b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f1d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f20:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f25:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f28:	83 ec 04             	sub    $0x4,%esp
  800f2b:	53                   	push   %ebx
  800f2c:	03 45 0c             	add    0xc(%ebp),%eax
  800f2f:	50                   	push   %eax
  800f30:	57                   	push   %edi
  800f31:	e8 18 09 00 00       	call   80184e <memmove>
		sys_cputs(buf, m);
  800f36:	83 c4 08             	add    $0x8,%esp
  800f39:	53                   	push   %ebx
  800f3a:	57                   	push   %edi
  800f3b:	e8 5e f1 ff ff       	call   80009e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f40:	01 de                	add    %ebx,%esi
  800f42:	83 c4 10             	add    $0x10,%esp
  800f45:	89 f0                	mov    %esi,%eax
  800f47:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f4a:	72 cc                	jb     800f18 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4f:	5b                   	pop    %ebx
  800f50:	5e                   	pop    %esi
  800f51:	5f                   	pop    %edi
  800f52:	5d                   	pop    %ebp
  800f53:	c3                   	ret    

00800f54 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	83 ec 08             	sub    $0x8,%esp
  800f5a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f5f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f63:	74 2a                	je     800f8f <devcons_read+0x3b>
  800f65:	eb 05                	jmp    800f6c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f67:	e8 cf f1 ff ff       	call   80013b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f6c:	e8 4b f1 ff ff       	call   8000bc <sys_cgetc>
  800f71:	85 c0                	test   %eax,%eax
  800f73:	74 f2                	je     800f67 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f75:	85 c0                	test   %eax,%eax
  800f77:	78 16                	js     800f8f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f79:	83 f8 04             	cmp    $0x4,%eax
  800f7c:	74 0c                	je     800f8a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f81:	88 02                	mov    %al,(%edx)
	return 1;
  800f83:	b8 01 00 00 00       	mov    $0x1,%eax
  800f88:	eb 05                	jmp    800f8f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f8a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f8f:	c9                   	leave  
  800f90:	c3                   	ret    

00800f91 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f91:	55                   	push   %ebp
  800f92:	89 e5                	mov    %esp,%ebp
  800f94:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f97:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f9d:	6a 01                	push   $0x1
  800f9f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fa2:	50                   	push   %eax
  800fa3:	e8 f6 f0 ff ff       	call   80009e <sys_cputs>
}
  800fa8:	83 c4 10             	add    $0x10,%esp
  800fab:	c9                   	leave  
  800fac:	c3                   	ret    

00800fad <getchar>:

int
getchar(void)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fb3:	6a 01                	push   $0x1
  800fb5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fb8:	50                   	push   %eax
  800fb9:	6a 00                	push   $0x0
  800fbb:	e8 67 f6 ff ff       	call   800627 <read>
	if (r < 0)
  800fc0:	83 c4 10             	add    $0x10,%esp
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	78 0f                	js     800fd6 <getchar+0x29>
		return r;
	if (r < 1)
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	7e 06                	jle    800fd1 <getchar+0x24>
		return -E_EOF;
	return c;
  800fcb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fcf:	eb 05                	jmp    800fd6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fd1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fd6:	c9                   	leave  
  800fd7:	c3                   	ret    

00800fd8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fde:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe1:	50                   	push   %eax
  800fe2:	ff 75 08             	pushl  0x8(%ebp)
  800fe5:	e8 d7 f3 ff ff       	call   8003c1 <fd_lookup>
  800fea:	83 c4 10             	add    $0x10,%esp
  800fed:	85 c0                	test   %eax,%eax
  800fef:	78 11                	js     801002 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ffa:	39 10                	cmp    %edx,(%eax)
  800ffc:	0f 94 c0             	sete   %al
  800fff:	0f b6 c0             	movzbl %al,%eax
}
  801002:	c9                   	leave  
  801003:	c3                   	ret    

00801004 <opencons>:

int
opencons(void)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80100a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100d:	50                   	push   %eax
  80100e:	e8 5f f3 ff ff       	call   800372 <fd_alloc>
  801013:	83 c4 10             	add    $0x10,%esp
		return r;
  801016:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801018:	85 c0                	test   %eax,%eax
  80101a:	78 3e                	js     80105a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80101c:	83 ec 04             	sub    $0x4,%esp
  80101f:	68 07 04 00 00       	push   $0x407
  801024:	ff 75 f4             	pushl  -0xc(%ebp)
  801027:	6a 00                	push   $0x0
  801029:	e8 2c f1 ff ff       	call   80015a <sys_page_alloc>
  80102e:	83 c4 10             	add    $0x10,%esp
		return r;
  801031:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801033:	85 c0                	test   %eax,%eax
  801035:	78 23                	js     80105a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801037:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80103d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801040:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801042:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801045:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80104c:	83 ec 0c             	sub    $0xc,%esp
  80104f:	50                   	push   %eax
  801050:	e8 f6 f2 ff ff       	call   80034b <fd2num>
  801055:	89 c2                	mov    %eax,%edx
  801057:	83 c4 10             	add    $0x10,%esp
}
  80105a:	89 d0                	mov    %edx,%eax
  80105c:	c9                   	leave  
  80105d:	c3                   	ret    

0080105e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80105e:	55                   	push   %ebp
  80105f:	89 e5                	mov    %esp,%ebp
  801061:	56                   	push   %esi
  801062:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801063:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801066:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80106c:	e8 ab f0 ff ff       	call   80011c <sys_getenvid>
  801071:	83 ec 0c             	sub    $0xc,%esp
  801074:	ff 75 0c             	pushl  0xc(%ebp)
  801077:	ff 75 08             	pushl  0x8(%ebp)
  80107a:	56                   	push   %esi
  80107b:	50                   	push   %eax
  80107c:	68 10 1f 80 00       	push   $0x801f10
  801081:	e8 b1 00 00 00       	call   801137 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801086:	83 c4 18             	add    $0x18,%esp
  801089:	53                   	push   %ebx
  80108a:	ff 75 10             	pushl  0x10(%ebp)
  80108d:	e8 54 00 00 00       	call   8010e6 <vcprintf>
	cprintf("\n");
  801092:	c7 04 24 fb 1e 80 00 	movl   $0x801efb,(%esp)
  801099:	e8 99 00 00 00       	call   801137 <cprintf>
  80109e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010a1:	cc                   	int3   
  8010a2:	eb fd                	jmp    8010a1 <_panic+0x43>

008010a4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	53                   	push   %ebx
  8010a8:	83 ec 04             	sub    $0x4,%esp
  8010ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010ae:	8b 13                	mov    (%ebx),%edx
  8010b0:	8d 42 01             	lea    0x1(%edx),%eax
  8010b3:	89 03                	mov    %eax,(%ebx)
  8010b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010bc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010c1:	75 1a                	jne    8010dd <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010c3:	83 ec 08             	sub    $0x8,%esp
  8010c6:	68 ff 00 00 00       	push   $0xff
  8010cb:	8d 43 08             	lea    0x8(%ebx),%eax
  8010ce:	50                   	push   %eax
  8010cf:	e8 ca ef ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  8010d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010da:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010dd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e4:	c9                   	leave  
  8010e5:	c3                   	ret    

008010e6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010ef:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010f6:	00 00 00 
	b.cnt = 0;
  8010f9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801100:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801103:	ff 75 0c             	pushl  0xc(%ebp)
  801106:	ff 75 08             	pushl  0x8(%ebp)
  801109:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80110f:	50                   	push   %eax
  801110:	68 a4 10 80 00       	push   $0x8010a4
  801115:	e8 54 01 00 00       	call   80126e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80111a:	83 c4 08             	add    $0x8,%esp
  80111d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801123:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801129:	50                   	push   %eax
  80112a:	e8 6f ef ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  80112f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801135:	c9                   	leave  
  801136:	c3                   	ret    

00801137 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80113d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801140:	50                   	push   %eax
  801141:	ff 75 08             	pushl  0x8(%ebp)
  801144:	e8 9d ff ff ff       	call   8010e6 <vcprintf>
	va_end(ap);

	return cnt;
}
  801149:	c9                   	leave  
  80114a:	c3                   	ret    

0080114b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80114b:	55                   	push   %ebp
  80114c:	89 e5                	mov    %esp,%ebp
  80114e:	57                   	push   %edi
  80114f:	56                   	push   %esi
  801150:	53                   	push   %ebx
  801151:	83 ec 1c             	sub    $0x1c,%esp
  801154:	89 c7                	mov    %eax,%edi
  801156:	89 d6                	mov    %edx,%esi
  801158:	8b 45 08             	mov    0x8(%ebp),%eax
  80115b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80115e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801161:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801164:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801167:	bb 00 00 00 00       	mov    $0x0,%ebx
  80116c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80116f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801172:	39 d3                	cmp    %edx,%ebx
  801174:	72 05                	jb     80117b <printnum+0x30>
  801176:	39 45 10             	cmp    %eax,0x10(%ebp)
  801179:	77 45                	ja     8011c0 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80117b:	83 ec 0c             	sub    $0xc,%esp
  80117e:	ff 75 18             	pushl  0x18(%ebp)
  801181:	8b 45 14             	mov    0x14(%ebp),%eax
  801184:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801187:	53                   	push   %ebx
  801188:	ff 75 10             	pushl  0x10(%ebp)
  80118b:	83 ec 08             	sub    $0x8,%esp
  80118e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801191:	ff 75 e0             	pushl  -0x20(%ebp)
  801194:	ff 75 dc             	pushl  -0x24(%ebp)
  801197:	ff 75 d8             	pushl  -0x28(%ebp)
  80119a:	e8 a1 09 00 00       	call   801b40 <__udivdi3>
  80119f:	83 c4 18             	add    $0x18,%esp
  8011a2:	52                   	push   %edx
  8011a3:	50                   	push   %eax
  8011a4:	89 f2                	mov    %esi,%edx
  8011a6:	89 f8                	mov    %edi,%eax
  8011a8:	e8 9e ff ff ff       	call   80114b <printnum>
  8011ad:	83 c4 20             	add    $0x20,%esp
  8011b0:	eb 18                	jmp    8011ca <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011b2:	83 ec 08             	sub    $0x8,%esp
  8011b5:	56                   	push   %esi
  8011b6:	ff 75 18             	pushl  0x18(%ebp)
  8011b9:	ff d7                	call   *%edi
  8011bb:	83 c4 10             	add    $0x10,%esp
  8011be:	eb 03                	jmp    8011c3 <printnum+0x78>
  8011c0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011c3:	83 eb 01             	sub    $0x1,%ebx
  8011c6:	85 db                	test   %ebx,%ebx
  8011c8:	7f e8                	jg     8011b2 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011ca:	83 ec 08             	sub    $0x8,%esp
  8011cd:	56                   	push   %esi
  8011ce:	83 ec 04             	sub    $0x4,%esp
  8011d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8011d7:	ff 75 dc             	pushl  -0x24(%ebp)
  8011da:	ff 75 d8             	pushl  -0x28(%ebp)
  8011dd:	e8 8e 0a 00 00       	call   801c70 <__umoddi3>
  8011e2:	83 c4 14             	add    $0x14,%esp
  8011e5:	0f be 80 33 1f 80 00 	movsbl 0x801f33(%eax),%eax
  8011ec:	50                   	push   %eax
  8011ed:	ff d7                	call   *%edi
}
  8011ef:	83 c4 10             	add    $0x10,%esp
  8011f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f5:	5b                   	pop    %ebx
  8011f6:	5e                   	pop    %esi
  8011f7:	5f                   	pop    %edi
  8011f8:	5d                   	pop    %ebp
  8011f9:	c3                   	ret    

008011fa <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011fd:	83 fa 01             	cmp    $0x1,%edx
  801200:	7e 0e                	jle    801210 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801202:	8b 10                	mov    (%eax),%edx
  801204:	8d 4a 08             	lea    0x8(%edx),%ecx
  801207:	89 08                	mov    %ecx,(%eax)
  801209:	8b 02                	mov    (%edx),%eax
  80120b:	8b 52 04             	mov    0x4(%edx),%edx
  80120e:	eb 22                	jmp    801232 <getuint+0x38>
	else if (lflag)
  801210:	85 d2                	test   %edx,%edx
  801212:	74 10                	je     801224 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801214:	8b 10                	mov    (%eax),%edx
  801216:	8d 4a 04             	lea    0x4(%edx),%ecx
  801219:	89 08                	mov    %ecx,(%eax)
  80121b:	8b 02                	mov    (%edx),%eax
  80121d:	ba 00 00 00 00       	mov    $0x0,%edx
  801222:	eb 0e                	jmp    801232 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801224:	8b 10                	mov    (%eax),%edx
  801226:	8d 4a 04             	lea    0x4(%edx),%ecx
  801229:	89 08                	mov    %ecx,(%eax)
  80122b:	8b 02                	mov    (%edx),%eax
  80122d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801232:	5d                   	pop    %ebp
  801233:	c3                   	ret    

00801234 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80123a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80123e:	8b 10                	mov    (%eax),%edx
  801240:	3b 50 04             	cmp    0x4(%eax),%edx
  801243:	73 0a                	jae    80124f <sprintputch+0x1b>
		*b->buf++ = ch;
  801245:	8d 4a 01             	lea    0x1(%edx),%ecx
  801248:	89 08                	mov    %ecx,(%eax)
  80124a:	8b 45 08             	mov    0x8(%ebp),%eax
  80124d:	88 02                	mov    %al,(%edx)
}
  80124f:	5d                   	pop    %ebp
  801250:	c3                   	ret    

00801251 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801257:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80125a:	50                   	push   %eax
  80125b:	ff 75 10             	pushl  0x10(%ebp)
  80125e:	ff 75 0c             	pushl  0xc(%ebp)
  801261:	ff 75 08             	pushl  0x8(%ebp)
  801264:	e8 05 00 00 00       	call   80126e <vprintfmt>
	va_end(ap);
}
  801269:	83 c4 10             	add    $0x10,%esp
  80126c:	c9                   	leave  
  80126d:	c3                   	ret    

0080126e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	57                   	push   %edi
  801272:	56                   	push   %esi
  801273:	53                   	push   %ebx
  801274:	83 ec 2c             	sub    $0x2c,%esp
  801277:	8b 75 08             	mov    0x8(%ebp),%esi
  80127a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80127d:	8b 7d 10             	mov    0x10(%ebp),%edi
  801280:	eb 12                	jmp    801294 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801282:	85 c0                	test   %eax,%eax
  801284:	0f 84 89 03 00 00    	je     801613 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80128a:	83 ec 08             	sub    $0x8,%esp
  80128d:	53                   	push   %ebx
  80128e:	50                   	push   %eax
  80128f:	ff d6                	call   *%esi
  801291:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801294:	83 c7 01             	add    $0x1,%edi
  801297:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80129b:	83 f8 25             	cmp    $0x25,%eax
  80129e:	75 e2                	jne    801282 <vprintfmt+0x14>
  8012a0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012a4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012ab:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012b2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8012be:	eb 07                	jmp    8012c7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012c3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c7:	8d 47 01             	lea    0x1(%edi),%eax
  8012ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012cd:	0f b6 07             	movzbl (%edi),%eax
  8012d0:	0f b6 c8             	movzbl %al,%ecx
  8012d3:	83 e8 23             	sub    $0x23,%eax
  8012d6:	3c 55                	cmp    $0x55,%al
  8012d8:	0f 87 1a 03 00 00    	ja     8015f8 <vprintfmt+0x38a>
  8012de:	0f b6 c0             	movzbl %al,%eax
  8012e1:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  8012e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012eb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012ef:	eb d6                	jmp    8012c7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012fc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012ff:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801303:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801306:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801309:	83 fa 09             	cmp    $0x9,%edx
  80130c:	77 39                	ja     801347 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80130e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801311:	eb e9                	jmp    8012fc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801313:	8b 45 14             	mov    0x14(%ebp),%eax
  801316:	8d 48 04             	lea    0x4(%eax),%ecx
  801319:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80131c:	8b 00                	mov    (%eax),%eax
  80131e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801321:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801324:	eb 27                	jmp    80134d <vprintfmt+0xdf>
  801326:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801329:	85 c0                	test   %eax,%eax
  80132b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801330:	0f 49 c8             	cmovns %eax,%ecx
  801333:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801336:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801339:	eb 8c                	jmp    8012c7 <vprintfmt+0x59>
  80133b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80133e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801345:	eb 80                	jmp    8012c7 <vprintfmt+0x59>
  801347:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80134a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80134d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801351:	0f 89 70 ff ff ff    	jns    8012c7 <vprintfmt+0x59>
				width = precision, precision = -1;
  801357:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80135a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80135d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801364:	e9 5e ff ff ff       	jmp    8012c7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801369:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80136c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80136f:	e9 53 ff ff ff       	jmp    8012c7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801374:	8b 45 14             	mov    0x14(%ebp),%eax
  801377:	8d 50 04             	lea    0x4(%eax),%edx
  80137a:	89 55 14             	mov    %edx,0x14(%ebp)
  80137d:	83 ec 08             	sub    $0x8,%esp
  801380:	53                   	push   %ebx
  801381:	ff 30                	pushl  (%eax)
  801383:	ff d6                	call   *%esi
			break;
  801385:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80138b:	e9 04 ff ff ff       	jmp    801294 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801390:	8b 45 14             	mov    0x14(%ebp),%eax
  801393:	8d 50 04             	lea    0x4(%eax),%edx
  801396:	89 55 14             	mov    %edx,0x14(%ebp)
  801399:	8b 00                	mov    (%eax),%eax
  80139b:	99                   	cltd   
  80139c:	31 d0                	xor    %edx,%eax
  80139e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013a0:	83 f8 0f             	cmp    $0xf,%eax
  8013a3:	7f 0b                	jg     8013b0 <vprintfmt+0x142>
  8013a5:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  8013ac:	85 d2                	test   %edx,%edx
  8013ae:	75 18                	jne    8013c8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013b0:	50                   	push   %eax
  8013b1:	68 4b 1f 80 00       	push   $0x801f4b
  8013b6:	53                   	push   %ebx
  8013b7:	56                   	push   %esi
  8013b8:	e8 94 fe ff ff       	call   801251 <printfmt>
  8013bd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013c3:	e9 cc fe ff ff       	jmp    801294 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013c8:	52                   	push   %edx
  8013c9:	68 c2 1e 80 00       	push   $0x801ec2
  8013ce:	53                   	push   %ebx
  8013cf:	56                   	push   %esi
  8013d0:	e8 7c fe ff ff       	call   801251 <printfmt>
  8013d5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013db:	e9 b4 fe ff ff       	jmp    801294 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8013e3:	8d 50 04             	lea    0x4(%eax),%edx
  8013e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8013e9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013eb:	85 ff                	test   %edi,%edi
  8013ed:	b8 44 1f 80 00       	mov    $0x801f44,%eax
  8013f2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013f9:	0f 8e 94 00 00 00    	jle    801493 <vprintfmt+0x225>
  8013ff:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801403:	0f 84 98 00 00 00    	je     8014a1 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801409:	83 ec 08             	sub    $0x8,%esp
  80140c:	ff 75 d0             	pushl  -0x30(%ebp)
  80140f:	57                   	push   %edi
  801410:	e8 86 02 00 00       	call   80169b <strnlen>
  801415:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801418:	29 c1                	sub    %eax,%ecx
  80141a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80141d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801420:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801424:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801427:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80142a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80142c:	eb 0f                	jmp    80143d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80142e:	83 ec 08             	sub    $0x8,%esp
  801431:	53                   	push   %ebx
  801432:	ff 75 e0             	pushl  -0x20(%ebp)
  801435:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801437:	83 ef 01             	sub    $0x1,%edi
  80143a:	83 c4 10             	add    $0x10,%esp
  80143d:	85 ff                	test   %edi,%edi
  80143f:	7f ed                	jg     80142e <vprintfmt+0x1c0>
  801441:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801444:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801447:	85 c9                	test   %ecx,%ecx
  801449:	b8 00 00 00 00       	mov    $0x0,%eax
  80144e:	0f 49 c1             	cmovns %ecx,%eax
  801451:	29 c1                	sub    %eax,%ecx
  801453:	89 75 08             	mov    %esi,0x8(%ebp)
  801456:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801459:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80145c:	89 cb                	mov    %ecx,%ebx
  80145e:	eb 4d                	jmp    8014ad <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801460:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801464:	74 1b                	je     801481 <vprintfmt+0x213>
  801466:	0f be c0             	movsbl %al,%eax
  801469:	83 e8 20             	sub    $0x20,%eax
  80146c:	83 f8 5e             	cmp    $0x5e,%eax
  80146f:	76 10                	jbe    801481 <vprintfmt+0x213>
					putch('?', putdat);
  801471:	83 ec 08             	sub    $0x8,%esp
  801474:	ff 75 0c             	pushl  0xc(%ebp)
  801477:	6a 3f                	push   $0x3f
  801479:	ff 55 08             	call   *0x8(%ebp)
  80147c:	83 c4 10             	add    $0x10,%esp
  80147f:	eb 0d                	jmp    80148e <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801481:	83 ec 08             	sub    $0x8,%esp
  801484:	ff 75 0c             	pushl  0xc(%ebp)
  801487:	52                   	push   %edx
  801488:	ff 55 08             	call   *0x8(%ebp)
  80148b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80148e:	83 eb 01             	sub    $0x1,%ebx
  801491:	eb 1a                	jmp    8014ad <vprintfmt+0x23f>
  801493:	89 75 08             	mov    %esi,0x8(%ebp)
  801496:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801499:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80149c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80149f:	eb 0c                	jmp    8014ad <vprintfmt+0x23f>
  8014a1:	89 75 08             	mov    %esi,0x8(%ebp)
  8014a4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014a7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014aa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014ad:	83 c7 01             	add    $0x1,%edi
  8014b0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014b4:	0f be d0             	movsbl %al,%edx
  8014b7:	85 d2                	test   %edx,%edx
  8014b9:	74 23                	je     8014de <vprintfmt+0x270>
  8014bb:	85 f6                	test   %esi,%esi
  8014bd:	78 a1                	js     801460 <vprintfmt+0x1f2>
  8014bf:	83 ee 01             	sub    $0x1,%esi
  8014c2:	79 9c                	jns    801460 <vprintfmt+0x1f2>
  8014c4:	89 df                	mov    %ebx,%edi
  8014c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014cc:	eb 18                	jmp    8014e6 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014ce:	83 ec 08             	sub    $0x8,%esp
  8014d1:	53                   	push   %ebx
  8014d2:	6a 20                	push   $0x20
  8014d4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014d6:	83 ef 01             	sub    $0x1,%edi
  8014d9:	83 c4 10             	add    $0x10,%esp
  8014dc:	eb 08                	jmp    8014e6 <vprintfmt+0x278>
  8014de:	89 df                	mov    %ebx,%edi
  8014e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8014e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014e6:	85 ff                	test   %edi,%edi
  8014e8:	7f e4                	jg     8014ce <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014ed:	e9 a2 fd ff ff       	jmp    801294 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014f2:	83 fa 01             	cmp    $0x1,%edx
  8014f5:	7e 16                	jle    80150d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fa:	8d 50 08             	lea    0x8(%eax),%edx
  8014fd:	89 55 14             	mov    %edx,0x14(%ebp)
  801500:	8b 50 04             	mov    0x4(%eax),%edx
  801503:	8b 00                	mov    (%eax),%eax
  801505:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801508:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80150b:	eb 32                	jmp    80153f <vprintfmt+0x2d1>
	else if (lflag)
  80150d:	85 d2                	test   %edx,%edx
  80150f:	74 18                	je     801529 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801511:	8b 45 14             	mov    0x14(%ebp),%eax
  801514:	8d 50 04             	lea    0x4(%eax),%edx
  801517:	89 55 14             	mov    %edx,0x14(%ebp)
  80151a:	8b 00                	mov    (%eax),%eax
  80151c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80151f:	89 c1                	mov    %eax,%ecx
  801521:	c1 f9 1f             	sar    $0x1f,%ecx
  801524:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801527:	eb 16                	jmp    80153f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801529:	8b 45 14             	mov    0x14(%ebp),%eax
  80152c:	8d 50 04             	lea    0x4(%eax),%edx
  80152f:	89 55 14             	mov    %edx,0x14(%ebp)
  801532:	8b 00                	mov    (%eax),%eax
  801534:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801537:	89 c1                	mov    %eax,%ecx
  801539:	c1 f9 1f             	sar    $0x1f,%ecx
  80153c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80153f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801542:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801545:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80154a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80154e:	79 74                	jns    8015c4 <vprintfmt+0x356>
				putch('-', putdat);
  801550:	83 ec 08             	sub    $0x8,%esp
  801553:	53                   	push   %ebx
  801554:	6a 2d                	push   $0x2d
  801556:	ff d6                	call   *%esi
				num = -(long long) num;
  801558:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80155b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80155e:	f7 d8                	neg    %eax
  801560:	83 d2 00             	adc    $0x0,%edx
  801563:	f7 da                	neg    %edx
  801565:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801568:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80156d:	eb 55                	jmp    8015c4 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80156f:	8d 45 14             	lea    0x14(%ebp),%eax
  801572:	e8 83 fc ff ff       	call   8011fa <getuint>
			base = 10;
  801577:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80157c:	eb 46                	jmp    8015c4 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80157e:	8d 45 14             	lea    0x14(%ebp),%eax
  801581:	e8 74 fc ff ff       	call   8011fa <getuint>
                        base = 8;
  801586:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  80158b:	eb 37                	jmp    8015c4 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80158d:	83 ec 08             	sub    $0x8,%esp
  801590:	53                   	push   %ebx
  801591:	6a 30                	push   $0x30
  801593:	ff d6                	call   *%esi
			putch('x', putdat);
  801595:	83 c4 08             	add    $0x8,%esp
  801598:	53                   	push   %ebx
  801599:	6a 78                	push   $0x78
  80159b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80159d:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a0:	8d 50 04             	lea    0x4(%eax),%edx
  8015a3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015a6:	8b 00                	mov    (%eax),%eax
  8015a8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015ad:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015b0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015b5:	eb 0d                	jmp    8015c4 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015b7:	8d 45 14             	lea    0x14(%ebp),%eax
  8015ba:	e8 3b fc ff ff       	call   8011fa <getuint>
			base = 16;
  8015bf:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015c4:	83 ec 0c             	sub    $0xc,%esp
  8015c7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015cb:	57                   	push   %edi
  8015cc:	ff 75 e0             	pushl  -0x20(%ebp)
  8015cf:	51                   	push   %ecx
  8015d0:	52                   	push   %edx
  8015d1:	50                   	push   %eax
  8015d2:	89 da                	mov    %ebx,%edx
  8015d4:	89 f0                	mov    %esi,%eax
  8015d6:	e8 70 fb ff ff       	call   80114b <printnum>
			break;
  8015db:	83 c4 20             	add    $0x20,%esp
  8015de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015e1:	e9 ae fc ff ff       	jmp    801294 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015e6:	83 ec 08             	sub    $0x8,%esp
  8015e9:	53                   	push   %ebx
  8015ea:	51                   	push   %ecx
  8015eb:	ff d6                	call   *%esi
			break;
  8015ed:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015f3:	e9 9c fc ff ff       	jmp    801294 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015f8:	83 ec 08             	sub    $0x8,%esp
  8015fb:	53                   	push   %ebx
  8015fc:	6a 25                	push   $0x25
  8015fe:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	eb 03                	jmp    801608 <vprintfmt+0x39a>
  801605:	83 ef 01             	sub    $0x1,%edi
  801608:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80160c:	75 f7                	jne    801605 <vprintfmt+0x397>
  80160e:	e9 81 fc ff ff       	jmp    801294 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801613:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801616:	5b                   	pop    %ebx
  801617:	5e                   	pop    %esi
  801618:	5f                   	pop    %edi
  801619:	5d                   	pop    %ebp
  80161a:	c3                   	ret    

0080161b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80161b:	55                   	push   %ebp
  80161c:	89 e5                	mov    %esp,%ebp
  80161e:	83 ec 18             	sub    $0x18,%esp
  801621:	8b 45 08             	mov    0x8(%ebp),%eax
  801624:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801627:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80162a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80162e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801631:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801638:	85 c0                	test   %eax,%eax
  80163a:	74 26                	je     801662 <vsnprintf+0x47>
  80163c:	85 d2                	test   %edx,%edx
  80163e:	7e 22                	jle    801662 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801640:	ff 75 14             	pushl  0x14(%ebp)
  801643:	ff 75 10             	pushl  0x10(%ebp)
  801646:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801649:	50                   	push   %eax
  80164a:	68 34 12 80 00       	push   $0x801234
  80164f:	e8 1a fc ff ff       	call   80126e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801654:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801657:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80165a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	eb 05                	jmp    801667 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801662:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801667:	c9                   	leave  
  801668:	c3                   	ret    

00801669 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801669:	55                   	push   %ebp
  80166a:	89 e5                	mov    %esp,%ebp
  80166c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80166f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801672:	50                   	push   %eax
  801673:	ff 75 10             	pushl  0x10(%ebp)
  801676:	ff 75 0c             	pushl  0xc(%ebp)
  801679:	ff 75 08             	pushl  0x8(%ebp)
  80167c:	e8 9a ff ff ff       	call   80161b <vsnprintf>
	va_end(ap);

	return rc;
}
  801681:	c9                   	leave  
  801682:	c3                   	ret    

00801683 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801689:	b8 00 00 00 00       	mov    $0x0,%eax
  80168e:	eb 03                	jmp    801693 <strlen+0x10>
		n++;
  801690:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801693:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801697:	75 f7                	jne    801690 <strlen+0xd>
		n++;
	return n;
}
  801699:	5d                   	pop    %ebp
  80169a:	c3                   	ret    

0080169b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016a1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a9:	eb 03                	jmp    8016ae <strnlen+0x13>
		n++;
  8016ab:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016ae:	39 c2                	cmp    %eax,%edx
  8016b0:	74 08                	je     8016ba <strnlen+0x1f>
  8016b2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016b6:	75 f3                	jne    8016ab <strnlen+0x10>
  8016b8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016ba:	5d                   	pop    %ebp
  8016bb:	c3                   	ret    

008016bc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	53                   	push   %ebx
  8016c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016c6:	89 c2                	mov    %eax,%edx
  8016c8:	83 c2 01             	add    $0x1,%edx
  8016cb:	83 c1 01             	add    $0x1,%ecx
  8016ce:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016d2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016d5:	84 db                	test   %bl,%bl
  8016d7:	75 ef                	jne    8016c8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016d9:	5b                   	pop    %ebx
  8016da:	5d                   	pop    %ebp
  8016db:	c3                   	ret    

008016dc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	53                   	push   %ebx
  8016e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016e3:	53                   	push   %ebx
  8016e4:	e8 9a ff ff ff       	call   801683 <strlen>
  8016e9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016ec:	ff 75 0c             	pushl  0xc(%ebp)
  8016ef:	01 d8                	add    %ebx,%eax
  8016f1:	50                   	push   %eax
  8016f2:	e8 c5 ff ff ff       	call   8016bc <strcpy>
	return dst;
}
  8016f7:	89 d8                	mov    %ebx,%eax
  8016f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fc:	c9                   	leave  
  8016fd:	c3                   	ret    

008016fe <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	56                   	push   %esi
  801702:	53                   	push   %ebx
  801703:	8b 75 08             	mov    0x8(%ebp),%esi
  801706:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801709:	89 f3                	mov    %esi,%ebx
  80170b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80170e:	89 f2                	mov    %esi,%edx
  801710:	eb 0f                	jmp    801721 <strncpy+0x23>
		*dst++ = *src;
  801712:	83 c2 01             	add    $0x1,%edx
  801715:	0f b6 01             	movzbl (%ecx),%eax
  801718:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80171b:	80 39 01             	cmpb   $0x1,(%ecx)
  80171e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801721:	39 da                	cmp    %ebx,%edx
  801723:	75 ed                	jne    801712 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801725:	89 f0                	mov    %esi,%eax
  801727:	5b                   	pop    %ebx
  801728:	5e                   	pop    %esi
  801729:	5d                   	pop    %ebp
  80172a:	c3                   	ret    

0080172b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	56                   	push   %esi
  80172f:	53                   	push   %ebx
  801730:	8b 75 08             	mov    0x8(%ebp),%esi
  801733:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801736:	8b 55 10             	mov    0x10(%ebp),%edx
  801739:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80173b:	85 d2                	test   %edx,%edx
  80173d:	74 21                	je     801760 <strlcpy+0x35>
  80173f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801743:	89 f2                	mov    %esi,%edx
  801745:	eb 09                	jmp    801750 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801747:	83 c2 01             	add    $0x1,%edx
  80174a:	83 c1 01             	add    $0x1,%ecx
  80174d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801750:	39 c2                	cmp    %eax,%edx
  801752:	74 09                	je     80175d <strlcpy+0x32>
  801754:	0f b6 19             	movzbl (%ecx),%ebx
  801757:	84 db                	test   %bl,%bl
  801759:	75 ec                	jne    801747 <strlcpy+0x1c>
  80175b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80175d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801760:	29 f0                	sub    %esi,%eax
}
  801762:	5b                   	pop    %ebx
  801763:	5e                   	pop    %esi
  801764:	5d                   	pop    %ebp
  801765:	c3                   	ret    

00801766 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80176c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80176f:	eb 06                	jmp    801777 <strcmp+0x11>
		p++, q++;
  801771:	83 c1 01             	add    $0x1,%ecx
  801774:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801777:	0f b6 01             	movzbl (%ecx),%eax
  80177a:	84 c0                	test   %al,%al
  80177c:	74 04                	je     801782 <strcmp+0x1c>
  80177e:	3a 02                	cmp    (%edx),%al
  801780:	74 ef                	je     801771 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801782:	0f b6 c0             	movzbl %al,%eax
  801785:	0f b6 12             	movzbl (%edx),%edx
  801788:	29 d0                	sub    %edx,%eax
}
  80178a:	5d                   	pop    %ebp
  80178b:	c3                   	ret    

0080178c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	53                   	push   %ebx
  801790:	8b 45 08             	mov    0x8(%ebp),%eax
  801793:	8b 55 0c             	mov    0xc(%ebp),%edx
  801796:	89 c3                	mov    %eax,%ebx
  801798:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80179b:	eb 06                	jmp    8017a3 <strncmp+0x17>
		n--, p++, q++;
  80179d:	83 c0 01             	add    $0x1,%eax
  8017a0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017a3:	39 d8                	cmp    %ebx,%eax
  8017a5:	74 15                	je     8017bc <strncmp+0x30>
  8017a7:	0f b6 08             	movzbl (%eax),%ecx
  8017aa:	84 c9                	test   %cl,%cl
  8017ac:	74 04                	je     8017b2 <strncmp+0x26>
  8017ae:	3a 0a                	cmp    (%edx),%cl
  8017b0:	74 eb                	je     80179d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b2:	0f b6 00             	movzbl (%eax),%eax
  8017b5:	0f b6 12             	movzbl (%edx),%edx
  8017b8:	29 d0                	sub    %edx,%eax
  8017ba:	eb 05                	jmp    8017c1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017bc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017c1:	5b                   	pop    %ebx
  8017c2:	5d                   	pop    %ebp
  8017c3:	c3                   	ret    

008017c4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ca:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017ce:	eb 07                	jmp    8017d7 <strchr+0x13>
		if (*s == c)
  8017d0:	38 ca                	cmp    %cl,%dl
  8017d2:	74 0f                	je     8017e3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017d4:	83 c0 01             	add    $0x1,%eax
  8017d7:	0f b6 10             	movzbl (%eax),%edx
  8017da:	84 d2                	test   %dl,%dl
  8017dc:	75 f2                	jne    8017d0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e3:	5d                   	pop    %ebp
  8017e4:	c3                   	ret    

008017e5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017eb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017ef:	eb 03                	jmp    8017f4 <strfind+0xf>
  8017f1:	83 c0 01             	add    $0x1,%eax
  8017f4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017f7:	38 ca                	cmp    %cl,%dl
  8017f9:	74 04                	je     8017ff <strfind+0x1a>
  8017fb:	84 d2                	test   %dl,%dl
  8017fd:	75 f2                	jne    8017f1 <strfind+0xc>
			break;
	return (char *) s;
}
  8017ff:	5d                   	pop    %ebp
  801800:	c3                   	ret    

00801801 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	57                   	push   %edi
  801805:	56                   	push   %esi
  801806:	53                   	push   %ebx
  801807:	8b 7d 08             	mov    0x8(%ebp),%edi
  80180a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80180d:	85 c9                	test   %ecx,%ecx
  80180f:	74 36                	je     801847 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801811:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801817:	75 28                	jne    801841 <memset+0x40>
  801819:	f6 c1 03             	test   $0x3,%cl
  80181c:	75 23                	jne    801841 <memset+0x40>
		c &= 0xFF;
  80181e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801822:	89 d3                	mov    %edx,%ebx
  801824:	c1 e3 08             	shl    $0x8,%ebx
  801827:	89 d6                	mov    %edx,%esi
  801829:	c1 e6 18             	shl    $0x18,%esi
  80182c:	89 d0                	mov    %edx,%eax
  80182e:	c1 e0 10             	shl    $0x10,%eax
  801831:	09 f0                	or     %esi,%eax
  801833:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801835:	89 d8                	mov    %ebx,%eax
  801837:	09 d0                	or     %edx,%eax
  801839:	c1 e9 02             	shr    $0x2,%ecx
  80183c:	fc                   	cld    
  80183d:	f3 ab                	rep stos %eax,%es:(%edi)
  80183f:	eb 06                	jmp    801847 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801841:	8b 45 0c             	mov    0xc(%ebp),%eax
  801844:	fc                   	cld    
  801845:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801847:	89 f8                	mov    %edi,%eax
  801849:	5b                   	pop    %ebx
  80184a:	5e                   	pop    %esi
  80184b:	5f                   	pop    %edi
  80184c:	5d                   	pop    %ebp
  80184d:	c3                   	ret    

0080184e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	57                   	push   %edi
  801852:	56                   	push   %esi
  801853:	8b 45 08             	mov    0x8(%ebp),%eax
  801856:	8b 75 0c             	mov    0xc(%ebp),%esi
  801859:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80185c:	39 c6                	cmp    %eax,%esi
  80185e:	73 35                	jae    801895 <memmove+0x47>
  801860:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801863:	39 d0                	cmp    %edx,%eax
  801865:	73 2e                	jae    801895 <memmove+0x47>
		s += n;
		d += n;
  801867:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80186a:	89 d6                	mov    %edx,%esi
  80186c:	09 fe                	or     %edi,%esi
  80186e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801874:	75 13                	jne    801889 <memmove+0x3b>
  801876:	f6 c1 03             	test   $0x3,%cl
  801879:	75 0e                	jne    801889 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80187b:	83 ef 04             	sub    $0x4,%edi
  80187e:	8d 72 fc             	lea    -0x4(%edx),%esi
  801881:	c1 e9 02             	shr    $0x2,%ecx
  801884:	fd                   	std    
  801885:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801887:	eb 09                	jmp    801892 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801889:	83 ef 01             	sub    $0x1,%edi
  80188c:	8d 72 ff             	lea    -0x1(%edx),%esi
  80188f:	fd                   	std    
  801890:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801892:	fc                   	cld    
  801893:	eb 1d                	jmp    8018b2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801895:	89 f2                	mov    %esi,%edx
  801897:	09 c2                	or     %eax,%edx
  801899:	f6 c2 03             	test   $0x3,%dl
  80189c:	75 0f                	jne    8018ad <memmove+0x5f>
  80189e:	f6 c1 03             	test   $0x3,%cl
  8018a1:	75 0a                	jne    8018ad <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018a3:	c1 e9 02             	shr    $0x2,%ecx
  8018a6:	89 c7                	mov    %eax,%edi
  8018a8:	fc                   	cld    
  8018a9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ab:	eb 05                	jmp    8018b2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018ad:	89 c7                	mov    %eax,%edi
  8018af:	fc                   	cld    
  8018b0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018b2:	5e                   	pop    %esi
  8018b3:	5f                   	pop    %edi
  8018b4:	5d                   	pop    %ebp
  8018b5:	c3                   	ret    

008018b6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018b9:	ff 75 10             	pushl  0x10(%ebp)
  8018bc:	ff 75 0c             	pushl  0xc(%ebp)
  8018bf:	ff 75 08             	pushl  0x8(%ebp)
  8018c2:	e8 87 ff ff ff       	call   80184e <memmove>
}
  8018c7:	c9                   	leave  
  8018c8:	c3                   	ret    

008018c9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018c9:	55                   	push   %ebp
  8018ca:	89 e5                	mov    %esp,%ebp
  8018cc:	56                   	push   %esi
  8018cd:	53                   	push   %ebx
  8018ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d4:	89 c6                	mov    %eax,%esi
  8018d6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018d9:	eb 1a                	jmp    8018f5 <memcmp+0x2c>
		if (*s1 != *s2)
  8018db:	0f b6 08             	movzbl (%eax),%ecx
  8018de:	0f b6 1a             	movzbl (%edx),%ebx
  8018e1:	38 d9                	cmp    %bl,%cl
  8018e3:	74 0a                	je     8018ef <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018e5:	0f b6 c1             	movzbl %cl,%eax
  8018e8:	0f b6 db             	movzbl %bl,%ebx
  8018eb:	29 d8                	sub    %ebx,%eax
  8018ed:	eb 0f                	jmp    8018fe <memcmp+0x35>
		s1++, s2++;
  8018ef:	83 c0 01             	add    $0x1,%eax
  8018f2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f5:	39 f0                	cmp    %esi,%eax
  8018f7:	75 e2                	jne    8018db <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018fe:	5b                   	pop    %ebx
  8018ff:	5e                   	pop    %esi
  801900:	5d                   	pop    %ebp
  801901:	c3                   	ret    

00801902 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	53                   	push   %ebx
  801906:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801909:	89 c1                	mov    %eax,%ecx
  80190b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80190e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801912:	eb 0a                	jmp    80191e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801914:	0f b6 10             	movzbl (%eax),%edx
  801917:	39 da                	cmp    %ebx,%edx
  801919:	74 07                	je     801922 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80191b:	83 c0 01             	add    $0x1,%eax
  80191e:	39 c8                	cmp    %ecx,%eax
  801920:	72 f2                	jb     801914 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801922:	5b                   	pop    %ebx
  801923:	5d                   	pop    %ebp
  801924:	c3                   	ret    

00801925 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
  801928:	57                   	push   %edi
  801929:	56                   	push   %esi
  80192a:	53                   	push   %ebx
  80192b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80192e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801931:	eb 03                	jmp    801936 <strtol+0x11>
		s++;
  801933:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801936:	0f b6 01             	movzbl (%ecx),%eax
  801939:	3c 20                	cmp    $0x20,%al
  80193b:	74 f6                	je     801933 <strtol+0xe>
  80193d:	3c 09                	cmp    $0x9,%al
  80193f:	74 f2                	je     801933 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801941:	3c 2b                	cmp    $0x2b,%al
  801943:	75 0a                	jne    80194f <strtol+0x2a>
		s++;
  801945:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801948:	bf 00 00 00 00       	mov    $0x0,%edi
  80194d:	eb 11                	jmp    801960 <strtol+0x3b>
  80194f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801954:	3c 2d                	cmp    $0x2d,%al
  801956:	75 08                	jne    801960 <strtol+0x3b>
		s++, neg = 1;
  801958:	83 c1 01             	add    $0x1,%ecx
  80195b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801960:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801966:	75 15                	jne    80197d <strtol+0x58>
  801968:	80 39 30             	cmpb   $0x30,(%ecx)
  80196b:	75 10                	jne    80197d <strtol+0x58>
  80196d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801971:	75 7c                	jne    8019ef <strtol+0xca>
		s += 2, base = 16;
  801973:	83 c1 02             	add    $0x2,%ecx
  801976:	bb 10 00 00 00       	mov    $0x10,%ebx
  80197b:	eb 16                	jmp    801993 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80197d:	85 db                	test   %ebx,%ebx
  80197f:	75 12                	jne    801993 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801981:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801986:	80 39 30             	cmpb   $0x30,(%ecx)
  801989:	75 08                	jne    801993 <strtol+0x6e>
		s++, base = 8;
  80198b:	83 c1 01             	add    $0x1,%ecx
  80198e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801993:	b8 00 00 00 00       	mov    $0x0,%eax
  801998:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80199b:	0f b6 11             	movzbl (%ecx),%edx
  80199e:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019a1:	89 f3                	mov    %esi,%ebx
  8019a3:	80 fb 09             	cmp    $0x9,%bl
  8019a6:	77 08                	ja     8019b0 <strtol+0x8b>
			dig = *s - '0';
  8019a8:	0f be d2             	movsbl %dl,%edx
  8019ab:	83 ea 30             	sub    $0x30,%edx
  8019ae:	eb 22                	jmp    8019d2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019b0:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019b3:	89 f3                	mov    %esi,%ebx
  8019b5:	80 fb 19             	cmp    $0x19,%bl
  8019b8:	77 08                	ja     8019c2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019ba:	0f be d2             	movsbl %dl,%edx
  8019bd:	83 ea 57             	sub    $0x57,%edx
  8019c0:	eb 10                	jmp    8019d2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019c2:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019c5:	89 f3                	mov    %esi,%ebx
  8019c7:	80 fb 19             	cmp    $0x19,%bl
  8019ca:	77 16                	ja     8019e2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019cc:	0f be d2             	movsbl %dl,%edx
  8019cf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019d2:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019d5:	7d 0b                	jge    8019e2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019d7:	83 c1 01             	add    $0x1,%ecx
  8019da:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019de:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019e0:	eb b9                	jmp    80199b <strtol+0x76>

	if (endptr)
  8019e2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019e6:	74 0d                	je     8019f5 <strtol+0xd0>
		*endptr = (char *) s;
  8019e8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019eb:	89 0e                	mov    %ecx,(%esi)
  8019ed:	eb 06                	jmp    8019f5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019ef:	85 db                	test   %ebx,%ebx
  8019f1:	74 98                	je     80198b <strtol+0x66>
  8019f3:	eb 9e                	jmp    801993 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019f5:	89 c2                	mov    %eax,%edx
  8019f7:	f7 da                	neg    %edx
  8019f9:	85 ff                	test   %edi,%edi
  8019fb:	0f 45 c2             	cmovne %edx,%eax
}
  8019fe:	5b                   	pop    %ebx
  8019ff:	5e                   	pop    %esi
  801a00:	5f                   	pop    %edi
  801a01:	5d                   	pop    %ebp
  801a02:	c3                   	ret    

00801a03 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	56                   	push   %esi
  801a07:	53                   	push   %ebx
  801a08:	8b 75 08             	mov    0x8(%ebp),%esi
  801a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801a11:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801a13:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801a18:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801a1b:	83 ec 0c             	sub    $0xc,%esp
  801a1e:	50                   	push   %eax
  801a1f:	e8 e6 e8 ff ff       	call   80030a <sys_ipc_recv>

	if (r < 0) {
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	85 c0                	test   %eax,%eax
  801a29:	79 16                	jns    801a41 <ipc_recv+0x3e>
		if (from_env_store)
  801a2b:	85 f6                	test   %esi,%esi
  801a2d:	74 06                	je     801a35 <ipc_recv+0x32>
			*from_env_store = 0;
  801a2f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801a35:	85 db                	test   %ebx,%ebx
  801a37:	74 2c                	je     801a65 <ipc_recv+0x62>
			*perm_store = 0;
  801a39:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a3f:	eb 24                	jmp    801a65 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801a41:	85 f6                	test   %esi,%esi
  801a43:	74 0a                	je     801a4f <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801a45:	a1 04 40 80 00       	mov    0x804004,%eax
  801a4a:	8b 40 74             	mov    0x74(%eax),%eax
  801a4d:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801a4f:	85 db                	test   %ebx,%ebx
  801a51:	74 0a                	je     801a5d <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801a53:	a1 04 40 80 00       	mov    0x804004,%eax
  801a58:	8b 40 78             	mov    0x78(%eax),%eax
  801a5b:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801a5d:	a1 04 40 80 00       	mov    0x804004,%eax
  801a62:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801a65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a68:	5b                   	pop    %ebx
  801a69:	5e                   	pop    %esi
  801a6a:	5d                   	pop    %ebp
  801a6b:	c3                   	ret    

00801a6c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	57                   	push   %edi
  801a70:	56                   	push   %esi
  801a71:	53                   	push   %ebx
  801a72:	83 ec 0c             	sub    $0xc,%esp
  801a75:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a78:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801a7e:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801a80:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801a85:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801a88:	ff 75 14             	pushl  0x14(%ebp)
  801a8b:	53                   	push   %ebx
  801a8c:	56                   	push   %esi
  801a8d:	57                   	push   %edi
  801a8e:	e8 54 e8 ff ff       	call   8002e7 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801a93:	83 c4 10             	add    $0x10,%esp
  801a96:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a99:	75 07                	jne    801aa2 <ipc_send+0x36>
			sys_yield();
  801a9b:	e8 9b e6 ff ff       	call   80013b <sys_yield>
  801aa0:	eb e6                	jmp    801a88 <ipc_send+0x1c>
		} else if (r < 0) {
  801aa2:	85 c0                	test   %eax,%eax
  801aa4:	79 12                	jns    801ab8 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801aa6:	50                   	push   %eax
  801aa7:	68 40 22 80 00       	push   $0x802240
  801aac:	6a 51                	push   $0x51
  801aae:	68 4d 22 80 00       	push   $0x80224d
  801ab3:	e8 a6 f5 ff ff       	call   80105e <_panic>
		}
	}
}
  801ab8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801abb:	5b                   	pop    %ebx
  801abc:	5e                   	pop    %esi
  801abd:	5f                   	pop    %edi
  801abe:	5d                   	pop    %ebp
  801abf:	c3                   	ret    

00801ac0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ac6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801acb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ace:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ad4:	8b 52 50             	mov    0x50(%edx),%edx
  801ad7:	39 ca                	cmp    %ecx,%edx
  801ad9:	75 0d                	jne    801ae8 <ipc_find_env+0x28>
			return envs[i].env_id;
  801adb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ade:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ae3:	8b 40 48             	mov    0x48(%eax),%eax
  801ae6:	eb 0f                	jmp    801af7 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ae8:	83 c0 01             	add    $0x1,%eax
  801aeb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801af0:	75 d9                	jne    801acb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801af2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801af7:	5d                   	pop    %ebp
  801af8:	c3                   	ret    

00801af9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801aff:	89 d0                	mov    %edx,%eax
  801b01:	c1 e8 16             	shr    $0x16,%eax
  801b04:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b0b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b10:	f6 c1 01             	test   $0x1,%cl
  801b13:	74 1d                	je     801b32 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b15:	c1 ea 0c             	shr    $0xc,%edx
  801b18:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b1f:	f6 c2 01             	test   $0x1,%dl
  801b22:	74 0e                	je     801b32 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b24:	c1 ea 0c             	shr    $0xc,%edx
  801b27:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b2e:	ef 
  801b2f:	0f b7 c0             	movzwl %ax,%eax
}
  801b32:	5d                   	pop    %ebp
  801b33:	c3                   	ret    
  801b34:	66 90                	xchg   %ax,%ax
  801b36:	66 90                	xchg   %ax,%ax
  801b38:	66 90                	xchg   %ax,%ax
  801b3a:	66 90                	xchg   %ax,%ax
  801b3c:	66 90                	xchg   %ax,%ax
  801b3e:	66 90                	xchg   %ax,%ax

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
